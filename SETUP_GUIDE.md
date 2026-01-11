# AI-Powered Case Classification - Setup Guide

Complete step-by-step setup instructions for deploying Google Gemini AI case classification to your Salesforce org.

**Estimated Setup Time:** 30-45 minutes

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Part 1: Google Gemini API Setup](#part-1-google-gemini-api-setup)
3. [Part 2: Salesforce Configuration](#part-2-salesforce-configuration)
4. [Part 3: Deploy Metadata](#part-3-deploy-metadata)
5. [Part 4: Add Component to Case Page](#part-4-add-component-to-case-page)
6. [Part 5: Testing](#part-5-testing)
7. [Troubleshooting](#troubleshooting)
8. [Monitoring & Analytics](#monitoring--analytics)

---

## Prerequisites

✅ **Required Access:**
- Salesforce System Administrator access
- Google Account (for Gemini API)
- Salesforce CLI installed (for deployment)

✅ **Required Salesforce Licenses:**
- Salesforce Platform license (minimum)
- No additional AI licenses required

✅ **Estimated Costs:**
- Google Gemini 1.5 Flash: **FREE** for up to 1,500 requests/day
- Or ~$0.001 per classification if exceeding free tier

---

## Part 1: Google Gemini API Setup

### Step 1.1: Create Google Cloud Account (if needed)

1. Go to https://console.cloud.google.com
2. Sign in with your Google account
3. Accept the terms of service

> 📷 **Screenshot 1.1:** Google Cloud Console homepage
> *Show: Main dashboard with navigation menu*

---

### Step 1.2: Get Google Gemini API Key

1. Navigate to **Google AI Studio**: https://aistudio.google.com/app/apikey

2. Click **"Get API key"** or **"Create API key"**

3. Select or create a Google Cloud project:
   - Click **"Create API key in new project"** (recommended)
   - Or select an existing project from dropdown

4. Copy your API key (starts with `AIza...`)
   ⚠️ **IMPORTANT:** Store this securely - you'll need it for Salesforce configuration

5. Click **"Done"**

> 📷 **Screenshot 1.2:** Google AI Studio API key page
> *Show: "Get API key" button and API key display*

**Your API key should look like:**
```
AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

### Step 1.3: (Optional) Test API Key

You can test your API key using curl:

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [{
      "parts": [{"text": "Hello"}]
    }]
  }'
```

**Expected response:** JSON with AI-generated content

---

## Part 2: Salesforce Configuration

### Step 2.1: Create Named Credential

Named Credentials store authentication details securely.

1. In Salesforce, click **Setup** (gear icon, top-right)

2. In Quick Find, search for **"Named Credentials"**

3. Click **"Named Credentials"** (under Security)

4. Click **"New"** (or "New Named Credential" if you're on new UI)

5. **For External Credentials (New UI):**

   **Tab 1: External Credential**
   - **Label:** `Google Gemini API`
   - **Name:** `Google_Gemini_API`
   - **Authentication Protocol:** `Custom`

   Click **Save**

   **Tab 2: Add Principal**
   - Click **"New"**
   - **Parameter Sequence:** 1
   - **Parameter Name:** `apiKey`
   - **Parameter Value:** `YOUR_API_KEY_HERE` (paste the key from Step 1.2)
   - **Parameter Type:** `Custom Header`
   - **Header Name:** `x-goog-api-key`

   Click **Save**

6. **For Legacy Named Credentials (Classic UI):**

   - **Label:** `Google Gemini API`
   - **Name:** `Google_Gemini_API`
   - **URL:** `https://generativelanguage.googleapis.com`
   - **Identity Type:** Named Principal
   - **Authentication Protocol:** Custom
   - **Generate Authorization Header:** ☐ Unchecked
   - **Allow Merge Fields in HTTP Header:** ☑ Checked
   - **Allow Merge Fields in HTTP Body:** ☐ Unchecked

   **Custom Headers:**
   - **Header Name:** `x-goog-api-key`
   - **Header Value:** `YOUR_API_KEY_HERE`

   Click **Save**

> 📷 **Screenshot 2.1a:** Named Credential setup page (filled out)
> *Show: Form with all fields populated*

> 📷 **Screenshot 2.1b:** Named Credential confirmation page
> *Show: Success message and named credential details*

---

### Step 2.2: Create Remote Site Setting

Remote Site Settings allow Salesforce to make callouts to external URLs.

1. In Setup Quick Find, search for **"Remote Site Settings"**

2. Click **"Remote Site Settings"**

3. Click **"New Remote Site"**

4. Fill in the form:
   - **Remote Site Name:** `Google_Gemini`
   - **Remote Site URL:** `https://generativelanguage.googleapis.com`
   - **Disable Protocol Security:** ☐ Leave unchecked
   - **Description:** `Google Gemini AI API for case classification`
   - **Active:** ☑ Checked

5. Click **Save**

> 📷 **Screenshot 2.2:** Remote Site Settings list
> *Show: List with Google_Gemini entry visible*

---

### Step 2.3: Create Custom Metadata Record

Custom Metadata stores AI configuration without hardcoding.

1. In Setup Quick Find, search for **"Custom Metadata Types"**

2. Click **"Custom Metadata Types"**

3. Find **"AI Configuration"** in the list

4. Click **"Manage Records"** next to AI Configuration

5. Click **"New"**

6. Fill in the form:
   - **Label:** `Case Classification`
   - **AI Configuration Name:** `Case_Classification`
   - **API Endpoint:** `/v1beta/models/gemini-1.5-flash:generateContent`
   - **Temperature:** `0.3`
   - **Max Tokens:** `500`

7. Click **Save**

> 📷 **Screenshot 2.3a:** Custom Metadata Type detail page
> *Show: AI Configuration with "Manage Records" button*

> 📷 **Screenshot 2.3b:** Custom Metadata record
> *Show: Case_Classification record with all fields filled*

**Field Explanations:**
- **API Endpoint:** The Gemini model endpoint (Flash = fast & cheap, Pro = more accurate)
- **Temperature:** Controls randomness (0.3 = deterministic, good for classification)
- **Max Tokens:** Maximum response length (500 is sufficient for classification JSON)

---

## Part 3: Deploy Metadata

### Step 3.1: Deploy Case Fields

Deploy the three new Case fields using Salesforce CLI:

```bash
cd /path/to/MasterIntakeFlow

# Deploy Case fields
sfdx force:source:deploy -p force-app/main/default/objects/Case/fields
```

**Expected output:**
```
=== Deployed Source
FULL NAME                                TYPE          PROJECT PATH
───────────────────────────────────────────────────────────────────
Classification_Method__c                 CustomField   force-app/main/default/objects/Case/fields/Classification_Method__c.field-meta.xml
Classification_Confidence__c             CustomField   force-app/main/default/objects/Case/fields/Classification_Confidence__c.field-meta.xml
Pre_Classification_Complete__c           CustomField   force-app/main/default/objects/Case/fields/Pre_Classification_Complete__c.field-meta.xml
```

> 📷 **Screenshot 3.1:** Terminal showing successful deployment
> *Show: SFDX command output with success status*

---

### Step 3.2: Verify Fields Created

1. In Setup, go to **Object Manager**
2. Click **Case**
3. Click **Fields & Relationships**
4. Scroll down and verify these fields exist:
   - ✅ Classification Method
   - ✅ Classification Confidence
   - ✅ Pre-Classification Complete

> 📷 **Screenshot 3.2:** Case object Fields & Relationships page
> *Show: List of fields with three new classification fields visible*

---

### Step 3.3: Deploy LWC Component

Deploy the preClassification component:

```bash
# Deploy Lightning Web Component
sfdx force:source:deploy -p force-app/main/default/lwc/preClassification
```

**Expected output:**
```
=== Deployed Source
FULL NAME                                TYPE                          PROJECT PATH
─────────────────────────────────────────────────────────────────────────────────
preClassification                        LightningComponentBundle      force-app/main/default/lwc/preClassification
```

---

### Step 3.4: Deploy Apex Classes (if not already deployed)

```bash
# Deploy Google Gemini service
sfdx force:source:deploy -p force-app/main/default/classes/GoogleGeminiService.cls

# Deploy updated IntakeProcessController
sfdx force:source:deploy -p force-app/main/default/classes/IntakeProcessController.cls
```

---

## Part 4: Add Component to Case Page

### Step 4.1: Edit Case Page Layout

1. In Setup, go to **Object Manager**

2. Click **Case**

3. Click **Lightning Record Pages**

4. Find your Case record page (usually "Case Record Page")

5. Click **Edit** next to the page name

> 📷 **Screenshot 4.1:** Lightning Record Pages list
> *Show: List of Case pages with Edit button*

---

### Step 4.2: Add Pre-Classification Component

You're now in the Lightning App Builder.

1. In the **Components** panel (left side), scroll to **Custom** section

2. Find **"Pre-Classification Assessment"** (preClassification)

3. **Drag** the component onto the page
   - Recommended location: Top of the page, above other components
   - Or in a new tab called "AI Classification"

4. Click on the component to configure it (right panel shows properties):
   - **recordId:** Automatically set to `{!recordId}`
   - **autoApplyThreshold:** Leave default `0.8` (or customize 0.0-1.0)

5. Click **Save**

6. Click **Activate** (if prompted)

7. Choose activation options:
   - **Lightning Experience:** Check
   - **App:** Select relevant apps (e.g., Service Console)
   - **App Page:** Set as org default (recommended)

8. Click **Save**

> 📷 **Screenshot 4.2a:** Lightning App Builder with component
> *Show: Page builder with preClassification component placed*

> 📷 **Screenshot 4.2b:** Component properties panel
> *Show: Properties panel showing recordId and autoApplyThreshold*

> 📷 **Screenshot 4.2c:** Activation modal
> *Show: Activation options with apps selected*

---

### Step 4.3: (Optional) Add Classification Fields to Page Layout

To display the classification tracking fields on the Case page:

1. Still in Lightning App Builder, or go to **Page Layouts**

2. Add a new **Details** component

3. Drag these fields into the Details component:
   - Classification Method
   - Classification Confidence
   - Pre-Classification Complete

4. **Save** the page

> 📷 **Screenshot 4.3:** Page layout with classification fields
> *Show: Case page layout with new fields visible in a section*

---

## Part 5: Testing

### Step 5.1: Create Test Case

1. Navigate to **Cases** tab

2. Click **New**

3. Create a test case with:
   - **Subject:** Test AI Classification
   - **Status:** New
   - Fill in required fields (Client, Location, etc.)

4. Click **Save**

> 📷 **Screenshot 5.1:** New test case created
> *Show: Case record page with basic information*

---

### Step 5.2: Complete Pre-Classification

You should now see the **Pre-Classification Assessment** component on the page.

**Step 1: Introduction Screen**

1. You'll see the introduction screen with:
   - "Let's find the right path for your case"
   - Info badges (30 seconds, AI-Powered, Accurate Routing)
   - **Get Started** button

2. Click **"Get Started"**

> 📷 **Screenshot 5.2a:** Introduction screen
> *Show: Intro screen with WM branding and Get Started button*

---

**Step 2: Answer Questions**

1. Answer the 5 diagnostic questions:

   **Question 1:** What is the primary issue?
   - Select: "Equipment is broken or malfunctioning"

   **Question 2:** Describe the issue
   - Enter: "Compactor is making loud grinding noise and not compacting trash properly. Needs urgent repair."

   **Question 3:** Urgency level
   - Select: "Urgent - Needs attention today"

   **Question 4:** Equipment type
   - Select: "Compactor"

   **Question 5:** Additional context
   - Enter: "Customer called this morning, issue started yesterday"

2. Click **"Analyze with AI"**

> 📷 **Screenshot 5.2b:** Questions screen filled out
> *Show: Questions with answers entered, showing validation*

---

**Step 3: Processing**

1. You'll see the processing screen for 2-3 seconds:
   - Animated spinner
   - "AI is analyzing your responses..."
   - Processing steps with checkmarks

> 📷 **Screenshot 5.2c:** Processing screen
> *Show: Loading spinner with processing steps*

---

**Step 4: View Results**

Based on the answers above, AI should predict with high confidence:

1. **Classification Display:**
   - Type: Equipment Maintenance
   - Sub-Type: Compactor
   - Reason: Repair Request (or Emergency Repair)

2. **Confidence Score:** ~85-95% (shown as green progress bar)

3. **AI Reasoning:**
   - Example: "Keywords 'broken', 'grinding noise', 'not compacting', 'urgent repair' indicate equipment malfunction requiring immediate maintenance attention."

4. If confidence ≥ 80%:
   - ✅ **Auto-Applied:** Classification applied automatically
   - Message: "Classification applied successfully (confidence: 92%)"
   - Button: **"Continue to Intake"**

5. If confidence < 80%:
   - ⚠️ **Review Required:** Please review classification
   - Buttons: **"Choose Manually"** | **"Accept & Continue"**

> 📷 **Screenshot 5.2d:** Results screen (auto-applied)
> *Show: Success message with classification path and confidence bar*

> 📷 **Screenshot 5.2e:** Results screen (review required)
> *Show: Warning message with review options*

---

### Step 5.3: Verify Case Updated

1. Scroll down on the Case page to the classification fields section

2. Verify the fields are populated:
   - **Classification Method:** `AI-Gemini`
   - **Classification Confidence:** `92%` (or similar)
   - **Pre-Classification Complete:** ☑ Checked

3. Check the standard Case fields:
   - **Case Type:** `Equipment Maintenance`
   - **Case Sub-Type:** `Compactor`
   - **Case Reason:** `Repair Request`

> 📷 **Screenshot 5.3:** Case record with updated fields
> *Show: Case detail section with all classification fields populated*

---

### Step 5.4: Test Low-Confidence Scenario

To test the manual review workflow:

1. Create another test case

2. In pre-classification, provide vague answers:
   - Question 1: "General inquiry or other"
   - Question 2: "Need some help"
   - Question 3: "Standard - Can wait 1-2 days"
   - Question 4: Leave blank
   - Question 5: Leave blank

3. AI should return low confidence (< 80%)

4. You'll see the review screen with options:
   - **"Choose Manually"** - Opens manual classification UI
   - **"Accept & Continue"** - Applies AI prediction

5. Test both paths to ensure they work

> 📷 **Screenshot 5.4:** Low-confidence result with review options
> *Show: Review screen with confidence ~65% and manual options*

---

## Troubleshooting

### Issue 1: "AI Classification Error: 401 Unauthorized"

**Cause:** Invalid or missing API key

**Solution:**
1. Verify API key in Named Credential is correct
2. Check that `x-goog-api-key` header name is exact (case-sensitive)
3. Regenerate API key in Google AI Studio if needed
4. Update Named Credential with new key

---

### Issue 2: "AI Classification Error: 403 Forbidden"

**Cause:** API key doesn't have access to Gemini API

**Solution:**
1. Go to Google AI Studio: https://aistudio.google.com
2. Ensure you've accepted terms of service
3. Verify the API key was created in the correct project
4. Check that Generative Language API is enabled in Google Cloud Console

---

### Issue 3: "Remote endpoint not allowed"

**Cause:** Missing Remote Site Setting

**Solution:**
1. Go to Setup → Remote Site Settings
2. Verify `https://generativelanguage.googleapis.com` is listed and **Active**
3. If missing, create it (see Step 2.2)

---

### Issue 4: Component doesn't appear on page

**Cause:** Component not deployed or page not activated

**Solution:**
1. Run deployment command again: `sfdx force:source:deploy -p force-app/main/default/lwc/preClassification`
2. Refresh Lightning App Builder
3. Check component is in Custom section
4. Verify page is activated for your app

---

### Issue 5: "No intake questions configured for this case type"

**Cause:** Case Type/Sub-Type/Reason not set before main intake flow

**Solution:**
This is expected! Pre-classification should run FIRST to set these fields.
- Ensure pre-classification completes successfully
- Verify Case fields are populated after classification
- Then proceed to main Master Intake Flow

---

### Issue 6: Confidence always shows 50%

**Cause:** AI response missing confidence field or parsing error

**Solution:**
1. Check debug logs in Salesforce Developer Console
2. Look for `[GoogleGeminiService]` log entries
3. Verify Gemini is returning proper JSON format
4. Check Temperature setting (should be 0.3, not too high)

---

## Monitoring & Analytics

### Track AI Performance

Create reports to monitor AI classification quality:

#### Report 1: Classification Method Distribution

1. Go to **Reports** tab
2. Click **New Report**
3. Choose **Cases** report type
4. Add grouping: **Classification Method**
5. Add chart: Donut chart showing distribution
6. Save as "AI Classification Adoption"

**Expected Results:**
```
AI-Gemini:         65%  (High confidence, auto-applied)
AI-Gemini-Manual:  20%  (Low confidence, user accepted)
Manual:            15%  (User chose manual or error occurred)
```

> 📷 **Screenshot M.1:** Report showing classification method distribution
> *Show: Donut chart with method breakdown*

---

#### Report 2: AI Confidence Score Trends

1. Create **Cases** report
2. Filter: `Classification Method` contains `AI-Gemini`
3. Add column: **Classification Confidence**
4. Add summary: Average of Classification Confidence
5. Group by: **Created Date** (by month)
6. Add trend chart

**Target Average Confidence:** 85%+

> 📷 **Screenshot M.2:** Confidence trend report
> *Show: Line chart showing confidence over time*

---

#### Report 3: Cases Requiring Manual Review

1. Create **Cases** report
2. Filter: `Classification Confidence` < 80
3. Add columns:
   - Subject
   - Classification Method
   - Classification Confidence
   - Case Type
   - Case Reason
4. Sort by: Confidence (ascending)

**Use Case:** Identify patterns in low-confidence predictions to:
- Improve diagnostic questions
- Add more training data
- Adjust classification logic

> 📷 **Screenshot M.3:** Low-confidence cases report
> *Show: List view of cases with confidence < 80%*

---

### Dashboard: AI Classification Metrics

Create a dashboard combining the above reports:

1. Go to **Dashboards** tab
2. Click **New Dashboard**
3. Name it "AI Classification Performance"
4. Add components:
   - Donut chart: Classification method distribution
   - Line chart: Average confidence over time
   - Table: Recent low-confidence cases
   - Metric: Total cases classified today
   - Metric: Average confidence this month

> 📷 **Screenshot M.4:** AI Classification dashboard
> *Show: Dashboard with multiple charts and metrics*

---

## Advanced Configuration

### Adjust Auto-Apply Threshold

The default threshold is 80% (0.80). You can adjust per your needs:

**Conservative (90%):** Only auto-apply very high confidence
```javascript
autoApplyThreshold="0.90"
```

**Balanced (80%):** Default, good for most use cases
```javascript
autoApplyThreshold="0.80"
```

**Aggressive (70%):** Auto-apply more often, faster workflow
```javascript
autoApplyThreshold="0.70"
```

**To change:**
1. Edit the Case page in Lightning App Builder
2. Select the preClassification component
3. Update the `autoApplyThreshold` property
4. Save and activate

---

### Switch to Gemini Pro Model

For more accurate classification (at slightly higher cost):

1. Go to **Custom Metadata Types** → **AI Configuration**
2. Edit "Case_Classification" record
3. Change **API Endpoint** to:
   ```
   /v1beta/models/gemini-1.5-pro:generateContent
   ```
4. Save

**Cost Comparison:**
- Flash: $0.001 per classification (recommended)
- Pro: $0.005 per classification (5x more expensive, higher accuracy)

---

### Customize Diagnostic Questions

To add/modify questions:

1. Open `preClassification.js` in VS Code
2. Find the `initializeQuestions()` method
3. Add/modify questions in the array
4. Deploy updated component

**Example - Add equipment serial number question:**
```javascript
{
    id: 'q6',
    number: 6,
    text: 'What is the equipment serial number (if known)?',
    type: 'text',
    placeholder: 'E.g., COMP-2024-001',
    required: false,
    answer: ''
}
```

---

## Best Practices

### ✅ DO:
- Monitor AI confidence scores regularly
- Review low-confidence cases to identify patterns
- Adjust threshold based on your accuracy requirements
- Provide clear, specific answers in diagnostic questions
- Use the manual override when AI is uncertain

### ❌ DON'T:
- Set threshold too high (>95%) - reduces auto-apply benefits
- Ignore low-confidence patterns - they indicate training opportunities
- Skip pre-classification - it saves time downstream
- Modify AI responses manually - they're optimized for the model

---

## Support & Resources

### Documentation
- **Google Gemini API Docs:** https://ai.google.dev/docs
- **Salesforce LWC Guide:** https://developer.salesforce.com/docs/component-library/documentation/en/lwc

### Community
- **Salesforce Trailblazer Community:** https://trailhead.salesforce.com/community
- **Google AI Community:** https://developers.googleblog.com/

### Need Help?
- Check the Troubleshooting section above
- Review Salesforce debug logs for detailed error messages
- Test with simple cases first before complex scenarios

---

## Appendix A: API Key Security

### Best Practices:
1. ✅ Store API key in Named Credential (encrypted)
2. ✅ Use separate API keys for dev/test/prod
3. ✅ Rotate keys every 90 days
4. ✅ Monitor API usage in Google Cloud Console
5. ❌ Never hardcode keys in Apex code
6. ❌ Never commit keys to version control

### Rotate API Key:
1. Generate new key in Google AI Studio
2. Update Named Credential with new key
3. Test in sandbox first
4. Delete old key after confirming new one works

---

## Appendix B: Cost Estimation

### Google Gemini 1.5 Flash Pricing

**Free Tier:**
- 1,500 requests per day
- 1 million tokens per month
- No credit card required

**Paid Tier (if exceeding free tier):**
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens

**Typical Classification:**
- Input: ~600 tokens (prompt + context)
- Output: ~100 tokens (JSON response)
- **Cost per classification: ~$0.001**

**Monthly Cost Examples:**

| Daily Volume | Monthly Classifications | Cost (Flash) | Cost (Pro) |
|-------------|------------------------|--------------|------------|
| 50/day      | 1,500                 | **FREE**     | **FREE**   |
| 100/day     | 3,000                 | $3           | $15        |
| 500/day     | 15,000                | $15          | $75        |
| 1,000/day   | 30,000                | $30          | $150       |

**ROI Calculation:**
- Average time saved per case: 2-3 minutes
- Labor cost per minute: $0.50 (example)
- Savings per case: $1.00-1.50
- Break-even volume: ~30-50 cases/day

---

## Appendix C: Field History Tracking

All three classification fields have history tracking enabled. To view:

1. Go to **Setup** → **Object Manager** → **Case**
2. Click **Fields & Relationships**
3. Click field name (e.g., "Classification Method")
4. Check **"Track Field History"** is enabled
5. View history on Case record page

**Use Cases:**
- Audit trail for classification changes
- Monitor AI prediction overrides
- Track confidence score improvements
- Analyze user behavior patterns

---

## Changelog

### Version 1.0 (Current)
- Initial release
- Google Gemini 1.5 Flash integration
- 5 diagnostic questions
- Auto-apply at 80% confidence threshold
- WM brand styling

### Future Enhancements (Planned)
- [ ] Batch classification API
- [ ] Custom classification rules engine
- [ ] Multi-language support
- [ ] Mobile app optimization
- [ ] Real-time confidence tuning

---

**Document Version:** 1.0
**Last Updated:** January 10, 2026
**Author:** Master Intake Flow Team

---

**Questions?** Review the Troubleshooting section or contact your Salesforce administrator.
