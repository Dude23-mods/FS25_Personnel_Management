HelperPersonnelExperienceEffects = HelperPersonnelExperienceEffects or {}
HelperPersonnelExperienceEffects.isInstalled = false

HelperPersonnelExperienceEffects.MIN_WORK_SPEED_FACTOR = 0.70
HelperPersonnelExperienceEffects.MAX_WORK_SPEED_FACTOR = 1.00
HelperPersonnelExperienceEffects.MIN_CAP_SPEED = 1.5

HelperPersonnelExperienceEffects.SPEED_DEBUG_LOGGING = false
HelperPersonnelExperienceEffects.SPEED_DEBUG_INTERVAL_MS = 30000
HelperPersonnelExperienceEffects._speedLogStateByVehicle = {}

HelperPersonnelExperienceEffects.RELIABILITY_DEBUG_LOGGING = false
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_RELIABILITY = 85
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_CHECK_INTERVAL_MS = 60000
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_COOLDOWN_MS = 180000
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_DURATION_MS = 30000
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MAX_DURATION_MS = 90000
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_PENALTY = 0.04
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MAX_PENALTY = 0.15
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MAX_CHANCE_PER_CHECK = 0.15
HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_CHANCE_EXPONENT = 1.4
HelperPersonnelExperienceEffects._reliabilitySlowdownStateByVehicle = {}

HelperPersonnelExperienceEffects.WEAR_DEBUG_LOGGING = false
HelperPersonnelExperienceEffects.WEAR_DEBUG_INTERVAL_MS = 30000
HelperPersonnelExperienceEffects.MAX_ADDITIONAL_WEAR_FACTOR = 0.15
HelperPersonnelExperienceEffects.WEAR_ECONOMY_DIFFICULTY_MULTIPLIERS = {
    [1] = 0.75,
    [2] = 1.00,
    [3] = 1.25
}
HelperPersonnelExperienceEffects._wearLogStateByVehicle = {}

HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_LOGGING = false
HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_INTERVAL_MS = 10000

HelperPersonnelExperienceEffects.PRECISION_FARMING_DEBUG_LOGGING = false
HelperPersonnelExperienceEffects.MAX_ADDITIONAL_CONSUMPTION_FACTOR = 0.10
HelperPersonnelExperienceEffects.CONSUMPTION_ECONOMY_DIFFICULTY_MULTIPLIERS = {
    [1] = 0.75,
    [2] = 1.00,
    [3] = 1.25
}
HelperPersonnelExperienceEffects._consumptionLogStateByVehicle = {}
HelperPersonnelExperienceEffects._consumptionDiagnosticLogState = {}

HelperPersonnelExperienceEffects.FUEL_DEBUG_LOGGING = false
HelperPersonnelExperienceEffects.FUEL_DEBUG_INTERVAL_MS = 30000
HelperPersonnelExperienceEffects.MAX_ADDITIONAL_FUEL_FACTOR = 0.10
HelperPersonnelExperienceEffects.FUEL_ECONOMY_DIFFICULTY_MULTIPLIERS = {
    [1] = 0.75,
    [2] = 1.00,
    [3] = 1.25
}
HelperPersonnelExperienceEffects._fuelLogStateByVehicle = {}

function HelperPersonnelExperienceEffects.clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

function HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle(vehicle)
    if vehicle == nil or g_helperPersonnelApp == nil or g_helperPersonnelApp.helperBridge == nil then
        return nil
    end

    local bridge = g_helperPersonnelApp.helperBridge

    if bridge.getWorkerIdByVehicle ~= nil then
        local success, workerId = pcall(bridge.getWorkerIdByVehicle, bridge, vehicle)
        if success and workerId ~= nil then
            return workerId
        end
    end

    if g_helperPersonnelApp.getRootVehicle ~= nil and bridge.getWorkerIdByVehicle ~= nil then
        local successRoot, rootVehicle = pcall(g_helperPersonnelApp.getRootVehicle, g_helperPersonnelApp, vehicle)
        if successRoot and rootVehicle ~= nil and rootVehicle ~= vehicle then
            local success, workerId = pcall(bridge.getWorkerIdByVehicle, bridge, rootVehicle)
            if success and workerId ~= nil then
                return workerId
            end
        end
    end

    return nil
end

function HelperPersonnelExperienceEffects.getSpeedFactorForVehicle(vehicle)
    if g_helperPersonnelApp == nil or g_helperPersonnelApp.manager == nil then
        return 1
    end

    local workerId = HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle(vehicle)
    if workerId == nil then
        return 1
    end

    local manager = g_helperPersonnelApp.manager
    local worker = manager.getWorkerById ~= nil and manager:getWorkerById(workerId) or nil

    local experienceFactor = 1
    if manager.getWorkerWorkSpeedMultiplier ~= nil then
        experienceFactor = manager:getWorkerWorkSpeedMultiplier(workerId, vehicle)
    end

    local reliabilityFactor = HelperPersonnelExperienceEffects.getReliabilitySlowdownFactorForVehicle(vehicle, workerId, worker)
    local finalFactor = math.max(0, experienceFactor * reliabilityFactor)

    HelperPersonnelExperienceEffects.logSpeedIfNeeded(vehicle, worker, experienceFactor, reliabilityFactor, finalFactor)

    return finalFactor
end

function HelperPersonnelExperienceEffects.getEconomyDifficultyMultiplier(multiplierTable)
    local difficulty = 0

    if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
        difficulty = math.floor((tonumber(g_currentMission.missionInfo.economicDifficulty) or 0) + 0.5)
    end

    return type(multiplierTable) == "table" and (multiplierTable[difficulty] or 1) or 1
end

function HelperPersonnelExperienceEffects.getEffectiveExperienceForWorker(manager, worker, effectName, vehicle, fillType)
    if manager ~= nil and manager.getEffectiveGameplayExperience ~= nil then
        return manager:getEffectiveGameplayExperience(worker, effectName, vehicle, fillType)
    end

    if manager ~= nil and manager.clampPersonStat ~= nil and type(worker) == "table" then
        return manager:clampPersonStat(worker.experience or 0)
    end

    return HelperPersonnelExperienceEffects.clamp(type(worker) == "table" and (worker.experience or 0) or 100, 0, 100)
end

function HelperPersonnelExperienceEffects.getAdditionalExperienceFactorForVehicle(vehicle, effectName, maxFactor, multiplierTable, fillType)
    if g_helperPersonnelApp == nil or g_helperPersonnelApp.manager == nil then
        return 0, nil, nil
    end

    local workerId = HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle(vehicle)
    if workerId == nil then
        return 0, nil, nil
    end

    local manager = g_helperPersonnelApp.manager
    local worker = manager.getWorkerById ~= nil and manager:getWorkerById(workerId) or nil
    if worker == nil then
        return 0, workerId, nil
    end

    if manager.isGameplayExperienceEffectEnabled ~= nil and not manager:isGameplayExperienceEffectEnabled(effectName) then
        return 0, workerId, worker
    end

    local experience = HelperPersonnelExperienceEffects.getEffectiveExperienceForWorker(manager, worker, effectName, vehicle, fillType)
    local baseFactor = (tonumber(maxFactor) or 0) * (1 - (experience / 100))
    local economyMultiplier = HelperPersonnelExperienceEffects.getEconomyDifficultyMultiplier(multiplierTable)

    return math.max(0, baseFactor * economyMultiplier), workerId, worker
end

function HelperPersonnelExperienceEffects.getWearEconomyDifficultyMultiplier()
    return HelperPersonnelExperienceEffects.getEconomyDifficultyMultiplier(HelperPersonnelExperienceEffects.WEAR_ECONOMY_DIFFICULTY_MULTIPLIERS)
end

function HelperPersonnelExperienceEffects.getAdditionalWearFactorForVehicle(vehicle)
    return HelperPersonnelExperienceEffects.getAdditionalExperienceFactorForVehicle(vehicle, "wear", HelperPersonnelExperienceEffects.MAX_ADDITIONAL_WEAR_FACTOR, HelperPersonnelExperienceEffects.WEAR_ECONOMY_DIFFICULTY_MULTIPLIERS)
end

function HelperPersonnelExperienceEffects.getConsumptionEconomyDifficultyMultiplier()
    return HelperPersonnelExperienceEffects.getEconomyDifficultyMultiplier(HelperPersonnelExperienceEffects.CONSUMPTION_ECONOMY_DIFFICULTY_MULTIPLIERS)
end

function HelperPersonnelExperienceEffects.getAdditionalConsumptionFactorForVehicle(vehicle, fillType)
    return HelperPersonnelExperienceEffects.getAdditionalExperienceFactorForVehicle(vehicle, "consumables", HelperPersonnelExperienceEffects.MAX_ADDITIONAL_CONSUMPTION_FACTOR, HelperPersonnelExperienceEffects.CONSUMPTION_ECONOMY_DIFFICULTY_MULTIPLIERS, fillType)
end

function HelperPersonnelExperienceEffects.getFuelEconomyDifficultyMultiplier()
    return HelperPersonnelExperienceEffects.getEconomyDifficultyMultiplier(HelperPersonnelExperienceEffects.FUEL_ECONOMY_DIFFICULTY_MULTIPLIERS)
end

function HelperPersonnelExperienceEffects.getAdditionalFuelFactorForVehicle(vehicle)
    return HelperPersonnelExperienceEffects.getAdditionalExperienceFactorForVehicle(vehicle, "fuel", HelperPersonnelExperienceEffects.MAX_ADDITIONAL_FUEL_FACTOR, HelperPersonnelExperienceEffects.FUEL_ECONOMY_DIFFICULTY_MULTIPLIERS)
end

function HelperPersonnelExperienceEffects.getFillTypeName(fillType)
    if fillType == nil then
        return "unbekannt"
    end

    if g_fillTypeManager ~= nil and g_fillTypeManager.getFillTypeNameByIndex ~= nil then
        local success, name = pcall(g_fillTypeManager.getFillTypeNameByIndex, g_fillTypeManager, fillType)
        if success and name ~= nil and tostring(name) ~= "" then
            return tostring(name)
        end
    end

    return tostring(fillType)
end

function HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, expectedNames)
    if fillType == nil or type(expectedNames) ~= "table" then
        return false
    end

    local fillTypeName = HelperPersonnelExperienceEffects.getFillTypeName(fillType)
    if fillTypeName == nil then
        return false
    end

    fillTypeName = string.upper(tostring(fillTypeName))

    for _, expectedName in ipairs(expectedNames) do
        if fillTypeName == string.upper(tostring(expectedName)) then
            return true
        end
    end

    return false
end

function HelperPersonnelExperienceEffects.isSupportedConsumptionFillType(fillType)
    if fillType == nil then
        return false
    end

    if FillType ~= nil then
        if fillType == FillType.SEEDS
            or fillType == FillType.FERTILIZER
            or fillType == FillType.LIQUIDFERTILIZER
            or fillType == FillType.HERBICIDE
            or fillType == FillType.LIQUIDMANURE
            or fillType == FillType.DIGESTATE
            or fillType == FillType.MANURE then
            return true
        end
    end

    return HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, {
        "SEEDS",
        "SEED",
        "FERTILIZER",
        "MINERALFERTILIZER",
        "MINERAL_FERTILIZER",
        "LIQUIDFERTILIZER",
        "LIQUID_FERTILIZER",
        "HERBICIDE",
        "LIQUIDMANURE",
        "LIQUID_MANURE",
        "DIGESTATE",
        "MANURE"
    })
end

function HelperPersonnelExperienceEffects.getConsumptionSourceName(fillType)
    if FillType ~= nil then
        if fillType == FillType.HERBICIDE then
            return "Herbizid"
        elseif fillType == FillType.LIQUIDFERTILIZER then
            return "Fluessigduenger"
        elseif fillType == FillType.FERTILIZER then
            return "Duenger"
        elseif fillType == FillType.LIQUIDMANURE then
            return "Guelle"
        elseif fillType == FillType.DIGESTATE then
            return "Gaerreste"
        elseif fillType == FillType.MANURE then
            return "Mist"
        elseif fillType == FillType.SEEDS then
            return "Saatgut"
        end
    end

    if HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "HERBICIDE" }) then
        return "Herbizid"
    elseif HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "LIQUIDFERTILIZER", "LIQUID_FERTILIZER" }) then
        return "Fluessigduenger"
    elseif HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "FERTILIZER", "MINERALFERTILIZER", "MINERAL_FERTILIZER" }) then
        return "Duenger"
    elseif HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "LIQUIDMANURE", "LIQUID_MANURE" }) then
        return "Guelle"
    elseif HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "DIGESTATE" }) then
        return "Gaerreste"
    elseif HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "MANURE" }) then
        return "Mist"
    elseif HelperPersonnelExperienceEffects.matchesFillTypeName(fillType, { "SEEDS", "SEED" }) then
        return "Saatgut"
    end

    return "Ausbringmittel"
end

function HelperPersonnelExperienceEffects.isSupportedFuelFillType(fillType)
    if FillType == nil or fillType == nil then
        return false
    end

    return fillType == FillType.DIESEL
        or fillType == FillType.METHANE
end

function HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle)
    if vehicle == nil then
        return nil
    end

    if vehicle.rootNode ~= nil then
        return "node:" .. tostring(vehicle.rootNode)
    end

    return tostring(vehicle)
end

function HelperPersonnelExperienceEffects.getVehicleLogName(vehicle)
    if vehicle == nil then
        return "Fahrzeug"
    end

    if vehicle.getName ~= nil then
        local success, vehicleName = pcall(vehicle.getName, vehicle)
        if success and vehicleName ~= nil and tostring(vehicleName) ~= "" then
            return tostring(vehicleName)
        end
    end

    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.getVehicleName ~= nil then
        local success, vehicleName = pcall(g_helperPersonnelApp.getVehicleName, g_helperPersonnelApp, vehicle)
        if success and vehicleName ~= nil and tostring(vehicleName) ~= "" then
            return tostring(vehicleName)
        end
    end

    if vehicle.configFileName ~= nil then
        return tostring(vehicle.configFileName)
    end

    return "Fahrzeug"
end

function HelperPersonnelExperienceEffects.getWorkerLogName(worker)
    if type(worker) ~= "table" then
        return "unbekannt"
    end

    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.manager ~= nil and g_helperPersonnelApp.manager.getFullName ~= nil then
        local success, fullName = pcall(g_helperPersonnelApp.manager.getFullName, g_helperPersonnelApp.manager, worker)
        if success and fullName ~= nil and tostring(fullName) ~= "" then
            return tostring(fullName)
        end
    end

    return string.format("%s %s", tostring(worker.firstName or ""), tostring(worker.lastName or ""))
end

function HelperPersonnelExperienceEffects.getCurrentTimeMs()
    if g_currentMission ~= nil and g_currentMission.time ~= nil then
        return tonumber(g_currentMission.time) or 0
    end

    return 0
end
local function hpAddUniqueText(target, value)
    if type(target) ~= "table" or value == nil then
        return
    end

    value = tostring(value)
    if value == "" then
        return
    end

    for _, existing in ipairs(target) do
        if existing == value then
            return
        end
    end

    table.insert(target, value)
end

function HelperPersonnelExperienceEffects.getPrecisionFarmingDetectionText()
    local names = {
        "PrecisionFarming",
        "ExtendedSprayer",
        "ExtendedSowingMachine",
        "ExtendedCombine",
        "ExtendedWearable",
        "ExtendedMotorized",
        "WeedSpotSpray",
        "ManureSensor",
        "CropSensor"
    }

    local hits = {}
    for _, name in ipairs(names) do
        if rawget(_G, name) ~= nil then
            hpAddUniqueText(hits, name)
        end
    end

    local modNames = {
        "FS25_precisionFarming",
        "FS25_precisionFarming.zip",
        "precisionFarming"
    }

    if type(g_modIsLoaded) == "table" then
        for _, modName in ipairs(modNames) do
            if g_modIsLoaded[modName] == true then
                hpAddUniqueText(hits, "g_modIsLoaded:" .. tostring(modName))
            end
        end
    end

    if g_modManager ~= nil then
        if g_modManager.getModByName ~= nil then
            for _, modName in ipairs(modNames) do
                local success, mod = pcall(g_modManager.getModByName, g_modManager, modName)
                if success and mod ~= nil then
                    hpAddUniqueText(hits, "g_modManager:" .. tostring(modName))
                end
            end
        end

        if type(g_modManager.nameToMod) == "table" then
            for _, modName in ipairs(modNames) do
                if g_modManager.nameToMod[modName] ~= nil then
                    hpAddUniqueText(hits, "nameToMod:" .. tostring(modName))
                end
            end
        end
    end

    if #hits > 0 then
        return "ja (" .. table.concat(hits, ",") .. ")"
    end

    return "nein/unklar"
end

local function hpCollectMatchingTableKeys(sourceTable, patterns, prefix, target, maxEntries)
    if type(sourceTable) ~= "table" or type(patterns) ~= "table" or type(target) ~= "table" then
        return
    end

    maxEntries = tonumber(maxEntries) or 12
    for key, _ in pairs(sourceTable) do
        if #target >= maxEntries then
            return
        end

        local keyText = tostring(key)
        local lowerKey = string.lower(keyText)
        for _, pattern in ipairs(patterns) do
            if string.find(lowerKey, pattern, 1, true) ~= nil then
                hpAddUniqueText(target, tostring(prefix or "") .. keyText)
                break
            end
        end
    end
end

function HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle)
    if vehicle == nil then
        return "Fahrzeug=nil"
    end

    local specNames = {
        "spec_extendedSprayer",
        "spec_extendedSowingMachine",
        "spec_extendedCombine",
        "spec_extendedWearable",
        "spec_extendedMotorized",
        "spec_weedSpotSpray",
        "spec_manureSensor",
        "spec_cropSensor"
    }

    local hits = {}
    for _, specName in ipairs(specNames) do
        if vehicle[specName] ~= nil then
            hpAddUniqueText(hits, specName)
        end
    end

    local patterns = {
        "precision",
        "extendedsprayer",
        "extendedsowing",
        "extendedcombine",
        "weedspray",
        "weedspotspray",
        "cropsensor",
        "manuresensor",
        "nitrogen",
        "soilmap",
        "phmap"
    }

    hpCollectMatchingTableKeys(vehicle, patterns, "", hits, 16)

    if type(vehicle.specializations) == "table" then
        for _, specialization in pairs(vehicle.specializations) do
            if #hits >= 16 then
                break
            end

            if type(specialization) == "table" then
                local candidates = { specialization.name, specialization.className, specialization.typeName }
                for _, candidate in ipairs(candidates) do
                    if candidate ~= nil then
                        local text = tostring(candidate)
                        local lowerText = string.lower(text)
                        for _, pattern in ipairs(patterns) do
                            if string.find(lowerText, pattern, 1, true) ~= nil then
                                hpAddUniqueText(hits, "specialization:" .. text)
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if #hits > 0 then
        return table.concat(hits, ",")
    end

    return "keine_PF_Spezialisierung_erkannt"
end

function HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle)
    if vehicle == nil then
        return "Root=nil"
    end

    local rootVehicle = vehicle
    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.getRootVehicle ~= nil then
        local success, result = pcall(g_helperPersonnelApp.getRootVehicle, g_helperPersonnelApp, vehicle)
        if success and result ~= nil then
            rootVehicle = result
        end
    elseif vehicle.rootVehicle ~= nil then
        rootVehicle = vehicle.rootVehicle
    end

    if rootVehicle == vehicle then
        return "Root=gleiches_Fahrzeug"
    end

    return HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(rootVehicle)
end

function HelperPersonnelExperienceEffects.logPrecisionFarmingDiagnosticsStart()
    if HelperPersonnelExperienceEffects.PRECISION_FARMING_DEBUG_LOGGING ~= true then
        return
    end

    if HelperPersonnelExperienceEffects._precisionFarmingStartupLogged == true then
        return
    end

    HelperPersonnelExperienceEffects._precisionFarmingStartupLogged = true

    if Logging ~= nil and Logging.info ~= nil then
        Logging.info("FS25_HelperPersonnel: Precision-Farming-Diagnose aktiv | Version=1.0.2.1 | PrecisionFarming=%s | Hinweis=BasisVerbrauch ist die Rueckgabe der vorherigen Spiel-/Mod-Funktionskette vor unserem Zusatzfaktor", HelperPersonnelExperienceEffects.getPrecisionFarmingDetectionText())
    end
end

function HelperPersonnelExperienceEffects.logWearIfNeeded(vehicle, worker, baseChange, extraChange, factor, resultChange)
    if HelperPersonnelExperienceEffects.WEAR_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    local key = HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle)
    if key == nil then
        return
    end

    local now = HelperPersonnelExperienceEffects.getCurrentTimeMs()
    local state = HelperPersonnelExperienceEffects._wearLogStateByVehicle[key]
    if state == nil then
        state = { lastLogTime = -HelperPersonnelExperienceEffects.WEAR_DEBUG_INTERVAL_MS, baseChange = 0, extraChange = 0, resultChange = 0, samples = 0 }
        HelperPersonnelExperienceEffects._wearLogStateByVehicle[key] = state
    end

    state.baseChange = (state.baseChange or 0) + (baseChange or 0)
    state.extraChange = (state.extraChange or 0) + (extraChange or 0)
    state.resultChange = (state.resultChange or 0) + (resultChange or 0)
    state.samples = (state.samples or 0) + 1

    if now - (state.lastLogTime or 0) < HelperPersonnelExperienceEffects.WEAR_DEBUG_INTERVAL_MS then
        return
    end

    state.lastLogTime = now

    local vehicleName = HelperPersonnelExperienceEffects.getVehicleLogName(vehicle)
    local workerName = HelperPersonnelExperienceEffects.getWorkerLogName(worker)
    local experience = type(worker) == "table" and (tonumber(worker.experience) or 0) or 0

    Logging.info("FS25_HelperPersonnel: Verschleiss-Test | Mitarbeiter=%s | Erfahrung=%d | Fahrzeug/Geraet=%s | Zusatzfaktor=%.2f%% | BasisAenderung=%.8f | ZusatzAenderung=%.8f | GesamtAenderung=%.8f | Samples=%d",
        workerName,
        math.floor(experience + 0.5),
        vehicleName,
        (factor or 0) * 100,
        state.baseChange or 0,
        state.extraChange or 0,
        state.resultChange or 0,
        state.samples or 0
    )

    state.baseChange = 0
    state.extraChange = 0
    state.resultChange = 0
    state.samples = 0
end

function HelperPersonnelExperienceEffects.logConsumptionIfNeeded(vehicle, worker, fillType, baseUsage, extraUsage, resultUsage, factor, sourceName, debugDetails)
    if HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    baseUsage = tonumber(baseUsage) or 0
    extraUsage = tonumber(extraUsage) or 0
    resultUsage = tonumber(resultUsage) or 0

    if baseUsage <= 0 and extraUsage <= 0 and resultUsage <= 0 then
        return
    end

    local key = HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle)
    if key == nil then
        return
    end

    local fillTypeName = HelperPersonnelExperienceEffects.getFillTypeName(fillType)
    key = key .. ":" .. fillTypeName .. ":" .. tostring(sourceName or "Verbrauch")

    local now = HelperPersonnelExperienceEffects.getCurrentTimeMs()
    local state = HelperPersonnelExperienceEffects._consumptionLogStateByVehicle[key]
    if state == nil then
        state = { lastLogTime = -HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_INTERVAL_MS, baseUsage = 0, extraUsage = 0, resultUsage = 0, samples = 0 }
        HelperPersonnelExperienceEffects._consumptionLogStateByVehicle[key] = state
    end

    state.baseUsage = (state.baseUsage or 0) + baseUsage
    state.extraUsage = (state.extraUsage or 0) + extraUsage
    state.resultUsage = (state.resultUsage or 0) + resultUsage
    state.samples = (state.samples or 0) + 1

    if now - (state.lastLogTime or 0) < HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_INTERVAL_MS then
        return
    end

    state.lastLogTime = now

    local vehicleName = HelperPersonnelExperienceEffects.getVehicleLogName(vehicle)
    local workerName = HelperPersonnelExperienceEffects.getWorkerLogName(worker)
    local experience = type(worker) == "table" and (tonumber(worker.experience) or 0) or 0

    Logging.info("FS25_HelperPersonnel: Precision-Farming-Verbrauchstest | Quelle=%s | Mitarbeiter=%s | Erfahrung=%d | Fahrzeug/Geraet=%s | Fuelltyp=%s | Zusatzfaktor=%.2f%% | BasisVerbrauch=%.4f l | ZusatzVerbrauch=%.4f l | GesamtVerbrauch=%.4f l | Samples=%d | PrecisionFarming=%s | Details=%s",
        tostring(sourceName or "Verbrauch"),
        workerName,
        math.floor(experience + 0.5),
        vehicleName,
        fillTypeName,
        (factor or 0) * 100,
        state.baseUsage or 0,
        state.extraUsage or 0,
        state.resultUsage or 0,
        state.samples or 0,
        HelperPersonnelExperienceEffects.getPrecisionFarmingDetectionText(),
        tostring(debugDetails or "-")
    )

    state.baseUsage = 0
    state.extraUsage = 0
    state.resultUsage = 0
    state.samples = 0
end

function HelperPersonnelExperienceEffects.getVehicleAIActiveText(vehicle)
    if vehicle == nil then
        return "Fahrzeug=nil"
    end

    if vehicle.getIsAIActive ~= nil then
        local success, isActive = pcall(vehicle.getIsAIActive, vehicle)
        if success then
            return tostring(isActive == true)
        end

        return "Fehler_bei_getIsAIActive"
    end

    return "Methode_fehlend"
end

function HelperPersonnelExperienceEffects.getConsumptionDiagnosticFactorForVehicle(vehicle, fillType)
    if g_helperPersonnelApp == nil or g_helperPersonnelApp.manager == nil then
        return 0, nil, nil, "Personalmanagement_nicht_bereit"
    end

    local workerId = HelperPersonnelExperienceEffects.getAssignedWorkerIdForVehicle(vehicle)
    if workerId == nil then
        return 0, nil, nil, "kein_Mitarbeiter_zugeordnet"
    end

    local manager = g_helperPersonnelApp.manager
    local worker = manager.getWorkerById ~= nil and manager:getWorkerById(workerId) or nil
    if worker == nil then
        return 0, workerId, nil, "Mitarbeiter_nicht_gefunden"
    end

    if manager.isGameplayExperienceEffectEnabled ~= nil and not manager:isGameplayExperienceEffectEnabled("consumables") then
        return 0, workerId, worker, "Verbrauchseffekt_in_Config_deaktiviert"
    end

    local experience = HelperPersonnelExperienceEffects.getEffectiveExperienceForWorker(manager, worker, "consumables", vehicle, fillType)
    local baseFactor = (tonumber(HelperPersonnelExperienceEffects.MAX_ADDITIONAL_CONSUMPTION_FACTOR) or 0) * (1 - (experience / 100))
    local economyMultiplier = HelperPersonnelExperienceEffects.getEconomyDifficultyMultiplier(HelperPersonnelExperienceEffects.CONSUMPTION_ECONOMY_DIFFICULTY_MULTIPLIERS)
    local factor = math.max(0, baseFactor * economyMultiplier)

    if factor <= 0 then
        return 0, workerId, worker, "Zusatzfaktor_0"
    end

    return factor, workerId, worker, "ok"
end

function HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded(hookName, vehicle, fillType, reason, details, baseUsage, factor, workerId, worker)
    if HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_LOGGING ~= true and HelperPersonnelExperienceEffects.PRECISION_FARMING_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    local vehicleKey = HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle) or "Fahrzeug=nil"
    local fillTypeName = HelperPersonnelExperienceEffects.getFillTypeName(fillType)
    local key = tostring(vehicleKey) .. ":diagnose:" .. tostring(hookName or "?") .. ":" .. tostring(fillTypeName) .. ":" .. tostring(reason or "?")
    local now = HelperPersonnelExperienceEffects.getCurrentTimeMs()
    local state = HelperPersonnelExperienceEffects._consumptionDiagnosticLogState[key]
    if state == nil then
        state = { lastLogTime = -HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_INTERVAL_MS, count = 0 }
        HelperPersonnelExperienceEffects._consumptionDiagnosticLogState[key] = state
    end

    state.count = (state.count or 0) + 1
    if now - (state.lastLogTime or 0) < HelperPersonnelExperienceEffects.CONSUMPTION_DEBUG_INTERVAL_MS then
        return
    end

    state.lastLogTime = now

    if worker == nil and workerId ~= nil and g_helperPersonnelApp ~= nil and g_helperPersonnelApp.manager ~= nil and g_helperPersonnelApp.manager.getWorkerById ~= nil then
        worker = g_helperPersonnelApp.manager:getWorkerById(workerId)
    end

    local workerName = HelperPersonnelExperienceEffects.getWorkerLogName(worker)
    local experience = type(worker) == "table" and (tonumber(worker.experience) or 0) or 0

    Logging.info("FS25_HelperPersonnel: Precision-Farming-Verbrauchsdiagnose | Haken=%s | Ergebnis=kein_Zusatzverbrauch | Grund=%s | Mitarbeiter=%s | WorkerId=%s | Erfahrung=%d | Fahrzeug/Geraet=%s | Fuelltyp=%s | BasisVerbrauch=%.4f l | Zusatzfaktor=%.2f%% | Server=%s | KIaktiv=%s | FuelltypUnterstuetzt=%s | PrecisionFarming=%s | Details=%s | Wiederholungen=%d",
        tostring(hookName or "?"),
        tostring(reason or "unbekannt"),
        workerName,
        tostring(workerId or "nil"),
        math.floor(experience + 0.5),
        HelperPersonnelExperienceEffects.getVehicleLogName(vehicle),
        fillTypeName,
        tonumber(baseUsage) or 0,
        (tonumber(factor) or 0) * 100,
        tostring(vehicle ~= nil and vehicle.isServer ~= false),
        HelperPersonnelExperienceEffects.getVehicleAIActiveText(vehicle),
        tostring(HelperPersonnelExperienceEffects.isSupportedConsumptionFillType(fillType) == true),
        HelperPersonnelExperienceEffects.getPrecisionFarmingDetectionText(),
        tostring(details or "-"),
        state.count or 0
    )

    state.count = 0
end

function HelperPersonnelExperienceEffects.logPrecisionFarmingHookStatus(wearableHookInstalled, sowingHookInstalled, sprayerHookInstalled, motorizedHookInstalled)
    if HelperPersonnelExperienceEffects.PRECISION_FARMING_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    Logging.info("FS25_HelperPersonnel: Precision-Farming-Diagnose Hooks | Wearable.updateDamageAmount=%s | SowingMachine.onEndWorkAreaProcessing=%s | Sprayer.getSprayerUsage=%s | Motorized.updateConsumers=%s | SowingMachineVorhanden=%s | SprayerVorhanden=%s | PrecisionFarming=%s",
        tostring(wearableHookInstalled == true),
        tostring(sowingHookInstalled == true),
        tostring(sprayerHookInstalled == true),
        tostring(motorizedHookInstalled == true),
        tostring(SowingMachine ~= nil),
        tostring(Sprayer ~= nil),
        HelperPersonnelExperienceEffects.getPrecisionFarmingDetectionText()
    )
end

function HelperPersonnelExperienceEffects.logFuelIfNeeded(vehicle, worker, fillType, baseUsage, extraUsage, resultUsage, factor)
    if HelperPersonnelExperienceEffects.FUEL_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    baseUsage = tonumber(baseUsage) or 0
    extraUsage = tonumber(extraUsage) or 0
    resultUsage = tonumber(resultUsage) or 0

    if baseUsage <= 0 and extraUsage <= 0 and resultUsage <= 0 then
        return
    end

    local key = HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle)
    if key == nil then
        return
    end

    local fillTypeName = HelperPersonnelExperienceEffects.getFillTypeName(fillType)
    key = key .. ":" .. fillTypeName .. ":Kraftstoff"

    local now = HelperPersonnelExperienceEffects.getCurrentTimeMs()
    local state = HelperPersonnelExperienceEffects._fuelLogStateByVehicle[key]
    if state == nil then
        state = { lastLogTime = -HelperPersonnelExperienceEffects.FUEL_DEBUG_INTERVAL_MS, baseUsage = 0, extraUsage = 0, resultUsage = 0, samples = 0 }
        HelperPersonnelExperienceEffects._fuelLogStateByVehicle[key] = state
    end

    state.baseUsage = (state.baseUsage or 0) + baseUsage
    state.extraUsage = (state.extraUsage or 0) + extraUsage
    state.resultUsage = (state.resultUsage or 0) + resultUsage
    state.samples = (state.samples or 0) + 1

    if now - (state.lastLogTime or 0) < HelperPersonnelExperienceEffects.FUEL_DEBUG_INTERVAL_MS then
        return
    end

    state.lastLogTime = now

    local vehicleName = HelperPersonnelExperienceEffects.getVehicleLogName(vehicle)
    local workerName = HelperPersonnelExperienceEffects.getWorkerLogName(worker)
    local experience = type(worker) == "table" and (tonumber(worker.experience) or 0) or 0

    Logging.info("FS25_HelperPersonnel: Kraftstoff-Test | Mitarbeiter=%s | Erfahrung=%d | Fahrzeug=%s | Fuelltyp=%s | Zusatzfaktor=%.2f%% | BasisVerbrauch=%.4f l | ZusatzVerbrauch=%.4f l | GesamtVerbrauch=%.4f l | Samples=%d",
        workerName,
        math.floor(experience + 0.5),
        vehicleName,
        fillTypeName,
        (factor or 0) * 100,
        state.baseUsage or 0,
        state.extraUsage or 0,
        state.resultUsage or 0,
        state.samples or 0
    )

    state.baseUsage = 0
    state.extraUsage = 0
    state.resultUsage = 0
    state.samples = 0
end

function HelperPersonnelExperienceEffects.getSowingBaseUsage(vehicle, seedUsageScaleOverride)
    if vehicle == nil or vehicle.spec_sowingMachine == nil then
        return 0, nil, "SaeMaschine_Spezialisierung_fehlt", "spec_sowingMachine=nil"
    end

    local spec = vehicle.spec_sowingMachine
    if spec.workAreaParameters == nil then
        return 0, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "Arbeitsflaechenparameter_fehlen", "workAreaParameters=nil"
    end

    local lastChangedArea = tonumber(spec.workAreaParameters.lastChangedArea) or 0
    local seedsFruitType = spec.workAreaParameters.seedsFruitType
    local detailsPrefix = string.format("lastChangedArea=%.4f; seedsFruitType=%s; seedFillType=%s; seedUsageScale=%.4f; PFVehicleSpecs=%s; RootPFVehicleSpecs=%s",
        lastChangedArea,
        tostring(seedsFruitType),
        tostring(spec.seedFillType),
        tonumber(seedUsageScaleOverride or spec.seedUsageScale) or 1,
        HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle),
        HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle)
    )

    if lastChangedArea <= 0 then
        return 0, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "keine_geaenderte_Flaeche", detailsPrefix
    end

    if g_fruitTypeManager == nil then
        return 0, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "FruitTypeManager_fehlt", detailsPrefix
    end

    if g_currentMission == nil or g_currentMission.getFruitPixelsToSqm == nil then
        return 0, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "FruitPixelUmrechnung_fehlt", detailsPrefix
    end

    local fruitDesc = g_fruitTypeManager:getFruitTypeByIndex(seedsFruitType)
    if fruitDesc == nil then
        return 0, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "Fruchtbeschreibung_fehlt", detailsPrefix
    end

    if fruitDesc.seedUsagePerSqm == nil then
        return 0, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "Saatgutverbrauch_der_Frucht_fehlt", detailsPrefix
    end

    local seedUsageScale = tonumber(seedUsageScaleOverride or spec.seedUsageScale) or 1
    local lastHa = MathUtil.areaToHa(lastChangedArea, g_currentMission:getFruitPixelsToSqm())
    local usage = fruitDesc.seedUsagePerSqm * lastHa * 10000 * seedUsageScale

    if vehicle.getVehicleDamage ~= nil then
        local damage = tonumber(vehicle:getVehicleDamage()) or 0
        if damage > 0 and SowingMachine ~= nil and SowingMachine.DAMAGED_USAGE_INCREASE ~= nil then
            usage = usage * (1 + damage * SowingMachine.DAMAGED_USAGE_INCREASE)
        end
    end

    local details = string.format("%s; lastHa=%.8f; seedUsagePerSqm=%.8f", detailsPrefix, tonumber(lastHa) or 0, tonumber(fruitDesc.seedUsagePerSqm) or 0)
    return math.max(0, usage), spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), "ok", details
end

function HelperPersonnelExperienceEffects.onSowingMachineEndWorkAreaProcessing(vehicle, superFunc, dt, hasProcessed, ...)
    if vehicle == nil then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("SowingMachine.onEndWorkAreaProcessing", vehicle, FillType ~= nil and FillType.SEEDS or nil, "Fahrzeug_nil", "dt=" .. tostring(dt) .. "; hasProcessed=" .. tostring(hasProcessed), 0, 0, nil, nil)
        return superFunc(vehicle, dt, hasProcessed, ...)
    end

    if vehicle.isServer == false then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("SowingMachine.onEndWorkAreaProcessing", vehicle, FillType ~= nil and FillType.SEEDS or nil, "Client_uebersprungen", "dt=" .. tostring(dt) .. "; hasProcessed=" .. tostring(hasProcessed), 0, 0, nil, nil)
        return superFunc(vehicle, dt, hasProcessed, ...)
    end

    local spec = vehicle.spec_sowingMachine
    if spec == nil then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("SowingMachine.onEndWorkAreaProcessing", vehicle, FillType ~= nil and FillType.SEEDS or nil, "SaeMaschine_Spezialisierung_fehlt", "dt=" .. tostring(dt) .. "; hasProcessed=" .. tostring(hasProcessed), 0, 0, nil, nil)
        return superFunc(vehicle, dt, hasProcessed, ...)
    end

    local factor, workerId, worker, factorReason = HelperPersonnelExperienceEffects.getConsumptionDiagnosticFactorForVehicle(vehicle, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil))
    if factor <= 0 then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("SowingMachine.onEndWorkAreaProcessing", vehicle, spec.seedFillType or (FillType ~= nil and FillType.SEEDS or nil), factorReason or "Zusatzfaktor_0", "dt=" .. tostring(dt) .. "; hasProcessed=" .. tostring(hasProcessed) .. "; PFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle) .. "; RootPFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle), 0, factor, workerId, worker)
        return superFunc(vehicle, dt, hasProcessed, ...)
    end

    local oldSeedUsageScale = spec.seedUsageScale
    local hpSeedUsageScale = (tonumber(oldSeedUsageScale) or 1) * (1 + factor)
    spec.seedUsageScale = hpSeedUsageScale

    local result = superFunc(vehicle, dt, hasProcessed, ...)

    spec.seedUsageScale = oldSeedUsageScale

    local baseUsage, fillType, usageReason, usageDetails = HelperPersonnelExperienceEffects.getSowingBaseUsage(vehicle, oldSeedUsageScale)
    if baseUsage > 0 then
        local extraUsage = baseUsage * factor
        local seedDetails = string.format("Basis=berechnete_Saatgutmenge_nach_WorkArea_mit_altem_Skalierungswert; seedUsageScaleAlt=%.4f; seedUsageScaleHP=%.4f; dt=%.4f; hasProcessed=%s; %s", tonumber(oldSeedUsageScale) or 1, hpSeedUsageScale, tonumber(dt) or 0, tostring(hasProcessed), tostring(usageDetails or "-"))
        HelperPersonnelExperienceEffects.logConsumptionIfNeeded(vehicle, worker, fillType or (FillType ~= nil and FillType.SEEDS or nil), baseUsage, extraUsage, baseUsage + extraUsage, factor, "Saatgut", seedDetails)
    else
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("SowingMachine.onEndWorkAreaProcessing", vehicle, fillType or (FillType ~= nil and FillType.SEEDS or nil), usageReason or "Basisverbrauch_0", "dt=" .. tostring(dt) .. "; hasProcessed=" .. tostring(hasProcessed) .. "; seedUsageScaleAlt=" .. tostring(oldSeedUsageScale) .. "; seedUsageScaleHP=" .. tostring(hpSeedUsageScale) .. "; " .. tostring(usageDetails or "-"), baseUsage, factor, workerId, worker)
    end

    return result
end

function HelperPersonnelExperienceEffects.onSprayerGetUsage(vehicle, superFunc, fillType, dt, ...)
    local baseUsage = superFunc(vehicle, fillType, dt, ...)
    local numericBaseUsage = tonumber(baseUsage) or 0

    if numericBaseUsage <= 0 then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("Sprayer.getSprayerUsage", vehicle, fillType, "Basisverbrauch_0", "dt=" .. tostring(dt) .. "; PFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle) .. "; RootPFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle), numericBaseUsage, 0, nil, nil)
        return baseUsage
    end

    if vehicle ~= nil and vehicle.isServer == false then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("Sprayer.getSprayerUsage", vehicle, fillType, "Client_uebersprungen", "dt=" .. tostring(dt) .. "; PFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle), numericBaseUsage, 0, nil, nil)
        return baseUsage
    end

    if not HelperPersonnelExperienceEffects.isSupportedConsumptionFillType(fillType) then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("Sprayer.getSprayerUsage", vehicle, fillType, "Fuelltyp_nicht_unterstuetzt", "dt=" .. tostring(dt) .. "; PFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle) .. "; RootPFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle), numericBaseUsage, 0, nil, nil)
        return baseUsage
    end

    local factor, workerId, worker, factorReason = HelperPersonnelExperienceEffects.getConsumptionDiagnosticFactorForVehicle(vehicle, fillType)
    if factor <= 0 then
        HelperPersonnelExperienceEffects.logConsumptionDiagnosticIfNeeded("Sprayer.getSprayerUsage", vehicle, fillType, factorReason or "Zusatzfaktor_0", "dt=" .. tostring(dt) .. "; PFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle) .. "; RootPFVehicleSpecs=" .. HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle), numericBaseUsage, factor, workerId, worker)
        return baseUsage
    end

    local extraUsage = numericBaseUsage * factor
    local resultUsage = numericBaseUsage + extraUsage
    local sourceName = HelperPersonnelExperienceEffects.getConsumptionSourceName(fillType)

    local sprayerDetails = string.format("Basis=Rueckgabe_von_Sprayer.getSprayerUsage_vor_HP_Faktor; dt=%.4f; PFVehicleSpecs=%s; RootPFVehicleSpecs=%s", tonumber(dt) or 0, HelperPersonnelExperienceEffects.getPrecisionFarmingVehicleDetails(vehicle), HelperPersonnelExperienceEffects.getRootVehiclePrecisionFarmingDetails(vehicle))
    HelperPersonnelExperienceEffects.logConsumptionIfNeeded(vehicle, worker, fillType, numericBaseUsage, extraUsage, resultUsage, factor, sourceName, sprayerDetails)

    return resultUsage
end

function HelperPersonnelExperienceEffects.getMotorizedFuelBaseUsage(vehicle, consumer, dt)
    if vehicle == nil or consumer == nil then
        return 0
    end

    dt = tonumber(dt) or 0
    local consumerUsage = tonumber(consumer.usage) or 0
    if dt <= 0 or consumerUsage <= 0 then
        return 0
    end

    local spec = vehicle.spec_motorized
    if spec == nil or spec.motor == nil then
        return 0
    end

    local motor = spec.motor
    local minRpm = tonumber(motor.minRpm) or 0
    local maxRpm = tonumber(motor.maxRpm) or minRpm
    if maxRpm <= minRpm then
        return 0
    end

    local lastMotorRpm = tonumber(motor.lastMotorRpm) or minRpm
    local rpmPercentage = (lastMotorRpm - minRpm) / (maxRpm - minRpm)
    rpmPercentage = HelperPersonnelExperienceEffects.clamp(rpmPercentage, 0, 1)

    local idleFactor = 0.5
    local rpmFactor = idleFactor + rpmPercentage * (1 - idleFactor)
    local loadFactor = math.max((tonumber(spec.smoothedLoadPercentage) or 0) * rpmPercentage, 0)
    local motorFactor = 0.5 * ((0.2 * rpmFactor) + (1.8 * loadFactor))

    local fuelUsage = 2
    if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
        fuelUsage = math.floor((tonumber(g_currentMission.missionInfo.fuelUsage) or 2) + 0.5)
    end

    local usageFactor = 1.5
    if fuelUsage == 1 then
        usageFactor = 1.0
    elseif fuelUsage == 3 then
        usageFactor = 2.5
    end

    if vehicle.getVehicleDamage ~= nil and Motorized ~= nil and Motorized.DAMAGED_USAGE_INCREASE ~= nil then
        local damage = tonumber(vehicle:getVehicleDamage()) or 0
        if damage > 0 then
            usageFactor = usageFactor * (1 + damage * Motorized.DAMAGED_USAGE_INCREASE)
        end
    end

    return math.max(0, usageFactor * motorFactor * consumerUsage * dt)
end

function HelperPersonnelExperienceEffects.onMotorizedUpdateConsumers(vehicle, superFunc, dt, accInput, ...)
    if vehicle == nil or vehicle.isServer == false then
        return superFunc(vehicle, dt, accInput, ...)
    end

    if vehicle.getIsAIActive == nil or not vehicle:getIsAIActive() then
        return superFunc(vehicle, dt, accInput, ...)
    end

    local spec = vehicle.spec_motorized
    if spec == nil or spec.consumers == nil then
        return superFunc(vehicle, dt, accInput, ...)
    end

    local factor, workerId, worker = HelperPersonnelExperienceEffects.getAdditionalFuelFactorForVehicle(vehicle)
    if factor <= 0 then
        return superFunc(vehicle, dt, accInput, ...)
    end

    local adjustedConsumers = {}
    local logEntries = {}

    for _, consumer in pairs(spec.consumers) do
        if consumer.permanentConsumption and (tonumber(consumer.usage) or 0) > 0 and HelperPersonnelExperienceEffects.isSupportedFuelFillType(consumer.fillType) then
            local baseUsage = HelperPersonnelExperienceEffects.getMotorizedFuelBaseUsage(vehicle, consumer, dt)
            if baseUsage > 0 then
                table.insert(logEntries, { fillType = consumer.fillType, baseUsage = baseUsage })
            end

            table.insert(adjustedConsumers, { consumer = consumer, oldUsage = consumer.usage })
            consumer.usage = (tonumber(consumer.usage) or 0) * (1 + factor)
        end
    end

    if #adjustedConsumers == 0 then
        return superFunc(vehicle, dt, accInput, ...)
    end

    local result = superFunc(vehicle, dt, accInput, ...)

    for _, entry in ipairs(adjustedConsumers) do
        if entry.consumer ~= nil then
            entry.consumer.usage = entry.oldUsage
        end
    end

    for _, entry in ipairs(logEntries) do
        local extraUsage = entry.baseUsage * factor
        HelperPersonnelExperienceEffects.logFuelIfNeeded(vehicle, worker, entry.fillType, entry.baseUsage, extraUsage, entry.baseUsage + extraUsage, factor)
    end

    return result
end

function HelperPersonnelExperienceEffects.onUpdateDamageAmount(vehicle, superFunc, dt, ...)
    local baseChange = superFunc(vehicle, dt, ...)
    local numericBaseChange = tonumber(baseChange) or 0

    if numericBaseChange <= 0 then
        return baseChange
    end

    if vehicle ~= nil and vehicle.isServer == false then
        return baseChange
    end

    local factor, workerId, worker = HelperPersonnelExperienceEffects.getAdditionalWearFactorForVehicle(vehicle)
    if factor <= 0 then
        return baseChange
    end

    local extraChange = numericBaseChange * factor
    local resultChange = numericBaseChange + extraChange

    HelperPersonnelExperienceEffects.logWearIfNeeded(vehicle, worker, numericBaseChange, extraChange, factor, resultChange)

    return resultChange
end

function HelperPersonnelExperienceEffects.getReliabilityStateKey(vehicle, workerId)
    local vehicleKey = HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle)
    if vehicleKey == nil then
        return nil
    end

    return tostring(vehicleKey) .. ":worker:" .. tostring(workerId or "unknown")
end

function HelperPersonnelExperienceEffects.getEffectiveReliabilityForWorker(manager, worker)
    if manager ~= nil and manager.getEffectiveGameplayReliability ~= nil then
        return manager:getEffectiveGameplayReliability(worker, "slowdown")
    end

    if manager ~= nil and manager.clampPersonStat ~= nil and type(worker) == "table" then
        return manager:clampPersonStat(worker.reliability or 0)
    end

    return HelperPersonnelExperienceEffects.clamp(type(worker) == "table" and (worker.reliability or 0) or 100, 0, 100)
end

function HelperPersonnelExperienceEffects.logReliabilityCheck(vehicle, worker, reliability, effectiveReliability, chance, triggered, penalty, durationMs, reason)
    if HelperPersonnelExperienceEffects.RELIABILITY_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    local vehicleName = HelperPersonnelExperienceEffects.getVehicleLogName(vehicle)
    local workerName = HelperPersonnelExperienceEffects.getWorkerLogName(worker)

    Logging.info("FS25_HelperPersonnel: Zuverlaessigkeit-Test | Mitarbeiter=%s | Zuverlaessigkeit=%d | wirksameZuverlaessigkeit=%d | Fahrzeug=%s | Chance=%.2f%% | Ausgeloest=%s | Einbruch=%.2f%% | Dauer=%.0fs | Grund=%s",
        workerName,
        math.floor((tonumber(reliability) or 0) + 0.5),
        math.floor((tonumber(effectiveReliability) or 0) + 0.5),
        vehicleName,
        (tonumber(chance) or 0) * 100,
        tostring(triggered == true),
        (tonumber(penalty) or 0) * 100,
        (tonumber(durationMs) or 0) / 1000,
        tostring(reason or "Pruefung")
    )
end

function HelperPersonnelExperienceEffects.getReliabilitySlowdownFactorForVehicle(vehicle, workerId, worker)
    if g_helperPersonnelApp == nil or g_helperPersonnelApp.manager == nil then
        return 1
    end

    if vehicle ~= nil and vehicle.isServer == false then
        return 1
    end

    local manager = g_helperPersonnelApp.manager
    if worker == nil and workerId ~= nil and manager.getWorkerById ~= nil then
        worker = manager:getWorkerById(workerId)
    end

    if type(worker) ~= "table" then
        return 1
    end

    local reliability = manager.clampPersonStat ~= nil and manager:clampPersonStat(worker.reliability or 0) or HelperPersonnelExperienceEffects.clamp(worker.reliability or 0, 0, 100)
    local effectiveReliability = HelperPersonnelExperienceEffects.getEffectiveReliabilityForWorker(manager, worker)
    local reliabilityEffectEnabled = manager.isGameplayExperienceEffectEnabled == nil or manager:isGameplayExperienceEffectEnabled("reliability")

    local stateKey = HelperPersonnelExperienceEffects.getReliabilityStateKey(vehicle, workerId or worker.id)
    if stateKey == nil then
        return 1
    end

    local now = HelperPersonnelExperienceEffects.getCurrentTimeMs()
    local state = HelperPersonnelExperienceEffects._reliabilitySlowdownStateByVehicle[stateKey]
    if state == nil then
        state = { lastCheckTime = -HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_CHECK_INTERVAL_MS, cooldownUntil = 0, activeUntil = 0, activePenalty = 0 }
        HelperPersonnelExperienceEffects._reliabilitySlowdownStateByVehicle[stateKey] = state
    end

    if state.activeUntil ~= nil and state.activeUntil > now and (tonumber(state.activePenalty) or 0) > 0 then
        return math.max(0, 1 - (tonumber(state.activePenalty) or 0))
    end

    if (tonumber(state.activePenalty) or 0) > 0 and (tonumber(state.activeUntil) or 0) > 0 and now >= (tonumber(state.activeUntil) or 0) then
        HelperPersonnelExperienceEffects.logReliabilityCheck(vehicle, worker, reliability, effectiveReliability, 0, false, 0, 0, "Einbruch beendet")
        state.activePenalty = 0
        state.activeUntil = 0
    end

    if reliabilityEffectEnabled ~= true or effectiveReliability >= HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_RELIABILITY then
        return 1
    end

    if now < (state.cooldownUntil or 0) then
        return 1
    end

    if now - (state.lastCheckTime or 0) < HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_CHECK_INTERVAL_MS then
        return 1
    end

    state.lastCheckTime = now

    local unreliability = (100 - effectiveReliability) / 100
    unreliability = HelperPersonnelExperienceEffects.clamp(unreliability, 0, 1)

    local chance = HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MAX_CHANCE_PER_CHECK * (unreliability ^ HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_CHANCE_EXPONENT)
    local durationMs = HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_DURATION_MS + ((HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MAX_DURATION_MS - HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_DURATION_MS) * unreliability)
    local penalty = HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_PENALTY + ((HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MAX_PENALTY - HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_MIN_PENALTY) * unreliability)
    local triggered = math.random() < chance

    HelperPersonnelExperienceEffects.logReliabilityCheck(vehicle, worker, reliability, effectiveReliability, chance, triggered, penalty, durationMs, "Pruefung")

    if triggered then
        if manager ~= nil and manager.recordWorkerReliabilityIncident ~= nil then
            manager:recordWorkerReliabilityIncident(worker, "slowdown")
        end

        state.activePenalty = penalty
        state.activeUntil = now + durationMs
        state.cooldownUntil = now + HelperPersonnelExperienceEffects.RELIABILITY_SLOWDOWN_COOLDOWN_MS
        return math.max(0, 1 - penalty)
    end

    return 1
end

function HelperPersonnelExperienceEffects.logSpeedIfNeeded(vehicle, worker, experienceFactor, reliabilityFactor, finalFactor)
    if HelperPersonnelExperienceEffects.SPEED_DEBUG_LOGGING ~= true then
        return
    end

    if type(worker) ~= "table" or Logging == nil or Logging.info == nil then
        return
    end

    local key = HelperPersonnelExperienceEffects.getVehicleLogKey(vehicle)
    if key == nil then
        return
    end

    key = tostring(key) .. ":speed:worker:" .. tostring(worker.id or "unknown")
    local now = HelperPersonnelExperienceEffects.getCurrentTimeMs()
    local state = HelperPersonnelExperienceEffects._speedLogStateByVehicle[key]
    if state == nil then
        state = { lastLogTime = -HelperPersonnelExperienceEffects.SPEED_DEBUG_INTERVAL_MS }
        HelperPersonnelExperienceEffects._speedLogStateByVehicle[key] = state
    end

    if now - (state.lastLogTime or 0) < HelperPersonnelExperienceEffects.SPEED_DEBUG_INTERVAL_MS then
        return
    end

    state.lastLogTime = now

    local manager = g_helperPersonnelApp ~= nil and g_helperPersonnelApp.manager or nil
    local experience = type(worker) == "table" and (tonumber(worker.experience) or 0) or 0
    local reliability = type(worker) == "table" and (tonumber(worker.reliability) or 0) or 0
    local effectiveExperience = experience
    local effectiveReliability = reliability
    local speedEnabled = true
    local reliabilityEnabled = true

    if manager ~= nil then
        if manager.getEffectiveGameplayExperience ~= nil then
            effectiveExperience = manager:getEffectiveGameplayExperience(worker, "speed", vehicle)
        end
        if manager.getEffectiveGameplayReliability ~= nil then
            effectiveReliability = manager:getEffectiveGameplayReliability(worker, "slowdown")
        end
        if manager.isGameplayExperienceEffectEnabled ~= nil then
            speedEnabled = manager:isGameplayExperienceEffectEnabled("speed")
            reliabilityEnabled = manager:isGameplayExperienceEffectEnabled("reliability")
        end
    end

    Logging.info("FS25_HelperPersonnel: Geschwindigkeit-Test | Mitarbeiter=%s | Erfahrung=%d | wirksameErfahrung=%d | Zuverlaessigkeit=%d | wirksameZuverlaessigkeit=%d | Fahrzeug=%s | Erfahrungsfaktor=%.2f%% | Zuverlaessigkeitsfaktor=%.2f%% | Gesamtfaktor=%.2f%% | ConfigGeschwindigkeit=%s | ConfigZuverlaessigkeit=%s",
        HelperPersonnelExperienceEffects.getWorkerLogName(worker),
        math.floor((tonumber(experience) or 0) + 0.5),
        math.floor((tonumber(effectiveExperience) or 0) + 0.5),
        math.floor((tonumber(reliability) or 0) + 0.5),
        math.floor((tonumber(effectiveReliability) or 0) + 0.5),
        HelperPersonnelExperienceEffects.getVehicleLogName(vehicle),
        (tonumber(experienceFactor) or 1) * 100,
        (tonumber(reliabilityFactor) or 1) * 100,
        (tonumber(finalFactor) or 1) * 100,
        tostring(speedEnabled == true),
        tostring(reliabilityEnabled == true)
    )
end

function HelperPersonnelExperienceEffects.adjustMaxSpeed(vehicle, maxSpeed)
    if maxSpeed == nil then
        return maxSpeed
    end

    maxSpeed = tonumber(maxSpeed)
    if maxSpeed == nil or maxSpeed == math.huge or maxSpeed <= 0 then
        return maxSpeed
    end

    local factor = HelperPersonnelExperienceEffects.getSpeedFactorForVehicle(vehicle)
    if factor >= 0.999 then
        return maxSpeed
    end

    return math.max(HelperPersonnelExperienceEffects.MIN_CAP_SPEED, maxSpeed * factor)
end

function HelperPersonnelExperienceEffects.onDriveToPoint(vehicle, superFunc, dt, acceleration, isAllowedToDrive, moveForwards, targetX, targetZ, maxSpeed, ...)
    maxSpeed = HelperPersonnelExperienceEffects.adjustMaxSpeed(vehicle, maxSpeed)
    return superFunc(vehicle, dt, acceleration, isAllowedToDrive, moveForwards, targetX, targetZ, maxSpeed, ...)
end

function HelperPersonnelExperienceEffects.onDriveAlongCurvature(vehicle, superFunc, dt, curvature, maxSpeed, ...)
    maxSpeed = HelperPersonnelExperienceEffects.adjustMaxSpeed(vehicle, maxSpeed)
    return superFunc(vehicle, dt, curvature, maxSpeed, ...)
end

function HelperPersonnelExperienceEffects.install()
    if HelperPersonnelExperienceEffects.isInstalled then
        return
    end

    HelperPersonnelExperienceEffects.isInstalled = true

    HelperPersonnelExperienceEffects.logPrecisionFarmingDiagnosticsStart()

    if AIVehicleUtil ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        if AIVehicleUtil.driveToPoint ~= nil then
            AIVehicleUtil.driveToPoint = Utils.overwrittenFunction(AIVehicleUtil.driveToPoint, HelperPersonnelExperienceEffects.onDriveToPoint)
        end

        if AIVehicleUtil.driveAlongCurvature ~= nil then
            AIVehicleUtil.driveAlongCurvature = Utils.overwrittenFunction(AIVehicleUtil.driveAlongCurvature, HelperPersonnelExperienceEffects.onDriveAlongCurvature)
        end
    end

    local wearableHookInstalled = false
    local sowingHookInstalled = false
    local sprayerHookInstalled = false
    local motorizedHookInstalled = false

    if Wearable ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        if Wearable.updateDamageAmount ~= nil then
            Wearable.updateDamageAmount = Utils.overwrittenFunction(Wearable.updateDamageAmount, HelperPersonnelExperienceEffects.onUpdateDamageAmount)
            wearableHookInstalled = true
        end
    end

    if SowingMachine ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        if SowingMachine.onEndWorkAreaProcessing ~= nil then
            SowingMachine.onEndWorkAreaProcessing = Utils.overwrittenFunction(SowingMachine.onEndWorkAreaProcessing, HelperPersonnelExperienceEffects.onSowingMachineEndWorkAreaProcessing)
            sowingHookInstalled = true
        end
    end

    if Sprayer ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        if Sprayer.getSprayerUsage ~= nil then
            Sprayer.getSprayerUsage = Utils.overwrittenFunction(Sprayer.getSprayerUsage, HelperPersonnelExperienceEffects.onSprayerGetUsage)
            sprayerHookInstalled = true
        end
    end

    if Motorized ~= nil and Utils ~= nil and Utils.overwrittenFunction ~= nil then
        if Motorized.updateConsumers ~= nil then
            Motorized.updateConsumers = Utils.overwrittenFunction(Motorized.updateConsumers, HelperPersonnelExperienceEffects.onMotorizedUpdateConsumers)
            motorizedHookInstalled = true
        end
    end

    HelperPersonnelExperienceEffects.logPrecisionFarmingHookStatus(wearableHookInstalled, sowingHookInstalled, sprayerHookInstalled, motorizedHookInstalled)
end

function HelperPersonnelManager:getWorkerWorkSpeedMultiplier(workerOrId, vehicle)
    local worker = workerOrId
    if type(workerOrId) ~= "table" then
        worker = self:getWorkerById(workerOrId)
    end

    if worker == nil then
        return 1
    end

    if self.isGameplayExperienceEffectEnabled ~= nil and not self:isGameplayExperienceEffectEnabled("speed") then
        return 1
    end

    local experience = self.getEffectiveGameplayExperience ~= nil and self:getEffectiveGameplayExperience(worker, "speed", vehicle) or self:clampPersonStat(worker.experience or 0)
    local minFactor = HelperPersonnelExperienceEffects.MIN_WORK_SPEED_FACTOR
    local maxFactor = HelperPersonnelExperienceEffects.MAX_WORK_SPEED_FACTOR

    return minFactor + ((maxFactor - minFactor) * (experience / 100))
end

function HelperPersonnelManager:getWorkerWorkSpeedPercent(workerOrId)
    return math.floor((self:getWorkerWorkSpeedMultiplier(workerOrId) * 100) + 0.5)
end

if HelperPersonnelNetwork ~= nil then
    HelperPersonnelNetwork.ACTION_TRAIN_WORKER = HelperPersonnelNetwork.ACTION_TRAIN_WORKER or "trainWorker"
end

local HP_TRAIN_ORIGINAL_APP_REQUEST_TRAIN_WORKER = HelperPersonnelApp ~= nil and HelperPersonnelApp.requestTrainWorker or nil
if HelperPersonnelApp ~= nil then
    function HelperPersonnelApp:requestTrainWorker(workerId)
        local farmId = self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1

        if self.isServerAuthority ~= nil and self:isServerAuthority() then
            local changed = self.manager ~= nil and self.manager.trainWorkerForFarm ~= nil and self.manager:trainWorkerForFarm(workerId, farmId) == true
            if changed and self.syncNetworkStateToClients ~= nil then
                self:syncNetworkStateToClients()
            end
            return changed
        end

        if self.isMultiplayerClient ~= nil and self:isMultiplayerClient() and g_client ~= nil and HelperPersonnelNetworkActionEvent ~= nil then
            local connection = g_client.getServerConnection ~= nil and g_client:getServerConnection() or nil
            if connection ~= nil and connection.sendEvent ~= nil then
                connection:sendEvent(HelperPersonnelNetworkActionEvent.new(HelperPersonnelNetwork.ACTION_TRAIN_WORKER, workerId, nil, farmId))
                return true
            end
        end

        if HP_TRAIN_ORIGINAL_APP_REQUEST_TRAIN_WORKER ~= nil then
            return HP_TRAIN_ORIGINAL_APP_REQUEST_TRAIN_WORKER(self, workerId)
        end

        return false
    end

    local HP_TRAIN_ORIGINAL_APP_PROCESS_NETWORK_ACTION = HelperPersonnelApp.processNetworkAction
    function HelperPersonnelApp:processNetworkAction(actionName, targetId, connection, farmId)
        if HelperPersonnelNetwork ~= nil and actionName == HelperPersonnelNetwork.ACTION_TRAIN_WORKER then
            if self.isServerAuthority == nil or not self:isServerAuthority() or self.manager == nil then
                return false
            end

            local allowed = true
            local authorizedFarmId = farmId
            if self.resolveAuthorizedFarmId ~= nil then
                allowed, authorizedFarmId = self:resolveAuthorizedFarmId(connection, farmId, nil, actionName)
            else
                authorizedFarmId = tonumber(farmId) or (self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1)
            end

            if not allowed then
                if connection ~= nil and self.sendNetworkStateToConnection ~= nil then
                    self:sendNetworkStateToConnection(connection)
                end
                return false
            end

            if self.manager.hasWorkerInFarm ~= nil and self.manager:hasWorkerInFarm(targetId, authorizedFarmId) ~= true then
                if connection ~= nil and self.sendNetworkStateToConnection ~= nil then
                    self:sendNetworkStateToConnection(connection)
                end
                return false
            end

            local changed = self.manager.trainWorkerForFarm ~= nil and self.manager:trainWorkerForFarm(targetId, authorizedFarmId) == true
            if changed then
                if self.syncNetworkStateToClients ~= nil then
                    self:syncNetworkStateToClients()
                end
            elseif connection ~= nil and self.sendNetworkStateToConnection ~= nil then
                self:sendNetworkStateToConnection(connection)
            end
            return changed
        end

        if HP_TRAIN_ORIGINAL_APP_PROCESS_NETWORK_ACTION ~= nil then
            return HP_TRAIN_ORIGINAL_APP_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, farmId)
        end

        return false
    end
end

if HelperPersonnelFrame ~= nil then
    function HelperPersonnelFrame:getSelectedWorkerForTrainingAction()
        if self.mode ~= HelperPersonnelFrame.MODE_WORKERS then
            return nil
        end

        local workers = self:getWorkers()
        local worker = workers ~= nil and workers[self.workerIndex] or nil
        if worker == nil then
            return nil
        end

        return worker
    end

    function HelperPersonnelFrame:onClickTrainWorker()
        local worker = self:getSelectedWorkerForTrainingAction()
        if worker == nil then
            return false
        end

        local changed = false
        if self.app ~= nil and self.app.requestTrainWorker ~= nil then
            changed = self.app:requestTrainWorker(worker.id) == true
        else
            local manager = self:getManager()
            if manager ~= nil and manager.trainWorker ~= nil then
                changed = manager:trainWorker(worker.id) == true
            end
        end

        if changed then
            self.requestRender = true
            if self.updateButtons ~= nil then
                self:updateButtons()
            end
        end

        return true
    end

    local HP_TRAIN_ORIGINAL_FRAME_KEY_EVENT = HelperPersonnelFrame.keyEvent
    function HelperPersonnelFrame:keyEvent(unicode, sym, modifier, isDown)
        if isDown and self.mode == HelperPersonnelFrame.MODE_WORKERS and Input ~= nil and Input.KEY_s ~= nil and sym == Input.KEY_s then
            return self:onClickTrainWorker()
        end

        if HP_TRAIN_ORIGINAL_FRAME_KEY_EVENT ~= nil then
            return HP_TRAIN_ORIGINAL_FRAME_KEY_EVENT(self, unicode, sym, modifier, isDown)
        end

        return false
    end
end
