-- RareTracker-SW Map Logic (Inspired by pfQuest)
-- RareTracker-SW Map Logic
RareTrackerSW_Map = CreateFrame("Frame", nil, WorldMapButton)
RareTrackerSW_Map.pins = {}

RareTrackerSW_Minimap = CreateFrame("Frame", nil, Minimap)
RareTrackerSW_Minimap.pins = {}

-- pfQuest-inspired constants for 1.12.1 Minimap
-- [0] = indoor/dungeon, [1] = outdoor — mesma convenção do pfQuest
local minimap_zoom = {
    [0] = { [0] = 300,        [1] = 240, [2] = 180,        [3] = 120,        [4] = 80,  [5] = 50         },
    [1] = { [0] = 466+2/3,   [1] = 400, [2] = 333+1/3,   [3] = 266+2/3,   [4] = 200, [5] = 133+1/3  },
}

-- Retorna 1 quando outdoor, 0 quando indoor (sem chamar SetZoom — seguro para OnUpdate)
local function minimap_outdoor()
    -- CVars iguais = inside zoom ativo = indoor
    if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
        return 0
    end
    return 1
end

-- Configuração visual por tipo: cor (r,g,b), tamanho no mapa-mundi, tamanho no minimapa
local pinTypeConfig = {
    rare      = { r=0.12, g=1,    b=0,    size=18, mmSize=13 },  -- Verde (Incomum)
    rareelite = { r=0,    g=0.44, b=0.87, size=22, mmSize=16 },  -- Azul (Raro)
    elite     = { r=1,    g=0.4,  b=0,    size=20, mmSize=14 },  -- Laranja
    worldboss = { r=1,    g=0,    b=0,    size=26, mmSize=18 },  -- Vermelho puro
    custom    = { r=0.8,  g=0,    b=1,    size=18, mmSize=13 },  -- Roxo
    turtlewow = { r=0,    g=1,    b=0.3,  size=18, mmSize=13 },  -- Teal
}

-- ============================================================
-- SEEK MOB — tenta TargetByName repetidamente enquanto você se aproxima
-- ============================================================
local RTSW_SeekFrame = CreateFrame("Frame")
RTSW_SeekFrame.active   = false
RTSW_SeekFrame.mobName  = nil
RTSW_SeekFrame.timeLeft = 0
RTSW_SeekFrame.nextTry  = 0

RTSW_SeekFrame:SetScript("OnUpdate", function()
    if not this.active then return end
    this.timeLeft = this.timeLeft - arg1
    if this.timeLeft <= 0 then
        this.active = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r |cffff6666" .. (this.mobName or "?") .. " fora de alcance.|r")
        return
    end
    this.nextTry = this.nextTry - arg1
    if this.nextTry <= 0 then
        this.nextTry = 0.5
        TargetByName(this.mobName)
        if UnitExists("target") and UnitName("target") == this.mobName then
            this.active = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r |cff44ff44" .. this.mobName .. " alvejado!|r")
        end
    end
end)

function RTSW_SeekMob(mobName)
    if RTSW_SeekFrame.active and RTSW_SeekFrame.mobName == mobName then
        -- Segundo clique cancela a busca
        RTSW_SeekFrame.active = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r Busca cancelada.")
        return
    end
    RTSW_SeekFrame.mobName  = mobName
    RTSW_SeekFrame.active   = true
    RTSW_SeekFrame.timeLeft = 10
    RTSW_SeekFrame.nextTry  = 0
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r Buscando |cffff8000" .. mobName .. "|r por 10s... (clique de novo para cancelar)")
end

-- ============================================================
-- HOVER HIGHLIGHT — dim outros pins quando mouse está num pin
-- ============================================================
RTSW_HoveredMob = nil

local function RTSW_RefreshPinAlpha()
    local hovering = RTSW_HoveredMob ~= nil
    for _, pin in pairs(RareTrackerSW_Map.pins) do
        if pin:IsShown() then
            if not hovering or pin.mobName == RTSW_HoveredMob then
                pin:SetAlpha(1)
            else
                pin:SetAlpha(0.3)
            end
        end
    end
    for _, pin in pairs(RareTrackerSW_Minimap.pins) do
        if pin:IsShown() then
            if not hovering or pin.mobName == RTSW_HoveredMob then
                pin:SetAlpha(1)
            else
                pin:SetAlpha(0.3)
            end
        end
    end
end

-- Mapeamento zona → pfQuest mapId (pfDB["units"]["data"][npcId]["coords"][i][3])
local RTSW_ZoneToMapId = {
    ["Alterac Mountains"]    = 36,
    ["Arathi Highlands"]     = 45,
    ["Ashenvale"]            = 331,
    ["Azshara"]              = 16,
    ["Badlands"]             = 3,
    ["Blasted Lands"]        = 4,
    ["Burning Steppes"]      = 46,
    ["Darkshore"]            = 148,
    ["Deadwind Pass"]        = 41,
    ["Desolace"]             = 405,
    ["Dun Morogh"]           = 1,
    ["Durotar"]              = 14,
    ["Duskwood"]             = 10,
    ["Dustwallow Marsh"]     = 15,
    ["Eastern Plaguelands"]  = 139,
    ["Elwynn Forest"]        = 12,
    ["Felwood"]              = 361,
    ["Feralas"]              = 357,
    ["Hillsbrad Foothills"]  = 267,
    ["Loch Modan"]           = 38,
    ["Moonglade"]            = 493,
    ["Mulgore"]              = 215,
    ["Redridge Mountains"]   = 44,
    ["Searing Gorge"]        = 51,
    ["Silverpine Forest"]    = 130,
    ["Stonetalon Mountains"] = 406,
    ["Stranglethorn Vale"]   = 33,
    ["Swamp of Sorrows"]     = 8,
    ["Tanaris"]              = 440,
    ["Teldrassil"]           = 141,
    ["The Barrens"]          = 17,
    ["The Hinterlands"]      = 47,
    ["Thousand Needles"]     = 400,
    ["Tirisfal Glades"]      = 85,
    ["Un'Goro Crater"]       = 490,
    ["Westfall"]             = 40,
    ["Western Plaguelands"]  = 28,
    ["Wetlands"]             = 11,
    ["Winterspring"]         = 618,
}

-- Retorna lista de spawns {x, y} para o mob.
-- Para mobs vanilla (id < 40000), tenta usar coordenadas do pfQuest (múltiplos spawns).
-- zoneMapId = pfQuest mapId da zona atual.
local function GetMobSpawns(mob, zoneMapId)
    if mob.spawns then return mob.spawns end

    local npcId = tonumber(mob.id)
    if npcId and npcId > 0 and npcId < 40000 and zoneMapId then
        if pfDB and pfDB["units"] and pfDB["units"]["data"] then
            local pfUnit = pfDB["units"]["data"][npcId]
            if pfUnit and pfUnit.coords then
                local result = {}
                for _, coord in pairs(pfUnit.coords) do
                    if coord[3] == zoneMapId then
                        table.insert(result, { x = coord[1] / 100, y = coord[2] / 100 })
                    end
                end
                if table.getn(result) > 0 then return result end
            end
        end
    end

    if mob.x and mob.y then return { {x=mob.x, y=mob.y} } end
    return {}
end

local function TypeVisible(t)
    if not RareTrackerSW_ShowTypes then return true end
    if RareTrackerSW_ShowTypes[t] == nil then return true end
    return RareTrackerSW_ShowTypes[t]
end

local pinColors = {
    rare      = {0.12, 1, 0},
    rareelite = {0, 0.44, 0.87},
    elite     = {1, 0.55, 0},
    worldboss = {1, 0.1, 0.1},
    custom    = {0.8, 0.3, 1},
    turtlewow = {0, 0.9, 0.5},
}

local function RTSW_DiffColor(mobLevel)
    local pLv = UnitLevel("player") or 1
    local ml  = tonumber(mobLevel) or pLv
    local d   = ml - pLv
    if     d >= 5  then return "ff2020"
    elseif d >= 3  then return "ff8040"
    elseif d >= -2 then return "ffff00"
    elseif d >= -7 then return "40c040"
    else                return "808080"
    end
end

-- Retorna o tipo visual do mob (IDs >= 40000 = custom SandWorlds → roxo)
local function GetDisplayType(mob, name)
    if not mob then return "rare" end
    local id = tonumber(mob.id) or 0
    if id >= 40000 then return "custom" end
    return mob.type or "rare"
end

local qualityColors = {
    purple = {1, 0, 1},
    blue = {0, 0.4, 1},
    green = {0.1, 1, 0},
    white = {1, 1, 1}
}

RareTrackerSW_Map.minimapSizes = {
    ["Alterac Mountains"] = { 2800.0, 1866.67 },
    ["Arathi Highlands"] = { 3500.0, 2333.3 },
    ["Ashenvale"] = { 5766.67, 3843.75 },
    ["Azshara"] = { 5070.84, 3381.25 },
    ["Badlands"] = { 2487.5, 1658.34 },
    ["Blasted Lands"] = { 3350.0, 2233.3 },
    ["Burning Steppes"] = { 2929.16, 1952.08 },
    ["Darkshore"] = { 6550.0, 4366.66 },
    ["Desolace"] = { 4495.83, 2997.91 },
    ["Dun Morogh"] = { 4925.0, 3283.34 },
    ["Durotar"] = { 5287.5, 3525.0 },
    ["Duskwood"] = { 2700.0, 1800.03 },
    ["Dustwallow Marsh"] = { 5250.0, 3500.0 },
    ["Eastern Plaguelands"] = { 3870.83, 2581.25 },
    ["Elwynn Forest"] = { 3470.84, 2314.62 },
    ["Felwood"] = { 5750.0, 3833.33 },
    ["Feralas"] = { 6950.0, 4633.33 },
    ["Hillsbrad Foothills"] = { 3200.0, 2133.33 },
    ["Loch Modan"] = { 2758.33, 1839.58 },
    ["Mulgore"] = { 5137.5, 3425.0 },
    ["Redridge Mountains"] = { 2170.84, 1447.9 },
    ["Searing Gorge"] = { 2231.25, 1487.5 },
    ["Silverpine Forest"] = { 4200.0, 2800.0 },
    ["Stonetalon Mountains"] = { 4883.33, 3256.25 },
    ["Stranglethorn Vale"] = { 6381.25, 4254.1 },
    ["Swamp of Sorrows"] = { 2293.75, 1529.17 },
    ["Tanaris"] = { 6900.0, 4600.0 },
    ["Teldrassil"] = { 5091.66, 3393.7 },
    ["The Barrens"] = { 10133.34, 6756.25 },
    ["Thousand Needles"] = { 4399.99, 2933.33 },
    ["Tirisfal Glades"] = { 4518.75, 3012.5 },
    ["Un'Goro Crater"] = { 3700.0, 2466.66 },
    ["Westfall"] = { 3500.0, 2333.3 },
    ["Western Plaguelands"] = { 4299.99, 2866.67 },
    ["Wetlands"] = { 4135.42, 2756.25 },
    ["Winterspring"] = { 7100.0, 4733.33 },
    ["The Hinterlands"] = { 5100.0, 3400.0 },
    ["Alah'Thalas"] = { 1468.0, 976.0 },
    ["Hyjal"] = { 3206.0, 2142.0 },
    ["Lapidis Isle"] = { 2901.45, 1915.9 },
}

function RareTrackerSW_Map:CreateGenericPin(parent)
    local pin = CreateFrame("Button", nil, parent)
    pin:SetWidth(10)
    pin:SetHeight(10)
    pin:EnableMouse(true)
    pin:SetFrameLevel(parent:GetFrameLevel() + 5)

    local tex = pin:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\AddOns\\pfQuest\\img\\node")
    pin.texture = tex
    
    pin:SetScript("OnEnter", function()
        if this.mobData then
            RTSW_HoveredMob = this.mobName
            RTSW_RefreshPinAlpha()
            -- UIParent como owner evita conflito com detecção de unidade do minimapa
            local tt = GameTooltip
            tt:SetOwner(UIParent, "ANCHOR_CURSOR")
            tt:ClearLines()
            local n = this.mobName
            local d = this.mobData
            local timer = RareTrackerSW_Timers and RareTrackerSW_Timers[n] or 0
            local isDead = timer > time()
            local status = isDead and "|cffff4444Morto|r" or "|cff44ff44Vivo|r"
            tt:AddLine(n, 1, 1, 1)
            local lvlColor = RTSW_DiffColor(d and d.level)
            local lvlStr = "|cff" .. lvlColor .. "Nv. " .. (d and d.level or "?") .. "|r"
            tt:AddLine(lvlStr .. "   " .. status .. "   |cffaaaaaa(Clique para buscar)|r", 1, 1, 1)
            tt:Show()
        end
    end)
    pin:SetScript("OnLeave", function()
        GameTooltip:Hide()
        RTSW_HoveredMob = nil
        RTSW_RefreshPinAlpha()
    end)

    pin:SetScript("OnClick", function()
        if IsShiftKeyDown() then
            if RareTrackerSW and RareTrackerSW.RecordDeath then
                RareTrackerSW:RecordDeath(this.mobName, false, nil, true)
                RareTrackerSW_Map:UpdateWorldMap()
            end
        else
            if this.mobName then
                RTSW_SeekMob(this.mobName)
            end
        end
    end)

    return pin
end

function RareTrackerSW_Map:UpdateWorldMap()
    local cIdx = GetCurrentMapContinent()
    local zIdx = GetCurrentMapZone()
    
    if zIdx == 0 then
        for _, pin in pairs(self.pins) do pin:Hide() end
        return
    end

    local zones = { GetMapZones(cIdx) }
    local zName = zones[zIdx]
    if RareTrackerSW and RareTrackerSW.GetNormalizedZone then zName = RareTrackerSW:GetNormalizedZone(zName) end
    local data = {}
    if RareTrackerSW_Data and RareTrackerSW_Data[zName] then
        for k, v in pairs(RareTrackerSW_Data[zName]) do data[k] = v end
    end
    if RareTrackerSW_DB and RareTrackerSW_DB[zName] then
        for k, v in pairs(RareTrackerSW_DB[zName]) do
            local staticId = data[k] and data[k].id
            data[k] = v
            if staticId and (not v.id or v.id == "0" or v.id == 0) then
                data[k].id = staticId
            end
        end
    end

    for _, pin in pairs(self.pins) do pin:Hide() end
    if not data or next(data) == nil then return end
    
    local i = 1
    local mapW, mapH = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
    
    if RareTrackerSW_ShowDeadOnMap == nil then RareTrackerSW_ShowDeadOnMap = true end
    
    local pFac = UnitFactionGroup("player")
    local pFacCode = (pFac == "Alliance" and "A") or (pFac == "Horde" and "H") or "N"
    
    local zoneMapId = RTSW_ZoneToMapId[zName]

    for name, mob in pairs(data) do
        if mob.faction and mob.faction ~= "N" and mob.faction == pFacCode then
            -- pular mob amigável
        else
            local timer  = RareTrackerSW_Timers and RareTrackerSW_Timers[name] or 0
            local isDead = timer > time()
            local dt     = GetDisplayType(mob, name)
            local cfg    = pinTypeConfig[dt] or pinTypeConfig.rare
            local spawns = GetMobSpawns(mob, zoneMapId)

            if TypeVisible(dt) then
            for _, sp in ipairs(spawns) do
                local pin = self.pins[i]
                if not pin then
                    pin = RareTrackerSW_Map:CreateGenericPin(WorldMapDetailFrame)
                    table.insert(RareTrackerSW_Map.pins, pin)
                end

                pin.mobName, pin.mobData, pin.spawnX, pin.spawnY, pin.mobZone = name, mob, sp.x, sp.y, zName

                local sz = cfg.size
                pin:SetWidth(sz)
                pin:SetHeight(sz)

                if isDead then
                    pin.texture:SetVertexColor(0.35, 0.35, 0.35)
                else
                    pin.texture:SetVertexColor(cfg.r, cfg.g, cfg.b)
                end

                pin:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", sp.x * mapW, -sp.y * mapH)
                pin:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 5)

                pin:SetScript("OnEnter", function()
                    local d  = this.mobData
                    local n  = this.mobName
                    RTSW_HoveredMob = n
                    RTSW_RefreshPinAlpha()
                    local c  = pinTypeConfig[GetDisplayType(d, n)] or pinTypeConfig.rare
                    local hex = string.format("%02x%02x%02x", math.floor(c.r*255), math.floor(c.g*255), math.floor(c.b*255))

                    local t2     = RareTrackerSW_Timers and RareTrackerSW_Timers[n] or 0
                    local dead2  = t2 > time()
                    local status = dead2 and "|cffff4444Morto|r" or "|cff44ff44Vivo|r"

                    local lvlColor = RTSW_DiffColor(d and d.level)
                    local lvlStr   = "|cff" .. lvlColor .. "Nv. " .. (d and d.level or "?") .. "|r"
                    WorldMapTooltip:SetOwner(this, "ANCHOR_RIGHT")
                    WorldMapTooltip:SetText("|cff" .. hex .. n .. "|r")
                    WorldMapTooltip:AddLine(lvlStr .. "   " .. status .. "  |cffaaaaaa(Clique para detalhes)|r")
                    WorldMapTooltip:Show()
                end)
                pin:SetScript("OnLeave", function()
                    WorldMapTooltip:Hide()
                    RTSW_HoveredMob = nil
                    RTSW_RefreshPinAlpha()
                end)
                pin:SetScript("OnClick", function()
                    if IsShiftKeyDown() then
                        if RareTrackerSW and RareTrackerSW.RecordDeath then
                            RareTrackerSW:RecordDeath(this.mobName, false, nil, true)
                            RareTrackerSW_Map:UpdateWorldMap()
                        end
                    else
                        RTSW_OpenQuickPanel(this)
                    end
                end)
                pin:Show()
                i = i + 1
            end
            end -- TypeVisible
        end
    end

    -- Esconder pins não usados no mapa mundi
    local totalPins = table.getn(RareTrackerSW_Map.pins)
    if i <= totalPins then
        for j = i, totalPins do
            self.pins[j]:Hide()
        end
    end
end

function RareTrackerSW_Map:UpdateMinimap()
    local zName = GetRealZoneText()
    if RareTrackerSW and RareTrackerSW.GetNormalizedZone then zName = RareTrackerSW:GetNormalizedZone(zName) end
    if not RareTrackerSW_Data then return end
    
    -- Unificar banco estático e local
    local data = {}
    if RareTrackerSW_Data[zName] then
        for k, v in pairs(RareTrackerSW_Data[zName]) do data[k] = v end
    end
    if RareTrackerSW_DB and RareTrackerSW_DB[zName] then
        for k, v in pairs(RareTrackerSW_DB[zName]) do
            local staticId = data[k] and data[k].id
            data[k] = v
            if staticId and (not v.id or v.id == "0" or v.id == 0) then
                data[k].id = staticId
            end
        end
    end
    
    for _, pin in pairs(RareTrackerSW_Minimap.pins) do pin:Hide() end
    if not data or next(data) == nil then return end

    local sizes = RareTrackerSW_Map.minimapSizes[zName] or { 3000, 2000 }
    
    local xPlayer, yPlayer = GetPlayerMapPosition("player")
    if xPlayer == 0 and yPlayer == 0 then return end
    
    -- pfQuest-style scaling: minimap_outdoor() retorna 1=outdoor, 0=indoor
    local mapZoom = minimap_zoom[minimap_outdoor()][Minimap:GetZoom()] or minimap_zoom[1][0]

    local xScale = mapZoom / sizes[1]
    local yScale = mapZoom / sizes[2]
    local xDraw = Minimap:GetWidth() / xScale / 100
    local yDraw = Minimap:GetHeight() / yScale / 100
    
    local i = 1
    local radius = (Minimap:GetWidth() / 2) - 5

    if RareTrackerSW_ShowDeadOnMap == nil then RareTrackerSW_ShowDeadOnMap = true end

    local px, py = xPlayer * 100, yPlayer * 100
    local zoneMapId = RTSW_ZoneToMapId[zName]

    for name, mob in pairs(data) do
        local timer   = RareTrackerSW_Timers and RareTrackerSW_Timers[name] or 0
        local isDead  = timer > time()
        local isAllied = RareTrackerSW_AlliedMobs and RareTrackerSW_AlliedMobs[name]

        if (isDead and not RareTrackerSW_ShowDeadOnMap) or (isAllied and RareTrackerSW_HideAllied) then
            -- pula
        else
            local dt     = GetDisplayType(mob, name)
            local cfg    = pinTypeConfig[dt] or pinTypeConfig.rare
            local spawns = GetMobSpawns(mob, zoneMapId)

            if TypeVisible(dt) then
            for _, sp in ipairs(spawns) do
                local x    = sp.x * 100
                local y    = sp.y * 100
                local xPos = (x - px) * xDraw
                local yPos = -(y - py) * yDraw

                local dist = math.sqrt(xPos*xPos + yPos*yPos)
                if dist < radius then
                    local pin = RareTrackerSW_Minimap.pins[i]
                    if not pin then
                        pin = RareTrackerSW_Map:CreateGenericPin(Minimap)
                        table.insert(RareTrackerSW_Minimap.pins, pin)
                    end

                    pin.mobName, pin.mobData = name, mob
                    local sz = cfg.mmSize
                    pin:SetWidth(sz)
                    pin:SetHeight(sz)

                    if isDead then
                        pin.texture:SetVertexColor(0.35, 0.35, 0.35)
                    else
                        pin.texture:SetVertexColor(cfg.r, cfg.g, cfg.b)
                    end

                    pin:ClearAllPoints()
                    pin:SetPoint("CENTER", Minimap, "CENTER", xPos, yPos)
                    pin:SetFrameLevel(Minimap:GetFrameLevel() + 20)
                    pin:Show()
                    i = i + 1
                end
            end
            end -- TypeVisible
        end
    end

    -- Esconder pins não usados no minimapa
    local totalPins = table.getn(RareTrackerSW_Minimap.pins)
    if i <= totalPins then
        for j = i, totalPins do
            RareTrackerSW_Minimap.pins[j]:Hide()
        end
    end
end

RareTrackerSW_Map:RegisterEvent("WORLD_MAP_UPDATE")
RareTrackerSW_Map:RegisterEvent("PLAYER_ENTERING_WORLD")
RareTrackerSW_Map:RegisterEvent("ZONE_CHANGED_NEW_AREA")
RareTrackerSW_Map:SetScript("OnEvent", function() 
    RareTrackerSW_Map:UpdateWorldMap() 
end)


-- ============================================================
-- TARGET PIN — bolinha pulsante ao targetar raro (estilo tracker do Hunter)
-- ============================================================
local RTSW_TargetPin = CreateFrame("Frame", "RTSW_TargetPin", Minimap)
RTSW_TargetPin:SetWidth(8)
RTSW_TargetPin:SetHeight(8)
RTSW_TargetPin:SetFrameLevel(Minimap:GetFrameLevel() + 30)
RTSW_TargetPin:Hide()

-- Dot simples (circulo pequeno como blip do Hunter)
local tpDot = RTSW_TargetPin:CreateTexture(nil, "OVERLAY")
tpDot:SetAllPoints()
tpDot:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Background")
tpDot:SetVertexColor(1, 0.8, 0, 1)

RTSW_TargetMob = nil

-- Calcula e posiciona o TargetPin a partir das coordenadas salvas do mob
local function RTSW_UpdateTargetPinPosition()
    if not RTSW_TargetMob then RTSW_TargetPin:Hide(); return end

    local isRare, zone, realName = RareTrackerSW:IsRare(RTSW_TargetMob)
    if not isRare or not zone then RTSW_TargetPin:Hide(); return end

    local mobData = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][realName]) or
                    (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][realName])
    if not mobData then RTSW_TargetPin:Hide(); return end

    local curZone = GetRealZoneText()
    if RareTrackerSW then curZone = RareTrackerSW:GetNormalizedZone(curZone) end
    if curZone ~= zone then RTSW_TargetPin:Hide(); return end

    local xPlayer, yPlayer = GetPlayerMapPosition("player")
    if xPlayer == 0 and yPlayer == 0 then RTSW_TargetPin:Hide(); return end

    local sizes = RareTrackerSW_Map.minimapSizes[zone] or { 3000, 2000 }
    local mapZoom = minimap_zoom[minimap_outdoor()][Minimap:GetZoom()] or minimap_zoom[1][0]
    local xDraw = Minimap:GetWidth() / (mapZoom / sizes[1]) / 100
    local yDraw = Minimap:GetHeight() / (mapZoom / sizes[2]) / 100

    local spx = mobData.x
    local spy = mobData.y
    if not spx and mobData.spawns and mobData.spawns[1] then
        spx = mobData.spawns[1].x
        spy = mobData.spawns[1].y
    end
    if not spx then RTSW_TargetPin:Hide(); return end
    local xPos = (spx - xPlayer) * xDraw * 100
    local yPos = -(spy - yPlayer) * yDraw * 100

    local radius = (Minimap:GetWidth() / 2) - 8
    local dist = math.sqrt(xPos * xPos + yPos * yPos)

    -- Clamp na borda do minimapa (em vez de esconder, aponta a direção)
    if dist > radius then
        local angle = math.atan2(yPos, xPos)
        xPos = math.cos(angle) * radius
        yPos = math.sin(angle) * radius
    end

    RTSW_TargetPin:ClearAllPoints()
    RTSW_TargetPin:SetPoint("CENTER", Minimap, "CENTER", xPos, yPos)
    RTSW_TargetPin:Show()
end

-- Pulse suave + reposicionamento a cada frame
local tpTime = 0
RTSW_TargetPin:SetScript("OnUpdate", function()
    tpTime = tpTime + arg1
    local s = 1.0 + math.sin(tpTime * 5) * 0.35
    this:SetScale(s)
    RTSW_UpdateTargetPinPosition()
end)

function RareTrackerSW_Map:ShowTargetPin(mobName)
    RTSW_TargetMob = mobName

    -- Atualiza posição do mob para onde o player está agora (melhor aproximação possível)
    local isRare, zone, realName = RareTrackerSW and RareTrackerSW:IsRare(mobName)
    if isRare and zone then
        local px, py = GetPlayerMapPosition("player")
        if px and not (px == 0 and py == 0) then
            if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
            if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end
            if not RareTrackerSW_DB[zone][realName] then
                local base = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][realName]) or {}
                RareTrackerSW_DB[zone][realName] = {
                    level=base.level, type=base.type, respawn=base.respawn,
                    id=base.id, faction=base.faction
                }
            end
            RareTrackerSW_DB[zone][realName].x = px
            RareTrackerSW_DB[zone][realName].y = py
        end
    end

    RTSW_UpdateTargetPinPosition()
end

function RareTrackerSW_Map:HideTargetPin()
    RTSW_TargetMob = nil
    RTSW_TargetPin:Hide()
end

-- Hook WorldMap: ao abrir, tenta ir para a zona do player antes de atualizar pins
local original_WorldMap_OnShow = WorldMapFrame:GetScript("OnShow")
WorldMapFrame:SetScript("OnShow", function()
    if original_WorldMap_OnShow then original_WorldMap_OnShow() end
    -- SetMapToCurrentZone centraliza no player (vanilla 1.12 API, só funciona fora de instância)
    if SetMapToCurrentZone then SetMapToCurrentZone() end
    RareTrackerSW_Map:UpdateWorldMap()
end)

RareTrackerSW_Minimap:SetScript("OnUpdate", function()
    if (this.tick or 0) < GetTime() then
        RareTrackerSW_Map:UpdateMinimap()
        this.tick = GetTime() + 0.1
    end
end)

-- ============================================================
-- TIPO TOGGLE PANEL — painel de filtro estilo pfQuest Database
-- ============================================================
local RTSW_TypePanel = CreateFrame("Frame", "RTSW_TypePanel", UIParent)
RTSW_TypePanel:SetWidth(175)
RTSW_TypePanel:SetHeight(185)
RTSW_TypePanel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
RTSW_TypePanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
RTSW_TypePanel:SetMovable(true)
RTSW_TypePanel:EnableMouse(true)
RTSW_TypePanel:RegisterForDrag("LeftButton")
RTSW_TypePanel:SetScript("OnDragStart", function() this:StartMoving() end)
RTSW_TypePanel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
RTSW_TypePanel:SetFrameStrata("DIALOG")
RTSW_TypePanel:Hide()

local tpTitle = RTSW_TypePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tpTitle:SetPoint("TOP", RTSW_TypePanel, "TOP", 0, -10)
tpTitle:SetText("|cFF2ecc40KZ|r |cFFFFD700RareTracker|r — Filtros")

local tpClose = CreateFrame("Button", nil, RTSW_TypePanel, "UIPanelCloseButton")
tpClose:SetPoint("TOPRIGHT", RTSW_TypePanel, "TOPRIGHT", 2, 2)
tpClose:SetScript("OnClick", function() RTSW_TypePanel:Hide() end)

local typeRows = {
    { key = "rare",      label = "|cFFFFD700★|r Raros"       },
    { key = "rareelite", label = "|cFF6699FF★|r Raros Elite" },
    { key = "elite",     label = "|cFFFF8800★|r Elites"      },
    { key = "worldboss", label = "|cFFFF3333★|r World Boss"  },
    { key = "custom",    label = "|cFFCC44FF★|r Custom"      },
    { key = "turtlewow", label = "|cFF00E680★|r Turtle WoW"  },
}

local tpChecks = {}
for idx, row in ipairs(typeRows) do
    local cb = CreateFrame("CheckButton", "RTSW_TypeCheck" .. idx, RTSW_TypePanel, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", RTSW_TypePanel, "TOPLEFT", 8, -25 - (idx - 1) * 22)
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb.rowKey = row.key
    local lbl = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    lbl:SetText(row.label)
    cb:SetScript("OnClick", function()
        if not RareTrackerSW_ShowTypes then RareTrackerSW_ShowTypes = {} end
        RareTrackerSW_ShowTypes[this.rowKey] = this:GetChecked() and true or false
        RareTrackerSW_Map:UpdateWorldMap()
    end)
    tpChecks[row.key] = cb
end

local cbDead = CreateFrame("CheckButton", "RTSW_TypeCheckDead", RTSW_TypePanel, "UICheckButtonTemplate")
cbDead:SetPoint("TOPLEFT", RTSW_TypePanel, "TOPLEFT", 8, -25 - table.getn(typeRows) * 22 - 6)
cbDead:SetWidth(20)
cbDead:SetHeight(20)
local cbDeadLbl = cbDead:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
cbDeadLbl:SetPoint("LEFT", cbDead, "RIGHT", 2, 0)
cbDeadLbl:SetText("|cFFAAAAAA☾ Mostrar Mortos|r")
cbDead:SetScript("OnClick", function()
    RareTrackerSW_ShowDeadOnMap = this:GetChecked() and true or false
    RareTrackerSW_Map:UpdateWorldMap()
end)

RTSW_TypePanel:SetScript("OnShow", function()
    for _, row in ipairs(typeRows) do
        local cb = tpChecks[row.key]
        if cb then cb:SetChecked(TypeVisible(row.key)) end
    end
    cbDead:SetChecked(RareTrackerSW_ShowDeadOnMap ~= false)
end)

function RareTrackerSW_Map:ToggleTypePanel()
    if RTSW_TypePanel:IsShown() then
        RTSW_TypePanel:Hide()
    else
        -- Abre acima do botão que abriu (lastPanelAnchor definido por cada botão)
        RTSW_TypePanel:ClearAllPoints()
        local anchor = RTSW_TypePanel.lastAnchor or RTSW_MapBtn
        RTSW_TypePanel:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 4)
        RTSW_TypePanel:Show()
    end
end

SLASH_RTSWTYPE1 = "/rtswtype"
SLASH_RTSWTYPE2 = "/rtswtypes"
SlashCmdList["RTSWTYPE"] = function() RareTrackerSW_Map:ToggleTypePanel() end

-- ============================================================
-- BOTÃO NO MAPA MUNDIAL — abre painel de filtros
-- ============================================================
local RTSW_MapBtn = CreateFrame("Button", "RTSW_MapBtn", WorldMapFrame)
RTSW_MapBtn:SetWidth(80)
RTSW_MapBtn:SetHeight(22)
RTSW_MapBtn:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", -4, 4)
RTSW_MapBtn:SetFrameStrata("DIALOG")
RTSW_MapBtn:SetFrameLevel(10)

local mbBg = RTSW_MapBtn:CreateTexture(nil, "BACKGROUND")
mbBg:SetAllPoints()
mbBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")

local mbBorder = RTSW_MapBtn:CreateTexture(nil, "BORDER")
mbBorder:SetPoint("TOPLEFT",     RTSW_MapBtn, "TOPLEFT",     -1,  1)
mbBorder:SetPoint("BOTTOMRIGHT", RTSW_MapBtn, "BOTTOMRIGHT",  1, -1)
mbBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")

local mbText = RTSW_MapBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
mbText:SetAllPoints()
mbText:SetJustifyH("CENTER")
mbText:SetText("|cFFFFD700★|r Raros")

local mbHL = RTSW_MapBtn:CreateTexture(nil, "HIGHLIGHT")
mbHL:SetAllPoints()
mbHL:SetTexture(1, 1, 1, 0.1)
mbHL:SetBlendMode("ADD")

RTSW_MapBtn:SetScript("OnClick", function()
    if RareTrackerSW_Menu and not RareTrackerSW_Menu:IsShown() then
        RareTrackerSW_Menu:Show()
        local z = RareTrackerSW and RareTrackerSW:GetNormalizedZone(GetRealZoneText()) or GetRealZoneText()
        RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Data[z] and z or "Tanaris")
    end
    if RareTrackerSW_Menu then RareTrackerSW_Menu:ShowTab("config") end
end)
RTSW_MapBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText("|cFF2ecc40KZ|r |cFFFFD700RareTracker|r")
    GameTooltip:AddLine("Abre filtros de tipo de raro", 0.9, 0.9, 0.9)
    GameTooltip:Show()
end)
RTSW_MapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ============================================================
-- BOTÃO DO MINIMAPA — arrastável, também abre o painel de filtros
-- ============================================================
local RTSW_MM_RADIUS = 80

local function RTSW_MM_SetPos(angle)
    RTSW_MinimapBtn:ClearAllPoints()
    local rad = math.rad(angle)
    RTSW_MinimapBtn:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(rad) * RTSW_MM_RADIUS,
        math.sin(rad) * RTSW_MM_RADIUS)
end

RTSW_MinimapBtn = CreateFrame("Button", "RTSW_MinimapBtn", Minimap)
RTSW_MinimapBtn:SetWidth(28)
RTSW_MinimapBtn:SetHeight(28)
RTSW_MinimapBtn:SetFrameStrata("MEDIUM")
RTSW_MinimapBtn:SetFrameLevel(8)

-- Fundo escuro arredondado (estilo botão de addon padrão)
local mmBg = RTSW_MinimapBtn:CreateTexture(nil, "BACKGROUND")
mmBg:SetAllPoints()
mmBg:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Background")

-- Ícone centralizado (com margem pra ficar dentro do fundo arredondado)
local mmIcon = RTSW_MinimapBtn:CreateTexture(nil, "ARTWORK")
mmIcon:SetPoint("TOPLEFT",     RTSW_MinimapBtn, "TOPLEFT",     3, -3)
mmIcon:SetPoint("BOTTOMRIGHT", RTSW_MinimapBtn, "BOTTOMRIGHT", -3,  3)
mmIcon:SetTexture("Interface\\Icons\\Ability_Tracking")

-- Brilho ao hover
local mmHL = RTSW_MinimapBtn:CreateTexture(nil, "HIGHLIGHT")
mmHL:SetAllPoints()
mmHL:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
mmHL:SetBlendMode("ADD")

RTSW_MinimapBtn:SetScript("OnClick", function()
    RareTrackerSW_MenuHandler("")
end)
RTSW_MinimapBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("|cffffff00RareTracker-SW|r |cff888888v" .. (RTSW_VERSION or "?") .. "|r")
    GameTooltip:AddLine("Clique para abrir/fechar", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Arraste para mover", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
RTSW_MinimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

RTSW_MinimapBtn:RegisterForDrag("LeftButton")
RTSW_MinimapBtn:SetScript("OnDragStart", function()
    this:SetScript("OnUpdate", function()
        local cx, cy = Minimap:GetCenter()
        local mx, my = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        local angle = math.deg(math.atan2((my / s) - cy, (mx / s) - cx))
        RareTrackerSW_MinimapAngle = angle
        RTSW_MM_SetPos(angle)
    end)
end)
RTSW_MinimapBtn:SetScript("OnDragStop", function()
    this:SetScript("OnUpdate", nil)
end)

local mmInit = CreateFrame("Frame")
mmInit:RegisterEvent("PLAYER_LOGIN")
mmInit:SetScript("OnEvent", function()
    RTSW_MM_SetPos(RareTrackerSW_MinimapAngle or 225)
end)

-- Debug: /rtswdbg — diagnóstico do mapa
SLASH_RTSWDBG1 = "/rtswdbg"
SlashCmdList["RTSWDBG"] = function()
    local msg = function(t) DEFAULT_CHAT_FRAME:AddMessage("[RTSW] " .. t) end
    local cIdx = GetCurrentMapContinent()
    local zIdx = GetCurrentMapZone()
    msg("Cont=" .. tostring(cIdx) .. " Zone=" .. tostring(zIdx))
    local zones = { GetMapZones(cIdx or 1) }
    local zName = zones[zIdx] or "nil"
    msg("ZoneName=" .. zName)
    if RareTrackerSW and RareTrackerSW.GetNormalizedZone then
        zName = RareTrackerSW:GetNormalizedZone(zName)
        msg("Normalized=" .. zName)
    end
    local count = 0
    if RareTrackerSW_Data and RareTrackerSW_Data[zName] then
        for _ in pairs(RareTrackerSW_Data[zName]) do count = count + 1 end
    end
    msg("StaticMobs=" .. count)
    local mW = WorldMapDetailFrame:GetWidth()
    local mH = WorldMapDetailFrame:GetHeight()
    msg("MapSize=" .. mW .. "x" .. mH)
    msg("Pins criados=" .. table.getn(RareTrackerSW_Map.pins))
    -- Força update
    RareTrackerSW_Map:UpdateWorldMap()
    msg("UpdateWorldMap() executado")
end

-- ============================================================
-- QUICK PANEL — clique no pin do mapa abre ficha do mob
-- ============================================================
local RTSW_QP = CreateFrame("Frame", "RTSW_QuickPanel", WorldMapFrame)
RTSW_QP:SetWidth(265)
RTSW_QP:SetHeight(275)
RTSW_QP:SetFrameStrata("TOOLTIP")
RTSW_QP:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
RTSW_QP:SetBackdropColor(0.10, 0.06, 0.03, 1.0)
RTSW_QP:EnableMouse(true)
RTSW_QP:SetMovable(true)
RTSW_QP:RegisterForDrag("LeftButton")
RTSW_QP:SetScript("OnDragStart", function() this:StartMoving() end)
RTSW_QP:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
RTSW_QP:Hide()

local qpCloseBtn = CreateFrame("Button", nil, RTSW_QP, "UIPanelCloseButton")
qpCloseBtn:SetPoint("TOPRIGHT", RTSW_QP, "TOPRIGHT", -2, -2)
qpCloseBtn:SetScript("OnClick", function() RTSW_QP:Hide() end)

local qpTitle = RTSW_QP:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
qpTitle:SetPoint("TOPLEFT", 8, -10)
qpTitle:SetPoint("TOPRIGHT", -28, -10)
qpTitle:SetJustifyH("LEFT")
RTSW_QP.title = qpTitle

local qpDiv = RTSW_QP:CreateTexture(nil, "ARTWORK")
qpDiv:SetTexture(0.8, 0.7, 0.2, 0.5)
qpDiv:SetHeight(1) qpDiv:SetWidth(245)
qpDiv:SetPoint("TOPLEFT", 8, -30)

RTSW_QP.lines = {}
for i = 1, 12 do
    local fs = RTSW_QP:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetWidth(248)
    fs:SetJustifyH("LEFT")
    fs:SetPoint("TOPLEFT", 8, -33 - (i-1)*17)
    RTSW_QP.lines[i] = fs
end

-- Botões invisíveis de hover sobre linhas de loot (para tooltip do item)
RTSW_QP.lootBtns = {}
for i = 1, 8 do
    local lb = CreateFrame("Button", nil, RTSW_QP)
    lb:SetWidth(248)
    lb:SetHeight(16)
    lb:EnableMouse(true)
    lb:SetFrameLevel(RTSW_QP:GetFrameLevel() + 10)
    lb:SetScript("OnEnter", function()
        if this.itemId and this.itemId ~= "0" then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. this.itemId .. ":0:0:0")
            GameTooltip:Show()
        elseif this.itemName then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(this.itemName, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    lb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    lb:Hide()
    RTSW_QP.lootBtns[i] = lb
end

local qpDeadBtn = CreateFrame("Button", nil, RTSW_QP, "UIPanelButtonTemplate")
qpDeadBtn:SetWidth(115) qpDeadBtn:SetHeight(22)
qpDeadBtn:SetPoint("BOTTOMLEFT", 8, 8)
qpDeadBtn:SetText("Marcar Morto")
qpDeadBtn:SetScript("OnClick", function()
    local n = RTSW_QP.mobName
    if n and RareTrackerSW then
        RareTrackerSW:RecordDeath(n, false, nil, true)
        RTSW_OpenQuickPanel(RTSW_QP.currentPin)
        RareTrackerSW_Map:UpdateWorldMap()
    end
end)

local qpMoveBtn = CreateFrame("Button", nil, RTSW_QP, "UIPanelButtonTemplate")
qpMoveBtn:SetWidth(115) qpMoveBtn:SetHeight(22)
qpMoveBtn:SetPoint("BOTTOMRIGHT", -8, 8)
qpMoveBtn:SetText("|cff00ff88Mover Pin|r")

qpMoveBtn:SetScript("OnClick", function()
    local pin = RTSW_QP.currentPin
    if not pin then return end
    RTSW_QP:Hide()

    pin.texture:SetVertexColor(0, 1, 0.5)
    pin.unlocked = true
    pin:SetMovable(true)
    pin:RegisterForDrag("LeftButton")

    pin:SetScript("OnDragStart", function()
        WorldMapTooltip:Hide()
        this:StartMoving()
    end)
    pin:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        this:SetMovable(false)
        this.unlocked = false
        this:SetScript("OnDragStart", nil)
        this:SetScript("OnDragStop", nil)

        local mapLeft = WorldMapDetailFrame:GetLeft()
        local mapTop  = WorldMapDetailFrame:GetTop()
        local mapW    = WorldMapDetailFrame:GetWidth()
        local mapH    = WorldMapDetailFrame:GetHeight()
        local pinX, pinY = this:GetCenter()
        local newX = math.max(0.01, math.min(0.99, (pinX - mapLeft) / mapW))
        local newY = math.max(0.01, math.min(0.99, (mapTop - pinY) / mapH))

        local n    = this.mobName
        local zone = this.mobZone
        if n and zone then
            if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
            if not RareTrackerSW_DB[zone] then RareTrackerSW_DB[zone] = {} end
            if not RareTrackerSW_DB[zone][n] then
                local base = RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][n]
                if base then
                    RareTrackerSW_DB[zone][n] = { level=base.level, type=base.type, respawn=base.respawn, id=base.id, faction=base.faction or "N", x=newX, y=newY }
                else
                    RareTrackerSW_DB[zone][n] = { x=newX, y=newY }
                end
            else
                RareTrackerSW_DB[zone][n].x = newX
                RareTrackerSW_DB[zone][n].y = newY
            end
            if RareTrackerSW_Sync then RareTrackerSW_Sync:SendFound(n, newX, newY) end
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r Posicao de |cffff8000" .. n .. "|r salva: " .. string.format("%.1f, %.1f", newX*100, newY*100))
        end
        RareTrackerSW_Map:UpdateWorldMap()
    end)

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00[RareTracker]|r Arraste o pin verde para a posicao correta.")
end)

function RTSW_OpenQuickPanel(pin)
    if not pin or not pin.mobName then return end
    RTSW_QP.currentPin = pin
    RTSW_QP.mobName    = pin.mobName

    local n = pin.mobName
    local d = pin.mobData
    if not d then return end

    local dt  = GetDisplayType(d, n)
    local cfg = pinTypeConfig[dt] or pinTypeConfig.rare
    local hex = string.format("%02x%02x%02x", math.floor(cfg.r*255), math.floor(cfg.g*255), math.floor(cfg.b*255))
    RTSW_QP.title:SetText("|cff" .. hex .. n .. "|r")

    for _, fs in ipairs(RTSW_QP.lines) do fs:SetText("") end
    for _, lb in ipairs(RTSW_QP.lootBtns) do lb:Hide() end

    local li  = 0
    local lbi = 1
    local function addLine(text)
        li = li + 1
        if RTSW_QP.lines[li] then RTSW_QP.lines[li]:SetText(text) end
    end
    local function addLootLine(text, itemId, itemName)
        li = li + 1
        if RTSW_QP.lines[li] then RTSW_QP.lines[li]:SetText(text) end
        if lbi <= table.getn(RTSW_QP.lootBtns) then
            local lb = RTSW_QP.lootBtns[lbi]
            lb.itemId   = itemId
            lb.itemName = itemName
            lb:ClearAllPoints()
            lb:SetPoint("TOPLEFT", RTSW_QP, "TOPLEFT", 8, -33 - (li-1)*17)
            lb:Show()
            lbi = lbi + 1
        end
    end

    local typeNames = { rare="Raro", rareelite="Raro Elite", elite="Elite", worldboss="World Boss", custom="Custom", turtlewow="Turtle WoW" }
    addLine("Nível: |cffffffff" .. (d.level or "??") .. "|r   Tipo: |cffffcc00" .. (typeNames[d.type] or "Raro") .. "|r")

    local lvl    = tonumber(d.level) or 60
    local hpMult = (d.type=="worldboss" and 5000) or (d.type=="rareelite" and 250) or (d.type=="elite" and 180) or 120
    addLine("Vida: |cffff4444~" .. lvl*hpMult .. "|r   Respawn: |cff66ff66" .. (d.respawn or "?") .. "|r")

    local pFac = UnitFactionGroup("player")
    local fac  = d.faction or "N"
    local rt   = "|cffffff00Neutro|r"
    if fac == "A" then rt = (pFac=="Alliance") and "|cff3366ffAliado|r" or "|cffff2222Inimigo|r"
    elseif fac == "H" then rt = (pFac=="Horde") and "|cff3366ffAliado|r" or "|cffff2222Inimigo|r" end
    addLine("Reacao: " .. rt .. "   ID: |cff999999" .. (d.id or "0") .. "|r")
    if d.x and d.y then
        addLine("Coords: |cffffffff" .. string.format("%.1f, %.1f", d.x*100, d.y*100) .. "|r")
    end
    addLine("")

    local timer  = RareTrackerSW_Timers and RareTrackerSW_Timers[n] or 0
    local isDead = timer > time()
    if isDead then
        local rem = timer - time()
        local h   = math.floor(rem/3600)
        local m   = math.floor(math.mod(rem,3600)/60)
        local s   = math.floor(math.mod(rem,60))
        local ts  = (h>0 and h.."h "..m.."m") or (m>0 and m.."m "..s.."s") or (s.."s")
        addLine("Status: |cffff4444Morto|r   Renasce: |cffff8800" .. ts .. "|r")
        if RareTrackerSW_Killers and RareTrackerSW_Killers[n] then
            addLine("Morto por: |cffaaaaaa" .. RareTrackerSW_Killers[n] .. "|r")
        end
    else
        addLine("Status: |cff44ff44Vivo|r")
    end

    -- Loot: prefere dados dinâmicos (kills reais), fallback para estático
    local dynDB = RareTrackerSW_LootDB and RareTrackerSW_LootDB[n]
    if dynDB and dynDB.items and table.getn(dynDB.items) > 0 then
        local kills = dynDB.kills or 1
        addLine("")
        addLine("|cffffcc00Loot|r |cffaaaaaa(" .. kills .. " kills)|r:")
        local sorted = {}
        for _, item in ipairs(dynDB.items) do table.insert(sorted, item) end
        table.sort(sorted, function(a,b) return (a.drops or 0) > (b.drops or 0) end)
        for _, item in ipairs(sorted) do
            if li < 12 then
                local pct = string.format("%.0f%%", ((item.drops or 0) / kills) * 100)
                local qColor = (item.quality == 4 and "ffd700") or (item.quality == 3 and "0099ff") or (item.quality == 2 and "1eff00") or "ffffff"
                addLootLine("  |cff" .. qColor .. item.name .. "|r |cff888888(" .. pct .. ")|r", item.id, item.name)
            end
        end
    else
        local loot = RareTrackerSW_Loot and RareTrackerSW_Loot[n]
        if loot and table.getn(loot) > 0 then
            addLine("")
            addLine("|cffffcc00Loot:|r |cffaaaaaa(estatico)|r")
            for _, item in ipairs(loot) do
                if li < 12 then
                    addLootLine("  " .. item.name .. " |cff888888(" .. (item.chance or "") .. ")|r", item.id, item.name)
                end
            end
        end
    end

    RTSW_QP:ClearAllPoints()
    local pinRight = pin:GetRight() or 0
    local mapRight = WorldMapDetailFrame:GetRight() or 800
    if pinRight + 275 > mapRight then
        RTSW_QP:SetPoint("TOPRIGHT", pin, "TOPLEFT", -4, 10)
    else
        RTSW_QP:SetPoint("TOPLEFT", pin, "TOPRIGHT", 4, 10)
    end
    RTSW_QP:Show()
end

