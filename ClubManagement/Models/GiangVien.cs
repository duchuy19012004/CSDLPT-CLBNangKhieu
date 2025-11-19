using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class GiangVien
    {
        [Display(Name = "Mã giảng viên")]
        [Required(ErrorMessage = "Mã giảng viên là bắt buộc")]
        [StringLength(10, MinimumLength = 2, ErrorMessage = "Mã giảng viên phải từ 2-10 ký tự")]
        [RegularExpression(@"^GV\d+$", ErrorMessage = "Mã giảng viên phải có định dạng GV theo sau là số (VD: GV1, GV10)")]
        public string MaGV { get; set; } = string.Empty;

        [Display(Name = "Họ tên giảng viên")]
        [Required(ErrorMessage = "Họ tên giảng viên là bắt buộc")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Họ tên phải từ 3-100 ký tự")]
        public string HoTenGV { get; set; } = string.Empty;

        [Display(Name = "Mã câu lạc bộ")]
        [Required(ErrorMessage = "Mã câu lạc bộ là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Mã CLB phải lớn hơn 0")]
        public int MaCLB { get; set; }

        public string? TenCLB { get; set; }
    }
}
