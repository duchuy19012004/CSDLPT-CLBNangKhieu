using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class BienLaiController : Controller
    {
        private readonly DbContext _dbContext;

        public BienLaiController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();
            var bienLais = await conn.QueryAsync<BienLai>(
                @"SELECT bl.*, sv.HoTenSV as TenSV 
                  FROM vw_BienLai bl 
                  LEFT JOIN vw_SinhVien sv ON bl.MaSV = sv.MaSV");
            return View(bienLais);
        }

        public async Task<IActionResult> Create()
        {
            using var conn = _dbContext.GetConnection();
            ViewBag.LopNangKhieus = await conn.QueryAsync<LopNangKhieu>("SELECT * FROM vw_LopNangKhieu");
            ViewBag.SinhViens = await conn.QueryAsync<SinhVien>("SELECT * FROM vw_SinhVien");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(BienLai model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "INSERT INTO vw_BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien) VALUES (@SoBL, @Thang, @Nam, @MaLop, @MaSV, @SoTien)",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            using var conn = _dbContext.GetConnection();
            var bienLai = await conn.QueryFirstOrDefaultAsync<BienLai>(
                "SELECT * FROM vw_BienLai WHERE SoBL = @Id", new { Id = id });
            if (bienLai == null) return NotFound();
            ViewBag.LopNangKhieus = await conn.QueryAsync<LopNangKhieu>("SELECT * FROM vw_LopNangKhieu");
            ViewBag.SinhViens = await conn.QueryAsync<SinhVien>("SELECT * FROM vw_SinhVien");
            return View(bienLai);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(BienLai model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "UPDATE vw_BienLai SET Thang = @Thang, Nam = @Nam, MaLop = @MaLop, MaSV = @MaSV, SoTien = @SoTien WHERE SoBL = @SoBL",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            using var conn = _dbContext.GetConnection();
            await conn.ExecuteAsync("DELETE FROM vw_BienLai WHERE SoBL = @Id", new { Id = id });
            return RedirectToAction(nameof(Index));
        }
    }
}
