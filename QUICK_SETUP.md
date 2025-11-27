# Quick Setup - Add Your Google API Key

## ✅ Step 1: Update Android Configuration

**File:** `android/app/src/main/res/values/strings.xml`

**Find this line:**
```xml
<string name="default_web_client_id">PASTE_YOUR_WEB_CLIENT_ID_HERE</string>
```

**Replace `PASTE_YOUR_WEB_CLIENT_ID_HERE` with your actual Web Client ID**

**Example:**
```xml
<string name="default_web_client_id">123456789-abcdefghijk.apps.googleusercontent.com</string>
```

## ✅ Step 2: Update Backend Configuration

**File:** `backend/.env`

**Add or update this line:**
```env
GOOGLE_CLIENT_ID=123456789-abcdefghijk.apps.googleusercontent.com
```

(Use the **same** Web Client ID as in Step 1)

## ✅ Step 3: Rebuild and Test

```bash
# Clean and rebuild Flutter app
flutter clean
flutter pub get
flutter run

# In another terminal, restart backend
cd backend
npm run dev
```

## 📝 Important Notes

- ✅ Use the **Web Client ID** (not Android Client ID)
- ✅ Same ID must be in **both** places (Android app + Backend)
- ✅ No quotes, no extra spaces
- ✅ Restart backend after updating `.env`

That's it! Your Google Sign-In should now work! 🎉

