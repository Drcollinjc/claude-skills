# Claude Code Orchestrator v1.0.0

## Role
Intelligent task routing and skill management for Claude Code.

## Core Process
1. **Analyze** - Understand the task and requirements
2. **Load** - Select and load relevant skills from GitHub
3. **Execute** - Apply skills with focused context
4. **Learn** - Run retrospective and capture lessons

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

    # Load retrospective for learning
    skills.append("core/retrospective")

    return skills
```

## Context Management
- Maximum 3-4 active skills
- Incremental context updates
- Checkpoint every 5 iterations

## Learning Integration
After each task:
1. Automatically trigger retrospective
2. Extract patterns and lessons
3. Generate skill improvements
4. Create PR if improvements found

## Version
- Version: 1.0.0
- Last Updated: $(date +%Y-%m-%d)
- Evolution: Continuous via retrospectives

## Document Creation Skills
- documents/powerpoint - PowerPoint presentations
- documents/google-docs - Google Docs creation
- documents/google-sheets - Spreadsheet automation
- documents/google-slides - Google Slides
- documents/reports - Report generation

## Integration Skills
- integrations/google-workspace - Google Workspace integration

## Skill Loading for Documents
When task involves:
- "presentation", "slides", "deck" → load documents/powerpoint
- "document", "doc", "write" → load documents/google-docs
- "spreadsheet", "excel", "data" → load documents/google-sheets
- "report" → load documents/reports + relevant document skills
