 ALTER PROCEDURE [dbo].[Acc_CustomerUpdOpusCS_StakeLevel]
	@custid INT,
	@userid INT,
	@GameTypeID INT,
	@StakeLevelList VARCHAR(100),
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT 
 AS
	/*
		Created: Johnson
		Date: 2013-09-30
		Task[redmine:#5670]: Update opus casino's stake level for customer
		DB: DBTXN/custDB
		
		Revision:
		
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON
	
	declare @roleid tinyint
			,@CustGameTypeID int
			,@OldStakeLevelList nvarchar(100)	
			,@LowestStakeLevelList nvarchar(100)
			,@DownlineID int
			,@DownlineRoleID int
			,@srecommend int
			,@mrecommend int
			,@recommend int
			,@DownlineStakeLevelList nvarchar(100)
			,@DownlineStakeLevelList_new nvarchar(100)
			,@UplineStakeLevelList nvarchar(100)
			,@UplineLowestStakeLevelList nvarchar(100)
			
	---------------------------
	-- ***Check Downline Belonging***		
	EXEC DBAGE.bodb02.dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,		
		@roleid = @roleid OUTPUT
		if (@roleid = 0) return

	--Check disable user
	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode > 0
		RETURN;
	
	CREATE TABLE #CustGameTypeDownlines (
				CustID INT PRIMARY KEY		
				,srecommend INT
				,mrecommend INT
				,recommend INT		
				,roleid TINYINT
				,StakeLevelList varchar(100)
				,CustGameTypeID INT
		)
			
	--Update itself
	SELECT	@CustGameTypeID = CustGameTypeID, @OldStakeLevelList = StakeLevelList 
	FROM	CustGameType with (NOLOCK) 
	WHERE	GameTypeID = @GameTypeID AND CustID = @CustID
	
	IF @StakeLevelList <> @OldStakeLevelList
	BEGIN 
		UPDATE	CustGameType with(rowlock)
		SET		StakeLevelList = @StakeLevelList
		WHERE	CustGameTypeID = @CustGameTypeID
		
		IF @roleid > 1 --Apply stake level for downlines
		BEGIN
			--Get stake level is unchecked
			IF OBJECT_ID('tempdb..#temp_DelStakeLevelList') IS NOT NULL DROP TABLE #temp_DelStakeLevelList
			IF EXISTS ( SELECT ISNULL(val,'')
						FROM dbo.strSplit(@OldStakeLevelList,',')
						WHERE val NOT IN (SELECT val FROM strSplit(@StakeLevelList,','))	
						)
			BEGIN
				SELECT	ISNULL(Val,'') Val INTO #temp_DelStakeLevelList
				FROM	dbo.strSplit(@OldStakeLevelList,',')
				WHERE	ISNULL(Val,'') not IN(SELECT ISNULL(val,'') Val FROM dbo.strSplit(@StakeLevelList,',')) 		
			END
			
			--Get lowest stake level to apply to agents/members
			SELECT	top 1 @LowestStakeLevelList = CONVERT(VARCHAR(10),StakeLevelID)
			FROM	StakeLevel with(nolock)
			WHERE	CHARINDEX('''' + convert(varchar(5),StakeLevelID) + '''','''' + replace(@StakeLevelList,',',''',''') + '''') > 0
					AND MinStake <> 0
					AND MaxStake <> 0
			ORDER BY MinStake, MaxStake		
			
			IF @roleid = 4
			BEGIN
				INSERT INTO #CustGameTypeDownlines (CustID, srecommend, mrecommend, recommend, roleid ,StakeLevelList ,CustGameTypeID)
				SELECT ci.custid, srecommend, mrecommend, recommend, ci.roleid, StakeLevelList, CustGameTypeID
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustGameType cg WITH(NOLOCK) ON ci.custid = cg.custid AND cg.gametypeid = @GameTypeID
				WHERE srecommend = @custid AND roleid < 4		
			END
			IF @roleid = 3
			BEGIN
				INSERT INTO #CustGameTypeDownlines (CustID ,srecommend, mrecommend, recommend, roleid ,StakeLevelList ,CustGameTypeID)
				SELECT ci.custid, srecommend, mrecommend, recommend, ci.roleid, StakeLevelList, CustGameTypeID
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustGameType cg WITH(NOLOCK) ON ci.custid = cg.custid AND cg.gametypeid = @GameTypeID
				WHERE mrecommend = @custid AND roleid < 3
			END
			IF @roleid = 2
			BEGIN
				INSERT INTO #CustGameTypeDownlines (CustID, srecommend, mrecommend, recommend,roleid ,StakeLevelList ,CustGameTypeID)
				SELECT ci.custid, srecommend, mrecommend, recommend, ci.roleid, StakeLevelList, CustGameTypeID
				FROM custinfo ci WITH(NOLOCK)
					INNER JOIN CustGameType cg WITH(NOLOCK) ON ci.custid = cg.custid AND cg.gametypeid = @GameTypeID
				WHERE recommend = @custid AND roleid = 1
			END
			
			--correct stake level for all downlines
			WHILE (1 = 1)
			BEGIN
				SELECT TOP 1 @DownlineID = custid , @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend,
					 @DownlineRoleid = roleid ,@DownlineStakeLevelList = ISNULL(StakeLevelList,'')
				FROM #CustGameTypeDownlines
				ORDER BY roleid DESC, custid
				
				IF @@ROWCOUNT = 0
					break;
					
				IF OBJECT_ID('tempdb..#temp_DelStakeLevelList') IS NOT NULL
				BEGIN
					IF @DownlineStakeLevelList <> ''
					BEGIN 
						SET @DownlineStakeLevelList_new = ''
						
						SELECT @DownlineStakeLevelList_new = @DownlineStakeLevelList_new + val + ','
						FROM dbo.strSplit(@DownlineStakeLevelList,',')
						WHERE val not in (SELECT val FROM #temp_DelStakeLevelList)
						
						SET @DownlineStakeLevelList_new = left(@DownlineStakeLevelList_new,len(@DownlineStakeLevelList_new) - 1)
						
						--apply valid stake level for downline
						IF @DownlineStakeLevelList_new = ''
						BEGIN
							IF @DownLineRoleid = 3
								SELECT @UplineStakeLevelList = StakeLevelList
								FROM CustGameType WITH(NOLOCK)
								WHERE custid = @srecommend AND gametypeid = @gametypeid
							ELSE IF  @DownLineRoleid = 2
								SELECT @UplineStakeLevelList = StakeLevelList
								FROM CustGameType WITH(NOLOCK)
								WHERE custid = @mrecommend AND gametypeid = @gametypeid
							ELSE IF  @DownLineRoleid = 1
								SELECT @UplineStakeLevelList = StakeLevelList
								FROM CustGameType WITH(NOLOCK)
								WHERE custid = @recommend AND gametypeid = @gametypeid
							
							SELECT TOP 1 @UplineLowestStakeLevelList = CONVERT(varchar(10),StakeLevelID)
							FROM StakeLevel WITH(NOLOCK)
							WHERE stakeLevelID IN (SELECT val FROM dbo.strSplit(@UplineStakeLevelList,','))
								AND MinStake <> 0
								AND MaxStake <> 0
							ORDER BY minstake , maxstake
							
							SET @DownlineStakeLevelList_new = @UplineLowestStakeLevelList
						END
					END
				END
				--check if old stake level list is empty and update stake level list then copy all stake level list to master if update super and 
				--copy lowest stake level to agent/member if update master/agent
				IF RTRIM(ISNULL(@OldStakeLevelList,'')) = '' AND RTRIM(ISNULL(@StakeLevelList,'')) <> ''
				BEGIN
					IF @DownLineRoleID = 1 or @DownLineRoleID = 2 
						SET @DownlineStakeLevelList_new = @LowestStakeLevelList
					ELSE IF @DownLineRoleID = 3
						SET @DownlineStakeLevelList_new = @StakeLevelList
				END
				
				UPDATE CustGameType WITH(ROWLOCK)
				SET StakeLevelList = @DownlineStakeLevelList_new
				WHERE CustGameTypeID = @CustGameTypeID
				
				IF (@ErrMsg <> '') RAISERROR(@ErrMsg,16,1)
				
				DELETE #CustGameTypeDownlines WHERE CustID = @DownLineID
			END
		END
	END
	IF OBJECT_ID('tempdb..#temp_DelStakeLevelList') IS NOT NULL DROP TABLE #temp_DelStakeLevelList
	IF OBJECT_ID('tempdb..#CustGameTypeDownlines') IS NOT NULL DROP TABLE #CustGameTypeDownlines
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdOpusCS_StakeLevel] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdOpusCS_StakeLevel] TO [bodbDownlineNet]
