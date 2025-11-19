-- =============================================
-- HỆ THỐNG QUẢN LÝ CÂU LẠC BỘ VÀ LỚP NĂNG KHIẾU
-- Cơ sở dữ liệu phân tán - PHÂN MẢNH NGANG (Horizontal Fragmentation)
-- Sử dụng UNION ALL để kết hợp dữ liệu từ nhiều site
-- =============================================

USE master;
GO

-- Tạo database toàn cục
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ClubManagementGlobal')
BEGIN
    CREATE DATABASE ClubManagementGlobal;
END
GO

-- Tạo các database site (mô phỏng phân tán)
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
-- SITE A: Chứa dữ liệu với ID nhỏ (1-3)
-- =============================================
USE SiteA;
GO

-- Drop tables if exist
IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('CauLacBo', 'U') IS NOT NULL DROP TABLE CauLacBo;
IF OBJECT_ID('BienLai', 'U') IS NOT NULL DROP TABLE BienLai;
IF OBJECT_ID('LopNangKhieu', 'U') IS NOT NULL DROP TABLE LopNangKhieu;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL,
    CHECK (MaCLB BETWEEN 1 AND 3)  -- Site A: MaCLB 1-3
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
    HocPhi DECIMAL(18,2) NOT NULL,
    CHECK (MaLop BETWEEN 1 AND 3)  -- Site A: MaLop 1-3
);

CREATE TABLE BienLai (
    SoBL INT PRIMARY KEY,
    Thang INT NOT NULL,
    Nam INT NOT NULL,
    MaLop INT NOT NULL,
    MaSV VARCHAR(10) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    CHECK (SoBL BETWEEN 1 AND 4)  -- Site A: SoBL 1-4
);

-- =============================================
-- SITE B: Chứa dữ liệu với ID lớn (4+)
-- =============================================
USE SiteB;
GO

-- Drop tables if exist
IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('CauLacBo', 'U') IS NOT NULL DROP TABLE CauLacBo;
IF OBJECT_ID('BienLai', 'U') IS NOT NULL DROP TABLE BienLai;
IF OBJECT_ID('LopNangKhieu', 'U') IS NOT NULL DROP TABLE LopNangKhieu;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL,
    CHECK (MaCLB >= 4)  -- Site B: MaCLB 4+
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
    HocPhi DECIMAL(18,2) NOT NULL,
    CHECK (MaLop >= 4)  -- Site B: MaLop 4+
);

CREATE TABLE BienLai (
    SoBL INT PRIMARY KEY,
    Thang INT NOT NULL,
    Nam INT NOT NULL,
    MaLop INT NOT NULL,
    MaSV VARCHAR(10) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    CHECK (SoBL >= 5)  -- Site B: SoBL 5+
);

-- =============================================
-- DATABASE TOÀN CỤC: Tạo các VIEW với UNION ALL
-- =============================================
USE ClubManagementGlobal;
GO

-- Drop existing views
IF OBJECT_ID('vw_CauLacBo', 'V') IS NOT NULL DROP VIEW vw_CauLacBo;
IF OBJECT_ID('vw_GiangVien', 'V') IS NOT NULL DROP VIEW vw_GiangVien;
IF OBJECT_ID('vw_SinhVien', 'V') IS NOT NULL DROP VIEW vw_SinhVien;
IF OBJECT_ID('vw_LopNangKhieu', 'V') IS NOT NULL DROP VIEW vw_LopNangKhieu;
IF OBJECT_ID('vw_BienLai', 'V') IS NOT NULL DROP VIEW vw_BienLai;
GO

-- View toàn cục cho Câu lạc bộ (UNION ALL từ 2 site)
CREATE VIEW vw_CauLacBo AS
SELECT * FROM SiteA.dbo.CauLacBo
UNION ALL
SELECT * FROM SiteB.dbo.CauLacBo;
GO

-- View toàn cục cho Giảng viên (UNION ALL từ 2 site)
CREATE VIEW vw_GiangVien AS
SELECT * FROM SiteA.dbo.GiangVien
UNION ALL
SELECT * FROM SiteB.dbo.GiangVien;
GO

-- View toàn cục cho Sinh viên (UNION ALL từ 2 site)
CREATE VIEW vw_SinhVien AS
SELECT * FROM SiteA.dbo.SinhVien
UNION ALL
SELECT * FROM SiteB.dbo.SinhVien;
GO

-- View toàn cục cho Lớp năng khiếu (UNION ALL từ 2 site)
CREATE VIEW vw_LopNangKhieu AS
SELECT * FROM SiteA.dbo.LopNangKhieu
UNION ALL
SELECT * FROM SiteB.dbo.LopNangKhieu;
GO

-- View toàn cục cho Biên lai (UNION ALL từ 2 site)
CREATE VIEW vw_BienLai AS
SELECT * FROM SiteA.dbo.BienLai
UNION ALL
SELECT * FROM SiteB.dbo.BienLai;
GO

-- =============================================
-- TẠO TRIGGER INSTEAD OF CHO CÁC VIEW
-- Trigger sẽ định tuyến dữ liệu đến đúng site dựa trên ID
-- =============================================

-- Trigger INSERT cho vw_CauLacBo
CREATE TRIGGER trg_Insert_CauLacBo
ON vw_CauLacBo
INSTEAD OF INSERT
AS
BEGIN
    -- Insert vào Site A nếu MaCLB từ 1-3
    INSERT INTO SiteA.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa 
    FROM inserted 
    WHERE MaCLB BETWEEN 1 AND 3;
    
    -- Insert vào Site B nếu MaCLB >= 4
    INSERT INTO SiteB.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa 
    FROM inserted 
    WHERE MaCLB >= 4;
END;
GO

-- Trigger UPDATE cho vw_CauLacBo
CREATE TRIGGER trg_Update_CauLacBo
ON vw_CauLacBo
INSTEAD OF UPDATE
AS
BEGIN
    -- Update ở Site A
    UPDATE SiteA.dbo.CauLacBo
    SET TenCLB = i.TenCLB, TenKhoa = i.TenKhoa
    FROM SiteA.dbo.CauLacBo c
    INNER JOIN inserted i ON c.MaCLB = i.MaCLB;
    
    -- Update ở Site B
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

-- Trigger INSERT cho vw_GiangVien
CREATE TRIGGER trg_Insert_GiangVien
ON vw_GiangVien
INSTEAD OF INSERT
AS
BEGIN
    -- Phân bổ dựa trên số cuối của MaGV (GV1-GV5 -> Site A, GV6+ -> Site B)
    INSERT INTO SiteA.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT MaGV, HoTenGV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaGV, 3, LEN(MaGV)) AS INT) <= 5;
    
    INSERT INTO SiteB.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT MaGV, HoTenGV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaGV, 3, LEN(MaGV)) AS INT) > 5;
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

-- Trigger INSERT cho vw_SinhVien
CREATE TRIGGER trg_Insert_SinhVien
ON vw_SinhVien
INSTEAD OF INSERT
AS
BEGIN
    -- Phân bổ dựa trên số cuối của MaSV (SV001-SV005 -> Site A, SV006+ -> Site B)
    INSERT INTO SiteA.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT MaSV, HoTenSV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaSV, 3, LEN(MaSV)) AS INT) <= 5;
    
    INSERT INTO SiteB.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT MaSV, HoTenSV, MaCLB 
    FROM inserted 
    WHERE CAST(SUBSTRING(MaSV, 3, LEN(MaSV)) AS INT) > 5;
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

-- Trigger INSERT cho vw_LopNangKhieu
CREATE TRIGGER trg_Insert_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT MaLop, NgayMo, MaGV, HocPhi 
    FROM inserted 
    WHERE MaLop BETWEEN 1 AND 3;
    
    INSERT INTO SiteB.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT MaLop, NgayMo, MaGV, HocPhi 
    FROM inserted 
    WHERE MaLop >= 4;
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

-- Trigger INSERT cho vw_BienLai
CREATE TRIGGER trg_Insert_BienLai
ON vw_BienLai
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT SoBL, Thang, Nam, MaLop, MaSV, SoTien 
    FROM inserted 
    WHERE SoBL BETWEEN 1 AND 4;
    
    INSERT INTO SiteB.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT SoBL, Thang, Nam, MaLop, MaSV, SoTien 
    FROM inserted 
    WHERE SoBL >= 5;
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
-- DỮ LIỆU MẪU - Phân bổ theo site
-- =============================================

-- Thêm dữ liệu vào SiteA (ID nhỏ)
USE SiteA;
GO

INSERT INTO CauLacBo VALUES (1, N'Câu lạc bộ Tin học', N'K1');
INSERT INTO CauLacBo VALUES (2, N'Câu lạc bộ Toán học', N'K2');
INSERT INTO CauLacBo VALUES (3, N'Câu lạc bộ Văn học', N'K1');

INSERT INTO GiangVien VALUES ('GV1', N'Nguyễn Văn A', 1);
INSERT INTO GiangVien VALUES ('GV2', N'Trần Thị B', 2);
INSERT INTO GiangVien VALUES ('GV3', N'Lê Văn C', 3);
INSERT INTO GiangVien VALUES ('GV4', N'Phạm Thị D', 1);
INSERT INTO GiangVien VALUES ('GV5', N'Hoàng Văn E', 2);

INSERT INTO SinhVien VALUES ('SV001', N'Nguyễn Minh A', 1);
INSERT INTO SinhVien VALUES ('SV002', N'Trần Thị B', 2);
INSERT INTO SinhVien VALUES ('SV003', N'Lê Văn C', 3);
INSERT INTO SinhVien VALUES ('SV004', N'Phạm Thị D', 1);
INSERT INTO SinhVien VALUES ('SV005', N'Hoàng Văn E', 2);

INSERT INTO LopNangKhieu VALUES (1, '2012-08-01', 'GV1', 500000);
INSERT INTO LopNangKhieu VALUES (2, '2012-08-15', 'GV2', 600000);
INSERT INTO LopNangKhieu VALUES (3, '2012-09-01', 'GV3', 550000);

INSERT INTO BienLai VALUES (1, 8, 2012, 1, 'SV001', 500000);
INSERT INTO BienLai VALUES (2, 8, 2012, 2, 'SV002', 600000);
INSERT INTO BienLai VALUES (3, 9, 2012, 3, 'SV003', 550000);
INSERT INTO BienLai VALUES (4, 8, 2012, 1, 'SV004', 500000);

-- Thêm dữ liệu vào SiteB (ID lớn)
USE SiteB;
GO

INSERT INTO CauLacBo VALUES (4, N'Câu lạc bộ Anh văn', N'K2');
INSERT INTO CauLacBo VALUES (5, N'Câu lạc bộ Thể thao', N'K3');
INSERT INTO CauLacBo VALUES (6, N'Câu lạc bộ Âm nhạc', N'K1');

INSERT INTO GiangVien VALUES ('GV6', N'Võ Thị F', 4);
INSERT INTO GiangVien VALUES ('GV7', N'Đặng Văn G', 5);
INSERT INTO GiangVien VALUES ('GV8', N'Bùi Thị H', 6);

INSERT INTO SinhVien VALUES ('SV006', N'Trương Văn F', 4);
INSERT INTO SinhVien VALUES ('SV007', N'Lý Thị G', 5);
INSERT INTO SinhVien VALUES ('SV008', N'Phan Văn H', 6);

INSERT INTO LopNangKhieu VALUES (4, '2012-08-20', 'GV6', 700000);
INSERT INTO LopNangKhieu VALUES (5, '2012-07-01', 'GV7', 650000);
INSERT INTO LopNangKhieu VALUES (6, '2012-09-10', 'GV8', 800000);

INSERT INTO BienLai VALUES (5, 9, 2012, 4, 'SV006', 700000);
INSERT INTO BienLai VALUES (6, 7, 2012, 5, 'SV007', 650000);
INSERT INTO BienLai VALUES (7, 8, 2012, 5, 'SV007', 650000);
INSERT INTO BienLai VALUES (8, 9, 2012, 6, 'SV008', 800000);

GO

PRINT N'Hoàn thành setup database với phân mảnh ngang (Horizontal Fragmentation)!';
PRINT N'- Site A: Chứa dữ liệu với ID nhỏ (CauLacBo 1-3, LopNangKhieu 1-3, BienLai 1-4, GV1-5, SV001-005)';
PRINT N'- Site B: Chứa dữ liệu với ID lớn (CauLacBo 4+, LopNangKhieu 4+, BienLai 5+, GV6+, SV006+)';
PRINT N'- View toàn cục sử dụng UNION ALL để kết hợp dữ liệu từ cả 2 site';
