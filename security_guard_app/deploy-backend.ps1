# GuardCore API - Quick Deploy Script
# Choose your deployment platform

Write-Host "`n=== GuardCore API - Zero Cost Deployment ===" -ForegroundColor Cyan
Write-Host "`nThis script will help you deploy your API for FREE!" -ForegroundColor Green

Write-Host "`n[1] Fly.io (Recommended - PostgreSQL + Always On)"
Write-Host "[2] Railway.app (Easy - $5 credit/month)"
Write-Host "[3] Render.com (100% Free - Auto-sleep)"
Write-Host "[4] Show detailed instructions"
Write-Host "[0] Exit`n"

$choice = Read-Host "Select platform (1-4)"

switch ($choice) {
    "1" {
        Write-Host "`n=== Deploying to Fly.io ===" -ForegroundColor Cyan
        
        # Check if flyctl is installed
        $flyctl = Get-Command flyctl -ErrorAction SilentlyContinue
        if (-not $flyctl) {
            Write-Host "`nInstalling Fly.io CLI..." -ForegroundColor Yellow
            iwr https://fly.io/install.ps1 -useb | iex
            Write-Host "`nPlease restart this script after installation completes." -ForegroundColor Green
            exit
        }
        
        Write-Host "`n1. Logging in..." -ForegroundColor Yellow
        flyctl auth login
        
        Write-Host "`n2. Setting up application..." -ForegroundColor Yellow
        Set-Location -Path "SecurityGuardApi"
        flyctl launch --no-deploy
        
        Write-Host "`n3. Creating persistent volume for database..." -ForegroundColor Yellow
        flyctl volumes create guardcore_data --size 1 --yes
        
        Write-Host "`n4. Deploying application..." -ForegroundColor Yellow
        flyctl deploy
        
        Write-Host "`n5. Setting up secrets..." -ForegroundColor Yellow
        $jwtKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
        flyctl secrets set "Jwt__Key=$jwtKey"
        
        Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Green
        flyctl status
        Write-Host "`nYour API is live! Copy the hostname above and update your Flutter app's api_config.dart" -ForegroundColor Cyan
    }
    
    "2" {
        Write-Host "`n=== Deploying to Railway ===" -ForegroundColor Cyan
        
        # Check if railway is installed
        $railway = Get-Command railway -ErrorAction SilentlyContinue
        if (-not $railway) {
            Write-Host "`nInstalling Railway CLI..." -ForegroundColor Yellow
            npm install -g @railway/cli
        }
        
        Write-Host "`n1. Logging in..." -ForegroundColor Yellow
        railway login
        
        Write-Host "`n2. Initializing project..." -ForegroundColor Yellow
        Set-Location -Path "SecurityGuardApi"
        railway init
        
        Write-Host "`n3. Deploying..." -ForegroundColor Yellow
        railway up
        
        Write-Host "`n4. Setting up domain..." -ForegroundColor Yellow
        railway domain
        
        Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Green
        railway status
        Write-Host "`nYour API is live! Update your Flutter app's api_config.dart with the domain above" -ForegroundColor Cyan
    }
    
    "3" {
        Write-Host "`n=== Deploying to Render.com ===" -ForegroundColor Cyan
        Write-Host "`nRender.com requires GitHub integration." -ForegroundColor Yellow
        Write-Host "`nSteps:"
        Write-Host "1. Push your code to GitHub"
        Write-Host "2. Go to https://render.com"
        Write-Host "3. Create New > Web Service"
        Write-Host "4. Connect your GitHub repository"
        Write-Host "5. Configure:"
        Write-Host "   - Root Directory: SecurityGuardApi"
        Write-Host "   - Build Command: dotnet publish -c Release -o out"
        Write-Host "   - Start Command: cd out && dotnet SecurityGuardApi.dll"
        Write-Host "`nWould you like to:"
        Write-Host "[1] Initialize Git and push to GitHub"
        Write-Host "[2] Open Render.com in browser"
        Write-Host "[0] Cancel"
        
        $renderChoice = Read-Host "`nSelect option"
        
        if ($renderChoice -eq "1") {
            git init
            git add .
            git commit -m "Initial commit for deployment"
            Write-Host "`nNow create a GitHub repository and run:" -ForegroundColor Green
            Write-Host "git remote add origin YOUR_GITHUB_REPO_URL"
            Write-Host "git push -u origin main"
        }
        elseif ($renderChoice -eq "2") {
            Start-Process "https://render.com/dashboard"
        }
    }
    
    "4" {
        Write-Host "`nOpening deployment guide..." -ForegroundColor Yellow
        notepad "SecurityGuardApi\ZERO_COST_DEPLOYMENT.md"
    }
    
    "0" {
        Write-Host "`nExiting..." -ForegroundColor Yellow
        exit
    }
    
    default {
        Write-Host "`nInvalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Copy your deployed URL"
Write-Host "2. Update lib/config/api_config.dart with your new URL"
Write-Host "3. Rebuild your Flutter app: flutter build apk"
Write-Host "`nYour backend is now live on the internet for FREE! 🎉" -ForegroundColor Green
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
