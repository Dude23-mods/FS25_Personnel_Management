HelperPersonnelAutoDriveCompatibility = HelperPersonnelAutoDriveCompatibility or {}

HelperPersonnelAutoDriveCompatibility.START_INPUTS = {
    input_start_stop = true,
    input_parkVehicle = true,
    input_refuelVehicle = true,
    input_repairVehicle = true
}
HelperPersonnelAutoDriveCompatibility.INPUT_IDS = {
    input_start_stop = 1,
    input_parkVehicle = 2,
    input_refuelVehicle = 3,
    input_repairVehicle = 4
}
HelperPersonnelAutoDriveCompatibility.INPUT_NAMES_BY_ID = {
    [1] = "input_start_stop",
    [2] = "input_parkVehicle",
    [3] = "input_refuelVehicle",
    [4] = "input_repairVehicle"
}
HelperPersonnelAutoDriveCompatibility.CONTINUATION_INPUTS = {
    input_parkVehicle = true,
    input_refuelVehicle = true,
    input_repairVehicle = true
}
HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey = {}
HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey = {}
HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey = {}
HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey = {}
HelperPersonnelAutoDriveCompatibility.continuingInputsByVehicleKey = {}
HelperPersonnelAutoDriveCompatibility.vehicleHooks = setmetatable({}, {__mode = "k"})
HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey = {}
HelperPersonnelAutoDriveCompatibility.HANDOFF_TIMEOUT_MS = 10000

function HelperPersonnelAutoDriveCompatibility.getAutoDriveEnvironment()
    if type(FS25_AutoDrive) == "table" then
        return FS25_AutoDrive
    end
    return nil
end

function HelperPersonnelAutoDriveCompatibility.getAutoDriveClass(className)
    local environment = HelperPersonnelAutoDriveCompatibility.getAutoDriveEnvironment()
    if environment ~= nil and environment[className] ~= nil then
        return environment[className]
    end
    if _G ~= nil then
        return _G[className]
    end
    return nil
end

function HelperPersonnelAutoDriveCompatibility.getApp()
    local app = g_helperPersonnelApp
    if app == nil or app.helperBridge == nil or app.manager == nil then
        return nil
    end
    return app
end

function HelperPersonnelAutoDriveCompatibility.logInfo(message, ...)
    if Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

function HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app ~= nil and app.getVehicleName ~= nil then
        local name = app:getVehicleName(vehicle)
        if name ~= nil and tostring(name) ~= "" then
            return tostring(name)
        end
    end
    return "unknown vehicle"
end

function HelperPersonnelAutoDriveCompatibility.getWorkerName(worker)
    if type(worker) ~= "table" then
        return "unknown employee"
    end
    local name = string.format("%s %s", tostring(worker.firstName or ""), tostring(worker.lastName or ""))
    name = string.gsub(name, "^%s*(.-)%s*$", "%1")
    if name == "" then
        return string.format("employee %s", tostring(worker.id or "unknown"))
    end
    return name
end

function HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil or vehicle == nil or app.getVehicleKey == nil then
        return nil
    end
    return app:getVehicleKey(vehicle)
end

function HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle)
    return vehicle ~= nil
        and vehicle.ad ~= nil
        and vehicle.ad.stateModule ~= nil
        and vehicle.ad.typeIsConveyorBelt ~= true
end

function HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
    if not HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle) then
        return false
    end
    return vehicle.ad.stateModule:isActive() == true
end

function HelperPersonnelAutoDriveCompatibility.getFarmId(vehicle, fallbackFarmId)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app ~= nil and app.getStrictFarmIdForVehicle ~= nil then
        local farmId = app:getStrictFarmIdForVehicle(vehicle)
        if farmId ~= nil then
            return farmId
        end
    end
    if tonumber(fallbackFarmId) ~= nil and tonumber(fallbackFarmId) > 0 then
        return tonumber(fallbackFarmId)
    end
    if vehicle ~= nil and vehicle.ad ~= nil and vehicle.ad.stateModule ~= nil
        and vehicle.ad.stateModule.getActualFarmId ~= nil then
        local farmId = vehicle.ad.stateModule:getActualFarmId()
        if tonumber(farmId) ~= nil and tonumber(farmId) > 0 then
            return tonumber(farmId)
        end
    end
    if app ~= nil and app.getFarmIdForVehicle ~= nil then
        return app:getFarmIdForVehicle(vehicle, fallbackFarmId)
    end
    return tonumber(fallbackFarmId) or 1
end

function HelperPersonnelAutoDriveCompatibility.getWorkerIdForVehicle(vehicle)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if app == nil or key == nil then
        return nil
    end

    local workerId = app.helperBridge:getWorkerIdByVehicle(vehicle)
    if workerId ~= nil then
        return tonumber(workerId) or workerId
    end

    if app.manager.getWorkerByVehicleKeyAnyFarm ~= nil then
        local worker = app.manager:getWorkerByVehicleKeyAnyFarm(key)
        if worker ~= nil then
            return worker.id
        end
    end

    return nil
end

function HelperPersonnelAutoDriveCompatibility.isCourseplayJob(job)
    if job == nil or job.helperPersonnelExternalType == "AutoDrive" then
        return false
    end
    local className = tostring(job.className or job.name or "")
    if string.find(string.lower(className), "cp", 1, true) ~= nil
        or string.find(string.lower(className), "courseplay", 1, true) ~= nil then
        return true
    end
    return job.getCpJobParameters ~= nil
end

function HelperPersonnelAutoDriveCompatibility.canUseWorker(vehicle, workerId, allowBusyForVehicle)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    workerId = tonumber(workerId)
    if app == nil or workerId == nil or workerId <= 0 then
        return false
    end

    local worker = app.manager:getWorkerById(workerId)
    if worker == nil then
        return false
    end

    local vehicleFarmId = HelperPersonnelAutoDriveCompatibility.getFarmId(vehicle)
    local workerFarmId = app.manager.getWorkerFarmId ~= nil and app.manager:getWorkerFarmId(workerId) or vehicleFarmId
    if tonumber(vehicleFarmId) ~= nil and tonumber(workerFarmId) ~= nil
        and tonumber(vehicleFarmId) ~= tonumber(workerFarmId) then
        return false
    end

    if worker.busy ~= true and worker.restorePending ~= true then
        return true
    end

    if allowBusyForVehicle == true then
        local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
        local assignedKey = worker.vehicleKey or worker.restoreVehicleKey
        if key ~= nil and assignedKey ~= nil and tostring(key) == tostring(assignedKey) then
            return true
        end
        if app.helperBridge:getWorkerIdByVehicle(vehicle) == workerId then
            return true
        end
    end

    return false
end

function HelperPersonnelAutoDriveCompatibility.reserveWorker(vehicle, workerId, source)
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if key == nil then
        return false
    end
    HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = {
        workerId = tonumber(workerId),
        source = source,
        vehicle = vehicle
    }
    return true
end

function HelperPersonnelAutoDriveCompatibility.resolveWorkerForStart(vehicle)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if app == nil or key == nil then
        return nil, nil
    end

    local reservation = HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key]
    if reservation ~= nil then
        return reservation.workerId, reservation
    end

    local workerId = HelperPersonnelAutoDriveCompatibility.getWorkerIdForVehicle(vehicle)
    if workerId ~= nil then
        return workerId, nil
    end

    return nil, nil
end

function HelperPersonnelAutoDriveCompatibility.applyWorkerContext(workerId)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil then
        return
    end
    local worker = app.manager:getWorkerById(workerId)
    if worker == nil then
        return
    end

    local activity = "Transport"
    if app.manager.getLocalizedText ~= nil then
        activity = app.manager:getLocalizedText("ui_activityTransport", activity)
    end
    worker.currentJobActivityText = activity
    worker.currentJobActivityKey = "ui_activityTransport"
    worker.currentJobActivityFallback = "Transport"
    worker.currentJobFieldId = nil
    worker.currentJobSpecializationKey = HelperPersonnelManager.SPECIALIZATION_TRANSPORT or "transport"
    worker.helperPersonnelAutoDriveContext = true

    if app.manager.rememberWorkerSpecializationContext ~= nil then
        app.manager:rememberWorkerSpecializationContext(worker, HelperPersonnelManager.SPECIALIZATION_TRANSPORT or "transport", 2)
    end
end

function HelperPersonnelAutoDriveCompatibility.clearWorkerContext(workerId)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local worker = app ~= nil and app.manager:getWorkerById(workerId) or nil
    if worker == nil or worker.helperPersonnelAutoDriveContext ~= true then
        return
    end
    worker.currentJobActivityText = nil
    worker.currentJobActivityKey = nil
    worker.currentJobActivityFallback = nil
    worker.currentJobFieldId = nil
    worker.currentJobSpecializationKey = nil
    worker.currentJobSpecializationPractice = nil
    worker.helperPersonnelAutoDriveContext = nil
end

function HelperPersonnelAutoDriveCompatibility.createExternalJob(vehicle, workerId, farmId)
    local job = {
        className = "HelperPersonnelAutoDriveJob",
        helperPersonnelExternalType = "AutoDrive",
        helperPersonnelWorkerId = tonumber(workerId),
        vehicle = vehicle,
        farmId = HelperPersonnelAutoDriveCompatibility.getFarmId(vehicle, farmId)
    }
    job.helperPersonnelExternalStop = function(externalJob)
        local externalVehicle = externalJob ~= nil and externalJob.vehicle or nil
        if HelperPersonnelAutoDriveCompatibility.isActive(externalVehicle)
            and externalVehicle.stopAutoDrive ~= nil then
            externalVehicle.ad.isStoppingWithError = true
            if externalVehicle.ad.stateModule.setLoopsDone ~= nil then
                externalVehicle.ad.stateModule:setLoopsDone(0)
            end
            externalVehicle:stopAutoDrive()
            return true
        end
        return false
    end
    return job
end

function HelperPersonnelAutoDriveCompatibility.createAssignment(vehicle, workerId)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if app == nil or key == nil then
        return nil
    end

    local existing = HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key]
    if existing ~= nil and tonumber(existing.workerId) == tonumber(workerId) then
        return existing
    end

    local job = HelperPersonnelAutoDriveCompatibility.createExternalJob(vehicle, workerId)

    local record = {
        job = job,
        vehicle = vehicle,
        vehicleKey = key,
        workerId = tonumber(workerId),
        farmId = job.farmId
    }
    HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key] = record
    app.helperBridge:onJobStarted(job, workerId)
    HelperPersonnelAutoDriveCompatibility.applyWorkerContext(workerId)

    local handoff = HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey[key]
    if handoff ~= nil then
        handoff.started = true
    end
    HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
    HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey[key] = nil
    return record
end

function HelperPersonnelAutoDriveCompatibility.finishBusyWorker(workerId, vehicle, suppressFinish)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil or workerId == nil then
        return false
    end
    local bridge = app.helperBridge
    local farmId = bridge.getFarmIdForWorkerOrVehicle ~= nil
        and bridge:getFarmIdForWorkerOrVehicle(workerId, vehicle)
        or HelperPersonnelAutoDriveCompatibility.getFarmId(vehicle)
    local changed = false

    if bridge:hpIsServerAuthority() then
        if suppressFinish == true then
            local clearBusy = function()
                if app.manager.setWorkerBusy ~= nil then
                    app.manager:setWorkerBusy(workerId, false, "")
                    return true
                end
                return false
            end
            if app.manager.executeWithFarmContext ~= nil then
                changed = app.manager:executeWithFarmContext(farmId, clearBusy, true) == true
            else
                changed = clearBusy()
            end
        elseif app.manager.finishWorkerJobForFarm ~= nil then
            changed = app.manager:finishWorkerJobForFarm(workerId, farmId) == true
        elseif app.manager.finishWorkerJob ~= nil then
            changed = app.manager:finishWorkerJob(workerId) == true
        end
    end

    HelperPersonnelAutoDriveCompatibility.clearWorkerContext(workerId)
    bridge:hpSyncStateAfterJobChange(changed)
    return changed
end

function HelperPersonnelAutoDriveCompatibility.finishAssignment(record, suppressFinish)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil or record == nil then
        return false
    end
    local bridge = app.helperBridge
    local workerId = record.workerId
    local job = record.job
    local key = record.vehicleKey

    if key ~= nil then
        HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key] = nil
        HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
        HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey[key] = nil
    end
    if suppressFinish == true then
        bridge.suppressFinishForWorkerId = bridge.suppressFinishForWorkerId or {}
        bridge.suppressFinishForWorkerId[workerId] = true
    end
    if bridge.onJobStopped ~= nil then
        bridge:onJobStopped(job)
        HelperPersonnelAutoDriveCompatibility.clearWorkerContext(workerId)
        return true
    end
    return HelperPersonnelAutoDriveCompatibility.finishBusyWorker(workerId, record.vehicle, suppressFinish)
end

function HelperPersonnelAutoDriveCompatibility.ensureAssignmentMapping(record)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil or record == nil then
        return
    end
    local bridge = app.helperBridge
    local assigned = bridge.workerJobById[record.workerId]
    if assigned == nil or assigned == record.job then
        bridge.workerJobById[record.workerId] = record.job
        bridge.jobWorkerIds[record.job] = record.workerId
        bridge.vehicleWorkerIds[record.vehicleKey] = record.workerId
        record.job.helperPersonnelWorkerId = record.workerId
    end
end

function HelperPersonnelAutoDriveCompatibility.beginTransfer(record, kind)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil or record == nil then
        return false
    end
    local bridge = app.helperBridge
    local key = record.vehicleKey
    local workerId = record.workerId

    if bridge.workerJobById[workerId] == record.job then
        bridge.workerJobById[workerId] = nil
    end
    bridge.jobWorkerIds[record.job] = nil
    record.job.helperPersonnelWorkerId = nil
    HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key] = nil
    HelperPersonnelAutoDriveCompatibility.clearWorkerContext(workerId)
    HelperPersonnelAutoDriveCompatibility.reserveWorker(record.vehicle, workerId, kind)
    HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey[key] = {
        record = record,
        kind = kind,
        elapsedMs = 0
    }

    return true
end

function HelperPersonnelAutoDriveCompatibility.captureCourseplayHandoff(vehicle)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if app == nil or key == nil then
        return
    end
    local workerId = app.helperBridge:getWorkerIdByVehicle(vehicle)
    local sourceJob = workerId ~= nil and app.helperBridge.workerJobById[workerId] or nil
    if workerId == nil or not HelperPersonnelAutoDriveCompatibility.isCourseplayJob(sourceJob) then
        return
    end
    HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey[key] = {
        workerId = tonumber(workerId),
        vehicle = vehicle,
        sourceJob = sourceJob,
        elapsedMs = 0,
        started = false,
        sourceStopped = false
    }
    HelperPersonnelAutoDriveCompatibility.reserveWorker(vehicle, workerId, "Courseplay")
end

function HelperPersonnelAutoDriveCompatibility.handleCourseplaySourceStopped(bridge, job, workerId, key, handoff)
    bridge.jobWorkerIds[job] = nil
    if bridge.workerJobById[workerId] == job then
        bridge.workerJobById[workerId] = nil
    end
    job.helperPersonnelWorkerId = nil
    job.hpHelperPersonnelStopHandled = true
    bridge.vehicleWorkerIds[key] = workerId
    handoff.sourceStopped = true
    if handoff.started == true then
        HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey[key] = nil
    end
end

function HelperPersonnelAutoDriveCompatibility.beforeBridgeJobStopped(bridge, job, workerId)
    local key = bridge:getVehicleKeyFromJob(job)
    local handoff = key ~= nil and HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey[key] or nil
    if handoff ~= nil and tonumber(handoff.workerId) == tonumber(workerId) and handoff.sourceJob == job then
        HelperPersonnelAutoDriveCompatibility.handleCourseplaySourceStopped(bridge, job, workerId, key, handoff)
        return true
    end
    return false
end

function HelperPersonnelAutoDriveCompatibility.afterBridgeJobStopped(bridge, stoppedJob, workerId, assignedJob, vehicleKey)
    if workerId ~= nil and vehicleKey ~= nil and assignedJob ~= nil
        and assignedJob ~= stoppedJob and assignedJob.helperPersonnelExternalType == "AutoDrive" then
        bridge.vehicleWorkerIds[vehicleKey] = workerId
    end
end

function HelperPersonnelAutoDriveCompatibility.isPersonnelAssignmentVehicle(vehicle)
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    local record = key ~= nil and HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key] or nil
    return record ~= nil and record.vehicle == vehicle and HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
end

function HelperPersonnelAutoDriveCompatibility.onUpdateTick(vehicle, superFunc, ...)
    local previousVehicle = HelperPersonnelAutoDriveCompatibility.wageContextVehicle
    if HelperPersonnelAutoDriveCompatibility.isPersonnelAssignmentVehicle(vehicle) then
        HelperPersonnelAutoDriveCompatibility.wageContextVehicle = vehicle
    else
        HelperPersonnelAutoDriveCompatibility.wageContextVehicle = nil
    end
    local ok, result = pcall(superFunc, vehicle, ...)
    HelperPersonnelAutoDriveCompatibility.wageContextVehicle = previousVehicle
    if not ok then
        error(result)
    end
    return result
end

function HelperPersonnelAutoDriveCompatibility.addActiveAssignmentsToLookup(app, lookup)
    if lookup == nil then
        return
    end

    lookup.jobSet = lookup.jobSet or {}
    lookup.workerIds = lookup.workerIds or {}
    lookup.vehicleKeys = lookup.vehicleKeys or {}
    lookup.vehicleNames = lookup.vehicleNames or {}

    for key, record in pairs(HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey) do
        if record ~= nil and HelperPersonnelAutoDriveCompatibility.isActive(record.vehicle) then
            if lookup.jobSet[record.job] ~= true then
                lookup.jobSet[record.job] = true
                lookup.count = (lookup.count or 0) + 1
            end
            lookup.workerIds[record.workerId] = true
            lookup.vehicleKeys[key] = true
            if app.getVehicleName ~= nil then
                local vehicleName = app:getVehicleName(record.vehicle)
                if vehicleName ~= nil and tostring(vehicleName) ~= "" then
                    lookup.vehicleNames[tostring(vehicleName)] = true
                end
            end
        end
    end
end

function HelperPersonnelAutoDriveCompatibility.onStartAutoDrive(vehicle, superFunc, ...)
    if not HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle)
        or HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
        return superFunc(vehicle, ...)
    end

    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local workerId, reservation = HelperPersonnelAutoDriveCompatibility.resolveWorkerForStart(vehicle)
    local automaticallyAssigned = false
    if app == nil then
        return superFunc(vehicle, ...)
    end

    if workerId == nil and app.isServerAuthority ~= nil and app:isServerAuthority() == true then
        local farmId = app.getStrictFarmIdForVehicle ~= nil and app:getStrictFarmIdForVehicle(vehicle) or nil
        if tonumber(farmId) == nil or tonumber(farmId) <= 0 then
            return nil
        end
        local worker, reason, hasTransportDrivers = HelperPersonnelAutoDriveCompatibility.getAutomaticTransportDriver(vehicle, farmId)
        if worker == nil then
            local messageKey = (reason == "busy" or hasTransportDrivers == true)
                and "ui_transportNoDriverAvailable" or "ui_transportNoDriverAssigned"
            HelperPersonnelAutoDriveCompatibility.logInfo(
                "FS25_HelperPersonnel: AutoDrive start blocked for '%s': %s.",
                HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle),
                messageKey == "ui_transportNoDriverAvailable" and "all assigned transport employees are unavailable" or "no transport employee is assigned")
            HelperPersonnelAutoDriveCompatibility.notifyRequester(app, nil, messageKey)
            return nil
        end
        workerId = tonumber(worker.id)
        automaticallyAssigned = true
        if not HelperPersonnelAutoDriveCompatibility.reserveWorker(vehicle, workerId, "transport") then
            HelperPersonnelAutoDriveCompatibility.notifyRequester(app, nil, "ui_transportNoDriverAvailable")
            return nil
        end
        local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
        reservation = key ~= nil and HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] or nil
    elseif workerId == nil then
        return superFunc(vehicle, ...)
    end

    local allowBusy = reservation ~= nil or app.helperBridge:getWorkerIdByVehicle(vehicle) == workerId
    if not HelperPersonnelAutoDriveCompatibility.canUseWorker(vehicle, workerId, allowBusy) then
        if reservation ~= nil then
            local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
            if key ~= nil then
                HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
            end
            return nil
        end
        return superFunc(vehicle, ...)
    end

    local assignedJob = app.helperBridge.workerJobById[workerId]
    if HelperPersonnelAutoDriveCompatibility.isCourseplayJob(assignedJob) then
        HelperPersonnelAutoDriveCompatibility.captureCourseplayHandoff(vehicle)
    end

    local worker = app.manager:getWorkerById(workerId)
    local wasBusy = worker ~= nil and (worker.busy == true or worker.restorePending == true)
    local previousHelper = vehicle.ad.currentHelper
    local previousIndex = vehicle.ad.stateModule:getCurrentHelperIndex()
    local helper = app.helperBridge:ensureHelperProfile(worker)
    if helper == nil then
        if reservation ~= nil then
            local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
            if key ~= nil then
                HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
            end
        end
        if automaticallyAssigned then
            HelperPersonnelAutoDriveCompatibility.notifyRequester(app, nil, "ui_transportNoDriverAvailable")
        end
        return nil
    end

    vehicle.ad.currentHelper = helper
    vehicle.ad.stateModule:setCurrentHelperIndex(helper.index)
    local result = superFunc(vehicle, ...)

    if HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
        HelperPersonnelAutoDriveCompatibility.createAssignment(vehicle, workerId)
        if automaticallyAssigned then
            HelperPersonnelAutoDriveCompatibility.logInfo(
                "FS25_HelperPersonnel: Assigned transport employee '%s' (ID %s) to AutoDrive vehicle '%s'.",
                HelperPersonnelAutoDriveCompatibility.getWorkerName(worker),
                tostring(workerId),
                HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle))
            HelperPersonnelAutoDriveCompatibility.notifyRequester(app, nil, "ui_transportAutoAssigned")
        end
    else
        local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
        if key ~= nil then
            HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
        end
        vehicle.ad.currentHelper = previousHelper
        vehicle.ad.stateModule:setCurrentHelperIndex(previousIndex or 0)
        if not wasBusy and previousHelper ~= helper
            and g_helperManager ~= nil and g_helperManager.releaseHelper ~= nil then
            g_helperManager:releaseHelper(helper)
        end
    end
    return result
end

function HelperPersonnelAutoDriveCompatibility.isPassingToCourseplay(vehicle)
    local stateModuleClass = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("ADStateModule")
    if not HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
        or stateModuleClass == nil or vehicle.ad.isStoppingWithError == true then
        return false
    end
    local state = vehicle.ad.stateModule
    return state.getStartHelper ~= nil and state:getStartHelper() == true
        and state.getUsedHelper ~= nil and state:getUsedHelper() == stateModuleClass.HELPER_CP
end

function HelperPersonnelAutoDriveCompatibility.onStopAutoDrive(vehicle, superFunc, ...)
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    local record = key ~= nil and HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key] or nil
    local wasActive = HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
    local isPassingToCourseplay = record ~= nil and HelperPersonnelAutoDriveCompatibility.isPassingToCourseplay(vehicle)
    local isContinuation = record ~= nil and key ~= nil
        and HelperPersonnelAutoDriveCompatibility.continuingInputsByVehicleKey[key] == true

    if isPassingToCourseplay then
        HelperPersonnelAutoDriveCompatibility.beginTransfer(record, "Courseplay")
    elseif isContinuation then
        HelperPersonnelAutoDriveCompatibility.beginTransfer(record, "AutoDrive")
    end

    local result = superFunc(vehicle, ...)
    if wasActive and record ~= nil and not isPassingToCourseplay and not isContinuation then
        local app = HelperPersonnelAutoDriveCompatibility.getApp()
        local suppress = app ~= nil and app.helperBridge.suppressFinishForWorkerId ~= nil
            and app.helperBridge.suppressFinishForWorkerId[record.workerId] == true
        HelperPersonnelAutoDriveCompatibility.finishAssignment(record, suppress)
    end
    return result
end

function HelperPersonnelAutoDriveCompatibility.installVehicleHooks(vehicle)
    if not HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle)
        or Utils == nil or Utils.overwrittenFunction == nil then
        return false
    end

    local hooks = HelperPersonnelAutoDriveCompatibility.vehicleHooks[vehicle]
    if hooks == nil then
        hooks = {}
        HelperPersonnelAutoDriveCompatibility.vehicleHooks[vehicle] = hooks
    end

    local autoDrive = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("AutoDrive")
    local installed = false
    if hooks.start ~= true and type(vehicle.startAutoDrive) == "function" then
        if autoDrive ~= nil and HelperPersonnelAutoDriveCompatibility.startHookInstalled == true
            and vehicle.startAutoDrive == autoDrive.startAutoDrive then
            hooks.start = true
        else
            vehicle.startAutoDrive = Utils.overwrittenFunction(vehicle.startAutoDrive, HelperPersonnelAutoDriveCompatibility.onStartAutoDrive)
            hooks.start = true
            installed = true
        end
    end

    if hooks.stop ~= true and type(vehicle.stopAutoDrive) == "function" then
        if autoDrive ~= nil and HelperPersonnelAutoDriveCompatibility.stopHookInstalled == true
            and vehicle.stopAutoDrive == autoDrive.stopAutoDrive then
            hooks.stop = true
        else
            vehicle.stopAutoDrive = Utils.overwrittenFunction(vehicle.stopAutoDrive, HelperPersonnelAutoDriveCompatibility.onStopAutoDrive)
            hooks.stop = true
            installed = true
        end
    end

    if installed and HelperPersonnelAutoDriveCompatibility.vehicleHookFallbackLogged ~= true then
        HelperPersonnelAutoDriveCompatibility.vehicleHookFallbackLogged = true
        HelperPersonnelAutoDriveCompatibility.logInfo("FS25_HelperPersonnel: AutoDrive registered vehicle functions required instance-level compatibility hooks.")
    end
    return hooks.start == true and hooks.stop == true
end

function HelperPersonnelAutoDriveCompatibility.getInputFarmId(vehicle, farmId)
    local autoDrive = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("AutoDrive")
    farmId = tonumber(farmId) or 0
    if farmId <= 0 and autoDrive ~= nil and autoDrive.getAIFrameFarmId ~= nil then
        farmId = tonumber(autoDrive:getAIFrameFarmId()) or 0
    end
    return HelperPersonnelAutoDriveCompatibility.getFarmId(vehicle, farmId)
end

function HelperPersonnelAutoDriveCompatibility.notifyRequester(app, connection, textKey)
    if app == nil then
        return
    end

    if connection ~= nil and type(connection.sendEvent) == "function"
        and HelperPersonnelNotificationEvent ~= nil then
        local text = app.resolveText ~= nil and app:resolveText(textKey) or textKey
        if text ~= nil and text ~= "" then
            connection:sendEvent(HelperPersonnelNotificationEvent.new(text, app:getDefaultNotificationType()))
            return
        end
    end

    if app.showPlayerMessage ~= nil then
        app:showPlayerMessage(textKey)
    end
end

function HelperPersonnelAutoDriveCompatibility.getAutomaticTransportDriver(vehicle, farmId)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil or app.manager.getAvailableTransportDriverForFarm == nil then
        return nil, "none", false
    end

    local job = HelperPersonnelAutoDriveCompatibility.createExternalJob(vehicle, nil, farmId)
    local worker, reason, hasTransportDrivers = app.manager:getAvailableTransportDriverForFarm(farmId, job)
    if worker == nil then
        return nil, reason, hasTransportDrivers
    end

    local workerFarmId = app.manager.getWorkerFarmId ~= nil and app.manager:getWorkerFarmId(worker.id) or nil
    if worker.transportDriver ~= true
        or tonumber(workerFarmId) ~= tonumber(farmId)
        or not HelperPersonnelAutoDriveCompatibility.canUseWorker(vehicle, worker.id, false) then
        return nil, "busy", hasTransportDrivers == true
    end

    return worker, nil, true
end

function HelperPersonnelAutoDriveCompatibility.logReconciliationState(key, state, message, ...)
    if key == nil or HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey[key] == state then
        return
    end
    HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey[key] = state
    HelperPersonnelAutoDriveCompatibility.logInfo(message, ...)
end

function HelperPersonnelAutoDriveCompatibility.stopUnmanagedVehicle(vehicle, messageKey, reason)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if HelperPersonnelAutoDriveCompatibility.isActive(vehicle) and type(vehicle.stopAutoDrive) == "function" then
        vehicle.ad.isStoppingWithError = true
        if vehicle.ad.stateModule.setLoopsDone ~= nil then
            vehicle.ad.stateModule:setLoopsDone(0)
        end
        vehicle:stopAutoDrive()
    end
    HelperPersonnelAutoDriveCompatibility.logReconciliationState(
        key,
        "blocked:" .. tostring(messageKey),
        "FS25_HelperPersonnel: Blocked unmanaged AutoDrive vehicle '%s': %s.",
        HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle),
        tostring(reason))
    HelperPersonnelAutoDriveCompatibility.notifyRequester(app, nil, messageKey)
end

function HelperPersonnelAutoDriveCompatibility.assignWorkerToActiveVehicle(vehicle, worker, source, isTransportAssignment)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if app == nil or key == nil or worker == nil or not HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
        return false
    end

    local workerId = tonumber(worker.id)
    local wasBusy = worker.busy == true or worker.restorePending == true
    local previousHelper = vehicle.ad.currentHelper
    local previousIndex = vehicle.ad.stateModule:getCurrentHelperIndex()
    local helper = app.helperBridge:ensureHelperProfile(worker)
    if helper == nil then
        return false
    end

    vehicle.ad.currentHelper = helper
    vehicle.ad.stateModule:setCurrentHelperIndex(helper.index)
    local record = HelperPersonnelAutoDriveCompatibility.createAssignment(vehicle, workerId)
    if record == nil then
        vehicle.ad.currentHelper = previousHelper
        vehicle.ad.stateModule:setCurrentHelperIndex(previousIndex or 0)
        if not wasBusy and previousHelper ~= helper
            and g_helperManager ~= nil and g_helperManager.releaseHelper ~= nil then
            g_helperManager:releaseHelper(helper)
        end
        return false
    end

    if previousHelper ~= nil and previousHelper ~= helper
        and g_helperManager ~= nil and g_helperManager.releaseHelper ~= nil then
        g_helperManager:releaseHelper(previousHelper)
    end
    HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey[key] = "assigned"
    HelperPersonnelAutoDriveCompatibility.logInfo(
        "FS25_HelperPersonnel: Recovered AutoDrive vehicle '%s' at '%s' with %s '%s' (ID %s).",
        HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle),
        tostring(source),
        isTransportAssignment == true and "transport employee" or "employee",
        HelperPersonnelAutoDriveCompatibility.getWorkerName(worker),
        tostring(workerId))
    if isTransportAssignment == true then
        HelperPersonnelAutoDriveCompatibility.notifyRequester(app, nil, "ui_transportAutoAssigned")
    end
    return true
end

function HelperPersonnelAutoDriveCompatibility.reconcileActiveVehicle(vehicle, source)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    if app == nil or key == nil or not HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
        return "inactive"
    end

    local record = HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key]
    if record ~= nil then
        HelperPersonnelAutoDriveCompatibility.ensureAssignmentMapping(record)
        HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey[key] = "managed"
        return "managed"
    end

    if app.isServerAuthority == nil or app:isServerAuthority() ~= true then
        return "deferred"
    end

    local workerId = HelperPersonnelAutoDriveCompatibility.getWorkerIdForVehicle(vehicle)
    local worker = workerId ~= nil and app.manager:getWorkerById(workerId) or nil
    if worker ~= nil and HelperPersonnelAutoDriveCompatibility.canUseWorker(vehicle, workerId, true) then
        if HelperPersonnelAutoDriveCompatibility.assignWorkerToActiveVehicle(vehicle, worker, source, false) then
            return "assigned"
        end
    end

    local farmId = app.getStrictFarmIdForVehicle ~= nil and app:getStrictFarmIdForVehicle(vehicle) or nil
    if tonumber(farmId) == nil or tonumber(farmId) <= 0 then
        HelperPersonnelAutoDriveCompatibility.logReconciliationState(
            key,
            "invalidFarm",
            "FS25_HelperPersonnel: Could not reconcile AutoDrive vehicle '%s': no authoritative farm could be resolved.",
            HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle))
        return "deferred"
    end

    local reason
    local hasTransportDrivers
    worker, reason, hasTransportDrivers = HelperPersonnelAutoDriveCompatibility.getAutomaticTransportDriver(vehicle, farmId)
    if worker == nil then
        local messageKey = (reason == "busy" or hasTransportDrivers == true)
            and "ui_transportNoDriverAvailable" or "ui_transportNoDriverAssigned"
        local reasonText = messageKey == "ui_transportNoDriverAvailable"
            and "all assigned transport employees are unavailable" or "no transport employee is assigned"
        HelperPersonnelAutoDriveCompatibility.stopUnmanagedVehicle(vehicle, messageKey, reasonText)
        return "blocked"
    end

    if HelperPersonnelAutoDriveCompatibility.assignWorkerToActiveVehicle(vehicle, worker, source, true) then
        return "assigned"
    end

    HelperPersonnelAutoDriveCompatibility.stopUnmanagedVehicle(
        vehicle,
        "ui_transportNoDriverAvailable",
        "the selected transport employee profile could not be activated")
    return "blocked"
end

function HelperPersonnelAutoDriveCompatibility.onStartEventSend(eventClass, superFunc, vehicle)
    if g_server ~= nil and HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
        local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
        local reservation = key ~= nil and HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] or nil
        local helper = vehicle.ad.currentHelper
        local isPersonnelStart = reservation ~= nil
            or (helper ~= nil and helper.helperPersonnelWorkerId ~= nil)
        if not isPersonnelStart then
            local result = HelperPersonnelAutoDriveCompatibility.reconcileActiveVehicle(vehicle, "startEvent")
            if result == "blocked" or not HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
                return nil
            end
        end
    end
    return superFunc(eventClass, vehicle)
end

function HelperPersonnelAutoDriveCompatibility.onInputCall(manager, superFunc, vehicle, input, farmId, sendEvent)
    if HelperPersonnelAutoDriveCompatibility.replayingInput == true
        or not HelperPersonnelAutoDriveCompatibility.START_INPUTS[input]
        or not HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle) then
        return superFunc(manager, vehicle, input, farmId, sendEvent)
    end

    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    local active = HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
    if active and HelperPersonnelAutoDriveCompatibility.CONTINUATION_INPUTS[input]
        and key ~= nil and HelperPersonnelAutoDriveCompatibility.getWorkerIdForVehicle(vehicle) ~= nil
        and g_server ~= nil and sendEvent == false then
        HelperPersonnelAutoDriveCompatibility.continuingInputsByVehicleKey[key] = true
        local ok, result1, result2, result3 = pcall(superFunc, manager, vehicle, input, farmId, sendEvent)
        HelperPersonnelAutoDriveCompatibility.continuingInputsByVehicleKey[key] = nil
        if not ok then
            error(result1)
        end
        return result1, result2, result3
    end

    if active then
        return superFunc(manager, vehicle, input, farmId, sendEvent)
    end

    if g_server ~= nil and sendEvent == false then
        return nil
    end

    local actualFarmId = HelperPersonnelAutoDriveCompatibility.getInputFarmId(vehicle, farmId)
    HelperPersonnelAutoDriveInputEvent.sendEvent(vehicle, actualFarmId, input)
    return nil
end

function HelperPersonnelAutoDriveCompatibility.onInputEventSend(vehicle, superFunc, inputId, farmId)
    local inputManager = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("ADInputManager")
    local input = inputManager ~= nil and inputManager.idsToInputs ~= nil
        and inputManager.idsToInputs[inputId] or nil
    if HelperPersonnelAutoDriveCompatibility.replayingInput == true
        or not HelperPersonnelAutoDriveCompatibility.START_INPUTS[input]
        or not HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle)
        or HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
        return superFunc(vehicle, inputId, farmId)
    end

    local actualFarmId = HelperPersonnelAutoDriveCompatibility.getInputFarmId(vehicle, farmId)
    HelperPersonnelAutoDriveInputEvent.sendEvent(vehicle, actualFarmId, input)
    return nil
end

function HelperPersonnelAutoDriveCompatibility.processStartRequest(vehicle, farmId, input, connection)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    local inputManager = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("ADInputManager")
    if app == nil or not HelperPersonnelAutoDriveCompatibility.START_INPUTS[input]
        or not HelperPersonnelAutoDriveCompatibility.isSupportedVehicle(vehicle)
        or HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
        or inputManager == nil or type(inputManager.onInputCall) ~= "function"
        or app.isServerAuthority == nil or app:isServerAuthority() ~= true then
        return false
    end

    local vehicleFarmId = app.getStrictFarmIdForVehicle ~= nil and app:getStrictFarmIdForVehicle(vehicle) or nil
    if tonumber(vehicleFarmId) == nil or tonumber(vehicleFarmId) <= 0 or app.resolveAuthorizedFarmId == nil then
        return false
    end
    local allowed, authorizedFarmId = app:resolveAuthorizedFarmId(connection, farmId, vehicleFarmId, HelperPersonnelNetwork.ACTION_SELECT_WORKER)
    if not allowed or tonumber(authorizedFarmId) ~= tonumber(vehicleFarmId) then
        return false
    end

    HelperPersonnelAutoDriveCompatibility.logInfo(
        "FS25_HelperPersonnel: Received AutoDrive start request for '%s' on farm %s.",
        HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle),
        tostring(authorizedFarmId))

    local worker, reason, hasTransportDrivers = HelperPersonnelAutoDriveCompatibility.getAutomaticTransportDriver(vehicle, authorizedFarmId)
    if worker == nil then
        local messageKey = (reason == "busy" or hasTransportDrivers == true)
            and "ui_transportNoDriverAvailable" or "ui_transportNoDriverAssigned"
        HelperPersonnelAutoDriveCompatibility.logInfo(
            "FS25_HelperPersonnel: AutoDrive start blocked for '%s': %s.",
            HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle),
            messageKey == "ui_transportNoDriverAvailable" and "all assigned transport employees are unavailable" or "no transport employee is assigned")
        HelperPersonnelAutoDriveCompatibility.notifyRequester(app, connection, messageKey)
        return false
    end

    local workerId = tonumber(worker.id)
    local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
    local previousHelper = vehicle.ad.currentHelper
    local previousIndex = vehicle.ad.stateModule:getCurrentHelperIndex()
    local wasBusy = worker.busy == true or worker.restorePending == true
    local helper = app.helperBridge:ensureHelperProfile(worker)
    if helper == nil or key == nil then
        HelperPersonnelAutoDriveCompatibility.notifyRequester(app, connection, "ui_transportNoDriverAvailable")
        return false
    end

    HelperPersonnelAutoDriveCompatibility.reserveWorker(vehicle, workerId, "transport")
    vehicle.ad.currentHelper = helper
    vehicle.ad.stateModule:setCurrentHelperIndex(helper.index)
    HelperPersonnelAutoDriveCompatibility.replayingInput = true
    local ok, errorText = pcall(inputManager.onInputCall, inputManager, vehicle, input, authorizedFarmId, false)
    HelperPersonnelAutoDriveCompatibility.replayingInput = false
    if not ok and Logging ~= nil and Logging.warning ~= nil then
        Logging.warning("FS25_HelperPersonnel: AutoDrive start failed: %s", tostring(errorText))
    end

    local started = HelperPersonnelAutoDriveCompatibility.isActive(vehicle)
    if started then
        if HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey[key] == nil then
            HelperPersonnelAutoDriveCompatibility.createAssignment(vehicle, workerId)
        end
        HelperPersonnelAutoDriveCompatibility.logInfo(
            "FS25_HelperPersonnel: Assigned transport employee '%s' (ID %s) to AutoDrive vehicle '%s'.",
            HelperPersonnelAutoDriveCompatibility.getWorkerName(worker),
            tostring(workerId),
            HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle))
        HelperPersonnelAutoDriveCompatibility.notifyRequester(app, connection, "ui_transportAutoAssigned")
    else
        HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
        vehicle.ad.currentHelper = previousHelper
        vehicle.ad.stateModule:setCurrentHelperIndex(previousIndex or 0)
        if not wasBusy and previousHelper ~= helper
            and g_helperManager ~= nil and g_helperManager.releaseHelper ~= nil then
            g_helperManager:releaseHelper(helper)
        end
        HelperPersonnelAutoDriveCompatibility.logInfo(
            "FS25_HelperPersonnel: AutoDrive start request for '%s' did not activate the vehicle.",
            HelperPersonnelAutoDriveCompatibility.getVehicleName(vehicle))
    end
    return ok and started
end

function HelperPersonnelAutoDriveCompatibility.captureFromVehicleEvent(vehicle, superFunc, ...)
    HelperPersonnelAutoDriveCompatibility.captureCourseplayHandoff(vehicle)
    return superFunc(vehicle, ...)
end

function HelperPersonnelAutoDriveCompatibility.resetState()
    HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey = {}
    HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey = {}
    HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey = {}
    HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey = {}
    HelperPersonnelAutoDriveCompatibility.continuingInputsByVehicleKey = {}
    HelperPersonnelAutoDriveCompatibility.vehicleHooks = setmetatable({}, {__mode = "k"})
    HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey = {}
    HelperPersonnelAutoDriveCompatibility.replayingInput = false
    HelperPersonnelAutoDriveCompatibility.restoreScanElapsedMs = 0
    HelperPersonnelAutoDriveCompatibility.wageContextVehicle = nil
    HelperPersonnelAutoDriveCompatibility.compatibilityHookStatus = nil
end

function HelperPersonnelAutoDriveCompatibility.captureFromHandleCP(owner, superFunc, vehicle, ...)
    HelperPersonnelAutoDriveCompatibility.captureCourseplayHandoff(vehicle)
    return superFunc(owner, vehicle, ...)
end

function HelperPersonnelAutoDriveCompatibility.update(dt)
    local app = HelperPersonnelAutoDriveCompatibility.getApp()
    if app == nil then
        return
    end
    dt = tonumber(dt) or 0

    for _, record in pairs(HelperPersonnelAutoDriveCompatibility.assignmentsByVehicleKey) do
        if record ~= nil and not HelperPersonnelAutoDriveCompatibility.isActive(record.vehicle) then
            HelperPersonnelAutoDriveCompatibility.finishAssignment(record, false)
        else
            HelperPersonnelAutoDriveCompatibility.ensureAssignmentMapping(record)
        end
    end

    if app:isServerAuthority() then
        for key, transfer in pairs(HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey) do
            transfer.elapsedMs = (transfer.elapsedMs or 0) + dt
            local record = transfer.record
            local assigned = record ~= nil and app.helperBridge.workerJobById[record.workerId] or nil
            if assigned ~= nil and assigned ~= record.job then
                HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey[key] = nil
                HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
            elseif transfer.elapsedMs >= HelperPersonnelAutoDriveCompatibility.HANDOFF_TIMEOUT_MS then
                HelperPersonnelAutoDriveCompatibility.finishAssignment(record, false)
                HelperPersonnelAutoDriveCompatibility.transfersByVehicleKey[key] = nil
            end
        end

        for key, handoff in pairs(HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey) do
            handoff.elapsedMs = (handoff.elapsedMs or 0) + dt
            local assigned = app.helperBridge.workerJobById[handoff.workerId]
            if handoff.started == true and handoff.sourceStopped == true then
                HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey[key] = nil
            elseif handoff.elapsedMs >= HelperPersonnelAutoDriveCompatibility.HANDOFF_TIMEOUT_MS then
                if handoff.sourceStopped == true and assigned == nil then
                    if app.helperBridge.vehicleWorkerIds[key] == handoff.workerId then
                        app.helperBridge.vehicleWorkerIds[key] = nil
                    end
                    HelperPersonnelAutoDriveCompatibility.finishBusyWorker(handoff.workerId, handoff.vehicle, false)
                end
                HelperPersonnelAutoDriveCompatibility.reservationsByVehicleKey[key] = nil
                HelperPersonnelAutoDriveCompatibility.courseplayHandoffsByVehicleKey[key] = nil
            end
        end
    end

    HelperPersonnelAutoDriveCompatibility.restoreScanElapsedMs = (HelperPersonnelAutoDriveCompatibility.restoreScanElapsedMs or 0) + dt
    if HelperPersonnelAutoDriveCompatibility.restoreScanElapsedMs >= 1000 then
        HelperPersonnelAutoDriveCompatibility.restoreScanElapsedMs = 0
        local autoDriveDetected = HelperPersonnelAutoDriveCompatibility.getAutoDriveEnvironment() ~= nil
        if autoDriveDetected and (HelperPersonnelAutoDriveCompatibility.inputHookInstalled ~= true
            or HelperPersonnelAutoDriveCompatibility.inputEventHookInstalled ~= true
            or HelperPersonnelAutoDriveCompatibility.startHookInstalled ~= true
            or HelperPersonnelAutoDriveCompatibility.startEventHookInstalled ~= true
            or HelperPersonnelAutoDriveCompatibility.stopHookInstalled ~= true) then
            HelperPersonnelAutoDriveCompatibility.install("runtime")
        end
        for _, vehicle in ipairs(g_currentMission ~= nil and g_currentMission.vehicles or {}) do
            HelperPersonnelAutoDriveCompatibility.installVehicleHooks(vehicle)
            if HelperPersonnelAutoDriveCompatibility.isActive(vehicle) then
                HelperPersonnelAutoDriveCompatibility.reconcileActiveVehicle(vehicle, "runtimeScan")
            else
                local key = HelperPersonnelAutoDriveCompatibility.getVehicleKey(vehicle)
                if key ~= nil then
                    HelperPersonnelAutoDriveCompatibility.reconciliationLogStateByVehicleKey[key] = nil
                end
            end
        end
    end
end

function HelperPersonnelAutoDriveCompatibility.install(stage)
    if Utils == nil or Utils.overwrittenFunction == nil then
        return
    end

    local inputManager = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("ADInputManager")
    local inputEvent = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("AutoDriveInputEventEvent")
    local startStopEvent = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("AutoDriveStartStopEvent")
    local autoDrive = HelperPersonnelAutoDriveCompatibility.getAutoDriveClass("AutoDrive")

    if inputManager ~= nil and inputManager.onInputCall ~= nil
        and HelperPersonnelAutoDriveCompatibility.inputHookInstalled ~= true then
        inputManager.onInputCall = Utils.overwrittenFunction(inputManager.onInputCall, HelperPersonnelAutoDriveCompatibility.onInputCall)
        HelperPersonnelAutoDriveCompatibility.inputHookInstalled = true
    end

    if inputEvent ~= nil and inputEvent.sendEvent ~= nil
        and HelperPersonnelAutoDriveCompatibility.inputEventHookInstalled ~= true then
        inputEvent.sendEvent = Utils.overwrittenFunction(inputEvent.sendEvent, HelperPersonnelAutoDriveCompatibility.onInputEventSend)
        HelperPersonnelAutoDriveCompatibility.inputEventHookInstalled = true
    end

    if startStopEvent ~= nil and startStopEvent.sendStartEvent ~= nil
        and HelperPersonnelAutoDriveCompatibility.startEventHookInstalled ~= true then
        startStopEvent.sendStartEvent = Utils.overwrittenFunction(
            startStopEvent.sendStartEvent,
            HelperPersonnelAutoDriveCompatibility.onStartEventSend)
        HelperPersonnelAutoDriveCompatibility.startEventHookInstalled = true
    end

    if autoDrive ~= nil then
        if autoDrive.startAutoDrive ~= nil and HelperPersonnelAutoDriveCompatibility.startHookInstalled ~= true then
            autoDrive.startAutoDrive = Utils.overwrittenFunction(autoDrive.startAutoDrive, HelperPersonnelAutoDriveCompatibility.onStartAutoDrive)
            HelperPersonnelAutoDriveCompatibility.startHookInstalled = true
        end
        if autoDrive.stopAutoDrive ~= nil and HelperPersonnelAutoDriveCompatibility.stopHookInstalled ~= true then
            autoDrive.stopAutoDrive = Utils.overwrittenFunction(autoDrive.stopAutoDrive, HelperPersonnelAutoDriveCompatibility.onStopAutoDrive)
            HelperPersonnelAutoDriveCompatibility.stopHookInstalled = true
        end
        if autoDrive.onUpdateTick ~= nil and HelperPersonnelAutoDriveCompatibility.updateTickHookInstalled ~= true then
            autoDrive.onUpdateTick = Utils.overwrittenFunction(autoDrive.onUpdateTick, HelperPersonnelAutoDriveCompatibility.onUpdateTick)
            HelperPersonnelAutoDriveCompatibility.updateTickHookInstalled = true
        end
        if autoDrive.getSetting ~= nil and HelperPersonnelAutoDriveCompatibility.getSettingHookInstalled ~= true then
            local originalGetSetting = autoDrive.getSetting
            autoDrive.getSetting = function(settingName, vehicle)
                if settingName == "driverWages"
                    and HelperPersonnelAutoDriveCompatibility.wageContextVehicle ~= nil then
                    return 0
                end
                return originalGetSetting(settingName, vehicle)
            end
            HelperPersonnelAutoDriveCompatibility.getSettingHookInstalled = true
        end

        if autoDrive.handleCPFieldWorker ~= nil and HelperPersonnelAutoDriveCompatibility.handleCPHookInstalled ~= true then
            autoDrive.handleCPFieldWorker = Utils.overwrittenFunction(autoDrive.handleCPFieldWorker, HelperPersonnelAutoDriveCompatibility.captureFromHandleCP)
            HelperPersonnelAutoDriveCompatibility.handleCPHookInstalled = true
        end
        for _, functionName in ipairs({"onCpFinished", "onCpFuelEmpty", "onCpBroken"}) do
            local flagName = functionName .. "HelperPersonnelHookInstalled"
            if autoDrive[functionName] ~= nil and HelperPersonnelAutoDriveCompatibility[flagName] ~= true then
                autoDrive[functionName] = Utils.overwrittenFunction(autoDrive[functionName], HelperPersonnelAutoDriveCompatibility.captureFromVehicleEvent)
                HelperPersonnelAutoDriveCompatibility[flagName] = true
            end
        end
    end

    for _, vehicle in ipairs(g_currentMission ~= nil and g_currentMission.vehicles or {}) do
        HelperPersonnelAutoDriveCompatibility.installVehicleHooks(vehicle)
    end

    local hookStatus = string.format(
        "input=%s,inputEvent=%s,start=%s,startEvent=%s,stop=%s,update=%s,wages=%s",
        tostring(HelperPersonnelAutoDriveCompatibility.inputHookInstalled == true),
        tostring(HelperPersonnelAutoDriveCompatibility.inputEventHookInstalled == true),
        tostring(HelperPersonnelAutoDriveCompatibility.startHookInstalled == true),
        tostring(HelperPersonnelAutoDriveCompatibility.startEventHookInstalled == true),
        tostring(HelperPersonnelAutoDriveCompatibility.stopHookInstalled == true),
        tostring(HelperPersonnelAutoDriveCompatibility.updateTickHookInstalled == true),
        tostring(HelperPersonnelAutoDriveCompatibility.getSettingHookInstalled == true))
    local autoDriveDetected = HelperPersonnelAutoDriveCompatibility.getAutoDriveEnvironment() ~= nil
    if autoDriveDetected and HelperPersonnelAutoDriveCompatibility.compatibilityHookStatus ~= hookStatus then
        HelperPersonnelAutoDriveCompatibility.compatibilityHookStatus = hookStatus
        HelperPersonnelAutoDriveCompatibility.logInfo(
            "FS25_HelperPersonnel: AutoDrive compatibility hooks at stage '%s': %s.",
            tostring(stage),
            hookStatus)
    end
end

HelperPersonnelAutoDriveInputEvent = {}
local HelperPersonnelAutoDriveInputEvent_mt = Class(HelperPersonnelAutoDriveInputEvent, Event)
InitEventClass(HelperPersonnelAutoDriveInputEvent, "HelperPersonnelAutoDriveInputEvent")

function HelperPersonnelAutoDriveInputEvent.emptyNew()
    return Event.new(HelperPersonnelAutoDriveInputEvent_mt)
end

function HelperPersonnelAutoDriveInputEvent.new(vehicle, workerId, farmId, input)
    local self = HelperPersonnelAutoDriveInputEvent.emptyNew()
    self.vehicle = vehicle
    self.workerId = tonumber(workerId) or 0
    self.farmId = tonumber(farmId) or 1
    self.inputId = HelperPersonnelAutoDriveCompatibility.INPUT_IDS[input] or 0
    self.input = HelperPersonnelAutoDriveCompatibility.INPUT_NAMES_BY_ID[self.inputId]
    return self
end

function HelperPersonnelAutoDriveInputEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObjectId(streamId, NetworkUtil.getObjectId(self.vehicle))
    streamWriteInt32(streamId, self.workerId)
    HelperPersonnelNetwork.writeFarmId(streamId, self.farmId)
    streamWriteUInt8(streamId, self.inputId or 0)
end

function HelperPersonnelAutoDriveInputEvent:readStream(streamId, connection)
    self.vehicle = NetworkUtil.getObject(NetworkUtil.readNodeObjectId(streamId))
    self.workerId = streamReadInt32(streamId)
    self.farmId = HelperPersonnelNetwork.readFarmId(streamId)
    self.inputId = streamReadUInt8(streamId)
    self.input = HelperPersonnelAutoDriveCompatibility.INPUT_NAMES_BY_ID[self.inputId]
    self:run(connection)
end

function HelperPersonnelAutoDriveInputEvent:run(connection)
    if g_server ~= nil and (connection == nil or connection.getIsServer == nil or connection:getIsServer() ~= true) then
        HelperPersonnelAutoDriveCompatibility.processStartRequest(self.vehicle, self.farmId, self.input, connection)
    end
end

function HelperPersonnelAutoDriveInputEvent.sendEvent(vehicle, farmId, input)
    if g_server ~= nil then
        return HelperPersonnelAutoDriveCompatibility.processStartRequest(vehicle, farmId, input, nil)
    end
    if g_client ~= nil and g_client.getServerConnection ~= nil then
        local connection = g_client:getServerConnection()
        if connection ~= nil then
            connection:sendEvent(HelperPersonnelAutoDriveInputEvent.new(vehicle, 0, farmId, input))
            return true
        end
    end
    return false
end
