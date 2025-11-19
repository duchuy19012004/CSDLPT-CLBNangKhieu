using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class LopNangKhieuController : Controller
    {
        private readonly DbContext _dbContext;

        public LopNangKhieuController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();
            var lops = await conn.QueryAsync<LopNangKhieu>(
                @"SELECT l.*, gv.HoTenGV as TenGV 
                  FROM vw_LopNangKhieu l 
                  LEFT JOIN vw_GiangVien gv ON l.MaGV = gv.MaGV");
            return View(lops);
        }

        public async Task<IActionResult> Create()
        {
            using var conn = _dbContext.GetConnection();
            ViewBag.GiangViens = await conn.QueryAsync<GiangVien>("SELECT * FROM vw_GiangVien");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(LopNangKhieu model)
        {
            // Xóa validation cho MaLop vì sẽ tự động sinh
            ModelState.Remove("MaLop");
            
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                
                // Lấy mã lớp lớn nhất hiện tại
                var maxId = await conn.ExecuteScalarAsync<int?>("SELECT MAX(MaLop) FROM vw_LopNangKhieu") ?? 0;
                model.MaLop = maxId + 1;
                
                await conn.ExecuteAsync(
                    "INSERT INTO vw_LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi) VALUES (@MaLop, @NgayMo, @MaGV, @HocPhi)",
                    model);
                return RedirectToAction(nameof(Index));
            }
            
            ViewBag.GiangViens = await _dbContext.GetConnection().QueryAsync<GiangVien>("SELECT * FROM vw_GiangVien");
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            using var conn = _dbContext.GetConnection();
            var lop = await conn.QueryFirstOrDefaultAsync<LopNangKhieu>(
                "SELECT * FROM vw_LopNangKhieu WHERE MaLop = @Id", new { Id = id });
            if (lop == null) return NotFound();
            ViewBag.GiangViens = await conn.QueryAsync<GiangVien>("SELECT * FROM vw_GiangVien");
            return View(lop);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(LopNangKhieu model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "UPDATE vw_LopNangKhieu SET NgayMo = @NgayMo, MaGV = @MaGV, HocPhi = @HocPhi WHERE MaLop = @MaLop",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            using var conn = _dbContext.GetConnection();
            await conn.ExecuteAsync("DELETE FROM vw_LopNangKhieu WHERE MaLop = @Id", new { Id = id });
            return RedirectToAction(nameof(Index));
        }
    }
}
