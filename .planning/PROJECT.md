# KZ Addons Suite — SandWorlds

## What This Is

Suite de addons para o servidor WoW 1.12.1 **SandWorlds** (`world.sandworlds.com`), desenvolvida por Kevinzinho. O projeto centraliza o desenvolvimento, melhorias e manutenção de todos os addons KZ — hoje 4 addons, com abertura para novos conforme necessidade.

O objetivo é disponibilizar os addons para todos os jogadores do SandWorlds.

## Core Value

**Melhorar a experiência dos jogadores do SandWorlds com addons PT-BR funcionais, polidos e confiáveis** — leveling, raros, tradução e otimização de itens.

## Context

- **Servidor:** SandWorlds, WoW 1.12.1 (build 5875, interface 11200)
- **Mod especial:** SuperWoW (`SuperWoWhook.dll`) — expande a API Lua com eventos como `UNIT_CASTEVENT`, funções como `SpellInfo()`, `UnitPosition()`, etc.
- **Stack:** Lua 5.0, API vanilla 1.12.1 + SuperWoW, Ace2 (no KZ Guide), LibStub
- **Destino:** Compartilhamento com toda a comunidade SandWorlds

## Addons Existentes

| Addon | Versão | Status | Problemas Conhecidos |
|-------|--------|--------|----------------------|
| **KZ Guide** | 1.1.0 | Ativo | Navegação bugada, conteúdo incompleto, PartySync falha, UI lenta |
| **KZ RareTracker-SW** | 1.2.0 | Ativo | DB de raros incompleto, alertas/sons com problema, minimapa bugado |
| **KZ Translator** | 0.1.0-Beta | Beta | Bugs de UI, dicionário incompleto |
| **KZ ItemEP** | 1.2.0 | Ativo | Bugs de UI no menu |

## Requirements

### Validated

- ✓ KZ Guide funciona com guias de leveling Alliance/Horde, dungeons, profissões — existing
- ✓ KZ RareTracker rastreia raros com minimapa, sync e alertas — existing
- ✓ KZ Translator traduz termos EN→PT-BR no chat — existing
- ✓ KZ ItemEP mostra valor EP nos tooltips com pesos customizados — existing

### Active

- [ ] KZ Guide: corrigir bugs de navegação (waypoints, seta, minimapa path)
- [ ] KZ Guide: completar conteúdo faltante nos guias de leveling/profissões
- [ ] KZ Guide: corrigir PartySync entre membros do grupo
- [ ] KZ Guide: melhorar performance e corrigir bugs de UI
- [ ] KZ RareTracker: completar database de raros do SandWorlds
- [ ] KZ RareTracker: corrigir sistema de alertas/sons
- [ ] KZ RareTracker: corrigir ícone no minimapa
- [ ] KZ Translator: corrigir bugs de UI
- [ ] KZ ItemEP: corrigir bugs de UI no menu

### Out of Scope

- Novos addons do zero (nesta fase) — foco nas melhorias primeiro
- Suporte a outros servidores (SandWorlds-specific)
- Port para versões mais recentes do WoW

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Focar em melhorias antes de novos addons | 4 addons existentes têm bugs críticos | — Pending |
| Compartilhar com servidor, não open-source | Público-alvo é a comunidade SandWorlds | — Pending |
| Cada addon é um sub-projeto independente | Codebase separada, deploy independente | — Validated |

## Evolution

Este documento evolui a cada transição de fase e milestone.

**Após cada transição de fase** (via `/gsd-transition`):
1. Requirements invalidados? → Mover para Out of Scope com motivo
2. Requirements validados? → Mover para Validated com referência da fase
3. Novos requirements? → Adicionar em Active
4. Decisões a registrar? → Adicionar em Key Decisions

**Após cada milestone** (via `/gsd-complete-milestone`):
1. Revisão completa de todas as seções
2. Core Value ainda correto?
3. Auditar Out of Scope
4. Atualizar Context com estado atual

---
*Last updated: 2026-05-23 after initialization*
