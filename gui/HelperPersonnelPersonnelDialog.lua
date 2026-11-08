-- Native modal view for salary requests and the transport priority draft.
HelperPersonnelPersonnelDialog = {}
local HelperPersonnelPersonnelDialog_mt = Class(HelperPersonnelPersonnelDialog, DialogElement)

function HelperPersonnelPersonnelDialog.new(target)
    return DialogElement.new(target, HelperPersonnelPersonnelDialog_mt)
end

function HelperPersonnelPersonnelDialog:setContext(page, mode)
    self.page = page
    self.mode = mode
end

function HelperPersonnelPersonnelDialog:onOpen()
    HelperPersonnelPersonnelDialog:superClass().onOpen(self)
    local page = self.page
    if page == nil then return end
    local salary = self.mode == "salary"
    self.dialogTitle:setText(salary and page:getText("ui_salaryRequestsTitle", "Gehaltsforderungen verwalten") or page:getText("ui_transportPriorityTitle", "Transportaufgaben verwalten"))
    self.dialogIntro:setText(salary and page:getText("ui_salaryRequestsIntro", "Hier werden alle offenen Gehaltsforderungen angezeigt.") or page:getText("ui_transportPriorityIntro", "Aktiviere Mitarbeiter für Transportaufgaben und lege ihre Reihenfolge fest."))
    self.emptyText:setText(salary and page:getText("ui_salaryRequestsNoRequests", "Keine offenen Gehaltsforderungen.") or page:getText("ui_transportPriorityNoWorkers", "Keine Mitarbeiter vorhanden."))
    self.acceptButton:setVisible(salary)
    self.declineButton:setVisible(salary)
    self.upButton:setVisible(not salary)
    self.downButton:setVisible(not salary)
    self.toggleButton:setVisible(not salary)
    self.applyButton:setVisible(not salary)
    self.list:setDataSource(self)
    self:refreshList()
    if not salary then
        self.transportInputEvents = {}
        for _, action in ipairs({{InputAction.HP_TRANSPORT_PRIORITY_UP, self.onMoveUp}, {InputAction.HP_TRANSPORT_PRIORITY_DOWN, self.onMoveDown}}) do
            if action[1] ~= nil then
                local _, eventId = g_inputBinding:registerActionEvent(action[1], self, action[2], false, true, false, true)
                if eventId ~= nil then
                    g_inputBinding:setActionEventTextVisibility(eventId, false)
                    table.insert(self.transportInputEvents, eventId)
                end
            end
        end
    end
end

function HelperPersonnelPersonnelDialog:getRows()
    if self.page == nil then return {} end
    return self.mode == "salary" and self.page.salaryRaiseRows or self.page.transportPriorityRows
end

function HelperPersonnelPersonnelDialog:getNumberOfItemsInSection(list, section)
    return #(self:getRows() or {})
end

function HelperPersonnelPersonnelDialog:populateCellForItemInSection(list, section, index, cell)
    local page = self.page
    local row = (self:getRows() or {})[index]
    if page == nil or row == nil then return end
    local worker = self.mode == "salary" and page:getSalaryRaiseWorker(row) or page:getTransportPriorityWorker(row)
    local name = worker ~= nil and page:getPersonName(worker) or tostring(row.workerId or "")
    local detail
    if self.mode == "salary" then
        detail = worker ~= nil and (page:getSalaryRaiseWageText(worker, false) .. "  →  " .. page:getSalaryRaiseWageText(worker, true)) or ""
    else
        local manager = page:getManager()
        local status = worker ~= nil and manager ~= nil and manager.getStatusText ~= nil and manager:getStatusText(worker) or ""
        local enabled = row.enabled and page:getText("ui_transportPriorityActive", "Aktiv") or page:getText("ui_transportPriorityInactive", "Inaktiv")
        detail = (row.enabled and tostring(index) or "–") .. "  |  " .. status .. "  |  " .. enabled
    end
    cell.attributes.personName:setText(name)
    cell.attributes.personDetail:setText(detail)
    cell.target = self
end

function HelperPersonnelPersonnelDialog:refreshList()
    local rows = self:getRows() or {}
    self.emptyText:setVisible(#rows == 0)
    self.list:reloadData()
    if #rows > 0 then
        local index = self.mode == "salary" and self.page.salaryRaiseSelectedIndex or self.page.transportPrioritySelectedIndex
        self.list:setSelectedIndex(math.max(1, math.min(index or 1, #rows)), true, 0)
    end
end

function HelperPersonnelPersonnelDialog:syncSelection()
    local index = self.list:getSelectedIndexInSection()
    if index == nil or index < 1 then return false end
    if self.mode == "salary" then self.page.salaryRaiseSelectedIndex = index
    else self.page.transportPrioritySelectedIndex = index end
    return true
end

function HelperPersonnelPersonnelDialog:onAccept()
    if self:syncSelection() then self.page:decideSalaryRaiseRequest(true); self:refreshList() end
end

function HelperPersonnelPersonnelDialog:onDecline()
    if self:syncSelection() then self.page:decideSalaryRaiseRequest(false); self:refreshList() end
end

function HelperPersonnelPersonnelDialog:onMoveUp()
    if self:syncSelection() then self.page:moveTransportPriorityRow(-1); self:refreshList() end
end

function HelperPersonnelPersonnelDialog:onMoveDown()
    if self:syncSelection() then self.page:moveTransportPriorityRow(1); self:refreshList() end
end

function HelperPersonnelPersonnelDialog:onToggle()
    if self:syncSelection() then self.page:toggleTransportPriorityRow(); self:refreshList() end
end

function HelperPersonnelPersonnelDialog:onApply()
    if self.page:applyTransportPriorityDialog() then self:onClickBack() end
end

function HelperPersonnelPersonnelDialog:onClose()
    for _, eventId in ipairs(self.transportInputEvents or {}) do
        g_inputBinding:removeActionEvent(eventId)
    end
    self.transportInputEvents = nil
    local page = self.page
    self.page = nil
    self.mode = nil
    if page ~= nil then
        page.salaryRaiseRows = {}
        page.transportPriorityRows = {}
        page:refresh()
    end
    HelperPersonnelPersonnelDialog:superClass().onClose(self)
end
