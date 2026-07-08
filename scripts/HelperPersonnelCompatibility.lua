HelperPersonnelCompatibility = HelperPersonnelCompatibility or {}
HelperPersonnelCompatibility.DEBUG_LOGGING = false
HelperPersonnelCompatibility.FOLLOWME_DIAGNOSTIC_LOGGING = false

local function hpCompatSafeCall(object, methodName, ...)
    if object == nil or methodName == nil or object[methodName] == nil then
        return nil
    end

    local success, result = pcall(object[methodName], object, ...)
    if success then
        return result
    end

    return nil
end

local function hpCompatToLower(value)
    if value == nil then
        return ""
    end

    return string.lower(tostring(value))
end

local function hpCompatContainsAny(value, needles)
    local text = hpCompatToLower(value)
    if text == "" then
        return false
    end

    for _, needle in ipairs(needles) do
        if string.find(text, needle, 1, true) ~= nil then
            return true
        end
    end

    return false
end

local function hpCompatGetClassText(object)
    if object == nil then
        return ""
    end

    local parts = {}
    local function add(value)
        if value ~= nil then
            table.insert(parts, tostring(value))
        end
    end

    if type(object) == "table" then
        add(object.className)
        add(object.typeName)
        add(object.name)
        add(object.typeId)
        local mt = getmetatable(object)
        if type(mt) == "table" then
            add(mt.__name)
            add(mt.className)
            add(mt.typeName)
        end
    end

    add(object)
    return table.concat(parts, " ")
end

local function hpCompatLog(message, ...)
    if (HelperPersonnelCompatibility.DEBUG_LOGGING == true or HelperPersonnelCompatibility.FOLLOWME_DIAGNOSTIC_LOGGING == true) and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

local function hpCompatDescribeVehicle(vehicle)
    if vehicle == nil then
        return "nil"
    end

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getDebugVehicleName ~= nil then
        return HelperPersonnelAIStartHooks.getDebugVehicleName(vehicle)
    end

    local name = hpCompatSafeCall(vehicle, "getName") or hpCompatSafeCall(vehicle, "getFullName")
    if name ~= nil and name ~= "" then
        return tostring(name)
    end

    if vehicle.configFileName ~= nil then
        return tostring(vehicle.configFileName)
    end

    return hpCompatGetClassText(vehicle)
end

local function hpCompatDescribeJob(job)
    if job == nil then
        return "nil"
    end

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getDebugJobName ~= nil then
        return HelperPersonnelAIStartHooks.getDebugJobName(job)
    end

    return hpCompatGetClassText(job)
end

local function hpCompatCountKeys(values)
    if type(values) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(values) do
        count = count + 1
    end
    return count
end

local function hpCompatGetVehicleKey(vehicle)
    local app = g_helperPersonnelApp
    if app ~= nil and app.getVehicleKey ~= nil then
        local ok, key = pcall(app.getVehicleKey, app, vehicle)
        if ok and key ~= nil then
            return key
        end
    end

    if vehicle ~= nil then
        if vehicle.getUniqueId ~= nil then
            local ok, key = pcall(vehicle.getUniqueId, vehicle)
            if ok and key ~= nil then
                return tostring(key)
            end
        end

        if vehicle.rootNode ~= nil then
            return tostring(vehicle.rootNode)
        end
    end

    return tostring(vehicle)
end

function HelperPersonnelCompatibility.reserveFollowMeWorker(vehicle, workerId)
    if vehicle == nil or workerId == nil then
        return false
    end

    HelperPersonnelCompatibility.followMeReservedWorkerIdsByVehicleKey = HelperPersonnelCompatibility.followMeReservedWorkerIdsByVehicleKey or {}
    local key = hpCompatGetVehicleKey(vehicle)
    HelperPersonnelCompatibility.followMeReservedWorkerIdsByVehicleKey[key] = workerId
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | reserveWorker | Fahrzeug=%s | Key=%s | Mitarbeiter=%s", hpCompatDescribeVehicle(vehicle), tostring(key), tostring(workerId))
    return true
end

function HelperPersonnelCompatibility.consumeReservedFollowMeWorker(vehicle)
    if vehicle == nil then
        return nil
    end

    local key = hpCompatGetVehicleKey(vehicle)
    local reservations = HelperPersonnelCompatibility.followMeReservedWorkerIdsByVehicleKey
    local workerId = reservations ~= nil and reservations[key] or nil
    if reservations ~= nil then
        reservations[key] = nil
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | consumeReservedWorker | Fahrzeug=%s | Key=%s | Mitarbeiter=%s", hpCompatDescribeVehicle(vehicle), tostring(key), tostring(workerId))
    return workerId
end

function HelperPersonnelCompatibility.peekReservedFollowMeWorker(vehicle)
    if vehicle == nil then
        return nil
    end

    local reservations = HelperPersonnelCompatibility.followMeReservedWorkerIdsByVehicleKey
    if reservations == nil then
        return nil
    end

    return reservations[hpCompatGetVehicleKey(vehicle)]
end


function HelperPersonnelCompatibility.reserveFollowMeTrailDrop(vehicle, vehicleToFollow)
    if vehicle == nil or vehicleToFollow == nil then
        return nil
    end

    local key = hpCompatGetVehicleKey(vehicle)
    local index = nil
    local ok = false

    if vehicle.findOptimalClosestTrailDrop ~= nil then
        ok, index = pcall(vehicle.findOptimalClosestTrailDrop, vehicle, vehicleToFollow)
        if not ok then
            index = nil
        end
    end

    local leaderSpec = HelperPersonnelCompatibility.getFollowMeSpec(vehicleToFollow)
    local leaderDropper = leaderSpec ~= nil and leaderSpec.dropperCurrentCount or nil

    HelperPersonnelCompatibility.followMeReservedTrailDropByVehicleKey = HelperPersonnelCompatibility.followMeReservedTrailDropByVehicleKey or {}
    HelperPersonnelCompatibility.followMeReservedTrailDropByVehicleKey[key] = {
        index = index,
        leaderDropper = leaderDropper
    }

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | reserveTrailDrop | Fahrzeug=%s | Ziel=%s | Key=%s | Pcall=%s | Index=%s | LeaderDropper=%s", hpCompatDescribeVehicle(vehicle), hpCompatDescribeVehicle(vehicleToFollow), tostring(key), tostring(ok), tostring(index), tostring(leaderDropper))
    return index
end

function HelperPersonnelCompatibility.consumeReservedFollowMeTrailDrop(vehicle)
    if vehicle == nil then
        return nil
    end

    local key = hpCompatGetVehicleKey(vehicle)
    local reservations = HelperPersonnelCompatibility.followMeReservedTrailDropByVehicleKey
    local reservation = reservations ~= nil and reservations[key] or nil
    if reservations ~= nil then
        reservations[key] = nil
    end

    local index = reservation ~= nil and reservation.index or nil
    local leaderDropper = reservation ~= nil and reservation.leaderDropper or nil
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | consumeTrailDrop | Fahrzeug=%s | Key=%s | Index=%s | LeaderDropper=%s", hpCompatDescribeVehicle(vehicle), tostring(key), tostring(index), tostring(leaderDropper))
    return index, leaderDropper
end

function HelperPersonnelCompatibility.applyReservedFollowMeTrailDrop(vehicle)
    if vehicle == nil then
        return false
    end

    local reservedIndex, leaderDropperAtReserve = HelperPersonnelCompatibility.consumeReservedFollowMeTrailDrop(vehicle)
    local spec = HelperPersonnelCompatibility.getFollowMeSpec(vehicle)
    if spec == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | applyTrailDrop=false | Grund=SpecFehlt | Fahrzeug=%s | Index=%s", hpCompatDescribeVehicle(vehicle), tostring(reservedIndex))
        return false
    end

    local leader = spec.vehicleToFollow
    local leaderSpec = HelperPersonnelCompatibility.getFollowMeSpec(leader)
    local leaderDropperNow = leaderSpec ~= nil and leaderSpec.dropperCurrentCount or nil
    local recalculatedIndex = nil
    local recalculatedOk = false

    if leader ~= nil and vehicle.findOptimalClosestTrailDrop ~= nil then
        recalculatedOk, recalculatedIndex = pcall(vehicle.findOptimalClosestTrailDrop, vehicle, leader)
        if not recalculatedOk then
            recalculatedIndex = nil
        end
    end

    local index = recalculatedIndex or reservedIndex
    local directStart = false
    if leaderDropperNow ~= nil then
        if leaderDropperNow <= 5 then
            index = leaderDropperNow + 1
            directStart = true
        elseif index ~= nil and leaderDropperNow > index then
            index = leaderDropperNow
        end
    end

    if index == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | applyTrailDrop=false | Grund=IndexFehlt | Fahrzeug=%s | Reserviert=%s | Recalc=%s | LeaderNow=%s", hpCompatDescribeVehicle(vehicle), tostring(reservedIndex), tostring(recalculatedIndex), tostring(leaderDropperNow))
        return false
    end

    local oldIndex = spec.followingCurrentCount
    spec.followingCurrentCount = index
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | applyTrailDrop | Fahrzeug=%s | Alt=%s | Neu=%s | Reserviert=%s | Recalc=%s | RecalcOk=%s | LeaderDropperAtReserve=%s | LeaderDropperNow=%s | DirectStart=%s | Active=%s", hpCompatDescribeVehicle(vehicle), tostring(oldIndex), tostring(index), tostring(reservedIndex), tostring(recalculatedIndex), tostring(recalculatedOk), tostring(leaderDropperAtReserve), tostring(leaderDropperNow), tostring(directStart), tostring(spec.isActive))
    return true
end

function HelperPersonnelCompatibility.setActiveFollowMeWorker(vehicle, workerId)
    if vehicle == nil or workerId == nil then
        return false
    end

    local app = g_helperPersonnelApp
    if app == nil or app.manager == nil then
        return false
    end

    HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey = HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey or {}
    local key = hpCompatGetVehicleKey(vehicle)
    HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey[key] = workerId

    if app.helperBridge ~= nil and app.helperBridge.vehicleWorkerIds ~= nil then
        app.helperBridge.vehicleWorkerIds[key] = workerId
    end

    local rootVehicle = vehicle
    if app.getRootVehicle ~= nil then
        rootVehicle = app:getRootVehicle(vehicle)
    end

    local vehicleName = hpCompatDescribeVehicle(rootVehicle)
    if app.getVehicleName ~= nil then
        local ok, resolvedName = pcall(app.getVehicleName, app, rootVehicle)
        if ok and resolvedName ~= nil and resolvedName ~= "" then
            vehicleName = resolvedName
        end
    end

    local started = false
    if app.manager.startWorkerJob ~= nil then
        started = app.manager:startWorkerJob(workerId, vehicleName, key) == true
    elseif app.manager.setWorkerBusy ~= nil then
        app.manager:setWorkerBusy(workerId, true, vehicleName, key)
        started = true
    end

    if started == true then
        local leader = nil
        if HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey ~= nil then
            leader = HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey[key]
        end
        HelperPersonnelCompatibility.applyFollowMeWorkerContext(workerId, vehicle, leader)
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | activeWorkerStart | Fahrzeug=%s | Key=%s | Mitarbeiter=%s | Started=%s", hpCompatDescribeVehicle(vehicle), tostring(key), tostring(workerId), tostring(started))
    return started
end

function HelperPersonnelCompatibility.finishActiveFollowMeWorker(vehicle)
    if vehicle == nil then
        return false
    end

    local key = hpCompatGetVehicleKey(vehicle)
    local active = HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey
    local workerId = active ~= nil and active[key] or nil

    if active ~= nil then
        active[key] = nil
    end

    local reservations = HelperPersonnelCompatibility.followMeReservedWorkerIdsByVehicleKey
    if reservations ~= nil then
        reservations[key] = nil
    end

    HelperPersonnelCompatibility.clearFollowMeWorkerContext(vehicle, workerId)

    local app = g_helperPersonnelApp
    if app ~= nil and app.helperBridge ~= nil and app.helperBridge.vehicleWorkerIds ~= nil then
        app.helperBridge.vehicleWorkerIds[key] = nil
    end

    local finished = false
    if workerId ~= nil and app ~= nil and app.manager ~= nil then
        if app.manager.finishWorkerJob ~= nil then
            finished = app.manager:finishWorkerJob(workerId) == true
        elseif app.manager.setWorkerBusy ~= nil then
            app.manager:setWorkerBusy(workerId, false, "")
            finished = true
        end
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | activeWorkerStop | Fahrzeug=%s | Key=%s | Mitarbeiter=%s | Finished=%s", hpCompatDescribeVehicle(vehicle), tostring(key), tostring(workerId), tostring(finished))
    return finished
end

function HelperPersonnelCompatibility.getActiveFollowMeWorker(vehicle)
    if vehicle == nil then
        return nil
    end

    local active = HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey
    if active == nil then
        return nil
    end

    return active[hpCompatGetVehicleKey(vehicle)]
end

function HelperPersonnelCompatibility.getWorkerByIdFlexible(workerId)
    local app = g_helperPersonnelApp
    if workerId == nil or app == nil or app.manager == nil or app.manager.getWorkerById == nil then
        return nil
    end

    local worker = app.manager:getWorkerById(workerId)
    if worker ~= nil then
        return worker
    end

    local numericId = tonumber(workerId)
    if numericId ~= nil and numericId ~= workerId then
        worker = app.manager:getWorkerById(numericId)
        if worker ~= nil then
            return worker
        end
    end

    local textId = tostring(workerId)
    if textId ~= tostring(numericId) then
        worker = app.manager:getWorkerById(textId)
        if worker ~= nil then
            return worker
        end
    end

    if type(app.manager.workers) == "table" then
        for _, candidate in ipairs(app.manager.workers) do
            if tostring(candidate.id) == tostring(workerId) then
                return candidate
            end
        end
    end

    return nil
end

function HelperPersonnelCompatibility.getWorkerDisplayName(workerId)
    local app = g_helperPersonnelApp
    if workerId == nil or app == nil or app.manager == nil then
        return nil
    end

    local worker = HelperPersonnelCompatibility.getWorkerByIdFlexible(workerId)

    if worker == nil then
        return nil
    end

    if app.manager.getFullName ~= nil then
        local ok, name = pcall(app.manager.getFullName, app.manager, worker)
        if ok and name ~= nil and name ~= "" then
            return name
        end
    end

    local firstName = worker.firstName or ""
    local lastName = worker.lastName or ""
    local name = string.format("%s %s", firstName, lastName)
    if name ~= " " then
        return name
    end

    return tostring(workerId)
end

function HelperPersonnelCompatibility.getLocalizedText(key, fallback)
    if key ~= nil and g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, text = pcall(g_i18n.getText, g_i18n, key)
        if ok and text ~= nil and text ~= "" and text ~= key then
            return text
        end
    end

    return fallback or tostring(key or "")
end

function HelperPersonnelCompatibility.collectAttachedFollowMeObjects(vehicle, result, visited, depth)
    result = result or {}
    visited = visited or {}
    depth = depth or 0

    if vehicle == nil or depth > 4 or visited[vehicle] == true then
        return result
    end

    visited[vehicle] = true
    table.insert(result, vehicle)

    if vehicle.getAttachedImplements ~= nil then
        local ok, attachedImplements = pcall(vehicle.getAttachedImplements, vehicle)
        if ok and type(attachedImplements) == "table" then
            for _, implementInfo in pairs(attachedImplements) do
                local object = nil
                if type(implementInfo) == "table" then
                    object = implementInfo.object or implementInfo.vehicle or implementInfo.implement
                else
                    object = implementInfo
                end

                if object ~= nil then
                    HelperPersonnelCompatibility.collectAttachedFollowMeObjects(object, result, visited, depth + 1)
                end
            end
        end
    end

    return result
end

function HelperPersonnelCompatibility.objectHasAnySpec(object, specNames)
    if object == nil or type(specNames) ~= "table" then
        return false
    end

    for _, specName in ipairs(specNames) do
        if specName ~= nil then
            local fieldName = "spec_" .. tostring(specName)
            if object[fieldName] ~= nil then
                return true
            end

            local text = tostring(specName)
            local lowerFirst = string.lower(string.sub(text, 1, 1)) .. string.sub(text, 2)
            if object["spec_" .. lowerFirst] ~= nil then
                return true
            end

            local upperFirst = string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
            local specialization = _G ~= nil and _G[upperFirst] or nil
            if specialization ~= nil and SpecializationUtil ~= nil and SpecializationUtil.hasSpecialization ~= nil and object.specializations ~= nil then
                local ok, result = pcall(SpecializationUtil.hasSpecialization, specialization, object.specializations)
                if ok and result == true then
                    return true
                end
            end
        end
    end

    return false
end

function HelperPersonnelCompatibility.getFollowMeLeaderWorkerId(vehicleToFollow)
    if vehicleToFollow == nil then
        return nil
    end

    local key = hpCompatGetVehicleKey(vehicleToFollow)
    if HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey ~= nil and HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey[key] ~= nil then
        return HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey[key]
    end

    local app = g_helperPersonnelApp
    if app ~= nil and app.helperBridge ~= nil and app.helperBridge.vehicleWorkerIds ~= nil then
        return app.helperBridge.vehicleWorkerIds[key]
    end

    return nil
end

function HelperPersonnelCompatibility.getFollowMeTargetText(vehicleToFollow)
    local workerId = HelperPersonnelCompatibility.getFollowMeLeaderWorkerId(vehicleToFollow)
    local workerName = HelperPersonnelCompatibility.getWorkerDisplayName(workerId)
    if workerName ~= nil and workerName ~= "" then
        return workerName
    end

    if vehicleToFollow ~= nil then
        local app = g_helperPersonnelApp
        if app ~= nil and app.getRootVehicle ~= nil then
            local okRoot, rootVehicle = pcall(app.getRootVehicle, app, vehicleToFollow)
            if okRoot and rootVehicle ~= nil then
                vehicleToFollow = rootVehicle
            end
        end

        if app ~= nil and app.getVehicleName ~= nil then
            local okName, name = pcall(app.getVehicleName, app, vehicleToFollow)
            if okName and name ~= nil and name ~= "" then
                return tostring(name)
            end
        end
    end

    return hpCompatDescribeVehicle(vehicleToFollow)
end

function HelperPersonnelCompatibility.detectFollowMeActivity(vehicle)
    local app = g_helperPersonnelApp
    local rootVehicle = vehicle
    if app ~= nil and app.getRootVehicle ~= nil then
        local okRoot, resolvedRoot = pcall(app.getRootVehicle, app, vehicle)
        if okRoot and resolvedRoot ~= nil then
            rootVehicle = resolvedRoot
        end
    end

    local objects = HelperPersonnelCompatibility.collectAttachedFollowMeObjects(rootVehicle or vehicle, {}, {}, 0)
    local activitySpecs = {
        {specs = {"combine", "forageHarvester", "harvester", "potatoHarvester", "beetHarvester", "cutter"}, textKey = "ui_activityHarvesting", fallback = "Ernten", specialization = "harvest"},
        {specs = {"mower"}, textKey = "ui_activityMowing", fallback = "Mähen", specialization = "harvest"},
        {specs = {"baler"}, textKey = "ui_activityBaling", fallback = "Pressen", specialization = "harvest"},
        {specs = {"forageWagon", "pickup"}, textKey = "ui_activityCollecting", fallback = "Sammeln", specialization = "harvest"},
        {specs = {"windrower"}, textKey = "ui_activityWindrowing", fallback = "Schwaden", specialization = "harvest"},
        {specs = {"tedder"}, textKey = "ui_activityTedding", fallback = "Wenden", specialization = "harvest"},
        {specs = {"sowingMachine", "planter"}, textKey = "ui_activitySowing", fallback = "Säen", specialization = "sowing"},
        {specs = {"sprayer"}, textKey = "ui_activitySpraying", fallback = "Düngen/Spritzen", specialization = "fertilizing"},
        {specs = {"manureSpreader", "slurryTank"}, textKey = "ui_activityFertilizing", fallback = "Düngen", specialization = "fertilizing"},
        {specs = {"cultivator", "discHarrow", "powerHarrows"}, textKey = "ui_activityCultivating", fallback = "Grubbern", specialization = "tillage"},
        {specs = {"plow", "subsoiler"}, textKey = "ui_activityPlowing", fallback = "Pflügen", specialization = "tillage"},
        {specs = {"roller"}, textKey = "ui_activityRolling", fallback = "Walzen", specialization = "tillage"},
        {specs = {"stonePicker"}, textKey = "ui_activityStonePicking", fallback = "Steine sammeln", specialization = "tillage"},
        {specs = {"weeder", "hoe"}, textKey = "ui_activityWeeding", fallback = "Striegeln", specialization = "plantProtection"},
        {specs = {"mulcher"}, textKey = "ui_activityMulching", fallback = "Mulchen", specialization = "tillage"}
    }

    for _, entry in ipairs(activitySpecs) do
        for _, object in ipairs(objects) do
            if HelperPersonnelCompatibility.objectHasAnySpec(object, entry.specs) then
                return entry.textKey, entry.fallback, entry.specialization, false
            end
        end
    end

    for _, object in ipairs(objects) do
        if HelperPersonnelCompatibility.objectHasAnySpec(object, {"trailer", "dischargeable"}) then
            return "ui_activityTransport", "Transport", "transport", true
        end
    end

    return "ui_activityTransport", "Transport", "transport", true
end

function HelperPersonnelCompatibility.createFollowMeWorkerContext(vehicle, vehicleToFollow, workerId)
    local activityKey, activityFallback, specializationKey, isTransportOnly = HelperPersonnelCompatibility.detectFollowMeActivity(vehicle)
    local targetText = HelperPersonnelCompatibility.getFollowMeTargetText(vehicleToFollow)
    local activityBaseText = HelperPersonnelCompatibility.getLocalizedText(activityKey, activityFallback)
    local activityText
    local fieldText = nil

    if isTransportOnly == true then
        activityText = string.format(HelperPersonnelCompatibility.getLocalizedText("ui_activityFollowMeTransport", "FollowMe bei %s"), targetText or "")
        fieldText = HelperPersonnelCompatibility.getLocalizedText("ui_activeWorkerNoField", "nicht feldgebunden")
    else
        activityText = string.format(HelperPersonnelCompatibility.getLocalizedText("ui_activityFollowMeWork", "FollowMe: %s hinter %s"), activityBaseText or activityFallback or "", targetText or "")
    end

    return {
        vehicle = vehicle,
        leaderVehicle = vehicleToFollow,
        workerId = workerId,
        targetText = targetText,
        activityKey = activityKey,
        activityFallback = activityFallback,
        activityText = activityText,
        fieldText = fieldText,
        specializationKey = specializationKey,
        transportOnly = isTransportOnly == true
    }
end

function HelperPersonnelCompatibility.applyFollowMeWorkerContext(workerId, vehicle, vehicleToFollow)
    if workerId == nil or vehicle == nil then
        return nil
    end

    local app = g_helperPersonnelApp
    if app == nil then
        return nil
    end

    local key = hpCompatGetVehicleKey(vehicle)
    if vehicleToFollow == nil and HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey ~= nil then
        vehicleToFollow = HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey[key]
    end

    local context = HelperPersonnelCompatibility.createFollowMeWorkerContext(vehicle, vehicleToFollow, workerId)

    if app.helperBridge ~= nil then
        app.helperBridge.followMeContextsByWorkerId = app.helperBridge.followMeContextsByWorkerId or {}
        app.helperBridge.followMeContextsByVehicleKey = app.helperBridge.followMeContextsByVehicleKey or {}
        app.helperBridge.followMeContextsByWorkerId[workerId] = context
        app.helperBridge.followMeContextsByWorkerId[tostring(workerId)] = context
        local numericWorkerId = tonumber(workerId)
        if numericWorkerId ~= nil then
            app.helperBridge.followMeContextsByWorkerId[numericWorkerId] = context
        end
        app.helperBridge.followMeContextsByVehicleKey[key] = context
    end

    local worker = HelperPersonnelCompatibility.getWorkerByIdFlexible(workerId)
    if worker ~= nil and app.manager ~= nil then
        context.workerId = worker.id or workerId
        worker.currentJobActivityText = context.activityText
        worker.currentJobActivityKey = context.activityKey
        worker.currentJobActivityFallback = context.activityFallback
        worker.currentJobFollowMeTargetText = context.targetText
        worker.currentJobFieldId = nil
        worker.currentJobFieldText = context.fieldText
        worker.currentJobSpecializationKey = context.specializationKey

        if app.helperBridge ~= nil and app.helperBridge.followMeContextsByWorkerId ~= nil then
            app.helperBridge.followMeContextsByWorkerId[worker.id] = context
            app.helperBridge.followMeContextsByWorkerId[tostring(worker.id)] = context
        end

        if context.specializationKey ~= nil and app.manager.rememberWorkerSpecializationContext ~= nil then
            app.manager:rememberWorkerSpecializationContext(worker, context.specializationKey, 2)
        end
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | workerContext | Fahrzeug=%s | Ziel=%s | Mitarbeiter=%s | WorkerGefunden=%s | Tätigkeit=%s | FeldText=%s | Spez=%s", hpCompatDescribeVehicle(vehicle), hpCompatDescribeVehicle(vehicleToFollow), tostring(workerId), tostring(worker ~= nil), tostring(context.activityText), tostring(context.fieldText), tostring(context.specializationKey))
    return context
end

function HelperPersonnelCompatibility.clearFollowMeWorkerContext(vehicle, workerId)
    local app = g_helperPersonnelApp
    local key = vehicle ~= nil and hpCompatGetVehicleKey(vehicle) or nil

    if app ~= nil and app.helperBridge ~= nil then
        if workerId ~= nil and app.helperBridge.followMeContextsByWorkerId ~= nil then
            app.helperBridge.followMeContextsByWorkerId[workerId] = nil
        end
        if key ~= nil and app.helperBridge.followMeContextsByVehicleKey ~= nil then
            app.helperBridge.followMeContextsByVehicleKey[key] = nil
        end
    end

    if workerId ~= nil and app ~= nil and app.manager ~= nil then
        local worker = HelperPersonnelCompatibility.getWorkerByIdFlexible(workerId)
        if worker ~= nil then
            worker.currentJobActivityText = nil
            worker.currentJobActivityKey = nil
            worker.currentJobActivityFallback = nil
            worker.currentJobFollowMeTargetText = nil
            worker.currentJobFieldId = nil
            worker.currentJobFieldText = nil
        end
    end
end

function HelperPersonnelCompatibility.getMessageText(aiMessage)
    if aiMessage ~= nil and aiMessage.getMessage ~= nil then
        local ok, text = pcall(aiMessage.getMessage, aiMessage)
        if ok and text ~= nil then
            return tostring(text)
        end
    end

    return nil
end


HelperPersonnelFollowMeAIMessage = HelperPersonnelFollowMeAIMessage or {}

function HelperPersonnelCompatibility.ensureFollowMeAIMessageClass()
    if HelperPersonnelFollowMeAIMessage.helperPersonnelClassReady == true then
        return true
    end

    if AIMessage == nil or Class == nil then
        return false
    end

    HelperPersonnelFollowMeAIMessage_mt = Class(HelperPersonnelFollowMeAIMessage, AIMessage)

    function HelperPersonnelFollowMeAIMessage.new(text, customMt)
        local self = AIMessage.new(customMt or HelperPersonnelFollowMeAIMessage_mt)
        self.helperPersonnelText = text
        return self
    end

    function HelperPersonnelFollowMeAIMessage:getMessage()
        return self.helperPersonnelText or ""
    end

    HelperPersonnelFollowMeAIMessage.helperPersonnelClassReady = true
    return true
end

function HelperPersonnelCompatibility.createFollowMeWorkerAIMessage(workerId, aiMessage)
    local workerName = HelperPersonnelCompatibility.getWorkerDisplayName(workerId) or tostring(workerId)
    local originalText = HelperPersonnelCompatibility.getMessageText(aiMessage) or ""
    local lowerText = hpCompatToLower(originalText)
    local text = nil

    if string.find(lowerText, "gefolgsmann", 1, true) ~= nil then
        text = string.format("%s hat den FollowMe-Job beendet: Gefolgsmann blieb stehen.", workerName)
    elseif string.find(lowerText, "blocked", 1, true) ~= nil or string.find(lowerText, "blockiert", 1, true) ~= nil then
        text = string.format("%s hat den FollowMe-Job beendet: Fahrzeug blockiert.", workerName)
    elseif string.find(lowerText, "manuell", 1, true) ~= nil or string.find(lowerText, "manual", 1, true) ~= nil then
        text = string.format("%s hat den FollowMe-Job manuell beendet.", workerName)
    else
        text = string.format("%s hat den FollowMe-Job beendet.", workerName)
    end

    if HelperPersonnelCompatibility.ensureFollowMeAIMessageClass ~= nil and HelperPersonnelCompatibility.ensureFollowMeAIMessageClass() == true and HelperPersonnelFollowMeAIMessage ~= nil and HelperPersonnelFollowMeAIMessage.new ~= nil then
        return HelperPersonnelFollowMeAIMessage.new(text), text
    end

    if type(aiMessage) == "table" then
        aiMessage.helperPersonnelOriginalGetMessage = aiMessage.helperPersonnelOriginalGetMessage or aiMessage.getMessage
        aiMessage.helperPersonnelText = text
        aiMessage.getMessage = function(message)
            return message ~= nil and message.helperPersonnelText or text
        end
        return aiMessage, text
    end

    return {
        helperPersonnelText = text,
        getMessage = function(message)
            return message ~= nil and message.helperPersonnelText or text
        end
    }, text
end

local function hpCompatDescribeMessage(message)
    if message == nil then
        return "nil"
    end

    local text = hpCompatGetClassText(message)
    if message.getMessage ~= nil then
        local ok, result = pcall(message.getMessage, message)
        if ok and result ~= nil then
            text = text .. " | " .. tostring(result)
        end
    end

    return text
end

function HelperPersonnelCompatibility.getRootVehicle(vehicle)
    if vehicle == nil then
        return nil
    end

    local rootVehicle = hpCompatSafeCall(vehicle, "getRootVehicle")
    if rootVehicle ~= nil then
        return rootVehicle
    end

    return vehicle.rootVehicle or vehicle
end

function HelperPersonnelCompatibility.getVehicleFromJob(job)
    if job == nil then
        return nil
    end

    if job.vehicle ~= nil then
        return job.vehicle
    end

    if job.vehicleParameter ~= nil then
        local vehicle = hpCompatSafeCall(job.vehicleParameter, "getVehicle")
        if vehicle ~= nil then
            return vehicle
        end

        if job.vehicleParameter.vehicle ~= nil then
            return job.vehicleParameter.vehicle
        end
    end

    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.getVehicleFromJob ~= nil then
        local success, vehicle = pcall(HelperPersonnelAIJobHooks.getVehicleFromJob, job)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getVehicleFromAIJob ~= nil then
        local success, vehicle = pcall(HelperPersonnelAIStartHooks.getVehicleFromAIJob, job)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    return nil
end

function HelperPersonnelCompatibility.jobIsA(job, class)
    if job == nil or class == nil or job.isa == nil then
        return false
    end

    local success, result = pcall(job.isa, job, class)
    return success and result == true
end

function HelperPersonnelCompatibility.isFollowMeJob(job)
    if job == nil then
        return false
    end

    if AIJobFollowVehicle ~= nil then
        if job == AIJobFollowVehicle or HelperPersonnelCompatibility.jobIsA(job, AIJobFollowVehicle) then
            return true
        end
    end

    if job.followVehicleTask ~= nil or job.followVehicleParameter ~= nil then
        return true
    end

    local text = hpCompatGetClassText(job)
    return hpCompatContainsAny(text, {"aijobfollowvehicle", "followvehicle", "followme"})
end

function HelperPersonnelCompatibility.getFollowMeFarmId(vehicle, fallbackFarmId)
    if vehicle ~= nil and vehicle.getOwnerFarmId ~= nil then
        return vehicle:getOwnerFarmId()
    end

    if fallbackFarmId ~= nil then
        return fallbackFarmId
    end

    if g_localPlayer ~= nil and g_localPlayer.farmId ~= nil then
        return g_localPlayer.farmId
    end

    return nil
end

function HelperPersonnelCompatibility.createFollowMeJob(vehicle, vehicleToFollow)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | createFollowMeJob | Fahrzeug=%s | Ziel=%s | Mission=%s | AIJobTypeManager=%s | MOD_FOLLOW_VEHICLE=%s",
        hpCompatDescribeVehicle(vehicle),
        hpCompatDescribeVehicle(vehicleToFollow),
        tostring(g_currentMission ~= nil),
        tostring(g_currentMission ~= nil and g_currentMission.aiJobTypeManager ~= nil and g_currentMission.aiJobTypeManager.createJob ~= nil),
        tostring(AIJobType ~= nil and AIJobType.MOD_FOLLOW_VEHICLE ~= nil))

    if g_currentMission == nil or g_currentMission.aiJobTypeManager == nil or g_currentMission.aiJobTypeManager.createJob == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | createFollowMeJob=false | Grund=keinAIJobTypeManager")
        return nil
    end

    if AIJobType == nil or AIJobType.MOD_FOLLOW_VEHICLE == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | createFollowMeJob=false | Grund=keinAIJobType")
        return nil
    end

    local job = g_currentMission.aiJobTypeManager:createJob(AIJobType.MOD_FOLLOW_VEHICLE)
    if job == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | createFollowMeJob=false | Grund=createJobNil")
        return nil
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | createFollowMeJob erstellt | Job=%s | vehicleParameter=%s | followVehicleParameter=%s",
        hpCompatDescribeJob(job),
        tostring(job.vehicleParameter ~= nil),
        tostring(job.followVehicleParameter ~= nil))

    if job.vehicleParameter ~= nil and job.vehicleParameter.setVehicle ~= nil then
        job.vehicleParameter:setVehicle(vehicle)
    end

    if job.followVehicleParameter ~= nil and job.followVehicleParameter.setVehicle ~= nil then
        job.followVehicleParameter:setVehicle(vehicleToFollow)
    end

    if job.setValues ~= nil then
        job:setValues()
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | createFollowMeJob fertig | Job=%s | Fahrzeug=%s | Ziel=%s | IstFollowMe=%s",
        hpCompatDescribeJob(job),
        hpCompatDescribeVehicle(HelperPersonnelCompatibility.getVehicleFromJob(job)),
        hpCompatDescribeVehicle(HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow ~= nil and HelperPersonnelAIStartHooks.getFollowMeVehicleToFollow(job) or nil),
        tostring(HelperPersonnelCompatibility.isFollowMeJob(job)))

    return job
end

function HelperPersonnelCompatibility.getExcludedWorkerIdsForFollowMe(job)
    local excludedWorkerIds = nil
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getExcludedWorkerIdsForJob ~= nil then
        excludedWorkerIds = HelperPersonnelAIStartHooks.getExcludedWorkerIdsForJob(job)
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | getExcludedWorkerIdsForFollowMe | Job=%s | Anzahl=%s", hpCompatDescribeJob(job), tostring(hpCompatCountKeys(excludedWorkerIds)))
    return excludedWorkerIds
end

function HelperPersonnelCompatibility.startFollowMeWithWorker(vehicle, vehicleToFollow, workerId, farmId)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowMeWithWorker ENTER | Mitarbeiter=%s | Fahrzeug=%s | Ziel=%s | Farm=%s",
        tostring(workerId),
        hpCompatDescribeVehicle(vehicle),
        hpCompatDescribeVehicle(vehicleToFollow),
        tostring(farmId))

    local job = HelperPersonnelCompatibility.createFollowMeJob(vehicle, vehicleToFollow)
    if job == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowMeWithWorker=false | Grund=keinJob | Mitarbeiter=%s", tostring(workerId))
        return false
    end

    if job.validate ~= nil then
        local ok, success, errorMessage = pcall(job.validate, job, farmId)
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowMeWithWorker validate | Pcall=%s | Success=%s | Error=%s | Mitarbeiter=%s | Job=%s",
            tostring(ok),
            tostring(success),
            tostring(errorMessage),
            tostring(workerId),
            hpCompatDescribeJob(job))
        if not ok or success ~= true then
            return false
        end
    end

    if vehicle ~= nil and vehicle.setAIModeSelection ~= nil and AIModeSelection ~= nil and AIModeSelection.MODE ~= nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowMeWithWorker setAIModeSelection | Fahrzeug=%s", hpCompatDescribeVehicle(vehicle))
        vehicle:setAIModeSelection(AIModeSelection.MODE.WORKER)
    end

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.sendSelectedAIJob ~= nil then
        local result = HelperPersonnelAIStartHooks.sendSelectedAIJob(vehicle, workerId, job, farmId) == true
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowMeWithWorker Ergebnis | Result=%s | Mitarbeiter=%s | Job=%s", tostring(result), tostring(workerId), hpCompatDescribeJob(job))
        return result
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowMeWithWorker=false | Grund=keinSendSelectedAIJob")
    return false
end

function HelperPersonnelCompatibility.onFollowMeInitiate(vehicle, superFunc, vehicleToFollow, ...)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate ENTER | Fahrzeug=%s | Ziel=%s | SuperFunc=%s | App=%s | Overlay=%s | ShowSelection=%s | AuswahlSichtbar=%s",
        hpCompatDescribeVehicle(vehicle),
        hpCompatDescribeVehicle(vehicleToFollow),
        tostring(superFunc ~= nil),
        tostring(g_helperPersonnelApp ~= nil),
        tostring(g_helperPersonnelApp ~= nil and g_helperPersonnelApp.selectionOverlay ~= nil),
        tostring(g_helperPersonnelApp ~= nil and g_helperPersonnelApp.showWorkerSelectionForVehicle ~= nil),
        tostring(g_helperPersonnelApp ~= nil and g_helperPersonnelApp.selectionOverlay ~= nil and g_helperPersonnelApp.selectionOverlay.isVisible == true))

    local app = g_helperPersonnelApp
    if app == nil or app.selectionOverlay == nil or app.showWorkerSelectionForVehicle == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate FallbackOriginal | Grund=AppOderOverlayFehlt")
        return superFunc(vehicle, vehicleToFollow, ...)
    end

    if g_currentMission ~= nil and g_currentMission.getHasPlayerPermission ~= nil and not g_currentMission:getHasPlayerPermission("hireAssistant") then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate=false | Grund=keineHireAssistantPermission")
        return nil
    end

    local farmId = HelperPersonnelCompatibility.getFollowMeFarmId(vehicle, nil)
    local job = HelperPersonnelCompatibility.createFollowMeJob(vehicle, vehicleToFollow)
    if job == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate FallbackOriginal | Grund=JobNichtErstellbar")
        return superFunc(vehicle, vehicleToFollow, ...)
    end

    if job.validate ~= nil then
        local ok, success, errorMessage = pcall(job.validate, job, farmId)
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate validate | Pcall=%s | Success=%s | Error=%s | Farm=%s | Job=%s",
            tostring(ok),
            tostring(success),
            tostring(errorMessage),
            tostring(farmId),
            hpCompatDescribeJob(job))
        if not ok or success ~= true then
            return nil
        end
    end

    local initiateArgs = {...}
    local trailDropIndex = HelperPersonnelCompatibility.reserveFollowMeTrailDrop(vehicle, vehicleToFollow)
    local excludedWorkerIds = HelperPersonnelCompatibility.getExcludedWorkerIdsForFollowMe(job)
    local opened = app:showWorkerSelectionForVehicle(vehicle, function(selectedWorker)
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AuswahlCallback | Selected=%s | Mitarbeiter=%s | Fahrzeug=%s | Ziel=%s",
            tostring(selectedWorker ~= nil),
            tostring(selectedWorker ~= nil and selectedWorker.id or nil),
            hpCompatDescribeVehicle(vehicle),
            hpCompatDescribeVehicle(vehicleToFollow))

        if selectedWorker == nil or selectedWorker.id == nil then
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AuswahlCallback abgebrochen | Grund=keinMitarbeiter")
            HelperPersonnelCompatibility.consumeReservedFollowMeTrailDrop(vehicle)
            return
        end

        HelperPersonnelCompatibility.reserveFollowMeWorker(vehicle, selectedWorker.id)

        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AuswahlCallback OriginalStart | Mitarbeiter=%s | Fahrzeug=%s | Ziel=%s | Farm=%s",
            tostring(selectedWorker.id),
            hpCompatDescribeVehicle(vehicle),
            hpCompatDescribeVehicle(vehicleToFollow),
            tostring(farmId))

        local ok, result = pcall(superFunc, vehicle, vehicleToFollow, unpack(initiateArgs))
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AuswahlCallback OriginalStart Ergebnis | Pcall=%s | Result=%s | Mitarbeiter=%s | Fahrzeug=%s",
            tostring(ok),
            tostring(result),
            tostring(selectedWorker.id),
            hpCompatDescribeVehicle(vehicle))

        if not ok then
            HelperPersonnelCompatibility.finishActiveFollowMeWorker(vehicle)
            HelperPersonnelCompatibility.consumeReservedFollowMeTrailDrop(vehicle)
            error(result)
        end
    end, excludedWorkerIds)

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate Auswahl | Geoeffnet=%s | Fahrzeug=%s | Ziel=%s | Excluded=%s | Farm=%s | TrailDrop=%s",
        tostring(opened),
        hpCompatDescribeVehicle(vehicle),
        hpCompatDescribeVehicle(vehicleToFollow),
        tostring(hpCompatCountKeys(excludedWorkerIds)),
        tostring(farmId),
        tostring(trailDropIndex))

    if opened then
        return nil
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiate blockiert | Grund=AuswahlNichtGeoeffnet")
    HelperPersonnelCompatibility.consumeReservedFollowMeTrailDrop(vehicle)
    return nil
end

function HelperPersonnelCompatibility.getFollowMeTimeMs()
    if g_time ~= nil then
        return g_time
    end

    if g_currentMission ~= nil and g_currentMission.time ~= nil then
        return g_currentMission.time
    end

    return 0
end

function HelperPersonnelCompatibility.getFollowMeSpec(vehicle)
    if vehicle == nil then
        return nil
    end

    local directNames = {
        "spec_FS25_FollowMe.followVehicle",
        "spec_FollowMe.followVehicle",
        "spec_followVehicle"
    }

    for _, name in ipairs(directNames) do
        local spec = vehicle[name]
        if type(spec) == "table" then
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | getSpec direkt | Fahrzeug=%s | Key=%s | DriveStrategies=%s | Active=%s", hpCompatDescribeVehicle(vehicle), tostring(name), tostring(type(spec.driveStrategies) == "table" and #spec.driveStrategies or nil), tostring(spec.isActive))
            return spec
        end
    end

    for key, spec in pairs(vehicle) do
        if type(key) == "string" and type(spec) == "table" then
            local lowerKey = hpCompatToLower(key)
            if string.find(lowerKey, "followvehicle", 1, true) ~= nil then
                if spec.driveStrategies ~= nil or spec.vehicleToFollow ~= nil or spec.followJob ~= nil or spec.didNotMoveTimer ~= nil or spec.nearbyVehicles_timeout ~= nil then
                    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | getSpec scan | Fahrzeug=%s | Key=%s | DriveStrategies=%s | Active=%s", hpCompatDescribeVehicle(vehicle), tostring(key), tostring(type(spec.driveStrategies) == "table" and #spec.driveStrategies or nil), tostring(spec.isActive))
                    return spec
                end
            end
        end
    end

    if getSpec ~= nil then
        local ok, spec = pcall(getSpec, vehicle)
        if ok and type(spec) == "table" then
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | getSpec global | Fahrzeug=%s | DriveStrategies=%s | Active=%s", hpCompatDescribeVehicle(vehicle), tostring(type(spec.driveStrategies) == "table" and #spec.driveStrategies or nil), tostring(spec.isActive))
            return spec
        end
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | getSpec=false | Fahrzeug=%s", hpCompatDescribeVehicle(vehicle))
    return nil
end

function HelperPersonnelCompatibility.getFollowMePosition(vehicle)
    if vehicle ~= nil and vehicle.rootNode ~= nil then
        local ok, x, y, z = pcall(getWorldTranslation, vehicle.rootNode)
        if ok then
            return x, z
        end
    end

    return 0, 0
end

function HelperPersonnelCompatibility.resyncFollowMeTrailTarget(vehicle, reason)
    local spec = HelperPersonnelCompatibility.getFollowMeSpec(vehicle)
    if spec == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | resyncTrail=false | Grund=SpecFehlt | Fahrzeug=%s | Reason=%s", hpCompatDescribeVehicle(vehicle), tostring(reason))
        return false
    end

    local leader = spec.vehicleToFollow
    local leaderSpec = HelperPersonnelCompatibility.getFollowMeSpec(leader)
    local leaderDropper = leaderSpec ~= nil and leaderSpec.dropperCurrentCount or nil
    if leaderDropper == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | resyncTrail=false | Grund=LeaderFehlt | Fahrzeug=%s | Reason=%s", hpCompatDescribeVehicle(vehicle), tostring(reason))
        return false
    end

    local oldIndex = spec.followingCurrentCount
    spec.followingCurrentCount = leaderDropper + 1
    if type(spec.aiDriveParams) == "table" then
        spec.aiDriveParams.valid = false
    end
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | resyncTrail | Fahrzeug=%s | Alt=%s | Neu=%s | LeaderDropper=%s | Reason=%s", hpCompatDescribeVehicle(vehicle), tostring(oldIndex), tostring(spec.followingCurrentCount), tostring(leaderDropper), tostring(reason))
    return true
end

function HelperPersonnelCompatibility.wrapFollowMeDriveStrategy(vehicle, strategy, index)
    if vehicle == nil or type(strategy) ~= "table" or type(strategy.getDriveData) ~= "function" or strategy.helperPersonnelFollowMeWrapped == true then
        return false
    end

    local originalGetDriveData = strategy.getDriveData
    strategy.helperPersonnelFollowMeWrapped = true
    strategy.getDriveData = function(driveStrategy, dt, vX, vY, vZ, ...)
        local tX, tZ, moveForwards, maxSpeed, distanceToStop = originalGetDriveData(driveStrategy, dt, vX, vY, vZ, ...)
        if maxSpeed ~= nil and maxSpeed < 0 then
            local key = hpCompatGetVehicleKey(vehicle)
            local untilTime = HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey ~= nil and HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey[key] or nil
            local now = HelperPersonnelCompatibility.getFollowMeTimeMs()
            local classText = hpCompatGetClassText(driveStrategy)
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | driveStrategy negative | Fahrzeug=%s | Index=%s | Strategie=%s | MaxSpeed=%s | Dist=%s | GraceUntil=%s | Now=%s | tX=%s | tZ=%s", hpCompatDescribeVehicle(vehicle), tostring(index), tostring(classText), tostring(maxSpeed), tostring(distanceToStop), tostring(untilTime), tostring(now), tostring(tX), tostring(tZ))
            if HelperPersonnelCompatibility.resyncFollowMeTrailTarget(vehicle, "negativeDriveStrategy") == true then
                local rtX, rtZ, rMoveForwards, rMaxSpeed, rDistanceToStop = originalGetDriveData(driveStrategy, dt, vX, vY, vZ, ...)
                hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | driveStrategy resync Ergebnis | Fahrzeug=%s | Index=%s | MaxSpeed=%s | Dist=%s | tX=%s | tZ=%s", hpCompatDescribeVehicle(vehicle), tostring(index), tostring(rMaxSpeed), tostring(rDistanceToStop), tostring(rtX), tostring(rtZ))
                if rMaxSpeed == nil or rMaxSpeed >= 0 then
                    return rtX, rtZ, rMoveForwards, rMaxSpeed, rDistanceToStop
                end
            end
        end

        return tX, tZ, moveForwards, maxSpeed, distanceToStop
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | driveStrategy wrapped | Fahrzeug=%s | Index=%s | Strategie=%s", hpCompatDescribeVehicle(vehicle), tostring(index), hpCompatGetClassText(strategy))
    return true
end

function HelperPersonnelCompatibility.wrapFollowMeDriveStrategies(vehicle)
    local spec = HelperPersonnelCompatibility.getFollowMeSpec(vehicle)
    local count = 0
    if spec ~= nil and type(spec.driveStrategies) == "table" then
        for index, strategy in ipairs(spec.driveStrategies) do
            if HelperPersonnelCompatibility.wrapFollowMeDriveStrategy(vehicle, strategy, index) then
                count = count + 1
            end
        end
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | driveStrategies wrapped | Fahrzeug=%s | Anzahl=%s", hpCompatDescribeVehicle(vehicle), tostring(count))
    return count
end


function HelperPersonnelCompatibility.rememberFollowMeLeader(vehicle, vehicleToFollow)
    if vehicle == nil or vehicleToFollow == nil then
        return false
    end

    HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey = HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey or {}
    HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey[hpCompatGetVehicleKey(vehicle)] = vehicleToFollow
    return true
end

function HelperPersonnelCompatibility.cleanupFollowMeVehicleAfterStop(vehicle, stageName)
    if vehicle == nil then
        return false
    end

    local key = hpCompatGetVehicleKey(vehicle)
    local spec = HelperPersonnelCompatibility.getFollowMeSpec(vehicle)
    local leader = spec ~= nil and spec.vehicleToFollow or nil
    if leader == nil and HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey ~= nil then
        leader = HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey[key]
    end

    local beforeActive = vehicle.getIsFollowVehicleActive ~= nil and vehicle:getIsFollowVehicleActive() or nil
    local beforeAIActive = vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() or nil

    if leader ~= nil and leader.removeFollower ~= nil then
        pcall(leader.removeFollower, leader, vehicle)
    end

    if spec ~= nil then
        spec.isActive = false
        spec.vehicleToFollow = nil
        spec.isWaiting = false
        spec.followingCurrentCount = spec.followingCurrentCount or 0
        spec.nearbyVehicles = {}
        spec.nearbyVehicles_timeout = 0
        spec.selectedFollower = nil
        if type(spec.aiDriveParams) == "table" then
            spec.aiDriveParams.valid = false
            spec.aiDriveParams.maxSpeed = 0
            spec.aiDriveParams.tX = nil
            spec.aiDriveParams.tZ = nil
        end
        if spec.didNotMoveTimeout ~= nil then
            spec.didNotMoveTimer = spec.didNotMoveTimeout
        end
        if spec.hudExtension ~= nil then
            if spec.hudExtension.delete ~= nil then
                pcall(spec.hudExtension.delete, spec.hudExtension)
            end
            spec.hudExtension = nil
        end
        if type(spec.driveStrategies) == "table" then
            for _, strategy in ipairs(spec.driveStrategies) do
                if type(strategy) == "table" and strategy.delete ~= nil then
                    pcall(strategy.delete, strategy)
                end
            end
            spec.driveStrategies = {}
        end
    end

    if vehicle.getIsAIActive ~= nil then
        local okActive, isAIActive = pcall(vehicle.getIsAIActive, vehicle)
        if okActive and isAIActive == true then
            if vehicle.deleteAgent ~= nil then
                pcall(vehicle.deleteAgent, vehicle)
            end
            if vehicle.aiJobFinished ~= nil then
                pcall(vehicle.aiJobFinished, vehicle)
            end
        end
    end

    if HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey ~= nil then
        HelperPersonnelCompatibility.followMeLastLeaderByVehicleKey[key] = nil
    end

    local afterActive = vehicle.getIsFollowVehicleActive ~= nil and vehicle:getIsFollowVehicleActive() or nil
    local afterAIActive = vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() or nil
    local canStart = vehicle.getCanStartFollowVehicle ~= nil and vehicle:getCanStartFollowVehicle() or nil
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | cleanupAfterStop | Phase=%s | Fahrzeug=%s | VorActive=%s | NachActive=%s | VorAI=%s | NachAI=%s | CanStart=%s", tostring(stageName), hpCompatDescribeVehicle(vehicle), tostring(beforeActive), tostring(afterActive), tostring(beforeAIActive), tostring(afterAIActive), tostring(canStart))
    return true
end

function HelperPersonnelCompatibility.onFollowMeStartFollowVehicle(vehicle, superFunc, vehicleToFollow, ...)
    local reservedWorkerId = HelperPersonnelCompatibility.peekReservedFollowMeWorker(vehicle)
    HelperPersonnelCompatibility.rememberFollowMeLeader(vehicle, vehicleToFollow)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowVehicle ENTER | Fahrzeug=%s | Ziel=%s | Reserviert=%s", hpCompatDescribeVehicle(vehicle), hpCompatDescribeVehicle(vehicleToFollow), tostring(reservedWorkerId))

    local ok, result = pcall(superFunc, vehicle, vehicleToFollow, ...)
    local active = vehicle ~= nil and vehicle.getIsFollowVehicleActive ~= nil and vehicle:getIsFollowVehicleActive() or nil
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | startFollowVehicle OriginalErgebnis | Pcall=%s | Result=%s | Reserviert=%s | Active=%s", tostring(ok), tostring(result), tostring(reservedWorkerId), tostring(active))

    if not ok then
        HelperPersonnelCompatibility.consumeReservedFollowMeWorker(vehicle)
        HelperPersonnelCompatibility.consumeReservedFollowMeTrailDrop(vehicle)
        error(result)
    end

    if active == true and reservedWorkerId ~= nil then
        local workerId = HelperPersonnelCompatibility.consumeReservedFollowMeWorker(vehicle)
        if workerId ~= nil then
            local workerStarted = HelperPersonnelCompatibility.setActiveFollowMeWorker(vehicle, workerId)
            if workerStarted == true then
                HelperPersonnelCompatibility.applyFollowMeWorkerContext(workerId, vehicle, vehicleToFollow)
            end
        end
    end

    if active == true then
        HelperPersonnelCompatibility.applyReservedFollowMeTrailDrop(vehicle)
        HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey = HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey or {}
        HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey[hpCompatGetVehicleKey(vehicle)] = HelperPersonnelCompatibility.getFollowMeTimeMs() + 12000
        HelperPersonnelCompatibility.wrapFollowMeDriveStrategies(vehicle)
    end

    return result
end

function HelperPersonnelCompatibility.onFollowMeStopFollowVehicle(vehicle, superFunc, ...)
    local activeWorkerId = HelperPersonnelCompatibility.getActiveFollowMeWorker(vehicle)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopFollowVehicle ENTER | Fahrzeug=%s | Mitarbeiter=%s", hpCompatDescribeVehicle(vehicle), tostring(activeWorkerId))

    local ok, result = pcall(superFunc, vehicle, ...)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopFollowVehicle OriginalErgebnis | Pcall=%s | Result=%s | Mitarbeiter=%s", tostring(ok), tostring(result), tostring(activeWorkerId))

    if not ok then
        error(result)
    end

    if activeWorkerId ~= nil then
        HelperPersonnelCompatibility.finishActiveFollowMeWorker(vehicle)
    else
        HelperPersonnelCompatibility.consumeReservedFollowMeWorker(vehicle)
    end

    HelperPersonnelCompatibility.cleanupFollowMeVehicleAfterStop(vehicle, "stopFollowVehicle")

    if HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey ~= nil then
        HelperPersonnelCompatibility.followMeStartupGraceUntilByVehicleKey[hpCompatGetVehicleKey(vehicle)] = nil
    end

    return result
end

function HelperPersonnelCompatibility.onFollowMeStopCurrentAIJob(vehicle, superFunc, aiMessage, ...)
    local activeWorkerId = HelperPersonnelCompatibility.getActiveFollowMeWorker(vehicle)
    local active = vehicle ~= nil and vehicle.getIsFollowVehicleActive ~= nil and vehicle:getIsFollowVehicleActive() or nil
    local messageToUse = aiMessage
    local replacementText = nil

    if activeWorkerId ~= nil then
        messageToUse, replacementText = HelperPersonnelCompatibility.createFollowMeWorkerAIMessage(activeWorkerId, aiMessage)
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopCurrentAIJob | Fahrzeug=%s | Active=%s | Mitarbeiter=%s | Message=%s | Ersatz=%s", hpCompatDescribeVehicle(vehicle), tostring(active), tostring(activeWorkerId), hpCompatDescribeMessage(aiMessage), tostring(replacementText))
    return superFunc(vehicle, messageToUse, ...)
end

function HelperPersonnelCompatibility.onFollowMeAIJobStart(job, superFunc, farmId, ...)
    local startArgs = {...}
    local vehicle = HelperPersonnelCompatibility.getVehicleFromJob(job)
    local workerId = job ~= nil and job.helperPersonnelWorkerId or nil
    if workerId == nil then
        workerId = HelperPersonnelCompatibility.consumeReservedFollowMeWorker(vehicle)
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicle.start ENTER | Job=%s | Fahrzeug=%s | Farm=%s | Mitarbeiter=%s", hpCompatDescribeJob(job), hpCompatDescribeVehicle(vehicle), tostring(farmId), tostring(workerId))

    local app = g_helperPersonnelApp
    if workerId ~= nil and HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.canUseWorkerForJob ~= nil then
        if not HelperPersonnelAIJobHooks.canUseWorkerForJob(workerId, job) then
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicle.start blockiert | Grund=MitarbeiterNichtVerfuegbar | Mitarbeiter=%s | Job=%s", tostring(workerId), hpCompatDescribeJob(job))
            if HelperPersonnelAIJobHooks.rejectUnavailableWorker ~= nil then
                HelperPersonnelAIJobHooks.rejectUnavailableWorker(workerId, job)
            end
            return false
        end
    end

    if workerId ~= nil and HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.applyWorkerToJob ~= nil then
        HelperPersonnelAIJobHooks.applyWorkerToJob(job, workerId)
    elseif job ~= nil then
        job.helperPersonnelWorkerId = workerId
    end

    local ok, result
    if workerId ~= nil and HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.callWithForcedHelper ~= nil then
        ok, result = pcall(function()
            return HelperPersonnelAIJobHooks.callWithForcedHelper(job, workerId, function()
                return superFunc(job, farmId, unpack(startArgs))
            end)
        end)
    else
        ok, result = pcall(superFunc, job, farmId, unpack(startArgs))
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicle.start Ergebnis | Pcall=%s | Result=%s | Mitarbeiter=%s | HelperIndex=%s", tostring(ok), tostring(result), tostring(workerId), tostring(job ~= nil and job.helperIndex or nil))

    if not ok then
        if workerId ~= nil then
            HelperPersonnelCompatibility.consumeReservedFollowMeWorker(vehicle)
        end
        error(result)
    end

    if result ~= false and workerId ~= nil and app ~= nil and app.helperBridge ~= nil then
        local alreadyMapped = app.helperBridge.jobWorkerIds ~= nil and app.helperBridge.jobWorkerIds[job] == workerId
        if not alreadyMapped then
            if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.finalizeStartedJob ~= nil then
                HelperPersonnelAIJobHooks.finalizeStartedJob(app, job, workerId)
            elseif app.helperBridge.onJobStarted ~= nil then
                app.helperBridge:onJobStarted(job, workerId)
            end
        end
        HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey = HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey or {}
        HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey[hpCompatGetVehicleKey(vehicle)] = workerId
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicle.start finalisiert | Job=%s | Fahrzeug=%s | Mitarbeiter=%s | BereitsZuordnung=%s", hpCompatDescribeJob(job), hpCompatDescribeVehicle(vehicle), tostring(workerId), tostring(alreadyMapped))
    end

    return result
end

function HelperPersonnelCompatibility.onFollowMeAIJobStop(job, superFunc, aiMessage, ...)
    local vehicle = HelperPersonnelCompatibility.getVehicleFromJob(job)
    local workerId = nil
    if job ~= nil then
        workerId = job.helperPersonnelWorkerId
    end
    if workerId == nil and g_helperPersonnelApp ~= nil and g_helperPersonnelApp.helperBridge ~= nil and g_helperPersonnelApp.helperBridge.jobWorkerIds ~= nil then
        workerId = g_helperPersonnelApp.helperBridge.jobWorkerIds[job]
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicle.stop ENTER | Job=%s | Fahrzeug=%s | Mitarbeiter=%s | Message=%s", hpCompatDescribeJob(job), hpCompatDescribeVehicle(vehicle), tostring(workerId), hpCompatDescribeMessage(aiMessage))

    local ok, result = pcall(superFunc, job, aiMessage, ...)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicle.stop Ergebnis | Pcall=%s | Result=%s | Mitarbeiter=%s", tostring(ok), tostring(result), tostring(workerId))

    if workerId ~= nil and g_helperPersonnelApp ~= nil and g_helperPersonnelApp.helperBridge ~= nil and g_helperPersonnelApp.helperBridge.jobWorkerIds ~= nil and g_helperPersonnelApp.helperBridge.jobWorkerIds[job] == workerId then
        g_helperPersonnelApp.helperBridge:onJobStopped(job)
    end

    if vehicle ~= nil then
        local active = HelperPersonnelCompatibility.followMeActiveWorkerIdsByVehicleKey
        if active ~= nil then
            active[hpCompatGetVehicleKey(vehicle)] = nil
        end
    end

    if not ok then
        error(result)
    end

    return result
end

function HelperPersonnelCompatibility.onFollowMeActionEventInitiate(vehicle, superFunc, actionName, inputValue, callbackState, isAnalog)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | actionEventInitiate | Fahrzeug=%s | Action=%s | Input=%s | CallbackState=%s | Analog=%s | CanStart=%s | Active=%s",
        hpCompatDescribeVehicle(vehicle),
        tostring(actionName),
        tostring(inputValue),
        tostring(callbackState),
        tostring(isAnalog),
        tostring(vehicle ~= nil and vehicle.getCanStartFollowVehicle ~= nil and vehicle:getCanStartFollowVehicle() or nil),
        tostring(vehicle ~= nil and vehicle.getIsFollowVehicleActive ~= nil and vehicle:getIsFollowVehicleActive() or nil))
    return superFunc(vehicle, actionName, inputValue, callbackState, isAnalog)
end

function HelperPersonnelCompatibility.onFollowMeUpdateTick(vehicle, superFunc, dt, isActiveForInput, isSelected)
    local spec = nil
    if vehicle ~= nil and getSpec ~= nil then
        local ok, result = pcall(getSpec, vehicle)
        if ok then
            spec = result
        end
    end

    local timeout = spec ~= nil and spec.nearbyVehicles_timeout or nil
    local nearbyCount = 0
    if type(spec) == "table" and type(spec.nearbyVehicles) == "table" then
        nearbyCount = #spec.nearbyVehicles
    end

    if timeout ~= nil and timeout > 0 then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | onUpdateTick vor Super | Fahrzeug=%s | Timeout=%s | Nearby=%s | ActiveInput=%s | Selected=%s",
            hpCompatDescribeVehicle(vehicle),
            tostring(timeout),
            tostring(nearbyCount),
            tostring(isActiveForInput),
            tostring(isSelected))
    end

    return superFunc(vehicle, dt, isActiveForInput, isSelected)
end

function HelperPersonnelCompatibility.installFollowMeJobClassHooks(stageName)
    if AIJobFollowVehicle == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicleHook=false | Phase=%s | Grund=KlasseFehlt", tostring(stageName))
        return false
    end

    if HelperPersonnelCompatibility.followMeAIJobClassHookInstalled == true then
        return true
    end

    if AIJobFollowVehicle.start ~= nil then
        local originalStart = AIJobFollowVehicle.start
        AIJobFollowVehicle.start = function(job, farmId, ...)
            return HelperPersonnelCompatibility.onFollowMeAIJobStart(job, originalStart, farmId, ...)
        end
    end

    if AIJobFollowVehicle.stop ~= nil then
        local originalStop = AIJobFollowVehicle.stop
        AIJobFollowVehicle.stop = function(job, aiMessage, ...)
            return HelperPersonnelCompatibility.onFollowMeAIJobStop(job, originalStop, aiMessage, ...)
        end
    end

    HelperPersonnelCompatibility.followMeAIJobClassHookInstalled = true
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | AIJobFollowVehicleHook=true | Phase=%s | Start=%s | Stop=%s", tostring(stageName), tostring(AIJobFollowVehicle.start ~= nil), tostring(AIJobFollowVehicle.stop ~= nil))
    return true
end

function HelperPersonnelCompatibility.installStopCurrentAIJobDiagnosticHook(stageName)
    if HelperPersonnelCompatibility.stopCurrentAIJobDiagnosticHookInstalled == true then
        return true
    end

    local targets = {
        Vehicle,
        AIVehicle,
        AIJobVehicle
    }

    for _, target in ipairs(targets) do
        if type(target) == "table" and type(target.stopCurrentAIJob) == "function" then
            local originalStopCurrentAIJob = target.stopCurrentAIJob
            target.stopCurrentAIJob = function(vehicle, aiMessage, ...)
                if vehicle ~= nil and vehicle.getIsFollowVehicleActive ~= nil then
                    local activeWorkerId = HelperPersonnelCompatibility.getActiveFollowMeWorker(vehicle)
                    local messageToUse = aiMessage
                    local replacementText = nil
                    if activeWorkerId ~= nil then
                        messageToUse, replacementText = HelperPersonnelCompatibility.createFollowMeWorkerAIMessage(activeWorkerId, aiMessage)
                    end
                    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopCurrentAIJob global | Fahrzeug=%s | Active=%s | Mitarbeiter=%s | Ersatz=%s", hpCompatDescribeVehicle(vehicle), tostring(vehicle:getIsFollowVehicleActive()), tostring(activeWorkerId), tostring(replacementText))
                    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopCurrentAIJob OriginalMessage | Fahrzeug=%s | Message=%s", hpCompatDescribeVehicle(vehicle), hpCompatDescribeMessage(aiMessage))
                    return originalStopCurrentAIJob(vehicle, messageToUse, ...)
                end
                return originalStopCurrentAIJob(vehicle, aiMessage, ...)
            end
            HelperPersonnelCompatibility.stopCurrentAIJobDiagnosticHookInstalled = true
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopCurrentAIJobHook=true | Phase=%s | Target=%s", tostring(stageName), hpCompatGetClassText(target))
            return true
        end
    end

    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopCurrentAIJobHook=false | Phase=%s", tostring(stageName))
    return false
end

function HelperPersonnelCompatibility.installFollowMeVehicleTypeHooks(vehicleType, stageName)
    if vehicleType == nil or SpecializationUtil == nil or SpecializationUtil.registerOverwrittenFunction == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | installVehicleTypeHook=false | Phase=%s | Grund=keinVehicleTypeOderSpecializationUtil", tostring(stageName))
        return false
    end

    HelperPersonnelCompatibility.followMeVehicleTypeHooks = HelperPersonnelCompatibility.followMeVehicleTypeHooks or {}
    local key = tostring(vehicleType)
    if HelperPersonnelCompatibility.followMeVehicleTypeHooks[key] == true then
        return true
    end

    SpecializationUtil.registerOverwrittenFunction(vehicleType, "initiateFollowVehicle", HelperPersonnelCompatibility.onFollowMeInitiate)
    HelperPersonnelCompatibility.followMeVehicleTypeHooks[key] = true
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | installVehicleTypeHook=true | Phase=%s | VehicleType=%s", tostring(stageName), key)
    return true
end

function HelperPersonnelCompatibility.wrapFollowMeFunction(funcName, func, stageName)
    if type(func) ~= "function" then
        return func
    end

    if funcName == "initiateFollowVehicle" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, vehicleToFollow, ...)
            return HelperPersonnelCompatibility.onFollowMeInitiate(vehicle, function(innerVehicle, innerVehicleToFollow, ...)
                return originalFunc(innerVehicle, innerVehicleToFollow, ...)
            end, vehicleToFollow, ...)
        end
    end

    if funcName == "actionEventInitiate" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, actionName, inputValue, callbackState, isAnalog, ...)
            return HelperPersonnelCompatibility.onFollowMeActionEventInitiate(vehicle, function(innerVehicle, innerActionName, innerInputValue, innerCallbackState, innerIsAnalog, ...)
                return originalFunc(innerVehicle, innerActionName, innerInputValue, innerCallbackState, innerIsAnalog, ...)
            end, actionName, inputValue, callbackState, isAnalog, ...)
        end
    end

    if funcName == "onUpdateTick" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, dt, isActiveForInput, isSelected, ...)
            return HelperPersonnelCompatibility.onFollowMeUpdateTick(vehicle, function(innerVehicle, innerDt, innerIsActiveForInput, innerIsSelected, ...)
                return originalFunc(innerVehicle, innerDt, innerIsActiveForInput, innerIsSelected, ...)
            end, dt, isActiveForInput, isSelected, ...)
        end
    end

    if funcName == "startFollowVehicle" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, vehicleToFollow, ...)
            return HelperPersonnelCompatibility.onFollowMeStartFollowVehicle(vehicle, function(innerVehicle, innerVehicleToFollow, ...)
                return originalFunc(innerVehicle, innerVehicleToFollow, ...)
            end, vehicleToFollow, ...)
        end
    end

    if funcName == "stopFollowVehicle" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, ...)
            return HelperPersonnelCompatibility.onFollowMeStopFollowVehicle(vehicle, function(innerVehicle, ...)
                return originalFunc(innerVehicle, ...)
            end, ...)
        end
    end

    if funcName == "stopCurrentAIJob" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, aiMessage, ...)
            return HelperPersonnelCompatibility.onFollowMeStopCurrentAIJob(vehicle, function(innerVehicle, innerMessage, ...)
                return originalFunc(innerVehicle, innerMessage, ...)
            end, aiMessage, ...)
        end
    end


    if funcName == "getCanStartFollowVehicle" then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | wrapFunction | Phase=%s | Funktion=%s", tostring(stageName), tostring(funcName))
        local originalFunc = func
        return function(vehicle, ...)
            local result = originalFunc(vehicle, ...)
            if result ~= true then
                local spec = HelperPersonnelCompatibility.getFollowMeSpec(vehicle)
                local followActive = vehicle ~= nil and vehicle.getIsFollowVehicleActive ~= nil and vehicle:getIsFollowVehicleActive() or nil
                local aiActive = vehicle ~= nil and vehicle.getIsAIActive ~= nil and vehicle:getIsAIActive() or nil
                local aiFieldActive = vehicle ~= nil and vehicle.spec_aiFieldWorker ~= nil and vehicle.spec_aiFieldWorker.isActive or nil
                local aiDrivableRunning = vehicle ~= nil and vehicle.spec_aiDrivable ~= nil and vehicle.spec_aiDrivable.isRunning or nil
                hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | getCanStartFollowVehicle=false | Fahrzeug=%s | FollowActive=%s | AIActive=%s | AIField=%s | AIDrivable=%s | SpecActive=%s", hpCompatDescribeVehicle(vehicle), tostring(followActive), tostring(aiActive), tostring(aiFieldActive), tostring(aiDrivableRunning), tostring(spec ~= nil and spec.isActive or nil))
            end
            return result
        end
    end

    return func
end

function HelperPersonnelCompatibility.installSpecializationRegisterHook(stageName)
    if SpecializationUtil == nil or SpecializationUtil.registerFunction == nil then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | registerFunctionHook=false | Phase=%s | Grund=keinSpecializationUtil", tostring(stageName))
        return false
    end

    if HelperPersonnelCompatibility.specializationRegisterFunctionHookInstalled == true then
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | registerFunctionHook=bereitsInstalliert | Phase=%s", tostring(stageName))
        return true
    end

    local originalRegisterFunction = SpecializationUtil.registerFunction
    SpecializationUtil.registerFunction = function(vehicleType, funcName, func, ...)
        local wrappedFunc = func
        if funcName == "initiateFollowVehicle" or funcName == "startFollowVehicle" or funcName == "stopFollowVehicle" or funcName == "getCanStartFollowVehicle" then
            hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | registerFunction abgefangen | Funktion=%s | VehicleType=%s | Func=%s", tostring(funcName), tostring(vehicleType), tostring(func ~= nil))
            wrappedFunc = HelperPersonnelCompatibility.wrapFollowMeFunction(funcName, func, "SpecializationUtil.registerFunction")
            HelperPersonnelCompatibility.installFollowMeJobClassHooks("SpecializationUtil.registerFunction")
            HelperPersonnelCompatibility.installStopCurrentAIJobDiagnosticHook("SpecializationUtil.registerFunction")
        end

        return originalRegisterFunction(vehicleType, funcName, wrappedFunc, ...)
    end

    HelperPersonnelCompatibility.specializationRegisterFunctionHookInstalled = true
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | registerFunctionHook=true | Phase=%s", tostring(stageName))
    return true
end

function HelperPersonnelCompatibility.installFollowMeHooks(stageName)
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | installFollowMeHooks | Phase=%s | FollowVehicle=%s | initiate=%s | registerFunctions=%s | actionEventInitiate=%s | Utils=%s | SpecializationUtil=%s | registerFunctionHook=%s",
        tostring(stageName),
        tostring(FollowVehicle ~= nil),
        tostring(FollowVehicle ~= nil and FollowVehicle.initiateFollowVehicle ~= nil),
        tostring(FollowVehicle ~= nil and FollowVehicle.registerFunctions ~= nil),
        tostring(FollowVehicle ~= nil and FollowVehicle.actionEventInitiate ~= nil),
        tostring(Utils ~= nil),
        tostring(SpecializationUtil ~= nil),
        tostring(HelperPersonnelCompatibility.specializationRegisterFunctionHookInstalled == true))

    HelperPersonnelCompatibility.installSpecializationRegisterHook(stageName)
    HelperPersonnelCompatibility.installFollowMeJobClassHooks(stageName)
    HelperPersonnelCompatibility.installStopCurrentAIJobDiagnosticHook(stageName)

    if FollowVehicle ~= nil and FollowVehicle.actionEventInitiate ~= nil and HelperPersonnelCompatibility.followMeActionHookInstalled ~= true then
        FollowVehicle.actionEventInitiate = HelperPersonnelCompatibility.wrapFollowMeFunction("actionEventInitiate", FollowVehicle.actionEventInitiate, stageName)
        HelperPersonnelCompatibility.followMeActionHookInstalled = true
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | actionEventInitiateHook=true | Phase=%s", tostring(stageName))
    end

    if FollowVehicle ~= nil and FollowVehicle.initiateFollowVehicle ~= nil and HelperPersonnelCompatibility.followMeInitiateHookInstalled ~= true then
        FollowVehicle.initiateFollowVehicle = HelperPersonnelCompatibility.wrapFollowMeFunction("initiateFollowVehicle", FollowVehicle.initiateFollowVehicle, stageName)
        HelperPersonnelCompatibility.followMeInitiateHookInstalled = true
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | initiateClassHook=true | Phase=%s", tostring(stageName))
    end

    if FollowVehicle ~= nil and FollowVehicle.onUpdateTick ~= nil and HelperPersonnelCompatibility.followMeUpdateTickHookInstalled ~= true then
        FollowVehicle.onUpdateTick = HelperPersonnelCompatibility.wrapFollowMeFunction("onUpdateTick", FollowVehicle.onUpdateTick, stageName)
        HelperPersonnelCompatibility.followMeUpdateTickHookInstalled = true
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | updateTickClassHook=true | Phase=%s", tostring(stageName))
    end

    if AIVehicle ~= nil and AIVehicle.stopCurrentAIJob ~= nil and HelperPersonnelCompatibility.followMeStopCurrentAIJobHookInstalled ~= true then
        AIVehicle.stopCurrentAIJob = HelperPersonnelCompatibility.wrapFollowMeFunction("stopCurrentAIJob", AIVehicle.stopCurrentAIJob, stageName)
        HelperPersonnelCompatibility.followMeStopCurrentAIJobHookInstalled = true
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | stopCurrentAIJobHook=true | Phase=%s", tostring(stageName))
    end

    if FollowVehicle ~= nil and FollowVehicle.registerFunctions ~= nil and HelperPersonnelCompatibility.followMeRegisterFunctionsHookInstalled ~= true then
        FollowVehicle.registerFunctions = Utils.appendedFunction(FollowVehicle.registerFunctions, function(vehicleType)
            HelperPersonnelCompatibility.installFollowMeVehicleTypeHooks(vehicleType, "FollowVehicle.registerFunctions")
        end)
        HelperPersonnelCompatibility.followMeRegisterFunctionsHookInstalled = true
        hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | registerFunctionsHook=true | Phase=%s", tostring(stageName))
    end
end

function HelperPersonnelCompatibility.install()
    hpCompatLog("FS25_HelperPersonnel: FollowMe-Diagnose | compatibility.install ENTER | BereitsInstalliert=%s", tostring(HelperPersonnelCompatibility.isInstalled == true))

    if HelperPersonnelCompatibility.isInstalled == true then
        if HelperPersonnelCompatibility.installFollowMeHooks ~= nil then
            HelperPersonnelCompatibility.installFollowMeHooks("installRepeat")
        end
        return
    end

    HelperPersonnelCompatibility.isInstalled = true

    if HelperPersonnelCompatibility.installFollowMeHooks ~= nil then
        HelperPersonnelCompatibility.installFollowMeHooks("install")
    end

end

