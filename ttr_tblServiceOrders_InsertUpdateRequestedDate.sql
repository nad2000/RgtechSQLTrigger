
IF OBJECT_ID ('dbo.ttr_tblServiceOrders_InsertUpdateRequestedDate','TR') IS NOT NULL
   DROP TRIGGER dbo.ttr_tblServiceOrders_InsertUpdateRequestedDate;
GO

CREATE TRIGGER dbo.ttr_tblServiceOrders_InsertUpdateRequestedDate
ON dbo.tblServiceOrders
FOR INSERT, UPDATE
WITH APPEND 
AS
BEGIN
	IF ( @@ROWCOUNT < 1 ) RETURN
	IF ( SELECT COUNT(*) FROM inserted 
	     WHERE [Status] IN ('New', 'Open', 'Ready for Scheduling')
	           AND Priority <> 'No Priority - TBA' ) >= 1
	BEGIN 
	  DECLARE @requestedDate DATETIME
	  UPDATE dbo.tblServiceOrders
	  SET
		@requestedDate = dbo.tf_RequestedDate( 
			DateReceived,
			TimeReceived,
			Priority),
		DateRequested = CAST( @requestedDate AS DATE),
		TimeRequested = CAST( @requestedDate AS TIME)
	  WHERE [Status] IN ('New', 'Open', 'Ready for Scheduling')
	    AND Priority <> 'No Priority - TBA'
	    AND SONumber IN (SELECT SONumber FROM inserted)
	END

/*
Trigger based on ANY change to the SO 'Status'

Check for existance of Time Logs associated with the service order. (tblSOLogs)
If a Time Log exists, set open date & open time of SO to the same as the start date & start time of the oldest Time Log associated with that service order.

if no time log exists, do not alter open date.
*/

	DECLARE @OldestStartDateTime TABLE(
		SONumber int NOT NULL PRIMARY KEY,
		StartDateTime datetime NOT NULL);

	INSERT INTO @OldestStartDateTime (SONumber, StartDateTime) 
	-- oldest Time Log associated with that service order
	SELECT sol.SONumber, MIN( sol.StartDateTime) AS StartDateTime
	FROM dbo.tblSOLogs AS sol JOIN (
		-- SOs, which status has been changed:
		SELECT i.SONumber FROM inserted AS i JOIN deleted AS d 
			ON i.SONumber=d.SONumber
		WHERE ( i.[Status] <> d.[Status]
			    OR ( d.[Status] IS NULL AND i.[Status] IS NOT NULL))
	) AS cs ON cs.SONumber = sol.SONumber
	GROUP BY sol.SONumber;
	  
	UPDATE dbo.tblServiceOrders
	SET
		TimeOpened = sdt.StartDateTime,
		DateOpened = sdt.StartDateTime
	FROM dbo.tblServiceOrders AS so JOIN @OldestStartDateTime AS sdt
	  ON sdt.SONumber = so.SONumber;
	 
END

GO


