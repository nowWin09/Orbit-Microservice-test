# Project Orbit - Visual Flowcharts

## Main Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROJECT ORBIT WORKFLOW                       │
└─────────────────────────────────────────────────────────────────┘

                          START NEW TASK
                               │
                               ▼
                    ┌──────────────────────┐
                    │   /start TICKET_ID   │
                    │  (45-65 seconds)     │
                    └──────────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
    ┌────────────┐    ┌──────────────┐    ┌─────────────┐
    │   JIRA     │    │ Schema       │    │ RabbitMQ    │
    │ Context    │    │ Analysis     │    │ Trace       │
    │            │    │ (parallel)   │    │ (parallel)  │
    └────────────┘    └──────────────┘    └─────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Discovery Report     │
                    │ (synthesis)          │
                    └──────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  USER APPROVAL ✓     │
                    │  (Approval Gate 1)   │
                    └──────────────────────┘
                               │
                    NO ◄───────┘
                    │
              (Fix & Retry)
              
                               │
                               YES
                               │
                               ▼
                    ┌──────────────────────┐
                    │   /plan              │
                    │  (25-35 seconds)     │
                    └──────────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
    ┌────────────┐    ┌──────────────┐    ┌─────────────┐
    │ TDD        │    │ Risk         │    │ Impl.       │
    │ Planner    │    │ Analyzer     │    │ Planner     │
    │ (parallel) │    │ (parallel)   │    │ (synthesis) │
    └────────────┘    └──────────────┘    └─────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Impl. Plan + TDD     │
                    │ + Risk Assessment    │
                    └──────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  USER APPROVAL ✓     │
                    │  (Approval Gate 2)   │
                    └──────────────────────┘
                               │
                    NO ◄───────┘
                    │
              (Adjust & Retry)
              
                               │
                               YES
                               │
                               ▼
                    ┌──────────────────────┐
                    │  IMPLEMENT CODE      │
                    │  (You code here!)    │
                    └──────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   /finish            │
                    │  (25-35 seconds)     │
                    └──────────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
    ┌────────────┐    ┌──────────────┐    ┌─────────────┐
    │ Code       │    │ Test         │    │ Regression  │
    │ Reviewer   │    │ Validator    │    │ Detector    │
    │ (parallel) │    │ (parallel)   │    │ (sequential)│
    └────────────┘    └──────────────┘    └─────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  ALL PASS? ✓         │
                    │  (Quality Gate)      │
                    └──────────────────────┘
                               │
                    NO ◄───────┘
                    │
              (Fix Issues & Retry)
              
                               │
                               YES
                               │
                               ▼
                    ┌──────────────────────┐
                    │  READY FOR MERGE     │
                    │  (Satellite/Rulebook │
                    │   check optional)    │
                    └──────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  ✅ TASK COMPLETE   │
                    │  (Production Ready)  │
                    └──────────────────────┘
```

---

## Phase 1: Discovery (`/start`)

```
/start CSIQ-12043
│
├─ Step 1: Fetch JIRA Context (INLINE - Main Agent)
│  ├─ Fetch ticket + sub-tasks
│  ├─ Fetch PRD from Google Drive
│  ├─ Extract requirements
│  └─ Parse entities (DB tables), service, RabbitMQ exchange
│
├─ Step 2A: Schema Analysis (PARALLEL - subagent)
│  ├─ Query MariaDB schema for entities
│  ├─ Query MongoDB collections
│  ├─ Identify changes needed
│  └─ Recommend indexes
│
├─ Step 2B: RabbitMQ Flow Analysis (PARALLEL - subagent)
│  ├─ Find producer code
│  ├─ Find consumer code
│  ├─ Compare payload contracts
│  └─ Identify mismatches
│
├─ Step 3: Discovery Synthesis (INLINE - Main Agent)
│  ├─ Combine all inputs
│  ├─ Identify file dependencies
│  ├─ Find existing patterns
│  └─ Create unified report
│
└─ Output: Discovery Report
   └─ Ready for /plan
```

---

## Phase 2: Planning (`/plan`)

```
/plan
│
├─ Step 1: Check Cache
│  └─ Reuse Context/Discovery/Schema/Rabbit reports from /start
│
├─ Step 2A: TDD Blueprint (PARALLEL - subagent)
│  ├─ Design test suite:
│  │  ├─ Unit tests (functions/methods)
│  │  ├─ Integration tests (APIs, consumers)
│  │  ├─ Edge case tests (null, empty, invalid)
│  │  ├─ Error scenario tests (DB failure, timeouts)
│  │  └─ Performance tests (no N+1, pagination)
│  ├─ Verify HIPAA compliance
│  └─ Output: TDD Blueprint (Red phase tests)
│
├─ Step 2B: Risk Assessment (PARALLEL - subagent)
│  ├─ Identify risks:
│  │  ├─ Breaking changes (API, schema, message)
│  │  ├─ Performance risks (indexes, queries)
│  │  ├─ Security risks (auth, data exposure)
│  │  └─ Compliance risks (HIPAA violations)
│  ├─ Rate severity (P0, P1, P2, P3)
│  └─ Output: Risk Assessment Report
│
├─ Step 3: Implementation Planning Skill (INLINE)
│  ├─ Read all 5 cached/new reports
│  ├─ Synthesize 18-aspect plan:
│  │  1. Architecture overview
│  │  2. Database changes
│  │  3. API endpoints
│  │  4. RabbitMQ publishers/consumers
│  │  5. Cache strategy
│  │  6. Security measures
│  │  7. Performance tuning
│  │  8. Monitoring/logging
│  │  9. Error handling
│  │  10. Backward compatibility
│  │  11. Data migration
│  │  12. Rollback strategy
│  │  13. Configuration changes
│  │  14. Dependency updates
│  │  15. Documentation
│  │  16. Deployment steps
│  │  17. Testing strategy
│  │  18. Approval checklist
│  └─ Output: Implementation Plan
│
└─ Outputs:
   ├─ TDD Blueprint (Red phase)
   ├─ Risk Assessment Report
   ├─ Implementation Plan (18 aspects)
   └─ Ready for implementation
```

---

## Phase 3: Delivery (`/finish`)

```
After code implementation → /finish
│
├─ Step 1A: Code Review (PARALLEL - subagent)
│  ├─ Check for N+1 queries
│  ├─ Verify Joi validation (all inputs)
│  ├─ Check HIPAA compliance (no PHI in logs)
│  ├─ Review performance patterns
│  ├─ Verify error handling
│  └─ Output: Code Review Report
│     └─ PASS or FAIL
│
├─ Step 1B: Test Validation (PARALLEL - subagent)
│  ├─ Verify all functions have tests
│  ├─ Check test coverage (target 80%+)
│  ├─ Verify test quality (meaningful assertions)
│  ├─ Compare vs TDD Blueprint
│  └─ Output: Test Validation Report
│     └─ PASS or FAIL
│
├─ Decision Gate: Both PASS?
│  ├─ NO → Fix issues, run /finish again
│  └─ YES → Continue to Step 2
│
├─ Step 2: Regression Detection (SEQUENTIAL - subagent)
│  ├─ Find all dependencies:
│  │  ├─ Direct (function calls, imports)
│  │  ├─ Indirect (DB columns, API fields, messages)
│  │  └─ Cross-service (other services affected)
│  ├─ Assess impact (high/medium/low)
│  ├─ Recommend regression tests
│  └─ Output: Regression Impact Report
│
├─ Step 3: Pattern Detection (INLINE)
│  ├─ Check for 16 new pattern criteria
│  ├─ If pattern detected:
│  │  ├─ Propose rulebook update
│  │  └─ Ask user approval
│  └─ Output: Pattern Analysis (if applicable)
│
└─ Final Outputs:
   ├─ Code Review Report (PASS)
   ├─ Test Validation Report (PASS)
   ├─ Regression Impact Report
   ├─ Pattern Analysis (if applicable)
   └─ ✅ READY FOR MERGE
```

---

## Subagent Dependency Tree

```
/start
├─ JIRA Context Analysis (INLINE)
│  └─ Blocks schema-analyzer & rabbit-tracer
│     ├─ Schema Analyzer (PARALLEL)
│     └─ Rabbit Tracer (PARALLEL)
│
/plan
├─ Cache Check (uses /start outputs)
└─ Parallel:
   ├─ TDD Planner (Reasoning model)
   └─ Risk Analyzer (Reasoning model)
   └─ Implementation Planner (INLINE, uses all reports)

/finish
├─ Parallel:
│  ├─ Code Reviewer (Reasoning model)
│  └─ Test Validator (Reasoning model)
├─ Regression Detector (SEQUENTIAL, after review passes)
└─ Pattern Detection (INLINE, final)
```

---

## Data Flow (How Reports Connect)

```
JIRA Ticket
    │
    ▼
Context Analysis Report
    │
    ├─────────────────────────────┬───────────────────────────┐
    │                             │                           │
    ▼                             ▼                           ▼
Schema Analysis Report      RabbitMQ Flow Report       Discovery Report
    │                             │                           │
    └─────────────────────────────┼───────────────────────────┘
                                  │
                                  ▼
                      Implementation Planning
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
             TDD Blueprint  Risk Assessment  Implementation Plan
                    │             │             │
                    └─────────────┼─────────────┘
                                  │
                                  ▼
                         Code Implementation
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
            Code Review Report Test Validation Regression Report
                    │             │             │
                    └─────────────┼─────────────┘
                                  │
                                  ▼
                        ✅ PRODUCTION READY
```

---

## Approval Gates

```
┌─────────────────────────────────────────────┐
│  APPROVAL GATE 1 (After /start)             │
│                                             │
│  Review Discovery Report:                   │
│  ✓ Requirements understood?                 │
│  ✓ Scope reasonable?                        │
│  ✓ Dependencies identified?                 │
│  ✓ Patterns found and documented?           │
│                                             │
│  Decision: APPROVE → Continue to /plan     │
│  Decision: REVISE → Run /start again        │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  APPROVAL GATE 2 (After /plan)              │
│                                             │
│  Review:                                    │
│  ✓ TDD Blueprint complete?                  │
│  ✓ All test types included?                 │
│  ✓ Risk assessment reasonable?              │
│  ✓ Implementation plan feasible?            │
│  ✓ 18-aspect table comprehensive?           │
│                                             │
│  Decision: APPROVE → Implement code        │
│  Decision: REVISE → Run /plan again         │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  QUALITY GATE (After /finish)               │
│                                             │
│  Automated Checks:                          │
│  ✓ Code Review PASSED?                      │
│  ✓ Test Validation PASSED?                  │
│  ✓ No high-risk regressions?                │
│  ✓ All patterns updated?                    │
│                                             │
│  Result: READY FOR MERGE                    │
│  (No user approval needed - automated)      │
└─────────────────────────────────────────────┘
```

---

## Parallel Execution Strategy

### Why Parallel?

```
SEQUENTIAL (BAD - 90 seconds):
Step 1: JIRA Context ──────────────► 30s
        (waits for completion)
        ▼
Step 2: Schema Analysis ───────────► 15s
        ▼
Step 3: Rabbit Trace ──────────────► 15s
        ▼
Step 4: Discovery ─────────────────► 30s
                      Total: 90s

PARALLEL (GOOD - 65 seconds):
Step 1: JIRA Context ──────────────► 30s
        (blocks steps 2&3 dependency)
        ▼
Steps 2,3: Schema + Rabbit ────────► 15s (BOTH at same time)
        ▼
Step 4: Discovery ─────────────────► 30s
                      Total: 65s
                      Savings: 25s (28% faster)
```

### Key Rules

1. **Identify Dependencies First**
   - Schema-analyzer NEEDS JIRA context (entities)
   - Rabbit-tracer NEEDS JIRA context (service/exchange)
   - Discovery NEEDS schema + rabbit outputs

2. **Group Independent Tasks**
   - Schema + Rabbit are independent → run in parallel
   - TDD Planner + Risk Analyzer are independent → run in parallel

3. **Single Message, Multiple Tasks**
   ```javascript
   // CORRECT (Parallel):
   Task(...schema...), Task(...rabbit...) // Single message
   
   // WRONG (Sequential):
   Task(...schema...) → wait → Task(...rabbit...) // Multiple messages
   ```

---

## MCP Integration Points

```
Orbit Workflow
    │
    ├─ Jira MCP
    │  ├─ Fetch ticket: CSIQ-12043
    │  ├─ Fetch sub-tasks
    │  └─ Search related tickets
    │
    ├─ GDrive MCP
    │  ├─ Fetch PRD from link
    │  └─ Parse requirements
    │
    ├─ MariaDB MCP
    │  ├─ Get schema for users table
    │  ├─ Get indexes
    │  ├─ Check for migration conflicts
    │  └─ Verify constraints
    │
    ├─ MongoDB MCP
    │  ├─ Get schema for documents
    │  ├─ Check existing collections
    │  └─ Verify indexes
    │
    └─ GitHub MCP
       ├─ Push implementation
       ├─ Create PR
       └─ Check CI status

If MCP Down → Use Fallback (manual input, HIGH RISK)
```

---

## Configuration Checklist

```
Before running Orbit, verify:

□ Jira MCP configured and working
  Command: /init → Check status

□ GDrive MCP configured
  Test: Can fetch PRD from link

□ MariaDB MCP configured
  Test: Can query schema

□ MongoDB MCP configured (if using MongoDB)
  Test: Can query collections

□ GitHub MCP configured (optional)
  Test: Can create PR

□ Rules loaded:
  □ db_rules.mdc
  □ microservice_rules.mdc
  □ tech_stack.mdc
  □ cross_service.mdc
  □ business_logic.mdc
  □ mcp_usage.mdc

□ Skills available:
  □ discovery/SKILL.md
  □ jira-context-analysis/SKILL.md
  □ implementation-planning/SKILL.md
  □ tdd-planning/SKILL.md
  □ review/SKILL.md
  □ sentinel/SKILL.md

□ Agents available:
  □ schema-analyzer.md
  □ rabbit-tracer.md
  □ tdd-planner.md
  □ risk-analyzer.md
  □ code-reviewer.md
  □ test-validator.md
  □ regression-detector.md
  □ orbit-validator.md

All checked? → Ready to use Orbit!
```

---

**Last Updated:** February 19, 2026  
**Version:** 1.0  
**Visual Status:** Complete
