-- =============================================
-- HỆ THỐNG QUẢN LÝ CÂU LẠC BỘ - PHÂN MẢNH LINH HOẠT
-- Admin có thể cấu hình ngưỡng phân mảnh
-- 
-- PHƯƠNG ÁN 2: NGƯỠNG LINH HOẠT (KHUYẾN NGHỊ)
-- - Site A: ID <= ngưỡng (mặc định 50)
-- - Site B: ID > ngưỡng
-- - Ngưỡng lưu trong bảng FragmentationConfig
-- - Admin có thể thay đổi qua Web UI: /FragmentationConfig
-- - Có trang thống kê phân bổ dữ liệu
-- - Phù hợp cho: Production, yêu cầu linh hoạt
-- =============================================

USE master;
GO

-- Tạo database toàn cục
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ClubManagementGlobal')
BEGIN
    CREATE DATABASE ClubManagementGlobal;
END
GO

-- Tạo các database site
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SiteA')
BEGIN
    CREATE DATABASE SiteA;
END
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SiteB')
BEGIN
    CREATE DATABASE SiteB;
END
GO

-- =============================================
-- DATABASE TOÀN CỤC: Tạo bảng cấu hình phân mảnh
-- =============================================
USE ClubManagementGlobal;
GO

-- Bảng cấu hình ngưỡng phân mảnh
IF OBJECT_ID('FragmentationConfig', 'U') IS NOT NULL DROP TABLE FragmentationConfig;
GO

CREATE TABLE FragmentationConfig (
    TableName NVARCHAR(50) PRIMARY KEY,
    ThresholdValue INT NOT NULL,
    Description NVARCHAR(200),
    LastModified DATETIME DEFAULT GETDATE()
);
GO

-- Dữ liệu cấu hình mặc định (Admin có thể thay đổi)
INSERT INTO FragmentationConfig (TableName, ThresholdValue, Description) VALUES
('CauLacBo', 50, N'Site A: 1-50, Site B: >50'),
('GiangVien', 50, N'Site A: GV1-GV50, Site B: GV51+'),
('SinhVien', 50, N'Site A: SV001-SV050, Site B: SV051+'),
('LopNangKhieu', 50, N'Site A: 1-50, Site B: >50'),
('BienLai', 50, N'Site A: 1-50, Site B: >50');
GO

-- Function để lấy ngưỡng phân mảnh
CREATE FUNCTION dbo.GetFragmentationThreshold(@TableName NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @Threshold INT;
    SELECT @Threshold = ThresholdValue 
    FROM FragmentationConfig 
    WHERE TableName = @TableName;
    RETURN ISNULL(@Threshold, 50); -- Mặc định 50 nếu không tìm thấy
END;
GO

-- =============================================
-- SITE A & SITE B: Tạo bảng
-- =============================================
USE SiteA;
GO

IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('CauLacBo', 'U') IS NOT NULL DROP TABLE CauLacBo;
IF OBJECT_ID('BienLai', 'U') IS NOT NULL DROP TABLE BienLai;
IF OBJECT_ID('LopNangKhieu', 'U') IS NOT NULL DROP TABLE LopNangKhieu;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL
);

CREATE TABLE GiangVien (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTenGV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL
);

CREATE TABLE SinhVien (
    MaSV VARCHAR(10) PRIMARY KEY,
    HoTenSV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL
);

CREATE TABLE LopNangKhieu (
    MaLop INT PRIMARY KEY,
    NgayMo DATE NOT NULL,
    MaGV VARCHAR(10) NOT NULL,
    HocPhi DECIMAL(18,2) NOT NULL
);

CREATE TABLE BienLai (
    SoBL INT PRIMARY KEY,
    Thang INT NOT NULL,
    Nam INT NOT NULL,
    MaLop INT NOT NULL,
    MaSV VARCHAR(10) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL
);
GO

USE SiteB;
GO

IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('CauLacBo', 'U') IS NOT NULL DROP TABLE CauLacBo;
IF OBJECT_ID('BienLai', 'U') IS NOT NULL DROP TABLE BienLai;
IF OBJECT_ID('LopNangKhieu', 'U') IS NOT NULL DROP TABLE LopNangKhieu;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL
);

CREATE TABLE GiangVien (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTenGV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL
);

CREATE TABLE SinhVien (
    MaSV VARCHAR(10) PRIMARY KEY,
    HoTenSV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL
);

CREATE TABLE LopNangKhieu (
    MaLop INT PRIMARY KEY,
    NgayMo DATE NOT NULL,
    MaGV VARCHAR(10) NOT NULL,
    HocPhi DECIMAL(18,2) NOT NULL
);

CREATE TABLE BienLai (
    SoBL INT PRIMARY KEY,
    Thang INT NOT NULL,
    Nam INT NOT NULL,
    MaLop INT NOT NULL,
    MaSV VARCHAR(10) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL
);
GO

-- =============================================
-- DATABASE TOÀN CỤC: Tạo VIEW với UNION ALL
-- =============================================
USE ClubManagementGlobal;
GO

IF OBJECT_ID('vw_CauLacBo', 'V') IS NOT NULL DROP VIEW vw_CauLacBo;
IF OBJECT_ID('vw_GiangVien', 'V') IS NOT NULL DROP VIEW vw_GiangVien;
IF OBJECT_ID('vw_SinhVien', 'V') IS NOT NULL DROP VIEW vw_SinhVien;
IF OBJECT_ID('vw_LopNangKhieu', 'V') IS NOT NULL DROP VIEW vw_LopNangKhieu;
IF OBJECT_ID('vw_BienLai', 'V') IS NOT NULL DROP VIEW vw_BienLai;
GO

CREATE VIEW vw_CauLacBo AS
SELECT * FROM SiteA.dbo.CauLacBo
UNION ALL
SELECT * FROM SiteB.dbo.CauLacBo;
GO

CREATE VIEW vw_GiangVien AS
SELECT * FROM SiteA.dbo.GiangVien
UNION ALL
SELECT * FROM SiteB.dbo.GiangVien;
GO

CREATE VIEW vw_SinhVien AS
SELECT * FROM SiteA.dbo.SinhVien
UNION ALL
SELECT * FROM SiteB.dbo.SinhVien;
GO

CREATE VIEW vw_LopNangKhieu AS
SELECT * FROM SiteA.dbo.LopNangKhieu
UNION ALL
SELECT * FROM SiteB.dbo.LopNangKhieu;
GO

CREATE VIEW vw_BienLai AS
SELECT * FROM SiteA.dbo.BienLai
UNION ALL
SELECT * FROM SiteB.dbo.BienLai;
GO

-- =============================================
-- TRIGGER LINH HOẠT - Sử dụng cấu hình từ bảng
-- =============================================

-- Trigger INSERT cho vw_CauLacBo (Sử dụng ngưỡng động)
CREATE TRIGGER trg_Insert_CauLacBo
ON vw_CauLacBo
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Threshold INT;
    SELECT @Threshold = dbo.GetFragmentationThreshold('CauLacBo');
    
    -- Insert vào Site A nếu MaCLB <= Threshold
    INSERT INTO SiteA.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa 
    FROM inserted 
    WHERE MaCLB <= @Threshold;
    
    -- Insert vào Site B nếu MaCLB > Threshold
    INSERT INTO SiteB.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa 
    FROM inserted 
    WHERE MaCLB > @Threshold;
END;
GO

-- Trigger UPDATE cho vw_CauLacBo
CREATE TRIGGER trg_Update_CauLacBo
ON vw_CauLacBo
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE SiteA.dbo.CauLacBo
    SET TenCLB = i.TenCLB, TenKhoa = i.TenKhoa
    FROM SiteA.dbo.CauLacBo c
    INNER JOIN inserted i ON c.MaCLB = i.MaCLB;
    
    UPDATE SiteB.dbo.CauLacBo
    SET TenCLB = i.TenCLB, TenKhoa = i.TenKhoa
    FROM SiteB.dbo.CauLacBo c
    INNER JOIN inserted i ON c.MaCLB = i.MaCLB;
END;
GO

-- Trigger DELETE cho vw_CauLacBo
CREATE TRIGGER trg_Delete_CauLacBo
ON vw_CauLacBo
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.CauLacBo WHERE MaCLB IN (SELECT MaCLB FROM deleted);
    DELETE FROM SiteB.dbo.CauLacBo WHERE MaCLB IN (SELECT MaCLB FROM deleted);
END;
GO

-- Trigger INSERT cho vw_GiangVien (Sử dụng ngưỡng động)
CREATE TRIGGER trg_Insert_GiangVien
ON vw_GiangVien
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Threshold INT;
    SELECT @Threshold = dbo.GetFragmentationThreshold('GiangVien');
    
    INSERT INTO SiteA.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT MaGV, HoTenGV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaGV, 3, LEN(MaGV)) AS INT) <= @Threshold;
    
    INSERT INTO SiteB.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT MaGV, HoTenGV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaGV, 3, LEN(MaGV)) AS INT) > @Threshold;
END;
GO

-- Trigger UPDATE cho vw_GiangVien
CREATE TRIGGER trg_Update_GiangVien
ON vw_GiangVien
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE SiteA.dbo.GiangVien
    SET HoTenGV = i.HoTenGV, MaCLB = i.MaCLB
    FROM SiteA.dbo.GiangVien g
    INNER JOIN inserted i ON g.MaGV = i.MaGV;
    
    UPDATE SiteB.dbo.GiangVien
    SET HoTenGV = i.HoTenGV, MaCLB = i.MaCLB
    FROM SiteB.dbo.GiangVien g
    INNER JOIN inserted i ON g.MaGV = i.MaGV;
END;
GO

-- Trigger DELETE cho vw_GiangVien
CREATE TRIGGER trg_Delete_GiangVien
ON vw_GiangVien
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.GiangVien WHERE MaGV IN (SELECT MaGV FROM deleted);
    DELETE FROM SiteB.dbo.GiangVien WHERE MaGV IN (SELECT MaGV FROM deleted);
END;
GO

-- Trigger INSERT cho vw_SinhVien (Sử dụng ngưỡng động)
CREATE TRIGGER trg_Insert_SinhVien
ON vw_SinhVien
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Threshold INT;
    SELECT @Threshold = dbo.GetFragmentationThreshold('SinhVien');
    
    INSERT INTO SiteA.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT MaSV, HoTenSV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaSV, 3, LEN(MaSV)) AS INT) <= @Threshold;
    
    INSERT INTO SiteB.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT MaSV, HoTenSV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaSV, 3, LEN(MaSV)) AS INT) > @Threshold;
END;
GO

-- Trigger UPDATE cho vw_SinhVien
CREATE TRIGGER trg_Update_SinhVien
ON vw_SinhVien
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE SiteA.dbo.SinhVien
    SET HoTenSV = i.HoTenSV, MaCLB = i.MaCLB
    FROM SiteA.dbo.SinhVien s
    INNER JOIN inserted i ON s.MaSV = i.MaSV;
    
    UPDATE SiteB.dbo.SinhVien
    SET HoTenSV = i.HoTenSV, MaCLB = i.MaCLB
    FROM SiteB.dbo.SinhVien s
    INNER JOIN inserted i ON s.MaSV = i.MaSV;
END;
GO

-- Trigger DELETE cho vw_SinhVien
CREATE TRIGGER trg_Delete_SinhVien
ON vw_SinhVien
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.SinhVien WHERE MaSV IN (SELECT MaSV FROM deleted);
    DELETE FROM SiteB.dbo.SinhVien WHERE MaSV IN (SELECT MaSV FROM deleted);
END;
GO

-- Trigger INSERT cho vw_LopNangKhieu (Sử dụng ngưỡng động)
CREATE TRIGGER trg_Insert_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Threshold INT;
    SELECT @Threshold = dbo.GetFragmentationThreshold('LopNangKhieu');
    
    INSERT INTO SiteA.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT MaLop, NgayMo, MaGV, HocPhi 
    FROM inserted 
    WHERE MaLop <= @Threshold;
    
    INSERT INTO SiteB.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT MaLop, NgayMo, MaGV, HocPhi 
    FROM inserted 
    WHERE MaLop > @Threshold;
END;
GO

-- Trigger UPDATE cho vw_LopNangKhieu
CREATE TRIGGER trg_Update_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE SiteA.dbo.LopNangKhieu
    SET NgayMo = i.NgayMo, MaGV = i.MaGV, HocPhi = i.HocPhi
    FROM SiteA.dbo.LopNangKhieu l
    INNER JOIN inserted i ON l.MaLop = i.MaLop;
    
    UPDATE SiteB.dbo.LopNangKhieu
    SET NgayMo = i.NgayMo, MaGV = i.MaGV, HocPhi = i.HocPhi
    FROM SiteB.dbo.LopNangKhieu l
    INNER JOIN inserted i ON l.MaLop = i.MaLop;
END;
GO

-- Trigger DELETE cho vw_LopNangKhieu
CREATE TRIGGER trg_Delete_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.LopNangKhieu WHERE MaLop IN (SELECT MaLop FROM deleted);
    DELETE FROM SiteB.dbo.LopNangKhieu WHERE MaLop IN (SELECT MaLop FROM deleted);
END;
GO

-- Trigger INSERT cho vw_BienLai (Sử dụng ngưỡng động)
CREATE TRIGGER trg_Insert_BienLai
ON vw_BienLai
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Threshold INT;
    SELECT @Threshold = dbo.GetFragmentationThreshold('BienLai');
    
    INSERT INTO SiteA.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT SoBL, Thang, Nam, MaLop, MaSV, SoTien 
    FROM inserted 
    WHERE SoBL <= @Threshold;
    
    INSERT INTO SiteB.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT SoBL, Thang, Nam, MaLop, MaSV, SoTien 
    FROM inserted 
    WHERE SoBL > @Threshold;
END;
GO

-- Trigger UPDATE cho vw_BienLai
CREATE TRIGGER trg_Update_BienLai
ON vw_BienLai
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE SiteA.dbo.BienLai
    SET Thang = i.Thang, Nam = i.Nam, MaLop = i.MaLop, MaSV = i.MaSV, SoTien = i.SoTien
    FROM SiteA.dbo.BienLai b
    INNER JOIN inserted i ON b.SoBL = i.SoBL;
    
    UPDATE SiteB.dbo.BienLai
    SET Thang = i.Thang, Nam = i.Nam, MaLop = i.MaLop, MaSV = i.MaSV, SoTien = i.SoTien
    FROM SiteB.dbo.BienLai b
    INNER JOIN inserted i ON b.SoBL = i.SoBL;
END;
GO

-- Trigger DELETE cho vw_BienLai
CREATE TRIGGER trg_Delete_BienLai
ON vw_BienLai
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.BienLai WHERE SoBL IN (SELECT SoBL FROM deleted);
    DELETE FROM SiteB.dbo.BienLai WHERE SoBL IN (SELECT SoBL FROM deleted);
END;
GO

-- =============================================
-- DỮ LIỆU MẪU
-- =============================================
USE SiteA;
GO

INSERT INTO CauLacBo VALUES (1, N'Câu lạc bộ Tin học', N'K1');
INSERT INTO CauLacBo VALUES (2, N'Câu lạc bộ Toán học', N'K2');
INSERT INTO CauLacBo VALUES (3, N'Câu lạc bộ Văn học', N'K1');

INSERT INTO GiangVien VALUES ('GV1', N'Nguyễn Văn A', 1);
INSERT INTO GiangVien VALUES ('GV2', N'Trần Thị B', 2);
INSERT INTO GiangVien VALUES ('GV3', N'Lê Văn C', 3);

INSERT INTO SinhVien VALUES ('SV001', N'Nguyễn Minh A', 1);
INSERT INTO SinhVien VALUES ('SV002', N'Trần Thị B', 2);
INSERT INTO SinhVien VALUES ('SV003', N'Lê Văn C', 3);

INSERT INTO LopNangKhieu VALUES (1, '2012-08-01', 'GV1', 500000);
INSERT INTO LopNangKhieu VALUES (2, '2012-08-15', 'GV2', 600000);
INSERT INTO LopNangKhieu VALUES (3, '2012-09-01', 'GV3', 550000);

INSERT INTO BienLai VALUES (1, 8, 2012, 1, 'SV001', 500000);
INSERT INTO BienLai VALUES (2, 8, 2012, 2, 'SV002', 600000);
INSERT INTO BienLai VALUES (3, 9, 2012, 3, 'SV003', 550000);

USE SiteB;
GO

INSERT INTO CauLacBo VALUES (51, N'Câu lạc bộ Anh văn', N'K2');
INSERT INTO CauLacBo VALUES (52, N'Câu lạc bộ Thể thao', N'K3');

INSERT INTO GiangVien VALUES ('GV51', N'Võ Thị F', 51);
INSERT INTO GiangVien VALUES ('GV52', N'Đặng Văn G', 52);

INSERT INTO SinhVien VALUES ('SV051', N'Trương Văn F', 51);
INSERT INTO SinhVien VALUES ('SV052', N'Lý Thị G', 52);

INSERT INTO LopNangKhieu VALUES (51, '2012-08-20', 'GV51', 700000);
INSERT INTO LopNangKhieu VALUES (52, '2012-07-01', 'GV52', 650000);

INSERT INTO BienLai VALUES (51, 9, 2012, 51, 'SV051', 700000);
INSERT INTO BienLai VALUES (52, 7, 2012, 52, 'SV052', 650000);

GO

PRINT N'========================================';
PRINT N'Hoàn thành setup database với phân mảnh linh hoạt!';
PRINT N'';
PRINT N'CÁCH SỬ DỤNG:';
PRINT N'1. Xem cấu hình hiện tại:';
PRINT N'   SELECT * FROM ClubManagementGlobal.dbo.FragmentationConfig';
PRINT N'';
PRINT N'2. Thay đổi ngưỡng (ví dụ: CauLacBo từ 1-100 cho Site A):';
PRINT N'   UPDATE ClubManagementGlobal.dbo.FragmentationConfig';
PRINT N'   SET ThresholdValue = 100';
PRINT N'   WHERE TableName = ''CauLacBo''';
PRINT N'';
PRINT N'3. Trigger sẽ tự động sử dụng ngưỡng mới!';
PRINT N'========================================';
