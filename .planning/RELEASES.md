# Releases — KZ Addons Suite

## Repositórios GitHub

| Addon | Repo | Versão Atual |
|-------|------|--------------|
| KZ Guide MEGA PT-BR | https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR | 1.1.0 |
| KZ ItemEP | https://github.com/worldkkevin-boop/KZ_ItemEP | 1.2.0 |
| KZ RareTracker-SW | https://github.com/worldkkevin-boop/RareTracker-SW | 1.2.0 |
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
| 1.2.0 | — | MINOR | Versão atual |

### KZ Translator

| Versão | Data | Tipo | O que mudou |
|--------|------|------|-------------|
| 0.1.0-Beta | — | — | Versão inicial beta |

---

## Post de Divulgação (Discord/Fórum)

```
🍺 KZ Addons — PT-BR para SandWorlds

Olá aventureiros! Desenvolvemos uma coleção de addons gratuitos e em português
para o servidor SandWorlds. Confira abaixo:

📖 KZ Guide MEGA PT-BR
Guias completos de leveling, profissões, masmorras e endgame — tudo em português!
🔗 https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR

⚔️ KZ ItemEP
Calculadora de EP (Equipment Points) no tooltip dos itens.
Veja a nota do item (SS/S/A/B/C...) e compare com o que você está usando!
🔗 https://github.com/worldkkevin-boop/KZ_ItemEP

🗺️ RareTracker-SW
Tracker de mobs raros no minimapa com alertas e sincronização entre jogadores!
🔗 https://github.com/worldkkevin-boop/RareTracker-SW

🛠️ Como instalar
Use o GitAddonsManager e cole o link abaixo — ele instala tudo automaticamente:
https://github.com/worldkkevin-boop/KZ_Guide_MEGA_PTBR.git

☕ Gostou? Me paga um café!
👉 https://ko-fi.com/worldkkevingmailcom
```
