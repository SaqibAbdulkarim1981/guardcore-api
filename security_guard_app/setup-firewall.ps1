# Run this script as Administrator to configure Windows Firewall

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GuardCore Backend API - Firewall Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then try again." -ForegroundColor Yellow
    Write-Host ""
    Pause
    Exit 1
}

Write-Host "✅ Running with Administrator privileges" -ForegroundColor Green
Write-Host ""

# Remove existing rule if it exists
Write-Host "🔍 Checking for existing firewall rules..." -ForegroundColor Yellow
$existingRule = Get-NetFirewallRule -DisplayName "GuardCore*" -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "   Found existing rule. Removing..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName "GuardCore*" -ErrorAction SilentlyContinue
    Write-Host "   ✅ Removed old rule" -ForegroundColor Green
}

# Create new firewall rule
Write-Host ""
Write-Host "🔧 Creating firewall rule for port 5000..." -ForegroundColor Yellow

try {
    New-NetFirewallRule `
        -DisplayName "GuardCore Backend API" `
        -Description "Allows incoming connections to GuardCore .NET Backend API on port 5000" `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 5000 `
        -Action Allow `
        -Profile Domain,Private,Public `
        -Enabled True `
        -ErrorAction Stop | Out-Null
    
    Write-Host "   ✅ Firewall rule created successfully!" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to create firewall rule: $($_.Exception.Message)" -ForegroundColor Red
    Pause
    Exit 1
}

# Verify the rule
Write-Host ""
Write-Host "🔍 Verifying firewall configuration..." -ForegroundColor Yellow
$rule = Get-NetFirewallRule -DisplayName "GuardCore Backend API" -ErrorAction SilentlyContinue

if ($rule) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ FIREWALL CONFIGURED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Rule Details:" -ForegroundColor Cyan
    Write-Host "  Name:      $($rule.DisplayName)"
    Write-Host "  Direction: $($rule.Direction)"
    Write-Host "  Action:    $($rule.Action)"
    Write-Host "  Protocol:  TCP"
    Write-Host "  Port:      5000"
    Write-Host "  Enabled:   $($rule.Enabled)"
    Write-Host ""
    Write-Host "✅ Port 5000 is now accessible from your network!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "❌ Could not verify firewall rule" -ForegroundColor Red
}

# Display next steps
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Start the backend API:" -ForegroundColor Yellow
Write-Host "   cd SecurityGuardApi"
Write-Host "   dotnet run"
Write-Host ""
Write-Host "2. Install APK on your Android device:" -ForegroundColor Yellow
Write-Host "   adb install build\app\outputs\flutter-apk\app-debug.apk"
Write-Host ""
Write-Host "3. Ensure your phone is on the same WiFi network" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Test backend connectivity from phone browser:" -ForegroundColor Yellow
Write-Host "   Open: http://10.0.0.208:5000/api/Users"
Write-Host ""
Write-Host "5. Launch GuardCore app and login!" -ForegroundColor Yellow
Write-Host ""
Write-Host "For detailed instructions, see: APK_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Pause
