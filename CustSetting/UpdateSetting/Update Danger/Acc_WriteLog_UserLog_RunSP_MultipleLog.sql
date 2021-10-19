/*<info serverAlias="DBCUST-bodb_CustomerLog,DBLOG-bodb_CustomerLog" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_WriteLog_UserLog_RunSP_MultipleLog]
	@UserID INT,	
	@ActionID INT = NULL,	
	@Log NVARCHAR(MAX)= NULL,
	@IP	VARCHAR(20)='',
	@Duration INT = NULL
AS		
/* 
	Created: 20211014@Johnson
    Task: write multiple log for job update danger level 
    DB: DBLOG/bodb_CustomerLog

	Revisions:
		- 20211014@Johnson: Initial sp [redmine:#161351]
    Param's Explaination:    	
		- @UserID: UserId perform this action
		- @Log = '<Root>
					<r id="1" s="10" b="11" us="1" ub="0" os="5" ob="11">
					<r id="2" s="15" b="10" us="1" ub="1" os="5" ob="11">
				</Root>
				'
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @xml XML = CAST (@Log as XML)
	
	IF @ActionID = 1187 
	BEGIN
		CREATE TABLE #tblCustLog(custid INT PRIMARY KEY, soccer TINYINT, basketball TINYINT, updateSoccer BIT, updateBasketball BIT, OldSoccer TINYINT, OldBasketball TINYINT, WinlossSoccer MONEY, WinlossBasketball MONEY)
		
		INSERT INTO #tblCustLog(custid,soccer,basketball,updateSoccer,updateBasketball,OldSoccer,OldBasketball,WinlossSoccer,WinlossBasketball)
		SELECT t.c.value('@id[1]','int'),
			t.c.value('@s[1]','tinyint'),
			t.c.value('@b[1]','tinyint'),
			t.c.value('@us[1]','bit'),
			t.c.value('@ub[1]','bit'),
			t.c.value('@os[1]','tinyint'),
			t.c.value('@ob[1]','tinyint'),
			t.c.value('@wls[1]','money'),
			t.c.value('@wlb[1]','money')
		FROM @xml.nodes('Root/r')as t(c)
		
		;WITH Tmp AS (
		SELECT custid,
			(SELECT 
				CASE WHEN UpdateSoccer = 1 THEN soccer END as '@Soccer',
				CASE WHEN UpdateBasketball = 1 THEN basketball END as '@Basketball',
				CASE WHEN UpdateSoccer = 1 THEN WinlossSoccer END as '@WinlossSoccer',
				CASE WHEN UpdateBasketball = 1 THEN WinlossBasketball END as '@WinlossBasketball',
				@IP as '@IP'
			FROM #tblCustLog t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R')
			) as LogNew,
			(SELECT 
				CASE WHEN UpdateSoccer = 1 THEN OldSoccer END as '@Soccer',
				CASE WHEN UpdateBasketball = 1 THEN OldBasketball END as '@Basketball',
				CASE WHEN UpdateSoccer = 1 THEN WinlossSoccer END as '@WinlossSoccer',
				CASE WHEN UpdateBasketball = 1 THEN WinlossBasketball END as '@WinlossBasketball',
				@IP as '@IP'
			FROM #tblCustLog t2
			WHERE t2.custid = t.custid
			FOR XML PATH('R')
			) as LogOld
		FROM #tblCustLog t
		)
		INSERT INTO dbo.UserLog_RunSP(	UserID, 
									CustID, 								
									ActionID, 
									TrackingValue,
									TrackingValue2,
									Duration
									)
		SELECT @UserID,
			CustID,
			@ActionID,
			LogNew,
			LogOld,
			@Duration
		FROM Tmp
		
		DROP TABLE #tblCustLog
	END
	ELSE IF @ActionID = 1188
	BEGIN
		CREATE TABLE #tblCustLogManual(custid INT PRIMARY KEY, sport TINYINT, OldFlag BIT, NewFlag BIT, OldLevel TINYINT, NewLevel TINYINT)
		
		INSERT INTO #tblCustLogManual(custid,sport,newflag,oldflag,newlevel,oldlevel)
		SELECT t.c.value('@id[1]','int'),
			t.c.value('@sport[1]','tinyint'),
			t.c.value('@newflag[1]','bit'),
			t.c.value('@oldflag[1]','bit'),
			t.c.value('@newlevel[1]','tinyint'),
			t.c.value('@oldlevel[1]','tinyint')
		FROM @xml.nodes('Root/r')as t(c)
		
		
		;WITH Tmp AS (
		SELECT custid,
			(SELECT 
				CASE WHEN sport = 0 THEN 'Soccer' WHEN sport= 1 THEN 'Basketball' END as '@SportType',
				NewLevel as '@DangerLevel',
				NewFlag as '@ManualDangerLevel',
				@IP as '@IP'
			FROM #tblCustLogManual t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R')
			) as LogNew,
			(SELECT 
				CASE WHEN sport = 0 THEN 'Soccer' WHEN sport= 1 THEN 'Basketball' END as '@SportType',
				OldLevel as '@DangerLevel',
				OldFlag as '@ManualDangerLevel',
				@IP as '@IP'
			FROM #tblCustLogManual t2
			WHERE t2.custid = t.custid
			FOR XML PATH('R')
			) as LogOld
		FROM #tblCustLogManual t
		)
		INSERT INTO dbo.UserLog_RunSP(	UserID, 
									CustID, 								
									ActionID, 
									TrackingValue,
									TrackingValue2,
									Duration
									)
		SELECT @UserID,
			CustID,
			@ActionID,
			LogNew,
			LogOld,
			@Duration
		FROM Tmp
		
		DROP TABLE #tblCustLogManual
	END
END