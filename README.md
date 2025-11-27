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
         │  (MaCLB lẻ)     │ │  (MaCLB chẵn)   │
         │  1, 3, 5, 7...  │ │  2, 4, 6, 8...  │
         └─────────────────┘ └─────────────────┘
```

## Phân mảnh theo ID (Chẵn/Lẻ)

| Site   | Quy tắc | Ví dụ MaCLB       |
| ------ | ------- | ----------------- |
| Site A | ID lẻ   | 1, 3, 5, 7, 9...  |
| Site B | ID chẵn | 2, 4, 6, 8, 10... |

**Logic phân mảnh dẫn xuất:**

- `CauLacBo`: Phân theo MaCLB (lẻ → A, chẵn → B)
- `GiangVien`, `SinhVien`: Theo MaCLB của CLB
- `LopNangKhieu`: Theo site của GiangVien
- `BienLai`: Theo site của LopNangKhieu

**Ưu điểm:**

- Phân bố đều 50-50
- Dễ scale, dễ hiểu
- Không phụ thuộc nghiệp vụ

## Cài đặt

### Yêu cầu

- .NET 8.0 SDK
- SQL Server 2019+
- Visual Studio 2022 / VS Code

### 1. Setup Database

Chạy file SQL trong SSMS:

```sql
-- Chạy file này để setup database
DatabaseSetup_IDBasedFragmentation.sql
```

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

### Quản lý dữ liệu (CRUD)

- Câu lạc bộ
- Giảng viên
- Sinh viên
- Lớp năng khiếu
- Biên lai

### Truy vấn phân tán

- Truy vấn toàn cục qua view UNION ALL
- Tự động định tuyến INSERT/UPDATE/DELETE qua trigger

### Nhật ký hoạt động

- Ghi log tự động mọi thao tác INSERT/UPDATE/DELETE
- Lọc theo thao tác, bảng, site, thời gian
- Phân trang

## Mức trong suốt

| Loại                 | Mô tả                                    |
| -------------------- | ---------------------------------------- |
| Trong suốt phân mảnh | Thao tác trên view như 1 bảng duy nhất   |
| Trong suốt vị trí    | Trigger tự động định tuyến theo ID       |
| Trong suốt sao chép  | View UNION ALL kết hợp dữ liệu từ 2 site |

## Công nghệ

- ASP.NET Core 8.0 MVC
- SQL Server (Distributed Database)
- Dapper (Micro ORM)
- Bootstrap 5

## Cấu trúc

```
ClubManagement/
├── Controllers/     # Xử lý logic
├── Models/          # Entity classes
├── Views/           # Razor views
├── Data/            # DbContext
└── wwwroot/         # Static files

SQL Files:
├── DatabaseSetup_IDBasedFragmentation.sql  # Setup phân mảnh theo ID
└── DatabaseSetup_AttributeBased.sql        # Setup phân mảnh theo thuộc tính (backup)
```
