# Push code to GitHub
# Run these commands after creating your GitHub repository

# Replace YOUR_USERNAME with your actual GitHub username
$username = Read-Host "Enter your GitHub username"

# Add remote
git remote add origin "https://github.com/$username/guardcore-api.git"

# Push code
git branch -M main
git push -u origin main

Write-Host "`nCode pushed successfully! Now deploying to Render.com..." -ForegroundColor Green

# Open Render.com for deployment
Start-Process "https://dashboard.render.com/register"

Write-Host "`n=== Next Steps on Render.com ===" -ForegroundColor Cyan
Write-Host "1. Sign up/Login (use GitHub to sign in - easiest!)"
Write-Host "2. Click 'New +' > PostgreSQL"
Write-Host "   - Name: guardcore-db"
Write-Host "   - Plan: Free"
Write-Host "   - Click Create Database"
Write-Host "   - COPY the 'Internal Database URL'"
Write-Host ""
Write-Host "3. Click 'New +' > Web Service"
Write-Host "   - Connect your guardcore-api repository"
Write-Host "   - Name: guardcore-api"
Write-Host "   - Root Directory: security_guard_app/SecurityGuardApi"
Write-Host "   - Environment: Docker"
Write-Host "   - Plan: Free"
Write-Host ""
Write-Host "4. Add Environment Variables (click Advanced):"
Write-Host "   ASPNETCORE_ENVIRONMENT = Production"
Write-Host "   ASPNETCORE_URLS = http://+:5000"
Write-Host "   ConnectionStrings__DefaultConnection = [YOUR DATABASE URL]"
Write-Host "   Jwt__Key = [GENERATE RANDOM 32+ CHARACTERS]"
Write-Host ""
Write-Host "5. Click 'Create Web Service' and wait 5-10 minutes"
Write-Host ""
Write-Host "Your API will be live at: https://guardcore-api.onrender.com" -ForegroundColor Green

# Generate JWT Key
Write-Host "`n=== JWT Key (copy this for Render environment variable) ===" -ForegroundColor Yellow
$jwtKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 48 | % {[char]$_})
Write-Host $jwtKey -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue..."
