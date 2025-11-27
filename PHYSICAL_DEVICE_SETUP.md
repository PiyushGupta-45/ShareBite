# 📱 Physical Device Setup Guide

## ✅ Configuration Complete!

I've updated your app to work with **physical Android devices**.

## 🔧 What Changed

**File:** `lib/core/constants/api_constants.dart`

- ✅ Changed from `http://10.0.2.2:5000/api` (emulator only)
- ✅ Now uses `http://192.168.1.11:5000/api` (your computer's IP)

## ⚠️ Important Requirements

### 1. Same WiFi Network

**Your phone and computer MUST be on the same WiFi network!**

- ✅ Phone connected to same WiFi as your computer
- ✅ Computer connected to same WiFi
- ❌ Cannot be on different networks

### 2. Backend Server Must Be Running

**Keep your backend running while testing:**

```bash
cd backend
npm run dev
```

**Backend must show:**
```
✅ Server running in development mode
📡 Listening on http://localhost:5000
```

### 3. Firewall Settings

**Windows Firewall might block connections:**

**Quick Fix:**
1. Temporarily disable Windows Firewall
2. Test if it works
3. If it works, add firewall rule for port 5000

**Permanent Fix:**
1. Windows Defender Firewall → Advanced Settings
2. Inbound Rules → New Rule
3. Port → TCP → Port 5000
4. Allow connection
5. Apply to all profiles

## 🧪 Test Steps

### Step 1: Verify Backend is Running

```bash
cd backend
npm run dev
```

Wait for: "Server running in development mode on port 5000"

### Step 2: Test from Your Phone Browser

**On your phone's browser, go to:**
```
http://192.168.1.11:5000/health
```

**Should show:**
```json
{"success": true, "message": "Server is healthy", ...}
```

**If this doesn't work:**
- Check firewall
- Verify phone and computer on same WiFi
- Check backend is running

### Step 3: Test in Your Flutter App

1. **Rebuild the app** (since we changed the API URL):
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Try signing up** - should work now!

## 🔍 Troubleshooting

### Phone Browser Can't Connect

**Error:** "This site can't be reached"

**Check:**
1. ✅ Backend is running (`npm run dev`)
2. ✅ Phone and computer on same WiFi
3. ✅ Firewall allows port 5000
4. ✅ IP address is correct (192.168.1.11)

**Test:**
- Open `http://192.168.1.11:5000/health` in phone browser
- Should show JSON response

### App Still Shows Timeout

**If phone browser works but app doesn't:**

1. **Rebuild app** (API URL changed):
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check API URL in app:**
   - Should be: `http://192.168.1.11:5000/api`
   - Not: `http://10.0.2.2:5000/api`

### IP Address Changed

**If your computer gets a different IP:**

1. **Find new IP:**
   ```bash
   ipconfig
   ```
   Look for IPv4 Address (usually 192.168.x.x from WiFi adapter)

2. **Update in code:**
   - Edit `lib/core/constants/api_constants.dart`
   - Change `computerIP = '192.168.1.11'` to your new IP

3. **Rebuild app:**
   ```bash
   flutter clean
   flutter run
   ```

## ✅ Current Configuration

- **Your Computer's IP:** `192.168.1.11`
- **Backend URL:** `http://192.168.1.11:5000/api`
- **Backend Port:** `5000`

## 🚀 Quick Start

1. **Start backend:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Verify on phone browser:**
   - Go to: `http://192.168.1.11:5000/health`
   - Should work!

3. **Rebuild and run Flutter app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Try sign up** - should work now! 🎉

## 📝 Summary

- ✅ App now uses your computer's IP (192.168.1.11) instead of emulator IP
- ✅ Works on physical Android devices
- ✅ Make sure phone and computer on same WiFi
- ✅ Check firewall allows port 5000
- ✅ Rebuild app after changes

Your app is now configured for physical device testing! 📱

