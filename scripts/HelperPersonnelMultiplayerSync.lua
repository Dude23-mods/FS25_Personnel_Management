

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.STATE_VERSION = 14
HelperPersonnelNetwork.ACTION_SELECT_WORKER = "selectWorker"

local function hpSyncFarmIdBits()
    if FarmManager ~= nil and FarmManager.FARM_ID_SEND_NUM_BITS ~= nil then
        return FarmManager.FARM_ID_SEND_NUM_BITS
    end

    return 8
end

function HelperPersonnelNetwork.writeFarmId(streamId, farmId)
    farmId = tonumber(farmId) or 1
    streamWriteUIntN(streamId, farmId, hpSyncFarmIdBits())
end

function HelperPersonnelNetwork.readFarmId(streamId)
    return streamReadUIntN(streamId, hpSyncFarmIdBits())
end

function HelperPersonnelNetwork.writeOptionalInt(streamId, value)
    value = tonumber(value)
    streamWriteBool(streamId, value ~= nil)
    if value ~= nil then
        streamWriteInt32(streamId, math.floor(value + 0.5))
    end
end

function HelperPersonnelNetwork.readOptionalInt(streamId)
    if streamReadBool(streamId) then
        return streamReadInt32(streamId)
    end

    return nil
end

function HelperPersonnelNetwork.writeOptionalFloat(streamId, value)
    value = tonumber(value)
    streamWriteBool(streamId, value ~= nil)
    if value ~= nil then
        streamWriteFloat32(streamId, value)
    end
end

function HelperPersonnelNetwork.readOptionalFloat(streamId)
    if streamReadBool(streamId) then
        return streamReadFloat32(streamId)
    end

    return nil
end

function HelperPersonnelNetwork.writeConfigState(streamId, config)
    config = config or {}

    streamWriteBool(streamId, config.gameplayEffectsEnabled ~= false)
    streamWriteBool(streamId, config.experienceEffectsEnabled ~= false)
    streamWriteBool(streamId, config.speedEffectEnabled ~= false)
    streamWriteBool(streamId, config.wearEffectEnabled ~= false)
    streamWriteBool(streamId, config.consumablesEffectEnabled ~= false)
    streamWriteBool(streamId, config.fuelEffectEnabled ~= false)
    streamWriteBool(streamId, config.reliabilityEffectsEnabled ~= false)
    streamWriteBool(streamId, config.personnelEffectsEnabled ~= false)
    streamWriteBool(streamId, config.loyaltyEffectsEnabled ~= false)
    streamWriteBool(streamId, config.nightWorkLoyaltyEffectEnabled ~= false)
    streamWriteBool(streamId, config.economicEffectsEnabled ~= false)
    streamWriteBool(streamId, config.individualWagesEnabled ~= false)
    streamWriteFloat32(streamId, tonumber(config.standardBaseMonthlyWage) or (HelperPersonnelConfig ~= nil and HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE or 2500))
end

function HelperPersonnelNetwork.readConfigState(streamId, version)
    local state = {
        gameplayEffectsEnabled = streamReadBool(streamId) == true,
        experienceEffectsEnabled = streamReadBool(streamId) == true,
        speedEffectEnabled = streamReadBool(streamId) == true,
        wearEffectEnabled = streamReadBool(streamId) == true,
        consumablesEffectEnabled = streamReadBool(streamId) == true,
        fuelEffectEnabled = streamReadBool(streamId) == true,
        reliabilityEffectsEnabled = streamReadBool(streamId) == true
    }

    if (version or 0) >= 6 then
        state.personnelEffectsEnabled = streamReadBool(streamId) == true
        state.loyaltyEffectsEnabled = streamReadBool(streamId) == true
        state.nightWorkLoyaltyEffectEnabled = streamReadBool(streamId) == true
    else
        state.personnelEffectsEnabled = true
        state.loyaltyEffectsEnabled = true
        state.nightWorkLoyaltyEffectEnabled = true
    end

    state.economicEffectsEnabled = streamReadBool(streamId) == true
    state.individualWagesEnabled = streamReadBool(streamId) == true
    state.standardBaseMonthlyWage = streamReadFloat32(streamId) or (HelperPersonnelConfig ~= nil and HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE or 2500)

    return state
end

function HelperPersonnelNetwork.writePersonArray(streamId, people)
    people = people or {}
    streamWriteInt32(streamId, #people)

    for _, person in ipairs(people) do
        HelperPersonnelNetwork.writePerson(streamId, person)
    end
end

function HelperPersonnelNetwork.readPersonArray(streamId, version)
    local people = {}
    local count = math.min(HelperPersonnelNetwork.MAX_NETWORK_ARRAY or 100000, math.max(0, streamReadInt32(streamId) or 0))

    for _ = 1, count do
        table.insert(people, HelperPersonnelNetwork.readPerson(streamId, version))
    end

    return people
end

function HelperPersonnelNetwork.writeAssignment(streamId, assignment)
    assignment = assignment or {}
    streamWriteInt32(streamId, tonumber(assignment.workerId) or 0)
    HelperPersonnelNetwork.writeString(streamId, assignment.vehicleKey)
    HelperPersonnelNetwork.writeString(streamId, assignment.vehicleName)
    HelperPersonnelNetwork.writeOptionalInt(streamId, assignment.helperIndex)
    HelperPersonnelNetwork.writeOptionalInt(streamId, assignment.baseHelperIndex)
    HelperPersonnelNetwork.writeOptionalFloat(streamId, assignment.currentJobElapsedMs)
end

function HelperPersonnelNetwork.readAssignment(streamId)
    return {
        workerId = streamReadInt32(streamId),
        vehicleKey = HelperPersonnelNetwork.readString(streamId),
        vehicleName = HelperPersonnelNetwork.readString(streamId),
        helperIndex = HelperPersonnelNetwork.readOptionalInt(streamId),
        baseHelperIndex = HelperPersonnelNetwork.readOptionalInt(streamId),
        currentJobElapsedMs = HelperPersonnelNetwork.readOptionalFloat(streamId)
    }
end

function HelperPersonnelNetwork.writeAssignmentArray(streamId, assignments)
    assignments = assignments or {}
    streamWriteInt32(streamId, #assignments)

    for _, assignment in ipairs(assignments) do
        HelperPersonnelNetwork.writeAssignment(streamId, assignment)
    end
end

function HelperPersonnelNetwork.readAssignmentArray(streamId)
    local assignments = {}
    local count = math.min(HelperPersonnelNetwork.MAX_NETWORK_ARRAY or 100000, math.max(0, streamReadInt32(streamId) or 0))

    for _ = 1, count do
        table.insert(assignments, HelperPersonnelNetwork.readAssignment(streamId))
    end

    return assignments
end

function HelperPersonnelNetwork.writeFarmState(streamId, farmState)
    farmState = farmState or {}

    HelperPersonnelNetwork.writeFarmId(streamId, farmState.farmId or 1)
    streamWriteUInt8(streamId, farmState.employerReputation or 50)
    streamWriteString(streamId, farmState.lastActionText or "")
    streamWriteString(streamId, farmState.lastReputationChangeText or "")
    streamWriteString(streamId, farmState.lastPayrollText or "")
    streamWriteFloat32(streamId, farmState.lastPayrollAmount or 0)
    streamWriteFloat32(streamId, farmState.totalPayrollPaid or 0)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.dismissalPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.dismissalYear)
    streamWriteInt32(streamId, farmState.monthlyDismissals or 0)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.lastApplicantPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.lastApplicantYear)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.lastLoyaltyDailyCheckMinute)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.lastSicknessDailyCheckMinute)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.sicknessCurrentDay)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.sicknessDayPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.sicknessDayYear)
    streamWriteInt32(streamId, tonumber(farmState.pendingPayrollLoyaltyDelta) or 0)
    streamWriteBool(streamId, farmState.applicantMarketInitialized == true)

    HelperPersonnelNetwork.writePersonArray(streamId, farmState.workers or {})
    HelperPersonnelNetwork.writePersonArray(streamId, farmState.applicants or {})
    HelperPersonnelNetwork.writeHistory(streamId, farmState.reputationHistory or {})
    HelperPersonnelNetwork.writeHistory(streamId, farmState.actionHistory or {})

    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.selectedWorkerId)
    HelperPersonnelNetwork.writeString(streamId, farmState.selectedVehicleKey)
    HelperPersonnelNetwork.writeString(streamId, farmState.selectedVehicleName)
    HelperPersonnelNetwork.writeAssignmentArray(streamId, farmState.activeAssignments or {})
end

function HelperPersonnelNetwork.readFarmState(streamId, version)
    local farmState = {}

    farmState.farmId = HelperPersonnelNetwork.readFarmId(streamId)
    farmState.employerReputation = streamReadUInt8(streamId)
    farmState.lastActionText = streamReadString(streamId)
    farmState.lastReputationChangeText = streamReadString(streamId)
    farmState.lastPayrollText = streamReadString(streamId)
    farmState.lastPayrollAmount = streamReadFloat32(streamId)
    farmState.totalPayrollPaid = streamReadFloat32(streamId)
    farmState.dismissalPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    farmState.dismissalYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    farmState.monthlyDismissals = streamReadInt32(streamId)
    farmState.lastApplicantPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    farmState.lastApplicantYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    if (version or 0) >= 6 then
        farmState.lastLoyaltyDailyCheckMinute = HelperPersonnelNetwork.readOptionalInt(streamId)
        if (version or 0) >= 7 then
            farmState.lastSicknessDailyCheckMinute = HelperPersonnelNetwork.readOptionalInt(streamId)
            farmState.sicknessCurrentDay = HelperPersonnelNetwork.readOptionalInt(streamId)
            farmState.sicknessDayPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
            farmState.sicknessDayYear = HelperPersonnelNetwork.readOptionalInt(streamId)
        end
        farmState.pendingPayrollLoyaltyDelta = streamReadInt32(streamId) or 0
    else
        farmState.pendingPayrollLoyaltyDelta = 0
    end
    if (version or 0) >= 4 then
        farmState.applicantMarketInitialized = streamReadBool(streamId) == true
    else
        farmState.applicantMarketInitialized = false
    end

    farmState.workers = HelperPersonnelNetwork.readPersonArray(streamId, version)
    farmState.applicants = HelperPersonnelNetwork.readPersonArray(streamId, version)
    farmState.reputationHistory = HelperPersonnelNetwork.readHistory(streamId)
    farmState.actionHistory = HelperPersonnelNetwork.readHistory(streamId)

    if (version or 0) >= 3 then
        farmState.selectedWorkerId = HelperPersonnelNetwork.readOptionalInt(streamId)
        farmState.selectedVehicleKey = HelperPersonnelNetwork.readString(streamId)
        farmState.selectedVehicleName = HelperPersonnelNetwork.readString(streamId)
        farmState.activeAssignments = HelperPersonnelNetwork.readAssignmentArray(streamId)
    else
        farmState.activeAssignments = {}
    end

    return farmState
end

function HelperPersonnelNetwork.writeState(streamId, state)
    state = state or {}

    streamWriteUInt8(streamId, HelperPersonnelNetwork.STATE_VERSION)
    streamWriteInt32(streamId, state.nextPersonId or 1)
    streamWriteInt32(streamId, state.changeCounter or 0)
    HelperPersonnelNetwork.writeFarmId(streamId, state.activeFarmId or 1)
    HelperPersonnelNetwork.writeConfigState(streamId, state.config)

    local farms = state.farms or {}
    streamWriteInt32(streamId, #farms)
    for _, farmState in ipairs(farms) do
        HelperPersonnelNetwork.writeFarmState(streamId, farmState)
    end
end

function HelperPersonnelNetwork.readState(streamId)
    local version = streamReadUInt8(streamId)
    local state = { version = version, farms = {} }

    if version ~= nil and version >= 2 and version <= HelperPersonnelNetwork.STATE_VERSION then
        state.nextPersonId = streamReadInt32(streamId)
        state.changeCounter = streamReadInt32(streamId)
        state.activeFarmId = HelperPersonnelNetwork.readFarmId(streamId)
        if version >= 5 then
            state.config = HelperPersonnelNetwork.readConfigState(streamId, version)
        end

        local farmCount = math.min(HelperPersonnelNetwork.MAX_NETWORK_ARRAY or 100000, math.max(0, streamReadInt32(streamId) or 0))
        for _ = 1, farmCount do
            table.insert(state.farms, HelperPersonnelNetwork.readFarmState(streamId, version))
        end

        return state
    end

    state.nextPersonId = streamReadInt32(streamId)
    state.changeCounter = streamReadInt32(streamId)
    state.workers = HelperPersonnelNetwork.readPersonArray(streamId, 0)
    state.applicants = HelperPersonnelNetwork.readPersonArray(streamId, 0)
    state.employerReputation = streamReadUInt8(streamId)
    state.lastActionText = streamReadString(streamId)
    state.lastReputationChangeText = streamReadString(streamId)
    state.lastPayrollText = streamReadString(streamId)
    state.lastPayrollAmount = streamReadFloat32(streamId)
    state.totalPayrollPaid = streamReadFloat32(streamId)
    state.dismissalPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.dismissalYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.monthlyDismissals = streamReadInt32(streamId)
    state.lastApplicantPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.lastApplicantYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.reputationHistory = HelperPersonnelNetwork.readHistory(streamId)
    state.actionHistory = HelperPersonnelNetwork.readHistory(streamId)

    return state
end

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
        end
    end
end

local HP_V1540_ORIGINAL_MANAGER_GET_NETWORK_STATE = HelperPersonnelManager.getNetworkState
function HelperPersonnelManager:getNetworkState()
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
                    reputationHistory = self.copyHistoryForNetwork ~= nil and self:copyHistoryForNetwork(data.reputationHistory) or data.reputationHistory or {},
                    actionHistory = self.copyHistoryForNetwork ~= nil and self:copyHistoryForNetwork(data.actionHistory) or data.actionHistory or {},
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
function HelperPersonnelManager:applyNetworkState(state)
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
function HelperPersonnelApp:setPendingWorkerForVehicle(vehicle, workerId)
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

function HelperPersonnelApp:processNetworkSelection(workerId, farmId, vehicleKey, vehicleName, connection)
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
function HelperPersonnelApp:applyNetworkState(state)
    local applied = HP_V1540_ORIGINAL_APP_APPLY_NETWORK_STATE ~= nil and HP_V1540_ORIGINAL_APP_APPLY_NETWORK_STATE(self, state) or false

    if applied == true and self.helperBridge ~= nil and self.helperBridge.syncNetworkAssignmentsFromManager ~= nil then
        self.helperBridge:syncNetworkAssignmentsFromManager()
    end

    return applied
end

function HelperPersonnelHelperBridge:syncNetworkAssignmentsFromManager()
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

function HelperPersonnelHelperBridge:onJobStarted(job, workerId)
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

function HelperPersonnelHelperBridge:onJobStopped(job)
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

function HelperPersonnelApp:getFarmIdFromConnection(connection)
    if connection == nil then
        return nil
    end

    local candidates = {
        connection.farmId,
        connection.playerFarmId,
        connection.currentFarmId
    }

    if connection.player ~= nil then
        table.insert(candidates, connection.player.farmId)
        table.insert(candidates, hpV1550SafeCall(connection.player, "getFarmId"))
        table.insert(candidates, hpV1550SafeCall(connection.player, "getOwnerFarmId"))
    end

    if connection.user ~= nil then
        table.insert(candidates, connection.user.farmId)
        table.insert(candidates, hpV1550SafeCall(connection.user, "getFarmId"))
    end

    table.insert(candidates, hpV1550SafeCall(connection, "getFarmId"))
    table.insert(candidates, hpV1550SafeCall(connection, "getPlayerFarmId"))
    table.insert(candidates, hpV1550SafeCall(connection, "getCurrentFarmId"))

    local player = hpV1550SafeCall(connection, "getPlayer")
    if player ~= nil then
        table.insert(candidates, player.farmId)
        table.insert(candidates, hpV1550SafeCall(player, "getFarmId"))
    end

    local user = hpV1550SafeCall(connection, "getUser")
    if user ~= nil then
        table.insert(candidates, user.farmId)
        table.insert(candidates, hpV1550SafeCall(user, "getFarmId"))
    end

    for _, candidate in ipairs(candidates) do
        local farmId = hpV1550NormalizeFarmId(candidate)
        if farmId ~= nil then
            return farmId
        end
    end

    return nil
end

function HelperPersonnelApp:getStrictFarmIdForVehicle(vehicle)
    local rootVehicle = self.getRootVehicle ~= nil and self:getRootVehicle(vehicle) or vehicle
    if rootVehicle == nil then
        return nil
    end

    local farmId = nil
    if rootVehicle.getOwnerFarmId ~= nil then
        farmId = hpV1550SafeCall(rootVehicle, "getOwnerFarmId")
    end

    farmId = hpV1550NormalizeFarmId(farmId)
    if farmId ~= nil then
        return farmId
    end

    return hpV1550NormalizeFarmId(rootVehicle.ownerFarmId)
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

function HelperPersonnelApp:resolveAuthorizedFarmId(connection, requestedFarmId, vehicleFarmId, actionText)
    local requestFarmId = hpV1550NormalizeFarmId(requestedFarmId)
    local strictVehicleFarmId = hpV1550NormalizeFarmId(vehicleFarmId)
    local connectionFarmId = self:getFarmIdFromConnection(connection)

    if connection == nil then
        return true, strictVehicleFarmId or requestFarmId or (self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1), nil
    end

    if connectionFarmId ~= nil then
        if strictVehicleFarmId ~= nil and strictVehicleFarmId ~= connectionFarmId then
            hpV1550Warn("Netzwerkanfrage '%s' abgelehnt: Fahrzeug gehoert Hof %s, Verbindung gehoert Hof %s.", tostring(actionText or "?"), tostring(strictVehicleFarmId), tostring(connectionFarmId))
            return false, connectionFarmId, connectionFarmId
        end

        if requestFarmId ~= nil and requestFarmId ~= connectionFarmId then
            hpV1550Warn("Netzwerkanfrage '%s' abgelehnt: angeforderter Hof %s, Verbindung gehoert Hof %s.", tostring(actionText or "?"), tostring(requestFarmId), tostring(connectionFarmId))
            return false, connectionFarmId, connectionFarmId
        end

        return true, connectionFarmId, connectionFarmId
    end

    -- Security: the connection exists but its farm could not be resolved. Fail CLOSED —
    -- never fall back to the client-supplied farm id here, or a malicious/buggy client
    -- could act on a farm it does not own (hire/dismiss/train/pay on another farm).
    hpV1550Warn("Netzwerkanfrage '%s' abgelehnt: Hof der Verbindung nicht ermittelbar.", tostring(actionText or "?"))
    return false, nil, nil
end

function HelperPersonnelApp:validateNetworkActionTarget(actionName, targetId, farmId)
    if self.manager == nil then
        return false
    end

    if actionName == HelperPersonnelNetwork.ACTION_HIRE then
        return self.manager.hasApplicantInFarm ~= nil and self.manager:hasApplicantInFarm(targetId, farmId) == true
    elseif actionName == HelperPersonnelNetwork.ACTION_DISMISS then
        return self.manager.hasWorkerInFarm ~= nil and self.manager:hasWorkerInFarm(targetId, farmId) == true
    end

    return false
end

local HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_ACTION = HelperPersonnelApp.processNetworkAction
function HelperPersonnelApp:processNetworkAction(actionName, targetId, connection, farmId)
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
        hpV1550Warn("Netzwerkanfrage '%s' abgelehnt: Ziel %s gehoert nicht zu Hof %s.", tostring(actionName), tostring(targetId), tostring(authorizedFarmId))
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
    elseif HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_ACTION ~= nil then
        changed = HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, authorizedFarmId) == true
    end

    if changed then
        self:syncNetworkStateToClients()
    elseif connection ~= nil then
        self:sendNetworkStateToConnection(connection)
    end

    return changed
end

local HP_V1550_ORIGINAL_APP_PROCESS_NETWORK_SELECTION = HelperPersonnelApp.processNetworkSelection
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
            hpV1550Warn("Mitarbeiterauswahl abgelehnt: Mitarbeiter %s gehoert nicht zu Hof %s.", tostring(workerId), tostring(authorizedFarmId))
            if connection ~= nil then
                self:sendNetworkStateToConnection(connection)
            end
            return false
        end

        if self.manager.canSelectWorkerForFarm ~= nil and not self.manager:canSelectWorkerForFarm(workerId, authorizedFarmId) then
            hpV1550Warn("Mitarbeiterauswahl abgelehnt: Mitarbeiter %s ist fuer Hof %s nicht verfuegbar.", tostring(workerId), tostring(authorizedFarmId))
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
function HelperPersonnelHelperBridge:canUseWorkerForJob(workerId, job)
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
        hpV1550Warn("KI-Job mit Mitarbeiter %s abgelehnt: Fahrzeug gehoert Hof %s, Mitarbeiter gehoert Hof %s.", tostring(workerId), tostring(vehicleFarmId), tostring(workerFarmId))
        return false
    end

    return true
end

local HP_V1550_ORIGINAL_SEND_SELECTED_AI_JOB = HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.sendSelectedAIJob or nil
if HelperPersonnelAIStartHooks ~= nil and HP_V1550_ORIGINAL_SEND_SELECTED_AI_JOB ~= nil then
    function HelperPersonnelAIStartHooks.sendSelectedAIJob(vehicle, workerId, fallbackJob, fallbackFarmId)
        local app = g_helperPersonnelApp
        if app ~= nil and app.manager ~= nil then
            local workerFarmId = app.manager.getWorkerFarmId ~= nil and hpV1550NormalizeFarmId(app.manager:getWorkerFarmId(workerId)) or nil
            local vehicleFarmId = app.getStrictFarmIdForVehicle ~= nil and hpV1550NormalizeFarmId(app:getStrictFarmIdForVehicle(vehicle)) or hpV1550NormalizeFarmId(fallbackFarmId)

            if workerFarmId ~= nil and vehicleFarmId ~= nil and workerFarmId ~= vehicleFarmId then
                if app.showPlayerMessage ~= nil then
                    app:showPlayerMessage("ui_selectionWorkerUnavailable")
                end
                hpV1550Warn("Lokale Mitarbeiterauswahl abgelehnt: Fahrzeug gehoert Hof %s, Mitarbeiter gehoert Hof %s.", tostring(vehicleFarmId), tostring(workerFarmId))
                return false
            end
        end

        return HP_V1550_ORIGINAL_SEND_SELECTED_AI_JOB(vehicle, workerId, fallbackJob, fallbackFarmId)
    end
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
    if connection == nil then
        return nil
    end

    local candidates = {
        connection.farmId,
        connection.playerFarmId,
        connection.currentFarmId,
        connection.ownerFarmId
    }

    local function addPlayerLike(object)
        if object == nil then
            return
        end
        table.insert(candidates, object.farmId)
        table.insert(candidates, object.ownerFarmId)
        table.insert(candidates, hpV1550SafeCall(object, "getFarmId"))
        table.insert(candidates, hpV1550SafeCall(object, "getOwnerFarmId"))
    end

    addPlayerLike(connection.player)
    addPlayerLike(connection.user)
    addPlayerLike(hpV1550SafeCall(connection, "getPlayer"))
    addPlayerLike(hpV1550SafeCall(connection, "getUser"))

    table.insert(candidates, hpV1550SafeCall(connection, "getFarmId"))
    table.insert(candidates, hpV1550SafeCall(connection, "getPlayerFarmId"))
    table.insert(candidates, hpV1550SafeCall(connection, "getCurrentFarmId"))
    table.insert(candidates, hpV1550SafeCall(connection, "getOwnerFarmId"))

    local userId = connection.userId or connection.playerUserId or hpV1550SafeCall(connection, "getUserId") or hpV1550SafeCall(connection, "getPlayerUserId")
    local userManager = g_currentMission ~= nil and g_currentMission.userManager or nil
    if userManager ~= nil then
        addPlayerLike(hpV1550SafeCall(userManager, "getUserByConnection", connection))
        if userId ~= nil then
            addPlayerLike(hpV1550SafeCall(userManager, "getUserByUserId", userId))
            addPlayerLike(hpV1550SafeCall(userManager, "getUserById", userId))
        end

        if userId ~= nil and userManager.users ~= nil then
            for _, user in pairs(userManager.users) do
                if user ~= nil and (user.id == userId or user.userId == userId or tostring(user.id) == tostring(userId) or tostring(user.userId) == tostring(userId)) then
                    addPlayerLike(user)
                end
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        local farmId = hpV1550NormalizeFarmId(candidate)
        if farmId ~= nil then
            return farmId
        end
    end

    return nil
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
function HelperPersonnelApp:load()

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
local HP_V1560_ORIGINAL_APP_REQUEST_NETWORK_STATE = HelperPersonnelApp.requestNetworkState
function HelperPersonnelApp:requestNetworkState()
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

local HP_V1560_ORIGINAL_APP_APPLY_NETWORK_STATE = HelperPersonnelApp.applyNetworkState
function HelperPersonnelApp:applyNetworkState(state)
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
    function HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job)
        local app = g_helperPersonnelApp
        if app ~= nil and app.isMultiplayerClient ~= nil and app:isMultiplayerClient() then
            if app.hpJoinSyncApplied ~= true or app.activeJobsRestoreDone ~= true then
                return true
            end
        end

        return HP_V1561_ORIGINAL_AIJOB_CAN_USE_WORKER_FOR_JOB(workerId, job)
    end
end

local HP_V1560_ORIGINAL_APP_UPDATE = HelperPersonnelApp.update
function HelperPersonnelApp:update(dt)
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
function HelperPersonnelHelperBridge:getWorkerIdByVehicleKey(vehicleKey)
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

local HP_V1562_ORIGINAL_BRIDGE_SYNC_ASSIGNMENTS = HelperPersonnelHelperBridge.syncNetworkAssignmentsFromManager
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
    function HelperPersonnelAIStartHooks.handleVehicleStart(vehicle, superFunc, ...)
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
end

local HP_V1562_ORIGINAL_BRIDGE_ON_JOB_STOPPED = HelperPersonnelHelperBridge.onJobStopped
function HelperPersonnelHelperBridge:onJobStopped(job)

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

local HP_V1562_ORIGINAL_APP_APPLY_NETWORK_STATE = HelperPersonnelApp.applyNetworkState
function HelperPersonnelApp:applyNetworkState(state)
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
function HelperPersonnelApp:finishActiveJobRestore()
    if HP_V1563_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE ~= nil then
        HP_V1563_ORIGINAL_APP_FINISH_ACTIVE_JOB_RESTORE(self)
    end

    if self:isServerAuthority() and self.manager ~= nil and self.manager.hp1563CleanupStaleActiveAssignments ~= nil then
        local lookup = self.hp1563BuildActiveJobLookup ~= nil and self:hp1563BuildActiveJobLookup() or nil
        local changed = self.manager:hp1563CleanupStaleActiveAssignments(lookup) == true
        if changed and self.syncNetworkStateToClients ~= nil then
            self:syncNetworkStateToClients()
        end
    end
end

local HP_V1563_ORIGINAL_MANAGER_GET_OR_CREATE_FARM_DATA = HelperPersonnelManager.getOrCreateFarmData
function HelperPersonnelManager:getOrCreateFarmData(farmId, initializeApplicants)
    if self.app ~= nil and self.app.isMultiplayerClient ~= nil and self.app:isMultiplayerClient() then
        initializeApplicants = false
    end

    if HP_V1563_ORIGINAL_MANAGER_GET_OR_CREATE_FARM_DATA ~= nil then
        return HP_V1563_ORIGINAL_MANAGER_GET_OR_CREATE_FARM_DATA(self, farmId, initializeApplicants)
    end

    return nil
end

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
function HelperPersonnelApp:finishActiveJobRestore()
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

function HelperPersonnelAIJobHooks.onAIJobStart(job, superFunc, farmId, ...)
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

function HelperPersonnelAIJobHooks.onAISystemStartJob(aiSystem, superFunc, job, farmId, ...)
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
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: KI-Start wurde nicht als aktiver Einsatz uebernommen, weil der Job sofort wieder beendet wurde")
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
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: KI-Start wurde nicht als aktiver Einsatz uebernommen, weil der Job sofort wieder beendet wurde")
            end
        end
    end

    return result
end

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

function HelperPersonnelApp:hp1564TryRestartRestoredAssignment(assignment)
    if assignment == nil or assignment.workerId == nil or self.manager == nil then
        return false, false
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

    if vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() then
        assignment.consumed = true
        return false, true
    end

    if vehicle.getStartableAIJob == nil then
        assignment.hp1564RestartFailed = true
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: Fahrzeug hat keinen startbaren KI-Job", tostring(assignment.workerId))
        return false, true
    end

    local okJob, aiJob = pcall(vehicle.getStartableAIJob, vehicle)
    if not okJob or aiJob == nil then
        assignment.hp1564RestartFailed = true
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: kein startbarer KI-Job am Fahrzeug", tostring(assignment.workerId))
        return false, true
    end

    self:prepareAIJobForWorker(aiJob, vehicle, assignment.workerId)

    local farmId = self:hp1564GetFarmIdForRestoredAssignment(assignment, vehicle)
    local okStart, result = pcall(function()
        return g_currentMission.aiSystem:startJob(aiJob, farmId)
    end)

    if not okStart then
        hpV1564ClearPendingStart(self, aiJob)
        assignment.hp1564RestartFailed = true
        Logging.warning("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: %s", tostring(assignment.workerId), tostring(result))
        return false, true
    end

    local known, active = hpV1564GetJobActiveState(self, aiJob)
    if result ~= false and ((known and active) or not known) then
        assignment.consumed = true
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s wurde serverseitig erneut gestartet", tostring(assignment.workerId))
        return true, true
    end

    hpV1564ClearPendingStart(self, aiJob)
    assignment.hp1564RestartFailed = true
    HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s wurde nicht fortgesetzt, weil der Job nicht aktiv blieb", tostring(assignment.workerId))
    return false, true
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
function HelperPersonnelApp:restoreActiveAIJobs()
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
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Restore-Start fuer Mitarbeiter-ID %s bereinigt: %s", tostring(workerId), tostring(reason))
    end
end

if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.finalizeStartedJob ~= nil then
    local HP_V1565_ORIGINAL_AIJOB_FINALIZE_STARTED_JOB = HelperPersonnelAIJobHooks.finalizeStartedJob
    function HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
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
end

if HelperPersonnelHelperBridge ~= nil and HelperPersonnelHelperBridge.attachRestoredJob ~= nil then
    local HP_V1565_ORIGINAL_BRIDGE_ATTACH_RESTORED_JOB = HelperPersonnelHelperBridge.attachRestoredJob
    function HelperPersonnelHelperBridge:attachRestoredJob(job, workerId)
        local result = HP_V1565_ORIGINAL_BRIDGE_ATTACH_RESTORED_JOB ~= nil and HP_V1565_ORIGINAL_BRIDGE_ATTACH_RESTORED_JOB(self, job, workerId) == true
        if result and job ~= nil then
            job.hpHelperPersonnelFinalized = true
            if job.hp1565RestoreRestart == true then
                job.hp1565RestoreConfirmed = true
            end
        end
        return result
    end
end

if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.onAIJobStop ~= nil then
    local HP_V1565_ORIGINAL_AIJOB_STOP = HelperPersonnelAIJobHooks.onAIJobStop
    function HelperPersonnelAIJobHooks.onAIJobStop(job, aiMessage)
        local app = g_helperPersonnelApp
        local workerId = hpV1565GetWorkerIdFromJob(job)

        if job ~= nil and workerId ~= nil and job.hpHelperPersonnelFinalized ~= true then
            if app ~= nil and app.hp1565ClearFailedRestoreJob ~= nil then
                app:hp1565ClearFailedRestoreJob(job, workerId, job.hp1565RestoreAssignment, "Job wurde nicht als aktiver Einsatz bestaetigt")
            end
            return
        end

        if job ~= nil and job.hp1565RestoreRestart == true then
            local now = hpV1565GetTimeMs()
            local protectUntil = job.hp1565RestoreProtectUntil or 0
            if now <= protectUntil then
                if app ~= nil and app.hp1565ClearFailedRestoreJob ~= nil then
                    app:hp1565ClearFailedRestoreJob(job, workerId, job.hp1565RestoreAssignment, "Restore-Job endete waehrend der Schutzfrist")
                end
                return
            end
        end

        return HP_V1565_ORIGINAL_AIJOB_STOP(job, aiMessage)
    end
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
                self:hp1565ClearFailedRestoreJob(job, record.workerId, record.assignment, "neu gestarteter Job blieb nicht aktiv")
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
            self:hp1565ClearFailedRestoreJob(nil, assignment.workerId, assignment, "Fahrzeug hat keinen startbaren KI-Job")
        end
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: Fahrzeug hat keinen startbaren KI-Job", tostring(assignment.workerId))
        return false, true
    end

    local okJob, aiJob = pcall(vehicle.getStartableAIJob, vehicle)
    if not okJob or aiJob == nil then
        assignment.hp1564RestartFailed = true
        if self.hp1565ClearFailedRestoreJob ~= nil then
            self:hp1565ClearFailedRestoreJob(nil, assignment.workerId, assignment, "kein startbarer KI-Job am Fahrzeug")
        end
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: kein startbarer KI-Job am Fahrzeug", tostring(assignment.workerId))
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
            self:hp1565ClearFailedRestoreJob(aiJob, assignment.workerId, assignment, okStart and "AISystem.startJob lieferte false" or tostring(result))
        end
        if not okStart then
            Logging.warning("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: %s", tostring(assignment.workerId), tostring(result))
        else
            HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s konnte nicht neu gestartet werden: AISystem.startJob lieferte false", tostring(assignment.workerId))
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

    HelperPersonnel.debugInfo("FS25_HelperPersonnel: Gespeicherter KI-Job fuer Mitarbeiter-ID %s wurde zum Wiederanlauf angemeldet", tostring(assignment.workerId))
    return true, true
end

local HP_V1565_ORIGINAL_APP_UPDATE = HelperPersonnelApp.update
function HelperPersonnelApp:update(dt)
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
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: Beendete oder veraltete Mitarbeitereinsaetze wurden bereinigt")
    end
end

local HP_V15611_ORIGINAL_APP_UPDATE = HelperPersonnelApp.update
function HelperPersonnelApp:update(dt)
    if HP_V15611_ORIGINAL_APP_UPDATE ~= nil then
        HP_V15611_ORIGINAL_APP_UPDATE(self, dt)
    end

    if self.hp15611UpdateFinishedJobAudit ~= nil then
        self:hp15611UpdateFinishedJobAudit(dt)
    end
end

if HelperPersonnelHelperBridge ~= nil and HelperPersonnelHelperBridge.onJobStopped ~= nil then
    local HP_V15182_ORIGINAL_BRIDGE_ON_JOB_STOPPED = HelperPersonnelHelperBridge.onJobStopped
    function HelperPersonnelHelperBridge:onJobStopped(job)
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

        local result = HP_V15182_ORIGINAL_BRIDGE_ON_JOB_STOPPED(self, job)

        if workerId ~= nil then
            job.helperPersonnelWorkerId = workerId
            job.hpHelperPersonnelStopHandled = true
        end

        return result
    end
end

local function hpMP101NormalizeFarmId(farmId)
    farmId = tonumber(farmId)
    if farmId == nil or farmId <= 0 then
        return nil
    end

    farmId = math.floor(farmId + 0.5)
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

    if FarmManager ~= nil and FarmManager.SINGLEPLAYER_FARM_ID ~= nil then
        hpMP101AddFarmId(result, FarmManager.SINGLEPLAYER_FARM_ID)
    end

    local managers = {}
    if g_farmManager ~= nil then
        table.insert(managers, g_farmManager)
    end
    if g_currentMission ~= nil and g_currentMission.farmManager ~= nil and g_currentMission.farmManager ~= g_farmManager then
        table.insert(managers, g_currentMission.farmManager)
    end

    local function scanFarmTable(farms)
        if type(farms) ~= "table" then
            return
        end

        for key, farm in pairs(farms) do
            hpMP101AddFarmId(result, key)
            if type(farm) == "table" then
                hpMP101AddFarmId(result, farm.farmId)
                hpMP101AddFarmId(result, farm.id)
            end
        end
    end

    for _, manager in ipairs(managers) do
        scanFarmTable(manager.farms)
        scanFarmTable(manager.farmsById)
        scanFarmTable(manager.farmIdToFarm)

        if type(manager.farmIds) == "table" then
            for _, farmId in pairs(manager.farmIds) do
                hpMP101AddFarmId(result, farmId)
            end
        end
    end

    if g_currentMission ~= nil then
        if g_currentMission.player ~= nil then
            hpMP101AddFarmId(result, g_currentMission.player.farmId)
        end
        if g_currentMission.controlPlayer ~= nil then
            hpMP101AddFarmId(result, g_currentMission.controlPlayer.farmId)
        end
    end

    table.sort(result.ids, function(a, b) return tonumber(a) < tonumber(b) end)
    return result.ids
end

function HelperPersonnelManager:hpMP101EnsureFarmDataForFarm(farmId)
    farmId = hpMP101NormalizeFarmId(farmId)
    if farmId == nil then
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
    local changed = false

    for _, farmId in ipairs(hpMP101CollectKnownFarmIds()) do
        local hadData = self.farms[farmId] ~= nil
        if self:hpMP101EnsureFarmDataForFarm(farmId) then
            changed = changed or not hadData
        end
    end

    if previousData ~= nil and self.bindFarmData ~= nil then
        self:bindFarmData(previousData)
    elseif self.refreshFarmContext ~= nil then
        self:refreshFarmContext()
    end

    return changed
end

local HP_MP101_ORIGINAL_MANAGER_GET_NETWORK_STATE = HelperPersonnelManager.getNetworkState
function HelperPersonnelManager:getNetworkState()
    if g_server ~= nil or (g_currentMission ~= nil and g_currentMission.getIsServer ~= nil and g_currentMission:getIsServer() == true) then
        if self.hpMP101EnsureFarmDataForKnownFarms ~= nil then
            self:hpMP101EnsureFarmDataForKnownFarms()
        end
    end

    if HP_MP101_ORIGINAL_MANAGER_GET_NETWORK_STATE ~= nil then
        return HP_MP101_ORIGINAL_MANAGER_GET_NETWORK_STATE(self)
    end

    return nil
end

local HP_MP101_ORIGINAL_APP_SEND_NETWORK_STATE_TO_CONNECTION = HelperPersonnelApp.sendNetworkStateToConnection
function HelperPersonnelApp:sendNetworkStateToConnection(connection)
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

local HP_MP101_ORIGINAL_APP_SYNC_NETWORK_STATE_TO_CLIENTS = HelperPersonnelApp.syncNetworkStateToClients
function HelperPersonnelApp:syncNetworkStateToClients()
    if self:isServerAuthority() and self.manager ~= nil and self.manager.hpMP101EnsureFarmDataForKnownFarms ~= nil then
        self.manager:hpMP101EnsureFarmDataForKnownFarms()
    end

    if HP_MP101_ORIGINAL_APP_SYNC_NETWORK_STATE_TO_CLIENTS ~= nil then
        return HP_MP101_ORIGINAL_APP_SYNC_NETWORK_STATE_TO_CLIENTS(self)
    end

    return false
end

function HelperPersonnelApp:hpMP101FilterClientStateToServerFarms(state)
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

local HP_MP101_ORIGINAL_APP_APPLY_NETWORK_STATE = HelperPersonnelApp.applyNetworkState
function HelperPersonnelApp:applyNetworkState(state)
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
            if self.frame ~= nil and self.frame.refresh ~= nil then
                self.frame:refresh()
            end
        end
    end

    return applied
end

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
function HelperPersonnelApp:requestHireApplicant(applicantId)
    if self:isMultiplayerClient() then
        if self.hpJoinSyncApplied ~= true or self:hpMP101ClientHasSyncedApplicant(applicantId) ~= true then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            if self.frame ~= nil and self.frame.refresh ~= nil then
                self.frame:refresh()
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
function HelperPersonnelApp:requestDismissWorker(workerId)
    if self:isMultiplayerClient() then
        if self.hpJoinSyncApplied ~= true or self:hpMP101ClientHasSyncedWorker(workerId) ~= true then
            if self.requestNetworkState ~= nil then
                self:requestNetworkState()
            end
            if self.frame ~= nil and self.frame.refresh ~= nil then
                self.frame:refresh()
            end
            return false
        end
    end

    if HP_MP101_ORIGINAL_APP_REQUEST_DISMISS_WORKER ~= nil then
        return HP_MP101_ORIGINAL_APP_REQUEST_DISMISS_WORKER(self, workerId)
    end

    return false
end

local HP_MP101_ORIGINAL_APP_PROCESS_NETWORK_ACTION = HelperPersonnelApp.processNetworkAction
function HelperPersonnelApp:processNetworkAction(actionName, targetId, connection, farmId)
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
        return HP_MP101_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, farmId)
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
function HelperPersonnelManager:ensureInitialApplicantMarketForFarmData(data)
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

local HP_MP102_ORIGINAL_MANAGER_INITIALIZE_NEW_MARKET = HelperPersonnelManager.initializeNewApplicantMarket
function HelperPersonnelManager:initializeNewApplicantMarket()
    if hpMP102IsMultiplayerClientRuntime() then
        self.applicants = self.applicants or {}
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_INITIALIZE_NEW_MARKET ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_INITIALIZE_NEW_MARKET(self)
    end

    return 0
end

local HP_MP102_ORIGINAL_MANAGER_ENSURE_APPLICANT_BUFFER = HelperPersonnelManager.ensureApplicantBuffer
function HelperPersonnelManager:ensureApplicantBuffer(minimumCount, targetCount)
    if hpMP102IsMultiplayerClientRuntime() then
        self.applicants = self.applicants or {}
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_ENSURE_APPLICANT_BUFFER ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_ENSURE_APPLICANT_BUFFER(self, minimumCount, targetCount)
    end

    return 0
end

local HP_MP102_ORIGINAL_MANAGER_GENERATE_MONTHLY_APPLICANTS = HelperPersonnelManager.generateMonthlyApplicants
function HelperPersonnelManager:generateMonthlyApplicants(forceAtLeastOne)
    if hpMP102IsMultiplayerClientRuntime() then
        self.applicants = self.applicants or {}
        return 0
    end

    if HP_MP102_ORIGINAL_MANAGER_GENERATE_MONTHLY_APPLICANTS ~= nil then
        return HP_MP102_ORIGINAL_MANAGER_GENERATE_MONTHLY_APPLICANTS(self, forceAtLeastOne)
    end

    return 0
end

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

local HP_MP102_ORIGINAL_APP_REQUEST_HIRE_APPLICANT = HelperPersonnelApp.requestHireApplicant
function HelperPersonnelApp:requestHireApplicant(applicantId)
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
            if self.frame ~= nil and self.frame.refresh ~= nil then
                self.frame:refresh()
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

local HP_MP102_ORIGINAL_APP_REQUEST_DISMISS_WORKER = HelperPersonnelApp.requestDismissWorker
function HelperPersonnelApp:requestDismissWorker(workerId)
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
            if self.frame ~= nil and self.frame.refresh ~= nil then
                self.frame:refresh()
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

local HP_MP102_ORIGINAL_APP_PROCESS_NETWORK_ACTION = HelperPersonnelApp.processNetworkAction
function HelperPersonnelApp:processNetworkAction(actionName, targetId, connection, farmId)
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

            Logging.warning("FS25_HelperPersonnel: Netzwerkanfrage 'hire' Diagnose: Ziel=%s angefragterHof=%s gefundenerHof=%s", tostring(targetId), tostring(requestedFarmId), tostring(foundFarmId))
        end
    end

    if HP_MP102_ORIGINAL_APP_PROCESS_NETWORK_ACTION ~= nil then
        return HP_MP102_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, farmId)
    end

    return false
end

local HP_MP102_ORIGINAL_APP_FILTER_CLIENT_STATE = HelperPersonnelApp.hpMP101FilterClientStateToServerFarms
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
