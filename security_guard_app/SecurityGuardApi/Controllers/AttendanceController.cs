using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SecurityGuardApi.Data;
using SecurityGuardApi.Models;
using System.Security.Claims;

namespace SecurityGuardApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AttendanceController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AttendanceController(AppDbContext context)
        {
            _context = context;
        }

        // POST: api/Attendance
        [HttpPost]
        public async Task<IActionResult> RecordAttendance([FromBody] AttendanceDto dto)
        {
            try
            {
                // Get user from JWT token
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

                // Check if user is blocked or expired
                if (user.IsBlocked)
                {
                    return BadRequest(new { message = "Your access has been blocked" });
                }

                if (user.ExpiryDate.HasValue && user.ExpiryDate.Value < DateTime.UtcNow)
                {
                    return BadRequest(new { message = "Your access has expired" });
                }

                // Parse location ID from QR data (assuming QR contains locationId)
                if (!int.TryParse(dto.QRData, out int locationId))
                {
                    return BadRequest(new { message = "Invalid QR code" });
                }

                var location = await _context.Locations.FindAsync(locationId);
                if (location == null)
                {
                    return NotFound(new { message = "Location not found" });
                }

                // Determine if this is check-in or check-out
                var lastAttendance = await _context.Set<Attendance>()
                    .Where(a => a.UserId == user.Id && a.LocationId == locationId)
                    .OrderByDescending(a => a.Timestamp)
                    .FirstOrDefaultAsync();

                string attendanceType = "CheckIn";
                if (lastAttendance != null && lastAttendance.Type == "CheckIn")
                {
                    // If last was CheckIn, this is CheckOut
                    attendanceType = "CheckOut";
                }

                var attendance = new Attendance
                {
                    UserId = user.Id,
                    LocationId = locationId,
                    Type = attendanceType,
                    Timestamp = DateTime.UtcNow,
                    QRData = dto.QRData
                };

                _context.Set<Attendance>().Add(attendance);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = $"{attendanceType} recorded successfully at {location.Name}",
                    type = attendanceType,
                    location = location.Name,
                    timestamp = attendance.Timestamp,
                    user = user.Name
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Error recording attendance: {ex.Message}" });
            }
        }

        // GET: api/Attendance
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Attendance>>> GetAttendance()
        {
            return await _context.Set<Attendance>()
                .OrderByDescending(a => a.Timestamp)
                .ToListAsync();
        }

        // GET: api/Attendance/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<Attendance>>> GetUserAttendance(int userId)
        {
            return await _context.Set<Attendance>()
                .Where(a => a.UserId == userId)
                .OrderByDescending(a => a.Timestamp)
                .ToListAsync();
        }
    }

    public class AttendanceDto
    {
        public string QRData { get; set; } = string.Empty;
        public string? Timestamp { get; set; }
    }
}
