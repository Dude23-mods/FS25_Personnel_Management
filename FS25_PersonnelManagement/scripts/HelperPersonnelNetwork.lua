-- Multiplayer-Grundlage fuer FS25_HelperPersonnel.
-- Der Server bleibt die einzige Instanz, die Personal-, Bewerber- und Monatsdaten veraendert.
-- Clients senden nur Bedienanfragen und erhalten danach einen vollstaendigen Zustandsabgleich.

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.ACTION_HIRE = "hire"
HelperPersonnelNetwork.ACTION_DISMISS = "dismiss"
HelperPersonnelNetwork.ACTION_TRAIN_WORKER = "trainWorker"

function HelperPersonnelNetwork.writeString(streamId, value)
    streamWriteString(streamId, value ~= nil and tostring(value) or "")
end

function HelperPersonnelNetwork.readString(streamId)
    local value = streamReadString(streamId)
    if value == nil or value == "" then
        return nil
    end

    return value
end

function HelperPersonnelNetwork.writeSpecializationProgresses(streamId, progresses)
    progresses = type(progresses) == "table" and progresses or {}
    local keys = HelperPersonnelManager ~= nil and HelperPersonnelManager.SPECIALIZATION_KEYS or {}
    local count = 0

    for _, key in ipairs(keys) do
        local minutes = math.max(0, math.floor((tonumber(progresses[key]) or 0) + 0.5))
        if minutes > 0 then
            count = count + 1
        end
    end

    streamWriteUInt8(streamId, math.min(count, 255))
    local written = 0
    for _, key in ipairs(keys) do
        local minutes = math.max(0, math.floor((tonumber(progresses[key]) or 0) + 0.5))
        if minutes > 0 and written < 255 then
            HelperPersonnelNetwork.writeString(streamId, key)
            streamWriteInt32(streamId, minutes)
            written = written + 1
        end
    end
end

function HelperPersonnelNetwork.readSpecializationProgresses(streamId)
    local progresses = {}
    local count = math.max(0, streamReadUInt8(streamId) or 0)

    for _ = 1, count do
        local key = HelperPersonnelNetwork.readString(streamId)
        local minutes = math.max(0, streamReadInt32(streamId) or 0)
        if key ~= nil and minutes > 0 then
            progresses[key] = math.max(progresses[key] or 0, minutes)
        end
    end

    return progresses
end

function HelperPersonnelNetwork.writeOptionalInt(streamId, value)
    value = tonumber(value)
    streamWriteInt32(streamId, value ~= nil and math.floor(value + 0.5) or -1)
end

function HelperPersonnelNetwork.readOptionalInt(streamId)
    local value = streamReadInt32(streamId)
    if value == nil or value < 0 then
        return nil
    end

    return value
end

function HelperPersonnelNetwork.writePerson(streamId, person)
    person = person or {}

    streamWriteInt32(streamId, tonumber(person.id) or 0)
    HelperPersonnelNetwork.writeString(streamId, person.firstName)
    HelperPersonnelNetwork.writeString(streamId, person.lastName)
    HelperPersonnelNetwork.writeString(streamId, person.gender)
    streamWriteInt32(streamId, tonumber(person.experience) or 0)
    streamWriteInt32(streamId, tonumber(person.reliability) or 0)
    streamWriteInt32(streamId, tonumber(person.loyalty) or (HelperPersonnelManager ~= nil and HelperPersonnelManager.DEFAULT_LOYALTY or 65))
    streamWriteInt32(streamId, tonumber(person.avatarIndex) or 0)
    HelperPersonnelNetwork.writeOptionalInt(streamId, person.assignedHelperIndex)
    HelperPersonnelNetwork.writeOptionalInt(streamId, person.assignedBaseHelperIndex)
    HelperPersonnelNetwork.writeOptionalInt(streamId, person.hiredPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, person.hiredYear)
    streamWriteInt32(streamId, tonumber(person.loyaltyMilestoneMonths) or 0)
    streamWriteInt32(streamId, tonumber(person.loyaltyTenureMilestoneMonths) or 0)
    streamWriteInt32(streamId, tonumber(person.nightWorkIngameMinutes) or 0)
    streamWriteFloat32(streamId, tonumber(person.nightWorkRealtimeMs) or 0)
    HelperPersonnelNetwork.writeOptionalInt(streamId, person.nightWorkLastMinute)
    streamWriteFloat32(streamId, tonumber(person.loyaltyReputationProgress) or 0)
    streamWriteInt32(streamId, tonumber(person.experiencePeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.experienceYear) or 1)
    streamWriteInt32(streamId, tonumber(person.experienceThisPeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.experienceProgressMinutes) or 0)
    streamWriteFloat32(streamId, tonumber(person.wage) or 0)
    streamWriteFloat32(streamId, tonumber(person.baseWage) or 0)
    streamWriteBool(streamId, person.busy == true)
    HelperPersonnelNetwork.writeString(streamId, person.vehicleName)
    HelperPersonnelNetwork.writeString(streamId, person.vehicleKey)
    streamWriteBool(streamId, person.restorePending == true)
    HelperPersonnelNetwork.writeString(streamId, person.restoreVehicleName)
    HelperPersonnelNetwork.writeString(streamId, person.restoreVehicleKey)
    streamWriteInt32(streamId, tonumber(person.jobsCompleted) or 0)
    streamWriteInt32(streamId, tonumber(person.totalWorkMinutes) or 0)
    streamWriteInt32(streamId, tonumber(person.lastJobMinutes) or 0)
    streamWriteFloat32(streamId, tonumber(person.totalEarnings) or 0)
    streamWriteFloat32(streamId, tonumber(person.currentJobStartedAt) or 0)
    streamWriteFloat32(streamId, tonumber(person.currentJobElapsedMs) or 0)
    streamWriteInt32(streamId, tonumber(person.monthsAvailable) or 0)
    streamWriteInt32(streamId, tonumber(person.sickPeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.sickYear) or 0)
    streamWriteInt32(streamId, tonumber(person.sickDay) or 0)
    streamWriteInt32(streamId, tonumber(person.sicknessPeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.sicknessYear) or 0)
    streamWriteInt32(streamId, tonumber(person.sicknessDaysThisPeriod) or 0)
    HelperPersonnelNetwork.writeString(streamId, person.specializationPrimary)
    HelperPersonnelNetwork.writeString(streamId, person.specializationSecondary)
    HelperPersonnelNetwork.writeString(streamId, person.specializationProgressKey)
    streamWriteInt32(streamId, tonumber(person.specializationProgressMinutes) or 0)
    HelperPersonnelNetwork.writeSpecializationProgresses(streamId, person.specializationProgresses)
    streamWriteInt32(streamId, tonumber(person.trainingLastPeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.trainingLastYear) or 0)
    HelperPersonnelNetwork.writeString(streamId, person.trainingLastSpecialization)
    streamWriteInt32(streamId, tonumber(person.trainingActivePeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.trainingActiveYear) or 0)
    HelperPersonnelNetwork.writeString(streamId, person.trainingActiveSpecialization)
end

function HelperPersonnelNetwork.readPerson(streamId, version)
    local person = {}

    person.id = streamReadInt32(streamId)
    person.firstName = HelperPersonnelNetwork.readString(streamId) or ""
    person.lastName = HelperPersonnelNetwork.readString(streamId) or ""
    person.gender = HelperPersonnelNetwork.readString(streamId)
    person.experience = streamReadInt32(streamId)
    person.reliability = streamReadInt32(streamId)
    person.loyalty = streamReadInt32(streamId)
    person.avatarIndex = streamReadInt32(streamId)
    person.assignedHelperIndex = HelperPersonnelNetwork.readOptionalInt(streamId)
    person.assignedBaseHelperIndex = HelperPersonnelNetwork.readOptionalInt(streamId)
    person.hiredPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    person.hiredYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    person.loyaltyMilestoneMonths = streamReadInt32(streamId)
    person.loyaltyTenureMilestoneMonths = streamReadInt32(streamId)
    person.nightWorkIngameMinutes = streamReadInt32(streamId)
    person.nightWorkRealtimeMs = streamReadFloat32(streamId)
    person.nightWorkLastMinute = HelperPersonnelNetwork.readOptionalInt(streamId)
    person.loyaltyReputationProgress = streamReadFloat32(streamId)
    person.experiencePeriod = streamReadInt32(streamId)
    person.experienceYear = streamReadInt32(streamId)
    person.experienceThisPeriod = streamReadInt32(streamId)
    person.experienceProgressMinutes = streamReadInt32(streamId)
    person.wage = streamReadFloat32(streamId)
    person.baseWage = streamReadFloat32(streamId)
    person.busy = streamReadBool(streamId)
    person.vehicleName = HelperPersonnelNetwork.readString(streamId) or ""
    person.vehicleKey = HelperPersonnelNetwork.readString(streamId)
    person.restorePending = streamReadBool(streamId)
    person.restoreVehicleName = HelperPersonnelNetwork.readString(streamId)
    person.restoreVehicleKey = HelperPersonnelNetwork.readString(streamId)
    person.jobsCompleted = streamReadInt32(streamId)
    person.totalWorkMinutes = streamReadInt32(streamId)
    person.lastJobMinutes = streamReadInt32(streamId)
    person.totalEarnings = streamReadFloat32(streamId)
    person.currentJobStartedAt = streamReadFloat32(streamId)
    person.currentJobElapsedMs = streamReadFloat32(streamId)
    person.monthsAvailable = streamReadInt32(streamId)

    if (version or 0) >= 7 then
        person.sickPeriod = streamReadInt32(streamId) or 0
        person.sickYear = streamReadInt32(streamId) or 0
        person.sickDay = streamReadInt32(streamId) or 0
        person.sicknessPeriod = streamReadInt32(streamId) or 0
        person.sicknessYear = streamReadInt32(streamId) or 0
        person.sicknessDaysThisPeriod = streamReadInt32(streamId) or 0
    else
        person.sickPeriod = 0
        person.sickYear = 0
        person.sickDay = 0
        person.sicknessPeriod = 0
        person.sicknessYear = 0
        person.sicknessDaysThisPeriod = 0
    end

    if (version or 0) >= 8 then
        person.specializationPrimary = HelperPersonnelNetwork.readString(streamId)
        person.specializationSecondary = HelperPersonnelNetwork.readString(streamId)
        person.specializationProgressKey = HelperPersonnelNetwork.readString(streamId)
        person.specializationProgressMinutes = streamReadInt32(streamId) or 0
        if (version or 0) >= 12 then
            person.specializationProgresses = HelperPersonnelNetwork.readSpecializationProgresses(streamId)
        else
            person.specializationProgresses = {}
            if person.specializationProgressKey ~= nil and (person.specializationProgressMinutes or 0) > 0 then
                person.specializationProgresses[person.specializationProgressKey] = person.specializationProgressMinutes
            end
        end
        if (version or 0) >= 13 then
            person.trainingLastPeriod = streamReadInt32(streamId) or 0
            person.trainingLastYear = streamReadInt32(streamId) or 0
        else
            person.trainingLastPeriod = 0
            person.trainingLastYear = 0
        end
        if (version or 0) >= 14 then
            person.trainingLastSpecialization = HelperPersonnelNetwork.readString(streamId)
            person.trainingActivePeriod = streamReadInt32(streamId) or 0
            person.trainingActiveYear = streamReadInt32(streamId) or 0
            person.trainingActiveSpecialization = HelperPersonnelNetwork.readString(streamId)
        else
            person.trainingLastSpecialization = nil
            person.trainingActivePeriod = 0
            person.trainingActiveYear = 0
            person.trainingActiveSpecialization = nil
        end
    else
        person.specializationPrimary = nil
        person.specializationSecondary = nil
        person.specializationProgressKey = nil
        person.specializationProgressMinutes = 0
        person.specializationProgresses = {}
        person.trainingLastPeriod = 0
        person.trainingLastYear = 0
        person.trainingLastSpecialization = nil
        person.trainingActivePeriod = 0
        person.trainingActiveYear = 0
        person.trainingActiveSpecialization = nil
    end

    return person
end

function HelperPersonnelNetwork.writeHistory(streamId, history)
    history = history or {}
    local maxCount = HelperPersonnelManager ~= nil and (HelperPersonnelManager.MAX_HISTORY_ENTRIES or 3) or 3
    local count = math.min(#history, maxCount)
    streamWriteInt32(streamId, count)

    for index = 1, count do
        local entry = history[index] or {}
        streamWriteInt32(streamId, tonumber(entry.period) or 0)
        streamWriteInt32(streamId, tonumber(entry.year) or 1)
        HelperPersonnelNetwork.writeString(streamId, entry.text)
    end
end

function HelperPersonnelNetwork.readHistory(streamId)
    local history = {}
    local count = math.max(0, streamReadInt32(streamId) or 0)

    for _ = 1, count do
        table.insert(history, {
            period = streamReadInt32(streamId) or 0,
            year = streamReadInt32(streamId) or 1,
            text = HelperPersonnelNetwork.readString(streamId) or ""
        })
    end

    return history
end

function HelperPersonnelNetwork.writeState(streamId, state)
    state = state or {}

    streamWriteInt32(streamId, tonumber(state.nextPersonId) or 1)
    streamWriteInt32(streamId, tonumber(state.employerReputation) or 50)
    HelperPersonnelNetwork.writeString(streamId, state.lastActionText)
    HelperPersonnelNetwork.writeString(streamId, state.lastReputationChangeText)
    HelperPersonnelNetwork.writeString(streamId, state.lastPayrollText)
    streamWriteFloat32(streamId, tonumber(state.lastPayrollAmount) or 0)
    streamWriteFloat32(streamId, tonumber(state.totalPayrollPaid) or 0)
    HelperPersonnelNetwork.writeOptionalInt(streamId, state.dismissalPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, state.dismissalYear)
    streamWriteInt32(streamId, tonumber(state.monthlyDismissals) or 0)
    HelperPersonnelNetwork.writeOptionalInt(streamId, state.lastApplicantPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, state.lastApplicantYear)
    streamWriteInt32(streamId, tonumber(state.changeCounter) or 0)

    HelperPersonnelNetwork.writeHistory(streamId, state.reputationHistory)
    HelperPersonnelNetwork.writeHistory(streamId, state.actionHistory)

    local workers = state.workers or {}
    streamWriteInt32(streamId, #workers)
    for _, worker in ipairs(workers) do
        HelperPersonnelNetwork.writePerson(streamId, worker)
    end

    local applicants = state.applicants or {}
    streamWriteInt32(streamId, #applicants)
    for _, applicant in ipairs(applicants) do
        HelperPersonnelNetwork.writePerson(streamId, applicant)
    end
end

function HelperPersonnelNetwork.readState(streamId)
    local state = {}

    state.nextPersonId = streamReadInt32(streamId)
    state.employerReputation = streamReadInt32(streamId)
    state.lastActionText = HelperPersonnelNetwork.readString(streamId) or ""
    state.lastReputationChangeText = HelperPersonnelNetwork.readString(streamId) or ""
    state.lastPayrollText = HelperPersonnelNetwork.readString(streamId) or "noch keine Gehaltsabrechnung"
    state.lastPayrollAmount = streamReadFloat32(streamId) or 0
    state.totalPayrollPaid = streamReadFloat32(streamId) or 0
    state.dismissalPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.dismissalYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.monthlyDismissals = streamReadInt32(streamId) or 0
    state.lastApplicantPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.lastApplicantYear = HelperPersonnelNetwork.readOptionalInt(streamId)
    state.changeCounter = streamReadInt32(streamId) or 0

    state.reputationHistory = HelperPersonnelNetwork.readHistory(streamId)
    state.actionHistory = HelperPersonnelNetwork.readHistory(streamId)

    state.workers = {}
    local workerCount = math.max(0, streamReadInt32(streamId) or 0)
    for _ = 1, workerCount do
        table.insert(state.workers, HelperPersonnelNetwork.readPerson(streamId))
    end

    state.applicants = {}
    local applicantCount = math.max(0, streamReadInt32(streamId) or 0)
    for _ = 1, applicantCount do
        table.insert(state.applicants, HelperPersonnelNetwork.readPerson(streamId))
    end

    return state
end

-- Server -> Client: vollstaendiger Personalzustand.
HelperPersonnelNetworkStateEvent = {}
local HelperPersonnelNetworkStateEvent_mt = Class(HelperPersonnelNetworkStateEvent, Event)
InitEventClass(HelperPersonnelNetworkStateEvent, "HelperPersonnelNetworkStateEvent")

function HelperPersonnelNetworkStateEvent.emptyNew()
    return Event.new(HelperPersonnelNetworkStateEvent_mt)
end

function HelperPersonnelNetworkStateEvent.new(state)
    local self = HelperPersonnelNetworkStateEvent.emptyNew()
    self.state = state or {}
    return self
end

function HelperPersonnelNetworkStateEvent:writeStream(streamId, connection)
    HelperPersonnelNetwork.writeState(streamId, self.state)
end

function HelperPersonnelNetworkStateEvent:readStream(streamId, connection)
    self.state = HelperPersonnelNetwork.readState(streamId)
    self:run(connection)
end

function HelperPersonnelNetworkStateEvent:run(connection)
    local app = g_helperPersonnelApp
    if app ~= nil and app.applyNetworkState ~= nil then
        app:applyNetworkState(self.state)
    end
end

-- Client -> Server: Bedienanfrage aus dem ESC-Menue.
HelperPersonnelNetworkActionEvent = {}
local HelperPersonnelNetworkActionEvent_mt = Class(HelperPersonnelNetworkActionEvent, Event)
InitEventClass(HelperPersonnelNetworkActionEvent, "HelperPersonnelNetworkActionEvent")

function HelperPersonnelNetworkActionEvent.emptyNew()
    return Event.new(HelperPersonnelNetworkActionEvent_mt)
end

function HelperPersonnelNetworkActionEvent.new(actionName, targetId)
    local self = HelperPersonnelNetworkActionEvent.emptyNew()
    self.actionName = actionName or ""
    self.targetId = tonumber(targetId) or 0
    return self
end

function HelperPersonnelNetworkActionEvent:writeStream(streamId, connection)
    HelperPersonnelNetwork.writeString(streamId, self.actionName)
    streamWriteInt32(streamId, tonumber(self.targetId) or 0)
end

function HelperPersonnelNetworkActionEvent:readStream(streamId, connection)
    self.actionName = HelperPersonnelNetwork.readString(streamId) or ""
    self.targetId = streamReadInt32(streamId) or 0
    self:run(connection)
end

function HelperPersonnelNetworkActionEvent:run(connection)
    local app = g_helperPersonnelApp
    if app == nil or app.processNetworkAction == nil then
        return
    end

    -- Auf dem Server kommt die Anfrage von einer Client-Verbindung.
    -- Auf Clients werden ActionEvents nicht ausgefuehrt.
    if connection == nil or connection.getIsServer == nil or connection:getIsServer() ~= true then
        app:processNetworkAction(self.actionName, self.targetId, connection)
    end
end

-- Client -> Server: ausdrueckliche Anforderung eines vollstaendigen Zustandsabgleichs.
HelperPersonnelNetworkRequestStateEvent = {}
local HelperPersonnelNetworkRequestStateEvent_mt = Class(HelperPersonnelNetworkRequestStateEvent, Event)
InitEventClass(HelperPersonnelNetworkRequestStateEvent, "HelperPersonnelNetworkRequestStateEvent")

function HelperPersonnelNetworkRequestStateEvent.emptyNew()
    return Event.new(HelperPersonnelNetworkRequestStateEvent_mt)
end

function HelperPersonnelNetworkRequestStateEvent.new()
    return HelperPersonnelNetworkRequestStateEvent.emptyNew()
end

function HelperPersonnelNetworkRequestStateEvent:writeStream(streamId, connection)
end

function HelperPersonnelNetworkRequestStateEvent:readStream(streamId, connection)
    self:run(connection)
end

function HelperPersonnelNetworkRequestStateEvent:run(connection)
    local app = g_helperPersonnelApp
    if app == nil or app.sendNetworkStateToConnection == nil then
        return
    end

    if connection == nil or connection.getIsServer == nil or connection:getIsServer() ~= true then
        app:sendNetworkStateToConnection(connection)
    end
end

-- Server -> Client: kurze Spielmeldung oben rechts.
HelperPersonnelNotificationEvent = {}
local HelperPersonnelNotificationEvent_mt = Class(HelperPersonnelNotificationEvent, Event)
InitEventClass(HelperPersonnelNotificationEvent, "HelperPersonnelNotificationEvent")

function HelperPersonnelNotificationEvent.emptyNew()
    return Event.new(HelperPersonnelNotificationEvent_mt)
end

function HelperPersonnelNotificationEvent.new(text, notificationType)
    local self = HelperPersonnelNotificationEvent.emptyNew()
    self.text = text or ""
    self.notificationType = tonumber(notificationType) or 0
    return self
end

function HelperPersonnelNotificationEvent:writeStream(streamId, connection)
    HelperPersonnelNetwork.writeString(streamId, self.text)
    streamWriteInt32(streamId, tonumber(self.notificationType) or 0)
end

function HelperPersonnelNotificationEvent:readStream(streamId, connection)
    self.text = HelperPersonnelNetwork.readString(streamId) or ""
    self.notificationType = streamReadInt32(streamId) or 0
    self:run(connection)
end

function HelperPersonnelNotificationEvent:run(connection)
    local app = g_helperPersonnelApp
    if app ~= nil and app.showIngameNotificationLocal ~= nil then
        app:showIngameNotificationLocal(self.text, self.notificationType)
    elseif g_currentMission ~= nil and g_currentMission.addIngameNotification ~= nil then
        g_currentMission:addIngameNotification(self.notificationType or 0, self.text or "")
    end
end

-- Multiplayer farm separation stream format (v1.5.1.0)
HelperPersonnelNetwork.STATE_VERSION = 14

local function hpNetworkFarmIdBits()
    if FarmManager ~= nil and FarmManager.FARM_ID_SEND_NUM_BITS ~= nil then
        return FarmManager.FARM_ID_SEND_NUM_BITS
    end
    return 8
end

function HelperPersonnelNetwork.writeFarmId(streamId, farmId)
    farmId = tonumber(farmId) or 1
    streamWriteUIntN(streamId, farmId, hpNetworkFarmIdBits())
end

function HelperPersonnelNetwork.readFarmId(streamId)
    return streamReadUIntN(streamId, hpNetworkFarmIdBits())
end

function HelperPersonnelNetwork.writeOptionalInt(streamId, value)
    local hasValue = value ~= nil
    streamWriteBool(streamId, hasValue)
    if hasValue then
        streamWriteInt32(streamId, value)
    end
end

function HelperPersonnelNetwork.readOptionalInt(streamId)
    if streamReadBool(streamId) then
        return streamReadInt32(streamId)
    end
    return nil
end

function HelperPersonnelNetwork.writeOptionalFloat(streamId, value)
    local hasValue = value ~= nil
    streamWriteBool(streamId, hasValue)
    if hasValue then
        streamWriteFloat32(streamId, value)
    end
end

function HelperPersonnelNetwork.readOptionalFloat(streamId)
    if streamReadBool(streamId) then
        return streamReadFloat32(streamId)
    end
    return nil
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
    HelperPersonnelNetwork.writePersonArray(streamId, farmState.workers or {})
    HelperPersonnelNetwork.writePersonArray(streamId, farmState.applicants or {})
    HelperPersonnelNetwork.writeHistory(streamId, farmState.reputationHistory or {})
    HelperPersonnelNetwork.writeHistory(streamId, farmState.actionHistory or {})
end

function HelperPersonnelNetwork.readFarmState(streamId)
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
    farmState.workers = HelperPersonnelNetwork.readPersonArray(streamId)
    farmState.applicants = HelperPersonnelNetwork.readPersonArray(streamId)
    farmState.reputationHistory = HelperPersonnelNetwork.readHistory(streamId)
    farmState.actionHistory = HelperPersonnelNetwork.readHistory(streamId)
    return farmState
end

function HelperPersonnelNetwork.writeState(streamId, state)
    state = state or {}
    streamWriteUInt8(streamId, HelperPersonnelNetwork.STATE_VERSION)
    streamWriteInt32(streamId, state.nextPersonId or 1)
    streamWriteInt32(streamId, state.changeCounter or 0)
    HelperPersonnelNetwork.writeFarmId(streamId, state.activeFarmId or 1)

    local farms = state.farms or {}
    streamWriteInt32(streamId, #farms)
    for _, farmState in ipairs(farms) do
        HelperPersonnelNetwork.writeFarmState(streamId, farmState)
    end
end

function HelperPersonnelNetwork.readState(streamId)
    local version = streamReadUInt8(streamId)
    local state = { version = version }

    if version == HelperPersonnelNetwork.STATE_VERSION then
        state.nextPersonId = streamReadInt32(streamId)
        state.changeCounter = streamReadInt32(streamId)
        state.activeFarmId = HelperPersonnelNetwork.readFarmId(streamId)
        state.farms = {}

        local farmCount = streamReadInt32(streamId)
        for _ = 1, farmCount do
            table.insert(state.farms, HelperPersonnelNetwork.readFarmState(streamId))
        end

        return state
    end

    -- Rueckfall fuer fruehe Testversionen ohne Farm-Trennung.
    state.nextPersonId = streamReadInt32(streamId)
    state.changeCounter = streamReadInt32(streamId)
    state.workers = HelperPersonnelNetwork.readPersonArray(streamId)
    state.applicants = HelperPersonnelNetwork.readPersonArray(streamId)
    state.employerReputation = streamReadUInt8(streamId)
    state.lastActionText = streamReadString(streamId)
    state.lastReputationChangeText = streamReadString(streamId)
    state.lastPayrollText = streamReadString(streamId)
    state.lastPayrollAmount = streamReadFloat32(streamId)
    state.totalPayrollPaid = streamReadFloat32(streamId)
    state.dismissalPeriod = streamReadInt32(streamId)
    state.dismissalYear = streamReadInt32(streamId)
    state.monthlyDismissals = streamReadInt32(streamId)
    state.lastApplicantPeriod = streamReadInt32(streamId)
    state.lastApplicantYear = streamReadInt32(streamId)
    state.reputationHistory = HelperPersonnelNetwork.readHistory(streamId)
    state.actionHistory = HelperPersonnelNetwork.readHistory(streamId)
    return state
end

function HelperPersonnelNetworkActionEvent.new(actionType, targetId, changeCounter, farmId)
    local self = HelperPersonnelNetworkActionEvent.emptyNew()
    self.actionType = actionType or ""
    self.targetId = targetId or 0
    self.changeCounter = changeCounter or 0
    self.farmId = tonumber(farmId) or 1
    return self
end

function HelperPersonnelNetworkActionEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.actionType or "")
    streamWriteInt32(streamId, self.targetId or 0)
    streamWriteInt32(streamId, self.changeCounter or 0)
    HelperPersonnelNetwork.writeFarmId(streamId, self.farmId or 1)
end

function HelperPersonnelNetworkActionEvent:readStream(streamId, connection)
    self.actionType = streamReadString(streamId)
    self.targetId = streamReadInt32(streamId)
    self.changeCounter = streamReadInt32(streamId)
    self.farmId = HelperPersonnelNetwork.readFarmId(streamId)
    self:run(connection)
end

function HelperPersonnelNetworkActionEvent:run(connection)
    local app = g_helperPersonnelApp
    if app == nil or app.processNetworkAction == nil then
        return
    end

    if connection == nil or connection.getIsServer == nil or connection:getIsServer() ~= true then
        app:processNetworkAction(self.actionType or self.actionName, self.targetId, connection, self.farmId)
    end
end
