HelperPersonnelHelperBridge = {}
HelperPersonnelHelperBridge_mt = Class(HelperPersonnelHelperBridge)

HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J"
}

HelperPersonnelHelperBridge.GENDER_MALE = "male"
HelperPersonnelHelperBridge.GENDER_FEMALE = "female"

HelperPersonnelHelperBridge.BASE_HELPER_GENDERS_BY_NAME = {
    A = HelperPersonnelHelperBridge.GENDER_MALE,
    B = HelperPersonnelHelperBridge.GENDER_MALE,
    C = HelperPersonnelHelperBridge.GENDER_FEMALE,
    D = HelperPersonnelHelperBridge.GENDER_FEMALE,
    E = HelperPersonnelHelperBridge.GENDER_MALE,
    F = HelperPersonnelHelperBridge.GENDER_FEMALE,
    G = HelperPersonnelHelperBridge.GENDER_MALE,
    H = HelperPersonnelHelperBridge.GENDER_MALE,
    I = HelperPersonnelHelperBridge.GENDER_FEMALE,
    J = HelperPersonnelHelperBridge.GENDER_MALE
}

HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_GENDER = {
    [HelperPersonnelHelperBridge.GENDER_MALE] = {"A", "B", "E", "G", "H", "J"},
    [HelperPersonnelHelperBridge.GENDER_FEMALE] = {"C", "D", "F", "I"}
}

function HelperPersonnelHelperBridge.new(app, customMt)
    local self = setmetatable({}, customMt or HelperPersonnelHelperBridge_mt)

    self.app = app
    self.customProfilesByWorkerId = {}
    self.customProfilesByHelperName = {}
    self.workerIdByHelperIndex = {}
    self.jobWorkerIds = {}
    self.workerJobById = {}
    self.vehicleWorkerIds = {}
    self.portraitFilenamesByWorkerId = {}
    self.portraitFilenamesByBaseHelperIndex = {}

    return self
end

function HelperPersonnelHelperBridge:delete()
    self.customProfilesByWorkerId = {}
    self.customProfilesByHelperName = {}
    self.workerIdByHelperIndex = {}
    self.jobWorkerIds = {}
    self.workerJobById = {}
    self.vehicleWorkerIds = {}
    self.portraitFilenamesByWorkerId = {}
    self.portraitFilenamesByBaseHelperIndex = {}
end

function HelperPersonnelHelperBridge:getHelperIndexName(worker)
    if worker == nil or worker.id == nil then
        return nil
    end

    return string.format("HP_WORKER_%d", worker.id)
end

function HelperPersonnelHelperBridge:clearWorkerMapping(workerId)
    local helper = self.customProfilesByWorkerId[workerId]
    if helper ~= nil then
        if helper.index ~= nil then
            self.workerIdByHelperIndex[helper.index] = nil
        end

        if self.customProfilesByHelperName ~= nil then
            if helper.helperPersonnelKey ~= nil then
                self.customProfilesByHelperName[helper.helperPersonnelKey] = nil
            end

            local fallbackKey = self:getHelperIndexName({ id = workerId })
            if fallbackKey ~= nil then
                self.customProfilesByHelperName[fallbackKey] = nil
            end
        end
    end

    self.customProfilesByWorkerId[workerId] = nil
end

function HelperPersonnelHelperBridge:clearCustomProfiles()
    self.customProfilesByWorkerId = {}
    self.customProfilesByHelperName = {}
    self.workerIdByHelperIndex = {}
    self.portraitFilenamesByWorkerId = {}
end

function HelperPersonnelHelperBridge:rebuildHelperProfiles()
    self:clearCustomProfiles()

    if self.app == nil or self.app.manager == nil then
        return
    end

    for _, worker in ipairs(self.app.manager.workers or {}) do
        self:ensureHelperProfile(worker)
    end
end

function HelperPersonnelHelperBridge:normalizeGender(gender)
    if gender == HelperPersonnelHelperBridge.GENDER_MALE or gender == HelperPersonnelHelperBridge.GENDER_FEMALE then
        return gender
    end

    if type(gender) == "string" then
        local lowerGender = string.lower(gender)
        if lowerGender == "m" or lowerGender == "male" or lowerGender == "mann" or lowerGender == "maennlich" or lowerGender == "männlich" then
            return HelperPersonnelHelperBridge.GENDER_MALE
        elseif lowerGender == "f" or lowerGender == "female" or lowerGender == "frau" or lowerGender == "weiblich" then
            return HelperPersonnelHelperBridge.GENDER_FEMALE
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getDesiredGenderForWorker(worker)
    if self.app ~= nil and self.app.manager ~= nil and self.app.manager.getGenderForPerson ~= nil then
        return self:normalizeGender(self.app.manager:getGenderForPerson(worker))
    end

    if type(worker) == "table" then
        return self:normalizeGender(worker.gender)
    end

    return nil
end

function HelperPersonnelHelperBridge:normalizeBaseHelperName(name)
    if type(name) ~= "string" then
        return nil
    end

    local helperName = string.upper(name)
    helperName = string.gsub(helperName, "^HELPER_", "")
    helperName = string.gsub(helperName, "^HELPER", "")

    if string.len(helperName) == 1 then
        return helperName
    end

    return nil
end

function HelperPersonnelHelperBridge:getFallbackGenderForBaseHelperName(name)
    local normalizedName = self:normalizeBaseHelperName(name)
    if normalizedName == nil then
        return nil
    end

    return HelperPersonnelHelperBridge.BASE_HELPER_GENDERS_BY_NAME[normalizedName]
end

function HelperPersonnelHelperBridge:detectGenderHintFromString(value)
    if type(value) ~= "string" then
        return nil
    end

    local lowerValue = string.lower(value)

    if string.find(lowerValue, "playerf", 1, true) ~= nil or string.find(lowerValue, "/f/", 1, true) ~= nil or string.find(lowerValue, "\\f\\", 1, true) ~= nil then
        return HelperPersonnelHelperBridge.GENDER_FEMALE
    end

    if string.find(lowerValue, "playerm", 1, true) ~= nil or string.find(lowerValue, "/m/", 1, true) ~= nil or string.find(lowerValue, "\\m\\", 1, true) ~= nil then
        return HelperPersonnelHelperBridge.GENDER_MALE
    end

    if string.find(lowerValue, "female", 1, true) ~= nil or string.find(lowerValue, "woman", 1, true) ~= nil or string.find(lowerValue, "frau", 1, true) ~= nil or string.find(lowerValue, "weiblich", 1, true) ~= nil then
        return HelperPersonnelHelperBridge.GENDER_FEMALE
    end

    if string.find(lowerValue, "male", 1, true) ~= nil or string.find(lowerValue, "man", 1, true) ~= nil or string.find(lowerValue, "mann", 1, true) ~= nil or string.find(lowerValue, "maennlich", 1, true) ~= nil or string.find(lowerValue, "männlich", 1, true) ~= nil then
        return HelperPersonnelHelperBridge.GENDER_MALE
    end

    return nil
end

function HelperPersonnelHelperBridge:getSelectedConfigItem(config)
    if type(config) ~= "table" then
        return nil
    end

    if config.getSelectedItem ~= nil then
        local ok, selectedItem = pcall(function()
            return config:getSelectedItem()
        end)

        if ok then
            return selectedItem
        end
    end

    local selectedIndex = tonumber(config.selectedIndex or config.selectedItemIndex or config.state)
    if selectedIndex ~= nil and type(config.items) == "table" then
        return config.items[selectedIndex] or config.items[selectedIndex + 1]
    end

    return nil
end

function HelperPersonnelHelperBridge:normalizeHeadPortraitFilename(value)
    if type(value) ~= "string" then
        return nil
    end

    local cleanValue = string.gsub(value, "\\", "/")
    local lowerValue = string.lower(cleanValue)

    if string.find(lowerValue, "/heads/", 1, true) == nil then
        return nil
    end

    local path = cleanValue:match("(%$dataS/character/playerM/heads/[^%s%\"%\'<%>%)]*)")
        or cleanValue:match("(%$dataS/character/playerF/heads/[^%s%\"%\'<%>%)]*)")
        or cleanValue:match("(dataS/character/playerM/heads/[^%s%\"%\'<%>%)]*)")
        or cleanValue:match("(dataS/character/playerF/heads/[^%s%\"%\'<%>%)]*)")

    if path == nil or path == "" then
        return nil
    end

    path = string.gsub(path, "^%$dataS/", "dataS/")
    path = string.gsub(path, "%.i3d$", ".png")
    path = string.gsub(path, "%.xml$", ".png")

    if string.find(string.lower(path), "%.png$") == nil then
        path = path .. ".png"
    end

    return path
end

function HelperPersonnelHelperBridge:findHeadPortraitFilename(value, depth, visited)
    if value == nil then
        return nil
    end

    if type(value) == "string" then
        return self:normalizeHeadPortraitFilename(value)
    end

    if type(value) ~= "table" then
        return nil
    end

    depth = depth or 0
    if depth > 7 then
        return nil
    end

    visited = visited or {}
    if visited[value] == true then
        return nil
    end
    visited[value] = true

    local selectedItem = nil
    local okSelected, result = pcall(function()
        return self:getSelectedConfigItem(value)
    end)

    if okSelected then
        selectedItem = result
    end

    if selectedItem ~= nil and selectedItem ~= value then
        local selectedFilename = self:findHeadPortraitFilename(selectedItem, depth + 1, visited)
        if selectedFilename ~= nil then
            return selectedFilename
        end
    end

    local priorityKeys = {
        "filename", "xmlFilename", "i3dFilename", "iconFilename", "previewFilename",
        "head", "heads", "headConfig", "face", "faceConfig", "selectedItem", "items", "configurations"
    }

    for _, key in ipairs(priorityKeys) do
        local childValue = value[key]
        local filename = self:findHeadPortraitFilename(childValue, depth + 1, visited)
        if filename ~= nil then
            return filename
        end
    end

    for key, childValue in pairs(value) do
        if type(key) ~= "string" or string.sub(key, 1, 2) ~= "__" then
            local filename = self:findHeadPortraitFilename(childValue, depth + 1, visited)
            if filename ~= nil then
                return filename
            end
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getPortraitFilenameForPlayerStyle(playerStyle)
    return self:findHeadPortraitFilename(playerStyle, 0, {})
end

function HelperPersonnelHelperBridge:getFallbackPortraitFilenameForPerson(person)
    local index = tonumber(person ~= nil and person.avatarIndex or nil) or 0

    local fallbackPortraits = {
        [1] = "dataS/character/playerM/heads/mHead01.png",
        [2] = "dataS/character/playerM/heads/mHead02.png",
        [3] = "dataS/character/playerF/heads/fHead01.png",
        [4] = "dataS/character/playerF/heads/fHead02.png",
        [5] = "dataS/character/playerM/heads/mHead03.png",
        [6] = "dataS/character/playerF/heads/fHead03.png",
        [7] = "dataS/character/playerM/heads/mHead04.png",
        [8] = "dataS/character/playerM/heads/mHead05.png",
        [9] = "dataS/character/playerF/heads/fHead04.png",
        [10] = "dataS/character/playerM/heads/mHead06.png"
    }

    if fallbackPortraits[index] ~= nil then
        return fallbackPortraits[index]
    end

    local gender = self:getDesiredGenderForWorker(person)
    if gender == HelperPersonnelHelperBridge.GENDER_FEMALE then
        return "dataS/character/playerF/heads/fHead01.png"
    end

    return "dataS/character/playerM/heads/mHead01.png"
end

function HelperPersonnelHelperBridge:getPortraitFilenameForBaseHelper(helper)
    if helper == nil then
        return nil
    end

    if helper.helperPersonnelPortraitFilename ~= nil then
        return helper.helperPersonnelPortraitFilename
    end

    local filename = self:getPortraitFilenameForPlayerStyle(helper.playerStyle)
    helper.helperPersonnelPortraitFilename = filename

    if filename ~= nil and helper.index ~= nil then
        self.portraitFilenamesByBaseHelperIndex[helper.index] = filename
    end

    return filename
end

function HelperPersonnelHelperBridge:getBaseHelperBySavedIndex(person)
    if person == nil or g_helperManager == nil or g_helperManager.getHelperByIndex == nil then
        return nil
    end

    local baseHelperIndex = tonumber(person.assignedBaseHelperIndex)
    if baseHelperIndex == nil then
        return nil
    end

    local helper = g_helperManager:getHelperByIndex(baseHelperIndex)
    if helper ~= nil and helper.playerStyle ~= nil and helper.helperPersonnelWorkerId == nil then
        return helper
    end

    return nil
end

function HelperPersonnelHelperBridge:getPortraitFilenameForPerson(person)
    if type(person) ~= "table" then
        return self:getFallbackPortraitFilenameForPerson(nil)
    end

    if person.helperPersonnelPortraitFilename ~= nil then
        return person.helperPersonnelPortraitFilename
    end

    if person.id ~= nil and self.portraitFilenamesByWorkerId[person.id] ~= nil then
        return self.portraitFilenamesByWorkerId[person.id]
    end

    local helper = self:getBaseHelperBySavedIndex(person)
    if helper == nil then
        helper = self:getBaseHelperForWorker(person)
    end

    local filename = self:getPortraitFilenameForBaseHelper(helper)
    if filename == nil then

        return self:getFallbackPortraitFilenameForPerson(person)
    end

    person.helperPersonnelPortraitFilename = filename
    if person.id ~= nil then
        self.portraitFilenamesByWorkerId[person.id] = filename
    end

    return filename
end

function HelperPersonnelHelperBridge:detectGenderFromPlayerStyle(playerStyle)
    if type(playerStyle) ~= "table" then
        return nil
    end

    local portraitFilename = self:getPortraitFilenameForPlayerStyle(playerStyle)
    local portraitGender = self:detectGenderHintFromString(portraitFilename)
    if portraitGender ~= nil then
        return portraitGender
    end

    local directFields = {
        "gender",
        "sex",
        "name",
        "filename",
        "xmlFilename",
        "configFileName"
    }

    for _, fieldName in ipairs(directFields) do
        local gender = self:detectGenderHintFromString(playerStyle[fieldName])
        if gender ~= nil then
            return gender
        end
    end

    local configNames = {
        "body", "head", "face", "hair", "hairStyle", "beard", "outfit", "top", "bottom", "character"
    }

    for _, configName in ipairs(configNames) do
        local config = nil

        if type(playerStyle.configs) == "table" then
            config = playerStyle.configs[configName]
        end

        if config == nil then
            config = playerStyle[configName]
        end

        if type(config) == "table" then
            local gender = self:detectGenderHintFromString(config.gender) or self:detectGenderHintFromString(config.name) or self:detectGenderHintFromString(config.filename) or self:detectGenderHintFromString(config.xmlFilename)
            if gender ~= nil then
                return gender
            end

            local selectedItem = self:getSelectedConfigItem(config)
            if type(selectedItem) == "table" then
                gender = self:detectGenderHintFromString(selectedItem.gender) or self:detectGenderHintFromString(selectedItem.name) or self:detectGenderHintFromString(selectedItem.filename) or self:detectGenderHintFromString(selectedItem.xmlFilename)
                if gender ~= nil then
                    return gender
                end
            end
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getBaseHelperName(baseHelper)
    if type(baseHelper) ~= "table" then
        return nil
    end

    if baseHelper.helperPersonnelBaseNameFallback ~= nil then
        return baseHelper.helperPersonnelBaseNameFallback
    end

    if type(baseHelper.getName) == "function" then
        local ok, name = pcall(baseHelper.getName, baseHelper)
        if ok and name ~= nil then
            return name
        end
    end

    return baseHelper.name or baseHelper.title or baseHelper.i18nName or baseHelper.configName or baseHelper.xmlFilename
end

function HelperPersonnelHelperBridge:getBaseHelperByIndex(index)
    if g_helperManager == nil or g_helperManager.getHelperByIndex == nil then
        return nil
    end

    index = math.floor(tonumber(index) or 0)
    if index <= 0 then
        return nil
    end

    if g_helperManager.getNumOfHelpers ~= nil then
        local okCount, count = pcall(function()
            return g_helperManager:getNumOfHelpers()
        end)
        count = okCount and (tonumber(count) or 0) or 0
        if count > 0 and index > count then
            return nil
        end
    end

    local okHelper, helper = pcall(function()
        return g_helperManager:getHelperByIndex(index)
    end)
    if not okHelper or type(helper) ~= "table" then
        return nil
    end

    helper.index = helper.index or index
    helper.helperPersonnelBaseNameFallback = helper.helperPersonnelBaseNameFallback or HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR[index]

    return helper
end

function HelperPersonnelHelperBridge:getBaseHelperGender(baseHelper, index)
    local playerStyle = baseHelper ~= nil and baseHelper.playerStyle or nil
    local detectedGender = self:detectGenderFromPlayerStyle(playerStyle)
    if detectedGender ~= nil then
        return detectedGender
    end

    local portraitFilename = self:getPortraitFilenameForPlayerStyle(playerStyle)
    detectedGender = self:detectGenderHintFromString(portraitFilename)
    if detectedGender ~= nil then
        return detectedGender
    end

    local helperName = self:getBaseHelperName(baseHelper)
    detectedGender = self:detectGenderHintFromString(helperName)
    if detectedGender ~= nil then
        return detectedGender
    end

    helperName = baseHelper ~= nil and baseHelper.helperPersonnelBaseNameFallback or nil
    detectedGender = self:getFallbackGenderForBaseHelperName(helperName)
    if detectedGender ~= nil then
        return detectedGender
    end

    if index ~= nil then
        helperName = HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR[index]
        detectedGender = self:getFallbackGenderForBaseHelperName(helperName)
        if detectedGender ~= nil then
            return detectedGender
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:doesHelperMatchGender(helper, desiredGender)
    desiredGender = self:normalizeGender(desiredGender)
    if desiredGender == nil then
        return true
    end

    local helperGender = self:getBaseHelperGender(helper)
    return helperGender == desiredGender
end

function HelperPersonnelHelperBridge:getHelperByPossibleNames(baseHelperName)
    if g_helperManager == nil or g_helperManager.getHelperByName == nil or baseHelperName == nil then
        return nil
    end

    local candidates = {
        baseHelperName,
        string.format("HELPER_%s", baseHelperName),
        string.format("HELPER%s", baseHelperName),
        string.format("helper_%s", baseHelperName),
        string.format("helper%s", baseHelperName)
    }

    for _, candidate in ipairs(candidates) do
        local helper = g_helperManager:getHelperByName(candidate)
        if helper ~= nil and helper.playerStyle ~= nil and helper.helperPersonnelWorkerId == nil then
            helper.helperPersonnelBaseNameFallback = baseHelperName
            return helper
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:findBaseHelperByGender(desiredGender, preferredOffset)
    desiredGender = self:normalizeGender(desiredGender)
    if desiredGender == nil or g_helperManager == nil then
        return nil
    end

    local helperNames = HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_GENDER[desiredGender]
    if type(helperNames) == "table" and #helperNames > 0 then
        preferredOffset = tonumber(preferredOffset) or 1

        for i = 1, #helperNames do
            local index = ((preferredOffset + i - 2) % #helperNames) + 1
            local helper = self:getHelperByPossibleNames(helperNames[index])
            if helper ~= nil and self:doesHelperMatchGender(helper, desiredGender) then
                return helper
            end
        end
    end

    if g_helperManager.getNumOfHelpers ~= nil and g_helperManager.getHelperByIndex ~= nil then
        local count = tonumber(g_helperManager:getNumOfHelpers()) or 0
        for index = 1, count do
            local helper = g_helperManager:getHelperByIndex(index)
            if helper ~= nil and helper.playerStyle ~= nil and helper.helperPersonnelWorkerId == nil and self:doesHelperMatchGender(helper, desiredGender) then
                return helper
            end
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getAvatarIndexForWorker(worker)
    local baseHelpers = HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR or {}
    local count = #baseHelpers

    if count <= 0 then
        return 1
    end

    local avatarIndex = tonumber(worker ~= nil and worker.avatarIndex or nil) or 0
    if avatarIndex < 1 or avatarIndex > count then
        local personId = tonumber(worker ~= nil and worker.id or nil) or 1
        avatarIndex = ((math.max(1, personId) - 1) % count) + 1
    end

    return math.floor(avatarIndex)
end

function HelperPersonnelHelperBridge:getBaseHelperNameForWorker(worker)
    local index = self:getAvatarIndexForWorker(worker)
    return (HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR or {})[index], index
end

function HelperPersonnelHelperBridge:getGenderForBaseHelperIndex(index)
    index = tonumber(index) or 0
    if index <= 0 then
        return nil
    end

    local baseHelper = self:getBaseHelperByIndex(index)
    if baseHelper ~= nil then
        return self:getBaseHelperGender(baseHelper, index)
    end

    local helperName = HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR[index]
    if helperName ~= nil then
        return self:getFallbackGenderForBaseHelperName(helperName)
    end

    return nil
end

function HelperPersonnelHelperBridge:getAvatarIndicesForGender(gender)
    gender = self:normalizeGender(gender)
    if gender == nil then
        return {}
    end

    local result = {}
    local maxIndex = HelperPersonnelManager ~= nil and HelperPersonnelManager.PORTRAIT_COUNT or #HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR

    for index = 1, maxIndex do
        local helperGender = self:getGenderForBaseHelperIndex(index)
        if helperGender == gender then
            table.insert(result, index)
        end
    end

    if #result == 0 then
        for index, helperName in ipairs(HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR) do
            local helperGender = self:getFallbackGenderForBaseHelperName(helperName)
            if helperGender == gender then
                table.insert(result, index)
            end
        end
    end

    return result
end

function HelperPersonnelHelperBridge:getBaseHelperForWorker(worker)
    if g_helperManager == nil then
        return nil
    end

    local desiredGender = self:getDesiredGenderForWorker(worker)
    local savedHelper = self:getBaseHelperBySavedIndex(worker)
    if savedHelper ~= nil then
        return savedHelper
    end
    local baseHelperName, avatarIndex = self:getBaseHelperNameForWorker(worker)
    local firstUsableFallback = nil

    if baseHelperName ~= nil then
        local helper = self:getHelperByPossibleNames(baseHelperName)
        if helper ~= nil then
            if self:doesHelperMatchGender(helper, desiredGender) then
                return helper
            end

            firstUsableFallback = helper
        end
    end

    local genderMatchedHelper = self:findBaseHelperByGender(desiredGender, avatarIndex)
    if genderMatchedHelper ~= nil then
        return genderMatchedHelper
    end

    if avatarIndex ~= nil and g_helperManager.getHelperByIndex ~= nil then
        local helper = g_helperManager:getHelperByIndex(avatarIndex)
        if helper ~= nil and helper.playerStyle ~= nil and helper.helperPersonnelWorkerId == nil then
            helper.helperPersonnelBaseNameFallback = HelperPersonnelHelperBridge.BASE_HELPER_NAMES_BY_AVATAR[avatarIndex]
            if self:doesHelperMatchGender(helper, desiredGender) then
                return helper
            end

            if firstUsableFallback == nil then
                firstUsableFallback = helper
            end
        end
    end

    return firstUsableFallback
end

function HelperPersonnelHelperBridge:getPlayerStyleForWorker(worker)
    local baseHelper = self:getBaseHelperForWorker(worker)
    if baseHelper ~= nil and baseHelper.playerStyle ~= nil then
        return baseHelper.playerStyle, baseHelper.name or baseHelper.title
    end

    if g_helperManager ~= nil and g_helperManager.getRandomHelperStyle ~= nil then
        local desiredGender = self:getDesiredGenderForWorker(worker)

        for _ = 1, 10 do
            local playerStyle = g_helperManager:getRandomHelperStyle()
            if playerStyle ~= nil and (desiredGender == nil or self:detectGenderFromPlayerStyle(playerStyle) == desiredGender) then
                return playerStyle, nil
            end
        end

        return g_helperManager:getRandomHelperStyle(), nil
    end

    return nil, nil
end

function HelperPersonnelHelperBridge:ensureHelperProfile(worker)
    if worker == nil or g_helperManager == nil then
        return nil
    end

    local helperKey = self:getHelperIndexName(worker)
    if helperKey == nil then
        return nil
    end

    local helper = self.customProfilesByWorkerId[worker.id]
    if helper == nil then
        helper = g_helperManager:getHelperByName(helperKey)
    end

    local title = self.app.manager:getFullName(worker)
    local baseHelper = self:getBaseHelperForWorker(worker)
    local playerStyle = baseHelper ~= nil and baseHelper.playerStyle or nil
    local baseHelperName = baseHelper ~= nil and (baseHelper.helperPersonnelBaseNameFallback or baseHelper.name or baseHelper.title) or nil
    local baseHelperIndex = baseHelper ~= nil and baseHelper.index or nil

    if playerStyle == nil then
        playerStyle, baseHelperName = self:getPlayerStyleForWorker(worker)
    end

    if helper == nil then
        helper = g_helperManager:addHelper(helperKey, title, {1, 1, 1}, playerStyle, self.app.modDir, false)
    else
        helper.title = title
        if playerStyle ~= nil then
            helper.playerStyle = playerStyle
        end
    end

    if helper ~= nil then

        helper.name = title
        helper.title = title
        helper.helperPersonnelKey = helperKey
        helper.helperPersonnelWorkerId = worker.id
        helper.helperPersonnelDisplayName = title
        helper.helperPersonnelAvatarIndex = self:getAvatarIndexForWorker(worker)
        helper.helperPersonnelBaseHelperName = baseHelperName
        helper.helperPersonnelBaseHelperIndex = baseHelperIndex or helper.helperPersonnelBaseHelperIndex
        helper.helperPersonnelPortraitFilename = self:getPortraitFilenameForBaseHelper(baseHelper) or self:getPortraitFilenameForPlayerStyle(playerStyle)

        worker.helperPersonnelPortraitFilename = helper.helperPersonnelPortraitFilename
        if worker.id ~= nil and helper.helperPersonnelPortraitFilename ~= nil then
            self.portraitFilenamesByWorkerId[worker.id] = helper.helperPersonnelPortraitFilename
        end

        worker.assignedHelperIndex = helper.index
        worker.assignedBaseHelperIndex = baseHelperIndex or worker.assignedBaseHelperIndex or helper.helperPersonnelBaseHelperIndex

        if self.customProfilesByHelperName == nil then
            self.customProfilesByHelperName = {}
        end

        self.customProfilesByWorkerId[worker.id] = helper
        self.customProfilesByHelperName[helperKey] = worker.id
        self.workerIdByHelperIndex[helper.index] = worker.id

        if worker.assignedBaseHelperIndex ~= nil and (worker.busy == true or worker.restorePending == true) then
            self.workerIdByHelperIndex[worker.assignedBaseHelperIndex] = worker.id
        end

        if g_helperManager.useHelper ~= nil then
            g_helperManager:useHelper(helper)
        end
    end

    return helper
end

function HelperPersonnelHelperBridge:applyWorkerToJob(job, workerId)
    if job == nil or workerId == nil then
        return nil
    end

    local worker = self.app.manager:getWorkerById(workerId)
    if worker == nil then
        return nil
    end

    local helper = self:ensureHelperProfile(worker)
    if helper ~= nil then
        job.helperIndex = helper.index
        job.helperPersonnelBaseHelperIndex = worker.assignedBaseHelperIndex or helper.helperPersonnelBaseHelperIndex
        job.helperPersonnelBaseHelperName = helper.helperPersonnelBaseHelperName
    end

    worker.assignedHelperIndex = helper ~= nil and helper.index or worker.assignedHelperIndex
    worker.assignedBaseHelperIndex = job.helperPersonnelBaseHelperIndex or worker.assignedBaseHelperIndex
    job.helperPersonnelWorkerId = workerId
    return helper
end

function HelperPersonnelHelperBridge:getVehicleFromJob(job)
    if job == nil then
        return nil
    end

    if job.vehicle ~= nil then
        return job.vehicle
    end

    if job.vehicleParameter ~= nil then
        if job.vehicleParameter.getVehicle ~= nil then
            local success, vehicle = pcall(job.vehicleParameter.getVehicle, job.vehicleParameter)
            if success and vehicle ~= nil then
                return vehicle
            end
        end

        if job.vehicleParameter.vehicle ~= nil then
            return job.vehicleParameter.vehicle
        end
    end

    if job.getVehicle ~= nil then
        local success, vehicle = pcall(job.getVehicle, job)
        if success and vehicle ~= nil then
            return vehicle
        end
    end

    if job.getNamedParameter ~= nil then
        local vehicleParameter = job:getNamedParameter("VEHICLE") or job:getNamedParameter("vehicle")
        if vehicleParameter ~= nil then
            if vehicleParameter.getVehicle ~= nil then
                local success, vehicle = pcall(vehicleParameter.getVehicle, vehicleParameter)
                if success and vehicle ~= nil then
                    return vehicle
                end
            end

            if vehicleParameter.getValue ~= nil then
                local success, vehicle = pcall(vehicleParameter.getValue, vehicleParameter)
                if success and vehicle ~= nil then
                    return vehicle
                end
            end

            if vehicleParameter.vehicle ~= nil then
                return vehicleParameter.vehicle
            end
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getVehicleKeyFromJob(job)
    if self.app == nil or job == nil or self.app.getVehicleKey == nil then
        return nil
    end

    local vehicle = self:getVehicleFromJob(job)
    return self.app:getVehicleKey(vehicle)
end

function HelperPersonnelHelperBridge:getVehicleNameFromJob(job)
    if self.app == nil or job == nil then
        return nil
    end

    local vehicle = self:getVehicleFromJob(job)
    if self.app.getRootVehicle ~= nil then
        vehicle = self.app:getRootVehicle(vehicle)
    end

    if self.app.getVehicleName ~= nil then
        return self.app:getVehicleName(vehicle)
    end

    return nil
end

function HelperPersonnelHelperBridge:getWorkerIdByVehicle(vehicle)
    if self.app == nil or vehicle == nil or self.app.getVehicleKey == nil then
        return nil
    end

    local key = self.app:getVehicleKey(vehicle)
    if key == nil then
        return nil
    end

    return self.vehicleWorkerIds[key]
end

function HelperPersonnelHelperBridge:getWorkerIdByVehicleKey(vehicleKey)
    if vehicleKey == nil then
        return nil
    end

    local workerId = self.vehicleWorkerIds[vehicleKey]
    if workerId ~= nil then
        return workerId
    end

    if self.app ~= nil and self.app.manager ~= nil and self.app.manager.getWorkerByVehicleKey ~= nil then
        local worker = self.app.manager:getWorkerByVehicleKey(vehicleKey)
        if worker ~= nil then
            return worker.id
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getWorkerIdFromHelperName(helperName)
    if helperName == nil then
        return nil
    end

    local helperNameString = tostring(helperName)

    if self.customProfilesByHelperName ~= nil and self.customProfilesByHelperName[helperNameString] ~= nil then
        return self.customProfilesByHelperName[helperNameString]
    end

    local workerId = string.match(helperNameString, "^HP_WORKER_(%d+)$")
    if workerId ~= nil then
        return tonumber(workerId)
    end

    return nil
end

function HelperPersonnelHelperBridge:getWorkerIdByHelperIndex(helperIndex)
    if helperIndex == nil then
        return nil
    end

    local workerId = self.workerIdByHelperIndex[helperIndex]
    if workerId ~= nil then
        return workerId
    end

    if g_helperManager ~= nil and g_helperManager.getHelperByIndex ~= nil then
        local helper = g_helperManager:getHelperByIndex(helperIndex)
        if helper ~= nil then
            workerId = helper.helperPersonnelWorkerId

            if workerId == nil and helper.helperPersonnelKey ~= nil then
                workerId = self:getWorkerIdFromHelperName(helper.helperPersonnelKey)
            end

            if workerId == nil then
                workerId = self:getWorkerIdFromHelperName(helper.name)
            end

            if workerId == nil then
                workerId = self:getWorkerIdFromHelperName(helper.title)
            end

            if workerId ~= nil then
                self.workerIdByHelperIndex[helperIndex] = workerId
                return workerId
            end
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:getWorkerByHelperIndex(helperIndex)
    local workerId = self:getWorkerIdByHelperIndex(helperIndex)
    if workerId ~= nil and self.app ~= nil and self.app.manager ~= nil then
        return self.app.manager:getWorkerById(workerId)
    end

    return nil
end

function HelperPersonnelHelperBridge:getWorkerIdByJob(job)
    if job == nil then
        return nil
    end

    local workerId = self.jobWorkerIds[job] or job.helperPersonnelWorkerId
    if workerId ~= nil then
        return workerId
    end

    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.isFollowMeJob ~= nil and HelperPersonnelAIJobHooks.isFollowMeJob(job) then
        return nil
    end

    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        workerId = self:getWorkerIdByVehicleKey(vehicleKey)
        if workerId ~= nil then
            return workerId
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:resolveRestoredWorkerIdForJob(job)
    if job == nil or self.app == nil or self.app.manager == nil then
        return nil
    end

    local workerId = self:getWorkerIdByJob(job)
    if workerId ~= nil then
        return workerId
    end

    local vehicle = self:getVehicleFromJob(job)
    local vehicleKey = self:getVehicleKeyFromJob(job)
    local vehicleName = self:getVehicleNameFromJob(job)

    if self.app.manager.findRestoredWorkerIdForVehicle ~= nil then
        local restoredWorkerId = self.app.manager:findRestoredWorkerIdForVehicle(vehicleKey, vehicleName)
        if restoredWorkerId ~= nil then
            return restoredWorkerId
        end
    end

    if vehicleKey ~= nil and self.app.manager.getWorkerByVehicleKey ~= nil then
        local worker = self.app.manager:getWorkerByVehicleKey(vehicleKey)
        if worker ~= nil and worker.restorePending == true then
            return worker.id
        end
    end

    local rootVehicle = vehicle
    if self.app.getRootVehicle ~= nil then
        rootVehicle = self.app:getRootVehicle(vehicle)
    end

    local vehicleName = nil
    if self.app.getVehicleName ~= nil then
        vehicleName = self.app:getVehicleName(rootVehicle)
    end

    if vehicleName ~= nil and vehicleName ~= "" and self.app.manager.getPendingRestoredWorkerByVehicleName ~= nil then
        local worker = self.app.manager:getPendingRestoredWorkerByVehicleName(vehicleName)
        if worker ~= nil then
            return worker.id
        end
    end

    if self.app.manager.getSinglePendingRestoredWorker ~= nil then
        local worker = self.app.manager:getSinglePendingRestoredWorker()
        if worker ~= nil then
            return worker.id
        end
    end

    return nil
end

function HelperPersonnelHelperBridge:hasPendingRestoredWorkers()
    if self.app == nil or self.app.manager == nil or self.app.manager.getPendingRestoredWorkerCount == nil then
        return false
    end

    return self.app.manager:getPendingRestoredWorkerCount() > 0
end

function HelperPersonnelHelperBridge:isWorkerSelectable(workerId)
    if self.app == nil or self.app.manager == nil then
        return false
    end

    if self.app.manager.isWorkerAvailable ~= nil and not self.app.manager:isWorkerAvailable(workerId) then
        return false
    end

    return self.workerJobById[workerId] == nil
end

function HelperPersonnelHelperBridge:hasActiveJobForWorker(workerId)
    if workerId == nil then
        return false
    end

    return self.workerJobById[workerId] ~= nil
end

function HelperPersonnelHelperBridge:canUseWorkerForJob(workerId, job)
    if self.app == nil or self.app.manager == nil then
        return false
    end

    local worker = self.app.manager:getWorkerById(workerId)
    if worker == nil then
        return false
    end

    local assignedJob = self.workerJobById[workerId]
    if assignedJob ~= nil and assignedJob ~= job then
        return false
    end

    if worker.busy == true and assignedJob ~= job then
        if assignedJob == nil and job ~= nil and (job.helperPersonnelWorkerId == workerId or self:getWorkerIdByJob(job) == workerId) then
            return true
        end

        return false
    end

    return true
end

function HelperPersonnelHelperBridge:attachRestoredJob(job, workerId)
    if job == nil or workerId == nil or self.app == nil or self.app.manager == nil then
        return false
    end

    local worker = self.app.manager:getWorkerById(workerId)
    if worker == nil then
        return false
    end

    if worker.assignedBaseHelperIndex == nil and job.helperIndex ~= nil then
        worker.assignedBaseHelperIndex = job.helperIndex
    end

    self:applyWorkerToJob(job, workerId)

    self.jobWorkerIds[job] = workerId
    self.workerJobById[workerId] = job
    job.helperPersonnelWorkerId = workerId

    local vehicle = self:getVehicleFromJob(job)
    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = workerId
        worker.vehicleKey = vehicleKey
    end

    if self.app.getRootVehicle ~= nil then
        vehicle = self.app:getRootVehicle(vehicle)
    end

    local vehicleName = ""
    if self.app.getVehicleName ~= nil then
        vehicleName = self.app:getVehicleName(vehicle)
    end

    local now = self.app.manager:getCurrentTimestampMs()
    local elapsedMs = 0

    if worker.busy ~= true then
        elapsedMs = math.max(0, worker.currentJobElapsedMs or 0)
        worker.busy = true
        worker.currentJobStartedAt = now - elapsedMs
        worker.currentJobElapsedMs = 0
    elseif worker.currentJobStartedAt == nil or worker.currentJobStartedAt <= 0 then
        elapsedMs = math.max(0, worker.currentJobElapsedMs or 0)
        worker.currentJobStartedAt = now - elapsedMs
        worker.currentJobElapsedMs = 0
    end

    worker.restorePending = false
    worker.restoreVehicleName = nil
    worker.restoreVehicleKey = nil

    if vehicleName ~= nil and vehicleName ~= "" then
        worker.vehicleName = vehicleName
    end

    if self.app.manager.consumeRestoredWorkerId ~= nil then
        self.app.manager:consumeRestoredWorkerId(workerId, vehicleKey)
    end

    return true
end

function HelperPersonnelHelperBridge:onJobStarted(job, workerId)
    if job == nil or workerId == nil then
        return
    end

    self.jobWorkerIds[job] = workerId
    self.workerJobById[workerId] = job
    job.helperPersonnelWorkerId = workerId

    local vehicle = self:getVehicleFromJob(job)
    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = workerId
        local worker = self.app.manager:getWorkerById(workerId)
        if worker ~= nil then
            worker.vehicleKey = vehicleKey
        end
    end

    vehicle = self.app:getRootVehicle(vehicle)
    local vehicleName = self.app:getVehicleName(vehicle)

    if self.app.manager.startWorkerJob ~= nil then
        self.app.manager:startWorkerJob(workerId, vehicleName, vehicleKey)
    else
        self.app.manager:setWorkerBusy(workerId, true, vehicleName, vehicleKey)
    end
end

function HelperPersonnelHelperBridge:onJobStopped(job)
    if job == nil then
        return
    end

    local workerId = self:getWorkerIdByJob(job)
    if workerId ~= nil then
        local assignedJob = self.workerJobById[workerId]
        if assignedJob == nil or assignedJob == job then
            self.workerJobById[workerId] = nil
            if self.app.manager.finishWorkerJob ~= nil then
                self.app.manager:finishWorkerJob(workerId)
            else
                self.app.manager:setWorkerBusy(workerId, false, "")
            end
        end
    end

    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = nil
    end

    self.jobWorkerIds[job] = nil
    job.helperPersonnelWorkerId = nil
end

local HP_ORIGINAL_HELPER_BRIDGE_REBUILD_PROFILES = HelperPersonnelHelperBridge.rebuildHelperProfiles
function HelperPersonnelHelperBridge:rebuildHelperProfiles()
    self:clearCustomProfiles()

    if self.app == nil or self.app.manager == nil then
        return
    end

    local workers = nil
    if self.app.manager.getAllWorkers ~= nil then
        workers = self.app.manager:getAllWorkers()
    else
        workers = self.app.manager.workers or {}
    end

    for _, worker in ipairs(workers or {}) do
        self:ensureHelperProfile(worker)
    end
end

function HelperPersonnelHelperBridge:hpIsServerAuthority()
    if self.app ~= nil and self.app.isServerAuthority ~= nil then
        return self.app:isServerAuthority() == true
    end

    if g_server ~= nil then
        return true
    end

    if g_currentMission ~= nil and g_currentMission.getIsServer ~= nil then
        return g_currentMission:getIsServer() == true
    end

    return true
end

function HelperPersonnelHelperBridge:hpSyncStateAfterJobChange(changed)
    if changed == true and self.app ~= nil and self.app.syncNetworkStateToClients ~= nil then
        self.app:syncNetworkStateToClients()
    end
end

function HelperPersonnelHelperBridge:onJobStarted(job, workerId)
    if job == nil or workerId == nil then
        return
    end

    self.jobWorkerIds = self.jobWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}

    self.jobWorkerIds[job] = workerId
    self.workerJobById[workerId] = job
    job.helperPersonnelWorkerId = workerId

    local vehicle = self:getVehicleFromJob(job)
    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = workerId
    end

    vehicle = self.app ~= nil and self.app.getRootVehicle ~= nil and self.app:getRootVehicle(vehicle) or vehicle
    local vehicleName = self.app ~= nil and self.app.getVehicleName ~= nil and self.app:getVehicleName(vehicle) or ""

    if not self:hpIsServerAuthority() then
        return
    end

    if vehicleKey ~= nil and self.app ~= nil and self.app.manager ~= nil then
        local worker = self.app.manager:getWorkerById(workerId)
        if worker ~= nil then
            worker.vehicleKey = vehicleKey
        end
    end

    local changed = false
    if self.app ~= nil and self.app.manager ~= nil then
        if self.app.manager.startWorkerJob ~= nil then
            changed = self.app.manager:startWorkerJob(workerId, vehicleName, vehicleKey) == true
        elseif self.app.manager.setWorkerBusy ~= nil then
            self.app.manager:setWorkerBusy(workerId, true, vehicleName, vehicleKey)
            changed = true
        end
    end

    self:hpSyncStateAfterJobChange(changed)
end

function HelperPersonnelHelperBridge:tryStopAIJob(job)
    if job == nil then
        return false
    end

    local aiSystem = g_currentMission ~= nil and g_currentMission.aiSystem or nil

    if aiSystem ~= nil and aiSystem.stopJob ~= nil then
        local ok, result = pcall(aiSystem.stopJob, aiSystem, job)
        if ok and result ~= false then
            return true
        end
    end

    if job.stop ~= nil then
        local ok, result = pcall(job.stop, job)
        if ok and result ~= false then
            return true
        end
    end

    local vehicle = self:getVehicleFromJob(job)
    vehicle = self.app ~= nil and self.app.getRootVehicle ~= nil and self.app:getRootVehicle(vehicle) or vehicle
    if vehicle ~= nil then
        if vehicle.stopCurrentAIJob ~= nil then
            local ok, result = pcall(vehicle.stopCurrentAIJob, vehicle)
            if ok and result ~= false then
                return true
            end
        end
        if vehicle.stopAIVehicle ~= nil then
            local ok, result = pcall(vehicle.stopAIVehicle, vehicle)
            if ok and result ~= false then
                return true
            end
        end
    end

    return false
end

function HelperPersonnelHelperBridge:abortJobForWorker(workerId)
    workerId = tonumber(workerId)
    if workerId == nil then
        return false
    end

    self.jobWorkerIds = self.jobWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}
    self.suppressFinishForWorkerId = self.suppressFinishForWorkerId or {}

    local job = self.workerJobById[workerId]
    local hasJob = job ~= nil
    local aborted = false

    if hasJob then
        self.suppressFinishForWorkerId[workerId] = true
        aborted = self:tryStopAIJob(job) == true

        local vehicleKey = self:getVehicleKeyFromJob(job)
        if vehicleKey ~= nil then
            self.vehicleWorkerIds[vehicleKey] = nil
        end
        self.jobWorkerIds[job] = nil
        job.helperPersonnelWorkerId = nil
    end

    self.workerJobById[workerId] = nil

    if self:hpIsServerAuthority() and self.app ~= nil and self.app.manager ~= nil and self.app.manager.setWorkerBusy ~= nil then
        self.app.manager:setWorkerBusy(workerId, false, "")
        aborted = true
    end

    self.suppressFinishForWorkerId[workerId] = nil

    self:hpSyncStateAfterJobChange(true)
    return aborted
end

function HelperPersonnelHelperBridge:onJobStopped(job)
    if job == nil then
        return
    end

    self.jobWorkerIds = self.jobWorkerIds or {}
    self.workerJobById = self.workerJobById or {}
    self.vehicleWorkerIds = self.vehicleWorkerIds or {}

    local workerId = self:getWorkerIdByJob(job)
    local changed = false

    if workerId ~= nil then
        local assignedJob = self.workerJobById[workerId]
        if assignedJob == nil or assignedJob == job then
            self.workerJobById[workerId] = nil
            if self:hpIsServerAuthority() and self.app ~= nil and self.app.manager ~= nil then
                local suppressFinish = self.suppressFinishForWorkerId ~= nil and self.suppressFinishForWorkerId[workerId] == true
                if suppressFinish then
                    self.suppressFinishForWorkerId[workerId] = nil
                    if self.app.manager.setWorkerBusy ~= nil then
                        self.app.manager:setWorkerBusy(workerId, false, "")
                        changed = true
                    end
                elseif self.app.manager.finishWorkerJob ~= nil then
                    changed = self.app.manager:finishWorkerJob(workerId) == true
                elseif self.app.manager.setWorkerBusy ~= nil then
                    self.app.manager:setWorkerBusy(workerId, false, "")
                    changed = true
                end
            end
        end
    end

    local vehicleKey = self:getVehicleKeyFromJob(job)
    if vehicleKey ~= nil then
        self.vehicleWorkerIds[vehicleKey] = nil
    end

    self.jobWorkerIds[job] = nil
    job.helperPersonnelWorkerId = nil

    self:hpSyncStateAfterJobChange(changed)
end
