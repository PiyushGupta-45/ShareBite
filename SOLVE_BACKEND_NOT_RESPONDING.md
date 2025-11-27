# ✅ Solve: Backend Server Not Responding

## 🔍 Diagnosis

**Good News:** Your backend IS running on port 5000 and responding to localhost! ✅

**The Problem:** The Flutter app cannot connect from the Android emulator.

## 🔧 What I Just Fixed

1. ✅ **Server now listens on all network interfaces** (0.0.0.0)
   - Allows connections from emulator and network devices
   - Previously might have been only listening on localhost

2. ✅ **Added connectivity test endpoint** (`/api/test`)
   - Easy way to test if backend is reachable
   - Shows client IP address

3. ✅ **Better server startup logs**
   - Shows exactly where server is listening
   - Shows which URLs to use

## 🚀 Quick Fix Steps

### Step 1: Restart Backend Server

**This is IMPORTANT - you must restart to apply the fix!**

1. **Stop the backend** (Ctrl+C in the terminal where it's running)

2. **Start it again:**
   ```bash
   cd backend
   npm run dev
   ```

3. **You should now see:**
   ```
   ✅ Server running in development mode
   📡 Listening on http://localhost:5000
   🌐 Accessible from network: http://YOUR_IP:5000
   📱 Android Emulator should use: http://10.0.2.2:5000/api
   ```

### Step 2: Test Backend Connectivity

**Test from your computer:**
```bash
curl http://localhost:5000/api/test
```

**Should return:**
```json
{"success": true, "message": "Backend is reachable!", ...}
```

### Step 3: Test from Flutter App

**Now try signing up again in your Flutter app.**

The backend should now be accessible from the Android emulator!

## 🔍 If Still Not Working

### Check 1: Firewall

Windows Firewall might be blocking connections.

**Quick Test:**
- Temporarily disable Windows Firewall
- Try again
- If it works, add firewall exception for Node.js

**Add Firewall Exception:**
1. Open Windows Defender Firewall
2. Allow an app through firewall
3. Find Node.js and allow it
4. Or allow port 5000

### Check 2: Verify Server is Listening

**Run this command:**
```bash
netstat -ano | findstr :5000
```

**You should see:**
```
TCP    0.0.0.0:5000           0.0.0.0:0              LISTENING
```

**If you see:**
```
TCP    127.0.0.1:5000         ...                    LISTENING
```
→ Server is only listening on localhost (old configuration)
→ **Restart backend** to fix it

### Check 3: Test Network Path

**Test if emulator can reach backend:**

In your Flutter app, the error message shows the URL it's trying. Make sure it's:
- Android Emulator: `http://10.0.2.2:5000/api`
- Physical Device: `http://YOUR_COMPUTER_IP:5000/api` (use `192.168.1.11` based on your network)

## 📱 For Physical Devices

If you're using a **physical Android device**, update the API URL:

**Edit `lib/core/constants/api_constants.dart`:**

```dart
if (Platform.isAndroid) {
  // For physical device, use your computer's IP:
  return 'http://192.168.1.11:5000/api'; // Your IP from ipconfig
}
```

**Make sure:**
- ✅ Device and computer are on the same WiFi network
- ✅ Firewall allows connections on port 5000
- ✅ Use the correct IP address (not localhost)

## ✅ Success Checklist

After restarting backend, verify:

- [ ] Backend console shows "📡 Listening on http://localhost:5000"
- [ ] Backend console shows "📱 Android Emulator should use: http://10.0.2.2:5000/api"
- [ ] Browser can access `http://localhost:5000/health`
- [ ] Browser can access `http://localhost:5000/api/test`
- [ ] Try sign up in Flutter app again

## 🎯 Most Important Step

**RESTART THE BACKEND SERVER** - This applies the fix to listen on all network interfaces!

```bash
# Stop current backend (Ctrl+C)
cd backend
npm run dev
```

Then try again! 🚀

