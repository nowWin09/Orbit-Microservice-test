# Project Orbit - Commands Guide

**Quick Reference:** How to run each Orbit command with examples

---

## Command Summary Table

| Command | Purpose | Time | Approval Gate | Prerequisites |
|---------|---------|------|---|---|
| `/init` | Check MCP status | 5-10s | None | None |
| `/start` | Initialize new task | 45-65s | ✓ Approve Discovery | JIRA ticket ID |
| `/plan` | Create implementation plan | 25-35s | ✓ Approve Plan | `/start` completed |
| `/finish` | Complete & verify | 25-35s | None (automated) | Code implemented |
| `/explain` | Understand feature | 10-20s | None | Ticket ID or file |
| `/flow` | Show architecture | 10-15s | None | Ticket ID or service |
| `/fix` | Troubleshoot issues | 10-30s | None | Problem description |

---

## /init - Initialize System

### Purpose
Verify all MCPs are working and cache their status for the session.

### Syntax
```
/init
```

### What It Does
1. Checks Jira MCP connectivity
2. Checks GDrive MCP connectivity
3. Checks MariaDB MCP connectivity
4. Checks MongoDB MCP connectivity
5. Checks GitHub MCP connectivity (optional)
6. **Caches** MCP status (reused by all commands)

### Output
```
MCP Connectivity Status:
┌─────────────┬──────────┐
│ MCP         │ Status   │
├─────────────┼──────────┤
│ Jira        │ ✅ OK    │
│ GDrive      │ ✅ OK    │
│ MariaDB     │ ✅ OK    │
│ MongoDB     │ ✅ OK    │
│ GitHub      │ ✅ OK    │
└─────────────┴──────────┘

Session Status: READY TO PROCEED
```

### If MCP is Down
```
MariaDB MCP: ❌ TIMEOUT (Connection failed)
→ Orbit will use fallback: Ask user for schema manually (HIGH RISK)
→ Run /init again after fixing MariaDB
```

### Best Practice
- Run `/init` at the START of your session
- MCPs are cached, no need to re-check per command
- If any MCP fails, fix it before running `/start`

---

## /start - Begin New Task

### Purpose
Understand requirements, analyze dependencies, create Discovery Report

### Syntax
```
/start <brief description of feature> for <TICKET_ID>
```

### Examples

#### Example 1: Simple Feature
```
/start implement user authentication for CSIQ-12043
```

#### Example 2: Complex Feature
```
/start add voicemail storage with CDR integration for CSIQ-15000
```

#### Example 3: Bug Fix
```
/start fix N+1 query in user list endpoint for CSIQ-14999
```

### What It Does
1. **Fetch JIRA Context** (inline, main agent)
   - Downloads ticket + sub-tasks
   - Fetches PRD from Google Drive
   - Parses requirements
   - Extracts entities (DB tables), service name, RabbitMQ exchange

2. **Parallel Analysis** (two subagents at same time)
   - Schema Analyzer: Queries live DB schema, identifies changes
   - Rabbit Tracer: Traces RabbitMQ producer/consumer, finds mismatches

3. **Discovery Report** (main agent synthesizes)
   - Combines all inputs
   - Identifies dependencies
   - Finds existing patterns

### Outputs
```
docs/
└── CSIQ-12043/
    ├── context_analysis_report.md
    ├── schema_analysis_report.md      (if DB changes)
    ├── message_flow_report.md         (if RabbitMQ involved)
    └── discovery_report.md            ← MAIN OUTPUT
```

### Approval Gate
```
Discovery Report Review Checklist:
□ Requirements clearly understood?
□ Scope reasonable (not too big/small)?
□ All dependencies identified?
□ Existing patterns documented?
□ RabbitMQ flows traced (if applicable)?
□ DB schema changes identified (if applicable)?

Answer YES to all?
└─ Type: /plan
   (to continue to planning phase)

Answer NO to any?
└─ Provide feedback, and run /start again
```

### Troubleshooting

#### "Cannot fetch JIRA ticket"
- Verify ticket ID is correct (e.g., CSIQ-12043 not 12043)
- Check Jira MCP is working: `/init`

#### "Schema analysis failed"
- Check MariaDB MCP is working: `/init`
- Provide schema manually if MCP unavailable

#### "Missing consumer found for exchange"
- This is normal - RabbitMQ may have producer but no consumer yet
- Review report for what needs to be created

### Time Estimate
- **JIRA fetch:** 25-35s
- **Parallel schema + rabbit:** 15-25s
- **Total:** 45-65s

### Best Practice
- NEVER skip `/start` - it builds critical context
- Let it complete fully before asking questions
- If MCP times out, try `/init` to refresh
- Don't run `/plan` until you've approved `/start`

---

## /plan - Create Implementation Plan

### Purpose
Design tests (TDD), assess risks, create 18-point implementation plan

### Syntax
```
/plan
```

### Prerequisites
- `/start` must be completed
- Discovery Report must be approved
- `docs/<TICKET_ID>/` folder exists with cached reports

### What It Does
1. **Check Cache** (reuse reports from /start)
   - Uses: context_analysis_report.md
   - Uses: discovery_report.md
   - Uses: schema_analysis_report.md (if exists)
   - Uses: message_flow_report.md (if exists)

2. **Parallel Planning** (two subagents at same time)
   - **TDD Planner:** Designs test suite (Red → Green → Refactor)
   - **Risk Analyzer:** Identifies breaking changes, performance risks, security issues

3. **Implementation Planning** (main agent synthesizes)
   - Creates 18-aspect technical plan
   - Maps all requirements to implementation
   - Includes rollback strategy, deployment steps, etc.

### Outputs
```
docs/
└── CSIQ-12043/
    ├── tdd_blueprint.md              ← Red phase tests
    ├── risk_assessment_report.md     ← Risks & mitigations
    └── implementation_plan.md        ← 18-aspect plan
```

### The 18 Aspects

```
1. Architecture Overview
   - Service diagram
   - Components affected
   - Integration points

2. Database Changes
   - New tables/collections
   - Schema changes
   - Migration strategy

3. API Endpoints
   - New routes
   - Changed routes
   - Deprecation plan

4. RabbitMQ Changes
   - New exchanges/queues
   - New consumers/producers
   - Payload schema

5. Cache Strategy
   - What to cache
   - TTL values
   - Invalidation logic

6. Security Measures
   - Authentication/authorization
   - Data encryption
   - HIPAA compliance

7. Performance Tuning
   - Indexes needed
   - Query optimization
   - Caching points

8. Monitoring & Logging
   - Metrics to track
   - Logs to add
   - Alerts to configure

9. Error Handling
   - Error scenarios
   - Recovery strategies
   - Retry logic

10. Backward Compatibility
    - API versioning
    - Schema versioning
    - Migration path

11. Data Migration
    - Migration script
    - Data validation
    - Rollback procedures

12. Rollback Strategy
    - If deployment fails
    - Data recovery
    - Feature flags

13. Configuration Changes
    - .env changes
    - pm2.json changes
    - Feature flags

14. Dependency Updates
    - New npm packages
    - Version upgrades
    - Breaking changes

15. Documentation
    - API docs
    - Architecture docs
    - Runbooks

16. Deployment Steps
    - Pre-deployment
    - Deployment order
    - Post-deployment

17. Testing Strategy
    - Unit test targets
    - Integration test targets
    - E2E test targets

18. Approval Checklist
    - Business approval
    - Security review
    - Performance review
    - Architecture review
```

### TDD Blueprint Structure

```
Red Phase Tests:
├─ Unit Tests
│  ├─ Function 1 tests (happy path + edge cases)
│  ├─ Function 2 tests
│  └─ ...
├─ Integration Tests
│  ├─ API endpoint tests
│  ├─ RabbitMQ consumer tests
│  └─ DB transaction tests
├─ Edge Case Tests
│  ├─ Null/undefined/empty inputs
│  ├─ Boundary values
│  └─ Invalid data types
├─ Error Scenario Tests
│  ├─ DB connection failure
│  ├─ Network timeout
│  ├─ Auth failure
│  └─ External service failure
├─ Performance Tests
│  ├─ No N+1 queries
│  ├─ Batch query verification
│  └─ Response time targets
└─ Compliance Tests
   ├─ Joi validation for all inputs
   └─ HIPAA checks (no PHI in logs)

Green Phase Implementation Guide:
├─ Start with failing tests
├─ Write minimal code to pass tests
├─ Don't over-engineer
└─ Each test → one feature

Refactor Checklist:
├─ Code clarity
├─ Performance
├─ Test coverage
└─ Maintainability
```

### Approval Gate
```
Implementation Plan Review Checklist:
□ TDD Blueprint includes all test types?
□ Coverage map complete (requirements → tests)?
□ Risk assessment identified all major risks?
□ Risk severity ratings reasonable?
□ 18-aspect plan comprehensive?
□ Implementation steps clear and sequenced?
□ Rollback strategy feasible?
□ No P0 (critical) risks without mitigation?

Answer YES to all?
└─ Proceed to CODE IMPLEMENTATION
   (Now you write the code!)

Answer NO to any?
└─ Provide feedback, adjust plan, run /plan again
```

### Troubleshooting

#### "Cache reports not found"
- You must run `/start` first
- Or provide ticket ID: `/plan CSIQ-12043`

#### "TDD Blueprint only has happy path tests"
- This indicates blueprint is incomplete
- Reject it, run `/plan` again
- Use TDD Blueprint Completeness Checklist (in tdd-planning SKILL)

#### "Risk assessment marked as all Green"
- This may be too lenient
- Check if P0 risks identified (breaking changes, HIPAA violations)
- Review risk severity criteria

### Time Estimate
- **Cache check:** 2-5s
- **TDD Planner:** 12-18s
- **Risk Analyzer:** 10-15s
- **Implementation Planning:** 5-10s
- **Total:** 25-35s

### Best Practice
- Don't skip or modify the TDD Blueprint
- Tests must be written FIRST (Red phase)
- Implementation only after tests are designed
- Wait for both approval gates before coding

---

## /finish - Complete & Verify

### Purpose
Review code quality, validate tests, detect regressions

### Syntax
```
/finish
```

### Prerequisites
- `/plan` must be completed and approved
- Code must be implemented
- All tests must be written and passing locally

### What It Does
1. **Parallel Code & Test Review** (two subagents at same time)
   - **Code Reviewer:** Checks N+1 queries, Joi validation, HIPAA, patterns
   - **Test Validator:** Verifies tests exist, execute, have meaningful assertions

2. **Decision Gate** (automatic)
   - If BOTH PASS → Continue to Step 2
   - If EITHER FAILS → STOP, fix issues, run `/finish` again

3. **Regression Detection** (sequential, after review passes)
   - Finds all code dependencies (direct + indirect)
   - Assesses risk per dependency
   - Recommends regression tests

4. **Pattern Detection** (final check)
   - Looks for new architectural patterns
   - If found, proposes rulebook update

### Outputs
```
docs/
└── CSIQ-12043/
    ├── code_review_report.md         ← PASS or FAIL
    ├── test_validation_report.md     ← PASS or FAIL
    └── regression_impact_report.md   ← Dependencies & risks
```

### Quality Gate - Code Review Checks

```
PASS if ALL of these:
✅ No N+1 queries (verified with sampling)
✅ All inputs validated with Joi
✅ No PHI in logs/console output
✅ Error handling present
✅ Async operations properly handled
✅ No SQL injection vulnerabilities
✅ Follows project patterns
✅ No dead code
✅ Meaningful variable names
✅ Comments for non-obvious logic

FAIL if ANY of these:
❌ N+1 query pattern found
❌ Missing Joi validation
❌ PHI exposed in logs
❌ Missing try/catch
❌ Uncaught promises
❌ Security vulnerability
❌ Pattern violation
❌ Typos in identifiers
❌ Missing comments where needed
❌ Temporary/commented code left behind
```

### Quality Gate - Test Validation Checks

```
PASS if ALL of these:
✅ Tests written for all new functions
✅ Test coverage ≥ 80%
✅ Tests execute successfully
✅ Assertions are meaningful (not just .toBeDefined())
✅ Edge cases covered
✅ Error scenarios covered
✅ Performance tests included
✅ Tests compare against TDD Blueprint
✅ Mock data/fixtures defined
✅ Test data cleaned up after each test

FAIL if ANY of these:
❌ Functions with no tests
❌ Coverage < 80%
❌ Tests don't execute
❌ Weak assertions (.toBeTruthy())
❌ Only happy path tests
❌ No error scenario tests
❌ Missing performance tests
❌ Tests don't match blueprint
❌ No mock data defined
❌ Test data not cleaned up
```

### Regression Detection

```
For each file changed:
├─ Direct Dependencies
│  ├─ Functions that call this
│  ├─ Modules that import this
│  └─ Services that depend on this
├─ Indirect Dependencies
│  ├─ DB columns affected
│  ├─ API response fields
│  ├─ Message payload fields
│  └─ Constants/enums
└─ Cross-Service Dependencies
   ├─ Other services calling this
   ├─ RabbitMQ consumers
   └─ External integrations

Risk Assessment:
├─ No impact: Optional feature added
├─ Low: Backward compatible, no breaking change
├─ Medium: Deprecated field, new required param, DB migration
└─ High: Removed required field, type change, breaking API

Recommendations:
├─ Test all high-risk dependencies
├─ Add regression tests for medium-risk
└─ Add E2E tests if cross-service affected
```

### Troubleshooting

#### "Code review failed - N+1 query found"
- Fix the N+1 query (use batch operations, not loops)
- Verify code matches TDD Blueprint performance tests
- Re-run `/finish`

#### "Test validation failed - coverage < 80%"
- Add missing tests for uncovered functions
- Re-run tests locally to verify coverage
- Re-run `/finish`

#### "High-risk regression detected"
- Add recommended regression tests
- Test against dependent code
- Verify no breaking changes introduced
- Re-run `/finish`

### Time Estimate
- **Code Review:** 8-12s
- **Test Validation:** 8-12s
- **Regression Detection:** 10-15s
- **Total:** 25-35s

### Best Practice
- Run tests locally before `/finish`
- Fix ALL code review issues before next attempt
- Don't ignore regression warnings
- If pattern detected, review and approve rulebook update

### Success Criteria

```
Final Output:
┌────────────────────────────────────┐
│ ✅ Code Review: PASSED             │
├────────────────────────────────────┤
│ ✅ Test Validation: PASSED         │
├────────────────────────────────────┤
│ ✅ Regression Detection: Complete  │
│   - 3 dependencies identified      │
│   - 0 high-risk regressions        │
├────────────────────────────────────┤
│ ✅ READY FOR MERGE                 │
└────────────────────────────────────┘

→ Create PR and merge!
```

---

## /explain - Understand Feature

### Purpose
Get detailed explanation of how a feature works

### Syntax
```
/explain how <feature> works
/explain flow in <file>
```

### Examples
```
/explain how user authentication works
/explain flow in src/controllers/auth.controller.ts
/explain RabbitMQ flow for CSIQ-12043
```

### Output
- Architecture diagram
- Data flow explanation
- Key functions/services involved
- Related test coverage

---

## /flow - Show Architecture

### Purpose
Visualize service architecture and message flows

### Syntax
```
/flow for <service or TICKET_ID>
/flow show RabbitMQ
```

### Examples
```
/flow for CSIQ-12043
/flow show RabbitMQ
/flow for auth-service
```

### Output
- Service diagram
- Message flow visualization
- Data store connections
- External integrations

---

## /fix - Troubleshoot Issues

### Purpose
Diagnose and fix common problems

### Syntax
```
/fix <problem description>
```

### Examples
```
/fix commands taking too long
/fix MCP connection errors
/fix tests failing to run
```

### Output
- Root cause analysis
- Step-by-step fixes
- Verification commands

---

## Command Sequencing (Typical Workflow)

### Scenario: Implement New Feature

```
Day 1:
1. Run /init                    (5-10s)   → Verify MCPs working
2. Run /start CSIQ-12043        (45-65s)  → Get Discovery Report
3. Review & approve             (varies)  → Ask clarifying questions
4. Run /plan                    (25-35s)  → Get Implementation Plan
5. Review & approve             (varies)  → Decide feasibility

Day 2:
6. Implement code               (2-4h)    → You write the code
7. Write tests (per TDD)        (1-2h)    → Tests match blueprint
8. Verify locally               (10m)     → Run tests, verify pass
9. Run /finish                  (25-35s)  → Get verification
10. Fix any issues              (varies)  → Address review feedback
11. Create PR & merge           (varies)  → Ship to production
```

### Scenario: Bug Fix (Simpler)

```
1. Run /init                    (5-10s)   → Verify MCPs working
2. Run /start CSIQ-14999        (45-65s)  → Analyze bug
3. Approve                      (vary)
4. Implement fix                (10-30m)  → Fix the bug
5. Write test for bug           (5-15m)   → Test the fix
6. Run /finish                  (25-35s)  → Verify no regressions
7. Create PR & merge            (varies)  → Ship fix
```

---

## Tips & Tricks

### Reuse Cached Reports
If you run `/plan` before `/start` is approved, it will reuse cached reports. No re-analysis needed.

### Check Report Status Anytime
```
ls docs/CSIQ-12043/
```
Shows all reports generated so far.

### Reference Reports in Implementation
```
// In your code, refer to section in TDD Blueprint
// See tdd_blueprint.md - Unit Tests - Authentication
```

### Skip to Later Phases (Advanced)
If you already have a Discovery Report from elsewhere, you can `docs/CSIQ-12043/` folder with reports and jump to `/plan`.

### Parallel Commands (Developer Tip)
If you have multiple tickets:
```
Terminal 1: /start CSIQ-12043
Terminal 2: /start CSIQ-12044  (while first is running)
Terminal 3: /finish (for CSIQ-12043, after implementation)
```
MCPs are fast enough for parallel execution.

---

**Last Updated:** February 19, 2026  
**Version:** 1.0  
**Ready for New Users:** Yes
