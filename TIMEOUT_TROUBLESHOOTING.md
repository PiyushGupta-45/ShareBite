# Timeout Error Troubleshooting Guide

## 🚨 Issue: Sign Up Taking Too Long / Timeout Error

### ✅ What I Fixed

I've added:
1. **30-second timeout** on all API requests
2. **Better error messages** that tell you exactly what's wrong
3. **Connection error detection** to identify network issues
4. **Clear troubleshooting steps** in error messages

### 🔍 Quick Diagnosis Steps

#### Step 1: Check if Backend is Running

Open a terminal and run:
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

**If backend is NOT running:**
- Start it now: `cd backend && npm run dev`
- Wait for "Server running on port 5000" message
- Then try signup again

#### Step 2: Test Backend Directly

Open your browser and go to:
```
http://localhost:5000/health
```

**Should return:**
```json
{"success": true, "message": "Server is healthy", ...}
```

**If this doesn't work:**
- Backend is not accessible
- Check if port 5000 is in use
- Make sure backend server started successfully

#### Step 3: Check API URL in Flutter

The timeout error message will show the URL it's trying to connect to. Verify:

- **Android Emulator:** Should be `http://10.0.2.2:5000/api/auth/signup`
- **Physical Device:** Should be `http://YOUR_COMPUTER_IP:5000/api/auth/signup`

**Find your computer's IP:**
- Windows: Open Command Prompt, run `ipconfig`, look for "IPv4 Address"
- Mac/Linux: Run `ifconfig` or `ip addr`

#### Step 4: Verify Network Connection

**For Android Emulator:**
- ✅ `http://10.0.2.2:5000` is correct (10.0.2.2 = host machine's localhost)

**For Physical Device:**
- ✅ Make sure phone/device is on same WiFi network as your computer
- ✅ Use your computer's local IP (e.g., `192.168.1.100:5000`)
- ❌ Don't use `localhost` on physical device (won't work!)

### 🛠️ Common Fixes

#### Fix 1: Backend Not Running
**Solution:**
```bash
cd backend
npm run dev
```
Wait until you see "Server running on port 5000"

#### Fix 2: Wrong API URL for Physical Device
**Solution:**
1. Find your computer's IP address (see Step 3 above)
2. Update `lib/core/constants/api_constants.dart`:
   ```dart
   if (Platform.isAndroid) {
     return 'http://192.168.1.XXX:5000/api'; // Replace XXX with your IP
   }
   ```
3. Restart Flutter app

#### Fix 3: Firewall Blocking Connection
**Solution:**
- Windows: Allow Node.js through Windows Firewall
- Mac: Check System Preferences > Security & Privacy > Firewall
- Temporarily disable firewall to test, then add exception

#### Fix 4: MongoDB Connection Slow
**Check backend console for:**
- Long delays before "MongoDB Connected" message
- MongoDB connection errors

**Solution:**
- Check MongoDB URI in `backend/.env`
- Verify MongoDB cluster allows connections from your IP
- Test MongoDB connection speed

### 📱 Device-Specific Settings

#### Android Emulator
✅ Use: `http://10.0.2.2:5000/api`
- This is automatic if you're using emulator
- No changes needed

#### Physical Android Device
✅ Use: `http://YOUR_COMPUTER_IP:5000/api`
- Find your computer's IP
- Update `api_constants.dart` with your IP
- Make sure device and computer on same WiFi

### 🔧 Update API URL for Physical Device

Edit `lib/core/constants/api_constants.dart`:

```dart
if (Platform.isAndroid) {
  // For physical device, replace with your computer's IP:
  return 'http://192.168.1.100:5000/api'; // Change 192.168.1.100 to your IP
}
```

### ✅ Test Checklist

Before reporting timeout errors, verify:

- [ ] Backend server is running (`npm run dev` in backend folder)
- [ ] Backend shows "Server running on port 5000"
- [ ] Browser can access `http://localhost:5000/health`
- [ ] API URL in error message matches your setup
- [ ] For physical device: Using computer's IP (not localhost)
- [ ] For physical device: Same WiFi network
- [ ] Firewall not blocking port 5000
- [ ] MongoDB connection is fast (check backend console)

### 📞 Error Messages Explained

**"Request timeout: Backend server is not responding"**
→ Backend is not running or not accessible at the URL

**"Connection failed: Unable to reach backend server"**
→ Network connectivity issue or wrong URL

**"Cannot connect to backend server"**
→ Check backend is running, URL is correct, same network

### 🚀 Quick Test

1. Start backend: `cd backend && npm run dev`
2. Wait for "Server running on port 5000"
3. Open browser: `http://localhost:5000/health`
4. Should see JSON response
5. Now try signup in Flutter app

If browser test works but Flutter doesn't → Check API URL configuration

