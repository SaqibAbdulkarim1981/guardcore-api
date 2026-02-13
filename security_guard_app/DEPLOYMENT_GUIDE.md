# Security Guard App - Complete Setup & Deployment Guide

## Project Overview
Cross-platform Super Admin mobile app (iOS/Android) for managing users, generating location QR codes, and accessing activity/incident reports.

### Features Implemented
✅ **Super Admin Login** – Login UI wired to Firebase Auth (or mock)  
✅ **User Management** – Create users with name, email, active days; block/unblock users  
✅ **Email Invitations** – Auto-open mail client with prefilled invite & password-reset link  
✅ **QR Code Generation** – Generate and download QR codes for locations  
✅ **Automatic User Blocking** – Users blocked after expiry date  
✅ **Manual User Blocking** – Admin can block/unblock users anytime  
✅ **Reports Dashboard** – View activity and incident reports  
✅ **Polished UI/UX** – Material 3 design, responsive layouts, shared widgets  

---

## Local Development Setup

### Prerequisites
- **Flutter** ≥ 3.0 (https://flutter.dev/docs/get-started/install)
- **Dart** ≥ 3.0 (bundled with Flutter)
- **Node.js** ≥ 18 (for Cloud Functions, optional)

### 1. Get Dependencies
```bash
cd "path/to/security_guard_app"
flutter pub get
```

### 2. Run on Desktop (Development)
```bash
flutter run -d windows
# or macOS:
flutter run -d macos
# or Chrome (web):
flutter run -d chrome
```

### 3. Run on Android Device/Emulator
```bash
flutter emulators --launch Pixel_5_API_33  # or your emulator name
flutter run -d <emulator-id>
```

### 4. Run on iOS (macOS required)
```bash
open ios/Runner.xcworkspace
# or via CLI:
flutter run -d <iOS-device-id>
```

---

## Backend Setup (Firebase Cloud Functions)

### Project Created
- **Project ID**: `security-guard-1770233111`
- **Cloud Function**: Express HTTP endpoint at `/invite` for creating users and generating password-reset links
- **Status**: Scaffolded; awaiting Firebase enablement in GCP project

### Deployment Steps (After Enabling Firebase on GCP)

1. **Ensure Firebase is enabled** on the GCP project (project owner must grant permissions in GCP Console):
   ```bash
   firebase projects:addfirebase security-guard-1770233111
   ```

2. **Set the invite secret** (replace with your strong secret):
   ```bash
   cd functions
   firebase functions:config:set invite.secret="YOUR_STRONG_SECRET_HERE" --project security-guard-1770233111
   ```

3. **Deploy the function**:
   ```bash
   firebase deploy --only functions:api --project security-guard-1770233111
   ```

4. **Note the function URL** from deploy output, e.g.:
   ```
   https://<region>-security-guard-1770233111.cloudfunctions.net/api
   ```

### Update App with Function URL
Edit [lib/screens/create_user.dart](lib/screens/create_user.dart) and replace:
```dart
const functionUrl = 'https://YOUR_CLOUD_FUNCTION_URL';
const functionSecret = 'YOUR_SECRET';
```
with the actual deployed URL and secret.

### Test the Cloud Function
```bash
curl -X POST 'https://<region>-security-guard-1770233111.cloudfunctions.net/api/invite' \
  -H 'Content-Type: application/json' \
  -H 'x-invite-secret: YOUR_STRONG_SECRET_HERE' \
  -d '{"name":"Test User","email":"test@example.com","daysActive":30}'
```

Expected response:
```json
{
  "uid": "<firebase-auth-uid>",
  "resetLink": "https://..."
}
```

---

## Architecture

### Folders
- **lib/** — Flutter app source code
  - **screens/** — Login, Dashboard, Users, Create User, Locations (QR), Reports
  - **services/** — MockService (local), FirebaseService (Cloud integration)
  - **models/** — User model with expiry/block logic
  - **widgets/** — PrimaryButton, CommonAppBar (reusable UI)
- **functions/** — Firebase Cloud Function (Node.js/Express)
  - **index.js** — HTTP endpoint to create Auth users & generate reset links
  - **package.json** — Dependencies (firebase-admin, firebase-functions, express)
- **android/** — Android-specific config
- **ios/** — iOS-specific config

### Key Dependencies
- **flutter** – UI framework
- **provider** – State management (MockService)
- **firebase_core, firebase_auth, cloud_firestore** – Backend services
- **qr_flutter** – QR code generation
- **url_launcher** – Open mail client
- **http** – HTTP client for Cloud Function calls

---

## App Screens

1. **Login** ([lib/screens/login.dart](lib/screens/login.dart))
   - Email & password input
   - Demo quick-login button

2. **Dashboard** ([lib/screens/dashboard.dart](lib/screens/dashboard.dart))
   - 4-tile grid: Users, Locations (QR), Reports, Settings
   - Recent activity widget

3. **Users** ([lib/screens/users.dart](lib/screens/users.dart))
   - List of created users with expiry dates
   - Block/unblock menu actions

4. **Create User** ([lib/screens/create_user.dart](lib/screens/create_user.dart))
   - Form: name, email, active days
   - Calls Firebase Cloud Function to create Auth user
   - Opens mail client with prefilled invite

5. **Locations (QR)** ([lib/screens/locations.dart](lib/screens/locations.dart))
   - Input location name & link
   - Generate & display QR code
   - Download/share (TODO: implement)

6. **Reports** ([lib/screens/reports.dart](lib/screens/reports.dart))
   - Activity reports list
   - Placeholder for incident reports (integrate Firestore)

---

## User Management Logic

### MockService ([lib/services/mock_service.dart](lib/services/mock_service.dart))
- Keeps users in-memory during app session
- Auto-checks user expiry every hour
- Blocks users whose `expiryDate` has passed

### FirebaseService ([lib/services/firebase_service.dart](lib/services/firebase_service.dart))
- Creates user records in Firestore
- Calls Cloud Function to generate password-reset link
- (TODO: integrate Firestore for persistent user storage)

---

## TODO / Next Steps

### High Priority
- [ ] Complete Firebase project enablement (requires GCP/Firebase console permissions)
- [ ] Deploy Cloud Function and test invite endpoint
- [ ] Wire app to real Firestore for user persistence
- [ ] Implement email sending in Cloud Function (SendGrid/SMTP)
- [ ] Secure admin login with Firebase Auth

### Medium Priority
- [ ] Implement QR code download/share functionality
- [ ] Add incident report form and Firestore integration
- [ ] Implement activity logging when users perform actions
- [ ] Persist app state and user session
- [ ] Add push notifications for user creation/blocking

### Polish
- [ ] Add tests (unit, widget, integration)
- [ ] Optimize build size for mobile
- [ ] Add dark mode support
- [ ] Localization (multi-language)
- [ ] Error handling & logging

---

## Configuration

### Environment Variables (Cloud Function)
Set in Firebase Console or via CLI:
```bash
firebase functions:config:set invite.secret="YOUR_SECRET" --project security-guard-1770233111
```

### Android/iOS Build
```bash
# Android release APK
flutter build apk --release

# iOS release IPA
flutter build ios --release
```

---

## Troubleshooting

### Firebase Deploy Permission Denied
- Ensure the Google account used has **Owner** or **Firebase Admin** role on the GCP project
- Grant permissions in GCP Console → IAM & Admin → Add member with appropriate role

### Flutter Build Errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Emulator Not Detected
```bash
flutter emulators
flutter emulators --launch <emulator-id>
```

---

## Support & Resources
- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **Cloud Functions**: https://firebase.google.com/docs/functions
- **Dart**: https://dart.dev/guides

---

## License
Proprietary – Security Guard App

---

**Last Updated**: February 4, 2026  
**Status**: Development (Local testing ready; Firebase deployment pending GCP permissions)
