using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class FragmentationConfigController : Controller
    {
        private readonly DbContext _dbContext;

        public FragmentationConfigController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        // Hiển thị danh sách cấu hình
        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();
            var configs = await conn.QueryAsync<FragmentationConfig>(
                "SELECT * FROM FragmentationConfig ORDER BY ConfigKey");
            return View(configs);
        }

        // Form chỉnh sửa cấu hình
        public async Task<IActionResult> Edit(string configKey)
        {
            using var conn = _dbContext.GetConnection();
            var config = await conn.QueryFirstOrDefaultAsync<FragmentationConfig>(
                "SELECT * FROM FragmentationConfig WHERE ConfigKey = @ConfigKey",
                new { ConfigKey = configKey });
            
            if (config == null) return NotFound();
            return View(config);
        }

        // Cập nhật cấu hình
        [HttpPost]
        public async Task<IActionResult> Edit(FragmentationConfig model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    @"UPDATE FragmentationConfig 
                      SET ConfigValue = @ConfigValue, 
                          Description = @Description,
                          LastModified = GETDATE()
                      WHERE ConfigKey = @ConfigKey",
                    model);
                
                TempData["SuccessMessage"] = $"Đã cập nhật cấu hình {model.ConfigKey}";
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        // Xem thống kê phân bổ dữ liệu
        public async Task<IActionResult> Statistics()
        {
            using var conn = _dbContext.GetConnection();
            
            var stats = new Dictionary<string, object>();
            
            // Đếm số lượng ở mỗi site
            stats["CauLacBo_SiteA"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.CauLacBo");
            stats["CauLacBo_SiteB"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.CauLacBo");
            
            stats["GiangVien_SiteA"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.GiangVien");
            stats["GiangVien_SiteB"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.GiangVien");
            
            stats["SinhVien_SiteA"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.SinhVien");
            stats["SinhVien_SiteB"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.SinhVien");
            
            stats["LopNangKhieu_SiteA"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.LopNangKhieu");
            stats["LopNangKhieu_SiteB"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.LopNangKhieu");
            
            stats["BienLai_SiteA"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteA.dbo.BienLai");
            stats["BienLai_SiteB"] = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM SiteB.dbo.BienLai");
            
            return View(stats);
        }
    }
}
