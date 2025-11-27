# Backend Troubleshooting Guide

## ✅ What I Fixed

I've updated your backend to fix common issues:

1. **✅ Environment Variable Validation**
   - Server now checks for required env vars on startup
   - Shows clear error messages if any are missing
   - Prevents server from starting with missing config

2. **✅ Improved CORS Configuration**
   - Now allows all origins in development (for Flutter apps)
   - Properly handles mobile app requests
   - No more CORS errors from Flutter app

3. **✅ Better Error Handling**
   - More specific error messages for Google auth failures
   - Validates Google Client ID before processing requests
   - Better logging for debugging

4. **✅ Startup Checks**
   - Validates all required environment variables
   - Shows status of Google Client ID configuration
   - Logs CORS configuration

## 🔍 How to Check Your Backend

### Step 1: Verify .env File

Make sure `backend/.env` has:
```env
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
PORT=5000
```

### Step 2: Start Backend Server

```bash
cd backend
npm run dev
```

**You should see:**
```
✅ Environment variables loaded successfully
📡 CORS: Allowing all origins (development mode)
🔑 Google Client ID: ✅ Set
MongoDB Connected: ...
Server running in development mode on port 5000
```

**If you see errors:**
- ❌ Missing required environment variables → Add them to .env
- ❌ MongoDB connection failed → Check MONGODB_URI
- ❌ Google Client ID: ❌ Missing → Add GOOGLE_CLIENT_ID to .env

### Step 3: Test Backend

Open your browser and go to:
- `http://localhost:5000` → Should show API is running
- `http://localhost:5000/health` → Should show server is healthy

### Step 4: Test from Flutter App

1. Make sure backend is running (Step 2)
2. Check API URL in Flutter matches backend:
   - Android Emulator: `http://10.0.2.2:5000/api`
   - Physical Device: Your computer's IP (e.g., `http://192.168.1.100:5000/api`)
3. Try signing in/up from the app

## 🚨 Common Errors & Solutions

### Error: "Missing required environment variables"
**Cause:** .env file is missing or incomplete
**Solution:** 
1. Check `backend/.env` exists
2. Add all required variables (see Step 1)
3. Restart server

### Error: "MongoDB connection failed"
**Cause:** Wrong MongoDB URI or network issue
**Solution:**
1. Verify MONGODB_URI in .env is correct
2. Check MongoDB cluster allows connections from your IP
3. Test MongoDB connection separately

### Error: "Google Client ID: ❌ Missing"
**Cause:** GOOGLE_CLIENT_ID not set in .env
**Solution:**
1. Add to `backend/.env`:
   ```
   GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
   ```
2. Restart server

### Error: "Invalid token" or "Authentication failed"
**Cause:** Google Client ID mismatch or token verification failed
**Solution:**
1. Ensure GOOGLE_CLIENT_ID in backend/.env matches Android strings.xml
2. Both should use the **Web Client ID** (not Android Client ID)
3. Restart backend after changing .env
4. Wait 2-3 minutes for Google's servers to sync

### Error: CORS errors in Flutter
**Cause:** CORS not allowing Flutter app origin
**Solution:**
- ✅ Already fixed! Backend now allows all origins in development
- If still happening, restart backend server

## 📋 Checklist

Before reporting errors, verify:

- [ ] Backend server is running (check console output)
- [ ] All required env vars are in `backend/.env`
- [ ] MongoDB connection is successful (see console)
- [ ] Google Client ID is set in both:
  - [ ] `backend/.env`
  - [ ] `android/app/src/main/res/values/strings.xml`
- [ ] Backend and Flutter use the same Web Client ID
- [ ] Restarted backend after changing .env
- [ ] API URL in Flutter matches backend port (default: 5000)

## 🆘 Still Having Issues?

1. **Check backend console logs** - they now show detailed errors
2. **Check Flutter console logs** - shows API errors
3. **Test backend directly:**
   ```bash
   curl http://localhost:5000/health
   ```
4. **Verify .env file format:**
   - No quotes around values
   - No spaces around `=`
   - One variable per line

