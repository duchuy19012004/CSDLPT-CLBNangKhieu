using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class CauLacBo
    {
        [Display(Name = "Mã CLB")]
        [Range(1, int.MaxValue, ErrorMessage = "Mã CLB phải lớn hơn 0")]
        public int MaCLB { get; set; }

        [Display(Name = "Tên câu lạc bộ")]
        [Required(ErrorMessage = "Tên câu lạc bộ là bắt buộc")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Tên câu lạc bộ phải từ 3-100 ký tự")]
        public string TenCLB { get; set; } = string.Empty;

        [Display(Name = "Tên khoa")]
        [Required(ErrorMessage = "Tên khoa là bắt buộc")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Tên khoa phải từ 2-50 ký tự")]
        public string TenKhoa { get; set; } = string.Empty;
    }
}
