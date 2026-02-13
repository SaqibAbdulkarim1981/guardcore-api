# Security Guard App - Backend Integration Guide

## ✅ Integration Complete

The Flutter app has been successfully integrated with the ASP.NET Core backend.

---

## 🔧 What Was Changed

### 1. **API Service Created**
- **File**: `lib/services/api_service.dart`
- Full-featured service connecting to .NET backend
- Supports: Authentication, User Management, Locations, QR Codes, Reports
- Uses JWT Bearer token authentication
- Built-in error handling and loading states

### 2. **Configuration**
- **File**: `lib/config/api_config.dart`
- Backend URL: `https://localhost:5001/api`
- Default admin credentials for quick testing
- Easily configurable for production deployment

### 3. **Updated Screens**
All screens now use the new API service:

#### Login Screen (`lib/screens/login.dart`)
- Authenticates against .NET backend
- Stores JWT token in ApiService
- "Quick Login" button for testing
- Shows error messages on failed authentication

#### Users Screen (`lib/screens/users.dart`)
- Fetches users from API on load
- Real-time user blocking/unblocking
- Shows blocked status with visual indicators
- Automatically refreshes after user creation

#### Create User Screen (`lib/screens/create_user.dart`)
- Creates users via API
- Composes invitation email
- Shows success/error feedback
- Returns to users list after creation

#### Locations Screen (`lib/screens/locations.dart`)
- Create locations with name and description
- Fetch all locations from backend
- Display QR codes in modal dialog
- QR codes loaded directly from backend endpoint

#### Reports Screen (`lib/screens/reports.dart`)
- Fetches all reports from API
- Displays activity and incident reports
- Color-coded by type (red for incidents)
- Shows user ID, location ID, and timestamps

### 4. **Main App (`lib/main.dart`)**
- Added `ApiService` provider
- Available throughout the app via Provider

---

## 🚀 How to Use

### Start the Backend
```powershell
cd SecurityGuardApi
dotnet run --project SecurityGuardApi.csproj --urls "http://localhost:5000;https://localhost:5001"
```

### Start the Flutter App
```powershell
flutter run -d windows
```

### Login
- **Email**: `admin@example.com`
- **Password**: `admin123`
- Or click "Quick Login as Super Admin"

---

## 📡 API Endpoints Used

### Authentication
- `POST /api/Auth/login` - Login with email/password

### Users
- `GET /api/Users` - List all users
- `POST /api/Users` - Create new user
- `GET /api/Users/{id}` - Get user by ID
- `POST /api/Users/{id}/block` - Block user
- `POST /api/Users/{id}/unblock` - Unblock user

### Locations
- `GET /api/Locations` - List all locations
- `POST /api/Locations` - Create location
- `GET /api/Locations/{id}/qrcode` - Get QR code image

### Reports
- `GET /api/Reports` - List all reports
- `POST /api/Reports` - Create report

---

## 🔐 Security Notes

1. **HTTPS Certificate**: The app accepts self-signed certificates for localhost development
2. **JWT Token**: Stored in memory, cleared on logout
3. **Production**: Update `ApiConfig.baseUrl` to production URL and use proper SSL certificates

---

## 🐛 Troubleshooting

### Backend Connection Issues
- Ensure .NET API is running on https://localhost:5001
- Check Windows Firewall settings
- Verify JWT key is at least 32 characters in `appsettings.json`

### Login Fails
- Confirm backend is accessible
- Check credentials in `appsettings.json`
- Look for errors in backend terminal

### QR Codes Not Loading
- Ensure locations are created first
- Check authentication token is valid
- Verify Image.network can access HTTPS endpoint

---

## 📦 Architecture

```
Flutter App (UI/Client)
    ↓
ApiService (HTTP Client + State Management)
    ↓
ASP.NET Core Web API (Controllers + Services)
    ↓
Entity Framework Core
    ↓
SQLite Database (securityguard.db)
```

---

## 🎯 Next Steps (Optional)

1. **Deploy Backend**: Host on Azure, AWS, or other cloud provider
2. **Email Integration**: Add SendGrid or SMTP for real invitation emails
3. **Push Notifications**: Implement FCM for incident alerts
4. **User Roles**: Add Guard and Supervisor roles with different permissions
5. **Real-time Updates**: Add SignalR for live dashboard updates
6. **Mobile Support**: Test and optimize for Android/iOS

---

## 📝 Testing Checklist

- [x] Login with admin credentials
- [x] Create new user
- [x] View users list
- [x] Block/unblock users
- [x] Create location
- [x] Generate and display QR codes
- [x] View reports (if any exist)
- [x] Handle network errors gracefully

---

## 💡 Tips

- Use "Quick Login" button for fast testing
- Backend runs on both HTTP (5000) and HTTPS (5001)
- Swagger UI available at https://localhost:5001/swagger
- All API calls include automatic JWT token authentication
- Users auto-block when expiry date is reached

---

**Integration Date**: February 10, 2026  
**Status**: ✅ Production Ready for Local Testing
