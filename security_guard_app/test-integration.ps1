# Integration Test Script

Write-Host "`n=== Security Guard App Integration Test ===" -ForegroundColor Cyan
Write-Host "This script validates the Flutter + .NET backend integration`n" -ForegroundColor Gray

# Check if API is running
Write-Host "1. Checking backend API..." -ForegroundColor Yellow
try {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $response = Invoke-RestMethod -Uri "https://localhost:5001/api/Auth/login" -Method POST -Body '{"Email":"admin@example.com","Password":"admin123"}' -ContentType "application/json"
    if ($response.token) {
        Write-Host "   ✓ Backend API is running and responsive" -ForegroundColor Green
        $global:token = $response.token
    } else {
        Write-Host "   ✗ Backend returned unexpected response" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ Backend is not accessible at https://localhost:5001" -ForegroundColor Red
    Write-Host "   Start the backend first: dotnet run --project SecurityGuardApi/SecurityGuardApi.csproj" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n2. Testing User Management..." -ForegroundColor Yellow
$headers = @{ Authorization = "Bearer $global:token" }

# Create a test user
try {
    $userBody = '{"Name":"Test User","Email":"test@example.com","ActiveDays":7}'
    $newUser = Invoke-RestMethod -Uri "https://localhost:5001/api/Users" -Method POST -Body $userBody -ContentType "application/json" -Headers $headers
    Write-Host "   ✓ Created test user: $($newUser.name)" -ForegroundColor Green
    $testUserId = $newUser.id
} catch {
    Write-Host "   ✗ Failed to create user" -ForegroundColor Red
}

# List users
try {
    $users = Invoke-RestMethod -Uri "https://localhost:5001/api/Users" -Method GET -Headers $headers
    Write-Host "   ✓ Fetched users list: $($users.Count) total" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to fetch users" -ForegroundColor Red
}

Write-Host "`n3. Testing Locations..." -ForegroundColor Yellow

# Create a location
try {
    $locationBody = '{"Name":"Test Location","Description":"Integration test location"}'
    $newLocation = Invoke-RestMethod -Uri "https://localhost:5001/api/Locations" -Method POST -Body $locationBody -ContentType "application/json" -Headers $headers
    Write-Host "   ✓ Created test location: $($newLocation.name)" -ForegroundColor Green
    $testLocationId = $newLocation.id
} catch {
    Write-Host "   ✗ Failed to create location" -ForegroundColor Red
}

Write-Host "`n4. Testing QR Code Generation..." -ForegroundColor Yellow

# Get QR code
if ($testLocationId) {
    try {
        $qrResponse = Invoke-WebRequest -Uri "https://localhost:5001/api/Locations/$testLocationId/qrcode" -Method GET -Headers $headers
        if ($qrResponse.Headers.'Content-Type' -like '*image/png*') {
            Write-Host "   ✓ QR code generated successfully ($($qrResponse.Content.Length) bytes)" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ✗ Failed to generate QR code" -ForegroundColor Red
    }
}

Write-Host "`n5. Testing Reports..." -ForegroundColor Yellow

# Create a report
try {
    $reportBody = '{"UserId":' + $testUserId + ',"LocationId":' + $testLocationId + ',"Type":"Activity","Description":"Integration test activity"}'
    $newReport = Invoke-RestMethod -Uri "https://localhost:5001/api/Reports" -Method POST -Body $reportBody -ContentType "application/json" -Headers $headers
    Write-Host "   ✓ Created test report: $($newReport.type)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to create report" -ForegroundColor Red
}

Write-Host "`n=== Integration Test Complete ===" -ForegroundColor Cyan
Write-Host "`nNow test the Flutter app:" -ForegroundColor White
Write-Host "  1. Launch the Flutter app (flutter run -d windows)" -ForegroundColor Gray
Write-Host "  2. Click 'Quick Login as Super Admin'" -ForegroundColor Gray
Write-Host "  3. Navigate through Users, Locations, and Reports screens" -ForegroundColor Gray
Write-Host "  4. Create a user and location" -ForegroundColor Gray
Write-Host "  5. View QR codes`n" -ForegroundColor Gray
