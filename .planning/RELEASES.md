# Releases — KZ Addons Suite

## Repositórios GitHub

| Addon | Repo | Versão Atual |
|-------|------|--------------|
| KZ Guide MEGA PT-BR | https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR | 1.1.0 |
| KZ ItemEP | https://github.com/worldkkevin-boop/KZ_ItemEP | 1.2.0 |
| KZ RareTracker-SW | https://github.com/worldkkevin-boop/KZ_RareTracker-SW | 1.3.0 |
| KZ Translator | — (ainda não publicado) | 0.1.0-Beta |

**GitAddonsManager URL (KZ Guide):**
```
https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR.git
```

---

## Padrão de Versionamento (SemVer)

```
MAJOR.MINOR.PATCH
```

| Parte | Quando aumentar | Exemplo |
|-------|-----------------|---------|
| **MAJOR** | Quebra compatibilidade com versões anteriores (mudança estrutural grande) | 2.0.0 |
| **MINOR** | Nova funcionalidade sem quebrar nada existente | 1.10.0 |
| **PATCH** | Correção de bug ou melhoria pequena | 1.9.1 |

**Sufixos especiais:**
- `-Beta` — funcional mas em teste, pode ter bugs
- `-ptBR-112d` — indica localização PT-BR para WoW 1.12 (vanilla)

---

## Checklist de Release

Antes de fazer push para o GitHub:

- [ ] Versão atualizada no `.toc` (campo `## Version:`)
- [ ] Versão atualizada no `Core.lua` ou arquivo principal (se houver constante de versão)
- [ ] Testado in-game com `/reload` sem erros Lua
- [ ] Testado do zero (personagem sem SavedVariables) — simular primeiro uso
- [ ] Commit com mensagem descritiva (ex: `fix: corrigir posicionamento do ícone no minimapa`)
- [ ] Tag git criada no formato `vMAJOR.MINOR.PATCH` (ex: `v1.2.1`)
- [ ] Release criada no GitHub com changelog

---

## Histórico de Releases

### KZ Guide MEGA PT-BR

| Versão | Data | Tipo | O que mudou |
|--------|------|------|-------------|
| 1.1.0 | — | MINOR | Aba Profissões, KZPartySync, GuideWriter, ProfessionBrowser |
| 1.0.4 | — | PATCH | Correções de UI, browser de dungeons |

### KZ ItemEP

| Versão | Data | Tipo | O que mudou |
|--------|------|------|-------------|
| 1.2.0 | — | MINOR | Versão atual |

### KZ RareTracker-SW

| Versão | Data | Tipo | O que mudou |
|--------|------|------|-------------|
| 1.3.0 | 2026-05-24 | MINOR | Multi-spawn points via pfQuest DB + hover highlight nos pins do mapa |
| 1.2.1 | — | PATCH | SuperWoW enhancements |
| 1.2.0 | — | MINOR | Versão anterior |

### KZ Translator

| Versão | Data | Tipo | O que mudou |
|--------|------|------|-------------|
| 0.1.0-Beta | — | — | Versão inicial beta |

---

## Post de Divulgação (Discord/Fórum)

```
🍺 KZ Addons — PT-BR para SandWorlds
Olá aventureiros! Desenvolvemos uma coleção de addons gratuitos e em português para o servidor SandWorlds.

🛠️ Como instalar
1. Baixe o GitAddonsManager: https://woblight.gitlab.io/overview/gitaddonsmanager/
2. Cole o link abaixo — ele instala tudo automaticamente:
https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR.git

---

📖 KZ Guide MEGA PT-BR
Guias completos de leveling, profissões, masmorras e endgame — tudo em português!
🔗 https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR

⚔️ KZ ItemEP
Calculadora de EP (Equipment Points) no tooltip dos itens. Veja a nota do item (SS/S/A/B/C...) e compare com o que você está usando!
🔗 https://github.com/worldkkevin-boop/KZ_ItemEP

🗺️ KZ RareTracker-SW
Tracker de mobs raros no minimapa com alertas e sincronização entre jogadores!
🔗 https://github.com/worldkkevin-boop/KZ_RareTracker-SW

☕ Gostou? Me paga um café!
👉 https://ko-fi.com/worldkkevingmailcom

---

🇺🇸 English
🍺 KZ Addons — PT-BR for SandWorlds
Hey adventurers! We've developed a collection of free addons in Brazilian Portuguese for the SandWorlds server.

🛠️ How to install
1. Download GitAddonsManager: https://woblight.gitlab.io/overview/gitaddonsmanager/
2. Paste the link below — it installs everything automatically:
https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR.git

---

📖 KZ Guide MEGA PT-BR
Complete leveling, professions, dungeons and endgame guides — all in Portuguese!
🔗 https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR

⚔️ KZ ItemEP
Item EP (Equipment Points) calculator in the item tooltip. See the item grade (SS/S/A/B/C...) and compare with your equipped gear!
🔗 https://github.com/worldkkevin-boop/KZ_ItemEP

🗺️ KZ RareTracker-SW
Rare mob tracker on the minimap with kill alerts and player synchronization!
🔗 https://github.com/worldkkevin-boop/KZ_RareTracker-SW

☕ Enjoy the addons? Buy me a coffee!
👉 https://ko-fi.com/worldkkevingmailcom
```
