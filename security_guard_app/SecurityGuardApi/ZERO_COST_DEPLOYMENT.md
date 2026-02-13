# GuardCore API - Zero Cost Deployment Guide

## 🚀 Quick Start - Choose Your Platform

All three options are **100% FREE** and take 5-10 minutes to deploy.

---

## Option 1: Fly.io (RECOMMENDED for SQLite)

**Why?** Persistent volumes for SQLite, always-on, 3GB storage free.

### Deploy Steps:

```bash
# 1. Install Fly CLI
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"

# 2. Login
flyctl auth login

# 3. Navigate to API folder
cd SecurityGuardApi

# 4. Launch (follow prompts)
flyctl launch --no-deploy

# 5. Create persistent volume for database
flyctl volumes create guardcore_data --size 1

# 6. Deploy!
flyctl deploy

# 7. Get your URL
flyctl status
```

**Your API will be at:** `https://guardcore-api.fly.dev`

---

## Option 2: Railway.app (Easy + SQLite)

**Why?** Simplest deployment, $5/month free credit (~500 hours).

### Deploy Steps:

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Navigate to API folder
cd SecurityGuardApi

# 4. Initialize & deploy
railway init
railway up

# 5. Add domain
railway domain
```

**Cost:** ~$0.02/hour = ~500 hours free monthly

---

## Option 3: Render.com (PostgreSQL)

**Why?** True 100% free (with auto-sleep), unlimited time.

### Deploy Steps:

1. **Create PostgreSQL Database:**
   - Go to https://render.com
   - New > PostgreSQL
   - Name: `guardcore-db`
   - Free tier
   - Copy connection string

2. **Push code to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin YOUR_GITHUB_REPO
   git push -u origin main
   ```

3. **Create Web Service:**
   - New > Web Service
   - Connect GitHub repo
   - Root Directory: `SecurityGuardApi`
   - Build: `dotnet publish -c Release -o out`
   - Start: `cd out && dotnet SecurityGuardApi.dll`
   - Add environment variable:
     - `ConnectionStrings__DefaultConnection` = PostgreSQL connection string

**Trade-off:** Sleeps after 15min inactivity, wakes in ~30 seconds.

---

## 📊 Comparison Table

| Feature | Fly.io | Railway | Render |
|---------|--------|---------|--------|
| **Cost** | Free forever | $5/month credit | Free forever |
| **Database** | SQLite | SQLite/Postgres | Postgres only |
| **Uptime** | 24/7 | 24/7 | Auto-sleep |
| **Storage** | 3GB (persistent) | 1GB | 1GB |
| **Memory** | 256MB | 512MB | 512MB |
| **Setup Time** | 5 min | 3 min | 10 min |

---

## 🔐 Security Setup (ALL PLATFORMS)

After deployment, set these environment variables:

```bash
# Fly.io
flyctl secrets set Jwt__Key="YOUR-SECURE-KEY-MIN-32-CHARS-$(openssl rand -hex 16)"
flyctl secrets set Admin__Password="YourStrongPassword123!"

# Railway
railway variables set Jwt__Key="YOUR-SECURE-KEY-MIN-32-CHARS-$(openssl rand -hex 16)"
railway variables set Admin__Password="YourStrongPassword123!"

# Render (via dashboard)
Jwt__Key = YOUR-SECURE-KEY-MIN-32-CHARS
Admin__Password = YourStrongPassword123!
```

---

## 🔄 Update Your Flutter App

After deployment, update your API endpoint:

**File:** `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Replace with your deployed URL
  static const String baseUrl = 'https://guardcore-api.fly.dev';
  // or
  // static const String baseUrl = 'https://guardcore-api.up.railway.app';
  // or
  // static const String baseUrl = 'https://guardcore-api.onrender.com';
}
```

---

## 🌐 Bonus: Free Domain Options

Get a free custom domain:

1. **Freenom** - Free .tk, .ml, .ga domains
2. **Cloudflare** - Free DNS + SSL
3. **DuckDNS** - Free subdomain

Connect to your platform:
- Fly.io: `flyctl certs add yourdomain.com`
- Railway: Dashboard > Settings > Custom Domain
- Render: Dashboard > Settings > Custom Domain

---

## 📝 Testing Your Deployment

```bash
# Test health endpoint
curl https://your-api-url.com/health

# Test login
curl -X POST https://your-api-url.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

---

## 💡 Pro Tips

### Fly.io:
- Free 3 apps, auto-stop after inactivity, auto-wake on request
- Persistent SQLite works perfectly
- `flyctl logs` for debugging

### Railway:
- Monitor usage: `railway status`
- ~500 hours/month = 20+ days if always on
- Auto-stop on low traffic to extend credit

### Render:
- Keep warm with uptime monitoring (UptimeRobot free)
- Best for truly free, unlimited time
- accepts PostgreSQL string switch for production

---

## 🆘 Troubleshooting

### Database not persisting (Fly.io):
```bash
flyctl volumes list
# If empty, create one:
flyctl volumes create guardcore_data --size 1
# Redeploy:
flyctl deploy
```

### Out of memory:
Optimize your app settings in appsettings.Production.json

### Can't connect from Flutter app:
- Check CORS settings in Program.cs
- Ensure HTTPS
- Verify firewall rules

---

## 📈 Scaling (Still Free!)

When you outgrow free tier:
1. **Vercel** - Edge functions
2. **Cloudflare Workers** - Serverless
3. **Oracle Cloud** - Always free tier (4 CPUs, 24GB RAM!)
4. **Google Cloud Run** - 2M requests/month free

---

## ✅ My Recommendation

**Start with Fly.io:**
- Easiest SQLite persistence
- Always-on
- No code changes needed
- Simple CLI

**Commands:**
```bash
cd SecurityGuardApi
flyctl auth login
flyctl launch
flyctl volumes create guardcore_data --size 1
flyctl deploy
```

Done! 🎉

Your API will be live at `https://[your-app].fly.dev` in under 5 minutes.
