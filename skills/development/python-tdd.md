# Python TDD Skill v1.0.0

## Purpose
Test-driven development in Python

## TDD Cycle
1. **RED** - Write failing test
2. **GREEN** - Minimal code to pass
3. **REFACTOR** - Improve while keeping tests green

## Test Structure
```python
def test_should_[behavior]_when_[condition]():
    # Arrange
    input_data = ...
    expected = ...

    # Act
    result = function_under_test(input_data)

    # Assert
    assert result == expected
```

## Commands
```bash
# Run last failed
poetry run pytest --lf -xvs

# Run specific test
poetry run pytest path/to/test.py::test_name -xvs

# Coverage
poetry run pytest --cov=src --cov-report=html
```

## Patterns
- Write test first, always
- One assertion per test
- Test behavior, not implementation
- Use fixtures for reusable setup

## Anti-Patterns
- Testing private methods
- Overmocking
- Brittle tests tied to implementation

## Evolution
- v1.0.0: Initial version
