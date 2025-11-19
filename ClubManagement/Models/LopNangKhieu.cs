namespace ClubManagement.Models
{
    public class LopNangKhieu
    {
        public int MaLop { get; set; }
        public DateTime NgayMo { get; set; }
        public string MaGV { get; set; } = string.Empty;
        public decimal HocPhi { get; set; }
        public string? TenGV { get; set; }
    }
}
