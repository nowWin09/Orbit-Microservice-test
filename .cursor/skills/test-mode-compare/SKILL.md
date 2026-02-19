---
name: test-mode-compare
description: Phase 3 of Test Mode - Objective comparison of Orbit vs Developer implementations using anonymized analysis.
---

# Test Mode Compare (Phase 3 - UNBIASED)

**Purpose**: Compare Orbit and Developer implementations objectively without bias.

**Critical**: Implementations should be anonymized before comparison.

---

## Pre-Flight Checks

### 1. Verify New Session

This MUST be a fresh session. Check:
```
- No context from Phase 1 or Phase 2
- No implementation details in recent files
- Clean conversation history
```

### 2. Verify Both Implementations Exist

Check that Phase 1 and 2 completed:
```bash
# Phase 1 output (sealed):
docs/{TICKET_ID}/developer_pr/pr_diff.patch
docs/{TICKET_ID}/.sealed/comparison_baseline.json

# Phase 2 output (workspace):
docs/{TICKET_ID}/IMPLEMENTATION_SUMMARY.md
docs/{TICKET_ID}/VALIDATION_SUMMARY.md
test/orbit-validation-{TICKET_ID} branch
```

If missing, STOP and complete previous phases.

### 3. Verify Compliance

Read: `docs/{TICKET_ID}/phase2_compliance_report.md`

Check:
- ✅ File access: Clean
- ✅ Checksums: Unchanged
- ✅ Context: No violations

If violations found, comparison is INVALID.

---

## Workflow

### Step 1: Unseal Developer PR

**Now it's safe to read the sealed folders.**

Read:
- `docs/{TICKET_ID}/developer_pr/pr_metadata.json`
- `docs/{TICKET_ID}/developer_pr/pr_diff.patch`
- `docs/{TICKET_ID}/developer_pr/analysis.md`
- `docs/{TICKET_ID}/.sealed/comparison_baseline.json`

### Step 2: Create Anonymous Comparison Workspace

Create temporary structure:

```
.orbit/comparison/{TICKET_ID}/
├── candidate_A/          # Orbit implementation (anonymized)
│   ├── service-csiq-appointment-bigquery/
│   ├── service-csiq-patient-appointment-linking/
│   ├── Library/Common/Contants.js
│   └── pm2.json
├── candidate_B/          # Developer implementation (anonymized)
│   ├── service-csiq-appointment-bigquery/
│   ├── service-csiq-patient-appointment-linking/
│   ├── Library/Common/Contants.js
│   └── pm2.json
└── metadata.json         # Maps A/B to Orbit/Developer (sealed until reveal)
```

### Step 3: Anonymize Both Implementations

**Remove identifying information:**

```javascript
// For both candidate_A and candidate_B:
- Strip author names from comments
- Remove commit messages
- Remove @author JSDoc tags
- Remove timestamps
- Normalize formatting
- Rename branch references to "candidate_A" / "candidate_B"
```

Create: `.orbit/comparison/{TICKET_ID}/metadata.json`

```json
{
  "candidate_A": "orbit",
  "candidate_B": "developer",
  "reveal_at_end": true
}
```

**SEAL THIS FILE** - Do not read until comparison complete.

### Step 4: Compare Using 5 Metrics

**Load orbit-validator agent behavior** but do NOT reveal which is which.

Compare:
1. **Code Quality** (30 points)
2. **Test Coverage** (25 points)
3. **Performance** (20 points)
4. **Security** (15 points)
5. **Architecture** (10 points)

**Instructions to comparison agent**:
```
You are comparing two implementations: Candidate A and Candidate B.

DO NOT assume either is "better" or "official".
DO NOT reference "Orbit" or "Developer".
DO NOT reveal identities until scoring complete.

Analyze OBJECTIVELY based on metrics only.
```

### Step 5: Generate Blind Comparison Report

Create: `docs/{TICKET_ID}/blind_comparison_report.md`

**Format** (before reveal):
```markdown
# Blind Comparison Report

**Ticket**: {TICKET_ID}
**Compared**: 2026-02-16T15:00:00Z

## Scoring (Anonymous)

| Metric | Max | Candidate A | Candidate B | Winner |
|--------|-----|-------------|-------------|--------|
| Code Quality | 30 | 26 | 20 | A |
| Test Coverage | 25 | 23 | 2 | A |
| Performance | 20 | 18 | 16 | A |
| Security | 15 | 14 | 9 | A |
| Architecture | 10 | 9 | 7 | A |
| **TOTAL** | **100** | **90** | **54** | **A** |

## Detailed Analysis

### Code Quality (Candidate A: 26/30, Candidate B: 20/30)

**Candidate A Strengths:**
- Entry-point validation with Joi
- Strict schemas (`.unknown(false)`)
- HIPAA-compliant logging
- Clear error handling

**Candidate B Strengths:**
- Compact and focused
- Follows existing patterns
- Fast delivery

**Winner: Candidate A** (+6 points)

(... continue for all 5 metrics ...)

## Side-by-Side Code Comparison

### Consumer Validation

**Candidate A:**
```javascript
payload = validateIncomingMessage(payload);
console.log(`[${queue}]::Received message for callId: ${payload?.callId || 'unknown'}`);
```

**Candidate B:**
```javascript
const payload = JSON.parse(message.content.toString());
console.log(`Received message in ${queue}: ${message.content.toString()}`);
```

**Analysis**: Candidate A validates at entry; Candidate B logs full payload (potential PHI).

(... continue comparison ...)

## Verdict (Before Reveal)

**Winner**: Candidate A (90/100)

Candidate A demonstrates superior:
- Test coverage (32 vs 0)
- Security (HIPAA compliance)
- Validation (strict schemas)
- Documentation (comprehensive)

Candidate B demonstrates:
- Speed (faster delivery)
- Simplicity (smaller scope)
- Pragmatism (meets requirements)
```

### Step 6: Reveal Identities

**After scoring is complete**, reveal:

Add to report:
```markdown
---

## REVEAL

**Candidate A** = **Orbit Implementation**
- Branch: test/orbit-validation-{TICKET_ID}
- Commits: 6
- Time: ~3.5 hours

**Candidate B** = **Developer Implementation**
- PR: #{PR_NUMBER}
- Author: {AUTHOR}
- Files: 6 (+388, -14)

## Final Verdict

**Orbit (Candidate A)**: 90/100 (Grade A)
**Developer (Candidate B)**: 54/100 (Grade D+)

**Recommendation**: Use Orbit implementation for production.
```

### Step 7: Generate Unbiased Lessons

Create: `docs/{TICKET_ID}/unbiased_lessons.md`

```markdown
# Unbiased Lessons from Test Mode

**Ticket**: {TICKET_ID}

## What Each Implementation Did Well

### Orbit (Candidate A)
1. Test coverage (32 tests)
2. HIPAA compliance (no PHI in logs)
3. Security (strict validation)
4. Documentation (13 reports)
5. Type safety (coercion + tests)

### Developer (Candidate B)
1. Speed (faster delivery)
2. Simplicity (6 files vs 18)
3. Pragmatism (meets requirements)
4. Pattern consistency (matches repo)

## Objective Comparison

- **Test gap**: 32 vs 0 (Orbit +32)
- **Security gap**: 14/15 vs 9/15 (Orbit +5)
- **Speed gap**: 3.5 hours vs faster (Developer wins)
- **Scope gap**: 18 files vs 6 files (Developer wins)

## Key Insights

1. **Tests matter most**: Biggest scoring gap was test coverage (21 points)
2. **HIPAA is critical**: Security/compliance gap was 5 points
3. **Speed has value**: Developer delivered faster with adequate quality
4. **Both approaches valid**: Orbit for production rigor, Developer for speed

## Recommendations

**For Orbit**:
- Optimize for speed (90% quality in 50% time)
- Lightweight mode for simple features
- Learn from Developer's pragmatism

**For Developer**:
- Add minimum test coverage (at least validation + 1 integration)
- Fix HIPAA logging (no PHI in success path)
- Use strict Joi schemas (`.unknown(false)`)

**For Team**:
- Orbit for critical features (auth, payments, compliance)
- Developer speed for minor features (UI tweaks, reports)
- Hybrid approach for most features (Orbit planning + Developer speed)
```

---

## Verification of Unbiased Comparison

### Independence Check

**Questions to verify**:
1. Did comparison agent see Phase 1 or Phase 2 context? ❌ No
2. Was anonymization complete before scoring? ✅ Yes
3. Were identities hidden during analysis? ✅ Yes
4. Was scoring based on metrics only? ✅ Yes
5. Were both implementations treated equally? ✅ Yes

If ALL answers are as shown, comparison is **UNBIASED**.

---

## Output Files

```
docs/{TICKET_ID}/
├── blind_comparison_report.md         # NEW (anonymous then revealed)
├── unbiased_lessons.md                # NEW
├── orbit_validation_report.md         # Final report (identified)
└── phase3_comparison_report.md        # NEW (summary)

.orbit/comparison/{TICKET_ID}/
├── candidate_A/                       # Orbit (anonymized)
├── candidate_B/                       # Developer (anonymized)
└── metadata.json                      # Identity mapping
```

---

## Step 8: Generate Phase 3 Summary

Create: `docs/{TICKET_ID}/phase3_comparison_report.md`

```markdown
# Test Mode Phase 3: Comparison Complete

**Ticket**: {TICKET_ID}
**Compared**: 2026-02-16T15:00:00Z

## Final Scores

- **Orbit**: 90/100 (A)
- **Developer**: 54/100 (D+)
- **Winner**: Orbit (+36 points)

## Unbiased Process

✅ Phase 1: Developer PR captured and sealed
✅ Phase 2: Orbit implemented blind (no access)
✅ Phase 3: Anonymous comparison (revealed after scoring)

## Independence Verified

- Phase 1 agent: Exited after setup
- Phase 2 agent: No access to sealed folders (compliance verified)
- Phase 3 agent: Anonymized comparison, revealed after scoring

## Test Mode Integrity

**Status**: ✅ VALID

All phases completed with full isolation.
Comparison is unbiased and objective.

## Recommendations

Use Orbit implementation for production deployment.
Learn from Developer's speed and pragmatism for future work.
```

---

## Command Usage

```bash
# User runs (in NEW session):
/test-mode-compare CSIQ-13534

# Agent:
# 1. Verifies compliance from Phase 2
# 2. Unseals developer PR (now safe)
# 3. Creates anonymous workspace
# 4. Compares candidate A vs B (blind)
# 5. Generates scoring (unbiased)
# 6. Reveals identities
# 7. Generates lessons
# 8. Creates final report
```

---

## Critical Rules

1. ✅ DO: Verify Phase 2 compliance first
2. ✅ DO: Anonymize before comparison
3. ✅ DO: Score before revealing identities
4. ✅ DO: Treat both candidates equally
5. ✅ DO: Generate unbiased lessons
6. ❌ DON'T: Assume Orbit is better
7. ❌ DON'T: Reveal identities before scoring
8. ❌ DON'T: Reference previous phases
9. ❌ DON'T: Bias towards either implementation

---

## Success Criteria

- [ ] New session verified
- [ ] Phase 2 compliance verified
- [ ] Developer PR unsealed
- [ ] Anonymous workspace created
- [ ] Blind comparison complete
- [ ] Scoring finished (before reveal)
- [ ] Identities revealed
- [ ] Unbiased lessons generated
- [ ] Final reports created
- [ ] Test mode complete
