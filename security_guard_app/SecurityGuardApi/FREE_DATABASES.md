# Free Database Options for GuardCore API

## Current Setup: SQLite ✅
Your API currently uses SQLite, which is **perfect for free hosting**!

---

## Option 1: Keep SQLite (Recommended)

### ✅ Pros:
- No migration needed
- Zero additional cost
- Fast (no network latency)
- Simple file-based storage
- Works on Fly.io & Railway

### ⚠️ Considerations:
- Need persistent volumes (Fly.io/Railway provide free)
- Single server only (fine for small apps)
- Manual backups

### Best For: **Fly.io or Railway deployment**

---

## Option 2: Upgrade to PostgreSQL (Free Options)

If you need more features or multi-server support:

### **A. Supabase (Recommended PostgreSQL)**
- **Free Tier:** 500MB database, unlimited API requests
- **Features:** Real-time, Auth, Storage
- **URL:** https://supabase.com
- **Setup Time:** 2 minutes

```bash
# Connection string format:
postgresql://user:password@db.supabase.co:5432/postgres
```

### **B. ElephantSQL**
- **Free Tier:** 20MB database
- **Good For:** Small apps, testing
- **URL:** https://elephantsql.com

### **C. Railway PostgreSQL**
- **Free:** Included with $5 credit
- **Storage:** Shared with app hosting
- **Integrated:** One-click setup

### **D. Render PostgreSQL**
- **Free Tier:** 90-day free databases (renewable)
- **Storage:** Limited
- **Best with:** Render web service

### **E. Neon**
- **Free Tier:** 10GB storage, 10M queries/month
- **Features:** Serverless PostgreSQL
- **URL:** https://neon.tech

---

## Comparison Table

| Database | Storage | Cost | Best For |
|----------|---------|------|----------|
| **SQLite** | 3GB | $0 | Fly.io/Railway |
| **Supabase** | 500MB | $0 | Production apps |
| **ElephantSQL** | 20MB | $0 | Testing |
| **Railway PG** | Shared | $0* | Railway users |
| **Render PG** | Limited | $0 | Render users |
| **Neon** | 10GB | $0 | Large apps |

*Uses your $5/month credit

---

## Migration Guide: SQLite → PostgreSQL

If you need to switch to PostgreSQL:

### 1. Install PostgreSQL Package

```bash
cd SecurityGuardApi
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
```

### 2. Update Program.cs

```csharp
// Replace SQLite line:
// options.UseSqlite(configuration.GetConnectionString("DefaultConnection")));

// With PostgreSQL:
var connectionString = Environment.GetEnvironmentVariable("DATABASE_URL") 
    ?? configuration.GetConnectionString("DefaultConnection");

// Handle Heroku-style URLs (postgres:// -> convert to postgresql://)
if (connectionString.StartsWith("postgres://"))
{
    connectionString = connectionString.Replace("postgres://", "postgresql://");
}

options.UseNpgsql(connectionString);
```

### 3. Update appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=guardcore;Username=postgres;Password=yourpass"
  }
}
```

### 4. Generate New Migrations

```bash
# Remove old SQLite migrations
rm -rf Migrations

# Create new PostgreSQL migrations
dotnet ef migrations add InitialCreate
```

### 5. Deploy with Database URL

Set environment variable on your platform:

```bash
# Fly.io
flyctl secrets set DATABASE_URL="postgresql://user:pass@host:5432/dbname"

# Railway (auto-connects if you add PostgreSQL service)
railway add postgresql

# Render (add as environment variable in dashboard)
DATABASE_URL=postgresql://user:pass@host:5432/dbname
```

---

## 💡 My Recommendation

### For Most Users: **Stick with SQLite on Fly.io**

Why?
- ✅ Zero code changes
- ✅ Zero config
- ✅ Simpler
- ✅ Faster (no network calls)
- ✅ Free persistent storage
- ✅ Perfect for small-medium apps

### When to Use PostgreSQL:

- Multiple server instances needed
- Database > 3GB
- Advanced features (full-text search, JSON queries)
- Team collaboration on DB
- Need automatic backups

---

## Database Backups (Important!)

### SQLite on Fly.io:

```bash
# Download backup
flyctl ssh sftp get /app/data/securityguard.db ./backup.db

# Upload restore
flyctl ssh sftp shell
put ./backup.db /app/data/securityguard.db
```

### PostgreSQL:

Most free services include automatic backups:
- **Supabase:** Daily backups (7 days retention)
- **Railway:** Point-in-time recovery
- **Neon:** Automatic with branch feature

Manual backup:
```bash
pg_dump $DATABASE_URL > backup.sql
# Restore:
psql $DATABASE_URL < backup.sql
```

---

## Quick Decision Guide

**Choose SQLite if:**
- Your app serves < 1000 users
- Single deployment region
- Want simplest setup
- No complex queries needed

**Choose PostgreSQL if:**
- Need to scale horizontally
- Want built-in replication
- Team needs direct DB access
- Using advanced SQL features
- Database > 3GB

---

## 🎯 Bottom Line

**For zero cost deployment**: SQLite + Fly.io = Perfect combo!

No migration needed, just deploy:

```bash
cd SecurityGuardApi
flyctl launch
flyctl volumes create guardcore_data --size 1
flyctl deploy
```

Done! 🚀
