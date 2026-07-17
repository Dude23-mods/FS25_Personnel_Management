function HelperPersonnelApp:getActionId(actionName)
    if InputAction ~= nil and InputAction[actionName] ~= nil then
        return InputAction[actionName]
    end

    return actionName
end

function HelperPersonnelApp:tryRegisterStandaloneMenu()
    if self.standaloneMenuLoaded == true then
        return true
    end

    if g_gui == nil or HelperPersonnelInGameMenu == nil or HelperPersonnelOverviewFrame == nil or HelperPersonnelApplicantsFrame == nil or HelperPersonnelEmployeesFrame == nil or HelperPersonnelTrainingFrame == nil or HelperPersonnelSettingsFrame == nil or self.modDir == nil then
        return false
    end

    local ok, message = pcall(function()
        if self.standaloneMenuTextureLoaded ~= true and g_overlayManager ~= nil and g_overlayManager.addTextureConfigFile ~= nil then
            g_overlayManager:addTextureConfigFile(Utils.getFilename("gui/icons/hp_pm_menu_icons_20260710c.xml", self.modDir), "hpUiPm20260710c")
            self.standaloneMenuTextureLoaded = true
        end

        self.standaloneMenuPages = {
            overview = HelperPersonnelOverviewFrame.new(),
            applicants = HelperPersonnelApplicantsFrame.new(),
            employees = HelperPersonnelEmployeesFrame.new(),
            training = HelperPersonnelTrainingFrame.new(),
            settings = HelperPersonnelSettingsFrame.new()
        }

        self.standaloneMenuPages.overview:setContext(self)
        self.standaloneMenuPages.applicants:setContext(self)
        self.standaloneMenuPages.employees:setContext(self)
        self.standaloneMenuPages.training:setContext(self)
        self.standaloneMenuPages.settings:setContext(self)

        g_gui:loadGui(Utils.getFilename("gui/frames/HelperPersonnelMenuOverview.xml", self.modDir), "HelperPersonnelMenuOverview", self.standaloneMenuPages.overview, true)
        g_gui:loadGui(Utils.getFilename("gui/frames/HelperPersonnelMenuApplicants.xml", self.modDir), "HelperPersonnelMenuApplicants", self.standaloneMenuPages.applicants, true)
        g_gui:loadGui(Utils.getFilename("gui/frames/HelperPersonnelMenuEmployees.xml", self.modDir), "HelperPersonnelMenuEmployees", self.standaloneMenuPages.employees, true)
        g_gui:loadGui(Utils.getFilename("gui/frames/HelperPersonnelMenuTraining.xml", self.modDir), "HelperPersonnelMenuTraining", self.standaloneMenuPages.training, true)
        g_gui:loadGui(Utils.getFilename("gui/frames/HelperPersonnelMenuSettings.xml", self.modDir), "HelperPersonnelMenuSettings", self.standaloneMenuPages.settings, true)

        self.standaloneMenu = HelperPersonnelInGameMenu.new(nil, nil, self, g_messageCenter, g_i18n, g_inputBinding)
        g_gui:loadGui(Utils.getFilename("gui/HelperPersonnelInGameMenu.xml", self.modDir), "HelperPersonnelInGameMenu", self.standaloneMenu)
    end)

    if not ok then
        self.standaloneMenuLoaded = false
        self.standaloneMenu = nil
        self.standaloneMenuPages = nil
        if Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("%s: Standalone personnel management menu could not be loaded (%s).", tostring(self.modName or "FS25_PersonnelManagement"), tostring(message))
        end
        return false
    end

    self.standaloneMenuLoaded = true
    return true
end

function HelperPersonnelApp:openStandaloneMenu(pageName)
    if not self:tryRegisterStandaloneMenu() then
        return false
    end

    if g_gui == nil or self.standaloneMenu == nil then
        return false
    end

    g_gui:showGui("HelperPersonnelInGameMenu")


    if self.standaloneMenu.refreshPages ~= nil then
        self.standaloneMenu:refreshPages()
    end

    if pageName ~= nil and self.standaloneMenu.openPageByName ~= nil then
        self.standaloneMenu:openPageByName(pageName)
    end

    return true
end

function HelperPersonnelApp:onActionOpenPersonnelMenu(actionName, inputValue)
    if inputValue ~= nil and inputValue <= 0 then
        return
    end

    self:openStandaloneMenu("overview")
end

function HelperPersonnelApp:updateStandaloneMenuHotkey()
    if Input == nil or Input.isKeyPressed == nil or Input.KEY_lctrl == nil or Input.KEY_m == nil then
        return
    end

    local isDown = Input.isKeyPressed(Input.KEY_lctrl) and Input.isKeyPressed(Input.KEY_m)

    if isDown == true and self.standaloneMenuHotkeyDown ~= true then
        self:openStandaloneMenu("overview")
    end

    self.standaloneMenuHotkeyDown = isDown == true
end

function HelperPersonnelApp:registerStandaloneMenuAction()
    if self.standaloneMenuActionRegistered == true or g_inputBinding == nil then
        return false
    end

    local contextName = g_inputBinding.currentContextName
    local modificationStarted = false
    if contextName ~= nil and g_inputBinding.beginActionEventsModification ~= nil then
        g_inputBinding:beginActionEventsModification(contextName)
        modificationStarted = true
    end

    local actionId = self:getActionId("HP_OPEN_PERSONNEL_MENU")
    local success, actionEventId = g_inputBinding:registerActionEvent(actionId, self, self.onActionOpenPersonnelMenu, false, true, false, true, nil, true)

    if success == true and actionEventId ~= nil then
        self.standaloneMenuActionEventId = actionEventId
        self.standaloneMenuActionRegistered = true

        if g_inputBinding.setActionEventText ~= nil then
            local text = g_i18n ~= nil and g_i18n:getText("input_HP_OPEN_PERSONNEL_MENU") or "Personalmanagement öffnen"
            g_inputBinding:setActionEventText(actionEventId, text)
        end
        if g_inputBinding.setActionEventTextPriority ~= nil then
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_HIGH)
        end
        if g_inputBinding.setActionEventTextVisibility ~= nil then
            g_inputBinding:setActionEventTextVisibility(actionEventId, true)
        end
        if g_inputBinding.setActionEventActive ~= nil then
            g_inputBinding:setActionEventActive(actionEventId, true)
        end
    elseif Logging ~= nil and Logging.warning ~= nil then
        Logging.warning("%s: Keyboard shortcut for the standalone personnel management menu could not be registered as an action event.", tostring(self.modName or "FS25_PersonnelManagement"))
    end

    if modificationStarted and g_inputBinding.endActionEventsModification ~= nil then
        g_inputBinding:endActionEventsModification()
    end

    return self.standaloneMenuActionRegistered == true
end

function HelperPersonnelApp:unregisterStandaloneMenuAction()
    if self.standaloneMenuActionRegistered == true and g_inputBinding ~= nil then
        if self.standaloneMenuActionEventId ~= nil and g_inputBinding.removeActionEvent ~= nil then
            g_inputBinding:removeActionEvent(self.standaloneMenuActionEventId)
        elseif g_inputBinding.removeActionEventsByTarget ~= nil then
            g_inputBinding:removeActionEventsByTarget(self)
        end
    end

    self.standaloneMenuActionEventId = nil
    self.standaloneMenuActionRegistered = false
end





function HelperPersonnelApp:refreshPersonnelMenu()
    if self.standaloneMenu ~= nil and self.standaloneMenu.refreshPages ~= nil then
        self.standaloneMenu:refreshPages()
    end
end

function HelperPersonnelApp:isMultiplayerGame()
    if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil and g_currentMission.missionInfo.isMultiplayer == true then
        return true
    end

    if g_server ~= nil and g_client ~= nil then
        return true
    end

    return false
end

function HelperPersonnelApp:getLocalPlayerUserId()
    local player = g_currentMission ~= nil and g_currentMission.player or nil
    if player == nil then
        return nil
    end

    local methodNames = {"getUserId", "getUniqueUserId", "getNetworkUserId"}
    for _, methodName in ipairs(methodNames) do
        if player[methodName] ~= nil then
            local ok, value = pcall(function()
                return player[methodName](player)
            end)
            if ok and value ~= nil then
                return value
            end
        end
    end

    return player.userId or player.uniqueUserId or player.networkUserId
end

function HelperPersonnelApp:isLocalPlayerFarmManager(farmId)
    if not self:isMultiplayerGame() then
        return true
    end

    farmId = tonumber(farmId) or self:getCurrentFarmId()
    local currentFarmId = self:getCurrentFarmId()
    if tonumber(currentFarmId) ~= tonumber(farmId) then
        return false
    end

    local farm = self:getFarmById(farmId)
    local userId = self:getLocalPlayerUserId()
    local isManager = self:farmHasManagerEntry(farm, userId)
    if isManager ~= nil then
        return isManager == true
    end

    return true
end

function HelperPersonnelApp:canManageCurrentFarm()
    return self:isLocalPlayerFarmManager(self:getCurrentFarmId()) == true
end
