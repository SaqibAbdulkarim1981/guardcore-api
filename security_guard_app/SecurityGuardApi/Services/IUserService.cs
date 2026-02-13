using SecurityGuardApi.DTOs;
using SecurityGuardApi.Models;

namespace SecurityGuardApi.Services
{
    public interface IUserService
    {
        Task<User> CreateAsync(UserCreateDto dto);
        Task<IEnumerable<User>> GetAllAsync();
        Task<User?> GetByIdAsync(int id);
        Task<bool> BlockAsync(int id, bool blocked);
        Task AutoBlockExpiredAsync();
    }
}
