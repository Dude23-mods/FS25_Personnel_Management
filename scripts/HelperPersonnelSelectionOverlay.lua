HelperPersonnelSelectionOverlay = {}
HelperPersonnelSelectionOverlay_mt = Class(HelperPersonnelSelectionOverlay)
HelperPersonnelSelectionOverlay.DEBUG_LOGGING = false

local function hpSelectionDebug(message, ...)
    if HelperPersonnelSelectionOverlay.DEBUG_LOGGING == true and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

local function hpSelectionVehicleName(vehicle)
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getDebugVehicleName ~= nil then
        return HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle)
    end

    if vehicle == nil then
        return "nil"
    end

    if vehicle.getName ~= nil then
        local ok, name = pcall(vehicle.getName, vehicle)
        if ok and name ~= nil and name ~= "" then
            return tostring(name)
        end
    end

    return tostring(vehicle)
end

local function hpSelectionCountExcluded(excludedWorkerIds)
    if type(excludedWorkerIds) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(excludedWorkerIds) do
        count = count + 1
    end
    return count
end

HelperPersonnelSelectionOverlay.KEYS_LEFT = { "KEY_left", "KEY_a" }
HelperPersonnelSelectionOverlay.KEYS_RIGHT = { "KEY_right", "KEY_d" }
HelperPersonnelSelectionOverlay.KEYS_CONFIRM = { "KEY_space" }
HelperPersonnelSelectionOverlay.KEYS_CANCEL = { "KEY_esc", "KEY_escape" }
HelperPersonnelSelectionOverlay.KEYS_TOGGLE_ALL = { "KEY_tab" }

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
    self.consumeCancelUntilReleased = false
    self.nativeMenuSuppressionUntil = 0
    self.lastWorkerClickIndex = nil
    self.lastWorkerClickTime = 0
    self.lastFallbackCommand = nil
    self.playerFrozenBackup = nil
    self.playerFrozenBackupWasSet = false
    self.inputBlockActive = false
    self.cursorReleaseFrames = 0
    self.cursorReleaseUntil = 0
    self.cameraStateBackups = {}
    self.keyConstantCache = {}
    self.showAllWorkers = false
    self.excludedWorkerIds = {}
    self.expectedSpecializationKey = nil
    self.portraitOverlays = {}

    local pixelFile = Utils.getFilename("gui/solidPixel.dds", app.modDir)
    self.backgroundOverlay = Overlay.new(pixelFile, 0.25, 0.375, 0.50, 0.29)
    self.backgroundOverlay:setColor(0.045, 0.055, 0.04, 0.94)

    self.highlightOverlay = Overlay.new(pixelFile, 0.29, 0.43, 0.42, 0.115)
    self.highlightOverlay:setColor(0.11, 0.13, 0.075, 0.96)

    self.accentOverlay = Overlay.new(pixelFile, 0.25, 0.661, 0.50, 0.004)
    self.accentOverlay:setColor(0.61, 0.73, 0.07, 1)

    self.cardAccentOverlay = Overlay.new(pixelFile, 0.29, 0.43, 0.004, 0.115)
    self.cardAccentOverlay:setColor(0.61, 0.73, 0.07, 1)

    self.solidOverlay = Overlay.new(pixelFile, 0, 0, 1, 1)

    return self
end

function HelperPersonnelSelectionOverlay:delete()
    self:unregisterActionEvents()
    self:restoreGameplayInput()
    self.consumeCancelUntilReleased = false

    if self.backgroundOverlay ~= nil then
        self.backgroundOverlay:delete()
        self.backgroundOverlay = nil
    end

    if self.highlightOverlay ~= nil then
        self.highlightOverlay:delete()
        self.highlightOverlay = nil
    end

    if self.accentOverlay ~= nil then
        self.accentOverlay:delete()
        self.accentOverlay = nil
    end

    if self.cardAccentOverlay ~= nil then
        self.cardAccentOverlay:delete()
        self.cardAccentOverlay = nil
    end

    if self.solidOverlay ~= nil then
        self.solidOverlay:delete()
        self.solidOverlay = nil
    end
    for _, overlay in pairs(self.portraitOverlays or {}) do
        overlay:delete()
    end
    self.portraitOverlays = {}
end

function HelperPersonnelSelectionOverlay:isWorkerExcluded(worker)
    local workerId = worker ~= nil and worker.id or nil
    return workerId ~= nil and (self.excludedWorkerIds[workerId] == true or self.excludedWorkerIds[tostring(workerId)] == true)
end

function HelperPersonnelSelectionOverlay:isWorkerAvailable(worker)
    if worker == nil or self:isWorkerExcluded(worker) or worker.busy == true then
        return false
    end
    local manager = self.app ~= nil and self.app.manager or nil
    if manager ~= nil and manager.isWorkerSick ~= nil and manager:isWorkerSick(worker) then
        return false
    end
    if manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(worker) then
        return false
    end
    local bridge = self.app ~= nil and self.app.helperBridge or nil
    return bridge == nil or bridge.isWorkerSelectable == nil or bridge:isWorkerSelectable(worker.id)
end

function HelperPersonnelSelectionOverlay:getWorkerAvailabilityReason(worker)
    if self:isWorkerAvailable(worker) then
        return g_i18n:getText("ui_selectionAvailable")
    end
    local manager = self.app ~= nil and self.app.manager or nil
    if manager ~= nil and manager.isWorkerSick ~= nil and manager:isWorkerSick(worker) then
        return g_i18n:getText("ui_selectionUnavailableSick")
    end
    if manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(worker) then
        return g_i18n:getText("ui_selectionUnavailableTraining")
    end
    if self:isWorkerExcluded(worker) then
        return g_i18n:getText("ui_selectionUnavailableReserved")
    end
    if worker.helperPersonnelAutoDriveContext == true then
        return g_i18n:getText("ui_selectionUnavailableAutoDrive")
    end
    if worker.busy == true then
        local activity = tostring(worker.currentJobActivityText or "")
        if string.find(string.lower(activity), "courseplay", 1, true) ~= nil then
            return g_i18n:getText("ui_selectionUnavailableCourseplay")
        end
        return g_i18n:getText("ui_selectionUnavailableFieldwork")
    end
    return g_i18n:getText("ui_selectionUnavailableOther")
end

function HelperPersonnelSelectionOverlay:refreshWorkerList()
    local manager = self.app ~= nil and self.app.manager or nil
    local workers = manager ~= nil and manager.workers or {}
    local filtered = {}
    for _, worker in ipairs(workers or {}) do
        if self.showAllWorkers or self:isWorkerAvailable(worker) then
            table.insert(filtered, worker)
        end
    end
    self.availableWorkers = filtered
    self.selectedIndex = math.max(1, math.min(self.selectedIndex or 1, math.max(#filtered, 1)))
end

function HelperPersonnelSelectionOverlay:detectExpectedSpecialization(vehicle)
    local manager = self.app ~= nil and self.app.manager or nil
    if manager == nil or manager.getSpecializationForVehicle == nil or HelperPersonnelViewBase == nil then
        return nil
    end

    local resolver = setmetatable({app = self.app}, {__index = HelperPersonnelViewBase})
    local rootVehicle = resolver:getRootVehicle(vehicle)
    local attachedObjects = resolver:collectAttachedObjects(rootVehicle or vehicle, {}, {}, 0)

    for _, object in ipairs(attachedObjects) do
        local specializationKey = manager:getSpecializationForVehicle(object)
        if specializationKey ~= nil then
            return specializationKey
        end
    end

    return manager:getSpecializationForVehicle(rootVehicle or vehicle)
end

function HelperPersonnelSelectionOverlay:open(vehicle, callback, excludedWorkerIds)
    local availableWorkers = self.app.manager:getAvailableWorkers()
    local originalCount = #availableWorkers
    local excludedCount = hpSelectionCountExcluded(excludedWorkerIds)

    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | open ENTER | Vehicle=%s | Original=%s | Excluded=%s | Visible=%s | Callback=%s",
        hpSelectionVehicleName(vehicle),
        tostring(originalCount),
        tostring(excludedCount),
        tostring(self.isVisible == true),
        tostring(callback ~= nil))

    if excludedWorkerIds ~= nil then
        local filteredWorkers = {}
        for _, worker in ipairs(availableWorkers) do
            local workerId = worker ~= nil and worker.id or nil
            local excluded = workerId ~= nil and (excludedWorkerIds[workerId] == true or excludedWorkerIds[tostring(workerId)] == true)
            hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | Candidate | Worker=%s | Excluded=%s | Vehicle=%s", tostring(workerId), tostring(excluded == true), hpSelectionVehicleName(vehicle))
            if workerId ~= nil and not excluded then
                table.insert(filteredWorkers, worker)
            end
        end
        availableWorkers = filteredWorkers
    end

    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | open Filtered | Vehicle=%s | Available=%s | Original=%s | Excluded=%s", hpSelectionVehicleName(vehicle), tostring(#availableWorkers), tostring(originalCount), tostring(excludedCount))

    if #availableWorkers == 0 then
        local warningText = g_i18n:getText("ui_selectionNoWorkers")
        if #self.app.manager.workers == 0 then
            warningText = g_i18n:getText("ui_selectionNoEmployees")
        end

        hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | open=false | Reason=noAvailableWorkers | Vehicle=%s | TotalWorkers=%s", hpSelectionVehicleName(vehicle), tostring(#self.app.manager.workers))

        if g_currentMission ~= nil then
            g_currentMission:showBlinkingWarning(warningText, 2200)
        end
        return false
    end

    self.vehicle = vehicle
    self.callback = callback
    self.excludedWorkerIds = excludedWorkerIds or {}
    self.expectedSpecializationKey = self:detectExpectedSpecialization(vehicle)
    self.showAllWorkers = false
    self:refreshWorkerList()
    self.selectedIndex = 1
    self.isVisible = true
    self.lastFallbackCommand = nil
    self.lastWorkerClickIndex = nil
    self.lastWorkerClickTime = 0

    self:suspendGameplayInput()
    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | open=true | Vehicle=%s | Available=%s | FirstSelection=%s", hpSelectionVehicleName(vehicle), tostring(#availableWorkers), tostring(availableWorkers[1] ~= nil and availableWorkers[1].id or nil))
    return true
end

function HelperPersonnelSelectionOverlay:close(confirmSelection)
    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | close ENTER | Confirm=%s | Vehicle=%s | SelectedIndex=%s | Available=%s", tostring(confirmSelection == true), hpSelectionVehicleName(self.vehicle), tostring(self.selectedIndex), tostring(#self.availableWorkers))

    local callback = self.callback
    local selectedWorker = nil

    if confirmSelection and self.availableWorkers[self.selectedIndex] ~= nil then
        selectedWorker = self.availableWorkers[self.selectedIndex]

        if not self:isWorkerAvailable(selectedWorker) then
            if self.app.showPlayerMessage ~= nil then
                self.app:showPlayerMessage("ui_selectionWorkerUnavailable")
            end
            return false
        end
    end

    self.vehicle = nil
    self.callback = nil
    self.availableWorkers = {}
    self.selectedIndex = 1
    self.isVisible = false
    self.showAllWorkers = false
    self.excludedWorkerIds = {}
    self.expectedSpecializationKey = nil
    self.lastWorkerClickIndex = nil
    self.lastWorkerClickTime = 0

    self:unregisterActionEvents()
    self:restoreGameplayInput()

    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | close Callback | HasCallback=%s | Worker=%s", tostring(callback ~= nil), tostring(selectedWorker ~= nil and selectedWorker.id or nil))

    if callback ~= nil then
        callback(selectedWorker)
    end
end

function HelperPersonnelSelectionOverlay:getActionId(actionName)
    if g_inputBinding ~= nil
        and g_inputBinding.nameActions ~= nil
        and g_inputBinding.nameActions[actionName] ~= nil then
        return g_inputBinding.nameActions[actionName]
    end

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
        return false
    end

    local lookupKey = self:getInputEventLookupKey(eventId)
    if self.suspendedInputEventLookup[lookupKey] then
        return false
    end

    local wasActive = self:getInputEventActive(eventId)
    if self:setInputEventActive(eventId, false) then
        self.suspendedInputEventLookup[lookupKey] = true
        table.insert(self.suspendedInputEvents, {
            eventId = eventId,
            wasActive = wasActive
        })
        return true
    end

    return false
end

function HelperPersonnelSelectionOverlay:suspendGameplayAction(actionName)
    if g_inputBinding == nil or g_inputBinding.contexts == nil then
        return 0
    end

    local actionId = self:getActionId(actionName)
    if actionId == nil then
        return 0
    end

    local suspendedCount = 0
    for _, context in pairs(g_inputBinding.contexts) do
        if context ~= nil and context.actionEvents ~= nil then
            local actionEvents = context.actionEvents[actionId]
            if actionEvents ~= nil then
                for _, eventId in ipairs(actionEvents) do
                    if self:suspendInputEvent(eventId) then
                        suspendedCount = suspendedCount + 1
                    end
                end
            end
        end
    end

    return suspendedCount
end

function HelperPersonnelSelectionOverlay:getControlledVehicle()
    if g_localPlayer ~= nil and g_localPlayer.getCurrentVehicle ~= nil then
        local success, vehicle = pcall(g_localPlayer.getCurrentVehicle, g_localPlayer)
        if success then
            return vehicle
        end
    end

    return nil
end

function HelperPersonnelSelectionOverlay:lockVehicleCameras(vehicle)
    if vehicle == nil or vehicle.spec_enterable == nil or vehicle.spec_enterable.cameras == nil then
        return
    end

    for _, camera in pairs(vehicle.spec_enterable.cameras) do
        if camera ~= nil then
            if self.cameraStateBackups[camera] == nil then
                self.cameraStateBackups[camera] = {
                    hasIsRotatable = camera.isRotatable ~= nil,
                    isRotatable = camera.isRotatable,
                    hasAllowTranslation = camera.allowTranslation ~= nil,
                    allowTranslation = camera.allowTranslation
                }
            end
            camera.isRotatable = false
            if camera.allowTranslation ~= nil then
                camera.allowTranslation = false
            end
        end
    end
end

function HelperPersonnelSelectionOverlay:lockGameplayCameras()
    self:lockVehicleCameras(self.vehicle)
    self:lockVehicleCameras(self:getControlledVehicle())

    if g_localPlayer ~= nil and g_localPlayer.inputComponent ~= nil then
        g_localPlayer.inputComponent.cameraRotationX = 0
        g_localPlayer.inputComponent.cameraRotationY = 0
    end
end

function HelperPersonnelSelectionOverlay:restoreGameplayCameras()
    for camera, state in pairs(self.cameraStateBackups or {}) do
        if camera ~= nil and state ~= nil then
            if state.hasIsRotatable then
                camera.isRotatable = state.isRotatable
            else
                camera.isRotatable = nil
            end
            if state.hasAllowTranslation then
                camera.allowTranslation = state.allowTranslation
            else
                camera.allowTranslation = nil
            end
        end
    end
    self.cameraStateBackups = {}
end

function HelperPersonnelSelectionOverlay:suspendGameplayInput()
    self:restoreGameplayInput()
    self.cursorReleaseFrames = 0
    self.cursorReleaseUntil = 0
    self.consumeCancelUntilReleased = false
    self.nativeMenuSuppressionUntil = 0

    for _, actionName in ipairs({
        "AXIS_LOOK_UPDOWN_PLAYER",
        "AXIS_LOOK_LEFTRIGHT_PLAYER",
        "AXIS_LOOK_UPDOWN_VEHICLE",
        "AXIS_LOOK_LEFTRIGHT_VEHICLE",
        "AXIS_LOOK_UPDOWN_DRAG",
        "AXIS_LOOK_LEFTRIGHT_DRAG"
    }) do
        self:suspendGameplayAction(actionName)
    end

    if g_inputBinding ~= nil and g_inputBinding.setShowMouseCursor ~= nil then
        g_inputBinding:setShowMouseCursor(true)
        self.inputBlockActive = true
    end

    if g_currentMission ~= nil then
        self.playerFrozenBackupWasSet = g_currentMission.isPlayerFrozen ~= nil
        self.playerFrozenBackup = g_currentMission.isPlayerFrozen
        g_currentMission.isPlayerFrozen = true
        self.inputBlockActive = true
    end


    self:lockGameplayCameras()
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
    self:restoreGameplayCameras()

    if self.inputBlockActive and g_currentMission ~= nil then
        if self.playerFrozenBackupWasSet then
            g_currentMission.isPlayerFrozen = self.playerFrozenBackup
        else
            g_currentMission.isPlayerFrozen = nil
        end
    end

    if self.inputBlockActive and g_inputBinding ~= nil and g_inputBinding.setShowMouseCursor ~= nil then
        g_inputBinding:setShowMouseCursor(false)
        self.cursorReleaseFrames = 12
        self.cursorReleaseUntil = (tonumber(g_time) or 0) + 500
    end

    self.playerFrozenBackup = nil
    self.playerFrozenBackupWasSet = false
    self.inputBlockActive = false
end

function HelperPersonnelSelectionOverlay:isNativeMenuSuppressed()
    local now = tonumber(g_time) or 0
    return self.consumeCancelUntilReleased == true or now < (self.nativeMenuSuppressionUntil or 0)
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
    anyRegistered = register("HP_SELECT_TOGGLE_ALL", self.onActionToggleAll, g_i18n:getText("input_HP_SELECT_TOGGLE_ALL")) or anyRegistered

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
        self:beginCancelSuppression()
        self:close(false)
    end
end

function HelperPersonnelSelectionOverlay:beginCancelSuppression()
    self.consumeCancelUntilReleased = true
    self.nativeMenuSuppressionUntil = (tonumber(g_time) or 0) + 500
end

function HelperPersonnelSelectionOverlay:isCursorReleasePending()
    local now = tonumber(g_time) or 0
    return (self.cursorReleaseFrames or 0) > 0 or now < (self.cursorReleaseUntil or 0)
end

function HelperPersonnelSelectionOverlay:onActionToggleAll(actionName, inputValue)
    if self.isVisible and self:isActionPressed(inputValue) then
        local selectedWorker = self.availableWorkers[self.selectedIndex]
        self.showAllWorkers = not self.showAllWorkers
        self:refreshWorkerList()
        if selectedWorker ~= nil then
            for index, worker in ipairs(self.availableWorkers) do
                if worker.id == selectedWorker.id then
                    self.selectedIndex = index
                    break
                end
            end
        end
    end
end

function HelperPersonnelSelectionOverlay:resetClickAreas()
    self.clickAreas = {}
end

function HelperPersonnelSelectionOverlay:addClickArea(x, y, width, height, workerIndex, action)
    if self.clickAreas == nil then
        self.clickAreas = {}
    end

    table.insert(self.clickAreas, {
        x = x,
        y = y,
        width = width,
        height = height,
        workerIndex = workerIndex,
        action = action
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

    local leftMouseButton = Input ~= nil and Input.MOUSE_BUTTON_LEFT or nil
    local isLeftMouseButton = button == nil or button == 0 or button == 1 or (leftMouseButton ~= nil and button == leftMouseButton)

    for i = #(self.clickAreas or {}), 1, -1 do
        local area = self.clickAreas[i]
        if area ~= nil and self:isPointInArea(posX, posY, area) then
            if isUp and isLeftMouseButton and area.action == "toggleAll" then
                self:onActionToggleAll(nil, 1)
            elseif isUp and isLeftMouseButton and area.workerIndex ~= nil and self.availableWorkers[area.workerIndex] ~= nil then
                local clickTime = tonumber(g_time) or 0
                local isDoubleClick = self.lastWorkerClickIndex == area.workerIndex and clickTime - (self.lastWorkerClickTime or 0) <= 400
                self.selectedIndex = area.workerIndex
                self.lastWorkerClickIndex = area.workerIndex
                self.lastWorkerClickTime = clickTime
                if isDoubleClick then
                    self:close(true)
                end
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
        local now = tonumber(g_time) or 0
        if self.consumeCancelUntilReleased
            and not self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_CANCEL)
            and now >= (self.nativeMenuSuppressionUntil or 0) then
            self.consumeCancelUntilReleased = false
        end
        if self:isCursorReleasePending() then
            if g_inputBinding ~= nil and g_inputBinding.setShowMouseCursor ~= nil then
                g_inputBinding:setShowMouseCursor(false)
            end
            self.cursorReleaseFrames = math.max((self.cursorReleaseFrames or 0) - 1, 0)
        end
        return
    end

    if g_inputBinding ~= nil and g_inputBinding.setShowMouseCursor ~= nil then
        if g_inputBinding.getShowMouseCursor == nil or not g_inputBinding:getShowMouseCursor() then
            g_inputBinding:setShowMouseCursor(true)
        end
    end
    self:lockGameplayCameras()
    local command = nil
    if self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_LEFT) then
        command = "left"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_RIGHT) then
        command = "right"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_CONFIRM) then
        command = "confirm"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_CANCEL) then
        command = "cancel"
    elseif self:isAnyKeyPressed(HelperPersonnelSelectionOverlay.KEYS_TOGGLE_ALL) then
        command = "toggleAll"
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
    elseif command == "toggleAll" then
        self:onActionToggleAll(nil, 1)
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
    elseif sym == self:getKeyConstant("KEY_space") then
        self:onActionConfirm(nil, 1)
        return true
    elseif sym == self:getKeyConstant("KEY_esc") or sym == self:getKeyConstant("KEY_escape") then
        self:onActionCancel(nil, 1)
        return true
    elseif sym == self:getKeyConstant("KEY_tab") then
        self:onActionToggleAll(nil, 1)
        return true
    end

    return false
end

local function hpSelectionToLinear(value)
    value = math.max(0, math.min(1, tonumber(value) or 0))
    if value <= 0.04045 then
        return value / 12.92
    end
    return ((value + 0.055) / 1.055) ^ 2.4
end

function HelperPersonnelSelectionOverlay:drawRect(x, y, width, height, r, g, b, a)
    if self.solidOverlay == nil then
        return
    end
    self.solidOverlay:setPosition(x, y)
    self.solidOverlay:setDimension(width, height)
    self.solidOverlay:setColor(hpSelectionToLinear(r), hpSelectionToLinear(g), hpSelectionToLinear(b), a)
    self.solidOverlay:render()
end

function HelperPersonnelSelectionOverlay:drawLabel(x, y, size, alignment, text, r, g, b, a, bold)
    setTextAlignment(alignment)
    setTextColor(hpSelectionToLinear(r), hpSelectionToLinear(g), hpSelectionToLinear(b), a or 1)
    setTextBold(bold == true)
    renderText(x, y, size, tostring(text or ""))
    setTextBold(false)
end

function HelperPersonnelSelectionOverlay:drawMetric(x, y, width, title, value)
    local px, py = self.drawPixelX, self.drawPixelY
    self:drawRect(x, y, width, 74 * py, 0.125, 0.137, 0.125, 1)
    self:drawLabel(x + 13 * px, y + 51 * py, 12 * py, RenderText.ALIGN_LEFT, title, 0.667, 0.690, 0.659, 1, false)
    self:drawLabel(x + width - 13 * px, y + 45 * py, 21 * py, RenderText.ALIGN_RIGHT, string.format("%d", math.floor((tonumber(value) or 0) + 0.5)), 0.941, 0.949, 0.933, 1, true)
    self:drawRect(x + 13 * px, y + 11 * py, width - 26 * px, 4 * py, 0.231, 0.251, 0.227, 1)
    self:drawRect(x + 13 * px, y + 11 * py, (width - 26 * px) * math.max(0, math.min(100, tonumber(value) or 0)) / 100, 4 * py, 0.722, 0.875, 0.098, 1)
end

function HelperPersonnelSelectionOverlay:getPortraitOverlay(worker)
    local workerId = worker ~= nil and worker.id or nil
    local bridge = self.app ~= nil and self.app.helperBridge or nil
    local filename = bridge ~= nil and bridge.getPortraitFilenameForPerson ~= nil and bridge:getPortraitFilenameForPerson(worker) or nil
    if workerId == nil or filename == nil or filename == "" then
        return nil
    end
    local cached = self.portraitOverlays[workerId]
    if cached == nil or cached.filename ~= filename then
        if cached ~= nil and cached.overlay ~= nil then
            cached.overlay:delete()
        end
        cached = {filename = filename, overlay = Overlay.new(filename, 0, 0, 1, 1)}
        self.portraitOverlays[workerId] = cached
    end
    return cached.overlay
end

function HelperPersonnelSelectionOverlay:draw()
    if not self.isVisible then
        return
    end

    self:resetClickAreas()
    local screenWidth = math.max(1, tonumber(g_screenWidth) or 1920)
    local screenHeight = math.max(1, tonumber(g_screenHeight) or 1080)
    local scale = math.min(1, (screenWidth - 48) / 896, (screenHeight - 48) / 510)
    local px, py = scale / screenWidth, scale / screenHeight
    self.drawPixelX, self.drawPixelY = px, py
    local windowWidth, windowHeight = 896 * px, 510 * py
    local windowX, windowY = (1 - windowWidth) * 0.5, (1 - windowHeight) * 0.5
    local headerHeight, footerHeight = 94 * py, 56 * py
    local contentY = windowY + footerHeight
    local contentHeight = windowHeight - headerHeight - footerHeight
    local headerY = windowY + windowHeight - headerHeight
    self:drawRect(windowX, windowY, windowWidth, windowHeight, 0.345, 0.376, 0.341, 1)
    self:drawRect(windowX + px, windowY + py, windowWidth - 2 * px, windowHeight - 2 * py, 0.067, 0.075, 0.067, 1)
    self:drawRect(windowX + px, windowY + windowHeight - 4 * py, windowWidth - 2 * px, 3 * py, 0.722, 0.875, 0.098, 1)
    self:drawRect(windowX, headerY, windowWidth, 1 * py, 0.255, 0.278, 0.251, 1)
    self:drawRect(windowX, windowY + footerHeight, windowWidth, 1 * py, 0.255, 0.278, 0.251, 1)

    self:drawLabel(windowX + 32 * px, headerY + 64 * py, 11 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_selectionKicker"), 0.722, 0.875, 0.098, 1, true)
    self:drawLabel(windowX + 32 * px, headerY + 24 * py, 28 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_selectionTitle"), 0.941, 0.949, 0.933, 1, false)

    local count = #self.availableWorkers
    local worker = self.availableWorkers[self.selectedIndex]
    self:drawLabel(windowX + windowWidth - 32 * px, headerY + 42 * py, 15 * py, RenderText.ALIGN_RIGHT, string.format("%d / %d", math.min(self.selectedIndex, count), count), 0.667, 0.690, 0.659, 1, false)

    if worker ~= nil then
        local manager = self.app.manager
        local available = self:isWorkerAvailable(worker)
        local identityX, identityY, identityWidth = windowX + 32 * px, contentY + 28 * py, 185 * px
        local profileX = identityX + identityWidth + 26 * px
        local profileWidth = windowX + windowWidth - 32 * px - profileX
        self:addClickArea(windowX, contentY, windowWidth, contentHeight, self.selectedIndex)

        local portraitWidth, portraitHeight = 100 * px, 100 * py
        local portraitX = identityX + (identityWidth - portraitWidth) * 0.5
        local portraitY = identityY + 202 * py
        self:drawRect(portraitX - 3 * px, portraitY - 3 * py, portraitWidth + 6 * px, portraitHeight + 6 * py, available and 0.722 or 0.32, available and 0.875 or 0.34, available and 0.098 or 0.32, 1)
        local portrait = self:getPortraitOverlay(worker)
        if portrait ~= nil then
            portrait:setPosition(portraitX, portraitY)
            portrait:setDimension(portraitWidth, portraitHeight)
            portrait:setColor(available and 1 or hpSelectionToLinear(0.55), available and 1 or hpSelectionToLinear(0.55), available and 1 or hpSelectionToLinear(0.55), 1)
            portrait:render()
        end

        self:drawLabel(identityX + identityWidth * 0.5, identityY + 175 * py, 18 * py, RenderText.ALIGN_CENTER, manager:getFullName(worker), available and 0.941 or 0.54, available and 0.949 or 0.54, available and 0.933 or 0.54, 1, false)
        local rankText = self.app.manager:getRankText(worker)
        self:drawLabel(identityX + identityWidth * 0.5, identityY + 151 * py, 13 * py, RenderText.ALIGN_CENTER, rankText, available and 0.722 or 0.45, available and 0.875 or 0.45, available and 0.098 or 0.45, 1, false)
        self:drawRect(identityX + 28 * px, identityY + 108 * py, identityWidth - 56 * px, 27 * py, available and 0.208 or 0.17, available and 0.267 or 0.17, available and 0.051 or 0.17, 1)
        self:drawLabel(identityX + identityWidth * 0.5, identityY + 116 * py, 12 * py, RenderText.ALIGN_CENTER, self:getWorkerAvailabilityReason(worker), available and 0.843 or 0.62, available and 0.945 or 0.62, available and 0.541 or 0.62, 1, false)

        local experience = tonumber(worker.experience) or 0
        local reliability = tonumber(worker.reliability) or 0
        local loyalty = tonumber(worker.loyalty) or 65
        self:drawLabel(profileX, identityY + 300 * py, 11 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_selectionPerformanceProfile"), 0.667, 0.690, 0.659, 1, true)
        local metricY = identityY + 210 * py
        local metricGap = 10 * px
        local metricWidth = (profileWidth - metricGap * 2) / 3
        self:drawMetric(profileX, metricY, metricWidth, g_i18n:getText("ui_pmStatExperience"), experience)
        self:drawMetric(profileX + metricWidth + metricGap, metricY, metricWidth, g_i18n:getText("ui_pmStatReliability"), reliability)
        self:drawMetric(profileX + (metricWidth + metricGap) * 2, metricY, metricWidth, g_i18n:getText("ui_pmStatLoyalty"), loyalty)

        local wage = worker.wage or 0
        if manager.getCurrentMonthlyWage ~= nil then
            wage = manager:getCurrentMonthlyWage(worker)
        end
        local wageText = g_i18n:formatMoney(wage, 0, true, false)
        local jobsCompleted = tonumber(worker.jobsCompleted) or 0
        local workSpeedPercent = manager.getWorkerWorkSpeedPercent ~= nil and manager:getWorkerWorkSpeedPercent(worker) or 100
        local age = manager.getPersonAge ~= nil and manager:getPersonAge(worker) or 0
        local detailY = identityY + 151 * py
        local detailWidth = profileWidth / 4
        local detailLabels = {g_i18n:getText("ui_selectionAgeLabel"), g_i18n:getText("ui_selectionWageLabel"), g_i18n:getText("ui_selectionJobsLabel"), g_i18n:getText("ui_selectionSpeedLabel")}
        local detailValues = {string.format(g_i18n:getText("ui_selectionAgeValue"), age), wageText, tostring(jobsCompleted), string.format("%d %%", workSpeedPercent)}
        for index = 1, 4 do
            local x = profileX + (index - 1) * detailWidth
            self:drawRect(x, detailY - 10 * py, detailWidth - 1 * px, 54 * py, 0.125, 0.137, 0.125, 1)
            self:drawLabel(x + 12 * px, detailY + 19 * py, 11 * py, RenderText.ALIGN_LEFT, detailLabels[index], 0.667, 0.690, 0.659, 1, false)
            self:drawLabel(x + 12 * px, detailY - 3 * py, 14 * py, RenderText.ALIGN_LEFT, detailValues[index], available and 0.941 or 0.58, available and 0.949 or 0.58, available and 0.933 or 0.58, 1, false)
        end

        local lowerY = identityY
        local lowerHeight = 127 * py
        local lowerGap = 12 * px
        local lowerWidth = (profileWidth - lowerGap) * 0.43
        local developmentX = profileX + lowerWidth + lowerGap
        local developmentWidth = profileWidth - lowerWidth - lowerGap
        self:drawRect(profileX, lowerY, lowerWidth, lowerHeight, 0.125, 0.137, 0.125, 1)
        self:drawRect(developmentX, lowerY, developmentWidth, lowerHeight, 0.125, 0.137, 0.125, 1)
        self:drawLabel(profileX + 13 * px, lowerY + lowerHeight - 22 * py, 11 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_specialization_short"), 0.667, 0.690, 0.659, 1, true)
        local specY = lowerY + lowerHeight - 47 * py
        local learned = manager.getLearnedSpecializationTable ~= nil and manager:getLearnedSpecializationTable(worker) or {}
        local specCount = 0
        for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
            if learned[key] == true and specCount < 5 then
                local active = manager:workerHasSpecialization(worker, key)
                local matchesExpectedJob = active and key == self.expectedSpecializationKey
                local textRed, textGreen, textBlue = 0.82, 0.82, 0.82
                if not available then
                    textRed, textGreen, textBlue = 0.55, 0.55, 0.55
                end
                if matchesExpectedJob then
                    textRed, textGreen, textBlue = 0.722, 0.875, 0.098
                end
                self:drawLabel(profileX + 13 * px, specY, 12 * py, RenderText.ALIGN_LEFT, manager:getSpecializationDisplayName(key), textRed, textGreen, textBlue, 1, matchesExpectedJob)
                specY = specY - 19 * py
                specCount = specCount + 1
            end
        end
        if specCount == 0 then
            self:drawLabel(profileX + 13 * px, specY, 12 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_selectionNoSpecialization"), 0.667, 0.690, 0.659, 1, false)
        end

        self:drawLabel(developmentX + 13 * px, lowerY + lowerHeight - 22 * py, 11 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_selectionProfessionalDevelopment"), 0.667, 0.690, 0.659, 1, true)
        local learnedCount = 0
        local developmentEntries = {}
        for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
            if manager:workerHasLearnedSpecialization(worker, key) then
                learnedCount = learnedCount + 1
            else
                local minutes = manager:getSpecializationProgressMinutes(worker, key)
                if minutes > 0 then
                    table.insert(developmentEntries, {key = key, minutes = minutes})
                end
            end
        end
        local requiredMinutes = (HelperPersonnelManager.SPECIALIZATION_LEARN_BASE_MINUTES or 240) + learnedCount * (HelperPersonnelManager.SPECIALIZATION_LEARN_INCREMENT_MINUTES or 180)
        for _, entry in ipairs(developmentEntries) do
            entry.percent = requiredMinutes > 0 and math.max(0, math.min(99, math.floor(entry.minutes / requiredMinutes * 100 + 0.5))) or 0
        end
        table.sort(developmentEntries, function(a, b)
            return a.percent == b.percent and a.minutes > b.minutes or a.percent > b.percent
        end)
        if #developmentEntries == 0 then
            self:drawLabel(developmentX + 13 * px, lowerY + lowerHeight - 51 * py, 11 * py, RenderText.ALIGN_LEFT, g_i18n:getText("ui_selectionNoSpecializationProgress"), 0.667, 0.690, 0.659, 1, false)
        else
            local progressY = lowerY + lowerHeight - 47 * py
            local barX = developmentX + 13 * px
            local barWidth = developmentWidth - 26 * px
            for index = 1, math.min(4, #developmentEntries) do
                local entry = developmentEntries[index]
                self:drawLabel(barX, progressY, 11 * py, RenderText.ALIGN_LEFT, manager:getSpecializationDisplayName(entry.key), available and 0.82 or 0.55, available and 0.82 or 0.55, available and 0.82 or 0.55, 1, false)
                self:drawLabel(developmentX + developmentWidth - 13 * px, progressY, 11 * py, RenderText.ALIGN_RIGHT, string.format("%d %%", entry.percent), available and 0.941 or 0.58, available and 0.949 or 0.58, available and 0.933 or 0.58, 1, true)
                self:drawRect(barX, progressY - 9 * py, barWidth, 4 * py, 0.231, 0.251, 0.227, 1)
                self:drawRect(barX, progressY - 9 * py, barWidth * entry.percent / 100, 4 * py, 0.722, 0.875, 0.098, 1)
                progressY = progressY - 25 * py
            end
        end
    else
        self:drawLabel(0.5, contentY + contentHeight * 0.5, 0.016, RenderText.ALIGN_CENTER, g_i18n:getText("ui_selectionNoWorkers"), 0.67, 0.69, 0.66, 1, false)
    end

    local toggleText = self.showAllWorkers and g_i18n:getText("ui_selectionShowAvailable") or g_i18n:getText("ui_selectionShowAll")
    self:drawRect(windowX + 32 * px, windowY + 18 * py, 18 * px, 18 * py, self.showAllWorkers and 0.722 or 0.25, self.showAllWorkers and 0.875 or 0.28, self.showAllWorkers and 0.098 or 0.25, 1)
    self:drawLabel(windowX + 61 * px, windowY + 20 * py, 12 * py, RenderText.ALIGN_LEFT, toggleText, 0.667, 0.690, 0.659, 1, false)
    self:addClickArea(windowX + 24 * px, windowY + 10 * py, 245 * px, 38 * py, nil, "toggleAll")
    self:drawLabel(windowX + windowWidth - 32 * px, windowY + 20 * py, 12 * py, RenderText.ALIGN_RIGHT, g_i18n:getText("ui_selectionFooterControls"), 0.667, 0.690, 0.659, 1, false)
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextColor(1, 1, 1, 1)
    setTextBold(false)
end
