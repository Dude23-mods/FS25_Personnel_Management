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
        classObject.saveToXMLFile = Utils.overwrittenFunction(saveToXMLFile, HelperPersonnelAIJobHooks.onAIJobSaveToXMLFile)
    end

    local loadFromXMLFile = rawget(classObject, "loadFromXMLFile")
    if loadFromXMLFile ~= nil then
        classObject.loadFromXMLFile = Utils.overwrittenFunction(loadFromXMLFile, HelperPersonnelAIJobHooks.onAIJobLoadFromXMLFile)
    end

    local writeStream = rawget(classObject, "writeStream")
    if writeStream ~= nil then
        classObject.writeStream = Utils.overwrittenFunction(writeStream, HelperPersonnelAIJobHooks.onAIJobWriteStream)
    end

    local readStream = rawget(classObject, "readStream")
    if readStream ~= nil and hookOptions.skipReadStream ~= true then
        classObject.readStream = Utils.overwrittenFunction(readStream, HelperPersonnelAIJobHooks.onAIJobReadStream)
    end

    local getHelperName = rawget(classObject, "getHelperName")
    if getHelperName ~= nil then
        classObject.getHelperName = Utils.overwrittenFunction(getHelperName, HelperPersonnelAIJobHooks.onAIJobGetHelperName)
    end

    local getTitle = rawget(classObject, "getTitle")
    if getTitle ~= nil then
        classObject.getTitle = Utils.overwrittenFunction(getTitle, HelperPersonnelAIJobHooks.onAIJobGetTitle)
    end

    local getPricePerMs = rawget(classObject, "getPricePerMs")
    if getPricePerMs ~= nil then
        classObject.getPricePerMs = Utils.overwrittenFunction(getPricePerMs, HelperPersonnelAIJobHooks.onGetPricePerMs)
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
            AIJob.start = Utils.overwrittenFunction(AIJob.start, HelperPersonnelAIJobHooks.onAIJobStart)
        end
        if AIJob.stop ~= nil then
            AIJob.stop = Utils.prependedFunction(AIJob.stop, HelperPersonnelAIJobHooks.onAIJobStop)
        end
        if AIJob.writeStream ~= nil then
            AIJob.writeStream = Utils.overwrittenFunction(AIJob.writeStream, HelperPersonnelAIJobHooks.onAIJobWriteStream)
        end
        if AIJob.readStream ~= nil then
            AIJob.readStream = Utils.overwrittenFunction(AIJob.readStream, HelperPersonnelAIJobHooks.onAIJobReadStream)
        end

        if AIJob.saveToXMLFile ~= nil then
            AIJob.saveToXMLFile = Utils.overwrittenFunction(AIJob.saveToXMLFile, HelperPersonnelAIJobHooks.onAIJobSaveToXMLFile)
        end

        if AIJob.loadFromXMLFile ~= nil then
            AIJob.loadFromXMLFile = Utils.overwrittenFunction(AIJob.loadFromXMLFile, HelperPersonnelAIJobHooks.onAIJobLoadFromXMLFile)
        end

        if AIJob.getHelperName ~= nil then
            AIJob.getHelperName = Utils.overwrittenFunction(AIJob.getHelperName, HelperPersonnelAIJobHooks.onAIJobGetHelperName)
        end

        if AIJob.getTitle ~= nil then
            AIJob.getTitle = Utils.overwrittenFunction(AIJob.getTitle, HelperPersonnelAIJobHooks.onAIJobGetTitle)
        end

        if AIJob.getPricePerMs ~= nil then
            AIJob.getPricePerMs = Utils.overwrittenFunction(AIJob.getPricePerMs, HelperPersonnelAIJobHooks.onGetPricePerMs)
        end
    end

    if AISystem ~= nil and AISystem.startJob ~= nil then
        AISystem.startJob = Utils.overwrittenFunction(AISystem.startJob, HelperPersonnelAIJobHooks.onAISystemStartJob)
    end

    if AIJobStartRequestEvent ~= nil then
        if AIJobStartRequestEvent.new ~= nil and HelperPersonnelAIJobHooks.originalAIJobStartRequestEventNew == nil then
            HelperPersonnelAIJobHooks.originalAIJobStartRequestEventNew = AIJobStartRequestEvent.new
            AIJobStartRequestEvent.new = HelperPersonnelAIJobHooks.onAIJobStartRequestEventNew
        end

        if AIJobStartRequestEvent.writeStream ~= nil then
            AIJobStartRequestEvent.writeStream = Utils.overwrittenFunction(AIJobStartRequestEvent.writeStream, HelperPersonnelAIJobHooks.onAIJobStartRequestEventWriteStream)
        end

        if AIJobStartRequestEvent.readStream ~= nil and HelperPersonnelAIJobHooks.originalAIJobStartRequestEventReadStream == nil then
            HelperPersonnelAIJobHooks.originalAIJobStartRequestEventReadStream = AIJobStartRequestEvent.readStream
            AIJobStartRequestEvent.readStream = HelperPersonnelAIJobHooks.onAIJobStartRequestEventReadStream
        end

        if AIJobStartRequestEvent.run ~= nil then
            AIJobStartRequestEvent.run = Utils.overwrittenFunction(AIJobStartRequestEvent.run, HelperPersonnelAIJobHooks.onAIJobStartRequestEventRun)
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

function HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
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

    local app = g_helperPersonnelApp
    if app ~= nil and app.helperBridge ~= nil then
        if app.helperBridge.getWorkerIdByJob ~= nil then
            local workerId = app.helperBridge:getWorkerIdByJob(job)
            if workerId ~= nil then
                job.helperPersonnelWorkerId = workerId
                return workerId
            end
        end

        if app.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
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

    if app.helperBridge ~= nil
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

    job.helperPersonnelWorkerId = workerId

    if app.helperBridge ~= nil then
        return app.helperBridge:applyWorkerToJob(job, workerId)
    end

    return nil
end

function HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job)
    local app = g_helperPersonnelApp
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
        return
    end

    HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)

    if app.helperBridge.onJobStarted ~= nil then
        app.helperBridge:onJobStarted(job, workerId)
    end

    if app.consumePendingWorkerForVehicle ~= nil then
        app:consumePendingWorkerForVehicle(HelperPersonnelAIJobHooks.getVehicleFromJob(job))
    end
end

function HelperPersonnelAIJobHooks.onAIJobStart(job, superFunc, farmId, ...)
    local args = {...}
    local app = g_helperPersonnelApp
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
    local result = nil

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJob.start | Job=%s | Farm=%s | Worker=%s | App=%s",
        hpJobDebugJobName(job), tostring(farmId), tostring(workerId), tostring(app ~= nil))

    if workerId ~= nil and not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJob.start aborted | Reason=workerNotAvailable | Job=%s | Worker=%s", hpJobDebugJobName(job), tostring(workerId))
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

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJob.start result | Job=%s | Worker=%s | Result=%s", hpJobDebugJobName(job), tostring(workerId), tostring(result))

    if result ~= false and app ~= nil and app.helperBridge ~= nil and job ~= nil then
        if workerId == nil then
            workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
        end

        if workerId ~= nil then
            hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIJob.start finalized | Job=%s | Worker=%s", hpJobDebugJobName(job), tostring(workerId))
            HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
        end
    end

    return result
end

function HelperPersonnelAIJobHooks.onAISystemStartJob(aiSystem, superFunc, job, farmId, ...)
    local args = {...}
    local app = g_helperPersonnelApp
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)

    local isRestorePhase = app ~= nil
        and app.activeJobsRestoreDone ~= true

    local isSendingSelected = HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.isSendingSelectedAIJob == true
    local isRunningStartRequest = HelperPersonnelAIJobHooks.isRunningStartRequestEvent == true
    local shouldHandleStart = false

    if workerId == nil
        and app ~= nil
        and not isRestorePhase
        and not isSendingSelected
        and not isRunningStartRequest
        and HelperPersonnelAIStartHooks ~= nil
        and HelperPersonnelAIStartHooks.shouldHandleAIJobStart ~= nil then
        shouldHandleStart = HelperPersonnelAIStartHooks.shouldHandleAIJobStart(job)
    end

    local isFollowMe = HelperPersonnelAIJobHooks.isFollowMeJob(job)
    local followVehicle = nil
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow ~= nil then
        followVehicle = HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow(job)
    end

    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISystem.startJob | Job=%s | FollowMe=%s | Vehicle=%s | Target=%s | Farm=%s | Worker=%s | Restore=%s | SelectedSend=%s | EventRun=%s | ShouldSelect=%s",
        hpJobDebugJobName(job),
        tostring(isFollowMe),
        hpJobDebugVehicleName(HelperPersonnelAIJobHooks.getVehicleFromJob(job)),
        hpJobDebugVehicleName(followVehicle),
        tostring(farmId),
        tostring(workerId),
        tostring(isRestorePhase),
        tostring(isSendingSelected),
        tostring(isRunningStartRequest),
        tostring(shouldHandleStart))

    if shouldHandleStart then
        local queued = false
        if HelperPersonnelAIStartHooks.queueSelectionForAIJob ~= nil then
            queued = HelperPersonnelAIStartHooks.queueSelectionForAIJob(job, farmId)
        elseif HelperPersonnelAIStartHooks.openSelectionForAIJob ~= nil then
            queued = HelperPersonnelAIStartHooks.openSelectionForAIJob(job, farmId)
        end

        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISystem.startJob selection inserted | Job=%s | Queued=%s", hpJobDebugJobName(job), tostring(queued))

        if not queued then
            hpJobStartDebug("FS25_HelperPersonnel: Direct AI job without a worker was blocked")
        end

        return false
    end

    if workerId ~= nil then
        if not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
            hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISystem.startJob aborted | Reason=workerNotAvailable | Job=%s | Worker=%s", hpJobDebugJobName(job), tostring(workerId))
            HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
            return false
        end

        local result = HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, function()
            return superFunc(aiSystem, job, farmId, unpack(args))
        end)

        hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISystem.startJob result with worker | Job=%s | Worker=%s | Result=%s", hpJobDebugJobName(job), tostring(workerId), tostring(result))

        if result ~= false then
            HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
        end

        return result
    end

    local result = superFunc(aiSystem, job, farmId, unpack(args))
    hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISystem.startJob result without worker | Job=%s | Result=%s", hpJobDebugJobName(job), tostring(result))

    if result ~= false and app ~= nil and app.helperBridge ~= nil and job ~= nil then
        workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
        if workerId ~= nil then
            hpJobStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISystem.startJob finalized afterward | Job=%s | Worker=%s", hpJobDebugJobName(job), tostring(workerId))
            HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
        end
    end

    return result
end

function HelperPersonnelAIJobHooks.onAIJobStop(job, aiMessage)
    local app = g_helperPersonnelApp
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
