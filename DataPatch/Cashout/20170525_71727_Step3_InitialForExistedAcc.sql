
/*
	Created: Winnie	
	Task: Enable CashOut for existed customer
	DB: DBCUST/CustDB
	Date: 20170515
*/ 
------------------------------------------------------
alter procedure dbo.Acc_CustSetting3rd_19 @srecommend int
	, @maxcustid int
	, @target varchar(20)
as
begin
	set nocount on
	
	if (@target = 'replicated' and @@servername = 'dbcust') return	-- run at all replicated servers
	if (@target = 'dbcust' and @@servername <> 'dbcust') return -- run at dbtrans only
		
	IF NOT (dbo.f_CheckRepTable('Dep_CustProductSetting') = 1 
	   AND dbo.f_CheckRepTable('Dep_SupperProductSetting') = 1	 
	   AND dbo.f_CheckRepTable('Customer') = 1	 
	   )
		RETURN		
	
	INSERT INTO dbo.Dep_SupperProductSetting (CustID, ProductId, IsEnabled)
	VALUES (@srecommend, 25, 1)

	
	INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
	SELECT c.CustID, 25, 1
	FROM Customer c WITH(NOLOCK) WHERE custid<=@maxcustid AND srecommend=@srecommend AND roleid=1 

end
go
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB ------
------------------------------------------------------

---
---
-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
--------------------------------------------------------------------------------------

declare @MaxCustId int,@srecommend int

set @MaxCustId = xxx

create table #supers (srecommend int, isFinished bit default(0))
INSERT INTO #supers(srecommend)
SELECT ci.custid
FROM Customer ci WITH(NOLOCK)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE ci.roleid = 4 	
AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
AND c.Enabled=1	
AND ci.site IN ('Macaubet','Aoncash','ITCBET','9Bet','Allbetclub','m8bola','Q8Bola','NBCbet','BE7','Goobet','Bolanation','IndoWin','IvoryBet','Unobet')
AND c.custid<=@MaxCustId
while 1 = 1
begin
	
	update top (1) #supers
	set isFinished = 1
		, @srecommend = srecommend
	where isFinished = 0
	
	if @@rowcount = 0 break

	exec dbo.Acc_CustSetting3rd_19 @srecommend = @srecommend
			, @maxcustid = @maxcustid
			, @target = 'REPLICATED'
	
	waitfor delay '00:00:0.280'

end

go
-- END STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
-----------------------------------------------------------------------------------

---
-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
declare @MaxCustId int,@srecommend int

set @MaxCustId = xxx

create table #supers (srecommend int, isFinished bit default(0))
INSERT INTO #supers(srecommend)
SELECT ci.custid
FROM Customer ci WITH(NOLOCK)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE ci.roleid = 4 	
AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
AND c.Enabled=1	
AND ci.site IN ('Macaubet','Aoncash','ITCBET','9Bet','Allbetclub','m8bola','Q8Bola','NBCbet','BE7','Goobet','Bolanation','IndoWin','IvoryBet','Unobet')
AND c.custid<=@MaxCustId

while 1 = 1
begin
	
	update top (1) #supers
	set isFinished = 1
		, @srecommend = srecommend			
	where isFinished = 0
	
	if @@rowcount = 0 break

	exec dbo.Acc_CustSetting3rd_19 @srecommend = @srecommend
			, @maxcustid = @maxcustid
			, @target = 'DBCUST'
	
	waitfor delay '00:00:0.280'

end
go

-- END STEP 3: RUN THIS SCRIPT AT DBCUST -----
-----------------------------------------------------------------------------------

