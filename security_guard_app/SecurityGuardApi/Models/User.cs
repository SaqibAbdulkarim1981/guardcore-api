using System.ComponentModel.DataAnnotations;

namespace SecurityGuardApi.Models
{
    public class User
    {
        public int Id { get; set; }
        [Required] public string Name { get; set; } = "";
        [Required] public string Email { get; set; } = "";
        [Required] public string PasswordHash { get; set; } = "";
        public bool IsBlocked { get; set; }
        public DateTime? ExpiryDate { get; set; }
        public int ActiveDays { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
