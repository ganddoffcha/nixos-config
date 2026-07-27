# Memory Persistence Strategy

> Defines what Zoo automatically stores in the MCP knowledge graph to maintain context across sessions.
>
> **Bootstrap enforcement:** [`.clinerules`](.clinerules) contains ONLY the bootstrap gate (5 lines: "STOP. Call read_graph first."). All context (active projects, rules, session history) lives in [`CONTEXT.md`](CONTEXT.md) which Zoo reads AFTER `read_graph`. This isolation prevents the gate instruction from being diluted by other content. See Appendix A for full history.

## 1. Entity Types & Their Purpose

| Entity Type | Purpose | Examples |
|---|---|---|
| `project` | Tracks a project — its goal, status, key decisions | `memory-project` |
| `user` | Stores user preferences, location, habits | `user-gc` |
| `assistant` | Zoo's own capabilities and learned behaviors | `zoo-assistant` |
| `session` | A discrete conversation session with summary | `session-2026-07-27-f` |
| `file` | Important files created or modified with metadata | `file-keybindings.json` |
| `decision` | Architectural or design decisions made | `decision-bootstrap-protocol` |
| `convention` | Agreed-upon coding or workflow conventions | `convention-memory-storage` |
| `bug` | Known bugs with diagnosis and workarounds | `bug-fbdev-drm-conflict` |

## 2. Auto-Storage Triggers

Zoo automatically persists to the knowledge graph **immediately** (not batched at session end) when:

- **Session start** → Create a `session-YYYY-MM-DD` entity with summary of what's being worked on
- **File creation/modification** → Store file path, purpose, and key contents summary as a `file` entity
- **Decision made** → Record architectural/design choices as `decision` entities linked to the relevant project
- **User preference expressed** → Update the `user` entity with new observations
- **Project status change** → Update the `project` entity's observations
- **Session end** → Finalize session entity with summary of accomplishments and open items

**Proactive recording rule:** Memory recording must be PROACTIVE and IMMEDIATE — not batched at session end. After every meaningful exchange (new fact, decision, preference, file change, automation detail), create/update entities right away. If the user has to ask "you remember X right?" — that is a failure of the memory system. The knowledge graph is a live brain, not a session log.

## 3. Relation Conventions

| Relation | From → To | Meaning |
|---|---|---|
| `working_on` | `assistant` → `project` / `session` | Zoo is actively working on this |
| `assists` | `assistant` → `user` | Zoo assists this user |
| `owns` | `user` → `project` | User owns this project |
| `created_in` | `file` / `decision` → `session` | Entity was created during this session |
| `part_of` | `decision` / `session` / `convention` → `project` | Entity belongs to this project |
| `follows` | `session-N` → `session-N-1` | Session chronology |
| `validates` | `decision` → `decision` | One decision confirms/corroborates another |
| `extends` | `decision` → `decision` | One decision builds upon another |
| `supersedes` | `decision` → `decision` | One decision replaces another |

## 4. Observation Formatting

- **Decisions**: `"[DATE] Decision: <what was decided> | Rationale: <why> | Alternatives considered: <list>"`
- **Files**: `"[DATE] <type: created/modified> | Path: <path> | Purpose: <description>"`
- **Session summaries**: `"Date: <date> | Summary: <one-liner> | Key accomplishments: <list> | Open items: <list>"`
- **User preferences**: `"Prefers: <preference>"` or `"Uses: <tool/workflow>"`

## 5. Session Bootstrap Protocol

> **Gate-only `.clinerules` (2026-07-27 session f):** [`.clinerules`](.clinerules) contains ONLY the bootstrap gate — 5 lines with zero competing content. All context (active projects, rules, history) is in [`CONTEXT.md`](CONTEXT.md). The theory: isolation prevents gate instruction dilution.

### Bootstrap Sequence
1. **`.clinerules` injected into system prompt** → Zoo sees "STOP. Call read_graph first." with no other content
2. **Zoo calls `mcp--memory--read_graph`** → restores knowledge graph context
3. **Zoo reads [`CONTEXT.md`](CONTEXT.md)** → gets active projects, critical rules, session history
4. **Zoo responds** → with full awareness of all context

### File Architecture
| File | Purpose | Injected? |
|---|---|---|
| [`.clinerules`](.clinerules) | Bootstrap gate ONLY (5 lines) | Yes — auto-injected by Zoo Code |
| [`CONTEXT.md`](CONTEXT.md) | Active projects, rules, history | No — read by Zoo via tool after bootstrap |
| [`memory-strategy.md`](memory-strategy.md) | Memory strategy documentation | No — reference only |
| [`SESSION_LOG.md`](SESSION_LOG.md) | Human-readable session history | No — reference only |

## 6. Maintenance

### Periodic Cleanup (every ~5 sessions or when clutter is noticed)
- **Sessions:** Consolidate multiple same-day sessions into a single session entity (e.g., `session-2026-07-06-consolidated`)
- **Decisions:** Merge redundant decisions documenting the same conclusion into consolidated entities
- **Files:** Remove `file` entities for files that no longer exist in the workspace
- **Observations:** Remove outdated or superseded observations from entities

### Knowledge Graph Hygiene
- The convention entity `convention-memory-storage` always points to this document as its canonical source
- After any cleanup, verify that relations remain consistent (no dangling references to deleted entities)
- The bootstrap protocol (Section 5) reflects the pragmatic two-message reality — do not attempt further first-message enforcement

### File Hygiene
- This document (`memory-strategy.md`) is the single canonical strategy reference
- [`.clinerules`](.clinerules) provides inline context for Zoo sessions

## 7. Scalability

### Soft Guidelines (not hard caps)
- **~10 observations per entity max** — consolidate when exceeding this
- **~75 total entities** — run cleanup (Section 6) when approaching this
- **Relations are optional** — prioritize meaningful links over exhaustive linking

### Consolidation Triggers
- **Sessions older than 14 days** → merge into consolidated session entities (e.g., per-day or per-week)
- **Redundant decisions** → merge into topic-based consolidated decision entities
- **Stale file entities** → delete if the file no longer exists in the workspace
- **Superseded observations** → remove or replace when newer information contradicts them

### Smart Retrieval
- **Bootstrap (session start):** Use `read_graph` to restore full context on message 2
- **Mid-session lookups:** Use `search_nodes` for targeted queries (e.g., "what was that decision about X?")
- **Specific entity inspection:** Use `open_nodes` to retrieve detailed observations for known entity names

---

## Appendix A: Bootstrap Enforcement History

7 iterations. Current approach (v7): gate-only `.clinerules` — zero competing content.

| Iteration | Date | Approach | Result |
|---|---|---|---|
| 1 | 2026-07-06 (session a) | Section 5 added to this document | **Failed** — passive doc |
| 2 | 2026-07-06 (session b) | `BOOTSTRAP.md` workspace file | **Failed** — passive doc |
| 3 | 2026-07-06 (session c) | Diagnosed root cause: need technical enforcement | **Diagnosis** |
| 4 | 2026-07-06 (session d) | `.clinerules` injection (67 lines) | **Success** ✅ — 46 sessions |
| 5 | 2026-07-27 (session e) | Dual-injection: `.clinerules-{mode}` files | **Failed** — violated next session |
| 6 | 2026-07-27 (session f) | Two-message bootstrap (pragmatic) | **Rejected** — user wants immediate |
| 7 | 2026-07-27 (session f v2) | **Gate-only `.clinerules`** — 5 lines, zero context dilution. Context → `CONTEXT.md` | **Pending test** |

**Current theory:** Previous failures occurred because the bootstrap gate instruction was diluted by 70+ lines of context in the same injected file. By isolating the gate to its own file with zero competing content, the instruction should be impossible to miss. Testing requires VSCode restart.
