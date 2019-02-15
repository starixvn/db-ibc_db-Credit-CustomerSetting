/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerIns_Com]
	@custid						INT OUTPUT,
	@username					VARCHAR(30),
	@MainShareholderUsername	VARCHAR(30),
	@userpwd					VARCHAR(40),
	@firstname					NVARCHAR(50),
	@lastname					NVARCHAR(50),
	@phone						NVARCHAR(50),
	@mobilephone				NVARCHAR(50),
	@fax						NVARCHAR(50),
	@currency					INT, 
	@credit						MONEY,

	@PTSetting					VARCHAR(MAX),
	@BetSetting					VARCHAR(MAX),
	@CommSetting				VARCHAR(MAX),
	@IsTest						BIT = 0,
	@ProductId					TINYINT = 1,

	@creator					INT,
	@site						NVARCHAR(50),	
	@isinternal					BIT = 0,

	@SystemID					TINYINT = 1,	
	@IP							VARCHAR(15)='',
	@Language					VARCHAR(2)= 'E',	
	@ErrCode					INT = 0 OUTPUT,
	@ErrSettingType 			TINYINT = 0 OUTPUT,
	@MsgType					INT	= 0 OUTPUT,
	@ErrMsg						NVARCHAR(MAX) = '' OUTPUT
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
	DECLARE @autosuspend BIT, @autosuspend2 BIT, @MainShareholderId INT
	
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

	SELECT @MainShareholderId = custid FROM Customer WITH (NOLOCK) WHERE username= @MainShareholderUsername AND roleid = 0
	IF @MainShareholderId IS NULL
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Main Shareholder does not exist.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40039,@Language)
						END
		SELECT @ErrCode = 102
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
		@MainShareholderId = @MainShareholderId,
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

	DECLARE @LogSPData VARCHAR(MAX), @MaxMemberLog VARCHAR(50), @LogXML XML
	SELECT @MaxMemberLog = CASE WHEN @Site = '789y' THEN '20000' ELSE 'Unlimited' END

	--Write general info
	SELECT @LogSPData = '<R fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)),SPACE(1))) + '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS VARCHAR(100)),SPACE(1))) + '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS VARCHAR(100)),SPACE(1))) + '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS VARCHAR(100)),SPACE(1))) + '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS VARCHAR(100)),SPACE(1))) + '" ' +
						'username="'+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1)) + '" ' +
						'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +								
						'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
						'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
						'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" />'
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 160000,
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
	SELECT * INTO #PT_tmp
	FROM dbo.f_CS_PTParse(CAST(@PTSetting AS XML))

	SELECT @LogXML = (SELECT	@ProductId														AS '@ProductID',
								@IP																AS '@IP',
								cs.isLive														AS '@IsL',
								CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPT',
								CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPT'
						FROM #PT_tmp cs
						FOR XML PATH('R'), 
						TYPE
					)
	SELECT @LogSPData = CONVERT(VARCHAR(MAX), @LogXML)

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 119997,
		@TrackingValue = @LogSPData,
		@duration = @duration
	
	--Write Bet setting log
	SELECT * INTO #BetSetting_tmp
	FROM dbo.f_CS_BetSettingParse(CAST(@BetSetting AS XML))

	SELECT @LogXML = (SELECT	@ProductId						AS '@ProductID',
								@IP                             AS '@IP',
								(SELECT SportType AS '@Sport'
									, BetType AS '@BT'
									, IsLive AS '@IsL'
									, CAST(CONVERT(DOUBLE PRECISION,MaxBet) AS VARCHAR(30)) AS '@Max'
									, CAST(CONVERT(DOUBLE PRECISION,MaxPerEvent) AS VARCHAR(30)) AS '@MPM'
								FROM #BetSetting_tmp
								FOR XML PATH('C'), TYPE)						
						FOR XML PATH('R'), TYPE)		
	SELECT @LogSPData = CONVERT(VARCHAR(MAX), @LogXML)

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 149996,
		@TrackingValue = @LogSPData,
		@duration = @duration
	
	--Write commission log	
	SELECT * INTO #Comm_tmp
	FROM dbo.f_CS_CommParse(CAST(@CommSetting AS XML))

	CREATE TABLE #Com_Log (SportType SMALLINT, BetType SMALLINT, IsLive BIT, GroupA DECIMAL(9,8), GroupB DECIMAL(9,8), GroupC DECIMAL(9,8), GroupD DECIMAL(9,8), Comm DECIMAL(9,8))
	INSERT INTO #Com_Log(SportType, BetType, IsLive)
	SELECT DISTINCT SportType, BetType, IsLive
	FROM #Comm_tmp

	UPDATE l
	SET l.GroupA = ct.Value
	FROM #Com_Log l
		INNER JOIN #Comm_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
		INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
		LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
	WHERE gc.GroupName = 'A'

	UPDATE l
	SET l.GroupB = ct.Value
	FROM #Com_Log l
		INNER JOIN #Comm_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
		INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
		LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
	WHERE gc.GroupName = 'B'

	UPDATE l
	SET l.GroupC = ct.Value
	FROM #Com_Log l
		INNER JOIN #Comm_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
		INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
		LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
	WHERE gc.GroupName = 'C'

	UPDATE l
	SET l.GroupD = ct.Value
	FROM #Com_Log l
		INNER JOIN #Comm_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
		INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
		LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
	WHERE gc.GroupName = 'D'

	UPDATE l
	SET l.Comm = ct.Value
	FROM #Com_Log l
		INNER JOIN #Comm_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
		INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
		LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
	WHERE gc.GroupId IS NULL

	SELECT @LogXML = (SELECT	@ProductId						AS '@ProductID',
								@IP                             AS '@IP',
								(SELECT t.SportType AS '@Sport'
									, t.BetType AS '@BT'
									, t.IsLive AS '@IsL'
									, CAST(CONVERT(DOUBLE PRECISION,t.GroupA) AS VARCHAR(30)) AS '@GroupA'
									, CAST(CONVERT(DOUBLE PRECISION,t.GroupB) AS VARCHAR(30)) AS '@GroupB'
									, CAST(CONVERT(DOUBLE PRECISION,t.GroupC) AS VARCHAR(30)) AS '@GroupC'
									, CAST(CONVERT(DOUBLE PRECISION,t.GroupC) AS VARCHAR(30)) AS '@GroupD'
									, CAST(CONVERT(DOUBLE PRECISION,t.Comm) AS VARCHAR(30))   AS '@Comm'
								FROM #Com_Log t
								FOR XML PATH('C'), TYPE)						
						FOR XML PATH('R'), TYPE)

	SELECT @LogSPData = CONVERT(VARCHAR(MAX), @LogXML)

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 139996,
			@TrackingValue = @LogSPData,
			@duration = @duration	
	
END
GO

