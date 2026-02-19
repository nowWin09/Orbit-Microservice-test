---
name: review
description: Post-implementation verification. Act as Hostile QA; reject N+1 queries and missing Joi validation. Use when the user runs /finish or asks for a code review.
disable-model-invocation: true
---

# Review Skill (The Gatekeeper)

After the code is generated, you MUST verify the implementation using **two parallel subagents** with a Hostile QA mindset.

## PREFERRED APPROACH: Delegate to subagents

**CRITICAL: Launch both subagents in PARALLEL** (single message, two Task calls) for comprehensive review:

**CORRECT (Parallel execution):**
```javascript
[
  Task(
    subagent_type="generalPurpose",
    model="default",  // Code review requires reasoning
    prompt="Read and execute .cursor/agents/code-reviewer.md. Context:
      - Changed files: <list of files>
      - Implementation summary: <brief description>
      - Schema analyzer output: <path to report>
      - Verbosity: full
      
      Review for: N+1 queries, missing Joi validation, HIPAA compliance, performance issues, pattern adherence.",
    description="Review code quality"
  ),
  Task(
    subagent_type="generalPurpose",
    model="default",  // Test validation requires reasoning
    prompt="Read and execute .cursor/agents/test-validator.md. Context:
      - Changed files: <list of files>
      - TDD Blueprint: <path to blueprint>
      - Test execution output: <Jest/Mocha output if available>
      - Verbosity: full
      
      Verify test existence, execution, quality, and coverage.",
    description="Validate test coverage"
  )
]
```

**INCORRECT (Sequential - DO NOT DO THIS):**
```javascript
Task(...code-reviewer...) → [wait] → Task(...test-validator...)
```

**Performance Impact:** Parallel execution reduces review time by ~50%. Sequential invocation is a **performance failure**.

**Wait for both reports.** Only **PASS** implementation if:
- `code-reviewer` returns **PASS** (all checks passed)
- `test-validator` returns **PASS** (adequate coverage)

If either returns **FAIL**, reject implementation and require fixes before proceeding.

---

## FALLBACK: Manual Review (if subagents unavailable)

**If code-reviewer or test-validator cannot be invoked:**

1. **Ask user for manual verification:**
   - List of changed files
   - Test execution output
   
2. **State HIGH RISK:** "Code review without subagents is HIGH RISK. Cannot systematically verify N+1 queries, Joi validation, HIPAA compliance, or test quality."

3. **Basic checks only:**
   - Manually scan for obvious N+1 patterns (loops with queries)
   - Check if controllers have Joi schemas
   - Verify test files exist for new code
   - **Cannot verify:** Comprehensive pattern adherence, full test quality assessment

4. **Recommend:** Fix subagent availability for complete review

### Quick Rejection Criteria (Manual Check)
- ❌ **REJECT** if N+1 queries found (loops with DB calls)
- ❌ **REJECT** if missing Joi validation in controllers/consumers
- ❌ **REJECT** if no tests for new functions
