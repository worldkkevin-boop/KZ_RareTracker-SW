-- RareTracker-SW Alerts Logic

-- Mobs já alertados nesta sessão de zona — limpa ao mudar de zona
local RTSW_AlertedMobs = {}
local alertZoneCleaner = CreateFrame("Frame")
alertZoneCleaner:RegisterEvent("ZONE_CHANGED_NEW_AREA")
alertZoneCleaner:SetScript("OnEvent", function()
    RTSW_AlertedMobs = {}
end)

RareTrackerSW_Alert = CreateFrame("Frame", "RareTrackerSW_AlertFrame", UIParent)
RareTrackerSW_Alert:SetWidth(320)
RareTrackerSW_Alert:SetHeight(115)
RareTrackerSW_Alert:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
RareTrackerSW_Alert:SetFrameStrata("FULLSCREEN_DIALOG")
RareTrackerSW_Alert:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
RareTrackerSW_Alert:SetBackdropColor(0.05, 0.03, 0.01, 0.97)
RareTrackerSW_Alert:SetBackdropBorderColor(1, 0.8, 0, 1)
RareTrackerSW_Alert:EnableMouse(true)
RareTrackerSW_Alert:SetMovable(true)
RareTrackerSW_Alert:RegisterForDrag("LeftButton")
RareTrackerSW_Alert:SetScript("OnDragStart", function() this:StartMoving() end)
RareTrackerSW_Alert:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
RareTrackerSW_Alert:Hide()

-- Ícone
local icon = RareTrackerSW_Alert:CreateTexture(nil, "ARTWORK")
icon:SetWidth(56)
icon:SetHeight(56)
icon:SetPoint("LEFT", RareTrackerSW_Alert, "LEFT", 16, 8)
icon:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01")
icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
RareTrackerSW_Alert.icon = icon

local iconBg = RareTrackerSW_Alert:CreateTexture(nil, "BACKGROUND")
iconBg:SetAllPoints(icon)
iconBg:SetTexture(0, 0, 0, 0.5)

-- Título
local titleText = RareTrackerSW_Alert:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
titleText:SetPoint("RIGHT", RareTrackerSW_Alert, "RIGHT", -30, 0)
titleText:SetJustifyH("CENTER")
titleText:SetText("|cffff0000RARO ENCONTRADO!|r")
RareTrackerSW_Alert.title = titleText

-- Nome do mob
local mobNameText = RareTrackerSW_Alert:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
mobNameText:SetPoint("TOP", titleText, "BOTTOM", 0, -4)
mobNameText:SetPoint("LEFT", icon, "RIGHT", 10, 0)
mobNameText:SetPoint("RIGHT", RareTrackerSW_Alert, "RIGHT", -30, 0)
mobNameText:SetJustifyH("CENTER")
mobNameText:SetText("Nome do Mob")
RareTrackerSW_Alert.mobNameText = mobNameText

-- Flash effect
local flash = CreateFrame("Frame", "RareTrackerSW_FlashFrame", UIParent)
flash:SetAllPoints(UIParent)
flash:SetFrameStrata("BACKGROUND")
flash:Hide()

local flashTex = flash:CreateTexture(nil, "BACKGROUND")
flashTex:SetAllPoints()
flashTex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
flashTex:SetVertexColor(1, 0, 0, 0.5)

-- Botão X fechar
local closeBtn = CreateFrame("Button", "RareTrackerSW_Alert_CloseBtn", RareTrackerSW_Alert, "UIPanelCloseButton")
closeBtn:SetWidth(32)
closeBtn:SetHeight(32)
closeBtn:SetPoint("TOPRIGHT", RareTrackerSW_Alert, "TOPRIGHT", -2, -2)
closeBtn:SetScript("OnClick", function()
    RareTrackerSW_Alert:Hide()
    RareTrackerSW_Alert:SetScript("OnUpdate", nil)
end)

-- Botão ALVEJAR (esquerda)
local targetBtn = CreateFrame("Button", "RareTrackerSW_Alert_TargetBtn", RareTrackerSW_Alert, "UIPanelButtonTemplate")
targetBtn:SetWidth(120)
targetBtn:SetHeight(22)
targetBtn:SetPoint("BOTTOMLEFT", RareTrackerSW_Alert, "BOTTOMLEFT", 10, 10)
targetBtn:SetText("|cff00ff88Alvejar|r")
targetBtn:SetScript("OnClick", function()
    local n = RareTrackerSW_Alert.currentMob
    if n then
        if RTSW_SeekMob then
            RTSW_SeekMob(n)
        else
            TargetByName(n)
        end
    end
end)

-- Botão SALVAR/ATUALIZAR (direita)
local addBtn = CreateFrame("Button", "RareTrackerSW_Alert_AddBtn", RareTrackerSW_Alert, "UIPanelButtonTemplate")
addBtn:SetWidth(155)
addBtn:SetHeight(22)
addBtn:SetPoint("BOTTOMRIGHT", RareTrackerSW_Alert, "BOTTOMRIGHT", -10, 10)
addBtn:SetText("ATUALIZAR POSIÇÃO")
addBtn:SetScript("OnClick", function()
    if RareTrackerSW and RareTrackerSW.AddCurrentTargetToDB then
        RareTrackerSW:AddCurrentTargetToDB()
        RareTrackerSW_Alert:Hide()
        RareTrackerSW_Alert:SetScript("OnUpdate", nil)
    end
end)

function RareTrackerSW_Alert:UpdateAddButton(name)
    local zone = GetRealZoneText()
    if RareTrackerSW then zone = RareTrackerSW:GetNormalizedZone(zone) end
    local exists = (RareTrackerSW_Data and RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][name]) or
                   (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][name])
    addBtn:SetText(exists and "ATUALIZAR POSIÇÃO" or "SALVAR NO MAPA")
end

function RareTrackerSW_Alert:ShowAlert(name)
    if not name then return end
    if RareTrackerSW_AlertEnabled == false then return end
    if RTSW_AlertedMobs[name] then return end         -- já alertou nesta zona
    if self:IsShown() and self.currentMob == name then return end

    if self.UpdateAddButton then self:UpdateAddButton(name) end

    local mobType = "rare"
    if RareTrackerSW and RareTrackerSW.IsRare then
        local found, zone, realName = RareTrackerSW:IsRare(name)
        if found and zone then
            local data = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][realName]) or
                         (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][realName])
            if data then mobType = data.type or "rare" end
        end
    end

    local typeIcons = {
        rare      = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
        rareelite = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        elite     = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        worldboss = "Interface\\Icons\\INV_Misc_Head_Dragon_02",
        custom    = "Interface\\Icons\\INV_Misc_MonsterScales_13",
    }
    local typeTitles = {
        rare      = "|cffff0000RARO ENCONTRADO!|r",
        rareelite = "|cff4488ffRARO ELITE!|r",
        elite     = "|cffffcc00ELITE!|r",
        worldboss = "|cffff2222WORLD BOSS!!!|r",
        custom    = "|cff9370dbRARO CUSTOMIZADO!|r",
    }
    local typeNameColors = {
        rare      = {1, 0.8, 0},
        rareelite = {0.5, 0.8, 1},
        elite     = {1, 0.8, 0},
        worldboss = {1, 0.2, 0.2},
        custom    = {0.8, 0.4, 1},
    }
    local typeBorderColors = {
        rare      = {1, 0.8, 0, 1},
        rareelite = {0.4, 0.7, 1, 1},
        elite     = {1, 0.8, 0, 1},
        worldboss = {1, 0.1, 0.1, 1},
        custom    = {0.8, 0.4, 1, 1},
    }
    local typeSounds = {
        rare      = "Sound\\Interface\\AuctionWindowOpen.wav",
        rareelite = "Sound\\Interface\\AuctionWindowOpen.wav",
        elite     = "Sound\\Interface\\AuctionWindowOpen.wav",
        worldboss = "Sound\\Spells\\PVPFlagTaken.wav",
        custom    = "Sound\\Spells\\PVPFlagTaken.wav",
    }

    local t = mobType
    self.currentMob = name
    RTSW_AlertedMobs[name] = true

    self.mobNameText:SetText(name)
    self.title:SetText(typeTitles[t] or typeTitles.rare)
    local nc = typeNameColors[t] or typeNameColors.rare
    self.mobNameText:SetTextColor(nc[1], nc[2], nc[3])
    local bc = typeBorderColors[t] or typeBorderColors.rare
    self:SetBackdropBorderColor(bc[1], bc[2], bc[3], bc[4])
    self.icon:SetTexture(typeIcons[t] or typeIcons.rare)

    if RareTrackerSW_SoundEnabled ~= false then
        PlaySoundFile(typeSounds[t] or typeSounds.rare)
    end

    -- Pulso de entrada (1 segundo)
    local animTime = 0
    self:SetScript("OnUpdate", function()
        animTime = animTime + arg1
        local scale = 1 + math.sin(animTime * 6) * 0.05
        if scale > 1.05 then scale = 1.05 end
        if scale < 0.95 then scale = 0.95 end
        this:SetScale(scale)
        if animTime > 1.0 then
            this:SetScale(1)
            this:SetScript("OnUpdate", nil)
        end
    end)

    self:Show()

    -- Flash na tela
    flash:Show()
    local startTime = GetTime()
    flash:SetScript("OnUpdate", function()
        local elapsed = GetTime() - startTime
        if elapsed > 1.5 then
            this:Hide()
            this:SetScript("OnUpdate", nil)
        else
            local alpha = (1 - (elapsed / 1.5)) * 0.6
            if t == "custom" or t == "turtlewow" then
                flashTex:SetVertexColor(0.5, 0, 1, alpha)
            elseif t == "worldboss" then
                flashTex:SetVertexColor(1, 0.3, 0, alpha)
            else
                flashTex:SetVertexColor(1, 0.8, 0, alpha)
            end
        end
    end)
end
