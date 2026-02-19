# Plan (TDD Blueprint + Risk Assessment)

Create a test-first implementation plan and assess risks before coding.

---

## Workflow Overview

```
/plan → Cache Check → Parallel (TDD + Risk) → Implementation Skill → Validate → Approval
```

**Estimated Time:** 25-35 seconds (2 subagents parallel + skill synthesis)

---

## Steps

### 1. Check Cached Reports
Look for existing reports in `docs/<JIRA_TICKET_ID>/`:
- `context_analysis_report.md` (from `/start`)
- `discovery_report.md` (from `/start`)
- `schema_analysis_report.md` (from `/start`)

**If found:** Reuse (state "Using cached reports from `/start`")  
**If missing:** User must run `/start` first

### 2. Parallel Planning (2 Subagents)
**Launch in parallel** (single message, **two** Tasks):

**Subagent 1: tdd-planner**
```javascript
Task(
  subagent_type="generalPurpose",
  model="default",  // Requires reasoning
  prompt="Read and execute .cursor/agents/tdd-planner.md. 
          Context: docs/<TICKET_ID>/discovery_report.md. 
          Verbosity: full",
  description="Generate TDD Blueprint"
)
```
- **Output:** `docs/<JIRA_TICKET_ID>/tdd_blueprint.md`

**Subagent 2: risk-analyzer**
```javascript
Task(
  subagent_type="generalPurpose",
  model="default",  // Requires reasoning
  prompt="Read and execute .cursor/agents/risk-analyzer.md. 
          Context: docs/<TICKET_ID>/discovery_report.md. 
          Verbosity: full",
  description="Assess implementation risks"
)
```
- **Output:** `docs/<JIRA_TICKET_ID>/risk_assessment_report.md`

### 3. Wait for Subagents to Complete
Both subagents must complete before proceeding.

### 4. Run Implementation Planning Skill
**Main agent uses:** `.cursor/skills/implementation-planning/SKILL.md`

**What happens:**
- Reads all cached reports (Context Analysis, Discovery, Schema, Rabbit)
- Reads newly completed reports (TDD Blueprint, Risk Assessment)
- Synthesizes Technical Implementation Plan with 18-aspect table
- Cross-references all reports
- **Saves:** `docs/<JIRA_TICKET_ID>/implementation_plan.md`

**Structure:**
1. **Problem Summary** (from Context Analysis)
2. **Proposed Solution Overview** (from Context Analysis)
3. **Technical Implementation Plan** (18-aspect table synthesized from all reports)
4. **Risk Assessment** (from risk-analyzer)
5. **TDD Blueprint** (from tdd-planner)
6. **Implementation Readiness Checklist** (synthesized)

### 5. Validate TDD Blueprint Completeness
**Use checklist from:** `.cursor/skills/tdd-planning/SKILL.md`

**10-item checklist:**
- Unit tests for all functions
- Integration tests for APIs/consumers
- Edge case tests
- Error scenario tests
- HIPAA compliance tests (if PHI)
- Performance tests (N+1 prevention)
- Joi validation tests
- Test data/fixtures
- Coverage map (requirements → tests)

**If incomplete:** Request missing tests before approval

### 6. Present & Get Approval
**Show user:**
- **Technical Implementation Plan** (problem, solution, architecture, DB, APIs, security, performance, rollback)
- **TDD Blueprint** (Red → Green → Refactor, coverage map)
- **Risk Assessment** (Green/Yellow/Red, mitigation checklist)

**Decision:**
- If Risk = Red (Stop): Address critical risks before proceeding
- If Risk = Yellow (Caution): Discuss high-risk mitigations
- If Risk = Green (Go): Proceed with explicit user approval

**No implementation until user approves**

---

## Usage

```
/plan
```

**Prerequisite:** Must run `/start` first (needs cached reports)
