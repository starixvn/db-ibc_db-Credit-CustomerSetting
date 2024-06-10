/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" IsNested = "1"></info>*/
ALTER PROCEDURE [dbo].[Acc_Custsetting_CloneSetting_SportsbookIns]
	@custid INT =0,
	@ExistingCustid INT = 0,
	@Language VARCHAR(3) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20240607@Johnson	
	Task: Scale out DBCUST- add rep in-house tables setting
	DB: DBCUST/custDB
	
	Revisions:
		- 20240607@Johnson: scale out DBCUST [redmine: #199915]
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency SMALLINT
	DECLARE @RoleID TINYINT ,@SuperID INT, @MasterID INT

	SELECT @RoleID = roleid , @SuperID = srecommend , @MasterID = mrecommend
		,@_Site = Site, @_Currency = currency 
	FROM dbo.Customer WITH(NOLOCK) 
	WHERE CustID = @CustID

	SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

	CREATE TABLE #SportBettype_SB(	
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit]
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #SportBettype_SB(SportType,BetType,SettingType,IsLive)
	SELECT SportType,BetType,SettingType,IsLive
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@_SiteID,@_Currency)
	WHERE SettingType IN (26)
	
	--Sportsbook Bet setting
	INSERT INTO BetSetting_Agent(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch,RepUpdateTime)
	SELECT @custid
		,cs.SportType        
		,cs.BetType          
		,cs.MinBet           
		,cs.MaxBet           
		,cs.MaxPerMatch        
		,cs.MaxPayoutPerMatch
		,SYSDATETIME()
	FROM BetSetting_Agent cs WITH(NOLOCK)
		INNER JOIN #SportBettype_SB ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.SettingType = 26
	WHERE cs.custid = @ExistingCustid

	IF @@ERROR <> 0
	BEGIN
		--Error Occurs
		SELECT @ErrCode = 26
			
		-- ROLLBACK MANUALLY
		DELETE BetSetting_Agent WITH (ROWLOCK)
		OUTPUT DELETED.[CustID],DELETED.[Sporttype],DELETED.[Bettype],SYSDATETIME()
		INTO [BetSetting_Agent_Del_InHouse]([CustID],[Sporttype],[Bettype],[RepUpdateTime])
		WHERE custID = @custid
				
		RETURN
	END	
END