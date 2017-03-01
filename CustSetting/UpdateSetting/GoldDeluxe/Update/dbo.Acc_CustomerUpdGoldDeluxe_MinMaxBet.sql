ALTER PROCEDURE [dbo].[Acc_CustomerUpdGoldDeluxe_MinMaxBet]
	@custid		INT,
	@userid		INT,
	@SubAccID	INT = 0, --Sub-AccountID	
	@StakeLevel	VARCHAR(4000),
	@Language	VARCHAR(2) = 'E',
	@IP			VARCHAR(15)='',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(500) = '' OUTPUT 
AS 
	/*
		Created: Johnson
		Date: 2015-04-23
		Task: Update bet settings for Gold Deluxe
		DB: DBTXN/CustDB
		
		Revisions:
			- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST, Change Age_CustomerSelCheckBelonging to Age_CustomerSelCheckBelongingByCustID, call bettype by link server)
			- 20151001@Johnson: check limit downlines before updating 
			- 20151120@Helen: Improve the performance of the setting [Redmine: 45056] 
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
		Parameter's Explanation:
			* @StakeLevel = <ROOT>
								<Row ID="1701" Stake="1,2,3,4"/>
								<Row ID="1702" Stake="1,2,3,4"/>
							</ROOT>
								
	*/
BEGIN 
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
			,@roleid INT
			,@GameTypeID INT
			,@StakeLevelList VARCHAR(100)
			,@StakeLevelList_Old VARCHAR(100)
			
	DECLARE  @srecommend INT
			,@mrecommend INT
			,@recommend  INT
			,@UplineStakeLevelList VARCHAR(100)
			,@invalidStakeLevelID INT
			--store xml bet settings for downlines when correct settings			
			,@BetSettings VARCHAR(MAX)
			--log data
			,@LogStakeLevel VARCHAR(500)
			,@LogStakeLevel_Old VARCHAR(500)
			,@LogSPData VARCHAR(MAX)
			,@LogSPData_Old VARCHAR(MAX)
	
	CREATE TABLE #CustGameTypeDownlines (
				CustID INT 
				,DirectUplineID INT		
				,roleid TINYINT
				,GameTypeID INT
				,StakeLevelList varchar(100)
				,StakeLevelList_new varchar(100)
				,StakeLevelList_Upline VARCHAR(100)
				, PRIMARY KEY CLUSTERED (CustID,GameTypeID)
		)
		
	SET @startRun = GETDATE()
	
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN
	
	-- ***Check Downline Belonging***		
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,		
		@roleid = @roleid OUTPUT
		if (@roleid = 0) return
	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	---- Checking total downlines before UPDATEs 
	EXEC Acc_CustomerSelCheckAllowedDownlines    
		@custid		= @custid,
        @roleid		= @roleid,
        @isExecRep	= 1,
        @isUpdatePT = 1,
        @Sporttype	= 1,
        @Language	= 'E',
        @ErrMsg		= @ErrMsg	OUTPUT,
        @ErrCode	= @ErrCode	OUTPUT
        
    IF @ErrCode <> 0 
        RETURN 
	
	CREATE TABLE #tmpStake (ID INT IDENTITY (1,1), GameTypeID INT, StakeLevelList VARCHAR(100), isValidated BIT DEFAULT(0), PRIMARY KEY CLUSTERED (GameTypeID))
	
	DECLARE @DocHandler INT
	
	-- For read xml					
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @StakeLevel
	
	INSERT INTO #tmpStake(
					GameTypeID,
					StakeLevelList
				)
		SELECT
			Data.ID,
			Data.Stake			
		FROM OPENXML (@DocHandler, '/ROOT/Row',1) 
		WITH (
			ID			INT,
			Stake		VARCHAR(100)	
		) AS Data

	
	EXEC sp_xml_removedocument @DocHandler
	-- end read xml
	
	SELECT @srecommend = srecommend
			,@mrecommend = mrecommend
			,@recommend = recommend
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
			
	--validate stake level
	SELECT @roleid
	  
	--validate stake level  
	IF @roleid < 4  
	BEGIN  
		WHILE (1=1)  
		BEGIN  
			SELECT TOP (1) @GameTypeID = GameTypeID,  
			 @StakeLevelList = StakeLevelList   
			FROM #tmpStake  
			WHERE isValidated = 0  

			IF @@ROWCOUNT = 0 BREAK;  

			IF @RoleID = 3  
			BEGIN  
				SELECT @UplineStakeLevelList = StakeLevelList  
				FROM CustGameType with(nolock)   
				WHERE CustID = @srecommend  
				  AND GameTypeID = @GameTypeID   
			END           
			ELSE IF @RoleID = 2  
			BEGIN  
				SELECT @UplineStakeLevelList = StakeLevelList  
				FROM CustGameType with(nolock)  
				WHERE CustID = @Mrecommend  
				  AND GameTypeID = @GameTypeID  
			END           
			ELSE IF @RoleID = 1  
			BEGIN  
				SELECT @UplineStakeLevelList = StakeLevelList  
				FROM CustGameType with(nolock)   
				WHERE CustID = @recommend  
				  AND GameTypeID = @GameTypeID  
			END  

			SELECT TOP 1 @invalidStakeLevelID = ISNULL(Val,0)    
			FROM dbo.strSplit(@StakeLevelList,',')  
			WHERE Val not in (SELECT Val FROM dbo.strSplit(@UplineStakeLevelList,','))  

			IF @invalidStakeLevelID > 0  
			BEGIN  
				--Return Data  
				SELECT @ErrCode = 1000  
				BEGIN TRY  
					 SELECT @ErrMsg = CASE @Language   
							WHEN 'E' THEN 'This user''s upline does not have Stake Level for '   
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10031,@Language)  
						   END + typenamee   
					 FROM DBAGE.bodb02.dbo.bettype WITH(NOLOCK)  
					 WHERE TypeID = @GameTypeID  
				END TRY  
				BEGIN CATCH  
					 SELECT @ErrMsg = CASE @Language   
							WHEN 'E' THEN 'This user''s upline does not have Stake Level for '   
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10031,@Language)  
						   END + typenamee   
					 FROM DBTXN.bodb02.dbo.bettype WITH(NOLOCK)  
					 WHERE TypeID = @GameTypeID  
				END CATCH   
				RETURN   
			END   

			UPDATE #tmpStake  
			SET isValidated = 1  
			WHERE GameTypeID = @GameTypeID  

		END  
	END  
	
	--end validate
	--update stake level
	BEGIN
		-- Downline Processing: only processing if being different.
		DELETE T
		FROM #tmpStake T
			JOIN CustGameType cg WITH(NOLOCK)  ON T.GameTypeID = cg.GameTypeID
		WHERE cg.CustID = @custid AND T.StakeLevelList = cg.StakeLevelList
		
		SELECT CG.GameTypeID,CG.StakeLevelList AS StakeLevelList_old , (SELECT * FROM dbo.f_StakeLevelcorrectString (cg.StakeLevelList,s.StakeLevelList)) AS ExcludedLevel--string,excludeString()
		INTO  #StakeLevelList_Excluded -- Get excluded level compared with old 
		FROM CustGameType CG WITH (NOLOCK)
			JOIN #tmpStake S ON CG.GameTypeID = S.GameTypeID
		WHERE custid = @custid 
		-- update this customer
		UPDATE	C with(UPDLOCK,ROWLOCK)
			SET	StakeLevelList = S.StakeLevelList
		FROM CustGameType C
			INNER JOIN #tmpStake S ON C.GameTypeID = S.GameTypeID
		WHERE	CustID = @CustID
		
		IF EXISTS (SELECT 1 FROM #tmpStake) AND @roleid IN (4,3,2)
		BEGIN
			/* Starting Update downline process */
			IF @roleid = 4
			BEGIN
				INSERT INTO #CustGameTypeDownlines (CustID,DirectUplineID, roleid ,GameTypeID ,StakeLevelList,StakeLevelList_new,StakeLevelList_Upline)
				SELECT ci.custid,
					  CASE 
							WHEN ci.roleid = 2 THEN mrecommend
							WHEN ci.roleid = 1 THEN recommend 	
					  END AS DirectUplineID,		
					 ci.roleid,S.GameTypeID,cg.StakeLevelList,cg.StakeLevelList,S.StakeLevelList AS StakeLevelList_Upline
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustGameType cg WITH(NOLOCK) ON ci.custid = cg.custid
					INNER JOIN #tmpStake S ON S.GameTypeID = CG.GameTypeID 
				WHERE ci.srecommend = @custid AND ci.roleid IN (1,2,3)
			END
			ELSE IF @roleid = 3
			BEGIN
				INSERT INTO #CustGameTypeDownlines (CustID,DirectUplineID,roleid ,GameTypeID ,StakeLevelList,StakeLevelList_new,StakeLevelList_Upline)
				SELECT ci.custid,
					  CASE 
							WHEN ci.roleid = 2 THEN mrecommend
							WHEN ci.roleid = 1 THEN recommend 	
					  END AS DirectUplineID,
					ci.roleid,S.GameTypeID,cg.StakeLevelList,cg.StakeLevelList,S.StakeLevelList AS StakeLevelList_Upline
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustGameType cg WITH(NOLOCK) ON ci.custid = cg.custid
					INNER JOIN #tmpStake S ON S.GameTypeID = CG.GameTypeID 
				WHERE ci.mrecommend = @custid AND ci.roleid IN (1,2)
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO #CustGameTypeDownlines (CustID,DirectUplineID, roleid ,GameTypeID ,StakeLevelList,StakeLevelList_new,StakeLevelList_Upline)
				SELECT ci.custid,ci.recommend DirectUplineID,
					 ci.roleid,S.GameTypeID,cg.StakeLevelList,CG.StakeLevelList,S.StakeLevelList AS StakeLevelList_Upline
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustGameType cg WITH(NOLOCK) ON ci.custid = cg.custid
					INNER JOIN #tmpStake S ON S.GameTypeID = CG.GameTypeID 
				WHERE ci.recommend = @custid AND ci.roleid = 1
			END	
			
			-- Remove level excluded
			UPDATE T
				SET StakeLevelList_new = (SELECT * FROM dbo.f_StakeLevelcorrectString (T.StakeLevelList,E.ExcludedLevel))
			FROM #CustGameTypeDownlines T
				INNER JOIN #StakeLevelList_Excluded E ON T.GameTypeID = E.GameTypeID
			WHERE T.StakeLevelList_new <> '' 
			
			-- Correct downline
			IF @roleid = 4
			BEGIN
				-- Role = 3
				UPDATE T
					SET StakeLevelList_new = T.StakeLevelList_Upline
				FROM #CustGameTypeDownlines T
				WHERE T.StakeLevelList_new = '' AND T.roleid = 3
				
				-- For RoleID in (1,2) - get lowest if has no value
				UPDATE T
					SET StakeLevelList_new = T1.DownlineStakeLevelList_new
				FROM #CustGameTypeDownlines T
					INNER JOIN #CustGameTypeDownlines Upline ON t.DirectUplineID = Upline.CustID 
															AND T.GameTypeID =Upline.GameTypeID AND Upline.StakeLevelList_new <> ''			 
					
					CROSS APPLY(SELECT TOP 1 ISNULL(CONVERT(varchar(20),SL.StakeLevelID),'') AS DownlineStakeLevelList_new
								FROM (SELECT CAST(val AS INT) AS val
									  FROM dbo.strSplit(Upline.StakeLevelList_new,','))  cd
										INNER JOIN dbo.StakeLevel SL WITH(NOLOCK) ON cd.val = sl.StakeLevelID
									 WHERE MinStake <> 0 AND MaxStake <> 0
									ORDER BY minstake , maxstake
								) T1 -- Direct Upline
				WHERE t.roleid = 2 AND T.StakeLevelList_new = ''
				
				UPDATE T
					SET StakeLevelList_new = T1.DownlineStakeLevelList_new
				FROM #CustGameTypeDownlines T
					INNER JOIN #CustGameTypeDownlines Upline ON t.DirectUplineID = Upline.CustID 
																AND T.GameTypeID =Upline.GameTypeID AND Upline.StakeLevelList_new <> ''			 			 
					
					CROSS APPLY(SELECT TOP 1 ISNULL(CONVERT(varchar(20),cd.val),'') AS DownlineStakeLevelList_new
								FROM (SELECT CAST(val AS INT) AS val
									  FROM dbo.strSplit(Upline.StakeLevelList_new,','))  cd
										INNER JOIN dbo.StakeLevel SL WITH(NOLOCK) ON cd.val = sl.StakeLevelID
									 WHERE MinStake <> 0 AND MaxStake <> 0
									ORDER BY minstake , maxstake
								) T1 -- Direct Upline
				WHERE t.roleid = 1 AND T.StakeLevelList_new = ''
			
			END				
			ELSE IF @roleid = 3
			BEGIN
				UPDATE T
				SET StakeLevelList_new = T1.DownlineStakeLevelList_new
				FROM #CustGameTypeDownlines T
					CROSS APPLY(SELECT TOP 1 ISNULL(CONVERT(varchar(20),SL.StakeLevelID),'') AS DownlineStakeLevelList_new
								FROM (SELECT CAST(val AS INT) AS val
									  FROM dbo.strSplit(T.StakeLevelList_Upline,','))  cd
										INNER JOIN dbo.StakeLevel SL WITH(NOLOCK) ON cd.val = sl.StakeLevelID
									 WHERE MinStake <> 0 AND MaxStake <> 0
									ORDER BY minstake , maxstake
								) T1 -- Direct Upline
				WHERE t.roleid = 2 AND T.StakeLevelList_new = ''
			
				UPDATE T
				SET StakeLevelList_new = T1.DownlineStakeLevelList_new
				FROM #CustGameTypeDownlines T
					INNER JOIN #CustGameTypeDownlines Upline ON t.DirectUplineID = Upline.CustID 
																AND T.GameTypeID =Upline.GameTypeID AND Upline.StakeLevelList_new <> ''			 			 
					
					CROSS APPLY(SELECT TOP 1 ISNULL(CONVERT(varchar(20),cd.val),'') AS DownlineStakeLevelList_new
								FROM (SELECT CAST(val AS INT) AS val
									  FROM dbo.strSplit(Upline.StakeLevelList_new,','))  cd
										INNER JOIN dbo.StakeLevel SL WITH(NOLOCK) ON cd.val = sl.StakeLevelID
									 WHERE MinStake <> 0 AND MaxStake <> 0
									ORDER BY minstake , maxstake
								) T1 -- Direct Upline
				WHERE t.roleid = 1 AND T.StakeLevelList_new = ''
			
			END
			ELSE IF @roleid = 2
			BEGIN
				UPDATE T
				SET StakeLevelList_new = T1.DownlineStakeLevelList_new
				FROM #CustGameTypeDownlines T
					CROSS APPLY(SELECT TOP 1 ISNULL(CONVERT(varchar(20),cd.val),'') AS DownlineStakeLevelList_new
								FROM (SELECT CAST(val AS INT) AS val
									  FROM dbo.strSplit(T.StakeLevelList_Upline,','))  cd
										INNER JOIN dbo.StakeLevel SL WITH(NOLOCK) ON cd.val = sl.StakeLevelID
									 WHERE MinStake <> 0 AND MaxStake <> 0
									ORDER BY minstake , maxstake
								) T1 -- Direct Upline
				WHERE t.roleid = 1 AND T.StakeLevelList_new = ''
			END
			
			-- No need to update if having the same value between old and new
			DELETE #CustGameTypeDownlines WHERE StakeLevelList_new = StakeLevelList
			
			ALTER TABLE #CustGameTypeDownlines ADD ID INT IDENTITY (1,1)
			
			DECLARE @StartRow INT = 1, @MaxRow INT,@Threshold INT = 20000, @StopRow INT
			
			SET @MaxRow = (SELECT MAX(ID) FROM #CustGameTypeDownlines)
			
			IF @Threshold >= @MaxRow
				SET @Threshold = @MaxRow
			
			SET @StopRow = @Threshold
			
			IF EXISTS( SELECT 1 FROM #CustGameTypeDownlines)
			BEGIN
				WHILE (1=1)
				BEGIN
					PRINT @StartRow
					PRINT @StopRow
					SET @BetSettings =(SELECT custid AS ID,GameTypeID,StakeLevelList_new AS Stake
										FROM #CustGameTypeDownlines
										WHERE ID >= @StartRow AND ID <= @StopRow
										FOR XML RAW ('Row'), ROOT ('ROOT') 
										)
					
					--call execrep to correct downlines by batch customers
					
					EXEC Acc_CustSetting3rd_10
						@Action = 'GoldDeluxe'
						--,@GameTypeID = @GameTypeID
						,@BetSettings = @BetSettings
					
					IF @StopRow = @MaxRow BREAK
					
					SET @StartRow = @StopRow + 1
					
					SET @StopRow = 1 + @StopRow + @Threshold
					
					IF @StopRow >= @MaxRow
						SET @StopRow = @MaxRow
					
				END
			END	
			/* End of Updating downline process */	
		END	
				
		/*Starting write log customer process */		
		DECLARE @minGameTypeRow INT, @maxGameTypeRow INT
		SELECT @minGameTypeRow = MIN(ID), @maxGameTypeRow = MAX(ID) FROM #tmpStake
		
		WHILE @minGameTypeRow <=@maxGameTypeRow
		BEGIN
			
			SELECT @GameTypeID = new.GameTypeID, @StakeLevelList = new.StakeLevelList, @StakeLevelList_Old = old.StakeLevelList_old 
			FROM #tmpStake new
				JOIN #StakeLevelList_Excluded old ON new.GameTypeID = old.GameTypeID
			WHERE new.ID = @minGameTypeRow 
			
			IF @GameTypeID IS NOT NULL
			BEGIN
				SELECT @LogStakeLevel = ''  
				SELECT @LogStakeLevel_Old = ''  
				 
				SELECT @LogStakeLevel = @LogStakeLevel + MinLabel + '-' + MaxLabel + ','  
				FROM dbo.StakeLevel WITH(NOLOCK)  
				WHERE StakeLevelID IN (SELECT val FROM dbo.strSplit(@StakeLevelList,','))  
				ORDER BY MinStake, MaxStake ASC  
				 
				IF @LogStakeLevel <> ''   
				SELECT @LogStakeLevel = LEFT(@LogStakeLevel,LEN(@LogStakeLevel)-1)  
				 
				SELECT @LogStakeLevel_Old = @LogStakeLevel_old + MinLabel + '-' + MaxLabel + ','  
				FROM dbo.StakeLevel WITH(NOLOCK)  
				WHERE StakeLevelID IN (SELECT val FROM dbo.strSplit(@StakeLevelList_Old,','))  
				ORDER BY MinStake, MaxStake ASC  
				 
				IF @LogStakeLevel_Old <> ''  
				SELECT @LogStakeLevel_Old = LEFT(@LogStakeLevel_Old,LEN(@LogStakeLevel_Old)-1)  

				SELECT @LogSPData = '<Acc_CustomerUpdGoldDeluxe_MinMaxBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
				 'GameTypeID="'+ coalesce(cast(@GameTypeID as varchar(50)),space(1)) + '" '+    
				 'StakeLevel="'+ @LogStakeLevel + '" '+    
				 'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    
				 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +  
				 'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
				 'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
				 'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+    
				 'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'   
				   
				SELECT @LogSPData_Old = '<Acc_CustomerUpdGoldDeluxe_MinMaxBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
				 'GameTypeID="'+ coalesce(cast(@GameTypeID as varchar(50)),space(1)) + '" '+    
				 'StakeLevel="'+ @LogStakeLevel_old + '" '+    
				 'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    
				 'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +  
				 'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
				 'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
				 'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+    
				 'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'     

				SET @endRun = GETDATE()    
				SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)    

				BEGIN TRY  
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP    
					@UserID = @UserID,    
					@CustID = @CustID,    
					@ActionID = 389,    
					@TrackingValue = @LogSPData  ,   
					@TrackingValue2 = @LogSPData_old  ,    
					@duration = @duration    
				END TRY   
				BEGIN CATCH  
				SELECT @LogSPData = '<Acc_CustomerUpdGoldDeluxe_MinMaxBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
				  'GameTypeID="'+ coalesce(cast(@GameTypeID as varchar(50)),space(1)) + '" '+    
				  'StakeLevel="'+ @LogStakeLevel + '" '+    
				  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    
				  'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +  
				  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
				  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
				  'ErrMsg="'+ ERROR_MESSAGE() +'" '+  
				  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
				    
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP    
					@UserID = @UserID,    
					@CustID = @CustID,    
					@ActionID = 389,    
					@TrackingValue = @LogSPData,    
					@TrackingValue2 = @LogSPData_old,    
					@duration = @duration  
				END CATCH 
				
			 END
			SET @minGameTypeRow = @minGameTypeRow + 1
		END
	END	
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdGoldDeluxe_MinMaxBet] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdGoldDeluxe_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdGoldDeluxe_MinMaxBet] TO [bodbExtAccNet] AS [dbo]