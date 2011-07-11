/*
Function returen invariant week day:

	Monday = 2
	Tuesday = 3
	Wednesday = 4
	.....
	Saturday = 7
	Sunday = 1
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.tf_WeekDay') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.tf_WeekDay
GO


CREATE FUNCTION dbo.tf_WeekDay(	@d DATETIME )
RETURNS INT
AS
BEGIN 
	RETURN (DATEPART( WEEKDAY, @d )+@@DATEFIRST) % 7
END