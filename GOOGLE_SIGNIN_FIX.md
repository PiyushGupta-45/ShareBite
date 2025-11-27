# Fixing Google Sign-In Error (Code 10)

The error you're seeing (`ApiException: 10`) is a `DEVELOPER_ERROR`, which means Google Sign-In is not properly configured. Follow these steps to fix it:

## Step 1: Get Your SHA-1 Fingerprint

You need to add your app's SHA-1 fingerprint to Google Cloud Console. Run this command:

### For Debug Build (Development):

**Windows:**
```bash
cd android
gradlew signingReport
```

**Mac/Linux:**
```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 fingerprint under `Variant: debug` -> `SHA1`. It will look something like:
```
SHA1: A1:B2:C3:D4:E5:F6:...
```

### For Release Build:

If you have a release keystore, you'll need to get the SHA-1 from your release key as well.

## Step 2: Set Up Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable **Google Sign-In API**:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sign-In API" and enable it

4. Create OAuth 2.0 Credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - If prompted, configure the OAuth consent screen first
   
5. Create **Android** OAuth Client:
   - Application type: **Android**
   - Package name: `com.example.finalyear` (from your build.gradle.kts)
   - SHA-1 certificate fingerprint: Paste the SHA-1 from Step 1
   - Click "Create"
   - **Copy the Client ID** (starts with something like `123456789-abc...`)

6. Create **Web** OAuth Client (for ID token):
   - Click "Create Credentials" > "OAuth client ID" again
   - Application type: **Web application**
   - Name: "Web Client" (or any name)
   - Authorized redirect URIs: Leave empty (not needed for mobile)
   - Click "Create"
   - **Copy the Client ID** (this is your Web Client ID - different from Android Client ID)

## Step 3: Configure Android App

1. Open `android/app/src/main/res/values/strings.xml`
2. Replace `YOUR_GOOGLE_WEB_CLIENT_ID` with your **Web Client ID** (not the Android one):

```xml
<string name="default_web_client_id">YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com</string>
```

**Important:** Use the **Web Client ID**, not the Android Client ID. This is needed to get the ID token that your backend verifies.

## Step 4: Update Backend Configuration

1. Open `backend/.env`
2. Add or update the `GOOGLE_CLIENT_ID` with your **Web Client ID** (same as above):

```env
GOOGLE_CLIENT_ID=YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com
```

**Important:** The backend should use the same Web Client ID for token verification.

## Step 5: Rebuild and Test

1. Clean and rebuild your Flutter app:
```bash
flutter clean
flutter pub get
flutter run
```

2. Try Google Sign-In again

## Troubleshooting

### Still Getting Error 10?

1. **Verify SHA-1 matches**: Make sure the SHA-1 in Google Cloud Console matches exactly what `gradlew signingReport` shows
2. **Check Package Name**: Ensure package name in Google Cloud Console is exactly `com.example.finalyear`
3. **Wait a few minutes**: Google's servers may take a few minutes to propagate changes
4. **Check Client ID**: Make sure you're using the Web Client ID in both Flutter app and backend, not the Android Client ID

### Different Error Codes?

- **Error 12500**: User cancelled sign-in (not an error, just user action)
- **Error 7**: Network error - check internet connection
- **Error 8**: Internal error - try again later

### Alternative: Test with Email/Password First

While setting up Google Sign-In, you can test the authentication flow using email/password sign-in, which doesn't require Google Cloud Console configuration.

## Quick Checklist

- [ ] SHA-1 fingerprint added to Google Cloud Console (Android OAuth client)
- [ ] Android OAuth client created with correct package name
- [ ] Web OAuth client created
- [ ] Web Client ID added to `strings.xml`
- [ ] Web Client ID added to backend `.env` file
- [ ] App rebuilt after configuration changes
- [ ] Backend server restarted with new environment variables

