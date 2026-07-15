

HelperPersonnelNetwork = HelperPersonnelNetwork or {}
HelperPersonnelNetwork.STATE_VERSION = math.max(tonumber(HelperPersonnelNetwork.STATE_VERSION) or 0, 11)

local function hpSRGetText(key, fallback)
    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local text = g_i18n:getText(key)
        if text ~= nil and text ~= "" and text ~= key and string.match(text, "^Missing '") == nil then
            return text
        end
    end

    return fallback or key
end

local function hpSRRoundToNearestTen(value)
    value = tonumber(value) or 0
    return math.floor((value / 10) + 0.5) * 10
end

local function hpSRGetPeriodIndex(period, year)
    period = math.floor((tonumber(period) or 0) + 0.5)
    year = math.floor((tonumber(year) or 1) + 0.5)

    if period <= 0 then
        return nil
    end

    return ((math.max(1, year) - 1) * 12) + math.max(1, math.min(12, period))
end

local function hpSRGetPeriodDistance(fromPeriod, fromYear, toPeriod, toYear)
    local fromIndex = hpSRGetPeriodIndex(fromPeriod, fromYear)
    local toIndex = hpSRGetPeriodIndex(toPeriod, toYear)

    if fromIndex == nil or toIndex == nil then
        return nil
    end

    return toIndex - fromIndex
end

local function hpSRAddPeriods(period, year, periodsToAdd)
    local index = hpSRGetPeriodIndex(period, year)
    if index == nil then
        return 0, 0
    end

    index = math.max(1, index + math.floor((tonumber(periodsToAdd) or 0) + 0.5))
    local newYear = math.floor((index - 1) / 12) + 1
    local newPeriod = ((index - 1) % 12) + 1
    return newPeriod, newYear
end

if HelperPersonnelManager ~= nil then
    HelperPersonnelManager.SALARY_RAISE_STAGE_SPECIALIST = 2
    HelperPersonnelManager.SALARY_RAISE_STAGE_EXPERT = 3
    HelperPersonnelManager.SALARY_RAISE_BASE_CHANCE = 0.70
    HelperPersonnelManager.SALARY_RAISE_LOYALTY_SPREAD = 0.15
    HelperPersonnelManager.SALARY_RAISE_CHANCE_MIN = 0.55
    HelperPersonnelManager.SALARY_RAISE_CHANCE_MAX = 0.85
    HelperPersonnelManager.SALARY_RAISE_SPECIALIST_MIN_INCREASE = 180
    HelperPersonnelManager.SALARY_RAISE_EXPERT_MIN_INCREASE = 260
    HelperPersonnelManager.SALARY_RAISE_SPECIALIST_PERCENT = 1.08
    HelperPersonnelManager.SALARY_RAISE_SPECIALIST_PERCENT_MAX = 1.12
    HelperPersonnelManager.SALARY_RAISE_EXPERT_PERCENT = 1.10
    HelperPersonnelManager.SALARY_RAISE_EXPERT_PERCENT_MAX = 1.15
    HelperPersonnelManager.SALARY_RAISE_ACCEPT_LOYALTY_DELTA = 3
    HelperPersonnelManager.SALARY_RAISE_ACCEPT_REPUTATION_DELTA = 1
    HelperPersonnelManager.SALARY_RAISE_DECLINE_LOYALTY_DELTA = -5
    HelperPersonnelManager.SALARY_RAISE_DECLINE_LOW_LOYALTY_DELTA = -7
    HelperPersonnelManager.SALARY_RAISE_DECLINE_LOW_LOYALTY_THRESHOLD = 40
    HelperPersonnelManager.SALARY_RAISE_DECLINE_EFFECT_MONTHS = 3
    HelperPersonnelManager.SALARY_RAISE_DECLINE_RESIGNATION_BONUS = 0.05
    HelperPersonnelManager.SALARY_RAISE_PENDING_GRACE_PERIODS = 1
    HelperPersonnelManager.SALARY_RAISE_PENDING_MONTHLY_LOYALTY_DELTA = -2
    HelperPersonnelManager.SALARY_RAISE_FOLLOWUP_CHANCE_FACTOR = 0.50

    local function hpSRRegisterPersonXMLPaths(path)
        if HelperPersonnelManager.xmlSchema == nil or XMLValueType == nil or path == nil then
            return
        end

        HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, path .. "#salaryRaisePending", "Offene Gehaltsforderung", false)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, path .. "#salaryRaiseTargetBaseWage", "Gefordertes Grundgehalt", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, path .. "#salaryRaisePreviousBaseWage", "Vorheriges Grundgehalt bei Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseStage", "Einstufung der Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaisePeriod", "Monat der Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseYear", "Jahr der Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, path .. "#salaryRaiseFollowupPending", "Monatliche Nachpruefung fuer Gehaltsforderung", false)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, path .. "#salaryRaiseFollowupPreviousBaseWage", "Vorheriges Grundgehalt fuer spaetere Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseFollowupStage", "Einstufung fuer spaetere Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseFollowupLastCheckPeriod", "Letzter Monat der Gehaltsforderungs-Nachpruefung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseFollowupLastCheckYear", "Letztes Jahr der Gehaltsforderungs-Nachpruefung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaisePendingPenaltyPeriod", "Letzter Monat mit Loyalitaetsabzug fuer offene Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaisePendingPenaltyYear", "Letztes Jahr mit Loyalitaetsabzug fuer offene Gehaltsforderung", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseDeclinedUntilPeriod", "Monat bis zu dem eine abgelehnte Gehaltsforderung nachwirkt", 0)
        HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, path .. "#salaryRaiseDeclinedUntilYear", "Jahr bis zu dem eine abgelehnte Gehaltsforderung nachwirkt", 0)
    end

    hpSRRegisterPersonXMLPaths("helperPersonnel.workers.worker(?)")
    hpSRRegisterPersonXMLPaths("helperPersonnel.farms.farm(?).workers.worker(?)")

    function HelperPersonnelManager:getExperienceStage(experience)
        experience = self:clampPersonStat(tonumber(experience) or 0)
        if experience >= 75 then
            return HelperPersonnelManager.SALARY_RAISE_STAGE_EXPERT
        elseif experience >= 45 then
            return HelperPersonnelManager.SALARY_RAISE_STAGE_SPECIALIST
        end

        return 1
    end

    function HelperPersonnelManager:getSalaryRaiseStageText(stage)
        stage = tonumber(stage) or 1
        if stage >= HelperPersonnelManager.SALARY_RAISE_STAGE_EXPERT then
            return hpSRGetText("ui_rank_expert", "Profi")
        elseif stage >= HelperPersonnelManager.SALARY_RAISE_STAGE_SPECIALIST then
            return hpSRGetText("ui_rank_specialist", "Fachkraft")
        end

        return hpSRGetText("ui_rank_helper", "Helfer")
    end

    function HelperPersonnelManager:canCreateSalaryRaiseRequest(worker)
        if type(worker) ~= "table" then
            return false
        end

        if worker.salaryRaisePending == true then
            return false
        end

        if self.useIndividualWages ~= nil and self:useIndividualWages() ~= true then
            return false
        end

        return true
    end

    function HelperPersonnelManager:getSalaryRaiseRequestChance(worker, newStage, isFollowupCheck)
        local loyalty = self:clampPersonStat(type(worker) == "table" and (worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY) or HelperPersonnelManager.DEFAULT_LOYALTY)
        local chance = (HelperPersonnelManager.SALARY_RAISE_BASE_CHANCE or 0.70) - (((loyalty - 50) / 50) * (HelperPersonnelManager.SALARY_RAISE_LOYALTY_SPREAD or 0.15))
        chance = math.max(HelperPersonnelManager.SALARY_RAISE_CHANCE_MIN or 0.55, math.min(HelperPersonnelManager.SALARY_RAISE_CHANCE_MAX or 0.85, chance))

        if isFollowupCheck == true then
            chance = chance * (HelperPersonnelManager.SALARY_RAISE_FOLLOWUP_CHANCE_FACTOR or 0.50)
        end

        return math.max(0.01, math.min(0.95, chance))
    end

    function HelperPersonnelManager:getSalaryRaisePreviousBaseWage(worker, previousExperience)
        if type(worker) ~= "table" then
            return 0
        end

        local previousBaseWage = tonumber(worker.baseWage)
        if previousBaseWage == nil or previousBaseWage <= 0 then
            previousBaseWage = self.calculateBaseSalaryForStats ~= nil and self:calculateBaseSalaryForStats(previousExperience or worker.experience or 0, worker.reliability or 0) or tonumber(worker.wage) or 0
        end

        return math.max(0, tonumber(previousBaseWage) or 0)
    end

    function HelperPersonnelManager:clearSalaryRaiseFollowup(worker)
        if type(worker) ~= "table" then
            return
        end

        worker.salaryRaiseFollowupPending = false
        worker.salaryRaiseFollowupPreviousBaseWage = 0
        worker.salaryRaiseFollowupStage = 0
        worker.salaryRaiseFollowupLastCheckPeriod = 0
        worker.salaryRaiseFollowupLastCheckYear = 0
    end

    function HelperPersonnelManager:markSalaryRaiseFollowup(worker, stage, previousBaseWage, period, year)
        if not self:canCreateSalaryRaiseRequest(worker) then
            return false
        end

        stage = math.floor((tonumber(stage) or 0) + 0.5)
        if stage <= 1 then
            return false
        end

        if self.getApplicantPeriodInfo ~= nil and (period == nil or year == nil) then
            period, year = self:getApplicantPeriodInfo(period, year)
        end

        worker.salaryRaiseFollowupPending = true
        worker.salaryRaiseFollowupPreviousBaseWage = math.max(0, tonumber(previousBaseWage) or tonumber(worker.baseWage) or 0)
        worker.salaryRaiseFollowupStage = stage
        worker.salaryRaiseFollowupLastCheckPeriod = math.max(0, math.floor((tonumber(period) or 0) + 0.5))
        worker.salaryRaiseFollowupLastCheckYear = math.max(0, math.floor((tonumber(year) or 0) + 0.5))
        return true
    end

    function HelperPersonnelManager:calculateSalaryRaiseTargetBaseWage(worker, newStage)
        if type(worker) ~= "table" then
            return 0
        end

        local currentBaseWage = tonumber(worker.baseWage)
        if currentBaseWage == nil or currentBaseWage <= 0 then
            currentBaseWage = self.calculateBaseSalaryForStats ~= nil and self:calculateBaseSalaryForStats(worker.experience or 0, worker.reliability or 0) or tonumber(worker.wage) or 0
        end

        local calculatedBaseWage = self.calculateBaseSalaryForStats ~= nil and self:calculateBaseSalaryForStats(worker.experience or 0, worker.reliability or 0) or currentBaseWage
        local minIncrease = HelperPersonnelManager.SALARY_RAISE_SPECIALIST_MIN_INCREASE or 180
        local percentFactorMin = HelperPersonnelManager.SALARY_RAISE_SPECIALIST_PERCENT or 1.08
        local percentFactorMax = HelperPersonnelManager.SALARY_RAISE_SPECIALIST_PERCENT_MAX or percentFactorMin

        if (tonumber(newStage) or 0) >= HelperPersonnelManager.SALARY_RAISE_STAGE_EXPERT then
            minIncrease = HelperPersonnelManager.SALARY_RAISE_EXPERT_MIN_INCREASE or 260
            percentFactorMin = HelperPersonnelManager.SALARY_RAISE_EXPERT_PERCENT or 1.10
            percentFactorMax = HelperPersonnelManager.SALARY_RAISE_EXPERT_PERCENT_MAX or percentFactorMin
        end

        local loyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
        local pressure = (100 - loyalty) / 100
        local percentFactor = percentFactorMin + ((math.max(percentFactorMin, percentFactorMax) - percentFactorMin) * pressure)

        local targetBaseWage = math.max(calculatedBaseWage or 0, currentBaseWage + minIncrease, currentBaseWage * percentFactor)
        return hpSRRoundToNearestTen(targetBaseWage)
    end

    function HelperPersonnelManager:getMonthlyWageTextFromBase(baseWage)
        local monthlyWage = self.calculateCurrentMonthlyWageFromBase ~= nil and self:calculateCurrentMonthlyWageFromBase(baseWage or 0) or (baseWage or 0)
        if self.formatMoneyForText ~= nil then
            return self:formatMoneyForText(monthlyWage)
        end

        return string.format("%d €", math.floor((tonumber(monthlyWage) or 0) + 0.5))
    end

    function HelperPersonnelManager:getSalaryRaiseLine(worker)
        if type(worker) ~= "table" or worker.salaryRaisePending ~= true then
            return nil
        end

        local targetText = self:getMonthlyWageTextFromBase(worker.salaryRaiseTargetBaseWage or worker.baseWage or 0)
        local currentText = self:getMonthlyWageTextFromBase(worker.salaryRaisePreviousBaseWage or worker.baseWage or 0)
        local template = hpSRGetText("ui_salaryRaisePendingLine", "Forderung: %s statt %s")
        return string.format(template, targetText, currentText)
    end

    function HelperPersonnelManager:showSalaryRaiseRequestNotification(worker)
        if type(worker) ~= "table" then
            return
        end

        local fullName = self:getFullName(worker)
        local stageText = self:getSalaryRaiseStageText(worker.salaryRaiseStage or self:getExperienceStage(worker.experience or 0))
        local targetText = self:getMonthlyWageTextFromBase(worker.salaryRaiseTargetBaseWage or worker.baseWage or 0)
        local template = hpSRGetText("ui_salaryRaiseRequestNotification", "%s fordert nach dem Aufstieg zur Einstufung %s eine Gehaltserhöhung auf %s.")
        self:showIngameNotification(string.format(template, fullName, stageText, targetText), self:getInfoNotificationType())
    end

    function HelperPersonnelManager:activateSalaryRaiseRequestForStage(worker, newStage, previousBaseWage, isFollowupCheck)
        if not self:canCreateSalaryRaiseRequest(worker) then
            return false, "notAllowed"
        end

        newStage = math.floor((tonumber(newStage) or 0) + 0.5)
        if newStage <= 1 then
            return false, "stage"
        end

        previousBaseWage = math.max(0, tonumber(previousBaseWage) or tonumber(worker.baseWage) or tonumber(worker.wage) or 0)
        local targetBaseWage = self:calculateSalaryRaiseTargetBaseWage(worker, newStage)
        if targetBaseWage <= previousBaseWage then
            self:clearSalaryRaiseFollowup(worker)
            return false, "wage"
        end

        local chance = self:getSalaryRaiseRequestChance(worker, newStage, isFollowupCheck == true)
        if math.random() >= chance then
            return false, "chance"
        end

        local period, year = nil, nil
        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo()
        end

        worker.salaryRaisePending = true
        worker.salaryRaisePreviousBaseWage = previousBaseWage
        worker.salaryRaiseTargetBaseWage = targetBaseWage
        worker.salaryRaiseStage = newStage
        worker.salaryRaisePeriod = tonumber(period) or 0
        worker.salaryRaiseYear = tonumber(year) or 0
        worker.salaryRaisePendingPenaltyPeriod = 0
        worker.salaryRaisePendingPenaltyYear = 0
        self:clearSalaryRaiseFollowup(worker)

        local fullName = self:getFullName(worker)
        local targetText = self:getMonthlyWageTextFromBase(targetBaseWage)
        local historyTemplate = hpSRGetText("ui_salaryRaiseRequestHistory", "Gehaltsforderung: %s fordert %s.")
        if self.addActionHistoryEntry ~= nil then
            self:addActionHistoryEntry(string.format(historyTemplate, fullName, targetText))
        end

        self.changeCounter = (self.changeCounter or 0) + 1
        if type(self.notifyDataChanged) == "function" then
            self:notifyDataChanged()
        end

        self:showSalaryRaiseRequestNotification(worker)
        if self.addPersonChronicleEntry ~= nil then
            self:addPersonChronicleEntry(worker, HelperPersonnelManager.CHRONICLE_EVENT_SALARY_REQUEST, {
                reason = isFollowupCheck == true and "followup" or "experienceStage",
                valueName = "baseWage",
                oldValue = tonumber(worker.salaryRaisePreviousBaseWage) or tonumber(previousBaseWage) or 0,
                newValue = tonumber(worker.salaryRaiseTargetBaseWage) or 0,
                delta = (tonumber(worker.salaryRaiseTargetBaseWage) or 0) - (tonumber(worker.salaryRaisePreviousBaseWage) or tonumber(previousBaseWage) or 0),
                amount = tonumber(worker.salaryRaiseTargetBaseWage) or 0,
                text = hpSRGetText("ui_pmChronicleSalaryRequest", "Gehaltsforderung gestellt.")
            })
        end
        return true
    end

    function HelperPersonnelManager:createSalaryRaiseRequest(worker, previousExperience, newExperience)
        if not self:canCreateSalaryRaiseRequest(worker) then
            return false
        end

        local previousStage = self:getExperienceStage(previousExperience or worker.experience or 0)
        local newStage = self:getExperienceStage(newExperience or worker.experience or previousExperience or 0)

        if newStage <= previousStage then
            return false
        end

        local previousBaseWage = self:getSalaryRaisePreviousBaseWage(worker, previousExperience or worker.experience or 0)
        local created, reason = self:activateSalaryRaiseRequestForStage(worker, newStage, previousBaseWage, false)
        if created == true then
            return true
        end

        if reason == "chance" then
            self:markSalaryRaiseFollowup(worker, newStage, previousBaseWage)
        end

        return false
    end

    function HelperPersonnelManager:processMonthlySalaryRaiseFollowupChecks(period, year)
        if self.useIndividualWages ~= nil and self:useIndividualWages() ~= true then
            return 0
        end

        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo(period, year)
        end
        if period == nil then
            return 0
        end

        local createdCount = 0
        local touchedOnly = false

        for _, worker in ipairs(self.workers or {}) do
            if type(worker) == "table" then
                self:normalizePersonRuntimeData(worker)
                if worker.salaryRaisePending ~= true and worker.salaryRaiseFollowupPending == true then
                    local stage = math.floor((tonumber(worker.salaryRaiseFollowupStage) or 0) + 0.5)
                    local currentStage = self:getExperienceStage(worker.experience or 0)

                    if stage <= 1 or currentStage < stage then
                        self:clearSalaryRaiseFollowup(worker)
                        touchedOnly = true
                    else
                        local lastPeriod = math.floor((tonumber(worker.salaryRaiseFollowupLastCheckPeriod) or 0) + 0.5)
                        local lastYear = math.floor((tonumber(worker.salaryRaiseFollowupLastCheckYear) or 0) + 0.5)

                        if lastPeriod ~= period or lastYear ~= year then
                            worker.salaryRaiseFollowupLastCheckPeriod = period
                            worker.salaryRaiseFollowupLastCheckYear = year
                            touchedOnly = true

                            local previousBaseWage = math.max(0, tonumber(worker.salaryRaiseFollowupPreviousBaseWage) or tonumber(worker.baseWage) or 0)
                            local created = self:activateSalaryRaiseRequestForStage(worker, stage, previousBaseWage, true)
                            if created == true then
                                createdCount = createdCount + 1
                            end
                        end
                    end
                end
            end
        end

        if touchedOnly == true and createdCount <= 0 then
            self.changeCounter = (self.changeCounter or 0) + 1
        end

        return createdCount
    end

    function HelperPersonnelManager:clearSalaryRaiseRequest(worker)
        if type(worker) ~= "table" then
            return
        end

        worker.salaryRaisePending = false
        worker.salaryRaiseTargetBaseWage = 0
        worker.salaryRaisePreviousBaseWage = 0
        worker.salaryRaiseStage = 0
        worker.salaryRaisePeriod = 0
        worker.salaryRaiseYear = 0
        worker.salaryRaisePendingPenaltyPeriod = 0
        worker.salaryRaisePendingPenaltyYear = 0
        self:clearSalaryRaiseFollowup(worker)
    end

    function HelperPersonnelManager:clearSalaryRaiseDeclineAftereffect(worker)
        if type(worker) ~= "table" then
            return
        end

        worker.salaryRaiseDeclinedUntilPeriod = 0
        worker.salaryRaiseDeclinedUntilYear = 0
    end

    function HelperPersonnelManager:markSalaryRaiseDeclineAftereffect(worker, period, year)
        if type(worker) ~= "table" then
            return false
        end

        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo(period, year)
        end
        if period == nil then
            return false
        end

        local months = math.max(1, math.floor((HelperPersonnelManager.SALARY_RAISE_DECLINE_EFFECT_MONTHS or 3) + 0.5))
        local untilPeriod, untilYear = hpSRAddPeriods(period, year, months - 1)
        worker.salaryRaiseDeclinedUntilPeriod = untilPeriod
        worker.salaryRaiseDeclinedUntilYear = untilYear
        return true
    end

    function HelperPersonnelManager:isSalaryRaiseDeclineAftereffectActive(worker, period, year)
        if type(worker) ~= "table" then
            return false
        end

        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo(period, year)
        end
        local currentIndex = hpSRGetPeriodIndex(period, year)
        local untilIndex = hpSRGetPeriodIndex(worker.salaryRaiseDeclinedUntilPeriod, worker.salaryRaiseDeclinedUntilYear)
        return currentIndex ~= nil and untilIndex ~= nil and untilIndex >= currentIndex
    end

    function HelperPersonnelManager:getOpenSalaryRaiseRequestPeriodDistance(worker, period, year)
        if type(worker) ~= "table" or worker.salaryRaisePending ~= true then
            return nil
        end

        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo(period, year)
        end

        return hpSRGetPeriodDistance(worker.salaryRaisePeriod, worker.salaryRaiseYear, period, year)
    end

    function HelperPersonnelManager:applyOpenSalaryRaiseRequestPenalty(worker, period, year)
        if type(worker) ~= "table" or worker.salaryRaisePending ~= true then
            return false
        end

        if not (self.isPersonnelEffectEnabled == nil or self:isPersonnelEffectEnabled("loyalty")) then
            return false
        end

        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo(period, year)
        end
        if period == nil then
            return false
        end

        local distance = self:getOpenSalaryRaiseRequestPeriodDistance(worker, period, year)
        if distance == nil or distance < (HelperPersonnelManager.SALARY_RAISE_PENDING_GRACE_PERIODS or 1) then
            return false
        end

        if tonumber(worker.salaryRaisePendingPenaltyPeriod) == tonumber(period) and tonumber(worker.salaryRaisePendingPenaltyYear) == tonumber(year) then
            return false
        end

        worker.salaryRaisePendingPenaltyPeriod = period
        worker.salaryRaisePendingPenaltyYear = year

        local delta = HelperPersonnelManager.SALARY_RAISE_PENDING_MONTHLY_LOYALTY_DELTA or -2
        local oldLoyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
        local newLoyalty = self:clampPersonStat(oldLoyalty + delta)
        local appliedDelta = newLoyalty - oldLoyalty

        if appliedDelta ~= 0 then
            worker.loyalty = newLoyalty
            self:showLoyaltyChangeNotification(worker, appliedDelta, oldLoyalty, newLoyalty)

            local template = hpSRGetText("ui_salaryRaisePendingPenalty", "Offene Gehaltsforderung von %s belastet die Loyalitaet: %s.")
            self:touch(string.format(template, self:getFullName(worker), self:formatSignedDelta(appliedDelta)))
            if self.addPersonChronicleEntry ~= nil then
                self:addPersonChronicleEntry(worker, HelperPersonnelManager.CHRONICLE_EVENT_LOYALTY_CHANGED, {
                    period = period,
                    gameYear = year,
                    reason = "openSalaryRequest",
                    valueName = "loyalty",
                    oldValue = oldLoyalty,
                    newValue = newLoyalty,
                    delta = appliedDelta
                })
            end
        else
            self.changeCounter = (self.changeCounter or 0) + 1
        end

        return true
    end

    function HelperPersonnelManager:processOpenSalaryRaiseRequestPenalties(period, year)
        local count = 0

        for _, worker in ipairs(self.workers or {}) do
            self:normalizePersonRuntimeData(worker)
            if self:applyOpenSalaryRaiseRequestPenalty(worker, period, year) then
                count = count + 1
            end
        end

        return count
    end

    function HelperPersonnelManager:grantSalaryRaise(workerId)
        local worker = self:getWorkerById(workerId)
        if type(worker) ~= "table" or worker.salaryRaisePending ~= true then
            return false
        end

        local oldWage = tonumber(worker.baseWage)
        local oldLoyalty = tonumber(worker.loyalty)
        local targetBaseWage = math.max(tonumber(worker.salaryRaiseTargetBaseWage) or 0, tonumber(worker.baseWage) or 0)
        if targetBaseWage <= 0 then
            targetBaseWage = self:calculateSalaryRaiseTargetBaseWage(worker, worker.salaryRaiseStage or self:getExperienceStage(worker.experience or 0))
        end

        worker.baseWage = targetBaseWage
        self:getCurrentMonthlyWage(worker)

        if self.isPersonnelEffectEnabled == nil or self:isPersonnelEffectEnabled("loyalty") then
            worker.loyalty = self:clampPersonStat((worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY) + (HelperPersonnelManager.SALARY_RAISE_ACCEPT_LOYALTY_DELTA or 3))
        end

        if self.adjustEmployerReputation ~= nil then
            local reputationDelta = HelperPersonnelManager.SALARY_RAISE_ACCEPT_REPUTATION_DELTA or 1
            local reputationTemplate = hpSRGetText("ui_salaryRaiseGrantedReputation", "Faire Gehaltserhoehung: %s Ansehen")
            self:adjustEmployerReputation(reputationDelta, string.format(reputationTemplate, self:formatSignedDelta(reputationDelta)))
        end

        local fullName = self:getFullName(worker)
        local targetText = self:getMonthlyWageTextFromBase(targetBaseWage)
        self:clearSalaryRaiseRequest(worker)
        self:clearSalaryRaiseDeclineAftereffect(worker)

        local template = hpSRGetText("ui_salaryRaiseGranted", "Gehaltserhöhung für %s gewährt: %s.")
        self:touch(string.format(template, fullName, targetText))
        if self.addPersonChronicleEntry ~= nil then
            local newWage = tonumber(worker.baseWage) or oldWage or 0
            self:addPersonChronicleEntry(worker, HelperPersonnelManager.CHRONICLE_EVENT_SALARY_CHANGED, {
                reason = "salaryRaiseGranted",
                valueName = "baseWage",
                oldValue = oldWage,
                newValue = newWage,
                delta = oldWage ~= nil and newWage - oldWage or nil,
                amount = newWage,
                text = hpSRGetText("ui_pmChronicleSalaryGranted", "Gehaltserhöhung gewährt.")
            })
            if oldLoyalty ~= nil and tonumber(worker.loyalty) ~= oldLoyalty then
                self:addPersonChronicleEntry(worker, HelperPersonnelManager.CHRONICLE_EVENT_LOYALTY_CHANGED, {
                    reason = "salaryRaiseGranted",
                    valueName = "loyalty",
                    oldValue = oldLoyalty,
                    newValue = tonumber(worker.loyalty),
                    delta = tonumber(worker.loyalty) - oldLoyalty
                })
            end
        end
        return true
    end

    function HelperPersonnelManager:declineSalaryRaise(workerId)
        local worker = self:getWorkerById(workerId)
        if type(worker) ~= "table" or worker.salaryRaisePending ~= true then
            return false
        end

        local oldLoyalty = tonumber(worker.loyalty)
        local targetWage = tonumber(worker.salaryRaiseTargetBaseWage)
        local loyaltyEffectsEnabled = self.isPersonnelEffectEnabled == nil or self:isPersonnelEffectEnabled("loyalty")
        if loyaltyEffectsEnabled then
            local oldLoyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
            local delta = HelperPersonnelManager.SALARY_RAISE_DECLINE_LOYALTY_DELTA or -5
            if oldLoyalty < (HelperPersonnelManager.SALARY_RAISE_DECLINE_LOW_LOYALTY_THRESHOLD or 40) then
                delta = HelperPersonnelManager.SALARY_RAISE_DECLINE_LOW_LOYALTY_DELTA or -7
            end
            worker.loyalty = self:clampPersonStat(oldLoyalty + delta)
        end

        local fullName = self:getFullName(worker)
        self:clearSalaryRaiseRequest(worker)
        if loyaltyEffectsEnabled then
            self:markSalaryRaiseDeclineAftereffect(worker)
        else
            self:clearSalaryRaiseDeclineAftereffect(worker)
        end

        local template = hpSRGetText("ui_salaryRaiseDeclined", "Gehaltsforderung von %s abgelehnt.")
        self:touch(string.format(template, fullName))
        if self.addPersonChronicleEntry ~= nil then
            self:addPersonChronicleEntry(worker, HelperPersonnelManager.CHRONICLE_EVENT_SALARY_REQUEST_DECLINED, {
                reason = "salaryRaiseDeclined",
                amount = targetWage,
                text = hpSRGetText("ui_pmChronicleSalaryDeclined", "Gehaltsforderung abgelehnt.")
            })
            if oldLoyalty ~= nil and tonumber(worker.loyalty) ~= oldLoyalty then
                self:addPersonChronicleEntry(worker, HelperPersonnelManager.CHRONICLE_EVENT_LOYALTY_CHANGED, {
                    reason = "salaryRaiseDeclined",
                    valueName = "loyalty",
                    oldValue = oldLoyalty,
                    newValue = tonumber(worker.loyalty),
                    delta = tonumber(worker.loyalty) - oldLoyalty
                })
            end
        end
        return true
    end

    function HelperPersonnelManager:grantSalaryRaiseForFarm(workerId, farmId)
        if self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return self:grantSalaryRaise(workerId)
            end, true)
        end

        return self:grantSalaryRaise(workerId)
    end

    function HelperPersonnelManager:declineSalaryRaiseForFarm(workerId, farmId)
        if self.executeWithFarmContext ~= nil then
            return self:executeWithFarmContext(farmId, function()
                return self:declineSalaryRaise(workerId)
            end, true)
        end

        return self:declineSalaryRaise(workerId)
    end

    local HP_SR_ORIGINAL_AWARD_WORKER_EXPERIENCE = HelperPersonnelManager.awardWorkerExperience
    local function hpOverride_HelperPersonnelManager_awardWorkerExperience_1(self, worker, workMinutes)
        if HP_SR_ORIGINAL_AWARD_WORKER_EXPERIENCE == nil then
            return 0, 0
        end

        local previousExperience = type(worker) == "table" and self:clampPersonStat(worker.experience or 0) or 0
        local experienceGain, monthlyLimit = HP_SR_ORIGINAL_AWARD_WORKER_EXPERIENCE(self, worker, workMinutes)
        local newExperience = type(worker) == "table" and self:clampPersonStat(worker.experience or previousExperience) or previousExperience

        if (tonumber(experienceGain) or 0) > 0 then
            self:createSalaryRaiseRequest(worker, previousExperience, newExperience)
        end

        return experienceGain, monthlyLimit
    end
    HelperPersonnelManager.awardWorkerExperience = hpOverride_HelperPersonnelManager_awardWorkerExperience_1

    local HP_SR_ORIGINAL_NORMALIZE_PERSON = HelperPersonnelManager.normalizePersonRuntimeData
    local function hpOverride_HelperPersonnelManager_normalizePersonRuntimeData_2(self, person)
        if HP_SR_ORIGINAL_NORMALIZE_PERSON ~= nil then
            HP_SR_ORIGINAL_NORMALIZE_PERSON(self, person)
        end

        if type(person) == "table" then
            person.salaryRaisePending = person.salaryRaisePending == true
            person.salaryRaiseTargetBaseWage = math.max(0, tonumber(person.salaryRaiseTargetBaseWage) or 0)
            person.salaryRaisePreviousBaseWage = math.max(0, tonumber(person.salaryRaisePreviousBaseWage) or 0)
            person.salaryRaiseStage = math.max(0, math.floor((tonumber(person.salaryRaiseStage) or 0) + 0.5))
            person.salaryRaisePeriod = math.max(0, math.floor((tonumber(person.salaryRaisePeriod) or 0) + 0.5))
            person.salaryRaiseYear = math.max(0, math.floor((tonumber(person.salaryRaiseYear) or 0) + 0.5))
            person.salaryRaiseFollowupPending = person.salaryRaiseFollowupPending == true
            person.salaryRaiseFollowupPreviousBaseWage = math.max(0, tonumber(person.salaryRaiseFollowupPreviousBaseWage) or 0)
            person.salaryRaiseFollowupStage = math.max(0, math.floor((tonumber(person.salaryRaiseFollowupStage) or 0) + 0.5))
            person.salaryRaiseFollowupLastCheckPeriod = math.max(0, math.floor((tonumber(person.salaryRaiseFollowupLastCheckPeriod) or 0) + 0.5))
            person.salaryRaiseFollowupLastCheckYear = math.max(0, math.floor((tonumber(person.salaryRaiseFollowupLastCheckYear) or 0) + 0.5))
            person.salaryRaisePendingPenaltyPeriod = math.max(0, math.floor((tonumber(person.salaryRaisePendingPenaltyPeriod) or 0) + 0.5))
            person.salaryRaisePendingPenaltyYear = math.max(0, math.floor((tonumber(person.salaryRaisePendingPenaltyYear) or 0) + 0.5))
            person.salaryRaiseDeclinedUntilPeriod = math.max(0, math.floor((tonumber(person.salaryRaiseDeclinedUntilPeriod) or 0) + 0.5))
            person.salaryRaiseDeclinedUntilYear = math.max(0, math.floor((tonumber(person.salaryRaiseDeclinedUntilYear) or 0) + 0.5))
        end

        return person
    end
    HelperPersonnelManager.normalizePersonRuntimeData = hpOverride_HelperPersonnelManager_normalizePersonRuntimeData_2

    local HP_SR_ORIGINAL_COPY_PERSON_FOR_NETWORK = HelperPersonnelManager.copyPersonForNetwork
    local function hpOverride_HelperPersonnelManager_copyPersonForNetwork_2(self, person)
        local copy = HP_SR_ORIGINAL_COPY_PERSON_FOR_NETWORK ~= nil and HP_SR_ORIGINAL_COPY_PERSON_FOR_NETWORK(self, person) or {}
        if type(person) == "table" then
            copy.salaryRaisePending = person.salaryRaisePending == true
            copy.salaryRaiseTargetBaseWage = person.salaryRaiseTargetBaseWage
            copy.salaryRaisePreviousBaseWage = person.salaryRaisePreviousBaseWage
            copy.salaryRaiseStage = person.salaryRaiseStage
            copy.salaryRaisePeriod = person.salaryRaisePeriod
            copy.salaryRaiseYear = person.salaryRaiseYear
            copy.salaryRaiseFollowupPending = person.salaryRaiseFollowupPending == true
            copy.salaryRaiseFollowupPreviousBaseWage = person.salaryRaiseFollowupPreviousBaseWage
            copy.salaryRaiseFollowupStage = person.salaryRaiseFollowupStage
            copy.salaryRaiseFollowupLastCheckPeriod = person.salaryRaiseFollowupLastCheckPeriod
            copy.salaryRaiseFollowupLastCheckYear = person.salaryRaiseFollowupLastCheckYear
            copy.salaryRaisePendingPenaltyPeriod = person.salaryRaisePendingPenaltyPeriod
            copy.salaryRaisePendingPenaltyYear = person.salaryRaisePendingPenaltyYear
            copy.salaryRaiseDeclinedUntilPeriod = person.salaryRaiseDeclinedUntilPeriod
            copy.salaryRaiseDeclinedUntilYear = person.salaryRaiseDeclinedUntilYear
        end

        return copy
    end
    HelperPersonnelManager.copyPersonForNetwork = hpOverride_HelperPersonnelManager_copyPersonForNetwork_2

    local HP_SR_ORIGINAL_READ_PERSON_FROM_XML = HelperPersonnelManager.readPersonFromXML
    local function hpOverride_HelperPersonnelManager_readPersonFromXML_2(self, xmlFile, key)
        local person = HP_SR_ORIGINAL_READ_PERSON_FROM_XML ~= nil and HP_SR_ORIGINAL_READ_PERSON_FROM_XML(self, xmlFile, key) or nil
        if person ~= nil and xmlFile ~= nil and key ~= nil then
            person.salaryRaisePending = xmlFile:getBool(key .. "#salaryRaisePending", false) == true
            person.salaryRaiseTargetBaseWage = xmlFile:getFloat(key .. "#salaryRaiseTargetBaseWage", 0)
            person.salaryRaisePreviousBaseWage = xmlFile:getFloat(key .. "#salaryRaisePreviousBaseWage", 0)
            person.salaryRaiseStage = xmlFile:getInt(key .. "#salaryRaiseStage", 0)
            person.salaryRaisePeriod = xmlFile:getInt(key .. "#salaryRaisePeriod", 0)
            person.salaryRaiseYear = xmlFile:getInt(key .. "#salaryRaiseYear", 0)
            person.salaryRaiseFollowupPending = xmlFile:getBool(key .. "#salaryRaiseFollowupPending", false) == true
            person.salaryRaiseFollowupPreviousBaseWage = xmlFile:getFloat(key .. "#salaryRaiseFollowupPreviousBaseWage", 0)
            person.salaryRaiseFollowupStage = xmlFile:getInt(key .. "#salaryRaiseFollowupStage", 0)
            person.salaryRaiseFollowupLastCheckPeriod = xmlFile:getInt(key .. "#salaryRaiseFollowupLastCheckPeriod", 0)
            person.salaryRaiseFollowupLastCheckYear = xmlFile:getInt(key .. "#salaryRaiseFollowupLastCheckYear", 0)
            person.salaryRaisePendingPenaltyPeriod = xmlFile:getInt(key .. "#salaryRaisePendingPenaltyPeriod", 0)
            person.salaryRaisePendingPenaltyYear = xmlFile:getInt(key .. "#salaryRaisePendingPenaltyYear", 0)
            person.salaryRaiseDeclinedUntilPeriod = xmlFile:getInt(key .. "#salaryRaiseDeclinedUntilPeriod", 0)
            person.salaryRaiseDeclinedUntilYear = xmlFile:getInt(key .. "#salaryRaiseDeclinedUntilYear", 0)
        end

        return person
    end
    HelperPersonnelManager.readPersonFromXML = hpOverride_HelperPersonnelManager_readPersonFromXML_2

    local HP_SR_ORIGINAL_WRITE_PERSON_TO_XML = HelperPersonnelManager.writePersonToXML
    local function hpOverride_HelperPersonnelManager_writePersonToXML_2(self, xmlFile, key, person, includeWorkerState)
        if HP_SR_ORIGINAL_WRITE_PERSON_TO_XML ~= nil then
            HP_SR_ORIGINAL_WRITE_PERSON_TO_XML(self, xmlFile, key, person, includeWorkerState)
        end

        if xmlFile == nil or person == nil or key == nil or includeWorkerState ~= true then
            return
        end

        xmlFile:setBool(key .. "#salaryRaisePending", person.salaryRaisePending == true)
        xmlFile:setFloat(key .. "#salaryRaiseTargetBaseWage", tonumber(person.salaryRaiseTargetBaseWage) or 0)
        xmlFile:setFloat(key .. "#salaryRaisePreviousBaseWage", tonumber(person.salaryRaisePreviousBaseWage) or 0)
        xmlFile:setInt(key .. "#salaryRaiseStage", tonumber(person.salaryRaiseStage) or 0)
        xmlFile:setInt(key .. "#salaryRaisePeriod", tonumber(person.salaryRaisePeriod) or 0)
        xmlFile:setInt(key .. "#salaryRaiseYear", tonumber(person.salaryRaiseYear) or 0)
        xmlFile:setBool(key .. "#salaryRaiseFollowupPending", person.salaryRaiseFollowupPending == true)
        xmlFile:setFloat(key .. "#salaryRaiseFollowupPreviousBaseWage", tonumber(person.salaryRaiseFollowupPreviousBaseWage) or 0)
        xmlFile:setInt(key .. "#salaryRaiseFollowupStage", tonumber(person.salaryRaiseFollowupStage) or 0)
        xmlFile:setInt(key .. "#salaryRaiseFollowupLastCheckPeriod", tonumber(person.salaryRaiseFollowupLastCheckPeriod) or 0)
        xmlFile:setInt(key .. "#salaryRaiseFollowupLastCheckYear", tonumber(person.salaryRaiseFollowupLastCheckYear) or 0)
        xmlFile:setInt(key .. "#salaryRaisePendingPenaltyPeriod", tonumber(person.salaryRaisePendingPenaltyPeriod) or 0)
        xmlFile:setInt(key .. "#salaryRaisePendingPenaltyYear", tonumber(person.salaryRaisePendingPenaltyYear) or 0)
        xmlFile:setInt(key .. "#salaryRaiseDeclinedUntilPeriod", tonumber(person.salaryRaiseDeclinedUntilPeriod) or 0)
        xmlFile:setInt(key .. "#salaryRaiseDeclinedUntilYear", tonumber(person.salaryRaiseDeclinedUntilYear) or 0)
    end
    HelperPersonnelManager.writePersonToXML = hpOverride_HelperPersonnelManager_writePersonToXML_2

    local HP_SR_ORIGINAL_WORKER_HIRED_LINE = HelperPersonnelManager.getWorkerHiredLine
    local function hpOverride_HelperPersonnelManager_getWorkerHiredLine_2(self, person)
        local line = HP_SR_ORIGINAL_WORKER_HIRED_LINE ~= nil and HP_SR_ORIGINAL_WORKER_HIRED_LINE(self, person) or ""
        local salaryRaiseLine = self:getSalaryRaiseLine(person)
        if salaryRaiseLine ~= nil and salaryRaiseLine ~= "" then
            if line ~= nil and line ~= "" then
                return string.format("%s | %s", line, salaryRaiseLine)
            end
            return salaryRaiseLine
        end

        return line
    end
    HelperPersonnelManager.getWorkerHiredLine = hpOverride_HelperPersonnelManager_getWorkerHiredLine_2

    local HP_SR_ORIGINAL_PROCESS_APPLICANT_PERIOD_CHANGE = HelperPersonnelManager.processApplicantPeriodChange
    local function hpOverride_HelperPersonnelManager_processApplicantPeriodChange_1(self, period, year, forceCheck)
        local changed = HP_SR_ORIGINAL_PROCESS_APPLICANT_PERIOD_CHANGE ~= nil and HP_SR_ORIGINAL_PROCESS_APPLICANT_PERIOD_CHANGE(self, period, year, forceCheck) or false

        if self.getApplicantPeriodInfo ~= nil then
            period, year = self:getApplicantPeriodInfo(period, year)
        end
        local createdCount = self:processMonthlySalaryRaiseFollowupChecks(period, year)
        local penaltyCount = self:processOpenSalaryRaiseRequestPenalties(period, year)
        return changed == true or (tonumber(createdCount) or 0) > 0 or (tonumber(penaltyCount) or 0) > 0
    end
    HelperPersonnelManager.processApplicantPeriodChange = hpOverride_HelperPersonnelManager_processApplicantPeriodChange_1

    local HP_SR_ORIGINAL_GET_LOYALTY_RESIGNATION_CHANCE = HelperPersonnelManager.getLoyaltyResignationChance
    local function hpOverride_HelperPersonnelManager_getLoyaltyResignationChance_1(self, worker)
        local chance = HP_SR_ORIGINAL_GET_LOYALTY_RESIGNATION_CHANCE ~= nil and HP_SR_ORIGINAL_GET_LOYALTY_RESIGNATION_CHANCE(self, worker) or 0

        if chance > 0 and self:isSalaryRaiseDeclineAftereffectActive(worker) then
            chance = math.min(0.45, chance + (HelperPersonnelManager.SALARY_RAISE_DECLINE_RESIGNATION_BONUS or 0.05))
        end

        return chance
    end
    HelperPersonnelManager.getLoyaltyResignationChance = hpOverride_HelperPersonnelManager_getLoyaltyResignationChance_1
end

if HelperPersonnelNetwork ~= nil then
    local HP_SR_ORIGINAL_WRITE_PERSON = HelperPersonnelNetwork.writePerson
    local function hpOverride_HelperPersonnelNetwork_writePerson_1(streamId, person)
        if HP_SR_ORIGINAL_WRITE_PERSON ~= nil then
            HP_SR_ORIGINAL_WRITE_PERSON(streamId, person)
        end

        person = person or {}
        streamWriteBool(streamId, person.salaryRaisePending == true)
        streamWriteFloat32(streamId, tonumber(person.salaryRaiseTargetBaseWage) or 0)
        streamWriteFloat32(streamId, tonumber(person.salaryRaisePreviousBaseWage) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseStage) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaisePeriod) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseYear) or 0)
        streamWriteBool(streamId, person.salaryRaiseFollowupPending == true)
        streamWriteFloat32(streamId, tonumber(person.salaryRaiseFollowupPreviousBaseWage) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseFollowupStage) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseFollowupLastCheckPeriod) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseFollowupLastCheckYear) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaisePendingPenaltyPeriod) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaisePendingPenaltyYear) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseDeclinedUntilPeriod) or 0)
        streamWriteInt32(streamId, tonumber(person.salaryRaiseDeclinedUntilYear) or 0)
        streamWriteBool(streamId, person.dismissalPending == true)
        streamWriteInt32(streamId, tonumber(person.dismissalNoticePeriod) or 0)
        streamWriteInt32(streamId, tonumber(person.dismissalNoticeYear) or 0)
        streamWriteInt32(streamId, tonumber(person.dismissalEffectivePeriod) or 0)
        streamWriteInt32(streamId, tonumber(person.dismissalEffectiveYear) or 0)
    end
    HelperPersonnelNetwork.writePerson = hpOverride_HelperPersonnelNetwork_writePerson_1

    local HP_SR_ORIGINAL_READ_PERSON = HelperPersonnelNetwork.readPerson
    local function hpOverride_HelperPersonnelNetwork_readPerson_1(streamId, version)
        local person = HP_SR_ORIGINAL_READ_PERSON ~= nil and HP_SR_ORIGINAL_READ_PERSON(streamId, version) or {}

        if (version or 0) >= 8 then
            person.salaryRaisePending = streamReadBool(streamId) == true
            person.salaryRaiseTargetBaseWage = streamReadFloat32(streamId)
            person.salaryRaisePreviousBaseWage = streamReadFloat32(streamId)
            person.salaryRaiseStage = streamReadInt32(streamId)
            person.salaryRaisePeriod = streamReadInt32(streamId)
            person.salaryRaiseYear = streamReadInt32(streamId)
            person.salaryRaiseFollowupPending = streamReadBool(streamId) == true
            person.salaryRaiseFollowupPreviousBaseWage = streamReadFloat32(streamId)
            person.salaryRaiseFollowupStage = streamReadInt32(streamId)
            person.salaryRaiseFollowupLastCheckPeriod = streamReadInt32(streamId)
            person.salaryRaiseFollowupLastCheckYear = streamReadInt32(streamId)
            if (version or 0) >= 9 then
                person.salaryRaisePendingPenaltyPeriod = streamReadInt32(streamId)
                person.salaryRaisePendingPenaltyYear = streamReadInt32(streamId)
                person.salaryRaiseDeclinedUntilPeriod = streamReadInt32(streamId)
                person.salaryRaiseDeclinedUntilYear = streamReadInt32(streamId)
            else
                person.salaryRaisePendingPenaltyPeriod = 0
                person.salaryRaisePendingPenaltyYear = 0
                person.salaryRaiseDeclinedUntilPeriod = 0
                person.salaryRaiseDeclinedUntilYear = 0
            end
        else
            person.salaryRaisePending = false
            person.salaryRaiseTargetBaseWage = 0
            person.salaryRaisePreviousBaseWage = 0
            person.salaryRaiseStage = 0
            person.salaryRaisePeriod = 0
            person.salaryRaiseYear = 0
            person.salaryRaiseFollowupPending = false
            person.salaryRaiseFollowupPreviousBaseWage = 0
            person.salaryRaiseFollowupStage = 0
            person.salaryRaiseFollowupLastCheckPeriod = 0
            person.salaryRaiseFollowupLastCheckYear = 0
            person.salaryRaisePendingPenaltyPeriod = 0
            person.salaryRaisePendingPenaltyYear = 0
            person.salaryRaiseDeclinedUntilPeriod = 0
            person.salaryRaiseDeclinedUntilYear = 0
        end

        if (version or 0) >= 10 then
            person.dismissalPending = streamReadBool(streamId) == true
            person.dismissalNoticePeriod = streamReadInt32(streamId) or 0
            person.dismissalNoticeYear = streamReadInt32(streamId) or 0
            if (version or 0) >= 11 then
                person.dismissalEffectivePeriod = streamReadInt32(streamId) or 0
                person.dismissalEffectiveYear = streamReadInt32(streamId) or 0
            else
                person.dismissalEffectivePeriod = 0
                person.dismissalEffectiveYear = 0
            end
        else
            person.dismissalPending = person.dismissalPending == true
            person.dismissalNoticePeriod = tonumber(person.dismissalNoticePeriod) or 0
            person.dismissalNoticeYear = tonumber(person.dismissalNoticeYear) or 0
            person.dismissalEffectivePeriod = tonumber(person.dismissalEffectivePeriod) or 0
            person.dismissalEffectiveYear = tonumber(person.dismissalEffectiveYear) or 0
        end

        return person
    end
    HelperPersonnelNetwork.readPerson = hpOverride_HelperPersonnelNetwork_readPerson_1
end

if HelperPersonnelApp ~= nil then
    function HelperPersonnelApp:requestGrantSalaryRaise(workerId)
        if workerId == nil or self.manager == nil then
            return false
        end

        local farmId = self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1
        local changed = false

        if self.isServerAuthority ~= nil and self:isServerAuthority() then
            changed = self.manager.grantSalaryRaiseForFarm ~= nil and self.manager:grantSalaryRaiseForFarm(workerId, farmId) == true
            if changed and self.syncNetworkStateToClients ~= nil then
                self:syncNetworkStateToClients()
            end
        elseif g_client ~= nil and g_client.getServerConnection ~= nil and HelperPersonnelNetworkActionEvent ~= nil and HelperPersonnelNetworkActionEvent.new ~= nil then
            g_client:getServerConnection():sendEvent(HelperPersonnelNetworkActionEvent.new(HelperPersonnelNetwork.ACTION_GRANT_SALARY_RAISE, workerId, self.manager.changeCounter or 0, farmId))
            changed = true
        end

        return changed
    end

    function HelperPersonnelApp:requestDeclineSalaryRaise(workerId)
        if workerId == nil or self.manager == nil then
            return false
        end

        local farmId = self.getCurrentFarmId ~= nil and self:getCurrentFarmId() or 1
        local changed = false

        if self.isServerAuthority ~= nil and self:isServerAuthority() then
            changed = self.manager.declineSalaryRaiseForFarm ~= nil and self.manager:declineSalaryRaiseForFarm(workerId, farmId) == true
            if changed and self.syncNetworkStateToClients ~= nil then
                self:syncNetworkStateToClients()
            end
        elseif g_client ~= nil and g_client.getServerConnection ~= nil and HelperPersonnelNetworkActionEvent ~= nil and HelperPersonnelNetworkActionEvent.new ~= nil then
            g_client:getServerConnection():sendEvent(HelperPersonnelNetworkActionEvent.new(HelperPersonnelNetwork.ACTION_DECLINE_SALARY_RAISE, workerId, self.manager.changeCounter or 0, farmId))
            changed = true
        end

        return changed
    end

end
