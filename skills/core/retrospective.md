# Retrospective Skill v1.0.0

## Purpose
Capture lessons and evolve skills based on experience

## Activation
- After task completion
- When patterns emerge
- On explicit request

## Process

### 1. Session Analysis
```yaml
session:
  task: [what was attempted]
  duration: [time taken]
  iterations: [number of iterations]
  tokens_used: [total tokens]
  outcome: [success/partial/failure]
  skills_used: [list of skills]
```

### 2. Pattern Recognition
- What worked well?
- What was challenging?
- What patterns emerged?
- What was missing?

### 3. Lesson Extraction
```yaml
lessons:
  - type: [success/failure/insight]
    skill: [affected skill]
    pattern: [what was learned]
    frequency: [how often seen]
    action: [proposed improvement]
```

### 4. Skill Evolution
For patterns seen 3+ times:
1. Identify target skill
2. Create specific improvement
3. Add example
4. Update anti-patterns

### 5. Generate PR
```bash
# Create improvement branch
git checkout -b retro/$(date +%Y%m%d-%H%M)

# Add lesson file
cat > lessons/$(date +%Y%m%d)-$(echo $task | tr ' ' '-').md << 'END_LESSON'
# Retrospective: $task
Date: $(date -I)

## Session Summary
- Task: $task
- Outcome: $outcome
- Efficiency: $tokens_used tokens

## Key Learnings
$learnings

## Skill Updates
$updates
END_LESSON

# Update skills
[make skill updates]

# Create PR
git add .
git commit -m "retro: $key_learning"
git push origin retro/$(date +%Y%m%d-%H%M)
gh pr create --title "Skill Evolution: $key_learning" \
             --body "$retrospective_summary"
```

## Learning Patterns
Track these specific patterns:
- Repeated errors → Add to anti-patterns
- Successful shortcuts → Add to patterns
- Missing knowledge → Add to skills
- Inefficiencies → Optimize approach

## Evolution
- v1.0.0: Initial learning system
