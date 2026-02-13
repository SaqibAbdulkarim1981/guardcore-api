# GuardCore - Test Credentials & Quick Start

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   GuardCore - Test Credentials" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔐 LOGIN CREDENTIALS" -ForegroundColor Yellow
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  👨‍💼 ADMIN ACCOUNT (Back-Office App)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "  Email:    " -NoNewline -ForegroundColor White
Write-Host "admin@example.com" -ForegroundColor Green
Write-Host "  Password: " -NoNewline -ForegroundColor White
Write-Host "admin123" -ForegroundColor Green
Write-Host ""
Write-Host "  Use this to:" -ForegroundColor Gray
Write-Host "  • Manage users" -ForegroundColor Gray
Write-Host "  • Generate QR codes" -ForegroundColor Gray
Write-Host "  • View reports & attendance" -ForegroundColor Gray
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "  👮 GUARD ACCOUNT (Mobile App)" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "  Email:    " -NoNewline -ForegroundColor White
Write-Host "guard@test.com" -ForegroundColor Green
Write-Host "  Password: " -NoNewline -ForegroundColor White
Write-Host "guard123" -ForegroundColor Green
Write-Host ""
Write-Host "  Use this to:" -ForegroundColor Gray
Write-Host "  • Login to mobile app" -ForegroundColor Gray
Write-Host "  • Scan QR codes (check in/out)" -ForegroundColor Gray
Write-Host "  • Submit activity/incident reports" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   📍 TEST LOCATIONS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Main Entrance    (ID: 1)" -ForegroundColor White
Write-Host "  2. Parking Lot      (ID: 2)" -ForegroundColor White
Write-Host "  3. Rooftop Access   (ID: 3)" -ForegroundColor White
Write-Host ""
Write-Host "  💡 Use admin app to generate QR codes for these locations" -ForegroundColor Yellow
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   🚀 QUICK START" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 1: Start Backend API" -ForegroundColor Yellow
Write-Host "  cd SecurityGuardApi" -ForegroundColor Cyan
Write-Host "  dotnet run" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Backend will:" -ForegroundColor Gray
Write-Host "  • Create database automatically" -ForegroundColor Gray
Write-Host "  • Seed with test accounts above" -ForegroundColor Gray
Write-Host "  • Listen on http://0.0.0.0:5000" -ForegroundColor Gray
Write-Host ""

Write-Host "STEP 2A: Test Admin App (Windows)" -ForegroundColor Yellow
Write-Host "  • In main.dart, set: USE_MOBILE_APP = false" -ForegroundColor Cyan
Write-Host "  • Run: flutter run -d windows" -ForegroundColor Cyan
Write-Host "  • Login with: admin@example.com / admin123" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 2B: Test Mobile App (Android)" -ForegroundColor Yellow
Write-Host "  • In main.dart, set: USE_MOBILE_APP = true" -ForegroundColor Cyan
Write-Host "  • Install APK: adb install build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Cyan
Write-Host "  • Login with: guard@test.com / guard123" -ForegroundColor Cyan
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   ⚙️ NETWORK CONFIGURATION" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Backend API:  " -NoNewline -ForegroundColor White
Write-Host "http://10.0.0.208:5000/api" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Mobile App Config: " -NoNewline -ForegroundColor White
Write-Host "lib/config/api_config.dart" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   📱 MOBILE APP TESTING WORKFLOW" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Login to mobile app" -ForegroundColor White
Write-Host "   guard@test.com / guard123" -ForegroundColor Green
Write-Host ""
Write-Host "2. Scan QR Code" -ForegroundColor White
Write-Host "   • First scan = CheckIn" -ForegroundColor Gray
Write-Host "   • Second scan = CheckOut" -ForegroundColor Gray
Write-Host "   • QR should contain: 1, 2, or 3 (Location ID)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Submit Activity Report" -ForegroundColor White
Write-Host "   • Fill all required fields" -ForegroundColor Gray
Write-Host "   • Report saved to database" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Submit Incident Report" -ForegroundColor White
Write-Host "   • Select severity level" -ForegroundColor Gray
Write-Host "   • Fill description & actions" -ForegroundColor Gray
Write-Host ""
Write-Host "5. View in Admin App" -ForegroundColor White
Write-Host "   • All reports visible in Reports tab" -ForegroundColor Gray
Write-Host "   • Attendance records in dashboard" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   🔧 TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Login fails?" -ForegroundColor Red
Write-Host "  • Ensure backend is running (dotnet run)" -ForegroundColor Gray
Write-Host "  • Check database was created (guardcore.db should exist)" -ForegroundColor Gray
Write-Host "  • Verify credentials exactly as shown above" -ForegroundColor Gray
Write-Host ""
Write-Host "Mobile app cannot connect?" -ForegroundColor Red
Write-Host "  • Run: .\setup-firewall.ps1 (as Administrator)" -ForegroundColor Gray
Write-Host "  • Ensure phone on same WiFi as computer" -ForegroundColor Gray
Write-Host "  • Test in phone browser: http://10.0.0.208:5000/api/Users" -ForegroundColor Gray
Write-Host ""
Write-Host "Need to reset database?" -ForegroundColor Red
Write-Host "  cd SecurityGuardApi" -ForegroundColor Gray
Write-Host "  rm guardcore.db" -ForegroundColor Gray
Write-Host "  dotnet run" -ForegroundColor Gray
Write-Host "  (Database will be recreated with test data)" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 TIP: Keep this window open for reference!" -ForegroundColor Yellow
Write-Host ""
Write-Host "📚 Full Documentation:" -ForegroundColor White
Write-Host "   • MOBILE_QUICK_START.md" -ForegroundColor Cyan
Write-Host "   • APK_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
Write-Host "   • MOBILE_APP_README.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
