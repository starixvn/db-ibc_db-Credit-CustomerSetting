/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Ag_Validate] 
(
	@creator INT,
	@username VARCHAR(30),
	@credit MONEY,	
	@SettingXML VARCHAR(MAX) = '', -- store all settings
	@Language 		VARCHAR(2)= 'E',
	@recommend		INT,
	@ugroup			VARCHAR(5) = NULL,
	@SystemID		TINYINT=1,
	@IP 			VARCHAR(15)='',
	@ErrCode 		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg 		NVARCHAR(4000) = '' OUTPUT,
	@isSearchAndCopy BIT = 0,
	@ExistingCustID INT = 0,
	@IsQRCode 		BIT  = 0,
	@SettingStatus TINYINT = 0
)
AS
/*
	Created: Helen
	Date: 2024-07-04
	Task: Full Mode - Agent create member - validate
	DB: DBCUST.CustDB
	
	Revisions:
		- 20240704@Helen: Full Mode - Agent create member - validate - [Redmine:#206823]
		
	Parameter's Explanation:
	
*/	
BEGIN
	 SET NOCOUNT ON

	 DECLARE 
		@currency INT
		,@srecommend INT, @mrecommend INT
		,@AgentCredit MONEY
		,@Credit_AllOtherMember MONEY
		,@MaxCredit_Mem MONEY
	    ,@site NVARCHAR(50)	    		  
		,@uplineUsername NVARCHAR(50)
		,@SettingType25 VARCHAR(MAX)= ''
		,@SettingType26 VARCHAR(MAX)= ''
		,@SettingType27 VARCHAR(MAX)= ''
		,@SettingType28 VARCHAR(MAX)= ''
		,@SiteID int

	SELECT @siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @recommend

	 -- check UM
	 EXEC [Acc_CheckUM] @CustID = @recommend
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN

	IF @credit < 0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END
	
	SELECT @uplineUsername = username, @mrecommend = mrecommend, @srecommend = srecommend, @currency = currency,  @AgentCredit = ISNULL(Credit, 0) 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @recommend

	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @recommend , 
			@RuleID				= 'AG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
			@IsQRCode			= @IsQRCode , 
			@SystemID			= @SystemID , 
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
	---- check constraint on prefix username same as upline in case of creating member from alpha site
	IF @creator = @recommend
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

	--Check an account disabled OR not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @recommend, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT 
    IF @ErrCode <>0	RETURN 

	  IF (@recommend = @mrecommend) OR (@recommend = @srecommend)
    BEGIN
	    SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'Invalid user'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						    END,
			     @ErrCode = 350
	    RETURN	
    END

   -- MyanmarOdds
	DECLARE @IsMyanmarOdds BIT = 0
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
	
	IF @IsMyanmarOdds = 1 AND @ugroup <> 'a'
	BEGIN
	   SELECT	@ErrMsg = CASE @Language
						    WHEN 'E' THEN 'The selected group is not allowed for this site'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40055,@Language)
						    END,
			     @ErrCode = 40055
	    RETURN	
	END

	 --Check member group under Won currency
    IF @currency = 45 AND @ugroup NOT IN ('dea','deb','dec','ded')-- Won currency
	    BEGIN
		    SELECT @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Unable to assign this group to the customer.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40017,@Language)
							    END,
				    @ErrCode = 300
		    RETURN			
	    END
    	
    IF @currency <> 45 AND @ugroup IN ('dea','deb','dec','ded') -- Others currency
	    BEGIN
		    SELECT @ErrMsg = CASE @Language
							    WHEN 'E' THEN 'Unable to assign this group to the customer.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40017,@Language)
							    END,
				    @ErrCode = 301
		    RETURN			
	    END
	
	SELECT  @username = rtrim(ltrim(@username))
    SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

	SELECT @MaxCredit_Mem = ISNULL(maxcredit,0) FROM custAgent WITH(NOLOCK)  WHERE CustID = @recommend

    SELECT @Credit_AllOtherMember = ISNULL(sum(Credit), 0) FROM custinfo WITH(NOLOCK) WHERE Recommend = @Recommend AND RoleID = 1
    SELECT @MaxCredit_Mem = CASE WHEN @MaxCredit_Mem =0 THEN (@AgentCredit - @Credit_AllOtherMember) 
						    ELSE @MaxCredit_Mem END 
    IF @Credit + @Credit_AllOtherMember>@AgentCredit
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@AgentCredit - @Credit_AllOtherMember, '#,#0.####'))
			    , @ErrCode = 204
	    RETURN
    END

    IF @Credit > @MaxCredit_Mem 
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70032,@Language), '{number}', FORMAT(@MaxCredit_Mem, '#,#0.####'))
			    , @ErrCode =217
	    RETURN
    END 

	IF @credit <0
		or @recommend <=0
		or @ugroup not in ('a','b','c','d','hka','hkb','hkc','hkd','indoa','indob','indoc','indod','dea','deb','dec','ded')
	BEGIN
		select @ErrCode = 102
				,@ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per ball/ Max per match/ Credit/ Agent name/ user group.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10001,@Language)
					end
		RETURN
	END

	---- check settingtype
	--Parse Json to XML param
	IF @isSearchAndCopy = 1 --Clone Setting --> Get Setting from SourceCustID
	BEGIN
		EXEC Acc_CustomerIns_CloneMemberSetting_Sel
			 @siteid = @siteID
			,@currency = @currency
			,@ExistingCustID = @ExistingCustID
			,@AgentID = @recommend
			,@SettingType25 = @SettingType25 OUT
			,@SettingType26 = @SettingType26 OUT
			,@SettingType27 = @SettingType27 OUT
			,@SettingType28 = @SettingType28 OUT
			,@SettingStatus = @SettingStatus
	END
	ELSE --Fullmode --> Get setting from Json input value
	BEGIN
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
						SELECT SportType,BetType,IsLive,AgentPT
						FROM OPENJSON(@SettingXML,'$."153"') WITH (
								SportType SMALLINT  '$.SportType'
								,BetType SMALLINT  '$.BetType'
								,IsLive BIT  '$.IsLive'
								,AgentPT SMALLMONEY  '$.AgentPT'
							)
						FOR XML RAW('R'), ROOT ('Root'), TYPE
					)
				)
	END

	--check comm
	EXEC Acc_LiteMode_CustomerInsMember_DiscountCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,
		@siteID = @siteID,
		@currency = @currency,
		
		@SettingType25 = @SettingType25 OUTPUT, --SB
		@SettingStatus = @SettingStatus,
		@ugroup = @ugroup,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	EXEC Acc_LiteMode_CustomerInsMember_BetSettingCheck_Ag
		@srecommend =@srecommend,
		@mrecommend =@mrecommend,
		@recommend =@recommend,
		@siteid =@siteid,
		@currency =@currency,
		
		@SettingType26 = @SettingType26, --SB
		@SystemID = @SystemID,
		@SettingStatus  = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg  = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	EXEC Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,
		@siteid =@siteid,
		@currency =@currency,
		
		@SettingType27 = @SettingType27, --SB
		@SettingStatus = @SettingStatus,
		
		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
		
	EXEC Acc_LiteMode_CustomerInsMember_PTCheck_Ag
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@recommend = @recommend,		
		@siteid = @siteid,
		@currency = @currency,
		
		@SettingType28 = @SettingType28 OUTPUT,-- SB
		@SettingStatus = @SettingStatus,

		@ErrCode = @ErrCode OUTPUT,
		@MsgType = @MsgType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT

	IF @ErrCode > 0
		RETURN;

END