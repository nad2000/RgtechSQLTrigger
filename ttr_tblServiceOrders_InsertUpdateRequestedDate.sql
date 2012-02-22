
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
	It basically needs to occur on the UPDATE of tblServiceOrders where the tblServiceOrders.status is changed to "Customer Updated" 

	What it needs to do is look for the earliest SO Note (tblSONotes) assigned to this Service Order that has the following text: 'Status changed from "New" to "Open"' within the text of the Note. 

	It then needs to get the time from the timestamp of the note and update tblServiceOrders.timeopened with this time 	
*/
	  
	UPDATE dbo.tblServiceOrders
	SET TimeOpened = ISNULL(

		(SELECT TOP 1 n.DateCreated
		 FROM dbo.tblSONotes AS n
		 WHERE n.SONumber = dbo.tblServiceOrders.SONumber
		   AND n.Note LIKE '%Status changed from "New" to "Open"%'
		 ORDER BY n.DateCreated ASC),
		 
		 TimeOpened )
	
	WHERE SONumber IN (
	  -- SOs, which status changed to "Customer Updated"
	  SELECT i.SONumber FROM inserted AS i JOIN deleted AS d 
	    ON i.SONumber=d.SONumber
	  WHERE ( i.[Status] <> d.[Status] OR d.[Status] IS NULL )
	    AND i.[Status] = 'Customer Updated' )
	 
END

GO


