

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.ACTION_HIRE = "hire"
HelperPersonnelNetwork.ACTION_DISMISS = "dismiss"
HelperPersonnelNetwork.ACTION_TRAIN_WORKER = "trainWorker"
HelperPersonnelNetwork.ACTION_GRANT_SALARY_RAISE = "grantSalaryRaise"
HelperPersonnelNetwork.ACTION_DECLINE_SALARY_RAISE = "declineSalaryRaise"

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
    streamWriteInt32(streamId, tonumber(person.birthDay) or 1)
    streamWriteInt32(streamId, tonumber(person.birthMonth) or 1)
    streamWriteInt32(streamId, tonumber(person.birthYear) or 2000)
    streamWriteInt32(streamId, tonumber(person.lastBirthdayYear) or 0)
    HelperPersonnelNetwork.writeString(streamId, person.backgroundKey)
    streamWriteInt32(streamId, tonumber(person.retirementProfileSeed) or 1)
    streamWriteInt32(streamId, tonumber(person.lastRetirementCheckYear) or 0)
    streamWriteBool(streamId, person.retirementPending == true)
    streamWriteInt32(streamId, tonumber(person.retirementNoticePeriod) or 0)
    streamWriteInt32(streamId, tonumber(person.retirementNoticeYear) or 0)
    streamWriteBool(streamId, person.transportDriver == true)
    streamWriteInt32(streamId, person.transportDriver == true and (tonumber(person.transportPriority) or 0) or 0)
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

    if (version or 0) >= 15 then
        person.birthDay = streamReadInt32(streamId) or 1
        person.birthMonth = streamReadInt32(streamId) or 1
        person.birthYear = streamReadInt32(streamId) or 2000
        person.lastBirthdayYear = streamReadInt32(streamId) or 0
        person.backgroundKey = HelperPersonnelNetwork.readString(streamId)
        person.retirementProfileSeed = streamReadInt32(streamId) or 1
        person.lastRetirementCheckYear = streamReadInt32(streamId) or 0
        person.retirementPending = streamReadBool(streamId) == true
        person.retirementNoticePeriod = streamReadInt32(streamId) or 0
        person.retirementNoticeYear = streamReadInt32(streamId) or 0
    else
        person.birthDay = nil
        person.birthMonth = nil
        person.birthYear = nil
        person.lastBirthdayYear = nil
        person.backgroundKey = nil
        person.retirementProfileSeed = nil
        person.lastRetirementCheckYear = nil
        person.retirementPending = false
        person.retirementNoticePeriod = 0
        person.retirementNoticeYear = 0
    end

    if (version or 0) >= 18 then
        person.transportDriver = streamReadBool(streamId) == true
        person.transportPriority = streamReadInt32(streamId) or 0
    else
        person.transportDriver = false
        person.transportPriority = 0
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
    local count = HelperPersonnelNetwork.readBoundedCount(streamId, HelperPersonnelNetwork.MAX_NETWORK_HISTORY, "history")

    for _ = 1, count do
        table.insert(history, {
            period = streamReadInt32(streamId) or 0,
            year = streamReadInt32(streamId) or 1,
            text = HelperPersonnelNetwork.readString(streamId) or ""
        })
    end

    return history
end

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.STATE_VERSION = 18
HelperPersonnelNetwork.ACTION_SELECT_WORKER = "selectWorker"
HelperPersonnelNetwork.MAX_NETWORK_FARMS = 64
HelperPersonnelNetwork.MAX_NETWORK_PEOPLE = 1024
HelperPersonnelNetwork.MAX_NETWORK_HISTORY = 64
HelperPersonnelNetwork.MAX_NETWORK_ASSIGNMENTS = 1024
HelperPersonnelNetwork.MAX_NETWORK_CHRONICLE_RECORDS = 4096
HelperPersonnelNetwork.MAX_NETWORK_CHRONICLE_ENTRIES = 8192
HelperPersonnelNetwork.MAX_NETWORK_TOTAL_ITEMS = 32768

function HelperPersonnelNetwork.beginNetworkRead()
    HelperPersonnelNetwork.networkReadInvalid = false
    HelperPersonnelNetwork.networkReadRemaining = HelperPersonnelNetwork.MAX_NETWORK_TOTAL_ITEMS
end

function HelperPersonnelNetwork.invalidateNetworkRead(label, count, limit)
    if HelperPersonnelNetwork.networkReadInvalid ~= true and Logging ~= nil and Logging.warning ~= nil then
        Logging.warning("FS25_PersonnelManagement: Invalid network count for %s (%s, maximum %s). State will be discarded.", tostring(label or "?"), tostring(count), tostring(limit))
    end

    HelperPersonnelNetwork.networkReadInvalid = true
end

function HelperPersonnelNetwork.readBoundedCount(streamId, limit, label)
    local count = tonumber(streamReadInt32(streamId)) or 0
    local remaining = tonumber(HelperPersonnelNetwork.networkReadRemaining)

    if count < 0 or count > limit or (remaining ~= nil and count > remaining) then
        HelperPersonnelNetwork.invalidateNetworkRead(label, count, limit)
        return 0
    end

    if remaining ~= nil then
        HelperPersonnelNetwork.networkReadRemaining = remaining - count
    end

    return count
end

function HelperPersonnelNetwork.finishNetworkRead()
    local invalid = HelperPersonnelNetwork.networkReadInvalid == true
    HelperPersonnelNetwork.networkReadInvalid = nil
    HelperPersonnelNetwork.networkReadRemaining = nil
    return invalid
end

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
    local count = HelperPersonnelNetwork.readBoundedCount(streamId, HelperPersonnelNetwork.MAX_NETWORK_PEOPLE, "people")

    for _ = 1, count do
        table.insert(people, HelperPersonnelNetwork.readPerson(streamId, version))
    end

    return people
end

function HelperPersonnelNetwork.writeChronicleRecords(streamId, records)
    records = type(records) == "table" and records or {}
    streamWriteInt32(streamId, #records)

    for _, record in ipairs(records) do
        streamWriteInt32(streamId, tonumber(record.personId) or 0)
        HelperPersonnelNetwork.writeString(streamId, record.firstName)
        HelperPersonnelNetwork.writeString(streamId, record.lastName)
        streamWriteBool(streamId, record.departed == true)
        streamWriteInt32(streamId, tonumber(record.sequence) or 0)

        local entries = type(record.entries) == "table" and record.entries or {}
        streamWriteInt32(streamId, #entries)
        for _, entry in ipairs(entries) do
            streamWriteInt32(streamId, tonumber(entry.sequence) or 0)
            HelperPersonnelNetwork.writeString(streamId, entry.eventType)
            streamWriteInt32(streamId, tonumber(entry.period) or 1)
            streamWriteInt32(streamId, tonumber(entry.gameYear) or 1)
            streamWriteInt32(streamId, tonumber(entry.calendarMonth) or 1)
            streamWriteInt32(streamId, tonumber(entry.calendarYear) or 2025)
            streamWriteInt32(streamId, tonumber(entry.day) or 1)
            HelperPersonnelNetwork.writeString(streamId, entry.category)
            HelperPersonnelNetwork.writeString(streamId, entry.reason)
            HelperPersonnelNetwork.writeString(streamId, entry.text)
            HelperPersonnelNetwork.writeString(streamId, entry.valueName)
            HelperPersonnelNetwork.writeOptionalFloat(streamId, entry.oldValue)
            HelperPersonnelNetwork.writeOptionalFloat(streamId, entry.newValue)
            HelperPersonnelNetwork.writeOptionalFloat(streamId, entry.delta)
            HelperPersonnelNetwork.writeOptionalFloat(streamId, entry.amount)
            HelperPersonnelNetwork.writeOptionalInt(streamId, entry.minutes)
            HelperPersonnelNetwork.writeString(streamId, entry.vehicleName)
        end
    end
end

function HelperPersonnelNetwork.readChronicleRecords(streamId)
    local records = {}
    local count = HelperPersonnelNetwork.readBoundedCount(streamId, HelperPersonnelNetwork.MAX_NETWORK_CHRONICLE_RECORDS, "chronicleRecords")

    for _ = 1, count do
        local record = {
            personId = streamReadInt32(streamId) or 0,
            firstName = HelperPersonnelNetwork.readString(streamId) or "",
            lastName = HelperPersonnelNetwork.readString(streamId) or "",
            departed = streamReadBool(streamId) == true,
            sequence = streamReadInt32(streamId) or 0,
            entries = {}
        }

        local entryCount = HelperPersonnelNetwork.readBoundedCount(streamId, HelperPersonnelNetwork.MAX_NETWORK_CHRONICLE_ENTRIES, "chronicleEntries")
        for _ = 1, entryCount do
            table.insert(record.entries, {
                sequence = streamReadInt32(streamId) or 0,
                eventType = HelperPersonnelNetwork.readString(streamId) or "unknown",
                period = streamReadInt32(streamId) or 1,
                gameYear = streamReadInt32(streamId) or 1,
                calendarMonth = streamReadInt32(streamId) or 1,
                calendarYear = streamReadInt32(streamId) or 2025,
                day = streamReadInt32(streamId) or 1,
                category = HelperPersonnelNetwork.readString(streamId),
                reason = HelperPersonnelNetwork.readString(streamId),
                text = HelperPersonnelNetwork.readString(streamId),
                valueName = HelperPersonnelNetwork.readString(streamId),
                oldValue = HelperPersonnelNetwork.readOptionalFloat(streamId),
                newValue = HelperPersonnelNetwork.readOptionalFloat(streamId),
                delta = HelperPersonnelNetwork.readOptionalFloat(streamId),
                amount = HelperPersonnelNetwork.readOptionalFloat(streamId),
                minutes = HelperPersonnelNetwork.readOptionalInt(streamId),
                vehicleName = HelperPersonnelNetwork.readString(streamId)
            })
        end

        table.insert(records, record)
    end

    return records
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
    local count = HelperPersonnelNetwork.readBoundedCount(streamId, HelperPersonnelNetwork.MAX_NETWORK_ASSIGNMENTS, "assignments")

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
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.trainingOfferPeriod)
    HelperPersonnelNetwork.writeOptionalInt(streamId, farmState.trainingOfferYear)
    for _, key in ipairs(HelperPersonnelManager ~= nil and HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local offer = type(farmState.trainingOffers) == "table" and farmState.trainingOffers[key] or nil
        streamWriteInt32(streamId, type(offer) == "table" and tonumber(offer.modifierPercent) or 0)
        streamWriteBool(streamId, type(offer) ~= "table" or offer.available ~= false)
    end

    HelperPersonnelNetwork.writePersonArray(streamId, farmState.workers or {})
    HelperPersonnelNetwork.writePersonArray(streamId, farmState.applicants or {})
    HelperPersonnelNetwork.writeHistory(streamId, farmState.reputationHistory or {})
    HelperPersonnelNetwork.writeHistory(streamId, farmState.actionHistory or {})
    HelperPersonnelNetwork.writeChronicleRecords(streamId, farmState.personChronicles or {})

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
    farmState.trainingOffers = {}
    if (version or 0) >= 16 then
        farmState.trainingOfferPeriod = HelperPersonnelNetwork.readOptionalInt(streamId)
        farmState.trainingOfferYear = HelperPersonnelNetwork.readOptionalInt(streamId)
        for _, key in ipairs(HelperPersonnelManager ~= nil and HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
            farmState.trainingOffers[key] = {
                modifierPercent = streamReadInt32(streamId) or 0,
                available = streamReadBool(streamId) == true
            }
        end
    end

    farmState.workers = HelperPersonnelNetwork.readPersonArray(streamId, version)
    farmState.applicants = HelperPersonnelNetwork.readPersonArray(streamId, version)
    farmState.reputationHistory = HelperPersonnelNetwork.readHistory(streamId)
    farmState.actionHistory = HelperPersonnelNetwork.readHistory(streamId)
    if (version or 0) >= 18 then
        farmState.personChronicles = HelperPersonnelNetwork.readChronicleRecords(streamId)
    else
        farmState.personChronicles = {}
    end

    if (version or 0) >= 3 then
        farmState.selectedWorkerId = HelperPersonnelNetwork.readOptionalInt(streamId)
        farmState.selectedVehicleKey = HelperPersonnelNetwork.readString(streamId)
        farmState.selectedVehicleName = HelperPersonnelNetwork.readString(streamId)
        farmState.activeAssignments = HelperPersonnelNetwork.readAssignmentArray(streamId)
    else
        farmState.activeAssignments = {}
    end

    if (version or 0) >= 5 and (version or 0) < 18 then
        for _, worker in ipairs(farmState.workers or {}) do
            worker.transportDriver = streamReadBool(streamId) == true
            worker.transportPriority = 0
        end
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
    HelperPersonnelNetwork.beginNetworkRead()

    local version = streamReadUInt8(streamId)
    local state = { version = version, farms = {} }

    if version ~= nil and version >= 2 and version <= HelperPersonnelNetwork.STATE_VERSION then
        state.nextPersonId = streamReadInt32(streamId)
        state.changeCounter = streamReadInt32(streamId)
        state.activeFarmId = HelperPersonnelNetwork.readFarmId(streamId)
        if version >= 5 then
            state.config = HelperPersonnelNetwork.readConfigState(streamId, version)
        end

        local farmCount = HelperPersonnelNetwork.readBoundedCount(streamId, HelperPersonnelNetwork.MAX_NETWORK_FARMS, "farms")
        local farmIds = {}
        for _ = 1, farmCount do
            local farmState = HelperPersonnelNetwork.readFarmState(streamId, version)
            local farmId = farmState ~= nil and tonumber(farmState.farmId) or nil
            if farmId == nil or farmId <= 0 or farmIds[farmId] == true then
                HelperPersonnelNetwork.invalidateNetworkRead("farmId", farmId or -1, 1)
                break
            end
            farmIds[farmId] = true
            table.insert(state.farms, farmState)
            if HelperPersonnelNetwork.networkReadInvalid == true then
                break
            end
        end

        if HelperPersonnelNetwork.finishNetworkRead() then
            return nil
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

    if HelperPersonnelNetwork.finishNetworkRead() then
        return nil
    end

    return state
end




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
    if self.state ~= nil then
        self:run(connection)
    end
end

function HelperPersonnelNetworkStateEvent:run(connection)
    local app = g_helperPersonnelApp
    if app ~= nil and app.applyNetworkState ~= nil then
        app:applyNetworkState(self.state)
    end
end

HelperPersonnelNetworkActionEvent = {}
local HelperPersonnelNetworkActionEvent_mt = Class(HelperPersonnelNetworkActionEvent, Event)
InitEventClass(HelperPersonnelNetworkActionEvent, "HelperPersonnelNetworkActionEvent")

function HelperPersonnelNetworkActionEvent.emptyNew()
    return Event.new(HelperPersonnelNetworkActionEvent_mt)
end





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

function HelperPersonnelNetworkActionEvent.new(actionType, targetId, changeCounter, farmId, actionData)
    local self = HelperPersonnelNetworkActionEvent.emptyNew()
    self.actionType = actionType or ""
    self.targetId = targetId or 0
    self.changeCounter = changeCounter or 0
    self.farmId = tonumber(farmId) or 1
    self.actionData = actionData or ""
    return self
end

function HelperPersonnelNetworkActionEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.actionType or "")
    streamWriteInt32(streamId, self.targetId or 0)
    streamWriteInt32(streamId, self.changeCounter or 0)
    HelperPersonnelNetwork.writeFarmId(streamId, self.farmId or 1)
    streamWriteString(streamId, self.actionData or "")
end

function HelperPersonnelNetworkActionEvent:readStream(streamId, connection)
    self.actionType = streamReadString(streamId)
    self.targetId = streamReadInt32(streamId)
    self.changeCounter = streamReadInt32(streamId)
    self.farmId = HelperPersonnelNetwork.readFarmId(streamId)
    self.actionData = streamReadString(streamId) or ""
    self:run(connection)
end

function HelperPersonnelNetworkActionEvent:run(connection)
    local app = g_helperPersonnelApp
    if app == nil or app.processNetworkAction == nil then
        return
    end

    if connection == nil or connection.getIsServer == nil or connection:getIsServer() ~= true then
        app:processNetworkAction(self.actionType or self.actionName, self.targetId, connection, self.farmId, self.actionData)
    end
end
