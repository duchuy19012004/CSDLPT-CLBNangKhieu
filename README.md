# Hệ thống Quản lý Câu lạc bộ - Cơ sở dữ liệu Phân tán

Đồ án môn học: Cơ sở dữ liệu phân tán

## Mô tả

Ứng dụng web ASP.NET Core MVC mô phỏng hệ thống quản lý câu lạc bộ và lớp năng khiếu với cơ sở dữ liệu phân tán trên SQL Server.

## Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────────┐
│              ClubManagementGlobal                       │
│         (View toàn cục - UNION ALL)                     │
│    vw_CauLacBo, vw_GiangVien, vw_SinhVien, ...         │
└─────────────────┬───────────────────┬───────────────────┘
                  │                   │
         ┌────────▼────────┐ ┌────────▼────────┐
         │     Site A      │ │     Site B      │
         │   TP.HCM        │ │    Hà Nội       │
         │  KhuVuc=TPHCM   │ │  KhuVuc=HaNoi   │
         └─────────────────┘ └─────────────────┘
```

## Phân mảnh theo Khu vực (Geographic Partitioning)

| Site   | Khu vực | Mô tả           |
| ------ | ------- | --------------- |
| Site A | TPHCM   | TP. Hồ Chí Minh |
| Site B | HaNoi   | Hà Nội          |

**Logic phân mảnh:**

- `CauLacBo`: Phân theo KhuVuc
- `GiangVien`, `SinhVien`: Theo site của CauLacBo (MaCLB)
- `LopNangKhieu`: Theo site của GiangVien (MaGV)
- `BienLai`: Theo site của LopNangKhieu (MaLop)

**Ưu điểm:**

- Giảm latency theo vùng địa lý
- Dễ mở rộng thêm khu vực mới
- Phù hợp nghiệp vụ thực tế

## Cài đặt

### Yêu cầu

- .NET 8.0 SDK
- SQL Server 2019+
- Visual Studio 2022 / VS Code

### 1. Setup Database

Chạy file `DatabaseSetup_Geographic.sql` trong SQL Server Management Studio.

### 2. Cấu hình Connection String

Sửa file `ClubManagement/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=TEN_SERVER\\SQLEXPRESS;Database=ClubManagementGlobal;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### 3. Chạy ứng dụng

```bash
cd ClubManagement
dotnet restore
dotnet run
```

Truy cập: `https://localhost:5001`

## Chức năng

- CRUD: Câu lạc bộ, Giảng viên, Sinh viên, Lớp năng khiếu, Biên lai
- Truy vấn phân tán qua view UNION ALL
- Nhật ký hoạt động (Activity Log)
- Phân trang 12 dòng/trang

## Mức trong suốt

| Loại                 | Mô tả                                    |
| -------------------- | ---------------------------------------- |
| Trong suốt phân mảnh | Thao tác trên view như 1 bảng duy nhất   |
| Trong suốt vị trí    | Trigger tự động định tuyến theo KhuVuc   |
| Trong suốt sao chép  | View UNION ALL kết hợp dữ liệu từ 2 site |

## Công nghệ

- ASP.NET Core 8.0 MVC
- SQL Server
- Dapper
- Bootstrap 5
