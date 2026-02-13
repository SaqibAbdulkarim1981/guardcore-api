# GuardCore Mobile App - Quick Setup & Installation Guide

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   GuardCore Mobile App - Installation Guide" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check APK exists
Write-Host "🔍 Checking APK file..." -ForegroundColor Yellow
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"

if (Test-Path $apkPath) {
    $apkInfo = Get-Item $apkPath
    $sizeMB = [math]::Round($apkInfo.Length / 1MB, 2)
    Write-Host "   ✅ APK found!" -ForegroundColor Green
    Write-Host "      File: $($apkInfo.Name)" -ForegroundColor Gray
    Write-Host "      Size: $sizeMB MB" -ForegroundColor Gray
    Write-Host "      Date: $($apkInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "   ❌ APK not found at: $apkPath" -ForegroundColor Red
    Write-Host "      Run 'flutter build apk --debug' first" -ForegroundColor Yellow
    Write-Host ""
    Pause
    Exit 1
}

# Display network configuration
Write-Host ""
Write-Host "🌐 Network Configuration:" -ForegroundColor Yellow
Write-Host "   Backend API: http://10.0.0.208:5000/api" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Your IP Addresses:" -ForegroundColor Gray
ipconfig | Select-String "IPv4" | ForEach-Object {
    $ip = $_.ToString().Split(":")[1].Trim()
    if ($ip -eq "10.0.0.208") {
        Write-Host "      $ip ✅ (Configured in app)" -ForegroundColor Green
    } else {
        Write-Host "      $ip" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   INSTALLATION STEPS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 STEP 1: Configure Firewall (Run as Administrator)" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Right-click PowerShell → Run as Administrator" -ForegroundColor White
Write-Host "   Then run:" -ForegroundColor White
Write-Host "   .\setup-firewall.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 STEP 2: Start Backend API" -ForegroundColor Yellow
Write-Host ""
Write-Host "   cd SecurityGuardApi" -ForegroundColor Cyan
Write-Host "   dotnet run" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Backend should start on: http://localhost:5000" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 STEP 3: Connect Android Device" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Option A - USB Connection:" -ForegroundColor White
Write-Host "   1. Enable Developer Options on Android" -ForegroundColor Gray
Write-Host "   2. Enable USB Debugging" -ForegroundColor Gray
Write-Host "   3. Connect phone via USB cable" -ForegroundColor Gray
Write-Host "   4. Allow USB debugging when prompted" -ForegroundColor Gray
Write-Host ""
Write-Host "   Option B - WiFi Only:" -ForegroundColor White
Write-Host "   1. Connect phone to same WiFi as computer" -ForegroundColor Gray
Write-Host "   2. Copy APK to phone manually" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 STEP 4: Install APK" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Option A - Via ADB (Recommended):" -ForegroundColor White
Write-Host "   adb install $apkPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Option B - Manual Install:" -ForegroundColor White
Write-Host "   1. Copy APK to phone's Download folder" -ForegroundColor Gray
Write-Host "   2. Open Files app on phone" -ForegroundColor Gray
Write-Host "   3. Navigate to Downloads" -ForegroundColor Gray
Write-Host "   4. Tap app-debug.apk" -ForegroundColor Gray
Write-Host "   5. Allow unknown sources if prompted" -ForegroundColor Gray
Write-Host "   6. Install" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 STEP 5: Verify Network Connection" -ForegroundColor Yellow
Write-Host ""
Write-Host "   On your Android phone:" -ForegroundColor White
Write-Host "   1. Ensure connected to WiFi (not mobile data)" -ForegroundColor Gray
Write-Host "   2. Open Chrome browser" -ForegroundColor Gray
Write-Host "   3. Navigate to: http://10.0.0.208:5000/api/Users" -ForegroundColor Cyan
Write-Host "   4. You should see JSON response or 401 error (both are OK)" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 STEP 6: Launch GuardCore App" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Open GuardCore app on phone" -ForegroundColor Gray
Write-Host "   2. You should see the login screen" -ForegroundColor Gray
Write-Host "   3. Try logging in with test credentials" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   TEST CREDENTIALS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To create a guard test account:" -ForegroundColor Yellow
Write-Host "   1. In main.dart, set: USE_MOBILE_APP = false" -ForegroundColor Gray
Write-Host "   2. Run admin app: flutter run -d windows" -ForegroundColor Gray
Write-Host "   3. Login as: admin@example.com / admin123" -ForegroundColor Gray
Write-Host "   4. Go to Users → Create User" -ForegroundColor Gray
Write-Host "   5. Create guard account with email/password" -ForegroundColor Gray
Write-Host "   6. Use those credentials in mobile app" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "❌ Cannot connect to backend:" -ForegroundColor Red
Write-Host "   • Check backend is running (dotnet run)" -ForegroundColor Gray
Write-Host "   • Verify firewall allows port 5000" -ForegroundColor Gray
Write-Host "   • Ensure phone on same WiFi network" -ForegroundColor Gray
Write-Host "   • Test URL in phone browser first" -ForegroundColor Gray
Write-Host ""
Write-Host "❌ ADB not found:" -ForegroundColor Red
Write-Host "   • Install Android SDK Platform Tools" -ForegroundColor Gray
Write-Host "   • Or use manual APK installation method" -ForegroundColor Gray
Write-Host ""
Write-Host "❌ App crashes on startup:" -ForegroundColor Red
Write-Host "   • Check logs: adb logcat | Select-String 'Flutter'" -ForegroundColor Gray
Write-Host "   • Verify API URL in lib/config/api_config.dart" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   QUICK COMMANDS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check if device connected:" -ForegroundColor Yellow
Write-Host "   adb devices" -ForegroundColor Cyan
Write-Host ""
Write-Host "Install APK:" -ForegroundColor Yellow
Write-Host "   adb install $apkPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "View app logs:" -ForegroundColor Yellow
Write-Host "   adb logcat | Select-String 'Flutter'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Uninstall app:" -ForegroundColor Yellow
Write-Host "   adb uninstall com.example.security_guard_app" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copy APK to phone:" -ForegroundColor Yellow
Write-Host "   adb push $apkPath /sdcard/Download/" -ForegroundColor Cyan
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   For detailed documentation, see:" -ForegroundColor White
Write-Host "   • APK_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
Write-Host "   • MOBILE_APP_README.md" -ForegroundColor Cyan
Write-Host "   • MOBILE_QUICK_START.md" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Ready to install? Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run .\setup-firewall.ps1 as Administrator" -ForegroundColor Green
Write-Host "2. Start backend: cd SecurityGuardApi; dotnet run" -ForegroundColor Green
Write-Host "3. Install: adb install $apkPath" -ForegroundColor Green
Write-Host ""
