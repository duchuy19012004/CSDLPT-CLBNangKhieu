using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class TruyVanController : Controller
    {
        private readonly DbContext _dbContext;

        public TruyVanController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public IActionResult Index()
        {
            return View();
        }

        // Truy vấn 1: Biên lai của các lớp do giảng viên GV5 giảng dạy
        public async Task<IActionResult> Query1()
        {
            using var conn = _dbContext.GetConnection();
            var result = await conn.QueryAsync<BienLai>(
                @"SELECT bl.SoBL, bl.Thang, bl.Nam, bl.SoTien, bl.MaLop, bl.MaSV
                  FROM vw_BienLai bl
                  JOIN vw_LopNangKhieu l ON bl.MaLop = l.MaLop
                  WHERE l.MaGV = 'GV5'");
            return View(result);
        }

        // Truy vấn 2: Tổng học phí sinh viên đóng cho một lớp
        public async Task<IActionResult> Query2()
        {
            using var conn = _dbContext.GetConnection();
            ViewBag.LopNangKhieus = await conn.QueryAsync<LopNangKhieu>("SELECT * FROM vw_LopNangKhieu");
            ViewBag.SinhViens = await conn.QueryAsync<SinhVien>("SELECT * FROM vw_SinhVien");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Query2(int maLop, string maSV)
        {
            using var conn = _dbContext.GetConnection();
            var tongTien = await conn.ExecuteScalarAsync<decimal>(
                @"SELECT ISNULL(SUM(SoTien), 0)
                  FROM vw_BienLai
                  WHERE MaLop = @MaLop AND MaSV = @MaSV",
                new { MaLop = maLop, MaSV = maSV });
            
            ViewBag.TongTien = tongTien;
            ViewBag.MaLop = maLop;
            ViewBag.MaSV = maSV;
            ViewBag.LopNangKhieus = await conn.QueryAsync<LopNangKhieu>("SELECT * FROM vw_LopNangKhieu");
            ViewBag.SinhViens = await conn.QueryAsync<SinhVien>("SELECT * FROM vw_SinhVien");
            return View();
        }

        // Truy vấn 3: Các lớp mở trong tháng 08 năm 2012
        public async Task<IActionResult> Query3()
        {
            using var conn = _dbContext.GetConnection();
            var result = await conn.QueryAsync<LopNangKhieu>(
                @"SELECT MaLop, NgayMo, MaGV, HocPhi
                  FROM vw_LopNangKhieu
                  WHERE MONTH(NgayMo) = 8 AND YEAR(NgayMo) = 2012");
            return View(result);
        }

        // Truy vấn 4: Cập nhật khoa của câu lạc bộ
        public async Task<IActionResult> Query4()
        {
            using var conn = _dbContext.GetConnection();
            ViewBag.CauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Query4Execute()
        {
            using var conn = _dbContext.GetConnection();
            var rowsAffected = await conn.ExecuteAsync(
                @"UPDATE vw_CauLacBo 
                  SET TenKhoa = 'K2' 
                  WHERE MaCLB = 5 AND TenKhoa = 'K3'");
            
            ViewBag.Message = $"Đã cập nhật {rowsAffected} câu lạc bộ";
            ViewBag.CauLacBos = await conn.QueryAsync<CauLacBo>("SELECT * FROM vw_CauLacBo");
            return View("Query4");
        }
    }
}
