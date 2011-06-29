/*
Function adds business hours to a datatime value
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.tf_BusinessHoursAdd') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.tf_BusinessHoursAdd
GO


CREATE FUNCTION dbo.tf_BusinessHoursAdd
(
	@d DATETIME, -- variable to hold the date you want to add hours to
	@businessHours INT -- number of business hours to add
)
RETURNS DATETIME
AS
BEGIN
  DECLARE @bDayStart TIME = '8:30'
  DECLARE @bDayEnd TIME = '17:00'
  -- If received outside the business hours, take the next day beginnig instead
  IF CAST( @d AS TIME ) NOT BETWEEN @bDayStart AND @bDayEnd
  BEGIN
	SET @d = CAST( CAST( DATEADD( DAY, 1, @d) AS DATE ) AS DATETIME ) + @bDayStart
  END
  DECLARE @hoursInDay DECIMAL(3,1) = DATEDIFF( MINUTE, @bDayStart, @bDayEnd )/60. -- 8.5 
  DECLARE @t TIME = CAST( @d AS TIME)
  DECLARE @bDays INT = CAST( @businessHours / @hoursInDay AS INT)
  -- reste of minutes to add to the time
  DECLARE @bMinutes INT = ( @businessHours - ( @bDays * @hoursInDay ) ) * 60
  DECLARE @resultTime TIME = DATEADD( MINUTE, @bMinutes, @t )
  IF @resultTime > @bDayEnd -- pushing it to the next business day
  BEGIN
    SET @bDays = @bDays + 1
    SET @resultTime = DATEADD( MINUTE, DATEDIFF( MINUTE, @bDayEnd, @resultTime), @bDayStart)
  END
  ELSE IF @resultTime < @bDayStart
  BEGIN
    SET @bDays = @bDays + 1
    SET @resultTime = DATEADD( MINUTE, @bMinutes-DATEDIFF( MINUTE, @t, @bDayEnd), @bDayStart)
  END
  
  -- Declare the return variable here
  DECLARE @nDate DATETIME
  SET @nDate = CAST( @d AS DATE)
  WHILE @bDays <> 0 -- Keep adding/subtracting a day until @bdays becomes 0
    BEGIN
      SET @nDate = DATEADD( DAY, 1, @nDate)
      -- ignore if it is Sunday or Sat
      IF DATEPART( WEEKDAY, @nDate) NOT IN ( 1, 7)
		SET @bDays = @bDays - 1
    END
  IF DATEPART( WEEKDAY, @nDate) = 7 SET @nDate = DATEADD( DAY, 1, @nDate)
  IF DATEPART( WEEKDAY, @nDate) = 1 SET @nDate = DATEADD( DAY, 1, @nDate)
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
IF dbo.tf_BusinessHoursAdd( '2011-06-24 16:30', 8)='2011-06-27 16:00' 
PRINT 'PASS'
IF dbo.tf_BusinessHoursAdd( '2011-06-23 16:30', 8)='2011-06-24 16:00' 
PRINT 'PASS'
IF dbo.tf_BusinessHoursAdd( '2011-06-23 10:30', 9)='2011-06-24 11:00' 
PRINT 'PASS'
*/
