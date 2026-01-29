# Claude Code Orchestrator v1.1.0

## Role
Intelligent task routing and skill management for Claude Code.

## Core Process
1. **Analyze** - Understand the task and requirements
2. **Load** - Select and load relevant skills from GitHub
3. **Execute** - Apply skills with focused context
4. **Validate** - Verify work meets requirements (NEW)
5. **Learn** - Run retrospective and capture lessons

## Skill Loading Logic
```python
def select_skills(task_description):
    """Select optimal skills for task"""
    # Always load core skills
    skills = ["core/thinking", "core/verification"]

    # Add specialized skills based on keywords
    task_lower = task_description.lower()

    if any(word in task_lower for word in ["test", "tdd", "pytest"]):
        skills.append("testing/unit-testing")

    if any(word in task_lower for word in ["lambda", "serverless", "api"]):
        skills.append("infrastructure/serverless")

    if any(word in task_lower for word in ["debug", "fix", "error"]):
        skills.append("development/debugging")

    # NEW: Data engineering skills
    if any(word in task_lower for word in ["duckdb", "csv", "parquet", "medallion", "bronze", "silver", "gold", "dbt"]):
        skills.append("development/duckdb-patterns")

    # NEW: Ensure verification loaded for data work
    if any(word in task_lower for word in ["data", "schema", "csv", "database", "migration"]):
        if "core/verification" not in skills:
            skills.append("core/verification")

    # Load retrospective for learning
    skills.append("core/retrospective")

    return skills
```

## Context Management
- Maximum 3-4 active skills
- Incremental context updates
- Checkpoint every 5 iterations

## Validation Reminders

When completing tasks that involve:

### 1. Infrastructure Changes
- ALWAYS run `cdk synth` / `terraform plan` before marking complete
- VERIFY generated config matches expected changes
- CHECK for warnings or deprecations

### 2. Data Changes
- ALWAYS validate schema matches spec exactly
- TEST data loading before building downstream models
- NEVER accept "close enough" column counts
- VERIFY foreign key relationships

### 3. Code Changes
- START the application and test critical path
- CHECK logs for expected behavior
- VERIFY error handling works
- TEST actual failure scenarios, not just happy path

### 4. Story Completion
- Stories are only "done" when 100% of requirements met
- Tests passing ≠ story complete
- User feedback "let's keep working" = do not mark as done

## Learning Integration
After each task:
1. Automatically trigger retrospective
2. Extract patterns and lessons
3. Generate skill improvements
4. Create PR if improvements found

## Version
- Version: 1.1.0
- Last Updated: 2026-01-23
- Evolution: Continuous via retrospectives

## Changelog
- v1.0.0: Initial orchestration system
- v1.1.0: Added data engineering skill loading, validation reminders, validation step in core process
