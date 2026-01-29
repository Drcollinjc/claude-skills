# Docker Patterns Skill v1.0.0

## Purpose
Docker and docker-compose patterns for AI/ML workloads and development environments.

## AI Workload Timeout Configuration

**Problem**: AI/LLM API calls (Bedrock, OpenAI, etc.) can take 30+ seconds. Docker's default stop timeout is 10 seconds, causing zombie containers.

**Symptoms**:
- Container becomes unresponsive during long AI request
- `docker compose down` hangs indefinitely
- `docker kill` doesn't terminate container
- Requires Docker Desktop restart to clear

### Solution: Increase Stop Grace Period

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    
    # CRITICAL for AI workloads
    stop_grace_period: 60s  # Must exceed max AI request time
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

### Timeout Guidelines

| AI Service | Typical Latency | Recommended `stop_grace_period` |
|------------|-----------------|----------------------------------|
| Claude/Bedrock | 10-30s | 60s |
| GPT-4 | 10-45s | 90s |
| Image Generation | 30-120s | 180s |
| Fine-tuned Models | varies | 2x max expected latency |

## Health Check Patterns

### Basic Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s      # How often to check
  timeout: 10s       # Max time for check to complete
  retries: 3         # Failures before unhealthy
  start_period: 10s  # Grace period for startup
```

### Health Check for Slow-Starting Apps

AI apps loading models need longer startup:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 5
  start_period: 60s  # Allow time for model loading
```

### Health Endpoint Implementation

```python
# FastAPI
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

## Volume Patterns for Development

### Code Hot-Reload

```yaml
volumes:
  # Mount code for hot-reload
  - ./app:/app
  
  # Read-only data volumes
  - ./data/gold:/app/data/gold:ro
  
  # Read-write for persistence
  - ./data/output:/app/data/output
```

### Volume Mode Reference

| Mode | Syntax | Use Case |
|------|--------|----------|
| Read-Write | `./src:/app` | Code, writable data |
| Read-Only | `./data:/data:ro` | Reference data, configs |
| Named Volume | `db_data:/var/lib/db` | Database persistence |

## Environment Variables

### Using .env Files

```yaml
services:
  app:
    env_file:
      - .env  # Load from file
    environment:
      # Override or add variables
      - PORT=8000
      - AWS_REGION=${AWS_REGION:-us-east-1}  # With default
```

### Passing AWS Credentials

```yaml
# For local development with AWS
services:
  app:
    env_file:
      - .env  # Contains AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
    environment:
      - AWS_REGION=${AWS_REGION:-us-east-1}
      - BEDROCK_MODEL_ID=${BEDROCK_MODEL_ID:-anthropic.claude-3-sonnet}
```

## Compose File Best Practices

### Remove Deprecated Fields

```yaml
# WRONG - deprecated in Compose v2+
version: "3.8"
services:
  app:
    ...

# CORRECT - no version field needed
services:
  app:
    ...
```

### Complete Example for AI App

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    
    # AI workload configuration
    stop_grace_period: 60s
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    
    volumes:
      # Development hot-reload
      - ./app:/app
      # Read-only data
      - ./data/gold:/app/data/gold:ro
      # Writable output
      - ./data/logs:/app/data/logs
    
    environment:
      - PORT=8000
      - DUCKDB_PATH=/app/data/gold/analytics.duckdb
      - AWS_REGION=${AWS_REGION:-us-east-1}
    
    env_file:
      - .env
```

## Troubleshooting

### Zombie Container

**Symptoms**: Container won't stop, docker commands hang.

**Immediate Fix**:
```bash
# Try graceful stop with longer timeout
docker stop --time=120 container_name

# Force kill if needed
docker kill container_name

# If still stuck: restart Docker Desktop
```

**Permanent Fix**: Increase `stop_grace_period` in compose file.

### Port Already in Use

```bash
# Find process using port
lsof -i :8000

# Kill it
kill -9 <PID>
```

### Volume Permission Issues

```yaml
# Run as specific user
services:
  app:
    user: "${UID}:${GID}"
```

## Anti-Patterns

- Using default stop timeout for AI workloads
- No health check for production containers
- Mounting sensitive files (`.env`, credentials) into container
- Using `version` field in Compose v2+
- Read-write volumes for data that should be read-only
- Hardcoding credentials in compose file

## Evolution
- v1.0.0: Initial patterns from 004-icp-decision-surface (AI workload timeouts, zombie container fix)
