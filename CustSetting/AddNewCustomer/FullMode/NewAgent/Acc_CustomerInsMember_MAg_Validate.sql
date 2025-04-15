/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROC Acc_CustomerInsMember_MAg_Validate
(
	@Language		VARCHAR(2)= 'E'
	,@mrecommend	INT
	,@credit		 MONEY
	,@maxcredit MONEY = 0
	,@creator		INT
	,@username		VARCHAR(30)
	,@IP			VARCHAR(15)=''	
	,@SettingXML	VARCHAR(MAX) = '' -- store all settings
	,@SettingStatus TINYINT = 0
	,@SystemID		TINYINT=1
	,@Site			NVARCHAR(50)
	,@ErrCode		INT = 0 OUTPUT
	,@MsgType		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(MAX) = '' OUTPUT
)
AS
/*
	Created: 20240704@Louisa
	Task : Validate Master Create Agent Full Mode
	DB: DBCUST/CustDB

	Revision:
		- 20240704@Louisa: Scaleout DBCUST [Redmine:#206823]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]  

	Param's Explanation:
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
  
	- @ErrMsg: Error description.
	- @SettingStatus: 0: Pro, 1: UAT
	- @SettingXML: Json format
	'{
		"150": [
			{"SportType": "1","BetType": "1","Discount": "0.0010000"},
			{"SportType": "1","BetType": "3","Discount": "0.0015000"},
			{"SportType": "1","BetType": "5","Discount": "0.0070000"},
			{"SportType": "1","BetType": "7","Discount": "0.0020000"},
			{"SportType": "1","BetType": "4","Discount": "0.0035000"},
			{"SportType": "1","BetType": "8","Discount": "0.0025000"}
		],
		"151": [
			{"SportType": "1","BetType": "9","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "2","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "9902","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "1","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "9901","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "11","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "99","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "3","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "5","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "8","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "10","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
			{"SportType": "99","BetType": "9","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
			{"SportType": "43","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10"},
			{"SportType": "44","BetType": "3","MinBet": "0","MaxBet": "0","MPM": "0"}
		],
		"152": [
			{"SportType": "99","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"},
			{"SportType": "1","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"}
        
		],
		"153": [
			{"SportType": "9914","BetType": "915","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9914","BetType": "917","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "917","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9915","BetType": "918","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "915","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9913","BetType": "916","IsLive": "1","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"},
			{"SportType": "9914","BetType": "916","IsLive": "0","MasterPT": "20","IsAutoMasterPT": "0","AutoMasterPT": "0.0000","AgentPT": "38","MinPT": "0"}
		]
	}'
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @uplineUsername NVARCHAR(50)
			,@currency INT
			,@srecommend INT
			,@Credit_AllOtherDownline MONEY
			,@Credit_MAg MONEY
			,@SiteID int
			,@SettingType25	VARCHAR(MAX)= ''
			,@SettingType26	VARCHAR(MAX)= ''
			,@SettingType27	VARCHAR(MAX)= ''
			,@SettingType28	VARCHAR(MAX)= ''

	EXEC [Acc_CheckUM] @CustID = @mrecommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN
	
	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END

	SELECT @uplineUsername = username 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @mrecommend

	SELECT @Site = c.site, @siteID = s.siteID, @currency = currency, @srecommend = srecommend
	FROM customer c WITH(NOLOCK) 
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @mrecommend
	
	SELECT @Credit_MAg = isnull(credit, 0)
	FROM CustInfo ci WITH(NOLOCK) 
	WHERE CustID = @mrecommend

	SELECT @Credit_AllOtherDownline = ISNULL(sum(Credit), 0) 
	FROM custinfo WITH(NOLOCK) 
	WHERE MRecommend = @mrecommend 
		AND (RoleID = 2  --Masters
				OR (roleid = 1 AND recommend = -3) --master direct members
			)

    IF @Credit_AllOtherDownline + @Credit >@Credit_MAg
    BEGIN
		SET @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@Credit_MAg - @Credit_AllOtherDownline, '#,#0.####'))

	    SELECT @ErrCode = 104
	    return
    END

    IF (isnull(@maxcredit ,0) > @credit )
    BEGIN 
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70034,@Language) , '{number}', FORMAT(@maxcredit, '#,#0.####')),  
			@ErrCode = 116  
		RETURN  
    END 
			
	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @mrecommend , 
			@RuleID				= 'MAG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
			@IsQRCode			= 0 , 
			@SystemID			= 0 , 
			@IP					= @IP ,
			@Credit				= @Credit ,
			@ErrCode			= @ErrCode OUTPUT , 
			@ErrMsg				= @ErrMsg OUTPUT , 
			@Language			= @Language

	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode , @ErrMsg
		RETURN		
	END

	---- check constraint on prefix username same as upline in case of creating new customer from alpha site
	IF @creator = @mrecommend
	BEGIN
		IF LEFT(@username,LEN(@uplineUsername)) <> @uplineUsername
		BEGIN
			SELECT @ErrMsg = CASE @Language
						    WHEN 'E' THEN 'This function is under maintenance and not available at the moment. Please kindly check back later. Thank you!'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](90011, @Language)
					     END,				   
				   @ErrCode = 101
			RETURN
		END
	END 

	 --Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable 
		@custid = @mrecommend
		, @ErrCode=@ErrCode OUTPUT
		,@ErrMsg=@ErrMsg OUTPUT 
    
	IF @ErrCode <>0	
		RETURN

	------------------------------
	--Parse Json to XML param
	SELECT @SettingType25 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,Discount
					FROM OPENJSON(@SettingXML,'$."150"') WITH (
							SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,Discount DECIMAL(9,8)  '$.Discount'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType26 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout
					FROM OPENJSON(@SettingXML,'$."151"') WITH (
							SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,MinBet MONEY  '$.MinBet'
							,MaxBet MONEY  '$.MaxBet'
							,MPM MONEY  '$.MPM'
							,MaxPayout MONEY  '$.MaxPayout'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType27 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,SingleMP,Combo2,Combo35,Combo6
					FROM OPENJSON(@SettingXML,'$."152"') WITH (
							 SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,SingleMP MONEY  '$.SingleMP'
							,Combo2 MONEY  '$.Combo2'
							,Combo35 MONEY  '$.Combo35'
							,Combo6 MONEY  '$.Combo6'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

	SELECT @SettingType28 = CONVERT(VARCHAR(MAX),
				(
					SELECT SportType,BetType,IsLive,MasterPT,IsAuto,AutoPT,AgentPT,MinPT
					FROM OPENJSON(@SettingXML,'$."153"') WITH (
							SportType SMALLINT  '$.SportType'
							,BetType SMALLINT  '$.BetType'
							,IsLive BIT  '$.IsLive'
							,MasterPT SMALLMONEY  '$.MasterPT'
							,IsAuto BIT  '$.IsAutoMasterPT'
							,AutoPT SMALLMONEY  '$.AutoMasterPT'
							,AgentPT SMALLMONEY  '$.AgentPT'
							,MinPT SMALLMONEY  '$.MinPT'
						)
					FOR XML RAW('R'), ROOT ('Root'), TYPE
				)
			)

		--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
	
	--Check bet setting
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType26 = @SettingType26 OUTPUT, --SB
		@SystemID = @SystemID,
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;
		
	--Check Parlay Max Payout
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_MAg
		@mrecommend = @mrecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType27 = @SettingType27 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;		
		
	--Check PT
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_MAg
		@mrecommend = @mrecommend,
		@srecommend = @srecommend,
		@siteID = @siteID,
		@currency = @currency,
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingStatus = @SettingStatus,
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT	

	IF @ErrCode > 0 
		RETURN;	

END
GO