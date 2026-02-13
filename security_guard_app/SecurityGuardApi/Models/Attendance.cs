namespace SecurityGuardApi.Models
{
    public class Attendance
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int LocationId { get; set; }
        public string Type { get; set; } = "CheckIn"; // CheckIn or CheckOut
        public DateTime Timestamp { get; set; }
        public string? QRData { get; set; }
    }
}
