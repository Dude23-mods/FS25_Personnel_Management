HelperPersonnelAIStartHooks = {}
HelperPersonnelAIStartHooks.START_DEBUG_LOGGING = false

local function hpStartDebug(message, ...)
    if HelperPersonnelAIStartHooks.START_DEBUG_LOGGING == true and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

local function hpSafeCall(object, methodName)
    if object == nil or methodName == nil or object[methodName] == nil then
        return nil
    end

    local success, result = pcall(object[methodName], object)
    if success then
        return result
    end

    return nil
end

local function hpGetDebugClassName(object)
    if object == nil then
        return "nil"
    end

    if type(object) == "table" then
        if object.className ~= nil then
            return tostring(object.className)
        end
        if object.typeName ~= nil then
            return tostring(object.typeName)
        end
        if object.name ~= nil and type(object.name) == "string" then
            return tostring(object.name)
        end

        local mt = getmetatable(object)
        if type(mt) == "table" then
            if mt.__name ~= nil then
                return tostring(mt.__name)
            end
            if mt.className ~= nil then
                return tostring(mt.className)
            end
        end
    end

    return tostring(object)
end

function HelperPersonnelAIStartHooks.debugStart(message, ...)
    hpStartDebug(message, ...)
end

function HelperPersonnelAIStartHooks.getDebugJobName(job)
    return hpGetDebugClassName(job)
end

function HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle)
    if vehicle == nil then
        return "nil"
    end

    local name = hpSafeCall(vehicle, "getName") or hpSafeCall(vehicle, "getFullName")
    if name ~= nil and name ~= "" then
        return tostring(name)
    end

    if vehicle.configFileName ~= nil then
        return tostring(vehicle.configFileName)
    end

    return hpGetDebugClassName(vehicle)
end

local function getOwnerFarmId(vehicle, fallbackFarmId)
    if vehicle ~= nil and vehicle.getOwnerFarmId ~= nil then
        return vehicle:getOwnerFarmId()
    end

    return fallbackFarmId
end

local function hpInstallStartHook(owner, methodName, hookFunc, hookKey)
    if owner == nil or methodName == nil or hookFunc == nil or hookKey == nil then
        return false
    end

    if owner[methodName] == nil then
        return false
    end

    HelperPersonnelAIStartHooks.installedStartHooks = HelperPersonnelAIStartHooks.installedStartHooks or {}
    if HelperPersonnelAIStartHooks.installedStartHooks[hookKey] == true then
        return true
    end

    owner[methodName] = Utils.overwrittenFunction(owner[methodName], hookFunc)
    HelperPersonnelAIStartHooks.installedStartHooks[hookKey] = true
    return true
end

function HelperPersonnelAIStartHooks.install(stageName)
    stageName = stageName or "initial"

    if HelperPersonnelAIStartHooks.isInstalled ~= true then
        HelperPersonnelAIStartHooks.isInstalled = true
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics enabled | Version=1.0.3.0")
    end

    local aivehicleAvailable = AIVehicle ~= nil and AIVehicle.startAIVehicle ~= nil
    local aiFieldWorkerAvailable = AIFieldWorker ~= nil and AIFieldWorker.onClickActivate ~= nil
    local aiJobVehicleStartAvailable = AIJobVehicle ~= nil and AIJobVehicle.startAIJob ~= nil
    local aiJobVehicleToggleAvailable = AIJobVehicle ~= nil and AIJobVehicle.toggleAIVehicle ~= nil
    local aiModeSettingsChangedAvailable = AIModeSelection ~= nil and AIModeSelection.aiModeSettingsChanged ~= nil
    local aiSettingsDialogShowAvailable = AISettingsDialog ~= nil and AISettingsDialog.show ~= nil

    local hookAIVehicle = hpInstallStartHook(AIVehicle, "startAIVehicle", HelperPersonnelAIStartHooks.onStartAIVehicle, "AIVehicle.startAIVehicle")
    local hookAIFieldWorker = hpInstallStartHook(AIFieldWorker, "onClickActivate", HelperPersonnelAIStartHooks.onFieldWorkerActivate, "AIFieldWorker.onClickActivate")
    local hookAIJobVehicleStart = hpInstallStartHook(AIJobVehicle, "startAIJob", HelperPersonnelAIStartHooks.onStartAIJob, "AIJobVehicle.startAIJob")
    local hookAIJobVehicleToggle = hpInstallStartHook(AIJobVehicle, "toggleAIVehicle", HelperPersonnelAIStartHooks.onToggleAIVehicle, "AIJobVehicle.toggleAIVehicle")
    local hookAIModeSettingsChanged = hpInstallStartHook(AIModeSelection, "aiModeSettingsChanged", HelperPersonnelAIStartHooks.onAIModeSettingsChanged, "AIModeSelection.aiModeSettingsChanged")
    local hookAISettingsDialogShow = hpInstallStartHook(AISettingsDialog, "show", HelperPersonnelAIStartHooks.onAISettingsDialogShow, "AISettingsDialog.show")

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostic hooks | Phase=%s | AIVehicle.startAIVehicle=%s/%s | AIFieldWorker.onClickActivate=%s/%s | AIJobVehicle.startAIJob=%s/%s | AIJobVehicle.toggleAIVehicle=%s/%s | AIModeSelection.aiModeSettingsChanged=%s/%s | AISettingsDialog.show=%s/%s | AIJobStartRequestEvent=%s | AISystem.startJob=%s",
        tostring(stageName),
        tostring(aivehicleAvailable), tostring(hookAIVehicle),
        tostring(aiFieldWorkerAvailable), tostring(hookAIFieldWorker),
        tostring(aiJobVehicleStartAvailable), tostring(hookAIJobVehicleStart),
        tostring(aiJobVehicleToggleAvailable), tostring(hookAIJobVehicleToggle),
        tostring(aiModeSettingsChangedAvailable), tostring(hookAIModeSettingsChanged),
        tostring(aiSettingsDialogShowAvailable), tostring(hookAISettingsDialogShow),
        tostring(AIJobStartRequestEvent ~= nil),
        tostring(AISystem ~= nil and AISystem.startJob ~= nil))
end

function HelperPersonnelAIStartHooks.getAIModeDebugName(aiMode)
    if AIModeSelection ~= nil and AIModeSelection.MODE ~= nil then
        for name, value in pairs(AIModeSelection.MODE) do
            if value == aiMode then
                return tostring(name)
            end
        end
    end

    return tostring(aiMode)
end

function HelperPersonnelAIStartHooks.isWorkerAIMode(aiMode)
    if AIModeSelection ~= nil and AIModeSelection.MODE ~= nil then
        return aiMode == AIModeSelection.MODE.WORKER
    end

    return false
end

function HelperPersonnelAIStartHooks.getVehicleFromAISettingsTarget(target)
    if target == nil then
        return nil
    end

    if target.rootVehicle ~= nil then
        return target.rootVehicle
    end

    if target.vehicle ~= nil then
        return target.vehicle
    end

    return target
end

function HelperPersonnelAIStartHooks.shouldHandleVehicleStart(vehicle)
    local app = g_helperPersonnelApp
    if app == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleVehicleStart=false | Reason=noApp | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    if vehicle == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleVehicleStart=false | Reason=noVehicle")
        return false
    end

    if vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleVehicleStart=false | Reason=alreadyActive | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    if vehicle.getStartableAIJob == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleVehicleStart=false | Reason=noGetStartableAIJob | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    if g_currentMission ~= nil and g_currentMission.disableAIVehicle then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleVehicleStart=false | Reason=disableAIVehicle | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleVehicleStart=true | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
    return true
end

function HelperPersonnelAIStartHooks.getVehicleFromAIJob(job)
    if job == nil then
        return nil
    end

    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob ~= nil then
        local success, vehicle = pcall(HelperPersonnelAIJobHooks.getVehicleFromJob, job)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    local app = g_helperPersonnelApp
    if app ~= nil and app.helperBridge ~= nil and app.helperBridge.getVehicleFromJob ~= nil then
        local success, vehicle = pcall(function()
            return app.helperBridge:getVehicleFromJob(job)
        end)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    if job.vehicle ~= nil then
        return job.vehicle
    end

    if job.vehicleParameter ~= nil then
        if job.vehicleParameter.getVehicle ~= nil then
            local success, vehicle = pcall(job.vehicleParameter.getVehicle, job.vehicleParameter)
            if success and vehicle ~= nil then
                return vehicle
            end
        end

        if job.vehicleParameter.vehicle ~= nil then
            return job.vehicleParameter.vehicle
        end
    end

    return nil
end

function HelperPersonnelAIStartHooks.shouldHandleAIJobStart(job)
    local app = g_helperPersonnelApp
    if app == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleAIJobStart=false | Reason=noApp | Job=%s", HelperPersonnelAIStartHooks.getDebugJobName(job))
        return false
    end

    if job == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleAIJobStart=false | Reason=noJob")
        return false
    end

    local vehicle = HelperPersonnelAIStartHooks.getVehicleFromAIJob(job)
    if vehicle == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleAIJobStart=false | Reason=noVehicle | Job=%s", HelperPersonnelAIStartHooks.getDebugJobName(job))
        return false
    end

    if vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleAIJobStart=false | Reason=vehicleAlreadyActive | Job=%s | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugJobName(job), HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    if g_currentMission ~= nil and g_currentMission.disableAIVehicle then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleAIJobStart=false | Reason=disableAIVehicle | Job=%s | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugJobName(job), HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | shouldHandleAIJobStart=true | Job=%s | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugJobName(job), HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
    return true
end


function HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow(job)
    if job == nil or job.followVehicleParameter == nil then
        return nil
    end

    if job.followVehicleParameter.getVehicle ~= nil then
        local success, vehicle = pcall(job.followVehicleParameter.getVehicle, job.followVehicleParameter)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    if job.followVehicleParameter.vehicle ~= nil then
        return job.followVehicleParameter.vehicle
    end

    return nil
end

function HelperPersonnelAIStartHooks.getExcludedWorkerIdsForJob(job)
    local excludedWorkerIds = nil
    local app = g_helperPersonnelApp

    if app == nil or app.helperBridge == nil or job == nil then
        return nil
    end

    if HelperPersonnelAIJobHooks == nil or HelperPersonnelAIJobHooks.isFollowMeJob == nil or not HelperPersonnelAIJobHooks.isFollowMeJob(job) then
        return nil
    end

    local followVehicle = HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow(job)
    local workerId = nil

    if followVehicle ~= nil and app.helperBridge.getWorkerIdByVehicle ~= nil then
        workerId = app.helperBridge:getWorkerIdByVehicle(followVehicle)
    end

    if workerId == nil and followVehicle ~= nil and app.getVehicleKey ~= nil and app.helperBridge.getWorkerIdByVehicleKey ~= nil then
        workerId = app.helperBridge:getWorkerIdByVehicleKey(app:getVehicleKey(followVehicle))
    end

    if workerId ~= nil then
        excludedWorkerIds = {}
        excludedWorkerIds[tonumber(workerId) or workerId] = true
    end

    return excludedWorkerIds
end

function HelperPersonnelAIStartHooks.queueSelectionForVehicle(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames)
    if vehicle == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | queueSelectionForVehicle=false | Reason=noVehicle | Job=%s | Farm=%s | ReasonPath=%s",
            HelperPersonnelAIStartHooks.getDebugJobName(fallbackJob),
            tostring(fallbackFarmId),
            tostring(reason))
        return false
    end

    local aiJob = fallbackJob
    if aiJob == nil and vehicle.getStartableAIJob ~= nil then
        aiJob = vehicle:getStartableAIJob()
    end

    if aiJob == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | queueSelectionForVehicle=false | Reason=noStartableJob | Vehicle=%s | Farm=%s | ReasonPath=%s",
            HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
            tostring(fallbackFarmId),
            tostring(reason))
        return false
    end

    HelperPersonnelAIStartHooks.pendingSelection = {
        vehicle = vehicle,
        job = aiJob,
        farmId = fallbackFarmId,
        delayFrames = delayFrames or 8,
        reason = reason
    }

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | queueSelectionForVehicle=true | Job=%s | Vehicle=%s | Farm=%s | DelayFrames=%s | ReasonPath=%s",
        HelperPersonnelAIStartHooks.getDebugJobName(aiJob),
        HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
        tostring(fallbackFarmId),
        tostring(HelperPersonnelAIStartHooks.pendingSelection.delayFrames),
        tostring(reason))

    return true
end

function HelperPersonnelAIStartHooks.queueSelectionForAIJob(job, fallbackFarmId)
    local vehicle = HelperPersonnelAIStartHooks.getVehicleFromAIJob(job)
    local followVehicle = HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow(job)
    local excludedWorkerIds = HelperPersonnelAIStartHooks.getExcludedWorkerIdsForJob(job)
    local excludedCount = 0
    if type(excludedWorkerIds) == "table" then
        for _ in pairs(excludedWorkerIds) do
            excludedCount = excludedCount + 1
        end
    end

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | queueSelectionForAIJob ENTER | Job=%s | Vehicle=%s | Target=%s | Farm=%s | FollowMe=%s | Excluded=%s",
        HelperPersonnelAIStartHooks.getDebugJobName(job),
        HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
        HelperPersonnelAIStartHooks.getDebugVehicleName(followVehicle),
        tostring(fallbackFarmId),
        tostring(HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.isFollowMeJob ~= nil and HelperPersonnelAIJobHooks.isFollowMeJob(job) or nil),
        tostring(excludedCount))

    if vehicle == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | queueSelectionForAIJob=false | Reason=noVehicle | Job=%s | Farm=%s", HelperPersonnelAIStartHooks.getDebugJobName(job), tostring(fallbackFarmId))
        return false
    end

    return HelperPersonnelAIStartHooks.queueSelectionForVehicle(vehicle, job, fallbackFarmId, "AIJobStart", 8)
end

function HelperPersonnelAIStartHooks.updatePendingSelection(dt)
    local pending = HelperPersonnelAIStartHooks.pendingSelection
    if pending == nil then
        return
    end

    pending.delayFrames = (pending.delayFrames or 0) - 1
    if pending.delayFrames > 0 then
        return
    end

    HelperPersonnelAIStartHooks.pendingSelection = nil
    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | pendingSelection is being processed | Job=%s | Vehicle=%s | Farm=%s | ReasonPath=%s",
        HelperPersonnelAIStartHooks.getDebugJobName(pending.job),
        HelperPersonnelAIStartHooks.getDebugVehicleName(pending.vehicle),
        tostring(pending.farmId),
        tostring(pending.reason))

    if pending.job == nil or pending.vehicle == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | pendingSelection aborted | Reason=jobOrVehicleMissing | Job=%s | Vehicle=%s",
            HelperPersonnelAIStartHooks.getDebugJobName(pending.job),
            HelperPersonnelAIStartHooks.getDebugVehicleName(pending.vehicle))
        return
    end

    local opened = HelperPersonnelAIStartHooks.openSelectionForVehicle(pending.vehicle, pending.job, pending.farmId)
    if opened then
        hpStartDebug("FS25_HelperPersonnel: AI job from the advanced helper menu intercepted; worker selection opened")
    else
        hpStartDebug("FS25_HelperPersonnel: AI job from the advanced helper menu could not open worker selection")
    end
end

function HelperPersonnelAIStartHooks.sendSelectedAIJob(vehicle, workerId, fallbackJob, fallbackFarmId)
    local app = g_helperPersonnelApp
    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob called | Worker=%s | Vehicle=%s | FallbackJob=%s | Farm=%s",
        tostring(workerId),
        HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
        HelperPersonnelAIStartHooks.getDebugJobName(fallbackJob),
        tostring(fallbackFarmId))

    if app == nil or vehicle == nil or workerId == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob=false | Reason=appVehicleOrWorkerMissing")
        return false
    end

    local aiJob = fallbackJob
    if aiJob == nil and vehicle.getStartableAIJob ~= nil then
        aiJob = vehicle:getStartableAIJob()
    end

    if aiJob == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob=false | Reason=noAIJob | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))
        return false
    end

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob job resolved | Job=%s | Vehicle=%s", HelperPersonnelAIStartHooks.getDebugJobName(aiJob), HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle))

    if app.helperBridge ~= nil and app.helperBridge.canUseWorkerForJob ~= nil and not app.helperBridge:canUseWorkerForJob(workerId, aiJob) then
        if app.showPlayerMessage ~= nil then
            app:showPlayerMessage("ui_selectionWorkerUnavailable")
        end
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob=false | Reason=workerNotAvailable | Worker=%s | Job=%s", tostring(workerId), HelperPersonnelAIStartHooks.getDebugJobName(aiJob))
        return false
    end

    app:prepareAIJobForWorker(aiJob, vehicle, workerId)

    local farmId = getOwnerFarmId(vehicle, fallbackFarmId)
    HelperPersonnel.debugInfo("FS25_HelperPersonnel: AI job is being prepared with worker ID %s", tostring(workerId))

    if g_client ~= nil and g_client.getServerConnection ~= nil and g_client:getServerConnection() ~= nil and AIJobStartRequestEvent ~= nil then
        HelperPersonnelAIStartHooks.isSendingSelectedAIJob = true
        local event = AIJobStartRequestEvent.new(aiJob, farmId)
        HelperPersonnelAIStartHooks.isSendingSelectedAIJob = false

        g_client:getServerConnection():sendEvent(event)
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob=true | Path=ClientEvent | Worker=%s | Job=%s | Farm=%s", tostring(workerId), HelperPersonnelAIStartHooks.getDebugJobName(aiJob), tostring(farmId))
        return true
    end

    if g_currentMission ~= nil and g_currentMission.aiSystem ~= nil and g_currentMission.aiSystem.startJob ~= nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob starts AISystem | Worker=%s | Job=%s | Farm=%s", tostring(workerId), HelperPersonnelAIStartHooks.getDebugJobName(aiJob), tostring(farmId))
        local result = g_currentMission.aiSystem:startJob(aiJob, farmId)
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob result | Path=AISystem | Result=%s | Worker=%s | Job=%s", tostring(result), tostring(workerId), HelperPersonnelAIStartHooks.getDebugJobName(aiJob))
        return result ~= false
    end

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | sendSelectedAIJob=false | Reason=noStartPath | Worker=%s | Job=%s", tostring(workerId), HelperPersonnelAIStartHooks.getDebugJobName(aiJob))
    return false
end

function HelperPersonnelAIStartHooks.openSelectionForVehicle(vehicle, fallbackJob, fallbackFarmId)
    local app = g_helperPersonnelApp
    if app == nil or vehicle == nil then
        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | openSelectionForVehicle=false | Reason=appOrVehicleMissing | Vehicle=%s | Job=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle), HelperPersonnelAIStartHooks.getDebugJobName(fallbackJob))
        return false
    end

    local availableCount = -1
    if app.manager ~= nil and app.manager.getAvailableWorkers ~= nil then
        local success, workers = pcall(app.manager.getAvailableWorkers, app.manager)
        if success and workers ~= nil then
            availableCount = #workers
        end
    end

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | openSelectionForVehicle called | Vehicle=%s | Job=%s | Farm=%s | Overlay=%s | AvailableWorkers=%s",
        HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
        HelperPersonnelAIStartHooks.getDebugJobName(fallbackJob),
        tostring(fallbackFarmId),
        tostring(app.selectionOverlay ~= nil),
        tostring(availableCount))

    local excludedWorkerIds = HelperPersonnelAIStartHooks.getExcludedWorkerIdsForJob(fallbackJob)
    local opened = app:showWorkerSelectionForVehicle(vehicle, function(selectedWorker)
        if selectedWorker == nil then
            return
        end

        hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | worker selection confirmed | Worker=%s | Vehicle=%s | Job=%s", tostring(selectedWorker.id), HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle), HelperPersonnelAIStartHooks.getDebugJobName(fallbackJob))
        HelperPersonnelAIStartHooks.sendSelectedAIJob(vehicle, selectedWorker.id, fallbackJob, fallbackFarmId)
    end, excludedWorkerIds)

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | openSelectionForVehicle result | Opened=%s | Vehicle=%s | Job=%s", tostring(opened), HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle), HelperPersonnelAIStartHooks.getDebugJobName(fallbackJob))

    if opened then
        hpStartDebug("FS25_HelperPersonnel: Standard AI start request intercepted; worker selection opened")
    end

    return opened
end

function HelperPersonnelAIStartHooks.openSelectionForAIJob(job, fallbackFarmId)
    local vehicle = HelperPersonnelAIStartHooks.getVehicleFromAIJob(job)
    if vehicle == nil then
        return false
    end

    local opened = HelperPersonnelAIStartHooks.openSelectionForVehicle(vehicle, job, fallbackFarmId)
    if opened then
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: AI job from the job menu intercepted; worker selection opened")
    end

    return opened
end

function HelperPersonnelAIStartHooks.handleVehicleStart(vehicle, superFunc, ...)
    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | handleVehicleStart called | Vehicle=%s | SuperFunc=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle), tostring(superFunc ~= nil))

    if not HelperPersonnelAIStartHooks.shouldHandleVehicleStart(vehicle) then
        if superFunc ~= nil then
            return superFunc(vehicle, ...)
        end

        return nil
    end

    local startableJob = vehicle:getStartableAIJob()
    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | handleVehicleStart startableJob | Vehicle=%s | Job=%s", HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle), HelperPersonnelAIStartHooks.getDebugJobName(startableJob))
    if startableJob == nil then
        if superFunc ~= nil then
            return superFunc(vehicle, ...)
        end

        return nil
    end

    local app = g_helperPersonnelApp
    local isRestorePhase = app ~= nil
        and app.activeJobsRestoreDone ~= true
        and app.helperBridge ~= nil
        and app.helperBridge.hasPendingRestoredWorkers ~= nil
        and app.helperBridge:hasPendingRestoredWorkers()

    if isRestorePhase then
        local workerId = nil
        if app.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
            workerId = app.helperBridge:resolveRestoredWorkerIdForJob(startableJob)
        end

        if workerId ~= nil then
            app:prepareAIJobForWorker(startableJob, vehicle, workerId)
            app.helperBridge:attachRestoredJob(startableJob, workerId)
            HelperPersonnel.debugInfo("FS25_HelperPersonnel: Saved worker assignment applied to restored vehicle AI start")
        else
            Logging.warning("FS25_HelperPersonnel: Restored vehicle AI start could not be matched to a saved worker")
        end

        if superFunc ~= nil then
            return superFunc(vehicle, ...)
        end

        return nil
    end

    local opened = HelperPersonnelAIStartHooks.openSelectionForVehicle(vehicle, startableJob, getOwnerFarmId(vehicle, nil))
    if opened then
        return nil
    end

    return nil
end

function HelperPersonnelAIStartHooks.onAIModeSettingsChanged(vehicle, superFunc, aiMode, fieldCourseSettings, ...)
    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AIModeSelection.aiModeSettingsChanged | Vehicle=%s | Mode=%s | HasSettings=%s",
        HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
        HelperPersonnelAIStartHooks.getAIModeDebugName(aiMode),
        tostring(fieldCourseSettings ~= nil))

    return superFunc(vehicle, aiMode, fieldCourseSettings, ...)
end

function HelperPersonnelAIStartHooks.onAISettingsDialogShow(userSettings, superFunc, fieldCourseSettings, target, currentMode, fieldX, fieldZ, callbackFunc, callbackSelf, ...)
    local vehicle = HelperPersonnelAIStartHooks.getVehicleFromAISettingsTarget(target)

    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISettingsDialog.show | Target=%s | Vehicle=%s | Mode=%s | HasCallback=%s | HasSettings=%s",
        hpGetDebugClassName(target),
        HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
        HelperPersonnelAIStartHooks.getAIModeDebugName(currentMode),
        tostring(callbackFunc ~= nil),
        tostring(fieldCourseSettings ~= nil))

    local wrappedCallback = callbackFunc
    if callbackFunc ~= nil and vehicle ~= nil then
        wrappedCallback = function(...)
            local callbackArgs = {...}
            local aiMode = nil
            local callbackSettings = nil

            if callbackSelf ~= nil and callbackArgs[1] == callbackSelf then
                aiMode = callbackArgs[2]
                callbackSettings = callbackArgs[3]
            else
                aiMode = callbackArgs[1]
                callbackSettings = callbackArgs[2]
            end

            hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISettingsDialog.Callback | Vehicle=%s | Mode=%s | HasSettings=%s",
                HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
                HelperPersonnelAIStartHooks.getAIModeDebugName(aiMode),
                tostring(callbackSettings ~= nil))

            local result = callbackFunc(unpack(callbackArgs))

            if HelperPersonnelAIStartHooks.isWorkerAIMode(aiMode)
                and HelperPersonnelAIStartHooks.shouldHandleVehicleStart(vehicle) then
                local farmId = getOwnerFarmId(vehicle, nil)
                local queued = HelperPersonnelAIStartHooks.queueSelectionForVehicle(vehicle, nil, farmId, "AISettingsDialogCallback", 10)
                hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | AISettingsDialog.Callback selection after start | Vehicle=%s | Queued=%s",
                    HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle),
                    tostring(queued))
            end

            return result
        end
    end

    return superFunc(userSettings, fieldCourseSettings, target, currentMode, fieldX, fieldZ, wrappedCallback, callbackSelf, ...)
end

function HelperPersonnelAIStartHooks.onStartAIVehicle(vehicle, superFunc, ...)
    return HelperPersonnelAIStartHooks.handleVehicleStart(vehicle, superFunc, ...)
end

function HelperPersonnelAIStartHooks.onFieldWorkerActivate(worker, superFunc, ...)
    hpStartDebug("FS25_HelperPersonnel: Helper start diagnostics | onFieldWorkerActivate | Worker=%s | WorkerVehicle=%s | HasGetStartableAIJob=%s", hpGetDebugClassName(worker), HelperPersonnelAIStartHooks.getDebugVehicleName(worker ~= nil and worker.vehicle or nil), tostring(worker ~= nil and worker.getStartableAIJob ~= nil))

    if worker ~= nil and worker.getStartableAIJob == nil and worker.vehicle ~= nil then
        if superFunc ~= nil then
            return superFunc(worker, ...)
        end

        return nil
    end

    local vehicle = worker.vehicle or worker
    return HelperPersonnelAIStartHooks.handleVehicleStart(vehicle, superFunc, ...)
end

function HelperPersonnelAIStartHooks.onStartAIJob(vehicle, superFunc, ...)
    return HelperPersonnelAIStartHooks.handleVehicleStart(vehicle, superFunc, ...)
end

function HelperPersonnelAIStartHooks.onToggleAIVehicle(vehicle, superFunc, ...)
    if vehicle ~= nil and vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() then
        return superFunc(vehicle, ...)
    end

    return HelperPersonnelAIStartHooks.handleVehicleStart(vehicle, superFunc, ...)
end
