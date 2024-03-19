/*<info serverAlias="DBCUST-bodb_CustomerLog,DBLOG-bodb_CustomerLog" executers="bodbAdminNet,wsv_nap,Dot_Admin" viewers="" isFunction="0" isNested="1"></info>*/
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
		- 20221110@Tacy: Add ActionID 1191-1196, remove 1187,1188 [RedmineId: #179078]

    Param's Explaination:    	
		- @UserID: UserId perform this action
		-@ActionID = 1191,1192
			@Log = '<Root>
					<r id="1" sport="0" newlevel="10" oldlevel="11" wl="1000" IsPA="1">
					<r id="2" sport="1" newlevel="10" oldlevel="11" wl="1000" IsPA="1">
				</Root>
				'
		-@ActionID = 1193 ~ 1196
			@Log = '<Root>
					<r id="1" sport="0" newflag="1" oldflag="0" newlevel="10" oldlevel="5" />
					<r id="2" sport="1" newflag="1" oldflag="0" newlevel="10" oldlevel="15" />
				</Root>
				'		
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @xml XML = CAST (@Log as XML)

	CREATE TABLE #tblCustLog(
				custid			INT, 
				sporttype		TINYINT, 
				NewFlag			BIT,
				OldFlag			BIT, 
				NewLevel		TINYINT, 
				OldLevel		TINYINT, 
				Winloss			MONEY, 
				IsUpdatedByPA	BIT,
				PRIMARY KEY (CustID, SportType))
	
	IF @ActionID=1189
	BEGIN
		INSERT INTO #tblCustLog(custid,SportType)
		SELECT	t.c.value('@CustID[1]','int'),
				t.c.value('@SportType[1]','tinyint')
		FROM @xml.nodes('Root/r')as t(c)
		
		;WITH Tmp AS (
			SELECT DISTINCT 
				custid,
				(SELECT 
					SportType	AS '@SportType',
					@IP as '@IP'
				FROM #tblCustLog t1
				WHERE t1.custid = t.custid
				FOR XML PATH('R'), ROOT ('ROOT')
				) as LogAdd
			FROM #tblCustLog t
		)
		INSERT INTO dbo.UserLog_RunSP(UserID,CustID,ActionID,TrackingValue,Duration)
		SELECT @UserID,CustID,@ActionID,LogAdd,@Duration
		FROM Tmp
		
		DROP TABLE #tblCustLog
	END
	ELSE IF @ActionID=1190
	BEGIN
		INSERT INTO #tblCustLog(custid,SportType)
		SELECT	t.c.value('@CustID[1]','int'),
				t.c.value('@SportType[1]','tinyint')
		FROM @xml.nodes('Root/r')as t(c)
		OPTION (OPTIMIZE FOR (@xml = NULL))

		;WITH Tmp AS (
			SELECT DISTINCT 
				custid,
				(SELECT 
					SportType	AS '@SportType',
					@IP as '@IP'
				FROM #tblCustLog t1
				WHERE t1.custid = t.custid
				FOR XML PATH('R'), ROOT ('ROOT')
				) as LogRemove
			FROM #tblCustLog t
		)
		INSERT INTO dbo.UserLog_RunSP(UserID,CustID,ActionID,TrackingValue,Duration)
		SELECT @UserID,CustID,@ActionID,LogRemove,@Duration
		FROM Tmp
		
		DROP TABLE #tblCustLog
	END
	ELSE IF @ActionID IN (1191, 1192)	--auto update dangerlevel 
	BEGIN		
		INSERT INTO #tblCustLog(custid,SportType,newlevel,oldlevel,Winloss,IsUpdatedByPA)
		SELECT t.c.value('@id[1]','int'),
				t.c.value('@sport[1]','tinyint'),
				t.c.value('@newlevel[1]','tinyint'),
				t.c.value('@oldlevel[1]','tinyint'),
				CASE WHEN ISNUMERIC(t.c.value('@wl[1]','varchar(10)'))=0 THEN NULL ELSE t.c.value('@wl[1]','money') END,
				t.c.value('@IsPA[1]','bit')
		FROM @xml.nodes('Root/r')as t(c)
		OPTION (OPTIMIZE FOR (@xml = NULL))

		;WITH Tmp AS (
		SELECT custid,
			(SELECT 
				CASE WHEN SportType = 0 THEN 'Soccer' 
					 WHEN SportType = 1 THEN 'Basketball' END as '@SportType',
				NewLevel			as '@DangerLevel',
				ISNULL(Winloss,'')	as '@Winloss',
				IsUpdatedByPA		as '@IsUpdatedByPA',
				@IP					as '@IP'
			FROM #tblCustLog t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R')
			) as LogNew,
			(SELECT 
				CASE WHEN SportType = 0 THEN 'Soccer' 
					 WHEN SportType = 1 THEN 'Basketball' END as '@SportType',
				OldLevel			as '@DangerLevel',
				ISNULL(Winloss,'')	as '@Winloss',
				@IP					as '@IP'
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
	ELSE IF @ActionID IN (1193, 1194, 1195, 1196)	-- manual update  dangerlevel
	BEGIN
		INSERT INTO #tblCustLog(custid,SportType,newflag,oldflag,newlevel,oldlevel)
		SELECT t.c.value('@id[1]','int'),
				t.c.value('@sport[1]','tinyint'),
				t.c.value('@newflag[1]','bit'),
				t.c.value('@oldflag[1]','bit'),
				t.c.value('@newlevel[1]','tinyint'),
				t.c.value('@oldlevel[1]','tinyint')
		FROM @xml.nodes('Root/r')as t(c)
		OPTION (OPTIMIZE FOR (@xml = NULL))
		
		;WITH Tmp AS (
		SELECT custid,
			(SELECT 
				CASE WHEN SportType = 0 THEN 'Soccer' 
					 WHEN SportType = 1 THEN 'Basketball' END as '@SportType',
				NewLevel	as '@DangerLevel',
				NewFlag		as '@ManualDangerLevel',
				@IP			as '@IP'
			FROM #tblCustLog t1
			WHERE t1.custid = t.custid
			FOR XML PATH('R')
			) as LogNew,
			(SELECT 
				CASE WHEN SportType = 0 THEN 'Soccer' 
					 WHEN SportType= 1 THEN 'Basketball' END as '@SportType',
				OldLevel	as '@DangerLevel',
				OldFlag		as '@ManualDangerLevel',
				@IP			as '@IP'
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
END