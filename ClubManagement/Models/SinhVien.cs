using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class SinhVien
    {
        [Display(Name = "Mã sinh viên")]
        [StringLength(10, MinimumLength = 3, ErrorMessage = "Mã sinh viên phải từ 3-10 ký tự")]
        [RegularExpression(@"^SV\d+$", ErrorMessage = "Mã sinh viên phải có định dạng SV theo sau là số (VD: SV001, SV100)")]
        public string MaSV { get; set; } = string.Empty;

        [Display(Name = "Họ tên sinh viên")]
        [Required(ErrorMessage = "Họ tên sinh viên là bắt buộc")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Họ tên phải từ 3-100 ký tự")]
        public string HoTenSV { get; set; } = string.Empty;

        [Display(Name = "Mã câu lạc bộ")]
        [Required(ErrorMessage = "Mã câu lạc bộ là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Mã CLB phải lớn hơn 0")]
        public int MaCLB { get; set; }

        public string? TenCLB { get; set; }
    }
}
