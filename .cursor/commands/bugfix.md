# Bug Fix

Diagnose and fix a bug reported by QA/testers. Focuses on fast root-cause analysis, surgical fix, and regression safety.

---

## Workflow Overview

```
/bugfix CSIQ-15753
  ↓
Fetch bug ticket → Root Cause Analysis → Classify (small/big)
  ↓              ↓
 Small bug      Big bug
  ↓              ↓
 Fix Plan        Full Plan (TDD + Risk + Implementation Plan)
  ↓              ↓
  └──── Implement Fix ────┘
          ↓
        /finish
```

**Estimated Time:**
- Small bug: 5-10 minutes
- Big bug: 15-25 minutes

---

## Steps

### 1. Fetch Bug Ticket

Use `jira-context-analysis` skill with the ticket ID.

**Extract from ticket:**
- Summary (what is broken)
- Description (steps to reproduce, actual vs expected behaviour)
- Priority (High/Critical → likely big bug; Medium/Low → likely small)
- Reporter (tester name — useful for follow-up)
- Affected area (component/feature name)

**Save:** `docs/<TICKET_ID>/context_analysis_report.md`

---

### 2. Root Cause Analysis

**Main agent traces the broken behaviour:**

1. **Identify the trigger** — what user action causes the bug?
   - e.g. "User sends SMS response to a missed call"

2. **Trace the code path** — follow the trigger through the codebase:
   - API route → controller → service → repository/DB query
   - Find the exact function where state is incorrectly updated

3. **Identify the flaw** — what condition is missing or wrong?
   - e.g. "The state update query does not filter by `status != 'Ignored'"

4. **Map blast radius** — what else touches this code?
   - Other callers of the same function
   - Other features that depend on the same state field

**Save:** `docs/<TICKET_ID>/bug_analysis_report.md`

```markdown
# Bug Analysis Report — CSIQ-15753

## Bug Summary
[One sentence: what is broken and where]

## Root Cause
- File: src/services/missedCallService.js
- Function: updateCallStateOnSmsResponse()
- Line: ~142
- Flaw: State update does not filter out calls already in 'Ignored' state

## How it breaks
[Exact condition that triggers wrong behaviour]

## Blast Radius
- Files affected: [list]
- Other features using this code: [list]
- Data at risk: [any state corruption?]

## Classification
[ ] Small bug — isolated, 1-3 files, no architectural change needed
[ ] Big bug  — cross-cutting, state corruption risk, or needs architectural decision
```

---

### 3. Classify the Bug

**After root cause analysis, decide:**

#### Small Bug ✅

Criteria (all must be true):
- Fix touches **1-3 files**
- Fix is a **condition or filter change** (not a new data model)
- **No data migration** required
- **No cross-service impact**
- Risk of regression is **low to medium**

→ Go to **Step 4a: Targeted Fix Plan**

#### Big Bug 🔴

Criteria (any one is true):
- Fix touches **4+ files** or a **shared utility/service**
- Bug involves **state corruption** (data already affected in production)
- Requires **architectural decision** (e.g. redesign the state machine)
- Fix has **cross-service side effects**
- **High regression risk** (touching core flow)

→ Go to **Step 4b: Full Plan** (TDD + Risk + Implementation Plan)

---

### 4a. Targeted Fix Plan (Small Bug)

**No subagents needed — main agent creates the plan directly.**

```markdown
# Fix Plan — CSIQ-15753

## Minimal Fix
- File to change: src/services/missedCallService.js
- Change: Add WHERE status != 'Ignored' to the state update query
- Why minimal: Only the query filter is wrong, no architecture change

## What NOT to touch
- Do not refactor the surrounding function
- Do not change state transition constants
- Do not alter other state update callers

## Regression Tests to Write
1. SMS response on a call in 'Open' state → should move to 'Responded'
2. SMS response on a call in 'Ignored' state → must stay 'Ignored'
3. SMS response when multiple calls exist for same patient:
   - Open calls → Responded ✅
   - Ignored calls → Ignored ✅ (the bug scenario)

## Risk
- Green — isolated, low blast radius
```

**Save:** `docs/<TICKET_ID>/fix_plan.md`

⏸️ **User confirms fix plan before coding**

---

### 4b. Full Plan (Big Bug)

**Launch in parallel:**

```javascript
Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/tdd-planner.md.
          Context: docs/<TICKET_ID>/bug_analysis_report.md.
          Focus: regression tests for the bug scenario AND unit tests for the fix.
          Verbosity: full",
  description="Generate TDD Blueprint for bug fix"
)

Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/risk-analyzer.md.
          Context: docs/<TICKET_ID>/bug_analysis_report.md.
          Focus: blast radius, regression risks, production data impact.
          Verbosity: full",
  description="Assess bug fix risks"
)
```

**Wait for both to complete, then:**

Use `.cursor/skills/implementation-planning/SKILL.md` to synthesize:
- Root cause summary
- Minimal fix approach
- Risk mitigation steps
- Full TDD coverage (bug scenario + regression scenarios)
- Rollback plan (especially if data migration needed)

**Save:** `docs/<TICKET_ID>/implementation_plan.md`

⏸️ **User approves plan before coding**

---

### 5. Implement the Fix

**Guiding principles:**
- **Surgical** — change only what the fix plan specifies
- **No opportunistic refactoring** — resist the urge to clean up surrounding code
- **Write regression tests first** — confirm the bug is reproducible via a failing test, then fix

**Implementation order:**
1. Write the failing regression test (proves bug exists)
2. Run test → confirm it fails
3. Apply the fix
4. Run test → confirm it passes
5. Run all existing tests → confirm nothing broke

---

### 6. Run `/finish`

Same as standard workflow — runs `code-reviewer`, `test-validator`, and `regression-detector`.

```
/finish
```

The `regression-detector` is especially important for bug fixes — it will scan for any other callers of the modified function that might now behave differently.

---

## Usage

```
/bugfix CSIQ-15753
```

**No prerequisite** — does not require `/start` first. Fetches ticket directly.

---

## Output Files

```
docs/CSIQ-15753/
├── context_analysis_report.md     ← Ticket summary
├── bug_analysis_report.md         ← Root cause + blast radius + classification
└── fix_plan.md                    ← Targeted fix plan (small bug)
    OR implementation_plan.md      ← Full plan (big bug)
```

---

## Key Differences from `/start` + `/plan`

| | `/start` + `/plan` | `/bugfix` |
|---|---|---|
| Entry point | PRD / story | Tester bug report |
| Discovery focus | What to build | Where is it broken |
| Planning | Full 18-aspect plan (always) | Targeted fix plan (small) or full plan (big) |
| Tests | TDD — write first, define behaviour | Regression — reproduce bug first, then fix |
| Refactoring | Allowed | Explicitly avoided |
| Speed | Thorough | Fast for small bugs |
