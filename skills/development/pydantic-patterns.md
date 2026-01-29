# Pydantic Patterns Skill v1.0.0

## Purpose
Pydantic v2 patterns for API development, especially Python backend to JavaScript/TypeScript frontend.

## CamelCase Serialization

**Problem**: Python uses snake_case, JavaScript/TypeScript expects camelCase.

**Solution**: Configure Pydantic models to output camelCase while accepting both formats on input.

### Basic Pattern

```python
from pydantic import BaseModel, ConfigDict

def to_camel(string: str) -> str:
    """Convert snake_case to camelCase."""
    components = string.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])

class APIResponse(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,  # Accept both snake_case and camelCase on input
        by_alias=True,          # Output camelCase in JSON
    )
    
    user_name: str      # Outputs as "userName"
    created_at: str     # Outputs as "createdAt"
    is_active: bool     # Outputs as "isActive"
```

### Key Configuration Options

| Option | Purpose | When to Use |
|--------|---------|-------------|
| `alias_generator` | Transforms field names | Always for camelCase output |
| `populate_by_name` | Accept original names on input | When backend sends snake_case |
| `by_alias` | Use aliases in output | Always for camelCase output |

**Critical**: Must set BOTH `alias_generator` AND `by_alias=True`. Missing either breaks serialization.

### Nested Models

Each nested model needs its own config:

```python
class Evidence(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        by_alias=True,
    )
    sample_size: int    # Outputs as "sampleSize"
    metric_name: str    # Outputs as "metricName"

class ICPField(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        by_alias=True,
    )
    field_value: str            # Outputs as "fieldValue"
    confidence_level: str       # Outputs as "confidenceLevel"
    supporting_evidence: list[Evidence]  # Nested model also uses camelCase
```

### Custom Serialization for Complex Cases

When alias_generator isn't enough:

```python
class Evidence(BaseModel):
    metric: str
    comparison: str | None = None
    sample_size: int | None = None

    def model_dump(self, **kwargs):
        """Override for custom camelCase output."""
        d = super().model_dump(**kwargs)
        return {
            "metric": d["metric"],
            "comparison": d.get("comparison"),
            "sampleSize": d.get("sample_size"),  # Explicit mapping
        }
```

## Enum Patterns

### String Enums for API

```python
from enum import Enum

class ConfidenceLevel(str, Enum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class ICPField(BaseModel):
    confidence: ConfidenceLevel  # Serializes as "high", "medium", "low"
```

**Why `str, Enum`**: Ensures JSON serialization outputs the string value, not `ConfidenceLevel.HIGH`.

## Optional Fields

### Handling None vs Missing

```python
from typing import Optional

class Response(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        by_alias=True,
    )
    
    required_field: str
    optional_field: Optional[str] = None  # Outputs as null if not set
```

### Excluding None Values

To omit null fields from output:

```python
response.model_dump(by_alias=True, exclude_none=True)
```

## FastAPI Integration

### Response Model

```python
from fastapi import FastAPI
from pydantic import BaseModel, ConfigDict

app = FastAPI()

class UserResponse(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        by_alias=True,
    )
    user_name: str
    email_address: str

@app.get("/user/{user_id}", response_model=UserResponse)
async def get_user(user_id: str):
    return UserResponse(
        user_name="John",
        email_address="john@example.com"
    )
    # Output: {"userName": "John", "emailAddress": "john@example.com"}
```

### Request Model

```python
class UserRequest(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,  # Accept both camelCase and snake_case
    )
    user_name: str
    email_address: str

@app.post("/user")
async def create_user(user: UserRequest):
    # Accepts both:
    # {"userName": "John"} and {"user_name": "John"}
    return {"created": user.user_name}
```

## TypeScript Alignment

Ensure frontend types match Pydantic output:

```typescript
// Frontend types must use camelCase
interface UserResponse {
  userName: string;      // Matches Pydantic output
  emailAddress: string;  // Matches Pydantic output
}

interface ICPField {
  fieldValue: string;
  confidenceLevel: 'high' | 'medium' | 'low';
  supportingEvidence: Evidence[];
}
```

## Common Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Missing `by_alias=True` | Output is snake_case | Add to ConfigDict |
| Missing `alias_generator` | Output is snake_case | Add to_camel function |
| Nested model missing config | Nested fields are snake_case | Add ConfigDict to all models |
| Using `Enum` without `str` | Output is "ConfidenceLevel.HIGH" | Use `class X(str, Enum)` |
| Forgetting `populate_by_name` | Can't accept snake_case input | Add to ConfigDict |

## Anti-Patterns

- Manually converting field names in route handlers
- Different casing conventions across models
- Using `Field(alias="camelCase")` for every field (use alias_generator)
- Forgetting to propagate config to nested models
- Assuming FastAPI automatically converts casing

## Evolution
- v1.0.0: Initial patterns from 004-icp-decision-surface
