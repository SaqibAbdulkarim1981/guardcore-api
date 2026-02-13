# Quick Start Guide - GuardCore

## 🚀 Running the Apps

GuardCore consists of TWO apps:
1. **Super Admin App** (Windows Desktop) - For administrators
2. **Guard Mobile App** (Android/iOS) - For security guards

---

## 🖥️ Super Admin App (Current Setup)

### Run Desktop App:
```bash
flutter run -d windows
```

### Features:
- User management
- Location/QR code generation
- Reports dashboard
- Settings

### Default Login:
- Email: `admin@example.com`
- Password: `admin123`

---

## 📱 Guard Mobile App (New)

### Option 1: Use Guard App Standalone

**Create New main.dart**:
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'mobile/guard_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: const GuardMobileApp(),
    ),
  );
}
```

### Option 2: Switch Between Apps

**Create Launcher Screen**:
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'mobile/guard_main.dart';
import 'screens/login.dart'; // Admin login

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: const AppLauncher(),
    ),
  );
}

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GuardCore',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GuardMobileApp(),
                    ),
                  );
                },
                child: const Text('Guard App'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Admin App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🧪 Testing Mobile App

### 1. Start Backend API:
```bash
cd SecurityGuardApi
dotnet run
# Backend runs on http://localhost:5000
```

### 2. Run Mobile App on Android Emulator:
```bash
flutter run
```

### 3. Create Test Guard User:
1. Run admin app: `flutter run -d windows`
2. Navigate to "Guard Management"
3. Click "Create New Guard"
4. Enter:
   - Name: Test Guard
   - Email: guard@test.com
   - Active Days: 30
5. Note the credentials

### 4. Login as Guard:
1. Open mobile app
2. Use guard@test.com credentials
3. Explore home screen

---

## 📲 Testing on Physical Android Device

### Setup:
1. Enable Developer Options on phone:
   - Settings → About Phone → Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging
3. Connect phone via USB

### Get Computer IP:
```powershell
ipconfig
# Find IPv4 Address (e.g., 192.168.1.100)
```

### Update API Config:
```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

### Run on Device:
```bash
flutter devices
# Shows connected devices

flutter run -d YOUR_DEVICE_ID
```

---

## 🏗️ Build APK for Testing

### Debug APK (Fast):
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
# Size: ~40 MB
```

### Release APK (Optimized):
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
# Size: ~25 MB
```

### Install APK:
1. Copy APK to phone
2. Open file manager on phone
3. Tap APK file
4. Allow installation from unknown sources
5. Install and open

---

## 🔧 Configure for Different Environments

### Development (Local):
```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://localhost:5000/api';
```

### Testing (Physical Device):
```dart
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

### Production:
```dart
static const String baseUrl = 'https://api.guardcore.com/api';
```

---

## 🧩 Project Structure

```
security_guard_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   └── api_config.dart       # API URLs and settings
│   ├── models/
│   │   └── user.dart             # Data models
│   ├── services/
│   │   ├── api_service.dart      # API client
│   │   ├── firebase_service.dart
│   │   └── mock_service.dart
│   ├── screens/                  # Admin screens
│   │   ├── login.dart
│   │   ├── dashboard.dart
│   │   ├── users.dart
│   │   ├── locations.dart
│   │   └── reports.dart
│   ├── mobile/                   # Guard mobile app
│   │   ├── guard_main.dart       # Mobile app entry
│   │   └── screens/
│   │       ├── guard_login.dart
│   │       ├── guard_home.dart
│   │       ├── qr_scanner.dart
│   │       ├── activity_report_form.dart
│   │       ├── incident_report_form.dart
│   │       ├── guard_password_reset.dart
│   │       └── guard_access_expired.dart
│   └── widgets/
│       ├── common_appbar.dart
│       └── primary_button.dart
├── SecurityGuardApi/             # Backend API
│   ├── Controllers/
│   │   ├── AuthController.cs
│   │   ├── UsersController.cs
│   │   ├── LocationsController.cs
│   │   ├── ReportsController.cs
│   │   └── AttendanceController.cs
│   ├── Models/
│   │   ├── User.cs
│   │   ├── Location.cs
│   │   ├── Report.cs
│   │   └── Attendance.cs
│   ├── Data/
│   │   └── AppDbContext.cs
│   └── securityguard.db          # SQLite database
└── Documentation/
    ├── MOBILE_APP_GUIDE.md
    ├── IMPLEMENTATION_SUMMARY.md
    └── QUICK_START.md (this file)
```

---

## ✅ Checklist Before Testing

- [ ] Backend API running (`dotnet run`)
- [ ] Database updated (`dotnet ef database update`)
- [ ] Flutter packages installed (`flutter pub get`)
- [ ] API URL configured correctly
- [ ] Test user created via admin app
- [ ] Android emulator/device ready
- [ ] Camera permissions granted (for QR scanning)

---

## 🐛 Troubleshooting

### Problem: "Connection refused" error
**Solution**: Check API URL and ensure backend is running

### Problem: QR Scanner not working
**Solution**: Grant camera permission in app settings

### Problem: Login fails
**Solution**: Verify user exists in database and credentials are correct

### Problem: "Cannot connect to localhost" on physical device
**Solution**: Use computer's IP address instead of localhost

### Problem: Build errors
**Solution**: Run `flutter clean` then `flutter pub get`

---

## 📝 Testing Scenarios

### Scenario 1: Complete Guard Workflow
1. Admin creates guard user
2. Guard receives credentials
3. Guard downloads and installs app
4. Guard logs in
5. Guard scans QR code at patrol point
6. Guard fills activity report
7. Guard logs out

### Scenario 2: Access Expiry
1. Admin creates guard with 1-day access
2. Guard logs in successfully
3. Admin changes expiry date to yesterday
4. Guard tries to login → sees "Access Expired"

### Scenario 3: Incident Reporting
1. Guard logs in
2. Guard witnesses incident
3. Guard fills incident report form
4. Guard submits report
5. Admin sees report in dashboard

---

## 🎯 Next Actions

1. **Test mobile app**: `flutter run`
2. **Create test users**: Use admin app
3. **Test QR scanning**: Print QR codes
4. **Test all forms**: Submit reports
5. **Build APK**: Share with team for testing

---

## 💡 Tips

- Use Android Studio's Virtual Device Manager for emulators
- Keep backend terminal open for debug logs
- Use Flutter DevTools for debugging: `flutter pub global activate devtools`
- Enable hot reload (press 'r' in terminal) for faster development
- Check backend logs when API calls fail

---

## 🌐 URLs Reference

- **Backend API**: http://localhost:5000
- **Swagger Docs**: http://localhost:5000/swagger
- **Admin App**: Windows desktop (flutter run -d windows)
- **Mobile App**: Android/iOS (flutter run)
- **DevTools**: Shown when app runs

---

## 📞 Need Help?

Check these files:
- `MOBILE_APP_GUIDE.md` - Detailed mobile app documentation
- `IMPLEMENTATION_SUMMARY.md` - What was built and how
- `DEPLOYMENT_GUIDE.md` - Backend deployment instructions

---

**GuardCore v1.0.0.0**
*Ready for Testing!*
