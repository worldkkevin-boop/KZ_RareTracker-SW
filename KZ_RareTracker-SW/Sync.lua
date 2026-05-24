-- RareTracker-SW Sync System
RareTrackerSW_Sync = CreateFrame("Frame")
local SYNC_CHANNEL = "RareTrackerSW_Sync"
local SYNC_PREFIX = "[RTSW_SYNC]"
local SYNC_PREFIX_PATTERN = "%[RTSW_SYNC%]"

function RareTrackerSW_Sync:Init()
    JoinChannelByName(SYNC_CHANNEL)

    self:RegisterEvent("CHAT_MSG_CHANNEL")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    self:SetScript("OnEvent", function()
        if event == "PLAYER_ENTERING_WORLD" then
            JoinChannelByName(SYNC_CHANNEL)
            self:HideSyncChannel()
            self:SendVersion()
            self:SendRequest()
            -- BroadcastDB removido do init: evita flood de mensagens no login
        elseif event == "CHAT_MSG_CHANNEL" then
            -- Filtrar pelo numero do canal (mais confiavel que arg9 que pode variar)
            local chanId = GetChannelName(SYNC_CHANNEL)
            local isSync = false
            if chanId and chanId > 0 and tonumber(arg8) == chanId then
                isSync = true
            end
            -- Fallback: verificar pelo nome do canal (arg4 = "N. CanalNome", arg9 = "CanalNome")
            if not isSync then
                local cn = (arg9 and string.lower(arg9)) or ""
                local c4 = (arg4 and string.lower(arg4)) or ""
                local sc = string.lower(SYNC_CHANNEL)
                if string.find(cn, sc) or string.find(c4, sc) then
                    isSync = true
                end
            end
            if isSync then
                self:OnSyncMessage(arg1, arg2)
            end
        end
    end)
end

-- Remove o canal de sync de todos os chat frames (mensagens brutas ficam invisiveis)
function RareTrackerSW_Sync:HideSyncChannel()
    for i = 1, 10 do
        local cf = getglobal("ChatFrame"..i)
        if cf then
            ChatFrame_RemoveChannel(cf, SYNC_CHANNEL)
        end
    end
end

function RareTrackerSW_Sync:BroadcastDB()
    if not RareTrackerSW_DB then return end
    for zone, mobs in pairs(RareTrackerSW_DB) do
        for name, d in pairs(mobs) do
            if d and d.x and d.y then
                local msg = string.format("%s:DBSYNC:%s:%s:%s:%s:%s:%.3f:%.3f:%s",
                    SYNC_PREFIX, zone, name,
                    tostring(d.level or "?"),
                    tostring(d.type or "rare"),
                    tostring(d.respawn or "?"),
                    d.x, d.y,
                    tostring(d.id or "0"))
                self:Broadcast(msg)
            end
        end
    end
end

function RareTrackerSW_Sync:SendVersion()
    local v = RTSW_VERSION or "0"
    self:Broadcast(string.format("%s:VERSION:%s:%s", SYNC_PREFIX, v, UnitName("player") or "?"))
end

function RareTrackerSW_Sync:SendDeath(mobName, deathTime, killer)
    local killerStr = killer or UnitName("player") or "?"
    local msg = string.format("%s:DEATH:%s:%d:%s", SYNC_PREFIX, mobName, deathTime, killerStr)
    self:Broadcast(msg)
end

function RareTrackerSW_Sync:SendFound(mobName, x, y)
    local msg = string.format("%s:FOUND:%s:%.1f:%.1f", SYNC_PREFIX, mobName, x*100, y*100)
    self:Broadcast(msg)
end

function RareTrackerSW_Sync:SendRequest()
    self:Broadcast(SYNC_PREFIX .. ":REQ_TIMERS:ALL:0")
end

function RareTrackerSW_Sync:SendLoot(mobName, lootData)
    if not mobName or not lootData then return end
    -- Sinal de kill (outros incrementam o contador)
    self:Broadcast(string.format("%s:LOOTKILL:%s:1:0", SYNC_PREFIX, mobName))
    -- Um item por mensagem
    if lootData.items then
        for _, item in ipairs(lootData.items) do
            if item.name then
                self:Broadcast(string.format("%s:LOOTITEM:%s:%s:%d",
                    SYNC_PREFIX, mobName,
                    item.id or "0",
                    item.quality or 1) .. ":" .. item.name)
            end
        end
    end
end

-- Fila de mensagens com throttle para evitar "You must wait X seconds"
local RTSW_MsgQueue = {}
local RTSW_MsgNextSend = 0
local RTSW_MSG_INTERVAL = 2.0  -- 1 msg a cada 2s, seguro contra throttle

local RTSW_SyncThrottleFrame = CreateFrame("Frame")
RTSW_SyncThrottleFrame:SetScript("OnUpdate", function()
    if GetTime() < RTSW_MsgNextSend then return end
    if table.getn(RTSW_MsgQueue) == 0 then return end
    local msg = table.remove(RTSW_MsgQueue, 1)
    local channelId = GetChannelName(SYNC_CHANNEL)
    if channelId and channelId > 0 then
        SendChatMessage(msg, "CHANNEL", nil, channelId)
    end
    RTSW_MsgNextSend = GetTime() + RTSW_MSG_INTERVAL
end)

function RareTrackerSW_Sync:Broadcast(msg)
    table.insert(RTSW_MsgQueue, msg)
end

function RareTrackerSW_Sync:OnSyncMessage(msg, sender)
    if not msg or not string.find(msg, SYNC_PREFIX_PATTERN) then return end
    if sender == UnitName("player") then return end

    local _, _, action, name, v1, v2 = string.find(msg, SYNC_PREFIX_PATTERN .. ":([^:]+):([^:]+):([^:]+):?([^:]*)")
    if not action then return end

    if action == "DEATH" then
        local timer = tonumber(v1)
        local killerRaw = (v2 and v2 ~= "") and v2 or sender
        if not timer then return end
        if not RareTrackerSW_Timers[name] or timer > RareTrackerSW_Timers[name] then
            RareTrackerSW_Timers[name] = timer
            if not RareTrackerSW_Killers then RareTrackerSW_Killers = {} end
            if not RareTrackerSW_Ranks then RareTrackerSW_Ranks = {} end

            -- Parsear lista de matadores
            local killers = {}
            local displayKiller = killerRaw
            if string.find(killerRaw, ",") then
                for k in string.gfind(killerRaw, "[^,]+") do
                    table.insert(killers, k)
                    RareTrackerSW_Ranks[k] = (RareTrackerSW_Ranks[k] or 0) + 1
                end
                if table.getn(killers) > 3 then
                    displayKiller = "Grupo (" .. table.getn(killers) .. " jog.)"
                else
                    displayKiller = "Grupo (" .. table.concat(killers, ", ") .. ")"
                end
            else
                RareTrackerSW_Ranks[killerRaw] = (RareTrackerSW_Ranks[killerRaw] or 0) + 1
                displayKiller = killerRaw
            end
            RareTrackerSW_Killers[name] = displayKiller

            -- Respawn time
            local respawnStr = "?"
            local isRare, zone = RareTrackerSW and RareTrackerSW:IsRare(name)
            if isRare and zone then
                local md = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]) or
                           (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][name])
                if md then respawnStr = md.respawn or "?" end
            end

            -- Mensagem formatada no chat do usuario
            if RareTrackerSW_ChatEnabled ~= false then
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RT Sync]|r |cffff8000" .. name .. "|r eliminado por |cff00ff00" .. displayKiller .. "|r! Respawn: |cffffff00" .. respawnStr .. "|r")
            end

            if RareTrackerSW_Map then RareTrackerSW_Map:UpdateWorldMap() end
            if RareTrackerSW_Menu and RareTrackerSW_Menu:IsShown() then
                local curZ = RareTrackerSW:GetNormalizedZone(GetRealZoneText())
                RareTrackerSW_Menu:ShowZoneDetails(curZ)
            end
        end

    elseif action == "FOUND" then
        local xCoord = tonumber(v1) or 0
        local yCoord = tonumber(v2) or 0
        if RareTrackerSW_ChatEnabled ~= false then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[RT Sync]|r |cff00ff00" .. sender .. "|r encontrou |cffff8000" .. name .. "|r em " .. v1 .. ", " .. v2 .. "!")
        end

        local isRare, zone = RareTrackerSW and RareTrackerSW:IsRare(name)
        if isRare and zone then
            if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
            if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end
            if not RareTrackerSW_DB[zone][name] then
                local base = RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]
                if base then
                    RareTrackerSW_DB[zone][name] = { level=base.level, type=base.type, respawn=base.respawn, id=base.id, faction=base.faction or "N", x=base.x, y=base.y }
                end
            end
            if RareTrackerSW_DB[zone][name] then
                RareTrackerSW_DB[zone][name].x = xCoord / 100
                RareTrackerSW_DB[zone][name].y = yCoord / 100
            end
        end

        if RareTrackerSW_Timers[name] and RareTrackerSW_Timers[name] > time() then
            RareTrackerSW_Timers[name] = nil
        end

        if RareTrackerSW_Map then RareTrackerSW_Map:UpdateWorldMap() end
        if RareTrackerSW_SoundEnabled then PlaySoundFile("Sound\\Interface\\iUiInterfaceButtonFocus.wav") end

    elseif action == "REQ_TIMERS" then
        self:SendResponse()

    elseif action == "DBSYNC" then
        -- Parse manual (parser generico so pega 4 grupos)
        local _, _, zone, mname, level, type_, respawn, x, y, id = string.find(msg,
            SYNC_PREFIX_PATTERN .. ":DBSYNC:([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([%d%.]+):([%d%.]+):([^:]*)")
        if zone and mname and x and y then
            local xn, yn = tonumber(x), tonumber(y)
            if xn and yn then
                if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
                if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end
                if not RareTrackerSW_DB[zone][mname] then
                    RareTrackerSW_DB[zone][mname] = {
                        level=level, type=type_, respawn=respawn,
                        x=xn, y=yn, id=id or "0"
                    }
                    if RareTrackerSW then RareTrackerSW:BuildLookup() end
                    if RareTrackerSW_Map then RareTrackerSW_Map:UpdateWorldMap() end
                end
            end
        end

    elseif action == "LOOTKILL" then
        -- name = mob name; outro player matou e lootou
        if not RareTrackerSW_LootDB then RareTrackerSW_LootDB = {} end
        if not RareTrackerSW_LootDB[name] then
            RareTrackerSW_LootDB[name] = { kills = 0, items = {} }
        end
        RareTrackerSW_LootDB[name].kills = (RareTrackerSW_LootDB[name].kills or 0) + 1
        if RareTrackerSW_ChatEnabled ~= false then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RT Loot]|r |cff00ff00" .. sender .. "|r lootou |cffff8000" .. name .. "|r — kill registrado.")
        end

    elseif action == "LOOTITEM" then
        -- formato: LOOTITEM:MobName:itemId:quality:itemName (name tem itemId, v1=quality, v2+ = itemName)
        local _, _, mobN, itemId, quality, itemName = string.find(msg,
            SYNC_PREFIX_PATTERN .. ":LOOTITEM:([^:]+):([^:]+):([^:]+):(.*)")
        if not mobN or not itemName or itemName == "" then return end
        local qual = tonumber(quality) or 1
        if not RareTrackerSW_LootDB then RareTrackerSW_LootDB = {} end
        if not RareTrackerSW_LootDB[mobN] then
            RareTrackerSW_LootDB[mobN] = { kills = 0, items = {} }
        end
        local lootDB = RareTrackerSW_LootDB[mobN]
        local found = false
        for _, item in ipairs(lootDB.items) do
            if item.name == itemName then
                item.drops = (item.drops or 0) + 1
                found = true
                break
            end
        end
        if not found then
            table.insert(lootDB.items, { name=itemName, id=itemId, quality=qual, drops=1 })
        end

    elseif action == "VERSION" then
        local remoteVer = v1
        local localVer  = RTSW_VERSION or "0"
        if remoteVer and RareTrackerSW_Sync:IsNewerVersion(remoteVer, localVer) then
            if RareTrackerSW_ChatEnabled ~= false then DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[RareTracker]|r |cffff8800Atualizacao disponivel!|r |cffffd700v" .. remoteVer .. "|r (voce tem v" .. localVer .. ") - Peca para " .. (v2 or sender)) end
        end
    end
end

function RareTrackerSW_Sync:IsNewerVersion(remote, local_)
    local function parseVer(v)
        local a, b, c = string.match(v, "(%d+)%.?(%d*)%.?(%d*)")
        return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
    end
    local ra, rb, rc = parseVer(remote)
    local la, lb, lc = parseVer(local_)
    if ra ~= la then return ra > la end
    if rb ~= lb then return rb > lb end
    return rc > lc
end

function RareTrackerSW_Sync:SendResponse()
    for name, timer in pairs(RareTrackerSW_Timers) do
        if timer > time() then
            local killer = RareTrackerSW_Killers and RareTrackerSW_Killers[name] or ""
            self:SendDeath(name, timer, killer)
        end
    end
end

RareTrackerSW_Sync:Init()
