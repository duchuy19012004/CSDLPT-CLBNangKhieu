using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class FragmentationConfig
    {
        [Display(Name = "Khóa cấu hình")]
        [Required(ErrorMessage = "Khóa cấu hình là bắt buộc")]
        public string ConfigKey { get; set; } = string.Empty;

        [Display(Name = "Giá trị")]
        [Required(ErrorMessage = "Giá trị là bắt buộc")]
        [StringLength(200, ErrorMessage = "Giá trị không được quá 200 ký tự")]
        public string ConfigValue { get; set; } = string.Empty;

        [Display(Name = "Mô tả")]
        public string? Description { get; set; }

        [Display(Name = "Cập nhật lần cuối")]
        public DateTime? LastModified { get; set; }
    }
}
