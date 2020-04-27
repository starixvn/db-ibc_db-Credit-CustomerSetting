/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_StakeLevelCheck] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @StakeLevel		VARCHAR(MAX)
	, @SystemID INT --20200305@Tiara
	, @SettingType SMALLINT --20200414@Tiara
	, @ProductID TINYINT 
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160118@Billy
	Task : Check Customer's Stake Level Settings
	DB: DBCUST/CustDB
	Original:
	Revisions:
		- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
		- 20200330@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP applied for SB2 [Redmine: #131163]
		- 20200414@Tiara: Allbet/GD multiple stakelevels for member [Redmine: #131171]

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
					,	PRIMARY KEY CLUSTERED (SportType, BetType)
					);
	
	DECLARE	@iDoc					INT;

	DECLARE	@BetType				INT
		,	@StakeLevelList			VARCHAR(100)
		,	@UplineStakeLevelList	VARCHAR(100)
		,	@invalidStakeLevelID	VARCHAR(100)
		,	@wrongStakeLevelList	VARCHAR(100) 

	DECLARE	@xml					XML
	

	IF @StakeLevel IS NULL OR @StakeLevel = ''
		RETURN;

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

	CREATE TABLE #TmpProductSettingDetail
	(
		SettingType SMALLINT,
		SportType SMALLINT,
		BetType SMALLINT,
		IsLive BIT,
		ProductID TINYINT,
		MaxPT TINYINT,
		MaxDiscount DECIMAL (9, 8),
		IsSync BIT,
		IsHidden BIT,
		IsDisabled BIT,
		SettingLevel TINYINT,
		DisplayOrder TINYINT,
		SettingStatus TINYINT,
		IntervalValue DECIMAL (19, 8),
		RealProductID TINYINT,
		MaxChoice TINYINT
	)

	INSERT INTO #TmpProductSettingDetail ([SettingType] ,[SportType],[BetType],[IsLive],[ProductID],[MaxPT],[MaxDiscount],[IsSync],[IsHidden],[IsDisabled],[SettingLevel],[DisplayOrder],[SettingStatus],[IntervalValue],[RealProductID],[MaxChoice]) VALUES(17,211,2401,0,41,NULL,NULL,NULL,NULL,NULL,2,5,0,NULL,21,3)
	INSERT INTO #TmpProductSettingDetail ([SettingType] ,[SportType],[BetType],[IsLive],[ProductID],[MaxPT],[MaxDiscount],[IsSync],[IsHidden],[IsDisabled],[SettingLevel],[DisplayOrder],[SettingStatus],[IntervalValue],[RealProductID],[MaxChoice]) VALUES(17,243,3101,0,41,NULL,NULL,NULL,NULL,NULL,2,5,0,NULL,45,6)
	INSERT INTO #TmpProductSettingDetail ([SettingType] ,[SportType],[BetType],[IsLive],[ProductID],[MaxPT],[MaxDiscount],[IsSync],[IsHidden],[IsDisabled],[SettingLevel],[DisplayOrder],[SettingStatus],[IntervalValue],[RealProductID],[MaxChoice]) VALUES(17,244,3001,0,41,NULL,NULL,NULL,NULL,NULL,2,5,0,NULL,39,5)
	INSERT INTO #TmpProductSettingDetail ([SettingType] ,[SportType],[BetType],[IsLive],[ProductID],[MaxPT],[MaxDiscount],[IsSync],[IsHidden],[IsDisabled],[SettingLevel],[DisplayOrder],[SettingStatus],[IntervalValue],[RealProductID],[MaxChoice]) VALUES(7,241,3300,0,41,NULL,NULL,NULL,NULL,NULL,2,6,0,NULL,47,NULL)
	INSERT INTO #TmpProductSettingDetail ([SettingType] ,[SportType],[BetType],[IsLive],[ProductID],[MaxPT],[MaxDiscount],[IsSync],[IsHidden],[IsDisabled],[SettingLevel],[DisplayOrder],[SettingStatus],[IntervalValue],[RealProductID],[MaxChoice]) VALUES(7,242,3201,0,41,NULL,NULL,NULL,NULL,NULL,2,6,0,NULL,46,NULL)
	INSERT INTO #TmpProductSettingDetail ([SettingType] ,[SportType],[BetType],[IsLive],[ProductID],[MaxPT],[MaxDiscount],[IsSync],[IsHidden],[IsDisabled],[SettingLevel],[DisplayOrder],[SettingStatus],[IntervalValue],[RealProductID],[MaxChoice]) VALUES(7,245,4601,0,38,NULL,NULL,NULL,NULL,NULL,4,4,0,NULL,38,NULL)
	--Prevent users under 789y uncheck all Stakelevel
	--Prevent uncheck all Stakelevel of member level for setting type 17
	IF @SystemID IN (6,7,8,9) OR (@SystemID != 1 AND @RoleID = 1 AND @SettingType = 17)--789y Alpha, 789y ExtNAP OR Member level at Setting type 17
	BEGIN
		IF EXISTS (SELECT 1 
					FROM #tmpStakeCheck WITH (NOLOCK)
					WHERE StakeLevelList IS NULL OR StakeLevelList='')
		BEGIN
			SELECT	@xml =	(
										SELECT	10035												AS '@MsgID'
											,	'Each bet type must have at least one Bet Limit value to be selected'	AS '@Msg'
											,	(
													SELECT	DISTINCT psd.SportType							AS '@SportType'
														,	psd.BetType								AS '@BetType'
													FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
													INNER JOIN	#tmpStakeCheck AS ts
															ON	ts.BetType = sl.GameTypeID
													INNER JOIN	#TmpProductSettingDetail AS psd WITH(NOLOCK)
															ON	psd.SportType = ts.SportType
															AND	psd.BetType = ts.BetType
															AND	psd.SettingType = @SettingType
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
				IF EXISTS (SELECT 1 
						FROM  #tmpStakeCheck T WITH (NOLOCK)
							INNER JOIN #TmpProductSettingDetail P WITH (NOLOCK) ON T.SportType = P.SportType AND T.BetType = P.BetType
							CROSS APPLY dbo.strSplit(T.StakeLevelList,',') 
						WHERE P.SettingType = @SettingType
						GROUP BY P.MaxChoice
						HAVING COUNT(VAL) > P.MaxChoice
					)
				BEGIN
				--Select Product Name
				DECLARE @ProductName VARCHAR (50)
				
				SELECT	@ProductName = p.ProductName
				FROM	DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
				WHERE	p.ProductID = @ProductID;

				SELECT	@xml =	(
											SELECT	10036												AS '@MsgID'
												,	(
														SELECT	DISTINCT 'You can only assign maximum '+CAST(PSD.MaxChoice AS VARCHAR)+ ' bet limits to member level for '+@ProductName	AS '@Msg'
															,	psd.SportType							AS '@SportType'
															,	psd.BetType								AS '@BetType'
															,  psd.MaxChoice							AS '@MaxChoice'
														FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
														INNER JOIN	#tmpStakeCheck AS ts
																ON	ts.BetType = sl.GameTypeID
														INNER JOIN	#TmpProductSettingDetail AS psd WITH(NOLOCK)
																ON	psd.SportType = ts.SportType
																AND	psd.BetType = ts.BetType
																AND	psd.SettingType = @SettingType
														FOR XML PATH ('Row')
													,	TYPE
													) 
											FOR XML PATH ('Root')
										,	TYPE
										);
				SELECT	@ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
						,	@MsgType = 131
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

			IF	@RoleID = 3  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @SuperID
					AND	BetType = @BetType;
			END;           
			ELSE IF	@RoleID = 2  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @MasterID
					AND	BetType = @BetType;
			END;           
			ELSE IF	@RoleID = 1  
			BEGIN  
				SELECT	@UplineStakeLevelList = StakeLevelList
				FROM	dbo.CustStakeLevel_Agent WITH(NOLOCK)
				WHERE	CustID = @AgentID
					AND	BetType = @BetType;			
			END

			SELECT TOP(1) @invalidStakeLevelID = ISNULL(val,0)    
			FROM dbo.strSplit(@StakeLevelList,',')  
			WHERE val NOT IN (SELECT val FROM dbo.strSplit(@UplineStakeLevelList,','));  

			IF @invalidStakeLevelID > 0  
			BEGIN
				SELECT	@xml =	(
									SELECT	10034												AS '@MsgID'
										,	'This user''s upline does not have Stake Level.'	AS '@Msg'
										,	(
												SELECT	psd.SportType							AS '@SportType'
													,	psd.BetType								AS '@BetType'
												FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
												INNER JOIN	#tmpStakeCheck AS ts
														ON	ts.BetType = sl.GameTypeID
														AND	sl.StakeLevelID = CAST(@invalidStakeLevelID AS INT)
												INNER JOIN	#TmpProductSettingDetail AS psd WITH(NOLOCK)
														ON	psd.SportType = ts.SportType
														AND	psd.BetType = ts.BetType
														AND	psd.SettingType = @SettingType
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
	DROP TABLE #TmpProductSettingDetail;
END;
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_BetLimitCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_BetLimitCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_BetLimitCheck] TO [bodbExtAccNet]
