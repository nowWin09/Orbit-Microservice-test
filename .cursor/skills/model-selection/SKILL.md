---
name: model-selection
description: Select optimal AI model for each Orbit stage based on task complexity and active profile. Reads orbit-config.yaml and returns model parameter for Task tool.
disable-model-invocation: false
---

# Model Selection Skill

This skill reads `orbit-config.yaml` and determines which AI model to use for each Orbit stage.

---

## ⚠️ CRITICAL LIMITATION

**The Task tool only accepts `"fast"` as a valid model parameter value.**

This means:
- ✅ `fast` tier → Pass `model="fast"` to Task tool
- ❌ `deep-reasoning`, `balanced`, `code-specialized` → **Omit model parameter** (uses Cursor default)

Your `orbit-config.yaml` can define custom tiers for documentation and cost tracking, but only `"fast"` will actually change the model used by subagents. All other tiers use Cursor's default model (typically Sonnet 4.5).

**When to use this skill:**
- To determine if a stage should use `model="fast"` or omit the parameter
- To document which tier was intended (for cost tracking)
- To prepare for future Cursor updates that may support more model options

---

## Purpose

Optimize AI model selection based on:
- **Task complexity** (simple search vs complex planning)
- **User profile** (cost-optimized vs quality-optimized)
- **Stage criticality** (planning is critical, search is not)

---

## How It Works

### Step 1: Load Active Profile

Read `.cursor/orbit-config.yaml` and get `active_profile`:

```yaml
active_profile: complex_feature_development
```

### Step 2: Get Model for Stage

When invoking a subagent, look up the model tier for that stage:

```yaml
profiles:
  complex_feature_development:
    planning_phase:
      risk_analyzer: deep-reasoning
      tdd_planner: deep-reasoning
```

### Step 3: Map Tier to Model

Look up the actual model ID from `model_tiers`:

```yaml
model_tiers:
  deep-reasoning:
    primary: "claude-3-5-sonnet-20241022"
    fallback: "gpt-4-turbo-2024-04-09"
```

### Step 4: Return Model Parameter

**IMPORTANT:** The Task tool only accepts `"fast"` as a model parameter value. For all other tiers, **omit the model parameter** to use Cursor's default model.

Return the model string for use in Task tool:

```javascript
// If tier is "fast"
Task(
  subagent_type="generalPurpose",
  model="fast",  // Only valid value
  prompt="...",
  description="..."
)

// If tier is anything else (deep-reasoning, balanced, code-specialized)
Task(
  subagent_type="generalPurpose",
  // model parameter OMITTED - uses Cursor default (Sonnet 4.5)
  prompt="...",
  description="..."
)
```

---

## Usage in Commands

### Example: `/plan` Command

```javascript
// Load orbit config
const orbitConfig = loadOrbitConfig('.cursor/orbit-config.yaml');
const activeProfile = orbitConfig.profiles[orbitConfig.active_profile];

// Get models for planning phase
const riskModel = getModelForStage('risk_analyzer', activeProfile);
const tddModel = getModelForStage('tdd_planner', activeProfile);

// Launch subagents with appropriate models
// Note: riskModel and tddModel will be null (deep-reasoning tier)
// So we omit the model parameter to use Cursor's default

Task(
  subagent_type="generalPurpose",
  // model parameter omitted - uses default (deep-reasoning tier)
  prompt="Read and execute .cursor/agents/risk-analyzer.md...",
  description="Assess implementation risks"
)

Task(
  subagent_type="generalPurpose",
  // model parameter omitted - uses default (deep-reasoning tier)
  prompt="Read and execute .cursor/agents/tdd-planner.md...",
  description="Generate TDD Blueprint"
)
```

---

## Model Selection Logic

### Function: `getModelForStage(stageName, profile)`

```javascript
function getModelForStage(stageName, profile) {
  // 1. Determine phase
  let phase;
  if (['schema_analyzer', 'rabbit_tracer', 'discovery'].includes(stageName)) {
    phase = 'discovery_phase';
  } else if (['risk_analyzer', 'tdd_planner', 'implementation_planning'].includes(stageName)) {
    phase = 'planning_phase';
  } else if (['code_generation', 'code_refactoring'].includes(stageName)) {
    phase = 'implementation_phase';
  } else if (['code_reviewer', 'test_validator', 'regression_detector'].includes(stageName)) {
    phase = 'review_phase';
  }
  
  // 2. Get model tier from profile
  const modelTier = profile[phase][stageName];
  // e.g., "deep-reasoning", "fast", "balanced"
  
  // 3. Map to Task tool parameter
  // CRITICAL: Task tool only accepts "fast" or null
  if (modelTier === 'fast') {
    return 'fast';  // Only valid enum value
  } else {
    return null;  // Omit model parameter - uses Cursor default
  }
}
```

**Key Change:** The function now returns:
- `"fast"` if the tier is `fast`
- `null` (omit parameter) for all other tiers (`deep-reasoning`, `balanced`, `code-specialized`)

This is because **the Task tool only accepts `"fast"` as a valid model enum value**.

---

## Current Model Mappings

Based on `complex_feature_development` profile:

| Stage | Tier | Model |
|-------|------|-------|
| **Planning (Critical)** |
| risk_analyzer | deep-reasoning | Claude 3.5 Sonnet |
| tdd_planner | deep-reasoning | Claude 3.5 Sonnet |
| implementation_planning | deep-reasoning | Claude 3.5 Sonnet |
| **Implementation** |
| code_generation | code-specialized | Claude 3.5 Sonnet |
| code_refactoring | code-specialized | Claude 3.5 Sonnet |
| **Review** |
| code_reviewer | deep-reasoning | Claude 3.5 Sonnet |
| test_validator | balanced | Claude 3.5 Sonnet |
| regression_detector | balanced | Claude 3.5 Sonnet |
| **Discovery** |
| schema_analyzer | fast | Claude 3.5 Sonnet |
| rabbit_tracer | fast | Claude 3.5 Sonnet |

**IMPORTANT LIMITATION:** The Task tool currently only accepts `"fast"` as a model parameter. All other tiers (`deep-reasoning`, `balanced`, `code-specialized`) will use Cursor's default model (typically Sonnet 4.5) because the model parameter must be omitted.

**Model Parameter Mapping:**
- `fast` tier → `model="fast"` (uses faster model)
- All other tiers → model parameter omitted (uses Cursor default)

When Cursor expands the Task tool's model enum to support more values, update this skill accordingly.

---

## Cost Tracking

After each workflow stage, log the model used:

```markdown
## Stage: Risk Analysis
- **Model Used:** Claude 3.5 Sonnet (deep-reasoning)
- **Estimated Cost:** $0.50
- **Duration:** 45 seconds
```

This appears in:
- Implementation Plan (footer)
- Final report summary

---

## Fallback Strategy

If primary model fails or is unavailable:

1. Try `fallback` model from `model_tiers`
2. If fallback fails, use Cursor's default model
3. Log warning: "⚠️ Fallback to default model (primary/fallback unavailable)"

---

## Profile Switching

To switch profiles, edit `orbit-config.yaml`:

```yaml
# Change this line
active_profile: balanced  # or cost_optimized
```

Or create a command:

```bash
# .cursor/commands/set-profile.md
Change Orbit model profile to optimize for cost or quality.

Usage: /set-profile balanced | cost_optimized | complex_feature_development
```

---

## Future Enhancements

**When Cursor adds multi-model support:**

Update `orbit-config.yaml`:

```yaml
model_tiers:
  deep-reasoning:
    primary: "o1-preview"              # OpenAI o1
    fallback: "claude-3-opus-20240229" # Claude Opus
  
  code-specialized:
    primary: "codestral-latest"        # Mistral Codestral
    fallback: "claude-3-5-sonnet-20241022"
```

**Analytics Dashboard:**
- Track cost per stage
- Compare quality across models
- Auto-tune profiles based on results

---

## See Also

- Configuration file: `.cursor/orbit-config.yaml`
- Model recommendations: `.cursor/agents/README.md`
- Cost estimates: `docs/orbit_subagent_workflow.md`
