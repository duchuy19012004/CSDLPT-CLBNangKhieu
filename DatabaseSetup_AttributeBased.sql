-- =============================================
-- HỆ THỐNG QUẢN LÝ CÂU LẠC BỘ - PHÂN MẢNH THEO THUỘC TÍNH
-- Phân mảnh dựa trên giá trị thuộc tính (Attribute-based Fragmentation)
-- 
--   PHÂN MẢNH THEO THUỘC TÍNH
-- - CauLacBo: Phân theo TenKhoa (K1,K2 → Site A | K3,K4,K5 → Site B)
-- - GiangVien, SinhVien, LopNangKhieu, BienLai: Phân theo MaCLB
-- - ID tự động tăng toàn cục, không bị giới hạn bởi site
-- - Phù hợp cho: Production, phân bổ cân bằng theo nghiệp vụ
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

-- Bảng cấu hình phân mảnh theo thuộc tính
IF OBJECT_ID('FragmentationConfig', 'U') IS NOT NULL DROP TABLE FragmentationConfig;
GO

CREATE TABLE FragmentationConfig (
    ConfigKey NVARCHAR(50) PRIMARY KEY,
    ConfigValue NVARCHAR(200) NOT NULL,
    Description NVARCHAR(200),
    LastModified DATETIME DEFAULT GETDATE()
);
GO

-- Cấu hình: Khoa nào thuộc Site A, khoa nào thuộc Site B
INSERT INTO FragmentationConfig (ConfigKey, ConfigValue, Description) VALUES
('SiteA_Khoa', 'K1,K2', N'Các khoa thuộc Site A (phân cách bởi dấu phẩy)'),
('SiteB_Khoa', 'K3,K4,K5', N'Các khoa thuộc Site B (phân cách bởi dấu phẩy)');
GO

-- Function kiểm tra khoa thuộc site nào
CREATE FUNCTION dbo.GetSiteForKhoa(@TenKhoa NVARCHAR(50))
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @Site VARCHAR(10) = 'SiteA'; -- Mặc định Site A
    DECLARE @SiteB_Khoa NVARCHAR(200);
    
    SELECT @SiteB_Khoa = ConfigValue 
    FROM FragmentationConfig 
    WHERE ConfigKey = 'SiteB_Khoa';
    
    -- Kiểm tra nếu khoa nằm trong danh sách Site B
    IF CHARINDEX(@TenKhoa, @SiteB_Khoa) > 0
        SET @Site = 'SiteB';
    
    RETURN @Site;
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
-- TRIGGER PHÂN MẢNH THEO THUỘC TÍNH
-- =============================================

-- Trigger INSERT cho vw_CauLacBo (Phân theo TenKhoa)
CREATE TRIGGER trg_Insert_CauLacBo
ON vw_CauLacBo
INSTEAD OF INSERT
AS
BEGIN
    -- Insert vào Site A nếu TenKhoa thuộc Site A (K1, K2)
    INSERT INTO SiteA.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa 
    FROM inserted 
    WHERE dbo.GetSiteForKhoa(TenKhoa) = 'SiteA';
    
    -- Insert vào Site B nếu TenKhoa thuộc Site B (K3, K4, K5)
    INSERT INTO SiteB.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa 
    FROM inserted 
    WHERE dbo.GetSiteForKhoa(TenKhoa) = 'SiteB';
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

-- Trigger INSERT cho vw_GiangVien (Phân theo MaCLB của CauLacBo)
CREATE TRIGGER trg_Insert_GiangVien
ON vw_GiangVien
INSTEAD OF INSERT
AS
BEGIN
    -- Insert vào Site A nếu CLB thuộc Site A
    INSERT INTO SiteA.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT i.MaGV, i.HoTenGV, i.MaCLB 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
    
    -- Insert vào Site B nếu CLB thuộc Site B
    INSERT INTO SiteB.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT i.MaGV, i.HoTenGV, i.MaCLB 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
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

-- Trigger INSERT cho vw_SinhVien (Phân theo MaCLB)
CREATE TRIGGER trg_Insert_SinhVien
ON vw_SinhVien
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT i.MaSV, i.HoTenSV, i.MaCLB 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
    
    INSERT INTO SiteB.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT i.MaSV, i.HoTenSV, i.MaCLB 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
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

-- Trigger INSERT cho vw_LopNangKhieu (Phân theo MaCLB của GiangVien)
CREATE TRIGGER trg_Insert_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT i.MaLop, i.NgayMo, i.MaGV, i.HocPhi 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.GiangVien WHERE MaGV = i.MaGV);
    
    INSERT INTO SiteB.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT i.MaLop, i.NgayMo, i.MaGV, i.HocPhi 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.GiangVien WHERE MaGV = i.MaGV);
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

-- Trigger INSERT cho vw_BienLai (Phân theo MaLop)
CREATE TRIGGER trg_Insert_BienLai
ON vw_BienLai
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT i.SoBL, i.Thang, i.Nam, i.MaLop, i.MaSV, i.SoTien 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.LopNangKhieu WHERE MaLop = i.MaLop);
    
    INSERT INTO SiteB.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT i.SoBL, i.Thang, i.Nam, i.MaLop, i.MaSV, i.SoTien 
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.LopNangKhieu WHERE MaLop = i.MaLop);
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

-- Câu lạc bộ thuộc khoa K1, K2 → Site A
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

-- Câu lạc bộ thuộc khoa K3, K4, K5 → Site B
INSERT INTO CauLacBo VALUES (4, N'Câu lạc bộ Anh văn', N'K3');
INSERT INTO CauLacBo VALUES (5, N'Câu lạc bộ Thể thao', N'K4');
INSERT INTO CauLacBo VALUES (6, N'Câu lạc bộ Âm nhạc', N'K5');

INSERT INTO GiangVien VALUES ('GV4', N'Võ Thị D', 4);
INSERT INTO GiangVien VALUES ('GV5', N'Đặng Văn E', 5);
INSERT INTO GiangVien VALUES ('GV6', N'Bùi Thị F', 6);

INSERT INTO SinhVien VALUES ('SV004', N'Trương Văn D', 4);
INSERT INTO SinhVien VALUES ('SV005', N'Lý Thị E', 5);
INSERT INTO SinhVien VALUES ('SV006', N'Phan Văn F', 6);

INSERT INTO LopNangKhieu VALUES (4, '2012-08-20', 'GV4', 700000);
INSERT INTO LopNangKhieu VALUES (5, '2012-07-01', 'GV5', 650000);
INSERT INTO LopNangKhieu VALUES (6, '2012-09-10', 'GV6', 800000);

INSERT INTO BienLai VALUES (4, 8, 2012, 4, 'SV004', 700000);
INSERT INTO BienLai VALUES (5, 7, 2012, 5, 'SV005', 650000);
INSERT INTO BienLai VALUES (6, 9, 2012, 6, 'SV006', 800000);

GO

PRINT N'========================================';
PRINT N'Hoàn thành setup database với phân mảnh theo thuộc tính!';
PRINT N'';
PRINT N'LOGIC PHÂN MẢNH:';
PRINT N'- CauLacBo: Phân theo TenKhoa';
PRINT N'  + Site A: K1, K2';
PRINT N'  + Site B: K3, K4, K5';
PRINT N'- GiangVien: Phân theo MaCLB (cùng site với CauLacBo)';
PRINT N'- SinhVien: Phân theo MaCLB (cùng site với CauLacBo)';
PRINT N'- LopNangKhieu: Phân theo MaGV (cùng site với GiangVien)';
PRINT N'- BienLai: Phân theo MaLop (cùng site với LopNangKhieu)';
PRINT N'';
PRINT N'ID tự động tăng toàn cục, không bị giới hạn!';
PRINT N'========================================';
