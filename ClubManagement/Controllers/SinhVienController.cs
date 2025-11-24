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
                  LEFT JOIN vw_CauLacBo clb ON sv.MaCLB = clb.MaCLB
                  ORDER BY sv.MaSV");
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
            // Xóa validation cho MaSV vì sẽ tự động sinh
            ModelState.Remove("MaSV");
            
            if (ModelState.IsValid)
            {
                try
                {
                    using var conn = _dbContext.GetConnection();
                    
                    // Lấy số thứ tự lớn nhất từ mã SV (SV001, SV002, ...)
                    var maxSV = await conn.QueryFirstOrDefaultAsync<string>(
                        "SELECT TOP 1 MaSV FROM vw_SinhVien ORDER BY CAST(SUBSTRING(MaSV, 3, LEN(MaSV)) AS INT) DESC");
                    
                    int nextNumber = 1;
                    if (!string.IsNullOrEmpty(maxSV))
                    {
                        nextNumber = int.Parse(maxSV.Substring(2)) + 1;
                    }
                    model.MaSV = $"SV{nextNumber:D3}"; // Format: SV001, SV002, ...
                    
                    await conn.ExecuteAsync(
                        "INSERT INTO vw_SinhVien (MaSV, HoTenSV, MaCLB) VALUES (@MaSV, @HoTenSV, @MaCLB)",
                        model);
                    TempData["SuccessMessage"] = "Thêm sinh viên thành công!";
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK_"))
                    {
                        ModelState.AddModelError("", "Mã câu lạc bộ không tồn tại!");
                    }
                    else
                    {
                        ModelState.AddModelError("", $"Lỗi: {ex.Message}");
                    }
                }
            }
            
            using var connection = _dbContext.GetConnection();
            ViewBag.CauLacBos = await connection.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
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
                try
                {
                    using var conn = _dbContext.GetConnection();
                    await conn.ExecuteAsync(
                        "UPDATE vw_SinhVien SET HoTenSV = @HoTenSV, MaCLB = @MaCLB WHERE MaSV = @MaSV",
                        model);
                    TempData["SuccessMessage"] = "Cập nhật sinh viên thành công!";
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK_"))
                    {
                        ModelState.AddModelError("", "Mã câu lạc bộ không tồn tại!");
                    }
                    else
                    {
                        ModelState.AddModelError("", $"Lỗi: {ex.Message}");
                    }
                }
            }
            
            using var connection = _dbContext.GetConnection();
            ViewBag.CauLacBos = await connection.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync("DELETE FROM vw_SinhVien WHERE MaSV = @Id", new { Id = id });
                TempData["SuccessMessage"] = "Xóa sinh viên thành công!";
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK_"))
                {
                    TempData["ErrorMessage"] = "Không thể xóa sinh viên này vì còn biên lai liên quan!";
                }
                else
                {
                    TempData["ErrorMessage"] = $"Lỗi khi xóa: {ex.Message}";
                }
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
