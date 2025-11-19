using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class LopNangKhieu
    {
        [Display(Name = "Mã lớp")]
        [Required(ErrorMessage = "Mã lớp là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Mã lớp phải lớn hơn 0")]
        public int MaLop { get; set; }

        [Display(Name = "Ngày mở")]
        [Required(ErrorMessage = "Ngày mở là bắt buộc")]
        [DataType(DataType.Date)]
        public DateTime NgayMo { get; set; }

        [Display(Name = "Mã giảng viên")]
        [Required(ErrorMessage = "Mã giảng viên là bắt buộc")]
        [StringLength(10, MinimumLength = 2, ErrorMessage = "Mã giảng viên phải từ 2-10 ký tự")]
        public string MaGV { get; set; } = string.Empty;

        [Display(Name = "Học phí")]
        [Required(ErrorMessage = "Học phí là bắt buộc")]
        [Range(0, 999999999, ErrorMessage = "Học phí phải từ 0 đến 999,999,999")]
        [DataType(DataType.Currency)]
        public decimal HocPhi { get; set; }

        public string? TenGV { get; set; }
    }
}
