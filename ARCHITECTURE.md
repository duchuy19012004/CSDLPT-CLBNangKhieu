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

## 3. Phân mảnh dữ liệu theo ID

```
┌─────────────────────────────────────────────────────────────┐
│                    PHÂN MẢNH THEO CHIỀU NGANG               │
│                   (Horizontal Fragmentation)                │
│                      Sử dụng UNION ALL                      │
└─────────────────────────────────────────────────────────────┘

        ┌──────────────────┴──────────────────┐
        │                                     │
        ↓                                     ↓
┌──────────────────┐                ┌──────────────────┐
│    SITE A        │                │     SITE B       │
│                  │                │                  │
│  Dữ liệu ID nhỏ  │                │  Dữ liệu ID lớn  │
│                  │                │                  │
│  • CauLacBo 1-3  │                │  • CauLacBo 4+   │
│  • GiangVien 1-5 │                │  • GiangVien 6+  │
│  • SinhVien 1-5  │                │  • SinhVien 6+   │
│  • LopNK 1-3     │                │  • LopNK 4+      │
│  • BienLai 1-4   │                │  • BienLai 5+    │
└──────────────────┘                └──────────────────┘

        │                                     │
        └──────────────────┬──────────────────┘
                           ↓
                    ┌─────────────┐
                    │ UNION ALL   │
                    │ Kết hợp dữ  │
                    │ liệu 2 site │
                    └─────────────┘
```

## 4. Cơ chế Trigger INSTEAD OF với định tuyến

```
┌─────────────────────────────────────────────────────────────┐
│         MỖI VIEW CÓ 3 TRIGGER VỚI LOGIC ĐỊNH TUYẾN          │
└─────────────────────────────────────────────────────────────┘

    VIEW: vw_CauLacBo (UNION ALL từ Site A + Site B)
         │
         ├─→ trg_Insert_CauLacBo
         │   ├─→ IF MaCLB 1-3  → INSERT vào SiteA.dbo.CauLacBo
         │   └─→ IF MaCLB >= 4 → INSERT vào SiteB.dbo.CauLacBo
         │
         ├─→ trg_Update_CauLacBo
         │   ├─→ UPDATE SiteA.dbo.CauLacBo (nếu có)
         │   └─→ UPDATE SiteB.dbo.CauLacBo (nếu có)
         │
         └─→ trg_Delete_CauLacBo
             ├─→ DELETE từ SiteA.dbo.CauLacBo
             └─→ DELETE từ SiteB.dbo.CauLacBo


    VIEW: vw_SinhVien (UNION ALL từ Site A + Site B)
         │
         ├─→ trg_Insert_SinhVien
         │   ├─→ IF SV001-005 → INSERT vào SiteA.dbo.SinhVien
         │   └─→ IF SV006+    → INSERT vào SiteB.dbo.SinhVien
         │
         ├─→ trg_Update_SinhVien
         │   ├─→ UPDATE SiteA.dbo.SinhVien (nếu có)
         │   └─→ UPDATE SiteB.dbo.SinhVien (nếu có)
         │
         └─→ trg_Delete_SinhVien
             ├─→ DELETE từ SiteA.dbo.SinhVien
             └─→ DELETE từ SiteB.dbo.SinhVien
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
