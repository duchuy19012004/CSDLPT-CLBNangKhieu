namespace ClubManagement.Models
{
    public class BienLai
    {
        public int SoBL { get; set; }
        public int Thang { get; set; }
        public int Nam { get; set; }
        public int MaLop { get; set; }
        public string MaSV { get; set; } = string.Empty;
        public decimal SoTien { get; set; }
        public string? TenSV { get; set; }
    }
}
