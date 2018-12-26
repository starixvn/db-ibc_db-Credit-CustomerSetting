/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustomerIns_PTSetting_Check
	@CustID			INT,
	@SuperID		INT,
	@MasterID		INT,
	@AgentID		INT,
	@RoleID			TINYINT,
	@ProductID		TINYINT = 1,
	@PTSetting		VARCHAR(MAX),
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check PT info when creating new downline
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId:
			= 4: Create super 
			= 3: Create master 
			= 2: Create agent 			
		@RoleID = 4:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MinPT="20" MaxPT = "80"/>
						</ROOT>			
		@RoleID = 3:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" SuperPT="10"/>
						</ROOT>			
		@RoleID = 2:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MasterPT="20" AgentPT = "50"/>
						</ROOT>			
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @_PTSetting XML	
	DECLARE @ErrorSportTypeTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsLive			BIT
			, SuperPT			TINYINT
			, MasterPT			TINYINT
			, AgentPT			TINYINT
			, MinPT				TINYINT
			, MaxPT				TINYINT
		)

	SELECT @_PTSetting = @PTSetting

	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	SELECT * INTO #PT_tmp
	FROM dbo.f_CS_PTParse(@_PTSetting) pt
		INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive

	IF @RoleId = 4
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinPT, ps.MaxPT AS MaxPT
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter1 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinPT, pt.MaxPT AS MaxPT
		FROM dbo.f_CS_GetPT_Agent (@CustID)	pt 		
			INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive
	END	
	ELSE IF @RoleId = 2
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, spt.MinPT - mpt.SuperPT AS MinPT, spt.MaxPT - mpt.SuperPT AS MaxPT
		FROM CustInfo ci WITH (NOLOCK) 
			CROSS APPLY dbo.f_CS_GetPT_Agent (ci.srecommend) spt 			
			CROSS APPLY dbo.f_CS_GetPT_Agent (ci.custid) mpt 
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive AND mpt.SportType = ft.SportType AND mpt.BetType = ft.BetType AND mpt.IsLive = ft.IsLive 
		WHERE ci.custid = @CustId
	END	
END
GO
