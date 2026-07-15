

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.STATE_VERSION = math.max(tonumber(HelperPersonnelNetwork.STATE_VERSION) or 0, 7)
HelperPersonnelNetwork.ACTION_SET_TRANSPORT_PRIORITY = "setTransportPriority"
HelperPersonnelTransportAssignments = HelperPersonnelTransportAssignments or {}

HelperPersonnelTransportAssignments.TRANSPORT_DEBUG_LOGGING = false

local function hp1570Debug(message, ...)
    if HelperPersonnelTransportAssignments.TRANSPORT_DEBUG_LOGGING == true and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

local function hp1570NormalizeFarmId(farmId)
    farmId = tonumber(farmId)
    if farmId == nil or farmId <= 0 then
        return nil
    end
    return math.floor(farmId + 0.5)
end

local function hp1570GetText(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, text = pcall(function()
            return g_i18n:getText(key)
        end)
        if ok and text ~= nil and text ~= "" then
            return text
        end
    end

    return fallback or key
end

local function hp1570GetWorkerName(manager, worker)
    if manager ~= nil and manager.getFullName ~= nil then
        local ok, name = pcall(function()
            return manager:getFullName(worker)
        end)
        if ok and name ~= nil and name ~= "" then
            return name
        end
    end

    if type(worker) == "table" then
        return tostring(worker.firstName or "") .. " " .. tostring(worker.lastName or "")
    end

    return ""
end

local function hp1570GetActiveAIJobs(app)
    if app ~= nil and app.getActiveAIJobs ~= nil then
        local ok, activeJobs = pcall(app.getActiveAIJobs, app)
        if ok then
            return activeJobs
        end
    end

    local aiSystem = g_currentMission ~= nil and g_currentMission.aiSystem or nil
    if aiSystem ~= nil then
        if aiSystem.getActiveJobs ~= nil then
            local ok, activeJobs = pcall(aiSystem.getActiveJobs, aiSystem)
            if ok then
                return activeJobs
            end
        end

        return aiSystem.activeJobs
    end

    return nil
end

local function hp1570ActiveJobsContain(activeJobs, job)
    if activeJobs == nil or job == nil then
        return false
    end

    for _, activeJob in pairs(activeJobs) do
        if activeJob == job then
            return true
        end
    end

    return false
end

local function hp1570GetJobWorkerId(app, job)
    if job == nil then
        return nil
    end

    if type(job) == "table" and job.helperPersonnelWorkerId ~= nil then
        return tonumber(job.helperPersonnelWorkerId)
    end

    local bridge = app ~= nil and app.helperBridge or nil
    if bridge ~= nil and type(bridge.jobWorkerIds) == "table" then
        local workerId = bridge.jobWorkerIds[job]
        if workerId ~= nil then
            return tonumber(workerId)
        end
    end

    return nil
end

local function hp1570GetJobVehicleKey(app, job)
    local bridge = app ~= nil and app.helperBridge or nil
    if bridge ~= nil and bridge.getVehicleKeyFromJob ~= nil then
        local ok, key = pcall(bridge.getVehicleKeyFromJob, bridge, job)
        if ok and key ~= nil and tostring(key) ~= "" then
            return tostring(key)
        end
    end

    return nil
end

local function hp1570WorkerHasActiveAIJob(app, workerId, worker)
    workerId = tonumber(workerId)
    if app == nil or workerId == nil then
        return false
    end

    if type(worker) == "table" and worker.restorePending == true then
        return true
    end

    local bridge = app.helperBridge
    local assignedJob = bridge ~= nil and type(bridge.workerJobById) == "table" and bridge.workerJobById[workerId] or nil
    local activeJobs = hp1570GetActiveAIJobs(app)

    if activeJobs == nil then
        return assignedJob ~= nil
    end

    if assignedJob ~= nil and hp1570ActiveJobsContain(activeJobs, assignedJob) then
        return true
    end

    local workerVehicleKey = type(worker) == "table" and worker.vehicleKey ~= nil and tostring(worker.vehicleKey) or nil

    for _, activeJob in pairs(activeJobs) do
        local activeWorkerId = hp1570GetJobWorkerId(app, activeJob)
        if activeWorkerId == workerId then
            return true
        end

        if workerVehicleKey ~= nil and workerVehicleKey ~= "" and bridge ~= nil and type(bridge.vehicleWorkerIds) == "table" then
            local activeVehicleKey = hp1570GetJobVehicleKey(app, activeJob)
            if activeVehicleKey == workerVehicleKey and tonumber(bridge.vehicleWorkerIds[workerVehicleKey]) == workerId then
                return true
            end
        end
    end

    return false
end

local function hp1570ClearStaleBridgeAssignment(app, worker)
    if app == nil or app.helperBridge == nil or type(worker) ~= "table" then
        return
    end

    local workerId = tonumber(worker.id)
    if workerId == nil or worker.restorePending == true then
        return
    end

    if hp1570WorkerHasActiveAIJob(app, workerId, worker) then
        return
    end

    local bridge = app.helperBridge
    if type(bridge.workerJobById) == "table" then
        bridge.workerJobById[workerId] = nil
    end

    if type(bridge.jobWorkerIds) == "table" then
        for job, mappedWorkerId in pairs(bridge.jobWorkerIds) do
            if tonumber(mappedWorkerId) == workerId then
                bridge.jobWorkerIds[job] = nil
                if type(job) == "table" and job.helperPersonnelWorkerId == workerId then
                    job.helperPersonnelWorkerId = nil
                end
            end
        end
    end

    if type(bridge.vehicleWorkerIds) == "table" then
        for vehicleKey, mappedWorkerId in pairs(bridge.vehicleWorkerIds) do
            if tonumber(mappedWorkerId) == workerId then
                bridge.vehicleWorkerIds[vehicleKey] = nil
            end
        end
    end

    if worker.busy == true then
        worker.busy = false
        worker.vehicleName = ""
        worker.vehicleKey = nil
        worker.currentJobStartedAt = 0
        worker.currentJobElapsedMs = 0
    end
end

local function hp1570ClearPendingWorkerForTransport(app, vehicle)
    if app == nil then
        return
    end

    app.pendingWorkerIdForNextAIJob = nil

    if vehicle ~= nil and type(app.pendingWorkerIdsByVehicleKey) == "table" and app.getVehicleKey ~= nil then
        local key = app:getVehicleKey(vehicle)
        if key ~= nil then
            app.pendingWorkerIdsByVehicleKey[key] = nil
        end
    end
end

local function hp1570ClearTransportStartResidues(app, job, vehicle, keepWorkerId)
    if app == nil then
        return
    end

    keepWorkerId = tonumber(keepWorkerId)
    hp1570ClearPendingWorkerForTransport(app, vehicle)

    if type(job) == "table" and job.helperPersonnelWorkerId ~= nil and tonumber(job.helperPersonnelWorkerId) ~= keepWorkerId then
        hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | alte Job-Mitarbeiter-ID am Transportjob geloescht | Alt=%s | Behalten=%s", tostring(job.helperPersonnelWorkerId), tostring(keepWorkerId))
        job.helperPersonnelWorkerId = nil
    end

    local bridge = app.helperBridge
    if bridge == nil then
        return
    end

    if type(bridge.jobWorkerIds) == "table" and job ~= nil then
        local mappedWorkerId = tonumber(bridge.jobWorkerIds[job])
        if mappedWorkerId ~= nil and mappedWorkerId ~= keepWorkerId then
            hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | alte Bridge-Jobzuordnung geloescht | Alt=%s | Behalten=%s", tostring(mappedWorkerId), tostring(keepWorkerId))
            bridge.jobWorkerIds[job] = nil
        end
    end

    local vehicleKey = nil
    if bridge.getVehicleKeyFromJob ~= nil and job ~= nil then
        local ok, key = pcall(bridge.getVehicleKeyFromJob, bridge, job)
        if ok and key ~= nil then
            vehicleKey = tostring(key)
        end
    end
    if vehicleKey == nil and vehicle ~= nil and app.getVehicleKey ~= nil then
        local ok, key = pcall(app.getVehicleKey, app, vehicle)
        if ok and key ~= nil then
            vehicleKey = tostring(key)
        end
    end

    if vehicleKey ~= nil and type(bridge.vehicleWorkerIds) == "table" then
        local mappedWorkerId = tonumber(bridge.vehicleWorkerIds[vehicleKey])
        if mappedWorkerId ~= nil and mappedWorkerId ~= keepWorkerId then
            hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | alte Fahrzeugzuordnung fuer Transportfahrzeug geloescht | Fahrzeug=%s | Alt=%s | Behalten=%s", tostring(vehicleKey), tostring(mappedWorkerId), tostring(keepWorkerId))
            bridge.vehicleWorkerIds[vehicleKey] = nil
        end
    end
end

local function hp1570IsTransportJobByClass(job)
    if job == nil then
        return false
    end

    if AIJobGoTo ~= nil and job.isa ~= nil then
        local ok, result = pcall(function()
            return job:isa(AIJobGoTo)
        end)
        if ok and result == true then
            return true
        end
    end

    local candidates = {}
    if type(job) == "table" then
        candidates = {
            rawget(job, "className"),
            rawget(job, "name"),
            rawget(job, "typeName"),
            rawget(job, "jobTypeName")
        }
    end

    for _, value in ipairs(candidates) do
        if value ~= nil and tostring(value) == "AIJobGoTo" then
            return true
        end
    end

    local text = tostring(job)
    if string.find(text, "AIJobGoTo", 1, true) ~= nil then
        return true
    end

    return false
end

if HelperPersonnelAIJobHooks ~= nil then
    function HelperPersonnelAIJobHooks.isTransportJob(job)
        return hp1570IsTransportJobByClass(job)
    end

    local HP_V15192_ORIGINAL_GET_WORKER_ID_FOR_JOB = HelperPersonnelAIJobHooks.getWorkerIdForJob
    local function hpOverride_HelperPersonnelAIJobHooks_getWorkerIdForJob_1(app, job)
        if hp1570IsTransportJobByClass(job)
            and type(job) == "table"
            and job.helperPersonnelWorkerId == nil then

            return nil
        end

        if HP_V15192_ORIGINAL_GET_WORKER_ID_FOR_JOB ~= nil then
            return HP_V15192_ORIGINAL_GET_WORKER_ID_FOR_JOB(app, job)
        end

        return nil
    end
    HelperPersonnelAIJobHooks.getWorkerIdForJob = hpOverride_HelperPersonnelAIJobHooks_getWorkerIdForJob_1
end

local function hp1570GetBridgeVehicleKey(bridge, job)
    if bridge == nil or job == nil then
        return nil
    end

    if bridge.getVehicleKeyFromJob ~= nil then
        local ok, key = pcall(function()
            return bridge:getVehicleKeyFromJob(job)
        end)
        if ok and key ~= nil and tostring(key) ~= "" then
            return tostring(key)
        end
    end

    if bridge.getVehicleFromJob ~= nil and bridge.app ~= nil and bridge.app.getVehicleKey ~= nil then
        local ok, vehicle = pcall(function()
            return bridge:getVehicleFromJob(job)
        end)
        if ok and vehicle ~= nil then
            local okKey, key = pcall(function()
                return bridge.app:getVehicleKey(vehicle)
            end)
            if okKey and key ~= nil and tostring(key) ~= "" then
                return tostring(key)
            end
        end
    end

    return nil
end

local function hp1570IsSameTransportVehicle(bridge, oldJob, newJob)
    if oldJob == nil or newJob == nil then
        return false
    end

    local oldKey = hp1570GetBridgeVehicleKey(bridge, oldJob)
    local newKey = hp1570GetBridgeVehicleKey(bridge, newJob)

    return oldKey ~= nil and newKey ~= nil and oldKey == newKey
end

if HelperPersonnelHelperBridge ~= nil then
    local HP_V15193_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB = HelperPersonnelHelperBridge.canUseWorkerForJob
    local function hpOverride_HelperPersonnelHelperBridge_canUseWorkerForJob_2(self, workerId, job)
        if HP_V15193_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB ~= nil
            and HP_V15193_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB(self, workerId, job) == true then
            return true
        end

        if hp1570IsTransportJobByClass(job) ~= true or self.app == nil or self.app.manager == nil then
            return false
        end

        workerId = tonumber(workerId)
        if workerId == nil then
            return false
        end

        local worker = self.app.manager:getWorkerById(workerId)
        if worker == nil then
            return false
        end

        local assignedJob = self.workerJobById ~= nil and self.workerJobById[workerId] or nil
        if assignedJob ~= nil
            and assignedJob ~= job
            and hp1570IsTransportJobByClass(assignedJob) == true
            and hp1570IsSameTransportVehicle(self, assignedJob, job) == true then
            return true
        end

        return false
    end
    HelperPersonnelHelperBridge.canUseWorkerForJob = hpOverride_HelperPersonnelHelperBridge_canUseWorkerForJob_2
end

if HelperPersonnelManager ~= nil then
    function HelperPersonnelManager:normalizeTransportPriorities()
        local active = {}
        local changed = false

        for _, worker in ipairs(self.workers or {}) do
            self:normalizePersonRuntimeData(worker)
            if worker.transportDriver == true then
                table.insert(active, worker)
            elseif (tonumber(worker.transportPriority) or 0) ~= 0 then
                worker.transportPriority = 0
                changed = true
            end
        end

        table.sort(active, function(a, b)
            local priorityA = math.max(0, math.floor((tonumber(a.transportPriority) or 0) + 0.5))
            local priorityB = math.max(0, math.floor((tonumber(b.transportPriority) or 0) + 0.5))
            if priorityA > 0 or priorityB > 0 then
                if priorityA == 0 then
                    return false
                elseif priorityB == 0 then
                    return true
                elseif priorityA ~= priorityB then
                    return priorityA < priorityB
                end
            end
            if (a.reliability or 0) ~= (b.reliability or 0) then
                return (a.reliability or 0) > (b.reliability or 0)
            end
            if (a.experience or 0) ~= (b.experience or 0) then
                return (a.experience or 0) > (b.experience or 0)
            end
            local nameA = tostring(a.firstName or "") .. tostring(a.lastName or "")
            local nameB = tostring(b.firstName or "") .. tostring(b.lastName or "")
            if nameA ~= nameB then
                return nameA < nameB
            end
            return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
        end)

        for index, worker in ipairs(active) do
            if tonumber(worker.transportPriority) ~= index then
                worker.transportPriority = index
                changed = true
            end
        end

        return changed, active
    end

    function HelperPersonnelManager:getTransportDriversSorted()
        local _, active = self:normalizeTransportPriorities()
        return active or {}
    end

    function HelperPersonnelManager:isTransportDriverAvailableForJob(worker, job, allowStaleCleanup)
        if type(worker) ~= "table" then
            return false
        end

        local workerId = tonumber(worker.id)
        if workerId == nil or worker.restorePending == true then
            return false
        end

        local hasActiveJob = self.app ~= nil and hp1570WorkerHasActiveAIJob(self.app, workerId, worker) == true
        hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | pruefe Fahrer | ID=%s | Name=%s %s | Busy=%s | Restore=%s | AktiverJob=%s | Cleanup=%s",
            tostring(workerId),
            tostring(worker.firstName or ""),
            tostring(worker.lastName or ""),
            tostring(worker.busy == true),
            tostring(worker.restorePending == true),
            tostring(hasActiveJob == true),
            tostring(allowStaleCleanup == true))
        if hasActiveJob == true then
            return false
        end

        if worker.busy == true then
            if allowStaleCleanup ~= true then
                return false
            end

            if self.app ~= nil then
                hp1570ClearStaleBridgeAssignment(self.app, worker)
            end

            if worker.busy == true or worker.restorePending == true then
                return false
            end
        end

        if allowStaleCleanup == true and self.app ~= nil then
            hp1570ClearStaleBridgeAssignment(self.app, worker)
        end

        if self.isWorkerAvailable ~= nil and self:isWorkerAvailable(workerId) ~= true then
            return false
        end

        if self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.canUseWorkerForJob ~= nil then
            if self.app.helperBridge:canUseWorkerForJob(workerId, job) == true then
                return true
            end

            if allowStaleCleanup == true then
                hp1570ClearStaleBridgeAssignment(self.app, worker)
                return self.app.helperBridge:canUseWorkerForJob(workerId, job) == true
            end

            return false
        end

        return true
    end

    function HelperPersonnelManager:getAvailableTransportDriversForJob(job)
        local drivers = self:getTransportDriversSorted()
        local result = {}

        for _, worker in ipairs(drivers) do
            if self:isTransportDriverAvailableForJob(worker, job, false) then
                table.insert(result, worker)
            end
        end

        if #result > 0 then
            return result, nil, #drivers > 0
        end

        for _, worker in ipairs(drivers) do
            if worker.busy ~= true and self:isTransportDriverAvailableForJob(worker, job, true) then
                table.insert(result, worker)
            end
        end

        if #result > 0 then
            return result, nil, #drivers > 0
        end

        for _, worker in ipairs(drivers) do
            if worker.busy == true and self:isTransportDriverAvailableForJob(worker, job, true) then
                table.insert(result, worker)
            end
        end

        if #result > 0 then
            return result, nil, #drivers > 0
        end

        if #drivers > 0 then
            return result, "busy", true
        end

        return result, "none", false
    end

    function HelperPersonnelManager:getAvailableTransportDriverForJob(job)
        local drivers, reason, hasTransportDrivers = self:getAvailableTransportDriversForJob(job)
        if drivers ~= nil and #drivers > 0 then
            return drivers[1], nil, hasTransportDrivers
        end

        return nil, reason, hasTransportDrivers
    end

    function HelperPersonnelManager:getAvailableTransportDriverForFarm(farmId, job)
        farmId = hp1570NormalizeFarmId(farmId)
        if farmId ~= nil and self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return self:getAvailableTransportDriverForJob(job)
            end, false)
        end

        return self:getAvailableTransportDriverForJob(job)
    end

    function HelperPersonnelManager:getAvailableTransportDriversForFarm(farmId, job)
        farmId = hp1570NormalizeFarmId(farmId)
        if farmId ~= nil and self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return self:getAvailableTransportDriversForJob(job)
            end, false)
        end

        return self:getAvailableTransportDriversForJob(job)
    end

    function HelperPersonnelManager:hasTransportDriversForFarm(farmId)
        farmId = hp1570NormalizeFarmId(farmId)
        if farmId ~= nil and self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return #(self:getTransportDriversSorted()) > 0
            end, false) == true
        end

        return #(self:getTransportDriversSorted()) > 0
    end

    function HelperPersonnelManager:setTransportPriorityOrder(workerIds)
        if type(workerIds) ~= "table" then
            return false
        end

        local workersById = {}
        for _, worker in ipairs(self.workers or {}) do
            local workerId = tonumber(worker.id)
            if workerId ~= nil then
                workersById[workerId] = worker
            end
        end

        if #workerIds > #(self.workers or {}) then
            return false
        end

        local seen = {}
        local normalizedIds = {}
        for _, value in ipairs(workerIds) do
            local workerId = tonumber(value)
            if workerId == nil or workerId <= 0 or workerId ~= math.floor(workerId) then
                return false
            end
            workerId = math.floor(workerId)
            if seen[workerId] == true or workersById[workerId] == nil then
                return false
            end
            seen[workerId] = true
            table.insert(normalizedIds, workerId)
        end

        local oldOrder = {}
        for _, worker in ipairs(self:getTransportDriversSorted()) do
            table.insert(oldOrder, tonumber(worker.id))
        end

        local oldStates = {}
        for workerId, worker in pairs(workersById) do
            oldStates[workerId] = worker.transportDriver == true
            worker.transportDriver = false
            worker.transportPriority = 0
        end

        for index, workerId in ipairs(normalizedIds) do
            local worker = workersById[workerId]
            worker.transportDriver = true
            worker.transportPriority = index
        end

        local changed = #oldOrder ~= #normalizedIds
        if not changed then
            for index, workerId in ipairs(normalizedIds) do
                if oldOrder[index] ~= workerId then
                    changed = true
                    break
                end
            end
        end

        for workerId, worker in pairs(workersById) do
            local enabledChanged = oldStates[workerId] ~= (worker.transportDriver == true)
            if enabledChanged then
                changed = true
                if self.addPersonChronicleEntry ~= nil then
                    local textKey = worker.transportDriver == true and "ui_transportActionAssigned" or "ui_transportActionRemoved"
                    local fallback = worker.transportDriver == true and "%s ist für Transporttätigkeiten eingeteilt." or "%s ist nicht mehr für Transporttätigkeiten eingeteilt."
                    self:addPersonChronicleEntry(worker, worker.transportDriver == true and HelperPersonnelManager.CHRONICLE_EVENT_TRANSPORT_ASSIGNED or HelperPersonnelManager.CHRONICLE_EVENT_TRANSPORT_REMOVED, {
                        reason = "manualAssignment",
                        text = string.format(hp1570GetText(textKey, fallback), hp1570GetWorkerName(self, worker))
                    })
                end
            end
        end

        if changed and self.touch ~= nil then
            self:touch(hp1570GetText("ui_transportPrioritySaved", "Transportreihenfolge gespeichert."))
        end

        return changed
    end

    function HelperPersonnelManager:setTransportPriorityOrderForFarm(workerIds, farmId)
        farmId = hp1570NormalizeFarmId(farmId)
        if farmId ~= nil and self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return self:setTransportPriorityOrder(workerIds)
            end, true) == true
        end

        return self:setTransportPriorityOrder(workerIds)
    end

end

if HelperPersonnelApp ~= nil then
    function HelperPersonnelApp:encodeTransportPriorityOrder(workerIds)
        local values = {}
        for _, workerId in ipairs(workerIds or {}) do
            local id = tonumber(workerId)
            if id ~= nil and id > 0 then
                table.insert(values, tostring(math.floor(id + 0.5)))
            end
        end
        return table.concat(values, ",")
    end

    function HelperPersonnelApp:decodeTransportPriorityOrder(actionData)
        local result = {}
        local seen = {}
        local text = tostring(actionData or "")
        if text == "" then
            return result
        end
        if #text > 16384 then
            return nil
        end

        for token in string.gmatch(text, "[^,]+") do
            local workerId = tonumber(token)
            if workerId == nil or workerId <= 0 or workerId ~= math.floor(workerId) then
                return nil
            end
            workerId = math.floor(workerId)
            if seen[workerId] == true then
                return nil
            end
            seen[workerId] = true
            table.insert(result, workerId)
            if #result > (HelperPersonnelNetwork.MAX_NETWORK_PEOPLE or 1024) then
                return nil
            end
        end

        return result
    end

    function HelperPersonnelApp:requestSetTransportPriority(workerIds)
        if self.manager == nil then
            return false
        end

        local farmId = self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1
        if self.isServerAuthority ~= nil and self:isServerAuthority() then
            if self.isConnectionFarmManager ~= nil and not self:isConnectionFarmManager(nil, farmId) then
                return false
            end
            local changed = self.manager.setTransportPriorityOrderForFarm ~= nil and self.manager:setTransportPriorityOrderForFarm(workerIds, farmId) == true
            if changed and self.syncNetworkStateToClients ~= nil then
                self:syncNetworkStateToClients()
            end
            return changed
        end

        if HelperPersonnelNetworkActionEvent ~= nil and HelperPersonnelNetworkActionEvent.send ~= nil then
            HelperPersonnelNetworkActionEvent.send(HelperPersonnelNetwork.ACTION_SET_TRANSPORT_PRIORITY, 0, self.manager.changeCounter or 0, farmId, self:encodeTransportPriorityOrder(workerIds))
            return true
        elseif g_client ~= nil and g_client.getServerConnection ~= nil and HelperPersonnelNetworkActionEvent ~= nil then
            local connection = g_client:getServerConnection()
            if connection ~= nil and connection.sendEvent ~= nil then
                connection:sendEvent(HelperPersonnelNetworkActionEvent.new(HelperPersonnelNetwork.ACTION_SET_TRANSPORT_PRIORITY, 0, self.manager.changeCounter or 0, farmId, self:encodeTransportPriorityOrder(workerIds)))
                return true
            end
        end

        return false
    end

end

if HelperPersonnelAIStartHooks ~= nil then
    local HP_V1570_ORIGINAL_OPEN_SELECTION_FOR_AI_JOB = HelperPersonnelAIStartHooks.openSelectionForAIJob
    local function hpOverride_HelperPersonnelAIStartHooks_openSelectionForAIJob_1(job, fallbackFarmId)
        if HelperPersonnelAIJobHooks ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob(job) == true then

            local app = g_helperPersonnelApp
            if app == nil or app.manager == nil then
                return false
            end

            local vehicle = HelperPersonnelAIStartHooks.getVehicleFromAIJob ~= nil and HelperPersonnelAIStartHooks.getVehicleFromAIJob(job) or nil
            if vehicle == nil then
                return false
            end

            local farmId = hp1570NormalizeFarmId(fallbackFarmId)
            if farmId == nil and app.getFarmIdForVehicle ~= nil then
                farmId = hp1570NormalizeFarmId(app:getFarmIdForVehicle(vehicle))
            end
            farmId = farmId or (app.getCurrentFarmId ~= nil and app:getCurrentFarmId() or 1)

            local drivers, reason, hasTransportDrivers = nil, nil, false
            if app.manager.getAvailableTransportDriversForFarm ~= nil then
                drivers, reason, hasTransportDrivers = app.manager:getAvailableTransportDriversForFarm(farmId, job)
            elseif app.manager.getAvailableTransportDriversForJob ~= nil then
                drivers, reason, hasTransportDrivers = app.manager:getAvailableTransportDriversForJob(job)
            elseif app.manager.getAvailableTransportDriverForFarm ~= nil then
                local worker = nil
                worker, reason, hasTransportDrivers = app.manager:getAvailableTransportDriverForFarm(farmId, job)
                if worker ~= nil then
                    drivers = {worker}
                end
            end

            if drivers == nil or #drivers == 0 then
                if app.showPlayerMessage ~= nil then
                    if reason == "busy" or hasTransportDrivers == true then
                        app:showPlayerMessage("ui_transportNoDriverAvailable")
                    else
                        app:showPlayerMessage("ui_transportNoDriverAssigned")
                    end
                end
                HelperPersonnel.debugInfo("FS25_HelperPersonnel: Transportauftrag ohne freien Transportmitarbeiter wurde blockiert")
                return false
            end

            hp1570ClearPendingWorkerForTransport(app, vehicle)

            for _, worker in ipairs(drivers) do
                if worker ~= nil and worker.id ~= nil then
                    HelperPersonnel.debugInfo("FS25_HelperPersonnel: Transportauftrag wird automatisch von Mitarbeiter-ID %s vorbereitet", tostring(worker.id))
                    hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | Startversuch mit Fahrer | ID=%s | Name=%s", tostring(worker.id), hp1570GetWorkerName(app.manager, worker))
                    hp1570ClearStaleBridgeAssignment(app, worker)
                    hp1570ClearTransportStartResidues(app, job, vehicle, worker.id)
                    if type(job) == "table" then
                        job.hpTransportAllowWorkerId = tonumber(worker.id)
                    end
                    local started = HelperPersonnelAIStartHooks.sendSelectedAIJob(vehicle, worker.id, job, farmId) == true
                    if started then
                        if type(job) == "table" then
                            job.helperPersonnelTransportStarted = true
                        end
                        if app.showPlayerMessage ~= nil then
                            app:showPlayerMessage("ui_transportAutoAssigned")
                        end
                        return true
                    end

                    if type(job) == "table" then
                        job.helperPersonnelWorkerId = nil
                        job.hpTransportAllowWorkerId = nil
                    end
                    hp1570ClearPendingWorkerForTransport(app, vehicle)
                end
            end

            if app.showPlayerMessage ~= nil then
                app:showPlayerMessage("ui_transportNoDriverAvailable")
            end
            HelperPersonnel.debugInfo("FS25_HelperPersonnel: Transportauftrag konnte mit keinem eingeteilten freien Mitarbeiter gestartet werden")
            return false
        end

        if HP_V1570_ORIGINAL_OPEN_SELECTION_FOR_AI_JOB ~= nil then
            return HP_V1570_ORIGINAL_OPEN_SELECTION_FOR_AI_JOB(job, fallbackFarmId)
        end

        return false
    end
    HelperPersonnelAIStartHooks.openSelectionForAIJob = hpOverride_HelperPersonnelAIStartHooks_openSelectionForAIJob_1

    local HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_VEHICLE = HelperPersonnelAIStartHooks.queueSelectionForVehicle
    local function hpOverride_HelperPersonnelAIStartHooks_queueSelectionForVehicle_1(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames)
        local job = fallbackJob
        if job == nil and vehicle ~= nil and vehicle.getStartableAIJob ~= nil then
            local ok, startableJob = pcall(vehicle.getStartableAIJob, vehicle)
            if ok then
                job = startableJob
            end
        end

        if HelperPersonnelAIJobHooks ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob(job) == true then

            return false
        end

        if HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_VEHICLE ~= nil then
            return HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_VEHICLE(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames)
        end

        return false
    end
    HelperPersonnelAIStartHooks.queueSelectionForVehicle = hpOverride_HelperPersonnelAIStartHooks_queueSelectionForVehicle_1

    local HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_AI_JOB = HelperPersonnelAIStartHooks.queueSelectionForAIJob
    local function hpOverride_HelperPersonnelAIStartHooks_queueSelectionForAIJob_1(job, fallbackFarmId)
        if HelperPersonnelAIJobHooks ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob(job) == true then
            return HelperPersonnelAIStartHooks.openSelectionForAIJob(job, fallbackFarmId) == true
        end

        if HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_AI_JOB ~= nil then
            return HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_AI_JOB(job, fallbackFarmId)
        end

        return false
    end
    HelperPersonnelAIStartHooks.queueSelectionForAIJob = hpOverride_HelperPersonnelAIStartHooks_queueSelectionForAIJob_1
end

if HelperPersonnelAIJobHooks ~= nil then
    local HP_V15197_ORIGINAL_GET_WORKER_ID_FOR_JOB = HelperPersonnelAIJobHooks.getWorkerIdForJob
    local function hpOverride_HelperPersonnelAIJobHooks_getWorkerIdForJob_2(app, job)
        if HelperPersonnelAIJobHooks.isTransportJob ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob(job) == true
            and not (HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.isSendingSelectedAIJob == true)
            and not (type(job) == "table" and job.hpTransportAllowWorkerId ~= nil) then

            local vehicle = HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.getVehicleFromAIJob ~= nil and HelperPersonnelAIStartHooks.getVehicleFromAIJob(job) or nil
            hp1570ClearTransportStartResidues(app, job, vehicle, nil)
            hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | normale Mitarbeiterzuordnung fuer Transportstart ignoriert, freie Transportfahrer-Auswahl wird erzwungen")
            return nil
        end

        if HP_V15197_ORIGINAL_GET_WORKER_ID_FOR_JOB ~= nil then
            return HP_V15197_ORIGINAL_GET_WORKER_ID_FOR_JOB(app, job)
        end

        return nil
    end
    HelperPersonnelAIJobHooks.getWorkerIdForJob = hpOverride_HelperPersonnelAIJobHooks_getWorkerIdForJob_2

    local HP_V15197_ORIGINAL_GET_WORKER_ID_FROM_JOB = HelperPersonnelAIJobHooks.getWorkerIdFromJob
    local function hpOverride_HelperPersonnelAIJobHooks_getWorkerIdFromJob_1(job)
        if HelperPersonnelAIJobHooks.isTransportJob ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob(job) == true
            and not (HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.isSendingSelectedAIJob == true)
            and not (HelperPersonnelAIJobHooks.isRunningStartRequestEvent == true)
            and not (type(job) == "table" and (job.hpTransportAllowWorkerId ~= nil or job.helperPersonnelTransportStarted == true)) then

            if type(job) == "table" and job.helperPersonnelWorkerId ~= nil then
                hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | alte Mitarbeiter-ID am Transportjob vor Start ignoriert | ID=%s", tostring(job.helperPersonnelWorkerId))
                job.helperPersonnelWorkerId = nil
            end
            return nil
        end

        if HP_V15197_ORIGINAL_GET_WORKER_ID_FROM_JOB ~= nil then
            return HP_V15197_ORIGINAL_GET_WORKER_ID_FROM_JOB(job)
        end

        return nil
    end
    HelperPersonnelAIJobHooks.getWorkerIdFromJob = hpOverride_HelperPersonnelAIJobHooks_getWorkerIdFromJob_1
end

if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.sendSelectedAIJob ~= nil then
    local HP_V15197_ORIGINAL_SEND_SELECTED_AI_JOB = HelperPersonnelAIStartHooks.sendSelectedAIJob
    local function hpOverride_HelperPersonnelAIStartHooks_sendSelectedAIJob_2(vehicle, workerId, fallbackJob, fallbackFarmId)
        if HelperPersonnelAIJobHooks ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob ~= nil
            and HelperPersonnelAIJobHooks.isTransportJob(fallbackJob) == true then

            local app = g_helperPersonnelApp
            if app ~= nil and app.manager ~= nil then
                local worker = app.manager.getWorkerById ~= nil and app.manager:getWorkerById(workerId) or nil
                if worker ~= nil then
                    hp1570ClearStaleBridgeAssignment(app, worker)
                end
                hp1570ClearTransportStartResidues(app, fallbackJob, vehicle, workerId)
            end

            if type(fallbackJob) == "table" then
                fallbackJob.hpTransportAllowWorkerId = tonumber(workerId)
            end

            local oldSending = HelperPersonnelAIStartHooks.isSendingSelectedAIJob
            HelperPersonnelAIStartHooks.isSendingSelectedAIJob = true
            local result = HP_V15197_ORIGINAL_SEND_SELECTED_AI_JOB(vehicle, workerId, fallbackJob, fallbackFarmId)
            HelperPersonnelAIStartHooks.isSendingSelectedAIJob = oldSending

            if result == true and type(fallbackJob) == "table" then
                fallbackJob.helperPersonnelTransportStarted = true
            end

            hp1570Debug("FS25_HelperPersonnel: Transport-Diagnose | sendSelectedAIJob Transport Ergebnis | Mitarbeiter=%s | Ergebnis=%s", tostring(workerId), tostring(result == true))
            return result
        end

        return HP_V15197_ORIGINAL_SEND_SELECTED_AI_JOB(vehicle, workerId, fallbackJob, fallbackFarmId)
    end
    HelperPersonnelAIStartHooks.sendSelectedAIJob = hpOverride_HelperPersonnelAIStartHooks_sendSelectedAIJob_2
end
