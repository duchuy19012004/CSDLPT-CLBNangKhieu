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
┌─────────────────────────────────┐   ┌─────────────────────────────────┐
│         SITE A                  │   │         SITE B                  │
│    (Database: SiteA)            │   │    (Database: SiteB)            │
│    Khoa K1, K2                  │   │    Khoa K3, K4, K5              │
├─────────────────────────────────┤   ├─────────────────────────────────┤
│  LOCAL SCHEMA                   │   │  LOCAL SCHEMA                   │
│                                 │   │                                 │
│ ┌─────────────────────────────┐ │   │ ┌─────────────────────────────┐ │
│ │   CauLacBo (TenKhoa=K1,K2)  │ │   │ │   CauLacBo (TenKhoa=K3,K4,K5)│ │
│ ├─────────────────────────────┤ │   │ ├─────────────────────────────┤ │
│ │ MaCLB (PK)                  │ │   │ │ MaCLB (PK)                  │ │
│ │ TenCLB                      │ │   │ │ TenCLB                      │ │
│ │ TenKhoa                     │ │   │ │ TenKhoa                     │ │
│ └─────────────────────────────┘ │   │ └─────────────────────────────┘ │
│                                 │   │                                 │
│ ┌─────────────────────────────┐ │   │ ┌─────────────────────────────┐ │
│ │   GiangVien (của CLB Site A)│ │   │ │   GiangVien (của CLB Site B)│ │
│ ├─────────────────────────────┤ │   │ ├─────────────────────────────┤ │
│ │ MaGV (PK)                   │ │   │ │ MaGV (PK)                   │ │
│ │ HoTenGV                     │ │   │ │ HoTenGV                     │ │
│ │ MaCLB (FK)                  │ │   │ │ MaCLB (FK)                  │ │
│ └─────────────────────────────┘ │   │ └─────────────────────────────┘ │
│                                 │   │                                 │
│ ┌─────────────────────────────┐ │   │ ┌─────────────────────────────┐ │
│ │   SinhVien (của CLB Site A) │ │   │ │   SinhVien (của CLB Site B) │ │
│ ├─────────────────────────────┤ │   │ ├─────────────────────────────┤ │
│ │ MaSV (PK)                   │ │   │ │ MaSV (PK)                   │ │
│ │ HoTenSV                     │ │   │ │ HoTenSV                     │ │
│ │ MaCLB (FK)                  │ │   │ │ MaCLB (FK)                  │ │
│ └─────────────────────────────┘ │   │ └─────────────────────────────┘ │
│                                 │   │                                 │
│ ┌─────────────────────────────┐ │   │ ┌─────────────────────────────┐ │
│ │   LopNangKhieu (của GV A)   │ │   │ │   LopNangKhieu (của GV B)   │ │
│ ├─────────────────────────────┤ │   │ ├─────────────────────────────┤ │
│ │ MaLop (PK)                  │ │   │ │ MaLop (PK)                  │ │
│ │ NgayMo, MaGV, HocPhi        │ │   │ │ NgayMo, MaGV, HocPhi        │ │
│ └─────────────────────────────┘ │   │ └─────────────────────────────┘ │
│                                 │   │                                 │
│ ┌─────────────────────────────┐ │   │ ┌─────────────────────────────┐ │
│ │   BienLai (của Lớp A)       │ │   │ │   BienLai (của Lớp B)       │ │
│ ├─────────────────────────────┤ │   │ ├─────────────────────────────┤ │
│ │ SoBL (PK)                   │ │   │ │ SoBL (PK)                   │ │
│ │ Thang, Nam, MaLop, MaSV     │ │   │ │ Thang, Nam, MaLop, MaSV     │ │
│ │ SoTien                      │ │   │ │ SoTien                      │ │
│ └─────────────────────────────┘ │   │ └─────────────────────────────┘ │
└─────────────────────────────────┘   └─────────────────────────────────┘
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

## 3. Phân mảnh dữ liệu theo thuộc tính

```
┌─────────────────────────────────────────────────────────────┐
│              PHÂN MẢNH THEO CHIỀU NGANG DẪN XUẤT            │
│           (Derived Horizontal Fragmentation)                │
│                   Sử dụng UNION ALL                         │
└─────────────────────────────────────────────────────────────┘

                    ┌─────────────────┐
                    │   CauLacBo      │
                    │ (Phân theo Khoa)│
                    └────────┬────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
        ↓                                         ↓
┌──────────────────┐                    ┌──────────────────┐
│    SITE A        │                    │     SITE B       │
│                  │                    │                  │
│  Khoa K1, K2     │                    │  Khoa K3,K4,K5   │
│                  │                    │                  │
│  • CauLacBo      │                    │  • CauLacBo      │
│    (K1, K2)      │                    │    (K3,K4,K5)    │
│  • GiangVien     │                    │  • GiangVien     │
│    (của CLB A)   │                    │    (của CLB B)   │
│  • SinhVien      │                    │  • SinhVien      │
│    (của CLB A)   │                    │    (của CLB B)   │
│  • LopNangKhieu  │                    │  • LopNangKhieu  │
│    (của GV A)    │                    │    (của GV B)    │
│  • BienLai       │                    │  • BienLai       │
│    (của Lớp A)   │                    │    (của Lớp B)   │
└──────────────────┘                    └──────────────────┘

        │                                         │
        └──────────────────┬──────────────────────┘
                           ↓
                    ┌─────────────┐
                    │ UNION ALL   │
                    │ Kết hợp dữ  │
                    │ liệu 2 site │
                    └─────────────┘
```

## 4. Cơ chế Trigger INSTEAD OF với định tuyến theo thuộc tính

```
┌─────────────────────────────────────────────────────────────┐
│      MỖI VIEW CÓ 3 TRIGGER VỚI LOGIC ĐỊNH TUYẾN THÔNG MINH  │
└─────────────────────────────────────────────────────────────┘

    VIEW: vw_CauLacBo (UNION ALL từ Site A + Site B)
         │
         ├─→ trg_Insert_CauLacBo
         │   ├─→ IF TenKhoa IN (K1,K2) → INSERT vào SiteA.dbo.CauLacBo
         │   └─→ IF TenKhoa IN (K3,K4,K5) → INSERT vào SiteB.dbo.CauLacBo
         │
         ├─→ trg_Update_CauLacBo
         │   ├─→ UPDATE SiteA.dbo.CauLacBo (nếu có)
         │   └─→ UPDATE SiteB.dbo.CauLacBo (nếu có)
         │
         └─→ trg_Delete_CauLacBo
             ├─→ DELETE từ SiteA.dbo.CauLacBo
             └─→ DELETE từ SiteB.dbo.CauLacBo


    VIEW: vw_GiangVien (UNION ALL từ Site A + Site B)
         │
         ├─→ trg_Insert_GiangVien
         │   ├─→ IF MaCLB EXISTS IN SiteA.CauLacBo → INSERT vào SiteA.dbo.GiangVien
         │   └─→ IF MaCLB EXISTS IN SiteB.CauLacBo → INSERT vào SiteB.dbo.GiangVien
         │
         ├─→ trg_Update_GiangVien
         │   ├─→ UPDATE SiteA.dbo.GiangVien (nếu có)
         │   └─→ UPDATE SiteB.dbo.GiangVien (nếu có)
         │
         └─→ trg_Delete_GiangVien
             ├─→ DELETE từ SiteA.dbo.GiangVien
             └─→ DELETE từ SiteB.dbo.GiangVien


    VIEW: vw_LopNangKhieu (UNION ALL từ Site A + Site B)
         │
         ├─→ trg_Insert_LopNangKhieu
         │   ├─→ IF MaGV EXISTS IN SiteA.GiangVien → INSERT vào SiteA.dbo.LopNangKhieu
         │   └─→ IF MaGV EXISTS IN SiteB.GiangVien → INSERT vào SiteB.dbo.LopNangKhieu
         │
         └─→ ... (tương tự UPDATE/DELETE)


    VIEW: vw_BienLai (UNION ALL từ Site A + Site B)
         │
         ├─→ trg_Insert_BienLai
         │   ├─→ IF MaLop EXISTS IN SiteA.LopNangKhieu → INSERT vào SiteA.dbo.BienLai
         │   └─→ IF MaLop EXISTS IN SiteB.LopNangKhieu → INSERT vào SiteB.dbo.BienLai
         │
         └─→ ... (tương tự UPDATE/DELETE)
```

## 5. Ví dụ truy vấn phân tán với Data Locality

```
┌─────────────────────────────────────────────────────────────┐
│ Query 1: Biên lai của lớp do giảng viên GV5 giảng dạy       │
└─────────────────────────────────────────────────────────────┘

SELECT bl.*, l.*
FROM vw_BienLai bl              ← UNION ALL từ cả 2 site
JOIN vw_LopNangKhieu l          ← UNION ALL từ cả 2 site
  ON bl.MaLop = l.MaLop
WHERE l.MaGV = 'GV5'

Nếu GV5 thuộc Site B:
        ┌─────────────┐
        │ Site B      │  ← Tất cả dữ liệu liên quan ở đây
        │ GiangVien   │     (Data Locality)
        │ LopNangKhieu│
        │ BienLai     │
        └─────────────┘
              ↓
        JOIN cục bộ, không cần truy cập Site A!


┌─────────────────────────────────────────────────────────────┐
│ Query 2: Sinh viên của CLB thuộc khoa K1                    │
└─────────────────────────────────────────────────────────────┘

SELECT sv.*, clb.*
FROM vw_SinhVien sv
JOIN vw_CauLacBo clb ON sv.MaCLB = clb.MaCLB
WHERE clb.TenKhoa = 'K1'

        ┌─────────────┐
        │ Site A      │  ← CLB K1 và SinhVien cùng site
        │ CauLacBo    │     (Data Locality)
        │ SinhVien    │
        └─────────────┘
              ↓
        JOIN cục bộ, hiệu suất cao!
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

## 7. Lợi ích kiến trúc phân mảnh theo thuộc tính

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Tính trong suốt │     │   Data Locality  │     │  ID không giới   │
│                  │     │                  │     │  hạn             │
│  User không cần  │     │  Dữ liệu liên    │     │                  │
│  biết vị trí     │     │  quan cùng site  │     │  ID tự động tăng │
│  dữ liệu         │     │  → JOIN nhanh    │     │  không bị chặn   │
└──────────────────┘     └──────────────────┘     └──────────────────┘

┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Phân bổ cân     │     │  Dễ bảo trì      │     │  Mở rộng linh    │
│  bằng            │     │                  │     │  hoạt            │
│                  │     │  Thay đổi cấu    │     │                  │
│  Phân theo khoa  │     │  hình khoa qua   │     │  Thêm khoa mới   │
│  → Cân bằng tải  │     │  Web UI          │     │  dễ dàng         │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```
