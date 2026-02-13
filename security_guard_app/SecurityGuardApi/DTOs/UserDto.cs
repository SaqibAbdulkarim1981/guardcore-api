namespace SecurityGuardApi.DTOs
{
    public class UserDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public bool IsBlocked { get; set; }
        public DateTime? ExpiryDate { get; set; }
        public int ActiveDays { get; set; }
    }
}
