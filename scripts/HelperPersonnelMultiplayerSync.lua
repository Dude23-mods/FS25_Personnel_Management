

HelperPersonnelNetworkSelectedWorkerEvent = {}
local HelperPersonnelNetworkSelectedWorkerEvent_mt = Class(HelperPersonnelNetworkSelectedWorkerEvent, Event)
InitEventClass(HelperPersonnelNetworkSelectedWorkerEvent, "HelperPersonnelNetworkSelectedWorkerEvent")

function HelperPersonnelNetworkSelectedWorkerEvent.emptyNew()
    return Event.new(HelperPersonnelNetworkSelectedWorkerEvent_mt)
end

function HelperPersonnelNetworkSelectedWorkerEvent.new(workerId, farmId, vehicleKey, vehicleName)
    local self = HelperPersonnelNetworkSelectedWorkerEvent.emptyNew()
    self.workerId = tonumber(workerId) or 0
    self.farmId = tonumber(farmId) or 1
    self.vehicleKey = vehicleKey
    self.vehicleName = vehicleName
    return self
end

function HelperPersonnelNetworkSelectedWorkerEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.workerId or 0)
    HelperPersonnelNetwork.writeFarmId(streamId, self.farmId or 1)
    HelperPersonnelNetwork.writeString(streamId, self.vehicleKey)
    HelperPersonnelNetwork.writeString(streamId, self.vehicleName)
end

function HelperPersonnelNetworkSelectedWorkerEvent:readStream(streamId, connection)
    self.workerId = streamReadInt32(streamId)
    self.farmId = HelperPersonnelNetwork.readFarmId(streamId)
    self.vehicleKey = HelperPersonnelNetwork.readString(streamId)
    self.vehicleName = HelperPersonnelNetwork.readString(streamId)
    self:run(connection)
end

function HelperPersonnelNetworkSelectedWorkerEvent:run(connection)
    local app = g_helperPersonnelApp
    if app == nil or app.processNetworkSelection == nil then
        return
    end

    if connection == nil or connection.getIsServer == nil or connection:getIsServer() ~= true then
        app:processNetworkSelection(self.workerId, self.farmId, self.vehicleKey, self.vehicleName, connection)
    end
end

function HelperPersonnelManager:getWorkerFarmId(workerId)
    if self.findWorkerFarmData ~= nil then
        local _, farmId = self:findWorkerFarmData(workerId)
        if farmId ~= nil then
            return farmId
        end
    end

    return self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1
end

function HelperPersonnelManager:getWorkerFromFarmData(data, workerId)
    workerId = tonumber(workerId)
    if data == nil or workerId == nil then
        return nil
    end

    for _, worker in ipairs(data.workers or {}) do
        if tonumber(worker.id) == workerId then
            return worker
        end
    end

    return nil
end

function HelperPersonnelManager:setSelectedWorkerForFarm(workerId, farmId, vehicleKey, vehicleName)
    workerId = tonumber(workerId)
    farmId = tonumber(farmId) or (self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1)

    local data = self.getOrCreateFarmData ~= nil and self:getOrCreateFarmData(farmId, false) or nil
    if data == nil then
        return false
    end

    if workerId == nil or workerId <= 0 then
        data.selectedWorkerId = nil
        data.selectedVehicleKey = nil
        data.selectedVehicleName = nil
        data.selectedTimestamp = g_time or 0
    else
        local worker = self:getWorkerFromFarmData(data, workerId)
        if worker == nil then
            return false
        end

        data.selectedWorkerId = workerId
        data.selectedVehicleKey = vehicleKey
        data.selectedVehicleName = vehicleName or ""
        data.selectedTimestamp = g_time or 0
    end

    self.changeCounter = (self.changeCounter or 0) + 1
    if self.notifyDataChanged ~= nil then
        self:notifyDataChanged()
    end

    return true
end

function HelperPersonnelManager:getActiveAssignmentsForFarmData(data)
    local assignments = {}

    for _, worker in ipairs(data ~= nil and data.workers or {}) do
        local isActive = worker.busy == true or worker.restorePending == true
        if isActive and worker.id ~= nil then
            table.insert(assignments, {
                workerId = worker.id,
                vehicleKey = worker.vehicleKey or worker.restoreVehicleKey,
                vehicleName = worker.vehicleName or worker.restoreVehicleName or "",
                helperIndex = worker.assignedHelperIndex,
                baseHelperIndex = worker.assignedBaseHelperIndex,
                currentJobElapsedMs = self.getCurrentJobElapsedMs ~= nil and self:getCurrentJobElapsedMs(worker) or worker.currentJobElapsedMs
            })
        end
    end

    return assignments
end

function HelperPersonnelManager:applyActiveAssignmentsToFarmData(data, assignments)
    if data == nil then
        return
    end

    data.activeAssignments = assignments or {}

    for _, assignment in ipairs(data.activeAssignments) do
        local worker = self:getWorkerFromFarmData(data, assignment.workerId)
        if worker ~= nil then
            worker.busy = true
            worker.vehicleKey = assignment.vehicleKey or worker.vehicleKey
            worker.vehicleName = assignment.vehicleName or worker.vehicleName or ""
            worker.assignedHelperIndex = assignment.helperIndex or worker.assignedHelperIndex
            worker.assignedBaseHelperIndex = assignment.baseHelperIndex or worker.assignedBaseHelperIndex
            if assignment.currentJobElapsedMs ~= nil then
                worker.currentJobElapsedMs = math.max(0, tonumber(assignment.currentJobElapsedMs) or 0)
                worker.currentJobStartedAt = self.getCurrentTimestampMs ~= nil and (self:getCurrentTimestampMs() - worker.currentJobElapsedMs) or worker.currentJobStartedAt
            end
            worker.reliabilityJobAbortChecked = true
            worker.reliabilityJobAbortCheckAt = 0
        end
    end
end

local HP_V1540_ORIGINAL_MANAGER_GET_NETWORK_STATE = HelperPersonnelManager.getNetworkState
local function hpLayer_HelperPersonnelManager_getNetworkState_1(self)
    if self.storeCurrentFarmData ~= nil then
        self:storeCurrentFarmData()
    end
    if self.refreshFarmContext ~= nil then
        self:refreshFarmContext()
    end

    local state = {
        version = HelperPersonnelNetwork.STATE_VERSION,
        nextPersonId = self.nextPersonId or 1,
        changeCounter = self.changeCounter or 0,
        activeFarmId = self.activeFarmId or (self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1),
        config = self.config ~= nil and self.config.getNetworkState ~= nil and self.config:getNetworkState() or nil,
        farms = {}
    }

    if self.getSortedFarmIds ~= nil then
        for _, farmId in ipairs(self:getSortedFarmIds()) do
            if self.ensureMonthlyTrainingOffers ~= nil and self.executeWithFarmContext ~= nil then
                self:executeWithFarmContext(farmId, function()
                    self:ensureMonthlyTrainingOffers()
                end, true)
            end
            local data = self.farms ~= nil and self.farms[farmId] or nil
            if data ~= nil then
                local farmState = {
                    farmId = data.farmId or farmId,
                    employerReputation = data.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50,
                    lastActionText = data.lastActionText or "",
                    lastReputationChangeText = data.lastReputationChangeText or "",
                    lastPayrollText = data.lastPayrollText or "noch keine Gehaltsabrechnung",
                    lastPayrollAmount = data.lastPayrollAmount or 0,
                    totalPayrollPaid = data.totalPayrollPaid or 0,
                    dismissalPeriod = data.dismissalPeriod,
                    dismissalYear = data.dismissalYear,
                    monthlyDismissals = data.monthlyDismissals or 0,
                    lastApplicantPeriod = data.lastApplicantPeriod,
                    lastApplicantYear = data.lastApplicantYear,
                    lastLoyaltyDailyCheckMinute = data.lastLoyaltyDailyCheckMinute,
                    pendingPayrollLoyaltyDelta = data.pendingPayrollLoyaltyDelta or 0,
                    applicantMarketInitialized = data.applicantMarketInitialized == true,
                    trainingOfferPeriod = data.trainingOfferPeriod,
                    trainingOfferYear = data.trainingOfferYear,
                    trainingOffers = data.trainingOffers or {},
                    reputationHistory = self.copyHistoryForNetwork ~= nil and self:copyHistoryForNetwork(data.reputationHistory) or data.reputationHistory or {},
                    actionHistory = self.copyHistoryForNetwork ~= nil and self:copyHistoryForNetwork(data.actionHistory) or data.actionHistory or {},
                    personChronicles = self.copyPersonChroniclesForNetwork ~= nil and self:copyPersonChroniclesForNetwork(data.personChronicles) or {},
                    workers = {},
                    applicants = {},
                    selectedWorkerId = data.selectedWorkerId,
                    selectedVehicleKey = data.selectedVehicleKey,
                    selectedVehicleName = data.selectedVehicleName,
                    activeAssignments = self:getActiveAssignmentsForFarmData(data)
                }

                for _, worker in ipairs(data.workers or {}) do
                    table.insert(farmState.workers, self.copyPersonForNetwork ~= nil and self:copyPersonForNetwork(worker) or worker)
                end

                for _, applicant in ipairs(data.applicants or {}) do
                    table.insert(farmState.applicants, self.copyPersonForNetwork ~= nil and self:copyPersonForNetwork(applicant) or applicant)
                end

                table.insert(state.farms, farmState)
            end
        end
    elseif HP_V1540_ORIGINAL_MANAGER_GET_NETWORK_STATE ~= nil then
        return HP_V1540_ORIGINAL_MANAGER_GET_NETWORK_STATE(self)
    end

    return state
end

local HP_V1540_ORIGINAL_MANAGER_APPLY_NETWORK_STATE = HelperPersonnelManager.applyNetworkState
local function hpOverride_HelperPersonnelManager_applyNetworkState_1(self, state)
    if HP_V1540_ORIGINAL_MANAGER_APPLY_NETWORK_STATE == nil then
        return false
    end

    local applied = HP_V1540_ORIGINAL_MANAGER_APPLY_NETWORK_STATE(self, state)

    if applied == true and self.config ~= nil and self.config.applyNetworkState ~= nil and type(state) == "table" and type(state.config) == "table" then
        self.config:applyNetworkState(state.config)
    end

    if applied ~= true or type(state) ~= "table" or type(state.farms) ~= "table" then
        return applied
    end

    for _, farmState in ipairs(state.farms) do
        local farmId = tonumber(farmState.farmId)
        local data = self.farms ~= nil and self.farms[farmId] or nil
        if data ~= nil then
            data.selectedWorkerId = farmState.selectedWorkerId
            data.selectedVehicleKey = farmState.selectedVehicleKey
            data.selectedVehicleName = farmState.selectedVehicleName
            self:applyActiveAssignmentsToFarmData(data, farmState.activeAssignments or {})
        end
    end

    if self.refreshFarmContext ~= nil then
        self:refreshFarmContext()
    end

    return true
end
HelperPersonnelManager.applyNetworkState = hpOverride_HelperPersonnelManager_applyNetworkState_1

local HP_V1540_ORIGINAL_MANAGER_START_WORKER_JOB = HelperPersonnelManager.startWorkerJob
function HelperPersonnelManager:startWorkerJobForFarm(workerId, farmId, vehicleName, vehicleKey)
    if self.executeWithFarmContext ~= nil then
        return self:executeWithFarmContext(farmId, function()
            if HP_V1540_ORIGINAL_MANAGER_START_WORKER_JOB ~= nil then
                return HP_V1540_ORIGINAL_MANAGER_START_WORKER_JOB(self, workerId, vehicleName, vehicleKey)
            end
            return false
        end, true)
    end

    return HP_V1540_ORIGINAL_MANAGER_START_WORKER_JOB ~= nil and HP_V1540_ORIGINAL_MANAGER_START_WORKER_JOB(self, workerId, vehicleName, vehicleKey) == true
end

local HP_V1540_ORIGINAL_MANAGER_FINISH_WORKER_JOB = HelperPersonnelManager.finishWorkerJob
function HelperPersonnelManager:finishWorkerJobForFarm(workerId, farmId)
    if self.executeWithFarmContext ~= nil then
        return self:executeWithFarmContext(farmId, function()
            if HP_V1540_ORIGINAL_MANAGER_FINISH_WORKER_JOB ~= nil then
                return HP_V1540_ORIGINAL_MANAGER_FINISH_WORKER_JOB(self, workerId)
            end
            return false
        end, true)
    end

    return HP_V1540_ORIGINAL_MANAGER_FINISH_WORKER_JOB ~= nil and HP_V1540_ORIGINAL_MANAGER_FINISH_WORKER_JOB(self, workerId) == true
end

function HelperPersonnelApp:getFarmIdForVehicle(vehicle, fallbackFarmId)
    if vehicle ~= nil and vehicle.getOwnerFarmId ~= nil then
        local ok, farmId = pcall(vehicle.getOwnerFarmId, vehicle)
        if ok and farmId ~= nil then
            return farmId
        end
    end

    if fallbackFarmId ~= nil then
        return fallbackFarmId
    end

    if self.manager ~= nil and self.manager.getCurrentFarmId ~= nil then
        return self.manager:getCurrentFarmId()
    end

    return 1
end

local HP_V1540_ORIGINAL_APP_SET_PENDING_WORKER = HelperPersonnelApp.setPendingWorkerForVehicle
local function hpOverride_HelperPersonnelApp_setPendingWorkerForVehicle_1(self, vehicle, workerId)
    if HP_V1540_ORIGINAL_APP_SET_PENDING_WORKER ~= nil then
        HP_V1540_ORIGINAL_APP_SET_PENDING_WORKER(self, vehicle, workerId)
    end

    local farmId = self:getFarmIdForVehicle(vehicle)
    local vehicleKey = self.getVehicleKey ~= nil and self:getVehicleKey(vehicle) or nil
    local vehicleName = self.getVehicleName ~= nil and self:getVehicleName(vehicle) or ""

    if self:isServerAuthority() then
        if self.manager ~= nil and self.manager.setSelectedWorkerForFarm ~= nil then
            if self.manager:setSelectedWorkerForFarm(workerId, farmId, vehicleKey, vehicleName) and self.syncNetworkStateToClients ~= nil then
                self:syncNetworkStateToClients()
            end
        end
    elseif self:isMultiplayerClient() and g_client ~= nil and HelperPersonnelNetworkSelectedWorkerEvent ~= nil then
        local connection = g_client.getServerConnection ~= nil and g_client:getServerConnection() or nil
        if connection ~= nil and connection.sendEvent ~= nil then
            connection:sendEvent(HelperPersonnelNetworkSelectedWorkerEvent.new(workerId, farmId, vehicleKey, vehicleName))
        end
    end
end
HelperPersonnelApp.setPendingWorkerForVehicle = hpOverride_HelperPersonnelApp_setPendingWorkerForVehicle_1

local function hpLayer_HelperPersonnelApp_processNetworkSelection_1(self, workerId, farmId, vehicleKey, vehicleName, connection)
    if not self:isServerAuthority() or self.manager == nil or self.manager.setSelectedWorkerForFarm == nil then
        return false
    end

    local changed = self.manager:setSelectedWorkerForFarm(workerId, farmId, vehicleKey, vehicleName) == true
    if changed then
        self:syncNetworkStateToClients()
    elseif connection ~= nil then
        self:sendNetworkStateToConnection(connection)
    end

    return changed
end

local HP_V1540_ORIGINAL_APP_APPLY_NETWORK_STATE = HelperPersonnelApp.applyNetworkState
local function hpLayer_HelperPersonnelApp_applyNetworkState_1(self, state)
    local applied = HP_V1540_ORIGINAL_APP_APPLY_NETWORK_STATE ~= nil and HP_V1540_ORIGINAL_APP_APPLY_NETWORK_STATE(self, state) or false

    if applied == true and self.helperBridge ~= nil and self.helperBridge.syncNetworkAssignmentsFromManager ~= nil then
        self.helperBridge:syncNetworkAssignmentsFromManager()
    end

    return applied
end

local function hpLayer_HelperPersonnelHelperBridge_syncNetworkAssignmentsFromManager_1(self)
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}

    if self.app == nil or self.app.manager == nil or self.app.manager.getActiveAssignmentsForFarmData == nil then
        return false
    end

    local manager = self.app.manager
    if manager.farms == nil then
        return false
    end

    for _, data in pairs(manager.farms) do
        for _, assignment in ipairs(data.activeAssignments or manager:getActiveAssignmentsForFarmData(data)) do
            if assignment.vehicleKey ~= nil and assignment.workerId ~= nil then
                self.vehicleWorkerIds[assignment.vehicleKey] = assignment.workerId
            end
        end
    end

    return true
end

function HelperPersonnelHelperBridge:getFarmIdForWorkerOrVehicle(workerId, vehicle)
    if self.app ~= nil and self.app.manager ~= nil and self.app.manager.getWorkerFarmId ~= nil then
        local farmId = self.app.manager:getWorkerFarmId(workerId)
        if farmId ~= nil then
            return farmId
        end
    end

    if self.app ~= nil and self.app.getFarmIdForVehicle ~= nil then
        return self.app:getFarmIdForVehicle(vehicle)
    end

    return 1
end

local function hpOverride_HelperPersonnelHelperBridge_onJobStarted_1(self, job, workerId)
    if job == nil or workerId == nil then
        return
    end

    self.jobWorkerIds = self.jobWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}

    self.jobWorkerIds[job] = workerId
    self.workerJobById[workerId] = job
    job.helperPersonnelWorkerId = workerId

    local vehicle = self:getVehicleFromJob(job)
    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = workerId
    end

    vehicle = self.app ~= nil and self.app.getRootVehicle ~= nil and self.app:getRootVehicle(vehicle) or vehicle
    local vehicleName = self.app ~= nil and self.app.getVehicleName ~= nil and self.app:getVehicleName(vehicle) or ""
    local farmId = self:getFarmIdForWorkerOrVehicle(workerId, vehicle)

    if not self:hpIsServerAuthority() then
        return
    end

    local changed = false
    if self.app ~= nil and self.app.manager ~= nil then
        if self.app.manager.setSelectedWorkerForFarm ~= nil then
            self.app.manager:setSelectedWorkerForFarm(workerId, farmId, vehicleKey, vehicleName)
        end

        if self.app.manager.startWorkerJobForFarm ~= nil then
            changed = self.app.manager:startWorkerJobForFarm(workerId, farmId, vehicleName, vehicleKey) == true
        elseif self.app.manager.startWorkerJob ~= nil then
            changed = self.app.manager:startWorkerJob(workerId, vehicleName, vehicleKey) == true
        elseif self.app.manager.setWorkerBusy ~= nil then
            self.app.manager:setWorkerBusy(workerId, true, vehicleName, vehicleKey)
            changed = true
        end
    end

    self:hpSyncStateAfterJobChange(changed)
end
HelperPersonnelHelperBridge.onJobStarted = hpOverride_HelperPersonnelHelperBridge_onJobStarted_1

local function hpLayer_HelperPersonnelHelperBridge_onJobStopped_1(self, job)
    if job == nil then
        return
    end

    self.jobWorkerIds = self.jobWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}

    local workerId = self:getWorkerIdByJob(job)
    local changed = false
    local farmId = nil

    if workerId ~= nil then
        farmId = self:getFarmIdForWorkerOrVehicle(workerId, self:getVehicleFromJob(job))
        local assignedJob = self.workerJobById[workerId]
        if assignedJob == nil or assignedJob == job then
            self.workerJobById[workerId] = nil
            if self:hpIsServerAuthority() and self.app ~= nil and self.app.manager ~= nil then
                if self.app.manager.finishWorkerJobForFarm ~= nil then
                    changed = self.app.manager:finishWorkerJobForFarm(workerId, farmId) == true
                elseif self.app.manager.finishWorkerJob ~= nil then
                    changed = self.app.manager:finishWorkerJob(workerId) == true
                elseif self.app.manager.setWorkerBusy ~= nil then
                    self.app.manager:setWorkerBusy(workerId, false, "")
                    changed = true
                end
            end
        end
    end

    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = nil
    end

    self.jobWorkerIds[job] = nil
    job.helperPersonnelWorkerId = nil

    self:hpSyncStateAfterJobChange(changed)
end

local function hpV1550NormalizeFarmId(farmId)
    farmId = tonumber(farmId)
    if farmId == nil or farmId <= 0 then
        return nil
    end

    farmId = math.floor(farmId + 0.5)
    if FarmManager ~= nil and FarmManager.SPECTATOR_FARM_ID ~= nil and farmId == FarmManager.SPECTATOR_FARM_ID then
        return nil
    end

    return farmId
end

local function hpV1550SafeCall(object, methodName, ...)
    if object == nil or methodName == nil or object[methodName] == nil then
        return nil
    end

    local ok, result = pcall(object[methodName], object, ...)
    if ok then
        return result
    end

    return nil
end

local function hpV1550Warn(message, ...)
    if Logging ~= nil and Logging.warning ~= nil then
        Logging.warning("FS25_HelperPersonnel: " .. tostring(message), ...)
    elseif print ~= nil then
        print(string.format("FS25_HelperPersonnel: " .. tostring(message), ...))
    end
end

function HelperPersonnelManager:getFarmDataIfExists(farmId)
    farmId = hpV1550NormalizeFarmId(farmId)
    if farmId == nil then
        return nil
    end

    if self.storeCurrentFarmData ~= nil then
        self:storeCurrentFarmData()
    end

    return self.farms ~= nil and self.farms[farmId] or nil
end

function HelperPersonnelManager:getApplicantFromFarmData(data, applicantId)
    applicantId = tonumber(applicantId)
    if data == nil or applicantId == nil then
        return nil
    end

    for _, applicant in ipairs(data.applicants or {}) do
        if tonumber(applicant.id) == applicantId then
            return applicant
        end
    end

    return nil
end

function HelperPersonnelManager:hasApplicantInFarm(applicantId, farmId)
    local data = self:getFarmDataIfExists(farmId)
    return self:getApplicantFromFarmData(data, applicantId) ~= nil
end

function HelperPersonnelManager:hasWorkerInFarm(workerId, farmId)
    local data = self:getFarmDataIfExists(farmId)
    return self:getWorkerFromFarmData(data, workerId) ~= nil
end

function HelperPersonnelManager:canSelectWorkerForFarm(workerId, farmId)
    workerId = tonumber(workerId)
    if workerId == nil or workerId <= 0 then
        return true
    end

    local data = self:getFarmDataIfExists(farmId)
    local worker = self:getWorkerFromFarmData(data, workerId)
    if worker == nil then
        return false
    end

    if worker.busy == true or worker.restorePending == true then
        return false
    end

    return true
end



function HelperPersonnelApp:findVehicleByKey(vehicleKey)
    if vehicleKey == nil or vehicleKey == "" or g_currentMission == nil or self.getVehicleKey == nil then
        return nil
    end

    local checked = {}
    local vehicleLists = {}
    table.insert(vehicleLists, g_currentMission.vehicles)

    if g_currentMission.vehicleSystem ~= nil then
        table.insert(vehicleLists, g_currentMission.vehicleSystem.vehicles)
    end

    for _, vehicleList in ipairs(vehicleLists) do
        if vehicleList ~= nil then
            for _, vehicle in pairs(vehicleList) do
                if vehicle ~= nil and checked[vehicle] ~= true then
                    checked[vehicle] = true
                    local ok, key = pcall(function()
                        return self:getVehicleKey(vehicle)
                    end)
                    if ok and key == vehicleKey then
                        return vehicle
                    end
                end
            end
        end
    end

    return nil
end

function HelperPersonnelApp:getFarmIdForVehicleKey(vehicleKey)
    local vehicle = self:findVehicleByKey(vehicleKey)
    if vehicle == nil then
        return nil, nil
    end

    return self:getStrictFarmIdForVehicle(vehicle), vehicle
end

function HelperPersonnelApp:getFarmById(farmId)
    farmId = tonumber(farmId)
    local farmManager = g_farmManager or (g_currentMission ~= nil and g_currentMission.farmManager or nil)
    if farmId == nil or farmManager == nil or farmManager.getFarmById == nil then
        return nil
    end

    return farmManager:getFarmById(farmId)
end

function HelperPersonnelApp:getConnectionUserId(connection)
    local userManager = g_currentMission ~= nil and g_currentMission.userManager or nil
    if connection == nil or userManager == nil or userManager.getUserIdByConnection == nil then
        return nil
    end

    return userManager:getUserIdByConnection(connection)
end

function HelperPersonnelApp:farmHasManagerEntry(farm, userId)
    if farm == nil or userId == nil or farm.isUserFarmManager == nil then
        return nil
    end

    return farm:isUserFarmManager(userId) == true
end

function HelperPersonnelApp:isConnectionFarmManager(connection, farmId)
    if not self:isMultiplayerGame() then
        return true
    end

    if connection == nil then
        return self:isLocalPlayerFarmManager(farmId)
    end

    local connectionFarmId = self.getFarmIdFromConnection ~= nil and self:getFarmIdFromConnection(connection) or nil
    if connectionFarmId == nil or tonumber(connectionFarmId) ~= tonumber(farmId) then
        return false
    end

    local farm = self:getFarmById(farmId)
    local userId = self:getConnectionUserId(connection)
    if farm == nil or userId == nil then
        return false
    end

    return self:farmHasManagerEntry(farm, userId) == true
end

function HelperPersonnelApp:resolveAuthorizedFarmId(connection, requestedFarmId, vehicleFarmId, actionText)
    local requestFarmId = hpV1550NormalizeFarmId(requestedFarmId)
    local strictVehicleFarmId = hpV1550NormalizeFarmId(vehicleFarmId)

    if connection == nil then
        local authorizedFarmId = strictVehicleFarmId or requestFarmId or (self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1)
        if self.isConnectionFarmManager ~= nil and not self:isConnectionFarmManager(nil, authorizedFarmId) then
            hpV1550Warn("Network request '%s' rejected: no farm manager permission for farm %s.", tostring(actionText or "?"), tostring(authorizedFarmId))
            return false, authorizedFarmId, nil
        end

        return true, authorizedFarmId, nil
    end

    local connectionFarmId = self:getFarmIdFromConnection(connection)
    if connectionFarmId == nil then
        hpV1550Warn("Network request '%s' rejected: connection farm could not be resolved.", tostring(actionText or "?"))
        return false, nil, nil
    end

    if strictVehicleFarmId ~= nil and strictVehicleFarmId ~= connectionFarmId then
        hpV1550Warn("Network request '%s' rejected: vehicle belongs to farm %s, connection belongs to farm %s.", tostring(actionText or "?"), tostring(strictVehicleFarmId), tostring(connectionFarmId))
        return false, connectionFarmId, connectionFarmId
    end

    if requestFarmId ~= nil and requestFarmId ~= connectionFarmId then
        hpV1550Warn("Network request '%s' rejected: requested farm %s, connection belongs to farm %s.", tostring(actionText or "?"), tostring(requestFarmId), tostring(connectionFarmId))
        return false, connectionFarmId, connectionFarmId
    end

    if self.isConnectionFarmManager == nil or not self:isConnectionFarmManager(connection, connectionFarmId) then
        hpV1550Warn("Network request '%s' rejected: no farm manager permission for farm %s.", tostring(actionText or "?"), tostring(connectionFarmId))
        return false, connectionFarmId, connectionFarmId
    end

    return true, connectionFarmId, connectionFarmId
end

function HelperPersonnelApp:validateNetworkActionTarget(actionName, targetId, farmId)
    if self.manager == nil then
        return false
    end

    if actionName == HelperPersonnelNetwork.ACTION_HIRE then
        return self.manager.hasApplicantInFarm ~= nil and self.manager:hasApplicantInFarm(targetId, farmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_DISMISS then
        return self.manager.hasWorkerInFarm ~= nil and self.manager:hasWorkerInFarm(targetId, farmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_SET_TRANSPORT_PRIORITY then
        return true
    elseif actionName == HelperPersonnelNetwork.ACTION_GRANT_SALARY_RAISE or actionName == HelperPersonnelNetwork.ACTION_DECLINE_SALARY_RAISE then
        return self.manager.hasWorkerInFarm ~= nil and self.manager:hasWorkerInFarm(targetId, farmId) == true
    end

    return false
end

local HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_ACTION = HelperPersonnelApp.processNetworkAction
local function hpLayer_HelperPersonnelApp_processNetworkAction_1(self, actionName, targetId, connection, farmId, actionData)
    if not self:isServerAuthority() or self.manager == nil then
        return false
    end

    local allowed, authorizedFarmId = self:resolveAuthorizedFarmId(connection, farmId, nil, actionName)
    if not allowed then
        if connection ~= nil then
            self:sendNetworkStateToConnection(connection)
        end
        return false
    end

    if not self:validateNetworkActionTarget(actionName, targetId, authorizedFarmId) then
        hpV1550Warn("Network request '%s' rejected: target %s does not belong to farm %s.", tostring(actionName), tostring(targetId), tostring(authorizedFarmId))
        if connection ~= nil then
            self:sendNetworkStateToConnection(connection)
        end
        return false
    end

    local changed = false
    if actionName == HelperPersonnelNetwork.ACTION_HIRE and self.manager.hireApplicantForFarm ~= nil then
        changed = self.manager:hireApplicantForFarm(targetId, authorizedFarmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_DISMISS and self.manager.dismissWorkerForFarm ~= nil then
        changed = self.manager:dismissWorkerForFarm(targetId, authorizedFarmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_SET_TRANSPORT_PRIORITY and self.decodeTransportPriorityOrder ~= nil and self.manager.setTransportPriorityOrderForFarm ~= nil then
        local workerIds = self:decodeTransportPriorityOrder(actionData)
        changed = workerIds ~= nil and self.manager:setTransportPriorityOrderForFarm(workerIds, authorizedFarmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_GRANT_SALARY_RAISE and self.manager.grantSalaryRaiseForFarm ~= nil then
        changed = self.manager:grantSalaryRaiseForFarm(targetId, authorizedFarmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_DECLINE_SALARY_RAISE and self.manager.declineSalaryRaiseForFarm ~= nil then
        changed = self.manager:declineSalaryRaiseForFarm(targetId, authorizedFarmId) == true
    elseif HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_ACTION ~= nil then
        changed = HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, authorizedFarmId, actionData) == true
    end

    if changed then
        self:syncNetworkStateToClients()
    elseif connection ~= nil then
        self:sendNetworkStateToConnection(connection)
    end

    return changed
end

local HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_SELECTION = hpLayer_HelperPersonnelApp_processNetworkSelection_1
function HelperPersonnelApp:processNetworkSelection(workerId, farmId, vehicleKey, vehicleName, connection)
    if not self:isServerAuthority() or self.manager == nil then
        return false
    end

    workerId = tonumber(workerId) or 0
    local vehicleFarmId = nil
    if vehicleKey ~= nil and vehicleKey ~= "" and self.getFarmIdForVehicleKey ~= nil then
        vehicleFarmId = self:getFarmIdForVehicleKey(vehicleKey)
    end

    local allowed, authorizedFarmId = self:resolveAuthorizedFarmId(connection, farmId, vehicleFarmId, HelperPersonnelNetwork.ACTION_SELECT_WORKER)
    if not allowed then
        if connection ~= nil then
            self:sendNetworkStateToConnection(connection)
        end
        return false
    end

    if workerId > 0 then
        local workerFarmId = self.manager.getWorkerFarmId ~= nil and hpV1550NormalizeFarmId(self.manager:getWorkerFarmId(workerId)) or nil
        if workerFarmId == nil or workerFarmId ~= authorizedFarmId then
            hpV1550Warn("Worker selection rejected: worker %s does not belong to farm %s.", tostring(workerId), tostring(authorizedFarmId))
            if connection ~= nil then
                self:sendNetworkStateToConnection(connection)
            end
            return false
        end

        if self.manager.canSelectWorkerForFarm ~= nil and not self.manager:canSelectWorkerForFarm(workerId, authorizedFarmId) then
            hpV1550Warn("Worker selection rejected: worker %s is not available for farm %s.", tostring(workerId), tostring(authorizedFarmId))
            if connection ~= nil then
                self:sendNetworkStateToConnection(connection)
            end
            return false
        end
    end

    local changed = false
    if self.manager.setSelectedWorkerForFarm ~= nil then
        changed = self.manager:setSelectedWorkerForFarm(workerId, authorizedFarmId, vehicleKey, vehicleName) == true
    elseif HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_SELECTION ~= nil then
        changed = HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_SELECTION(self, workerId, authorizedFarmId, vehicleKey, vehicleName, connection) == true
    end

    if changed then
        self:syncNetworkStateToClients()
    elseif connection ~= nil then
        self:sendNetworkStateToConnection(connection)
    end

    return changed
end

local HP_V1550_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB = HelperPersonnelHelperBridge.canUseWorkerForJob
local function hpOverride_HelperPersonnelHelperBridge_canUseWorkerForJob_1(self, workerId, job)
    if HP_V1550_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB ~= nil and HP_V1550_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB(self, workerId, job) ~= true then
        return false
    end

    if self.app == nil or self.app.manager == nil then
        return false
    end

    local workerFarmId = self.app.manager.getWorkerFarmId ~= nil and hpV1550NormalizeFarmId(self.app.manager:getWorkerFarmId(workerId)) or nil
    local vehicle = self.getVehicleFromJob ~= nil and self:getVehicleFromJob(job) or nil
    local vehicleFarmId = self.app.getStrictFarmIdForVehicle ~= nil and hpV1550NormalizeFarmId(self.app:getStrictFarmIdForVehicle(vehicle)) or nil

    if workerFarmId ~= nil and vehicleFarmId ~= nil and workerFarmId ~= vehicleFarmId then
        hpV1550Warn("AI job with worker %s rejected: vehicle belongs to farm %s, worker belongs to farm %s.", tostring(workerId), tostring(vehicleFarmId), tostring(workerFarmId))
        return false
    end

    return true
end
HelperPersonnelHelperBridge.canUseWorkerForJob = hpOverride_HelperPersonnelHelperBridge_canUseWorkerForJob_1

local HP_V1550_ORIGINAL_SEND_SELECTED_AI_JOB = HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.sendSelectedAIJob or nil
if HelperPersonnelAIStartHooks ~= nil and HP_V1550_ORIGINAL_SEND_SELECTED_AI_JOB ~= nil then
    local function hpOverride_HelperPersonnelAIStartHooks_sendSelectedAIJob_1(vehicle, workerId, fallbackJob, fallbackFarmId)
        local app = g_helperPersonnelApp
        if app ~= nil and app.manager ~= nil then
            local workerFarmId = app.manager.getWorkerFarmId ~= nil and hpV1550NormalizeFarmId(app.manager:getWorkerFarmId(workerId)) or nil
            local vehicleFarmId = app.getStrictFarmIdForVehicle ~= nil and hpV1550NormalizeFarmId(app:getStrictFarmIdForVehicle(vehicle)) or hpV1550NormalizeFarmId(fallbackFarmId)

            if workerFarmId ~= nil and vehicleFarmId ~= nil and workerFarmId ~= vehicleFarmId then
                if app.showPlayerMessage ~= nil then
                    app:showPlayerMessage("ui_selectionWorkerUnavailable")
                end
                hpV1550Warn("Local worker selection rejected: vehicle belongs to farm %s, worker belongs to farm %s.", tostring(vehicleFarmId), tostring(workerFarmId))
                return false
            end
        end

        return HP_V1550_ORIGINAL_SEND_SELECTED_AI_JOB(vehicle, workerId, fallbackJob, fallbackFarmId)
    end
    HelperPersonnelAIStartHooks.sendSelectedAIJob = hpOverride_HelperPersonnelAIStartHooks_sendSelectedAIJob_1
end

function HelperPersonnelApp:getStrictFarmIdForVehicle(vehicle)
    if vehicle == nil then
        return nil
    end

    local candidates = {vehicle}
    if self.getRootVehicle ~= nil then
        local rootVehicle = self:getRootVehicle(vehicle)
        if rootVehicle ~= nil and rootVehicle ~= vehicle then
            table.insert(candidates, rootVehicle)
        end
    end

    for _, candidate in ipairs(candidates) do
        if candidate.getOwnerFarmId ~= nil then
            local farmId = hpV1550NormalizeFarmId(hpV1550SafeCall(candidate, "getOwnerFarmId"))
            if farmId ~= nil then
                return farmId
            end
        end

        local farmId = hpV1550NormalizeFarmId(candidate.ownerFarmId)
        if farmId ~= nil then
            return farmId
        end
    end

    return nil
end

function HelperPersonnelApp:getFarmIdFromConnection(connection)
    if connection == nil or self.getConnectionUserId == nil then
        return nil
    end

    local userId = self:getConnectionUserId(connection)
    local farmManager = g_farmManager or (g_currentMission ~= nil and g_currentMission.farmManager or nil)
    if userId == nil or farmManager == nil or farmManager.getFarmByUserId == nil then
        return nil
    end

    local farm = farmManager:getFarmByUserId(userId)
    return farm ~= nil and hpV1550NormalizeFarmId(farm.farmId) or nil
end

local HP_V1560_CLIENT_REQUEST_INTERVAL_MS = 1000
local HP_V1561_CLIENT_INITIAL_DELAY_MS = 2000
local HP_V1560_CLIENT_REQUEST_MAX_ATTEMPTS = 90
local HP_V1560_SERVER_SCAN_INTERVAL_MS = 2000
local HP_V1560_SERVER_EARLY_BROADCAST_INTERVAL_MS = 3000
local HP_V1560_SERVER_EARLY_BROADCAST_MAX = 8

local function hpV1560SafeCall(object, methodName, ...)
    if object == nil then
        return nil
    end

    local method = object[methodName]
    if type(method) ~= "function" then
        return nil
    end

    local ok, result = pcall(method, object, ...)
    if ok then
        return result
    end

    return nil
end

local function hpV1560IsClientConnection(connection)
    if type(connection) ~= "table" or type(connection.sendEvent) ~= "function" then
        return false
    end

    if type(connection.getIsServer) == "function" then
        local ok, isServer = pcall(connection.getIsServer, connection)
        if ok and isServer == true then
            return false
        end
    end

    return true
end

local HP_V1560_ORIGINAL_APP_LOAD = HelperPersonnelApp.load
local function hpOverride_HelperPersonnelApp_load_1(self)

    self.hpJoinSyncApplied = false
    self.hpJoinSyncRequestTimer = 0
    self.hpJoinSyncRequestAttempts = 0
    self.hpJoinSyncInitialDelay = HP_V1561_CLIENT_INITIAL_DELAY_MS
    self.hpJoinSyncRequestsEnabled = false
    self.hpServerConnectionScanTimer = 0
    self.hpServerEarlyBroadcastTimer = 0
    self.hpServerEarlyBroadcastCount = 0

    HP_V1560_ORIGINAL_APP_LOAD(self)

    if self:isServerAuthority() then
        self.hpKnownSyncConnections = self.hpKnownSyncConnections or setmetatable({}, {__mode = "k"})
    elseif self:isMultiplayerClient() then

        self.hpJoinSyncRequestsEnabled = true
    end
end
HelperPersonnelApp.load = hpOverride_HelperPersonnelApp_load_1
local HP_V1560_ORIGINAL_APP_REQUEST_NETWORK_STATE = HelperPersonnelApp.requestNetworkState
local function hpOverride_HelperPersonnelApp_requestNetworkState_1(self)
    if not self:isMultiplayerClient() or g_client == nil or HelperPersonnelNetworkRequestStateEvent == nil then
        return false
    end

    if self.hpJoinSyncRequestsEnabled ~= true then
        return false
    end

    local sent = false

    if HP_V1560_ORIGINAL_APP_REQUEST_NETWORK_STATE ~= nil then
        sent = HP_V1560_ORIGINAL_APP_REQUEST_NETWORK_STATE(self) == true
    end

    if sent then
        return true
    end

    local candidates = {}
    local function addCandidate(connection)
        if connection ~= nil then
            table.insert(candidates, connection)
        end
    end

    addCandidate(g_client.serverConnection)
    addCandidate(g_client.connection)
    addCandidate(hpV1560SafeCall(g_client, "getServerConnection"))

    for _, connection in ipairs(candidates) do
        if connection ~= nil and type(connection.sendEvent) == "function" then
            local ok = pcall(function()
                connection:sendEvent(HelperPersonnelNetworkRequestStateEvent.new())
            end)

            if ok then
                return true
            end
        end
    end

    return false
end
HelperPersonnelApp.requestNetworkState = hpOverride_HelperPersonnelApp_requestNetworkState_1
function HelperPersonnelApp:hp1560CollectServerConnections()
    local result = {}
    local seen = {}

    local function addConnection(connection)
        if connection ~= nil and seen[connection] ~= true and hpV1560IsClientConnection(connection) then
            seen[connection] = true
            table.insert(result, connection)
        end
    end

    local function scanContainer(container)
        if type(container) ~= "table" then
            return
        end

        if hpV1560IsClientConnection(container) then
            addConnection(container)
            return
        end

        for _, value in pairs(container) do
            if hpV1560IsClientConnection(value) then
                addConnection(value)
            end
        end
    end

    if g_server ~= nil then
        scanContainer(g_server.connections)
        scanContainer(g_server.clients)
        scanContainer(g_server.clientConnections)
        scanContainer(g_server.connectionsByUniqueId)
        scanContainer(g_server.connectionsByUserId)
        scanContainer(g_server.connectionList)
    end

    return result
end

function HelperPersonnelApp:hp1560UpdateClientJoinSync(dt)
    if not self:isMultiplayerClient() or self.hpJoinSyncApplied == true then
        return
    end

    if self.hpJoinSyncRequestsEnabled ~= true then
        return
    end

    if (self.hpJoinSyncInitialDelay or 0) > 0 then
        self.hpJoinSyncInitialDelay = math.max(0, (self.hpJoinSyncInitialDelay or 0) - (dt or 0))
        return
    end

    self.hpJoinSyncRequestTimer = (self.hpJoinSyncRequestTimer or 0) + (dt or 0)
    if self.hpJoinSyncRequestTimer < HP_V1560_CLIENT_REQUEST_INTERVAL_MS then
        return
    end

    self.hpJoinSyncRequestTimer = 0
    if (self.hpJoinSyncRequestAttempts or 0) >= HP_V1560_CLIENT_REQUEST_MAX_ATTEMPTS then
        return
    end

    if self:requestNetworkState() then
        self.hpJoinSyncRequestAttempts = (self.hpJoinSyncRequestAttempts or 0) + 1
    end
end
function HelperPersonnelApp:hp1560UpdateServerJoinSync(dt)
    if not self:isServerAuthority() or g_server == nil then
        return
    end

    self.hpKnownSyncConnections = self.hpKnownSyncConnections or setmetatable({}, {__mode = "k"})

    self.hpServerEarlyBroadcastTimer = (self.hpServerEarlyBroadcastTimer or 0) + (dt or 0)
    if (self.hpServerEarlyBroadcastCount or 0) < HP_V1560_SERVER_EARLY_BROADCAST_MAX
        and self.hpServerEarlyBroadcastTimer >= HP_V1560_SERVER_EARLY_BROADCAST_INTERVAL_MS then
        self.hpServerEarlyBroadcastTimer = 0
        self.hpServerEarlyBroadcastCount = (self.hpServerEarlyBroadcastCount or 0) + 1
        self:syncNetworkStateToClients()
    end

    self.hpServerConnectionScanTimer = (self.hpServerConnectionScanTimer or 0) + (dt or 0)
    if self.hpServerConnectionScanTimer < HP_V1560_SERVER_SCAN_INTERVAL_MS then
        return
    end

    self.hpServerConnectionScanTimer = 0
    for _, connection in ipairs(self:hp1560CollectServerConnections()) do
        if self.hpKnownSyncConnections[connection] ~= true then
            if self:sendNetworkStateToConnection(connection) then
                self.hpKnownSyncConnections[connection] = true
            end
        end
    end
end

local HP_V1560_ORIGINAL_APP_APPLY_NETWORK_STATE = hpLayer_HelperPersonnelApp_applyNetworkState_1
local function hpLayer_HelperPersonnelApp_applyNetworkState_2(self, state)
    local applied = false

    if HP_V1560_ORIGINAL_APP_APPLY_NETWORK_STATE ~= nil then
        applied = HP_V1560_ORIGINAL_APP_APPLY_NETWORK_STATE(self, state) == true
    end

    if applied and self:isMultiplayerClient() then
        self.hpJoinSyncApplied = true
        self.hpJoinSyncRequestTimer = 0
        self.hpJoinSyncRequestAttempts = 0
    end

    return applied
end

local HP_V1561_ORIGINAL_AIJOB_CAN_USE_WORKER_FOR_JOB = HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.canUseWorkerForJob or nil
if HelperPersonnelAIJobHooks ~= nil and HP_V1561_ORIGINAL_AIJOB_CAN_USE_WORKER_FOR_JOB ~= nil then
    local function hpOverride_HelperPersonnelAIJobHooks_canUseWorkerForJob_1(workerId, job)
        local app = g_helperPersonnelApp
        if app ~= nil and app.isMultiplayerClient ~= nil and app:isMultiplayerClient() then
            if app.hpJoinSyncApplied ~= true or app.activeJobsRestoreDone ~= true then
                return true
            end
        end

        return HP_V1561_ORIGINAL_AIJOB_CAN_USE_WORKER_FOR_JOB(workerId, job)
    end
    HelperPersonnelAIJobHooks.canUseWorkerForJob = hpOverride_HelperPersonnelAIJobHooks_canUseWorkerForJob_1
end

local HP_V1560_ORIGINAL_APP_UPDATE = HelperPersonnelApp.update
local function hpLayer_HelperPersonnelApp_update_1(self, dt)
    if HP_V1560_ORIGINAL_APP_UPDATE ~= nil then
        HP_V1560_ORIGINAL_APP_UPDATE(self, dt)
    end

    if self.isMissionDeleting == true then
        return
    end

    self:hp1560UpdateClientJoinSync(dt)
    self:hp1560UpdateServerJoinSync(dt)
end

local function hpV1562NormalizeVehicleKey(vehicleKey)
    if vehicleKey == nil then
        return nil
    end

    vehicleKey = tostring(vehicleKey)
    if vehicleKey == "" then
        return nil
    end

    return vehicleKey
end

local function hpV1562GetVehicleKeyFromJob(bridge, job)
    if bridge == nil or job == nil then
        return nil
    end

    if bridge.getVehicleKeyFromJob ~= nil then
        return hpV1562NormalizeVehicleKey(bridge:getVehicleKeyFromJob(job))
    end

    return nil
end

function HelperPersonnelManager:getWorkerByVehicleKeyAnyFarm(vehicleKey)
    vehicleKey = hpV1562NormalizeVehicleKey(vehicleKey)
    if vehicleKey == nil then
        return nil, nil
    end

    if self.storeCurrentFarmData ~= nil then
        self:storeCurrentFarmData()
    end

    local function checkWorker(worker)
        if worker == nil then
            return false
        end

        if worker.busy == true and hpV1562NormalizeVehicleKey(worker.vehicleKey) == vehicleKey then
            return true
        end

        if worker.restorePending == true and hpV1562NormalizeVehicleKey(worker.restoreVehicleKey) == vehicleKey then
            return true
        end

        return false
    end

    for _, worker in ipairs(self.workers or {}) do
        if checkWorker(worker) then
            return worker, self.activeFarmId
        end
    end

    for farmId, data in pairs(self.farms or {}) do
        for _, worker in ipairs(data.workers or {}) do
            if checkWorker(worker) then
                return worker, farmId
            end
        end
    end

    return nil, nil
end

function HelperPersonnelManager:getActiveAssignmentCountFromNetworkState(state)
    local count = 0

    if type(state) == "table" and type(state.farms) == "table" then
        for _, farmState in ipairs(state.farms) do
            if type(farmState.activeAssignments) == "table" then
                count = count + #farmState.activeAssignments
            end
        end
    end

    return count
end

local HP_V1562_ORIGINAL_BRIDGE_GET_WORKER_ID_BY_VEHICLE_KEY = HelperPersonnelHelperBridge.getWorkerIdByVehicleKey
local function hpOverride_HelperPersonnelHelperBridge_getWorkerIdByVehicleKey_1(self, vehicleKey)
    local workerId = nil

    if HP_V1562_ORIGINAL_BRIDGE_GET_WORKER_ID_BY_VEHICLE_KEY ~= nil then
        workerId = HP_V1562_ORIGINAL_BRIDGE_GET_WORKER_ID_BY_VEHICLE_KEY(self, vehicleKey)
        if workerId ~= nil then
            return workerId
        end
    end

    if self.app ~= nil and self.app.manager ~= nil and self.app.manager.getWorkerByVehicleKeyAnyFarm ~= nil then
        local worker = self.app.manager:getWorkerByVehicleKeyAnyFarm(vehicleKey)
        if worker ~= nil then
            return worker.id
        end
    end

    return nil
end
HelperPersonnelHelperBridge.getWorkerIdByVehicleKey = hpOverride_HelperPersonnelHelperBridge_getWorkerIdByVehicleKey_1

local HP_V1562_ORIGINAL_BRIDGE_SYNC_ASSIGNMENTS = hpLayer_HelperPersonnelHelperBridge_syncNetworkAssignmentsFromManager_1
function HelperPersonnelHelperBridge:syncNetworkAssignmentsFromManager()
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.jobWorkerIds = self.jobWorkerIds or {}

    local activeWorkerIds = {}
    local activeVehicleKeys = {}

    if self.app ~= nil and self.app.manager ~= nil then
        local manager = self.app.manager
        if manager.storeCurrentFarmData ~= nil then
            manager:storeCurrentFarmData()
        end

        for _, data in pairs(manager.farms or {}) do
            local assignments = data.activeAssignments
            if assignments == nil and manager.getActiveAssignmentsForFarmData ~= nil then
                assignments = manager:getActiveAssignmentsForFarmData(data)
            end

            for _, assignment in ipairs(assignments or {}) do
                local workerId = tonumber(assignment.workerId)
                local vehicleKey = hpV1562NormalizeVehicleKey(assignment.vehicleKey)
                if workerId ~= nil then
                    activeWorkerIds[workerId] = true
                end
                if workerId ~= nil and vehicleKey ~= nil then
                    self.vehicleWorkerIds[vehicleKey] = workerId
                    activeVehicleKeys[vehicleKey] = true
                end
            end
        end
    end

    if self.app ~= nil and self.app.isMultiplayerClient ~= nil and self.app:isMultiplayerClient() then
        for vehicleKey, _ in pairs(self.vehicleWorkerIds or {}) do
            if activeVehicleKeys[vehicleKey] ~= true then
                self.vehicleWorkerIds[vehicleKey] = nil
            end
        end

        for workerId, job in pairs(self.workerJobById or {}) do
            if activeWorkerIds[workerId] ~= true then
                self.workerJobById[workerId] = nil
                if job ~= nil then
                    self.jobWorkerIds[job] = nil
                    if job.helperPersonnelWorkerId == workerId then
                        job.helperPersonnelWorkerId = nil
                    end
                end
            end
        end
    elseif HP_V1562_ORIGINAL_BRIDGE_SYNC_ASSIGNMENTS ~= nil then

        HP_V1562_ORIGINAL_BRIDGE_SYNC_ASSIGNMENTS(self)
    end

    return true
end

local function hpV1562IsClientJoinRestorePhase(app)
    return app ~= nil
        and app.isMultiplayerClient ~= nil
        and app:isMultiplayerClient()
        and (app.hpJoinSyncApplied ~= true or app.activeJobsRestoreDone ~= true)
end

local function hpV1562TryAttachClientRestoredJob(app, vehicle, job)
    if app == nil or app.helperBridge == nil or job == nil then
        return nil
    end

    local workerId = job.helperPersonnelWorkerId
    if workerId == nil and app.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
        workerId = app.helperBridge:resolveRestoredWorkerIdForJob(job)
    end
    if workerId == nil and app.helperBridge.getWorkerIdByVehicle ~= nil then
        workerId = app.helperBridge:getWorkerIdByVehicle(vehicle)
    end
    if workerId == nil and app.helperBridge.getVehicleKeyFromJob ~= nil and app.helperBridge.getWorkerIdByVehicleKey ~= nil then
        workerId = app.helperBridge:getWorkerIdByVehicleKey(app.helperBridge:getVehicleKeyFromJob(job))
    end

    if workerId ~= nil then
        job.helperPersonnelWorkerId = workerId
        if app.helperBridge.attachRestoredJob ~= nil then
            app.helperBridge:attachRestoredJob(job, workerId)
        elseif HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.applyWorkerToJob ~= nil then
            HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
        end
    end

    return workerId
end

local HP_V1562_ORIGINAL_AI_START_HANDLE_VEHICLE_START = HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.handleVehicleStart or nil
if HelperPersonnelAIStartHooks ~= nil and HP_V1562_ORIGINAL_AI_START_HANDLE_VEHICLE_START ~= nil then
    local function hpOverride_HelperPersonnelAIStartHooks_handleVehicleStart_1(vehicle, superFunc, ...)
        local app = g_helperPersonnelApp

        if hpV1562IsClientJoinRestorePhase(app) and vehicle ~= nil then
            local startableJob = nil
            if vehicle.getStartableAIJob ~= nil then
                local ok, result = pcall(vehicle.getStartableAIJob, vehicle)
                if ok then
                    startableJob = result
                end
            end

            hpV1562TryAttachClientRestoredJob(app, vehicle, startableJob)

            if superFunc ~= nil then
                return superFunc(vehicle, ...)
            end

            return nil
        end

        return HP_V1562_ORIGINAL_AI_START_HANDLE_VEHICLE_START(vehicle, superFunc, ...)
    end
    HelperPersonnelAIStartHooks.handleVehicleStart = hpOverride_HelperPersonnelAIStartHooks_handleVehicleStart_1
end

local HP_V1562_ORIGINAL_BRIDGE_ON_JOB_STOPPED = hpLayer_HelperPersonnelHelperBridge_onJobStopped_1
local function hpLayer_HelperPersonnelHelperBridge_onJobStopped_2(self, job)

    if not self:hpIsServerAuthority()
        and hpV1562IsClientJoinRestorePhase(self.app) then
        local workerId = self:getWorkerIdByJob(job)
        local vehicleKey = hpV1562GetVehicleKeyFromJob(self, job)

        if workerId == nil and vehicleKey ~= nil and self.getWorkerIdByVehicleKey ~= nil then
            workerId = self:getWorkerIdByVehicleKey(vehicleKey)
        end

        if workerId ~= nil then
            self.jobWorkerIds = self.jobWorkerIds or {}
            self.workerJobById = self.workerJobById or {}
            self.vehicleWorkerIds = self.vehicleWorkerIds or {}

            self.jobWorkerIds[job] = workerId
            self.workerJobById[workerId] = job
            if job ~= nil then
                job.helperPersonnelWorkerId = workerId
            end
            if vehicleKey ~= nil then
                self.vehicleWorkerIds[vehicleKey] = workerId
            end

            return
        end
    end

    if HP_V1562_ORIGINAL_BRIDGE_ON_JOB_STOPPED ~= nil then
        return HP_V1562_ORIGINAL_BRIDGE_ON_JOB_STOPPED(self, job)
    end
end

local HP_V1562_ORIGINAL_APP_APPLY_NETWORK_STATE = hpLayer_HelperPersonnelApp_applyNetworkState_2
local function hpLayer_HelperPersonnelApp_applyNetworkState_3(self, state)
    local activeAssignmentCount = 0
    if self.manager ~= nil and self.manager.getActiveAssignmentCountFromNetworkState ~= nil then
        activeAssignmentCount = self.manager:getActiveAssignmentCountFromNetworkState(state)
    end

    local applied = HP_V1562_ORIGINAL_APP_APPLY_NETWORK_STATE ~= nil and HP_V1562_ORIGINAL_APP_APPLY_NETWORK_STATE(self, state) == true

    if applied == true and self:isMultiplayerClient() then
        if self.helperBridge ~= nil and self.helperBridge.syncNetworkAssignmentsFromManager ~= nil then
            self.helperBridge:syncNetworkAssignmentsFromManager()
        end

        if activeAssignmentCount > 0 then
            self.activeJobsRestoreDone = false
            self.activeJobsRestoreAttempts = 0
            if self.restoreActiveAIJobs ~= nil then
                self:restoreActiveAIJobs()
            end
        end
    end

    return applied
end

local function hpV1563NormalizeText(value)
    if value == nil then
        return nil
    end

    value = tostring(value)
    if value == "" then
        return nil
    end

    return string.lower(value)
end

local function hpV1563HasTableEntries(values)
    if type(values) ~= "table" then
        return false
    end

    for _, _ in pairs(values) do
        return true
    end

    return false
end

function HelperPersonnelApp:hp1563BuildActiveJobLookup()
    local lookup = {
        count = 0,
        workerIds = {},
        vehicleKeys = {},
        vehicleNames = {},
        hasIdentifiers = false
    }

    local activeJobs = self.getActiveAIJobs ~= nil and self:getActiveAIJobs() or nil
    if type(activeJobs) ~= "table" then
        return lookup
    end

    for _, job in pairs(activeJobs) do
        if job ~= nil then
            lookup.count = lookup.count + 1

            local workerId = job.helperPersonnelWorkerId
            if workerId == nil and self.helperBridge ~= nil and self.helperBridge.getWorkerIdByJob ~= nil then
                workerId = self.helperBridge:getWorkerIdByJob(job)
            end
            if workerId == nil and self.helperBridge ~= nil and self.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
                workerId = self.helperBridge:resolveRestoredWorkerIdForJob(job)
            end

            workerId = tonumber(workerId)
            if workerId ~= nil then
                lookup.workerIds[workerId] = true
            end

            local vehicleKey = nil
            if self.helperBridge ~= nil and self.helperBridge.getVehicleKeyFromJob ~= nil then
                vehicleKey = hpV1562NormalizeVehicleKey(self.helperBridge:getVehicleKeyFromJob(job))
            end
            if vehicleKey ~= nil then
                lookup.vehicleKeys[vehicleKey] = true
            end

            local vehicle = nil
            if self.helperBridge ~= nil and self.helperBridge.getVehicleFromJob ~= nil then
                vehicle = self.helperBridge:getVehicleFromJob(job)
            end
            if vehicle ~= nil and self.getRootVehicle ~= nil then
                vehicle = self:getRootVehicle(vehicle)
            end

            local vehicleName = nil
            if vehicle ~= nil and self.getVehicleName ~= nil then
                vehicleName = hpV1563NormalizeText(self:getVehicleName(vehicle))
            end
            if vehicleName ~= nil then
                lookup.vehicleNames[vehicleName] = true
            end
        end
    end

    lookup.hasIdentifiers = hpV1563HasTableEntries(lookup.workerIds)
        or hpV1563HasTableEntries(lookup.vehicleKeys)
        or hpV1563HasTableEntries(lookup.vehicleNames)

    return lookup
end

function HelperPersonnelManager:hp1563WorkerHasRealActiveJob(worker, activeLookup)
    if worker == nil then
        return false
    end

    activeLookup = activeLookup or {}
    local workerId = tonumber(worker.id)
    if workerId ~= nil and type(activeLookup.workerIds) == "table" and activeLookup.workerIds[workerId] == true then
        return true
    end

    local vehicleKey = hpV1562NormalizeVehicleKey(worker.vehicleKey or worker.restoreVehicleKey)
    if vehicleKey ~= nil and type(activeLookup.vehicleKeys) == "table" and activeLookup.vehicleKeys[vehicleKey] == true then
        return true
    end

    local vehicleName = hpV1563NormalizeText((worker.vehicleName ~= nil and worker.vehicleName ~= "") and worker.vehicleName or worker.restoreVehicleName)
    if vehicleName ~= nil and type(activeLookup.vehicleNames) == "table" and activeLookup.vehicleNames[vehicleName] == true then
        return true
    end

    return false
end

function HelperPersonnelManager:hp1563ClearWorkerActiveState(worker)
    if worker == nil then
        return false
    end

    local wasActive = worker.busy == true or worker.restorePending == true
        or worker.vehicleKey ~= nil or worker.restoreVehicleKey ~= nil
        or (worker.vehicleName ~= nil and worker.vehicleName ~= "")
        or (worker.restoreVehicleName ~= nil and worker.restoreVehicleName ~= "")

    worker.busy = false
    worker.restorePending = false
    worker.vehicleName = ""
    worker.vehicleKey = nil
    worker.restoreVehicleName = nil
    worker.restoreVehicleKey = nil
    worker.currentJobStartedAt = 0
    worker.currentJobElapsedMs = 0

    return wasActive
end

function HelperPersonnelManager:hp1563FilterAssignments(assignments, activeLookup)
    local filtered = {}
    local changed = false

    for _, assignment in ipairs(assignments or {}) do
        local keep = false
        local workerId = tonumber(assignment.workerId)
        local vehicleKey = hpV1562NormalizeVehicleKey(assignment.vehicleKey)
        local vehicleName = hpV1563NormalizeText(assignment.vehicleName)

        if workerId ~= nil and type(activeLookup.workerIds) == "table" and activeLookup.workerIds[workerId] == true then
            keep = true
        elseif vehicleKey ~= nil and type(activeLookup.vehicleKeys) == "table" and activeLookup.vehicleKeys[vehicleKey] == true then
            keep = true
        elseif vehicleName ~= nil and type(activeLookup.vehicleNames) == "table" and activeLookup.vehicleNames[vehicleName] == true then
            keep = true
        end

        if keep then
            table.insert(filtered, assignment)
        else
            changed = true
        end
    end

    if #filtered ~= #(assignments or {}) then
        changed = true
    end

    return filtered, changed
end

function HelperPersonnelManager:hp1563CleanupStaleActiveAssignments(activeLookup)
    activeLookup = activeLookup or { count = 0, hasIdentifiers = false, workerIds = {}, vehicleKeys = {}, vehicleNames = {} }

    if (activeLookup.count or 0) > 0 and activeLookup.hasIdentifiers ~= true then
        return false
    end

    if self.storeCurrentFarmData ~= nil then
        self:storeCurrentFarmData()
    end

    local changed = false

    local function cleanupFarmData(data)
        if data == nil then
            return
        end

        for _, worker in ipairs(data.workers or {}) do
            local markedActive = worker.busy == true or worker.restorePending == true
            if markedActive and self:hp1563WorkerHasRealActiveJob(worker, activeLookup) ~= true then
                if self:hp1563ClearWorkerActiveState(worker) then
                    changed = true
                end
            end
        end

        if type(data.activeAssignments) == "table" then
            local filtered, assignmentsChanged = self:hp1563FilterAssignments(data.activeAssignments, activeLookup)
            if assignmentsChanged then
                data.activeAssignments = filtered
                changed = true
            end
        end
    end

    if type(self.farms) == "table" then
        for _, data in pairs(self.farms) do
            cleanupFarmData(data)
        end
    else
        cleanupFarmData({ workers = self.workers or {}, activeAssignments = self.activeAssignments or {} })
    end

    if changed then
        self.changeCounter = (self.changeCounter or 0) + 1
        if type(self.notifyDataChanged) == "function" then
            self:notifyDataChanged()
        end
    end

    return changed
end

local HP_V1563_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE = HelperPersonnelApp.finishActiveJobRestore

local HP_V1563_ORIGINAL_MANAGER_GET_OR_CREATE_FARM_DATA = HelperPersonnelManager.getOrCreateFarmData
local function hpOverride_HelperPersonnelManager_getOrCreateFarmData_1(self, farmId, initializeApplicants)
    if self.app ~= nil and self.app.isMultiplayerClient ~= nil and self.app:isMultiplayerClient() then
        initializeApplicants = false
    end

    if HP_V1563_ORIGINAL_MANAGER_GET_OR_CREATE_FARM_DATA ~= nil then
        return HP_V1563_ORIGINAL_MANAGER_GET_OR_CREATE_FARM_DATA(self, farmId, initializeApplicants)
    end

    return nil
end
HelperPersonnelManager.getOrCreateFarmData = hpOverride_HelperPersonnelManager_getOrCreateFarmData_1

function HelperPersonnelManager:hp1563PromoteRestoredWorkersWithActiveJobs(activeLookup)
    activeLookup = activeLookup or {}
    if (activeLookup.count or 0) <= 0 or activeLookup.hasIdentifiers ~= true then
        return false
    end

    if self.storeCurrentFarmData ~= nil then
        self:storeCurrentFarmData()
    end

    local changed = false
    local now = self.getCurrentTimestampMs ~= nil and self:getCurrentTimestampMs() or 0

    local function promoteFarmData(data)
        if data == nil then
            return
        end

        for _, worker in ipairs(data.workers or {}) do
            if worker.restorePending == true and self:hp1563WorkerHasRealActiveJob(worker, activeLookup) == true then
                local elapsedMs = math.max(0, tonumber(worker.currentJobElapsedMs) or 0)
                worker.busy = true
                worker.restorePending = false
                worker.vehicleKey = worker.vehicleKey or worker.restoreVehicleKey
                if worker.vehicleName == nil or worker.vehicleName == "" then
                    worker.vehicleName = worker.restoreVehicleName or ""
                end
                worker.restoreVehicleKey = nil
                worker.restoreVehicleName = nil
                if worker.currentJobStartedAt == nil or worker.currentJobStartedAt <= 0 then
                    worker.currentJobStartedAt = now - elapsedMs
                    worker.currentJobElapsedMs = 0
                end
                worker.reliabilityJobAbortChecked = true
                worker.reliabilityJobAbortCheckAt = 0
                changed = true
            end
        end
    end

    if type(self.farms) == "table" then
        for _, data in pairs(self.farms) do
            promoteFarmData(data)
        end
    else
        promoteFarmData({ workers = self.workers or {} })
    end

    if changed then
        self.changeCounter = (self.changeCounter or 0) + 1
    end

    return changed
end

local HP_V1563_FINAL_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE = HP_V1563_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE
local function hpOverride_HelperPersonnelApp_finishActiveJobRestore_1(self)
    local lookup = nil
    local promoted = false

    if self:isServerAuthority() and self.manager ~= nil and self.hp1563BuildActiveJobLookup ~= nil then
        lookup = self:hp1563BuildActiveJobLookup()
        if self.manager.hp1563PromoteRestoredWorkersWithActiveJobs ~= nil then
            promoted = self.manager:hp1563PromoteRestoredWorkersWithActiveJobs(lookup) == true
        end
    end

    if HP_V1563_FINAL_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE ~= nil then
        HP_V1563_FINAL_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE(self)
    end

    if self:isServerAuthority() and self.manager ~= nil and self.manager.hp1563CleanupStaleActiveAssignments ~= nil then
        lookup = lookup or (self.hp1563BuildActiveJobLookup ~= nil and self:hp1563BuildActiveJobLookup() or nil)
        local cleaned = self.manager:hp1563CleanupStaleActiveAssignments(lookup) == true
        if (promoted or cleaned) and self.syncNetworkStateToClients ~= nil then
            self:syncNetworkStateToClients()
        end
    end
end
HelperPersonnelApp.finishActiveJobRestore = hpOverride_HelperPersonnelApp_finishActiveJobRestore_1

local function hpV1564GetJobActiveState(app, job)
    if app == nil or job == nil or app.getActiveAIJobs == nil then
        return false, false
    end

    local activeJobs = app:getActiveAIJobs()
    if type(activeJobs) ~= "table" then
        return false, false
    end

    for key, value in pairs(activeJobs) do
        if value == job or key == job then
            return true, true
        end
    end

    return true, false
end

local function hpV1564ShouldFinalizeStartedJob(app, job)
    local known, active = hpV1564GetJobActiveState(app, job)
    if known then
        return active == true
    end

    return true
end

local function hpV1564ClearPendingStart(app, job)
    if app == nil then
        return
    end

    if app.consumePendingWorkerForVehicle ~= nil and HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob ~= nil then
        app:consumePendingWorkerForVehicle(HelperPersonnelAIJobHooks.getVehicleFromJob(job))
    end
end

local function hpOverride_HelperPersonnelAIJobHooks_onAIJobStart_1(job, superFunc, farmId, ...)
    local args = {...}
    local app = g_helperPersonnelApp
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
    local result = nil
    local insideAISystemStart = (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 0) > 0

    if workerId ~= nil and not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
        HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
        return false
    end

    if workerId ~= nil then
        result = HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, function()
            return superFunc(job, farmId, unpack(args))
        end)
    else
        result = superFunc(job, farmId, unpack(args))
    end

    if result ~= false and app ~= nil and app.helperBridge ~= nil and job ~= nil and not insideAISystemStart then
        if workerId == nil then
            workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
        end

        if workerId ~= nil and hpV1564ShouldFinalizeStartedJob(app, job) then
            HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
        elseif workerId ~= nil then
            hpV1564ClearPendingStart(app, job)
        end
    end

    return result
end
HelperPersonnelAIJobHooks.onAIJobStart = hpOverride_HelperPersonnelAIJobHooks_onAIJobStart_1

local function hpOverride_HelperPersonnelAIJobHooks_onAISystemStartJob_1(aiSystem, superFunc, job, farmId, ...)
    local args = {...}
    local app = g_helperPersonnelApp
    local workerId = HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
    local result = nil

    if workerId ~= nil then
        if not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
            HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
            return false
        end

        HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth = (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 0) + 1
        result = HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, function()
            return superFunc(aiSystem, job, farmId, unpack(args))
        end)
        HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth = math.max(0, (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 1) - 1)

        if result ~= false then
            if hpV1564ShouldFinalizeStartedJob(app, job) then
                HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
            else
                hpV1564ClearPendingStart(app, job)
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: AI start was not registered as an active assignment because the job ended immediately")
            end
        end

        return result
    end

    HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth = (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 0) + 1
    result = superFunc(aiSystem, job, farmId, unpack(args))
    HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth = math.max(0, (HelperPersonnelAIJobHooks.hp1564InsideAISystemStartDepth or 1) - 1)

    if result ~= false and app ~= nil and app.helperBridge ~= nil and job ~= nil then
        workerId = HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
        if workerId ~= nil then
            if hpV1564ShouldFinalizeStartedJob(app, job) then
                HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
            else
                hpV1564ClearPendingStart(app, job)
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: AI start was not registered as an active assignment because the job ended immediately")
            end
        end
    end

    return result
end
HelperPersonnelAIJobHooks.onAISystemStartJob = hpOverride_HelperPersonnelAIJobHooks_onAISystemStartJob_1

function HelperPersonnelApp:hp1564FindVehicleByKey(vehicleKey)
    vehicleKey = hpV1562NormalizeVehicleKey(vehicleKey)
    if vehicleKey == nil or g_currentMission == nil or type(g_currentMission.vehicles) ~= "table" then
        return nil
    end

    for _, vehicle in pairs(g_currentMission.vehicles) do
        if vehicle ~= nil then
            local rootVehicle = self.getRootVehicle ~= nil and self:getRootVehicle(vehicle) or vehicle
            local key = self.getVehicleKey ~= nil and self:getVehicleKey(rootVehicle) or nil
            if hpV1562NormalizeVehicleKey(key) == vehicleKey then
                return rootVehicle
            end
        end
    end

    return nil
end

function HelperPersonnelApp:hp1564FindVehicleByName(vehicleName)
    local normalizedName = hpV1563NormalizeText(vehicleName)
    if normalizedName == nil or g_currentMission == nil or type(g_currentMission.vehicles) ~= "table" then
        return nil
    end

    for _, vehicle in pairs(g_currentMission.vehicles) do
        if vehicle ~= nil then
            local rootVehicle = self.getRootVehicle ~= nil and self:getRootVehicle(vehicle) or vehicle
            local name = self.getVehicleName ~= nil and hpV1563NormalizeText(self:getVehicleName(rootVehicle)) or nil
            if name ~= nil and name == normalizedName then
                return rootVehicle
            end
        end
    end

    return nil
end

function HelperPersonnelApp:hp1564GetFarmIdForRestoredAssignment(assignment, vehicle)
    if assignment ~= nil and assignment.farmId ~= nil then
        return tonumber(assignment.farmId)
    end

    if vehicle ~= nil and self.getFarmIdForVehicle ~= nil then
        local farmId = self:getFarmIdForVehicle(vehicle)
        if farmId ~= nil then
            return farmId
        end
    end

    if self.manager ~= nil and self.manager.getWorkerFarmId ~= nil and assignment ~= nil then
        local farmId = self.manager:getWorkerFarmId(assignment.workerId)
        if farmId ~= nil then
            return farmId
        end
    end

    return self.manager ~= nil and self.manager.getCurrentFarmId ~= nil and self.manager:getCurrentFarmId() or 1
end


function HelperPersonnelApp:hp1564TryRestartRestoredAIJobs()
    if not self:isServerAuthority() or self.manager == nil or g_currentMission == nil or g_currentMission.aiSystem == nil then
        return false
    end

    local assignments = self.manager.restoredActiveJobs
    if type(assignments) ~= "table" or #assignments == 0 then
        return false
    end

    local changed = false

    for _, assignment in ipairs(assignments) do
        if assignment ~= nil and assignment.consumed ~= true and assignment.hp1564RestartFailed ~= true then
            local restarted, handled = self:hp1564TryRestartRestoredAssignment(assignment)
            if restarted then
                changed = true
            end

            if handled ~= true then
                assignment.hp1564PendingRetry = true
            end
        end
    end

    if changed and self.syncNetworkStateToClients ~= nil then
        self:syncNetworkStateToClients()
    end

    return changed
end

local HP_V1564_ORIGINAL_APP_RESTORE_ACTIVE_AI_JOBS = HelperPersonnelApp.restoreActiveAIJobs
local function hpOverride_HelperPersonnelApp_restoreActiveAIJobs_1(self)
    local restored = false

    if HP_V1564_ORIGINAL_APP_RESTORE_ACTIVE_AI_JOBS ~= nil then
        restored = HP_V1564_ORIGINAL_APP_RESTORE_ACTIVE_AI_JOBS(self) == true
    end

    if self:isServerAuthority() and restored ~= true then
        local restarted = self:hp1564TryRestartRestoredAIJobs() == true
        restored = restored or restarted
    end

    return restored
end
HelperPersonnelApp.restoreActiveAIJobs = hpOverride_HelperPersonnelApp_restoreActiveAIJobs_1

local function hpV1565GetTimeMs()
    if g_time ~= nil then
        return g_time
    end

    if g_currentMission ~= nil and g_currentMission.time ~= nil then
        return g_currentMission.time
    end

    return 0
end

local function hpV1565GetWorkerIdFromJob(job)
    if job == nil then
        return nil
    end

    if job.helperPersonnelWorkerId ~= nil then
        return job.helperPersonnelWorkerId
    end

    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getWorkerIdFromJob ~= nil then
        return HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
    end

    return nil
end

local function hpV1565ClearBridgeJobMaps(bridge, job, workerId)
    if bridge == nil or job == nil then
        return
    end

    bridge.jobWorkerIds = bridge.jobWorkerIds or {}
    bridge.workerJobById = bridge.workerJobById or {}
    bridge.vehicleWorkerIds = bridge.vehicleWorkerIds or {}

    if workerId ~= nil and bridge.workerJobById[workerId] == job then
        bridge.workerJobById[workerId] = nil
    end

    local vehicleKey = nil
    if bridge.getVehicleKeyFromJob ~= nil then
        local ok, result = pcall(function()
            return bridge:getVehicleKeyFromJob(job)
        end)
        if ok then
            vehicleKey = result
        end
    end

    if vehicleKey ~= nil then
        bridge.vehicleWorkerIds[vehicleKey] = nil
    end

    bridge.jobWorkerIds[job] = nil
    job.helperPersonnelWorkerId = nil
end

function HelperPersonnelManager:hp1565ClearWorkerAssignment(workerId, farmId, vehicleName, vehicleKey)
    local function clearCurrentContext()
        local worker = self.getWorkerById ~= nil and self:getWorkerById(workerId) or nil
        if worker == nil then
            return false
        end

        local changed = worker.busy == true
            or worker.restorePending == true
            or worker.vehicleName ~= nil and worker.vehicleName ~= ""
            or worker.vehicleKey ~= nil
            or worker.currentJobStartedAt ~= nil and worker.currentJobStartedAt > 0
            or worker.currentJobElapsedMs ~= nil and worker.currentJobElapsedMs > 0

        worker.busy = false
        worker.vehicleName = ""
        worker.vehicleKey = nil
        worker.currentJobStartedAt = 0
        worker.currentJobElapsedMs = 0
        worker.restorePending = false
        worker.restoreVehicleName = nil
        worker.restoreVehicleKey = nil

        if changed and self.touch ~= nil then
            self:touch(nil)
        end

        return changed
    end

    if self.executeWithFarmContext ~= nil and farmId ~= nil then
        return self:executeWithFarmContext(farmId, clearCurrentContext, true) == true
    end

    return clearCurrentContext() == true
end

function HelperPersonnelApp:hp1565ClearFailedRestoreJob(job, workerId, assignment, reason)
    if job ~= nil then
        job.hp1565RestoreRestartFailed = true
    end

    if assignment ~= nil then
        assignment.consumed = true
        assignment.hp1564RestartFailed = true
        assignment.hp1565RestartFailed = true
    end

    if workerId == nil then
        workerId = hpV1565GetWorkerIdFromJob(job)
    end

    local vehicle = nil
    local vehicleKey = nil
    local vehicleName = nil
    if self.helperBridge ~= nil and job ~= nil then
        if self.helperBridge.getVehicleFromJob ~= nil then
            local okVehicle, resultVehicle = pcall(function()
                return self.helperBridge:getVehicleFromJob(job)
            end)
            if okVehicle then
                vehicle = resultVehicle
            end
        end

        if self.helperBridge.getVehicleKeyFromJob ~= nil then
            local okKey, resultKey = pcall(function()
                return self.helperBridge:getVehicleKeyFromJob(job)
            end)
            if okKey then
                vehicleKey = resultKey
            end
        end

        if self.helperBridge.getVehicleNameFromJob ~= nil then
            local okName, resultName = pcall(function()
                return self.helperBridge:getVehicleNameFromJob(job)
            end)
            if okName then
                vehicleName = resultName
            end
        end

        hpV1565ClearBridgeJobMaps(self.helperBridge, job, workerId)
    end

    if vehicle == nil and job ~= nil and HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob ~= nil then
        local okVehicle, resultVehicle = pcall(function()
            return HelperPersonnelAIJobHooks.getVehicleFromJob(job)
        end)
        if okVehicle then
            vehicle = resultVehicle
        end
    end

    local changed = false
    if self:isServerAuthority() and self.manager ~= nil and workerId ~= nil then
        local farmId = nil
        if self.getFarmIdForVehicle ~= nil then
            farmId = self:getFarmIdForVehicle(vehicle)
        end
        if farmId == nil and self.manager.getWorkerFarmId ~= nil then
            farmId = self.manager:getWorkerFarmId(workerId)
        end

        if self.manager.hp1565ClearWorkerAssignment ~= nil then
            changed = self.manager:hp1565ClearWorkerAssignment(workerId, farmId, vehicleName, vehicleKey) == true
        end
    end

    if self.consumePendingWorkerForVehicle ~= nil then
        self:consumePendingWorkerForVehicle(vehicle)
    end

    if self.hp1565PendingRestoreRestartJobs ~= nil and job ~= nil then
        self.hp1565PendingRestoreRestartJobs[job] = nil
    end

    if changed and self.syncNetworkStateToClients ~= nil then
        self:syncNetworkStateToClients()
    end

    if reason ~= nil and reason ~= "" then
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Restore start for worker ID %s was cleared: %s", tostring(workerId), tostring(reason))
    end
end

if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.finalizeStartedJob ~= nil then
    local HP_V1565_ORIGINAL_AIJOB_FINALIZE_STARTED_JOB = HelperPersonnelAIJobHooks.finalizeStartedJob
    local function hpOverride_HelperPersonnelAIJobHooks_finalizeStartedJob_1(app, job, workerId)
        if HP_V1565_ORIGINAL_AIJOB_FINALIZE_STARTED_JOB ~= nil then
            HP_V1565_ORIGINAL_AIJOB_FINALIZE_STARTED_JOB(app, job, workerId)
        end

        if job ~= nil then
            job.hpHelperPersonnelFinalized = true
            if job.hp1565RestoreRestart == true then
                job.hp1565RestoreConfirmed = true
            end
        end
    end
    HelperPersonnelAIJobHooks.finalizeStartedJob = hpOverride_HelperPersonnelAIJobHooks_finalizeStartedJob_1
end

if HelperPersonnelHelperBridge ~= nil and HelperPersonnelHelperBridge.attachRestoredJob ~= nil then
    local HP_V1565_ORIGINAL_BRIDGE_ATTACH_RESTORED_JOB = HelperPersonnelHelperBridge.attachRestoredJob
    local function hpOverride_HelperPersonnelHelperBridge_attachRestoredJob_1(self, job, workerId)
        local result = HP_V1565_ORIGINAL_BRIDGE_ATTACH_RESTORED_JOB ~= nil and HP_V1565_ORIGINAL_BRIDGE_ATTACH_RESTORED_JOB(self, job, workerId) == true
        if result and job ~= nil then
            job.hpHelperPersonnelFinalized = true
            if job.hp1565RestoreRestart == true then
                job.hp1565RestoreConfirmed = true
            end
        end
        return result
    end
    HelperPersonnelHelperBridge.attachRestoredJob = hpOverride_HelperPersonnelHelperBridge_attachRestoredJob_1
end

if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.onAIJobStop ~= nil then
    local HP_V1565_ORIGINAL_AIJOB_STOP = HelperPersonnelAIJobHooks.onAIJobStop
    local function hpOverride_HelperPersonnelAIJobHooks_onAIJobStop_1(job, aiMessage)
        local app = g_helperPersonnelApp
        local workerId = hpV1565GetWorkerIdFromJob(job)

        if job ~= nil and workerId ~= nil and job.hpHelperPersonnelFinalized ~= true then
            if app ~= nil and app.hp1565ClearFailedRestoreJob ~= nil then
                app:hp1565ClearFailedRestoreJob(job, workerId, job.hp1565RestoreAssignment, "job was not confirmed as an active assignment")
            end
            return
        end

        if job ~= nil and job.hp1565RestoreRestart == true then
            local now = hpV1565GetTimeMs()
            local protectUntil = job.hp1565RestoreProtectUntil or 0
            if now <= protectUntil then
                if app ~= nil and app.hp1565ClearFailedRestoreJob ~= nil then
                    app:hp1565ClearFailedRestoreJob(job, workerId, job.hp1565RestoreAssignment, "restore job ended during the grace period")
                end
                return
            end
        end

        return HP_V1565_ORIGINAL_AIJOB_STOP(job, aiMessage)
    end
    HelperPersonnelAIJobHooks.onAIJobStop = hpOverride_HelperPersonnelAIJobHooks_onAIJobStop_1
end

function HelperPersonnelApp:hp1565VerifyPendingRestoreRestarts()
    if not self:isServerAuthority() or self.hp1565PendingRestoreRestartJobs == nil then
        return
    end

    local now = hpV1565GetTimeMs()
    local changed = false

    for job, record in pairs(self.hp1565PendingRestoreRestartJobs) do
        if job == nil or record == nil then
            self.hp1565PendingRestoreRestartJobs[job] = nil
        elseif now >= (record.verifyAt or 0) then
            local known, active = hpV1564GetJobActiveState(self, job)
            local vehicleActive = false
            local vehicle = record.vehicle
            if vehicle ~= nil and vehicle.getIsAIActive ~= nil then
                local okActive, resultActive = pcall(function()
                    return vehicle:getIsAIActive()
                end)
                vehicleActive = okActive and resultActive == true
            end

            if (known and active) or vehicleActive then
                job.hpHelperPersonnelFinalized = true
                job.hp1565RestoreConfirmed = true
                if self.helperBridge ~= nil and record.workerId ~= nil then
                    local farmId = record.farmId
                    if self.helperBridge.onJobStarted ~= nil then
                        self.helperBridge:onJobStarted(job, record.workerId)
                    end
                    if self.manager ~= nil and self.manager.startWorkerJobForFarm ~= nil and farmId ~= nil then

                    end
                end
                if record.assignment ~= nil then
                    record.assignment.consumed = true
                end
                self.hp1565PendingRestoreRestartJobs[job] = nil
                changed = true
            elseif now >= (record.failAt or 0) then
                self:hp1565ClearFailedRestoreJob(job, record.workerId, record.assignment, "restarted job did not remain active")
                self.hp1565PendingRestoreRestartJobs[job] = nil
                changed = true
            else

            end
        end
    end

    if changed and self.syncNetworkStateToClients ~= nil then
        self:syncNetworkStateToClients()
    end
end

function HelperPersonnelApp:hp1564TryRestartRestoredAssignment(assignment)
    if assignment == nil or assignment.workerId == nil or self.manager == nil then
        return false, false
    end

    if assignment.hp1565RestartAttempted == true then
        return false, true
    end

    local worker = self.manager.getWorkerById ~= nil and self.manager:getWorkerById(assignment.workerId) or nil
    if worker == nil or worker.busy == true or worker.restorePending ~= true then
        return false, true
    end

    local vehicle = self:hp1564FindVehicleByKey(assignment.vehicleKey)
    if vehicle == nil then
        vehicle = self:hp1564FindVehicleByName(assignment.vehicleName)
    end

    if vehicle == nil then
        assignment.hp1564MissingVehicleAttempts = (assignment.hp1564MissingVehicleAttempts or 0) + 1
        return false, false
    end

    if vehicle.getIsAIActive ~= nil then
        local okActive, isActive = pcall(function()
            return vehicle:getIsAIActive()
        end)
        if okActive and isActive == true then
            assignment.consumed = true
            return false, true
        end
    end

    if vehicle.getStartableAIJob == nil then
        assignment.hp1564RestartFailed = true
        if self.hp1565ClearFailedRestoreJob ~= nil then
            self:hp1565ClearFailedRestoreJob(nil, assignment.workerId, assignment, "vehicle has no startable AI job")
        end
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Saved AI job for worker ID %s could not be restarted: vehicle has no startable AI job", tostring(assignment.workerId))
        return false, true
    end

    local okJob, aiJob = pcall(vehicle.getStartableAIJob, vehicle)
    if not okJob or aiJob == nil then
        assignment.hp1564RestartFailed = true
        if self.hp1565ClearFailedRestoreJob ~= nil then
            self:hp1565ClearFailedRestoreJob(nil, assignment.workerId, assignment, "no startable AI job on vehicle")
        end
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Saved AI job for worker ID %s could not be restarted: no startable AI job on vehicle", tostring(assignment.workerId))
        return false, true
    end

    assignment.hp1565RestartAttempted = true

    self:prepareAIJobForWorker(aiJob, vehicle, assignment.workerId)
    aiJob.hp1565RestoreRestart = true
    aiJob.hp1565RestoreAssignment = assignment
    aiJob.hp1565RestoreStartedAt = hpV1565GetTimeMs()
    aiJob.hp1565RestoreProtectUntil = aiJob.hp1565RestoreStartedAt + 15000

    local farmId = self:hp1564GetFarmIdForRestoredAssignment(assignment, vehicle)
    local okStart, result = pcall(function()
        return g_currentMission.aiSystem:startJob(aiJob, farmId)
    end)

    if not okStart or result == false then
        hpV1564ClearPendingStart(self, aiJob)
        assignment.hp1564RestartFailed = true
        if self.hp1565ClearFailedRestoreJob ~= nil then
            self:hp1565ClearFailedRestoreJob(aiJob, assignment.workerId, assignment, okStart and "AISystem.startJob returned false" or tostring(result))
        end
        if not okStart then
            Logging.warning("FS25_HelperPersonnel: Saved AI job for worker ID %s could not be restarted: %s", tostring(assignment.workerId), tostring(result))
        else
            HelperPersonnel.debugInfo("FS25_HelperPersonnel: Saved AI job for worker ID %s could not be restarted: AISystem.startJob returned false", tostring(assignment.workerId))
        end
        return false, true
    end

    self.hp1565PendingRestoreRestartJobs = self.hp1565PendingRestoreRestartJobs or {}
    self.hp1565PendingRestoreRestartJobs[aiJob] = {
        assignment = assignment,
        workerId = assignment.workerId,
        vehicle = vehicle,
        vehicleKey = assignment.vehicleKey,
        vehicleName = assignment.vehicleName,
        farmId = farmId,
        verifyAt = hpV1565GetTimeMs() + 750,
        failAt = hpV1565GetTimeMs() + 6000
    }

    HelperPersonnel.debugInfo("FS25_HelperPersonnel: Saved AI job for worker ID %s was queued for restart", tostring(assignment.workerId))
    return true, true
end

local HP_V1565_ORIGINAL_APP_UPDATE = hpLayer_HelperPersonnelApp_update_1
local function hpLayer_HelperPersonnelApp_update_2(self, dt)
    if HP_V1565_ORIGINAL_APP_UPDATE ~= nil then
        HP_V1565_ORIGINAL_APP_UPDATE(self, dt)
    end

    self:hp1565VerifyPendingRestoreRestarts()
end

local function hpV15611NormalizeVehicleKey(vehicleKey)
    if vehicleKey == nil then
        return nil
    end

    local key = tostring(vehicleKey)
    if key == "" then
        return nil
    end

    return key
end

local function hpV15611NormalizeText(value)
    if value == nil then
        return nil
    end

    local text = tostring(value)
    if text == "" then
        return nil
    end

    return string.lower(text)
end

local function hpV15611HasTableEntries(values)
    if type(values) ~= "table" then
        return false
    end

    for _, _ in pairs(values) do
        return true
    end

    return false
end

if HelperPersonnelAIJobHooks ~= nil then
    function HelperPersonnelAIJobHooks.hp15611InstallJobStopHooks()
        local targets = {
            "AIJobFieldWork",
            "AIJobDeliver",
            "AIJobConveyor",
            "AIJobGoTo",
            "AIJobLoadAndDeliver"
        }

        for _, className in ipairs(targets) do
            local classObject = _G[className]
            if classObject ~= nil and classObject.hp15611StopHookInstalled ~= true then
                local stopFunc = rawget(classObject, "stop")
                if stopFunc ~= nil and Utils ~= nil and Utils.prependedFunction ~= nil and HelperPersonnelAIJobHooks.onAIJobStop ~= nil then
                    classObject.stop = Utils.prependedFunction(stopFunc, HelperPersonnelAIJobHooks.onAIJobStop)
                    classObject.hp15611StopHookInstalled = true
                end
            end
        end
    end

    HelperPersonnelAIJobHooks.hp15611InstallJobStopHooks()
end

function HelperPersonnelApp:hp15611AddJobToActiveLookup(lookup, job)
    if lookup == nil or job == nil then
        return
    end

    local workerId = tonumber(job.helperPersonnelWorkerId)

    if workerId == nil and self.helperBridge ~= nil and self.helperBridge.getWorkerIdByJob ~= nil then
        local okWorker, resultWorker = pcall(function()
            return self.helperBridge:getWorkerIdByJob(job)
        end)
        if okWorker then
            workerId = tonumber(resultWorker)
        end
    end

    if workerId == nil and self.helperBridge ~= nil and self.helperBridge.resolveRestoredWorkerIdForJob ~= nil then
        local okRestored, resultRestored = pcall(function()
            return self.helperBridge:resolveRestoredWorkerIdForJob(job)
        end)
        if okRestored then
            workerId = tonumber(resultRestored)
        end
    end

    if workerId ~= nil then
        lookup.workerIds[workerId] = true
    end

    local vehicleKey = nil
    if self.helperBridge ~= nil and self.helperBridge.getVehicleKeyFromJob ~= nil then
        local okKey, resultKey = pcall(function()
            return self.helperBridge:getVehicleKeyFromJob(job)
        end)
        if okKey then
            vehicleKey = hpV15611NormalizeVehicleKey(resultKey)
        end
    end

    if vehicleKey ~= nil then
        lookup.vehicleKeys[vehicleKey] = true
    end

    local vehicleName = nil
    if self.helperBridge ~= nil and self.helperBridge.getVehicleNameFromJob ~= nil then
        local okName, resultName = pcall(function()
            return self.helperBridge:getVehicleNameFromJob(job)
        end)
        if okName then
            vehicleName = hpV15611NormalizeText(resultName)
        end
    end

    if vehicleName == nil and self.helperBridge ~= nil and self.helperBridge.getVehicleFromJob ~= nil then
        local okVehicle, vehicle = pcall(function()
            return self.helperBridge:getVehicleFromJob(job)
        end)
        if okVehicle and vehicle ~= nil then
            if self.getRootVehicle ~= nil then
                vehicle = self:getRootVehicle(vehicle)
            end
            if self.getVehicleName ~= nil then
                vehicleName = hpV15611NormalizeText(self:getVehicleName(vehicle))
            end
        end
    end

    if vehicleName ~= nil then
        lookup.vehicleNames[vehicleName] = true
    end
end

function HelperPersonnelApp:hp15611AddActiveVehiclesToLookup(lookup)
    if lookup == nil or g_currentMission == nil or type(g_currentMission.vehicles) ~= "table" then
        return
    end

    for _, vehicle in pairs(g_currentMission.vehicles) do
        if vehicle ~= nil and vehicle.getIsAIActive ~= nil then
            local okActive, isActive = pcall(function()
                return vehicle:getIsAIActive()
            end)

            if okActive and isActive == true then
                local rootVehicle = vehicle
                if self.getRootVehicle ~= nil then
                    rootVehicle = self:getRootVehicle(vehicle)
                end

                local vehicleKey = nil
                if self.getVehicleKey ~= nil then
                    vehicleKey = hpV15611NormalizeVehicleKey(self:getVehicleKey(rootVehicle))
                end
                if vehicleKey ~= nil then
                    lookup.vehicleKeys[vehicleKey] = true
                end

                local vehicleName = nil
                if self.getVehicleName ~= nil then
                    vehicleName = hpV15611NormalizeText(self:getVehicleName(rootVehicle))
                end
                if vehicleName ~= nil then
                    lookup.vehicleNames[vehicleName] = true
                end
            end
        end
    end
end

function HelperPersonnelApp:hp15611BuildActiveAssignmentLookup()
    local lookup = {
        count = 0,
        workerIds = {},
        vehicleKeys = {},
        vehicleNames = {},
        jobSet = {},
        hasIdentifiers = false
    }

    local activeJobs = self.getActiveAIJobs ~= nil and self:getActiveAIJobs() or nil
    if type(activeJobs) == "table" then
        for key, value in pairs(activeJobs) do
            local job = nil

            if type(value) == "table" then
                job = value
            elseif type(key) == "table" then
                job = key
            end

            if job ~= nil and lookup.jobSet[job] ~= true then
                lookup.jobSet[job] = true
                lookup.count = lookup.count + 1
                self:hp15611AddJobToActiveLookup(lookup, job)
            end
        end
    end

    self:hp15611AddActiveVehiclesToLookup(lookup)

    if HelperPersonnelAutoDriveCompatibility ~= nil and HelperPersonnelAutoDriveCompatibility.addActiveAssignmentsToLookup ~= nil then
        HelperPersonnelAutoDriveCompatibility.addActiveAssignmentsToLookup(self, lookup)
    end

    lookup.hasIdentifiers = hpV15611HasTableEntries(lookup.workerIds)
        or hpV15611HasTableEntries(lookup.vehicleKeys)
        or hpV15611HasTableEntries(lookup.vehicleNames)

    return lookup
end

function HelperPersonnelHelperBridge:hp15611CleanupFinishedJobMappings(activeLookup)
    activeLookup = activeLookup or {}
    local jobSet = activeLookup.jobSet or {}
    local activeVehicleKeys = activeLookup.vehicleKeys or {}

    self.jobWorkerIds = self.jobWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}

    local changed = false

    for workerId, job in pairs(self.workerJobById) do
        if job == nil or jobSet[job] ~= true then
            self.workerJobById[workerId] = nil
            if job ~= nil then
                self.jobWorkerIds[job] = nil
                if job.helperPersonnelWorkerId == workerId then
                    job.helperPersonnelWorkerId = nil
                end
            end
            changed = true
        end
    end

    for job, workerId in pairs(self.jobWorkerIds) do
        if job == nil or jobSet[job] ~= true then
            self.jobWorkerIds[job] = nil
            if job ~= nil and job.helperPersonnelWorkerId == workerId then
                job.helperPersonnelWorkerId = nil
            end
            changed = true
        end
    end

    local canCleanVehicleMap = (activeLookup.count or 0) == 0 or hpV15611HasTableEntries(activeVehicleKeys)
    if canCleanVehicleMap then
        for vehicleKey, _ in pairs(self.vehicleWorkerIds) do
            local normalizedKey = hpV15611NormalizeVehicleKey(vehicleKey)
            if normalizedKey == nil or activeVehicleKeys[normalizedKey] ~= true then
                self.vehicleWorkerIds[vehicleKey] = nil
                changed = true
            end
        end
    end

    return changed
end

function HelperPersonnelApp:hp15611UpdateFinishedJobAudit(dt)
    if self.isMissionDeleting == true then
        return
    end

    if self.isServerAuthority == nil or self:isServerAuthority() ~= true then
        return
    end

    if self.activeJobsRestoreDone ~= true then
        return
    end

    self.hp15611FinishedJobAuditTimer = (self.hp15611FinishedJobAuditTimer or 0) + (dt or 0)
    if self.hp15611FinishedJobAuditTimer < 1000 then
        return
    end
    self.hp15611FinishedJobAuditTimer = 0

    local activeLookup = self.hp15611BuildActiveAssignmentLookup ~= nil and self:hp15611BuildActiveAssignmentLookup() or nil
    local bridgeChanged = false
    local managerChanged = false

    if self.helperBridge ~= nil and self.helperBridge.hp15611CleanupFinishedJobMappings ~= nil then
        bridgeChanged = self.helperBridge:hp15611CleanupFinishedJobMappings(activeLookup) == true
    end

    if self.manager ~= nil and self.manager.hp1563CleanupStaleActiveAssignments ~= nil then
        managerChanged = self.manager:hp1563CleanupStaleActiveAssignments(activeLookup) == true
        if managerChanged and self.manager.storeCurrentFarmData ~= nil then
            self.manager:storeCurrentFarmData()
        end
    end

    if bridgeChanged or managerChanged then
        if self.syncNetworkStateToClients ~= nil then
            self:syncNetworkStateToClients()
        end
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Ended or stale worker assignments were cleared")
    end
end

local HP_V15611_ORIGINAL_APP_UPDATE = hpLayer_HelperPersonnelApp_update_2
local function hpOverride_HelperPersonnelApp_update_1(self, dt)
    if HP_V15611_ORIGINAL_APP_UPDATE ~= nil then
        HP_V15611_ORIGINAL_APP_UPDATE(self, dt)
    end

    if HelperPersonnelAutoDriveCompatibility ~= nil and HelperPersonnelAutoDriveCompatibility.update ~= nil then
        HelperPersonnelAutoDriveCompatibility.update(dt)
    end

    if self.hp15611UpdateFinishedJobAudit ~= nil then
        self:hp15611UpdateFinishedJobAudit(dt)
    end
end
HelperPersonnelApp.update = hpOverride_HelperPersonnelApp_update_1

if HelperPersonnelHelperBridge ~= nil and HelperPersonnelHelperBridge.onJobStopped ~= nil then
    local HP_V15182_ORIGINAL_BRIDGE_ON_JOB_STOPPED = hpLayer_HelperPersonnelHelperBridge_onJobStopped_2
    local function hpOverride_HelperPersonnelHelperBridge_onJobStopped_1(self, job)
        if job == nil then
            return
        end

        if job.hpHelperPersonnelStopHandled == true then
            return
        end

        local workerId = nil
        if self.getWorkerIdByJob ~= nil then
            workerId = self:getWorkerIdByJob(job)
        elseif job.helperPersonnelWorkerId ~= nil then
            workerId = job.helperPersonnelWorkerId
        end


        if HelperPersonnelAutoDriveCompatibility ~= nil
            and HelperPersonnelAutoDriveCompatibility.beforeBridgeJobStopped ~= nil
            and HelperPersonnelAutoDriveCompatibility.beforeBridgeJobStopped(self, job, workerId) == true then
            return
        end

        local assignedJob = workerId ~= nil and self.workerJobById[workerId] or nil
        local vehicleKey = self.getVehicleKeyFromJob ~= nil and self:getVehicleKeyFromJob(job) or nil

        local result = HP_V15182_ORIGINAL_BRIDGE_ON_JOB_STOPPED(self, job)

        if HelperPersonnelAutoDriveCompatibility ~= nil and HelperPersonnelAutoDriveCompatibility.afterBridgeJobStopped ~= nil then
            HelperPersonnelAutoDriveCompatibility.afterBridgeJobStopped(self, job, workerId, assignedJob, vehicleKey)
        end

        if workerId ~= nil then
            job.helperPersonnelWorkerId = workerId
            job.hpHelperPersonnelStopHandled = true
        end

        return result
    end
    HelperPersonnelHelperBridge.onJobStopped = hpOverride_HelperPersonnelHelperBridge_onJobStopped_1
end

local function hpMP101GetFarmManager()
    return g_farmManager or (g_currentMission ~= nil and g_currentMission.farmManager or nil)
end

local function hpMP101GetMaximumFarmId()
    local bits = FarmManager ~= nil and tonumber(FarmManager.FARM_ID_SEND_NUM_BITS) or 8
    bits = math.floor(bits or 8)
    if bits < 1 or bits > 30 then
        bits = 8
    end
    return (2 ^ bits) - 1
end

local function hpMP101NormalizeFarmId(farmId)
    local numericFarmId = tonumber(farmId)
    if numericFarmId == nil or numericFarmId <= 0 then
        return nil
    end

    farmId = math.floor(numericFarmId)
    if farmId ~= numericFarmId or farmId > hpMP101GetMaximumFarmId() then
        return nil
    end
    if FarmManager ~= nil and FarmManager.SPECTATOR_FARM_ID ~= nil and farmId == FarmManager.SPECTATOR_FARM_ID then
        return nil
    end
    if FarmManager ~= nil and FarmManager.NO_OWNER_FARM_ID ~= nil and farmId == FarmManager.NO_OWNER_FARM_ID then
        return nil
    end

    return farmId
end

local function hpMP101AddFarmId(result, farmId)
    farmId = hpMP101NormalizeFarmId(farmId)
    if farmId == nil then
        return
    end

    if result.lookup[farmId] ~= true then
        result.lookup[farmId] = true
        table.insert(result.ids, farmId)
    end
end

local function hpMP101CollectKnownFarmIds()
    local result = { ids = {}, lookup = {} }
    local farmManager = hpMP101GetFarmManager()
    if farmManager ~= nil and farmManager.getFarms ~= nil and farmManager.getFarmById ~= nil then
        for _, farm in ipairs(farmManager:getFarms() or {}) do
            local farmId = type(farm) == "table" and hpMP101NormalizeFarmId(farm.farmId) or nil
            if farmId ~= nil and farmManager:getFarmById(farmId) == farm then
                hpMP101AddFarmId(result, farmId)
            end
        end
    end

    table.sort(result.ids, function(a, b) return tonumber(a) < tonumber(b) end)
    return result.ids
end

local function hpMP101IsRegisteredFarmId(farmId)
    farmId = hpMP101NormalizeFarmId(farmId)
    local farmManager = hpMP101GetFarmManager()
    if farmId == nil or farmManager == nil or farmManager.getFarmById == nil then
        return false
    end

    local farm = farmManager:getFarmById(farmId)
    return farm ~= nil and hpMP101NormalizeFarmId(farm.farmId) == farmId
end

local function hpMP101HasTableEntries(value)
    return type(value) == "table" and next(value) ~= nil
end

local function hpMP101HasMeaningfulFarmData(data)
    if type(data) ~= "table" then
        return false
    end

    if hpMP101HasTableEntries(data.workers)
        or hpMP101HasTableEntries(data.reputationHistory)
        or hpMP101HasTableEntries(data.actionHistory)
        or hpMP101HasTableEntries(data.personChronicles)
        or hpMP101HasTableEntries(data.activeAssignments)
        or hpMP101HasTableEntries(data.saveActiveJobSnapshot)
        or hpMP101HasTableEntries(data.saveBusyWorkerLookup) then
        return true
    end

    if tonumber(data.selectedWorkerId) ~= nil and tonumber(data.selectedWorkerId) > 0 then
        return true
    end
    if (tonumber(data.totalPayrollPaid) or 0) ~= 0
        or (tonumber(data.lastPayrollAmount) or 0) ~= 0
        or (tonumber(data.monthlyDismissals) or 0) ~= 0
        or (tonumber(data.pendingPayrollLoyaltyDelta) or 0) ~= 0
        or (tonumber(data.historySequence) or 0) ~= 0 then
        return true
    end
    if (tonumber(data.employerReputation) or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50) ~= (HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50) then
        return true
    end
    return false
end

local function hpMP101WarnOnce(manager, key, message, ...)
    manager.hpMP101Warnings = manager.hpMP101Warnings or {}
    if manager.hpMP101Warnings[key] == true then
        return
    end

    manager.hpMP101Warnings[key] = true
    if Logging ~= nil and Logging.warning ~= nil then
        Logging.warning(message, ...)
    end
end

local function hpMP101SanitizeLegacyFarmData(manager)
    if type(manager.farms) ~= "table" then
        return false
    end

    local knownFarmIds = hpMP101CollectKnownFarmIds()
    local knownLookup = {}
    for _, farmId in ipairs(knownFarmIds) do
        knownLookup[farmId] = true
    end

    local changed = false
    for farmKey, data in pairs(manager.farms) do
        local numericFarmKey = tonumber(farmKey)
        if numericFarmKey ~= nil and numericFarmKey == math.floor(numericFarmKey) and knownLookup[numericFarmKey] == true then
            if type(data) == "table" then
                data.farmId = numericFarmKey
            end
        elseif numericFarmKey ~= nil and hpMP101NormalizeFarmId(numericFarmKey) == nil and not hpMP101HasMeaningfulFarmData(data) then
            manager.farms[farmKey] = nil
            if manager.currentFarmData == data then
                manager.currentFarmData = nil
                manager.activeFarmId = nil
            end
            changed = true
            hpMP101WarnOnce(manager, "removed:" .. tostring(numericFarmKey), "FS25_PersonnelManagement: Stale phantom farm data %s was removed.", tostring(numericFarmKey))
        else
            hpMP101WarnOnce(manager, "preserved:" .. tostring(farmKey), "FS25_PersonnelManagement: Unregistered farm data %s may contain persistent data and will not be synchronized or deleted automatically.", tostring(farmKey))
        end
    end

    return changed
end

local function hpMP101FilterNetworkStateToRegisteredFarms(manager, state)
    if type(state) ~= "table" or type(state.farms) ~= "table" then
        return nil
    end

    local allowed = {}
    for _, farmId in ipairs(hpMP101CollectKnownFarmIds()) do
        allowed[farmId] = true
    end

    local filtered = {}
    local seen = {}
    for _, farmState in ipairs(state.farms) do
        local farmId = type(farmState) == "table" and hpMP101NormalizeFarmId(farmState.farmId) or nil
        if farmId ~= nil and allowed[farmId] == true then
            if seen[farmId] == true then
                hpMP101WarnOnce(manager, "duplicateNetworkFarm:" .. tostring(farmId), "FS25_PersonnelManagement: Network state discarded because farm %s is duplicated.", tostring(farmId))
                return nil
            end
            seen[farmId] = true
            farmState.farmId = farmId
            table.insert(filtered, farmState)
        end
    end

    local maximumFarms = HelperPersonnelNetwork ~= nil and tonumber(HelperPersonnelNetwork.MAX_NETWORK_FARMS) or 64
    if #filtered == 0 or #filtered > maximumFarms then
        hpMP101WarnOnce(manager, "invalidNetworkFarmCount", "FS25_PersonnelManagement: Network state discarded because the registered farm count is invalid (%s).", tostring(#filtered))
        return nil
    end

    state.farms = filtered
    local activeFarmId = hpMP101NormalizeFarmId(state.activeFarmId)
    if activeFarmId == nil or seen[activeFarmId] ~= true then
        state.activeFarmId = filtered[1].farmId
    end

    return state
end

function HelperPersonnelManager:hpMP101EnsureFarmDataForFarm(farmId)
    farmId = hpMP101NormalizeFarmId(farmId)
    if farmId == nil or not hpMP101IsRegisteredFarmId(farmId) then
        return false
    end

    if self.farms == nil then
        self.farms = {}
    end

    local previousForcedFarmId = self.forcedFarmId
    local previousCurrentFarmData = self.currentFarmData

    self.forcedFarmId = farmId
    local data = self:getOrCreateFarmData(farmId, true)
    if data ~= nil then
        data.farmId = farmId
        if self.ensureInitialApplicantMarketForFarmData ~= nil then
            self:ensureInitialApplicantMarketForFarmData(data)
        end

        for _, worker in ipairs(data.workers or {}) do
            worker.farmId = farmId
        end
        for _, applicant in ipairs(data.applicants or {}) do
            applicant.farmId = farmId
        end
    end

    self.forcedFarmId = previousForcedFarmId
    if previousCurrentFarmData ~= nil and self.bindFarmData ~= nil then
        self:bindFarmData(previousCurrentFarmData)
    end

    return data ~= nil
end

function HelperPersonnelManager:hpMP101EnsureFarmDataForKnownFarms()
    if self.farms == nil then
        self.farms = {}
    end

    local previousData = self.currentFarmData
    local previousFarmId = type(previousData) == "table" and tonumber(previousData.farmId) or nil
    local changed = hpMP101SanitizeLegacyFarmData(self)
    local knownFarmIds = hpMP101CollectKnownFarmIds()

    for _, farmId in ipairs(knownFarmIds) do
        local hadData = self.farms[farmId] ~= nil
        if self:hpMP101EnsureFarmDataForFarm(farmId) then
            changed = changed or not hadData
        end
    end

    if previousFarmId ~= nil and self.farms[previousFarmId] == previousData and self.bindFarmData ~= nil then
        self:bindFarmData(previousData)
    elseif knownFarmIds[1] ~= nil and self.farms[knownFarmIds[1]] ~= nil and self.bindFarmData ~= nil then
        self:bindFarmData(self.farms[knownFarmIds[1]])
    elseif self.refreshFarmContext ~= nil then
        self:refreshFarmContext()
    end

    return changed
end

local HP_MP101_ORIGINAL_MANAGER_GET_NETWORK_STATE = hpLayer_HelperPersonnelManager_getNetworkState_1
local function hpOverride_HelperPersonnelManager_getNetworkState_1(self)
    if g_server ~= nil or (g_currentMission ~= nil and g_currentMission.getIsServer ~= nil and g_currentMission:getIsServer() == true) then
        if self.hpMP101EnsureFarmDataForKnownFarms ~= nil then
            self:hpMP101EnsureFarmDataForKnownFarms()
        end
    end

    if HP_MP101_ORIGINAL_MANAGER_GET_NETWORK_STATE ~= nil then
        local state = HP_MP101_ORIGINAL_MANAGER_GET_NETWORK_STATE(self)
        return hpMP101FilterNetworkStateToRegisteredFarms(self, state)
    end

    return nil
end
HelperPersonnelManager.getNetworkState = hpOverride_HelperPersonnelManager_getNetworkState_1

local HP_MP101_ORIGINAL_APP_SEND_NETWORK_STATE_TO_CONNECTION = HelperPersonnelApp.sendNetworkStateToConnection
local function hpOverride_HelperPersonnelApp_sendNetworkStateToConnection_1(self, connection)
    if self:isServerAuthority() and self.manager ~= nil then
        if self.getFarmIdFromConnection ~= nil then
            local farmId = hpMP101NormalizeFarmId(self:getFarmIdFromConnection(connection))
            if farmId ~= nil and self.manager.hpMP101EnsureFarmDataForFarm ~= nil then
                self.manager:hpMP101EnsureFarmDataForFarm(farmId)
            end
        end

        if self.manager.hpMP101EnsureFarmDataForKnownFarms ~= nil then
            self.manager:hpMP101EnsureFarmDataForKnownFarms()
        end
    end

    if HP_MP101_ORIGINAL_APP_SEND_NETWORK_STATE_TO_CONNECTION ~= nil then
        return HP_MP101_ORIGINAL_APP_SEND_NETWORK_STATE_TO_CONNECTION(self, connection)
    end

    return false
end
HelperPersonnelApp.sendNetworkStateToConnection = hpOverride_HelperPersonnelApp_sendNetworkStateToConnection_1

local HP_MP101_ORIGINAL_APP_SYNC_NETWORK_STATE_TO_CLIENTS = HelperPersonnelApp.syncNetworkStateToClients
local function hpOverride_HelperPersonnelApp_syncNetworkStateToClients_1(self)
    if self:isServerAuthority() and self.manager ~= nil and self.manager.hpMP101EnsureFarmDataForKnownFarms ~= nil then
        self.manager:hpMP101EnsureFarmDataForKnownFarms()
    end

    if HP_MP101_ORIGINAL_APP_SYNC_NETWORK_STATE_TO_CLIENTS ~= nil then
        return HP_MP101_ORIGINAL_APP_SYNC_NETWORK_STATE_TO_CLIENTS(self)
    end

    return false
end
HelperPersonnelApp.syncNetworkStateToClients = hpOverride_HelperPersonnelApp_syncNetworkStateToClients_1

local function hpLayer_HelperPersonnelApp_hpMP101FilterClientStateToServerFarms_1(self, state)
    if not self:isMultiplayerClient() or self.manager == nil or type(state) ~= "table" or type(state.farms) ~= "table" then
        return false
    end

    local allowed = {}
    local firstFarmId = nil
    for _, farmState in ipairs(state.farms) do
        local farmId = hpMP101NormalizeFarmId(farmState.farmId)
        if farmId ~= nil then
            allowed[farmId] = true
            firstFarmId = firstFarmId or farmId
        end
    end

    if firstFarmId == nil or type(self.manager.farms) ~= "table" then
        return false
    end

    for farmId, _ in pairs(self.manager.farms) do
        if allowed[hpMP101NormalizeFarmId(farmId)] ~= true then
            self.manager.farms[farmId] = nil
        end
    end

    local preferredFarmId = self.getCurrentFarmId ~= nil and hpMP101NormalizeFarmId(self:getCurrentFarmId()) or nil
    local bindFarmId = nil
    if preferredFarmId ~= nil and allowed[preferredFarmId] == true then
        bindFarmId = preferredFarmId
    else
        local activeFarmId = hpMP101NormalizeFarmId(state.activeFarmId)
        bindFarmId = (activeFarmId ~= nil and allowed[activeFarmId] == true) and activeFarmId or firstFarmId
    end

    local data = self.manager.farms[bindFarmId]
    if data ~= nil and self.manager.bindFarmData ~= nil then
        self.manager:bindFarmData(data)
        return true
    end

    return false
end

local HP_MP101_ORIGINAL_APP_APPLY_NETWORK_STATE = hpLayer_HelperPersonnelApp_applyNetworkState_3
local function hpOverride_HelperPersonnelApp_applyNetworkState_1(self, state)
    local applied = false
    if HP_MP101_ORIGINAL_APP_APPLY_NETWORK_STATE ~= nil then
        applied = HP_MP101_ORIGINAL_APP_APPLY_NETWORK_STATE(self, state) == true
    end

    if applied == true then
        local rebound = self:hpMP101FilterClientStateToServerFarms(state) == true
        if rebound == true then
            if self.helperBridge ~= nil and self.helperBridge.rebuildHelperProfiles ~= nil then
                self.helperBridge:rebuildHelperProfiles()
            end
            if self.refreshPersonnelMenu ~= nil then
                self:refreshPersonnelMenu()
            end
        end
    end

    return applied
end
HelperPersonnelApp.applyNetworkState = hpOverride_HelperPersonnelApp_applyNetworkState_1

function HelperPersonnelApp:hpMP101ClientHasSyncedApplicant(applicantId)
    if self.manager == nil or self.getCurrentFarmId == nil then
        return false
    end

    local farmId = hpMP101NormalizeFarmId(self:getCurrentFarmId())
    if farmId == nil then
        return false
    end

    if self.manager.hasApplicantInFarm ~= nil then
        return self.manager:hasApplicantInFarm(applicantId, farmId) == true
    end

    local data = self.manager.getFarmDataIfExists ~= nil and self.manager:getFarmDataIfExists(farmId) or nil
    if data == nil then
        return false
    end
    for _, applicant in ipairs(data.applicants or {}) do
        if tonumber(applicant.id) == tonumber(applicantId) then
            return true
        end
    end
    return false
end

function HelperPersonnelApp:hpMP101ClientHasSyncedWorker(workerId)
    if self.manager == nil or self.getCurrentFarmId == nil then
        return false
    end

    local farmId = hpMP101NormalizeFarmId(self:getCurrentFarmId())
    if farmId == nil then
        return false
    end

    if self.manager.hasWorkerInFarm ~= nil then
        return self.manager:hasWorkerInFarm(workerId, farmId) == true
    end

    local data = self.manager.getFarmDataIfExists ~= nil and self.manager:getFarmDataIfExists(farmId) or nil
    if data == nil then
        return false
    end
    for _, worker in ipairs(data.workers or {}) do
        if tonumber(worker.id) == tonumber(workerId) then
            return true
        end
    end
    return false
end

local HP_MP101_ORIGINAL_APP_REQUEST_HIRE_APPLICANT = HelperPersonnelApp.requestHireApplicant
local function hpLayer_HelperPersonnelApp_requestHireApplicant_1(self, applicantId)
    if self:isMultiplayerClient() then
        if self.hpJoinSyncApplied ~= true or self:hpMP101ClientHasSyncedApplicant(applicantId) ~= true then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            if self.refreshPersonnelMenu ~= nil then
                self:refreshPersonnelMenu()
            end
            return false
        end
    end

    if HP_MP101_ORIGINAL_APP_REQUEST_HIRE_APPLICANT ~= nil then
        return HP_MP101_ORIGINAL_APP_REQUEST_HIRE_APPLICANT(self, applicantId)
    end

    return false
end

local HP_MP101_ORIGINAL_APP_REQUEST_DISMISS_WORKER = HelperPersonnelApp.requestDismissWorker
local function hpLayer_HelperPersonnelApp_requestDismissWorker_1(self, workerId)
    if self:isMultiplayerClient() then
        if self.hpJoinSyncApplied ~= true or self:hpMP101ClientHasSyncedWorker(workerId) ~= true then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            if self.refreshPersonnelMenu ~= nil then
                self:refreshPersonnelMenu()
            end
            return false
        end
    end

    if HP_MP101_ORIGINAL_APP_REQUEST_DISMISS_WORKER ~= nil then
        return HP_MP101_ORIGINAL_APP_REQUEST_DISMISS_WORKER(self, workerId)
    end

    return false
end

local HP_MP101_ORIGINAL_APP_PROCESS_NETWORK_ACTION = hpLayer_HelperPersonnelApp_processNetworkAction_1
local function hpLayer_HelperPersonnelApp_processNetworkAction_2(self, actionName, targetId, connection, farmId, actionData)
    if self:isServerAuthority() and self.manager ~= nil then
        local requestedFarmId = hpMP101NormalizeFarmId(farmId)
        if requestedFarmId == nil and self.getFarmIdFromConnection ~= nil then
            requestedFarmId = hpMP101NormalizeFarmId(self:getFarmIdFromConnection(connection))
        end

        if requestedFarmId ~= nil and self.manager.hpMP101EnsureFarmDataForFarm ~= nil then
            self.manager:hpMP101EnsureFarmDataForFarm(requestedFarmId)
        end
    end

    if HP_MP101_ORIGINAL_APP_PROCESS_NETWORK_ACTION ~= nil then
        return HP_MP101_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, farmId, actionData)
    end

    return false
end

local function hpMP102IsMultiplayerClientRuntime()
    if g_server ~= nil then
        return false
    end

    if g_client ~= nil then
        return true
    end

    local app = g_helperPersonnelApp
    if app ~= nil and app.isMultiplayerClient ~= nil then
        return app:isMultiplayerClient() == true
    end

    return false
end

local HP_MP102_ORIGINAL_MANAGER_ENSURE_INITIAL_MARKET = HelperPersonnelManager.ensureInitialApplicantMarketForFarmData
local function hpOverride_HelperPersonnelManager_ensureInitialApplicantMarketForFarmData_1(self, data)
    if hpMP102IsMultiplayerClientRuntime() then
        if type(data) == "table" then
            data.workers = data.workers or {}
            data.applicants = data.applicants or {}
        end
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_ENSURE_INITIAL_MARKET ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_ENSURE_INITIAL_MARKET(self, data)
    end

    return 0
end
HelperPersonnelManager.ensureInitialApplicantMarketForFarmData = hpOverride_HelperPersonnelManager_ensureInitialApplicantMarketForFarmData_1

local HP_MP102_ORIGINAL_MANAGER_INITIALIZE_NEW_MARKET = HelperPersonnelManager.initializeNewApplicantMarket
local function hpOverride_HelperPersonnelManager_initializeNewApplicantMarket_1(self)
    if hpMP102IsMultiplayerClientRuntime() then
        self.applicants = self.applicants or {}
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_INITIALIZE_NEW_MARKET ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_INITIALIZE_NEW_MARKET(self)
    end

    return 0
end
HelperPersonnelManager.initializeNewApplicantMarket = hpOverride_HelperPersonnelManager_initializeNewApplicantMarket_1

local HP_MP102_ORIGINAL_MANAGER_ENSURE_APPLICANT_BUFFER = HelperPersonnelManager.ensureApplicantBuffer
local function hpOverride_HelperPersonnelManager_ensureApplicantBuffer_1(self, minimumCount, targetCount)
    if hpMP102IsMultiplayerClientRuntime() then
        self.applicants = self.applicants or {}
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_ENSURE_APPLICANT_BUFFER ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_ENSURE_APPLICANT_BUFFER(self, minimumCount, targetCount)
    end

    return 0
end
HelperPersonnelManager.ensureApplicantBuffer = hpOverride_HelperPersonnelManager_ensureApplicantBuffer_1

local HP_MP102_ORIGINAL_MANAGER_GENERATE_MONTHLY_APPLICANTS = HelperPersonnelManager.generateMonthlyApplicants
local function hpOverride_HelperPersonnelManager_generateMonthlyApplicants_1(self, forceAtLeastOne)
    if hpMP102IsMultiplayerClientRuntime() then
        self.applicants = self.applicants or {}
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_GENERATE_MONTHLY_APPLICANTS ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_GENERATE_MONTHLY_APPLICANTS(self, forceAtLeastOne)
    end

    return 0
end
HelperPersonnelManager.generateMonthlyApplicants = hpOverride_HelperPersonnelManager_generateMonthlyApplicants_1

function HelperPersonnelApp:hpMP102GetSyncedApplicantFarmId(applicantId)
    if self.manager == nil then
        return nil
    end

    applicantId = tonumber(applicantId)
    if applicantId == nil then
        return nil
    end

    for farmId, data in pairs(self.manager.farms or {}) do
        for _, applicant in ipairs(data.applicants or {}) do
            if tonumber(applicant.id) == applicantId then
                return hpMP101NormalizeFarmId(farmId) or hpMP101NormalizeFarmId(data.farmId)
            end
        end
    end

    return nil
end

function HelperPersonnelApp:hpMP102GetSyncedWorkerFarmId(workerId)
    if self.manager == nil then
        return nil
    end

    workerId = tonumber(workerId)
    if workerId == nil then
        return nil
    end

    for farmId, data in pairs(self.manager.farms or {}) do
        for _, worker in ipairs(data.workers or {}) do
            if tonumber(worker.id) == workerId then
                return hpMP101NormalizeFarmId(farmId) or hpMP101NormalizeFarmId(data.farmId)
            end
        end
    end

    return nil
end

local HP_MP102_ORIGINAL_APP_REQUEST_HIRE_APPLICANT = hpLayer_HelperPersonnelApp_requestHireApplicant_1
local function hpOverride_HelperPersonnelApp_requestHireApplicant_1(self, applicantId)
    if self:isMultiplayerClient() then
        if self.hpJoinSyncApplied ~= true then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            return false
        end

        local applicantFarmId = self:hpMP102GetSyncedApplicantFarmId(applicantId)
        if applicantFarmId == nil then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            if self.refreshPersonnelMenu ~= nil then
                self:refreshPersonnelMenu()
            end
            return false
        end

        if self.manager ~= nil and self.manager.refreshFarmContext ~= nil then
            self.manager:refreshFarmContext(applicantFarmId)
        end
    end

    if HP_MP102_ORIGINAL_APP_REQUEST_HIRE_APPLICANT ~= nil then
        return HP_MP102_ORIGINAL_APP_REQUEST_HIRE_APPLICANT(self, applicantId)
    end

    return false
end
HelperPersonnelApp.requestHireApplicant = hpOverride_HelperPersonnelApp_requestHireApplicant_1

local HP_MP102_ORIGINAL_APP_REQUEST_DISMISS_WORKER = hpLayer_HelperPersonnelApp_requestDismissWorker_1
local function hpOverride_HelperPersonnelApp_requestDismissWorker_1(self, workerId)
    if self:isMultiplayerClient() then
        if self.hpJoinSyncApplied ~= true then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            return false
        end

        local workerFarmId = self:hpMP102GetSyncedWorkerFarmId(workerId)
        if workerFarmId == nil then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            if self.refreshPersonnelMenu ~= nil then
                self:refreshPersonnelMenu()
            end
            return false
        end

        if self.manager ~= nil and self.manager.refreshFarmContext ~= nil then
            self.manager:refreshFarmContext(workerFarmId)
        end
    end

    if HP_MP102_ORIGINAL_APP_REQUEST_DISMISS_WORKER ~= nil then
        return HP_MP102_ORIGINAL_APP_REQUEST_DISMISS_WORKER(self, workerId)
    end

    return false
end
HelperPersonnelApp.requestDismissWorker = hpOverride_HelperPersonnelApp_requestDismissWorker_1

local HP_MP102_ORIGINAL_APP_PROCESS_NETWORK_ACTION = hpLayer_HelperPersonnelApp_processNetworkAction_2
local function hpOverride_HelperPersonnelApp_processNetworkAction_1(self, actionName, targetId, connection, farmId, actionData)
    if self:isServerAuthority() and self.manager ~= nil and actionName == "hire" then
        local requestedFarmId = hpMP101NormalizeFarmId(farmId)
        if requestedFarmId == nil and self.getFarmIdFromConnection ~= nil then
            requestedFarmId = hpMP101NormalizeFarmId(self:getFarmIdFromConnection(connection))
        end

        if requestedFarmId ~= nil and self.manager.hasApplicantInFarm ~= nil and self.manager:hasApplicantInFarm(targetId, requestedFarmId) ~= true then
            local foundFarmId = nil
            for existingFarmId, data in pairs(self.manager.farms or {}) do
                for _, applicant in ipairs(data.applicants or {}) do
                    if tonumber(applicant.id) == tonumber(targetId) then
                        foundFarmId = hpMP101NormalizeFarmId(existingFarmId) or hpMP101NormalizeFarmId(data.farmId)
                        break
                    end
                end
                if foundFarmId ~= nil then
                    break
                end
            end

            Logging.warning("FS25_HelperPersonnel: Network request 'hire' diagnostics: Target=%s RequestedFarm=%s FoundFarm=%s", tostring(targetId), tostring(requestedFarmId), tostring(foundFarmId))
        end
    end

    if HP_MP102_ORIGINAL_APP_PROCESS_NETWORK_ACTION ~= nil then
        return HP_MP102_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, farmId, actionData)
    end

    return false
end
HelperPersonnelApp.processNetworkAction = hpOverride_HelperPersonnelApp_processNetworkAction_1

local HP_MP102_ORIGINAL_APP_FILTER_CLIENT_STATE = hpLayer_HelperPersonnelApp_hpMP101FilterClientStateToServerFarms_1
function HelperPersonnelApp:hpMP101FilterClientStateToServerFarms(state)
    if not self:isMultiplayerClient() or self.manager == nil or type(state) ~= "table" or type(state.farms) ~= "table" then
        if HP_MP102_ORIGINAL_APP_FILTER_CLIENT_STATE ~= nil then
            return HP_MP102_ORIGINAL_APP_FILTER_CLIENT_STATE(self, state)
        end
        return false
    end

    local currentFarmId = hpMP101NormalizeFarmId(self.manager.getCurrentFarmId ~= nil and self.manager:getCurrentFarmId() or nil)
    local allowed = {}
    for _, farmState in ipairs(state.farms) do
        local farmId = hpMP101NormalizeFarmId(farmState.farmId)
        if farmId ~= nil then
            allowed[farmId] = true
        end
    end

    local result = false
    if HP_MP102_ORIGINAL_APP_FILTER_CLIENT_STATE ~= nil then
        result = HP_MP102_ORIGINAL_APP_FILTER_CLIENT_STATE(self, state) == true
    end

    if currentFarmId ~= nil and allowed[currentFarmId] ~= true and self.manager.createFarmData ~= nil and self.manager.bindFarmData ~= nil then
        local data = self.manager:createFarmData(currentFarmId)
        data.applicantMarketInitialized = true
        self.manager.farms = self.manager.farms or {}
        self.manager.farms[currentFarmId] = data
        self.manager:bindFarmData(data)
        return true
    end

    return result
end
