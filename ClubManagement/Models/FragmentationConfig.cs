using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class FragmentationConfig
    {
        [Display(Name = "Tên bảng")]
        [Required(ErrorMessage = "Tên bảng là bắt buộc")]
        public string TableName { get; set; } = string.Empty;

        [Display(Name = "Ngưỡng phân mảnh")]
        [Required(ErrorMessage = "Ngưỡng là bắt buộc")]
        [Range(1, 10000, ErrorMessage = "Ngưỡng phải từ 1 đến 10,000")]
        public int ThresholdValue { get; set; }

        [Display(Name = "Mô tả")]
        public string? Description { get; set; }

        [Display(Name = "Cập nhật lần cuối")]
        public DateTime? LastModified { get; set; }
    }
}
