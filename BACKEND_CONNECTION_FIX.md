# 🔧 Complete Fix: Backend Server Not Responding

## ✅ What I Fixed

1. **Server now listens on all network interfaces** (0.0.0.0) - accessible from emulator
2. **Added connectivity test endpoint** (`/api/test`) - easy way to verify connection
3. **Better error messages** - tells you exactly what's wrong
4. **Request logging** - see all requests in backend console

## 🚀 Step-by-Step Solution

### Step 1: Restart Backend Server (REQUIRED!)

**This is critical - you MUST restart to apply fixes:**

```bash
# Stop the current backend (Ctrl+C in terminal where it's running)
# Then start fresh:
cd backend
npm run dev
```

**Wait for these messages:**
```
✅ Environment variables loaded successfully
📡 CORS: Allowing all origins (development mode)
🔑 Google Client ID: ✅ Set
✅ MongoDB Connected: ...
✅ Server running in development mode
📡 Listening on http://localhost:5000
🌐 Accessible from network: http://YOUR_IP:5000
📱 Android Emulator should use: http://10.0.2.2:5000/api
```

### Step 2: Test Backend is Accessible

**Test from your computer:**
```bash
curl http://localhost:5000/api/test
```

**Should return:**
```json
{"success": true, "message": "Backend is reachable!", ...}
```

**✅ If this works, backend is ready!**

### Step 3: Verify Network Configuration

**For Android Emulator:**
- ✅ URL: `http://10.0.2.2:5000/api` (already configured)
- This is automatically set in `api_constants.dart`

**For Physical Device:**
- ❌ `http://10.0.2.2:5000` won't work!
- ✅ Use your computer's IP: `http://192.168.1.11:5000/api`
- Update `lib/core/constants/api_constants.dart`

### Step 4: Check Firewall

**Windows Firewall might be blocking connections:**

**Quick Fix:**
1. Open Windows Defender Firewall
2. Advanced Settings
3. Inbound Rules → New Rule
4. Port → TCP → Port 5000
5. Allow the connection
6. Apply to all profiles

**Or temporarily disable firewall to test**

### Step 5: Watch Backend Console

**When you try to sign up, watch the backend terminal.**

**You should see:**
```
📥 POST /api/auth/signup
   Body: {"name":"...","email":"...","password":"..."}
📤 POST /api/auth/signup - Status: 201
```

**If you see NO logs:**
- Request not reaching backend
- Check firewall or network

**If you see logs:**
- Backend is receiving requests
- Check for errors in the logs

## 🔍 Troubleshooting

### Issue 1: No Logs in Backend Console

**Problem:** Request never reaches backend

**Solutions:**
1. Check backend is running (`npm run dev`)
2. Check firewall isn't blocking port 5000
3. Verify API URL is correct
4. For physical device: Make sure using computer's IP, not localhost

### Issue 2: "Connection refused" or "SocketException"

**Problem:** Network connectivity issue

**Solutions:**
- Backend not running → Start it
- Firewall blocking → Allow port 5000
- Wrong URL → Check `api_constants.dart`

### Issue 3: Requests Reach Backend But Timeout

**Problem:** Backend is slow (MongoDB, Google API)

**Solutions:**
- Check MongoDB connection in backend console
- Check internet connection for Google API calls
- Look at backend logs to see where it's hanging

## ✅ Quick Verification

Run these commands to verify everything:

```bash
# 1. Check backend is running
netstat -ano | findstr :5000

# 2. Test backend responds
curl http://localhost:5000/health

# 3. Test connectivity endpoint
curl http://localhost:5000/api/test
```

**All should work!**

## 🎯 Right Now: Do This

1. **Stop backend** (Ctrl+C)
2. **Restart backend:**
   ```bash
   cd backend
   npm run dev
   ```
3. **Wait for all startup messages**
4. **Test:** `curl http://localhost:5000/api/test`
5. **Try sign up in Flutter app again**

The server is now configured to accept connections from the emulator! 🚀

