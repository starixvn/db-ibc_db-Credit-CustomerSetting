/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_PTMatrix]
   @ProductID TINYINT = 0,
   @SportType SMALLINT = 0,
   @BetType SMALLINT = 0,
   @IsLive BIT = 1,
   @UserName VARCHAR(30) = '',
   @SettingStatus TINYINT = 0
AS  
/*  
 Created: 20150518@Dominic  
 Task : Get PT Matrix
 DB:  DBCUST/CustDB  
 Original:  

 Revision:
    - 20151021@Billy: Change parameter from (@ProductID, @UserName) to (@SportType, @BetType, @isLive, @UserName)
	- 20160912@Elodie: Support view PT by product - [Redmine: #60809]
	- 20171214@Vicky: NAP - System show duplicate data when viewing PT of Cricket - [Redmine: #87939]
	- 20200615@Elodie: Implement new setting type 18 [Redmine: #135363]
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]

 Param's Explanation:  

 */  
BEGIN  
	SET NOCOUNT ON
	DECLARE @CustID INT
		, @RoleID INT
		, @SRecommend INT
		, @MRecommend INT
		, @Recommend INT
	
	SELECT @CustID = CustID
		, @RoleID = RoleID
		, @SRecommend = SRecommend
		, @MRecommend = MRecommend
		, @Recommend = Recommend
	FROM Custinfo WITH (NOLOCK)
	WHERE UserName = @UserName	
	
	DECLARE @PTMatrix TABLE (
		[CustID] [int],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SuperPT] SMALLMONEY,
		[MasterPT] SMALLMONEY,
		[AgentPT] SMALLMONEY,
		[AutoSuperPT] SMALLMONEY,
		[IsAutoSuperPT] [bit],
		[AutoMasterPT] SMALLMONEY,
		[IsAutoMasterPT] [bit],
		[MinPT] SMALLMONEY,
		[MaxPT] SMALLMONEY
	)	
	
	CREATE TABLE #SportList (ProductID TINYINT, SportType SMALLINT, BetType SMALLINT, IsLive BIT, Child_DisplayOrder int)

	INSERT INTO #SportList (ProductID, SportType, BetType, IsLive, Child_DisplayOrder)
	SELECT ProductID, SportType, BetType, IsLive , Child_DisplayOrder
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULLIF(@productid,0),1,@SettingStatus)
	--WHERE islive <= @islive
	UNION ALL
	SELECT ProductID, SportType, BetType, IsLive , Child_DisplayOrder
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULLIF(@productid,0),18,@SettingStatus)
	--WHERE islive <= @islive
	UNION ALL
	SELECT ProductID, SportType, BetType, IsLive , Child_DisplayOrder
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULLIF(@productid,0),28,@SettingStatus)
		
	INSERT @PTMatrix
	SELECT
		spt.CustID
		,spt.[SportType]
		,spt.[BetType]
		,spt.[IsLive]
		,spt.[SuperPT]
		,spt.[MasterPT]
		,spt.[AgentPT]
		, NULL
		, NULL
		, NULL
		, NULL
		,spt.[MinPT]
		,spt.[MaxPT]
	FROM [dbo].[CustPTSetting3rd_Agent] spt WITH(NOLOCK)
		INNER JOIN #SportList s ON s.SportType = spt.SportType AND s.BetType = spt.BetType AND s.IsLive = spt.IsLive
	WHERE CustID = @SRecommend
		AND spt.SportType = CASE WHEN @SportType = 0 THEN spt.SportType ELSE @SportType END
		AND spt.BetType = CASE WHEN @BetType = 0 THEN spt.BetType ELSE @BetType END
		--AND spt.IsLive <= @isLive
	
	IF @RoleID IN (3, 2, 1)
	BEGIN
		INSERT @PTMatrix
		SELECT mpt.CustID
			, mpt.[SportType]
			,mpt.[BetType]
			,mpt.[IsLive]
			,mpt.[SuperPT]
			,mpt.[MasterPT]
			,NULL
			,mpt.[AutoSuperPT]
			,mpt.[IsAutoSuperPT]
			,NULL
			,NULL
			,mpt.[MinPT]
			,mpt.[MaxPT]
		FROM [dbo].[CustPTSetting3rd_Agent] mpt WITH(NOLOCK)
			INNER JOIN #SportList s ON s.SportType = mpt.SportType AND s.BetType = mpt.BetType AND s.IsLive = mpt.IsLive
		WHERE CustID = @MRecommend
			AND mpt.SportType = CASE WHEN @SportType = 0 THEN mpt.SportType ELSE @SportType END
			AND mpt.BetType = CASE WHEN @BetType = 0 THEN mpt.BetType ELSE @BetType END
			--AND mpt.IsLive <= @isLive
		
		IF @RoleID IN (2, 1)
		BEGIN
			INSERT @PTMatrix
			SELECT apt.CustID
				, apt.[SportType]
				,apt.[BetType]
				,apt.[IsLive]
				,NULL
				,[MasterPT]
				,[AgentPT]
				,NULL
				,NULL
				,apt.[AutoMasterPT]
				,apt.[IsAutoMasterPT]
				,apt.[MinPT]
				,apt.[MaxPT]
			FROM [dbo].[CustPTSetting3rd_Agent] apt WITH(NOLOCK)
				INNER JOIN #SportList s ON s.SportType = apt.SportType AND s.BetType = apt.BetType AND s.IsLive = apt.IsLive
			WHERE CustID = @Recommend
				AND apt.SportType = CASE WHEN @SportType = 0 THEN apt.SportType ELSE @SportType END
				AND apt.BetType = CASE WHEN @BetType = 0 THEN apt.BetType ELSE @BetType END
				--AND apt.IsLive <= @isLive
			
			IF @RoleID = 1
			BEGIN
				IF EXISTS(SELECT TOP 1 1 
							FROM dbo.CustSettingMode3rd WITH(NOLOCK) 
							WHERE CustID = @CustID AND IsGrouped = 0)
				BEGIN
					INSERT @PTMatrix
					SELECT mempt.CustID
						, mempt.[SportType]
						, mempt.[BetType]
						, mempt.[IsLive]
						, mempt.[SuperPT]
						, mempt.[MasterPT]
						, mempt.[AgentPT]
						, mempt.[AutoSuperPT]
						, mempt.[IsAutoSuperPT]
						, mempt.[AutoMasterPT]
						, mempt.[IsAutoMasterPT]
						, NULL
						, NULL
					FROM [dbo].CustPTSetting3rd_Member mempt WITH (NOLOCK)
						INNER JOIN #SportList s ON s.SportType = mempt.SportType AND s.BetType = mempt.BetType AND s.IsLive = mempt.IsLive
					WHERE CustID = @CustID
						AND mempt.SportType = CASE WHEN @SportType = 0 THEN mempt.SportType ELSE @SportType END
						AND mempt.BetType = CASE WHEN @BetType = 0 THEN mempt.BetType ELSE @BetType END	
						--AND mempt.IsLive <= @isLive
				END
				ELSE
				BEGIN
					INSERT @PTMatrix
					SELECT @CustID
						, mempt.[SportType]
						, mempt.[BetType]
						, mempt.[IsLive]
						, mempt.[SuperPT]
						, mempt.[MasterPT]
						, mempt.[AgentPT]
						, mempt.[AutoSuperPT]
						, mempt.[IsAutoSuperPT]
						, mempt.[AutoMasterPT]
						, mempt.[IsAutoMasterPT]
						, NULL
						, NULL
					FROM [dbo].CustPTGroupSetting3rd_Member mempt WITH (NOLOCK)
						INNER JOIN #SportList s ON s.SportType = mempt.SportType AND s.BetType = mempt.BetType AND s.IsLive = mempt.IsLive
					WHERE AgentID = @Recommend
						AND mempt.SportType = CASE WHEN @SportType = 0 THEN mempt.SportType ELSE @SportType END
						AND mempt.BetType = CASE WHEN @BetType = 0 THEN mempt.BetType ELSE @BetType END	
						--AND mempt.IsLive <= @isLive
				END
			END
		END
	END

	--Return PT
	SELECT pt.[SportType]
		, pt.[BetType]
		, pt.[IsLive]
		, [RoleID]
		, ISNULL([SuperPT],0) [SuperPT]
		, ISNULL([MasterPT],0) [MasterPT]
		, ISNULL([AgentPT],0) [AgentPT]
		, ISNULL([AutoSuperPT],0) [AutoSuperPT]
		, ISNULL([IsAutoSuperPT],0) [IsAutoSuperPT]
		, ISNULL([AutoMasterPT],0) [AutoMasterPT]
		, ISNULL([IsAutoMasterPT],0) [IsAutoMasterPT]
		, ISNULL([MinPT],0) [MinPT]
		--, ISNULL([MaxPT],0) [MaxPT]
	FROM @PTMatrix pt
		INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON pt.CustID = ci.custid
		INNER JOIN #SportList t ON pt.SportType = t.SportType
								AND pt.BetType = t.BetType
								AND pt.IsLive = t.IsLive
	ORDER BY t.Child_DisplayOrder
		, pt.[SportType]
		, pt.[BetType]
		, pt.[IsLive]
		, ci.[RoleID] DESC

	DROP TABLE #SportList
END
GO