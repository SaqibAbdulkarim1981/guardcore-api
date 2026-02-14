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

// Support both SQLite (local) and PostgreSQL (production)
// Try DATABASE_URL first (Render standard), then ConnectionStrings__DefaultConnection
var connectionString = Environment.GetEnvironmentVariable("DATABASE_URL") 
    ?? configuration.GetConnectionString("DefaultConnection");

// Remove any surrounding brackets or quotes that might have been copy-pasted
if (connectionString != null)
{
    connectionString = connectionString.Trim();
    connectionString = connectionString.TrimStart('[', '"', '\'');
    connectionString = connectionString.TrimEnd(']', '"', '\'');
    connectionString = connectionString.Trim();
}

Console.WriteLine($"[DEBUG] Original connection string length: {connectionString?.Length ?? 0}");
Console.WriteLine($"[DEBUG] First 20 chars: {(connectionString != null && connectionString.Length > 20 ? connectionString.Substring(0, 20) : connectionString ?? "null")}");
Console.WriteLine($"[DEBUG] Last 20 chars: {(connectionString != null && connectionString.Length > 20 ? connectionString.Substring(connectionString.Length - 20) : connectionString ?? "null")}");

// Convert postgres:// to postgresql:// for Npgsql compatibility
if (connectionString != null && connectionString.StartsWith("postgres://"))
{
    connectionString = connectionString.Replace("postgres://", "postgresql://");
}

Console.WriteLine($"Connection string found: {!string.IsNullOrEmpty(connectionString)}");
Console.WriteLine($"Connection string length: {connectionString?.Length ?? 0}");
Console.WriteLine($"Connection string starts with: {(connectionString != null && connectionString.Length > 15 ? connectionString.Substring(0, 15) : connectionString ?? "null")}");

bool isPostgreSQL = connectionString?.StartsWith("postgresql") == true;
Console.WriteLine($"Using database: {(isPostgreSQL ? "PostgreSQL" : "SQLite")}");

// Convert PostgreSQL URI to connection string format if needed
if (isPostgreSQL)
{
    try
    {
        var uri = new Uri(connectionString!);
        var userInfo = uri.UserInfo.Split(':');
        var port = uri.Port > 0 ? uri.Port : 5432; // Default PostgreSQL port
        connectionString = $"Host={uri.Host};Port={port};Database={uri.AbsolutePath.TrimStart('/')};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=true";
        Console.WriteLine($"Converted to key-value format successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"ERROR converting URI: {ex.Message}");
        throw;
    }
}

// Don't validate URI format here - let Entity Framework handle it directly

builder.Services.AddDbContext<AppDbContext>(options =>
{
    if (isPostgreSQL)
    {
        // Use PostgreSQL for Render.com/cloud hosting
        options.UseNpgsql(connectionString!);
    }
    else
    {
        // Use SQLite for local development
        options.UseSqlite(connectionString ?? "Data Source=securityguard.db");
    }
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
    db.Database.Migrate();
    
    // Seed database with test data
    SecurityGuardApi.DatabaseSeeder.SeedDatabase(db);
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
