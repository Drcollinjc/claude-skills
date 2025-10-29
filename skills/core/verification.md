# Verification Skill v1.0.0

## Purpose
Systematic validation and testing

## Core Loop
1. Run tests
2. Check output
3. Validate requirements
4. Confirm no regressions

## Commands
```bash
# Python testing
poetry run pytest -xvs
poetry run pytest --cov=src --cov-report=term-missing

# Code quality
poetry run ruff check .
poetry run ruff format .
poetry run mypy src/

# AWS CDK
poetry run cdk synth
poetry run cdk diff

# Pre-commit
poetry run pre-commit run --all-files
```

## Validation Checklist
- [ ] All tests pass
- [ ] Coverage > 80%
- [ ] No linting errors
- [ ] Type checks pass
- [ ] CDK synthesis successful
- [ ] Security scan clean

## Evolution
- v1.0.0: Initial version
