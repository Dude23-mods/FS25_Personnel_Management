HelperPersonnelGameSettings = HelperPersonnelGameSettings or {}

HelperPersonnelGameSettings.SETTINGS = {
    { key = "gameplayEffects", field = "gameplayEffectsEnabled", labelKey = "ui_hpSetting_gameplayEffects", descriptionKey = "ui_hpSetting_gameplayEffects_desc", sectionKey = "ui_hpSetting_groupWork" },
    { key = "experienceEffects", field = "experienceEffectsEnabled", labelKey = "ui_hpSetting_experienceEffects", descriptionKey = "ui_hpSetting_experienceEffects_desc", sectionKey = "ui_hpSetting_groupWork", dependency = { name = "gameplayEffects", state = true } },
    { key = "speedEffect", field = "speedEffectEnabled", labelKey = "ui_hpSetting_speedEffect", descriptionKey = "ui_hpSetting_speedEffect_desc", sectionKey = "ui_hpSetting_groupWork", dependency = { name = "experienceEffects", state = true } },
    { key = "wearEffect", field = "wearEffectEnabled", labelKey = "ui_hpSetting_wearEffect", descriptionKey = "ui_hpSetting_wearEffect_desc", sectionKey = "ui_hpSetting_groupWork", dependency = { name = "experienceEffects", state = true } },
    { key = "consumablesEffect", field = "consumablesEffectEnabled", labelKey = "ui_hpSetting_consumablesEffect", descriptionKey = "ui_hpSetting_consumablesEffect_desc", sectionKey = "ui_hpSetting_groupWork", dependency = { name = "experienceEffects", state = true } },
    { key = "fuelEffect", field = "fuelEffectEnabled", labelKey = "ui_hpSetting_fuelEffect", descriptionKey = "ui_hpSetting_fuelEffect_desc", sectionKey = "ui_hpSetting_groupWork", dependency = { name = "experienceEffects", state = true } },
    { key = "reliabilityEffects", field = "reliabilityEffectsEnabled", labelKey = "ui_hpSetting_reliabilityEffects", descriptionKey = "ui_hpSetting_reliabilityEffects_desc", sectionKey = "ui_hpSetting_groupWork", dependency = { name = "gameplayEffects", state = true } },
    { key = "personnelEffects", field = "personnelEffectsEnabled", labelKey = "ui_hpSetting_personnelEffects", descriptionKey = "ui_hpSetting_personnelEffects_desc", sectionKey = "ui_hpSetting_groupPersonnel" },
    { key = "loyaltyEffects", field = "loyaltyEffectsEnabled", labelKey = "ui_hpSetting_loyaltyEffects", descriptionKey = "ui_hpSetting_loyaltyEffects_desc", sectionKey = "ui_hpSetting_groupPersonnel", dependency = { name = "personnelEffects", state = true } },
    { key = "nightWorkLoyaltyEffect", field = "nightWorkLoyaltyEffectEnabled", labelKey = "ui_hpSetting_nightWorkLoyaltyEffect", descriptionKey = "ui_hpSetting_nightWorkLoyaltyEffect_desc", sectionKey = "ui_hpSetting_groupPersonnel", dependency = { name = "loyaltyEffects", state = true } },
    { key = "economicEffects", field = "economicEffectsEnabled", labelKey = "ui_hpSetting_economicEffects", descriptionKey = "ui_hpSetting_economicEffects_desc", sectionKey = "ui_hpSetting_groupEconomy" },
    { key = "individualWages", field = "individualWagesEnabled", labelKey = "ui_hpSetting_individualWages", descriptionKey = "ui_hpSetting_individualWages_desc", sectionKey = "ui_hpSetting_groupEconomy", dependency = { name = "economicEffects", state = true } },
    { key = "standardWage", field = "standardBaseMonthlyWage", valueType = "number", labelKey = "ui_hpSetting_standardWage", descriptionKey = "ui_hpSetting_standardWage_desc", sectionKey = "ui_hpSetting_groupEconomy", dependency = { name = "economicEffects", state = true } }
}

HelperPersonnelGameSettings.SETTINGS_BY_KEY = {}
for _, setting in ipairs(HelperPersonnelGameSettings.SETTINGS) do
    HelperPersonnelGameSettings.SETTINGS_BY_KEY[setting.key] = setting
end

function HelperPersonnelGameSettings.getManager()
    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.manager ~= nil then
        return g_helperPersonnelApp.manager
    end

    return nil
end

function HelperPersonnelGameSettings.getConfig()
    local manager = HelperPersonnelGameSettings.getManager()
    if manager ~= nil then
        return manager.config
    end

    return nil
end

function HelperPersonnelGameSettings.isServerAuthority()
    return g_server ~= nil
end

function HelperPersonnelGameSettings.getSettingState(setting)
    local config = HelperPersonnelGameSettings.getConfig()
    if config ~= nil and setting ~= nil and setting.valueType ~= "number" and config[setting.field] ~= nil then
        return config[setting.field] == true and 2 or 1
    end

    return 2
end

function HelperPersonnelGameSettings.getSettingDisplayText(setting)
    local config = HelperPersonnelGameSettings.getConfig()
    if setting == nil or config == nil then
        return "-"
    end

    if setting.valueType == "number" then
        local value = tonumber(config[setting.field]) or 0
        if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
            return g_i18n:formatMoney(value, 0, true, false)
        end
        return tostring(math.floor(value + 0.5))
    end

    return "-"
end

function HelperPersonnelGameSettings.findTemplates(layout)
    if layout == nil then
        return nil, nil
    end

    local sectionHeaderTemplate = nil
    local binaryOptionTemplate = nil

    local function isBinaryOptionRow(element)
        if element == nil or element.typeName ~= "Bitmap" then
            return false
        end

        for _, child in ipairs(element.elements or {}) do
            if child.typeName == "BinaryOption" then
                return true
            end
        end

        return false
    end

    local function visit(element)
        if element == nil then
            return
        end

        if sectionHeaderTemplate == nil and element.name == "sectionHeader" then
            sectionHeaderTemplate = element
        end

        if binaryOptionTemplate == nil and isBinaryOptionRow(element) then
            binaryOptionTemplate = element
        end

        if sectionHeaderTemplate ~= nil and binaryOptionTemplate ~= nil then
            return
        end

        for _, child in ipairs(element.elements or {}) do
            visit(child)
            if sectionHeaderTemplate ~= nil and binaryOptionTemplate ~= nil then
                return
            end
        end
    end

    for _, element in ipairs(layout.elements or {}) do
        visit(element)
        if sectionHeaderTemplate ~= nil and binaryOptionTemplate ~= nil then
            break
        end
    end

    return sectionHeaderTemplate, binaryOptionTemplate
end

function HelperPersonnelGameSettings.isSettingAvailable(setting)
    if setting == nil or setting.dependency == nil then
        return true
    end

    local parent = HelperPersonnelGameSettings.SETTINGS_BY_KEY[setting.dependency.name]
    local config = HelperPersonnelGameSettings.getConfig()
    local parentValue = parent ~= nil and config ~= nil and config[parent.field] == true

    if parentValue ~= setting.dependency.state then
        return false
    end

    return HelperPersonnelGameSettings.isSettingAvailable(parent)
end

function HelperPersonnelGameSettings.syncElementsFromConfig()
    local settingsFrame = nil
    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.standaloneMenu ~= nil then
        settingsFrame = g_helperPersonnelApp.standaloneMenu.pageSettings
    end

    if settingsFrame ~= nil and settingsFrame.syncNativeSettings ~= nil then
        settingsFrame:syncNativeSettings()
        return
    end

    for _, setting in ipairs(HelperPersonnelGameSettings.SETTINGS) do
        if setting.element ~= nil and setting.element.setState ~= nil then
            if setting.valueType == "number" then
                local displayText = HelperPersonnelGameSettings.getSettingDisplayText(setting)
                if setting.element.setTexts ~= nil then
                    setting.element:setTexts({displayText, displayText})
                end
                setting.element:setState(1, false)
            else
                setting.element:setState(HelperPersonnelGameSettings.getSettingState(setting), false)
            end
            local hasAuthority = HelperPersonnelGameSettings.isServerAuthority()
            local available = hasAuthority and HelperPersonnelGameSettings.isSettingAvailable(setting)
            if setting.element.setCanChangeState ~= nil then
                setting.element:setCanChangeState(available)
            end
            if setting.element.setDisabled ~= nil then
                setting.element:setDisabled(not hasAuthority)
            end
        end
    end
end
