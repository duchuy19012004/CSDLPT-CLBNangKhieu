using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class DashboardController : Controller
    {
        private readonly DbContext _dbContext;

        public DashboardController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();

            var model = new DashboardViewModel
            {
                // Site A - TPHCM
                SiteA_CLB = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.CauLacBo"),
                SiteA_GV = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.GiangVien"),
                SiteA_SV = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.SinhVien"),
                SiteA_Lop = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.LopNangKhieu"),
                SiteA_BienLai = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.BienLai"),
                SiteA_Revenue = await conn.ExecuteScalarAsync<decimal?>("SELECT ISNULL(SUM(SoTien), 0) FROM SiteA.dbo.BienLai") ?? 0,

                // Site B - Hà Nội
                SiteB_CLB = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.CauLacBo"),
                SiteB_GV = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.GiangVien"),
                SiteB_SV = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.SinhVien"),
                SiteB_Lop = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.LopNangKhieu"),
                SiteB_BienLai = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.BienLai"),
                SiteB_Revenue = await conn.ExecuteScalarAsync<decimal?>("SELECT ISNULL(SUM(SoTien), 0) FROM SiteB.dbo.BienLai") ?? 0
            };

            // Tổng
            model.TotalCLB = model.SiteA_CLB + model.SiteB_CLB;
            model.TotalGV = model.SiteA_GV + model.SiteB_GV;
            model.TotalSV = model.SiteA_SV + model.SiteB_SV;
            model.TotalLop = model.SiteA_Lop + model.SiteB_Lop;
            model.TotalBienLai = model.SiteA_BienLai + model.SiteB_BienLai;
            model.TotalRevenue = model.SiteA_Revenue + model.SiteB_Revenue;

            return View(model);
        }
    }
}
