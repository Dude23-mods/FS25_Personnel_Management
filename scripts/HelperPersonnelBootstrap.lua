HelperPersonnel = HelperPersonnel or {}
HelperPersonnel.DEBUG_LOGGING = false

function HelperPersonnel.debugInfo(message, ...)
    if HelperPersonnel.DEBUG_LOGGING == true and Logging ~= nil and Logging.info ~= nil then
        Logging.info(message, ...)
    end
end

source(g_currentModDirectory .. "gui/HelperPersonnelViewBase.lua")
source(g_currentModDirectory .. "gui/HelperPersonnelMenuPage.lua")
source(g_currentModDirectory .. "gui/HelperPersonnelMenuFrames.lua")
source(g_currentModDirectory .. "gui/HelperPersonnelInGameMenu.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelConfig.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelGameSettings.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelManager.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelNetwork.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelHelperBridge.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelSelectionOverlay.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelApp.lua")
source(g_currentModDirectory .. "scripts/hooks/AIStartHooks.lua")
source(g_currentModDirectory .. "scripts/hooks/AIJobHooks.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelMultiplayerSync.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelTransportAssignments.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelSalaryRaiseRequests.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelExperienceEffects.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelCompatibility.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelCourseplayCompatibility.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelAutoDriveCompatibility.lua")
source(g_currentModDirectory .. "scripts/HelperPersonnelStandaloneMenu.lua")

HelperPersonnelBootstrap = {}
HelperPersonnelBootstrap.modName = g_currentModName
HelperPersonnelBootstrap.modDir = g_currentModDirectory
HelperPersonnelBootstrap.mission00Loaded = false

function HelperPersonnelBootstrap.install()
    if HelperPersonnelBootstrap.isInstalled then
        return
    end

    HelperPersonnelBootstrap.isInstalled = true

    if HelperPersonnelCompatibility ~= nil and HelperPersonnelCompatibility.install ~= nil then
        HelperPersonnelCompatibility.install()
    end

    HelperPersonnelAIStartHooks.install("bootstrap")
    HelperPersonnelAIJobHooks.install("bootstrap")
    HelperPersonnelExperienceEffects.install()
    HelperPersonnelCourseplayCompatibility.install("bootstrap")
    HelperPersonnelAutoDriveCompatibility.install("bootstrap")

    FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, HelperPersonnelBootstrap.onBeforeLoadMapFinished)
    FSBaseMission.loadMapFinished = Utils.appendedFunction(FSBaseMission.loadMapFinished, HelperPersonnelBootstrap.onLoadMapFinished)
    FSBaseMission.saveSavegame = Utils.prependedFunction(FSBaseMission.saveSavegame, HelperPersonnelBootstrap.onBeforeSaveSavegame)
    FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, HelperPersonnelBootstrap.onSaveSavegame)
    BaseMission.delete = Utils.prependedFunction(BaseMission.delete, HelperPersonnelBootstrap.onBeforeMissionDelete)
    BaseMission.delete = Utils.appendedFunction(BaseMission.delete, HelperPersonnelBootstrap.onMissionDelete)

    if BaseMission ~= nil and BaseMission.mouseEvent ~= nil then
        BaseMission.mouseEvent = Utils.appendedFunction(BaseMission.mouseEvent, HelperPersonnelBootstrap.onMouseEvent)
    end


    if Mission00 ~= nil and Mission00.loadMission00Finished ~= nil then
        Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, HelperPersonnelBootstrap.onMissionLoaded)
    end
end

function HelperPersonnelBootstrap.isMissionReadyForApp()
    if g_currentMission == nil then
        return false
    end

    local missionInfo = g_currentMission.missionInfo
    if missionInfo == nil then
        return false
    end

    if missionInfo.savegameDirectory ~= nil and missionInfo.savegameDirectory ~= "" then
        return true
    end

    if missionInfo.savegameIndex ~= nil then
        return false
    end

    if missionInfo.isValid ~= false then
        return true
    end

    return false
end

function HelperPersonnelBootstrap.ensureAppLoaded()
    if g_currentMission == nil then
        return false
    end

    if g_helperPersonnelApp ~= nil then
        return true
    end

    if not HelperPersonnelBootstrap.isMissionReadyForApp() then
        return false
    end

    g_helperPersonnelApp = HelperPersonnelApp.new(HelperPersonnelBootstrap.modName, HelperPersonnelBootstrap.modDir)
    g_helperPersonnelApp:load()

    return true
end

function HelperPersonnelBootstrap.onBeforeLoadMapFinished(mission)
    HelperPersonnelBootstrap.ensureAppLoaded()
end

function HelperPersonnelBootstrap.onLoadMapFinished(mission)
    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.install ~= nil then
        HelperPersonnelAIStartHooks.install("loadMapFinished")
    end
    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.install ~= nil then
        HelperPersonnelAIJobHooks.install("loadMapFinished")
    end
    if HelperPersonnelCompatibility ~= nil and HelperPersonnelCompatibility.installFollowMeHooks ~= nil then
        HelperPersonnelCompatibility.installFollowMeHooks("loadMapFinished")
    end
    HelperPersonnelCourseplayCompatibility.install("loadMapFinished")
    HelperPersonnelAutoDriveCompatibility.install("loadMapFinished")

    HelperPersonnelBootstrap.ensureAppLoaded()

    if HelperPersonnelBootstrap.mission00Loaded == true
        and g_helperPersonnelApp ~= nil
        and g_helperPersonnelApp.onMission00Loaded ~= nil then
        g_helperPersonnelApp:onMission00Loaded()
    end

    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.restoreActiveAIJobs ~= nil then
        g_helperPersonnelApp:restoreActiveAIJobs()
    end
end

function HelperPersonnelBootstrap.onBeforeSaveSavegame(mission)
    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.prepareSaveSnapshot ~= nil then
        g_helperPersonnelApp:prepareSaveSnapshot()
    end
end

function HelperPersonnelBootstrap.onSaveSavegame(mission)
    if g_helperPersonnelApp ~= nil then
        g_helperPersonnelApp:save()
    end
end

function HelperPersonnelBootstrap.onMissionLoaded(mission)
    HelperPersonnelBootstrap.mission00Loaded = true

    if HelperPersonnelAIStartHooks ~= nil and HelperPersonnelAIStartHooks.install ~= nil then
        HelperPersonnelAIStartHooks.install("mission00Loaded")
    end
    if HelperPersonnelAIJobHooks ~= nil and HelperPersonnelAIJobHooks.install ~= nil then
        HelperPersonnelAIJobHooks.install("mission00Loaded")
    end
    if HelperPersonnelCompatibility ~= nil and HelperPersonnelCompatibility.installFollowMeHooks ~= nil then
        HelperPersonnelCompatibility.installFollowMeHooks("mission00Loaded")
    end
    HelperPersonnelCourseplayCompatibility.install("mission00Loaded")
    HelperPersonnelAutoDriveCompatibility.install("mission00Loaded")

    HelperPersonnelBootstrap.ensureAppLoaded()

    if g_helperPersonnelApp ~= nil then
        g_helperPersonnelApp:onMission00Loaded()
    end
end

function HelperPersonnelBootstrap.onBeforeMissionDelete(mission)
    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.beginMissionDelete ~= nil then
        g_helperPersonnelApp:beginMissionDelete()
    end
end

function HelperPersonnelBootstrap.onMissionDelete(mission)
    if g_helperPersonnelApp ~= nil then
        g_helperPersonnelApp:delete()
        g_helperPersonnelApp = nil
    end
    if HelperPersonnelAutoDriveCompatibility ~= nil and HelperPersonnelAutoDriveCompatibility.resetState ~= nil then
        HelperPersonnelAutoDriveCompatibility.resetState()
    end
end

function HelperPersonnelBootstrap.onMouseEvent(mission, posX, posY, isDown, isUp, button)
    if g_helperPersonnelApp ~= nil and g_helperPersonnelApp.mouseEvent ~= nil then
        g_helperPersonnelApp:mouseEvent(posX, posY, isDown, isUp, button)
    end
end

HelperPersonnelBootstrap.install()
