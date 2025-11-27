-- =============================================
-- THÊM MODULE THỐNG KÊ LOG
-- Tạo bảng ActivityLog để ghi nhận các hoạt động trong hệ thống
-- =============================================

USE ClubManagementGlobal;
GO

-- =============================================
-- TẠO BẢNG ACTIVITYLOG TẠI SITE A VÀ SITE B
-- =============================================

USE SiteA;
GO

IF OBJECT_ID('ActivityLog', 'U') IS NOT NULL DROP TABLE ActivityLog;
GO

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

CREATE INDEX IX_ActivityLog_Timestamp ON ActivityLog(Timestamp DESC);
CREATE INDEX IX_ActivityLog_Action ON ActivityLog(Action);
CREATE INDEX IX_ActivityLog_TableName ON ActivityLog(TableName);
GO

USE SiteB;
GO

IF OBJECT_ID('ActivityLog', 'U') IS NOT NULL DROP TABLE ActivityLog;
GO

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

CREATE INDEX IX_ActivityLog_Timestamp ON ActivityLog(Timestamp DESC);
CREATE INDEX IX_ActivityLog_Action ON ActivityLog(Action);
CREATE INDEX IX_ActivityLog_TableName ON ActivityLog(TableName);
GO

-- =============================================
-- TẠO VIEW TOÀN CỤC CHO ACTIVITYLOG
-- =============================================

USE ClubManagementGlobal;
GO

IF OBJECT_ID('vw_ActivityLog', 'V') IS NOT NULL DROP VIEW vw_ActivityLog;
GO

CREATE VIEW vw_ActivityLog AS
SELECT * FROM SiteA.dbo.ActivityLog
UNION ALL
SELECT * FROM SiteB.dbo.ActivityLog;
GO

-- =============================================
-- TRIGGER GHI LOG CHO CauLacBo
-- =============================================

USE SiteA;
GO

IF OBJECT_ID('trg_Log_Insert_CauLacBo_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_CauLacBo_SiteA;
GO
CREATE TRIGGER trg_Log_Insert_CauLacBo_SiteA ON CauLacBo AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'CauLacBo', CAST(i.MaCLB AS NVARCHAR(50)), 'SiteA', 
           N'Thêm CLB: ' + i.TenCLB + N' (Khoa: ' + i.TenKhoa + N')'
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_CauLacBo_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_CauLacBo_SiteA;
GO
CREATE TRIGGER trg_Log_Update_CauLacBo_SiteA ON CauLacBo AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'CauLacBo', CAST(i.MaCLB AS NVARCHAR(50)), 'SiteA', 
           N'Cập nhật CLB: ' + i.TenCLB
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_CauLacBo_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_CauLacBo_SiteA;
GO
CREATE TRIGGER trg_Log_Delete_CauLacBo_SiteA ON CauLacBo AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'CauLacBo', CAST(d.MaCLB AS NVARCHAR(50)), 'SiteA', 
           N'Xóa CLB: ' + d.TenCLB
    FROM deleted d;
END;
GO

USE SiteB;
GO

IF OBJECT_ID('trg_Log_Insert_CauLacBo_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_CauLacBo_SiteB;
GO
CREATE TRIGGER trg_Log_Insert_CauLacBo_SiteB ON CauLacBo AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'CauLacBo', CAST(i.MaCLB AS NVARCHAR(50)), 'SiteB', 
           N'Thêm CLB: ' + i.TenCLB + N' (Khoa: ' + i.TenKhoa + N')'
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_CauLacBo_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_CauLacBo_SiteB;
GO
CREATE TRIGGER trg_Log_Update_CauLacBo_SiteB ON CauLacBo AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'CauLacBo', CAST(i.MaCLB AS NVARCHAR(50)), 'SiteB', 
           N'Cập nhật CLB: ' + i.TenCLB
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_CauLacBo_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_CauLacBo_SiteB;
GO
CREATE TRIGGER trg_Log_Delete_CauLacBo_SiteB ON CauLacBo AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'CauLacBo', CAST(d.MaCLB AS NVARCHAR(50)), 'SiteB', 
           N'Xóa CLB: ' + d.TenCLB
    FROM deleted d;
END;
GO

USE ClubManagementGlobal;
GO

-- =============================================
-- TRIGGER GHI LOG CHO GiangVien
-- =============================================

USE SiteA;
GO

IF OBJECT_ID('trg_Log_Insert_GiangVien_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_GiangVien_SiteA;
GO
CREATE TRIGGER trg_Log_Insert_GiangVien_SiteA ON GiangVien AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'GiangVien', i.MaGV, 'SiteA', N'Thêm GV: ' + i.HoTenGV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_GiangVien_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_GiangVien_SiteA;
GO
CREATE TRIGGER trg_Log_Update_GiangVien_SiteA ON GiangVien AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'GiangVien', i.MaGV, 'SiteA', N'Cập nhật GV: ' + i.HoTenGV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_GiangVien_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_GiangVien_SiteA;
GO
CREATE TRIGGER trg_Log_Delete_GiangVien_SiteA ON GiangVien AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'GiangVien', d.MaGV, 'SiteA', N'Xóa GV: ' + d.HoTenGV
    FROM deleted d;
END;
GO

USE SiteB;
GO

IF OBJECT_ID('trg_Log_Insert_GiangVien_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_GiangVien_SiteB;
GO
CREATE TRIGGER trg_Log_Insert_GiangVien_SiteB ON GiangVien AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'GiangVien', i.MaGV, 'SiteB', N'Thêm GV: ' + i.HoTenGV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_GiangVien_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_GiangVien_SiteB;
GO
CREATE TRIGGER trg_Log_Update_GiangVien_SiteB ON GiangVien AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'GiangVien', i.MaGV, 'SiteB', N'Cập nhật GV: ' + i.HoTenGV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_GiangVien_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_GiangVien_SiteB;
GO
CREATE TRIGGER trg_Log_Delete_GiangVien_SiteB ON GiangVien AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'GiangVien', d.MaGV, 'SiteB', N'Xóa GV: ' + d.HoTenGV
    FROM deleted d;
END;
GO

USE ClubManagementGlobal;
GO

-- =============================================
-- TRIGGER GHI LOG CHO SinhVien
-- =============================================

USE SiteA;
GO

IF OBJECT_ID('trg_Log_Insert_SinhVien_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_SinhVien_SiteA;
GO
CREATE TRIGGER trg_Log_Insert_SinhVien_SiteA ON SinhVien AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'SinhVien', i.MaSV, 'SiteA', N'Thêm SV: ' + i.HoTenSV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_SinhVien_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_SinhVien_SiteA;
GO
CREATE TRIGGER trg_Log_Update_SinhVien_SiteA ON SinhVien AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'SinhVien', i.MaSV, 'SiteA', N'Cập nhật SV: ' + i.HoTenSV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_SinhVien_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_SinhVien_SiteA;
GO
CREATE TRIGGER trg_Log_Delete_SinhVien_SiteA ON SinhVien AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'SinhVien', d.MaSV, 'SiteA', N'Xóa SV: ' + d.HoTenSV
    FROM deleted d;
END;
GO

USE SiteB;
GO

IF OBJECT_ID('trg_Log_Insert_SinhVien_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_SinhVien_SiteB;
GO
CREATE TRIGGER trg_Log_Insert_SinhVien_SiteB ON SinhVien AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'SinhVien', i.MaSV, 'SiteB', N'Thêm SV: ' + i.HoTenSV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_SinhVien_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_SinhVien_SiteB;
GO
CREATE TRIGGER trg_Log_Update_SinhVien_SiteB ON SinhVien AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'SinhVien', i.MaSV, 'SiteB', N'Cập nhật SV: ' + i.HoTenSV
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_SinhVien_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_SinhVien_SiteB;
GO
CREATE TRIGGER trg_Log_Delete_SinhVien_SiteB ON SinhVien AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'SinhVien', d.MaSV, 'SiteB', N'Xóa SV: ' + d.HoTenSV
    FROM deleted d;
END;
GO

USE ClubManagementGlobal;
GO

-- =============================================
-- TRIGGER GHI LOG CHO LopNangKhieu
-- =============================================

USE SiteA;
GO

IF OBJECT_ID('trg_Log_Insert_LopNangKhieu_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_LopNangKhieu_SiteA;
GO
CREATE TRIGGER trg_Log_Insert_LopNangKhieu_SiteA ON LopNangKhieu AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'LopNangKhieu', CAST(i.MaLop AS NVARCHAR(50)), 'SiteA', N'Thêm lớp: ' + CAST(i.MaLop AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_LopNangKhieu_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_LopNangKhieu_SiteA;
GO
CREATE TRIGGER trg_Log_Update_LopNangKhieu_SiteA ON LopNangKhieu AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'LopNangKhieu', CAST(i.MaLop AS NVARCHAR(50)), 'SiteA', N'Cập nhật lớp: ' + CAST(i.MaLop AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_LopNangKhieu_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_LopNangKhieu_SiteA;
GO
CREATE TRIGGER trg_Log_Delete_LopNangKhieu_SiteA ON LopNangKhieu AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'LopNangKhieu', CAST(d.MaLop AS NVARCHAR(50)), 'SiteA', N'Xóa lớp: ' + CAST(d.MaLop AS NVARCHAR(50))
    FROM deleted d;
END;
GO

USE SiteB;
GO

IF OBJECT_ID('trg_Log_Insert_LopNangKhieu_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_LopNangKhieu_SiteB;
GO
CREATE TRIGGER trg_Log_Insert_LopNangKhieu_SiteB ON LopNangKhieu AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'LopNangKhieu', CAST(i.MaLop AS NVARCHAR(50)), 'SiteB', N'Thêm lớp: ' + CAST(i.MaLop AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_LopNangKhieu_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_LopNangKhieu_SiteB;
GO
CREATE TRIGGER trg_Log_Update_LopNangKhieu_SiteB ON LopNangKhieu AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'LopNangKhieu', CAST(i.MaLop AS NVARCHAR(50)), 'SiteB', N'Cập nhật lớp: ' + CAST(i.MaLop AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_LopNangKhieu_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_LopNangKhieu_SiteB;
GO
CREATE TRIGGER trg_Log_Delete_LopNangKhieu_SiteB ON LopNangKhieu AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'LopNangKhieu', CAST(d.MaLop AS NVARCHAR(50)), 'SiteB', N'Xóa lớp: ' + CAST(d.MaLop AS NVARCHAR(50))
    FROM deleted d;
END;
GO

USE ClubManagementGlobal;
GO

-- =============================================
-- TRIGGER GHI LOG CHO BienLai
-- =============================================

USE SiteA;
GO

IF OBJECT_ID('trg_Log_Insert_BienLai_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_BienLai_SiteA;
GO
CREATE TRIGGER trg_Log_Insert_BienLai_SiteA ON BienLai AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'BienLai', CAST(i.SoBL AS NVARCHAR(50)), 'SiteA', N'Thêm biên lai: ' + CAST(i.SoBL AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_BienLai_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_BienLai_SiteA;
GO
CREATE TRIGGER trg_Log_Update_BienLai_SiteA ON BienLai AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'BienLai', CAST(i.SoBL AS NVARCHAR(50)), 'SiteA', N'Cập nhật biên lai: ' + CAST(i.SoBL AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_BienLai_SiteA', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_BienLai_SiteA;
GO
CREATE TRIGGER trg_Log_Delete_BienLai_SiteA ON BienLai AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'BienLai', CAST(d.SoBL AS NVARCHAR(50)), 'SiteA', N'Xóa biên lai: ' + CAST(d.SoBL AS NVARCHAR(50))
    FROM deleted d;
END;
GO

USE SiteB;
GO

IF OBJECT_ID('trg_Log_Insert_BienLai_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Insert_BienLai_SiteB;
GO
CREATE TRIGGER trg_Log_Insert_BienLai_SiteB ON BienLai AFTER INSERT
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'INSERT', 'BienLai', CAST(i.SoBL AS NVARCHAR(50)), 'SiteB', N'Thêm biên lai: ' + CAST(i.SoBL AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Update_BienLai_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Update_BienLai_SiteB;
GO
CREATE TRIGGER trg_Log_Update_BienLai_SiteB ON BienLai AFTER UPDATE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'UPDATE', 'BienLai', CAST(i.SoBL AS NVARCHAR(50)), 'SiteB', N'Cập nhật biên lai: ' + CAST(i.SoBL AS NVARCHAR(50))
    FROM inserted i;
END;
GO

IF OBJECT_ID('trg_Log_Delete_BienLai_SiteB', 'TR') IS NOT NULL DROP TRIGGER trg_Log_Delete_BienLai_SiteB;
GO
CREATE TRIGGER trg_Log_Delete_BienLai_SiteB ON BienLai AFTER DELETE
AS
BEGIN
    INSERT INTO ActivityLog (Action, TableName, RecordId, Site, Details)
    SELECT 'DELETE', 'BienLai', CAST(d.SoBL AS NVARCHAR(50)), 'SiteB', N'Xóa biên lai: ' + CAST(d.SoBL AS NVARCHAR(50))
    FROM deleted d;
END;
GO

USE ClubManagementGlobal;
GO

PRINT N'========================================';
PRINT N'Hoàn thành cài đặt module thống kê log!';
PRINT N'- Bảng ActivityLog đã được tạo tại SiteA và SiteB';
PRINT N'- View vw_ActivityLog đã được tạo';
PRINT N'- Các trigger ghi log đã được tạo cho tất cả bảng';
PRINT N'========================================';
