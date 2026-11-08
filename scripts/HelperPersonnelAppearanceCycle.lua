HelperPersonnelAppearanceCycle = {}
HelperPersonnelAppearanceCycle_mt = Class(HelperPersonnelAppearanceCycle)

function HelperPersonnelAppearanceCycle.new(app)
    local self = setmetatable({}, HelperPersonnelAppearanceCycle_mt)
    self.app = app
    if addConsoleCommand ~= nil and g_dedicatedServerInfo == nil then
        addConsoleCommand("pmAussehenStart", "Start appearance cycle: male|female face(1-6) [hair(1-16)] [color(1-24)]", "start", self)
        addConsoleCommand("pmAussehenStop", "Stop appearance cycle and restore the player style", "stop", self)
        self.commandsRegistered = true
    end
    return self
end

function HelperPersonnelAppearanceCycle:delete()
    if self.commandsRegistered and removeConsoleCommand ~= nil then
        removeConsoleCommand("pmAussehenStart")
        removeConsoleCommand("pmAussehenStop")
    end
    if self.run ~= nil then
        self:stop()
    end
end

function HelperPersonnelAppearanceCycle:start(gender, faceArg, hairArg, colorArg)
    if self.run ~= nil then
        return "Aussehen: bereits aktiv oder Wiederherstellung laeuft."
    end
    local mission = g_currentMission
    if mission == nil or mission.missionDynamicInfo == nil or mission.missionDynamicInfo.isMultiplayer ~= false or not mission:getIsServer() then
        return "Aussehen: nur im Einzelspieler verfuegbar."
    end
    local face, hair, color = tonumber(faceArg), tonumber(hairArg or 1), tonumber(colorArg or 1)
    if (gender ~= "male" and gender ~= "female") or face == nil or hair == nil or color == nil or face % 1 ~= 0 or hair % 1 ~= 0 or color % 1 ~= 0 or face < 1 or face > 6 or hair < 1 or hair > 16 or color < 1 or color > 24 then
        return "Verwendung: pmAussehenStart male|female 1-6 [1-16] [1-24]"
    end
    local player = g_localPlayer
    local graphics = player ~= nil and player.graphicsComponent or nil
    local original = graphics ~= nil and graphics:getStyle(true) or nil
    if graphics == nil or original == nil or PlayerStyle == nil or self.app.helperBridge == nil then
        return "Aussehen: Spielfigur noch nicht bereit."
    end
    local source
    local modelPath = gender == "male" and "/playerM/" or "/playerF/"
    for index = 1, 10 do
        local helper = self.app.helperBridge:getBaseHelperByIndex(index)
        local candidate = helper ~= nil and helper.playerStyle or nil
        if candidate ~= nil and type(candidate.xmlFilename) == "string" and candidate.xmlFilename:find(modelPath, 1, true) ~= nil then
            source = candidate
            break
        end
    end
    if source == nil then
        return "Aussehen: passende Figurenkonfiguration nicht gefunden."
    end
    local style = PlayerStyle.new()
    style:copyFrom(source)
    style:loadConfigurationIfRequired()
    local originalCopy = PlayerStyle.new()
    originalCopy:copyFrom(original)
    originalCopy:loadConfigurationIfRequired()
    local faceName = string.format("head%02d", face)
    if not style.isConfigurationLoaded or not originalCopy.isConfigurationLoaded or style.configs.face.itemsByName[faceName] == nil then
        return "Aussehen: Figurenkonfiguration konnte nicht geladen werden."
    end
    self.run = {player = player, graphics = graphics, original = originalCopy, style = style, gender = gender, face = faceName, hair = hair, color = color, elapsed = 3000, loading = false, stopping = false}
    return string.format("Aussehen gestartet: %s %s; Stopp: pmAussehenStop", gender, faceName)
end

function HelperPersonnelAppearanceCycle:stop()
    local run = self.run
    if run == nil then
        return "Aussehen: kein Durchlauf aktiv."
    end
    run.stopping = true
    if not run.loading then
        self:restore()
    end
    return "Aussehen: Wiederherstellung angefordert."
end

function HelperPersonnelAppearanceCycle:restore()
    local run = self.run
    if run == nil or run.restoring then
        return
    end
    run.restoring = true
    run.loading = true
    run.elapsed = 0
    run.graphics:setStyleAsync(run.original, self.onRestored, self, nil, true, nil, true)
end

function HelperPersonnelAppearanceCycle:onRestored(loadingState)
    local run = self.run
    if run == nil or not run.restoring then
        return
    end
    if loadingState ~= HumanModelLoadingState.OK then
        Logging.warning("[PersonnelManagement] Appearance restoration failed; reload the savegame.")
    else
        Logging.info("[PersonnelManagement] Appearance cycle: original style restored.")
    end
    self.run = nil
end

function HelperPersonnelAppearanceCycle:onVariantLoaded(loadingState)
    local run = self.run
    if run == nil or run.restoring then
        return
    end
    run.loading = false
    run.elapsed = 0
    if loadingState ~= HumanModelLoadingState.OK then
        Logging.warning("[PersonnelManagement] Appearance variant failed; restoring original style.")
        run.stopping = true
    else
        Logging.info("[PersonnelManagement] Appearance: %s face=%s hair=hair%02d color=%d", run.gender, run.face, run.currentHair, run.currentColor)
    end
    if run.stopping then
        self:restore()
    end
end

function HelperPersonnelAppearanceCycle:draw()
    local run = self.run
    if run == nil or run.loading or run.stopping or run.currentHair == nil then
        return
    end
    local label = string.format("%s | %s | hair%02d | color %02d", run.gender, run.face, run.currentHair, run.currentColor)
    setTextAlignment(RenderText.ALIGN_CENTER)
    setTextBold(true)
    setTextColor(0, 0, 0, 1)
    renderText(0.501, 0.934, 0.025, label)
    setTextColor(1, 1, 1, 1)
    renderText(0.5, 0.936, 0.025, label)
    setTextBold(false)
    setTextAlignment(RenderText.ALIGN_LEFT)
    setTextColor(1, 1, 1, 1)
end

function HelperPersonnelAppearanceCycle:update(dt)
    local run = self.run
    if run == nil then
        return
    end
    if g_localPlayer ~= run.player then
        Logging.warning("[PersonnelManagement] Appearance cycle stopped: player changed; reload if needed.")
        self.run = nil
        return
    end
    run.elapsed = run.elapsed + dt
    if run.loading then
        if run.elapsed >= 30000 and not run.timeoutReported then
            Logging.warning("[PersonnelManagement] Appearance loading did not complete; stop the cycle and reload if necessary.")
            run.timeoutReported = true
        end
        return
    end
    if run.elapsed < 3000 then
        return
    end
    if run.finished then
        self:stop()
        return
    end
    local configs = run.style.configs
    local hairName = string.format("hair%02d", run.hair)
    if configs.hairStyle.itemsByName[hairName] == nil then
        Logging.warning("[PersonnelManagement] Appearance missing %s; restoring original style.", hairName)
        self:stop()
        return
    end
    configs.face:setSelectedItemName(run.face)
    configs.hairStyle:setSelectedItemName(hairName)
    configs.hairStyle:setSelectedColorIndex(run.color)
    local beardName = "stubble_" .. run.face
    if configs.beard.itemsByName[beardName] ~= nil then
        configs.beard:setSelectedItemName(beardName)
    end
    run.style:updateDisabledOptions()
    run.currentHair = run.hair
    run.currentColor = run.color
    run.loading = true
    run.elapsed = 0
    run.graphics:setStyleAsync(run.style, self.onVariantLoaded, self, nil, true, nil, true)
    run.hair = run.hair + 1
    if run.hair > 16 then
        run.hair = 1
        run.color = run.color + 1
        if run.color > 24 then
            run.finished = true
        end
    end
end
