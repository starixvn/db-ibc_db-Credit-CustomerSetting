/*
	Created: Helen
	Date: 20160301
	Task: Delete redundant All Bet settings except StakeLevel
	DB: DBCust/CustDB
*/
DECLARE @maxcustID INT = xxx
DECLARE @Sporttype INT, @Bettype INT, @IsLive BIT

SELECT @Sporttype = 211, @Bettype = 2401, @IsLive = 0

CREATE TABLE #DirectMaster (CustID INT,roleid INT)
CREATE TABLE #DirectAgent (CustID INT,mrecommend INT,roleid INT)
--- get direct master
INSERT INTO #DirectMaster (CustID,roleid)
SELECT custid, roleid
FROM Customer with(nolock)
WHERE SITE in ('733333','222223')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=3 AND srecommend IN (2,13)
--- get direct agent

INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT custid, mrecommend,roleid
FROM Customer WITH(NOLOCK)
WHERE site in ('733333','222223')
	and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
	and roleid=2 AND srecommend IN (2,13)
--PT
DELETE cs
FROM [dbo].CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND cs.IsLive = @IsLive
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))
	
DELETE cs
FROM [dbo].CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND cs.IsLive = @IsLive
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

DELETE cs
FROM [dbo].CustPTGroupSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.AgentID = c.custid
WHERE cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND cs.IsLive = @IsLive
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

--Commission
DELETE cs
FROM [dbo].CustDiscount3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

DELETE cs
FROM [dbo].CustDiscount3rd_Member cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

--WinLossLimit
DELETE cs
FROM [dbo].CustWinLossLimit_Agent cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

DELETE cs
FROM [dbo].CustWinLossLimit_Member cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype = @Bettype
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

--StakeLevel
DELETE cs
FROM [dbo].CustStakeLevel_Agent cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype IN (2401,2402)
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))

DELETE cs
FROM [dbo].CustStakeLevel_Member cs WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cs.CustID = c.custid
WHERE cs.CustID > @maxcustID
	AND cs.Sporttype = @Sporttype
	AND cs.Bettype IN (2401,2402)
	AND (C.mrecommend in (select custid from #DirectMaster) OR c.recommend in (select custid from #DirectAgent))
	