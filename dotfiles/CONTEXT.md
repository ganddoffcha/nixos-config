# Zoo Code Context

> This file is read by Zoo after `read_graph` bootstrap. It provides active project context, system details, and critical rules. Not injected into system prompt — Zoo reads it via the `read_file` tool.

## Memory Instructions

1. **On task start:** Read the knowledge graph (`mcp--memory--read_graph`) to restore context from previous sessions.
2. **Record proactively and immediately:** Store facts, decisions, preferences, file changes, and context to the knowledge graph DURING conversations — not batched at session end.
3. **At session end:** Finalize the session entity with summary of accomplishments and open items.

## Active Projects

### PRIMARY: Quantum Spin Paper
- **Repo:** `~/Documents/quantum-spin-public/` — public: github.com/ganddoffcha/quantum-spin (CC BY 4.0)
- **Paper:** pdflatex, leopard.sty v3. §1-§7 done (32pp, 443KB). §8 quantum spin NOT YET WRITTEN (~17 items: Cartan-Weyl, irrep classification, spin operators, Pauli matrices).
- **Poster:** A1 beamer, lualatex + fontspec + din.otf. QR code to paper PDF.
- **Style:** `convention-math-style` (10 rules): \set{} for algebraic ops, \Br{}/\SqBr{} auto-scaling, \FUNC evaluation, \dd upright d, \eval{} bars, \df definitions, quantifier-first, explicit domain/codomain, operators wrap in \Br{}.
- **leopard.sty v3:** `~/Documents/texnow/leopard.sty` — 285 lines, beamer-compatible, \mathsf group symbols.

### SECONDARY: Topology Classical Chinese
- **Location:** `~/Documents/MH3600/topology-classical-chinese/`
- **State:** All 14 chapters drafted (3,102 lines). Ch1-2 full, Ch3-5 substantive, Ch6-14 framework. jlreq + LuaLaTeX + luatexja + Shanggu fonts.

### SYSTEM: NixOS + Home Manager (zephyrus laptop)
- **Repo:** github.com/ganddoffcha/nixos-config (MIT). Flake-based, catppuccin/nix Mocha+blue.
- **Boot:** ~34s (optimized from 58s). **CRITICAL:** NEVER edit /etc/nixos/ directly — edit ~/ then rebuild.
- **Config topology:** ~/ is source of truth. /etc/nixos/ is managed target. Use `~/scripts/rebuild -m 'msg'`.
- **VSCode settings:** settings.json and keybindings.json are real writable files, NOT home-manager managed.
- **Font chain:** JuliaMono→Google Sans Mono→JetBrains Mono→Noto Sans Math→Shanggu Mono.
- **ASUS ACPI errors are harmless firmware bugs — ignore them.**

### MEMORY: Knowledge Graph
- Entity count: ~60 (consolidated from 100+). Soft cap: 75 entities, 10 obs/entity.
- Bootstrap: `.clinerules` contains ONLY the gate. `CONTEXT.md` (this file) has everything else.
- Strategy doc: `/home/gc/memory-strategy.md`

### USER: Gordon Chan (gc)
- NTU math student, Singapore (UTC+8). Linux 6.18, zsh, VSCode+Zoo Code.
- Prefers: direct technical communication, bemenu-style follow-up questions, explicit sudo confirmation.
- Active repos: nixos-config (MIT), quantum-spin (CC BY 4.0), documents (CC BY 4.0).

## Session History

See `~/SESSION_LOG.md` for detailed session history. Latest:

- **2026-07-27 (session f):** Memory system maintenance — knowledge graph consolidation, bootstrap gate isolation (.clinerules → gate only, context → CONTEXT.md).
- **2026-07-27 (session e):** Bootstrap enforcement fix — dual-injection attempt. FAILED.
- **2026-07-27 (session d):** Bootstrap violation #5.
- **2026-07-27 (session c):** Bootstrap violation #4.
- **2026-07-27 (session b):** Fixed stale .clinerules (20 days behind).
- **2026-07-27 (session a):** Math style audit — applied 10 conventions to quantum-spin paper.

## CRITICAL RULES

1. **Bootstrap:** `read_graph` FIRST — enforced by `.clinerules` gate. Then read this file.
2. **Record proactively:** Update knowledge graph DURING sessions, not at end.
3. **Config topology:** ~/ is source of truth. /etc/nixos/ is managed target. NEVER edit /etc/nixos/ directly.
4. **Rebuild script:** `~/scripts/rebuild -m 'msg'` syncs ~/→/etc/nixos/ then nixos-rebuild --flake.
5. **VSCode settings:** settings.json and keybindings.json are real writable files, NOT home-manager managed.
6. **Math style:** Follow `convention-math-style` (10 rules) for all LaTeX in Gordon's documents.
7. **Ask before sudo:** Must explicitly ask user before any sudo command.
8. **bemenu-style questions:** Use ask_followup_question with 2-4 specific choices.
9. **Update files:** Update `.clinerules` (gate only, keep short), `CONTEXT.md` (full context), and `SESSION_LOG.md` at end of every session.
