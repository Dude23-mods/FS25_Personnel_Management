HelperPersonnelAIJobHooks = {}

local function hpJobStartDebug(message, ...)
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.debugStart ~= nil then
        HelperPersonnelAIStartHooks.debugStart(message, ...)
    elseif Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

local function hpJobDebugJobName(job)
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getDebugJobName ~= nil then
        return HelperPersonnelAIStartHooks.getDebugJobName(job)
    end
    return tostring(job)
end

local function hpJobDebugVehicleName(vehicle)
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getDebugVehicleName ~= nil then
        return HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle)
    end
    return tostring(vehicle)
end

HelperPersonnelAIJobHooks.XML_ATTR_WORKER_ID = "#helperPersonnelWorkerId"
HelperPersonnelAIJobHooks.XML_ATTR_HELPER_NAME = "#helperPersonnelHelperName"
HelperPersonnelAIJobHooks.XML_ATTR_BASE_HELPER_INDEX = "#helperPersonnelBaseHelperIndex"
HelperPersonnelAIJobHooks.pendingRestoredJobs = HelperPersonnelAIJobHooks.pendingRestoredJobs or {}

local function hpRegisterAIJobHook(owner, methodName, hookKind, hookFunction, hookKey, purpose, side)
    if HelperPersonnelHookRegistrar ~= nil and HelperPersonnelHookRegistrar.install ~= nil then
        return HelperPersonnelHookRegistrar:install(owner, methodName, hookKind, hookFunction, hookKey, purpose, side)
    end

    if owner == nil or owner[methodName] == nil or Utils == nil then
        return false
    end
    if hookKind == "append" then
        owner[methodName] = Utils.appendedFunction(owner[methodName], hookFunction)
    elseif hookKind == "prepend" then
        owner[methodName] = Utils.prependedFunction(owner[methodName], hookFunction)
    else
        owner[methodName] = Utils.overwrittenFunction(owner[methodName], hookFunction)
    end
    return true
end

function HelperPersonnelAIJobHooks.onAIJobSaveToXMLFile(job, superFunc, xmlFile, key, ...)
    superFunc(job, xmlFile, key, ...)

    if xmlFile == nil or key == nil then
        return
    end

    local workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)

    if workerId == nil and g_helperManager ~= nil and g_helperManager.getHelperByIndex ~= nil and job ~= nil and job.helperIndex ~= nil then
        local helper = g_helperManager:getHelperByIndex(job.helperIndex)
        if helper ~= nil then
            workerId = helper.helperPersonnelWorkerId
        end
    end

    if workerId ~= nil then
        xmlFile:setInt(key .. HelperPersonnelAIJobHooks.XML_ATTR_WORKER_ID, workerId)

        if job ~= nil and job.helperPersonnelBaseHelperIndex ~= nil then
            xmlFile:setInt(key .. HelperPersonnelAIJobHooks.XML_ATTR_BASE_HELPER_INDEX, job.helperPersonnelBaseHelperIndex)
        end

        if g_helperManager ~= nil and g_helperManager.getHelperByIndex ~= nil and job ~= nil and job.helperIndex ~= nil then
            local helper = g_helperManager:getHelperByIndex(job.helperIndex)
            if helper ~= nil then
                local helperName = helper.helperPersonnelKey or HelperPersonnelAIJobHooks.getHelperKeyFromWorkerId(workerId) or helper.name
                if helperName ~= nil then
                    xmlFile:setString(key .. HelperPersonnelAIJobHooks.XML_ATTR_HELPER_NAME, helperName)
                end

                if job.helperPersonnelBaseHelperIndex == nil and helper.helperPersonnelBaseHelperIndex ~= nil then
                    xmlFile:setInt(key .. HelperPersonnelAIJobHooks.XML_ATTR_BASE_HELPER_INDEX, helper.helperPersonnelBaseHelperIndex)
                end
            end
        end
    end
end

function HelperPersonnelAIJobHooks.onAIJobLoadFromXMLFile(job, superFunc, xmlFile, key, ...)
    superFunc(job, xmlFile, key, ...)

    if xmlFile == nil or key == nil or job == nil then
        return
    end

    local workerId = xmlFile:getInt(key .. HelperPersonnelAIJobHooks.XML_ATTR_WORKER_ID, -1)
    if (workerId == nil or workerId <= 0) and xmlFile.getString ~= nil then
        local helperName = xmlFile:getString(key .. HelperPersonnelAIJobHooks.XML_ATTR_HELPER_NAME)
        workerId = HelperPersonnelAIJobHooks.getWorkerIdFromHelperName(helperName) or -1
    end

    local baseHelperIndex = xmlFile:getInt(key .. HelperPersonnelAIJobHooks.XML_ATTR_BASE_HELPER_INDEX, -1)

    if workerId ~= nil and workerId > 0 then
        job.helperPersonnelWorkerId = workerId
        job.hpHelperPersonnelRestoredWorkerId = workerId
        if baseHelperIndex ~= nil and baseHelperIndex > 0 then
            job.helperPersonnelBaseHelperIndex = baseHelperIndex
        end

        HelperPersonnelAIJobHooks.pendingRestoredJobs[job] = workerId
    end
end

function HelperPersonnelAIJobHooks.installJobClassHooks(className, classObject, hookOptions)
    classObject = classObject or _G[className]
    if classObject == nil or classObject.helperPersonnelJobHooksInstalled == true then
        return
    end

    hookOptions = hookOptions or {}
    classObject.helperPersonnelJobHooksInstalled = true

    local saveToXMLFile = rawget(classObject, "saveToXMLFile")
    if saveToXMLFile ~= nil then
        hpRegisterAIJobHook(classObject, "saveToXMLFile", "overwrite", HelperPersonnelAIJobHooks.onAIJobSaveToXMLFile, "giants." .. className .. ".saveToXMLFile", "KI-Job-Persistenz", "both")
    end

    local loadFromXMLFile = rawget(classObject, "loadFromXMLFile")
    if loadFromXMLFile ~= nil then
        hpRegisterAIJobHook(classObject, "loadFromXMLFile", "overwrite", HelperPersonnelAIJobHooks.onAIJobLoadFromXMLFile, "giants." .. className .. ".loadFromXMLFile", "KI-Job-Persistenz", "both")
    end

    local writeStream = rawget(classObject, "writeStream")
    if writeStream ~= nil then
        hpRegisterAIJobHook(classObject, "writeStream", "overwrite", HelperPersonnelAIJobHooks.onAIJobWriteStream, "giants." .. className .. ".writeStream", "KI-Job-Netzwerk", "both")
    end

    local readStream = rawget(classObject, "readStream")
    if readStream ~= nil and hookOptions.skipReadStream ~= true then
        hpRegisterAIJobHook(classObject, "readStream", "overwrite", HelperPersonnelAIJobHooks.onAIJobReadStream, "giants." .. className .. ".readStream", "KI-Job-Netzwerk", "both")
    end

    local getHelperName = rawget(classObject, "getHelperName")
    if getHelperName ~= nil then
        hpRegisterAIJobHook(classObject, "getHelperName", "overwrite", HelperPersonnelAIJobHooks.onAIJobGetHelperName, "giants." .. className .. ".getHelperName", "KI-Helferprofil", "both")
    end

    local getTitle = rawget(classObject, "getTitle")
    if getTitle ~= nil then
        hpRegisterAIJobHook(classObject, "getTitle", "overwrite", HelperPersonnelAIJobHooks.onAIJobGetTitle, "giants." .. className .. ".getTitle", "KI-Helferprofil", "both")
    end

    local getPricePerMs = rawget(classObject, "getPricePerMs")
    if getPricePerMs ~= nil then
        hpRegisterAIJobHook(classObject, "getPricePerMs", "overwrite", HelperPersonnelAIJobHooks.onGetPricePerMs, "giants." .. className .. ".getPricePerMs", "KI-Lohnberechnung", "server")
    end
end

function HelperPersonnelAIJobHooks.install(stageName)
    stageName = stageName or "initial"

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics AIJobHooks enabled | Phase=%s | AIJob.start=%s | AISystem.startJob=%s | AIJobStartRequestEvent.new=%s | writeStream=%s | readStream=%s | run=%s",
        tostring(stageName),
        tostring(AIJob ~= nil and AIJob.start ~= nil),
        tostring(AISystem ~= nil and AISystem.startJob ~= nil),
        tostring(AIJobStartRequestEvent ~= nil and AIJobStartRequestEvent.new ~= nil),
        tostring(AIJobStartRequestEvent ~= nil and AIJobStartRequestEvent.writeStream ~= nil),
        tostring(AIJobStartRequestEvent ~= nil and AIJobStartRequestEvent.readStream ~= nil),
        tostring(AIJobStartRequestEvent ~= nil and AIJobStartRequestEvent.run ~= nil))

    if HelperPersonnelAIJobHooks.isInstalled == true then
        local delayedJobHookTargets = {
            "AIJobFieldWork",
            "AIJobDeliver",
            "AIJobConveyor",
            "AIJobGoTo",
            "AIJobLoadAndDeliver",
            "AIJobFollowVehicle"
        }

        for _, className in ipairs(delayedJobHookTargets) do
            HelperPersonnelAIJobHooks.installJobClassHooks(className)
        end

        return
    end

    HelperPersonnelAIJobHooks.isInstalled = true

    if AIJob ~= nil then
        if AIJob.start ~= nil then
            hpRegisterAIJobHook(AIJob, "start", "overwrite", HelperPersonnelAIJobHooks.onAIJobStart, "giants.AIJob.start", "KI-Job-Start", "both")
        end
        if AIJob.stop ~= nil then
            hpRegisterAIJobHook(AIJob, "stop", "prepend", HelperPersonnelAIJobHooks.onAIJobStop, "giants.AIJob.stop", "KI-Job-Ende", "both")
        end
        if AIJob.writeStream ~= nil then
            hpRegisterAIJobHook(AIJob, "writeStream", "overwrite", HelperPersonnelAIJobHooks.onAIJobWriteStream, "giants.AIJob.writeStream", "KI-Job-Netzwerk", "both")
        end
        if AIJob.readStream ~= nil then
            hpRegisterAIJobHook(AIJob, "readStream", "overwrite", HelperPersonnelAIJobHooks.onAIJobReadStream, "giants.AIJob.readStream", "KI-Job-Netzwerk", "both")
        end

        if AIJob.saveToXMLFile ~= nil then
            hpRegisterAIJobHook(AIJob, "saveToXMLFile", "overwrite", HelperPersonnelAIJobHooks.onAIJobSaveToXMLFile, "giants.AIJob.saveToXMLFile", "KI-Job-Persistenz", "both")
        end

        if AIJob.loadFromXMLFile ~= nil then
            hpRegisterAIJobHook(AIJob, "loadFromXMLFile", "overwrite", HelperPersonnelAIJobHooks.onAIJobLoadFromXMLFile, "giants.AIJob.loadFromXMLFile", "KI-Job-Persistenz", "both")
        end

        if AIJob.getHelperName ~= nil then
            hpRegisterAIJobHook(AIJob, "getHelperName", "overwrite", HelperPersonnelAIJobHooks.onAIJobGetHelperName, "giants.AIJob.getHelperName", "KI-Helferprofil", "both")
        end

        if AIJob.getTitle ~= nil then
            hpRegisterAIJobHook(AIJob, "getTitle", "overwrite", HelperPersonnelAIJobHooks.onAIJobGetTitle, "giants.AIJob.getTitle", "KI-Helferprofil", "both")
        end

        if AIJob.getPricePerMs ~= nil then
            hpRegisterAIJobHook(AIJob, "getPricePerMs", "overwrite", HelperPersonnelAIJobHooks.onGetPricePerMs, "giants.AIJob.getPricePerMs", "KI-Lohnberechnung", "server")
        end
    end

    if AISystem ~= nil and AISystem.startJob ~= nil then
        hpRegisterAIJobHook(AISystem, "startJob", "overwrite", HelperPersonnelAIJobHooks.onAISystemStartJob, "giants.AISystem.startJob", "KI-Job-Start", "both")
    end

    if AIJobStartRequestEvent ~= nil then
        if AIJobStartRequestEvent.new ~= nil and HelperPersonnelAIJobHooks.originalAIJobStartRequestEventNew == nil then
            HelperPersonnelAIJobHooks.originalAIJobStartRequestEventNew = AIJobStartRequestEvent.new
            if HelperPersonnelHookRegistrar ~= nil and HelperPersonnelHookRegistrar.replace ~= nil then
                HelperPersonnelHookRegistrar:replace(AIJobStartRequestEvent, "new", HelperPersonnelAIJobHooks.onAIJobStartRequestEventNew,
                    "giants.AIJobStartRequestEvent.new", "KI-Start-Anfrage", "client")
            else
                AIJobStartRequestEvent.new = HelperPersonnelAIJobHooks.onAIJobStartRequestEventNew
            end
        end

        if AIJobStartRequestEvent.writeStream ~= nil then
            hpRegisterAIJobHook(AIJobStartRequestEvent, "writeStream", "overwrite", HelperPersonnelAIJobHooks.onAIJobStartRequestEventWriteStream, "giants.AIJobStartRequestEvent.writeStream", "KI-Start-Anfrage", "client")
        end

        if AIJobStartRequestEvent.readStream ~= nil and HelperPersonnelAIJobHooks.originalAIJobStartRequestEventReadStream == nil then
            HelperPersonnelAIJobHooks.originalAIJobStartRequestEventReadStream = AIJobStartRequestEvent.readStream
            if HelperPersonnelHookRegistrar ~= nil and HelperPersonnelHookRegistrar.replace ~= nil then
                HelperPersonnelHookRegistrar:replace(AIJobStartRequestEvent, "readStream", HelperPersonnelAIJobHooks.onAIJobStartRequestEventReadStream,
                    "giants.AIJobStartRequestEvent.readStream", "KI-Start-Anfrage", "server")
            else
                AIJobStartRequestEvent.readStream = HelperPersonnelAIJobHooks.onAIJobStartRequestEventReadStream
            end
        end

        if AIJobStartRequestEvent.run ~= nil then
            hpRegisterAIJobHook(AIJobStartRequestEvent, "run", "overwrite", HelperPersonnelAIJobHooks.onAIJobStartRequestEventRun, "giants.AIJobStartRequestEvent.run", "KI-Start-Autorisierung", "server")
        end
    end

    local jobHookTargets = {
        "AIJobFieldWork",
        "AIJobDeliver",
        "AIJobConveyor",
        "AIJobGoTo",
        "AIJobLoadAndDeliver",
        "AIJobFollowVehicle"
    }

    for _, className in ipairs(jobHookTargets) do
        HelperPersonnelAIJobHooks.installJobClassHooks(className)
    end
end

function HelperPersonnelAIJobHooks.getHelperKeyFromWorkerId(workerId)
    local numericWorkerId = tonumber(workerId)
    if numericWorkerId == nil then
        return nil
    end

    return string.format("HP_WORKER_%d", numericWorkerId)
end

function HelperPersonnelAIJobHooks.getWorkerIdFromHelperName(helperName)
    if helperName == nil then
        return nil
    end

    local workerId = string.match(tostring(helperName), "^HP_WORKER_(%d+)$")
    if workerId ~= nil then
        return tonumber(workerId)
    end

    return nil
end

function HelperPersonnelAIJobHooks.isFollowMeJob(job)
    if HelperPersonnelCompatibility ~= nil and HelperPersonnelCompatibility.isFollowMeJob ~= nil then
        return HelperPersonnelCompatibility.isFollowMeJob(job) == true
    end

    if job == nil then
        return false
    end

    if AIJobFollowVehicle ~= nil and job.isa ~= nil then
        local success, result = pcall(job.isa, job, AIJobFollowVehicle)
        if success and result == true then
            return true
        end
    end

    if job.followVehicleTask ~= nil or job.followVehicleParameter ~= nil then
        return true
    end

    local text = ""
    if type(job) == "table" then
        text = tostring(job.className or "") .. " " .. tostring(job.typeName or "") .. " " .. tostring(job.name or "")
        local mt = getmetatable(job)
        if type(mt) == "table" then
            text = text .. " " .. tostring(mt.__name or "") .. " " .. tostring(mt.className or "")
        end
    end
    text = string.lower(text .. " " .. tostring(job))

    return string.find(text, "aijobfollowvehicle", 1, true) ~= nil or string.find(text, "followvehicle", 1, true) ~= nil
end

function HelperPersonnelAIJobHooks.getVehicleFromJob(job)
    local app = g_helperPersonnelApp
    if app ~= nil and app.helperBridge ~= nil and app.helperBridge.getVehicleFromJob ~= nil then
        return app.helperBridge:getVehicleFromJob(job)
    end

    if job ~= nil then
        if job.vehicle ~= nil then
            return job.vehicle
        end

        if job.vehicleParameter ~= nil and job.vehicleParameter.getVehicle ~= nil then
            local success, vehicle = pcall(job.vehicleParameter.getVehicle, job.vehicleParameter)
            if success and vehicle ~= nil then
                return vehicle
            end
        end
    end

    return nil
end

function HelperPersonnelAIJobHooks.getPersonnelHelperName(job)
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
    if workerId == nil then
        return nil
    end

    local app = g_helperPersonnelApp
    if app ~= nil and app.manager ~= nil then
        local worker = app.manager:getWorkerById(workerId)
        if worker ~= nil then
            return app.manager:getFullName(worker)
        end
    end

    return nil
end

function HelperPersonnelAIJobHooks.onAIJobGetHelperName(job, superFunc, ...)
    local helperName = HelperPersonnelAIJobHooks.getPersonnelHelperName(job)
    if helperName ~= nil and helperName ~= "" then
        return helperName
    end

    return superFunc(job, ...)
end

function HelperPersonnelAIJobHooks.onAIJobGetTitle(job, superFunc, ...)
    local helperName = HelperPersonnelAIJobHooks.getPersonnelHelperName(job)
    if helperName ~= nil and helperName ~= "" then
        return helperName
    end

    return superFunc(job, ...)
end

function HelperPersonnelAIJobHooks.isTransportJob(job)
    return HelperPersonnelTransportAssignments ~= nil and HelperPersonnelTransportAssignments.isTransportJob(job) == true
end

function HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
    if HelperPersonnelTransportAssignments ~= nil and HelperPersonnelTransportAssignments.shouldIgnoreWorkerFromJob(job) then
        return nil
    end
    if job == nil then
        return nil
    end

    if HelperPersonnelAIJobHooks.isFollowMeJob(job) then
        local app = g_helperPersonnelApp
        if app ~= nil and app.helperBridge ~= nil and app.helperBridge.jobWorkerIds ~= nil and app.helperBridge.jobWorkerIds[job] ~= nil then
            return app.helperBridge.jobWorkerIds[job]
        end

        if job.helperPersonnelWorkerId ~= nil then
            return job.helperPersonnelWorkerId
        end

        return nil
    end

    if job.helperPersonnelWorkerId ~= nil then
        return job.helperPersonnelWorkerId
    end

    if job.hpCourseplayNeedsWorkerSelection == true then
        return nil
    end

    local app = g_helperPersonnelApp
    if app ~= nil and app.helperBridge ~= nil then
        if app.helperBridge.getWorkerIdByJob ~= nil then
            local workerId = app.helperBridge:getWorkerIdByJob(job)
            if workerId ~= nil then
                job.helperPersonnelWorkerId = workerId
                return workerId
            end
        end

        if app.activeJobsRestoreDone ~= true and app.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
            local restoredWorkerId = app.helperBridge:resolveRestoredWorkerIdForJob(job)
            if restoredWorkerId ~= nil then
                HelperPersonnelAIJobHooks.applyWorkerToJob(job, restoredWorkerId)
                return restoredWorkerId
            end
        end

        if app.helperBridge.getVehicleKeyFromJob ~= nil and app.helperBridge.getWorkerIdByVehicleKey ~= nil then
            local vehicleKey = app.helperBridge:getVehicleKeyFromJob(job)
            local workerId = app.helperBridge:getWorkerIdByVehicleKey(vehicleKey)
            if workerId ~= nil then
                job.helperPersonnelWorkerId = workerId
                return workerId
            end
        end

        if job.helperIndex ~= nil and app.helperBridge.getWorkerIdByHelperIndex ~= nil then
            local workerId = app.helperBridge:getWorkerIdByHelperIndex(job.helperIndex)
            if workerId ~= nil then
                job.helperPersonnelWorkerId = workerId
                return workerId
            end
        end
    end

    if job.helperIndex ~= nil and g_helperManager ~= nil and g_helperManager.getHelperByIndex ~= nil then
        local helper = g_helperManager:getHelperByIndex(job.helperIndex)
        if helper ~= nil then
            return helper.helperPersonnelWorkerId
                or HelperPersonnelAIJobHooks.getWorkerIdFromHelperName(helper.helperPersonnelKey)
                or HelperPersonnelAIJobHooks.getWorkerIdFromHelperName(helper.name)
                or HelperPersonnelAIJobHooks.getWorkerIdFromHelperName(helper.title)
        end
    end

    return nil
end

function HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
    if HelperPersonnelTransportAssignments ~= nil and HelperPersonnelTransportAssignments.shouldIgnoreWorkerForJob(app, job) then
        return nil
    end
    if app == nil or job == nil then
        return nil
    end

    local vehicle = HelperPersonnelAIJobHooks.getVehicleFromJob(job)

    if HelperPersonnelAIJobHooks.isFollowMeJob(job) then
        local workerId = job.helperPersonnelWorkerId
        if workerId ~= nil then
            local bridge = app.helperBridge
            if bridge ~= nil and bridge.jobWorkerIds ~= nil and bridge.jobWorkerIds[job] == workerId then
                return workerId
            end

            if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.isSendingSelectedAIJob == true then
                return workerId
            end

            if HelperPersonnelAIJobHooks.isRunningStartRequestEvent == true then
                return workerId
            end
        end

        return nil
    end

    if job.helperPersonnelWorkerId ~= nil then
        return job.helperPersonnelWorkerId
    end

    if HelperPersonnelAutoDriveCompatibility ~= nil
        and HelperPersonnelAutoDriveCompatibility.resolveCourseplayHandoffWorker ~= nil then
        local handoffWorkerId = HelperPersonnelAutoDriveCompatibility.resolveCourseplayHandoffWorker(job)
        if handoffWorkerId ~= nil then
            return handoffWorkerId
        end
    end

    if app.activeJobsRestoreDone ~= true
        and app.helperBridge ~= nil
        and app.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
        local restoredWorkerId = app.helperBridge:resolveRestoredWorkerIdForJob(job)
        if restoredWorkerId ~= nil then
            HelperPersonnelAIJobHooks.applyWorkerToJob(job, restoredWorkerId)
            return restoredWorkerId
        end
    end

    if app.consumePendingWorkerForVehicle ~= nil then
        return app:consumePendingWorkerForVehicle(vehicle)
    end

    if app.getPendingWorkerForVehicle ~= nil then
        return app:getPendingWorkerForVehicle(vehicle)
    end

    return nil
end

function HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
    local app = g_helperPersonnelApp
    if app == nil or job == nil or workerId == nil then
        return nil
    end

    job.hpCourseplayNeedsWorkerSelection = nil
    job.helperPersonnelWorkerId = workerId

    if app.helperBridge ~= nil then
        return app.helperBridge:applyWorkerToJob(job, workerId)
    end

    return nil
end

function HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job)
    local app = g_helperPersonnelApp
    if app ~= nil and app.isMultiplayerClient ~= nil and app:isMultiplayerClient() then
        if app.hpJoinSyncApplied ~= true or app.activeJobsRestoreDone ~= true then
            return true
        end
    end
    if app == nil or workerId == nil then
        return false
    end

    if app.helperBridge ~= nil and app.helperBridge.canUseWorkerForJob ~= nil then
        return app.helperBridge:canUseWorkerForJob(workerId, job)
    end

    if app.manager ~= nil and app.manager.isWorkerAvailable ~= nil then
        return app.manager:isWorkerAvailable(workerId)
    end

    return true
end

function HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
    local app = g_helperPersonnelApp
    if app ~= nil and app.showPlayerMessage ~= nil then
        app:showPlayerMessage("ui_selectionWorkerUnavailable")
    end

    if job ~= nil then
        job.helperPersonnelWorkerId = nil
    end

    if app ~= nil and app.consumePendingWorkerForVehicle ~= nil and job ~= nil then
        app:consumePendingWorkerForVehicle(HelperPersonnelAIJobHooks.getVehicleFromJob(job))
    end

    Logging.warning("FS25_HelperPersonnel: Worker ID %s is not available; AI start aborted", tostring(workerId))
end

function HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, callback)
    local forcedHelper = HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
    local originalGetRandomHelper = nil
    local originalGetRandomIndex = nil

    if forcedHelper ~= nil and g_helperManager ~= nil and g_helperManager.getRandomHelper ~= nil then
        originalGetRandomHelper = g_helperManager.getRandomHelper
        g_helperManager.getRandomHelper = function(helperManager, ...)
            return forcedHelper
        end
    end

    if forcedHelper ~= nil and g_helperManager ~= nil and g_helperManager.getRandomIndex ~= nil then
        originalGetRandomIndex = g_helperManager.getRandomIndex
        g_helperManager.getRandomIndex = function(helperManager, ...)
            return forcedHelper.index
        end
    end

    local success, result = pcall(callback)

    if originalGetRandomHelper ~= nil then
        g_helperManager.getRandomHelper = originalGetRandomHelper
    end

    if originalGetRandomIndex ~= nil then
        g_helperManager.getRandomIndex = originalGetRandomIndex
    end

    if not success then
        error(result)
    end

    return result
end

function HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
    if app == nil or app.helperBridge == nil or job == nil or workerId == nil then
        if job ~= nil then
            job.hpHelperPersonnelFinalized = true
            if job.hp1565RestoreRestart == true then
                job.hp1565RestoreConfirmed = true
            end
        end
        return
    end

    HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)

    if app.helperBridge.onJobStarted ~= nil then
        app.helperBridge:onJobStarted(job, workerId)
    end

    if app.consumePendingWorkerForVehicle ~= nil then
        app:consumePendingWorkerForVehicle(HelperPersonnelAIJobHooks.getVehicleFromJob(job))
    end

    job.hpHelperPersonnelFinalized = true
    if job.hp1565RestoreRestart == true then
        job.hp1565RestoreConfirmed = true
    end
end

function HelperPersonnelAIJobHooks.getStartedJobActiveState(app, job)
    if app == nil or job == nil or app.getActiveAIJobs == nil then
        return false, false
    end

    local activeJobs = app:getActiveAIJobs()
    if type(activeJobs) ~= "table" then
        return false, false
    end

    for key, value in pairs(activeJobs) do
        if value == job or key == job then
            return true, true
        end
    end

    return true, false
end

function HelperPersonnelAIJobHooks.shouldFinalizeStartedJob(app, job)
    local known, active = HelperPersonnelAIJobHooks.getStartedJobActiveState(app, job)
    if known then
        return active == true
    end

    return true
end

function HelperPersonnelAIJobHooks.clearPendingStart(app, job)
    if app == nil then
        return
    end

    if app.consumePendingWorkerForVehicle ~= nil and HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob ~= nil then
        app:consumePendingWorkerForVehicle(HelperPersonnelAIJobHooks.getVehicleFromJob(job))
    end
end

function HelperPersonnelAIJobHooks.onAIJobStart(job, superFunc, farmId, ...)
    local args = {...}
    local app = g_helperPersonnelApp
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
    local result = nil
    local insideAISystemStart = (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 0) > 0

    if workerId ~= nil and not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
        HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
        return false
    end

    if workerId ~= nil then
        result = HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, function()
            return superFunc(job, farmId, unpack(args))
        end)
    else
        result = superFunc(job, farmId, unpack(args))
    end

    if result ~= false and app ~= nil and app.helperBridge ~= nil and job ~= nil and not insideAISystemStart then
        if workerId == nil then
            workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
        end

        if workerId ~= nil and HelperPersonnelAIJobHooks.shouldFinalizeStartedJob(app, job) then
            HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
        elseif workerId ~= nil then
            HelperPersonnelAIJobHooks.clearPendingStart(app, job)
        end
    end

    return result
end

local function hpCallAISystemStart(callback)
    HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth = (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 0) + 1
    local success, result = pcall(callback)
    HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth = math.max(0, (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 1) - 1)
    if not success then
        error(result)
    end
    return result
end

function HelperPersonnelAIJobHooks.onAISystemStartJob(aiSystem, superFunc, job, farmId, ...)
    local args = {...}
    local app = g_helperPersonnelApp
    local isRunningStartRequest = HelperPersonnelAIJobHooks.isRunningStartRequestEvent == true
    if not isRunningStartRequest and HelperPersonnelCourseplayCompatibility ~= nil and HelperPersonnelCourseplayCompatibility.prepareAIJobStart ~= nil then
        HelperPersonnelCourseplayCompatibility.prepareAIJobStart(job)
    end
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
    local result = nil

    local startHooks = HelperPersonnelAIStartHooks
    if workerId == nil and app ~= nil and app.activeJobsRestoreDone == true and g_client ~= nil
        and not isRunningStartRequest and startHooks ~= nil and startHooks.isSendingSelectedAIJob ~= true
        and startHooks.shouldHandleAIJobStart ~= nil and startHooks.shouldHandleAIJobStart(job) then
        if startHooks.queueSelectionForAIJob ~= nil then
            startHooks.queueSelectionForAIJob(job, farmId)
        end
        return false
    end

    if workerId ~= nil then
        if not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
            HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
            return false
        end

        result = hpCallAISystemStart(function()
            return HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, function()
                return superFunc(aiSystem, job, farmId, unpack(args))
            end)
        end)

        if result ~= false then
            if HelperPersonnelAIJobHooks.shouldFinalizeStartedJob(app, job) then
                HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
            else
                HelperPersonnelAIJobHooks.clearPendingStart(app, job)
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: AI start was not registered as an active assignment because the job ended immediately")
            end
        end

        return result
    end

    result = hpCallAISystemStart(function()
        return superFunc(aiSystem, job, farmId, unpack(args))
    end)

    if result ~= false and app ~= nil and app.helperBridge ~= nil and job ~= nil then
        workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
        if workerId ~= nil then
            if HelperPersonnelAIJobHooks.shouldFinalizeStartedJob(app, job) then
                HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
            else
                HelperPersonnelAIJobHooks.clearPendingStart(app, job)
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: AI start was not registered as an active assignment because the job ended immediately")
            end
        end
    end

    return result
end

function HelperPersonnelAIJobHooks.onAIJobStop(job, aiMessage)
    local app = g_helperPersonnelApp
    if job ~= nil and job.hpHelperPersonnelStopHandled == true then
        return
    end
    local restoreWorkerId = job ~= nil and job.helperPersonnelWorkerId or nil
    if restoreWorkerId == nil then
        restoreWorkerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
    end
    local bridge = app ~= nil and app.helperBridge or nil
    if bridge ~= nil and job ~= nil and restoreWorkerId ~= nil
        and HelperPersonnelCourseplayCompatibility ~= nil
        and HelperPersonnelCourseplayCompatibility.isCourseplayJob(job) then
        local assignedJob = bridge.workerJobById ~= nil and bridge.workerJobById[restoreWorkerId] or nil
        local worker = app.manager ~= nil and app.manager.getWorkerById ~= nil and app.manager:getWorkerById(restoreWorkerId) or nil
        local vehicleKey = bridge.getVehicleKeyFromJob ~= nil and bridge:getVehicleKeyFromJob(job) or nil
        local workerOnOtherVehicle = worker ~= nil and worker.busy == true and worker.vehicleKey ~= nil
            and vehicleKey ~= nil and worker.vehicleKey ~= vehicleKey
        if (assignedJob ~= nil and assignedJob ~= job) or workerOnOtherVehicle then
            if bridge.jobWorkerIds ~= nil then bridge.jobWorkerIds[job] = nil end
            if vehicleKey ~= nil and bridge.vehicleWorkerIds ~= nil and bridge.vehicleWorkerIds[vehicleKey] == restoreWorkerId
                and (worker == nil or worker.vehicleKey ~= vehicleKey) then
                bridge.vehicleWorkerIds[vehicleKey] = nil
            end
            job.helperPersonnelWorkerId = nil
            job.hpHelperPersonnelStopHandled = true
            return
        end
    end
    if job ~= nil and restoreWorkerId ~= nil and job.hpHelperPersonnelFinalized ~= true then
        if app ~= nil and app.hp1565ClearFailedRestoreJob ~= nil then
            app:hp1565ClearFailedRestoreJob(job, restoreWorkerId, job.hp1565RestoreAssignment, "job was not confirmed as an active assignment")
        end
        return
    end
    if job ~= nil and job.hp1565RestoreRestart == true then
        local now = g_time or (g_currentMission ~= nil and g_currentMission.time) or 0
        if now <= (job.hp1565RestoreProtectUntil or 0) then
            if app ~= nil and app.hp1565ClearFailedRestoreJob ~= nil then
                app:hp1565ClearFailedRestoreJob(job, restoreWorkerId, job.hp1565RestoreAssignment, "restore job ended during the grace period")
            end
            return
        end
    end
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
    local isFollowMe = HelperPersonnelAIJobHooks.isFollowMeJob(job)
    local followVehicle = nil
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow ~= nil then
        followVehicle = HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow(job)
    end

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJob.stop | Job=%s | FollowMe=%s | Vehicle=%s | Target=%s | Worker=%s | MissionDelete=%s | Message=%s",
        hpJobDebugJobName(job),
        tostring(isFollowMe),
        hpJobDebugVehicleName(HelperPersonnelAIJobHooks.getVehicleFromJob(job)),
        hpJobDebugVehicleName(followVehicle),
        tostring(workerId),
        tostring(app ~= nil and app.isMissionDeleting == true),
        tostring(aiMessage))

    if app ~= nil and app.isMissionDeleting == true then
        if workerId ~= nil then
            HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
        end
        return
    end

    if isFollowMe and workerId == nil then
        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJob.stop ignored | Reason=FollowMeWithoutPersonnelAssignment | Job=%s", hpJobDebugJobName(job))
        return
    end

    if app ~= nil and app.helperBridge ~= nil then
        if workerId ~= nil then
            app.helperBridge:attachRestoredJob(job, workerId)
        end

        app.helperBridge:onJobStopped(job)
    elseif workerId ~= nil then
        HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
    end
end

function HelperPersonnelAIJobHooks.onAIJobWriteStream(job, superFunc, streamId, connection)
    superFunc(job, streamId, connection)

    local workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)

    streamWriteBool(streamId, workerId ~= nil)
    if workerId ~= nil then
        streamWriteInt32(streamId, workerId)
    end
end

function HelperPersonnelAIJobHooks.onAIJobReadStream(job, superFunc, streamId, connection)
    superFunc(job, streamId, connection)

    if streamReadBool(streamId) then
        job.helperPersonnelWorkerId = streamReadInt32(streamId)
        HelperPersonnelAIJobHooks.pendingRestoredJobs[job] = job.helperPersonnelWorkerId
    else
        job.helperPersonnelWorkerId = nil
    end
end

function HelperPersonnelAIJobHooks.onAIJobStartRequestEventNew(job, farmId, ...)
    if HelperPersonnelCourseplayCompatibility ~= nil and HelperPersonnelCourseplayCompatibility.prepareAIJobStart ~= nil then
        HelperPersonnelCourseplayCompatibility.prepareAIJobStart(job)
    end

    local originalNew = HelperPersonnelAIJobHooks.originalAIJobStartRequestEventNew
    local event = originalNew(job, farmId, ...)

    if event == nil then
        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.new | Result=nil | Job=%s | Farm=%s", hpJobDebugJobName(job), tostring(farmId))
        return event
    end

    local workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)

    local app = g_helperPersonnelApp
    local isRestorePhase = app ~= nil
        and app.activeJobsRestoreDone ~= true

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.new | Job=%s | Vehicle=%s | Farm=%s | Worker=%s | Restore=%s | SelectedSend=%s",
        hpJobDebugJobName(job),
        hpJobDebugVehicleName(HelperPersonnelAIJobHooks.getVehicleFromJob(job)),
        tostring(farmId),
        tostring(workerId),
        tostring(isRestorePhase),
        tostring(HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.isSendingSelectedAIJob == true))

    if workerId == nil and isRestorePhase and app.helperBridge ~= nil and app.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
        workerId = app.helperBridge:resolveRestoredWorkerIdForJob(job)
        if workerId ~= nil then
            HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
            hpJobStartDebug("FS25_HelperPersonnel: Saved worker assignment applied to restored AI job")
        else
            hpJobStartDebug("FS25_HelperPersonnel: Savegame AI start without a saved worker assignment - worker selection was not opened")
        end
    end

    local shouldOpenSelection = app ~= nil
        and job ~= nil
        and workerId == nil
        and not isRestorePhase
        and not HelperPersonnelAIStartHooks.isSendingSelectedAIJob
        and HelperPersonnelAIStartHooks.shouldHandleAIJobStart ~= nil
        and HelperPersonnelAIStartHooks.shouldHandleAIJobStart(job)

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.new decision | Job=%s | ShouldSelect=%s | Worker=%s", hpJobDebugJobName(job), tostring(shouldOpenSelection), tostring(workerId))

    if shouldOpenSelection then
        event.helperPersonnelCancelStart = true
        event.helperPersonnelWorkerId = nil

        local queued = false
        if HelperPersonnelAIStartHooks.queueSelectionForAIJob ~= nil then
            queued = HelperPersonnelAIStartHooks.queueSelectionForAIJob(job, farmId)
        end

        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.new standard start blocked | Job=%s | Queued=%s", hpJobDebugJobName(job), tostring(queued))

        if not queued then
            hpJobStartDebug("FS25_HelperPersonnel: AI start without a worker was blocked")
        end
    else
        event.helperPersonnelCancelStart = false
        event.helperPersonnelWorkerId = workerId
        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.new start allowed | Job=%s | Worker=%s", hpJobDebugJobName(job), tostring(workerId))
    end

    return event
end

function HelperPersonnelAIJobHooks.onAIJobStartRequestEventWriteStream(event, superFunc, streamId, connection)
    superFunc(event, streamId, connection)

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.writeStream | Cancel=%s | EventWorker=%s | Job=%s",
        tostring(event.helperPersonnelCancelStart == true),
        tostring(event.helperPersonnelWorkerId),
        hpJobDebugJobName(event.job))

    streamWriteBool(streamId, event.helperPersonnelCancelStart == true)

    local workerId = event.helperPersonnelWorkerId
    if workerId == nil and event.job ~= nil then
        workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(event.job)
    end

    streamWriteBool(streamId, workerId ~= nil)
    if workerId ~= nil then
        streamWriteInt32(streamId, workerId)
    end
end

function HelperPersonnelAIJobHooks.onAIJobStartRequestEventReadStream(event, streamId, connection)

    if event == nil or streamId == nil or connection == nil then
        return
    end

    if not connection:getIsServer() then
        event.startFarmId = streamReadUIntN(streamId, FarmManager.FARM_ID_SEND_NUM_BITS)
        local jobTypeIndex = streamReadUInt16(streamId)
        event.job = g_currentMission.aiJobTypeManager:createJob(jobTypeIndex)
        event.job:readStream(streamId, connection)
    else
        event.state = streamReadUInt8(streamId)
        event.jobTypeIndex = streamReadUInt16(streamId)
    end

    event.helperPersonnelCancelStart = streamReadBool(streamId)

    if streamReadBool(streamId) then
        event.helperPersonnelWorkerId = streamReadInt32(streamId)
        if event.job ~= nil then
            event.job.helperPersonnelWorkerId = event.helperPersonnelWorkerId
        end
    else
        event.helperPersonnelWorkerId = nil
    end

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.readStream | Cancel=%s | Worker=%s | Job=%s | ConnectionIsServer=%s",
        tostring(event.helperPersonnelCancelStart == true),
        tostring(event.helperPersonnelWorkerId),
        hpJobDebugJobName(event.job),
        tostring(connection.getIsServer ~= nil and connection:getIsServer() or nil))

    event:run(connection)
end

function HelperPersonnelAIJobHooks.onAIJobStartRequestEventRun(event, superFunc, connection)
    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.run | Cancel=%s | Worker=%s | Job=%s | Connection=%s",
        tostring(event.helperPersonnelCancelStart == true),
        tostring(event.helperPersonnelWorkerId),
        hpJobDebugJobName(event.job),
        tostring(connection))

    if event.helperPersonnelCancelStart == true then
        hpJobStartDebug("FS25_HelperPersonnel: Blocked standard AI start request discarded")
        return
    end

    local workerId = event.helperPersonnelWorkerId
    local app = g_helperPersonnelApp
    if g_server ~= nil and connection ~= nil and connection.getIsServer == nil then
        if Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("FS25_HelperPersonnel: AI job start rejected: connection authority could not be resolved")
        end
        return
    end
    if g_server ~= nil and connection ~= nil and not connection:getIsServer() then
        local vehicle = event.job ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob(event.job) or nil
        local vehicleFarmId = app ~= nil and app.getStrictFarmIdForVehicle ~= nil and app:getStrictFarmIdForVehicle(vehicle) or nil
        local workerFarmId = nil
        if workerId ~= nil and app ~= nil and app.manager ~= nil and app.manager.findWorkerFarmData ~= nil then
            local workerData
            workerData, workerFarmId = app.manager:findWorkerFarmData(workerId)
            if workerData == nil then
                workerFarmId = nil
            end
        end
        local allowed, authorizedFarmId = false, nil
        if app ~= nil and app.resolveAuthorizedFarmId ~= nil and vehicleFarmId ~= nil and workerFarmId ~= nil then
            allowed, authorizedFarmId = app:resolveAuthorizedFarmId(connection, event.startFarmId, vehicleFarmId, "aiJobStart")
        end
        if not allowed or tonumber(workerFarmId) ~= tonumber(authorizedFarmId) then
            if Logging ~= nil and Logging.warning ~= nil then
                Logging.warning("FS25_HelperPersonnel: AI job start rejected: connection, vehicle or worker farm could not be authorized")
            end
            return
        end
    end
    if workerId ~= nil and event.job ~= nil then
        if not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, event.job) then
            hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.run aborted | Reason=workerNotAvailable | Job=%s | Worker=%s", hpJobDebugJobName(event.job), tostring(workerId))
            HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, event.job)
            return
        end

        HelperPersonnelAIJobHooks.applyWorkerToJob(event.job, workerId)
    end

    HelperPersonnelAIJobHooks.isRunningStartRequestEvent = true
    local success, result = pcall(superFunc, event, connection)
    HelperPersonnelAIJobHooks.isRunningStartRequestEvent = false

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJobStartRequestEvent.run result | Success=%s | Result=%s | Job=%s | Worker=%s", tostring(success), tostring(result), hpJobDebugJobName(event.job), tostring(workerId))

    if not success then
        error(result)
    end

    return result
end

function HelperPersonnelAIJobHooks.onGetPricePerMs(job, superFunc, ...)
    if job == nil or type(job.namedParameters) ~= "table" then
        return superFunc(job, ...)
    end

    local workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
    if workerId ~= nil then
        return 0
    end

    return superFunc(job, ...)
end
