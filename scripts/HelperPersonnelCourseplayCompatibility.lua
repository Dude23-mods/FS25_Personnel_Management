HelperPersonnelCourseplayCompatibility = HelperPersonnelCourseplayCompatibility or {}

HelperPersonnelCourseplayCompatibility.jobClassNames = {
    "CpAIJob",
    "CpAIJobFieldWork",
    "CpAIJobBaleFinder",
    "CpAIJobBunkerSilo",
    "CpAIJobCombineUnloader",
    "CpAIJobSiloLoader"
}

HelperPersonnelCourseplayCompatibility.jobClassHookOptions = {
    CpAIJobBunkerSilo = {
        skipReadStream = true
    }
}

function HelperPersonnelCourseplayCompatibility.getJobClass(className)
    if type(FS25_Courseplay) == "table" and FS25_Courseplay[className] ~= nil then
        return FS25_Courseplay[className]
    end
    if _G ~= nil then
        return _G[className]
    end
    return nil
end

function HelperPersonnelCourseplayCompatibility.isCourseplayJob(job)
    if job == nil then
        return false
    end

    local baseClass = HelperPersonnelCourseplayCompatibility.getJobClass("CpAIJob")
    if baseClass ~= nil and job.is_a ~= nil and job:is_a(baseClass) then
        return true
    end

    for _, className in ipairs(HelperPersonnelCourseplayCompatibility.jobClassNames) do
        local classObject = HelperPersonnelCourseplayCompatibility.getJobClass(className)
        if classObject ~= nil and job.is_a ~= nil and job:is_a(classObject) then
            return true
        end
    end

    return false
end

function HelperPersonnelCourseplayCompatibility.prepareAIJobStart(job)
    if not HelperPersonnelCourseplayCompatibility.isCourseplayJob(job)
        or (job.hpHelperPersonnelStopHandled ~= true and job.hpHelperPersonnelRestoredWorkerId == nil) then
        return false
    end

    local app = g_helperPersonnelApp
    if app == nil or app.activeJobsRestoreDone ~= true
        or (HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.isSendingSelectedAIJob == true) then
        return false
    end

    local bridge = app.helperBridge
    local workerId = job.helperPersonnelWorkerId
    if workerId == nil and bridge ~= nil and bridge.getWorkerIdByJob ~= nil then
        workerId = bridge:getWorkerIdByJob(job)
    end

    if bridge ~= nil then
        if bridge.jobWorkerIds ~= nil then
            bridge.jobWorkerIds[job] = nil
        end
        if workerId ~= nil and bridge.workerJobById ~= nil and bridge.workerJobById[workerId] == job then
            bridge.workerJobById[workerId] = nil
        end
        if bridge.getVehicleKeyFromJob ~= nil and bridge.vehicleWorkerIds ~= nil then
            local vehicleKey = bridge:getVehicleKeyFromJob(job)
            if vehicleKey ~= nil and (workerId == nil or bridge.vehicleWorkerIds[vehicleKey] == workerId) then
                bridge.vehicleWorkerIds[vehicleKey] = nil
            end
        end
    end

    job.helperPersonnelWorkerId = nil
    job.helperPersonnelBaseHelperIndex = nil
    job.hpHelperPersonnelFinalized = nil
    job.hpHelperPersonnelStopHandled = nil
    job.hpHelperPersonnelRestoredWorkerId = nil
    HelperPersonnel.debugInfo("FS25_HelperPersonnel: Cleared stopped or restored Courseplay job assignment before new start")
    return true
end

function HelperPersonnelCourseplayCompatibility.install(stage)
    if HelperPersonnelAIJobHooks == nil or HelperPersonnelAIJobHooks.installJobClassHooks == nil then
        return
    end

    local installedAny = false
    for _, className in ipairs(HelperPersonnelCourseplayCompatibility.jobClassNames) do
        local classObject = HelperPersonnelCourseplayCompatibility.getJobClass(className)
        if classObject ~= nil then
            HelperPersonnelAIJobHooks.installJobClassHooks(
                className,
                classObject,
                HelperPersonnelCourseplayCompatibility.jobClassHookOptions[className])
            installedAny = true
        end
    end

    if installedAny then
        HelperPersonnelCourseplayCompatibility.isInstalled = true
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Courseplay compatibility active (%s)", tostring(stage))
    end
end
