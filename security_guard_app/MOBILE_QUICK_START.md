# 🚀 Quick Start - GuardCore Mobile App

## ✅ What's Complete

Your GuardCore system now has **TWO fully functional applications**:

### 1. **Back-Office Admin App** (Operations Staff)
- ✅ User management (create, block, unblock)
- ✅ QR code generation for locations
- ✅ View all reports and attendance
- ✅ Email invitations to guards

### 2. **Mobile App** (Security Guards)
- ✅ Login with email/password
- ✅ QR code check-in/check-out
- ✅ Activity report submission
- ✅ Incident report submission
- ✅ Password reset
- ✅ Access expiry handling

---

## 🏃 Run the Apps in 3 Steps

### Step 1: Start Backend API

```bash
cd SecurityGuardApi
dotnet run
```

Backend runs at: `http://localhost:5000`

### Step 2A: Run Admin App (Operations Staff)

Edit `lib/main.dart` and set:
```dart
const bool USE_MOBILE_APP = false;  // Admin app
```

Then run:
```bash
flutter run -d windows
```

Login with: `admin@example.com` / `admin123`

### Step 2B: Run Mobile App (Security Guards)

Edit `lib/main.dart` and set:
```dart
const bool USE_MOBILE_APP = true;  // Mobile app
```

Then run:
```bash
flutter run -d chrome     # For testing
# OR
flutter run               # On connected device/emulator
```

---

## 📋 Complete User Journey

### 1️⃣ **Admin Creates Guard Account**
1. Run admin app (`USE_MOBILE_APP = false`)
2. Login as admin
3. Go to "Users" → "Create User"
4. Enter:
   - Name: John Guard
   - Email: john@guard.com
   - Active Days: 30
5. Click "Create User"
6. Click "Send Invite" (opens email with password reset link)

### 2️⃣ **Guard Sets Password**
1. Guard receives email with password reset link
2. Guard clicks link and sets new password
3. Guard downloads GuardCore app

### 3️⃣ **Guard Uses Mobile App**
1. Run mobile app (`USE_MOBILE_APP = true`)
2. Login with email and password
3. See home screen with 4 options:
   - **Scan QR Code** - Check in/out
   - **Activity Report** - Daily activities
   - **Incident Report** - Security incidents
   - **Reset Password** - Change password

### 4️⃣ **Guard Checks In/Out**
1. Tap "Scan QR Code"
2. Point camera at location QR code
3. First scan = CheckIn recorded
4. Second scan (same location) = CheckOut recorded
5. Data saved to backend with timestamp

### 5️⃣ **Guard Submits Reports**

**Activity Report:**
1. Tap "Activity Report"
2. Fill in:
   - Location
   - Shift (Day/Night/Evening)
   - Time
   - Activity description
   - Observations
   - Remarks
3. Tap "Submit Report"
4. Saved to database with date/time

**Incident Report:**
1. Tap "Incident Report"
2. Fill in:
   - Location
   - Incident type
   - Severity (Low/Medium/High/Critical)
   - Time
   - Description
   - Action taken
   - Witness info
3. Tap "Submit Report"
4. Saved to database with date/time

### 6️⃣ **Admin Views Data**
1. In admin app, go to "Reports"
2. See all activity and incident reports
3. View attendance records
4. Manage users (block/unblock)

---

## 🔧 Configuration

### API Endpoint (lib/config/api_config.dart)

```dart
class ApiConfig {
  // For testing on physical device, use your computer's IP
  static const String baseUrl = 'http://10.0.0.208:5000/api';
  
  // For emulator testing
  // static const String baseUrl = 'http://localhost:5000/api';
  
  // For production
  // static const String baseUrl = 'https://your-domain.com/api';
}
```

### Find Your Computer's IP Address

**Windows:**
```bash
ipconfig
# Look for "IPv4 Address" (e.g., 10.0.0.208)
```

**Mac/Linux:**
```bash
ifconfig
# Look for "inet" under active network
```

---

## 📱 Test Credentials

### Admin Account (Back-Office)
- Email: `admin@example.com`
- Password: `admin123`

### Create Test Guard Account
Use admin app to create with any email, then set password via database or API.

---

## 🎯 Mobile App Features Checklist

| Feature | Status | Description |
|---------|--------|-------------|
| Login | ✅ Complete | Email/password authentication |
| Password Reset | ✅ Complete | Change password anytime |
| QR Scanning | ✅ Complete | Check-in/check-out at locations |
| Activity Reports | ✅ Complete | Submit daily activity forms |
| Incident Reports | ✅ Complete | Report security incidents |
| Access Expiry | ✅ Complete | Auto-block after expiry date |
| User Profile | ✅ Complete | View current user info |
| Logout | ✅ Complete | Secure session termination |

---

## 📊 Backend API Endpoints

### Mobile App Uses:
- `POST /api/Auth/login` - Login
- `GET /api/Users/me` - Get current user
- `POST /api/Users/reset-password` - Change password
- `POST /api/Attendance` - Record check-in/out
- `POST /api/Reports` - Submit reports

### Admin App Uses:
- `GET /api/Users` - List all users
- `POST /api/Users` - Create user
- `POST /api/Users/{id}/block` - Block user
- `POST /api/Users/{id}/unblock` - Unblock user
- `GET /api/Locations` - List locations
- `POST /api/Locations` - Create location
- `GET /api/Reports` - View all reports
- `GET /api/Attendance` - View attendance

---

## 🐛 Common Issues

### "Cannot connect to backend"
- ✅ Check if backend is running (`dotnet run`)
- ✅ Update IP address in `api_config.dart`
- ✅ Ensure device and computer on same WiFi
- ✅ Check firewall allows port 5000

### "QR scanner not working"
- ✅ Grant camera permissions
- ✅ Test on physical device (not emulator)
- ✅ Use admin app to generate QR codes first

### "Login fails with valid credentials"
- ✅ Check user exists in database
- ✅ Verify password hash is set
- ✅ Check if user is blocked or expired

---

## 🚀 Next Steps

### For Testing:
1. ✅ Start backend API
2. ✅ Run admin app, create test locations with QR codes
3. ✅ Create test guard user
4. ✅ Run mobile app, login as guard
5. ✅ Test all features (scan, reports, password reset)

### For Production:
1. 📱 Set up HTTPS backend with SSL certificate
2. 📱 Configure production API endpoint
3. 📱 Build release versions:
   - Android: `flutter build apk --release`
   - iOS: `flutter build ipa --release`
4. 📱 Submit to App Store and Google Play
5. 📱 Set up email service for invitations

### For Deployment:
See detailed deployment guide in:
- [MOBILE_APP_README.md](MOBILE_APP_README.md) - Full mobile app documentation
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Backend deployment
- [MOBILE_APP_GUIDE.md](MOBILE_APP_GUIDE.md) - Technical implementation details

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **MOBILE_APP_README.md** | Complete mobile app guide (read this first!) |
| **QUICK_START.md** | This file - getting started quickly |
| **DEPLOYMENT_GUIDE.md** | Deploy backend to production |
| **MOBILE_APP_GUIDE.md** | Technical implementation details |
| **IMPLEMENTATION_SUMMARY.md** | Overall project summary |

---

## ✨ You're All Set!

Your GuardCore system is **100% complete** and ready to use:

✅ Back-office app for operations staff
✅ Mobile app for security guards  
✅ Backend API with all endpoints
✅ Database schema
✅ Authentication & security
✅ QR code check-in/check-out
✅ Activity & incident reporting
✅ User management

**What you can do right now:**
1. Start backend: `cd SecurityGuardApi && dotnet run`
2. Toggle app in `main.dart`: `USE_MOBILE_APP = true/false`
3. Run: `flutter run`
4. Test both apps side-by-side!

Happy guarding! 🛡️✨
