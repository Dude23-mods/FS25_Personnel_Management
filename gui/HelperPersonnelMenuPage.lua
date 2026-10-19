HelperPersonnelMenuPage = {}
local HelperPersonnelMenuPage_mt = Class(HelperPersonnelMenuPage, HelperPersonnelViewBase)
local hpMenuTypography = HelperPersonnelViewBase.TYPOGRAPHY
local hpMenuDesign = HelperPersonnelViewBase.MENU_DESIGN

local function hpMenuGetInputAction(actionName, fallback)
    if InputAction ~= nil and InputAction[actionName] ~= nil then
        return InputAction[actionName]
    end

    return fallback or actionName
end

local function hpMenuGetInputConstant(name, fallback)
    if Input ~= nil and Input[name] ~= nil then
        return Input[name]
    end

    if _G ~= nil and _G[name] ~= nil then
        return _G[name]
    end

    return fallback
end

local function hpMenuClamp(value, minValue, maxValue)
    value = math.floor((tonumber(value) or minValue) + 0.5)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function hpMenuGetAspectCorrectWidth(height)
    local screenWidth = tonumber(g_screenWidth) or 0
    local screenHeight = tonumber(g_screenHeight) or 0
    if screenWidth <= 0 or screenHeight <= 0 then
        return height * (9 / 16)
    end

    return height * (screenHeight / screenWidth)
end

local function hpMenuGetAspectCorrectHeight(width)
    local screenWidth = tonumber(g_screenWidth) or 0
    local screenHeight = tonumber(g_screenHeight) or 0
    if screenWidth <= 0 or screenHeight <= 0 then
        return width * (16 / 9)
    end

    return width * (screenWidth / screenHeight)
end

local function hpMenuSetText(element, value)
    if element ~= nil and element.setText ~= nil then
        element:setText(tostring(value or ""))
    end
end

local function hpMenuUpper(value)
    return string.upper(tostring(value or ""))
end

local function hpMenuSplitLabelValue(value)
    local text = tostring(value or "")
    local separatorStart, separatorEnd = string.find(text, ": ", 1, true)
    if separatorStart == nil then
        return text, ""
    end

    return string.sub(text, 1, separatorStart - 1), string.sub(text, separatorEnd + 1)
end

function HelperPersonnelMenuPage.new(pageKind, customMt)
    local self = HelperPersonnelViewBase.new(customMt or HelperPersonnelMenuPage_mt, g_messageCenter)

    self.pageKind = pageKind or "overview"
    self.menu = nil
    self.pageTitleKey = "ui_pmMenuPageOverview"
    self.pageTitleFallback = "Übersicht"
    self.btnClose = nil
    self.btnPrevTab = nil
    self.btnNextTab = nil
    self.btnPrevPerson = nil
    self.btnNextPerson = nil
    self.btnPrimary = nil
    self.btnTransport = nil
    self.btnSalary = nil
    self.btnEmergencyRelease = nil
    self.navArrowLeftOverlay = nil
    self.navArrowRightOverlay = nil
    self.navDotActiveOverlay = nil
    self.navDotInactiveOverlay = nil
    self.overviewRefreshElapsed = 0
    self.settingsInfoTextKey = "ui_pmSettingsInfo"
    self.settingsSelectedKey = nil
    self.selectedTrainingCategoryKey = nil
    self.selectedTrainingWorkerId = nil
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.transportPrioritySelectedIndex = 1
    self.transportPriorityFirstIndex = 1
    self.transportPriorityVisibleRows = 10
    self.btnTransportDialogCancel = nil
    self.btnTransportDialogUp = nil
    self.btnTransportDialogDown = nil
    self.btnTransportDialogToggle = nil
    self.btnTransportDialogApply = nil
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    self.salaryRaiseSelectedIndex = 1
    self.salaryRaiseFirstIndex = 1
    self.salaryRaiseVisibleRows = 10
    self.btnSalaryDialogCancel = nil
    self.btnSalaryDialogDecline = nil
    self.btnSalaryDialogAccept = nil

    return self
end

function HelperPersonnelMenuPage:setMenu(menu)
    self.menu = menu
    self.inGameMenu = menu
end

function HelperPersonnelMenuPage:setContext(app)
    HelperPersonnelMenuPage:superClass().setContext(self, app)
    self:deleteNavigationOverlays()

    if app ~= nil and app.modDir ~= nil then
        local leftFilename = Utils.getFilename("gui/icons/hp_person_nav_left.dds", app.modDir)
        local rightFilename = Utils.getFilename("gui/icons/hp_person_nav_right.dds", app.modDir)
        local activeDotFilename = Utils.getFilename("gui/icons/hp_person_dot_active.dds", app.modDir)
        local inactiveDotFilename = Utils.getFilename("gui/icons/hp_person_dot_inactive.dds", app.modDir)
        local okLeft, leftOverlay = pcall(function()
            return Overlay.new(leftFilename, 0, 0, 0.04, 0.04)
        end)
        local okRight, rightOverlay = pcall(function()
            return Overlay.new(rightFilename, 0, 0, 0.04, 0.04)
        end)
        local okActiveDot, activeDotOverlay = pcall(function()
            return Overlay.new(activeDotFilename, 0, 0, 0.01, 0.01)
        end)
        local okInactiveDot, inactiveDotOverlay = pcall(function()
            return Overlay.new(inactiveDotFilename, 0, 0, 0.01, 0.01)
        end)

        if okLeft then
            self.navArrowLeftOverlay = leftOverlay
        end
        if okRight then
            self.navArrowRightOverlay = rightOverlay
        end
        if okActiveDot then
            self.navDotActiveOverlay = activeDotOverlay
        end
        if okInactiveDot then
            self.navDotInactiveOverlay = inactiveDotOverlay
        end

    end
end

function HelperPersonnelMenuPage:deleteNavigationOverlays()
    if self.navArrowLeftOverlay ~= nil then
        self.navArrowLeftOverlay:delete()
        self.navArrowLeftOverlay = nil
    end

    if self.navArrowRightOverlay ~= nil then
        self.navArrowRightOverlay:delete()
        self.navArrowRightOverlay = nil
    end

    if self.navDotActiveOverlay ~= nil then
        self.navDotActiveOverlay:delete()
        self.navDotActiveOverlay = nil
    end

    if self.navDotInactiveOverlay ~= nil then
        self.navDotInactiveOverlay:delete()
        self.navDotInactiveOverlay = nil
    end

end

function HelperPersonnelMenuPage:delete()
    self:deleteNavigationOverlays()
    HelperPersonnelMenuPage:superClass().delete(self)
end

function HelperPersonnelMenuPage:getInGameMenu()
    return self.menu or HelperPersonnelMenuPage:superClass().getInGameMenu(self)
end

function HelperPersonnelMenuPage:isCurrentMenuPage()
    local menu = self:getInGameMenu()
    return menu == nil or menu.currentPage == self
end

function HelperPersonnelMenuPage:setPageKind(pageKind)
    self.pageKind = pageKind or self.pageKind or "overview"
    self:applyPageKind()
end

function HelperPersonnelMenuPage:applyPageKind()
    local kind = self.pageKind or "overview"

    if kind == "applicants" then
        self.mode = HelperPersonnelViewBase.MODE_APPLICANTS
        self.pageTitleKey = "ui_pmMenuPageApplicants"
        self.pageTitleFallback = "Bewerber"
    elseif kind == "employees" then
        self.mode = HelperPersonnelViewBase.MODE_WORKERS
        self.pageTitleKey = "ui_pmMenuPageEmployees"
        self.pageTitleFallback = "Mitarbeiter"
    elseif kind == "training" then
        self.mode = HelperPersonnelViewBase.MODE_WORKERS
        self.pageTitleKey = "ui_pmMenuPageTraining"
        self.pageTitleFallback = "Schulung"
    elseif kind == "settings" then
        self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
        self.pageTitleKey = "ui_pmMenuPageSettings"
        self.pageTitleFallback = "Einstellungen"
    else
        self.mode = HelperPersonnelViewBase.MODE_OVERVIEW
        self.pageTitleKey = "ui_pmMenuPageOverview"
        self.pageTitleFallback = "Übersicht"
    end
end

function HelperPersonnelMenuPage:onFrameOpen()
    HelperPersonnelMenuPage:superClass().onFrameOpen(self)
    self:applyPageKind()
    self:refresh()
    self:updateButtons()
    self.personPagerLayoutRefreshPending = (self.pageKind == "applicants" or self.pageKind == "employees") and 1 or 0
end

function HelperPersonnelMenuPage:onGuiSetupFinished()
    HelperPersonnelMenuPage:superClass().onGuiSetupFinished(self)
    self:initializeNativeOverviewGui()
    self:initializeNativeApplicantsGui()
    self:initializeNativeEmployeesGui()
    self:initializeNativeTrainingGui()
end

function HelperPersonnelMenuPage:initializeNativeApplicantsGui()
    if self.pageKind ~= "applicants" then
        return
    end

    self.applicantsPagerDotsDynamic = {}
    self.applicantsPagerDotCount = 0

    local setTextSize = function(element, size)
        if element ~= nil and element.setTextSize ~= nil then
            element:setTextSize(size)
        end
    end
    setTextSize(self.applicantsName, hpMenuTypography.listPrimary.size)
    setTextSize(self.applicantsProfileTitle, hpMenuTypography.sectionTitle.size)
    setTextSize(self.applicantsEmpty, hpMenuTypography.listPrimary.size)
    for _, name in ipairs({"applicantsExperienceLabel", "applicantsReliabilityLabel", "applicantsLoyaltyLabel", "applicantsExperienceValue", "applicantsReliabilityValue", "applicantsLoyaltyValue", "applicantsBirthLabel", "applicantsBirth", "applicantsOriginLabel", "applicantsOrigin", "applicantsWageLabel", "applicantsWage", "applicantsStatusLabel", "applicantsStatus", "applicantsSpecializationLabel", "applicantsSpecialization", "applicantsProfileRow1", "applicantsProfileRow2", "applicantsProfileRow3", "applicantsProfileRow4", "applicantsPermission"}) do
        setTextSize(self[name], hpMenuTypography.bodyText.size)
    end

    local pixelFilename = self.app ~= nil and Utils.getFilename("gui/solidPixel.dds", self.app.modDir) or nil
    if pixelFilename ~= nil then
        for _, name in ipairs({"applicantsDetailBg"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.055, 0.090, 0.060, 0.94)
            end
        end
        for _, name in ipairs({"applicantsPortraitBg"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.032, 0.052, 0.036, 0.84)
            end
        end
        for _, name in ipairs({"applicantsDetailLine", "applicantsProfileLine"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.61, 0.73, 0.07, 0.86)
            end
        end
        for _, name in ipairs({"applicantsExperienceTrack", "applicantsReliabilityTrack", "applicantsLoyaltyTrack"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.30, 0.34, 0.30, 0.90)
            end
        end
        for _, name in ipairs({"applicantsExperienceFill", "applicantsReliabilityFill", "applicantsLoyaltyFill"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.70, 0.86, 0.12, 1)
            end
        end
    end

    if self.app ~= nil and self.app.modDir ~= nil then
        local leftFilename = Utils.getFilename("gui/icons/hp_person_nav_left.dds", self.app.modDir)
        local rightFilename = Utils.getFilename("gui/icons/hp_person_nav_right.dds", self.app.modDir)
        if self.applicantsPrevIcon ~= nil then self.applicantsPrevIcon:setImageFilename(leftFilename) end
        if self.applicantsNextIcon ~= nil then self.applicantsNextIcon:setImageFilename(rightFilename) end
    end

    self:refreshApplicantsNativeGui()
end

function HelperPersonnelMenuPage:clearApplicantsPagerDots()
    for _, dot in ipairs(self.applicantsPagerDotsDynamic or {}) do
        if dot ~= nil and dot.delete ~= nil then
            dot:delete()
        end
    end
    self.applicantsPagerDotsDynamic = {}
    self.applicantsPagerDotCount = 0
end

function HelperPersonnelMenuPage:refreshApplicantsPager(index, count)
    if self.applicantsPagerDots == nil or self.applicantsPagerDotTemplate == nil then
        return
    end

    if self.applicantsPagerDotCount ~= count then
        self:clearApplicantsPagerDots()
        for _ = 1, count do
            local dot = self.applicantsPagerDotTemplate:clone(self.applicantsPagerDots)
            if dot ~= nil then
                table.insert(self.applicantsPagerDotsDynamic, dot)
            end
        end
        self.applicantsPagerDotCount = count
    end

    local activeFilename = self.app ~= nil and Utils.getFilename("gui/icons/hp_person_dot_active.dds", self.app.modDir) or nil
    local inactiveFilename = self.app ~= nil and Utils.getFilename("gui/icons/hp_person_dot_inactive.dds", self.app.modDir) or nil
    local centerX = 0.360
    local desiredDotHeight = 0.012
    local desiredDotWidth = hpMenuGetAspectCorrectWidth(desiredDotHeight)
    local maxDotBandWidth = 0.300
    local spacingFactor = 0.75
    local dotWidth = desiredDotWidth
    if count > 1 then
        dotWidth = math.min(desiredDotWidth, maxDotBandWidth / (count + (count - 1) * spacingFactor))
    end
    local dotHeight = hpMenuGetAspectCorrectHeight(dotWidth)
    local dotSpacing = dotWidth * spacingFactor
    local totalDotWidth = count > 0 and (count * dotWidth) + ((count - 1) * dotSpacing) or 0
    local firstDotX = centerX - totalDotWidth * 0.5

    local buttonHeight = 0.050
    local buttonWidth = 0.028125
    local iconHeight = 0.032
    local iconWidth = 0.018
    local buttonGap = 0.024
    local previousX = centerX - totalDotWidth * 0.5 - buttonGap - buttonWidth
    local nextX = centerX + totalDotWidth * 0.5 + buttonGap
    for _, buttonInfo in ipairs({
        {button = self.applicantsPrevButton, icon = self.applicantsPrevIcon, x = previousX},
        {button = self.applicantsNextButton, icon = self.applicantsNextIcon, x = nextX}
    }) do
        if buttonInfo.button ~= nil then
            buttonInfo.button:setPosition(buttonInfo.x, -0.001)
        end
        if buttonInfo.icon ~= nil then
            buttonInfo.icon:setPosition((buttonWidth - iconWidth) * 0.5, (buttonHeight - iconHeight) * 0.5)
        end
    end

    for dotIndex, dot in ipairs(self.applicantsPagerDotsDynamic or {}) do
        if dot ~= nil then
            dot:setVisible(true)
            dot:setPosition(firstDotX + (dotIndex - 1) * (dotWidth + dotSpacing), (0.048 - dotHeight) * 0.5)
            dot:setSize(dotWidth, dotHeight)
            if activeFilename ~= nil and inactiveFilename ~= nil then
                dot:setImageFilename(dotIndex == index and activeFilename or inactiveFilename)
            end
        end
    end
end

function HelperPersonnelMenuPage:refreshApplicantsNativeGui()
    if self.pageKind ~= "applicants" or self.applicantsContent == nil then
        return
    end

    local applicants = self:getApplicants()
    local count = #applicants
    self.applicantIndex = hpMenuClamp(self.applicantIndex or 1, 1, math.max(count, 1))
    local person = applicants[self.applicantIndex]
    local hasPerson = person ~= nil
    local canManage = self:canManageCurrentFarm()

    if self.applicantsDetail ~= nil then self.applicantsDetail:setVisible(hasPerson) end
    if self.applicantsPager ~= nil then self.applicantsPager:setVisible(hasPerson) end
    if self.applicantsEmpty ~= nil then
        hpMenuSetText(self.applicantsEmpty, self:getText("ui_noApplicantsDetail", "Keine Bewerber vorhanden"))
        self.applicantsEmpty:setVisible(not hasPerson)
    end
    if self.applicantsPermission ~= nil then
        hpMenuSetText(self.applicantsPermission, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen."))
        self.applicantsPermission:setVisible(not canManage)
    end

    local hasNavigation = count > 1
    for _, button in ipairs({self.applicantsPrevButton, self.applicantsNextButton}) do
        if button ~= nil and button.setDisabled ~= nil then button:setDisabled(not hasNavigation) end
    end

    self:refreshApplicantsPager(self.applicantIndex, count)

    if not hasPerson then
        return
    end

    local lines = self:getPersonCoreLines(person, true)
    hpMenuSetText(self.applicantsName, self:getPersonName(person))
    local birthLabel, birthValue = hpMenuSplitLabelValue(lines[1])
    local originLabel, originValue = hpMenuSplitLabelValue(lines[2])
    local wageLabel, wageValue = hpMenuSplitLabelValue(lines[3])
    local statusLabel, statusValue = hpMenuSplitLabelValue(lines[4])
    local specializationLabel, specializationValue = hpMenuSplitLabelValue(lines[5])
    hpMenuSetText(self.applicantsBirthLabel, birthLabel .. ":")
    hpMenuSetText(self.applicantsBirth, birthValue)
    hpMenuSetText(self.applicantsOriginLabel, originLabel .. ":")
    hpMenuSetText(self.applicantsOrigin, originValue)
    hpMenuSetText(self.applicantsWageLabel, wageLabel .. ":")
    hpMenuSetText(self.applicantsWage, wageValue)
    hpMenuSetText(self.applicantsStatusLabel, statusLabel .. ":")
    hpMenuSetText(self.applicantsStatus, statusValue)
    hpMenuSetText(self.applicantsSpecializationLabel, specializationLabel .. ":")
    hpMenuSetText(self.applicantsSpecialization, specializationValue)
    hpMenuSetText(self.applicantsExperienceLabel, self:getText("ui_pmStatExperience", "Erfahrung"))
    hpMenuSetText(self.applicantsReliabilityLabel, self:getText("ui_pmStatReliability", "Zuverlässigkeit"))
    hpMenuSetText(self.applicantsLoyaltyLabel, self:getText("ui_pmStatLoyalty", "Loyalität"))

    local stats = {
        {key = "Experience", value = person.experience or 0},
        {key = "Reliability", value = person.reliability or 0},
        {key = "Loyalty", value = person.loyalty or 0}
    }
    for _, stat in ipairs(stats) do
        local value = math.max(0, math.min(100, tonumber(stat.value) or 0))
        hpMenuSetText(self["applicants" .. stat.key .. "Value"], string.format("%d %%", math.floor(value + 0.5)))
        local fill = self["applicants" .. stat.key .. "Fill"]
        if fill ~= nil and fill.setSize ~= nil then fill:setSize(math.max(0.001, 0.150 * value / 100), 0.009) end
    end

    if self.applicantsPortrait ~= nil and self.applicantsPortrait.setImageFilename ~= nil then
        self.applicantsPortrait:setImageFilename(self:getPortraitFilename(person))
    end
    hpMenuSetText(self.applicantsProfileTitle, self:getText("ui_pmProfileHeader", "PROFIL"))
    local profileLines = self:getWrappedProfileLines(person, true)
    for index = 1, 4 do
        local row = self["applicantsProfileRow" .. index]
        local value = profileLines[index]
        hpMenuSetText(row, value or "")
        if row ~= nil then row:setVisible(value ~= nil) end
    end
end

function HelperPersonnelMenuPage:initializeNativeEmployeesGui()
    if self.pageKind ~= "employees" then
        return
    end

    self.employeesPagerDotsDynamic = {}
    self.employeesPagerDotCount = 0
    self.employeesProfileFirstIndex = 1

    local setTextSize = function(element, size)
        if element ~= nil and element.setTextSize ~= nil then
            element:setTextSize(size)
        end
    end
    setTextSize(self.employeesName, hpMenuTypography.listPrimary.size)
    setTextSize(self.employeesProfileTitle, hpMenuTypography.sectionTitle.size)
    setTextSize(self.employeesEmpty, hpMenuTypography.listPrimary.size)
    for _, name in ipairs({"employeesExperienceLabel", "employeesReliabilityLabel", "employeesLoyaltyLabel", "employeesExperienceValue", "employeesReliabilityValue", "employeesLoyaltyValue", "employeesBirthLabel", "employeesBirth", "employeesOriginLabel", "employeesOrigin", "employeesRankLabel", "employeesRank", "employeesWageLabel", "employeesWage", "employeesStatusLabel", "employeesStatus", "employeesSpecializationLabel", "employeesSpecialization", "employeesProfileRow1", "employeesProfileRow2", "employeesProfileRow3", "employeesProfileRow4", "employeesProfileRow5", "employeesPermission"}) do
        setTextSize(self[name], hpMenuTypography.bodyText.size)
    end
    for _, prefix in ipairs({"employeesHistoryCareer", "employeesHistoryRecent", "employeesHistoryTotals"}) do
        setTextSize(self[prefix .. "Title"], hpMenuTypography.metricTitle.size)
        for index = 1, 4 do
            if prefix == "employeesHistoryRecent" then
                setTextSize(self[prefix .. "Label" .. index], hpMenuTypography.bodyText.size)
                setTextSize(self[prefix .. "Value" .. index], hpMenuTypography.bodyText.size)
            else
                setTextSize(self[prefix .. "Label" .. index], hpMenuTypography.bodyText.size)
                setTextSize(self[prefix .. "Value" .. index], hpMenuTypography.bodyText.size)
            end
        end
    end

    local pixelFilename = self.app ~= nil and Utils.getFilename("gui/solidPixel.dds", self.app.modDir) or nil
    if pixelFilename ~= nil then
        for _, name in ipairs({"employeesDetailBg", "employeesProfileBg", "employeesHistoryCareerBg", "employeesHistoryRecentBg", "employeesHistoryTotalsBg"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.055, 0.090, 0.060, 0.94)
            end
        end
        for _, name in ipairs({"employeesPortraitBg"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.032, 0.052, 0.036, 0.84)
            end
        end
        for _, name in ipairs({"employeesDetailLine", "employeesProfileLine", "employeesHistoryCareerLine", "employeesHistoryRecentLine", "employeesHistoryTotalsLine"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.61, 0.73, 0.07, 0.86)
            end
        end
        for _, name in ipairs({"employeesExperienceTrack", "employeesReliabilityTrack", "employeesLoyaltyTrack"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.30, 0.34, 0.30, 0.90)
            end
        end
        for _, name in ipairs({"employeesExperienceFill", "employeesReliabilityFill", "employeesLoyaltyFill"}) do
            local element = self[name]
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                element:setImageColor(nil, 0.70, 0.86, 0.12, 1)
            end
        end
        if self.employeesProfileSlider ~= nil then
            GuiOverlay.createOverlay(self.employeesProfileSlider.overlay, pixelFilename)
            GuiOverlay.createOverlay(self.employeesProfileSlider.sliderOverlay, pixelFilename)
            self.employeesProfileSlider.overlay.color = {0.35, 0.35, 0.35, 0.75}
            self.employeesProfileSlider.sliderOverlay.color = {0.70, 0.86, 0.12, 1}
        end
    end

    if self.app ~= nil and self.app.modDir ~= nil then
        if self.employeesPrevIcon ~= nil then self.employeesPrevIcon:setImageFilename(Utils.getFilename("gui/icons/hp_person_nav_left.dds", self.app.modDir)) end
        if self.employeesNextIcon ~= nil then self.employeesNextIcon:setImageFilename(Utils.getFilename("gui/icons/hp_person_nav_right.dds", self.app.modDir)) end
    end

    self:refreshEmployeesNativeGui()
end

function HelperPersonnelMenuPage:clearEmployeesPagerDots()
    for _, dot in ipairs(self.employeesPagerDotsDynamic or {}) do
        if dot ~= nil and dot.delete ~= nil then
            dot:delete()
        end
    end
    self.employeesPagerDotsDynamic = {}
    self.employeesPagerDotCount = 0
end

function HelperPersonnelMenuPage:refreshEmployeesPagerDots(index, count)
    if self.employeesPagerDots == nil or self.employeesPagerDotTemplate == nil then
        return
    end

    if self.employeesPagerDotCount ~= count then
        self:clearEmployeesPagerDots()
        for dotIndex = 1, count do
            local dot = self.employeesPagerDotTemplate:clone(self.employeesPagerDots)
            if dot ~= nil then
                table.insert(self.employeesPagerDotsDynamic, dot)
            end
        end
        self.employeesPagerDotCount = count
    end

    local activeFilename = self.app ~= nil and Utils.getFilename("gui/icons/hp_person_dot_active.dds", self.app.modDir) or nil
    local inactiveFilename = self.app ~= nil and Utils.getFilename("gui/icons/hp_person_dot_inactive.dds", self.app.modDir) or nil
    local centerX = 0.360
    local desiredDotHeight = 0.012
    local desiredDotWidth = hpMenuGetAspectCorrectWidth(desiredDotHeight)
    local maxDotBandWidth = 0.300
    local spacingFactor = 0.75
    local dotWidth = desiredDotWidth
    if count > 1 then
        dotWidth = math.min(desiredDotWidth, maxDotBandWidth / (count + (count - 1) * spacingFactor))
    end
    local dotHeight = hpMenuGetAspectCorrectHeight(dotWidth)
    local dotSpacing = dotWidth * spacingFactor
    local totalDotWidth = count > 0 and (count * dotWidth) + ((count - 1) * dotSpacing) or 0
    local firstDotX = centerX - totalDotWidth * 0.5

    local buttonHeight = 0.050
    local buttonWidth = 0.028125
    local iconHeight = 0.032
    local iconWidth = 0.018
    local buttonGap = 0.024
    local previousX = centerX - totalDotWidth * 0.5 - buttonGap - buttonWidth
    local nextX = centerX + totalDotWidth * 0.5 + buttonGap
    for _, buttonInfo in ipairs({
        {button = self.employeesPrevButton, icon = self.employeesPrevIcon, x = previousX},
        {button = self.employeesNextButton, icon = self.employeesNextIcon, x = nextX}
    }) do
        if buttonInfo.button ~= nil then
            buttonInfo.button:setPosition(buttonInfo.x, -0.001)
        end
        if buttonInfo.icon ~= nil then
            buttonInfo.icon:setPosition((buttonWidth - iconWidth) * 0.5, (buttonHeight - iconHeight) * 0.5)
        end
    end

    for dotIndex, dot in ipairs(self.employeesPagerDotsDynamic or {}) do
        if dot ~= nil then
            dot:setVisible(true)
            dot:setPosition(firstDotX + (dotIndex - 1) * (dotWidth + dotSpacing), (0.048 - dotHeight) * 0.5)
            dot:setSize(dotWidth, dotHeight)
            if activeFilename ~= nil and inactiveFilename ~= nil then
                dot:setImageFilename(dotIndex == index and activeFilename or inactiveFilename)
            end
        end
    end
end

function HelperPersonnelMenuPage:refreshEmployeesProfileRows()
    local rows = self.employeesProfileRows or {}
    local visibleRows = 5
    local maxFirstIndex = math.max(#rows - visibleRows + 1, 1)
    self.employeesProfileFirstIndex = hpMenuClamp(self.employeesProfileFirstIndex or 1, 1, maxFirstIndex)
    if self.employeesProfileSlider ~= nil then
        self.employeesProfileSlider:setMinValue(1)
        self.employeesProfileSlider:setMaxValue(maxFirstIndex, self.employeesProfileFirstIndex)
        self.employeesProfileSlider:setSliderSize(visibleRows, #rows)
        self.employeesProfileSlider:setValue(self.employeesProfileFirstIndex, true, true)
        self.employeesProfileSlider:setVisible(#rows > visibleRows)
    end
    for rowIndex = 1, visibleRows do
        local row = self["employeesProfileRow" .. rowIndex]
        local value = rows[self.employeesProfileFirstIndex + rowIndex - 1]
        hpMenuSetText(row, value or "")
        if row ~= nil then row:setVisible(value ~= nil) end
    end
end

function HelperPersonnelMenuPage:onEmployeesProfileSliderChanged(value)
    self.employeesProfileFirstIndex = math.floor(tonumber(value) or 1)
    self:refreshEmployeesProfileRows()
end

function HelperPersonnelMenuPage:refreshEmployeesNativeGui()
    if self.pageKind ~= "employees" or self.employeesContent == nil then
        return
    end

    local workers = self:getWorkers()
    local count = #workers
    self.workerIndex = hpMenuClamp(self.workerIndex or 1, 1, math.max(count, 1))
    local person = workers[self.workerIndex]
    local hasPerson = person ~= nil
    local canManage = self:canManageCurrentFarm()

    if self.employeesDetail ~= nil then self.employeesDetail:setVisible(hasPerson) end
    if self.employeesProfile ~= nil then self.employeesProfile:setVisible(hasPerson) end
    for _, panel in ipairs({self.employeesHistoryCareer, self.employeesHistoryRecent, self.employeesHistoryTotals}) do
        if panel ~= nil then panel:setVisible(hasPerson) end
    end
    if self.employeesPager ~= nil then self.employeesPager:setVisible(hasPerson) end
    if self.employeesEmpty ~= nil then
        hpMenuSetText(self.employeesEmpty, self:getText("ui_noWorkersDetail", "Keine Mitarbeiter vorhanden"))
        self.employeesEmpty:setVisible(not hasPerson)
    end
    if self.employeesPermission ~= nil then
        hpMenuSetText(self.employeesPermission, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen."))
        self.employeesPermission:setVisible(not canManage)
    end
    for _, button in ipairs({self.employeesPrevButton, self.employeesNextButton}) do
        if button ~= nil and button.setDisabled ~= nil then button:setDisabled(count <= 1) end
    end
    self:refreshEmployeesPagerDots(self.workerIndex, count)

    if not hasPerson then
        return
    end

    local manager = self:getManager()
    local lines = self:getPersonCoreLines(person, false)
    hpMenuSetText(self.employeesName, self:getPersonName(person))
    local birthLabel, birthValue = hpMenuSplitLabelValue(lines[1])
    local originLabel, originValue = hpMenuSplitLabelValue(lines[2])
    local wageLabel, wageValue = hpMenuSplitLabelValue(lines[3])
    local statusLabel, statusValue = hpMenuSplitLabelValue(lines[4])
    local specializationLabel, specializationValue = hpMenuSplitLabelValue(lines[5])
    hpMenuSetText(self.employeesBirthLabel, birthLabel .. ":")
    hpMenuSetText(self.employeesBirth, birthValue)
    hpMenuSetText(self.employeesOriginLabel, originLabel .. ":")
    hpMenuSetText(self.employeesOrigin, originValue)
    hpMenuSetText(self.employeesRankLabel, self:getText("ui_pmRankLabel", "Rang") .. ":")
    hpMenuSetText(self.employeesRank, manager ~= nil and manager.getRankText ~= nil and manager:getRankText(person) or "")
    hpMenuSetText(self.employeesWageLabel, wageLabel .. ":")
    hpMenuSetText(self.employeesWage, wageValue)
    hpMenuSetText(self.employeesStatusLabel, statusLabel .. ":")
    hpMenuSetText(self.employeesStatus, statusValue)
    hpMenuSetText(self.employeesSpecializationLabel, specializationLabel .. ":")
    hpMenuSetText(self.employeesSpecialization, specializationValue)
    hpMenuSetText(self.employeesExperienceLabel, self:getText("ui_pmStatExperience", "Erfahrung"))
    hpMenuSetText(self.employeesReliabilityLabel, self:getText("ui_pmStatReliability", "Zuverlässigkeit"))
    hpMenuSetText(self.employeesLoyaltyLabel, self:getText("ui_pmStatLoyalty", "Loyalität"))
    for _, stat in ipairs({{key = "Experience", value = person.experience or 0}, {key = "Reliability", value = person.reliability or 0}, {key = "Loyalty", value = person.loyalty or 0}}) do
        local value = math.max(0, math.min(100, tonumber(stat.value) or 0))
        hpMenuSetText(self["employees" .. stat.key .. "Value"], string.format("%d %%", math.floor(value + 0.5)))
        local fill = self["employees" .. stat.key .. "Fill"]
        if fill ~= nil and fill.setSize ~= nil then fill:setSize(math.max(0.001, 0.150 * value / 100), 0.009) end
    end
    if self.employeesPortrait ~= nil and self.employeesPortrait.setImageFilename ~= nil then self.employeesPortrait:setImageFilename(self:getPortraitFilename(person)) end

    hpMenuSetText(self.employeesProfileTitle, self:getText("ui_pmProfileHeader", "PROFIL"))
    self.employeesProfileRows = self:getWrappedProfileLines(person, false)
    self:refreshEmployeesProfileRows()
    local columns = self:getWorkerHistoryColumns(person)
    for columnIndex, prefix in ipairs({"employeesHistoryCareer", "employeesHistoryRecent", "employeesHistoryTotals"}) do
        local column = columns[columnIndex] or {}
        hpMenuSetText(self[prefix .. "Title"], column.title or "")
        for rowIndex = 1, 4 do
            local line = column.lines ~= nil and column.lines[rowIndex] or ""
            if prefix == "employeesHistoryRecent" then
                local label, value = hpMenuSplitLabelValue(line)
                hpMenuSetText(self[prefix .. "Label" .. rowIndex], label)
                hpMenuSetText(self[prefix .. "Value" .. rowIndex], value)
            else
                local label, value = hpMenuSplitLabelValue(line)
                hpMenuSetText(self[prefix .. "Label" .. rowIndex], label)
                hpMenuSetText(self[prefix .. "Value" .. rowIndex], value)
            end
        end
    end
end

function HelperPersonnelMenuPage:initializeNativeTrainingGui()
    if self.pageKind ~= "training" then
        return
    end

    self.trainingPagerDotsDynamic = {}
    self.trainingPagerDotCount = 0
    self.trainingRowsDynamic = {}
    self.trainingRowCount = 0

    local setTextSize = function(element, size)
        if element ~= nil and element.setTextSize ~= nil then element:setTextSize(size) end
    end
    setTextSize(self.trainingName, hpMenuTypography.listPrimary.size)
    setTextSize(self.trainingEmpty, hpMenuTypography.listPrimary.size)
    for _, name in ipairs({"trainingExperienceLabel", "trainingReliabilityLabel", "trainingLoyaltyLabel", "trainingExperienceValue", "trainingReliabilityValue", "trainingLoyaltyValue", "trainingBirthLabel", "trainingBirth", "trainingOriginLabel", "trainingOrigin", "trainingRankLabel", "trainingRank", "trainingWageLabel", "trainingWage", "trainingStatusLabel", "trainingStatus", "trainingSpecializationLabel", "trainingSpecialization", "trainingIntroRow1", "trainingIntroRow2", "trainingIntroRow3", "trainingIntroRow4", "trainingIntroRow5", "trainingPermission"}) do
        setTextSize(self[name], hpMenuTypography.bodyText.size)
    end
    for _, name in ipairs({"trainingCategoryHeader", "trainingProgressHeader", "trainingCostHeader", "trainingAdjustmentHeader"}) do
        setTextSize(self[name], hpMenuTypography.metricTitle.size)
    end

    local pixelFilename = self.app ~= nil and Utils.getFilename("gui/solidPixel.dds", self.app.modDir) or nil
    if pixelFilename ~= nil then
        for _, name in ipairs({"trainingDetailBg", "trainingIntroBg", "trainingColumnLeftBg", "trainingColumnRightBg"}) do
            local element = self[name]
            if element ~= nil then element:setImageFilename(pixelFilename); element:setImageColor(nil, 0.055, 0.090, 0.060, 0.94) end
        end
        for _, name in ipairs({"trainingPortraitBg"}) do
            local element = self[name]
            if element ~= nil then element:setImageFilename(pixelFilename); element:setImageColor(nil, 0.032, 0.052, 0.036, 0.84) end
        end
        for _, name in ipairs({"trainingDetailLine", "trainingIntroLine", "trainingTableLine"}) do
            local element = self[name]
            if element ~= nil then element:setImageFilename(pixelFilename); element:setImageColor(nil, 0.61, 0.73, 0.07, 0.86) end
        end
        for _, name in ipairs({"trainingExperienceTrack", "trainingReliabilityTrack", "trainingLoyaltyTrack"}) do
            local element = self[name]
            if element ~= nil then element:setImageFilename(pixelFilename); element:setImageColor(nil, 0.30, 0.34, 0.30, 0.90) end
        end
        for _, name in ipairs({"trainingExperienceFill", "trainingReliabilityFill", "trainingLoyaltyFill"}) do
            local element = self[name]
            if element ~= nil then element:setImageFilename(pixelFilename); element:setImageColor(nil, 0.70, 0.86, 0.12, 1) end
        end
    end
    if self.app ~= nil and self.app.modDir ~= nil then
        if self.trainingPrevIcon ~= nil then self.trainingPrevIcon:setImageFilename(Utils.getFilename("gui/icons/hp_person_nav_left.dds", self.app.modDir)) end
        if self.trainingNextIcon ~= nil then self.trainingNextIcon:setImageFilename(Utils.getFilename("gui/icons/hp_person_nav_right.dds", self.app.modDir)) end
    end
    self:refreshTrainingNativeGui()
end

function HelperPersonnelMenuPage:clearTrainingPagerDots()
    for _, dot in ipairs(self.trainingPagerDotsDynamic or {}) do if dot ~= nil and dot.delete ~= nil then dot:delete() end end
    self.trainingPagerDotsDynamic = {}
    self.trainingPagerDotCount = 0
end

function HelperPersonnelMenuPage:refreshTrainingPagerDots(index, count)
    if self.trainingPagerDots == nil or self.trainingPagerDotTemplate == nil then return end
    if self.trainingPagerDotCount ~= count then
        self:clearTrainingPagerDots()
        for _ = 1, count do
            local dot = self.trainingPagerDotTemplate:clone(self.trainingPagerDots)
            if dot ~= nil then table.insert(self.trainingPagerDotsDynamic, dot) end
        end
        self.trainingPagerDotCount = count
    end
    local activeFilename = self.app ~= nil and Utils.getFilename("gui/icons/hp_person_dot_active.dds", self.app.modDir) or nil
    local inactiveFilename = self.app ~= nil and Utils.getFilename("gui/icons/hp_person_dot_inactive.dds", self.app.modDir) or nil
    local centerX = 0.360
    local desiredDotHeight = 0.012
    local desiredDotWidth = hpMenuGetAspectCorrectWidth(desiredDotHeight)
    local maxDotBandWidth = 0.300
    local spacingFactor = 0.75
    local dotWidth = desiredDotWidth
    if count > 1 then
        dotWidth = math.min(desiredDotWidth, maxDotBandWidth / (count + (count - 1) * spacingFactor))
    end
    local dotHeight = hpMenuGetAspectCorrectHeight(dotWidth)
    local dotSpacing = dotWidth * spacingFactor
    local totalDotWidth = count > 0 and (count * dotWidth) + ((count - 1) * dotSpacing) or 0
    local firstDotX = centerX - totalDotWidth * 0.5

    local buttonHeight, buttonWidth = 0.050, 0.028125
    local iconHeight, iconWidth = 0.032, 0.018
    local buttonGap = 0.024
    local previousX = centerX - totalDotWidth * 0.5 - buttonGap - buttonWidth
    local nextX = centerX + totalDotWidth * 0.5 + buttonGap
    for _, buttonInfo in ipairs({
        {button = self.trainingPrevButton, icon = self.trainingPrevIcon, x = previousX},
        {button = self.trainingNextButton, icon = self.trainingNextIcon, x = nextX}
    }) do
        if buttonInfo.button ~= nil then buttonInfo.button:setPosition(buttonInfo.x, -0.001) end
        if buttonInfo.icon ~= nil then buttonInfo.icon:setPosition((buttonWidth - iconWidth) * 0.5, (buttonHeight - iconHeight) * 0.5) end
    end
    for dotIndex, dot in ipairs(self.trainingPagerDotsDynamic or {}) do
        dot:setVisible(true)
        dot:setPosition(firstDotX + (dotIndex - 1) * (dotWidth + dotSpacing), (0.048 - dotHeight) * 0.5)
        dot:setSize(dotWidth, dotHeight)
        if activeFilename ~= nil and inactiveFilename ~= nil then dot:setImageFilename(dotIndex == index and activeFilename or inactiveFilename) end
    end
end

function HelperPersonnelMenuPage:ensureTrainingRows(count)
    self.trainingRowsDynamic = {}
    for index = 1, count do
        local row = self["trainingRow" .. index]
        if row ~= nil then
            table.insert(self.trainingRowsDynamic, row)
        end
    end
    self.trainingRowCount = #self.trainingRowsDynamic
end

function HelperPersonnelMenuPage:refreshTrainingRows(person)
    local manager = self:getManager()
    local rows = self:getTrainingCategoryRows(person)
    self:ensureTrainingRows(#rows)
    local workerInTraining = manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person)
    for index, row in ipairs(rows) do
        local element = self.trainingRowsDynamic[index]
        if element ~= nil then
            local selected = self.selectedTrainingCategoryKey == row.key
            local selectable = not workerInTraining and (row.acquired or row.learned or row.available == true)
            local background = element:getDescendantByName("trainingRowBg")
            local track = element:getDescendantByName("trainingRowTrack")
            local fill = element:getDescendantByName("trainingRowFill")
            local name = element:getDescendantByName("trainingRowName")
            local progress = element:getDescendantByName("trainingRowProgress")
            local cost = element:getDescendantByName("trainingRowCost")
            local adjustment = element:getDescendantByName("trainingRowAdjustment")
            element.trainingKey = row.key
            element:setVisible(true)
            if background ~= nil then
                background:setImageFilename(Utils.getFilename("gui/solidPixel.dds", self.app.modDir))
                background:setImageColor(nil, 0, 0, 0, 0)
            end
            if track ~= nil then track:setImageFilename(Utils.getFilename("gui/solidPixel.dds", self.app.modDir)); track:setImageColor(nil, 0.30, 0.34, 0.30, 0.90) end
            if fill ~= nil then fill:setImageFilename(Utils.getFilename("gui/solidPixel.dds", self.app.modDir)); fill:setImageColor(nil, 0.70, 0.86, 0.12, (selectable or row.trainingActive or row.acquired) and 1 or 0.48); fill:setSize(math.max(0.001, 0.215 * row.progress / 100), 0.009) end
            if name ~= nil and name.setTextColor ~= nil then name:setTextColor(1, 1, 1, selectable and 1 or 0.64) end
            if cost ~= nil and cost.setTextColor ~= nil then cost:setTextColor(1, 1, 1, selectable and 1 or 0.64) end
            if progress ~= nil and progress.setTextColor ~= nil then progress:setTextColor(0.70, 0.86, 0.12, selectable and 1 or 0.58) end
            if adjustment ~= nil and adjustment.setTextColor ~= nil then adjustment:setTextColor(0.78, 0.80, 0.78, selectable and 1 or 0.58) end
            hpMenuSetText(name, row.name)
            hpMenuSetText(progress, row.trainingActive and self:getText("ui_pmTrainingRunning", "laufende Schulung") or string.format("%d %%", math.floor(row.progress + 0.5)))
            local costText, adjustmentText = "", ""
            if row.acquired then costText = self:getText("ui_pmSpecializationActive", "aktiv")
            elseif row.learned then costText = self:getText("ui_pmSpecializationInactive", "gelernt, inaktiv")
            elseif row.available == true then
                costText = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(row.cost) or string.format("%d €", math.floor(row.cost + 0.5))
                local difference = math.abs(row.costDifference)
                local amount = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(difference) or string.format("%d €", math.floor(difference + 0.5))
                adjustmentText = row.costDifference > 0 and "+" .. amount or (row.costDifference < 0 and "-" .. amount or (manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(0) or "0 €"))
            else costText = self:getText("ui_pmTrainingNoPlaces", "aktuell keine Plätze frei") end
            hpMenuSetText(cost, costText)
            hpMenuSetText(adjustment, adjustmentText)
        end
    end
    for index = #rows + 1, 8 do
        local element = self["trainingRow" .. index]
        if element ~= nil then
            element:setVisible(false)
        end
    end
end

function HelperPersonnelMenuPage:refreshTrainingNativeGui()
    if self.pageKind ~= "training" or self.trainingContent == nil then return end
    local workers, count = self:getWorkers(), 0
    count = #workers
    self.workerIndex = hpMenuClamp(self.workerIndex or 1, 1, math.max(count, 1))
    local person, hasPerson = workers[self.workerIndex], workers[self.workerIndex] ~= nil
    if self.trainingDetail ~= nil then self.trainingDetail:setVisible(hasPerson) end
    if self.trainingIntro ~= nil then self.trainingIntro:setVisible(hasPerson) end
    if self.trainingTable ~= nil then self.trainingTable:setVisible(hasPerson) end
    if self.trainingPager ~= nil then self.trainingPager:setVisible(hasPerson) end
    if self.trainingEmpty ~= nil then hpMenuSetText(self.trainingEmpty, self:getText("ui_noWorkersDetail", "Keine Mitarbeiter vorhanden")); self.trainingEmpty:setVisible(not hasPerson) end
    if self.trainingPermission ~= nil then hpMenuSetText(self.trainingPermission, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen.")); self.trainingPermission:setVisible(not self:canManageCurrentFarm()) end
    for _, button in ipairs({self.trainingPrevButton, self.trainingNextButton}) do if button ~= nil and button.setDisabled ~= nil then button:setDisabled(count <= 1) end end
    self:refreshTrainingPagerDots(self.workerIndex, count)
    if not hasPerson then return end
    if self.selectedTrainingWorkerId ~= person.id then self.selectedTrainingWorkerId = person.id; self.selectedTrainingCategoryKey = nil end
    local manager, lines = self:getManager(), self:getPersonCoreLines(person, false)
    local birthLabel, birthValue = hpMenuSplitLabelValue(lines[1])
    local originLabel, originValue = hpMenuSplitLabelValue(lines[2])
    local wageLabel, wageValue = hpMenuSplitLabelValue(lines[3])
    local statusLabel, statusValue = hpMenuSplitLabelValue(lines[4])
    local specializationLabel, specializationValue = hpMenuSplitLabelValue(lines[5])
    hpMenuSetText(self.trainingName, self:getPersonName(person))
    hpMenuSetText(self.trainingBirthLabel, birthLabel .. ":"); hpMenuSetText(self.trainingBirth, birthValue)
    hpMenuSetText(self.trainingOriginLabel, originLabel .. ":"); hpMenuSetText(self.trainingOrigin, originValue)
    hpMenuSetText(self.trainingRankLabel, self:getText("ui_pmRankLabel", "Rang") .. ":"); hpMenuSetText(self.trainingRank, manager ~= nil and manager.getRankText ~= nil and manager:getRankText(person) or "")
    hpMenuSetText(self.trainingWageLabel, wageLabel .. ":"); hpMenuSetText(self.trainingWage, wageValue)
    hpMenuSetText(self.trainingStatusLabel, statusLabel .. ":"); hpMenuSetText(self.trainingStatus, statusValue)
    hpMenuSetText(self.trainingSpecializationLabel, specializationLabel .. ":"); hpMenuSetText(self.trainingSpecialization, specializationValue)
    for _, key in ipairs({"Experience", "Reliability", "Loyalty"}) do
        local value = math.max(0, math.min(100, tonumber(person[string.lower(key)] or 0) or 0))
        hpMenuSetText(self["training" .. key .. "Label"], self:getText("ui_pmStat" .. key, key)); hpMenuSetText(self["training" .. key .. "Value"], string.format("%d %%", math.floor(value + 0.5)))
        local fill = self["training" .. key .. "Fill"]
        if fill ~= nil then fill:setSize(math.max(0.001, 0.150 * value / 100), 0.009) end
    end
    if self.trainingPortrait ~= nil then self.trainingPortrait:setImageFilename(self:getPortraitFilename(person)) end
    local intro = self:getText("ui_pmTrainingIntro", "Spezialisierungen verbessern die Leistung in der passenden Lernkategorie. Schulungen beginnen nur am Monatsanfang, kosten Geld und machen den Mitarbeiter bis Monatsende nicht verfügbar. Fortschritt wird nach Abschluss gutgeschrieben. Pro Landwirtschaftsjahr von März bis Februar ist nur eine Schulung möglich. Gelernte Spezialisierungen bleiben erhalten, aber höchstens zwei Boni sind aktiv. Beide Plätze können ruhen. Eine gelernte inaktive Spezialisierung kann je Mitarbeiter nur einmal pro Landwirtschaftsjahr eingeloggt werden.")
    local introLines = self:getWrappedHistoryLines(intro, hpMenuTypography.bodyText.size, 0.688, 120)
    for index = 1, 5 do local element = self["trainingIntroRow" .. index]; hpMenuSetText(element, introLines[index] or ""); if element ~= nil then element:setVisible(introLines[index] ~= nil) end end
    hpMenuSetText(self.trainingCategoryHeader, hpMenuUpper(self:getText("ui_pmTrainingCategoryHeader", "Lernkategorie")))
    self:refreshTrainingRows(person)
end

function HelperPersonnelMenuPage:initializeNativeOverviewGui()
    if self.pageKind ~= "overview" then
        return
    end

    for _, prefix in ipairs({"overviewMetricEmployees", "overviewMetricAvailable", "overviewMetricApplicants", "overviewMetricReputation"}) do
        for _, suffix in ipairs({"Label", "Value"}) do
            local element = self[prefix .. suffix]
            if element ~= nil then
                element.textAlignment = RenderText.ALIGN_LEFT
                element.textOriginalAlignment = RenderText.ALIGN_LEFT
            end
        end
    end
    for _, element in ipairs({self.overviewActiveEmpty, self.overviewHistoryTitle, self.overviewMonthlyTitle, self.overviewLifetimeTitle}) do
        if element ~= nil then
            element.textAlignment = RenderText.ALIGN_LEFT
            element.textOriginalAlignment = RenderText.ALIGN_LEFT
        end
    end

    local setTextSize = function(element, size)
        if element ~= nil and element.setTextSize ~= nil then
            element:setTextSize(size)
        end
    end
    for _, prefix in ipairs({"overviewMetricEmployees", "overviewMetricAvailable", "overviewMetricApplicants", "overviewMetricReputation"}) do
        setTextSize(self[prefix .. "Label"], hpMenuTypography.metricTitle.size)
        setTextSize(self[prefix .. "Value"], hpMenuTypography.metricValue.size)
    end
    setTextSize(self.overviewActiveTitle, hpMenuTypography.sectionTitle.size)
    setTextSize(self.overviewActiveEmpty, hpMenuTypography.bodyText.size)
    setTextSize(self.overviewHistoryTitle, hpMenuTypography.sectionTitle.size)
    setTextSize(self.overviewMonthlyTitle, hpMenuTypography.sectionTitle.size)
    setTextSize(self.overviewLifetimeTitle, hpMenuTypography.sectionTitle.size)
    for rowIndex = 1, 6 do
        for _, suffix in ipairs({"Name", "Status", "Activity"}) do
            local element = self["overviewEmployee" .. suffix .. rowIndex]
            if element ~= nil then
                element.textAlignment = RenderText.ALIGN_LEFT
                element.textOriginalAlignment = RenderText.ALIGN_LEFT
            end
        end
        setTextSize(self["overviewEmployeeName" .. rowIndex], hpMenuTypography.listPrimary.size)
        setTextSize(self["overviewEmployeeStatus" .. rowIndex], hpMenuTypography.bodyText.size)
        setTextSize(self["overviewEmployeeActivity" .. rowIndex], hpMenuTypography.bodyText.size)
    end
    for rowIndex = 1, 3 do
        for _, suffix in ipairs({"Primary", "Secondary"}) do
            local history = self["overviewHistory" .. suffix .. rowIndex]
            if history ~= nil then
                history.textAlignment = RenderText.ALIGN_LEFT
                history.textOriginalAlignment = RenderText.ALIGN_LEFT
            end
        end
        setTextSize(self["overviewHistoryPrimary" .. rowIndex], 0.0102)
        setTextSize(self["overviewHistorySecondary" .. rowIndex], 0.0090)
    end
    for rowIndex = 1, 7 do
        for _, prefix in ipairs({"overviewMonthly", "overviewLifetime"}) do
            local label = self[prefix .. "Label" .. rowIndex]
            if label ~= nil and label.setTextColor ~= nil then
                label:setTextColor(0.61, 0.73, 0.07, 1)
                label.textAlignment = RenderText.ALIGN_LEFT
                label.textOriginalAlignment = RenderText.ALIGN_LEFT
            end
            local value = self[prefix .. "Value" .. rowIndex]
            if value ~= nil then
                value.textAlignment = RenderText.ALIGN_RIGHT
                value.textOriginalAlignment = RenderText.ALIGN_RIGHT
            end
            setTextSize(label, hpMenuTypography.bodyText.size)
            setTextSize(value, hpMenuTypography.bodyText.size)
        end
    end

    local colors = hpMenuDesign ~= nil and hpMenuDesign.colors or {}
    local setImageColor = function(element, color)
        element:setImageColor(nil, color[1], color[2], color[3], color[4])
    end
    local pixelFilename = self.app ~= nil and Utils.getFilename("gui/solidPixel.dds", self.app.modDir) or nil
    if pixelFilename ~= nil then
        for _, name in ipairs({
            "overviewMetricEmployeesBg", "overviewMetricAvailableBg", "overviewMetricApplicantsBg", "overviewMetricReputationBg"
        }) do
            local element = self:getDescendantByName(name)
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                setImageColor(element, colors.metric or {0.075, 0.115, 0.075, 0.94})
            end
        end
        for _, name in ipairs({
            "overviewActiveBg", "overviewHistoryBg", "overviewMonthlyBg", "overviewLifetimeBg"
        }) do
            local element = self:getDescendantByName(name)
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                setImageColor(element, colors.panel or {0.055, 0.090, 0.060, 0.94})
            end
        end
        for _, name in ipairs({
            "overviewEmployeeRowBg1", "overviewEmployeeRowBg2", "overviewEmployeeRowBg3",
            "overviewEmployeeRowBg4", "overviewEmployeeRowBg5", "overviewEmployeeRowBg6"
        }) do
            local element = self:getDescendantByName(name)
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                setImageColor(element, colors.row or {0.032, 0.052, 0.036, 0.84})
            end
        end
        for _, name in ipairs({
            "overviewMetricEmployeesLine", "overviewMetricAvailableLine", "overviewMetricApplicantsLine", "overviewMetricReputationLine",
            "overviewActiveLine", "overviewHistoryLine", "overviewMonthlyLine", "overviewLifetimeLine",
            "overviewHistoryMarker1", "overviewHistoryMarker2", "overviewHistoryMarker3"
        }) do
            local element = self:getDescendantByName(name)
            if element ~= nil then
                element:setImageFilename(pixelFilename)
                setImageColor(element, colors.accent or {0.70, 0.86, 0.12, 1})
            end
        end
        for _, slider in ipairs({self.overviewEmployeeSlider, self.overviewHistorySlider}) do
            if slider ~= nil then
                GuiOverlay.createOverlay(slider.overlay, pixelFilename)
                GuiOverlay.createOverlay(slider.sliderOverlay, pixelFilename)
                slider.overlay.color = {0.35, 0.35, 0.35, 0.75}
                slider.sliderOverlay.color = {0.70, 0.86, 0.12, 1}
            end
        end
    end

    self:refreshOverviewNativeGui()
end

function HelperPersonnelMenuPage:onFrameClose()
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    HelperPersonnelViewBase:superClass().onFrameClose(self)
end

function HelperPersonnelMenuPage:update(dt)
    HelperPersonnelMenuPage:superClass().update(self, dt)

    if (self.personPagerLayoutRefreshPending or 0) > 0 and self:isCurrentMenuPage() == true then
        self.personPagerLayoutRefreshPending = self.personPagerLayoutRefreshPending - 1
        if self.pageKind == "applicants" then
            self:refreshApplicantsNativeGui()
        elseif self.pageKind == "employees" then
            self:refreshEmployeesNativeGui()
        end
    end

    if self.pageKind ~= "overview" or self:isCurrentMenuPage() ~= true then
        return
    end

    self.overviewRefreshElapsed = (self.overviewRefreshElapsed or 0) + (tonumber(dt) or 0)
    if self.overviewRefreshElapsed >= 1000 then
        self.overviewRefreshElapsed = 0
        self:refreshOverviewNativeGui()
    end
end

function HelperPersonnelMenuPage:refresh()
    local workers = self:getWorkers()
    local applicants = self:getApplicants()

    self.workerIndex = hpMenuClamp(self.workerIndex or 1, 1, math.max(#workers, 1))
    self.applicantIndex = hpMenuClamp(self.applicantIndex or 1, 1, math.max(#applicants, 1))
    self:applyPageKind()

    if self.salaryRaiseDialogOpen == true then
        local selectedRow = self.salaryRaiseRows[self.salaryRaiseSelectedIndex or 1]
        local selectedWorkerId = selectedRow ~= nil and tonumber(selectedRow.workerId) or nil
        self.salaryRaiseRows = self:buildSalaryRaiseRows()
        self.salaryRaiseSelectedIndex = 1
        if selectedWorkerId ~= nil then
            for index, row in ipairs(self.salaryRaiseRows) do
                if tonumber(row.workerId) == selectedWorkerId then
                    self.salaryRaiseSelectedIndex = index
                    break
                end
            end
        end
        self:ensureSalaryRaiseSelectionVisible()
    end

    if self.pageKind == "overview" then
        self:refreshOverviewNativeGui()
    elseif self.pageKind == "applicants" then
        self:refreshApplicantsNativeGui()
    elseif self.pageKind == "employees" then
        self:refreshEmployeesNativeGui()
    elseif self.pageKind == "training" then
        self:refreshTrainingNativeGui()
    end

    self:updateButtons()
end

function HelperPersonnelMenuPage:refreshOverviewNativeGui()
    if self.pageKind ~= "overview" or self.overviewEmployeeRow1 == nil then
        return
    end

    local manager = self:getManager()
    local workers = self:getWorkers()
    local applicants = self:getApplicants()
    local counts = self:getWorkerSummaryCounts(workers)
    self.overviewNativeActiveWorkers = self:getActiveWorkerEntries(workers)

    local historyEvents, period, year = {}, nil, nil
    if manager ~= nil and manager.getMonthlyOverviewChanges ~= nil then
        historyEvents, period, year = manager:getMonthlyOverviewChanges()
    elseif manager ~= nil and manager.getMonthlyOverviewChangeLines ~= nil then
        local lines
        lines, period, year = manager:getMonthlyOverviewChangeLines()
        for _, line in ipairs(lines or {}) do
            table.insert(historyEvents, {title = line, detail = "", kind = "neutral"})
        end
    end
    self.overviewNativeHistoryEvents = historyEvents or {}

    hpMenuSetText(self.overviewMetricEmployeesLabel, hpMenuUpper(self:getText("ui_monthlyRowEmployees", "Mitarbeiter")))
    hpMenuSetText(self.overviewMetricEmployeesValue, counts.total)
    hpMenuSetText(self.overviewMetricAvailableLabel, hpMenuUpper(self:getText("ui_monthlyRowAvailable", "Verfügbar")))
    hpMenuSetText(self.overviewMetricAvailableValue, counts.available)
    hpMenuSetText(self.overviewMetricApplicantsLabel, hpMenuUpper(self:getText("ui_monthlyRowApplicants", "Bewerber")))
    hpMenuSetText(self.overviewMetricApplicantsValue, #applicants)

    local reputation = manager ~= nil and (manager.getEmployerReputation ~= nil and manager:getEmployerReputation() or manager.employerReputation) or 0
    local reputationKey = manager ~= nil and (manager.getEmployerReputationLevelKey ~= nil and manager:getEmployerReputationLevelKey() or "ui_reputationSolid") or "ui_reputationSolid"
    local reputationLabel = string.gsub(self:getText("ui_overviewReputation", "Arbeitgeberansehen: %d/100 (%s)"), "%s*:?%s*%%d.*$", "")
    hpMenuSetText(self.overviewMetricReputationLabel, hpMenuUpper(reputationLabel))
    hpMenuSetText(self.overviewMetricReputationValue, string.format("%d/100 (%s)", tonumber(reputation) or 0, self:getText(reputationKey, "solide")))

    hpMenuSetText(self.overviewActiveTitle, self:getText("ui_workerStockHeader", "MITARBEITER IM EINSATZ"))
    hpMenuSetText(self.overviewActiveEmpty, self:getText("ui_noActiveWorkers", "Gerade ist kein Mitarbeiter im Einsatz."))
    if self.overviewActiveEmpty ~= nil then
        self.overviewActiveEmpty:setVisible(#self.overviewNativeActiveWorkers == 0)
    end
    hpMenuSetText(self.overviewHistoryTitle, self:getOverviewHistoryHeader(manager, period, year))
    hpMenuSetText(self.overviewMonthlyTitle, self:getText("ui_monthlyReportHeader", "MONATSBERICHT"))
    hpMenuSetText(self.overviewLifetimeTitle, self:getText("ui_pmOverviewOverallHeader", "GESAMT"))

    self:setOverviewReportRows("overviewMonthly", self:getMonthlyReportRows(counts, applicants, workers))
    self:setOverviewReportRows("overviewLifetime", self:getLifetimeReportRows(manager))
    self:refreshOverviewEmployeeRows()
    self:refreshOverviewHistoryRows()
end

function HelperPersonnelMenuPage:setOverviewReportRows(prefix, rows)
    for index = 1, 7 do
        local row = rows[index] or {}
        hpMenuSetText(self[prefix .. "Label" .. index], row.label)
        hpMenuSetText(self[prefix .. "Value" .. index], row.value)
    end
end

function HelperPersonnelMenuPage:refreshOverviewEmployeeRows()
    local entries = self.overviewNativeActiveWorkers or {}
    local visibleRows = 6
    local maxFirstIndex = math.max(#entries - visibleRows + 1, 1)
    self.overviewEmployeeFirstIndex = hpMenuClamp(self.overviewEmployeeFirstIndex or 1, 1, maxFirstIndex)

    if self.overviewEmployeeSlider ~= nil then
        self.overviewEmployeeSlider:setMinValue(1)
        self.overviewEmployeeSlider:setMaxValue(maxFirstIndex, self.overviewEmployeeFirstIndex)
        self.overviewEmployeeSlider:setSliderSize(visibleRows, #entries)
        self.overviewEmployeeSlider:setValue(self.overviewEmployeeFirstIndex, true, true)
        self.overviewEmployeeSlider:setVisible(#entries > visibleRows)
    end

    local manager = self:getManager()
    for rowIndex = 1, visibleRows do
        local row = self["overviewEmployeeRow" .. rowIndex]
        local entry = entries[self.overviewEmployeeFirstIndex + rowIndex - 1]
        local worker = entry ~= nil and entry.worker or nil
        if row ~= nil then
            row:setVisible(worker ~= nil)
        end
        if worker ~= nil then
            hpMenuSetText(self["overviewEmployeeName" .. rowIndex], manager ~= nil and manager:getFullName(worker) or "")
            local status, activity = self:getActiveWorkerOverviewLines(worker)
            hpMenuSetText(self["overviewEmployeeStatus" .. rowIndex], status)
            hpMenuSetText(self["overviewEmployeeActivity" .. rowIndex], activity)
            local portrait = self["overviewEmployeePortrait" .. rowIndex]
            if portrait ~= nil and portrait.setImageFilename ~= nil then
                portrait:setImageFilename(self:getPortraitFilename(worker))
            end
        end
    end
end

function HelperPersonnelMenuPage:refreshOverviewHistoryRows()
    local events = self.overviewNativeHistoryEvents or {}
    local visibleRows = 3
    local maxFirstIndex = math.max(#events - visibleRows + 1, 1)
    self.overviewHistoryFirstIndex = hpMenuClamp(self.overviewHistoryFirstIndex or 1, 1, maxFirstIndex)

    if self.overviewHistorySlider ~= nil then
        self.overviewHistorySlider:setMinValue(1)
        self.overviewHistorySlider:setMaxValue(maxFirstIndex, self.overviewHistoryFirstIndex)
        self.overviewHistorySlider:setSliderSize(visibleRows, #events)
        self.overviewHistorySlider:setValue(self.overviewHistoryFirstIndex, true, true)
        self.overviewHistorySlider:setVisible(#events > visibleRows)
    end

    for rowIndex = 1, visibleRows do
        local event = events[self.overviewHistoryFirstIndex + rowIndex - 1]
        local container = self["overviewHistoryEvent" .. rowIndex]
        hpMenuSetText(self["overviewHistoryPrimary" .. rowIndex], event ~= nil and event.title or "")
        hpMenuSetText(self["overviewHistorySecondary" .. rowIndex], event ~= nil and event.detail or "")
        if container ~= nil then
            container:setVisible(event ~= nil)
        end
        local marker = self["overviewHistoryMarker" .. rowIndex]
        if marker ~= nil and marker.setImageColor ~= nil then
            if event ~= nil and event.kind == "negative" then
                marker:setImageColor(nil, 0.95, 0.56, 0.22, 1)
            elseif event ~= nil and event.kind == "reputation" then
                marker:setImageColor(nil, 0.72, 0.78, 0.85, 1)
            else
                marker:setImageColor(nil, 0.70, 0.86, 0.12, 1)
            end
        end
    end
end

function HelperPersonnelMenuPage:onOverviewEmployeeSliderChanged(value)
    self.overviewEmployeeFirstIndex = math.floor(tonumber(value) or 1)
    self:refreshOverviewEmployeeRows()
end

function HelperPersonnelMenuPage:onOverviewHistorySliderChanged(value)
    self.overviewHistoryFirstIndex = math.floor(tonumber(value) or 1)
    self:refreshOverviewHistoryRows()
end

function HelperPersonnelMenuPage:canManageCurrentFarm()
    if self.app ~= nil and self.app.canManageCurrentFarm ~= nil then
        return self.app:canManageCurrentFarm() == true
    end

    return true
end

function HelperPersonnelMenuPage:getCurrentEntries()
    if self.pageKind == "applicants" then
        return self:getApplicants(), true
    elseif self.pageKind == "settings" then
        return {}, false
    end

    return self:getWorkers(), false
end

function HelperPersonnelMenuPage:getCurrentPerson()
    local entries, isApplicant = self:getCurrentEntries()
    if #entries == 0 then
        return nil, isApplicant, entries
    end

    local index = isApplicant and self.applicantIndex or self.workerIndex
    index = hpMenuClamp(index or 1, 1, #entries)
    if isApplicant then
        self.applicantIndex = index
    else
        self.workerIndex = index
    end

    return entries[index], isApplicant, entries
end

function HelperPersonnelMenuPage:createButtonInfo()
    self.btnClose = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_button_back", "Zurück"),
        callback = function()
            return self:onClickBack()
        end
    }
    self.btnPrevTab = {
        inputAction = InputAction.MENU_PAGE_PREV,
        text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü"),
        callback = function()
            return self:onClickPagePrevious()
        end
    }
    self.btnNextTab = {
        inputAction = InputAction.MENU_PAGE_NEXT,
        text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü"),
        callback = function()
            return self:onClickPageNext()
        end
    }
    self.btnPrevPerson = {
        inputAction = hpMenuGetInputAction("HP_SELECT_LEFT", nil),
        text = self:getText("ui_pmMenuPrevPerson", "Vorige Person"),
        callback = function()
            return self:onClickPreviousPerson()
        end
    }
    self.btnNextPerson = {
        inputAction = hpMenuGetInputAction("HP_SELECT_RIGHT", nil),
        text = self:getText("ui_pmMenuNextPerson", "Nächste Person"),
        callback = function()
            return self:onClickNextPerson()
        end
    }
    self.btnPrimary = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getPrimaryButtonText(),
        callback = function()
            return self:onClickPrimaryAction()
        end
    }
    self.btnTransport = {
        inputAction = hpMenuGetInputAction("HP_TRANSPORT_MANAGE", nil),
        text = self:getTransportButtonText(),
        callback = function()
            return self:onClickTransportAction()
        end
    }
    self.btnSalary = {
        inputAction = hpMenuGetInputAction("HP_SALARY_RAISE_MANAGE", nil),
        text = self:getSalaryButtonText(),
        callback = function()
            return self:onClickSalaryAction()
        end
    }
    self.btnEmergencyRelease = {
        inputAction = hpMenuGetInputAction("HP_EMERGENCY_RELEASE_WORKER", nil),
        text = self:getText("ui_button_emergency_release_worker", "Notfallfreigabe"),
        callback = function()
            return self:onClickEmergencyReleaseWorker()
        end
    }
    self.btnTransportDialogCancel = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_transportPriorityCancel", "Abbrechen"),
        callback = function()
            return self:closeTransportPriorityDialog()
        end
    }
    self.btnTransportDialogUp = {
        inputAction = hpMenuGetInputAction("HP_SELECT_LEFT", nil),
        text = self:getText("ui_transportPriorityMoveUp", "Nach oben"),
        callback = function()
            return self:moveTransportPriorityRow(-1)
        end
    }
    self.btnTransportDialogDown = {
        inputAction = hpMenuGetInputAction("HP_SELECT_RIGHT", nil),
        text = self:getText("ui_transportPriorityMoveDown", "Nach unten"),
        callback = function()
            return self:moveTransportPriorityRow(1)
        end
    }
    self.btnTransportDialogToggle = {
        inputAction = hpMenuGetInputAction("HP_SELECT_CONFIRM", nil),
        text = self:getText("ui_transportPriorityToggle", "Aktivieren/Deaktivieren"),
        callback = function()
            return self:toggleTransportPriorityRow()
        end
    }
    self.btnTransportDialogApply = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_transportPriorityApply", "Übernehmen"),
        callback = function()
            return self:applyTransportPriorityDialog()
        end
    }
    self.btnSalaryDialogCancel = {
        inputAction = InputAction.MENU_BACK,
        text = self:getText("ui_transportPriorityCancel", "Abbrechen"),
        callback = function()
            return self:closeSalaryRaiseDialog()
        end
    }
    self.btnSalaryDialogDecline = {
        inputAction = hpMenuGetInputAction("HP_SELECT_CONFIRM", nil),
        text = self:getText("ui_button_raise_decline", "Forderung ablehnen"),
        callback = function()
            return self:decideSalaryRaiseRequest(false)
        end
    }
    self.btnSalaryDialogAccept = {
        inputAction = InputAction.MENU_ACCEPT,
        text = self:getText("ui_button_raise_grant", "Gehaltserhöhung gewähren"),
        callback = function()
            return self:decideSalaryRaiseRequest(true)
        end
    }
end

function HelperPersonnelMenuPage:getPrimaryButtonText()
    if self.pageKind == "applicants" then
        return self:getText("ui_button_hire", "Einstellen")
    elseif self.pageKind == "training" then
        return self:getText("ui_button_train", "Schulen")
    elseif self.pageKind == "settings" then
        return self:getText("ui_hpSetting_toggle", "Umschalten")
    end

    return self:getText("ui_button_fire", "Entlassen")
end

function HelperPersonnelMenuPage:getTransportButtonText()
    return self:getText("ui_button_transport_manage_long", "Transport")
end

function HelperPersonnelMenuPage:getSalaryButtonText()
    return self:getText("ui_button_salary_manage_long", "Gehalt")
end

function HelperPersonnelMenuPage:updateButtons()
    if self.btnClose == nil then
        self:createButtonInfo()
    end

    if self.salaryRaiseDialogOpen == true then
        local row = self.salaryRaiseRows[self.salaryRaiseSelectedIndex or 1]
        self.btnSalaryDialogCancel.text = self:getText("ui_transportPriorityCancel", "Abbrechen")
        self.btnSalaryDialogDecline.text = self:getText("ui_button_raise_decline", "Forderung ablehnen")
        self.btnSalaryDialogAccept.text = self:getText("ui_button_raise_grant", "Gehaltserhöhung gewähren")
        self.btnSalaryDialogDecline.disabled = row == nil or not self:canManageCurrentFarm()
        self.btnSalaryDialogAccept.disabled = row == nil or not self:canManageCurrentFarm()
        self:applyMenuButtons({self.btnSalaryDialogCancel, self.btnSalaryDialogDecline, self.btnSalaryDialogAccept})
        return
    end

    if self.transportPriorityDialogOpen == true then
        local row = self.transportPriorityRows[self.transportPrioritySelectedIndex or 1]
        local activeCount = self:getTransportPriorityActiveCount()
        local selectedIndex = self.transportPrioritySelectedIndex or 1
        self.btnTransportDialogCancel.text = self:getText("ui_transportPriorityCancel", "Abbrechen")
        self.btnTransportDialogUp.text = self:getText("ui_transportPriorityMoveUp", "Nach oben")
        self.btnTransportDialogDown.text = self:getText("ui_transportPriorityMoveDown", "Nach unten")
        self.btnTransportDialogToggle.text = self:getText("ui_transportPriorityToggle", "Aktivieren/Deaktivieren")
        self.btnTransportDialogApply.text = self:getText("ui_transportPriorityApply", "Übernehmen")
        self.btnTransportDialogUp.disabled = row == nil or row.enabled ~= true or selectedIndex <= 1
        self.btnTransportDialogDown.disabled = row == nil or row.enabled ~= true or selectedIndex >= activeCount
        self.btnTransportDialogToggle.disabled = row == nil
        self.btnTransportDialogApply.disabled = not self:canManageCurrentFarm()
        self:applyMenuButtons({self.btnTransportDialogCancel, self.btnTransportDialogUp, self.btnTransportDialogDown, self.btnTransportDialogToggle, self.btnTransportDialogApply})
        return
    end

    local buttons = {self.btnClose, self.btnPrevTab, self.btnNextTab}
    local entries = self:getCurrentEntries()
    local hasEntries = entries ~= nil and #entries > 0
    local canManage = self:canManageCurrentFarm()

    self.btnClose.text = self:getText("ui_button_back", "Zurück")
    self.btnPrevTab.text = self:getText("ui_hpIngameMenuPrev", "Vorheriges Menü")
    self.btnNextTab.text = self:getText("ui_hpIngameMenuNext", "Nächstes Menü")
    self.btnPrevPerson.text = self:getText("ui_pmMenuPrevPerson", "Vorige Person")
    self.btnNextPerson.text = self:getText("ui_pmMenuNextPerson", "Nächste Person")
    self.btnPrimary.text = self:getPrimaryButtonText()
    self.btnTransport.text = self:getTransportButtonText()
    self.btnSalary.text = self:getSalaryButtonText()
    self.btnEmergencyRelease.text = self:getText("ui_button_emergency_release_worker", "Notfallfreigabe")
    self.btnPrevPerson.disabled = not hasEntries
    self.btnNextPerson.disabled = not hasEntries
    local currentPerson = self:getCurrentPerson()
    local manager = self:getManager()
    local trainingActive = self.pageKind == "training" and currentPerson ~= nil and manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(currentPerson)

    self.btnPrimary.disabled = not hasEntries or not canManage or self.pageKind == "overview" or self.pageKind == "settings" or trainingActive
    self.btnTransport.disabled = self.pageKind ~= "employees" or not hasEntries or not canManage
    self.btnSalary.disabled = self.pageKind ~= "employees" or not hasEntries or not canManage
    self.btnEmergencyRelease.disabled = self.pageKind ~= "employees" or not hasEntries or not canManage or currentPerson == nil or currentPerson.busy ~= true

    if self.pageKind ~= "overview" and self.pageKind ~= "settings" then
        if self.pageKind == "employees" then
            table.insert(buttons, self.btnTransport)
            table.insert(buttons, self.btnSalary)
            table.insert(buttons, self.btnEmergencyRelease)
        end
        table.insert(buttons, self.btnPrevPerson)
        table.insert(buttons, self.btnNextPerson)
        table.insert(buttons, self.btnPrimary)
    end

    self:applyMenuButtons(buttons)
end

function HelperPersonnelMenuPage:onClickBack()
    if self.salaryRaiseDialogOpen == true then
        return self:closeSalaryRaiseDialog()
    end

    if self.transportPriorityDialogOpen == true then
        return self:closeTransportPriorityDialog()
    end

    if self.menu ~= nil and self.menu.exitMenu ~= nil then
        self.menu:exitMenu()
        return true
    end

    return true
end

function HelperPersonnelMenuPage:onClickPagePrevious()
    if self.menu ~= nil and self.menu.onPagePrevious ~= nil then
        self.menu:onPagePrevious()
        return true
    end

    return false
end

function HelperPersonnelMenuPage:onClickPageNext()
    if self.menu ~= nil and self.menu.onPageNext ~= nil then
        self.menu:onPageNext()
        return true
    end

    return false
end

function HelperPersonnelMenuPage:onClickPreviousPerson()
    return self:movePersonSelection(-1)
end

function HelperPersonnelMenuPage:onClickNextPerson()
    return self:movePersonSelection(1)
end

function HelperPersonnelMenuPage:onClickSalaryAction()
    if not self:canManageCurrentFarm() then
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage("ui_pmMenuNoPermission")
        end
        return false
    end

    if self.pageKind ~= "employees" or #self:getWorkers() == 0 then
        return false
    end

    return self:openSalaryRaiseDialog()
end

function HelperPersonnelMenuPage:onClickTransportAction()
    if not self:canManageCurrentFarm() then
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage("ui_pmMenuNoPermission")
        end
        return false
    end

    if self.pageKind ~= "employees" or #self:getWorkers() == 0 then
        return false
    end

    return self:openTransportPriorityDialog()
end

function HelperPersonnelMenuPage:getTransportPriorityActiveCount()
    local count = 0
    for _, row in ipairs(self.transportPriorityRows or {}) do
        if row.enabled == true then
            count = count + 1
        end
    end
    return count
end

function HelperPersonnelMenuPage:buildTransportPriorityRows()
    local rows = {}
    local activeIds = {}
    local manager = self:getManager()

    if manager ~= nil and manager.getTransportDriversSorted ~= nil then
        for _, worker in ipairs(manager:getTransportDriversSorted()) do
            if worker ~= nil and worker.id ~= nil then
                activeIds[tonumber(worker.id)] = true
                table.insert(rows, {workerId = tonumber(worker.id), enabled = true})
            end
        end
    end

    for _, worker in ipairs(self:getWorkers()) do
        local workerId = worker ~= nil and tonumber(worker.id) or nil
        if workerId ~= nil and activeIds[workerId] ~= true then
            table.insert(rows, {workerId = workerId, enabled = false})
        end
    end

    return rows
end

function HelperPersonnelMenuPage:openTransportPriorityDialog()
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    self.transportPriorityRows = self:buildTransportPriorityRows()
    self.transportPrioritySelectedIndex = 1
    self.transportPriorityFirstIndex = 1
    self.transportPriorityDialogOpen = true
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:closeTransportPriorityDialog()
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.transportPrioritySelectedIndex = 1
    self.transportPriorityFirstIndex = 1
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:ensureTransportPrioritySelectionVisible()
    local count = #self.transportPriorityRows
    local visible = math.max(1, self.transportPriorityVisibleRows or 10)
    self.transportPrioritySelectedIndex = hpMenuClamp(self.transportPrioritySelectedIndex or 1, 1, math.max(count, 1))
    self.transportPriorityFirstIndex = hpMenuClamp(self.transportPriorityFirstIndex or 1, 1, math.max(1, count - visible + 1))

    if self.transportPrioritySelectedIndex < self.transportPriorityFirstIndex then
        self.transportPriorityFirstIndex = self.transportPrioritySelectedIndex
    elseif self.transportPrioritySelectedIndex >= self.transportPriorityFirstIndex + visible then
        self.transportPriorityFirstIndex = self.transportPrioritySelectedIndex - visible + 1
    end
end

function HelperPersonnelMenuPage:moveTransportPrioritySelection(delta)
    local count = #self.transportPriorityRows
    if count == 0 then
        return false
    end

    self.transportPrioritySelectedIndex = hpMenuClamp((self.transportPrioritySelectedIndex or 1) + delta, 1, count)
    self:ensureTransportPrioritySelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:moveTransportPriorityRow(delta)
    local index = self.transportPrioritySelectedIndex or 1
    local row = self.transportPriorityRows[index]
    local activeCount = self:getTransportPriorityActiveCount()
    if row == nil or row.enabled ~= true then
        return false
    end

    local target = index + delta
    if target < 1 or target > activeCount then
        return false
    end

    self.transportPriorityRows[index], self.transportPriorityRows[target] = self.transportPriorityRows[target], self.transportPriorityRows[index]
    self.transportPrioritySelectedIndex = target
    self:ensureTransportPrioritySelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:toggleTransportPriorityRow()
    local index = self.transportPrioritySelectedIndex or 1
    local row = self.transportPriorityRows[index]
    if row == nil then
        return false
    end

    table.remove(self.transportPriorityRows, index)
    if row.enabled == true then
        row.enabled = false
        table.insert(self.transportPriorityRows, row)
        self.transportPrioritySelectedIndex = #self.transportPriorityRows
    else
        row.enabled = true
        local insertIndex = self:getTransportPriorityActiveCount() + 1
        table.insert(self.transportPriorityRows, insertIndex, row)
        self.transportPrioritySelectedIndex = insertIndex
    end

    self:ensureTransportPrioritySelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:getTransportPriorityDraftIds()
    local ids = {}
    for _, row in ipairs(self.transportPriorityRows or {}) do
        if row.enabled == true then
            table.insert(ids, row.workerId)
        end
    end
    return ids
end

function HelperPersonnelMenuPage:isTransportPriorityDraftChanged()
    local draft = self:getTransportPriorityDraftIds()
    local manager = self:getManager()
    local current = manager ~= nil and manager.getTransportDriversSorted ~= nil and manager:getTransportDriversSorted() or {}
    if #draft ~= #current then
        return true
    end
    for index, worker in ipairs(current) do
        if tonumber(worker.id) ~= tonumber(draft[index]) then
            return true
        end
    end
    return false
end

function HelperPersonnelMenuPage:applyTransportPriorityDialog()
    if not self:canManageCurrentFarm() then
        return false
    end

    if not self:isTransportPriorityDraftChanged() then
        return self:closeTransportPriorityDialog()
    end

    if self.app == nil or self.app.requestSetTransportPriority == nil then
        return false
    end

    local changed = self.app:requestSetTransportPriority(self:getTransportPriorityDraftIds()) == true
    if changed then
        self:closeTransportPriorityDialog()
        self:refresh()
    end
    return changed
end

function HelperPersonnelMenuPage:getTransportPriorityWorker(row)
    local manager = self:getManager()
    if row == nil or manager == nil or manager.getWorkerById == nil then
        return nil
    end
    return manager:getWorkerById(row.workerId)
end

function HelperPersonnelMenuPage:buildSalaryRaiseRows()
    local rows = {}
    for _, worker in ipairs(self:getWorkers()) do
        if worker ~= nil and worker.salaryRaisePending == true and worker.id ~= nil then
            table.insert(rows, {workerId = tonumber(worker.id)})
        end
    end
    return rows
end

function HelperPersonnelMenuPage:openSalaryRaiseDialog()
    self.transportPriorityDialogOpen = false
    self.transportPriorityRows = {}
    self.salaryRaiseRows = self:buildSalaryRaiseRows()
    self.salaryRaiseSelectedIndex = 1
    self.salaryRaiseFirstIndex = 1
    self.salaryRaiseDialogOpen = true
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:closeSalaryRaiseDialog()
    self.salaryRaiseDialogOpen = false
    self.salaryRaiseRows = {}
    self.salaryRaiseSelectedIndex = 1
    self.salaryRaiseFirstIndex = 1
    self:refresh()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:ensureSalaryRaiseSelectionVisible()
    local count = #self.salaryRaiseRows
    local visible = math.max(1, self.salaryRaiseVisibleRows or 10)
    self.salaryRaiseSelectedIndex = hpMenuClamp(self.salaryRaiseSelectedIndex or 1, 1, math.max(count, 1))
    self.salaryRaiseFirstIndex = hpMenuClamp(self.salaryRaiseFirstIndex or 1, 1, math.max(1, count - visible + 1))

    if self.salaryRaiseSelectedIndex < self.salaryRaiseFirstIndex then
        self.salaryRaiseFirstIndex = self.salaryRaiseSelectedIndex
    elseif self.salaryRaiseSelectedIndex >= self.salaryRaiseFirstIndex + visible then
        self.salaryRaiseFirstIndex = self.salaryRaiseSelectedIndex - visible + 1
    end
end

function HelperPersonnelMenuPage:moveSalaryRaiseSelection(delta)
    local count = #self.salaryRaiseRows
    if count == 0 then
        return false
    end

    self.salaryRaiseSelectedIndex = hpMenuClamp((self.salaryRaiseSelectedIndex or 1) + delta, 1, count)
    self:ensureSalaryRaiseSelectionVisible()
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:getSalaryRaiseWorker(row)
    local manager = self:getManager()
    if row == nil or manager == nil or manager.getWorkerById == nil then
        return nil
    end
    return manager:getWorkerById(row.workerId)
end

function HelperPersonnelMenuPage:getSalaryRaiseWageText(worker, requested)
    local manager = self:getManager()
    if worker == nil or manager == nil then
        return "-"
    end

    local baseWage = requested == true and worker.salaryRaiseTargetBaseWage or worker.salaryRaisePreviousBaseWage
    baseWage = tonumber(baseWage) or tonumber(worker.baseWage) or 0
    if manager.getMonthlyWageTextFromBase ~= nil then
        return manager:getMonthlyWageTextFromBase(baseWage)
    end
    if manager.formatMoneyForText ~= nil then
        return manager:formatMoneyForText(baseWage)
    end
    return string.format("%d €", math.floor(baseWage + 0.5))
end

function HelperPersonnelMenuPage:decideSalaryRaiseRequest(acceptRequest)
    if not self:canManageCurrentFarm() then
        return false
    end

    local index = self.salaryRaiseSelectedIndex or 1
    local row = self.salaryRaiseRows[index]
    local worker = self:getSalaryRaiseWorker(row)
    if worker == nil or worker.salaryRaisePending ~= true or self.app == nil then
        return false
    end

    local changed = false
    if acceptRequest == true and self.app.requestGrantSalaryRaise ~= nil then
        changed = self.app:requestGrantSalaryRaise(worker.id) == true
    elseif acceptRequest ~= true and self.app.requestDeclineSalaryRaise ~= nil then
        changed = self.app:requestDeclineSalaryRaise(worker.id) == true
    end

    if changed then
        table.remove(self.salaryRaiseRows, index)
        self.salaryRaiseSelectedIndex = hpMenuClamp(index, 1, math.max(#self.salaryRaiseRows, 1))
        self:ensureSalaryRaiseSelectionVisible()
        self:updateButtons()
        self.requestRender = true
    end

    return changed
end

function HelperPersonnelMenuPage:movePersonSelection(delta)
    if self.pageKind == "overview" then
        return false
    end

    local entries, isApplicant = self:getCurrentEntries()
    if #entries <= 0 then
        return false
    end

    if isApplicant then
        self.applicantIndex = self.applicantIndex + delta
        if self.applicantIndex < 1 then
            self.applicantIndex = #entries
        elseif self.applicantIndex > #entries then
            self.applicantIndex = 1
        end
    else
        self.workerIndex = self.workerIndex + delta
        if self.workerIndex < 1 then
            self.workerIndex = #entries
        elseif self.workerIndex > #entries then
            self.workerIndex = 1
        end
    end

    if self.pageKind == "training" then
        self.selectedTrainingCategoryKey = nil
        self.selectedTrainingWorkerId = nil
    end

    if self.pageKind == "applicants" then
        self:refreshApplicantsNativeGui()
    elseif self.pageKind == "employees" then
        self.employeesProfileFirstIndex = 1
        self:refreshEmployeesNativeGui()
    elseif self.pageKind == "training" then
        self:refreshTrainingNativeGui()
    end

    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:showConfirmDialog(text, callback, person)
    if YesNoDialog ~= nil and YesNoDialog.show ~= nil then
        YesNoDialog.show(function(target, clickOk, data)
            if clickOk == true and callback ~= nil then
                callback(target, data)
            end
        end, self, text, nil, nil, nil, nil, nil, nil, person)
        return true
    end

    if callback ~= nil then
        callback(self, person)
    end

    return true
end

function HelperPersonnelMenuPage:showTrainingInfoText(text)
    text = tostring(text or "")

    if InfoDialog ~= nil and InfoDialog.show ~= nil then
        InfoDialog.show(text)
        return true
    end

    if self.app ~= nil and self.app.showIngameNotificationLocal ~= nil then
        self.app:showIngameNotificationLocal(text)
        return true
    end

    if self.app ~= nil and self.app.showPlayerMessage ~= nil then
        self.app:showPlayerMessage(text)
        return true
    end

    return false
end

function HelperPersonnelMenuPage:showTrainingInfoMessage(textKey, fallback)
    return self:showTrainingInfoText(self:getText(textKey, fallback))
end

function HelperPersonnelMenuPage:showTrainingCategoryRequiredMessage()
    return self:showTrainingInfoMessage("ui_pmTrainingSelectCategory", "Erst Schulungskategorie auswählen")
end

function HelperPersonnelMenuPage:showTrainingCategoryDialog(person)
    local rows = self:getTrainingCategoryRows(person)
    if #rows == 0 or OptionDialog == nil or OptionDialog.show == nil then
        self:showTrainingCategoryRequiredMessage()
        return false
    end

    local texts = {}
    for _, row in ipairs(rows) do
        texts[#texts + 1] = row.name
    end

    OptionDialog.show(function(item)
        local row = rows[tonumber(item) or 0]
        if row == nil then
            return
        end

        self.selectedTrainingWorkerId = person.id
        self.selectedTrainingCategoryKey = row.key
        self.trainingCategoryDialogSelection = true
        self:refreshTrainingNativeGui()
        self:onClickPrimaryAction()
    end, self:getText("ui_pmMenuPageTraining", "Schulung"), "", texts)
    return true
end

function HelperPersonnelMenuPage:onClickPrimaryAction()
    if not self:canManageCurrentFarm() then
        if self.app ~= nil and self.app.showPlayerMessage ~= nil then
            self.app:showPlayerMessage("ui_pmMenuNoPermission")
        end
        return false
    end

    local person = self:getCurrentPerson()
    if person == nil then
        return false
    end

    if self.pageKind == "applicants" then
        local text = self:formatText("ui_pmConfirmHire", "%s wirklich einstellen?", self:getPersonName(person))
        return self:showConfirmDialog(text, self.onConfirmHire, person)
    elseif self.pageKind == "training" then
        if self.trainingCategoryDialogSelection ~= true then
            return self:showTrainingCategoryDialog(person)
        end
        self.trainingCategoryDialogSelection = nil
        local manager = self:getManager()
        local specializationKey = self.selectedTrainingCategoryKey
        if specializationKey == nil or specializationKey == "" then
            self:showTrainingCategoryRequiredMessage()
            return true
        end

        local specializationName = manager ~= nil and manager.getSpecializationDisplayName ~= nil and manager:getSpecializationDisplayName(specializationKey) or tostring(specializationKey)
        local isActive = manager ~= nil and manager.workerHasSpecialization ~= nil and manager:workerHasSpecialization(person, specializationKey) == true
        local isLearned = manager ~= nil and manager.workerHasLearnedSpecialization ~= nil and manager:workerHasLearnedSpecialization(person, specializationKey) == true

        if person.busy == true then
            self:showTrainingInfoMessage("ui_training_worker_busy", "Der Mitarbeiter ist gerade im Einsatz und kann nicht geändert werden.")
            return true
        end
        if manager ~= nil and manager.isWorkerSick ~= nil and manager:isWorkerSick(person) then
            self:showTrainingInfoMessage("ui_training_worker_sick", "Der Mitarbeiter ist krank und kann nicht geändert werden.")
            return true
        end
        if manager ~= nil and manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person) then
            self:showTrainingInfoMessage("ui_training_worker_in_training", "Der Mitarbeiter ist bereits bis Monatsende in Schulung.")
            return true
        end

        if isActive then
            local text = self:formatText("ui_pmSpecializationDeactivateConfirm", "Spezialisierung %s bei %s ruhen lassen?", specializationName, self:getPersonName(person))
            return self:showConfirmDialog(text, self.onConfirmSpecializationState, {person = person, specializationKey = specializationKey, active = false})
        elseif isLearned then
            if manager.canActivateWorkerSpecializationThisYear ~= nil and not manager:canActivateWorkerSpecializationThisYear(person) then
                self:showTrainingInfoMessage("ui_pmSpecializationActivationUsed", "Eine neue Spezialisierung kann pro Landwirtschaftsjahr und Mitarbeiter nur einmal eingeloggt werden.")
                return true
            end
            if person.specializationPrimary ~= nil and person.specializationPrimary ~= "" and person.specializationSecondary ~= nil and person.specializationSecondary ~= "" then
                self:showTrainingInfoMessage("ui_pmSpecializationSlotsFull", "Vor dem Einloggen muss mindestens eine aktive Spezialisierung ruhen.")
                return true
            end
            local text = self:formatText("ui_pmSpecializationActivateConfirm", "Spezialisierung %s bei %s einloggen?", specializationName, self:getPersonName(person))
            return self:showConfirmDialog(text, self.onConfirmSpecializationState, {person = person, specializationKey = specializationKey, active = true})
        end

        if manager ~= nil and manager.canTrainWorkerThisYear ~= nil and not manager:canTrainWorkerThisYear(person) then
            local message = self:formatText("ui_training_already_done_year", "%s wurde in diesem Jahr bereits geschult.", self:getPersonName(person))
            self:showTrainingInfoText(message)
            return true
        end

        if manager ~= nil and manager.getWorkerTrainingCostDetails ~= nil then
            local _, _, _, available = manager:getWorkerTrainingCostDetails(person, specializationKey)
            if not available then
                self:showTrainingInfoMessage("ui_pmTrainingNoPlacesMessage", "Für diese Schulung sind aktuell keine Plätze frei.")
                return true
            end
        end

        local text = self:formatText("ui_pmTrainingConfirm", "Schulung für %s in der Kategorie %s starten?", self:getPersonName(person), specializationName)
        return self:showConfirmDialog(text, self.onConfirmTraining, {person = person, specializationKey = specializationKey})
    elseif self.pageKind == "settings" then
        return false
    end

    if person.dismissalPending == true then
        local message = self:formatText("ui_fireDeniedPending", "%s wurde bereits gekündigt. Er wird den Betrieb nach Ende der Kündigungsfrist verlassen.", self:getPersonName(person))
        self:showTrainingInfoText(message)
        return true
    end

    local text = self:formatText("ui_pmConfirmDismiss", "%s wirklich kündigen?", self:getPersonName(person))
    return self:showConfirmDialog(text, self.onConfirmDismiss, person)
end

function HelperPersonnelMenuPage:onClickEmergencyReleaseWorker()
    if not self:canManageCurrentFarm() then
        return false
    end

    local person = self:getCurrentPerson()
    if person == nil or person.busy ~= true or self.app == nil or self.app.requestEmergencyReleaseWorker == nil then
        return false
    end

    local text = self:formatText("ui_pmConfirmEmergencyReleaseWorker", "%s notfallmäßig freigeben? Ein laufender Auftrag wird beendet, soweit dies möglich ist. Anschließend werden alle Zuordnungen zwangsläufig entfernt.", self:getPersonName(person))
    return self:showConfirmDialog(text, self.onConfirmEmergencyReleaseWorker, person)
end

function HelperPersonnelMenuPage:onConfirmHire(person)
    if person == nil or self.app == nil or self.app.requestHireApplicant == nil then
        return false
    end

    local changed = self.app:requestHireApplicant(person.id) == true
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:onConfirmDismiss(person)
    if person == nil or self.app == nil or self.app.requestDismissWorker == nil then
        return false
    end

    local changed = self.app:requestDismissWorker(person.id) == true
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:onConfirmEmergencyReleaseWorker(person)
    if person == nil or self.app == nil or self.app.requestEmergencyReleaseWorker == nil then
        return false
    end

    local changed = self.app:requestEmergencyReleaseWorker(person.id) == true
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:onConfirmTraining(trainingData)
    local person = trainingData ~= nil and trainingData.person or trainingData
    local specializationKey = trainingData ~= nil and trainingData.specializationKey or self.selectedTrainingCategoryKey
    if person == nil or specializationKey == nil or self.app == nil or self.app.requestTrainWorker == nil then
        return false
    end

    local changed = self.app:requestTrainWorker(person.id, specializationKey) == true
    if changed then
        self.selectedTrainingCategoryKey = nil
    end
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:onConfirmSpecializationState(actionData)
    local person = actionData ~= nil and actionData.person or nil
    local specializationKey = actionData ~= nil and actionData.specializationKey or nil
    if person == nil or specializationKey == nil or self.app == nil or self.app.requestSpecializationState == nil then
        return false
    end
    local changed = self.app:requestSpecializationState(person.id, specializationKey, actionData.active == true) == true
    if changed then
        self.selectedTrainingCategoryKey = nil
    end
    self:refresh()
    return changed
end

function HelperPersonnelMenuPage:keyEvent(unicode, sym, modifier, isDown)
    if not self:isCurrentMenuPage() then
        return false
    end

    if not isDown then
        return false
    end

    if self.salaryRaiseDialogOpen == true then
        if sym == hpMenuGetInputConstant("KEY_escape", nil) then
            return self:closeSalaryRaiseDialog()
        elseif sym == hpMenuGetInputConstant("KEY_up", nil) or sym == hpMenuGetInputConstant("KEY_upArrow", nil) or sym == hpMenuGetInputConstant("KEY_w", nil) then
            return self:moveSalaryRaiseSelection(-1)
        elseif sym == hpMenuGetInputConstant("KEY_down", nil) or sym == hpMenuGetInputConstant("KEY_downArrow", nil) or sym == hpMenuGetInputConstant("KEY_s", nil) then
            return self:moveSalaryRaiseSelection(1)
        elseif sym == hpMenuGetInputConstant("KEY_return", nil) or sym == hpMenuGetInputConstant("KEY_enter", nil) or sym == hpMenuGetInputConstant("KEY_space", nil) then
            return true
        end
        return true
    end

    if self.transportPriorityDialogOpen == true then
        if sym == hpMenuGetInputConstant("KEY_escape", nil) then
            return self:closeTransportPriorityDialog()
        elseif sym == hpMenuGetInputConstant("KEY_up", nil) or sym == hpMenuGetInputConstant("KEY_upArrow", nil) or sym == hpMenuGetInputConstant("KEY_w", nil) then
            return self:moveTransportPrioritySelection(-1)
        elseif sym == hpMenuGetInputConstant("KEY_down", nil) or sym == hpMenuGetInputConstant("KEY_downArrow", nil) or sym == hpMenuGetInputConstant("KEY_s", nil) then
            return self:moveTransportPrioritySelection(1)
        elseif sym == hpMenuGetInputConstant("KEY_left", nil) or sym == hpMenuGetInputConstant("KEY_leftArrow", nil) or sym == hpMenuGetInputConstant("KEY_a", nil) then
            return self:moveTransportPriorityRow(-1)
        elseif sym == hpMenuGetInputConstant("KEY_right", nil) or sym == hpMenuGetInputConstant("KEY_rightArrow", nil) or sym == hpMenuGetInputConstant("KEY_d", nil) then
            return self:moveTransportPriorityRow(1)
        elseif sym == hpMenuGetInputConstant("KEY_space", nil) then
            return self:toggleTransportPriorityRow()
        elseif sym == hpMenuGetInputConstant("KEY_return", nil) or sym == hpMenuGetInputConstant("KEY_enter", nil) then
            return true
        end
        return true
    end

    if sym == hpMenuGetInputConstant("KEY_escape", nil) then
        return self:onClickBack()
    elseif sym == hpMenuGetInputConstant("KEY_left", nil) or sym == hpMenuGetInputConstant("KEY_leftArrow", nil) or sym == hpMenuGetInputConstant("KEY_a", nil) then
        if self:movePersonSelection(-1) then
            return true
        end
    elseif sym == hpMenuGetInputConstant("KEY_right", nil) or sym == hpMenuGetInputConstant("KEY_rightArrow", nil) or sym == hpMenuGetInputConstant("KEY_d", nil) then
        if self:movePersonSelection(1) then
            return true
        end
    elseif sym == hpMenuGetInputConstant("KEY_return", nil) or sym == hpMenuGetInputConstant("KEY_enter", nil) then
        return true
    end

    return HelperPersonnelMenuPage:superClass().keyEvent(self, unicode, sym, modifier, isDown)
end

function HelperPersonnelMenuPage:getVisibleDotRange(index, count)
    local maxDots = 9
    if count <= maxDots then
        return 1, count
    end

    local halfWindow = math.floor(maxDots * 0.5)
    local startIndex = math.max(1, index - halfWindow)
    startIndex = math.min(startIndex, count - maxDots + 1)

    return startIndex, maxDots
end

function HelperPersonnelMenuPage:drawPersonPager(index, count)
    if count <= 0 then
        return
    end

    local buttonHeight = 0.044
    local buttonWidth = hpMenuGetAspectCorrectWidth(buttonHeight)
    local buttonY = 0.753
    local leftX = 0.255
    local rightX = 0.745

    if self.navArrowLeftOverlay ~= nil then
        self.navArrowLeftOverlay:setPosition(leftX, buttonY)
        self.navArrowLeftOverlay:setDimension(buttonWidth, buttonHeight)
        self.navArrowLeftOverlay:render()
    else
        self:drawTextLine(leftX + buttonWidth * 0.5, buttonY + buttonHeight * 0.5, 0.020, RenderText.ALIGN_CENTER, "<", 0.61, 0.73, 0.07, 1, true)
    end

    if self.navArrowRightOverlay ~= nil then
        self.navArrowRightOverlay:setPosition(rightX, buttonY)
        self.navArrowRightOverlay:setDimension(buttonWidth, buttonHeight)
        self.navArrowRightOverlay:render()
    else
        self:drawTextLine(rightX + buttonWidth * 0.5, buttonY + buttonHeight * 0.5, 0.020, RenderText.ALIGN_CENTER, ">", 0.61, 0.73, 0.07, 1, true)
    end

    self:addClickArea(leftX, buttonY, buttonWidth, buttonHeight, "prevPerson", nil)
    self:addClickArea(rightX, buttonY, buttonWidth, buttonHeight, "nextPerson", nil)

    local startIndex, visibleDots = self:getVisibleDotRange(index, count)
    local dotHeight = 0.011
    local dotWidth = hpMenuGetAspectCorrectWidth(dotHeight)
    local dotSpacing = dotWidth + 0.005
    local centerX = 0.52
    local firstX = centerX - (((visibleDots - 1) * dotSpacing) + dotWidth) * 0.5
    local dotY = 0.772

    for dot = 1, visibleDots do
        local realIndex = startIndex + dot - 1
        local x = firstX + (dot - 1) * dotSpacing
        local overlay = realIndex == index and self.navDotActiveOverlay or self.navDotInactiveOverlay
        if overlay ~= nil then
            overlay:setPosition(x, dotY)
            overlay:setDimension(dotWidth, dotHeight)
            overlay:render()
        else
            local c = realIndex == index and 0.61 or 0.56
            self:drawTextLine(x + dotWidth * 0.5, dotY + dotHeight * 0.5, 0.012, RenderText.ALIGN_CENTER, "•", c, c, c, 1, true)
        end
    end
end

function HelperPersonnelMenuPage:handleMouseClick(posX, posY)
    if self.salaryRaiseDialogOpen == true then
        for i = #(self.clickAreas or {}), 1, -1 do
            local area = self.clickAreas[i]
            if area ~= nil and self:isPointInClickArea(posX, posY, area) and area.action == "salaryRaiseSelect" then
                self.salaryRaiseSelectedIndex = area.index or 1
                self:ensureSalaryRaiseSelectionVisible()
                self:updateButtons()
                self.requestRender = true
                return true
            end
        end
        return true
    end

    if self.transportPriorityDialogOpen == true then
        for i = #(self.clickAreas or {}), 1, -1 do
            local area = self.clickAreas[i]
            if area ~= nil and self:isPointInClickArea(posX, posY, area) then
                if area.action == "transportPrioritySelect" then
                    self.transportPrioritySelectedIndex = area.index or 1
                    self:ensureTransportPrioritySelectionVisible()
                    self:updateButtons()
                    self.requestRender = true
                    return true
                end
            end
        end
        return true
    end

    for i = #(self.clickAreas or {}), 1, -1 do
        local area = self.clickAreas[i]
        if area ~= nil and self:isPointInClickArea(posX, posY, area) then
            if area.action == "prevPerson" then
                return self:movePersonSelection(-1)
            elseif area.action == "nextPerson" then
                return self:movePersonSelection(1)
            end
        end
    end

    return HelperPersonnelMenuPage:superClass().handleMouseClick(self, posX, posY)
end

function HelperPersonnelMenuPage:draw()
    HelperPersonnelViewBase:superClass().draw(self)
    self:resetClickAreas()

    if self.salaryRaiseDialogOpen == true then
        self:drawSalaryRaiseDialog()
        return
    end

    if self.transportPriorityDialogOpen == true then
        self:drawTransportPriorityDialog()
        return
    end

    if self.pageKind == "overview" or self.pageKind == "applicants" or self.pageKind == "employees" or self.pageKind == "training" then
        return
    elseif self.pageKind == "settings" then
        self:drawStandaloneHeader()
        self:drawTextLine(0.22, 0.790, 0.014, RenderText.ALIGN_LEFT, self:getText("ui_pmSettingsInfo", "Die Einstellungen werden über die nativen Auswahlzeilen geändert."), 1, 1, 1, 1, false)
    end

end

function HelperPersonnelMenuPage:drawSalaryRaiseDialog()
    self:ensureSalaryRaiseSelectionVisible()

    self:drawSolidRect(0, 0, 1, 1, 0, 0, 0, 0.62)
    local x = 0.18
    local y = 0.145
    local width = 0.64
    local height = 0.71
    self:drawSolidRect(x, y, width, height, 0.055, 0.062, 0.070, 1)
    self:drawSolidRect(x, y + height - 0.008, width, 0.008, 0.61, 0.73, 0.07, 1)

    self:drawTextLine(x + 0.025, y + height - 0.058, 0.026, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsTitle", "Gehaltsforderungen verwalten"), 1, 1, 1, 1, true)
    local intro = self:getText("ui_salaryRequestsIntro", "Hier werden alle offenen Gehaltsforderungen angezeigt. Wähle einen Mitarbeiter aus und entscheide, ob die Forderung angenommen oder abgelehnt wird.")
    local introLines = self:getWrappedHistoryLines(intro, 0.0115, width - 0.05, 118)
    local introY = y + height - 0.092
    for index = 1, math.min(#introLines, 3) do
        self:drawTextLine(x + 0.025, introY, 0.0115, RenderText.ALIGN_LEFT, introLines[index], 0.91, 0.91, 0.91, 1, false)
        introY = introY - 0.017
    end

    local tableX = x + 0.025
    local tableWidth = width - 0.05
    local headerY = y + height - 0.158
    local nameX = tableX + 0.015
    local currentX = tableX + 0.34
    local requestedX = tableX + tableWidth - 0.015
    self:drawTextLine(nameX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsHeaderEmployee", "Mitarbeiter"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(currentX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsHeaderCurrent", "Aktuelles Gehalt"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(requestedX, headerY, 0.0118, RenderText.ALIGN_RIGHT, self:getText("ui_salaryRequestsHeaderRequested", "Gefordertes Gehalt"), 0.61, 0.73, 0.07, 1, true)
    self:drawSeparator(tableX, headerY - 0.014, tableWidth)

    local rows = self.salaryRaiseRows or {}
    if #rows == 0 then
        self:drawTextLine(tableX + 0.012, headerY - 0.065, 0.015, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsNoRequests", "Keine offenen Gehaltsforderungen."), 1, 1, 1, 1, false)
    else
        local rowHeight = 0.044
        local rowGap = 0.004
        local firstRowY = headerY - 0.067
        local visible = math.max(1, self.salaryRaiseVisibleRows or 10)
        local lastIndex = math.min(#rows, self.salaryRaiseFirstIndex + visible - 1)
        for index = self.salaryRaiseFirstIndex, lastIndex do
            local visibleIndex = index - self.salaryRaiseFirstIndex
            local rowY = firstRowY - visibleIndex * (rowHeight + rowGap)
            local selected = index == self.salaryRaiseSelectedIndex
            local row = rows[index]
            local worker = self:getSalaryRaiseWorker(row)
            local shade = index % 2 == 0 and 0.145 or 0.115
            if selected then
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, 0.31, 0.38, 0.06, 0.94)
            else
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, shade, shade, shade, 0.86)
            end

            local textY = rowY + (rowHeight - 0.0125) * 0.5
            local name = worker ~= nil and self:getPersonName(worker) or tostring(row.workerId or "")
            local currentText = self:getSalaryRaiseWageText(worker, false)
            local requestedText = self:getSalaryRaiseWageText(worker, true)
            self:drawTextLine(nameX, textY, 0.0125, RenderText.ALIGN_LEFT, name, 1, 1, 1, 1, true)
            self:drawTextLine(currentX, textY, 0.0120, RenderText.ALIGN_LEFT, currentText, 0.88, 0.88, 0.88, 1, false)
            self:drawTextLine(requestedX, textY, 0.0120, RenderText.ALIGN_RIGHT, requestedText, 0.70, 0.88, 0.12, 1, true)
            self:addClickArea(tableX, rowY, tableWidth, rowHeight, "salaryRaiseSelect", index)
        end

        if #rows > visible then
            local scrollbarX = tableX + tableWidth + 0.006
            local scrollbarY = firstRowY - (visible - 1) * (rowHeight + rowGap)
            local scrollbarHeight = visible * rowHeight + (visible - 1) * rowGap
            self:drawSolidRect(scrollbarX, scrollbarY, 0.004, scrollbarHeight, 0.18, 0.18, 0.18, 0.95)
            local thumbHeight = math.max(0.035, scrollbarHeight * (visible / #rows))
            local maxFirst = math.max(1, #rows - visible + 1)
            local ratio = maxFirst > 1 and ((self.salaryRaiseFirstIndex - 1) / (maxFirst - 1)) or 0
            local thumbY = scrollbarY + scrollbarHeight - thumbHeight - ratio * (scrollbarHeight - thumbHeight)
            self:drawSolidRect(scrollbarX, thumbY, 0.004, thumbHeight, 0.61, 0.73, 0.07, 1)
        end
    end

    self:drawTextLine(x + 0.025, y + 0.025, 0.0108, RenderText.ALIGN_LEFT, self:getText("ui_salaryRequestsControls", "Pfeil hoch/runter: auswählen | Enter: annehmen | Leertaste: ablehnen"), 0.82, 0.82, 0.82, 1, false)
end

function HelperPersonnelMenuPage:drawTransportPriorityDialog()
    self:ensureTransportPrioritySelectionVisible()

    self:drawSolidRect(0, 0, 1, 1, 0, 0, 0, 0.62)
    local x = 0.18
    local y = 0.145
    local width = 0.64
    local height = 0.71
    self:drawSolidRect(x, y, width, height, 0.055, 0.062, 0.070, 1)
    self:drawSolidRect(x, y + height - 0.008, width, 0.008, 0.61, 0.73, 0.07, 1)

    self:drawTextLine(x + 0.025, y + height - 0.058, 0.026, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityTitle", "Transportaufgaben verwalten"), 1, 1, 1, 1, true)
    local intro = self:getText("ui_transportPriorityIntro", "Aktiviere Mitarbeiter für Transportaufgaben und lege ihre Reihenfolge fest. Bei einem neuen Transportauftrag wird von oben nach unten der erste freie Mitarbeiter ausgewählt.")
    local introLines = self:getWrappedHistoryLines(intro, 0.0115, width - 0.05, 118)
    local introY = y + height - 0.092
    for index = 1, math.min(#introLines, 3) do
        self:drawTextLine(x + 0.025, introY, 0.0115, RenderText.ALIGN_LEFT, introLines[index], 0.91, 0.91, 0.91, 1, false)
        introY = introY - 0.017
    end

    local tableX = x + 0.025
    local tableWidth = width - 0.05
    local headerY = y + height - 0.158
    local priorityX = tableX + 0.015
    local nameX = tableX + 0.085
    local statusX = tableX + 0.355
    local enabledX = tableX + tableWidth - 0.015
    self:drawTextLine(priorityX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityHeaderPriority", "Priorität"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(nameX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityHeaderEmployee", "Mitarbeiter"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(statusX, headerY, 0.0118, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityHeaderStatus", "Status"), 0.61, 0.73, 0.07, 1, true)
    self:drawTextLine(enabledX, headerY, 0.0118, RenderText.ALIGN_RIGHT, self:getText("ui_transportPriorityHeaderEnabled", "Transport"), 0.61, 0.73, 0.07, 1, true)
    self:drawSeparator(tableX, headerY - 0.014, tableWidth)

    local rows = self.transportPriorityRows or {}
    if #rows == 0 then
        self:drawTextLine(tableX + 0.012, headerY - 0.065, 0.015, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityNoWorkers", "Keine Mitarbeiter vorhanden."), 1, 1, 1, 1, false)
        return
    end

    local rowHeight = 0.044
    local rowGap = 0.004
    local firstRowY = headerY - 0.067
    local visible = math.max(1, self.transportPriorityVisibleRows or 10)
    local lastIndex = math.min(#rows, self.transportPriorityFirstIndex + visible - 1)
    local activePosition = 0
    for index = 1, #rows do
        if rows[index].enabled == true then
            activePosition = activePosition + 1
        end
        if index >= self.transportPriorityFirstIndex and index <= lastIndex then
            local visibleIndex = index - self.transportPriorityFirstIndex
            local rowY = firstRowY - visibleIndex * (rowHeight + rowGap)
            local selected = index == self.transportPrioritySelectedIndex
            local row = rows[index]
            local worker = self:getTransportPriorityWorker(row)
            local shade = index % 2 == 0 and 0.145 or 0.115
            if selected then
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, 0.31, 0.38, 0.06, 0.94)
            else
                self:drawSolidRect(tableX, rowY, tableWidth, rowHeight, shade, shade, shade, 0.86)
            end

            local textY = rowY + (rowHeight - 0.0125) * 0.5
            local priorityText = row.enabled == true and tostring(activePosition) or "–"
            local name = worker ~= nil and self:getPersonName(worker) or tostring(row.workerId or "")
            local manager = self:getManager()
            local status = worker ~= nil and manager ~= nil and manager.getStatusText ~= nil and manager:getStatusText(worker) or ""
            local enabledText = row.enabled == true and self:getText("ui_transportPriorityActive", "Aktiv") or self:getText("ui_transportPriorityInactive", "Inaktiv")
            local value = row.enabled == true and 1 or 0.62
            self:drawTextLine(priorityX, textY, 0.0125, RenderText.ALIGN_LEFT, priorityText, value, value, value, 1, true)
            self:drawTextLine(nameX, textY, 0.0125, RenderText.ALIGN_LEFT, name, value, value, value, 1, true)
            self:drawTextLine(statusX, textY, 0.0114, RenderText.ALIGN_LEFT, status, value, value, value, 1, false)
            self:drawTextLine(enabledX, textY, 0.0120, RenderText.ALIGN_RIGHT, enabledText, row.enabled == true and 0.70 or 0.72, row.enabled == true and 0.88 or 0.72, row.enabled == true and 0.12 or 0.72, 1, true)
            self:addClickArea(tableX, rowY, tableWidth, rowHeight, "transportPrioritySelect", index)
        end
    end

    if #rows > visible then
        local scrollbarX = tableX + tableWidth + 0.006
        local scrollbarY = firstRowY - (visible - 1) * (rowHeight + rowGap)
        local scrollbarHeight = visible * rowHeight + (visible - 1) * rowGap
        self:drawSolidRect(scrollbarX, scrollbarY, 0.004, scrollbarHeight, 0.18, 0.18, 0.18, 0.95)
        local thumbHeight = math.max(0.035, scrollbarHeight * (visible / #rows))
        local maxFirst = math.max(1, #rows - visible + 1)
        local ratio = maxFirst > 1 and ((self.transportPriorityFirstIndex - 1) / (maxFirst - 1)) or 0
        local thumbY = scrollbarY + scrollbarHeight - thumbHeight - ratio * (scrollbarHeight - thumbHeight)
        self:drawSolidRect(scrollbarX, thumbY, 0.004, thumbHeight, 0.61, 0.73, 0.07, 1)
    end

    self:drawTextLine(x + 0.025, y + 0.025, 0.0108, RenderText.ALIGN_LEFT, self:getText("ui_transportPriorityControls", "Pfeil hoch/runter: auswählen | links/rechts: verschieben | Leertaste: aktivieren/deaktivieren"), 0.82, 0.82, 0.82, 1, false)
end

function HelperPersonnelMenuPage:getTrainingCategoryRows(person)
    local rows = {}
    local manager = self:getManager()
    if person == nil or manager == nil then
        return rows
    end

    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local specializationKey = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(key) or key
        if specializationKey ~= nil then
            local acquired = manager.workerHasSpecialization ~= nil and manager:workerHasSpecialization(person, specializationKey) == true
            local learned = manager.workerHasLearnedSpecialization ~= nil and manager:workerHasLearnedSpecialization(person, specializationKey) == true
            local progressPercent = 100
            if not learned then
                local minutes = manager.getSpecializationProgressMinutes ~= nil and manager:getSpecializationProgressMinutes(person, specializationKey) or 0
                progressPercent = manager.getSpecializationProgressPercentForMinutes ~= nil and manager:getSpecializationProgressPercentForMinutes(person, minutes) or 0
            end
            local trainingActive = manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person) and manager:normalizeSpecializationKey(person.trainingActiveSpecialization) == specializationKey
            local finalCost, baseCost, costDifference, available, modifierPercent = 0, 0, 0, true, 0
            if manager.getWorkerTrainingCostDetails ~= nil then
                finalCost, baseCost, costDifference, available, modifierPercent = manager:getWorkerTrainingCostDetails(person, specializationKey)
            elseif manager.getWorkerTrainingCost ~= nil then
                finalCost = manager:getWorkerTrainingCost(person, specializationKey)
                baseCost = finalCost
            end
            rows[#rows + 1] = {
                key = specializationKey,
                name = manager.getSpecializationDisplayName ~= nil and manager:getSpecializationDisplayName(specializationKey) or tostring(specializationKey),
                progress = math.max(0, math.min(100, tonumber(progressPercent) or 0)),
                acquired = acquired,
                learned = learned,
                trainingActive = trainingActive,
                cost = math.max(0, tonumber(finalCost) or 0),
                baseCost = math.max(0, tonumber(baseCost) or 0),
                costDifference = tonumber(costDifference) or 0,
                modifierPercent = tonumber(modifierPercent) or 0,
                available = available ~= false
            }
        end
    end

    return rows
end

function HelperPersonnelMenuPage:selectTrainingCategory(specializationKey)
    if self.pageKind ~= "training" then
        return false
    end

    local person = self:getCurrentPerson()
    local manager = self:getManager()
    if person == nil or manager == nil then
        return false
    end

    specializationKey = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(specializationKey) or specializationKey
    if specializationKey == nil then
        return false
    end

    if manager.isWorkerInTraining ~= nil and manager:isWorkerInTraining(person) then
        return true
    end

    local active = manager.workerHasSpecialization ~= nil and manager:workerHasSpecialization(person, specializationKey) == true
    local learned = manager.workerHasLearnedSpecialization ~= nil and manager:workerHasLearnedSpecialization(person, specializationKey) == true

    if not active and not learned and manager.getWorkerTrainingCostDetails ~= nil then
        local _, _, _, available = manager:getWorkerTrainingCostDetails(person, specializationKey)
        if not available then
            return true
        end
    end

    local isKnown = false
    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local normalized = manager.normalizeSpecializationKey ~= nil and manager:normalizeSpecializationKey(key) or key
        if normalized == specializationKey then
            isKnown = true
            break
        end
    end
    if not isKnown then
        return false
    end

    self.selectedTrainingWorkerId = person.id
    self.selectedTrainingCategoryKey = specializationKey
    self:updateButtons()
    self.requestRender = true
    return true
end

function HelperPersonnelMenuPage:drawStandaloneHeader()
    if not self:canManageCurrentFarm() then
        self:drawTextLine(0.22, 0.817, 0.013, RenderText.ALIGN_LEFT, self:getText("ui_pmMenuNoPermission", "Du hast keine Berechtigung, Personalentscheidungen für diesen Hof zu treffen."), 1, 0.55, 0.2, 1, true)
    end
end

function HelperPersonnelMenuPage:getSettingsList()
    if HelperPersonnelGameSettings ~= nil and type(HelperPersonnelGameSettings.SETTINGS) == "table" then
        return HelperPersonnelGameSettings.SETTINGS
    end

    return {}
end

function HelperPersonnelMenuPage:getSettingText(setting, keyName, fallback)
    if setting == nil then
        return fallback or ""
    end

    local key = setting[keyName]
    if key ~= nil then
        return self:getText(key, fallback or key)
    end

    return fallback or ""
end

function HelperPersonnelMenuPage:isServerAuthority()
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.isServerAuthority ~= nil then
        return HelperPersonnelGameSettings.isServerAuthority() == true
    end

    return g_server ~= nil
end

function HelperPersonnelMenuPage:isSettingAvailable(setting)
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.isSettingAvailable ~= nil then
        return HelperPersonnelGameSettings.isSettingAvailable(setting) == true
    end

    return true
end

function HelperPersonnelMenuPage:getSettingsConfig()
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.getConfig ~= nil then
        return HelperPersonnelGameSettings.getConfig()
    end

    local manager = self:getManager()
    return manager ~= nil and manager.config or nil
end


function HelperPersonnelMenuPage:getSettingByKey(settingKey)
    if HelperPersonnelGameSettings ~= nil and HelperPersonnelGameSettings.SETTINGS_BY_KEY ~= nil then
        return HelperPersonnelGameSettings.SETTINGS_BY_KEY[settingKey]
    end

    for _, setting in ipairs(self:getSettingsList()) do
        if setting.key == settingKey then
            return setting
        end
    end

    return nil
end

function HelperPersonnelMenuPage:getSelectedSetting()
    local selected = self:getSettingByKey(self.settingsSelectedKey)
    if selected ~= nil then
        return selected
    end

    local settings = self:getSettingsList()
    selected = settings[1]
    if selected ~= nil then
        self.settingsSelectedKey = selected.key
    end

    return selected
end

function HelperPersonnelMenuPage:drawSettingsDescription(setting)
    if setting == nil then
        return
    end

    local x = self.settingsDescriptionX or 0.600
    local y = self.settingsDescriptionY or 0.500
    local width = self.settingsDescriptionWidth or 0.270
    local desc = self:getSettingText(setting, "descriptionKey", "")
    local lines = self:getWrappedHistoryLines(desc, 0.0110, width, 66)
    local currentY = y

    for i = 1, math.min(#lines, 7) do
        self:drawTextLine(x, currentY, 0.0110, RenderText.ALIGN_LEFT, lines[i], 0.66, 0.66, 0.66, 1, false)
        currentY = currentY - 0.020
    end
end


function HelperPersonnelMenuPage:getPersonName(person)
    if person == nil then
        return ""
    end

    return tostring(person.firstName or "") .. " " .. tostring(person.lastName or "")
end

function HelperPersonnelMenuPage:getPersonSeed(person)
    local seed = tonumber(person ~= nil and person.id or 1) or 1
    local name = self:getPersonName(person)
    for i = 1, string.len(name) do
        seed = seed + string.byte(name, i) * i
    end
    return seed
end

function HelperPersonnelMenuPage:getBirthDateText(person)
    local manager = self:getManager()
    if manager ~= nil and manager.getBirthDateText ~= nil and manager.getPersonAge ~= nil then
        local birthDate = manager:getBirthDateText(person)
        local age = manager:getPersonAge(person)
        return self:formatText("ui_pmBirthDateAge", "%s (%d Jahre)", birthDate, age)
    end

    local seed = self:getPersonSeed(person)
    local day = (seed % 28) + 1
    local month = (math.floor(seed / 7) % 12) + 1
    local year = 1967 + (seed % 36)
    return string.format("%02d.%02d.%04d", day, month, year)
end

function HelperPersonnelMenuPage:getOriginText(person)
    local manager = self:getManager()
    if manager ~= nil and manager.getBackgroundDisplayName ~= nil then
        return manager:getBackgroundDisplayName(person)
    end

    local origins = {
        self:getText("ui_pmOrigin1", "ländlicher Familienbetrieb"),
        self:getText("ui_pmOrigin2", "kleiner Milchviehbetrieb"),
        self:getText("ui_pmOrigin3", "Lohnunternehmen"),
        self:getText("ui_pmOrigin4", "Ackerbaubetrieb"),
        self:getText("ui_pmOrigin5", "Gemischtbetrieb")
    }
    local seed = self:getPersonSeed(person)
    return origins[(seed % #origins) + 1]
end

function HelperPersonnelMenuPage:drawPersonStatBars(person, x, y, width)
    if person == nil then
        return
    end

    local stats = {
        { key = "ui_pmStatExperience", fallback = "Erfahrung", value = person.experience or 0 },
        { key = "ui_pmStatReliability", fallback = "Zuverlässigkeit", value = person.reliability or 0 },
        { key = "ui_pmStatLoyalty", fallback = "Loyalität", value = person.loyalty or 0 }
    }
    local gap = 0.012
    local statWidth = (width - (gap * 2)) / 3
    local labelY = y + 0.017
    local barHeight = 0.010

    for index, stat in ipairs(stats) do
        local statX = x + ((index - 1) * (statWidth + gap))
        local value = hpMenuClamp(stat.value, 0, 100)
        self:drawTextLine(statX, labelY, 0.0100, RenderText.ALIGN_LEFT, self:getText(stat.key, stat.fallback), 0.92, 0.92, 0.92, 1, true)
        self:drawTextLine(statX + statWidth, labelY, 0.0100, RenderText.ALIGN_RIGHT, string.format("%d %%", value), 0.61, 0.73, 0.07, 1, true)
        self:drawProgressBar(statX, y, statWidth, barHeight, value, 100, 0.61, 0.73, 0.07, 1)
    end
end

function HelperPersonnelMenuPage:drawPersonCoreBlock(person, isApplicant)
    local manager = self:getManager()
    local lines = self:getPersonCoreLines(person, isApplicant)
    local textX = 0.405

    self:drawDetailTextLine(textX, 0.690, 0.0125, lines[1] or "", 0.92, 0.92, 0.92, 1)
    self:drawDetailTextLine(textX, 0.663, 0.0125, lines[2] or "", 0.92, 0.92, 0.92, 1)

    self:drawPersonStatBars(person, textX, 0.620, 0.430)

    if not isApplicant and manager ~= nil and manager.getRankText ~= nil then
        self:drawTextLine(textX, 0.603, 0.0125, RenderText.ALIGN_LEFT, manager:getRankText(person), 0.61, 0.73, 0.07, 1, true)
    end

    self:drawDetailTextLine(textX, 0.576, 0.0125, lines[3] or "", 0.61, 0.73, 0.07, 1)
    self:drawDetailTextLine(textX, 0.549, 0.0125, lines[4] or "", 0.61, 0.73, 0.07, 1)
    self:drawDetailTextLine(textX, 0.522, 0.0125, lines[5] or "", 0.61, 0.73, 0.07, 1)
end

function HelperPersonnelMenuPage:getPersonCoreLines(person, isApplicant)
    local manager = self:getManager()
    local lines = {}
    local status = isApplicant and self:getText("ui_pmStatusApplicant", "Bewerber") or self:getText("ui_status_idle", "verfügbar")

    if not isApplicant and manager ~= nil and manager.getWorkerStatusText ~= nil then
        status = manager:getWorkerStatusText(person)
    elseif not isApplicant and manager ~= nil and manager.getStatusText ~= nil then
        status = manager:getStatusText(person)
    elseif not isApplicant and self:isWorkerActive(person) then
        status = self:getText("ui_status_busy", "im Einsatz")
    end

    local wageText = "-"
    if manager ~= nil and manager.getMonthlyWageTextFromBase ~= nil then
        wageText = manager:getMonthlyWageTextFromBase(person.baseWage or person.wage or 0)
    elseif manager ~= nil and manager.formatMoney ~= nil then
        wageText = manager:formatMoney(person.wage or person.baseWage or 0)
    else
        wageText = string.format("%d €", math.floor((tonumber(person.wage) or tonumber(person.baseWage) or 0) + 0.5))
    end

    local specText = self:getText("ui_specialization_short", "Spezialisierung") .. ": -"
    if manager ~= nil and manager.getPersonSpecializationText ~= nil then
        specText = manager:getPersonSpecializationText(person) or specText
    elseif person.specializationPrimary ~= nil and person.specializationPrimary ~= "" then
        specText = self:getText("ui_specialization_short", "Spezialisierung") .. ": " .. tostring(person.specializationPrimary)
    end

    table.insert(lines, self:formatText("ui_pmBirthLine", "Geboren: %s", self:getBirthDateText(person)))
    table.insert(lines, self:formatText("ui_pmOriginLine", "Herkunft: %s", self:getOriginText(person)))
    table.insert(lines, self:formatText("ui_pmWageLine", "Gehalt: %s", wageText))
    table.insert(lines, self:formatText("ui_pmStatusLine", "Status: %s", status))
    table.insert(lines, specText)

    return lines
end


function HelperPersonnelMenuPage:getProfileTemplate(person, isApplicant)
    local manager = self:getManager()
    local spec = person.specializationPrimary or person.specializationProgressKey or ""
    local origin = self:getOriginText(person)
    local name = self:getPersonName(person)
    local strength = self:getText("ui_pmStrengthReliable", "ruhige und zuverlässige Arbeitsweise")

    if spec == HelperPersonnelManager.SPECIALIZATION_TRANSPORT or spec == "transport" then
        strength = self:getText("ui_pmStrengthTransport", "strukturierte Transport- und Hoflogistik")
    elseif spec == HelperPersonnelManager.SPECIALIZATION_HARVEST or spec == "harvest" then
        strength = self:getText("ui_pmStrengthHarvest", "sorgfältige Erntearbeiten")
    elseif spec == HelperPersonnelManager.SPECIALIZATION_SOWING or spec == "sowing" then
        strength = self:getText("ui_pmStrengthSowing", "präzise Aussaat und Feldvorbereitung")
    end

    if isApplicant then
        if manager ~= nil and manager.getDynamicApplicantProfileText ~= nil then
            local ok, dynamicText = pcall(manager.getDynamicApplicantProfileText, manager, person)
            if ok and dynamicText ~= nil and dynamicText ~= "" then
                return dynamicText
            end
            if not ok and Logging ~= nil and Logging.warning ~= nil then
                Logging.warning("FS25_PersonnelManagement: Could not generate applicant profile: %s", tostring(dynamicText))
            end
        end
        return self:formatText("ui_pmApplicantProfileText", "%s bewirbt sich mit Erfahrung aus einem %s. Die bisherigen Angaben sprechen für %s. Die Werte sind eine Momentaufnahme des Bewerberprofils.", name, origin, strength)
    end

    if manager ~= nil and manager.getDynamicWorkerProfileText ~= nil then
        local ok, dynamicText = pcall(manager.getDynamicWorkerProfileText, manager, person)
        if ok and dynamicText ~= nil and dynamicText ~= "" then
            return dynamicText
        end
        if not ok and Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("FS25_PersonnelManagement: Could not generate profile text: %s", tostring(dynamicText))
        end
    end


    local hiredLine = manager ~= nil and self:getBaseWorkerHiredLine(manager, person) or self:getText("ui_worker_hired_unknown", "eingestellt vor Aufzeichnung")
    return self:formatText("ui_pmWorkerProfileText", "%s ist %s im Betrieb. Die bisherige Entwicklung spricht für %s.", name, hiredLine, strength)
end

function HelperPersonnelMenuPage:getWrappedProfileLines(person, isApplicant)
    local text = self:getProfileTemplate(person, isApplicant)
    return self:getWrappedHistoryLines(text, 0.0122, 0.62, 132)
end

function HelperPersonnelMenuPage:formatChronicleDate(entry)
    if type(entry) ~= "table" then
        return self:getText("ui_pmHistoryNoRecord", "keine Aufzeichnung")
    end

    return self:formatText("ui_pmHistoryDateFormat", "Tag %d · %d/%d", entry.day or 1, entry.calendarMonth or 1, entry.calendarYear or 1)
end

function HelperPersonnelMenuPage:getWorkerHistoryColumns(person)
    local manager = self:getManager()
    local overview = manager ~= nil and manager.getWorkerHistoryOverview ~= nil and manager:getWorkerHistoryOverview(person) or nil
    overview = type(overview) == "table" and overview or {}

    local trainingText
    if person.trainingActivePeriod ~= nil and (person.trainingActivePeriod or 0) > 0 then
        trainingText = manager ~= nil and manager.getSpecializationDisplayName ~= nil and manager:getSpecializationDisplayName(person.trainingActiveSpecialization) or tostring(person.trainingActiveSpecialization or "")
    elseif person.trainingLastYear ~= nil and (person.trainingLastYear or 0) > 0 then
        trainingText = self:formatText("ui_pmHistoryTrainingYearCompact", "Jahr %d", person.trainingLastYear or 0)
    else
        trainingText = self:getText("ui_pmHistoryTrainingNoneCompact", "keine")
    end

    local firstColumn = {
        self:formatText("ui_pmHistoryCareerJobs", "Einsätze: %d", person.jobsCompleted or 0),
        self:formatText("ui_pmHistoryCareerWorkTime", "Arbeitszeit: %s", manager ~= nil and manager.formatWorkMinutes ~= nil and manager:formatWorkMinutes(person.totalWorkMinutes or 0) or tostring(person.totalWorkMinutes or 0)),
        self:formatText("ui_pmHistoryCareerTraining", "Schulung: %s", trainingText),
        self:formatText("ui_pmHistoryCareerTransport", "Transport: %s", person.transportDriver == true and self:getText("ui_pmHistoryValueActive", "aktiv") or self:getText("ui_pmHistoryValueInactive", "nicht aktiv"))
    }

    local noRecord = self:getText("ui_pmHistoryNoRecord", "keine Aufzeichnung")
    local sicknessDate = overview.latestSickness ~= nil and self:formatChronicleDate(overview.latestSickness) or noRecord
    local salaryDate = overview.latestSalaryRequest ~= nil and self:formatChronicleDate(overview.latestSalaryRequest) or noRecord
    local salaryStatusKey = "ui_pmHistorySalaryUnresolved"
    local salaryStatusFallback = "ohne erfasste Entscheidung"
    if overview.salaryRequestStatus == "accepted" then
        salaryStatusKey = "ui_pmHistorySalaryAccepted"
        salaryStatusFallback = "angenommen"
    elseif overview.salaryRequestStatus == "declined" then
        salaryStatusKey = "ui_pmHistorySalaryDeclined"
        salaryStatusFallback = "abgelehnt"
    elseif overview.salaryRequestStatus == "pending" then
        salaryStatusKey = "ui_pmHistorySalaryPending"
        salaryStatusFallback = "offen"
    end
    local salaryStatus = overview.latestSalaryRequest ~= nil and self:getText(salaryStatusKey, salaryStatusFallback) or noRecord

    local abortDate = overview.latestJobAbort ~= nil and self:formatChronicleDate(overview.latestJobAbort) or noRecord
    local abortReason = noRecord
    if overview.latestJobAbort ~= nil then
        if overview.latestJobAbort.reason == "sickness" then
            abortReason = self:getText("ui_pmHistoryAbortSickness", "Krankheit")
        elseif overview.latestJobAbort.reason == "unreliability" then
            abortReason = self:getText("ui_pmHistoryAbortUnreliability", "Unzuverlässigkeit")
        else
            abortReason = self:getText("ui_pmHistoryAbortOther", "sonstiger Grund")
        end
    end

    local salaryHistoryValue = noRecord
    if overview.latestSalaryRequest ~= nil then
        salaryHistoryValue = string.format("%s · %s", salaryDate, salaryStatus)
    end
    local abortHistoryValue = noRecord
    if overview.latestJobAbort ~= nil then
        abortHistoryValue = string.format("%s · %s", abortDate, abortReason)
    end

    local secondColumn = {
        self:formatText("ui_pmHistoryLastSickness", "Zuletzt krank: %s", sicknessDate),
        self:formatText("ui_pmHistoryLastSalaryRequest", "Letzte Gehaltsforderung: %s", salaryHistoryValue),
        self:formatText("ui_pmHistoryLastAbort", "Letzter Einsatzabbruch: %s", abortHistoryValue)
    }

    local totalSalaryText = manager ~= nil and manager.formatMoneyForText ~= nil and manager:formatMoneyForText(person.totalEarnings or 0) or string.format("%d €", math.floor((tonumber(person.totalEarnings) or 0) + 0.5))
    local thirdColumn = {
        self:formatText("ui_pmHistoryTotalSickness", "Krankheitstage: %d", overview.sicknessDays or 0),
        self:formatText("ui_pmHistoryTotalSalaryRequests", "Gehaltsforderungen: %d", overview.salaryRequests or 0),
        self:formatText("ui_pmHistoryTotalAborts", "Einsatzabbrüche: %d", overview.abortedJobs or 0),
        self:formatText("ui_pmHistoryTotalSalaryPaid", "Gesamtgehalt: %s", totalSalaryText)
    }

    return {
        { title = self:getText("ui_pmHistoryColumnCareer", "Bisheriger Verlauf"), lines = firstColumn },
        { title = self:getText("ui_pmHistoryColumnRecent", "Letzte Ereignisse"), lines = secondColumn },
        { title = self:getText("ui_pmHistoryColumnTotals", "Summen"), lines = thirdColumn }
    }
end
