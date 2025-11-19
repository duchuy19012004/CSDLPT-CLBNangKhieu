using System.ComponentModel.DataAnnotations;

namespace ClubManagement.Models
{
    public class BienLai
    {
        [Display(Name = "Số biên lai")]
        [Required(ErrorMessage = "Số biên lai là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Số biên lai phải lớn hơn 0")]
        public int SoBL { get; set; }

        [Display(Name = "Tháng")]
        [Required(ErrorMessage = "Tháng là bắt buộc")]
        [Range(1, 12, ErrorMessage = "Tháng phải từ 1 đến 12")]
        public int Thang { get; set; }

        [Display(Name = "Năm")]
        [Required(ErrorMessage = "Năm là bắt buộc")]
        [Range(2000, 2100, ErrorMessage = "Năm phải từ 2000 đến 2100")]
        public int Nam { get; set; }

        [Display(Name = "Mã lớp")]
        [Required(ErrorMessage = "Mã lớp là bắt buộc")]
        [Range(1, int.MaxValue, ErrorMessage = "Mã lớp phải lớn hơn 0")]
        public int MaLop { get; set; }

        [Display(Name = "Mã sinh viên")]
        [Required(ErrorMessage = "Mã sinh viên là bắt buộc")]
        [StringLength(10, MinimumLength = 3, ErrorMessage = "Mã sinh viên phải từ 3-10 ký tự")]
        public string MaSV { get; set; } = string.Empty;

        [Display(Name = "Số tiền")]
        [Required(ErrorMessage = "Số tiền là bắt buộc")]
        [Range(0, 999999999, ErrorMessage = "Số tiền phải từ 0 đến 999,999,999")]
        [DataType(DataType.Currency)]
        public decimal SoTien { get; set; }

        public string? TenSV { get; set; }
    }
}
