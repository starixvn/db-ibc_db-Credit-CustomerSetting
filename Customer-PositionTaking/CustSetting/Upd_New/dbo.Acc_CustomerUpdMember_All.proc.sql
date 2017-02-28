ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_All]  
	@custid INT,--memberid  

	@firstname NVARCHAR(50),  
	@lastname NVARCHAR(50),  
	@phone NVARCHAR(50),  
	@mobilephone NVARCHAR(50),  
	@email NVARCHAR(50) = NULL,  
	@fax NVARCHAR(50),  

	@UpdateMultiple BIT = 0,  

	@playerdiscount DECIMAL(9,8),  
	@playerdiscountcs DECIMAL(9,8),  
	@playerdiscount1x2 DECIMAL(9,8)=0,  
	@playerdiscountnumber DECIMAL(9,8)=0,  
	@playerdiscountHRFixedOdds decimal(9,8)=0,
	@playerdiscountMyanmarOdds DECIMAL(9,8)=0, -- MyanmarOdds
	
	@UpdateCommission BIT = 1,  

	@MinBet MONEY,  
	@MaxBet MONEY,  
	@MaxPerMatch MONEY,  

	@MinBetv2 MONEY,  
	@MaxBetv2 MONEY,  
	@MaxPerMatchv2 MONEY,  

	@MinBetv3 MONEY,  
	@MaxBetv3 MONEY,  
	@MaxPerMatchv3 MONEY,  

	@MinBetv5 MONEY,  
	@MaxBetv5 MONEY,  
	@MaxPerMatchv5 MONEY,  

	@MinBetv8 MONEY,  
	@MaxBetv8 MONEY,  
	@MaxPerMatchv8 MONEY,  

	@MinBetv10 MONEY,  
	@MaxBetv10 MONEY,  
	@MaxPerMatchv10 MONEY,  

	@MinBetv11 MONEY,  
	@MaxBetv11 MONEY,  
	@MaxPerMatchv11 MONEY,  

	@MinBetv99 MONEY,  
	@MaxBetv99 MONEY,  
	@MaxPerMatchv99 MONEY,  

	--Mix Parlay Mixed Sports  
	@MinBetv99MP MONEY,  
	@MaxBetv99MP MONEY,  
	@MaxPerMatchv99MP MONEY,  
	
	--Mix Parlay Mixed Sports  
	@MinBetv1MP MONEY,  
	@MaxBetv1MP MONEY,  
	@MaxPerMatchv1MP MONEY,  
	
	--HR Fixed Odds
	@MinBetv154 MONEY = 0,
	@MaxBetv154 MONEY = 0,
	@MaxPerMatchv154 MONEY = 0,
	
	--Number Game  
	@MinBetv161 MONEY,  
	@MaxBetv161 MONEY,  
	@MaxPerMatchv161 MONEY,  

	@MaxPerBallv161 money = 0,

	@UpdateMinMaxBet BIT = 1,   
	@UpdateMinMaxBetv2 BIT = 1,   
	@UpdateMinMaxBetv3 BIT = 1,   
	@UpdateMinMaxBetv5 BIT = 1,   
	@UpdateMinMaxBetv8 BIT = 1,   
	@UpdateMinMaxBetv10 BIT = 1,  
	@UpdateMinMaxBetv11 BIT = 1,  
	@UpdateMinMaxBetv99 BIT = 1,  

	@UpdateMinMaxBetv99MP BIT = 1,  
	@UpdateMinMaxBetv1MP BIT = 1,
	@UpdateMinMaxBetv154 bit = 1,
	@UpdateMinMaxBetv161 BIT = 1,  

	@credit MONEY,  

	@closed BIT,  
	@Suspended bit,   
	@UpdateClosed BIT = 1,  
	@UpdateSuspended BIT = 1,  
	@disCasino bit = 0,  

	@apositiontaking_1 SMALLMONEY,  
	@apositiontaking_2 SMALLMONEY,  
	@apositiontaking_3 SMALLMONEY,  
	@apositiontaking_4 SMALLMONEY,  
	@apositiontaking_5 SMALLMONEY,  
	@apositiontaking_6 SMALLMONEY,  
	@apositiontaking_7 SMALLMONEY,  
	@apositiontaking_8 SMALLMONEY,  
	@apositiontaking_9 SMALLMONEY,  
	@apositiontaking_10 SMALLMONEY, 
	@apositiontaking_9999 SMALLMONEY = 0,   

	@alivepositiontaking_1 SMALLMONEY,  
	@alivepositiontaking_3 SMALLMONEY,  
	@alivepositiontaking_7 SMALLMONEY,  
	@alivepositiontaking_8 SMALLMONEY,  

	@v2apositiontaking_1 SMALLMONEY,  
	@v2apositiontaking_2 SMALLMONEY,  
	@v2apositiontaking_3 SMALLMONEY,  
	@v2apositiontaking_7 SMALLMONEY,  
	@v2apositiontaking_8 SMALLMONEY,  
	--@v2apositiontaking_9 SMALLMONEY,  
	@v2apositiontaking_20 SMALLMONEY,  

	@v3apositiontaking_1 SMALLMONEY,  
	@v3apositiontaking_2 SMALLMONEY,  
	@v3apositiontaking_3 SMALLMONEY,  
	@v3apositiontaking_20 SMALLMONEY,  

	@v5apositiontaking_1 SMALLMONEY,  
	@v5apositiontaking_2 SMALLMONEY,  
	@v5apositiontaking_3 SMALLMONEY,  
	@v5apositiontaking_20 SMALLMONEY,
	@v5apositiontaking_9999 SMALLMONEY = 0,  

	@v8apositiontaking_1 SMALLMONEY,  
	@v8apositiontaking_3 SMALLMONEY,  
	@v8apositiontaking_20 SMALLMONEY,  

	@v10apositiontaking_1 SMALLMONEY,  
	@v10apositiontaking_2 SMALLMONEY,  
	@v10apositiontaking_3 SMALLMONEY,  
	@v10apositiontaking_20 SMALLMONEY,  

	@v11apositiontaking_1 SMALLMONEY,  
	@v11apositiontaking_20 SMALLMONEY,  
	  
	@v99apositiontaking_1 SMALLMONEY,  
	@v99apositiontaking_2 SMALLMONEY,  
	@v99apositiontaking_3 SMALLMONEY,  
	@v99apositiontaking_9 SMALLMONEY,  
	@v99apositiontaking_20 SMALLMONEY,  

	--HR Fixed Odds
	@v154apositiontaking_20 SMALLMONEY = 0,
	
	--v161  
	@v161apositiontaking_81 smallmoney,   
	@v161apositiontaking_83 smallmoney,       
	@v161apositiontaking_86 smallmoney,   
	@v161apositiontaking_88 smallmoney = 0,	
	@v161alivepositiontaking_85 smallmoney,  
	@v161alivepositiontaking_86 smallmoney,  
	@v161alivepositiontaking_87 smallmoney,  
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0,

	-- Outright PT for sports
	
	@v2apositiontaking_10 SMALLMONEY, 
	@v3apositiontaking_10 SMALLMONEY, 
	@v5apositiontaking_10 SMALLMONEY, 
	@v8apositiontaking_10 SMALLMONEY, 
	@v10apositiontaking_10 SMALLMONEY, 
	@v11apositiontaking_10 SMALLMONEY, 
	@v99apositiontaking_10 SMALLMONEY, 

	@UpdatePositiontaking BIT = 1,   
	@UpdatePositiontakingv2 BIT = 1,  
	@UpdatePositiontakingv3 BIT = 1,  
	@UpdatePositiontakingv5 BIT = 1,  
	@UpdatePositiontakingv8 BIT = 1,  
	@UpdatePositiontakingv10 BIT = 1,  
	@UpdatePositiontakingv11 BIT = 1,  
	@UpdatePositiontakingv99 BIT = 1,  
	@UpdatePositiontakingv99MP BIT = 1,  
	@UpdatePositiontakingv1MP BIT = 1,  
	@UpdatePositiontakingv154 BIT = 1,
	@UpdatePositiontakingv161 BIT = 1,  

	@UserID INT,    

	@IP varchar(15)='',   
	@Language VARCHAR(2)= 'E',  

	@SubAccID INT = 0, --Sub-AccountID  
	@Username varchar(30) = '' OUTPUT,  
	@ErrCode varchar(300) = '' OUTPUT,  
	@ErrMsg nvarchar(4000) = '' OUTPUT  
AS  

--@Source Control  
/*  
Created: 20080514@Thien  
Task : Update member  
DB: DBCUST/CUSTDB
Original: Acc_CustomerUpdEditCustomer_Ag  
  
Revisions:  
    - 20081023@Phuc: Add new sporttype 201, bettype 3, hard code copy min/max/maxperbet/PT for 201 from 2 sporttype   
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.  
 - 20090317@Phuc: disable Financial.  
 - 20090320@PhuongDao: Remove the input param @IsUpdDownline  
    - 20090424@Phuc:Separate finance sporttype(201).  
    - 20090430@Kiwi: Add checking IF @UpdateSuspended = 1 for updating multiple customer.  
    - 20090514@PhuongDao: Add 1x2 Commission  
 - 20090703@Phuc: enrich error message.(-101: general info, -102: closed, -103: suspended, -104: credit, -105: commission, -106: min/max bet, -107: positiontaking  
 - 20090801@Shifu: check disabled user  
 - 20091125@Terry: Check disabled casino  
 - 20100728@Kiwi: grant execute permission to [bodbExtAccNet]  
 - 20100830@Henry: Add Number Game + Mix Parlay Mixed Sports  
 - 20101028@Lukas: Add max per ball (number game)
 - 20110801@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
 - 20110831@Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
 - 20110709@Johnson: Change to use new server BD053 instead DB052
 - 20120704@Johnson: Remove setting hard code of number group
 - 20130218@Dan: Change linked server DB053 to DBAGE
 - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
 - 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
 - 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
 - 20150904@Helen: commission setting for MO [Redmine #41470]
 - 20160104@Helen: Disallow SMA changes password or updates account status of members - [Redmine:#49967]  
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
	  
	EXEC Age_CustomerSelCheckBelongingByCustID
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
		@UserID = @UserID,  
		@disCasino = @disCasino,  
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
	DECLARE @Old_Suspended bit, @Old_Closed bit  

	SELECT  @Old_Suspended = reject,  
			@Old_Closed = closed
	FROM Custinfo WITH (NOLOCK)  
	WHERE CustID = @CustID  

	IF @Old_Closed = @closed
	BEGIN
		SET @UpdateClosed = 0
	END
		
	IF @Old_Suspended = @Suspended
	BEGIN
		SET @UpdateSuspended = 0
	END	
			
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
	 Declare @playerdiscount_old DECIMAL(9,8),  
	   @playerdiscountcs_old DECIMAL(9,8),  
	   @playerdiscount1x2_old DECIMAL(9,8),  
	   @playerdiscountHRFixedOdds_old decimal(9,8),
	   @playerdiscountnumber_old DECIMAL(9,8),  
	   @discountMyanmarOdds_old DECIMAL(9,8)=0,
	   @updatecomm_old bit  
	  
		select @playerdiscount_old = playerdiscount  
		from custsetting (nolock) where custid = @custid and sporttype = 1 and bettype = 1  

		select @playerdiscountcs_old = playerdiscount  
		from custsetting (nolock) where custid = @custid and sporttype = 1 and bettype = 4  

		select @playerdiscount1x2_old = playerdiscount  
		from custsetting (nolock) where custid = @custid and sporttype = 1 and bettype = 5  

		select @playerdiscountHRFixedOdds_old = playerdiscount
		from custsetting (nolock) where custid = @custid and sporttype = 154 and bettype = 20
		   
		select @playerdiscountnumber_old = playerdiscount  
		from custsetting3rd (nolock) where custid = @custid and sporttype = 161 and bettype = 81  

		
		-- For Myanmar Odds
		DECLARE @IsMyanmarOdds BIT = 0
		DECLARE @recommend INT = NULL
		
		SELECT @recommend = recommend
		FROM custInfo WITH (NOLOCK)
		WHERE custid = @custid

		SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
			
		IF @IsMyanmarOdds = 1
		BEGIN
			-- Get old value
			SET @discountMyanmarOdds_old = (SELECT playerdiscount FROM CustCommRate WITH (NOLOCK) WHERE CustId = @custid AND Sporttype = 1 AND Bettype = 301)
		END
			
		if @playerdiscount_old <> @playerdiscount or @playerdiscountcs_old <> @playerdiscountcs   
			or @playerdiscount1x2_old <> @playerdiscount1x2 or @playerdiscountnumber_old <> @playerdiscountnumber or @playerdiscountHRFixedOdds_old <> @playerdiscountHRFixedOdds
			OR (@IsMyanmarOdds = 1 AND @playerdiscountMyanmarOdds <> @discountMyanmarOdds_old)
			set @updatecomm_old = 1  
		else   
			set @updatecomm_old = 0 
	 
	 if @updatecomm_old <> 0  
	 begin  
	   EXEC dbo.Acc_CustomerUpdMember_Commission
	   @custid = @custid,  
	   @playerdiscount = @playerdiscount,  
	   @playerdiscountcs = @playerdiscountcs,  
	   @playerdiscount1x2 = @playerdiscount1x2,  
	   @playerdiscountHRFixedOdds = @playerdiscountHRFixedOdds,
	   @playerdiscountnumber = @playerdiscountnumber,  
	   -- For Myanmar Odds
	   @IsMyanmarOdds = @IsMyanmarOdds,
	   @discountMyanmarOdds = @playerdiscountMyanmarOdds,
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
	if  @UpdateMinMaxBet  = 1 or  
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
	 EXEC dbo.Acc_CustomerUpdMember_MinMaxBet   
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
	  @minbetv99MP = @minbetv99MP,  
	  @maxbetv99MP = @maxbetv99MP,  
	  @maxpermatchv99MP = @maxpermatchv99MP,  
	  
	  @minbetv1MP = @minbetv1MP,  
	  @maxbetv1MP = @maxbetv1MP,  
	  @maxpermatchv1MP = @maxpermatchv1MP,  
	  
	  @minbetv154 = @minbetv154,  
	  @maxbetv154 = @maxbetv154,  
	  @maxpermatchv154 = @maxpermatchv154,  
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
	  @ErrCode = @ErrCode_Cur OUTPUT,  
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
	if @UpdatePositiontaking   = 1  or  
	 @UpdatePositiontakingv2   = 1  or  
	 @UpdatePositiontakingv3   = 1  or  
	 @UpdatePositiontakingv5   = 1  or  
	 @UpdatePositiontakingv8   = 1  or  
	 @UpdatePositiontakingv10   = 1  or  
	 @UpdatePositiontakingv11   = 1  or  
	 @UpdatePositiontakingv99   = 1  or  

	 @UpdatePositiontakingv99MP  = 1 or  
	 
	 @UpdatePositiontakingv1MP  = 1 or  
	 
	 @UpdatePositiontakingv154   = 1  or  
	 @UpdatePositiontakingv161  = 1  
	BEGIN  
	 Select @ErrCode_Cur = 0, @ErrMsg_Cur = ''  
	   
	 --Check Old_PT <> New_PT  
	 Declare @apositiontaking_1_old SMALLMONEY,  
	  @apositiontaking_2_old SMALLMONEY,  
	  @apositiontaking_3_old SMALLMONEY,  
	  @apositiontaking_4_old SMALLMONEY,  
	  @apositiontaking_5_old SMALLMONEY,  
	  @apositiontaking_6_old SMALLMONEY,  
	  @apositiontaking_7_old SMALLMONEY,  
	  @apositiontaking_8_old SMALLMONEY,  
	  @apositiontaking_9_old SMALLMONEY,  
	  @apositiontaking_10_old SMALLMONEY,
	  @apositiontaking_9999_old SMALLMONEY,   
	    
	  @alivepositiontaking_1_old SMALLMONEY,  
	  @alivepositiontaking_3_old SMALLMONEY,  
	  @alivepositiontaking_7_old SMALLMONEY,  
	  @alivepositiontaking_8_old SMALLMONEY,  
	    
	  @v2apositiontaking_1_old SMALLMONEY,  
	  @v2apositiontaking_2_old SMALLMONEY,  
	  @v2apositiontaking_3_old SMALLMONEY,  
	  @v2apositiontaking_7_old SMALLMONEY,  
	  @v2apositiontaking_8_old SMALLMONEY,  
	  --@v2apositiontaking_9_old SMALLMONEY,  
	  @v2apositiontaking_20_old SMALLMONEY,  
	    
	  @v3apositiontaking_1_old SMALLMONEY,  
	  @v3apositiontaking_2_old SMALLMONEY,  
	  @v3apositiontaking_3_old SMALLMONEY,  
	  @v3apositiontaking_20_old SMALLMONEY,  
	  
	  @v5apositiontaking_1_old SMALLMONEY,  
	  @v5apositiontaking_2_old SMALLMONEY,  
	  @v5apositiontaking_3_old SMALLMONEY,  
	  @v5apositiontaking_20_old SMALLMONEY, 
	  @v5apositiontaking_9999_old SMALLMONEY,   
	  
	  @v8apositiontaking_1_old SMALLMONEY,  
	  @v8apositiontaking_3_old SMALLMONEY,  
	  @v8apositiontaking_20_old SMALLMONEY,  
	  
	  @v10apositiontaking_1_old SMALLMONEY,  
	  @v10apositiontaking_2_old SMALLMONEY,  
	  @v10apositiontaking_3_old SMALLMONEY,  
	  @v10apositiontaking_20_old SMALLMONEY,  
	  
	  @v11apositiontaking_1_old SMALLMONEY,  
	  @v11apositiontaking_20_old SMALLMONEY,  
	       
	  @v99apositiontaking_1_old SMALLMONEY,  
	  @v99apositiontaking_2_old SMALLMONEY,  
	  @v99apositiontaking_3_old SMALLMONEY,  
	  @v99apositiontaking_9_old SMALLMONEY,  
	  @v99apositiontaking_20_old SMALLMONEY,  
	    
	  @v154apositiontaking_20_old SMALLMONEY,  
	  
	  @v161apositiontaking_81_old SMALLMONEY,   
	  @v161apositiontaking_83_old SMALLMONEY,        
	  @v161apositiontaking_86_old SMALLMONEY,   
	  @v161apositiontaking_88_old SMALLMONEY,
	  @v161alivepositiontaking_85_old SMALLMONEY,  
	  @v161alivepositiontaking_86_old SMALLMONEY,  
	  @v161alivepositiontaking_87_old SMALLMONEY,  
	  @v161alivepositiontaking_89_old SMALLMONEY, 
	  @v161alivepositiontaking_90_old SMALLMONEY,
	  -- Outright PT sports
	  @v2apositiontaking_10_old SMALLMONEY,
	  @v3apositiontaking_10_old SMALLMONEY,
	  @v5apositiontaking_10_old SMALLMONEY,
	  @v8apositiontaking_10_old SMALLMONEY,
	  @v10apositiontaking_10_old SMALLMONEY,
	  @v11apositiontaking_10_old SMALLMONEY,
	  @v99apositiontaking_10_old SMALLMONEY
	  
	    
	    
	 --Get old_PT a2  
	 select @apositiontaking_1_old = apositiontaking, @alivepositiontaking_1_old = alivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1  
	 select @apositiontaking_3_old = apositiontaking, @alivepositiontaking_3_old = alivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1  
	 select @apositiontaking_7_old = apositiontaking, @alivepositiontaking_7_old = alivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1  
	 select @apositiontaking_8_old = apositiontaking, @alivepositiontaking_8_old = alivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1  
	 select @apositiontaking_2_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1  
	 select @apositiontaking_4_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1  
	  
	 select @apositiontaking_5_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1  
	 select @apositiontaking_6_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1  
	 select @apositiontaking_9_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1  
	 select @apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1  
	 -- Outright PT for sports
	 select @v2apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=2  
	 select @v3apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=3  
	 select @v5apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=5  
	 select @v8apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=8  
	 select @v10apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=10  
	 select @v11apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=11 
	 select @v99apositiontaking_10_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=99  
	 
	 select @apositiontaking_9999_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=1  
	  
	 select @v2apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=2  
	 select @v2apositiontaking_2_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=2  
	 select @v2apositiontaking_3_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=2  
	 select @v2apositiontaking_7_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=2  
	 select @v2apositiontaking_8_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=2  
	 --select @v2apositiontaking_9_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=2
	 select @v2apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=2  
	  
	 select @v3apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=3  
	 select @v3apositiontaking_2_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=3  
	 select @v3apositiontaking_3_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=3  
	 select @v3apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=3  
	  
	 select @v5apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=5  
	 select @v5apositiontaking_2_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=5  
	 select @v5apositiontaking_3_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=5  
	 select @v5apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=5  
	 select @v5apositiontaking_9999_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=5  
	  
	 select @v8apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8  
	 select @v8apositiontaking_3_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8  
	 select @v8apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8  
	  
	 select @v10apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=10  
	 select @v10apositiontaking_2_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=10  
	 select @v10apositiontaking_3_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=10  
	 select @v10apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=10  
	  
	 select @v11apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=11  
	 select @v11apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=11  
	  
	 select @v99apositiontaking_1_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=99  
	 select @v99apositiontaking_2_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=99  
	 select @v99apositiontaking_3_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=99  
	 select @v99apositiontaking_9_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=99  
	 select @v99apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=99  
	   
	 select @v154apositiontaking_20_old = apositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=154 
	  
	 select @v161apositiontaking_81_old = apositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161  
	 select @v161apositiontaking_83_old = apositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161  
	 select @v161apositiontaking_88_old = apositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161  
	 select @v161alivepositiontaking_85_old=alivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161  
	 select @v161apositiontaking_86_old = apositiontaking,@v161alivepositiontaking_86_old=alivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161  
	 select @v161alivepositiontaking_87_old=alivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161  
	 select @v161alivepositiontaking_89_old=alivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161  
	 select @v161alivepositiontaking_90_old=alivepositiontaking  from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161  
	   
	   
	 --Check Old_PT <> New_PT  
	 IF @apositiontaking_1 <> @apositiontaking_1_old or  
	   @apositiontaking_2 <> @apositiontaking_2_old or  
	   @apositiontaking_3 <> @apositiontaking_3_old or  
	   @apositiontaking_4 <> @apositiontaking_4_old or  
	   @apositiontaking_5 <> @apositiontaking_5_old or  
	   @apositiontaking_6 <> @apositiontaking_6_old or  
	   @apositiontaking_7 <> @apositiontaking_7_old or  
	   @apositiontaking_8 <> @apositiontaking_8_old or  
	   @apositiontaking_9 <> @apositiontaking_9_old or  
	   @apositiontaking_10 <> @apositiontaking_10_old or  
	   @apositiontaking_9999 <> @apositiontaking_9999_old or  
	   @alivepositiontaking_1 <> @alivepositiontaking_1_old or  
	   @alivepositiontaking_3 <> @alivepositiontaking_3_old or  
	   @alivepositiontaking_7 <> @alivepositiontaking_7_old or  
	   @alivepositiontaking_8 <> @alivepositiontaking_8_old or  
	   @v2apositiontaking_1 <> @v2apositiontaking_1_old or  
	   @v2apositiontaking_2 <> @v2apositiontaking_2_old or  
	   @v2apositiontaking_3 <> @v2apositiontaking_3_old or  
	   @v2apositiontaking_7 <> @v2apositiontaking_7_old or  
	   @v2apositiontaking_8 <> @v2apositiontaking_8_old or  
	   --@v2apositiontaking_9 <> @v2apositiontaking_9_old or  
	   @v2apositiontaking_20 <> @v2apositiontaking_20_old or  
	   @v3apositiontaking_1 <> @v3apositiontaking_1_old or  
	   @v3apositiontaking_2 <> @v3apositiontaking_2_old or  
	   @v3apositiontaking_3 <> @v3apositiontaking_3_old or  
	   @v3apositiontaking_20 <> @v3apositiontaking_20_old or  
	   @v5apositiontaking_1 <> @v5apositiontaking_1_old or  
	   @v5apositiontaking_2 <> @v5apositiontaking_2_old or  
	   @v5apositiontaking_3 <> @v5apositiontaking_3_old or  
	   @v5apositiontaking_20 <> @v5apositiontaking_20_old or  
	   @v5apositiontaking_9999 <> @v5apositiontaking_9999_old or  
	   @v8apositiontaking_1 <> @v8apositiontaking_1_old or  
	   @v8apositiontaking_3 <> @v8apositiontaking_3_old or  
	   @v8apositiontaking_20 <> @v8apositiontaking_20_old or  
	   @v10apositiontaking_1 <> @v10apositiontaking_1_old or  
	   @v10apositiontaking_2 <> @v10apositiontaking_2_old or  
	   @v10apositiontaking_3 <> @v10apositiontaking_3_old or  
	   @v10apositiontaking_20 <> @v10apositiontaking_20_old or  
	   @v11apositiontaking_1 <> @v11apositiontaking_1_old or  
	   @v11apositiontaking_20 <> @v11apositiontaking_20_old or  
	  
	   @v99apositiontaking_1 <> @v99apositiontaking_1_old or  
	   @v99apositiontaking_2 <> @v99apositiontaking_2_old or  
	   @v99apositiontaking_3 <> @v99apositiontaking_3_old or  
	   @v99apositiontaking_9 <> @v99apositiontaking_9_old or  
	   @v99apositiontaking_20 <> @v99apositiontaking_20_old or  

	   @v154apositiontaking_20 <> @v154apositiontaking_20_old or  
	     
	   @v161apositiontaking_81 <> @v161apositiontaking_81_old or  
	   @v161apositiontaking_83 <> @v161apositiontaking_83_old or    
	   @v161apositiontaking_86 <> @v161apositiontaking_86_old or  
	   @v161apositiontaking_88 <> @v161apositiontaking_88_old or
	   @v161alivepositiontaking_85 <> @v161alivepositiontaking_85_old or  
	   @v161alivepositiontaking_86 <> @v161alivepositiontaking_86_old or  
	   @v161alivepositiontaking_87 <> @v161alivepositiontaking_87_old or  
	   @v161alivepositiontaking_89 <> @v161alivepositiontaking_89_old or  
	   @v161alivepositiontaking_90 <> @v161alivepositiontaking_90_old or  
	   -- Outright PT for sports
	   @v2apositiontaking_10 <> @v2apositiontaking_10_old or  
	   @v3apositiontaking_10 <> @v3apositiontaking_10_old or  
	   @v5apositiontaking_10 <> @v5apositiontaking_10_old or  
	   @v8apositiontaking_10 <> @v8apositiontaking_10_old or  
	   @v10apositiontaking_10 <> @v10apositiontaking_10_old or  
	   @v11apositiontaking_10 <> @v11apositiontaking_10_old or  
	   @v99apositiontaking_10 <> @v99apositiontaking_10_old 
	   
	     

	 BEGIN  
		EXEC dbo.Acc_CustomerUpdMember_PositionTaking   
	   @custid = @custid,  
	   @apositiontaking_1 = @apositiontaking_1,  
	   @apositiontaking_2 = @apositiontaking_2,  
	   @apositiontaking_3 = @apositiontaking_3,  
	   @apositiontaking_4 = @apositiontaking_4,  
	   @apositiontaking_5 = @apositiontaking_5,  
	   @apositiontaking_6 = @apositiontaking_6,  
	   @apositiontaking_7 = @apositiontaking_7,  
	   @apositiontaking_8 = @apositiontaking_8,  
	   @apositiontaking_9 = @apositiontaking_9,  
	   @apositiontaking_10 = @apositiontaking_10,  
	   @apositiontaking_9999 = @apositiontaking_9999, 
	   @alivepositiontaking_1 = @alivepositiontaking_1,  
	   @alivepositiontaking_3 = @alivepositiontaking_3,  
	   @alivepositiontaking_7 = @alivepositiontaking_7,  
	   @alivepositiontaking_8 = @alivepositiontaking_8,  
	   @v2apositiontaking_1 = @v2apositiontaking_1,  
	   @v2apositiontaking_2 = @v2apositiontaking_2,  
	   @v2apositiontaking_3 = @v2apositiontaking_3,  
	   @v2apositiontaking_7 = @v2apositiontaking_7,  
	   @v2apositiontaking_8 = @v2apositiontaking_8,  
	   --@v2apositiontaking_9 = @v2apositiontaking_9,  
	   @v2apositiontaking_20 = @v2apositiontaking_20,  
	   @v3apositiontaking_1 = @v3apositiontaking_1,  
	   @v3apositiontaking_2 = @v3apositiontaking_2,  
	   @v3apositiontaking_3 = @v3apositiontaking_3,  
	   @v3apositiontaking_20 = @v3apositiontaking_20,  
	   @v5apositiontaking_1 = @v5apositiontaking_1,  
	   @v5apositiontaking_2 = @v5apositiontaking_2,  
	   @v5apositiontaking_3 = @v5apositiontaking_3,  
	   @v5apositiontaking_20 = @v5apositiontaking_20,  
	   @v5apositiontaking_9999 = @v5apositiontaking_9999,
	   @v8apositiontaking_1 = @v8apositiontaking_1,  
	   @v8apositiontaking_3 = @v8apositiontaking_3,  
	   @v8apositiontaking_20 = @v8apositiontaking_20,  
	   @v10apositiontaking_1 = @v10apositiontaking_1,  
	   @v10apositiontaking_2 = @v10apositiontaking_2,  
	   @v10apositiontaking_3 = @v10apositiontaking_3,  
	   @v10apositiontaking_20 = @v10apositiontaking_20,  
	   @v11apositiontaking_1 = @v11apositiontaking_1,  
	   @v11apositiontaking_20 = @v11apositiontaking_20,  
	     
	   @v99apositiontaking_1 = @v99apositiontaking_1,  
	   @v99apositiontaking_2 = @v99apositiontaking_2,  
	   @v99apositiontaking_3 = @v99apositiontaking_3,  
	   @v99apositiontaking_9 = @v99apositiontaking_9,  
	   @v99apositiontaking_20 = @v99apositiontaking_20,  

	   @v154apositiontaking_20 = @v154apositiontaking_20,  
	     
	   @v161apositiontaking_81 = @v161apositiontaking_81,  
	   @v161apositiontaking_83 = @v161apositiontaking_83,  
	   @v161apositiontaking_86 = @v161apositiontaking_86,  
	   @v161apositiontaking_88 = @v161apositiontaking_88,  
	   @v161alivepositiontaking_85 = @v161alivepositiontaking_85,  
	   @v161alivepositiontaking_86 = @v161alivepositiontaking_86,  
	   @v161alivepositiontaking_87 = @v161alivepositiontaking_87,  
	   @v161alivepositiontaking_89 = @v161alivepositiontaking_89,  
	   @v161alivepositiontaking_90 = @v161alivepositiontaking_90,  
	    
	    -- Outright PT for sports
	   @v2apositiontaking_10 = @v2apositiontaking_10,  
	   @v3apositiontaking_10 = @v3apositiontaking_10,  
	   @v5apositiontaking_10 = @v5apositiontaking_10,  
	   @v8apositiontaking_10 = @v8apositiontaking_10,  
	   @v10apositiontaking_10 = @v10apositiontaking_10,  
	   @v11apositiontaking_10 = @v11apositiontaking_10,  
	   @v99apositiontaking_10 = @v99apositiontaking_10,  
	     
	   @UpdateMultiple = @UpdateMultiple,  
	   @UpdatePositiontaking = @UpdatePositiontaking,  
	   @UpdatePositiontakingv2 = @UpdatePositiontakingv2,  
	   @UpdatePositiontakingv3 = @UpdatePositiontakingv3,  
	   @UpdatePositiontakingv5 = @UpdatePositiontakingv5,  
	   @UpdatePositiontakingv8 = @UpdatePositiontakingv8,  
	   @UpdatePositiontakingv10 = @UpdatePositiontakingv10,  
	   @UpdatePositiontakingv11 = @UpdatePositiontakingv11,  
	   @UpdatePositiontakingv99 = @UpdatePositiontakingv99,  
	   @UpdatePositiontakingv99MP = @UpdatePositiontakingv99MP,  
	   @UpdatePositiontakingv154 = @UpdatePositiontakingv154,  
	   @UpdatePositiontakingv161 = @UpdatePositiontakingv161,  
	   @UserID = @UserID,  
	   @IP = @IP,  
	   @Language = @Language,  
	   @SubAccID = @SubAccID,  
	   @ErrCode = @ErrCode_Cur OUTPUT,  
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
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_All] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_All] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_All] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_All] TO [bodbExtAccNet]
GO 
