CREATE PROCEDURE [dbo].[Acc_CustSetting_WinLimitCheck] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @WinLimit		VARCHAR(MAX)
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160108@Elodie
	Task : Check Customer's Win Limits
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	• @WinLimit:
		<ROOT>
				<WinLimit 
						SportType="1" 
						BetType="1" 
						MaxWinLimit="2" 
						IsAutoReset="0" 
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UplineLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		SMALLMONEY
			, IsAutoReset		BIT
			)
	DECLARE @NewWinLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		SMALLMONEY
			, IsAutoReset		BIT
			)
	
	IF @WinLimit IS NULL OR @WinLimit = ''
		RETURN
	
	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	IF @RoleId NOT IN (1, 2, 3, 4)
    BEGIN       
		SELECT @ErrMsg = '<Root MsgID="40002" Msg="Invalid user!" />'
                        , @ErrCode = 1                    
						, @MsgType = 100--just return msgID
        RETURN
    END

	--Parse XML data
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @WinLimit

	INSERT @NewWinLimitTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/WinLimit', 1) WITH (
						SportType		SMALLINT
						, BetType		SMALLINT
						, MaxWinLimit	SMALLMONEY
						, IsAutoReset	BIT
						)

	EXEC sp_xml_removedocument @iDoc

	IF @RoleID = 3
	BEGIN
		--Get super 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLimit3rd_Agent wl WITH (NOLOCK)
			INNER JOIN @NewWinLimitTbl tmp ON tmp.SportType	= wl.SportType AND tmp.BetType = wl.BetType
		WHERE wl.CustID	= @SuperID		
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Get master 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLimit3rd_Agent wl WITH (NOLOCK)
			INNER JOIN @NewWinLimitTbl tmp ON tmp.SportType	= wl.SportType AND tmp.BetType = wl.BetType
		WHERE wl.CustID	= @MasterID
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Get agent 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLimit3rd_Agent wl WITH (NOLOCK)
			INNER JOIN @NewWinLimitTbl tmp ON tmp.SportType	= wl.SportType AND tmp.BetType = wl.BetType
		WHERE wl.CustID	= @AgentID
	END			

	--Check Upline's win limit >= Win Limit
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewWinLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
			)
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="10024" Msg="Maximum Win should be less than or equal to Maximum Win of Direct Upline!" />'
                        , @ErrCode = 2                    
						, @MsgType = 100--just return msgID
        RETURN	
	END
	
	--Check Upline's auto reset = 0 and auto reset = 1
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewWinLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.IsAutoReset = 1 AND nwl.IsAutoReset = 0
			)
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="10022" Msg="You are not allowed to change Daily auto reset limit." />'
                        , @ErrCode = 3               
						, @MsgType = 100--just return msgID
        RETURN	
	END
	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLimitCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLimitCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLimitCheck] TO [bodbExtAccNet]