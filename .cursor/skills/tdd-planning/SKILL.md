---
name: tdd-planning
description: TDD Blueprint: Red (fail) → Green (pass) → Refactor. Use when planning new features or when the user runs /plan.
disable-model-invocation: false
---

# TDD Planning Skill (The Architect)

Test-Driven Development (TDD) is **MANDATORY**. All new functionality must be developed using a strict test-first approach.

## Steps: Red → Green → Refactor

**PREFERRED APPROACH: Delegate to `tdd-planner` subagent**

For comprehensive test-first planning, invoke the `tdd-planner` subagent:

```javascript
Task(
  subagent_type="generalPurpose",
  model="default",  // TDD planning requires reasoning, use default model
  prompt="Read and execute .cursor/agents/tdd-planner.md. Context:
    - Requirements: <from Context Analysis Report>
    - Discovery findings: <from Discovery Report>
    - Schema analysis: <from schema-analyzer output>
    - Service: <service name>
    - Feature: <feature description>
    - Verbosity: full
    
    Generate TDD Blueprint with test suite structure, coverage map, implementation guidance, and refactor checklist.",
  description="Generate TDD Blueprint"
)
```

The subagent will return a **TDD Blueprint** with:
- Complete test suite (unit + integration tests)
- Coverage map (requirements → tests)
- Implementation guidance (Green phase)
- Refactor checklist
- Compliance verification

**MANDATORY: Architecture Checklist (Before Phase 1 – Tests)**

For cross-service, telecom, or workflow features, answer **before** drafting tests:

- **Does this require a new microservice?** (e.g. retry orchestrator, delayed processing) – If yes, blueprint MUST include: service creation, pm2.json entry, Constants.js entry, consumer setup.
- **Does this require a delayed exchange?** (e.g. `produceDelayedMessage` for retry scheduling) – If yes, blueprint MUST include delayed exchange config and producer usage.
- **Does this require CDR format changes?** (e.g. new fields in format-normal-cdr, format-parent-cdr) – If yes, blueprint MUST include CDR format tests and postcall consumer tests.

**Cross-Service Test Matrix:** For CDR-driven features (voicemail, playback, acknowledgment), require tests for:
- postcall consumer (CDR processing, callhistory update)
- CDR format (format-normal-cdr, format-parent-cdr if applicable)
- workflow consumer (if workflow triggers the flow)

**MANDATORY: Verify TDD Blueprint Completeness Before Implementation**

After receiving the TDD Blueprint from the subagent (or creating it manually), validate using this checklist:

### TDD Blueprint Completeness Checklist
- [ ] **Unit tests for all new functions/methods** (each function has at least one test)
- [ ] **Integration tests for API endpoints** (if applicable: request → response flow)
- [ ] **Integration tests for RabbitMQ consumers** (if applicable: message → processing flow)
- [ ] **Edge case tests** (null/empty/invalid inputs, boundary values)
- [ ] **Error scenario tests** (DB failures, network errors, auth failures, external service failures)
- [ ] **HIPAA compliance tests** (if PHI involved: no PHI in logs, access control, audit trail)
- [ ] **Performance tests** (if query or aggregation: verify N+1 prevention, pagination)
- [ ] **Joi validation tests** (all inputs validated: HTTP body/query/params, RabbitMQ payloads)
- [ ] **Test data and fixtures defined** (sample payloads, mocks, DB fixtures)
- [ ] **Coverage map complete** (every requirement maps to at least one test)

**If any item is ❌, the TDD Blueprint is INCOMPLETE. Request the subagent (or manually) to add missing tests before proceeding to implementation.**

Only proceed after **all checklist items are ✅** and user approval is received.

## FALLBACK: Manual TDD Planning (if subagent unavailable)

**If tdd-planner subagent cannot be invoked:**

1. **Ask user for requirements confirmation:**
   - Confirm understanding of feature requirements
   - Clarify any ambiguities
   
2. **State HIGH RISK:** "TDD Blueprint without tdd-planner subagent is HIGH RISK. Cannot ensure comprehensive test coverage or compliance validation."

3. **Basic TDD approach:**
   - Draft tests for happy path only (Red phase)
   - Outline implementation (Green phase)
   - **Cannot ensure:** Edge cases covered, HIPAA compliance tests, performance tests, full coverage map

4. **Apply completeness checklist** (10 items above) manually

5. **Recommend:** Fix subagent availability for comprehensive TDD Blueprint

**Only proceed after explicit user approval** with caveat that Blueprint may be incomplete.
