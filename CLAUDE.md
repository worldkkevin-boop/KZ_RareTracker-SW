# SandWorlds WoW Server — Contexto para Desenvolvimento de Addons

## Identificação do Servidor

| Campo | Valor |
|---|---|
| Servidor | SandWorlds |
| Realmlist | `world.sandworlds.com` |
| Nome do realm | `Sandworlds (1,17,2)` |
| Versão do cliente | **1.12.1 (build 5875)** — Vanilla/Classic |
| Número de interface | **11200** |
| Copyright do exe | Blizzard Entertainment, 2004 |
| Mod instalado | **SuperWoW** (`SuperWoWhook.dll` presente) |

O servidor roda o executável original do WoW 1.12.1 com o mod **SuperWoW** injetado, que expande significativamente a API Lua disponível para addons.

---

## Estrutura de Diretórios

```
WoW-SandWorlds/
├── Interface/
│   └── AddOns/           ← todos os addons aqui
├── WTF/
│   └── Account/
│       └── KEVINZINHO/
│           └── Sandworlds (1,17,2)/
│               └── <Personagem>/   ← SavedVariables por personagem
├── WoW.exe               ← cliente 1.12.1.5875
├── SuperWoWhook.dll      ← SuperWoW instalado
├── nampower.dll          ← nampower (spellqueue)
└── realmlist.wtf         ← aponta para world.sandworlds.com
```

---

## Como Criar um Addon

### Estrutura mínima

```
Interface/AddOns/MeuAddon/
├── MeuAddon.toc
├── MeuAddon.lua
└── MeuAddon.xml        (opcional)
```

### Arquivo .toc

```
## Interface: 11200
## Title: Nome do Addon
## Notes: Descrição curta
## Author: Kevin
## Version: 1.0
## SavedVariables: MeuAddonDB

MeuAddon.lua
```

### Detectar se SuperWoW está ativo

```lua
if SUPERWOW_VERSION then
    -- SuperWoW disponível, pode usar API extendida
else
    -- Fallback para vanilla puro
end
```

---

## API Vanilla 1.12.1 (base)

### Funções sempre disponíveis

```lua
CreateFrame("Frame", "MeuFrame", UIParent)
frame:SetScript("OnEvent", function() end)
frame:RegisterEvent("PLAYER_LOGIN")

DEFAULT_CHAT_FRAME:AddMessage("texto")
SendChatMessage("texto", "SAY")

UnitName("player"), UnitClass("player"), UnitLevel("player")
UnitHealth("player"), UnitHealthMax("player")
UnitMana("player"), UnitManaMax("player")
GetPlayerFacing(), GetZoneText(), GetSubZoneText()

GetContainerNumSlots(bag), GetContainerItemInfo(bag, slot)
GetItemInfo(itemLink), GetTime(), date("formato")

SLASH_MEUADDON1 = "/meuaddon"
SlashCmdList["MEUADDON"] = function(msg) end
```

### Eventos vanilla úteis

```lua
"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD"
"CHAT_MSG_SAY", "CHAT_MSG_PARTY", "CHAT_MSG_RAID", "CHAT_MSG_YELL"
"UNIT_HEALTH", "UNIT_MANA", "PLAYER_TARGET_CHANGED"
"BAG_UPDATE", "COMBAT_LOG_EVENT"
```

---

## API SuperWoW — Extensões Disponíveis no SandWorlds

### Novos Eventos

```lua
-- UNIT_CASTEVENT: rastreia casting de qualquer unidade
-- arg1 = GUID do caster, arg2 = GUID do alvo
-- arg3 = tipo: "START", "CAST", "FAIL", "CHANNEL", "MAINHAND", "OFFHAND"
-- arg4 = spell id, arg5 = duração do cast (ms)
frame:RegisterEvent("UNIT_CASTEVENT")
frame:SetScript("OnEvent", function()
    if event == "UNIT_CASTEVENT" then
        local casterGUID, targetGUID, tipo, spellID, duracao = arg1, arg2, arg3, arg4, arg5
    end
end)

-- RAW_COMBATLOG: versão raw de todos os eventos de combate com GUIDs
-- arg1 = nome do evento original, arg2 = texto com GUIDs
frame:RegisterEvent("RAW_COMBATLOG")
```

### Novas Funções

```lua
-- Info de spell pelo ID (sem precisar de itemlink)
local nome, rank, texture, minrange, maxrange = SpellInfo(spellID)

-- Posição de unidade amiga no mapa
local x, y = UnitPosition("target")  -- só funciona para aliados

-- Adiciona unidade ao minimapa
TrackUnit("target")

-- Mouseover casting
SetMouseoverUnit("target")   -- define o mouseover
SetMouseoverUnit(nil)        -- limpa o mouseover

-- Coordenadas do cursor no mundo (XYZ)
local x, y, z = CursorPosition()

-- Converter coords mundo → mapa
local mapX, mapY = GetWorldLocMapPosition(continente, x, y)

-- Nameplate de uma unidade
local frame = UnitNameplate("target")

-- Verificar se unidade tem loot
local temLoot = CanLootUnit("target")

-- Buff do player por índice (retorna o ID)
local buffID = GetPlayerBuffID(index)

-- Escrever no log de combate
CombatLogAdd("minha mensagem")
CombatLogAdd("minha mensagem", true)  -- também no raw log

-- Autoloot via Lua
SetAutoloot(1)   -- ativa
SetAutoloot(0)   -- desativa
local estado = SetAutoloot()  -- lê estado atual

-- Clickthrough em cadáveres
Clickthrough(1)
local estado = Clickthrough()

-- Ler/escrever arquivos (pasta game\imports\)
local texto = ImportFile("meuarquivo.txt")
ExportFile("saida.txt", "conteúdo aqui")
```

### Funções Modificadas/Extendidas

```lua
-- CastSpellByName agora aceita unidade como 2° argumento
CastSpellByName("Fireball", "target")
CastSpellByName("Heal", "mouseover")
CastSpellByName("Flare", "CLICK")  -- cast reticle no cursor

-- UnitExists agora também retorna o GUID
local existe, guid = UnitExists("target")

-- UnitBuff/UnitDebuff retornam o ID do aura como extra
local nome, rank, texture, count, debuffType, duration, expiration, caster, auraID = UnitBuff("target", index)

-- GetContainerItemInfo: charges negativas = não-stackável com cargas
local texture, count, locked, quality, readable = GetContainerItemInfo(bag, slot)
-- count negativo = item tem cargas (ex: -3 = 3 cargas restantes)

-- SetRaidTarget: 3° argumento = marcar só localmente (sem enviar ao grupo)
SetRaidTarget("target", 1, true)  -- marca local only

-- GetActionText retorna tipo e ID da ação
local texto, tipo, id = GetActionText(slot)
-- tipo = "MACRO", "ITEM" ou "SPELL"
```

### Argumentos de Unidade Extendidos

```lua
-- Sufixo "owner" — dono do pet/minion
UnitName("targetowner")   -- dono do alvo
UnitHealth("focusowner")

-- Por marca de raid (mark1 a mark8)
UnitName("mark1")         -- unidade com a marca 1 (caveira, etc)
UnitHealth("mark5")

-- Por GUID direto
UnitName("0x000000000012AB34")
```

### CVars Novos

```lua
-- Campo de visão da câmera (0.1 a 3.14, padrão 1.57)
SetCVar("FoV", "1.8")

-- Som em segundo plano (alt+tab)
SetCVar("BackgroundSound", "1")

-- Remove limite de canais de som
SetCVar("UncapSounds", "1")

-- Estilo do círculo de seleção
SetCVar("SelectionCircleStyle", "1")

-- Toggle do sparkle em baús/loot
SetCVar("LootSparkle", "0")
```

---

## O que NÃO existe (nem com SuperWoW)

- `SecureActionButtonTemplate` — TBC+
- `C_Timer.After()` — Cataclysm+
- `C_Item`, `C_Unit`, `C_Map` — namespaces modernos
- `hooksecurefunc()` — TBC+
- Frames protegidos de combate — não existem no vanilla

---

## Contas e Personagens

| Conta | Personagens |
|---|---|
| KEVINZINHO | Pactonopix, Larapio, Naoeokevinzi, Kevinzinho, Lore, Lothardado |
| KEVINZINHO2 | Kaelthor, Sylvaris |

---

## Addons Já Instalados

- **Titan Panel** — barra superior/inferior de info
- **TitanStanceSets** — troca armas por stance
- **WeaponQuickSwap** — troca rápida de armas

---

## Dicas Rápidas

1. `/reload` — recarrega addons sem sair do jogo
2. `/console scriptErrors 1` — ativa erros Lua visíveis
3. Lua 5.0: use `unpack()` (não `table.unpack`), não tem `string.split`
4. Sem `print()` — use `DEFAULT_CHAT_FRAME:AddMessage()`
5. SavedVariables globais: `WTF/Account/<CONTA>/SavedVariables/`
6. SavedVariables por personagem: `WTF/Account/<CONTA>/<REALM>/<CHAR>/SavedVariables/`
