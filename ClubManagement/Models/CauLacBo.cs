using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class CauLacBo
    {
        [Display(Name = "Mã CLB")]
        public int MaCLB { get; set; }

        [Display(Name = "Tên câu lạc bộ")]
        [Required(ErrorMessage = "Tên câu lạc bộ là bắt buộc")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Tên câu lạc bộ phải từ 3-100 ký tự")]
        public string TenCLB { get; set; } = string.Empty;

        [Display(Name = "Tên khoa")]
        [Required(ErrorMessage = "Tên khoa là bắt buộc")]
        public string TenKhoa { get; set; } = string.Empty;

        [Display(Name = "Khu vực")]
        [Required(ErrorMessage = "Khu vực là bắt buộc")]
        public string KhuVuc { get; set; } = string.Empty;

        // Để hiển thị site nguồn (từ view)
        public string? SourceSite { get; set; }
    }
}
