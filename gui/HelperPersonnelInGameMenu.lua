HelperPersonnelInGameMenu = {}
local HelperPersonnelInGameMenu_mt = Class(HelperPersonnelInGameMenu, TabbedMenu)

function HelperPersonnelInGameMenu.new(target, customMt, app, messageCenter, l10n, inputManager)
    local self = HelperPersonnelInGameMenu:superClass().new(target, customMt or HelperPersonnelInGameMenu_mt, messageCenter, l10n, inputManager)

    self.app = app
    self.messageCenter = messageCenter
    self.l10n = l10n
    self.inputManager = inputManager
    self.defaultMenuButtonInfo = {}
    self.defaultMenuButtonInfoByActions = {}
    self.defaultButtonActionCallbacks = {}
    self.pageLookup = {}

    return self
end

function HelperPersonnelInGameMenu:initializePages()
    self.clickBackCallback = function()
        self:exitMenu()
    end

    local pages = {
        overview = self.pageOverview,
        applicants = self.pageApplicants,
        employees = self.pageEmployees,
        training = self.pageTraining,
        settings = self.pageSettings
    }

    for pageName, page in pairs(pages) do
        if page ~= nil then
            page:setMenu(self)
            page:setContext(self.app)
            page.pageName = pageName
            self.pageLookup[pageName] = page
        end
    end
end

function HelperPersonnelInGameMenu:setupMenuPages()
    local pageDefs = {
        {self.pageOverview, "overview", "hpUiPm20260710c.overview"},
        {self.pageApplicants, "applicants", "hpUiPm20260710c.applicants"},
        {self.pageEmployees, "employees", "hpUiPm20260710c.employees"},
        {self.pageTraining, "training", "hpUiPm20260710c.training"},
        {self.pageSettings, "settings", "hpUiPm20260710c.settings"}
    }

    for index, pageDef in ipairs(pageDefs) do
        local page = pageDef[1]
        local pageName = pageDef[2]
        local sliceId = pageDef[3]
        if page ~= nil then
            page.pageName = pageName
            if page.setPageKind ~= nil then
                page:setPageKind(pageName)
            else
                page.pageKind = pageName
            end
            self:registerPage(page, index, function()
                return true
            end)
            self:addPageTab(page, nil, nil, sliceId)
        end
    end
end

function HelperPersonnelInGameMenu:setupMenuButtonInfo()
    HelperPersonnelInGameMenu:superClass().setupMenuButtonInfo(self)

    local onButtonBackFunction = self.clickBackCallback or function()
        self:exitMenu()
    end
    local onButtonPagePreviousFunction = self:makeSelfCallback(self.onPagePrevious)
    local onButtonPageNextFunction = self:makeSelfCallback(self.onPageNext)

    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_button_back", "Zurück"),
        callback = onButtonBackFunction
    }
    self.nextPageButtonInfo = {
        inputAction = InputAction.MENU_PAGE_NEXT,
        text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü"),
        callback = onButtonPageNextFunction
    }
    self.prevPageButtonInfo = {
        inputAction = InputAction.MENU_PAGE_PREV,
        text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü"),
        callback = onButtonPagePreviousFunction
    }

    self.defaultMenuButtonInfo = {
        self.backButtonInfo,
        self.nextPageButtonInfo,
        self.prevPageButtonInfo
    }

    if InputAction ~= nil then
        self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]
        self.defaultMenuButtonInfoByActions[InputAction.MENU_PAGE_NEXT] = self.defaultMenuButtonInfo[2]
        self.defaultMenuButtonInfoByActions[InputAction.MENU_PAGE_PREV] = self.defaultMenuButtonInfo[3]
        self.defaultButtonActionCallbacks[InputAction.MENU_BACK] = onButtonBackFunction
        self.defaultButtonActionCallbacks[InputAction.MENU_PAGE_NEXT] = onButtonPageNextFunction
        self.defaultButtonActionCallbacks[InputAction.MENU_PAGE_PREV] = onButtonPagePreviousFunction
    end
end

function HelperPersonnelInGameMenu:onGuiSetupFinished()
    HelperPersonnelInGameMenu:superClass().onGuiSetupFinished(self)
    self:initializePages()
    self:setupMenuPages()
end

function HelperPersonnelInGameMenu:getText(key, fallback)
    if g_i18n ~= nil then
        local text = g_i18n:getText(key)
        if text ~= nil and text ~= key then
            return text
        end
    end

    return fallback
end

function HelperPersonnelInGameMenu:onOpen()
    HelperPersonnelInGameMenu:superClass().onOpen(self)
    self:refreshPages()
end

function HelperPersonnelInGameMenu:onClose()
    HelperPersonnelInGameMenu:superClass().onClose(self)
end

function HelperPersonnelInGameMenu:onPageChange(pageIndex, pageMappingIndex, element, skipTabVisualUpdate)
    HelperPersonnelInGameMenu:superClass().onPageChange(self, pageIndex, pageMappingIndex, element, skipTabVisualUpdate)

    if self.currentPage ~= nil and self.currentPage.refresh ~= nil then
        self.currentPage:refresh()
    end
end

function HelperPersonnelInGameMenu:refreshPages()
    if self.pageLookup == nil then
        return
    end

    for _, page in pairs(self.pageLookup) do
        if page.refresh ~= nil then
            page:refresh()
        end
    end
end

function HelperPersonnelInGameMenu:openPageByName(pageName)
    if self.pageLookup == nil or pageName == nil then
        return false
    end

    local page = self.pageLookup[pageName]
    if page == nil or self.pagingElement == nil then
        return false
    end

    self:goToPage(page, true)
    return true
end
