using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SecurityGuardApi.Data;
using SecurityGuardApi.DTOs;
using SecurityGuardApi.Services;
using System.Security.Claims;

namespace SecurityGuardApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _svc;
        private readonly AppDbContext _context;
        
        public UsersController(IUserService svc, AppDbContext context) 
        { 
            _svc = svc;
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] UserCreateDto dto)
        {
            var user = await _svc.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _svc.GetAllAsync();
            return Ok(list);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var user = await _svc.GetByIdAsync(id);
            if (user == null) return NotFound();
            return Ok(user);
        }

        // GET: api/Users/me - Get current authenticated user
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var emailClaim = User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(emailClaim))
            {
                return Unauthorized(new { message = "User not authenticated" });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == emailClaim);
            if (user == null)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(new
            {
                id = user.Id,
                name = user.Name,
                email = user.Email,
                isBlocked = user.IsBlocked,
                expiryDate = user.ExpiryDate
            });
        }

        // POST: api/Users/reset-password
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            var emailClaim = User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(emailClaim))
            {
                return Unauthorized(new { message = "User not authenticated" });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == emailClaim);
            if (user == null)
            {
                return NotFound(new { message = "User not found" });
            }

            // Verify current password
            if (!BCrypt.Net.BCrypt.Verify(dto.CurrentPassword, user.PasswordHash))
            {
                return BadRequest(new { message = "Current password is incorrect" });
            }

            // Hash and update new password
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Password changed successfully" });
        }

        [HttpPost("{id:int}/block")]
        public async Task<IActionResult> Block(int id)
        {
            var ok = await _svc.BlockAsync(id, true);
            return ok ? NoContent() : NotFound();
        }

        [HttpPost("{id:int}/unblock")]
        public async Task<IActionResult> Unblock(int id)
        {
            var ok = await _svc.BlockAsync(id, false);
            return ok ? NoContent() : NotFound();
        }
    }

    public class ResetPasswordDto
    {
        public string CurrentPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}
