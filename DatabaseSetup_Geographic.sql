-- =============================================
-- HỆ THỐNG QUẢN LÝ CÂU LẠC BỘ - PHÂN MẢNH THEO KHU VỰC
-- Geographic Partitioning (Phân mảnh địa lý)
-- 
-- LOGIC PHÂN MẢNH:
-- - TPHCM → Site A
-- - HaNoi → Site B
-- - Dễ mở rộng: thêm khu vực = thêm site
-- =============================================

USE master;
GO

-- Tạo databases
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ClubManagementGlobal')
    CREATE DATABASE ClubManagementGlobal;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SiteA')
    CREATE DATABASE SiteA;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SiteB')
    CREATE DATABASE SiteB;
GO

-- =============================================
-- DATABASE TOÀN CỤC: Cấu hình phân mảnh
-- =============================================
USE ClubManagementGlobal;
GO

IF OBJECT_ID('FragmentationConfig', 'U') IS NOT NULL DROP TABLE FragmentationConfig;
GO

CREATE TABLE FragmentationConfig (
    ConfigKey NVARCHAR(50) PRIMARY KEY,
    ConfigValue NVARCHAR(200) NOT NULL,
    Description NVARCHAR(200),
    LastModified DATETIME DEFAULT GETDATE()
);
GO

INSERT INTO FragmentationConfig (ConfigKey, ConfigValue, Description) VALUES
('FragmentationType', 'GEOGRAPHIC', N'Phân mảnh theo khu vực địa lý'),
('SiteA_Region', 'TPHCM', N'Site A: TP. Hồ Chí Minh'),
('SiteB_Region', 'HaNoi', N'Site B: Hà Nội');
GO

-- Function xác định site theo KhuVuc
IF OBJECT_ID('dbo.GetSiteByKhuVuc', 'FN') IS NOT NULL DROP FUNCTION dbo.GetSiteByKhuVuc;
GO

CREATE FUNCTION dbo.GetSiteByKhuVuc(@KhuVuc NVARCHAR(50))
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CASE 
        WHEN @KhuVuc = 'TPHCM' THEN 'SiteA'
        WHEN @KhuVuc = 'HaNoi' THEN 'SiteB'
        ELSE 'SiteA' -- Mặc định
    END;
END;
GO

-- =============================================
-- SITE A: TP. Hồ Chí Minh
-- =============================================
USE SiteA;
GO

IF OBJECT_ID('BienLai', 'U') IS NOT NULL DROP TABLE BienLai;
IF OBJECT_ID('LopNangKhieu', 'U') IS NOT NULL DROP TABLE LopNangKhieu;
IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
IF OBJECT_ID('CauLacBo', 'U') IS NOT NULL DROP TABLE CauLacBo;
IF OBJECT_ID('ActivityLog', 'U') IS NOT NULL DROP TABLE ActivityLog;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL,
    KhuVuc NVARCHAR(50) NOT NULL DEFAULT 'TPHCM',
    CONSTRAINT CHK_SiteA_Region CHECK (KhuVuc = 'TPHCM')
);

CREATE TABLE GiangVien (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTenGV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL,
    CONSTRAINT FK_GV_CLB_A FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB) ON DELETE CASCADE
);

CREATE TABLE SinhVien (
    MaSV VARCHAR(10) PRIMARY KEY,
    HoTenSV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL,
    CONSTRAINT FK_SV_CLB_A FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB) ON DELETE CASCADE
);

CREATE TABLE LopNangKhieu (
    MaLop INT PRIMARY KEY,
    NgayMo DATE NOT NULL,
    MaGV VARCHAR(10) NOT NULL,
    HocPhi DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Lop_GV_A FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV) ON DELETE CASCADE
);

CREATE TABLE BienLai (
    SoBL INT PRIMARY KEY,
    Thang INT NOT NULL,
    Nam INT NOT NULL,
    MaLop INT NOT NULL,
    MaSV VARCHAR(10) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_BL_Lop_A FOREIGN KEY (MaLop) REFERENCES LopNangKhieu(MaLop) ON DELETE NO ACTION,
    CONSTRAINT FK_BL_SV_A FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV) ON DELETE NO ACTION
);

CREATE TABLE ActivityLog (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(20) NOT NULL,
    TableName NVARCHAR(50) NOT NULL,
    RecordId NVARCHAR(50),
    Site NVARCHAR(10) DEFAULT 'SiteA',
    Username NVARCHAR(100),
    Timestamp DATETIME DEFAULT GETDATE(),
    Details NVARCHAR(500)
);
GO

-- =============================================
-- SITE B: Hà Nội
-- =============================================
USE SiteB;
GO

IF OBJECT_ID('BienLai', 'U') IS NOT NULL DROP TABLE BienLai;
IF OBJECT_ID('LopNangKhieu', 'U') IS NOT NULL DROP TABLE LopNangKhieu;
IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
IF OBJECT_ID('CauLacBo', 'U') IS NOT NULL DROP TABLE CauLacBo;
IF OBJECT_ID('ActivityLog', 'U') IS NOT NULL DROP TABLE ActivityLog;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL,
    KhuVuc NVARCHAR(50) NOT NULL DEFAULT 'HaNoi',
    CONSTRAINT CHK_SiteB_Region CHECK (KhuVuc = 'HaNoi')
);

CREATE TABLE GiangVien (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTenGV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL,
    CONSTRAINT FK_GV_CLB_B FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB) ON DELETE CASCADE
);

CREATE TABLE SinhVien (
    MaSV VARCHAR(10) PRIMARY KEY,
    HoTenSV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL,
    CONSTRAINT FK_SV_CLB_B FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB) ON DELETE CASCADE
);

CREATE TABLE LopNangKhieu (
    MaLop INT PRIMARY KEY,
    NgayMo DATE NOT NULL,
    MaGV VARCHAR(10) NOT NULL,
    HocPhi DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Lop_GV_B FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV) ON DELETE CASCADE
);

CREATE TABLE BienLai (
    SoBL INT PRIMARY KEY,
    Thang INT NOT NULL,
    Nam INT NOT NULL,
    MaLop INT NOT NULL,
    MaSV VARCHAR(10) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_BL_Lop_B FOREIGN KEY (MaLop) REFERENCES LopNangKhieu(MaLop) ON DELETE NO ACTION,
    CONSTRAINT FK_BL_SV_B FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV) ON DELETE NO ACTION
);

CREATE TABLE ActivityLog (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(20) NOT NULL,
    TableName NVARCHAR(50) NOT NULL,
    RecordId NVARCHAR(50),
    Site NVARCHAR(10) DEFAULT 'SiteB',
    Username NVARCHAR(100),
    Timestamp DATETIME DEFAULT GETDATE(),
    Details NVARCHAR(500)
);
GO

-- =============================================
-- DATABASE TOÀN CỤC: Tạo VIEW
-- =============================================
USE ClubManagementGlobal;
GO

IF OBJECT_ID('vw_CauLacBo', 'V') IS NOT NULL DROP VIEW vw_CauLacBo;
IF OBJECT_ID('vw_GiangVien', 'V') IS NOT NULL DROP VIEW vw_GiangVien;
IF OBJECT_ID('vw_SinhVien', 'V') IS NOT NULL DROP VIEW vw_SinhVien;
IF OBJECT_ID('vw_LopNangKhieu', 'V') IS NOT NULL DROP VIEW vw_LopNangKhieu;
IF OBJECT_ID('vw_BienLai', 'V') IS NOT NULL DROP VIEW vw_BienLai;
IF OBJECT_ID('vw_ActivityLog', 'V') IS NOT NULL DROP VIEW vw_ActivityLog;
GO

CREATE VIEW vw_CauLacBo AS
SELECT *, 'SiteA' AS SourceSite FROM SiteA.dbo.CauLacBo
UNION ALL
SELECT *, 'SiteB' AS SourceSite FROM SiteB.dbo.CauLacBo;
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

CREATE VIEW vw_ActivityLog AS
SELECT * FROM SiteA.dbo.ActivityLog
UNION ALL
SELECT * FROM SiteB.dbo.ActivityLog;
GO


-- =============================================
-- TRIGGER PHÂN MẢNH THEO KHU VỰC
-- =============================================

-- Trigger INSERT cho CauLacBo
CREATE TRIGGER trg_Insert_CauLacBo
ON vw_CauLacBo
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- TPHCM → Site A
    INSERT INTO SiteA.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa, KhuVuc)
    SELECT MaCLB, TenCLB, TenKhoa, KhuVuc FROM inserted WHERE KhuVuc = 'TPHCM';
    
    -- HaNoi → Site B
    INSERT INTO SiteB.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa, KhuVuc)
    SELECT MaCLB, TenCLB, TenKhoa, KhuVuc FROM inserted WHERE KhuVuc = 'HaNoi';
END;
GO

-- Trigger UPDATE cho CauLacBo
CREATE TRIGGER trg_Update_CauLacBo
ON vw_CauLacBo
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SiteA.dbo.CauLacBo
    SET TenCLB = i.TenCLB, TenKhoa = i.TenKhoa, KhuVuc = i.KhuVuc
    FROM SiteA.dbo.CauLacBo c INNER JOIN inserted i ON c.MaCLB = i.MaCLB;
    
    UPDATE SiteB.dbo.CauLacBo
    SET TenCLB = i.TenCLB, TenKhoa = i.TenKhoa, KhuVuc = i.KhuVuc
    FROM SiteB.dbo.CauLacBo c INNER JOIN inserted i ON c.MaCLB = i.MaCLB;
END;
GO

-- Trigger DELETE cho CauLacBo
CREATE TRIGGER trg_Delete_CauLacBo
ON vw_CauLacBo
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SiteA.dbo.CauLacBo WHERE MaCLB IN (SELECT MaCLB FROM deleted);
    DELETE FROM SiteB.dbo.CauLacBo WHERE MaCLB IN (SELECT MaCLB FROM deleted);
END;
GO

-- Trigger INSERT cho GiangVien (theo site của CLB)
CREATE TRIGGER trg_Insert_GiangVien
ON vw_GiangVien
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SiteA.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT i.MaGV, i.HoTenGV, i.MaCLB FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
    
    INSERT INTO SiteB.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT i.MaGV, i.HoTenGV, i.MaCLB FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
END;
GO

-- Trigger UPDATE cho GiangVien
CREATE TRIGGER trg_Update_GiangVien
ON vw_GiangVien
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SiteA.dbo.GiangVien
    SET HoTenGV = i.HoTenGV, MaCLB = i.MaCLB
    FROM SiteA.dbo.GiangVien g INNER JOIN inserted i ON g.MaGV = i.MaGV;
    
    UPDATE SiteB.dbo.GiangVien
    SET HoTenGV = i.HoTenGV, MaCLB = i.MaCLB
    FROM SiteB.dbo.GiangVien g INNER JOIN inserted i ON g.MaGV = i.MaGV;
END;
GO

-- Trigger DELETE cho GiangVien
CREATE TRIGGER trg_Delete_GiangVien
ON vw_GiangVien
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SiteA.dbo.GiangVien WHERE MaGV IN (SELECT MaGV FROM deleted);
    DELETE FROM SiteB.dbo.GiangVien WHERE MaGV IN (SELECT MaGV FROM deleted);
END;
GO

-- Trigger INSERT cho SinhVien
CREATE TRIGGER trg_Insert_SinhVien
ON vw_SinhVien
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SiteA.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT i.MaSV, i.HoTenSV, i.MaCLB FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
    
    INSERT INTO SiteB.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT i.MaSV, i.HoTenSV, i.MaCLB FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.CauLacBo WHERE MaCLB = i.MaCLB);
END;
GO

-- Trigger UPDATE cho SinhVien
CREATE TRIGGER trg_Update_SinhVien
ON vw_SinhVien
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SiteA.dbo.SinhVien
    SET HoTenSV = i.HoTenSV, MaCLB = i.MaCLB
    FROM SiteA.dbo.SinhVien s INNER JOIN inserted i ON s.MaSV = i.MaSV;
    
    UPDATE SiteB.dbo.SinhVien
    SET HoTenSV = i.HoTenSV, MaCLB = i.MaCLB
    FROM SiteB.dbo.SinhVien s INNER JOIN inserted i ON s.MaSV = i.MaSV;
END;
GO

-- Trigger DELETE cho SinhVien
CREATE TRIGGER trg_Delete_SinhVien
ON vw_SinhVien
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SiteA.dbo.SinhVien WHERE MaSV IN (SELECT MaSV FROM deleted);
    DELETE FROM SiteB.dbo.SinhVien WHERE MaSV IN (SELECT MaSV FROM deleted);
END;
GO

-- Trigger INSERT cho LopNangKhieu
CREATE TRIGGER trg_Insert_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SiteA.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT i.MaLop, i.NgayMo, i.MaGV, i.HocPhi FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.GiangVien WHERE MaGV = i.MaGV);
    
    INSERT INTO SiteB.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT i.MaLop, i.NgayMo, i.MaGV, i.HocPhi FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.GiangVien WHERE MaGV = i.MaGV);
END;
GO

-- Trigger UPDATE cho LopNangKhieu
CREATE TRIGGER trg_Update_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SiteA.dbo.LopNangKhieu
    SET NgayMo = i.NgayMo, MaGV = i.MaGV, HocPhi = i.HocPhi
    FROM SiteA.dbo.LopNangKhieu l INNER JOIN inserted i ON l.MaLop = i.MaLop;
    
    UPDATE SiteB.dbo.LopNangKhieu
    SET NgayMo = i.NgayMo, MaGV = i.MaGV, HocPhi = i.HocPhi
    FROM SiteB.dbo.LopNangKhieu l INNER JOIN inserted i ON l.MaLop = i.MaLop;
END;
GO

-- Trigger DELETE cho LopNangKhieu
CREATE TRIGGER trg_Delete_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SiteA.dbo.LopNangKhieu WHERE MaLop IN (SELECT MaLop FROM deleted);
    DELETE FROM SiteB.dbo.LopNangKhieu WHERE MaLop IN (SELECT MaLop FROM deleted);
END;
GO

-- Trigger INSERT cho BienLai
CREATE TRIGGER trg_Insert_BienLai
ON vw_BienLai
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SiteA.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT i.SoBL, i.Thang, i.Nam, i.MaLop, i.MaSV, i.SoTien FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteA.dbo.LopNangKhieu WHERE MaLop = i.MaLop);
    
    INSERT INTO SiteB.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT i.SoBL, i.Thang, i.Nam, i.MaLop, i.MaSV, i.SoTien FROM inserted i
    WHERE EXISTS (SELECT 1 FROM SiteB.dbo.LopNangKhieu WHERE MaLop = i.MaLop);
END;
GO

-- Trigger UPDATE cho BienLai
CREATE TRIGGER trg_Update_BienLai
ON vw_BienLai
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SiteA.dbo.BienLai
    SET Thang = i.Thang, Nam = i.Nam, MaLop = i.MaLop, MaSV = i.MaSV, SoTien = i.SoTien
    FROM SiteA.dbo.BienLai b INNER JOIN inserted i ON b.SoBL = i.SoBL;
    
    UPDATE SiteB.dbo.BienLai
    SET Thang = i.Thang, Nam = i.Nam, MaLop = i.MaLop, MaSV = i.MaSV, SoTien = i.SoTien
    FROM SiteB.dbo.BienLai b INNER JOIN inserted i ON b.SoBL = i.SoBL;
END;
GO

-- Trigger DELETE cho BienLai
CREATE TRIGGER trg_Delete_BienLai
ON vw_BienLai
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SiteA.dbo.BienLai WHERE SoBL IN (SELECT SoBL FROM deleted);
    DELETE FROM SiteB.dbo.BienLai WHERE SoBL IN (SELECT SoBL FROM deleted);
END;
GO


-- =============================================
-- TRIGGER GHI LOG
-- =============================================
USE SiteA;
GO

CREATE TRIGGER trg_Log_CauLacBo_A ON CauLacBo AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'CauLacBo', CAST(MaCLB AS NVARCHAR), 'SiteA', N'Thêm CLB: ' + TenCLB + N' (' + KhuVuc + N')' FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'CauLacBo', CAST(MaCLB AS NVARCHAR), 'SiteA', N'Cập nhật CLB: ' + TenCLB FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'CauLacBo', CAST(MaCLB AS NVARCHAR), 'SiteA', N'Xóa CLB: ' + TenCLB FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_GiangVien_A ON GiangVien AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'GiangVien', MaGV, 'SiteA', N'Thêm GV: ' + HoTenGV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'GiangVien', MaGV, 'SiteA', N'Cập nhật GV: ' + HoTenGV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'GiangVien', MaGV, 'SiteA', N'Xóa GV: ' + HoTenGV FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_SinhVien_A ON SinhVien AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'SinhVien', MaSV, 'SiteA', N'Thêm SV: ' + HoTenSV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'SinhVien', MaSV, 'SiteA', N'Cập nhật SV: ' + HoTenSV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'SinhVien', MaSV, 'SiteA', N'Xóa SV: ' + HoTenSV FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_LopNangKhieu_A ON LopNangKhieu AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'LopNangKhieu', CAST(MaLop AS NVARCHAR), 'SiteA', N'Thêm lớp: ' + CAST(MaLop AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'LopNangKhieu', CAST(MaLop AS NVARCHAR), 'SiteA', N'Cập nhật lớp: ' + CAST(MaLop AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'LopNangKhieu', CAST(MaLop AS NVARCHAR), 'SiteA', N'Xóa lớp: ' + CAST(MaLop AS NVARCHAR) FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_BienLai_A ON BienLai AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'BienLai', CAST(SoBL AS NVARCHAR), 'SiteA', N'Thêm biên lai: ' + CAST(SoBL AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'BienLai', CAST(SoBL AS NVARCHAR), 'SiteA', N'Cập nhật biên lai: ' + CAST(SoBL AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'BienLai', CAST(SoBL AS NVARCHAR), 'SiteA', N'Xóa biên lai: ' + CAST(SoBL AS NVARCHAR) FROM deleted;
END;
GO

USE SiteB;
GO

CREATE TRIGGER trg_Log_CauLacBo_B ON CauLacBo AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'CauLacBo', CAST(MaCLB AS NVARCHAR), 'SiteB', N'Thêm CLB: ' + TenCLB + N' (' + KhuVuc + N')' FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'CauLacBo', CAST(MaCLB AS NVARCHAR), 'SiteB', N'Cập nhật CLB: ' + TenCLB FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'CauLacBo', CAST(MaCLB AS NVARCHAR), 'SiteB', N'Xóa CLB: ' + TenCLB FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_GiangVien_B ON GiangVien AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'GiangVien', MaGV, 'SiteB', N'Thêm GV: ' + HoTenGV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'GiangVien', MaGV, 'SiteB', N'Cập nhật GV: ' + HoTenGV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'GiangVien', MaGV, 'SiteB', N'Xóa GV: ' + HoTenGV FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_SinhVien_B ON SinhVien AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'SinhVien', MaSV, 'SiteB', N'Thêm SV: ' + HoTenSV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'SinhVien', MaSV, 'SiteB', N'Cập nhật SV: ' + HoTenSV FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'SinhVien', MaSV, 'SiteB', N'Xóa SV: ' + HoTenSV FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_LopNangKhieu_B ON LopNangKhieu AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'LopNangKhieu', CAST(MaLop AS NVARCHAR), 'SiteB', N'Thêm lớp: ' + CAST(MaLop AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'LopNangKhieu', CAST(MaLop AS NVARCHAR), 'SiteB', N'Cập nhật lớp: ' + CAST(MaLop AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'LopNangKhieu', CAST(MaLop AS NVARCHAR), 'SiteB', N'Xóa lớp: ' + CAST(MaLop AS NVARCHAR) FROM deleted;
END;
GO

CREATE TRIGGER trg_Log_BienLai_B ON BienLai AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'INSERT', 'BienLai', CAST(SoBL AS NVARCHAR), 'SiteB', N'Thêm biên lai: ' + CAST(SoBL AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'UPDATE', 'BienLai', CAST(SoBL AS NVARCHAR), 'SiteB', N'Cập nhật biên lai: ' + CAST(SoBL AS NVARCHAR) FROM inserted;
    ELSE IF EXISTS (SELECT 1 FROM deleted)
        INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
        SELECT 'DELETE', 'BienLai', CAST(SoBL AS NVARCHAR), 'SiteB', N'Xóa biên lai: ' + CAST(SoBL AS NVARCHAR) FROM deleted;
END;
GO

-- =============================================
-- DỮ LIỆU MẪU
-- =============================================

-- Site A: TP. Hồ Chí Minh
USE SiteA;
GO

INSERT INTO CauLacBo (MaCLB, TenCLB, TenKhoa, KhuVuc) VALUES
(1, N'CLB Tin học Sài Gòn', N'CNTT', 'TPHCM'),
(2, N'CLB Bóng đá Q1', N'Thể thao', 'TPHCM'),
(3, N'CLB Âm nhạc Thủ Đức', N'Nghệ thuật', 'TPHCM'),
(4, N'CLB Tiếng Anh Q7', N'Ngoại ngữ', 'TPHCM'),
(5, N'CLB Robotics Bình Thạnh', N'CNTT', 'TPHCM');

INSERT INTO GiangVien (MaGV, HoTenGV, MaCLB) VALUES
('GV01', N'Nguyễn Văn An', 1),
('GV02', N'Trần Thị Bình', 2),
('GV03', N'Lê Văn Cường', 3),
('GV04', N'Phạm Thị Dung', 4),
('GV05', N'Hoàng Văn Em', 5);

INSERT INTO SinhVien (MaSV, HoTenSV, MaCLB) VALUES
('SV001', N'Nguyễn Minh Anh', 1),
('SV002', N'Trần Quốc Bảo', 2),
('SV003', N'Lê Thị Cẩm', 3),
('SV004', N'Phạm Văn Dũng', 4),
('SV005', N'Hoàng Thị Em', 5);

INSERT INTO LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi) VALUES
(1, '2024-01-15', 'GV01', 500000),
(2, '2024-02-01', 'GV02', 600000),
(3, '2024-03-10', 'GV03', 550000),
(4, '2024-04-05', 'GV04', 700000),
(5, '2024-05-20', 'GV05', 650000);

INSERT INTO BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien) VALUES
(1, 1, 2024, 1, 'SV001', 500000),
(2, 2, 2024, 2, 'SV002', 600000),
(3, 3, 2024, 3, 'SV003', 550000),
(4, 4, 2024, 4, 'SV004', 700000),
(5, 5, 2024, 5, 'SV005', 650000);
GO

-- Site B: Hà Nội
USE SiteB;
GO

INSERT INTO CauLacBo (MaCLB, TenCLB, TenKhoa, KhuVuc) VALUES
(6, N'CLB Tin học Hà Nội', N'CNTT', 'HaNoi'),
(7, N'CLB Bóng đá Cầu Giấy', N'Thể thao', 'HaNoi'),
(8, N'CLB Âm nhạc Hoàn Kiếm', N'Nghệ thuật', 'HaNoi'),
(9, N'CLB Tiếng Anh Đống Đa', N'Ngoại ngữ', 'HaNoi'),
(10, N'CLB Robotics Thanh Xuân', N'CNTT', 'HaNoi');

INSERT INTO GiangVien (MaGV, HoTenGV, MaCLB) VALUES
('GV06', N'Vũ Thị Phương', 6),
('GV07', N'Đặng Văn Giang', 7),
('GV08', N'Bùi Thị Hoa', 8),
('GV09', N'Ngô Văn Inh', 9),
('GV10', N'Dương Thị Kim', 10);

INSERT INTO SinhVien (MaSV, HoTenSV, MaCLB) VALUES
('SV006', N'Vũ Minh Phong', 6),
('SV007', N'Đặng Thị Giang', 7),
('SV008', N'Bùi Văn Hải', 8),
('SV009', N'Ngô Thị Hương', 9),
('SV010', N'Dương Văn Khoa', 10);

INSERT INTO LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi) VALUES
(6, '2024-01-20', 'GV06', 520000),
(7, '2024-02-15', 'GV07', 620000),
(8, '2024-03-25', 'GV08', 570000),
(9, '2024-04-10', 'GV09', 720000),
(10, '2024-05-30', 'GV10', 670000);

INSERT INTO BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien) VALUES
(6, 1, 2024, 6, 'SV006', 520000),
(7, 2, 2024, 7, 'SV007', 620000),
(8, 3, 2024, 8, 'SV008', 570000),
(9, 4, 2024, 9, 'SV009', 720000),
(10, 5, 2024, 10, 'SV010', 670000);
GO

USE ClubManagementGlobal;
GO

PRINT N'========================================';
PRINT N'HOÀN THÀNH - PHÂN MẢNH THEO KHU VỰC';
PRINT N'';
PRINT N'LOGIC PHÂN MẢNH:';
PRINT N'- Site A: TP. Hồ Chí Minh (TPHCM)';
PRINT N'- Site B: Hà Nội (HaNoi)';
PRINT N'';
PRINT N'ƯU ĐIỂM:';
PRINT N'- Giảm latency theo vùng địa lý';
PRINT N'- Dễ mở rộng thêm khu vực';
PRINT N'- Phù hợp nghiệp vụ thực tế';
PRINT N'========================================';
