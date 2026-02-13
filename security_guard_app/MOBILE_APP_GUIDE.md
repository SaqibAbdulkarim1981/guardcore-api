# GuardCore Mobile App - Complete Guide

## 📱 Mobile App Features

### For Security Guards:
1. **Email Invitation System**
   - Guards receive email with temporary password
   - Link to download app from Play Store / App Store
   - First-time login requires password creation

2. **Authentication**
   - Login with email and password
   - Password reset functionality
   - Auto-logout when access expires

3. **QR Code Scanning**
   - Scan patrol point QR codes
   - Automatic check-in/check-out tracking
   - Attendance stored in backend database

4. **Report Forms**
   - **Activity Report**: Log daily activities, shift details, observations
   - **Incident Report**: Report security incidents with severity levels
   - Both forms save to database with timestamp

5. **Access Control**
   - Time-based access (set by admin)
   - Automatic blocking after expiry date
   - "Access Expired" screen with contact info

---

## 🏗️ Architecture

### Frontend (Flutter Mobile)
- **Location**: `lib/mobile/`
- **Screens**:
  - `guard_login.dart` - Guard authentication
  - `guard_home.dart` - Main navigation menu
  - `qr_scanner.dart` - QR code scanner with camera
  - `activity_report_form.dart` - Activity logging form
  - `incident_report_form.dart` - Incident reporting form
  - `guard_password_reset.dart` - Password change
  - `guard_access_expired.dart` - Expiry notification

### Backend (ASP.NET Core)
- **New Endpoints**:
  - `GET /api/Users/me` - Get current user info
  - `POST /api/Users/reset-password` - Change password
  - `POST /api/Attendance` - Record check-in/check-out
  - `GET /api/Attendance` - View all attendance records
  - `GET /api/Attendance/user/{userId}` - User-specific attendance

### Database
- **New Table**: `Attendances`
  - Id, UserId, LocationId, Type (CheckIn/CheckOut), Timestamp, QRData

---

## 🚀 Building for Android & iOS

### 1. Install Dependencies
```bash
cd security_guard_app
flutter pub get
```

### 2. Build Android APK
```bash
# Debug APK
flutter build apk --debug

# Release APK (optimized)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 3. Build Android App Bundle (for Play Store)
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 4. Build iOS (requires macOS)
```bash
# Open in Xcode
flutter build ios --release
open ios/Runner.xcworkspace

# Or build IPA directly
flutter build ipa --release

# Output: build/ios/ipa/GuardCore.ipa
```

---

## 📲 Publishing to Stores

### Google Play Store (Android)
1. Create developer account ($25 one-time fee)
2. Upload `app-release.aab` file
3. Fill app details (description, screenshots, category)
4. Set privacy policy and content rating
5. Submit for review (1-7 days)

**Download Link Example**: `https://play.google.com/store/apps/details?id=com.yourcompany.guardcore`

### Apple App Store (iOS)
1. Create Apple Developer account ($99/year)
2. Generate certificates and provisioning profiles
3. Upload `GuardCore.ipa` via Xcode or App Store Connect
4. Fill app metadata and screenshots
5. Submit for review (1-3 days)

**Download Link Example**: `https://apps.apple.com/app/guardcore/id1234567890`

---

## 🔄 Backend Updates Required

### 1. Add Migration for Attendance Table
```bash
cd SecurityGuardApi
dotnet ef migrations add AddAttendanceTable
dotnet ef database update
```

### 2. Restart Backend API
```bash
dotnet run
```

### 3. Test New Endpoints
```powershell
# Get current user
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:5000/api/Users/me

# Record attendance
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"QRData":"1","Timestamp":"2026-02-10T10:00:00Z"}' \
  http://localhost:5000/api/Attendance
```

---

## 📧 User Onboarding Flow

### Admin Side (Super Admin App):
1. Navigate to "Guard Management"
2. Click "Create New Guard"
3. Enter: Name, Email, Active Days (e.g., 30)
4. Click "Create & Send Invite"
5. Email sent to guard with:
   - Temporary password or signup link
   - App download links (Play Store / App Store)
   - Welcome instructions

### Guard Side (Mobile App):
1. Download GuardCore from store
2. Open app, enter email from invitation
3. Create/set password on first login
4. Access granted for specified days
5. After expiry, see "Access Expired" screen

---

## 🎨 App Branding

### Current Settings:
- **App Name**: GuardCore
- **Version**: 1.0.0.0
- **Subtitle**: Security Guard Portal
- **Colors**: Blue gradient theme with orange accents
- **Icons**: Security badge, shield, QR scanner

### To Customize:
- **Android**: Update `android/app/src/main/AndroidManifest.xml` (label)
- **iOS**: Update `ios/Runner/Info.plist` (CFBundleDisplayName)
- **App Icon**: Replace `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS Icon**: Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 🔐 Security Checklist

Before publishing:
- [ ] Change JWT secret key to production value (256-bit)
- [ ] Use HTTPS for backend API
- [ ] Store passwords with bcrypt/PBKDF2 hashing
- [ ] Implement rate limiting for API endpoints
- [ ] Add input validation on all forms
- [ ] Enable SSL certificate pinning
- [ ] Obfuscate Flutter code: `flutter build apk --obfuscate --split-debug-info=./debug-info`
- [ ] Set up Firebase Cloud Messaging for push notifications
- [ ] Configure proper error logging (Sentry, Firebase Crashlytics)

---

## 📊 Database Schema Updates

New `Attendances` table:
```sql
CREATE TABLE Attendances (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId INTEGER NOT NULL,
    LocationId INTEGER NOT NULL,
    Type TEXT NOT NULL, -- 'CheckIn' or 'CheckOut'
    Timestamp DATETIME NOT NULL,
    QRData TEXT,
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (LocationId) REFERENCES Locations(Id)
);
```

---

## 🧪 Testing Guide

### 1. Test Guard Login
- Email: Create a guard user via admin app
- Login on mobile app
- Verify home screen loads

### 2. Test QR Scanner
- Print QR code from "Patrol Points" screen
- Scan with mobile app
- Check backend logs for attendance record

### 3. Test Reports
- Fill Activity Report form
- Fill Incident Report form
- Verify data appears in admin Reports screen

### 4. Test Access Expiry
- Create guard with 1-day access
- Change system date to tomorrow
- Login should show "Access Expired" screen

---

## 📱 App Store Listings

### App Description Template:
```
GuardCore - Professional Security Guard Management

GuardCore is the essential mobile companion for professional security guards. Stay connected, report incidents, and track your patrol activities with ease.

Features:
✓ QR Code Check-In/Out at patrol points
✓ Activity & Incident Report Forms
✓ Secure authentication with password reset
✓ Time-based access control
✓ Real-time synchronization with admin dashboard

Perfect for security companies managing field guards across multiple locations.
```

### Screenshots Needed:
1. Login screen
2. Home menu (4 tiles)
3. QR scanner in action
4. Activity report form
5. Incident report form

---

## 🌐 Production Deployment URLs

Update `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Change to production API
  static const String baseUrl = 'https://guardcore-api.yourdomain.com/api';
  
  // Remove admin credentials in production
  static const int timeoutSeconds = 15;
}
```

---

## 📦 Required Packages

Already added to `pubspec.yaml`:
- `mobile_scanner: ^5.0.0` - QR code scanning
- `http: ^1.1.0` - API communication
- `provider: ^6.1.2` - State management
- `firebase_core` - Firebase integration (optional)
- `firebase_auth` - Email/password authentication

---

## 🎯 Next Steps

1. **Run Flutter pub get**: `flutter pub get`
2. **Test on emulator**: `flutter run`
3. **Create backend migration**: `dotnet ef migrations add AddAttendanceTable`
4. **Build APK**: `flutter build apk --release`
5. **Test on physical device**: Install APK and test all features
6. **Set up app store accounts**: Google Play Console + Apple Developer
7. **Prepare store listings**: Screenshots, description, privacy policy
8. **Submit for review**: Upload builds and wait for approval
9. **Distribute download links**: Update invitation emails with store URLs

---

## 💡 Tips

- **Testing without stores**: Use Firebase App Distribution or TestFlight
- **Beta testing**: Start with closed beta (friends/colleagues)
- **Analytics**: Add Firebase Analytics to track user behavior
- **Crash reporting**: Implement Firebase Crashlytics for production
- **Push notifications**: Alert guards of urgent updates/messages
- **Offline mode**: Store reports locally, sync when online

---

## 🆘 Support & Maintenance

### For Guards:
- Contact supervisor if access expired
- Report bugs via in-app feedback form
- Check app updates regularly

### For Admins:
- Monitor attendance records in admin dashboard
- Review submitted reports
- Manage guard access periods
- Generate analytics reports

---

**GuardCore v1.0.0.0**
*Built with Flutter & ASP.NET Core*
