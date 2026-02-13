# Keeping Your Deployment at $0 Forever

## 🎯 Platform-Specific Cost Management

---

## Fly.io - Stay Free

### Free Tier Limits:
- ✅ 3 shared-cpu VMs (256MB RAM each)
- ✅ 160GB data transfer/month
- ✅ 3GB persistent volumes total
- ✅ 1 IPv4 address

### How to Stay Free:

1. **Single VM:** Use just 1 VM (default)
   ```bash
   # Check your apps
   flyctl apps list
   
   # Scale to 1 instance max
   flyctl scale count 1
   ```

2. **Auto-stop (optional):**
   ```bash
   # Stop when idle, wake on request
   flyctl scale vm shared-cpu-1x --memory 256
   ```

3. **Monitor Usage:**
   ```bash
   flyctl dashboard
   # Or visit: https://fly.io/dashboard
   ```

### ⚠️ What Triggers Charges:
- ❌ More than 160GB bandwidth/month (unlikely for small APIs)
- ❌ More than 3 total app volumes
- ❌ Dedicated CPU instances
- ❌ Additional IP addresses

### Cost Alerts:
```bash
# Set up billing alerts in dashboard
# Settings > Billing > Set alert at $1
```

---

## Railway - Maximize Your $5 Credit

### Free Credit: $5/month (~500 hours)

### Usage Formula:
```
Cost = (vCPU × $0.000463/min) + (RAM_GB × $0.000231/min)
```

Example:
- 0.5 vCPU + 512MB RAM = ~$0.01/hour = 500 hours/month FREE

### Optimization Tips:

1. **Check Usage:**
   ```bash
   railway status
   railway metrics
   ```

2. **Auto-Sleep (save 60-80% credits):**
   ```bash
   # In railway.toml
   [deploy]
   sleepAfter = "15m"  # Sleep after 15min idle
   ```

3. **Monitor in Dashboard:**
   - https://railway.app/account/usage
   - View hourly breakdown
   - Set up alerts

4. **Reduce Runtime:**
   - Only run when needed
   - Use cron jobs for scheduled tasks
   - Remove unused services

### Stay Under $5:
- ✅ ~20 days 24/7 uptime
- ✅ ~500 hours/month
- ✅ With auto-sleep: Effectively unlimited for low-traffic apps

---

## Render - Truly Free (with Trade-offs)

### Free Tier:
- ✅ Unlimited time
- ✅ 512MB RAM
- ✅ Automatic SSL
- ⚠️ Sleeps after 15min inactivity
- ⚠️ Wakes in ~30 seconds

### Keep-Alive Strategies:

#### Option 1: UptimeRobot (Free)
1. Sign up: https://uptimerobot.com
2. Add monitor:
   - URL: `https://your-app.onrender.com/health`
   - Interval: Every 5 minutes
3. Keeps your app awake 24/7 (within free tier limits)

#### Option 2: Cron-job.org (Free)
```bash
# Ping your API every 10 minutes
URL: https://your-app.onrender.com/health
Schedule: */10 * * * *
```

#### Option 3: Accept the Sleep
- Best for low-traffic apps
- First request takes 30s (cold start)
- Subsequent requests are instant
- No monitoring needed = truly $0

### What's Included Free:
- ✅ 750 hours/month web services
- ✅ Unlimited static sites
- ✅ Automatic deploys from Git
- ✅ Zero maintenance

---

## 📊 Cost Comparison Over Time

| Platform | Month 1 | Month 6 | Month 12 | Trade-off |
|----------|---------|---------|----------|-----------|
| **Fly.io** | $0 | $0 | $0 | None (if stay in limits) |
| **Railway** | $0 | $0 | $0* | Need usage management |
| **Render** | $0 | $0 | $0 | Auto-sleep or monitoring |

*With proper optimization

---

## 🔍 Monitoring Scripts

### Check Fly.io Usage:
```bash
flyctl dashboard
flyctl metrics
```

### Check Railway Usage:
```bash
railway status
railway logs --tail 100
```

### Monitor All Platforms:
```powershell
# Save as check-hosting-costs.ps1

Write-Host "=== Hosting Cost Monitor ===" -ForegroundColor Cyan

# Fly.io
Write-Host "`nFly.io Status:" -ForegroundColor Yellow
flyctl dashboard
flyctl apps list

# Railway
Write-Host "`nRailway Status:" -ForegroundColor Yellow
railway status

Write-Host "`n=== Monthly Estimate ===" -ForegroundColor Green
Write-Host "Fly.io: $0 (within free tier)"
Write-Host "Railway: $(railway metrics --cost)"
Write-Host "`nTotal: Check dashboards for exact usage"
```

Run weekly: `.\check-hosting-costs.ps1`

---

## 💡 Optimization Tips for All Platforms

### 1. Reduce Memory Usage

**In appsettings.Production.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",  // Instead of "Information"
      "Microsoft": "Warning"
    }
  }
}
```

### 2. Enable Response Compression

**In Program.cs:**
```csharp
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
});

app.UseResponseCompression();
```

### 3. Add Caching

```csharp
builder.Services.AddResponseCaching();
app.UseResponseCaching();
```

### 4. Optimize Docker Image

**In Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
# Use alpine for smaller image (saves bandwidth)
```

### 5. Database Optimization

```bash
# SQLite: Regular cleanup
sqlite3 guardcore.db "VACUUM;"
sqlite3 guardcore.db "ANALYZE;"
```

---

## 🎯 Best Practices to Stay Free

### ✅ DO:
1. Monitor usage weekly
2. Set up billing alerts ($1 threshold)
3. Use auto-sleep for Railway
4. Keep single VM/instance
5. Optimize images and code
6. Use CDN for static assets (Cloudflare free)
7. Set resource limits in code

### ❌ DON'T:
1. Deploy multiple copies of same app
2. Leave test apps running
3. Enable auto-scaling without limits
4. Upload large files to database
5. Run background jobs 24/7 unnecessarily
6. Ignore usage dashboards

---

## 🚨 Setting Up Alerts

### Fly.io:
```bash
# Via dashboard: fly.io/dashboard/(org)/settings
# Set email alert at $1 spend
```

### Railway:
```bash
# Dashboard > Account > Usage
# Email notifications enabled by default
```

### Render:
```bash
# Dashboard > Account > Billing
# Monthly usage reports via email
```

---

## 📧 Email Notifications Setup

Create: `monitor-costs.ps1`

```powershell
$costs = @{
    Fly = 0
    Railway = 0
    Render = 0
}

# Check costs (pseudo-code - implement with CLI)
# If any > $0.50, send alert email

if ($totalCost -gt 0.50) {
    # Send email or notification
    Write-Host "WARNING: Approaching cost threshold!" -ForegroundColor Red
}
```

Schedule with Task Scheduler: Run daily

---

## 🎁 Bonus: More Free Resources

1. **Free CDN:** Cloudflare (unlimited bandwidth)
2. **Free SSL:** Let's Encrypt (automatic on all platforms)
3. **Free Domain:** Freenom (.tk, .ml domains)
4. **Free DNS:** Cloudflare
5. **Free Monitoring:** UptimeRobot (50 monitors)
6. **Free Logs:** All platforms include logs
7. **Free Backups:** 
   - Fly.io: Manual via CLI
   - Railway: Automatic
   - Render: Database snapshots

---

## 🏆 The Perfect Free Stack

```
Frontend: Vercel (free)
Backend: Fly.io (free)
Database: SQLite on Fly.io (free)
CDN: Cloudflare (free)
Domain: Freenom (free) + Cloudflare DNS (free)
SSL: Let's Encrypt (free, automatic)
Monitoring: UptimeRobot (free)
Email: SendGrid (100 emails/day free)
```

**Total Monthly Cost: $0** ✅

---

## ✅ Quick Check: Are You Still Free?

Run this monthly:

```bash
# Fly.io
flyctl dashboard  # Check usage graphs

# Railway  
railway status  # Check credit remaining

# Render
# Check email for monthly report
```

If usage > 50% of limits:
1. Review optimization tips above
2. Consider auto-sleep
3. Remove unused features
4. Contact support (often increase limits free!)

---

## 🎯 Bottom Line

**All three platforms can be FREE forever if you:**
1. Stay within limits (easy for small-medium apps)
2. Monitor monthly
3. Optimize your code
4. Don't over-engineer

**Recommended for true $0:**
- **Fly.io** - Best balance, no tricks needed
- **Railway** - Second best, auto-sleep for insurance
- **Render** - Most generous, accept cold starts

Your GuardCore API will cost **$0/month** on any of these! 🎉
