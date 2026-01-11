# Creating Named Credential for Google Gemini API

**Complete Step-by-Step Guide**

This guide covers creating a Named Credential in Salesforce to securely connect to Google Gemini API for AI-powered case classification.

**Time Required:** 10-15 minutes
**Prerequisite:** Google Gemini API Key (get from https://aistudio.google.com/app/apikey)

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Method 1: External Credentials (New UI - Winter '23+)](#method-1-external-credentials-new-ui)
4. [Method 2: Legacy Named Credentials (Classic UI)](#method-2-legacy-named-credentials-classic-ui)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## Overview

### What is a Named Credential?

A Named Credential in Salesforce is a secure way to store:
- API endpoint URLs
- Authentication credentials
- Custom headers (like API keys)

**Benefits:**
- ✅ Credentials encrypted at rest
- ✅ No hardcoded API keys in code
- ✅ Easy credential rotation
- ✅ Centralized authentication management

### What We're Creating

We'll create a Named Credential that:
- Connects to: `https://generativelanguage.googleapis.com`
- Authenticates with: Google Gemini API key
- Passes key via: Custom HTTP header `x-goog-api-key`
- Used in: Apex callouts for AI classification

---

## Prerequisites

### 1. Get Your Google Gemini API Key

If you don't have an API key yet:

1. Go to **Google AI Studio**: https://aistudio.google.com/app/apikey
2. Sign in with your Google account
3. Click **"Get API key"** or **"Create API key"**
4. Select **"Create API key in new project"** (or choose existing project)
5. Copy the API key (starts with `AIza...`)

**Example API Key Format:**
```
AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

⚠️ **IMPORTANT:** Save this key securely. You'll need it in the next steps.

### 2. Check Your Salesforce Version

Salesforce has two Named Credential interfaces:

- **Winter '23 and newer:** External Credentials + Named Credentials (recommended)
- **Older versions:** Legacy Named Credentials

**To check your version:**
1. Click the **Setup** gear icon (top-right)
2. Look at the navigation - if you see "External Credentials", use Method 1
3. If you only see "Named Credentials", use Method 2

---

## Method 1: External Credentials (New UI)

**Use this method if:** Your org is on Winter '23 or newer and you see "External Credentials" in Setup.

This is the **recommended method** for newer Salesforce orgs.

---

### Step 1.1: Create External Credential

1. **Open Setup**
   - Click the **gear icon** (⚙️) in the top-right corner
   - Click **Setup**

2. **Navigate to External Credentials**
   - In the **Quick Find** box (left sidebar), type: `external credentials`
   - Click **External Credentials** (under Security)

3. **Start Creating New Credential**
   - Click **New External Credential** button
   - You'll see the External Credential creation form

---

### Step 1.2: Configure External Credential

Fill in the form with these **exact values**:

| Field | Value | Notes |
|-------|-------|-------|
| **Label** | `Google Gemini API` | Display name (can be anything) |
| **Name** | `Google_Gemini_API` | API name (no spaces, used in code) |
| **Authentication Protocol** | `Custom` | Select from dropdown |

**Form Should Look Like:**
```
┌─────────────────────────────────────────┐
│ External Credential Edit                │
├─────────────────────────────────────────┤
│ Label: Google Gemini API                │
│ Name:  Google_Gemini_API                │
│ Authentication Protocol: Custom          │
└─────────────────────────────────────────┘
```

4. **Click Save**

> 📷 **Screenshot 1.2:** External Credential form filled out

---

### Step 1.3: Add Principal (Authentication Details)

After saving, you'll be on the External Credential detail page.

1. **Scroll to "Principals" section**
   - You should see an empty list with an **"New"** button

2. **Click "New"** button
   - This opens the "External Credential Principal" form

3. **Fill in Principal Information:**

| Field | Value | Notes |
|-------|-------|-------|
| **Label** | `Google Gemini Principal` | Display name |
| **Name** | `Google_Gemini_Principal` | API name |
| **Sequence Number** | `1` | Order of execution (use 1) |
| **Identity Type** | `Named Principal` | Select from dropdown |
| **Authentication Protocol** | `Custom` | Should auto-populate |

4. **Click Save** (but don't close the page yet!)

> 📷 **Screenshot 1.3a:** Principal form filled out

---

### Step 1.4: Add Custom Header Parameter

Now we'll add the API key as a custom HTTP header.

1. **On the Principal detail page**, scroll to **"Custom Headers"** section

2. **Click "New"** under Custom Headers

3. **Fill in Custom Header:**

| Field | Value | Notes |
|-------|-------|-------|
| **Header Name** | `x-goog-api-key` | **EXACT** (case-sensitive!) |
| **Header Value** | `AIzaSy...` | **YOUR** actual API key from Google |
| **Parameter Sequence** | `1` | Order (use 1) |

**CRITICAL: The header name MUST be exactly `x-goog-api-key`**

4. **Click Save**

> 📷 **Screenshot 1.4:** Custom header with API key (key value masked)

---

### Step 1.5: Create Named Credential (Callout Endpoint)

Now we create the Named Credential that references the External Credential.

1. **Navigate to Named Credentials**
   - In Quick Find, type: `named credentials`
   - Click **Named Credentials** (under Security)

2. **Click "New Named Credential"**
   - You'll see the Named Credential form

3. **Fill in Named Credential:**

| Field | Value | Notes |
|-------|-------|-------|
| **Label** | `Google Gemini API` | Display name |
| **Name** | `Google_Gemini_API` | **MUST match Apex code** |
| **URL** | `https://generativelanguage.googleapis.com` | Base endpoint URL |
| **External Credential** | `Google Gemini API` | Select from dropdown |

**Advanced Settings (expand if needed):**
- **Enabled for Callouts:** ☑ Checked (default)
- **Generate Authorization Header:** ☐ Unchecked
- **Allow Merge Fields in HTTP Header:** ☑ Checked
- **Allow Merge Fields in HTTP Body:** ☐ Unchecked

4. **Click Save**

> 📷 **Screenshot 1.5:** Named Credential form with External Credential selected

---

### Step 1.6: Verify Creation

1. **Navigate back to Named Credentials list**
   - You should see "Google Gemini API" in the list

2. **Click on "Google Gemini API"** to view details

3. **Verify these fields:**
   - ✅ URL: `https://generativelanguage.googleapis.com`
   - ✅ External Credential: `Google Gemini API`
   - ✅ Status: Active

> 📷 **Screenshot 1.6:** Named Credential detail page showing configuration

**✅ You're done with Method 1! Skip to [Verification](#verification) section.**

---

## Method 2: Legacy Named Credentials (Classic UI)

**Use this method if:** Your org doesn't have "External Credentials" or you prefer the legacy approach.

---

### Step 2.1: Navigate to Named Credentials

1. **Open Setup**
   - Click the **gear icon** (⚙️) in the top-right
   - Click **Setup**

2. **Find Named Credentials**
   - In the **Quick Find** box, type: `named credentials`
   - Click **Named Credentials** (under Security)

3. **Start Creating**
   - Click **"New Legacy"** button
   - OR just **"New"** if you don't see "External Credentials"

---

### Step 2.2: Fill in Named Credential Form

You'll see a form with many fields. Fill them in **exactly** as shown:

#### **Basic Information**

| Field | Value | Required |
|-------|-------|----------|
| **Label** | `Google Gemini API` | ✅ Yes |
| **Name** | `Google_Gemini_API` | ✅ Yes |
| **URL** | `https://generativelanguage.googleapis.com` | ✅ Yes |

**Important:** The **Name** field (`Google_Gemini_API`) is used in Apex code. It MUST match exactly.

#### **Identity Type**

- **Identity Type:** Select `Named Principal`
  - This means a single credential is used for all users

#### **Authentication Protocol**

- **Authentication Protocol:** Select `Custom`
  - This allows us to use a custom header for the API key

#### **Authentication Settings**

- **Generate Authorization Header:** ☐ **UNCHECK** this box
  - We don't want Salesforce to generate a Bearer token
  - We'll use a custom header instead

#### **Callout Options**

- **Allow Merge Fields in HTTP Header:** ☑ **CHECK** this box
  - Enables using merge fields in custom headers

- **Allow Merge Fields in HTTP Body:** ☐ **UNCHECK** this box
  - Not needed for this integration

---

### Step 2.3: Add Custom Header

Still on the same form, scroll down to **"Custom Headers"** section.

1. **In the "Custom Headers" section**, you'll see fields to add headers

2. **Add the API Key Header:**

| Field | Value |
|-------|-------|
| **Header Name** | `x-goog-api-key` |
| **Header Value** | `AIzaSy...` (YOUR actual API key) |

**CRITICAL NOTES:**
- Header name is **case-sensitive**: must be lowercase `x-goog-api-key`
- Header value is your **actual API key** from Google AI Studio
- The header format is specific to Google Gemini API

**Example:**
```
Header Name:  x-goog-api-key
Header Value: AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

> 📷 **Screenshot 2.3:** Custom Headers section filled in (API key masked)

---

### Step 2.4: Review Complete Form

Before saving, double-check your form has:

```
┌──────────────────────────────────────────────────┐
│ Named Credential Edit                            │
├──────────────────────────────────────────────────┤
│ Label: Google Gemini API                         │
│ Name:  Google_Gemini_API                         │
│ URL:   https://generativelanguage.googleapis.com │
│                                                   │
│ Identity Type: Named Principal                   │
│ Authentication Protocol: Custom                  │
│                                                   │
│ ☐ Generate Authorization Header                 │
│ ☑ Allow Merge Fields in HTTP Header             │
│ ☐ Allow Merge Fields in HTTP Body               │
│                                                   │
│ Custom Headers:                                  │
│   Name:  x-goog-api-key                         │
│   Value: AIzaSy... (your actual key)            │
└──────────────────────────────────────────────────┘
```

---

### Step 2.5: Save Named Credential

1. **Click "Save"** button at the bottom

2. **You should see:**
   - Success message: "Named Credential created successfully"
   - You're redirected to the Named Credential detail page

3. **Verify on Detail Page:**
   - ✅ Name: `Google_Gemini_API`
   - ✅ URL: `https://generativelanguage.googleapis.com`
   - ✅ Authentication: Custom
   - ✅ Custom headers section shows `x-goog-api-key`

> 📷 **Screenshot 2.5:** Named Credential detail page after saving

**✅ You're done with Method 2! Continue to [Verification](#verification) section.**

---

## Verification

### Test the Named Credential

After creating the Named Credential, verify it works:

#### Option 1: Test in Anonymous Apex (Recommended)

1. **Open Developer Console**
   - From Setup, click **Developer Console** (top-right menu)

2. **Open Execute Anonymous**
   - Click **Debug** → **Open Execute Anonymous Window**

3. **Paste Test Code:**

```apex
// Test Google Gemini API connection
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Google_Gemini_API/v1beta/models');
req.setMethod('GET');
req.setTimeout(30000);

Http http = new Http();
try {
    HttpResponse res = http.send(req);
    System.debug('Status Code: ' + res.getStatusCode());
    System.debug('Status: ' + res.getStatus());
    System.debug('Body: ' + res.getBody());

    if (res.getStatusCode() == 200) {
        System.debug('✅ SUCCESS: Named Credential is working!');
    } else {
        System.debug('❌ ERROR: Status ' + res.getStatusCode());
    }
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
}
```

4. **Click "Execute"**

5. **Check Debug Log:**
   - Click **Debug** → **View Log**
   - Look for:
     - ✅ `Status Code: 200` = Success!
     - ❌ `Status Code: 401` = API key invalid
     - ❌ `Status Code: 403` = API not enabled
     - ❌ `Status Code: 404` = URL incorrect

**Expected Successful Output:**
```
Status Code: 200
Status: OK
Body: {"models":[...]}
✅ SUCCESS: Named Credential is working!
```

> 📷 **Screenshot V.1:** Developer Console with successful test

---

#### Option 2: Test in AI Classification Component

The ultimate test is using the actual component:

1. **Navigate to a Case record**
2. **Look for the Pre-Classification component**
3. **Click "Get Started"**
4. **Fill in the diagnostic questions**
5. **Click "Analyze with AI"**
6. **Verify:**
   - ✅ Processing screen appears (2-3 seconds)
   - ✅ Results screen shows classification
   - ❌ Error screen = credential issue

---

## Troubleshooting

### Error: "Couldn't access the credential(s)"

**Full Error Message:**
```
System.CalloutException: We couldn't access the credential(s). You might not have
the required permissions, or the external credential "Google_Gemini_API" might not exist.
```

**Debug Log Shows:**
```
NAMED_CREDENTIAL_RESPONSE|NamedCallout[Named Credential Id=null, Named Credential Name=null...
```

**Cause:** This is the most common initial setup error - the Named Credential doesn't exist yet or cannot be found.

**Solution - Verify Setup:**

**Step 1: Check if Named Credential exists**
1. Go to **Setup** → Quick Find → type `Named Credentials`
2. Look for an entry with **Name** = `Google_Gemini_API`
3. If you don't see it → **You need to create it** (see Method 1 or Method 2 above)
4. If you see it → Continue to Step 2

**Step 2: Verify the Name is exact**
1. Click on your Named Credential
2. Check the **Name** field (not Label!)
3. Must be exactly: `Google_Gemini_API`
   - ❌ NOT: `Google Gemini API` (spaces)
   - ❌ NOT: `google_gemini_api` (case)
   - ❌ NOT: `GoogleGeminiAPI` (underscores)

**Step 3: If using External Credentials (Method 1)**
1. Setup → **External Credentials**
2. Verify entry exists with **Name** = `Google_Gemini_API`
3. Click on it → Verify custom header `x-goog-api-key` exists
4. If External Credential missing → Create it first, then Named Credential

**Step 4: Check Remote Site Settings**
1. Setup → **Remote Site Settings**
2. Verify entry exists for `https://generativelanguage.googleapis.com`
3. If missing → See "Unauthorized endpoint" error below

**Step 5: Verify User Permissions**
1. Setup → **Users** → find your user
2. Click on your username → **Permission Sets** or **Profile**
3. Check these permissions are enabled:
   - ✅ **API Enabled**
   - ✅ **Author Apex** (for testing in Anonymous Apex)

**Quick Test After Setup:**
Run this in Anonymous Apex to verify:
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Google_Gemini_API/v1beta/models');
req.setMethod('GET');
req.setTimeout(30000);

try {
    Http http = new Http();
    HttpResponse res = http.send(req);
    System.debug('✅ SUCCESS - Status: ' + res.getStatusCode());
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}
```

Expected output: `✅ SUCCESS - Status: 200`

---

### Error: "Unauthorized endpoint"

**Full Error Message:**
```
System.CalloutException: Unauthorized endpoint, please check Setup->Security->Remote site settings.
```

**Cause:** Missing Remote Site Setting

**Solution:**
1. Go to **Setup** → **Remote Site Settings**
2. Click **New Remote Site**
3. Fill in:
   - **Remote Site Name:** `Google_Gemini`
   - **Remote Site URL:** `https://generativelanguage.googleapis.com`
   - **Active:** ☑ Checked
4. Click **Save**

---

### Error: "401 Unauthorized"

**Full Error Message:**
```
Status Code: 401
{
  "error": {
    "code": 401,
    "message": "API key not valid."
  }
}
```

**Possible Causes:**
1. API key is incorrect or expired
2. API key has typo or extra spaces
3. Header name is wrong (case-sensitive!)

**Solutions:**

**A. Verify API Key:**
1. Go to https://aistudio.google.com/app/apikey
2. Check if your key is listed and active
3. If expired, generate a new key
4. Copy the new key (no extra spaces)

**B. Update Named Credential:**

*For External Credentials (Method 1):*
1. Setup → External Credentials
2. Click "Google Gemini API"
3. Go to Principals section
4. Edit the principal
5. Go to Custom Headers
6. Edit `x-goog-api-key` header
7. Paste new API key
8. Save

*For Legacy Named Credentials (Method 2):*
1. Setup → Named Credentials
2. Click "Google Gemini API"
3. Click "Edit"
4. Update the Custom Header value
5. Save

**C. Verify Header Name:**
- Must be exactly: `x-goog-api-key` (lowercase)
- NOT: `X-Goog-Api-Key` or `Api-Key` or `apiKey`

---

### Error: "403 Forbidden"

**Full Error Message:**
```
Status Code: 403
{
  "error": {
    "code": 403,
    "message": "Generative Language API has not been used..."
  }
}
```

**Cause:** Generative Language API not enabled for your Google Cloud project

**Solution:**
1. Go to Google Cloud Console: https://console.cloud.google.com
2. Select your project (same one where you created API key)
3. Go to **APIs & Services** → **Library**
4. Search for: `Generative Language API`
5. Click on it
6. Click **Enable**
7. Wait 1-2 minutes for activation
8. Try test again

---

### Error: Named Credential not found in Apex

**Full Error Message:**
```
System.CalloutException: Named Credential 'Google_Gemini_API' not found
```

**Cause:** Named Credential name doesn't match code reference

**Solution:**
1. Verify Named Credential **Name** field is exactly: `Google_Gemini_API`
   - NOT `Google Gemini API` (no spaces)
   - NOT `google_gemini_api` (case matters)
2. Verify Apex code uses: `callout:Google_Gemini_API`
3. If you changed the name, either:
   - Change Named Credential name back to `Google_Gemini_API`, OR
   - Update Apex code in `GoogleGeminiService.cls`:
     ```apex
     private static final String NAMED_CREDENTIAL = 'callout:YOUR_NAME_HERE';
     ```

---

### Error: Custom header not sent

**Symptoms:**
- Test returns 401 Unauthorized
- Debug logs show request without `x-goog-api-key` header

**Cause:** "Allow Merge Fields in HTTP Header" not checked (Legacy method)

**Solution:**
1. Setup → Named Credentials
2. Click "Google Gemini API"
3. Click "Edit"
4. Scroll to **Callout Options**
5. ☑ Check "Allow Merge Fields in HTTP Header"
6. Save

---

### Timeout Error

**Full Error Message:**
```
System.CalloutException: Read timed out
```

**Cause:** Google Gemini API taking longer than 30 seconds to respond

**Solutions:**
1. **Temporary:** Retry the request (might be API slowness)
2. **Check API Status:** https://status.cloud.google.com
3. **Verify Network:** Ensure Salesforce can reach Google APIs
4. **Contact Support:** If persistent, check Google Cloud quota/limits

---

## Security Best Practices

### 1. API Key Rotation

**Rotate API keys every 90 days:**

1. Generate new key in Google AI Studio
2. Test new key in sandbox first
3. Update Named Credential in production
4. Verify applications work
5. Delete old key from Google

### 2. Monitoring Usage

**Track API usage to detect anomalies:**

1. Go to: https://aistudio.google.com
2. Click on your project
3. View usage dashboard
4. Set up alerts for unusual spikes

### 3. Separate Keys for Environments

**Use different API keys for:**
- Development/Sandbox
- UAT/QA
- Production

**Benefits:**
- Isolate usage
- Track consumption per environment
- Revoke without affecting others

### 4. Never Hardcode Keys

**❌ Bad:**
```apex
String apiKey = 'AIzaSyDXXXXXXXXXXX'; // DON'T DO THIS!
```

**✅ Good:**
```apex
// Use Named Credential
req.setEndpoint('callout:Google_Gemini_API/v1beta/models');
// API key passed automatically via custom header
```

---

## Advanced Configuration

### Using Multiple API Keys

If you need multiple Gemini API keys (e.g., different projects):

**Create additional Named Credentials:**

1. Follow same steps above
2. Use different names:
   - `Google_Gemini_API_Project1`
   - `Google_Gemini_API_Project2`
3. Reference in code as needed:
   ```apex
   req.setEndpoint('callout:Google_Gemini_API_Project1/...');
   ```

### Per-User Authentication

If you need per-user API keys (rare):

1. Change **Identity Type** to: `Per User`
2. Each user must set up their own credential:
   - User → Settings → Authentication Settings
   - Add their Google API key

---

## Frequently Asked Questions

### Q: Can I use the same API key in multiple Named Credentials?

**A:** Yes, but it's better to:
- Use separate API keys per environment (dev/prod)
- Monitor usage separately
- Easier to revoke if compromised

### Q: What if I change the API key?

**A:** Just update the Named Credential:
1. Edit the Named Credential (or External Credential Principal)
2. Update the custom header value
3. Save
4. No code changes needed!

### Q: Can I test without deploying the full solution?

**A:** Yes! Use the Anonymous Apex test code in [Verification](#verification) section.

### Q: Does this work in Sandbox?

**A:** Yes! The same steps work in Sandbox orgs.

**Tip:** Use a separate Google API key for Sandbox to track usage separately.

### Q: How much does this cost?

**A:** Named Credentials are **FREE** in Salesforce.

Google Gemini API costs:
- **FREE:** Up to 1,500 requests/day
- **Paid:** ~$0.001 per classification if exceeding free tier

### Q: Can I use this with Salesforce Classic?

**A:** Yes! Named Credentials work in both:
- Lightning Experience
- Salesforce Classic

The setup is the same, just the UI looks different.

---

## Summary

**What We Created:**

✅ Named Credential called `Google_Gemini_API`
✅ Points to: `https://generativelanguage.googleapis.com`
✅ Authenticates with: Custom header `x-goog-api-key`
✅ Secured with: Your Google Gemini API key

**This enables:**
- Secure API key storage (encrypted)
- Easy credential rotation
- No hardcoded keys in Apex code
- Centralized authentication management

**Usage in Code:**
```apex
// Reference in Apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Google_Gemini_API/v1beta/models/gemini-1.5-flash:generateContent');
req.setMethod('POST');
// API key header automatically added!
```

---

## Next Steps

Now that your Named Credential is created:

1. ✅ **Create Remote Site Setting** (if not done)
   - See [SETUP_GUIDE.md Part 2.2](./SETUP_GUIDE.md#step-22-create-remote-site-setting)

2. ✅ **Create Custom Metadata Record**
   - See [SETUP_GUIDE.md Part 2.3](./SETUP_GUIDE.md#step-23-create-custom-metadata-record)

3. ✅ **Deploy Code**
   - Deploy Case fields, LWC component, Apex classes

4. ✅ **Test End-to-End**
   - Use pre-classification component on Case page

---

## Related Documentation

- **Complete Setup Guide:** [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- **Quick Start:** [QUICK_START.md](./QUICK_START.md)
- **Salesforce Docs:** [Named Credentials](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm)
- **Google Gemini API:** [Documentation](https://ai.google.dev/docs)

---

**Document Version:** 1.0
**Last Updated:** January 10, 2026
**Tested On:** Winter '24, Spring '24, Summer '24, Winter '25

---

**Need Help?**

- Review the [Troubleshooting](#troubleshooting) section
- Check Salesforce debug logs for detailed error messages
- Verify API key at https://aistudio.google.com/app/apikey
