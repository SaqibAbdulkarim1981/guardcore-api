using System.ComponentModel.DataAnnotations;

namespace SecurityGuardApi.Models
{
    public class Location
    {
        public int Id { get; set; }
        [Required] public string Name { get; set; } = "";
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
