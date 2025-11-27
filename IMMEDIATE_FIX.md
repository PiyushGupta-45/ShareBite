# ⚡ IMMEDIATE FIX: Backend Not Responding

## 🎯 The Problem

Your Flutter app shows: "Backend server is not responding" timeout error.

**Root Cause:** Backend might not be accessible from the Android emulator, or there's a network/firewall issue.

## ✅ Complete Solution (Do These Steps)

### Step 1: RESTART Backend Server (MUST DO!)

**Stop and restart your backend to apply all fixes:**

1. **Go to terminal where backend is running**
2. **Press `Ctrl+C` to stop it**
3. **Start it again:**
   ```bash
   cd backend
   npm run dev
   ```

4. **Wait for these messages:**
   ```
   ✅ Environment variables loaded successfully
   📡 CORS: Allowing all origins (development mode)
   🔑 Google Client ID: ✅ Set
   ✅ MongoDB Connected: ...
   ✅ Server running in development mode
   📡 Listening on http://localhost:5000
   📱 Android Emulator should use: http://10.0.2.2:5000/api
   ```

### Step 2: Test Backend is Working

**Open browser and test:**
```
http://localhost:5000/health
```

**Should show:** `{"success": true, "message": "Server is healthy", ...}`

**If this doesn't work:** Backend has issues - check console for errors

### Step 3: Check Firewall (Common Issue!)

**Windows Firewall might be blocking connections:**

**Quick Test:**
- Temporarily disable Windows Firewall
- Try signup again
- If it works → Firewall was blocking it

**Permanent Fix:**
1. Windows Defender Firewall → Advanced Settings
2. Inbound Rules → New Rule
3. Port → TCP → Specific port: `5000`
4. Allow the connection
5. Apply to all profiles

### Step 4: Verify API URL

**The app uses:** `http://10.0.2.2:5000/api` for Android emulator

**This is correct!** 10.0.2.2 is the special IP that Android emulator uses to access your computer's localhost.

**If using a physical device:**
- Update `lib/core/constants/api_constants.dart`
- Use your computer's IP: `http://192.168.1.11:5000/api` (from ipconfig)

### Step 5: Watch Backend Console

**When you try sign up, BACKEND CONSOLE should show:**

```
📥 POST /api/auth/signup
   Body: {"name":"...","email":"...","password":"..."}
```

**If you see this:** ✅ Request is reaching backend!

**If you DON'T see this:** ❌ Request not reaching backend (firewall/network issue)

## 🔥 Quick Test Checklist

- [ ] Backend restarted (fresh start)
- [ ] Backend console shows "Server running on port 5000"
- [ ] Browser can access `http://localhost:5000/health`
- [ ] Firewall allows port 5000 (or temporarily disabled)
- [ ] Try signup in Flutter app
- [ ] Check backend console for request logs

## 🚨 If Still Not Working

**Check backend console when you try signup:**

**No logs at all?**
- Request not reaching backend
- Check firewall
- Check API URL is correct

**Logs appear but timeout?**
- Backend is receiving request
- Check MongoDB connection
- Check Google API (for Google sign-in)
- Look at where logs stop

**Share the backend console output** - it will show exactly what's happening!

## ✅ Summary

1. **Restart backend** ← MOST IMPORTANT!
2. **Test in browser:** `http://localhost:5000/health`
3. **Check/disable firewall**
4. **Try signup again**
5. **Watch backend console** for logs

The fixes are applied - just restart the backend and it should work! 🚀

