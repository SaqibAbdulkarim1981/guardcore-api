# 📱 GuardCore Mobile APK - Network Setup Guide

## ✅ Build Complete

Your debug APK has been generated and is ready for installation!

**APK Location:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🌐 Network Configuration

### Your Backend API Details
- **Backend URL:** `http://10.0.0.208:5000/api`
- **Port:** `5000`
- **Protocol:** HTTP (for local development)

### Your Computer's IP Addresses
- **Local Network:** `10.0.0.208` ✅ (Configured in API)
- **VPN/Hyper-V:** `100.77.136.91`
- **VirtualBox:** `192.168.56.1`

---

## 🚀 Installation Steps

### Step 1: Start Your Backend API

Open a terminal and run:
```bash
cd SecurityGuardApi
dotnet run
```

**Verify backend is accessible:**
```bash
curl http://10.0.0.208:5000/api/Users
```

You should see JSON output or authentication error (which is normal).

### Step 2: Configure Windows Firewall

**Allow incoming connections on port 5000:**

1. Open PowerShell as Administrator
2. Run this command:
```powershell
New-NetFirewallRule -DisplayName "GuardCore API" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
```

**Or manually:**
1. Open Windows Defender Firewall → Advanced Settings
2. Click "Inbound Rules"
3. Click "New Rule..."
4. Select "Port" → Next
5. Select TCP, enter "5000" → Next
6. Allow the connection → Next
7. Apply to all profiles → Next
8. Name: "GuardCore API" → Finish

### Step 3: Install APK on Android Device

**Method A: USB Transfer**
1. Connect phone to computer via USB
2. Copy APK to phone:
   ```powershell
   # Copy to Downloads folder (adjust path for your device)
   adb push "build/app/outputs/flutter-apk/app-debug.apk" /sdcard/Download/
   ```
3. On phone: Open Files app → Downloads
4. Tap `app-debug.apk`
5. Allow installation from unknown sources if prompted
6. Install the app

**Method B: ADB Install (Recommended)**
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

**Method C: Cloud Storage**
1. Upload APK to Google Drive / Dropbox
2. Download on phone
3. Install from Downloads folder

---

## 📱 Testing the Connection

### Test 1: Ensure Device is on Same Network

**On your Android phone:**
1. Go to Settings → Wi-Fi
2. Connect to the **same Wi-Fi network** as your computer
3. Note: Mobile data won't work for local testing!

### Test 2: Test Backend Connectivity

**Option A: Using Browser on Phone**
1. Open Chrome on your Android phone
2. Navigate to: `http://10.0.0.208:5000/api/Users`
3. You should see JSON response or authentication error

**Option B: Ping Test (if available)**
```bash
# On phone's terminal app (like Termux)
ping 10.0.0.208
```

### Test 3: Launch GuardCore App

1. Open GuardCore app on phone
2. You should see the login screen
3. Try logging in with test credentials
4. Watch backend console for incoming requests

---

## 🐛 Troubleshooting

### ❌ Cannot Connect to Backend

**Problem:** App shows "Connection Error" or timeout

**Solutions:**

1. **Verify backend is running:**
   ```bash
   netstat -an | findstr :5000
   # Should show LISTENING
   ```

2. **Check Windows Firewall:**
   ```powershell
   Get-NetFirewallRule -DisplayName "GuardCore API"
   # Should show Enabled = True
   ```

3. **Verify IP address is correct:**
   ```bash
   ipconfig | findstr "10.0.0"
   # Confirm 10.0.0.208 is still your IP
   ```

4. **Test from another computer on same network:**
   ```bash
   curl http://10.0.0.208:5000/api/Users
   ```

5. **Temporarily disable firewall (testing only):**
   - Windows Security → Firewall → Turn off
   - Test app
   - Turn firewall back on
   - Add proper rule

### ❌ "Trust Anchor Not Found" or SSL Error

**Problem:** App shows SSL certificate error

**Solution:** API is configured to use HTTP (not HTTPS) for local development. This is normal and expected.

If you see this error, verify `api_config.dart` uses `http://` not `https://`.

### ❌ App Installs but Crashes Immediately

**Problem:** App crashes on startup

**Solutions:**

1. **Check device logs:**
   ```bash
   adb logcat | findstr "Flutter"
   ```

2. **Verify Firebase configuration:**
   - Firebase is optional for local testing
   - App should handle Firebase init errors gracefully

3. **Rebuild with more verbose output:**
   ```bash
   flutter build apk --debug --verbose
   ```

### ❌ Backend Returns 401 Unauthorized

**Problem:** App connects but login fails

**Solutions:**

1. **Verify admin user exists:**
   - Check database for admin@example.com user
   - Password hash should be BCrypt hashed "admin123"

2. **Create test user via admin app:**
   - Set `USE_MOBILE_APP = false` in main.dart
   - Run admin app: `flutter run -d windows`
   - Create test guard user

3. **Check JWT configuration:**
   - Ensure appsettings.json has JWT secret
   - Token should be generated on login

---

## 🔧 Advanced Configuration

### Change API Endpoint

If you need to use a different IP or port:

1. Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:YOUR_PORT/api';
```

2. Rebuild APK:
```bash
flutter build apk --debug
```

### Use with Production Server

1. Get your production server URL (e.g., `https://api.guardcore.com`)
2. Update `api_config.dart`:
```dart
static const String baseUrl = 'https://api.guardcore.com/api';
```
3. Build release APK:
```bash
flutter build apk --release
```

### Network Debugging

Enable network logging:

1. Edit `lib/services/api_service.dart`
2. All API calls already have `debugPrint` statements
3. View logs: `adb logcat | findstr "API\|Flutter"`

---

## 📊 Test Checklist

Use this checklist to verify everything works:

- [ ] Backend API is running on port 5000
- [ ] Firewall allows port 5000
- [ ] Phone connected to same Wi-Fi as computer
- [ ] Can access `http://10.0.0.208:5000/api/Users` from phone browser
- [ ] APK installed successfully on phone
- [ ] GuardCore app opens without crashing
- [ ] Login screen appears
- [ ] Can login with test credentials
- [ ] Backend console shows incoming requests
- [ ] Can scan QR codes (requires camera permission)
- [ ] Can submit activity reports
- [ ] Can submit incident reports
- [ ] Can change password

---

## 📱 Device Requirements

**Minimum Requirements:**
- Android 5.0 (API level 21) or higher
- Camera (for QR scanning)
- Internet permission
- Storage permission

**Recommended:**
- Android 8.0 or higher
- 2GB RAM minimum
- Stable Wi-Fi connection

---

## 🎯 Quick Start Command Summary

```bash
# 1. Start backend
cd SecurityGuardApi
dotnet run

# 2. Allow firewall (as Administrator)
New-NetFirewallRule -DisplayName "GuardCore API" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow

# 3. Install on device
adb install build/app/outputs/flutter-apk/app-debug.apk

# 4. Test backend from phone browser
# Navigate to: http://10.0.0.208:5000/api/Users

# 5. Launch app and login!
```

---

## 📞 Still Having Issues?

1. **Check backend console** - Look for error messages
2. **Check app logs** - Run `adb logcat | findstr "Flutter"`
3. **Verify network** - Ensure same WiFi, no VPN
4. **Test API manually** - Use Postman or browser from phone
5. **Rebuild clean** - `flutter clean && flutter build apk --debug`

---

## ✅ Success Indicators

When everything is working correctly:

1. **Backend Console Shows:**
   ```
   🔐 Attempting login to: http://10.0.0.208:5000/api/Auth/login
   ✅ Login successful! Token received.
   ```

2. **Phone Shows:**
   - Login screen with GuardCore branding
   - Successful login → Home screen
   - 4 menu cards (QR Scanner, Activity Report, Incident Report, Password Reset)

3. **Network Traffic:**
   - Backend receives POST /api/Auth/login
   - Backend receives GET /api/Users/me
   - Backend receives POST /api/Attendance (when scanning QR)

---

**Your GuardCore mobile app is ready for field testing!** 📱✨
