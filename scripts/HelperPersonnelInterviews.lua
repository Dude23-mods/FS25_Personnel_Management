HelperPersonnelInterviews = HelperPersonnelInterviews or {}

HelperPersonnelInterviews.TOPICS = {"experience", "reliability", "loyalty"}
HelperPersonnelInterviews.MAX_QUESTIONS = 3
HelperPersonnelInterviews.INITIAL_RANGE_WIDTH = 30
HelperPersonnelInterviews.NARROW_RANGE_WIDTH = 15
HelperPersonnelInterviews.DISCOVERY_MIN_REALTIME_MS = 20 * 60 * 1000
HelperPersonnelInterviews.DISCOVERY_MAX_REALTIME_MS = 35 * 60 * 1000

local function hpInterviewClampStat(value)
    return math.max(0, math.min(100, math.floor((tonumber(value) or 0) + 0.5)))
end

local function hpInterviewHash(value)
    local hash = 2166136261
    local text = tostring(value or "")
    for index = 1, #text do
        hash = (hash * 16777619 + string.byte(text, index)) % 2147483647
    end
    return math.max(1, hash)
end

local function hpInterviewNext(seed)
    return (seed * 48271) % 2147483647
end

local function hpInterviewPick(seed, minimum, maximum)
    local count = math.max(1, maximum - minimum + 1)
    local limit = math.floor(2147483646 / count) * count
    local value
    repeat
        seed = hpInterviewNext(seed)
        value = seed - 1
    until value < limit
    return seed, minimum + (value % count)
end

local function hpInterviewTopicField(topic)
    if topic == "experience" then
        return "experience"
    elseif topic == "reliability" then
        return "reliability"
    elseif topic == "loyalty" then
        return "loyalty"
    end
    return nil
end

local function hpInterviewCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end
    seen = seen or {}
    if seen[value] ~= nil then
        return seen[value]
    end
    local copy = {}
    seen[value] = copy
    for key, item in pairs(value) do
        copy[hpInterviewCopy(key, seen)] = hpInterviewCopy(item, seen)
    end
    return copy
end

function HelperPersonnelManager:isApplicantInterviewsEnabled()
    return self.config == nil or self.config.applicantInterviewsEnabled ~= false
end

function HelperPersonnelManager:getApplicantInterviewSeed(applicant)
    if type(applicant) ~= "table" then
        return 1
    end
    local seed = tonumber(applicant.interviewSeed)
    if seed == nil or seed <= 0 then
        seed = hpInterviewHash(string.format("%s:%s:%s:%s", tostring(applicant.id or 0), tostring(applicant.firstName or ""), tostring(applicant.lastName or ""), tostring(applicant.avatarIndex or 0)))
        applicant.interviewSeed = seed
    end
    return seed
end

function HelperPersonnelManager:getApplicantInterviewRange(applicant, topic, level)
    local field = hpInterviewTopicField(topic)
    if type(applicant) ~= "table" or field == nil then
        return nil, nil
    end
    local value = hpInterviewClampStat(applicant[field])
    level = math.max(0, math.min(3, math.floor((tonumber(level) or 0) + 0.5)))
    if level >= 3 then
        return value, value
    end
    if level <= 0 then
        return nil, nil
    end
    local width = level == 1 and HelperPersonnelInterviews.INITIAL_RANGE_WIDTH or HelperPersonnelInterviews.NARROW_RANGE_WIDTH
    local minimumStart = math.max(0, value - width)
    local maximumStart = math.min(value, 100 - width)
    local seed = self:getApplicantInterviewSeed(applicant) + (topic == "experience" and 101 or topic == "reliability" and 211 or 307)
    local _, start = hpInterviewPick(seed, minimumStart, maximumStart)
    if level == 2 then
        local broadMinimum, broadMaximum = self:getApplicantInterviewRange(applicant, topic, 1)
        minimumStart = math.max(broadMinimum or 0, value - width)
        maximumStart = math.min(value, (broadMaximum or 100) - width)
        local narrowSeed = self:getApplicantInterviewSeed(applicant) + (topic == "experience" and 401 or topic == "reliability" and 503 or 601)
        narrowSeed, start = hpInterviewPick(narrowSeed, minimumStart, maximumStart)
    end
    return start, start + width
end

function HelperPersonnelManager:normalizeApplicantInterviewData(applicant)
    if type(applicant) ~= "table" then
        return nil
    end
    self:getApplicantInterviewSeed(applicant)
    applicant.interviewQuestionsUsed = math.max(0, math.min(HelperPersonnelInterviews.MAX_QUESTIONS, math.floor((tonumber(applicant.interviewQuestionsUsed) or 0) + 0.5)))
    applicant.interviewExperienceLevel = math.max(0, math.min(3, math.floor((tonumber(applicant.interviewExperienceLevel) or 0) + 0.5)))
    applicant.interviewReliabilityLevel = math.max(0, math.min(3, math.floor((tonumber(applicant.interviewReliabilityLevel) or 0) + 0.5)))
    applicant.interviewLoyaltyLevel = math.max(0, math.min(3, math.floor((tonumber(applicant.interviewLoyaltyLevel) or 0) + 0.5)))
    if applicant.interviewInitialTopic == nil then
        local _, topicIndex = hpInterviewPick(self:getApplicantInterviewSeed(applicant) + 701, 1, #HelperPersonnelInterviews.TOPICS)
        applicant.interviewInitialTopic = HelperPersonnelInterviews.TOPICS[topicIndex]
    end
    local initialField = "interview" .. string.upper(string.sub(applicant.interviewInitialTopic, 1, 1)) .. string.sub(applicant.interviewInitialTopic, 2) .. "Level"
    applicant[initialField] = math.max(1, tonumber(applicant[initialField]) or 0)
    applicant.interviewHistory = type(applicant.interviewHistory) == "table" and applicant.interviewHistory or {}
    applicant.interviewCompleted = applicant.interviewQuestionsUsed >= HelperPersonnelInterviews.MAX_QUESTIONS
    return applicant
end

function HelperPersonnelManager:getApplicantInterviewLevel(applicant, topic)
    self:normalizeApplicantInterviewData(applicant)
    if topic == "experience" then
        return applicant.interviewExperienceLevel or 0
    elseif topic == "reliability" then
        return applicant.interviewReliabilityLevel or 0
    elseif topic == "loyalty" then
        return applicant.interviewLoyaltyLevel or 0
    end
    return 0
end

function HelperPersonnelManager:getApplicantInterviewKnowledge(applicant, topic)
    if not self:isApplicantInterviewsEnabled() then
        local field = hpInterviewTopicField(topic)
        local value = field ~= nil and hpInterviewClampStat(applicant[field]) or 0
        return 3, value, value
    end
    local level = self:getApplicantInterviewLevel(applicant, topic)
    local minimum, maximum = self:getApplicantInterviewRange(applicant, topic, level)
    return level, minimum, maximum
end

function HelperPersonnelManager:canAskApplicantInterviewTopic(applicant, topic)
    if type(applicant) ~= "table" or hpInterviewTopicField(topic) == nil or not self:isApplicantInterviewsEnabled() then
        return false
    end
    self:normalizeApplicantInterviewData(applicant)
    return applicant.interviewQuestionsUsed < HelperPersonnelInterviews.MAX_QUESTIONS and self:getApplicantInterviewLevel(applicant, topic) < 3
end

function HelperPersonnelManager:askApplicantInterviewQuestionForFarm(applicantId, farmId, topic)
    return self:executeWithFarmContext(farmId, function()
        local applicant = self:getApplicantById(applicantId)
        if not self:canAskApplicantInterviewTopic(applicant, topic) then
            return false
        end
        local level = self:getApplicantInterviewLevel(applicant, topic) + 1
        if topic == "experience" then
            applicant.interviewExperienceLevel = level
        elseif topic == "reliability" then
            applicant.interviewReliabilityLevel = level
        else
            applicant.interviewLoyaltyLevel = level
        end
        applicant.interviewQuestionsUsed = applicant.interviewQuestionsUsed + 1
        applicant.interviewCompleted = applicant.interviewQuestionsUsed >= HelperPersonnelInterviews.MAX_QUESTIONS
        local seed = self:getApplicantInterviewSeed(applicant) + applicant.interviewQuestionsUsed * 809 + level * 17
        local nextSeed, questionVariant = hpInterviewPick(seed, 1, 3)
        local _, answerVariant = hpInterviewPick(nextSeed, 1, 3)
        for _, previous in ipairs(applicant.interviewHistory) do
            local oldVariant = tonumber(previous.variant) or 1
            if previous.topic == topic and oldVariant >= 4 and oldVariant <= 12 then
                local oldQuestion = math.floor((oldVariant - 4) / 3) + 1
                local oldAnswer = (oldVariant - 4) % 3 + 1
                if level > 1 and tonumber(previous.level) and tonumber(previous.level) > 1 and questionVariant == oldQuestion then
                    questionVariant = questionVariant % 3 + 1
                end
                if answerVariant == oldAnswer then answerVariant = answerVariant % 3 + 1 end
            end
        end
        local variant = 4 + (questionVariant - 1) * 3 + answerVariant - 1
        local value = hpInterviewClampStat(applicant[hpInterviewTopicField(topic)])
        local band = value < 40 and 1 or value < 70 and 2 or 3
        if value >= 30 and value < 50 then
            local _, choice = hpInterviewPick(nextSeed + 353, 1, 2)
            band = choice
        elseif value >= 60 and value < 80 then
            local _, choice = hpInterviewPick(nextSeed + 353, 1, 2)
            band = choice + 1
        end
        table.insert(applicant.interviewHistory, {topic = topic, level = level, variant = variant, band = band})
        self:touch(nil)
        return true
    end, true)
end

function HelperPersonnelManager:getApplicantInterviewLeaderKey(applicantId, farmId)
    return string.format("%d:%d", math.floor((tonumber(farmId) or 0) + 0.5), math.floor((tonumber(applicantId) or 0) + 0.5))
end

function HelperPersonnelManager:claimApplicantInterviewLeadership(applicantId, farmId, leaderToken)
    local data = self:getFarmDataIfExists(farmId)
    if self:getApplicantFromFarmData(data, applicantId) == nil or leaderToken == nil then
        return false
    end
    self.applicantInterviewLeaders = self.applicantInterviewLeaders or {}
    local key = self:getApplicantInterviewLeaderKey(applicantId, farmId)
    local current = self.applicantInterviewLeaders[key]
    local now = tonumber(g_time) or (g_currentMission ~= nil and tonumber(g_currentMission.time)) or 0
    local currentToken = type(current) == "table" and current.token or current
    local currentTime = type(current) == "table" and tonumber(current.lastSeen) or now
    if current == nil or currentToken == leaderToken or now - currentTime > 15000 then
        self.applicantInterviewLeaders[key] = {token = leaderToken, lastSeen = now}
        return true
    end
    return false
end

function HelperPersonnelManager:isApplicantInterviewLeader(applicantId, farmId, leaderToken)
    if leaderToken == nil then
        return false
    end
    local leaders = self.applicantInterviewLeaders or {}
    local current = leaders[self:getApplicantInterviewLeaderKey(applicantId, farmId)]
    return (type(current) == "table" and current.token or current) == leaderToken
end

function HelperPersonnelManager:releaseApplicantInterviewLeadership(applicantId, farmId, leaderToken)
    if not self:isApplicantInterviewLeader(applicantId, farmId, leaderToken) then
        return false
    end
    self.applicantInterviewLeaders[self:getApplicantInterviewLeaderKey(applicantId, farmId)] = nil
    return true
end

function HelperPersonnelManager:prepareHiredWorkerDiscovery(applicant)
    if type(applicant) ~= "table" then
        return
    end
    self:normalizeApplicantInterviewData(applicant)
    local seed = self:getApplicantInterviewSeed(applicant) + 1201
    local _, threshold = hpInterviewPick(seed, HelperPersonnelInterviews.DISCOVERY_MIN_REALTIME_MS, HelperPersonnelInterviews.DISCOVERY_MAX_REALTIME_MS)
    applicant.personnelKnowledgeRealtimeMs = 0
    applicant.personnelKnowledgeThresholdMs = threshold
    applicant.personnelValuesDiscovered = self:isApplicantInterviewsEnabled() ~= true
end

function HelperPersonnelManager:updatePersonnelKnowledgeRuntime(dt)
    if g_server == nil then
        return false
    end
    local changed = false
    for _, worker in ipairs(self.workers or {}) do
        if worker.personnelValuesDiscovered ~= true and worker.busy == true then
            worker.personnelKnowledgeRealtimeMs = math.max(0, tonumber(worker.personnelKnowledgeRealtimeMs) or 0) + math.max(0, tonumber(dt) or 0)
            local threshold = math.max(HelperPersonnelInterviews.DISCOVERY_MIN_REALTIME_MS, tonumber(worker.personnelKnowledgeThresholdMs) or HelperPersonnelInterviews.DISCOVERY_MAX_REALTIME_MS)
            if worker.personnelKnowledgeRealtimeMs >= threshold then
                worker.personnelValuesDiscovered = true
                changed = true
            end
        end
    end
    if changed then
        self:touch(nil)
    end
    return changed
end

function HelperPersonnelManager:copyApplicantInterviewForNetwork(applicant, copy)
    self:normalizeApplicantInterviewData(applicant)
    copy.interviewSeed = applicant.interviewSeed
    copy.interviewInitialTopic = applicant.interviewInitialTopic
    copy.interviewQuestionsUsed = applicant.interviewQuestionsUsed
    copy.interviewExperienceLevel = applicant.interviewExperienceLevel
    copy.interviewReliabilityLevel = applicant.interviewReliabilityLevel
    copy.interviewLoyaltyLevel = applicant.interviewLoyaltyLevel
    copy.interviewCompleted = applicant.interviewCompleted == true
    copy.interviewHistory = {}
    for _, entry in ipairs(applicant.interviewHistory or {}) do
        table.insert(copy.interviewHistory, {topic = entry.topic, level = entry.level, variant = entry.variant, band = entry.band})
    end
    if self:isApplicantInterviewsEnabled() then
        copy.experience = -1
        copy.reliability = -1
        copy.loyalty = -1
        copy.wage = applicant.interviewCompleted == true and applicant.wage or -1
        copy.baseWage = applicant.interviewCompleted == true and applicant.baseWage or -1
        for _, topic in ipairs(HelperPersonnelInterviews.TOPICS) do
            local level, minimum, maximum = self:getApplicantInterviewKnowledge(applicant, topic)
            copy[topic .. "KnowledgeLevel"] = level
            copy[topic .. "KnowledgeMin"] = minimum
            copy[topic .. "KnowledgeMax"] = maximum
        end
    end
    return copy
end

function HelperPersonnelManager:relinkGlobalApplicants()
    local canonical = self.globalApplicants or {}
    for _, farmId in ipairs(self:getSortedFarmIds()) do
        local data = self.farms ~= nil and self.farms[farmId] or nil
        if data ~= nil then
            data.applicants = data.applicants or {}
            for index, applicant in ipairs(data.applicants) do
                local applicantId = tonumber(applicant.id)
                if applicantId ~= nil then
                    if canonical[applicantId] == nil then
                        canonical[applicantId] = applicant
                        self:normalizeApplicantInterviewData(applicant)
                    end
                end
            end
        end
    end
    self.globalApplicants = canonical
    return canonical
end

function HelperPersonnelManager:farmHasGlobalApplicant(data, applicantId)
    for _, applicant in ipairs(data ~= nil and data.applicants or {}) do
        if tonumber(applicant.id) == tonumber(applicantId) then
            return true
        end
    end
    return false
end

function HelperPersonnelManager:getApplicantOfferChanceForFarm(data)
    local reputation = self:clampEmployerReputation(data ~= nil and data.employerReputation or 50)
    return 0.15 + reputation / 100 * 0.70
end

function HelperPersonnelManager:createFarmApplicantOffer(applicant)
    local offer = hpInterviewCopy(applicant)
    offer.interviewQuestionsUsed = 0
    offer.interviewExperienceLevel = 0
    offer.interviewReliabilityLevel = 0
    offer.interviewLoyaltyLevel = 0
    offer.interviewCompleted = false
    offer.interviewHistory = {}
    self:normalizeApplicantInterviewData(offer)
    return offer
end

function HelperPersonnelManager:offerGlobalApplicant(applicant, requireOffer)
    local offered = 0
    local eligible = {}
    local farmIds = self.getRuntimeFarmIds ~= nil and self:getRuntimeFarmIds() or self:getSortedFarmIds()
    for _, farmId in ipairs(farmIds or {}) do
        local data = self.farms ~= nil and self.farms[farmId] or nil
        if data ~= nil then
            data.applicants = data.applicants or {}
            if #data.applicants < (HelperPersonnelManager.MAX_APPLICANTS or 6) and not self:farmHasGlobalApplicant(data, applicant.id) then
                table.insert(eligible, data)
                if math.random() < self:getApplicantOfferChanceForFarm(data) then
                    table.insert(data.applicants, self:createFarmApplicantOffer(applicant))
                    offered = offered + 1
                end
            end
        end
    end
    if offered == 0 and requireOffer == true and #eligible > 0 then
        table.sort(eligible, function(a, b)
            return (tonumber(a.employerReputation) or 0) > (tonumber(b.employerReputation) or 0)
        end)
        table.insert(eligible[1].applicants, self:createFarmApplicantOffer(applicant))
        offered = 1
    end
    return offered
end

function HelperPersonnelManager:createGlobalApplicant(preferredGender)
    local applicant = self:createRandomApplicant(preferredGender, 50)
    self:normalizeApplicantInterviewData(applicant)
    self.globalApplicants = self.globalApplicants or {}
    self.globalApplicants[applicant.id] = applicant
    return applicant
end

function HelperPersonnelManager:ensureGlobalApplicantMarketForFarmData(data)
    if g_server == nil and g_client ~= nil then
        return 0
    end
    if data == nil then
        return 0
    end
    data.workers = data.workers or {}
    data.applicants = data.applicants or {}
    if data.applicantMarketInitialized == true then
        return 0
    end
    local existing = self:relinkGlobalApplicants()
    local initialCount = math.min(HelperPersonnelManager.INITIAL_APPLICANT_COUNT or 4, HelperPersonnelManager.MAX_APPLICANTS or 6)
    if next(existing) == nil then
        local sequence = HelperPersonnelManager.INITIAL_APPLICANT_GENDER_SEQUENCE or {}
        for index = 1, initialCount do
            local gender = #sequence > 0 and sequence[((index - 1) % #sequence) + 1] or nil
            self:createGlobalApplicant(gender)
        end
    end
    local added = 0
    local candidates = {}
    for _, applicant in pairs(self.globalApplicants or {}) do
        table.insert(candidates, applicant)
    end
    table.sort(candidates, function(a, b) return (tonumber(a.id) or 0) < (tonumber(b.id) or 0) end)
    for _, applicant in ipairs(candidates) do
        if #data.applicants >= initialCount then
            break
        end
        if not self:farmHasGlobalApplicant(data, applicant.id) and math.random() < self:getApplicantOfferChanceForFarm(data) then
            table.insert(data.applicants, self:createFarmApplicantOffer(applicant))
            added = added + 1
        end
    end
    if #data.applicants == 0 and #candidates > 0 then
        table.insert(data.applicants, self:createFarmApplicantOffer(candidates[math.random(1, #candidates)]))
        added = added + 1
    end
    data.applicantMarketInitialized = true
    data.lastActionText = added > 0 and self:getApplicantMarketUpdateActionText(added, 0) or data.lastActionText
    return added
end

function HelperPersonnelManager:processGlobalApplicantPeriod(period, year)
    if g_server == nil then
        return false
    end
    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil then
        return false
    end
    if self.globalApplicantPeriod == nil then
        for _, data in pairs(self.farms or {}) do
            if data.lastApplicantPeriod ~= nil then
                self.globalApplicantPeriod = data.lastApplicantPeriod
                self.globalApplicantYear = data.lastApplicantYear
                break
            end
        end
    end
    if self.globalApplicantPeriod == nil then
        self.globalApplicantPeriod = period
        self.globalApplicantYear = year
        self:relinkGlobalApplicants()
        return false
    end
    if self.globalApplicantPeriod == period and self.globalApplicantYear == year then
        return false
    end
    self.globalApplicantPeriod = period
    self.globalApplicantYear = year
    local pool = self:relinkGlobalApplicants()
    local previousOffers = {}
    for farmId, data in pairs(self.farms or {}) do
        previousOffers[farmId] = {}
        for _, offer in ipairs(data.applicants or {}) do
            previousOffers[farmId][tonumber(offer.id)] = true
        end
    end
    local expiredIds = {}
    for applicantId, applicant in pairs(pool) do
        applicant.monthsAvailable = math.max(0, tonumber(applicant.monthsAvailable) or 0) + 1
        if applicant.monthsAvailable >= (HelperPersonnelManager.MAX_APPLICANT_AVAILABLE_MONTHS or 3) or math.random() < self:getApplicantDepartureChance(applicant, applicant.monthsAvailable) then
            expiredIds[applicantId] = true
        end
    end
    for _, data in pairs(self.farms or {}) do
        for index = #(data.applicants or {}), 1, -1 do
            local offer = data.applicants[index]
            local applicantId = tonumber(offer.id)
            if expiredIds[applicantId] then
                table.remove(data.applicants, index)
            elseif pool[applicantId] ~= nil then
                offer.monthsAvailable = pool[applicantId].monthsAvailable
            end
        end
    end
    local created = 0
    for _ = 1, (HelperPersonnelManager.MAX_MONTHLY_NEW_APPLICANTS or 3) do
        local applicant = self:createGlobalApplicant()
        if self:offerGlobalApplicant(applicant, created == 0) > 0 then
            created = created + 1
        else
            self.globalApplicants[applicant.id] = nil
        end
    end
    for farmId, data in pairs(self.farms or {}) do
        local currentOffers = {}
        local added, expired = 0, 0
        for _, offer in ipairs(data.applicants or {}) do
            local applicantId = tonumber(offer.id)
            currentOffers[applicantId] = true
            if previousOffers[farmId] ~= nil and previousOffers[farmId][applicantId] ~= true then
                added = added + 1
            end
        end
        for applicantId in pairs(previousOffers[farmId] or {}) do
            if currentOffers[applicantId] ~= true then
                expired = expired + 1
            end
        end
        data.pendingApplicantMarketAdded = added
        data.pendingApplicantMarketExpired = expired
    end
    return created > 0 or next(expiredIds) ~= nil
end

function HelperPersonnelManager:removeGlobalApplicantOffers(applicantId)
    for _, data in pairs(self.farms or {}) do
        for index = #(data.applicants or {}), 1, -1 do
            if tonumber(data.applicants[index].id) == tonumber(applicantId) then
                table.remove(data.applicants, index)
            end
        end
    end
    if self.globalApplicants ~= nil then
        self.globalApplicants[tonumber(applicantId)] = nil
    end
end

local function hpRegisterInterviewXMLPath(schema, basePath)
    schema:register(XMLValueType.INT, basePath .. "#interviewSeed", "Stabiler Bewerbungsgespraechs-Seed")
    schema:register(XMLValueType.STRING, basePath .. "#interviewInitialTopic", "Anfaenglich bekanntes Thema")
    schema:register(XMLValueType.INT, basePath .. "#interviewQuestionsUsed", "Gestellte Fragen")
    schema:register(XMLValueType.INT, basePath .. "#interviewExperienceLevel", "Wissensstand Erfahrung")
    schema:register(XMLValueType.INT, basePath .. "#interviewReliabilityLevel", "Wissensstand Zuverlaessigkeit")
    schema:register(XMLValueType.INT, basePath .. "#interviewLoyaltyLevel", "Wissensstand Loyalitaet")
    schema:register(XMLValueType.BOOL, basePath .. "#interviewCompleted", "Bewerbungsgespraech abgeschlossen")
    schema:register(XMLValueType.STRING, basePath .. ".interviewHistory.entry(?)#topic", "Fragenthema")
    schema:register(XMLValueType.INT, basePath .. ".interviewHistory.entry(?)#level", "Erreichter Wissensstand")
    schema:register(XMLValueType.INT, basePath .. ".interviewHistory.entry(?)#variant", "Antwortvariante")
    schema:register(XMLValueType.INT, basePath .. ".interviewHistory.entry(?)#band", "Antwortstufe")
    schema:register(XMLValueType.FLOAT, basePath .. "#personnelKnowledgeRealtimeMs", "Aktive Echtzeit bis zur vollstaendigen Kenntnis")
    schema:register(XMLValueType.FLOAT, basePath .. "#personnelKnowledgeThresholdMs", "Individuelle Aufdeckschwelle")
    schema:register(XMLValueType.BOOL, basePath .. "#personnelValuesDiscovered", "Personalwerte vollstaendig bekannt")
end

if HelperPersonnelManager.xmlSchema ~= nil then
    hpRegisterInterviewXMLPath(HelperPersonnelManager.xmlSchema, "helperPersonnel.workers.worker(?)")
    hpRegisterInterviewXMLPath(HelperPersonnelManager.xmlSchema, "helperPersonnel.applicants.applicant(?)")
    hpRegisterInterviewXMLPath(HelperPersonnelManager.xmlSchema, "helperPersonnel.farms.farm(?).workers.worker(?)")
    hpRegisterInterviewXMLPath(HelperPersonnelManager.xmlSchema, "helperPersonnel.farms.farm(?).applicants.applicant(?)")
end
