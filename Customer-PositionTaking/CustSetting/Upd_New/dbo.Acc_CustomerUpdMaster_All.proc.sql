ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_All]
    @custid int,-- masterid    
    @disCasino bit = 0,    
    @firstname nvarchar(50),
    @lastname nvarchar(50),
    @phone nvarchar(50),    
    @mobilephone nvarchar(50),
    @email nvarchar(50) = NULL,
    @fax nvarchar(50),
    @closed bit,
    @Suspended bit,
    @srecommend int,--superid


    @minbet money,
    @maxbet money,
    @maxpermatch money,
    
    @minbetv2 money,
    @maxbetv2 money,
    @maxpermatchv2 money,
    
    @minbetv3 money,
    @maxbetv3 money,
    @maxpermatchv3 money,
    
    @minbetv5 money,
    @maxbetv5 money,
    @maxpermatchv5 money,
    
    @minbetv8 money,
    @maxbetv8 money,
    @maxpermatchv8 money,
    
    @minbetv10 money,
    @maxbetv10 money,
    @maxpermatchv10 money,
    
    @minbetv11 money,
    @maxbetv11 money,
    @maxpermatchv11 money,

    @minbetv99 money,
    @maxbetv99 money,
    @maxpermatchv99 money,

    -- mixed sports
    @minbetv99mp money = 0,
    @maxbetv99mp money = 0,
    @maxpermatchv99mp money = 0,
    
    -- parlay soccer sports
    @minbetv1mp money = 0,
    @maxbetv1mp money = 0,
    @maxpermatchv1mp money = 0,
    
    --HR Fixed Odds
    @MinBetv154 MONEY = 0,
    @MaxBetv154 MONEY = 0 ,
    @MaxPerMatchv154 MONEY = 0,
    
    -- number game
    @minbetv161 money,
    @maxbetv161 money,
    @maxpermatchv161 money,
    @maxperballv161 money,

    @credit money,
    @Language varchar(2),
    @UpdateMultiple bit = 0,
    @spositiontaking_1 smallmoney,
    @spositiontaking_2 smallmoney,
    @spositiontaking_3 smallmoney,
    @spositiontaking_4 smallmoney,
    @spositiontaking_5 smallmoney,
    @spositiontaking_6 smallmoney,
    @spositiontaking_7 smallmoney,
    @spositiontaking_8 smallmoney,
    @spositiontaking_9 smallmoney,
    @spositiontaking_10 smallmoney,
    @spositiontaking_9999 smallmoney = 0,
    @slivepositiontaking_1 smallmoney,
    @slivepositiontaking_3 smallmoney,
    @slivepositiontaking_7 smallmoney,
    @slivepositiontaking_8 smallmoney,
    
    @v2spositiontaking_1 smallmoney,
    @v2spositiontaking_2 smallmoney,
    @v2spositiontaking_3 smallmoney,
    @v2spositiontaking_7 smallmoney,
    @v2spositiontaking_8 smallmoney,
--    @v2spositiontaking_9 smallmoney,
    @v2spositiontaking_20 smallmoney,
    
    @v3spositiontaking_1 smallmoney,
    @v3spositiontaking_2 smallmoney,
    @v3spositiontaking_3 smallmoney,    
    @v3spositiontaking_20 smallmoney,
    
    @v5spositiontaking_1 smallmoney,
    @v5spositiontaking_2 smallmoney,
    @v5spositiontaking_3 smallmoney,    
    @v5spositiontaking_20 smallmoney,
    @v5spositiontaking_9999 smallmoney = 0,    
    
    @v8spositiontaking_1 smallmoney,
    @v8spositiontaking_3 smallmoney,    
    @v8spositiontaking_20 smallmoney,
    
    @v10spositiontaking_1 smallmoney,
    @v10spositiontaking_2 smallmoney,
    @v10spositiontaking_3 smallmoney,    
    @v10spositiontaking_20 smallmoney,
    
    @v11spositiontaking_1 smallmoney,
    @v11spositiontaking_20 smallmoney,
    
    @v99spositiontaking_1 smallmoney,
    @v99spositiontaking_2 smallmoney,
    @v99spositiontaking_3 smallmoney,    
    @v99spositiontaking_20 smallmoney,
    
    -- mixed sports
    @v99spositiontaking_9 smallmoney = 0,    

    -- HR fixOdds
    @v154spositiontaking_20 smallmoney = 0,    
    
    -- number game
    @v161spositiontaking_81 smallmoney,
    @v161spositiontaking_83 smallmoney,    
    @v161spositiontaking_86 smallmoney,
    @v161spositiontaking_88 smallmoney = 0,    
    @v161slivepositiontaking_85 smallmoney,
    @v161slivepositiontaking_86 smallmoney,
    @v161slivepositiontaking_87 smallmoney,
    @v161slivepositiontaking_89 smallmoney = 0,
    @v161slivepositiontaking_90 smallmoney = 0,
    
    

    @groupa decimal(9,8),
    @groupb decimal(9,8),
    @groupc decimal(9,8),
    @groupd decimal(9,8),
    @discountcs decimal(9,8),
    @discount1x2 decimal(9,8)=0, --1x2    
    @discountnumber decimal(9,8) = 0,
    @discountHRFixedOdds DECIMAL(9,8)=0,
    
    @discountMyanmarOdds DECIMAL(9,8)=0, -- MyanmarOdds
    
    @UpdateCommission bit = 1,
    
    @UpdateMinMaxBet bit = 1,
    @UpdateMinMaxBetv2 bit = 1,
    @UpdateMinMaxBetv3 bit = 1,
    @UpdateMinMaxBetv5 bit = 1,
    @UpdateMinMaxBetv8 bit = 1,
    @UpdateMinMaxBetv10 bit = 1,
    @UpdateMinMaxBetv11 bit = 1,
    @UpdateMinMaxBetv99 bit = 1,
    
    -- new setting
    @UpdateMinMaxBetv99MP bit = 1,
    
    @UpdateMinMaxBetv1MP bit = 1,
    
    @UpdateMinMaxBetv154 bit = 1,
    @UpdateMinMaxBetv161 bit = 1,

    @UpdatePositiontaking bit = 1,
    @UpdatePositiontakingv2 bit = 1,
    @UpdatePositiontakingv3 bit = 1,
    @UpdatePositiontakingv5 bit = 1,
    @UpdatePositiontakingv8 bit = 1,
    @UpdatePositiontakingv10 bit = 1,
    @UpdatePositiontakingv11 bit = 1,
    @UpdatePositiontakingv99 bit = 1,

    @UpdatePositiontakingv99MP bit = 1,
    
    @UpdatePositiontakingv154 bit = 1,
    @UpdatePositiontakingv161 bit = 1,

    @UpdateClosed bit = 1,
    @UpdateSuspended BIT = 1,

    @auto_spositiontaking_1 smallmoney = 0,
    @auto_spositiontaking_2 smallmoney = 0,
    @auto_spositiontaking_3 smallmoney = 0,
    @auto_spositiontaking_4 smallmoney = 0,
    @auto_spositiontaking_5 smallmoney= 0,
    @auto_spositiontaking_6 smallmoney = 0,
    @auto_spositiontaking_7 smallmoney = 0,
    @auto_spositiontaking_8 smallmoney = 0,
    @auto_spositiontaking_9 smallmoney = 0,
    @auto_spositiontaking_10 smallmoney = 0,
    @auto_spositiontaking_9999 smallmoney = 0,
    @auto_slivepositiontaking_1 smallmoney = 0,
    @auto_slivepositiontaking_3 smallmoney = 0,
    @auto_slivepositiontaking_7 smallmoney = 0,
    @auto_slivepositiontaking_8 smallmoney = 0,
    
    @auto_v2spositiontaking_1 smallmoney = 0,
    @auto_v2spositiontaking_2 smallmoney = 0,
    @auto_v2spositiontaking_3 smallmoney = 0,
    @auto_v2spositiontaking_7 smallmoney = 0,
    @auto_v2spositiontaking_8 smallmoney = 0,
--    @auto_v2spositiontaking_9 smallmoney = 0,
    @auto_v2spositiontaking_20 smallmoney = 0,
    
    @auto_v3spositiontaking_1 smallmoney = 0,
    @auto_v3spositiontaking_2 smallmoney = 0,
    @auto_v3spositiontaking_3 smallmoney = 0,
    @auto_v3spositiontaking_20 smallmoney = 0,
    
    @auto_v5spositiontaking_1 smallmoney = 0,
    @auto_v5spositiontaking_2 smallmoney = 0,
    @auto_v5spositiontaking_3 smallmoney = 0,
    @auto_v5spositiontaking_20 smallmoney = 0,
    @auto_v5spositiontaking_9999 smallmoney = 0,
    
    @auto_v8spositiontaking_1 smallmoney = 0,
    @auto_v8spositiontaking_3 smallmoney = 0,
    @auto_v8spositiontaking_20 smallmoney = 0,
    
    @auto_v10spositiontaking_1 smallmoney = 0,
    @auto_v10spositiontaking_2 smallmoney = 0,
    @auto_v10spositiontaking_3 smallmoney = 0,
    @auto_v10spositiontaking_20 smallmoney = 0,
    
    @auto_v11spositiontaking_1 smallmoney = 0,
    @auto_v11spositiontaking_20 smallmoney = 0,

    @auto_v99spositiontaking_1 smallmoney = 0,
    @auto_v99spositiontaking_2 smallmoney = 0,
    @auto_v99spositiontaking_3 smallmoney = 0,
    @auto_v99spositiontaking_20 smallmoney = 0,
    
    -- mixed sports
    @auto_v99spositiontaking_9 smallmoney = 0,
    
    -- HR fixodds
    @auto_v154spositiontaking_20 smallmoney = 0,
    
    -- number game
    @auto_v161spositiontaking_81 smallmoney = 0,
    @auto_v161spositiontaking_83 smallmoney = 0,    
    @auto_v161spositiontaking_86 smallmoney = 0,
    @auto_v161spositiontaking_88 smallmoney = 0,
    
    @auto_v161slivepositiontaking_85 smallmoney = 0,
    @auto_v161slivepositiontaking_86 smallmoney = 0,
    @auto_v161slivepositiontaking_87 smallmoney = 0,
    @auto_v161slivepositiontaking_89 smallmoney = 0,
    @auto_v161slivepositiontaking_90 smallmoney = 0,

    @updateallmembers bit = 0,
    @newspositiontaking smallmoney = 0,--equals max(s+m) - chosen(m)
    
    @isauto_spositiontaking_1 bit = 0,
    @isauto_spositiontaking_2 bit = 0,
    @isauto_spositiontaking_3 bit = 0,
    @isauto_spositiontaking_4 bit = 0,
    @isauto_spositiontaking_5 bit= 0,
    @isauto_spositiontaking_6 bit = 0,
    @isauto_spositiontaking_7 bit = 0,
    @isauto_spositiontaking_8 bit = 0,
    @isauto_spositiontaking_9 bit = 0,
    @isauto_spositiontaking_10 bit = 0,
    @isauto_spositiontaking_9999 bit = 0,
    @isauto_slivepositiontaking_1 bit = 0,
    @isauto_slivepositiontaking_3 bit = 0,
    @isauto_slivepositiontaking_7 bit = 0,
    @isauto_slivepositiontaking_8 bit = 0,
    
    @isauto_v2spositiontaking_1 bit = 0,
    @isauto_v2spositiontaking_2 bit = 0,
    @isauto_v2spositiontaking_3 bit = 0,
    @isauto_v2spositiontaking_7 bit = 0,
    @isauto_v2spositiontaking_8 bit = 0,
--    @isauto_v2spositiontaking_9 bit = 0,
    @isauto_v2spositiontaking_20 bit = 0,
    
    @isauto_v3spositiontaking_1 bit = 0,
    @isauto_v3spositiontaking_2 bit = 0,
    @isauto_v3spositiontaking_3 bit = 0,
    @isauto_v3spositiontaking_20 bit = 0,
    
    @isauto_v5spositiontaking_1 bit = 0,
    @isauto_v5spositiontaking_2 bit = 0,
    @isauto_v5spositiontaking_3 bit = 0,
    @isauto_v5spositiontaking_20 bit = 0,
    @isauto_v5spositiontaking_9999 bit = 0,
    
    @isauto_v8spositiontaking_1 bit = 0,
    @isauto_v8spositiontaking_3 bit = 0,
    @isauto_v8spositiontaking_20 bit = 0,
    
    @isauto_v10spositiontaking_1 bit = 0,
    @isauto_v10spositiontaking_2 bit = 0,
    @isauto_v10spositiontaking_3 bit = 0,
    @isauto_v10spositiontaking_20 bit = 0,
    
    @isauto_v11spositiontaking_1 bit = 0,
    @isauto_v11spositiontaking_20 bit = 0,
    
    @isauto_v99spositiontaking_1 bit = 0,
    @isauto_v99spositiontaking_2 bit = 0,
    @isauto_v99spositiontaking_3 bit = 0,
    @isauto_v99spositiontaking_20 bit = 0,

    -- mixed sports
    @isauto_v99spositiontaking_9 bit = 0,
    
    -- HR fixodds
    @isauto_v154spositiontaking_20 bit = 0,

    -- number game
    @isauto_v161spositiontaking_81 bit = 0,
    @isauto_v161spositiontaking_83 bit = 0,    
    @isauto_v161spositiontaking_86 bit = 0,
    @isauto_v161spositiontaking_88 bit = 0,
    
    @isauto_v161slivepositiontaking_85 bit = 0,
    @isauto_v161slivepositiontaking_86 bit = 0,
    @isauto_v161slivepositiontaking_87 bit = 0,
    @isauto_v161slivepositiontaking_89 bit = 0,
    @isauto_v161slivepositiontaking_90 bit = 0,
    
    @SubAccID int = 0, --Sub-AccountID
    @mpositiontaking_1 smallmoney = 0.7,
    @mpositiontaking_2 smallmoney = 0.7,
    @mpositiontaking_3 smallmoney = 0.7,
    @mpositiontaking_4 smallmoney = 0.7,
    @mpositiontaking_5 smallmoney = 0.7,
    @mpositiontaking_6 smallmoney = 0.7,
    @mpositiontaking_7 smallmoney = 0.7,
    @mpositiontaking_8 smallmoney = 0.7,
    @mpositiontaking_9 smallmoney = 0.7,
    @mpositiontaking_10 smallmoney = 0.7,
    @mpositiontaking_9999 smallmoney = 0,
    @mlivepositiontaking_1 smallmoney = 0.7,
    @mlivepositiontaking_3 smallmoney = 0.7,
    @mlivepositiontaking_7 smallmoney = 0.7,
    @mlivepositiontaking_8 smallmoney = 0.7,
    
    @v2mpositiontaking_1 smallmoney = 0.7,
    @v2mpositiontaking_2 smallmoney = 0.7,
    @v2mpositiontaking_3 smallmoney = 0.7,
    @v2mpositiontaking_7 smallmoney = 0.7,
    @v2mpositiontaking_8 smallmoney = 0.7,
--    @v2mpositiontaking_9 smallmoney = 0.7,
    @v2mpositiontaking_20 smallmoney = 0.7,
    
    @v3mpositiontaking_1 smallmoney = 0.7,
    @v3mpositiontaking_2 smallmoney = 0.7,
    @v3mpositiontaking_3 smallmoney = 0.7,
    @v3mpositiontaking_20 smallmoney = 0.7,
    
    @v5mpositiontaking_1 smallmoney = 0.7,
    @v5mpositiontaking_2 smallmoney = 0.7,
    @v5mpositiontaking_3 smallmoney = 0.7,
    @v5mpositiontaking_20 smallmoney = 0.7,
    @v5mpositiontaking_9999 smallmoney = 0,
    
    @v8mpositiontaking_1 smallmoney = 0.7,
    @v8mpositiontaking_3 smallmoney = 0.7,
    @v8mpositiontaking_20 smallmoney = 0.7,
    
    @v10mpositiontaking_1 smallmoney = 0.7,
    @v10mpositiontaking_2 smallmoney = 0.7,
    @v10mpositiontaking_3 smallmoney = 0.7,
    @v10mpositiontaking_20 smallmoney = 0.7,
    
    @v11mpositiontaking_1 smallmoney = 0.7,
    @v11mpositiontaking_20 smallmoney = 0.7,

    @v99mpositiontaking_1 smallmoney = 0.7,
    @v99mpositiontaking_2 smallmoney = 0.7,
    @v99mpositiontaking_3 smallmoney = 0.7,
    @v99mpositiontaking_20 smallmoney = 0.7,
    
    -- mixed sports
    @v99mpositiontaking_9 smallmoney = 0.7,
    
    -- HR fixodds
    @v154mpositiontaking_20 smallmoney = 0,
    
    -- number game
    @v161mpositiontaking_81 smallmoney = 0.7,
    @v161mpositiontaking_83 smallmoney = 0.7,    
    @v161mpositiontaking_86 smallmoney = 0.7,
    @v161mpositiontaking_88 smallmoney = 0.7,
    
    @v161mlivepositiontaking_85 smallmoney = 0.7,
    @v161mlivepositiontaking_86 smallmoney = 0.7,
    @v161mlivepositiontaking_87 smallmoney = 0.7,
    @v161mlivepositiontaking_89 smallmoney = 0.7,
    @v161mlivepositiontaking_90 smallmoney = 0.7,
	
	-- Outright PT for Sports	
	@v2spositiontaking_10 smallmoney,
	@v3spositiontaking_10 smallmoney,
	@v5spositiontaking_10 smallmoney,
	@v8spositiontaking_10 smallmoney,
	@v10spositiontaking_10 smallmoney,
	@v11spositiontaking_10 smallmoney,
	@v99spositiontaking_10 smallmoney,
	
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
	
	@isauto_v2spositiontaking_10 bit = 0,
	@isauto_v3spositiontaking_10 bit = 0,
	@isauto_v5spositiontaking_10 bit = 0,
	@isauto_v8spositiontaking_10 bit = 0,
	@isauto_v10spositiontaking_10 bit = 0,
	@isauto_v11spositiontaking_10 bit = 0,
	@isauto_v99spositiontaking_10 bit = 0,
	
	@v2mpositiontaking_10 smallmoney = 0.7,
	@v3mpositiontaking_10 smallmoney = 0.7,
	@v5mpositiontaking_10 smallmoney = 0.7,
	@v8mpositiontaking_10 smallmoney = 0.7,
	@v10mpositiontaking_10 smallmoney = 0.7,
	@v11mpositiontaking_10 smallmoney = 0.7,
	@v99mpositiontaking_10 smallmoney = 0.7,

    @IP varchar(15) = '',
    @UserID int,
    @Username varchar(30) = '' OUTPUT,
    @ErrCode varchar(300) = '' OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
as

--@Source Control
/*
Created: 20080514@Thien
Task : Update master
DB: DBTXN/bodb02
Original: Acc_CustomerUpdEditCustomer_SAg

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3, hard code copy min/max/maxperbet/PT for 201 from 2 sporttype 
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090317@Phuc: update Financial.
    - 20090320@PhuongDao: Change the param @IsUpdDownlineFI to @DisableDownlineFI
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090430@Kiwi: Add checking IF @UpdateSuspended = 1 for updating multiple customer
    - 20090514@PhuongDao: Add 1x2 Commission
    - 20090801@Shifu: check disabled user
    - 20091125@Terry: Check disable casino
    - 20100903@Lukas:    - Add Number game setting
                        - Add Mixed sports setting
                        - Remove mix parlay of basketball setting
    - 20101027@Lukas: Add max per ball (number game)
    - 20110729@Lukas: 
                - Add three new bettype: Warrior, Next combo, Number Group
                - Remove Dead Ball Over/Under
    - 20110831@Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
    - 20110709@Johnson: Change to use new server BD053 instead DB052
    - 20120704@Johnson: Remove setting hard code of number group
    - 20130218@Dan: Change linked server DB053 to DBAGE
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20140623@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160310@Winnie: Fix bug #53736[Edit SB: Email is cleared when updating without any change in Edit SB page]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	-- ***Check Downline Belonging***
	declare @roleid tinyint, @ErrCode_Cur int, @ErrMsg_Cur nvarchar(4000)
	Select @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	EXEC  Age_CustomerSelCheckBelongingByCustID
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@Username = @Username OUTPUT,
		@roleid = @roleid OUTPUT
		if (@roleid = 0) return

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	--end
	----------------------------------------------

	----------------------------------------------
	--Update Info
	IF @UpdateMultiple = 0
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		EXEC dbo.Acc_CustomerUpdUserInfo
					@CustID = @CustID,
					@firstname = @firstname,
					@lastname = @lastname,
					@phone = @phone,
					@mobilephone = @mobilephone,
					@fax = @fax,
					@email = @email,
					@SubAccID = @SubAccID,
					@disCasino = @disCasino,                
					@UserID = @UserID,
					@ErrMsg = @ErrMsg_Cur OUTPUT,
					@ErrCode = @ErrCode_Cur OUTPUT,
					@IP = @IP            
	    
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	        
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-101'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END

	----------------------------------------------
	--Update Closed
	if @UpdateClosed = 1
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		EXEC dbo.Acc_CustomerUpdClosed
					@CustID = @CustID,
					@Closed = @Closed,
					@disCasino = @disCasino,                
					@SubAccID = @SubAccID,
					@UserID = @UserID,
					@Language = @Language,
					@ErrCode = @ErrCode_Cur OUTPUT,
					@ErrMsg = @ErrMsg_Cur OUTPUT,
					@IP = @IP
	                
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	        
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-102'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END


	---------------------------------------------
	---update suspended
	IF @UpdateSuspended = 1
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		EXEC Acc_CustomerUpdSuspended
					@CustID =@CustID,
					@Suspended =@Suspended,    
					@disCasino = @disCasino,                
					@SubAccID =@SubAccID , 
					@UserID =@UserID,
					@Language =@Language,
					@ErrCode =@ErrCode_Cur OUTPUT,
					@ErrMsg =@ErrMsg_Cur OUTPUT,
					@IP =@IP
	                
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	        
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
	----------------------------------------------
	--Update credit
	IF @UpdateMultiple = 0
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		EXEC dbo.Acc_CustomerUpdCredit 
			@custid = @custid,
			@NewCredit = @Credit,
			@SubAccID = @SubAccID,
			@UserID = @UserID,
			@Language = @Language,
			@ErrMsg = @ErrMsg_Cur OUTPUT,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@IP = @IP
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-104'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END

	----------------------------------------------
	--Update Commission
	if @UpdateCommission=1 
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		Declare @updatecomm_old bit
		Declare @groupa_old decimal(9,8),
			@groupb_old decimal(9,8),
			@groupc_old decimal(9,8),
			@groupd_old decimal(9,8),
			@discountcs_old decimal(9,8),
			@discount1x2_old decimal(9,8),
			@discountnumber_old decimal(9,8),
			@discountHRFixedOdds_old decimal(9,8),
			@discountMyanmarOdds_old DECIMAL(9,8)

		select @groupa_old = groupa, @groupb_old = groupb, @groupc_old = groupc, @groupd_old = groupd
		from custsetting (nolock) where custid = @custid and sporttype = 1 and bettype = 1

		select @discountcs_old = adiscount
		from custsetting (nolock) where custid = @custid and sporttype = 1 and bettype = 4

		select @discount1x2_old = adiscount
		from custsetting (nolock) where custid = @custid and sporttype = 1 and bettype = 5
	    
		--v154
		select @discountHRFixedOdds_old = adiscount
		from custsetting (nolock) where custid = @custid and sporttype = 154 and bettype = 20

		---
		select @discountnumber_old = adiscount
		from custsetting3rd with(nolock) where custid = @custid and sporttype = 161 and bettype = 81

		
		-- For Myanmar Odds
		DECLARE @IsMyanmarOdds BIT = 0
		SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@custid)
	
		IF @IsMyanmarOdds = 1
		BEGIN
			-- Get old value
			SET @discountMyanmarOdds_old = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @custid AND Sporttype = 1 AND Bettype = 301)
		END
		
		
		if (@groupa_old <> @groupa) or (@groupb_old <> @groupb) or (@groupc_old <> @groupc) or (@groupd_old <> @groupd)
			or (@discountcs_old <> @discountcs) or (@discount1x2_old <> @discount1x2) or (@discountHRFixedOdds_old <> @discountHRFixedOdds) or (@discountnumber_old <> @discountnumber)
			or (@IsMyanmarOdds = 1 AND @discountMyanmarOdds <> @discountMyanmarOdds_old)
			set @updatecomm_old = 1
		else 
			set @updatecomm_old = 0
	    
		if @updatecomm_old <> 0
		begin
	        
			EXEC dbo.Acc_CustomerUpdMaster_Commission
				@custid = @custid,
				@groupa = @groupa,
				@groupb = @groupb,
				@groupc = @groupc,
				@groupd = @groupd,
				@discountcs = @discountcs,
				@discount1x2 = @discount1x2,
				@discountnumber = @discountnumber,
				@discountHRFixedOdds =@discountHRFixedOdds,

				-- For Myanmar Odds
				@IsMyanmarOdds = @IsMyanmarOdds,
				@discountMyanmarOdds = @discountMyanmarOdds,
				@discountMyanmarOdds_old = @discountMyanmarOdds_old,

				@updatecomm_old = @updatecomm_old,
				@SubAccID = @SubAccID,
				@UserID = @UserID,
				@Language = @Language,
				@IP = @IP,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		end
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-105'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END

	----------------------------------------------
	--Update MinBet, MaxBet, MaxPerMatch
	if     @UpdateMinMaxBet  = 1 or
		@UpdateMinMaxBetv2  = 1 or
		@UpdateMinMaxBetv3  = 1 or
		@UpdateMinMaxBetv5  = 1 or
		@UpdateMinMaxBetv8  = 1 or
		@UpdateMinMaxBetv10  = 1 or
		@UpdateMinMaxBetv11  = 1 or
		@UpdateMinMaxBetv99  = 1 or
		@UpdateMinMaxBetv99MP = 1 or
		@UpdateMinMaxBetv1MP = 1 or
		@UpdateMinMaxBetv154  = 1 or
		@UpdateMinMaxBetv161 = 1
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		EXEC dbo.Acc_CustomerUpdMaster_MinMaxBet
			@custid = @custid,
			@minbet = @minbet,
			@maxbet = @maxbet,
			@maxpermatch = @maxpermatch,
			@minbetv2 = @minbetv2,
			@maxbetv2 = @maxbetv2,
			@maxpermatchv2 = @maxpermatchv2,
			@minbetv3 = @minbetv3,
			@maxbetv3 = @maxbetv3,
			@maxpermatchv3 = @maxpermatchv3,
			@minbetv5 = @minbetv5,
			@maxbetv5 = @maxbetv5,
			@maxpermatchv5 = @maxpermatchv5,
			@minbetv8 = @minbetv8,
			@maxbetv8 = @maxbetv8,
			@maxpermatchv8 = @maxpermatchv8,
			@minbetv10 = @minbetv10,
			@maxbetv10 = @maxbetv10,
			@maxpermatchv10 = @maxpermatchv10,
			@minbetv11 = @minbetv11,
			@maxbetv11 = @maxbetv11,
			@maxpermatchv11 = @maxpermatchv11,
			@minbetv99 = @minbetv99,
			@maxbetv99 = @maxbetv99,
			@maxpermatchv99 = @maxpermatchv99,
	    
			--- mixed sports
			@minbetv99mp = @minbetv99mp,
			@maxbetv99mp = @maxbetv99mp,
			@maxpermatchv99mp = @maxpermatchv99mp,
	        
	        --- parlay soccer sports
			@minbetv1mp = @minbetv1mp,
			@maxbetv1mp = @maxbetv1mp,
			@maxpermatchv1mp = @maxpermatchv1mp,
			
			@MinBetv154 = @MinBetv154,
			@MaxBetv154 = @MaxBetv154,
			@MaxPerMatchv154 = @MaxPerMatchv154,
	        
			-- number game
			@minbetv161 = @minbetv161,
			@maxbetv161 = @maxbetv161,
			@maxpermatchv161 = @maxpermatchv161,

			@maxperballv161 = @maxperballv161,

			@UpdateMultiple = @UpdateMultiple,
			@UpdateMinMaxBet = @UpdateMinMaxBet,
			@UpdateMinMaxBetv2 = @UpdateMinMaxBetv2,
			@UpdateMinMaxBetv3 = @UpdateMinMaxBetv3,
			@UpdateMinMaxBetv5 = @UpdateMinMaxBetv5,
			@UpdateMinMaxBetv8 = @UpdateMinMaxBetv8,
			@UpdateMinMaxBetv10 = @UpdateMinMaxBetv10,
			@UpdateMinMaxBetv11 = @UpdateMinMaxBetv11,
			@UpdateMinMaxBetv99 = @UpdateMinMaxBetv99,
	        
			@UpdateMinMaxBetv99MP = @UpdateMinMaxBetv99MP,
			
			@UpdateMinMaxBetv1MP = @UpdateMinMaxBetv1MP,
			
			@UpdateMinMaxBetv154 = @UpdateMinMaxBetv154,
			@UpdateMinMaxBetv161 = @UpdateMinMaxBetv161,

			@SubAccID = @SubAccID,
			@UserID = @UserID,
			@Language = @Language,
			@IP = @IP,
			@ErrCode = @ErrCode_cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-106'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END

	----------------------------------------------
	--Update Position Taking
	if    @UpdatePositiontaking   = 1  or
		@UpdatePositiontakingv2   = 1  or
		@UpdatePositiontakingv3   = 1  or
		@UpdatePositiontakingv5   = 1  or
		@UpdatePositiontakingv8   = 1  or
		@UpdatePositiontakingv10   = 1  or
		@UpdatePositiontakingv11   = 1  or
		@UpdatePositiontakingv99   = 1  or
		@UpdatePositiontakingv99MP = 1 or
		@UpdatePositiontakingv154   = 1  or
		@UpdatePositiontakingv161 = 1
	BEGIN
		Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		--Check Old_PT <> New_PT
		Declare 
			--s3
			@spositiontaking_1_old smallmoney,
			@spositiontaking_2_old smallmoney,
			@spositiontaking_3_old smallmoney,
			@spositiontaking_4_old smallmoney,
			@spositiontaking_5_old smallmoney,
			@spositiontaking_6_old smallmoney,
			@spositiontaking_7_old smallmoney,
			@spositiontaking_8_old smallmoney,
			@spositiontaking_9_old smallmoney,
			@spositiontaking_10_old smallmoney,
			@spositiontaking_9999_old smallmoney,
			@slivepositiontaking_1_old smallmoney,
			@slivepositiontaking_3_old smallmoney,
			@slivepositiontaking_7_old smallmoney,
			@slivepositiontaking_8_old smallmoney,
	        
			@v2spositiontaking_1_old smallmoney,
			@v2spositiontaking_2_old smallmoney,
			@v2spositiontaking_3_old smallmoney,
			@v2spositiontaking_7_old smallmoney,
			@v2spositiontaking_8_old smallmoney,
	--        @v2spositiontaking_9_old smallmoney,
			@v2spositiontaking_20_old smallmoney,
	        
			@v3spositiontaking_1_old smallmoney,
			@v3spositiontaking_2_old smallmoney,
			@v3spositiontaking_3_old smallmoney,    
			@v3spositiontaking_20_old smallmoney,
	        
			@v5spositiontaking_1_old smallmoney,
			@v5spositiontaking_2_old smallmoney,
			@v5spositiontaking_3_old smallmoney,    
			@v5spositiontaking_20_old smallmoney,
			@v5spositiontaking_9999_old smallmoney,    
	        
			@v8spositiontaking_1_old smallmoney,
			@v8spositiontaking_3_old smallmoney,    
			@v8spositiontaking_20_old smallmoney,
	        
			@v10spositiontaking_1_old smallmoney,
			@v10spositiontaking_2_old smallmoney,
			@v10spositiontaking_3_old smallmoney,    
			@v10spositiontaking_20_old smallmoney,
			@v11spositiontaking_1_old smallmoney,
			@v11spositiontaking_20_old smallmoney,
	        
			@v99spositiontaking_1_old smallmoney,
			@v99spositiontaking_2_old smallmoney,
			@v99spositiontaking_3_old smallmoney,    
			@v99spositiontaking_20_old smallmoney,

			-- mixed sports
			@v99spositiontaking_9_old smallmoney,    
			@v154spositiontaking_20_old smallmoney,

			-- number game
			@v161spositiontaking_81_old smallmoney,    
			@v161spositiontaking_83_old smallmoney,            
			@v161spositiontaking_86_old smallmoney,    
			@v161spositiontaking_88_old smallmoney,    
	        
			@v161slivepositiontaking_85_old smallmoney,    
			@v161slivepositiontaking_86_old smallmoney,    
			@v161slivepositiontaking_87_old smallmoney,    
			@v161slivepositiontaking_89_old smallmoney,
			@v161slivepositiontaking_90_old smallmoney,
			--u3
			@auto_spositiontaking_1_old smallmoney ,
			@auto_spositiontaking_2_old smallmoney ,
			@auto_spositiontaking_3_old smallmoney ,
			@auto_spositiontaking_4_old smallmoney ,
			@auto_spositiontaking_5_old smallmoney,
			@auto_spositiontaking_6_old smallmoney ,
			@auto_spositiontaking_7_old smallmoney ,
			@auto_spositiontaking_8_old smallmoney ,
			@auto_spositiontaking_9_old smallmoney ,
			@auto_spositiontaking_10_old smallmoney ,
			@auto_spositiontaking_9999_old smallmoney ,
			@auto_slivepositiontaking_1_old smallmoney ,
			@auto_slivepositiontaking_3_old smallmoney ,
			@auto_slivepositiontaking_7_old smallmoney ,
			@auto_slivepositiontaking_8_old smallmoney ,
	        
			@auto_v2spositiontaking_1_old smallmoney ,
			@auto_v2spositiontaking_2_old smallmoney ,
			@auto_v2spositiontaking_3_old smallmoney ,
			@auto_v2spositiontaking_7_old smallmoney ,
			@auto_v2spositiontaking_8_old smallmoney ,
	--        @auto_v2spositiontaking_9_old smallmoney ,
			@auto_v2spositiontaking_20_old smallmoney ,
	        
			@auto_v3spositiontaking_1_old smallmoney ,
			@auto_v3spositiontaking_2_old smallmoney ,
			@auto_v3spositiontaking_3_old smallmoney ,
			@auto_v3spositiontaking_20_old smallmoney ,
	        
			@auto_v5spositiontaking_1_old smallmoney ,
			@auto_v5spositiontaking_2_old smallmoney ,
			@auto_v5spositiontaking_3_old smallmoney ,
			@auto_v5spositiontaking_20_old smallmoney ,
			@auto_v5spositiontaking_9999_old smallmoney ,
	        
			@auto_v8spositiontaking_1_old smallmoney ,
			@auto_v8spositiontaking_3_old smallmoney ,
			@auto_v8spositiontaking_20_old smallmoney ,
	        
			@auto_v10spositiontaking_1_old smallmoney ,
			@auto_v10spositiontaking_2_old smallmoney ,
			@auto_v10spositiontaking_3_old smallmoney ,
			@auto_v10spositiontaking_20_old smallmoney ,
	        
			@auto_v11spositiontaking_1_old smallmoney ,
			@auto_v11spositiontaking_20_old smallmoney ,

			@auto_v99spositiontaking_1_old smallmoney ,
			@auto_v99spositiontaking_2_old smallmoney ,
			@auto_v99spositiontaking_3_old smallmoney ,
			@auto_v99spositiontaking_20_old smallmoney ,

			-- mixed sports
			@auto_v99spositiontaking_9_old smallmoney ,
			@auto_v154spositiontaking_20_old smallmoney ,

			-- number game
			@auto_v161spositiontaking_81_old smallmoney ,
			@auto_v161spositiontaking_83_old smallmoney ,        
			@auto_v161spositiontaking_86_old smallmoney ,
			@auto_v161spositiontaking_88_old smallmoney ,
	        
			@auto_v161slivepositiontaking_85_old smallmoney ,
			@auto_v161slivepositiontaking_86_old smallmoney ,
			@auto_v161slivepositiontaking_87_old smallmoney ,
			@auto_v161slivepositiontaking_89_old smallmoney ,
			@auto_v161slivepositiontaking_90_old smallmoney ,
			--i3
			@isauto_spositiontaking_1_old bit ,
			@isauto_spositiontaking_2_old bit ,
			@isauto_spositiontaking_3_old bit ,
			@isauto_spositiontaking_4_old bit ,
			@isauto_spositiontaking_5_old bit,
			@isauto_spositiontaking_6_old bit ,
			@isauto_spositiontaking_7_old bit ,
			@isauto_spositiontaking_8_old bit ,
			@isauto_spositiontaking_9_old bit ,
			@isauto_spositiontaking_10_old bit ,
			@isauto_spositiontaking_9999_old bit ,
			@isauto_slivepositiontaking_1_old bit ,
			@isauto_slivepositiontaking_3_old bit ,
			@isauto_slivepositiontaking_7_old bit ,
			@isauto_slivepositiontaking_8_old bit ,
	        
			@isauto_v2spositiontaking_1_old bit ,
			@isauto_v2spositiontaking_2_old bit ,
			@isauto_v2spositiontaking_3_old bit ,
			@isauto_v2spositiontaking_7_old bit ,
			@isauto_v2spositiontaking_8_old bit ,
	--        @isauto_v2spositiontaking_9_old bit ,
			@isauto_v2spositiontaking_20_old bit ,
	        
			@isauto_v3spositiontaking_1_old bit ,
			@isauto_v3spositiontaking_2_old bit ,
			@isauto_v3spositiontaking_3_old bit ,
			@isauto_v3spositiontaking_20_old bit ,
	        
			@isauto_v5spositiontaking_1_old bit ,
			@isauto_v5spositiontaking_2_old bit ,
			@isauto_v5spositiontaking_3_old bit ,
			@isauto_v5spositiontaking_20_old bit ,
			@isauto_v5spositiontaking_9999_old bit ,
	        
			@isauto_v8spositiontaking_1_old bit ,
			@isauto_v8spositiontaking_3_old bit ,
			@isauto_v8spositiontaking_20_old bit ,
	        
			@isauto_v10spositiontaking_1_old bit ,
			@isauto_v10spositiontaking_2_old bit ,
			@isauto_v10spositiontaking_3_old bit ,
			@isauto_v10spositiontaking_20_old bit ,
	        
			@isauto_v11spositiontaking_1_old bit ,
			@isauto_v11spositiontaking_20_old bit ,
	        
			@isauto_v99spositiontaking_1_old bit ,
			@isauto_v99spositiontaking_2_old bit ,
			@isauto_v99spositiontaking_3_old bit ,
			@isauto_v99spositiontaking_20_old bit ,

			-- mixed sports
			@isauto_v99spositiontaking_9_old bit ,
			@isauto_v154spositiontaking_20_old bit ,

			-- number game
			@isauto_v161spositiontaking_81_old bit ,
			@isauto_v161spositiontaking_83_old bit ,        
			@isauto_v161spositiontaking_86_old bit ,
			@isauto_v161spositiontaking_88_old bit ,
	        
			@isauto_v161slivepositiontaking_85_old bit ,
			@isauto_v161slivepositiontaking_86_old bit ,
			@isauto_v161slivepositiontaking_87_old bit ,
			@isauto_v161slivepositiontaking_89_old bit ,
			@isauto_v161slivepositiontaking_90_old bit ,
			--m3        
			@mpositiontaking_1_old smallmoney ,
			@mpositiontaking_2_old smallmoney ,
			@mpositiontaking_3_old smallmoney ,
			@mpositiontaking_4_old smallmoney ,
			@mpositiontaking_5_old smallmoney ,
			@mpositiontaking_6_old smallmoney ,
			@mpositiontaking_7_old smallmoney ,
			@mpositiontaking_8_old smallmoney ,
			@mpositiontaking_9_old smallmoney ,
			@mpositiontaking_10_old smallmoney ,
			@mpositiontaking_9999_old smallmoney ,
			@mlivepositiontaking_1_old smallmoney ,
			@mlivepositiontaking_3_old smallmoney ,
			@mlivepositiontaking_7_old smallmoney ,
			@mlivepositiontaking_8_old smallmoney ,
	        
			@v2mpositiontaking_1_old smallmoney ,
			@v2mpositiontaking_2_old smallmoney ,
			@v2mpositiontaking_3_old smallmoney ,
			@v2mpositiontaking_7_old smallmoney ,
			@v2mpositiontaking_8_old smallmoney ,
	--        @v2mpositiontaking_9_old smallmoney ,
			@v2mpositiontaking_20_old smallmoney ,
	        
			@v3mpositiontaking_1_old smallmoney ,
			@v3mpositiontaking_2_old smallmoney ,
			@v3mpositiontaking_3_old smallmoney ,
			@v3mpositiontaking_20_old smallmoney ,
	        
			@v5mpositiontaking_1_old smallmoney ,
			@v5mpositiontaking_2_old smallmoney ,
			@v5mpositiontaking_3_old smallmoney ,
			@v5mpositiontaking_20_old smallmoney ,
			@v5mpositiontaking_9999_old smallmoney ,
	        
			@v8mpositiontaking_1_old smallmoney ,
			@v8mpositiontaking_3_old smallmoney ,
			@v8mpositiontaking_20_old smallmoney ,
	        
			@v10mpositiontaking_1_old smallmoney ,
			@v10mpositiontaking_2_old smallmoney ,
			@v10mpositiontaking_3_old smallmoney ,
			@v10mpositiontaking_20_old smallmoney ,
	        
			@v11mpositiontaking_1_old smallmoney ,
			@v11mpositiontaking_20_old smallmoney ,
	        
			@v99mpositiontaking_1_old smallmoney ,
			@v99mpositiontaking_2_old smallmoney ,
			@v99mpositiontaking_3_old smallmoney ,
			@v99mpositiontaking_20_old smallmoney,

			-- mixed sports
			@v99mpositiontaking_9_old smallmoney,
			@v154mpositiontaking_20_old smallmoney,

			-- number game
			@v161mpositiontaking_81_old smallmoney,
			@v161mpositiontaking_83_old smallmoney,        
			@v161mpositiontaking_86_old smallmoney,
			@v161mpositiontaking_88_old smallmoney,
	        
			@v161mlivepositiontaking_85_old smallmoney,
			@v161mlivepositiontaking_86_old smallmoney,
			@v161mlivepositiontaking_87_old smallmoney,
			@v161mlivepositiontaking_89_old smallmoney,
			@v161mlivepositiontaking_90_old smallmoney,
			
			-- Outright PT for sports
			@v2spositiontaking_10_old smallmoney,
			@v3spositiontaking_10_old smallmoney,
			@v5spositiontaking_10_old smallmoney,
			@v8spositiontaking_10_old smallmoney,
			@v10spositiontaking_10_old smallmoney,
			@v11spositiontaking_10_old smallmoney,
			@v99spositiontaking_10_old smallmoney,
			
			@auto_v2spositiontaking_10_old smallmoney ,
			@auto_v3spositiontaking_10_old smallmoney ,
			@auto_v5spositiontaking_10_old smallmoney ,
			@auto_v8spositiontaking_10_old smallmoney ,
			@auto_v10spositiontaking_10_old smallmoney ,
			@auto_v11spositiontaking_10_old smallmoney ,
			@auto_v99spositiontaking_10_old smallmoney ,
			
			@isauto_v2spositiontaking_10_old bit ,
			@isauto_v3spositiontaking_10_old bit ,
			@isauto_v5spositiontaking_10_old bit ,
			@isauto_v8spositiontaking_10_old bit ,
			@isauto_v10spositiontaking_10_old bit ,
			@isauto_v11spositiontaking_10_old bit ,
			@isauto_v99spositiontaking_10_old bit ,
			
			@v2mpositiontaking_10_old smallmoney ,
			@v3mpositiontaking_10_old smallmoney ,
			@v5mpositiontaking_10_old smallmoney ,
			@v8mpositiontaking_10_old smallmoney ,
			@v10mpositiontaking_10_old smallmoney ,
			@v11mpositiontaking_10_old smallmoney ,
			@v99mpositiontaking_10_old smallmoney 
	        
		--Get old PT s3,m3,u3,i3
		select @spositiontaking_1_old = spositiontaking, @slivepositiontaking_1_old = slivepositiontaking, @mpositiontaking_1_old = mpositiontaking, @mlivepositiontaking_1_old = mlivepositiontaking, @auto_spositiontaking_1_old = autopositiontaking, @auto_slivepositiontaking_1_old = autolivepositiontaking, @isauto_spositiontaking_1_old = isautopositiontaking, @isauto_slivepositiontaking_1_old = isautolivepositiontaking  from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1
		select @spositiontaking_3_old = spositiontaking, @slivepositiontaking_3_old = slivepositiontaking, @mpositiontaking_3_old = mpositiontaking, @mlivepositiontaking_3_old = mlivepositiontaking, @auto_spositiontaking_3_old = autopositiontaking, @auto_slivepositiontaking_3_old = autolivepositiontaking, @isauto_spositiontaking_3_old = isautopositiontaking, @isauto_slivepositiontaking_3_old = isautolivepositiontaking  from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1
		select @spositiontaking_7_old = spositiontaking, @slivepositiontaking_7_old = slivepositiontaking, @mpositiontaking_7_old = mpositiontaking, @mlivepositiontaking_7_old = mlivepositiontaking, @auto_spositiontaking_7_old = autopositiontaking, @auto_slivepositiontaking_7_old = autolivepositiontaking, @isauto_spositiontaking_7_old = isautopositiontaking, @isauto_slivepositiontaking_7_old = isautolivepositiontaking  from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1
		select @spositiontaking_8_old = spositiontaking, @slivepositiontaking_8_old = slivepositiontaking, @mpositiontaking_8_old = mpositiontaking, @mlivepositiontaking_8_old = mlivepositiontaking, @auto_spositiontaking_8_old = autopositiontaking, @auto_slivepositiontaking_8_old = autolivepositiontaking, @isauto_spositiontaking_8_old = isautopositiontaking, @isauto_slivepositiontaking_8_old = isautolivepositiontaking  from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1
		select @spositiontaking_2_old = spositiontaking, @mpositiontaking_2_old = mpositiontaking, @auto_spositiontaking_2_old = autopositiontaking, @isauto_spositiontaking_2_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
		select @spositiontaking_4_old = spositiontaking, @mpositiontaking_4_old = mpositiontaking, @auto_spositiontaking_4_old = autopositiontaking, @isauto_spositiontaking_4_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1

		select @spositiontaking_5_old = spositiontaking, @mpositiontaking_5_old = mpositiontaking, @auto_spositiontaking_5_old = autopositiontaking, @isauto_spositiontaking_5_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
		select @spositiontaking_6_old = spositiontaking, @mpositiontaking_6_old = mpositiontaking, @auto_spositiontaking_6_old = autopositiontaking, @isauto_spositiontaking_6_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
		select @spositiontaking_9_old = spositiontaking, @mpositiontaking_9_old = mpositiontaking, @auto_spositiontaking_9_old = autopositiontaking, @isauto_spositiontaking_9_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
		select @spositiontaking_10_old = spositiontaking, @mpositiontaking_10_old = mpositiontaking, @auto_spositiontaking_10_old = autopositiontaking, @isauto_spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1
		
		-- Outright PT for sports
		select @v2spositiontaking_10_old = spositiontaking, @v2mpositiontaking_10_old = mpositiontaking, @auto_v2spositiontaking_10_old = autopositiontaking, @isauto_v2spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=2
		select @v3spositiontaking_10_old = spositiontaking, @v3mpositiontaking_10_old = mpositiontaking, @auto_v3spositiontaking_10_old = autopositiontaking, @isauto_v3spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=3
		select @v5spositiontaking_10_old = spositiontaking, @v5mpositiontaking_10_old = mpositiontaking, @auto_v5spositiontaking_10_old = autopositiontaking, @isauto_v5spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=5
		select @v8spositiontaking_10_old = spositiontaking, @v8mpositiontaking_10_old = mpositiontaking, @auto_v8spositiontaking_10_old = autopositiontaking, @isauto_v8spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=8
		select @v10spositiontaking_10_old = spositiontaking, @v10mpositiontaking_10_old = mpositiontaking, @auto_v10spositiontaking_10_old = autopositiontaking, @isauto_v10spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=10
		select @v11spositiontaking_10_old = spositiontaking, @v11mpositiontaking_10_old = mpositiontaking, @auto_v11spositiontaking_10_old = autopositiontaking, @isauto_v11spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=11
		select @v99spositiontaking_10_old = spositiontaking, @v99mpositiontaking_10_old = mpositiontaking, @auto_v99spositiontaking_10_old = autopositiontaking, @isauto_v99spositiontaking_10_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=99
		
		select @spositiontaking_9999_old = spositiontaking, @mpositiontaking_9999_old = mpositiontaking, @auto_spositiontaking_9999_old = autopositiontaking, @isauto_spositiontaking_9999_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=1
	    
		select @v2spositiontaking_1_old = spositiontaking, @v2mpositiontaking_1_old = mpositiontaking, @auto_v2spositiontaking_1_old = autopositiontaking, @isauto_v2spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=2
		select @v2spositiontaking_2_old = spositiontaking, @v2mpositiontaking_2_old = mpositiontaking, @auto_v2spositiontaking_2_old = autopositiontaking, @isauto_v2spositiontaking_2_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=2
		select @v2spositiontaking_3_old = spositiontaking, @v2mpositiontaking_3_old = mpositiontaking, @auto_v2spositiontaking_3_old = autopositiontaking, @isauto_v2spositiontaking_3_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=2
		select @v2spositiontaking_7_old = spositiontaking, @v2mpositiontaking_7_old = mpositiontaking, @auto_v2spositiontaking_7_old = autopositiontaking, @isauto_v2spositiontaking_7_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=2
		select @v2spositiontaking_8_old = spositiontaking, @v2mpositiontaking_8_old = mpositiontaking, @auto_v2spositiontaking_8_old = autopositiontaking, @isauto_v2spositiontaking_8_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=2
	--    select @v2spositiontaking_9_old = spositiontaking, @v2mpositiontaking_9_old = mpositiontaking, @auto_v2spositiontaking_9_old = autopositiontaking, @isauto_v2spositiontaking_9_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=2
		select @v2spositiontaking_20_old = spositiontaking, @v2mpositiontaking_20_old = mpositiontaking, @auto_v2spositiontaking_20_old = autopositiontaking, @isauto_v2spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=2

		select @v3spositiontaking_1_old = spositiontaking, @v3mpositiontaking_1_old = mpositiontaking, @auto_v3spositiontaking_1_old = autopositiontaking, @isauto_v3spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=3
		select @v3spositiontaking_2_old = spositiontaking, @v3mpositiontaking_2_old = mpositiontaking, @auto_v3spositiontaking_2_old = autopositiontaking, @isauto_v3spositiontaking_2_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=3
		select @v3spositiontaking_3_old = spositiontaking, @v3mpositiontaking_3_old = mpositiontaking, @auto_v3spositiontaking_3_old = autopositiontaking, @isauto_v3spositiontaking_3_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=3
		select @v3spositiontaking_20_old = spositiontaking, @v3mpositiontaking_20_old = mpositiontaking, @auto_v3spositiontaking_20_old = autopositiontaking, @isauto_v3spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=3

		select @v5spositiontaking_1_old = spositiontaking, @v5mpositiontaking_1_old = mpositiontaking, @auto_v5spositiontaking_1_old = autopositiontaking, @isauto_v5spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=5
		select @v5spositiontaking_2_old = spositiontaking, @v5mpositiontaking_2_old = mpositiontaking, @auto_v5spositiontaking_2_old = autopositiontaking, @isauto_v5spositiontaking_2_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=5
		select @v5spositiontaking_3_old = spositiontaking, @v5mpositiontaking_3_old = mpositiontaking, @auto_v5spositiontaking_3_old = autopositiontaking, @isauto_v5spositiontaking_3_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=5
		select @v5spositiontaking_20_old = spositiontaking, @v5mpositiontaking_20_old = mpositiontaking, @auto_v5spositiontaking_20_old = autopositiontaking, @isauto_v5spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=5
		select @v5spositiontaking_9999_old = spositiontaking, @v5mpositiontaking_9999_old = mpositiontaking, @auto_v5spositiontaking_9999_old = autopositiontaking, @isauto_v5spositiontaking_9999_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=5

		select @v8spositiontaking_1_old = spositiontaking, @v8mpositiontaking_1_old = mpositiontaking, @auto_v8spositiontaking_1_old = autopositiontaking, @isauto_v8spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
		select @v8spositiontaking_3_old = spositiontaking, @v8mpositiontaking_3_old = mpositiontaking, @auto_v8spositiontaking_3_old = autopositiontaking, @isauto_v8spositiontaking_3_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
		select @v8spositiontaking_20_old = spositiontaking, @v8mpositiontaking_20_old = mpositiontaking, @auto_v8spositiontaking_20_old = autopositiontaking, @isauto_v8spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8

		select @v10spositiontaking_1_old = spositiontaking, @v10mpositiontaking_1_old = mpositiontaking, @auto_v10spositiontaking_1_old = autopositiontaking, @isauto_v10spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=10
		select @v10spositiontaking_2_old = spositiontaking, @v10mpositiontaking_2_old = mpositiontaking, @auto_v10spositiontaking_2_old = autopositiontaking, @isauto_v10spositiontaking_2_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=10
		select @v10spositiontaking_3_old = spositiontaking, @v10mpositiontaking_3_old = mpositiontaking, @auto_v10spositiontaking_3_old = autopositiontaking, @isauto_v10spositiontaking_3_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=10
		select @v10spositiontaking_20_old = spositiontaking, @v10mpositiontaking_20_old = mpositiontaking, @auto_v10spositiontaking_20_old = autopositiontaking, @isauto_v10spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=10

		select @v11spositiontaking_1_old = spositiontaking, @v11mpositiontaking_1_old = mpositiontaking, @auto_v11spositiontaking_1_old = autopositiontaking, @isauto_v11spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=11
		select @v11spositiontaking_20_old = spositiontaking, @v11mpositiontaking_20_old = mpositiontaking, @auto_v11spositiontaking_20_old = autopositiontaking, @isauto_v11spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=11

		select @v99spositiontaking_1_old = spositiontaking, @v99mpositiontaking_1_old = mpositiontaking, @auto_v99spositiontaking_1_old = autopositiontaking, @isauto_v99spositiontaking_1_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=99
		select @v99spositiontaking_2_old = spositiontaking, @v99mpositiontaking_2_old = mpositiontaking, @auto_v99spositiontaking_2_old = autopositiontaking, @isauto_v99spositiontaking_2_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=99
		select @v99spositiontaking_3_old = spositiontaking, @v99mpositiontaking_3_old = mpositiontaking, @auto_v99spositiontaking_3_old = autopositiontaking, @isauto_v99spositiontaking_3_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=99
		select @v99spositiontaking_20_old = spositiontaking, @v99mpositiontaking_20_old = mpositiontaking, @auto_v99spositiontaking_20_old = autopositiontaking, @isauto_v99spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=99

		-- mixed sports
		select @v99spositiontaking_9_old = spositiontaking, @v99mpositiontaking_9_old = mpositiontaking, @auto_v99spositiontaking_9_old = autopositiontaking, @isauto_v99spositiontaking_9_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=99
		select @v154spositiontaking_20_old = spositiontaking, @v154mpositiontaking_20_old = mpositiontaking, @auto_v154spositiontaking_20_old = autopositiontaking, @isauto_v154spositiontaking_20_old = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=154

		-- number game
		select @v161spositiontaking_81_old = spositiontaking, @v161mpositiontaking_81_old = mpositiontaking, @auto_v161spositiontaking_81_old = autopositiontaking, @isauto_v161spositiontaking_81_old = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype = 81 and sporttype = 161
		select @v161spositiontaking_83_old = spositiontaking, @v161mpositiontaking_83_old = mpositiontaking, @auto_v161spositiontaking_83_old = autopositiontaking, @isauto_v161spositiontaking_83_old = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype = 83 and sporttype = 161
		select @v161spositiontaking_88_old = spositiontaking, @v161mpositiontaking_88_old = mpositiontaking, @auto_v161spositiontaking_88_old = autopositiontaking, @isauto_v161spositiontaking_88_old = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype = 88 and sporttype = 161    
		select @v161slivepositiontaking_85_old = slivepositiontaking, @v161mlivepositiontaking_85_old = mlivepositiontaking, @auto_v161slivepositiontaking_85_old = autolivepositiontaking, @isauto_v161slivepositiontaking_85_old = isautolivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
		select @v161spositiontaking_86_old = spositiontaking, @v161slivepositiontaking_86_old = slivepositiontaking, @v161mpositiontaking_86_old = mpositiontaking, @v161mlivepositiontaking_86_old = mlivepositiontaking, @auto_v161spositiontaking_86_old = autopositiontaking, @auto_v161slivepositiontaking_86_old = autolivepositiontaking, @isauto_v161spositiontaking_86_old = isautopositiontaking, @isauto_v161slivepositiontaking_86_old = isautolivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
		select @v161slivepositiontaking_87_old = slivepositiontaking, @v161mlivepositiontaking_87_old = mlivepositiontaking, @auto_v161slivepositiontaking_87_old = autolivepositiontaking, @isauto_v161slivepositiontaking_87_old = isautolivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
		select @v161slivepositiontaking_89_old = slivepositiontaking, @v161mlivepositiontaking_89_old = mlivepositiontaking, @auto_v161slivepositiontaking_89_old = autolivepositiontaking, @isauto_v161slivepositiontaking_89_old = isautolivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
		select @v161slivepositiontaking_90_old = slivepositiontaking, @v161mlivepositiontaking_90_old = mlivepositiontaking, @auto_v161slivepositiontaking_90_old = autolivepositiontaking, @isauto_v161slivepositiontaking_90_old = isautolivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161
	    
	 
		--Check Old_PT <> New_PT
		IF    @spositiontaking_1 <> @spositiontaking_1_old or
			@spositiontaking_2 <> @spositiontaking_2_old or
			@spositiontaking_3 <> @spositiontaking_3_old or
			@spositiontaking_4 <> @spositiontaking_4_old or
			@spositiontaking_5 <> @spositiontaking_5_old or
			@spositiontaking_6 <> @spositiontaking_6_old or
			@spositiontaking_7 <> @spositiontaking_7_old or
			@spositiontaking_8 <> @spositiontaking_8_old or
			@spositiontaking_9 <> @spositiontaking_9_old or
			@spositiontaking_10 <> @spositiontaking_10_old or
			@spositiontaking_9999 <> @spositiontaking_9999_old or
			@slivepositiontaking_1 <> @slivepositiontaking_1_old or
			@slivepositiontaking_3 <> @slivepositiontaking_3_old or
			@slivepositiontaking_7 <> @slivepositiontaking_7_old or
			@slivepositiontaking_8 <> @slivepositiontaking_8_old or
	        
			@v2spositiontaking_1 <> @v2spositiontaking_1_old or
			@v2spositiontaking_2 <> @v2spositiontaking_2_old or
			@v2spositiontaking_3 <> @v2spositiontaking_3_old or
			@v2spositiontaking_7 <> @v2spositiontaking_7_old or
			@v2spositiontaking_8 <> @v2spositiontaking_8_old or
	--        @v2spositiontaking_9 <> @v2spositiontaking_9_old or
			@v2spositiontaking_20 <> @v2spositiontaking_20_old or
	        
			@v3spositiontaking_1 <> @v3spositiontaking_1_old or
			@v3spositiontaking_2 <> @v3spositiontaking_2_old or
			@v3spositiontaking_3 <> @v3spositiontaking_3_old or
			@v3spositiontaking_20 <> @v3spositiontaking_20_old or
	        
			@v5spositiontaking_1 <> @v5spositiontaking_1_old or
			@v5spositiontaking_2 <> @v5spositiontaking_2_old or
			@v5spositiontaking_3 <> @v5spositiontaking_3_old or
			@v5spositiontaking_20 <> @v5spositiontaking_20_old or
			@v5spositiontaking_9999 <> @v5spositiontaking_9999_old or
	        
			@v8spositiontaking_1 <> @v8spositiontaking_1_old or
			@v8spositiontaking_3 <> @v8spositiontaking_3_old or
			@v8spositiontaking_20 <> @v8spositiontaking_20_old or
	        
			@v10spositiontaking_1 <> @v10spositiontaking_1_old or
			@v10spositiontaking_2 <> @v10spositiontaking_2_old or
			@v10spositiontaking_3 <> @v10spositiontaking_3_old or
			@v10spositiontaking_20 <> @v10spositiontaking_20_old or
	        
			@v11spositiontaking_1 <> @v11spositiontaking_1_old or
			@v11spositiontaking_20 <> @v11spositiontaking_20_old or

			@v99spositiontaking_1 <> @v99spositiontaking_1_old or
			@v99spositiontaking_2 <> @v99spositiontaking_2_old or
			@v99spositiontaking_3 <> @v99spositiontaking_3_old or
			@v99spositiontaking_20 <> @v99spositiontaking_20_old or

			-- mixed sports
			@v99spositiontaking_9 <> @v99spositiontaking_9_old or
			@v154spositiontaking_20 <> @v154spositiontaking_20_old or

			-- number game
			@v161spositiontaking_81 <> @v161spositiontaking_81_old or
			@v161spositiontaking_83 <> @v161spositiontaking_83_old or        
			@v161spositiontaking_86 <> @v161spositiontaking_86_old or
			@v161spositiontaking_88 <> @v161spositiontaking_88_old or
			@v161slivepositiontaking_85 <> @v161slivepositiontaking_85_old or
			@v161slivepositiontaking_86 <> @v161slivepositiontaking_86_old or
			@v161slivepositiontaking_87 <> @v161slivepositiontaking_87_old or
			@v161slivepositiontaking_89 <> @v161slivepositiontaking_89_old or
			@v161slivepositiontaking_90 <> @v161slivepositiontaking_90_old or
	        
			@auto_spositiontaking_1 <> @auto_spositiontaking_1_old or
			@auto_spositiontaking_2 <> @auto_spositiontaking_2_old or
			@auto_spositiontaking_3 <> @auto_spositiontaking_3_old or
			@auto_spositiontaking_4 <> @auto_spositiontaking_4_old or
			@auto_spositiontaking_5 <> @auto_spositiontaking_5_old or
			@auto_spositiontaking_6 <> @auto_spositiontaking_6_old or
			@auto_spositiontaking_7 <> @auto_spositiontaking_7_old or
			@auto_spositiontaking_8 <> @auto_spositiontaking_8_old or
			@auto_spositiontaking_9 <> @auto_spositiontaking_9_old or
			@auto_spositiontaking_10 <> @auto_spositiontaking_10_old or
			@auto_spositiontaking_9999 <> @auto_spositiontaking_9999_old or
			@auto_slivepositiontaking_1 <> @auto_slivepositiontaking_1_old or
			@auto_slivepositiontaking_3 <> @auto_slivepositiontaking_3_old or
			@auto_slivepositiontaking_7 <> @auto_slivepositiontaking_7_old or
			@auto_slivepositiontaking_8 <> @auto_slivepositiontaking_8_old or
	        
			@auto_v2spositiontaking_1 <> @auto_v2spositiontaking_1_old or
			@auto_v2spositiontaking_2 <> @auto_v2spositiontaking_2_old or
			@auto_v2spositiontaking_3 <> @auto_v2spositiontaking_3_old or
			@auto_v2spositiontaking_7 <> @auto_v2spositiontaking_7_old or
			@auto_v2spositiontaking_8 <> @auto_v2spositiontaking_8_old or
	--        @auto_v2spositiontaking_9 <> @auto_v2spositiontaking_9_old or
			@auto_v2spositiontaking_20 <> @auto_v2spositiontaking_20_old or
	        
			@auto_v3spositiontaking_1 <> @auto_v3spositiontaking_1_old or
			@auto_v3spositiontaking_2 <> @auto_v3spositiontaking_2_old or
			@auto_v3spositiontaking_3 <> @auto_v3spositiontaking_3_old or
			@auto_v3spositiontaking_20 <> @auto_v3spositiontaking_20_old or
	        
			@auto_v5spositiontaking_1 <> @auto_v5spositiontaking_1_old or
			@auto_v5spositiontaking_2 <> @auto_v5spositiontaking_2_old or
			@auto_v5spositiontaking_3 <> @auto_v5spositiontaking_3_old or
			@auto_v5spositiontaking_20 <> @auto_v5spositiontaking_20_old or
			@auto_v5spositiontaking_9999 <> @auto_v5spositiontaking_9999_old or
	        
			@auto_v8spositiontaking_1 <> @auto_v8spositiontaking_1_old or
			@auto_v8spositiontaking_3 <> @auto_v8spositiontaking_3_old or
			@auto_v8spositiontaking_20 <> @auto_v8spositiontaking_20_old or
	        
			@auto_v10spositiontaking_1 <> @auto_v10spositiontaking_1_old or
			@auto_v10spositiontaking_2 <> @auto_v10spositiontaking_2_old or
			@auto_v10spositiontaking_3 <> @auto_v10spositiontaking_3_old or
			@auto_v10spositiontaking_20 <> @auto_v10spositiontaking_20_old or
	        
			@auto_v11spositiontaking_1 <> @auto_v11spositiontaking_1_old or
			@auto_v11spositiontaking_20 <> @auto_v11spositiontaking_20_old or

			@auto_v99spositiontaking_1 <> @auto_v99spositiontaking_1_old or
			@auto_v99spositiontaking_2 <> @auto_v99spositiontaking_2_old or
			@auto_v99spositiontaking_3 <> @auto_v99spositiontaking_3_old or
			@auto_v99spositiontaking_20 <> @auto_v99spositiontaking_20_old or

			-- mixed sports
			@auto_v99spositiontaking_9 <> @auto_v99spositiontaking_9_old or
			@auto_v154spositiontaking_20 <> @auto_v154spositiontaking_20_old or

			-- number game
			@auto_v161spositiontaking_81 <> @auto_v161spositiontaking_81_old or
			@auto_v161spositiontaking_83 <> @auto_v161spositiontaking_83_old or        
			@auto_v161spositiontaking_86 <> @auto_v161spositiontaking_86_old or
			@auto_v161spositiontaking_88 <> @auto_v161spositiontaking_88_old or
	        
			@auto_v161slivepositiontaking_85 <> @auto_v161slivepositiontaking_85_old or
			@auto_v161slivepositiontaking_86 <> @auto_v161slivepositiontaking_86_old or
			@auto_v161slivepositiontaking_87 <> @auto_v161slivepositiontaking_87_old or
			@auto_v161slivepositiontaking_89 <> @auto_v161slivepositiontaking_89_old or
			@auto_v161slivepositiontaking_90 <> @auto_v161slivepositiontaking_90_old or
	        
			@isauto_spositiontaking_1 <> @isauto_spositiontaking_1_old or
			@isauto_spositiontaking_2 <> @isauto_spositiontaking_2_old or
			@isauto_spositiontaking_3 <> @isauto_spositiontaking_3_old or
			@isauto_spositiontaking_4 <> @isauto_spositiontaking_4_old or
			@isauto_spositiontaking_5 <> @isauto_spositiontaking_5_old or
			@isauto_spositiontaking_6 <> @isauto_spositiontaking_6_old or
			@isauto_spositiontaking_7 <> @isauto_spositiontaking_7_old or
			@isauto_spositiontaking_8 <> @isauto_spositiontaking_8_old or
			@isauto_spositiontaking_9 <> @isauto_spositiontaking_9_old or
			@isauto_spositiontaking_10 <> @isauto_spositiontaking_10_old or
			@isauto_spositiontaking_9999 <> @isauto_spositiontaking_9999_old or
			@isauto_slivepositiontaking_1 <> @isauto_slivepositiontaking_1_old or
			@isauto_slivepositiontaking_3 <> @isauto_slivepositiontaking_3_old or
			@isauto_slivepositiontaking_7 <> @isauto_slivepositiontaking_7_old or
			@isauto_slivepositiontaking_8 <> @isauto_slivepositiontaking_8_old or

			@isauto_v2spositiontaking_1 <> @isauto_v2spositiontaking_1_old or
			@isauto_v2spositiontaking_2 <> @isauto_v2spositiontaking_2_old or
			@isauto_v2spositiontaking_3 <> @isauto_v2spositiontaking_3_old or
			@isauto_v2spositiontaking_7 <> @isauto_v2spositiontaking_7_old or
			@isauto_v2spositiontaking_8 <> @isauto_v2spositiontaking_8_old or
	--        @isauto_v2spositiontaking_9 <> @isauto_v2spositiontaking_9_old or
			@isauto_v2spositiontaking_20 <> @isauto_v2spositiontaking_20_old or

			@isauto_v3spositiontaking_1 <> @isauto_v3spositiontaking_1_old or
			@isauto_v3spositiontaking_2 <> @isauto_v3spositiontaking_2_old or
			@isauto_v3spositiontaking_3 <> @isauto_v3spositiontaking_3_old or
			@isauto_v3spositiontaking_20 <> @isauto_v3spositiontaking_20_old or

			@isauto_v5spositiontaking_1 <> @isauto_v5spositiontaking_1_old or
			@isauto_v5spositiontaking_2 <> @isauto_v5spositiontaking_2_old or
			@isauto_v5spositiontaking_3 <> @isauto_v5spositiontaking_3_old or
			@isauto_v5spositiontaking_20 <> @isauto_v5spositiontaking_20_old or
			@isauto_v5spositiontaking_9999 <> @isauto_v5spositiontaking_9999_old or

			@isauto_v8spositiontaking_1 <> @isauto_v8spositiontaking_1_old or
			@isauto_v8spositiontaking_3 <> @isauto_v8spositiontaking_3_old or
			@isauto_v8spositiontaking_20 <> @isauto_v8spositiontaking_20_old or

			@isauto_v10spositiontaking_1 <> @isauto_v10spositiontaking_1_old or
			@isauto_v10spositiontaking_2 <> @isauto_v10spositiontaking_2_old or
			@isauto_v10spositiontaking_3 <> @isauto_v10spositiontaking_3_old or
			@isauto_v10spositiontaking_20 <> @isauto_v10spositiontaking_20_old or

			@isauto_v11spositiontaking_1 <> @isauto_v11spositiontaking_1_old or
			@isauto_v11spositiontaking_20 <> @isauto_v11spositiontaking_20_old or

			@isauto_v99spositiontaking_1 <> @isauto_v99spositiontaking_1_old or
			@isauto_v99spositiontaking_2 <> @isauto_v99spositiontaking_2_old or
			@isauto_v99spositiontaking_3 <> @isauto_v99spositiontaking_3_old or
			@isauto_v99spositiontaking_20 <> @isauto_v99spositiontaking_20_old or

			-- mixed sports
			@isauto_v99spositiontaking_9 <> @isauto_v99spositiontaking_9_old or
			@isauto_v154spositiontaking_20 <> @isauto_v154spositiontaking_20_old or

			-- number game
			@isauto_v161spositiontaking_81 <> @isauto_v161spositiontaking_81_old or
			@isauto_v161spositiontaking_83 <> @isauto_v161spositiontaking_83_old or        
			@isauto_v161spositiontaking_86 <> @isauto_v161spositiontaking_86_old or
			@isauto_v161spositiontaking_88 <> @isauto_v161spositiontaking_88_old or
	        
			@isauto_v161slivepositiontaking_85 <> @isauto_v161slivepositiontaking_85_old or
			@isauto_v161slivepositiontaking_86 <> @isauto_v161slivepositiontaking_86_old or
			@isauto_v161slivepositiontaking_87 <> @isauto_v161slivepositiontaking_87_old or
			@isauto_v161slivepositiontaking_89 <> @isauto_v161slivepositiontaking_89_old or
			@isauto_v161slivepositiontaking_90 <> @isauto_v161slivepositiontaking_90_old or

			@mpositiontaking_1 <> @mpositiontaking_1_old or
			@mpositiontaking_2 <> @mpositiontaking_2_old or
			@mpositiontaking_3 <> @mpositiontaking_3_old or
			@mpositiontaking_4 <> @mpositiontaking_4_old or
			@mpositiontaking_5 <> @mpositiontaking_5_old or
			@mpositiontaking_6 <> @mpositiontaking_6_old or
			@mpositiontaking_7 <> @mpositiontaking_7_old or
			@mpositiontaking_8 <> @mpositiontaking_8_old or
			@mpositiontaking_9 <> @mpositiontaking_9_old or
			@mpositiontaking_10 <> @mpositiontaking_10_old or
			@mpositiontaking_9999 <> @mpositiontaking_9999_old or
			@mlivepositiontaking_1 <> @mlivepositiontaking_1_old or
			@mlivepositiontaking_3 <> @mlivepositiontaking_3_old or
			@mlivepositiontaking_7 <> @mlivepositiontaking_7_old or
			@mlivepositiontaking_8 <> @mlivepositiontaking_8_old or

			@v2mpositiontaking_1 <> @v2mpositiontaking_1_old or
			@v2mpositiontaking_2 <> @v2mpositiontaking_2_old or
			@v2mpositiontaking_3 <> @v2mpositiontaking_3_old or
			@v2mpositiontaking_7 <> @v2mpositiontaking_7_old or
			@v2mpositiontaking_8 <> @v2mpositiontaking_8_old or
	--        @v2mpositiontaking_9 <> @v2mpositiontaking_9_old or
			@v2mpositiontaking_20 <> @v2mpositiontaking_20_old or

			@v3mpositiontaking_1 <> @v3mpositiontaking_1_old or
			@v3mpositiontaking_2 <> @v3mpositiontaking_2_old or
			@v3mpositiontaking_3 <> @v3mpositiontaking_3_old or
			@v3mpositiontaking_20 <> @v3mpositiontaking_20_old or

			@v5mpositiontaking_1 <> @v5mpositiontaking_1_old or
			@v5mpositiontaking_2 <> @v5mpositiontaking_2_old or
			@v5mpositiontaking_3 <> @v5mpositiontaking_3_old or
			@v5mpositiontaking_20 <> @v5mpositiontaking_20_old or
			@v5mpositiontaking_9999 <> @v5mpositiontaking_9999_old or

			@v8mpositiontaking_1 <> @v8mpositiontaking_1_old or
			@v8mpositiontaking_3 <> @v8mpositiontaking_3_old or
			@v8mpositiontaking_20 <> @v8mpositiontaking_20_old or

			@v10mpositiontaking_1 <> @v10mpositiontaking_1_old or
			@v10mpositiontaking_2 <> @v10mpositiontaking_2_old or
			@v10mpositiontaking_3 <> @v10mpositiontaking_3_old or
			@v10mpositiontaking_20 <> @v10mpositiontaking_20_old or

			@v11mpositiontaking_1 <> @v11mpositiontaking_1_old or
			@v11mpositiontaking_20 <> @v11mpositiontaking_20_old or

			@v99mpositiontaking_1 <> @v99mpositiontaking_1_old or
			@v99mpositiontaking_2 <> @v99mpositiontaking_2_old or
			@v99mpositiontaking_3 <> @v99mpositiontaking_3_old or
			@v99mpositiontaking_20 <> @v99mpositiontaking_20_old or
	        
			-- mixed sports
			@v99mpositiontaking_9 <> @v99mpositiontaking_9_old or
			@v154mpositiontaking_20 <> @v154mpositiontaking_20_old or

			-- number game
			@v161mpositiontaking_81 <> @v161mpositiontaking_81_old or
			@v161mpositiontaking_83 <> @v161mpositiontaking_83_old or        
			@v161mpositiontaking_86 <> @v161mpositiontaking_86_old or
			@v161mpositiontaking_88 <> @v161mpositiontaking_88_old or
	        
			@v161mlivepositiontaking_85 <> @v161mlivepositiontaking_85_old or
			@v161mlivepositiontaking_86 <> @v161mlivepositiontaking_86_old or
			@v161mlivepositiontaking_87 <> @v161mlivepositiontaking_87_old or
			@v161mlivepositiontaking_89 <> @v161mlivepositiontaking_89_old or
			@v161mlivepositiontaking_90 <> @v161mlivepositiontaking_90_old or
			
			-- Outright PT for sports 
			@v2spositiontaking_10 <> @v2spositiontaking_10_old or
			@v3spositiontaking_10 <> @v3spositiontaking_10_old or
			@v5spositiontaking_10 <> @v5spositiontaking_10_old or
			@v8spositiontaking_10 <> @v8spositiontaking_10_old or
			@v10spositiontaking_10 <> @v10spositiontaking_10_old or
			@v11spositiontaking_10 <> @v11spositiontaking_10_old or
			@v99spositiontaking_10 <> @v99spositiontaking_10_old or
			
			@auto_v2spositiontaking_10 <> @auto_v2spositiontaking_10_old or
			@auto_v3spositiontaking_10 <> @auto_v3spositiontaking_10_old or
			@auto_v5spositiontaking_10 <> @auto_v5spositiontaking_10_old or
			@auto_v8spositiontaking_10 <> @auto_v8spositiontaking_10_old or
			@auto_v10spositiontaking_10 <> @auto_v10spositiontaking_10_old or
			@auto_v11spositiontaking_10 <> @auto_v11spositiontaking_10_old or
			@auto_v99spositiontaking_10 <> @auto_v99spositiontaking_10_old or
			
			@isauto_v2spositiontaking_10 <> @isauto_v2spositiontaking_10_old or
			@isauto_v3spositiontaking_10 <> @isauto_v3spositiontaking_10_old or
			@isauto_v5spositiontaking_10 <> @isauto_v5spositiontaking_10_old or
			@isauto_v8spositiontaking_10 <> @isauto_v8spositiontaking_10_old or
			@isauto_v10spositiontaking_10 <> @isauto_v10spositiontaking_10_old or
			@isauto_v11spositiontaking_10 <> @isauto_v11spositiontaking_10_old or
			@isauto_v99spositiontaking_10 <> @isauto_v99spositiontaking_10_old or
			
			@v2mpositiontaking_10 <> @v2mpositiontaking_10_old or
			@v3mpositiontaking_10 <> @v3mpositiontaking_10_old or
			@v5mpositiontaking_10 <> @v5mpositiontaking_10_old or
			@v8mpositiontaking_10 <> @v8mpositiontaking_10_old or
			@v10mpositiontaking_10 <> @v10mpositiontaking_10_old or
			@v11mpositiontaking_10 <> @v11mpositiontaking_10_old or
			@v99mpositiontaking_10 <> @v99mpositiontaking_10_old


		BEGIN
									EXEC dbo.Acc_CustomerUpdMaster_PositionTaking
				@custid = @custid,
				@spositiontaking_1 = @spositiontaking_1,
				@spositiontaking_2 = @spositiontaking_2,
				@spositiontaking_3 = @spositiontaking_3,
				@spositiontaking_4 = @spositiontaking_4,
				@spositiontaking_5 = @spositiontaking_5,
				@spositiontaking_6 = @spositiontaking_6,
				@spositiontaking_7 = @spositiontaking_7,
				@spositiontaking_8 = @spositiontaking_8,
				@spositiontaking_9 = @spositiontaking_9,
				@spositiontaking_10 = @spositiontaking_10,
				@spositiontaking_9999 = @spositiontaking_9999,
				@slivepositiontaking_1 = @slivepositiontaking_1,
				@slivepositiontaking_3 = @slivepositiontaking_3,
				@slivepositiontaking_7 = @slivepositiontaking_7,
				@slivepositiontaking_8 = @slivepositiontaking_8,
				@v2spositiontaking_1 = @v2spositiontaking_1,
				@v2spositiontaking_2 = @v2spositiontaking_2,
				@v2spositiontaking_3 = @v2spositiontaking_3,
				@v2spositiontaking_7 = @v2spositiontaking_7,
				@v2spositiontaking_8 = @v2spositiontaking_8,
	--            @v2spositiontaking_9 = @v2spositiontaking_9,
				@v2spositiontaking_20 = @v2spositiontaking_20,
				@v3spositiontaking_1 = @v3spositiontaking_1,
				@v3spositiontaking_2 = @v3spositiontaking_2,
				@v3spositiontaking_3 = @v3spositiontaking_3,
				@v3spositiontaking_20 = @v3spositiontaking_20,
				@v5spositiontaking_1 = @v5spositiontaking_1,
				@v5spositiontaking_2 = @v5spositiontaking_2,
				@v5spositiontaking_3 = @v5spositiontaking_3,
				@v5spositiontaking_20 = @v5spositiontaking_20,
				@v5spositiontaking_9999 = @v5spositiontaking_9999,
				@v8spositiontaking_1 = @v8spositiontaking_1,
				@v8spositiontaking_3 = @v8spositiontaking_3,
				@v8spositiontaking_20 = @v8spositiontaking_20,
				@v10spositiontaking_1 = @v10spositiontaking_1,
				@v10spositiontaking_2 = @v10spositiontaking_2,
				@v10spositiontaking_3 = @v10spositiontaking_3,
				@v10spositiontaking_20 = @v10spositiontaking_20,
				@v11spositiontaking_1 = @v11spositiontaking_1,
				@v11spositiontaking_20 = @v11spositiontaking_20,

				@v99spositiontaking_1 = @v99spositiontaking_1,
				@v99spositiontaking_2 = @v99spositiontaking_2,
				@v99spositiontaking_3 = @v99spositiontaking_3,
				@v99spositiontaking_20 = @v99spositiontaking_20,

				-- mixed sports
				@v99spositiontaking_9 = @v99spositiontaking_9,
				@v154spositiontaking_20 = @v154spositiontaking_20,

				-- number game
				@v161spositiontaking_81 = @v161spositiontaking_81,
				@v161spositiontaking_83 = @v161spositiontaking_83,            
				@v161spositiontaking_86 = @v161spositiontaking_86,
				@v161spositiontaking_88 = @v161spositiontaking_88,
				@v161slivepositiontaking_85 = @v161slivepositiontaking_85,
				@v161slivepositiontaking_86 = @v161slivepositiontaking_86,
				@v161slivepositiontaking_87 = @v161slivepositiontaking_87,
				@v161slivepositiontaking_89 = @v161slivepositiontaking_89,
				@v161slivepositiontaking_90 = @v161slivepositiontaking_90,

				@UpdateMultiple = @UpdateMultiple,
				@UpdatePositiontaking = @UpdatePositiontaking,
				@UpdatePositiontakingv2 = @UpdatePositiontakingv2,
				@UpdatePositiontakingv3 = @UpdatePositiontakingv3,
				@UpdatePositiontakingv5 = @UpdatePositiontakingv5,
				@UpdatePositiontakingv8 = @UpdatePositiontakingv8,
				
				@UpdatePositiontakingv10 = @UpdatePositiontakingv10,
				
				@UpdatePositiontakingv11 = @UpdatePositiontakingv11,
	            
				@UpdatePositiontakingv99 = @UpdatePositiontakingv99,
	            
				---- mixed sports
				@UpdatePositiontakingv99MP = @UpdatePositiontakingv99MP,
				@UpdatePositiontakingv154 = @UpdatePositiontakingv154,

				-- number game
				@UpdatePositiontakingv161 = @UpdatePositiontakingv161,

				@auto_spositiontaking_1 = @auto_spositiontaking_1,
				@auto_spositiontaking_2 = @auto_spositiontaking_2,
				@auto_spositiontaking_3 = @auto_spositiontaking_3,
				@auto_spositiontaking_4 = @auto_spositiontaking_4,
				@auto_spositiontaking_5 = @auto_spositiontaking_5,
				@auto_spositiontaking_6 = @auto_spositiontaking_6,
				@auto_spositiontaking_7 = @auto_spositiontaking_7,
				@auto_spositiontaking_8 = @auto_spositiontaking_8,
				@auto_spositiontaking_9 = @auto_spositiontaking_9,
				@auto_spositiontaking_10 = @auto_spositiontaking_10,
				@auto_spositiontaking_9999 = @auto_spositiontaking_9999,
				@auto_slivepositiontaking_1 = @auto_slivepositiontaking_1,
				@auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
				@auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
				@auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
				@auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
				@auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
				@auto_v2spositiontaking_3 = @auto_v2spositiontaking_3,
				@auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
				@auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,
	--            @auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
				@auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
				@auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
				@auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
				@auto_v3spositiontaking_3 = @auto_v3spositiontaking_3,
				@auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,
				@auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
				@auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
				@auto_v5spositiontaking_3 = @auto_v5spositiontaking_3,
				@auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
				@auto_v5spositiontaking_9999 = @auto_v5spositiontaking_9999,
				@auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
				@auto_v8spositiontaking_3 = @auto_v8spositiontaking_3,
				@auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,
				@auto_v10spositiontaking_1 = @auto_v10spositiontaking_1,
				@auto_v10spositiontaking_2 = @auto_v10spositiontaking_2,
				@auto_v10spositiontaking_3 = @auto_v10spositiontaking_3,
				@auto_v10spositiontaking_20 = @auto_v10spositiontaking_20,
				@auto_v11spositiontaking_1 = @auto_v11spositiontaking_1,
				@auto_v11spositiontaking_20 = @auto_v11spositiontaking_20,

				@auto_v99spositiontaking_1 = @auto_v99spositiontaking_1,
				@auto_v99spositiontaking_2 = @auto_v99spositiontaking_2,
				@auto_v99spositiontaking_3 = @auto_v99spositiontaking_3,
				@auto_v99spositiontaking_20 = @auto_v99spositiontaking_20,

				-- mixed sports
				@auto_v99spositiontaking_9 = @auto_v99spositiontaking_9,
				@auto_v154spositiontaking_20 = @auto_v154spositiontaking_20,
	    
				-- number game
				@auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
				@auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,            
				@auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
				@auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
				@auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
				@auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
				@auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
				@auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
				@auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,

				@updateallmembers = @updateallmembers,
				@newspositiontaking = @newspositiontaking,
				@isauto_spositiontaking_1 = @isauto_spositiontaking_1,
				@isauto_spositiontaking_2 = @isauto_spositiontaking_2,
				@isauto_spositiontaking_3 = @isauto_spositiontaking_3,
				@isauto_spositiontaking_4 = @isauto_spositiontaking_4,
				@isauto_spositiontaking_5 = @isauto_spositiontaking_5,
				@isauto_spositiontaking_6 = @isauto_spositiontaking_6,
				@isauto_spositiontaking_7 = @isauto_spositiontaking_7,
				@isauto_spositiontaking_8 = @isauto_spositiontaking_8,
				@isauto_spositiontaking_9 = @isauto_spositiontaking_9,
				@isauto_spositiontaking_10 = @isauto_spositiontaking_10,
				@isauto_spositiontaking_9999 = @isauto_spositiontaking_9999,
				@isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1,
				@isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3,
				@isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7,
				@isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8,
				@isauto_v2spositiontaking_1 = @isauto_v2spositiontaking_1,
				@isauto_v2spositiontaking_2 = @isauto_v2spositiontaking_2,
				@isauto_v2spositiontaking_3 = @isauto_v2spositiontaking_3,
				@isauto_v2spositiontaking_7 = @isauto_v2spositiontaking_7,
				@isauto_v2spositiontaking_8 = @isauto_v2spositiontaking_8,
	--            @isauto_v2spositiontaking_9 = @isauto_v2spositiontaking_9,
				@isauto_v2spositiontaking_20 = @isauto_v2spositiontaking_20,
				@isauto_v3spositiontaking_1 = @isauto_v3spositiontaking_1,
				@isauto_v3spositiontaking_2 = @isauto_v3spositiontaking_2,
				@isauto_v3spositiontaking_3 = @isauto_v3spositiontaking_3,
				@isauto_v3spositiontaking_20 = @isauto_v3spositiontaking_20,
				@isauto_v5spositiontaking_1 = @isauto_v5spositiontaking_1,
				@isauto_v5spositiontaking_2 = @isauto_v5spositiontaking_2,
				@isauto_v5spositiontaking_3 = @isauto_v5spositiontaking_3,
				@isauto_v5spositiontaking_20 = @isauto_v5spositiontaking_20,
				@isauto_v5spositiontaking_9999 = @isauto_v5spositiontaking_9999,
				@isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,
				@isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,
				@isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,
				@isauto_v10spositiontaking_1 = @isauto_v10spositiontaking_1,
				@isauto_v10spositiontaking_2 = @isauto_v10spositiontaking_2,
				@isauto_v10spositiontaking_3 = @isauto_v10spositiontaking_3,
				@isauto_v10spositiontaking_20 = @isauto_v10spositiontaking_20,
				@isauto_v11spositiontaking_1 = @isauto_v11spositiontaking_1,
				@isauto_v11spositiontaking_20 = @isauto_v11spositiontaking_20,

				@isauto_v99spositiontaking_1 = @isauto_v99spositiontaking_1,
				@isauto_v99spositiontaking_2 = @isauto_v99spositiontaking_2,
				@isauto_v99spositiontaking_3 = @isauto_v99spositiontaking_3,
				@isauto_v99spositiontaking_20 = @isauto_v99spositiontaking_20,
	        
				-- mixed sports
				@isauto_v99spositiontaking_9 = @isauto_v99spositiontaking_9,
				@isauto_v154spositiontaking_20 = @isauto_v154spositiontaking_20,

				-- number game
				@isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,
				@isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,            
				@isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
				@isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
				@isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
				@isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
				@isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
				@isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
				@isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,

				@mpositiontaking_1 = @mpositiontaking_1,
				@mpositiontaking_2 = @mpositiontaking_2,
				@mpositiontaking_3 = @mpositiontaking_3,
				@mpositiontaking_4 = @mpositiontaking_4,
				@mpositiontaking_5 = @mpositiontaking_5,
				@mpositiontaking_6 = @mpositiontaking_6,
				@mpositiontaking_7 = @mpositiontaking_7,
				@mpositiontaking_8 = @mpositiontaking_8,
				@mpositiontaking_9 = @mpositiontaking_9,
				@mpositiontaking_10 = @mpositiontaking_10,
				@mpositiontaking_9999 = @mpositiontaking_9999,
				@mlivepositiontaking_1 = @mlivepositiontaking_1,
				@mlivepositiontaking_3 = @mlivepositiontaking_3,
				@mlivepositiontaking_7 = @mlivepositiontaking_7,
				@mlivepositiontaking_8 = @mlivepositiontaking_8,
				@v2mpositiontaking_1 = @v2mpositiontaking_1,
				@v2mpositiontaking_2 = @v2mpositiontaking_2,
				@v2mpositiontaking_3 = @v2mpositiontaking_3,
				@v2mpositiontaking_7 = @v2mpositiontaking_7,
				@v2mpositiontaking_8 = @v2mpositiontaking_8,
	--            @v2mpositiontaking_9 = @v2mpositiontaking_9,
				@v2mpositiontaking_20 = @v2mpositiontaking_20,
				@v3mpositiontaking_1 = @v3mpositiontaking_1,
				@v3mpositiontaking_2 = @v3mpositiontaking_2,
				@v3mpositiontaking_3 = @v3mpositiontaking_3,
				@v3mpositiontaking_20 = @v3mpositiontaking_20,
				@v5mpositiontaking_1 = @v5mpositiontaking_1,
				@v5mpositiontaking_2 = @v5mpositiontaking_2,
				@v5mpositiontaking_3 = @v5mpositiontaking_3,
				@v5mpositiontaking_20 = @v5mpositiontaking_20,
				@v5mpositiontaking_9999 = @v5mpositiontaking_9999,
				@v8mpositiontaking_1 = @v8mpositiontaking_1,
				@v8mpositiontaking_3 = @v8mpositiontaking_3,
				@v8mpositiontaking_20 = @v8mpositiontaking_20,
				@v10mpositiontaking_1 = @v10mpositiontaking_1,
				@v10mpositiontaking_2 = @v10mpositiontaking_2,
				@v10mpositiontaking_3 = @v10mpositiontaking_3,
				@v10mpositiontaking_20 = @v10mpositiontaking_20,
				@v11mpositiontaking_1 = @v11mpositiontaking_1,
				@v11mpositiontaking_20 = @v11mpositiontaking_20,

				@v99mpositiontaking_1 = @v99mpositiontaking_1,
				@v99mpositiontaking_2 = @v99mpositiontaking_2,
				@v99mpositiontaking_3 = @v99mpositiontaking_3,
				@v99mpositiontaking_20 = @v99mpositiontaking_20,

				-- mixed sports
				@v99mpositiontaking_9 = @v99mpositiontaking_9,
				@v154mpositiontaking_20 = @v154mpositiontaking_20,

				-- number game
				@v161mpositiontaking_81 = @v161mpositiontaking_81,
				@v161mpositiontaking_83 = @v161mpositiontaking_83,            
				@v161mpositiontaking_86 = @v161mpositiontaking_86,
				@v161mpositiontaking_88 = @v161mpositiontaking_88,
				@v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
				@v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
				@v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
				@v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
				@v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,

				-- Outright PT for sports
				@v2spositiontaking_10 = @v2spositiontaking_10,
				@v3spositiontaking_10 = @v3spositiontaking_10,
				@v5spositiontaking_10 = @v5spositiontaking_10,
				@v8spositiontaking_10 = @v8spositiontaking_10,
				@v10spositiontaking_10 = @v10spositiontaking_10,
				@v11spositiontaking_10 = @v11spositiontaking_10,
				@v99spositiontaking_10 = @v99spositiontaking_10,
				
				@auto_v2spositiontaking_10 = @auto_v2spositiontaking_10,
				@auto_v3spositiontaking_10 = @auto_v3spositiontaking_10,
				@auto_v5spositiontaking_10 = @auto_v5spositiontaking_10,
				@auto_v8spositiontaking_10 = @auto_v8spositiontaking_10,
				@auto_v10spositiontaking_10 = @auto_v10spositiontaking_10,
				@auto_v11spositiontaking_10 = @auto_v11spositiontaking_10,
				@auto_v99spositiontaking_10 = @auto_v99spositiontaking_10,
				
				@isauto_v2spositiontaking_10 = @isauto_v2spositiontaking_10,
				@isauto_v3spositiontaking_10 = @isauto_v3spositiontaking_10,
				@isauto_v5spositiontaking_10 = @isauto_v5spositiontaking_10,
				@isauto_v8spositiontaking_10 = @isauto_v8spositiontaking_10,
				@isauto_v10spositiontaking_10 = @isauto_v10spositiontaking_10,
				@isauto_v11spositiontaking_10 = @isauto_v11spositiontaking_10,
				@isauto_v99spositiontaking_10 = @isauto_v99spositiontaking_10,

				@v2mpositiontaking_10 = @v2mpositiontaking_10,
				@v3mpositiontaking_10 = @v3mpositiontaking_10,
				@v5mpositiontaking_10 = @v5mpositiontaking_10,
				@v8mpositiontaking_10 = @v8mpositiontaking_10,
				@v10mpositiontaking_10 = @v10mpositiontaking_10,
				@v11mpositiontaking_10 = @v11mpositiontaking_10,
				@v99mpositiontaking_10 = @v99mpositiontaking_10,
				
				@SubAccID = @SubAccID,
				@UserID = @UserID,
				@Language = @Language,
				@IP = @IP,
				@ErrCode = @ErrCode_cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
		BEGIN
			Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
		END
	END
END
GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_All] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_All] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_All] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_All] TO [bodbExtAccNet]
GO 
