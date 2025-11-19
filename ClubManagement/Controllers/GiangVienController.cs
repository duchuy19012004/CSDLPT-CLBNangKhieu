using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class GiangVienController : Controller
    {
        private readonly DbContext _dbContext;

        public GiangVienController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();
            var giangViens = await conn.QueryAsync<GiangVien>(
                @"SELECT gv.*, clb.TenCLB 
                  FROM vw_GiangVien gv 
                  LEFT JOIN vw_CauLacBo clb ON gv.MaCLB = clb.MaCLB");
            return View(giangViens);
        }

        public async Task<IActionResult> Create()
        {
            using var conn = _dbContext.GetConnection();
            ViewBag.CauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(GiangVien model)
        {
            // Xóa validation cho MaGV vì sẽ tự động sinh
            ModelState.Remove("MaGV");
            
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                
                // Lấy số thứ tự lớn nhất từ mã GV (GV1, GV2, ...)
                var maxGV = await conn.QueryFirstOrDefaultAsync<string>(
                    "SELECT TOP 1 MaGV FROM vw_GiangVien ORDER BY CAST(SUBSTRING(MaGV, 3, LEN(MaGV)) AS INT) DESC");
                
                int nextNumber = 1;
                if (!string.IsNullOrEmpty(maxGV))
                {
                    nextNumber = int.Parse(maxGV.Substring(2)) + 1;
                }
                model.MaGV = $"GV{nextNumber}";
                
                await conn.ExecuteAsync(
                    "INSERT INTO vw_GiangVien (MaGV, HoTenGV, MaCLB) VALUES (@MaGV, @HoTenGV, @MaCLB)",
                    model);
                return RedirectToAction(nameof(Index));
            }
            
            ViewBag.CauLacBos = await _dbContext.GetConnection().QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View(model);
        }

        public async Task<IActionResult> Edit(string id)
        {
            using var conn = _dbContext.GetConnection();
            var giangVien = await conn.QueryFirstOrDefaultAsync<GiangVien>(
                "SELECT * FROM vw_GiangVien WHERE MaGV = @Id", new { Id = id });
            if (giangVien == null) return NotFound();
            ViewBag.CauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View(giangVien);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(GiangVien model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "UPDATE vw_GiangVien SET HoTenGV = @HoTenGV, MaCLB = @MaCLB WHERE MaGV = @MaGV",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(string id)
        {
            using var conn = _dbContext.GetConnection();
            await conn.ExecuteAsync("DELETE FROM vw_GiangVien WHERE MaGV = @Id", new { Id = id });
            return RedirectToAction(nameof(Index));
        }
    }
}
