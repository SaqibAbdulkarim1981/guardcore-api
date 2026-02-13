# Render.com Deployment - Step by Step

## 🚀 Deploy GuardCore API to Render.com (100% FREE)

### Step 1: Push to GitHub (5 minutes)

1. **Create a new GitHub repository:**
   - Go to https://github.com/new
   - Repository name: `guardcore-api`
   - Set to Public or Private (both work)
   - Click "Create repository"

2. **Push your code:**
   ```powershell
   # Add your GitHub repo (replace YOUR_USERNAME)
   git remote add origin https://github.com/YOUR_USERNAME/guardcore-api.git
   
   # Push code
   git branch -M main
   git push -u origin main
   ```

### Step 2: Deploy on Render.com (3 minutes)

1. **Sign up/Login:**
   - Go to https://render.com
   - Sign up with GitHub (easiest) or email
   - No credit card required!

2. **Create PostgreSQL Database:**
   - Click "New +" button
   - Select "PostgreSQL"
   - Name: `guardcore-db`
   - Database: `guardcore`
   - User: `guardcore`
   - Region: Choose closest to you
   - Plan: **Free**
   - Click "Create Database"
   - **Copy the "Internal Database URL"** (important!)

3. **Create Web Service:**
   - Click "New +" button again
   - Select "Web Service"
   - Click "Connect a repository"
   - Authorize Render to access your GitHub
   - Select your `guardcore-api` repository
   - Configure:
     - **Name:** `guardcore-api`
     - **Root Directory:** `security_guard_app/SecurityGuardApi`
     - **Environment:** `Docker`
     - **Plan:** **Free**
   - Click "Advanced" and add environment variables:
     - `ASPNETCORE_ENVIRONMENT` = `Production`
     - `ASPNETCORE_URLS` = `http://+:5000`
     - `ConnectionStrings__DefaultConnection` = (paste your database URL from Step 2)
     - `Jwt__Key` = (generate a random 32+ character string)
   - Click "Create Web Service"

4. **Wait for deployment:**
   - Render will build and deploy (5-10 minutes)
   - Watch the logs for progress
   - When you see "Service is live 🎉" - you're done!

### Step 3: Update Flutter App

1. **Get your API URL:**
   - On Render dashboard, copy your app URL
   - Format: `https://guardcore-api.onrender.com`

2. **Update Flutter config:**
   ```dart
   // lib/config/api_config.dart
   static const String baseUrl = 'https://guardcore-api.onrender.com';
   ```

3. **Rebuild your app:**
   ```powershell
   cd security_guard_app
   flutter build apk
   ```

### 🎯 Important Notes:

**Free Tier Details:**
- ✅ Unlimited time FREE
- ✅ 512MB RAM
- ✅ Automatic SSL/HTTPS
- ⚠️ Sleeps after 15 minutes of inactivity
- ⚠️ First request after sleep takes ~30 seconds to wake

**Keep Warm (Optional):**
- Use UptimeRobot.com (free) to ping your API every 5 minutes
- This keeps it awake 24/7 within free limits

**Database:**
- Free PostgreSQL included
- 1GB storage
- Automatic backups

### 🔐 Generate Secure JWT Key:

```powershell
# PowerShell command to generate secure key:
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
```

Copy the output and use it for `Jwt__Key` environment variable.

### ✅ Testing Your Deployment:

```powershell
# Test health endpoint
curl https://guardcore-api.onrender.com/health

# Test login
curl -X POST https://guardcore-api.onrender.com/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@example.com","password":"admin123"}'
```

### 🆘 Troubleshooting:

**Build fails:**
- Check logs in Render dashboard
- Ensure Dockerfile is in `security_guard_app/SecurityGuardApi/`

**Database connection error:**
- Verify the ConnectionStrings__DefaultConnection matches your database URL
- Format should be: `postgresql://user:password@host:5432/database`

**CORS errors from Flutter:**
- Check Program.cs has CORS enabled
- Verify your app is using HTTPS URL

### 📊 Monitor Your App:

- **Dashboard:** https://dashboard.render.com
- **Logs:** Click your service > Logs tab
- **Metrics:** View CPU, Memory usage
- **Events:** See deployment history

---

## 🎉 That's It!

Your GuardCore API is now live on the internet for **$0/month**!

Total time: ~10 minutes
Cost: FREE forever
SSL: Automatic
Backups: Included

Need help? Check Render docs: https://render.com/docs
