use Training
go

/****** Create employees table  ******/
  declare @tempData table (
		BusinessEntityID int
      ,FirstName varchar(100)
      ,LastName varchar(100)
      ,email varchar(100)
      ,PhoneNumber varchar(100)
      ,ModifiedDate datetime
      ,SALARY NUMERIC(8,2)
      ,COMMISSION_PCT varchar(50)
      ,MANAGER_ID int
      ,DEPARTMENT_ID int
      ,JOB_ID varchar(10)
	)	

  insert @tempData	
  SELECT P.[BusinessEntityID]      
      ,P.[FirstName]
      ,P.[LastName]
      ,P.FirstName + '_' + P.LastName + '_' + CAST (P.[BusinessEntityID] AS VARCHAR(5)) + '@gmail.com'
      ,PP.PhoneNumber
      ,P.ModifiedDate
      ,ROUND((RAND(P.[BusinessEntityID] * 100)* 10000),0) + 1 as 'SALARY'
      ,null as 'COMMISSION_PCT'
      ,ROUND((RAND(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PP.PhoneNumber, ' ', ''), '-', ''), '(', ''), ')', ''), '9', ''), '5', ''))* 19971), 0) + 1 as 'MANAGER_ID'
      ,ROUND((RAND(P.[BusinessEntityID])* 752),0) + 1 as 'DEPARTMENT_ID'
      ,(select o.job_id from (select o.*, row_number() over (order by o.job_id) rw 
        from [Training].[dbo].[JOBS] o) o 
        where o.rw = ROUND((RAND(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PP.PhoneNumber, ' ', ''), '-', ''), '(', ''), ')', ''), '9', ''), '5', ''))* 18), 0) + 1
        ) as 'JOB_ID'
  FROM [AdventureWorks2008R2].[Person].[Person] as P, [AdventureWorks2008R2].[Person].[PersonPhone] as PP
  WHERE P.BusinessEntityID = PP.BusinessEntityID
  order by P.[BusinessEntityID]
  
  select * from @tempData
  FOR XML RAW ('Employee'), ROOT ('Employees'), ELEMENTS
  go

/****** Create departments table  ******/
  declare @tempDepartments table (
		DEPARTMENT_ID   int identity primary key,
		DEPARTMENT_NAME VARCHAR(30),
		MANAGER_ID      int,
		COUNTRY_ID   CHAR(2)
	)	
  	
  declare @count int
  set @count = 3
  
  while @count > 0
  begin
	insert into @tempDepartments(COUNTRY_ID) 
		select 
			COUNTRY_ID		
		from COUNTRIES
	set @count = @count - 1
  end	

  update @tempDepartments set 
		DEPARTMENT_NAME = (select TOP 1 o.Name 
			from [AdventureWorks2008R2].[HumanResources].[Department] o
			order by RAND(CHECKSUM(NEWID()) % 8023)* 18
			),
		MANAGER_ID = ROUND((RAND(CHECKSUM(NEWID()) % 8023)* 10973), 0) + 1
	
  select * from @tempDepartments
  FOR XML RAW ('Department'), ROOT ('Departments'), ELEMENTS
  go
