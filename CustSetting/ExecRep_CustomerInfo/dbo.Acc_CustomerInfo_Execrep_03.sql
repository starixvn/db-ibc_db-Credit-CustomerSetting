/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_03]  
	@custid				INT = 0,  
	@roleid				TINYINT = 0,
	@DangerType			TINYINT = 0,
	@DangerLevel		INT = 0,
	@oddsgroup			VARCHAR(10) = '',
	@CategoryList		VARCHAR(MAX) = '',
	@CustList			VARCHAR(MAX)='',
	@isVip				BIT = 0,
	@userID 			INT = 0, 
	@mode				VARCHAR(50) = 'DangerStatus'
AS  
/*  

Created: Winnie  
Date: 2017-11-24  
Task: Update Danger, Danger2, Danger3 fields [RedmineID:#86627]
DB: DBCUST/CustDB  

Revisions:  
	- 20171124@Winnie: Update Danger, Danger2, Danger3 fields , and write log content [RedmineID:#86627]
	- 20190925@Johnson: Allow danger status for Super and Master levels [redmine:#120056]
	- 20200213@Johnson: update VIP status for deposit [redmine:#128077]
	- 20200903@Johnson: service update customerclass [redmine:#140809]
	- 20200907@Johnson: Set NULL incase customerclass = -1 [redmine:#140809]
	- 20200917@Johnson: change #tblCust to ignore error when update VIP status [redmine:#141848]
	- 20210326@Johnson: CTS service update Danger level [Redmine:#86627]
	- 20210419@Johnson: CTS update category for problem account [redmine:#153617]
	- 20210608@Johnson: change source PA for deposit [redmine:#155692]
	- 20210712@Johnson: Update oddsgroup for licensee [redmine:#157702]
	- 20210820@Johnson: Add 2 new Dangerous types for Basketball & Esports [redmine:#159551]
	- 20211013@Johnson: Auto job update danger level for Saba [redmine:#161351]
	- 20211021@Johnson: Auto add & remove ABI Danger Level [redmine:#162834]
	- 20220228@Johnson: add new category for good/bad robot[redmine:#167726]
	- 20220329@Johnson: Add new category/class for PA Probation [redmine:#170468]
	- 20220406@Elodie: Apply STRING_SPLIT() instead of strSplit UDF [Redmine: #168783]
	- 20220526@Johnson: Add OldCustomerClass column for CustCategoryHistory [redmine:#167819]
	- 20220602@Johnson: remove ProblemAccount when update vip customer [redmine:#173357]
	- 20220823@Tacy: update BA member's Danger follow upline [redmine:#176518]
	- 20220831@Johnson: Update customer class by sport [redmine:#176992]
	- 20221123@Johnson: update CC for non-sports [redmine: #179500] 
	- 20230614@Johnson: update CC for Saba Virtual Soccer, Saba Virtual Basketball [redmine: #185320] 
	- 20240426@Johnson: Update CC By Sports for Special Class [redmine:#201360]
	- 20240904@Winfred: Update SportID of CustomerClassSetting Feature name [redmine:#210321]
	- 20240716@Johnson: Apply In-house Replication for Customer Setting [redmine:#207025]
	- 20241008@Winfred: [CTS] - Customer Classification - Classify Agent [redmine:#185799]
Parameter's Explanation: 
	@custid: Custid of members will be updated,
	@DangerType: type of danger,
			1: Soccer Live
			2: Soccer Non-Live
			3: OtherSports
	@DangerLevel: new danger level value
*/
BEGIN
	SET NOCOUNT ON 
	/*region1: Declare params and check table replicated */
	IF @mode = 'DangerStatus'
	BEGIN		
		IF (dbo.f_CheckRepTable('custinfo') = 0) RETURN
		DECLARE @tempCust TABLE(CustID INT, 
								ID	INT IDENTITY (1,1),
								PRIMARY KEY CLUSTERED (ID))
		
		DECLARE @StartRow	INT, 
				@MaxRow		INT,
				@Threshold	INT, 
				@StopRow INT	
		
		SET @StartRow=1
		SET @Threshold=5000
		
		/*region2: get downlines */
		-- Get downline of super
		IF @roleid = 4  
		BEGIN	

			INSERT INTO @tempCust(CustID)
			SELECT CustID
			FROM custInfo WITH(NOLOCK)
			WHERE srecommend=@custid		
			  
		END  
		--Get downline of master
		ELSE IF @roleid = 3  
		BEGIN

			INSERT INTO @tempCust(CustID)
			SELECT CustID
			FROM custInfo WITH(NOLOCK)
			WHERE mrecommend=@custid	
				
		END 
		 -- Get downline of agent
		ELSE IF @roleid = 2  
		BEGIN  

			INSERT INTO @tempCust(CustID)
			SELECT CustID
			FROM custInfo WITH(NOLOCK)
			WHERE recommend=@custid
			
		END	
		
		/*region3: update danger */	
		SET @MaxRow = (SELECT MAX(ID) FROM @tempCust)
				
		IF	@Threshold >= @MaxRow
			SET	@Threshold = @MaxRow
				
		SET @StopRow = @Threshold
		
		-- If danger for Soccer Live
		IF @DangerType = 1 
		BEGIN 
			WHILE (0 = 0)
			BEGIN	
				IF(@DangerLevel<>0)
				BEGIN
					UPDATE c
					SET danger = @DangerLevel	
					FROM custinfo c WITH(UPDLOCK,ROWLOCK) 
						INNER JOIN @tempCust t ON c.CustID=t.CustID
					WHERE	ID >= @StartRow 
						AND	ID <= @StopRow								
				END
				ELSE
				BEGIN
					UPDATE c
					SET danger = @DangerLevel 
					FROM custinfo c WITH(UPDLOCK,ROWLOCK) 
						INNER JOIN @tempCust t ON c.CustID=t.CustID
					WHERE	ID >= @StartRow 
						AND	ID <= @StopRow								
				END
				
				IF	@StopRow = @MaxRow 
					BREAK
						
				SET	@StartRow = @StopRow + 1
						
				SET	@StopRow = 1 + @StopRow + @Threshold
						
				IF	@StopRow >= @MaxRow
					SET	@StopRow = @MaxRow
			END			
		END
		-- If danger for Soccer Non-Live
		ELSE IF  @DangerType = 2
		BEGIN 		
			WHILE (0 = 0)
			BEGIN	
				UPDATE c
					SET danger2 = @DangerLevel,
						danger4 = CASE WHEN @DangerLevel = 11 THEN 15
									WHEN @DangerLevel = 16 THEN 49 
									ELSE danger4 END
				FROM custinfo c WITH(UPDLOCK,ROWLOCK) 
					INNER JOIN @tempCust t ON c.CustID=t.CustID
				WHERE	ID >= @StartRow 
					AND	ID <= @StopRow	
		
				IF	@StopRow = @MaxRow 
					BREAK
						
				SET	@StartRow = @StopRow + 1
						
				SET	@StopRow = 1 + @StopRow + @Threshold;
						
				IF	@StopRow >= @MaxRow
					SET	@StopRow = @MaxRow
					
			END;			
		END
		-- If danger for Other sports
		ELSE IF  @DangerType = 3
		BEGIN 	
			WHILE (0 = 0)
			BEGIN	
					
				UPDATE c
					SET danger3 = @DangerLevel	
				FROM custinfo c WITH(UPDLOCK,ROWLOCK) 
					INNER JOIN @tempCust t ON c.CustID=t.CustID
				WHERE	ID >= @StartRow 
					AND	ID <= @StopRow	
		
				IF	@StopRow = @MaxRow 
					BREAK;
						
				SET	@StartRow = @StopRow + 1
						
				SET	@StopRow = 1 + @StopRow + @Threshold
						
				IF	@StopRow >= @MaxRow
					SET	@StopRow = @MaxRow					
			END
		END
		-- If danger for Basketball
		ELSE IF  @DangerType = 4
		BEGIN 	
			WHILE (0 = 0)
			BEGIN	
					
				UPDATE c
					SET danger4 = @DangerLevel	
				FROM custinfo c WITH(UPDLOCK,ROWLOCK) 
					INNER JOIN @tempCust t ON c.CustID=t.CustID
				WHERE	ID >= @StartRow 
					AND	ID <= @StopRow	
		
				IF	@StopRow = @MaxRow 
					BREAK;
						
				SET	@StartRow = @StopRow + 1
						
				SET	@StopRow = 1 + @StopRow + @Threshold
						
				IF	@StopRow >= @MaxRow
					SET	@StopRow = @MaxRow					
			END
		END
		-- If danger for Esports
		ELSE IF  @DangerType = 5
		BEGIN 	
			WHILE (0 = 0)
			BEGIN	
					
				UPDATE c
					SET danger5 = @DangerLevel	
				FROM custinfo c WITH(UPDLOCK,ROWLOCK) 
					INNER JOIN @tempCust t ON c.CustID=t.CustID
				WHERE	ID >= @StartRow 
					AND	ID <= @StopRow	
		
				IF	@StopRow = @MaxRow 
					BREAK;
						
				SET	@StartRow = @StopRow + 1
						
				SET	@StopRow = 1 + @StopRow + @Threshold
						
				IF	@StopRow >= @MaxRow
					SET	@StopRow = @MaxRow					
			END
		END
	END	
	ELSE IF @mode = 'CTSUpdDanger'
	BEGIN
		IF (dbo.f_CheckRepTable('custinfo') = 0) RETURN
		
		CREATE TABLE #tblCustDanger (custid INT, Danger TINYINT, isFinished BIT DEFAULT(0))
		DECLARE @tmpCustDanger TABLE (custid INT PRIMARY KEY, Danger TINYINT)
		
		DECLARE @xmlCustDanger XML = CAST (@CustList as XML)
		
		INSERT INTO #tblCustDanger (custid, Danger)
		SELECT t.c.value('@id[1]','int'),
			t.c.value('@l[1]','int')
		FROM @xmlCustDanger.nodes('Root/r')as t(c)		
		
		WHILE (1=1)
		BEGIN
			UPDATE TOP (5000) t
			SET isFinished = 1
			OUTPUT DELETED.custid, DELETED.Danger INTO @tmpCustDanger(custid,Danger)
			FROM #tblCustDanger t
			WHERE isFinished = 0
						
			IF @@ROWCOUNT = 0
				BREAK;
				
			UPDATE c
			SET c.Danger = CASE WHEN @DangerType = 1 THEN t.Danger ELSE c.Danger END,
				c.Danger2 = CASE WHEN @DangerType = 2 THEN t.Danger ELSE c.Danger2 END,
				c.Danger3 = CASE WHEN @DangerType = 3 THEN t.Danger ELSE c.Danger3 END
			FROM custInfo c WITH(UPDLOCK,ROWLOCK)
				INNER JOIN @tmpCustDanger t ON c.custid = t.custid
				
			DELETE @tmpCustDanger
		END
		
		DROP TABLE #tblCustDanger
	END	
	ELSE IF @mode = 'CustomerClass'
	BEGIN
		IF (dbo.f_CheckRepTable('custinfo') = 0) RETURN
		IF OBJECT_ID('Dep_Custsuper') IS NULL RETURN
		
		CREATE TABLE #tblCustClass (custid INT,RoleID TINYINT, CustomerClass INT, OldCustomerClass SMALLINT, CategoryID INT, isDeposit BIT, isFinished BIT DEFAULT(0))
		DECLARE @tmp TABLE (custid INT,RoleID TINYINT, CustomerClass INT, OldCustomerClass SMALLINT, CategoryID INT, isDeposit BIT)
		DECLARE @tblCategory TABLE (CategoryID INT)
		
		DECLARE @xml XML = CAST (@CustList as XML),
				@xmlCategory XML = CAST (@CategoryList as XML),
				@cnt INT
		
		INSERT INTO @tblCategory (CategoryID)
		SELECT t.c.value('.','int')			
		FROM @xmlCategory.nodes('Root/c')as t(c)
		
		INSERT INTO #tblCustClass (custid, CustomerClass, CategoryID)
		SELECT t.c.value('@id[1]','int'),
			t.c.value('@c[1]','int'),
			t.c.value('@t[1]','int')
		FROM @xml.nodes('Root/r')as t(c)		
		
		UPDATE t
		SET isDeposit = CASE WHEN s.custid IS NULL THEN 0 ELSE 1 END,
			OldCustomerClass = ci.CustomerClass,
			t.RoleID = ci.roleid
		FROM #tblCustClass t
			INNER JOIN custinfo ci WITH(NOLOCK) ON t.custid = ci.custid
			LEFT JOIN Dep_Custsuper s WITH(NOLOCK) ON ci.srecommend = s.custid
			
		WHILE (1=1)
		BEGIN
			UPDATE TOP (5000) t
			SET isFinished = 1
			OUTPUT DELETED.custid, DELETED.CustomerClass, DELETED.OldCustomerClass, DELETED.CategoryID, DELETED.isDeposit, DELETED.RoleID
			INTO @tmp(custid,CustomerClass,OldCustomerClass,CategoryID,isDeposit,RoleID)
			FROM #tblCustClass t
			WHERE isFinished = 0
			
			SELECT @cnt = @@ROWCOUNT
			
			UPDATE c
			SET c.CustomerClass = NULLIF(t.CustomerClass,-1)
			FROM custInfo c WITH(UPDLOCK,ROWLOCK)
				INNER JOIN @tmp t ON c.custid = t.custid AND t.roleid = 1
			
			IF (dbo.f_CheckRepTable('ProblemAccountClassification') = 1)  
			BEGIN			
				MERGE ProblemAccountClassification as Target
				USING @tmp as Source
				ON Target.custid = Source.custid 
				WHEN MATCHED AND (ISNULL(source.CustomerClass,0) IN (SELECT CategoryID FROM @tblCategory))
				THEN UPDATE SET ModifiedDate = GETDATE()
				WHEN MATCHED AND ISNULL(source.CustomerClass,0) NOT IN (SELECT CategoryID FROM @tblCategory)
				THEN DELETE 
				WHEN NOT MATCHED BY TARGET AND (ISNULL(source.CustomerClass,0) IN (SELECT CategoryID FROM @tblCategory))
				THEN INSERT(custid,isReviewed,ModifiedDate) VALUES(Source.custid,0,GETDATE());	
			END
						
			IF EXISTS ( SELECT 1 FROM sys.tables WHERE Name='CustCategoryHistory')
			BEGIN
				INSERT INTO CustCategoryHistory(custid,CategoryID,CustomerClass,OldCustomerClass,CreatedDate)
				SELECT custid,CategoryID,CustomerClass,OldCustomerClass,GETDATE()
				FROM @tmp 
				WHERE (CustomerClass IN (SELECT CategoryID FROM @tblCategory))
					AND isDeposit = 0
					AND CategoryID > 0
					AND RoleID = 1
			END
			
			IF @cnt < 5000
				BREAK;
				
			DELETE @tmp
		END
		
		DROP TABLE #tblCustClass
	END
	ELSE IF @mode = 'CustomerClassBySport'
	BEGIN
		DECLARE @xmlCustClassSport XML = CAST (@CustList as XML)
		
		IF (dbo.f_CheckRepTable('custinfo') = 1) 
		BEGIN
			CREATE TABLE #tblCustClassSport (custid INT PRIMARY KEY, CC1 SMALLINT, CC2 SMALLINT, CC43 SMALLINT, CC99 SMALLINT, CC229 SMALLINT, CC145 SMALLINT, CC912 SMALLINT, isFinished BIT DEFAULT(0))
			DECLARE @tmpCustClassSport TABLE (custid INT PRIMARY KEY, CC1 SMALLINT, CC2 SMALLINT, CC43 SMALLINT, CC99 SMALLINT, CC229 SMALLINT, CC145 SMALLINT, CC912 SMALLINT)
				
			;WITH T AS (
				SELECT t.c.value('@id[1]','int') custid,
					t.c.value('@s[1]','smallint') sporttype,
					t.c.value('@c[1]','smallint') customerclass
				FROM @xmlCustClassSport.nodes('Root/r')as t(c)
			)
			INSERT INTO #tblCustClassSport (custid, CC1, CC2, CC43, CC99, CC229)
			SELECT custid, [1] as CC1, [2] as CC2, [43] as CC43, [99] as CC99, [229] as CC229
			FROM T 
			PIVOT (SUM(customerclass) 
			FOR sporttype IN ([1],[2],[43],[99],[229])
			)as pvt	
			
			WHILE (1=1)
			BEGIN
				UPDATE TOP (5000) t
				SET isFinished = 1
				OUTPUT DELETED.custid, DELETED.CC1, DELETED.CC2, DELETED.CC43, DELETED.CC99, DELETED.CC229
				INTO @tmpCustClassSport(custid,CC1,CC2,CC43,CC99,CC229)
				FROM #tblCustClassSport t
				WHERE isFinished = 0
				
				IF @@ROWCOUNT = 0
					BREAK;
					
				UPDATE c
				SET c.CCSoccer = CASE WHEN t.CC1 IS NOT NULL THEN NULLIF(t.CC1,-1) ELSE c.CCSoccer END,
					c.CCBasketball = CASE WHEN t.CC2 IS NOT NULL THEN NULLIF(t.CC2,-1) ELSE c.CCBasketball END,
					c.CCEsports = CASE WHEN t.CC43 IS NOT NULL THEN NULLIF(t.CC43,-1) ELSE c.CCEsports END,
					c.CCOtherSports = CASE WHEN t.CC99 IS NOT NULL THEN NULLIF(t.CC99,-1) ELSE  c.CCOtherSports END,
					c.CCNonSports = CASE WHEN t.CC229 IS NOT NULL THEN NULLIF(t.CC229,-1) ELSE c.CCNonSports END				
				FROM custInfo c WITH(UPDLOCK,ROWLOCK)
					INNER JOIN @tmpCustClassSport t ON c.custid = t.custid
					
				DELETE @tmpCustClassSport	
			END	
			
			DROP TABLE #tblCustClassSport
		END
		
		IF (dbo.f_CheckRepTable('CustomerClassSetting') = 1) 
		BEGIN
			CREATE TABLE #tblCustClassSport2 (custid INT, SportType SMALLINT, CustomerClass SMALLINT, isFinished BIT DEFAULT(0) PRIMARY KEY(custid,sporttype))
			DECLARE @tmpCustClassSport2 TABLE (custid INT, SportType SMALLINT, CustomerClass SMALLINT PRIMARY KEY(custid,sporttype))
			
			;WITH T AS (
				SELECT t.c.value('@id[1]','int') custid,
					t.c.value('@s[1]','smallint') sporttype,
					t.c.value('@c[1]','smallint') customerclass
				FROM @xmlCustClassSport.nodes('Root/r')as t(c)
			)
			INSERT INTO #tblCustClassSport2(custid,sporttype,customerclass)
			SELECT custid, sb.sporttype ,NULLIF(customerclass,-1)
			FROM T t
				CROSS APPLY dbo.f_CTSMappingSportType (t.sporttype) sb 
			WHERE t.sporttype NOT IN (1,2,43,99,229)
			
			WHILE (1=1)
			BEGIN
				UPDATE TOP (5000) t
				SET isFinished = 1
				OUTPUT DELETED.custid, DELETED.sporttype, DELETED.customerclass
				INTO @tmpCustClassSport2(custid,sporttype,customerclass)
				FROM #tblCustClassSport2 t
				WHERE isFinished = 0
				
				IF @@ROWCOUNT = 0
					BREAK;
					
				MERGE CustomerClassSetting as Target
				USING @tmpCustClassSport2 as Source
				ON Target.custid = Source.custid 
					AND Target.SportType = Source.SportType
				WHEN MATCHED 
				THEN UPDATE SET Target.CustomerClass = Source.CustomerClass,
								Target.ModifiedDate = GETDATE()
				WHEN NOT MATCHED BY TARGET
				THEN INSERT(custid,sporttype,customerclass,ModifiedDate) VALUES(Source.custid,source.sporttype,source.customerclass,GETDATE());		
				
				DELETE @tmpCustClassSport2
			END	

			DROP TABLE #tblCustClassSport2		
		END
	END
	ELSE IF @mode = 'UpdateOddsGroup'
	BEGIN
		IF (dbo.f_CheckRepTable('customer') = 0) RETURN
		
		DECLARE @tmpCustOddsGroup TABLE (custid INT PRIMARY KEY)
		
		INSERT INTO @tmpCustOddsGroup(custid)
		SELECT value
		FROM STRING_SPLIT(@CustList,',')
		
		UPDATE customer WITH(UPDLOCK,ROWLOCK)
		SET ugroup = @oddsgroup
		WHERE custid IN (SELECT custid FROM @tmpCustOddsGroup)		
	END
	ELSE IF @mode = 'SabaDangerLevel'
	BEGIN
		IF (dbo.f_CheckRepTable('custinfo') = 0) RETURN
		
		CREATE TABLE #tblCustSaba (custid INT PRIMARY KEY, DangerLevel BIGINT, isFinished BIT DEFAULT(0))
		DECLARE @tmpSaba TABLE (custid INT PRIMARY KEY, DangerLevel BIGINT)
		
		DECLARE @xmlSaba XML = CAST (@CustList as XML)				
		
		INSERT INTO #tblCustSaba (custid, DangerLevel)
		SELECT t.c.value('@id[1]','int'),
			t.c.value('@value[1]','bigint')			
		FROM @xmlSaba.nodes('Root/r')as t(c)	

		WHILE (1=1)
		BEGIN
			UPDATE TOP (5000) t
			SET isFinished = 1
			OUTPUT DELETED.custid, DELETED.DangerLevel
			INTO @tmpSaba(custid,DangerLevel)
			FROM #tblCustSaba t
			WHERE isFinished = 0
			
			IF @@ROWCOUNT = 0
				BREAK;
			
			UPDATE c
			SET c.DangerLevel = t.DangerLevel
			FROM custInfo c WITH(UPDLOCK,ROWLOCK)
				INNER JOIN @tmpSaba t ON c.custid = t.custid
				
			DELETE @tmpSaba
		END		
	END	
END
