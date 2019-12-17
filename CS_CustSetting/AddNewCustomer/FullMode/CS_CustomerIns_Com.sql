/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerIns_Com]
	@custid						INT OUTPUT,
	@username					VARCHAR(30),
	@HeadlineUsername			VARCHAR(30),
	@userpwd					VARCHAR(40),
	@firstname					NVARCHAR(50),
	@lastname					NVARCHAR(50),
	@phone						NVARCHAR(50),
	@mobilephone				NVARCHAR(50),
	@fax						NVARCHAR(50),	
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
		- 20190422@Elodie: Offer unique nickname for CN88 [Redmine:112287]
		- 20100527@Elodie: New account status [Redmine: #113198]
		- 20100627@Elodie: Different PT for Headline [Redmine: #114912]
		- 20190627@Elodie: Apply currency min bet constrain for Bet Setting [Redmine:#115126]
		- 20190708@Johnson: set pwdexpiry = yesterday [redmine:#116088]
	Param's Explanation:
		• @ErrCode:
			= 0: Create super successfully.
			> 0: Specific Error.
  
		• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME , @endRun DATETIME , @duration INT
	DECLARE @autosuspend BIT, @autosuspend2 BIT, @HeadlineId INT, @currency INT
	
	SET @startRun = GETDATE()
	SELECT @ErrCode = 0
	SELECT @autosuspend = 0, @autosuspend2 = 0, @credit = ISNULL(@credit,0)

	SELECT @HeadlineId = custid, @currency = currency FROM Customer WITH (NOLOCK) WHERE username= @HeadlineUsername AND roleid = 0
	IF @HeadlineId IS NULL
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid Headline.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40041,@Language)
						END
		SELECT @ErrCode = 101
		SELECT @ErrSettingType = 1, @MsgType = 200	
		RETURN
	END

	DECLARE @IsExists BIT 
	EXEC CS_CustomerCheckExists @username = @username, @Mode = 0, @IsExists = @IsExists OUTPUT

	IF @IsExists = 1
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'This username is not available.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
						END
		SELECT @ErrCode = 102
		SELECT @ErrSettingType = 1, @MsgType = 200	
		RETURN
	END

	EXEC dbo.CS_CustomerIns_Check 
		@RoleId			= 4,
		@Currency		= @Currency,		
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
	
	DECLARE @pwdexpiry DATETIME 
	
	SELECT @pwdexpiry = dbo.f_CS_GetPwdExpiryDate (4)
	
	--Insert general info
	EXEC dbo.CS_CustomerInsUserInfo 
		@custid = @custid OUTPUT,
		@firstname = @firstname,
		@lastname = @lastname,
		@creator = @creator,
		@username = @username,
		@userpwd = @userpwd,
		@pwdexpiry = @pwdexpiry,
		@currency = @currency,
		@site = @site,
		@HeadlineId = @HeadlineId,
		@srecommend = 0,
		@mrecommend = 0,
		@recommend = 0,
		@roleid = 4,
		@phone = @phone,
		@mobilephone = @mobilephone,
		@fax = @fax,
		@suspended = 0,
		@SystemID = @SystemID,
		@autosuspend = @autosuspend,
		@autosuspend2 = @autosuspend2,		
		@matchlimit = 1,
		--@Johnson: Disable virtual rate status as default
		@virtualmultiplier = 0,	
	
		@credit = @credit,
		@maxcredit = NULL,
		@IP = @IP,
		@isinternal = @isinternal,
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	--Error occurs
	IF @ErrCode <> 0
	BEGIN 
		SELECT @ErrSettingType = 1, @MsgType = 200	
		RETURN	
	END
				
	DECLARE @EffectiveDate DATETIME = CONVERT(DATE,GETDATE()), @GroupName VARCHAR(50)
	
	EXEC dbo.CS_GroupExtraPT_Ins
		@CustID = @custid,
		@HeadlineId = @HeadlineId,
		@EffectiveDate = @EffectiveDate,
		@UserID = @Creator,
		@IP = @IP,
		@GroupName = @GroupName OUTPUT,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT 

	IF @ErrCode > 0
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
		SELECT @ErrSettingType = 1, @MsgType = 200	
		EXEC CS_CustomerInsUserInfo_Rollback @CustID = @CustID		

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
		EXEC CS_CustomerInsUserInfo_Rollback @CustID = @CustID

		EXEC dbo.CS_GroupExtraPT_Ins
			@CustID = @custid,
			@HeadlineId = NULL,
			@EffectiveDate = NULL,
			@UserID = NULL,
			@IP = NULL,
			@IsRollBack = 1,
			@GroupName = @GroupName OUTPUT,
			@ErrCode = @ErrCode OUTPUT,
			@ErrMsg = @ErrMsg OUTPUT 
		RETURN
	END	
		
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	DECLARE @LogSPData NVARCHAR(MAX), @MaxMemberLog VARCHAR(50), @LogXML XML
	SELECT @MaxMemberLog = CASE WHEN @Site = '789y' THEN '20000' ELSE 'Unlimited' END

	--Write general info
	SELECT @LogSPData = '<R fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS NVARCHAR(100)),SPACE(1))) + '" ' +
						'lname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@lastname AS NVARCHAR(100)),SPACE(1))) + '" ' +
						'phone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@phone AS NVARCHAR(100)),SPACE(1))) + '" ' +
						'mphone="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@mobilephone AS NVARCHAR(100)),SPACE(1))) + '" ' +
						'fax="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@fax AS NVARCHAR(100)),SPACE(1))) + '" ' +
						'username="'+ COALESCE(CAST(@username AS VARCHAR(30)),SPACE(1)) + '" ' +
						'Headline="'+ COALESCE(CAST(@HeadlineUsername AS VARCHAR(30)),SPACE(1)) + '" ' +
						'site="'+ COALESCE(CAST(@site AS VARCHAR(100)),SPACE(1)) + '" ' +								
						'currency="'+ COALESCE(CAST(@currency AS VARCHAR(50)),SPACE(1)) + '" ' +
						'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)),SPACE(1)) + '" ' +
						'MaxMember="'+ coalesce(@MaxMemberLog,space(1)) + '" ' +	
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" />'
	EXEC dbo.CS_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 160000,
		@TrackingValue = @LogSPData,
		@duration = @duration	
	
	--Log status
    SELECT @LogSPData = '<R Status="Active" IP="' + COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" />'

    EXEC dbo.CS_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 165003,
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

	SELECT @LogXML = (
						SELECT  @ProductID						AS '@ProductID',
								@IP                             AS '@IP',
							(
								SELECT  cs.sporttype													AS '@Sport',
										cs.isLive														AS '@InPlay',
										dbo.f_CS_FomatNumber (CAST ((cs.MinPT/100.0) AS VARCHAR(50)))	AS '@MinPossess',
										dbo.f_CS_FomatNumber (CAST ((cs.MaxPT/100.0) AS VARCHAR(50)))	AS '@MaxPossess'
								FROM #PT_tmp cs
								FOR XML PATH('C'), 
								TYPE
							)
					FOR XML PATH('R'), 
					TYPE
					)
	SELECT @LogSPData = CONVERT(VARCHAR(MAX), @LogXML)

	EXEC CS_WriteLog_UserLog_RunSP_Wrapper
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
									, IsLive AS '@InPlay'
									, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))	AS '@Max'
									, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))	AS '@MPE'
								FROM #BetSetting_tmp
								FOR XML PATH('C'), TYPE)						
						FOR XML PATH('R'), TYPE)		
	SELECT @LogSPData = CONVERT(VARCHAR(MAX), @LogXML)

	EXEC dbo.CS_WriteLog_UserLog_RunSP_Wrapper
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
									, t.IsLive AS '@InPlay'
									, dbo.f_CS_FomatNumber (CAST (t.GroupA AS VARCHAR(50)))		AS '@GrA'
									, dbo.f_CS_FomatNumber (CAST (t.GroupB AS VARCHAR(50)))		AS '@GrB'
									, dbo.f_CS_FomatNumber (CAST (t.GroupC AS VARCHAR(50)))		AS '@GrC'
									, dbo.f_CS_FomatNumber (CAST (t.GroupD AS VARCHAR(50)))		AS '@GrD'
									, dbo.f_CS_FomatNumber (CAST (t.Comm AS VARCHAR(50)))		AS '@Comm'
								FROM #Com_Log t
								FOR XML PATH('C'), TYPE)						
						FOR XML PATH('R'), TYPE)

	SELECT @LogSPData = CONVERT(VARCHAR(MAX), @LogXML)

	EXEC dbo.CS_WriteLog_UserLog_RunSP_Wrapper
			@UserID = @Creator,
			@CustID = @CustID,
			@ActionID = 139996,
			@TrackingValue = @LogSPData,
			@duration = @duration			

	SELECT  @LogSPData = '<R Headline="'+ COALESCE(CAST(@HeadlineUsername AS VARCHAR(30)),SPACE(1))
						+ '" GroupName="' + @GroupName 
						+ '" EffectiveDate="' + CONVERT(NVARCHAR(10), @EffectiveDate, 120)
						+ '" IP="' + @IP + '" />'

	EXEC CS_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @creator,
		@CustID = @CustID,
		@ActionID = 160008,
		@TrackingValue = @LogSPData,
		@Duration = @Duration

	DROP TABLE #BetSetting_tmp
	DROP TABLE #Comm_tmp
	DROP TABLE #Com_Log
	DROP TABLE #PT_tmp
END
GO

