# Playwright Validation Skill v1.0.0

## Purpose
Using Playwright MCP for UI validation, demo generation, and visual testing.

## When to Use

| Use Case | Description |
|----------|-------------|
| Validation Tasks | Verify UI matches acceptance criteria in tasks.md |
| Demo Generation | Automated walkthrough capture with screenshots |
| Visual Regression | Baseline comparison for UI changes |
| Bug Reproduction | Capture exact state for debugging |
| Acceptance Testing | Verify user stories are complete |

## Core Workflow

### 1. Navigate and Snapshot

```
1. browser_navigate → Load the page
2. browser_snapshot → Get accessibility tree with element refs
3. Analyze snapshot → Identify elements to interact with
```

### 2. Interact with Elements

Use element refs from snapshot:
```
browser_click(ref="button[ref=abc123]", element="Submit button")
browser_type(ref="input[ref=def456]", text="test input")
```

### 3. Capture Evidence

```
browser_take_screenshot(filename="step-1-landing.png")
browser_snapshot() → Verify state changed
```

## Demo Walkthrough Pattern

For generating feature demos:

### Step-by-Step Structure

```markdown
## Demo: [Feature Name]

### Step 1: [Action]
- Navigate to: [URL]
- Screenshot: [filename]
- Verify: [What should be visible]

### Step 2: [Action]
- Click: [Element description]
- Screenshot: [filename]
- Verify: [Expected result]

... continue for each step
```

### Example: ICP Decision Surface Demo

```
Step 1: Landing Page
- Navigate: http://localhost:3000
- Screenshot: 01-landing.png
- Verify: Metric cards visible, insight card present

Step 2: Expand Evidence
- Click: "See the evidence" button
- Screenshot: 02-evidence-expanded.png
- Verify: Evidence bullets visible with data

Step 3: Generate ICP
- Click: "Generate ICP Recommendation" button
- Wait: For page navigation
- Screenshot: 03-icp-editor.png
- Verify: Split panel with ICP fields and reasoning

Step 4: Chat Interaction
- Type: "What about healthcare?" in chat input
- Submit: Press Enter
- Wait: For AI response
- Screenshot: 04-chat-response.png
- Verify: Response with action buttons

Step 5: Execute Action
- Click: Action button (e.g., "Add as Emerging Segment")
- Screenshot: 05-action-applied.png
- Verify: Confirmation message, ICP updated

Step 6: Save Version
- Click: "Save Draft" button
- Screenshot: 06-save-page.png
- Verify: ICP summary, main bet textarea, version info

Step 7: Confirm Save
- Type: Main bet rationale in textarea
- Click: "Save as Canonical" button
- Screenshot: 07-save-success.png
- Verify: Success message with version number
```

## Validation Task Pattern

For tasks.md validation tasks:

### Acceptance Criteria Verification

```markdown
## T024 [US1] Validate AC1: Landing Page Metrics

**Criteria**: Load http://localhost:3000, verify 3-4 metric cards display with real data

**Steps**:
1. browser_navigate(url="http://localhost:3000")
2. browser_snapshot()
3. Verify snapshot contains:
   - MetricCard components (3-4 visible)
   - Real numeric values (not placeholders)
   - Insight card with headline
4. browser_take_screenshot(filename="validation-ac1.png")
5. Report: PASS/FAIL with evidence
```

### Multi-Criteria Validation

```markdown
## T036-T038 [US2] Validate All AC for ICP Editor

**AC1**: Split-panel with 4 ICP fields + reasoning
**AC2**: Confidence badges on each field
**AC3**: Uncertainty callout for low-confidence

**Steps**:
1. Navigate to /editor
2. Snapshot and verify:
   - [ ] 4 ICP fields visible (Company Size, Industry, Buying Signals, Disqualifiers)
   - [ ] Reasoning panel on right
   - [ ] Confidence badges (high/medium/low) on fields
   - [ ] Uncertainty callout present if any low-confidence field
3. Screenshot each state
4. Report: All AC PASS/FAIL
```

## Screenshot Best Practices

### Naming Convention

```
{step-number}-{description}.png

Examples:
- 01-landing-page.png
- 02-evidence-expanded.png
- 03-form-filled.png
- validation-us1-ac1.png
```

### When to Screenshot

| Event | Screenshot? | Reason |
|-------|-------------|--------|
| Page load | Yes | Baseline state |
| After click | Yes | Verify action result |
| Form filled | Yes | Before submission |
| Success state | Yes | Completion evidence |
| Error state | Yes | Debug information |
| Loading state | Optional | Usually skip |

## Element Interaction

### Finding Elements

From browser_snapshot, look for:
```
- button "Submit" [ref=abc123]
- textbox "Email" [ref=def456]
- link "See more" [ref=ghi789]
```

### Click Patterns

```
# Basic click
browser_click(ref="abc123", element="Submit button")

# With description for permission
browser_click(ref="xyz789", element="Generate ICP Recommendation button")
```

### Type Patterns

```
# Type and submit
browser_type(ref="input123", text="What about healthcare?", submit=true)

# Type without submit
browser_type(ref="textarea456", text="Main bet rationale")
```

## Wait Patterns

### Wait for Text

```
# Wait for specific text to appear
browser_wait_for(text="ICP saved successfully")

# Wait for text to disappear (loading)
browser_wait_for(textGone="Loading...")
```

### Wait for Time

```
# Wait fixed duration (for animations, AI responses)
browser_wait_for(time=2)  # 2 seconds
```

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Element not found | Page not loaded | Add wait or re-snapshot |
| Stale ref | Page changed | Re-snapshot to get new refs |
| Click no effect | Wrong element | Verify ref from fresh snapshot |
| Screenshot blank | Page still loading | Add wait before screenshot |

## Anti-Patterns

- Clicking without fresh snapshot (stale refs)
- Not waiting for async operations (AI responses, navigation)
- Screenshots without meaningful names
- Skipping validation steps in tasks.md
- Not capturing error states
- Using hardcoded waits instead of wait_for conditions

## Integration with Tasks.md

### Validation Task Format

```markdown
- [ ] T024 [US1] **Validate AC1**: [Description] → Use Playwright to verify
```

### Validation Report

```markdown
**T024 Validation Result**: ✅ PASS
- Screenshot: validation-us1-ac1.png
- Verified: 4 metric cards with real data
- Evidence: [specific values observed]
```

## Evolution
- v1.0.0: Initial patterns from 004-icp-decision-surface (demo walkthrough, validation tasks)
