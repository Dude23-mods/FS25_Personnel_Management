HelperPersonnelManager = {}
HelperPersonnelManager_mt = Class(HelperPersonnelManager)

HelperPersonnelManager.GENDER_MALE = "male"
HelperPersonnelManager.GENDER_FEMALE = "female"

HelperPersonnelManager.FIRST_NAMES_MALE = {
    "Simon", "Jonas", "Lukas", "Felix", "Max", "Paul", "Noah", "David", "Michael", "Daniel",
    "Florian", "Stefan", "Johannes", "Tobias", "Fabian", "Nico", "Marcel", "Sebastian", "Anton", "Leon"
}

HelperPersonnelManager.FIRST_NAMES_FEMALE = {
    "Anna", "Lisa", "Maria", "Laura", "Sarah", "Lea", "Julia", "Sophie", "Mia", "Lena",
    "Katharina", "Nina", "Hannah", "Marie", "Clara", "Johanna", "Eva", "Theresa", "Franziska", "Carina"
}

HelperPersonnelManager.FIRST_NAMES = HelperPersonnelManager.FIRST_NAMES_MALE

HelperPersonnelManager.AVATAR_GENDER_BY_INDEX = {
    [1] = HelperPersonnelManager.GENDER_MALE,
    [2] = HelperPersonnelManager.GENDER_MALE,
    [3] = HelperPersonnelManager.GENDER_FEMALE,
    [4] = HelperPersonnelManager.GENDER_FEMALE,
    [5] = HelperPersonnelManager.GENDER_MALE,
    [6] = HelperPersonnelManager.GENDER_FEMALE,
    [7] = HelperPersonnelManager.GENDER_MALE,
    [8] = HelperPersonnelManager.GENDER_MALE,
    [9] = HelperPersonnelManager.GENDER_FEMALE,
    [10] = HelperPersonnelManager.GENDER_MALE
}

HelperPersonnelManager.AVATAR_INDICES_BY_GENDER = {
    [HelperPersonnelManager.GENDER_MALE] = {1, 2, 5, 7, 8, 10},
    [HelperPersonnelManager.GENDER_FEMALE] = {3, 4, 6, 9}
}

HelperPersonnelManager.LAST_NAMES = {
    "Schuster", "Bauer", "Hofmann", "Kraus", "Wagner", "Huber", "Meyer", "Wolf", "Fischer", "Neumann",
    "Schmid", "Lehner", "Winter", "Hartmann", "Becker", "Maier", "Lang", "Pfeiffer", "Schramm", "Eder"
}

HelperPersonnelManager.MIN_RECORDED_JOB_DURATION_MS = 10000
HelperPersonnelManager.EXPERIENCE_MINUTES_PER_POINT = 50
HelperPersonnelManager.MAX_EXPERIENCE_GAIN_PER_JOB = 2

HelperPersonnelManager.EXPERIENCE_LEARNING_TIERS = {
    {maxExperience = 24, minutesPerPoint = 25, monthlyLimitAdjustment = 1},
    {maxExperience = 49, minutesPerPoint = 50, monthlyLimitAdjustment = 0},
    {maxExperience = 69, minutesPerPoint = 100, monthlyLimitAdjustment = -1},
    {maxExperience = 84, minutesPerPoint = 220, monthlyLimitAdjustment = -2},
    {maxExperience = 94, minutesPerPoint = 540, monthlyLimitAdjustment = -3},
    {maxExperience = 100, minutesPerPoint = 1080, monthlyLimitAdjustment = -4}
}
HelperPersonnelManager.EXPERIENCE_MONTHLY_GAIN_LIMITS = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 3,
    [5] = 4,
    [6] = 4,
    [7] = 5,
    [8] = 5,
    [9] = 5,
    [10] = 6,
    [11] = 6,
    [12] = 6,
    [13] = 7,
    [14] = 7,
    [15] = 7,
    [16] = 8,
    [17] = 8,
    [18] = 8,
    [19] = 9,
    [20] = 9,
    [21] = 9,
    [22] = 10,
    [23] = 10,
    [24] = 10,
    [25] = 11,
    [26] = 11,
    [27] = 11,
    [28] = 12
}
HelperPersonnelManager.MAX_HISTORY_ENTRIES = 36
HelperPersonnelManager.PORTRAIT_COUNT = 10
HelperPersonnelManager.MAX_APPLICANTS = 6
HelperPersonnelManager.MAX_MONTHLY_NEW_APPLICANTS = 3
HelperPersonnelManager.MAX_APPLICANT_AVAILABLE_MONTHS = 2
HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION = 60
HelperPersonnelManager.MIN_EMPLOYER_REPUTATION = 0
HelperPersonnelManager.MAX_EMPLOYER_REPUTATION = 100
HelperPersonnelManager.PERIOD_CHECK_INTERVAL_MS = 1000

HelperPersonnelManager.CONFIG_DEBUG_LOGGING = false
HelperPersonnelManager.WAGE_DEBUG_LOGGING = false
HelperPersonnelManager.WAGE_DEBUG_INTERVAL_MS = 30000

HelperPersonnelManager.DEFAULT_LOYALTY = 65
HelperPersonnelManager.NIGHT_WORK_START_MINUTE = 22 * 60
HelperPersonnelManager.NIGHT_WORK_END_MINUTE = 6 * 60
HelperPersonnelManager.NIGHT_WORK_LOYALTY_MIN_INGAME_MINUTES = 120
HelperPersonnelManager.NIGHT_WORK_LOYALTY_MAX_PENALTY = 5
HelperPersonnelManager.NIGHT_WORK_REPUTATION_MAX_PENALTY = 2
HelperPersonnelManager.NIGHT_WORK_REALTIME_FACTOR_CAP = 60
HelperPersonnelManager.LOYALTY_DAILY_EVALUATION_MINUTE = 6 * 60
HelperPersonnelManager.LOYALTY_WARNING_THRESHOLD_LOW = 40
HelperPersonnelManager.LOYALTY_WARNING_THRESHOLD_VERY_LOW = 25
HelperPersonnelManager.LOYALTY_WARNING_THRESHOLD_CRITICAL = 15
HelperPersonnelManager.LOYALTY_RESIGNATION_REPUTATION_DELTA = -10
HelperPersonnelManager.LOYALTY_RESIGNATION_CHANCES = {
    {maxLoyalty = 5, chance = 0.35},
    {maxLoyalty = 9, chance = 0.20},
    {maxLoyalty = 14, chance = 0.10}
}
HelperPersonnelManager.LOYALTY_RUNTIME_CHECK_INTERVAL_MS = 1000
HelperPersonnelManager.SICKNESS_CHANCES_BY_RELIABILITY = {
    {maxReliability = 20, chance = 0.10},
    {maxReliability = 40, chance = 0.08},
    {maxReliability = 60, chance = 0.06},
    {maxReliability = 80, chance = 0.04},
    {maxReliability = 100, chance = 0.02}
}
HelperPersonnelManager.SICKNESS_MAX_DAYS_STEP = 3
HelperPersonnelManager.RELIABILITY_MONTHLY_GOOD_WORK_MINUTES = 120
HelperPersonnelManager.RELIABILITY_MONTHLY_GOOD_CHANCE = 0.35
HelperPersonnelManager.RELIABILITY_LOW_LOYALTY_THRESHOLD = 25
HelperPersonnelManager.RELIABILITY_LOW_LOYALTY_MONTHLY_DROP_CHANCE = 0.20
HelperPersonnelManager.RELIABILITY_SALARY_DECLINED_MONTHLY_DROP_CHANCE = 0.20
HelperPersonnelManager.RELIABILITY_OPEN_SALARY_MONTHLY_DROP_CHANCE = 0.15
HelperPersonnelManager.RELIABILITY_LOW_REPUTATION_THRESHOLD = 30
HelperPersonnelManager.RELIABILITY_LOW_REPUTATION_MONTHLY_DROP_CHANCE = 0.10
HelperPersonnelManager.RELIABILITY_MONTHLY_NIGHT_WORK_MINUTES = 240
HelperPersonnelManager.RELIABILITY_NIGHT_WORK_MONTHLY_DROP_CHANCE = 0.15
HelperPersonnelManager.RELIABILITY_DEVELOPMENT_MAX_NEGATIVE_CHANCE = 0.60
HelperPersonnelManager.LOYALTY_PAYROLL_BONUS_MIN_REPUTATION = 40
HelperPersonnelManager.LOYALTY_PAYROLL_PAID_DELTA = 1
HelperPersonnelManager.LOYALTY_PAYROLL_LOW_BALANCE_DELTA = -2
HelperPersonnelManager.LOYALTY_PAYROLL_ALREADY_NEGATIVE_DELTA = -4
HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_THRESHOLD_SMALL = 15
HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_THRESHOLD_MEDIUM = 30
HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_THRESHOLD_LARGE = 50
HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_SMALL = 1
HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_MEDIUM = 2
HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_LARGE = 3
HelperPersonnelManager.LOYALTY_TENURE_MILESTONES = {
    {months = 3, delta = 1},
    {months = 6, delta = 1},
    {months = 12, delta = 2},
    {months = 24, delta = 3}
}

HelperPersonnelManager.LOYALTY_REPUTATION_MILESTONES = {
    {months = 3, delta = 1},
    {months = 6, delta = 2},
    {months = 12, delta = 4},
    {months = 24, delta = 6}
}
HelperPersonnelManager.DISMISSAL_REPUTATION_DELTAS = {
    under1Month = -12,
    under3Months = -9,
    under6Months = -7,
    under12Months = -5,
    under24Months = -3,
    longTerm = -1,
    unknown = -5
}
HelperPersonnelManager.ADDITIONAL_MONTHLY_DISMISSAL_DELTA = -4
HelperPersonnelManager.DISMISSAL_NOTICE_LOYALTY_PENALTY = 40
HelperPersonnelManager.DISMISSAL_NOTICE_RELIABILITY_PENALTY = 25
HelperPersonnelManager.DISMISSAL_SINGLE_DAY_NOTICE_DEADLINE_MINUTE = 720
HelperPersonnelManager.TRAINING_SINGLE_DAY_START_DEADLINE_MINUTE = 720
HelperPersonnelManager.PAYROLL_REPUTATION_PAID = 1
HelperPersonnelManager.PAYROLL_REPUTATION_LOW_BALANCE = -3
HelperPersonnelManager.PAYROLL_REPUTATION_ALREADY_NEGATIVE = -6
HelperPersonnelManager.DEFAULT_SALARY_MONTH_LENGTH_DAYS = 3
HelperPersonnelManager.SALARY_MONTH_LENGTH_FACTORS = {
    [1] = 0.58,
    [2] = 0.82,
    [3] = 1.00,
    [4] = 1.15,
    [5] = 1.29,
    [6] = 1.41,
    [7] = 1.53,
    [8] = 1.63,
    [9] = 1.73,
    [10] = 1.83,
    [11] = 1.91,
    [12] = 2.00,
    [13] = 2.08,
    [14] = 2.16,
    [15] = 2.24,
    [16] = 2.31,
    [17] = 2.38,
    [18] = 2.45,
    [19] = 2.52,
    [20] = 2.58,
    [21] = 2.65,
    [22] = 2.71,
    [23] = 2.77,
    [24] = 2.83,
    [25] = 2.89,
    [26] = 2.94,
    [27] = 3.00,
    [28] = 3.06
}
HelperPersonnelManager.SALARY_ECONOMY_COST_MULTIPLIERS = {
    [1] = 0.40,
    [2] = 0.70,
    [3] = 1.00
}
HelperPersonnelManager.SALARY_RANGES_BY_EXPERIENCE = {
    {minExperience = 0, maxExperience = 44, minSalary = 1800, maxSalary = 2200},
    {minExperience = 45, maxExperience = 74, minSalary = 2200, maxSalary = 2700},
    {minExperience = 75, maxExperience = 100, minSalary = 2700, maxSalary = 3300}
}
HelperPersonnelManager.SALARY_RELIABILITY_MIN_FACTOR = 0.94
HelperPersonnelManager.SALARY_RELIABILITY_MAX_FACTOR = 1.06
HelperPersonnelManager.APPLICANT_SALARY_RANDOM_MIN = 96
HelperPersonnelManager.APPLICANT_SALARY_RANDOM_MAX = 106

HelperPersonnelManager.SPECIALIZATION_NONE = "none"
HelperPersonnelManager.SPECIALIZATION_TILLAGE = "tillage"
HelperPersonnelManager.SPECIALIZATION_SOWING = "sowing"
HelperPersonnelManager.SPECIALIZATION_FERTILIZING = "fertilizing"
HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION = "plantProtection"
HelperPersonnelManager.SPECIALIZATION_HARVEST = "harvest"
HelperPersonnelManager.SPECIALIZATION_TRANSPORT = "transport"
HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE = "machineCare"
HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER = "resourceSaver"

HelperPersonnelManager.SPECIALIZATION_PRIMARY_EXPERIENCE_BONUS = 12
HelperPersonnelManager.SPECIALIZATION_SECONDARY_EXPERIENCE_BONUS = 6
HelperPersonnelManager.SPECIALIZATION_PRIMARY_WAGE_MULTIPLIER = 1.05
HelperPersonnelManager.SPECIALIZATION_SECONDARY_WAGE_MULTIPLIER = 1.03

HelperPersonnelManager.SPECIALIZATION_PRIMARY_LEARN_MINUTES = 240
HelperPersonnelManager.SPECIALIZATION_SECONDARY_LEARN_MINUTES = 420
HelperPersonnelManager.SPECIALIZATION_MIN_PRACTICE_JOB_MINUTES = 3
HelperPersonnelManager.SPECIALIZATION_LEARNING_MIN_FACTOR = 0.75
HelperPersonnelManager.SPECIALIZATION_LEARNING_MAX_FACTOR = 1.30

HelperPersonnelManager.TRAINING_PROGRESS_FRACTION = 0.30
HelperPersonnelManager.TRAINING_MIN_PROGRESS_MINUTES = 30

HelperPersonnelManager.TRAINING_SALARY_FACTORS = {
    [HelperPersonnelManager.SPECIALIZATION_TILLAGE] = 0.75,
    [HelperPersonnelManager.SPECIALIZATION_SOWING] = 0.90,
    [HelperPersonnelManager.SPECIALIZATION_FERTILIZING] = 0.90,
    [HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION] = 1.00,
    [HelperPersonnelManager.SPECIALIZATION_HARVEST] = 1.10,
    [HelperPersonnelManager.SPECIALIZATION_TRANSPORT] = 0.65,
    [HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE] = 1.20,
    [HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER] = 1.20
}

HelperPersonnelManager.SPECIALIZATION_KEYS = {
    HelperPersonnelManager.SPECIALIZATION_TILLAGE,
    HelperPersonnelManager.SPECIALIZATION_SOWING,
    HelperPersonnelManager.SPECIALIZATION_FERTILIZING,
    HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION,
    HelperPersonnelManager.SPECIALIZATION_HARVEST,
    HelperPersonnelManager.SPECIALIZATION_TRANSPORT,
    HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE,
    HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER
}

HelperPersonnelManager.SPECIALIZATION_TEXT_KEYS = {
    [HelperPersonnelManager.SPECIALIZATION_TILLAGE] = "ui_specialization_tillage",
    [HelperPersonnelManager.SPECIALIZATION_SOWING] = "ui_specialization_sowing",
    [HelperPersonnelManager.SPECIALIZATION_FERTILIZING] = "ui_specialization_fertilizing",
    [HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION] = "ui_specialization_plantProtection",
    [HelperPersonnelManager.SPECIALIZATION_HARVEST] = "ui_specialization_harvest",
    [HelperPersonnelManager.SPECIALIZATION_TRANSPORT] = "ui_specialization_transport",
    [HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE] = "ui_specialization_machineCare",
    [HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER] = "ui_specialization_resourceSaver"
}

HelperPersonnelManager.SPECIALIZATION_FALLBACK_TEXTS = {
    [HelperPersonnelManager.SPECIALIZATION_TILLAGE] = "Bodenbearbeitung",
    [HelperPersonnelManager.SPECIALIZATION_SOWING] = "Aussaat",
    [HelperPersonnelManager.SPECIALIZATION_FERTILIZING] = "Düngung",
    [HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION] = "Pflanzenschutz",
    [HelperPersonnelManager.SPECIALIZATION_HARVEST] = "Ernte",
    [HelperPersonnelManager.SPECIALIZATION_TRANSPORT] = "Transport",
    [HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE] = "Maschinenschonung",
    [HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER] = "Sparsame Arbeitsweise"
}

HelperPersonnelManager.SPECIALIZATION_GENERAL_KEYS = {
    [HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE] = true,
    [HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER] = true
}

HelperPersonnelManager.SPECIALIZATION_TASK_KEYS = {
    [HelperPersonnelManager.SPECIALIZATION_TILLAGE] = true,
    [HelperPersonnelManager.SPECIALIZATION_SOWING] = true,
    [HelperPersonnelManager.SPECIALIZATION_FERTILIZING] = true,
    [HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION] = true,
    [HelperPersonnelManager.SPECIALIZATION_HARVEST] = true,
    [HelperPersonnelManager.SPECIALIZATION_TRANSPORT] = true
}

HelperPersonnelManager.namesXmlSchema = XMLSchema.new("helperPersonnelNames")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.firstNamesMale.name(?)#value", "Male first name")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.firstNamesFemale.name(?)#value", "Female first name")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.lastNames.name(?)#value", "Last name")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.language(?)#code", "Language code for name pools")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.language(?).firstNamesMale.name(?)#value", "Localized male first name")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.language(?).firstNamesFemale.name(?)#value", "Localized female first name")
HelperPersonnelManager.namesXmlSchema:register(XMLValueType.STRING, "helperPersonnelNames.language(?).lastNames.name(?)#value", "Localized last name")

local function hpCloneStringList(source)
    local target = {}

    if type(source) == "table" then
        for _, value in ipairs(source) do
            if type(value) == "string" and value ~= "" then
                table.insert(target, value)
            end
        end
    end

    return target
end

local function hpSanitizeName(value)
    if type(value) ~= "string" then
        return nil
    end

    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")

    if value == "" then
        return nil
    end

    return value
end

local function hpNormalizeNamePoolLanguageCode(value)
    if value == nil then
        return nil
    end

    local code = string.lower(tostring(value))
    code = string.gsub(code, "^%s+", "")
    code = string.gsub(code, "%s+$", "")
    code = string.gsub(code, "^_", "")
    code = string.gsub(code, "-", "_")

    if code == "" then
        return nil
    end

    local baseCode = code
    local underscoreIndex = string.find(baseCode, "_", 1, true)
    if underscoreIndex ~= nil then
        baseCode = string.sub(baseCode, 1, underscoreIndex - 1)
    end

    if string.sub(code, 1, 2) == "de" or code == "ger" or code == "deutsch" or code == "german" then
        return "de"
    end

    if string.sub(code, 1, 2) == "fr" or code == "fra" or code == "fre" or code == "francais" or code == "français" or code == "french" or baseCode == "fc" then
        return "fr"
    end

    if string.sub(code, 1, 2) == "en" or code == "eng" or code == "english" then
        return "en"
    end

    if baseCode == "es" or code == "spa" or code == "spanish" or code == "espanol" or code == "español" then
        return "es"
    end

    if baseCode == "it" or code == "ita" or code == "italian" or code == "italiano" then
        return "it"
    end

    if baseCode == "pt" or baseCode == "br" or code == "por" or code == "portuguese" or code == "portugues" or code == "português" then
        return "pt"
    end

    if baseCode == "pl" or code == "pol" or code == "polish" or code == "polski" then
        return "pl"
    end

    if baseCode == "ru" or code == "rus" or code == "russian" then
        return "ru"
    end

    if baseCode == "tr" or code == "tur" or code == "turkish" then
        return "tr"
    end

    if baseCode == "cz" or code == "cze" or code == "cesky" or code == "česky" or code == "czech" then
        return "cz"
    end

    if baseCode == "hu" or code == "hun" or code == "hungarian" or code == "magyar" then
        return "hu"
    end

    if baseCode == "ro" or code == "ron" or code == "rum" or code == "romanian" or code == "română" or code == "romana" then
        return "ro"
    end

    if baseCode == "uk" or baseCode == "ua" or code == "ukr" or code == "ukrainian" then
        return "uk"
    end

    if baseCode == "da" or baseCode == "dk" or code == "dan" or code == "danish" then
        return "da"
    end

    if baseCode == "fi" or code == "fin" or code == "finnish" then
        return "fi"
    end

    if baseCode == "sv" or baseCode == "se" or code == "swe" or code == "swedish" then
        return "sv"
    end

    if baseCode == "no" or baseCode == "nb" or baseCode == "nn" or code == "nor" or code == "norwegian" then
        return "no"
    end

    if baseCode == "vi" or code == "vie" or code == "vietnamese" then
        return "vi"
    end

    if baseCode == "jp" or baseCode == "ja" or code == "jpn" or code == "japanese" then
        return "jp"
    end

    if baseCode == "kr" or baseCode == "ko" or code == "kor" or code == "korean" then
        return "kr"
    end

    if baseCode == "cs" or baseCode == "zh" or baseCode == "cn" or baseCode == "ct" or code == "zh_cn" or code == "chs" or code == "chinese" or code == "simplified_chinese" then
        return "cs"
    end

    return "en"
end

HelperPersonnelManager.xmlSchema = XMLSchema.new("helperPersonnel")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#nextId", "Next person id")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel#lastAction", "Last action text")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#employerReputation", "Employer reputation for the applicant market")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel#lastReputationChange", "Last employer reputation change text")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel#lastPayroll", "Last monthly payroll text")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.reputationHistory.entry(?)#period", "Reputation history period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.reputationHistory.entry(?)#year", "Reputation history year", 1)
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.reputationHistory.entry(?)#text", "Reputation history text", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.reputationHistory.entry(?)#sequence", "Reputation history order", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.actionHistory.entry(?)#period", "Action history period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.actionHistory.entry(?)#year", "Action history year", 1)
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.actionHistory.entry(?)#text", "Action history text", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.actionHistory.entry(?)#sequence", "Action history order", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel#lastPayrollAmount", "Last monthly payroll amount")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel#totalPayrollPaid", "Total payroll paid through Personnel Management")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#dismissalPeriod", "In-game period for current monthly dismissal counter")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#dismissalYear", "In-game year for current monthly dismissal counter")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#monthlyDismissals", "Dismissals already performed in the current in-game period")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#lastApplicantPeriod", "Last in-game period processed for applicant market")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#lastApplicantYear", "Last in-game year processed for applicant market")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#lastLoyaltyDailyCheckMinute", "Last in-game minute used for daily loyalty evaluation")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#lastSicknessDailyCheckMinute", "Last in-game minute used for daily sickness evaluation")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#sicknessCurrentDay", "Current tracked in-game day for sickness evaluation")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#sicknessDayPeriod", "Tracked sickness period")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#sicknessDayYear", "Tracked sickness year")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#pendingPayrollLoyaltyDelta", "Queued payroll reputation result for daily loyalty evaluation")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#id", "Worker id")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#firstName", "Worker first name")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#lastName", "Worker last name")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#gender", "Worker gender")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#experience", "Worker experience")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliability", "Worker reliability")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#loyalty", "Worker loyalty")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#avatarIndex", "Worker portrait index")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#assignedHelperIndex", "Assigned helper index")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#assignedBaseHelperIndex", "Assigned base helper index")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#hiredPeriod", "In-game period/month when this worker was hired")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#hiredYear", "In-game year when this worker was hired")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#loyaltyMilestoneMonths", "Highest loyalty reputation milestone already applied")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#loyaltyTenureMilestoneMonths", "Highest worker loyalty tenure milestone already applied", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#nightWorkIngameMinutes", "Stored in-game night work minutes for loyalty", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#loyaltyReputationProgress", "Stored loyalty/reputation attraction progress", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#loyaltyWarningPeriod", "Last period with a low-loyalty warning", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#loyaltyWarningYear", "Last year with a low-loyalty warning", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, "helperPersonnel.workers.worker(?)#resignationPending", "Worker has resigned for the end of the current period", false)
HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, "helperPersonnel.workers.worker(?)#dismissalPending", "Worker has been dismissed and will leave after the next payroll", false)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#dismissalNoticePeriod", "Period when worker dismissal was announced", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#dismissalNoticeYear", "Year when worker dismissal was announced", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#dismissalEffectivePeriod", "Period when worker dismissal becomes effective", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#dismissalEffectiveYear", "Year when worker dismissal becomes effective", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#resignationNoticePeriod", "Period when worker resignation was announced", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#resignationNoticeYear", "Year when worker resignation was announced", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#resignationCheckPeriod", "Last period checked for automatic resignation", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#resignationCheckYear", "Last year checked for automatic resignation", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#sickPeriod", "Period of current sickness day", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#sickYear", "Year of current sickness day", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#sickDay", "Day of current sickness", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#sicknessPeriod", "Period of monthly sickness counter", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#sicknessYear", "Year of monthly sickness counter", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#sicknessDaysThisPeriod", "Sickness days in current period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityWorkPeriod", "Reliability work counter period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityWorkYear", "Reliability work counter year", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityWorkMinutesThisPeriod", "Work minutes for reliability development", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityIncidentPeriod", "Reliability incident counter period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityIncidentYear", "Reliability incident counter year", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityIncidentsThisPeriod", "Reliability incidents in current period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilitySicknessPeriod", "Reliability sickness counter period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilitySicknessYear", "Reliability sickness counter year", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilitySicknessDaysThisPeriod", "Sick days for reliability development", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityNightWorkPeriod", "Reliability night work counter period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityNightWorkYear", "Reliability night work counter year", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityNightWorkMinutesThisPeriod", "Night work minutes for reliability development", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityDevelopmentCheckPeriod", "Last reliability development check period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#reliabilityDevelopmentCheckYear", "Last reliability development check year", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#nightWorkRealtimeMs", "Stored real night work time for loyalty", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#nightWorkLastMinute", "Last in-game minute used for night work tracking", -1)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#experiencePeriod", "Experience gain period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#experienceYear", "Experience gain year", 1)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#experienceThisPeriod", "Experience gained in the current period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#experienceProgressMinutes", "Stored helper work minutes toward the next experience point", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#specializationPrimary", "Primary worker specialization", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#specializationSecondary", "Secondary worker specialization", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#specializationProgressKey", "Specialization currently being learned", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#specializationProgressMinutes", "Minutes toward next specialization", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#trainingLastPeriod", "Last period with a training course", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#trainingLastYear", "Last year with a training course", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#trainingLastSpecialization", "Last training specialization")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#trainingActivePeriod", "Current training period", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#trainingActiveYear", "Current training year", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#trainingActiveSpecialization", "Current training specialization")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?).specializationProgress(?)#key", "Parallel specialization progress key", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?).specializationProgress(?)#minutes", "Parallel specialization progress minutes", 0)
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#wage", "Worker wage")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#baseWage", "Worker base wage before month-length and economy multipliers")
HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, "helperPersonnel.workers.worker(?)#busy", "Worker busy state")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#vehicleName", "Assigned vehicle name")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.workers.worker(?)#vehicleKey", "Assigned vehicle key")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#jobsCompleted", "Completed AI helper jobs")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#totalWorkMinutes", "Total work time in minutes")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.workers.worker(?)#lastJobMinutes", "Last job duration in minutes")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#totalEarnings", "Estimated total helper wage")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#currentJobStartedAt", "Current job start timestamp")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.workers.worker(?)#currentJobElapsedMs", "Accumulated elapsed time of the current active job")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.applicants.applicant(?)#id", "Applicant id")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.applicants.applicant(?)#firstName", "Applicant first name")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.applicants.applicant(?)#lastName", "Applicant last name")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.applicants.applicant(?)#gender", "Applicant gender")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.applicants.applicant(?)#experience", "Applicant experience")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.applicants.applicant(?)#reliability", "Applicant reliability")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.applicants.applicant(?)#loyalty", "Applicant loyalty")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.applicants.applicant(?)#avatarIndex", "Applicant portrait index")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.applicants.applicant(?)#wage", "Applicant wage")
HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, "helperPersonnel.applicants.applicant(?)#baseWage", "Applicant base wage before month-length and economy multipliers")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.applicants.applicant(?)#monthsAvailable", "Applicant market age in months")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.applicants.applicant(?)#specializationPrimary", "Primary applicant specialization", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.applicants.applicant(?)#specializationSecondary", "Secondary applicant specialization", "")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.activeJobs.job(?)#workerId", "Active helper personnel worker id")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.activeJobs.job(?)#vehicleKey", "Active helper personnel vehicle key")
HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, "helperPersonnel.activeJobs.job(?)#vehicleName", "Active helper personnel vehicle name")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.activeJobs.job(?)#helperIndex", "Active helper personnel helper index")
HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel.activeJobs.job(?)#baseHelperIndex", "Active helper personnel base helper index")

function HelperPersonnelManager.new(app, customMt)
    local self = setmetatable({}, customMt or HelperPersonnelManager_mt)

    self.app = app
    self.workers = {}
    self.applicants = {}
    self.nextPersonId = 1
    self.lastActionText = ""
    self.changeCounter = 0
    self.saveBusyWorkerLookup = {}
    self.saveActiveJobSnapshot = {}
    self.restoredActiveJobs = {}
    self.restoredActiveJobByVehicleKey = {}
    self.restoredActiveJobByVehicleName = {}
    self.employerReputation = HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION
    self.lastReputationChangeText = ""
    self.lastPayrollText = "noch keine Gehaltsabrechnung"
    self.reputationHistory = {}
    self.actionHistory = {}
    self.historySequence = 0
    self.lastPayrollAmount = 0
    self.totalPayrollPaid = 0
    self.dismissalPeriod = nil
    self.dismissalYear = nil
    self.monthlyDismissals = 0
    self.lastApplicantPeriod = nil
    self.lastApplicantYear = nil
    self.lastLoyaltyDailyCheckMinute = nil
    self.lastSicknessDailyCheckMinute = nil
    self.sicknessCurrentDay = nil
    self.sicknessDayPeriod = nil
    self.sicknessDayYear = nil
    self.pendingPayrollLoyaltyDelta = 0
    self.periodCheckTimerMs = 0
    self.loyaltyRuntimeTimerMs = 0
    self._wageDebugLogStateByPerson = {}
    self.config = HelperPersonnelConfig ~= nil and HelperPersonnelConfig.new(self) or nil
    self.firstNamesMale = hpCloneStringList(HelperPersonnelManager.FIRST_NAMES_MALE)
    self.firstNamesFemale = hpCloneStringList(HelperPersonnelManager.FIRST_NAMES_FEMALE)
    self.lastNames = hpCloneStringList(HelperPersonnelManager.LAST_NAMES)

    self:loadNamePools()

    return self
end

function HelperPersonnelManager:loadNamePoolFromXML(xmlFile, key, fallback)
    local result = {}
    local index = 0

    if xmlFile ~= nil then
        while true do
            local nameKey = string.format("%s.name(%d)", key, index)
            if not xmlFile:hasProperty(nameKey) then
                break
            end

            local value = hpSanitizeName(xmlFile:getString(nameKey .. "#value", ""))
            if value ~= nil then
                table.insert(result, value)
            end

            index = index + 1
        end
    end

    if #result == 0 then
        result = hpCloneStringList(fallback)
    end

    return result
end

function HelperPersonnelManager:getNamePoolLanguageCode()
    local candidates = {}

    if type(g_languageShort) == "string" then
        table.insert(candidates, g_languageShort)
    end

    if type(g_languageSuffix) == "string" then
        table.insert(candidates, g_languageSuffix)
    end

    if g_i18n ~= nil then
        if type(g_i18n.languageCode) == "string" then
            table.insert(candidates, g_i18n.languageCode)
        end

        if type(g_i18n.currentLanguage) == "string" then
            table.insert(candidates, g_i18n.currentLanguage)
        end

        if type(g_i18n.languageShort) == "string" then
            table.insert(candidates, g_i18n.languageShort)
        end

        if type(g_i18n.getLanguageCode) == "function" then
            local success, value = pcall(g_i18n.getLanguageCode, g_i18n)
            if success and type(value) == "string" then
                table.insert(candidates, value)
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        local code = hpNormalizeNamePoolLanguageCode(candidate)
        if code ~= nil then
            return code
        end
    end

    return "en"
end

function HelperPersonnelManager:getLocalizedNamePoolRootKey(xmlFile, desiredLanguageCode)
    if xmlFile == nil then
        return nil
    end

    desiredLanguageCode = hpNormalizeNamePoolLanguageCode(desiredLanguageCode) or "en"

    local fallbackEnKey = nil
    local fallbackDeKey = nil
    local index = 0

    while true do
        local languageKey = string.format("helperPersonnelNames.language(%d)", index)
        if not xmlFile:hasProperty(languageKey) then
            break
        end

        local code = hpNormalizeNamePoolLanguageCode(xmlFile:getString(languageKey .. "#code", ""))
        if code == desiredLanguageCode then
            return languageKey
        end

        if code == "en" and fallbackEnKey == nil then
            fallbackEnKey = languageKey
        elseif code == "de" and fallbackDeKey == nil then
            fallbackDeKey = languageKey
        end

        index = index + 1
    end

    return fallbackEnKey or fallbackDeKey
end

function HelperPersonnelManager:loadNamePools()
    self.firstNamesMale = hpCloneStringList(HelperPersonnelManager.FIRST_NAMES_MALE)
    self.firstNamesFemale = hpCloneStringList(HelperPersonnelManager.FIRST_NAMES_FEMALE)
    self.lastNames = hpCloneStringList(HelperPersonnelManager.LAST_NAMES)

    if self.app == nil or self.app.modDir == nil then
        return
    end

    local filename = Utils.getFilename("data/helperPersonnelNames.xml", self.app.modDir)
    if filename == nil or filename == "" or not fileExists(filename) then
        return
    end

    local xmlFile = XMLFile.loadIfExists("helperPersonnelNames", filename, HelperPersonnelManager.namesXmlSchema)
    if xmlFile == nil then
        return
    end

    local localizedRootKey = self:getLocalizedNamePoolRootKey(xmlFile, self:getNamePoolLanguageCode())
    if localizedRootKey ~= nil then
        self.firstNamesMale = self:loadNamePoolFromXML(xmlFile, localizedRootKey .. ".firstNamesMale", HelperPersonnelManager.FIRST_NAMES_MALE)
        self.firstNamesFemale = self:loadNamePoolFromXML(xmlFile, localizedRootKey .. ".firstNamesFemale", HelperPersonnelManager.FIRST_NAMES_FEMALE)
        self.lastNames = self:loadNamePoolFromXML(xmlFile, localizedRootKey .. ".lastNames", HelperPersonnelManager.LAST_NAMES)
    else

        self.firstNamesMale = self:loadNamePoolFromXML(xmlFile, "helperPersonnelNames.firstNamesMale", HelperPersonnelManager.FIRST_NAMES_MALE)
        self.firstNamesFemale = self:loadNamePoolFromXML(xmlFile, "helperPersonnelNames.firstNamesFemale", HelperPersonnelManager.FIRST_NAMES_FEMALE)
        self.lastNames = self:loadNamePoolFromXML(xmlFile, "helperPersonnelNames.lastNames", HelperPersonnelManager.LAST_NAMES)
    end

    xmlFile:delete()
end

function HelperPersonnelManager:getCurrentTimestampMs()
    if g_time ~= nil then
        return tonumber(g_time) or 0
    end

    if g_currentMission ~= nil and g_currentMission.time ~= nil then
        return tonumber(g_currentMission.time) or 0
    end

    return 0
end

function HelperPersonnelManager:getDefaultAvatarIndexForId(personId)
    local count = HelperPersonnelManager.PORTRAIT_COUNT or 1
    personId = tonumber(personId) or 1

    if count <= 1 then
        return 1
    end

    return ((math.max(1, personId) - 1) % count) + 1
end

function HelperPersonnelManager:normalizeGender(gender)
    if gender == HelperPersonnelManager.GENDER_MALE or gender == HelperPersonnelManager.GENDER_FEMALE then
        return gender
    end

    if type(gender) == "string" then
        local lowerGender = string.lower(gender)
        if lowerGender == "m" or lowerGender == "male" or lowerGender == "mann" or lowerGender == "maennlich" or lowerGender == "männlich" then
            return HelperPersonnelManager.GENDER_MALE
        elseif lowerGender == "f" or lowerGender == "female" or lowerGender == "frau" or lowerGender == "weiblich" then
            return HelperPersonnelManager.GENDER_FEMALE
        end
    end

    return nil
end

function HelperPersonnelManager:getGenderForAvatarIndex(avatarIndex)
    avatarIndex = tonumber(avatarIndex) or 0

    local bridge = self.app ~= nil and self.app.helperBridge or nil
    if bridge ~= nil and bridge.getGenderForBaseHelperIndex ~= nil then
        local liveGender = bridge:getGenderForBaseHelperIndex(avatarIndex)
        liveGender = self:normalizeGender(liveGender)
        if liveGender ~= nil then
            return liveGender
        end
    end

    local gender = HelperPersonnelManager.AVATAR_GENDER_BY_INDEX[avatarIndex]
    if gender ~= nil then
        return gender
    end

    return HelperPersonnelManager.GENDER_MALE
end

function HelperPersonnelManager:getGenderForPerson(person)
    if type(person) ~= "table" then
        return HelperPersonnelManager.GENDER_MALE
    end

    local gender = self:normalizeGender(person.gender)
    if gender ~= nil then
        return gender
    end

    return self:getGenderForAvatarIndex(person.avatarIndex)
end

function HelperPersonnelManager:getRandomAvatarIndexForGender(gender)
    gender = self:normalizeGender(gender) or HelperPersonnelManager.GENDER_MALE

    local bridge = self.app ~= nil and self.app.helperBridge or nil
    if bridge ~= nil and bridge.getAvatarIndicesForGender ~= nil then
        local liveIndices = bridge:getAvatarIndicesForGender(gender)
        if type(liveIndices) == "table" and #liveIndices > 0 then
            return liveIndices[math.random(1, #liveIndices)]
        end
    end

    local indices = HelperPersonnelManager.AVATAR_INDICES_BY_GENDER[gender]
    if type(indices) == "table" and #indices > 0 then
        return indices[math.random(1, #indices)]
    end

    return self:getDefaultAvatarIndexForId(self.nextPersonId)
end

function HelperPersonnelManager:getRandomFirstNameForGender(gender)
    gender = self:normalizeGender(gender) or HelperPersonnelManager.GENDER_MALE

    local names = gender == HelperPersonnelManager.GENDER_FEMALE and self.firstNamesFemale or self.firstNamesMale
    if type(names) ~= "table" or #names == 0 then
        names = HelperPersonnelManager.FIRST_NAMES
    end

    return names[math.random(1, #names)]
end

function HelperPersonnelManager:getRandomLastName()
    local names = self.lastNames
    if type(names) ~= "table" or #names == 0 then
        names = HelperPersonnelManager.LAST_NAMES
    end

    return names[math.random(1, #names)]
end

function HelperPersonnelManager:roundToNearest(value, step)
    value = tonumber(value) or 0
    step = math.max(1, tonumber(step) or 1)

    return math.floor((value / step) + 0.5) * step
end

function HelperPersonnelManager:getSalaryDaysPerMonth()
    local days = nil

    if g_currentMission ~= nil then
        if g_currentMission.environment ~= nil then
            days = g_currentMission.environment.daysPerPeriod or g_currentMission.environment.daysPerMonth
        end

        if days == nil and g_currentMission.missionInfo ~= nil then
            days = g_currentMission.missionInfo.daysPerPeriod or g_currentMission.missionInfo.daysPerMonth
        end
    end

    days = math.floor((tonumber(days) or HelperPersonnelManager.DEFAULT_SALARY_MONTH_LENGTH_DAYS) + 0.5)
    return math.max(1, math.min(28, days))
end

function HelperPersonnelManager:getSalaryMonthLengthFactor()
    local days = self:getSalaryDaysPerMonth()
    local factor = HelperPersonnelManager.SALARY_MONTH_LENGTH_FACTORS[days]

    if factor == nil then
        factor = HelperPersonnelManager.SALARY_MONTH_LENGTH_FACTORS[HelperPersonnelManager.DEFAULT_SALARY_MONTH_LENGTH_DAYS] or 1
    end

    return factor
end

function HelperPersonnelManager:getSalaryEconomyDifficulty()
    if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
        return math.floor((tonumber(g_currentMission.missionInfo.economicDifficulty) or 0) + 0.5)
    end

    return 0
end

function HelperPersonnelManager:getSalaryEconomyCostMultiplier()
    local difficulty = self:getSalaryEconomyDifficulty()

    if EconomyManager ~= nil and type(EconomyManager.COST_MULTIPLIER) == "table" then
        local value = tonumber(EconomyManager.COST_MULTIPLIER[difficulty])
        if value ~= nil and value > 0 then
            return value
        end
    end

    if g_currentMission ~= nil and g_currentMission.economyManager ~= nil and type(g_currentMission.economyManager.COST_MULTIPLIER) == "table" then
        local value = tonumber(g_currentMission.economyManager.COST_MULTIPLIER[difficulty])
        if value ~= nil and value > 0 then
            return value
        end
    end

    return HelperPersonnelManager.SALARY_ECONOMY_COST_MULTIPLIERS[difficulty] or 1
end

function HelperPersonnelManager:getSalaryTotalMultiplier()
    return self:getSalaryMonthLengthFactor() * self:getSalaryEconomyCostMultiplier()
end

function HelperPersonnelManager:calculateBaseSalaryForStats(experience, reliability)
    experience = self:clampPersonStat(experience)
    reliability = self:clampPersonStat(reliability)

    local selectedRange = HelperPersonnelManager.SALARY_RANGES_BY_EXPERIENCE[1]
    for _, range in ipairs(HelperPersonnelManager.SALARY_RANGES_BY_EXPERIENCE) do
        if experience >= range.minExperience and experience <= range.maxExperience then
            selectedRange = range
            break
        end
    end

    local divisor = math.max(1, (selectedRange.maxExperience or selectedRange.minExperience or 0) - (selectedRange.minExperience or 0))
    local progress = (experience - (selectedRange.minExperience or 0)) / divisor
    progress = math.max(0, math.min(1, progress))

    local baseSalary = (selectedRange.minSalary or 0) + (((selectedRange.maxSalary or selectedRange.minSalary or 0) - (selectedRange.minSalary or 0)) * progress)
    local reliabilityProgress = reliability / 100
    local reliabilityFactor = (HelperPersonnelManager.SALARY_RELIABILITY_MIN_FACTOR or 1) + (((HelperPersonnelManager.SALARY_RELIABILITY_MAX_FACTOR or 1) - (HelperPersonnelManager.SALARY_RELIABILITY_MIN_FACTOR or 1)) * reliabilityProgress)

    return self:roundToNearest(baseSalary * reliabilityFactor, 10)
end

function HelperPersonnelManager:calculateApplicantBaseWage(experience, reliability, reputationWageMultiplier)
    local baseWage = self:calculateBaseSalaryForStats(experience, reliability)
    local randomPercent = math.random(HelperPersonnelManager.APPLICANT_SALARY_RANDOM_MIN, HelperPersonnelManager.APPLICANT_SALARY_RANDOM_MAX) / 100

    return self:roundToNearest(baseWage * (tonumber(reputationWageMultiplier) or 1) * randomPercent, 10)
end

function HelperPersonnelManager:calculateCurrentMonthlyWageFromBase(baseWage)
    baseWage = tonumber(baseWage) or 0
    return self:roundToNearest(baseWage * self:getSalaryTotalMultiplier(), 10)
end

function HelperPersonnelManager:logConfigState(sourceName)
    if HelperPersonnelManager.CONFIG_DEBUG_LOGGING ~= true then
        return
    end

    if Logging == nil or Logging.info == nil then
        return
    end

    local config = self.config
    if config == nil then
        Logging.info("FS25_HelperPersonnel: Konfiguration-Test | Quelle=%s | Konfiguration=nicht verfuegbar", tostring(sourceName or "unbekannt"))
        return
    end

    Logging.info("FS25_HelperPersonnel: Konfiguration-Test | Quelle=%s | Gameplay=%s | Erfahrung=%s | Geschwindigkeit=%s | Verschleiss=%s | Verbrauch=%s | Kraftstoff=%s | Zuverlaessigkeit=%s | Personal=%s | Loyalitaet=%s | Nachtarbeit=%s | Wirtschaft=%s | IndividuelleGehaelter=%s | StandardGrundgehalt=%.2f",
        tostring(sourceName or "unbekannt"),
        tostring(config.gameplayEffectsEnabled == true),
        tostring(config.experienceEffectsEnabled == true),
        tostring(config.speedEffectEnabled == true),
        tostring(config.wearEffectEnabled == true),
        tostring(config.consumablesEffectEnabled == true),
        tostring(config.fuelEffectEnabled == true),
        tostring(config.reliabilityEffectsEnabled == true),
        tostring(config.personnelEffectsEnabled == true),
        tostring(config.loyaltyEffectsEnabled == true),
        tostring(config.nightWorkLoyaltyEffectEnabled == true),
        tostring(config.economicEffectsEnabled == true),
        tostring(config.individualWagesEnabled == true),
        tonumber(config.standardBaseMonthlyWage) or 0
    )
end

function HelperPersonnelManager:loadConfig()
    if self.config ~= nil and self.config.load ~= nil then
        local result = self.config:load()
        self:logConfigState("Laden")
        return result
    end

    self:logConfigState("Laden")
    return false
end

function HelperPersonnelManager:saveConfig()
    if self.config ~= nil and self.config.save ~= nil then
        local result = self.config:save()
        self:logConfigState("Speichern")
        return result
    end

    self:logConfigState("Speichern")
    return false
end

function HelperPersonnelManager:useIndividualWages()
    if self.config ~= nil and self.config.useIndividualWages ~= nil then
        return self.config:useIndividualWages()
    end

    return true
end

function HelperPersonnelManager:getStandardBaseMonthlyWage()
    if self.config ~= nil and self.config.getStandardBaseMonthlyWage ~= nil then
        return self.config:getStandardBaseMonthlyWage()
    end

    return HelperPersonnelConfig ~= nil and HelperPersonnelConfig.DEFAULT_STANDARD_BASE_MONTHLY_WAGE or 2500
end

function HelperPersonnelManager:isGameplayExperienceEffectEnabled(effectName)
    if self.config ~= nil and self.config.isGameplayExperienceEffectEnabled ~= nil then
        return self.config:isGameplayExperienceEffectEnabled(effectName)
    end

    return true
end

function HelperPersonnelManager:normalizeSpecializationKey(value)
    if value == nil then
        return nil
    end

    value = tostring(value)
    if value == "" or value == HelperPersonnelManager.SPECIALIZATION_NONE then
        return nil
    end

    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        if value == key then
            return key
        end
    end

    return nil
end

function HelperPersonnelManager:getSpecializationDisplayName(value)
    local key = self:normalizeSpecializationKey(value)
    if key == nil then
        return "-"
    end

    local textKey = HelperPersonnelManager.SPECIALIZATION_TEXT_KEYS[key]
    local fallback = HelperPersonnelManager.SPECIALIZATION_FALLBACK_TEXTS[key] or tostring(key)
    return self:getLocalizedText(textKey, fallback)
end

function HelperPersonnelManager:isGeneralSpecializationKey(value)
    local key = self:normalizeSpecializationKey(value)
    return key ~= nil and HelperPersonnelManager.SPECIALIZATION_GENERAL_KEYS ~= nil and HelperPersonnelManager.SPECIALIZATION_GENERAL_KEYS[key] == true
end

function HelperPersonnelManager:isTaskSpecializationKey(value)
    local key = self:normalizeSpecializationKey(value)
    return key ~= nil and HelperPersonnelManager.SPECIALIZATION_TASK_KEYS ~= nil and HelperPersonnelManager.SPECIALIZATION_TASK_KEYS[key] == true
end

function HelperPersonnelManager:getDirectPersonSpecializationExperienceBonus(person, specializationKey)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if type(person) ~= "table" or specializationKey == nil then
        return 0
    end

    if self:normalizeSpecializationKey(person.specializationPrimary) == specializationKey then
        return HelperPersonnelManager.SPECIALIZATION_PRIMARY_EXPERIENCE_BONUS or 0
    end

    if self:normalizeSpecializationKey(person.specializationSecondary) == specializationKey then
        return HelperPersonnelManager.SPECIALIZATION_SECONDARY_EXPERIENCE_BONUS or 0
    end

    return 0
end

function HelperPersonnelManager:getSpecializationRequiredMinutes(person)
    local primary = type(person) == "table" and self:normalizeSpecializationKey(person.specializationPrimary) or nil
    if primary == nil then
        return HelperPersonnelManager.SPECIALIZATION_PRIMARY_LEARN_MINUTES or 240
    end

    return HelperPersonnelManager.SPECIALIZATION_SECONDARY_LEARN_MINUTES or 420
end

function HelperPersonnelManager:getSpecializationProgressTable(person)
    if type(person) ~= "table" then
        return {}
    end

    if type(person.specializationProgresses) ~= "table" then
        person.specializationProgresses = {}
    end

    return person.specializationProgresses
end

function HelperPersonnelManager:getSpecializationProgressMinutes(person, specializationKey)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if type(person) ~= "table" or specializationKey == nil then
        return 0
    end

    local progresses = person.specializationProgresses
    if type(progresses) == "table" then
        return math.max(0, math.floor((tonumber(progresses[specializationKey]) or 0) + 0.5))
    end

    if self:normalizeSpecializationKey(person.specializationProgressKey) == specializationKey then
        return math.max(0, math.floor((tonumber(person.specializationProgressMinutes) or 0) + 0.5))
    end

    return 0
end

function HelperPersonnelManager:getSpecializationProgressPercentForMinutes(person, progressMinutes)
    local requiredMinutes = self:getSpecializationRequiredMinutes(person)
    if requiredMinutes <= 0 then
        return 0
    end

    progressMinutes = math.max(0, tonumber(progressMinutes) or 0)
    return math.max(0, math.min(99, math.floor((progressMinutes / requiredMinutes) * 100 + 0.5)))
end

function HelperPersonnelManager:getBestSpecializationProgress(person)
    if type(person) ~= "table" then
        return nil, 0, 0
    end

    local bestKey = nil
    local bestMinutes = 0
    local bestIsTask = false

    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local specializationKey = self:normalizeSpecializationKey(key)
        local minutes = self:getSpecializationProgressMinutes(person, specializationKey)
        if specializationKey ~= nil and minutes > 0 and not self:workerHasSpecialization(person, specializationKey) then
            local isTask = self:isTaskSpecializationKey(specializationKey)
            if bestKey == nil or minutes > bestMinutes or (minutes == bestMinutes and isTask and not bestIsTask) then
                bestKey = specializationKey
                bestMinutes = minutes
                bestIsTask = isTask
            end
        end
    end

    if bestKey == nil then
        return nil, 0, 0
    end

    return bestKey, bestMinutes, self:getSpecializationProgressPercentForMinutes(person, bestMinutes)
end

function HelperPersonnelManager:getSpecializationProgressPercent(person)
    local _, _, percent = self:getBestSpecializationProgress(person)
    return percent or 0
end

function HelperPersonnelManager:normalizeSpecializationProgresses(person)
    if type(person) ~= "table" then
        return {}
    end

    local normalized = {}
    local existing = person.specializationProgresses
    if type(existing) == "table" then
        for key, value in pairs(existing) do
            local specializationKey = self:normalizeSpecializationKey(key)
            local minutes = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
            if specializationKey ~= nil and minutes > 0 and not self:workerHasSpecialization(person, specializationKey) then
                normalized[specializationKey] = math.max(normalized[specializationKey] or 0, minutes)
            end
        end
    end

    local legacyKey = self:normalizeSpecializationKey(person.specializationProgressKey)
    local legacyMinutes = math.max(0, math.floor((tonumber(person.specializationProgressMinutes) or 0) + 0.5))
    if legacyKey ~= nil and legacyMinutes > 0 and not self:workerHasSpecialization(person, legacyKey) then
        normalized[legacyKey] = math.max(normalized[legacyKey] or 0, legacyMinutes)
    end

    person.specializationProgresses = normalized
    local bestKey, bestMinutes = self:getBestSpecializationProgress(person)
    person.specializationProgressKey = bestKey
    person.specializationProgressMinutes = bestMinutes or 0

    return normalized
end
function HelperPersonnelManager:copySpecializationProgresses(person)
    local result = {}
    if type(person) ~= "table" then
        return result
    end

    self:normalizeSpecializationProgresses(person)
    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local specializationKey = self:normalizeSpecializationKey(key)
        local minutes = self:getSpecializationProgressMinutes(person, specializationKey)
        if specializationKey ~= nil and minutes > 0 and not self:workerHasSpecialization(person, specializationKey) then
            result[specializationKey] = minutes
        end
    end

    return result
end

function HelperPersonnelManager:readSpecializationProgressesFromXML(xmlFile, basePath)
    local progresses = {}
    if xmlFile == nil or basePath == nil then
        return progresses
    end

    local index = 0
    while true do
        local progressPath = string.format("%s.specializationProgress(%d)", basePath, index)
        if not xmlFile:hasProperty(progressPath) then
            break
        end

        local specializationKey = self:normalizeSpecializationKey(xmlFile:getString(progressPath .. "#key"))
        local minutes = math.max(0, math.floor((xmlFile:getInt(progressPath .. "#minutes", 0) or 0) + 0.5))
        if specializationKey ~= nil and minutes > 0 then
            progresses[specializationKey] = math.max(progresses[specializationKey] or 0, minutes)
        end

        index = index + 1
    end

    return progresses
end

function HelperPersonnelManager:writeSpecializationProgressesToXML(xmlFile, basePath, person)
    if xmlFile == nil or basePath == nil or type(person) ~= "table" then
        return
    end

    self:normalizeSpecializationProgresses(person)
    local index = 0
    for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
        local specializationKey = self:normalizeSpecializationKey(key)
        local minutes = self:getSpecializationProgressMinutes(person, specializationKey)
        if specializationKey ~= nil and minutes > 0 and not self:workerHasSpecialization(person, specializationKey) then
            local progressPath = string.format("%s.specializationProgress(%d)", basePath, index)
            xmlFile:setString(progressPath .. "#key", specializationKey)
            xmlFile:setInt(progressPath .. "#minutes", minutes)
            index = index + 1
        end
    end

    local bestKey, bestMinutes = self:getBestSpecializationProgress(person)
    person.specializationProgressKey = bestKey
    person.specializationProgressMinutes = bestMinutes or 0
end

function HelperPersonnelManager:getPersonSpecializationText(person)
    if type(person) ~= "table" then
        return ""
    end

    local primary = self:normalizeSpecializationKey(person.specializationPrimary)
    local secondary = self:normalizeSpecializationKey(person.specializationSecondary)
    local prefix = self:getLocalizedText("ui_specialization_short", "Spezialisierung")
    local text

    if primary == nil then
        text = string.format("%s: -", prefix)
    elseif secondary ~= nil then
        text = string.format("%s: %s / %s", prefix, self:getSpecializationDisplayName(primary), self:getSpecializationDisplayName(secondary))
    else
        text = string.format("%s: %s", prefix, self:getSpecializationDisplayName(primary))
    end

    local progressKey, _, progressPercent = self:getBestSpecializationProgress(person)
    if progressKey ~= nil and (primary == nil or secondary == nil) then
        local progressText = self:getLocalizedText("ui_specialization_progress", "lernt %s %d%%")
        text = string.format("%s (%s)", text, string.format(progressText, self:getSpecializationDisplayName(progressKey), progressPercent or 0))
    end

    return text
end

function HelperPersonnelManager:getPersonSpecializationExperienceBonus(person, specializationKey)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if type(person) ~= "table" or specializationKey == nil then
        return 0
    end

    if self:normalizeSpecializationKey(person.specializationPrimary) == specializationKey then
        return HelperPersonnelManager.SPECIALIZATION_PRIMARY_EXPERIENCE_BONUS or 0
    end

    if self:normalizeSpecializationKey(person.specializationSecondary) == specializationKey then
        return HelperPersonnelManager.SPECIALIZATION_SECONDARY_EXPERIENCE_BONUS or 0
    end

    if (specializationKey == HelperPersonnelManager.SPECIALIZATION_TILLAGE
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_SOWING
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_FERTILIZING
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_HARVEST
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_TRANSPORT) then
        if self:normalizeSpecializationKey(person.specializationPrimary) == HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE then
            return math.floor((HelperPersonnelManager.SPECIALIZATION_PRIMARY_EXPERIENCE_BONUS or 0) / 2)
        elseif self:normalizeSpecializationKey(person.specializationSecondary) == HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE then
            return math.floor((HelperPersonnelManager.SPECIALIZATION_SECONDARY_EXPERIENCE_BONUS or 0) / 2)
        end
    end

    if specializationKey == HelperPersonnelManager.SPECIALIZATION_FERTILIZING
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_SOWING
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION
        or specializationKey == HelperPersonnelManager.SPECIALIZATION_TRANSPORT then
        if self:normalizeSpecializationKey(person.specializationPrimary) == HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER then
            return math.floor((HelperPersonnelManager.SPECIALIZATION_PRIMARY_EXPERIENCE_BONUS or 0) / 2)
        elseif self:normalizeSpecializationKey(person.specializationSecondary) == HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER then
            return math.floor((HelperPersonnelManager.SPECIALIZATION_SECONDARY_EXPERIENCE_BONUS or 0) / 2)
        end
    end

    return 0
end

function HelperPersonnelManager:getSpecializationForFillType(fillType)
    if fillType == nil or FillType == nil then
        return nil
    end

    if fillType == FillType.SEEDS then
        return HelperPersonnelManager.SPECIALIZATION_SOWING
    elseif fillType == FillType.HERBICIDE then
        return HelperPersonnelManager.SPECIALIZATION_PLANT_PROTECTION
    elseif fillType == FillType.FERTILIZER or fillType == FillType.LIQUIDFERTILIZER or fillType == FillType.LIQUIDMANURE or fillType == FillType.DIGESTATE or fillType == FillType.MANURE then
        return HelperPersonnelManager.SPECIALIZATION_FERTILIZING
    end

    return nil
end

function HelperPersonnelManager:vehicleHasAnySpec(vehicle, specNames)
    if vehicle == nil or type(specNames) ~= "table" then
        return false
    end

    for _, specName in ipairs(specNames) do
        if vehicle[specName] ~= nil then
            return true
        end
    end

    return false
end

function HelperPersonnelManager:getSpecializationForVehicle(vehicle, effectName, fillType)
    local fillSpecialization = self:getSpecializationForFillType(fillType)
    if fillSpecialization ~= nil then
        return fillSpecialization
    end

    if vehicle == nil then
        return nil
    end

    if self:vehicleHasAnySpec(vehicle, {"spec_sowingMachine", "spec_planter"}) then
        return HelperPersonnelManager.SPECIALIZATION_SOWING
    end

    if self:vehicleHasAnySpec(vehicle, {"spec_sprayer"}) then
        return HelperPersonnelManager.SPECIALIZATION_FERTILIZING
    end

    if self:vehicleHasAnySpec(vehicle, {"spec_plow", "spec_cultivator", "spec_powerHarrows", "spec_discHarrow", "spec_roller", "spec_mulcher"}) then
        return HelperPersonnelManager.SPECIALIZATION_TILLAGE
    end

    if self:vehicleHasAnySpec(vehicle, {"spec_combine", "spec_cutter", "spec_baler", "spec_mower", "spec_forageWagon", "spec_pickup"}) then
        return HelperPersonnelManager.SPECIALIZATION_HARVEST
    end

    if self:vehicleHasAnySpec(vehicle, {"spec_trailer", "spec_dischargeable"}) then
        return HelperPersonnelManager.SPECIALIZATION_TRANSPORT
    end

    return nil
end

function HelperPersonnelManager:getGeneralSpecializationForEffect(effectName, fillType)
    if effectName == nil then
        return nil
    end

    effectName = tostring(effectName)
    if effectName == "wear" then
        return HelperPersonnelManager.SPECIALIZATION_MACHINE_CARE
    end

    if effectName == "fuel" or effectName == "consumables" then
        return HelperPersonnelManager.SPECIALIZATION_RESOURCE_SAVER
    end

    return nil
end

function HelperPersonnelManager:rememberWorkerSpecializationContext(worker, specializationKey, weight)
    if type(worker) ~= "table" then
        return
    end

    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if specializationKey == nil then
        return
    end

    weight = tonumber(weight) or 1
    if weight <= 0 then
        return
    end

    worker.currentJobSpecializationPractice = worker.currentJobSpecializationPractice or {}
    worker.currentJobSpecializationPractice[specializationKey] = (tonumber(worker.currentJobSpecializationPractice[specializationKey]) or 0) + weight

    local bestKey = nil
    local bestWeight = -1
    for key, value in pairs(worker.currentJobSpecializationPractice) do
        local normalizedKey = self:normalizeSpecializationKey(key)
        local numericValue = tonumber(value) or 0
        if normalizedKey ~= nil and numericValue > bestWeight then
            bestKey = normalizedKey
            bestWeight = numericValue
        end
    end

    worker.currentJobSpecializationKey = bestKey or specializationKey
end

function HelperPersonnelManager:workerHasSpecialization(worker, specializationKey)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if type(worker) ~= "table" or specializationKey == nil then
        return false
    end

    return self:normalizeSpecializationKey(worker.specializationPrimary) == specializationKey or self:normalizeSpecializationKey(worker.specializationSecondary) == specializationKey
end

function HelperPersonnelManager:getWorkerSpecializationPracticeKey(worker)
    if type(worker) ~= "table" then
        return nil
    end

    local primary = self:normalizeSpecializationKey(worker.specializationPrimary)
    local secondary = self:normalizeSpecializationKey(worker.specializationSecondary)
    if primary ~= nil and secondary ~= nil then
        return nil
    end

    local practice = worker.currentJobSpecializationPractice
    if type(practice) ~= "table" then
        return self:normalizeSpecializationKey(worker.currentJobSpecializationKey)
    end

    local activeProgressKey = self:normalizeSpecializationKey(worker.specializationProgressKey)
    if activeProgressKey ~= nil and not self:workerHasSpecialization(worker, activeProgressKey) and tonumber(practice[activeProgressKey]) ~= nil then
        return activeProgressKey
    end

    local bestTaskKey = nil
    local bestTaskWeight = -1
    local bestGeneralKey = nil
    local bestGeneralWeight = -1

    for key, value in pairs(practice) do
        local specializationKey = self:normalizeSpecializationKey(key)
        local numericValue = tonumber(value) or 0
        if specializationKey ~= nil and numericValue > 0 and not self:workerHasSpecialization(worker, specializationKey) then
            if self:isGeneralSpecializationKey(specializationKey) then
                if numericValue > bestGeneralWeight then
                    bestGeneralKey = specializationKey
                    bestGeneralWeight = numericValue
                end
            else
                if numericValue > bestTaskWeight then
                    bestTaskKey = specializationKey
                    bestTaskWeight = numericValue
                end
            end
        end
    end

    if primary == nil then
        return bestTaskKey or bestGeneralKey
    end

    return bestTaskKey or bestGeneralKey
end

function HelperPersonnelManager:getWorkerSpecializationLearningMinutes(worker, specializationKey, workMinutes)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    workMinutes = math.max(0, tonumber(workMinutes) or 0)
    if type(worker) ~= "table" or specializationKey == nil or workMinutes <= 0 then
        return 0
    end

    local experience = self:clampPersonStat(worker.experience or 0)
    local reliability = self:clampPersonStat(worker.reliability or 0)
    local factor = 1 + ((experience - 50) / 250) + ((reliability - 50) / 300)
    factor = math.max(HelperPersonnelManager.SPECIALIZATION_LEARNING_MIN_FACTOR or 0.75, math.min(HelperPersonnelManager.SPECIALIZATION_LEARNING_MAX_FACTOR or 1.30, factor))

    return math.max(1, math.floor((workMinutes * factor) + 0.5))
end

function HelperPersonnelManager:clearWorkerSpecializationRuntimeContext(worker)
    if type(worker) ~= "table" then
        return
    end

    worker.currentJobSpecializationKey = nil
    worker.currentJobSpecializationPractice = nil
end

function HelperPersonnelManager:addWorkerSpecializationProgress(worker, specializationKey, workMinutes)
    if type(worker) ~= "table" then
        return false
    end

    specializationKey = self:normalizeSpecializationKey(specializationKey)
    workMinutes = math.max(0, math.floor((tonumber(workMinutes) or 0) + 0.5))
    if specializationKey == nil or workMinutes < (HelperPersonnelManager.SPECIALIZATION_MIN_PRACTICE_JOB_MINUTES or 3) then
        return false
    end

    if self:workerHasSpecialization(worker, specializationKey) then
        return false
    end

    local primary = self:normalizeSpecializationKey(worker.specializationPrimary)
    local secondary = self:normalizeSpecializationKey(worker.specializationSecondary)
    if primary ~= nil and secondary ~= nil then
        return false
    end

    local progresses = self:getSpecializationProgressTable(worker)
    progresses[specializationKey] = math.max(0, math.floor((tonumber(progresses[specializationKey]) or 0) + workMinutes + 0.5))
    self:normalizeSpecializationProgresses(worker)
    return true
end

function HelperPersonnelManager:applyWorkerSpecializationIfReady(worker, preferredKey)
    if type(worker) ~= "table" then
        return nil
    end

    preferredKey = self:normalizeSpecializationKey(preferredKey)
    local primary = self:normalizeSpecializationKey(worker.specializationPrimary)
    local secondary = self:normalizeSpecializationKey(worker.specializationSecondary)
    if primary ~= nil and secondary ~= nil then
        worker.specializationProgresses = {}
        worker.specializationProgressKey = nil
        worker.specializationProgressMinutes = 0
        return nil
    end

    local requiredMinutes = self:getSpecializationRequiredMinutes(worker)
    local learnedKey = nil
    local learnedMinutes = 0

    if preferredKey ~= nil and not self:workerHasSpecialization(worker, preferredKey) then
        local preferredMinutes = self:getSpecializationProgressMinutes(worker, preferredKey)
        if preferredMinutes >= requiredMinutes then
            learnedKey = preferredKey
            learnedMinutes = preferredMinutes
        end
    end

    if learnedKey == nil then
        local learnedIsTask = false
        for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
            local specializationKey = self:normalizeSpecializationKey(key)
            local minutes = self:getSpecializationProgressMinutes(worker, specializationKey)
            if specializationKey ~= nil and minutes >= requiredMinutes and not self:workerHasSpecialization(worker, specializationKey) then
                local isTask = self:isTaskSpecializationKey(specializationKey)
                if learnedKey == nil or minutes > learnedMinutes or (minutes == learnedMinutes and isTask and not learnedIsTask) then
                    learnedKey = specializationKey
                    learnedMinutes = minutes
                    learnedIsTask = isTask
                end
            end
        end
    end

    if learnedKey == nil then
        self:normalizeSpecializationProgresses(worker)
        return nil
    end

    if primary == nil then
        worker.specializationPrimary = learnedKey
    else
        worker.specializationSecondary = learnedKey
    end

    if type(worker.specializationProgresses) == "table" then
        worker.specializationProgresses[learnedKey] = nil
    end
    self:normalizeSpecializationProgresses(worker)

    local template = self:getLocalizedText("ui_specializationLearned", "%s hat eine Spezialisierung entwickelt: %s.")
    self:showIngameNotification(string.format(template, self:getFullName(worker), self:getSpecializationDisplayName(learnedKey)), self:getInfoNotificationType())
    return learnedKey
end

function HelperPersonnelManager:recordWorkerSpecializationPractice(worker, specializationKey, workMinutes)
    if self:addWorkerSpecializationProgress(worker, specializationKey, workMinutes) then
        return self:applyWorkerSpecializationIfReady(worker, specializationKey) ~= nil
    end

    return false
end

function HelperPersonnelManager:recordWorkerSpecializationPracticeFromCurrentJob(worker, workMinutes)
    if type(worker) ~= "table" then
        return nil
    end

    local practice = worker.currentJobSpecializationPractice
    local preferredKey = self:getWorkerSpecializationPracticeKey(worker)
    local didAddProgress = false

    if type(practice) == "table" then
        local hasTaskPractice = false
        for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
            local specializationKey = self:normalizeSpecializationKey(key)
            if specializationKey ~= nil and self:isTaskSpecializationKey(specializationKey) and (tonumber(practice[specializationKey]) or 0) > 0 then
                hasTaskPractice = true
                break
            end
        end

        for _, key in ipairs(HelperPersonnelManager.SPECIALIZATION_KEYS or {}) do
            local specializationKey = self:normalizeSpecializationKey(key)
            local weight = specializationKey ~= nil and tonumber(practice[specializationKey]) or nil
            if specializationKey ~= nil and weight ~= nil and weight > 0 and not self:workerHasSpecialization(worker, specializationKey) then
                local learningMinutes = self:getWorkerSpecializationLearningMinutes(worker, specializationKey, workMinutes)
                local weightFactor = math.min(1, weight / 2)
                if self:isGeneralSpecializationKey(specializationKey) and not hasTaskPractice then
                    weightFactor = 1
                end
                local weightedLearningMinutes = math.max(0, math.floor(learningMinutes * weightFactor + 0.5))
                if self:addWorkerSpecializationProgress(worker, specializationKey, weightedLearningMinutes) then
                    didAddProgress = true
                end
            end
        end
    else
        local learningMinutes = self:getWorkerSpecializationLearningMinutes(worker, preferredKey, workMinutes)
        didAddProgress = self:addWorkerSpecializationProgress(worker, preferredKey, learningMinutes)
    end

    if didAddProgress then
        return self:applyWorkerSpecializationIfReady(worker, preferredKey)
    end

    return nil
end

function HelperPersonnelManager:getWorkerTrainingSpecializationKey(worker)
    if type(worker) ~= "table" then
        return nil
    end

    local primary = self:normalizeSpecializationKey(worker.specializationPrimary)
    local secondary = self:normalizeSpecializationKey(worker.specializationSecondary)
    if primary ~= nil and secondary ~= nil then
        return nil
    end

    local progressKey = self:getBestSpecializationProgress(worker)
    return self:normalizeSpecializationKey(progressKey)
end

function HelperPersonnelManager:getWorkerTrainingCost(worker, specializationKey)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if type(worker) ~= "table" or specializationKey == nil then
        return 0
    end

    local wage = tonumber(self:getCurrentMonthlyWage(worker)) or tonumber(worker.wage) or tonumber(worker.baseWage) or 0
    local factor = HelperPersonnelManager.TRAINING_SALARY_FACTORS ~= nil and HelperPersonnelManager.TRAINING_SALARY_FACTORS[specializationKey] or 1.00
    local cost = wage * factor
    return math.max(0, math.floor((cost / 10) + 0.5) * 10)
end

function HelperPersonnelManager:getWorkerTrainingProgressMinutes(worker, specializationKey)
    specializationKey = self:normalizeSpecializationKey(specializationKey)
    if type(worker) ~= "table" or specializationKey == nil then
        return 0
    end

    local requiredMinutes = self:getSpecializationRequiredMinutes(worker)
    local currentMinutes = self:getSpecializationProgressMinutes(worker, specializationKey)
    local remainingMinutes = math.max(0, requiredMinutes - currentMinutes)
    if remainingMinutes <= 0 then
        return 0
    end

    local fraction = HelperPersonnelManager.TRAINING_PROGRESS_FRACTION or 0.30
    local baseMinutes = math.max(HelperPersonnelManager.TRAINING_MIN_PROGRESS_MINUTES or 30, math.floor(requiredMinutes * fraction + 0.5))
    return math.max(0, math.min(remainingMinutes, baseMinutes))
end

function HelperPersonnelManager:isFirstDayOfCurrentPeriod()
    local day = self:getEnvironmentDayInPeriod()
    return day == nil or day <= 1
end

function HelperPersonnelManager:isTrainingStartAllowedNow()
    local daysPerMonth = self:getSalaryDaysPerMonth()
    local currentDay = self:getEnvironmentDayInPeriod()

    if currentDay ~= nil and currentDay > 1 then
        return false, "notFirstDay", currentDay, nil, daysPerMonth
    end

    if daysPerMonth <= 1 then
        local currentMinute = self:getIngameDayMinute()
        local deadlineMinute = HelperPersonnelManager.TRAINING_SINGLE_DAY_START_DEADLINE_MINUTE or 720
        if currentMinute ~= nil and currentMinute > deadlineMinute then
            return false, "singleDayDeadline", currentDay, currentMinute, daysPerMonth
        end
    end

    return true, nil, currentDay, nil, daysPerMonth
end

function HelperPersonnelManager:isWorkerInTraining(worker, period, year)
    if type(worker) ~= "table" then
        return false
    end

    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil or year == nil then
        return false
    end

    return (tonumber(worker.trainingActivePeriod) or 0) == period and (tonumber(worker.trainingActiveYear) or 0) == year
end

function HelperPersonnelManager:canTrainWorkerThisYear(worker, period, year)
    if type(worker) ~= "table" then
        return false
    end

    period, year = self:getApplicantPeriodInfo(period, year)
    if year == nil or year <= 0 then
        return true
    end

    return (tonumber(worker.trainingLastYear) or 0) ~= year
end

function HelperPersonnelManager:getShortPeriodLabel(period, year)
    local monthName = self:getMonthName(period)
    year = math.floor((tonumber(year) or 0) + 0.5)
    if monthName ~= nil and year > 0 then
        return string.format("%s J%d", monthName, year)
    elseif year > 0 then
        return string.format("Jahr %d", year)
    end
    return "-"
end

function HelperPersonnelManager:getWorkerTrainingLastText(worker)
    if type(worker) ~= "table" then
        return "-"
    end

    local year = tonumber(worker.trainingLastYear) or 0
    if year <= 0 then
        return self:getLocalizedText("ui_training_last_none", "-")
    end

    local specializationName = self:getSpecializationDisplayName(worker.trainingLastSpecialization)
    if specializationName == nil or specializationName == "" then
        specializationName = self:getLocalizedText("ui_training_unknown", "unbekannt")
    end

    return string.format("%s %s", specializationName, self:getShortPeriodLabel(worker.trainingLastPeriod, worker.trainingLastYear))
end

function HelperPersonnelManager:getWorkerTrainingInfoLine(worker)
    if type(worker) ~= "table" then
        return ""
    end

    self:normalizePersonRuntimeData(worker)

    local lastText = self:getWorkerTrainingLastText(worker)
    if self:isWorkerInTraining(worker) then
        local specName = self:getSpecializationDisplayName(worker.trainingActiveSpecialization) or self:getLocalizedText("ui_training_unknown", "unbekannt")
        local template = self:getLocalizedText("ui_training_line_active", "Schulung: läuft %s bis Monatsende · letzte: %s")
        return string.format(template, specName, lastText)
    end

    local specializationKey = self:getWorkerTrainingSpecializationKey(worker)
    if specializationKey == nil then
        local template = self:getLocalizedText("ui_training_line_no_direction", "Schulung: keine Lernrichtung · letzte: %s")
        return string.format(template, lastText)
    end

    local specName = self:getSpecializationDisplayName(specializationKey)
    local costText = self:formatMoneyForText(self:getWorkerTrainingCost(worker, specializationKey))

    if not self:canTrainWorkerThisYear(worker) then
        local template = self:getLocalizedText("ui_training_line_year_blocked", "Schulung: erst nächstes Jahr · letzte: %s")
        return string.format(template, lastText)
    end

    local trainingStartAllowed, trainingBlockedReason = self:isTrainingStartAllowedNow()
    if not trainingStartAllowed then
        if trainingBlockedReason == "singleDayDeadline" then
            local template = self:getLocalizedText("ui_training_line_single_day_deadline", "Schulung: bei 1 Tag/Monat nur bis 12:00 · %s %s · letzte: %s")
            return string.format(template, specName, costText, lastText)
        end

        local template = self:getLocalizedText("ui_training_line_first_day", "Schulung: nur am 1. Tag · %s %s · letzte: %s")
        return string.format(template, specName, costText, lastText)
    end

    if worker.busy == true then
        local template = self:getLocalizedText("ui_training_line_busy", "Schulung: nicht möglich, im Einsatz · %s %s · letzte: %s")
        return string.format(template, specName, costText, lastText)
    end

    if self.isWorkerSick ~= nil and self:isWorkerSick(worker) then
        local template = self:getLocalizedText("ui_training_line_sick", "Schulung: nicht möglich, krank · %s %s · letzte: %s")
        return string.format(template, specName, costText, lastText)
    end

    local template = self:getLocalizedText("ui_training_line_possible", "Schulung: möglich %s, %s · letzte: %s")
    return string.format(template, specName, costText, lastText)
end

function HelperPersonnelManager:trainWorker(workerId)
    local worker = self:getWorkerById(workerId)
    if worker == nil then
        return false
    end

    if worker.busy == true then
        self:showIngameNotification(self:getLocalizedText("ui_training_worker_busy", "Der Mitarbeiter ist gerade im Einsatz und kann nicht geschult werden."), self:getInfoNotificationType())
        return false
    end

    if self.isWorkerSick ~= nil and self:isWorkerSick(worker) then
        self:showIngameNotification(self:getLocalizedText("ui_training_worker_sick", "Der Mitarbeiter ist krank und kann nicht geschult werden."), self:getInfoNotificationType())
        return false
    end

    if self:isWorkerInTraining(worker) then
        self:showIngameNotification(self:getLocalizedText("ui_training_worker_in_training", "Der Mitarbeiter ist bereits bis Monatsende in Schulung."), self:getInfoNotificationType())
        return false
    end

    local trainingStartAllowed, trainingBlockedReason = self:isTrainingStartAllowedNow()
    if not trainingStartAllowed then
        if trainingBlockedReason == "singleDayDeadline" then
            self:showIngameNotification(self:getLocalizedText("ui_training_not_single_day_deadline", "Bei 1 Tag pro Monat können Schulungen nur am ersten Tag bis 12:00 Uhr begonnen werden."), self:getInfoNotificationType())
        else
            self:showIngameNotification(self:getLocalizedText("ui_training_not_first_day", "Schulungen können nur am ersten Tag eines Monats begonnen werden."), self:getInfoNotificationType())
        end
        return false
    end

    local specializationKey = self:getWorkerTrainingSpecializationKey(worker)
    if specializationKey == nil then
        self:showIngameNotification(self:getLocalizedText("ui_training_no_progress", "Für diesen Mitarbeiter gibt es noch keine passende Lernrichtung."), self:getInfoNotificationType())
        return false
    end

    local period, year = self:getApplicantPeriodInfo()
    if not self:canTrainWorkerThisYear(worker, period, year) then
        local template = self:getLocalizedText("ui_training_already_done_year", "%s wurde in diesem Jahr bereits geschult.")
        self:showIngameNotification(string.format(template, self:getFullName(worker)), self:getInfoNotificationType())
        return false
    end

    local progressMinutes = self:getWorkerTrainingProgressMinutes(worker, specializationKey)
    if progressMinutes <= 0 then
        return false
    end

    local beforePercent = self:getSpecializationProgressPercentForMinutes(worker, self:getSpecializationProgressMinutes(worker, specializationKey))
    local cost = self:getWorkerTrainingCost(worker, specializationKey)
    local _, farmId = self:getCurrentFarmMoney()
    self:addFarmMoney(-cost, farmId)

    worker.trainingLastPeriod = period or 0
    worker.trainingLastYear = year or 0
    worker.trainingLastSpecialization = specializationKey
    worker.trainingActivePeriod = period or 0
    worker.trainingActiveYear = year or 0
    worker.trainingActiveSpecialization = specializationKey

    local progresses = self:getSpecializationProgressTable(worker)
    progresses[specializationKey] = math.max(0, math.floor((tonumber(progresses[specializationKey]) or 0) + progressMinutes + 0.5))
    self:normalizeSpecializationProgresses(worker)
    local learnedKey = self:applyWorkerSpecializationIfReady(worker, specializationKey)
    local afterPercent = learnedKey ~= nil and 100 or self:getSpecializationProgressPercentForMinutes(worker, self:getSpecializationProgressMinutes(worker, specializationKey))

    local template = self:getLocalizedText("ui_training_completed", "%s beginnt eine Schulung für %s bis Monatsende: %d%% -> %d%% (%s).")
    local text = string.format(template, self:getFullName(worker), self:getSpecializationDisplayName(specializationKey), beforePercent or 0, afterPercent or 0, self:formatMoneyForText(cost))
    self.lastActionText = text
    self:addActionHistoryEntry(text, period, year)
    self.changeCounter = (self.changeCounter or 0) + 1
    self:showIngameNotification(text, self:getInfoNotificationType())
    return true
end

function HelperPersonnelManager:trainWorkerForFarm(workerId, farmId)
    if self.executeWithFarmContext ~= nil then
        return self:executeWithFarmContext(farmId, function()
            return self:trainWorker(workerId)
        end, true)
    end

    return self:trainWorker(workerId)
end

function HelperPersonnelManager:rollApplicantExperience()
    local reputation = self:getEmployerReputation()

    local repShift = math.max(-4, math.min(4, math.floor(((reputation or 60) - 60) / 10 + 0.5)))
    local r = math.random()
    local experience

    if r < 0.64 then
        experience = math.random(8, 42)
    elseif r < 0.86 then
        experience = math.random(43, 58)
    elseif r < 0.975 then
        experience = math.random(59, 72)
    elseif r < 0.997 then
        experience = math.random(73, 82)
    else
        experience = math.random(83, 88)
    end

    return self:clampPersonStat(experience + repShift)
end

function HelperPersonnelManager:getApplicantSpecializationChance(experience, reliability)
    experience = self:clampPersonStat(experience or 0)
    reliability = self:clampPersonStat(reliability or 0)

    local chance = 0.14

    if experience >= 45 then
        chance = chance + 0.06
    end
    if experience >= 55 then
        chance = chance + 0.08
    end
    if experience >= 70 then
        chance = chance + 0.10
    end
    if experience >= 80 then
        chance = chance + 0.08
    end
    if reliability >= 70 then
        chance = chance + 0.05
    end
    if reliability >= 85 then
        chance = chance + 0.05
    end
    local reputation = self:getEmployerReputation()
    if reputation >= 75 then
        chance = chance + 0.05
    end
    if reputation >= 90 then
        chance = chance + 0.05
    end

    return math.min(0.60, chance)
end

function HelperPersonnelManager:assignRandomApplicantSpecializations(person)
    if type(person) ~= "table" then
        return
    end

    local chance = self:getApplicantSpecializationChance(person.experience, person.reliability)
    if math.random() >= chance then
        person.specializationPrimary = nil
        person.specializationSecondary = nil
        return
    end

    local keys = HelperPersonnelManager.SPECIALIZATION_KEYS or {}
    person.specializationPrimary = keys[math.random(1, #keys)]

    local secondaryChance = math.max(0.01, chance * 0.18)
    if math.random() < secondaryChance and #keys > 1 then
        local secondary = person.specializationPrimary
        for _ = 1, 12 do
            secondary = keys[math.random(1, #keys)]
            if secondary ~= person.specializationPrimary then
                break
            end
        end
        if secondary ~= person.specializationPrimary then
            person.specializationSecondary = secondary
        end
    end
end

function HelperPersonnelManager:getSmoothedExperienceForGameplay(experience)
    experience = self:clampPersonStat(experience or 0)

    if experience <= 0 then
        return 0
    elseif experience >= 100 then
        return 100
    end

    local missing = 100 - experience
    local smoothed = 100 - ((missing ^ 1.12) / (100 ^ 0.12))
    return self:clampPersonStat(smoothed)
end

function HelperPersonnelManager:getEffectiveGameplayExperience(worker, effectName, vehicle, fillType)
    if not self:isGameplayExperienceEffectEnabled(effectName) then
        return 100
    end

    if type(worker) ~= "table" then
        return 100
    end

    local experience = self:getSmoothedExperienceForGameplay(worker.experience or 0)
    local taskSpecializationKey = self:getSpecializationForVehicle(vehicle, effectName, fillType)
    local generalSpecializationKey = self:getGeneralSpecializationForEffect(effectName, fillType)
    local specializationBonus = 0

    if taskSpecializationKey ~= nil then
        self:rememberWorkerSpecializationContext(worker, taskSpecializationKey, 2)
        specializationBonus = math.max(specializationBonus, self:getDirectPersonSpecializationExperienceBonus(worker, taskSpecializationKey))
    end

    if generalSpecializationKey ~= nil then
        self:rememberWorkerSpecializationContext(worker, generalSpecializationKey, 1)
        specializationBonus = math.max(specializationBonus, self:getDirectPersonSpecializationExperienceBonus(worker, generalSpecializationKey))
    end

    return self:clampPersonStat(experience + specializationBonus)
end

function HelperPersonnelManager:getEffectiveGameplayReliability(worker, effectName)
    if not self:isGameplayExperienceEffectEnabled("reliability") then
        return 100
    end

    if type(worker) ~= "table" then
        return 100
    end

    return self:clampPersonStat(worker.reliability or 0)
end

function HelperPersonnelManager:isPersonnelEffectEnabled(effectName)
    if self.config ~= nil and self.config.isPersonnelEffectEnabled ~= nil then
        return self.config:isPersonnelEffectEnabled(effectName)
    end

    return true
end

function HelperPersonnelManager:getEffectiveLoyalty(worker, effectName)
    if not self:isPersonnelEffectEnabled(effectName or "loyalty") then
        return 100
    end

    if type(worker) ~= "table" then
        return 100
    end

    return self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
end

function HelperPersonnelManager:logWageIfNeeded(person, baseWage, currentWage, useIndividual, sourceName)
    if HelperPersonnelManager.WAGE_DEBUG_LOGGING ~= true then
        return
    end

    if type(person) ~= "table" or Logging == nil or Logging.info == nil then
        return
    end

    local key = tostring(person.id or self:getFullName(person) or "person")
    local now = self:getCurrentTimestampMs()
    local state = self._wageDebugLogStateByPerson[key]
    if state == nil then
        state = { lastLogTime = -HelperPersonnelManager.WAGE_DEBUG_INTERVAL_MS }
        self._wageDebugLogStateByPerson[key] = state
    end

    if now - (state.lastLogTime or 0) < HelperPersonnelManager.WAGE_DEBUG_INTERVAL_MS then
        return
    end

    state.lastLogTime = now

    local fullName = self:getFullName(person)
    local standardBaseWage = self:getStandardBaseMonthlyWage()
    local monthFactor = self:getSalaryMonthLengthFactor()
    local economyFactor = self:getSalaryEconomyCostMultiplier()
    local totalFactor = self:getSalaryTotalMultiplier()

    Logging.info("FS25_HelperPersonnel: Gehalt-Test | Quelle=%s | Mitarbeiter=%s | Individuell=%s | Erfahrung=%d | Zuverlaessigkeit=%d | Grundgehalt=%.2f | StandardGrundgehalt=%.2f | TageProMonatFaktor=%.2f | WirtschaftsFaktor=%.2f | GesamtFaktor=%.2f | Monatsgehalt=%.2f",
        tostring(sourceName or "Berechnung"),
        fullName ~= "" and fullName or "unbekannt",
        tostring(useIndividual == true),
        self:clampPersonStat(person.experience or 0),
        self:clampPersonStat(person.reliability or 0),
        tonumber(baseWage) or 0,
        tonumber(standardBaseWage) or 0,
        tonumber(monthFactor) or 0,
        tonumber(economyFactor) or 0,
        tonumber(totalFactor) or 0,
        tonumber(currentWage) or 0
    )
end

function HelperPersonnelManager:getCurrentMonthlyWage(person)
    if type(person) ~= "table" then
        return 0
    end

    if not self:useIndividualWages() then
        local standardBaseWage = self:getStandardBaseMonthlyWage()
        local wage = self:calculateCurrentMonthlyWageFromBase(standardBaseWage)
        person.wage = wage
        self:logWageIfNeeded(person, standardBaseWage, wage, false, "Standardgehalt")
        return wage
    end

    local baseWage = tonumber(person.baseWage)
    if baseWage == nil or baseWage <= 0 then
        baseWage = self:calculateBaseSalaryForStats(person.experience or 0, person.reliability or 0)
        person.baseWage = baseWage
    end

    local wage = self:calculateCurrentMonthlyWageFromBase(baseWage)
    person.wage = wage
    self:logWageIfNeeded(person, baseWage, wage, true, "Individuell")

    return wage
end

function HelperPersonnelManager:normalizePersonRuntimeData(person)
    if type(person) ~= "table" then
        return
    end

    person.jobsCompleted = math.max(0, person.jobsCompleted or 0)
    person.totalWorkMinutes = math.max(0, person.totalWorkMinutes or 0)
    person.lastJobMinutes = math.max(0, person.lastJobMinutes or 0)
    person.totalEarnings = math.max(0, person.totalEarnings or 0)
    person.currentJobStartedAt = person.currentJobStartedAt or 0
    person.currentJobElapsedMs = math.max(0, person.currentJobElapsedMs or 0)
    person.vehicleName = person.vehicleName or ""
    person.vehicleKey = person.vehicleKey or nil
    person.experience = self:clampPersonStat(person.experience or 0)
    person.reliability = self:clampPersonStat(person.reliability or 0)
    person.loyalty = self:clampPersonStat(person.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    person.specializationPrimary = self:normalizeSpecializationKey(person.specializationPrimary)
    person.specializationSecondary = self:normalizeSpecializationKey(person.specializationSecondary)
    if person.specializationSecondary == person.specializationPrimary then
        person.specializationSecondary = nil
    end
    self:normalizeSpecializationProgresses(person)
    self:getCurrentMonthlyWage(person)

    local portraitCount = HelperPersonnelManager.PORTRAIT_COUNT or 1
    person.avatarIndex = tonumber(person.avatarIndex) or 0
    if person.avatarIndex < 1 or person.avatarIndex > portraitCount then
        person.avatarIndex = self:getDefaultAvatarIndexForId(person.id)
    end

    person.gender = self:normalizeGender(person.gender) or self:getGenderForAvatarIndex(person.avatarIndex)

    if person.hiredPeriod ~= nil then
        person.hiredPeriod = math.max(1, math.floor((tonumber(person.hiredPeriod) or 1) + 0.5))
    end

    if person.hiredYear ~= nil then
        person.hiredYear = math.max(1, math.floor((tonumber(person.hiredYear) or 1) + 0.5))
    end

    person.loyaltyMilestoneMonths = math.max(0, math.floor((tonumber(person.loyaltyMilestoneMonths) or 0) + 0.5))
    person.loyaltyTenureMilestoneMonths = math.max(0, math.floor((tonumber(person.loyaltyTenureMilestoneMonths) or 0) + 0.5))
    person.nightWorkIngameMinutes = math.max(0, math.floor((tonumber(person.nightWorkIngameMinutes) or 0) + 0.5))
    person.nightWorkRealtimeMs = math.max(0, tonumber(person.nightWorkRealtimeMs) or 0)
    person.nightWorkLastMinute = tonumber(person.nightWorkLastMinute)
    person.loyaltyReputationProgress = tonumber(person.loyaltyReputationProgress) or 0
    person.loyaltyWarningPeriod = math.max(0, math.floor((tonumber(person.loyaltyWarningPeriod) or 0) + 0.5))
    person.loyaltyWarningYear = math.max(0, math.floor((tonumber(person.loyaltyWarningYear) or 0) + 0.5))
    person.resignationPending = person.resignationPending == true
    person.dismissalPending = person.dismissalPending == true
    person.dismissalNoticePeriod = math.max(0, math.floor((tonumber(person.dismissalNoticePeriod) or 0) + 0.5))
    person.dismissalNoticeYear = math.max(0, math.floor((tonumber(person.dismissalNoticeYear) or 0) + 0.5))
    person.dismissalEffectivePeriod = math.max(0, math.floor((tonumber(person.dismissalEffectivePeriod) or 0) + 0.5))
    person.dismissalEffectiveYear = math.max(0, math.floor((tonumber(person.dismissalEffectiveYear) or 0) + 0.5))
    person.resignationNoticePeriod = math.max(0, math.floor((tonumber(person.resignationNoticePeriod) or 0) + 0.5))
    person.resignationNoticeYear = math.max(0, math.floor((tonumber(person.resignationNoticeYear) or 0) + 0.5))
    person.resignationCheckPeriod = math.max(0, math.floor((tonumber(person.resignationCheckPeriod) or 0) + 0.5))
    person.resignationCheckYear = math.max(0, math.floor((tonumber(person.resignationCheckYear) or 0) + 0.5))
    person.sickPeriod = math.max(0, math.floor((tonumber(person.sickPeriod) or 0) + 0.5))
    person.sickYear = math.max(0, math.floor((tonumber(person.sickYear) or 0) + 0.5))
    person.sickDay = math.max(0, math.floor((tonumber(person.sickDay) or 0) + 0.5))
    person.sicknessPeriod = math.max(0, math.floor((tonumber(person.sicknessPeriod) or 0) + 0.5))
    person.sicknessYear = math.max(0, math.floor((tonumber(person.sicknessYear) or 0) + 0.5))
    person.sicknessDaysThisPeriod = math.max(0, math.floor((tonumber(person.sicknessDaysThisPeriod) or 0) + 0.5))
    person.reliabilityWorkPeriod = math.max(0, math.floor((tonumber(person.reliabilityWorkPeriod) or 0) + 0.5))
    person.reliabilityWorkYear = math.max(0, math.floor((tonumber(person.reliabilityWorkYear) or 0) + 0.5))
    person.reliabilityWorkMinutesThisPeriod = math.max(0, math.floor((tonumber(person.reliabilityWorkMinutesThisPeriod) or 0) + 0.5))
    person.reliabilityIncidentPeriod = math.max(0, math.floor((tonumber(person.reliabilityIncidentPeriod) or 0) + 0.5))
    person.reliabilityIncidentYear = math.max(0, math.floor((tonumber(person.reliabilityIncidentYear) or 0) + 0.5))
    person.reliabilityIncidentsThisPeriod = math.max(0, math.floor((tonumber(person.reliabilityIncidentsThisPeriod) or 0) + 0.5))
    person.reliabilitySicknessPeriod = math.max(0, math.floor((tonumber(person.reliabilitySicknessPeriod) or 0) + 0.5))
    person.reliabilitySicknessYear = math.max(0, math.floor((tonumber(person.reliabilitySicknessYear) or 0) + 0.5))
    person.reliabilitySicknessDaysThisPeriod = math.max(0, math.floor((tonumber(person.reliabilitySicknessDaysThisPeriod) or 0) + 0.5))
    person.reliabilityNightWorkPeriod = math.max(0, math.floor((tonumber(person.reliabilityNightWorkPeriod) or 0) + 0.5))
    person.reliabilityNightWorkYear = math.max(0, math.floor((tonumber(person.reliabilityNightWorkYear) or 0) + 0.5))
    person.reliabilityNightWorkMinutesThisPeriod = math.max(0, math.floor((tonumber(person.reliabilityNightWorkMinutesThisPeriod) or 0) + 0.5))
    person.reliabilityDevelopmentCheckPeriod = math.max(0, math.floor((tonumber(person.reliabilityDevelopmentCheckPeriod) or 0) + 0.5))
    person.reliabilityDevelopmentCheckYear = math.max(0, math.floor((tonumber(person.reliabilityDevelopmentCheckYear) or 0) + 0.5))
    person.experiencePeriod = math.floor((tonumber(person.experiencePeriod) or 0) + 0.5)
    person.experienceYear = math.floor((tonumber(person.experienceYear) or 0) + 0.5)
    person.experienceThisPeriod = math.max(0, math.floor((tonumber(person.experienceThisPeriod) or 0) + 0.5))
    person.experienceProgressMinutes = math.max(0, math.floor((tonumber(person.experienceProgressMinutes) or 0) + 0.5))

    person.trainingLastPeriod = math.max(0, math.floor((tonumber(person.trainingLastPeriod) or 0) + 0.5))
    person.trainingLastYear = math.max(0, math.floor((tonumber(person.trainingLastYear) or 0) + 0.5))
    person.trainingLastSpecialization = self:normalizeSpecializationKey(person.trainingLastSpecialization)
    person.trainingActivePeriod = math.max(0, math.floor((tonumber(person.trainingActivePeriod) or 0) + 0.5))
    person.trainingActiveYear = math.max(0, math.floor((tonumber(person.trainingActiveYear) or 0) + 0.5))
    person.trainingActiveSpecialization = self:normalizeSpecializationKey(person.trainingActiveSpecialization)

    if person.restorePending == nil then
        person.restorePending = false
    end

    return person
end

function HelperPersonnelManager:normalizeApplicantRuntimeData(applicant)
    if type(applicant) ~= "table" then
        return
    end

    self:normalizePersonRuntimeData(applicant)

    applicant.monthsAvailable = tonumber(applicant.monthsAvailable) or 0
    applicant.monthsAvailable = math.max(0, math.floor(applicant.monthsAvailable + 0.5))

    return applicant
end

function HelperPersonnelManager:repairApplicantGendersFromHelperProfiles()
    local changed = false

    for _, applicant in ipairs(self.applicants) do
        if type(applicant) == "table" then
            local detectedGender = self:getGenderForAvatarIndex(applicant.avatarIndex)
            detectedGender = self:normalizeGender(detectedGender)

            if detectedGender ~= nil and self:normalizeGender(applicant.gender) ~= detectedGender then
                applicant.gender = detectedGender
                applicant.firstName = self:getRandomFirstNameForGender(detectedGender)
                changed = true
            end
        end
    end

    if changed then
        if Logging ~= nil and Logging.info ~= nil then
            HelperPersonnel.debugInfo("FS25_HelperPersonnel: Bewerber-Geschlechter anhand der live erkannten Helferprofile korrigiert")
        end

        if type(self.notifyDataChanged) == "function" then
            self:notifyDataChanged()
        end
    end

    return changed
end

function HelperPersonnelManager:getExperienceLearningSettings(workerOrExperience)
    local experience = 0

    if type(workerOrExperience) == "table" then
        experience = workerOrExperience.experience or 0
    else
        experience = workerOrExperience or 0
    end

    experience = self:clampPersonStat(experience)

    for _, tier in ipairs(HelperPersonnelManager.EXPERIENCE_LEARNING_TIERS) do
        if experience <= (tier.maxExperience or 100) then
            return math.max(1, tier.minutesPerPoint or HelperPersonnelManager.EXPERIENCE_MINUTES_PER_POINT), tier.monthlyLimitAdjustment or 0
        end
    end

    return HelperPersonnelManager.EXPERIENCE_MINUTES_PER_POINT, 0
end

function HelperPersonnelManager:getExperienceMinutesPerPoint(workerOrExperience)
    local minutesPerPoint = self:getExperienceLearningSettings(workerOrExperience)
    return minutesPerPoint
end

function HelperPersonnelManager:getMaxExperienceGainPerPeriod(workerOrExperience)
    local days = math.max(1, math.min(28, math.floor((tonumber(self:getSalaryDaysPerMonth()) or HelperPersonnelManager.DEFAULT_SALARY_MONTH_LENGTH_DAYS) + 0.5)))
    local baseLimit = HelperPersonnelManager.EXPERIENCE_MONTHLY_GAIN_LIMITS[days] or 3

    if workerOrExperience ~= nil then
        local _, adjustment = self:getExperienceLearningSettings(workerOrExperience)
        return math.max(1, baseLimit + (adjustment or 0))
    end

    return baseLimit
end

function HelperPersonnelManager:resetWorkerExperiencePeriodIfNeeded(worker, period, year)
    if type(worker) ~= "table" then
        return
    end

    if period == nil or period <= 0 then
        period, year = self:getApplicantPeriodInfo()
    end

    period = math.floor((tonumber(period) or 0) + 0.5)
    year = math.floor((tonumber(year) or 1) + 0.5)

    if (tonumber(worker.experiencePeriod) or 0) ~= period or (tonumber(worker.experienceYear) or 0) ~= year then
        worker.experiencePeriod = period
        worker.experienceYear = year
        worker.experienceThisPeriod = 0

        worker.experienceProgressMinutes = math.max(0, math.floor((tonumber(worker.experienceProgressMinutes) or 0) + 0.5))
    end
end

function HelperPersonnelManager:awardWorkerExperience(worker, workMinutes)
    if type(worker) ~= "table" then
        return 0, self:getMaxExperienceGainPerPeriod()
    end

    local period, year = self:getApplicantPeriodInfo()
    self:resetWorkerExperiencePeriodIfNeeded(worker, period, year)

    local maxGain = self:getMaxExperienceGainPerPeriod(worker)
    local alreadyGained = math.max(0, math.floor((tonumber(worker.experienceThisPeriod) or 0) + 0.5))
    local remaining = math.max(0, maxGain - alreadyGained)
    local currentExperience = self:clampPersonStat(worker.experience or 0)

    if remaining <= 0 or currentExperience >= 100 then
        return 0, maxGain
    end

    workMinutes = math.max(0, math.floor((tonumber(workMinutes) or 0) + 0.5))
    if workMinutes <= 0 then
        return 0, maxGain
    end

    local maxGainPerJob = math.max(1, HelperPersonnelManager.MAX_EXPERIENCE_GAIN_PER_JOB or remaining)
    local progressMinutes = math.max(0, math.floor((tonumber(worker.experienceProgressMinutes) or 0) + 0.5)) + workMinutes
    local gained = 0

    while gained < remaining and gained < maxGainPerJob and currentExperience < 100 do
        local minutesPerPoint = self:getExperienceMinutesPerPoint(currentExperience)
        if progressMinutes < minutesPerPoint then
            break
        end

        progressMinutes = progressMinutes - minutesPerPoint
        currentExperience = self:clampPersonStat(currentExperience + 1)
        gained = gained + 1
    end

    worker.experienceProgressMinutes = math.max(0, math.floor(progressMinutes + 0.5))

    if gained > 0 then
        worker.experience = currentExperience
        worker.experienceThisPeriod = alreadyGained + gained
    end

    return gained, maxGain
end

function HelperPersonnelManager:calculateExperienceGain(workMinutes, workerOrExperience)
    workMinutes = math.max(0, math.floor((tonumber(workMinutes) or 0) + 0.5))
    if workMinutes <= 0 then
        return 0
    end

    local currentExperience = self:clampPersonStat(type(workerOrExperience) == "table" and (workerOrExperience.experience or 0) or (workerOrExperience or 0))
    local maxGainPerJob = math.max(1, HelperPersonnelManager.MAX_EXPERIENCE_GAIN_PER_JOB or 1)
    local gained = 0
    local progressMinutes = workMinutes

    while gained < maxGainPerJob and currentExperience < 100 do
        local minutesPerPoint = self:getExperienceMinutesPerPoint(currentExperience)
        if progressMinutes < minutesPerPoint then
            break
        end

        progressMinutes = progressMinutes - minutesPerPoint
        currentExperience = self:clampPersonStat(currentExperience + 1)
        gained = gained + 1
    end

    return math.max(0, gained)
end

function HelperPersonnelManager:getExperienceNotificationType()
    if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_OK ~= nil then
        return FSBaseMission.INGAME_NOTIFICATION_OK
    end

    if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_INFO ~= nil then
        return FSBaseMission.INGAME_NOTIFICATION_INFO
    end

    return 0
end

function HelperPersonnelManager:getInfoNotificationType()
    if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_INFO ~= nil then
        return FSBaseMission.INGAME_NOTIFICATION_INFO
    end

    return self:getExperienceNotificationType()
end

function HelperPersonnelManager:getLocalizedText(key, fallback)
    local text = fallback or key

    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local ok, translated = pcall(function()
            return g_i18n:getText(key)
        end)

        if ok and translated ~= nil and translated ~= "" and string.match(translated, "^Missing '") == nil then
            text = translated
        end
    end

    return text
end

function HelperPersonnelManager:showIngameNotification(text, notificationType)
    if text == nil or text == "" then
        return
    end

    local app = self.app or g_helperPersonnelApp

    if app ~= nil and app.showIngameNotification ~= nil then
        app:showIngameNotification(text, notificationType)
    elseif g_currentMission ~= nil and g_currentMission.addIngameNotification ~= nil then
        g_currentMission:addIngameNotification(notificationType or self:getInfoNotificationType(), text)
    elseif Logging ~= nil and Logging.info ~= nil then
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: %s", tostring(text))
    end
end

function HelperPersonnelManager:showExperienceGainNotification(worker, experienceGain, previousExperience, newExperience)
    experienceGain = math.max(0, math.floor((tonumber(experienceGain) or 0) + 0.5))
    if type(worker) ~= "table" or experienceGain <= 0 then
        return
    end

    previousExperience = self:clampPersonStat(previousExperience or worker.experience or 0)
    newExperience = self:clampPersonStat(newExperience or worker.experience or previousExperience)

    local fullName = self:getFullName(worker)
    local text

    if experienceGain == 1 then
        local template = self:getLocalizedText("ui_experienceGainSingle", "%s hat einen Erfahrungspunkt gewonnen. Erfahrung: %d auf %d")
        text = string.format(template, fullName, previousExperience, newExperience)
    else
        local template = self:getLocalizedText("ui_experienceGainMultiple", "%s hat %d Erfahrungspunkte gewonnen. Erfahrung: %d auf %d")
        text = string.format(template, fullName, experienceGain, previousExperience, newExperience)
    end

    self:showIngameNotification(text, self:getExperienceNotificationType())
end

function HelperPersonnelManager:showExperienceLimitNotification(worker, monthlyLimit)
    if type(worker) ~= "table" then
        return
    end

    local period, year = self:getApplicantPeriodInfo()
    local notificationKey = string.format("%d:%d", tonumber(period) or 0, tonumber(year) or 0)

    if worker.experienceLimitNotificationKey == notificationKey then
        return
    end

    worker.experienceLimitNotificationKey = notificationKey

    local template = self:getLocalizedText("ui_experienceMonthlyLimitReached", "%s hat das monatliche Erfahrungslimit erreicht.")
    local text = string.format(template, self:getFullName(worker))
    self:showIngameNotification(text, self:getInfoNotificationType())
end

function HelperPersonnelManager:loadFromSavegame()
    self:loadConfig()
    self.workers = {}
    self.applicants = {}
    self:resetRestoredActiveJobs()

    local savePath = self.app:getSavegamePath()
    if savePath == nil or savePath == "" or not fileExists(savePath) then
        self:initializeNewApplicantMarket()
        return
    end

    local xmlFile = XMLFile.loadIfExists("helperPersonnel", savePath, HelperPersonnelManager.xmlSchema)
    if xmlFile == nil then
        self:initializeNewApplicantMarket()
        return
    end

    self.nextPersonId = xmlFile:getInt("helperPersonnel#nextId", 1)
    self.lastActionText = xmlFile:getString("helperPersonnel#lastAction", "")
    self.employerReputation = self:clampEmployerReputation(xmlFile:getInt("helperPersonnel#employerReputation", HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION))
    self.lastReputationChangeText = xmlFile:getString("helperPersonnel#lastReputationChange", "") or ""
    self.lastPayrollText = xmlFile:getString("helperPersonnel#lastPayroll", self.lastPayrollText or "noch keine Gehaltsabrechnung") or "noch keine Gehaltsabrechnung"
    self.lastPayrollAmount = xmlFile:getFloat("helperPersonnel#lastPayrollAmount", self.lastPayrollAmount or 0) or 0
    self.totalPayrollPaid = xmlFile:getFloat("helperPersonnel#totalPayrollPaid", self.totalPayrollPaid or 0) or 0
    self.dismissalPeriod = xmlFile:getInt("helperPersonnel#dismissalPeriod")
    self.dismissalYear = xmlFile:getInt("helperPersonnel#dismissalYear")
    self.monthlyDismissals = math.max(0, xmlFile:getInt("helperPersonnel#monthlyDismissals", 0))
    self.lastApplicantPeriod = xmlFile:getInt("helperPersonnel#lastApplicantPeriod")
    self.lastApplicantYear = xmlFile:getInt("helperPersonnel#lastApplicantYear")
    self.lastSicknessDailyCheckMinute = xmlFile:getInt("helperPersonnel#lastSicknessDailyCheckMinute")
    self.sicknessCurrentDay = xmlFile:getInt("helperPersonnel#sicknessCurrentDay")
    self.sicknessDayPeriod = xmlFile:getInt("helperPersonnel#sicknessDayPeriod")
    self.sicknessDayYear = xmlFile:getInt("helperPersonnel#sicknessDayYear")

    self.reputationHistory = {}
    local reputationHistoryIndex = 0
    while true do
        local key = string.format("helperPersonnel.reputationHistory.entry(%d)", reputationHistoryIndex)
        if not xmlFile:hasProperty(key) then
            break
        end

        table.insert(self.reputationHistory, {
            period = xmlFile:getInt(key .. "#period", 0) or 0,
            year = xmlFile:getInt(key .. "#year", 1) or 1,
            text = xmlFile:getString(key .. "#text", "") or "",
            sequence = xmlFile:getInt(key .. "#sequence", reputationHistoryIndex + 1) or (reputationHistoryIndex + 1)
        })

        reputationHistoryIndex = reputationHistoryIndex + 1
    end

    self.actionHistory = {}
    local actionHistoryIndex = 0
    while true do
        local key = string.format("helperPersonnel.actionHistory.entry(%d)", actionHistoryIndex)
        if not xmlFile:hasProperty(key) then
            break
        end

        table.insert(self.actionHistory, {
            period = xmlFile:getInt(key .. "#period", 0) or 0,
            year = xmlFile:getInt(key .. "#year", 1) or 1,
            text = xmlFile:getString(key .. "#text", "") or "",
            sequence = xmlFile:getInt(key .. "#sequence", actionHistoryIndex + 1) or (actionHistoryIndex + 1)
        })

        actionHistoryIndex = actionHistoryIndex + 1
    end

    local index = 0
    while true do
        local key = string.format("helperPersonnel.workers.worker(%d)", index)
        if not xmlFile:hasProperty(key) then
            break
        end

        local savedBusy = xmlFile:getBool(key .. "#busy", false)
        local savedVehicleName = xmlFile:getString(key .. "#vehicleName", "")
        local savedVehicleKey = xmlFile:getString(key .. "#vehicleKey")
        local savedElapsedMs = xmlFile:getFloat(key .. "#currentJobElapsedMs", 0)

        local worker = {
            id = xmlFile:getInt(key .. "#id", index + 1),
            firstName = xmlFile:getString(key .. "#firstName", "Mitarbeiter"),
            lastName = xmlFile:getString(key .. "#lastName", tostring(index + 1)),
            gender = xmlFile:getString(key .. "#gender", nil),
            experience = xmlFile:getInt(key .. "#experience", 50),
            reliability = xmlFile:getInt(key .. "#reliability", 50),
            loyalty = xmlFile:getInt(key .. "#loyalty", HelperPersonnelManager.DEFAULT_LOYALTY),
            avatarIndex = xmlFile:getInt(key .. "#avatarIndex", 0),
            assignedHelperIndex = xmlFile:getInt(key .. "#assignedHelperIndex"),
            assignedBaseHelperIndex = xmlFile:getInt(key .. "#assignedBaseHelperIndex"),
            hiredPeriod = xmlFile:getInt(key .. "#hiredPeriod"),
            hiredYear = xmlFile:getInt(key .. "#hiredYear"),
            loyaltyMilestoneMonths = xmlFile:getInt(key .. "#loyaltyMilestoneMonths", 0),
            loyaltyTenureMilestoneMonths = xmlFile:getInt(key .. "#loyaltyTenureMilestoneMonths", 0) or 0,
            nightWorkIngameMinutes = xmlFile:getInt(key .. "#nightWorkIngameMinutes", 0) or 0,
            nightWorkRealtimeMs = xmlFile:getFloat(key .. "#nightWorkRealtimeMs", 0) or 0,
            nightWorkLastMinute = xmlFile:getInt(key .. "#nightWorkLastMinute"),
            loyaltyReputationProgress = xmlFile:getFloat(key .. "#loyaltyReputationProgress", 0) or 0,
            loyaltyWarningPeriod = xmlFile:getInt(key .. "#loyaltyWarningPeriod", 0) or 0,
            loyaltyWarningYear = xmlFile:getInt(key .. "#loyaltyWarningYear", 0) or 0,
            resignationPending = xmlFile:getBool(key .. "#resignationPending", false) == true,
            dismissalPending = xmlFile:getBool(key .. "#dismissalPending", false) == true,
            dismissalNoticePeriod = xmlFile:getInt(key .. "#dismissalNoticePeriod", 0) or 0,
            dismissalNoticeYear = xmlFile:getInt(key .. "#dismissalNoticeYear", 0) or 0,
            dismissalEffectivePeriod = xmlFile:getInt(key .. "#dismissalEffectivePeriod", 0) or 0,
            dismissalEffectiveYear = xmlFile:getInt(key .. "#dismissalEffectiveYear", 0) or 0,
            resignationNoticePeriod = xmlFile:getInt(key .. "#resignationNoticePeriod", 0) or 0,
            resignationNoticeYear = xmlFile:getInt(key .. "#resignationNoticeYear", 0) or 0,
            resignationCheckPeriod = xmlFile:getInt(key .. "#resignationCheckPeriod", 0) or 0,
            resignationCheckYear = xmlFile:getInt(key .. "#resignationCheckYear", 0) or 0,
            sickPeriod = xmlFile:getInt(key .. "#sickPeriod", 0) or 0,
            sickYear = xmlFile:getInt(key .. "#sickYear", 0) or 0,
            sickDay = xmlFile:getInt(key .. "#sickDay", 0) or 0,
            sicknessPeriod = xmlFile:getInt(key .. "#sicknessPeriod", 0) or 0,
            sicknessYear = xmlFile:getInt(key .. "#sicknessYear", 0) or 0,
            sicknessDaysThisPeriod = xmlFile:getInt(key .. "#sicknessDaysThisPeriod", 0) or 0,
            reliabilityWorkPeriod = xmlFile:getInt(key .. "#reliabilityWorkPeriod", 0) or 0,
            reliabilityWorkYear = xmlFile:getInt(key .. "#reliabilityWorkYear", 0) or 0,
            reliabilityWorkMinutesThisPeriod = xmlFile:getInt(key .. "#reliabilityWorkMinutesThisPeriod", 0) or 0,
            reliabilityIncidentPeriod = xmlFile:getInt(key .. "#reliabilityIncidentPeriod", 0) or 0,
            reliabilityIncidentYear = xmlFile:getInt(key .. "#reliabilityIncidentYear", 0) or 0,
            reliabilityIncidentsThisPeriod = xmlFile:getInt(key .. "#reliabilityIncidentsThisPeriod", 0) or 0,
            reliabilitySicknessPeriod = xmlFile:getInt(key .. "#reliabilitySicknessPeriod", 0) or 0,
            reliabilitySicknessYear = xmlFile:getInt(key .. "#reliabilitySicknessYear", 0) or 0,
            reliabilitySicknessDaysThisPeriod = xmlFile:getInt(key .. "#reliabilitySicknessDaysThisPeriod", 0) or 0,
            reliabilityNightWorkPeriod = xmlFile:getInt(key .. "#reliabilityNightWorkPeriod", 0) or 0,
            reliabilityNightWorkYear = xmlFile:getInt(key .. "#reliabilityNightWorkYear", 0) or 0,
            reliabilityNightWorkMinutesThisPeriod = xmlFile:getInt(key .. "#reliabilityNightWorkMinutesThisPeriod", 0) or 0,
            reliabilityDevelopmentCheckPeriod = xmlFile:getInt(key .. "#reliabilityDevelopmentCheckPeriod", 0) or 0,
            reliabilityDevelopmentCheckYear = xmlFile:getInt(key .. "#reliabilityDevelopmentCheckYear", 0) or 0,
            experiencePeriod = xmlFile:getInt(key .. "#experiencePeriod", 0) or 0,
            experienceYear = xmlFile:getInt(key .. "#experienceYear", 1) or 1,
            experienceThisPeriod = xmlFile:getInt(key .. "#experienceThisPeriod", 0) or 0,
            experienceProgressMinutes = xmlFile:getInt(key .. "#experienceProgressMinutes", 0) or 0,
            specializationPrimary = xmlFile:getString(key .. "#specializationPrimary"),
            specializationSecondary = xmlFile:getString(key .. "#specializationSecondary"),
            specializationProgressKey = xmlFile:getString(key .. "#specializationProgressKey"),
            specializationProgressMinutes = xmlFile:getInt(key .. "#specializationProgressMinutes", 0) or 0,
            specializationProgresses = self:readSpecializationProgressesFromXML(xmlFile, key),
            trainingLastPeriod = xmlFile:getInt(key .. "#trainingLastPeriod", 0) or 0,
            trainingLastYear = xmlFile:getInt(key .. "#trainingLastYear", 0) or 0,
            trainingLastSpecialization = xmlFile:getString(key .. "#trainingLastSpecialization"),
            trainingActivePeriod = xmlFile:getInt(key .. "#trainingActivePeriod", 0) or 0,
            trainingActiveYear = xmlFile:getInt(key .. "#trainingActiveYear", 0) or 0,
            trainingActiveSpecialization = xmlFile:getString(key .. "#trainingActiveSpecialization"),
            wage = xmlFile:getFloat(key .. "#wage", 1000),
            baseWage = xmlFile:getFloat(key .. "#baseWage"),

            busy = false,
            vehicleName = "",
            vehicleKey = nil,
            restorePending = savedBusy,
            restoreVehicleName = savedVehicleName,
            restoreVehicleKey = savedVehicleKey,
            jobsCompleted = xmlFile:getInt(key .. "#jobsCompleted", 0),
            totalWorkMinutes = xmlFile:getInt(key .. "#totalWorkMinutes", 0),
            lastJobMinutes = xmlFile:getInt(key .. "#lastJobMinutes", 0),
            totalEarnings = xmlFile:getFloat(key .. "#totalEarnings", 0),
            currentJobStartedAt = 0,
            currentJobElapsedMs = savedBusy and savedElapsedMs or 0
        }

        self:normalizePersonRuntimeData(worker)

        table.insert(self.workers, worker)
        index = index + 1
    end

    index = 0
    while true do
        local key = string.format("helperPersonnel.applicants.applicant(%d)", index)
        if not xmlFile:hasProperty(key) then
            break
        end

        local applicant = {
            id = xmlFile:getInt(key .. "#id", 1000 + index + 1),
            firstName = xmlFile:getString(key .. "#firstName", "Bewerber"),
            lastName = xmlFile:getString(key .. "#lastName", tostring(index + 1)),
            gender = xmlFile:getString(key .. "#gender", nil),
            experience = xmlFile:getInt(key .. "#experience", 50),
            reliability = xmlFile:getInt(key .. "#reliability", 50),
            loyalty = xmlFile:getInt(key .. "#loyalty", HelperPersonnelManager.DEFAULT_LOYALTY),
            avatarIndex = xmlFile:getInt(key .. "#avatarIndex", 0),
            assignedHelperIndex = xmlFile:getInt(key .. "#assignedHelperIndex"),
            assignedBaseHelperIndex = xmlFile:getInt(key .. "#assignedBaseHelperIndex"),
            wage = xmlFile:getFloat(key .. "#wage", 1000),
            baseWage = xmlFile:getFloat(key .. "#baseWage"),
            monthsAvailable = xmlFile:getInt(key .. "#monthsAvailable", 0),
            specializationPrimary = xmlFile:getString(key .. "#specializationPrimary"),
            specializationSecondary = xmlFile:getString(key .. "#specializationSecondary"),
            busy = false,
            vehicleName = "",
            jobsCompleted = 0,
            totalWorkMinutes = 0,
            lastJobMinutes = 0,
            totalEarnings = 0,
            currentJobStartedAt = 0
        }

        self:normalizeApplicantRuntimeData(applicant)
        table.insert(self.applicants, applicant)
        index = index + 1
    end

    self:loadRestoredActiveJobsFromXML(xmlFile)
    self:loadRestoredActiveJobsFromVehiclesXML(savePath)

    xmlFile:delete()

    self:trimApplicantMarketToCap()
    self:ensureApplicantBuffer(1, 1)
    self:initializeApplicantPeriodIfMissing()
    self.changeCounter = (self.changeCounter or 0) + 1
end

function HelperPersonnelManager:getCurrentJobElapsedMs(worker)
    if worker == nil or worker.busy ~= true then
        return 0
    end

    local elapsedMs = math.max(0, worker.currentJobElapsedMs or 0)
    local startedAt = worker.currentJobStartedAt or 0

    if startedAt > 0 then
        elapsedMs = math.max(elapsedMs, self:getCurrentTimestampMs() - startedAt)
    end

    return elapsedMs
end

function HelperPersonnelManager:captureSaveSnapshot(activeJobs, getVehicleKeyFunc, helperBridge)
    self.saveBusyWorkerLookup = {}
    self.saveActiveJobSnapshot = {}

    local seenWorkerIds = {}

    local function addAssignment(worker, job, vehicleKey, vehicleName, helperIndex)
        if worker == nil or worker.id == nil then
            return
        end

        if vehicleKey == nil and getVehicleKeyFunc ~= nil then
            local vehicle = nil
            if helperBridge ~= nil and helperBridge.getVehicleFromJob ~= nil and job ~= nil then
                vehicle = helperBridge:getVehicleFromJob(job)
            end
            if vehicle ~= nil then
                vehicleKey = getVehicleKeyFunc(vehicle)
            end
        end

        if vehicleName == nil and helperBridge ~= nil and helperBridge.getVehicleNameFromJob ~= nil and job ~= nil then
            vehicleName = helperBridge:getVehicleNameFromJob(job)
        end

        if helperIndex == nil then
            helperIndex = worker.assignedHelperIndex
        end

        local baseHelperIndex = worker.assignedBaseHelperIndex
        if baseHelperIndex == nil and job ~= nil then
            baseHelperIndex = job.helperPersonnelBaseHelperIndex
        end

        local assignment = {
            workerId = worker.id,
            vehicleKey = vehicleKey or worker.vehicleKey,
            vehicleName = vehicleName or worker.vehicleName,
            helperIndex = helperIndex,
            baseHelperIndex = baseHelperIndex,
            timestamp = g_time or 0
        }

        self.saveBusyWorkerLookup[worker.id] = assignment

        if not seenWorkerIds[worker.id] then
            table.insert(self.saveActiveJobSnapshot, assignment)
            seenWorkerIds[worker.id] = true
        end
    end

    if activeJobs ~= nil and helperBridge ~= nil then
        for _, job in pairs(activeJobs) do
            local workerId = nil

            if job ~= nil then
                workerId = job.helperPersonnelWorkerId

                if workerId == nil and helperBridge.getWorkerIdByJob ~= nil then
                    workerId = helperBridge:getWorkerIdByJob(job)
                end

                if workerId == nil and job.helperIndex ~= nil and helperBridge.getWorkerIdByHelperIndex ~= nil then
                    workerId = helperBridge:getWorkerIdByHelperIndex(job.helperIndex)
                end
            end

            if workerId ~= nil then
                local worker = self:getWorkerById(workerId)
                if worker ~= nil then
                    local vehicleKey = nil
                    if helperBridge.getVehicleKeyFromJob ~= nil then
                        vehicleKey = helperBridge:getVehicleKeyFromJob(job)
                    end

                    local vehicleName = nil
                    if helperBridge.getVehicleNameFromJob ~= nil then
                        vehicleName = helperBridge:getVehicleNameFromJob(job)
                    end

                    addAssignment(worker, job, vehicleKey, vehicleName, job ~= nil and job.helperIndex or nil)
                end
            end
        end
    end

    for _, worker in ipairs(self.workers or {}) do
        local id = tonumber(worker.id)
        if id ~= nil then
            local isBusy = worker.busy == true or worker.isBusy == true or worker.isAssigned == true

            if not isBusy and self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.hasActiveJobForWorker ~= nil then
                isBusy = self.app.helperBridge:hasActiveJobForWorker(id) == true
            end

            if isBusy then
                addAssignment(worker, nil, worker.vehicleKey, worker.vehicleName, worker.assignedHelperIndex)
            end
        end
    end
end

function HelperPersonnelManager:saveToSavegame()
    self:saveConfig()
    local savePath = self.app:getSavegamePath()
    if savePath == nil or savePath == "" then
        return
    end

    if createFolder ~= nil then
        local directory = savePath:match("^(.+)/helperPersonnel%.xml$")
        if directory ~= nil and directory ~= "" then
            pcall(createFolder, directory)
        end
    end

    local xmlFile = XMLFile.create("helperPersonnel", savePath, "helperPersonnel", HelperPersonnelManager.xmlSchema)
    if xmlFile == nil then
        Logging.error("HelperPersonnel: Konnte Savegame-XML nicht erstellen: %s", savePath)
        return
    end

    xmlFile:setInt("helperPersonnel#nextId", self.nextPersonId)
    xmlFile:setString("helperPersonnel#lastAction", self.lastActionText or "")
    xmlFile:setInt("helperPersonnel#employerReputation", self:clampEmployerReputation(self.employerReputation))
    xmlFile:setString("helperPersonnel#lastReputationChange", self.lastReputationChangeText or "")
    xmlFile:setString("helperPersonnel#lastPayroll", self.lastPayrollText or "")
    xmlFile:setFloat("helperPersonnel#lastPayrollAmount", self.lastPayrollAmount or 0)
    xmlFile:setFloat("helperPersonnel#totalPayrollPaid", self.totalPayrollPaid or 0)
    if self.dismissalPeriod ~= nil then
        xmlFile:setInt("helperPersonnel#dismissalPeriod", self.dismissalPeriod)
    end
    if self.dismissalYear ~= nil then
        xmlFile:setInt("helperPersonnel#dismissalYear", self.dismissalYear)
    end
    xmlFile:setInt("helperPersonnel#monthlyDismissals", math.max(0, self.monthlyDismissals or 0))
    if self.lastApplicantPeriod ~= nil then
        xmlFile:setInt("helperPersonnel#lastApplicantPeriod", self.lastApplicantPeriod)
    end
    if self.lastApplicantYear ~= nil then
        xmlFile:setInt("helperPersonnel#lastApplicantYear", self.lastApplicantYear)
    end
    if self.lastSicknessDailyCheckMinute ~= nil then
        xmlFile:setInt("helperPersonnel#lastSicknessDailyCheckMinute", self.lastSicknessDailyCheckMinute)
    end
    if self.sicknessCurrentDay ~= nil then
        xmlFile:setInt("helperPersonnel#sicknessCurrentDay", self.sicknessCurrentDay)
    end
    if self.sicknessDayPeriod ~= nil then
        xmlFile:setInt("helperPersonnel#sicknessDayPeriod", self.sicknessDayPeriod)
    end
    if self.sicknessDayYear ~= nil then
        xmlFile:setInt("helperPersonnel#sicknessDayYear", self.sicknessDayYear)
    end

    for index, entry in ipairs(self.reputationHistory or {}) do
        if index <= (HelperPersonnelManager.MAX_HISTORY_ENTRIES or 3) then
            local key = string.format("helperPersonnel.reputationHistory.entry(%d)", index - 1)
            xmlFile:setInt(key .. "#period", entry.period or 0)
            xmlFile:setInt(key .. "#year", entry.year or 1)
            xmlFile:setString(key .. "#text", entry.text or "")
            xmlFile:setInt(key .. "#sequence", entry.sequence or index)
        end
    end

    for index, entry in ipairs(self.actionHistory or {}) do
        if index <= (HelperPersonnelManager.MAX_HISTORY_ENTRIES or 3) then
            local key = string.format("helperPersonnel.actionHistory.entry(%d)", index - 1)
            xmlFile:setInt(key .. "#period", entry.period or 0)
            xmlFile:setInt(key .. "#year", entry.year or 1)
            xmlFile:setString(key .. "#text", entry.text or "")
            xmlFile:setInt(key .. "#sequence", entry.sequence or index)
        end
    end

    for index, worker in ipairs(self.workers) do
        self:normalizePersonRuntimeData(worker)
        local key = string.format("helperPersonnel.workers.worker(%d)", index - 1)
        local workerId = tonumber(worker.id)
        local isActuallyBusy = worker.busy == true or worker.isBusy == true or worker.isAssigned == true

        local savedBusyAssignment = nil
        if self.saveBusyWorkerLookup ~= nil and workerId ~= nil then
            savedBusyAssignment = self.saveBusyWorkerLookup[workerId]
        end

        if not isActuallyBusy and savedBusyAssignment ~= nil then
            isActuallyBusy = true
        end

        if not isActuallyBusy and self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.hasActiveJobForWorker ~= nil then
            isActuallyBusy = self.app.helperBridge:hasActiveJobForWorker(worker.id) == true
        end

        xmlFile:setInt(key .. "#id", worker.id)
        xmlFile:setString(key .. "#firstName", worker.firstName)
        xmlFile:setString(key .. "#lastName", worker.lastName)
        xmlFile:setString(key .. "#gender", self:getGenderForPerson(worker))
        xmlFile:setInt(key .. "#experience", worker.experience)
        xmlFile:setInt(key .. "#reliability", worker.reliability)
        xmlFile:setInt(key .. "#loyalty", worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
        xmlFile:setInt(key .. "#avatarIndex", worker.avatarIndex or self:getDefaultAvatarIndexForId(worker.id))
        if worker.assignedHelperIndex ~= nil then
            xmlFile:setInt(key .. "#assignedHelperIndex", worker.assignedHelperIndex)
        end
        if worker.assignedBaseHelperIndex ~= nil then
            xmlFile:setInt(key .. "#assignedBaseHelperIndex", worker.assignedBaseHelperIndex)
        end
        if worker.hiredPeriod ~= nil then
            xmlFile:setInt(key .. "#hiredPeriod", worker.hiredPeriod)
        end
        if worker.hiredYear ~= nil then
            xmlFile:setInt(key .. "#hiredYear", worker.hiredYear)
        end
        xmlFile:setInt(key .. "#loyaltyMilestoneMonths", worker.loyaltyMilestoneMonths or 0)
        xmlFile:setInt(key .. "#loyaltyTenureMilestoneMonths", worker.loyaltyTenureMilestoneMonths or 0)
        xmlFile:setInt(key .. "#nightWorkIngameMinutes", worker.nightWorkIngameMinutes or 0)
        xmlFile:setFloat(key .. "#nightWorkRealtimeMs", worker.nightWorkRealtimeMs or 0)
        if worker.nightWorkLastMinute ~= nil then
            xmlFile:setInt(key .. "#nightWorkLastMinute", worker.nightWorkLastMinute)
        end
        xmlFile:setFloat(key .. "#loyaltyReputationProgress", worker.loyaltyReputationProgress or 0)
        xmlFile:setInt(key .. "#loyaltyWarningPeriod", worker.loyaltyWarningPeriod or 0)
        xmlFile:setInt(key .. "#loyaltyWarningYear", worker.loyaltyWarningYear or 0)
        xmlFile:setBool(key .. "#resignationPending", worker.resignationPending == true)
        xmlFile:setBool(key .. "#dismissalPending", worker.dismissalPending == true)
        xmlFile:setInt(key .. "#dismissalNoticePeriod", worker.dismissalNoticePeriod or 0)
        xmlFile:setInt(key .. "#dismissalNoticeYear", worker.dismissalNoticeYear or 0)
        xmlFile:setInt(key .. "#dismissalEffectivePeriod", worker.dismissalEffectivePeriod or 0)
        xmlFile:setInt(key .. "#dismissalEffectiveYear", worker.dismissalEffectiveYear or 0)
        xmlFile:setInt(key .. "#resignationNoticePeriod", worker.resignationNoticePeriod or 0)
        xmlFile:setInt(key .. "#resignationNoticeYear", worker.resignationNoticeYear or 0)
        xmlFile:setInt(key .. "#resignationCheckPeriod", worker.resignationCheckPeriod or 0)
        xmlFile:setInt(key .. "#resignationCheckYear", worker.resignationCheckYear or 0)
        xmlFile:setInt(key .. "#sickPeriod", worker.sickPeriod or 0)
        xmlFile:setInt(key .. "#sickYear", worker.sickYear or 0)
        xmlFile:setInt(key .. "#sickDay", worker.sickDay or 0)
        xmlFile:setInt(key .. "#sicknessPeriod", worker.sicknessPeriod or 0)
        xmlFile:setInt(key .. "#sicknessYear", worker.sicknessYear or 0)
        xmlFile:setInt(key .. "#sicknessDaysThisPeriod", worker.sicknessDaysThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityWorkPeriod", worker.reliabilityWorkPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityWorkYear", worker.reliabilityWorkYear or 0)
        xmlFile:setInt(key .. "#reliabilityWorkMinutesThisPeriod", worker.reliabilityWorkMinutesThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityIncidentPeriod", worker.reliabilityIncidentPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityIncidentYear", worker.reliabilityIncidentYear or 0)
        xmlFile:setInt(key .. "#reliabilityIncidentsThisPeriod", worker.reliabilityIncidentsThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilitySicknessPeriod", worker.reliabilitySicknessPeriod or 0)
        xmlFile:setInt(key .. "#reliabilitySicknessYear", worker.reliabilitySicknessYear or 0)
        xmlFile:setInt(key .. "#reliabilitySicknessDaysThisPeriod", worker.reliabilitySicknessDaysThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityNightWorkPeriod", worker.reliabilityNightWorkPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityNightWorkYear", worker.reliabilityNightWorkYear or 0)
        xmlFile:setInt(key .. "#reliabilityNightWorkMinutesThisPeriod", worker.reliabilityNightWorkMinutesThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityDevelopmentCheckPeriod", worker.reliabilityDevelopmentCheckPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityDevelopmentCheckYear", worker.reliabilityDevelopmentCheckYear or 0)
        xmlFile:setInt(key .. "#experiencePeriod", worker.experiencePeriod or 0)
        xmlFile:setInt(key .. "#experienceYear", worker.experienceYear or 1)
        xmlFile:setInt(key .. "#experienceThisPeriod", worker.experienceThisPeriod or 0)
        xmlFile:setInt(key .. "#experienceProgressMinutes", worker.experienceProgressMinutes or 0)
        if worker.specializationPrimary ~= nil then
            xmlFile:setString(key .. "#specializationPrimary", worker.specializationPrimary)
        end
        if worker.specializationSecondary ~= nil then
            xmlFile:setString(key .. "#specializationSecondary", worker.specializationSecondary)
        end
        self:writeSpecializationProgressesToXML(xmlFile, key, worker)
        if worker.specializationProgressKey ~= nil then
            xmlFile:setString(key .. "#specializationProgressKey", worker.specializationProgressKey)
        end
        xmlFile:setInt(key .. "#specializationProgressMinutes", worker.specializationProgressMinutes or 0)
        xmlFile:setInt(key .. "#trainingLastPeriod", worker.trainingLastPeriod or 0)
        xmlFile:setInt(key .. "#trainingLastYear", worker.trainingLastYear or 0)
        if worker.trainingLastSpecialization ~= nil then
            xmlFile:setString(key .. "#trainingLastSpecialization", worker.trainingLastSpecialization)
        end
        xmlFile:setInt(key .. "#trainingActivePeriod", worker.trainingActivePeriod or 0)
        xmlFile:setInt(key .. "#trainingActiveYear", worker.trainingActiveYear or 0)
        if worker.trainingActiveSpecialization ~= nil then
            xmlFile:setString(key .. "#trainingActiveSpecialization", worker.trainingActiveSpecialization)
        end
        xmlFile:setFloat(key .. "#baseWage", worker.baseWage or 0)
        xmlFile:setFloat(key .. "#wage", self:getCurrentMonthlyWage(worker))
        xmlFile:setBool(key .. "#busy", isActuallyBusy)
        local savedVehicleName = savedBusyAssignment ~= nil and savedBusyAssignment.vehicleName or nil
        local savedVehicleKey = savedBusyAssignment ~= nil and savedBusyAssignment.vehicleKey or nil
        xmlFile:setString(key .. "#vehicleName", isActuallyBusy and (savedVehicleName or worker.vehicleName or "") or "")
        if isActuallyBusy and (savedVehicleKey or worker.vehicleKey) ~= nil and (savedVehicleKey or worker.vehicleKey) ~= "" then
            xmlFile:setString(key .. "#vehicleKey", savedVehicleKey or worker.vehicleKey)
        end
        xmlFile:setInt(key .. "#jobsCompleted", worker.jobsCompleted or 0)
        xmlFile:setInt(key .. "#totalWorkMinutes", worker.totalWorkMinutes or 0)
        xmlFile:setInt(key .. "#lastJobMinutes", worker.lastJobMinutes or 0)
        xmlFile:setFloat(key .. "#totalEarnings", worker.totalEarnings or 0)
        xmlFile:setFloat(key .. "#currentJobStartedAt", isActuallyBusy and (worker.currentJobStartedAt or 0) or 0)
        xmlFile:setFloat(key .. "#currentJobElapsedMs", isActuallyBusy and self:getCurrentJobElapsedMs(worker) or 0)
    end

    for index, applicant in ipairs(self.applicants) do
        self:normalizeApplicantRuntimeData(applicant)
        local key = string.format("helperPersonnel.applicants.applicant(%d)", index - 1)
        xmlFile:setInt(key .. "#id", applicant.id)
        xmlFile:setString(key .. "#firstName", applicant.firstName)
        xmlFile:setString(key .. "#lastName", applicant.lastName)
        xmlFile:setString(key .. "#gender", self:getGenderForPerson(applicant))
        xmlFile:setInt(key .. "#experience", applicant.experience)
        xmlFile:setInt(key .. "#reliability", applicant.reliability)
        xmlFile:setInt(key .. "#loyalty", applicant.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
        xmlFile:setInt(key .. "#avatarIndex", applicant.avatarIndex or self:getDefaultAvatarIndexForId(applicant.id))
        xmlFile:setFloat(key .. "#baseWage", applicant.baseWage or 0)
        xmlFile:setFloat(key .. "#wage", self:getCurrentMonthlyWage(applicant))
        xmlFile:setInt(key .. "#monthsAvailable", applicant.monthsAvailable or 0)
        if applicant.specializationPrimary ~= nil then
            xmlFile:setString(key .. "#specializationPrimary", applicant.specializationPrimary)
        end
        if applicant.specializationSecondary ~= nil then
            xmlFile:setString(key .. "#specializationSecondary", applicant.specializationSecondary)
        end
    end

    self:writeActiveJobSnapshotToXML(xmlFile)

    xmlFile:save()
    xmlFile:delete()
    self.saveBusyWorkerLookup = nil
    self.saveActiveJobSnapshot = nil
end

function HelperPersonnelManager:resetRestoredActiveJobs()
    self.restoredActiveJobs = {}
    self.restoredActiveJobByVehicleKey = {}
    self.restoredActiveJobByVehicleName = {}
end

function HelperPersonnelManager:normalizeRestoreText(value)
    if value == nil then
        return nil
    end

    value = tostring(value)
    if value == "" then
        return nil
    end

    return string.lower(value)
end

function HelperPersonnelManager:rememberRestoredActiveJob(assignment)
    if assignment == nil or assignment.workerId == nil then
        return
    end

    if self.restoredActiveJobs == nil then
        self:resetRestoredActiveJobs()
    end

    table.insert(self.restoredActiveJobs, assignment)

    if assignment.vehicleKey ~= nil and assignment.vehicleKey ~= "" then
        self.restoredActiveJobByVehicleKey[tostring(assignment.vehicleKey)] = assignment
    end

    local normalizedName = self:normalizeRestoreText(assignment.vehicleName)
    if normalizedName ~= nil then
        self.restoredActiveJobByVehicleName[normalizedName] = assignment
    end

    local worker = self:getWorkerById(assignment.workerId)
    if worker ~= nil then
        worker.busy = false
        worker.restorePending = true
        worker.restoreVehicleKey = assignment.vehicleKey
        worker.restoreVehicleName = assignment.vehicleName
        worker.vehicleKey = assignment.vehicleKey or worker.vehicleKey
        worker.vehicleName = assignment.vehicleName or worker.vehicleName
        worker.assignedHelperIndex = assignment.helperIndex or worker.assignedHelperIndex
        worker.assignedBaseHelperIndex = assignment.baseHelperIndex or worker.assignedBaseHelperIndex
    end
end

function HelperPersonnelManager:loadRestoredActiveJobsFromXML(xmlFile)
    self:resetRestoredActiveJobs()

    local index = 0
    while true do
        local key = string.format("helperPersonnel.activeJobs.job(%d)", index)
        if not xmlFile:hasProperty(key) then
            break
        end

        self:rememberRestoredActiveJob({
            workerId = xmlFile:getInt(key .. "#workerId"),
            vehicleKey = xmlFile:getString(key .. "#vehicleKey"),
            vehicleName = xmlFile:getString(key .. "#vehicleName"),
            helperIndex = xmlFile:getInt(key .. "#helperIndex"),
            baseHelperIndex = xmlFile:getInt(key .. "#baseHelperIndex")
        })

        index = index + 1
    end

    if #self.restoredActiveJobs == 0 then
        for _, worker in ipairs(self.workers or {}) do
            if worker ~= nil and worker.restorePending == true then
                self:rememberRestoredActiveJob({
                    workerId = worker.id,
                    vehicleKey = worker.restoreVehicleKey or worker.vehicleKey,
                    vehicleName = worker.restoreVehicleName or worker.vehicleName,
                    helperIndex = worker.assignedHelperIndex,
                    baseHelperIndex = worker.assignedBaseHelperIndex
                })
            end
        end
    end
end

function HelperPersonnelManager:getSavegameDirectoryFromPath(savePath)
    if savePath == nil or savePath == "" then
        return nil
    end

    local directory = string.match(tostring(savePath), "^(.*[/\\])[^/\\]+$")
    if directory == nil or directory == "" then
        return nil
    end

    return directory
end

function HelperPersonnelManager:loadRestoredActiveJobsFromVehiclesXML(savePath)
    local directory = self:getSavegameDirectoryFromPath(savePath)
    if directory == nil then
        return
    end

    local vehiclesPath = directory .. "vehicles.xml"
    if not fileExists(vehiclesPath) then
        return
    end

    local xmlFile = XMLFile.loadIfExists("helperPersonnelVehicles", vehiclesPath)
    if xmlFile == nil then
        return
    end

    local loadedAssignments = 0
    local index = 0

    while true do
        local vehicleKey = string.format("vehicles.vehicle(%d)", index)
        if not xmlFile:hasProperty(vehicleKey) then
            break
        end

        local jobKey = vehicleKey .. ".aiJobVehicle.lastJob"
        local workerId = xmlFile:getInt(jobKey .. "#helperPersonnelWorkerId", -1)

        if workerId ~= nil and workerId > 0 then

            local isActiveFieldWorker = xmlFile:getBool(vehicleKey .. ".aiFieldWorker#isActive", false)

            if isActiveFieldWorker == true then
                local uniqueId = xmlFile:getString(vehicleKey .. "#uniqueId")
                local restoreVehicleKey = nil
                if uniqueId ~= nil and tostring(uniqueId) ~= "" then
                    restoreVehicleKey = "uid:" .. tostring(uniqueId)
                end

                local vehicleName = xmlFile:getString(vehicleKey .. "#filename", "")
                local baseHelperIndex = xmlFile:getInt(jobKey .. "#helperPersonnelBaseHelperIndex")

                self:rememberRestoredActiveJob({
                    workerId = workerId,
                    vehicleKey = restoreVehicleKey,
                    vehicleName = vehicleName,
                    baseHelperIndex = baseHelperIndex
                })

                loadedAssignments = loadedAssignments + 1
            end
        end

        index = index + 1
    end

    xmlFile:delete()

    if loadedAssignments > 0 then
        HelperPersonnel.debugInfo("FS25_HelperPersonnel: %d aktive Mitarbeiterzuordnung(en) aus vehicles.xml vorgemerkt", loadedAssignments)
    end
end

function HelperPersonnelManager:writeActiveJobSnapshotToXML(xmlFile)
    local activeJobs = self.saveActiveJobSnapshot or {}

    for index, assignment in ipairs(activeJobs) do
        if assignment ~= nil and assignment.workerId ~= nil then
            local key = string.format("helperPersonnel.activeJobs.job(%d)", index - 1)
            xmlFile:setInt(key .. "#workerId", assignment.workerId)
            if assignment.vehicleKey ~= nil and assignment.vehicleKey ~= "" then
                xmlFile:setString(key .. "#vehicleKey", tostring(assignment.vehicleKey))
            end
            if assignment.vehicleName ~= nil and assignment.vehicleName ~= "" then
                xmlFile:setString(key .. "#vehicleName", tostring(assignment.vehicleName))
            end
            if assignment.helperIndex ~= nil then
                xmlFile:setInt(key .. "#helperIndex", assignment.helperIndex)
            end
            if assignment.baseHelperIndex ~= nil then
                xmlFile:setInt(key .. "#baseHelperIndex", assignment.baseHelperIndex)
            end
        end
    end
end

function HelperPersonnelManager:findRestoredWorkerIdForVehicle(vehicleKey, vehicleName)
    if self.restoredActiveJobs == nil then
        return nil
    end

    if vehicleKey ~= nil and self.restoredActiveJobByVehicleKey ~= nil then
        local assignment = self.restoredActiveJobByVehicleKey[tostring(vehicleKey)]
        if assignment ~= nil and assignment.workerId ~= nil then
            return assignment.workerId
        end
    end

    local normalizedName = self:normalizeRestoreText(vehicleName)
    if normalizedName ~= nil and self.restoredActiveJobByVehicleName ~= nil then
        local assignment = self.restoredActiveJobByVehicleName[normalizedName]
        if assignment ~= nil and assignment.workerId ~= nil then
            return assignment.workerId
        end
    end

    local openAssignment = nil
    local openCount = 0
    for _, assignment in ipairs(self.restoredActiveJobs) do
        if assignment ~= nil and assignment.workerId ~= nil and assignment.consumed ~= true then
            openAssignment = assignment
            openCount = openCount + 1
        end
    end

    if openCount == 1 and openAssignment ~= nil then
        return openAssignment.workerId
    end

    return nil
end

function HelperPersonnelManager:consumeRestoredWorkerId(workerId, vehicleKey)
    if self.restoredActiveJobs == nil or workerId == nil then
        return
    end

    for _, assignment in ipairs(self.restoredActiveJobs) do
        if assignment ~= nil and assignment.workerId == workerId then
            if vehicleKey == nil or assignment.vehicleKey == nil or tostring(assignment.vehicleKey) == tostring(vehicleKey) then
                assignment.consumed = true
                return
            end
        end
    end
end

function HelperPersonnelManager:saveToSavegameSafe()
    local ok, err = pcall(function()
        self:saveToSavegame()
    end)

    if not ok then
        Logging.warning("HelperPersonnel: Speichern wurde uebersprungen: %s", tostring(err))
    end
end

function HelperPersonnelManager:touch(lastActionText)
    if lastActionText ~= nil then
        self.lastActionText = lastActionText
        self:addActionHistoryEntry(lastActionText)
    end

    self.changeCounter = self.changeCounter + 1

end

function HelperPersonnelManager:getLastActionText()
    if self.lastActionText ~= nil and self.lastActionText ~= "" then
        return self.lastActionText
    end

    return g_i18n:getText("ui_summary_lastActionNone")
end

function HelperPersonnelManager:getWorkersSorted()
    local items = {}
    for _, worker in ipairs(self.workers) do
        table.insert(items, worker)
    end

    table.sort(items, function(a, b)
        if a.lastName == b.lastName then
            return a.firstName < b.firstName
        end

        return a.lastName < b.lastName
    end)

    return items
end

function HelperPersonnelManager:getApplicantsSorted()
    local items = {}
    for _, applicant in ipairs(self.applicants) do
        table.insert(items, applicant)
    end

    table.sort(items, function(a, b)
        if a.experience == b.experience then
            if a.lastName == b.lastName then
                return a.firstName < b.firstName
            end

            return a.lastName < b.lastName
        end

        return a.experience > b.experience
    end)

    return items
end

function HelperPersonnelManager:getWorkerById(workerId)
    for _, worker in ipairs(self.workers) do
        if worker.id == workerId then
            return worker
        end
    end

    return nil
end

function HelperPersonnelManager:getWorkerByVehicleKey(vehicleKey)
    if vehicleKey == nil or vehicleKey == "" then
        return nil
    end

    for _, worker in ipairs(self.workers) do
        if worker.busy == true and worker.vehicleKey == vehicleKey then
            return worker
        end
        if worker.restorePending == true and worker.restoreVehicleKey == vehicleKey then
            return worker
        end
    end

    return nil
end

function HelperPersonnelManager:getPendingRestoredWorkerCount()
    local count = 0

    for _, worker in ipairs(self.workers) do
        if worker.restorePending == true then
            count = count + 1
        end
    end

    return count
end

function HelperPersonnelManager:getSinglePendingRestoredWorker()
    local result = nil
    local count = 0

    for _, worker in ipairs(self.workers) do
        if worker.restorePending == true then
            result = worker
            count = count + 1
        end
    end

    if count == 1 then
        return result
    end

    return nil
end

function HelperPersonnelManager:getPendingRestoredWorkerByVehicleName(vehicleName)
    if vehicleName == nil or vehicleName == "" then
        return nil
    end

    local result = nil
    local count = 0

    for _, worker in ipairs(self.workers) do
        if worker.restorePending == true and worker.restoreVehicleName == vehicleName then
            result = worker
            count = count + 1
        end
    end

    if count == 1 then
        return result
    end

    return nil
end

function HelperPersonnelManager:isWorkerBusy(workerId)
    local worker = self:getWorkerById(workerId)
    return worker ~= nil and worker.busy == true
end

function HelperPersonnelManager:isWorkerAvailable(workerId)
    local worker = self:getWorkerById(workerId)
    return worker ~= nil and worker.busy ~= true and not self:isWorkerSick(worker) and not self:isWorkerInTraining(worker)
end

function HelperPersonnelManager:getApplicantById(applicantId)
    for _, applicant in ipairs(self.applicants) do
        if applicant.id == applicantId then
            return applicant
        end
    end

    return nil
end

function HelperPersonnelManager:getAvailableWorkers()
    local items = {}
    for _, worker in ipairs(self.workers) do
        local isAvailable = worker.busy ~= true and not self:isWorkerSick(worker) and not self:isWorkerInTraining(worker)

        if isAvailable and self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.isWorkerSelectable ~= nil then
            isAvailable = self.app.helperBridge:isWorkerSelectable(worker.id)
        end

        if isAvailable then
            table.insert(items, worker)
        end
    end

    table.sort(items, function(a, b)
        if a.experience == b.experience then
            return self:getFullName(a) < self:getFullName(b)
        end

        return a.experience > b.experience
    end)

    return items
end

function HelperPersonnelManager:getWorkerCounts()
    local total = #self.workers
    local busy = 0
    local available = 0

    for _, worker in ipairs(self.workers) do
        if worker.busy then
            busy = busy + 1
        elseif not self:isWorkerSick(worker) and not self:isWorkerInTraining(worker) then
            available = available + 1
        end
    end

    return total, available, busy
end

function HelperPersonnelManager:hireApplicant(applicantId)
    local applicant = nil
    local removeIndex = nil

    for index, candidate in ipairs(self.applicants) do
        if candidate.id == applicantId then
            applicant = candidate
            removeIndex = index
            break
        end
    end

    if applicant == nil then
        return false
    end

    table.remove(self.applicants, removeIndex)
    applicant.busy = false
    applicant.vehicleName = ""
    applicant.currentJobStartedAt = 0
    applicant.monthsAvailable = nil

    local hiredPeriod, hiredYear = self:getApplicantPeriodInfo()
    if hiredPeriod ~= nil then
        applicant.hiredPeriod = hiredPeriod
        applicant.hiredYear = hiredYear or 1
    end

    applicant.loyaltyMilestoneMonths = 0
    applicant.loyaltyTenureMilestoneMonths = 0
    applicant.nightWorkIngameMinutes = 0
    applicant.nightWorkRealtimeMs = 0
    applicant.nightWorkLastMinute = self:getIngameDayMinute()
    applicant.loyaltyReputationProgress = 0
    applicant.loyaltyWarningPeriod = 0
    applicant.loyaltyWarningYear = 0
    applicant.dismissalPending = false
    applicant.dismissalNoticePeriod = 0
    applicant.dismissalNoticeYear = 0
    applicant.dismissalEffectivePeriod = 0
    applicant.dismissalEffectiveYear = 0
    applicant.sickPeriod = 0
    applicant.sickYear = 0
    applicant.sickDay = 0
    applicant.sicknessPeriod = 0
    applicant.sicknessYear = 0
    applicant.sicknessDaysThisPeriod = 0
    applicant.reliabilityWorkPeriod = 0
    applicant.reliabilityWorkYear = 0
    applicant.reliabilityWorkMinutesThisPeriod = 0
    applicant.reliabilityIncidentPeriod = 0
    applicant.reliabilityIncidentYear = 0
    applicant.reliabilityIncidentsThisPeriod = 0
    applicant.reliabilitySicknessPeriod = 0
    applicant.reliabilitySicknessYear = 0
    applicant.reliabilitySicknessDaysThisPeriod = 0
    applicant.reliabilityNightWorkPeriod = 0
    applicant.reliabilityNightWorkYear = 0
    applicant.reliabilityNightWorkMinutesThisPeriod = 0
    applicant.reliabilityDevelopmentCheckPeriod = 0
    applicant.reliabilityDevelopmentCheckYear = 0
    applicant.experiencePeriod = 0
    applicant.experienceYear = 0
    applicant.experienceThisPeriod = 0
    applicant.experienceProgressMinutes = 0
    self:normalizePersonRuntimeData(applicant)
    table.insert(self.workers, applicant)

    local fullName = self:getFullName(applicant)
    self:adjustEmployerReputation(1, string.format("%s eingestellt: +1 Ansehen", fullName))
    self:touch(string.format("%s wurde eingestellt.", fullName))
    self:rebuildHelperProfilesSafe()

    return true
end

function HelperPersonnelManager:addMonthsToPeriod(period, year, months)
    period = math.max(1, math.floor((tonumber(period) or 1) + 0.5))
    year = math.max(1, math.floor((tonumber(year) or 1) + 0.5))
    months = math.floor((tonumber(months) or 0) + 0.5)

    local absolute = ((year - 1) * 12) + (period - 1) + months
    local newYear = math.floor(absolute / 12) + 1
    local newPeriod = (absolute % 12) + 1

    return newPeriod, newYear
end

function HelperPersonnelManager:getDismissalNoticeDeadline(daysPerMonth)
    daysPerMonth = math.max(1, math.min(28, math.floor((tonumber(daysPerMonth) or self:getSalaryDaysPerMonth()) + 0.5)))

    if daysPerMonth <= 1 then
        return 1, HelperPersonnelManager.DISMISSAL_SINGLE_DAY_NOTICE_DEADLINE_MINUTE or 720
    end

    return math.ceil(daysPerMonth / 2), 1440
end

function HelperPersonnelManager:isDismissalNoticeInTimeForCurrentPeriod()
    local daysPerMonth = self:getSalaryDaysPerMonth()
    local deadlineDay, deadlineMinute = self:getDismissalNoticeDeadline(daysPerMonth)
    local currentDay = self:getEnvironmentDayInPeriod()
    local currentMinute = self:getIngameDayMinute()

    if currentDay == nil then

        return true, nil, currentMinute, deadlineDay, deadlineMinute
    end

    if currentDay < deadlineDay then
        return true, currentDay, currentMinute, deadlineDay, deadlineMinute
    end

    if currentDay > deadlineDay then
        return false, currentDay, currentMinute, deadlineDay, deadlineMinute
    end

    if deadlineMinute >= 1440 then
        return true, currentDay, currentMinute, deadlineDay, deadlineMinute
    end

    if currentMinute == nil then
        return true, currentDay, currentMinute, deadlineDay, deadlineMinute
    end

    return currentMinute <= deadlineMinute, currentDay, currentMinute, deadlineDay, deadlineMinute
end

function HelperPersonnelManager:getDismissalEffectivePeriodInfo(period, year)
    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil then
        return nil, nil, true, nil, nil, nil, nil
    end

    local inTime, currentDay, currentMinute, deadlineDay, deadlineMinute = self:isDismissalNoticeInTimeForCurrentPeriod()
    local monthsToAdd = inTime and 1 or 2
    local effectivePeriod, effectiveYear = self:addMonthsToPeriod(period, year, monthsToAdd)

    return effectivePeriod, effectiveYear, inTime, currentDay, currentMinute, deadlineDay, deadlineMinute
end

function HelperPersonnelManager:isPeriodAtOrAfter(period, year, targetPeriod, targetYear)
    period = tonumber(period)
    year = tonumber(year)
    targetPeriod = tonumber(targetPeriod)
    targetYear = tonumber(targetYear)

    if period == nil or year == nil or targetPeriod == nil or targetYear == nil or targetPeriod <= 0 or targetYear <= 0 then
        return true
    end

    local currentIndex = (math.floor(year) * 12) + math.floor(period)
    local targetIndex = (math.floor(targetYear) * 12) + math.floor(targetPeriod)
    return currentIndex >= targetIndex
end

function HelperPersonnelManager:formatDismissalNoticeDeadlineText(deadlineDay, deadlineMinute)
    deadlineDay = math.max(1, math.floor((tonumber(deadlineDay) or 1) + 0.5))
    deadlineMinute = tonumber(deadlineMinute) or 1440

    if deadlineMinute >= 1440 then
        return string.format("Tag %d, 24:00 Uhr", deadlineDay)
    end

    local hour = math.floor(deadlineMinute / 60)
    local minute = math.floor(deadlineMinute % 60)
    return string.format("Tag %d, %02d:%02d Uhr", deadlineDay, hour, minute)
end

function HelperPersonnelManager:applyDismissalNoticePenalties(worker)
    if type(worker) ~= "table" then
        return 0, 0, 0, 0
    end

    local oldLoyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    local oldReliability = self:clampPersonStat(worker.reliability or 0)
    local loyaltyPenalty = math.max(0, tonumber(HelperPersonnelManager.DISMISSAL_NOTICE_LOYALTY_PENALTY) or 0)
    local reliabilityPenalty = math.max(0, tonumber(HelperPersonnelManager.DISMISSAL_NOTICE_RELIABILITY_PENALTY) or 0)

    worker.loyalty = self:clampPersonStat(oldLoyalty - loyaltyPenalty)
    worker.reliability = self:clampPersonStat(oldReliability - reliabilityPenalty)

    return oldLoyalty, worker.loyalty, oldReliability, worker.reliability
end

function HelperPersonnelManager:dismissWorker(workerId)
    local worker = nil

    for _, candidate in ipairs(self.workers) do
        if candidate.id == workerId then
            worker = candidate
            break
        end
    end

    if worker == nil then
        return false, nil
    end

    if worker.dismissalPending == true then
        return false, self:getLocalizedText("ui_fireDeniedPending", "Der Mitarbeiter ist bereits zum Monatsende gekündigt.")
    end

    local period, year = self:getApplicantPeriodInfo()
    local fullName = self:getFullName(worker)
    local reputationDelta, dismissalReason = self:calculateDismissalReputationDelta(worker)
    local effectivePeriod, effectiveYear, inTime, currentDay, currentMinute, deadlineDay, deadlineMinute = self:getDismissalEffectivePeriodInfo(period, year)

    worker.dismissalPending = true
    worker.dismissalNoticePeriod = period or 0
    worker.dismissalNoticeYear = year or 0
    worker.dismissalEffectivePeriod = effectivePeriod or 0
    worker.dismissalEffectiveYear = effectiveYear or 0
    local oldLoyalty, newLoyalty, oldReliability, newReliability = self:applyDismissalNoticePenalties(worker)

    self:registerMonthlyDismissal()
    self:adjustEmployerReputation(reputationDelta, string.format("%s gekündigt (%s): %d Ansehen", fullName, dismissalReason, reputationDelta))

    local templateKey = inTime == true and "ui_dismissalNotice" or "ui_dismissalNoticeNextMonth"
    local fallbackText = inTime == true and "%s wurde zum Monatsende gekündigt." or "%s wurde zum nächsten Monatsende gekündigt."
    local template = self:getLocalizedText(templateKey, fallbackText)
    local text = string.format(template, fullName)
    local periodLabel = self:getPeriodLabel(effectivePeriod, effectiveYear)
    local deadlineText = self:formatDismissalNoticeDeadlineText(deadlineDay, deadlineMinute)
    local actionText = string.format("%s Wirksam: %s. Kündigungsfrist-Stichtag: %s. Loyalität %d -> %d, Zuverlässigkeit %d -> %d während der Kündigungsfrist.", text, periodLabel, deadlineText, oldLoyalty or 0, newLoyalty or 0, oldReliability or 0, newReliability or 0)
    self:showIngameNotification(text, self:getInfoNotificationType())
    self:touch(actionText)
    self:rebuildHelperProfilesSafe()

    return true, nil
end

function HelperPersonnelManager:rebuildHelperProfilesSafe()
    if self.app == nil or self.app.helperBridge == nil or self.app.helperBridge.rebuildHelperProfiles == nil then
        return
    end

    local ok, err = pcall(function()
        self.app.helperBridge:rebuildHelperProfiles()
    end)

    if not ok then
        Logging.warning("HelperPersonnel: Helferprofil-Abgleich wurde übersprungen: %s", tostring(err))
    end
end

function HelperPersonnelManager:startWorkerJob(workerId, vehicleName, vehicleKey)
    local worker = self:getWorkerById(workerId)
    if worker == nil then
        return false
    end

    self:normalizePersonRuntimeData(worker)

    if self:isWorkerSick(worker) or self:isWorkerInTraining(worker) then
        return false
    end

    local wasRestorePending = worker.restorePending == true
    local savedElapsedMs = math.max(0, worker.currentJobElapsedMs or 0)
    local now = self:getCurrentTimestampMs()

    worker.busy = true
    worker.vehicleName = vehicleName or ""
    worker.vehicleKey = vehicleKey
    worker.nightWorkLastMinute = self:getIngameDayMinute()

    if wasRestorePending and savedElapsedMs > 0 then
        worker.currentJobStartedAt = now - savedElapsedMs
        worker.currentJobElapsedMs = 0
    elseif worker.currentJobStartedAt == nil or worker.currentJobStartedAt <= 0 then
        worker.currentJobStartedAt = now
        worker.currentJobElapsedMs = 0
    end

    worker.restorePending = false
    worker.restoreVehicleName = nil
    worker.restoreVehicleKey = nil

    self:touch(nil)

    return true
end

function HelperPersonnelManager:finishWorkerJob(workerId)
    local worker = self:getWorkerById(workerId)
    if worker == nil then
        return false
    end

    self:normalizePersonRuntimeData(worker)

    local durationMs = self:getCurrentJobElapsedMs(worker)

    worker.busy = false
    worker.vehicleName = ""
    worker.vehicleKey = nil
    worker.currentJobStartedAt = 0
    worker.currentJobElapsedMs = 0

    if durationMs >= HelperPersonnelManager.MIN_RECORDED_JOB_DURATION_MS then
        local workMinutes = math.max(1, math.floor((durationMs / 60000) + 0.5))
        self:recordWorkerReliabilityWork(worker, workMinutes)
        local previousExperience = self:clampPersonStat(worker.experience or 0)
        local experienceGain, monthlyLimit = self:awardWorkerExperience(worker, workMinutes)
        local newExperience = self:clampPersonStat(worker.experience or previousExperience)
        local fullName = self:getFullName(worker)

        worker.jobsCompleted = (worker.jobsCompleted or 0) + 1
        worker.totalWorkMinutes = (worker.totalWorkMinutes or 0) + workMinutes
        worker.lastJobMinutes = workMinutes
        local learnedSpecializationKey = self:recordWorkerSpecializationPracticeFromCurrentJob(worker, workMinutes)
        if learnedSpecializationKey ~= nil then
            local specName = self:getSpecializationDisplayName(learnedSpecializationKey)
            self:touch(string.format("%s hat eine Spezialisierung entwickelt: %s.", fullName, specName))
        end
        self:clearWorkerSpecializationRuntimeContext(worker)

        if experienceGain > 0 then
            self:showExperienceGainNotification(worker, experienceGain, previousExperience, newExperience)
            self:touch(string.format("%s hat einen Einsatz beendet (+%d Erfahrung, Monatslimit %d).", fullName, experienceGain, monthlyLimit or 0))
        elseif monthlyLimit ~= nil and monthlyLimit > 0 and (worker.experienceThisPeriod or 0) >= monthlyLimit then
            self:showExperienceLimitNotification(worker, monthlyLimit)
            self:touch(string.format("%s hat einen Einsatz beendet (Erfahrungslimit des Monats erreicht).", fullName))
        else
            self:touch(string.format("%s hat einen Einsatz beendet.", fullName))
        end
    else
        self:clearWorkerSpecializationRuntimeContext(worker)
        self:touch(nil)
    end

    return true
end

function HelperPersonnelManager:setWorkerBusy(workerId, isBusy, vehicleName, vehicleKey)
    if isBusy == true then
        self:startWorkerJob(workerId, vehicleName, vehicleKey)
    else
        local worker = self:getWorkerById(workerId)
        if worker ~= nil then
            worker.busy = false
            worker.vehicleName = ""
            worker.vehicleKey = nil
            worker.currentJobStartedAt = 0
            worker.currentJobElapsedMs = 0
            self:touch(nil)
        end
    end
end

function HelperPersonnelManager:clampEmployerReputation(value)
    value = tonumber(value) or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION
    value = math.floor(value + 0.5)

    if value < HelperPersonnelManager.MIN_EMPLOYER_REPUTATION then
        return HelperPersonnelManager.MIN_EMPLOYER_REPUTATION
    end

    if value > HelperPersonnelManager.MAX_EMPLOYER_REPUTATION then
        return HelperPersonnelManager.MAX_EMPLOYER_REPUTATION
    end

    return value
end

function HelperPersonnelManager:formatSignedDelta(delta)
    delta = math.floor((tonumber(delta) or 0) + 0.5)

    if delta > 0 then
        return string.format("+%d", delta)
    end

    return tostring(delta)
end

function HelperPersonnelManager:getCurrentPeriodLabel()
    local period, year = self:getApplicantPeriodInfo()
    return self:getPeriodLabel(period, year)
end

function HelperPersonnelManager:getPeriodLabel(period, year)
    period = math.floor((tonumber(period) or 0) + 0.5)
    year = math.floor((tonumber(year) or 1) + 0.5)

    if period >= 1 and period <= 12 then
        return string.format("%s Jahr %d", self:getMonthName(period), year)
    end

    return string.format("Jahr %d", year)
end

function HelperPersonnelManager:normalizeHistoryText(text)
    if text == nil then
        return ""
    end

    text = tostring(text)

    local hiredName = text:match("^(.+) has been hired%.$")
    if hiredName ~= nil then
        return string.format("%s wurde eingestellt.", hiredName)
    end

    local dismissedName = text:match("^(.+) has been dismissed%.$")
    if dismissedName ~= nil then
        return string.format("%s wurde entlassen.", dismissedName)
    end

    return text
end

function HelperPersonnelManager:getHighestHistorySequence()
    local highest = tonumber(self.historySequence) or 0

    for _, history in ipairs({ self.reputationHistory or {}, self.actionHistory or {} }) do
        for _, entry in ipairs(history or {}) do
            highest = math.max(highest, tonumber(entry.sequence) or 0)
        end
    end

    return highest
end

function HelperPersonnelManager:addHistoryEntry(history, text, period, year)
    if type(history) ~= "table" or type(text) ~= "string" or text == "" then
        return
    end

    text = self:normalizeHistoryText(text)
    if text == "" then
        return
    end

    if period == nil or period <= 0 then
        period, year = self:getApplicantPeriodInfo()
    end

    self.historySequence = math.max(tonumber(self.historySequence) or 0, self:getHighestHistorySequence()) + 1

    local entry = {
        period = math.max(0, math.floor((tonumber(period) or 0) + 0.5)),
        year = math.max(1, math.floor((tonumber(year) or 1) + 0.5)),
        text = text,
        sequence = self.historySequence
    }

    table.insert(history, 1, entry)

    while #history > (HelperPersonnelManager.MAX_HISTORY_ENTRIES or 36) do
        table.remove(history)
    end
end

function HelperPersonnelManager:addReputationHistoryEntry(text, period, year)
    self.reputationHistory = self.reputationHistory or {}
    self:addHistoryEntry(self.reputationHistory, text, period, year)
end

function HelperPersonnelManager:addActionHistoryEntry(text, period, year)
    self.actionHistory = self.actionHistory or {}
    self:addHistoryEntry(self.actionHistory, text, period, year)
end

function HelperPersonnelManager:getFormattedHistoryLines(history, emptyText)
    local lines = {}

    if type(history) == "table" then
        for i = 1, math.min(#history, HelperPersonnelManager.MAX_HISTORY_ENTRIES or 3) do
            local entry = history[i]
            if type(entry) == "table" and type(entry.text) == "string" and entry.text ~= "" then
                table.insert(lines, string.format("%s: %s", self:getPeriodLabel(entry.period, entry.year), self:normalizeHistoryText(entry.text)))
            end
        end
    end

    if #lines == 0 then
        table.insert(lines, emptyText or g_i18n:getText("ui_summary_lastActionNone"))
    end

    return lines
end

function HelperPersonnelManager:getReputationHistoryLines()
    return self:getFormattedHistoryLines(self.reputationHistory, g_i18n:getText("ui_noReputationChange"))
end

function HelperPersonnelManager:getActionHistoryLines()
    return self:getFormattedHistoryLines(self.actionHistory, g_i18n:getText("ui_summary_lastActionNone"))
end
function HelperPersonnelManager:collectHistoryEntriesForPeriod(period, year)
    period, year = self:getApplicantPeriodInfo(period, year)
    local entries = {}

    local function appendFrom(history, source)
        for index, entry in ipairs(history or {}) do
            if type(entry) == "table" then
                local entryPeriod = math.max(0, math.floor((tonumber(entry.period) or 0) + 0.5))
                local entryYear = math.max(1, math.floor((tonumber(entry.year) or 1) + 0.5))
                local text = self:normalizeHistoryText(entry.text or "")
                if text ~= "" and entryPeriod == period and entryYear == year then
                    table.insert(entries, {
                        period = entryPeriod,
                        year = entryYear,
                        text = text,
                        sequence = tonumber(entry.sequence) or 0,
                        index = index,
                        source = source
                    })
                end
            end
        end
    end

    appendFrom(self.reputationHistory, "reputation")
    appendFrom(self.actionHistory, "action")

    table.sort(entries, function(a, b)
        local seqA = tonumber(a.sequence) or 0
        local seqB = tonumber(b.sequence) or 0
        if seqA ~= seqB then
            return seqA > seqB
        end
        return (tonumber(a.index) or 0) < (tonumber(b.index) or 0)
    end)

    return entries, period, year
end

function HelperPersonnelManager:getMonthlyHistoryEntryInfo(entry)
    if type(entry) ~= "table" then
        return nil
    end

    local text = tostring(entry.text or "")
    if text == "" then
        return nil
    end

    local name = text:match("^(.+) wurde eingestellt%.$")
    if name ~= nil then
        return { kind = "hire", role = "action", name = name }
    end

    name = text:match("^(.+) eingestellt: [%+%-]?%d+ Ansehen")
    if name ~= nil then
        return { kind = "hire", role = "effect", name = name, effectText = text }
    end

    name = text:match("^Gehaltserhöhung für (.-) gewährt:")
    if name == nil then
        name = text:match("^Gehaltserhoehung fuer (.-) gewaehrt:")
    end
    if name == nil then
        name = text:match("^Gehaltserhoehung für (.-) gewährt:")
    end
    if name ~= nil then
        return { kind = "salaryRaiseGranted", role = "action", name = name }
    end

    local reputationDelta = text:match("^Faire Gehaltserhöhung: ([%+%-]?%d+) Ansehen")
    if reputationDelta == nil then
        reputationDelta = text:match("^Faire Gehaltserhoehung: ([%+%-]?%d+) Ansehen")
    end
    if reputationDelta ~= nil then
        return { kind = "salaryRaiseGranted", role = "effect", effectText = text, reputationDelta = reputationDelta }
    end

    name = text:match("^(.+) wurde zum Monatsende gekündigt%.")
    if name == nil then
        name = text:match("^(.+) wurde zum Monatsende gekuendigt%.")
    end
    if name == nil then
        name = text:match("^(.+) wurde zum nächsten Monatsende gekündigt%.")
    end
    if name == nil then
        name = text:match("^(.+) wurde zum naechsten Monatsende gekuendigt%.")
    end
    if name ~= nil then
        return { kind = "dismissalNotice", role = "action", name = name }
    end

    local dismissedName, dismissalReason, dismissalDelta = text:match("^(.+) gekündigt %((.-)%): ([%+%-]?%d+) Ansehen")
    if dismissedName == nil then
        dismissedName, dismissalReason, dismissalDelta = text:match("^(.+) gekuendigt %((.-)%): ([%+%-]?%d+) Ansehen")
    end
    if dismissedName ~= nil then
        return { kind = "dismissalNotice", role = "effect", name = dismissedName, reason = dismissalReason, reputationDelta = dismissalDelta, effectText = text }
    end

    name = text:match("^(.+) hat den Hof .+ verlassen%.$")
    if name ~= nil then
        return { kind = "resignation", role = "action", name = name }
    end

    local resignationName, resignationDelta = text:match("^Eigenkündigung von (.+): ([%+%-]?%d+) Ansehen")
    if resignationName == nil then
        resignationName, resignationDelta = text:match("^Eigenkuendigung von (.+): ([%+%-]?%d+) Ansehen")
    end
    if resignationName ~= nil then
        return { kind = "resignation", role = "effect", name = resignationName, reputationDelta = resignationDelta, effectText = text }
    end

    return nil
end

function HelperPersonnelManager:getMonthlyHistoryEffectText(info)
    if type(info) ~= "table" then
        return nil
    end

    if info.kind == "hire" then
        local delta = tostring(info.effectText or ""):match(": ([%+%-]?%d+) Ansehen")
        if delta ~= nil then
            return string.format("Auswirkung: %s Ansehen.", delta)
        end
    elseif info.kind == "salaryRaiseGranted" then
        local delta = info.reputationDelta or tostring(info.effectText or ""):match(": ([%+%-]?%d+) Ansehen")
        if delta ~= nil then
            return string.format("Auswirkung: %s Ansehen.", delta)
        end
    elseif info.kind == "dismissalNotice" then
        local delta = info.reputationDelta or tostring(info.effectText or ""):match(": ([%+%-]?%d+) Ansehen")
        if delta ~= nil and info.reason ~= nil and info.reason ~= "" then
            return string.format("Auswirkung: %s Ansehen (%s).", delta, info.reason)
        elseif delta ~= nil then
            return string.format("Auswirkung: %s Ansehen.", delta)
        end
    elseif info.kind == "resignation" then
        local delta = info.reputationDelta or tostring(info.effectText or ""):match(": ([%+%-]?%d+) Ansehen")
        if delta ~= nil then
            return string.format("Auswirkung: %s Ansehen.", delta)
        end
    end

    return nil
end

function HelperPersonnelManager:findMatchingMonthlyHistoryEffect(entries, usedEntries, actionIndex, actionInfo)
    if type(entries) ~= "table" or type(actionInfo) ~= "table" then
        return nil, nil
    end

    local actionEntry = entries[actionIndex]
    local actionSequence = actionEntry ~= nil and tonumber(actionEntry.sequence) or nil
    local bestIndex = nil
    local bestInfo = nil
    local bestDistance = nil

    for index, entry in ipairs(entries) do
        if index ~= actionIndex and usedEntries[index] ~= true then
            local info = self:getMonthlyHistoryEntryInfo(entry)
            if info ~= nil and info.role == "effect" and info.kind == actionInfo.kind then
                local nameMatches = actionInfo.kind == "salaryRaiseGranted" or (info.name ~= nil and actionInfo.name ~= nil and info.name == actionInfo.name)
                if nameMatches then
                    local distance = 999999
                    if actionSequence ~= nil then
                        distance = math.abs((tonumber(entry.sequence) or 0) - actionSequence)
                    else
                        distance = math.abs(index - actionIndex)
                    end

                    if distance <= 6 and (bestDistance == nil or distance < bestDistance) then
                        bestIndex = index
                        bestInfo = info
                        bestDistance = distance
                    end
                end
            end
        end
    end

    return bestIndex, bestInfo
end

function HelperPersonnelManager:buildMonthlyHistoryLines(entries)
    local lines = {}
    local usedEntries = {}

    for index, entry in ipairs(entries or {}) do
        if usedEntries[index] ~= true then
            local text = tostring(entry.text or "")
            local info = self:getMonthlyHistoryEntryInfo(entry)

            if info ~= nil and info.role == "action" then
                local effectIndex, effectInfo = self:findMatchingMonthlyHistoryEffect(entries, usedEntries, index, info)
                local effectText = self:getMonthlyHistoryEffectText(effectInfo)

                if effectIndex ~= nil and effectText ~= nil and effectText ~= "" then
                    usedEntries[effectIndex] = true
                    text = string.format("%s %s", text, effectText)
                end
            end

            if text ~= "" then
                table.insert(lines, text)
            end

            usedEntries[index] = true
        end
    end

    return lines
end

function HelperPersonnelManager:getMonthlyHistoryLines(period, year)
    local entries
    entries, period, year = self:collectHistoryEntriesForPeriod(period, year)
    local lines = self:buildMonthlyHistoryLines(entries)

    if #lines == 0 then
        table.insert(lines, "Noch keine Änderungen in diesem Monat.")
    end

    return lines, period, year
end

function HelperPersonnelManager:adjustEmployerReputation(delta, reasonText)
    delta = math.floor((tonumber(delta) or 0) + 0.5)
    if delta == 0 then
        return self:getEmployerReputation()
    end

    local oldValue = self:clampEmployerReputation(self.employerReputation)
    local newValue = self:clampEmployerReputation(oldValue + delta)
    self.employerReputation = newValue

    if reasonText ~= nil and reasonText ~= "" then
        self.lastReputationChangeText = reasonText
    else
        self.lastReputationChangeText = string.format("Arbeitgeberansehen %s", self:formatSignedDelta(newValue - oldValue))
    end

    if newValue - oldValue ~= 0 then
        self:addReputationHistoryEntry(self.lastReputationChangeText)
    end

    return newValue
end

function HelperPersonnelManager:getLastReputationChangeText()
    if self.lastReputationChangeText == nil or self.lastReputationChangeText == "" then
        return "noch keine"
    end

    return self.lastReputationChangeText
end

function HelperPersonnelManager:getEmployerReputation()
    self.employerReputation = self:clampEmployerReputation(self.employerReputation)
    return self.employerReputation
end

function HelperPersonnelManager:getEmployerReputationLevelKey()
    local reputation = self:getEmployerReputation()

    if reputation >= 80 then
        return "ui_reputationVeryGood"
    elseif reputation >= 60 then
        return "ui_reputationGood"
    elseif reputation >= 40 then
        return "ui_reputationSolid"
    elseif reputation >= 20 then
        return "ui_reputationWeak"
    end

    return "ui_reputationCritical"
end

function HelperPersonnelManager:getCurrentEmploymentMonths(worker, period, year)
    if type(worker) ~= "table" then
        return nil
    end

    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil or year == nil or worker.hiredPeriod == nil or worker.hiredYear == nil then
        return nil
    end

    local hiredPeriod = math.floor((tonumber(worker.hiredPeriod) or 0) + 0.5)
    local hiredYear = math.floor((tonumber(worker.hiredYear) or 0) + 0.5)

    if hiredPeriod < 1 or hiredPeriod > 12 or hiredYear < 1 then
        return nil
    end

    local months = ((year - hiredYear) * 12) + (period - hiredPeriod)
    return math.max(0, months)
end

function HelperPersonnelManager:getDismissalReasonAndBaseDelta(worker)
    local months = self:getCurrentEmploymentMonths(worker)
    local deltas = HelperPersonnelManager.DISMISSAL_REPUTATION_DELTAS

    if months == nil then
        return "Beschäftigungsdauer unbekannt", deltas.unknown
    elseif months < 1 then
        return "weniger als 1 Monat beschäftigt", deltas.under1Month
    elseif months < 3 then
        return "weniger als 3 Monate beschäftigt", deltas.under3Months
    elseif months < 6 then
        return "weniger als 6 Monate beschäftigt", deltas.under6Months
    elseif months < 12 then
        return "weniger als 12 Monate beschäftigt", deltas.under12Months
    elseif months < 24 then
        return "weniger als 24 Monate beschäftigt", deltas.under24Months
    end

    return "mindestens 24 Monate beschäftigt", deltas.longTerm
end

function HelperPersonnelManager:resetMonthlyDismissalCounterIfNeeded(period, year)
    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil then
        return
    end

    if self.dismissalPeriod ~= period or self.dismissalYear ~= year then
        self.dismissalPeriod = period
        self.dismissalYear = year
        self.monthlyDismissals = 0
    end
end

function HelperPersonnelManager:calculateDismissalReputationDelta(worker)
    self:resetMonthlyDismissalCounterIfNeeded()

    local reason, baseDelta = self:getDismissalReasonAndBaseDelta(worker)
    local previousDismissals = math.max(0, self.monthlyDismissals or 0)
    local additionalDelta = previousDismissals * (HelperPersonnelManager.ADDITIONAL_MONTHLY_DISMISSAL_DELTA or 0)
    local totalDelta = (baseDelta or 0) + additionalDelta

    if previousDismissals > 0 then
        reason = string.format("%s, %d. Entlassung in diesem Monat", reason, previousDismissals + 1)
    end

    return totalDelta, reason
end

function HelperPersonnelManager:registerMonthlyDismissal()
    self:resetMonthlyDismissalCounterIfNeeded()
    self.monthlyDismissals = math.max(0, self.monthlyDismissals or 0) + 1
end

function HelperPersonnelManager:getCurrentFarmId()
    local mission = g_currentMission
    if mission == nil then
        return 1
    end

    if mission.getFarmId ~= nil then
        local ok, farmId = pcall(function()
            return mission:getFarmId()
        end)
        if ok and tonumber(farmId) ~= nil then
            return tonumber(farmId)
        end
    end

    if mission.player ~= nil and tonumber(mission.player.farmId) ~= nil then
        return tonumber(mission.player.farmId)
    end

    if mission.missionInfo ~= nil and tonumber(mission.missionInfo.farmId) ~= nil then
        return tonumber(mission.missionInfo.farmId)
    end

    if FarmManager ~= nil and FarmManager.SINGLEPLAYER_FARM_ID ~= nil then
        return FarmManager.SINGLEPLAYER_FARM_ID
    end

    return 1
end

function HelperPersonnelManager:getCurrentFarm()
    local farmId = self:getCurrentFarmId()

    if g_farmManager ~= nil and g_farmManager.getFarmById ~= nil then
        local ok, farm = pcall(function()
            return g_farmManager:getFarmById(farmId)
        end)
        if ok and farm ~= nil then
            return farm, farmId
        end
    end

    local mission = g_currentMission
    if mission ~= nil and mission.getFarm ~= nil then
        local ok, farm = pcall(function()
            return mission:getFarm(farmId)
        end)
        if ok and farm ~= nil then
            return farm, farmId
        end
    end

    return nil, farmId
end

function HelperPersonnelManager:getCurrentFarmMoney()
    local farm, farmId = self:getCurrentFarm()
    if farm ~= nil and tonumber(farm.money) ~= nil then
        return tonumber(farm.money), farmId
    end

    local mission = g_currentMission
    if mission ~= nil and mission.getMoney ~= nil then
        local ok, money = pcall(function()
            return mission:getMoney(farmId)
        end)
        if ok and tonumber(money) ~= nil then
            return tonumber(money), farmId
        end
    end

    return nil, farmId
end

function HelperPersonnelManager:getPayrollMoneyType()
    if MoneyType ~= nil then

        if MoneyType.AI ~= nil then
            return MoneyType.AI
        end

        local wageMoneyTypes = {
            MoneyType.HIRED_WORKER,
            MoneyType.HIRED_HELPER,
            MoneyType.HELPER_WAGES,
            MoneyType.WAGE_PAYMENT,
            MoneyType.WAGE_PAYMENTS,
            MoneyType.WORKER_WAGES
        }

        for _, moneyType in ipairs(wageMoneyTypes) do
            if moneyType ~= nil then
                return moneyType
            end
        end
    end

    return nil
end

function HelperPersonnelManager:addFarmMoney(amount, farmId)
    amount = tonumber(amount) or 0
    if amount == 0 then
        return true
    end

    local mission = g_currentMission
    if mission == nil or mission.addMoney == nil then
        return false
    end

    farmId = farmId or self:getCurrentFarmId()
    local moneyType = self:getPayrollMoneyType()

    local attempts = {
        function()
            return mission:addMoney(amount, farmId, moneyType, true, true)
        end,
        function()
            return mission:addMoney(amount, farmId, moneyType, true)
        end,
        function()
            return mission:addMoney(amount, farmId, moneyType)
        end,
        function()
            return mission:addMoney(amount, farmId)
        end
    }

    for _, attempt in ipairs(attempts) do
        local ok = pcall(attempt)
        if ok then
            return true
        end
    end

    return false
end

function HelperPersonnelManager:getMonthlyPayrollAmount()
    local amount = 0

    for _, worker in ipairs(self.workers or {}) do
        self:normalizePersonRuntimeData(worker)
        amount = amount + math.max(0, tonumber(self:getCurrentMonthlyWage(worker)) or 0)
    end

    return math.floor(amount + 0.5)
end

function HelperPersonnelManager:formatMoneyForText(amount)
    amount = tonumber(amount) or 0

    if g_i18n ~= nil and g_i18n.formatMoney ~= nil then
        local ok, text = pcall(function()
            return g_i18n:formatMoney(amount, 0, true, false)
        end)
        if ok and text ~= nil and text ~= "" then
            return text
        end
    end

    return string.format("%d €", math.floor(amount + 0.5))
end

function HelperPersonnelManager:getLastPayrollText()
    if self.lastPayrollText == nil or self.lastPayrollText == "" then
        return "noch keine Gehaltsabrechnung"
    end

    return self.lastPayrollText
end

function HelperPersonnelManager:processMonthlyPayroll()
    local amount = self:getMonthlyPayrollAmount()
    self.lastPayrollAmount = amount

    if amount <= 0 then
        self.lastPayrollText = "Keine Gehaltszahlung fällig."
        return 0, 0
    end

    local moneyBefore, farmId = self:getCurrentFarmMoney()
    local booked = self:addFarmMoney(-amount, farmId)
    local amountText = self:formatMoneyForText(amount)
    local delta = 0

    if not booked then
        self.lastPayrollText = string.format("Gehaltsabrechnung konnte nicht gebucht werden: %s.", amountText)
        if Logging ~= nil and Logging.warning ~= nil then
            Logging.warning("HelperPersonnel: Monatsgehaelter konnten nicht gebucht werden (%s).", amountText)
        end
        return amount, 0
    end

    self.totalPayrollPaid = (self.totalPayrollPaid or 0) + amount

    if moneyBefore ~= nil and moneyBefore < 0 then
        delta = HelperPersonnelManager.PAYROLL_REPUTATION_ALREADY_NEGATIVE
        self.lastPayrollText = string.format("Monatsgehälter gebucht: %s. Hof war bereits im Minus.", amountText)
        self:adjustEmployerReputation(delta, string.format("Gehaltszahlung bei negativem Kontostand: %d Ansehen", delta))
    elseif moneyBefore ~= nil and (moneyBefore - amount) < 0 then
        delta = HelperPersonnelManager.PAYROLL_REPUTATION_LOW_BALANCE
        self.lastPayrollText = string.format("Monatsgehälter gebucht: %s. Hof rutscht dadurch ins Minus.", amountText)
        self:adjustEmployerReputation(delta, string.format("Gehaltszahlung führt zu negativem Kontostand: %d Ansehen", delta))
    else
        delta = HelperPersonnelManager.PAYROLL_REPUTATION_PAID
        self.lastPayrollText = string.format("Monatsgehälter pünktlich gezahlt: %s.", amountText)
        self:adjustEmployerReputation(delta, string.format("Pünktliche Gehaltszahlung: +%d Ansehen", delta))
    end

    return amount, delta
end

function HelperPersonnelManager:processWorkerLoyaltyMilestones(period, year)
    local totalDelta = 0
    local affectedWorkers = 0
    local highestMilestone = 0

    for _, worker in ipairs(self.workers) do
        self:normalizePersonRuntimeData(worker)

        local employmentMonths = self:getCurrentEmploymentMonths(worker, period, year)
        if employmentMonths ~= nil then
            local awardedMilestone = math.max(0, worker.loyaltyMilestoneMonths or 0)
            local workerDelta = 0
            local workerHighestMilestone = awardedMilestone

            for _, milestone in ipairs(HelperPersonnelManager.LOYALTY_REPUTATION_MILESTONES) do
                if employmentMonths >= milestone.months and awardedMilestone < milestone.months then
                    workerDelta = workerDelta + (milestone.delta or 0)
                    workerHighestMilestone = math.max(workerHighestMilestone, milestone.months)
                end
            end

            if workerDelta > 0 then
                worker.loyaltyMilestoneMonths = workerHighestMilestone
                totalDelta = totalDelta + workerDelta
                affectedWorkers = affectedWorkers + 1
                highestMilestone = math.max(highestMilestone, workerHighestMilestone)
            end
        end
    end

    if totalDelta > 0 then
        local reasonText
        if affectedWorkers == 1 then
            reasonText = string.format("Betriebstreue: 1 Mitarbeiter seit mindestens %d Monaten beschäftigt: +%d Ansehen", highestMilestone, totalDelta)
        else
            reasonText = string.format("Betriebstreue: %d Mitarbeiter erreichen Loyalitätsmeilensteine: +%d Ansehen", affectedWorkers, totalDelta)
        end

        self:adjustEmployerReputation(totalDelta, reasonText)
    end

    return totalDelta, affectedWorkers
end

function HelperPersonnelManager:trimApplicantMarketToCap()
    local maxApplicants = HelperPersonnelManager.MAX_APPLICANTS or 6

    while #self.applicants > maxApplicants do
        table.remove(self.applicants)
    end
end

function HelperPersonnelManager:ageApplicantMarketForNewPeriod()
    local maxMonths = HelperPersonnelManager.MAX_APPLICANT_AVAILABLE_MONTHS or 2
    local expired = 0

    for index = #self.applicants, 1, -1 do
        local applicant = self.applicants[index]
        self:normalizeApplicantRuntimeData(applicant)
        applicant.monthsAvailable = (applicant.monthsAvailable or 0) + 1

        if applicant.monthsAvailable >= maxMonths then
            table.remove(self.applicants, index)
            expired = expired + 1
        end
    end

    return expired
end

function HelperPersonnelManager:getApplicantMarketUpdateActionText(added, expired)
    added = tonumber(added) or 0
    expired = tonumber(expired) or 0

    if added > 0 and expired > 0 then
        return string.format("Bewerbermarkt aktualisiert: %d Bewerber abgelaufen, %d neue Bewerber.", expired, added)
    elseif added > 0 then
        return added == 1 and "Bewerbermarkt aktualisiert: 1 neuer Bewerber." or string.format("Bewerbermarkt aktualisiert: %d neue Bewerber.", added)
    elseif expired > 0 then
        return expired == 1 and "Bewerbermarkt aktualisiert: 1 Bewerber abgelaufen." or string.format("Bewerbermarkt aktualisiert: %d Bewerber abgelaufen.", expired)
    end

    return nil
end

function HelperPersonnelManager:ensureApplicantBuffer(minimumCount, targetCount)
    minimumCount = minimumCount or 1
    targetCount = targetCount or minimumCount
    targetCount = math.min(targetCount, HelperPersonnelManager.MAX_APPLICANTS or targetCount)

    self:trimApplicantMarketToCap()

    if #self.applicants >= minimumCount then
        return 0
    end

    local added = 0
    while #self.applicants < targetCount do
        table.insert(self.applicants, self:createRandomApplicant())
        added = added + 1
    end

    return added
end

function HelperPersonnelManager:getApplicantPeriodInfo(period, year)
    period = tonumber(period)
    year = tonumber(year)

    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    if environment ~= nil then
        local environmentPeriod = tonumber(environment.currentPeriod) or tonumber(environment.period)
        local environmentYear = tonumber(environment.currentYear) or tonumber(environment.year)

        if environmentPeriod ~= nil then
            period = environmentPeriod
        end

        if environmentYear ~= nil then
            year = environmentYear
        end
    end

    if period == nil then
        return nil, nil
    end

    return math.floor(period), math.floor(year or 1)
end

function HelperPersonnelManager:initializeApplicantPeriodIfMissing()
    if self.lastApplicantPeriod ~= nil and self.lastApplicantYear ~= nil then
        return
    end

    local period, year = self:getApplicantPeriodInfo()
    if period ~= nil then
        self.lastApplicantPeriod = period
        self.lastApplicantYear = year
    end
end

function HelperPersonnelManager:initializeNewApplicantMarket()
    self.applicants = {}

    local maxApplicants = HelperPersonnelManager.MAX_APPLICANTS or 6
    local initialApplicantCount = math.min(3, maxApplicants)

    for _ = 1, initialApplicantCount do
        table.insert(self.applicants, self:createRandomApplicant())
    end

    if initialApplicantCount > 0 then
        self.lastActionText = self:getApplicantMarketUpdateActionText(initialApplicantCount, 0)
    end

    self.applicantMarketInitialized = true
    self:initializeApplicantPeriodIfMissing()
end

function HelperPersonnelManager:getMonthlyApplicantChance()
    local reputation = self:clampEmployerReputation(self.employerReputation)

    return 0.15 + ((reputation / 100) * 0.70)
end

function HelperPersonnelManager:rollMonthlyApplicantCount(forceAtLeastOne)
    local count = 0
    local chance = self:getMonthlyApplicantChance()

    for _ = 1, HelperPersonnelManager.MAX_MONTHLY_NEW_APPLICANTS do
        if math.random() < chance then
            count = count + 1
        end
    end

    if forceAtLeastOne and count < 1 then
        count = 1
    end

    return math.min(count, HelperPersonnelManager.MAX_MONTHLY_NEW_APPLICANTS)
end

function HelperPersonnelManager:generateMonthlyApplicants(forceAtLeastOne)
    self:trimApplicantMarketToCap()

    local maxApplicants = HelperPersonnelManager.MAX_APPLICANTS or 6
    local freeSlots = math.max(0, maxApplicants - #self.applicants)
    if freeSlots <= 0 then
        return 0
    end

    local mustCreateOne = forceAtLeastOne == true and #self.applicants <= 0
    local count = self:rollMonthlyApplicantCount(mustCreateOne)
    count = math.min(count, freeSlots)

    for _ = 1, count do
        table.insert(self.applicants, self:createRandomApplicant())
    end

    if count > 0 then
        self.lastActionText = self:getApplicantMarketUpdateActionText(count, 0)
    end

    return count
end

function HelperPersonnelManager:resetWorkerReliabilityDevelopmentCounters(worker, period, year)
    if type(worker) ~= "table" then
        return
    end

    period = math.max(0, math.floor((tonumber(period) or 0) + 0.5))
    year = math.max(0, math.floor((tonumber(year) or 0) + 0.5))

    local function resetCounter(periodKey, yearKey, valueKey)
        local counterPeriod = math.max(0, math.floor((tonumber(worker[periodKey]) or 0) + 0.5))
        local counterYear = math.max(0, math.floor((tonumber(worker[yearKey]) or 0) + 0.5))
        if counterPeriod ~= period or counterYear ~= year then
            worker[periodKey] = period
            worker[yearKey] = year
            worker[valueKey] = 0
        else
            worker[valueKey] = math.max(0, math.floor((tonumber(worker[valueKey]) or 0) + 0.5))
        end
    end

    resetCounter("reliabilityWorkPeriod", "reliabilityWorkYear", "reliabilityWorkMinutesThisPeriod")
    resetCounter("reliabilityIncidentPeriod", "reliabilityIncidentYear", "reliabilityIncidentsThisPeriod")
    resetCounter("reliabilitySicknessPeriod", "reliabilitySicknessYear", "reliabilitySicknessDaysThisPeriod")
    resetCounter("reliabilityNightWorkPeriod", "reliabilityNightWorkYear", "reliabilityNightWorkMinutesThisPeriod")
end

function HelperPersonnelManager:prepareWorkerReliabilityCounter(worker, counterName, period, year)
    if type(worker) ~= "table" or counterName == nil then
        return false
    end

    if period == nil or year == nil then
        period, year = self:getApplicantPeriodInfo()
    end

    period = math.max(0, math.floor((tonumber(period) or 0) + 0.5))
    year = math.max(0, math.floor((tonumber(year) or 0) + 0.5))
    if period <= 0 then
        return false
    end

    local periodKey = counterName .. "Period"
    local yearKey = counterName .. "Year"
    local valueKey
    if counterName == "reliabilityWork" then
        valueKey = "reliabilityWorkMinutesThisPeriod"
    elseif counterName == "reliabilityIncident" then
        valueKey = "reliabilityIncidentsThisPeriod"
    elseif counterName == "reliabilitySickness" then
        valueKey = "reliabilitySicknessDaysThisPeriod"
    elseif counterName == "reliabilityNightWork" then
        valueKey = "reliabilityNightWorkMinutesThisPeriod"
    end

    if valueKey == nil then
        return false
    end

    if tonumber(worker[periodKey]) ~= period or tonumber(worker[yearKey]) ~= year then
        worker[periodKey] = period
        worker[yearKey] = year
        worker[valueKey] = 0
    end

    return true
end

function HelperPersonnelManager:recordWorkerReliabilityWork(worker, workMinutes, period, year)
    if self:prepareWorkerReliabilityCounter(worker, "reliabilityWork", period, year) ~= true then
        return false
    end

    workMinutes = math.max(0, math.floor((tonumber(workMinutes) or 0) + 0.5))
    if workMinutes <= 0 then
        return false
    end

    worker.reliabilityWorkMinutesThisPeriod = math.max(0, (tonumber(worker.reliabilityWorkMinutesThisPeriod) or 0) + workMinutes)
    return true
end

function HelperPersonnelManager:recordWorkerReliabilityIncident(worker, reason, period, year)
    if self:prepareWorkerReliabilityCounter(worker, "reliabilityIncident", period, year) ~= true then
        return false
    end

    worker.reliabilityIncidentsThisPeriod = math.max(0, (tonumber(worker.reliabilityIncidentsThisPeriod) or 0) + 1)
    return true
end

function HelperPersonnelManager:recordWorkerReliabilitySickness(worker, days, period, year)
    if self:prepareWorkerReliabilityCounter(worker, "reliabilitySickness", period, year) ~= true then
        return false
    end

    days = math.max(0, math.floor((tonumber(days) or 0) + 0.5))
    if days <= 0 then
        return false
    end

    worker.reliabilitySicknessDaysThisPeriod = math.max(0, (tonumber(worker.reliabilitySicknessDaysThisPeriod) or 0) + days)
    return true
end

function HelperPersonnelManager:recordWorkerReliabilityNightWork(worker, nightMinutes, period, year)
    if self:prepareWorkerReliabilityCounter(worker, "reliabilityNightWork", period, year) ~= true then
        return false
    end

    nightMinutes = math.max(0, math.floor((tonumber(nightMinutes) or 0) + 0.5))
    if nightMinutes <= 0 then
        return false
    end

    worker.reliabilityNightWorkMinutesThisPeriod = math.max(0, (tonumber(worker.reliabilityNightWorkMinutesThisPeriod) or 0) + nightMinutes)
    return true
end

function HelperPersonnelManager:getWorkerReliabilityCounterForCurrentEvaluation(worker, counterName, currentPeriod, currentYear)
    if type(worker) ~= "table" or counterName == nil then
        return 0
    end

    local periodKey = counterName .. "Period"
    local yearKey = counterName .. "Year"
    local valueKey
    if counterName == "reliabilityWork" then
        valueKey = "reliabilityWorkMinutesThisPeriod"
    elseif counterName == "reliabilityIncident" then
        valueKey = "reliabilityIncidentsThisPeriod"
    elseif counterName == "reliabilitySickness" then
        valueKey = "reliabilitySicknessDaysThisPeriod"
    elseif counterName == "reliabilityNightWork" then
        valueKey = "reliabilityNightWorkMinutesThisPeriod"
    end

    if valueKey == nil then
        return 0
    end

    local counterPeriod = math.max(0, math.floor((tonumber(worker[periodKey]) or 0) + 0.5))
    local counterYear = math.max(0, math.floor((tonumber(worker[yearKey]) or 0) + 0.5))
    if counterPeriod <= 0 then
        return 0
    end

    currentPeriod = math.max(0, math.floor((tonumber(currentPeriod) or 0) + 0.5))
    currentYear = math.max(0, math.floor((tonumber(currentYear) or 0) + 0.5))
    if currentPeriod > 0 and counterPeriod == currentPeriod and counterYear == currentYear then
        return 0
    end

    return math.max(0, math.floor((tonumber(worker[valueKey]) or 0) + 0.5))
end

function HelperPersonnelManager:getWorkerReliabilityNegativeChance(worker, period, year)
    if type(worker) ~= "table" then
        return 0, nil
    end

    local chance = 0
    local reason = nil
    local loyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    if loyalty < (HelperPersonnelManager.RELIABILITY_LOW_LOYALTY_THRESHOLD or 25) then
        chance = chance + (HelperPersonnelManager.RELIABILITY_LOW_LOYALTY_MONTHLY_DROP_CHANCE or 0)
        reason = reason or "Unzufriedenheit"
    end

    if self.isSalaryRaiseDeclineAftereffectActive ~= nil and self:isSalaryRaiseDeclineAftereffectActive(worker, period, year) then
        chance = chance + (HelperPersonnelManager.RELIABILITY_SALARY_DECLINED_MONTHLY_DROP_CHANCE or 0)
        reason = reason or "abgelehnte Gehaltsforderung"
    end

    if worker.salaryRaisePending == true and self.getOpenSalaryRaiseRequestPeriodDistance ~= nil then
        local distance = self:getOpenSalaryRaiseRequestPeriodDistance(worker, period, year)
        if distance ~= nil and distance >= (HelperPersonnelManager.SALARY_RAISE_PENDING_GRACE_PERIODS or 1) then
            chance = chance + (HelperPersonnelManager.RELIABILITY_OPEN_SALARY_MONTHLY_DROP_CHANCE or 0)
            reason = reason or "offene Gehaltsforderung"
        end
    end

    local reputation = self:getEmployerReputation()
    if reputation < (HelperPersonnelManager.RELIABILITY_LOW_REPUTATION_THRESHOLD or 30) then
        chance = chance + (HelperPersonnelManager.RELIABILITY_LOW_REPUTATION_MONTHLY_DROP_CHANCE or 0)
        reason = reason or "schlechtes Arbeitgeberansehen"
    end

    local nightMinutes = self:getWorkerReliabilityCounterForCurrentEvaluation(worker, "reliabilityNightWork", period, year)
    if nightMinutes >= (HelperPersonnelManager.RELIABILITY_MONTHLY_NIGHT_WORK_MINUTES or 240) then
        chance = chance + (HelperPersonnelManager.RELIABILITY_NIGHT_WORK_MONTHLY_DROP_CHANCE or 0)
        reason = reason or "starke Nachtbelastung"
    end

    chance = math.max(0, math.min(HelperPersonnelManager.RELIABILITY_DEVELOPMENT_MAX_NEGATIVE_CHANCE or 0.60, chance))
    return chance, reason
end

function HelperPersonnelManager:canWorkerGainReliabilityThisMonth(worker, negativeChance, period, year)
    if type(worker) ~= "table" then
        return false
    end

    if (tonumber(negativeChance) or 0) > 0 then
        return false
    end

    local workMinutes = self:getWorkerReliabilityCounterForCurrentEvaluation(worker, "reliabilityWork", period, year)
    local incidents = self:getWorkerReliabilityCounterForCurrentEvaluation(worker, "reliabilityIncident", period, year)
    local sickDays = self:getWorkerReliabilityCounterForCurrentEvaluation(worker, "reliabilitySickness", period, year)
    local nightMinutes = self:getWorkerReliabilityCounterForCurrentEvaluation(worker, "reliabilityNightWork", period, year)

    return workMinutes >= (HelperPersonnelManager.RELIABILITY_MONTHLY_GOOD_WORK_MINUTES or 120)
        and incidents <= 0
        and sickDays <= 0
        and nightMinutes < (HelperPersonnelManager.RELIABILITY_MONTHLY_NIGHT_WORK_MINUTES or 240)
end

function HelperPersonnelManager:showReliabilityChangeNotification(worker, appliedDelta, previousReliability, newReliability, reason)
    appliedDelta = math.floor((tonumber(appliedDelta) or 0) + 0.5)
    if type(worker) ~= "table" or appliedDelta == 0 then
        return
    end

    previousReliability = self:clampPersonStat(previousReliability or worker.reliability or 0)
    newReliability = self:clampPersonStat(newReliability or worker.reliability or previousReliability)

    local fullName = self:getFullName(worker)
    local reasonText = reason ~= nil and reason ~= "" and string.format(" (%s)", reason) or ""
    local text = string.format("%s: Zuverlässigkeit %s%s. Zuverlässigkeit: %d auf %d", fullName, self:formatSignedDelta(appliedDelta), reasonText, previousReliability, newReliability)
    self:showIngameNotification(text, self:getInfoNotificationType())
end

function HelperPersonnelManager:processMonthlyReliabilityDevelopment(period, year)
    if not self:isGameplayExperienceEffectEnabled("reliability") then
        for _, worker in ipairs(self.workers or {}) do
            self:normalizePersonRuntimeData(worker)
            self:resetWorkerReliabilityDevelopmentCounters(worker, period, year)
            worker.reliabilityDevelopmentCheckPeriod = math.max(0, math.floor((tonumber(period) or 0) + 0.5))
            worker.reliabilityDevelopmentCheckYear = math.max(0, math.floor((tonumber(year) or 0) + 0.5))
        end
        return 0, 0, nil
    end

    local affected = 0
    local totalDelta = 0

    for _, worker in ipairs(self.workers or {}) do
        self:normalizePersonRuntimeData(worker)

        if tonumber(worker.reliabilityDevelopmentCheckPeriod) ~= tonumber(period) or tonumber(worker.reliabilityDevelopmentCheckYear) ~= tonumber(year) then
            local oldReliability = self:clampPersonStat(worker.reliability or 0)
            local delta = 0
            local reason = nil
            local negativeChance, negativeReason = self:getWorkerReliabilityNegativeChance(worker, period, year)

            if negativeChance > 0 and math.random() < negativeChance then
                delta = -1
                reason = negativeReason
            elseif self:canWorkerGainReliabilityThisMonth(worker, negativeChance, period, year) and math.random() < (HelperPersonnelManager.RELIABILITY_MONTHLY_GOOD_CHANCE or 0.35) then
                delta = 1
                reason = "guter Arbeitsmonat"
            end

            if delta ~= 0 then
                local newReliability = self:clampPersonStat(oldReliability + delta)
                local appliedDelta = newReliability - oldReliability
                if appliedDelta ~= 0 then
                    worker.reliability = newReliability
                    affected = affected + 1
                    totalDelta = totalDelta + appliedDelta
                    self:showReliabilityChangeNotification(worker, appliedDelta, oldReliability, newReliability, reason)
                end
            end

            worker.reliabilityDevelopmentCheckPeriod = math.max(0, math.floor((tonumber(period) or 0) + 0.5))
            worker.reliabilityDevelopmentCheckYear = math.max(0, math.floor((tonumber(year) or 0) + 0.5))
            self:resetWorkerReliabilityDevelopmentCounters(worker, period, year)
        end
    end

    if affected <= 0 or totalDelta == 0 then
        return totalDelta, affected, nil
    end

    local text
    if affected == 1 then
        text = string.format("Zuverlässigkeit: %s bei 1 Mitarbeiter.", self:formatSignedDelta(totalDelta))
    else
        text = string.format("Zuverlässigkeit: %s bei %d Mitarbeitern.", self:formatSignedDelta(totalDelta), affected)
    end

    return totalDelta, affected, text
end

function HelperPersonnelManager:processApplicantPeriodChange(period, year, forceCheck)
    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil then
        return false
    end

    if self.lastApplicantPeriod == nil or self.lastApplicantYear == nil then
        self.lastApplicantPeriod = period
        self.lastApplicantYear = year
        return false
    end

    if self.lastApplicantPeriod == period and self.lastApplicantYear == year then
        return false
    end

    self.lastApplicantPeriod = period
    self.lastApplicantYear = year
    self:resetMonthlyDismissalCounterIfNeeded(period, year)

    local payrollAmount, payrollDelta = self:processMonthlyPayroll()
    self:queuePayrollLoyaltyDelta(payrollDelta)
    local dismissedCount = self:processPendingDismissalsForPeriodChange(period, year)
    local resignedCount = self:processPendingResignationsForPeriodChange(period, year)
    local workerLoyaltyDelta, workerLoyaltyAffected = 0, 0
    local expired = self:ageApplicantMarketForNewPeriod()
    local forceAtLeastOne = #self.applicants <= 0
    local added = self:generateMonthlyApplicants(forceAtLeastOne)
    local loyaltyDelta, loyaltyWorkers = self:processWorkerLoyaltyMilestones(period, year)
    local reliabilityDelta, reliabilityWorkers, reliabilityText = self:processMonthlyReliabilityDevelopment(period, year)
    local actionText = self:getApplicantMarketUpdateActionText(added, expired)

    if payrollAmount ~= nil and payrollAmount > 0 then
        local payrollText = string.format("Gehaltsabrechnung: %s", self:formatMoneyForText(payrollAmount))
        if payrollDelta ~= nil and payrollDelta ~= 0 then
            payrollText = string.format("%s (%s Ansehen)", payrollText, self:formatSignedDelta(payrollDelta))
        end
        actionText = actionText ~= nil and (payrollText .. " " .. actionText) or payrollText
    end

    if workerLoyaltyAffected ~= nil and workerLoyaltyAffected > 0 and workerLoyaltyDelta ~= nil and workerLoyaltyDelta ~= 0 then
        local loyaltyText = workerLoyaltyAffected == 1
            and string.format("Loyalität: %s bei 1 Mitarbeiter.", self:formatSignedDelta(workerLoyaltyDelta))
            or string.format("Loyalität: %s bei %d Mitarbeitern.", self:formatSignedDelta(workerLoyaltyDelta), workerLoyaltyAffected)
        actionText = actionText ~= nil and (actionText .. " " .. loyaltyText) or loyaltyText
    end

    if loyaltyDelta ~= nil and loyaltyDelta > 0 then
        local loyaltyText = loyaltyWorkers == 1 and string.format("Betriebstreue: +%d Ansehen.", loyaltyDelta) or string.format("Betriebstreue: +%d Ansehen durch %d Mitarbeiter.", loyaltyDelta, loyaltyWorkers or 0)
        actionText = actionText ~= nil and (actionText .. " " .. loyaltyText) or loyaltyText
    end

    if reliabilityText ~= nil and reliabilityText ~= "" then
        actionText = actionText ~= nil and (actionText .. " " .. reliabilityText) or reliabilityText
    end

    if dismissedCount ~= nil and dismissedCount > 0 then
        local dismissalText = dismissedCount == 1 and "1 gekündigter Mitarbeiter wurde zum Monatswechsel entlassen." or string.format("%d gekündigte Mitarbeiter wurden zum Monatswechsel entlassen.", dismissedCount)
        actionText = actionText ~= nil and (actionText .. " " .. dismissalText) or dismissalText
    end

    if resignedCount ~= nil and resignedCount > 0 then
        local resignationText = resignedCount == 1 and "1 Mitarbeiter hat den Hof zum Monatswechsel verlassen." or string.format("%d Mitarbeiter haben den Hof zum Monatswechsel verlassen.", resignedCount)
        actionText = actionText ~= nil and (actionText .. " " .. resignationText) or resignationText
    end

    if actionText ~= nil then
        self:touch(actionText)
    else
        self:touch(nil)
    end

    return true
end

function HelperPersonnelManager:onPeriodChanged(period, year)
    self:processApplicantPeriodChange(period, year, true)
end

function HelperPersonnelManager:update(dt)
    local elapsedMs = dt or 0
    self.loyaltyRuntimeTimerMs = (self.loyaltyRuntimeTimerMs or 0) + elapsedMs
    if self.loyaltyRuntimeTimerMs >= (HelperPersonnelManager.PERIOD_CHECK_INTERVAL_MS or 1000) then
        local loyaltyRuntimeElapsedMs = self.loyaltyRuntimeTimerMs
        self.loyaltyRuntimeTimerMs = 0
        self:updateLoyaltyRuntimeForAllFarms(loyaltyRuntimeElapsedMs)
    end

    self.periodCheckTimerMs = (self.periodCheckTimerMs or 0) + elapsedMs

    if self.periodCheckTimerMs < (HelperPersonnelManager.PERIOD_CHECK_INTERVAL_MS or 1000) then
        return
    end

    self.periodCheckTimerMs = 0
    self:processApplicantPeriodChange(nil, nil, false)
end

function HelperPersonnelManager:clampPersonStat(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    return math.max(0, math.min(100, value))
end

function HelperPersonnelManager:getApplicantReputationModifiers()
    local reputation = self:getEmployerReputation()

    local experienceBonus = math.floor(((reputation - 60) / 4) + 0.5)
    local reliabilityBonus = math.floor(((reputation - 60) / 5) + 0.5)
    local wageMultiplier = 1 + ((60 - reputation) / 400)

    return experienceBonus, reliabilityBonus, wageMultiplier
end

function HelperPersonnelManager:createRandomApplicant()
    local experienceBonus, reliabilityBonus, wageMultiplier = self:getApplicantReputationModifiers()
    local reputation = self:getEmployerReputation()
    local loyaltyBonus = math.floor(((reputation - 50) / 5) + 0.5)
    local experience = self:rollApplicantExperience()
    local reliability = self:clampPersonStat(math.random(35, 98) + reliabilityBonus)
    local loyalty = self:clampPersonStat(math.random(40, 70) + loyaltyBonus)
    local baseWage = self:calculateApplicantBaseWage(experience, reliability, wageMultiplier)
    local wage = self:calculateCurrentMonthlyWageFromBase(baseWage)
    local gender = math.random(1, 2) == 1 and HelperPersonnelManager.GENDER_MALE or HelperPersonnelManager.GENDER_FEMALE
    local avatarIndex = self:getRandomAvatarIndexForGender(gender)

    gender = self:getGenderForAvatarIndex(avatarIndex) or gender

    local person = {
        id = self.nextPersonId,
        avatarIndex = avatarIndex,
        gender = gender,
        firstName = self:getRandomFirstNameForGender(gender),
        lastName = self:getRandomLastName(),
        experience = experience,
        reliability = reliability,
        loyalty = loyalty,
        baseWage = baseWage,
        wage = wage,
        busy = false,
        vehicleName = "",
        jobsCompleted = 0,
        totalWorkMinutes = 0,
        lastJobMinutes = 0,
        totalEarnings = 0,
        currentJobStartedAt = 0,
        dismissalPending = false,
        dismissalNoticePeriod = 0,
        dismissalNoticeYear = 0,
        dismissalEffectivePeriod = 0,
        dismissalEffectiveYear = 0,
        monthsAvailable = 0
    }

    self:assignRandomApplicantSpecializations(person)
    if person.specializationPrimary ~= nil then
        baseWage = self:roundToNearest(baseWage * (HelperPersonnelManager.SPECIALIZATION_PRIMARY_WAGE_MULTIPLIER or 1), 10)
        if person.specializationSecondary ~= nil then
            baseWage = self:roundToNearest(baseWage * (HelperPersonnelManager.SPECIALIZATION_SECONDARY_WAGE_MULTIPLIER or 1), 10)
        end
        person.baseWage = baseWage
        person.wage = self:calculateCurrentMonthlyWageFromBase(baseWage)
    end

    self.nextPersonId = self.nextPersonId + 1

    return person
end

function HelperPersonnelManager:getFullName(person)
    if type(person) ~= "table" then
        return ""
    end

    return string.format("%s %s", person.firstName or "", person.lastName or "")
end

function HelperPersonnelManager:getRankText(person)
    if type(person) ~= "table" then
        return g_i18n:getText("ui_rank_helper")
    end

    local experience = person.experience or 0

    if experience >= 75 then
        return g_i18n:getText("ui_rank_expert")
    elseif experience >= 45 then
        return g_i18n:getText("ui_rank_specialist")
    end

    return g_i18n:getText("ui_rank_helper")
end

function HelperPersonnelManager:getStatusText(person)
    if type(person) ~= "table" then
        return g_i18n:getText("ui_status_idle")
    end

    local statusText
    if self:isWorkerSick(person) then
        statusText = self:getLocalizedText("ui_status_sick", "krank")
    elseif self:isWorkerInTraining(person) then
        statusText = self:getLocalizedText("ui_status_training", "in Schulung")
    elseif person.busy then
        statusText = g_i18n:getText("ui_status_busy")
    elseif person.resignationPending == true then
        statusText = self:getLocalizedText("ui_status_resigned", "gekündigt zum Monatsende")
    else
        statusText = g_i18n:getText("ui_status_idle")
    end

    if person.dismissalPending == true then
        local dismissalText = self:getLocalizedText("ui_status_dismissed", "gekündigt")
        if statusText ~= nil and statusText ~= "" and statusText ~= dismissalText then
            return string.format("%s, %s", statusText, dismissalText)
        end
        return dismissalText
    end

    return statusText
end

function HelperPersonnelManager:formatWorkMinutes(minutes)
    minutes = math.max(0, minutes or 0)
    local hours = math.floor(minutes / 60)
    local restMinutes = minutes - (hours * 60)

    if hours > 0 then
        return string.format("%dh %02dmin", hours, restMinutes)
    end

    return string.format("%dmin", restMinutes)
end

function HelperPersonnelManager:getMonthName(period)

    local monthNamesByPeriod = {
        "März", "April", "Mai", "Juni", "Juli", "August",
        "September", "Oktober", "November", "Dezember", "Januar", "Februar"
    }

    period = math.floor((tonumber(period) or 0) + 0.5)
    if period < 1 or period > #monthNamesByPeriod then
        return nil
    end

    return monthNamesByPeriod[period]
end

function HelperPersonnelManager:getWorkerHiredLine(person)
    if type(person) ~= "table" then
        return ""
    end

    local monthName = self:getMonthName(person.hiredPeriod)
    local year = tonumber(person.hiredYear)

    if monthName == nil or year == nil then
        return g_i18n:getText("ui_worker_hired_unknown")
    end

    return string.format(g_i18n:getText("ui_worker_hired_line"), monthName, math.floor(year + 0.5))
end

function HelperPersonnelManager:getWorkerStatsLine(person)
    if type(person) ~= "table" then
        return ""
    end

    return string.format(g_i18n:getText("ui_worker_line3"), person.jobsCompleted or 0, self:formatWorkMinutes(person.totalWorkMinutes or 0))
end

function HelperPersonnelManager:getTotalWorkStats()
    local jobs = 0
    local minutes = 0
    local monthlyWages = 0

    for _, worker in ipairs(self.workers) do
        jobs = jobs + (worker.jobsCompleted or 0)
        minutes = minutes + (worker.totalWorkMinutes or 0)
        monthlyWages = monthlyWages + self:getCurrentMonthlyWage(worker)
    end

    return jobs, minutes, monthlyWages
end

function HelperPersonnelManager:getPersonLine1(person)
    if type(person) ~= "table" then
        return ""
    end

    local rankText = self:getRankText(person)
    return string.format(g_i18n:getText("ui_worker_line1"), rankText, person.experience or 0, person.reliability or 0, person.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
end

function HelperPersonnelManager:getApplicantLine1(person)
    if type(person) ~= "table" then
        return ""
    end

    local rankText = self:getRankText(person)
    return string.format(g_i18n:getText("ui_applicant_line1"), rankText, person.experience or 0, person.reliability or 0, person.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
end

function HelperPersonnelManager:getPersonLine2(person)
    if type(person) ~= "table" then
        return ""
    end

    local wageText = g_i18n:formatMoney(self:getCurrentMonthlyWage(person), 0, true, false)
    local statusText = self:getStatusText(person)
    if person.busy and person.vehicleName ~= nil and person.vehicleName ~= "" then
        statusText = string.format("%s (%s)", statusText, person.vehicleName)
    end

    return string.format(g_i18n:getText("ui_worker_line2"), wageText, statusText)
end

function HelperPersonnelManager:getApplicantLine2(person)
    if type(person) ~= "table" then
        return ""
    end

    local wageText = g_i18n:formatMoney(self:getCurrentMonthlyWage(person), 0, true, false)
    local monthsAvailable = math.max(0, tonumber(person.monthsAvailable) or 0)
    local ageText

    if monthsAvailable <= 0 then
        ageText = g_i18n:getText("ui_applicantAgeNew")
    else
        ageText = string.format(g_i18n:getText("ui_applicantAgeMonths"), monthsAvailable)
    end

    return string.format(g_i18n:getText("ui_applicant_line2_age"), wageText, ageText)
end

function HelperPersonnelManager:copyPersonForNetwork(person)
    if type(person) ~= "table" then
        return {}
    end

    return {
        id = person.id,
        firstName = person.firstName,
        lastName = person.lastName,
        gender = self:getGenderForPerson(person),
        experience = person.experience,
        reliability = person.reliability,
        loyalty = person.loyalty,
        avatarIndex = person.avatarIndex,
        assignedHelperIndex = person.assignedHelperIndex,
        assignedBaseHelperIndex = person.assignedBaseHelperIndex,
        hiredPeriod = person.hiredPeriod,
        hiredYear = person.hiredYear,
        loyaltyMilestoneMonths = person.loyaltyMilestoneMonths,
        loyaltyTenureMilestoneMonths = person.loyaltyTenureMilestoneMonths,
        nightWorkIngameMinutes = person.nightWorkIngameMinutes,
        nightWorkRealtimeMs = person.nightWorkRealtimeMs,
        nightWorkLastMinute = person.nightWorkLastMinute,
        loyaltyReputationProgress = person.loyaltyReputationProgress,
        loyaltyWarningPeriod = person.loyaltyWarningPeriod,
        loyaltyWarningYear = person.loyaltyWarningYear,
        resignationPending = person.resignationPending == true,
        dismissalPending = person.dismissalPending == true,
        dismissalNoticePeriod = person.dismissalNoticePeriod,
        dismissalNoticeYear = person.dismissalNoticeYear,
        resignationNoticePeriod = person.resignationNoticePeriod,
        resignationNoticeYear = person.resignationNoticeYear,
        resignationCheckPeriod = person.resignationCheckPeriod,
        resignationCheckYear = person.resignationCheckYear,
        sickPeriod = person.sickPeriod,
        sickYear = person.sickYear,
        sickDay = person.sickDay,
        sicknessPeriod = person.sicknessPeriod,
        sicknessYear = person.sicknessYear,
        sicknessDaysThisPeriod = person.sicknessDaysThisPeriod,
        reliabilityWorkPeriod = person.reliabilityWorkPeriod,
        reliabilityWorkYear = person.reliabilityWorkYear,
        reliabilityWorkMinutesThisPeriod = person.reliabilityWorkMinutesThisPeriod,
        reliabilityIncidentPeriod = person.reliabilityIncidentPeriod,
        reliabilityIncidentYear = person.reliabilityIncidentYear,
        reliabilityIncidentsThisPeriod = person.reliabilityIncidentsThisPeriod,
        reliabilitySicknessPeriod = person.reliabilitySicknessPeriod,
        reliabilitySicknessYear = person.reliabilitySicknessYear,
        reliabilitySicknessDaysThisPeriod = person.reliabilitySicknessDaysThisPeriod,
        reliabilityNightWorkPeriod = person.reliabilityNightWorkPeriod,
        reliabilityNightWorkYear = person.reliabilityNightWorkYear,
        reliabilityNightWorkMinutesThisPeriod = person.reliabilityNightWorkMinutesThisPeriod,
        reliabilityDevelopmentCheckPeriod = person.reliabilityDevelopmentCheckPeriod,
        reliabilityDevelopmentCheckYear = person.reliabilityDevelopmentCheckYear,
        experiencePeriod = person.experiencePeriod,
        experienceYear = person.experienceYear,
        experienceThisPeriod = person.experienceThisPeriod,
        experienceProgressMinutes = person.experienceProgressMinutes,
        specializationPrimary = person.specializationPrimary,
        specializationSecondary = person.specializationSecondary,
        specializationProgressKey = person.specializationProgressKey,
        specializationProgressMinutes = person.specializationProgressMinutes,
        specializationProgresses = self:copySpecializationProgresses(person),
        trainingLastPeriod = person.trainingLastPeriod,
        trainingLastYear = person.trainingLastYear,
        trainingLastSpecialization = person.trainingLastSpecialization,
        trainingActivePeriod = person.trainingActivePeriod,
        trainingActiveYear = person.trainingActiveYear,
        trainingActiveSpecialization = person.trainingActiveSpecialization,
        wage = person.wage,
        baseWage = person.baseWage,
        busy = person.busy == true,
        vehicleName = person.vehicleName,
        vehicleKey = person.vehicleKey,
        restorePending = person.restorePending == true,
        restoreVehicleName = person.restoreVehicleName,
        restoreVehicleKey = person.restoreVehicleKey,
        jobsCompleted = person.jobsCompleted,
        totalWorkMinutes = person.totalWorkMinutes,
        lastJobMinutes = person.lastJobMinutes,
        totalEarnings = person.totalEarnings,
        currentJobStartedAt = person.currentJobStartedAt,
        currentJobElapsedMs = self:getCurrentJobElapsedMs(person),
        monthsAvailable = person.monthsAvailable
    }
end

function HelperPersonnelManager:copyHistoryForNetwork(history)
    local result = {}
    local maxCount = HelperPersonnelManager.MAX_HISTORY_ENTRIES or 3

    for index, entry in ipairs(history or {}) do
        if index > maxCount then
            break
        end

        table.insert(result, {
            period = entry.period or 0,
            year = entry.year or 1,
            text = entry.text or "",
            sequence = entry.sequence or index
        })
    end

    return result
end

function HelperPersonnelManager:getNetworkState()
    local state = {
        nextPersonId = self.nextPersonId,
        employerReputation = self.employerReputation,
        lastActionText = self.lastActionText,
        lastReputationChangeText = self.lastReputationChangeText,
        lastPayrollText = self.lastPayrollText,
        lastPayrollAmount = self.lastPayrollAmount,
        totalPayrollPaid = self.totalPayrollPaid,
        dismissalPeriod = self.dismissalPeriod,
        dismissalYear = self.dismissalYear,
        monthlyDismissals = self.monthlyDismissals,
        lastApplicantPeriod = self.lastApplicantPeriod,
        lastApplicantYear = self.lastApplicantYear,
        changeCounter = self.changeCounter or 0,
        reputationHistory = self:copyHistoryForNetwork(self.reputationHistory),
        actionHistory = self:copyHistoryForNetwork(self.actionHistory),
        workers = {},
        applicants = {}
    }

    for _, worker in ipairs(self.workers or {}) do
        table.insert(state.workers, self:copyPersonForNetwork(worker))
    end

    for _, applicant in ipairs(self.applicants or {}) do
        table.insert(state.applicants, self:copyPersonForNetwork(applicant))
    end

    return state
end

function HelperPersonnelManager:applyNetworkState(state)
    if type(state) ~= "table" then
        return false
    end

    self.nextPersonId = math.max(1, tonumber(state.nextPersonId) or 1)
    self.employerReputation = self:clampEmployerReputation(state.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION)
    self.lastActionText = state.lastActionText or ""
    self.lastReputationChangeText = state.lastReputationChangeText or ""
    self.lastPayrollText = state.lastPayrollText or "noch keine Gehaltsabrechnung"
    self.lastPayrollAmount = tonumber(state.lastPayrollAmount) or 0
    self.totalPayrollPaid = tonumber(state.totalPayrollPaid) or 0
    self.dismissalPeriod = state.dismissalPeriod
    self.dismissalYear = state.dismissalYear
    self.monthlyDismissals = math.max(0, tonumber(state.monthlyDismissals) or 0)
    self.lastApplicantPeriod = state.lastApplicantPeriod
    self.lastApplicantYear = state.lastApplicantYear
    self.reputationHistory = state.reputationHistory or {}
    self.actionHistory = state.actionHistory or {}

    self.workers = {}
    for _, worker in ipairs(state.workers or {}) do
        local copiedWorker = {
            id = worker.id,
            firstName = worker.firstName,
            lastName = worker.lastName,
            gender = worker.gender,
            experience = worker.experience,
            reliability = worker.reliability,
            loyalty = worker.loyalty,
            avatarIndex = worker.avatarIndex,
            assignedHelperIndex = worker.assignedHelperIndex,
            assignedBaseHelperIndex = worker.assignedBaseHelperIndex,
            hiredPeriod = worker.hiredPeriod,
            hiredYear = worker.hiredYear,
            loyaltyMilestoneMonths = worker.loyaltyMilestoneMonths,
            loyaltyTenureMilestoneMonths = worker.loyaltyTenureMilestoneMonths,
            nightWorkIngameMinutes = worker.nightWorkIngameMinutes,
            nightWorkRealtimeMs = worker.nightWorkRealtimeMs,
            nightWorkLastMinute = worker.nightWorkLastMinute,
            loyaltyReputationProgress = worker.loyaltyReputationProgress,
            loyaltyWarningPeriod = worker.loyaltyWarningPeriod,
            loyaltyWarningYear = worker.loyaltyWarningYear,
            resignationPending = worker.resignationPending == true,
            resignationNoticePeriod = worker.resignationNoticePeriod,
            resignationNoticeYear = worker.resignationNoticeYear,
            resignationCheckPeriod = worker.resignationCheckPeriod,
            resignationCheckYear = worker.resignationCheckYear,
            sickPeriod = worker.sickPeriod,
            sickYear = worker.sickYear,
            sickDay = worker.sickDay,
            sicknessPeriod = worker.sicknessPeriod,
            sicknessYear = worker.sicknessYear,
            sicknessDaysThisPeriod = worker.sicknessDaysThisPeriod,
            reliabilityWorkPeriod = worker.reliabilityWorkPeriod,
            reliabilityWorkYear = worker.reliabilityWorkYear,
            reliabilityWorkMinutesThisPeriod = worker.reliabilityWorkMinutesThisPeriod,
            reliabilityIncidentPeriod = worker.reliabilityIncidentPeriod,
            reliabilityIncidentYear = worker.reliabilityIncidentYear,
            reliabilityIncidentsThisPeriod = worker.reliabilityIncidentsThisPeriod,
            reliabilitySicknessPeriod = worker.reliabilitySicknessPeriod,
            reliabilitySicknessYear = worker.reliabilitySicknessYear,
            reliabilitySicknessDaysThisPeriod = worker.reliabilitySicknessDaysThisPeriod,
            reliabilityNightWorkPeriod = worker.reliabilityNightWorkPeriod,
            reliabilityNightWorkYear = worker.reliabilityNightWorkYear,
            reliabilityNightWorkMinutesThisPeriod = worker.reliabilityNightWorkMinutesThisPeriod,
            reliabilityDevelopmentCheckPeriod = worker.reliabilityDevelopmentCheckPeriod,
            reliabilityDevelopmentCheckYear = worker.reliabilityDevelopmentCheckYear,
            experiencePeriod = worker.experiencePeriod,
            experienceYear = worker.experienceYear,
            experienceThisPeriod = worker.experienceThisPeriod,
            experienceProgressMinutes = worker.experienceProgressMinutes,
            specializationPrimary = worker.specializationPrimary,
            specializationSecondary = worker.specializationSecondary,
            specializationProgressKey = worker.specializationProgressKey,
            specializationProgressMinutes = worker.specializationProgressMinutes,
            specializationProgresses = self:copySpecializationProgresses(worker),
            trainingLastPeriod = worker.trainingLastPeriod,
            trainingLastYear = worker.trainingLastYear,
            trainingLastSpecialization = worker.trainingLastSpecialization,
            trainingActivePeriod = worker.trainingActivePeriod,
            trainingActiveYear = worker.trainingActiveYear,
            trainingActiveSpecialization = worker.trainingActiveSpecialization,
            wage = worker.wage,
            baseWage = worker.baseWage,
            busy = worker.busy == true,
            vehicleName = worker.vehicleName or "",
            vehicleKey = worker.vehicleKey,
            restorePending = worker.restorePending == true,
            restoreVehicleName = worker.restoreVehicleName,
            restoreVehicleKey = worker.restoreVehicleKey,
            jobsCompleted = worker.jobsCompleted,
            totalWorkMinutes = worker.totalWorkMinutes,
            lastJobMinutes = worker.lastJobMinutes,
            totalEarnings = worker.totalEarnings,
            currentJobStartedAt = worker.currentJobStartedAt,
            currentJobElapsedMs = worker.currentJobElapsedMs
        }

        if copiedWorker.busy == true then
            copiedWorker.currentJobElapsedMs = math.max(0, tonumber(copiedWorker.currentJobElapsedMs) or 0)
            copiedWorker.currentJobStartedAt = self:getCurrentTimestampMs() - copiedWorker.currentJobElapsedMs
        end

        self:normalizePersonRuntimeData(copiedWorker)
        table.insert(self.workers, copiedWorker)
    end

    self.applicants = {}
    for _, applicant in ipairs(state.applicants or {}) do
        local copiedApplicant = {
            id = applicant.id,
            firstName = applicant.firstName,
            lastName = applicant.lastName,
            gender = applicant.gender,
            experience = applicant.experience,
            reliability = applicant.reliability,
            loyalty = applicant.loyalty,
            loyaltyReputationProgress = applicant.loyaltyReputationProgress,
            loyaltyWarningPeriod = applicant.loyaltyWarningPeriod,
            loyaltyWarningYear = applicant.loyaltyWarningYear,
            resignationPending = applicant.resignationPending == true,
            resignationNoticePeriod = applicant.resignationNoticePeriod,
            resignationNoticeYear = applicant.resignationNoticeYear,
            resignationCheckPeriod = applicant.resignationCheckPeriod,
            resignationCheckYear = applicant.resignationCheckYear,
            reliabilityDevelopmentCheckPeriod = applicant.reliabilityDevelopmentCheckPeriod,
            reliabilityDevelopmentCheckYear = applicant.reliabilityDevelopmentCheckYear,
            avatarIndex = applicant.avatarIndex,
            assignedHelperIndex = applicant.assignedHelperIndex,
            assignedBaseHelperIndex = applicant.assignedBaseHelperIndex,
            wage = applicant.wage,
            baseWage = applicant.baseWage,
            monthsAvailable = applicant.monthsAvailable,
            specializationPrimary = applicant.specializationPrimary,
            specializationSecondary = applicant.specializationSecondary,
            busy = false,
            vehicleName = "",
            jobsCompleted = 0,
            totalWorkMinutes = 0,
            lastJobMinutes = 0,
            totalEarnings = 0,
            currentJobStartedAt = 0,
            currentJobElapsedMs = 0
        }
        self:normalizeApplicantRuntimeData(copiedApplicant)
        table.insert(self.applicants, copiedApplicant)
    end

    self.changeCounter = math.max((self.changeCounter or 0) + 1, tonumber(state.changeCounter) or 0)

    if type(self.notifyDataChanged) == "function" then
        self:notifyDataChanged()
    end

    return true
end

function HelperPersonnelManager:getIngameDayMinute()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    local dayTime = nil

    if environment ~= nil then
        dayTime = tonumber(environment.dayTime) or tonumber(environment.currentDayTime) or tonumber(environment.daytime)

        if dayTime == nil then
            local hour = tonumber(environment.currentHour) or tonumber(environment.hour)
            local minute = tonumber(environment.currentMinute) or tonumber(environment.minute) or 0
            if hour ~= nil then
                return ((math.floor(hour) * 60) + math.floor(minute)) % 1440
            end
        end
    end

    if dayTime == nil and g_currentMission ~= nil then
        dayTime = tonumber(g_currentMission.dayTime) or tonumber(g_currentMission.timeOfDay)
    end

    if dayTime == nil then
        return nil
    end

    if dayTime > 1440 then
        return math.floor((dayTime % 86400000) / 60000)
    elseif dayTime > 24 then
        return math.floor(dayTime % 1440)
    end

    return math.floor((dayTime * 60) % 1440)
end

function HelperPersonnelManager:isNightMinute(minuteOfDay)
    minuteOfDay = tonumber(minuteOfDay)
    if minuteOfDay == nil then
        return false
    end

    minuteOfDay = math.floor(minuteOfDay) % 1440
    return minuteOfDay >= (HelperPersonnelManager.NIGHT_WORK_START_MINUTE or 1320) or minuteOfDay < (HelperPersonnelManager.NIGHT_WORK_END_MINUTE or 360)
end

local function hpOverlapMinutes(startA, endA, startB, endB)
    local startValue = math.max(startA, startB)
    local endValue = math.min(endA, endB)
    return math.max(0, endValue - startValue)
end

function HelperPersonnelManager:getNightOverlapMinutes(previousMinute, currentMinute)
    previousMinute = tonumber(previousMinute)
    currentMinute = tonumber(currentMinute)

    if previousMinute == nil or currentMinute == nil then
        return 0
    end

    previousMinute = math.floor(previousMinute) % 1440
    currentMinute = math.floor(currentMinute) % 1440

    local duration = (currentMinute - previousMinute) % 1440
    if duration <= 0 then
        return 0
    end

    duration = math.min(duration, 1440)
    local startMinute = previousMinute
    local endMinute = previousMinute + duration
    local total = 0

    for offset = -1440, 1440, 1440 do
        total = total + hpOverlapMinutes(startMinute, endMinute, (HelperPersonnelManager.NIGHT_WORK_START_MINUTE or 1320) + offset, 1440 + offset)
        total = total + hpOverlapMinutes(startMinute, endMinute, offset, (HelperPersonnelManager.NIGHT_WORK_END_MINUTE or 360) + offset)
    end

    return math.max(0, math.floor(total + 0.5))
end

function HelperPersonnelManager:getEnvironmentDayInPeriod()
    local environment = g_currentMission ~= nil and g_currentMission.environment or nil
    local day = nil

    if environment ~= nil then
        day = environment.currentDayInPeriod or environment.dayInPeriod or environment.currentDayInMonth or environment.dayInMonth
        if day == nil then
            local currentDay = tonumber(environment.currentDay)
            local daysPerPeriod = tonumber(environment.daysPerPeriod or environment.daysPerMonth)
            if currentDay ~= nil and daysPerPeriod ~= nil and daysPerPeriod > 0 then
                day = ((math.max(1, math.floor(currentDay + 0.5)) - 1) % math.floor(daysPerPeriod + 0.5)) + 1
            end
        end
    end

    if day == nil and g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
        day = g_currentMission.missionInfo.currentDayInPeriod or g_currentMission.missionInfo.dayInPeriod or g_currentMission.missionInfo.currentDayInMonth or g_currentMission.missionInfo.dayInMonth
    end

    day = tonumber(day)
    if day == nil then
        return nil
    end

    return math.max(1, math.min(self:getSalaryDaysPerMonth(), math.floor(day + 0.5)))
end

function HelperPersonnelManager:getSicknessDayInfo()
    local period, year = self:getApplicantPeriodInfo()
    period = period or 1
    year = year or 1

    local environmentDay = self:getEnvironmentDayInPeriod()
    if environmentDay ~= nil then
        self.sicknessCurrentDay = environmentDay
        self.sicknessDayPeriod = period
        self.sicknessDayYear = year
        return period, year, environmentDay
    end

    if self.sicknessDayPeriod ~= period or self.sicknessDayYear ~= year then
        self.sicknessCurrentDay = 1
        self.sicknessDayPeriod = period
        self.sicknessDayYear = year
    end

    local day = math.max(1, math.floor((tonumber(self.sicknessCurrentDay) or 1) + 0.5))
    local maxDay = self:getSalaryDaysPerMonth()
    if day > maxDay then
        day = maxDay
    end

    self.sicknessCurrentDay = day
    return period, year, day
end

function HelperPersonnelManager:advanceSicknessDayAfterMidnight(period, year)
    local currentPeriod, currentYear = self:getApplicantPeriodInfo(period, year)
    currentPeriod = currentPeriod or 1
    currentYear = currentYear or 1

    local environmentDay = self:getEnvironmentDayInPeriod()
    if environmentDay ~= nil then
        self.sicknessCurrentDay = environmentDay
        self.sicknessDayPeriod = currentPeriod
        self.sicknessDayYear = currentYear
        return self.sicknessCurrentDay
    end

    local maxDay = self:getSalaryDaysPerMonth()
    if self.sicknessDayPeriod ~= currentPeriod or self.sicknessDayYear ~= currentYear then
        self.sicknessCurrentDay = 1
    else
        self.sicknessCurrentDay = ((math.max(1, math.floor((tonumber(self.sicknessCurrentDay) or 1) + 0.5))) % maxDay) + 1
    end

    self.sicknessDayPeriod = currentPeriod
    self.sicknessDayYear = currentYear
    return self.sicknessCurrentDay
end

function HelperPersonnelManager:hasCrossedMidnight(previousMinute, currentMinute)
    previousMinute = tonumber(previousMinute)
    currentMinute = tonumber(currentMinute)

    if previousMinute == nil or currentMinute == nil then
        return false
    end

    previousMinute = math.floor(previousMinute) % 1440
    currentMinute = math.floor(currentMinute) % 1440

    if previousMinute == currentMinute then
        return false
    end

    return previousMinute > currentMinute
end

function HelperPersonnelManager:getSicknessChance(worker)
    if type(worker) ~= "table" then
        return 0
    end

    if not self:isPersonnelEffectEnabled("sickness") or not self:isGameplayExperienceEffectEnabled("reliability") then
        return 0
    end

    local reliability = self:clampPersonStat(worker.reliability or 0)
    for _, tier in ipairs(HelperPersonnelManager.SICKNESS_CHANCES_BY_RELIABILITY or {}) do
        if reliability <= (tier.maxReliability or 100) then
            return tonumber(tier.chance) or 0
        end
    end

    return 0
end

function HelperPersonnelManager:getMaxSicknessDaysPerPeriod()
    local daysPerMonth = self:getSalaryDaysPerMonth()
    local step = math.max(1, tonumber(HelperPersonnelManager.SICKNESS_MAX_DAYS_STEP) or 3)
    return math.max(1, math.ceil(daysPerMonth / step))
end

function HelperPersonnelManager:getWorkerSicknessDaysThisPeriod(worker, period, year)
    if type(worker) ~= "table" then
        return 0
    end

    period = tonumber(period) or 0
    year = tonumber(year) or 0

    if tonumber(worker.sicknessPeriod) ~= period or tonumber(worker.sicknessYear) ~= year then
        worker.sicknessPeriod = period
        worker.sicknessYear = year
        worker.sicknessDaysThisPeriod = 0
    end

    return math.max(0, math.floor((tonumber(worker.sicknessDaysThisPeriod) or 0) + 0.5))
end

function HelperPersonnelManager:isWorkerSick(worker)
    if type(worker) ~= "table" then
        return false
    end

    if not self:isPersonnelEffectEnabled("sickness") or not self:isGameplayExperienceEffectEnabled("reliability") then
        return false
    end

    local period, year, day = self:getSicknessDayInfo()
    return tonumber(worker.sickPeriod) == tonumber(period)
        and tonumber(worker.sickYear) == tonumber(year)
        and tonumber(worker.sickDay) == tonumber(day)
end

function HelperPersonnelManager:abortActiveJobForSickWorker(worker)
    if type(worker) ~= "table" then
        return false
    end

    local bridge = self.app ~= nil and self.app.helperBridge or nil
    local workerId = tonumber(worker.id)
    local hasKnownJob = worker.busy == true or worker.isBusy == true or worker.isAssigned == true

    if not hasKnownJob and bridge ~= nil and bridge.workerJobById ~= nil and workerId ~= nil then
        hasKnownJob = bridge.workerJobById[workerId] ~= nil
    end

    if not hasKnownJob then
        return false
    end

    if bridge ~= nil and bridge.abortJobForWorker ~= nil then
        return bridge:abortJobForWorker(worker.id) == true
    end

    if worker.busy == true then
        self:setWorkerBusy(worker.id, false, "")
        return true
    end

    return false
end

function HelperPersonnelManager:showSicknessNotification(worker, jobAborted)
    if type(worker) ~= "table" then
        return
    end

    local key = jobAborted == true and "ui_sicknessNoticeJobAborted" or "ui_sicknessNotice"
    local fallback = jobAborted == true and "%s ist krank und kann heute nicht arbeiten. Der laufende Einsatz wurde abgebrochen." or "%s ist krank und kann heute nicht arbeiten."
    local template = self:getLocalizedText(key, fallback)
    self:showIngameNotification(string.format(template, self:getFullName(worker)), self:getInfoNotificationType())
end

function HelperPersonnelManager:markWorkerSickForToday(worker, period, year, day)
    if type(worker) ~= "table" then
        return false
    end

    if self:isWorkerSick(worker) then
        return false
    end

    if period == nil or year == nil or day == nil then
        period, year, day = self:getSicknessDayInfo()
    end

    local sickDays = self:getWorkerSicknessDaysThisPeriod(worker, period, year)
    local maxDays = self:getMaxSicknessDaysPerPeriod()
    if sickDays >= maxDays then
        return false
    end

    worker.sickPeriod = period
    worker.sickYear = year
    worker.sickDay = day
    worker.sicknessPeriod = period
    worker.sicknessYear = year
    worker.sicknessDaysThisPeriod = sickDays + 1
    self:recordWorkerReliabilitySickness(worker, 1, period, year)

    local jobAborted = self:abortActiveJobForSickWorker(worker)
    self:showSicknessNotification(worker, jobAborted)

    local text
    if jobAborted then
        text = string.format("%s ist krank. Der laufende Einsatz wurde abgebrochen.", self:getFullName(worker))
    else
        text = string.format("%s ist krank und heute nicht verfügbar.", self:getFullName(worker))
    end

    self:touch(text)
    return true
end

function HelperPersonnelManager:processDailySicknessCheck(period, year, day)
    if not self:isPersonnelEffectEnabled("sickness") or not self:isGameplayExperienceEffectEnabled("reliability") then
        return 0
    end

    if period == nil or year == nil or day == nil then
        period, year, day = self:getSicknessDayInfo()
    end

    local sickCount = 0
    for _, worker in ipairs(self.workers or {}) do
        self:normalizePersonRuntimeData(worker)

        if worker.resignationPending ~= true and not self:isWorkerSick(worker) then
            local sickDays = self:getWorkerSicknessDaysThisPeriod(worker, period, year)
            if sickDays < self:getMaxSicknessDaysPerPeriod() then
                local chance = self:getSicknessChance(worker)
                if chance > 0 and math.random() < chance then
                    if self:markWorkerSickForToday(worker, period, year, day) then
                        sickCount = sickCount + 1
                    end
                end
            end
        end
    end

    return sickCount
end

function HelperPersonnelManager:processDailySicknessIfDue(currentMinute)
    currentMinute = currentMinute or self:getIngameDayMinute()
    if currentMinute == nil then
        return false
    end

    local previousMinute = self.lastSicknessDailyCheckMinute
    self.lastSicknessDailyCheckMinute = currentMinute

    if previousMinute == nil then
        self:getSicknessDayInfo()
        return false
    end

    if not self:hasCrossedMidnight(previousMinute, currentMinute) then
        return false
    end

    local period, year = self:getApplicantPeriodInfo()
    local day = self:advanceSicknessDayAfterMidnight(period, year)
    local sickCount = self:processDailySicknessCheck(period, year, day)
    return sickCount > 0
end

function HelperPersonnelManager:updateWorkerNightWorkTracking(worker, dt, currentMinute)
    if type(worker) ~= "table" then
        return
    end

    currentMinute = currentMinute or self:getIngameDayMinute()
    if worker.busy ~= true then
        worker.nightWorkLastMinute = currentMinute
        return
    end

    local previousMinute = worker.nightWorkLastMinute
    worker.nightWorkLastMinute = currentMinute

    if currentMinute == nil then
        return
    end

    local nightMinutes = 0
    if previousMinute ~= nil then
        nightMinutes = self:getNightOverlapMinutes(previousMinute, currentMinute)
    elseif self:isNightMinute(currentMinute) then
        nightMinutes = 1
    end

    if nightMinutes > 0 then
        worker.nightWorkIngameMinutes = math.max(0, (tonumber(worker.nightWorkIngameMinutes) or 0) + nightMinutes)
        worker.nightWorkRealtimeMs = math.max(0, (tonumber(worker.nightWorkRealtimeMs) or 0) + math.max(0, tonumber(dt) or 0))
        self:recordWorkerReliabilityNightWork(worker, nightMinutes)
    end
end

function HelperPersonnelManager:updateLoyaltyRuntimeForCurrentFarm(dt)
    local currentMinute = self:getIngameDayMinute()

    for _, worker in ipairs(self.workers or {}) do
        self:updateWorkerNightWorkTracking(worker, dt, currentMinute)
    end

    self:processDailySicknessIfDue(currentMinute)
    self:processDailyLoyaltyEvaluationIfDue(currentMinute)
end

function HelperPersonnelManager:updateLoyaltyRuntimeForAllFarms(dt)
    if self.farms == nil then
        self:updateLoyaltyRuntimeForCurrentFarm(dt)
        return
    end

    self:forEachFarm(function()
        self:updateLoyaltyRuntimeForCurrentFarm(dt)
    end)
end

function HelperPersonnelManager:getPayrollLoyaltyDelta(payrollDelta)
    payrollDelta = tonumber(payrollDelta) or 0

    if payrollDelta > 0 then
        local reputation = self.getEmployerReputation ~= nil and self:getEmployerReputation() or self.employerReputation
        reputation = tonumber(reputation) or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50

        if reputation < (HelperPersonnelManager.LOYALTY_PAYROLL_BONUS_MIN_REPUTATION or 40) then
            return 0
        end

        return HelperPersonnelManager.LOYALTY_PAYROLL_PAID_DELTA or 1
    elseif payrollDelta <= (HelperPersonnelManager.PAYROLL_REPUTATION_ALREADY_NEGATIVE or -6) then
        return HelperPersonnelManager.LOYALTY_PAYROLL_ALREADY_NEGATIVE_DELTA or -4
    elseif payrollDelta < 0 then
        return HelperPersonnelManager.LOYALTY_PAYROLL_LOW_BALANCE_DELTA or -2
    end

    return 0
end

function HelperPersonnelManager:getTenureLoyaltyDelta(worker, period, year)
    if type(worker) ~= "table" then
        return 0
    end

    local employmentMonths = self:getCurrentEmploymentMonths(worker, period, year)
    if employmentMonths == nil then
        return 0
    end

    local awardedMilestone = math.max(0, tonumber(worker.loyaltyTenureMilestoneMonths) or 0)
    local delta = 0
    local highestMilestone = awardedMilestone

    for _, milestone in ipairs(HelperPersonnelManager.LOYALTY_TENURE_MILESTONES or {}) do
        if employmentMonths >= (milestone.months or 0) and awardedMilestone < (milestone.months or 0) then
            delta = delta + (milestone.delta or 0)
            highestMilestone = math.max(highestMilestone, milestone.months or 0)
        end
    end

    if highestMilestone > awardedMilestone then
        worker.loyaltyTenureMilestoneMonths = highestMilestone
    end

    return delta
end

function HelperPersonnelManager:getNightWorkLoyaltyDelta(worker)
    if type(worker) ~= "table" then
        return 0
    end

    if not self:isPersonnelEffectEnabled("nightWork") then
        return 0
    end

    local ingameMinutes = math.max(0, tonumber(worker.nightWorkIngameMinutes) or 0)
    local realtimeMinutes = math.max(0, (tonumber(worker.nightWorkRealtimeMs) or 0) / 60000)
    local minIngameMinutes = HelperPersonnelManager.NIGHT_WORK_LOYALTY_MIN_INGAME_MINUTES or 120
    local dampedRealtimeFactor = HelperPersonnelManager.NIGHT_WORK_REALTIME_FACTOR_CAP or 60
    local dampedWorkMinutes = math.min(ingameMinutes, realtimeMinutes * dampedRealtimeFactor)
    local penalty = 0

    if ingameMinutes >= minIngameMinutes then
        penalty = penalty + 1
    end

    if dampedWorkMinutes >= 60 then
        penalty = penalty + 1
    end
    if dampedWorkMinutes >= 180 then
        penalty = penalty + 1
    end
    if dampedWorkMinutes >= 360 then
        penalty = penalty + 1
    end

    penalty = math.min(HelperPersonnelManager.NIGHT_WORK_LOYALTY_MAX_PENALTY or 5, penalty)

    return -penalty
end

function HelperPersonnelManager:getNightWorkReputationPenalty(nightPenaltyTotal, affectedWorkers)
    if not self:isPersonnelEffectEnabled("nightWork") then
        return 0
    end

    nightPenaltyTotal = math.max(0, math.floor((tonumber(nightPenaltyTotal) or 0) + 0.5))
    affectedWorkers = math.max(0, math.floor((tonumber(affectedWorkers) or 0) + 0.5))

    if nightPenaltyTotal <= 0 or affectedWorkers <= 0 then
        return 0
    end

    local penalty = 1
    if affectedWorkers >= 2 or nightPenaltyTotal >= 3 then
        penalty = 2
    end

    penalty = math.min(HelperPersonnelManager.NIGHT_WORK_REPUTATION_MAX_PENALTY or 2, penalty)
    return -penalty
end

function HelperPersonnelManager:getReputationLoyaltyAttractionDelta(worker)
    if type(worker) ~= "table" then
        return 0
    end

    if not self:isPersonnelEffectEnabled("loyalty") then
        worker.loyaltyReputationProgress = 0
        return 0
    end

    local reputation = self:getEmployerReputation()
    local loyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    local diff = reputation - loyalty
    local absDiff = math.abs(diff)
    local monthlyStrength = 0

    if absDiff >= (HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_THRESHOLD_LARGE or 50) then
        monthlyStrength = HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_LARGE or 3
    elseif absDiff >= (HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_THRESHOLD_MEDIUM or 30) then
        monthlyStrength = HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_MEDIUM or 2
    elseif absDiff >= (HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_THRESHOLD_SMALL or 15) then
        monthlyStrength = HelperPersonnelManager.LOYALTY_REPUTATION_ATTRACTION_SMALL or 1
    end

    if monthlyStrength <= 0 or diff == 0 then
        worker.loyaltyReputationProgress = 0
        return 0
    end

    local sign = diff > 0 and 1 or -1
    local progress = tonumber(worker.loyaltyReputationProgress) or 0
    if progress ~= 0 and progress * sign < 0 then
        progress = 0
    end

    local daysPerMonth = math.max(1, math.min(28, self:getSalaryDaysPerMonth()))
    progress = progress + (sign * monthlyStrength / daysPerMonth)

    local delta = 0
    if progress >= 1 then
        delta = math.floor(progress)
        progress = progress - delta
    elseif progress <= -1 then
        delta = math.ceil(progress)
        progress = progress - delta
    end

    worker.loyaltyReputationProgress = progress
    return delta
end

function HelperPersonnelManager:resetWorkerLoyaltyPeriodCounters(worker)
    if type(worker) ~= "table" then
        return
    end

    worker.nightWorkIngameMinutes = 0
    worker.nightWorkRealtimeMs = 0
    worker.nightWorkLastMinute = self:getIngameDayMinute()
end

function HelperPersonnelManager:queuePayrollLoyaltyDelta(payrollDelta)
    payrollDelta = tonumber(payrollDelta) or 0
    if payrollDelta == 0 then
        return
    end

    self.pendingPayrollLoyaltyDelta = (tonumber(self.pendingPayrollLoyaltyDelta) or 0) + payrollDelta
end

function HelperPersonnelManager:showLoyaltyChangeNotification(worker, appliedDelta, previousLoyalty, newLoyalty)
    appliedDelta = math.floor((tonumber(appliedDelta) or 0) + 0.5)
    if type(worker) ~= "table" or appliedDelta == 0 then
        return
    end

    previousLoyalty = self:clampPersonStat(previousLoyalty or worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    newLoyalty = self:clampPersonStat(newLoyalty or worker.loyalty or previousLoyalty)

    local template = self:getLocalizedText("ui_loyaltyChanged", "%s: Loyalität %s. Loyalität: %d auf %d")
    local text = string.format(template, self:getFullName(worker), self:formatSignedDelta(appliedDelta), previousLoyalty, newLoyalty)
    self:showIngameNotification(text, self:getInfoNotificationType())
end

function HelperPersonnelManager:getLoyaltyWarningLevel(worker)
    if type(worker) ~= "table" then
        return 0
    end

    local loyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    if loyalty < (HelperPersonnelManager.LOYALTY_WARNING_THRESHOLD_CRITICAL or 15) then
        return 3
    elseif loyalty < (HelperPersonnelManager.LOYALTY_WARNING_THRESHOLD_VERY_LOW or 25) then
        return 2
    elseif loyalty < (HelperPersonnelManager.LOYALTY_WARNING_THRESHOLD_LOW or 40) then
        return 1
    end

    return 0
end

function HelperPersonnelManager:getLoyaltyWarningText(worker, warningLevel)
    warningLevel = tonumber(warningLevel) or 0
    local fullName = self:getFullName(worker)

    if warningLevel >= 3 then
        local template = self:getLocalizedText("ui_loyaltyWarningCritical", "%s denkt über einen Wechsel nach.")
        return string.format(template, fullName)
    elseif warningLevel >= 2 then
        local template = self:getLocalizedText("ui_loyaltyWarningVeryLow", "%s ist sehr unzufrieden.")
        return string.format(template, fullName)
    elseif warningLevel >= 1 then
        local template = self:getLocalizedText("ui_loyaltyWarningLow", "%s wirkt unzufrieden.")
        return string.format(template, fullName)
    end

    return nil
end

function HelperPersonnelManager:processLoyaltyWarningForWorker(worker, period, year)
    if type(worker) ~= "table" or not self:isPersonnelEffectEnabled("loyalty") then
        return false
    end

    period = math.max(1, math.floor((tonumber(period) or 1) + 0.5))
    year = math.max(1, math.floor((tonumber(year) or 1) + 0.5))

    if tonumber(worker.loyaltyWarningPeriod) == period and tonumber(worker.loyaltyWarningYear) == year then
        return false
    end

    local warningLevel = self:getLoyaltyWarningLevel(worker)
    if warningLevel <= 0 then
        return false
    end

    worker.loyaltyWarningPeriod = period
    worker.loyaltyWarningYear = year

    local text = self:getLoyaltyWarningText(worker, warningLevel)
    if text == nil or text == "" then
        return false
    end

    self.lastActionText = text
    self:addActionHistoryEntry(text, period, year)

    if warningLevel >= 2 then
        self:showIngameNotification(text, self:getInfoNotificationType())
    end

    self.changeCounter = (self.changeCounter or 0) + 1
    return true
end

function HelperPersonnelManager:processLoyaltyWarnings(period, year)
    if not self:isPersonnelEffectEnabled("loyalty") then
        return 0
    end

    local warningCount = 0
    for _, worker in ipairs(self.workers or {}) do
        if self:processLoyaltyWarningForWorker(worker, period, year) then
            warningCount = warningCount + 1
        end
    end

    return warningCount
end

function HelperPersonnelManager:hasCrossedDailyLoyaltyEvaluation(previousMinute, currentMinute)
    previousMinute = tonumber(previousMinute)
    currentMinute = tonumber(currentMinute)

    if previousMinute == nil or currentMinute == nil then
        return false
    end

    previousMinute = math.floor(previousMinute) % 1440
    currentMinute = math.floor(currentMinute) % 1440

    if previousMinute == currentMinute then
        return false
    end

    local evaluationMinute = HelperPersonnelManager.LOYALTY_DAILY_EVALUATION_MINUTE or 360

    if previousMinute < currentMinute then
        return previousMinute < evaluationMinute and currentMinute >= evaluationMinute
    end

    return previousMinute < evaluationMinute or currentMinute >= evaluationMinute
end

function HelperPersonnelManager:getPayrollLoyaltyReason(payrollDelta, loyaltyDelta)
    payrollDelta = tonumber(payrollDelta) or 0
    loyaltyDelta = tonumber(loyaltyDelta) or 0

    if loyaltyDelta > 0 then
        return "pünktliche Gehaltszahlung"
    elseif payrollDelta <= (HelperPersonnelManager.PAYROLL_REPUTATION_ALREADY_NEGATIVE or -6) then
        return "Hof war bei der Gehaltszahlung bereits im Minus"
    elseif payrollDelta < 0 then
        return "Hof rutschte durch die Gehaltszahlung ins Minus"
    end

    return nil
end

function HelperPersonnelManager:getLoyaltyReasonText(reasonParts)
    if type(reasonParts) ~= "table" or #reasonParts == 0 then
        return "normale monatliche Entwicklung"
    end

    return table.concat(reasonParts, ", ")
end

function HelperPersonnelManager:processDailyLoyaltyChanges(period, year)
    if not self:isPersonnelEffectEnabled("loyalty") then
        self.pendingPayrollLoyaltyDelta = 0
        for _, worker in ipairs(self.workers or {}) do
            worker.loyaltyReputationProgress = 0
            self:resetWorkerLoyaltyPeriodCounters(worker)
        end
        return 0, 0
    end

    period, year = period or nil, year or nil
    local pendingPayrollDelta = tonumber(self.pendingPayrollLoyaltyDelta) or 0
    local payrollLoyaltyDelta = self:getPayrollLoyaltyDelta(pendingPayrollDelta)
    local totalDelta = 0
    local affectedWorkers = 0
    local detailedHistoryLines = {}

    local nightWorkPenaltyTotal = 0
    local nightWorkAffectedWorkers = 0
    local nightWorkDeltas = {}

    for _, worker in ipairs(self.workers or {}) do
        local nightDelta = self:getNightWorkLoyaltyDelta(worker)
        nightWorkDeltas[worker] = nightDelta
        if nightDelta < 0 then
            nightWorkPenaltyTotal = nightWorkPenaltyTotal + math.abs(nightDelta)
            nightWorkAffectedWorkers = nightWorkAffectedWorkers + 1
        end
    end

    local reputationPenalty = self:getNightWorkReputationPenalty(nightWorkPenaltyTotal, nightWorkAffectedWorkers)
    if reputationPenalty ~= 0 then
        local reasonText = string.format("Nachtarbeit: %d Mitarbeiter betroffen: %d Ansehen", nightWorkAffectedWorkers, reputationPenalty)
        self:adjustEmployerReputation(reputationPenalty, reasonText)
        self.changeCounter = (self.changeCounter or 0) + 1
    end

    for _, worker in ipairs(self.workers or {}) do
        self:normalizePersonRuntimeData(worker)

        local reasonParts = {}
        local delta = 0

        if payrollLoyaltyDelta ~= 0 then
            delta = delta + payrollLoyaltyDelta
            local payrollReason = self:getPayrollLoyaltyReason(pendingPayrollDelta, payrollLoyaltyDelta)
            if payrollReason ~= nil and payrollReason ~= "" then
                table.insert(reasonParts, payrollReason)
            end
        end

        local tenureDelta = self:getTenureLoyaltyDelta(worker, period, year)
        if tenureDelta ~= 0 then
            delta = delta + tenureDelta
            table.insert(reasonParts, "lange Betriebszugehörigkeit")
        end

        local nightDelta = nightWorkDeltas[worker] or 0
        if nightDelta ~= 0 then
            delta = delta + nightDelta
            table.insert(reasonParts, "Nachtarbeit")
        end

        local reputationDelta = self:getReputationLoyaltyAttractionDelta(worker)
        if reputationDelta ~= 0 then
            delta = delta + reputationDelta
            if reputationDelta > 0 then
                table.insert(reasonParts, "gutes Arbeitgeberansehen")
            else
                table.insert(reasonParts, "niedrigeres Arbeitgeberansehen als persönliche Loyalität")
            end
        end

        if delta ~= 0 then
            local oldLoyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
            local newLoyalty = self:clampPersonStat(oldLoyalty + delta)
            local appliedDelta = newLoyalty - oldLoyalty

            if appliedDelta ~= 0 then
                worker.loyalty = newLoyalty
                totalDelta = totalDelta + appliedDelta
                affectedWorkers = affectedWorkers + 1
                self:showLoyaltyChangeNotification(worker, appliedDelta, oldLoyalty, newLoyalty)
                table.insert(detailedHistoryLines, string.format("%s: Loyalität %s (%d auf %d). Grund: %s.", self:getFullName(worker), self:formatSignedDelta(appliedDelta), oldLoyalty, newLoyalty, self:getLoyaltyReasonText(reasonParts)))
            end
        end

        self:resetWorkerLoyaltyPeriodCounters(worker)
    end

    self.pendingPayrollLoyaltyDelta = 0

    if affectedWorkers > 0 then
        if #detailedHistoryLines > 0 then
            self.lastActionText = detailedHistoryLines[1]
            for i = #detailedHistoryLines, 1, -1 do
                self:addActionHistoryEntry(detailedHistoryLines[i], period, year)
            end
            self.changeCounter = (self.changeCounter or 0) + 1
        else
            local text
            if affectedWorkers == 1 then
                text = string.format("Tägliche Loyalitätsauswertung: 1 Mitarbeiter (%s).", self:formatSignedDelta(totalDelta))
            else
                text = string.format("Tägliche Loyalitätsauswertung: %d Mitarbeiter (%s gesamt).", affectedWorkers, self:formatSignedDelta(totalDelta))
            end
            self:touch(text)
        end
    end

    self:processLoyaltyWarnings(period, year)
    self:processAutomaticResignationChecks(period, year)

    return totalDelta, affectedWorkers
end

function HelperPersonnelManager:getLoyaltyResignationChance(worker)
    if type(worker) ~= "table" or worker.resignationPending == true or worker.dismissalPending == true then
        return 0
    end

    local loyalty = self:clampPersonStat(worker.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    for _, tier in ipairs(HelperPersonnelManager.LOYALTY_RESIGNATION_CHANCES or {}) do
        if loyalty <= (tier.maxLoyalty or 0) then
            return tonumber(tier.chance) or 0
        end
    end

    return 0
end

function HelperPersonnelManager:showResignationNotice(worker)
    if type(worker) ~= "table" then
        return
    end

    local template = self:getLocalizedText("ui_loyaltyResignationNotice", "%s hat zum Monatsende gekündigt.")
    self:showIngameNotification(string.format(template, self:getFullName(worker)), self:getInfoNotificationType())
end

function HelperPersonnelManager:scheduleWorkerResignation(worker, period, year)
    if type(worker) ~= "table" or worker.resignationPending == true then
        return false
    end

    period, year = self:getApplicantPeriodInfo(period, year)
    worker.resignationPending = true
    worker.resignationNoticePeriod = period or 0
    worker.resignationNoticeYear = year or 0
    worker.resignationCheckPeriod = period or 0
    worker.resignationCheckYear = year or 0

    local text = string.format("%s hat zum Monatsende gekündigt.", self:getFullName(worker))
    self:showResignationNotice(worker)
    self:touch(text)
    return true
end

function HelperPersonnelManager:processAutomaticResignationChecks(period, year)
    if not self:isPersonnelEffectEnabled("loyalty") then
        return 0
    end

    period, year = self:getApplicantPeriodInfo(period, year)
    if period == nil or year == nil then
        return 0
    end

    local scheduled = 0
    for _, worker in ipairs(self.workers or {}) do
        self:normalizePersonRuntimeData(worker)

        if worker.resignationPending ~= true and worker.dismissalPending ~= true
            and not (worker.resignationCheckPeriod == period and worker.resignationCheckYear == year) then
            local chance = self:getLoyaltyResignationChance(worker)
            if chance > 0 then
                worker.resignationCheckPeriod = period
                worker.resignationCheckYear = year

                if math.random() < chance then
                    if self:scheduleWorkerResignation(worker, period, year) then
                        scheduled = scheduled + 1
                    end
                end
            end
        end
    end

    return scheduled
end

function HelperPersonnelManager:abortActiveJobForResigningWorker(worker)
    if type(worker) ~= "table" then
        return false
    end

    local workerId = worker.id
    local aborted = false

    if self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.abortJobForWorker ~= nil then
        aborted = self.app.helperBridge:abortJobForWorker(workerId) == true
    elseif worker.busy == true then
        self:setWorkerBusy(workerId, false, "")
        aborted = true
    end

    return aborted
end

function HelperPersonnelManager:processPendingDismissalsForPeriodChange(period, year)
    local removed = 0
    local actionTexts = {}

    for index = #(self.workers or {}), 1, -1 do
        local worker = self.workers[index]
        self:normalizePersonRuntimeData(worker)

        if worker.dismissalPending == true and self:isPeriodAtOrAfter(period, year, worker.dismissalEffectivePeriod, worker.dismissalEffectiveYear) then
            local fullName = self:getFullName(worker)
            local jobAborted = self:abortActiveJobForResigningWorker(worker)
            table.remove(self.workers, index)
            removed = removed + 1

            if jobAborted then
                table.insert(actionTexts, string.format("%s wurde nach abgebrochenem Einsatz zum Monatswechsel entlassen.", fullName))
            else
                table.insert(actionTexts, string.format("%s wurde zum Monatswechsel entlassen.", fullName))
            end
        end
    end

    if removed > 0 then
        self:rebuildHelperProfilesSafe()

        if #actionTexts == 1 then
            self:touch(actionTexts[1])
        else
            self:touch(string.format("%d gekündigte Mitarbeiter wurden zum Monatswechsel entlassen.", removed))
        end
    end

    return removed
end

function HelperPersonnelManager:processPendingResignationsForPeriodChange(period, year)
    local removed = 0
    local actionTexts = {}

    for index = #(self.workers or {}), 1, -1 do
        local worker = self.workers[index]
        self:normalizePersonRuntimeData(worker)

        if worker.resignationPending == true then
            local fullName = self:getFullName(worker)
            local jobAborted = self:abortActiveJobForResigningWorker(worker)
            table.remove(self.workers, index)
            removed = removed + 1

            local reputationDelta = HelperPersonnelManager.LOYALTY_RESIGNATION_REPUTATION_DELTA or -10
            self:adjustEmployerReputation(reputationDelta, string.format("Eigenkündigung von %s: %d Ansehen", fullName, reputationDelta))

            if jobAborted then
                table.insert(actionTexts, string.format("%s hat den Hof nach abgebrochenem Einsatz verlassen.", fullName))
            else
                table.insert(actionTexts, string.format("%s hat den Hof zum Monatswechsel verlassen.", fullName))
            end
        end
    end

    if removed > 0 then
        if self.app ~= nil and self.app.helperBridge ~= nil and self.app.helperBridge.rebuildHelperProfiles ~= nil then
            self.app.helperBridge:rebuildHelperProfiles()
        end

        if #actionTexts == 1 then
            self:touch(actionTexts[1])
        else
            self:touch(string.format("%d Mitarbeiter haben den Hof zum Monatswechsel verlassen.", removed))
        end
    end

    return removed
end

function HelperPersonnelManager:processDailyLoyaltyEvaluationIfDue(currentMinute)
    currentMinute = currentMinute or self:getIngameDayMinute()
    if currentMinute == nil then
        return false
    end

    local previousMinute = self.lastLoyaltyDailyCheckMinute
    self.lastLoyaltyDailyCheckMinute = currentMinute

    if previousMinute == nil then
        return false
    end

    if not self:hasCrossedDailyLoyaltyEvaluation(previousMinute, currentMinute) then
        return false
    end

    local period, year = self:getApplicantPeriodInfo()
    local _, affectedWorkers = self:processDailyLoyaltyChanges(period, year)
    return affectedWorkers > 0
end

local HP_ORIGINAL_MANAGER_LOAD_FROM_SAVEGAME = HelperPersonnelManager.loadFromSavegame
local HP_ORIGINAL_MANAGER_ON_PERIOD_CHANGED = HelperPersonnelManager.onPeriodChanged
local HP_ORIGINAL_MANAGER_CAPTURE_SAVE_SNAPSHOT = HelperPersonnelManager.captureSaveSnapshot
local HP_ORIGINAL_MANAGER_GET_WORKER_BY_ID = HelperPersonnelManager.getWorkerById
local HP_ORIGINAL_MANAGER_GET_WORKER_BY_VEHICLE_KEY = HelperPersonnelManager.getWorkerByVehicleKey
local HP_ORIGINAL_MANAGER_GET_PENDING_RESTORED_WORKER_COUNT = HelperPersonnelManager.getPendingRestoredWorkerCount
local HP_ORIGINAL_MANAGER_GET_SINGLE_PENDING_RESTORED_WORKER = HelperPersonnelManager.getSinglePendingRestoredWorker
local HP_ORIGINAL_MANAGER_GET_PENDING_RESTORED_WORKER_BY_VEHICLE_NAME = HelperPersonnelManager.getPendingRestoredWorkerByVehicleName
local HP_ORIGINAL_MANAGER_INITIALIZE_APPLICANT_MARKET = HelperPersonnelManager.initializeNewApplicantMarket

function HelperPersonnelManager:getSavegamePath()
    if self.app ~= nil and self.app.getSavegamePath ~= nil then
        return self.app:getSavegamePath()
    end

    if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
        local missionInfo = g_currentMission.missionInfo
        if missionInfo.savegameDirectory ~= nil and missionInfo.savegameDirectory ~= "" then
            return missionInfo.savegameDirectory .. "/helperPersonnel.xml"
        end

        if missionInfo.savegameIndex ~= nil and getUserProfileAppPath ~= nil then
            return getUserProfileAppPath() .. "savegame" .. tostring(missionInfo.savegameIndex) .. "/helperPersonnel.xml"
        end
    end

    return nil
end

function HelperPersonnelManager.registerFarmXMLPaths(schema, basePath)
    if schema == nil or basePath == nil then
        return
    end

    schema:register(XMLValueType.INT, basePath .. "#farmId", "Hof-ID")
    schema:register(XMLValueType.INT, basePath .. "#employerReputation", "Ansehen dieses Hofs")
    schema:register(XMLValueType.STRING, basePath .. "#lastActionText", "Letzte Aktion dieses Hofs")
    schema:register(XMLValueType.STRING, basePath .. "#lastReputationChangeText", "Letzte Ansehensänderung dieses Hofs")
    schema:register(XMLValueType.STRING, basePath .. "#lastPayrollText", "Letzte Gehaltsabrechnung dieses Hofs")
    schema:register(XMLValueType.FLOAT, basePath .. "#lastPayrollAmount", "Letzter Gehaltsbetrag dieses Hofs")
    schema:register(XMLValueType.FLOAT, basePath .. "#totalPayrollPaid", "Bisher gezahlte Gehälter dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#dismissalPeriod", "Entlassungsmonat dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#dismissalYear", "Entlassungsjahr dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#monthlyDismissals", "Entlassungen in diesem Monat auf diesem Hof")
    schema:register(XMLValueType.INT, basePath .. "#lastApplicantPeriod", "Letzter Bewerbermonat dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#lastApplicantYear", "Letztes Bewerberjahr dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#lastLoyaltyDailyCheckMinute", "Letzte Loyalitaetsauswertung dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#lastSicknessDailyCheckMinute", "Letzte Krankheitsauswertung dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#sicknessCurrentDay", "Aktueller Krankheitstag dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#sicknessDayPeriod", "Krankheitsmonat dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#sicknessDayYear", "Krankheitsjahr dieses Hofs")
    schema:register(XMLValueType.INT, basePath .. "#pendingPayrollLoyaltyDelta", "Vorgemerkte Gehaltswirkung fuer Loyalitaet")
    schema:register(XMLValueType.BOOL, basePath .. "#applicantMarketInitialized", "Bewerbermarkt wurde fuer diesen Hof initialisiert")

    local workerPath = basePath .. ".workers.worker(?)"
    local applicantPath = basePath .. ".applicants.applicant(?)"
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#id", "Mitarbeiter-ID")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#firstName", "Vorname")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#lastName", "Nachname")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#gender", "Geschlecht")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#experience", "Erfahrung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliability", "Zuverlässigkeit")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#loyalty", "Loyalität")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#avatarIndex", "Avatar-Index")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#wage", "Gehalt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#baseWage", "Grundgehalt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, workerPath .. "#busy", "Beschäftigt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#vehicleName", "Fahrzeugname")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#vehicleKey", "Fahrzeugschlüssel")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#assignedHelperIndex", "Zugeordneter Spielhelfer")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#assignedBaseHelperIndex", "Basis-Spielhelfer")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#hiredPeriod", "Einstellungsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#hiredYear", "Einstellungsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#loyaltyMilestoneMonths", "Treue-Meilenstein")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#loyaltyTenureMilestoneMonths", "Loyalitäts-Meilenstein")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#nightWorkIngameMinutes", "Nachtarbeit in Spielminuten")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#loyaltyReputationProgress", "Fortschritt fuer Loyalitaetsangleichung an Arbeitgeberansehen")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#loyaltyWarningPeriod", "Letzter Monat mit Loyalitaetswarnung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#loyaltyWarningYear", "Letztes Jahr mit Loyalitaetswarnung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, workerPath .. "#resignationPending", "Kündigung zum Monatsende vorgemerkt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, workerPath .. "#dismissalPending", "Entlassung zum Monatsende vorgemerkt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#dismissalNoticePeriod", "Monat der Entlassung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#dismissalNoticeYear", "Jahr der Entlassung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#dismissalEffectivePeriod", "Wirksamkeitsmonat der Entlassung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#dismissalEffectiveYear", "Wirksamkeitsjahr der Entlassung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#resignationNoticePeriod", "Monat der Eigenkündigung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#resignationNoticeYear", "Jahr der Eigenkündigung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#resignationCheckPeriod", "Letzter Monat mit Kündigungsprüfung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#resignationCheckYear", "Letztes Jahr mit Kündigungsprüfung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#sickPeriod", "Krankheitsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#sickYear", "Krankheitsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#sickDay", "Krankheitstag")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#sicknessPeriod", "Monat der Krankheitszählung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#sicknessYear", "Jahr der Krankheitszählung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#sicknessDaysThisPeriod", "Krankheitstage im Monat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityWorkPeriod", "Zuverlaessigkeits-Arbeitsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityWorkYear", "Zuverlaessigkeits-Arbeitsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityWorkMinutesThisPeriod", "Arbeitsminuten fuer Zuverlaessigkeitsentwicklung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityIncidentPeriod", "Zuverlaessigkeits-Auffaelligkeitsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityIncidentYear", "Zuverlaessigkeits-Auffaelligkeitsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityIncidentsThisPeriod", "Zuverlaessigkeits-Auffaelligkeiten im Monat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilitySicknessPeriod", "Zuverlaessigkeits-Krankheitsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilitySicknessYear", "Zuverlaessigkeits-Krankheitsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilitySicknessDaysThisPeriod", "Krankheitstage fuer Zuverlaessigkeitsentwicklung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityNightWorkPeriod", "Zuverlaessigkeits-Nachtarbeitsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityNightWorkYear", "Zuverlaessigkeits-Nachtarbeitsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityNightWorkMinutesThisPeriod", "Nachtarbeitsminuten fuer Zuverlaessigkeitsentwicklung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityDevelopmentCheckPeriod", "Letzte Zuverlaessigkeitsauswertung Monat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#reliabilityDevelopmentCheckYear", "Letzte Zuverlaessigkeitsauswertung Jahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#nightWorkRealtimeMs", "Nachtarbeit in Echtzeit")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#nightWorkLastMinute", "Letzte Nachtarbeitsminute")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#experiencePeriod", "Erfahrungsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#experienceYear", "Erfahrungsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#experienceThisPeriod", "Erfahrung im Monat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#experienceProgressMinutes", "Erfahrungsfortschritt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#specializationPrimary", "Hauptspezialisierung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#specializationSecondary", "Nebenspezialisierung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#specializationProgressKey", "Spezialisierungsfortschritt-Typ")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#specializationProgressMinutes", "Spezialisierungsfortschritt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#trainingLastPeriod", "Letzter Schulungsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#trainingLastYear", "Letztes Schulungsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#trainingLastSpecialization", "Letzte Schulungsfachrichtung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#trainingActivePeriod", "Aktiver Schulungsmonat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#trainingActiveYear", "Aktives Schulungsjahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#trainingActiveSpecialization", "Aktive Schulungsfachrichtung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. ".specializationProgress(?)#key", "Spezialisierungsfortschritt-Typ")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. ".specializationProgress(?)#minutes", "Spezialisierungsfortschritt-Minuten")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#jobsCompleted", "Abgeschlossene Arbeiten")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#totalWorkMinutes", "Arbeitsminuten gesamt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, workerPath .. "#lastJobMinutes", "Letzte Arbeitsminuten")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#totalEarnings", "Verdienst gesamt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#currentJobStartedAt", "Arbeitsbeginn")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, workerPath .. "#currentJobElapsedMs", "Bisherige Arbeitszeit")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.BOOL, workerPath .. "#restorePending", "Wiederherstellung offen")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#restoreVehicleName", "Wiederherstellungsfahrzeug")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, workerPath .. "#restoreVehicleKey", "Wiederherstellungsschlüssel")

    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, applicantPath .. "#id", "Bewerber-ID")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, applicantPath .. "#firstName", "Vorname")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, applicantPath .. "#lastName", "Nachname")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, applicantPath .. "#gender", "Geschlecht")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, applicantPath .. "#experience", "Erfahrung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, applicantPath .. "#reliability", "Zuverlässigkeit")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, applicantPath .. "#loyalty", "Loyalität")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, applicantPath .. "#avatarIndex", "Avatar-Index")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, applicantPath .. "#wage", "Gehaltsforderung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.FLOAT, applicantPath .. "#baseWage", "Grundgehalt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, applicantPath .. "#monthsAvailable", "Monate am Markt")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, applicantPath .. "#specializationPrimary", "Hauptspezialisierung")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, applicantPath .. "#specializationSecondary", "Nebenspezialisierung")

    local reputationPath = basePath .. ".reputationHistory.entry(?)"
    local actionPath = basePath .. ".actionHistory.entry(?)"
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, reputationPath .. "#period", "Monat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, reputationPath .. "#year", "Jahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, reputationPath .. "#text", "Text")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, reputationPath .. "#sequence", "Reihenfolge")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, actionPath .. "#period", "Monat")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, actionPath .. "#year", "Jahr")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, actionPath .. "#text", "Text")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, actionPath .. "#sequence", "Reihenfolge")

    local jobPath = basePath .. ".activeJobs.job(?)"
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, jobPath .. "#workerId", "Mitarbeiter-ID")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, jobPath .. "#vehicleKey", "Fahrzeugschlüssel")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.STRING, jobPath .. "#vehicleName", "Fahrzeugname")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, jobPath .. "#helperIndex", "Helferindex")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, jobPath .. "#baseHelperIndex", "Basis-Helferindex")
end

if HelperPersonnelManager.xmlSchema ~= nil then
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#saveVersion", "Savegame-Strukturversion")
    HelperPersonnelManager.xmlSchema:register(XMLValueType.INT, "helperPersonnel#activeFarmId", "Aktiver Hof beim Speichern")
    HelperPersonnelManager.registerFarmXMLPaths(HelperPersonnelManager.xmlSchema, "helperPersonnel.farms.farm(?)")
end

function HelperPersonnelManager:getFallbackFarmId()
    if FarmManager ~= nil and FarmManager.SINGLEPLAYER_FARM_ID ~= nil then
        return FarmManager.SINGLEPLAYER_FARM_ID
    end

    return 1
end

function HelperPersonnelManager:getCurrentFarmId()
    local farmId = nil

    if g_currentMission ~= nil then
        if g_currentMission.getFarmId ~= nil then
            local ok, result = pcall(g_currentMission.getFarmId, g_currentMission)
            if ok then
                farmId = tonumber(result)
            end
        end

        if farmId == nil and g_currentMission.player ~= nil then
            farmId = tonumber(g_currentMission.player.farmId)
        end

        if farmId == nil and g_currentMission.controlPlayer ~= nil then
            farmId = tonumber(g_currentMission.controlPlayer.farmId)
        end
    end

    if (farmId == nil or farmId <= 0) and g_farmManager ~= nil then
        local singleplayerFarmId = FarmManager ~= nil and FarmManager.SINGLEPLAYER_FARM_ID or nil
        if singleplayerFarmId ~= nil then
            farmId = tonumber(singleplayerFarmId)
        end
    end

    if farmId == nil or farmId <= 0 then
        farmId = self:getFallbackFarmId()
    end

    return farmId
end

function HelperPersonnelManager:createFarmData(farmId)
    return {
        farmId = tonumber(farmId) or self:getFallbackFarmId(),
        workers = {},
        applicants = {},
        employerReputation = HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50,
        lastActionText = "",
        lastReputationChangeText = "",
        lastPayrollText = "noch keine Gehaltsabrechnung",
        lastPayrollAmount = 0,
        totalPayrollPaid = 0,
        dismissalPeriod = nil,
        dismissalYear = nil,
        monthlyDismissals = 0,
        lastApplicantPeriod = nil,
        lastApplicantYear = nil,
        lastLoyaltyDailyCheckMinute = nil,
        lastSicknessDailyCheckMinute = nil,
        sicknessCurrentDay = nil,
        sicknessDayPeriod = nil,
        sicknessDayYear = nil,
        pendingPayrollLoyaltyDelta = 0,
        applicantMarketInitialized = false,
        reputationHistory = {},
        actionHistory = {},
        historySequence = 0,
        saveActiveJobSnapshot = {}
    }
end

function HelperPersonnelManager:bindFarmData(data)
    if data == nil then
        return nil
    end

    data.workers = data.workers or {}
    data.applicants = data.applicants or {}
    data.reputationHistory = data.reputationHistory or {}
    data.actionHistory = data.actionHistory or {}
    data.saveActiveJobSnapshot = data.saveActiveJobSnapshot or {}
    data.applicantMarketInitialized = data.applicantMarketInitialized == true

    self.currentFarmData = data
    self.activeFarmId = data.farmId
    self.workers = data.workers
    self.applicants = data.applicants
    self.employerReputation = data.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50
    self.lastActionText = data.lastActionText or ""
    self.lastReputationChangeText = data.lastReputationChangeText or ""
    self.lastPayrollText = data.lastPayrollText or "noch keine Gehaltsabrechnung"
    self.lastPayrollAmount = data.lastPayrollAmount or 0
    self.totalPayrollPaid = data.totalPayrollPaid or 0
    self.dismissalPeriod = data.dismissalPeriod
    self.dismissalYear = data.dismissalYear
    self.monthlyDismissals = data.monthlyDismissals or 0
    self.lastApplicantPeriod = data.lastApplicantPeriod
    self.lastApplicantYear = data.lastApplicantYear
    self.lastLoyaltyDailyCheckMinute = data.lastLoyaltyDailyCheckMinute
    self.lastSicknessDailyCheckMinute = data.lastSicknessDailyCheckMinute
    self.sicknessCurrentDay = data.sicknessCurrentDay
    self.sicknessDayPeriod = data.sicknessDayPeriod
    self.sicknessDayYear = data.sicknessDayYear
    self.pendingPayrollLoyaltyDelta = tonumber(data.pendingPayrollLoyaltyDelta) or 0
    self.applicantMarketInitialized = data.applicantMarketInitialized == true
    self.reputationHistory = data.reputationHistory
    self.actionHistory = data.actionHistory
    self.historySequence = math.max(tonumber(data.historySequence) or 0, self:getHighestHistorySequence())
    self.saveActiveJobSnapshot = data.saveActiveJobSnapshot

    return data
end

function HelperPersonnelManager:storeCurrentFarmData()
    local data = self.currentFarmData
    if data == nil then
        return nil
    end

    data.workers = self.workers or data.workers or {}
    data.applicants = self.applicants or data.applicants or {}
    data.employerReputation = self.employerReputation or data.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50
    data.lastActionText = self.lastActionText or ""
    data.lastReputationChangeText = self.lastReputationChangeText or ""
    data.lastPayrollText = self.lastPayrollText or "noch keine Gehaltsabrechnung"
    data.lastPayrollAmount = self.lastPayrollAmount or 0
    data.totalPayrollPaid = self.totalPayrollPaid or 0
    data.dismissalPeriod = self.dismissalPeriod
    data.dismissalYear = self.dismissalYear
    data.monthlyDismissals = self.monthlyDismissals or 0
    data.lastApplicantPeriod = self.lastApplicantPeriod
    data.lastApplicantYear = self.lastApplicantYear
    data.lastLoyaltyDailyCheckMinute = self.lastLoyaltyDailyCheckMinute
    data.lastSicknessDailyCheckMinute = self.lastSicknessDailyCheckMinute
    data.sicknessCurrentDay = self.sicknessCurrentDay
    data.sicknessDayPeriod = self.sicknessDayPeriod
    data.sicknessDayYear = self.sicknessDayYear
    data.pendingPayrollLoyaltyDelta = tonumber(self.pendingPayrollLoyaltyDelta) or 0
    data.applicantMarketInitialized = self.applicantMarketInitialized == true or data.applicantMarketInitialized == true
    data.reputationHistory = self.reputationHistory or data.reputationHistory or {}
    data.actionHistory = self.actionHistory or data.actionHistory or {}
    data.historySequence = math.max(tonumber(self.historySequence) or 0, self:getHighestHistorySequence())
    data.saveActiveJobSnapshot = self.saveActiveJobSnapshot or data.saveActiveJobSnapshot or {}

    return data
end

function HelperPersonnelManager:ensureInitialApplicantMarketForFarmData(data)
    if data == nil then
        return 0
    end

    data.workers = data.workers or {}
    data.applicants = data.applicants or {}

    if data.applicantMarketInitialized == true then
        return 0
    end

    local hasExistingProgress = #data.workers > 0
        or #data.applicants > 0
        or (data.lastActionText ~= nil and data.lastActionText ~= "")
        or (data.lastReputationChangeText ~= nil and data.lastReputationChangeText ~= "")
        or #(data.reputationHistory or {}) > 0
        or #(data.actionHistory or {}) > 0

    if hasExistingProgress then
        data.applicantMarketInitialized = true
        return 0
    end

    local previousData = self.currentFarmData
    self:bindFarmData(data)

    local added = 0
    if self.initializeNewApplicantMarket ~= nil then
        self:initializeNewApplicantMarket()
        added = #(self.applicants or {})
    elseif self.ensureApplicantBuffer ~= nil then
        added = self:ensureApplicantBuffer(3, 3)
    end

    self.applicantMarketInitialized = true
    self:storeCurrentFarmData()

    if previousData ~= nil and previousData ~= data then
        self:bindFarmData(previousData)
    end

    return added
end

function HelperPersonnelManager:getOrCreateFarmData(farmId, initializeApplicants)
    farmId = tonumber(farmId) or self:getCurrentFarmId()
    if self.farms == nil then
        self.farms = {}
    end

    local data = self.farms[farmId]
    if data == nil then
        data = self:createFarmData(farmId)
        self.farms[farmId] = data

        if initializeApplicants ~= false then
            self:ensureInitialApplicantMarketForFarmData(data)
        end
    end

    return data
end

function HelperPersonnelManager:refreshFarmContext(farmId)
    self:storeCurrentFarmData()

    farmId = tonumber(farmId) or self:getCurrentFarmId()
    local data = self:getOrCreateFarmData(farmId, true)
    self:ensureInitialApplicantMarketForFarmData(data)
    self:bindFarmData(data)

    return data
end

function HelperPersonnelManager:adoptFlatStateAsFarm(farmId)
    farmId = tonumber(farmId) or self:getCurrentFarmId()
    if self.farms == nil then
        self.farms = {}
    end

    local data = self:createFarmData(farmId)
    data.workers = self.workers or {}
    data.applicants = self.applicants or {}
    data.employerReputation = self.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50
    data.lastActionText = self.lastActionText or ""
    data.lastReputationChangeText = self.lastReputationChangeText or ""
    data.lastPayrollText = self.lastPayrollText or "noch keine Gehaltsabrechnung"
    data.lastPayrollAmount = self.lastPayrollAmount or 0
    data.totalPayrollPaid = self.totalPayrollPaid or 0
    data.dismissalPeriod = self.dismissalPeriod
    data.dismissalYear = self.dismissalYear
    data.monthlyDismissals = self.monthlyDismissals or 0
    data.lastApplicantPeriod = self.lastApplicantPeriod
    data.lastApplicantYear = self.lastApplicantYear
    data.applicantMarketInitialized = self.applicantMarketInitialized == true or #(data.applicants or {}) > 0 or #(data.workers or {}) > 0
    data.reputationHistory = self.reputationHistory or {}
    data.actionHistory = self.actionHistory or {}
    data.saveActiveJobSnapshot = self.saveActiveJobSnapshot or {}

    self.farms[farmId] = data
    self:bindFarmData(data)

    for _, worker in ipairs(data.workers) do
        worker.farmId = farmId
    end
    for _, applicant in ipairs(data.applicants) do
        applicant.farmId = farmId
    end

    return data
end

function HelperPersonnelManager:getSortedFarmIds()
    local ids = {}

    if self.farms ~= nil then
        for farmId, _ in pairs(self.farms) do
            table.insert(ids, tonumber(farmId) or farmId)
        end
    end

    table.sort(ids, function(a, b)
        return tonumber(a) < tonumber(b)
    end)

    return ids
end

function HelperPersonnelManager:getAllWorkers()
    local result = {}

    if self.farms ~= nil then
        for _, farmId in ipairs(self:getSortedFarmIds()) do
            local data = self.farms[farmId]
            for _, worker in ipairs(data ~= nil and data.workers or {}) do
                table.insert(result, worker)
            end
        end
    else
        for _, worker in ipairs(self.workers or {}) do
            table.insert(result, worker)
        end
    end

    return result
end

function HelperPersonnelManager:findWorkerFarmData(workerId)
    if workerId == nil or self.farms == nil then
        return nil, nil, nil
    end

    for farmId, data in pairs(self.farms) do
        for index, worker in ipairs(data ~= nil and data.workers or {}) do
            if worker ~= nil and worker.id == workerId then
                return data, farmId, index
            end
        end
    end

    return nil, nil, nil
end

function HelperPersonnelManager:getWorkerById(workerId)
    if self.farms ~= nil then
        local data = self.currentFarmData
        for _, worker in ipairs(data ~= nil and data.workers or {}) do
            if worker.id == workerId then
                return worker
            end
        end

        local foundData = self:findWorkerFarmData(workerId)
        if foundData ~= nil then
            for _, worker in ipairs(foundData.workers or {}) do
                if worker.id == workerId then
                    return worker
                end
            end
        end

        return nil
    end

    if HP_ORIGINAL_MANAGER_GET_WORKER_BY_ID ~= nil then
        return HP_ORIGINAL_MANAGER_GET_WORKER_BY_ID(self, workerId)
    end

    return nil
end

function HelperPersonnelManager:getWorkerByVehicleKey(vehicleKey)
    if vehicleKey == nil or vehicleKey == "" then
        return nil
    end

    for _, worker in ipairs(self:getAllWorkers()) do
        if worker.busy == true and worker.vehicleKey == vehicleKey then
            return worker
        end
        if worker.restorePending == true and worker.restoreVehicleKey == vehicleKey then
            return worker
        end
    end

    return nil
end

function HelperPersonnelManager:getPendingRestoredWorkerCount()
    local count = 0
    for _, worker in ipairs(self:getAllWorkers()) do
        if worker.restorePending == true then
            count = count + 1
        end
    end
    return count
end

function HelperPersonnelManager:getSinglePendingRestoredWorker()
    local result = nil
    local count = 0
    for _, worker in ipairs(self:getAllWorkers()) do
        if worker.restorePending == true then
            result = worker
            count = count + 1
        end
    end
    return count == 1 and result or nil
end

function HelperPersonnelManager:getPendingRestoredWorkerByVehicleName(vehicleName)
    if vehicleName == nil or vehicleName == "" then
        return nil
    end

    local result = nil
    local count = 0
    for _, worker in ipairs(self:getAllWorkers()) do
        if worker.restorePending == true and worker.restoreVehicleName == vehicleName then
            result = worker
            count = count + 1
        end
    end

    return count == 1 and result or nil
end

function HelperPersonnelManager:forEachFarm(callback)
    if callback == nil then
        return
    end

    self:refreshFarmContext()
    for _, farmId in ipairs(self:getSortedFarmIds()) do
        local data = self.farms[farmId]
        if data ~= nil then
            self:bindFarmData(data)
            callback(data, farmId)
            self:storeCurrentFarmData()
        end
    end
    self:refreshFarmContext()
end

function HelperPersonnelManager:onPeriodChanged(period, year)
    if HP_ORIGINAL_MANAGER_ON_PERIOD_CHANGED == nil then
        return
    end

    self:refreshFarmContext()
    for _, farmId in ipairs(self:getSortedFarmIds()) do
        local data = self.farms[farmId]
        if data ~= nil then
            self:bindFarmData(data)
            HP_ORIGINAL_MANAGER_ON_PERIOD_CHANGED(self, period, year)
            self:storeCurrentFarmData()
        end
    end
    self:refreshFarmContext()
end

function HelperPersonnelManager:readPersonFromXML(xmlFile, key)
    local person = {
        id = xmlFile:getInt(key .. "#id"),
        firstName = xmlFile:getString(key .. "#firstName", ""),
        lastName = xmlFile:getString(key .. "#lastName", ""),
        gender = xmlFile:getString(key .. "#gender"),
        experience = xmlFile:getInt(key .. "#experience", 0),
        reliability = xmlFile:getInt(key .. "#reliability", 0),
        loyalty = xmlFile:getInt(key .. "#loyalty", HelperPersonnelManager.DEFAULT_LOYALTY),
        avatarIndex = xmlFile:getInt(key .. "#avatarIndex", 0),
        wage = xmlFile:getFloat(key .. "#wage", 0),
        baseWage = xmlFile:getFloat(key .. "#baseWage", 0),
        monthsAvailable = xmlFile:getInt(key .. "#monthsAvailable", 0),
        specializationPrimary = xmlFile:getString(key .. "#specializationPrimary"),
        specializationSecondary = xmlFile:getString(key .. "#specializationSecondary"),
        specializationProgressKey = xmlFile:getString(key .. "#specializationProgressKey"),
        specializationProgressMinutes = xmlFile:getInt(key .. "#specializationProgressMinutes", 0),
        specializationProgresses = self:readSpecializationProgressesFromXML(xmlFile, key),
        trainingLastPeriod = xmlFile:getInt(key .. "#trainingLastPeriod", 0),
        trainingLastYear = xmlFile:getInt(key .. "#trainingLastYear", 0),
        trainingLastSpecialization = xmlFile:getString(key .. "#trainingLastSpecialization"),
        trainingActivePeriod = xmlFile:getInt(key .. "#trainingActivePeriod", 0),
        trainingActiveYear = xmlFile:getInt(key .. "#trainingActiveYear", 0),
        trainingActiveSpecialization = xmlFile:getString(key .. "#trainingActiveSpecialization")
    }

    if person.id == nil or person.id <= 0 then
        return nil
    end

    person.busy = xmlFile:getBool(key .. "#busy", false)
    person.vehicleName = xmlFile:getString(key .. "#vehicleName", "")
    person.vehicleKey = xmlFile:getString(key .. "#vehicleKey")
    person.assignedHelperIndex = xmlFile:getInt(key .. "#assignedHelperIndex")
    person.assignedBaseHelperIndex = xmlFile:getInt(key .. "#assignedBaseHelperIndex")
    person.hiredPeriod = xmlFile:getInt(key .. "#hiredPeriod")
    person.hiredYear = xmlFile:getInt(key .. "#hiredYear")
    person.loyaltyMilestoneMonths = xmlFile:getInt(key .. "#loyaltyMilestoneMonths", 0)
    person.loyaltyTenureMilestoneMonths = xmlFile:getInt(key .. "#loyaltyTenureMilestoneMonths", 0)
    person.nightWorkIngameMinutes = xmlFile:getInt(key .. "#nightWorkIngameMinutes", 0)
    person.nightWorkRealtimeMs = xmlFile:getFloat(key .. "#nightWorkRealtimeMs", 0)
    person.nightWorkLastMinute = xmlFile:getInt(key .. "#nightWorkLastMinute")
    person.loyaltyReputationProgress = xmlFile:getFloat(key .. "#loyaltyReputationProgress", 0)
    person.loyaltyWarningPeriod = xmlFile:getInt(key .. "#loyaltyWarningPeriod", 0)
    person.loyaltyWarningYear = xmlFile:getInt(key .. "#loyaltyWarningYear", 0)
    person.resignationPending = xmlFile:getBool(key .. "#resignationPending", false) == true
    person.dismissalPending = xmlFile:getBool(key .. "#dismissalPending", false) == true
    person.dismissalNoticePeriod = xmlFile:getInt(key .. "#dismissalNoticePeriod", 0)
    person.dismissalNoticeYear = xmlFile:getInt(key .. "#dismissalNoticeYear", 0)
    person.dismissalEffectivePeriod = xmlFile:getInt(key .. "#dismissalEffectivePeriod", 0)
    person.dismissalEffectiveYear = xmlFile:getInt(key .. "#dismissalEffectiveYear", 0)
    person.resignationNoticePeriod = xmlFile:getInt(key .. "#resignationNoticePeriod", 0)
    person.resignationNoticeYear = xmlFile:getInt(key .. "#resignationNoticeYear", 0)
    person.resignationCheckPeriod = xmlFile:getInt(key .. "#resignationCheckPeriod", 0)
    person.resignationCheckYear = xmlFile:getInt(key .. "#resignationCheckYear", 0)
    person.sickPeriod = xmlFile:getInt(key .. "#sickPeriod", 0)
    person.sickYear = xmlFile:getInt(key .. "#sickYear", 0)
    person.sickDay = xmlFile:getInt(key .. "#sickDay", 0)
    person.sicknessPeriod = xmlFile:getInt(key .. "#sicknessPeriod", 0)
    person.sicknessYear = xmlFile:getInt(key .. "#sicknessYear", 0)
    person.sicknessDaysThisPeriod = xmlFile:getInt(key .. "#sicknessDaysThisPeriod", 0)
    person.reliabilityWorkPeriod = xmlFile:getInt(key .. "#reliabilityWorkPeriod", 0)
    person.reliabilityWorkYear = xmlFile:getInt(key .. "#reliabilityWorkYear", 0)
    person.reliabilityWorkMinutesThisPeriod = xmlFile:getInt(key .. "#reliabilityWorkMinutesThisPeriod", 0)
    person.reliabilityIncidentPeriod = xmlFile:getInt(key .. "#reliabilityIncidentPeriod", 0)
    person.reliabilityIncidentYear = xmlFile:getInt(key .. "#reliabilityIncidentYear", 0)
    person.reliabilityIncidentsThisPeriod = xmlFile:getInt(key .. "#reliabilityIncidentsThisPeriod", 0)
    person.reliabilitySicknessPeriod = xmlFile:getInt(key .. "#reliabilitySicknessPeriod", 0)
    person.reliabilitySicknessYear = xmlFile:getInt(key .. "#reliabilitySicknessYear", 0)
    person.reliabilitySicknessDaysThisPeriod = xmlFile:getInt(key .. "#reliabilitySicknessDaysThisPeriod", 0)
    person.reliabilityNightWorkPeriod = xmlFile:getInt(key .. "#reliabilityNightWorkPeriod", 0)
    person.reliabilityNightWorkYear = xmlFile:getInt(key .. "#reliabilityNightWorkYear", 0)
    person.reliabilityNightWorkMinutesThisPeriod = xmlFile:getInt(key .. "#reliabilityNightWorkMinutesThisPeriod", 0)
    person.reliabilityDevelopmentCheckPeriod = xmlFile:getInt(key .. "#reliabilityDevelopmentCheckPeriod", 0)
    person.reliabilityDevelopmentCheckYear = xmlFile:getInt(key .. "#reliabilityDevelopmentCheckYear", 0)
    person.experiencePeriod = xmlFile:getInt(key .. "#experiencePeriod", 0)
    person.experienceYear = xmlFile:getInt(key .. "#experienceYear", 1)
    person.experienceThisPeriod = xmlFile:getInt(key .. "#experienceThisPeriod", 0)
    person.experienceProgressMinutes = xmlFile:getInt(key .. "#experienceProgressMinutes", 0)
    person.jobsCompleted = xmlFile:getInt(key .. "#jobsCompleted", 0)
    person.totalWorkMinutes = xmlFile:getInt(key .. "#totalWorkMinutes", 0)
    person.lastJobMinutes = xmlFile:getInt(key .. "#lastJobMinutes", 0)
    person.totalEarnings = xmlFile:getFloat(key .. "#totalEarnings", 0)
    person.currentJobStartedAt = xmlFile:getFloat(key .. "#currentJobStartedAt", 0)
    person.currentJobElapsedMs = xmlFile:getFloat(key .. "#currentJobElapsedMs", 0)
    person.restorePending = xmlFile:getBool(key .. "#restorePending", false)
    person.restoreVehicleName = xmlFile:getString(key .. "#restoreVehicleName")
    person.restoreVehicleKey = xmlFile:getString(key .. "#restoreVehicleKey")

    return person
end

function HelperPersonnelManager:writePersonToXML(xmlFile, key, person, includeWorkerState)
    if xmlFile == nil or person == nil or person.id == nil then
        return
    end

    xmlFile:setInt(key .. "#id", person.id)
    xmlFile:setString(key .. "#firstName", person.firstName or "")
    xmlFile:setString(key .. "#lastName", person.lastName or "")
    if person.gender ~= nil then
        xmlFile:setString(key .. "#gender", person.gender)
    end
    xmlFile:setInt(key .. "#experience", person.experience or 0)
    xmlFile:setInt(key .. "#reliability", person.reliability or 0)
    xmlFile:setInt(key .. "#loyalty", person.loyalty or HelperPersonnelManager.DEFAULT_LOYALTY)
    xmlFile:setInt(key .. "#avatarIndex", person.avatarIndex or 0)
    xmlFile:setFloat(key .. "#wage", person.wage or 0)
    xmlFile:setFloat(key .. "#baseWage", person.baseWage or person.wage or 0)
    xmlFile:setInt(key .. "#monthsAvailable", person.monthsAvailable or 0)
    if person.specializationPrimary ~= nil then
        xmlFile:setString(key .. "#specializationPrimary", person.specializationPrimary)
    end
    if person.specializationSecondary ~= nil then
        xmlFile:setString(key .. "#specializationSecondary", person.specializationSecondary)
    end
    self:writeSpecializationProgressesToXML(xmlFile, key, person)
    if person.specializationProgressKey ~= nil then
        xmlFile:setString(key .. "#specializationProgressKey", person.specializationProgressKey)
    end
    xmlFile:setInt(key .. "#specializationProgressMinutes", person.specializationProgressMinutes or 0)
    xmlFile:setInt(key .. "#trainingLastPeriod", person.trainingLastPeriod or 0)
    xmlFile:setInt(key .. "#trainingLastYear", person.trainingLastYear or 0)
    if person.trainingLastSpecialization ~= nil then
        xmlFile:setString(key .. "#trainingLastSpecialization", person.trainingLastSpecialization)
    end
    xmlFile:setInt(key .. "#trainingActivePeriod", person.trainingActivePeriod or 0)
    xmlFile:setInt(key .. "#trainingActiveYear", person.trainingActiveYear or 0)
    if person.trainingActiveSpecialization ~= nil then
        xmlFile:setString(key .. "#trainingActiveSpecialization", person.trainingActiveSpecialization)
    end

    if includeWorkerState == true then
        xmlFile:setBool(key .. "#busy", person.busy == true)
        if person.vehicleName ~= nil and person.vehicleName ~= "" then
            xmlFile:setString(key .. "#vehicleName", tostring(person.vehicleName))
        end
        if person.vehicleKey ~= nil and person.vehicleKey ~= "" then
            xmlFile:setString(key .. "#vehicleKey", tostring(person.vehicleKey))
        end
        if person.assignedHelperIndex ~= nil then
            xmlFile:setInt(key .. "#assignedHelperIndex", person.assignedHelperIndex)
        end
        if person.assignedBaseHelperIndex ~= nil then
            xmlFile:setInt(key .. "#assignedBaseHelperIndex", person.assignedBaseHelperIndex)
        end
        if person.hiredPeriod ~= nil then
            xmlFile:setInt(key .. "#hiredPeriod", person.hiredPeriod)
        end
        if person.hiredYear ~= nil then
            xmlFile:setInt(key .. "#hiredYear", person.hiredYear)
        end
        xmlFile:setInt(key .. "#loyaltyMilestoneMonths", person.loyaltyMilestoneMonths or 0)
        xmlFile:setInt(key .. "#loyaltyTenureMilestoneMonths", person.loyaltyTenureMilestoneMonths or 0)
        xmlFile:setInt(key .. "#nightWorkIngameMinutes", person.nightWorkIngameMinutes or 0)
        xmlFile:setFloat(key .. "#nightWorkRealtimeMs", person.nightWorkRealtimeMs or 0)
        if person.nightWorkLastMinute ~= nil then
            xmlFile:setInt(key .. "#nightWorkLastMinute", person.nightWorkLastMinute)
        end
        xmlFile:setFloat(key .. "#loyaltyReputationProgress", person.loyaltyReputationProgress or 0)
        xmlFile:setInt(key .. "#loyaltyWarningPeriod", person.loyaltyWarningPeriod or 0)
        xmlFile:setInt(key .. "#loyaltyWarningYear", person.loyaltyWarningYear or 0)
        xmlFile:setBool(key .. "#resignationPending", person.resignationPending == true)
        xmlFile:setBool(key .. "#dismissalPending", person.dismissalPending == true)
        xmlFile:setInt(key .. "#dismissalNoticePeriod", person.dismissalNoticePeriod or 0)
        xmlFile:setInt(key .. "#dismissalNoticeYear", person.dismissalNoticeYear or 0)
        xmlFile:setInt(key .. "#dismissalEffectivePeriod", person.dismissalEffectivePeriod or 0)
        xmlFile:setInt(key .. "#dismissalEffectiveYear", person.dismissalEffectiveYear or 0)
        xmlFile:setInt(key .. "#resignationNoticePeriod", person.resignationNoticePeriod or 0)
        xmlFile:setInt(key .. "#resignationNoticeYear", person.resignationNoticeYear or 0)
        xmlFile:setInt(key .. "#resignationCheckPeriod", person.resignationCheckPeriod or 0)
        xmlFile:setInt(key .. "#resignationCheckYear", person.resignationCheckYear or 0)
        xmlFile:setInt(key .. "#sickPeriod", person.sickPeriod or 0)
        xmlFile:setInt(key .. "#sickYear", person.sickYear or 0)
        xmlFile:setInt(key .. "#sickDay", person.sickDay or 0)
        xmlFile:setInt(key .. "#sicknessPeriod", person.sicknessPeriod or 0)
        xmlFile:setInt(key .. "#sicknessYear", person.sicknessYear or 0)
        xmlFile:setInt(key .. "#sicknessDaysThisPeriod", person.sicknessDaysThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityWorkPeriod", person.reliabilityWorkPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityWorkYear", person.reliabilityWorkYear or 0)
        xmlFile:setInt(key .. "#reliabilityWorkMinutesThisPeriod", person.reliabilityWorkMinutesThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityIncidentPeriod", person.reliabilityIncidentPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityIncidentYear", person.reliabilityIncidentYear or 0)
        xmlFile:setInt(key .. "#reliabilityIncidentsThisPeriod", person.reliabilityIncidentsThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilitySicknessPeriod", person.reliabilitySicknessPeriod or 0)
        xmlFile:setInt(key .. "#reliabilitySicknessYear", person.reliabilitySicknessYear or 0)
        xmlFile:setInt(key .. "#reliabilitySicknessDaysThisPeriod", person.reliabilitySicknessDaysThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityNightWorkPeriod", person.reliabilityNightWorkPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityNightWorkYear", person.reliabilityNightWorkYear or 0)
        xmlFile:setInt(key .. "#reliabilityNightWorkMinutesThisPeriod", person.reliabilityNightWorkMinutesThisPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityDevelopmentCheckPeriod", person.reliabilityDevelopmentCheckPeriod or 0)
        xmlFile:setInt(key .. "#reliabilityDevelopmentCheckYear", person.reliabilityDevelopmentCheckYear or 0)
        xmlFile:setInt(key .. "#experiencePeriod", person.experiencePeriod or 0)
        xmlFile:setInt(key .. "#experienceYear", person.experienceYear or 1)
        xmlFile:setInt(key .. "#experienceThisPeriod", person.experienceThisPeriod or 0)
        xmlFile:setInt(key .. "#experienceProgressMinutes", person.experienceProgressMinutes or 0)
        xmlFile:setInt(key .. "#jobsCompleted", person.jobsCompleted or 0)
        xmlFile:setInt(key .. "#totalWorkMinutes", person.totalWorkMinutes or 0)
        xmlFile:setInt(key .. "#lastJobMinutes", person.lastJobMinutes or 0)
        xmlFile:setFloat(key .. "#totalEarnings", person.totalEarnings or 0)
        xmlFile:setFloat(key .. "#currentJobStartedAt", person.currentJobStartedAt or 0)
        xmlFile:setFloat(key .. "#currentJobElapsedMs", person.currentJobElapsedMs or 0)
        xmlFile:setBool(key .. "#restorePending", person.restorePending == true)
        if person.restoreVehicleName ~= nil and person.restoreVehicleName ~= "" then
            xmlFile:setString(key .. "#restoreVehicleName", tostring(person.restoreVehicleName))
        end
        if person.restoreVehicleKey ~= nil and person.restoreVehicleKey ~= "" then
            xmlFile:setString(key .. "#restoreVehicleKey", tostring(person.restoreVehicleKey))
        end
    end
end

function HelperPersonnelManager:loadHistoryFromXML(xmlFile, basePath)
    local result = {}
    local index = 0
    while true do
        local key = string.format("%s.entry(%d)", basePath, index)
        if not xmlFile:hasProperty(key) then
            break
        end
        table.insert(result, {
            period = xmlFile:getInt(key .. "#period", 0),
            year = xmlFile:getInt(key .. "#year", 1),
            text = xmlFile:getString(key .. "#text", ""),
            sequence = xmlFile:getInt(key .. "#sequence", index + 1) or (index + 1)
        })
        index = index + 1
    end
    return result
end

function HelperPersonnelManager:writeHistoryToXML(xmlFile, basePath, history)
    history = history or {}
    local maxCount = HelperPersonnelManager.MAX_HISTORY_ENTRIES or 3
    for index = 1, math.min(#history, maxCount) do
        local entry = history[index]
        if entry ~= nil then
            local key = string.format("%s.entry(%d)", basePath, index - 1)
            xmlFile:setInt(key .. "#period", entry.period or 0)
            xmlFile:setInt(key .. "#year", entry.year or 1)
            xmlFile:setString(key .. "#text", entry.text or "")
            xmlFile:setInt(key .. "#sequence", entry.sequence or index)
        end
    end
end

function HelperPersonnelManager:loadFarmDataFromXML(xmlFile, basePath, fallbackFarmId)
    local farmId = xmlFile:getInt(basePath .. "#farmId", fallbackFarmId or self:getFallbackFarmId())
    local data = self:createFarmData(farmId)

    data.employerReputation = xmlFile:getInt(basePath .. "#employerReputation", HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50)
    data.lastActionText = xmlFile:getString(basePath .. "#lastActionText", "")
    data.lastReputationChangeText = xmlFile:getString(basePath .. "#lastReputationChangeText", "")
    data.lastPayrollText = xmlFile:getString(basePath .. "#lastPayrollText", "noch keine Gehaltsabrechnung")
    data.lastPayrollAmount = xmlFile:getFloat(basePath .. "#lastPayrollAmount", 0)
    data.totalPayrollPaid = xmlFile:getFloat(basePath .. "#totalPayrollPaid", 0)
    data.dismissalPeriod = xmlFile:getInt(basePath .. "#dismissalPeriod")
    data.dismissalYear = xmlFile:getInt(basePath .. "#dismissalYear")
    data.monthlyDismissals = xmlFile:getInt(basePath .. "#monthlyDismissals", 0)
    data.lastApplicantPeriod = xmlFile:getInt(basePath .. "#lastApplicantPeriod")
    data.lastApplicantYear = xmlFile:getInt(basePath .. "#lastApplicantYear")
    data.lastLoyaltyDailyCheckMinute = xmlFile:getInt(basePath .. "#lastLoyaltyDailyCheckMinute")
    data.lastSicknessDailyCheckMinute = xmlFile:getInt(basePath .. "#lastSicknessDailyCheckMinute")
    data.sicknessCurrentDay = xmlFile:getInt(basePath .. "#sicknessCurrentDay")
    data.sicknessDayPeriod = xmlFile:getInt(basePath .. "#sicknessDayPeriod")
    data.sicknessDayYear = xmlFile:getInt(basePath .. "#sicknessDayYear")
    data.pendingPayrollLoyaltyDelta = xmlFile:getInt(basePath .. "#pendingPayrollLoyaltyDelta", 0) or 0
    data.applicantMarketInitialized = xmlFile:getBool(basePath .. "#applicantMarketInitialized", false) == true
    data.reputationHistory = self:loadHistoryFromXML(xmlFile, basePath .. ".reputationHistory")
    data.actionHistory = self:loadHistoryFromXML(xmlFile, basePath .. ".actionHistory")
    for _, history in ipairs({ data.reputationHistory or {}, data.actionHistory or {} }) do
        for _, entry in ipairs(history or {}) do
            data.historySequence = math.max(tonumber(data.historySequence) or 0, tonumber(entry.sequence) or 0)
        end
    end

    local index = 0
    while true do
        local key = string.format("%s.workers.worker(%d)", basePath, index)
        if not xmlFile:hasProperty(key) then
            break
        end
        local worker = self:readPersonFromXML(xmlFile, key)
        if worker ~= nil then
            worker.farmId = farmId
            table.insert(data.workers, worker)
            self.nextPersonId = math.max(self.nextPersonId or 1, (worker.id or 0) + 1)
        end
        index = index + 1
    end

    index = 0
    while true do
        local key = string.format("%s.applicants.applicant(%d)", basePath, index)
        if not xmlFile:hasProperty(key) then
            break
        end
        local applicant = self:readPersonFromXML(xmlFile, key)
        if applicant ~= nil then
            applicant.farmId = farmId
            table.insert(data.applicants, applicant)
            self.nextPersonId = math.max(self.nextPersonId or 1, (applicant.id or 0) + 1)
        end
        index = index + 1
    end

    data.saveActiveJobSnapshot = {}
    index = 0
    while true do
        local key = string.format("%s.activeJobs.job(%d)", basePath, index)
        if not xmlFile:hasProperty(key) then
            break
        end
        table.insert(data.saveActiveJobSnapshot, {
            workerId = xmlFile:getInt(key .. "#workerId"),
            vehicleKey = xmlFile:getString(key .. "#vehicleKey"),
            vehicleName = xmlFile:getString(key .. "#vehicleName"),
            helperIndex = xmlFile:getInt(key .. "#helperIndex"),
            baseHelperIndex = xmlFile:getInt(key .. "#baseHelperIndex")
        })
        index = index + 1
    end

    self:ensureInitialApplicantMarketForFarmData(data)

    return data
end

function HelperPersonnelManager:writeFarmDataToXML(xmlFile, basePath, data)
    if data == nil then
        return
    end

    xmlFile:setInt(basePath .. "#farmId", data.farmId or self:getFallbackFarmId())
    xmlFile:setInt(basePath .. "#employerReputation", data.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50)
    xmlFile:setBool(basePath .. "#applicantMarketInitialized", data.applicantMarketInitialized == true)
    xmlFile:setString(basePath .. "#lastActionText", data.lastActionText or "")
    xmlFile:setString(basePath .. "#lastReputationChangeText", data.lastReputationChangeText or "")
    xmlFile:setString(basePath .. "#lastPayrollText", data.lastPayrollText or "noch keine Gehaltsabrechnung")
    xmlFile:setFloat(basePath .. "#lastPayrollAmount", data.lastPayrollAmount or 0)
    xmlFile:setFloat(basePath .. "#totalPayrollPaid", data.totalPayrollPaid or 0)
    if data.dismissalPeriod ~= nil then
        xmlFile:setInt(basePath .. "#dismissalPeriod", data.dismissalPeriod)
    end
    if data.dismissalYear ~= nil then
        xmlFile:setInt(basePath .. "#dismissalYear", data.dismissalYear)
    end
    xmlFile:setInt(basePath .. "#monthlyDismissals", data.monthlyDismissals or 0)
    if data.lastApplicantPeriod ~= nil then
        xmlFile:setInt(basePath .. "#lastApplicantPeriod", data.lastApplicantPeriod)
    end
    if data.lastApplicantYear ~= nil then
        xmlFile:setInt(basePath .. "#lastApplicantYear", data.lastApplicantYear)
    end
    if data.lastLoyaltyDailyCheckMinute ~= nil then
        xmlFile:setInt(basePath .. "#lastLoyaltyDailyCheckMinute", data.lastLoyaltyDailyCheckMinute)
    end
    if data.lastSicknessDailyCheckMinute ~= nil then
        xmlFile:setInt(basePath .. "#lastSicknessDailyCheckMinute", data.lastSicknessDailyCheckMinute)
    end
    if data.sicknessCurrentDay ~= nil then
        xmlFile:setInt(basePath .. "#sicknessCurrentDay", data.sicknessCurrentDay)
    end
    if data.sicknessDayPeriod ~= nil then
        xmlFile:setInt(basePath .. "#sicknessDayPeriod", data.sicknessDayPeriod)
    end
    if data.sicknessDayYear ~= nil then
        xmlFile:setInt(basePath .. "#sicknessDayYear", data.sicknessDayYear)
    end
    xmlFile:setInt(basePath .. "#pendingPayrollLoyaltyDelta", tonumber(data.pendingPayrollLoyaltyDelta) or 0)

    for index, worker in ipairs(data.workers or {}) do
        self:writePersonToXML(xmlFile, string.format("%s.workers.worker(%d)", basePath, index - 1), worker, true)
    end

    for index, applicant in ipairs(data.applicants or {}) do
        self:writePersonToXML(xmlFile, string.format("%s.applicants.applicant(%d)", basePath, index - 1), applicant, false)
    end

    self:writeHistoryToXML(xmlFile, basePath .. ".reputationHistory", data.reputationHistory)
    self:writeHistoryToXML(xmlFile, basePath .. ".actionHistory", data.actionHistory)

    for index, assignment in ipairs(data.saveActiveJobSnapshot or {}) do
        if assignment ~= nil and assignment.workerId ~= nil then
            local key = string.format("%s.activeJobs.job(%d)", basePath, index - 1)
            xmlFile:setInt(key .. "#workerId", assignment.workerId)
            if assignment.vehicleKey ~= nil and assignment.vehicleKey ~= "" then
                xmlFile:setString(key .. "#vehicleKey", tostring(assignment.vehicleKey))
            end
            if assignment.vehicleName ~= nil and assignment.vehicleName ~= "" then
                xmlFile:setString(key .. "#vehicleName", tostring(assignment.vehicleName))
            end
            if assignment.helperIndex ~= nil then
                xmlFile:setInt(key .. "#helperIndex", assignment.helperIndex)
            end
            if assignment.baseHelperIndex ~= nil then
                xmlFile:setInt(key .. "#baseHelperIndex", assignment.baseHelperIndex)
            end
        end
    end
end

function HelperPersonnelManager:loadFromSavegame()
    self:loadConfig()
    self.farms = {}
    self.currentFarmData = nil
    self.activeFarmId = nil

    local savePath = self:getSavegamePath()
    if savePath == nil then
        self:refreshFarmContext()
        return
    end

    local xmlFile = XMLFile.loadIfExists("helperPersonnel", savePath, HelperPersonnelManager.xmlSchema)
    if xmlFile == nil then
        self:refreshFarmContext()
        return
    end

    if xmlFile:hasProperty("helperPersonnel.farms.farm(0)") then
        self.nextPersonId = xmlFile:getInt("helperPersonnel#nextPersonId", 1)
        self.changeCounter = xmlFile:getInt("helperPersonnel#changeCounter", 0)

        local index = 0
        while true do
            local farmKey = string.format("helperPersonnel.farms.farm(%d)", index)
            if not xmlFile:hasProperty(farmKey) then
                break
            end
            local data = self:loadFarmDataFromXML(xmlFile, farmKey, index + 1)
            self.farms[data.farmId] = data
            index = index + 1
        end

        self:resetRestoredActiveJobs()
        for _, farmId in ipairs(self:getSortedFarmIds()) do
            local data = self.farms[farmId]
            if data ~= nil then
                self:bindFarmData(data)
                for _, assignment in ipairs(data.saveActiveJobSnapshot or {}) do
                    self:rememberRestoredActiveJob(assignment)
                end
                self:storeCurrentFarmData()
            end
        end

        local activeFarmId = xmlFile:getInt("helperPersonnel#activeFarmId", self:getCurrentFarmId())
        self:refreshFarmContext(activeFarmId)
        xmlFile:delete()
        self:loadRestoredActiveJobsFromVehiclesXML(savePath)
        self:refreshFarmContext()
        return
    end

    xmlFile:delete()

    if HP_ORIGINAL_MANAGER_LOAD_FROM_SAVEGAME ~= nil then
        HP_ORIGINAL_MANAGER_LOAD_FROM_SAVEGAME(self)
    end

    self:adoptFlatStateAsFarm(self:getCurrentFarmId())
    self:refreshFarmContext()
end

function HelperPersonnelManager:saveToXMLFile(xmlFile)
    if xmlFile == nil then
        return
    end

    self:storeCurrentFarmData()
    self:refreshFarmContext()

    xmlFile:setInt("helperPersonnel#saveVersion", 2)
    xmlFile:setInt("helperPersonnel#nextPersonId", self.nextPersonId or 1)
    xmlFile:setInt("helperPersonnel#changeCounter", self.changeCounter or 0)
    xmlFile:setInt("helperPersonnel#activeFarmId", self.activeFarmId or self:getCurrentFarmId())

    for index, farmId in ipairs(self:getSortedFarmIds()) do
        local data = self.farms[farmId]
        if data ~= nil then
            self:writeFarmDataToXML(xmlFile, string.format("helperPersonnel.farms.farm(%d)", index - 1), data)
        end
    end
end

function HelperPersonnelManager:saveToSavegame()
    self:saveConfig()
    local savePath = self:getSavegamePath()
    if savePath == nil or savePath == "" then
        return
    end

    if createFolder ~= nil then
        local directory = savePath:match("^(.+)/helperPersonnel%.xml$")
        if directory ~= nil and directory ~= "" then
            pcall(createFolder, directory)
        end
    end

    local xmlFile = XMLFile.create("helperPersonnel", savePath, "helperPersonnel", HelperPersonnelManager.xmlSchema)
    if xmlFile == nil then
        Logging.error("HelperPersonnel: Konnte Savegame-XML nicht erstellen: %s", savePath)
        return
    end

    self:saveToXMLFile(xmlFile)
    xmlFile:save()
    xmlFile:delete()

    self.saveBusyWorkerLookup = nil
    self.saveActiveJobSnapshot = nil
    for _, data in pairs(self.farms or {}) do
        if data ~= nil then
            data.saveBusyWorkerLookup = nil
            data.saveActiveJobSnapshot = nil
        end
    end
end

function HelperPersonnelManager:captureSaveSnapshot(activeJobs, getVehicleKeyFunc, helperBridge)
    if HP_ORIGINAL_MANAGER_CAPTURE_SAVE_SNAPSHOT == nil then
        return
    end

    self:refreshFarmContext()
    for _, data in pairs(self.farms or {}) do
        data.saveActiveJobSnapshot = {}
    end

    HP_ORIGINAL_MANAGER_CAPTURE_SAVE_SNAPSHOT(self, activeJobs, getVehicleKeyFunc, helperBridge)

    local snapshot = self.saveActiveJobSnapshot or {}
    for _, assignment in ipairs(snapshot) do
        local workerData = self:findWorkerFarmData(assignment.workerId)
        if workerData ~= nil then
            workerData.saveActiveJobSnapshot = workerData.saveActiveJobSnapshot or {}
            table.insert(workerData.saveActiveJobSnapshot, assignment)
        end
    end

    self:storeCurrentFarmData()
    self:refreshFarmContext()
end

function HelperPersonnelManager:getNetworkState()
    self:storeCurrentFarmData()
    self:refreshFarmContext()

    local state = {
        version = 2,
        nextPersonId = self.nextPersonId or 1,
        changeCounter = self.changeCounter or 0,
        activeFarmId = self.activeFarmId or self:getCurrentFarmId(),
        config = self.config ~= nil and self.config.getNetworkState ~= nil and self.config:getNetworkState() or nil,
        farms = {}
    }

    for _, farmId in ipairs(self:getSortedFarmIds()) do
        local data = self.farms[farmId]
        if data ~= nil then
            table.insert(state.farms, {
                farmId = data.farmId,
                workers = data.workers or {},
                applicants = data.applicants or {},
                employerReputation = data.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50,
                lastActionText = data.lastActionText or "",
                lastReputationChangeText = data.lastReputationChangeText or "",
                lastPayrollText = data.lastPayrollText or "noch keine Gehaltsabrechnung",
                lastPayrollAmount = data.lastPayrollAmount or 0,
                totalPayrollPaid = data.totalPayrollPaid or 0,
                dismissalPeriod = data.dismissalPeriod,
                dismissalYear = data.dismissalYear,
                monthlyDismissals = data.monthlyDismissals or 0,
                lastApplicantPeriod = data.lastApplicantPeriod,
                lastApplicantYear = data.lastApplicantYear,
                lastLoyaltyDailyCheckMinute = data.lastLoyaltyDailyCheckMinute,
                lastSicknessDailyCheckMinute = data.lastSicknessDailyCheckMinute,
                sicknessCurrentDay = data.sicknessCurrentDay,
                sicknessDayPeriod = data.sicknessDayPeriod,
                sicknessDayYear = data.sicknessDayYear,
                pendingPayrollLoyaltyDelta = data.pendingPayrollLoyaltyDelta,
                applicantMarketInitialized = data.applicantMarketInitialized == true,
                reputationHistory = data.reputationHistory or {},
                actionHistory = data.actionHistory or {},
                historySequence = data.historySequence or 0
            })
        end
    end

    return state
end

function HelperPersonnelManager:applyNetworkState(state)
    if state == nil then
        return false
    end

    if self.config ~= nil and self.config.applyNetworkState ~= nil and type(state.config) == "table" then
        self.config:applyNetworkState(state.config)
    end

    self.farms = {}
    self.currentFarmData = nil
    self.activeFarmId = nil
    self.nextPersonId = state.nextPersonId or 1
    self.changeCounter = state.changeCounter or 0

    if state.farms ~= nil then
        for _, farmState in ipairs(state.farms) do
            local farmId = tonumber(farmState.farmId) or self:getFallbackFarmId()
            local data = self:createFarmData(farmId)
            data.workers = farmState.workers or {}
            data.applicants = farmState.applicants or {}
            data.employerReputation = farmState.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50
            data.lastActionText = farmState.lastActionText or ""
            data.lastReputationChangeText = farmState.lastReputationChangeText or ""
            data.lastPayrollText = farmState.lastPayrollText or "noch keine Gehaltsabrechnung"
            data.lastPayrollAmount = farmState.lastPayrollAmount or 0
            data.totalPayrollPaid = farmState.totalPayrollPaid or 0
            data.dismissalPeriod = farmState.dismissalPeriod
            data.dismissalYear = farmState.dismissalYear
            data.monthlyDismissals = farmState.monthlyDismissals or 0
            data.lastApplicantPeriod = farmState.lastApplicantPeriod
            data.lastApplicantYear = farmState.lastApplicantYear
            data.lastLoyaltyDailyCheckMinute = farmState.lastLoyaltyDailyCheckMinute
            data.lastSicknessDailyCheckMinute = farmState.lastSicknessDailyCheckMinute
            data.sicknessCurrentDay = farmState.sicknessCurrentDay
            data.sicknessDayPeriod = farmState.sicknessDayPeriod
            data.sicknessDayYear = farmState.sicknessDayYear
            data.pendingPayrollLoyaltyDelta = farmState.pendingPayrollLoyaltyDelta or 0
            data.applicantMarketInitialized = farmState.applicantMarketInitialized == true
            data.reputationHistory = farmState.reputationHistory or {}
            data.actionHistory = farmState.actionHistory or {}
            data.historySequence = farmState.historySequence or 0

            for _, worker in ipairs(data.workers) do
                worker.farmId = farmId
            end
            for _, applicant in ipairs(data.applicants) do
                applicant.farmId = farmId
            end

            self.farms[farmId] = data
        end
    else

        local farmId = state.activeFarmId or self:getCurrentFarmId()
        local data = self:createFarmData(farmId)
        data.workers = state.workers or {}
        data.applicants = state.applicants or {}
        data.employerReputation = state.employerReputation or HelperPersonnelManager.DEFAULT_EMPLOYER_REPUTATION or 50
        data.lastActionText = state.lastActionText or ""
        data.lastReputationChangeText = state.lastReputationChangeText or ""
        data.lastPayrollText = state.lastPayrollText or "noch keine Gehaltsabrechnung"
        data.lastPayrollAmount = state.lastPayrollAmount or 0
        data.totalPayrollPaid = state.totalPayrollPaid or 0
        data.dismissalPeriod = state.dismissalPeriod
        data.dismissalYear = state.dismissalYear
        data.monthlyDismissals = state.monthlyDismissals or 0
        data.lastApplicantPeriod = state.lastApplicantPeriod
        data.lastApplicantYear = state.lastApplicantYear
        data.lastLoyaltyDailyCheckMinute = state.lastLoyaltyDailyCheckMinute
        data.lastSicknessDailyCheckMinute = state.lastSicknessDailyCheckMinute
        data.sicknessCurrentDay = state.sicknessCurrentDay
        data.sicknessDayPeriod = state.sicknessDayPeriod
        data.sicknessDayYear = state.sicknessDayYear
        data.pendingPayrollLoyaltyDelta = state.pendingPayrollLoyaltyDelta or 0
        data.applicantMarketInitialized = state.applicantMarketInitialized == true or #(data.applicants or {}) > 0 or #(data.workers or {}) > 0
        data.reputationHistory = state.reputationHistory or {}
        data.actionHistory = state.actionHistory or {}
        data.historySequence = state.historySequence or 0
        self.farms[farmId] = data
    end

    self:refreshFarmContext(state.activeFarmId or self:getCurrentFarmId())
    return true
end

local HP_FARM_SCOPED_METHODS = {
    "getApplicantCountText",
    "getWorkerCountText",
    "getApplicantsSorted",
    "getWorkersSorted",
    "getApplicantById",
    "getAvailableWorkers",
    "getWorkerCounts",
    "hireApplicant",
    "dismissWorker",
    "startWorkerJob",
    "finishWorkerJob",
    "setWorkerBusy",
    "isWorkerBusy",
    "isWorkerAvailable",
    "isWorkerSick"
}

for _, methodName in ipairs(HP_FARM_SCOPED_METHODS) do
    local original = HelperPersonnelManager[methodName]
    if original ~= nil then
        HelperPersonnelManager[methodName] = function(self, ...)
            self:refreshFarmContext()
            local result = original(self, ...)
            self:storeCurrentFarmData()
            return result
        end
    end
end

local HP_ORIGINAL_MANAGER_HIRE_APPLICANT = HelperPersonnelManager.hireApplicant
function HelperPersonnelManager:hireApplicantForFarm(applicantId, farmId)
    self:refreshFarmContext(farmId)
    local result = HP_ORIGINAL_MANAGER_HIRE_APPLICANT(self, applicantId)
    self:storeCurrentFarmData()
    self:refreshFarmContext()
    return result
end

local HP_ORIGINAL_MANAGER_DISMISS_WORKER = HelperPersonnelManager.dismissWorker
function HelperPersonnelManager:dismissWorkerForFarm(workerId, farmId)
    self:refreshFarmContext(farmId)
    local result = HP_ORIGINAL_MANAGER_DISMISS_WORKER(self, workerId)
    self:storeCurrentFarmData()
    self:refreshFarmContext()
    return result
end

local HP_MANAGER_GET_CURRENT_FARM_ID_WITHOUT_FORCE = HelperPersonnelManager.getCurrentFarmId
function HelperPersonnelManager:getCurrentFarmId()
    if self.forcedFarmId ~= nil then
        return self.forcedFarmId
    end
    return HP_MANAGER_GET_CURRENT_FARM_ID_WITHOUT_FORCE(self)
end

function HelperPersonnelManager:hireApplicantForFarm(applicantId, farmId)
    self.forcedFarmId = tonumber(farmId) or self:getCurrentFarmId()
    local result = HP_ORIGINAL_MANAGER_HIRE_APPLICANT(self, applicantId)
    self.forcedFarmId = nil
    self:storeCurrentFarmData()
    self:refreshFarmContext()
    return result
end

function HelperPersonnelManager:dismissWorkerForFarm(workerId, farmId)
    self.forcedFarmId = tonumber(farmId) or self:getCurrentFarmId()
    local result = HP_ORIGINAL_MANAGER_DISMISS_WORKER(self, workerId)
    self.forcedFarmId = nil
    self:storeCurrentFarmData()
    self:refreshFarmContext()
    return result
end

function HelperPersonnelManager:executeWithFarmContext(farmId, callback, storeChanges)
    if callback == nil then
        return nil
    end

    local targetFarmId = tonumber(farmId) or self:getCurrentFarmId()
    local previousForcedFarmId = self.forcedFarmId

    self.forcedFarmId = targetFarmId
    self:refreshFarmContext(targetFarmId)

    local results = {pcall(callback)}
    local ok = table.remove(results, 1)

    if storeChanges ~= false then
        self:storeCurrentFarmData()
    end

    self.forcedFarmId = previousForcedFarmId
    if previousForcedFarmId ~= nil then
        self:refreshFarmContext(previousForcedFarmId)
    else
        self:refreshFarmContext()
    end

    if not ok then
        error(results[1], 0)
    end

    local unpackResults = unpack or table.unpack
    return unpackResults(results)
end

function HelperPersonnelManager:processPeriodChangeForFarm(farmId, period, year, forceCheck)
    return self:executeWithFarmContext(farmId, function()
        return self:processApplicantPeriodChange(period, year, forceCheck == true)
    end, true)
end

function HelperPersonnelManager:onPeriodChanged(period, year)
    self:storeCurrentFarmData()

    local processed = false
    self:forEachFarm(function(_, farmId)
        local changed = self:processPeriodChangeForFarm(farmId, period, year, true)
        processed = processed or changed == true
    end)

    self:refreshFarmContext()
    return processed
end

function HelperPersonnelManager:update(dt)
    dt = dt or 0
    local processed = false

    self.loyaltyRuntimeTimerMs = (self.loyaltyRuntimeTimerMs or 0) + dt
    if self.loyaltyRuntimeTimerMs >= (HelperPersonnelManager.LOYALTY_RUNTIME_CHECK_INTERVAL_MS or 1000) then
        local elapsedLoyaltyMs = self.loyaltyRuntimeTimerMs
        self.loyaltyRuntimeTimerMs = 0
        self:storeCurrentFarmData()

        self:forEachFarm(function()
            self:updateLoyaltyRuntimeForCurrentFarm(elapsedLoyaltyMs)
        end)
        processed = true
    end

    self.periodCheckTimerMs = (self.periodCheckTimerMs or 0) + dt

    if self.periodCheckTimerMs >= (HelperPersonnelManager.PERIOD_CHECK_INTERVAL_MS or 1000) then
        self.periodCheckTimerMs = 0
        self:storeCurrentFarmData()

        self:forEachFarm(function(_, farmId)
            local changed = self:processPeriodChangeForFarm(farmId, nil, nil, false)
            processed = processed or changed == true
        end)
    end

    self:refreshFarmContext()
    return processed
end

function HelperPersonnelManager:hireApplicantForFarm(applicantId, farmId)
    return self:executeWithFarmContext(farmId, function()
        if HP_ORIGINAL_MANAGER_HIRE_APPLICANT == nil then
            return false
        end
        return HP_ORIGINAL_MANAGER_HIRE_APPLICANT(self, applicantId)
    end, true)
end

function HelperPersonnelManager:dismissWorkerForFarm(workerId, farmId)
    return self:executeWithFarmContext(farmId, function()
        if HP_ORIGINAL_MANAGER_DISMISS_WORKER == nil then
            return false
        end
        return HP_ORIGINAL_MANAGER_DISMISS_WORKER(self, workerId)
    end, true)
end
