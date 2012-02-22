DECLARE @SONumber int
SELECT TOP 1 @SONumber=SONumber FROM (
SELECT DISTINCT n.SONumber
FROM dbo.tblSONotes AS n
WHERE n.Note LIKE '%Status changed from "New" to "Open"%') SON
ORDER BY NEWID()

BEGIN TRANSACTION 
-- SET @SONumber= 10015

SELECT TimeOpened FROM dbo.tblServiceOrders WHERE SONumber=@SONumber;
UPDATE dbo.tblServiceOrders 
SET [Status] = 'Customer Updated'
WHERE  SONumber = @SONumber;
SELECT TimeOpened FROM dbo.tblServiceOrders WHERE SONumber=@SONumber;

ROLLBACK