/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerIns_Com]
	@custid				INT OUTPUT,
	@username			VARCHAR(30),
	@userpwd			VARCHAR(40),
	@firstname			NVARCHAR(50),
	@lastname			NVARCHAR(50),
	@phone				NVARCHAR(50),
	@mobilephone		NVARCHAR(50),
	@fax				NVARCHAR(50),
	@currency			INT, 
	@credit				MONEY,

	@PTSetting			VARCHAR(MAX),
	@BetSetting			VARCHAR(MAX),
	@CommSetting		VARCHAR(MAX),
	@IsTest				BIT = 0,

	@creator			INT,
	@site				NVARCHAR(50),	
	@isinternal			BIT = 0,

	@SystemID			TINYINT = 1,	
	@IP					VARCHAR(15)='',
	@Language			VARCHAR(2)= 'E',	
	@ErrCode			INT = 0 OUTPUT,
	@ErrSettingType 	TINYINT = 0 OUTPUT,
	@MsgType			INT	= 0 OUTPUT,
	@ErrMsg				NVARCHAR(2000) = '' OUTPUT
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
	DECLARE @autosuspend BIT, @autosuspend2 BIT
	
	SET @startRun = GETDATE()
	SELECT @ErrCode = 0
	SELECT @autosuspend = 0, @autosuspend2 = 0

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
		SELECT @ErrSettingType = 1, @MsgType = 200	
		RETURN
	END

	EXEC dbo.CS_CustomerIns_Check 
		@RoleId			= 4,
		@PTSetting		= @PTSetting,
		@BetSetting		= @BetSetting,
		@CommSetting	= @CommSetting,
		@credit			= @credit,
		@IsTest			= @IsTest, 
		@ErrCode		= @ErrCode OUTPUT,
		@ErrSettingType = @ErrSettingType OUTPUT,
		@MsgType		= @MsgType OUTPUT,
		@ErrMsg			= @ErrMsg OUTPUT
	IF @ErrCode <> 0
		RETURN
	
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

		@MaxPerMatch = 0,
		@MaxPerMatchv2 = 0,
		@MaxPerMatchv3 = 0,
		@MaxPerMatchv5 = 0,
		@MaxPerMatchv8 = 0,
		@MaxPerMatchv10 = 0,
		@MaxPerMatchv11 = 0,
		@MaxPerMatchv99 = 0,
		@MaxPerMatchv99MP = 0,
		@MaxPerMatchv161 = 0,	

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
	BEGIN 
		SELECT @ErrSettingType = 1, @MsgType = 200	
		RETURN	
	END
				
	EXEC dbo.CS_DynamicCustomerInfo_00
		@CustID			= @custid,	
		@PTSetting		= @PTSetting, 
		@BetSetting		= @BetSetting,
		@CommSetting	= @CommSetting,
		@IsTest			= @IsTest, 
		@ErrCode		= @ErrCode OUTPUT
	IF @ErrCode > 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
		SELECT @ErrSettingType = 1, @MsgType = 200	
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END	
	
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	DECLARE @LogSPData VARCHAR(MAX), @MaxMemberLog VARCHAR(50)
	SELECT @MaxMemberLog = CASE WHEN @Site = '789y' THEN '20000' ELSE 'Unlimited' END

	--Write general info
	SELECT @LogSPData = '<CS_CustomerIns_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'username="'+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1)) + '" ' +
						'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
						'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
						'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
						'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)),SPACE(1)) + '" ' +	
						'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +		
						'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(4000)),SPACE(1)) + '" />'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100400,
		@TrackingValue = @LogSPData,
		@duration = @duration	
	--status
	SELECT @LogSPData = '<CS_CustomerIns_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
						'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
						'virtualmultiplier="'+ COALESCE(CAST(0 AS VARCHAR(1)),SPACE(1)) + '" ' +
						'IsInternal="'+ COALESCE(CAST(@IsInternal AS VARCHAR(1)),SPACE(1)) + '" />'

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100500,
		@TrackingValue = @LogSPData,
		@duration = @duration	
	
	-- Write Log Credit	
	DECLARE @LogSPCredit VARCHAR(MAX)
	SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1))

	EXEC dbo.Acc_WriteLog_UserLog_Credit_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@Doing = @LogSPCredit,
		@NewValue = @credit,
		@IP = @IP,
		@ActionID = 1213

	--Write PT log
	SELECT @LogSPData = '<CS_CustomerIns_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '">' 
						+ LTRIM(RTRIM(SUBSTRING(@PTSetting, 7, LEN(@PTSetting) - 13))) 
						+ '</CS_CustomerIns_Com>' 

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100000,
		@TrackingValue = @LogSPData,
		@duration = @duration
	
	--Write Bet setting log
	SELECT @LogSPData = '<CS_CustomerIns_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '">' 
						+ LTRIM(RTRIM(SUBSTRING(@BetSetting, 7, LEN(@BetSetting) - 13))) 
						+ '</CS_CustomerIns_Com>' 

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100300,
		@TrackingValue = @LogSPData,
		@duration = @duration
	
	--Write commission log	
	SELECT @LogSPData = '<CS_CustomerIns_Com custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '">' 
						+ LTRIM(RTRIM(SUBSTRING(@CommSetting, 7, LEN(@CommSetting) - 13))) 
						+ '</CS_CustomerIns_Com>' 

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 100200,
			@TrackingValue = @LogSPData,
			@duration = @duration	
	
END
GO

