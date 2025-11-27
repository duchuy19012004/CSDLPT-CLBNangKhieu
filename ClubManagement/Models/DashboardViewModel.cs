namespace ClubManagement.Models
{
    public class DashboardViewModel
    {
        // Tổng số liệu
        public int TotalCLB { get; set; }
        public int TotalGV { get; set; }
        public int TotalSV { get; set; }
        public int TotalLop { get; set; }
        public int TotalBienLai { get; set; }

        // Site A - TPHCM
        public int SiteA_CLB { get; set; }
        public int SiteA_GV { get; set; }
        public int SiteA_SV { get; set; }
        public int SiteA_Lop { get; set; }
        public int SiteA_BienLai { get; set; }

        // Site B - Hà Nội
        public int SiteB_CLB { get; set; }
        public int SiteB_GV { get; set; }
        public int SiteB_SV { get; set; }
        public int SiteB_Lop { get; set; }
        public int SiteB_BienLai { get; set; }

        // Tổng doanh thu
        public decimal TotalRevenue { get; set; }
        public decimal SiteA_Revenue { get; set; }
        public decimal SiteB_Revenue { get; set; }
    }
}
