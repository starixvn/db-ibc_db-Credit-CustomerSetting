/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsUserInfo_DirectMember]
(
	@custid INT OUTPUT,
	@firstname NVARCHAR(50),
	@lastname NVARCHAR(50),
	@creator INT,
	@username VARCHAR(30),
	@userpwd VARCHAR(40),
	@pwdexpiry DATETIME,
	@currency INT,
	@site NVARCHAR(50),
	@ugroup VARCHAR(5) = NULL,

	@srecommend INT,
	@mrecommend INT,
	@recommend INT,
	@UplineID INT,
	@roleid INT,
	
	@Danger TINYINT = 0,
	@Danger2 TINYINT = 0,
	@Danger3 TINYINT = 0,
	@Danger4 TINYINT = 0,
	@Danger5 TINYINT = 0,
	@Abnormal TINYINT = 0,
	
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@email NVARCHAR(50),
	@fax NVARCHAR(50),
	@address NVARCHAR(80),
	@city NVARCHAR(50),
	@state NVARCHAR(50),
	@country NVARCHAR(50),
	@postal NVARCHAR(50),

	@closed BIT = NULL,	
	@DisableOutright BIT = 0,
	@matchlimit SMALLMONEY,
	@virtualmultiplier SMALLMONEY,
	
	@autosuspend BIT = 0,
	@autosuspend2 BIT = 0,
	@autosuspend3 BIT = 0,

	@DoubleCommLosing BIT = 0,
	@DisableSuperLive BIT = 0,	
	@credit MONEY,
	
	@IP VARCHAR(15)='',
	@SystemID	TINYINT=1,
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
	)
AS

/*
	Created: 20241107@Eden	
	Task: Super/Master create direct member - Insert setting, base on from Acc_CustomerInsUserInfo
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 
		
	Parameter's Explanation:
	
*/	
BEGIN
    SET NOCOUNT ON 
	DECLARE @CreateDate DATETIME = GETDATE()

	BEGIN TRY
		EXEC Acc_CustomerIns
			 @FirstName	= @FirstName	
			,@LastName	= @LastName	
			,@UserName	= @UserName	
			,@UserPwd	= @UserPwd	 
			,@pwdexpiry = @pwdexpiry 
			,@roleid	= @roleid	
			,@closed	= @closed	
			,@CustID	= @CustID	
			,@creator	= @creator	

			,@phone			= @phone			
			,@mobilephone	= @mobilephone	
			,@email			= @email			
			,@fax			= @fax			
			,@address		= @address		
			,@city			= @city			
			,@state			= @state			
			,@country		= @country		
			,@postal		= @postal		
			,@srecommend	= @srecommend	
			,@mrecommend	= @mrecommend	
			,@recommend		= @recommend		
			,@currency		= @currency		
			,@site			= @site			
			,@ugroup		= @ugroup
			
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg  = @ErrMsg OUTPUT

	END TRY
	BEGIN CATCH 
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004, @Language)
							END,
			@ErrCode = 111
		RETURN
	END CATCH
	
	INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual,RepUpdateTime)
	SELECT @Custid, seqNo, bitmapVirtual, [dbo].[f_GetDateTime2]() as RepUpdateTime
	FROM CustVirtualSetting WITH(NOLOCK)
	WHERE custid = @UplineID

    IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END
		     , @ErrCode = 112
	    RETURN
    END	

	--VR lock status
	INSERT INTO VRCustLockStatus(CustID,Type,RepUpdateTime)
	SELECT @custid,Type, [dbo].[f_GetDateTime2]() as RepUpdateTime
	FROM VRCustLockStatus v (NOLOCK) 
	WHERE CustID = @UplineID
		AND NOT EXISTS( SELECT 1 FROM VRCustLockStatus(NOLOCK) WHERE CustID = @custid AND type = v.Type)

	IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END
		     , @ErrCode = 112
	    RETURN
    END	

	DECLARE @ClosedReason TINYINT 
	IF(@SystemID=1 AND @closed=1)
		SELECT @ClosedReason=1
	ELSE IF(@SystemID<>1 AND @closed=1)
		SELECT @ClosedReason=2
	ELSE 
		SELECT @ClosedReason=0
		
	IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo_Member WITH(NOLOCK) WHERE custid = @custid)
	BEGIN
		INSERT INTO CustLoginInfo_Member([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason,RepUpdateTime)
		SELECT @custid,NULL,@IP,@creator,GETDATE(),@ClosedReason,[dbo].[f_GetDateTime2]()

		IF @@ERROR <> 0
		BEGIN
			SELECT	@ErrMsg = CASE @Language
									WHEN 'E' THEN 'Create customer failed. Please try again.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END
					,@ErrCode = 115
			RETURN
		END
	END

	BEGIN TRY
		DECLARE @DangerLevel BIGINT = NULL

		SELECT @DangerLevel=DangerLevel
		FROM dbo.f_CustSetting_DangerLevel(@site, @currency)

		INSERT INTO [dbo].[custinfo]
		(
			custid, currency
		  , roleid, srecommend, mrecommend, recommend, dangercust
		  , autosuspend, autosuspend2, autosuspend3
		  , credit
		  , username
		  , MatchLimit, VirtualMultiplier
		  , DisableOutright
		  , danger, danger2, danger3, danger4, danger5, Abnormal
		  , DoubleCommLosing
		  , DisableSuperLive
		  , DangerLevel
		  , RepUpdateTime
		  )
		SELECT
			@custid, @currency
		  , @roleid, @srecommend, @mrecommend, @recommend, 0
		  , @autosuspend, @autosuspend2, @autosuspend3
		  , @credit
		  , @username
		  , @matchlimit, @virtualmultiplier
		  , @DisableOutright
		  , @danger, @danger2, @danger3, @danger4, @danger5, @Abnormal
		  , @DoubleCommLosing	
		  , @DisableSuperLive
		  , @DangerLevel
		  , [dbo].[f_GetDateTime2]()
		
	END TRY
	BEGIN CATCH		
		SELECT @ErrMsg = CASE @Language
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END,
				@ErrCode = 113
		RETURN
    END CATCH
	
	IF @site = '611111'
	BEGIN
		INSERT INTO [VRSettingManualUpdAcc](CustID,SportType,RepUpdateTime)			
		SELECT @CustID,43 AS SportType, [dbo].[f_GetDateTime2]() as RepUpdateTime
		WHERE NOT EXISTS (SELECT 1 FROM VRSettingManualUpdAcc WHERE custid = @CustId AND SportType = 43)

		IF @@ERROR <> 0
		BEGIN 
		--	DELETE customer with (ROWLOCK) where custid =  @custid
			SELECT @ErrMsg = CASE @Language
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END,
					@ErrCode = 113
			RETURN
		END

	
		DECLARE @InitBitmap varbinary(30)  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

		INSERT INTO CustSettingAutoSuspend(CustID,SportType,AutoSuspendLive,AutoSuspendNonLive,OverrideASLive,OverrideASNonLive,RepUpdateTime)
		SELECT @custid, 43 AS SportType, @InitBitmap, @InitBitmap, @InitBitmap, @InitBitmap, [dbo].[f_GetDateTime2]() as RepUpdateTime

		IF @@ERROR <> 0
		BEGIN 
			SELECT @ErrMsg = CASE @Language
								WHEN 'E' THEN 'Create customer failed. Please try again.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
								END,
					@ErrCode = 113
			RETURN
		END
	END
END
GO