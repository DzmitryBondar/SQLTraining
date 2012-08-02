use Training
go

/*****************************************************************
******************************************************************
*						The First task							 *
******************************************************************
******************************************************************/

/*****************************************************************
* Drop constraints and tables									 *
******************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[JOBS]'))
BEGIN
	alter table JOBS drop constraint JOB_TITLE_NN
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DEPARTMENTS]'))
BEGIN
	alter table DEPARTMENTS drop constraint DEPT_NAME_NN
	alter table DEPARTMENTS drop constraint DEPT_MGR_FK
	alter table DEPARTMENTS drop constraint EMP_COUNTRY_FK 
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[EMPLOYEES]'))
BEGIN
	alter table EMPLOYEES drop constraint EMP_EMAIL_UK
	alter table EMPLOYEES drop constraint EMP_DEPT_FK
	alter table EMPLOYEES drop constraint EMP_JOB_FK
	alter table EMPLOYEES drop constraint EMP_EMAIL_NN
	alter table EMPLOYEES drop constraint EMP_HIRE_DATE_NN
	alter table EMPLOYEES drop constraint EMP_JOB_NN
	alter table EMPLOYEES drop constraint EMP_LAST_NAME_NN
	alter table EMPLOYEES drop constraint EMP_SALARY_MIN
--	alter table EMPLOYEES drop constraint EMP_MANAGER_FK
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[JOB_HISTORY]'))
BEGIN
	alter table JOB_HISTORY drop constraint JHIST_DEPT_FK
	alter table JOB_HISTORY drop constraint JHIST_EMP_FK
	alter table JOB_HISTORY drop constraint JHIST_JOB_FK
	alter table JOB_HISTORY drop constraint JHIST_DATE_INTERVAL
	alter table JOB_HISTORY drop constraint JHIST_EMPLOYEE_NN
	alter table JOB_HISTORY drop constraint JHIST_END_DATE_NN
	alter table JOB_HISTORY drop constraint JHIST_JOB_NN
	alter table JOB_HISTORY drop constraint JHIST_START_DATE_NN	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[COUNTRIES]'))
BEGIN
	DROP TABLE COUNTRIES	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[JOBS]'))
BEGIN
	DROP TABLE JOBS	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DEPARTMENTS]'))
BEGIN
	DROP TABLE DEPARTMENTS	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[EMPLOYEES]'))
BEGIN
	DROP TABLE EMPLOYEES	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[JOB_HISTORY]'))
BEGIN
	DROP TABLE JOB_HISTORY	
END
go

/*****************************************************************
* Create tables													 *
******************************************************************/

create table COUNTRIES (
  COUNTRY_ID   CHAR(2) primary key,
  COUNTRY_NAME VARCHAR(100)
)
go

create table JOBS (
  JOB_ID     VARCHAR(10) primary key,
  JOB_TITLE  VARCHAR(35),
  MIN_SALARY int,
  MAX_SALARY int  
)
go

create table DEPARTMENTS (
  DEPARTMENT_ID   int identity primary key,
  DEPARTMENT_NAME VARCHAR(30),
  MANAGER_ID      int,
  COUNTRY_ID   CHAR(2)
)
go

create table EMPLOYEES (
  EMPLOYEE_ID    int identity primary key,
  FIRST_NAME     VARCHAR(100),
  LAST_NAME      VARCHAR(100),
  EMAIL          VARCHAR(100),
  PHONE_NUMBER   VARCHAR(100),
  HIRE_DATE      DATETIME,
  JOB_ID         VARCHAR(10),
  SALARY         NUMERIC(8,2),
  COMMISSION_PCT NUMERIC(2,2),
  MANAGER_ID     int,
  DEPARTMENT_ID  int
)
go

create table JOB_HISTORY (
  EMPLOYEE_ID   int,
  START_DATE    DATETIME,
  END_DATE      DATETIME,
  JOB_ID        VARCHAR(10),
  DEPARTMENT_ID int,
  constraint JHIST_EMP_ID_ST_DATE_PK primary key (EMPLOYEE_ID, START_DATE)
)
go

/*****************************************************************
* Create constraints and indexes								 *
******************************************************************/

alter table COUNTRIES 
add constraint COUNTRY_ID_NN check ("COUNTRY_ID" IS NOT NULL)

alter table JOBS 
add constraint JOB_TITLE_NN check ("JOB_TITLE" IS NOT NULL)

alter table DEPARTMENTS 
add constraint DEPT_NAME_NN check ("DEPARTMENT_NAME" IS NOT NULL)

alter table EMPLOYEES 
add constraint EMP_EMAIL_UK unique (EMAIL)

alter table EMPLOYEES 
add constraint EMP_DEPT_FK 
foreign key (DEPARTMENT_ID) 
references DEPARTMENTS

alter table EMPLOYEES 
add constraint EMP_JOB_FK 
foreign key (JOB_ID) 
references JOBS (JOB_ID)

alter table EMPLOYEES 
add constraint EMP_EMAIL_NN check ("EMAIL" IS NOT NULL)

alter table EMPLOYEES 
add constraint EMP_HIRE_DATE_NN check ("HIRE_DATE" IS NOT NULL)

alter table EMPLOYEES 
add constraint EMP_JOB_NN check ("JOB_ID" IS NOT NULL)

alter table EMPLOYEES 
add constraint EMP_LAST_NAME_NN check ("LAST_NAME" IS NOT NULL)

alter table EMPLOYEES 
add constraint EMP_SALARY_MIN check (salary > 0)
go

create index EMP_DEPARTMENT_IX on EMPLOYEES (DEPARTMENT_ID);
create index EMP_JOB_IX on EMPLOYEES (JOB_ID);
--create index EMP_MANAGER_IX on EMPLOYEES (MANAGER_ID);
create index EMP_NAME_IX on EMPLOYEES (LAST_NAME, FIRST_NAME);
go

alter table JOB_HISTORY 
add constraint JHIST_DEPT_FK 
foreign key (DEPARTMENT_ID) 
references DEPARTMENTS (DEPARTMENT_ID)

alter table JOB_HISTORY 
add constraint JHIST_EMP_FK 
foreign key (EMPLOYEE_ID) 
references EMPLOYEES (EMPLOYEE_ID)

alter table JOB_HISTORY 
add constraint JHIST_JOB_FK 
foreign key (JOB_ID) 
references JOBS (JOB_ID)

alter table JOB_HISTORY 
add constraint JHIST_DATE_INTERVAL check (end_date > start_date)

alter table JOB_HISTORY 
add constraint JHIST_EMPLOYEE_NN check ("EMPLOYEE_ID" IS NOT NULL)

alter table JOB_HISTORY 
add constraint JHIST_END_DATE_NN check ("END_DATE" IS NOT NULL)

alter table JOB_HISTORY 
add constraint JHIST_JOB_NN check ("JOB_ID" IS NOT NULL)

alter table JOB_HISTORY 
add constraint JHIST_START_DATE_NN check ("START_DATE" IS NOT NULL)
go

create index JHIST_DEPARTMENT_IX on JOB_HISTORY (DEPARTMENT_ID);
create index JHIST_EMPLOYEE_IX on JOB_HISTORY (EMPLOYEE_ID);
create index JHIST_JOB_IX on JOB_HISTORY (JOB_ID);
go

/*****************************************************************
* Create store procedures										 *
******************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id(N'[dbo].[getXMLCountry]') AND Objectproperty(id,N'IsProcedure') = 1)
BEGIN
	drop procedure getXMLCountry	
END
go

create procedure getXMLCountry @XMLPath varchar(255)
as
begin
	set nocount on

	declare @xml xml
	declare @xmlload nvarchar(300)

	SET @xmlload=N'select @xml = (SELECT DXML.* FROM OPENROWSET(BULK N'''+@XMLPath+''', SINGLE_CLOB) AS DXML)'
	exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output
	
	declare @idoc int

	exec sp_xml_preparedocument @idoc OUTPUT, @xml
	
	declare @tempValidateLookupData table (
		[name] varchar(50),
		[fullname] varchar(100),
		[english] varchar(100),
		[alpha2] varchar(2),
		[alpha3] varchar(3),
		[iso] varchar(5),
		[location] varchar(50),
		[location-precise] varchar(100)
	)

	insert @tempValidateLookupData
		select [name], [fullname], [english], [alpha2], [alpha3], [iso], [location], [location-precise]
			from OPENXML (@idoc, '/country-list/country', 2)
			with (	[name] varchar(50), [fullname] varchar(100),
					[english] varchar(100), [alpha2] varchar(2),
					[alpha3] varchar(3), [iso] varchar(5),
					[location] varchar(50), [location-precise] varchar(100))
     
     exec sp_xml_removedocument @idoc 
     
     insert into COUNTRIES(COUNTRY_ID, COUNTRY_NAME) 
		select alpha2, english from @tempValidateLookupData
end
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id(N'[dbo].[getXMLEmployees]') AND Objectproperty(id,N'IsProcedure') = 1)
BEGIN
	drop procedure getXMLEmployees
END
go

create procedure getXMLEmployees @XMLPath varchar(255)
as
begin
	set nocount on

	declare @xml xml
	declare @xmlload nvarchar(300)

	SET @xmlload=N'select @xml = (SELECT DXML.* FROM OPENROWSET(BULK N'''+@XMLPath+''', SINGLE_CLOB) AS DXML)'
	exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output
	
	declare @idoc int

	exec sp_xml_preparedocument @idoc OUTPUT, @xml
	
	declare @tempValidateLookupData table (
	   BusinessEntityID int
      ,FirstName varchar(100)
      ,LastName varchar(100)
      ,email varchar(100)
      ,PhoneNumber varchar(100)
      ,ModifiedDate datetime
      ,SALARY NUMERIC(8,2)
      ,COMMISSION_PCT NUMERIC(2,2)
      ,MANAGER_ID int
      ,DEPARTMENT_ID int
      ,JOB_ID varchar(10)
	)

	insert @tempValidateLookupData
		select BusinessEntityID, FirstName, LastName, email, PhoneNumber, ModifiedDate, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID,JOB_ID
			from OPENXML (@idoc, '/Employees/Employee', 2)
			with (	[BusinessEntityID] int,[FirstName] varchar(100),
					[LastName] varchar(100),[email] varchar(100),
					[PhoneNumber] varchar(100),[ModifiedDate] datetime,
					[SALARY] NUMERIC(8,2),[COMMISSION_PCT] NUMERIC(2,2),
					[MANAGER_ID] int,[DEPARTMENT_ID] int,[JOB_ID] varchar(10))
     
     exec sp_xml_removedocument @idoc 
     
     insert into EMPLOYEES(FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID,JOB_ID) 
		select FirstName, LastName, email, PhoneNumber, ModifiedDate, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID,JOB_ID from @tempValidateLookupData

end
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id(N'[dbo].[getXMLDepartments]') AND Objectproperty(id,N'IsProcedure') = 1)
BEGIN
	drop procedure getXMLDepartments
END
go

create procedure getXMLDepartments @XMLPath varchar(255)
as
begin
	set nocount on

	declare @xml xml
	declare @xmlload nvarchar(300)

	SET @xmlload=N'select @xml = (SELECT DXML.* FROM OPENROWSET(BULK N'''+@XMLPath+''', SINGLE_CLOB) AS DXML)'
	exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output
	
	declare @idoc int

	exec sp_xml_preparedocument @idoc OUTPUT, @xml
	
	declare @tempValidateLookupData table (
	    DEPARTMENT_ID   int,
		DEPARTMENT_NAME VARCHAR(30),
		MANAGER_ID      int,
		COUNTRY_ID   CHAR(2)
	)

	insert @tempValidateLookupData
		select DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, COUNTRY_ID
			from OPENXML (@idoc, '/Departments/Department', 2)
			with (	DEPARTMENT_ID   int, DEPARTMENT_NAME VARCHAR(30),
					MANAGER_ID      int, COUNTRY_ID   CHAR(2))
     
     exec sp_xml_removedocument @idoc 
     
     insert into DEPARTMENTS(DEPARTMENT_NAME, MANAGER_ID, COUNTRY_ID) 
		select DEPARTMENT_NAME, MANAGER_ID, COUNTRY_ID from @tempValidateLookupData

end
go

/*****************************************************************
******************************************************************
*						The Second task	(part 1)				 *
******************************************************************
******************************************************************/

/*****************************************************************
* Drop history tables											 *
******************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HISTORY_COUNTRIES]'))
BEGIN
	DROP TABLE HISTORY_COUNTRIES	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HISTORY_JOBS]'))
BEGIN
	DROP TABLE HISTORY_JOBS	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HISTORY_DEPARTMENTS]'))
BEGIN
	DROP TABLE HISTORY_DEPARTMENTS	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HISTORY_EMPLOYEES]'))
BEGIN
	DROP TABLE HISTORY_EMPLOYEES	
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HISTORY_JOB_HISTORY]'))
BEGIN
	DROP TABLE HISTORY_JOB_HISTORY	
END
go

/*****************************************************************
* Create history tables											 *
******************************************************************/

create table HISTORY_COUNTRIES (
  ID int identity primary key,
  COUNTRY_ID   CHAR(2),
  COUNTRY_NAME VARCHAR(100),
  DATE_START datetime default(GetDate()), 
  DATE_END datetime default('12/28/9999'),
  CURRENT_VERSION int default(0),
  CUR_USER varchar(100)
)
go

create table HISTORY_JOBS (
  ID int identity primary key,
  JOB_ID     VARCHAR(10),
  JOB_TITLE  VARCHAR(35),
  MIN_SALARY int,
  MAX_SALARY int,
  DATE_START datetime default(GetDate()), 
  DATE_END datetime default('12/28/9999'),
  CURRENT_VERSION int default(0),
  CUR_USER varchar(100)
)
go

create table HISTORY_DEPARTMENTS (
  ID int identity primary key,
  DEPARTMENT_ID   int,
  DEPARTMENT_NAME VARCHAR(30),
  MANAGER_ID      int,
  COUNTRY_ID   CHAR(2),
  DATE_START datetime default(GetDate()), 
  DATE_END datetime default('12/28/9999'),
  CURRENT_VERSION int default(0),
  CUR_USER varchar(100)
)
go

create table HISTORY_EMPLOYEES (
  ID int identity primary key,
  EMPLOYEE_ID    int,
  FIRST_NAME     VARCHAR(100),
  LAST_NAME      VARCHAR(100),
  EMAIL          VARCHAR(100),
  PHONE_NUMBER   VARCHAR(100),
  HIRE_DATE      DATETIME,
  JOB_ID         VARCHAR(10),
  SALARY         NUMERIC(8,2),
  COMMISSION_PCT NUMERIC(2,2),
  MANAGER_ID     int,
  DEPARTMENT_ID  int,
  DATE_START datetime default(GetDate()), 
  DATE_END datetime default('12/28/9999'),
  CURRENT_VERSION int default(0),
  CUR_USER varchar(100)
)
go

create table HISTORY_JOB_HISTORY (
  ID int identity primary key,
  EMPLOYEE_ID   int,
  START_DATE    DATETIME,
  END_DATE      DATETIME,
  JOB_ID        VARCHAR(10),
  DEPARTMENT_ID int,  
  DATE_START datetime default(GetDate()), 
  DATE_END datetime default('12/28/9999'),
  CURRENT_VERSION int default(0),
  CUR_USER varchar(100)
)
go

/*****************************************************************
* Create history triggers										 *
******************************************************************/

CREATE TRIGGER [dbo].trgUpCountries ON  [dbo].COUNTRIES
   AFTER UPDATE
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_COUNTRIES set DATE_END = GETDATE()
		from inserted as I
		where HISTORY_COUNTRIES.COUNTRY_ID = I.COUNTRY_ID and HISTORY_COUNTRIES.DATE_END = (select max(DATE_END) from HISTORY_COUNTRIES where COUNTRY_ID = I.COUNTRY_ID)
	
	insert into HISTORY_COUNTRIES(COUNTRY_ID, COUNTRY_NAME, DATE_START, CURRENT_VERSION, CUR_USER)
		select I.COUNTRY_ID, I.COUNTRY_NAME, HC.DATE_START, (select max(CURRENT_VERSION) + 1 from HISTORY_COUNTRIES where COUNTRY_ID = I.COUNTRY_ID), @sys_user
		from inserted as I, HISTORY_COUNTRIES as HC
		where I.COUNTRY_ID = HC.COUNTRY_ID
END
go

CREATE TRIGGER [dbo].trgUpDepartments ON  [dbo].DEPARTMENTS
   AFTER UPDATE
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER
		
	update HISTORY_DEPARTMENTS set DATE_END = GETDATE()
		from inserted as I
		where HISTORY_DEPARTMENTS.DEPARTMENT_ID = I.DEPARTMENT_ID and HISTORY_DEPARTMENTS.DATE_END = (select max(DATE_END) from HISTORY_DEPARTMENTS where DEPARTMENT_ID = I.DEPARTMENT_ID)
	
	insert into HISTORY_DEPARTMENTS(DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, COUNTRY_ID, DATE_START, CURRENT_VERSION, CUR_USER)
		select I.DEPARTMENT_ID, I.DEPARTMENT_NAME, I.MANAGER_ID, I.COUNTRY_ID, HD.DATE_START, (select max(CURRENT_VERSION) + 1 from HISTORY_DEPARTMENTS where DEPARTMENT_ID = I.DEPARTMENT_ID), @sys_user
		from inserted as I, HISTORY_DEPARTMENTS as HD
		where I.DEPARTMENT_ID = HD.DEPARTMENT_ID
END
go

CREATE TRIGGER [dbo].trgUpEmployees ON  [dbo].EMPLOYEES
   AFTER UPDATE
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER
		
	update HISTORY_EMPLOYEES set DATE_END = GETDATE()
		from inserted as I
		where HISTORY_EMPLOYEES.EMPLOYEE_ID = I.EMPLOYEE_ID and HISTORY_EMPLOYEES.DATE_END = (select max(DATE_END) from HISTORY_EMPLOYEES where EMPLOYEE_ID = I.EMPLOYEE_ID)
	
	insert into HISTORY_EMPLOYEES(EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID, DATE_START, CURRENT_VERSION, CUR_USER)
		select I.EMPLOYEE_ID, I.FIRST_NAME, I.LAST_NAME, I.EMAIL, I.PHONE_NUMBER, I.HIRE_DATE, I.JOB_ID, I.SALARY, I.COMMISSION_PCT, I.MANAGER_ID, I.DEPARTMENT_ID, HE.DATE_START, (select max(CURRENT_VERSION) + 1 from HISTORY_EMPLOYEES where EMPLOYEE_ID = I.EMPLOYEE_ID), @sys_user
		from inserted as I, HISTORY_EMPLOYEES as HE
		where I.EMPLOYEE_ID = HE.EMPLOYEE_ID
END
go

CREATE TRIGGER [dbo].trgUpJob_History ON  [dbo].JOB_HISTORY
   AFTER UPDATE
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER
		
	update HISTORY_JOB_HISTORY set DATE_END = GETDATE()
		from inserted as I
		where HISTORY_JOB_HISTORY.EMPLOYEE_ID = I.EMPLOYEE_ID and HISTORY_JOB_HISTORY.START_DATE = I.START_DATE and HISTORY_JOB_HISTORY.DATE_END = (select max(DATE_END) from HISTORY_JOB_HISTORY where HISTORY_JOB_HISTORY.EMPLOYEE_ID = I.EMPLOYEE_ID and HISTORY_JOB_HISTORY.START_DATE = I.START_DATE)
	
	insert into HISTORY_JOB_HISTORY(EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID, DATE_START, CURRENT_VERSION, CUR_USER)
		select I.EMPLOYEE_ID, I.START_DATE, I.END_DATE, I.JOB_ID, I.DEPARTMENT_ID, HJH.DATE_START, (select max(CURRENT_VERSION) + 1 from HISTORY_JOB_HISTORY where HISTORY_JOB_HISTORY.EMPLOYEE_ID = I.EMPLOYEE_ID and HISTORY_JOB_HISTORY.START_DATE = I.START_DATE), @sys_user
		from inserted as I, HISTORY_JOB_HISTORY as HJH
		where I.EMPLOYEE_ID = HJH.EMPLOYEE_ID and I.START_DATE = HJH.START_DATE
END
go

CREATE TRIGGER [dbo].trgUpJobs ON  [dbo].JOBS
   AFTER UPDATE
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_JOBS set DATE_END = GETDATE()
		from inserted as I
		where HISTORY_JOBS.JOB_ID = I.JOB_ID and HISTORY_JOBS.DATE_END = (select max(DATE_END) from HISTORY_JOBS where JOB_ID = I.JOB_ID)
	
	insert into HISTORY_JOBS(JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY, DATE_START, CURRENT_VERSION, CUR_USER)
		select I.JOB_ID, I.JOB_TITLE, I.MIN_SALARY, I.MAX_SALARY, HJ.DATE_START, (select max(CURRENT_VERSION) + 1 from HISTORY_JOBS where JOB_ID = I.JOB_ID), @sys_user
		from inserted as I, HISTORY_JOBS as HJ
		where I.JOB_ID = HJ.JOB_ID
END
go

CREATE TRIGGER [dbo].trgDelCountries ON  [dbo].COUNTRIES
   AFTER DELETE, INSERT
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_COUNTRIES set DATE_END = GETDATE()
		from deleted as D
		where HISTORY_COUNTRIES.COUNTRY_ID = D.COUNTRY_ID
		
	insert into HISTORY_COUNTRIES(COUNTRY_ID, COUNTRY_NAME, CUR_USER)
		select I.COUNTRY_ID, I.COUNTRY_NAME, @sys_user from inserted as I
END
go

CREATE TRIGGER [dbo].trgDelDepartments ON  [dbo].DEPARTMENTS
   AFTER DELETE, INSERT
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_DEPARTMENTS set DATE_END = GETDATE()
		from deleted as D
		where HISTORY_DEPARTMENTS.DEPARTMENT_ID = D.DEPARTMENT_ID
		
	insert into HISTORY_DEPARTMENTS(DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, COUNTRY_ID, CUR_USER)
		select I.DEPARTMENT_ID, I.DEPARTMENT_NAME, I.MANAGER_ID, I.COUNTRY_ID, @sys_user from inserted as I
END
go

CREATE TRIGGER [dbo].trgDelEmployees ON  [dbo].EMPLOYEES
   AFTER DELETE, INSERT
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_EMPLOYEES set DATE_END = GETDATE()
		from deleted as D
		where HISTORY_EMPLOYEES.EMPLOYEE_ID = D.EMPLOYEE_ID
		
	insert into HISTORY_EMPLOYEES(EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID, CUR_USER)
		select I.EMPLOYEE_ID, I.FIRST_NAME, I.LAST_NAME, I.EMAIL, I.PHONE_NUMBER, I.HIRE_DATE, I.JOB_ID, I.SALARY, I.COMMISSION_PCT, I.MANAGER_ID, I.DEPARTMENT_ID, @sys_user from inserted as I
END
go

CREATE TRIGGER [dbo].trgDelJob_History ON  [dbo].JOB_HISTORY
   AFTER DELETE, INSERT
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_JOB_HISTORY set DATE_END = GETDATE()
		from deleted as D
		where HISTORY_JOB_HISTORY.EMPLOYEE_ID = D.EMPLOYEE_ID and HISTORY_JOB_HISTORY.START_DATE = D.START_DATE
		
	insert into HISTORY_JOB_HISTORY(EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID, CUR_USER)
		select I.EMPLOYEE_ID, I.START_DATE, I.END_DATE, I.JOB_ID, I.DEPARTMENT_ID, @sys_user from inserted as I
END
go

CREATE TRIGGER [dbo].trgDelJobs ON  [dbo].JOBS
   AFTER DELETE, INSERT
AS 
BEGIN	
	SET NOCOUNT ON;
	declare @sys_user varchar(100)
	select @sys_user = SYSTEM_USER

	update HISTORY_JOBS set DATE_END = GETDATE()
		from deleted as D
		where HISTORY_JOBS.JOB_ID = D.JOB_ID
		
	insert into HISTORY_JOBS(JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY, CUR_USER)
		select I.JOB_ID, I.JOB_TITLE, I.MIN_SALARY, I.MAX_SALARY, @sys_user from inserted as I
END
go

/*****************************************************************
* Operations with data											 *
******************************************************************/

insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('AD_PRES', 'President', 20000, 40000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('AD_VP', 'Administration Vice President', 15000, 30000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('AD_ASST', 'Administration Assistant', 3000, 6000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('FI_MGR', 'Finance Manager', 8200, 16000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('FI_ACCOUNT', 'Accountant', 4200, 9000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('AC_MGR', 'Accounting Manager', 8200, 16000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('AC_ACCOUNT', 'Public Accountant', 4200, 9000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('SA_MAN', 'Sales Manager', 10000, 20000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('SA_REP', 'Sales Representative', 6000, 12000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('PU_MAN', 'Purchasing Manager', 8000, 15000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('PU_CLERK', 'Purchasing Clerk', 2500, 5500)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('ST_MAN', 'Stock Manager', 5500, 8500)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('ST_CLERK', 'Stock Clerk', 2000, 5000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('SH_CLERK', 'Shipping Clerk', 2500, 5500)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('IT_PROG', 'Programmer', 4000, 10000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('MK_MAN', 'Marketing Manager', 9000, 15000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('MK_REP', 'Marketing Representative', 4000, 9000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('HR_REP', 'Human Resources Representative', 4000, 9000)
insert into JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY) values ('PR_REP', 'Public Relations Representative', 4500, 10500)
go

exec getXMLCountry N'd:\country.xml'
go

exec getXMLDepartments N'd:\departments.xml'
go

exec getXMLEmployees N'd:\employees.xml'
go

insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (102, '12/01/1993', '04/07/1998', 'IT_PROG', 1);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (101, '02/09/1989', '07/10/1993', 'AC_ACCOUNT', 2);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (101, '08/10/1993', '05/03/1997', 'AC_MGR', 3);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (201, '07/02/1996', '09/12/1999', 'MK_REP', 2);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (114, '04/03/1998', '03/12/1999', 'ST_CLERK', 6);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (122, '01/01/1999', '01/12/1999', 'ST_CLERK', 7);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (200, '11/09/1987', '07/06/1993', 'AD_ASST', 2);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (176, '04/03/1998', '01/12/2000', 'SA_REP', 3);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (176, '01/01/1999', '01/12/1999', 'SA_MAN', 4);
insert into JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
values (200, '01/07/1994', '01/12/1998', 'AC_ACCOUNT', 1);
go

/*****************************************************************
* Create adding constraints										 *
******************************************************************/

alter table DEPARTMENTS 
add constraint DEPT_MGR_FK 
foreign key (MANAGER_ID) 
references EMPLOYEES
go
/*
alter table EMPLOYEES 
add constraint EMP_MANAGER_FK 
foreign key (MANAGER_ID) 
references EMPLOYEES
go
*/
alter table DEPARTMENTS 
add constraint EMP_COUNTRY_FK 
foreign key (COUNTRY_ID) 
references COUNTRIES
go

/*****************************************************************
* Operations with history tables								 *
******************************************************************/

update COUNTRIES set COUNTRY_NAME = 'TEST' where COUNTRY_ID = 'AB'
update DEPARTMENTS set DEPARTMENT_NAME = 'TEST' where DEPARTMENT_ID = 3
update EMPLOYEES set FIRST_NAME = 'TEST' where EMPLOYEE_ID = 3
update JOB_HISTORY set END_DATE = '12/28/9999' where EMPLOYEE_ID = 101 and START_DATE = '1989-02-09 00:00:00.000'
update JOBS set JOB_TITLE = 'TEST' where JOB_ID = 'AC_ACCOUNT'
go

insert into COUNTRIES values('WW', 'TEST')
insert into DEPARTMENTS values('TEST', 1, 'WW')
insert into EMPLOYEES values('TEST', 'TEST', 'TEST', 'TEST', '12/28/9999', 'AC_ACCOUNT', 9999, null, 1, 1)
insert into JOB_HISTORY values(1, '12/28/9999', '12/29/9999', 'AC_ACCOUNT', 1)
insert into JOBS values('TEST', 'TEST_TEST', 1000, 10000)
go

delete from JOBS where JOB_TITLE = 'TEST_TEST'
delete from DEPARTMENTS where DEPARTMENT_NAME = 'TEST' and COUNTRY_ID = 'WW'
delete from EMPLOYEES where FIRST_NAME = 'TEST' and LAST_NAME = 'TEST'
delete from JOB_HISTORY where EMPLOYEE_ID = 1 and START_DATE = '12/28/9999'
delete from COUNTRIES where COUNTRY_ID = 'WW'
go

update EMPLOYEES set MANAGER_ID = null 
from EMPLOYEES as E, DEPARTMENTS as D
where E.EMPLOYEE_ID = D.MANAGER_ID
go