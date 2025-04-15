/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_DirectMember_Validate] 
(
	@creator INT,
	@username VARCHAR(30),
	@credit MONEY,	
	@SettingXML VARCHAR(MAX) = '', -- store all settings
	@Language 		VARCHAR(2)= 'E',
	@UplineID		INT, --SuperID/MasterID
	@ugroup			VARCHAR(5) = NULL,
	@SystemID		TINYINT=1,
	@IP 			VARCHAR(15)='',
	@ErrCode 		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg 		NVARCHAR(4000) = '' OUTPUT,
	@isSearchAndCopy BIT = 0,
	@ExistingCustID INT = 0,
	@SettingStatus TINYINT = 0
)
AS
/*
	Created: 20241107@Eden	
	Task: Validate when Super/Master create direct member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]  
		
	Parameter's Explanation:
	- @SettingXML:
		'{
			--Commission:
			"150": [
				{"SportType": "1","BetType": "1","Discount": "0.0010000"},
				{"SportType": "1","BetType": "5","Discount": "0.0030000"},
				{"SportType": "1","BetType": "4","Discount": "0.0035000"}
			],
			"156": [
				{"SportType": "9911","BetType": "2400","Discount": "0.0035000"},
				{"SportType": "175","BetType": "7901","Discount": "0.0025000"}
			],

			--BetSetting:
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
			"154": [
				{"SportType": "161","BetType": "81","MinBet": "0","MaxBet": "10","MPM": "10","MaxPerNumber": "10"},
				{"SportType": "164","BetType": "8101","MinBet": "0","MaxBet": "0","MPM": "0"}
			],

			--Parlay Maxpayout:
			"152": [
				{"SportType": "99","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"},
				{"SportType": "1","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"}
        
			],

			--PT:
			"153": [
				{"SportType": "9914","BetType": "915","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "917","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "917","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9915","BetType": "918","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "915","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "916","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "916","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9906","BetType": "4001","IsLive": "0","SuperPT": "38"},
				{"SportType": "9909","BetType": "3700","IsLive": "0","SuperPT": "38"},
				{"SportType": "9911","BetType": "2400","IsLive": "0","SuperPT": "38"},
				{"SportType": "9918","BetType": "4601","IsLive": "0","SuperPT": "38"}

			],

			--Winloss Limit:
			"155": [
					{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }

				],

			--Stake Level:
			"158": [
					{"SportType": "159","BetType": "3151","StakeLevelList": "3151"},
					{"SportType": "211","BetType": "2401","StakeLevelList": "3151"}
				],

			--Product Status:
			"160": [
					{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
					{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
				]
		}'	
	
*/	
BEGIN
	 SET NOCOUNT ON

	 DECLARE @currency INT
		,@srecommend INT
		,@mrecommend INT
		,@UplineCredit MONEY
		,@Credit_AllOtherDownline MONEY
		,@MaxCredit_Mem MONEY
	    ,@site NVARCHAR(50)	    		  
		,@uplineUsername NVARCHAR(50)
		,@SiteID int
		,@UplineRoleID TINYINT

	DECLARE
		--Discount	
		@GroupTypeT150 VARCHAR(MAX)= '', --Sportbook Comm
		@GroupTypeT156 VARCHAR(MAX)= '', --LCS Comm
		--Bet Setting
		@GroupTypeT151 VARCHAR(MAX)= '', --Sportbook Bet Setting
		@GroupTypeT154 VARCHAR(MAX)= '', --RNG Games
		--Parlay Max Payout
		@GroupTypeT152 VARCHAR(MAX)= '', --SB Parlay Max Payout
		--PT
		@GroupTypeT153 VARCHAR(MAX)= '', --PT all products
		--
		@GroupTypeT158 VARCHAR(MAX)= '', --Stake Level
		@GroupTypeT155 VARCHAR(MAX)= '', --WinLoss Limit
		@GroupTypeT160 VARCHAR(MAX)= '' --Product Status

	SELECT @siteID = s.siteid, @site = c.site
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @UplineID

	 -- check UM
	 EXEC [Acc_CheckUM] @CustID = @UplineID
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
	
	SELECT @uplineUsername = username
	, @mrecommend = NULLIF(mrecommend,0) -- Set mrecommend = NULL when Upline is Super
	, @srecommend = srecommend
	, @currency = currency
	, @UplineCredit = ISNULL(Credit, 0) 
	, @UplineRoleID = RoleID
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @UplineID

	--Super cannot create master direct member, master cannot create super direct member
	IF @creator IN (@srecommend, @mrecommend) AND @UplineID <> @creator
	BEGIN
			SELECT @ErrMsg = CASE @Language
						    WHEN 'E' THEN 'This function is under maintenance and not available at the moment. Please kindly check back later. Thank you!'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](90011, @Language)
					     END,
				   @ErrCode = 101
			RETURN
	END 

	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @UplineID , 
			@RuleID				= 'DAG' , 
			@existingMrecommend = @mrecommend , 
			@existingSrecommend = @srecommend , 
			@Prefix				= @uplineUsername , 
			@GroupName			= '' , 
			@IsQRCode			= 0 , 
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
	IF @creator = @UplineID
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
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @UplineID, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT 
    IF @ErrCode <>0	RETURN 

	IF @UplineRoleID NOT IN (3,4)--IF (@UplineID = @mrecommend) OR (@UplineID = @srecommend)
	BEGIN
		SELECT	@ErrMsg = CASE @Language
							WHEN 'E' THEN 'Invalid user'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
							END,
					@ErrCode = 350
		RETURN	
	END

   -- MyanmarOdds
	--DECLARE @IsMyanmarOdds BIT = 0
	--SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@UplineID)
	
	--IF @IsMyanmarOdds = 1 AND @ugroup <> 'a'
	--BEGIN
	--   SELECT	@ErrMsg = CASE @Language
	--					    WHEN 'E' THEN 'The selected group is not allowed for this site'
	--					    ELSE [dbo].[f_Get_MsgNamebyMsgID](40055,@Language)
	--					    END,
	--		     @ErrCode = 40055
	--    RETURN	
	--END

    --check ugroup
	IF (@site = '76666B' AND @ugroup <> 'a')
		OR (@currency = 45 AND @ugroup NOT IN ('dea','deb','dec','ded'))
		OR (@currency <> 45 AND @ugroup not in ('a', 'b', 'c', 'd', 'hka', 'hkb', 'hkc', 'hkd'))
		OR (@site = 'INDO' AND @ugroup like 'hk_')
	BEGIN
		SELECT @ErrCode = 12,
			@MsgType = 100,
			@ErrMsg =  '<Root MsgID="12" Msg="Unable to assign this commission group to the member." />'

		RETURN
	END
	
	SELECT  @username = rtrim(ltrim(@username))
    --SELECT @site=CASE WHEN @ugroup like 'indo_' THEN 'INDO' ELSE '' END, @ugroup = CASE WHEN @ugroup like 'indo_' THEN right(@ugroup,1) ELSE @ugroup END

    IF @UplineRoleID = 4
	BEGIN
		SELECT @Credit_AllOtherDownline = ISNULL(sum(Credit), 0) 
		FROM custinfo WITH(NOLOCK) 
		WHERE SRecommend = @UplineID 
			AND (RoleID = 3  --Masters
					OR (roleid = 1 AND recommend = -4) --Super direct members
				)
	END
	ELSE
	IF @UplineRoleID = 3
	BEGIN
		SELECT @Credit_AllOtherDownline = ISNULL(sum(Credit), 0) 
		FROM custinfo WITH(NOLOCK) 
		WHERE MRecommend = @UplineID 
			AND (RoleID = 2  --Masters
					OR (roleid = 1 AND recommend = -3) --master direct members
				)
	END

    IF @Credit + @Credit_AllOtherDownline > @UplineCredit
    BEGIN
	    SELECT @ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](70030,@Language), '{number}', FORMAT(@UplineCredit - @Credit_AllOtherDownline, '#,#0.####'))
			    , @ErrCode = 204
	    RETURN
    END

	IF @credit <0
		or @UplineID <=0
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
	--Parse Json
	BEGIN
		SELECT @GroupTypeT150 =	(
									SELECT SportType,BetType,Discount
									FROM OPENJSON(@SettingXML,'$."150"') WITH (
											SportType SMALLINT  '$.SportType'
											,BetType SMALLINT  '$.BetType'
											,Discount DECIMAL(9,8)  '$.Discount'
										)
									FOR JSON PATH
								)
										

		SELECT @GroupTypeT156 = (
									SELECT SportType,BetType,Discount
									FROM OPENJSON(@SettingXML,'$."156"') WITH (
											SportType SMALLINT  '$.SportType'
											,BetType SMALLINT  '$.BetType'
											,Discount DECIMAL(9,8)  '$.Discount'
										)
									FOR JSON PATH
								)

		
		SELECT @GroupTypeT151 = (
									SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout,MaxPerNumber
									FROM OPENJSON(@SettingXML,'$."151"') WITH (
											SportType SMALLINT  '$.SportType'
											,BetType SMALLINT  '$.BetType'
											,MinBet MONEY  '$.MinBet'
											,MaxBet MONEY  '$.MaxBet'
											,MPM MONEY  '$.MPM'
											,MaxPayout MONEY  '$.MaxPayout'
											,MaxPerNumber MONEY  '$.MaxPerNumber'
										)
									FOR JSON PATH
								)

		SELECT @GroupTypeT154 = (
									SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout,MaxPerNumber
									FROM OPENJSON(@SettingXML,'$."154"') WITH (
											SportType SMALLINT  '$.SportType'
											,BetType SMALLINT  '$.BetType'
											,MinBet MONEY  '$.MinBet'
											,MaxBet MONEY  '$.MaxBet'
											,MPM MONEY  '$.MPM'
											,MaxPayout MONEY  '$.MaxPayout'
											,MaxPerNumber MONEY  '$.MaxPerNumber'
										)
									FOR JSON PATH
								)
		
		SELECT @GroupTypeT152 = (
									SELECT SportType,BetType,SingleMP,Combo2,Combo35,Combo6
									FROM OPENJSON(@SettingXML,'$."152"') WITH (
											SportType SMALLINT  '$.SportType'
											,BetType SMALLINT  '$.BetType'
											,SingleMP MONEY  '$.SingleMP'
											,Combo2 MONEY  '$.Combo2'
											,Combo35 MONEY  '$.Combo35'
											,Combo6 MONEY  '$.Combo6'
										)
									FOR JSON PATH
								)

		SELECT @GroupTypeT153 = (
									SELECT SportType,BetType,IsLive,SuperPT,MasterPT
									FROM OPENJSON(@SettingXML,'$."153"') WITH (
											SportType SMALLINT  '$.SportType'
											,BetType SMALLINT  '$.BetType'
											,IsLive BIT  '$.IsLive'
											,SuperPT SMALLMONEY  '$.SuperPT'
											,MasterPT SMALLMONEY  '$.MasterPT'
										)
									FOR JSON PATH
								)

		SELECT @GroupTypeT155 = (
									SELECT SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
									FROM OPENJSON(@SettingXML,'$."155"') WITH (
											 SportType		SMALLINT
											,BetType		SMALLINT
											,MaxWinLimit	SMALLMONEY
											,MaxLossLimit	MONEY
											,IsAutoReset	BIT
										) AS Limit
									FOR JSON PATH
								)

		SELECT @GroupTypeT158 = (
									SELECT	ox.SportType, ox.BetType, ox.StakeLevelList
									FROM OPENJSON(@SettingXML,'$."158"') WITH (
											 SportType		SMALLINT
											,BetType		INT
											,StakeLevelList	VARCHAR(200)	
											) AS ox
									FOR JSON PATH
								)

		SELECT @GroupTypeT160 = (
									SELECT SportType, BetType, IsDisabled
									FROM OPENJSON(@SettingXML,'$."160"') WITH (
											 SportType			SMALLINT	
											,BetType			SMALLINT
											,IsDisabled			BIT
										) AS DisabledProductStatus
									FOR JSON PATH
								)

		--check comm
		EXEC Acc_CustomerInsMember_DiscountCheck_DirectMember
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@UplineRoleID =@UplineRoleID,
			@siteID = @siteID,
			@currency = @currency,
		
			@GroupTypeT150 = @GroupTypeT150, --SB
			@GroupTypeT156 = @GroupTypeT156, --LCS		
			@SettingStatus = @SettingStatus,
			@ugroup = @ugroup,
		
			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT
	
		IF @ErrCode > 0
			RETURN;
		
		EXEC Acc_CustomerInsMember_BetSettingCheck_DirectMember
			@srecommend =@srecommend,
			@mrecommend =@mrecommend,
			@siteid =@siteid,
			@currency =@currency,
		
			@GroupTypeT151 = @GroupTypeT151, --SB
			@GroupTypeT154 = @GroupTypeT154, --LCS	
			@SystemID = @SystemID,
			@SettingStatus  = @SettingStatus,
		
			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg  = @ErrMsg OUTPUT
	
		IF @ErrCode > 0
			RETURN;
		
		EXEC Acc_CustomerInsMember_ParlayMaxPayoutCheck_DirectMember
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@siteid =@siteid,
			@currency =@currency,
		
			@GroupTypeT152 = @GroupTypeT152, --SB
			@SettingStatus = @SettingStatus,
		
			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT
	
		IF @ErrCode > 0
			RETURN;
		
		EXEC Acc_CustomerInsMember_PTCheck_DirectMember
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@UplineRoleID =@UplineRoleID,		
			@siteid = @siteid,
			@currency = @currency,
		
			@GroupTypeT153 = @GroupTypeT153,
			@SettingStatus = @SettingStatus,

			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT

		IF @ErrCode > 0
			RETURN;

		EXEC Acc_CustomerInsMember_WinlossLimitCheck_DirectMember
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@UplineRoleID =@UplineRoleID,		
			@siteid = @siteid,
			@currency = @currency,
		
			@GroupTypeT155 = @GroupTypeT155,
			@SettingStatus = @SettingStatus,

			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT

		IF @ErrCode > 0
			RETURN;

		EXEC Acc_CustomerInsMember_StakeLevelCheck_DirectMember
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@UplineRoleID =@UplineRoleID,		
			@siteid = @siteid,
			@currency = @currency,
			@SystemID = @SystemID,
			@site = @Site,
		
			@GroupTypeT158 = @GroupTypeT158,
			@SettingStatus = @SettingStatus,

			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT

		IF @ErrCode > 0
			RETURN;

		EXEC Acc_CustomerInsMember_ProductStatusCheck_DirectMember
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@UplineRoleID =@UplineRoleID,		
			@siteid = @siteid,
			@currency = @currency,
			@SystemID = @SystemID,
		
			@GroupTypeT160 = @GroupTypeT160,
			@SettingStatus = @SettingStatus,

			@ErrCode = @ErrCode OUTPUT,
			@MsgType = @MsgType OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT

		IF @ErrCode > 0
			RETURN;
	END

END