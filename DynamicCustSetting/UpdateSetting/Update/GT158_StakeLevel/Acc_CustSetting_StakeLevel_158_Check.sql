/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_StakeLevel_158_Check] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @StakeLevel		VARCHAR(MAX)
	, @SystemID			INT 
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
	, @SettingStatus	TINYINT = 0
	, @GroupType		SMALLINT = 158
	, @GroupID			TINYINT = 3
AS
/*
	Created: - 20240215@Eden
	Task : Check Customer's Stake Level Settings
	DB: DBCUST/CustDB
	Original:
	Revisions:
		- 20240215@Eden: Unify Live Casino & RNG slot/RNG Casino [Redmine: #198960] 
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969] 
	Param's Explanation:
		@StakeLevel:
		<ROOT>
				<StakeLevel 
						SportType="211" 
						BetType="2401" 
						StakeLevelList="1,2,3,4,5"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE	#tmpStakeCheck (
						ID				INT IDENTITY (1,1)
					,	SportType		SMALLINT
					,	BetType			INT
					,	StakeLevelList	VARCHAR(200)
					,	isValidated		BIT DEFAULT 0
					,   SettingType		SMALLINT
					,	PRIMARY KEY CLUSTERED (SportType, BetType)
					);
	
	DECLARE	@iDoc					INT;

	DECLARE	@BetType				INT
		,	@StakeLevelList			VARCHAR(100)
		,	@UplineStakeLevelList	VARCHAR(100)
		,	@invalidStakeLevelID	VARCHAR(100)
		,	@wrongStakeLevelList	VARCHAR(100) 

	DECLARE	@xml					XML

	CREATE TABLE #ProductSettingDetail_Check(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		MaxChoice	tinyint,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	

	IF @StakeLevel IS NULL OR @StakeLevel = ''
		RETURN;

	DECLARE  @SiteID SMALLINT,
			 @Currency SMALLINT,
			 @Site VARCHAR (10)
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency,
			@Site = C.site
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxChoice)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,NULLIF(MaxChoice,0)
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	DELETE t
	FROM #tmpStakeCheck t
		LEFT JOIN #ProductSettingDetail_Check ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
	WHERE ps.SportType IS NULL

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= '';


	EXEC sys.sp_xml_preparedocument @iDoc OUTPUT, @StakeLevel;

	INSERT INTO #tmpStakeCheck
		(	SportType   , BetType   , StakeLevelList)
	SELECT	ox.SportType, ox.BetType, ox.StakeLevelList
	FROM OPENXML (@iDoc, '/ROOT/StakeLevel', 1) 
	WITH (
		SportType		SMALLINT
	,	BetType			INT
	,	StakeLevelList	VARCHAR(200)	
	) AS ox;

	EXEC sys.sp_xml_removedocument @iDoc;

	--Exclude Update for Sport is having UM
	DELETE t
	FROM #tmpStakeCheck t
		INNER JOIN #ProductSettingDetail_Check ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	UPDATE t
	SET t.SettingType = ps.SettingType
	FROM #tmpStakeCheck t
		INNER JOIN #ProductSettingDetail_Check ps 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType

	--Prevent users under 789y uncheck all Stakelevel
	--Prevent uncheck all Stakelevel of member level for setting type 17,7
	IF EXISTS	(	SELECT 1 
					FROM  #tmpStakeCheck t
					WHERE t.SettingType IN (7,17)
						AND @RoleID = 1
				) 
		OR @SystemID IN (6,7,8,9) --Restrict for Member Level of all sites for setting type 17 or 789y all level 
	BEGIN
		IF EXISTS ( SELECT 1 
					FROM #tmpStakeCheck ts
						INNER JOIN	#ProductSettingDetail_Check AS psd
							ON	psd.SportType = ts.SportType
							AND	psd.BetType = ts.BetType
					WHERE ISNULL(ts.StakeLevelList,'') = ''
						AND (	
								(	ts.SettingType IN (7,17) 
									AND NOT (@Site IN ('733333', '722222') AND psd.ProductID = 41) --Allow users under site: 733333, 722222 uncheck all StakeLevel on Live Casino products
								)
							OR @SystemID IN (6,7,8,9)
							)
				)
		BEGIN
			SELECT	@xml =	(
										SELECT	10035												AS '@MsgID'
											,	'Each bet type must have at least one Bet Limit value to be selected'	AS '@Msg'
											,	(
													SELECT	DISTINCT psd.SportType					AS '@SportType'
														,	psd.BetType								AS '@BetType'
														,	psd.SettingLevel							AS '@SettingLevel'
													FROM #tmpStakeCheck ts
														INNER JOIN	#ProductSettingDetail_Check AS psd
															ON	psd.SportType = ts.SportType
															AND	psd.BetType = ts.BetType
													WHERE ISNULL(ts.StakeLevelList,'') = ''
														AND (	
																(	ts.SettingType IN (7,17) 
																	AND NOT (@Site IN ('733333', '722222') AND psd.ProductID = 41) --Allow users under site: 733333, 722222 uncheck all StakeLevel on Live Casino products
																)
															OR @SystemID IN (6,7,8,9)
															)
													FOR XML PATH ('Row')
												,	TYPE
												)
										FOR XML PATH ('Root')
									,	TYPE
									);

			SELECT	@ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
					,	@MsgType = 131
					,	@ErrCode = 10035;
			RETURN;   
		END

		IF @RoleID = 1
		BEGIN
			IF EXISTS (	SELECT 1 
						FROM  #tmpStakeCheck T WITH (NOLOCK)
							INNER JOIN #ProductSettingDetail_Check P WITH (NOLOCK) 
								ON T.SportType = P.SportType AND T.BetType = P.BetType
							CROSS APPLY STRING_SPLIT(T.StakeLevelList,',') 
						WHERE p.SettingType  = 17
						GROUP BY P.SportType, P.BetType, P.MaxChoice
						HAVING COUNT(value) > P.MaxChoice
				)
			BEGIN
				SELECT	@xml =	(
											SELECT	10036											AS '@MsgID'
												,	(
														SELECT	DISTINCT 'You can only assign maximum ' + CAST(P.MaxChoice AS VARCHAR) + ' bet limits to member level for this Product' AS '@Msg'
															,	p.SportType							AS '@SportType'
															,	p.BetType							AS '@BetType'
															,   p.MaxChoice							AS '@MaxChoice'
															,	MAX(p.SettingLevel) 				AS '@SettingLevel'
															,	MAX(p.ProductID)					AS '@ProductID'
														FROM  #tmpStakeCheck T WITH (NOLOCK)
															INNER JOIN #ProductSettingDetail_Check P 
																ON T.SportType = P.SportType AND T.BetType = P.BetType
															CROSS APPLY STRING_SPLIT(T.StakeLevelList,',') 
														WHERE p.SettingType  = 17
														GROUP BY P.SportType, P.BetType, P.MaxChoice
														HAVING COUNT(value) > P.MaxChoice
														FOR XML PATH ('Row')
													,	TYPE
													) 
											FOR XML PATH ('Root')
										,	TYPE
										);
				SELECT	@ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
						,	@MsgType = 132
						,	@ErrCode = 10036;
				RETURN;   
			END
		END
	END 
	IF @RoleID < 4
	BEGIN
	    WHILE (0 = 0)
		BEGIN
		    SELECT TOP(1)	@BetType		= BetType
						,	@StakeLevelList = StakeLevelList   
			FROM #tmpStakeCheck  
			WHERE isValidated = 0;  

			IF @@ROWCOUNT = 0
				BREAK;  

			IF	(@RoleID = 3) OR (@RoleID = 1 AND @AgentID = -4)			-- Master or SuperDirectMember : Collect Upline Super
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @SuperID
					AND	BetType = @BetType;
			END;           
			ELSE IF	(@RoleID = 2) OR (@RoleID = 1 AND @AgentID = -3)		-- Agent or MasterDirectMember : Collect Upline Super, Master  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @MasterID
					AND	BetType = @BetType;
			END;           
			ELSE IF	@RoleID = 1 AND @AgentID NOT IN (-4,-3)				 -- Normal member : Collect Upline Super, Master, Agent
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @AgentID
					AND	BetType = @BetType;			
			END

			SELECT TOP(1) @invalidStakeLevelID = ISNULL(value,0)    
			FROM STRING_SPLIT(@StakeLevelList,',')  
			WHERE value NOT IN (SELECT value FROM STRING_SPLIT(@UplineStakeLevelList,','));  

			IF @invalidStakeLevelID > 0  
			BEGIN
				SELECT	@xml =	(
									SELECT	10034												AS '@MsgID'
										,	'This user''s upline does not have Stake Level.'	AS '@Msg'
										,	(
												SELECT	psd.SportType							AS '@SportType'
													,	psd.BetType								AS '@BetType'
													,	psd.SettingLevel							AS '@SettingLevel'
												FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
												INNER JOIN	#tmpStakeCheck AS ts
														ON	ts.BetType = sl.GameTypeID
														AND	sl.StakeLevelID = CAST(@invalidStakeLevelID AS INT)
												INNER JOIN	#ProductSettingDetail_Check AS psd WITH(NOLOCK)
														ON	psd.SportType = ts.SportType
														AND	psd.BetType = ts.BetType
												FOR XML PATH ('Row')
											,	TYPE
											)
									FOR XML PATH ('Root')
								,	TYPE
								);
				SELECT	@ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
					,	@MsgType = 131
					,	@ErrCode = 10034;
				RETURN;   
			END;   

			UPDATE	#tmpStakeCheck
			SET		isValidated = 1  
			WHERE	BetType = @BetType;
		END;
	END;

	DROP TABLE #tmpStakeCheck;
	DROP TABLE #ProductSettingDetail_Check
END;
GO
