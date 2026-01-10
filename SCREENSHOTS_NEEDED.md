# Screenshots Needed for Setup Guide

This document lists all screenshots that should be captured and added to the setup documentation.

## How to Use This Guide

1. Follow the setup steps in [SETUP_GUIDE.md](./SETUP_GUIDE.md)
2. Take screenshots at each indicated point
3. Save screenshots with the naming convention: `screenshot-X.X-description.png`
4. Add screenshots to a `/docs/images/` folder
5. Update the setup guide markdown to reference actual images

---

## Screenshot List

### Part 1: Google Gemini API Setup

**Screenshot 1.1:** `screenshot-1.1-google-cloud-console.png`
- **Page:** https://console.cloud.google.com
- **What to show:** Main Google Cloud Console homepage
- **Callouts:** Navigation menu, project selector

**Screenshot 1.2:** `screenshot-1.2-gemini-api-key.png`
- **Page:** https://aistudio.google.com/app/apikey
- **What to show:** API key page with "Get API key" button
- **Callouts:** "Create API key in new project" button, API key display area
- **Note:** Blur/mask the actual API key value

---

### Part 2: Salesforce Configuration

**Screenshot 2.1a:** `screenshot-2.1a-named-credential-setup.png`
- **Page:** Setup → Named Credentials → New
- **What to show:** Named Credential form filled out with:
  - Label: Google Gemini API
  - Name: Google_Gemini_API
  - URL: https://generativelanguage.googleapis.com
  - Custom header section
- **Callouts:** All form fields, Save button
- **Note:** Mask the API key value

**Screenshot 2.1b:** `screenshot-2.1b-named-credential-saved.png`
- **Page:** Named Credential detail page
- **What to show:** Success message and saved credential details
- **Callouts:** Active status, credential name

**Screenshot 2.2:** `screenshot-2.2-remote-site-settings.png`
- **Page:** Setup → Remote Site Settings
- **What to show:** List view with Google_Gemini entry
- **Callouts:** Active checkbox (checked), Remote Site URL

**Screenshot 2.3a:** `screenshot-2.3a-custom-metadata-type.png`
- **Page:** Setup → Custom Metadata Types → AI Configuration
- **What to show:** AI Configuration detail page
- **Callouts:** "Manage Records" button

**Screenshot 2.3b:** `screenshot-2.3b-metadata-record.png`
- **Page:** Custom Metadata record edit page
- **What to show:** Case_Classification record with fields:
  - API Endpoint: /v1beta/models/gemini-1.5-flash:generateContent
  - Temperature: 0.3
  - Max Tokens: 500
- **Callouts:** Each field with its value

---

### Part 3: Deploy Metadata

**Screenshot 3.1:** `screenshot-3.1-deploy-fields.png`
- **Terminal/Command Line**
- **What to show:** Output of `sfdx force:source:deploy` command
- **Callouts:** Success status, deployed files list

**Screenshot 3.2:** `screenshot-3.2-case-fields-list.png`
- **Page:** Setup → Object Manager → Case → Fields & Relationships
- **What to show:** Fields list with three new fields visible:
  - Classification Method
  - Classification Confidence
  - Pre-Classification Complete
- **Callouts:** Circle or highlight the three new fields

---

### Part 4: Add Component to Page

**Screenshot 4.1:** `screenshot-4.1-lightning-pages-list.png`
- **Page:** Setup → Object Manager → Case → Lightning Record Pages
- **What to show:** List of Case pages
- **Callouts:** Edit button next to Case Record Page

**Screenshot 4.2a:** `screenshot-4.2a-app-builder-component.png`
- **Page:** Lightning App Builder
- **What to show:** Page builder with preClassification component placed
- **Callouts:** Component in left panel, component on canvas

**Screenshot 4.2b:** `screenshot-4.2b-component-properties.png`
- **Page:** Lightning App Builder (component selected)
- **What to show:** Properties panel on right side
- **Callouts:** recordId and autoApplyThreshold properties

**Screenshot 4.2c:** `screenshot-4.2c-activation-modal.png`
- **Page:** Lightning App Builder activation modal
- **What to show:** Activation options with apps selected
- **Callouts:** Lightning Experience checkbox, App selections

**Screenshot 4.3:** `screenshot-4.3-page-layout-fields.png`
- **Page:** Case record page (view mode)
- **What to show:** Details section with classification fields visible
- **Callouts:** Three classification fields in a section

---

### Part 5: Testing

**Screenshot 5.1:** `screenshot-5.1-test-case-created.png`
- **Page:** Case record page (newly created test case)
- **What to show:** Basic case information
- **Callouts:** Case number, subject, status

**Screenshot 5.2a:** `screenshot-5.2a-intro-screen.png`
- **Page:** Case record with preClassification component
- **What to show:** Introduction screen with:
  - "Let's find the right path" heading
  - Info badges (30 seconds, AI-Powered, Accurate Routing)
  - Get Started button
- **Callouts:** WM branding elements, call-to-action

**Screenshot 5.2b:** `screenshot-5.2b-questions-filled.png`
- **Page:** Questions screen
- **What to show:** All 5 questions with answers filled in
- **Callouts:** Progress indicator, submit button, validation indicators

**Screenshot 5.2c:** `screenshot-5.2c-processing.png`
- **Page:** Processing screen
- **What to show:** Loading spinner and processing steps
- **Callouts:** Animated elements, step progress

**Screenshot 5.2d:** `screenshot-5.2d-results-auto-applied.png`
- **Page:** Results screen (high confidence)
- **What to show:** Success message, classification path, confidence bar
- **Callouts:**
  - Success icon
  - Classification: Type → Sub-Type → Reason
  - Green confidence bar showing 92%
  - AI reasoning box
  - Continue button

**Screenshot 5.2e:** `screenshot-5.2e-results-review.png`
- **Page:** Results screen (low confidence)
- **What to show:** Warning message, classification with lower confidence
- **Callouts:**
  - Warning icon
  - Orange confidence bar showing 65%
  - Two action buttons: "Choose Manually" and "Accept & Continue"

**Screenshot 5.3:** `screenshot-5.3-case-updated.png`
- **Page:** Case record after classification
- **What to show:** All classification fields populated:
  - Case Type, Case Sub-Type, Case Reason (standard fields)
  - Classification Method, Classification Confidence, Pre-Classification Complete (new fields)
- **Callouts:** Circle or highlight all updated fields

**Screenshot 5.4:** `screenshot-5.4-low-confidence.png`
- **Page:** Results screen with ~65% confidence
- **What to show:** Review required message with manual options
- **Callouts:** Confidence bar color (orange), action buttons

---

### Monitoring & Analytics

**Screenshot M.1:** `screenshot-m.1-method-distribution-report.png`
- **Page:** Salesforce Reports
- **What to show:** Donut chart showing classification method breakdown
- **Callouts:** Percentages for AI-Gemini, AI-Gemini-Manual, Manual

**Screenshot M.2:** `screenshot-m.2-confidence-trend.png`
- **Page:** Salesforce Reports
- **What to show:** Line chart of average confidence over time
- **Callouts:** Trend line, target line at 85%

**Screenshot M.3:** `screenshot-m.3-low-confidence-cases.png`
- **Page:** Salesforce Reports
- **What to show:** List of cases with confidence < 80%
- **Callouts:** Confidence column, sorted ascending

**Screenshot M.4:** `screenshot-m.4-dashboard.png`
- **Page:** Salesforce Dashboard
- **What to show:** Complete dashboard with:
  - Donut chart (method distribution)
  - Line chart (confidence trend)
  - Table (recent cases)
  - Metrics (total classified, avg confidence)
- **Callouts:** Each dashboard component labeled

---

## Screenshot Guidelines

### Technical Requirements:
- **Format:** PNG (preferred) or JPG
- **Resolution:** 1920x1080 minimum
- **DPI:** 150+ for print quality
- **File Size:** Compress to < 500KB each

### Capture Guidelines:
- **Browser:** Use Chrome or Firefox in standard window size
- **Zoom:** Set browser zoom to 100%
- **Annotations:** Add after capture using tool like:
  - Snagit
  - Skitch
  - Lightshot
  - macOS Preview
  - Windows Snip & Sketch

### What to Include in Screenshots:
✅ **DO Include:**
- Salesforce header (to show context)
- Relevant navigation breadcrumbs
- All form fields and their values
- Success/error messages
- Button states (enabled/disabled)

❌ **DON'T Include:**
- Sensitive data (real customer names, API keys)
- Personal information
- Email addresses (except generic ones)
- Internal company URLs (use generic "yourinstance.salesforce.com")

### Annotation Style:
- **Callout boxes:** Red rectangles or circles
- **Arrows:** Red arrows pointing to key elements
- **Text:** Use sans-serif font (Arial, Helvetica)
- **Numbers:** Circle numbers for step-by-step callouts

---

## Screenshot Capture Tools

### Free Tools:
- **macOS:** Cmd+Shift+4 (native)
- **Windows:** Windows+Shift+S (Snipping Tool)
- **Chrome Extension:** Awesome Screenshot
- **Cross-platform:** ShareX (Windows), Flameshot (Linux)

### Paid Tools:
- **Snagit** (recommended) - https://www.techsmith.com/screen-capture.html
- **CloudApp** - https://www.getcloudapp.com
- **Droplr** - https://droplr.com

---

## Organization

Save screenshots in this structure:

```
MasterIntakeFlow/
└── docs/
    └── images/
        ├── setup/
        │   ├── screenshot-1.1-google-cloud-console.png
        │   ├── screenshot-1.2-gemini-api-key.png
        │   ├── screenshot-2.1a-named-credential-setup.png
        │   └── ...
        ├── testing/
        │   ├── screenshot-5.2a-intro-screen.png
        │   ├── screenshot-5.2b-questions-filled.png
        │   └── ...
        └── analytics/
            ├── screenshot-m.1-method-distribution-report.png
            └── ...
```

---

## Updating the Setup Guide

After capturing screenshots, update SETUP_GUIDE.md:

**Replace this:**
```markdown
> 📷 **Screenshot 1.1:** Google Cloud Console homepage
> *Show: Main dashboard with navigation menu*
```

**With this:**
```markdown
![Google Cloud Console](./docs/images/setup/screenshot-1.1-google-cloud-console.png)
*Figure 1.1: Google Cloud Console homepage showing navigation menu*
```

---

## Checklist

Use this checklist when capturing screenshots:

### Part 1: Google Setup (2 screenshots)
- [ ] 1.1: Google Cloud Console homepage
- [ ] 1.2: Gemini API key page

### Part 2: Salesforce Config (5 screenshots)
- [ ] 2.1a: Named Credential setup
- [ ] 2.1b: Named Credential saved
- [ ] 2.2: Remote Site Settings
- [ ] 2.3a: Custom Metadata Type page
- [ ] 2.3b: Metadata record

### Part 3: Deploy (2 screenshots)
- [ ] 3.1: Deploy command output
- [ ] 3.2: Case fields list

### Part 4: Page Layout (4 screenshots)
- [ ] 4.1: Lightning pages list
- [ ] 4.2a: App Builder with component
- [ ] 4.2b: Component properties
- [ ] 4.2c: Activation modal
- [ ] 4.3: Page layout with fields

### Part 5: Testing (7 screenshots)
- [ ] 5.1: Test case created
- [ ] 5.2a: Intro screen
- [ ] 5.2b: Questions filled
- [ ] 5.2c: Processing screen
- [ ] 5.2d: Results (auto-applied)
- [ ] 5.2e: Results (review)
- [ ] 5.3: Case updated
- [ ] 5.4: Low confidence scenario

### Monitoring (4 screenshots)
- [ ] M.1: Method distribution report
- [ ] M.2: Confidence trend
- [ ] M.3: Low confidence cases
- [ ] M.4: Complete dashboard

**Total Screenshots Needed: 24**

---

## Video Alternative

Consider recording a video walkthrough as an alternative/supplement:

1. **Screen Recording Tools:**
   - Loom (free for up to 5 min)
   - OBS Studio (free, open source)
   - Camtasia (paid)

2. **Video Content:**
   - Complete setup (10-15 minutes)
   - Testing walkthrough (5 minutes)
   - Troubleshooting common issues (5 minutes)

3. **Upload to:**
   - YouTube (unlisted)
   - Vimeo
   - Internal company video platform

4. **Embed in README.md:**
   ```markdown
   📺 **Video Walkthrough:** [Watch Setup Guide](https://youtu.be/your-video-id)
   ```

---

**Questions about screenshots?**

Contact your technical documentation team or refer to your organization's screenshot style guide.
