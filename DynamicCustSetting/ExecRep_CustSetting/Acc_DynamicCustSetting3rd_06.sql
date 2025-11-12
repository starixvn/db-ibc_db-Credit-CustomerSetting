/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_06]
    @CustId int,
    @RoleId int,
    @SettingType	SMALLINT		=	3,
	@Discount_XML VARCHAR(MAX) = NULL
AS
/*
    Created: 20151007@Dominic
    Task : Update commission 
    DB: DBCust/CustDB
    Revision:
		- 20151203@Dominic: Fix bug when correcting discount setting on downline members  Bug #48652, #48671    
		- 20160104@Dominic: Implementing Charge Commission Plugin - [Redmine: #49689]
		- 20160219@Dominic: Remove commission on C981RMB - [Redmine: #51057]  
		- 20160909@Winnie: Not apply CustNoComm for 3rd product [Redmine: #63736]	
		- 20170426@Elodie: Implementing Ticket Commission Plugin - [Redmine: #75221]
		- 20200615@Elodie: Implement new setting type 19 [Redmine: #135363]
		- 20220622@Elodie:  Run by batch [RedmineID: #174131]
		- 20241202@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969] 
		- 20250701@Elodie:  Tune SP [RedmineID: #231914]
	Param's Explanation:
		 @SettingType: 3 - Given Comm
						5 - Charge Comm
						14 - Ticket Comm
						19 - Given Comm

	exec Acc_CustSetting_Discount_156_Upd @ErrCode=@p1 output,@MsgType=@p2 output,@ErrMsg=@p3 output,@IP='10.15.200.10',@UserID=8,@SettingStatus=0,@Discount='[
	{
		"Discount": 0.004,
		"ProductId": 41,
		"SportType": 9911,
		"BetType": 2400,
		"IsLive": false,
		"TooltipMessage": null
	}
	]',@CustID=2690,@SubAccID=0
	select @p1, @p2, @p3
*/
BEGIN
    SET NOCOUNT ON
	
	IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
		AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
	)
	RETURN;
	
	DECLARE @BatchNo INT = 2000, @SettingRow TINYINT
	CREATE TABLE #Agent(custid INT)
	CREATE TABLE #Member(custid INT , Recommend INT)
	CREATE TABLE #AgentTmpBatch(custid INT )
	CREATE TABLE #MemberTmpBatch(custid INT , Recommend INT, sporttype SMALLINT, bettype SMALLINT, Discount DECIMAL(9,8), PRIMARY KEY (custid, sporttype, bettype))

	DECLARE @NewDiscountTbl TABLE(
		SportType SMALLINT,
		BetType SMALLINT,
		Discount Decimal(9,8)
	)
	
	IF @Discount_XML IS NULL OR @Discount_XML='' RETURN

	--Parse XML	
	DECLARE @iDoc INT
	DECLARE @SuperDiscount DECIMAL(9,8),
			@MasterDiscount DECIMAL(9,8),
			@AgentDiscount DECIMAL(9,8),
			@PlayerDiscount DECIMAL(9,8),
			@SuperID INT, @MasterID INT, @AgentID INT, @UplineID INT
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Discount_XML	
	
	INSERT @NewDiscountTbl (SportType, BetType, Discount)
	SELECT SportType,BetType,CAST(Discount AS DECIMAL(9,8)) AS Discount
	FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
	WITH(SportType smallint, BetType smallint, Discount VARCHAR(15))	
	
	EXEC sp_xml_removedocument @iDoc
	
	SELECT @SettingRow = COUNT(1) FROM @NewDiscountTbl
	IF @SettingRow = 0 RETURN

	SELECT @BatchNo = @BatchNo / @SettingRow

	DECLARE @IsDirectMember  INT = 0
		
	IF @RoleId = 4
	BEGIN
		INSERT INTO #Agent(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE srecommend = @CustId AND roleid IN (3,2) AND Enabled = 1

		INSERT INTO #Member(custid , Recommend)
		SELECT custid , c.recommend
		FROM custInfo c WITH(NOLOCK) 
		WHERE srecommend = @CustId AND roleid = 1 AND Enabled = 1	

	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT @SuperID = srecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		INSERT INTO #Agent(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE mrecommend = @CustId AND roleid = 2 AND Enabled = 1	
			
		INSERT INTO #Member(custid , Recommend)
		SELECT custid , c.recommend
		FROM custInfo c WITH(NOLOCK) 
		WHERE mrecommend = @CustId AND roleid = 1 AND Enabled = 1

	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT @SuperID = srecommend, @MasterID = mrecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		INSERT INTO #Member(custid , Recommend)
		SELECT custid , c.recommend
		FROM custInfo c WITH(NOLOCK) 
		WHERE recommend = @CustId AND roleid = 1 AND Enabled = 1
	END
	ELSE IF @RoleId = 1
	BEGIN
		-- Check Member updated is Normal or Direct
		SELECT @IsDirectMember = recommend FROM Custinfo WITH (NOLOCK) WHERE custid = @custid AND roleid = 1 AND Enabled = 1 AND recommend IN (-3,-4)
	END
	
	--Update main is member normal account
	IF @RoleID=1 AND @IsDirectMember NOT IN (-3,-4)
	BEGIN
		SELECT @SuperID = srecommend, @MasterID = mrecommend, @AgentID = recommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		UPDATE dcmem  
		SET @SuperDiscount = dcs.Discount,
			@MasterDiscount = dcm.Discount,
			@AgentDiscount = dca.Discount,
			@PlayerDiscount = tmp.Discount,	
			@SuperDiscount = CASE WHEN @SuperDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @SuperDiscount END,
			@MasterDiscount= CASE WHEN @MasterDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @MasterDiscount END,
			@AgentDiscount= CASE WHEN @AgentDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)  
			INNER JOIN @NewDiscountTbl tmp ON tmp.SportType=dcmem.SportType AND tmp.BetType=dcmem.BetType  
			INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype AND dca.bettype = dcmem.bettype AND dca.custid=@AgentID
			INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype AND dcm.bettype = dcmem.bettype AND dcm.custid=@MasterID
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@SuperID
		WHERE dcmem.CustID=@CustID AND @SettingType IN (3,19)
	END
	
	--Update main is direct account : SuperDirectMember
	ELSE IF @RoleID=1 AND @IsDirectMember = -4
	BEGIN
		SELECT @SuperID = srecommend, @MasterID = mrecommend, @AgentID = recommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		UPDATE dcmem  
		SET   @SuperDiscount = dcs.Discount,
			@PlayerDiscount = tmp.Discount,	
			@SuperDiscount = CASE WHEN @SuperDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @SuperDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount,
			dcmem.AgentDiscount  = @PlayerDiscount,
			dcmem.MasterDiscount = @PlayerDiscount,
			dcmem.RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)  
			INNER JOIN @NewDiscountTbl tmp ON tmp.SportType=dcmem.SportType AND tmp.BetType=dcmem.BetType  
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@SuperID
		WHERE dcmem.CustID=@CustID AND @SettingType IN (3,19)
	END
	
	--Update main is direct account : MasterDirectMember
	ELSE IF @RoleID=1 AND @IsDirectMember = -3
	BEGIN
		SELECT @SuperID = srecommend, @MasterID = mrecommend, @AgentID = recommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		UPDATE dcmem  
		SET   @SuperDiscount = dcs.Discount,
			@MasterDiscount = dcm.Discount,
			@PlayerDiscount = tmp.Discount,	
			@SuperDiscount = CASE WHEN @SuperDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @SuperDiscount END,
			@MasterDiscount= CASE WHEN @MasterDiscount < @PlayerDiscount THEN @PlayerDiscount ELSE @MasterDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount,
			dcmem.AgentDiscount = @PlayerDiscount,
			dcmem.RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)  
			INNER JOIN @NewDiscountTbl tmp ON tmp.SportType=dcmem.SportType AND tmp.BetType=dcmem.BetType  
			INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype AND dcm.bettype = dcmem.bettype AND dcm.custid=@MasterID
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@SuperID
		WHERE dcmem.CustID=@CustID AND @SettingType IN (3,19)
	END

	-- Update main is Super or Master or Agent
	ELSE IF @roleid IN (2,3,4)
	BEGIN
		UPDATE main
		SET main.Discount = tmp.Discount,
			main.RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
			INNER JOIN @NewDiscountTbl tmp ON tmp.SportType=main.SportType AND tmp.BetType=main.BetType
		WHERE main.CustID=@CustID
	END

	--Adjust master, agent
	IF @RoleID IN (4,3)
	BEGIN	
		--downline_master_discount = min (downline_master_discount, @NEW_DISCOUNT)
		--downline_agent_discount = min (downline_agent_discount, @NEW_DISCOUNT)		
		WHILE 1 = 1
		BEGIN
			TRUNCATE TABLE #AgentTmpBatch
			DELETE TOP (@BatchNo) a
			OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
			FROM #Agent a

			IF @@ROWCOUNT = 0 
				BREAK

			UPDATE dca
			SET
				dca.Discount=CASE WHEN dcu.Discount < dca.Discount THEN dcu.Discount ELSE dca.Discount  END,
				dca.RepUpdateTime = dbo.f_GetDateTime2()
			FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
				INNER JOIN @NewDiscountTbl fil ON dca.sporttype = fil.sporttype AND dca.bettype = fil.bettype
				INNER JOIN #AgentTmpBatch ci WITH(NOLOCK) ON dca.custid = ci.custid
				INNER JOIN dbo.CustDiscount3rd_Agent dcu WITH(NOLOCK) ON dcu.sporttype = dca.sporttype AND dcu.bettype = dca.bettype AND dcu.custid=@CustID
		END
	END

	--Adjust member
	WHILE 1 = 1
	BEGIN
		TRUNCATE TABLE #MemberTmpBatch
		DELETE TOP (@BatchNo) a
		OUTPUT deleted.custid ,DELETED.Recommend, fil.sporttype, fil.bettype, fil.Discount 
		INTO #MemberTmpBatch(custid ,Recommend, sporttype, bettype, Discount)
		FROM #Member a
			CROSS JOIN @NewDiscountTbl fil

		IF @@ROWCOUNT = 0 
			BREAK

		IF @RoleId = 4 
		BEGIN
			--downline_member_sdiscount = @NEW_DISCOUNT
			--downline_member_adiscount = min(downline_member_adiscount, downline_member_sdiscount)
			--downline_member_discount = min(downline_member_discount, downline_member_adiscount)
			--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)			
			
			--Adjust Normal member:			
			UPDATE dcmem
			SET
				@SuperDiscount = dcs.Discount,
				@MasterDiscount = dcmem.MasterDiscount,
				@AgentDiscount = dcmem.AgentDiscount,
				@PlayerDiscount = dcmem.PlayerDiscount,			
				@MasterDiscount= CASE WHEN @MasterDiscount < @SuperDiscount THEN @MasterDiscount ELSE @SuperDiscount END,
				@AgentDiscount= CASE WHEN @AgentDiscount < @MasterDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
				@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount OR @SettingType IN (5,14) THEN @PlayerDiscount ELSE @AgentDiscount END,
				dcmem.SuperDiscount = @SuperDiscount,
				dcmem.MasterDiscount = @MasterDiscount,
				dcmem.AgentDiscount = @AgentDiscount,
				dcmem.PlayerDiscount = @PlayerDiscount,
				dcmem.RepUpdateTime = dbo.f_GetDateTime2()
			FROM #MemberTmpBatch ci 
				INNER JOIN dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK) ON dcmem.custid = ci.custid AND dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
				INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@CustID
		END
		ELSE IF @RoleID = 3
		BEGIN
			--downline_member_adiscount = @NEW_DISCOUNT
			--downline_member_discount = min(downline_member_discount, downline_member_adiscount)
			--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)									
			
			-- Update Normal Member
			UPDATE dcmem
			SET
				@SuperDiscount = dcs.Discount,
				@MasterDiscount = dcm.Discount,
				@AgentDiscount = dcmem.AgentDiscount,
				@PlayerDiscount = dcmem.PlayerDiscount,	
				@SuperDiscount = CASE WHEN @SuperDiscount < @MasterDiscount THEN @MasterDiscount ELSE @SuperDiscount END,
				@AgentDiscount= CASE WHEN @AgentDiscount < @MasterDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
				@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount OR @SettingType IN (5,14) THEN @PlayerDiscount ELSE @AgentDiscount END,
				dcmem.SuperDiscount = @SuperDiscount,
				dcmem.MasterDiscount = @MasterDiscount,
				dcmem.AgentDiscount = @AgentDiscount,
				dcmem.PlayerDiscount = @PlayerDiscount,
				dcmem.RepUpdateTime = dbo.f_GetDateTime2()
			FROM #MemberTmpBatch ci 
				INNER JOIN dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK) ON dcmem.custid = ci.custid AND dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
				INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype AND dcm.bettype = dcmem.bettype AND dcm.custid=@CustID
				INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@SuperID
		END
		ELSE IF @RoleID = 2
		BEGIN
			--downline_member_discount = @NEW_DISCOUNT
			--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)
			UPDATE dcmem
			SET
				@SuperDiscount = dcs.Discount,
				@MasterDiscount = dcm.Discount,
				@AgentDiscount = dca.Discount,
				@PlayerDiscount = dcmem.PlayerDiscount,	
				@SuperDiscount = CASE WHEN @SuperDiscount < @AgentDiscount THEN @AgentDiscount ELSE @SuperDiscount END,
				@MasterDiscount= CASE WHEN @MasterDiscount < @AgentDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
				@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount OR @SettingType IN (5,14) THEN @PlayerDiscount ELSE @AgentDiscount END,
				dcmem.SuperDiscount = @SuperDiscount,
				dcmem.MasterDiscount = @MasterDiscount,
				dcmem.AgentDiscount = @AgentDiscount,
				dcmem.PlayerDiscount = @PlayerDiscount,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM #MemberTmpBatch ci 
				INNER JOIN dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK) ON dcmem.custid = ci.custid AND dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
				INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype AND dca.bettype = dcmem.bettype AND dca.custid=@CustID
				INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype AND dcm.bettype = dcmem.bettype AND dcm.custid=@MasterID
				INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype AND dcs.bettype = dcmem.bettype AND dcs.custid=@SuperID
		END
	END
END
GO

