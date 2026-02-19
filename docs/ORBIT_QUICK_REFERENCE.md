# Orbit Quick Reference Card

**Print this or keep it handy!**

---

## 🚀 The 3-Phase Workflow

```
Phase 1: DISCOVER          Phase 2: PLAN             Phase 3: DELIVER
/start TICKET_ID    →      /plan                →    /finish
(45-65 sec)                (25-35 sec)                (25-35 sec)
     ↓                          ↓                          ↓
Understand                  Design Tests            Verify Quality
Requirements            & Implementation            & Catch Bugs
     ↓                          ↓                          ↓
Discovery Report       Implementation Plan      Code Review Report
   (APPROVE)          + TDD Blueprint + Risk   + Test Validation
                      Assessment (APPROVE)     + Regression Report
```

---

## 🎯 Command Quick Reference

### /init (5-10 seconds)
**What:** Check if system is ready  
**Command:** `/init`  
**Checks:** Jira, GDrive, MariaDB, MongoDB, GitHub MCPs  
**Output:** Status for each MCP  
**When:** First, each session

### /start (45-65 seconds)
**What:** Analyze requirement & dependencies  
**Command:** `/start <description> for <TICKET_ID>`  
**Example:** `/start implement auth for CSIQ-12043`  
**Outputs:** Discovery Report + optional Schema & RabbitMQ analysis  
**Gate:** ✓ Approve discovery report

### /plan (25-35 seconds)
**What:** Design tests & implementation roadmap  
**Command:** `/plan`  
**Requires:** `/start` completed  
**Outputs:** TDD Blueprint + Risk Assessment + Implementation Plan  
**Gate:** ✓ Approve plan  
**Contains:** 18-aspect implementation roadmap

### /finish (25-35 seconds)
**What:** Verify code quality & catch bugs  
**Command:** `/finish`  
**Requires:** Code implemented  
**Outputs:** Code Review + Test Validation + Regression Report  
**Checks:** N+1 queries, validation, tests, regressions  
**Gate:** ⚠️ Automatic (no approval needed)

---

## 📊 What Gets Checked

### Code Review (/finish)
- ✅ No N+1 queries (batch operations, not loops)
- ✅ Joi validation for ALL inputs
- ✅ No PHI in logs (HIPAA compliance)
- ✅ Error handling present
- ✅ Follows project patterns
- ✅ No security vulnerabilities

### Test Validation (/finish)
- ✅ Tests exist for all new functions
- ✅ Coverage ≥ 80%
- ✅ Tests execute successfully
- ✅ Assertions are meaningful (not just .toBeDefined())
- ✅ Edge cases covered
- ✅ Error scenarios covered

### Regression Detection (/finish)
- ✅ Find all code dependencies
- ✅ Assess risk (high/medium/low)
- ✅ Recommend regression tests

---

## 📁 File Organization

```
/docs
├── README.md                          ← START HERE
├── ORBIT_QUICK_START.md               ← First read (10 min)
├── ORBIT_OVERVIEW.md                  ← Deep understanding (20 min)
├── ORBIT_COMMANDS_GUIDE.md            ← How to run each command
├── ORBIT_FLOWCHART.md                 ← Visual diagrams
├── ORBIT_CONFIGURATION_GUIDE.md       ← Setup & MCP config
├── ORBIT_TROUBLESHOOTING_MATRIX.md    ← Fix problems
└── CSIQ-12043/                        ← Reports per ticket
    ├── discovery_report.md
    ├── tdd_blueprint.md
    ├── implementation_plan.md
    ├── code_review_report.md
    ├── test_validation_report.md
    └── regression_impact_report.md
```

---

## 🔍 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Cannot fetch JIRA" | Run `/init` → Check Jira MCP status |
| "N+1 query found" | Use batch: `db.find({id: {$in: ids}})` not loop |
| "Test coverage too low" | Add missing tests, verify coverage ≥ 80% |
| "High-risk regressions" | Add recommended regression tests |
| "Commands too slow" | Check `/init` status, verify DB responsive |
| "Schema analysis failed" | Check MariaDB MCP working: `/init` |
| "MCP timeout error" | Increase timeout, verify credentials |

---

## ✅ Implementation Checklist

```
Before coding:
☐ Run /init (verify ready)
☐ Run /start TICKET_ID (analyze requirement)
☐ Approve Discovery Report
☐ Run /plan (design TDD)
☐ Approve TDD Blueprint & Implementation Plan

While coding:
☐ Write tests FIRST (Red phase, per TDD Blueprint)
☐ Write minimal code to pass (Green phase)
☐ Reference tdd_blueprint.md while coding
☐ Use Joi for validation: Joi.object({...}).validateAsync(payload)
☐ Batch DB queries: not loops with await

Before submitting:
☐ Run tests locally
☐ Run /finish (verify quality)
☐ Fix any code review issues
☐ Fix any test validation issues
☐ Fix any regression issues
☐ Create PR & merge

Done:
☐ Feature shipped! 🎉
```

---

## 🏃 Typical Timelines

### Feature Implementation (Total ~5 hours)
```
/init                           5 sec
/start                         60 sec
Review + Approve              10 min
/plan                          35 sec
Review + Approve              10 min
─────────────────────────────
Subtotal                       ~31 min

Code Implementation        2-4 hours
Test Writing              30-60 min
Local Testing             15-30 min
─────────────────────────────
Subtotal                  3-5 hours

/finish                        35 sec
Fix Issues (if any)        10-30 min
Create PR                  10 min
─────────────────────────────
Subtotal                   20-40 min

Total Time: 4-6 hours
```

### Bug Fix (Total ~1 hour)
```
/init                           5 sec
/start                         60 sec
Analyze                        5 min

Implement Fix              10-30 min
Write Test                 5-15 min
─────────────────────────────

/finish                        35 sec
Fix Issues                 5-10 min
Create PR                  5 min
─────────────────────────────
Total Time: 30-90 minutes
```

---

## 🔑 Key Commands

```bash
# Check if ready
/init

# Start new feature
/start implement <description> for <TICKET_ID>

# Plan implementation
/plan

# Implement code (you do this)
# Write tests first per tdd_blueprint.md

# Verify quality
/finish

# Understand feature
/explain how <feature> works

# Show architecture
/flow for <service>

# Troubleshoot
/fix <problem>
```

---

## 📖 Documentation Map

| Question | Answer In |
|----------|-----------|
| What is Orbit? | ORBIT_OVERVIEW.md |
| How do I start? | ORBIT_QUICK_START.md |
| How do I run /start? | ORBIT_COMMANDS_GUIDE.md |
| How do I run /plan? | ORBIT_COMMANDS_GUIDE.md |
| How do I run /finish? | ORBIT_COMMANDS_GUIDE.md |
| Show me visually | ORBIT_FLOWCHART.md |
| How do I set up MCPs? | ORBIT_CONFIGURATION_GUIDE.md |
| Something's broken | ORBIT_TROUBLESHOOTING_MATRIX.md |
| Where do I find docs? | README.md |

---

## 💡 Pro Tips

1. **Reuse reports**: Don't delete `docs/CSIQ-12043/` after `/start`
2. **Cache speeds things up**: `/plan` reuses cached reports (~40s savings)
3. **TDD first**: Tests designed before implementation
4. **Batch queries**: Not loops - use `db.find({id: {$in: ids}})`
5. **Reference TDD while coding**: Keep tdd_blueprint.md open
6. **Run /finish early**: Don't wait until everything done
7. **Fix issues immediately**: Don't ignore code review feedback
8. **Trust the process**: Orbit catches bugs that human review misses

---

## ❌ Common Mistakes

- ❌ Skipping `/start` or `/plan`
- ❌ Writing code before TDD Blueprint is approved
- ❌ Ignoring code review feedback
- ❌ N+1 queries (loops with DB calls)
- ❌ Missing Joi validation
- ❌ Logging PHI (personal health info)
- ❌ Not running `/finish` before PR
- ❌ Deleting `docs/TICKET_ID/` folder

---

## ✨ What Orbit Guarantees

✅ 100% test coverage (tests written first)  
✅ Zero breaking changes (regression detection)  
✅ No N+1 queries (code review enforcement)  
✅ All inputs validated (Joi requirement)  
✅ HIPAA compliance verified  
✅ Consistent patterns (rulebook)  
✅ Production-ready code  

---

## 🎯 Success Indicators

You're using Orbit successfully when:
- ✅ Features pass `/finish` on first try
- ✅ Zero production bugs from your code
- ✅ Regressions caught before deployment
- ✅ Tests run faster (parallel execution)
- ✅ Code reviews take < 5 minutes
- ✅ Team asks fewer "why" questions
- ✅ Onboarding time reduced by 50%

---

## 📞 Need Help?

```
Quick question?
→ Use ORBIT_COMMANDS_GUIDE.md (Ctrl+F search)

Understanding Orbit?
→ Read ORBIT_OVERVIEW.md

Setting up MCPs?
→ See ORBIT_CONFIGURATION_GUIDE.md

Something broken?
→ Check ORBIT_TROUBLESHOOTING_MATRIX.md

Need visuals?
→ See ORBIT_FLOWCHART.md

Just starting?
→ Read ORBIT_QUICK_START.md

Lost?
→ Go to README.md (navigation hub)
```

---

## 📅 Typical Week

```
Monday:      Run /init (verify ready for week)
Tuesday:     /start ticket, /plan, implement feature
Wednesday:   Continue implementation, run /finish
Thursday:    Fix any issues, create PR, merge
Friday:      Another feature /start to /finish

Every day:   Reference guides as needed
```

---

## 🎓 Learning

**Day 1:** Read ORBIT_QUICK_START.md (10 min)
**Day 2:** Read ORBIT_OVERVIEW.md (20 min)
**Day 3:** Implement first feature with Orbit (4-6 hours)
**Day 4:** Implement second feature (faster)
**Day 5+:** Expert - reference docs as needed

---

## 📊 File Locations (Relative to Project Root)

```
.cursor/
├── commands/        ← Orbit workflow commands
├── agents/          ← AI subagents
├── skills/          ← AI skills
└── rules/           ← Project rules

docs/
├── README.md        ← Start here
├── ORBIT_*.md       ← All guides
└── CSIQ-*/          ← Per-ticket reports
```

---

**Print or bookmark this card!**

**Last Updated:** February 19, 2026  
**Version:** 1.0  
**Format:** Quick Reference (2-3 page print)
