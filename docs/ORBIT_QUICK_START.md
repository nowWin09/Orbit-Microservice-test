# Project Orbit - Quick Start Guide

**Get up and running with Orbit in 10 minutes**

---

## 5-Minute Overview

**What is Orbit?** An AI-powered development workflow that ensures zero defects through:
- ✅ Test-first development (TDD)
- ✅ Risk assessment before implementation
- ✅ Automated code review (N+1 queries, security, compliance)
- ✅ Regression detection
- ✅ Pattern learning

**3-Phase Workflow:**
1. **Discover** (`/start`) - Understand requirement
2. **Plan** (`/plan`) - Design tests & implementation
3. **Deliver** (`/finish`) - Verify code quality

---

## Prerequisites

- [ ] Cursor IDE installed
- [ ] Node.js 16+
- [ ] Project cloned locally
- [ ] Jira account access
- [ ] Database access (MariaDB/MongoDB)

---

## First Run - 10 Minutes

### Step 1: Check System (1 min)

```bash
/init
```

**Expected:**
```
MCP Status:
✅ Jira      - OK
✅ GDrive    - OK
✅ MariaDB   - OK
✅ MongoDB   - OK
✅ GitHub    - OK

Session: READY
```

**If any ❌:** See [Troubleshooting](#troubleshooting) section.

### Step 2: Pick a Jira Ticket (1 min)

Find a ticket for a feature you want to implement. Examples:
- `CSIQ-12043` - User authentication
- `CSIQ-15000` - Voicemail storage
- `CSIQ-14999` - Fix N+1 query bug

### Step 3: Start Discovery (2-3 min)

```bash
/start implement user authentication for CSIQ-12043
```

**What happens:**
- Orbit fetches ticket from Jira
- Analyzes database schemas
- Traces RabbitMQ flows
- Creates Discovery Report

**Output:**
```
📊 Discovery Report Generated
   docs/CSIQ-12043/discovery_report.md

Ready to plan implementation?
```

### Step 4: Review & Approve (2 min)

Open `docs/CSIQ-12043/discovery_report.md`

**Checklist:**
- [ ] Requirements understood?
- [ ] Scope reasonable?
- [ ] All dependencies listed?
- [ ] Existing patterns documented?

**If YES:** Continue to Step 5

**If NO:** Provide feedback and run `/start` again

### Step 5: Create Implementation Plan (2-3 min)

```bash
/plan
```

**What happens:**
- Orbit designs test suite (TDD Blueprint)
- Assesses risks
- Creates 18-point implementation plan

**Outputs:**
- `tdd_blueprint.md` - Tests to write
- `risk_assessment_report.md` - Risks identified
- `implementation_plan.md` - How to code it

**Review Checklist:**
- [ ] TDD Blueprint includes all test types?
- [ ] Risk assessment complete?
- [ ] 18-aspect plan makes sense?

**If YES:** You're ready to code!

---

## Implementation Phase (Your Part)

### Write Tests First (Per TDD)

```typescript
// tests/auth.service.test.ts

describe('Authentication Service', () => {
  // RED PHASE: Tests that fail initially
  
  describe('User Registration', () => {
    it('should create user with hashed password', async () => {
      const user = await authService.register({
        email: 'user@example.com',
        password: 'SecurePass123!'
      });
      expect(user.id).toBeDefined();
      expect(user.password).not.toBe('SecurePass123!');
    });

    it('should reject duplicate email', async () => {
      await authService.register({...});
      const result = await authService.register({...});
      expect(result).toThrow('Email already exists');
    });

    // More tests per TDD Blueprint
  });
});
```

### Then Implement (Green Phase)

```typescript
// src/services/auth.service.ts

export class AuthService {
  async register(payload: RegisterPayload) {
    // Validate input
    await Joi.object({
      email: Joi.string().email().required(),
      password: Joi.string().min(8).required()
    }).validateAsync(payload);

    // Check duplicate
    const existing = await User.findOne({ email: payload.email });
    if (existing) throw new Error('Email already exists');

    // Create user
    const hashedPassword = await bcrypt.hash(payload.password, 10);
    const user = await User.create({
      email: payload.email,
      password: hashedPassword
    });

    return user;
  }
}
```

### Follow the TDD Blueprint

Your `tdd_blueprint.md` specifies:
- Unit tests to write
- Integration tests
- Edge case tests
- Performance tests
- Compliance tests

**Don't skip any!** This is your contract with production.

---

## Verification Phase (Orbit's Part)

### Run Orbit Verification

```bash
/finish
```

**What Orbit checks:**
- ✅ Code quality (N+1 queries, validation, HIPAA)
- ✅ Test quality (coverage, meaningful assertions)
- ✅ Regressions (dependent code at risk)

**Output:**
```
✅ Code Review: PASSED
✅ Test Validation: PASSED
✅ Regression Detection: 2 dependencies found, 0 high-risk

🎉 READY FOR MERGE
```

**If any ❌:**
- Fix the issue
- Re-run `/finish`
- Repeat until all pass

---

## Key Concepts to Remember

### Discovery Report
**What:** Analysis of your feature  
**When:** After `/start`  
**Contains:** What's needed, where, why, and dependencies

### TDD Blueprint
**What:** Test design (before implementation)  
**When:** After `/plan`  
**Contains:** Unit + integration + edge case + error + performance tests

### Implementation Plan
**What:** 18-point roadmap for implementation  
**When:** After `/plan`  
**Contains:** Architecture, DB changes, APIs, RabbitMQ, deployment, rollback

### Code Review Report
**What:** Quality checks on your code  
**When:** After `/finish`  
**Checks:** N+1 queries, Joi validation, HIPAA compliance, patterns

### Test Validation Report
**What:** Quality checks on your tests  
**When:** After `/finish`  
**Checks:** Test existence, coverage (80%+), assertion quality

### Regression Report
**What:** Code dependencies that might break  
**When:** After `/finish`  
**Contains:** Direct/indirect dependencies, risk level, recommended tests

---

## Common Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `/init` | Check system status | `/init` |
| `/start` | Analyze requirement | `/start implement auth for CSIQ-12043` |
| `/plan` | Design implementation | `/plan` |
| `/finish` | Verify code quality | `/finish` |
| `/explain` | Understand feature | `/explain how auth works` |
| `/flow` | Show architecture | `/flow for CSIQ-12043` |
| `/fix` | Troubleshoot | `/fix commands taking too long` |

---

## Workflow Examples

### Example 1: Implement New Feature

```
You:     /init                                    (5s)
Orbit:   ✅ All systems ready

You:     /start implement user auth for CSIQ-12043 (60s)
Orbit:   📊 Discovery Report ready

You:     Review & approve discovery report       (5m)

You:     /plan                                   (35s)
Orbit:   📋 TDD Blueprint + Risk Assessment ready

You:     Review & approve plan                   (5m)

You:     Write code + tests (per TDD)           (2-4h)

You:     /finish                                 (35s)
Orbit:   ✅ Code Review: PASSED
Orbit:   ✅ Test Validation: PASSED
Orbit:   ✅ Regression: 0 high-risk

You:     Create PR & merge                      (10m)

Done! 🎉
```

### Example 2: Quick Bug Fix

```
You:     /init                                    (5s)

You:     /start fix N+1 query in list endpoint CSIQ-14999 (60s)
Orbit:   📊 Discovery Report ready

You:     Approve discovery                       (2m)

You:     Implement fix + test                   (30m)

You:     /finish                                 (35s)
Orbit:   ✅ All checks passed

You:     Merge                                   (5m)

Done! 🎉
```

---

## Troubleshooting

### Issue: /init shows MCP errors

**Problem:** One or more MCPs not responding

**Fix:**
1. Check network connectivity
2. Verify credentials in `.cursor/settings.json`
3. Restart MCP server
4. See `ORBIT_CONFIGURATION_GUIDE.md` for detailed MCP setup

### Issue: /start takes too long

**Problem:** Taking >2 minutes instead of ~65 seconds

**Fix:**
1. Check MCP response times: `/init`
2. Verify database is responsive
3. Check network latency to Jira
4. See `ORBIT_TROUBLESHOOTING_MATRIX.md` issue 14.1

### Issue: Code review fails - N+1 query found

**Problem:** Orbit detected loop with DB queries

**Fix:**
```typescript
// BAD (N+1 query):
for (const userId of userIds) {
  const user = await User.findById(userId);
}

// GOOD (Batch query):
const users = await User.find({ id: { $in: userIds } });
```

### Issue: Test validation fails - coverage too low

**Problem:** Tests don't cover 80% of code

**Fix:**
1. Add missing test cases
2. Verify tests execute (not just defined)
3. Check assertions are meaningful (not just `.toBeDefined()`)
4. Re-run `/finish`

### Issue: Regression detection finds high-risk dependencies

**Problem:** Your change might break dependent code

**Fix:**
1. Review regression report
2. Add recommended regression tests
3. Test against dependent services
4. Verify no breaking changes
5. Re-run `/finish`

---

## Pro Tips

### 1. Reuse Reports
After `/start`, don't delete `docs/CSIQ-12043/`. When you run `/plan`, it reuses reports (saves ~40s).

### 2. Parallel Coding
If you have multiple tickets, run them in parallel:
```bash
# Terminal 1
/start ticket-1

# Terminal 2 (while terminal 1 is running)
/start ticket-2
```

### 3. Reference TDD Blueprint While Coding
Open `tdd_blueprint.md` alongside your code. It's your spec for what to implement.

### 4. Run `/finish` Incrementally
After writing some tests and code, run `/finish` to get feedback early. Don't wait until everything is done.

### 5. Use Caching
Always run `/init` at session start. MCPs are cached, so all commands run faster.

---

## What's Next?

1. **✅ First Run:** Complete the 10-minute setup above
2. **📖 Deep Dive:** Read `ORBIT_OVERVIEW.md` for complete understanding
3. **🛠️ Detailed Guides:**
   - `ORBIT_COMMANDS_GUIDE.md` - All commands explained
   - `ORBIT_CONFIGURATION_GUIDE.md` - Setup & configuration
   - `ORBIT_FLOWCHART.md` - Visual workflows
4. **🐛 Troubleshooting:** `ORBIT_TROUBLESHOOTING_MATRIX.md`

---

## Your First Orbit Feature - Checklist

- [ ] Run `/init` and verify all MCPs ready
- [ ] Find Jira ticket (ask team if unsure)
- [ ] Run `/start TICKET_ID` and wait for report
- [ ] Review Discovery Report and approve
- [ ] Run `/plan` and wait for TDD Blueprint
- [ ] Review TDD Blueprint and Implementation Plan, approve
- [ ] Write tests first (per Red phase in TDD)
- [ ] Write minimal code to pass tests (Green phase)
- [ ] Run `/finish` and fix any issues
- [ ] Create PR and merge

**Congratulations!** You've completed your first Orbit feature! 🎉

---

## Questions?

- **How does X work?** → See `ORBIT_OVERVIEW.md`
- **How do I run command Y?** → See `ORBIT_COMMANDS_GUIDE.md`
- **How do I configure Z?** → See `ORBIT_CONFIGURATION_GUIDE.md`
- **Something's broken** → See `ORBIT_TROUBLESHOOTING_MATRIX.md`
- **Show me visually** → See `ORBIT_FLOWCHART.md`

---

**Last Updated:** February 19, 2026  
**For:** New Orbit Users  
**Time to Read:** 5 minutes  
**Time to First Feature:** ~4 hours (including implementation)
