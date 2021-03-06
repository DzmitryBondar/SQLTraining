/*****************************************************************
******************************************************************
*						The Second task	(part 2)				 *
******************************************************************
******************************************************************/

use Training
go

drop table #tempSource
go
create table #tempSource (EMP_ID int, MANAGER_ID int, JOB_ID varchar(10), DEP varchar(50), COUNTRY varchar(50), VER int, DEP_ID int) 
go

IF OBJECT_ID('TempReportTable', 'P') IS NULL
BEGIN
	drop function TempReportTable
END
go

CREATE FUNCTION TempReportTable(@beforeDate datetime)
RETURNS @res TABLE(EMP_ID int, MANAGER_ID int, JOB_ID varchar(10), DEP varchar(50), COUNTRY varchar(50), VER int, DEP_ID int) 
AS
begin
	insert into @res(EMP_ID, VER)
		select EMPLOYEE_ID, MAX(HE.CURRENT_VERSION)
		from HISTORY_EMPLOYEES as HE
		where HE.DATE_END >= @beforeDate
		group by EMPLOYEE_ID
	update @res set
		MANAGER_ID = (select TOP 1 MANAGER_ID from HISTORY_EMPLOYEES as HE where EMPLOYEE_ID = EMP_ID and CURRENT_VERSION = VER),
		JOB_ID = (select TOP 1 JOB_ID from HISTORY_EMPLOYEES as HE where EMPLOYEE_ID = EMP_ID and CURRENT_VERSION = VER),
		DEP_ID = (select TOP 1 DEPARTMENT_ID from HISTORY_EMPLOYEES as HE where EMPLOYEE_ID = EMP_ID and CURRENT_VERSION = VER)
	update @res set
		DEP = (select DEPARTMENT_NAME from DEPARTMENTS where DEPARTMENT_ID = DEP_ID),
		COUNTRY = (select TOP 1 COUNTRY_NAME from COUNTRIES as C, DEPARTMENTS as D where C.COUNTRY_ID = D.COUNTRY_ID and D.DEPARTMENT_ID = DEP_ID)
	RETURN 
end
go

insert into #tempSource select * from TempReportTable('01/01/2012')

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TEST]'))
BEGIN
	DROP TABLE TEST	
END

drop table #temp
go

create table TEST (
  ID   int,
  NPARENT_ID int,
  CTITLE varchar(50),
  Level int,
  DEP varchar(50),
  COUNTRY varchar(50)  
)

create table #temp (
	COUNTRY varchar(50),
	DEP varchar(50),
	id int, 
	idParent int
)
go

WITH ORGTREE (ID, NPARENT_ID, CTITLE, Level, DEP, COUNTRY)
AS
(
    SELECT EMP_ID, MANAGER_ID, JOB_ID, 0 AS Level, DEP, COUNTRY
    FROM #tempSource
    WHERE MANAGER_ID IS NULL
    UNION ALL    
    SELECT t.EMP_ID, t.MANAGER_ID, t.JOB_ID, Level + 1, t.DEP, t.COUNTRY
    FROM #tempSource AS t
    INNER JOIN ORGTREE AS o ON o.ID = t.MANAGER_ID
)

insert into dbo.TEST(ID, NPARENT_ID, CTITLE, Level, DEP, COUNTRY) SELECT ID, NPARENT_ID, CTITLE, Level, DEP, COUNTRY FROM ORGTREE order by Level, ID, NPARENT_ID;
insert into #temp select COUNTRY, DEP, ID, NPARENT_ID from TEST where Level = 0


declare @sql varchar(2000), @count int, @step int, @delim varchar(2)
select @count = MAX(Level) + 1 from TEST
set @step = 1
set @sql = 'select T1.COUNTRY, T1.DEP, '
set @delim = ', '

while @step <= @count
begin
	if (@step = @count) set @delim = ' '
	set @sql = @sql + 'T' + cast(@step as varchar(3)) + '.id as ID' + cast(@step as varchar(3)) + @delim
	set @step = @step + 1
end

set @sql = @sql + 'from #temp as T1 '
set @step = 1

while @step <= @count
begin
	set @sql = @sql + 'left join TEST as T' + cast((@step + 1) as varchar(3)) + ' on T' + cast((@step + 1) as varchar(3)) + '.NPARENT_ID = T' + cast(@step as varchar(3)) + '.id' + @delim
	set @step = @step + 1
end

set @sql = @sql + ' order by T1.id'

/*****************************************************************
* Show report													 *
******************************************************************/

exec(@sql)
go