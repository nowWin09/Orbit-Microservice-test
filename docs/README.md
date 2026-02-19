# Project Orbit Documentation

**Complete documentation for the Project Orbit AI-driven development framework**

---

## 📚 Documentation Overview

This folder contains comprehensive guides for understanding, configuring, and using **Project Orbit**.

### For Different Audiences

#### 👤 New Users (Just Starting)
**Start here:** `ORBIT_QUICK_START.md`
- 10-minute overview
- Step-by-step first run
- Key concepts
- Troubleshooting basics

#### 🏃 Experienced Users (Know TDD/Testing)
**Start here:** `ORBIT_OVERVIEW.md`
- What is Orbit & why
- 3-phase workflow
- Architecture
- Key concepts
- Configuration overview

#### 🛠️ Setup & Configuration
**Reference:** `ORBIT_CONFIGURATION_GUIDE.md`
- MCP setup (Jira, GDrive, MariaDB, MongoDB, GitHub)
- Rule configuration
- Project structure
- Performance tuning
- Advanced configuration

#### 📋 Commands Reference
**Reference:** `ORBIT_COMMANDS_GUIDE.md`
- All Orbit commands explained
- `/start` - Initialize task
- `/plan` - Create implementation plan
- `/finish` - Verify code quality
- Examples for each command
- Typical workflows

#### 📊 Visual Workflows
**Reference:** `ORBIT_FLOWCHART.md`
- Main workflow diagram
- Phase 1: Discovery
- Phase 2: Planning
- Phase 3: Delivery
- Subagent dependencies
- Data flow diagrams
- MCP integration points

#### 🐛 Troubleshooting
**Reference:** `ORBIT_TROUBLESHOOTING_MATRIX.md`
- 15 issue categories
- Symptoms to solutions
- Root cause analysis
- Responsible files
- Quick reference matrix

---

## 🚀 Quick Navigation

### I want to...

| Goal | Document | Time |
|------|----------|------|
| **Get started quickly** | `ORBIT_QUICK_START.md` | 10 min |
| **Understand what Orbit is** | `ORBIT_OVERVIEW.md` | 20 min |
| **Set up Orbit** | `ORBIT_CONFIGURATION_GUIDE.md` | 30 min |
| **Run a command** | `ORBIT_COMMANDS_GUIDE.md` | 5 min lookup |
| **See how it works visually** | `ORBIT_FLOWCHART.md` | 15 min |
| **Fix a problem** | `ORBIT_TROUBLESHOOTING_MATRIX.md` | 5 min lookup |
| **Report issues** | `ORBIT_TROUBLESHOOTING_MATRIX.md` (bottom) | 5 min |

---

## 📖 Document Descriptions

### ORBIT_QUICK_START.md
**For:** New users, first-time setup  
**Contains:**
- 5-minute overview
- 10-minute first run
- Prerequisites checklist
- Key concepts explained
- Common commands
- 2 example workflows
- Troubleshooting basics
- Pro tips

**Read time:** 5 minutes  
**Action:** Complete 10-minute first run

---

### ORBIT_OVERVIEW.md
**For:** Understanding the framework  
**Contains:**
- What is Project Orbit
- Why Orbit (before vs after)
- 3-phase workflow explained
- Architecture (main agent + subagents)
- MCP integration
- Key concepts deep dive
- File organization
- Workflow commands
- Rules framework
- Best practices
- Glossary

**Read time:** 20 minutes  
**Action:** Understand high-level architecture

---

### ORBIT_CONFIGURATION_GUIDE.md
**For:** Setting up Orbit  
**Contains:**
- Pre-requisites
- Verify Orbit structure
- MCP configuration (5 MCPs)
  - Jira
  - Google Drive
  - MariaDB
  - MongoDB
  - GitHub
- MCP troubleshooting
- Project rules configuration
- Project structure setup
- Caching configuration
- Logging configuration
- Complete setup checklist
- Troubleshooting setup
- Performance tuning
- Advanced configuration

**Read time:** 30 minutes (setup) + 15 min (per MCP)  
**Action:** Configure MCPs and verify setup

---

### ORBIT_COMMANDS_GUIDE.md
**For:** Using Orbit commands  
**Contains:**
- Command summary table
- `/init` - Check MCP status
- `/start` - Initialize task
  - Syntax, examples, workflow, outputs, approval gate, troubleshooting
- `/plan` - Create implementation plan
  - Syntax, examples, workflow, outputs, TDD structure, 18 aspects, approval gate
- `/finish` - Verify code quality
  - Syntax, workflow, outputs, quality gates, checks
- `/explain` - Understand feature
- `/flow` - Show architecture
- `/fix` - Troubleshoot
- Typical workflows (feature + bug fix)
- Tips & tricks

**Read time:** 30 minutes (reference)  
**Action:** Run commands as needed

---

### ORBIT_FLOWCHART.md
**For:** Visual understanding  
**Contains:**
- Main workflow flowchart
- Phase 1: Discovery flowchart
- Phase 2: Planning flowchart
- Phase 3: Delivery flowchart
- Subagent dependency tree
- Data flow diagram
- Approval gates diagram
- Parallel execution strategy
- MCP integration points
- Configuration checklist

**Read time:** 15 minutes  
**Action:** Understand process flow visually

---

### ORBIT_TROUBLESHOOTING_MATRIX.md
**For:** Fixing problems  
**Contains:**
- Quick navigation by symptom
- 15 issue categories:
  1. JIRA Context Issues
  2. Schema Analysis Issues
  3. RabbitMQ Flow Issues
  4. Discovery Issues
  5. TDD Blueprint Issues
  6. Risk Analysis Issues
  7. Code Review Issues
  8. Test Validation Issues
  9. Regression Detection Issues
  10. Parallel Execution Issues
  11. MCP Connection Issues
  12. Caching Issues
  13. Pattern Detection Issues
  14. Performance Issues
  15. Architectural Issues
- File responsibility matrix
- How to report issues
- Living document (updates as issues discovered)

**Read time:** 5 minutes (per issue)  
**Action:** Look up symptom, follow fix

---

## 🔄 Typical Workflow

### First Time Setup (1-2 hours)

```
1. Read ORBIT_QUICK_START.md          (5 min)
2. Run /init                          (5 min)
3. Fix any MCP issues (if needed)    (10-30 min)
   See ORBIT_CONFIGURATION_GUIDE.md
4. Run /start with test ticket      (60 sec)
5. Review outputs                    (5 min)

Result: Orbit is working! ✅
```

### Implementing a Feature (4-6 hours)

```
1. Run /init                         (5 sec)
2. Run /start TICKET_ID             (60 sec)
   See ORBIT_COMMANDS_GUIDE.md
3. Review Discovery Report          (10 min)
4. Approve and proceed
5. Run /plan                         (35 sec)
6. Review TDD Blueprint              (10 min)
7. Approve and proceed
8. Implement per TDD                 (2-4 hours)
   Reference tdd_blueprint.md while coding
9. Run /finish                       (35 sec)
10. Fix any issues                   (10-30 min)
11. Create PR and merge              (10 min)

Result: Production-ready feature! 🎉
```

### Troubleshooting (As needed)

```
1. Identify symptom
2. Open ORBIT_TROUBLESHOOTING_MATRIX.md
3. Find matching issue
4. Follow root cause analysis
5. Apply fix
6. Run /init to refresh status
7. Retry command
```

---

## 📊 File Statistics

```
Total Documentation: ~15,000 lines

Breakdown:
├── ORBIT_QUICK_START.md                   ~800 lines (New users)
├── ORBIT_OVERVIEW.md                      ~650 lines (What is Orbit)
├── ORBIT_COMMANDS_GUIDE.md                ~1200 lines (How to run commands)
├── ORBIT_CONFIGURATION_GUIDE.md           ~850 lines (Setup & config)
├── ORBIT_FLOWCHART.md                     ~700 lines (Visual diagrams)
├── ORBIT_TROUBLESHOOTING_MATRIX.md        ~1100 lines (Troubleshooting)
└── README.md (this file)                  ~400 lines (Navigation)
```

---

## 🎯 Key Concepts at a Glance

| Concept | Meaning | Time | Where |
|---------|---------|------|-------|
| **Discovery Report** | Analysis of requirement | `/start` | OVERVIEW |
| **TDD Blueprint** | Test design (before code) | `/plan` | COMMANDS GUIDE |
| **Implementation Plan** | 18-point roadmap | `/plan` | COMMANDS GUIDE |
| **Code Review** | N+1, validation, HIPAA checks | `/finish` | COMMANDS GUIDE |
| **Regression Detection** | Dependencies at risk | `/finish` | COMMANDS GUIDE |
| **N+1 Query** | Loop with DB queries (bad) | Any | TROUBLESHOOTING |
| **MCP** | Data source connector | Setup | CONFIGURATION |
| **Joi** | Input validation library | Tech Stack | RULES |
| **HIPAA** | Health data compliance | Rules | BUSINESS LOGIC |

---

## 🛠️ Frequently Used References

### Common Issues & Solutions

```
"Cannot fetch Jira"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 1.1

"Schema analysis failed"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 2.2

"Missing consumer not found"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 3.1

"Tests only cover happy path"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 5.1

"N+1 query in code"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 7.1

"Commands too slow"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 14.1

"MCP unavailable"
→ ORBIT_TROUBLESHOOTING_MATRIX.md Issue 11.1
```

### Common Tasks & How-Tos

```
"How do I run /start?"
→ ORBIT_COMMANDS_GUIDE.md - /start section

"What's the TDD Blueprint?"
→ ORBIT_COMMANDS_GUIDE.md - /plan section

"How do I set up MariaDB MCP?"
→ ORBIT_CONFIGURATION_GUIDE.md Step 2.4

"What are the 18 aspects in implementation plan?"
→ ORBIT_COMMANDS_GUIDE.md - /plan section

"What happens in /finish?"
→ ORBIT_COMMANDS_GUIDE.md - /finish section

"Show me a typical workflow"
→ ORBIT_COMMANDS_GUIDE.md - Command Sequencing
```

---

## ✅ Pre-Reading Checklist

Before you start:

- [ ] Node.js 16+ installed: `node --version`
- [ ] Project cloned: `cd project`
- [ ] `.cursor/` folder exists: `ls .cursor/`
- [ ] `docs/` folder exists: `ls docs/`
- [ ] Cursor IDE installed and open
- [ ] Network connectivity verified
- [ ] Jira account access
- [ ] Database access (MariaDB/MongoDB)

**All checked?** → Ready to proceed!

---

## 🚀 Getting Started Recommendation

### Level 1: Quick Overview (10 minutes)
1. Read `ORBIT_QUICK_START.md`
2. Run `/init` to verify setup
3. Skim `ORBIT_OVERVIEW.md`

### Level 2: First Feature (4-6 hours)
1. Re-read relevant sections of `ORBIT_COMMANDS_GUIDE.md`
2. Run `/start` with real ticket
3. Follow workflow through `/finish`
4. Create PR and merge

### Level 3: Advanced Usage (as needed)
1. Deep dive into `ORBIT_CONFIGURATION_GUIDE.md`
2. Reference `ORBIT_FLOWCHART.md` for architecture
3. Use `ORBIT_TROUBLESHOOTING_MATRIX.md` when issues arise

---

## 📞 Support & Feedback

### If you're stuck:

1. **Quick answer (< 1 min):** ORBIT_TROUBLESHOOTING_MATRIX.md
2. **Command reference (< 5 min):** ORBIT_COMMANDS_GUIDE.md
3. **Understanding (5-20 min):** ORBIT_OVERVIEW.md
4. **Setup help (10-30 min):** ORBIT_CONFIGURATION_GUIDE.md

### To report issues:

See `ORBIT_TROUBLESHOOTING_MATRIX.md` - "How to Report Issues" section

### To improve documentation:

Each document is a living guide. Suggestions welcome!

---

## 📅 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 19, 2026 | Initial complete documentation |

---

## 📄 Document Checklist

- [x] ORBIT_QUICK_START.md - Quick 10-minute guide
- [x] ORBIT_OVERVIEW.md - Complete overview
- [x] ORBIT_COMMANDS_GUIDE.md - All commands explained
- [x] ORBIT_CONFIGURATION_GUIDE.md - Setup & MCP config
- [x] ORBIT_FLOWCHART.md - Visual diagrams
- [x] ORBIT_TROUBLESHOOTING_MATRIX.md - Issues & fixes
- [x] README.md - This navigation document

**All documentation complete!** ✅

---

## 🎓 Learning Path

### For a Developer New to Orbit:

```
Day 1 (1-2 hours):
├─ Read ORBIT_QUICK_START.md            (5 min)
├─ Read ORBIT_OVERVIEW.md               (15 min)
├─ Run /init                            (5 min)
└─ Run /start with test ticket         (60 sec)

Day 2 (6-8 hours):
├─ Implement first feature             (4-6 hours)
│  ├─ Run /plan
│  ├─ Write code + tests
│  └─ Run /finish
└─ Reference docs as needed

Day 3+ (as needed):
├─ Implement features faster            (2-4 hours each)
├─ Reference command guide              (1-5 min lookups)
└─ Use troubleshooting guide             (as needed)
```

### For a Tech Lead Setting Up Orbit:

```
Session 1 (2-3 hours):
├─ Read ORBIT_OVERVIEW.md               (15 min)
├─ Read ORBIT_CONFIGURATION_GUIDE.md    (30 min)
├─ Configure MCPs                       (1-2 hours)
└─ Run /init to verify                  (5 min)

Session 2 (1 hour):
├─ Test with team member               (30 min)
├─ Review feedback                      (15 min)
└─ Adjust configuration if needed       (15 min)

Ongoing:
├─ Reference troubleshooting guide     (as issues arise)
└─ Update documentation                (quarterly)
```

---

## 🔗 Related Resources

- **Orbit Source Code:** `.cursor/commands/`, `.cursor/agents/`, `.cursor/skills/`, `.cursor/rules/`
- **Jira Tickets:** Link to your Jira instance
- **Database Access:** MariaDB/MongoDB connection strings
- **Google Drive:** For PRD documents

---

**Last Updated:** February 19, 2026  
**Maintained by:** Project Orbit Team  
**Status:** Active & Growing  
**For:** All developers using Project Orbit
