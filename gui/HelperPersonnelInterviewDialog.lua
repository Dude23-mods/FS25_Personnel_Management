HelperPersonnelInterviewDialog = {}
local HelperPersonnelInterviewDialog_mt = Class(HelperPersonnelInterviewDialog, DialogElement)

local HP_INTERVIEW_TOPICS = {"experience", "reliability", "loyalty"}

local function hpInterviewUtf8Characters(text)
    local characters = {}
    for character in string.gmatch(tostring(text or ""), "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(characters, character)
    end
    return characters
end

function HelperPersonnelInterviewDialog.new(target)
    local self = DialogElement.new(target, HelperPersonnelInterviewDialog_mt)
    self.lastChangeCounter = -1
    self.typewriterQueue = {}
    self.typewriterText = nil
    self.typewriterVisible = 0
    return self
end

function HelperPersonnelInterviewDialog:setContext(page, applicantId)
    self.page = page
    self.applicantId = tonumber(applicantId)
end

function HelperPersonnelInterviewDialog:getText(key, fallback)
    if self.page ~= nil and self.page.getText ~= nil then
        return self.page:getText(key, fallback)
    end
    return fallback or key
end

function HelperPersonnelInterviewDialog:getApplicant()
    if self.page == nil then
        return nil
    end
    for _, applicant in ipairs(self.page:getApplicants() or {}) do
        if tonumber(applicant.id) == self.applicantId then
            return applicant
        end
    end
    return nil
end

function HelperPersonnelInterviewDialog:onOpen()
    HelperPersonnelInterviewDialog:superClass().onOpen(self)
    local applicant = self:getApplicant()
    self.lastHistoryCount = applicant ~= nil and #(applicant.interviewHistory or {}) or 0
    self.lastChangeCounter = -1
    self.typewriterQueue = {}
    self.typewriterTarget = nil
    self.typewriterText = nil
    self.focusTopic = nil
    self.hoverTopic = nil
    self.mouseMode = true
    self.keyboardFocusActive = false
    self.topicDisabled = {}
    self.topicImageStates = {}
    local modDir = self.page ~= nil and self.page.app ~= nil and self.page.app.modDir or nil
    if modDir ~= nil then
        local iconFilename = Utils.getFilename("gui/icons/hp_interview_player.dds", modDir)
        local bubbleFilename = Utils.getFilename("gui/solidPixel.dds", modDir)
        self.topicImages = {
            normal = Utils.getFilename("gui/icons/hp_interview_topic_normal.dds", modDir),
            focused = Utils.getFilename("gui/icons/hp_interview_topic_focused.dds", modDir),
            disabled = Utils.getFilename("gui/icons/hp_interview_topic_disabled.dds", modDir)
        }
        for _, background in ipairs({self.chatBackground, self.sideBackground}) do
            if background ~= nil then
                background:setImageFilename(bubbleFilename)
                background:setImageColor(nil, 0.008, 0.020, 0.016, 0.98)
            end
        end
        self.sideSeparator:setImageFilename(bubbleFilename)
        self.sideSeparator:setImageColor(nil, 0.24, 0.31, 0.26, 1)
        for index = 1, 3 do
            local icon = self["questionIcon" .. index]
            if icon ~= nil then
                icon:setImageFilename(iconFilename)
                icon:setImageColor(nil, 1, 1, 1, 1)
            end
            for _, name in ipairs({"questionBubble", "answerBubble"}) do
                local bubble = self[name .. index]
                if bubble ~= nil then
                    bubble:setImageFilename(bubbleFilename)
                    bubble:setImageColor(nil, 0.026, 0.047, 0.041, 1)
                end
            end
        end
    end
    if self.page ~= nil and self.page.app ~= nil and self.page.app.requestOpenApplicantInterview ~= nil then
        self.page.app:requestOpenApplicantInterview(self.applicantId)
    end
    self:refresh(true)
end

function HelperPersonnelInterviewDialog:updateTopicBackgrounds()
    if self.topicImages == nil then
        return
    end
    for _, topic in ipairs(HP_INTERVIEW_TOPICS) do
        local activeTopic = self.mouseMode and self.hoverTopic or (self.keyboardFocusActive and self.focusTopic or nil)
        local state = self.topicDisabled[topic] and "disabled" or (activeTopic == topic and "focused" or "normal")
        if self.topicImageStates[topic] ~= state then
            local background = self[topic .. "ButtonBackground"]
            background:setImageFilename(self.topicImages[state])
            background:setImageColor(nil, 1, 1, 1, 1)
            self.topicImageStates[topic] = state
        end
    end
end

function HelperPersonnelInterviewDialog:onTopicFocused(element)
    if self.topicDisabled == nil then
        return
    end
    for _, topic in ipairs(HP_INTERVIEW_TOPICS) do
        if element == self[topic .. "Button"] and not self.topicDisabled[topic] then
            self.focusTopic = topic
            if not self.settingProgrammaticFocus and not self.handlingMouseEvent then
                self.mouseMode = false
                self.keyboardFocusActive = true
            end
            self:updateTopicBackgrounds()
            break
        end
    end
end

function HelperPersonnelInterviewDialog:getTopicLabel(topic)
    if topic == "experience" then
        return self:getText("ui_hpInterviewTopicExperience", "Erfahrung")
    elseif topic == "reliability" then
        return self:getText("ui_hpInterviewTopicReliability", "Zuverlässigkeit")
    end
    return self:getText("ui_hpInterviewTopicLoyalty", "Loyalität")
end

function HelperPersonnelInterviewDialog:getQuestionText(topic, level, variant)
    local suffix = tonumber(level) == 1 and "First" or "Followup"
    local key = "ui_hpInterviewQuestion" .. string.upper(string.sub(topic, 1, 1)) .. string.sub(topic, 2) .. suffix
    if tonumber(variant) ~= nil and tonumber(variant) >= 4 and tonumber(variant) <= 12 then
        key = key .. "V" .. tostring(math.floor((tonumber(variant) - 4) / 3) + 1)
    end
    return self:getText(key, self:getTopicLabel(topic) .. "?")
end

function HelperPersonnelInterviewDialog:getAnswerText(applicant, entry, isLast)
    local manager = self.page ~= nil and self.page:getManager() or nil
    local minimum, maximum = nil, nil
    if manager ~= nil and manager.getApplicantInterviewKnowledge ~= nil then
        local _
        _, minimum, maximum = manager:getApplicantInterviewKnowledge(applicant, entry.topic)
    end
    local midpoint = ((tonumber(minimum) or 0) + (tonumber(maximum) or 0)) * 0.5
    local bandValue = tonumber(entry.band)
    local band = bandValue == 1 and "Low" or bandValue == 2 and "Medium" or bandValue == 3 and "High" or midpoint < 40 and "Low" or midpoint < 70 and "Medium" or "High"
    local storedVariant = tonumber(entry.variant) or 1
    local variant = math.max(1, math.min(3, storedVariant))
    local intro = self:getText("ui_hpInterviewAnswerIntro" .. tostring(variant), "Meine Einschätzung:")
    local topicName = string.upper(string.sub(entry.topic, 1, 1)) .. string.sub(entry.topic, 2)
    local statement = self:getText("ui_hpInterviewAnswer" .. topicName .. band, self:getTopicLabel(entry.topic))
    local answer = intro .. " " .. statement
    if storedVariant >= 4 and storedVariant <= 12 then
        local answerVariant = (storedVariant - 4) % 3 + 1
        answer = self:getText("ui_hpInterviewAnswer" .. topicName .. band .. "V" .. tostring(answerVariant), statement)
    end
    if isLast and applicant.interviewCompleted == true then
        local wage = self.page ~= nil and self.page:getPersonCoreLines(applicant, true)[3] or ""
        answer = answer .. "\n" .. self:getText("ui_hpInterviewWageIntro", "Mein Gehaltswunsch:") .. " " .. tostring(wage):gsub("^[^:]+:%s*", "")
    end
    return answer
end

function HelperPersonnelInterviewDialog:isTypewriterQueued(target)
    for _, item in ipairs(self.typewriterQueue or {}) do
        if item.target == target then
            return true
        end
    end
    return false
end

function HelperPersonnelInterviewDialog:startNextTypewriter()
    if self.typewriterTarget ~= nil or self.typewriterQueue == nil or #self.typewriterQueue == 0 then
        return
    end
    local item = table.remove(self.typewriterQueue, 1)
    self.typewriterTarget = item.target
    self.typewriterText = item.text
    self.typewriterCharacters = hpInterviewUtf8Characters(item.text)
    self.typewriterVisible = 0
    if item.answerIndex ~= nil then
        self["answerBubble" .. item.answerIndex]:setVisible(true)
        self["answerPortrait" .. item.answerIndex]:setVisible(true)
        item.target:setVisible(true)
    end
    item.target:setText("")
end

function HelperPersonnelInterviewDialog:finishTypewriter()
    if self.typewriterTarget == nil then
        return false
    end
    self.typewriterTarget:setText(self.typewriterText or "")
    self.typewriterTarget = nil
    self.typewriterText = nil
    self.typewriterCharacters = nil
    self.typewriterVisible = 0
    self:startNextTypewriter()
    return true
end

function HelperPersonnelInterviewDialog:refresh(force)
    local applicant = self:getApplicant()
    local manager = self.page ~= nil and self.page:getManager() or nil
    if applicant == nil then
        self:onClickBack()
        return
    end
    if manager == nil then
        return
    end
    if manager.isApplicantInterviewsEnabled ~= nil and not manager:isApplicantInterviewsEnabled() then
        self:onClickBack()
        return
    end
    local history = applicant.interviewHistory or {}
    self.dialogTitle:setText(self:getText("ui_hpInterviewTitle", "Bewerbungsgespräch"))
    self.questionPrompt:setText(self:getText("ui_hpInterviewPrompt", "Wonach möchtest du fragen?"))
    self.applicantProfile:setText(self.page:getProfileTemplate(applicant, true))
    self.applicantName:setText(self.page:getPersonName(applicant))
    self.ageText:setText(self.page:getBirthDateText(applicant))
    self.headerApplicant:setText(self.page:getPersonName(applicant))
    self.headerProgress:setText(string.format(self:getText("ui_hpInterviewRound", "Fragerunde %d von 3"), math.min(3, (tonumber(applicant.interviewQuestionsUsed) or 0) + 1)))
    self.roundText:setText(string.format(self:getText("ui_hpInterviewRound", "Fragerunde %d von 3"), math.min(3, (tonumber(applicant.interviewQuestionsUsed) or 0) + 1)))
    for _, topic in ipairs(HP_INTERVIEW_TOPICS) do
        local display = self.page:getPersonnelKnowledgeDisplay(applicant, topic, true)
        self[topic .. "Knowledge"]:setText(self:getTopicLabel(topic) .. ": " .. display)
    end
    self.leaderText:setText(self.page.app ~= nil and self.page.app:canControlApplicantInterview(self.applicantId) and self:getText("ui_hpInterviewLeader", "Du führst das Gespräch.") or self:getText("ui_hpInterviewObserver", "Du verfolgst das Gespräch."))
    if self.applicantPortrait.setImageFilename ~= nil then
        self.applicantPortrait:setImageFilename(self.page:getPortraitFilename(applicant))
        self.applicantPortrait:setImageColor(nil, 1, 1, 1, 1)
    end
    for index = (self.lastHistoryCount or #history) + 1, #history do
        local entry = history[index]
        local question = self["question" .. index]
        local answer = self["answer" .. index]
        table.insert(self.typewriterQueue, {target = question, text = self:getQuestionText(entry.topic, entry.level, entry.variant)})
        table.insert(self.typewriterQueue, {target = answer, text = self:getAnswerText(applicant, entry, index == #history), answerIndex = index})
        question:setText("")
        answer:setText("")
    end
    for index = 1, 3 do
        local entry = history[index]
        local question = self["question" .. index]
        local answer = self["answer" .. index]
        local questionIcon = self["questionIcon" .. index]
        local answerPortrait = self["answerPortrait" .. index]
        local visible = entry ~= nil
        question:setVisible(visible)
        local answerWaiting = self:isTypewriterQueued(answer)
        answer:setVisible(visible and not answerWaiting)
        questionIcon:setVisible(visible)
        answerPortrait:setVisible(visible and not answerWaiting)
        self["questionBubble" .. index]:setVisible(visible)
        self["answerBubble" .. index]:setVisible(visible and not answerWaiting)
        if visible then
            if self.typewriterTarget ~= question and not self:isTypewriterQueued(question) then
                question:setText(self:getQuestionText(entry.topic, entry.level, entry.variant))
            end
            local answerText = self:getAnswerText(applicant, entry, index == #history)
            if self.typewriterTarget ~= answer and not answerWaiting then
                answer:setText(answerText)
            end
            if answerPortrait.setImageFilename ~= nil then
                answerPortrait:setImageFilename(self.page:getPortraitFilename(applicant))
                answerPortrait:setImageColor(nil, 1, 1, 1, 1)
            end
        end
    end
    self:startNextTypewriter()
    local canControl = self.page.app ~= nil and self.page.app:canControlApplicantInterview(self.applicantId)
    local firstAvailable = nil
    for _, topic in ipairs(HP_INTERVIEW_TOPICS) do
        local button = self[topic .. "Button"]
        local level = manager:getApplicantInterviewLevel(applicant, topic)
        local disabled = not canControl or applicant.interviewCompleted == true or level >= 3 or not manager:canAskApplicantInterviewTopic(applicant, topic)
        button:setText(self:getTopicLabel(topic))
        button:setDisabled(disabled)
        self.topicDisabled[topic] = disabled
        if not disabled then firstAvailable = firstAvailable or topic end
    end
    if self.focusTopic == nil or self.topicDisabled[self.focusTopic] then
        self.focusTopic = firstAvailable
        if firstAvailable ~= nil and FocusManager ~= nil then
            self.settingProgrammaticFocus = true
            FocusManager:setFocus(self[firstAvailable .. "Button"])
            self.settingProgrammaticFocus = false
        end
    end
    self:updateTopicBackgrounds()
    self.finishedText:setVisible(applicant.interviewCompleted == true)
    self.leaderText:setVisible(applicant.interviewCompleted ~= true)
    self.finishedText:setText(self:getText("ui_hpInterviewFinished", "Das Bewerbungsgespräch ist beendet."))
    self.lastHistoryCount = #history
    self.lastChangeCounter = tonumber(manager.changeCounter) or self.lastChangeCounter
end

function HelperPersonnelInterviewDialog:ask(topic)
    if self.page == nil or self.page.app == nil then
        return false
    end
    if self:finishTypewriter() then
        return true
    end
    self.focusTopic = topic
    self:updateTopicBackgrounds()
    return self.page.app:requestApplicantInterviewQuestion(self.applicantId, topic)
end

function HelperPersonnelInterviewDialog:onExperience() return self:ask("experience") end
function HelperPersonnelInterviewDialog:onReliability() return self:ask("reliability") end
function HelperPersonnelInterviewDialog:onLoyalty() return self:ask("loyalty") end

function HelperPersonnelInterviewDialog:mouseEvent(posX, posY, isDown, isUp, button, eventUsed)
    local hoveredTopic = nil
    for _, topic in ipairs(HP_INTERVIEW_TOPICS) do
        local element = self[topic .. "Button"]
        local position = element ~= nil and element.absPosition or nil
        local size = element ~= nil and element.absSize or nil
        if not self.topicDisabled[topic] and position ~= nil and size ~= nil
            and posX >= position[1] and posX <= position[1] + size[1]
            and posY >= position[2] and posY <= position[2] + size[2] then
            hoveredTopic = topic
            break
        end
    end
    if self.hoverTopic ~= hoveredTopic or not self.mouseMode then
        self.hoverTopic = hoveredTopic
        self.mouseMode = true
        self:updateTopicBackgrounds()
    end
    local leftButton = Input ~= nil and Input.MOUSE_BUTTON_LEFT or nil
    local isLeftClick = button == nil or button == 0 or button == 1 or button == leftButton
    local position = self.chatBackground ~= nil and self.chatBackground.absPosition or nil
    local size = self.chatBackground ~= nil and self.chatBackground.absSize or nil
    if isUp and isLeftClick and self.typewriterTarget ~= nil and position ~= nil and size ~= nil
        and posX >= position[1] and posX <= position[1] + size[1]
        and posY >= position[2] and posY <= position[2] + size[2] then
        self:finishTypewriter()
        return true
    end
    self.handlingMouseEvent = true
    local used = HelperPersonnelInterviewDialog:superClass().mouseEvent(self, posX, posY, isDown, isUp, button, eventUsed)
    self.handlingMouseEvent = false
    return used
end

function HelperPersonnelInterviewDialog:update(dt)
    HelperPersonnelInterviewDialog:superClass().update(self, dt)
    local manager = self.page ~= nil and self.page:getManager() or nil
    self.controlRefreshElapsed = (self.controlRefreshElapsed or 0) + (tonumber(dt) or 0)
    self.leadershipHeartbeatElapsed = (self.leadershipHeartbeatElapsed or 0) + (tonumber(dt) or 0)
    if self.leadershipHeartbeatElapsed >= 5000 and self.page ~= nil and self.page.app ~= nil and self.page.app.requestOpenApplicantInterview ~= nil then
        self.leadershipHeartbeatElapsed = 0
        self.page.app:requestOpenApplicantInterview(self.applicantId)
    end
    if manager ~= nil and ((tonumber(manager.changeCounter) or -1) ~= self.lastChangeCounter or self.controlRefreshElapsed >= 250) then
        self.controlRefreshElapsed = 0
        self:refresh(false)
    end
    if self.typewriterText ~= nil and self.typewriterTarget ~= nil then
        self.typewriterVisible = math.min(#self.typewriterCharacters, self.typewriterVisible + math.max(1, math.floor((tonumber(dt) or 0) * 0.045)))
        self.typewriterTarget:setText(table.concat(self.typewriterCharacters, "", 1, self.typewriterVisible))
        if self.typewriterVisible >= #self.typewriterCharacters then
            self:finishTypewriter()
        end
    end
end

function HelperPersonnelInterviewDialog:onClose()
    if self.page ~= nil and self.page.app ~= nil and self.page.app.requestCloseApplicantInterview ~= nil then
        self.page.app:requestCloseApplicantInterview(self.applicantId)
    end
    local page = self.page
    self.page = nil
    self.applicantId = nil
    self.typewriterText = nil
    self.typewriterTarget = nil
    self.typewriterQueue = {}
    self.topicImages = nil
    self.topicImageStates = nil
    self.topicDisabled = nil
    self.focusTopic = nil
    self.hoverTopic = nil
    self.mouseMode = nil
    self.keyboardFocusActive = nil
    if page ~= nil then page:refresh() end
    HelperPersonnelInterviewDialog:superClass().onClose(self)
end
