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

        private const int PageSize = 12;

        public async Task<IActionResult> Index(int page = 1)
        {
            using var conn = _dbContext.GetConnection();
            
            var totalRecords = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM vw_BienLai");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)PageSize);
            page = Math.Max(1, Math.Min(page, totalPages > 0 ? totalPages : 1));
            var offset = (page - 1) * PageSize;

            var bienLais = await conn.QueryAsync<BienLai>(
                @"SELECT bl.*, sv.HoTenSV as TenSV 
                  FROM vw_BienLai bl 
                  LEFT JOIN vw_SinhVien sv ON bl.MaSV = sv.MaSV
                  ORDER BY bl.SoBL
                  OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY",
                new { Offset = offset, PageSize });

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.TotalRecords = totalRecords;
            
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
            // Xóa validation cho SoBL vì sẽ tự động sinh
            ModelState.Remove("SoBL");
            
            if (ModelState.IsValid)
            {
                try
                {
                    using var conn = _dbContext.GetConnection();
                    
                    // Lấy số biên lai lớn nhất hiện tại
                    var maxId = await conn.ExecuteScalarAsync<int?>("SELECT MAX(SoBL) FROM vw_BienLai") ?? 0;
                    model.SoBL = maxId + 1;
                    
                    await conn.ExecuteAsync(
                        "INSERT INTO vw_BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien) VALUES (@SoBL, @Thang, @Nam, @MaLop, @MaSV, @SoTien)",
                        model);
                    TempData["SuccessMessage"] = "Thêm biên lai thành công!";
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK_"))
                    {
                        ModelState.AddModelError("", "Mã lớp hoặc mã sinh viên không tồn tại!");
                    }
                    else
                    {
                        ModelState.AddModelError("", $"Lỗi: {ex.Message}");
                    }
                }
            }
            
            using var connection = _dbContext.GetConnection();
            ViewBag.LopNangKhieus = await connection.QueryAsync<LopNangKhieu>("SELECT * FROM vw_LopNangKhieu");
            ViewBag.SinhViens = await connection.QueryAsync<SinhVien>("SELECT * FROM vw_SinhVien");
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
                try
                {
                    using var conn = _dbContext.GetConnection();
                    await conn.ExecuteAsync(
                        "UPDATE vw_BienLai SET Thang = @Thang, Nam = @Nam, MaLop = @MaLop, MaSV = @MaSV, SoTien = @SoTien WHERE SoBL = @SoBL",
                        model);
                    TempData["SuccessMessage"] = "Cập nhật biên lai thành công!";
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK_"))
                    {
                        ModelState.AddModelError("", "Mã lớp hoặc mã sinh viên không tồn tại!");
                    }
                    else
                    {
                        ModelState.AddModelError("", $"Lỗi: {ex.Message}");
                    }
                }
            }
            
            using var connection = _dbContext.GetConnection();
            ViewBag.LopNangKhieus = await connection.QueryAsync<LopNangKhieu>("SELECT * FROM vw_LopNangKhieu");
            ViewBag.SinhViens = await connection.QueryAsync<SinhVien>("SELECT * FROM vw_SinhVien");
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync("DELETE FROM vw_BienLai WHERE SoBL = @Id", new { Id = id });
                TempData["SuccessMessage"] = "Xóa biên lai thành công!";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = $"Lỗi khi xóa: {ex.Message}";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
