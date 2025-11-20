# Mô Phỏng Hệ thống quản lý câu lạc bộ và lớp năng khiếu

Đồ án môn học: Cơ sở dữ liệu phân tán

## Mô tả

Ứng dụng web ASP.NET Core MVC mô phỏng hệ thống quản lý câu lạc bộ và lớp năng khiếu với cơ sở dữ liệu phân tán trên SQL Server.

## Kiến trúc

- **Mô hình**: Toàn cục duy nhất với phân mảnh ngang (Horizontal Fragmentation)
- **Database**: SQL Server với 3 database:
  - `ClubManagementGlobal`: Database toàn cục chứa các view (sử dụng UNION ALL)
  - `SiteA`: Chứa dữ liệu phân mảnh A
  - `SiteB`: Chứa dữ liệu phân mảnh B

### Phân bổ dữ liệu (với DatabaseSetup_AttributeBased.sql):

- **Site A**: Câu lạc bộ thuộc khoa K1, K2 và dữ liệu liên quan

  - CauLacBo (TenKhoa = K1, K2)
  - GiangVien (thuộc các CLB ở Site A)
  - SinhVien (thuộc các CLB ở Site A)
  - LopNangKhieu (do GV ở Site A giảng dạy)
  - BienLai (của các lớp ở Site A)

- **Site B**: Câu lạc bộ thuộc khoa K3, K4, K5 và dữ liệu liên quan
  - CauLacBo (TenKhoa = K3, K4, K5)
  - GiangVien (thuộc các CLB ở Site B)
  - SinhVien (thuộc các CLB ở Site B)
  - LopNangKhieu (do GV ở Site B giảng dạy)
  - BienLai (của các lớp ở Site B)

## Cài đặt

### 1. Yêu cầu

- .NET 8.0 SDK
- SQL Server 2019 trở lên
- Visual Studio 2022 hoặc VS Code

### 2. Setup Database

Chạy file `DatabaseSetup_AttributeBased.sql` trong SQL Server Management Studio để:

- Tạo 3 database (ClubManagementGlobal, SiteA, SiteB)
- Tạo các bảng thật tại các site
- Tạo các view toàn cục với UNION ALL
- Tạo các trigger INSTEAD OF với logic phân mảnh theo thuộc tính
- Thêm dữ liệu mẫu

**Logic phân mảnh (Derived Horizontal Fragmentation)**:

- **CauLacBo**: Phân theo TenKhoa
  - Site A: K1, K2
  - Site B: K3, K4, K5
- **GiangVien, SinhVien**: Phân theo MaCLB (cùng site với CauLacBo)
- **LopNangKhieu**: Phân theo MaGV (cùng site với GiangVien)
- **BienLai**: Phân theo MaLop (cùng site với LopNangKhieu)

**Ưu điểm**:

- ID tự động tăng không bị giới hạn
- Dữ liệu liên quan nằm cùng site (data locality)
- Phân bổ cân bằng theo nghiệp vụ

### 3. Cấu hình Connection String

Mở file `appsettings.json` và cập nhật connection string (đã cấu hình sẵn):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=paste tên sql server vào đây\\SQLEXPRESS;Database=ClubManagementGlobal;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### 4. Restore packages và chạy ứng dụng

```bash
cd ClubManagement
dotnet restore
dotnet run
```

Truy cập: `https://localhost:5001` hoặc `http://localhost:5000`

## Chức năng

### Quản lý dữ liệu (CRUD)

1. **Câu lạc bộ**: Thêm, sửa, xóa, xem danh sách
2. **Giảng viên**: Thêm, sửa, xóa, xem danh sách
3. **Sinh viên**: Thêm, sửa, xóa, xem danh sách
4. **Lớp năng khiếu**: Thêm, sửa, xóa, xem danh sách
5. **Biên lai**: Thêm, sửa, xóa, xem danh sách

### Quản lý phân mảnh

1. **Cấu hình khoa**: Xem và chỉnh sửa danh sách khoa thuộc mỗi site (trong bảng FragmentationConfig)
2. **Thống kê phân bổ**: Xem biểu đồ phân bổ dữ liệu giữa Site A và Site B

### Truy vấn toàn cục

1. **Truy vấn 1**: Biên lai của các lớp do giảng viên GV5 giảng dạy
2. **Truy vấn 2**: Tổng học phí sinh viên đóng cho một lớp
3. **Truy vấn 3**: Các lớp mở trong tháng 08 năm 2012
4. **Truy vấn 4**: Cập nhật khoa của câu lạc bộ (CLB 5: K3 → K2)

## Mức trong suốt

- **Trong suốt phân mảnh**: Người dùng thao tác trên view toàn cục (UNION ALL) như thể chỉ có một bảng
- **Trong suốt vị trí**: Không cần biết dữ liệu lưu ở site nào, trigger tự động định tuyến dựa trên thuộc tính (TenKhoa, MaCLB, MaGV, MaLop)
- **Trong suốt sao chép**: View UNION ALL tự động kết hợp dữ liệu từ cả 2 site

## Công nghệ sử dụng

- ASP.NET Core 8.0 MVC
- SQL Server
- Dapper (Micro ORM)
- Bootstrap 5

## Cấu trúc thư mục

```
ClubManagement/
├── Controllers/        # Các controller xử lý logic
├── Models/            # Các entity classes
├── Views/             # Các view Razor
├── Data/              # Database context
└── wwwroot/           # Static files
```

## Lưu ý

- Đảm bảo SQL Server đang chạy
- Kiểm tra quyền truy cập cross-database
- Connection string phải trỏ đến database `ClubManagementGlobal`
