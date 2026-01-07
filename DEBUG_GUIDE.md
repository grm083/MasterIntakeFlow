# Master Intake Form - Debugging Guide

## Quick Start

1. **Open Browser DevTools**
   - Press `F12` (Windows/Linux) or `Cmd+Option+I` (Mac)
   - Or right-click anywhere and select "Inspect"

2. **Navigate to Console Tab**
   - Click the "Console" tab in DevTools

3. **Filter for Component Logs**
   - Type `[MasterIntakeForm]` in the filter box
   - All component logs are prefixed with this tag

## What to Look For

### 1. Component Initialization

When the component loads, you should see:

```
[MasterIntakeForm] connectedCallback - Component mounted
[MasterIntakeForm] recordId: 500XXXXXXXXXX
[MasterIntakeForm] loadIntakeData - Starting initialization
[MasterIntakeForm] Calling initializeIntake Apex method...
[MasterIntakeForm] Received data from Apex: { ... }
```

**Key Check:** Verify `recordId` is a valid Case ID (starts with "500")

### 2. Data Reception

After initialization completes:

```
[MasterIntakeForm] Case context: { caseType: "Pickup", caseSubType: "Extra Pickup", ... }
[MasterIntakeForm] First question received: { id: "...", text: "...", ... }
[MasterIntakeForm] Initialization complete. State: { ... }
```

**Key Check:** Look for `First question received` - if missing, no questions are configured

### 3. Visibility Control

The component renders based on these getters (logged frequently):

```
[MasterIntakeForm] showQuestions getter: {
  result: true,
  cpqEligible: false,
  questionHistoryLength: 1,
  showSummary: false
}
```

**Key Checks:**
- `showQuestions result: true` → Questions should be visible
- `showCPQScreen result: true` → CPQ screen should be visible
- `showError result: true` → Error message should be visible
- `showLoading result: true` → Loading spinner should be visible

### 4. Answer Flow

When user selects an answer:

```
[MasterIntakeForm] handleAnswerSelected - Answer selected
[MasterIntakeForm] Answer details: { questionId: "...", outcomeId: "...", ... }
[MasterIntakeForm] Selected outcome: { isTerminal: false, nextQuestionId: "..." }
[MasterIntakeForm] Loading next question: a2KXXXXXXXXXX
```

**Key Check:** Verify `nextQuestionId` matches the expected next question

### 5. Cache Operations

Watch for cache hits vs. misses:

```
[MasterIntakeForm] Cache lookup result: FOUND
```

or

```
[MasterIntakeForm] Cache lookup result: NOT FOUND
[MasterIntakeForm] Fetching question from server...
```

**Performance:** More cache hits = better performance

## Common Issues and Solutions

### Issue: No Questions Displaying

**Symptoms:**
```
[MasterIntakeForm] showQuestions getter: { result: false, ... }
```

**Check:**
1. **No first question returned:**
   ```
   [MasterIntakeForm] No first question returned from Apex
   [MasterIntakeForm] Case Type: Pickup
   [MasterIntakeForm] Case Sub-Type: Extra Pickup
   ```
   **Solution:** Configure intake questions for this case type/subtype combination

2. **CPQ eligible:**
   ```
   [MasterIntakeForm] Case is CPQ eligible - showing CPQ screen
   ```
   **Solution:** Expected behavior - CPQ screen should display instead

3. **Question history empty:**
   ```
   [MasterIntakeForm] showQuestions getter: { questionHistoryLength: 0, ... }
   ```
   **Solution:** Check initialization logs for errors

### Issue: Component Not Loading At All

**Symptoms:** No `[MasterIntakeForm]` logs appear

**Check:**
1. Component added to page layout?
2. Case record has `Master_Intake_Complete__c = false`?
3. JavaScript errors in console (not prefixed with component tag)?

### Issue: Error After Selecting Answer

**Symptoms:**
```
[MasterIntakeForm] Error in loadNextQuestion: ...
```

**Check:**
1. **Question not found in cache:**
   ```
   [MasterIntakeForm] Question still not found after fetch!
   [MasterIntakeForm] Looking for: a2KXXXXXXXXXX
   [MasterIntakeForm] Available keys: [...]
   ```
   **Solution:** Check outcome configuration - `Next_Question__c` may point to invalid question

2. **Apex error:**
   ```
   [MasterIntakeForm] Error message: System.QueryException: ...
   ```
   **Solution:** Check Apex debug logs for full stack trace

### Issue: Completion Fails

**Symptoms:**
```
[MasterIntakeForm] Error in handleFinalSubmit: ...
```

**Check:**
1. **Comment creation fails:**
   - Check user permissions on `Comment__c` object
   - Check required field validation

2. **Case update fails:**
   - Check record type access
   - Check field-level security

## Advanced Debugging

### Enable Apex Debug Logs

1. Go to **Setup → Debug Logs**
2. Click **New** under "User Trace Flags"
3. Select your user
4. Set log level to "FINEST" for Apex
5. Save and reproduce the issue
6. View logs under **Debug Logs**

### View Full State Object

In console, type:

```javascript
// Find the component
let cmp = document.querySelector('c-master-intake-form');

// View state (note: state may not be directly accessible due to LWC encapsulation)
// Use logs instead
```

### Check Network Requests

1. Go to **Network** tab in DevTools
2. Filter for `aura` or `IntakeProcessController`
3. Click on request to see:
   - Request payload
   - Response data
   - Response time

### Common Log Patterns

**Successful initialization:**
```
[MasterIntakeForm] connectedCallback - Component mounted
[MasterIntakeForm] loadIntakeData - Starting initialization
[MasterIntakeForm] Received data from Apex: {...}
[MasterIntakeForm] First question received: {...}
[MasterIntakeForm] Initialization complete. State: {...}
[MasterIntakeForm] showQuestions getter: { result: true, ... }
```

**CPQ eligible case:**
```
[MasterIntakeForm] connectedCallback - Component mounted
[MasterIntakeForm] loadIntakeData - Starting initialization
[MasterIntakeForm] Case is CPQ eligible - showing CPQ screen
[MasterIntakeForm] showCPQScreen getter: { result: true, ... }
```

**No questions configured:**
```
[MasterIntakeForm] connectedCallback - Component mounted
[MasterIntakeForm] loadIntakeData - Starting initialization
[MasterIntakeForm] No first question returned from Apex
[MasterIntakeForm] Case Type: Pickup
[MasterIntakeForm] Case Sub-Type: Extra Pickup
[MasterIntakeForm] showError getter: { result: true, error: "No intake questions..." }
```

**Error during initialization:**
```
[MasterIntakeForm] connectedCallback - Component mounted
[MasterIntakeForm] loadIntakeData - Starting initialization
[MasterIntakeForm] Error in loadIntakeData: {...}
[MasterIntakeForm] Error message: System.QueryException: ...
[MasterIntakeForm] showError getter: { result: true, ... }
```

## Performance Monitoring

### Track Server Calls

Count occurrences of:
- `Calling initializeIntake Apex method...` (should be 1)
- `Fetching question from server...` (fewer is better)

### Expected Performance

**Good performance (using cache):**
- Initial load: 1 server call
- 50 questions: 1-3 additional server calls
- Total: 2-4 server calls

**Poor performance (cache misses):**
- Initial load: 1 server call
- 50 questions: 40-50 additional server calls
- Total: 41-51 server calls

## Getting Help

When reporting issues, include:

1. **Full console logs** (copy all `[MasterIntakeForm]` messages)
2. **Case details:**
   - Case Type
   - Case Sub-Type
   - Case Reason
   - Case ID
3. **Expected vs. Actual behavior**
4. **Screenshots of DevTools console**
5. **Apex debug logs** (if available)

## Removing Debug Logs (Production)

Once debugging is complete, you can reduce console output by:

1. Commenting out `console.log()` statements
2. Keeping only `console.error()` statements
3. Or using a debug flag:

```javascript
const DEBUG = false; // Set to false in production

if (DEBUG) {
    console.log('[MasterIntakeForm] ...');
}
```

However, for production deployments, consider leaving debug logs enabled at least initially to help diagnose any issues in the live environment.
