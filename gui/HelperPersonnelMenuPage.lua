HelperPersonnelMenuPage = {}
local HelperPersonnelMenuPage_mt = Class(HelperPersonnelMenuPage, HelperPersonnelViewBase)

local function hpMenuGetInputAction(actionName, fallback)
    if InputAction ~= nil and InputAction[actionName] ~= nil then
        return InputAction[actionName]
    end

    return fallback or actionName
end

local function hpMenuGetInputConstant(name, fallback)
    if Input ~= nil and Input[name] ~= nil then
        return Input[name]
    end

    if _G ~= nil and _G[name] ~= nil then
        return _G[name]
    end

    return fallback
end

local function hpMenuClamp(value, minValue, maxValue)
    value = math.floor((tonumber(value) or minValue) + 0.5)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function hpMenuGetAspectCorrectWidth(height)
    local screenWidth = tonumber(g_screenWidth) or 1
    local screenHeight = tonumber(g_screenHeight) or 1
    if screenWidth <= 0 or screenHeight <= 0 then
        return height
    end

    return height * (screenHeight / screenWidth)
end

function HelperPersonnelMenuPage.new(pageKind, customMt)
    local self = HelperPersonnelViewBase.new(customMt or HelperPersonnelMenuPage_mt, g_messageCenter)

    self.pageKind = pageKind or "overview"
    self.menu = nil
    self.pageTitleKey = "ui_pmMenuPageOverview"
    self.pageTitleFallback = "Übersicht"
    self.btnClose = nil
    self.btnPrevTab = nil
    self.btnNextTab = nil
    self.btnPrevPerson = nil
    self.btnNextPerson = nil
    self.btnPrimary = nil
    self.btnTransport = nil
    self.btnSalary = nil
    self.navArrowLeftOverlay = nil
    self.navArrowRightOverlay = nil
    self.navDotActiveOverlay = nil
    self.navDotInactiveOverlay = nil
    self.overviewBrandOverlay = nil
    self.settingsInfoTextKey = "ui_pmSettingsInfo"
    self.settingsSelectedKey = nil
    self.selectedTrainingCategoryKey = nil
    self.selectedTrainingWorkerId = nil
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.transportPrioritySelectedIndex = 1
    self.transportPriorityFirstIndex = 1
    self.transportPriorityVisibleRows = 10
    self.btnTransportDialogCancel = nil
    self.btnTransportDialogUp = nil
    self.btnTransportDialogDown = nil
    self.btnTransportDialogToggle = nil
    self.btnTransportDialogApply = nil
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    self.salaryRaiseSelectedIndex = 1
    self.salaryRaiseFirstIndex = 1
    self.salaryRaiseVisibleRows = 10
    self.btnSalaryDialogCancel = nil
    self.btnSalaryDialogDecline = nil
    self.btnSalaryDialogAccept = nil

    return self
end

function HelperPersonnelMenuPage:setMenu(menu)
    self.menu = menu
    self.inGameMenu = menu
end

function HelperPersonnelMenuPage:setContext(app)
    HelperPersonnelMenuPage:superClass().setContext(self, app)
    self:deleteNavigationOverlays()

    if app ~= nil and app.modDir ~= nil then
        local leftFilename = Utils.getFilename("gui/icons/hp_person_nav_left.dds", app.modDir)
        local rightFilename = Utils.getFilename("gui/icons/hp_person_nav_right.dds", app.modDir)
        local activeDotFilename = Utils.getFilename("gui/icons/hp_person_dot_active.dds", app.modDir)
        local inactiveDotFilename = Utils.getFilename("gui/icons/hp_person_dot_inactive.dds", app.modDir)
        local okLeft, leftOverlay = pcall(function()
            return Overlay.new(leftFilename, 0, 0, 0.04, 0.04)
        end)
        local okRight, rightOverlay = pcall(function()
            return Overlay.new(rightFilename, 0, 0, 0.04, 0.04)
        end)
        local okActiveDot, activeDotOverlay = pcall(function()
            return Overlay.new(activeDotFilename, 0, 0, 0.01, 0.01)
        end)
        local okInactiveDot, inactiveDotOverlay = pcall(function()
            return Overlay.new(inactiveDotFilename, 0, 0, 0.01, 0.01)
        end)

        if okLeft then
            self.navArrowLeftOverlay = leftOverlay
        end
        if okRight then
            self.navArrowRightOverlay = rightOverlay
        end
        if okActiveDot then
            self.navDotActiveOverlay = activeDotOverlay
        end
        if okInactiveDot then
            self.navDotInactiveOverlay = inactiveDotOverlay
        end

        if self.pageKind == "overview" then
            local overviewFilename = Utils.getFilename("gui/overview_personnel_management.dds", app.modDir)
            local okOverview, overviewOverlay = pcall(function()
                return Overlay.new(overviewFilename, 0, 0, 0.10, 0.10)
            end)

            if okOverview then
                self.overviewBrandOverlay = overviewOverlay
            end
        end
    end
end

function HelperPersonnelMenuPage:deleteNavigationOverlays()
    if self.navArrowLeftOverlay ~= nil then
        self.navArrowLeftOverlay:delete()
        self.navArrowLeftOverlay = nil
    end

    if self.navArrowRightOverlay ~= nil then
        self.navArrowRightOverlay:delete()
        self.navArrowRightOverlay = nil
    end

    if self.navDotActiveOverlay ~= nil then
        self.navDotActiveOverlay:delete()
        self.navDotActiveOverlay = nil
    end

    if self.navDotInactiveOverlay ~= nil then
        self.navDotInactiveOverlay:delete()
        self.navDotInactiveOverlay = nil
    end

    if self.overviewBrandOverlay ~= nil then
        self.overviewBrandOverlay:delete()
        self.overviewBrandOverlay = nil
    end
end

function HelperPersonnelMenuPage:delete()
    self:deleteNavigationOverlays()
    HelperPersonnelMenuPage:superClass().delete(self)
end

function HelperPersonnelMenuPage:getInGameMenu()
    return self.menu or HelperPersonnelMenuPage:superClass().getInGameMenu(self)
end

function HelperPersonnelMenuPage:isCurrentMenuPage()
    local menu = self:getInGameMenu()
    return menu == nil or menu.currentPage == self
end

function HelperPersonnelMenuPage:setPageKind(pageKind)
    self.pageKind = pageKind or self.pageKind or "overview"
    self:applyPageKind()
end

function HelperPersonnelMenuPage:applyPageKind()
    local kind = self.pageKind or "overview"

    if kind == "applicants" then
        self.mode = HelperPersonnelViewBase.MODE_APPLICANTS
        self.pageTitleKey = "ui_pmMenuPageApplicants"
        self.pageTitleFallback = "Bewerber"
    elseif kind == "employees" then
        self.mode = HelperPersonnelViewBase.MODE_WORKERS
        self.pageTitleKey = "ui_pmMenuPageEmployees"
        self.pageTitleFallback = "Mitarbeiter"
    elseif kind == "training" then
        self.mode = HelperPersonnelViewBase.MODE_WORKERS
        self.pageTitleKey = "ui_pmMenuPageTraining"
        self.pageTitleFallback = "Schulung"
    elseif kind == "settings" then
        self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
        self.pageTitleKey = "ui_pmMenuPageSettings"
        self.pageTitleFallback = "Einstellungen"
    else
        self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
        self.pageTitleKey = "ui_pmMenuPageOverview"
        self.pageTitleFallback = "Übersicht"
    end
end

function HelperPersonnelMenuPage:onFrameOpen()
    HelperPersonnelMenuPage:superClass().onFrameOpen(self)
    self:applyPageKind()
    self:refresh()
    self:updateButtons()
end

function HelperPersonnelMenuPage:onFrameClose()
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    HelperPersonnelViewBase:superClass().onFrameClose(self)
end

function HelperPersonnelMenuPage:refresh()
    local workers = self:getWorkers()
    local applicants = self:getApplicants()

    self.workerIndex = hpMenuClamp(self.workerIndex or 1, 1, math.max(#workers, 1))
    self.applicantIndex = hpMenuClamp(self.applicantIndex or 1, 1, math.max(#applicants, 1))
    self:applyPageKind()

    if self.salaryRaiseDialogOpen == true then
        local selectedRow = self.salaryRaiseRows[self.salaryRaiseSelectedIndex or 1]
        local selectedWorkerId = selectedRow ~= nil and tonumber(selectedRow.workerId) or nil
        self.salaryRaiseRows = self:buildSalaryRaiseRows()
        self.salaryRaiseSelectedIndex = 1
        if selectedWorkerId ~= nil then
            for index, row in ipairs(self.salaryRaiseRows) do
                if tonumber(row.workerId) == selectedWorkerId then
                    self.salaryRaiseSelectedIndex = index
                    break
                end
            end
        end
        self:ensureSalaryRaiseSelectionVisible()
    end

    self:updateButtons()
end

function HelperPersonnelMenuPage:canManageCurrentFarm()
    if self.app ~= nil and self.app.canManageCurrentFarm ~= nil then
        return self.app:canManageCurrentFarm() == true
    end

    return true
end

function HelperPersonnelMenuPage:getCurrentEntries()
    if self.pageKind == "applicants" then
        return self:getApplicants(), true
    elseif self.pageKind == "settings" then
        return {}, false
    end

    return self:getWorkers(), false
end

function HelperPersonnelMenuPage:getCurrentPerson()
    local entries, isApplicant = self:getCurrentEntries()
    if #entries == 0 then
        return nil, isApplicant, entries
    end

    local index = isApplicant and self.applicantIndex or self.workerIndex
    index = hpMenuClamp(index or 1, 1, #entries)
    if isApplicant then
        self.applicantIndex = index
    else
        self.workerIndex = index
    end

    return entries[index], isApplicant, entries
end

function HelperPersonnelMenuPage:createButtonInfo()
    self.btnClose = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_button_back", "Zurück"),
        callback = function()
            return self:onClickBack()
        end
    }
    self.btnPrevTab = {
        inputAction = InputAction.MENU_PAGE_PREV,
        text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü"),
        callback = function()
            return self:onClickPagePrevious()
        end
    }
    self.btnNextTab = {
        inputAction = InputAction.MENU_PAGE_NEXT,
        text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü"),
        callback = function()
            return self:onClickPageNext()
        end
    }
    self.btnPrevPerson = {
        inputAction = hpMenuGetInputAction("HP_SELECT_LEFT", nil),
        text = self:getText("ui_pmMenuPrevPerson", "Vorige Person"),
        callback = function()
            return self:onClickPreviousPerson()
        end
    }
    self.btnNextPerson = {
        inputAction = hpMenuGetInputAction("HP_SELECT_RIGHT", nil),
        text = self:getText("ui_pmMenuNextPerson", "Nächste Person"),
        callback = function()
            return self:onClickNextPerson()
        end
    }
    self.btnPrimary = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getPrimaryButtonText(),
        callback = function()
            return self:onClickPrimaryAction()
        end
    }
    self.btnTransport = {
        inputAction = hpMenuGetInputAction("HP_TRANSPORT_MANAGE", nil),
        text = self:getTransportButtonText(),
        callback = function()
            return self:onClickTransportAction()
        end
    }
    self.btnSalary = {
        inputAction = hpMenuGetInputAction("HP_SALARY_RAISE_MANAGE", nil),
        text = self:getSalaryButtonText(),
        callback = function()
            return self:onClickSalaryAction()
        end
    }
    self.btnTransportDialogCancel = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_transportPriorityCancel", "Abbrechen"),
        callback = function()
            return self:closeTransportPriorityDialog()
        end
    }
    self.btnTransportDialogUp = {
        inputAction = hpMenuGetInputAction("HP_SELECT_LEFT", nil),
        text = self:getText("ui_transportPriorityMoveUp", "Nach oben"),
        callback = function()
            return self:moveTransportPriorityRow(-1)
        end
    }
    self.btnTransportDialogDown = {
        inputAction = hpMenuGetInputAction("HP_SELECT_RIGHT", nil),
        text = self:getText("ui_transportPriorityMoveDown", "Nach unten"),
        callback = function()
            return self:moveTransportPriorityRow(1)
        end
    }
    self.btnTransportDialogToggle = {
        inputAction = hpMenuGetInputAction("HP_SELECT_CONFIRM", nil),
        text = self:getText("ui_transportPriorityToggle", "Aktivieren/Deaktivieren"),
        callback = function()
            return self:toggleTransportPriorityRow()
        end
    }
    self.btnTransportDialogApply = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_transportPriorityApply", "Übernehmen"),
        callback = function()
            return self:applyTransportPriorityDialog()
        end
    }
    self.btnSalaryDialogCancel = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_transportPriorityCancel", "Abbrechen"),
        callback = function()
            return self:closeSalaryRaiseDialog()
        end
    }
    self.btnSalaryDialogDecline = {
        inputAction = hpMenuGetInputAction("HP_SELECT_CONFIRM", nil),
        text = self:getText("ui_button_raise_decline", "Forderung ablehnen"),
        callback = function()
            return self:decideSalaryRaiseRequest(false)
        end
    }
    self.btnSalaryDialogAccept = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_button_raise_grant", "Gehaltserhöhung gewähren"),
        callback = function()
            return self:decideSalaryRaiseRequest(true)
        end
    }
end

function HelperPersonnelMenuPage:getPrimaryButtonText()
    if self.pageKind == "applicants" then
        return self:getText("ui_button_hire", "Einstellen")
    elseif self.pageKind == "training" then
        return self:getText("ui_button_train", "Schulen")
    elseif self.pageKind == "settings" then
        return self:getText("ui_hpSetting_toggle", "Umschalten")
    end

    return self:getText("ui_button_fire", "Entlassen")
end

function HelperPersonnelMenuPage:getTransportButtonText()
    return self:getText("ui_button_transport_manage_long", "Transport")
end

function HelperPersonnelMenuPage:getSalaryButtonText()
    return self:getText("ui_button_salary_manage_long", "Gehalt")
end

function HelperPersonnelMenuPage:updateButtons()
    if self.btnClose == nil then
        self:createButtonInfo()
    end

    if self.salaryRaiseDialogOpen == true then
        local row = self.salaryRaiseRows[self.salaryRaiseSelectedIndex or 1]
        self.btnSalaryDialogCancel.text = self:getText("ui_transportPriorityCancel", "Abbrechen")
        self.btnSalaryDialogDecline.text = self:getText("ui_button_raise_decline", "Forderung ablehnen")
        self.btnSalaryDialogAccept.text = self:getText("ui_button_raise_grant", "Gehaltserhöhung gewähren")
        self.btnSalaryDialogDecline.disabled = row == nil or not self:canManageCurrentFarm()
        self.btnSalaryDialogAccept.disabled = row == nil or not self:canManageCurrentFarm()
        self:applyMenuButtons({self.btnSalaryDialogCancel, self.btnSalaryDialogDecline, self.btnSalaryDialogAccept})
        return
    end

    if self.transportPriorityDialogOpen == true then
        local row = self.transportPriorityRows[self.transportPrioritySelectedIndex or 1]
        local activeCount = self:getTransportPriorityActiveCount()
        local selectedIndex = self.transportPrioritySelectedIndex or 1
        self.btnTransportDialogCancel.text = self:getText("ui_transportPriorityCancel", "Abbrechen")
        self.btnTransportDialogUp.text = self:getText("ui_transportPriorityMoveUp", "Nach oben")
        self.btnTransportDialogDown.text = self:getText("ui_transportPriorityMoveDown", "Nach unten")
        self.btnTransportDialogToggle.text = self:getText("ui_transportPriorityToggle", "Aktivieren/Deaktivieren")
        self.btnTransportDialogApply.text = self:getText("ui_transportPriorityApply", "Übernehmen")
        self.btnTransportDialogUp.disabled = row == nil or row.enabled ~= true or selectedIndex <= 1
        self.btnTransportDialogDown.disabled = row == nil or row.enabled ~= true or selectedIndex >= activeCount
        self.btnTransportDialogToggle.disabled = row == nil
        self.btnTransportDialogApply.disabled = not self:canManageCurrentFarm()
        self:applyMenuButtons({self.btnTransportDialogCancel, self.btnTransportDialogUp, self.btnTransportDialogDown, self.btnTransportDialogToggle, self.btnTransportDialogApply})
        return
    end

    local buttons = {self.btnClose, self.btnPrevTab, self.btnNextTab}
    local entries = self:getCurrentEntries()
    local hasEntries = entries ~= nil and #entries > 0
    local canManage = self:canManageCurrentFarm()

    self.btnClose.text = self:getText("ui_button_back", "Zurück")
    self.btnPrevTab.text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü")
    self.btnNextTab.text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü")
    self.btnPrevPerson.text = self:getText("ui_pmMenuPrevPerson", "Vorige Person")
    self.btnNextPerson.text = self:getText("ui_pmMenuNextPerson", "Nächste Person")
    self.btnPrimary.text = self:getPrimaryButtonText()
    self.btnTransport.text = self:getTransportButtonText()
    self.btnSalary.text = self:getSalaryButtonText()
    self.btnPrevPerson.disabled = not hasEntries
    self.btnNextPerson.disabled = not hasEntries
    local currentPerson = self:getCurrentPerson()
    local manager = self:getManager()
    local trainingActive = self.pageKind == "training" and currentPerson ~= nil and manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(currentPerson)

    self.btnPrimary.disabled = not hasEntries or not canManage or self.pageKind == "overview" or self.pageKind == "settings" or trainingActive
    self.btnTransport.disabled = self.pageKind ~= "employees" or not hasEntries or not canManage
    self.btnSalary.disabled = self.pageKind ~= "employees" or not hasEntries or not canManage

    if self.pageKind ~= "overview" and self.pageKind ~= "settings" then
        if self.pageKind == "employees" then
            table.insert(buttons, self.btnTransport)
            table.insert(buttons, self.btnSalary)
        end
        table.insert(buttons, self.btnPrevPerson)
        table.insert(buttons, self.btnNextPerson)
        table.insert(buttons, self.btnPrimary)
    end

    self:applyMenuButtons(buttons)
end

function HelperPersonnelMenuPage:onClickBack()
    if self.salaryRaiseDialogOpen == true then
        return self:closeSalaryRaiseDialog()
    end

    if self.transportPriorityDialogOpen == true then
        return self:closeTransportPriorityDialog()
    end

    if self.menu ~= nil and self.menu.exitMenu ~= nil then
        self.menu:exitMenu()
        return true
    end

    return true
end

function HelperPersonnelMenuPage:onClickPagePrevious()
    if self.menu ~= nil and self.menu.onPagePrevious ~= nil then
        self.menu:onPagePrevious()
        return true
    end

    return false
end

function HelperPersonnelMenuPage:onClickPageNext()
    if self.menu ~= nil and self.menu.onPageNext ~= nil then
        self.menu:onPageNext()
        return true
    end

    return false
end

function HelperPersonnelMenuPage:onClickPreviousPerson()
    return self:movePersonSelection(-1)
end

function HelperPersonnelMenuPage:onClickNextPerson()
    return self:movePersonSelection(1)
end

function HelperPersonnelMenuPage:onClickSalaryAction()
    if not self:canManageCurrentFarm() then
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage("ui_pmMenuNoPermission")
        end
        return false
    end

    if self.pageKind ~= "employees" or #self:getWorkers() == 0 then
        return false
    end

    return self:openSalaryRaiseDialog()
end

function HelperPersonnelMenuPage:onClickTransportAction()
    if not self:canManageCurrentFarm() then
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage("ui_pmMenuNoPermission")
        end
        return false
    end

    if self.pageKind ~= "employees" or #self:getWorkers() == 0 then
        return false
    end

    return self:openTransportPriorityDialog()
end

function HelperPersonnelMenuPage:getTransportPriorityActiveCount()
    local count = 0
    for _, row in ipairs(self.transportPriorityRows or {}) do
        if row.enabled == true then
            count = count + 1
        end
    end
    return count
end

function HelperPersonnelMenuPage:buildTransportPriorityRows()
    local rows = {}
    local activeIds = {}
    local manager = self:getManager()

    if manager ~= nil and manager.getTransportDriversSorted ~= nil then
        for _, worker in ipairs(manager:getTransportDriversSorted()) do
            if worker ~= nil and worker.id ~= nil then
                activeIds[tonumber(worker.id)] = true
                table.insert(rows, {workerId = tonumber(worker.id), enabled = true})
            end
        end
    end

    for _, worker in ipairs(self:getWorkers()) do
        local workerId = worker ~= nil and tonumber(worker.id) or nil
        if workerId ~= nil and activeIds[workerId] ~= true then
            table.insert(rows, {workerId = workerId, enabled = false})
        end
    end

    return rows
end

function HelperPersonnelMenuPage:openTransportPriorityDialog()
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    self.transportPriorityRows = self:buildTransportPriorityRows()
    self.transportPrioritySelectedIndex = 1
    self.transportPriorityFirstIndex = 1
    self.transportPriorityDialogOpen = true
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:closeTransportPriorityDialog()
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.transportPrioritySelectedIndex = 1
    self.transportPriorityFirstIndex = 1
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:ensureTransportPrioritySelectionVisible()
    local count = #self.transportPriorityRows
    local visible = math.max(1, self.transportPriorityVisibleRows or 10)
    self.transportPrioritySelectedIndex = hpMenuClamp(self.transportPrioritySelectedIndex or 1, 1, math.max(count, 1))
    self.transportPriorityFirstIndex = hpMenuClamp(self.transportPriorityFirstIndex or 1, 1, math.max(1, count - visible + 1))

    if self.transportPrioritySelectedIndex < self.transportPriorityFirstIndex then
        self.transportPriorityFirstIndex = self.transportPrioritySelectedIndex
    elseif self.transportPrioritySelectedIndex >= self.transportPriorityFirstIndex + visible then
        self.transportPriorityFirstIndex = self.transportPrioritySelectedIndex - visible + 1
    end
end

function HelperPersonnelMenuPage:moveTransportPrioritySelection(delta)
    local count = #self.transportPriorityRows
    if count == 0 then
        return false
    end

    self.transportPrioritySelectedIndex = hpMenuClamp((self.transportPrioritySelectedIndex or 1) + delta, 1, count)
    self:ensureTransportPrioritySelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:moveTransportPriorityRow(delta)
    local index = self.transportPrioritySelectedIndex or 1
    local row = self.transportPriorityRows[index]
    local activeCount = self:getTransportPriorityActiveCount()
    if row == nil or row.enabled ~= true then
        return false
    end

    local target = index + delta
    if target < 1 or target > activeCount then
        return false
    end

    self.transportPriorityRows[index], self.transportPriorityRows[target] = self.transportPriorityRows[target], self.transportPriorityRows[index]
    self.transportPrioritySelectedIndex = target
    self:ensureTransportPrioritySelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:toggleTransportPriorityRow()
    local index = self.transportPrioritySelectedIndex or 1
    local row = self.transportPriorityRows[index]
    if row == nil then
        return false
    end

    table.remove(self.transportPriorityRows, index)
    if row.enabled == true then
        row.enabled = false
        table.insert(self.transportPriorityRows, row)
        self.transportPrioritySelectedIndex = #self.transportPriorityRows
    else
        row.enabled = true
        local insertIndex = self:getTransportPriorityActiveCount() + 1
        table.insert(self.transportPriorityRows, insertIndex, row)
        self.transportPrioritySelectedIndex = insertIndex
    end

    self:ensureTransportPrioritySelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:getTransportPriorityDraftIds()
    local ids = {}
    for _, row in ipairs(self.transportPriorityRows or {}) do
        if row.enabled == true then
            table.insert(ids, row.workerId)
        end
    end
    return ids
end

function HelperPersonnelMenuPage:isTransportPriorityDraftChanged()
    local draft = self:getTransportPriorityDraftIds()
    local manager = self:getManager()
    local current = manager ~= nil and manager.getTransportDriversSorted ~= nil and manager:getTransportDriversSorted() or {}
    if #draft ~= #current then
        return true
    end
    for index, worker in ipairs(current) do
        if tonumber(worker.id) ~= tonumber(draft[index]) then
            return true
        end
    end
    return false
end

function HelperPersonnelMenuPage:applyTransportPriorityDialog()
    if not self:canManageCurrentFarm() then
        return false
    end

    if not self:isTransportPriorityDraftChanged() then
        return self:closeTransportPriorityDialog()
    end

    if self.app == nil or self.app.requestSetTransportPriority == nil then
        return false
    end

    local changed = self.app:requestSetTransportPriority(self:getTransportPriorityDraftIds()) == true
    if changed then
        self:closeTransportPriorityDialog()
        self:refresh()
    end
    return changed
end

function HelperPersonnelMenuPage:getTransportPriorityWorker(row)
    local manager = self:getManager()
    if row == nil or manager == nil or manager.getWorkerById == nil then
        return nil
    end
    return manager:getWorkerById(row.workerId)
end

function HelperPersonnelMenuPage:buildSalaryRaiseRows()
    local rows = {}
    for _, worker in ipairs(self:getWorkers()) do
        if worker ~= nil and worker.salaryRaisePending == true and worker.id ~= nil then
            table.insert(rows, {workerId = tonumber(worker.id)})
        end
    end
    return rows
end

function HelperPersonnelMenuPage:openSalaryRaiseDialog()
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.salaryRaiseRows = self:buildSalaryRaiseRows()
    self.salaryRaiseSelectedIndex = 1
    self.salaryRaiseFirstIndex = 1
    self.salaryRaiseDialogOpen = true
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:closeSalaryRaiseDialog()
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    self.salaryRaiseSelectedIndex = 1
    self.salaryRaiseFirstIndex = 1
    self:refresh()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:ensureSalaryRaiseSelectionVisible()
    local count = #self.salaryRaiseRows
    local visible = math.max(1, self.salaryRaiseVisibleRows or 10)
    self.salaryRaiseSelectedIndex = hpMenuClamp(self.salaryRaiseSelectedIndex or 1, 1, math.max(count, 1))
    self.salaryRaiseFirstIndex = hpMenuClamp(self.salaryRaiseFirstIndex or 1, 1, math.max(1, count - visible + 1))

    if self.salaryRaiseSelectedIndex < self.salaryRaiseFirstIndex then
        self.salaryRaiseFirstIndex = self.salaryRaiseSelectedIndex
    elseif self.salaryRaiseSelectedIndex >= self.salaryRaiseFirstIndex + visible then
        self.salaryRaiseFirstIndex = self.salaryRaiseSelectedIndex - visible + 1
    end
end

function HelperPersonnelMenuPage:moveSalaryRaiseSelection(delta)
    local count = #self.salaryRaiseRows
    if count == 0 then
        return false
    end

    self.salaryRaiseSelectedIndex = hpMenuClamp((self.salaryRaiseSelectedIndex or 1) + delta, 1, count)
    self:ensureSalaryRaiseSelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:getSalaryRaiseWorker(row)
    local manager = self:getManager()
    if row == nil or manager == nil or manager.getWorkerById == nil then
        return nil
    end
    return manager:getWorkerById(row.workerId)
end

function HelperPersonnelMenuPage:getSalaryRaiseWageText(worker, requested)
    local manager = self:getManager()
    if worker == nil or manager == nil then
        return "-"
    end

    local baseWage = requested == true and worker.salaryRaiseTargetBaseWage or worker.salaryRaisePreviousBaseWage
    baseWage = tonumber(baseWage) or tonumber(worker.baseWage) or 0
    if manager.getMonthlyWageTextFromBase ~= nil then
        return manager:getMonthlyWageTextFromBase(baseWage)
    end
    if manager.formatMoneyForText ~= nil then
        return manager:formatMoneyForText(baseWage)
    end
    return string.format("%d €", math.floor(baseWage + 0.5))
end

function HelperPersonnelMenuPage:decideSalaryRaiseRequest(acceptRequest)
    if not self:canManageCurrentFarm() then
        return false
    end

    local index = self.salaryRaiseSelectedIndex or 1
    local row = self.salaryRaiseRows[index]
    local worker = self:getSalaryRaiseWorker(row)
    if worker == nil or worker.salaryRaisePending ~= true or self.app == nil then
        return false
    end

    local changed = false
    if acceptRequest == true and self.app.requestGrantSalaryRaise ~= nil then
        changed = self.app:requestGrantSalaryRaise(worker.id) == true
    elseif acceptRequest ~= true and self.app.requestDeclineSalaryRaise ~= nil then
        changed = self.app:requestDeclineSalaryRaise(worker.id) == true
    end

    if changed then
        table.remove(self.salaryRaiseRows, index)
        self.salaryRaiseSelectedIndex = hpMenuClamp(index, 1, math.max(#self.salaryRaiseRows, 1))
        self:ensureSalaryRaiseSelectionVisible()
        self:updateButtons()
        self.requestRender = true
    end

    return changed
end

function HelperPersonnelMenuPage:movePersonSelection(delta)
    if self.pageKind == "overview" then
        return false
    end

    local entries, isApplicant = self:getCurrentEntries()
    if #entries <= 0 then
        return false
    end

    if isApplicant then
        self.applicantIndex = self.applicantIndex + delta
        if self.applicantIndex < 1 then
            self.applicantIndex = #entries
        elseif self.applicantIndex > #entries then
            self.applicantIndex = 1
        end
    else
        self.workerIndex = self.workerIndex + delta
        if self.workerIndex < 1 then
            self.workerIndex = #entries
        elseif self.workerIndex > #entries then
            self.workerIndex = 1
        end
    end

    if self.pageKind == "training" then
        self.selectedTrainingCategoryKey = nil
        self.selectedTrainingWorkerId = nil
    end

    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:showConfirmDialog(text, callback, person)
    if YesNoDialog ~= nil and YesNoDialog.show ~= nil then
        YesNoDialog.show(function(target, clickOk, data)
            if clickOk == true and callback ~= nil then
                callback(target, data)
            end
        end, self, text, nil, nil, nil, nil, nil, nil, person)
        return true
    end

    if callback ~= nil then
        callback(self, person)
    end

    return true
end

function HelperPersonnelMenuPage:showTrainingInfoText(text)
    text = tostring(text or "")

    if InfoDialog ~= nil and InfoDialog.show ~= nil then
        InfoDialog.show(text)
        return true
    end

    if self.app ~= nil and self.app.showIngameNotificationLocal ~= nil then
        self.app:showIngameNotificationLocal(text)
        return true
    end

    if self.app ~= nil and self.app.showPlayerMessage ~= nil then
        self.app:showPlayerMessage(text)
        return true
    end

    return false
end

function HelperPersonnelMenuPage:showTrainingInfoMessage(textKey, fallback)
    return self:showTrainingInfoText(self:getText(textKey, fallback))
end

function HelperPersonnelMenuPage:showTrainingCategoryRequiredMessage()
    return self:showTrainingInfoMessage("ui_pmTrainingSelectCategory", "Erst Schulungskategorie auswählen")
end

function HelperPersonnelMenuPage:onClickPrimaryAction()
    if not self:canManageCurrentFarm() then
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage("ui_pmMenuNoPermission")
        end
        return false
    end

    local person = self:getCurrentPerson()
    if person == nil then
        return false
    end

    if self.pageKind == "applicants" then
        local text = self:formatText("ui_pmConfirmHire", "%s wirklich einstellen?", self:getPersonName(person))
        return self:showConfirmDialog(text, self.onConfirmHire, person)
    elseif self.pageKind == "training" then
        local manager = self:getManager()
        if manager ~= nil and manager.canTrainWorkerThisYear ~= nil and not manager:canTrainWorkerThisYear(person) then
            local message = self:formatText("ui_training_already_done_year", "%s wurde in diesem Jahr bereits geschult.", self:getPersonName(person))
            self:showTrainingInfoText(message)
            return true
        end

        if person.busy == true then
            self:showTrainingInfoMessage("ui_training_worker_busy", "Der Mitarbeiter ist gerade im Einsatz und kann nicht geschult werden.")
            return true
        end

        if manager ~= nil and manager.isWorkerSick ~= nil and manager:isWorkerSick(person) then
            self:showTrainingInfoMessage("ui_training_worker_sick", "Der Mitarbeiter ist krank und kann nicht geschult werden.")
            return true
        end

        if manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person) then
            self:showTrainingInfoMessage("ui_training_worker_in_training", "Der Mitarbeiter ist bereits bis Monatsende in Schulung.")
            return true
        end

        local specializationKey = self.selectedTrainingCategoryKey
        if specializationKey == nil or specializationKey == "" then
            self:showTrainingCategoryRequiredMessage()
            return true
        end

        if manager ~= nil and manager.getWorkerTrainingCostDetails ~= nil then
            local _, _, _, available = manager:getWorkerTrainingCostDetails(person, specializationKey)
            if not available then
                self:showTrainingInfoMessage("ui_pmTrainingNoPlacesMessage", "Für diese Schulung sind aktuell keine Plätze frei.")
                return true
            end
        end

        local specializationName = manager ~= nil and manager.getSpecializationDisplayName ~= nil and manager:getSpecializationDisplayName(specializationKey) or tostring(specializationKey)
        local text = self:formatText("ui_pmTrainingConfirm", "Schulung für %s in der Kategorie %s starten?", self:getPersonName(person), specializationName)
        return self:showConfirmDialog(text, self.onConfirmTraining, {person = person, specializationKey = specializationKey})
    elseif self.pageKind == "settings" then
        return false
    end

    if person.dismissalPending == true then
        local message = self:formatText("ui_fireDeniedPending", "%s wurde bereits gekündigt. Er wird den Betrieb nach Ende der Kündigungsfrist verlassen.", self:getPersonName(person))
        self:showTrainingInfoText(message)
        return true
    end

    local text = self:formatText("ui_pmConfirmDismiss", "%s wirklich kündigen?", self:getPersonName(person))
    return self:showConfirmDialog(text, self.onConfirmDismiss, person)
end

function HelperPersonnelMenuPage:onConfirmHire(person)
    if person == nil or self.app == nil or self.app.requestHireApplicant == nil then
        return false
    end

    local changed = self.app:requestHireApplicant(person.id) == true
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:onConfirmDismiss(person)
    if person == nil or self.app == nil or self.app.requestDismissWorker == nil then
        return false
    end

    local changed = self.app:requestDismissWorker(person.id) == true
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:onConfirmTraining(trainingData)
    local person = trainingData ~= nil and trainingData.person or trainingData
    local specializationKey = trainingData ~= nil and trainingData.specializationKey or self.selectedTrainingCategoryKey
    if person == nil or specializationKey == nil or self.app == nil or self.app.requestTrainWorker == nil then
        return false
    end

    local changed = self.app:requestTrainWorker(person.id, specializationKey) == true
    if changed then
        self.selectedTrainingCategoryKey = nil
    end
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:keyEvent(unicode, sym, modifier, isDown)
    if not self:isCurrentMenuPage() then
        return false
    end

    if not isDown then
        return false
    end

    if self.salaryRaiseDialogOpen == true then
        if sym == hpMenuGetInputConstant("KEY_escape", nil) then
            return self:closeSalaryRaiseDialog()
        elseif sym == hpMenuGetInputConstant("KEY_up", nil) or sym == hpMenuGetInputConstant("KEY_upArrow", nil) or sym == hpMenuGetInputConstant("KEY_w", nil) then
            return self:moveSalaryRaiseSelection(-1)
        elseif sym == hpMenuGetInputConstant("KEY_down", nil) or sym == hpMenuGetInputConstant("KEY_downArrow", nil) or sym == hpMenuGetInputConstant("KEY_s", nil) then
            return self:moveSalaryRaiseSelection(1)
        elseif sym == hpMenuGetInputConstant("KEY_return", nil) or sym == hpMenuGetInputConstant("KEY_enter", nil) or sym == hpMenuGetInputConstant("KEY_space", nil) then
            return true
        end
        return true
    end

    if self.transportPriorityDialogOpen == true then
        if sym == hpMenuGetInputConstant("KEY_escape", nil) then
            return self:closeTransportPriorityDialog()
        elseif sym == hpMenuGetInputConstant("KEY_up", nil) or sym == hpMenuGetInputConstant("KEY_upArrow", nil) or sym == hpMenuGetInputConstant("KEY_w", nil) then
            return self:moveTransportPrioritySelection(-1)
        elseif sym == hpMenuGetInputConstant("KEY_down", nil) or sym == hpMenuGetInputConstant("KEY_downArrow", nil) or sym == hpMenuGetInputConstant("KEY_s", nil) then
            return self:moveTransportPrioritySelection(1)
        elseif sym == hpMenuGetInputConstant("KEY_left", nil) or sym == hpMenuGetInputConstant("KEY_leftArrow", nil) or sym == hpMenuGetInputConstant("KEY_a", nil) then
            return self:moveTransportPriorityRow(-1)
        elseif sym == hpMenuGetInputConstant("KEY_right", nil) or sym == hpMenuGetInputConstant("KEY_rightArrow", nil) or sym == hpMenuGetInputConstant("KEY_d", nil) then
            return self:moveTransportPriorityRow(1)
        elseif sym == hpMenuGetInputConstant("KEY_space", nil) then
            return self:toggleTransportPriorityRow()
        elseif sym == hpMenuGetInputConstant("KEY_return", nil) or sym == hpMenuGetInputConstant("KEY_enter", nil) then
            return true
        end
        return true
    end

    if sym == hpMenuGetInputConstant("KEY_escape", nil) then
        return self:onClickBack()
    elseif sym == hpMenuGetInputConstant("KEY_left", nil) or sym == hpMenuGetInputConstant("KEY_leftArrow", nil) or sym == hpMenuGetInputConstant("KEY_a", nil) then
        if self:movePersonSelection(-1) then
            return true
        end
    elseif sym == hpMenuGetInputConstant("KEY_right", nil) or sym == hpMenuGetInputConstant("KEY_rightArrow", nil) or sym == hpMenuGetInputConstant("KEY_d", nil) then
        if self:movePersonSelection(1) then
            return true
        end
    elseif sym == hpMenuGetInputConstant("KEY_return", nil) or sym == hpMenuGetInputConstant("KEY_enter", nil) then
        return true
    end

    return HelperPersonnelMenuPage:superClass().keyEvent(self, unicode, sym, modifier, isDown)
end

function HelperPersonnelMenuPage:getVisibleDotRange(index, count)
    local maxDots = 9
    if count <= maxDots then
        return 1, count
    end

    local halfWindow = math.floor(maxDots * 0.5)
    local startIndex = math.max(1, index - halfWindow)
    startIndex = math.min(startIndex, count - maxDots + 1)

    return startIndex, maxDots
end

function HelperPersonnelMenuPage:drawPersonPager(index, count)
    if count <= 0 then
        return
    end

    local buttonHeight = 0.044
    local buttonWidth = hpMenuGetAspectCorrectWidth(buttonHeight)
    local buttonY = 0.753
    local leftX = 0.255
    local rightX = 0.745

    if self.navArrowLeftOverlay ~= nil then
        self.navArrowLeftOverlay:setPosition(leftX, buttonY)
        self.navArrowLeftOverlay:setDimension(buttonWidth, buttonHeight)
        self.navArrowLeftOverlay:render()
    else
        self:drawTextLine(leftX + buttonWidth * 0.5, buttonY + buttonHeight * 0.5, 0.020, RenderText.ALIGN_CENTER, "<", 0.61, 0.73, 0.07, 1, true)
    end

    if self.navArrowRightOverlay ~= nil then
        self.navArrowRightOverlay:setPosition(rightX, buttonY)
        self.navArrowRightOverlay:setDimension(buttonWidth, buttonHeight)
        self.navArrowRightOverlay:render()
    else
        self:drawTextLine(rightX + buttonWidth * 0.5, buttonY + buttonHeight * 0.5, 0.020, RenderText.ALIGN_CENTER, ">", 0.61, 0.73, 0.07, 1, true)
    end

    self:addClickArea(leftX, buttonY, buttonWidth, buttonHeight, "prevPerson", nil)
    self:addClickArea(rightX, buttonY, buttonWidth, buttonHeight, "nextPerson", nil)

    local startIndex, visibleDots = self:getVisibleDotRange(index, count)
    local dotHeight = 0.011
    local dotWidth = hpMenuGetAspectCorrectWidth(dotHeight)
    local dotSpacing = dotWidth + 0.005
    local centerX = 0.52
    local firstX = centerX - (((visibleDots - 1) * dotSpacing) + dotWidth) * 0.5
    local dotY = 0.772

    for dot = 1, visibleDots do
        local realIndex = startIndex + dot - 1
        local x = firstX + (dot - 1) * dotSpacing
        local overlay = realIndex == index and self.navDotActiveOverlay or self.navDotInactiveOverlay
        if overlay ~= nil then
            overlay:setPosition(x, dotY)
            overlay:setDimension(dotWidth, dotHeight)
            overlay:render()
        else
            local c = realIndex == index and 0.61 or 0.56
            self:drawTextLine(x + dotWidth * 0.5, dotY + dotHeight * 0.5, 0.012, RenderText.ALIGN_CENTER, "•", c, c, c, 1, true)
        end
    end
end

function HelperPersonnelMenuPage:handleMouseClick(posX, posY)
    if self.salaryRaiseDialogOpen == true then
        for i = #(self.clickAreas or {}), 1, -1 do
            local area = self.clickAreas[i]
            if area ~= nil and self:isPointInClickArea(posX, posY, area) and area.action == "salaryRaiseSelect" then
                self.salaryRaiseSelectedIndex = area.index or 1
                self:ensureSalaryRaiseSelectionVisible()
                self:updateButtons()
                self.requestRender = true
                return true
            end
        end
        return true
    end

    if self.transportPriorityDialogOpen == true then
        for i = #(self.clickAreas or {}), 1, -1 do
            local area = self.clickAreas[i]
            if area ~= nil and self:isPointInClickArea(posX, posY, area) then
                if area.action == "transportPrioritySelect" then
                    self.transportPrioritySelectedIndex = area.index or 1
                    self:ensureTransportPrioritySelectionVisible()
                    self:updateButtons()
                    self.requestRender = true
                    return true
                end
            end
        end
        return true
    end

    for i = #(self.clickAreas or {}), 1, -1 do
        local area = self.clickAreas[i]
        if area ~= nil and self:isPointInClickArea(posX, posY, area) then
            if area.action == "prevPerson" then
                return self:movePersonSelection(-1)
            elseif area.action == "nextPerson" then
                return self:movePersonSelection(1)
            elseif type(area.action) == "string" and string.sub(area.action, 1, 17) == "trainingCategory:" then
                return self:selectTrainingCategory(string.sub(area.action, 18))
            end
        end
    end

    return HelperPersonnelMenuPage:superClass().handleMouseClick(self, posX, posY)
end

function HelperPersonnelMenuPage:draw()
    HelperPersonnelViewBase:superClass().draw(self)
    self:resetClickAreas()

    if self.salaryRaiseDialogOpen == true then
        self:drawSalaryRaiseDialog()
        return
    end

    if self.transportPriorityDialogOpen == true then
        self:drawTransportPriorityDialog()
        return
    end

    if self.pageKind == "overview" then
        self:drawStandaloneHeader()

        if self.overviewBrandOverlay ~= nil then
            local baseImageHeight = 0.155
            local baseImageWidth = hpMenuGetAspectCorrectWidth(baseImageHeight) * 2

            if baseImageWidth > 0.18 then
                baseImageWidth = 0.18
                local screenWidth = tonumber(g_screenWidth) or 1
                local screenHeight = tonumber(g_screenHeight) or 1
                if screenHeight > 0 then
                    baseImageHeight = baseImageWidth * (screenWidth / screenHeight) * 0.5
                end
            end

            local anchorRight = 0.985 - baseImageWidth
            local anchorTop = 0.715 + baseImageHeight
            local imageWidth = baseImageWidth * 1.5
            local imageHeight = baseImageHeight * 1.5
            self.overviewBrandOverlay:setPosition(anchorRight - imageWidth, anchorTop - imageHeight)
            self.overviewBrandOverlay:setDimension(imageWidth, imageHeight)
            self.overviewBrandOverlay:render()
        end

        self:drawOverview()
    elseif self.pageKind == "settings" then
        self:drawStandaloneHeader()
        self:drawTextLine(0.22, 0.790, 0.014, RenderText.ALIGN_LEFT, self:getText("ui_pmSettingsInfo", "Die Einstellungen werden über die nativen Auswahlzeilen geändert."), 1, 1, 1, 1, false)
    elseif self.pageKind == "training" then
        self:drawTrainingPage()
    else
        self:drawPersonDetailPage()
    end

end

function HelperPersonnelMenuPage:drawSalaryRaiseDialog()
    self:ensureSalaryRaiseSelectionVisible()

    self:drawSolidRect(0, 0, 1, 1, 0, 0, 0, 0.62)
    local x = 0.18
    local y = 0.145
    local width = 0.64
    local height = 0.71
    self:drawSolidRect(x, y, width, height, 0.055, 0.062, 0.070, 1)
    self:drawSolidRect(x, y + height - 0.008, width, 0.008, 0.61, 0.73, 0.07, 1)

    self:drawTextLine(x + 0.025, y + height - 0.058, 0.026, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsTitle", "Gehaltsforderungen verwalten"), 1, 1, 1, 1, true)
    local intro = self:getText("ui_salaryRequestsIntro", "Hier werden alle offenen Gehaltsforderungen angezeigt. Wähle einen Mitarbeiter aus und entscheide, ob die Forderung angenommen oder abgelehnt wird.")
    local introLines = self:getWrappedHistoryLines(intro, 0.0115, width - 0.05, 118)
    local introY = y + height - 0.092
    for index = 1, math.min(#introLines, 3) do
        self:drawTextLine(x + 0.025, introY, 0.0115, RenderText.ALIGN_LEFT, introLines[index], 0.91, 0.91, 0.91, 1, false)
        introY = introY - 0.017
    end

    local tableX = x + 0.025
    local tableWidth = width - 0.05
    local headerY = y + height - 0.158
    local nameX = tableX + 0.015
    local currentX = tableX + 0.34
    local requestedX = tableX + tableWidth - 0.015
    self:drawTextLine(nameX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsHeaderEmployee", "Mitarbeiter"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(currentX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsHeaderCurrent", "Aktuelles Gehalt"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(requestedX, headerY, 0.0118, RenderText.ALIGN_RIGHT, self:getText("ui_salaryRequestsHeaderRequested", "Gefordertes Gehalt"), 0.61, 0.73, 0.07, 1, true)
    self:drawSeparator(tableX, headerY - 0.014, tableWidth)

    local rows = self.salaryRaiseRows or {}
    if #rows == 0 then
        self:drawTextLine(tableX + 0.012, headerY - 0.065, 0.015, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsNoRequests", "Keine offenen Gehaltsforderungen."), 1, 1, 1, 1, false)
    else
        local rowHeight = 0.044
        local rowGap = 0.004
        local firstRowY = headerY - 0.067
        local visible = math.max(1, self.salaryRaiseVisibleRows or 10)
        local lastIndex = math.min(#rows, self.salaryRaiseFirstIndex + visible - 1)
        for index = self.salaryRaiseFirstIndex, lastIndex do
            local visibleIndex = index - self.salaryRaiseFirstIndex
            local rowY = firstRowY - visibleIndex * (rowHeight + rowGap)
            local selected = index == self.salaryRaiseSelectedIndex
            local row = rows[index]
            local worker = self:getSalaryRaiseWorker(row)
            local shade = index % 2 == 0 and 0.145 or 0.115
            if selected then
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, 0.31, 0.38, 0.06, 0.94)
            else
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, shade, shade, shade, 0.86)
            end

            local textY = rowY + (rowHeight - 0.0125) * 0.5
            local name = worker ~= nil and self:getPersonName(worker) or tostring(row.workerId or "")
            local currentText = self:getSalaryRaiseWageText(worker, false)
            local requestedText = self:getSalaryRaiseWageText(worker, true)
            self:drawTextLine(nameX, textY, 0.0125, RenderText.ALIGN_LEFT, name, 1, 1, 1, 1, true)
            self:drawTextLine(currentX, textY, 0.0120, RenderText.ALIGN_LEFT, currentText, 0.88, 0.88, 0.88, 1, false)
            self:drawTextLine(requestedX, textY, 0.0120, RenderText.ALIGN_RIGHT, requestedText, 0.70, 0.88, 0.12, 1, true)
            self:addClickArea(tableX, rowY, tableWidth, rowHeight, "salaryRaiseSelect", index)
        end

        if #rows > visible then
            local scrollbarX = tableX + tableWidth + 0.006
            local scrollbarY = firstRowY - (visible - 1) * (rowHeight + rowGap)
            local scrollbarHeight = visible * rowHeight + (visible - 1) * rowGap
            self:drawSolidRect(scrollbarX, scrollbarY, 0.004, scrollbarHeight, 0.18, 0.18, 0.18, 0.95)
            local thumbHeight = math.max(0.035, scrollbarHeight * (visible / #rows))
            local maxFirst = math.max(1, #rows - visible + 1)
            local ratio = maxFirst > 1 and ((self.salaryRaiseFirstIndex - 1) / (maxFirst - 1)) or 0
            local thumbY = scrollbarY + scrollbarHeight - thumbHeight - ratio * (scrollbarHeight - thumbHeight)
            self:drawSolidRect(scrollbarX, thumbY, 0.004, thumbHeight, 0.61, 0.73, 0.07, 1)
        end
    end

    self:drawTextLine(x + 0.025, y + 0.025, 0.0108, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsControls", "Pfeil hoch/runter: auswählen | Enter: annehmen | Leertaste: ablehnen"), 0.82, 0.82, 0.82, 1, false)
end

function HelperPersonnelMenuPage:drawTransportPriorityDialog()
    self:ensureTransportPrioritySelectionVisible()

    self:drawSolidRect(0, 0, 1, 1, 0, 0, 0, 0.62)
    local x = 0.18
    local y = 0.145
    local width = 0.64
    local height = 0.71
    self:drawSolidRect(x, y, width, height, 0.055, 0.062, 0.070, 1)
    self:drawSolidRect(x, y + height - 0.008, width, 0.008, 0.61, 0.73, 0.07, 1)

    self:drawTextLine(x + 0.025, y + height - 0.058, 0.026, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityTitle", "Transportaufgaben verwalten"), 1, 1, 1, 1, true)
    local intro = self:getText("ui_transportPriorityIntro", "Aktiviere Mitarbeiter für Transportaufgaben und lege ihre Reihenfolge fest. Bei einem neuen Transportauftrag wird von oben nach unten der erste freie Mitarbeiter ausgewählt.")
    local introLines = self:getWrappedHistoryLines(intro, 0.0115, width - 0.05, 118)
    local introY = y + height - 0.092
    for index = 1, math.min(#introLines, 3) do
        self:drawTextLine(x + 0.025, introY, 0.0115, RenderText.ALIGN_LEFT, introLines[index], 0.91, 0.91, 0.91, 1, false)
        introY = introY - 0.017
    end

    local tableX = x + 0.025
    local tableWidth = width - 0.05
    local headerY = y + height - 0.158
    local priorityX = tableX + 0.015
    local nameX = tableX + 0.085
    local statusX = tableX + 0.355
    local enabledX = tableX + tableWidth - 0.015
    self:drawTextLine(priorityX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityHeaderPriority", "Priorität"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(nameX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityHeaderEmployee", "Mitarbeiter"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(statusX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityHeaderStatus", "Status"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(enabledX, headerY, 0.0118, RenderText.ALIGN_RIGHT, self:getText("ui_transportPriorityHeaderEnabled", "Transport"), 0.61, 0.73, 0.07, 1, true)
    self:drawSeparator(tableX, headerY - 0.014, tableWidth)

    local rows = self.transportPriorityRows or {}
    if #rows == 0 then
        self:drawTextLine(tableX + 0.012, headerY - 0.065, 0.015, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityNoWorkers", "Keine Mitarbeiter vorhanden."), 1, 1, 1, 1, false)
        return
    end

    local rowHeight = 0.044
    local rowGap = 0.004
    local firstRowY = headerY - 0.067
    local visible = math.max(1, self.transportPriorityVisibleRows or 10)
    local lastIndex = math.min(#rows, self.transportPriorityFirstIndex + visible - 1)
    local activePosition = 0
    for index = 1, #rows do
        if rows[index].enabled == true then
            activePosition = activePosition + 1
        end
        if index >= self.transportPriorityFirstIndex and index <= lastIndex then
            local visibleIndex = index - self.transportPriorityFirstIndex
            local rowY = firstRowY - visibleIndex * (rowHeight + rowGap)
            local selected = index == self.transportPrioritySelectedIndex
            local row = rows[index]
            local worker = self:getTransportPriorityWorker(row)
            local shade = index % 2 == 0 and 0.145 or 0.115
            if selected then
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, 0.31, 0.38, 0.06, 0.94)
            else
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, shade, shade, shade, 0.86)
            end

            local textY = rowY + (rowHeight - 0.0125) * 0.5
            local priorityText = row.enabled == true and tostring(activePosition) or "–"
            local name = worker ~= nil and self:getPersonName(worker) or tostring(row.workerId or "")
            local manager = self:getManager()
            local status = worker ~= nil and manager ~= nil and manager.getStatusText ~= nil and manager:getStatusText(worker) or ""
            local enabledText = row.enabled == true and self:getText("ui_transportPriorityActive", "Aktiv") or self:getText("ui_transportPriorityInactive", "Inaktiv")
            local value = row.enabled == true and 1 or 0.62
            self:drawTextLine(priorityX, textY, 0.0125, RenderText.ALIGN_LEFT, priorityText, value, value, value, 1, true)
            self:drawTextLine(nameX, textY, 0.0125, RenderText.ALIGN_LEFT, name, value, value, value, 1, true)
            self:drawTextLine(statusX, textY, 0.0114, RenderText.ALIGN_LEFT, status, value, value, value, 1, false)
            self:drawTextLine(enabledX, textY, 0.0120, RenderText.ALIGN_RIGHT, enabledText, row.enabled == true and 0.70 or 0.72, row.enabled == true and 0.88 or 0.72, row.enabled == true and 0.12 or 0.72, 1, true)
            self:addClickArea(tableX, rowY, tableWidth, rowHeight, "transportPrioritySelect", index)
        end
    end

    if #rows > visible then
        local scrollbarX = tableX + tableWidth + 0.006
        local scrollbarY = firstRowY - (visible - 1) * (rowHeight + rowGap)
        local scrollbarHeight = visible * rowHeight + (visible - 1) * rowGap
        self:drawSolidRect(scrollbarX, scrollbarY, 0.004, scrollbarHeight, 0.18, 0.18, 0.18, 0.95)
        local thumbHeight = math.max(0.035, scrollbarHeight * (visible / #rows))
        local maxFirst = math.max(1, #rows - visible + 1)
        local ratio = maxFirst > 1 and ((self.transportPriorityFirstIndex - 1) / (maxFirst - 1)) or 0
        local thumbY = scrollbarY + scrollbarHeight - thumbHeight - ratio * (scrollbarHeight - thumbHeight)
        self:drawSolidRect(scrollbarX, thumbY, 0.004, thumbHeight, 0.61, 0.73, 0.07, 1)
    end

    self:drawTextLine(x + 0.025, y + 0.025, 0.0108, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityControls", "Pfeil hoch/runter: auswählen | links/rechts: verschieben | Leertaste: aktivieren/deaktivieren"), 0.82, 0.82, 0.82, 1, false)
end

function HelperPersonnelMenuPage:getTrainingCategoryRows(person)
    local rows = {}
    local manager = self:getManager()
    if person == nil or manager == nil then
        return rows
    end

    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local specializationKey = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(key) or key
        if specializationKey ~= nil then
            local acquired = manager.workerHasSpecialization ~= nil and manager:workerHasSpecialization(person, specializationKey) == true
            local progressPercent = 100
            if not acquired then
                local minutes = manager.getSpecializationProgressMinutes ~= nil and manager:getSpecializationProgressMinutes(person, specializationKey) or 0
                progressPercent = manager.getSpecializationProgressPercentForMinutes ~= nil and manager:getSpecializationProgressPercentForMinutes(person, minutes) or 0
            end
            local trainingActive = manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person) and manager:normalizeSpecializationKey(person.trainingActiveSpecialization) == specializationKey
            local finalCost, baseCost, costDifference, available, modifierPercent = 0, 0, 0, true, 0
            if manager.getWorkerTrainingCostDetails ~= nil then
                finalCost, baseCost, costDifference, available, modifierPercent = manager:getWorkerTrainingCostDetails(person, specializationKey)
            elseif manager.getWorkerTrainingCost ~= nil then
                finalCost = manager:getWorkerTrainingCost(person, specializationKey)
                baseCost = finalCost
            end
            rows[#rows + 1] = {
                key = specializationKey,
                name = manager.getSpecializationDisplayName ~= nil and manager:getSpecializationDisplayName(specializationKey) or tostring(specializationKey),
                progress = math.max(0, math.min(100, tonumber(progressPercent) or 0)),
                acquired = acquired,
                trainingActive = trainingActive,
                cost = math.max(0, tonumber(finalCost) or 0),
                baseCost = math.max(0, tonumber(baseCost) or 0),
                costDifference = tonumber(costDifference) or 0,
                modifierPercent = tonumber(modifierPercent) or 0,
                available = available ~= false
            }
        end
    end

    return rows
end

function HelperPersonnelMenuPage:selectTrainingCategory(specializationKey)
    if self.pageKind ~= "training" then
        return false
    end

    local person = self:getCurrentPerson()
    local manager = self:getManager()
    if person == nil or manager == nil then
        return false
    end

    specializationKey = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(specializationKey) or specializationKey
    if specializationKey == nil then
        return false
    end

    if manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person) then
        return true
    end

    if manager.getWorkerTrainingCostDetails ~= nil then
        local _, _, _, available = manager:getWorkerTrainingCostDetails(person, specializationKey)
        if not available then
            return true
        end
    end

    if manager.workerHasSpecialization ~= nil and manager:workerHasSpecialization(person, specializationKey) then
        return true
    end

    local primary = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(person.specializationPrimary) or person.specializationPrimary
    local secondary = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(person.specializationSecondary) or person.specializationSecondary
    if primary ~= nil and secondary ~= nil then
        return true
    end

    local isKnown = false
    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local normalized = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(key) or key
        if normalized == specializationKey then
            isKnown = true
            break
        end
    end
    if not isKnown then
        return false
    end

    self.selectedTrainingWorkerId = person.id
    self.selectedTrainingCategoryKey = specializationKey
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:drawTrainingPage()
    local person, _, entries = self:getCurrentPerson()
    local title = self:getText(self.pageTitleKey, self.pageTitleFallback)
    local count = entries ~= nil and #entries or 0

    self:drawTextLine(0.22, 0.850, 0.030, RenderText.ALIGN_LEFT, title, 1, 1, 1, 1, true)
    self:drawSeparator(0.22, 0.815, 0.62)

    if not self:canManageCurrentFarm() then
        self:drawTextLine(0.22, 0.792, 0.013, RenderText.ALIGN_LEFT, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen."), 1, 0.55, 0.2, 1, true)
    end

    if person == nil then
        self:drawTextLine(0.22, 0.735, 0.018, RenderText.ALIGN_LEFT, self:getText("ui_noWorkersDetail", "Keine Mitarbeiter vorhanden"), 1, 1, 1, 1, true)
        return
    end

    if self.selectedTrainingWorkerId ~= person.id then
        self.selectedTrainingWorkerId = person.id
        self.selectedTrainingCategoryKey = nil
    end

    self:drawPersonPager(self.workerIndex or 1, count)
    self:drawPersonPortrait(person, 0.22, 0.535, 0.150, 0.210, true)
    self:drawTextLine(0.405, 0.725, 0.024, RenderText.ALIGN_LEFT, self:getPersonName(person), 1, 1, 1, 1, true)
    self:drawPersonCoreBlock(person, false)

    self:drawSeparator(0.22, 0.500, 0.62)

    local intro = self:getText("ui_pmTrainingIntro", "Spezialisierungen verbessern die Leistung eines Mitarbeiters in der jeweiligen Lernkategorie. Eine Schulung dauert bis zum Ende des aktuellen Monats; während dieser Zeit steht der Mitarbeiter nicht für Einsätze zur Verfügung. Der Lernfortschritt wird erst nach Abschluss der Schulung gutgeschrieben. Nicht für jede Kategorie wird in jedem Monat eine Schulung angeboten. Schulungen können gegenüber dem regulären Preis günstiger oder teurer sein. Pro Landwirtschaftsjahr von März bis Februar kann jeder Mitarbeiter nur eine Schulung absolvieren. Jeder Mitarbeiter kann maximal zwei Spezialisierungen erwerben. Wähle die gewünschte Lernkategorie aus.")
    local introLines = self:getWrappedHistoryLines(intro, 0.0107, 0.62, 116)
    local introY = 0.475
    for i = 1, math.min(#introLines, 6) do
        self:drawTextLine(0.22, introY, 0.0107, RenderText.ALIGN_LEFT, introLines[i], 0.92, 0.92, 0.92, 1, false)
        introY = introY - 0.0165
    end

    local tableX = 0.22
    local tableWidth = 0.62
    local progressBarX = 0.405
    local progressBarWidth = 0.105
    local progressX = 0.595
    local costX = 0.735
    local adjustmentX = 0.835
    local headerY = 0.379
    self:drawTextLine(tableX + 0.012, headerY, 0.0120, RenderText.ALIGN_LEFT, self:getText("ui_pmTrainingCategoryHeader", "Lernkategorie"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(progressX, headerY, 0.0115, RenderText.ALIGN_RIGHT, self:getText("ui_pmTrainingProgressHeader", "Fortschritt bis zur Spezialisierung"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(costX, headerY, 0.0120, RenderText.ALIGN_RIGHT, self:getText("ui_pmTrainingCostHeader", "Kosten"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(adjustmentX, headerY, 0.0117, RenderText.ALIGN_RIGHT, self:getText("ui_pmTrainingAdjustmentHeader", "Rabatt/Mehrkosten"), 0.61, 0.73, 0.07, 1, true)
    self:drawSeparator(tableX, headerY - 0.016, tableWidth)

    local manager = self:getManager()
    local rows = self:getTrainingCategoryRows(person)
    local screenHeight = math.max(1, math.floor((tonumber(g_screenHeight) or 1080) + 0.5))
    local rowHeightPixels = math.max(1, math.floor((screenHeight * 0.0310) + 0.5))
    local rowGapPixels = math.max(1, math.floor((screenHeight * 0.0030) + 0.5))
    local firstRowYPixels = math.floor((screenHeight * 0.330) + 0.5)
    local rowHeight = rowHeightPixels / screenHeight
    local workerInTraining = manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person)
    local hasTwoSpecializations = person.specializationPrimary ~= nil and person.specializationPrimary ~= "" and person.specializationSecondary ~= nil and person.specializationSecondary ~= ""

    for index, row in ipairs(rows) do
        local yPixels = firstRowYPixels - ((index - 1) * (rowHeightPixels + rowGapPixels))
        local y = yPixels / screenHeight
        local selected = self.selectedTrainingCategoryKey == row.key
        local selectable = not row.acquired and not hasTwoSpecializations and not workerInTraining and row.available == true
        local background = selected and 0.27 or (index % 2 == 0 and 0.145 or 0.115)
        local alpha = selected and 0.90 or 0.66
        local r, g, b = background, background, background
        if selected or row.trainingActive then
            r, g, b = 0.31, 0.38, 0.06
            alpha = 0.90
        end
        self:drawSolidRect(tableX, y, tableWidth, rowHeight, r, g, b, alpha)

        local textColor = (selectable or row.trainingActive) and 1 or 0.58
        local mainTextSize = 0.0122
        local moneyTextSize = 0.0114
        local mainTextY = y + (rowHeight - mainTextSize) * 0.5
        local moneyTextY = y + (rowHeight - moneyTextSize) * 0.5
        self:drawTextLine(tableX + 0.012, mainTextY, mainTextSize, RenderText.ALIGN_LEFT, row.name, textColor, textColor, textColor, 1, true)

        local progressBarHeight = math.min(0.010, rowHeight * 0.38)
        local progressBarY = y + (rowHeight - progressBarHeight) * 0.5
        local progressAlpha = (selectable or row.trainingActive or row.acquired) and 1 or 0.48
        self:drawProgressBar(progressBarX, progressBarY, progressBarWidth, progressBarHeight, row.progress, 100, 0.61, 0.73, 0.07, progressAlpha, false)

        local progressText
        local progressTextSize = mainTextSize
        if row.trainingActive then
            progressText = self:getText("ui_pmTrainingRunning", "laufende Schulung")
            progressTextSize = 0.0094
        else
            progressText = string.format("%d %%", math.floor(row.progress + 0.5))
        end
        self:drawTextLine(progressX, mainTextY, progressTextSize, RenderText.ALIGN_RIGHT, progressText, textColor, textColor, textColor, 1, true)

        local costText = ""
        local adjustmentText = ""
        if row.available == true then
            costText = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(row.cost) or string.format("%d €", math.floor(row.cost + 0.5))
            if row.costDifference > 0 then
                local amount = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(row.costDifference) or string.format("%d €", math.floor(row.costDifference + 0.5))
                adjustmentText = "+" .. amount
            elseif row.costDifference < 0 then
                local amount = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(math.abs(row.costDifference)) or string.format("%d €", math.floor(math.abs(row.costDifference) + 0.5))
                adjustmentText = "-" .. amount
            else
                adjustmentText = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(0) or "0 €"
            end
        else
            costText = self:getText("ui_pmTrainingNoPlaces", "aktuell keine Plätze frei")
        end

        self:drawTextLine(costX, moneyTextY, moneyTextSize, RenderText.ALIGN_RIGHT, costText, textColor, textColor, textColor, 1, true)
        self:drawTextLine(adjustmentX, moneyTextY, moneyTextSize, RenderText.ALIGN_RIGHT, adjustmentText, textColor, textColor, textColor, 1, true)

        if selectable then
            self:addClickArea(tableX, y, tableWidth, rowHeight, "trainingCategory:" .. tostring(row.key), nil)
        end
    end
end

function HelperPersonnelMenuPage:drawStandaloneHeader()
    local title = self:getText(self.pageTitleKey, self.pageTitleFallback)
    self:drawTextLine(0.22, 0.850, 0.030, RenderText.ALIGN_LEFT, title, 1, 1, 1, 1, true)

    if not self:canManageCurrentFarm() then
        self:drawTextLine(0.22, 0.817, 0.013, RenderText.ALIGN_LEFT, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen."), 1, 0.55, 0.2, 1, true)
    end
end

function HelperPersonnelMenuPage:drawPersonDetailPage()
    local person, isApplicant, entries = self:getCurrentPerson()
    local title = self:getText(self.pageTitleKey, self.pageTitleFallback)
    local count = entries ~= nil and #entries or 0
    local index = isApplicant and self.applicantIndex or self.workerIndex

    self:drawTextLine(0.22, 0.850, 0.030, RenderText.ALIGN_LEFT, title, 1, 1, 1, 1, true)
    self:drawSeparator(0.22, 0.815, 0.62)

    if not self:canManageCurrentFarm() then
        self:drawTextLine(0.22, 0.792, 0.013, RenderText.ALIGN_LEFT, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen."), 1, 0.55, 0.2, 1, true)
    end

    if person == nil then
        local emptyText = isApplicant and self:getText("ui_noApplicantsDetail", "Keine Bewerber vorhanden") or self:getText("ui_noWorkersDetail", "Keine Mitarbeiter vorhanden")
        self:drawTextLine(0.22, 0.735, 0.018, RenderText.ALIGN_LEFT, emptyText, 1, 1, 1, 1, true)
        return
    end

    self:drawPersonPager(index or 1, count)

    self:drawPersonPortrait(person, 0.22, 0.535, 0.150, 0.210, true)
    self:drawTextLine(0.405, 0.725, 0.024, RenderText.ALIGN_LEFT, self:getPersonName(person), 1, 1, 1, 1, true)
    self:drawPersonCoreBlock(person, isApplicant)

    self:drawSeparator(0.22, 0.500, 0.62)
    self:drawTextLine(0.22, 0.470, 0.015, RenderText.ALIGN_LEFT, self:getText("ui_pmProfileHeader", "PROFIL"), 1, 1, 1, 1, true)
    local lineY = 0.438
    local profileLines = self:getWrappedProfileLines(person, isApplicant)
    for i = 1, math.min(#profileLines, 7) do
        self:drawTextLine(0.22, lineY, 0.0122, RenderText.ALIGN_LEFT, profileLines[i], 0.92, 0.92, 0.92, 1, false)
        lineY = lineY - 0.023
    end

    if not isApplicant then
        self:drawTextLine(0.22, 0.278, 0.015, RenderText.ALIGN_LEFT, self:getText("ui_pmHistoryHeader", "VERLAUF"), 1, 1, 1, 1, true)
        self:drawWorkerHistoryTable(person)
    end
end


function HelperPersonnelMenuPage:getSettingsList()
    if HelperPersonnelGameSettings ~= nil and type(HelperPersonnelGameSettings.SETTINGS) == "table" then
        return HelperPersonnelGameSettings.SETTINGS
    end

    return {}
end

function HelperPersonnelMenuPage:getSettingText(setting, keyName, fallback)
    if setting == nil then
        return fallback or ""
    end

    local key = setting[keyName]
    if key ~= nil then
        return self:getText(key, fallback or key)
    end

    return fallback or ""
end

function HelperPersonnelMenuPage:isServerAuthority()
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.isServerAuthority ~= nil then
        return HelperPersonnelGameSettings.isServerAuthority() == true
    end

    return g_server ~= nil
end

function HelperPersonnelMenuPage:isSettingAvailable(setting)
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.isSettingAvailable ~= nil then
        return HelperPersonnelGameSettings.isSettingAvailable(setting) == true
    end

    return true
end

function HelperPersonnelMenuPage:getSettingsConfig()
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.getConfig ~= nil then
        return HelperPersonnelGameSettings.getConfig()
    end

    local manager = self:getManager()
    return manager ~= nil and manager.config or nil
end


function HelperPersonnelMenuPage:getSettingByKey(settingKey)
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.SETTINGS_BY_KEY ~= nil then
        return HelperPersonnelGameSettings.SETTINGS_BY_KEY[settingKey]
    end

    for _, setting in ipairs(self:getSettingsList()) do
        if setting.key == settingKey then
            return setting
        end
    end

    return nil
end

function HelperPersonnelMenuPage:getSelectedSetting()
    local selected = self:getSettingByKey(self.settingsSelectedKey)
    if selected ~= nil then
        return selected
    end

    local settings = self:getSettingsList()
    selected = settings[1]
    if selected ~= nil then
        self.settingsSelectedKey = selected.key
    end

    return selected
end

function HelperPersonnelMenuPage:drawSettingsDescription(setting)
    if setting == nil then
        return
    end

    local x = self.settingsDescriptionX or 0.600
    local y = self.settingsDescriptionY or 0.500
    local width = self.settingsDescriptionWidth or 0.270
    local desc = self:getSettingText(setting, "descriptionKey", "")
    local lines = self:getWrappedHistoryLines(desc, 0.0110, width, 66)
    local currentY = y

    for i = 1, math.min(#lines, 7) do
        self:drawTextLine(x, currentY, 0.0110, RenderText.ALIGN_LEFT, lines[i], 0.66, 0.66, 0.66, 1, false)
        currentY = currentY - 0.020
    end
end


function HelperPersonnelMenuPage:getPersonName(person)
    if person == nil then
        return ""
    end

    return tostring(person.firstName or "") .. " " .. tostring(person.lastName or "")
end

function HelperPersonnelMenuPage:getPersonSeed(person)
    local seed = tonumber(person ~= nil and person.id or 1) or 1
    local name = self:getPersonName(person)
    for i = 1, string.len(name) do
        seed = seed + string.byte(name, i) * i
    end
    return seed
end

function HelperPersonnelMenuPage:getBirthDateText(person)
    local manager = self:getManager()
    if manager ~= nil and manager.getBirthDateText ~= nil and manager.getPersonAge ~= nil then
        local birthDate = manager:getBirthDateText(person)
        local age = manager:getPersonAge(person)
        return self:formatText("ui_pmBirthDateAge", "%s (%d Jahre)", birthDate, age)
    end

    local seed = self:getPersonSeed(person)
    local day = (seed % 28) + 1
    local month = (math.floor(seed / 7) % 12) + 1
    local year = 1967 + (seed % 36)
    return string.format("%02d.%02d.%04d", day, month, year)
end

function HelperPersonnelMenuPage:getOriginText(person)
    local manager = self:getManager()
    if manager ~= nil and manager.getBackgroundDisplayName ~= nil then
        return manager:getBackgroundDisplayName(person)
    end

    local origins = {
        self:getText("ui_pmOrigin1", "ländlicher Familienbetrieb"),
        self:getText("ui_pmOrigin2", "kleiner Milchviehbetrieb"),
        self:getText("ui_pmOrigin3", "Lohnunternehmen"),
        self:getText("ui_pmOrigin4", "Ackerbaubetrieb"),
        self:getText("ui_pmOrigin5", "Gemischtbetrieb")
    }
    local seed = self:getPersonSeed(person)
    return origins[(seed % #origins) + 1]
end

function HelperPersonnelMenuPage:drawPersonStatBars(person, x, y, width)
    if person == nil then
        return
    end

    local stats = {
        { key = "ui_pmStatExperience", fallback = "Erfahrung", value = person.experience or 0 },
        { key = "ui_pmStatReliability", fallback = "Zuverlässigkeit", value = person.reliability or 0 },
        { key = "ui_pmStatLoyalty", fallback = "Loyalität", value = person.loyalty or 0 }
    }
    local gap = 0.012
    local statWidth = (width - (gap * 2)) / 3
    local labelY = y + 0.017
    local barHeight = 0.010

    for index, stat in ipairs(stats) do
        local statX = x + ((index - 1) * (statWidth + gap))
        local value = hpMenuClamp(stat.value, 0, 100)
        self:drawTextLine(statX, labelY, 0.0100, RenderText.ALIGN_LEFT, self:getText(stat.key, stat.fallback), 0.92, 0.92, 0.92, 1, true)
        self:drawTextLine(statX + statWidth, labelY, 0.0100, RenderText.ALIGN_RIGHT, string.format("%d %%", value), 0.61, 0.73, 0.07, 1, true)
        self:drawProgressBar(statX, y, statWidth, barHeight, value, 100, 0.61, 0.73, 0.07, 1)
    end
end

function HelperPersonnelMenuPage:drawPersonCoreBlock(person, isApplicant)
    local manager = self:getManager()
    local lines = self:getPersonCoreLines(person, isApplicant)
    local textX = 0.405

    self:drawDetailTextLine(textX, 0.690, 0.0125, lines[1] or "", 0.92, 0.92, 0.92, 1)
    self:drawDetailTextLine(textX, 0.663, 0.0125, lines[2] or "", 0.92, 0.92, 0.92, 1)

    self:drawPersonStatBars(person, textX, 0.620, 0.430)

    if not isApplicant and manager ~= nil and manager.getRankText ~= nil then
        self:drawTextLine(textX, 0.603, 0.0125, RenderText.ALIGN_LEFT, manager:getRankText(person), 0.61, 0.73, 0.07, 1, true)
    end

    self:drawDetailTextLine(textX, 0.576, 0.0125, lines[3] or "", 0.61, 0.73, 0.07, 1)
    self:drawDetailTextLine(textX, 0.549, 0.0125, lines[4] or "", 0.61, 0.73, 0.07, 1)
    self:drawDetailTextLine(textX, 0.522, 0.0125, lines[5] or "", 0.61, 0.73, 0.07, 1)
end

function HelperPersonnelMenuPage:getPersonCoreLines(person, isApplicant)
    local manager = self:getManager()
    local lines = {}
    local status = isApplicant and self:getText("ui_pmStatusApplicant", "Bewerber") or self:getText("ui_status_idle", "verfügbar")

    if not isApplicant and manager ~= nil and manager.getWorkerStatusText ~= nil then
        status = manager:getWorkerStatusText(person)
    elseif not isApplicant and manager ~= nil and manager.getStatusText ~= nil then
        status = manager:getStatusText(person)
    elseif not isApplicant and self:isWorkerActive(person) then
        status = self:getText("ui_status_busy", "im Einsatz")
    end

    local wageText = "-"
    if manager ~= nil and manager.getMonthlyWageTextFromBase ~= nil then
        wageText = manager:getMonthlyWageTextFromBase(person.baseWage or person.wage or 0)
    elseif manager ~= nil and manager.formatMoney ~= nil then
        wageText = manager:formatMoney(person.wage or person.baseWage or 0)
    else
        wageText = string.format("%d €", math.floor((tonumber(person.wage) or tonumber(person.baseWage) or 0) + 0.5))
    end

    local specText = self:getText("ui_specialization_short", "Spezialisierung") .. ": -"
    if manager ~= nil and manager.getPersonSpecializationText ~= nil then
        specText = manager:getPersonSpecializationText(person) or specText
    elseif person.specializationPrimary ~= nil and person.specializationPrimary ~= "" then
        specText = self:getText("ui_specialization_short", "Spezialisierung") .. ": " .. tostring(person.specializationPrimary)
    end

    table.insert(lines, self:formatText("ui_pmBirthLine", "Geboren: %s", self:getBirthDateText(person)))
    table.insert(lines, self:formatText("ui_pmOriginLine", "Herkunft: %s", self:getOriginText(person)))
    table.insert(lines, self:formatText("ui_pmWageLine", "Gehalt: %s", wageText))
    table.insert(lines, self:formatText("ui_pmStatusLine", "Status: %s", status))
    table.insert(lines, specText)

    return lines
end


function HelperPersonnelMenuPage:getProfileTemplate(person, isApplicant)
    local manager = self:getManager()
    local spec = person.specializationPrimary or person.specializationProgressKey or ""
    local origin = self:getOriginText(person)
    local name = self:getPersonName(person)
    local strength = self:getText("ui_pmStrengthReliable", "ruhige und zuverlässige Arbeitsweise")

    if spec == HelperPersonnelManager.SPECIALIZATION_TRANSPORT or spec == "transport" then
        strength = self:getText("ui_pmStrengthTransport", "strukturierte Transport- und Hoflogistik")
    elseif spec == HelperPersonnelManager.SPECIALIZATION_HARVEST or spec == "harvest" then
        strength = self:getText("ui_pmStrengthHarvest", "sorgfältige Erntearbeiten")
    elseif spec == HelperPersonnelManager.SPECIALIZATION_SOWING or spec == "sowing" then
        strength = self:getText("ui_pmStrengthSowing", "präzise Aussaat und Feldvorbereitung")
    end

    if isApplicant then
        if manager ~= nil and manager.getDynamicApplicantProfileText ~= nil then
            local ok, dynamicText = pcall(manager.getDynamicApplicantProfileText, manager, person)
            if ok and dynamicText ~= nil and dynamicText ~= "" then
                return dynamicText
            end
            if not ok and Logging ~= nil and Logging.warning ~= nil then
                Logging.warning("FS25_PersonnelManagement: Could not generate applicant profile: %s", tostring(dynamicText))
            end
        end
        return self:formatText("ui_pmApplicantProfileText", "%s bewirbt sich mit Erfahrung aus einem %s. Die bisherigen Angaben sprechen für %s. Die Werte sind eine Momentaufnahme des Bewerberprofils.", name, origin, strength)
    end

    if manager ~= nil and manager.getDynamicWorkerProfileText ~= nil then
        local ok, dynamicText = pcall(manager.getDynamicWorkerProfileText, manager, person)
        if ok and dynamicText ~= nil and dynamicText ~= "" then
            return dynamicText
        end
        if not ok and Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("FS25_PersonnelManagement: Could not generate profile text: %s", tostring(dynamicText))
        end
    end


    local hiredLine = manager ~= nil and self:getBaseWorkerHiredLine(manager, person) or self:getText("ui_worker_hired_unknown", "eingestellt vor Aufzeichnung")
    return self:formatText("ui_pmWorkerProfileText", "%s ist %s im Betrieb. Die bisherige Entwicklung spricht für %s.", name, hiredLine, strength)
end

function HelperPersonnelMenuPage:getWrappedProfileLines(person, isApplicant)
    local text = self:getProfileTemplate(person, isApplicant)
    return self:getWrappedHistoryLines(text, 0.0122, 0.62, 132)
end

function HelperPersonnelMenuPage:formatChronicleDate(entry)
    if type(entry) ~= "table" then
        return self:getText("ui_pmHistoryNoRecord", "keine Aufzeichnung")
    end

    return self:formatText("ui_pmHistoryDateFormat", "Tag %d · %d/%d", entry.day or 1, entry.calendarMonth or 1, entry.calendarYear or 1)
end

function HelperPersonnelMenuPage:drawWorkerHistoryTable(person)
    local manager = self:getManager()
    local overview = manager ~= nil and manager.getWorkerHistoryOverview ~= nil and manager:getWorkerHistoryOverview(person) or nil
    overview = type(overview) == "table" and overview or {}

    local trainingText
    if person.trainingActivePeriod ~= nil and (person.trainingActivePeriod or 0) > 0 then
        trainingText = manager ~= nil and manager.getSpecializationDisplayName ~= nil and manager:getSpecializationDisplayName(person.trainingActiveSpecialization) or tostring(person.trainingActiveSpecialization or "")
    elseif person.trainingLastYear ~= nil and (person.trainingLastYear or 0) > 0 then
        trainingText = self:formatText("ui_pmHistoryTrainingYearCompact", "Jahr %d", person.trainingLastYear or 0)
    else
        trainingText = self:getText("ui_pmHistoryTrainingNoneCompact", "keine")
    end

    local firstColumn = {
        self:formatText("ui_pmHistoryCareerJobs", "Einsätze: %d", person.jobsCompleted or 0),
        self:formatText("ui_pmHistoryCareerWorkTime", "Arbeitszeit: %s", manager ~= nil and manager.formatWorkMinutes ~= nil and manager:formatWorkMinutes(person.totalWorkMinutes or 0) or tostring(person.totalWorkMinutes or 0)),
        self:formatText("ui_pmHistoryCareerTraining", "Schulung: %s", trainingText),
        self:formatText("ui_pmHistoryCareerTransport", "Transport: %s", person.transportDriver == true and self:getText("ui_pmHistoryValueActive", "aktiv") or self:getText("ui_pmHistoryValueInactive", "nicht aktiv"))
    }

    local noRecord = self:getText("ui_pmHistoryNoRecord", "keine Aufzeichnung")
    local sicknessDate = overview.latestSickness ~= nil and self:formatChronicleDate(overview.latestSickness) or noRecord
    local salaryDate = overview.latestSalaryRequest ~= nil and self:formatChronicleDate(overview.latestSalaryRequest) or noRecord
    local salaryStatusKey = "ui_pmHistorySalaryUnresolved"
    local salaryStatusFallback = "ohne erfasste Entscheidung"
    if overview.salaryRequestStatus == "accepted" then
        salaryStatusKey = "ui_pmHistorySalaryAccepted"
        salaryStatusFallback = "angenommen"
    elseif overview.salaryRequestStatus == "declined" then
        salaryStatusKey = "ui_pmHistorySalaryDeclined"
        salaryStatusFallback = "abgelehnt"
    elseif overview.salaryRequestStatus == "pending" then
        salaryStatusKey = "ui_pmHistorySalaryPending"
        salaryStatusFallback = "offen"
    end
    local salaryStatus = overview.latestSalaryRequest ~= nil and self:getText(salaryStatusKey, salaryStatusFallback) or noRecord

    local abortDate = overview.latestJobAbort ~= nil and self:formatChronicleDate(overview.latestJobAbort) or noRecord
    local abortReason = noRecord
    if overview.latestJobAbort ~= nil then
        if overview.latestJobAbort.reason == "sickness" then
            abortReason = self:getText("ui_pmHistoryAbortSickness", "Krankheit")
        elseif overview.latestJobAbort.reason == "unreliability" then
            abortReason = self:getText("ui_pmHistoryAbortUnreliability", "Unzuverlässigkeit")
        else
            abortReason = self:getText("ui_pmHistoryAbortOther", "sonstiger Grund")
        end
    end

    local secondColumn = {
        self:formatText("ui_pmHistoryLastSickness", "Zuletzt krank: %s", sicknessDate),
        self:formatText("ui_pmHistoryLastSalaryRequest", "Letzte Gehaltsforderung: %s · %s", salaryDate, salaryStatus),
        self:formatText("ui_pmHistoryLastAbort", "Letzter Einsatzabbruch: %s · %s", abortDate, abortReason)
    }

    local totalSalaryText = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(person.totalEarnings or 0) or string.format("%d €", math.floor((tonumber(person.totalEarnings) or 0) + 0.5))
    local thirdColumn = {
        self:formatText("ui_pmHistoryTotalSickness", "Krankheitstage: %d", overview.sicknessDays or 0),
        self:formatText("ui_pmHistoryTotalSalaryRequests", "Gehaltsforderungen: %d", overview.salaryRequests or 0),
        self:formatText("ui_pmHistoryTotalAborts", "Einsatzabbrüche: %d", overview.abortedJobs or 0),
        self:formatText("ui_pmHistoryTotalSalaryPaid", "Gesamtgehalt: %s", totalSalaryText)
    }

    local columns = {
        { x = 0.22, width = 0.195, title = self:getText("ui_pmHistoryColumnCareer", "Bisheriger Verlauf"), lines = firstColumn },
        { x = 0.425, width = 0.290, title = self:getText("ui_pmHistoryColumnRecent", "Letzte Ereignisse"), lines = secondColumn },
        { x = 0.725, width = 0.115, title = self:getText("ui_pmHistoryColumnTotals", "Summen"), lines = thirdColumn }
    }
    local scrimY = 0.126
    local scrimHeight = 0.137

    for index, column in ipairs(columns) do
        local shade = 0.024
        self:drawSolidRect(column.x, scrimY, column.width, scrimHeight, shade, shade + 0.012, shade, 0.72)
        self:drawSolidRect(column.x, scrimY + scrimHeight - 0.003, column.width, 0.003, 0.61, 0.73, 0.07, 0.78)

        local textX = column.x + 0.010
        self:drawTextLine(textX, 0.239, 0.0112, RenderText.ALIGN_LEFT, column.title, 1, 1, 1, 1, true)
        local rowY = 0.210
        for lineIndex, line in ipairs(column.lines) do
            if lineIndex <= 4 then
                local textSize = index == 2 and 0.0092 or (index == 3 and 0.0085 or 0.0097)
                self:drawTextLine(textX, rowY, textSize, RenderText.ALIGN_LEFT, line, 0.61, 0.73, 0.07, 1, false)
                rowY = rowY - 0.025
            end
        end
    end
end
