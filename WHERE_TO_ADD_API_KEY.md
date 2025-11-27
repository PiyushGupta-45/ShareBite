# ✅ Where to Add Your Google API Key (Web Client ID)

You've already added it to the Android app! ✅ Now add it to the **backend**:

## 📍 Location: `backend/.env`

### Step 1: Open or Create the File

Navigate to: `backend/.env`

If the file doesn't exist, create it in the `backend` folder.

### Step 2: Add This Line

Add or update this line in the `.env` file:

```env
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
```

### Step 3: Complete .env File Example

Your `backend/.env` file should look like this:

```env
# MongoDB Atlas Connection
MONGODB_URI=your_mongodb_atlas_connection_string

# JWT Secret
JWT_SECRET=your_jwt_secret_key_here

# Google OAuth Web Client ID - YOUR API KEY GOES HERE
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com

# Server Configuration
PORT=5000
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

### Step 4: Restart Backend Server

After saving the `.env` file, restart your backend:

```bash
cd backend
npm run dev
```

## ✅ Summary

You need to add the same Web Client ID in **2 places**:

1. ✅ **Android App** (Already done!): 
   - `android/app/src/main/res/values/strings.xml`
   - Value: `999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com`

2. ⬜ **Backend** (Do this now):
   - `backend/.env`
   - Add: `GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com`

## 🔍 Where is it used?

- **Android app** reads it from `strings.xml` to get the ID token from Google
- **Backend** reads it from `.env` to verify the ID token sent from your app

Both must have the **same** Web Client ID!

