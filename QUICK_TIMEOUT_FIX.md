# ⚡ Quick Fix: Sign Up Timeout

## 🚨 The Issue

Your app shows: "Request timeout: Backend server is not responding at http://10.0.2.2:5000/api/auth/google"

## ✅ What I Just Fixed

1. ✅ Added **30-second timeout** to all API requests
2. ✅ Added **detailed logging** in backend
3. ✅ Added **better error messages** in Flutter app
4. ✅ Added **timeout handling** for slow operations

## 🔍 Step-by-Step Diagnosis

### Step 1: Verify Backend is Running

**Open terminal and run:**
```bash
cd backend
npm run dev
```

**You should see:**
```
✅ Environment variables loaded successfully
📡 CORS: Allowing all origins (development mode)
🔑 Google Client ID: ✅ Set
✅ MongoDB Connected: ...
Server running in development mode on port 5000
```

**✅ If you see this, backend is running!**

### Step 2: Test Backend in Browser

**Open your browser and go to:**
```
http://localhost:5000/health
```

**Should show:**
```json
{"success": true, "message": "Server is healthy", ...}
```

**✅ If this works, backend is responding!**

### Step 3: Watch Backend Console When You Try Sign Up

**When you click "Sign Up" in the app, watch the backend terminal.**

**You should see logs like:**
```
📥 2025-11-25T16:20:00.000Z - POST /api/auth/signup
   Body: {"name":"...","email":"...","password":"..."}
```

**If you DON'T see any logs:**
- ❌ Request not reaching backend
- Check network connectivity
- Check API URL is correct

**If you DO see logs but it stops:**
- ✅ Request reached backend
- The logs will show where it's hanging

### Step 4: Check Network Configuration

**For Android Emulator:**
- ✅ Should use: `http://10.0.2.2:5000/api`
- This is already configured correctly

**For Physical Device:**
- ❌ `http://10.0.2.2:5000` won't work!
- ✅ Need your computer's IP: `http://192.168.1.XXX:5000/api`
- Find your IP: Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

## 🎯 Most Likely Causes

### Cause 1: Backend Not Running
**Fix:** Start backend: `cd backend && npm run dev`

### Cause 2: MongoDB Connection Slow
**Check:** Backend console should show "✅ MongoDB Connected: ..."
**Fix:** Check MongoDB URI in backend/.env

### Cause 3: Network Connectivity
**For Emulator:** Should work automatically
**For Physical Device:** Need to use your computer's IP address

### Cause 4: Request Not Reaching Backend
**Check:** Do you see logs in backend console when you try to sign up?
**If no logs:** Network issue - backend not accessible

## 🚀 Quick Test

1. **Make sure backend is running**
2. **Open browser:** `http://localhost:5000/health` (should work)
3. **Try sign up in app**
4. **Watch backend console** - do you see request logs?
5. **If logs appear but timeout:** MongoDB or Google API is slow
6. **If no logs appear:** Network connectivity issue

## 📝 What to Check Next

When you try sign up again:
1. ✅ Backend console shows request received?
2. ✅ Which step does it reach? (Verifying token, Database query, etc.)
3. ✅ Where does it stop/fail?

**Share the backend console logs** - they'll tell us exactly what's wrong! 🔍

