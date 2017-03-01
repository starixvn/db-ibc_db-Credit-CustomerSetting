
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Acc_DynamicCustSetting3rd_06    Script Date: 12/9/2015 12:57:52 PM ******/
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
	Param's Explanation:
		 @SettingType: 3 - Given Comm
						5 - Charge Comm
*/
BEGIN
    SET NOCOUNT ON;
    -- check existing tables

    IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 0 RETURN


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
			@SuperID INT, @MasterID INT, @AgentID INT
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Discount_XML
	
	
	INSERT @NewDiscountTbl
	SELECT SportType,BetType,CAST(Discount AS DECIMAL(9,8)) AS Discount
	FROM OPENXML (@iDoc, '/ROOT/Discount',1) 
	WITH(SportType smallint, BetType smallint, Discount VARCHAR(15))	
	
	EXEC sp_xml_removedocument @iDoc

	IF @RoleID=4
	BEGIN
		--update super
		UPDATE main
		SET main.Discount = tmp.Discount
		FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
		JOIN @NewDiscountTbl tmp 
			ON tmp.SportType=main.SportType
				AND tmp.BetType=main.BetType
		WHERE main.CustID=@CustID
		
		--downline_master_discount = min (downline_master_discount, @NEW_DISCOUNT)
		UPDATE dcm
		SET
			dcm.Discount=CASE WHEN dcs.Discount < dcm.Discount THEN dcs.Discount ELSE dcm.Discount  END
		FROM dbo.CustDiscount3rd_Agent dcm WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcm.sporttype = fil.sporttype AND dcm.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcm.custid = ci.custid
										   AND ci.srecommend = @CustID
										   AND ci.roleid = 3
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcm.sporttype
											AND dcs.bettype = dcm.bettype
											AND dcs.custid=@CustID
		--ownline_agent_discount = min (downline_agent_discount, @NEW_DISCOUNT)									
		UPDATE dca
		SET
			dca.Discount=CASE WHEN dcs.Discount < dca.Discount THEN dcs.Discount ELSE dca.Discount  END
		FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dca.sporttype = fil.sporttype AND dca.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dca.custid = ci.custid
										   AND ci.srecommend = @CustID
										   AND ci.roleid = 2
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dca.sporttype
											AND dcs.bettype = dca.bettype
											AND dcs.custid=@CustID
		
		--downline_member_sdiscount = @NEW_DISCOUNT
		--downline_member_adiscount = min(downline_member_adiscount, downline_member_sdiscount)
		--downline_member_discount = min(downline_member_discount, downline_member_adiscount)
		--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)									
		UPDATE dcmem
		SET
			@SuperDiscount = dcs.Discount,
			@MasterDiscount = dcmem.MasterDiscount,
			@AgentDiscount = dcmem.AgentDiscount,
			@PlayerDiscount = dcmem.PlayerDiscount,			
			@MasterDiscount= CASE WHEN @MasterDiscount < @SuperDiscount THEN @MasterDiscount ELSE @SuperDiscount END,
			@AgentDiscount= CASE WHEN @AgentDiscount < @MasterDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
			@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount OR @SettingType = 5 THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
										   AND ci.srecommend = @CustID
										   AND ci.roleid = 1
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
											AND dcs.bettype = dcmem.bettype
											AND dcs.custid=@CustID
										
											
	END
	ELSE IF @RoleID=3
	BEGIN
		SELECT @SuperID = srecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		--update master
		UPDATE main
		SET main.Discount = tmp.Discount
		FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
		JOIN @NewDiscountTbl tmp 
			ON tmp.SportType=main.SportType
				AND tmp.BetType=main.BetType
		WHERE main.CustID=@CustID
				
		--downline_agent_discount = min (downline_agent_discount, @NEW_DISCOUNT)		
		UPDATE dca
		SET
			dca.Discount=CASE WHEN dcm.Discount < dca.Discount THEN dcm.Discount ELSE dca.Discount  END
		FROM dbo.CustDiscount3rd_Agent dca WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dca.sporttype = fil.sporttype AND dca.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dca.custid = ci.custid
										   AND ci.mrecommend = @CustID
										   AND ci.roleid = 2
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dca.sporttype
											AND dcm.bettype = dca.bettype
											AND dcm.custid=@CustID
											
		--downline_member_adiscount = @NEW_DISCOUNT
		--downline_member_discount = min(downline_member_discount, downline_member_adiscount)
		--downline_member_playerdiscount = min(downline_member_playerdiscount, downline_member_discount)									
		UPDATE dcmem
		SET
			@SuperDiscount = dcs.Discount,
			@MasterDiscount = dcm.Discount,
			@AgentDiscount = dcmem.AgentDiscount,
			@PlayerDiscount = dcmem.PlayerDiscount,	
			@SuperDiscount = CASE WHEN @SuperDiscount < @MasterDiscount THEN @MasterDiscount ELSE @SuperDiscount END,
			@AgentDiscount= CASE WHEN @AgentDiscount < @MasterDiscount THEN @AgentDiscount ELSE @MasterDiscount END,
			@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount OR @SettingType = 5 THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
										   AND ci.mrecommend = @CustID
										   AND ci.roleid = 1
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype
											AND dcm.bettype = dcmem.bettype
											AND dcm.custid=@CustID
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
											AND dcs.bettype = dcmem.bettype
											AND dcs.custid=@SuperID
											
	END
	ELSE IF @RoleID=2
	BEGIN
		SELECT @SuperID = srecommend, @MasterID = mrecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustId

		--update agent
		UPDATE main
		SET main.Discount = tmp.Discount
		FROM dbo.CustDiscount3rd_Agent main WITH(ROWLOCK, UPDLOCK)
		JOIN @NewDiscountTbl tmp 
			ON tmp.SportType=main.SportType
				AND tmp.BetType=main.BetType
		WHERE main.CustID=@CustID
			

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
			@PlayerDiscount= CASE WHEN @PlayerDiscount < @AgentDiscount OR @SettingType = 5 THEN @PlayerDiscount ELSE @AgentDiscount END,
			dcmem.SuperDiscount = @SuperDiscount,
			dcmem.MasterDiscount = @MasterDiscount,
			dcmem.AgentDiscount = @AgentDiscount,
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)
		INNER JOIN @NewDiscountTbl fil ON dcmem.sporttype = fil.sporttype AND dcmem.bettype = fil.bettype
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON dcmem.custid = ci.custid
										   AND ci.recommend = @CustID
										   AND ci.roleid = 1
										   AND ci.Enabled=1
		INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype
											AND dca.bettype = dcmem.bettype
											AND dca.custid=@CustID
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype
											AND dcm.bettype = dcmem.bettype
											AND dcm.custid=@MasterID
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
											AND dcs.bettype = dcmem.bettype
											AND dcs.custid=@SuperID

											
	END
	ELSE IF @RoleID=1
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
			dcmem.PlayerDiscount = @PlayerDiscount
		FROM dbo.CustDiscount3rd_Member dcmem WITH(ROWLOCK, UPDLOCK)  
			INNER JOIN @NewDiscountTbl tmp ON tmp.SportType=dcmem.SportType AND tmp.BetType=dcmem.BetType  
			INNER JOIN dbo.CustDiscount3rd_Agent dca WITH(NOLOCK) ON dca.sporttype = dcmem.sporttype
											AND dca.bettype = dcmem.bettype
											AND dca.custid=@AgentID
			INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH(NOLOCK) ON dcm.sporttype = dcmem.sporttype
												AND dcm.bettype = dcmem.bettype
												AND dcm.custid=@MasterID
			INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH(NOLOCK) ON dcs.sporttype = dcmem.sporttype
												AND dcs.bettype = dcmem.bettype
												AND dcs.custid=@SuperID
		WHERE dcmem.CustID=@CustID AND @SettingType = 3    
	END
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_DynamicCustSetting3rd_06] TO [vnteam]
GO 
