---
name: test-mode
description: Orbit Quality Validation | Workflow: Fetch PR → Revert → Re-implement → Compare | Use: Test Orbit on existing features | Model: Mixed (Opus for comparison)
disable-model-invocation: true
---

# Test Mode Skill (Orbit Quality Validation)

This skill orchestrates the full `/test-mode` workflow to validate Orbit's quality by re-implementing existing features and comparing against developer PRs.

**Invocation:** `/test-mode CSIQ-12345`

---

## Workflow Overview

```
User: /test-mode CSIQ-12345
  ↓
1. Fetch Original PR (Jira MCP → GitHub MCP)
  ↓
2. Create Test Branch (test/orbit-validation-CSIQ-12345)
  ↓
3. Revert Feature (remove existing implementation)
  ↓
4. Run Full Orbit Workflow
   ├─ /start (Discovery Phase)
   ├─ User confirms
   ├─ /plan (Planning Phase)
   ├─ User confirms
   ├─ Implementation (Code generation)
   └─ /finish (Review Phase)
  ↓
5. Compare Orbit vs Developer PR (orbit-validator subagent)
  ↓
6. Generate Quality Report (5 metrics)
```

---

## Steps

### Step 1: Fetch Original PR

**Try Jira MCP first:**

```javascript
// Get ticket from Jira
const ticket = await jiraMcp.getIssue(ticketId, {
  fields: 'summary,description,comment'
});

// Extract GitHub PR links from description/comments
const githubLinkRegex = /https:\/\/github\.com\/[\w-]+\/[\w-]+\/pull\/(\d+)/g;
const prLinks = [];

// Search description
const descMatches = ticket.description?.matchAll(githubLinkRegex);
for (const match of descMatches) {
  prLinks.push({ url: match[0], number: parseInt(match[1]) });
}

// Search comments
ticket.comments?.forEach(comment => {
  const commentMatches = comment.body.matchAll(githubLinkRegex);
  for (const match of commentMatches) {
    prLinks.push({ url: match[0], number: parseInt(match[1]) });
  }
});

if (prLinks.length === 0) {
  // Ask user for PR link
  console.log(`❓ No PR found in Jira ticket ${ticketId}.`);
  const prUrl = await askUser("Please provide GitHub PR URL:");
  // Parse PR URL...
}
```

**Fetch PR from GitHub:**

```javascript
// Extract owner, repo, prNumber from URL
const { owner, repo, prNumber } = parsePrUrl(prUrl);

// Get PR metadata
const pr = await githubMcp.getPullRequest(owner, repo, prNumber);

// Get PR diff
const prDiff = await githubMcp.getPullRequestDiff(owner, repo, prNumber);

// Get PR files
const prFiles = await githubMcp.getPullRequestFiles(owner, repo, prNumber);

// Save to docs/<TICKET_ID>/developer_pr/
await saveDeveloperPr(ticketId, { metadata: pr, diff: prDiff, files: prFiles });
```

**Output:**
- `docs/<TICKET_ID>/developer_pr/pr_metadata.json`
- `docs/<TICKET_ID>/developer_pr/pr_diff.patch`
- `docs/<TICKET_ID>/developer_pr/pr_files/...`

---

### Step 2: Create Test Branch

```bash
# Check current branch
current_branch=$(git branch --show-current)

# Ensure working directory is clean
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ Working directory not clean. Commit or stash changes first."
  exit 1
fi

# Create test branch from main
git checkout -b test/orbit-validation-${TICKET_ID} main

echo "✅ Created test branch: test/orbit-validation-${TICKET_ID}"
```

**Output:** New branch created and checked out

---

### Step 3: Revert Feature

**Option A: Revert merge commit**
```bash
# Find PR merge commit
merge_commit=$(git log --oneline --grep="Merge pull request #${PR_NUMBER}" -1 --format="%H")

if [[ -n "$merge_commit" ]]; then
  git revert $merge_commit --no-commit
  git commit -m "test: Revert ${TICKET_ID} for Orbit validation"
else
  echo "⚠️  Merge commit not found. Manual revert required."
fi
```

**Option B: Revert individual commits**
```bash
# Get all commits from PR
pr_commits=$(git log --oneline --grep="${TICKET_ID}" --format="%H" | tac)

# Revert each commit
for commit in $pr_commits; do
  git revert $commit --no-commit
done

git commit -m "test: Revert ${TICKET_ID} for Orbit validation"
```

**Confirm revert:**
```bash
# Ask user to confirm
echo "Feature reverted. Current state:"
git diff main --stat

read -p "Proceed with Orbit re-implementation? (y/n) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborting test mode."
  git checkout $current_branch
  git branch -D test/orbit-validation-${TICKET_ID}
  exit 1
fi
```

---

### Step 4: Run Full Orbit Workflow

**4a. Discovery Phase (/start)**

```javascript
// Launch jira-context-analyzer skill
await runSkill('jira-context-analysis', { ticketId });

// Launch schema-analyzer subagent
const schemaTask = Task({
  subagent_type: "schema-analyzer",
  model: "fast",
  prompt: `Analyze database schema for ${ticketId}. Generate schema report.`,
  description: "Analyze DB schema"
});

// Launch rabbit-tracer subagent (if RabbitMQ involved)
const rabbitTask = Task({
  subagent_type: "rabbit-tracer",
  model: "fast",
  prompt: `Trace RabbitMQ message flows for ${ticketId}.`,
  description: "Trace RabbitMQ flows"
});

// Wait for completion
await Promise.all([schemaTask, rabbitTask]);

// Generate Discovery Report
await runSkill('discovery', { ticketId });

// Output: docs/<TICKET_ID>/context_analysis_report.md
//         docs/<TICKET_ID>/discovery_report.md
```

**Pause for user confirmation:**
```javascript
const confirmDiscovery = await askUser(
  "Discovery complete. Review reports:\n" +
  `- docs/${ticketId}/context_analysis_report.md\n` +
  `- docs/${ticketId}/discovery_report.md\n\n` +
  "Proceed to planning? (y/n)"
);

if (confirmDiscovery !== 'y') {
  console.log("Aborting at user request.");
  return;
}
```

---

**4b. Planning Phase (/plan)**

```javascript
// Phase 2A: Launch TDD and Risk in parallel
const tddTask = Task({
  subagent_type: "tdd-planner",
  model: "claude-opus-4.5",  // Deep reasoning
  prompt: `Read Discovery Report for ${ticketId}. Generate TDD Blueprint.`,
  description: "Generate TDD Blueprint"
});

const riskTask = Task({
  subagent_type: "risk-analyzer",
  model: "claude-opus-4.5",  // Deep reasoning
  prompt: `Read Discovery Report for ${ticketId}. Generate Risk Analysis.`,
  description: "Generate Risk Analysis"
});

// Wait for Phase 2A completion
await Promise.all([tddTask, riskTask]);

// Output: docs/<TICKET_ID>/tdd_blueprint.md
//         docs/<TICKET_ID>/risk_assessment.md

// Phase 2B: Launch Implementation Planner (sequential)
const implPlanTask = Task({
  subagent_type: "implementation-planner",
  model: "claude-opus-4.5",  // Most important - Opus 4.5
  prompt: `Read Discovery, TDD, and Risk reports for ${ticketId}. Generate 18-aspect Implementation Plan.`,
  description: "Generate Implementation Plan"
});

await implPlanTask;

// Output: docs/<TICKET_ID>/implementation_plan.md
```

**Pause for user confirmation:**
```javascript
const confirmPlanning = await askUser(
  "Planning complete. Review reports:\n" +
  `- docs/${ticketId}/tdd_blueprint.md\n` +
  `- docs/${ticketId}/risk_assessment.md\n` +
  `- docs/${ticketId}/implementation_plan.md\n\n` +
  "Proceed to implementation? (y/n)"
);

if (confirmPlanning !== 'y') {
  console.log("Aborting at user request.");
  return;
}
```

---

**4c. Implementation Phase**

```javascript
// Read Implementation Plan
const implPlan = await readFile(`docs/${ticketId}/implementation_plan.md`);

// Use Sonnet 4.5 (code-specialized) for implementation
// This is the main agent's work, not a subagent
console.log("Implementing feature based on Implementation Plan...");
console.log("Model: Claude Sonnet 4.5 (code-specialized)");

// Agent implements code changes...
// (This is done by the main agent, not via Tool calls)
```

**Implementation is done by the main agent:**
- Reads Implementation Plan
- Creates/modifies files
- Writes tests (based on TDD Blueprint)
- Follows patterns (from Discovery Report)

**Output:**
- Code changes committed to test branch
- Test files created

---

**4d. Review Phase (/finish)**

```javascript
// Launch code-reviewer subagent
const reviewTask = Task({
  subagent_type: "code-reviewer",
  model: "claude-opus-4.5",  // Hostile QA needs Opus
  prompt: `Review code changes for ${ticketId}. Check N+1, Joi, HIPAA, performance, patterns.`,
  description: "Review code changes"
});

// Launch test-validator subagent
const testTask = Task({
  subagent_type: "test-validator",
  model: "claude-sonnet-4.5",  // Balanced
  prompt: `Validate tests for ${ticketId}. Check coverage, execution, quality.`,
  description: "Validate tests"
});

// Launch in parallel
await Promise.all([reviewTask, testTask]);

// Output: docs/<TICKET_ID>/orbit_generated/code_review_report.md
//         docs/<TICKET_ID>/orbit_generated/test_validation_report.md

// Optionally launch regression-detector
const regressionTask = Task({
  subagent_type: "regression-detector",
  model: "claude-sonnet-4.5",
  prompt: `Check for regression risks in ${ticketId} changes.`,
  description: "Detect regressions"
});

await regressionTask;

// Output: docs/<TICKET_ID>/orbit_generated/regression_report.md
```

---

### Step 5: Comparison Analysis

**Launch orbit-validator subagent:**

```javascript
const validatorTask = Task({
  subagent_type: "generalPurpose",  // orbit-validator not in built-in list yet
  model: "claude-opus-4.5",  // Deep comparison needs Opus
  prompt: `
Read and execute .cursor/agents/orbit-validator.md.

Context:
- Ticket: ${ticketId}
- Developer PR: docs/${ticketId}/developer_pr/
- Orbit code: git diff main..test/orbit-validation-${ticketId}
- Orbit reports: docs/${ticketId}/

Compare across 5 metrics:
1. Code Quality (complexity, duplication, patterns, error handling)
2. Test Coverage (line %, branch %, edge cases, error tests, E2E)
3. Performance (N+1 queries, indexes, caching, batching, pagination)
4. Security (Joi validation, HIPAA, auth, SQL injection, rate limiting)
5. Architecture (deployment, rollback, error handling, cross-service, docs)

Generate quality comparison report with scores.

Output to: docs/${ticketId}/orbit_validation_report.md
`,
  description: "Compare Orbit vs Developer PR"
});

await validatorTask;

console.log(`✅ Validation report generated: docs/${ticketId}/orbit_validation_report.md`);
```

**The subagent will:**
1. Read developer PR files
2. Read Orbit code changes (git diff)
3. Analyze 5 metrics
4. Score each metric (0-100)
5. Generate comparison report

---

### Step 6: Present Results

```javascript
// Read validation report
const report = await readFile(`docs/${ticketId}/orbit_validation_report.md`);

// Extract summary
const summaryRegex = /## Executive Summary([\s\S]*?)---/;
const summary = report.match(summaryRegex)[1];

console.log("\n" + "=".repeat(80));
console.log(`ORBIT VALIDATION REPORT - ${ticketId}`);
console.log("=".repeat(80) + "\n");
console.log(summary);
console.log("\n" + "=".repeat(80));
console.log(`Full report: docs/${ticketId}/orbit_validation_report.md`);
console.log("=".repeat(80) + "\n");

// Ask if user wants to keep test branch
const keepBranch = await askUser("Keep test branch for manual review? (y/n)");

if (keepBranch !== 'y') {
  // Checkout original branch and delete test branch
  await shell(`git checkout ${currentBranch}`);
  await shell(`git branch -D test/orbit-validation-${ticketId}`);
  console.log(`✅ Deleted test branch: test/orbit-validation-${ticketId}`);
} else {
  console.log(`✅ Test branch preserved: test/orbit-validation-${ticketId}`);
}
```

---

## Configuration

Configuration is in `.cursor/orbit-config.yaml`:

```yaml
test_mode:
  enabled: true
  test_branch_prefix: "test/orbit-validation-"
  base_branch: "main"
  comparison_model: "deep-reasoning"  # Opus 4.5
  metrics:
    - code_quality
    - test_coverage
    - performance
    - security
    - architecture
  pr_fetch:
    try_jira_mcp_first: true
    ask_user_if_not_found: true
  safety:
    require_clean_working_directory: true
    confirm_feature_revert: true
```

---

## Safety Checks

**Before starting:**
- ✅ Working directory is clean (no uncommitted changes)
- ✅ Git repository initialized
- ✅ Jira MCP configured
- ✅ GitHub MCP configured

**During execution:**
- ✅ Confirm feature revert before proceeding
- ✅ Confirm after Discovery phase
- ✅ Confirm after Planning phase

**After execution:**
- ✅ Test branch isolated (never merged to main)
- ✅ Original branch preserved
- ✅ Production code untouched

---

## Batch Testing

Test multiple tickets:

```bash
/test-mode CSIQ-12345 CSIQ-12346 CSIQ-12347
```

Will run validation on all 3 tickets sequentially and generate aggregate report.

---

## Cleanup

```bash
# Delete test branch
git branch -D test/orbit-validation-CSIQ-12345

# Delete validation reports (optional)
rm -rf docs/CSIQ-12345/
```

---

## See Also

- Test mode command: `.cursor/commands/test-mode.md`
- Validator subagent: `.cursor/agents/orbit-validator.md`
- Quality metrics: `docs/ORBIT_QUALITY_METRICS.md`
- Configuration: `.cursor/orbit-config.yaml` → `test_mode`

---

**Estimated Time:** 20-30 minutes (full Orbit workflow + comparison)  
**Estimated Cost:** ~$6.25 (includes all Orbit phases + Opus comparison)
