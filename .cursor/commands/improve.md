# Feature Improvement

Improve or extend an existing feature. Handles both sub-tasks (with a parent story) and standalone improvement tickets.

---

## Workflow Overview

```
/improve CSIQ-16333
  ↓
Fetch ticket → Check for parent ticket?
  ↓                    ↓
Has parent          Standalone
  ↓                    ↓
Fetch parent PRD    Use current ticket as PRD
Extract comments    (treat like /start)
Scope to sub-task
  ↓                    ↓
  └──── Discovery (scoped) ────┘
          ↓
         /plan
          ↓
       Implement
          ↓
        /finish
```

**Estimated Time:** 20-30 minutes (same as standard workflow)

---

## Steps

### 1. Fetch the Ticket

Use `jira-context-analysis` skill with the ticket ID.

**From the ticket, immediately check:**
- Does it have a **parent ticket**? (issuetype = Sub-task, Story, Task with parent field)
- What is the **current status**? (In Progress / Code Review → there may be an existing PR)
- Are there **linked PRs** in comments? (github.com links)
- What is the **scope signal** in the summary?
  - `[BackEnd]`, `[FE]`, `[API]` prefixes indicate a scoped sub-task
  - No prefix and full description → likely standalone

**Save:** `docs/<TICKET_ID>/context_analysis_report.md`

---

### 2. Determine Context Strategy

#### If ticket has a parent:

**Fetch the parent ticket** and extract:

1. **Full PRD from parent:**
   - Problem Statement
   - User Stories
   - Proposed Solution
   - Edge Cases
   - Assumptions & Dependencies

2. **Design decisions from parent comments** (critical — decisions often live here, not in the description):
   - Technology choices made during sprint
   - Scope changes ("as discussed, we will only show file name")
   - Edge case resolutions ("only for blind transfers, not warm/PT")
   - Status values, field names, API contracts agreed in-thread

3. **Scope boundary** — understand what the sub-task covers vs what the parent covers:
   - Current ticket: backend API for View Call Path
   - Parent covers: entire 2-party consent flow (config, softphone UI, audit log, etc.)
   - **Only implement what's in THIS sub-task**

4. **Check for existing PR** — if in Code Review, extract PR URL from comments for reference context.

**Save:** `docs/<TICKET_ID>/parent_context.md`

```markdown
# Parent Context — CSIQ-16176 → CSIQ-16333

## Sub-task Scope
[What this specific ticket covers]

## Parent PRD Summary
[Key requirements relevant to this sub-task]

## Design Decisions from Comments
- [Decision 1: only show file name, not full path]
- [Decision 2: status values = Completed / Interrupted]
- [Decision 3: only blind transfers, not warm/PT transfers]

## Out of Scope (in parent but NOT this sub-task)
- [List features that belong to sibling sub-tasks]

## Existing PR (if any)
- PR #5491: https://github.com/CS-IQ/CSIQ-Laravel/pull/5491
```

#### If ticket is standalone:

Treat the ticket description as the full PRD — proceed exactly like `/start`.

No parent context file needed.

---

### 3. Scoped Discovery

Launch subagents based on what the sub-task touches:

**Launch in parallel (where applicable):**

```javascript
// Always: schema-analyzer (check if DB changes needed)
Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/schema-analyzer.md.
          Context: docs/<TICKET_ID>/context_analysis_report.md.
          Focus: existing tables/collections relevant to this improvement.
          Do NOT analyze the full schema — only tables touched by this sub-task.
          Verbosity: full",
  description="Analyze DB schema for improvement scope"
)

// Only if message queues are involved:
Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/rabbit-tracer.md.
          Context: docs/<TICKET_ID>/context_analysis_report.md.
          Verbosity: full",
  description="Trace message flows for improvement"
)
```

**Main agent discovery (inline):**
- Find the **existing feature module** this improvement extends
- Identify the **exact files** that need changing
- Confirm the current behaviour that will be changed
- Identify any **API contracts** between services (especially if sub-task is backend-only)

**Save:** `docs/<TICKET_ID>/discovery_report.md`

⏸️ **User confirms discovery scope is correct**

---

### 4. Run `/plan`

Same as standard workflow.

```
/plan
```

The `/plan` command will:
- Use `docs/<TICKET_ID>/context_analysis_report.md` and `parent_context.md` (if exists) as input
- Launch `tdd-planner` + `risk-analyzer` in parallel
- Synthesize implementation plan

**The plan will be scoped to this sub-task only**, not the full parent story.

---

### 5. Implement

Follow the implementation plan. Keep scope discipline:
- Only implement what this sub-task specifies
- If you discover something that belongs to a sibling sub-task, note it but don't implement it
- Respect design decisions extracted from parent comments

---

### 6. Run `/finish`

```
/finish
```

Same as standard workflow — `code-reviewer`, `test-validator`, `regression-detector`.

---

## Usage

```
/improve CSIQ-16333
```

**No prerequisite** — fetches ticket (and parent, if applicable) directly.

---

## Output Files

```
docs/CSIQ-16333/
├── context_analysis_report.md     ← Sub-task ticket summary
├── parent_context.md              ← Parent PRD + comment decisions (if sub-task)
├── discovery_report.md            ← Scoped discovery
├── schema_analysis_report.md      ← DB schema (if applicable)
├── tdd_blueprint.md               ← From /plan
├── risk_assessment_report.md      ← From /plan
├── implementation_plan.md         ← From /plan
├── code_review_report.md          ← From /finish
├── test_validation_report.md      ← From /finish
└── regression_impact_report.md    ← From /finish
```

---

## Key Differences from `/start`

| | `/start` + `/plan` | `/improve` |
|---|---|---|
| Entry point | Top-level story with PRD | Sub-task OR standalone improvement ticket |
| PRD location | Current ticket | Parent ticket (if sub-task) |
| Design decisions | TBD at planning time | Already in parent comments — must extract |
| Discovery scope | Full feature | Scoped to existing module only |
| Scope discipline | Build the full feature | Only this sub-task, nothing from sibling sub-tasks |
| Existing PR | None | May already exist in Code Review |
