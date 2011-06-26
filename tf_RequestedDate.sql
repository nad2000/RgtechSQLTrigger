/*
Calculates Requested datetime on Received data, time, and priority
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.tf_RequestedDate') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.tf_RequestedDate
GO

CREATE FUNCTION dbo.tf_RequestedDate(
	@dateReceived DATE,
	@timeReceived TIME,
	@priority VARCHAR(50) )
RETURNS DATETIME
BEGIN
	DECLARE @datetimeReceived DATETIME = (CAST( @dateReceived AS DATETIME)+@timeReceived)
	DECLARE @resposeTime INT = 
		(SELECT TOP 1 ResponseTime FROM dbo.tblPriorities WHERE Priority=@priority);
	SET @resposeTime = ISNULL( @resposeTime, 0)
	RETURN dbo.tf_BusinessHoursAdd(
		@datetimeReceived,
		@resposeTime )
END
GO

/* Test:
DECLARE @d DATE = '2008-01-12'
DECLARE @t TIME = '11:23'

SELECT dbo.tf_RequestedDate( @d, @t, 'Within 24 Hours')
*/


