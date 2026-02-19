---
description: Test mode commands for blind handoff validation - prevents context leak through 3-phase isolation
globs: []
alwaysApply: false
---

# Test Mode Commands (Blind Handoff)

## Overview

Test mode validates Orbit quality by re-implementing existing features and comparing against developer PRs using **3-phase blind handoff** to prevent context leak.

---

## 🔒 Blind Handoff Pattern

### The Problem
Traditional test mode allows context leak:
- Implementation agent sees developer's code
- Comparison agent is biased by both
- Results are not objective

### The Solution
**3 independent sessions with sealed folders**:

```
Session 1: Setup → Capture & Seal → EXIT
Session 2: Implement (BLIND) → No Access to Sealed → EXIT  
Session 3: Compare → Unseal & Anonymize → Objective Scoring
```

---

## Commands

### `/test-mode-setup <TICKET_ID>`

**Phase 1: Capture Developer PR**

**Purpose**: Fetch and seal the developer's implementation

**What it does**:
1. Fetches Jira ticket
2. Extracts GitHub PR link from comments
3. Captures PR metadata and diff
4. Analyzes developer implementation
5. Generates comparison baseline
6. Creates checksums
7. **SEALS** developer PR folder
8. **EXITS** (does not implement)

**Output**:
```
docs/<TICKET_ID>/
├── developer_pr/              # SEALED
│   ├── pr_metadata.json
│   ├── pr_diff.patch
│   └── analysis.md
├── .sealed/                   # SEALED
│   ├── comparison_baseline.json
│   ├── checksums_before.txt
│   └── SEALED.txt
└── phase1_setup_report.md
```

**Usage**:
```bash
/test-mode-setup CSIQ-13534

# Agent will:
# - Fetch Jira ticket CSIQ-13534
# - Find GitHub PR in comments
# - Capture PR #2724
# - Seal developer_pr/ folder
# - Generate baseline
# - EXIT (requires NEW session for Phase 2)
```

**Critical**: Start **NEW SESSION** after this command.

---

### `/test-mode-implement <TICKET_ID>`

**Phase 2: Blind Orbit Implementation**

**Purpose**: Re-implement feature WITHOUT seeing developer's code

**What it does**:
1. Verifies sealed folders exist (Phase 1 complete)
2. Loads access restrictions
3. Fetches **Jira ticket ONLY** (not PR)
4. Runs full Orbit workflow:
   - `/start` - Discovery
   - `/plan` - Planning
   - Implement - TDD Red-Green-Refactor
   - `/finish` - Validation
5. Tracks all file reads
6. Verifies no access to sealed folders
7. Generates compliance report
8. **EXITS** (does not compare)

**Restrictions**:
- ❌ BLOCKED: `docs/<TICKET_ID>/developer_pr/`
- ❌ BLOCKED: `docs/<TICKET_ID>/.sealed/`
- ❌ BLOCKED: Developer PR references
- ❌ BLOCKED: Developer username
- ✅ ALLOWED: All other project files

**Output**:
```
docs/<TICKET_ID>/
├── context_analysis_report.md
├── schema_analysis_report.md
├── discovery_report.md
├── tdd_blueprint.md
├── risk_assessment_report.md
├── implementation_plan.md
├── code_review_report.md
├── test_validation_report.md
├── regression_impact_report.md
├── IMPLEMENTATION_SUMMARY.md
├── VALIDATION_SUMMARY.md
├── phase2_implementation_report.md
├── phase2_file_access_report.md
└── phase2_compliance_report.md

test/orbit-validation-<TICKET_ID>/ (branch)
```

**Verification**:
After completion, agent verifies:
- ✅ No sealed files accessed
- ✅ Checksums unchanged (files untouched)
- ✅ No developer PR references in context

**Usage**:
```bash
# In NEW SESSION (fresh context):
/test-mode-implement CSIQ-13534

# Agent will:
# - Verify sealed folders
# - Load restrictions
# - Implement from Jira ONLY
# - Full Orbit workflow (/start → /plan → implement → /finish)
# - Verify compliance
# - EXIT (requires NEW session for Phase 3)
```

**Critical**: 
- Must be **NEW SESSION** (no Phase 1 context)
- Start **NEW SESSION** after this command

---

### `/test-mode-compare <TICKET_ID>`

**Phase 3: Unbiased Comparison**

**Purpose**: Objectively compare Orbit vs Developer implementations

**What it does**:
1. Verifies Phase 2 compliance (no violations)
2. **Unseals** developer PR (now safe to read)
3. Creates anonymous comparison workspace:
   - `candidate_A/` (Orbit - anonymized)
   - `candidate_B/` (Developer - anonymized)
4. Compares **blindly** (identities hidden):
   - Code Quality (30 pts)
   - Test Coverage (25 pts)
   - Performance (20 pts)
   - Security (15 pts)
   - Architecture (10 pts)
5. Generates scoring (before revealing identities)
6. **Reveals** identities after scoring
7. Generates unbiased lessons
8. Creates final comparison report

**Anonymization**:
- Strips author names
- Removes timestamps
- Removes commit messages
- Normalizes formatting
- Labels as "Candidate A" and "Candidate B"

**Reveal Timing**:
- Identities are **sealed** during comparison
- Revealed **only after** scoring complete
- Ensures unbiased analysis

**Output**:
```
docs/<TICKET_ID>/
├── blind_comparison_report.md         # Anonymous → Revealed
├── unbiased_lessons.md
├── orbit_validation_report.md         # Final report
└── phase3_comparison_report.md

.orbit/comparison/<TICKET_ID>/
├── candidate_A/ (Orbit)
├── candidate_B/ (Developer)
└── metadata.json (sealed identity mapping)
```

**Usage**:
```bash
# In NEW SESSION (fresh context):
/test-mode-compare CSIQ-13534

# Agent will:
# - Verify Phase 2 compliance
# - Unseal developer PR
# - Anonymize both implementations
# - Compare blindly (Candidate A vs B)
# - Score before revealing
# - Reveal identities
# - Generate final report
```

**Critical**: Must be **NEW SESSION** (no Phase 1 or 2 context)

---

## Full Test Mode Flow

### Timeline

```
Day 1, 10:00 AM - Session 1
┌─────────────────────────────────┐
│ /test-mode-setup CSIQ-13534     │
│ - Fetches Jira + GitHub PR      │
│ - Seals developer_pr/           │
│ - Generates baseline            │
│ - EXITS                         │
└─────────────────────────────────┘
        ↓ (Start NEW session)

Day 1, 10:30 AM - Session 2
┌─────────────────────────────────┐
│ /test-mode-implement CSIQ-13534 │
│ - Implements BLIND (no PR)      │
│ - Full Orbit workflow           │
│ - Verifies compliance           │
│ - EXITS                         │
└─────────────────────────────────┘
        ↓ (Start NEW session)

Day 1, 2:00 PM - Session 3
┌─────────────────────────────────┐
│ /test-mode-compare CSIQ-13534   │
│ - Unseals developer PR          │
│ - Anonymizes both              │
│ - Compares blindly             │
│ - Reveals after scoring        │
│ - Final report                 │
└─────────────────────────────────┘
```

### Estimated Time
- Phase 1 (Setup): 10 minutes
- Phase 2 (Implement): 3-4 hours
- Phase 3 (Compare): 15 minutes
- **Total**: ~4 hours

---

## Verification & Compliance

### After Phase 2

Agent generates compliance report checking:

1. **File Access**: No sealed paths read
   ```bash
   grep "developer_pr\|\.sealed" .orbit/file_access_log.txt
   # Expected: No matches
   ```

2. **Checksums**: Files unchanged
   ```bash
   diff docs/<TICKET_ID>/.sealed/checksums_before.txt \
        docs/<TICKET_ID>/.sealed/checksums_after.txt
   # Expected: Identical
   ```

3. **Context**: No developer references
   ```bash
   grep "hamzathharizz\|PR #2724" .orbit/context_log.txt
   # Expected: No matches
   ```

### Compliance Status

If ANY check fails:
- ❌ **INVALID** - Context leak detected
- Comparison results are **BIASED**
- Must restart Phase 2 with fresh session

If ALL checks pass:
- ✅ **VALID** - Full isolation maintained
- Comparison results are **UNBIASED**
- Proceed to Phase 3

---

## Files & Folders

### Created by Test Mode

```
.cursor/
├── test-mode/
│   └── restrictions.md                # Access restrictions
└── skills/
    ├── test-mode-setup/
    │   └── SKILL.md                   # Phase 1 skill
    ├── test-mode-implement/
    │   └── SKILL.md                   # Phase 2 skill
    └── test-mode-compare/
        └── SKILL.md                   # Phase 3 skill

docs/<TICKET_ID>/
├── developer_pr/                      # SEALED (Phase 1)
│   ├── pr_metadata.json
│   ├── pr_diff.patch
│   └── analysis.md
├── .sealed/                           # SEALED (Phase 1)
│   ├── comparison_baseline.json
│   ├── checksums_before.txt
│   ├── checksums_after.txt
│   └── SEALED.txt
├── phase1_setup_report.md
├── phase2_implementation_report.md
├── phase2_file_access_report.md
├── phase2_compliance_report.md
├── phase3_comparison_report.md
├── blind_comparison_report.md
├── unbiased_lessons.md
└── orbit_validation_report.md

.orbit/
├── file_access_log.txt                # Phase 2 tracking
├── violations.txt                     # Phase 2 violations (if any)
└── comparison/<TICKET_ID>/            # Phase 3 anonymous workspace
    ├── candidate_A/
    ├── candidate_B/
    └── metadata.json
```

---

## Best Practices

### Do's ✅
- Start fresh session for each phase
- Verify compliance after Phase 2
- Trust the blind comparison process
- Learn from both implementations
- Use unbiased lessons for improvements

### Don'ts ❌
- Don't peek at sealed folders in Phase 2
- Don't continue to next phase in same session
- Don't skip compliance verification
- Don't assume Orbit is always better
- Don't ignore Developer's strengths

---

## Troubleshooting

### "Sealed folders not found"
**Problem**: Phase 1 not completed
**Solution**: Run `/test-mode-setup` first

### "Compliance check failed"
**Problem**: Sealed files accessed in Phase 2
**Solution**: Restart Phase 2 in fresh session

### "Cannot compare - Phase 2 incomplete"
**Problem**: Implementation not finished
**Solution**: Complete Phase 2 first

### "Context leak detected"
**Problem**: Developer PR referenced in Phase 2
**Solution**: Restart Phase 2 (invalid comparison)

---

## Example: CSIQ-13534

```bash
# Session 1 (10:00 AM)
/test-mode-setup CSIQ-13534
# → Captures PR #2724
# → Seals developer_pr/
# → Exits

# Session 2 (10:30 AM - fresh session)
/test-mode-implement CSIQ-13534
# → Implements blind (no PR access)
# → Full Orbit workflow
# → Compliance: ✅ VALID
# → Exits

# Session 3 (2:00 PM - fresh session)
/test-mode-compare CSIQ-13534
# → Unseals PR
# → Compares anonymously
# → Orbit: 90/100, Developer: 54/100
# → Final report generated
```

**Result**: Unbiased comparison showing Orbit superiority with +36 points.

---

## Related

- Skill: `.cursor/skills/test-mode-setup/SKILL.md`
- Skill: `.cursor/skills/test-mode-implement/SKILL.md`
- Skill: `.cursor/skills/test-mode-compare/SKILL.md`
- Config: `.cursor/test-mode/restrictions.md`
- Command: `.cursor/commands/test-mode.md` (old approach - replaced)
