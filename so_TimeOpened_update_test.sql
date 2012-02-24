DECLARE @SONumber int;
DECLARE @OldestStartDateTime TABLE(
	SONumber int NOT NULL PRIMARY KEY,
	StartDateTime datetime NOT NULL);

INSERT INTO @OldestStartDateTime (SONumber, StartDateTime)
SELECT sol.SONumber,
	MIN( sol.StartDateTime) AS StartDateTime
FROM dbo.tblSOLogs AS sol 
GROUP BY sol.SONumber;
	
SELECT TOP 1 @SONumber=SONumber FROM @OldestStartDateTime
ORDER BY NEWID()

BEGIN TRANSACTION 
-- SET @SONumber= 10015

SELECT TimeOpened FROM dbo.tblServiceOrders WHERE SONumber=@SONumber;
UPDATE dbo.tblServiceOrders 
SET [Status] = 'Customer Updated'
WHERE  SONumber = @SONumber;
SELECT SONumber, TimeOpened FROM dbo.tblServiceOrders WHERE SONumber=@SONumber;
SELECT SONumber, StartDateTime FROM @OldestStartDateTime WHERE SONumber=@SONumber;

ROLLBACK