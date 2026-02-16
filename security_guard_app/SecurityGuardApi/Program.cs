using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SecurityGuardApi.Data;
using SecurityGuardApi.Services;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;

// Listen on all network interfaces for LAN access
builder.WebHost.UseUrls("http://0.0.0.0:5000");

// PostgreSQL-only configuration
// Try DATABASE_URL first (Render/Railway standard), then ConnectionStrings__DefaultConnection
var connectionString = Environment.GetEnvironmentVariable("DATABASE_URL") 
    ?? configuration.GetConnectionString("DefaultConnection");

if (string.IsNullOrEmpty(connectionString))
{
    Console.WriteLine("❌ ERROR: No database connection string found!");
    Console.WriteLine("   Set DATABASE_URL environment variable or ConnectionStrings:DefaultConnection in appsettings.json");
    throw new InvalidOperationException("Database connection string is required");
}

// Remove any surrounding brackets or quotes
connectionString = connectionString.Trim().Trim('[', ']', '"', '\'');

Console.WriteLine($"[DEBUG] Connection string length: {connectionString.Length}");
Console.WriteLine($"[DEBUG] First 20 chars: {(connectionString.Length > 20 ? connectionString.Substring(0, 20) : connectionString)}");

// Convert postgres:// to postgresql:// for Npgsql compatibility
if (connectionString.StartsWith("postgres://"))
{
    connectionString = connectionString.Replace("postgres://", "postgresql://");
}

// Convert PostgreSQL URI to connection string format if needed
if (connectionString.StartsWith("postgresql://"))
{
    try
    {
        var uri = new Uri(connectionString);
        var userInfo = uri.UserInfo.Split(':');
        var port = uri.Port > 0 ? uri.Port : 5432;
        connectionString = $"Host={uri.Host};Port={port};Database={uri.AbsolutePath.TrimStart('/')};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=true";
        Console.WriteLine("✅ PostgreSQL URI converted successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ ERROR converting PostgreSQL URI: {ex.Message}");
        throw;
    }
}

Console.WriteLine("✅ Using PostgreSQL database");

// Configure DbContext with PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseNpgsql(connectionString);
});

builder.Services.AddScoped<IUserService, UserService>();

var jwtKey = configuration["Jwt:Key"] ?? "CHANGE_THIS_SECRET_KEY";
var key = Encoding.ASCII.GetBytes(jwtKey);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add CORS support for Flutter app
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        db.Database.Migrate();
        Console.WriteLine("✅ Database migrations applied successfully");
        
        // Try to seed database - don't fail if it doesn't work
        try
        {
            SecurityGuardApi.DatabaseSeeder.SeedDatabase(db);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"⚠️  Database seeding failed (this is OK for first deployment): {ex.Message}");
            Console.WriteLine("💡 You can create users manually through the API");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Database error: {ex.Message}");
        throw;
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Enable CORS
app.UseCors();

// Disabled for local development - Re-enable for production
// app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
