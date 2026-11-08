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
    self.cameraStateBackups = {}
    self.keyConstantCache = {}
    self.showAllWorkers = false
    self.excludedWorkerIds = {}
    self.expectedSpecializationKey = nil

    return self
end

function HelperPersonnelSelectionOverlay:delete()
    if self.isVisible then self:close(false) end
    self:unregisterActionEvents()
    self:restoreGameplayInput()
    self.consumeCancelUntilReleased = false
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

    if self.isVisible or self.app.tryRegisterStandaloneMenu == nil or not self.app:tryRegisterStandaloneMenu()
        or self.app.selectionDialog == nil or g_gui == nil then
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
    self.dialogRefreshElapsed = 0

    self:suspendGameplayInput()
    self.app.selectionDialog:setContext(self)
    self.guiTransition = true
    local ok, dialog = pcall(g_gui.showDialog, g_gui, "HelperPersonnelSelectionDialog")
    self.guiTransition = false
    if not ok or dialog == nil then
        self.isVisible = false
        self.callback = nil
        self.vehicle = nil
        self.app.selectionDialog:setContext(nil)
        self.guiTransition = true
        local closed, closeError = pcall(g_gui.closeDialogByName, g_gui, "HelperPersonnelSelectionDialog")
        self.guiTransition = false
        if not closed then
            Logging.warning("FS25_HelperPersonnel: Failed to clean up employee selection dialog: %s", tostring(closeError))
        end
        self:restoreGameplayInput()
        Logging.warning("FS25_HelperPersonnel: Employee selection dialog could not open: %s", tostring(dialog))
        return false
    end
    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | open=true | Vehicle=%s | Available=%s | FirstSelection=%s", hpSelectionVehicleName(vehicle), tostring(#availableWorkers), tostring(availableWorkers[1] ~= nil and availableWorkers[1].id or nil))
    return true
end

function HelperPersonnelSelectionOverlay:close(confirmSelection, fromDialog)
    hpSelectionDebug("FS25_HelperPersonnel: Selection diagnostics | close ENTER | Confirm=%s | Vehicle=%s | SelectedIndex=%s | Available=%s", tostring(confirmSelection == true), hpSelectionVehicleName(self.vehicle), tostring(self.selectedIndex), tostring(#self.availableWorkers))

    if not self.isVisible then return false end
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
    if not fromDialog and g_gui ~= nil and self.app.selectionDialog ~= nil then
        self.guiTransition = true
        g_gui:closeDialogByName("HelperPersonnelSelectionDialog")
        self.guiTransition = false
    end
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
        self.mouseCursorBackup = g_inputBinding.getShowMouseCursor ~= nil and g_inputBinding:getShowMouseCursor() or false
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
        g_inputBinding:setShowMouseCursor(self.mouseCursorBackup == true)
    end

    self.playerFrozenBackup = nil
    self.playerFrozenBackupWasSet = false
    self.mouseCursorBackup = nil
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
    if self.app.selectionDialog ~= nil then self.app.selectionDialog:refresh() end
end

function HelperPersonnelSelectionOverlay:onActionRight(actionName, inputValue)
    if not self.isVisible or not self:isActionPressed(inputValue) or #self.availableWorkers <= 1 then
        return
    end

    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.availableWorkers then
        self.selectedIndex = 1
    end
    if self.app.selectionDialog ~= nil then self.app.selectionDialog:refresh() end
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
        if self.app.selectionDialog ~= nil then self.app.selectionDialog:refresh() end
    end
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
        return
    end

    if g_inputBinding ~= nil and g_inputBinding.setShowMouseCursor ~= nil then
        if g_inputBinding.getShowMouseCursor == nil or not g_inputBinding:getShowMouseCursor() then
            g_inputBinding:setShowMouseCursor(true)
        end
    end
    self:lockGameplayCameras()
    self.dialogRefreshElapsed = (self.dialogRefreshElapsed or 0) + (dt or 0)
    if self.dialogRefreshElapsed >= 500 then
        self.dialogRefreshElapsed = 0
        if self.app.selectionDialog ~= nil then self.app.selectionDialog:refresh() end
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

