# Google Cloud Console Setup - Package Name

## 📦 Your Package Name

**Package Name:** `com.example.finalyear`

This is your Android application ID that you need to use when creating OAuth credentials in Google Cloud Console.

## 🔧 How to Set Up in Google Cloud Console

### Step 1: Go to Google Cloud Console

Visit: https://console.cloud.google.com/apis/credentials

### Step 2: Create Android OAuth Client

1. Click **"+ CREATE CREDENTIALS"**
2. Select **"OAuth client ID"**
3. If prompted, configure the OAuth consent screen first (basic info is enough)

4. **Application type:** Select **"Android"**

5. **Fill in the details:**
   - **Name:** "Food Donation App Android" (or any name you prefer)
   - **Package name:** `com.example.finalyear` ⬅️ **USE THIS EXACTLY**
   - **SHA-1 certificate fingerprint:** Your SHA-1 fingerprint (get it using `get_sha1.bat` or `gradlew signingReport`)

6. Click **"Create"**

7. **Copy the Client ID** (you'll see something like: `123456789-abc...apps.googleusercontent.com`)
   - ⚠️ This is the **Android Client ID** - you don't need this one!

### Step 3: Create Web OAuth Client (IMPORTANT!)

1. Click **"+ CREATE CREDENTIALS"** again
2. Select **"OAuth client ID"**

3. **Application type:** Select **"Web application"**

4. **Fill in the details:**
   - **Name:** "Food Donation App Web Client" (or any name)
   - **Authorized redirect URIs:** Leave empty (not needed for mobile apps)

5. Click **"Create"**

6. **Copy the Client ID** (looks like: `999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com`)
   - ✅ This is the **Web Client ID** - **USE THIS ONE!**

### Step 4: Add to Your Project

**Add Web Client ID to 2 places:**

1. **Android App:** `android/app/src/main/res/values/strings.xml`
   ```xml
   <string name="default_web_client_id">999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com</string>
   ```

2. **Backend:** `backend/.env`
   ```env
   GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
   ```

## 📋 Quick Reference

| Item | Value |
|------|-------|
| **Package Name** | `com.example.finalyear` |
| **Web Client ID** | `999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com` |

## ✅ Checklist

- [ ] OAuth consent screen configured
- [ ] Android OAuth client created with package name: `com.example.finalyear`
- [ ] SHA-1 fingerprint added to Android OAuth client
- [ ] Web OAuth client created
- [ ] Web Client ID added to `android/app/src/main/res/values/strings.xml`
- [ ] Web Client ID added to `backend/.env`
- [ ] Backend server restarted after updating `.env`

## 🚨 Important Notes

1. **Package name must match exactly:** `com.example.finalyear` (case-sensitive, no spaces)

2. **Use Web Client ID everywhere:**
   - Android `strings.xml` ✅
   - Backend `.env` ✅
   - NOT the Android Client ID ❌

3. **SHA-1 Fingerprint:**
   - Required for Android OAuth client
   - Run `get_sha1.bat` or `cd android && gradlew signingReport`
   - Copy the SHA-1 from the output
   - Add it to Google Cloud Console Android OAuth client

4. **Wait 2-3 minutes** after adding SHA-1 before testing (Google needs time to sync)

