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

HelperPersonnelHelpFrame = {}
local HelperPersonnelHelpFrame_mt = Class(HelperPersonnelHelpFrame, HelperPersonnelMenuPage)
local HP_HELP_LANGUAGE_CODES = {
    cs = true, cz = true, da = true, de = true, en = true, es = true, fi = true,
    fr = true, hu = true, it = true, jp = true, kr = true, no = true, pl = true,
    pt = true, ro = true, ru = true, sv = true, tr = true, uk = true, vi = true
}

local HP_HELP_LANGUAGE_ALIASES = {
    ja = "jp",
    ko = "kr",
    nb = "no"
}

function HelperPersonnelHelpFrame.new(target, customMt)
    local self = HelperPersonnelMenuPage.new("help", customMt or HelperPersonnelHelpFrame_mt)

    self.helpSelectedTopic = 1
    self.helpCachedTopics = nil
    self.helpCachedLanguageCode = nil
    self.helpCachedTexts = nil

    return self
end

function HelperPersonnelHelpFrame:applyPageKind()
    self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
    self.pageTitleKey = "ui_pmMenuPageHelp"
    self.pageTitleFallback = "ui_pmMenuPageHelp"
end

function HelperPersonnelHelpFrame:updateButtons()
    if self.btnClose == nil then
        self:createButtonInfo()
    end

    self.btnClose.text = self:getText("ui_button_back", "ui_button_back")
    self.btnPrevTab.text = self:getText("ui_hpIngameMenuPrev", "ui_hpIngameMenuPrev")
    self.btnNextTab.text = self:getText("ui_hpIngameMenuNext", "ui_hpIngameMenuNext")
    self:applyMenuButtons({self.btnClose, self.btnPrevTab, self.btnNextTab})
end

function HelperPersonnelHelpFrame:getHelpLanguageCode()
    local candidates = {g_languageShort, g_languageSuffix}
    if g_i18n ~= nil then
        table.insert(candidates, g_i18n.languageCode)
        table.insert(candidates, g_i18n.currentLanguage)
        table.insert(candidates, g_i18n.languageShort)
        if g_i18n.getLanguageCode ~= nil then
            local success, languageCode = pcall(g_i18n.getLanguageCode, g_i18n)
            if success then
                table.insert(candidates, languageCode)
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        local languageCode = string.lower(tostring(candidate or ""))
        languageCode = string.match(languageCode, "^([a-z][a-z])")
        languageCode = HP_HELP_LANGUAGE_ALIASES[languageCode] or languageCode
        if languageCode ~= nil and HP_HELP_LANGUAGE_CODES[languageCode] == true then
            return languageCode
        end
    end

    return "en"
end

function HelperPersonnelHelpFrame:getHelpTexts(languageCode)
    if self.helpCachedTexts ~= nil and self.helpCachedLanguageCode == languageCode then
        return self.helpCachedTexts
    end

    local texts = {}
    local modDir = self.app ~= nil and self.app.modDir or g_currentModDirectory
    local filename = modDir ~= nil and Utils.getFilename("i18n/l10n_" .. languageCode .. ".xml", modDir) or nil
    local xmlFile = filename ~= nil and fileExists(filename) and XMLFile.loadIfExists("helperPersonnelHelp", filename) or nil
    if xmlFile ~= nil then
        local index = 0
        while true do
            local entryKey = string.format("l10n.elements.e(%d)", index)
            if not xmlFile:hasProperty(entryKey) then
                break
            end
            local key = xmlFile:getString(entryKey .. "#k")
            if key == "ui_pmMenuPageHelp" or key == "ui_pmHelpContents" or key == "ui_pmHelpNavigation" or string.find(key or "", "ui_pmHelpTopic", 1, true) == 1 then
                texts[key] = xmlFile:getString(entryKey .. "#v", "")
            end
            index = index + 1
        end
        xmlFile:delete()
    end

    self.helpCachedTexts = texts
    self.helpCachedLanguageCode = languageCode
    return texts
end

function HelperPersonnelHelpFrame:getHelpText(key, fallback)
    local texts = self:getHelpTexts(self:getHelpLanguageCode())
    return texts[key] or self:getText(key, fallback)
end

function HelperPersonnelHelpFrame:getHelpTopics()
    local languageCode = self:getHelpLanguageCode()
    if self.helpCachedTopics ~= nil and self.helpCachedLanguageCode == languageCode then
        return self.helpCachedTopics
    end

    local texts = self:getHelpTexts(languageCode)
    local topics = {}
    local topicOrder = languageCode == "de" and {1, 2, 3, 15, 4, 5, 16, 6, 7, 8, 9, 10, 11, 12, 13, 14} or {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
    local iconIndexBySourceIndex = {
        [1] = 1, [2] = 2, [3] = 3, [15] = 4,
        [4] = 5, [5] = 6, [16] = 7, [6] = 8,
        [7] = 9, [8] = 10, [9] = 11, [10] = 12,
        [11] = 13, [12] = 14, [13] = 15, [14] = 16
    }
    for _, sourceIndex in ipairs(topicOrder) do
        local suffix = string.format("%02d", sourceIndex)
        local titleKey = "ui_pmHelpTopic" .. suffix .. "Title"
        local bodyKey = "ui_pmHelpTopic" .. suffix .. "Body"
        local title = texts[titleKey]
        local body = texts[bodyKey]
        if title ~= nil and body ~= nil then
            table.insert(topics, {
                title = title,
                body = body,
                iconIndex = iconIndexBySourceIndex[sourceIndex]
            })
        end
    end

    self.helpCachedTopics = topics
    self.helpCachedLanguageCode = languageCode
    return topics
end

function HelperPersonnelHelpFrame:onGuiSetupFinished()
    HelperPersonnelHelpFrame:superClass().onGuiSetupFinished(self)
end

function HelperPersonnelHelpFrame:onFrameOpen()
    HelperPersonnelHelpFrame:superClass().onFrameOpen(self)
    if self.helpTopicList == nil then
        return
    end

    local topics = self:getHelpTopics()
    self.helpSelectedTopic = math.max(1, math.min(self.helpSelectedTopic or 1, math.max(#topics, 1)))
    self.helpTopicList:reloadData()
    self:setSoundSuppressed(true)
    FocusManager:setFocus(self.helpTopicList)
    self:setSoundSuppressed(false)
    self.helpArticleLayout:registerActionEvents()
    self:updateNativeHelpArticle(self.helpSelectedTopic)
end

function HelperPersonnelHelpFrame:onFrameClose()
    if self.helpArticleLayout ~= nil then
        self.helpArticleLayout:removeActionEvents()
    end
    HelperPersonnelHelpFrame:superClass().onFrameClose(self)
end

function HelperPersonnelHelpFrame:getNumberOfSections(list)
    return 1
end

function HelperPersonnelHelpFrame:getNumberOfItemsInSection(list, section)
    return #self:getHelpTopics()
end

function HelperPersonnelHelpFrame:getTitleForSectionHeader(list, section)
    return self:getHelpText("ui_pmHelpContents", "INHALT")
end

function HelperPersonnelHelpFrame:populateCellForItemInSection(list, section, index, cell)
    local topic = self:getHelpTopics()[index]
    if topic == nil then
        return
    end
    local title = cell:getAttribute("title")
    if title ~= nil then
        title:setText(string.upper(topic.title))
    end
    local icon = cell:getAttribute("icon")
    if icon ~= nil then
        icon:setImageFilename(Utils.getFilename(string.format("gui/icons/help/help_topic_%02d.png", topic.iconIndex or index), self.app.modDir))
        icon:setVisible(true)
    end
end

function HelperPersonnelHelpFrame:onListSelectionChanged(list, section, index)
    if index == nil or index < 1 then
        return
    end
    self.helpSelectedTopic = index
    self:updateNativeHelpArticle(index)
end

function HelperPersonnelHelpFrame:updateNativeHelpArticle(topicIndex)
    if self.helpArticleLayout == nil or self.helpArticleTitleTemplate == nil or self.helpArticleTextTemplate == nil then
        return
    end

    self.helpArticleTitleTemplate:unlinkElement()
    self.helpArticleTextTemplate:unlinkElement()
    for index = #self.helpArticleLayout.elements, 1, -1 do
        self.helpArticleLayout.elements[index]:delete()
    end

    local topic = self:getHelpTopics()[topicIndex]
    if topic == nil then
        self.helpArticleLayout:invalidateLayout()
        return
    end

    local title = self.helpArticleTitleTemplate:clone(self.helpArticleLayout)
    title:setText(string.upper(topic.title))

    local body = tostring(topic.body or "")
    for paragraph in string.gmatch(body .. "\n", "(.-)\n") do
        if paragraph ~= "" then
            local row = self.helpArticleTextTemplate:clone(self.helpArticleLayout)
            local text = row:getDescendantByName("textFullWidth")
            if text ~= nil then
                text:setText(paragraph)
                local height = text:getTextHeight(true)
                text:setSize(nil, height)
                row:setSize(nil, height)
            end
            row:invalidateLayout()
        end
    end

    self.helpArticleLayout:invalidateLayout()
end

function HelperPersonnelHelpFrame:keyEvent(unicode, sym, modifier, isDown)
    return HelperPersonnelHelpFrame:superClass().keyEvent(self, unicode, sym, modifier, isDown)
end

function HelperPersonnelHelpFrame:mouseEvent(posX, posY, isDown, isUp, button, eventUsed)
    return HelperPersonnelHelpFrame:superClass().mouseEvent(self, posX, posY, isDown, isUp, button, eventUsed)
end

function HelperPersonnelHelpFrame:draw()
    HelperPersonnelHelpFrame:superClass().draw(self)
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

local function hpSettingsSetText(element, value)
    if element ~= nil and element.setText ~= nil then
        element:setText(value or "")
    end
end

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

    if HelperPersonnelGameSettings == nil or self.settingsLayout == nil then
        return false
    end

    self.nativeSettingsBuildAttempted = true
    self.nativeSettingsLayout = self.settingsLayout

    local offText = self:getText("ui_hpSetting_off", "Aus")
    local onText = self:getText("ui_hpSetting_on", "An")
    for _, setting in ipairs(self:getSettingsList()) do
        local option = self["setting" .. string.upper(string.sub(setting.key, 1, 1)) .. string.sub(setting.key, 2)]
        if option ~= nil then
            self.nativeSettingElements[setting.key] = option
            self.nativeSettingRows[setting.key] = option
            setting.element = option
            if setting.valueType ~= "number" then
                option:setTexts({offText, onText})
            end
            if self.settingsSelectedKey == nil then
                self.settingsSelectedKey = setting.key
            end
        end
    end

    self.nativeSettingsReady = next(self.nativeSettingElements) ~= nil
    if self.nativeSettingsLayout ~= nil and self.nativeSettingsLayout.invalidateLayout ~= nil then
        self.nativeSettingsLayout:invalidateLayout()
    end
    if self.settingsSlider ~= nil and self.settingsSlider.setDataElement ~= nil then
        self.settingsSlider:setDataElement(self.nativeSettingsLayout)
    end
    if self.settingsSliderBox ~= nil and self.settingsSliderBox.setVisible ~= nil then
        self.settingsSliderBox:setVisible(true)
    end
    if self.settingsLayout ~= nil then
        self:registerFocusElement(self.settingsLayout, true)
    end
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
                local value = config ~= nil and tonumber(config[setting.field]) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE
                if option.setText ~= nil then option:setText(tostring(math.floor(value + 0.5))) end
                if option.setDisabled ~= nil then option:setDisabled(not editable) end
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
    self:updateStaticSettingsInfo()
end

function HelperPersonnelSettingsFrame:onCreateStaticSettingRow(row)
    hpSettingsSetTransparentRow(row)
    local option = hpSettingsFindFirstByType(row, "BinaryOption") or hpSettingsFindFirstByType(row, "TextInput")
    local setting = option ~= nil and self:getSettingByKey(option.name) or nil
    local label = hpSettingsFindLabel(row)
    if setting ~= nil and label ~= nil then
        local labelText = self:getSettingText(setting, "labelKey", setting.key)
        local compact = string.match(labelText, "^[^:]+:%s*(.+)$")
        hpSettingsSetText(label, compact ~= nil and compact or labelText)
    end
    if setting ~= nil and option ~= nil and option.getDescendantByName ~= nil then
        local tooltip = option:getDescendantByName("tooltip")
        hpSettingsSetText(tooltip, self:getSettingText(setting, "descriptionKey", ""))
    end
end

function HelperPersonnelSettingsFrame:onStaticSettingFocused(element)
    local setting = element ~= nil and self:getSettingByKey(element.name) or nil
    if setting ~= nil then
        self.settingsSelectedKey = setting.key
        self:updateStaticSettingsInfo()
    end
end

function HelperPersonnelSettingsFrame:onStaticSettingChanged(state, element)
    local setting = element ~= nil and self:getSettingByKey(element.name) or nil
    if setting == nil then return end
    self.settingsSelectedKey = setting.key
    self:onNativeSettingChanged(state, element, setting)
end

function HelperPersonnelSettingsFrame:onStandardWageEnterPressed(element, isClick)
    if isClick == true then return end
    self:onStandardWageClicked(element)
end

function HelperPersonnelSettingsFrame:onStandardWageClicked(state, element)
    if element == nil and type(state) == "table" then
        element = state
    end
    element = element or self.settingStandardWage
    self:onStaticSettingFocused(element)
    local setting = self:getSettingByKey("standardWage")
    local config = self:getSettingsConfig()
    local editable = setting ~= nil and config ~= nil and self:canManageCurrentFarm() and self:isServerAuthority() and self:isSettingAvailable(setting)
    if not editable then
        self:syncNativeSettings()
        return
    end

    if TextInputDialog == nil or TextInputDialog.show == nil then
        return
    end

    local value = tostring(math.floor((tonumber(config[setting.field]) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE) + 0.5))
    local title = self:getSettingText(setting, "labelKey", "Standard-Monatsgehalt")
    TextInputDialog.show(HelperPersonnelSettingsFrame.onStandardWageDialogClosed, self, value, title, title, HP_SETTINGS_NUMBER_FIELD_MAX_CHARACTERS, self:getText("button_ok", "OK"))
end

function HelperPersonnelSettingsFrame:onStandardWageDialogClosed(text, clickOk)
    if clickOk ~= true then
        self:syncNativeSettings()
        return
    end

    local setting = self:getSettingByKey("standardWage")
    local config = self:getSettingsConfig()
    local editable = setting ~= nil and config ~= nil and self:canManageCurrentFarm() and self:isServerAuthority() and self:isSettingAvailable(setting)
    if not editable then
        self:syncNativeSettings()
        return
    end

    local normalized = HelperPersonnelConfig.normalizeStandardBaseMonthlyWage(text or "")
    if normalized == nil then
        if InfoDialog ~= nil and InfoDialog.show ~= nil then
            InfoDialog.show(self:getText("ui_hpSetting_standardWageInvalid", "Ungültiger Monatslohn."))
        end
        self:syncNativeSettings()
        return
    end

    config[setting.field] = normalized
    if config.save ~= nil then config:save() end
    self:syncNativeSettings()
    if self.app ~= nil and g_server ~= nil and self.app.syncNetworkStateToClients ~= nil then
        self.app:syncNetworkStateToClients()
    end
end

function HelperPersonnelSettingsFrame:onStandardWageEscPressed()
    self:cancelStandardWageInput()
    self:syncNativeSettings()
end

function HelperPersonnelSettingsFrame:updateStaticSettingsInfo()
    if self.settingsPermission ~= nil then
        hpSettingsSetText(self.settingsPermission, self:getText("ui_pmSettingsHostOnly", "Diese Einstellungen können nur vom Host geändert werden."))
        self.settingsPermission:setVisible(not self:isServerAuthority() or not self:canManageCurrentFarm())
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
    self:updateNativeStandardWageInputText()
    return true
end

function HelperPersonnelSettingsFrame:updateNativeStandardWageInputText()
    local option = self.nativeSettingElements ~= nil and self.nativeSettingElements.standardWage or nil
    if option ~= nil and option.setText ~= nil then
        option:setText(tostring(self.standardWageInputBuffer or ""))
    end
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
            self:updateNativeStandardWageInputText()
            return true
        end

        if Input ~= nil and Input.KEY_delete ~= nil and sym == Input.KEY_delete then
            self.standardWageInputBuffer = ""
            self.standardWageInputReplaceOnType = false
            self:updateNativeStandardWageInputText()
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
            self:updateNativeStandardWageInputText()
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
        self:updateStaticSettingsInfo()
    else
        HelperPersonnelSettingsFrame:superClass().draw(self)
    end
end


