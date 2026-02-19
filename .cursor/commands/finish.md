# Finish Task

Complete the task with code review, test validation, regression detection, and pattern detection.

---

## Workflow Overview

```
/finish → Parallel Review (code + tests) → Regression Detection → Pattern Detection → Done
```

**Estimated Time:** 25-35 seconds (parallel review: 15-20s, regression: 10-15s)

---

## Steps

### 1. Parallel Review
**Launch in parallel** (single message, two Tasks):

**Subagent 1: code-reviewer**
```javascript
Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/code-reviewer.md. 
          Changed files: <list>. 
          Schema: docs/<TICKET_ID>/schema_analysis_report.md. 
          Verbosity: full",
  description="Review code quality"
)
```
- **Checks:** N+1 queries, Joi validation, HIPAA, performance, patterns
- **Output:** `docs/<JIRA_TICKET_ID>/code_review_report.md`

**Subagent 2: test-validator**
```javascript
Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/test-validator.md. 
          Changed files: <list>. 
          TDD Blueprint: docs/<TICKET_ID>/tdd_blueprint.md. 
          Verbosity: full",
  description="Validate test coverage"
)
```
- **Checks:** Test existence, execution, quality, coverage
- **Output:** `docs/<JIRA_TICKET_ID>/test_validation_report.md`

**Decision Point:**
- **If BOTH PASS:** Continue to Step 2
- **If EITHER FAILS:** Fix issues, do not proceed

**See:** `.cursor/skills/review/SKILL.md` for pass/fail criteria

### 2. Regression Detection
**Subagent: regression-detector** (sequential, after review passes)

```javascript
Task(
  subagent_type="generalPurpose",
  model="default",
  prompt="Read and execute .cursor/agents/regression-detector.md. 
          Changed files: <list>. 
          Changed functions: <list>. 
          Verbosity: full",
  description="Detect regression impact"
)
```
- **Finds:** Direct + indirect dependencies
- **Assesses:** Risk level (high/medium/low)
- **Recommends:** Regression tests
- **Output:** `docs/<JIRA_TICKET_ID>/regression_impact_report.md`

**Decision Point:**
- **If high-risk regressions:** Add recommended tests before proceeding

### 3. Pattern Detection & Rulebook Update
**Main agent uses:** `.cursor/skills/sentinel/SKILL.md`

**What happens:**
- Auto-detect new patterns (16 criteria)
- Check if PR introduces:
  - New library/framework
  - New architectural pattern
  - New cross-service integration
  - New workflow state
  - New business rule
- **If detected:** Propose rule addition to `tech_stack.mdc` or `business_logic.mdc`
- **If approved:** Update rulebook

**Decision Point:**
- If new pattern detected, ask user: "Should I add this rule to the rulebook?"

---

## Usage

```
/finish
```

**Prerequisite:** Implementation complete, all tests pass
