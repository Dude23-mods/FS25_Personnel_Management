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
