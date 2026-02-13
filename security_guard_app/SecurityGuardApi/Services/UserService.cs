using Microsoft.EntityFrameworkCore;
using SecurityGuardApi.Data;
using SecurityGuardApi.DTOs;
using SecurityGuardApi.Models;

namespace SecurityGuardApi.Services
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _db;
        public UserService(AppDbContext db) { _db = db; }

        public async Task<User> CreateAsync(UserCreateDto dto)
        {
            var expiry = DateTime.UtcNow.AddDays(dto.ActiveDays);
            var user = new User
            {
                Name = dto.Name,
                Email = dto.Email,
                ActiveDays = dto.ActiveDays,
                ExpiryDate = expiry,
                IsBlocked = false
            };

            _db.Users.Add(user);
            await _db.SaveChangesAsync();
            return user;
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            await AutoBlockExpiredAsync();
            return await _db.Users.OrderByDescending(u => u.CreatedAt).ToListAsync();
        }

        public async Task<User?> GetByIdAsync(int id)
        {
            await AutoBlockExpiredAsync();
            return await _db.Users.FindAsync(id);
        }

        public async Task<bool> BlockAsync(int id, bool blocked)
        {
            var user = await _db.Users.FindAsync(id);
            if (user == null) return false;
            user.IsBlocked = blocked;
            await _db.SaveChangesAsync();
            return true;
        }

        public async Task AutoBlockExpiredAsync()
        {
            var now = DateTime.UtcNow;
            var expired = await _db.Users
                .Where(u => !u.IsBlocked && u.ExpiryDate != null && u.ExpiryDate <= now)
                .ToListAsync();

            if (!expired.Any()) return;

            foreach (var u in expired)
            {
                u.IsBlocked = true;
            }

            await _db.SaveChangesAsync();
        }
    }
}
