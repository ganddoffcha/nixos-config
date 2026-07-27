# Memory Persistence Strategy

> Defines what Zoo automatically stores in the MCP knowledge graph to maintain context across sessions.
>
> **Bootstrap reality:** The [`.clinerules`](.clinerules) file injects the bootstrap protocol into Zoo's system prompt. However, after 6 violations across sessions, the pragmatic conclusion is that Zoo cannot reliably be forced to call `read_graph` before the first response. The two-message bootstrap pattern (user greets → Zoo responds → user gives task → Zoo reads graph) is reliable and accepted. See Appendix A for full history.

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

> **Pragmatic conclusion (2026-07-27):** After 6 violations and multiple enforcement attempts, the two-message bootstrap pattern is the reliable approach. Zoo calls `read_graph` on the second user message (the actual task), not the first (greeting). This is documented in Appendix A.

### Reliable Pattern (Two-Message Bootstrap)
- **Message 1 (user greeting):** Zoo may respond conversationally without `read_graph`. This is acceptable.
- **Message 2 (user task):** Zoo MUST call `read_graph` to restore context before addressing the task.
- **After read_graph:** Process one-shot observations, restore project context, then respond with full awareness.

### Best-Effort Pattern (When It Works)
- When Zoo DOES call `read_graph` before first response (happens ~80% of sessions), follow:
  - Step 0: `read_graph` first
  - Step 1: Process one-shot observations
  - Step 2: Restore project context (active project, last session, open items)
  - Step 3: Respond with full context

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

The bootstrap protocol went through 6 iterations. The pragmatic conclusion: two-message bootstrap is the reliable pattern.

| Iteration | Date | Approach | Result |
|---|---|---|---|
| 1 | 2026-07-06 (session a) | Section 5 added to this document | **Failed** — passive doc, Zoo never reads it before responding |
| 2 | 2026-07-06 (session b) | Added `BOOTSTRAP.md` workspace file | **Failed** — same passive doc problem |
| 3 | 2026-07-06 (session c) | Diagnosed root cause: need technical enforcement | **Diagnosis only** |
| 4 | 2026-07-06 (session d) | `.clinerules` injection — Zoo Code auto-injects into system prompt | **Success** ✅ — worked for 46 sessions |
| 5 | 2026-07-27 (session e) | Dual-injection: `.clinerules-{mode}` files as second enforcement point | **Failed** — violated on very next session |
| 6 | 2026-07-27 (session f) | Accepted two-message bootstrap as reliable pattern | **Pragmatic conclusion** |

**Conclusion:** System prompt injection (`.clinerules`) worked for 46 sessions but is not 100% reliable — Zoo's default conversational behavior sometimes overrides injected instructions. The two-message bootstrap (read_graph on message 2) is the pragmatic, reliable pattern. The knowledge graph remains valuable for context persistence regardless of which message triggers the read.
