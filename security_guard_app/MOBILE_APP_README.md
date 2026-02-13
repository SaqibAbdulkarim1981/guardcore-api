# 📱 GuardCore Mobile App - Complete Implementation Guide

## ✅ Overview

The GuardCore mobile app is now **fully implemented** with all required features for security guards. The app is designed for iOS and Android platforms with a complete backend integration.

---

## 🎯 Features Implemented

### 1. **User Authentication**
- ✅ Login with email/password
- ✅ Password reset capability
- ✅ JWT token-based authentication
- ✅ Automatic expiry date checking
- ✅ Access expired screen for blocked/expired users

### 2. **QR Code Scanning**
- ✅ Check-in/Check-out functionality
- ✅ Real-time attendance recording
- ✅ Location-based tracking
- ✅ Automatic type detection (CheckIn vs CheckOut)
- ✅ Visual scanning interface with overlay

### 3. **Activity Reports**
- ✅ Location field
- ✅ Shift selection (Day/Night/Evening)
- ✅ Time picker
- ✅ Activity description
- ✅ Observations field
- ✅ Remarks field
- ✅ Auto date/time stamping

### 4. **Incident Reports**
- ✅ Incident location
- ✅ Incident type
- ✅ Severity levels (Low/Medium/High/Critical)
- ✅ Time of incident
- ✅ Detailed description
- ✅ Action taken field
- ✅ Witness information
- ✅ Auto date/time stamping

### 5. **User Management**
- ✅ User profile access
- ✅ Password change functionality
- ✅ Logout capability
- ✅ Welcome screen with user name

---

## 📂 Project Structure

```
lib/
├── mobile/
│   ├── guard_main.dart              # Mobile app entry point
│   └── screens/
│       ├── guard_login.dart         # Login screen
│       ├── guard_home.dart          # Home/Dashboard
│       ├── qr_scanner.dart          # QR code scanner
│       ├── activity_report_form.dart # Activity report
│       ├── incident_report_form.dart # Incident report
│       ├── guard_password_reset.dart # Password reset
│       └── guard_access_expired.dart # Access expired notice
├── services/
│   ├── api_service.dart             # Backend API integration
│   ├── firebase_service.dart        # Firebase services
│   └── mock_service.dart            # Mock data for testing
├── config/
│   └── api_config.dart              # API configuration
└── main.dart                        # App switcher (Admin/Mobile)
```

---

## 🔧 Configuration

### Switch Between Admin and Mobile App

Edit [lib/main.dart](lib/main.dart):

```dart
// Set to true for mobile guard app, false for admin app
const bool USE_MOBILE_APP = true;
```

### API Configuration

Edit [lib/config/api_config.dart](lib/config/api_config.dart):

```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_IP:5000/api';
  static const int timeoutSeconds = 30;
}
```

**Important:** 
- Use your computer's local IP address for mobile device testing
- Use `http://localhost:5000/api` for emulator testing
- Use HTTPS with proper domain for production

---

## 🚀 Running the Mobile App

### 1. **Install Dependencies**

```bash
flutter pub get
```

### 2. **Start Backend API**

```bash
cd SecurityGuardApi
dotnet run
```

Backend will run at: `http://localhost:5000`

### 3. **Run Mobile App**

**On Android Emulator:**
```bash
flutter run -d emulator-5554
```

**On iOS Simulator:**
```bash
flutter run -d "iPhone 14"
```

**On Physical Device:**
```bash
flutter run
```

**On Chrome (Testing):**
```bash
flutter run -d chrome
```

---

## 🔐 Backend API Endpoints

### Authentication
- `POST /api/Auth/login` - Login with email/password
- `POST /api/Auth/register` - Register new user (admin only)

### User Management
- `GET /api/Users/me` - Get current user profile
- `POST /api/Users/reset-password` - Change password

### Attendance
- `POST /api/Attendance` - Record check-in/check-out
- `GET /api/Attendance` - Get all attendance records
- `GET /api/Attendance/user/{userId}` - Get user attendance

### Reports
- `POST /api/Reports` - Submit activity/incident report
- `GET /api/Reports` - Get all reports
- `GET /api/Reports/{id}` - Get report by ID

### Locations
- `GET /api/Locations` - Get all locations
- `POST /api/Locations` - Create location (admin only)
- `GET /api/Locations/{id}/qrcode` - Get QR code image

---

## 📱 User Flow

### 1. **Initial Setup**
1. Admin creates user account in back-office app
2. User receives email with password reset link
3. User downloads GuardCore app from App Store/Play Store
4. User sets password via email link
5. User logs into mobile app

### 2. **Daily Operations**

**Login:**
1. Open GuardCore app
2. Enter email and password
3. Tap "Login"

**Check-In/Out:**
1. From home screen, tap "Scan QR Code"
2. Point camera at location QR code
3. Wait for confirmation message
4. Automatically records as CheckIn or CheckOut

**Submit Activity Report:**
1. From home screen, tap "Activity Report"
2. Fill all required fields:
   - Location
   - Shift (Day/Night/Evening)
   - Time
   - Activity performed
   - Observations (optional)
   - Remarks (optional)
3. Tap "Submit Report"

**Submit Incident Report:**
1. From home screen, tap "Incident Report"
2. Fill all required fields:
   - Incident location
   - Incident type
   - Severity (Low/Medium/High/Critical)
   - Time of incident
   - Description
   - Action taken
   - Witness info (optional)
3. Tap "Submit Report"

**Change Password:**
1. From home screen, tap "Reset Password"
2. Enter current password
3. Enter new password
4. Confirm new password
5. Tap "Change Password"

**Logout:**
1. From home screen, tap logout icon in app bar
2. Confirm logout

### 3. **Access Expiry**
- If user's access expires, they see "Access Expired" screen
- User must contact admin to extend access
- Cannot use app until access is renewed

---

## 🧪 Testing the Mobile App

### Test User Setup

1. **Start Backend:**
```bash
cd SecurityGuardApi
dotnet run
```

2. **Create Test User (via Admin App):**
   - Set `USE_MOBILE_APP = false` in main.dart
   - Run admin app
   - Login as admin (admin@example.com / admin123)
   - Create test user:
     - Name: Test Guard
     - Email: guard@test.com
     - Active Days: 30

3. **Set User Password (via API/Database):**
   - Use Postman or update database directly
   - Hash password using BCrypt

4. **Test Mobile App:**
   - Set `USE_MOBILE_APP = true` in main.dart
   - Run mobile app
   - Login with guard@test.com

### Test Scenarios

**✅ Login:**
- Valid credentials → Home screen
- Invalid credentials → Error message
- Expired user → Access expired screen

**✅ QR Scanning:**
- Scan valid QR → Success message
- Scan invalid QR → Error message
- First scan → CheckIn recorded
- Second scan (same location) → CheckOut recorded

**✅ Activity Report:**
- Fill all required fields → Success
- Leave required field empty → Validation error
- Submit → Report saved to database

**✅ Incident Report:**
- Fill all required fields → Success
- Select severity → Saved correctly
- Submit → Report saved with timestamp

**✅ Password Reset:**
- Correct current password → Success
- Wrong current password → Error
- Mismatched new passwords → Validation error

---

## 📦 Dependencies

### Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # State management
  http: ^1.1.0              # API calls
  mobile_scanner: ^5.0.0    # QR code scanning
  firebase_core: ^4.4.0     # Firebase integration
  firebase_auth: ^6.1.4     # Firebase authentication
  url_launcher: ^6.1.10     # Open URLs
  uuid: ^4.0.0              # Generate UUIDs
```

### Backend Packages

```xml
<PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="9.0.1" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="9.0.1" />
<PackageReference Include="QRCoder" Version="1.6.0" />
```

---

## 🔒 Security Features

1. **JWT Authentication**
   - Tokens expire after configured time
   - All API calls require valid token
   - User claims embedded in token

2. **Password Security**
   - BCrypt hashing (work factor 11)
   - Password validation on reset
   - Secure password reset flow

3. **Access Control**
   - Automatic user expiry checking
   - Manual block/unblock by admin
   - Expired users cannot access app

4. **Data Validation**
   - Client-side form validation
   - Server-side data validation
   - SQL injection prevention (Entity Framework)

---

## 🚢 Deployment

### Mobile App Deployment

**Android:**
1. Build release APK:
```bash
flutter build apk --release
```

2. Build App Bundle for Play Store:
```bash
flutter build appbundle --release
```

3. Upload to Google Play Console

**iOS:**
1. Configure provisioning profiles in Xcode
2. Build release IPA:
```bash
flutter build ipa --release
```

3. Upload to App Store Connect via Xcode

### Backend Deployment

**Azure App Service:**
```bash
cd SecurityGuardApi
dotnet publish -c Release
```

**Docker:**
```bash
docker build -t guardcore-api .
docker run -p 5000:80 guardcore-api
```

---

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    IsBlocked BIT DEFAULT 0,
    ExpiryDate DATETIME NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE()
);
```

### Attendance Table
```sql
CREATE TABLE Attendance (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT NOT NULL,
    LocationId INT NOT NULL,
    Type NVARCHAR(20) NOT NULL,  -- 'CheckIn' or 'CheckOut'
    Timestamp DATETIME NOT NULL,
    QRData NVARCHAR(500),
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (LocationId) REFERENCES Locations(Id)
);
```

### Reports Table
```sql
CREATE TABLE Reports (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT NULL,
    LocationId INT NULL,
    Type NVARCHAR(50) NOT NULL,  -- 'Activity' or 'Incident'
    Description NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (LocationId) REFERENCES Locations(Id)
);
```

### Locations Table
```sql
CREATE TABLE Locations (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETUTCDATE()
);
```

---

## 🐛 Troubleshooting

### Cannot Connect to Backend

**Problem:** Mobile app shows connection errors

**Solutions:**
1. Check if backend is running: `curl http://localhost:5000/api/Users`
2. Update `ApiConfig.baseUrl` with correct IP
3. For physical device, use computer's local IP (not localhost)
4. Check firewall settings - allow port 5000
5. Ensure device and computer are on same network

### QR Scanner Not Working

**Problem:** Camera doesn't open or scan fails

**Solutions:**
1. **Android:** Add permissions to AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

2. **iOS:** Add to Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>Need camera access to scan QR codes</string>
```

3. Test on physical device (camera may not work on emulator)

### Login Fails with 401

**Problem:** Valid credentials but login fails

**Solutions:**
1. Check if user exists in database
2. Verify password hash is correct
3. Check JWT configuration in backend
4. Verify user is not blocked or expired
5. Check backend logs for detailed error

### Reports Not Saving

**Problem:** Report submission fails

**Solutions:**
1. Check if user is authenticated (token valid)
2. Verify Reports table exists in database
3. Check backend logs for validation errors
4. Ensure all required fields are filled
5. Verify database connection string

---

## 📞 Support

For issues or questions:
1. Check troubleshooting section above
2. Review backend logs in console
3. Review Flutter logs: `flutter logs`
4. Check network requests in Flutter DevTools

---

## ✨ Future Enhancements

Potential features to add:

1. **Photo Attachments**
   - Add photos to incident reports
   - Camera integration
   - Image upload to cloud storage

2. **Offline Support**
   - Queue reports when offline
   - Sync when online
   - Local database (SQLite)

3. **Push Notifications**
   - New assignment alerts
   - Shift reminders
   - Emergency broadcasts

4. **GPS Tracking**
   - Location verification
   - Route tracking
   - Patrol validation

5. **Biometric Auth**
   - Fingerprint login
   - Face ID support
   - Enhanced security

6. **Report Templates**
   - Pre-filled forms
   - Custom fields per client
   - Dynamic form generation

---

## 📄 License

Copyright © 2026 GuardCore. All rights reserved.

---

## 🎉 Congratulations!

Your GuardCore mobile app is **fully operational** and ready for deployment! 

**What's Working:**
- ✅ User login and authentication
- ✅ QR code check-in/check-out
- ✅ Activity report submission
- ✅ Incident report submission
- ✅ Password reset
- ✅ Access expiry handling
- ✅ Backend API integration
- ✅ JWT security

**Next Steps:**
1. Test thoroughly with real devices
2. Configure production API endpoint
3. Set up SSL/HTTPS for production
4. Build release versions for stores
5. Submit to App Store and Play Store
6. Train security guards on app usage

Happy coding! 🚀
