-- RareTracker-SW: Menu UI com abas (Raros / Configurações / Ranking / Loot DB)
RareTrackerSW_Menu = CreateFrame("Frame", "RTSW_FinalFrame", UIParent)
RareTrackerSW_Timers = RareTrackerSW_Timers or {}
RareTrackerSW_AlliedMobs = RareTrackerSW_AlliedMobs or {}

-- ===== HOVER TIP (fundo sólido, substituindo GameTooltip) =====
local RTSW_HoverFrame = nil

local function RTSW_GetHoverFrame()
    if RTSW_HoverFrame then return RTSW_HoverFrame end
    local f = CreateFrame("Frame", "RTSW_HoverTip", UIParent)
    f:SetFrameStrata("TOOLTIP")
    f:SetWidth(240)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.05, 0.03, 0.01, 1.0)
    f:SetBackdropBorderColor(0.8, 0.7, 0.2, 1.0)
    f:Hide()
    f.fsList = {}
    RTSW_HoverFrame = f
    return f
end

local function RTSW_ShowHoverTip(anchor, textLines)
    local f = RTSW_GetHoverFrame()
    local PAD_X, PAD_TOP, PAD_BOT, LINE_H = 8, 7, 7, 14
    local yOff = PAD_TOP
    for i, t in ipairs(textLines) do
        local fs = f.fsList[i]
        if not fs then
            fs = f:CreateFontString(nil, "OVERLAY", i == 1 and "GameFontNormal" or "GameFontNormalSmall")
            fs:SetWidth(222) fs:SetJustifyH("LEFT")
            f.fsList[i] = fs
        end
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", f, "TOPLEFT", PAD_X, -yOff)
        fs:SetText(t)
        fs:Show()
        yOff = yOff + (i == 1 and LINE_H + 2 or LINE_H)
    end
    for i = table.getn(textLines) + 1, table.getn(f.fsList) do
        f.fsList[i]:Hide()
    end
    f:SetHeight(yOff + PAD_BOT)
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -6, 0)
    f:Show()
end

local function RTSW_HideHoverTip()
    if RTSW_HoverFrame then RTSW_HoverFrame:Hide() end
end

-- ===== EXPORT / IMPORT (formato RTSW1) =====
function RTSW_GenerateExportCode()
    if not RareTrackerSW_LootDB then return "RTSW1" end
    local parts = {"RTSW1"}
    for mobName, data in pairs(RareTrackerSW_LootDB) do
        if data.kills and data.kills > 0 then
            -- Busca NPC ID e coordenadas do banco de dados do addon
            local npcId = "0"
            local cx, cy = 0, 0
            local isRare, zone, realName = RareTrackerSW and RareTrackerSW:IsRare(mobName)
            if isRare and zone then
                local md = (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][realName]) or
                           (RareTrackerSW_DB and RareTrackerSW_DB[zone] and RareTrackerSW_DB[zone][realName])
                if md then
                    npcId = tostring(md.id or "0")
                    cx = (md.x or 0) * 100
                    cy = (md.y or 0) * 100
                end
            end

            local itemParts = {}
            if data.items then
                for _, item in ipairs(data.items) do
                    if item.name and item.name ~= "" then
                        table.insert(itemParts,
                            (item.id or "0") .. ":" .. item.name .. ":" ..
                            (item.quality or 1) .. ":" .. (item.drops or 1))
                    end
                end
            end
            local mobKey = string.format("%s@%s@%.1f@%.1f", mobName, npcId, cx, cy)
            local mobStr = mobKey .. "," .. (data.kills or 0)
            if table.getn(itemParts) > 0 then
                mobStr = mobStr .. "," .. table.concat(itemParts, "|")
            end
            table.insert(parts, mobStr)
        end
    end
    return table.concat(parts, ";")
end

function RTSW_ImportCode(code)
    if not code or code == "" then return 0 end
    if not string.find(code, "^RTSW1") then return 0 end
    if not RareTrackerSW_LootDB then RareTrackerSW_LootDB = {} end
    local newItems = 0
    local entryIdx = 0
    for entry in string.gfind(code, "[^;]+") do
        entryIdx = entryIdx + 1
        if entryIdx > 1 then
            local _, _, mobMeta, rest = string.find(entry, "^([^,]+),(.*)")
            -- Extrai nome real (ignora @npcId@x@y se presente)
            local mobName = mobMeta
            if mobMeta then
                local atPos = string.find(mobMeta, "@")
                if atPos then mobName = string.sub(mobMeta, 1, atPos - 1) end
            end
            local _, _, _ = nil, nil, nil  -- reset captures
            if mobName and rest then
                local _, _, killsStr, itemsStr = string.find(rest, "^(%d+),(.*)")
                if not killsStr then
                    _, _, killsStr = string.find(rest, "^(%d+)$")
                    itemsStr = ""
                end
                local kills = tonumber(killsStr) or 0
                if not RareTrackerSW_LootDB[mobName] then
                    RareTrackerSW_LootDB[mobName] = { kills = 0, items = {} }
                end
                if kills > (RareTrackerSW_LootDB[mobName].kills or 0) then
                    RareTrackerSW_LootDB[mobName].kills = kills
                end
                if itemsStr and itemsStr ~= "" then
                    for itemEntry in string.gfind(itemsStr, "[^|]+") do
                        local _, _, itemId, itemName, quality, drops =
                            string.find(itemEntry, "^([^:]+):([^:]+):([^:]+):(%d+)")
                        if itemId and itemName then
                            local qual = tonumber(quality) or 1
                            local dr   = tonumber(drops) or 1
                            local found = false
                            for _, existing in ipairs(RareTrackerSW_LootDB[mobName].items) do
                                if existing.name == itemName then
                                    existing.drops = math.max(existing.drops or 0, dr)
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(RareTrackerSW_LootDB[mobName].items,
                                    { id=itemId, name=itemName, quality=qual, drops=dr })
                                newItems = newItems + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return newItems
end

function RareTrackerSW_Menu:Init()
    self:SetWidth(600)
    self:SetHeight(450)
    self:SetPoint("CENTER", UIParent, "CENTER")
    self:SetFrameStrata("DIALOG")
    self:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self:SetBackdropColor(0.10, 0.06, 0.03, 1.0)
    self:EnableMouse(true)
    self:EnableKeyboard(false)
    self:SetMovable(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function() this:StartMoving() end)
    self:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    self:SetScript("OnKeyDown", function()
        if arg1 == "ESCAPE" then this:Hide() end
    end)

    -- Título
    local title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", self, "TOP", 0, -14)
    title:SetText("|cFF2ecc40KZ|r |cffffff00RareTracker-SW|r |cff888888v" .. (RTSW_VERSION or "?") .. "|r")

    local closeBtn = CreateFrame("Button", nil, self, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -5, -5)

    -- Abas
    local tabDefs = {
        { key="raros",  label="|cffffff00Raros|r" },
        { key="config", label="Configurações" },
        { key="loot",   label="Loot DB" },
    }
    self.tabBtns = {}
    for i, td in ipairs(tabDefs) do
        local btn = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
        btn:SetWidth(130) btn:SetHeight(22)
        btn:SetPoint("TOPLEFT", self, "TOPLEFT", 15 + (i-1)*135, -36)
        btn:SetText(td.label)
        local key = td.key
        btn:SetScript("OnClick", function() RareTrackerSW_Menu:ShowTab(key) end)
        self.tabBtns[td.key] = btn
    end

    -- Divisor dourado abaixo das abas
    local tabDiv = self:CreateTexture(nil, "ARTWORK")
    tabDiv:SetTexture(0.8, 0.7, 0.2, 0.5)
    tabDiv:SetHeight(1) tabDiv:SetWidth(568)
    tabDiv:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -61)

    -- ===== ABA RAROS =====
    local rarosPanel = CreateFrame("Frame", nil, self)
    rarosPanel:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -63)
    rarosPanel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 28)
    self.rarosPanel = rarosPanel

    local vline = rarosPanel:CreateTexture(nil, "ARTWORK")
    vline:SetTexture(0.8, 0.7, 0.2, 0.5)
    vline:SetWidth(1) vline:SetHeight(310)
    vline:SetPoint("TOPLEFT", rarosPanel, "TOPLEFT", 200, -14)

    local zoneHeader = rarosPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zoneHeader:SetPoint("TOPLEFT", rarosPanel, "TOPLEFT", 20, -3)
    zoneHeader:SetText("|cffaaaaaa— Zonas —|r")

    local searchLabel = rarosPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("TOPLEFT", rarosPanel, "TOPLEFT", 215, -3)
    searchLabel:SetText("Pesquisar Raro:")

    local searchBox = CreateFrame("EditBox", nil, rarosPanel)
    searchBox:SetWidth(200) searchBox:SetHeight(20)
    searchBox:SetPoint("TOPLEFT", rarosPanel, "TOPLEFT", 215, -17)
    searchBox:SetFontObject("GameFontHighlight")
    searchBox:SetAutoFocus(false)
    searchBox:SetTextInsets(6, 6, 0, 0)
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    searchBox:SetBackdropColor(0.02, 0.02, 0.05, 1.0)
    searchBox:SetBackdropBorderColor(0.8, 0.7, 0.2, 1)
    searchBox:SetScript("OnTextChanged", function()
        local text = this:GetText()
        if text ~= "" then
            RareTrackerSW_Menu:ShowZoneDetails("GlobalSearch", text)
        else
            RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Menu.lastActualZone or "Tanaris")
        end
    end)
    searchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    self.searchBar = searchBox

    -- Scroll de zonas
    self.zoneScroll = CreateFrame("ScrollFrame", "RTSW_ZoneScroll", rarosPanel, "UIPanelScrollFrameTemplate")
    self.zoneScroll:SetPoint("TOPLEFT", rarosPanel, "TOPLEFT", 15, -20)
    self.zoneScroll:SetWidth(175) self.zoneScroll:SetHeight(295)
    self.zoneScroll:EnableMouseWheel(true)
    self.zoneScroll:SetScript("OnMouseWheel", function()
        local s = this:GetVerticalScroll() - (arg1 * 25)
        if s < 0 then s = 0 end
        local m = this:GetVerticalScrollRange()
        if s > m then s = m end
        this:SetVerticalScroll(s)
    end)
    local zoneContent = CreateFrame("Frame", nil, self.zoneScroll)
    zoneContent:SetWidth(160) zoneContent:SetHeight(1)
    self.zoneScroll:SetScrollChild(zoneContent)
    self.zoneContent = zoneContent
    self.zoneButtons = {}

    -- Scroll de detalhes
    self.detailScroll = CreateFrame("ScrollFrame", "RTSW_DetailScroll", rarosPanel, "UIPanelScrollFrameTemplate")
    self.detailScroll:SetPoint("TOPLEFT", rarosPanel, "TOPLEFT", 210, -40)
    self.detailScroll:SetWidth(358) self.detailScroll:SetHeight(275)
    self.detailScroll:EnableMouseWheel(true)
    self.detailScroll:SetScript("OnMouseWheel", function()
        local s = this:GetVerticalScroll() - (arg1 * 25)
        if s < 0 then s = 0 end
        local m = this:GetVerticalScrollRange()
        if s > m then s = m end
        this:SetVerticalScroll(s)
    end)
    local detailPanel = CreateFrame("Frame", nil, self.detailScroll)
    detailPanel:SetWidth(330) detailPanel:SetHeight(1)
    self.detailScroll:SetScrollChild(detailPanel)
    self.detailPanel = detailPanel
    self.detailPanel.mobs = {}

    -- Botões do rodapé da aba Raros
    local clearBtn = CreateFrame("Button", nil, rarosPanel, "UIPanelButtonTemplate")
    clearBtn:SetPoint("BOTTOMLEFT", rarosPanel, "BOTTOMLEFT", 15, 2)
    clearBtn:SetWidth(120) clearBtn:SetHeight(22)
    clearBtn:SetText("Limpar Timers")
    clearBtn:SetScript("OnClick", function()
        RareTrackerSW_Timers = {}
        RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Menu.lastActualZone)
    end)

    local markBtn = CreateFrame("Button", nil, rarosPanel, "UIPanelButtonTemplate")
    markBtn:SetPoint("BOTTOMRIGHT", rarosPanel, "BOTTOMRIGHT", -15, 2)
    markBtn:SetWidth(120) markBtn:SetHeight(22)
    markBtn:SetText("Marcar Morto")
    markBtn:SetScript("OnClick", function()
        if UnitName("target") then RareTrackerSW:RecordDeath(UnitName("target")) end
    end)

    -- ===== ABA CONFIGURAÇÕES =====
    local configPanel = CreateFrame("Frame", nil, self)
    configPanel:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -63)
    configPanel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 28)
    self.configPanel = configPanel
    configPanel:Hide()

    local function CreateCB(text, var, px, py)
        local cbName = "RTSW_CB_" .. var
        local cb = CreateFrame("CheckButton", cbName, configPanel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", configPanel, "TOPLEFT", px, py)
        getglobal(cbName.."Text"):SetText(text)
        cb:SetChecked(getglobal(var))
        cb:SetScript("OnClick", function()
            local on = this:GetChecked() and true or false
            setglobal(var, on)
            local estado = on and "|cff00ff00ATIVADO|r" or "|cffff4444DESATIVADO|r"
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r " .. text .. ": " .. estado)
            if RareTrackerSW_Map and RareTrackerSW_Map.UpdateWorldMap then RareTrackerSW_Map:UpdateWorldMap() end
        end)
    end

    CreateCB("Alerta Visual",       "RareTrackerSW_AlertEnabled",     10,  -10)
    CreateCB("Som Ativado",         "RareTrackerSW_SoundEnabled",     10,  -38)
    CreateCB("Mostrar Mortos",      "RareTrackerSW_ShowDeadOnMap",   280,  -10)
    CreateCB("Ocultar no mapa ao ignorar", "RareTrackerSW_HideIgnoredOnMap", 280, -38)
    CreateCB("Mensagens no Chat",   "RareTrackerSW_ChatEnabled",     280,  -66)

    local cfgDiv = configPanel:CreateTexture(nil, "ARTWORK")
    cfgDiv:SetTexture(0.8, 0.7, 0.2, 0.35)
    cfgDiv:SetHeight(1) cfgDiv:SetWidth(540)
    cfgDiv:SetPoint("TOPLEFT", configPanel, "TOPLEFT", 10, -95)

    local cfgBtns = {
        { text="? Ajuda", fn=function() RareTrackerSW_Menu:ToggleHelp() end},
        { text="Resetar Ignorados", fn=function()
            RareTrackerSW_AlliedMobs = {}
            RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Menu.lastActualZone)
            if RareTrackerSW_Map then RareTrackerSW_Map:UpdateWorldMap() end
        end},
    }
    local btnW, btnH, cols = 175, 26, 2
    for i, bd in ipairs(cfgBtns) do
        local col = math.mod(i-1, cols)
        local row = math.floor((i-1) / cols)
        local btn = CreateFrame("Button", nil, configPanel, "UIPanelButtonTemplate")
        btn:SetWidth(btnW) btn:SetHeight(btnH)
        btn:SetPoint("TOPLEFT", configPanel, "TOPLEFT", 10 + col*(btnW+5), -105 - row*34)
        btn:SetText(bd.text)
        btn:SetScript("OnClick", bd.fn)
    end

    -- Filtros de tipo (ex-painel flutuante, agora integrado)
    local typeDiv2 = configPanel:CreateTexture(nil, "ARTWORK")
    typeDiv2:SetTexture(0.8, 0.7, 0.2, 0.3)
    typeDiv2:SetHeight(1) typeDiv2:SetWidth(540)
    typeDiv2:SetPoint("TOPLEFT", configPanel, "TOPLEFT", 10, -180)

    local typeLabel = configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    typeLabel:SetPoint("TOPLEFT", configPanel, "TOPLEFT", 10, -190)
    typeLabel:SetText("|cffffcc00Filtros de Tipo no Mapa:|r")

    local typeFilterDefs = {
        { key="rare",      label="|cff1eff00Raro|r" },
        { key="rareelite", label="|cff0070ddRaro Elite|r" },
        { key="elite",     label="|cffff8800Elite|r" },
        { key="worldboss", label="|cffff3333World Boss|r" },
        { key="custom",    label="|cffcc44ffCustom|r" },
    }
    local tfCols, tfW = 3, 175
    self.typeFilterCBs = {}
    for i, td in ipairs(typeFilterDefs) do
        local col = math.mod(i-1, tfCols)
        local row = math.floor((i-1) / tfCols)
        local cbName = "RTSW_TypeCB_" .. td.key
        local cb = CreateFrame("CheckButton", cbName, configPanel, "UICheckButtonTemplate")
        cb:SetWidth(20) cb:SetHeight(20)
        cb:SetPoint("TOPLEFT", configPanel, "TOPLEFT", 10 + col*(tfW+5), -208 - row*24)
        getglobal(cbName.."Text"):SetText(td.label)
        -- Checked por padrão (sem ShowTypes = tudo visível)
        cb:SetChecked(not RareTrackerSW_ShowTypes or RareTrackerSW_ShowTypes[td.key] ~= false)
        local key = td.key
        cb:SetScript("OnClick", function()
            if not RareTrackerSW_ShowTypes then RareTrackerSW_ShowTypes = {} end
            RareTrackerSW_ShowTypes[key] = this:GetChecked() and true or false
            if RareTrackerSW_Map then RareTrackerSW_Map:UpdateWorldMap() end
        end)
        self.typeFilterCBs[td.key] = cb
    end

    -- Mostrar mortos no mapa
    local cbDeadName = "RTSW_TypeCB_Dead"
    local cbDeadMap = CreateFrame("CheckButton", cbDeadName, configPanel, "UICheckButtonTemplate")
    cbDeadMap:SetWidth(20) cbDeadMap:SetHeight(20)
    cbDeadMap:SetPoint("TOPLEFT", configPanel, "TOPLEFT", 10, -259)
    getglobal(cbDeadName.."Text"):SetText("Mostrar Mortos no Mapa")
    cbDeadMap:SetChecked(RareTrackerSW_ShowDeadOnMap ~= false)
    cbDeadMap:SetScript("OnClick", function()
        RareTrackerSW_ShowDeadOnMap = this:GetChecked() and true or false
        if RareTrackerSW_Map then RareTrackerSW_Map:UpdateWorldMap() end
    end)
    self.cbDeadMap = cbDeadMap

    -- Atualizar estados dos filtros ao abrir a aba
    configPanel:SetScript("OnShow", function()
        for key, cb in pairs(RareTrackerSW_Menu.typeFilterCBs or {}) do
            cb:SetChecked(not RareTrackerSW_ShowTypes or RareTrackerSW_ShowTypes[key] ~= false)
        end
        if RareTrackerSW_Menu.cbDeadMap then
            RareTrackerSW_Menu.cbDeadMap:SetChecked(RareTrackerSW_ShowDeadOnMap ~= false)
        end
    end)

    -- ===== ABA LOOT DB =====
    local lootPanel = CreateFrame("Frame", nil, self)
    lootPanel:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -63)
    lootPanel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -16, 28)
    self.lootPanel = lootPanel
    lootPanel:Hide()

    local lootTitle = lootPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    lootTitle:SetPoint("TOP", lootPanel, "TOP", 0, -6)
    lootTitle:SetText("|cffffff00Banco de Loot|r")

    local lootStats = lootPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lootStats:SetPoint("TOP", lootTitle, "BOTTOM", 0, -4)
    lootStats:SetText("|cffaaaaaa—|r")
    self.lootStatsLabel = lootStats

    local exportBtn = CreateFrame("Button", nil, lootPanel, "UIPanelButtonTemplate")
    exportBtn:SetWidth(200) exportBtn:SetHeight(24)
    exportBtn:SetPoint("TOPLEFT", lootPanel, "TOPLEFT", 10, -54)
    exportBtn:SetText("Exportar para o Site")
    exportBtn:SetScript("OnClick", function()
        RareTrackerSW_Menu:ShowExportPopup()
    end)

    local importBtn = CreateFrame("Button", nil, lootPanel, "UIPanelButtonTemplate")
    importBtn:SetWidth(200) importBtn:SetHeight(24)
    importBtn:SetPoint("TOPLEFT", lootPanel, "TOPLEFT", 220, -54)
    importBtn:SetText("Importar do Site")
    importBtn:SetScript("OnClick", function()
        RareTrackerSW_Menu:ShowImportPopup()
    end)

    local lootScroll = CreateFrame("ScrollFrame", "RTSW_LootScroll", lootPanel, "UIPanelScrollFrameTemplate")
    lootScroll:SetPoint("TOPLEFT", lootPanel, "TOPLEFT", 10, -86)
    lootScroll:SetPoint("BOTTOMRIGHT", lootPanel, "BOTTOMRIGHT", -30, 4)
    lootScroll:EnableMouseWheel(true)
    lootScroll:SetScript("OnMouseWheel", function()
        local v = this:GetVerticalScroll() - (arg1 * 25)
        if v < 0 then v = 0 end
        local mx = this:GetVerticalScrollRange()
        if v > mx then v = mx end
        this:SetVerticalScroll(v)
    end)
    local lootContent = CreateFrame("Frame", nil, lootScroll)
    lootContent:SetWidth(510) lootContent:SetHeight(1)
    lootScroll:SetScrollChild(lootContent)
    self.lootContent = lootContent
    self.lootContent.rows = {}

    lootPanel:SetScript("OnShow", function()
        RareTrackerSW_Menu:RefreshLootDB()
    end)

    -- Mostra aba ativa
    function RareTrackerSW_Menu:ShowTab(tab)
        self.rarosPanel:Hide()
        self.configPanel:Hide()
        self.lootPanel:Hide()
        if tab == "raros" then
            self.rarosPanel:Show()
        elseif tab == "config" then
            self.configPanel:Show()
        elseif tab == "loot" then
            self.lootPanel:Show()
        end
        self.activeTab = tab
    end

    RareTrackerSW_Menu:PopulateZones()
    RareTrackerSW_Menu:CreateLinkPopup()
    RareTrackerSW_Menu:Hide()
end

function RareTrackerSW_Menu:PopulateZones()
    for _, b in pairs(RareTrackerSW_Menu.zoneButtons) do b:Hide() end

    local sorted = {}
    for zone in pairs(RareTrackerSW_Data) do if zone ~= "UNKNOWN" then table.insert(sorted, zone) end end
    table.sort(sorted)

    local offset = 0
    for i, zone in ipairs(sorted) do
        local b = self.zoneButtons[i]
        if not b then
            b = CreateFrame("Button", nil, self.zoneContent)
            b:SetWidth(180) b:SetHeight(22)
            b:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
            b:GetHighlightTexture():SetAlpha(0.3)

            local txt = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            txt:SetPoint("LEFT", 10, 0)
            b.text = txt

            b:SetScript("OnMouseWheel", function()
                local s = RareTrackerSW_Menu.zoneScroll
                local val = s:GetVerticalScroll() - (arg1 * 25)
                if val < 0 then val = 0 end
                local m = s:GetVerticalScrollRange()
                if val > m then val = m end
                s:SetVerticalScroll(val)
            end)

            b:SetScript("OnClick", function()
                RareTrackerSW_Menu:ShowZoneDetails(this.zoneName)
                RareTrackerSW_Menu:PopulateZones()
            end)
            table.insert(self.zoneButtons, b)
        end

        b.zoneName = zone
        local mobCount = 0
        if RareTrackerSW_Data[zone] then for _ in pairs(RareTrackerSW_Data[zone]) do mobCount = mobCount + 1 end end
        if RareTrackerSW_DB and RareTrackerSW_DB[zone] then
            for n in pairs(RareTrackerSW_DB[zone]) do
                if not (RareTrackerSW_Data[zone] and RareTrackerSW_Data[zone][n]) then mobCount = mobCount + 1 end
            end
        end
        local countStr = "|cff888888 (" .. mobCount .. ")|r"
        if zone == self.lastActualZone then
            b.text:SetText("|cffffff00" .. zone .. "|r" .. countStr)
        else
            b.text:SetText("|cffcccccc" .. zone .. "|r" .. countStr)
        end

        b:SetPoint("TOPLEFT", 0, -offset)
        b:Show()
        offset = offset + 22
    end
    self.zoneContent:SetHeight(offset > 0 and offset or 1)
    self.zoneScroll:UpdateScrollChildRect()
end

function RareTrackerSW_Menu:ShowZoneDetails(zone, filter)
    if not zone then return end
    if zone ~= "GlobalSearch" then RareTrackerSW_Menu.lastActualZone = zone end
    filter = string.lower(filter or "")

    if RareTrackerSW_Menu.detailPanel.mobs then for _, b in ipairs(RareTrackerSW_Menu.detailPanel.mobs) do b:Hide() end end
    RareTrackerSW_Menu.detailPanel.mobs = {}

    local offset, sorted = 0, {}
    local pFac = UnitFactionGroup("player")
    local pFacCode = (pFac == "Alliance" and "A") or (pFac == "Horde" and "H") or "N"

    if zone == "GlobalSearch" then
        local gsMerged = {}
        for zN, mobs in pairs(RareTrackerSW_Data) do
            gsMerged[zN] = {}
            for mN, mD in pairs(mobs) do gsMerged[zN][mN] = mD end
        end
        if RareTrackerSW_DB then
            for zN, mobs in pairs(RareTrackerSW_DB) do
                if not gsMerged[zN] then gsMerged[zN] = {} end
                for mN, mD in pairs(mobs) do gsMerged[zN][mN] = mD end
            end
        end
        for zN, mobs in pairs(gsMerged) do
            for mN, mD in pairs(mobs) do
                local isFriendly = mD.faction and mD.faction ~= "N" and mD.faction == pFacCode
                local normName = string.gsub(string.gsub(string.lower(mN), "'", ""), " ", "")
                local normFilter = string.gsub(string.gsub(filter, "'", ""), " ", "")
                if not isFriendly and (string.find(string.lower(mN), filter) or string.find(normName, normFilter)) then
                    table.insert(sorted, {name=mN, data=mD, zone=zN})
                end
            end
        end
    else
        local allMobs = {}
        for n, d in pairs(RareTrackerSW_Data[zone] or {}) do allMobs[n] = d end
        if RareTrackerSW_DB and RareTrackerSW_DB[zone] then
            for n, d in pairs(RareTrackerSW_DB[zone]) do allMobs[n] = d end
        end
        for n, d in pairs(allMobs) do
            local isFriendly = d.faction and d.faction ~= "N" and d.faction == pFacCode
            if not isFriendly then
                table.insert(sorted, {name=n, data=d, zone=zone})
            end
        end
    end

    table.sort(sorted, function(a,b) return a.name < b.name end)

    local pinTextures = {
        rare      = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
        rareelite = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        elite     = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        worldboss = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        custom    = "Interface\\Icons\\INV_Misc_MonsterScales_13",
    }
    local pinColors = {
        rare      = {0.12, 1,    0   },
        rareelite = {0,    0.44, 0.87},
        elite     = {1,    0.4,  0   },
        worldboss = {1,    0,    0   },
        custom    = {0.8, 0, 1},
    }
    local function GetDisplayType(mob, name)
        if not mob then return "rare" end
        if mob.type == "custom" then return "custom" end
        local id = tonumber(mob.id) or 0
        return mob.type or "rare"
    end

    for _, item in ipairs(sorted) do
        local n, d = item.name, item.data
        local isIgnored = RareTrackerSW_AlliedMobs[n]

        if not isIgnored then
            local b = CreateFrame("Button", nil, RareTrackerSW_Menu.detailPanel)
            b:SetWidth(310) b:SetHeight(38) b:SetPoint("TOPLEFT", 0, -offset)

            local highlight = b:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
            highlight:SetAlpha(0.2)

            b:EnableMouseWheel(true)
            b:SetScript("OnMouseWheel", function()
                local s = RareTrackerSW_Menu.detailScroll
                local val = s:GetVerticalScroll() - (arg1 * 25)
                if val < 0 then val = 0 end
                local m = s:GetVerticalScrollRange()
                if val > m then val = m end
                s:SetVerticalScroll(val)
            end)
            b:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    if RareTrackerSW and RareTrackerSW.RecordDeath then
                        RareTrackerSW:RecordDeath(n)
                        RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Menu.lastActualZone, RareTrackerSW_Menu.searchBar:GetText())
                    end
                else
                    local url = "https://classicdb.ch/?npc=" .. d.id
                    RareTrackerSW_Menu:ShowLink(url)
                end
            end)

            local dt = GetDisplayType(d, n)
            local tex = b:CreateTexture(nil, "ARTWORK")
            tex:SetWidth(24) tex:SetHeight(24) tex:SetPoint("LEFT", 5, 0)
            tex:SetTexture(pinTextures[dt] or pinTextures.rare)
            local color = pinColors[dt] or pinColors.rare
            tex:SetVertexColor(color[1], color[2], color[3])

            local timer = RareTrackerSW_Timers[n] or 0
            local isDead = (timer > time())
            local statusText
            if isDead then
                local remaining = timer - time()
                local h = math.floor(remaining / 3600)
                local m = math.floor(math.mod(remaining, 3600) / 60)
                local timeLeft = (h > 0) and (h .. "h " .. m .. "m") or (m .. "m")
                statusText = "|cffff4444Morto|r |cffff8800" .. timeLeft .. "|r"
                if RareTrackerSW_Killers and RareTrackerSW_Killers[n] then
                    statusText = statusText .. " |cffaaaaaa(" .. RareTrackerSW_Killers[n] .. ")|r"
                end
            else
                statusText = "|cff44ff44Vivo|r"
            end

            local itemZone = item.zone

            local sBtn = CreateFrame("Button", nil, b, "UIPanelButtonTemplate")
            sBtn:SetWidth(20) sBtn:SetHeight(20) sBtn:SetPoint("RIGHT", -55, 0)
            sBtn:SetText("|cff00ff00S|r")
            sBtn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(this, "ANCHOR_TOP")
                local isC = RareTrackerSW_DB and RareTrackerSW_DB[itemZone] and RareTrackerSW_DB[itemZone][n]
                GameTooltip:SetText(isC and "|cff00ccffAtualizar Posicao|r" or "|cff00ff00Salvar no Mapa|r")
                GameTooltip:AddLine("Usa sua posicao atual como coordenada do mob", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            sBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            sBtn:SetScript("OnClick", function()
                RareTrackerSW:UpdateMobPosition(n, itemZone)
                RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Menu.lastActualZone, RareTrackerSW_Menu.searchBar:GetText())
            end)

            local nameText = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", 35, 0)
            nameText:SetPoint("RIGHT", sBtn, "LEFT", -4, 0)
            nameText:SetJustifyH("LEFT")
            nameText:SetTextColor(color[1], color[2], color[3])
            nameText:SetText(n .. " - " .. statusText)

            local xBtn = CreateFrame("Button", nil, b, "UIPanelButtonTemplate")
            xBtn:SetWidth(20) xBtn:SetHeight(20) xBtn:SetPoint("RIGHT", -30, 0)
            xBtn:SetText("|cffff0000X|r")
            xBtn:SetScript("OnClick", function()
                RareTrackerSW_AlliedMobs[n] = true
                RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Menu.lastActualZone, RareTrackerSW_Menu.searchBar:GetText())
                if RareTrackerSW_Map and RareTrackerSW_Map.UpdateWorldMap then RareTrackerSW_Map:UpdateWorldMap() end
            end)
            xBtn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(this, "ANCHOR_TOP")
                GameTooltip:SetText("|cffff4444Ignorar Raro|r")
                GameTooltip:AddLine("Esconde este raro da lista", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            xBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            local tBtn = CreateFrame("Button", nil, b, "UIPanelButtonTemplate")
            tBtn:SetWidth(20) tBtn:SetHeight(20) tBtn:SetPoint("RIGHT", -5, 0)
            tBtn:SetText("|cffffff00T|r")
            tBtn:SetScript("OnClick", function() TargetByName(n, true) end)
            tBtn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(this, "ANCHOR_TOP")
                GameTooltip:SetText("|cffffff00Targetar Raro|r")
                GameTooltip:AddLine("Seleciona o mob pelo nome", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            tBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            local divLine = b:CreateTexture(nil, "BACKGROUND")
            divLine:SetHeight(1) divLine:SetWidth(295)
            divLine:SetPoint("BOTTOM", 0, 0)
            divLine:SetTexture(0.6, 0.55, 0.2, 0.35)

            b:SetScript("OnEnter", function()
                local c = pinColors[d.type] or pinColors.rare
                local hex = string.format("%02x%02x%02x", c[1]*255, c[2]*255, c[3]*255)
                local typeNames = { rare="Raro", rareelite="Raro Elite", elite="Elite", worldboss="World Boss", custom="Custom" }

                local t2 = RareTrackerSW_Timers[n] or 0
                local dead = (t2 > time())
                local st = dead and "|cffff4444Morto|r" or "|cff44ff44Vivo|r"
                if dead and RareTrackerSW_Killers and RareTrackerSW_Killers[n] then
                    st = st .. " |cffaaaaaa(por " .. RareTrackerSW_Killers[n] .. ")|r"
                end

                local lines = {}
                table.insert(lines, "|cff" .. hex .. n .. "|r")
                table.insert(lines, "Nível: |cffffffff" .. (d.level or "??") .. "|r   Tipo: |cffffcc00" .. (typeNames[d.type] or "Raro") .. "|r")
                table.insert(lines, "Status: " .. st)

                if dead then
                    local rem = t2 - time()
                    local h = math.floor(rem / 3600)
                    local m2 = math.floor(math.mod(rem, 3600) / 60)
                    local s2 = math.floor(math.mod(rem, 60))
                    local tt = (h > 0) and (h.."h "..m2.."m") or (m2 > 0) and (m2.."m "..s2.."s") or (s2.."s")
                    table.insert(lines, "Renasce em: |cff00ff00" .. tt .. "|r")
                else
                    table.insert(lines, "Respawn: |cff66ff66" .. (d.respawn or "?") .. "|r")
                end

                local fac = d.faction or "N"
                local reactText = "|cffffff00N|r"
                if fac == "A" then reactText = (pFac == "Alliance") and "|cff3366ffA|r" or "|cffff2222A|r"
                elseif fac == "H" then reactText = (pFac == "Horde") and "|cff3366ffH|r" or "|cffff2222H|r" end
                table.insert(lines, "Reação: " .. reactText .. "   ID: |cff999999" .. (d.id or "0") .. "|r")

                if d.x and d.y then
                    table.insert(lines, "Local: |cffffffff" .. string.format("%.1f, %.1f", d.x*100, d.y*100) .. "|r")
                end

                local lvl = tonumber(d.level) or 60
                local hpMult = (d.type=="worldboss" and 5000) or (d.type=="rareelite" and 250) or (d.type=="elite" and 180) or 120
                table.insert(lines, "Vida: |cffff8888~" .. lvl*hpMult .. " (Est.)|r")

                local loot = RareTrackerSW_Loot and RareTrackerSW_Loot[n]
                if loot and table.getn(loot) > 0 then
                    table.insert(lines, " ")
                    table.insert(lines, "|cffffcc00Loot:|r")
                    local qualHex = {[0]="999999",[1]="ffffff",[2]="1eff00",[3]="0070dd",[4]="a335ee",[5]="ff8000"}
                    for _, litem in ipairs(loot) do
                        local qh = qualHex[litem.quality or 1] or "ffffff"
                        table.insert(lines, "  |cff" .. qh .. litem.name .. "|r |cff888888(" .. litem.chance .. ")|r")
                    end
                end

                table.insert(lines, " ")
                table.insert(lines, "|cffaaaaaaShift+Clique para marcar MORTO|r")
                RTSW_ShowHoverTip(this, lines)
            end)
            b:SetScript("OnLeave", function() RTSW_HideHoverTip() end)

            b:Show()
            table.insert(self.detailPanel.mobs, b)
            offset = offset + 38
        end
    end
    self.detailPanel:SetHeight(offset > 0 and offset or 1)
    self.detailScroll:UpdateScrollChildRect()
end

-- estado de expand por mob (persiste enquanto o menu está aberto)
local RTSW_LootExpanded = {}

function RareTrackerSW_Menu:RefreshLootDB()
    local content = self.lootContent
    if not content then return end
    if not content.rows then content.rows = {} end
    for _, r in ipairs(content.rows) do
        r:Hide()
        r:EnableMouse(false)
        r:SetScript("OnEnter", nil)
        r:SetScript("OnLeave", nil)
        r:SetScript("OnClick", nil)
    end

    local totalMobs, totalKills, totalItems = 0, 0, 0
    local sorted = {}
    if RareTrackerSW_LootDB then
        for n, d in pairs(RareTrackerSW_LootDB) do
            if d.kills and d.kills > 0 then
                table.insert(sorted, {n, d})
                totalMobs  = totalMobs  + 1
                totalKills = totalKills + (d.kills or 0)
                if d.items then totalItems = totalItems + table.getn(d.items) end
            end
        end
    end
    if self.lootStatsLabel then
        self.lootStatsLabel:SetText(
            "|cffaaaaaa" .. totalMobs .. " mobs  |cff00ff00" ..
            totalKills .. " kills  |cffffff00" .. totalItems .. " itens únicos|r")
    end

    local qualHex = {[0]="999999",[1]="ffffff",[2]="1eff00",[3]="0070dd",[4]="a335ee",[5]="ff8000"}
    table.sort(sorted, function(a, b) return (a[2].kills or 0) > (b[2].kills or 0) end)

    -- Monta linhas: cabeçalho do mob + itens só se expandido
    local lines = {}
    for _, entry in ipairs(sorted) do
        local n, d = entry[1], entry[2]
        local expanded = RTSW_LootExpanded[n]
        local arrow = expanded and "|cffaaaaaa▼|r " or "|cffaaaaaa▶|r "
        local itemCount = d.items and table.getn(d.items) or 0
        local countStr = itemCount > 0 and ("|cffaaaaaa (" .. itemCount .. " itens)|r") or ""
        table.insert(lines, {
            text    = arrow .. "|cffff8000" .. n .. "|r  |cff00ff00" .. (d.kills or 0) .. " kills|r" .. countStr,
            h       = 24,
            isMob   = true,
            mobName = n,
        })
        if expanded and d.items then
            for _, item in ipairs(d.items) do
                local hex = qualHex[item.quality or 1] or "ffffff"
                local pct = (d.kills and d.kills > 0) and math.floor((item.drops or 1) / d.kills * 100) or 0
                table.insert(lines, {
                    text     = "    |cff" .. hex .. (item.name or "?") .. "|r  |cffaaaaaa(" .. (item.drops or 1) .. "x · " .. pct .. "%)|r",
                    h        = 20,
                    itemId   = item.id,
                    itemName = item.name,
                })
            end
        end
    end

    if table.getn(lines) == 0 then
        local row = content.rows[1]
        if not row then
            row = CreateFrame("Button", nil, content)
            row:SetWidth(510) row:SetHeight(30)
            row.fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.fs:SetPoint("LEFT", row, "LEFT", 8, 0)
            content.rows[1] = row
        end
        row:ClearAllPoints() row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        row:SetHeight(30) row.fs:SetText("|cffaaaaaa(Nenhum dado registrado ainda)|r")
        row:Show()
        content:SetHeight(30)
        RTSW_LootScroll:UpdateScrollChildRect()
        return
    end

    local yOff = 0
    for i, line in ipairs(lines) do
        local row = content.rows[i]
        if not row then
            row = CreateFrame("Button", nil, content)
            row:SetWidth(510)
            row.fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.fs:SetPoint("LEFT", row, "LEFT", 8, 0)
            content.rows[i] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOff)
        row:SetHeight(line.h)
        row.fs:SetText(line.text)
        row:EnableMouse(true)

        if line.isMob then
            -- clique no mob: toggle expand/collapse
            local mobName = line.mobName
            row:SetScript("OnClick", function()
                RTSW_LootExpanded[mobName] = not RTSW_LootExpanded[mobName]
                RareTrackerSW_Menu:RefreshLootDB()
            end)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
        elseif line.itemId then
            -- clique no item: abre classicdb / tooltip
            local itemId   = line.itemId
            local itemName = line.itemName
            if itemId ~= "0" then
                row:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
                    GameTooltip:SetHyperlink("item:" .. itemId .. ":0:0:0")
                    GameTooltip:Show()
                end)
                row:SetScript("OnClick", function()
                    RareTrackerSW_Menu:ShowLink("https://classicdb.ch/?item=" .. itemId)
                end)
            else
                row:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
                    GameTooltip:SetText(itemName or "?")
                    GameTooltip:Show()
                end)
                row:SetScript("OnClick", nil)
            end
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        else
            row:EnableMouse(false)
        end

        row:Show()
        yOff = yOff + line.h
    end
    content:SetHeight(yOff > 0 and yOff or 1)
    RTSW_LootScroll:UpdateScrollChildRect()
end

function RareTrackerSW_Menu:CreateExportPopup()
    local f = CreateFrame("Frame", "RTSW_ExportPopup", UIParent)
    f:SetWidth(520) f:SetHeight(120)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
    f:SetFrameStrata("TOOLTIP")
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true, tileSize=32, edgeSize=32, insets={left=8,right=8,top=8,bottom=8}})
    f:SetBackdropColor(0.10, 0.06, 0.03, 1.0)
    f:EnableMouse(true) f:SetMovable(true) f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() this:StartMoving() end)
    f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetText("|cffffff00Exportar LootDB — cole no site|r")

    local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    cb:SetScript("OnClick", function() f:Hide() end)

    local eb = CreateFrame("EditBox", "RTSW_ExportEB", f)
    eb:SetWidth(470) eb:SetHeight(24)
    eb:SetPoint("CENTER", f, "CENTER", 0, -6)
    eb:SetFontObject("GameFontHighlight")
    eb:SetAutoFocus(false)
    eb:SetTextInsets(6, 6, 0, 0)
    eb:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=12, insets={left=3,right=3,top=3,bottom=3}})
    eb:SetBackdropColor(0.02, 0.02, 0.05, 1.0)
    eb:SetBackdropBorderColor(0.8, 0.7, 0.2, 1)
    eb:SetScript("OnEscapePressed", function() f:Hide() end)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
    hint:SetText("|cffaaaaaa Ctrl+A para selecionar · Ctrl+C para copiar|r")

    self.exportPopup = f
    self.exportEB = eb
    tinsert(UISpecialFrames, "RTSW_ExportPopup")
end

function RareTrackerSW_Menu:ShowExportPopup()
    if not self.exportPopup then self:CreateExportPopup() end
    local code = RTSW_GenerateExportCode()
    self.exportEB:SetText(code)
    self.exportEB:HighlightText()
    self.exportEB:SetFocus()
    self.exportPopup:Show()
end

function RareTrackerSW_Menu:CreateImportPopup()
    local f = CreateFrame("Frame", "RTSW_ImportPopup", UIParent)
    f:SetWidth(520) f:SetHeight(130)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
    f:SetFrameStrata("TOOLTIP")
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true, tileSize=32, edgeSize=32, insets={left=8,right=8,top=8,bottom=8}})
    f:SetBackdropColor(0.10, 0.06, 0.03, 1.0)
    f:EnableMouse(true) f:SetMovable(true) f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() this:StartMoving() end)
    f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetText("|cffffff00Importar do Site — cole o código abaixo|r")

    local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    cb:SetScript("OnClick", function() f:Hide() end)

    local eb = CreateFrame("EditBox", "RTSW_ImportEB", f)
    eb:SetWidth(470) eb:SetHeight(24)
    eb:SetPoint("CENTER", f, "CENTER", 0, -4)
    eb:SetFontObject("GameFontHighlight")
    eb:SetAutoFocus(false)
    eb:SetTextInsets(6, 6, 0, 0)
    eb:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=12, insets={left=3,right=3,top=3,bottom=3}})
    eb:SetBackdropColor(0.02, 0.02, 0.05, 1.0)
    eb:SetBackdropBorderColor(0.8, 0.7, 0.2, 1)
    eb:SetScript("OnEscapePressed", function() f:Hide() end)

    local doBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    doBtn:SetWidth(160) doBtn:SetHeight(22)
    doBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
    doBtn:SetText("Importar")
    doBtn:SetScript("OnClick", function()
        local code = RTSW_ImportEB:GetText()
        local count = RTSW_ImportCode(code)
        if RareTrackerSW_ChatEnabled ~= false then DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[RareTracker]|r Importado! |cffffff00" .. count .. "|r itens novos adicionados.") end
        f:Hide()
        if RareTrackerSW_Menu.activeTab == "loot" then
            RareTrackerSW_Menu:RefreshLootDB()
        end
    end)

    self.importPopup = f
    self.importEB = eb
    tinsert(UISpecialFrames, "RTSW_ImportPopup")
end

function RareTrackerSW_Menu:ShowImportPopup()
    if not self.importPopup then self:CreateImportPopup() end
    self.importEB:SetText("")
    self.importEB:SetFocus()
    self.importPopup:Show()
end

function RareTrackerSW_Menu:ToggleHelp()
    if not self.helpFrame then
        local f = CreateFrame("Frame", "RTSW_HelpFrame", UIParent)
        f:SetWidth(340) f:SetHeight(420)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:SetFrameStrata("TOOLTIP")
        f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile=true, tileSize=32, edgeSize=32, insets={left=8,right=8,top=8,bottom=8}})
        f:SetBackdropColor(0.10, 0.06, 0.03, 1.0)
        f:EnableMouse(true) f:SetMovable(true) f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function() this:StartMoving() end)
        f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        f:Hide()

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", f, "TOP", 0, -14)
        title:SetText("|cffffff00RareTracker-SW|r |cffaaaaaa- Ajuda|r")

        local cb = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
        cb:SetScript("OnClick", function() f:Hide() end)

        local div = f:CreateTexture(nil, "ARTWORK")
        div:SetTexture(0.8, 0.7, 0.2, 0.5)
        div:SetHeight(1) div:SetWidth(308)
        div:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -38)

        local scroll = CreateFrame("ScrollFrame", "RTSW_HelpScroll", f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -44)
        scroll:SetWidth(298) scroll:SetHeight(348)
        scroll:EnableMouseWheel(true)
        scroll:SetScript("OnMouseWheel", function()
            local v = this:GetVerticalScroll() - (arg1 * 25)
            if v < 0 then v = 0 end
            local mx = this:GetVerticalScrollRange()
            if v > mx then v = mx end
            this:SetVerticalScroll(v)
        end)

        local content = CreateFrame("Frame", nil, scroll)
        content:SetWidth(288)
        scroll:SetScrollChild(content)

        local lines = {
            "|cffffff00ABRIR / FECHAR|r",
            "  Botao no minimapa",
            "  Comando: |cffaaaaaa/rt|r  ou  |cffaaaaaa/rtsw|r",
            "  Keybind: ESC > Key Bindings > RareTracker",
            " ",
            "|cffffff00MAPA E MINIMAPA|r",
            "  Pins coloridos por tipo de mob",
            "  Mouse sobre o pin: info + loot",
            "  Shift+Clique no pin: marca MORTO",
            " ",
            "|cffffff00MENU DE RAROS ( /rt )|r",
            "  Clique na zona: lista os raros",
            "  |cff00ff00[S]|r Salvar posicao como spawn",
            "  |cffff0000[X]|r Ignorar raro da lista",
            "  |cffffff00[T]|r Targetar raro pelo nome",
            "  Shift+Clique no raro: marca MORTO",
            "  Busca: funciona com nome parcial",
            " ",
            "|cffffff00ALERTAS|r",
            "  Pop-up ao mouseover/target",
            "  Cooldown de 10 min por raro",
            " ",
            "|cffffff00SINCRONIZACAO|r",
            "  Mortes compartilhadas automaticamente",
            "  Aba Configuracoes > Sincronizar Agora",
            " ",
            "|cffffff00RARO CUSTOM|r",
            "  1. Chegue perto do raro",
            "  2. Passe o mouse ou target ele",
            "  3. No alerta: clique SALVAR NO MAPA",
            "  4. Ou no menu: clique [S]",
            " ",
            "|cffaaaaaa v" .. (RTSW_VERSION or "?") .. " - RareTracker-SW|r",
        }

        local yOff = 0
        for _, line in ipairs(lines) do
            local fs = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            fs:SetWidth(284)
            fs:SetJustifyH("LEFT")
            fs:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -yOff)
            fs:SetText(line)
            yOff = yOff + 18
        end
        content:SetHeight(yOff)
        scroll:UpdateScrollChildRect()

        self.helpFrame = f
        tinsert(UISpecialFrames, "RTSW_HelpFrame")
    end

    if self.helpFrame:IsShown() then self.helpFrame:Hide()
    else self.helpFrame:Show() end
end

function RareTrackerSW_Menu:CreateLinkPopup()
    local f = CreateFrame("Frame", "RTSW_LinkPopup", UIParent)
    f:SetWidth(400) f:SetHeight(80) f:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile=true, tileSize=32, edgeSize=32, insets={left=8,right=8,top=8,bottom=8}})
    f:SetBackdropColor(0.10, 0.06, 0.03, 1.0)
    f:SetFrameStrata("TOOLTIP") f:Hide()
    local eb = CreateFrame("EditBox", nil, f)
    eb:SetWidth(350) eb:SetHeight(20) eb:SetPoint("CENTER", 0, 0)
    eb:SetFontObject("GameFontHighlight")
    eb:SetScript("OnEscapePressed", function() f:Hide() end)
    RareTrackerSW_Menu.linkPopup = f
    RareTrackerSW_Menu.linkEB = eb
end

function RareTrackerSW_Menu:ShowLink(url)
    self.linkEB:SetText(url)
    self.linkEB:HighlightText()
    self.linkPopup:Show()
    self.linkEB:SetFocus()
end

-- RTSW_UpdateMinimapPos: compatibilidade com Core.lua — redireciona para o botão de Map.lua
-- (o botão único RTSW_MinimapBtn é criado em Map.lua com suporte a drag)
function RTSW_UpdateMinimapPos(angle)
    if RTSW_MinimapBtn then
        RTSW_MinimapBtn:ClearAllPoints()
        local x = math.floor(math.cos(angle) * 80)
        local y = math.floor(math.sin(angle) * 80)
        RTSW_MinimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
end

function RareTrackerSW_MenuHandler(msg)
    if RareTrackerSW_Menu:IsShown() then
        RareTrackerSW_Menu:Hide()
    else
        RareTrackerSW_Menu:Show()
        local z = RareTrackerSW.GetNormalizedZone and RareTrackerSW:GetNormalizedZone(GetRealZoneText()) or GetRealZoneText()
        RareTrackerSW_Menu:ShowZoneDetails(RareTrackerSW_Data[z] and z or "Tanaris")
        if RareTrackerSW_Menu.activeTab ~= "raros" then
            RareTrackerSW_Menu:ShowTab("raros")
        end
    end
end

SlashCmdList["RARETRACKER_SW"] = RareTrackerSW_MenuHandler
SLASH_RARETRACKER_SW1 = "/rt"
SLASH_RARETRACKER_SW2 = "/rtsw"
RareTrackerSW_Menu:Init()
tinsert(UISpecialFrames, "RareTrackerSW_Menu")
