SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_StakeLevelCheck] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @StakeLevel		VARCHAR(MAX)
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160118@Billy
	Task : Check Customer's Stake Level Settings
	DB: DBCUST/CustDB
	Original:

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
		,	@invalidStakeLevelID	VARCHAR(100);

	DECLARE	@xml					XML
		,	@SettingType			SMALLINT;

	IF @StakeLevel IS NULL OR @StakeLevel = ''
		RETURN;

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= '';
		
	-- Stake Level Member Single Selection
	SELECT	@SettingType = 7;

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
			END;

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
												INNER JOIN	dbo.ProductSettingDetail AS psd WITH(NOLOCK)
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
END;
GO

GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelCheck TO [bodbAdminNet];
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelCheck TO [bodbDownlineNet];
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelCheck TO [bodbExtAccNet];