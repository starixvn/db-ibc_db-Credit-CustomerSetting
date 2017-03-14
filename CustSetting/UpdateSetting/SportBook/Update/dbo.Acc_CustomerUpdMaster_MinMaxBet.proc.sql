ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_MinMaxBet]
	@custid int,-- masterid
	
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

	--- mix parlay of mixed sports
	@minbetv99mp money,
	@maxbetv99mp money,
	@maxpermatchv99mp money,
	
	--- mix parlay of mixed sports
	@minbetv1mp money,
	@maxbetv1mp money,
	@maxpermatchv1mp money,
	
	@MinBetv154 MONEY = 0,
	@MaxBetv154 MONEY = 0,
	@MaxPerMatchv154 MONEY = 0,
	
	-- number game
	@minbetv161 money,
	@maxbetv161 money,
	@maxpermatchv161 money,
	@MaxPerBallv161 money,

	@UpdateMultiple bit = 0,	
	
	@UpdateMinMaxBet bit = 1,
	@UpdateMinMaxBetv2 bit = 1,
	@UpdateMinMaxBetv3 bit = 1,
	@UpdateMinMaxBetv5 bit = 1,
	@UpdateMinMaxBetv8 bit = 1,
	@UpdateMinMaxBetv10 bit = 1,
	@UpdateMinMaxBetv11 bit = 1,
	@UpdateMinMaxBetv99 bit = 1,
	-- mix parlay of mixed sports
	@UpdateMinMaxBetv99MP bit = 1,
	
	@UpdateMinMaxBetv1MP bit = 1,
	
	@UpdateMinMaxBetv154 bit = 1,
	
	-- number game
	@UpdateMinMaxBetv161 bit = 1,
	
	@SubAccID int = 0, --Sub-AccountID	
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
as
--@Source Control
/*
Created: 20080515@Thien
Task : Update master's min/max bet/maxpermatch 
DB: DBTXN/bodb02
Original: [Acc_CustomerUpdMaster_MinMaxBet_xtest]

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100903@Lukas:	- Add mixed sports setting
						- Add Number game setting
	- 20101019@Henry: Record execution time
	- 20101027@Lukas: Add max per ball (number game)
	- 20110606@Amy: Write log old values
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
	- 20160712@Helen: Mixed Sports Parlay Min & Max Bet log is always written using OtherSports Min & Max Bet value when user update Bet Limit of other sports [Redmine: 60571]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	Declare 
		@MinMinBet money, @MaxMaxBet money,	@MaxMaxPerMatch money,
		@MinMinBetv2 money, @MaxMaxBetv2 money, @MaxMaxPerMatchv2 money,
		@MinMinBetv3 money, @MaxMaxBetv3 money, @MaxMaxPerMatchv3 money,
		@MinMinBetv5 money, @MaxMaxBetv5 money, @MaxMaxPerMatchv5 money,
		@MinMinBetv8 money, @MaxMaxBetv8 money, @MaxMaxPerMatchv8 money,
		@MinMinBetv10 money, @MaxMaxBetv10 money, @MaxMaxPerMatchv10 money,
		@MinMinBetv11 money, @MaxMaxBetv11 money, @MaxMaxPerMatchv11 money,
		--v151
		--@MinMinBetv151 money, @MaxMaxBetv151 money, @MaxMaxPerMatchv151 money,

		@MinMinBetv99 money, @MaxMaxBetv99 money, @MaxMaxPerMatchv99 money,
		@MinMinBetv99MP money, @MaxMaxBetv99MP money, @MaxMaxPerMatchv99MP money,
		
		@MinMinBetv1MP money, @MaxMaxBetv1MP money, @MaxMaxPerMatchv1MP money,
		
		@MinMinBetv154 money, @MaxMaxBetv154 money, @MaxMaxPerMatchv154 money,
		@MinMinBetv161 money, @MaxMaxBetv161 money, @MaxMaxPerMatchv161 money,
		@MaxMaxPerBallv161 money
		
	Declare 
		@Old_MinBet money, @Old_MaxBet money,	@Old_MaxPerMatch money,
		@Old_MinBetv2 money, @Old_MaxBetv2 money, @Old_MaxPerMatchv2 money,
		@Old_MinBetv3 money, @Old_MaxBetv3 money, @Old_MaxPerMatchv3 money,
		@Old_MinBetv5 money, @Old_MaxBetv5 money, @Old_MaxPerMatchv5 money,
		@Old_MinBetv8 money, @Old_MaxBetv8 money, @Old_MaxPerMatchv8 money,
		@Old_MinBetv10 money, @Old_MaxBetv10 money, @Old_MaxPerMatchv10 money,
		@Old_MinBetv11 money, @Old_MaxBetv11 money, @Old_MaxPerMatchv11 money,
		@Old_MinBetv99 money, @Old_MaxBetv99 money, @Old_MaxPerMatchv99 money,
		@Old_MinBetv99MP money, @Old_MaxBetv99MP money, @Old_MaxPerMatchv99MP money,
		
		@Old_MinBetv1MP money, @Old_MaxBetv1MP money, @Old_MaxPerMatchv1MP money,
		
		@Old_MinBetv154 money, @Old_MaxBetv154 money, @Old_MaxPerMatchv154 money,
		@Old_MinBetv161 money, @Old_MaxBetv161 money, @Old_MaxPerMatchv161 money,
		@Old_MaxPerBallv161 money

		
	declare @ErrAcc varchar(4000), @ErrType varchar(4000),
			@UserName varchar(30), @srecommend int
			
	Select @UserName = username, @srecommend = srecommend
	from customer with (NOLOCK)
	where CustID = @CustID
	   
	EXEC Acc_CustomerSelMinMax @custid,
		@MinBet = @old_MinBet output, @MaxBet = @old_MaxBet output, @MaxPerMatch =@old_MaxPerMatch output,
		@MinBetv2 = @old_MinBetv2 output, @MaxBetv2 =@old_MaxBetv2 output, @MaxPerMatchv2 =@old_MaxPerMatchv2 output,
		@MinBetv3 = @old_MinBetv3 output, @MaxBetv3 =@old_MaxBetv3 output, @MaxPerMatchv3 =@old_MaxPerMatchv3 output,
		@MinBetv5 = @old_MinBetv5 output, @MaxBetv5 =@old_MaxBetv5 output, @MaxPerMatchv5 =@old_MaxPerMatchv5 output,
		@MinBetv8 = @old_MinBetv8 output, @MaxBetv8 =@old_MaxBetv8 output, @MaxPerMatchv8 =@old_MaxPerMatchv8 output,
		@MinBetv10 = @old_MinBetv10 output, @MaxBetv10 =@old_MaxBetv10 output, @MaxPerMatchv10 =@old_MaxPerMatchv10 output,
		@MinBetv11 = @old_MinBetv11 output, @MaxBetv11 =@old_MaxBetv11 output, @MaxPerMatchv11 =@old_MaxPerMatchv11 output,
		@MinBetv99 = @old_MinBetv99 output, @MaxBetv99 =@old_MaxBetv99 output, @MaxPerMatchv99 =@old_MaxPerMatchv99 output,
		@MinBetv99MP = @old_MinBetv99MP output, @MaxBetv99MP =@old_MaxBetv99MP output, @MaxPerMatchv99MP =@old_MaxPerMatchv99MP output,
		
		@MinBetv1MP = @old_MinBetv1MP output, @MaxBetv1MP =@old_MaxBetv1MP output, @MaxPerMatchv1MP =@old_MaxPerMatchv1MP output,
		
		@MinBetv154 = @old_MinBetv154 output, @MaxBetv154 = @old_MaxBetv154 output, @MaxPerMatchv154 =@old_MaxPerMatchv154 output,    
		@MinBetv161 = @old_MinBetv161 output, @MaxBetv161 =@old_MaxBetv161 output, @MaxPerMatchv161 =@old_MaxPerMatchv161 output, @MaxPerBallv161 =@old_MaxPerBallv161 output

	   
	IF 	@Old_MinBet = @MinBet AND @Old_MaxBet = @MaxBet AND	@Old_MaxPerMatch = @MaxPerMatch AND
		@Old_MinBetv2 = @MinBetv2 AND @Old_MaxBetv2 = @MaxBetv2 AND @Old_MaxPerMatchv2 = @MaxPerMatchv2 AND
		@Old_MinBetv3 = @MinBetv3 AND @Old_MaxBetv3 = @MaxBetv3 AND @Old_MaxPerMatchv3 = @MaxPerMatchv3 AND
		@Old_MinBetv5 = @MinBetv5 AND @Old_MaxBetv5 = @MaxBetv5 AND @Old_MaxPerMatchv5 = @MaxPerMatchv5 AND
		@Old_MinBetv8 = @MinBetv8 AND @Old_MaxBetv8 = @MaxBetv8 AND @Old_MaxPerMatchv8 = @MaxPerMatchv8 AND
		@Old_MinBetv10 = @MinBetv10 AND @Old_MaxBetv10 = @MaxBetv10 AND @Old_MaxPerMatchv10 = @MaxPerMatchv10 AND
		@Old_MinBetv11 = @MinBetv11 AND @Old_MaxBetv11 = @MaxBetv11 AND @Old_MaxPerMatchv11 = @MaxPerMatchv11 AND
		@Old_MinBetv99 = @MinBetv99 AND @Old_MaxBetv99 = @MaxBetv99 AND @Old_MaxPerMatchv99 = @MaxPerMatchv99 AND
		@Old_MinBetv99MP = @MinBetv99MP AND @Old_MaxBetv99MP = @MaxBetv99MP AND @Old_MaxPerMatchv99MP = @MaxPerMatchv99MP AND
		
		@Old_MinBetv1MP = @MinBetv1MP AND @Old_MaxBetv1MP = @MaxBetv1MP AND @Old_MaxPerMatchv1MP = @MaxPerMatchv1MP AND
		
		@Old_MinBetv154 = @MinBetv154 AND @Old_MaxBetv154 = @MaxBetv154 AND @Old_MaxPerMatchv154 = @MaxPerMatchv154 AND	
		@Old_MinBetv161 = @MinBetv161 AND @Old_MaxBetv161 = @MaxBetv161 AND @Old_MaxPerMatchv161 = @MaxPerMatchv161 AND
		@Old_MaxPerBallv161 = @MaxPerBallv161 RETURN

	if @UpdateMinMaxBet = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbet<0
			or @maxbet < 0
			or @maxpermatch <0
		BEGIN	 
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
						end, @ErrCode = 101
			return
		END
	END

	if @UpdateMinMaxBetv2 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv2 <0
			or @maxbetv2 <0
			or @maxpermatchv2 <0
		BEGIN	
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Basketball).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
						end, @ErrCode = 102
			return
		END
	END

	if @UpdateMinMaxBetv3 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv3 <0
			or @maxbetv3 <0
			or @maxpermatchv3 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Football).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
						end, @ErrCode = 103
			return
		END
	END

	if @UpdateMinMaxBetv5 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv5 <0
			or @maxbetv5 <0
			or @maxpermatchv5 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Tennis).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
						end, @ErrCode = 104
			return
		END
	END

	if @UpdateMinMaxBetv8 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv8 <0
			or @maxbetv8 <0
			or @maxpermatchv8 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Baseball).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
						end, @ErrCode = 105
			return
		END
	END

	if @UpdateMinMaxBetv10 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv10 <0
			or @maxbetv10 <0
			or @maxpermatchv10 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Golf).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
						end, @ErrCode = 106
			return
		END
	END

	if @UpdateMinMaxBetv11 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv11 <0
			or @maxbetv11 <0
			or @maxpermatchv11 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Motosports).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end, @ErrCode = 107
			return
		END
	END

	--v151
	--if @UpdateMinMaxBetv151 = 1 or @UpdateMultiple = 0
	--BEGIN
		--if 
			--@minbetv151 <0
			--or @maxbetv151 <0
			--or @maxpermatchv151 <0
		--BEGIN
			--Select @ErrMsg = 	case @Language 
								--when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Financial).'
								--when 'CS' then N'最低投注/最高投注/单场最高投注不正确(于金融).'
								--when 'CT' then N'最低投注/最高投注/單場最高投注不正確(於金融).'
								--when 'TH' then N'การกำหนดจำนวนเงินสำหรับการวางเดิมพันต่ำสุด/ สูงสุด/สูงสดต่อรายการไม่ถูกต้อง (สำหรับการเงิน).'
								--when 'J' then N'Wrong Min bet/ Max bet/ Max per match (for Financial).'
								--else N'Wrong Min bet/ Max bet/ Max per match (for Financial).'
						--end, @ErrCode = 108
			--return
		--END
	--END

	if @UpdateMinMaxBetv99 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv99 <0
			or @maxbetv99 <0
			or @maxpermatchv99 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Other Sports).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
						end, @ErrCode = 109
			return
		END
	END

	--- mix parlay of mixed sports
	if @UpdateMinMaxBetv99MP = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv99mp < 0
			or @maxbetv99mp < 0
			or @maxpermatchv99mp < 0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Mix Sports Parlay).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
						end, @ErrCode = 201
			return
		END
	END

	if @UpdateMinMaxBetv1MP = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv1mp < 0
			or @maxbetv1mp < 0
			or @maxpermatchv1mp < 0
		BEGIN	 
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
						end, @ErrCode = 101
			return
		END
	END

	
	if @UpdateMinMaxBetv154 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv154 <0
			or @maxbetv154 <0
			or @maxpermatchv154 <0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Other Sports).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
						end, @ErrCode = 110
			return
		END
	END

	--- number game
	if @UpdateMinMaxBetv161 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv161 < 0
			or @maxbetv161 < 0
			or @maxpermatchv161 < 0
		BEGIN
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Number game).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end, @ErrCode = 202
			return
		END

		--- max per ball
		if @MaxPerBallv161 < 0
		begin
			Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong Max Per Ball (Number Game).'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10002,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
				end, @ErrCode = 202
			return
		end
	END

	---------------------------------------------------------
	if @UpdateMultiple = 0 or @UpdateMinMaxBet=1 
	BEGIN
		if 
		(@minbet<>0 and @maxbet <> 0 and  @minbet>@maxbet) 
		or (@maxbet<> 0 and @maxpermatch <> 0 and @maxbet>@maxpermatch) 
		or (@minbet <> 0 and @maxpermatch <> 0 and @minbet>@maxpermatch)
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
							end	, @ErrCode = 110
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv1MP=1 
	BEGIN
		if (@minbetv1mp <> 0 and @maxbetv1mp <> 0 and @minbetv1mp > @maxbetv1mp) 
		or (@maxbetv1mp <> 0 and @maxpermatchv1mp <> 0 and @maxbetv1mp > @maxpermatchv1mp)
		or (@minbetv1mp <> 0 and @maxpermatchv1mp <> 0 and @minbetv1mp > @maxpermatchv1mp) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
							end	, @ErrCode = 110
			return
		END
	END
	
	if @UpdateMultiple = 0 or @UpdateMinMaxBetv2=1 
	BEGIN
		if (@minbetv2 <> 0 and @maxbetv2 <> 0 and @minbetv2>@maxbetv2) 
		or (@maxbetv2 <> 0 and @maxpermatchv2 <> 0 and @maxbetv2>@maxpermatchv2)
		or (@minbetv2 <> 0 and @maxpermatchv2 <> 0 and @minbetv2>@maxpermatchv2) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end, @ErrCode = 111
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv3=1 
	BEGIN
		if (@minbetv3 <> 0 and @maxbetv3 <> 0 and @minbetv3>@maxbetv3) 
		or (@maxbetv3 <> 0 and @maxpermatchv3 <> 0 and @maxbetv3>@maxpermatchv3)
		or (@minbetv3 <> 0 and @maxpermatchv3 <> 0 and @minbetv3>@maxpermatchv3) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end, @ErrCode = 112
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv5=1 
	BEGIN
		if (@minbetv5 <> 0 and @maxbetv5 <> 0 and @minbetv5>@maxbetv5) 
		or (@maxbetv5 <> 0 and @maxpermatchv5 <> 0 and @maxbetv5>@maxpermatchv5)
		or (@minbetv5 <> 0 and @maxpermatchv5 <> 0 and @minbetv5>@maxpermatchv5) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end, @ErrCode = 113
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv8=1 
	BEGIN
		if (@minbetv8 <> 0 and @maxbetv8 <> 0 and @minbetv8>@maxbetv8) 
		or (@maxbetv8 <> 0 and @maxpermatchv8 <> 0 and @maxbetv8>@maxpermatchv8)
		or (@minbetv8 <> 0 and @maxpermatchv8 <> 0 and @minbetv8>@maxpermatchv8) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end, @ErrCode = 114	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv10=1 
	BEGIN
		if (@minbetv10 <> 0 and @maxbetv10 <> 0 and @minbetv10>@maxbetv10) 
		or (@maxbetv10 <> 0 and @maxpermatchv10 <> 0 and @maxbetv10>@maxpermatchv10)
		or (@minbetv10 <> 0 and @maxpermatchv10 <> 0 and @minbetv10>@maxpermatchv10) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end, @ErrCode = 115
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv11=1 
	BEGIN
		if (@minbetv11 <> 0 and @maxbetv11 <> 0 and @minbetv11>@maxbetv11) 
		or (@maxbetv11 <> 0 and @maxpermatchv11 <> 0 and @maxbetv11>@maxpermatchv11)
		or (@minbetv11 <> 0 and @maxpermatchv11 <> 0 and @minbetv11>@maxpermatchv11) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end, @ErrCode = 116
			return
		END
	END

	--v151
	--if @UpdateMultiple = 0 or @UpdateMinMaxBetv151=1 
	--BEGIN
		--if (@minbetv151 <> 0 and @maxbetv151 <> 0 and @minbetv151>@maxbetv151) 
		--or (@maxbetv151 <> 0 and @maxpermatchv151 <> 0 and @maxbetv151>@maxpermatchv151)
		--or (@minbetv151 <> 0 and @maxpermatchv151 <> 0 and @minbetv151>@maxpermatchv151) 
		--BEGIN
			--SELECT @ErrMsg =  @UserName + ': '+
							--case @Language 
								--when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Financial)'
								--when 'CS' then N'最低投注不能高于最高投注，最高投注不能高于单场最高投注设定(于金融)'
								--when 'CT' then N'最低投注不能高於最高投注,最高投注不能高於單場最高投注設定(於金融)'
								--when 'TH' then N'จำนวนเงินต่ำสุดที่วางเดิมพันได้ต้องน้อยกว่าจำนวนเงินสูงสุดในการวางเดิมพันและจำนวนเงินสูงสุดในการวางเดิมพันต้องน้อยกว่าจำนวนเงินสูงสุดของเงินเดิมพันต่อเกม (สำหรับการเงิน).'
								--when 'J' then N'Min bet must be less than max bet and max bet must be less than max bet per match (for Financial)'
								--else N'Min bet must be less than max bet and max bet must be less than max bet per match (for Financial)'
							--end, @ErrCode = 117
			--return
		--END
	--END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv99=1 
	BEGIN
		if (@minbetv99 <> 0 and @maxbetv99 <> 0 and @minbetv99>@maxbetv99) 
		or (@maxbetv99 <> 0 and @maxpermatchv99 <> 0 and @maxbetv99>@maxpermatchv99)
		or (@minbetv99 <> 0 and @maxpermatchv99 <> 0 and @minbetv99>@maxpermatchv99) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end, @ErrCode = 118
			return
		END
	END

	-- mix parlay of mixed sports
	if @UpdateMultiple = 0 or @UpdateMinMaxBetv99MP = 1 
	BEGIN
		if (@minbetv99mp <> 0 and @maxbetv99mp <> 0 and @minbetv99mp > @maxbetv99mp) 
		or (@maxbetv99mp <> 0 and @maxpermatchv99mp <> 0 and @maxbetv99mp > @maxpermatchv99mp)
		or (@minbetv99mp <> 0 and @maxpermatchv99mp <> 0 and @minbetv99mp > @maxpermatchv99mp) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							end, @ErrCode = 203
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv154=1 
	BEGIN
		if (@minbetv154 <> 0 and @maxbetv154 <> 0 and @minbetv154>@maxbetv154) 
		or (@maxbetv154 <> 0 and @maxpermatchv154 <> 0 and @maxbetv154>@maxpermatchv154)
		or (@minbetv154 <> 0 and @maxpermatchv154 <> 0 and @minbetv154>@maxpermatchv154) 
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end, @ErrCode = 118
			return
		END
	END

	-- number game
	if @UpdateMultiple = 0 or @UpdateMinMaxBetv161 = 1
	BEGIN
		if (@minbetv161 <> 0 and @maxbetv161 <> 0 and @minbetv161 > @maxbetv161) 
		or (@maxbetv161 <> 0 and @maxpermatchv161 <> 0 and @maxbetv161 > @maxpermatchv161)
		or (@minbetv161 <> 0 and @maxpermatchv161 <> 0 and @minbetv161 > @maxpermatchv161)
		BEGIN
			SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end, @ErrCode = 204
			return
		END
	END

	-------------------------------------------------
	Select @MaxMaxPerMatch = MaxPerMatch,
			@MaxMaxPerMatchv2 = MaxPerMatch2,
			@MaxMaxPerMatchv3 = MaxPerMatch3,
			@MaxMaxPerMatchv5 = MaxPerMatch5,
			@MaxMaxPerMatchv8 = MaxPerMatch8,
			@MaxMaxPerMatchv10 = MaxPerMatch10,
			@MaxMaxPerMatchv11 = MaxPerMatch11,
			--v151
			--@MaxMaxPerMatchv151 = MaxPerMatch151,
			@MaxMaxPerMatchv99 = MaxPerMatch99,
			@MaxMaxPerMatchv99MP = MaxPerMatch99MP,
			
			@MaxMaxPerMatchv1MP = MaxPerMatch1MP,
			
			@MaxMaxPerMatchv154 = MaxPerMatch154,
			@MaxMaxPerMatchv161 = MaxPerMatch161,
			@MaxMaxPerBallv161 = MaxPerBall161
	from custinfo with (NOLOCK) where custid = @srecommend

	---------------------------------------------------------
	Select 
		@MinMinBet = MinBet,
		@MaxMaxBet = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=1

	Select 
		@MinMinBetv2 = MinBet,
		@MaxMaxBetv2 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=2

	Select 
		@MinMinBetv3 = MinBet,
		@MaxMaxBetv3 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=3

	Select 
		@MinMinBetv5 = MinBet,
		@MaxMaxBetv5 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=5

	Select 
		@MinMinBetv8 = MinBet,
		@MaxMaxBetv8 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=8

	Select 
		@MinMinBetv10 = MinBet,
		@MaxMaxBetv10 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=10

	Select 
		@MinMinBetv11 = MinBet,
		@MaxMaxBetv11 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=11

	Select 
		@MinMinBetv99 = MinBet,
		@MaxMaxBetv99 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=1 and sporttype=99

	select 
		@MinMinBetv99MP = MinBet,
		@MaxMaxBetv99MP = MaxBet
	from custsetting with(nolock)
	where custid = @srecommend and bettype = 9 and sporttype = 99

	select 
		@MinMinBetv1MP = MinBet,
		@MaxMaxBetv1MP = MaxBet
	from custsetting with(nolock)
	where custid = @srecommend and bettype = 9 and sporttype = 1
	
	Select 
		@MinMinBetv154 = MinBet,
		@MaxMaxBetv154 = MaxBet
	From custsetting with (NOLOCK)
	where CustID = @srecommend and bettype=20 and sporttype=154

	select 
		@MinMinBetv161 = MinBet,
		@MaxMaxBetv161 = MaxBet
	from custsetting3rd with(nolock)
	where custid = @srecommend and bettype = 81 and sporttype = 161


	if @UpdateMultiple = 0 or @UpdateMinMaxBet=1 
	BEGIN
		if (@MinMinBet>0 and @MinBet>0 and @minbet<@MinMinBet)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Soccer)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBet) + ').', @ErrCode = 119	
			return
		END
		
		if (@MaxMaxBet>0 and @MaxBet>0 and @maxbet>@MaxMaxBet)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Soccer)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBet) + ').', @ErrCode = 120	
			return
		END
		
		if (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Soccer)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatch) + ').', @ErrCode = 121	
			return
		END
	END
	
	IF @UpdateMultiple = 0 or @UpdateMinMaxBetv1MP=1 
	BEGIN
		if (@MinMinBetv1MP > 0 and @minbetv1mp > 0 and @minbetv1mp < @MinMinBetv1MP)
		
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Soccer Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv1MP) + ').', @ErrCode = 119	
			return
		END
		
		if (@MaxMaxBetv1MP > 0 and @maxbetv1mp > 0 and @maxbetv1mp > @MaxMaxBetv1MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Soccer Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv1MP) + ').', @ErrCode = 120	
			return
		END
		
		if (@MaxMaxPerMatchv1MP > 0 and @MaxPerMatchv1MP > 0 and @MaxPerMatchv1MP > @MaxMaxPerMatchv1MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Soccer Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv1MP) + ').', @ErrCode = 121	
			return
		END
	END
	

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv2=1 
	BEGIN
		if (@MaxMaxBetv2>0 and @maxbetv2>0 and @maxbetv2>@MaxMaxBetv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv2) + ').', @ErrCode = 122	
			return
		END
		
		if (@MaxMaxPerMatchv2>0 and @MaxPerMatchv2>0 and @MaxPerMatchv2>@MaxMaxPerMatchv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv2) + ').', @ErrCode = 123	
			return
		END
		
		if (@MinMinBetv2>0 and @minbetv2>0 and @minbetv2<@MinMinBetv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv2) + ').', @ErrCode = 124	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv3=1 
	BEGIN
		if (@MaxMaxBetv3>0 and @maxbetv3>0 and @maxbetv3>@MaxMaxBetv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv3) + ').', @ErrCode = 125	
			return
		END
		
		if (@MaxMaxPerMatchv3>0 and @MaxPerMatchv3>0 and @MaxPerMatchv3>@MaxMaxPerMatchv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv3) + ').', @ErrCode = 126	
			return
		END
		
		if (@MinMinBetv3>0 and @minbetv3>0 and @minbetv3<@MinMinBetv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv3) + ').', @ErrCode = 127	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv5=1 
	BEGIN
		if (@MaxMaxBetv5>0 and @maxbetv5>0 and @maxbetv5>@MaxMaxBetv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv5) + ').', @ErrCode = 128	
			return
		END
		
		if (@MaxMaxPerMatchv5>0 and @MaxPerMatchv5>0 and @MaxPerMatchv5>@MaxMaxPerMatchv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv5) + ').', @ErrCode = 129	
			return
		END
		
		if (@MinMinBetv5>0 and @minbetv5>0 and @minbetv5<@MinMinBetv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'						
							end						
							+' (' + convert(varchar(20), @MinMinBetv5) + ').', @ErrCode = 130	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv8=1 
	BEGIN
		if (@MaxMaxBetv8>0 and @maxbetv8>0 and @maxbetv8>@MaxMaxBetv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv8) + ').', @ErrCode = 131	
			return
		END
		
		if (@MaxMaxPerMatchv8>0 and @MaxPerMatchv8>0 and @MaxPerMatchv8>@MaxMaxPerMatchv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv8) + ').', @ErrCode = 132	
			return
		END
		
		if (@MinMinBetv8>0 and @minbetv8>0 and @minbetv8<@MinMinBetv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv8) + ').', @ErrCode = 133	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv10=1 
	BEGIN
		if (@MaxMaxBetv10>0 and @maxbetv10>0 and @maxbetv10>@MaxMaxBetv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv10) + ').', @ErrCode = 134	
			return
		END
		
		if (@MaxMaxPerMatchv10>0 and @MaxPerMatchv10>0 and @MaxPerMatchv10>@MaxMaxPerMatchv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv10) + ').', @ErrCode = 135	
			return
		END
		
		if (@MinMinBetv10>0 and @minbetv10>0 and @minbetv10<@MinMinBetv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv10) + ').', @ErrCode = 136	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv11=1 
	BEGIN
		if (@MaxMaxBetv11>0 and @maxbetv11>0 and @maxbetv11>@MaxMaxBetv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv11) + ').', @ErrCode = 137	
			return
		END
		
		if (@MaxMaxPerMatchv11>0 and @MaxPerMatchv11>0 and @MaxPerMatchv11>@MaxMaxPerMatchv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv11) + ').', @ErrCode = 138	
			return
		END
		
		if (@MinMinBetv11>0 and @minbetv11>0 and @minbetv11<@MinMinBetv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv11) + ').', @ErrCode = 139	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv99=1 
	BEGIN
		if (@MaxMaxBetv99>0 and @maxbetv99>0 and @maxbetv99>@MaxMaxBetv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv99) + ').', @ErrCode = 143	
			return
		END
		
		if (@MaxMaxPerMatchv99>0 and @MaxPerMatchv99>0 and @MaxPerMatchv99>@MaxMaxPerMatchv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv99) + ').', @ErrCode = 144	
			return
		END
		
		if (@MinMinBetv99>0 and @minbetv99>0 and @minbetv99<@MinMinBetv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv99) + ').', @ErrCode = 145	
			return
		END
	END

	---- mixed sports
	if @UpdateMultiple = 0 or @UpdateMinMaxBetv99MP = 1 
	BEGIN
		if (@MaxMaxBetv99MP > 0 and @maxbetv99mp > 0 and @maxbetv99mp > @MaxMaxBetv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv99MP) + ').', @ErrCode = 205	
			return
		END
		
		if (@MaxMaxPerMatchv99MP > 0 and @MaxPerMatchv99MP > 0 and @MaxPerMatchv99MP > @MaxMaxPerMatchv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv99MP) + ').', @ErrCode = 206	
			return
		END
		
		if (@MinMinBetv99MP > 0 and @minbetv99mp > 0 and @minbetv99mp < @MinMinBetv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							end						
							+' (' + convert(varchar(20), @MinMinBetv99MP) + ').', @ErrCode = 207	
			return
		END
	END

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv154=1 
	BEGIN
		if (@MaxMaxBetv154>0 and @maxbetv154>0 and @maxbetv154>@MaxMaxBetv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv154) + ').', @ErrCode = 143	
			return
		END
		
		if (@MaxMaxPerMatchv154>0 and @MaxPerMatchv154>0 and @MaxPerMatchv154>@MaxMaxPerMatchv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxPerMatchv154) + ').', @ErrCode = 144	
			return
		END
		
		if (@MinMinBetv154>0 and @minbetv154>0 and @minbetv154<@MinMinBetv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv154) + ').', @ErrCode = 145	
			return
		END
	END
	---- Number Game

	if @UpdateMultiple = 0 or @UpdateMinMaxBetv161 = 1
	BEGIN
		if (@MaxMaxBetv161 > 0 and @maxbetv161 > 0 and @maxbetv161 > @MaxMaxBetv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max bet must be equal to or less than Super Agent max bet (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MaxMaxBetv161) + ').', @ErrCode = 208	
			return
		END
		
		if (@MaxMaxPerMatchv161 > 0 and @MaxPerMatchv161 > 0 and @MaxPerMatchv161 > @MaxMaxPerMatchv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end
							+' (' + convert(varchar(20), @MaxMaxPerMatchv161) + ').', @ErrCode = 209	
			return
		END
		
		if (@MinMinBetv161 > 0 and @minbetv161 > 0 and @minbetv161 < @MinMinBetv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be equal to or greater than Super Agent min bet (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end						
							+' (' + convert(varchar(20), @MinMinBetv161) + ').', @ErrCode = 210	
			return
		END
	/* ------------- viet --comment this
		--- max per ball
		if @MaxPerBallv161 < @MaxBetv161 or @MaxPerBallv161 > @MaxPerMatchv161
		begin
			SELECT @ErrMsg =	@UserName + ': '+
				CASE @Language 
					WHEN 'E' THEN 'Sory, Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
					WHEN 'CS' THEN N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注.'
					WHEN 'CT' THEN N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注.'
					WHEN 'TH' THEN N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน.'
					WHEN 'J' THEN N'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
					WHEN 'KO' THEN N'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
					ELSE N'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
				END						
				+' (' + CONVERT(VARCHAR(20), @MaxPerBallv161) + ').', @ErrCode = 200				
			return
		end
	*/
		if @MaxPerBallv161 > @MaxMaxPerBallv161 and @MaxMaxPerBallv161 > 0
		begin
			SELECT @ErrMsg =	@UserName + ': '+
				CASE @Language 
					WHEN 'E' THEN 'Max Per Ball must be equal to or less than Super Agent Max Per Ball (Number Game).'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
				END						
				+' (' + CONVERT(VARCHAR(20), @MaxMaxPerBallv161) + ').', @ErrCode = 201				
			return
		end
	END
	------------

	------------
	update custsetting with (ROWLOCK, UPDLOCK)
	set	
		minbet = case when @UpdateMultiple = 1 and ((sporttype=1 and @UpdateMinMaxBetv1MP = 0 AND bettype = 9) or (sporttype=1 and @UpdateMinMaxBet = 0 AND bettype <> 9) or (sporttype=2 and @UpdateMinMaxBetv2 = 0) or (sporttype=3 and @UpdateMinMaxBetv3 = 0) or (sporttype=5 and @UpdateMinMaxBetv5 = 0) or (sporttype=8 and @UpdateMinMaxBetv8 = 0) or (sporttype=10 and @UpdateMinMaxBetv10 = 0) or (sporttype=11 and @UpdateMinMaxBetv11 = 0) or (sporttype=99 and @UpdateMinMaxBetv99 = 0 and bettype <> 9) or (sporttype=99 and @UpdateMinMaxBetv99MP = 0 and bettype = 9) or (sporttype=154 and @UpdateMinMaxBetv154 = 0 and bettype = 20)or (sporttype=161 and @UpdateMinMaxBetv161=0)) then minbet else case sporttype when 1 then (case when bettype = 9 then @minbetv1mp else @minbet end)  when 2 then @minbetv2 when 3 then @minbetv3 when 5 then @minbetv5 when 8 then @minbetv8 when 10 then @minbetv10 when 11 then @minbetv11  when 99 then (case when bettype = 9 then @minbetv99mp else @minbetv99 end) when 154 then @minbetv154 else minbet end end,
		maxbet = case when @UpdateMultiple = 1 and ((sporttype=1 and @UpdateMinMaxBetv1MP = 0 AND bettype = 9) or (sporttype=1 and @UpdateMinMaxBet = 0 AND bettype <> 9) or (sporttype=2 and @UpdateMinMaxBetv2 = 0) or (sporttype=3 and @UpdateMinMaxBetv3 = 0) or (sporttype=5 and @UpdateMinMaxBetv5 = 0) or (sporttype=8 and @UpdateMinMaxBetv8 = 0) or (sporttype=10 and @UpdateMinMaxBetv10 = 0) or (sporttype=11 and @UpdateMinMaxBetv11 = 0) or (sporttype=99 and @UpdateMinMaxBetv99 = 0 and bettype <> 9) or (sporttype=99 and @UpdateMinMaxBetv99MP = 0 and bettype = 9) or (sporttype=154 and @UpdateMinMaxBetv154 = 0 and bettype = 20)or (sporttype=161 and @UpdateMinMaxBetv161=0)) then maxbet else case sporttype when 1 then (case when bettype = 9 then @maxbetv1mp else @maxbet end)  when 2 then @maxbetv2 when 3 then @maxbetv3 when 5 then @maxbetv5 when 8 then @maxbetv8 when 10 then @maxbetv10 when 11 then @maxbetv11  when 99 then (case when bettype = 9 then @maxbetv99mp else @maxbetv99 end) when 154 then @maxbetv154 else maxbet end end	
	where custid=@custid
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 147
		return
	end


	--- update number game
	update custsetting3rd with (ROWLOCK, UPDLOCK)
	set	
		minbet = case when @UpdateMultiple = 1 and ((sporttype = 161 and @UpdateMinMaxBetv161 = 0)) then minbet else case when sporttype = 161 then @minbetv161 else minbet end end,
		maxbet = case when @UpdateMultiple = 1 and ((sporttype = 161 and @UpdateMinMaxBetv161 = 0)) then maxbet else case when sporttype = 161 then @maxbetv161 else maxbet end end	
	where custid = @custid
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 211
		return
	end


	EXEC dbo.Acc_CustomerUpdMaxPerMatch 
		@custid = @custid,
		@maxpermatch = @maxpermatch,
		@maxpermatchv2 = @maxpermatchv2,
		@maxpermatchv3 = @maxpermatchv3,
		@maxpermatchv5 = @maxpermatchv5,
		@maxpermatchv8 = @maxpermatchv8,
		@maxpermatchv10 = @maxpermatchv10,
		@maxpermatchv11 = @maxpermatchv11,
		@maxpermatchv99 = @maxpermatchv99,
		@maxpermatchv99mp = @maxpermatchv99mp,
		
		@maxpermatchv1mp = @maxpermatchv1mp,
		
		@maxpermatchv154 = @maxpermatchv154,
		@maxpermatchv161 = @maxpermatchv161,
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
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
		if @ErrCode > 0
		BEGIN
			return
		END
		
	exec dbo.Acc_CustomerUpdMaxPerBall
		@custid = @custid,
		@MaxPerBallv161 = @MaxPerBallv161,
		@UpdateMultiple = @UpdateMultiple,
		@UpdateMinMaxBetv161 = @UpdateMinMaxBetv161,
		@Language = @Language,
		@ErrCode = @ErrCode output,
		@ErrMsg = @ErrMsg output
	if @ErrCode > 0
	begin
		return
	end
			
	Declare @LogSPData varchar(8000)
	Declare @TrackingValue2 varchar(8000)

	----------
	-- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
	---------------------------------
	SELECT @minbet = MAX(CASE WHEN sporttype = 1 AND bettype <> 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBet = 0 
												THEN minbet ELSE @minbet END) 
								ELSE 0 END),
		@maxbet = MAX(CASE WHEN sporttype = 1 AND bettype <> 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBet = 0 
												THEN maxbet ELSE @maxbet END) 
								ELSE 0 END),
		
		@minbetv2 = MAX(CASE WHEN sporttype = 2 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv2 = 0 
												THEN minbet ELSE @minbetv2 END) 
								ELSE 0 END),
		@maxbetv2 = MAX(CASE WHEN sporttype = 2 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv2 = 0 
												THEN maxbet ELSE @maxbetv2 END) 
								ELSE 0 END),

		@minbetv3 = MAX(CASE WHEN sporttype = 3 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv3 = 0 
												THEN minbet ELSE @minbetv3 END) 
								ELSE 0 END),
		@maxbetv3 = MAX(CASE WHEN sporttype = 3 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv3 = 0 
												THEN maxbet ELSE @maxbetv3 END) 
								ELSE 0 END),
									
		@minbetv5 = MAX(CASE WHEN sporttype = 5 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv5 = 0 
												THEN minbet ELSE @minbetv5 END) 
								ELSE 0 END),
		@maxbetv5 = MAX(CASE WHEN sporttype = 5 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv5 = 0 
												THEN maxbet ELSE @maxbetv5 END) 
								ELSE 0 END),

		@minbetv8 = MAX(CASE WHEN sporttype = 8 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv8 = 0 
												THEN minbet ELSE @minbetv8 END) 
								ELSE 0 END),
		@maxbetv8 = MAX(CASE WHEN sporttype = 8 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv8 = 0 
												THEN maxbet ELSE @maxbetv8 END) 
								ELSE 0 END),

		@minbetv10 = MAX(CASE WHEN sporttype = 10 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv10 = 0 
												THEN minbet ELSE @minbetv10 END) 
								ELSE 0 END),
		@maxbetv10 = MAX(CASE WHEN sporttype = 10 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv10 = 0 
												THEN maxbet ELSE @maxbetv10 END) 
								ELSE 0 END),
		
		@minbetv11 = MAX(CASE WHEN sporttype = 11 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv11 = 0 
												THEN minbet ELSE @minbetv11 END) 
								ELSE 0 END),
		@maxbetv11 = MAX(CASE WHEN sporttype = 11 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv11 = 0 
												THEN maxbet ELSE @maxbetv11 END) 
								ELSE 0 END),
		
		@minbetv99 = MAX(CASE WHEN sporttype = 99 AND bettype <> 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99 = 0 
												THEN minbet ELSE @minbetv99 END) 
								ELSE 0 END),
		@maxbetv99 = MAX(CASE WHEN sporttype = 99 AND bettype <> 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99 = 0 
												THEN maxbet ELSE @maxbetv99 END) 
								ELSE 0 END),
		
		@minbetv99mp = MAX(CASE WHEN sporttype = 99 AND bettype = 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99mp = 0 
												THEN minbet ELSE @minbetv99mp END) 
								ELSE 0 END),
		@maxbetv99mp = MAX(CASE WHEN sporttype = 99 AND bettype = 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99mp = 0 
												THEN maxbet ELSE @maxbetv99mp END) 
								ELSE 0 END),
								
		@minbetv1mp = MAX(CASE WHEN sporttype = 1 AND bettype = 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv1mp = 0 
												THEN minbet ELSE @minbetv1mp END) 
								ELSE 0 END),
		@maxbetv1mp = MAX(CASE WHEN sporttype = 1 AND bettype = 9 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv1mp = 0 
												THEN maxbet ELSE @maxbetv1mp END) 
								ELSE 0 END),						
		
		@minbetv154 = MAX(CASE WHEN sporttype = 154 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv154 = 0 
												THEN minbet ELSE @minbetv154 END) 
								ELSE 0 END),
		@maxbetv154 = MAX(CASE WHEN sporttype = 154 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv154 = 0 
												THEN maxbet ELSE @maxbetv154 END) 
								ELSE 0 END)
	FROM custSetting WITH(NOLOCK)
	WHERE custid = @custid

	SELECT @minbetv161 = MAX(CASE WHEN sporttype = 161 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 
												THEN minbet ELSE @minbetv161 END) 
								ELSE 0 END),
		@maxbetv161 = MAX(CASE WHEN sporttype = 161 THEN 
										(CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 
												THEN maxbet ELSE @maxbetv161 END) 
								ELSE 0 END)
	FROM custSetting3rd WITH(NOLOCK)
	WHERE custid = @custid

	SELECT	@maxpermatch = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBet = 0 THEN maxpermatch ELSE @maxpermatch END,
		@maxpermatchv2 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv2 = 0 THEN maxpermatch2 ELSE @maxpermatchv2 END,
		@maxpermatchv3 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv3 = 0 THEN maxpermatch3 ELSE @maxpermatchv3 END,
		@maxpermatchv5 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv5 = 0 THEN maxpermatch5 ELSE @maxpermatchv5 END,
		@maxpermatchv8 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv8 = 0 THEN maxpermatch8 ELSE @maxpermatchv8 END,
		@maxpermatchv10 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv10 = 0 THEN maxpermatch10 ELSE @maxpermatchv10 END,
		@maxpermatchv11 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv11 = 0 THEN maxpermatch11 ELSE @maxpermatchv11 END,
		@maxpermatchv99 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99 = 0 THEN maxpermatch99 ELSE @maxpermatchv99 END,
		@maxpermatchv99MP = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv99MP = 0 THEN maxpermatch99MP ELSE @maxpermatchv99MP END,
		
		@maxpermatchv1MP = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv1MP = 0 THEN maxpermatch1MP ELSE @maxpermatchv1MP END,
		
		@maxpermatchv154 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv154 = 0 THEN maxpermatch154 ELSE @maxpermatchv154 END,
		@maxpermatchv161 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 THEN maxpermatch161 ELSE @maxpermatchv161 END,
		@MaxPerBallv161 = CASE WHEN @UpdateMultiple = 1 AND @UpdateMinMaxBetv161 = 0 THEN MaxPerBall161 ELSE @MaxPerBallv161 END	
	FROM custInfo WITH(NOLOCK)
	WHERE custid = @custid		
	---------------------------------

	Select @LogSPData ='<Acc_CustomerUpdMaster_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1))+ '" ' +
	'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1))+ '" ' +
	'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1))+ '" ' +
	'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1))+ '" ' +
	'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1))+ '" ' +
	'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1))+ '" ' +
	'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1))+ '" ' +
	'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1))+ '" ' +
	'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1))+ '" ' +
	'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1)) + '" ' +
	'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1))+ '" ' +
	'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1))+ '" ' +
	'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1))+ '" ' +
	'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1))+ '" ' +
	'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1))+ '" ' +
	'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1))+ '" ' +
	'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1))+ '" ' +
	'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1))+ '" ' +
	'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1))+ '" ' +
	'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1))+ '" ' +
	'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1))+ '" ' +
	'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1))+ '" ' +
	'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1))+ '" ' +
	'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1))+ '" ' +
	-- mixed sports
	'MinBv99MP="'+ coalesce(cast(@minbetv99mp as varchar(50)),space(1))+ '" ' +
	'MaxBv99MP="'+ coalesce(cast(@maxbetv99mp as varchar(50)),space(1))+ '" ' +
	'MPMv99MP="'+ coalesce(cast(@maxpermatchv99mp as varchar(50)),space(1))+ '" ' +

	'MinBv1MP="'+ coalesce(cast(@minbetv1mp as varchar(50)),space(1))+ '" ' +
	'MaxBv1MP="'+ coalesce(cast(@maxbetv1mp as varchar(50)),space(1))+ '" ' +
	'MPMv1MP="'+ coalesce(cast(@maxpermatchv1mp as varchar(50)),space(1))+ '" ' +
	
	'MinBv154="'+ coalesce(cast(@minbetv154 as varchar(50)),space(1))+ '" ' +
	'MaxBv154="'+ coalesce(cast(@maxbetv154 as varchar(50)),space(1))+ '" ' +
	'MPMv154="'+ coalesce(cast(@maxpermatchv154 as varchar(50)),space(1))+ '" ' +

	-- number game
	'MinBv161="'+ coalesce(cast(@minbetv161 as varchar(50)),space(1))+ '" ' +
	'MaxBv161="'+ coalesce(cast(@maxbetv161 as varchar(50)),space(1))+ '" ' +
	'MPMv161="'+ coalesce(cast(@maxpermatchv161 as varchar(50)),space(1))+ '" ' +
	'MPBv161="' + coalesce(cast(@maxperballv161 as varchar(50)), space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1))+ '" ' +
	'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1))+ '" ' +
	'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1))+ '" ' +
	'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1))+ '" ' +
	'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1))+ '" ' +
	'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1))+ '" ' +
	'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1))+ '" ' +
	'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1))+ '" ' +
	'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1))+ '" ' +
	'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1))+ '" ' +
	'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1))+ '" ' +
	'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
	'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1))+ '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" />'

	Select @TrackingValue2 ='<Acc_CustomerUpdMaster_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'MinB="'+ coalesce(cast(@Old_minbet as varchar(50)),space(1))+ '" ' +
	'MaxB="'+ coalesce(cast(@Old_maxbet as varchar(50)),space(1))+ '" ' +
	'MPM="'+ coalesce(cast(@Old_maxpermatch as varchar(50)),space(1))+ '" ' +
	'MinBv2="'+ coalesce(cast(@Old_minbetv2 as varchar(50)),space(1))+ '" ' +
	'MaxBv2="'+ coalesce(cast(@Old_maxbetv2 as varchar(50)),space(1))+ '" ' +
	'MPMv2="'+ coalesce(cast(@Old_maxpermatchv2 as varchar(50)),space(1))+ '" ' +
	'MinBv3="'+ coalesce(cast(@Old_minbetv3 as varchar(50)),space(1))+ '" ' +
	'MaxBv3="'+ coalesce(cast(@Old_maxbetv3 as varchar(50)),space(1))+ '" ' +
	'MPMv3="'+ coalesce(cast(@Old_maxpermatchv3 as varchar(50)),space(1))+ '" ' +
	'MinBv5="'+ coalesce(cast(@Old_minbetv5 as varchar(50)),space(1)) + '" ' +
	'MaxBv5="'+ coalesce(cast(@Old_maxbetv5 as varchar(50)),space(1))+ '" ' +
	'MPMv5="'+ coalesce(cast(@Old_maxpermatchv5 as varchar(50)),space(1))+ '" ' +
	'MinBv8="'+ coalesce(cast(@Old_minbetv8 as varchar(50)),space(1))+ '" ' +
	'MaxBv8="'+ coalesce(cast(@Old_maxbetv8 as varchar(50)),space(1))+ '" ' +
	'MPMv8="'+ coalesce(cast(@Old_maxpermatchv8 as varchar(50)),space(1))+ '" ' +
	'MinBv10="'+ coalesce(cast(@Old_minbetv10 as varchar(50)),space(1))+ '" ' +
	'MaxBv10="'+ coalesce(cast(@Old_maxbetv10 as varchar(50)),space(1))+ '" ' +
	'MPMv10="'+ coalesce(cast(@Old_maxpermatchv10 as varchar(50)),space(1))+ '" ' +
	'MinBv11="'+ coalesce(cast(@Old_minbetv11 as varchar(50)),space(1))+ '" ' +
	'MaxBv11="'+ coalesce(cast(@Old_maxbetv11 as varchar(50)),space(1))+ '" ' +
	'MPMv11="'+ coalesce(cast(@Old_maxpermatchv11 as varchar(50)),space(1))+ '" ' +
	'MinBv99="'+ coalesce(cast(@Old_minbetv99 as varchar(50)),space(1))+ '" ' +
	'MaxBv99="'+ coalesce(cast(@Old_maxbetv99 as varchar(50)),space(1))+ '" ' +
	'MPMv99="'+ coalesce(cast(@Old_maxpermatchv99 as varchar(50)),space(1))+ '" ' +
	-- mixed sports
	'MinBv99MP="'+ coalesce(cast(@Old_minbetv99mp as varchar(50)),space(1))+ '" ' +
	'MaxBv99MP="'+ coalesce(cast(@Old_maxbetv99mp as varchar(50)),space(1))+ '" ' +
	'MPMv99MP="'+ coalesce(cast(@Old_maxpermatchv99mp as varchar(50)),space(1))+ '" ' +

	'MinBv1MP="'+ coalesce(cast(@Old_minbetv1mp as varchar(50)),space(1))+ '" ' +
	'MaxBv1MP="'+ coalesce(cast(@Old_maxbetv1mp as varchar(50)),space(1))+ '" ' +
	'MPMv1MP="'+ coalesce(cast(@Old_maxpermatchv1mp as varchar(50)),space(1))+ '" ' +
	
	'MinBv154="'+ coalesce(cast(@Old_minbetv154 as varchar(50)),space(1))+ '" ' +
	'MaxBv154="'+ coalesce(cast(@Old_maxbetv154 as varchar(50)),space(1))+ '" ' +
	'MPMv154="'+ coalesce(cast(@Old_maxpermatchv154 as varchar(50)),space(1))+ '" ' +

	-- number game
	'MinBv161="'+ coalesce(cast(@Old_minbetv161 as varchar(50)),space(1))+ '" ' +
	'MaxBv161="'+ coalesce(cast(@Old_maxbetv161 as varchar(50)),space(1))+ '" ' +
	'MPMv161="'+ coalesce(cast(@Old_maxpermatchv161 as varchar(50)),space(1))+ '" ' +
	'MPBv161="' + coalesce(cast(@Old_maxperballv161 as varchar(50)), space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1))+ '" ' +
	'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1))+ '" ' +
	'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1))+ '" ' +
	'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1))+ '" ' +
	'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1))+ '" ' +
	'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1))+ '" ' +
	'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1))+ '" ' +
	'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1))+ '" ' +
	'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1))+ '" ' +
	'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1))+ '" ' +
	'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1))+ '" ' +
	'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
	'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1))+ '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1))+ '" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 305,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData ='<Acc_CustomerUpdMaster_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
		'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1))+ '" ' +
		'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1))+ '" ' +
		'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1))+ '" ' +
		'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1))+ '" ' +
		'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1))+ '" ' +
		'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1))+ '" ' +
		'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1))+ '" ' +
		'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1))+ '" ' +
		'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1))+ '" ' +
		'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1)) + '" ' +
		'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1))+ '" ' +
		'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1))+ '" ' +
		'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1))+ '" ' +
		'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1))+ '" ' +
		'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1))+ '" ' +
		'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1))+ '" ' +
		'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1))+ '" ' +
		'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1))+ '" ' +
		'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1))+ '" ' +
		'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1))+ '" ' +
		'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1))+ '" ' +
		'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1))+ '" ' +
		'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1))+ '" ' +
		'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1))+ '" ' +
		-- mixed sports
		'MinBv99MP="'+ coalesce(cast(@minbetv99mp as varchar(50)),space(1))+ '" ' +
		'MaxBv99MP="'+ coalesce(cast(@maxbetv99mp as varchar(50)),space(1))+ '" ' +
		'MPMv99MP="'+ coalesce(cast(@maxpermatchv99mp as varchar(50)),space(1))+ '" ' +
		
		'MinBv1MP="'+ coalesce(cast(@minbetv1mp as varchar(50)),space(1))+ '" ' +
		'MaxBv1MP="'+ coalesce(cast(@maxbetv1mp as varchar(50)),space(1))+ '" ' +
		'MPMv1MP="'+ coalesce(cast(@maxpermatchv1mp as varchar(50)),space(1))+ '" ' +
			
		'MinBv154="'+ coalesce(cast(@minbetv154 as varchar(50)),space(1))+ '" ' +
		'MaxBv154="'+ coalesce(cast(@maxbetv154 as varchar(50)),space(1))+ '" ' +
		'MPMv154="'+ coalesce(cast(@maxpermatchv154 as varchar(50)),space(1))+ '" ' +


		-- number game
		'MinBv161="'+ coalesce(cast(@minbetv161 as varchar(50)),space(1))+ '" ' +
		'MaxBv161="'+ coalesce(cast(@maxbetv161 as varchar(50)),space(1))+ '" ' +
		'MPMv161="'+ coalesce(cast(@maxpermatchv161 as varchar(50)),space(1))+ '" ' +
		'MPBv161="' + coalesce(cast(@maxperballv161 as varchar(50)), space(1)) + '" ' +
		'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1))+ '" ' +
		'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1))+ '" ' +
		'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1))+ '" ' +
		'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1))+ '" ' +
		'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1))+ '" ' +
		'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1))+ '" ' +
		'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1))+ '" ' +
		'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1))+ '" ' +
		'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1))+ '" ' +
		'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1))+ '" ' +
		
		'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1))+ '" ' +
		
		'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
		'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1))+ '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" />'

		Select @TrackingValue2 ='<Acc_CustomerUpdMaster_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
		'MinB="'+ coalesce(cast(@Old_minbet as varchar(50)),space(1))+ '" ' +
		'MaxB="'+ coalesce(cast(@Old_maxbet as varchar(50)),space(1))+ '" ' +
		'MPM="'+ coalesce(cast(@Old_maxpermatch as varchar(50)),space(1))+ '" ' +
		'MinBv2="'+ coalesce(cast(@Old_minbetv2 as varchar(50)),space(1))+ '" ' +
		'MaxBv2="'+ coalesce(cast(@Old_maxbetv2 as varchar(50)),space(1))+ '" ' +
		'MPMv2="'+ coalesce(cast(@Old_maxpermatchv2 as varchar(50)),space(1))+ '" ' +
		'MinBv3="'+ coalesce(cast(@Old_minbetv3 as varchar(50)),space(1))+ '" ' +
		'MaxBv3="'+ coalesce(cast(@Old_maxbetv3 as varchar(50)),space(1))+ '" ' +
		'MPMv3="'+ coalesce(cast(@Old_maxpermatchv3 as varchar(50)),space(1))+ '" ' +
		'MinBv5="'+ coalesce(cast(@Old_minbetv5 as varchar(50)),space(1)) + '" ' +
		'MaxBv5="'+ coalesce(cast(@Old_maxbetv5 as varchar(50)),space(1))+ '" ' +
		'MPMv5="'+ coalesce(cast(@Old_maxpermatchv5 as varchar(50)),space(1))+ '" ' +
		'MinBv8="'+ coalesce(cast(@Old_minbetv8 as varchar(50)),space(1))+ '" ' +
		'MaxBv8="'+ coalesce(cast(@Old_maxbetv8 as varchar(50)),space(1))+ '" ' +
		'MPMv8="'+ coalesce(cast(@Old_maxpermatchv8 as varchar(50)),space(1))+ '" ' +
		'MinBv10="'+ coalesce(cast(@Old_minbetv10 as varchar(50)),space(1))+ '" ' +
		'MaxBv10="'+ coalesce(cast(@Old_maxbetv10 as varchar(50)),space(1))+ '" ' +
		'MPMv10="'+ coalesce(cast(@Old_maxpermatchv10 as varchar(50)),space(1))+ '" ' +
		'MinBv11="'+ coalesce(cast(@Old_minbetv11 as varchar(50)),space(1))+ '" ' +
		'MaxBv11="'+ coalesce(cast(@Old_maxbetv11 as varchar(50)),space(1))+ '" ' +
		'MPMv11="'+ coalesce(cast(@Old_maxpermatchv11 as varchar(50)),space(1))+ '" ' +
		'MinBv99="'+ coalesce(cast(@Old_minbetv99 as varchar(50)),space(1))+ '" ' +
		'MaxBv99="'+ coalesce(cast(@Old_maxbetv99 as varchar(50)),space(1))+ '" ' +
		'MPMv99="'+ coalesce(cast(@Old_maxpermatchv99 as varchar(50)),space(1))+ '" ' +
		-- mixed sports
		'MinBv99MP="'+ coalesce(cast(@Old_minbetv99mp as varchar(50)),space(1))+ '" ' +
		'MaxBv99MP="'+ coalesce(cast(@Old_maxbetv99mp as varchar(50)),space(1))+ '" ' +
		'MPMv99MP="'+ coalesce(cast(@Old_maxpermatchv99mp as varchar(50)),space(1))+ '" ' +
		
		'MinBv1MP="'+ coalesce(cast(@Old_minbetv1mp as varchar(50)),space(1))+ '" ' +
		'MaxBv1MP="'+ coalesce(cast(@Old_maxbetv1mp as varchar(50)),space(1))+ '" ' +
		'MPMv1MP="'+ coalesce(cast(@Old_maxpermatchv1mp as varchar(50)),space(1))+ '" ' +
		
		
		'MinBv154="'+ coalesce(cast(@Old_minbetv154 as varchar(50)),space(1))+ '" ' +
		'MaxBv154="'+ coalesce(cast(@Old_maxbetv154 as varchar(50)),space(1))+ '" ' +
		'MPMv154="'+ coalesce(cast(@Old_maxpermatchv154 as varchar(50)),space(1))+ '" ' +

		-- number game
		'MinBv161="'+ coalesce(cast(@Old_minbetv161 as varchar(50)),space(1))+ '" ' +
		'MaxBv161="'+ coalesce(cast(@Old_maxbetv161 as varchar(50)),space(1))+ '" ' +
		'MPMv161="'+ coalesce(cast(@Old_maxpermatchv161 as varchar(50)),space(1))+ '" ' +
		'MPBv161="' + coalesce(cast(@Old_maxperballv161 as varchar(50)), space(1)) + '" ' +
		'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1))+ '" ' +
		'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1))+ '" ' +
		'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1))+ '" ' +
		'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1))+ '" ' +
		'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1))+ '" ' +
		'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1))+ '" ' +
		'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1))+ '" ' +
		'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1))+ '" ' +
		'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1))+ '" ' +
		'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1))+ '" ' +
		
		'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1))+ '" ' +
		
		'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
		'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1))+ '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1))+ '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+ '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 305,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration		
	END CATCH
END	
---------------------------------------------------------


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_MinMaxBet] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_MinMaxBet] TO [vnteam] AS [dbo]