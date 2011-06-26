
IF OBJECT_ID ('dbo.ttr_tblServiceOrders_InsertUpdateRequestedDate','TR') IS NOT NULL
   DROP TRIGGER dbo.ttr_tblServiceOrders_InsertUpdateRequestedDate;
GO

CREATE TRIGGER dbo.ttr_tblServiceOrders_InsertUpdateRequestedDate
ON dbo.tblServiceOrders
FOR INSERT, UPDATE
WITH APPEND 
AS
BEGIN
	-- IF ( @@ROWCOUNT < 1 ) RETURN
	--IF ( SELECT COUNT(*) FROM inserted 
	--	 WHERE [Status] IN ('New', 'Open', 'Ready for Scheduling') ) < 1 RETURN
	DECLARE @requestedDate DATETIME
	UPDATE dbo.tblServiceOrders
	SET
		@requestedDate = dbo.fn_RequestedDate( 
			DateReceived,
			TimeReceived,
			Priority),
		DateRequested = CAST( @requestedDate AS DATE),
		TimeRequested = CAST( @requestedDate AS TIME)
	WHERE [Status] IN ('New', 'Open', 'Ready for Scheduling')
	AND SONumber IN (SELECT SONumber FROM inserted)
END

GO


