namespace ClubManagement.Models
{
    public class ActivityLog
    {
        public int LogId { get; set; }
        public string Action { get; set; } = string.Empty;
        public string TableName { get; set; } = string.Empty;
        public string? RecordId { get; set; }
        public string? Site { get; set; }
        public string? Username { get; set; }
        public DateTime Timestamp { get; set; }
        public string? Details { get; set; }
    }
}
