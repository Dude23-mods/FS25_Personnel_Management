HelperPersonnelSelectionOverlay = {}
HelperPersonnelSelectionOverlay_mt = Class(HelperPersonnelSelectionOverlay)

HelperPersonnelSelectionOverlay.KEYS_LEFT = { "KEY_left", "KEY_a" }
HelperPersonnelSelectionOverlay.KEYS_RIGHT = { "KEY_right", "KEY_d" }
HelperPersonnelSelectionOverlay.KEYS_CONFIRM = { "KEY_return", "KEY_enter", "KEY_space" }
HelperPersonnelSelectionOverlay.KEYS_CANCEL = { "KEY_esc", "KEY_escape" }

function HelperPersonnelSelectionOverlay.new(app, customMt)
    local self = setmetatable({}, customMt or HelperPersonnelSelectionOverlay_mt)

    self.app = app
    self.isVisible = false
    self.availableWorkers = {}
    self.selectedIndex = 1
    self.callback = nil
    self.vehicle = nil
    self.actionEventIds = {}
    self.actionsRegistered = false
    self.lastFallbackCommand = nil
    self.playerFrozenBackup = nil
    self.inputBlockActive = false
    self.keyConstantCache = {}

    local pixelFile = Utils.getFilename("gui/solidPixel.dds", app.modDir)
    self.backgroundOverlay = Overlay.new(pixelFile, 0.25, 0.375, 0.50, 0.29)
    self.backgroundOverlay:setColor(0, 0, 0, 0.82)

    self.highlightOverlay = Overlay.new(pixelFile, 0.29, 0.43, 0.42, 0.115)
    self.highlightOverlay:setColor(0.18, 0.45, 0.9, 0.45)

    return self
end

function HelperPersonnelSelectionOverlay:delete()
    self:unregisterActionEvents()
    self:restoreGameplayInput()

    if self.backgroundOverlay ~= nil then
        self.backgroundOverlay:delete()
        self.backgroundOverlay = nil
    end

    if self.highlightOverlay ~= nil then
        self.highlightOverlay:delete()
        self.highlightOverlay = nil
    end
end

function HelperPersonnelSelectionOverlay:open(vehicle, callback)
    local availableWorkers = self.app.manager:getAvailableWorkers()
    if #availableWorkers == 0 then
        local warningText = g_i18n:getText("ui_selectionNoWorkers")
        if #self.app.manager.workers == 0 then
            warningText = g_i18n:getText("ui_selectionNoEmployees")
        end

        if g_currentMission ~= nil then
            g_currentMission:showBlinkingWarning(warningText, 2200)
        end
        return false
    end

    self.vehicle = vehicle
    self.callback = callback
    self.availableWorkers = availableWorkers
    self.selectedIndex = 1
    self.isVisible = true
    self.lastFallbackCommand = nil

    self:suspendGameplayInput()

    self.actionsRegistered = false
    return true
end

function HelperPersonnelSelectionOverlay:close(confirmSelection)
    local callback = self.callback
    local selectedWorker = nil

    if confirmSelection and self.availableWorkers[self.selectedIndex] ~= nil then
        selectedWorker = self.availableWorkers[self.selectedIndex]

        if self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.isWorkerSelectable ~= nil and not self.app.helperBridge:isWorkerSelectable(selectedWorker.id) then
            if self.app.showPlayerMessage ~= nil then
                self.app:showPlayerMessage("ui_selectionWorkerUnavailable")
            end
            selectedWorker = nil
        end
    end

    self.vehicle = nil
    self.callback = nil
    self.availableWorkers = {}
    self.selectedIndex = 1
    self.isVisible = false

    self:unregisterActionEvents()
    self:restoreGameplayInput()

    if callback ~= nil then
        callback(selectedWorker)
    end
end

function HelperPersonnelSelectionOverlay:getActionId(actionName)
    if InputAction ~= nil and InputAction[actionName] ~= nil then
        return InputAction[actionName]
    end

    return actionName
end

function HelperPersonnelSelectionOverlay:getInputEventLookupKey(eventId)
    if type(eventId) == "table" then
        if eventId.id ~= nil then
            return tostring(eventId.id)
        end
        if eventId.eventId ~= nil then
            return tostring(eventId.eventId)
        end
    end

    return tostring(eventId)
end

function HelperPersonnelSelectionOverlay:getInputEventActive(eventId)
    if type(eventId) == "table" then
        if eventId.isActive ~= nil then
            return eventId.isActive
        end
        if eventId.active ~= nil then
            return eventId.active
        end
    end

    if g_inputBinding ~= nil then
        local eventTable = nil
        if g_inputBinding.actionEvents ~= nil then
            eventTable = g_inputBinding.actionEvents[eventId]
        end
        if eventTable == nil and g_inputBinding.events ~= nil then
            eventTable = g_inputBinding.events[eventId]
        end

        if type(eventTable) == "table" then
            if eventTable.isActive ~= nil then
                return eventTable.isActive
            end
            if eventTable.active ~= nil then
                return eventTable.active
            end
        end
    end

    return true
end

function HelperPersonnelSelectionOverlay:setInputEventActive(eventId, isActive)
    if g_inputBinding == nil or eventId == nil then
        return false
    end

    if g_inputBinding.setEventActive ~= nil then
        local success = pcall(function()
            g_inputBinding:setEventActive(eventId, isActive)
        end)

        if success then
            return true
        end
    end

    if g_inputBinding.setActionEventActive ~= nil then
        local success = pcall(function()
            g_inputBinding:setActionEventActive(eventId, isActive)
        end)

        if success then
            return true
        end
    end

    return false
end

function HelperPersonnelSelectionOverlay:suspendInputEvent(eventId)
    if eventId == nil then
        return
    end

    local lookupKey = self:getInputEventLookupKey(eventId)
    if self.suspendedInputEventLookup[lookupKey] then
        return
    end

    local wasActive = self:getInputEventActive(eventId)
    if self:setInputEventActive(eventId, false) then
        self.suspendedInputEventLookup[lookupKey] = true
        table.insert(self.suspendedInputEvents, {
            eventId = eventId,
            wasActive = wasActive
        })
    end
end

function HelperPersonnelSelectionOverlay:suspendGameplayAction(actionName)
    if g_inputBinding == nil or g_inputBinding.contexts == nil then
        return
    end

    local actionId = self:getActionId(actionName)
    if actionId == nil then
        return
    end

    for _, context in pairs(g_inputBinding.contexts) do
        if context ~= nil and context.actionEvents ~= nil then
            local actionEvents = context.actionEvents[actionId]
            if actionEvents ~= nil then
                for _, eventId in ipairs(actionEvents) do
                    self:suspendInputEvent(eventId)
                end
            end
        end
    end
end

function HelperPersonnelSelectionOverlay:suspendGameplayInput()
    self:restoreGameplayInput()

    if g_currentMission ~= nil then
        self.playerFrozenBackup = g_currentMission.isPlayerFrozen
        g_currentMission.isPlayerFrozen = true
        self.inputBlockActive = true
    end
end

function HelperPersonnelSelectionOverlay:restoreGameplayInput()
    if self.suspendedInputEvents ~= nil and #self.suspendedInputEvents > 0 then
        for index = #self.suspendedInputEvents, 1, -1 do
            local entry = self.suspendedInputEvents[index]
            self:setInputEventActive(entry.eventId, entry.wasActive ~= false)
        end
    end

    self.suspendedInputEvents = {}
    self.suspendedInputEventLookup = {}

    if self.inputBlockActive and g_currentMission ~= nil then
        if self.playerFrozenBackup ~= nil then
            g_currentMission.isPlayerFrozen = self.playerFrozenBackup
        else
            g_currentMission.isPlayerFrozen = false
        end
    end

    self.playerFrozenBackup = nil
    self.inputBlockActive = false
end

function HelperPersonnelSelectionOverlay:registerActionEvents()
    if self.actionsRegistered or g_inputBinding == nil then
        return
    end

    self.actionEventIds = {}

    local contextName = g_inputBinding.currentContextName
    local modificationStarted = false
    if contextName ~= nil and g_inputBinding.beginActionEventsModification ~= nil then
        g_inputBinding:beginActionEventsModification(contextName)
        modificationStarted = true
    end

    local function register(actionName, callback, text)
        local actionId = self:getActionId(actionName)
        local success, actionEventId = g_inputBinding:registerActionEvent(actionId, self, callback, false, true, false, true, nil, true)

        if success and actionEventId ~= nil then
            table.insert(self.actionEventIds, actionEventId)

            if g_inputBinding.setActionEventText ~= nil then
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

            return true
        end

        Logging.warning("[HelperPersonnel] Could not register selection input action '%s'", tostring(actionName))
        return false
    end

    local anyRegistered = false
    anyRegistered = register("HP_SELECT_LEFT", self.onActionLeft, g_i18n:getText("input_HP_SELECT_LEFT")) or anyRegistered
    anyRegistered = register("HP_SELECT_RIGHT", self.onActionRight, g_i18n:getText("input_HP_SELECT_RIGHT")) or anyRegistered
    anyRegistered = register("HP_SELECT_CONFIRM", self.onActionConfirm, g_i18n:getText("input_HP_SELECT_CONFIRM")) or anyRegistered
    anyRegistered = register("HP_SELECT_CANCEL", self.onActionCancel, g_i18n:getText("input_HP_SELECT_CANCEL")) or anyRegistered

    if modificationStarted and g_inputBinding.endActionEventsModification ~= nil then
        g_inputBinding:endActionEventsModification()
    end

    self.actionsRegistered = anyRegistered
end

function HelperPersonnelSelectionOverlay:unregisterActionEvents()
    if self.actionsRegistered and g_inputBinding ~= nil then
        g_inputBinding:removeActionEventsByTarget(self)
    end

    self.actionEventIds = {}
    self.actionsRegistered = false
    self.lastFallbackCommand = nil
end

function HelperPersonnelSelectionOverlay:isActionPressed(inputValue)
    return inputValue == nil or inputValue > 0
end

function HelperPersonnelSelectionOverlay:onActionLeft(actionName, inputValue)
    if not self.isVisible or not self:isActionPressed(inputValue) or #self.availableWorkers <= 1 then
        return
    end

    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex < 1 then
        self.selectedIndex = #self.availableWorkers
    end
end

function HelperPersonnelSelectionOverlay:onActionRight(actionName, inputValue)
    if not self.isVisible or not self:isActionPressed(inputValue) or #self.availableWorkers <= 1 then
        return
    end

    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.availableWorkers then
        self.selectedIndex = 1
    end
end

function HelperPersonnelSelectionOverlay:onActionConfirm(actionName, inputValue)
    if self.isVisible and self:isActionPressed(inputValue) then
        self:close(true)
    end
end

function HelperPersonnelSelectionOverlay:onActionCancel(actionName, inputValue)
    if self.isVisible and self:isActionPressed(inputValue) then
        self:close(false)
    end
end

function HelperPersonnelSelectionOverlay:resetClickAreas()
    self.clickAreas = {}
end

function HelperPersonnelSelectionOverlay:addClickArea(x, y, width, height, workerIndex)
    if self.clickAreas == nil then
        self.clickAreas = {}
    end

    table.insert(self.clickAreas, {
        x = x,
        y = y,
        width = width,
        height = height,
        workerIndex = workerIndex
    })
end

function HelperPersonnelSelectionOverlay:isPointInArea(posX, posY, area)
    return posX >= area.x and posX <= area.x + area.width and posY >= area.y and posY <= area.y + area.height
end

function HelperPersonnelSelectionOverlay:mouseEvent(posX, posY, isDown, isUp, button, eventUsed)
    if not self.isVisible then
        return eventUsed == true
    end

    if not isDown and not isUp then
        return true
    end

    for i = #(self.clickAreas or {}), 1, -1 do
        local area = self.clickAreas[i]
        if area ~= nil and self:isPointInArea(posX, posY, area) then
            if area.workerIndex ~= nil and self.availableWorkers[area.workerIndex] ~= nil then
                self.selectedIndex = area.workerIndex
            end

            return true
        end
    end

    return true
end

function HelperPersonnelSelectionOverlay:getKeyConstant(keyName)
    if self.keyConstantCache ~= nil and self.keyConstantCache[keyName] ~= nil then
        return self.keyConstantCache[keyName]
    end

    local keyConstant = nil
    if _G ~= nil and _G[keyName] ~= nil then
        keyConstant = _G[keyName]
    elseif Input ~= nil and Input[keyName] ~= nil then
        keyConstant = Input[keyName]
    end

    if keyConstant ~= nil and self.keyConstantCache ~= nil then
        self.keyConstantCache[keyName] = keyConstant
    end

    return keyConstant
end

function HelperPersonnelSelectionOverlay:isAnyKeyPressed(keyNames)
    if Input == nil or Input.isKeyPressed == nil then
        return false
    end

    for _, keyName in ipairs(keyNames) do
        local key = self:getKeyConstant(keyName)
        if key ~= nil and Input.isKeyPressed(key) then
            return true
        end
    end

    return false
end

function HelperPersonnelSelectionOverlay:update(dt)

    if not self.isVisible then
        self.lastFallbackCommand = nil
        return
    end

    local command = nil
    if self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_LEFT) then
        command = "left"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_RIGHT) then
        command = "right"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_CONFIRM) then
        command = "confirm"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_CANCEL) then
        command = "cancel"
    end

    if command == nil then
        self.lastFallbackCommand = nil
        return
    end

    if command == self.lastFallbackCommand then
        return
    end

    self.lastFallbackCommand = command

    if command == "left" then
        self:onActionLeft(nil, 1)
    elseif command == "right" then
        self:onActionRight(nil, 1)
    elseif command == "confirm" then
        self:onActionConfirm(nil, 1)
    elseif command == "cancel" then
        self:onActionCancel(nil, 1)
    end
end

function HelperPersonnelSelectionOverlay:keyEvent(unicode, sym, modifier, isDown)
    if not isDown or not self.isVisible then
        return false
    end

    if sym == self:getKeyConstant("KEY_left") or sym == self:getKeyConstant("KEY_a") then
        self:onActionLeft(nil, 1)
        return true
    elseif sym == self:getKeyConstant("KEY_right") or sym == self:getKeyConstant("KEY_d") then
        self:onActionRight(nil, 1)
        return true
    elseif sym == self:getKeyConstant("KEY_return") or sym == self:getKeyConstant("KEY_enter") or sym == self:getKeyConstant("KEY_space") then
        self:onActionConfirm(nil, 1)
        return true
    elseif sym == self:getKeyConstant("KEY_esc") or sym == self:getKeyConstant("KEY_escape") then
        self:onActionCancel(nil, 1)
        return true
    end

    return false
end

function HelperPersonnelSelectionOverlay:draw()
    if not self.isVisible then
        return
    end

    self:resetClickAreas()

    if self.backgroundOverlay ~= nil then
        self.backgroundOverlay:render()
    end

    local centerX = 0.5
    local titleY = 0.64
    local infoY = 0.61
    local indexY = 0.58
    local cardY = 0.43
    local cardHeight = 0.115
    local cardWidth = 0.40
    local count = #self.availableWorkers
    local worker = self.availableWorkers[self.selectedIndex]

    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextColor(1, 1, 1, 1)
    setTextBold(true)
    renderText(centerX, titleY, 0.022, g_i18n:getText("ui_selectionTitle"))
    setTextBold(false)

    setTextColor(0.82, 0.82, 0.82, 1)
    renderText(centerX, infoY, 0.013, g_i18n:getText("ui_selectionHint"))

    if count > 0 then
        setTextColor(0.78, 0.78, 0.78, 1)
        renderText(centerX, indexY, 0.013, string.format("%d / %d", self.selectedIndex, count))
    end

    if worker ~= nil then
        local cardX = centerX - cardWidth * 0.5
        self:addClickArea(cardX, cardY, cardWidth, cardHeight, self.selectedIndex)

        if self.highlightOverlay ~= nil then
            self.highlightOverlay:setPosition(cardX, cardY)
            self.highlightOverlay:setDimension(cardWidth, cardHeight)
            self.highlightOverlay:render()
        end

        setTextColor(1, 1, 1, 1)
        setTextBold(true)
        renderText(centerX, cardY + 0.083, 0.02, self.app.manager:getFullName(worker))
        setTextBold(false)

        local rankText = self.app.manager:getRankText(worker)
        local experience = tonumber(worker.experience) or 0
        local reliability = tonumber(worker.reliability) or 0
        local loyalty = tonumber(worker.loyalty) or 65
        local wage = worker.wage or 0
        if self.app ~= nil and self.app.manager ~= nil and self.app.manager.getCurrentMonthlyWage ~= nil then
            wage = self.app.manager:getCurrentMonthlyWage(worker)
        end
        local wageText = g_i18n:formatMoney(wage, 0, true, false)
        local jobsCompleted = tonumber(worker.jobsCompleted) or 0
        local workSpeedPercent = 100
        if self.app ~= nil and self.app.manager ~= nil and self.app.manager.getWorkerWorkSpeedPercent ~= nil then
            workSpeedPercent = self.app.manager:getWorkerWorkSpeedPercent(worker)
        end

        local detailLine1 = string.format(g_i18n:getText("ui_selectionLineStats"), rankText, experience, reliability, loyalty)
        local detailLine2 = string.format(g_i18n:getText("ui_selectionLineWage"), wageText)
        local detailLine3 = string.format(g_i18n:getText("ui_selectionLineJobs"), jobsCompleted, workSpeedPercent)

        setTextColor(0.88, 0.88, 0.88, 1)
        renderText(centerX, cardY + 0.056, 0.0125, detailLine1)
        setTextColor(0.84, 0.84, 0.84, 1)
        renderText(centerX, cardY + 0.035, 0.0125, detailLine2)
        setTextColor(0.80, 0.80, 0.80, 1)
        renderText(centerX, cardY + 0.014, 0.0125, detailLine3)
    end

    setTextAlignment(RenderText.ALIGN_LEFT)
end
