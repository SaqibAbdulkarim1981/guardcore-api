using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SecurityGuardApi.Data;
using SecurityGuardApi.DTOs;
using SecurityGuardApi.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace SecurityGuardApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly AppDbContext _context;
        
        public AuthController(IConfiguration config, AppDbContext context) 
        { 
            _config = config;
            _context = context;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            try
            {
                // Check if user already exists
                var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
                if (existingUser != null)
                {
                    return BadRequest(new { message = "User already exists" });
                }

                // Create new user
                var newUser = new User
                {
                    Name = dto.Name ?? dto.Email,
                    Email = dto.Email,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                    IsBlocked = false,
                    ActiveDays = 0,
                    ExpiryDate = DateTime.UtcNow.AddYears(1),
                    CreatedAt = DateTime.UtcNow
                };

                _context.Users.Add(newUser);
                await _context.SaveChangesAsync();

                return Ok(new { message = "User registered successfully", userId = newUser.Id });
            }
            catch (Exception ex)
            {
                var innerEx = ex.InnerException?.Message ?? "No inner exception";
                return StatusCode(500, new { message = $"Registration error: {ex.Message}", inner = innerEx, stack = ex.StackTrace });
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            try
            {
                // Find user by email in database
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
                
                if (user == null)
                {
                    return Unauthorized(new { message = "Invalid email or password" });
                }
                
                // Verify password using BCrypt
                if (!BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                {
                    return Unauthorized(new { message = "Invalid email or password" });
                }
                
                // Check if user is blocked
                if (user.IsBlocked)
                {
                    return Unauthorized(new { message = "Your account has been blocked" });
                }
                
                // Check if user is expired
                if (user.ExpiryDate.HasValue && user.ExpiryDate.Value < DateTime.UtcNow)
                {
                    return Unauthorized(new { message = "Your account has expired" });
                }

                // Generate JWT token
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.ASCII.GetBytes(_config["Jwt:Key"] ?? "CHANGE_THIS_SECRET_KEY");

                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(new[]
                    {
                        new Claim(ClaimTypes.Name, user.Email),
                        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                        new Claim("Name", user.Name)
                    }),
                    Expires = DateTime.UtcNow.AddDays(7),
                    SigningCredentials = new SigningCredentials(
                        new SymmetricSecurityKey(key), 
                        SecurityAlgorithms.HmacSha256Signature
                    )
                };

                var token = tokenHandler.CreateToken(tokenDescriptor);
                
                return Ok(new 
                { 
                    token = tokenHandler.WriteToken(token),
                    user = new 
                    {
                        id = user.Id,
                        name = user.Name,
                        email = user.Email
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Login error: {ex.Message}" });
            }
        }

        [HttpPost("fix-schema")]
        public async Task<IActionResult> FixDatabaseSchema()
        {
            try
            {
                // Check if we're using PostgreSQL
                var isPostgres = _context.Database.ProviderName?.Contains("Npgsql") ?? false;
                
                if (!isPostgres)
                {
                    return Ok(new { message = "Not PostgreSQL, no fix needed" });
                }

                // Fix 1: Convert IsBlocked from integer to boolean
                await _context.Database.ExecuteSqlRawAsync(
                    "ALTER TABLE \"Users\" ALTER COLUMN \"IsBlocked\" TYPE boolean USING \"IsBlocked\"::boolean;"
                );

                // Fix 2: Convert CreatedAt and ExpiryDate from text to timestamp
                await _context.Database.ExecuteSqlRawAsync(
                    "ALTER TABLE \"Users\" ALTER COLUMN \"CreatedAt\" TYPE timestamp USING \"CreatedAt\"::timestamp;"
                );
                
                await _context.Database.ExecuteSqlRawAsync(
                    "ALTER TABLE \"Users\" ALTER COLUMN \"ExpiryDate\" TYPE timestamp USING \"ExpiryDate\"::timestamp;"
                );

                // Fix 3: Create sequence for Id auto-increment if it doesn't exist
                await _context.Database.ExecuteSqlRawAsync(@"
                    DO $$ 
                    BEGIN
                        IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'users_id_seq') THEN
                            CREATE SEQUENCE users_id_seq;
                            ALTER TABLE ""Users"" ALTER COLUMN ""Id"" SET DEFAULT nextval('users_id_seq');
                            PERFORM setval('users_id_seq', COALESCE((SELECT MAX(""Id"") FROM ""Users""), 0) + 1, false);
                        END IF;
                    END $$;
                ");

                return Ok(new { message = "Database schema fixed successfully (boolean + timestamps + auto-increment)!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Schema fix error: {ex.Message}", inner = ex.InnerException?.Message });
            }
        }

        [HttpPost("seed")]
        public async Task<IActionResult> SeedDatabase()
        {
            try
            {
                // Check if already seeded
                var adminExists = await _context.Users.AnyAsync(u => u.Email == "admin@example.com");
                if (adminExists)
                {
                    return Ok(new { message = "Database already seeded", users = await _context.Users.CountAsync() });
                }

                // Create admin user directly
                var adminUser = new User
                {
                    Name = "Admin User",
                    Email = "admin@example.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                    IsBlocked = false,
                    ActiveDays = 0,
                    ExpiryDate = DateTime.UtcNow.AddYears(10),
                    CreatedAt = DateTime.UtcNow
                };
                _context.Users.Add(adminUser);

                // Create guard user directly
                var guardUser = new User
                {
                    Name = "Test Guard",
                    Email = "guard@test.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("guard123"),
                    IsBlocked = false,
                    ActiveDays = 0,
                    ExpiryDate = DateTime.UtcNow.AddDays(30),
                    CreatedAt = DateTime.UtcNow
                };
                _context.Users.Add(guardUser);

                // Save users
                await _context.SaveChangesAsync();
                
                return Ok(new { message = "Database seeded successfully!", users = await _context.Users.CountAsync() });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Seeding error: {ex.Message}", detail = ex.InnerException?.Message });
            }
        }

        [HttpPost("init-tables")]
        public async Task<IActionResult> InitializeTables()
        {
            try
            {
                var isPostgres = _context.Database.ProviderName?.Contains("Npgsql") ?? false;
                
                if (!isPostgres)
                {
                    return Ok(new { message = "Not PostgreSQL, using SQLite - tables created automatically" });
                }

                // Create Locations table if not exists
                await _context.Database.ExecuteSqlRawAsync(@"
                    CREATE TABLE IF NOT EXISTS ""Locations"" (
                        ""Id"" SERIAL PRIMARY KEY,
                        ""Name"" VARCHAR(255) NOT NULL,
                        ""Description"" TEXT,
                        ""CreatedAt"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                ");

                // Create Attendances table if not exists
                await _context.Database.ExecuteSqlRawAsync(@"
                    CREATE TABLE IF NOT EXISTS ""Attendances"" (
                        ""Id"" SERIAL PRIMARY KEY,
                        ""UserId"" INTEGER NOT NULL,
                        ""LocationId"" INTEGER NOT NULL,
                        ""Type"" VARCHAR(50) NOT NULL DEFAULT 'CheckIn',
                        ""Timestamp"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        ""QRData"" TEXT
                    );
                ");

                // Create Reports table if not exists
                await _context.Database.ExecuteSqlRawAsync(@"
                    CREATE TABLE IF NOT EXISTS ""Reports"" (
                        ""Id"" SERIAL PRIMARY KEY,
                        ""UserId"" INTEGER,
                        ""LocationId"" INTEGER,
                        ""Type"" VARCHAR(100),
                        ""Description"" TEXT,
                        ""CreatedAt"" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                ");

                return Ok(new { message = "Tables created successfully (Locations, Attendances, Reports)!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Table creation error: {ex.Message}", inner = ex.InnerException?.Message });
            }
        }

        [HttpPost("seed-test-data")]
        public async Task<IActionResult> SeedTestData()
        {
            try
            {                // Check if data already exists
                var existingCount = await _context.Locations.CountAsync();
                if (existingCount > 0)
                {
                    var existingAttendance = await _context.Attendances.CountAsync();
                    return Ok(new { message = "Test data already exists", locations = existingCount, attendance = existingAttendance });
                }

                // Step 1: Create location using EF Core
                Location location;
                try
                {
                    location = new Location
                    {
                        Name = "Main Entrance",
                        Description = "Front gate checkpoint",
                        CreatedAt = DateTime.UtcNow
                    };
                    
                    _context.Locations.Add(location);
                    await _context.SaveChangesAsync(); // This will populate location.Id
                }
                catch (Exception ex)
                {
                    return StatusCode(500, new { 
                        message = "Failed to create location",
                        error = ex.Message,
                        innerError = ex.InnerException?.Message,
                        stackTrace = ex.StackTrace?.Split('\n').Take(5).ToArray()
                    });
                }

                // Step 2: Create attendance records for guard (user ID 1) - past 5 days
                try  {
                    var now = DateTime.UtcNow;
                    var attendanceRecords = new List<Attendance>
                    {
                        // Day 1 (7 days ago)
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckIn", Timestamp = now.AddDays(-7).AddHours(9), QRData = "1" },
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckOut", Timestamp = now.AddDays(-7).AddHours(17), QRData = "1" },
                        
                        // Day 2
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckIn", Timestamp = now.AddDays(-6).AddHours(9), QRData = "1" },
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckOut", Timestamp = now.AddDays(-6).AddHours(18), QRData = "1" },
                        
                        // Day 3
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckIn", Timestamp = now.AddDays(-5).AddHours(8).AddMinutes(30), QRData = "1" },
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckOut", Timestamp = now.AddDays(-5).AddHours(17).AddMinutes(15), QRData = "1" },
                        
                        // Day 4
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckIn", Timestamp = now.AddDays(-4).AddHours(9).AddMinutes(15), QRData = "1" },
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckOut", Timestamp = now.AddDays(-4).AddHours(17).AddMinutes(45), QRData = "1" },
                        
                        // Day 5
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckIn", Timestamp = now.AddDays(-3).AddHours(9).AddMinutes(5), QRData = "1" },
                        new Attendance { UserId = 1, LocationId = location.Id, Type = "CheckOut", Timestamp = now.AddDays(-3).AddHours(18).AddMinutes(10), QRData = "1" }
                    };

                    _context.Attendances.AddRange(attendanceRecords);
                    await _context.SaveChangesAsync();
                }
                catch (Exception ex)
                {
                    return StatusCode(500, new { 
                        message = "Failed to create attendance records",
                        locationId = location.Id,
                        error = ex.Message,
                        innerError = ex.InnerException?.Message,
                        stackTrace = ex.StackTrace?.Split('\n').Take(5).ToArray()
                    });
                }

                // Verify counts
                var locCount = await _context.Locations.CountAsync();
                var attCount = await _context.Attendances.CountAsync();

                return Ok(new 
                { 
                    message = "Test data seeded successfully!",
                    location = location.Name,
                    locationId = location.Id,
                    locations = locCount,
                    attendance = attCount,
                    days = 5
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Seeding error: {ex.Message}", detail = ex.InnerException?.Message, stack = ex.StackTrace });
            }
        }
    }
}
