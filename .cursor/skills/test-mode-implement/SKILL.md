---
name: test-mode-implement
description: Phase 2 of Test Mode - Blind Orbit implementation without access to developer PR. Implements from Jira ticket only with full isolation.
---

# Test Mode Implement (Phase 2 - BLIND)

**Purpose**: Re-implement the feature using Orbit workflow WITHOUT seeing the developer's solution.

**Critical**: This phase must have ZERO access to sealed folders.

---

## Pre-Flight Checks

### 1. Verify New Session

This MUST be a fresh session. Check:
```
- No context from Phase 1
- No developer PR in recent files
- No developer names in conversation history
```

### 2. Verify Sealed Folders Exist

Check that Phase 1 completed:
```bash
# These must exist:
docs/{TICKET_ID}/developer_pr/SEALED.txt
docs/{TICKET_ID}/.sealed/checksums_before.txt
docs/{TICKET_ID}/.sealed/comparison_baseline.json
```

If missing, STOP and run Phase 1 first.

### 3. Load Restrictions

Read: `.cursor/test-mode/restrictions.md`

**BLOCKED PATHS**:
- `docs/{TICKET_ID}/developer_pr/`
- `docs/{TICKET_ID}/.sealed/`

**BLOCKED TERMS**:
- Developer PR number (e.g., "#2724")
- Developer username (from baseline)
- "developer_pr"

### 4. Initialize File Access Log

Create: `.orbit/file_access_log.txt`

```
# Test Mode Phase 2 - File Access Log
# Ticket: {TICKET_ID}
# Started: 2026-02-16T11:00:00Z
# Any access to sealed paths will be logged here
```

---

## Workflow

### Step 1: Fetch Jira Ticket ONLY

```javascript
// Use Jira MCP
user-Jira-MCP-Server-jira_get_issue(ticket_id, fields="*all")
```

**DO NOT**:
- Read developer_pr/ folder
- Reference any PR numbers
- Look at sealed baseline

### Step 2: Run Orbit Discovery (/start)

Execute standard Orbit discovery:

```
/start {TICKET_ID}
```

This will:
1. Run jira-context-analysis skill
2. Launch schema-analyzer subagent
3. Launch rabbit-tracer subagent (if needed)
4. Run discovery skill
5. Generate discovery reports

**Restriction**: Do NOT reference developer PR in any reports.

### Step 3: Run Orbit Planning (/plan)

Execute standard Orbit planning:

```
/plan
```

This will:
1. Launch risk-analyzer subagent
2. Launch tdd-planner subagent
3. Run implementation-planning skill
4. Generate planning reports

**Restriction**: Plans should be based on Jira requirements only.

### Step 4: Implement (TDD Red-Green-Refactor)

Follow standard Orbit implementation:

1. **Red Phase**: Create failing tests
2. **Green Phase**: Implement code to pass tests
3. **Refactor Phase**: Optimize code
4. **Commit**: Save changes

**Restriction**: Do NOT reference developer code or patterns.

### Step 5: Run Orbit Validation (/finish)

Execute standard Orbit validation:

```
/finish
```

This will:
1. Launch code-reviewer subagent
2. Launch test-validator subagent
3. Launch regression-detector subagent
4. Run sentinel skill (pattern detection)

**Restriction**: Reviews should compare against project standards, NOT developer PR.

---

## Verification During Phase 2

### Continuous Monitoring

After EACH file read, check:
```javascript
// Is this a sealed path?
if (filePath.includes('developer_pr') || filePath.includes('.sealed')) {
  ALERT: "VIOLATION - Attempted to access sealed path: " + filePath
  LOG: Append to .orbit/violations.txt
  STOP: Halt execution
}
```

### Periodic Checks

Every 10 tool calls:
1. Review conversation history for blocked terms
2. Check recent file reads
3. Verify no PR references

---

## Output Files

```
docs/{TICKET_ID}/
├── context_analysis_report.md      # Orbit generated
├── schema_analysis_report.md       # Orbit generated
├── discovery_report.md             # Orbit generated
├── tdd_blueprint.md                # Orbit generated
├── risk_assessment_report.md       # Orbit generated
├── implementation_plan.md          # Orbit generated
├── code_review_report.md           # Orbit generated
├── test_validation_report.md       # Orbit generated
├── regression_impact_report.md     # Orbit generated
├── IMPLEMENTATION_SUMMARY.md       # Orbit generated
├── VALIDATION_SUMMARY.md           # Orbit generated
└── phase2_implementation_report.md # NEW
```

**Git Branch**: `test/orbit-validation-{TICKET_ID}`

---

## Post-Implementation Verification

### Step 1: Generate File Access Report

Create: `docs/{TICKET_ID}/phase2_file_access_report.md`

```markdown
# Phase 2 File Access Report

**Ticket**: {TICKET_ID}
**Completed**: 2026-02-16T14:00:00Z

## Files Read During Phase 2

Total files read: 127

### By Category

**Allowed (Project Files)**:
- Library/Common/Contants.js ✅
- service-csiq-bigquery-ai-summary/... ✅
- (127 files listed)

**Sealed (Blocked)**:
- NONE ✅ (Expected)

## Violations

**Count**: 0 ✅

No sealed files were accessed during Phase 2.
```

### Step 2: Verify Checksums

```bash
# Generate new checksums
find docs/{TICKET_ID}/developer_pr -type f -exec sha256sum {} \; > docs/{TICKET_ID}/.sealed/checksums_after.txt

# Compare
diff docs/{TICKET_ID}/.sealed/checksums_before.txt \
     docs/{TICKET_ID}/.sealed/checksums_after.txt
```

**Expected**: No differences (files untouched)

### Step 3: Context Analysis

Scan conversation for blocked terms:
```bash
# Search transcript for:
- Developer PR number
- Developer username  
- "developer_pr"
- PR review comments
```

**Expected**: No matches

### Step 4: Generate Compliance Report

Create: `docs/{TICKET_ID}/phase2_compliance_report.md`

```markdown
# Phase 2 Compliance Report

**Status**: ✅ COMPLIANT / ❌ VIOLATION

## Checks

1. **File Access**: ✅ No sealed files read
2. **Checksums**: ✅ Unchanged (files untouched)
3. **Context**: ✅ No developer PR references
4. **Implementation**: ✅ Based on Jira only

## Verification Evidence

- File access log: 0 violations
- Checksum diff: Identical
- Context scan: 0 blocked terms found

## Conclusion

Phase 2 implementation was completed with full isolation.
Orbit implementation is unbiased and ready for comparison.
```

---

## Step 5: Generate Phase 2 Summary

Create: `docs/{TICKET_ID}/phase2_implementation_report.md`

**Contents**:
```markdown
# Test Mode Phase 2: Implementation Complete

**Ticket**: {TICKET_ID}
**Branch**: test/orbit-validation-{TICKET_ID}
**Completed**: 2026-02-16T14:00:00Z

## Orbit Implementation

- Files Changed: X
- Lines Added: +Y
- Lines Deleted: -Z
- Tests Created: N
- Reports Generated: M

## Isolation Verified

✅ No access to developer PR
✅ Checksums unchanged
✅ Context clean
✅ Implementation unbiased

## Next Steps

1. START NEW SESSION (to clear context)
2. Run: `/test-mode-compare {TICKET_ID}`
3. Compare Orbit vs Developer implementations
```

### Step 6: EXIT

**STOP HERE**. Do NOT proceed to comparison.

User must start a NEW SESSION for Phase 3.

---

## Command Usage

```bash
# User runs (in NEW session):
/test-mode-implement CSIQ-13534

# Agent:
# 1. Verifies sealed folders exist
# 2. Loads restrictions
# 3. Runs /start (discovery)
# 4. Runs /plan (planning)
# 5. Implements (TDD)
# 6. Runs /finish (validation)
# 7. Verifies compliance
# 8. Generates reports
# 9. EXITS (does not compare)
```

---

## Critical Rules

1. ✅ DO: Implement from Jira ONLY
2. ✅ DO: Follow full Orbit workflow
3. ✅ DO: Track all file reads
4. ✅ DO: Verify compliance at end
5. ✅ DO: Exit after implementation
6. ❌ DON'T: Read sealed folders
7. ❌ DON'T: Reference developer PR
8. ❌ DON'T: Continue to comparison
9. ❌ DON'T: Peek at developer code

---

## Success Criteria

- [ ] New session verified
- [ ] Sealed folders verified
- [ ] Restrictions loaded
- [ ] Discovery complete (/start)
- [ ] Planning complete (/plan)
- [ ] Implementation complete (TDD)
- [ ] Validation complete (/finish)
- [ ] File access report clean
- [ ] Checksums unchanged
- [ ] Context scan clean
- [ ] Compliance report generated
- [ ] Phase 2 summary created
- [ ] Agent EXITS (session ends)
