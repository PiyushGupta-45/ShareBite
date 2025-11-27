# Google Sign-In Configuration Guide

## Where to Add Your API Key / Client ID

You've obtained your Google OAuth credentials! Now you need to add them in **2 places**:

### 1. Android App Configuration

**File:** `android/app/src/main/res/values/strings.xml`

Replace `YOUR_GOOGLE_WEB_CLIENT_ID` with your actual **Web Client ID**:

```xml
<string name="default_web_client_id">YOUR_ACTUAL_WEB_CLIENT_ID_HERE.apps.googleusercontent.com</string>
```

**Example:**
```xml
<string name="default_web_client_id">123456789-abcdefghijk.apps.googleusercontent.com</string>
```

**Important:** 
- Use the **Web Client ID** (not Android Client ID)
- The `google_sign_in` package automatically reads this value
- Make sure there are no extra spaces or quotes

### 2. Backend Configuration

**File:** `backend/.env`

Add or update the `GOOGLE_CLIENT_ID` variable:

```env
GOOGLE_CLIENT_ID=YOUR_ACTUAL_WEB_CLIENT_ID_HERE.apps.googleusercontent.com
```

**Example:**
```env
GOOGLE_CLIENT_ID=123456789-abcdefghijk.apps.googleusercontent.com
```

**Important:**
- Use the **same Web Client ID** as in the Android app
- Restart your backend server after updating `.env`

## Quick Setup Steps

1. **Open** `android/app/src/main/res/values/strings.xml`
2. **Replace** the placeholder with your Web Client ID
3. **Open** `backend/.env` 
4. **Add/Update** `GOOGLE_CLIENT_ID` with the same Web Client ID
5. **Rebuild** your Flutter app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
6. **Restart** your backend server:
   ```bash
   cd backend
   npm run dev
   ```

## How It Works

1. User clicks "Sign in with Google" in the app
2. App reads Web Client ID from `strings.xml`
3. Google Sign-In SDK authenticates user and gets ID token
4. ID token is sent to your backend API
5. Backend verifies the token using the same Web Client ID
6. Backend creates/updates user and returns JWT token
7. App stores JWT token and user is signed in

## Verification

To verify everything is configured correctly:

1. Both files should have the **same** Web Client ID
2. Web Client ID should look like: `123456789-abc...apps.googleusercontent.com`
3. Make sure you have added your app's SHA-1 fingerprint to Google Cloud Console
4. Package name in Google Cloud Console should match: `com.example.finalyear`

## Troubleshooting

### Error Code 10 (DEVELOPER_ERROR)
- Check that SHA-1 fingerprint is added to Google Cloud Console
- Verify package name matches exactly
- Wait 2-3 minutes after making changes

### ID Token is Null
- Make sure you're using **Web Client ID** (not Android Client ID)
- Check that `strings.xml` has the correct value
- Verify the value doesn't have quotes or extra spaces

### Backend Verification Fails
- Ensure backend `.env` has the same Web Client ID
- Restart backend server after updating `.env`
- Check backend logs for detailed error messages

