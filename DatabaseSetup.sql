-- =============================================
-- HỆ THỐNG QUẢN LÝ CÂU LẠC BỘ VÀ LỚP NĂNG KHIẾU
-- Cơ sở dữ liệu phân tán - Mô hình toàn cục
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
-- SITE A: Câu lạc bộ và Giảng viên
-- =============================================
USE SiteA;
GO

CREATE TABLE CauLacBo (
    MaCLB INT PRIMARY KEY,
    TenCLB NVARCHAR(100) NOT NULL,
    TenKhoa NVARCHAR(50) NOT NULL
);

CREATE TABLE GiangVien (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTenGV NVARCHAR(100) NOT NULL,
    MaCLB INT NOT NULL,
    FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB)
);

-- =============================================
-- SITE B: Sinh viên, Lớp năng khiếu, Biên lai
-- =============================================
USE SiteB;
GO

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
    SoTien DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (MaLop) REFERENCES LopNangKhieu(MaLop),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV)
);

-- =============================================
-- DATABASE TOÀN CỤC: Tạo các VIEW
-- =============================================
USE ClubManagementGlobal;
GO

-- View toàn cục cho Câu lạc bộ
CREATE VIEW vw_CauLacBo AS
SELECT * FROM SiteA.dbo.CauLacBo;
GO

-- View toàn cục cho Giảng viên
CREATE VIEW vw_GiangVien AS
SELECT * FROM SiteA.dbo.GiangVien;
GO

-- View toàn cục cho Sinh viên
CREATE VIEW vw_SinhVien AS
SELECT * FROM SiteB.dbo.SinhVien;
GO

-- View toàn cục cho Lớp năng khiếu
CREATE VIEW vw_LopNangKhieu AS
SELECT * FROM SiteB.dbo.LopNangKhieu;
GO

-- View toàn cục cho Biên lai
CREATE VIEW vw_BienLai AS
SELECT * FROM SiteB.dbo.BienLai;
GO

-- =============================================
-- TẠO TRIGGER INSTEAD OF CHO CÁC VIEW
-- =============================================

-- Trigger INSERT cho vw_CauLacBo
CREATE TRIGGER trg_Insert_CauLacBo
ON vw_CauLacBo
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.CauLacBo (MaCLB, TenCLB, TenKhoa)
    SELECT MaCLB, TenCLB, TenKhoa FROM inserted;
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
END;
GO

-- Trigger DELETE cho vw_CauLacBo
CREATE TRIGGER trg_Delete_CauLacBo
ON vw_CauLacBo
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.CauLacBo
    WHERE MaCLB IN (SELECT MaCLB FROM deleted);
END;
GO

-- Trigger INSERT cho vw_GiangVien
CREATE TRIGGER trg_Insert_GiangVien
ON vw_GiangVien
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteA.dbo.GiangVien (MaGV, HoTenGV, MaCLB)
    SELECT MaGV, HoTenGV, MaCLB FROM inserted;
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
END;
GO

-- Trigger DELETE cho vw_GiangVien
CREATE TRIGGER trg_Delete_GiangVien
ON vw_GiangVien
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM SiteA.dbo.GiangVien
    WHERE MaGV IN (SELECT MaGV FROM deleted);
END;
GO

-- Trigger INSERT cho vw_SinhVien
CREATE TRIGGER trg_Insert_SinhVien
ON vw_SinhVien
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteB.dbo.SinhVien (MaSV, HoTenSV, MaCLB)
    SELECT MaSV, HoTenSV, MaCLB FROM inserted;
END;
GO

-- Trigger UPDATE cho vw_SinhVien
CREATE TRIGGER trg_Update_SinhVien
ON vw_SinhVien
INSTEAD OF UPDATE
AS
BEGIN
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
    DELETE FROM SiteB.dbo.SinhVien
    WHERE MaSV IN (SELECT MaSV FROM deleted);
END;
GO

-- Trigger INSERT cho vw_LopNangKhieu
CREATE TRIGGER trg_Insert_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteB.dbo.LopNangKhieu (MaLop, NgayMo, MaGV, HocPhi)
    SELECT MaLop, NgayMo, MaGV, HocPhi FROM inserted;
END;
GO

-- Trigger UPDATE cho vw_LopNangKhieu
CREATE TRIGGER trg_Update_LopNangKhieu
ON vw_LopNangKhieu
INSTEAD OF UPDATE
AS
BEGIN
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
    DELETE FROM SiteB.dbo.LopNangKhieu
    WHERE MaLop IN (SELECT MaLop FROM deleted);
END;
GO

-- Trigger INSERT cho vw_BienLai
CREATE TRIGGER trg_Insert_BienLai
ON vw_BienLai
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO SiteB.dbo.BienLai (SoBL, Thang, Nam, MaLop, MaSV, SoTien)
    SELECT SoBL, Thang, Nam, MaLop, MaSV, SoTien FROM inserted;
END;
GO

-- Trigger UPDATE cho vw_BienLai
CREATE TRIGGER trg_Update_BienLai
ON vw_BienLai
INSTEAD OF UPDATE
AS
BEGIN
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
    DELETE FROM SiteB.dbo.BienLai
    WHERE SoBL IN (SELECT SoBL FROM deleted);
END;
GO

-- =============================================
-- DỮ LIỆU MẪU
-- =============================================

-- Thêm dữ liệu vào SiteA
USE SiteA;
GO

INSERT INTO CauLacBo VALUES (1, N'Câu lạc bộ Tin học', N'K1');
INSERT INTO CauLacBo VALUES (2, N'Câu lạc bộ Toán học', N'K2');
INSERT INTO CauLacBo VALUES (3, N'Câu lạc bộ Văn học', N'K1');
INSERT INTO CauLacBo VALUES (4, N'Câu lạc bộ Anh văn', N'K2');
INSERT INTO CauLacBo VALUES (5, N'Câu lạc bộ Thể thao', N'K3');

INSERT INTO GiangVien VALUES ('GV1', N'Nguyễn Văn A', 1);
INSERT INTO GiangVien VALUES ('GV2', N'Trần Thị B', 2);
INSERT INTO GiangVien VALUES ('GV3', N'Lê Văn C', 3);
INSERT INTO GiangVien VALUES ('GV4', N'Phạm Thị D', 4);
INSERT INTO GiangVien VALUES ('GV5', N'Hoàng Văn E', 5);

-- Thêm dữ liệu vào SiteB
USE SiteB;
GO

INSERT INTO SinhVien VALUES ('SV001', N'Nguyễn Minh A', 1);
INSERT INTO SinhVien VALUES ('SV002', N'Trần Thị B', 2);
INSERT INTO SinhVien VALUES ('SV003', N'Lê Văn C', 3);
INSERT INTO SinhVien VALUES ('SV004', N'Phạm Thị D', 4);
INSERT INTO SinhVien VALUES ('SV005', N'Hoàng Văn E', 5);

INSERT INTO LopNangKhieu VALUES (1, '2012-08-01', 'GV1', 500000);
INSERT INTO LopNangKhieu VALUES (2, '2012-08-15', 'GV2', 600000);
INSERT INTO LopNangKhieu VALUES (3, '2012-09-01', 'GV3', 550000);
INSERT INTO LopNangKhieu VALUES (4, '2012-08-20', 'GV5', 700000);
INSERT INTO LopNangKhieu VALUES (5, '2012-07-01', 'GV5', 650000);

INSERT INTO BienLai VALUES (1, 8, 2012, 1, 'SV001', 500000);
INSERT INTO BienLai VALUES (2, 8, 2012, 2, 'SV002', 600000);
INSERT INTO BienLai VALUES (3, 9, 2012, 3, 'SV003', 550000);
INSERT INTO BienLai VALUES (4, 8, 2012, 4, 'SV004', 700000);
INSERT INTO BienLai VALUES (5, 9, 2012, 4, 'SV004', 700000);
INSERT INTO BienLai VALUES (6, 7, 2012, 5, 'SV005', 650000);
INSERT INTO BienLai VALUES (7, 8, 2012, 5, 'SV005', 650000);

GO

PRINT N'Hoàn thành setup database!';
