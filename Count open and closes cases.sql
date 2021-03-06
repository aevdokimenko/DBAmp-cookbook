USE [SFDC]
GO
-- =============================================
-- Author:		Alex Evdokimenko
-- Create date: 2018-04-30 
-- Requested by: DBAmp cookbook users	
-- Description: Calculates counts of open/closed and update Statistics__c table.
-- Notes:		You need to have Statistics__c custom object set up
--				in your org, local tables statistics__c_insert, statistics__c_delete
--				defined.
--				It's safe to run the procedure more than once during reporting week.
-- =============================================
create proc [maintenance].[Count opened and closed cases] 
as
begin
	declare @dateTo date, @dateFrom date, @O nvarchar(255), @C nvarchar(255);
	declare @dateToReport varchar(255), @sql nvarchar(4000)

	select 
		@O = '[Cases]: Opened weekly', 
		@C = '[Cases]: Closed weekly'

	truncate table statistics__c_insert;
	truncate table statistics__c_delete;

	Select @dateTo = dateadd(wk, 1, getutcdate());

	-- In case we run this function not on Sunday, get Sunday.
	select @dateTo = dateadd(d, 1-datepart (dw, @dateTo), @dateTo); 
	select @dateFrom = dateadd(wk, -1, @dateTo);
	-- Last day of the previous period
	select @dateToReport = [dbo].[fn_GetSFShortDate] (dateadd(d, -1, @dateTo))
	
	print @dateTo
	print @dateFrom
	print @dateToReport

	-- Clear all entries for selected date
	select @sql = 'insert statistics__c_delete(id)
	select id 
	from openquery(salesforce, ''select id
	from statistics__c
	where date__c = ' + @dateToReport + ' and (
		type__c = ''''' + @O + '''''
		or 	type__c = ''''' + @C + ''''')'')';

	exec sp_executesql @sql

	-- Calculate Open cases
	insert Statistics__c_insert (type__c, date__c, value__c)
	select @O, @dateToReport, count(*)
	from salesforce...[case]
	where 
	CreatedDate between @dateFrom and @dateTo
	and isdeleted = 'false'
	and [status] not in ('Junk','Testing','Merged')
	-- include any other logic here to filter out cases, that should be excluded;

	-- Calculate Closed cases
	insert Statistics__c_insert (type__c, date__c, value__c)
	select @C, @dateToReport, count(*)
	from salesforce...[case]
	where 
	ClosedDate between @dateFrom and @dateTo
	and isdeleted = 'false'
	and [status] not in ('Junk','Testing','Merged');
	-- include any other logic here to filter out cases, that should be excluded;


	exec sf_bulkops 'delete', salesforce, 'statistics__c_delete';
	exec sf_bulkops 'insert', salesforce, 'statistics__c_insert';
end