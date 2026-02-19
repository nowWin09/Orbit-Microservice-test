# Orbit Template Repository

**A reusable Orbit framework template for microservice projects**

---

## What is This?

This is a **clean, standalone Orbit template repository** that can be cloned into any microservice project. It contains:

- ✅ `.cursor/` folder - All Orbit commands, agents, skills, and rules
- ✅ `docs/` folder - Complete user documentation
- ✅ `.gitignore` - Proper exclusions
- ✅ This README

**No project-specific code** - Just the framework and documentation.

---

## Quick Start

### 1. Clone Into Your Microservice Repo

```bash
# In your microservice project root
git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit-template

# Copy into your project
cp -r orbit-template/.cursor .cursor
cp -r orbit-template/docs docs

# Remove temporary folder
rm -rf orbit-template

# Verify
ls .cursor/          # Should show: commands/, agents/, skills/, rules/
ls docs/             # Should show: ORBIT_*.md, README.md
```

### 2. Verify Installation

```bash
# Check Orbit is there
/init
```

**Expected output:**
```
MCP Status:
✅ Jira      - OK
✅ GDrive    - OK
✅ MariaDB   - OK
✅ MongoDB   - OK
✅ GitHub    - OK

Session: READY
```

### 3. Start Using Orbit

```bash
/start implement <feature> for <TICKET_ID>
```

---

## Repository Structure

```
Orbit-Microservice-test/
├── .cursor/
│   ├── commands/              ← Orbit workflow commands
│   │   ├── start.md
│   │   ├── plan.md
│   │   ├── finish.md
│   │   ├── init.md
│   │   ├── explain.md
│   │   ├── flow.md
│   │   ├── fix.md
│   │   └── test-mode.md
│   ├── agents/                ← Subagent definitions
│   │   ├── schema-analyzer.md
│   │   ├── rabbit-tracer.md
│   │   ├── tdd-planner.md
│   │   ├── risk-analyzer.md
│   │   ├── code-reviewer.md
│   │   ├── test-validator.md
│   │   ├── regression-detector.md
│   │   ├── orbit-validator.md
│   │   ├── implementation-planner.md
│   │   └── README.md
│   ├── skills/                ← AI skills
│   │   ├── discovery/SKILL.md
│   │   ├── jira-context-analysis/SKILL.md
│   │   ├── implementation-planning/SKILL.md
│   │   ├── tdd-planning/SKILL.md
│   │   ├── review/SKILL.md
│   │   ├── sentinel/SKILL.md
│   │   └── model-selection/SKILL.md
│   └── rules/                 ← Project rules
│       ├── db_rules.mdc
│       ├── microservice_rules.mdc
│       ├── tech_stack.mdc
│       ├── cross_service.mdc
│       ├── business_logic.mdc
│       ├── mcp_usage.mdc
│       ├── agent_directives.mdc
│       ├── reasoning.mdc
│       └── troubleshooting.mdc
├── docs/
│   ├── README.md                       ← Navigation hub
│   ├── ORBIT_QUICK_START.md           ← 10-minute guide
│   ├── ORBIT_OVERVIEW.md              ← Complete overview
│   ├── ORBIT_COMMANDS_GUIDE.md        ← Command reference
│   ├── ORBIT_CONFIGURATION_GUIDE.md   ← Setup guide
│   ├── ORBIT_FLOWCHART.md             ← Visual workflows
│   ├── ORBIT_TROUBLESHOOTING_MATRIX.md ← Troubleshooting
│   ├── ORBIT_QUICK_REFERENCE.md       ← Reference card
│   └── DELIVERY_SUMMARY.md            ← What's included
├── .gitignore
└── README.md (this file)
```

---

## How to Use This Template

### For Yourself (In Your Current Project)

1. **Copy to your project:**
   ```bash
   cp -r .cursor your/project/root/
   cp -r docs your/project/root/
   ```

2. **Add to git:**
   ```bash
   git add .cursor/
   git add docs/
   git commit -m "Add Orbit framework"
   ```

3. **Start using:**
   ```bash
   /init
   /start implement <feature> for <TICKET>
   ```

### For Your Team (Share This Repo)

1. **Tell team members:**
   > "Clone this repo into your microservice project to add Orbit"

2. **They do:**
   ```bash
   git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit-template
   cp -r orbit-template/.cursor .
   cp -r orbit-template/docs .
   rm -rf orbit-template
   ```

3. **They verify:**
   ```bash
   /init
   ```

### For Version Control

**In Your Microservice Repo:**

```bash
# Add Orbit files
git add .cursor/
git add docs/

# Commit
git commit -m "Add: Project Orbit framework

- Includes all Orbit commands, agents, skills, rules
- Includes complete user documentation
- Ready for feature implementation via Orbit"

# Push
git push
```

---

## What Each Folder Contains

### `.cursor/commands/`
**Orbit workflow commands** - Each file is a command you can run:

- `/init` - Check MCP status
- `/start` - Discover & analyze requirement
- `/plan` - Design tests & implementation
- `/finish` - Verify code quality
- `/explain` - Understand feature
- `/flow` - Show architecture
- `/fix` - Troubleshoot

### `.cursor/agents/`
**Specialized subagents** - Each handles one task:

- `schema-analyzer` - DB schema analysis
- `rabbit-tracer` - RabbitMQ message flows
- `tdd-planner` - Test design (TDD)
- `risk-analyzer` - Risk assessment
- `code-reviewer` - Code quality
- `test-validator` - Test coverage
- `regression-detector` - Impact analysis
- `orbit-validator` - Quality assurance
- `implementation-planner` - 18-point roadmap

### `.cursor/skills/`
**Reusable AI skills** - Procedures agents follow:

- `discovery/SKILL.md` - Dependency tracing
- `jira-context-analysis/SKILL.md` - JIRA parsing
- `implementation-planning/SKILL.md` - Plan synthesis
- `tdd-planning/SKILL.md` - Test design
- `review/SKILL.md` - Code & test review
- `sentinel/SKILL.md` - Pattern detection

### `.cursor/rules/`
**Project coding standards** - Applied automatically:

- `db_rules.mdc` - Database best practices
- `microservice_rules.mdc` - Service architecture
- `tech_stack.mdc` - Tech requirements
- `cross_service.mdc` - RabbitMQ/APIs
- `business_logic.mdc` - Domain logic
- `mcp_usage.mdc` - MCP usage
- And more...

### `docs/`
**Complete user documentation** - 8 files for different audiences:

- `README.md` - Navigation hub
- `ORBIT_QUICK_START.md` - 10-minute guide for new users
- `ORBIT_OVERVIEW.md` - Complete architecture overview
- `ORBIT_COMMANDS_GUIDE.md` - How to run each command
- `ORBIT_CONFIGURATION_GUIDE.md` - Setup & MCP configuration
- `ORBIT_FLOWCHART.md` - Visual workflows
- `ORBIT_TROUBLESHOOTING_MATRIX.md` - Issue troubleshooting
- `ORBIT_QUICK_REFERENCE.md` - Print-friendly reference card

---

## For New Developers

**First time in any project using Orbit?**

1. Read: `docs/ORBIT_QUICK_START.md` (10 minutes)
2. Run: `/init` (verify setup)
3. Follow: Your first feature workflow
4. Reference: `docs/ORBIT_QUICK_REFERENCE.md` (daily use)

---

## Customization

### Adding Project-Specific Rules

Each microservice may have project-specific rules. Customize:

```
.cursor/rules/
├── [Global rules - don't modify]
├── [Shared rules - may customize]
└── your-project-rule.mdc  ← Add your custom rules here
```

### Adding Project Documentation

Add project-specific docs in the docs folder:

```
docs/
├── [Orbit framework docs - don't modify]
└── YOUR-PROJECT-SETUP.md  ← Your project setup
```

---

## Troubleshooting

### Command Not Found: `/start`

**Fix:**
1. Verify `.cursor/commands/start.md` exists
2. Restart Cursor
3. Run `/init` to refresh

### MCP Status Shows Errors

**Fix:**
1. See `docs/ORBIT_CONFIGURATION_GUIDE.md`
2. Configure your MCPs (Jira, database, etc.)
3. Run `/init` again

### Something Else Broken?

1. Check `docs/ORBIT_TROUBLESHOOTING_MATRIX.md`
2. Search for your issue
3. Follow the fix steps

---

## Version Control Best Practices

### Committing Orbit Files

```bash
# Add Orbit framework
git add .cursor/
git add docs/

# Commit with clear message
git commit -m "Add: Project Orbit framework

- .cursor/commands/ - Workflow commands
- .cursor/agents/ - AI subagents
- .cursor/skills/ - AI procedures
- .cursor/rules/ - Project rules
- docs/ - User documentation

Team can now use /start, /plan, /finish for features"
```

### Updating Orbit

If Orbit is updated in the template repo:

```bash
# Clone latest template
git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit-latest

# Copy updated files
cp -r orbit-latest/.cursor .
cp -r orbit-latest/docs .

# Commit update
git commit -m "Update: Project Orbit framework to latest version"

# Cleanup
rm -rf orbit-latest
```

### Team Workflow

```bash
# Team member clones project
git clone <your-microservice-repo>

# They have .cursor/ and docs/ folders
# They can immediately use Orbit

/init
/start implement feature for TICKET
```

---

## What NOT to Do

❌ Don't modify `.cursor/rules/` core rules  
❌ Don't delete `.cursor/agents/` files  
❌ Don't remove `docs/` documentation  
❌ Don't commit reports to `.cursor/reports/`  
❌ Don't commit `.env` files with this template  

✅ DO customize rules for your project  
✅ DO add project-specific documentation  
✅ DO update Orbit when templates change  
✅ DO share with team via git  

---

## Sharing With Your Team

### Step 1: Push This Repo

This repo (Orbit-Microservice-test) is already set up. Team members can clone it.

### Step 2: Team Clones Into Their Project

```bash
# They do this in their microservice repo
git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit
cp -r orbit/.cursor .
cp -r orbit/docs .
rm -rf orbit
git add .cursor/ docs/
git commit -m "Add Orbit framework"
git push
```

### Step 3: Team Uses Orbit

```bash
/init
/start implement feature for CSIQ-12345
```

---

## Repository Updates

### When Template Updates

1. Pull latest from template repo
2. Copy updated `.cursor/` and `docs/` 
3. Commit update in your project
4. Team pulls update

### Version Tracking

All projects get latest Orbit automatically when they:
1. Clone this template
2. Or manually update their `.cursor/` and `docs/`

---

## Support

**Team has questions?**
- Point to: `docs/README.md` (navigation hub)
- For quick start: `docs/ORBIT_QUICK_START.md`
- For commands: `docs/ORBIT_COMMANDS_GUIDE.md`
- For issues: `docs/ORBIT_TROUBLESHOOTING_MATRIX.md`

---

## What's Included

✅ 7 workflow commands (`/start`, `/plan`, `/finish`, etc.)  
✅ 8 specialized subagents  
✅ 6 reusable AI skills  
✅ 9 project rule files  
✅ 8 comprehensive documentation files  
✅ 15 troubleshooting categories  
✅ 50+ examples & patterns  
✅ Print-friendly reference card  

**Total:** ~9,500 lines of framework + documentation

---

## Getting Started Immediately

```bash
# 1. Clone template
git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit

# 2. Copy to your project
cp -r orbit/.cursor .
cp -r orbit/docs .
rm -rf orbit

# 3. Verify setup
/init

# 4. Start using
/start implement your-feature for YOUR-TICKET

# 5. Read docs
docs/ORBIT_QUICK_START.md
```

---

**Ready to transform your microservice development!** 🚀

For questions: See `docs/README.md`  
For quick start: See `docs/ORBIT_QUICK_START.md`  
For commands: See `docs/ORBIT_COMMANDS_GUIDE.md`
