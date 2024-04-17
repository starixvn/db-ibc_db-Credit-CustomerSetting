/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerLimitCreatedAccountCheck]
	@custid					INT ,
	@RuleID					VARCHAR(10) ,
	@existingMrecommend		INT = 0,
	@existingSrecommend		INT = 0,
	@Prefix					VARCHAR(50),
	@GroupName				VARCHAR(50),
	@IsQRCode				BIT,
	@SystemID				TINYINT,
	@IP						VARCHAR(15),
	@Credit					MONEY,
	@ErrCode				INT = 0 OUTPUT,
	@ErrMsg					NVARCHAR(250) = '' OUTPUT,
	@Language				VARCHAR(2)		= 'E'

AS
/*  
 Created by: Helios  
 Date:2023/06/28
 Task:  Collect Rule Customer Limit Created Account Check 
 DB: DBCUST/CustDB
  
 Revisions:  
 - 20230622@Helios: Alpha/ExtNAP - Create new downlines - Remove some obsolete rules [Redmine: #190167]
 - 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
 */
BEGIN

	SET NOCOUNT ON 

	-----------------------------------------Param Collection--------------------------------------------
	DECLARE 
		@Srecommend		INT ,		
		@Mrecommend		INT ,	
		@Recommend		INT ,
		@RoleID			INT

	SELECT 
		@RoleID		=	roleid,
		@Srecommend =	srecommend,
		@Mrecommend =	mrecommend,
		@Recommend	=	recommend
	FROM custinfo WITH(NOLOCK) 
	WHERE custid = @custid

	-- Limit Create New Account
	DECLARE @ToDay				DATE,
			@CntDownlines		INT = 0

	SELECT @today = GETDATE()

	-- Limit maximum account created per day by Site (300 accounts, IBCIndo only)
	DECLARE 
			@DefaultValueLimitAcc		INT = 0, 
			@lastAccountToDay			INT = 0, 
			@CurrentDate				DATETIME,
			@Site						VARCHAR(10)

	SET @CurrentDate  = CONVERT(DATE,GETDATE())
	SET @Site = (SELECT Site FROM Customer WITH (NOLOCK) where custid = @Srecommend)
	SET @DefaultValueLimitAcc = ISNULL((SELECT Limit FROM dbo.fn_LimitCreateAccountSiteConfig(@Site)),0)
	
	-- Cannot create more 1296 accounts Master,Agent. And 46656 accounts Member
	DECLARE @seqname	VARCHAR(10) = ''
	DECLARE @downline	INT

	---------------------------------------------------------------------------------------------------------------------

	IF @RuleID = 'AG'			-- SP related : Acc_CustomerInsMember_Ag
	BEGIN
		-- Limit Create New Account
		 IF EXISTS(SELECT 1 FROM ProblemAccountLimitDownline WITH(NOLOCK) WHERE custid IN(@srecommend,@mrecommend,@custid)) 
		 BEGIN
			SELECT @cntDownlines = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE recommend = @custid 
					AND creatdate >= @today
					AND roleid = 1
			IF @cntDownlines >=5
			BEGIN
				SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you can only create 5 members per day, please try again tomorrow.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40062, @Language) 
								 END,
					   @ErrCode = 1002
				RETURN
			END
		 END
		--END

		-- Agent can only create up to 200 new members every day by QR
		IF @IsQRCode = 1
		BEGIN
			DECLARE @QRMemberCount INT

			SELECT @QRMemberCount = COUNT(1) 
			FROM Customer a WITH(NOLOCK) 
				INNER JOIN CustQRCode b WITH(NOLOCK) ON a.CustID = b.CustID
			WHERE a.recommend = @Recommend AND a.roleid = 1 AND a.creatdate BETWEEN CONVERT(DATE,GETDATE()) AND GETDATE()

			IF @QRMemberCount >= 200
			BEGIN
				SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'You can only create up to 200 new members every day by this function.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40051,@Language)
									END,
					   @ErrCode = 40051
				RETURN
			END
		END

		-- Check IP to create downline
		IF @Credit = 0 AND @IP IN ('115.77.62.87', '124.248.244.56', '116.100.7.95'
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
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline OR CSD for further information.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
						END,
					@ErrCode = 1001	
			RETURN
		END

		-- Limit maximum account created per day by Site (300 accounts, IBCIndo only)
		IF @DefaultValueLimitAcc > 0
		BEGIN
			SET @lastAccountToDay = (SELECT  COUNT(1)
					FROM Customer c WITH(NOLOCK)
					WHERE c.recommend = @recommend
								AND c.roleid = 1
								AND c.creatdate  > @CurrentDate)
			IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
			BEGIN
				SELECT	@ErrMsg = CASE @Language  WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
										ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
									END,
						@ErrCode = 40056	
				RETURN
			END
		END
		
		-- Cannot create more 46656 accounts Member
		DECLARE @rowcnt INT 
		
		SELECT	@rowcnt = COUNT(1)
		FROM	dbo.custInfo  WITH(NOLOCK)
		WHERE	Recommend = @CustID AND RoleID = 1 
	
		IF @rowcnt > 7000
		BEGIN 
			CREATE TABLE #tmpSeq (
				Username	NVARCHAR(30),
				SeqName		VARCHAR(3)
			)

			INSERT INTO #tmpSeq(
				Username,
				SeqName
			)
			SELECT   @prefix + SeqName 
					,SeqName
			FROM age_custSeq with (nolock)
			WHERE type = 1  

			CREATE CLUSTERED INDEX IX_tmpSeq_Useranme  
			ON #tmpSeq (Username,SeqName)	

			SELECT TOP 1 @seqname = SeqName
			FROM	#tmpSeq S with (nolock)
				LEFT JOIN dbo.custInfo c WITH(NOLOCK) on s.username = c.username and c.recommend = @custid AND c.roleid = 1
			WHERE  c.username is null 	
			
			DROP TABLE #tmpSeq
		 
		END
		ELSE 
		BEGIN
			SELECT top 1 @seqname = SeqName
			FROM age_custSeq WITH(NOLOCK)
			WHERE type = 1
			AND @prefix + SeqName NOT IN (
				SELECT username			
				FROM dbo.custInfo WITH(NOLOCK)
				WHERE recommend = @custid AND roleid = 1
				)			
		END

		SELECT @downline=COUNT(1) 
		FROM custInfo WITH(NOLOCK)
			WHERE recommend = @custid AND roleid = 1
		
		IF ISNULL(@seqname,'')='' AND @downline>=46656
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you cannot create more accounts because the total downlines have reached the limit (46656 accounts). Please contact your upline for further assistance.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40040, @Language) 
								END,
				   @ErrCode=40040
			RETURN
		END

		-- Check Limit max members creation per Super
		IF @SystemID <> 1
		BEGIN
			DECLARE 
				@CurrentMembers			INT,  
				@MaxMemberLimit			INT,  
				@SuperId				INT  
    
			SELECT @SuperId = srecommend  
			FROM dbo.custinfo WITH (NOLOCK)  
			WHERE custid = @Recommend  
    
			SELECT @MaxMemberLimit = MaxMember  
			FROM dbo.CustSuper WITH (NOLOCK)  
			WHERE CustId = @Srecommend  
   
			IF @MaxMemberLimit = -1  
			BEGIN  
				RETURN  
			END  
   
			SELECT @CurrentMembers = COUNT(1)  
			FROM dbo.custinfo WITH (NOLOCK)  
			WHERE srecommend = @Srecommend  
				AND roleid = 1  
				AND [Enabled] = 1  
   
			SET @ErrCode = CASE WHEN @CurrentMembers > = @MaxMemberLimit THEN 1  ELSE 0  END  
			IF @ErrCode <> 0  
			BEGIN  
				SELECT @ErrMsg = CASE @Language WHEN 'E' THEN N'Sorry, you cannot create more Member accounts because the total Members under your upline have exceeded the limit. Please contact your upline for further assistance.'  
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40038,@Language)  
									END  
				RETURN
			END  
		END

	END

	IF @RuleID = 'SAG'			-- SP related : Acc_CustomerInsMember_SAg
	BEGIN
		-- Limit Create New Account		
		IF EXISTS(SELECT 1 FROM ProblemAccountLimitDownline WITH(NOLOCK) WHERE custid IN(@srecommend,@mrecommend,@custid))
		BEGIN
			SELECT @cntDownlines = COUNT(1) 
			FROM customer WITH(NOLOCK) 
			WHERE srecommend = @custid
				AND creatdate >= @today
				AND roleid = 3
			
			IF @cntDownlines >= 3
			BEGIN
				SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, you can only create 3 members per day, please try again tomorrow.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40062, @Language) END,
					@ErrCode = 1002
				RETURN
			END
		END

		-- Limit maximum account created per day by Site (300 accounts, IBCIndo only)
		IF @DefaultValueLimitAcc > 0
		BEGIN
			SET @lastAccountToDay = (SELECT  COUNT(1)
									FROM Customer c WITH(NOLOCK)
									WHERE c.srecommend = @custid
										AND c.roleid = 3
										AND c.creatdate  > @CurrentDate)
			
			IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
			BEGIN
				Select	@ErrMsg = CASE @Language  
								WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
								ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
							END,
						@ErrCode = 40056	
				RETURN
			END
		END

		-- Check IP to create downline
		IF @IP IN ('127.0.0.1')
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					END,
				@ErrCode = 1001	
			RETURN
		END

		-- Cannot create more 1296 accounts Master,Agent
		SELECT top 1 @seqname = SeqName
		FROM age_custSeq WITH(NOLOCK)
		WHERE type = 2
		AND @prefix + SeqName NOT IN (
			SELECT username
			FROM dbo.custInfo WITH(NOLOCK)
			WHERE srecommend = @custid AND roleid = 3
			)		
		SELECT @downline=COUNT(1) 
		FROM custInfo WITH(NOLOCK)
			WHERE srecommend = @custid AND roleid =3

		IF ISNULL(@seqname,'')='' AND @downline>=1296
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you cannot create more accounts because the total downlines have reached the limit (1296 accounts). Please contact your upline for further assistance.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40039, @Language) 
						END	,
					@ErrCode=40039
			RETURN
		END
		
	END

	IF @RuleID = 'MAG'			-- SP related : Acc_CustomerInsMember_MAg
	BEGIN
		-- Limit Create New Account		
		IF EXISTS(SELECT 1 FROM ProblemAccountLimitDownline WITH(NOLOCK) WHERE custid IN(@srecommend,@mrecommend,@custid))
		BEGIN
			SELECT @cntDownlines = COUNT(1) 
			FROM customer WITH(NOLOCK) 
			WHERE mrecommend = @custid
				AND creatdate >= @today
				AND roleid = 2
			
			IF @cntDownlines >= 3
			BEGIN
				SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Sorry, you can only create 3 members per day, please try again tomorrow.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40062, @Language) END,
					@ErrCode = 1002
				RETURN
			END
		END

		-- Limit maximum account created per day by Site (300 accounts, IBCIndo only)
		IF @DefaultValueLimitAcc > 0
		BEGIN
			SET @lastAccountToDay = (SELECT  COUNT(1)
									FROM Customer c WITH(NOLOCK)
									WHERE c.mrecommend = @custid
										AND c.roleid = 2
										AND c.creatdate  > @CurrentDate)
			
			IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
			BEGIN
				Select	@ErrMsg = CASE @Language  
								WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
								ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
							END,
						@ErrCode = 40056	
				RETURN
			END
		END

		-- Check IP to create downline
		IF @IP IN ('127.0.0.1')
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					END,
				@ErrCode = 1001	
			RETURN
		END
	
		-- Cannot create more 1296 accounts Master,Agent
		SELECT top 1 @seqname = SeqName
		FROM age_custSeq WITH(NOLOCK)
		WHERE type = 2
		AND @prefix + SeqName NOT IN (
			SELECT username
			FROM dbo.custInfo WITH(NOLOCK)
			WHERE mrecommend = @custid AND roleid = 2
			)
		SELECT @downline=COUNT(1) 
		FROM custInfo WITH(NOLOCK)
			WHERE mrecommend = @custid AND roleid =2

		IF ISNULL(@seqname,'')='' AND @downline>=1296
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you cannot create more accounts because the total downlines have reached the limit (1296 accounts). Please contact your upline for further assistance.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40039, @Language) 
							END	,
					@ErrCode=40039
			RETURN
		END
		
	END

	IF @RuleID = 'CSAG'			-- SP related : Acc_CustomerInsMember_CloneSetting_Sag
	BEGIN
		-- Limit Create New Account		
			IF EXISTS(SELECT 1 FROM ProblemAccountLimitDownline WITH(NOLOCK) WHERE custid IN(@srecommend,@mrecommend,@custid))
			BEGIN
				SELECT @cntDownlines = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE srecommend = @custid
					AND creatdate >= @today
					AND roleid = 3
			
				IF @cntDownlines >= 3
				BEGIN
					SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Sorry, you can only create 3 members per day, please try again tomorrow.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40062, @Language) END,
						@ErrCode = 1002
					RETURN
				END
			END
		--END

		-- Limit maximum account created per day by Site (300 accounts, IBCIndo only)
		IF @DefaultValueLimitAcc > 0
		BEGIN
			SET @lastAccountToDay = (SELECT  COUNT(1)
									FROM Customer c WITH(NOLOCK)
									WHERE c.srecommend = @existingSrecommend
										AND c.roleid = 3
										AND c.creatdate  > @CurrentDate)
			
			IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
			BEGIN
				SELECT	@ErrMsg = CASE @Language  
								WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
								ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
							END,
						@ErrCode = 40056	
				RETURN
			END
		END

		-- Check IP to create downline
		IF @IP IN ('127.0.0.1')
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					END,
				@ErrCode = 1001	
			RETURN
		END

		-- Cannot create more 1296 accounts Master,Agent
		SELECT top 1 @seqname = SeqName
		FROM age_custSeq WITH(NOLOCK)
		WHERE type = 2
		AND @prefix + SeqName NOT IN (
			SELECT username
			FROM dbo.custInfo WITH(NOLOCK)
			WHERE srecommend = @custid AND roleid = 3
			)		
		SELECT @downline=COUNT(1) 
		FROM custInfo WITH(NOLOCK)
			WHERE srecommend = @custid AND roleid =3

		IF ISNULL(@seqname,'')='' AND @downline>=1296
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you cannot create more accounts because the total downlines have reached the limit (1296 accounts). Please contact your upline for further assistance.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40039, @Language) 
						END	,
					@ErrCode=40039
			RETURN
		END
		
	END

	IF @RuleID = 'CMAG'			-- SP related : Acc_CustomerInsMember_CloneSetting_MAg
	BEGIN
		-- Limit Create New Account		
			IF EXISTS(SELECT 1 FROM ProblemAccountLimitDownline WITH(NOLOCK) WHERE custid IN(@srecommend,@mrecommend,@custid))
			BEGIN
				SELECT @cntDownlines = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE mrecommend = @custid
					AND creatdate >= @today
					AND roleid = 2
			
				IF @cntDownlines >= 3
				BEGIN
					SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you can only create 3 members per day, please try again tomorrow.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](40062, @Language) 
									 END,
						  @ErrCode = 1002
					RETURN
				END
			END
		--END

		-- Limit maximum account created per day by Site (300 accounts, IBCIndo only)
		IF @DefaultValueLimitAcc > 0
		BEGIN
			SET @lastAccountToDay = (SELECT  COUNT(1)
									FROM Customer c WITH(NOLOCK)
									WHERE c.mrecommend = @existingMrecommend
										AND c.roleid = 2
										AND c.creatdate  > @CurrentDate)
			
			IF @lastAccountToDay + 1 > @DefaultValueLimitAcc
			BEGIN
				Select	@ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you cannot create more accounts. The maximum accounts created per day is '+ CAST(@DefaultValueLimitAcc AS VARCHAR(10)) +'.'
										 ELSE REPLACE(REPLACE([dbo].[f_Get_MsgNamebyMsgID](40056,@Language),'<300>',CAST(@DefaultValueLimitAcc AS VARCHAR(10))),'(300)',CAST(@DefaultValueLimitAcc AS VARCHAR(10)))
								  END,
						@ErrCode = 40056	
				RETURN
			END
		END

		-- Check IP to create downline
		IF @IP IN ('127.0.0.1')
		BEGIN
			SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Your account is not allowed to create more customer. Please contact your upline or CSD for further information.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40032,@Language)
					END,
				@ErrCode = 1001	
			RETURN
		END

		-- Cannot create more 1296 accounts Master,Agent
		SELECT top 1 @seqname = SeqName
		FROM age_custSeq WITH(NOLOCK)
		WHERE type = 2
		AND @prefix + SeqName NOT IN (
			SELECT username
			FROM dbo.custInfo WITH(NOLOCK)
			WHERE mrecommend = @custid AND roleid = 2
			)
		SELECT @downline=COUNT(1) 
		FROM custInfo WITH(NOLOCK)
			WHERE mrecommend = @custid AND roleid =2

		IF ISNULL(@seqname,'')='' AND @downline>=1296
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Sorry, you cannot create more accounts because the total downlines have reached the limit (1296 accounts). Please contact your upline for further assistance.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](40039, @Language) 
							 END	,
				   @ErrCode=40039
			RETURN
		END
	
	END

	IF @RuleID = 'EAS'			-- SP related : EAS_CustomerInsMember_CloneSetting_Com
	BEGIN
		-- Check limit super per month
		DECLARE @tmpCustGroup TABLE(CustID INT)
		DECLARE @fromdate DATETIME,
				@countSuper INT
		
		SELECT @fromdate = CAST(DATEADD(DAY,-DATEPART(DAY,GETDATE())+1,GETDATE()) as DATE)
		
		INSERT INTO @tmpCustGroup(CustID)
		SELECT custid
		FROM Acc_CustGroup WITH(NOLOCK)
		WHERE GroupName = @GroupName
		
		SELECT @countSuper = COUNT(1)
		FROM customer WITH(NOLOCK)
		WHERE CustID IN (SELECT CustID FROM @tmpCustGroup)
			AND creatdate >= @fromdate 
			
		IF @countSuper >= 300
		BEGIN
			SELECT @ErrMsg =  'You can only create up to 300 supers per month.',
				@ErrCode = 201
			RETURN		
		END	
	END


END