using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class CauLacBoController : Controller
    {
        private readonly DbContext _dbContext;

        public CauLacBoController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        private const int PageSize = 12;

        public async Task<IActionResult> Index(int page = 1)
        {
            using var conn = _dbContext.GetConnection();
            
            var totalRecords = await conn.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM vw_CauLacBo");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)PageSize);
            page = Math.Max(1, Math.Min(page, totalPages > 0 ? totalPages : 1));
            var offset = (page - 1) * PageSize;

            var cauLacBos = await conn.QueryAsync<CauLacBo>(
                @"SELECT * FROM vw_CauLacBo ORDER BY MaCLB
                  OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY",
                new { Offset = offset, PageSize });

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.TotalRecords = totalRecords;
            
            return View(cauLacBos);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(CauLacBo model)
        {
            // Xóa validation cho MaCLB vì sẽ tự động sinh
            ModelState.Remove("MaCLB");
            
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                
                // Lấy mã CLB lớn nhất hiện tại
                var maxId = await conn.ExecuteScalarAsync<int?>("SELECT MAX(MaCLB) FROM vw_CauLacBo") ?? 0;
                model.MaCLB = maxId + 1;
                
                await conn.ExecuteAsync(
                    "INSERT INTO vw_CauLacBo (MaCLB, TenCLB, TenKhoa) VALUES (@MaCLB, @TenCLB, @TenKhoa)",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            using var conn = _dbContext.GetConnection();
            var cauLacBo = await conn.QueryFirstOrDefaultAsync<CauLacBo>(
                "SELECT * FROM vw_CauLacBo WHERE MaCLB = @Id", new { Id = id });
            if (cauLacBo == null) return NotFound();
            return View(cauLacBo);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(CauLacBo model)
        {
            if (ModelState.IsValid)
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync(
                    "UPDATE vw_CauLacBo SET TenCLB = @TenCLB, TenKhoa = @TenKhoa WHERE MaCLB = @MaCLB",
                    model);
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                using var conn = _dbContext.GetConnection();
                await conn.ExecuteAsync("DELETE FROM vw_CauLacBo WHERE MaCLB = @Id", new { Id = id });
                TempData["SuccessMessage"] = "Xóa câu lạc bộ thành công!";
            }
            catch (Exception ex)
            {
                // Kiểm tra lỗi vi phạm ràng buộc khóa ngoại
                if (ex.Message.Contains("REFERENCE") || ex.Message.Contains("FK_"))
                {
                    TempData["ErrorMessage"] = "Không thể xóa câu lạc bộ này vì còn giảng viên hoặc sinh viên đang tham gia!";
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
