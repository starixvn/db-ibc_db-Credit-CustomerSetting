/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustomerInsUserInfo
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

	@HeadlineId INT = NULL,
	@srecommend INT,
	@mrecommend INT,
	@recommend INT,
	@roleid INT,
	
	@Danger TINYINT = 0,
	@Danger2 TINYINT = 0,
	@Danger3 TINYINT = 0,
	@Abnormal TINYINT = 0,
	
	@phone NVARCHAR(50),
	@mobilephone NVARCHAR(50),
	@fax NVARCHAR(50),
	@suspended BIT = NULL,

	@closed BIT = NULL,	
	@DisableOutright BIT = 0,
	@matchlimit SMALLMONEY,
	@virtualmultiplier SMALLMONEY,
	@DisableAutoMPT BIT = 1,
	@IsInternal BIT = 0,
	
	@autosuspend BIT = 0,
	@autosuspend2 BIT = 0,

	@credit MONEY,
	@maxcredit MONEY = 0,
	@isSearchAndCopy BIT = 0,
	@copyFromCustID INT = 0,
	
	@IP VARCHAR(15)='',
	@SubAccID INT = 0,--Sub-AccountID,
	@SystemID	TINYINT=1,
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Create customer
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		- 20190527@Elodie: New account status [Redmine:#113198]
		- 20190715@Elodie: Sub account management [Redmine:#116825] 
		- 20190808@Elodie: Add problem account [Redmine:#116814]
		- 20190906@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20200219@Max: Support Separate setting and notification into Live/Non-Live major and minor bettypes [Redmine: #126841]

	Param's Explanation:
		• @ErrCode:
			= 0: Create customer successfully.
			> 0: Specific Error.
  
		• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON 
	
	DECLARE @NotificationInfo VARCHAR(MAX), @CreateDate DATETIME
	
	SET @CreateDate = GETDATE()
	
    INSERT INTO Customer   			
			    (username, firstname, lastname, phone, mobilephone, fax, email, address,
			    city, state, country, postal, userpwd, roleid, srecommend, mrecommend, recommend, 
			    currency, pwdexpiry, creator, Site, creatdate, ugroup
			    ) 
 		VALUES (@username, @firstname, @lastname, @phone, @mobilephone, @fax, '', '', 
				'', '', '', '', @userpwd, @roleid, @srecommend, @mrecommend, @recommend, 
				@currency, @pwdexpiry, @creator, @site, GETDATE(), @ugroup
				)
	
    SELECT @custid=@@IDENTITY
	
    IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create customer failed. Please try again.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004, @Language)
						    END,
			@ErrCode = 111
    		
	    -- ROLLBACK MANUALLY
	    DELETE FROM Customer WITH (ROWLOCK) WHERE custId = @CustID
    		
	    RETURN
    END
	
	EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Ins  @custid, 0, @roleid, @ErrCode, @ErrMsg
	
	IF @ErrCode <>0
	BEGIN
			SELECT @ErrMsg = CASE @Language 
							    WHEN 'E' THEN 'Create customer failed. Please try again.'
							    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004, @Language)
						    END
				, @ErrCode = 116
		 -- ROLLBACK MANUALLY
			DELETE FROM Customer WITH (ROWLOCK) WHERE custId = @CustID
			
			RETURN
	END
	
    DECLARE	@UplineSecurityCode	VARCHAR(50), @isForcedChangeSecurityCode BIT

    SELECT @UplineSecurityCode = NULL
	     , @isForcedChangeSecurityCode = 0

    IF @roleid = 4
    BEGIN
		SELECT @isForcedChangeSecurityCode = 1
        FROM Customer WITH(NOLOCK)
        WHERE custid = @custid

	    SET @srecommend = @custid
	    UPDATE Customer WITH(ROWLOCK, UPDLOCK)
	    SET srecommend = @custid
	    WHERE custId = @CustID
		
	    INSERT INTO CustSuper
	    (
	        custId, AutoIBCPositionTaking_Tote,  IsInternal, TransferOption, MaxMember, UplineId
	    )
	    VALUES
	    (
	        @CustID, 0,  @IsInternal, NULL, -1,			
			@HeadlineId
        )
		
		INSERT INTO dbo.custAccount (custid, creditgrade, installmentdate, installmentamount, preagreeamount, accountremark, accountremarkdate,groupid,isgroupheadline,checker)
		SELECT @CustID, ca.creditgrade, ca.installmentdate, ca.installmentamount, ca.preagreeamount, ca.accountremark, ca.accountremarkdate, ca.groupID,0,0
		FROM dbo.custAccount ca WITH (NOLOCK)
		WHERE ca.custid = @HeadlineId AND ca.IsGroupHeadLine = 1

			--Virtual rate
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT	@Custid, 
				seqNo,
				(
					SELECT TOP 1 bitmap
					FROM dbo.f_GenerateVirtualSetting_multiple(0x00, CONVERT(VARCHAR(MAX), virtualXML))
				) AS bitmapVirtual
		FROM (
			SELECT DISTINCT seqNo
			FROM ProfileVirtualSetting WITH(NOLOCK)
		) pvs
		CROSS APPLY (
			SELECT (
				SELECT	(
							SELECT	ipvs.profileID			AS '@p',
									vr.virtualMultiplier	AS '@v'
							FROM	ProfileVirtualSetting	AS ipvs WITH(NOLOCK)
							CROSS APPLY (
								SELECT CAST(1.00 AS SMALLMONEY) AS virtualMultiplier
							) vr
							WHERE	ipvs.seqNo = pvs.seqNo
							FOR XML PATH ('r'), 
							TYPE
						)
				FOR XML PATH ('root'), 
				TYPE
			) AS virtualXML
		) p	 
    END
    ELSE IF @roleid = 3
    BEGIN
	    SELECT @UplineSecurityCode = SecurityCode,
	           @isForcedChangeSecurityCode = isForcedChangeSecurityCode
	    FROM dbo.CustLoginInfo WITH(NOLOCK)
	    WHERE CustID = @srecommend

	    SET @mrecommend = @custid 
	    UPDATE Customer WITH (ROWLOCK, UPDLOCK) SET mrecommend = @custid WHERE custId = @CustID

	    INSERT INTO CustMaster(custId, DisableAutoMPT, IsInternal, TransferOption)
	    VALUES(@CustID,@DisableAutoMPT, @IsInternal, NULL)
	
		--Virtual rate
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @srecommend

		IF @SubAccID > 0
		BEGIN
			IF EXISTS (SELECT 1 FROM CustSub WITH (NOLOCK) WHERE subaccid = @SubAccID AND IsAllDownline = 0)
			BEGIN
				INSERT INTO dbo.CS_SubAccManagement (SubAccId, DownlineId)
				SELECT @SubAccID, @custid
			END
		END
    END
    ELSE IF @roleid = 2
    BEGIN
	    SELECT @UplineSecurityCode = SecurityCode,
	           @isForcedChangeSecurityCode = isForcedChangeSecurityCode
	    FROM dbo.CustLoginInfo WITH(NOLOCK)
	    WHERE CustID = @mrecommend

	    SET @recommend = @custid
	    UPDATE Customer WITH (ROWLOCK, UPDLOCK) SET recommend = @custid WHERE custId = @CustID

	    INSERT INTO CustAgent(custId, MaxCredit, IsInternal, TransferOption, Site)
	    VALUES(@CustID, @MaxCredit, @IsInternal, NULL, @site)
		
		--Virtual rate
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @mrecommend  
    END
	ELSE IF @roleid = 1
	BEGIN		
		INSERT INTO [dbo].[CustVirtualSetting] (custid, seqNo, bitmapVirtual)
		SELECT @Custid, seqNo, bitmapVirtual
		FROM CustVirtualSetting WITH(NOLOCK)
		WHERE custid = @recommend  
	END
    IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END
		     , @ErrCode = 112

	    -- ROLLBACK MANUALLY
	    IF @RoleID = 4
		    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
	    ELSE IF @RoleID = 3
		BEGIN
		    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM dbo.CS_SubAccManagement WITH(ROWLOCK) WHERE SubAccId = @SubAccID AND DownlineId = @CustID
		END
	    ELSE IF @RoleID = 2
		    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

	    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
	    RETURN
    END	

	INSERT INTO dbo.CS_CustomerStatus (CustId, InactiveInfo, SuspendedInfo, ViewOnlyInfo)
	SELECT @custid, 0, 0, 0
	      
	IF @@ERROR <> 0
    BEGIN
	    SELECT @ErrMsg = CASE @Language 
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END
		     , @ErrCode = 115

	    -- ROLLBACK MANUALLY
	    IF @RoleID = 4
		    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
	    ELSE IF @RoleID = 3
		BEGIN
		    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM dbo.CS_SubAccManagement WITH(ROWLOCK) WHERE SubAccId = @SubAccID AND DownlineId = @CustID
		END
	    ELSE IF @RoleID = 2
		    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

	    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CS_CustomerStatus WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
	    RETURN
    END	

	DECLARE @ClosedReason TINYINT 
	IF(@SystemID=1 AND @closed=1)
		SELECT @ClosedReason=1
	ELSE IF(@SystemID<>1 AND @closed=1)
		SELECT @ClosedReason=2
	ELSE 
		SELECT @ClosedReason=0

    IF @roleid BETWEEN 2 AND 4 
    BEGIN
	    IF @UplineSecurityCode IS NOT NULL OR @isForcedChangeSecurityCode = 1
		    SELECT @isForcedChangeSecurityCode = 1

	    INSERT INTO dbo.CustLoginInfo
	    (
	        CustID, OldUserPwd, LastChangedPwdDate, isFirstLogin, SecurityCodeCount,
	        SecurityCode, isForcedChangeSecurityCode, LastChangedSecurityCodeDate,ClosedReason
	    )
	    VALUES
	    (
	        @custid, NULL, GETDATE(), 1, 0,
	        NULL, @isForcedChangeSecurityCode, NULL,@ClosedReason
	    )

	    IF @@ERROR <> 0
	    BEGIN
		    SELECT	@ErrMsg = CASE @Language
								    WHEN 'E' THEN 'Create customer failed. Please try again.'
								    ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							    END
				    ,@ErrCode = 115

		    IF @RoleID = 4
			    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
		    ELSE IF @RoleID = 3
			BEGIN
				DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM dbo.CS_SubAccManagement WITH(ROWLOCK) WHERE SubAccId = @SubAccID AND DownlineId = @CustID
			END
		    ELSE IF @RoleID = 2
			    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID

		    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CS_CustomerStatus WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
			EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
		    RETURN
	    END
    END

	IF @roleid=1
	BEGIN		
		IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo_Member WITH(NOLOCK) WHERE custid = @custid)
		BEGIN
			INSERT INTO CustLoginInfo_Member([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason)
			VALUES(@custid,NULL,@IP,@creator,GETDATE(),@ClosedReason)
			IF @@ERROR <> 0
			BEGIN
				SELECT	@ErrMsg = CASE @Language
										WHEN 'E' THEN 'Create customer failed. Please try again.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
									END
						,@ErrCode = 115

				DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CS_CustomerStatus WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID
				EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
				RETURN
			END
		END
	END

    INSERT INTO [dbo].[custinfo]
    (
	    custid, currency
	  , maxpermatch, maxpermatch2, maxpermatch3, maxpermatch5, maxpermatch8, maxpermatch10, maxpermatch11
	  , maxpermatch99
	  , roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, autosuspend2, reject, credit, closed, username
	  , MatchLimit, VirtualMultiplier
	  , DisableOutright, DisableCasino, DisableNumber, maxpermatch161, MaxPerMatch99MP, MaxPerBall161
	  , danger, danger2, danger3, Abnormal
	  ,  DoubleCommLosing	 
	  , HideKeno, DisableEsports, DisableGoldDeluxe, HideGoldDeluxe, DisableSuperLive
	  , MaxPerMatch1MP,maxpermatch164)
    VALUES
    (
	    @custid, @currency
	  , NULL, NULL, NULL, NULL, NULL, NULL, NULL
	  , NULL
	  , @roleid, @srecommend, @mrecommend, @recommend, 0, @autosuspend, @autosuspend2, ISNULL(@suspended, 0), @credit, ISNULL(@closed, 0), @username
	  , @matchlimit, @virtualmultiplier
	  , @DisableOutright, 1, 1,  0, 0, 0
	  , @danger, @danger2, @danger3, @Abnormal
	  , 0, 1, 1, 1, 1, 1, NULL, NULL
    )

    IF @@ERROR <> 0
    BEGIN 
    --	DELETE customer with (ROWLOCK) where custid =  @custid
	    SELECT @ErrMsg = CASE @Language
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END,
		       @ErrCode = 113

	    -- ROLLBACK MANUALLY
	    IF @RoleID = 4
	    BEGIN
		    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
		    DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID
	    END
	    ELSE IF @RoleID = 3
	    BEGIN
		    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM dbo.CS_SubAccManagement WITH(ROWLOCK) WHERE SubAccId = @SubAccID AND DownlineId = @CustID
		    DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
	    END
	    ELSE IF @RoleID = 2
	    BEGIN
		    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID
		    DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
	    END

	    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CS_CustomerStatus WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID	
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
	    RETURN
    END
    
	IF @roleid <> 4
	BEGIN
		INSERT INTO dbo.CS_ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, MaxBet, MaxPerEvent, CreatedDate, IsReviewed, IsAbnormalMember)
		SELECT @CustId, ProblemStatus, NULL, NULL, NULL, NULL, GETDATE(), 0, 0
		FROM CS_ProblemAccount WITH (NOLOCK)
		WHERE CustId = CASE WHEN @roleid = 3 THEN @srecommend 
							WHEN @roleid = 2 THEN @mrecommend
							WHEN @roleid = 1 THEN @recommend END
	END

	IF @@ERROR <> 0
    BEGIN 
    --	DELETE customer with (ROWLOCK) where custid =  @custid
	    SELECT @ErrMsg = CASE @Language
					       WHEN 'E' THEN 'Create customer failed. Please try again.'
					       ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
					     END,
		       @ErrCode = 113

	    -- ROLLBACK MANUALLY
	    IF @RoleID = 4
	    BEGIN
		    DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
		    DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID
	    END
	    ELSE IF @RoleID = 3
	    BEGIN
		    DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM dbo.CS_SubAccManagement WITH(ROWLOCK) WHERE SubAccId = @SubAccID AND DownlineId = @CustID
		    DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
	    END
	    ELSE IF @RoleID = 2
	    BEGIN
		    DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID
		    DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
	    END
		
		DELETE FROM custinfo WITH (ROWLOCK) WHERE CustID = @CustID
	    DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CS_CustomerStatus WITH(ROWLOCK) WHERE custId = @CustID
		DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID	
		EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
	    RETURN
    END

    -- For Extra Info Direct Account, FOR CREDIT ONLY
    IF NOT EXISTS (SELECT 1 FROM Dep_CustSuper WITH (NOLOCK) WHERE custid = @srecommend)
    BEGIN
		IF @roleid = 1 
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
				AND ci.recommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
						
			IF @@ROWCOUNT <> 0
			BEGIN				
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
			
				DELETE dbo.TOControl_GlobalSetting
				WHERE CustID IN (@srecommend,@mrecommend,@recommend)
				
				DELETE dbo.TOControl_Setting
				WHERE CustID IN (@srecommend,@mrecommend,@recommend)
			END
		END
		ELSE IF @roleid = 2
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
				AND ci.mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			
			IF @@ROWCOUNT <> 0 
			BEGIN			
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
			
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 602,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0, TO_tmp.ProfileID
	            
				FROM (        
						-- Soccer 
						SELECT TOP 10 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency, f1.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 10 sporttype, MaxTurnOver,TOCurrency, f2.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f2                
						WHERE f2.site IN (@site,'') AND f2.ExchangeID IN (@currency,0) AND f2.sporttype = 99
						ORDER BY f2.site DESC, f2.ExchangeID DESC
						) AS TO_tmp
	                            
					INNER JOIN dbo.Exchange e WITH (NOLOCK) ON e.ExchangeID = TO_tmp.TOCurrency
					INNER JOIN dbo.Exchange e1 WITH (NOLOCK) ON e1.ExchangeID = @currency
				
				DELETE dbo.TOControl_GlobalSetting
				WHERE CustID IN (@srecommend,@mrecommend)
				
				DELETE dbo.TOControl_Setting
				WHERE CustID IN (@srecommend,@mrecommend)
					
			END	
				
		END	
		ELSE IF @roleid = 3
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
				AND ci.srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			
			IF @@ROWCOUNT <> 0 
			BEGIN						
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
				
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
	    
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 601,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0, TO_tmp.ProfileID
	            
				FROM (        
						-- Soccer 
						SELECT TOP 10 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency, f1.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 10 sporttype, MaxTurnOver,TOCurrency, f2.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f2                
						WHERE f2.site IN (@site,'') AND f2.ExchangeID IN (@currency,0) AND f2.sporttype = 99
						ORDER BY f2.site DESC, f2.ExchangeID DESC
						) AS TO_tmp
	                            
					INNER JOIN dbo.Exchange e WITH (NOLOCK) ON e.ExchangeID = TO_tmp.TOCurrency
					INNER JOIN dbo.Exchange e1 WITH (NOLOCK) ON e1.ExchangeID = @currency
				
				DELETE dbo.TOControl_GlobalSetting
				WHERE CustID = @srecommend
				
				DELETE dbo.TOControl_Setting
				WHERE CustID = @srecommend 
					
			END
				
		END
		ELSE IF @roleid = 4
		BEGIN
			INSERT INTO CustDirectAccount (CustID,ApprovedBy,Boss,ProcessedBy,RequestedBy, Coll_Status)
			SELECT ci.custid,'' AS ApprovedBy,'' AS Boss,'' AS ProcessedBy,'' AS RequestedBy, NULL AS Coll_Status
			FROM Customer ci WITH(NOLOCK)
			WHERE CI.custid = @custid AND ci.Custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			
			IF @@ROWCOUNT <> 0 
			BEGIN			
				EXEC dbo.Acc_CreditCollStatusInit @CustId = @custid, @UserId = @creator, @IP = @IP, @Language = @Language
			
				SELECT @NotificationInfo = '<NewDirectCustomer  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" />'
	    
				EXEC dbo.NAP_Email_NotificationInfoInsert @ActionID = 600,@NotificationInfo = @NotificationInfo, @CreateDate = @CreateDate
				
				INSERT INTO dbo.TOControl_GlobalSetting (CustID, MaxTurnOver, Sporttype, IsGroupHeadLine, ProfileID)
				SELECT @custid
						-- Since there are many kinds of currency default setting, default setting will be converted to RM before convert to orginal curency
						, CASE 
								-- currency RM in default Setting
								WHEN TO_tmp.TOCurrency = 2 THEN CONVERT(MONEY,TO_tmp.MaxTurnOver / E1.actualrate) 
								-- NOT currency RM in default Setting
								ELSE  CONVERT(MONEY,(TO_tmp.MaxTurnOver * E.actualrate)/E1.actualrate)
						END AS MaxTurnOver
						, TO_tmp.Sporttype, 0, TO_tmp.ProfileID
	            
				FROM (        
						-- Soccer 
						SELECT TOP 10 f1.sporttype, f1.MaxTurnOver,f1.TOCurrency, f1.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f1                
						WHERE f1.site IN (@site,'') AND f1.ExchangeID IN (@currency,0) AND f1.sporttype = 1        
						ORDER BY f1.site DESC, f1.ExchangeID DESC                
		                
						UNION ALL
						-- Others sport
						SELECT TOP 10 sporttype, MaxTurnOver,TOCurrency, f2.ProfileID
						FROM dbo.f_TOControl_GlobalSettingSel () f2                
						WHERE f2.site IN (@site,'') AND f2.ExchangeID IN (@currency,0) AND f2.sporttype = 99
						ORDER BY f2.site DESC, f2.ExchangeID DESC
						) AS TO_tmp
	                            
					INNER JOIN dbo.Exchange e WITH (NOLOCK) ON e.ExchangeID = TO_tmp.TOCurrency
					INNER JOIN dbo.Exchange e1 WITH (NOLOCK) ON e1.ExchangeID = @currency
			END
			
		END
		
		IF @@ERROR <> 0
		BEGIN 
		--	DELETE customer with (ROWLOCK) where custid =  @custid
			SELECT @ErrMsg = CASE @Language
							   WHEN 'E' THEN 'Create customer failed. Please try again.'
							   ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							 END,
				   @ErrCode = 113

			-- ROLLBACK MANUALLY
			IF @RoleID = 4
			BEGIN
				DELETE FROM CustSuper WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID
			END
			ELSE IF @RoleID = 3
			BEGIN
				DELETE FROM CustMaster WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM dbo.CS_SubAccManagement WITH(ROWLOCK) WHERE SubAccId = @SubAccID AND DownlineId = @CustID
				DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
			END
			ELSE IF @RoleID = 2
			BEGIN
				DELETE FROM CustAgent WITH(ROWLOCK) WHERE custId = @CustID
				DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
			END
			
			DELETE FROM CS_ProblemAccount WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custinfo WITH (ROWLOCK) WHERE CustID = @CustID
			DELETE FROM Customer WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CS_CustomerStatus WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM custInfo WITH(ROWLOCK) WHERE custId = @CustID
			DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custid = @CustID	
			EXEC DBMSG.bodb_Message.dbo.Age_MsgCustReadStatus_Del  @custid
			
			RETURN
		END
    END
END


GO
