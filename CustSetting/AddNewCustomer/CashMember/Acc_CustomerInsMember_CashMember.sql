/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CashMember]
	@custid INT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@BankId	INT = NULL,
	@AccountNumber VARCHAR(100) = NULL,	
	--
	@SettingXML VARCHAR(MAX) = '', -- store all settings
	--
	@Language 		VARCHAR(2)= 'E',
	@SubAccID 		INT = 0, --Sub-AccountID
	@UplineID		INT,
	@SystemID		TINYINT=1,
	@IP 			VARCHAR(15)='',

	@ErrCode 		INT = 0 OUTPUT,
	@MsgType		INT = 0 OUTPUT,
	@ErrMsg 		NVARCHAR(4000) = '' OUTPUT,
	--
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20250424@Elodie
	Task: Agent create cash member - Insert setting
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
		
	Parameter's Explanation:
	
*/	
BEGIN
    SET NOCOUNT ON
	--RETURN	

	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT

    SET @startRun = GETDATE()

    DECLARE @currency INT, 
		@pwdexpiry datetime, 
		@srecommend INT, 
		@mrecommend INT,
		@recommend INT,
		@UplineRoleID TINYINT,
	    @UplineClosed BIT,
	    @DisableOutright BIT,	   
		@suspended BIT = 0,
	    @UplineDanger tinyint,
	    @UplineDanger2 tinyint,
	    @UplineDanger3 tinyint,
		@UplineDanger4 tinyint,
	    @UplineDanger5 tinyint,
	    @AgentAbnormal tinyint,
	    -- check autosuspend's upline
	    @autosuspend BIT,
	    @autosuspend2 BIT,
		@autosuspend3 BIT,	
		@SiteID int,
		@_Site VARCHAR(10) ,	    		  
		@DisableSuperLive BIT = 0,
	    @matchlimit SMALLMONEY,
		@Closed BIT = 0, 
		@Suspend BIT = 0,
		@ugroup	VARCHAR(5) = 'a'
	DECLARE @EnableVR BIT
	
	SELECT @_Site = c.site,
		@siteID = s.siteid
	FROM dbo.customer c WITH(NOLOCK)
		INNER JOIN site s WITH(NOLOCK) ON c.site = s.site
	WHERE CustID = @UplineID

    SELECT @currency = currency
		 , @recommend = recommend
         , @mrecommend = mrecommend
         , @srecommend = srecommend
         , @UplineClosed = cs.closed
         , @matchlimit = matchlimit
         , @UplineDanger = 0
         , @UplineDanger2 = 0
         , @UplineDanger3 = 0
		 , @UplineDanger4 = 0
         , @UplineDanger5 = 0
         , @AgentAbnormal = 0
         , @autosuspend = ISNULL(autosuspend, 0)
         , @autosuspend2 = ISNULL(autosuspend2, 0)
		 , @autosuspend3 = ISNULL(autosuspend3, 0)
         
         , @DisableOutright = DisableOutright   
         , @EnableVR = ISNULL(virtualmultiplier, 1)           
		 , @DisableSuperLive = DisableSuperLive
		 , @UplineRoleID = ci.roleid
    FROM custinfo ci WITH(NOLOCK)	
	CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
						,CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject									
				FROM dbo.CustProductStatus  WITH(NOLOCK)
				WHERE CustID = ci.custid
				) AS cs
    WHERE CustID = @UplineID	
		  
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    SELECT  @username = RTRIM(LTRIM(@username))

    SELECT @pwdexpiry = DATEADD(dd, -1, GETDATE())

	IF @UplineClosed = 1
		SET @Closed = 1

	--select @custid, @username, @srecommend, @mrecommend, @UplineRoleID
    --Insert general data 
    BEGIN TRY
		EXEC dbo.Acc_CustomerInsUserInfo_CashMember
			@custid = @custid,
			@firstname = @firstname,
			@lastname = @lastname,
			@creator = @creator,
			@username = @username,
			@userpwd = @userpwd,
			@pwdexpiry = @pwdexpiry,
			@currency = @currency,
			@site = @_site,
			@ugroup = @ugroup,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,
			@recommend = @recommend,
			@UplineID = @UplineID,
			@roleid = 1,
			@Danger = @UplineDanger,
			@Danger2 = @UplineDanger2,
			@Danger3 = @UplineDanger3,
			@Danger4 = @UplineDanger4,
			@Danger5 = @UplineDanger5,
			@Abnormal = @AgentAbnormal,
			@phone = @phone,
			@mobilephone = @mobilephone,
			@email = '',
			@fax = '',
			@BankId = @BankId,
			@AccountNumber = @AccountNumber,
			@address = '',
			@city = '',
			@state = '',
			@country = '',
			@postal = '',
			@closed = @Closed,
			@DisableOutright = @DisableOutright,	
			@matchlimit = @matchlimit,
			@virtualmultiplier = @EnableVR,
			@autosuspend = @autosuspend,
			@autosuspend2 = @autosuspend2,
			@autosuspend3 = @autosuspend3,
			@DoubleCommLosing = 0,-- off double comm losing WHEN create new member   	 
			@DisableSuperLive = @DisableSuperLive,
			@credit = 0,	
			@IP = @IP,
    		@SystemID=@SystemID,
			@Language = @Language,
			@ErrCode = @ErrCode OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT

		IF @ErrCode <> 0
		BEGIN
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = @@ERROR
				,@ErrMsg = ERROR_MESSAGE()

		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END CATCH

	BEGIN TRY
		EXEC Acc_CustSettingIns_CashMember
			@custid = @custid,
			@srecommend = @srecommend,
			@mrecommend = @mrecommend,	
			@recommend = @recommend,
			@UplineRoleID = @UplineRoleID,			
			@siteID = @siteID,
			@currency = @currency,
			@SystemID = @SystemID,		
			@SettingXML = @SettingXML,
			@SettingStatus = @SettingStatus,
			@ErrCode = @ErrCode OUTPUT

		IF @ErrCode > 0
		BEGIN
			SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Create customer fail. Please try again'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					END
    				
			EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 1
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
			RETURN
		END	

		--Correct PT
		EXEC dbo.Acc_CustomerInfo_Execrep_01
			@custid = @custid, 
			@srecommend = @srecommend, 
			@mrecommend = @mrecommend, 
			@recommend = @recommend,
			@mode = 'LiteMode'   
	
		If @SystemID IN (2, 10) -- ALPHA, Chatbot
		BEGIN
			EXEC Age_LimitPTDailyIns @ServiceType = 1, @SettingStatus = @SettingStatus, @Actorid=@creator,@custid=@CustID,@ErrMsg=@ErrMsg OUTPUT,@ErrCode=@ErrCode OUTPUT
			IF @ErrCode > 0
			BEGIN
				SELECT @ErrMsg = CASE @Language 
									when 'E' then 'Create member fail. Please try again'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
								END
						, @ErrCode=216	
				-- ROLLBACK MANUALLY	
				EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 1		
				EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
				RETURN
			END	
		END
	END TRY
	BEGIN CATCH
		--Error occurs
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create member fail. Please try again'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
							END	
				, @ErrCode=216
    	
		-- ROLLBACK MANUALLY	
		EXEC Acc_CustomerInsSetting_Rollback @CustID = @CustID, @RoleID = 1
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END CATCH

    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)   

    Declare @LogSPData VARCHAR(8000)
    --Log customer general info
    SELECT @LogSPData = '<R custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)), SPACE(1))) + '" ' +
    'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)), SPACE(1))) + '" ' +
    'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
    'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
    'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)), SPACE(1))) + '" ' +   
    'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@BankId AS VARCHAR(50)), SPACE(1))) + '" ' +
	'BankId="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)), SPACE(1))) + '" ' +
	'AccNumber="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@AccountNumber AS VARCHAR(100)), SPACE(1))) + '" ' +
	'recommend="'+ COALESCE(CAST(@recommend AS VARCHAR(50)), SPACE(1)) + '" ' +    
    'ugroup="'+ COALESCE(CAST(@ugroup AS VARCHAR(5)), SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +   
	'SystemId="'+ cast(@SystemID as VARCHAR(3)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)), SPACE(1)) + '" />'
	
	DECLARE @ActionID INT 
	SELECT @ActionID = CASE WHEN @systemID = 10 THEN 264002 --telegram chatbot
							ELSE  264002 -- Multiple customers
							END		
						
    
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = @ActionID,
		@TrackingValue = @LogSPData,
		@duration = @duration
	
 	
    --Log statuses
	--write log product status
	DECLARE @LogDataSP2 VARCHAR(4000) = ''
	
	CREATE TABLE #tempSportbettypeSetting(ProductID TINYINT,SportType SMALLINT, Bettype SMALLINT, SettingType SMALLINT, GroupID TINYINT)
	CREATE TABLE #tempProductOfferStatus(custIsHidden BIT, Name VARCHAR(50))
	CREATE TABLE #TmpProductSettingDetail(
		[SettingType] [smallint] ,
		[SportType] [smallint] ,
		[BetType] [smallint] ,
		[IsLive] [bit] ,	
		[SettingLevel] [tinyint] ,
		[ProductID] [tinyint] ,	
		[Child_DisplayOrder] [int] ,
		GroupID [TINYINT],
		GroupType TINYINT,
		RealProductId	TINYINT
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #TmpProductSettingDetail(SettingType,SportType,BetType,IsLive,GroupID,Child_DisplayOrder,SettingLevel,ProductID,GroupType,RealProductId)
	SELECT SettingType,SportType,BetType,IsLive,GroupID,Child_DisplayOrder,SettingLevel,ProductID,GroupType,RealProductId
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@siteID,@currency)	

	INSERT INTO #tempSportbettypeSetting(ProductID,SportType,Bettype,SettingType,GroupID)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType	,GroupID
	FROM #TmpProductSettingDetail
	WHERE SettingType IN (4,11,13,21)
		AND RealProductId NOT IN (24,59)
	
	INSERT INTO #tempProductOfferStatus(custIsHidden, Name)
	SELECT MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden, REPLACE(REPLACE(MAX(p.ProductName), ' ', ''),'*','') 
	FROM #tempSportbettypeSetting psd WITH(NOLOCK)
		INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
															AND	psd.BetType = psp.Bettype
		INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
		CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
		INNER JOIN dbo.Products p WITH (NOLOCK)  ON p.ProductID = psd.ProductID
	WHERE psd.ProductID <> 20 
		AND ISNULL(psd.GroupID,0) NOT IN (3)
	GROUP BY psd.ProductID

	INSERT INTO #tempProductOfferStatus(CustIsHidden,Name)
	SELECT MIN(CAST(Hi.[Value] AS INT)) AS custIsHidden, 'GroupID' + CAST(psd.GroupID AS VARCHAR(10))
	FROM #tempSportbettypeSetting psd WITH(NOLOCK)
		INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
															AND	psd.BetType = psp.Bettype
		INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
		CROSS APPLY(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, psp.bitmapOrder)) AS Hi
	WHERE psd.ProductID <> 20 
		AND ISNULL(psd.GroupID,0) IN (3)
	GROUP BY psd.GroupID

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' + t.Name  + '="' + COALESCE(CAST(t.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM #tempProductOfferStatus t
	
	SELECT @LogDataSP2	= @LogDataSP2 
						+ 'Disable' + CAST(Sporttype AS VARCHAR) + '_' + CAST(Bettype AS VARCHAR)
						+ '="' + COALESCE(CAST(custIsDisable AS VARCHAR(1)), SPACE(1)) + '" '
	FROM (
		SELECT	psp.Sporttype,
				psp.Bettype,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsDisabled, psp.bitmapOrder)) AS custIsDisable
		FROM		#tempSportbettypeSetting AS psd WITH(NOLOCK)
			INNER JOIN	ProductStatusProfile AS psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype AND psd.BetType = psp.Bettype 
			CROSS APPLY CustProductStatus WITH(NOLOCK)
		WHERE CustID = @custid AND (psd.ProductID <> 20)
	)iq

	--Log for VR lock Status
	DECLARE @VRLockedStatus_Soccer BIT = 0
	DECLARE @VRLockedStatus_OS BIT = 0
	DECLARE @VRLockedStatus_Basketball BIT = 0
	--Log for VR+
	DECLARE @VRAccumulatedBalance BIT = 0

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @UplineID AND Type = 1)
		SET @VRLockedStatus_Soccer = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @UplineID AND Type = 2)
		SET @VRLockedStatus_OS = 1

	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @UplineID AND Type = 3)
		SET @VRLockedStatus_Basketball = 1
	
	IF EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @UplineID AND Type = 4)
		SET @VRAccumulatedBalance = 1

    SELECT @LogSPData = '<R custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
    'closed="'+ COALESCE(CAST(@UplineClosed AS VARCHAR(50)), SPACE(1)) + '" ' +
    'suspended="'+ COALESCE(CAST(@suspended AS VARCHAR(50)), SPACE(1)) + '" ' +
    'Danger="'+ COALESCE(CAST(@UplineDanger AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger2="'+ COALESCE(CAST(@UplineDanger2 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Danger3="'+ COALESCE(CAST(@UplineDanger3 AS VARCHAR(5)), SPACE(1)) + '" ' +
	'Danger4="'+ COALESCE(CAST(@UplineDanger4 AS VARCHAR(5)), SPACE(1)) + '" ' +
	'Danger5="'+ COALESCE(CAST(@UplineDanger5 AS VARCHAR(5)), SPACE(1)) + '" ' +
    'Abnormal="'+ COALESCE(CAST(@AgentAbnormal AS VARCHAR(5)), SPACE(1)) + '" ' +
	--20171206@Johnson: add more log for status
	'Special=" " ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend3="'+ COALESCE(CAST(@autosuspend3 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(@EnableVR AS VARCHAR(10)),SPACE(1)) + '" ' +	
	'VRAccumulatedBalance="'+ COALESCE(CAST(@VRAccumulatedBalance AS VARCHAR(10)),SPACE(1)) + '" ' +  
	'VRLockStatus_Soccer="'+ COALESCE(CAST(@VRLockedStatus_Soccer AS VARCHAR(10)),SPACE(1)) + '" ' +   
	'VRLockStatus_OtherSports="'+ COALESCE(CAST(@VRLockedStatus_OS AS VARCHAR(10)),SPACE(1)) + '" ' +   
 	'VRLockStatus_Basketball="'+ COALESCE(CAST(@VRLockedStatus_Basketball AS VARCHAR(10)),SPACE(1)) + '" ' +   

    'DisableOutright="'+ COALESCE(CAST(@DisableOutright AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataSP2 +
   
	'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)), SPACE(1)) + '" />'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 169001,
		@TrackingValue = @LogSPData,
		@duration = @duration  
	
	DECLARE @DiscountTbl TABLE (
		sporttype SMALLINT, 
		bettype SMALLINT, 
		playerdiscount DECIMAL(9,8), 
		AgentDiscount DECIMAL(9,8),									
		MasterDiscount DECIMAL(9,8),
		SuperDiscount DECIMAL(9,8),
		GroupID	TINYINT,
		Child_DisplayOrder  INT
	)

	DECLARE @BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY,
		GroupID			  TINYINT,
		Child_DisplayOrder  INT
		PRIMARY KEY(sporttype, Bettype)
	);

	DECLARE @MaxPayoutTbl TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		, GroupID			TINYINT
		, Child_DisplayOrder  INT
		)	

	DECLARE @PTTbl TABLE (
		SportType		SMALLINT,
		BetType			SMALLINT,
		IsLive			BIT,
		AgentPT			SMALLMONEY,		
		MasterPT		SMALLMONEY,		
		SuperPT			SMALLMONEY,		
		GroupID			TINYINT,
		Child_DisplayOrder  INT,
		ProductID 		TINYINT,
		SettingLevel	TINYINT 
	)

	DECLARE @WinLossLimitTbl TABLE (
		SportType SMALLINT
		,BetType SMALLINT
		,MaxWinLimit MONEY
		,MaxLossLimit MONEY
		,IsAutoReset BIT
		,SettingLevel TINYINT
		,ProductID TINYINT
		,GroupID TINYINT
		,Child_DisplayOrder INT
	)

	DECLARE @StakeLevelTbl TABLE(
		 SportType SMALLINT
		,BetType SMALLINT
		,StakeLevelList	VARCHAR(200)
		,SettingType SMALLINT
		,SettingLevel TINYINT
		,ProductID TINYINT	
		,GroupID TINYINT
		,Child_DisplayOrder INT
	)

	--Comm
	INSERT INTO @DiscountTbl(sporttype,bettype,playerdiscount,GroupID,Child_DisplayOrder)
	SELECT t.SportType,t.BetType,0,t.GroupID,t.Child_DisplayOrder
	FROM #TmpProductSettingDetail t 			
	WHERE t.GroupType IN (150,156)	

	--Correct comm get from setting
	UPDATE t 
	SET t.playerdiscount = cs.PlayerDiscount,
		t.SuperDiscount = cs.SuperDiscount,
		t.MasterDiscount = cs.MasterDiscount,
		t.AgentDiscount = cs.AgentDiscount
	FROM CustDiscount3rd_Member cs WITH(NOLOCK)
		INNER JOIN @DiscountTbl t 
			ON t.sporttype = cs.SportType
			AND t.bettype = cs.BetType
			AND cs.CustID = @custid

	--Bet Setting
	INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch,MaxPerNumber,GroupID,Child_DisplayOrder)
	SELECT cs.SportType,cs.BetType,cs.MinBet,cs.MaxBet,cs.MPM,cs.MaxPayout,cs.MaxPerNumber,t.GroupID,t.Child_DisplayOrder
	FROM OPENJSON(@SettingXML,'$."151"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,MinBet MONEY  '$.MinBet'
			,MaxBet MONEY  '$.MaxBet'
			,MPM MONEY  '$.MPM'
			,MaxPayout MONEY  '$.MaxPayout'
			,MaxPerNumber MONEY  '$.MaxPerNumber'
		) cs
	INNER JOIN #TmpProductSettingDetail t 
			ON cs.SportType = t.SportType
			AND cs.BetType = t.BetType
	WHERE t.GroupType = 151

	INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch,MaxPerNumber,GroupID,Child_DisplayOrder)
	SELECT cs.SportType,cs.BetType,cs.MinBet,cs.MaxBet,cs.MPM,cs.MaxPayout,cs.MaxPerNumber,t.GroupID,t.Child_DisplayOrder
	FROM OPENJSON(@SettingXML,'$."154"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,MinBet MONEY  '$.MinBet'
			,MaxBet MONEY  '$.MaxBet'
			,MPM MONEY  '$.MPM'
			,MaxPayout MONEY  '$.MaxPayout'
			,MaxPerNumber MONEY  '$.MaxPerNumber'
		) cs
	INNER JOIN #TmpProductSettingDetail t 
			ON cs.SportType = t.SportType
			AND cs.BetType = t.BetType
	WHERE t.GroupType = 154

	--Max parlay payout
	INSERT INTO @MaxPayoutTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6,GroupID,Child_DisplayOrder)
	SELECT cs.SportType,cs.BetType,cs.SingleMP,cs.Combo2,cs.Combo35,cs.Combo6,t.GroupID,t.Child_DisplayOrder
	FROM OPENJSON(@SettingXML,'$."152"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,SingleMP MONEY  '$.SingleMP'
			,Combo2 MONEY  '$.Combo2'
			,Combo35 MONEY  '$.Combo35'
			,Combo6 MONEY  '$.Combo6'
		) cs
	INNER JOIN #TmpProductSettingDetail t 
			ON cs.SportType = t.SportType
			AND cs.BetType = t.BetType
	WHERE t.GroupType = 152

	--PT
	INSERT INTO @PTTbl(SportType,BetType,IsLive,AgentPT,MasterPT,SuperPT,GroupID,Child_DisplayOrder,ProductID,SettingLevel)
	SELECT cs.SportType,cs.BetType,cs.IsLive,cs.AgentPT,cm.MasterPT,cm.SuperPT,t.GroupID,t.Child_DisplayOrder,t.ProductID,t.SettingLevel
	FROM OPENJSON(@SettingXML,'$."153"') WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,IsLive BIT  '$.IsLive'
			,AgentPT SMALLMONEY  '$.AgentPT'
		) cs
	INNER JOIN #TmpProductSettingDetail t 
			ON cs.SportType = t.SportType
			AND cs.BetType = t.BetType
			AND cs.IsLive = t.IsLive
	INNER JOIN CustPTSetting3rd_Member cm
			ON cm.SportType = t.SportType
			AND cm.BetType = t.BetType
			AND cm.IsLive = t.IsLive
	WHERE t.GroupType = 153 AND cm.CustID = @custid

	--WL Limit
	INSERT INTO @WinLossLimitTbl (SportType,BetType ,MaxWinLimit ,MaxLossLimit ,IsAutoReset,SettingLevel,ProductID,GroupID,Child_DisplayOrder)
	SELECT cs.SportType,cs.BetType,cs.MaxWinLimit,NULL,cs.IsAutoReset,t.SettingLevel,t.ProductID,t.GroupID,t.Child_DisplayOrder
	FROM OPENJSON(@SettingXML,'$."161"') WITH (
		 SportType		SMALLINT
		,BetType		SMALLINT
		,MaxWinLimit	MONEY	
		,IsAutoReset	BIT
	) AS cs
		INNER JOIN #TmpProductSettingDetail t 
			ON cs.SportType = t.SportType
			AND cs.BetType = t.BetType
	WHERE t.GroupType = 161
	
	--Stake Level
	INSERT INTO @StakeLevelTbl (SportType,BetType ,StakeLevelList,SettingType,SettingLevel,ProductID,GroupID,Child_DisplayOrder)
	SELECT cs.SportType,cs.BetType ,cs.StakeLevelList,t.SettingType,t.SettingLevel,t.ProductID,t.GroupID,t.Child_DisplayOrder
	FROM OPENJSON(@SettingXML,'$."158"') WITH (
			 SportType		SMALLINT
			,BetType		INT
			,StakeLevelList	VARCHAR(200)	
			) AS cs
		INNER JOIN #TmpProductSettingDetail t 
			ON cs.SportType = t.SportType
			AND cs.BetType = t.BetType
	WHERE t.GroupType = 158

	UPDATE @StakeLevelTbl
	SET StakeLevelList = REPLACE(StakeLevelList, ',', ';')
	
	WHILE 0 = 0
	BEGIN
		UPDATE	ts
		SET	ts.StakeLevelList = REPLACE(ts.StakeLevelList, sl.StakeLevelID, sl.StakeLevelValue)
		FROM		@StakeLevelTbl AS ts
		CROSS APPLY	(	SELECT TOP(1)	CAST(sl.StakeLevelID AS VARCHAR(10)) AS StakeLevelID
									,	CAST(sl.MinLabel AS VARCHAR(20)) + '-' + CAST(sl.MaxLabel AS VARCHAR(20)) AS StakeLevelValue
						FROM		string_split(ts.StakeLevelList, ';') AS ss
						INNER JOIN	GlobCustDB.dbo.StakeLevel AS sl WITH (NOLOCK)
								ON	ss.value = CAST(sl.StakeLevelID AS NVARCHAR(10))
					) sl	

		IF	@@ROWCOUNT = 0
			BREAK;
	END;

	--log all settings
	SELECT @LogSPData = '<Root custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' + 'UplineRoleID="'+ coalesce(cast(@UplineRoleID as VARCHAR(10)),space(1)) + '"  >' 
			+ '<Group ID="1">'--SB
			+ '<Discount GroupType="150">' 
				+ COALESCE(CAST((SELECT SportType,BetType,PlayerDiscount,SuperDiscount,MasterDiscount
						FROM @DiscountTbl
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</Discount>'
			+ '<BetSetting GroupType="151">'
				+ COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet,MaxPerMatch AS MPM,MaxPayoutPerMatch AS MaxPayout
						FROM @BetSetting
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</BetSetting>'
			+ '<ParlayMaxPayout GroupType="152">' 
				+ COALESCE(CAST((SELECT SportType,BetType,SingleMatchParlay AS SingleMP,Combo2,Combo35,ComboOver6 AS Combo6 
						FROM @MaxPayoutTbl
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</ParlayMaxPayout>'	
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT/100 AS AgentPT,MasterPT/100 AS MasterPT,SuperPT/100 AS SuperPT,SettingLevel,ProductID
						FROM @PTTbl
						WHERE GroupID = 1
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '</Group>'	
			+ '<Group ID="2">'--RNG Games
			+ '<BetSetting GroupType="154">'
				+ 	COALESCE(CAST((SELECT SportType,BetType,MinBet,MaxBet, MaxPerMatch AS MPM, MaxPerNumber	
						FROM @BetSetting
						WHERE GroupID = 2
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</BetSetting>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT/100 AS AgentPT,MasterPT/100 AS MasterPT,SuperPT/100 AS SuperPT,SettingLevel,ProductID
						FROM @PTTbl
						WHERE GroupID = 2
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '<WinLimit GroupType="161">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,IsAutoReset,SettingLevel,ProductID
							FROM @WinLossLimitTbl
							WHERE GroupID = 2
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</WinLimit>'		
			+ '</Group>'
			+ '<Group ID="3">'--LCS
			+ '<Discount GroupType="156">' 
				+ COALESCE(CAST((SELECT SportType,BetType,PlayerDiscount,SuperDiscount,MasterDiscount
						FROM @DiscountTbl
						WHERE GroupID = 3
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</Discount>'
			+ '<PT GroupType="153">'
				+ COALESCE(CAST((SELECT SportType,BetType,IsLive,AgentPT/100 AS AgentPT,MasterPT/100 AS MasterPT,SuperPT/100 AS SuperPT,SettingLevel,ProductID
						FROM @PTTbl						
						WHERE GroupID = 3
						ORDER BY Child_DisplayOrder
						FOR XML RAW('R')
						) as VARCHAR(max)), SPACE(1))
			+ '</PT>'
			+ '<WinLimit GroupType="161">'
				+ COALESCE(CAST((SELECT SportType,BetType,MaxWinLimit,IsAutoReset,SettingLevel,ProductID
							FROM @WinLossLimitTbl
							WHERE GroupID = 3
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</WinLimit>'	
			+ '<BetLimit GroupType="158">'
				+ COALESCE(CAST((SELECT SportType,BetType,SettingLevel,ProductID,StakeLevelList
							FROM @StakeLevelTbl
							WHERE GroupID = 3
							ORDER BY Child_DisplayOrder
							FOR XML RAW('R')
							) as VARCHAR(max)),SPACE(1))
			+ '</BetLimit>'
			+ '</Group>'
			+ '</Root>'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 264003,
		@TrackingValue = @LogSPData,
		@duration = @duration 

	DROP TABLE #tempProductOfferStatus
	DROP TABLE #tempSportbettypeSetting
END
GO
