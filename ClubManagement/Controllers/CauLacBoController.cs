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

        public async Task<IActionResult> Index()
        {
            using var conn = _dbContext.GetConnection();
            var cauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
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
            using var conn = _dbContext.GetConnection();
            await conn.ExecuteAsync("DELETE FROM vw_CauLacBo WHERE MaCLB = @Id", new { Id = id });
            return RedirectToAction(nameof(Index));
        }
    }
}
