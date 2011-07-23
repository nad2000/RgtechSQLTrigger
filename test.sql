
SELECT [SONumber]
      ,[BriefDescription]
      ,[AccountNumber]
      ,[AccountPhone]
      ,[ContactNumber]
      ,[ContactPhone]
      ,[DateReceived]
      ,[TimeReceived]
      ,[DateRequested]
      ,[TimeRequested]
      ,Status
	,Priority
  FROM [TigerpawDB].[dbo].[tblServiceOrders]
  WHERE SONumber IN (  10015, 10017)
GO  
update [tblServiceOrders]
set [TimeReceived] = 
CASE [TimeReceived]
WHEN '15:30' THEN '15:10'
ELSE '15:30'
END
where SONumber = 10015
update [tblServiceOrders]
set [TimeReceived] = 
CASE [TimeReceived]
WHEN '14:30' THEN '14:10'
ELSE '14:30'
END
where SONumber = 10017
SELECT [SONumber]
      ,[BriefDescription]
      ,[AccountNumber]
      ,[AccountPhone]
      ,[ContactNumber]
      ,[ContactPhone]
      ,[DateReceived]
      ,[TimeReceived]
      ,[DateRequested]
      ,[TimeRequested]
      ,Status
	,Priority
  FROM [TigerpawDB].[dbo].[tblServiceOrders]
  WHERE SONumber IN (  10015, 10017)
GO  

-- tf_BusinessHoursAdd UDF unit tests:
IF dbo.tf_BusinessHoursAdd( '2011-01-03 9:00', 10)='2011-01-04 10:30' 
PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_BusinessHoursAdd( '2011-06-24 9:00', 60)='2011-07-05 09:30'
PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_BusinessHoursAdd( '2011-06-24 9:00', 10)='2011-06-27 10:30'
PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_BusinessHoursAdd( '2011-06-24 16:30', 8)='2011-06-27 16:00' 
PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_BusinessHoursAdd( '2011-06-23 16:30', 8)='2011-06-24 16:00' 
PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_BusinessHoursAdd( '2011-06-23 10:30', 9)='2011-06-24 11:00' 
PRINT 'PASS' ELSE PRINT 'FAILED'

-- tf_RequestedDate UDF unit tests:
IF dbo.tf_RequestedDate(
	'2011-06-29',
	'18:00',
	'CRITICAL - Within an Hour' )='2011-06-30 09:30'
PRINT 'PASS' ELSE PRINT 'FAILED'

IF dbo.tf_RequestedDate(
	'2011-06-24',
	'18:00',
	'CRITICAL - Within an Hour' )='2011-06-27 09:30'
PRINT 'PASS' ELSE PRINT 'FAILED'

-- SELECT dbo.tf_RequestedDate( '2011-07-04', '11:55', 'Urgent - Within 3 hours' )
IF dbo.tf_RequestedDate( '2011-07-04', '11:55', 'Urgent - Within 3 hours')
		= '2011-07-04 14:55'
PRINT 'PASS' ELSE PRINT 'FAILED'

-- SELECT dbo.tf_RequestedDate( '2011-07-04', '11:26', 'CRITICAL - Within an Hour' )
IF dbo.tf_RequestedDate('2011-07-04', '11:26', 'CRITICAL - Within an Hour' )
		= '2011-07-04 12:26'
PRINT 'PASS' ELSE PRINT 'FAILED'

--SELECT dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
-- SELECT (DATEPART( WEEKDAY, GETDATE())+@@DATEFIRST) % 7, GETDATE(), @@DATEFIRST
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'

DECLARE @fd INT = @@DATEFIRST
SET DATEFIRST 1
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'
SET DATEFIRST 2
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'
SET DATEFIRST 3
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'
SET DATEFIRST 4
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'
SET DATEFIRST 5
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'
SET DATEFIRST 6
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'
SET DATEFIRST 7
IF dbo.tf_RequestedDate( '2011-07-11', '10:41', 'Urgent - Within 3 hours' )
		= '2011-07-11 13:41'
PRINT 'PASS' ELSE PRINT 'FAILED'

SET DATEFIRST @fd

-- SELECT dbo.tf_RequestedDate( '2011-07-22', '10:24', 'Priority - 24 Hours' )
IF dbo.tf_RequestedDate( '2011-07-22', '10:24', 'Within 24 Hours' ) = '2011-07-25 09:54'
PRINT 'PASS' ELSE PRINT 'FAILED'

PRINT 'dbo.tf_WeekDay Unit Tests:'
IF dbo.tf_WeekDay( '2011-07-22' ) = 6 PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_WeekDay( '2011-07-23' ) = 0 PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_WeekDay( '2011-07-24' ) = 1 PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_WeekDay( '2011-07-25' ) = 2 PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_WeekDay( '2011-07-26' ) = 3 PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_WeekDay( '2011-07-27' ) = 4 PRINT 'PASS' ELSE PRINT 'FAILED'
IF dbo.tf_WeekDay( '2011-07-28' ) = 5 PRINT 'PASS' ELSE PRINT 'FAILED'
