# AI Case Classification - Quick Start Guide

**Time to complete:** 15 minutes

This is a condensed version of the full setup guide. For detailed instructions, see [SETUP_GUIDE.md](./SETUP_GUIDE.md).

---

## Step 1: Get Google Gemini API Key (5 min)

1. Go to https://aistudio.google.com/app/apikey
2. Click **"Create API key in new project"**
3. Copy the API key (starts with `AIza...`)
4. Save it securely for next steps

---

## Step 2: Configure Salesforce (10 min)

### A. Create Named Credential

Setup → Search "Named Credentials" → New

```
Label: Google Gemini API
Name: Google_Gemini_API
URL: https://generativelanguage.googleapis.com
Identity Type: Named Principal
Authentication: Custom

Custom Header:
  Name: x-goog-api-key
  Value: [YOUR_API_KEY_FROM_STEP_1]
```

### B. Create Remote Site

Setup → Search "Remote Site Settings" → New

```
Name: Google_Gemini
URL: https://generativelanguage.googleapis.com
Active: ✓
```

### C. Create Metadata Record

Setup → Search "Custom Metadata Types" → AI Configuration → Manage Records → New

```
Label: Case Classification
Name: Case_Classification
API Endpoint: /v1/models/gemini-1.5-flash:generateContent
Temperature: 0.3
Max Tokens: 500
```

---

## Step 3: Deploy Code (Quick)

```bash
cd /path/to/MasterIntakeFlow

# Deploy everything
sfdx force:source:deploy -p force-app/main/default/objects/Case/fields
sfdx force:source:deploy -p force-app/main/default/lwc/preClassification
sfdx force:source:deploy -p force-app/main/default/classes/GoogleGeminiService.cls
sfdx force:source:deploy -p force-app/main/default/classes/IntakeProcessController.cls
```

---

## Step 4: Add to Page Layout

1. Setup → Object Manager → Case → Lightning Record Pages
2. Edit your Case page
3. Drag **"Pre-Classification Assessment"** component onto the page
4. Save & Activate

---

## Step 5: Test

1. Open any Case
2. You should see the Pre-Classification component
3. Click "Get Started"
4. Answer the 5 questions
5. Click "Analyze with AI"
6. Verify classification is applied

---

## Quick Test Answers

Use these to verify AI is working:

```
Q1: What is the primary issue?
A1: Equipment is broken or malfunctioning

Q2: Describe the issue
A2: Compactor making loud noise and not compacting properly

Q3: Urgency level
A3: Urgent - Needs attention today

Q4: Equipment type
A4: Compactor

Q5: Additional context
A5: Customer called this morning
```

**Expected Result:**
- Type: Equipment Maintenance
- Sub-Type: Compactor
- Reason: Repair Request
- Confidence: 85-95%
- Auto-applied: ✓

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| 401 Unauthorized | Check API key in Named Credential |
| 403 Forbidden | Enable Generative Language API in Google Cloud |
| Remote endpoint not allowed | Create Remote Site Setting |
| Component not visible | Deploy component and refresh page |

Full troubleshooting: See [SETUP_GUIDE.md](./SETUP_GUIDE.md#troubleshooting)

---

## Cost

- **FREE** for up to 1,500 classifications/day
- ~$0.001 per classification if exceeding free tier
- Monitor usage: https://aistudio.google.com

---

## Next Steps

- ✅ Monitor AI confidence scores (Reports → New)
- ✅ Adjust threshold if needed (edit component properties)
- ✅ Review low-confidence cases for patterns
- ✅ Customize questions for your use case

---

**Full Documentation:** [SETUP_GUIDE.md](./SETUP_GUIDE.md)
