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
    }
}
