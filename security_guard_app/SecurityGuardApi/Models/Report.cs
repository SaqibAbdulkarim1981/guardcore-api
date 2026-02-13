using System.ComponentModel.DataAnnotations;

namespace SecurityGuardApi.Models
{
    public class Report
    {
        public int Id { get; set; }
        public int? UserId { get; set; }
        public int? LocationId { get; set; }
        [Required] public string Type { get; set; } = "";
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
