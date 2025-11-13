# Claude Code Orchestrator v1.2.0

## Role
Intelligent task routing and skill management for Claude Code and SpecKit workflows.

## Core Process
1. **Analyze** - Understand the command and requirements
2. **Load** - Select and load relevant skills from GitHub
3. **Execute** - Apply skills with focused context
4. **Learn** - Run retrospective and capture lessons

## SpecKit Command Mapping

```python
SPECKIT_SKILLS = {
    "specify": [
        "core/thinking",
        "core/verification"
    ],
    "architecture": [
        "core/thinking",
        "development/cloud-architecture",
        "development/data-modeling",     # NEW: Data modeling for architecture phase
        "core/verification"
    ],
    "clarify": [
        "core/thinking"
    ],
    "plan": [
        "core/thinking",
        "development/cloud-architecture",
        "development/data-modeling",     # Reference during planning
        "core/verification"
    ],
    "implement": [
        "core/thinking",
        "core/verification",
        "development/python-tdd",
        "development/debugging",
        "core/retrospective"
    ],
    "tasks": [
        "core/thinking"
    ],
    "analyze": [
        "core/verification"
    ]
}

def select_skills_for_command(command_name, task_description=""):
    """Select skills based on SpecKit command"""
    # Start with command-specific skills
    skills = SPECKIT_SKILLS.get(command_name, ["core/thinking"])

    # Add context-based skills from description
    if task_description:
        task_lower = task_description.lower()

        if any(word in task_lower for word in ["test", "tdd", "pytest"]):
            if "development/python-tdd" not in skills:
                skills.append("development/python-tdd")

        if any(word in task_lower for word in ["architecture", "aws", "infrastructure", "orchestration", "database"]):
            if "development/cloud-architecture" not in skills:
                skills.append("development/cloud-architecture")

        # Data modeling keyword detection
        if any(word in task_lower for word in [
            "data model", "schema", "database design", "entities",
            "tables", "columns", "relationships", "medallion",
            "dimensional model", "star schema", "normalized",
            "denormalized", "fact table", "dimension", "event sourcing",
            "streaming events", "kafka", "kinesis"
        ]):
            if "development/data-modeling" not in skills:
                skills.append("development/data-modeling")

        if any(word in task_lower for word in ["lambda", "serverless", "api"]):
            if "infrastructure/serverless" not in skills:
                skills.append("infrastructure/serverless")

        if any(word in task_lower for word in ["debug", "fix", "error"]):
            if "development/debugging" not in skills:
                skills.append("development/debugging")

    return skills
```

## Skill Loading Instructions

When a SpecKit command is invoked:

1. **Identify command**: Extract command name (e.g., "specify", "architecture", "implement")
2. **Load base skills**: Fetch skills from `SPECKIT_SKILLS[command_name]`
3. **Load context skills**: Add skills based on task description keywords
4. **Fetch from GitHub**: Load each skill from `Drcollinjc/claude-skills@project/animis-analytics-agent`
5. **Combine with constitution**: Apply local `.specify/memory/constitution.md` constraints
6. **Execute**: Run SpecKit workflow with skill context
7. **Retrospective**: After completion, capture lessons and update project branch

## Example: /speckit.implement Flow

```
1. Orchestrator identifies: command="implement"
2. Base skills loaded: thinking, verification, python-tdd, debugging, retrospective
3. Skills fetched from: github.com/Drcollinjc/claude-skills/project/animis-analytics-agent/skills/
4. Constitution loaded: .specify/memory/constitution.md
5. Implementation executes with combined context
6. Retrospective runs
7. Lessons committed to project branch
```

## Context Management
- Maximum 4-5 active skills per command
- Skills loaded at command start
- Retrospective always runs at command end (for implement)

## Learning Integration

After SpecKit commands complete:
1. Run retrospective skill (for implement, plan)
2. Extract patterns and lessons
3. Update relevant skills in project branch
4. Optionally PR to main for universal improvements

## Version
- Version: 1.2.0
- Last Updated: 2025-11-13
- Changes: Added data-modeling skill for /speckit.architecture and /speckit.plan commands
- Evolution: Continuous via retrospectives
- Branch: project/animis-analytics-agent
