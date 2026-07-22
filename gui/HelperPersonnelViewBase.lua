HelperPersonnelViewBase = {}
local HelperPersonnelViewBase_mt = Class(HelperPersonnelViewBase, TabbedMenuFrameElement)

HelperPersonnelViewBase.PORTRAIT_FILENAMES = {

    [1] = "dataS/character/playerM/heads/mHead01.png",
    [2] = "dataS/character/playerM/heads/mHead02.png",
    [3] = "dataS/character/playerF/heads/fHead01.png",
    [4] = "dataS/character/playerF/heads/fHead02.png",
    [5] = "dataS/character/playerM/heads/mHead03.png",
    [6] = "dataS/character/playerF/heads/fHead03.png",
    [7] = "dataS/character/playerM/heads/mHead04.png",
    [8] = "dataS/character/playerM/heads/mHead05.png",
    [9] = "dataS/character/playerF/heads/fHead04.png",
    [10] = "dataS/character/playerM/heads/mHead06.png"
}

local function hpClamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end

    return value
end

local function hpTrim(text)
    return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

HelperPersonnelViewBase.MODE_OVERVIEW = 1
HelperPersonnelViewBase.MODE_WORKERS = 2
HelperPersonnelViewBase.MODE_APPLICANTS = 3

HelperPersonnelViewBase.DETAIL_VISIBLE_COUNT = 4
HelperPersonnelViewBase.DETAIL_ROW_HEIGHT = 0.114
HelperPersonnelViewBase.DETAIL_ROW_STEP = 0.119
HelperPersonnelViewBase.WORKER_DETAIL_ROW_HEIGHT = 0.128
HelperPersonnelViewBase.WORKER_DETAIL_ROW_STEP = 0.132
HelperPersonnelViewBase.DETAIL_TEXT_SIZE = 0.0106
HelperPersonnelViewBase.DETAIL_TEXT_LINE_STEP = 0.014
HelperPersonnelViewBase.OVERVIEW_HISTORY_VISIBLE_ROWS = 8
HelperPersonnelViewBase.OVERVIEW_HISTORY_LINE_HEIGHT = 0.0129
HelperPersonnelViewBase.OVERVIEW_HISTORY_ENTRY_GAP = 0.0025

HelperPersonnelViewBase.FIELD_DETECTION_DEBUG_LOGGING = false
HelperPersonnelViewBase.FIELD_DETECTION_CACHE_MS = 3000

local function hpGetInputAction(actionName, fallback)
    if InputAction ~= nil and InputAction[actionName] ~= nil then
        return InputAction[actionName]
    end

    if fallback ~= nil then
        return fallback
    end

    return actionName
end

local function hpGetInputConstant(name, fallback)
    if Input ~= nil and Input[name] ~= nil then
        return Input[name]
    end

    if _G ~= nil and _G[name] ~= nil then
        return _G[name]
    end

    return fallback
end

local function hpApplyPausedButton(button)

    if button ~= nil then
        button.showWhenPaused = true
    end

    return button
end

local function hpGetAspectCorrectWidth(height)
    local screenWidth = tonumber(g_screenWidth) or 1
    local screenHeight = tonumber(g_screenHeight) or 1
    if screenWidth <= 0 or screenHeight <= 0 then
        return height
    end

    return height * (screenHeight / screenWidth)
end

local function hpGetAspectCorrectSquare(maxWidth, maxHeight)
    local widthFromHeight = hpGetAspectCorrectWidth(maxHeight)
    if widthFromHeight <= maxWidth then
        return widthFromHeight, maxHeight
    end

    local screenWidth = tonumber(g_screenWidth) or 1
    local screenHeight = tonumber(g_screenHeight) or 1
    if screenWidth <= 0 or screenHeight <= 0 then
        return maxWidth, maxHeight
    end

    local heightFromWidth = maxWidth * (screenWidth / screenHeight)
    return maxWidth, math.min(maxHeight, heightFromWidth)
end

function HelperPersonnelViewBase.new(subclass_mt, messageCenter)
    local self = TabbedMenuFrameElement.new(nil, subclass_mt or HelperPersonnelViewBase_mt)

    self.app = nil
    self.messageCenter = messageCenter
    self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
    self.workerIndex = 1
    self.applicantIndex = 1

    self.inputActionEventIds = {}
    self.clickAreas = {}
    self.fieldDetectionCache = {}
    self.applicantListFirstIndex = 1
    self.workerListFirstIndex = 1
    self.detailListMouseArea = nil
    self.detailScrollbarMouseArea = nil
    self.detailScrollbarDragging = false
    self.overviewHistoryFirstRow = 1
    self.overviewHistoryRows = {}
    self.overviewHistoryMouseArea = nil
    self.overviewHistoryScrollbarMouseArea = nil
    self.overviewHistoryScrollbarDragging = false

    self.uiScale = g_gameSettings:getValue("uiScale") or 1
    self.lineOverlay = nil
    self.portraitOverlays = {}
    self.portraitCount = #HelperPersonnelViewBase.PORTRAIT_FILENAMES

    self.btnBack = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_button_back", "Zurück"),
        callback = function()
            return self:onClickBack()
        end
    }

    self.btnBackToOverview = {

        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_backToOverview", "Zur Übersicht"),
        callback = function()
            return self:onClickBack()
        end
    }

    self.btnPagePrev = {
        inputAction = InputAction.MENU_PAGE_PREV,
        text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü"),
        callback = function()
            return self:onClickPagePrevious()
        end
    }

    self.btnPageNext = {
        inputAction = InputAction.MENU_PAGE_NEXT,
        text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü"),
        callback = function()
            return self:onClickPageNext()
        end
    }

    self.btnOpenWorkers = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_openWorkerView", "Mitarbeiter"),
        callback = function()
            self:onClickActivate()
        end
    }

    self.btnOpenApplicants = hpApplyPausedButton({
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_openApplicantView", "Bewerbermarkt"),
        callback = function()
            self:onClickExtra1()
        end
    })

    self.btnExecute = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_button_hire", "Einstellen"),
        callback = function()
            self:onClickActivate()
        end
    }

    return self
end

function HelperPersonnelViewBase:setContext(app)
    self.app = app

    if app ~= nil then
        self.inGameMenu = app.inGameMenu
    end

    if self.lineOverlay ~= nil then
        self.lineOverlay:delete()
        self.lineOverlay = nil
    end

    if self.iconOverlay ~= nil then
        self.iconOverlay:delete()
        end

    self:deletePortraitOverlays()

    if self.app ~= nil and self.app.modDir ~= nil then
        self.lineOverlay = Overlay.new(Utils.getFilename("gui/solidPixel.dds", self.app.modDir), 0, 0, 1, 1)
        self:loadPortraitOverlays()
    end
end

function HelperPersonnelViewBase:delete()
    if self.lineOverlay ~= nil then
        self.lineOverlay:delete()
        self.lineOverlay = nil
    end

    if self.iconOverlay ~= nil then
        self.iconOverlay:delete()
        end

    self:deletePortraitOverlays()

    HelperPersonnelViewBase:superClass().delete(self)
end

function HelperPersonnelViewBase:onFrameOpen()
    HelperPersonnelViewBase:superClass().onFrameOpen(self)

    if self.app ~= nil then
        self.inGameMenu = self.app.inGameMenu
    end

    self.mode = HelperPersonnelViewBase.MODE_OVERVIEW

    self:refresh()
    self:updateButtons()
end

function HelperPersonnelViewBase:onFrameClose()

    self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
    HelperPersonnelViewBase:superClass().onFrameClose(self)
end

function HelperPersonnelViewBase:copyAttributes(src)
    HelperPersonnelViewBase:superClass().copyAttributes(self, src)
end

function HelperPersonnelViewBase:initialize() end
function HelperPersonnelViewBase:onGuiSetupFinished() end

function HelperPersonnelViewBase:registerActionEvents()
end

function HelperPersonnelViewBase:unregisterActionEvents()
end

function HelperPersonnelViewBase:onInputConfirm(_, inputValue)
    if inputValue ~= 1 then
        return
    end

    if self.mode == HelperPersonnelViewBase.MODE_OVERVIEW then
        self:showWorkersView()
    else
        self:activateCurrentEntry()
    end
end

function HelperPersonnelViewBase:onInputCancel(_, inputValue)
    if inputValue ~= 1 then
        return
    end

    self:onClickBack()
end

function HelperPersonnelViewBase:onClickActivate()
    if self.mode == HelperPersonnelViewBase.MODE_OVERVIEW then
        self:showWorkersView()
    else
        self:activateCurrentEntry()
    end
end

function HelperPersonnelViewBase:onClickExtra1()
    if self.mode == HelperPersonnelViewBase.MODE_OVERVIEW then
        self:showApplicantsView()
    else
        self:showOverview()
    end
end

function HelperPersonnelViewBase:getInGameMenu()
    local inGameMenu = self.inGameMenu

    if inGameMenu == nil and self.app ~= nil then
        inGameMenu = self.app.inGameMenu
    end

    if inGameMenu == nil then
        inGameMenu = g_inGameMenu
    end

    return inGameMenu
end

function HelperPersonnelViewBase:onClickBack()
    if self.mode ~= HelperPersonnelViewBase.MODE_OVERVIEW then
        self:showOverview()
        return true
    end

    local inGameMenu = self:getInGameMenu()

    if inGameMenu ~= nil and inGameMenu.exitMenu ~= nil then
        inGameMenu:exitMenu()
        return true
    end

    return false
end

function HelperPersonnelViewBase:onClickPagePrevious()
    local inGameMenu = self:getInGameMenu()

    if inGameMenu ~= nil and inGameMenu.onPagePrevious ~= nil then
        inGameMenu:onPagePrevious()
        return true
    end

    return false
end

function HelperPersonnelViewBase:onClickPageNext()
    local inGameMenu = self:getInGameMenu()

    if inGameMenu ~= nil and inGameMenu.onPageNext ~= nil then
        inGameMenu:onPageNext()
        return true
    end

    return false
end

function HelperPersonnelViewBase:showOverview()
    self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
    self:updateButtons()
end

function HelperPersonnelViewBase:showWorkersView()
    local workers = self:getWorkers()
    if #workers == 0 then
        return
    end

    self.mode = HelperPersonnelViewBase.MODE_WORKERS
    self.workerIndex = hpClamp(self.workerIndex, 1, #workers)
    self:updateButtons()
end

function HelperPersonnelViewBase:showApplicantsView()
    local applicants = self:getApplicants()
    if #applicants == 0 then
        return
    end

    self.mode = HelperPersonnelViewBase.MODE_APPLICANTS
    self.applicantIndex = hpClamp(self.applicantIndex, 1, #applicants)
    self:updateButtons()
end

function HelperPersonnelViewBase:activateCurrentEntry()
    local manager = self:getManager()
    if manager == nil then
        return
    end

    if self.mode == HelperPersonnelViewBase.MODE_WORKERS then
        local workers = self:getWorkers()
        if #workers == 0 then
            self:showOverview()
            return
        end

        local worker = workers[self.workerIndex]
        if self.app ~= nil and self.app.requestDismissWorker ~= nil then
            self.app:requestDismissWorker(worker.id)
        else
            manager:dismissWorker(worker.id)
        end
        workers = self:getWorkers()

        if #workers == 0 then
            self:showOverview()
        else
            self.workerIndex = hpClamp(self.workerIndex, 1, #workers)
        end
    elseif self.mode == HelperPersonnelViewBase.MODE_APPLICANTS then
        local applicants = self:getApplicants()
        if #applicants == 0 then
            self:showOverview()
            return
        end

        local applicant = applicants[self.applicantIndex]
        if self.app ~= nil and self.app.requestHireApplicant ~= nil then
            self.app:requestHireApplicant(applicant.id)
        else
            manager:hireApplicant(applicant.id)
        end
        applicants = self:getApplicants()

        if #applicants == 0 then
            self:showOverview()
        else
            self.applicantIndex = hpClamp(self.applicantIndex, 1, #applicants)
        end
    end

    self:refresh()
    self:updateButtons()
end

function HelperPersonnelViewBase:refresh()
    local workers = self:getWorkers()
    local applicants = self:getApplicants()

    if self.mode == HelperPersonnelViewBase.MODE_WORKERS and #workers == 0 then
        self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
    elseif self.mode == HelperPersonnelViewBase.MODE_APPLICANTS and #applicants == 0 then
        self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
    end

    self.workerIndex = hpClamp(self.workerIndex, 1, math.max(#workers, 1))
    self.applicantIndex = hpClamp(self.applicantIndex, 1, math.max(#applicants, 1))

    self:updateButtons()
end

function HelperPersonnelViewBase:applyMenuButtons(buttons)
    buttons = buttons or {}

    self.menuButtonInfo = buttons

    if self.setMenuButtonInfo ~= nil then
        pcall(self.setMenuButtonInfo, self, buttons)
    end

    local inGameMenu = self:getInGameMenu()
    local assignedDirectly = false

    if inGameMenu ~= nil and inGameMenu.currentPage == self and inGameMenu.assignMenuButtonInfo ~= nil then
        local ok = pcall(inGameMenu.assignMenuButtonInfo, inGameMenu, buttons)
        assignedDirectly = ok == true
    end

    if assignedDirectly then
        if self.clearMenuButtonInfoDirty ~= nil then
            self:clearMenuButtonInfoDirty()
        end
    elseif self.setMenuButtonInfoDirty ~= nil then
        self:setMenuButtonInfoDirty()
    end

end

function HelperPersonnelViewBase:updateButtons()
    local buttons = {}

    self.btnBack.text = self:getText("ui_button_back", "Zurück")
    self.btnBackToOverview.text = self:getText("ui_backToOverview", "Zur Übersicht")
    self.btnBackToOverview.inputAction = InputAction.MENU_BACK
    self.btnPagePrev.text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü")
    self.btnPageNext.text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü")
    self.btnOpenWorkers.inputAction = InputAction.MENU_ACCEPT
    self.btnOpenApplicants.inputAction = InputAction.MENU_ACCEPT
    self.btnExecute.inputAction = InputAction.MENU_ACCEPT
    hpApplyPausedButton(self.btnOpenApplicants)
    self.btnOpenWorkers.disabled = #self:getWorkers() == 0
    self.btnOpenApplicants.disabled = #self:getApplicants() == 0
    self.btnExecute.text = self.mode == HelperPersonnelViewBase.MODE_APPLICANTS and self:getText("ui_button_hire", "Einstellen") or self:getText("ui_button_fire", "Entlassen")
    self.btnExecute.disabled = false

    if self.mode == HelperPersonnelViewBase.MODE_OVERVIEW then
        table.insert(buttons, self.btnBack)
        table.insert(buttons, self.btnPagePrev)
        table.insert(buttons, self.btnPageNext)
        table.insert(buttons, self.btnOpenWorkers)
        table.insert(buttons, self.btnOpenApplicants)
    else
        table.insert(buttons, self.btnBackToOverview)
        table.insert(buttons, self.btnPagePrev)
        table.insert(buttons, self.btnPageNext)
        table.insert(buttons, self.btnExecute)
    end

    self:applyMenuButtons(buttons)
end

function HelperPersonnelViewBase:getMenuButtonInfo()
    return self.menuButtonInfo or {}
end

function HelperPersonnelViewBase:getText(key, fallback)
    if g_i18n ~= nil then
        local text = g_i18n:getText(key)
        if text ~= nil and text ~= key then
            return text
        end
    end

    return fallback
end

function HelperPersonnelViewBase:formatText(key, fallback, ...)
    local text = self:getText(key, fallback)
    if select("#", ...) > 0 then
        local ok, formattedText = pcall(string.format, text, ...)
        if ok and formattedText ~= nil then
            return formattedText
        end

        if fallback ~= nil and fallback ~= text then
            ok, formattedText = pcall(string.format, fallback, ...)
            if ok and formattedText ~= nil then
                return formattedText
            end
        end
    end

    return text
end

function HelperPersonnelViewBase:getManager()
    return self.app ~= nil and self.app.manager or nil
end

function HelperPersonnelViewBase:getWorkers()
    local manager = self:getManager()
    if manager == nil then
        return {}
    end

    return manager:getWorkersSorted()
end

function HelperPersonnelViewBase:getApplicants()
    local manager = self:getManager()
    if manager == nil then
        return {}
    end

    return manager:getApplicantsSorted()
end

function HelperPersonnelViewBase:isWorkerActive(worker)
    if type(worker) ~= "table" then
        return false
    end

    if worker.busy == true or worker.isBusy == true or worker.isAssigned == true then
        return true
    end

    local workerId = tonumber(worker.id)
    if workerId ~= nil and self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.hasActiveJobForWorker ~= nil then
        local ok, isActive = pcall(function()
            return self.app.helperBridge:hasActiveJobForWorker(workerId)
        end)

        if ok and isActive == true then
            return true
        end
    end

    return false
end

function HelperPersonnelViewBase:getActiveWorkerEntries(workers)
    local activeWorkers = {}

    for index, worker in ipairs(workers or {}) do
        if self:isWorkerActive(worker) then
            table.insert(activeWorkers, {
                worker = worker,
                sourceIndex = index
            })
        end
    end

    return activeWorkers
end

function HelperPersonnelViewBase:shortenText(text, maxLength)
    text = tostring(text or "")
    maxLength = math.max(4, math.floor((tonumber(maxLength) or 60) + 0.5))

    if string.len(text) <= maxLength then
        return text
    end

    return string.sub(text, 1, maxLength - 3) .. "..."
end

function HelperPersonnelViewBase:stripRuntimeHelperSuffix(value)
    if value == nil then
        return nil
    end

    local text = tostring(value)
    text = string.gsub(text, "%s*%(([^%)]*)%)", function(inner)
        local lowerInner = string.lower(tostring(inner or ""))
        if string.find(lowerInner, "ki-helfer", 1, true) ~= nil
                or string.find(lowerInner, "ai helper", 1, true) ~= nil
                or string.find(lowerInner, "ai worker", 1, true) ~= nil then
            return ""
        end

        return "(" .. tostring(inner or "") .. ")"
    end)

    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    return text
end

function HelperPersonnelViewBase:normalizeDisplayNamePart(value)
    if value == nil then
        return nil
    end

    local text = tostring(value)
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    if text == "" then
        return nil
    end

    if g_i18n ~= nil and g_i18n.getText ~= nil and string.sub(text, 1, 6) == "$l10n_" then
        local key = string.sub(text, 7)
        local ok, translatedText = pcall(function()
            return g_i18n:getText(key)
        end)

        if ok and translatedText ~= nil and tostring(translatedText) ~= "" and tostring(translatedText) ~= key then
            text = tostring(translatedText)
        end
    end

    text = self:stripRuntimeHelperSuffix(text)
    if text == nil or text == "" then
        return nil
    end

    return text
end

function HelperPersonnelViewBase:formatNameSegment(value)
    local text = self:normalizeDisplayNamePart(value)
    if text == nil then
        return nil
    end

    local knownNames = {
        johnDeere = "John Deere",
        caseIH = "Case IH",
        newHolland = "New Holland",
        masseyFerguson = "Massey Ferguson",
        deutzFahr = "Deutz-Fahr",
        steyr = "Steyr",
        fendt = "Fendt",
        claas = "CLAAS",
        kubota = "Kubota",
        valtra = "Valtra",
        vaderstad = "Väderstad",
        amazone = "Amazone",
        lemken = "Lemken",
        kuhn = "Kuhn",
        horsch = "Horsch",
        kverneland = "Kverneland",
        pottinger = "Pöttinger",
        poettinger = "Pöttinger"
    }

    if knownNames[text] ~= nil then
        return knownNames[text]
    end

    text = string.gsub(text, "_", " ")
    text = string.gsub(text, "%-", " ")
    text = string.gsub(text, "(%l)(%u)", "%1 %2")
    text = string.gsub(text, "(%a)(%d)", "%1 %2")
    text = string.gsub(text, "(%d)(%a)", "%1 %2")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    text = string.gsub(text, "(%S+)", function(word)
        if string.len(word) <= 3 and string.upper(word) == word then
            return word
        end

        return string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
    end)

    return text
end

function HelperPersonnelViewBase:getValueFromObject(object, getterNames, directKeys)
    if type(object) ~= "table" then
        return nil
    end

    if type(getterNames) == "table" then
        for _, getterName in ipairs(getterNames) do
            if object[getterName] ~= nil then
                local ok, value = pcall(function()
                    return object[getterName](object)
                end)

                if ok and value ~= nil and (type(value) == "table" or type(value) == "number") then
                    return value
                end

                local text = ok and self:normalizeDisplayNamePart(value) or nil
                if text ~= nil then
                    return text
                end
            end
        end
    end

    if type(directKeys) == "table" then
        for _, key in ipairs(directKeys) do
            local value = object[key]
            if value ~= nil and (type(value) == "table" or type(value) == "number") then
                return value
            end

            local text = self:normalizeDisplayNamePart(value)
            if text ~= nil then
                return text
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getBrandNameFromValue(value)
    if value == nil then
        return nil
    end

    if type(value) == "table" then
        return self:getValueFromObject(value, {"getTitle", "getName"}, {"title", "name", "brandName", "displayName"})
    end

    if type(value) == "number" then
        if g_brandManager == nil then
            return nil
        end

        local brand = nil

        if g_brandManager.getBrandByIndex ~= nil then
            local ok, result = pcall(function()
                return g_brandManager:getBrandByIndex(value)
            end)
            brand = ok and result or nil
        end

        if brand == nil and type(g_brandManager.indexToBrand) == "table" then
            brand = g_brandManager.indexToBrand[value]
        end

        local brandName = self:getBrandNameFromValue(brand)
        if brandName ~= nil then
            return brandName
        end

        return nil
    end

    return self:normalizeDisplayNamePart(value)
end

function HelperPersonnelViewBase:getBrandNameFromConfigFileName(configFileName)
    local filename = self:normalizeDisplayNamePart(configFileName)
    if filename == nil then
        return nil
    end

    filename = string.gsub(filename, "\\", "/")
    local brandFolder = string.match(filename, "/vehicles/([^/]+)/") or string.match(filename, "^vehicles/([^/]+)/")
    if brandFolder == nil then
        return nil
    end

    return self:formatNameSegment(brandFolder)
end

function HelperPersonnelViewBase:getModelNameFromConfigFileName(configFileName)
    local filename = self:normalizeDisplayNamePart(configFileName)
    if filename == nil then
        return nil
    end

    local cleanName = string.match(filename, "([^/\\]+)%.xml$") or string.match(filename, "([^/\\]+)$")
    return self:formatNameSegment(cleanName)
end

function HelperPersonnelViewBase:getBrandNameFromObject(object)
    if type(object) ~= "table" then
        return nil
    end

    local brandName = self:getValueFromObject(object, {"getBrandName", "getBrandTitle", "getBrand"}, {"brandName", "brandTitle", "brand"})
    brandName = self:getBrandNameFromValue(brandName)
    if brandName ~= nil then
        return self:formatNameSegment(brandName) or brandName
    end

    if type(object.storeItem) == "table" then
        brandName = self:getValueFromObject(object.storeItem, {"getBrandName", "getBrandTitle", "getBrand"}, {"brandName", "brandTitle", "brand"})
        brandName = self:getBrandNameFromValue(brandName)
        if brandName ~= nil then
            return self:formatNameSegment(brandName) or brandName
        end
    end

    return self:getBrandNameFromConfigFileName(object.configFileName or object.xmlFilename or object.filename)
end

function HelperPersonnelViewBase:getModelNameFromObject(object)
    if type(object) ~= "table" then
        return nil
    end

    local name = self:getValueFromObject(object, {"getFullName", "getDisplayName", "getName"}, {"fullName", "displayName", "name"})
    if name ~= nil then
        return name
    end

    if type(object.storeItem) == "table" then
        name = self:getValueFromObject(object.storeItem, {"getFullName", "getDisplayName", "getName"}, {"fullName", "displayName", "title", "name"})
        if name ~= nil then
            return name
        end
    end

    return self:getModelNameFromConfigFileName(object.configFileName or object.xmlFilename or object.filename)
end

function HelperPersonnelViewBase:combineBrandAndModelName(brandName, modelName, fallback)
    brandName = self:normalizeDisplayNamePart(brandName)
    modelName = self:normalizeDisplayNamePart(modelName)
    fallback = fallback or ""

    if modelName == nil then
        return brandName or fallback
    end

    if brandName == nil then
        return modelName
    end

    local lowerModel = string.lower(modelName)
    local lowerBrand = string.lower(brandName)
    if string.find(lowerModel, lowerBrand, 1, true) ~= nil then
        return modelName
    end

    local compactModel = string.gsub(lowerModel, "[%s%-_]", "")
    local compactBrand = string.gsub(lowerBrand, "[%s%-_]", "")
    if compactBrand ~= "" and string.find(compactModel, compactBrand, 1, true) ~= nil then
        return modelName
    end

    return string.format("%s %s", brandName, modelName)
end

function HelperPersonnelViewBase:getObjectDisplayName(object, fallback)
    fallback = fallback or ""

    if object == nil then
        return fallback
    end

    local brandName = self:getBrandNameFromObject(object)
    local modelName = self:getModelNameFromObject(object)

    return self:combineBrandAndModelName(brandName, modelName, fallback)
end

function HelperPersonnelViewBase:getJobForWorker(worker)
    if type(worker) ~= "table" or self.app == nil or self.app.helperBridge == nil then
        return nil
    end

    local helperBridge = self.app.helperBridge
    local workerId = tonumber(worker.id)
    if workerId == nil then
        return nil
    end

    if helperBridge.workerJobById ~= nil then
        local job = helperBridge.workerJobById[workerId]
        if job ~= nil then
            return job
        end
    end

    if helperBridge.jobWorkerIds ~= nil then
        for job, assignedWorkerId in pairs(helperBridge.jobWorkerIds) do
            if tonumber(assignedWorkerId) == workerId then
                return job
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getActiveWorkerContext(worker)
    if type(worker) ~= "table" then
        return nil
    end

    local workerId = tonumber(worker.id)
    local bridge = self.app ~= nil and self.app.helperBridge or nil
    if bridge ~= nil and bridge.followMeContextsByWorkerId ~= nil then
        local context = nil
        if workerId ~= nil then
            context = bridge.followMeContextsByWorkerId[workerId] or bridge.followMeContextsByWorkerId[tostring(workerId)]
        end
        if context == nil and worker.id ~= nil then
            context = bridge.followMeContextsByWorkerId[worker.id] or bridge.followMeContextsByWorkerId[tostring(worker.id)]
        end
        if type(context) == "table" then
            return context
        end
    end

    if bridge ~= nil and bridge.followMeContextsByVehicleKey ~= nil and worker.vehicleKey ~= nil then
        local context = bridge.followMeContextsByVehicleKey[worker.vehicleKey]
        if type(context) == "table" then
            return context
        end
    end

    if worker.currentJobActivityText ~= nil or worker.currentJobActivityKey ~= nil or worker.currentJobFieldId ~= nil or worker.currentJobFieldText ~= nil then
        return {
            activityText = worker.currentJobActivityText,
            activityKey = worker.currentJobActivityKey,
            activityFallback = worker.currentJobActivityFallback,
            targetText = worker.currentJobFollowMeTargetText,
            fieldId = worker.currentJobFieldId,
            fieldText = worker.currentJobFieldText,
            specializationKey = worker.currentJobSpecializationKey
        }
    end

    return nil
end

function HelperPersonnelViewBase:getVehicleFromActiveContext(context)
    if type(context) ~= "table" then
        return nil
    end

    if context.vehicle ~= nil then
        return context.vehicle
    end

    local bridge = self.app ~= nil and self.app.helperBridge or nil
    if bridge ~= nil and context.vehicleKey ~= nil and bridge.followMeContextsByVehicleKey ~= nil then
        local vehicleContext = bridge.followMeContextsByVehicleKey[context.vehicleKey]
        if type(vehicleContext) == "table" then
            return vehicleContext.vehicle
        end
    end

    return nil
end

function HelperPersonnelViewBase:getFollowMeActivityTextFromContext(context)
    if type(context) ~= "table" then
        return nil
    end

    if context.activityText ~= nil and context.activityText ~= "" then
        return tostring(context.activityText)
    end

    local activityBaseText = nil
    if context.activityKey ~= nil then
        activityBaseText = self:getText(context.activityKey, context.activityFallback or "")
    else
        activityBaseText = context.activityFallback
    end

    local targetText = context.targetText or ""
    if context.transportOnly == true or context.specializationKey == "transport" then
        return string.format(self:getText("ui_activityFollowMeTransport", "FollowMe bei %s"), targetText)
    end

    if activityBaseText ~= nil and activityBaseText ~= "" then
        return string.format(self:getText("ui_activityFollowMeWork", "FollowMe: %s hinter %s"), activityBaseText, targetText)
    end

    if targetText ~= "" then
        return string.format(self:getText("ui_activityFollowMeTransport", "FollowMe bei %s"), targetText)
    end

    return nil
end

function HelperPersonnelViewBase:getVehicleFromJob(job)
    if self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.getVehicleFromJob ~= nil then
        local ok, vehicle = pcall(function()
            return self.app.helperBridge:getVehicleFromJob(job)
        end)

        if ok and vehicle ~= nil then
            return vehicle
        end
    end

    if job ~= nil and job.vehicle ~= nil then
        return job.vehicle
    end

    return nil
end

function HelperPersonnelViewBase:getRootVehicle(vehicle)
    if vehicle == nil then
        return nil
    end

    if self.app ~= nil and self.app.getRootVehicle ~= nil then
        local ok, rootVehicle = pcall(function()
            return self.app:getRootVehicle(vehicle)
        end)

        if ok and rootVehicle ~= nil then
            return rootVehicle
        end
    end

    if vehicle.getRootVehicle ~= nil then
        local ok, rootVehicle = pcall(function()
            return vehicle:getRootVehicle()
        end)

        if ok and rootVehicle ~= nil then
            return rootVehicle
        end
    end

    return vehicle
end

function HelperPersonnelViewBase:getVehicleDisplayName(vehicle, fallback)
    fallback = fallback or self:getText("ui_activeWorkerUnknownVehicle", "Fahrzeug")

    local displayName = self:getObjectDisplayName(vehicle, "")
    if displayName ~= nil and displayName ~= "" then
        return displayName
    end

    if vehicle ~= nil and self.app ~= nil and self.app.getVehicleName ~= nil then
        local ok, name = pcall(function()
            return self.app:getVehicleName(vehicle)
        end)

        if ok and name ~= nil and tostring(name) ~= "" then
            return tostring(name)
        end
    end

    return fallback
end

function HelperPersonnelViewBase:collectAttachedObjects(vehicle, result, visited, depth)
    result = result or {}
    visited = visited or {}
    depth = depth or 0

    if vehicle == nil or depth > 4 then
        return result
    end

    if visited[vehicle] then
        return result
    end
    visited[vehicle] = true

    if vehicle.getAttachedImplements ~= nil then
        local ok, attachedImplements = pcall(function()
            return vehicle:getAttachedImplements()
        end)

        if ok and type(attachedImplements) == "table" then
            for _, implementInfo in pairs(attachedImplements) do
                local object = nil
                if type(implementInfo) == "table" then
                    object = implementInfo.object or implementInfo.vehicle or implementInfo.implement
                else
                    object = implementInfo
                end

                if object ~= nil and not visited[object] then
                    table.insert(result, object)
                    self:collectAttachedObjects(object, result, visited, depth + 1)
                end
            end
        end
    end

    return result
end

function HelperPersonnelViewBase:getAttachedImplementText(vehicle)
    local rootVehicle = self:getRootVehicle(vehicle)
    local objects = self:collectAttachedObjects(rootVehicle or vehicle, {}, {}, 0)
    local names = {}
    local seenNames = {}

    for _, object in ipairs(objects) do
        local name = self:getObjectDisplayName(object, "")
        if name ~= nil and name ~= "" and seenNames[name] ~= true then
            table.insert(names, name)
            seenNames[name] = true
        end

        if #names >= 2 then
            break
        end
    end

    if #names == 0 then
        return nil
    elseif #names == 1 then
        return names[1]
    end

    return string.format("%s + %s", names[1], names[2])
end

function HelperPersonnelViewBase:objectHasSpecialization(object, specializationName)
    if object == nil or specializationName == nil or _G == nil then
        return false
    end

    local specialization = _G[specializationName]
    if specialization == nil then
        return false
    end

    if SpecializationUtil ~= nil and SpecializationUtil.hasSpecialization ~= nil and object.specializations ~= nil then
        local ok, result = pcall(SpecializationUtil.hasSpecialization, specialization, object.specializations)
        if ok and result == true then
            return true
        end
    end

    return false
end

function HelperPersonnelViewBase:getJobClassName(job)
    if job == nil then
        return ""
    end

    if job.className ~= nil then
        return tostring(job.className)
    end

    local meta = getmetatable(job)
    if type(meta) == "table" and meta.className ~= nil then
        return tostring(meta.className)
    end

    return tostring(job)
end

function HelperPersonnelViewBase:getLocalizedActivityText(key, fallback)
    return self:getText(key, fallback)
end

function HelperPersonnelViewBase:detectActivityText(job, vehicle)
    local jobClassName = self:getJobClassName(job)
    if string.find(string.lower(jobClassName), "transport", 1, true) ~= nil then
        return self:getLocalizedActivityText("ui_activityTransport", "Transport")
    end

    local vehicles = {}
    local rootVehicle = self:getRootVehicle(vehicle)
    if rootVehicle ~= nil then
        table.insert(vehicles, rootVehicle)
        self:collectAttachedObjects(rootVehicle, vehicles, {}, 0)
    elseif vehicle ~= nil then
        table.insert(vehicles, vehicle)
        self:collectAttachedObjects(vehicle, vehicles, {}, 0)
    end

    local activityBySpecialization = {
        {"Combine", "ui_activityHarvesting", "Ernten"},
        {"ForageHarvester", "ui_activityHarvesting", "Ernten"},
        {"Harvester", "ui_activityHarvesting", "Ernten"},
        {"PotatoHarvester", "ui_activityHarvesting", "Ernten"},
        {"BeetHarvester", "ui_activityHarvesting", "Ernten"},
        {"Mower", "ui_activityMowing", "Mähen"},
        {"Baler", "ui_activityBaling", "Pressen"},
        {"ForageWagon", "ui_activityCollecting", "Sammeln"},
        {"Windrower", "ui_activityWindrowing", "Schwaden"},
        {"Tedder", "ui_activityTedding", "Wenden"},
        {"SowingMachine", "ui_activitySowing", "Säen"},
        {"Planter", "ui_activitySowing", "Säen"},
        {"Sprayer", "ui_activitySpraying", "Düngen/Spritzen"},
        {"ManureSpreader", "ui_activityFertilizing", "Düngen"},
        {"SlurryTank", "ui_activityFertilizing", "Düngen"},
        {"Cultivator", "ui_activityCultivating", "Grubbern"},
        {"DiscHarrow", "ui_activityCultivating", "Grubbern"},
        {"PowerHarrows", "ui_activityCultivating", "Grubbern"},
        {"Plow", "ui_activityPlowing", "Pflügen"},
        {"Subsoiler", "ui_activityPlowing", "Pflügen"},
        {"Roller", "ui_activityRolling", "Walzen"},
        {"StonePicker", "ui_activityStonePicking", "Steine sammeln"},
        {"Weeder", "ui_activityWeeding", "Striegeln"},
        {"Hoe", "ui_activityWeeding", "Striegeln"},
        {"Mulcher", "ui_activityMulching", "Mulchen"}
    }

    for _, entry in ipairs(activityBySpecialization) do
        local specializationName = entry[1]
        for _, object in ipairs(vehicles) do
            if self:objectHasSpecialization(object, specializationName) then
                return self:getLocalizedActivityText(entry[2], entry[3])
            end
        end
    end

    if string.find(string.lower(jobClassName), "field", 1, true) ~= nil then
        return self:getLocalizedActivityText("ui_activityFieldWork", "Feldarbeit")
    end

    return self:getLocalizedActivityText("ui_activityUnknown", "unbekannt")
end

function HelperPersonnelViewBase:getNumericFieldIdFromValue(value)
    if value == nil then
        return nil
    end

    local valueType = type(value)
    if valueType == "number" then
        if value > 0 then
            return math.floor(value + 0.5)
        end
        return nil
    elseif valueType == "string" then
        local numberValue = tonumber(value)
        if numberValue ~= nil and numberValue > 0 then
            return math.floor(numberValue + 0.5)
        end

        numberValue = tonumber(string.match(value, "%d+"))
        if numberValue ~= nil and numberValue > 0 then
            return math.floor(numberValue + 0.5)
        end
    elseif valueType == "table" then
        local directKeys = {"fieldId", "fieldIndex", "fieldNumber", "fieldNum", "id", "index"}
        for _, key in ipairs(directKeys) do
            local fieldId = self:getNumericFieldIdFromValue(value[key])
            if fieldId ~= nil then
                return fieldId
            end
        end

        local getterNames = {"getFieldId", "getFieldIndex", "getId"}
        for _, getterName in ipairs(getterNames) do
            if value[getterName] ~= nil then
                local ok, result = pcall(function()
                    return value[getterName](value)
                end)

                local fieldId = ok and self:getNumericFieldIdFromValue(result) or nil
                if fieldId ~= nil then
                    return fieldId
                end
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getValueFromParameter(parameter)
    if parameter == nil then
        return nil
    end

    if type(parameter) ~= "table" then
        return parameter
    end

    local getterNames = {"getValue", "getFieldId", "getFieldIndex", "getId"}
    for _, getterName in ipairs(getterNames) do
        if parameter[getterName] ~= nil then
            local ok, result = pcall(function()
                return parameter[getterName](parameter)
            end)

            if ok and result ~= nil then
                return result
            end
        end
    end

    return parameter.value or parameter.currentValue or parameter.selectedValue or parameter.fieldId or parameter.fieldIndex
end

function HelperPersonnelViewBase:getFieldIdFromJob(job)
    if job == nil then
        return nil
    end

    local directKeys = {"fieldId", "fieldIndex", "fieldNumber", "fieldNum", "targetField", "field"}
    for _, key in ipairs(directKeys) do
        local fieldId = self:getNumericFieldIdFromValue(job[key])
        if fieldId ~= nil then
            return fieldId
        end
    end

    local parameterKeys = {"fieldParameter", "fieldIdParameter", "fieldIndexParameter", "fieldPositionParameter", "targetFieldParameter"}
    for _, key in ipairs(parameterKeys) do
        local value = self:getValueFromParameter(job[key])
        local fieldId = self:getNumericFieldIdFromValue(value)
        if fieldId ~= nil then
            return fieldId
        end
    end

    if job.getNamedParameter ~= nil then
        local namedKeys = {"FIELD", "field", "FIELD_ID", "fieldId", "FIELD_INDEX", "fieldIndex", "FIELD_POSITION", "fieldPosition"}
        for _, key in ipairs(namedKeys) do
            local ok, parameter = pcall(function()
                return job:getNamedParameter(key)
            end)

            if ok and parameter ~= nil then
                local fieldId = self:getNumericFieldIdFromValue(self:getValueFromParameter(parameter))
                if fieldId ~= nil then
                    return fieldId
                end
            end
        end
    end

    for key, value in pairs(job) do
        if type(key) == "string" and string.find(string.lower(key), "field", 1, true) ~= nil then
            local fieldId = self:getNumericFieldIdFromValue(self:getValueFromParameter(value))
            if fieldId ~= nil then
                return fieldId
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getFieldIdFromFieldObject(field)
    if field == nil then
        return nil
    end

    local keys = {"fieldId", "fieldIndex", "fieldNumber", "id", "index"}
    for _, key in ipairs(keys) do
        local fieldId = self:getNumericFieldIdFromValue(field[key])
        if fieldId ~= nil then
            return fieldId
        end
    end

    local getterNames = {"getFieldId", "getFieldIndex", "getId"}
    for _, getterName in ipairs(getterNames) do
        if field[getterName] ~= nil then
            local ok, result = pcall(function()
                return field[getterName](field)
            end)

            local fieldId = ok and self:getNumericFieldIdFromValue(result) or nil
            if fieldId ~= nil then
                return fieldId
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getFrameTimeMs()
    if g_currentMission ~= nil and g_currentMission.time ~= nil then
        return tonumber(g_currentMission.time) or 0
    end

    if g_time ~= nil then
        return tonumber(g_time) or 0
    end

    if getTimeSec ~= nil then
        local ok, timeSec = pcall(getTimeSec)
        if ok and timeSec ~= nil then
            return (tonumber(timeSec) or 0) * 1000
        end
    end

    if os ~= nil and os.clock ~= nil then
        return (tonumber(os.clock()) or 0) * 1000
    end

    return 0
end

function HelperPersonnelViewBase:debugFieldDetection(worker, message)
    if HelperPersonnelViewBase.FIELD_DETECTION_DEBUG_LOGGING ~= true then
        return
    end

    local workerName = "Worker"
    local manager = self:getManager()
    if manager ~= nil and manager.getFullName ~= nil and worker ~= nil then
        local ok, fullName = pcall(function()
            return manager:getFullName(worker)
        end)
        if ok and fullName ~= nil and tostring(fullName) ~= "" then
            workerName = tostring(fullName)
        end
    end

    local text = string.format("FS25_HelperPersonnel: Field detection %s - %s", workerName, tostring(message or ""))
    if Logging ~= nil and Logging.info ~= nil then
        Logging.info(text)
    else
        print(text)
    end
end

function HelperPersonnelViewBase:addPositionSample(samples, x, z, source)
    x = tonumber(x)
    z = tonumber(z)
    if x == nil or z == nil then
        return
    end

    for _, sample in ipairs(samples) do
        local dx = (sample.x or 0) - x
        local dz = (sample.z or 0) - z
        if (dx * dx + dz * dz) < 0.25 then
            return
        end
    end

    table.insert(samples, {
        x = x,
        z = z,
        source = source or "Position"
    })
end

function HelperPersonnelViewBase:addObjectPositionSamples(object, samples, sourcePrefix)
    if object == nil or samples == nil or #samples >= 16 then
        return
    end

    sourcePrefix = sourcePrefix or "Objekt"

    if object.getPosition ~= nil then
        local ok, x, _, z = pcall(function()
            return object:getPosition()
        end)
        if ok then
            self:addPositionSample(samples, x, z, sourcePrefix)
        end
    end

    if object.rootNode ~= nil and getWorldTranslation ~= nil then
        local ok, x, _, z = pcall(getWorldTranslation, object.rootNode)
        if ok then
            self:addPositionSample(samples, x, z, sourcePrefix .. ".rootNode")
        end
    end

    if type(object.components) == "table" and getWorldTranslation ~= nil then
        local componentCount = 0
        for _, component in pairs(object.components) do
            if type(component) == "table" then
                local node = component.node or component.nodeId
                if node ~= nil then
                    local ok, x, _, z = pcall(getWorldTranslation, node)
                    if ok then
                        self:addPositionSample(samples, x, z, sourcePrefix .. ".component")
                    end
                    componentCount = componentCount + 1
                    if componentCount >= 4 or #samples >= 16 then
                        break
                    end
                end
            end
        end
    end
end

function HelperPersonnelViewBase:addJobPositionSamples(job, samples)
    if type(job) ~= "table" or samples == nil then
        return
    end

    local coordinatePairs = {
        {"x", "z", "Job.xz"},
        {"posX", "posZ", "Job.pos"},
        {"positionX", "positionZ", "Job.position"},
        {"targetX", "targetZ", "Job.target"},
        {"fieldX", "fieldZ", "Job.field"},
        {"fieldPositionX", "fieldPositionZ", "Job.fieldPosition"},
        {"startX", "startZ", "Job.start"},
        {"lastX", "lastZ", "Job.last"}
    }

    for _, pair in ipairs(coordinatePairs) do
        self:addPositionSample(samples, job[pair[1]], job[pair[2]], pair[3])
    end

    local parameterKeys = {
        "positionAngleParameter",
        "positionParameter",
        "fieldPositionParameter",
        "targetPositionParameter"
    }

    for _, key in ipairs(parameterKeys) do
        local parameter = job[key]
        if type(parameter) == "table" then
            if parameter.getPosition ~= nil then
                local ok, x, _, z = pcall(function()
                    return parameter:getPosition()
                end)
                if ok then
                    self:addPositionSample(samples, x, z, "Job." .. key)
                end
            end

            local x = parameter.x or parameter.posX or parameter.positionX or parameter.targetX
            local z = parameter.z or parameter.posZ or parameter.positionZ or parameter.targetZ
            self:addPositionSample(samples, x, z, "Job." .. key .. ".xz")

            local value = self:getValueFromParameter(parameter)
            if type(value) == "table" then
                x = value.x or value.posX or value.positionX or value.targetX
                z = value.z or value.posZ or value.positionZ or value.targetZ
                self:addPositionSample(samples, x, z, "Job." .. key .. ".value")
            end
        end
    end

    if job.getNamedParameter ~= nil then
        local namedKeys = {"POSITION", "POSITION_ANGLE", "FIELD_POSITION", "TARGET_POSITION", "position", "positionAngle", "fieldPosition"}
        for _, key in ipairs(namedKeys) do
            local ok, parameter = pcall(function()
                return job:getNamedParameter(key)
            end)
            if ok and type(parameter) == "table" then
                if parameter.getPosition ~= nil then
                    local okPosition, x, _, z = pcall(function()
                        return parameter:getPosition()
                    end)
                    if okPosition then
                        self:addPositionSample(samples, x, z, "Job.named." .. key)
                    end
                end

                local value = self:getValueFromParameter(parameter)
                if type(value) == "table" then
                    self:addPositionSample(samples, value.x or value.posX or value.positionX, value.z or value.posZ or value.positionZ, "Job.named." .. key .. ".value")
                end
            end
        end
    end
end

function HelperPersonnelViewBase:collectWorkPositionSamples(job, vehicle)
    local samples = {}
    self:addJobPositionSamples(job, samples)

    local rootVehicle = self:getRootVehicle(vehicle)
    if rootVehicle ~= nil then
        self:addObjectPositionSamples(rootVehicle, samples, "Vehicle")
        local attachedObjects = self:collectAttachedObjects(rootVehicle, {}, {}, 0)
        for index, object in ipairs(attachedObjects) do
            self:addObjectPositionSamples(object, samples, "Implement" .. tostring(index))
            if #samples >= 16 then
                break
            end
        end
    elseif vehicle ~= nil then
        self:addObjectPositionSamples(vehicle, samples, "Vehicle")
    end

    return samples
end

function HelperPersonnelViewBase:getVehicleWorldPosition(vehicle)
    local rootVehicle = self:getRootVehicle(vehicle)
    local samples = {}
    self:addObjectPositionSamples(rootVehicle or vehicle, samples, "Vehicle")

    if samples[1] ~= nil then
        return samples[1].x, samples[1].z
    end

    return nil, nil
end

function HelperPersonnelViewBase:getFarmlandIdAtPosition(x, z)
    if x == nil or z == nil or g_farmlandManager == nil then
        return nil
    end

    local idGetterNames = {"getFarmlandIdAtWorldPosition", "getFarmlandIdAtPosition"}
    for _, getterName in ipairs(idGetterNames) do
        if g_farmlandManager[getterName] ~= nil then
            local ok, farmlandId = pcall(function()
                return g_farmlandManager[getterName](g_farmlandManager, x, z)
            end)
            local id = self:getNumericFieldIdFromValue(ok and farmlandId or nil)
            if id ~= nil then
                return id
            end
        end
    end

    local objectGetterNames = {"getFarmlandAtWorldPosition", "getFarmlandAtPosition"}
    for _, getterName in ipairs(objectGetterNames) do
        if g_farmlandManager[getterName] ~= nil then
            local ok, farmland = pcall(function()
                return g_farmlandManager[getterName](g_farmlandManager, x, z)
            end)
            if ok and farmland ~= nil then
                if type(farmland) == "number" then
                    return self:getNumericFieldIdFromValue(farmland)
                elseif type(farmland) == "table" then
                    return self:getNumericFieldIdFromValue(farmland.id or farmland.farmlandId or farmland.index)
                end
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getFieldById(fieldId)
    fieldId = tonumber(fieldId)
    if fieldId == nil or g_fieldManager == nil then
        return nil
    end

    local getterNames = {"getFieldById", "getFieldByFieldId", "getFieldByIndex"}
    for _, getterName in ipairs(getterNames) do
        if g_fieldManager[getterName] ~= nil then
            local ok, field = pcall(function()
                return g_fieldManager[getterName](g_fieldManager, fieldId)
            end)
            if ok and field ~= nil then
                return field
            end
        end
    end

    if type(g_fieldManager.fields) == "table" then
        local directField = g_fieldManager.fields[fieldId]
        if type(directField) == "table" and self:getFieldIdFromFieldObject(directField) == fieldId then
            return directField
        end

        for _, field in pairs(g_fieldManager.fields) do
            if type(field) == "table" and self:getFieldIdFromFieldObject(field) == fieldId then
                return field
            end
        end
    end

    return nil
end

function HelperPersonnelViewBase:getFieldFarmlandId(field)
    if type(field) ~= "table" then
        return nil
    end

    local farmlandValue = field.farmland or field.farmlandId or field.farmlandID
    if type(farmlandValue) == "table" then
        return self:getNumericFieldIdFromValue(farmlandValue.id or farmlandValue.farmlandId or farmlandValue.index)
    end

    return self:getNumericFieldIdFromValue(farmlandValue)
end

function HelperPersonnelViewBase:getFieldsForFarmlandId(farmlandId)
    local fields = {}
    local seen = {}
    farmlandId = tonumber(farmlandId)
    if farmlandId == nil or g_fieldManager == nil then
        return fields
    end

    local function addField(field)
        if type(field) ~= "table" then
            return
        end

        local fieldId = self:getFieldIdFromFieldObject(field)
        local key = fieldId or tostring(field)
        if seen[key] ~= true then
            table.insert(fields, field)
            seen[key] = true
        end
    end

    if type(g_fieldManager.farmlandIdFieldMapping) == "table" then
        local mappedFields = g_fieldManager.farmlandIdFieldMapping[farmlandId]
        if type(mappedFields) == "table" then
            if self:getFieldIdFromFieldObject(mappedFields) ~= nil then
                addField(mappedFields)
            else
                for key, value in pairs(mappedFields) do
                    if type(value) == "table" then
                        addField(value)
                    else
                        local fieldId = nil
                        if type(value) == "number" then
                            fieldId = value
                        elseif value == true and type(key) == "number" then
                            fieldId = key
                        elseif type(key) == "number" and type(value) ~= "boolean" then
                            fieldId = key
                        end

                        if fieldId ~= nil then
                            addField(self:getFieldById(fieldId))
                        end
                    end
                end
            end
        elseif type(mappedFields) == "number" then
            addField(self:getFieldById(mappedFields))
        end
    end

    if type(g_fieldManager.fields) == "table" then
        for _, field in pairs(g_fieldManager.fields) do
            if self:getFieldFarmlandId(field) == farmlandId then
                addField(field)
            end
        end
    end

    return fields
end

function HelperPersonnelViewBase:getFieldCheckObjects(field)
    local objects = {field}
    if type(field) == "table" then
        if type(field.fieldDimensions) == "table" then
            table.insert(objects, field.fieldDimensions)
            for _, dimension in pairs(field.fieldDimensions) do
                if type(dimension) == "table" then
                    table.insert(objects, dimension)
                end
            end
        end

        if type(field.dimensions) == "table" then
            table.insert(objects, field.dimensions)
        end
    end

    return objects
end

function HelperPersonnelViewBase:getFieldContainsPosition(field, x, z)
    if type(field) ~= "table" or x == nil or z == nil then
        return false
    end

    local fieldCheckNames = {
        "getIsWorldPositionInField",
        "getIsPointInside",
        "getIsPointInField",
        "getIsPositionInField",
        "getIsPositionOnField",
        "getIsOnField",
        "containsPoint",
        "containsWorldPosition"
    }

    for _, object in ipairs(self:getFieldCheckObjects(field)) do
        if type(object) == "table" then
            for _, checkName in ipairs(fieldCheckNames) do
                if object[checkName] ~= nil then
                    local ok, inside = pcall(function()
                        return object[checkName](object, x, z)
                    end)
                    if ok and inside == true then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function HelperPersonnelViewBase:getFieldGroundAtPosition(x, z)
    if x == nil or z == nil or FSDensityMapUtil == nil or FSDensityMapUtil.getFieldDataAtWorldPosition == nil then
        return nil
    end

    local y = 0
    if getTerrainHeightAtWorldPos ~= nil and g_currentMission ~= nil and g_currentMission.terrainRootNode ~= nil then
        local ok, terrainY = pcall(function()
            return getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 0, z)
        end)

        if ok and tonumber(terrainY) ~= nil then
            y = tonumber(terrainY)
        end
    end

    local values = {pcall(function()
        return FSDensityMapUtil.getFieldDataAtWorldPosition(x, y, z)
    end)}

    if values[1] ~= true then
        return nil
    end

    for i = 2, #values do
        local value = values[i]
        if value == true then
            return true
        end

        local numberValue = tonumber(value)
        if numberValue ~= nil and numberValue > 0 then
            return true
        end
    end

    return false
end

function HelperPersonnelViewBase:getFieldIdAtPositionDetailed(x, z)
    if x == nil or z == nil or g_fieldManager == nil then
        return nil, "no position or FieldManager"
    end

    local directGetterNames = {"getFieldAtWorldPosition", "getFieldByPosition", "getFieldAtPosition"}
    for _, getterName in ipairs(directGetterNames) do
        if g_fieldManager[getterName] ~= nil then
            local ok, field = pcall(function()
                return g_fieldManager[getterName](g_fieldManager, x, z)
            end)

            local fieldId = ok and self:getFieldIdFromFieldObject(field) or nil
            if fieldId ~= nil then
                return fieldId, "FieldManager." .. getterName
            end
        end
    end

    if type(g_fieldManager.fields) == "table" then
        for _, field in pairs(g_fieldManager.fields) do
            if self:getFieldContainsPosition(field, x, z) then
                local fieldId = self:getFieldIdFromFieldObject(field)
                if fieldId ~= nil then
                    return fieldId, "field object contains position"
                end
            end
        end
    end

    local farmlandId = self:getFarmlandIdAtPosition(x, z)
    local isFieldGround = self:getFieldGroundAtPosition(x, z)
    if farmlandId ~= nil then
        local mappedFields = self:getFieldsForFarmlandId(farmlandId)
        if #mappedFields == 1 then
            local fieldId = self:getFieldIdFromFieldObject(mappedFields[1])
            if fieldId ~= nil then
                return fieldId, string.format("farmland %d with exactly one field%s", farmlandId, isFieldGround == false and " (field ground not confirmed)" or "")
            end
        elseif #mappedFields > 1 then
            for _, field in ipairs(mappedFields) do
                if self:getFieldContainsPosition(field, x, z) then
                    local fieldId = self:getFieldIdFromFieldObject(field)
                    if fieldId ~= nil then
                        return fieldId, string.format("farmland %d, matching field object", farmlandId)
                    end
                end
            end

            return nil, string.format("farmland %d has %d possible fields, but none matched exactly", farmlandId, #mappedFields)
        else
            return nil, string.format("farmland %d found, but without field assignment", farmlandId)
        end
    end

    return nil, isFieldGround == true and "field ground detected, but no field number" or "no field assignment at position"
end

function HelperPersonnelViewBase:getFieldIdAtPosition(x, z)
    local fieldId = self:getFieldIdAtPositionDetailed(x, z)
    return fieldId
end

function HelperPersonnelViewBase:getFieldIdFromWorkPositions(worker, job, vehicle)
    local samples = self:collectWorkPositionSamples(job, vehicle)
    if #samples == 0 then
        return nil, "no vehicle/implement position found"
    end

    local notes = {}
    for index, sample in ipairs(samples) do
        local fieldId, reason = self:getFieldIdAtPositionDetailed(sample.x, sample.z)
        table.insert(notes, string.format("%s %.1f/%.1f: %s", sample.source or tostring(index), sample.x or 0, sample.z or 0, reason or "unknown"))
        if fieldId ~= nil then
            return fieldId, string.format("%s %.1f/%.1f -> field %s (%s)", sample.source or tostring(index), sample.x or 0, sample.z or 0, tostring(fieldId), tostring(reason or ""))
        end
    end

    return nil, table.concat(notes, " | ")
end


function HelperPersonnelViewBase:getFieldIdFromActiveContext(context)
    if type(context) ~= "table" then
        return nil
    end

    local fieldId = self:getNumericFieldIdFromValue(context.fieldId)
    if fieldId ~= nil then
        return fieldId
    end

    local samples = {}
    self:addObjectPositionSamples(context.vehicle, samples, "FollowMe")
    self:addObjectPositionSamples(context.leaderVehicle, samples, "FollowMeTarget")

    for _, sample in ipairs(samples) do
        local detectedFieldId = self:getFieldIdAtPosition(sample.x, sample.z)
        if detectedFieldId ~= nil then
            context.fieldId = detectedFieldId
            if type(context.workerId) == "number" and self.app ~= nil and self.app.manager ~= nil and self.app.manager.getWorkerById ~= nil then
                local worker = self.app.manager:getWorkerById(context.workerId)
                if worker ~= nil then
                    worker.currentJobFieldId = detectedFieldId
                end
            end
            return detectedFieldId
        end
    end

    return nil
end

function HelperPersonnelViewBase:getCachedFieldIdForActiveWorker(worker, job, vehicle)
    local workerId = type(worker) == "table" and tonumber(worker.id) or nil
    local cacheKey = workerId or tostring(worker or "unknown")
    self.fieldDetectionCache = self.fieldDetectionCache or {}

    local now = self:getFrameTimeMs()
    local cached = self.fieldDetectionCache[cacheKey]
    if cached ~= nil and cached.expiresAt ~= nil and cached.expiresAt > now then
        return cached.fieldId
    end

    local fieldId = self:getFieldIdFromJob(job)
    local reason = nil
    if fieldId ~= nil then
        reason = "read directly from AI job"
    else
        fieldId, reason = self:getFieldIdFromWorkPositions(worker, job, vehicle)
    end

    self.fieldDetectionCache[cacheKey] = {
        fieldId = fieldId,
        expiresAt = now + (HelperPersonnelViewBase.FIELD_DETECTION_CACHE_MS or 3000)
    }

    if fieldId ~= nil then
        self:debugFieldDetection(worker, string.format("field %s detected: %s", tostring(fieldId), tostring(reason or "")))
    else
        self:debugFieldDetection(worker, "no field detected: " .. tostring(reason or "unknown"))
    end

    return fieldId
end

function HelperPersonnelViewBase:getActiveWorkerOverviewLines(worker)
    local context = self:getActiveWorkerContext(worker)
    local job = self:getJobForWorker(worker)
    local vehicle = self:getVehicleFromJob(job) or self:getVehicleFromActiveContext(context)
    local vehicleName = nil

    if vehicle ~= nil then
        vehicleName = self:getVehicleDisplayName(vehicle, worker.vehicleName)
    elseif worker.vehicleName ~= nil and worker.vehicleName ~= "" then
        vehicleName = self:normalizeDisplayNamePart(worker.vehicleName) or tostring(worker.vehicleName)
    else
        vehicleName = self:getText("ui_activeWorkerUnknownVehicle", "Fahrzeug")
    end

    local implementText = self:getAttachedImplementText(vehicle)
    local statusLine
    if implementText ~= nil and implementText ~= "" then
        statusLine = string.format(self:getText("ui_activeWorkerStatusVehicleImplement", "Status: im Einsatz (%s) | Gerät/Anhänger: %s"), vehicleName, implementText)
    else
        statusLine = string.format(self:getText("ui_activeWorkerStatusVehicle", "Status: im Einsatz (%s)"), vehicleName)
    end

    local activityText = self:getFollowMeActivityTextFromContext(context) or self:detectActivityText(job, vehicle)
    local fieldId = type(context) == "table" and tonumber(context.fieldId) or nil
    if fieldId == nil and type(worker) == "table" then
        fieldId = tonumber(worker.currentJobFieldId)
    end
    if fieldId == nil and type(context) == "table" then
        fieldId = self:getFieldIdFromActiveContext(context)
    end
    if fieldId == nil then
        fieldId = self:getCachedFieldIdForActiveWorker(worker, job, vehicle)
    end

    local fieldText = nil
    if fieldId ~= nil then
        fieldText = tostring(fieldId)
    elseif type(context) == "table" and context.fieldText ~= nil and context.fieldText ~= "" then
        fieldText = tostring(context.fieldText)
    elseif type(worker) == "table" and worker.currentJobFieldText ~= nil and worker.currentJobFieldText ~= "" then
        fieldText = tostring(worker.currentJobFieldText)
    else
        fieldText = self:getText("ui_activeWorkerUnknownField", "unbekannt")
    end
    local activityLine = string.format(self:getText("ui_activeWorkerActivityField", "Tätigkeit: %s | Feld: %s"), activityText, fieldText)

    return statusLine, activityLine
end

function HelperPersonnelViewBase:keyEvent(unicode, sym, modifier, isDown)
    if not isDown then
        return false
    end

    if sym == Input.KEY_escape then
        return self:onClickBack()
    elseif sym == hpGetInputConstant("KEY_up", nil) or sym == hpGetInputConstant("KEY_upArrow", nil) then
        if self:moveDetailSelection(-1) then
            return true
        end
    elseif sym == hpGetInputConstant("KEY_down", nil) or sym == hpGetInputConstant("KEY_downArrow", nil) then
        if self:moveDetailSelection(1) then
            return true
        end
    elseif sym == hpGetInputConstant("KEY_pageup", nil) or sym == hpGetInputConstant("KEY_pageUp", nil) then
        if self:moveDetailSelection(-(HelperPersonnelViewBase.DETAIL_VISIBLE_COUNT or 4)) then
            return true
        end
    elseif sym == hpGetInputConstant("KEY_pagedown", nil) or sym == hpGetInputConstant("KEY_pageDown", nil) then
        if self:moveDetailSelection(HelperPersonnelViewBase.DETAIL_VISIBLE_COUNT or 4) then
            return true
        end
    elseif sym == Input.KEY_space then
        self:onClickExtra1()
        return true
    elseif sym == Input.KEY_return or (Input.KEY_enter ~= nil and sym == Input.KEY_enter) then
        self:onClickActivate()
        return true
    end

    return false
end

function HelperPersonnelViewBase:resetClickAreas()
    self.clickAreas = {}
    self.detailListMouseArea = nil
    self.detailScrollbarMouseArea = nil
    self.overviewHistoryMouseArea = nil
    self.overviewHistoryScrollbarMouseArea = nil
end

function HelperPersonnelViewBase:addClickArea(x, y, width, height, action, index)
    if self.clickAreas == nil then
        self.clickAreas = {}
    end

    table.insert(self.clickAreas, {
        x = x,
        y = y,
        width = width,
        height = height,
        action = action,
        index = index
    })
end

function HelperPersonnelViewBase:isPointInClickArea(posX, posY, area)
    return area ~= nil and posX >= area.x and posX <= area.x + area.width and posY >= area.y and posY <= area.y + area.height
end

function HelperPersonnelViewBase:isOverviewMode()
    return self.mode == HelperPersonnelViewBase.MODE_OVERVIEW
end

function HelperPersonnelViewBase:getOverviewHistoryScrollState()
    if not self:isOverviewMode() then
        return nil
    end

    local rows = self.overviewHistoryRows or {}
    local count = #rows
    local visibleCount = math.min(count, HelperPersonnelViewBase.OVERVIEW_HISTORY_VISIBLE_ROWS or 8)

    if count <= visibleCount or visibleCount <= 0 then
        return nil
    end

    local firstRow = hpClamp(math.floor((tonumber(self.overviewHistoryFirstRow) or 1) + 0.5), 1, count - visibleCount + 1)

    return {
        count = count,
        visibleCount = visibleCount,
        firstRow = firstRow,
        maxFirstRow = count - visibleCount + 1
    }
end

function HelperPersonnelViewBase:setOverviewHistoryFirstRow(firstRow)
    local state = self:getOverviewHistoryScrollState()
    if state == nil then
        self.overviewHistoryFirstRow = 1
        return false
    end

    self.overviewHistoryFirstRow = hpClamp(math.floor((tonumber(firstRow) or state.firstRow) + 0.5), 1, state.maxFirstRow)
    self.requestRender = true
    return true
end

function HelperPersonnelViewBase:scrollOverviewHistory(deltaRows)
    local state = self:getOverviewHistoryScrollState()
    if state == nil then
        return false
    end

    return self:setOverviewHistoryFirstRow(state.firstRow + (tonumber(deltaRows) or 0))
end

function HelperPersonnelViewBase:setOverviewHistoryScrollFromMouseY(posY, area)
    local state = self:getOverviewHistoryScrollState()
    if state == nil or area == nil or area.height <= 0 then
        return false
    end

    local localY = hpClamp((posY - area.y) / area.height, 0, 1)
    local progress = 1 - localY
    local firstRow = 1 + math.floor(progress * (state.maxFirstRow - 1) + 0.5)

    return self:setOverviewHistoryFirstRow(firstRow)
end

function HelperPersonnelViewBase:isDetailMode()
    return self.mode == HelperPersonnelViewBase.MODE_WORKERS or self.mode == HelperPersonnelViewBase.MODE_APPLICANTS
end

function HelperPersonnelViewBase:getDetailScrollState()
    if not self:isDetailMode() then
        return nil
    end

    local isApplicantView = self.mode == HelperPersonnelViewBase.MODE_APPLICANTS
    local entries = isApplicantView and self:getApplicants() or self:getWorkers()
    local count = #entries
    local visibleCount = math.min(count, HelperPersonnelViewBase.DETAIL_VISIBLE_COUNT or 4)

    if count <= visibleCount or visibleCount <= 0 then
        return nil
    end

    local selectedIndex = isApplicantView and self.applicantIndex or self.workerIndex
    local firstIndex = isApplicantView and self.applicantListFirstIndex or self.workerListFirstIndex

    selectedIndex = hpClamp(tonumber(selectedIndex) or 1, 1, count)
    firstIndex = hpClamp(tonumber(firstIndex) or 1, 1, count - visibleCount + 1)

    return {
        isApplicantView = isApplicantView,
        count = count,
        visibleCount = visibleCount,
        selectedIndex = selectedIndex,
        firstIndex = firstIndex,
        maxFirstIndex = count - visibleCount + 1
    }
end

function HelperPersonnelViewBase:setDetailSelection(selectedIndex, firstIndex)
    local state = self:getDetailScrollState()
    if state == nil then
        return false
    end

    firstIndex = hpClamp(math.floor((tonumber(firstIndex) or state.firstIndex) + 0.5), 1, state.maxFirstIndex)
    selectedIndex = hpClamp(math.floor((tonumber(selectedIndex) or state.selectedIndex) + 0.5), 1, state.count)

    if selectedIndex < firstIndex then
        selectedIndex = firstIndex
    elseif selectedIndex > firstIndex + state.visibleCount - 1 then
        selectedIndex = firstIndex + state.visibleCount - 1
    end

    if state.isApplicantView then
        self.applicantListFirstIndex = firstIndex
        self.applicantIndex = selectedIndex
    else
        self.workerListFirstIndex = firstIndex
        self.workerIndex = selectedIndex
    end

    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelViewBase:moveDetailSelection(delta)
    local state = self:getDetailScrollState()
    if state == nil then
        return false
    end

    local selectedIndex = hpClamp(state.selectedIndex + (tonumber(delta) or 0), 1, state.count)
    local firstIndex = state.firstIndex

    if selectedIndex < firstIndex then
        firstIndex = selectedIndex
    elseif selectedIndex > firstIndex + state.visibleCount - 1 then
        firstIndex = selectedIndex - state.visibleCount + 1
    end

    return self:setDetailSelection(selectedIndex, firstIndex)
end

function HelperPersonnelViewBase:scrollDetailList(deltaRows)
    local state = self:getDetailScrollState()
    if state == nil then
        return false
    end

    local firstIndex = hpClamp(state.firstIndex + (tonumber(deltaRows) or 0), 1, state.maxFirstIndex)
    local selectedIndex = state.selectedIndex

    if selectedIndex < firstIndex then
        selectedIndex = firstIndex
    elseif selectedIndex > firstIndex + state.visibleCount - 1 then
        selectedIndex = firstIndex + state.visibleCount - 1
    end

    return self:setDetailSelection(selectedIndex, firstIndex)
end

function HelperPersonnelViewBase:setDetailScrollFromMouseY(posY, area)
    local state = self:getDetailScrollState()
    if state == nil or area == nil or area.height <= 0 then
        return false
    end

    local localY = hpClamp((posY - area.y) / area.height, 0, 1)
    local progress = 1 - localY
    local firstIndex = 1 + math.floor(progress * (state.maxFirstIndex - 1) + 0.5)

    return self:setDetailSelection(firstIndex, firstIndex)
end

function HelperPersonnelViewBase:isMouseWheelUp(button)
    local wheelUp = hpGetInputConstant("MOUSE_BUTTON_WHEEL_UP", nil) or hpGetInputConstant("MOUSE_WHEEL_UP", nil)
    return (wheelUp ~= nil and button == wheelUp) or button == 4
end

function HelperPersonnelViewBase:isMouseWheelDown(button)
    local wheelDown = hpGetInputConstant("MOUSE_BUTTON_WHEEL_DOWN", nil) or hpGetInputConstant("MOUSE_WHEEL_DOWN", nil)
    return (wheelDown ~= nil and button == wheelDown) or button == 5
end

function HelperPersonnelViewBase:handleOverviewHistoryMouseScroll(posX, posY, button)
    if not self:isOverviewMode() then
        return false
    end

    local scrollArea = self.overviewHistoryMouseArea
    local scrollbarArea = self.overviewHistoryScrollbarMouseArea
    local insideList = self:isPointInClickArea(posX, posY, scrollArea)
    local insideScrollbar = self:isPointInClickArea(posX, posY, scrollbarArea)

    if not insideList and not insideScrollbar then
        return false
    end

    if self:isMouseWheelUp(button) then
        return self:scrollOverviewHistory(-1)
    elseif self:isMouseWheelDown(button) then
        return self:scrollOverviewHistory(1)
    end

    return false
end

function HelperPersonnelViewBase:handleOverviewHistoryScrollbarDrag(posX, posY, isDown, isUp)
    if not self:isOverviewMode() then
        self.overviewHistoryScrollbarDragging = false
        return false
    end

    local area = self.overviewHistoryScrollbarMouseArea
    if area == nil then
        self.overviewHistoryScrollbarDragging = false
        return false
    end

    if isDown and self:isPointInClickArea(posX, posY, area) then
        self.overviewHistoryScrollbarDragging = true
        return self:setOverviewHistoryScrollFromMouseY(posY, area)
    end

    if self.overviewHistoryScrollbarDragging == true then
        local used = self:setOverviewHistoryScrollFromMouseY(posY, area)
        if isUp then
            self.overviewHistoryScrollbarDragging = false
        end
        return used
    end

    return false
end

function HelperPersonnelViewBase:handleDetailMouseScroll(posX, posY, button)
    if not self:isDetailMode() then
        return false
    end

    local scrollArea = self.detailListMouseArea
    local scrollbarArea = self.detailScrollbarMouseArea
    local insideList = self:isPointInClickArea(posX, posY, scrollArea)
    local insideScrollbar = self:isPointInClickArea(posX, posY, scrollbarArea)

    if not insideList and not insideScrollbar then
        return false
    end

    if self:isMouseWheelUp(button) then
        return self:scrollDetailList(-1)
    elseif self:isMouseWheelDown(button) then
        return self:scrollDetailList(1)
    end

    return false
end

function HelperPersonnelViewBase:handleDetailScrollbarDrag(posX, posY, isDown, isUp)
    if not self:isDetailMode() then
        self.detailScrollbarDragging = false
        return false
    end

    local area = self.detailScrollbarMouseArea
    if area == nil then
        self.detailScrollbarDragging = false
        return false
    end

    if isDown and self:isPointInClickArea(posX, posY, area) then
        self.detailScrollbarDragging = true
        return self:setDetailScrollFromMouseY(posY, area)
    end

    if self.detailScrollbarDragging == true then
        local used = self:setDetailScrollFromMouseY(posY, area)
        if isUp then
            self.detailScrollbarDragging = false
        end
        return used
    end

    return false
end

function HelperPersonnelViewBase:handleMouseClick(posX, posY)
    for i = #(self.clickAreas or {}), 1, -1 do
        local area = self.clickAreas[i]
        if area ~= nil and self:isPointInClickArea(posX, posY, area) then
            if area.action == "overviewWorker" then
                self.workerIndex = hpClamp(area.index or 1, 1, math.max(#self:getWorkers(), 1))
                self.mode = HelperPersonnelViewBase.MODE_WORKERS
                self:updateButtons()
                self.requestRender = true
                return true
            elseif area.action == "worker" then
                self.workerIndex = hpClamp(area.index or 1, 1, math.max(#self:getWorkers(), 1))
                self:updateButtons()
                self.requestRender = true
                return true
            elseif area.action == "applicant" then
                self.applicantIndex = hpClamp(area.index or 1, 1, math.max(#self:getApplicants(), 1))
                self:updateButtons()
                self.requestRender = true
                return true
            end
        end
    end

    return false
end

function HelperPersonnelViewBase:mouseEvent(posX, posY, isDown, isUp, button, eventUsed)
    local used = eventUsed == true
    local superFunc = HelperPersonnelViewBase:superClass().mouseEvent
    if superFunc ~= nil then
        used = superFunc(self, posX, posY, isDown, isUp, button, eventUsed) == true or used
    end

    if self:handleOverviewHistoryMouseScroll(posX, posY, button) then
        return true
    end

    if self:handleOverviewHistoryScrollbarDrag(posX, posY, isDown, isUp) then
        return true
    end

    if self:handleDetailMouseScroll(posX, posY, button) then
        return true
    end

    if self:handleDetailScrollbarDrag(posX, posY, isDown, isUp) then
        return true
    end

    if isUp then
        used = self:handleMouseClick(posX, posY) == true or used
    end

    return used
end

function HelperPersonnelViewBase:draw()
    HelperPersonnelViewBase:superClass().draw(self)
    self:resetClickAreas()

    self:drawHeader()

    if self.mode == HelperPersonnelViewBase.MODE_OVERVIEW then
        self:drawOverview()
    else
        self:drawDetail()
    end
end

function HelperPersonnelViewBase:drawHeader()
    self:drawTextLine(0.22, 0.872, 0.031, RenderText.ALIGN_LEFT, self:getText("ui_headerTitle", "PERSONALVERWALTUNG"), 1, 1, 1, 1, true)
end

function HelperPersonnelViewBase:drawOverviewReportPanel(x, y, width, height, title, rows)
    local shade = 0.024
    self:drawSolidRect(x, y, width, height, shade, shade + 0.012, shade, 0.72)
    self:drawSolidRect(x, y + height - 0.003, width, 0.003, 0.61, 0.73, 0.07, 0.78)

    local textX = x + 0.012
    local valueX = x + width - 0.012
    self:drawTextLine(textX, y + height - 0.028, 0.0118, RenderText.ALIGN_LEFT, title or "", 1, 1, 1, 1, true)

    local rowY = y + height - 0.056
    for _, row in ipairs(rows or {}) do
        self:drawTextLine(textX, rowY, 0.0103, RenderText.ALIGN_LEFT, row.label or "", 0.92, 0.92, 0.92, 1, true)
        self:drawTextLine(valueX, rowY, 0.0103, RenderText.ALIGN_RIGHT, row.value or "", 0.61, 0.73, 0.07, 1, false)
        rowY = rowY - 0.0180
    end
end

function HelperPersonnelViewBase:drawOverview()
    local manager = self:getManager()
    if manager == nil then
        return
    end

    local applicants = self:getApplicants()
    local workers = self:getWorkers()
    local counts = self:getWorkerSummaryCounts(workers)
    local monthlyRows = self:getMonthlyReportRows(counts, applicants, workers)
    local lifetimeRows = self:getLifetimeReportRows(manager)

    self:drawTextLine(0.22, 0.770, 0.013, RenderText.ALIGN_LEFT,
        self:formatText("ui_overviewCounts", "Mitarbeiter im Bestand: %d | Frei verfügbar: %d | Bewerber am Markt: %d", counts.total, counts.available, #applicants),
        0.61, 0.73, 0.07, 1, true)

    local reputation = manager.getEmployerReputation ~= nil and manager:getEmployerReputation() or (manager.employerReputation or 60)
    local reputationLevelKey = manager.getEmployerReputationLevelKey ~= nil and manager:getEmployerReputationLevelKey() or "ui_reputationSolid"
    local reputationLevelText = self:getText(reputationLevelKey, "solide")

    self:drawTextLine(0.22, 0.747, 0.013, RenderText.ALIGN_LEFT,
        self:formatText("ui_overviewReputation", "Arbeitgeberansehen: %d/100 (%s)", reputation, reputationLevelText),
        0.61, 0.73, 0.07, 1, true)

    local historyBottom = self:drawMonthlyChangeHistory(manager, 0.22, 0.720, 0.580, 0.106)
    local workerSeparatorY = math.min(0.604, (historyBottom or 0.620) - 0.014)
    workerSeparatorY = math.max(0.548, workerSeparatorY)

    self:drawSeparator(0.22, workerSeparatorY, 0.58)

    self:drawTextLine(0.51, workerSeparatorY - 0.032, 0.015, RenderText.ALIGN_CENTER, self:getText("ui_workerStockHeader", "MITARBEITER IM EINSATZ"), 1, 1, 1, 1, true)

    local activeWorkerEntries = self:getActiveWorkerEntries(workers)
    if #activeWorkerEntries == 0 then
        self:drawTextLine(0.22, workerSeparatorY - 0.066, 0.014, RenderText.ALIGN_LEFT, self:getText("ui_noActiveWorkers", "Gerade ist kein Mitarbeiter im Einsatz."), 1, 1, 1, 1, true)
    else
        local y = workerSeparatorY - 0.101
        for i = 1, math.min(#activeWorkerEntries, 3) do
            local entry = activeWorkerEntries[i]
            self:drawPersonMiniRow(entry.worker, 0.22, y, 0.44, false, entry.sourceIndex)
            y = y - 0.074
        end

        if #activeWorkerEntries > 3 then
            self:drawTextLine(0.22, workerSeparatorY - 0.294, 0.011, RenderText.ALIGN_LEFT, self:formatText("ui_moreActiveWorkers", "… und %d weitere Mitarbeiter im Einsatz", #activeWorkerEntries - 3), 0.61, 0.73, 0.07, 1, false)
        end
    end

    local monthlySeparatorY = workerSeparatorY - 0.264
    self:drawSeparator(0.22, monthlySeparatorY, 0.62)

    local panelY = 0.075
    local panelHeight = math.max(0.180, monthlySeparatorY - panelY - 0.018)
    self:drawOverviewReportPanel(0.22, panelY, 0.292, panelHeight, self:getText("ui_monthlyReportHeader", "MONATSBERICHT"), monthlyRows)
    self:drawOverviewReportPanel(0.524, panelY, 0.316, panelHeight, self:getText("ui_pmOverviewOverallHeader", "GESAMT"), lifetimeRows)
end

function HelperPersonnelViewBase:drawDetail()
    local manager = self:getManager()
    if manager == nil then
        return
    end

    local isApplicantView = self.mode == HelperPersonnelViewBase.MODE_APPLICANTS
    local entries = isApplicantView and self:getApplicants() or self:getWorkers()
    local index = isApplicantView and self.applicantIndex or self.workerIndex

    local sectionTitle = isApplicantView and self:getText("ui_applicantsHeaderUpper", "BEWERBERMARKT") or self:getText("ui_workersHeaderUpper", "MITARBEITERVERWALTUNG")
    local detailTitleY = 0.718
    local detailSeparatorY = 0.705
    local listStartY = 0.585
    local entryCounterY = 0.665
    local visibleRangeY = 0.642

    self:drawTextLine(0.22, 0.765, 0.014, RenderText.ALIGN_LEFT, self:getText("ui_instructionSwitchEntry", "Per Mausklick wechselst du den markierten Eintrag."), 0.61, 0.73, 0.07, 1, true)

    if isApplicantView then
        self:drawTextLine(0.22, 0.742, 0.014, RenderText.ALIGN_LEFT, self:getText("ui_instructionApplicant", "ENTER stellt den markierten Bewerber ein. ESC kehrt zur Übersicht zurück."), 0.61, 0.73, 0.07, 1, true)
    else
        self:drawTextLine(0.22, 0.742, 0.0125, RenderText.ALIGN_LEFT, self:getText("ui_instructionWorkerDismiss", "Mit ENTER entlässt du den angewählten Mitarbeiter."), 0.61, 0.73, 0.07, 1, true)
        self:drawTextLine(0.22, 0.722, 0.0125, RenderText.ALIGN_LEFT, self:getText("ui_instructionWorkerTransport", "Über den Transportbutton verwaltest du die Transportreihenfolge, mit S schulst du den Mitarbeiter."), 0.61, 0.73, 0.07, 1, true)
        self:drawTextLine(0.22, 0.702, 0.0125, RenderText.ALIGN_LEFT, self:getText("ui_instructionWorkerSalaryRaise", "Offene Gehaltsforderungen werden über den Button Gehalt bearbeitet."), 0.61, 0.73, 0.07, 1, true)
        detailTitleY = 0.674
        detailSeparatorY = 0.661
        listStartY = 0.526
        entryCounterY = 0.625
        visibleRangeY = 0.602
    end

    self:drawTextLine(0.52, detailTitleY, 0.015, RenderText.ALIGN_CENTER, sectionTitle, 1, 1, 1, 1, true)
    self:drawSeparator(0.22, detailSeparatorY, 0.60)

    if #entries == 0 then
        local emptyText = isApplicantView and self:getText("ui_noApplicantsDetail", "Keine Bewerber vorhanden") or self:getText("ui_noWorkersDetail", "Keine Mitarbeiter vorhanden")
        self:drawTextLine(0.22, listStartY + 0.015, 0.016, RenderText.ALIGN_LEFT, emptyText, 1, 1, 1, 1, true)
        self:drawTextLine(0.915, entryCounterY, 0.014, RenderText.ALIGN_RIGHT, self:getText("ui_entryZero", "Eintrag 0 von 0"), 0.61, 0.73, 0.07, 1, true)
    else
        index = hpClamp(index or 1, 1, #entries)
        if isApplicantView then
            self.applicantIndex = index
        else
            self.workerIndex = index
        end

        local startIndex, endIndex = self:getVisibleEntryRange(index, #entries, isApplicantView)
        local y = listStartY
        local rowHeight = isApplicantView and (HelperPersonnelViewBase.DETAIL_ROW_HEIGHT or 0.092) or (HelperPersonnelViewBase.WORKER_DETAIL_ROW_HEIGHT or HelperPersonnelViewBase.DETAIL_ROW_HEIGHT or 0.092)
        local rowStep = isApplicantView and (HelperPersonnelViewBase.DETAIL_ROW_STEP or 0.097) or (HelperPersonnelViewBase.WORKER_DETAIL_ROW_STEP or HelperPersonnelViewBase.DETAIL_ROW_STEP or 0.097)

        for entryIndex = startIndex, endIndex do
            self:drawPersonCard(entries[entryIndex], entryIndex, index, 0.22, y, 0.585, rowHeight, isApplicantView)
            y = y - rowStep
        end

        if #entries > (endIndex - startIndex + 1) then
            local scrollbarX = 0.812
            local scrollbarY = listStartY - ((endIndex - startIndex) * rowStep)
            local scrollbarWidth = 0.008
            local scrollbarHeight = (endIndex - startIndex + 1) * rowHeight + (endIndex - startIndex) * math.max(0, rowStep - rowHeight)

            self.detailListMouseArea = { x = 0.22, y = scrollbarY, width = 0.585, height = scrollbarHeight }
            self.detailScrollbarMouseArea = { x = scrollbarX - 0.010, y = scrollbarY, width = scrollbarWidth + 0.020, height = scrollbarHeight }

            self:drawDetailScrollbar(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, startIndex, endIndex - startIndex + 1, #entries)
            self:drawTextLine(0.915, visibleRangeY, 0.0115, RenderText.ALIGN_RIGHT, self:formatText("ui_visibleRange", "Sichtbar %d-%d", startIndex, endIndex), 0.61, 0.73, 0.07, 0.78, false)
        else
            self:drawTextLine(0.915, visibleRangeY, 0.0115, RenderText.ALIGN_RIGHT, self:getText("ui_allEntriesVisible", "Alle Einträge sichtbar"), 0.61, 0.73, 0.07, 0.78, false)
        end

        self:drawTextLine(0.915, entryCounterY, 0.014, RenderText.ALIGN_RIGHT, self:formatText("ui_entryCounter", "Eintrag %d von %d", index, #entries), 0.61, 0.73, 0.07, 1, true)
    end

    local bottomSeparatorY = isApplicantView and 0.190 or 0.120
    self:drawSeparator(0.22, bottomSeparatorY, 0.60)
end

function HelperPersonnelViewBase:getWorkerSummaryCounts(workers)
    local manager = self:getManager()
    local counts = {
        total = 0,
        available = 0,
        busy = 0,
        helpers = 0,
        specialists = 0,
        experts = 0
    }

    for _, worker in ipairs(workers or {}) do
        counts.total = counts.total + 1

        if self:isWorkerActive(worker) then
            counts.busy = counts.busy + 1
        elseif manager == nil or manager.isWorkerSick == nil or not manager:isWorkerSick(worker) then
            counts.available = counts.available + 1
        end

        local exp = worker.experience or 0
        if exp >= 75 then
            counts.experts = counts.experts + 1
        elseif exp >= 45 then
            counts.specialists = counts.specialists + 1
        else
            counts.helpers = counts.helpers + 1
        end
    end

    return counts
end

function HelperPersonnelViewBase:getMonthlyReportRows(counts, applicants, workers)
    local rows = {}

    applicants = applicants or {}
    workers = workers or {}
    if type(counts) ~= "table" then
        counts = self:getWorkerSummaryCounts(workers)
    end

    rows[#rows + 1] = { label = self:getText("ui_rank_helper", "Helfer"), value = tostring(counts.helpers or 0) }
    rows[#rows + 1] = { label = self:getText("ui_rank_specialist", "Fachkraft"), value = tostring(counts.specialists or 0) }
    rows[#rows + 1] = { label = self:getText("ui_rank_expert", "Profi"), value = tostring(counts.experts or 0) }
    rows[#rows + 1] = { label = self:getText("ui_monthlyRowApplicants", "Bewerber"), value = tostring(#applicants) }

    if #workers == 0 then
        rows[#rows + 1] = { label = self:getText("ui_monthlyRowEmployees", "Mitarbeiter"), value = self:getText("ui_noWorkersDetail", "Keine Mitarbeiter vorhanden") }
    else
        rows[#rows + 1] = { label = self:getText("ui_monthlyRowAvailable", "Verfügbar"), value = string.format("%d / %d", counts.available or 0, counts.total or 0) }

        local manager = self:getManager()
        if manager ~= nil and manager.getTotalWorkStats ~= nil then
            local _, _, monthlyWages = manager:getTotalWorkStats()
            local monthlyWagesText = g_i18n:formatMoney(monthlyWages or 0, 0, true, false)
            rows[#rows + 1] = { label = self:getText("ui_monthlyRowWages", "Monatsgehälter"), value = monthlyWagesText }

            if manager.getLastPayrollText ~= nil then
                rows[#rows + 1] = { label = self:getText("ui_monthlyRowPayroll", "Letzte Gehaltsabrechnung"), value = manager:getLastPayrollText() }
            end
        end
    end

    return rows
end

function HelperPersonnelViewBase:getLifetimeReportRows(manager)
    local rows = {}
    local stats = manager ~= nil and manager.getLifetimePersonnelStats ~= nil and manager:getLifetimePersonnelStats() or {}

    local workTimeText = manager ~= nil and manager.formatWorkMinutes ~= nil and manager:formatWorkMinutes(stats.workMinutes or 0) or tostring(stats.workMinutes or 0)
    local payrollText = g_i18n:formatMoney(stats.totalPayrollPaid or 0, 0, true, false)

    rows[#rows + 1] = { label = self:getText("ui_pmOverviewTotalJobs", "Einsätze gesamt"), value = tostring(stats.jobs or 0) }
    rows[#rows + 1] = { label = self:getText("ui_pmOverviewTotalWorkTime", "Arbeitszeit gesamt"), value = workTimeText }
    rows[#rows + 1] = { label = self:getText("ui_pmOverviewTotalPayroll", "Gehälter gesamt"), value = payrollText }
    rows[#rows + 1] = { label = self:getText("ui_pmOverviewEverHired", "Jemals angestellt"), value = tostring(stats.everHired or 0) }
    rows[#rows + 1] = { label = self:getText("ui_pmOverviewDismissed", "Entlassen"), value = tostring(stats.dismissed or 0) }
    rows[#rows + 1] = { label = self:getText("ui_pmOverviewResigned", "Eigenkündigungen"), value = tostring(stats.resigned or 0) }
    rows[#rows + 1] = { label = self:getText("ui_pmOverviewRetired", "Ruhestand"), value = tostring(stats.retired or 0) }

    return rows
end

function HelperPersonnelViewBase:loadPortraitOverlays()

    self.portraitOverlays = self.portraitOverlays or {}
    self.portraitCount = #HelperPersonnelViewBase.PORTRAIT_FILENAMES

end

function HelperPersonnelViewBase:deletePortraitOverlays()
    if self.portraitOverlays == nil then
        self.portraitOverlays = {}
        return
    end

    for _, overlay in pairs(self.portraitOverlays) do
        if overlay ~= nil then
            overlay:delete()
        end
    end

    self.portraitOverlays = {}
end

function HelperPersonnelViewBase:getPortraitIndex(person)
    local count = math.max(1, self.portraitCount or #HelperPersonnelViewBase.PORTRAIT_FILENAMES or 1)
    if type(person) ~= "table" then
        return 1
    end

    local index = tonumber(person.avatarIndex) or tonumber(person.portraitIndex) or 0
    if index < 1 or index > count then
        index = (((tonumber(person.id) or 1) - 1) % count) + 1
    end

    return index
end

function HelperPersonnelViewBase:getFallbackPortraitFilename(person)
    local index = self:getPortraitIndex(person)
    local app = self.app or (g_helperPersonnelApp ~= nil and g_helperPersonnelApp or nil)

    if app ~= nil and app.modDir ~= nil then
        local modFilename = Utils.getFilename(string.format("gui/portraits/helperPortrait_%02d.png", index), app.modDir)
        if fileExists(modFilename) then
            return modFilename
        end
    end

    return HelperPersonnelViewBase.PORTRAIT_FILENAMES[index] or HelperPersonnelViewBase.PORTRAIT_FILENAMES[1]
end

function HelperPersonnelViewBase:getPortraitFilename(person)
    local app = self.app or (g_helperPersonnelApp ~= nil and g_helperPersonnelApp or nil)

    if app ~= nil and app.helperBridge ~= nil and app.helperBridge.getPortraitFilenameForPerson ~= nil then
        local ok, filename = pcall(function()
            return app.helperBridge:getPortraitFilenameForPerson(person)
        end)

        if ok and filename ~= nil and filename ~= "" then
            return filename
        end
    end

    return self:getFallbackPortraitFilename(person)
end

function HelperPersonnelViewBase:createPortraitOverlay(filename)
    if filename == nil or filename == "" then
        return nil
    end

    self:loadPortraitOverlays()

    local overlay = self.portraitOverlays ~= nil and self.portraitOverlays[filename] or nil
    if overlay == nil then
        local ok, newOverlay = pcall(function()
            return Overlay.new(filename, 0, 0, 0.04, 0.071)
        end)

        if ok and newOverlay ~= nil then
            overlay = newOverlay
            self.portraitOverlays[filename] = overlay
        end
    end

    return overlay
end

function HelperPersonnelViewBase:getPortraitOverlay(person)
    local overlay = self:createPortraitOverlay(self:getPortraitFilename(person))

    if overlay == nil then
        overlay = self:createPortraitOverlay(self:getFallbackPortraitFilename(person))
    end

    return overlay
end

function HelperPersonnelViewBase:drawSolidRect(x, y, width, height, r, g, b, a)
    if self.lineOverlay == nil then
        return
    end

    self.lineOverlay:setColor(r, g, b, a)
    self.lineOverlay:setPosition(x, y)
    self.lineOverlay:setDimension(width, height)
    self.lineOverlay:render()
end

function HelperPersonnelViewBase:drawProgressBar(x, y, width, height, value, maxValue, fillR, fillG, fillB, fillA, drawFrame)
    local maximum = math.max(1, tonumber(maxValue) or 100)
    local normalized = hpClamp((tonumber(value) or 0) / maximum, 0, 1)
    local padding = drawFrame == false and 0 or math.min(width, height) * 0.12
    local innerWidth = math.max(0, width - (padding * 2))
    local innerHeight = math.max(0, height - (padding * 2))

    if drawFrame ~= false then
        self:drawSolidRect(x, y, width, height, 0.015, 0.018, 0.015, 0.82)
    end
    self:drawSolidRect(x + padding, y + padding, innerWidth, innerHeight, 0.10, 0.12, 0.10, 0.78)

    local filledWidth = innerWidth * normalized
    if filledWidth > 0 then
        self:drawSolidRect(x + padding, y + padding, filledWidth, innerHeight, fillR or 0.61, fillG or 0.73, fillB or 0.07, fillA or 1)
    end
end

function HelperPersonnelViewBase:drawPersonPortrait(person, x, y, width, height, selected)
    self:drawSolidRect(x, y, width, height, 0.02, 0.02, 0.02, 0.85)

    local overlay = self:getPortraitOverlay(person)
    if overlay ~= nil then
        local portraitWidth, portraitHeight = hpGetAspectCorrectSquare(width, height)
        local portraitX = x + (width - portraitWidth) * 0.5
        local portraitY = y + (height - portraitHeight) * 0.5
        overlay:setPosition(portraitX, portraitY)
        overlay:setDimension(portraitWidth, portraitHeight)
        overlay:render()
    end
end

function HelperPersonnelViewBase:drawPersonMiniRow(person, x, y, width, isApplicantView, entryIndex)
    local manager = self:getManager()
    if manager == nil then
        return
    end

    self:drawSolidRect(x - 0.010, y - 0.006, width, 0.063, 0, 0, 0, 0.18)

    if entryIndex ~= nil then
        self:addClickArea(x - 0.010, y - 0.006, width, 0.063, isApplicantView and "applicant" or "overviewWorker", entryIndex)
    end

    self:drawPersonPortrait(person, x, y, 0.032, 0.057, false)

    local textX = x + 0.044
    self:drawTextLine(textX, y + 0.039, 0.0125, RenderText.ALIGN_LEFT, manager:getFullName(person), 1, 1, 1, 1, true)

    local line1
    local line2
    if isApplicantView then
        line1 = manager:getApplicantLine1(person)
        line2 = manager:getApplicantLine2(person)
    else
        line1, line2 = self:getActiveWorkerOverviewLines(person)
    end

    self:drawTextLine(textX, y + 0.019, 0.011, RenderText.ALIGN_LEFT, line1, 0.61, 0.73, 0.07, 1, false)
    self:drawTextLine(textX, y + 0.000, 0.011, RenderText.ALIGN_LEFT, line2, 0.61, 0.73, 0.07, 1, false)
end

function HelperPersonnelViewBase:getBaseWorkerHiredLine(manager, person)
    if manager == nil or type(person) ~= "table" then
        return ""
    end

    local monthName = manager.getMonthName ~= nil and manager:getMonthName(person.hiredPeriod) or nil
    local year = tonumber(person.hiredYear)

    if monthName == nil or year == nil then
        return self:getText("ui_worker_hired_unknown", "eingestellt: unbekannt")
    end

    local template = self:getText("ui_worker_hired_line", "eingestellt im %s Jahr %d")
    return string.format(template, monthName, math.floor(year + 0.5))
end

function HelperPersonnelViewBase:getWorkerMarkerLine(manager, person)
    local line = self:getBaseWorkerHiredLine(manager, person)

    if type(person) == "table" and person.transportDriver == true then
        local marker = self:getText("ui_transportMarker", "Transport")
        if line ~= nil and line ~= "" then
            line = string.format("%s | %s", line, marker)
        else
            line = marker
        end
    end

    return line or ""
end

function HelperPersonnelViewBase:getWorkerWageAndStatusLines(manager, person)
    if manager == nil or manager.getPersonLine2 == nil then
        return "", ""
    end

    local line = tostring(manager:getPersonLine2(person) or "")
    local wageLine = hpTrim(line)
    local statusLine = ""
    local delimiterStart, delimiterEnd = string.find(line, "·", 1, true)

    if delimiterStart ~= nil then
        wageLine = hpTrim(string.sub(line, 1, delimiterStart - 1))
        statusLine = hpTrim(string.sub(line, delimiterEnd + 1))
    elseif manager.getStatusText ~= nil then
        local statusText = manager:getStatusText(person) or ""
        if statusText ~= "" then
            statusLine = string.format(self:getText("ui_worker_status_line", "Status: %s"), statusText)
        end
    end

    return wageLine, statusLine
end

function HelperPersonnelViewBase:getWorkerSalaryRequestLine(manager, person)
    if manager ~= nil and manager.getSalaryRaiseLine ~= nil then
        return manager:getSalaryRaiseLine(person) or ""
    end

    return ""
end

function HelperPersonnelViewBase:drawPersonCard(person, entryIndex, selectedIndex, x, y, width, height, isApplicantView)
    local manager = self:getManager()
    if manager == nil or person == nil then
        return
    end

    local selected = entryIndex == selectedIndex
    self:addClickArea(x, y, width, height, isApplicantView and "applicant" or "worker", entryIndex)

    if selected then
        self:drawSolidRect(x, y, width, height, 0.11, 0.25, 0.39, 0.82)
        self:drawSolidRect(x, y + height - 0.004, width, 0.003, 0.61, 0.73, 0.07, 1)
    else
        self:drawSolidRect(x, y, width, height, 0, 0, 0, 0.22)
    end

    local portraitX = x + 0.012
    local portraitHeight = math.max(0.058, height - 0.014)
    local portraitWidth = math.max(0.038, math.min(0.074, portraitHeight * 0.64))
    self:drawPersonPortrait(person, portraitX, y + 0.007, portraitWidth, portraitHeight, selected)

    local textX = portraitX + portraitWidth + 0.012
    local namePrefix = selected and "> " or "  "
    local detailTextSize = HelperPersonnelViewBase.DETAIL_TEXT_SIZE or 0.0106
    local lineStep = HelperPersonnelViewBase.DETAIL_TEXT_LINE_STEP or 0.014
    local currentY = y + height - 0.018

    self:drawTextLine(textX, currentY, 0.0125, RenderText.ALIGN_LEFT, namePrefix .. manager:getFullName(person), 1, 1, 1, 1, true)
    currentY = currentY - lineStep

    local detailLines = {}

    if isApplicantView then
        detailLines[#detailLines + 1] = manager:getApplicantLine1(person)
        detailLines[#detailLines + 1] = manager.getPersonSpecializationText ~= nil and manager:getPersonSpecializationText(person) or ""
        detailLines[#detailLines + 1] = manager:getApplicantLine2(person)
    else
        local workerLine1 = manager:getPersonLine1(person)
        local markerLine = self:getWorkerMarkerLine(manager, person)
        if markerLine ~= nil and markerLine ~= "" then
            workerLine1 = string.format("%s · %s", workerLine1, markerLine)
        end

        local wageLine, statusLine = self:getWorkerWageAndStatusLines(manager, person)

        detailLines[#detailLines + 1] = workerLine1
        detailLines[#detailLines + 1] = manager.getPersonSpecializationText ~= nil and manager:getPersonSpecializationText(person) or ""

        if wageLine ~= nil and wageLine ~= "" then
            detailLines[#detailLines + 1] = wageLine
        end

        local trainingLine = manager.getWorkerTrainingInfoLine ~= nil and manager:getWorkerTrainingInfoLine(person) or ""
        if trainingLine ~= nil and trainingLine ~= "" then
            detailLines[#detailLines + 1] = trainingLine
        end

        local salaryRequestLine = self:getWorkerSalaryRequestLine(manager, person)
        if salaryRequestLine ~= nil and salaryRequestLine ~= "" then
            detailLines[#detailLines + 1] = salaryRequestLine
        end

        if statusLine ~= nil and statusLine ~= "" then
            detailLines[#detailLines + 1] = statusLine
        end
    end

    local valueColumnOffset = self:getDetailValueColumnOffset(detailTextSize, detailLines)

    for lineIndex, line in ipairs(detailLines) do
        if lineIndex > 1 then
            currentY = currentY - lineStep
        end

        self:drawDetailTextLine(textX, currentY, detailTextSize, line, 0.61, 0.73, 0.07, 1, valueColumnOffset)
    end
end

function HelperPersonnelViewBase:getVisibleEntryRange(selectedIndex, count, isApplicantView)
    local visibleCount = math.min(count, HelperPersonnelViewBase.DETAIL_VISIBLE_COUNT or 4)

    if count <= visibleCount then
        if isApplicantView then
            self.applicantListFirstIndex = 1
        else
            self.workerListFirstIndex = 1
        end

        return 1, count
    end

    local firstIndex = isApplicantView and self.applicantListFirstIndex or self.workerListFirstIndex
    firstIndex = Utils.getNoNil(firstIndex, 1)

    if selectedIndex < firstIndex then
        firstIndex = selectedIndex
    elseif selectedIndex > firstIndex + visibleCount - 1 then
        firstIndex = selectedIndex - visibleCount + 1
    end

    firstIndex = hpClamp(firstIndex, 1, count - visibleCount + 1)

    if isApplicantView then
        self.applicantListFirstIndex = firstIndex
    else
        self.workerListFirstIndex = firstIndex
    end

    return firstIndex, firstIndex + visibleCount - 1
end

function HelperPersonnelViewBase:drawDetailScrollbar(x, y, width, height, firstIndex, visibleCount, count)
    if self.lineOverlay == nil or count <= visibleCount then
        return
    end

    self.lineOverlay:setColor(1, 1, 1, 0.12)
    self.lineOverlay:setPosition(x, y)
    self.lineOverlay:setDimension(width, height)
    self.lineOverlay:render()

    local thumbHeight = math.max(0.040, height * visibleCount / count)
    local maxFirst = math.max(1, count - visibleCount + 1)
    local progress = 0
    if maxFirst > 1 then
        progress = (firstIndex - 1) / (maxFirst - 1)
    end

    local thumbY = y + (height - thumbHeight) * (1 - progress)
    self.lineOverlay:setColor(0.61, 0.73, 0.07, 0.95)
    self.lineOverlay:setPosition(x, thumbY)
    self.lineOverlay:setDimension(width, thumbHeight)
    self.lineOverlay:render()
end

function HelperPersonnelViewBase:drawSeparator(x, y, width)
    if self.lineOverlay == nil then
        return
    end

    self.lineOverlay:setColor(1, 1, 1, 0.35)
    self.lineOverlay:setPosition(x, y)
    self.lineOverlay:setDimension(width, 0.0015)
    self.lineOverlay:render()
end

function HelperPersonnelViewBase:drawTextLine(x, y, size, align, text, r, g, b, a, bold)
    setTextAlignment(align)
    setTextBold(bold == true)
    setTextColor(r, g, b, a)
    renderText(x, y, getCorrectTextSize(size), text)
    setTextBold(false)
    setTextAlignment(RenderText.ALIGN_LEFT)
end

function HelperPersonnelViewBase:getTextSegmentWidth(size, text, bold)
    text = tostring(text or "")

    if text == "" then
        return 0
    end

    if getTextWidth == nil then
        return string.len(text) * (size or 0.01) * 0.42
    end

    local textSize = getCorrectTextSize ~= nil and getCorrectTextSize(size) or size
    setTextBold(bold == true)

    local ok, width = pcall(function()
        return getTextWidth(textSize, text)
    end)

    setTextBold(false)

    if ok and type(width) == "number" then
        return width
    end

    return string.len(text) * (size or 0.01) * 0.42
end

function HelperPersonnelViewBase:drawTextSegment(x, y, size, text, r, g, b, a, bold)
    text = tostring(text or "")

    if text == "" then
        return x
    end

    self:drawTextLine(x, y, size, RenderText.ALIGN_LEFT, text, r, g, b, a, bold == true)
    return x + self:getTextSegmentWidth(size, text, bold == true)
end

function HelperPersonnelViewBase:getPrimaryDetailLabelWidth(size, text)
    text = tostring(text or "")

    if text == "" then
        return 0
    end

    local delimiterStart = string.find(text, "·", 1, true)
    local segment = delimiterStart ~= nil and string.sub(text, 1, delimiterStart - 1) or text
    local trimmed = segment:gsub("^%s+", ""):gsub("%s+$", "")
    local label = trimmed:match("^([^:]+:%s*)")

    if label == nil then
        return 0
    end

    return self:getTextSegmentWidth(size, label, true)
end

function HelperPersonnelViewBase:getDetailValueColumnOffset(size, lines)
    local maxLabelWidth = 0

    if type(lines) == "table" then
        for _, line in ipairs(lines) do
            maxLabelWidth = math.max(maxLabelWidth, self:getPrimaryDetailLabelWidth(size, line))
        end
    end

    if maxLabelWidth <= 0 then
        return nil
    end

    return maxLabelWidth + (HelperPersonnelViewBase.DETAIL_LABEL_VALUE_GAP or 0.008)
end

function HelperPersonnelViewBase:drawDetailTextLine(x, y, size, text, r, g, b, a, valueColumnOffset)
    text = tostring(text or "")

    if text == "" then
        return
    end

    local currentX = x
    local first = true

    local delimiter = "·"
    local startPos = 1

    while startPos <= string.len(text) + 1 do
        local delimiterStart, delimiterEnd = string.find(text, delimiter, startPos, true)
        local segment

        if delimiterStart ~= nil then
            segment = string.sub(text, startPos, delimiterStart - 1)
            startPos = delimiterEnd + 1
        else
            segment = string.sub(text, startPos)
            startPos = string.len(text) + 2
        end

        local leading = segment:match("^(%s*)") or ""
        local trimmed = segment:gsub("^%s+", ""):gsub("%s+$", "")

        if trimmed ~= "" then
            if not first then
                currentX = self:drawTextSegment(currentX, y, size, " · ", r, g, b, a, false)
            elseif leading ~= "" then
                currentX = self:drawTextSegment(currentX, y, size, leading, r, g, b, a, false)
            end

            local label, value = trimmed:match("^([^:]+:%s*)(.*)$")
            if label ~= nil then
                local labelStartX = currentX
                currentX = self:drawTextSegment(currentX, y, size, label, r, g, b, a, true)

                if first and valueColumnOffset ~= nil and valueColumnOffset > 0 then
                    currentX = math.max(currentX, labelStartX + valueColumnOffset)
                end

                currentX = self:drawTextSegment(currentX, y, size, value or "", r, g, b, a, false)
            else
                currentX = self:drawTextSegment(currentX, y, size, trimmed, r, g, b, a, false)
            end

            first = false
        end
    end

    if first then
        self:drawTextLine(x, y, size, RenderText.ALIGN_LEFT, text, r, g, b, a, false)
    end
end

function HelperPersonnelViewBase:getCompactHistoryLine(text)

    return tostring(text or "")
end

function HelperPersonnelViewBase:historyLineFits(text, textSize, maxWidth, fallbackMaxChars)
    text = tostring(text or "")

    if maxWidth ~= nil then
        local ok, width = pcall(self.getTextSegmentWidth, self, textSize, text, false)
        if ok and type(width) == "number" then
            return width <= maxWidth
        end
    end

    return string.len(text) <= (fallbackMaxChars or 42)
end

function HelperPersonnelViewBase:getWrappedHistoryLines(text, textSize, maxWidth, fallbackMaxChars)
    text = self:getCompactHistoryLine(text)

    if text == "" then
        return { "" }
    end

    local wrappedLines = {}
    local currentLine = ""

    for word in string.gmatch(text, "%S+") do
        local candidate = currentLine == "" and word or (currentLine .. " " .. word)

        if currentLine == "" or self:historyLineFits(candidate, textSize, maxWidth, fallbackMaxChars) then
            currentLine = candidate
        else
            table.insert(wrappedLines, currentLine)
            currentLine = word
        end
    end

    if currentLine ~= "" then
        table.insert(wrappedLines, currentLine)
    end

    if #wrappedLines == 0 then
        table.insert(wrappedLines, text)
    end

    return wrappedLines
end

function HelperPersonnelViewBase:getOverviewHistoryHeader(manager, period, year)
    local label = nil
    if manager ~= nil and manager.getPeriodLabel ~= nil then
        label = manager:getPeriodLabel(period, year)
    end

    if label ~= nil and label ~= "" then
        return string.format(self:getText("ui_pmOverviewChangesHeader", "CHANGES IN %s"), label)
    end

    return self:getText("ui_changeHistoryHeader", "OTHER CHANGES")
end

function HelperPersonnelViewBase:buildOverviewHistoryRows(lines, textSize, maxWidth)
    local rows = {}

    for _, line in ipairs(lines or {}) do
        local text = tostring(line or "")
        local prefixed = string.format("- %s", text)
        local wrappedLines = self:getWrappedHistoryLines(prefixed, textSize, maxWidth, 82)

        for index, wrappedLine in ipairs(wrappedLines) do
            if index > 1 and string.sub(wrappedLine, 1, 2) ~= "  " then
                wrappedLine = "  " .. wrappedLine
            end
            table.insert(rows, wrappedLine)
        end
    end

    if #rows == 0 then
        table.insert(rows, string.format("- %s", self:getText("ui_pmOverviewNoChanges", "No changes this month.")))
    end

    return rows
end

function HelperPersonnelViewBase:drawMonthlyChangeHistory(manager, x, y, width, height)
    local period, year = nil, nil
    local lines = nil

    if manager ~= nil and manager.getMonthlyHistoryLines ~= nil then
        lines, period, year = manager:getMonthlyHistoryLines()
    else
        lines = { self:getText("ui_pmOverviewNoChanges", "No changes this month.") }
    end

    local textSize = 0.0096
    local lineHeight = HelperPersonnelViewBase.OVERVIEW_HISTORY_LINE_HEIGHT or 0.0129
    local header = self:getOverviewHistoryHeader(manager, period, year)

    self:drawTextLine(x, y, 0.0115, RenderText.ALIGN_LEFT, header, 1, 1, 1, 1, true)

    local contentTop = y - 0.021
    local rows = self:buildOverviewHistoryRows(lines, textSize, width - 0.020)
    self.overviewHistoryRows = rows

    local visibleRows = math.max(1, math.floor(height / lineHeight))
    HelperPersonnelViewBase.OVERVIEW_HISTORY_VISIBLE_ROWS = visibleRows
    local maxFirstRow = math.max(1, #rows - visibleRows + 1)
    self.overviewHistoryFirstRow = hpClamp(math.floor((tonumber(self.overviewHistoryFirstRow) or 1) + 0.5), 1, maxFirstRow)

    local firstRow = self.overviewHistoryFirstRow
    local lastRow = math.min(#rows, firstRow + visibleRows - 1)
    local currentY = contentTop

    for rowIndex = firstRow, lastRow do
        self:drawTextLine(x, currentY, textSize, RenderText.ALIGN_LEFT, rows[rowIndex], 0.61, 0.73, 0.07, 1, false)
        currentY = currentY - lineHeight
    end

    self.overviewHistoryMouseArea = { x = x, y = contentTop - ((visibleRows - 1) * lineHeight) - 0.004, width = width, height = height + 0.010 }

    if #rows > visibleRows then
        local scrollbarX = x + width + 0.008
        local scrollbarY = contentTop - ((visibleRows - 1) * lineHeight) - 0.002
        local scrollbarHeight = math.max(0.030, (visibleRows * lineHeight) + 0.002)
        self.overviewHistoryScrollbarMouseArea = { x = scrollbarX - 0.010, y = scrollbarY, width = 0.028, height = scrollbarHeight }
        self:drawDetailScrollbar(scrollbarX, scrollbarY, 0.006, scrollbarHeight, firstRow, visibleRows, #rows)
        local rangeTemplate = self:getText("ui_pmOverviewRange", "%d-%d of %d")
        self:drawTextLine(x + width, y, 0.0105, RenderText.ALIGN_RIGHT, string.format(rangeTemplate, firstRow, lastRow, #rows), 0.61, 0.73, 0.07, 0.80, false)
    end

    return contentTop - (visibleRows * lineHeight)
end

function HelperPersonnelViewBase:drawHistoryColumn(title, lines, x, y, maxWidth)
    self:drawTextLine(x, y, 0.0115, RenderText.ALIGN_LEFT, title, 1, 1, 1, 1, true)

    lines = lines or {}
    local textSize = 0.0088
    local lineHeight = 0.0106
    local entryGap = 0.0035
    local currentY = y - 0.020

    for i = 1, 3 do
        local line = lines[i] or self:getText("ui_summary_lastActionNone", "Noch keine Änderung")
        local wrappedLines = self:getWrappedHistoryLines(line, textSize, maxWidth, 45)

        for _, wrappedLine in ipairs(wrappedLines) do
            self:drawTextLine(x, currentY, textSize, RenderText.ALIGN_LEFT, wrappedLine, 0.61, 0.73, 0.07, 1, false)
            currentY = currentY - lineHeight
        end

        currentY = currentY - entryGap
    end

    return currentY
end
