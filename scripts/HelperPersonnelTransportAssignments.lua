-- Transportzuweisungen
-- Fuer A-nach-B-Auftraege aus dem ESC-Jobmenue wird kein Auswahlfenster geoeffnet.
-- Stattdessen koennen Mitarbeiter im Personalmanagement fuer Transporttaetigkeiten vorgemerkt werden.
-- Der erste freie Transportmitarbeiter uebernimmt solche Auftraege automatisch.

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.STATE_VERSION = math.max(tonumber(HelperPersonnelNetwork.STATE_VERSION) or 0, 7)
HelperPersonnelNetwork.ACTION_TOGGLE_TRANSPORT = "toggleTransport"
HelperPersonnelTransportAssignments = HelperPersonnelTransportAssignments or {}
-- Diagnose-Logging fuer Transportzuweisungen. Standardmaessig deaktiviert.
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

local function hp1570GetInputAction(actionName)
    if InputAction ~= nil and InputAction[actionName] ~= nil then
        return InputAction[actionName]
    end

    return actionName
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

    -- Fuer die Transport-Verfuegbarkeitspruefung duerfen nur direkte, bereits
    -- vorhandene Zuordnungen gelesen werden. Der allgemeine Fallback
    -- HelperPersonnelAIJobHooks.getWorkerIdFromJob() kann ueber Fahrzeug- oder
    -- HelperIndex-Reste selbst wieder alte Zuordnungen herstellen und hat dadurch
    -- freie Transportfahrer faelschlich als aktiv erscheinen lassen.
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

    -- Wenn die aktive Jobliste nicht verfuegbar ist, ist eine vorhandene Bridge-
    -- Zuordnung die sicherste Information. Ohne Bridge-Zuordnung wird ein busy-
    -- Restzustand als veraltet behandelt.
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

    -- Transportfahrer duerfen nur dann als beschaeftigt gelten, wenn wirklich ein
    -- aktiver AIJob fuer diesen Mitarbeiter gefunden wird. Reine Restdaten wie
    -- vehicleName, vehicleKey oder currentJobStartedAt koennen nach abgebrochenen
    -- oder umgehaengten Transportstarts stehen bleiben und wuerden sonst freie
    -- Transportmitarbeiter blockieren.
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

    -- Normale Helferstarts verwenden eine kurze Pending-Zuordnung. Transportjobs
    -- duerfen diese globale Restzuordnung nicht erben, weil sonst ein zuvor
    -- ausgewaehlter, inzwischen beschaeftigter Mitarbeiter den Transportstart
    -- blockieren kann.
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
    function HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
        if hp1570IsTransportJobByClass(job)
            and type(job) == "table"
            and job.helperPersonnelWorkerId == nil then
            -- Transportauftraege werden ausschliesslich ueber die Transportfahrer-
            -- Einteilung bedient. Dadurch erben sie keine alte Pending-Auswahl aus
            -- einem vorherigen normalen Helferstart.
            return nil
        end

        if HP_V15192_ORIGINAL_GET_WORKER_ID_FOR_JOB ~= nil then
            return HP_V15192_ORIGINAL_GET_WORKER_ID_FOR_JOB(app, job)
        end

        return nil
    end
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
    function HelperPersonnelHelperBridge:canUseWorkerForJob(workerId, job)
        if HP_V15193_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB ~= nil
            and HP_V15193_ORIGINAL_BRIDGE_CAN_USE_WORKER_FOR_JOB(self, workerId, job) == true then
            return true
        end

        -- Bei Grundspiel-Transportauftraegen kann das Spiel zwischen Zielauswahl,
        -- Client/Server-Start und eigentlichem AISystem-Start ein neues AIJob-Objekt
        -- verwenden. Dann ist derselbe Mitarbeiter bereits am vorbereiteten
        -- Transportjob vorgemerkt, obwohl der tatsaechliche Startjob ein anderes
        -- Lua-Objekt ist. Wenn beide Transportjobs eindeutig zum selben Fahrzeug
        -- gehoeren, wird diese vorbereitete Zuordnung zugelassen und beim Start auf
        -- den echten Job umgehaengt.
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
end

if HelperPersonnelManager ~= nil then
    local HP_V1570_ORIGINAL_NORMALIZE_PERSON = HelperPersonnelManager.normalizePersonRuntimeData
    function HelperPersonnelManager:normalizePersonRuntimeData(person)
        if HP_V1570_ORIGINAL_NORMALIZE_PERSON ~= nil then
            HP_V1570_ORIGINAL_NORMALIZE_PERSON(self, person)
        end

        if type(person) == "table" then
            person.transportDriver = person.transportDriver == true
        end

        return person
    end

    local HP_V1570_ORIGINAL_READ_PERSON_XML = HelperPersonnelManager.readPersonFromXML
    function HelperPersonnelManager:readPersonFromXML(xmlFile, key)
        local person = HP_V1570_ORIGINAL_READ_PERSON_XML ~= nil and HP_V1570_ORIGINAL_READ_PERSON_XML(self, xmlFile, key) or nil
        if type(person) == "table" and xmlFile ~= nil and key ~= nil and xmlFile.getBool ~= nil then
            person.transportDriver = xmlFile:getBool(key .. "#transportDriver", false) == true
        end
        return person
    end

    local HP_V1570_ORIGINAL_WRITE_PERSON_XML = HelperPersonnelManager.writePersonToXML
    function HelperPersonnelManager:writePersonToXML(xmlFile, key, person, includeWorkerState)
        if HP_V1570_ORIGINAL_WRITE_PERSON_XML ~= nil then
            HP_V1570_ORIGINAL_WRITE_PERSON_XML(self, xmlFile, key, person, includeWorkerState)
        end

        if xmlFile ~= nil and key ~= nil and person ~= nil and includeWorkerState == true then
            xmlFile:setBool(key .. "#transportDriver", person.transportDriver == true)
        end
    end

    local HP_V1570_ORIGINAL_COPY_PERSON_NETWORK = HelperPersonnelManager.copyPersonForNetwork
    function HelperPersonnelManager:copyPersonForNetwork(person)
        local copy = HP_V1570_ORIGINAL_COPY_PERSON_NETWORK ~= nil and HP_V1570_ORIGINAL_COPY_PERSON_NETWORK(self, person) or {}
        if type(person) == "table" then
            copy.transportDriver = person.transportDriver == true
        end
        return copy
    end

    if HelperPersonnelManager.xmlSchema ~= nil and XMLValueType ~= nil then
        HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, "helperPersonnel.farms.farm(?).workers.worker(?)#transportDriver", "Mitarbeiter ist fuer Transporttaetigkeiten vorgemerkt")
    end

    function HelperPersonnelManager:getTransportDriversSorted()
        local result = {}
        for _, worker in ipairs(self.workers or {}) do
            self:normalizePersonRuntimeData(worker)
            if worker.transportDriver == true then
                table.insert(result, worker)
            end
        end

        table.sort(result, function(a, b)
            if (a.reliability or 0) ~= (b.reliability or 0) then
                return (a.reliability or 0) > (b.reliability or 0)
            end
            if (a.experience or 0) ~= (b.experience or 0) then
                return (a.experience or 0) > (b.experience or 0)
            end
            local nameA = tostring(a.firstName or "") .. tostring(a.lastName or "")
            local nameB = tostring(b.firstName or "") .. tostring(b.lastName or "")
            return nameA < nameB
        end)

        return result
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

        -- Zuerst wird streng geprueft: Ein Mitarbeiter, der im Manager noch als
        -- beschaeftigt steht, wird nicht fuer Transport ausgewaehlt. Dadurch kann
        -- ein tatsaechlich laufender Feldeinsatz nicht versehentlich als freier
        -- Transportfahrer verwendet werden, nur weil die AIJob-Erkennung einen
        -- aktiven Job nicht eindeutig findet.
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
            -- Auch bei worker.busy ~= true koennen in der Bridge noch alte
            -- workerJobById-/vehicleWorkerIds-Zuordnungen stehen. Diese fuehren
            -- beim eigentlichen Transportstart zu "Mitarbeiter bereits im Einsatz",
            -- obwohl der Mitarbeiter in der Verwaltung frei wirkt. Deshalb wird
            -- vor der abschliessenden Verfuegbarkeitspruefung ein eindeutig nicht
            -- aktiver Restzustand bereinigt.
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

        -- Erster Durchlauf: nur eindeutig freie Mitarbeiter verwenden.
        for _, worker in ipairs(drivers) do
            if self:isTransportDriverAvailableForJob(worker, job, false) then
                table.insert(result, worker)
            end
        end

        if #result > 0 then
            return result, nil, #drivers > 0
        end

        -- Zweiter Durchlauf: freie Mitarbeiter mit veralteten Bridge-Restdaten
        -- bereinigen. Das ist der wichtigste Fall nach abgebrochenen oder
        -- umgehaengten Transportstarts: Der Mitarbeiter wirkt frei, hat aber
        -- intern noch eine alte workerJobById-/vehicleWorkerIds-Zuordnung.
        for _, worker in ipairs(drivers) do
            if worker.busy ~= true and self:isTransportDriverAvailableForJob(worker, job, true) then
                table.insert(result, worker)
            end
        end

        if #result > 0 then
            return result, nil, #drivers > 0
        end

        -- Letzter Durchlauf: nur wenn wirklich kein freier Mitarbeiter gefunden
        -- wurde, duerfen auch alte Busy-Restzustaende bereinigt werden. Ein
        -- tatsaechlich aktiver AIJob bleibt durch hp1570WorkerHasActiveAIJob
        -- geschuetzt.
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

    function HelperPersonnelManager:setWorkerTransportDriver(workerId, enabled)
        workerId = tonumber(workerId)
        if workerId == nil then
            return false
        end

        local worker = self:getWorkerById(workerId)
        if worker == nil then
            return false
        end

        local newValue = enabled == true
        if worker.transportDriver == newValue then
            return false
        end

        worker.transportDriver = newValue
        self:normalizePersonRuntimeData(worker)

        local name = hp1570GetWorkerName(self, worker)
        local textKey = newValue and "ui_transportActionAssigned" or "ui_transportActionRemoved"
        local fallback = newValue and "%s ist fuer Transporttaetigkeiten eingeteilt." or "%s ist nicht mehr fuer Transporttaetigkeiten eingeteilt."
        local actionText = string.format(hp1570GetText(textKey, fallback), name)

        if self.touch ~= nil then
            self:touch(actionText)
        end

        return true
    end

    function HelperPersonnelManager:toggleWorkerTransportDriver(workerId)
        local worker = self:getWorkerById(workerId)
        if worker == nil then
            return false
        end

        return self:setWorkerTransportDriver(workerId, worker.transportDriver ~= true)
    end

    function HelperPersonnelManager:toggleWorkerTransportDriverForFarm(workerId, farmId)
        farmId = hp1570NormalizeFarmId(farmId)
        if farmId ~= nil and self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return self:toggleWorkerTransportDriver(workerId)
            end, true) == true
        end

        return self:toggleWorkerTransportDriver(workerId)
    end

    local HP_V1570_ORIGINAL_WORKER_HIRED_LINE = HelperPersonnelManager.getWorkerHiredLine
    function HelperPersonnelManager:getWorkerHiredLine(person)
        local line = HP_V1570_ORIGINAL_WORKER_HIRED_LINE ~= nil and HP_V1570_ORIGINAL_WORKER_HIRED_LINE(self, person) or ""
        if type(person) == "table" and person.transportDriver == true then
            return string.format("%s | %s", line, hp1570GetText("ui_transportMarker", "Transport"))
        end
        return line
    end
end

if HelperPersonnelNetwork ~= nil then
    local function hp1570WriteTransportFlags(streamId, workers)
        for _, worker in ipairs(workers or {}) do
            streamWriteBool(streamId, worker ~= nil and worker.transportDriver == true)
        end
    end

    local function hp1570ReadTransportFlags(streamId, workers)
        for _, worker in ipairs(workers or {}) do
            if type(worker) == "table" then
                worker.transportDriver = streamReadBool(streamId) == true
            else
                streamReadBool(streamId)
            end
        end
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

        hp1570WriteTransportFlags(streamId, farmState.workers or {})
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

        if (version or 0) >= 5 then
            hp1570ReadTransportFlags(streamId, farmState.workers or {})
        end

        return farmState
    end
end

if HelperPersonnelApp ~= nil then
    function HelperPersonnelApp:requestToggleTransportDriver(workerId)
        if workerId == nil or self.manager == nil then
            return false
        end

        local farmId = self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1
        local changed = false

        if self.isServerAuthority ~= nil and self:isServerAuthority() then
            if self.manager.toggleWorkerTransportDriverForFarm ~= nil then
                changed = self.manager:toggleWorkerTransportDriverForFarm(workerId, farmId) == true
            elseif self.manager.toggleWorkerTransportDriver ~= nil then
                changed = self.manager:toggleWorkerTransportDriver(workerId) == true
            end

            if changed and self.syncNetworkStateToClients ~= nil then
                self:syncNetworkStateToClients()
            end
        elseif HelperPersonnelNetworkActionEvent ~= nil and HelperPersonnelNetworkActionEvent.send ~= nil then
            HelperPersonnelNetworkActionEvent.send(HelperPersonnelNetwork.ACTION_TOGGLE_TRANSPORT, workerId, self.manager.changeCounter or 0, farmId)
            changed = true
        end

        return changed
    end

    local HP_V1570_ORIGINAL_VALIDATE_NETWORK_ACTION_TARGET = HelperPersonnelApp.validateNetworkActionTarget
    function HelperPersonnelApp:validateNetworkActionTarget(actionName, targetId, farmId)
        if actionName == HelperPersonnelNetwork.ACTION_TOGGLE_TRANSPORT then
            return self.manager ~= nil and self.manager.hasWorkerInFarm ~= nil and self.manager:hasWorkerInFarm(targetId, farmId) == true
        end

        if HP_V1570_ORIGINAL_VALIDATE_NETWORK_ACTION_TARGET ~= nil then
            return HP_V1570_ORIGINAL_VALIDATE_NETWORK_ACTION_TARGET(self, actionName, targetId, farmId)
        end

        return false
    end

    local HP_V1570_ORIGINAL_PROCESS_NETWORK_ACTION = HelperPersonnelApp.processNetworkAction
    function HelperPersonnelApp:processNetworkAction(actionName, targetId, connection, farmId)
        if actionName ~= HelperPersonnelNetwork.ACTION_TOGGLE_TRANSPORT then
            if HP_V1570_ORIGINAL_PROCESS_NETWORK_ACTION ~= nil then
                return HP_V1570_ORIGINAL_PROCESS_NETWORK_ACTION(self, actionName, targetId, connection, farmId)
            end
            return false
        end

        if self.isServerAuthority == nil or self:isServerAuthority() ~= true or self.manager == nil then
            return false
        end

        local authorizedFarmId = hp1570NormalizeFarmId(farmId) or (self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1)
        if self.resolveAuthorizedFarmId ~= nil then
            local allowed, resolvedFarmId = self:resolveAuthorizedFarmId(connection, farmId, nil, actionName)
            if not allowed then
                if connection ~= nil and self.sendNetworkStateToConnection ~= nil then
                    self:sendNetworkStateToConnection(connection)
                end
                return false
            end
            authorizedFarmId = resolvedFarmId or authorizedFarmId
        end

        if self.validateNetworkActionTarget ~= nil and not self:validateNetworkActionTarget(actionName, targetId, authorizedFarmId) then
            if connection ~= nil and self.sendNetworkStateToConnection ~= nil then
                self:sendNetworkStateToConnection(connection)
            end
            return false
        end

        local changed = false
        if self.manager.toggleWorkerTransportDriverForFarm ~= nil then
            changed = self.manager:toggleWorkerTransportDriverForFarm(targetId, authorizedFarmId) == true
        elseif self.manager.toggleWorkerTransportDriver ~= nil then
            changed = self.manager:toggleWorkerTransportDriver(targetId) == true
        end

        if changed and self.syncNetworkStateToClients ~= nil then
            self:syncNetworkStateToClients()
        elseif connection ~= nil and self.sendNetworkStateToConnection ~= nil then
            self:sendNetworkStateToConnection(connection)
        end

        return changed
    end
end

if HelperPersonnelAIStartHooks ~= nil then
    local HP_V1570_ORIGINAL_OPEN_SELECTION_FOR_AI_JOB = HelperPersonnelAIStartHooks.openSelectionForAIJob
    function HelperPersonnelAIStartHooks.openSelectionForAIJob(job, fallbackFarmId)
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

    local HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_VEHICLE = HelperPersonnelAIStartHooks.queueSelectionForVehicle
    function HelperPersonnelAIStartHooks.queueSelectionForVehicle(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames)
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
            -- Transportjobs nicht ueber den fahrzeugbasierten Helferstart behandeln.
            -- Dieser Pfad kann waehrend der Zielauswahl im Grundspiel-Jobmenue zu frueh
            -- feuern. Die automatische Transportfahrer-Auswahl erfolgt erst beim
            -- tatsaechlichen AIJob-Start ueber queueSelectionForAIJob/openSelectionForAIJob.
            return false
        end

        if HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_VEHICLE ~= nil then
            return HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_VEHICLE(vehicle, fallbackJob, fallbackFarmId, reason, delayFrames)
        end

        return false
    end

    local HP_V15191_ORIGINAL_QUEUE_SELECTION_FOR_AI_JOB = HelperPersonnelAIStartHooks.queueSelectionForAIJob
    function HelperPersonnelAIStartHooks.queueSelectionForAIJob(job, fallbackFarmId)
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
end

if HelperPersonnelAIJobHooks ~= nil then
    local HP_V15197_ORIGINAL_GET_WORKER_ID_FOR_JOB = HelperPersonnelAIJobHooks.getWorkerIdForJob
    function HelperPersonnelAIJobHooks.getWorkerIdForJob(app, job)
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

    local HP_V15197_ORIGINAL_GET_WORKER_ID_FROM_JOB = HelperPersonnelAIJobHooks.getWorkerIdFromJob
    function HelperPersonnelAIJobHooks.getWorkerIdFromJob(job)
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
end

if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.sendSelectedAIJob ~= nil then
    local HP_V15197_ORIGINAL_SEND_SELECTED_AI_JOB = HelperPersonnelAIStartHooks.sendSelectedAIJob
    function HelperPersonnelAIStartHooks.sendSelectedAIJob(vehicle, workerId, fallbackJob, fallbackFarmId)
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
end

if HelperPersonnelFrame ~= nil then
    function HelperPersonnelFrame:getSelectedWorkerForTransportToggle()
        if self.mode ~= HelperPersonnelFrame.MODE_WORKERS then
            return nil
        end

        local workers = self:getWorkers()
        if #workers == 0 then
            return nil
        end

        self.workerIndex = math.max(1, math.min(self.workerIndex or 1, #workers))
        return workers[self.workerIndex]
    end

    function HelperPersonnelFrame:onClickTransportToggle()
        local worker = self:getSelectedWorkerForTransportToggle()
        if worker == nil or self.app == nil or self.app.requestToggleTransportDriver == nil then
            return false
        end

        -- T kann im pausierten ESC-Menue je nach Eingabekontext direkt als
        -- keyEvent oder als registriertes ActionEvent ankommen. Eine kurze Sperre
        -- verhindert, dass ein einzelner Tastendruck die Zuordnung sofort wieder
        -- an- und abwaehlt. Es wird bewusst kein unterer Menuebutton eingefuegt.
        local now = g_time or 0
        if now > 0 and self.hpLastTransportToggleTime ~= nil and now - self.hpLastTransportToggleTime < 200 then
            return true
        end
        if now > 0 then
            self.hpLastTransportToggleTime = now
        end

        local changed = self.app:requestToggleTransportDriver(worker.id) == true
        if changed then
            self.requestRender = true
            if self.setMenuButtonInfoDirty ~= nil then
                self:setMenuButtonInfoDirty()
            end
        end

        return true
    end

    function HelperPersonnelFrame:onActionTransportToggle(actionName, inputValue)
        if inputValue ~= nil and inputValue <= 0 then
            return
        end

        if self.mode == HelperPersonnelFrame.MODE_WORKERS then
            self:onClickTransportToggle()
        end
    end

    function HelperPersonnelFrame:registerTransportActionEvent()
        if self.hpTransportActionRegistered == true or g_inputBinding == nil then
            return
        end

        self.hpTransportActionEventIds = {}

        local contextName = g_inputBinding.currentContextName
        local modificationStarted = false
        if contextName ~= nil and g_inputBinding.beginActionEventsModification ~= nil then
            g_inputBinding:beginActionEventsModification(contextName)
            modificationStarted = true
        end

        local actionId = hp1570GetInputAction("HP_TRANSPORT_TOGGLE")
        local success, actionEventId = g_inputBinding:registerActionEvent(actionId, self, self.onActionTransportToggle, false, true, false, true, nil, true)

        if success == true and actionEventId ~= nil then
            table.insert(self.hpTransportActionEventIds, actionEventId)

            if g_inputBinding.setActionEventText ~= nil then
                g_inputBinding:setActionEventText(actionEventId, hp1570GetText("input_HP_TRANSPORT_TOGGLE", "Transportzuweisung umschalten"))
            end
            if g_inputBinding.setActionEventTextVisibility ~= nil then
                -- Das ActionEvent faengt nur T ab und soll keinen zusaetzlichen
                -- Button in der unteren ESC-Menueleiste anzeigen.
                g_inputBinding:setActionEventTextVisibility(actionEventId, false)
            end
            if g_inputBinding.setActionEventActive ~= nil then
                g_inputBinding:setActionEventActive(actionEventId, true)
            end

            self.hpTransportActionRegistered = true
        elseif Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("[HelperPersonnel] Could not register transport input action '%s'", tostring("HP_TRANSPORT_TOGGLE"))
        end

        if modificationStarted and g_inputBinding.endActionEventsModification ~= nil then
            g_inputBinding:endActionEventsModification()
        end
    end

    function HelperPersonnelFrame:unregisterTransportActionEvent()
        if self.hpTransportActionRegistered ~= true or g_inputBinding == nil then
            self.hpTransportActionEventIds = {}
            self.hpTransportActionRegistered = false
            return
        end

        if self.hpTransportActionEventIds ~= nil and g_inputBinding.removeActionEvent ~= nil then
            for _, actionEventId in ipairs(self.hpTransportActionEventIds) do
                g_inputBinding:removeActionEvent(actionEventId)
            end
        elseif g_inputBinding.removeActionEventsByTarget ~= nil then
            g_inputBinding:removeActionEventsByTarget(self)
        end

        self.hpTransportActionEventIds = {}
        self.hpTransportActionRegistered = false
    end

    local HP_V151910_ORIGINAL_REGISTER_ACTION_EVENTS = HelperPersonnelFrame.registerActionEvents
    function HelperPersonnelFrame:registerActionEvents()
        if HP_V151910_ORIGINAL_REGISTER_ACTION_EVENTS ~= nil then
            HP_V151910_ORIGINAL_REGISTER_ACTION_EVENTS(self)
        end

        self:registerTransportActionEvent()
    end

    local HP_V151910_ORIGINAL_UNREGISTER_ACTION_EVENTS = HelperPersonnelFrame.unregisterActionEvents
    function HelperPersonnelFrame:unregisterActionEvents()
        self:unregisterTransportActionEvent()

        if HP_V151910_ORIGINAL_UNREGISTER_ACTION_EVENTS ~= nil then
            HP_V151910_ORIGINAL_UNREGISTER_ACTION_EVENTS(self)
        end
    end

    local HP_V151910_ORIGINAL_FRAME_OPEN = HelperPersonnelFrame.onFrameOpen
    function HelperPersonnelFrame:onFrameOpen()
        if HP_V151910_ORIGINAL_FRAME_OPEN ~= nil then
            HP_V151910_ORIGINAL_FRAME_OPEN(self)
        end

        self:registerTransportActionEvent()
    end

    local HP_V151910_ORIGINAL_FRAME_CLOSE = HelperPersonnelFrame.onFrameClose
    function HelperPersonnelFrame:onFrameClose()
        self:unregisterTransportActionEvent()

        if HP_V151910_ORIGINAL_FRAME_CLOSE ~= nil then
            HP_V151910_ORIGINAL_FRAME_CLOSE(self)
        end
    end

    local HP_V151910_ORIGINAL_KEY_EVENT = HelperPersonnelFrame.keyEvent
    function HelperPersonnelFrame:keyEvent(unicode, sym, modifier, isDown)
        if isDown and self.mode == HelperPersonnelFrame.MODE_WORKERS then
            local isTransportKey = false
            if Input ~= nil and Input.KEY_t ~= nil and sym == Input.KEY_t then
                isTransportKey = true
            elseif unicode == string.byte("t") or unicode == string.byte("T") then
                isTransportKey = true
            end

            if isTransportKey then
                return self:onClickTransportToggle()
            end
        end

        if HP_V151910_ORIGINAL_KEY_EVENT ~= nil then
            return HP_V151910_ORIGINAL_KEY_EVENT(self, unicode, sym, modifier, isDown)
        end

        return false
    end
end
