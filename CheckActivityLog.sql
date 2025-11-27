-- Kiểm tra bảng ActivityLog có tồn tại không
USE ClubManagementGlobal;
GO

PRINT '=== KIỂM TRA BẢNG ACTIVITYLOG ===';
PRINT '';

-- Kiểm tra bảng tại SiteA
PRINT 'Kiểm tra SiteA:';
IF EXISTS (SELECT * FROM SiteA.sys.tables WHERE name = 'ActivityLog')
BEGIN
    PRINT '  ✓ Bảng ActivityLog tồn tại tại SiteA';
    DECLARE @CountA INT;
    SELECT @CountA = COUNT(*) FROM SiteA.dbo.ActivityLog;
    PRINT '  Số bản ghi: ' + CAST(@CountA AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '  ✗ Bảng ActivityLog KHÔNG tồn tại tại SiteA';
END
PRINT '';

-- Kiểm tra bảng tại SiteB
PRINT 'Kiểm tra SiteB:';
IF EXISTS (SELECT * FROM SiteB.sys.tables WHERE name = 'ActivityLog')
BEGIN
    PRINT '  ✓ Bảng ActivityLog tồn tại tại SiteB';
    DECLARE @CountB INT;
    SELECT @CountB = COUNT(*) FROM SiteB.dbo.ActivityLog;
    PRINT '  Số bản ghi: ' + CAST(@CountB AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '  ✗ Bảng ActivityLog KHÔNG tồn tại tại SiteB';
END
PRINT '';

-- Kiểm tra view
PRINT 'Kiểm tra View:';
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActivityLog')
BEGIN
    PRINT '  ✓ View vw_ActivityLog tồn tại';
    DECLARE @CountView INT;
    SELECT @CountView = COUNT(*) FROM vw_ActivityLog;
    PRINT '  Tổng số bản ghi: ' + CAST(@CountView AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '  ✗ View vw_ActivityLog KHÔNG tồn tại';
END
PRINT '';

-- Kiểm tra trigger
PRINT 'Kiểm tra Triggers tại SiteA:';
SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName
FROM SiteA.sys.triggers t
WHERE t.name LIKE 'trg_Log%'
ORDER BY t.name;

PRINT '';
PRINT 'Kiểm tra Triggers tại SiteB:';
SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName
FROM SiteB.sys.triggers t
WHERE t.name LIKE 'trg_Log%'
ORDER BY t.name;

PRINT '';
PRINT '=== XEM DỮ LIỆU LOG (10 BẢN GHI GẦN NHẤT) ===';
SELECT TOP 10 * FROM vw_ActivityLog ORDER BY Timestamp DESC;
