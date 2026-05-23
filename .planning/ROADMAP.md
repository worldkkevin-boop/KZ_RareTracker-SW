# Roadmap — KZ Addons Suite

**10 fases** | **10 requirements** | Granularidade: fina

---

### Phase 1: KZ Translator — Corrigir UI
**Goal:** Corrigir frames fora de posição no menu do KZ Translator
**Success Criteria:**
1. Menu do KZ Translator abre na posição correta sem sobreposição
2. Sem erros Lua ao abrir/fechar o menu
3. Layout mantém posição após `/reload`

**Requirements:** TRAN-01

---

### Phase 2: KZ ItemEP — Corrigir UI
**Goal:** Corrigir frames fora de posição no menu de configurações do KZ ItemEP
**Success Criteria:**
1. Menu de pesos EP abre corretamente sem sobreposição
2. Sem erros Lua ao abrir/fechar o menu
3. Configurações salvas persistem corretamente

**Requirements:** EP-01

---

### Phase 3: KZ RareTracker — Corrigir Minimapa
**Goal:** Corrigir posicionamento e visual do ícone do RareTracker no minimapa
**Success Criteria:**
1. Ícone aparece corretamente posicionado no minimapa
2. Ícone é visualmente correto (sem distorção)
3. Clique no ícone abre o addon normalmente

**Requirements:** RARE-02

---

### Phase 4: KZ RareTracker — Corrigir Alertas
**Goal:** Corrigir sistema de alertas/sons para spawn de raros
**Success Criteria:**
1. Alerta visual aparece quando raro spawna
2. Som toca corretamente quando raro spawna (se habilitado)
3. Toggle de alertas liga/desliga corretamente

**Requirements:** RARE-03

---

### Phase 5: KZ RareTracker — Completar Database
**Goal:** Cadastrar todos os monstros raros do SandWorlds que estão faltando no DB
**Success Criteria:**
1. Todos os raros conhecidos do SandWorlds estão no database
2. Loot de cada raro está listado corretamente
3. Coordenadas de spawn estão corretas no mapa

**Requirements:** RARE-01

---

### Phase 6: KZ Guide — Corrigir UI e Performance
**Goal:** Corrigir bugs de interface e melhorar performance do KZ Guide
**Success Criteria:**
1. Interface carrega sem erros Lua no login
2. Frames não travam durante navegação nos guias
3. Scroll e botões respondem sem lag

**Requirements:** GUIDE-04

---

### Phase 7: KZ Guide — Organizar Guias de Leveling
**Goal:** Organizar e completar steps faltantes nos guias Alliance e Horde
**Success Criteria:**
1. Guias Alliance e Horde cobrem 1-60 sem gaps de steps
2. Ordem dos steps está lógica e testada
3. Quests com IDs corretos e NPCs localizados

**Requirements:** GUIDE-01

---

### Phase 8: KZ Guide — Organizar Guias de Profissões
**Goal:** Organizar e completar steps faltantes nos guias de profissões
**Success Criteria:**
1. Guias de profissões cobrem 1-300 sem gaps
2. Materiais e NPCs corretos em cada step
3. Steps validados para o SandWorlds (disponibilidade de receitas)

**Requirements:** GUIDE-02

---

### Phase 9: KZ Guide — Corrigir PartySync
**Goal:** Corrigir sincronização de dados entre membros do grupo no PartySync
**Success Criteria:**
1. Líder sincroniza posição no guia para o grupo via addon channel
2. Membros recebem a sincronização e avançam para o step correto
3. Funciona com 2 a 5 membros no grupo

**Requirements:** GUIDE-03

---

### Phase 10: KZ Guide — Corrigir Navegação
**Goal:** Corrigir bugs de navegação (seta de direção, waypoints, caminho no minimapa)
**Success Criteria:**
1. Seta de navegação aponta na direção correta do waypoint
2. Waypoints resolvem para as coordenadas corretas dos steps
3. Caminho pontilhado no minimapa aparece e acompanha o personagem

**Requirements:** GUIDE-05

---

## Phase Summary

| # | Phase | Addon | Requirements |
|---|-------|-------|-------------|
| 1 | KZ Translator — Corrigir UI | KZ Translator | TRAN-01 |
| 2 | KZ ItemEP — Corrigir UI | KZ ItemEP | EP-01 |
| 3 | KZ RareTracker — Corrigir Minimapa | KZ RareTracker | RARE-02 |
| 4 | KZ RareTracker — Corrigir Alertas | KZ RareTracker | RARE-03 |
| 5 | KZ RareTracker — Completar Database | KZ RareTracker | RARE-01 |
| 6 | KZ Guide — Corrigir UI e Performance | KZ Guide | GUIDE-04 |
| 7 | KZ Guide — Organizar Guias de Leveling | KZ Guide | GUIDE-01 |
| 8 | KZ Guide — Organizar Guias de Profissões | KZ Guide | GUIDE-02 |
| 9 | KZ Guide — Corrigir PartySync | KZ Guide | GUIDE-03 |
| 10 | KZ Guide — Corrigir Navegação | KZ Guide | GUIDE-05 |
