HelperPersonnelConfig = HelperPersonnelConfig or {}
HelperPersonnelConfig_mt = Class(HelperPersonnelConfig)

HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE = 2500

HelperPersonnelConfig.xmlSchema = XMLSchema.new("helperPersonnelConfig")
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects#enabled", "Gameplay-Auswirkungen der Mitarbeiterwerte aktiv", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects.experience#enabled", "Erfahrung wirkt sich auf aktive Helferarbeit aus", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects.speed#enabled", "Erfahrung beeinflusst Arbeitsgeschwindigkeit", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects.wear#enabled", "Erfahrung beeinflusst Verschleiss", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects.consumables#enabled", "Erfahrung beeinflusst Saatgut-, Duenger-, Herbizid-, Guelle-, Gaerreste- und Mistverbrauch", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects.fuel#enabled", "Erfahrung beeinflusst Kraftstoffverbrauch", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.gameplayEffects.reliability#enabled", "Zuverlaessigkeit wirkt sich auf aktive Helferarbeit aus", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.personnelEffects#enabled", "Personalbezogene Auswirkungen der Mitarbeiterwerte aktiv", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.personnelEffects.loyalty#enabled", "Loyalitaetsveraenderungen aktiv", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.personnelEffects.loyalty.nightWork#enabled", "Nachtarbeit beeinflusst Loyalitaet und Arbeitgeberansehen", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.economicEffects#enabled", "Wirtschaftliche Einfluesse der Mitarbeiterwerte aktiv", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.BOOL, "helperPersonnelConfig.economicEffects.individualWages#enabled", "Individuelle Gehaelter aktiv", true)
HelperPersonnelConfig.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnelConfig.economicEffects.standardWage#baseMonthlyWage", "Standard-Monatsgehalt bei Referenz-Monatslaenge", HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE)

function HelperPersonnelConfig.new(manager, customMt)
    local self = setmetatable({}, customMt or HelperPersonnelConfig_mt)

    self.manager = manager
    self.gameplayEffectsEnabled = true
    self.experienceEffectsEnabled = true
    self.speedEffectEnabled = true
    self.wearEffectEnabled = true
    self.consumablesEffectEnabled = true
    self.fuelEffectEnabled = true
    self.reliabilityEffectsEnabled = true
    self.personnelEffectsEnabled = true
    self.loyaltyEffectsEnabled = true
    self.nightWorkLoyaltyEffectEnabled = true
    self.economicEffectsEnabled = true
    self.individualWagesEnabled = true
    self.standardBaseMonthlyWage = HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE

    return self
end

function HelperPersonnelConfig:getPath()
    local savePath = nil

    if self.manager ~= nil and self.manager.getSavegamePath ~= nil then
        savePath = self.manager:getSavegamePath()
    elseif self.manager ~= nil and self.manager.app ~= nil and self.manager.app.getSavegamePath ~= nil then
        savePath = self.manager.app:getSavegamePath()
    end

    if savePath == nil or savePath == "" then
        return nil
    end

    local configPath = string.gsub(savePath, "helperPersonnel%.xml$", "helperPersonnelConfig.xml")
    if configPath == savePath then
        configPath = savePath .. ".config.xml"
    end

    return configPath
end

function HelperPersonnelConfig:load()
    local path = self:getPath()
    if path == nil or path == "" then
        return false
    end

    local xmlFile = XMLFile.loadIfExists("helperPersonnelConfig", path, HelperPersonnelConfig.xmlSchema)
    if xmlFile ~= nil then
        self.gameplayEffectsEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects#enabled", true) == true
        self.experienceEffectsEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects.experience#enabled", true) == true
        self.speedEffectEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects.speed#enabled", true) == true
        self.wearEffectEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects.wear#enabled", true) == true
        self.consumablesEffectEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects.consumables#enabled", true) == true
        self.fuelEffectEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects.fuel#enabled", true) == true
        self.reliabilityEffectsEnabled = xmlFile:getBool("helperPersonnelConfig.gameplayEffects.reliability#enabled", true) == true
        self.personnelEffectsEnabled = xmlFile:getBool("helperPersonnelConfig.personnelEffects#enabled", true) == true
        self.loyaltyEffectsEnabled = xmlFile:getBool("helperPersonnelConfig.personnelEffects.loyalty#enabled", true) == true
        self.nightWorkLoyaltyEffectEnabled = xmlFile:getBool("helperPersonnelConfig.personnelEffects.loyalty.nightWork#enabled", true) == true
        self.economicEffectsEnabled = xmlFile:getBool("helperPersonnelConfig.economicEffects#enabled", true) == true
        self.individualWagesEnabled = xmlFile:getBool("helperPersonnelConfig.economicEffects.individualWages#enabled", true) == true
        self.standardBaseMonthlyWage = xmlFile:getFloat("helperPersonnelConfig.economicEffects.standardWage#baseMonthlyWage", HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE)
        xmlFile:delete()
    end

    self:save()
    return true
end

function HelperPersonnelConfig:save()
    local path = self:getPath()
    if path == nil or path == "" then
        return false
    end

    if createFolder ~= nil then
        local directory = path:match("^(.+)/helperPersonnelConfig%.xml$")
        if directory ~= nil and directory ~= "" then
            pcall(createFolder, directory)
        end
    end

    local xmlFile = XMLFile.create("helperPersonnelConfig", path, "helperPersonnelConfig", HelperPersonnelConfig.xmlSchema)
    if xmlFile == nil then
        if Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("HelperPersonnel: Konnte Konfigurationsdatei nicht erstellen: %s", path)
        end
        return false
    end

    xmlFile:setBool("helperPersonnelConfig.gameplayEffects#enabled", self.gameplayEffectsEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.gameplayEffects.experience#enabled", self.experienceEffectsEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.gameplayEffects.speed#enabled", self.speedEffectEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.gameplayEffects.wear#enabled", self.wearEffectEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.gameplayEffects.consumables#enabled", self.consumablesEffectEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.gameplayEffects.fuel#enabled", self.fuelEffectEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.gameplayEffects.reliability#enabled", self.reliabilityEffectsEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.personnelEffects#enabled", self.personnelEffectsEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.personnelEffects.loyalty#enabled", self.loyaltyEffectsEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.personnelEffects.loyalty.nightWork#enabled", self.nightWorkLoyaltyEffectEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.economicEffects#enabled", self.economicEffectsEnabled == true)
    xmlFile:setBool("helperPersonnelConfig.economicEffects.individualWages#enabled", self.individualWagesEnabled == true)
    xmlFile:setFloat("helperPersonnelConfig.economicEffects.standardWage#baseMonthlyWage", tonumber(self.standardBaseMonthlyWage) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE)

    xmlFile:save()
    xmlFile:delete()
    return true
end

function HelperPersonnelConfig:isGameplayExperienceEffectEnabled(effectName)
    if self.gameplayEffectsEnabled ~= true then
        return false
    end

    if effectName == "reliability" then
        return self.reliabilityEffectsEnabled == true
    end

    if self.experienceEffectsEnabled ~= true then
        return false
    end

    if effectName == "speed" then
        return self.speedEffectEnabled == true
    elseif effectName == "wear" then
        return self.wearEffectEnabled == true
    elseif effectName == "consumables" then
        return self.consumablesEffectEnabled == true
    elseif effectName == "fuel" then
        return self.fuelEffectEnabled == true
    end

    return true
end

function HelperPersonnelConfig:isPersonnelEffectEnabled(effectName)
    if self.personnelEffectsEnabled ~= true then
        return false
    end

    if effectName == "nightWork" then
        return self.loyaltyEffectsEnabled == true and self.nightWorkLoyaltyEffectEnabled == true
    elseif effectName == "loyalty" then
        return self.loyaltyEffectsEnabled == true
    end

    return true
end

function HelperPersonnelConfig:useIndividualWages()
    return self.economicEffectsEnabled == true and self.individualWagesEnabled == true
end

function HelperPersonnelConfig:getStandardBaseMonthlyWage()
    return tonumber(self.standardBaseMonthlyWage) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE
end

function HelperPersonnelConfig:getNetworkState()
    return {
        gameplayEffectsEnabled = self.gameplayEffectsEnabled == true,
        experienceEffectsEnabled = self.experienceEffectsEnabled == true,
        speedEffectEnabled = self.speedEffectEnabled == true,
        wearEffectEnabled = self.wearEffectEnabled == true,
        consumablesEffectEnabled = self.consumablesEffectEnabled == true,
        fuelEffectEnabled = self.fuelEffectEnabled == true,
        reliabilityEffectsEnabled = self.reliabilityEffectsEnabled == true,
        personnelEffectsEnabled = self.personnelEffectsEnabled == true,
        loyaltyEffectsEnabled = self.loyaltyEffectsEnabled == true,
        nightWorkLoyaltyEffectEnabled = self.nightWorkLoyaltyEffectEnabled == true,
        economicEffectsEnabled = self.economicEffectsEnabled == true,
        individualWagesEnabled = self.individualWagesEnabled == true,
        standardBaseMonthlyWage = tonumber(self.standardBaseMonthlyWage) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE
    }
end

function HelperPersonnelConfig:applyNetworkState(state)
    if type(state) ~= "table" then
        return false
    end

    self.gameplayEffectsEnabled = state.gameplayEffectsEnabled == true
    self.experienceEffectsEnabled = state.experienceEffectsEnabled == true
    self.speedEffectEnabled = state.speedEffectEnabled == true
    self.wearEffectEnabled = state.wearEffectEnabled == true
    self.consumablesEffectEnabled = state.consumablesEffectEnabled == true
    self.fuelEffectEnabled = state.fuelEffectEnabled == true
    self.reliabilityEffectsEnabled = state.reliabilityEffectsEnabled == true
    self.personnelEffectsEnabled = state.personnelEffectsEnabled ~= false
    self.loyaltyEffectsEnabled = state.loyaltyEffectsEnabled ~= false
    self.nightWorkLoyaltyEffectEnabled = state.nightWorkLoyaltyEffectEnabled ~= false
    self.economicEffectsEnabled = state.economicEffectsEnabled == true
    self.individualWagesEnabled = state.individualWagesEnabled == true
    self.standardBaseMonthlyWage = tonumber(state.standardBaseMonthlyWage) or HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE

    return true
end
