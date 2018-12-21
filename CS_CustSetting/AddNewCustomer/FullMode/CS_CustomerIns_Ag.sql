/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustomerIns_Ag
	@custid				INT OUTPUT,
	@username			VARCHAR(30),
	@firstname			NVARCHAR(50),
	@userpwd			VARCHAR(40),
	@credit				MONEY,	
	@creator			INT,
	@recommend			INT,

	@PTSetting			VARCHAR(MAX),
	@BetSetting			VARCHAR(MAX),
	@CommSetting		VARCHAR(MAX),
	@IsTest				BIT = 0,
	@ugroup				VARCHAR(3),

	@Language			VARCHAR(2)= 'E',
	@SubAccID			INT = 0,--Sub-AccountID,	
	@SystemID			TINYINT=1,	
	@IP					VARCHAR(15)='',
	@success			BIT = 1 OUTPUT,
	@ErrCode			INT = 0 OUTPUT,
	@ErrMsg				NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: 20181212@Elodie
	Task : Create Member
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @ErrCode:
			= 0: Create member successfully.
			> 0: Specific Error.
  
		• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON
	
	DECLARE @currency INT, @pwdexpiry DATETIME, @lastMINUTEMemberCount INT, @IsInternal BIT, @srecommend INT, @mrecommend INT,
			@Credit_AllOtherMember MONEY, @Credit_Ag MONEY,
			@matchlimit SMALLMONEY, @virtualmultiplier SMALLMONEY,
			@Asuspended BIT, @UplineClosed BIT, @autosuspend BIT, @autosuspend2 BIT 
	
	SELECT @username = RTRIM(LTRIM(@username))
	SELECT @pwdexpiry = DATEADD(dd, 30, GETDATE())
	SELECT @srecommend = srecommend, @mrecommend = mrecommend FROM dbo.customer WITH(NOLOCK) WHERE custid = @recommend AND roleid = 2

	-----BEGIN: 20180703@viet: normal agent can create up to 10 members per minute. Restricted Robot master/agent can open up to 1 low-credit member each minute
	DECLARE @RestrictedCredit money = 100
	IF @credit < @RestrictedCredit
	BEGIN
		--Restricted Agent, can open up to 1 low-credit member each minute--------------
		IF EXISTS(SELECT 1 from dbo.f_RestrictedRobotAgents('agent') WHERE custid = @recommend)
		BEGIN
			SELECT TOP (1) @success = CASE WHEN creatdate > DATEADD(MINUTE, -1, CURRENT_TIMESTAMP) THEN 0 ELSE 1 END
			FROM dbo.customer WITH(NOLOCK)
			WHERE roleid = 1 and recommend = @recommend 
			ORDER BY custid DESC
		
			IF (@success = 0) -- not allow	
			BEGIN		
				SELECT	@ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry. You cannot create member too often.'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language) END,
						@success = 0, @ErrCode = 998
				RETURN
			END
		END 	
	
		--Restricted Master, can open up to 1 low-credit member each minute--------------
		IF EXISTS(SELECT 1 from dbo.f_RestrictedRobotAgents('master') WHERE custid = @mrecommend)
		BEGIN
			SELECT TOP (1) @success = CASE WHEN creatdate > DATEADD(MINUTE, -1, CURRENT_TIMESTAMP) THEN 0 ELSE 1 END
			FROM dbo.customer WITH(NOLOCK)
			WHERE roleid = 1 and mrecommend = @mrecommend 
			ORDER BY custid desc

			IF (@success = 0) -- not allow	
			BEGIN		
				SELECT	@ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry. You cannot create member too often.'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language) END,
						@success = 0, @ErrCode = 998
				RETURN
			END
		END
	END

	IF @SystemID <> 1 -- internal agents: allow to create member freely
	BEGIN -- can create upto 10 members / min
		DECLARE @result_top10 TABLE (custid int)
		INSERT INTO @result_top10 (custid)
		SELECT TOP (10) custid
		FROM Customer WITH(NOLOCK)
		WHERE recommend = @recommend AND roleid = 1 
		ORDER BY custid DESC
	
		IF @@ROWCOUNT = 10
		BEGIN
			SELECT @success = CASE WHEN creatdate > DATEADD(MINUTE, -1, CURRENT_TIMESTAMP) THEN 0 ELSE 1 END
			FROM dbo.customer WITH(NOLOCK)
			WHERE custid IN (SELECT min(custid) FROM @result_top10)

			IF (@success = 0) -- not allow	
			BEGIN		
				SELECT	@ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry. You cannot create member too often.'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](40030,@Language) END,
						@success = 0, @ErrCode = 998
				RETURN
			END
		END	
	END
	-----END: 20180703@viet: normal agent can create upto 10 members per minute. Restricted Robot master/agent can open up to 1 low-credit-member each minute. Normal agent can open up to 10 members per minute

	--20140619@Johnson: Check IP to create downline-----------------
	Declare @isValidIP BIT
	
	IF	@credit = 0 AND
		@IP IN ('115.77.62.87', '124.248.244.56', '116.100.7.95'
				--20140626@Thien:
				,'183.91.31.31', '115.77.62.87', '42.117.7.217','203.113.172.148', '42.112.19.168'
				, '124.248.229.174', '118.69.77.60', '123.103.252.62'
			
				--20140627@Thien:
				,'116.100.7.95', '118.142.46.201', '118.69.174.108', '42.117.4.151', '122.117.7.217'
			
				--20140628@Thien:
				,'123.103.241.62', '203.113.173.121', '123.103.241.62'
			
				--20140630@Thien:
				,'61.8.32.91', '115.78.234.153'
			
				--20140701@Thien:
				,'14.169.66.152'
				)
		SELECT @isValidIP = 0 
	
	IF @isValidIP = 0
	BEGIN
		SELECT	@ErrMsg = CASE @Language WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline OR CSD for further information.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language) END,
				@ErrCode = 1001	
		RETURN
	END
    --End check IP--------------------------------------------------

	---- check constraint on prefix username same as upline in case of creating member from alpha site
	DECLARE @uplineUsername NVARCHAR(50)
	IF @creator = @recommend
	BEGIN
		SELECT @uplineUsername = username 
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @recommend

		IF LEFT(@username,LEN(@uplineUsername)) <> @uplineUsername
		BEGIN			
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'This function is under maintenance and not available at the moment. Please kindly check back later. Thank you!' 
											ELSE [dbo].[f_Get_MsgNamebyMsgID](90011, @Language) END,
				   @success = 0, @ErrCode = 101
			RETURN
		END
	END 
	---- END: check constraint on prefix username same as upline in case of creating member from alpha site

	--Check an account disabled or not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @recommend, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0		
		RETURN 
	
	IF EXISTS(SELECT 1 FROM customer WITH(NOLOCK) WHERE username= @username)
	    or EXISTS (SELECT 1 FROM customer WITH(NOLOCK) WHERE username2 = @username)
	    or EXISTS(SELECT 1 FROM custsub WITH(NOLOCK) WHERE username= @username)
		OR EXISTS(SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username= @username)
		OR EXISTS (SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username2 = @username)
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
						    WHEN 'E' THEN 'This username is not available.'
						    ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
					    END		
	    SELECT @ErrCode = 1101
	    RETURN
    END

	--Check Limit max members creation per Super
	IF @SystemID <> 1
	BEGIN
		EXEC Age_MaxMemberLimitBySuperCheck @AgentId = @recommend, @Language = @Language, @ErrMsg = @ErrMsg OUTPUT, @ErrCode = @ErrCode OUTPUT
		IF @ErrCode <> 0 RETURN
	END

    DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
    SET @startRun = GETDATE()

	EXEC dbo.CS_CustomerIns_Check 
		@UplineID		= @recommend,
		@PTSetting		= @PTSetting,
		@BetSetting		= @BetSetting,
		@CommSetting	= @CommSetting,
		@IsTest			= @IsTest, 
		@ugroup			= @ugroup,
		@ErrCode		= @ErrCode OUTPUT,
		@ErrMsg			= @ErrMsg OUTPUT
	IF @ErrCode <> 0
		RETURN

    SELECT @currency = currency
         , @mrecommend = mrecommend
         , @srecommend = srecommend
         , @Credit_Ag = ISNULL(Credit, 0)     
         , @Asuspended = reject
         , @UplineClosed = closed
         , @matchlimit = matchlimit
         , @autosuspend = ISNULL(autosuspend, 0)
         , @autosuspend2 = ISNULL(autosuspend2, 0)
         , @virtualmultiplier = ISNULL(virtualmultiplier, 1)           
     FROM custinfo WITH(NOLOCK)
     WHERE CustID = @recommend	

    SELECT @Credit_AllOtherMember = ISNULL(SUM(Credit), 0) FROM custinfo WITH(NOLOCK) WHERE recommend = @recommend AND RoleID = 1
    
    IF @Credit + @Credit_AllOtherMember > @Credit_Ag
    BEGIN
		SELECT @ErrMsg= CASE @Language 
							WHEN 'E' THEN 'Sorry, credit increase unsuccessful. You have exceeded your agent credit.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](70003,@Language)
						END	
				,@success = 0, @ErrCode = 204
		RETURN
    END

    --Insert general data 
	EXEC dbo.Acc_CustomerInsUserInfo
	    @custid = @custid OUTPUT,
		@username = @username,
	    @firstname = @firstname,
		@userpwd = @userpwd,
		@credit = @credit,	

	    @creator = @creator,
	    @srecommend = @srecommend,
	    @mrecommend = @mrecommend,
	    @recommend = @recommend,
	    @roleid = 1,

	    @pwdexpiry = @pwdexpiry,
	    @currency = @currency,
	    @site = '',
	    @ugroup = @ugroup,

		@suspended = @Asuspended,
	    @closed = @UplineClosed,
		@SystemID=@SystemID,
	    @autosuspend = @autosuspend,
	    @autosuspend2 = @autosuspend2,
		@virtualmultiplier = @virtualmultiplier,
		@matchlimit = @matchlimit,

		@lastname = '',
	    @phone = '',
	    @mobilephone = '',
	    @email = '',
	    @fax = '',
	    @address = '',
	    @city = '',
	    @state = '',
	    @country = '',
	    @postal = '',
	    @TransferOption = NULL,
	    @DisableOutright = 1,	
	    @DisableCasino = 1,
		@DisableNumber = 1,	 
	    @DoubleCommLosing = 1,-- off double comm losing WHEN create new member
	    @DisableCasinoBonus = 1,	    	 
	    
	    @IP = @IP,
	    @TransferOption_dec = NULL,
	    @Language = @Language,
	    @ErrCode = @ErrCode OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT
    IF @ErrCode <> 0
		RETURN

     ---- Create balance for new customer   
	EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditInitialize @CustID = @CustID, @errCode = @ErrCode OUTPUT
    IF @ErrCode <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg= CASE @Language 
							WHEN 'E' THEN 'Create member fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						END	
			    , @success = 0, @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
		EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    RETURN
    END
	
	EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitInitialize @CustID = @CustID, @errCode = @ErrCode OUTPUT 
    IF @ErrCode <> 0
    BEGIN
	    --Error occurs
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create member fail. Please try again'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40018,@Language)
						    END	
			    , @success = 0, @ErrCode=216
    	
	    -- ROLLBACK MANUALLY
		EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
		EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID
	    EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	    RETURN
    END
	
	EXEC dbo.CS_DynamicCustomerInfo_00
		@CustID			= @custid,	
		@PTSetting		= @PTSetting, 
		@BetSetting		= @BetSetting,
		@CommSetting	= @CommSetting,
		@IsTest			= @IsTest, 
		@uGroup			= @uGroup,
		@ErrCode		= @ErrCode OUTPUT
	IF @ErrCode > 0
	BEGIN
		SELECT @ErrMsg= CASE @Language 
							WHEN 'E' then 'Create customer fail. Please try again'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
						END
		
		EXEC DBTXN.bodb02.dbo.Dot_BalanceCreditRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelCredit @CustID = @CustID
		EXEC DBTXN.bodb02.dbo.Dot_BalanceDebitRemove @CustID = @CustID --EXEC DBTXN.bodb02.dbo.Dot_BalanceDelDebit @CustID = @CustID
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
		RETURN
	END	
	
    SELECT @Success = 1
    SET @endRun = getdate()
	SET @duration  = datediff (millisecond,@startRun,@endRun)

    DECLARE @LogSPData VARCHAR(MAX)

     --Write general info
    SELECT @LogSPData = '<CS_CustomerIns_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'username="'+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + '" ' +
		'fname="'+ dbo.f_EncodeXMLValue(COALESCE(CAST(@firstname AS VARCHAR(100)), SPACE(1))) + '" ' +
		'credit="'+ COALESCE(CAST(@credit AS VARCHAR(50)), SPACE(1)) + '" ' +
		'ugroup="'+ COALESCE(CAST(@ugroup AS VARCHAR(5)), SPACE(1)) + '" ' +
		'creator="'+ COALESCE(CAST(@creator AS VARCHAR(50)), SPACE(1)) + '" ' +
		'recommend="'+ COALESCE(CAST(@recommend AS VARCHAR(50)), SPACE(1)) + '" ' +
		'site="'+ COALESCE(CAST('' AS VARCHAR(50)), SPACE(1)) + '" ' +
		'success="'+ COALESCE(CAST(@success AS VARCHAR(50)), SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1)) + '" ' +
		'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

    EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100403,
		@TrackingValue = @LogSPData,
		@duration = @duration		

	--Log status
    SELECT @LogSPData = '<CS_CustomerIns_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
						'autosuspend="'+ COALESCE(CAST(@autosuspend AS VARCHAR(1)),SPACE(1)) + '" ' +
						'autosuspend2="'+ COALESCE(CAST(@autosuspend2 AS VARCHAR(1)),SPACE(1)) + '" ' +
						'suspended="'+ COALESCE(CAST(@Asuspended AS VARCHAR(1)), SPACE(1)) + '" ' +
						'closed="'+ COALESCE(CAST(@UplineClosed AS VARCHAR(1)), SPACE(1)) + '" ' +	
						'virtualmultiplier="'+ COALESCE(CAST(@virtualmultiplier AS VARCHAR(10)),SPACE(1)) + '" ' +
						'IsInternal="'+ COALESCE(CAST(@IsInternal AS VARCHAR(1)), SPACE(1)) + '" />'

    EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100503,
		@TrackingValue = @LogSPData,
		@duration = @duration	

	-- Write Log Credit	
    DECLARE @LogSPCredit VARCHAR(MAX)
    SELECT @LogSPCredit = 'UserName='+ COALESCE(CAST(@username AS VARCHAR(30)), SPACE(1)) + ', SubAccName='+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) 

    EXEC dbo.Acc_WriteLog_UserLog_Credit_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@Doing = @LogSPCredit,
		@NewValue = @credit,
		@IP = @IP,
		@ActionID = 1216

	--Write PT log
	SELECT '<CS_CustomerIns_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '">' 
		+ LTRIM(RTRIM(SUBSTRING(@PTSetting, 7, LEN(@PTSetting) - 13))) 
		+ '</CS_CustomerIns_Ag>' 

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100003,
		@TrackingValue = @LogSPData,
		@duration = @duration

    --Write Bet setting log
	SELECT '<CS_CustomerIns_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '">' 
		+ LTRIM(RTRIM(SUBSTRING(@BetSetting, 7, LEN(@BetSetting) - 13))) 
		+ '</CS_CustomerIns_Ag>' 

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100303,
		@TrackingValue = @LogSPData,
		@duration = @duration

    --Write commission log	
	SELECT '<CS_CustomerIns_Ag custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '">' 
		+ LTRIM(RTRIM(SUBSTRING(@CommSetting, 7, LEN(@CommSetting) - 13))) 
		+ '</CS_CustomerIns_Ag>' 

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @Creator,
		@CustID = @CustID,
		@ActionID = 100203,
		@TrackingValue = @LogSPData,
		@duration = @duration	
END
GO