-- RareTracker-SW Sync System (PARTY/RAID only)
RareTrackerSW_Sync = CreateFrame("Frame")
local SYNC_PREFIX         = "[RTSW]"
local SYNC_PREFIX_PATTERN = "%[RTSW%]"

local function RTSW_SyncChannel()
    if GetNumRaidMembers() > 0 then return "RAID" end
    if GetNumPartyMembers() > 0 then return "PARTY" end
    return nil
end

function RareTrackerSW_Sync:Init()
    self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_RAID")

    self:SetScript("OnEvent", function()
        if event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_RAID" then
            self:OnSyncMessage(arg1, arg2)
        end
    end)
end

-- Fila com throttle para evitar "You must wait X seconds"
local RTSW_MsgQueue    = {}
local RTSW_MsgNextSend = 0
local RTSW_MSG_INTERVAL = 1.5

local RTSW_SyncThrottleFrame = CreateFrame("Frame")
RTSW_SyncThrottleFrame:SetScript("OnUpdate", function()
    if GetTime() < RTSW_MsgNextSend then return end
    if table.getn(RTSW_MsgQueue) == 0 then return end
    local chan = RTSW_SyncChannel()
    if not chan then RTSW_MsgQueue = {} return end
    local msg = table.remove(RTSW_MsgQueue, 1)
    SendChatMessage(msg, chan)
    RTSW_MsgNextSend = GetTime() + RTSW_MSG_INTERVAL
end)

function RareTrackerSW_Sync:Broadcast(msg)
    if not RTSW_SyncChannel() then return end
    table.insert(RTSW_MsgQueue, msg)
end

function RareTrackerSW_Sync:SendDeath(mobName, deathTime, killer)
    local killerStr = killer or UnitName("player") or "?"
    self:Broadcast(string.format("%s:DEATH:%s:%d:%s", SYNC_PREFIX, mobName, deathTime, killerStr))
end

function RareTrackerSW_Sync:SendFound(mobName, x, y)
    self:Broadcast(string.format("%s:FOUND:%s:%.1f:%.1f", SYNC_PREFIX, mobName, x * 100, y * 100))
end

function RareTrackerSW_Sync:SendLoot(mobName, lootData)
    if not mobName or not lootData then return end
    self:Broadcast(string.format("%s:LOOTKILL:%s:1:0", SYNC_PREFIX, mobName))
    if lootData.items then
        for _, item in ipairs(lootData.items) do
            if item.name then
                self:Broadcast(string.format("%s:LOOTITEM:%s:%s:%d:%s",
                    SYNC_PREFIX, mobName, item.id or "0", item.quality or 1, item.name))
            end
        end
    end
end

function RareTrackerSW_Sync:OnSyncMessage(msg, sender)
    if not msg or not string.find(msg, SYNC_PREFIX_PATTERN) then return end
    if sender == UnitName("player") then return end

    local _, _, action, name, v1, v2 = string.find(msg,
        SYNC_PREFIX_PATTERN .. ":([^:]+):([^:]+):([^:]+):?([^:]*)")
    if not action then return end

    if action == "DEATH" then
        local timer = tonumber(v1)
        if not timer then return end
        local killerRaw = (v2 and v2 ~= "") and v2 or sender
        if not RareTrackerSW_Timers[name] or timer > RareTrackerSW_Timers[name] then
            RareTrackerSW_Timers[name] = timer
            if not RareTrackerSW_Killers then RareTrackerSW_Killers = {} end
            RareTrackerSW_Killers[name] = killerRaw

            local respawnStr = "?"
            local isRare, zone = RareTrackerSW and RareTrackerSW:IsRare(name)
            if isRare and zone then
                local md = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]) or
                           (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][name])
                if md then respawnStr = md.respawn or "?" end
            end

            if RareTrackerSW_ChatEnabled ~= false then
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RT Sync]|r |cffff8000" .. name ..
                    "|r eliminado por |cff00ff00" .. killerRaw ..
                    "|r! Respawn: |cffffff00" .. respawnStr .. "|r")
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
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[RT Sync]|r |cff00ff00" .. sender ..
                "|r encontrou |cffff8000" .. name .. "|r em " .. v1 .. ", " .. v2 .. "!")
        end

        local isRare, zone = RareTrackerSW and RareTrackerSW:IsRare(name)
        if isRare and zone then
            if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
            if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end
            if not RareTrackerSW_DB[zone][name] then
                local base = RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]
                if base then
                    RareTrackerSW_DB[zone][name] = {
                        level=base.level, type=base.type, respawn=base.respawn,
                        id=base.id, faction=base.faction or "N", x=base.x, y=base.y
                    }
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

    elseif action == "LOOTKILL" then
        if not RareTrackerSW_LootDB then RareTrackerSW_LootDB = {} end
        if not RareTrackerSW_LootDB[name] then
            RareTrackerSW_LootDB[name] = { kills = 0, items = {} }
        end
        RareTrackerSW_LootDB[name].kills = (RareTrackerSW_LootDB[name].kills or 0) + 1
        if RareTrackerSW_ChatEnabled ~= false then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RT Loot]|r |cff00ff00" .. sender ..
                "|r lootou |cffff8000" .. name .. "|r — kill registrado.")
        end

    elseif action == "LOOTITEM" then
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
    end
end

RareTrackerSW_Sync:Init()
