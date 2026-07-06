# Memory Persistence Strategy

> Defines what Zoo automatically stores in the MCP knowledge graph to maintain context across sessions.
>
> **Bootstrap enforcement:** The [`.clinerules`](.clinerules) file in the workspace root auto-injects the bootstrap protocol into Zoo's system prompt, making `read_graph` a mandatory pre-response gate. This is validated and working as of session `d` (2026-07-06).

## 1. Entity Types & Their Purpose

| Entity Type | Purpose | Examples |
|---|---|---|
| `project` | Tracks a project — its goal, status, key decisions | `memory-project` |
| `user` | Stores user preferences, location, habits | `user-gc` |
| `assistant` | Zoo's own capabilities and learned behaviors | `zoo-assistant` |
| `session` | A discrete conversation session with summary | `session-2026-07-06` |
| `file` | Important files created or modified with metadata | `file-keybindings.json` |
| `decision` | Architectural or design decisions made | `decision-zen-mode-shortcut` |
| `convention` | Agreed-upon coding or workflow conventions | `convention-memory-storage` |

## 2. Auto-Storage Triggers

Zoo automatically persists to the knowledge graph when:

- **Session start** → Create a `session-YYYY-MM-DD` entity with summary of what's being worked on
- **File creation/modification** → Store file path, purpose, and key contents summary as a `file` entity
- **Decision made** → Record architectural/design choices as `decision` entities linked to the relevant project
- **User preference expressed** → Update the `user` entity with new observations
- **Project status change** → Update the `project` entity's observations
- **Session end** → Finalize session entity with summary of accomplishments and open items

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
| `addresses` | `decision` → `decision` | One decision resolves a problem described by another |

## 4. Observation Formatting

- **Decisions**: `"[DATE] Decision: <what was decided> | Rationale: <why> | Alternatives considered: <list>"`
- **Files**: `"[DATE] <type: created/modified> | Path: <path> | Purpose: <description>"`
- **Session summaries**: `"Date: <date> | Summary: <one-liner> | Key accomplishments: <list> | Open items: <list>"`
- **User preferences**: `"Prefers: <preference>"` or `"Uses: <tool/workflow>"`

## 5. Session Bootstrap Protocol

> **Enforced by [`.clinerules`](.clinerules).** The workspace-root `.clinerules` file injects this protocol into Zoo's system prompt. Zoo cannot skip it.

### Step 0: Read Knowledge Graph (ALWAYS FIRST)
- Call `read_graph` before any other action — including greeting the user, answering a question, or running any tool.
- This is a hard gate: no response may be formulated until the graph has been read.

### Step 1: Process One-Shot Observations
- Scan all observations for `ONE-SHOT` markers. Execute them immediately if their conditions are met, then delete them.
- One-shot format: `"ONE-SHOT: On <trigger>, <action>. This is NOT a recurring convention."`

### Step 2: Restore Project Context
- Identify the active `project` entity and its status
- Identify the most recent `session` entity for continuity
- Review any open items from the previous session

### Step 3: Respond
- Only after Steps 0–2 are complete, formulate the first response to the user
- The response must reflect restored context — Zoo should appear to remember everything

## 6. Maintenance

### Periodic Cleanup (every ~5 sessions or when clutter is noticed)
- **Sessions:** Consolidate multiple same-day sessions that are troubleshooting/minor follow-ups into a single session entity
- **Decisions:** Merge redundant decisions documenting the same conclusion (keep the most complete one, delete duplicates)
- **Files:** Remove `file` entities for files that no longer exist in the workspace
- **Observations:** Remove outdated or superseded observations from entities

### Knowledge Graph Hygiene
- The convention entity `convention-memory-storage` always points to this document as its canonical source
- After any cleanup, verify that relations remain consistent (no dangling references to deleted entities)
- The bootstrap protocol (Section 5) and its enforcement via `.clinerules` must never be removed or weakened

### File Hygiene
- [`BOOTSTRAP.md`](BOOTSTRAP.md) is redundant — `.clinerules` supersedes it. Delete if found.
- This document (`memory-strategy.md`) is the single canonical strategy reference

---

## Appendix A: Bootstrap Enforcement History

The bootstrap protocol went through 4 iterations before a working solution was found:

| Iteration | Date | Approach | Result |
|---|---|---|---|
| 1 | 2026-07-06 (session a) | Section 5 added to this document | **Failed** — Zoo didn't read this file before responding |
| 2 | 2026-07-06 (session b) | Added failure log header + `BOOTSTRAP.md` workspace file | **Failed** — both files are passive, Zoo ignored them |
| 3 | 2026-07-06 (session c) | Diagnosed root cause: passive documentation can't enforce a pre-response gate. Created `.clinerules` in workspace root — the Zoo Code extension auto-injects `.clinerules` content into the system prompt | **Pending test** |
| 4 | 2026-07-06 (session d) | `.clinerules` injection worked — Zoo called `read_graph` before first response | **Success** ✅ |

**Conclusion:** `.clinerules` in the workspace root is the only known technical enforcement mechanism for the bootstrap protocol. It works by putting the `read_graph` instruction directly into the system prompt, making it a hard gate rather than a passive suggestion.
