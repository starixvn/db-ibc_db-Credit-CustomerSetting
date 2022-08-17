/*<info serverAlias="DBCUST-bodb_CustomerLog,DBLOG-bodb_CustomerLog" executers="bodbAdminNet,Dot_Admin" viewers="" isFunction="0" isNested="1"></info>*/
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
		- 20220803@Tacy: Add ActionID 1189; 1190 [RedmineID: #175857]

    Param's Explaination:    	
		- @UserID: UserId perform this action
		-@ActionID = 1187
			@Log = '<Root>
					<r id="1" s="10" b="11" us="1" ub="0" os="5" ob="11">
					<r id="2" s="15" b="10" us="1" ub="1" os="5" ob="11">
				</Root>
				'
		-@ActionID = 1188
			@Log = '<Root>
					<r id="1" sport="0" newflag="1" oldflag="0" newlevel="10" oldlevel="5" />
					<r id="2" sport="1" newflag="1" oldflag="0" newlevel="10" oldlevel="15" />
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
			CASE WHEN ISNUMERIC(t.c.value('@wls[1]','varchar(10)'))=0 THEN NULL ELSE t.c.value('@wls[1]','money') END,
			CASE WHEN ISNUMERIC(t.c.value('@wlb[1]','varchar(10)'))=0 THEN NULL ELSE t.c.value('@wlb[1]','money') END
		FROM @xml.nodes('Root/r')as t(c)
		
		;WITH Tmp AS (
		SELECT custid,
			(SELECT 
				CASE WHEN UpdateSoccer = 1 THEN soccer END as '@Soccer',
				CASE WHEN UpdateBasketball = 1 THEN basketball END as '@Basketball',
				CASE WHEN UpdateSoccer = 1 THEN ISNULL(WinlossSoccer,'') END as '@WinlossSoccer',
				CASE WHEN UpdateBasketball = 1 THEN ISNULL(WinlossBasketball,'') END as '@WinlossBasketball',
				@IP as '@IP'
			FROM #tblCustLog t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R')
			) as LogNew,
			(SELECT 
				CASE WHEN UpdateSoccer = 1 THEN OldSoccer END as '@Soccer',
				CASE WHEN UpdateBasketball = 1 THEN OldBasketball END as '@Basketball',
				CASE WHEN UpdateSoccer = 1 THEN ISNULL(WinlossSoccer,'') END as '@WinlossSoccer',
				CASE WHEN UpdateBasketball = 1 THEN ISNULL(WinlossBasketball,'') END as '@WinlossBasketball',
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
	ELSE IF @ActionID=1189
	BEGIN
		CREATE TABLE #tblCustLogAdd(
				CustID		INT
			,	SportType	TINYINT
		)
		
		INSERT INTO #tblCustLogAdd(custid,SportType)
		SELECT	t.c.value('@CustID[1]','int'),
				t.c.value('@SportType[1]','tinyint')
		FROM @xml.nodes('Root/r')as t(c)
		
		;WITH Tmp AS (
		SELECT DISTINCT 
			custid,
			(SELECT 
				SportType	AS '@SportType',
				@IP as '@IP'
			FROM #tblCustLogAdd t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R'), ROOT ('ROOT')
			) as LogAdd
		FROM #tblCustLogAdd t
		)
		INSERT INTO dbo.UserLog_RunSP(UserID,CustID,ActionID,TrackingValue,Duration)
		SELECT @UserID,CustID,@ActionID,LogAdd,@Duration
		FROM Tmp
		
		DROP TABLE #tblCustLogAdd
	END
	ELSE IF @ActionID=1190
	BEGIN
		CREATE TABLE #tblCustLogRemove(
				CustID		INT
			,	SportType	TINYINT
		)
		
		INSERT INTO #tblCustLogRemove(custid,SportType)
		SELECT	t.c.value('@CustID[1]','int'),
				t.c.value('@SportType[1]','tinyint')
		FROM @xml.nodes('Root/r')as t(c)

		;WITH Tmp AS (
		SELECT DISTINCT 
			custid,
			(SELECT 
				SportType	AS '@SportType',
				@IP as '@IP'
			FROM #tblCustLogRemove t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R'), ROOT ('ROOT')
			) as LogRemove
		FROM #tblCustLogRemove t
		)
		INSERT INTO dbo.UserLog_RunSP(UserID,CustID,ActionID,TrackingValue,Duration)
		SELECT @UserID,CustID,@ActionID,LogRemove,@Duration
		FROM Tmp
		
		DROP TABLE #tblCustLogRemove
	END
END