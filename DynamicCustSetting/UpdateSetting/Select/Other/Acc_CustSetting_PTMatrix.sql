ALTER PROCEDURE [dbo].[Acc_CustSetting_PTMatrix]
   @ProductID TINYINT = 0,
   @SportType SMALLINT = 0,
   @BetType SMALLINT = 0,
   @IsLive BIT = 1,
   @UserName VARCHAR(30) = ''
AS  
/*  
 Created: 20150518@Dominic  
 Task : Get PT Matrix
 DB:  DBCUST/CustDB  
 Original:  

 Revision:
    - 20151021@Billy: Change parameter from (@ProductID, @UserName) to (@SportType, @BetType, @isLive, @UserName)
	- 20160912@Elodie: Support view PT by product - [Redmine: #60809]

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
		[SuperPT] [tinyint],
		[MasterPT] [tinyint],
		[AgentPT] [tinyint],
		[AutoSuperPT] [tinyint],
		[IsAutoSuperPT] [bit],
		[AutoMasterPT] [tinyint],
		[IsAutoMasterPT] [bit],
		[MinPT] [tinyint],
		[MaxPT] [tinyint]
	)	
	
	SELECT ProductID, SportType, BetType
	INTO #SportList
	FROM dbo.ProductSettingDetail
	WHERE SettingType = 1 
		AND ProductID = CASE WHEN @ProductID = 0 THEN ProductID ELSE @ProductID END

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
		INNER JOIN #SportList s ON s.SportType = spt.SportType AND s.BetType = spt.BetType
	WHERE CustID = @SRecommend
		AND spt.SportType = CASE WHEN @SportType = 0 THEN spt.SportType ELSE @SportType END
		AND spt.BetType = CASE WHEN @BetType = 0 THEN spt.BetType ELSE @BetType END
		AND IsLive <= @isLive
	
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
			INNER JOIN #SportList s ON s.SportType = mpt.SportType AND s.BetType = mpt.BetType
		WHERE CustID = @MRecommend
			AND mpt.SportType = CASE WHEN @SportType = 0 THEN mpt.SportType ELSE @SportType END
			AND mpt.BetType = CASE WHEN @BetType = 0 THEN mpt.BetType ELSE @BetType END
			AND IsLive <= @isLive
		
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
				INNER JOIN #SportList s ON s.SportType = apt.SportType AND s.BetType = apt.BetType
			WHERE CustID = @Recommend
				AND apt.SportType = CASE WHEN @SportType = 0 THEN apt.SportType ELSE @SportType END
				AND apt.BetType = CASE WHEN @BetType = 0 THEN apt.BetType ELSE @BetType END
				AND IsLive <= @isLive
			
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
						INNER JOIN #SportList s ON s.SportType = mempt.SportType AND s.BetType = mempt.BetType
					WHERE CustID = @CustID
						AND mempt.SportType = CASE WHEN @SportType = 0 THEN mempt.SportType ELSE @SportType END
						AND mempt.BetType = CASE WHEN @BetType = 0 THEN mempt.BetType ELSE @BetType END	
						AND IsLive <= @isLive
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
						INNER JOIN #SportList s ON s.SportType = mempt.SportType AND s.BetType = mempt.BetType
					WHERE AgentID = @Recommend
						AND mempt.SportType = CASE WHEN @SportType = 0 THEN mempt.SportType ELSE @SportType END
						AND mempt.BetType = CASE WHEN @BetType = 0 THEN mempt.BetType ELSE @BetType END	
						AND IsLive <= @isLive
				END
			END
		END
	END

	--Return PT
	SELECT [SportType]
		, [BetType]
		, [IsLive]
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
	ORDER BY [SportType]
		, [BetType]
		, [IsLive]
		, [RoleID] DESC
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PTMatrix] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PTMatrix] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_PTMatrix] TO [bodbExtAccNet]