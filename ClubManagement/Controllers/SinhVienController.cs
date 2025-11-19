using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class SinhVienController : Controller
    {
        private readonly DbContext _dbContext;

        public SinhVienController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();
            var sinhViens = await conn.QueryAsync<SinhVien>(
                @"SELECT sv.*, clb.TenCLB 
                  FROM vw_SinhVien sv 
                  LEFT JOIN vw_CauLacBo clb ON sv.MaCLB = clb.MaCLB");
            return View(sinhViens);
        }

        public async Task<IActionResult> Create()
        {
            using var conn = _dbContext.GetConnection();
            ViewBag.CauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(SinhVien model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "INSERT INTO vw_SinhVien (MaSV, HoTenSV, MaCLB) VALUES (@MaSV, @HoTenSV, @MaCLB)",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        public async Task<IActionResult> Edit(string id)
        {
            using var conn = _dbContext.GetConnection();
            var sinhVien = await conn.QueryFirstOrDefaultAsync<SinhVien>(
                "SELECT * FROM vw_SinhVien WHERE MaSV = @Id", new { Id = id });
            if (sinhVien == null) return NotFound();
            ViewBag.CauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View(sinhVien);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(SinhVien model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "UPDATE vw_SinhVien SET HoTenSV = @HoTenSV, MaCLB = @MaCLB WHERE MaSV = @MaSV",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(string id)
        {
            using var conn = _dbContext.GetConnection();
            await conn.ExecuteAsync("DELETE FROM vw_SinhVien WHERE MaSV = @Id", new { Id = id });
            return RedirectToAction(nameof(Index));
        }
    }
}
