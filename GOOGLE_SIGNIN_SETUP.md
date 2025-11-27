# Quick Fix for Google Sign-In Error (Code 10)

## The Problem
Error code 10 means `DEVELOPER_ERROR` - your app isn't properly configured with Google Cloud Console.

## Quick Fix (3 Steps)

### Step 1: Get Your SHA-1 Fingerprint

**Option A: Using the batch file (Windows)**
```bash
get_sha1.bat
```

**Option B: Manual command**
```bash
cd android
gradlew signingReport
```

Look for output like:
```
Variant: debug
SHA1: A1:B2:C3:D4:E5:F6:...  <-- Copy this!
```

### Step 2: Configure Google Cloud Console

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
3. If asked, configure OAuth consent screen first (basic info is enough)
4. Create **Android** OAuth client:
   - Package name: `com.example.finalyear`
   - SHA-1: Paste the SHA-1 from Step 1
5. Create **Web** OAuth client:
   - Application type: **Web application**
   - Name: "Web Client"
   - Copy the **Client ID** (looks like: `123456789-abc.apps.googleusercontent.com`)

### Step 3: Update Configuration Files

1. **Update `android/app/src/main/res/values/strings.xml`:**
   - Replace `YOUR_GOOGLE_WEB_CLIENT_ID` with your **Web Client ID**

2. **Update `backend/.env`:**
   - Add: `GOOGLE_CLIENT_ID=your_web_client_id_here`

3. **Rebuild app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

**Important Notes:**
- Use the **Web Client ID** (not Android Client ID) in both places
- Wait 2-3 minutes after adding SHA-1 before testing
- Restart backend server after updating `.env`

## Still Not Working?

1. Verify SHA-1 matches exactly (no spaces, correct format)
2. Make sure package name is exactly `com.example.finalyear`
3. Check that you're using Web Client ID everywhere (not Android Client ID)
4. Try signing out and back in on your device
5. Wait a few more minutes for Google's servers to sync

## Alternative: Use Email/Password for Now

You can test authentication using email/password sign-in while setting up Google Sign-In. It doesn't require Google Cloud Console configuration.

