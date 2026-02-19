---
name: test-mode-setup
description: Phase 1 of Test Mode - Capture and seal developer PR for unbiased comparison. This agent analyzes the developer's PR, saves it, and exits WITHOUT implementing anything.
---

# Test Mode Setup (Phase 1)

**Purpose**: Capture the developer's PR and seal it to prevent context leak during Orbit implementation.

**Critical**: This agent must EXIT after capturing the PR. Do NOT proceed to implementation.

---

## Workflow

### Step 1: Fetch Jira Ticket

1. Get ticket ID from user (e.g., `CSIQ-13534`)
2. Use Jira MCP to fetch ticket details:
   ```javascript
   user-Jira-MCP-Server-jira_get_issue(ticket_id)
   ```
3. Extract:
   - Summary
   - Description
   - Comments (look for GitHub PR link)

### Step 2: Extract GitHub PR Link

From Jira comments, find GitHub PR URL:
- Pattern: `https://github.com/[ORG]/[REPO]/pull/[NUMBER]`
- Example: `https://github.com/CS-IQ/CSIQ-Microservice/pull/2724`

### Step 3: Fetch PR Data

Use GitHub CLI (`gh`) to fetch:
```bash
gh pr view [PR_NUMBER] --json number,title,author,state,mergedAt,additions,deletions,files,commits,reviews
```

Save to: `docs/{TICKET_ID}/developer_pr/pr_metadata.json`

### Step 4: Fetch PR Diff

```bash
gh pr diff [PR_NUMBER] > docs/{TICKET_ID}/developer_pr/pr_diff.patch
```

### Step 5: Analyze Developer Implementation

Create: `docs/{TICKET_ID}/developer_pr/analysis.md`

**Contents**:
- Files changed (list)
- Key changes per file
- New services created
- Configuration updates
- Dependencies added
- Test coverage (if any)
- Documentation (if any)

### Step 6: Generate Comparison Baseline

Create: `docs/{TICKET_ID}/.sealed/comparison_baseline.json`

```json
{
  "ticket_id": "CSIQ-XXXXX",
  "developer_pr": {
    "number": 2724,
    "author": "username",
    "files_changed": 6,
    "lines_added": 388,
    "lines_deleted": 14,
    "has_tests": false,
    "has_docs": true,
    "commits": 4,
    "review_comments": 5
  },
  "sealed_at": "2026-02-16T10:00:00Z",
  "phase_1_complete": true
}
```

### Step 7: Generate Checksums

```bash
# Create checksums of all developer PR files
find docs/{TICKET_ID}/developer_pr -type f -exec sha256sum {} \; > docs/{TICKET_ID}/.sealed/checksums_before.txt
```

### Step 8: Create Seal Marker

Create: `docs/{TICKET_ID}/.sealed/SEALED.txt`

```
This folder contains the developer's original implementation.

ACCESS RESTRICTED during Phase 2 (Orbit Implementation).

Phase: SEALED
Sealed At: 2026-02-16T10:00:00Z
Ticket: CSIQ-XXXXX
Developer PR: #2724

Do NOT read these files during Orbit implementation.
Violation will invalidate the test mode comparison.
```

### Step 9: Generate Phase 1 Report

Create: `docs/{TICKET_ID}/phase1_setup_report.md`

**Contents**:
```markdown
# Test Mode Phase 1: Setup Complete

**Ticket**: CSIQ-XXXXX
**Developer PR**: #2724
**Sealed At**: 2026-02-16T10:00:00Z

## Developer PR Captured

- Files: 6 changed (+388, -14)
- Tests: None
- Documentation: Basic README
- Commits: 4
- Reviews: 5 comments

## Sealed Folders

The following folders are OFF LIMITS for Phase 2:
- `docs/CSIQ-XXXXX/developer_pr/`
- `docs/CSIQ-XXXXX/.sealed/`

## Next Steps

1. START NEW SESSION (to clear context)
2. Run: `/test-mode-implement CSIQ-XXXXX`
3. DO NOT access sealed folders
4. Implement based on Jira ticket ONLY

## Verification

After Phase 2, verify:
- No reads to sealed folders
- Checksums unchanged
- Context clean (no developer PR references)
```

### Step 10: EXIT

**STOP HERE**. Do NOT proceed to implementation.

User must start a NEW SESSION for Phase 2.

---

## Output Files

```
docs/{TICKET_ID}/
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

---

## Command Usage

```bash
# User runs:
/test-mode-setup CSIQ-13534

# Agent:
# 1. Fetches Jira + GitHub PR
# 2. Captures and seals developer PR
# 3. Generates baseline
# 4. Creates checksums
# 5. Reports completion
# 6. EXITS (does not implement)
```

---

## Critical Rules

1. ✅ DO: Capture developer PR thoroughly
2. ✅ DO: Seal the folder with checksums
3. ✅ DO: Generate baseline metrics
4. ✅ DO: Exit after setup
5. ❌ DON'T: Start implementation
6. ❌ DON'T: Generate Orbit reports yet
7. ❌ DON'T: Continue to Phase 2

---

## Success Criteria

- [ ] Jira ticket fetched
- [ ] GitHub PR captured
- [ ] Developer analysis complete
- [ ] Baseline generated
- [ ] Checksums created
- [ ] Seal marker created
- [ ] Phase 1 report generated
- [ ] Agent EXITS (session ends)
