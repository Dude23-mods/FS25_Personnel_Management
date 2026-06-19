HelperPersonnelGameSettings = HelperPersonnelGameSettings or {}
HelperPersonnelGameSettings.DEBUG_LOGGING = false
HelperPersonnelGameSettings.isInstalled = false
HelperPersonnelGameSettings.isInitialized = false

HelperPersonnelGameSettings.SETTINGS = {
    { key = "gameplayEffects", field = "gameplayEffectsEnabled", labelKey = "ui_hpSetting_gameplayEffects", descriptionKey = "ui_hpSetting_gameplayEffects_desc" },
    { key = "experienceEffects", field = "experienceEffectsEnabled", labelKey = "ui_hpSetting_experienceEffects", descriptionKey = "ui_hpSetting_experienceEffects_desc", dependency = { name = "gameplayEffects", state = true } },
    { key = "speedEffect", field = "speedEffectEnabled", labelKey = "ui_hpSetting_speedEffect", descriptionKey = "ui_hpSetting_speedEffect_desc", dependency = { name = "experienceEffects", state = true } },
    { key = "wearEffect", field = "wearEffectEnabled", labelKey = "ui_hpSetting_wearEffect", descriptionKey = "ui_hpSetting_wearEffect_desc", dependency = { name = "experienceEffects", state = true } },
    { key = "consumablesEffect", field = "consumablesEffectEnabled", labelKey = "ui_hpSetting_consumablesEffect", descriptionKey = "ui_hpSetting_consumablesEffect_desc", dependency = { name = "experienceEffects", state = true } },
    { key = "fuelEffect", field = "fuelEffectEnabled", labelKey = "ui_hpSetting_fuelEffect", descriptionKey = "ui_hpSetting_fuelEffect_desc", dependency = { name = "experienceEffects", state = true } },
    { key = "reliabilityEffects", field = "reliabilityEffectsEnabled", labelKey = "ui_hpSetting_reliabilityEffects", descriptionKey = "ui_hpSetting_reliabilityEffects_desc", dependency = { name = "gameplayEffects", state = true } },
    { key = "personnelEffects", field = "personnelEffectsEnabled", labelKey = "ui_hpSetting_personnelEffects", descriptionKey = "ui_hpSetting_personnelEffects_desc" },
    { key = "loyaltyEffects", field = "loyaltyEffectsEnabled", labelKey = "ui_hpSetting_loyaltyEffects", descriptionKey = "ui_hpSetting_loyaltyEffects_desc", dependency = { name = "personnelEffects", state = true } },
    { key = "nightWorkLoyaltyEffect", field = "nightWorkLoyaltyEffectEnabled", labelKey = "ui_hpSetting_nightWorkLoyaltyEffect", descriptionKey = "ui_hpSetting_nightWorkLoyaltyEffect_desc", dependency = { name = "loyaltyEffects", state = true } },
    { key = "economicEffects", field = "economicEffectsEnabled", labelKey = "ui_hpSetting_economicEffects", descriptionKey = "ui_hpSetting_economicEffects_desc" },
    { key = "individualWages", field = "individualWagesEnabled", labelKey = "ui_hpSetting_individualWages", descriptionKey = "ui_hpSetting_individualWages_desc", dependency = { name = "economicEffects", state = true } }
}

HelperPersonnelGameSettings.SETTINGS_BY_KEY = {}
for _, setting in ipairs(HelperPersonnelGameSettings.SETTINGS) do
    HelperPersonnelGameSettings.SETTINGS_BY_KEY[setting.key] = setting
end

local function hpGameSettingsInfo(message, ...)
    if HelperPersonnelGameSettings.DEBUG_LOGGING == true and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

local function hpGameSettingsWarning(message, ...)
    if Logging ~= nil and Logging.warning ~= nil then
        Logging.warning(message, ...)
    end
end

local function hpGameSettingsText(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, text = pcall(g_i18n.getText, g_i18n, key)
        if ok and text ~= nil and text ~= "" and text ~= key then
            return text
        end
    end

    return fallback or key
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
    if config ~= nil and config[setting.field] ~= nil then
        return config[setting.field] == true and 2 or 1
    end

    return 2
end

function HelperPersonnelGameSettings.findTemplates(layout)
    if layout == nil or type(layout.elements) ~= "table" then
        return nil, nil
    end

    local sectionHeaderTemplate = nil
    local binaryOptionTemplate = nil

    for _, element in pairs(layout.elements) do
        if element ~= nil then
            if element.name == "sectionHeader" and sectionHeaderTemplate == nil then
                sectionHeaderTemplate = element
            end

            if element.typeName == "Bitmap" and element.elements ~= nil and element.elements[1] ~= nil and element.elements[1].typeName == "BinaryOption" and binaryOptionTemplate == nil then
                binaryOptionTemplate = element
            end
        end

        if sectionHeaderTemplate ~= nil and binaryOptionTemplate ~= nil then
            break
        end
    end

    return sectionHeaderTemplate, binaryOptionTemplate
end

function HelperPersonnelGameSettings.hasExistingRows(layout)
    if layout == nil or type(layout.elements) ~= "table" then
        return false
    end

    for _, element in pairs(layout.elements) do
        if element ~= nil and element.hpHelperPersonnelGameSetting == true then
            return true
        end

        if element ~= nil and element.elements ~= nil then
            for _, child in pairs(element.elements) do
                if child ~= nil and type(child.id) == "string" and string.sub(child.id, 1, 10) == "hpSetting_" then
                    return true
                end
            end
        end
    end

    return false
end

function HelperPersonnelGameSettings.isSettingAvailable(setting)
    if setting == nil then
        return true
    end

    if setting.dependency ~= nil then
        local parent = HelperPersonnelGameSettings.SETTINGS_BY_KEY[setting.dependency.name]
        local config = HelperPersonnelGameSettings.getConfig()
        local parentValue = parent ~= nil and config ~= nil and config[parent.field] == true

        if parentValue ~= setting.dependency.state then
            return false
        end

        return HelperPersonnelGameSettings.isSettingAvailable(parent)
    end

    return true
end

function HelperPersonnelGameSettings.applyDependencies()
    local isEditable = HelperPersonnelGameSettings.isServerAuthority()

    for _, setting in ipairs(HelperPersonnelGameSettings.SETTINGS) do
        if setting.element ~= nil and setting.element.setDisabled ~= nil then
            setting.element:setDisabled(not isEditable or not HelperPersonnelGameSettings.isSettingAvailable(setting))
        end
    end
end

function HelperPersonnelGameSettings.syncElementsFromConfig()
    for _, setting in ipairs(HelperPersonnelGameSettings.SETTINGS) do
        if setting.element ~= nil and setting.element.setState ~= nil then
            setting.element:setState(HelperPersonnelGameSettings.getSettingState(setting), false)
        end
    end

    HelperPersonnelGameSettings.applyDependencies()
end

function HelperPersonnelGameSettings.initialize()
    if HelperPersonnelGameSettings.isInitialized == true then
        HelperPersonnelGameSettings.syncElementsFromConfig()
        return true
    end

    if g_inGameMenu == nil or g_inGameMenu.pageSettings == nil or g_inGameMenu.pageSettings.gameSettingsLayout == nil then
        hpGameSettingsInfo("FS25_HelperPersonnel: Spieleinstellungen noch nicht bereit.")
        return false
    end

    local layout = g_inGameMenu.pageSettings.gameSettingsLayout

    if HelperPersonnelGameSettings.hasExistingRows(layout) then
        HelperPersonnelGameSettings.isInitialized = true
        HelperPersonnelGameSettings.syncElementsFromConfig()
        return true
    end

    local sectionHeaderTemplate, binaryOptionTemplate = HelperPersonnelGameSettings.findTemplates(layout)
    if sectionHeaderTemplate == nil or binaryOptionTemplate == nil then
        hpGameSettingsWarning("FS25_HelperPersonnel: Spieleinstellungen nicht eingefuegt, weil native Vorlagen fehlen.")
        return false
    end

    local sectionHeader = sectionHeaderTemplate:clone(layout)
    sectionHeader.hpHelperPersonnelGameSetting = true
    sectionHeader.id = nil
    sectionHeader:setText(hpGameSettingsText("ui_hpSetting_section", "PERSONALMANAGEMENT"))

    local onText = hpGameSettingsText("ui_hpSetting_on", "An")
    local offText = hpGameSettingsText("ui_hpSetting_off", "Aus")

    for _, setting in ipairs(HelperPersonnelGameSettings.SETTINGS) do
        local row = binaryOptionTemplate:clone(layout)
        row.hpHelperPersonnelGameSetting = true
        row.id = nil

        if row.elements ~= nil then
            for _, element in pairs(row.elements) do
                if element.typeName == "Text" then
                    element.id = nil
                    element:setText(hpGameSettingsText(setting.labelKey, setting.key))
                elseif element.typeName == "BinaryOption" then
                    element.id = "hpSetting_" .. setting.key
                    element:setTexts({ offText, onText })
                    element:setState(HelperPersonnelGameSettings.getSettingState(setting), false)
                    element.onClickCallback = HelperPersonnelGameSettings.onSettingChanged
                    element.isAlwaysFocusedOnOpen = false
                    element.focused = false

                    -- The native game settings row contains the explanation text as
                    -- the first child of the option widget.  If this is not
                    -- overwritten, the cloned row keeps the description of the
                    -- original base-game setting.
                    if element.elements ~= nil and element.elements[1] ~= nil and element.elements[1].setText ~= nil then
                        element.elements[1]:setText(hpGameSettingsText(setting.descriptionKey, ""))
                    end

                    setting.element = element
                elseif element.id ~= nil then
                    element.id = nil
                end
            end
        end
    end

    HelperPersonnelGameSettings.isInitialized = true
    HelperPersonnelGameSettings.applyDependencies()

    if layout.invalidateLayout ~= nil then
        layout:invalidateLayout()
    end
    if layout.updateAbsolutePosition ~= nil then
        layout:updateAbsolutePosition()
    end

    if Logging ~= nil and Logging.info ~= nil then
        Logging.info("FS25_HelperPersonnel: Personalmanagement-Schalter in native Spieleinstellungen eingefuegt.")
    end

    return true
end

function HelperPersonnelGameSettings.onSettingChanged(_, state, button)
    if button == nil then
        button = state
    end

    if button == nil or button.id == nil or string.sub(button.id, 1, 10) ~= "hpSetting_" then
        return
    end

    if HelperPersonnelGameSettings.isServerAuthority() ~= true then
        HelperPersonnelGameSettings.syncElementsFromConfig()
        return
    end

    local key = string.sub(button.id, 11)
    local setting = HelperPersonnelGameSettings.SETTINGS_BY_KEY[key]
    local config = HelperPersonnelGameSettings.getConfig()

    if setting == nil or config == nil then
        return
    end

    local newState = tonumber(state) or (button.state ~= nil and tonumber(button.state) or nil) or 2
    config[setting.field] = newState == 2

    if config.save ~= nil then
        config:save()
    end

    HelperPersonnelGameSettings.syncElementsFromConfig()

    if g_helperPersonnelApp ~= nil and g_server ~= nil and g_helperPersonnelApp.syncNetworkStateToClients ~= nil then
        g_helperPersonnelApp:syncNetworkStateToClients()
    end
end

function HelperPersonnelGameSettings.onLoadMapFinished()
    HelperPersonnelGameSettings.initialize()
end

function HelperPersonnelGameSettings.onMission00Loaded()
    HelperPersonnelGameSettings.initialize()
end

function HelperPersonnelGameSettings.onFrameOpen()
    HelperPersonnelGameSettings.syncElementsFromConfig()
end

function HelperPersonnelGameSettings.onFrameClose()
    local config = HelperPersonnelGameSettings.getConfig()
    if g_server ~= nil and config ~= nil and config.save ~= nil then
        config:save()
    end
end

function HelperPersonnelGameSettings.install()
    if HelperPersonnelGameSettings.isInstalled == true then
        return
    end

    HelperPersonnelGameSettings.isInstalled = true

    if FSBaseMission ~= nil and FSBaseMission.loadMapFinished ~= nil then
        FSBaseMission.loadMapFinished = Utils.appendedFunction(FSBaseMission.loadMapFinished, HelperPersonnelGameSettings.onLoadMapFinished)
    end

    if Mission00 ~= nil and Mission00.loadMission00Finished ~= nil then
        Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, HelperPersonnelGameSettings.onMission00Loaded)
    end

    if InGameMenuSettingsFrame ~= nil then
        if InGameMenuSettingsFrame.onFrameOpen ~= nil then
            InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, HelperPersonnelGameSettings.onFrameOpen)
        end
        if InGameMenuSettingsFrame.onFrameClose ~= nil then
            InGameMenuSettingsFrame.onFrameClose = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameClose, HelperPersonnelGameSettings.onFrameClose)
        end
    end

    if HelperPersonnelConfig ~= nil and HelperPersonnelConfig.applyNetworkState ~= nil and HelperPersonnelGameSettings.didHookConfigNetworkState ~= true then
        HelperPersonnelGameSettings.didHookConfigNetworkState = true
        HelperPersonnelConfig.applyNetworkState = Utils.appendedFunction(HelperPersonnelConfig.applyNetworkState, HelperPersonnelGameSettings.syncElementsFromConfig)
    end
end

HelperPersonnelGameSettings.install()
