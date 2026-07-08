HelperPersonnelCompatibility = HelperPersonnelCompatibility or {}
HelperPersonnelCompatibility.DEBUG_LOGGING = false

local function hpCompatSafeCall(object, methodName, ...)
    if object == nil or methodName == nil or object[methodName] == nil then
        return nil
    end

    local success, result = pcall(object[methodName], object, ...)
    if success then
        return result
    end

    return nil
end

local function hpCompatToLower(value)
    if value == nil then
        return ""
    end

    return string.lower(tostring(value))
end

local function hpCompatContainsAny(value, needles)
    local text = hpCompatToLower(value)
    if text == "" then
        return false
    end

    for _, needle in ipairs(needles) do
        if string.find(text, needle, 1, true) ~= nil then
            return true
        end
    end

    return false
end

local function hpCompatGetClassText(object)
    if object == nil then
        return ""
    end

    local parts = {}
    local function add(value)
        if value ~= nil then
            table.insert(parts, tostring(value))
        end
    end

    if type(object) == "table" then
        add(object.className)
        add(object.typeName)
        add(object.name)
        add(object.typeId)
        local mt = getmetatable(object)
        if type(mt) == "table" then
            add(mt.__name)
            add(mt.className)
            add(mt.typeName)
        end
    end

    add(object)
    return table.concat(parts, " ")
end

local function hpCompatLog(message, ...)
    if HelperPersonnelCompatibility.DEBUG_LOGGING == true and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

function HelperPersonnelCompatibility.isCallFromExternalAutomation()
    if debug == nil or debug.getinfo == nil then
        return false
    end

    for level = 3, 18 do
        local info = debug.getinfo(level, "S")
        if info == nil then
            break
        end

        local source = hpCompatToLower(info.source or info.short_src or "")
        if string.find(source, "autodrive", 1, true) ~= nil
            or string.find(source, "courseplay", 1, true) ~= nil
            or string.find(source, "cpai", 1, true) ~= nil
            or string.find(source, "followme", 1, true) ~= nil
            or string.find(source, "followvehicle", 1, true) ~= nil then
            return true
        end
    end

    return false
end

function HelperPersonnelCompatibility.getRootVehicle(vehicle)
    if vehicle == nil then
        return nil
    end

    local rootVehicle = hpCompatSafeCall(vehicle, "getRootVehicle")
    if rootVehicle ~= nil then
        return rootVehicle
    end

    return vehicle.rootVehicle or vehicle
end

function HelperPersonnelCompatibility.getVehicleFromJob(job)
    if job == nil then
        return nil
    end

    if job.vehicle ~= nil then
        return job.vehicle
    end

    if job.vehicleParameter ~= nil then
        local vehicle = hpCompatSafeCall(job.vehicleParameter, "getVehicle")
        if vehicle ~= nil then
            return vehicle
        end

        if job.vehicleParameter.vehicle ~= nil then
            return job.vehicleParameter.vehicle
        end
    end

    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob ~= nil then
        local success, vehicle = pcall(HelperPersonnelAIJobHooks.getVehicleFromJob, job)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getVehicleFromAIJob ~= nil then
        local success, vehicle = pcall(HelperPersonnelAIStartHooks.getVehicleFromAIJob, job)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    return nil
end

function HelperPersonnelCompatibility.jobIsA(job, class)
    if job == nil or class == nil or job.isa == nil then
        return false
    end

    local success, result = pcall(job.isa, job, class)
    return success and result == true
end

function HelperPersonnelCompatibility.isFollowMeJob(job)
    if job == nil then
        return false
    end

    if AIJobFollowVehicle ~= nil then
        if job == AIJobFollowVehicle or HelperPersonnelCompatibility.jobIsA(job, AIJobFollowVehicle) then
            return true
        end
    end

    if job.followVehicleTask ~= nil or job.followVehicleParameter ~= nil then
        return true
    end

    local text = hpCompatGetClassText(job)
    return hpCompatContainsAny(text, {"aijobfollowvehicle", "followvehicle", "followme"})
end

function HelperPersonnelCompatibility.isCourseplayJob(job)
    if job == nil then
        return false
    end

    if CpAIJob ~= nil then
        if job == CpAIJob or HelperPersonnelCompatibility.jobIsA(job, CpAIJob) then
            return true
        end
    end

    local text = hpCompatGetClassText(job)
    return hpCompatContainsAny(text, {"cpaijob", "courseplay"})
end

function HelperPersonnelCompatibility.isCourseplayVehicleActive(vehicle)
    vehicle = HelperPersonnelCompatibility.getRootVehicle(vehicle)
    if vehicle == nil then
        return false
    end

    local active = hpCompatSafeCall(vehicle, "getIsCpActive")
    if active == true then
        return true
    end

    active = hpCompatSafeCall(vehicle, "getIsCpFieldWorkActive")
    if active == true then
        return true
    end

    active = hpCompatSafeCall(vehicle, "getIsCourseplayActive")
    if active == true then
        return true
    end

    local spec = vehicle.spec_cpAIWorker or vehicle.spec_cpAIFieldWorker or vehicle.spec_cpAIDriveStrategy
    if type(spec) == "table" then
        if spec.driveStrategy ~= nil or spec.activeJob ~= nil or spec.currentJob ~= nil then
            return true
        end

        if spec.isActive == true or spec.active == true then
            return true
        end

        active = hpCompatSafeCall(spec, "getIsActive")
        if active == true then
            return true
        end
    end

    return false
end

local function hpCompatCheckStateModule(stateModule)
    if type(stateModule) ~= "table" then
        return false
    end

    local active = hpCompatSafeCall(stateModule, "isActive")
    if active == true then
        return true
    end

    active = hpCompatSafeCall(stateModule, "getIsActive")
    if active == true then
        return true
    end

    return stateModule.active == true or stateModule.isActive == true
end

function HelperPersonnelCompatibility.isAutoDriveVehicleActive(vehicle)
    vehicle = HelperPersonnelCompatibility.getRootVehicle(vehicle)
    if vehicle == nil then
        return false
    end

    local active = hpCompatSafeCall(vehicle, "getIsAutoDriveActive")
    if active == true then
        return true
    end

    active = hpCompatSafeCall(vehicle, "getIsADActive")
    if active == true then
        return true
    end

    local ad = vehicle.ad or vehicle.spec_autoDrive or vehicle.spec_autodrive
    if type(ad) == "table" then
        if hpCompatCheckStateModule(ad.stateModule) then
            return true
        end

        if ad.active == true or ad.isActive == true then
            return true
        end

        active = hpCompatSafeCall(ad, "getIsActive")
        if active == true then
            return true
        end

        local taskModule = ad.taskModule or ad.tasks
        if type(taskModule) == "table" then
            local hasTasks = hpCompatSafeCall(taskModule, "hasTasks")
            if hasTasks == true then
                return true
            end

            if taskModule.currentTask ~= nil or taskModule.activeTask ~= nil then
                return true
            end
        end
    end

    return false
end

function HelperPersonnelCompatibility.isExternalAutomationJob(job)
    if job == nil then
        return false
    end

    if HelperPersonnelCompatibility.isFollowMeJob(job) or HelperPersonnelCompatibility.isCourseplayJob(job) then
        return true
    end

    local text = hpCompatGetClassText(job)
    if hpCompatContainsAny(text, {"autodrive", "courseplay", "cpaijob", "followvehicle", "followme"}) then
        return true
    end

    local vehicle = HelperPersonnelCompatibility.getVehicleFromJob(job)
    if HelperPersonnelCompatibility.isAutoDriveVehicleActive(vehicle) or HelperPersonnelCompatibility.isCourseplayVehicleActive(vehicle) then
        return true
    end

    return HelperPersonnelCompatibility.isCallFromExternalAutomation()
end

function HelperPersonnelCompatibility.isExternalAutomationVehicleStart(vehicle)
    if vehicle == nil then
        return false
    end

    if HelperPersonnelCompatibility.isAutoDriveVehicleActive(vehicle) or HelperPersonnelCompatibility.isCourseplayVehicleActive(vehicle) then
        return true
    end

    local job = nil
    if vehicle.getStartableAIJob ~= nil then
        job = hpCompatSafeCall(vehicle, "getStartableAIJob")
    end

    if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
        return true
    end

    return HelperPersonnelCompatibility.isCallFromExternalAutomation()
end

function HelperPersonnelCompatibility.install()
    if HelperPersonnelCompatibility.isInstalled == true then
        return
    end

    HelperPersonnelCompatibility.isInstalled = true

    if HelperPersonnelAIJobHooks ~= nil then
        if HelperPersonnelAIJobHooks.getWorkerIdFromJob ~= nil then
            local oldGetWorkerIdFromJob = HelperPersonnelAIJobHooks.getWorkerIdFromJob
            HelperPersonnelAIJobHooks.getWorkerIdFromJob = function(job)
                if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                    return nil
                end

                return oldGetWorkerIdFromJob(job)
            end
        end

        if HelperPersonnelAIJobHooks.getWorkerIdForJob ~= nil then
            local oldGetWorkerIdForJob = HelperPersonnelAIJobHooks.getWorkerIdForJob
            HelperPersonnelAIJobHooks.getWorkerIdForJob = function(app, job)
                if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                    return nil
                end

                return oldGetWorkerIdForJob(app, job)
            end
        end

        if HelperPersonnelAIJobHooks.canUseWorkerForJob ~= nil then
            local oldCanUseWorkerForJob = HelperPersonnelAIJobHooks.canUseWorkerForJob
            HelperPersonnelAIJobHooks.canUseWorkerForJob = function(workerId, job)
                if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                    return true
                end

                return oldCanUseWorkerForJob(workerId, job)
            end
        end
    end

    if HelperPersonnelAIStartHooks ~= nil then
        if HelperPersonnelAIStartHooks.shouldHandleVehicleStart ~= nil then
            local oldShouldHandleVehicleStart = HelperPersonnelAIStartHooks.shouldHandleVehicleStart
            HelperPersonnelAIStartHooks.shouldHandleVehicleStart = function(vehicle)
                if HelperPersonnelCompatibility.isExternalAutomationVehicleStart(vehicle) then
                    hpCompatLog("FS25_HelperPersonnel: Externe KI-Automation wird passiv durchgereicht")
                    return false
                end

                return oldShouldHandleVehicleStart(vehicle)
            end
        end

        if HelperPersonnelAIStartHooks.shouldHandleAIJobStart ~= nil then
            local oldShouldHandleAIJobStart = HelperPersonnelAIStartHooks.shouldHandleAIJobStart
            HelperPersonnelAIStartHooks.shouldHandleAIJobStart = function(job)
                if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                    hpCompatLog("FS25_HelperPersonnel: Externer KI-Job wird passiv durchgereicht")
                    return false
                end

                return oldShouldHandleAIJobStart(job)
            end
        end

        if HelperPersonnelAIStartHooks.openSelectionForVehicle ~= nil then
            local oldOpenSelectionForVehicle = HelperPersonnelAIStartHooks.openSelectionForVehicle
            HelperPersonnelAIStartHooks.openSelectionForVehicle = function(vehicle, fallbackJob, fallbackFarmId, ...)
                if HelperPersonnelCompatibility.isExternalAutomationVehicleStart(vehicle) or HelperPersonnelCompatibility.isExternalAutomationJob(fallbackJob) then
                    return false
                end

                return oldOpenSelectionForVehicle(vehicle, fallbackJob, fallbackFarmId, ...)
            end
        end

        if HelperPersonnelAIStartHooks.openSelectionForAIJob ~= nil then
            local oldOpenSelectionForAIJob = HelperPersonnelAIStartHooks.openSelectionForAIJob
            HelperPersonnelAIStartHooks.openSelectionForAIJob = function(job, fallbackFarmId, ...)
                if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                    return false
                end

                return oldOpenSelectionForAIJob(job, fallbackFarmId, ...)
            end
        end

        if HelperPersonnelAIStartHooks.queueSelectionForAIJob ~= nil then
            local oldQueueSelectionForAIJob = HelperPersonnelAIStartHooks.queueSelectionForAIJob
            HelperPersonnelAIStartHooks.queueSelectionForAIJob = function(job, fallbackFarmId, ...)
                if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                    return false
                end

                return oldQueueSelectionForAIJob(job, fallbackFarmId, ...)
            end
        end

        if HelperPersonnelAIStartHooks.queueSelectionForVehicle ~= nil then
            local oldQueueSelectionForVehicle = HelperPersonnelAIStartHooks.queueSelectionForVehicle
            HelperPersonnelAIStartHooks.queueSelectionForVehicle = function(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames, ...)
                if HelperPersonnelCompatibility.isExternalAutomationVehicleStart(vehicle) or HelperPersonnelCompatibility.isExternalAutomationJob(fallbackJob) then
                    return false
                end

                return oldQueueSelectionForVehicle(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames, ...)
            end
        end
    end

    if HelperPersonnelHelperBridge ~= nil and HelperPersonnelHelperBridge.canUseWorkerForJob ~= nil then
        local oldBridgeCanUseWorkerForJob = HelperPersonnelHelperBridge.canUseWorkerForJob
        HelperPersonnelHelperBridge.canUseWorkerForJob = function(bridge, workerOrId, job, ...)
            if HelperPersonnelCompatibility.isExternalAutomationJob(job) then
                return true
            end

            return oldBridgeCanUseWorkerForJob(bridge, workerOrId, job, ...)
        end
    end

    if HelperPersonnelExperienceEffects ~= nil and HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle ~= nil then
        local oldGetAssignedWorkerIdForVehicle = HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle
        HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle = function(vehicle)
            if HelperPersonnelCompatibility.isAutoDriveVehicleActive(vehicle)
                or HelperPersonnelCompatibility.isCourseplayVehicleActive(vehicle)
                or HelperPersonnelCompatibility.isCallFromExternalAutomation() then
                return nil
            end

            return oldGetAssignedWorkerIdForVehicle(vehicle)
        end
    end
end
