# Kiến trúc CSDL phân tán - Club Management

## 1. Sơ đồ tổng quan

```
                        ┌─────────────────┐
                        │      USER       │
                        │   (Người dùng)  │
                        └────────┬────────┘
                                 │
                                 │ Truy vấn/Cập nhật
                                 ↓
┌────────────────────────────────────────────────────────────────┐
│           DATABASE TOÀN CỤC (ClubManagementGlobal)             │
│                         GLOBAL SCHEMA                          │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │vw_CauLacBo   │  │vw_GiangVien  │  │vw_SinhVien   │        │
│  │+ Triggers    │  │+ Triggers    │  │+ Triggers    │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                 │                  │                 │
│  ┌──────────────┐  ┌──────────────┐                           │
│  │vw_LopNangKhieu│ │vw_BienLai    │                           │
│  │+ Triggers    │  │+ Triggers    │                           │
│  └──────┬───────┘  └──────┬───────┘                           │
│         │                 │                                    │
└─────────┼─────────────────┼────────────────┼───────────────────┘
          │                 │                │
          │ Phân mảnh       │                │
          │ (Fragmentation) │                │
    ┌─────┴──────┐    ┌─────┴────────────────┴──────┐
    │            │    │                              │
    ↓            ↓    ↓                              ↓
┌─────────────────────────┐         ┌─────────────────────────────┐
│      SITE A             │         │         SITE B              │
│   (Database: SiteA)     │         │    (Database: SiteB)        │
├─────────────────────────┤         ├─────────────────────────────┤
│  LOCAL SCHEMA           │         │  LOCAL SCHEMA               │
│                         │         │                             │
│ ┌─────────────────────┐ │         │ ┌─────────────────────────┐ │
│ │   CauLacBo          │ │         │ │   SinhVien              │ │
│ ├─────────────────────┤ │         │ ├─────────────────────────┤ │
│ │ MaCLB (PK)          │ │         │ │ MaSV (PK)               │ │
│ │ TenCLB              │ │         │ │ HoTenSV                 │ │
│ │ TenKhoa             │ │         │ │ MaCLB (FK)              │ │
│ └─────────────────────┘ │         │ └─────────────────────────┘ │
│                         │         │                             │
│ ┌─────────────────────┐ │         │ ┌─────────────────────────┐ │
│ │   GiangVien         │ │         │ │   LopNangKhieu          │ │
│ ├─────────────────────┤ │         │ ├─────────────────────────┤ │
│ │ MaGV (PK)           │ │         │ │ MaLop (PK)              │ │
│ │ HoTenGV             │ │         │ │ NgayMo                  │ │
│ │ MaCLB (FK)          │ │         │ │ MaGV (FK)               │ │
│ └─────────────────────┘ │         │ │ HocPhi                  │ │
│                         │         │ └─────────────────────────┘ │
│                         │         │                             │
│                         │         │ ┌─────────────────────────┐ │
│                         │         │ │   BienLai               │ │
│                         │         │ ├─────────────────────────┤ │
│                         │         │ │ SoBL (PK)               │ │
│                         │         │ │ Thang, Nam              │ │
│                         │         │ │ MaLop (FK)              │ │
│                         │         │ │ MaSV (FK)               │ │
│                         │         │ │ SoTien                  │ │
│                         │         │ └─────────────────────────┘ │
└─────────────────────────┘         └─────────────────────────────┘
```

## 2. Luồng xử lý dữ liệu

```
┌──────────────────────────────────────────────────────────────┐
│ STEP 1: User gửi truy vấn đến Global Schema                  │
│ UPDATE vw_CauLacBo SET TenKhoa='K2' WHERE MaCLB=5            │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 2: Trigger INSTEAD OF bắt lệnh                          │
│ trg_Update_CauLacBo được kích hoạt tại Global Schema         │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 3: Trigger định tuyến đến Site chứa dữ liệu            │
│ UPDATE SiteA.dbo.CauLacBo SET TenKhoa='K2' WHERE MaCLB=5     │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│ STEP 4: Dữ liệu được cập nhật tại Site A                     │
│ ✓ Hoàn thành - User nhận kết quả                             │
└──────────────────────────────────────────────────────────────┘
```

## 3. Phân mảnh dữ liệu theo chức năng

```
┌─────────────────────────────────────────────────────────────┐
│                    PHÂN MẢNH THEO CHIỀU DỌC                 │
│                   (Vertical Fragmentation)                  │
└─────────────────────────────────────────────────────────────┘

        ┌──────────────────┴──────────────────┐
        │                                     │
        ↓                                     ↓
┌──────────────────┐                ┌──────────────────┐
│    SITE A        │                │     SITE B       │
│                  │                │                  │
│  Quản lý tổ chức │                │  Quản lý hoạt    │
│  & Nhân sự       │                │  động học tập    │
│                  │                │                  │
│  • Câu lạc bộ    │                │  • Sinh viên     │
│  • Giảng viên    │                │  • Lớp học       │
│                  │                │  • Biên lai      │
└──────────────────┘                └──────────────────┘
```

## 4. Cơ chế Trigger INSTEAD OF

```
┌─────────────────────────────────────────────────────────────┐
│                    MỖI VIEW CÓ 3 TRIGGER                    │
└─────────────────────────────────────────────────────────────┘

    VIEW: vw_CauLacBo
         │
         ├─→ trg_Insert_CauLacBo  ──→  INSERT vào SiteA.dbo.CauLacBo
         │
         ├─→ trg_Update_CauLacBo  ──→  UPDATE vào SiteA.dbo.CauLacBo
         │
         └─→ trg_Delete_CauLacBo  ──→  DELETE từ SiteA.dbo.CauLacBo


    VIEW: vw_SinhVien
         │
         ├─→ trg_Insert_SinhVien  ──→  INSERT vào SiteB.dbo.SinhVien
         │
         ├─→ trg_Update_SinhVien  ──→  UPDATE vào SiteB.dbo.SinhVien
         │
         └─→ trg_Delete_SinhVien  ──→  DELETE từ SiteB.dbo.SinhVien
```

## 5. Ví dụ truy vấn phân tán

```
┌─────────────────────────────────────────────────────────────┐
│ Query 1: Biên lai của lớp do giảng viên GV5 giảng dạy       │
└─────────────────────────────────────────────────────────────┘

SELECT bl.*, l.*
FROM vw_BienLai bl              ← Dữ liệu từ Site B
JOIN vw_LopNangKhieu l          ← Dữ liệu từ Site B
  ON bl.MaLop = l.MaLop
WHERE l.MaGV = 'GV5'            ← MaGV tham chiếu đến Site A

        ┌─────────────┐
        │ Site B      │  ← Thực hiện JOIN tại đây
        │ BienLai +   │
        │ LopNangKhieu│
        └─────────────┘
              ↑
              │ Tham chiếu MaGV
              │
        ┌─────────────┐
        │ Site A      │
        │ GiangVien   │
        └─────────────┘
```

## 6. Tính trong suốt (Transparency)

```
┌─────────────────────────────────────────────────────────────┐
│              User không biết dữ liệu ở đâu                  │
└─────────────────────────────────────────────────────────────┘

    User thấy:                      Thực tế xảy ra:

    SELECT *                        SELECT *
    FROM vw_CauLacBo        →       FROM SiteA.dbo.CauLacBo

    UPDATE vw_SinhVien              UPDATE SiteB.dbo.SinhVien
    SET ...                 →       SET ...

    INSERT INTO                     INSERT INTO
    vw_BienLai              →       SiteB.dbo.BienLai
    VALUES (...)                    VALUES (...)
```

## 7. Lợi ích kiến trúc

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Tính trong suốt │     │   Phân tải       │     │  Dễ bảo trì      │
│                  │     │                  │     │                  │
│  User không cần  │     │  Mỗi site xử lý  │     │  Thay đổi phân   │
│  biết vị trí     │     │  một phần dữ     │     │  mảnh không ảnh  │
│  dữ liệu         │     │  liệu riêng      │     │  hưởng user      │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```
