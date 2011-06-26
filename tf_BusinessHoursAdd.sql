/*
Function adds business hours to a datatime value
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.tf_BusinessHoursAdd') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.tf_BusinessHoursAdd
GO


CREATE FUNCTION dbo.tf_BusinessHoursAdd
(
	@d DATETIME, -- variable to hold the date you want to add sub. days to
	@businessHours INT -- number of business hours to add
)
RETURNS DATETIME
AS
BEGIN
  DECLARE @bDayStart TIME = '8:30'
  DECLARE @bDayEnd TIME = '17:00'
  DECLARE @hoursInDay DECIMAL(3,1) = DATEDIFF( MINUTE, @bDayStart, @bDayEnd )/60. -- 8.5 
  DECLARE @bDays INT = CAST( @businessHours / @hoursInDay AS INT)
  -- reste of minutes
  DECLARE @bMinutes INT = ( @businessHours - ( @bDays * @hoursInDay ) ) * 60
  DECLARE @resultTime TIME = DATEADD( MINUTE, @bMinutes, CAST( @d AS TIME) )
  IF @resultTime > @bDayEnd -- pushing it to the next business day
  BEGIN
    SET @bDays = @bDays + 1
    SET @resultTime = DATEADD( MINUTE, DATEDIFF( MINUTE, @bDayEnd, @resultTime), @bDayStart)
  END
  
  -- Declare the return variable here
  DECLARE @nDate DATETIME
  SET @nDate = CAST( @d AS DATE)
  WHILE @bDays <> 0 -- Keep adding/subtracting a day until @bdays becomes 0
    BEGIN
      SET @nDate = DATEADD( DAY, 1, @nDate)
      -- ignore if it is Sat or Sunday
      IF DATEPART( WEEKDAY, @nDate) NOT IN ( 1, 7)
		SET @bDays = @bDays - 1
    END
  RETURN ( @nDate+@resultTime )
END
GO


/* 
-- Unit tests:
IF dbo.tf_BusinessHoursAdd( '2011-01-03 9:00', 10)='2011-01-04 10:30' 
PRINT 'PASS'
IF dbo.tf_BusinessHoursAdd( '2011-06-24 9:00', 60)='2011-07-05 09:30'
PRINT 'PASS'
IF dbo.tf_BusinessHoursAdd( '2011-06-24 9:00', 10)='2011-06-27 10:30'
PRINT 'PASS'
*/
