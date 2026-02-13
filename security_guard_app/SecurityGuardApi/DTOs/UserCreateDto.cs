using System.ComponentModel.DataAnnotations;

namespace SecurityGuardApi.DTOs
{
    public class UserCreateDto
    {
        [Required] public string Name { get; set; } = "";
        [Required] [EmailAddress] public string Email { get; set; } = "";
        public int ActiveDays { get; set; } = 30;
    }
}
