HelperPersonnelApp = {}
HelperPersonnelApp_mt = Class(HelperPersonnelApp)

function HelperPersonnelApp.new(modName, modDir, customMt)
    local self = setmetatable({}, customMt or HelperPersonnelApp_mt)
    self.modName = modName
    self.modDir = modDir
    self.manager = nil
    self.helperBridge = nil
    self.selectionOverlay = nil
    self.pendingWorkerIdsByVehicleKey = {}
    self.pendingWorkerIdForNextAIJob = nil
    self.activeJobsRestoreAttempts = 0
    self.activeJobsRestoreDone = false
    self.isMissionDeleting = false
    self.standaloneMenu = nil
    self.standaloneMenuPages = nil
    self.standaloneMenuLoaded = false
    self.standaloneMenuTextureLoaded = false
    self.standaloneMenuActionRegistered = false
    self.standaloneMenuActionEventId = nil
    self.standaloneMenuHotkeyDown = false
    return self
end


function HelperPersonnelApp:load()
    self.manager = HelperPersonnelManager.new(self)
    self.helperBridge = HelperPersonnelHelperBridge.new(self)
    self.selectionOverlay = HelperPersonnelSelectionOverlay.new(self)

    if self:isServerAuthority() then
        self.manager:loadFromSavegame()
        self.helperBridge:rebuildHelperProfiles()
        if self.manager.repairApplicantGendersFromHelperProfiles ~= nil then
            self.manager:repairApplicantGendersFromHelperProfiles()
        end
        self:restoreActiveAIJobs()
        self.lastNetworkSyncCounter = -1
    else
        self.manager.lastActionText = self.manager:getLocalizedText("ui_waitingForServerData", "Waiting for server data")
        self:requestNetworkState()
    end

    if g_messageCenter ~= nil and MessageType ~= nil then
        if MessageType.PERIOD_CHANGED ~= nil then
            g_messageCenter:subscribe(MessageType.PERIOD_CHANGED, self.onPeriodChanged, self)
        end
        if MessageType.PLAYER_FARM_CHANGED ~= nil then
            g_messageCenter:subscribe(MessageType.PLAYER_FARM_CHANGED, self.onPlayerFarmChanged, self)
        end
    end

    if g_currentMission ~= nil then
        g_currentMission:addDrawable(self)
        g_currentMission:addUpdateable(self)
    end

    if self.manager ~= nil and self.manager.refreshFarmContext ~= nil then
        self.manager:refreshFarmContext()
    end

    self:tryRegisterStandaloneMenu()
    self:registerStandaloneMenuAction()
    self:updateStandaloneMenuHotkey()
end


function HelperPersonnelApp:beginMissionDelete()
    self.isMissionDeleting = true

    if self.manager ~= nil and self.prepareSaveSnapshot ~= nil then
        self:prepareSaveSnapshot()
    end
end

function HelperPersonnelApp:delete()
    if g_messageCenter ~= nil and g_messageCenter.unsubscribeAll ~= nil then
        g_messageCenter:unsubscribeAll(self)
    end

    self:unregisterStandaloneMenuAction()
    self.standaloneMenu = nil
    self.standaloneMenuPages = nil
    self.standaloneMenuLoaded = false

    if self.selectionOverlay ~= nil then
        self.selectionOverlay:delete()
        self.selectionOverlay = nil
    end

    if self.helperBridge ~= nil then
        self.helperBridge:delete()
        self.helperBridge = nil
    end
end


function HelperPersonnelApp:prepareSaveSnapshot()
    if self.manager ~= nil and self.manager.captureSaveSnapshot ~= nil then
        self.manager:captureSaveSnapshot(self:getActiveAIJobs(), function(vehicle)
            return self:getVehicleKey(vehicle)
        end, self.helperBridge)
    end
end

function HelperPersonnelApp:save()
    if not self:isServerAuthority() then
        return
    end

    self:prepareSaveSnapshot()

    if self.manager ~= nil then
        self.manager:saveToSavegame()
    end
end

function HelperPersonnelApp:update(dt)
    self:tryRegisterStandaloneMenu()
    self:registerStandaloneMenuAction()
    self:updateStandaloneMenuHotkey()

    if self:isServerAuthority() and self.manager ~= nil and self.manager.update ~= nil then
        self.manager:update(dt)
        self:syncNetworkStateIfNeeded()
    end

    if self.selectionOverlay ~= nil then
        self.selectionOverlay:update(dt)
    end

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.updatePendingSelection ~= nil then
        HelperPersonnelAIStartHooks.updatePendingSelection(dt)
    end

    if self.activeJobsRestoreDone ~= true then
        self.activeJobsRestoreAttempts = (self.activeJobsRestoreAttempts or 0) + 1
        self:restoreActiveAIJobs()
        if self.activeJobsRestoreAttempts >= 180 then
            self.activeJobsRestoreDone = true
            self:finishActiveJobRestore()
        end
    end
end


function HelperPersonnelApp:onPeriodChanged(period, year)
    if not self:isServerAuthority() then
        return
    end

    if self.manager ~= nil and self.manager.onPeriodChanged ~= nil then
        self.manager:onPeriodChanged(period, year)
        self:syncNetworkStateToClients()
    end
end

function HelperPersonnelApp:finishActiveJobRestore()
    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.pendingRestoredJobs ~= nil then
        for job, _ in pairs(HelperPersonnelAIJobHooks.pendingRestoredJobs) do
            HelperPersonnelAIJobHooks.pendingRestoredJobs[job] = nil
        end
    end

    if self.manager ~= nil then
        for _, worker in ipairs(self.manager.workers or {}) do
            if worker.restorePending == true and worker.busy ~= true then
                worker.restorePending = false
                worker.restoreVehicleName = nil
                worker.restoreVehicleKey = nil
                worker.vehicleName = ""
                worker.vehicleKey = nil
                worker.currentJobStartedAt = 0
                worker.currentJobElapsedMs = 0
            end
        end
    end
end

function HelperPersonnelApp:draw()
    if self.selectionOverlay ~= nil then
        self.selectionOverlay:draw()
    end
end

function HelperPersonnelApp:mouseEvent(posX, posY, isDown, isUp, button)
    if self.selectionOverlay ~= nil and self.selectionOverlay.mouseEvent ~= nil then
        return self.selectionOverlay:mouseEvent(posX, posY, isDown, isUp, button)
    end

    return false
end

function HelperPersonnelApp:keyEvent(unicode, sym, modifier, isDown)
    if self.selectionOverlay ~= nil then
        return self.selectionOverlay:keyEvent(unicode, sym, modifier, isDown)
    end

    return false
end

function HelperPersonnelApp:getActiveAIJobs()
    if g_currentMission == nil or g_currentMission.aiSystem == nil then
        return nil
    end

    local aiSystem = g_currentMission.aiSystem
    if aiSystem.getActiveJobs ~= nil then
        return aiSystem:getActiveJobs()
    end

    return aiSystem.activeJobs
end

function HelperPersonnelApp:restoreActiveAIJobs()
    if self.helperBridge == nil then
        return false
    end

    local restored = 0
    local activeJobs = self:getActiveAIJobs()

    if activeJobs == nil then
        return false
    end

    for _, job in pairs(activeJobs) do
        if job ~= nil then
            local workerId = nil

            if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.pendingRestoredJobs ~= nil then
                workerId = HelperPersonnelAIJobHooks.pendingRestoredJobs[job]
            end

            if workerId == nil and self.helperBridge.getWorkerIdByJob ~= nil then
                workerId = self.helperBridge:getWorkerIdByJob(job)
            end

            if workerId == nil then
                workerId = job.helperPersonnelWorkerId
            end

            if workerId == nil and self.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
                workerId = self.helperBridge:resolveRestoredWorkerIdForJob(job)
            end

            if workerId == nil and self.helperBridge.getVehicleKeyFromJob ~= nil and self.helperBridge.getWorkerIdByVehicleKey ~= nil then
                local vehicleKey = self.helperBridge:getVehicleKeyFromJob(job)
                workerId = self.helperBridge:getWorkerIdByVehicleKey(vehicleKey)
            end

            if workerId == nil and job.helperIndex ~= nil and self.helperBridge.getWorkerIdByHelperIndex ~= nil then
                workerId = self.helperBridge:getWorkerIdByHelperIndex(job.helperIndex)
            end

            if workerId ~= nil and self.helperBridge:attachRestoredJob(job, workerId) then
                restored = restored + 1
                if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.pendingRestoredJobs ~= nil then
                    HelperPersonnelAIJobHooks.pendingRestoredJobs[job] = nil
                end
            end
        end
    end

    return restored > 0
end

function HelperPersonnelApp:onMission00Loaded()
    self:tryRegisterStandaloneMenu()
    self:registerStandaloneMenuAction()
end


function HelperPersonnelApp:getSavegamePath()
    if g_currentMission == nil or g_currentMission.missionInfo == nil then
        return nil
    end

    local savegameDirectory = g_currentMission.missionInfo.savegameDirectory
    if savegameDirectory == nil or savegameDirectory == "" then
        return nil
    end

    return savegameDirectory .. "/helperPersonnel.xml"
end


function HelperPersonnelApp:getRootVehicle(vehicle)
    if vehicle == nil then
        return nil
    end

    if vehicle.getRootVehicle ~= nil then
        return vehicle:getRootVehicle()
    end

    return vehicle
end

function HelperPersonnelApp:getVehicleKey(vehicle)
    local rootVehicle = self:getRootVehicle(vehicle)
    if rootVehicle == nil then
        return nil
    end

    if rootVehicle.getUniqueId ~= nil then
        local success, uniqueId = pcall(rootVehicle.getUniqueId, rootVehicle)
        if success and uniqueId ~= nil and tostring(uniqueId) ~= "" then
            return "uid:" .. tostring(uniqueId)
        end
    end

    if rootVehicle.uniqueId ~= nil and tostring(rootVehicle.uniqueId) ~= "" then
        return "uid:" .. tostring(rootVehicle.uniqueId)
    end

    if rootVehicle.rootNode ~= nil then
        return "node:" .. tostring(rootVehicle.rootNode)
    end

    return tostring(rootVehicle)
end

function HelperPersonnelApp:getVehicleName(vehicle)
    local rootVehicle = self:getRootVehicle(vehicle)
    if rootVehicle == nil then
        return ""
    end

    if rootVehicle.getName ~= nil then
        return rootVehicle:getName()
    elseif rootVehicle.configFileName ~= nil then
        return rootVehicle.configFileName
    end

    return "Fahrzeug"
end

function HelperPersonnelApp:setPendingWorkerForVehicle(vehicle, workerId)
    self.pendingWorkerIdForNextAIJob = workerId

    local key = self:getVehicleKey(vehicle)
    if key == nil then
        return
    end

    self.pendingWorkerIdsByVehicleKey[key] = workerId
end

function HelperPersonnelApp:getPendingWorkerForVehicle(vehicle)
    local key = self:getVehicleKey(vehicle)
    if key ~= nil then
        return self.pendingWorkerIdsByVehicleKey[key]
    end

    return self.pendingWorkerIdForNextAIJob
end

function HelperPersonnelApp:consumePendingWorkerForVehicle(vehicle)
    local key = self:getVehicleKey(vehicle)
    local workerId = nil

    if key ~= nil then
        workerId = self.pendingWorkerIdsByVehicleKey[key]
        self.pendingWorkerIdsByVehicleKey[key] = nil
    else
        workerId = self.pendingWorkerIdForNextAIJob
    end

    if self.pendingWorkerIdForNextAIJob == workerId then
        self.pendingWorkerIdForNextAIJob = nil
    end

    return workerId
end

function HelperPersonnelApp:isLocalizationKey(text)
    if type(text) ~= "string" then
        return false
    end

    if string.find(text, " ", 1, true) ~= nil then
        return false
    end

    return string.match(text, "^ui_") ~= nil
        or string.match(text, "^input_") ~= nil
        or string.match(text, "^button_") ~= nil
        or string.match(text, "^action_") ~= nil
end

function HelperPersonnelApp:resolveText(textKeyOrText)
    local text = textKeyOrText

    if not self:isLocalizationKey(textKeyOrText) then
        return text
    end

    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, translated = pcall(function()
            return g_i18n:getText(textKeyOrText)
        end)

        if ok and translated ~= nil and translated ~= "" and string.match(translated, "^Missing '") == nil then
            text = translated
        end
    end

    return text
end

function HelperPersonnelApp:showPlayerMessage(textKeyOrText)
    local text = self:resolveText(textKeyOrText)

    if text == nil or text == "" then
        return
    end

    if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
        g_currentMission:showBlinkingWarning(text, 2200)
    elseif Logging ~= nil and Logging.info ~= nil then
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: %s", tostring(text))
    end
end

function HelperPersonnelApp:getDefaultNotificationType()
    if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_INFO ~= nil then
        return FSBaseMission.INGAME_NOTIFICATION_INFO
    end

    return 0
end

function HelperPersonnelApp:showIngameNotificationLocal(textKeyOrText, notificationType)
    local text = self:resolveText(textKeyOrText)

    if text == nil or text == "" then
        return
    end

    notificationType = notificationType or self:getDefaultNotificationType()

    if g_currentMission ~= nil and g_currentMission.addIngameNotification ~= nil then
        g_currentMission:addIngameNotification(notificationType, text)
    elseif g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
        g_currentMission:showBlinkingWarning(text, 2200)
    elseif Logging ~= nil and Logging.info ~= nil then
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: %s", tostring(text))
    end
end

function HelperPersonnelApp:showIngameNotification(textKeyOrText, notificationType)
    local text = self:resolveText(textKeyOrText)

    if text == nil or text == "" then
        return
    end

    notificationType = notificationType or self:getDefaultNotificationType()
    self:showIngameNotificationLocal(text, notificationType)

    if self:isServerAuthority() and g_server ~= nil and HelperPersonnelNotificationEvent ~= nil then
        g_server:broadcastEvent(HelperPersonnelNotificationEvent.new(text, notificationType), false, nil, nil)
    end
end

function HelperPersonnelApp:prepareAIJobForWorker(aiJob, vehicle, workerId)
    if workerId == nil then
        return
    end

    self:setPendingWorkerForVehicle(vehicle, workerId)

    if aiJob ~= nil then
        aiJob.helperPersonnelWorkerId = workerId
        if self.helperBridge ~= nil then
            self.helperBridge:applyWorkerToJob(aiJob, workerId)
        end
    end
end

function HelperPersonnelApp:showWorkerSelectionForVehicle(vehicle, callback, excludedWorkerIds)
    if self.selectionOverlay == nil then
        return false
    end

    return self.selectionOverlay:open(vehicle, callback, excludedWorkerIds)
end

function HelperPersonnelApp:isServerAuthority()
    if g_server ~= nil then
        return true
    end

    if g_currentMission ~= nil and g_currentMission.getIsServer ~= nil then
        return g_currentMission:getIsServer() == true
    end

    return false
end

function HelperPersonnelApp:isMultiplayerClient()
    return g_server == nil and g_client ~= nil
end

function HelperPersonnelApp:getNetworkState()
    if self.manager ~= nil and self.manager.getNetworkState ~= nil then
        return self.manager:getNetworkState()
    end

    return nil
end

function HelperPersonnelApp:sendNetworkStateToConnection(connection)
    if not self:isServerAuthority() or connection == nil or connection.sendEvent == nil then
        return false
    end

    local state = self:getNetworkState()
    if state == nil or HelperPersonnelNetworkStateEvent == nil then
        return false
    end

    connection:sendEvent(HelperPersonnelNetworkStateEvent.new(state))
    return true
end

function HelperPersonnelApp:syncNetworkStateToClients()
    if not self:isServerAuthority() or g_server == nil or HelperPersonnelNetworkStateEvent == nil then
        return false
    end

    local state = self:getNetworkState()
    if state == nil then
        return false
    end

    g_server:broadcastEvent(HelperPersonnelNetworkStateEvent.new(state), false, nil, nil)
    self.lastNetworkSyncCounter = self.manager ~= nil and (self.manager.changeCounter or 0) or self.lastNetworkSyncCounter
    return true
end

function HelperPersonnelApp:syncNetworkStateIfNeeded()
    if not self:isServerAuthority() or self.manager == nil then
        return
    end

    local counter = self.manager.changeCounter or 0
    if self.lastNetworkSyncCounter ~= counter then
        self:syncNetworkStateToClients()
    end
end

function HelperPersonnelApp:requestNetworkState()
    if not self:isMultiplayerClient() or g_client == nil or HelperPersonnelNetworkRequestStateEvent == nil then
        return false
    end

    local connection = g_client.getServerConnection ~= nil and g_client:getServerConnection() or nil
    if connection ~= nil and connection.sendEvent ~= nil then
        connection:sendEvent(HelperPersonnelNetworkRequestStateEvent.new())
        return true
    end

    return false
end

function HelperPersonnelApp:applyNetworkState(state)
    if self:isServerAuthority() then
        return false
    end
    if self.manager == nil or self.manager.applyNetworkState == nil then
        return false
    end

    local applied = self.manager:applyNetworkState(state)
    if applied then
        if self.helperBridge ~= nil and self.helperBridge.rebuildHelperProfiles ~= nil then
            self.helperBridge:rebuildHelperProfiles()
        end
        if self.manager.refreshFarmContext ~= nil then
            self.manager:refreshFarmContext()
        end
        self:refreshPersonnelMenu()
    end
    return applied
end






function HelperPersonnelApp:getCurrentFarmId()
    if self.manager ~= nil and self.manager.getCurrentFarmId ~= nil then
        return self.manager:getCurrentFarmId()
    end
    if FarmManager ~= nil and FarmManager.SINGLEPLAYER_FARM_ID ~= nil then
        return FarmManager.SINGLEPLAYER_FARM_ID
    end
    return 1
end


function HelperPersonnelApp:onPlayerFarmChanged()
    if self.manager ~= nil and self.manager.refreshFarmContext ~= nil then
        self.manager:refreshFarmContext()
    end

    if self:isMultiplayerClient() then
        self:requestNetworkState()
    end
    self:refreshPersonnelMenu()
end


function HelperPersonnelApp:processNetworkAction(actionName, targetId, connection, farmId, actionData)
    if not self:isServerAuthority() or self.manager == nil then
        return false
    end

    farmId = tonumber(farmId) or self:getCurrentFarmId()
    local changed = false

    if actionName == HelperPersonnelNetwork.ACTION_HIRE and self.manager.hireApplicantForFarm ~= nil then
        changed = self.manager:hireApplicantForFarm(targetId, farmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_DISMISS and self.manager.dismissWorkerForFarm ~= nil then
        changed = self.manager:dismissWorkerForFarm(targetId, farmId) == true
    end

    if changed then
        self:syncNetworkStateToClients()
    elseif connection ~= nil then
        self:sendNetworkStateToConnection(connection)
    end

    return changed
end

function HelperPersonnelApp:requestHireApplicant(applicantId)
    local farmId = self:getCurrentFarmId()

    if self:isServerAuthority() then
        local changed = self.manager ~= nil and self.manager.hireApplicantForFarm ~= nil and self.manager:hireApplicantForFarm(applicantId, farmId) == true
        if changed then
            self:syncNetworkStateToClients()
        end
        return changed
    end

    if self:isMultiplayerClient() and g_client ~= nil and HelperPersonnelNetworkActionEvent ~= nil then
        local connection = g_client.getServerConnection ~= nil and g_client:getServerConnection() or nil
        if connection ~= nil and connection.sendEvent ~= nil then
            connection:sendEvent(HelperPersonnelNetworkActionEvent.new(HelperPersonnelNetwork.ACTION_HIRE, applicantId, nil, farmId))
            return true
        end
    end

    return false
end

function HelperPersonnelApp:requestDismissWorker(workerId)
    local farmId = self:getCurrentFarmId()

    if self:isServerAuthority() then
        local changed = self.manager ~= nil and self.manager.dismissWorkerForFarm ~= nil and self.manager:dismissWorkerForFarm(workerId, farmId) == true
        if changed then
            self:syncNetworkStateToClients()
        end
        return changed
    end

    if self:isMultiplayerClient() and g_client ~= nil and HelperPersonnelNetworkActionEvent ~= nil then
        local connection = g_client.getServerConnection ~= nil and g_client:getServerConnection() or nil
        if connection ~= nil and connection.sendEvent ~= nil then
            connection:sendEvent(HelperPersonnelNetworkActionEvent.new(HelperPersonnelNetwork.ACTION_DISMISS, workerId, nil, farmId))
            return true
        end
    end

    return false
end
