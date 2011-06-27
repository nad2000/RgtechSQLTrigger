USE [TigerpawDB]
GO

ALTER DATABASE TigerpawDB SET RECURSIVE_TRIGGERS OFF;
GO

EXEC sp_configure 'nested triggers','0'
RECONFIGURE
GO 
