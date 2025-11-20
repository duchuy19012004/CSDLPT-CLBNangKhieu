using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class LopNangKhieu
    {
        [Display(Name = "Mã lớp")]
        [Range(1, int.MaxValue, ErrorMessage = "Mã lớp phải lớn hơn 0")]
        public int MaLop { get; set; }

        [Display(Name = "Ngày mở")]
        [Required(ErrorMessage = "Ngày mở là bắt buộc")]
        [DataType(DataType.Date)]
        public DateTime NgayMo { get; set; }

        [Display(Name = "Mã giảng viên")]
        [Required(ErrorMessage = "Vui lòng chọn giảng viên")]
        [StringLength(10, ErrorMessage = "Mã giảng viên không hợp lệ")]
        public string MaGV { get; set; } = string.Empty;

        [Display(Name = "Học phí")]
        [Required(ErrorMessage = "Học phí là bắt buộc")]
        [Range(0, 999999999, ErrorMessage = "Học phí phải từ 0 đến 999,999,999")]
        [DataType(DataType.Currency)]
        public decimal HocPhi { get; set; }

        public string? TenGV { get; set; }
    }
}
