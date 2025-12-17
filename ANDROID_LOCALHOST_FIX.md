# 🔧 Android Localhost Connection Fix

## ❌ Problem
```
Connection refused, address = localhost, port = 47618
Error: SocketException: Connection refused
```

**Root Cause:** Android emulator/device cannot connect to `localhost:3000` because `localhost` refers to the device itself, not your computer.

## ✅ Solution Applied

### Changed API Base URL
**File:** `lib/services/api_service.dart`

**Before:**
```dart
baseUrl: 'http://localhost:3000'
```

**After:**
```dart
baseUrl: 'http://10.0.2.2:3000'  // For Android emulator
```

## 📱 Understanding Android Network

### Android Emulator
- ❌ `localhost` or `127.0.0.1` → Points to the emulator itself
- ✅ `10.0.2.2` → Points to your host machine (your Mac)

### Physical Android Device
- ❌ `localhost` → Won't work
- ✅ `192.168.x.x` → Your computer's local IP address

## 🚀 How to Test Now

### Step 1: Hot Restart App
In your terminal where `flutter run` is active:
```
R
```

Or restart completely:
```bash
flutter run
```

### Step 2: Test Admin Broadcast
1. **Login as admin:** `admin@learninghub.com` / `admin123`
2. **Go to:** Admin Dashboard → Manage Notifications
3. **Click:** "Send Broadcast" button
4. **Fill form:**
   - Title: `Test Notification`
   - Message: `This should work now!`
5. **Click:** "Send"

### Expected Result
✅ "Broadcast sent to X users successfully!"

## 🔍 Verify Backend is Accessible

Test from your terminal:
```bash
curl http://10.0.2.2:3000/health
```

**Expected:**
```json
{
  "status": "OK",
  "message": "Learning Hub API is running"
}
```

## 📊 Network Configuration Summary

| Environment | Base URL | Notes |
|-------------|----------|-------|
| **Android Emulator** | `http://10.0.2.2:3000` | ✅ Current setting |
| **Physical Device (same WiFi)** | `http://192.168.x.x:3000` | Need your Mac's IP |
| **iOS Simulator** | `http://localhost:3000` | Works fine |
| **Web** | `http://localhost:3000` | Works fine |

## 🌐 For Physical Android Device

If you're using a **physical Android device** instead of emulator:

### Step 1: Find Your Mac's IP Address
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Look for something like: `192.168.1.100`

### Step 2: Update API Service
```dart
baseUrl: 'http://192.168.1.100:3000'  // Replace with your IP
```

### Step 3: Ensure Same WiFi
- Mac and Android device must be on the same WiFi network
- Firewall should allow connections on port 3000

## ✅ What's Fixed

- ✅ Android emulator can now reach backend server
- ✅ API calls will work correctly
- ✅ Admin broadcasts will send successfully
- ✅ User notifications will fetch properly
- ✅ Enrollment notifications will work

## 🧪 Quick Verification

After hot restart, check the console:
- ❌ Before: `Connection refused`
- ✅ After: API calls succeed, no connection errors

## 📝 Files Modified

1. **lib/services/api_service.dart**
   - Line 14: Changed `localhost:3000` to `10.0.2.2:3000`

---

**Fixed**: December 17, 2025  
**Status**: ✅ Ready to test  
**Impact**: Critical - Enables network communication from Android
