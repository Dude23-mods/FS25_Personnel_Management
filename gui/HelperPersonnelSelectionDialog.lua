HelperPersonnelSelectionDialog = {}
local HelperPersonnelSelectionDialog_mt = Class(HelperPersonnelSelectionDialog, DialogElement)

local function selectionLinear(value)
    if value <= 0.04045 then return value / 12.92 end
    return ((value + 0.055) / 1.055) ^ 2.4
end

local function setSelectionTextColor(element, r, g, b)
    element:setTextColor(selectionLinear(r), selectionLinear(g), selectionLinear(b), 1)
end

function HelperPersonnelSelectionDialog.new(target)
    return DialogElement.new(target, HelperPersonnelSelectionDialog_mt)
end

function HelperPersonnelSelectionDialog:setContext(selection)
    self.selection = selection
end

function HelperPersonnelSelectionDialog:onOpen()
    HelperPersonnelSelectionDialog:superClass().onOpen(self)
    local selection = self.selection
    local pixel = Utils.getFilename("gui/solidPixel.dds", selection.app.modDir)
    for _, name in ipairs({"windowBorder", "windowBackground", "windowAccent", "headerLine", "footerLine", "portraitFrame", "statusBackground", "metricBackground1", "metricBar1", "metricFill1", "metricBackground2", "metricBar2", "metricFill2", "metricBackground3", "metricBar3", "metricFill3", "detailBackground1", "detailBackground2", "detailBackground3", "detailBackground4", "specBackground", "developmentBackground", "progressBackground1", "progressFill1", "progressBackground2", "progressFill2", "progressBackground3", "progressFill3", "progressBackground4", "progressFill4", "toggleMark"}) do
        self[name]:setImageFilename(pixel)
    end
    self.metricBarWidth = self.metricBar1.size[1]
    self.progressBarWidth = self.progressBackground1.size[1]
    self:refresh()
end

function HelperPersonnelSelectionDialog:onClose()
    local selection = self.selection
    self.selection = nil
    if selection ~= nil and selection.isVisible then
        selection:close(false, true)
    end
    HelperPersonnelSelectionDialog:superClass().onClose(self)
end

function HelperPersonnelSelectionDialog:onClickBack()
    if self.selection ~= nil then
        self.selection:onActionCancel(nil, 1)
    end
    return false
end

function HelperPersonnelSelectionDialog:onToggle()
    if self.selection ~= nil then
        self.selection:onActionToggleAll(nil, 1)
    end
end

function HelperPersonnelSelectionDialog:onWorkerClick()
    local selection = self.selection
    if selection == nil then return end
    local index = selection.selectedIndex
    local now = tonumber(g_time) or 0
    local isDouble = selection.lastWorkerClickIndex == index and now - (selection.lastWorkerClickTime or 0) <= 400
    selection.lastWorkerClickIndex = index
    selection.lastWorkerClickTime = now
    if isDouble then selection:close(true) end
end

function HelperPersonnelSelectionDialog:refresh()
    local selection = self.selection
    if selection == nil or not selection.isVisible then return end
    local manager = selection.app.manager
    local worker = selection.availableWorkers[selection.selectedIndex]
    local count = #selection.availableWorkers
    self.kicker:setText(g_i18n:getText("ui_selectionKicker"))
    self.title:setText(g_i18n:getText("ui_selectionTitle"))
    self.counter:setText(string.format("%d / %d", math.min(selection.selectedIndex, count), count))
    self.footer:setText(g_i18n:getText("ui_selectionFooterControls"))
    self.toggleLabel:setText(g_i18n:getText(selection.showAllWorkers and "ui_selectionShowAvailable" or "ui_selectionShowAll"))
    self.toggleMark:setImageColor(nil, selectionLinear(selection.showAllWorkers and 0.722 or 0.25), selectionLinear(selection.showAllWorkers and 0.875 or 0.28), selectionLinear(selection.showAllWorkers and 0.098 or 0.25), 1)
    self.content:setVisible(worker ~= nil)
    self.emptyText:setVisible(worker == nil)
    self.emptyText:setText(g_i18n:getText("ui_selectionNoWorkers"))
    if worker == nil then return end
    local available = selection:isWorkerAvailable(worker)
    self.personName:setText(manager:getFullName(worker))
    self.rank:setText(manager:getRankText(worker))
    self.status:setText(selection:getWorkerAvailabilityReason(worker))
    self.portraitFrame:setImageColor(nil, selectionLinear(available and 0.722 or 0.32), selectionLinear(available and 0.875 or 0.34), selectionLinear(available and 0.098 or 0.32), 1)
    local bridge = selection.app.helperBridge
    local filename = bridge ~= nil and bridge.getPortraitFilenameForPerson ~= nil and bridge:getPortraitFilenameForPerson(worker) or nil
    self.portrait:setVisible(filename ~= nil and filename ~= "")
    if filename ~= nil and filename ~= "" then self.portrait:setImageFilename(filename) end
    self.portrait:setImageColor(nil, available and 1 or 0.27, available and 1 or 0.27, available and 1 or 0.27, 1)
    self.statusBackground:setImageColor(nil, selectionLinear(available and 0.208 or 0.17), selectionLinear(available and 0.267 or 0.17), selectionLinear(available and 0.051 or 0.17), 1)
    setSelectionTextColor(self.personName, available and 0.941 or 0.54, available and 0.949 or 0.54, available and 0.933 or 0.54)
    setSelectionTextColor(self.rank, available and 0.722 or 0.45, available and 0.875 or 0.45, available and 0.098 or 0.45)
    setSelectionTextColor(self.status, available and 0.843 or 0.62, available and 0.945 or 0.62, available and 0.541 or 0.62)
    self.profileTitle:setText(g_i18n:getText("ui_selectionPerformanceProfile"))
    local values = {tonumber(worker.experience) or 0, tonumber(worker.reliability) or 0, tonumber(worker.loyalty) or 65}
    local labels = {"ui_pmStatExperience", "ui_pmStatReliability", "ui_pmStatLoyalty"}
    for i = 1, 3 do
        local value = math.max(0, math.min(100, values[i]))
        self["metricLabel" .. i]:setText(g_i18n:getText(labels[i]))
        self["metricValue" .. i]:setText(string.format("%d", math.floor(values[i] + 0.5)))
        local bar = self["metricFill" .. i]
        bar:setSize(self.metricBarWidth * value / 100, bar.size[2])
    end
    local wage = manager.getCurrentMonthlyWage ~= nil and manager:getCurrentMonthlyWage(worker) or worker.wage or 0
    local age = manager.getPersonAge ~= nil and manager:getPersonAge(worker) or 0
    local speed = manager.getWorkerWorkSpeedPercent ~= nil and manager:getWorkerWorkSpeedPercent(worker) or 100
    local detailLabels = {"ui_selectionAgeLabel", "ui_selectionWageLabel", "ui_selectionJobsLabel", "ui_selectionSpeedLabel"}
    local details = {string.format(g_i18n:getText("ui_selectionAgeValue"), age), g_i18n:formatMoney(wage, 0, true, false), tostring(tonumber(worker.jobsCompleted) or 0), string.format("%d %%", speed)}
    for i = 1, 4 do
        self["detailLabel" .. i]:setText(g_i18n:getText(detailLabels[i]))
        self["detailValue" .. i]:setText(details[i])
        setSelectionTextColor(self["detailValue" .. i], available and 0.941 or 0.58, available and 0.949 or 0.58, available and 0.933 or 0.58)
    end
    self.specTitle:setText(g_i18n:getText("ui_specialization_short"))
    self.developmentTitle:setText(g_i18n:getText("ui_selectionProfessionalDevelopment"))
    local learned = manager.getLearnedSpecializationTable ~= nil and manager:getLearnedSpecializationTable(worker) or {}
    local specs, progress, learnedCount = {}, {}, 0
    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        if learned[key] == true and #specs < 5 then table.insert(specs, key) end
        if manager:workerHasLearnedSpecialization(worker, key) then
            learnedCount = learnedCount + 1
        else
            local minutes = manager:getSpecializationProgressMinutes(worker, key)
            if minutes > 0 then table.insert(progress, {key = key, minutes = minutes}) end
        end
    end
    local required = (HelperPersonnelManager.SPECIALIZATION_LEARN_BASE_MINUTES or 240) + learnedCount * (HelperPersonnelManager.SPECIALIZATION_LEARN_INCREMENT_MINUTES or 180)
    for _, entry in ipairs(progress) do entry.percent = required > 0 and math.max(0, math.min(99, math.floor(entry.minutes / required * 100 + 0.5))) or 0 end
    table.sort(progress, function(a, b) return a.percent == b.percent and a.minutes > b.minutes or a.percent > b.percent end)
    for i = 1, 5 do
        local element = self["spec" .. i]
        local key = specs[i]
        element:setVisible(key ~= nil or (i == 1 and #specs == 0))
        if key ~= nil then
            element:setText(manager:getSpecializationDisplayName(key))
            local matches = manager:workerHasSpecialization(worker, key) and key == selection.expectedSpecializationKey
            setSelectionTextColor(element, matches and 0.722 or (available and 0.82 or 0.55), matches and 0.875 or (available and 0.82 or 0.55), matches and 0.098 or (available and 0.82 or 0.55))
            element.textBold = matches
        elseif i == 1 then
            element:setText(g_i18n:getText("ui_selectionNoSpecialization"))
            setSelectionTextColor(element, 0.667, 0.690, 0.659)
            element.textBold = false
        end
    end
    for i = 1, 4 do
        local entry = progress[i]
        self["progressLabel" .. i]:setVisible(entry ~= nil or (i == 1 and #progress == 0))
        self["progressValue" .. i]:setVisible(entry ~= nil)
        self["progressBackground" .. i]:setVisible(entry ~= nil)
        self["progressFill" .. i]:setVisible(entry ~= nil)
        if entry ~= nil then
            self["progressLabel" .. i]:setText(manager:getSpecializationDisplayName(entry.key))
            self["progressValue" .. i]:setText(string.format("%d %%", entry.percent))
            setSelectionTextColor(self["progressLabel" .. i], available and 0.82 or 0.55, available and 0.82 or 0.55, available and 0.82 or 0.55)
            setSelectionTextColor(self["progressValue" .. i], available and 0.941 or 0.58, available and 0.949 or 0.58, available and 0.933 or 0.58)
            local bar = self["progressFill" .. i]
            bar:setSize(self.progressBarWidth * entry.percent / 100, bar.size[2])
        elseif i == 1 then
            self.progressLabel1:setText(g_i18n:getText("ui_selectionNoSpecializationProgress"))
            setSelectionTextColor(self.progressLabel1, 0.667, 0.690, 0.659)
        end
    end
end
