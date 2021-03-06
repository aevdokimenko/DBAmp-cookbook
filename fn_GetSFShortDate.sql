-- =============================================
-- Author:		Alex Evdokimenko
-- Create date: 2018-04-30 
-- Requested by: DBAmp cookbook users	
-- Description: Helper function to return date in Salesforce short date format
-- =============================================
Create FUNCTION [dbo].[fn_GetSFShortDate] (@d datetime )
RETURNS NVARCHAR(10)
AS
BEGIN
	RETURN cast(cast(@d as date) as nvarchar(10));
END
