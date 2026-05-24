-- Keybind nativo WoW (aparece em Key Bindings > RareTracker-SW)
BINDING_HEADER_RTSW = "RareTracker-SW"
BINDING_NAME_RTSW_TOGGLE = "Abrir/Fechar Menu"

function RTSW_TOGGLE()
    RareTrackerSW_MenuHandler("")
end
-- RareTracker-SW Core Logic
RTSW_VERSION = "1.3.2"
RareTrackerSW_Timers = RareTrackerSW_Timers or {}
RareTrackerSW_Killers = RareTrackerSW_Killers or {}
RareTrackerSW_DB = RareTrackerSW_DB or {}
if RareTrackerSW_ChatEnabled    == nil then RareTrackerSW_ChatEnabled    = false end
if RareTrackerSW_AlertEnabled   == nil then RareTrackerSW_AlertEnabled   = true end
if RareTrackerSW_SoundEnabled   == nil then RareTrackerSW_SoundEnabled   = true end
if RareTrackerSW_ShowDeadOnMap  == nil then RareTrackerSW_ShowDeadOnMap  = true end
if RareTrackerSW_HideAllied     == nil then RareTrackerSW_HideAllied     = false end

local function RTSW_Chat(msg)
    if RareTrackerSW_ChatEnabled ~= false then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end
RareTrackerSW = CreateFrame("Frame", "RareTrackerSWFrame")


function RareTrackerSW_OnEvent()
    if not event then return end

    if event == "VARIABLES_LOADED" then
        if not RareTrackerSW_Timers then RareTrackerSW_Timers = {} end
        RareTrackerSW:BuildLookup()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RareTracker-SW]|r v" .. RTSW_VERSION .. " carregado! |cffaaaaaa/rt para abrir|r")

    elseif event == "UPDATE_MOUSEOVER_UNIT" or event == "PLAYER_TARGET_CHANGED" then
        local unit = (event == "UPDATE_MOUSEOVER_UNIT") and "mouseover" or "target"
        if UnitExists(unit) then
            local targetName = UnitName(unit)
            local classification = UnitClassification(unit)
            local isRareDB, zone = RareTrackerSW:IsRare(targetName)

            if isRareDB or classification == "rare" or classification == "rareelite" then
                if UnitIsDead(unit) then
                    RareTrackerSW:RecordDeath(targetName)
                else
                    RareTrackerSW_AlertCooldowns = RareTrackerSW_AlertCooldowns or {}
                    local lastAlert = RareTrackerSW_AlertCooldowns[targetName] or 0
                    if GetTime() > lastAlert then
                        if RareTrackerSW_Alert and RareTrackerSW_Alert.ShowAlert then
                            RareTrackerSW_Alert:ShowAlert(targetName)
                            RareTrackerSW_AlertCooldowns[targetName] = GetTime() + 600
                        end
                    end
                end
            end
        end

    elseif event == "CHAT_MSG_ADDON" then
        RareTrackerSW:OnSync(arg1, arg2, arg3, arg4)
    end
end

function RareTrackerSW:GetNormalizedZone(zone)
    if not zone then return nil end
    local mapping = {
        ["Montanhas Cristarrubra"] = "Redridge Mountains",
        ["Terras Pestilentas Ocidentais"] = "Western Plaguelands",
        ["Terras Pestilentas Orientais"] = "Eastern Plaguelands",
        ["Estepes Ardentes"] = "Burning Steppes",
        ["Garganta de Fogo"] = "Searing Gorge",
        ["Pantano das Magoas"] = "Swamp of Sorrows",
        ["Barreira do Inferno"] = "Blasted Lands",
        ["Cratera de Un'Goro"] = "Un'Goro Crater",
        ["Selva de Stranglethorn"] = "Stranglethorn Vale",
        ["Selva de Espinhaco"] = "Stranglethorn Vale",
        ["Deserto de Tanaris"] = "Tanaris",
        ["Baldios"] = "The Barrens",
        ["Durotar"] = "Durotar",
        ["Mulgore"] = "Mulgore",
        ["Clareiras de Tirisfal"] = "Tirisfal Glades",
        ["Floresta de Elwynn"] = "Elwynn Forest",
        ["Dun Morogh"] = "Dun Morogh",
        ["Loch Modan"] = "Loch Modan",
        ["Montanhas de Alterac"] = "Alterac Mountains",
        ["Vale de Alterac"] = "Alterac Valley",
        ["Bacia de Arathi"] = "Arathi Basin",
        ["Planalto Arathi"] = "Arathi Highlands",
        ["Espinhaco de Hyjal"] = "Hyjal",
        ["Azshara"] = "Azshara",
        ["Hibernia"] = "Winterspring",
        ["Silithus"] = "Silithus",
        ["Feralas"] = "Feralas",
        ["Tanaris"] = "Tanaris",
        ["Mil Agulhas"] = "Thousand Needles",
        ["Desolacao"] = "Desolace",
        ["Serras de Wertermere"] = "Stonetalon Mountains",
        ["Pantano de Vadeco"] = "Dustwallow Marsh",
        ["Mar de Erguida"] = "The Great Sea",
        ["The Hinterlands"] = "The Hinterlands",
        ["Hinterlands"] = "The Hinterlands",
    }
    return mapping[zone] or zone
end

RareTrackerSW_Lookup = {}

function RareTrackerSW:BuildLookup()
    RareTrackerSW_Lookup = {}
    if not RareTrackerSW_Data then return end
    for zone, mobs in pairs(RareTrackerSW_Data) do
        for mobName, _ in pairs(mobs) do
            RareTrackerSW_Lookup[string.lower(mobName)] = { zone = zone, name = mobName }
        end
    end
    if RareTrackerSW_DB then
        for zone, mobs in pairs(RareTrackerSW_DB) do
            for mobName, _ in pairs(mobs) do
                RareTrackerSW_Lookup[string.lower(mobName)] = { zone = zone, name = mobName }
            end
        end
    end
end


function RareTrackerSW:GetGroupMembers()
    local members = {}
    local playerName = UnitName("player")
    if playerName then members[playerName] = true end

    local raidCount = GetNumRaidMembers and GetNumRaidMembers() or 0
    local partyCount = GetNumPartyMembers and GetNumPartyMembers() or 0

    if raidCount > 0 then
        for i = 1, raidCount do
            local name = UnitName("raid"..i)
            if name then members[name] = true end
        end
    elseif partyCount > 0 then
        for i = 1, partyCount do
            local name = UnitName("party"..i)
            if name then members[name] = true end
        end
    end

    local list = {}
    for name in pairs(members) do table.insert(list, name) end
    table.sort(list)
    return list
end

function RareTrackerSW:IsRare(name)
    if not name then return false end
    local found = RareTrackerSW_Lookup[string.lower(name)]
    if found then
        return true, found.zone, found.name
    end
    return false
end

function RareTrackerSW:ConvertRespawnToSeconds(str)
    if not str or str == "" or str == "---" or str == "---" then return 0 end

    local _, _, valStr = string.find(str, "([%d%.]+)")
    local val = tonumber(valStr) or 0
    if val == 0 then return 0 end

    if string.find(str, "dia") then
        return val * 86400
    elseif string.find(str, "h") then
        return val * 3600
    elseif string.find(str, "min") then
        return val * 60
    end

    return val
end

function RareTrackerSW:RecordDeath(name, fromSync, killer, isManual)
    if not RareTrackerSW_Timers then RareTrackerSW_Timers = {} end
    if not RareTrackerSW_Killers then RareTrackerSW_Killers = {} end

    local isRare, zone, realName = RareTrackerSW:IsRare(name)
    if isRare then
        name = realName
        if RareTrackerSW_Timers[name] and RareTrackerSW_Timers[name] > time() and not fromSync then
            return
        end

        local killerStr
        if isManual then
            killerStr = nil
        elseif not fromSync then
            local groupMembers = RareTrackerSW:GetGroupMembers()
            if table.getn(groupMembers) > 1 then
                table.sort(groupMembers)
                killerStr = table.concat(groupMembers, ",")
            else
                killerStr = killer or UnitName("player") or "?"
            end
        else
            killerStr = killer or "?"
        end
        if killerStr then
            RareTrackerSW_Killers[name] = killerStr
        end

        local mobData = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]) or
                        (RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][name])

        local seconds = 0
        if mobData then
            seconds = RareTrackerSW:ConvertRespawnToSeconds(mobData.respawn)
        end

        if seconds > 0 then
            -- Morte manual: CD pela metade (não sabemos quando realmente morreu)
            local timerSeconds = isManual and math.floor(seconds / 2) or seconds
            RareTrackerSW_Timers[name] = time() + timerSeconds
        else
            local timerSeconds = isManual and 1800 or 3600
            RareTrackerSW_Timers[name] = time() + timerSeconds
        end

        -- Preparar detecção de loot para kills reais (não manual, não sync)
        if not isManual and not fromSync then
            RTSW_LastKilledRare = name
            RTSW_LastKilledTime = GetTime()
        end

        if not fromSync then
            local msgType = isManual and "MANUALDEATH" or "DEATH"
            SendAddonMessage("RTSW", msgType..":"..name..":"..RareTrackerSW_Timers[name], "GUILD")
            if RareTrackerSW_Sync and RareTrackerSW_Sync.SendDeath then
                RareTrackerSW_Sync:SendDeath(name, RareTrackerSW_Timers[name], killerStr)
            end
        end

        if RareTrackerSW_Menu and RareTrackerSW_Menu:IsShown() then
            local currentZone = GetRealZoneText()
            currentZone = RareTrackerSW:GetNormalizedZone(currentZone)
            RareTrackerSW_Menu:ShowZoneDetails(currentZone)
        end
    end
end

function RareTrackerSW:OnSync(prefix, msg, channel, sender)
    if not msg or prefix ~= "RTSW" then return end
    if sender == UnitName("player") then return end

    local isManualSync = string.find(msg, "^MANUALDEATH:") ~= nil
    local _, _, name, t = string.find(msg, "[A-Z]+DEATH:(.+):(%d+)")
    if name and t then
        local timer = tonumber(t)
        if not RareTrackerSW_Timers[name] or timer > RareTrackerSW_Timers[name] then
            RareTrackerSW_Timers[name] = timer
            if not RareTrackerSW_Killers then RareTrackerSW_Killers = {} end
            -- Morte manual recebida: não atribuir como kill do sender
            if not isManualSync then
                RareTrackerSW_Killers[name] = sender
            end

            -- Notificar no chat (via guilda/addon message)
            local respawnStr = "?"
            local isRare2, zone2 = RareTrackerSW:IsRare(name)
            if isRare2 and zone2 then
                local md = (RareTrackerSW_Data[zone2] and RareTrackerSW_Data[zone2][name]) or
                           (RareTrackerSW_DB and RareTrackerSW_DB[zone2] and RareTrackerSW_DB[zone2][name])
                if md then respawnStr = md.respawn or "?" end
            end
            RTSW_Chat("|cff00ffff[RT Sync]|r |cffff8000" .. name .. "|r morto por |cff00ff00" .. sender .. "|r! Respawn: |cffffff00" .. respawnStr .. "|r")

            if RareTrackerSW_Menu and RareTrackerSW_Menu:IsShown() then
                local currentZone = GetRealZoneText()
                currentZone = RareTrackerSW:GetNormalizedZone(currentZone)
                RareTrackerSW_Menu:ShowZoneDetails(currentZone)
            end
            if RareTrackerSW_Map and RareTrackerSW_Map.UpdateWorldMap then
                RareTrackerSW_Map:UpdateWorldMap()
            end
        end
    end
end

RareTrackerSW:SetScript("OnEvent", RareTrackerSW_OnEvent)
RareTrackerSW:RegisterEvent("VARIABLES_LOADED")
RareTrackerSW:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
RareTrackerSW:RegisterEvent("PLAYER_TARGET_CHANGED")
RareTrackerSW:RegisterEvent("CHAT_MSG_ADDON")

function RareTrackerSW:AddCurrentTargetToDB()
    if not UnitExists("target") then return end

    local name = UnitName("target")
    local classification = UnitClassification("target")
    if classification ~= "rare" and classification ~= "rareelite" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[RT]|r O alvo nao e um monstro raro!")
        return
    end

    local zone = GetRealZoneText()
    zone = RareTrackerSW:GetNormalizedZone(zone)
    local x, y = GetPlayerMapPosition("player")

    if x == 0 and y == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[RT]|r Erro: Abra o mapa uma vez para calibrar as coordenadas!")
        return
    end

    if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
    if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end

    local existing = RareTrackerSW_DB[zone][name]
    if existing then
        -- Migrar formato antigo (x,y único) para spawns array
        if not existing.spawns then
            existing.spawns = {}
            if existing.x and existing.y then
                table.insert(existing.spawns, {x=existing.x, y=existing.y})
                existing.x, existing.y = nil, nil
            end
        end
        -- Adicionar novo ponto de spawn se não for duplicata
        local isDup = false
        for _, sp in ipairs(existing.spawns) do
            if math.abs(sp.x - x) < 0.005 and math.abs(sp.y - y) < 0.005 then
                isDup = true; break
            end
        end
        if not isDup then
            table.insert(existing.spawns, {x=x, y=y})
        end
    else
        RareTrackerSW_DB[zone][name] = {
            level   = UnitLevel("target"),
            type    = classification,
            respawn = "15.0 h",
            id      = "0",
            faction = "N",
            custom  = true,
            spawns  = { {x=x, y=y} },
        }
    end

    local coords = string.format("%.1f, %.1f", x*100, y*100)
    local spawnCount = existing and existing.spawns and table.getn(existing.spawns) or 1
    RTSW_Chat("|cff00ff00[RT]|r " .. name .. " spawn salvo em " .. zone .. " (" .. coords .. ") — total: " .. spawnCount .. " ponto(s)")

    RareTrackerSW:BuildLookup()

    -- Compartilhar com outros jogadores
    if RareTrackerSW_Sync and RareTrackerSW_Sync.SendFound then
        RareTrackerSW_Sync:SendFound(name, x, y)
    end

    if RareTrackerSW_Map and RareTrackerSW_Map.UpdateWorldMap then
        RareTrackerSW_Map:UpdateWorldMap()
    end
end


function RareTrackerSW:UpdateMobPosition(name, zone)
    local x, y = GetPlayerMapPosition("player")
    if x == 0 and y == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[RT]|r Abra o mapa uma vez para calibrar as coordenadas!")
        return
    end

    local mobData = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]) or
                    (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][name])

    if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
    if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end

    if RareTrackerSW_DB[zone][name] then
        RareTrackerSW_DB[zone][name].x = x
        RareTrackerSW_DB[zone][name].y = y
    elseif mobData then
        RareTrackerSW_DB[zone][name] = {
            level = mobData.level,
            type = mobData.type,
            respawn = mobData.respawn,
            x = x,
            y = y,
            id = mobData.id,
            faction = mobData.faction or "N",
        }
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[RT]|r Mob nao encontrado no banco!")
        return
    end

    local coords = string.format("%.1f, %.1f", x*100, y*100)
    RTSW_Chat("|cff00ff00[RT]|r " .. name .. " posicao salva em " .. coords)

    -- Compartilhar posicao com outros jogadores
    if RareTrackerSW_Sync and RareTrackerSW_Sync.SendFound then
        RareTrackerSW_Sync:SendFound(name, x, y)
    end

    RareTrackerSW:BuildLookup()
    if RareTrackerSW_Map and RareTrackerSW_Map.UpdateWorldMap then
        RareTrackerSW_Map:UpdateWorldMap()
    end
end

-- ============================================================
-- DETECCAO DE MORTE EM TEMPO REAL (sem precisar de mouseover)
-- ============================================================
RTSW_ActiveRare = nil

local RTSW_DeathFrame = CreateFrame("Frame")
RTSW_DeathFrame:RegisterEvent("UNIT_DIED")
RTSW_DeathFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
RTSW_DeathFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RTSW_DeathFrame:SetScript("OnEvent", function()
    if event == "UPDATE_MOUSEOVER_UNIT" or event == "PLAYER_TARGET_CHANGED" then
        local unit = (event == "UPDATE_MOUSEOVER_UNIT") and "mouseover" or "target"
        if UnitExists(unit) and not UnitIsPlayer(unit) then
            local name = UnitName(unit)
            local cls  = UnitClassification(unit)
            local isRare = RareTrackerSW and RareTrackerSW.IsRare and RareTrackerSW:IsRare(name)
            if isRare or cls == "rare" or cls == "rareelite" then
                local _, _, rn = RareTrackerSW:IsRare(name)
                if not UnitIsDead(unit) then
                    RTSW_ActiveRare = rn or name
                    if RareTrackerSW_Map and RareTrackerSW_Map.ShowTargetPin then
                        RareTrackerSW_Map:ShowTargetPin(RTSW_ActiveRare)
                    end
                elseif SUPERWOW_VERSION and CanLootUnit and CanLootUnit(unit) then
                    -- (4) Cadáver lootável de raro: registrar morte se ainda não registrada
                    local realName = rn or name
                    local timer = RareTrackerSW_Timers and RareTrackerSW_Timers[realName] or 0
                    if timer < time() then
                        RareTrackerSW:RecordDeath(realName)
                        RTSW_Chat("|cff00ffff[RareTracker]|r Cadaver de |cffff8000" .. realName .. "|r encontrado. Registrando morte...")
                    end
                end
            else
                if RTSW_ActiveRare then
                    RTSW_ActiveRare = nil
                    if RareTrackerSW_Map and RareTrackerSW_Map.HideTargetPin then
                        RareTrackerSW_Map:HideTargetPin()
                    end
                end
            end
        else
            if RTSW_ActiveRare then
                RTSW_ActiveRare = nil
                if RareTrackerSW_Map and RareTrackerSW_Map.HideTargetPin then
                    RareTrackerSW_Map:HideTargetPin()
                end
            end
        end

    elseif event == "UNIT_DIED" then
        if RTSW_ActiveRare and RareTrackerSW and RareTrackerSW.RecordDeath then
            local deadName = UnitName("target")
            if deadName then
                local _, _, rn = RareTrackerSW:IsRare(deadName)
                if (rn or deadName) == RTSW_ActiveRare then
                    RareTrackerSW:RecordDeath(RTSW_ActiveRare)
                    RTSW_Chat("|cff00ffff[RareTracker]|r |cffff8000" .. RTSW_ActiveRare .. "|r morto! Sincronizando...")
                    RTSW_ActiveRare = nil
                    if RareTrackerSW_Map and RareTrackerSW_Map.HideTargetPin then
                        RareTrackerSW_Map:HideTargetPin()
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- SUPERWOW ENHANCEMENTS (1) (2) (3) — só carrega se SuperWoW ativo
-- ============================================================
if SUPERWOW_VERSION then

    local RTSW_SW = CreateFrame("Frame")
    RTSW_SW:RegisterEvent("RAW_COMBATLOG")  -- (1) morte passiva
    RTSW_SW:RegisterEvent("UNIT_CASTEVENT") -- (2) detecção por cast
    RTSW_SW:RegisterEvent("PLAYER_TARGET_CHANGED")   -- (3) TrackUnit
    RTSW_SW:RegisterEvent("UPDATE_MOUSEOVER_UNIT")   -- (3) TrackUnit

    RTSW_SW:SetScript("OnEvent", function()

        -- (1) RAW_COMBATLOG: detectar morte de raro sem precisar estar com ele targetado
        if event == "RAW_COMBATLOG" and arg1 == "UNIT_DIED" and arg2 then
            local dyingName
            for part in string.gfind(arg2, "[^,]+") do
                local clean = string.gsub(part, "^%s*(.-)%s*$", "%1")
                -- GUIDs começam com 0x, flags são puramente numéricos — pular ambos
                if not string.find(clean, "^0x") and not string.find(clean, "^%d+$") and clean ~= "" then
                    local isRare, _, realName = RareTrackerSW:IsRare(clean)
                    if isRare then
                        dyingName = realName or clean
                        break
                    end
                end
            end
            -- Só registrar se não foi o UNIT_DIED normal que já pegou (evita duplicata)
            if dyingName and dyingName ~= RTSW_ActiveRare then
                RareTrackerSW:RecordDeath(dyingName)
                RTSW_Chat("|cff00ffff[RareTracker]|r |cffff8000" .. dyingName .. "|r abatido perto de voce. |cffaaaaaa(deteccao passiva)|r")
                if RareTrackerSW_Map and RareTrackerSW_Map.HideTargetPin then
                    RareTrackerSW_Map:HideTargetPin()
                end
            end

        -- (2) UNIT_CASTEVENT: raro detectado via cast mesmo sem targetar
        elseif event == "UNIT_CASTEVENT" then
            local casterGUID = arg1
            local castType   = arg3  -- "START", "CAST", "CHANNEL", "FAIL", ...
            if casterGUID and casterGUID ~= "" and (castType == "START" or castType == "CAST") then
                local unitName = UnitName(casterGUID)
                if unitName then
                    local isRare, _, realName = RareTrackerSW:IsRare(unitName)
                    if isRare then
                        local name = realName or unitName
                        local timer = RareTrackerSW_Timers and RareTrackerSW_Timers[name] or 0
                        -- Não alertar se já está morto ou já foi setado como ativo
                        if timer < time() and RTSW_ActiveRare ~= name then
                            RTSW_ActiveRare = name
                            RareTrackerSW_AlertCooldowns = RareTrackerSW_AlertCooldowns or {}
                            local lastAlert = RareTrackerSW_AlertCooldowns[name] or 0
                            if GetTime() > lastAlert then
                                if RareTrackerSW_Alert and RareTrackerSW_Alert.ShowAlert then
                                    RareTrackerSW_Alert:ShowAlert(name)
                                    RareTrackerSW_AlertCooldowns[name] = GetTime() + 600
                                end
                                RTSW_Chat("|cff00ffff[RareTracker]|r |cffff8000" .. name .. "|r detectado nas redondezas! |cffaaaaaa(via cast)|r")
                            end
                            if RareTrackerSW_Map and RareTrackerSW_Map.ShowTargetPin then
                                RareTrackerSW_Map:ShowTargetPin(name)
                            end
                        end
                    end
                end
            end

        -- (3) TrackUnit: adiciona raro vivo ao rastreamento nativo do minimapa
        elseif event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT" then
            local unit = (event == "UPDATE_MOUSEOVER_UNIT") and "mouseover" or "target"
            if UnitExists(unit) and not UnitIsPlayer(unit) and not UnitIsDead(unit) then
                local name = UnitName(unit)
                if RareTrackerSW:IsRare(name) then
                    TrackUnit(unit)
                end
            end
        end

    end)

end -- if SUPERWOW_VERSION

-- ============================================================
-- AUTO-LOOT DATABASE — registra drops ao lootar raros
-- ============================================================
local RTSW_LootFrame = CreateFrame("Frame")
RTSW_LootFrame:RegisterEvent("LOOT_OPENED")
RTSW_LootFrame:SetScript("OnEvent", function()
    if event ~= "LOOT_OPENED" then return end
    if not RTSW_LastKilledRare or not RTSW_LastKilledTime then return end
    if GetTime() - RTSW_LastKilledTime > 120 then RTSW_LastKilledRare = nil; return end

    -- Confirma que estamos lootando o mob correto (evita falso positivo quando outro player matou)
    local tName = UnitName("target")
    if tName and tName ~= RTSW_LastKilledRare then return end

    local mobName = RTSW_LastKilledRare
    RTSW_LastKilledRare = nil  -- limpa só após confirmar loot correto

    if not RareTrackerSW_LootDB then RareTrackerSW_LootDB = {} end
    if not RareTrackerSW_LootDB[mobName] then
        RareTrackerSW_LootDB[mobName] = { kills = 0, items = {} }
    end
    local lootDB = RareTrackerSW_LootDB[mobName]
    lootDB.kills = (lootDB.kills or 0) + 1

    local numItems = GetNumLootItems()
    local newItems = 0
    for i = 1, numItems do
        local texture, itemName, count, quality = GetLootSlotInfo(i)
        if itemName and quality and quality >= 2 then  -- verde+ (ignora cinza e branco)
            local itemId = "0"
            if GetLootSlotLink then
                local link = GetLootSlotLink(i)
                if link then
                    local _, _, id = string.find(link, "item:(%d+)")
                    if id then itemId = id end
                end
            end

            local found = false
            for _, item in ipairs(lootDB.items) do
                if item.name == itemName then
                    item.drops = (item.drops or 0) + 1
                    found = true
                    break
                end
            end
            if not found then
                table.insert(lootDB.items, { name=itemName, id=itemId, quality=quality, drops=1 })
                newItems = newItems + 1
            end
        end
    end

    local kills = lootDB.kills
    local suffix = newItems > 0 and (" |cff00ff00+" .. newItems .. " novo(s)|r") or ""
    RTSW_Chat("|cff00ffff[RareTracker]|r Loot de |cffff8000" .. mobName .. "|r registrado" .. suffix .. " — " .. kills .. " kill(s) total.")

    -- Compartilha com outros jogadores com o addon
    if RareTrackerSW_Sync then
        RareTrackerSW_Sync:SendLoot(mobName, lootDB)
    end

    -- Atualiza a aba Loot DB se estiver aberta
    if RareTrackerSW_Menu and RareTrackerSW_Menu:IsShown()
    and RareTrackerSW_Menu.activeTab == "loot" then
        RareTrackerSW_Menu:RefreshLootDB()
    end
end)

