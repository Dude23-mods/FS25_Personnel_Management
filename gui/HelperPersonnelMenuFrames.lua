HelperPersonnelOverviewFrame = {}
local HelperPersonnelOverviewFrame_mt = Class(HelperPersonnelOverviewFrame, HelperPersonnelMenuPage)

function HelperPersonnelOverviewFrame.new(target, customMt)
    return HelperPersonnelMenuPage.new("overview", customMt or HelperPersonnelOverviewFrame_mt)
end

HelperPersonnelApplicantsFrame = {}
local HelperPersonnelApplicantsFrame_mt = Class(HelperPersonnelApplicantsFrame, HelperPersonnelMenuPage)

function HelperPersonnelApplicantsFrame.new(target, customMt)
    return HelperPersonnelMenuPage.new("applicants", customMt or HelperPersonnelApplicantsFrame_mt)
end

HelperPersonnelEmployeesFrame = {}
local HelperPersonnelEmployeesFrame_mt = Class(HelperPersonnelEmployeesFrame, HelperPersonnelMenuPage)

function HelperPersonnelEmployeesFrame.new(target, customMt)
    return HelperPersonnelMenuPage.new("employees", customMt or HelperPersonnelEmployeesFrame_mt)
end

HelperPersonnelTrainingFrame = {}
local HelperPersonnelTrainingFrame_mt = Class(HelperPersonnelTrainingFrame, HelperPersonnelMenuPage)

function HelperPersonnelTrainingFrame.new(target, customMt)
    return HelperPersonnelMenuPage.new("training", customMt or HelperPersonnelTrainingFrame_mt)
end

HelperPersonnelSettingsFrame = {}
local HelperPersonnelSettingsFrame_mt = Class(HelperPersonnelSettingsFrame, HelperPersonnelMenuPage)
local HP_SETTINGS_VISIBLE_ITEMS = 11
local HP_SETTINGS_LAYOUT_Y_OFFSET = 0.182
local HP_SETTINGS_SCROLL_X = 0.972
local HP_SETTINGS_SCROLL_Y = 0.180
local HP_SETTINGS_SCROLL_WIDTH = 0.005
local HP_SETTINGS_SCROLL_HEIGHT = 0.570
local HP_SETTINGS_NUMBER_FIELD_FALLBACK_X = 0.426
local HP_SETTINGS_NUMBER_FIELD_WIDTH = 0.144
local HP_SETTINGS_NUMBER_FIELD_HEIGHT = 0.032
local HP_SETTINGS_NUMBER_FIELD_TEXT_SIZE = 0.0115
local HP_SETTINGS_NUMBER_FIELD_MAX_CHARACTERS = 6

local function hpSettingsClearIds(element)
    if element == nil then
        return
    end

    element.id = nil
    element.focusId = nil
    element.focusChangeData = {}
    element.focusActive = false
    element.isAlwaysFocusedOnOpen = false
    element.focused = false
    element.selected = false
    element.highlighted = false
    element.disabled = false

    for _, child in ipairs(element.elements or {}) do
        hpSettingsClearIds(child)
    end
end

local function hpSettingsClearToolTips(element)
    if element == nil then
        return
    end

    element.toolTipText = nil
    element.toolTipElementId = nil
    element.toolTipElement = nil

    for _, child in ipairs(element.elements or {}) do
        hpSettingsClearToolTips(child)
    end
end

local function hpSettingsClearInheritedCallbacks(element)
    if element == nil then
        return
    end

    element.onCreateCallback = nil
    element.onCreateArgs = nil
    element.onOpenCallback = nil
    element.onCloseCallback = nil
    element.onDrawCallback = nil
    element.onFocusCallback = nil
    element.onLeaveCallback = nil
    element.onHighlightCallback = nil

    for _, child in ipairs(element.elements or {}) do
        hpSettingsClearInheritedCallbacks(child)
    end
end

local function hpSettingsHideUnusedTexts(element, label)
    if element == nil then
        return
    end

    if element.typeName == "Text" and element ~= label then
        if element.setText ~= nil then
            element:setText("")
        end
        if element.setVisible ~= nil then
            element:setVisible(false)
        end
        if element.setDisabled ~= nil then
            element:setDisabled(true)
        end
    end

    for _, child in ipairs(element.elements or {}) do
        hpSettingsHideUnusedTexts(child, label)
    end
end

local function hpSettingsFindFirstByType(element, typeName)
    if element == nil then
        return nil
    end

    if element.typeName == typeName then
        return element
    end

    for _, child in ipairs(element.elements or {}) do
        local result = hpSettingsFindFirstByType(child, typeName)
        if result ~= nil then
            return result
        end
    end

    return nil
end

local function hpSettingsFindLabel(element)
    if element == nil then
        return nil
    end

    for _, child in ipairs(element.elements or {}) do
        if child.typeName == "Text" then
            return child
        end
    end

    return hpSettingsFindFirstByType(element, "Text")
end

local function hpSettingsSetImageColor(element, state, r, g, b, a)
    if element ~= nil and element.setImageColor ~= nil and state ~= nil then
        element:setImageColor(state, r, g, b, a)
    end
end

local function hpSettingsSetTransparentBackground(element)
    if GuiOverlay == nil then
        return
    end

    hpSettingsSetImageColor(element, GuiOverlay.STATE_NORMAL, 0, 0, 0, 0)
    hpSettingsSetImageColor(element, GuiOverlay.STATE_DISABLED, 0, 0, 0, 0)
    hpSettingsSetImageColor(element, GuiOverlay.STATE_FOCUSED, 0, 0, 0, 0)
    hpSettingsSetImageColor(element, GuiOverlay.STATE_SELECTED, 0, 0, 0, 0)
    hpSettingsSetImageColor(element, GuiOverlay.STATE_HIGHLIGHTED, 0, 0, 0, 0)
    hpSettingsSetImageColor(element, GuiOverlay.STATE_PRESSED, 0, 0, 0, 0)
end

local function hpSettingsSetTransparentRow(row)
    if row == nil or GuiOverlay == nil then
        return
    end

    hpSettingsSetImageColor(row, GuiOverlay.STATE_NORMAL, 0, 0, 0, 0)
    hpSettingsSetImageColor(row, GuiOverlay.STATE_DISABLED, 0, 0, 0, 0)
    hpSettingsSetImageColor(row, GuiOverlay.STATE_FOCUSED, 0, 0, 0, 0)
    hpSettingsSetImageColor(row, GuiOverlay.STATE_SELECTED, 0, 0, 0, 0)
    hpSettingsSetImageColor(row, GuiOverlay.STATE_HIGHLIGHTED, 0, 0, 0, 0)
    hpSettingsSetImageColor(row, GuiOverlay.STATE_PRESSED, 0, 0, 0, 0)
end

local function hpSettingsSetTransparentTree(element)
    if element == nil then
        return
    end

    hpSettingsSetTransparentBackground(element)
    for _, child in ipairs(element.elements or {}) do
        hpSettingsSetTransparentTree(child)
    end
end

local function hpSettingsIsLeftMouseButton(button)
    local leftMouseButton = Input ~= nil and Input.MOUSE_BUTTON_LEFT or nil
    return button == nil or button == 0 or button == 1 or (leftMouseButton ~= nil and button == leftMouseButton)
end

function HelperPersonnelSettingsFrame.new(target, customMt)
    local self = HelperPersonnelMenuPage.new("settings", customMt or HelperPersonnelSettingsFrame_mt)

    self.nativeSettingsReady = false
    self.nativeSettingsBuildAttempted = false
    self.nativeSettingsLayout = nil
    self.nativeSettingElements = {}
    self.nativeSettingRows = {}
    self.nativeSettingSections = {}
    self.nativeSettingItems = {}
    self.nativeSettingsScrollOffset = 0
    self.nativeSettingsScrollbarDragging = false
    self.nativeSettingsScrollArea = nil
    self.nativeSettingsScrollbarArea = nil
    self.nativeNumberFieldOptions = {}
    self.nativeStandardWageFieldArea = nil
    self.standardWageInputActive = false
    self.standardWageInputBuffer = nil
    self.standardWageInputReplaceOnType = false

    return self
end

function HelperPersonnelSettingsFrame:delete()
    for _, setting in ipairs(self:getSettingsList()) do
        if self.nativeSettingElements[setting.key] ~= nil and setting.element == self.nativeSettingElements[setting.key] then
            setting.element = nil
        end
    end

    self.nativeSettingElements = {}
    self.nativeSettingRows = {}
    self.nativeSettingSections = {}
    self.nativeSettingItems = {}
    self.nativeSettingsLayout = nil
    self.nativeSettingsScrollArea = nil
    self.nativeSettingsScrollbarArea = nil
    self.nativeSettingsScrollbarDragging = false
    self.nativeNumberFieldOptions = {}
    self.nativeStandardWageFieldArea = nil
    self.standardWageInputActive = false
    self.standardWageInputBuffer = nil
    self.standardWageInputReplaceOnType = false

    HelperPersonnelSettingsFrame:superClass().delete(self)
end

function HelperPersonnelSettingsFrame:getNativeSettingsSource()
    if g_inGameMenu == nil or g_inGameMenu.pageSettings == nil then
        return nil
    end

    return g_inGameMenu.pageSettings.gameSettingsLayout
end

function HelperPersonnelSettingsFrame:removeLayoutChildren(layout)
    if layout == nil then
        return
    end

    for index = #(layout.elements or {}), 1, -1 do
        local child = layout.elements[index]
        if child ~= nil then
            child:delete()
        end
    end
end

function HelperPersonnelSettingsFrame:registerFocusElement(element, isFirst)
    if element == nil or FocusManager == nil or FocusManager.loadElementFromCustomValues == nil then
        return
    end

    FocusManager:loadElementFromCustomValues(element, nil, nil, false, isFirst == true)
end

function HelperPersonnelSettingsFrame:addNativeSectionHeader(layout, template, textKey)
    local sectionHeader = template:clone(layout, false, true)
    if sectionHeader.setTarget ~= nil then
        sectionHeader:setTarget(self, sectionHeader.target, false)
    end
    hpSettingsClearIds(sectionHeader)
    hpSettingsClearToolTips(sectionHeader)
    hpSettingsClearInheritedCallbacks(sectionHeader)
    sectionHeader.hpHelperPersonnelGameSetting = true
    hpSettingsSetTransparentRow(sectionHeader)

    local sectionText = self:getText(textKey, textKey or "")
    if sectionHeader.setText ~= nil then
        sectionHeader:setText(sectionText)
    end
    local textElement = hpSettingsFindFirstByType(sectionHeader, "Text")
    if textElement ~= nil and textElement.setText ~= nil then
        textElement:setText(sectionText)
    end

    table.insert(self.nativeSettingSections, sectionHeader)
    table.insert(self.nativeSettingItems, { element = sectionHeader })
    return sectionHeader
end

function HelperPersonnelSettingsFrame:configureNativeRow(row, setting, offText, onText)
    hpSettingsClearIds(row)
    hpSettingsClearToolTips(row)
    hpSettingsClearInheritedCallbacks(row)

    local labelText = self:getSettingText(setting, "labelKey", setting.key or "")
    local compactLabel = string.match(labelText, "^[^:]+:%s*(.+)$")
    if compactLabel ~= nil and compactLabel ~= "" then
        labelText = compactLabel
    end

    local label = hpSettingsFindLabel(row)
    if label ~= nil and label.setText ~= nil then
        label:setText(labelText)
    end

    local option = hpSettingsFindFirstByType(row, "BinaryOption")
    if option == nil then
        option = hpSettingsFindFirstByType(row, "MultiTextOption")
    end

    if option == nil then
        return nil
    end

    hpSettingsHideUnusedTexts(row, label)

    option.id = "hpSetting_" .. tostring(setting.key)
    if setting.valueType == "number" then
        option:setTexts({"", ""})
        option:setState(1, false)
        if option.setVisible ~= nil then
            option:setVisible(true)
        end
        if option.setCanChangeState ~= nil then
            option:setCanChangeState(true)
        end
        if option.setDisabled ~= nil then
            option:setDisabled(false)
        end
        hpSettingsSetTransparentTree(option)
        option.onClickCallback = function()
            self.settingsSelectedKey = setting.key
            self:showStandardWageInput(setting)
        end
        option.onFocusCallback = function()
            self.settingsSelectedKey = setting.key
        end
        self.nativeNumberFieldOptions[setting.key] = option
    else
        option:setTexts({offText, onText})
        option:setState(HelperPersonnelGameSettings.getSettingState(setting), false)
        option.onClickCallback = function(_, state, button)
            self:onNativeSettingChanged(state, button or option, setting)
        end
        option.onFocusCallback = function()
            self.settingsSelectedKey = setting.key
        end
    end
    option.isAlwaysFocusedOnOpen = false
    option.focused = false

    row.onFocusCallback = function()
        self.settingsSelectedKey = setting.key
    end

    row.hpHelperPersonnelGameSetting = true
    setting.element = option
    self.nativeSettingElements[setting.key] = option
    self.nativeSettingRows[setting.key] = row

    return option
end

function HelperPersonnelSettingsFrame:getNativeSettingsScrollState()
    local itemCount = #(self.nativeSettingItems or {})
    local visibleCount = math.min(HP_SETTINGS_VISIBLE_ITEMS, itemCount)
    local maxOffset = math.max(0, itemCount - visibleCount)
    local offset = math.max(0, math.min(tonumber(self.nativeSettingsScrollOffset) or 0, maxOffset))

    return {
        itemCount = itemCount,
        visibleCount = visibleCount,
        maxOffset = maxOffset,
        offset = offset
    }
end

function HelperPersonnelSettingsFrame:updateNativeSettingsScroll()
    local state = self:getNativeSettingsScrollState()
    self.nativeSettingsScrollOffset = state.offset

    local selectedVisible = false
    local firstVisibleSettingKey = nil
    for index, item in ipairs(self.nativeSettingItems or {}) do
        local visible = index > state.offset and index <= state.offset + state.visibleCount
        local element = item.element
        if element ~= nil and element.setVisible ~= nil then
            element:setVisible(visible)
        end
        if visible and item.settingKey ~= nil then
            firstVisibleSettingKey = firstVisibleSettingKey or item.settingKey
            if item.settingKey == self.settingsSelectedKey then
                selectedVisible = true
            end
        end
    end

    if not selectedVisible and firstVisibleSettingKey ~= nil then
        self.settingsSelectedKey = firstVisibleSettingKey
    end

    if self.nativeSettingsLayout ~= nil and self.nativeSettingsLayout.invalidateLayout ~= nil then
        self.nativeSettingsLayout:invalidateLayout()
    end
    if self.nativeSettingsLayout ~= nil and self.nativeSettingsLayout.updateAbsolutePosition ~= nil then
        self.nativeSettingsLayout:updateAbsolutePosition()
    end

    return state
end

function HelperPersonnelSettingsFrame:scrollNativeSettings(delta)
    local state = self:getNativeSettingsScrollState()
    if state.maxOffset <= 0 then
        return false
    end

    local newOffset = math.max(0, math.min(state.maxOffset, state.offset + (tonumber(delta) or 0)))
    if newOffset == state.offset then
        return false
    end

    self.nativeSettingsScrollOffset = newOffset
    self:updateNativeSettingsScroll()
    self:syncNativeSettings()
    return true
end

function HelperPersonnelSettingsFrame:setNativeSettingsScrollFromMouseY(posY)
    local state = self:getNativeSettingsScrollState()
    local area = self.nativeSettingsScrollbarArea
    if area == nil or state.maxOffset <= 0 then
        return false
    end

    local localY = math.max(0, math.min(1, (posY - area.y) / area.height))
    local progress = 1 - localY
    local newOffset = math.floor(progress * state.maxOffset + 0.5)
    if newOffset == state.offset then
        return false
    end

    self.nativeSettingsScrollOffset = newOffset
    self:updateNativeSettingsScroll()
    self:syncNativeSettings()
    return true
end

function HelperPersonnelSettingsFrame:buildNativeSettings()
    if self.nativeSettingsReady == true then
        return true
    end

    if self.nativeSettingsBuildAttempted == true then
        return false
    end

    if HelperPersonnelGameSettings == nil then
        return false
    end

    local sourceLayout = self:getNativeSettingsSource()
    local root = self.elements ~= nil and self.elements[1] or nil
    if sourceLayout == nil or root == nil then
        return false
    end

    local sectionHeaderTemplate, binaryOptionTemplate = HelperPersonnelGameSettings.findTemplates(sourceLayout)
    if sectionHeaderTemplate == nil or binaryOptionTemplate == nil then
        if Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("%s: Native Vorlagen für die Personalmanagement-Einstellungen wurden nicht gefunden.", tostring(self.app ~= nil and self.app.modName or "FS25_PersonnelManagement"))
        end
        return false
    end

    self.nativeSettingsBuildAttempted = true

    local layout = sourceLayout:clone(root, false, true)
    self:removeLayoutChildren(layout)
    layout.id = nil
    layout.name = "helperPersonnelSettingsLayout"
    if layout.setTarget ~= nil then
        layout:setTarget(self, sourceLayout.target, false)
    end
    layout:setVisible(true)
    layout:setDisabled(false)
    if layout.setPosition ~= nil then
        layout:setPosition(layout.position[1], (layout.position[2] or 0) - HP_SETTINGS_LAYOUT_Y_OFFSET)
    end
    hpSettingsSetTransparentBackground(layout)
    hpSettingsClearToolTips(layout)
    hpSettingsClearInheritedCallbacks(layout)
    self.nativeSettingsLayout = layout

    local offText = self:getText("ui_hpSetting_off", "Aus")
    local onText = self:getText("ui_hpSetting_on", "An")

    local currentSectionKey = nil
    local focusIndex = 0
    for _, setting in ipairs(self:getSettingsList()) do
        if setting.sectionKey ~= currentSectionKey then
            currentSectionKey = setting.sectionKey
            self:addNativeSectionHeader(layout, sectionHeaderTemplate, currentSectionKey)
        end

        local row = binaryOptionTemplate:clone(layout, false, true)
        if row.setTarget ~= nil then
            row:setTarget(self, row.target, false)
        end
        hpSettingsSetTransparentRow(row)
        local option = self:configureNativeRow(row, setting, offText, onText)
        if option ~= nil then
            table.insert(self.nativeSettingItems, { element = row, settingKey = setting.key })
            focusIndex = focusIndex + 1
            self:registerFocusElement(row, focusIndex == 1)
            if focusIndex == 1 and self.settingsSelectedKey == nil then
                self.settingsSelectedKey = setting.key
            end
        else
            row:delete()
        end
    end

    self:updateNativeSettingsScroll()

    self.nativeSettingsReady = next(self.nativeSettingElements) ~= nil
    self:syncNativeSettings()

    return self.nativeSettingsReady
end

function HelperPersonnelSettingsFrame:syncNativeSettings()
    if self.nativeSettingsReady ~= true then
        return
    end

    local config = self:getSettingsConfig()
    local canEdit = config ~= nil and self:canManageCurrentFarm() and self:isServerAuthority()

    for _, setting in ipairs(self:getSettingsList()) do
        local option = self.nativeSettingElements[setting.key]
        if option ~= nil then
            local available = self:isSettingAvailable(setting)
            local editable = canEdit and available
            if setting.valueType == "number" then
                option:setState(1, false)
                if option.setVisible ~= nil then
                    option:setVisible(true)
                end
                if option.setCanChangeState ~= nil then
                    option:setCanChangeState(editable)
                end
                if option.setDisabled ~= nil then
                    option:setDisabled(not editable)
                end
                if not editable and self.standardWageInputActive == true then
                    self.standardWageInputActive = false
                    self.standardWageInputBuffer = nil
                    self.standardWageInputReplaceOnType = false
                end
                hpSettingsSetTransparentTree(option)
            else
                option:setState(HelperPersonnelGameSettings.getSettingState(setting), false)
                if option.setCanChangeState ~= nil then
                    option:setCanChangeState(editable)
                end
                if option.setDisabled ~= nil then
                    option:setDisabled(not canEdit)
                end
            end
        end
    end

    if self.nativeSettingsLayout ~= nil and self.nativeSettingsLayout.invalidateLayout ~= nil then
        self.nativeSettingsLayout:invalidateLayout()
    end
end

function HelperPersonnelSettingsFrame:drawStandardWageField()
    self.nativeStandardWageFieldArea = nil

    local setting = self:getSettingByKey("standardWage")
    local row = setting ~= nil and self.nativeSettingRows[setting.key] or nil
    local option = setting ~= nil and self.nativeNumberFieldOptions[setting.key] or nil
    if setting == nil or row == nil or option == nil then
        return
    end

    local rowVisible = row.visible ~= false
    if row.getIsVisible ~= nil then
        rowVisible = row:getIsVisible()
    end
    if not rowVisible then
        return
    end

    local width = option.absSize ~= nil and tonumber(option.absSize[1]) or HP_SETTINGS_NUMBER_FIELD_WIDTH
    local height = option.absSize ~= nil and tonumber(option.absSize[2]) or HP_SETTINGS_NUMBER_FIELD_HEIGHT
    width = width ~= nil and width > 0 and width or HP_SETTINGS_NUMBER_FIELD_WIDTH
    height = height ~= nil and height > 0 and height or HP_SETTINGS_NUMBER_FIELD_HEIGHT

    local x = option.absPosition ~= nil and tonumber(option.absPosition[1]) or nil
    local y = option.absPosition ~= nil and tonumber(option.absPosition[2]) or nil
    if x == nil and row.absPosition ~= nil and option.position ~= nil then
        x = (tonumber(row.absPosition[1]) or 0) + (tonumber(option.position[1]) or 0)
    end
    if y == nil and row.absPosition ~= nil and option.position ~= nil then
        y = (tonumber(row.absPosition[2]) or 0) + (tonumber(option.position[2]) or 0)
    end
    x = x or HP_SETTINGS_NUMBER_FIELD_FALLBACK_X
    if y == nil and row.absPosition ~= nil and row.absSize ~= nil then
        y = (tonumber(row.absPosition[2]) or 0) + math.max(0, ((tonumber(row.absSize[2]) or height) - height) * 0.5)
    end
    if y == nil then
        return
    end

    local config = self:getSettingsConfig()
    local available = self:isSettingAvailable(setting)
    local editable = config ~= nil and available and self:canManageCurrentFarm() and self:isServerAuthority()
    local focused = self.settingsSelectedKey == setting.key
    if option.getIsFocused ~= nil and option:getIsFocused() then
        focused = true
    elseif option.getIsHighlighted ~= nil and option:getIsHighlighted() then
        focused = true
    end

    local active = self.standardWageInputActive == true
    local backgroundR = 0.22
    local backgroundG = 0.22
    local backgroundB = 0.22
    local backgroundA = 0.96
    local textR = 0.66
    local textG = 0.66
    local textB = 0.66

    if active then
        backgroundR = 0.65
        backgroundG = 0.72
        backgroundB = 0.29
        textR = 0.25
        textG = 0.28
        textB = 0.16
    elseif focused and editable then
        backgroundR = 0.26
        backgroundG = 0.26
        backgroundB = 0.26
        textR = 0.78
        textG = 0.82
        textB = 0.58
    elseif not editable then
        backgroundR = 0.18
        backgroundG = 0.18
        backgroundB = 0.18
        backgroundA = 0.68
        textR = 0.45
        textG = 0.45
        textB = 0.45
    end

    self:drawSolidRect(x, y, width, height, backgroundR, backgroundG, backgroundB, backgroundA)

    local value = config ~= nil and tonumber(config[setting.field]) or nil
    value = value or (HelperPersonnelConfig ~= nil and HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE or 2500)
    local displayText = tostring(math.floor(value + 0.5))
    if active then
        displayText = tostring(self.standardWageInputBuffer or "")
        if displayText == "" then
            displayText = "_"
        end
    end

    self:drawTextLine(x + width * 0.5, y + height * 0.31, HP_SETTINGS_NUMBER_FIELD_TEXT_SIZE, RenderText.ALIGN_CENTER, displayText, textR, textG, textB, 1, false)
    self.nativeStandardWageFieldArea = { x = x, y = y, width = width, height = height }
end

function HelperPersonnelSettingsFrame:showStandardWageInput(setting)
    local config = self:getSettingsConfig()
    local editable = config ~= nil and self:canManageCurrentFarm() and self:isServerAuthority() and self:isSettingAvailable(setting)
    if not editable then
        self:syncNativeSettings()
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            if not self:isServerAuthority() then
                self.app:showPlayerMessage("ui_pmSettingsHostOnly")
            else
                self.app:showPlayerMessage("ui_pmMenuNoPermission")
            end
        end
        return false
    end

    local currentValue = tonumber(config[setting.field]) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE
    self.settingsSelectedKey = setting.key
    self.standardWageInputActive = true
    self.standardWageInputBuffer = tostring(math.floor(currentValue + 0.5))
    self.standardWageInputReplaceOnType = true
    return true
end

function HelperPersonnelSettingsFrame:cancelStandardWageInput()
    self.standardWageInputActive = false
    self.standardWageInputBuffer = nil
    self.standardWageInputReplaceOnType = false
end

function HelperPersonnelSettingsFrame:commitStandardWageInput()
    if self.standardWageInputActive ~= true then
        return true
    end

    local setting = self:getSettingByKey("standardWage")
    local config = self:getSettingsConfig()
    local editable = config ~= nil and setting ~= nil and self:canManageCurrentFarm() and self:isServerAuthority() and self:isSettingAvailable(setting)
    if not editable then
        self:cancelStandardWageInput()
        self:syncNativeSettings()
        return false
    end

    local numericText = string.gsub(tostring(self.standardWageInputBuffer or ""), "[^0-9]", "")
    local normalized = HelperPersonnelConfig.normalizeStandardBaseMonthlyWage(numericText)
    if normalized == nil then
        local minimum = HelperPersonnelConfig.MIN_STANDARD_BASE_MONTHLY_WAGE
        local maximum = HelperPersonnelConfig.MAX_STANDARD_BASE_MONTHLY_WAGE
        local message = string.format(self:getText("ui_hpSetting_standardWageInvalid", "Gib einen Wert zwischen %d und %d ein. Der Betrag wird auf die nächsten 10 gerundet."), minimum, maximum)
        if InfoDialog ~= nil and InfoDialog.show ~= nil then
            InfoDialog.show(message)
        elseif self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage(message)
        end
        self.standardWageInputReplaceOnType = true
        return false
    end

    config[setting.field] = normalized
    if config.save ~= nil then
        config:save()
    end

    self:cancelStandardWageInput()
    self:syncNativeSettings()
    if self.app ~= nil and g_server ~= nil and self.app.syncNetworkStateToClients ~= nil then
        self.app:syncNetworkStateToClients()
    end
    return true
end

function HelperPersonnelSettingsFrame:onNativeSettingChanged(state, button, setting)
    if setting ~= nil and setting.valueType == "number" then
        self:showStandardWageInput(setting)
        return
    end

    local config = self:getSettingsConfig()
    local editable = config ~= nil and self:canManageCurrentFarm() and self:isServerAuthority() and self:isSettingAvailable(setting)

    if not editable then
        self:syncNativeSettings()
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            if not self:isServerAuthority() then
                self.app:showPlayerMessage("ui_pmSettingsHostOnly")
            else
                self.app:showPlayerMessage("ui_pmMenuNoPermission")
            end
        end
        return
    end

    local newState = tonumber(state)
    if newState == nil and button ~= nil then
        newState = tonumber(button.state)
    end
    if newState == nil then
        newState = 2
    end

    config[setting.field] = newState == 2

    if config.save ~= nil then
        config:save()
    end

    self:syncNativeSettings()

    if self.app ~= nil and g_server ~= nil and self.app.syncNetworkStateToClients ~= nil then
        self.app:syncNetworkStateToClients()
    end
end

function HelperPersonnelSettingsFrame:onFrameOpen()
    HelperPersonnelSettingsFrame:superClass().onFrameOpen(self)
    self.nativeSettingsScrollOffset = 0
    self:buildNativeSettings()
    self:updateNativeSettingsScroll()
    self:syncNativeSettings()
end

function HelperPersonnelSettingsFrame:onFrameClose()
    self:cancelStandardWageInput()
    local config = self:getSettingsConfig()
    if g_server ~= nil and config ~= nil and config.save ~= nil then
        config:save()
    end

    HelperPersonnelSettingsFrame:superClass().onFrameClose(self)
end

function HelperPersonnelSettingsFrame:refresh()
    HelperPersonnelSettingsFrame:superClass().refresh(self)
    self:syncNativeSettings()
end

function HelperPersonnelSettingsFrame:updateNativeSelectedSetting()
    for _, setting in ipairs(self:getSettingsList()) do
        local option = self.nativeSettingElements[setting.key]
        local row = self.nativeSettingRows[setting.key]
        local isFocused = option ~= nil and option.getIsFocused ~= nil and option:getIsFocused()
        local isHighlighted = option ~= nil and option.getIsHighlighted ~= nil and option:getIsHighlighted()
        local rowFocused = row ~= nil and row.getIsFocused ~= nil and row:getIsFocused()
        local rowHighlighted = row ~= nil and row.getIsHighlighted ~= nil and row:getIsHighlighted()
        if isFocused or isHighlighted or rowFocused or rowHighlighted then
            self.settingsSelectedKey = setting.key
            return
        end
    end

    if self.settingsSelectedKey == nil then
        local settings = self:getSettingsList()
        if settings[1] ~= nil then
            self.settingsSelectedKey = settings[1].key
        end
    end
end

function HelperPersonnelSettingsFrame:keyEvent(unicode, sym, modifier, isDown)
    if not self:isCurrentMenuPage() then
        return false
    end

    if self.standardWageInputActive == true then
        if not isDown then
            return true
        end

        if Input ~= nil and sym == Input.KEY_escape then
            self:cancelStandardWageInput()
            return true
        end

        local isConfirm = Input ~= nil and (sym == Input.KEY_return or (Input.KEY_enter ~= nil and sym == Input.KEY_enter))
        if isConfirm then
            self:commitStandardWageInput()
            return true
        end

        if Input ~= nil and Input.KEY_backspace ~= nil and sym == Input.KEY_backspace then
            local buffer = tostring(self.standardWageInputBuffer or "")
            if self.standardWageInputReplaceOnType == true then
                buffer = ""
            elseif #buffer > 0 then
                buffer = string.sub(buffer, 1, #buffer - 1)
            end
            self.standardWageInputBuffer = buffer
            self.standardWageInputReplaceOnType = false
            return true
        end

        if Input ~= nil and Input.KEY_delete ~= nil and sym == Input.KEY_delete then
            self.standardWageInputBuffer = ""
            self.standardWageInputReplaceOnType = false
            return true
        end

        local digit = nil
        if type(unicode) == "number" and unicode >= 48 and unicode <= 57 then
            digit = string.char(unicode)
        elseif type(unicode) == "string" and string.match(unicode, "^[0-9]$") ~= nil then
            digit = unicode
        end

        if digit ~= nil then
            local buffer = tostring(self.standardWageInputBuffer or "")
            if self.standardWageInputReplaceOnType == true then
                buffer = digit
            elseif #buffer < HP_SETTINGS_NUMBER_FIELD_MAX_CHARACTERS then
                buffer = buffer .. digit
            end
            self.standardWageInputBuffer = buffer
            self.standardWageInputReplaceOnType = false
            return true
        end

        return true
    end

    if isDown and Input ~= nil then
        local isEnter = sym == Input.KEY_return or (Input.KEY_enter ~= nil and sym == Input.KEY_enter)
        if isEnter then
            return true
        end

        if self.settingsSelectedKey == "standardWage" and sym == Input.KEY_space then
            local setting = self:getSettingByKey("standardWage")
            if setting ~= nil then
                self:showStandardWageInput(setting)
                return true
            end
        end
    end

    return HelperPersonnelSettingsFrame:superClass().keyEvent(self, unicode, sym, modifier, isDown)
end

function HelperPersonnelSettingsFrame:mouseEvent(posX, posY, isDown, isUp, button, eventUsed)
    if self.nativeSettingsReady == true and eventUsed ~= true then
        local insideStandardWageField = self:isPointInClickArea(posX, posY, self.nativeStandardWageFieldArea)
        if isDown and hpSettingsIsLeftMouseButton(button) and insideStandardWageField then
            local setting = self:getSettingByKey("standardWage")
            if setting ~= nil then
                self.settingsSelectedKey = setting.key
                if self.standardWageInputActive ~= true then
                    self:showStandardWageInput(setting)
                end
                return true
            end
        elseif isDown and hpSettingsIsLeftMouseButton(button) and self.standardWageInputActive == true then
            if not self:commitStandardWageInput() then
                return true
            end
        end

        local insideScrollArea = self:isPointInClickArea(posX, posY, self.nativeSettingsScrollArea)
        local insideScrollbar = self:isPointInClickArea(posX, posY, self.nativeSettingsScrollbarArea)

        if insideScrollArea or insideScrollbar then
            if self:isMouseWheelUp(button) then
                return self:scrollNativeSettings(-1)
            elseif self:isMouseWheelDown(button) then
                return self:scrollNativeSettings(1)
            end
        end

        if isDown and insideScrollbar then
            self.nativeSettingsScrollbarDragging = true
            self:setNativeSettingsScrollFromMouseY(posY)
            return true
        end

        if self.nativeSettingsScrollbarDragging == true then
            self:setNativeSettingsScrollFromMouseY(posY)
            if isUp then
                self.nativeSettingsScrollbarDragging = false
            end
            return true
        end
    elseif isUp then
        self.nativeSettingsScrollbarDragging = false
    end

    return HelperPersonnelSettingsFrame:superClass().mouseEvent(self, posX, posY, isDown, isUp, button, eventUsed)
end

function HelperPersonnelSettingsFrame:draw()
    if self.nativeSettingsReady == true then
            HelperPersonnelViewBase:superClass().draw(self)
        self:updateNativeSelectedSetting()
        local title = self:getText(self.pageTitleKey, self.pageTitleFallback)
        self:drawTextLine(0.22, 0.850, 0.030, RenderText.ALIGN_LEFT, title, 1, 1, 1, 1, true)

        local selectedSetting = self:getSelectedSetting()
        local selectedRow = selectedSetting ~= nil and self.nativeSettingRows[selectedSetting.key] or nil
        local descriptionY = 0.500
        if selectedRow ~= nil and selectedRow.absPosition ~= nil and selectedRow.absSize ~= nil then
            descriptionY = (selectedRow.absPosition[2] or descriptionY) + (selectedRow.absSize[2] or 0) * 0.5
        end

        self.settingsDescriptionX = 0.605
        self.settingsDescriptionWidth = 0.300
        self.settingsDescriptionY = math.max(0.265, math.min(0.735, descriptionY))
        self:drawSettingsDescription(selectedSetting)
        self:drawStandardWageField()

        local scrollState = self:getNativeSettingsScrollState()
        self.nativeSettingsScrollArea = { x = 0.145, y = HP_SETTINGS_SCROLL_Y, width = 0.435, height = HP_SETTINGS_SCROLL_HEIGHT }
        self.nativeSettingsScrollbarArea = nil
        if scrollState.maxOffset > 0 then
            self.nativeSettingsScrollbarArea = { x = HP_SETTINGS_SCROLL_X - 0.012, y = HP_SETTINGS_SCROLL_Y, width = HP_SETTINGS_SCROLL_WIDTH + 0.024, height = HP_SETTINGS_SCROLL_HEIGHT }
            self:drawDetailScrollbar(HP_SETTINGS_SCROLL_X, HP_SETTINGS_SCROLL_Y, HP_SETTINGS_SCROLL_WIDTH, HP_SETTINGS_SCROLL_HEIGHT, scrollState.offset + 1, scrollState.visibleCount, scrollState.itemCount)
        end
    else
        HelperPersonnelSettingsFrame:superClass().draw(self)
    end
end
