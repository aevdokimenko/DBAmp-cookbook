-- ===============================================================
-- Author:		Alex Evdokimenko
-- Create date: 2018-05-15  
-- Requested by: DBAmp cookbook users	
-- Description: Helper function that safely returns 18 digit 
--				Salesforce IDs even for a 15 digit ones. 
--	Notes:		1) Original idea - I cannot find the original 
--				implementation of it, feel free to add a reference.
--				2) On SF side you don't need this, as CASESAFEID(id) will
--				provide conversion. 
-- ===============================================================
CREATE FUNCTION [dbo].[SalesforceId18] (@Id NCHAR(18))
RETURNS NCHAR(18) AS BEGIN

    DECLARE @code NCHAR(32) = N'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345' ;
    IF LEN(@Id) = 15
      SELECT @Id = LEFT(@Id, 15)
            + SUBSTRING(@code, 1 + SUM(CASE WHEN ASCII(SUBSTRING(@Id, pos, 1)) BETWEEN 65 AND 90 THEN val ELSE 0 END), 1)
            + SUBSTRING(@code, 1 + SUM(CASE WHEN ASCII(SUBSTRING(@Id, pos + 5, 1)) BETWEEN 65 AND 90 THEN val ELSE 0 END), 1)
            + SUBSTRING(@code, 1 + SUM(CASE WHEN ASCII(SUBSTRING(@Id, pos + 10, 1)) BETWEEN 65 AND 90 THEN val ELSE 0 END), 1)
      FROM (
         SELECT pos = 1, val = 1
         UNION ALL SELECT 2,2
         UNION ALL SELECT 3,4
         UNION ALL SELECT 4,8
         UNION ALL SELECT 5,16
      ) x ;   
   RETURN @Id ;
END