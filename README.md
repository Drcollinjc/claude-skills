# Claude Skills Repository

Centralized, evolving skill management for Claude Code across all projects.

## 🏗️ Structure
- `orchestrator/` - Main orchestration logic
- `skills/` - Modular skills by category
  - `core/` - Essential skills (thinking, verification, retrospective)
  - `development/` - Coding skills (TDD, debugging, refactoring)
  - `infrastructure/` - AWS/Cloud skills (CDK, serverless, IAM)
  - `testing/` - Testing skills (unit, integration, mocking)
  - `meta/` - Meta skills (learning, evolution)
- `patterns/` - Reusable code patterns
- `lessons/` - Project retrospectives and learnings
- `config/` - Configuration files

## 🔄 Learning System
This repository implements a continuous learning system:
1. Every project generates lessons through retrospectives
2. Lessons create PRs with skill improvements
3. Skills evolve based on real-world usage
4. Future projects benefit from accumulated knowledge

## 📈 Skill Evolution
Skills are versioned and evolve through:
- Automated retrospectives after each task
- Pattern recognition across projects
- Team contributions via PRs
- Validation through CI/CD

## 🚀 Usage
This repository is accessed by Claude Code via MCP (Model Context Protocol).
Skills are automatically loaded based on task requirements.

## 📊 Metrics
See `lessons/` directory for historical learnings and skill evolution.
