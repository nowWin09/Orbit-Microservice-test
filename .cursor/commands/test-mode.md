# Test Mode (Orbit Quality Validation)

Test Orbit's quality by re-implementing an **existing feature** and comparing it with the original developer's PR.

---

## Workflow Overview

```
/test-mode CSIQ-12345
  ↓
Fetch PR from Jira MCP (or ask user for link)
  ↓
Create test branch: test/orbit-validation-CSIQ-12345
  ↓
Revert feature (remove existing implementation)
  ↓
Run full Orbit workflow (/start → /plan → implement → /finish)
  ↓
Compare Orbit's code with original PR
  ↓
Generate quality comparison report with 5 metrics
```

**Estimated Time:** ~20-30 minutes (full Orbit workflow + comparison)

---

## Steps

### 1. Fetch Original PR

**Try Jira MCP first:**
```javascript
// Get PR link from Jira ticket
const ticket = await jiraMcp.getIssue(ticketId);
const prLinks = extractGitHubLinks(ticket.description, ticket.comments);

if (prLinks.length > 0) {
  // Found PR in Jira
} else {
  // Ask user for PR link
  console.log("❓ No PR found in Jira. Please provide GitHub PR URL:");
}
```

**Then fetch PR using GitHub MCP:**
```javascript
const prData = await githubMcp.getPullRequest(owner, repo, prNumber);
const prDiff = await githubMcp.getPullRequestDiff(owner, repo, prNumber);
```

**Save original PR:**
- `docs/<TICKET_ID>/developer_pr/pr_metadata.json`
- `docs/<TICKET_ID>/developer_pr/pr_diff.patch`
- `docs/<TICKET_ID>/developer_pr/pr_files/` (extracted files)

---

### 2. Create Test Branch

```bash
# Get current branch
git branch --show-current

# Create test branch from main (or specify base)
git checkout -b test/orbit-validation-<TICKET_ID> main

# Revert the feature (remove all PR changes)
git revert <PR_MERGE_COMMIT> --no-commit
# or
git revert <PR_COMMIT_1> <PR_COMMIT_2> ... --no-commit

# Commit the revert
git commit -m "test: Revert CSIQ-<ID> for Orbit validation test"
```

**Result:** Clean slate with feature removed, ready for Orbit to re-implement.

---

### 3. Run Full Orbit Workflow

**Execute automatically:**

```javascript
// Step 1: /start
await runOrbitCommand('start', { ticketId });
// Generates: Context Analysis, Discovery Report

// Wait for user confirmation
await getUserApproval("Discovery complete. Proceed to planning?");

// Step 2: /plan
await runOrbitCommand('plan', { ticketId });
// Generates: Risk Assessment, TDD Blueprint, Implementation Plan

// Wait for user approval
await getUserApproval("Planning complete. Proceed to implementation?");

// Step 3: Implement
await runOrbitCommand('implement', { ticketId });
// Generates: Code, tests, migrations

// Step 4: /finish
await runOrbitCommand('finish', { ticketId });
// Generates: Code Review Report, Test Validation Report, Regression Report
```

**Orbit's output location:**
- Code changes: committed to `test/orbit-validation-<TICKET_ID>` branch
- Reports: `docs/<TICKET_ID>/orbit_generated/`

---

### 4. Comparison Analysis

**Launch `orbit-validator` subagent:**

```javascript
Task(
  subagent_type="generalPurpose",
  model="claude-opus-4.5",  // Deep comparison needs Opus
  prompt="Read and execute .cursor/agents/orbit-validator.md.
          Context:
            - Original PR: docs/<TICKET_ID>/developer_pr/
            - Orbit code: git diff main..test/orbit-validation-<TICKET_ID>
            - Ticket: <TICKET_ID>
          
          Compare across 5 metrics: Code Quality, Test Coverage, Performance, Security, Architecture.
          Generate quality comparison report with scores.",
  description="Compare Orbit vs Developer PR"
)
```

**Subagent analyzes:**
1. **Code Quality:** Complexity, patterns, error handling
2. **Test Coverage:** Line %, branch %, edge cases
3. **Performance:** N+1 queries, indexes, caching
4. **Security:** Joi validation, HIPAA, auth
5. **Architecture:** Deployment, rollback, documentation

**Output:** `docs/<TICKET_ID>/orbit_validation_report.md`

---

### 5. Present Quality Report

```markdown
# Orbit Validation Report - CSIQ-12345

## Executive Summary
- **Orbit Score:** 450/500 (90%)
- **Developer Score:** 385/500 (77%)
- **Winner:** Orbit (+65 points)

## Detailed Comparison
(5 metrics with specific findings)

## Recommendations
- Areas where Orbit excelled
- Areas where Developer excelled
- Lessons learned for Orbit improvement
```

---

## Configuration

### Enable Test Mode

Add to `.cursor/orbit-config.yaml`:

```yaml
test_mode:
  enabled: true
  test_branch_prefix: "test/orbit-validation-"
  save_pr_to: "docs/{ticket_id}/developer_pr/"
  save_orbit_to: "test branch commits"
  comparison_model: "deep-reasoning"  # Opus 4.5 for comparison
  metrics:
    - code_quality
    - test_coverage
    - performance
    - security
    - architecture
```

---

## Usage

```bash
# Test Orbit on existing feature
/test-mode CSIQ-12345

# Agent will:
# 1. Fetch PR from Jira (or ask for link)
# 2. Create test branch
# 3. Revert feature
# 4. Run /start (you confirm after discovery)
# 5. Run /plan (you confirm after planning)
# 6. Implement code
# 7. Run /finish
# 8. Compare with original PR
# 9. Generate quality report
```

---

## Safety

**Test branches are isolated:**
- Prefix: `test/orbit-validation-*`
- Never merged to main
- Can be deleted after validation
- Production code untouched

**Cleanup:**
```bash
# After validation, delete test branch
git branch -D test/orbit-validation-CSIQ-12345
```

---

## Batch Testing

Test multiple features:

```bash
/test-mode CSIQ-12345 CSIQ-12346 CSIQ-12347

# Runs validation on all 3 tickets
# Generates aggregate quality report
```

---

## Prerequisites

- [x] Jira MCP configured (for fetching tickets)
- [x] GitHub MCP configured (for fetching PRs)
- [x] Git repository initialized
- [x] Clean working directory (no uncommitted changes)

---

## See Also

- Validator subagent: `.cursor/agents/orbit-validator.md`
- Test mode config: `.cursor/orbit-config.yaml` → `test_mode`
- Quality metrics: `docs/ORBIT_QUALITY_METRICS.md`
