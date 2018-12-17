/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerInsMember_Com]
	@custid INT OUTPUT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@fax NVARCHAR(50),
	@currency INT, 
	@credit MONEY,
	@PTSetting VARCHAR(MAX),
	@BetSetting VARCHAR(MAX),
	@CommSetting VARCHAR(MAX),
	@creator INT,
	@site NVARCHAR(50),	
	@isinternal BIT = 0,
	@SystemID TINYINT=1,	
	@IP VARCHAR(15)='',
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(2000) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Company create Super
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @ErrCode:
			= 0: Create super successfully.
			> 0: Specific Error.
  
		• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME , @endRun DATETIME , @duration INT
	SET @startRun = GETDATE()
	SELECT @ErrCode = 0

	IF EXISTS(SELECT 1 FROM Customer WITH (NOLOCK) WHERE username= @username)
		OR EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE username2 = @username)
		OR EXISTS(SELECT 1 FROM custSub WITH (NOLOCK) WHERE username= @username)
		OR EXISTS(SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username= @username)
		OR EXISTS (SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username2 = @username)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'This username is not available.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						END
		SELECT @ErrCode = 101		
		RETURN
	END

	--EXEC dbo.Acc_CustomerInsMember_Com_CheckParam 

	DECLARE @autosuspend BIT, @autosuspend2 BIT
	SELECT @autosuspend = 0, @autosuspend2 = 0

	--Insert general info
	EXEC dbo.Acc_CustomerInsUserInfo 
		@custid = @custid OUTPUT,
		@firstname = @firstname,
		@lastname = @lastname,
		@creator = @creator,
		@username = @username,
		@userpwd = @userpwd,
		@pwdexpiry = NULL,
		@currency = @currency,
		@site = @site,
		@srecommend = 0,
		@mrecommend = 0,
		@recommend = 0,
		@roleid = 4,
		@phone = @phone,
		@mobilephone = @mobilephone,
		@email = '',
		@fax = @fax,
		@address = '',
		@city = '',
		@state = '',
		@country = '',
		@postal = '',
		@TransferOption = NULL,
		@suspended = 0,
		@SystemID = @SystemID,
		@autosuspend = @autosuspend,
		@autosuspend2 = @autosuspend2,		
		@matchlimit = 1,
		--@Johnson: Disable virtual rate status as default
		@virtualmultiplier = 0,	
	
		@DisableCasino = 1,
		@DisableNumber = 1,
		@DoubleCommLosing = 1,		
		@DisableCasinoBonus = 1,		
		@DisableGoldDeluxe = 1,
		@HideGoldDeluxe = 1,
		@DisableColossusBet = 1,
		@HideColossusBet = 1,
		@DisableSuperLive = 1,
		@HideKeno = 1,

		@credit = @credit,
		@maxcredit = NULL,
		@IP = @IP,
		@isinternal = @isinternal,
		@TransferOption_dec = NULL,
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	--Error occurs
	IF @ErrCode <> 0
		RETURN

	DECLARE @IsMyanmarOdds BIT = 0

	IF @Site = '766666'
		SET @IsMyanmarOdds = 1
			
	EXEC dbo.Acc_CustomerInfo_Execrep_00
		@custid = @custid,
		@roleid = 4,							
		@ErrCode = @ErrCode OUTPUT

	IF @ErrCode > 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							when 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
			EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END	

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	DECLARE @MaxMemberLog VARCHAR(50)
	SELECT @MaxMemberLog = CASE WHEN @Site = '789y' THEN '20000' ELSE 'Unlimited' END

	DECLARE @LogSPData VARCHAR(MAX)
	--Write general info
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +

	'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
	'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
	'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address AS VARCHAR(160)),SPACE(1))) + '" ' +
	'postal="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal AS VARCHAR(100)),SPACE(1))) + '" ' +
	'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city AS VARCHAR(100)),SPACE(1))) + '" ' +
	'state="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state AS VARCHAR(100)),SPACE(1))) + '" ' +
	'country="'+ COALESCE(CAST(@country AS VARCHAR(100)),SPACE(1)) + '" ' +
	'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
	'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
	'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email AS VARCHAR(100)),SPACE(1))) + '" ' +
	'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
	'refcode1="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@refcode1 AS VARCHAR(100)),SPACE(1))) + '" ' +
	'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)),SPACE(1)) + '" ' +
	'username="'+ COALESCE(CAST(@username AS VARCHAR(20)),SPACE(1)) + '" ' +
	'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +
	'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
	'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)),SPACE(1)) + '" />'

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 600,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +

		'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
		'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
		'address="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@address AS VARCHAR(160)),SPACE(1))) + '" ' +
		'postal="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@postal AS VARCHAR(100)),SPACE(1))) + '" ' +
		'city="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@city AS VARCHAR(100)),SPACE(1))) + '" ' +
		'state="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@state AS VARCHAR(100)),SPACE(1))) + '" ' +
		'country="'+ COALESCE(CAST(@country AS VARCHAR(100)),SPACE(1)) + '" ' +
		'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
		'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
		'email="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@email AS VARCHAR(100)),SPACE(1))) + '" ' +
		'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
		'refcode1="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@refcode1 AS VARCHAR(100)),SPACE(1))) + '" ' +
		'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)),SPACE(1)) + '" ' +
		'username="'+ COALESCE(CAST(@username AS VARCHAR(20)),SPACE(1)) + '" ' +
		'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +
		'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
		'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 600,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH	

	--Write commission log
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" '  +
	'groupa="'+ COALESCE(CAST(@groupa AS VARCHAR(50)),SPACE(1)) + '" ' 

	IF @IsMyanmarOdds = 0
		SET @LogSPData = @LogSPData + 
			'groupb="' + COALESCE(CAST(@groupb AS VARCHAR(50)),SPACE(1)) + '" ' +
			'groupc="' + COALESCE(CAST(@groupc AS VARCHAR(50)),SPACE(1)) + '" ' +
			'groupd="' + COALESCE(CAST(@groupd AS VARCHAR(50)),SPACE(1)) + '" ' 

	SET @LogSPData = @LogSPData + 
	'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)),SPACE(1)) + '" ' +
	'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'discountnumber="'+ COALESCE(CAST(@discountnumber AS VARCHAR(50)),SPACE(1)) + '" ' 

	IF @IsMyanmarOdds = 1
		SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ COALESCE(CAST(@discountMyanmarOdds AS VARCHAR(50)),SPACE(1)) + '" ' 

	SET @LogSPData = @LogSPData + ' />'


	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 200,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupa="'+ COALESCE(CAST(@groupa AS VARCHAR(50)),SPACE(1)) + '" ' 
		
		IF @IsMyanmarOdds = 0
			SET @LogSPData = @LogSPData +
		'groupb="'+ COALESCE(CAST(@groupb AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupc="'+ COALESCE(CAST(@groupc AS VARCHAR(50)),SPACE(1)) + '" ' +
		'groupd="'+ COALESCE(CAST(@groupd AS VARCHAR(50)),SPACE(1)) + '" ' 
		SET @LogSPData = @LogSPData +
		'discountcs="'+ COALESCE(CAST(@discountcs AS VARCHAR(50)),SPACE(1)) + '" ' +
		'discount1x2="'+ COALESCE(CAST(@discount1x2 AS VARCHAR(50)),SPACE(1)) + '" ' +	
		'discountnumber="'+ COALESCE(CAST(@discountnumber AS VARCHAR(50)),SPACE(1)) + '" ' 
		IF @IsMyanmarOdds = 1
			SET @LogSPData = @LogSPData + 'discountMyanmarOdds="'+ COALESCE(CAST(@discountMyanmarOdds AS VARCHAR(50)),SPACE(1)) + '" ' 

		SET @LogSPData = @LogSPData + 'ErrMsg="'+ ERROR_MESSAGE() +	'" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 200,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH

	--Write status log
	--Get data prepare write log for Keno
	DECLARE @LogDataKeno NVARCHAR(4000) = ''
	SELECT @LogDataKeno = COALESCE(@LogDataKeno + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
		+ '=' + '"' + CAST(1 AS VARCHAR(1)) + '"' + SPACE(1), + 'Disable202_' + CAST(IBCBetTypeID AS VARCHAR(10)) 
		+ '=' + '"' + CAST(1 AS VARCHAR(1)) + '"' + SPACE(1))
	FROM @tmp_GameType gt
	WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0

	SET @LogDataKeno = 'HideKeno="'+ COALESCE(CAST(@HideKeno AS VARCHAR(1)), SPACE(1)) + '" ' + @LogDataKeno

	DECLARE @LogDataSP2 VARCHAR(4000)
	
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	INTO #temSportbettypeSetting
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11)
	
	INSERT INTO #temSportbettypeSetting(ProductID,SportType,Bettype,SettingType)
	SELECT DISTINCT ProductID,SportType,Bettype,SettingType
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13)
	
	DECLARE @_Site VARCHAR(10)
	SELECT @_Site = site
	FROM dbo.customer WITH(NOLOCK)
	WHERE CustID = @CustID

	SET @LogDataSP2 = ''

	SELECT @LogDataSP2 = @LogDataSP2 +  'Hide' +  REPLACE(REPLACE(p.ProductName, ' ', ''),'*','') + '="' + COALESCE(CAST(iq.custIsHidden AS VARCHAR(1)), SPACE(1)) + '" '
	FROM DBPRO.bodb02.dbo.Products p WITH (NOLOCK)
		INNER JOIN (SELECT psd.ProductID, MIN(CAST(dbo.f_GetProductStatus(cps.bitmapIsHidden, psp.bitmapOrder) AS INT)) AS custIsHidden
					FROM ProductSettingDetail psd WITH(NOLOCK)
						INNER JOIN	ProductStatusProfile psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype
																			AND	psd.BetType = psp.Bettype
																			AND psd.SettingType IN (4,11,13)		-- Product Status
						INNER JOIN #temSportbettypeSetting t WITH(NOLOCK) ON  psp.SportType = t.SportType	AND psp.BetType = t.BetType AND psd.SettingType = t.SettingType
						INNER JOIN CustProductStatus cps WITH(NOLOCK) ON cps.CustID = @CustID
					WHERE @_Site = 'IMBC' OR psd.ProductID <> 20 --iCricket
					GROUP BY psd.ProductID	
					) iq ON iq.ProductID = p.ProductID

	SELECT @LogDataSP2	= @LogDataSP2 
						+ 'Disable' + CAST(Sporttype AS VARCHAR) + '_' + CAST(Bettype AS VARCHAR)
						+ '="' + COALESCE(CAST(custIsDisable AS VARCHAR(1)), SPACE(1)) + '" '
	FROM (
		SELECT	psp.Sporttype,
				psp.Bettype,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapIsDisabled, psp.bitmapOrder)) AS custIsDisable
		FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	ProductStatusProfile AS psp WITH(NOLOCK) ON	psd.SportType = psp.Sporttype AND psd.BetType = psp.Bettype 
			INNER JOIN #temSportbettypeSetting t WITH(NOLOCK) ON  psp.SportType = t.SportType	AND psp.BetType = t.BetType AND psd.SettingType = t.SettingType
			CROSS APPLY CustProductStatus WITH(NOLOCK)
		WHERE CustID = @custid AND (@_Site = 'IMBC' OR psd.ProductID <> 20)--iCricket
			AND psd.SettingType IN (4,11,13)-- Product Status, Game Status
	)iq

	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	--20171205@Johnson: add more log for status
	'Special=" " ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
	'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'virtualmultiplier="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +	
	--'disableVirtualSports="'+ COALESCE(CAST(@Disable180_1201 AS VARCHAR(1)),SPACE(1)) + '" ' +
	'disableCasino="'+ COALESCE(CAST(@disableCasino AS VARCHAR(1)),SPACE(1)) + '" ' +
	'disablenumber="'+ COALESCE(CAST(@disablenumber AS VARCHAR(1)),SPACE(1)) + '" ' +

	
	'HideGoldDeluxe="'+ COALESCE(CAST(@HideGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DisableGoldDeluxe="'+ COALESCE(CAST(@DisableGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +

	'HideColossusBet="'+ COALESCE(CAST(@HideColossusBet AS VARCHAR(1)),SPACE(1)) + '" ' +
	'DisableColossusBet="'+ COALESCE(CAST(@DisableColossusBet AS VARCHAR(1)),SPACE(1)) + '" ' +

	'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)),SPACE(1)) + '" ' +
	 @LogDataKeno + @LogDataSP2 +
	'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" />'

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 1100,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		--20171205@Johnson: add more log for status
		'Special=" " ' +
		'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
		'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'virtualmultiplier="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'SelectedBetting="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
	
		--'disableVirtualSports="'+ COALESCE(CAST(@Disable180_1201 AS VARCHAR(1)),SPACE(1)) + '" ' +
		'disableCasino="'+ COALESCE(CAST(@disableCasino AS VARCHAR(1)),SPACE(1)) + '" ' +
		'disablenumber="'+ COALESCE(CAST(@disablenumber AS VARCHAR(1)),SPACE(1)) + '" ' +
		
		'HideGoldDeluxe="'+ COALESCE(CAST(@HideGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DisableGoldDeluxe="'+ COALESCE(CAST(@DisableGoldDeluxe AS VARCHAR(1)),SPACE(1)) + '" ' +
		
		'HideColossusBet="'+ COALESCE(CAST(@HideColossusBet AS VARCHAR(1)),SPACE(1)) + '" ' +
		'DisableColossusBet="'+ COALESCE(CAST(@DisableColossusBet AS VARCHAR(1)),SPACE(1)) + '" ' +
		
		'DisableSuperLive="'+ COALESCE(CAST(@DisableSuperLive AS VARCHAR(1)),SPACE(1)) + '" ' +		
		'isinternal="'+ COALESCE(CAST(@isinternal AS VARCHAR(1)),SPACE(1)) + '" ' + @LogDataKeno + @LogDataSP2 +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 1100,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH	

	--Write Bet setting log
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv2="'+ COALESCE(CAST(@MinBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv2="'+ COALESCE(CAST(@MaxBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv2="'+ COALESCE(CAST(@MaxPerMatchv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv3="'+ COALESCE(CAST(@MinBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv3="'+ COALESCE(CAST(@MaxBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv3="'+ COALESCE(CAST(@MaxPerMatchv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv5="'+ COALESCE(CAST(@MinBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv5="'+ COALESCE(CAST(@MaxBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv5="'+ COALESCE(CAST(@MaxPerMatchv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv8="'+ COALESCE(CAST(@MinBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv8="'+ COALESCE(CAST(@MaxBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv8="'+ COALESCE(CAST(@MaxPerMatchv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv10="'+ COALESCE(CAST(@MinBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv10="'+ COALESCE(CAST(@MaxBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv10="'+ COALESCE(CAST(@MaxPerMatchv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv11="'+ COALESCE(CAST(@MinBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv11="'+ COALESCE(CAST(@MaxBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv11="'+ COALESCE(CAST(@MaxPerMatchv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinBv99="'+ COALESCE(CAST(@MinBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv99="'+ COALESCE(CAST(@MaxBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv99="'+ COALESCE(CAST(@MaxPerMatchv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'MinBv99MP="'+ COALESCE(CAST(@MinBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv99MP="'+ COALESCE(CAST(@MaxBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv99MP="'+ COALESCE(CAST(@MaxPerMatchv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'MinBv1MP="'+ COALESCE(CAST(@MinBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv1MP="'+ COALESCE(CAST(@MaxBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv1MP="'+ COALESCE(CAST(@MaxPerMatchv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +

	'MinBv161="'+ COALESCE(CAST(@MinBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxBv161="'+ COALESCE(CAST(@MaxBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPMv161="'+ COALESCE(CAST(@MaxPerMatchv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPBv161="' + COALESCE(CAST(@MaxPerBallv161 AS VARCHAR(50)),SPACE(1)) + '" />' 

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 300,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv2="'+ COALESCE(CAST(@MinBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv2="'+ COALESCE(CAST(@MaxBetv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv2="'+ COALESCE(CAST(@MaxPerMatchv2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv3="'+ COALESCE(CAST(@MinBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv3="'+ COALESCE(CAST(@MaxBetv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv3="'+ COALESCE(CAST(@MaxPerMatchv3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv5="'+ COALESCE(CAST(@MinBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv5="'+ COALESCE(CAST(@MaxBetv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv5="'+ COALESCE(CAST(@MaxPerMatchv5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv8="'+ COALESCE(CAST(@MinBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv8="'+ COALESCE(CAST(@MaxBetv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv8="'+ COALESCE(CAST(@MaxPerMatchv8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv10="'+ COALESCE(CAST(@MinBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv10="'+ COALESCE(CAST(@MaxBetv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv10="'+ COALESCE(CAST(@MaxPerMatchv10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv11="'+ COALESCE(CAST(@MinBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv11="'+ COALESCE(CAST(@MaxBetv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv11="'+ COALESCE(CAST(@MaxPerMatchv11 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv99="'+ COALESCE(CAST(@MinBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv99="'+ COALESCE(CAST(@MaxBetv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv99="'+ COALESCE(CAST(@MaxPerMatchv99 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinBv99MP="'+ COALESCE(CAST(@MinBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv99MP="'+ COALESCE(CAST(@MaxBetv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv99MP="'+ COALESCE(CAST(@MaxPerMatchv99MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'MinBv1MP="'+ COALESCE(CAST(@MinBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv1MP="'+ COALESCE(CAST(@MaxBetv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv1MP="'+ COALESCE(CAST(@MaxPerMatchv1MP AS VARCHAR(50)),SPACE(1)) + '" ' +

		'MinBv161="'+ COALESCE(CAST(@MinBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxBv161="'+ COALESCE(CAST(@MaxBetv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPMv161="'+ COALESCE(CAST(@MaxPerMatchv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPBv161="' + COALESCE(CAST(@MaxPerBallv161 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="' + ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 300,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH	

	-- Write Log Credit	
	DECLARE @LogSPCredit VARCHAR(MAX)
	SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1))

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
			@UserID = @Creator,
			@CustID = @CustID,
			@Doing = @LogSPCredit,
			@NewValue = @credit,
			@IP = @IP,
			@ActionID = 1208
	END TRY
	BEGIN CATCH
		SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1)) 
							+  ', ErrMsg=' + ERROR_MESSAGE() 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
			@UserID = @Creator,
			@CustID = @CustID,
			@Doing = @LogSPCredit,
			@NewValue = @credit,
			@IP = @IP,
			@ActionID = 1208					
	END CATCH

	--Write PT log
	SELECT @LogSPData = '<Acc_CustomerInsMember_Com><s spt_1="'+ COALESCE(CAST(@spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_2="'+ COALESCE(CAST(@spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_3="'+ COALESCE(CAST(@spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_4="'+ COALESCE(CAST(@spositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_5="'+ COALESCE(CAST(@spositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_6="'+ COALESCE(CAST(@spositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_7="'+ COALESCE(CAST(@spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_8="'+ COALESCE(CAST(@spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_9="'+ COALESCE(CAST(@spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_10="'+ COALESCE(CAST(@spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_10="'+ COALESCE(CAST(@v2spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_10="'+ COALESCE(CAST(@v3spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_10="'+ COALESCE(CAST(@v5spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8spt_10="'+ COALESCE(CAST(@v8spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_10="'+ COALESCE(CAST(@v10spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11spt_10="'+ COALESCE(CAST(@v11spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_10="'+ COALESCE(CAST(@v99spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'spt_9999="'+ COALESCE(CAST(@spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_1="'+ COALESCE(CAST(@slivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_3="'+ COALESCE(CAST(@slivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_7="'+ COALESCE(CAST(@slivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'slivept_8="'+ COALESCE(CAST(@slivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v2spt_1="'+ COALESCE(CAST(@v2spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_2="'+ COALESCE(CAST(@v2spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_3="'+ COALESCE(CAST(@v2spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_7="'+ COALESCE(CAST(@v2spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2spt_8="'+ COALESCE(CAST(@v2spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2spt_20="'+ COALESCE(CAST(@v2spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--BAIO
	'v2spt_9999="'+ COALESCE(CAST(@v2spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v3spt_1="'+ COALESCE(CAST(@v3spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_2="'+ COALESCE(CAST(@v3spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_3="'+ COALESCE(CAST(@v3spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3spt_20="'+ COALESCE(CAST(@v3spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v5spt_1="'+ COALESCE(CAST(@v5spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_2="'+ COALESCE(CAST(@v5spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_3="'+ COALESCE(CAST(@v5spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_20="'+ COALESCE(CAST(@v5spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5spt_9999="'+ COALESCE(CAST(@v5spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v8spt_1="'+ COALESCE(CAST(@v8spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8spt_3="'+ COALESCE(CAST(@v8spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8spt_20="'+ COALESCE(CAST(@v8spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v10spt_1="'+ COALESCE(CAST(@v10spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_2="'+ COALESCE(CAST(@v10spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_3="'+ COALESCE(CAST(@v10spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10spt_20="'+ COALESCE(CAST(@v10spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v11spt_1="'+ COALESCE(CAST(@v11spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11spt_20="'+ COALESCE(CAST(@v11spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v99spt_1="'+ COALESCE(CAST(@v99spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_2="'+ COALESCE(CAST(@v99spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_3="'+ COALESCE(CAST(@v99spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_9="'+ COALESCE(CAST(@v99spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99spt_20="'+ COALESCE(CAST(@v99spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v161spt_81="'+ COALESCE(CAST(@v161spositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161spt_83="'+ COALESCE(CAST(@v161spositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--'v161spt_85="'+ coalesce(cast(@v161spositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161spt_86="'+ COALESCE(CAST(@v161spositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161spt_88="'+ COALESCE(CAST(@v161spositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_85="'+ COALESCE(CAST(@v161slivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_86="'+ COALESCE(CAST(@v161slivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_87="'+ COALESCE(CAST(@v161slivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_89="'+ COALESCE(CAST(@v161slivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161slivept_90="'+ COALESCE(CAST(@v161slivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


	'<m mpt_1="'+ COALESCE(CAST(@mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_2="'+ COALESCE(CAST(@mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_3="'+ COALESCE(CAST(@mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_4="'+ COALESCE(CAST(@mpositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_5="'+ COALESCE(CAST(@mpositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_6="'+ COALESCE(CAST(@mpositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_7="'+ COALESCE(CAST(@mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_8="'+ COALESCE(CAST(@mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_9="'+ COALESCE(CAST(@mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_10="'+ COALESCE(CAST(@mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_10="'+ COALESCE(CAST(@v2mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_10="'+ COALESCE(CAST(@v3mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_10="'+ COALESCE(CAST(@v5mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8mpt_10="'+ COALESCE(CAST(@v8mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_10="'+ COALESCE(CAST(@v10mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11mpt_10="'+ COALESCE(CAST(@v11mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_10="'+ COALESCE(CAST(@v99mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mpt_9999="'+ COALESCE(CAST(@mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_1="'+ COALESCE(CAST(@mlivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_3="'+ COALESCE(CAST(@mlivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_7="'+ COALESCE(CAST(@mlivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'mlivept_8="'+ COALESCE(CAST(@mlivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v2mpt_1="'+ COALESCE(CAST(@v2mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_2="'+ COALESCE(CAST(@v2mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_3="'+ COALESCE(CAST(@v2mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_7="'+ COALESCE(CAST(@v2mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2mpt_8="'+ COALESCE(CAST(@v2mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2mpt_20="'+ COALESCE(CAST(@v2mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--BAIO 
	'v2mpt_9999="'+ COALESCE(CAST(@v2mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v3mpt_1="'+ COALESCE(CAST(@v3mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_2="'+ COALESCE(CAST(@v3mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_3="'+ COALESCE(CAST(@v3mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3mpt_20="'+ COALESCE(CAST(@v3mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v5mpt_1="'+ COALESCE(CAST(@v5mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_2="'+ COALESCE(CAST(@v5mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_3="'+ COALESCE(CAST(@v5mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_20="'+ COALESCE(CAST(@v5mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5mpt_9999="'+ COALESCE(CAST(@v5mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v8mpt_1="'+ COALESCE(CAST(@v8mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8mpt_3="'+ COALESCE(CAST(@v8mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8mpt_20="'+ COALESCE(CAST(@v8mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v10mpt_1="'+ COALESCE(CAST(@v10mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_2="'+ COALESCE(CAST(@v10mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_3="'+ COALESCE(CAST(@v10mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10mpt_20="'+ COALESCE(CAST(@v10mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v11mpt_1="'+ COALESCE(CAST(@v11mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11mpt_20="'+ COALESCE(CAST(@v11mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v99mpt_1="'+ COALESCE(CAST(@v99mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_2="'+ COALESCE(CAST(@v99mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_3="'+ COALESCE(CAST(@v99mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_9="'+ COALESCE(CAST(@v99mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99mpt_20="'+ COALESCE(CAST(@v99mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v161mpt_81="'+ COALESCE(CAST(@v161mpositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mpt_83="'+ COALESCE(CAST(@v161mpositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mpt_86="'+ COALESCE(CAST(@v161mpositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mpt_88="'+ COALESCE(CAST(@v161mpositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_85="'+ COALESCE(CAST(@v161mlivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_86="'+ COALESCE(CAST(@v161mlivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_87="'+ COALESCE(CAST(@v161mlivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_89="'+ COALESCE(CAST(@v161mlivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161mlivept_90="'+ COALESCE(CAST(@v161mlivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


	'<ag apt_1="'+ COALESCE(CAST(@apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_2="'+ COALESCE(CAST(@apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_3="'+ COALESCE(CAST(@apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_4="'+ COALESCE(CAST(@apositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_5="'+ COALESCE(CAST(@apositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_6="'+ COALESCE(CAST(@apositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_7="'+ COALESCE(CAST(@apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_8="'+ COALESCE(CAST(@apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_9="'+ COALESCE(CAST(@apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'apt_10="'+ COALESCE(CAST(@apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v2apt_10="'+ COALESCE(CAST(@v2apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v3apt_10="'+ COALESCE(CAST(@v3apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v5apt_10="'+ COALESCE(CAST(@v5apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v8apt_10="'+ COALESCE(CAST(@v8apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v10apt_10="'+ COALESCE(CAST(@v10apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v11apt_10="'+ COALESCE(CAST(@v11apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'v99apt_10="'+ COALESCE(CAST(@v99apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
	'apt_9999="'+ COALESCE(CAST(@apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_1="'+ COALESCE(CAST(@alivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_3="'+ COALESCE(CAST(@alivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_7="'+ COALESCE(CAST(@alivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'alivept_8="'+ COALESCE(CAST(@alivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v2apt_1="'+ COALESCE(CAST(@v2apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_2="'+ COALESCE(CAST(@v2apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_3="'+ COALESCE(CAST(@v2apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_7="'+ COALESCE(CAST(@v2apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v2apt_8="'+ COALESCE(CAST(@v2apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2apt_20="'+ COALESCE(CAST(@v2apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	-- BAIO
	'v2apt_9999="'+ COALESCE(CAST(@v2apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v3apt_1="'+ COALESCE(CAST(@v3apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3apt_2="'+ COALESCE(CAST(@v3apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3apt_3="'+ COALESCE(CAST(@v3apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v3apt_20="'+ COALESCE(CAST(@v3apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v5apt_1="'+ COALESCE(CAST(@v5apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_2="'+ COALESCE(CAST(@v5apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_3="'+ COALESCE(CAST(@v5apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_20="'+ COALESCE(CAST(@v5apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v5apt_9999="'+ COALESCE(CAST(@v5apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v8apt_1="'+ COALESCE(CAST(@v8apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8apt_3="'+ COALESCE(CAST(@v8apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v8apt_20="'+ COALESCE(CAST(@v8apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v10apt_1="'+ COALESCE(CAST(@v10apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10apt_2="'+ COALESCE(CAST(@v10apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10apt_3="'+ COALESCE(CAST(@v10apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v10apt_20="'+ COALESCE(CAST(@v10apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v11apt_1="'+ COALESCE(CAST(@v11apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v11apt_20="'+ COALESCE(CAST(@v11apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v99apt_1="'+ COALESCE(CAST(@v99apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_2="'+ COALESCE(CAST(@v99apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_3="'+ COALESCE(CAST(@v99apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_9="'+ COALESCE(CAST(@v99apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v99apt_20="'+ COALESCE(CAST(@v99apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

	'v161apt_81="'+ COALESCE(CAST(@v161apositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161apt_83="'+ COALESCE(CAST(@v161apositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
	--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161apt_86="'+ COALESCE(CAST(@v161apositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161apt_88="'+ COALESCE(CAST(@v161apositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_85="'+ COALESCE(CAST(@v161alivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_86="'+ COALESCE(CAST(@v161alivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_87="'+ COALESCE(CAST(@v161alivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_89="'+ COALESCE(CAST(@v161alivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'v161alivept_90="'+ COALESCE(CAST(@v161alivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" /></Acc_CustomerInsMember_Com>' 

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 400,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH

		SELECT @LogSPData = '<Acc_CustomerInsMember_Com><s spt_1="'+ COALESCE(CAST(@spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_2="'+ COALESCE(CAST(@spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_3="'+ COALESCE(CAST(@spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_4="'+ COALESCE(CAST(@spositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_5="'+ COALESCE(CAST(@spositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_6="'+ COALESCE(CAST(@spositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_7="'+ COALESCE(CAST(@spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_8="'+ COALESCE(CAST(@spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_9="'+ COALESCE(CAST(@spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_10="'+ COALESCE(CAST(@spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_10="'+ COALESCE(CAST(@v2spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_10="'+ COALESCE(CAST(@v3spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_10="'+ COALESCE(CAST(@v5spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8spt_10="'+ COALESCE(CAST(@v8spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_10="'+ COALESCE(CAST(@v10spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11spt_10="'+ COALESCE(CAST(@v11spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_10="'+ COALESCE(CAST(@v99spositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'spt_9999="'+ COALESCE(CAST(@spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_1="'+ COALESCE(CAST(@slivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_3="'+ COALESCE(CAST(@slivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_7="'+ COALESCE(CAST(@slivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'slivept_8="'+ COALESCE(CAST(@slivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v2spt_1="'+ COALESCE(CAST(@v2spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_2="'+ COALESCE(CAST(@v2spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_3="'+ COALESCE(CAST(@v2spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_7="'+ COALESCE(CAST(@v2spositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2spt_8="'+ COALESCE(CAST(@v2spositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
		'v2spt_20="'+ COALESCE(CAST(@v2spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		-- BAIO
		'v2spt_9999="'+ COALESCE(CAST(@v2spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v3spt_1="'+ COALESCE(CAST(@v3spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_2="'+ COALESCE(CAST(@v3spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_3="'+ COALESCE(CAST(@v3spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3spt_20="'+ COALESCE(CAST(@v3spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v5spt_1="'+ COALESCE(CAST(@v5spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_2="'+ COALESCE(CAST(@v5spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_3="'+ COALESCE(CAST(@v5spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_20="'+ COALESCE(CAST(@v5spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5spt_9999="'+ COALESCE(CAST(@v5spositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v8spt_1="'+ COALESCE(CAST(@v8spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8spt_3="'+ COALESCE(CAST(@v8spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8spt_20="'+ COALESCE(CAST(@v8spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v10spt_1="'+ COALESCE(CAST(@v10spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_2="'+ COALESCE(CAST(@v10spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_3="'+ COALESCE(CAST(@v10spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10spt_20="'+ COALESCE(CAST(@v10spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v11spt_1="'+ COALESCE(CAST(@v11spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11spt_20="'+ COALESCE(CAST(@v11spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v99spt_1="'+ COALESCE(CAST(@v99spositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_2="'+ COALESCE(CAST(@v99spositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_3="'+ COALESCE(CAST(@v99spositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_9="'+ COALESCE(CAST(@v99spositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99spt_20="'+ COALESCE(CAST(@v99spositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v161spt_81="'+ COALESCE(CAST(@v161spositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161spt_83="'+ COALESCE(CAST(@v161spositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--'v161spt_85="'+ coalesce(cast(@v161spositiontaking_85 as varchar(50)),space(1)) + '" ' +
		'v161spt_86="'+ COALESCE(CAST(@v161spositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161spt_88="'+ COALESCE(CAST(@v161spositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_85="'+ COALESCE(CAST(@v161slivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_86="'+ COALESCE(CAST(@v161slivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_87="'+ COALESCE(CAST(@v161slivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_89="'+ COALESCE(CAST(@v161slivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161slivept_90="'+ COALESCE(CAST(@v161slivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


		'<m mpt_1="'+ COALESCE(CAST(@mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_2="'+ COALESCE(CAST(@mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_3="'+ COALESCE(CAST(@mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_4="'+ COALESCE(CAST(@mpositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_5="'+ COALESCE(CAST(@mpositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_6="'+ COALESCE(CAST(@mpositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_7="'+ COALESCE(CAST(@mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_8="'+ COALESCE(CAST(@mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_9="'+ COALESCE(CAST(@mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_10="'+ COALESCE(CAST(@mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_10="'+ COALESCE(CAST(@v2mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_10="'+ COALESCE(CAST(@v3mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_10="'+ COALESCE(CAST(@v5mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8mpt_10="'+ COALESCE(CAST(@v8mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_10="'+ COALESCE(CAST(@v10mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11mpt_10="'+ COALESCE(CAST(@v11mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_10="'+ COALESCE(CAST(@v99mpositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mpt_9999="'+ COALESCE(CAST(@mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_1="'+ COALESCE(CAST(@mlivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_3="'+ COALESCE(CAST(@mlivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_7="'+ COALESCE(CAST(@mlivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'mlivept_8="'+ COALESCE(CAST(@mlivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v2mpt_1="'+ COALESCE(CAST(@v2mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_2="'+ COALESCE(CAST(@v2mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_3="'+ COALESCE(CAST(@v2mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_7="'+ COALESCE(CAST(@v2mpositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2mpt_8="'+ COALESCE(CAST(@v2mpositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
		'v2mpt_20="'+ COALESCE(CAST(@v2mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--BAIO
		'v2mpt_9999="'+ COALESCE(CAST(@v2mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v3mpt_1="'+ COALESCE(CAST(@v3mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_2="'+ COALESCE(CAST(@v3mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_3="'+ COALESCE(CAST(@v3mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3mpt_20="'+ COALESCE(CAST(@v3mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v5mpt_1="'+ COALESCE(CAST(@v5mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_2="'+ COALESCE(CAST(@v5mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_3="'+ COALESCE(CAST(@v5mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_20="'+ COALESCE(CAST(@v5mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5mpt_9999="'+ COALESCE(CAST(@v5mpositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v8mpt_1="'+ COALESCE(CAST(@v8mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8mpt_3="'+ COALESCE(CAST(@v8mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8mpt_20="'+ COALESCE(CAST(@v8mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v10mpt_1="'+ COALESCE(CAST(@v10mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_2="'+ COALESCE(CAST(@v10mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_3="'+ COALESCE(CAST(@v10mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10mpt_20="'+ COALESCE(CAST(@v10mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v11mpt_1="'+ COALESCE(CAST(@v11mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11mpt_20="'+ COALESCE(CAST(@v11mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v99mpt_1="'+ COALESCE(CAST(@v99mpositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_2="'+ COALESCE(CAST(@v99mpositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_3="'+ COALESCE(CAST(@v99mpositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_9="'+ COALESCE(CAST(@v99mpositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99mpt_20="'+ COALESCE(CAST(@v99mpositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v161mpt_81="'+ COALESCE(CAST(@v161mpositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mpt_83="'+ COALESCE(CAST(@v161mpositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
		'v161mpt_86="'+ COALESCE(CAST(@v161mpositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mpt_88="'+ COALESCE(CAST(@v161mpositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_85="'+ COALESCE(CAST(@v161mlivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_86="'+ COALESCE(CAST(@v161mlivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_87="'+ COALESCE(CAST(@v161mlivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_89="'+ COALESCE(CAST(@v161mlivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161mlivept_90="'+ COALESCE(CAST(@v161mlivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" />' +


		'<ag apt_1="'+ COALESCE(CAST(@apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_2="'+ COALESCE(CAST(@apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_3="'+ COALESCE(CAST(@apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_4="'+ COALESCE(CAST(@apositiontaking_4 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_5="'+ COALESCE(CAST(@apositiontaking_5 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_6="'+ COALESCE(CAST(@apositiontaking_6 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_7="'+ COALESCE(CAST(@apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_8="'+ COALESCE(CAST(@apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_9="'+ COALESCE(CAST(@apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'apt_10="'+ COALESCE(CAST(@apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v2apt_10="'+ COALESCE(CAST(@v2apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v3apt_10="'+ COALESCE(CAST(@v3apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v5apt_10="'+ COALESCE(CAST(@v5apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v8apt_10="'+ COALESCE(CAST(@v8apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v10apt_10="'+ COALESCE(CAST(@v10apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v11apt_10="'+ COALESCE(CAST(@v11apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v99apt_10="'+ COALESCE(CAST(@v99apositiontaking_10 AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'apt_9999="'+ COALESCE(CAST(@apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_1="'+ COALESCE(CAST(@alivepositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_3="'+ COALESCE(CAST(@alivepositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_7="'+ COALESCE(CAST(@alivepositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'alivept_8="'+ COALESCE(CAST(@alivepositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v2apt_1="'+ COALESCE(CAST(@v2apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_2="'+ COALESCE(CAST(@v2apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_3="'+ COALESCE(CAST(@v2apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_7="'+ COALESCE(CAST(@v2apositiontaking_7 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v2apt_8="'+ COALESCE(CAST(@v2apositiontaking_8 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
		'v2apt_20="'+ COALESCE(CAST(@v2apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--BAIO
		'v2apt_9999="'+ COALESCE(CAST(@v2apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +
		
		'v3apt_1="'+ COALESCE(CAST(@v3apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3apt_2="'+ COALESCE(CAST(@v3apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3apt_3="'+ COALESCE(CAST(@v3apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v3apt_20="'+ COALESCE(CAST(@v3apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v5apt_1="'+ COALESCE(CAST(@v5apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_2="'+ COALESCE(CAST(@v5apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_3="'+ COALESCE(CAST(@v5apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_20="'+ COALESCE(CAST(@v5apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v5apt_9999="'+ COALESCE(CAST(@v5apositiontaking_9999 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v8apt_1="'+ COALESCE(CAST(@v8apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8apt_3="'+ COALESCE(CAST(@v8apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v8apt_20="'+ COALESCE(CAST(@v8apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v10apt_1="'+ COALESCE(CAST(@v10apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10apt_2="'+ COALESCE(CAST(@v10apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10apt_3="'+ COALESCE(CAST(@v10apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v10apt_20="'+ COALESCE(CAST(@v10apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v11apt_1="'+ COALESCE(CAST(@v11apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v11apt_20="'+ COALESCE(CAST(@v11apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v99apt_1="'+ COALESCE(CAST(@v99apositiontaking_1 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_2="'+ COALESCE(CAST(@v99apositiontaking_2 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_3="'+ COALESCE(CAST(@v99apositiontaking_3 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_9="'+ COALESCE(CAST(@v99apositiontaking_9 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v99apt_20="'+ COALESCE(CAST(@v99apositiontaking_20 AS VARCHAR(50)),SPACE(1)) + '" ' +

		'v161apt_81="'+ COALESCE(CAST(@v161apositiontaking_81 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161apt_83="'+ COALESCE(CAST(@v161apositiontaking_83 AS VARCHAR(50)),SPACE(1)) + '" ' +
		--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
		'v161apt_86="'+ COALESCE(CAST(@v161apositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161apt_88="'+ COALESCE(CAST(@v161apositiontaking_88 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_85="'+ COALESCE(CAST(@v161alivepositiontaking_85 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_86="'+ COALESCE(CAST(@v161alivepositiontaking_86 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_87="'+ COALESCE(CAST(@v161alivepositiontaking_87 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_89="'+ COALESCE(CAST(@v161alivepositiontaking_89 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'v161alivept_90="'+ COALESCE(CAST(@v161alivepositiontaking_90 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" /></Acc_CustomerInsMember_Com>' 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 400,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH
END
GO

