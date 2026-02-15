using System.ComponentModel.DataAnnotations;

namespace SecurityGuardApi.DTOs
{
    public class LoginDto
    {
        [Required] public string Email { get; set; } = "";
        [Required] public string Password { get; set; } = "";
    }

    public class RegisterDto
    {
        [Required] public string Email { get; set; } = "";
        [Required] public string Password { get; set; } = "";
        public string? Name { get; set; }
    }
}
