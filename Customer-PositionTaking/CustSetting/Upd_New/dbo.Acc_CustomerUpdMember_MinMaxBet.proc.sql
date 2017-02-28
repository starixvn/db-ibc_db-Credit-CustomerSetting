ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_MinMaxBet]
	@custid int,-- MemberID
	
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
	
	@minbetv99MP money,
	@maxbetv99MP money,
	@maxpermatchv99MP money,	
	
	@minbetv1MP money,
	@maxbetv1MP money,
	@maxpermatchv1MP money,	
	
	@MinBetv154 MONEY = 0,
	@MaxBetv154 MONEY = 0,
	@MaxPerMatchv154 MONEY = 0,
	
	@minbetv161 money,
	@maxbetv161 money,
	@maxpermatchv161 money,	
	
	@MaxPerBallv161 money = 0,	
	
	@UpdateMultiple bit = 0,	
	
	@UpdateMinMaxBet bit = 1,
	@UpdateMinMaxBetv2 bit = 1,
	@UpdateMinMaxBetv3 bit = 1,
	@UpdateMinMaxBetv5 bit = 1,
	@UpdateMinMaxBetv8 bit = 1,
	@UpdateMinMaxBetv10 bit = 1,
	@UpdateMinMaxBetv11 bit = 1,
	
	@UpdateMinMaxBetv99 bit = 1,
	@UpdateMinMaxBetv99MP bit = 1,
	
	@UpdateMinMaxBetv1MP bit = 1,
	
	@UpdateMinMaxBetv154 bit = 1,
	
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
Task : Update Member MinBet, MaxBet, MaxPerMatch
DB: DBTXN/bodb02
Original:
Revisions:
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100830@Henry: Amend to update for Number Game + Mix Parlay Mixed Sports
	- 20101019@Henry: Record execution time
	- 20101028@Lukas: add max per ball (number game)
	- 20110109@Lukas: correct error message (wrong error message for Number Game)
	- 20110606@Amy: Write Log Old values
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
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
			@UserName varchar(30), @recommend int

	declare @err1 int, @err2 int		
			
	Select @UserName = username, @recommend = recommend
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
		
		@MinBetv154 = @old_MinBetv154 output, @MaxBetv154 =@old_MaxBetv154 output, @MaxPerMatchv154 =@old_MaxPerMatchv154 output,
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
	---------------------------------------------------------------
	--Check Param
	if @UpdateMinMaxBet = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBet<0
			or @MaxBet < 0
			or @MaxPerMatch <0		
		BEGIN
			select @ErrCode = 2
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Soccer).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbet = @Old_MinBet, @maxbet = @Old_MaxBet , @maxpermatch = @Old_MaxPerMatch
	END
	
	if @UpdateMinMaxBetv1MP = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@minbetv1MP<0
			or @maxbetv1MP < 0
			or @maxpermatchv1MP <0		
		BEGIN
			select @ErrCode = 2
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Soccer Parlay).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv1MP = @Old_MinBetv1MP, @maxbetv1MP = @Old_MaxBetv1MP , @maxpermatchv1MP = @Old_MaxPerMatchv1MP
	END
	
	/*
	if @UpdateMinMaxBet = 1 or @UpdateMultiple = 0  or @UpdateMinMaxBetv2 = 1 or @UpdateMinMaxBetv3 = 1 
	   or @UpdateMinMaxBetv5 = 1 or @UpdateMinMaxBetv8 = 1 or @UpdateMinMaxBetv10 = 1  
	   or @UpdateMinMaxBetv11 = 1 or @UpdateMinMaxBetv12 = 1 or @UpdateMinMaxBetv99 = 1 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '<br>'
	from sports s inner join
	(           select 1 as sporttype, @MinBet as MinBet, @MaxBet as MaxBet, @MaxPerMatch as MaxPerMatch 
	  union all select 2 as sporttype, @MinBetv2 as MinBet, @MaxBetv2 as MaxBet, @MaxPerMatchv2 as MaxPerMatch
	  union all select 3 as sporttype, @MinBetv3 as MinBet, @MaxBetv3 as MaxBet, @MaxPerMatchv3 as MaxPerMatch
	  union all select 5 as sporttype, @MinBetv5 as MinBet, @MaxBetv5 as MaxBet, @MaxPerMatchv5 as MaxPerMatch  
	  union all select 8 as sporttype, @MinBetv8 as MinBet, @MaxBetv8 as MaxBet, @MaxPerMatchv8 as MaxPerMatch
	  union all select 10 as sporttype, @MinBetv10 as MinBet, @MaxBetv10 as MaxBet, @MaxPerMatchv10 as MaxPerMatch
	  union all select 11 as sporttype, @MinBetv11 as MinBet, @MaxBetv11 as MaxBet, @MaxPerMatchv11 as MaxPerMatch
	  union all select 12 as sporttype, @MinBetv12 as MinBet, @MaxBetv12 as MaxBet, @MaxPerMatchv12 as MaxPerMatch
	  union all select 99 as sporttype, @MinBetv99 as MinBet, @MaxBetv99 as MaxBet, @MaxPerMatchv99 as MaxPerMatch
	) as b on s.sporttype = b.sporttype 
	where ( b.MinBet <0 or b.MaxBet <0 or b.MaxPerMatch <0)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 2 
		Select @ErrMsg = case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match.<br>'+ @ErrType
								when 'CS' then N'最低投注/最高投注/單場最高投注/信用額度/代理名/組別不正確.<br>'+ @ErrType
								when 'J' then N'Wrong Min bet/ Max bet/ Max per match.<br>'+ @ErrType
								else N'Wrong Min bet/ Max bet/ Max per match.<br>'+ @ErrType
						 end
		return 
	END	
	*/
	if @UpdateMinMaxBetv2 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv2 <0
			or @MaxBetv2 <0
			or @MaxPerMatchv2 <0		
		BEGIN
			select @ErrCode = 3
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Basketball).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv2 = @Old_MinBetv2, @maxbetv2 = @Old_MaxBetv2 , @maxpermatchv2 = @Old_MaxPerMatchv2
	END

	if @UpdateMinMaxBetv3 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv3 <0
			or @MaxBetv3 <0
			or @MaxPerMatchv3 <0		
		BEGIN
			select @ErrCode = 4
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Football).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv3 = @Old_MinBetv3, @maxbetv3 = @Old_MaxBetv3 , @maxpermatchv3 = @Old_MaxPerMatchv3
	END

	if @UpdateMinMaxBetv5 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv5 <0
			or @MaxBetv5 <0
			or @MaxPerMatchv5 <0		
		BEGIN
			select @ErrCode = 5
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Tennis).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv5 = @Old_MinBetv5, @maxbetv5 = @Old_MaxBetv5 , @maxpermatchv5 = @Old_MaxPerMatchv5
	END

	if @UpdateMinMaxBetv8 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv8 <0
			or @MaxBetv8 <0
			or @MaxPerMatchv8 <0		
		BEGIN
			select @ErrCode = 6
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Baseball).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv8 = @Old_MinBetv8, @maxbetv8 = @Old_MaxBetv8 , @maxpermatchv8 = @Old_MaxPerMatchv8
	END



	if @UpdateMinMaxBetv10 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv10 <0
			or @MaxBetv10 <0
			or @MaxPerMatchv10 <0		
		BEGIN
			select @ErrCode = 7
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Golf).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv10 = @Old_MinBetv10, @maxbetv10 = @Old_MaxBetv10 , @maxpermatchv10 = @Old_MaxPerMatchv10
	END


	if @UpdateMinMaxBetv11 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv11 <0
			or @MaxBetv11 <0
			or @MaxPerMatchv11 <0		
		BEGIN
			select @ErrCode = 8
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Motorsports).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv11 = @Old_MinBetv11, @maxbetv11 = @Old_MaxBetv11 , @maxpermatchv11 = @Old_MaxPerMatchv11
	END


	if @UpdateMinMaxBetv99 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv99 <0
			or @MaxBetv99 <0
			or @MaxPerMatchv99 <0		
		BEGIN
			select @ErrCode = 9
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Other sports).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv99 = @Old_MinBetv99, @maxbetv99 = @Old_MaxBetv99 , @maxpermatchv99 = @Old_MaxPerMatchv99
	END

	if @UpdateMinMaxBetv99MP = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv99MP <0
			or @MaxBetv99MP <0
			or @MaxPerMatchv99MP <0		
		BEGIN
			select @ErrCode = 10
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
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @MinBetv99MP = @Old_MinBetv99MP, @MaxBetv99MP = @Old_MaxBetv99MP , @MaxPerMatchv99MP = @Old_MaxPerMatchv99MP
	END

	if @UpdateMinMaxBetv154 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv154 <0
			or @MaxBetv154 <0
			or @MaxPerMatchv154 <0		
		BEGIN
			select @ErrCode = 8
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Motorsports).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
						end
			return
		END
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @minbetv154 = @Old_MinBetv154, @maxbetv154 = @Old_MaxBetv154 , @maxpermatchv154 = @Old_MaxPerMatchv154
	END

	if @UpdateMinMaxBetv161 = 1 or @UpdateMultiple = 0
	BEGIN
		if 
			@MinBetv161 <0
			or @MaxBetv161 <0
			or @MaxPerMatchv161 <0		
		BEGIN
			select @ErrCode = 11
			Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match (for Number Game).'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end
			return
		END
		
		if @MaxPerBallv161 < 0
		begin		
			select @ErrCode = 12
			Select @ErrMsg = 	case @Language 
						when 'E' then 'Wrong Max Per Ball (Number Game).'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10002,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
				end
			return		
		end
	END
	ELSE --select MinBet = Old_Minbet to write log in case not update
	BEGIN
		SELECT @MinBetv161 = @Old_MinBetv161, @MaxBetv161 = @Old_MaxBetv161 , @MaxPerMatchv161 = @Old_MaxPerMatchv161,
				@MaxPerBallv161 = @Old_MaxPerBallv161
	END

	---------------------------------------------------------------

	Select
		@MinMinBet = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBet = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=1
	where ci.custid = @recommend

	Select 
		@MinMinBetv2 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv2 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=2
	where ci.custid = @recommend

	Select 
		@MinMinBetv3 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv3 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=3
	where ci.custid = @recommend

	Select 
		@MinMinBetv5 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv5 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=5
	where ci.custid = @recommend

	Select 
		@MinMinBetv8 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv8 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=8
	where ci.custid = @recommend

	Select 
		@MinMinBetv10 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv10 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=10
	where ci.custid = @recommend

	Select 
		@MinMinBetv11 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv11 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=11
	where ci.custid = @recommend

	Select 
		@MinMinBetv99 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv99 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 1 and cs.sporttype=99
	where ci.custid = @recommend

	Select 
		@MinMinBetv99MP = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv99MP = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 9 and cs.sporttype=99
	where ci.custid = @recommend

	Select 
		@MinMinBetv1MP = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv1MP = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 9 and cs.sporttype=1
	where ci.custid = @recommend
	
	Select 
		@MinMinBetv154 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv154 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 20 and cs.sporttype=154
	where ci.custid = @recommend

	Select 
		@MinMinBetv161 = Max(case when MinBet = 0 then NULL else MinBet end), 
		@MaxMaxBetv161 = Min(case when MaxBet = 0 then NULL else MaxBet end)
	from 
		custsetting3rd as cs WITH (NOLOCK)
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 81 and cs.sporttype=161
	where ci.custid = @recommend


	Select 	
		@MaxMaxperMatch = Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end), 	
		@MaxMaxPerMatchv2 = Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end), 	
		@MaxMaxPerMatchv3 = Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end), 	
		@MaxMaxPerMatchv5 = Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end), 	
		@MaxMaxPerMatchv8 = Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end), 	
		@MaxMaxPerMatchv10 = Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end), 	
		@MaxMaxPerMatchv11 = Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end), 	
		@MaxMaxPerMatchv99 = Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),
		@MaxMaxPerMatchv99MP = Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),
		
		@MaxMaxPerMatchv1MP = Min(case when cs.MaxPerMatch1MP = 0 then NULL else cs.MaxPerMatch1MP end),
		
		@MaxMaxPerMatchv154 = Min(case when cs.MaxPerMatch154 = 0 then NULL else cs.MaxPerMatch154 end), 	
		@MaxMaxPerMatchv161 = Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),
		@MaxMaxPerBallv161 = Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end)
	from 
		custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	where ci.custid = @recommend

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBet = 1
	BEGIN
		if (@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch), @ErrCode = 108
				
			return
			
		END
		
		IF (@MinMinBet>0 AND @MinBet>0 AND @MinBet<@MinMinBet)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': ' +
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').', @ErrCode = 109
					
			return
		END
		
		IF (@MaxMaxBet>0 AND @MaxBet>0 AND @MaxBet>@MaxMaxBet)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language)
							END						
							+'(' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').', @ErrCode = 110
					
			return
		END
		
		IF (@MaxMaxPerMatch>0 AND @MaxPerMatch>0 AND @MaxPerMatch>@MaxMaxPerMatch)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language)
							END						
							+'(' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').', @ErrCode = 111
					
			return
		END
	END

	-- For soccer Parlay
	IF @UpdateMultiple = 0 OR @UpdateMinMaxBet = 1
	BEGIN
		if (@minbetv1MP<>0 and @maxbetv1MP <> 0 and  @minbetv1MP>@maxbetv1MP) or (@maxbetv1MP<> 0 and @maxpermatchv1MP <> 0 and @maxbetv1MP>@maxpermatchv1MP) 
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
							end						
							+ char(13) + char(10) + convert(varchar(20), @minbetv1MP) + '-' + convert(varchar(20), @maxbetv1MP) + '-' + convert(varchar(20), @maxpermatchv1MP), @ErrCode = 108
				
			return
			
		END
		
		IF (@MinMinBetv1MP>0 AND @minbetv1MP>0 AND @minbetv1MP<@MinMinBetv1MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': ' +
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv1mp) + ').', @ErrCode = 109
					
			return
		END
		
		IF (@MaxMaxBetv1MP>0 AND @maxbetv1MP>0 AND @maxbetv1MP>@MaxMaxBetv1MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language)
							END						
							+'(' + CONVERT(VARCHAR(20), @MaxMaxBetv1MP) + ').', @ErrCode = 110
					
			return
		END
		
		IF (@MaxMaxPerMatchv1MP>0 AND @maxpermatchv1MP>0 AND @maxpermatchv1MP>@MaxMaxPerMatchv1MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language)
							END						
							+'(' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv1MP) + ').', @ErrCode = 111
					
			return
		END
	END
	
	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv2 = 1
	BEGIN
		if (@MinBetv2 <> 0 and @MaxBetv2 <> 0 and @MinBetv2>@MaxBetv2) or (@MaxBetv2 <> 0 and @MaxPerMatchv2 <> 0 and @MaxBetv2>@MaxPerMatchv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv2) + '-' + convert(varchar(20), @MaxBetv2) + '-' + convert(varchar(20), @MaxPerMatchv2), @ErrCode = 112
					
			return
		END
		
		IF (@MinMinBetv2>0 AND @MinBetv2>0 AND @MinBetv2<@MinMinBetv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv2) + ').', @ErrCode = 113
					
			return
		END	
		IF (@MaxMaxBetv2>0 AND @MaxBetv2>0 AND @MaxBetv2>@MaxMaxBetv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv2) + ').', @ErrCode = 114
					
			return
		END
		
		IF (@MaxMaxPerMatchv2>0 AND @MaxPerMatchv2>0 AND @MaxPerMatchv2>@MaxMaxPerMatchv2)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv2) + ').', @ErrCode = 115
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv3 = 1
	BEGIN
		if (@MinBetv3 <> 0 and @MaxBetv3 <> 0 and @MinBetv3>@MaxBetv3) or (@MaxBetv3 <> 0 and @MaxPerMatchv3 <> 0 and @MaxBetv3>@MaxPerMatchv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'						end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv3) + '-' + convert(varchar(20), @MaxBetv3) + '-' + convert(varchar(20), @MaxPerMatchv3), @ErrCode = 116
					
			return
		END
		
		IF (@MinMinBetv3>0 AND @MinBetv3>0 AND @MinBetv3<@MinMinBetv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv3) + ').', @ErrCode = 117
					
			return
		END	
		IF (@MaxMaxBetv3>0 AND @MaxBetv3>0 AND @MaxBetv3>@MaxMaxBetv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv3) + ').', @ErrCode = 118
					
			return
		END
		
		IF (@MaxMaxPerMatchv3>0 AND @MaxPerMatchv3>0 AND @MaxPerMatchv3>@MaxMaxPerMatchv3)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv3) + ').', @ErrCode = 119
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv5 = 1
	BEGIN
		if (@MinBetv5 <> 0 and @MaxBetv5 <> 0 and @MinBetv5>@MaxBetv5) or (@MaxBetv5 <> 0 and @MaxPerMatchv5 <> 0 and @MaxBetv5>@MaxPerMatchv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv5) + '-' + convert(varchar(20), @MaxBetv5) + '-' + convert(varchar(20), @MaxPerMatchv5), @ErrCode = 120
					
			return
		END
		
		IF (@MinMinBetv5>0 AND @MinBetv5>0 AND @MinBetv5<@MinMinBetv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv5) + ').', @ErrCode = 121
					
			return
		END	
		IF (@MaxMaxBetv5>0 AND @MaxBetv5>0 AND @MaxBetv5>@MaxMaxBetv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'							
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv5) + ').', @ErrCode = 122
					
			return
		END
		
		IF (@MaxMaxPerMatchv5>0 AND @MaxPerMatchv5>0 AND @MaxPerMatchv5>@MaxMaxPerMatchv5)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match  (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv5) + ').', @ErrCode = 123
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv8 = 1
	BEGIN
		if (@MinBetv8 <> 0 and @MaxBetv8 <> 0 and @MinBetv8>@MaxBetv8) or (@MaxBetv8 <> 0 and @MaxPerMatchv8 <> 0 and @MaxBetv8>@MaxPerMatchv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv8) + '-' + convert(varchar(20), @MaxBetv8) + '-' + convert(varchar(20), @MaxPerMatchv8), @ErrCode = 124
					
			return
		END
		
		IF (@MinMinBetv8>0 AND @MinBetv8>0 AND @MinBetv8<@MinMinBetv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv8) + ').', @ErrCode = 125
					
			return
		END	
		IF (@MaxMaxBetv8>0 AND @MaxBetv8>0 AND @MaxBetv8>@MaxMaxBetv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv8) + ').', @ErrCode = 126
					
			return
		END
		
		IF (@MaxMaxPerMatchv8>0 AND @MaxPerMatchv8>0 AND @MaxPerMatchv8>@MaxMaxPerMatchv8)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv8) + ').', @ErrCode = 127
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv10 = 1
	BEGIN
		if (@MinBetv10 <> 0 and @MaxBetv10 <> 0 and @MinBetv10>@MaxBetv10) or (@MaxBetv10 <> 0 and @MaxPerMatchv10 <> 0 and @MaxBetv10>@MaxPerMatchv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv10) + '-' + convert(varchar(20), @MaxBetv10) + '-' + convert(varchar(20), @MaxPerMatchv10), @ErrCode = 128
					
			return
		END
		
		IF (@MinMinBetv10>0 AND @MinBetv10>0 AND @MinBetv10<@MinMinBetv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv10) + ').', @ErrCode = 129
					
			return
		END	
		IF (@MaxMaxBetv10>0 AND @MaxBetv10>0 AND @MaxBetv10>@MaxMaxBetv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv10) + ').', @ErrCode = 130
					
			return
		END
		
		IF (@MaxMaxPerMatchv10>0 AND @MaxPerMatchv10>0 AND @MaxPerMatchv10>@MaxMaxPerMatchv10)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv10) + ').', @ErrCode = 131
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv11 = 1
	BEGIN
		if (@MinBetv11 <> 0 and @MaxBetv11 <> 0 and @MinBetv11>@MaxBetv11) or (@MaxBetv11 <> 0 and @MaxPerMatchv11 <> 0 and @MaxBetv11>@MaxPerMatchv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv11) + '-' + convert(varchar(20), @MaxBetv11) + '-' + convert(varchar(20), @MaxPerMatchv11), @ErrCode = 132
					
			return
		END
		
		IF (@MinMinBetv11>0 AND @MinBetv11>0 AND @MinBetv11<@MinMinBetv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv11) + ').', @ErrCode = 133
					
			return
		END	
		IF (@MaxMaxBetv11>0 AND @MaxBetv11>0 AND @MaxBetv11>@MaxMaxBetv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'							
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv11) + ').', @ErrCode = 134
					
			return
		END
		
		IF (@MaxMaxPerMatchv11>0 AND @MaxPerMatchv11>0 AND @MaxPerMatchv11>@MaxMaxPerMatchv11)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv11) + ').', @ErrCode = 135
					
			return
		END
	END


	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv99 = 1
	BEGIN
		if (@MinBetv99 <> 0 and @MaxBetv99 <> 0 and @MinBetv99>@MaxBetv99) or (@MaxBetv99 <> 0 and @MaxPerMatchv99 <> 0 and @MaxBetv99>@MaxPerMatchv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv99) + '-' + convert(varchar(20), @MaxBetv99) + '-' + convert(varchar(20), @MaxPerMatchv99), @ErrCode = 136
					
			return
		END
		
		IF (@MinMinBetv99>0 AND @MinBetv99>0 AND @MinBetv99<@MinMinBetv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv99) + ').', @ErrCode = 137
					
			return
		END	
		IF (@MaxMaxBetv99>0 AND @MaxBetv99>0 AND @MaxBetv99>@MaxMaxBetv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv99) + ').', @ErrCode = 138
					
			return
		END
		
		IF (@MaxMaxPerMatchv99>0 AND @MaxPerMatchv99>0 AND @MaxPerMatchv99>@MaxMaxPerMatchv99)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv99) + ').', @ErrCode = 139
					
			return
		END
	END


	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv99MP = 1
	BEGIN
		if (@MinBetv99MP <> 0 and @MaxBetv99MP <> 0 and @MinBetv99MP>@MaxBetv99MP) or (@MaxBetv99MP <> 0 and @MaxPerMatchv99MP <> 0 and @MaxBetv99MP>@MaxPerMatchv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
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
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv99MP) + '-' + convert(varchar(20), @MaxBetv99MP) + '-' + convert(varchar(20), @MaxPerMatchv99MP), @ErrCode = 140
					
			return
		END
		
		IF (@MinMinBetv99MP>0 AND @MinBetv99MP>0 AND @MinBetv99MP<@MinMinBetv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv99MP) + ').', @ErrCode = 141
					
			return
		END	
		IF (@MaxMaxBetv99MP>0 AND @MaxBetv99MP>0 AND @MaxBetv99MP>@MaxMaxBetv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv99MP) + ').', @ErrCode = 142
					
			return
		END
		
		IF (@MaxMaxPerMatchv99MP>0 AND @MaxPerMatchv99MP>0 AND @MaxPerMatchv99MP>@MaxMaxPerMatchv99MP)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Mix Sports Parlay)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + case @Language 
																								when 'CS' then N'(供混合体育过关)'
																								when 'CT' then N'(供混合體育過關)'
																								when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																								when 'J' then N'(Mix Sports Parlay)'
																								when 'KO' then N'(Mix Sports Parlay)'
																								when 'VI' then N'(Mix Sports Parlay)'
																								else N'(Mix Sports Parlay)' END
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv99MP) + ').', @ErrCode = 143
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv154 = 1
	BEGIN
		if (@MinBetv154 <> 0 and @MaxBetv154 <> 0 and @MinBetv154>@MaxBetv154) or (@MaxBetv154 <> 0 and @MaxPerMatchv154 <> 0 and @MaxBetv154>@MaxPerMatchv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv154) + '-' + convert(varchar(20), @MaxBetv154) + '-' + convert(varchar(20), @MaxPerMatchv154), @ErrCode = 132
					
			return
		END
		
		IF (@MinMinBetv154>0 AND @MinBetv154>0 AND @MinBetv154<@MinMinBetv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv154) + ').', @ErrCode = 133
					
			return
		END	
		IF (@MaxMaxBetv154>0 AND @MaxBetv154>0 AND @MaxBetv154>@MaxMaxBetv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'							
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv154) + ').', @ErrCode = 134
					
			return
		END
		
		IF (@MaxMaxPerMatchv154>0 AND @MaxPerMatchv154>0 AND @MaxPerMatchv154>@MaxMaxPerMatchv154)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for HR Fixed Odds)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv154) + ').', @ErrCode = 135
					
			return
		END
	END

	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv161 = 1
	BEGIN
		if (@MinBetv161 <> 0 and @MaxBetv161 <> 0 and @MinBetv161>@MaxBetv161) or (@MaxBetv161<> 0 and @MaxPerMatchv161 <> 0 and @MaxBetv161>@MaxPerMatchv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end						
							+ char(13) + char(10) + convert(varchar(20), @MinBetv161) + '-' + convert(varchar(20), @MaxBetv161) + '-' + convert(varchar(20), @MaxPerMatchv161), @ErrCode = 144
					
			return
		END
		
		IF (@MinMinBetv161>0 AND @MinBetv161>0 AND @MinBetv161<@MinMinBetv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBetv161) + ').', @ErrCode = 145
					
			return
		END	
		IF (@MaxMaxBetv161>0 AND @MaxBetv161>0 AND @MaxBetv161>@MaxMaxBetv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxBetv161) + ').', @ErrCode = 146
					
			return
		END
		
		IF (@MaxMaxPerMatchv161>0 AND @MaxPerMatchv161>0 AND @MaxPerMatchv161>@MaxMaxPerMatchv161)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							END						
							+' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatchv161) + ').', @ErrCode = 147
					
			return
		END
		/* ------------- viet --comment this
		--- max per ball
		if @MaxPerBallv161 < @MaxBetv161 or @MaxPerBallv161 > @MaxPerMatchv161
		begin
			SELECT @ErrMsg =	@UserName + ': '+
				CASE @Language 
					WHEN 'E' THEN 'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
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
			SELECT @ErrMsg = @UserName + ': ' +
				CASE @Language 
					WHEN 'E' THEN 'Max Per Ball must equal to or less than Agent Max Per Ball (Number Game).'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10009,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
				END
				+' (' + CONVERT(VARCHAR(20), @MaxMaxPerBallv161) + ').', @ErrCode = 201				
			return
		end
		
	END



	----------
	UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
	SET
		MinBet=CASE WHEN @UpdateMultiple = 1 AND ((@UpdateMinMaxBet = 0 AND sporttype=1 AND bettype <> 9)
													OR (@UpdateMinMaxBetv2 = 0 AND sporttype=2)
													OR (@UpdateMinMaxBetv3 = 0 AND sporttype=3)
													OR (@UpdateMinMaxBetv5 = 0 AND sporttype=5)
													OR (@UpdateMinMaxBetv8 = 0 AND sporttype=8)
													OR (@UpdateMinMaxBetv10 = 0 AND sporttype=10)
													OR (@UpdateMinMaxBetv11 = 0 AND sporttype=11)
													OR (@UpdateMinMaxBetv99 = 0 AND sporttype=99 AND bettype<>9)
													OR (@UpdateMinMaxBetv99MP = 0 AND sporttype=99 AND bettype=9)
													OR (@UpdateMinMaxBetv1MP = 0 AND sporttype=1 AND bettype=9)
													OR (@UpdateMinMaxBetv154 = 0 AND sporttype=154)
													) THEN MinBet ELSE CASE sporttype WHEN 1 THEN (CASE bettype WHEN 9 THEN @MinBetv1MP ELSE @MinBet END)  WHEN 2 THEN @MinBetv2 WHEN 3 THEN @MinBetv3 WHEN 5 THEN @MinBetv5 WHEN 8 THEN @MinBetv8 WHEN 10 THEN @MinBetv10 WHEN 11 THEN @MinBetv11 WHEN 154 THEN @MinBetv154 WHEN 99 THEN (CASE bettype WHEN 9 THEN @MinBetv99MP ELSE @MinBetv99 END) ELSE minbet END END,
		MaxBet=CASE WHEN @UpdateMultiple = 1 AND ((@UpdateMinMaxBet = 0 AND sporttype=1 AND bettype <> 9)
													OR (@UpdateMinMaxBetv2 = 0 AND sporttype=2)
													OR (@UpdateMinMaxBetv3 = 0 AND sporttype=3)
													OR (@UpdateMinMaxBetv5 = 0 AND sporttype=5)
													OR (@UpdateMinMaxBetv8 = 0 AND sporttype=8)
													OR (@UpdateMinMaxBetv10 = 0 AND sporttype=10)
													OR (@UpdateMinMaxBetv11 = 0 AND sporttype=11)
													OR (@UpdateMinMaxBetv99 = 0 AND sporttype=99 AND bettype<>9)
													OR (@UpdateMinMaxBetv99MP = 0 AND sporttype=99 AND bettype=9)
													OR (@UpdateMinMaxBetv1MP = 0 AND sporttype=1 AND bettype=9)
													OR (@UpdateMinMaxBetv154 = 0 AND sporttype=154)
													) THEN MaxBet ELSE CASE sporttype WHEN 1 THEN (CASE bettype WHEN 9 THEN @MaxBetv1MP ELSE @MaxBet END) WHEN 2 THEN @MaxBetv2 WHEN 3 THEN @MaxBetv3 WHEN 5 THEN @MaxBetv5 WHEN 8 THEN @MaxBetv8 WHEN 10 THEN @MaxBetv10 WHEN 11 THEN @MaxBetv11 WHEN 154 THEN @MaxBetv154 WHEN 99 THEN (CASE bettype WHEN 9 THEN @MaxBetv99MP ELSE @MaxBetv99 END) ELSE maxbet END END
	WHERE custid=@custid

	SELECT @err1 = @@error


	--for Number Game
	SELECT @err2 = 0
	IF @UpdateMultiple = 0 OR @UpdateMinMaxBetv161 = 1
	BEGIN
		UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
		SET
			MinBet = @MinBetv161,
			MaxBet = @MaxBetv161

		WHERE custid = @custid AND sporttype = 161
		
		SELECT @err2 = @@error
	END


	if (@err1 <> 0 OR @err2 <> 0)
	begin
		
		Select @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 148
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
		@maxpermatchv99MP = @maxpermatchv99MP,
		@maxpermatchv1MP = @maxpermatchv1MP,
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

	Select @LogSPData ='<Acc_CustomerUpdMember_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
	'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1)) + '" ' +
	'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1)) + '" ' +
	'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1)) + '" ' +
	'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1)) + '" ' +
	'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1)) + '" ' +
	'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1)) + '" ' +
	'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1))  + '" ' +
	'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1)) + '" ' +
	'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1)) + '" ' +
	'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1)) + '" ' +
	'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1)) + '" ' +
	'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1)) + '" ' +
	'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1)) + '" ' +
	'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1)) + '" ' +
	'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1)) + '" ' +
	'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1)) + '" ' +
	'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1)) + '" ' +
	'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1))  + '" ' +
	'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1)) + '" ' +
	'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1)) + '" ' +
	'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1)) + '" ' +
	'MinBv99MP="'+ coalesce(cast(@minbetv99MP as varchar(50)),space(1)) + '" ' +
	'MaxBv99MP="'+ coalesce(cast(@maxbetv99MP as varchar(50)),space(1)) + '" ' +
	'MPMv99MP="'+ coalesce(cast(@maxpermatchv99MP as varchar(50)),space(1)) + '" ' +
	
	'MinBv1MP="'+ coalesce(cast(@minbetv1MP as varchar(50)),space(1)) + '" ' +
	'MaxBv1MP="'+ coalesce(cast(@maxbetv1MP as varchar(50)),space(1)) + '" ' +
	'MPMv1MP="'+ coalesce(cast(@maxpermatchv1MP as varchar(50)),space(1)) + '" ' +
	
	'MinBv154="'+ coalesce(cast(@minbetv154 as varchar(50)),space(1))+ '" ' +
	'MaxBv154="'+ coalesce(cast(@maxbetv154 as varchar(50)),space(1))+ '" ' +
	'MPMv154="'+ coalesce(cast(@maxpermatchv154 as varchar(50)),space(1))+ '" ' +
	'MinBv161="'+ coalesce(cast(@minbetv161 as varchar(50)),space(1)) + '" ' +
	'MaxBv161="'+ coalesce(cast(@maxbetv161 as varchar(50)),space(1)) + '" ' +
	'MPMv161="'+ coalesce(cast(@maxpermatchv161 as varchar(50)),space(1)) + '" ' +
	'MPBv161 ="' + coalesce(cast(@MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
	'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
	'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
	'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
	'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
	'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
	'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
	'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
	'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
	'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

	Select @TrackingValue2 ='<Acc_CustomerUpdMember_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@Old_minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@Old_maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@Old_maxpermatch as varchar(50)),space(1)) + '" ' +
	'MinBv2="'+ coalesce(cast(@Old_minbetv2 as varchar(50)),space(1)) + '" ' +
	'MaxBv2="'+ coalesce(cast(@Old_maxbetv2 as varchar(50)),space(1)) + '" ' +
	'MPMv2="'+ coalesce(cast(@Old_maxpermatchv2 as varchar(50)),space(1)) + '" ' +
	'MinBv3="'+ coalesce(cast(@Old_minbetv3 as varchar(50)),space(1)) + '" ' +
	'MaxBv3="'+ coalesce(cast(@Old_maxbetv3 as varchar(50)),space(1)) + '" ' +
	'MPMv3="'+ coalesce(cast(@Old_maxpermatchv3 as varchar(50)),space(1)) + '" ' +
	'MinBv5="'+ coalesce(cast(@Old_minbetv5 as varchar(50)),space(1))  + '" ' +
	'MaxBv5="'+ coalesce(cast(@Old_maxbetv5 as varchar(50)),space(1)) + '" ' +
	'MPMv5="'+ coalesce(cast(@Old_maxpermatchv5 as varchar(50)),space(1)) + '" ' +
	'MinBv8="'+ coalesce(cast(@Old_minbetv8 as varchar(50)),space(1)) + '" ' +
	'MaxBv8="'+ coalesce(cast(@Old_maxbetv8 as varchar(50)),space(1)) + '" ' +
	'MPMv8="'+ coalesce(cast(@Old_maxpermatchv8 as varchar(50)),space(1)) + '" ' +
	'MinBv10="'+ coalesce(cast(@Old_minbetv10 as varchar(50)),space(1)) + '" ' +
	'MaxBv10="'+ coalesce(cast(@Old_maxbetv10 as varchar(50)),space(1)) + '" ' +
	'MPMv10="'+ coalesce(cast(@Old_maxpermatchv10 as varchar(50)),space(1)) + '" ' +
	'MinBv11="'+ coalesce(cast(@Old_minbetv11 as varchar(50)),space(1)) + '" ' +
	'MaxBv11="'+ coalesce(cast(@Old_maxbetv11 as varchar(50)),space(1)) + '" ' +
	'MPMv11="'+ coalesce(cast(@Old_maxpermatchv11 as varchar(50)),space(1))  + '" ' +
	'MinBv99="'+ coalesce(cast(@Old_minbetv99 as varchar(50)),space(1)) + '" ' +
	'MaxBv99="'+ coalesce(cast(@Old_maxbetv99 as varchar(50)),space(1)) + '" ' +
	'MPMv99="'+ coalesce(cast(@Old_maxpermatchv99 as varchar(50)),space(1)) + '" ' +
	'MinBv99MP="'+ coalesce(cast(@Old_minbetv99MP as varchar(50)),space(1)) + '" ' +
	'MaxBv99MP="'+ coalesce(cast(@Old_maxbetv99MP as varchar(50)),space(1)) + '" ' +
	'MPMv99MP="'+ coalesce(cast(@Old_maxpermatchv99MP as varchar(50)),space(1)) + '" ' +
	
	'MinBv1MP="'+ coalesce(cast(@Old_minbetv1MP as varchar(50)),space(1)) + '" ' +
	'MaxBv1MP="'+ coalesce(cast(@Old_maxbetv1MP as varchar(50)),space(1)) + '" ' +
	'MPMv1MP="'+ coalesce(cast(@Old_maxpermatchv1MP as varchar(50)),space(1)) + '" ' +
	
	'MinBv154="'+ coalesce(cast(@Old_minbetv154 as varchar(50)),space(1))+ '" ' +
	'MaxBv154="'+ coalesce(cast(@Old_maxbetv154 as varchar(50)),space(1))+ '" ' +
	'MPMv154="'+ coalesce(cast(@Old_maxpermatchv154 as varchar(50)),space(1))+ '" ' +
	'MinBv161="'+ coalesce(cast(@Old_minbetv161 as varchar(50)),space(1)) + '" ' +
	'MaxBv161="'+ coalesce(cast(@Old_maxbetv161 as varchar(50)),space(1)) + '" ' +
	'MPMv161="'+ coalesce(cast(@Old_maxpermatchv161 as varchar(50)),space(1)) + '" ' +
	'MPBv161 ="' + coalesce(cast(@Old_MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
	'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
	'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
	'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
	'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
	'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
	'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
	'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
	'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
	'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +
	
	'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
	'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 307,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH		

		Select @LogSPData ='<Acc_CustomerUpdMember_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
		'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
		'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
		'MinBv2="'+ coalesce(cast(@minbetv2 as varchar(50)),space(1)) + '" ' +
		'MaxBv2="'+ coalesce(cast(@maxbetv2 as varchar(50)),space(1)) + '" ' +
		'MPMv2="'+ coalesce(cast(@maxpermatchv2 as varchar(50)),space(1)) + '" ' +
		'MinBv3="'+ coalesce(cast(@minbetv3 as varchar(50)),space(1)) + '" ' +
		'MaxBv3="'+ coalesce(cast(@maxbetv3 as varchar(50)),space(1)) + '" ' +
		'MPMv3="'+ coalesce(cast(@maxpermatchv3 as varchar(50)),space(1)) + '" ' +
		'MinBv5="'+ coalesce(cast(@minbetv5 as varchar(50)),space(1))  + '" ' +
		'MaxBv5="'+ coalesce(cast(@maxbetv5 as varchar(50)),space(1)) + '" ' +
		'MPMv5="'+ coalesce(cast(@maxpermatchv5 as varchar(50)),space(1)) + '" ' +
		'MinBv8="'+ coalesce(cast(@minbetv8 as varchar(50)),space(1)) + '" ' +
		'MaxBv8="'+ coalesce(cast(@maxbetv8 as varchar(50)),space(1)) + '" ' +
		'MPMv8="'+ coalesce(cast(@maxpermatchv8 as varchar(50)),space(1)) + '" ' +
		'MinBv10="'+ coalesce(cast(@minbetv10 as varchar(50)),space(1)) + '" ' +
		'MaxBv10="'+ coalesce(cast(@maxbetv10 as varchar(50)),space(1)) + '" ' +
		'MPMv10="'+ coalesce(cast(@maxpermatchv10 as varchar(50)),space(1)) + '" ' +
		'MinBv11="'+ coalesce(cast(@minbetv11 as varchar(50)),space(1)) + '" ' +
		'MaxBv11="'+ coalesce(cast(@maxbetv11 as varchar(50)),space(1)) + '" ' +
		'MPMv11="'+ coalesce(cast(@maxpermatchv11 as varchar(50)),space(1))  + '" ' +
		'MinBv99="'+ coalesce(cast(@minbetv99 as varchar(50)),space(1)) + '" ' +
		'MaxBv99="'+ coalesce(cast(@maxbetv99 as varchar(50)),space(1)) + '" ' +
		'MPMv99="'+ coalesce(cast(@maxpermatchv99 as varchar(50)),space(1)) + '" ' +
		'MinBv99MP="'+ coalesce(cast(@minbetv99MP as varchar(50)),space(1)) + '" ' +
		'MaxBv99MP="'+ coalesce(cast(@maxbetv99MP as varchar(50)),space(1)) + '" ' +
		'MPMv99MP="'+ coalesce(cast(@maxpermatchv99MP as varchar(50)),space(1)) + '" ' +
		
		'MinBv1MP="'+ coalesce(cast(@minbetv1MP as varchar(50)),space(1)) + '" ' +
		'MaxBv1MP="'+ coalesce(cast(@maxbetv1MP as varchar(50)),space(1)) + '" ' +
		'MPMv1MP="'+ coalesce(cast(@maxpermatchv1MP as varchar(50)),space(1)) + '" ' +
		
		'MinBv154="'+ coalesce(cast(@minbetv154 as varchar(50)),space(1))+ '" ' +
		'MaxBv154="'+ coalesce(cast(@maxbetv154 as varchar(50)),space(1))+ '" ' +
		'MPMv154="'+ coalesce(cast(@maxpermatchv154 as varchar(50)),space(1))+ '" ' +
		'MinBv161="'+ coalesce(cast(@minbetv161 as varchar(50)),space(1)) + '" ' +
		'MaxBv161="'+ coalesce(cast(@maxbetv161 as varchar(50)),space(1)) + '" ' +
		'MPMv161="'+ coalesce(cast(@maxpermatchv161 as varchar(50)),space(1)) + '" ' +
		'MPBv161 ="' + coalesce(cast(@MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
		'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
		'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
		'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
		'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
		'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
		'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
		'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
		'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
		'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
		'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +
		
		'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +
		
		'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
		'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'

		Select @TrackingValue2 ='<Acc_CustomerUpdMember_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'MinB="'+ coalesce(cast(@Old_minbet as varchar(50)),space(1)) + '" ' +
		'MaxB="'+ coalesce(cast(@Old_maxbet as varchar(50)),space(1)) + '" ' +
		'MPM="'+ coalesce(cast(@Old_maxpermatch as varchar(50)),space(1)) + '" ' +
		'MinBv2="'+ coalesce(cast(@Old_minbetv2 as varchar(50)),space(1)) + '" ' +
		'MaxBv2="'+ coalesce(cast(@Old_maxbetv2 as varchar(50)),space(1)) + '" ' +
		'MPMv2="'+ coalesce(cast(@Old_maxpermatchv2 as varchar(50)),space(1)) + '" ' +
		'MinBv3="'+ coalesce(cast(@Old_minbetv3 as varchar(50)),space(1)) + '" ' +
		'MaxBv3="'+ coalesce(cast(@Old_maxbetv3 as varchar(50)),space(1)) + '" ' +
		'MPMv3="'+ coalesce(cast(@Old_maxpermatchv3 as varchar(50)),space(1)) + '" ' +
		'MinBv5="'+ coalesce(cast(@Old_minbetv5 as varchar(50)),space(1))  + '" ' +
		'MaxBv5="'+ coalesce(cast(@Old_maxbetv5 as varchar(50)),space(1)) + '" ' +
		'MPMv5="'+ coalesce(cast(@Old_maxpermatchv5 as varchar(50)),space(1)) + '" ' +
		'MinBv8="'+ coalesce(cast(@Old_minbetv8 as varchar(50)),space(1)) + '" ' +
		'MaxBv8="'+ coalesce(cast(@Old_maxbetv8 as varchar(50)),space(1)) + '" ' +
		'MPMv8="'+ coalesce(cast(@Old_maxpermatchv8 as varchar(50)),space(1)) + '" ' +
		'MinBv10="'+ coalesce(cast(@Old_minbetv10 as varchar(50)),space(1)) + '" ' +
		'MaxBv10="'+ coalesce(cast(@Old_maxbetv10 as varchar(50)),space(1)) + '" ' +
		'MPMv10="'+ coalesce(cast(@Old_maxpermatchv10 as varchar(50)),space(1)) + '" ' +
		'MinBv11="'+ coalesce(cast(@Old_minbetv11 as varchar(50)),space(1)) + '" ' +
		'MaxBv11="'+ coalesce(cast(@Old_maxbetv11 as varchar(50)),space(1)) + '" ' +
		'MPMv11="'+ coalesce(cast(@Old_maxpermatchv11 as varchar(50)),space(1))  + '" ' +
		'MinBv99="'+ coalesce(cast(@Old_minbetv99 as varchar(50)),space(1)) + '" ' +
		'MaxBv99="'+ coalesce(cast(@Old_maxbetv99 as varchar(50)),space(1)) + '" ' +
		'MPMv99="'+ coalesce(cast(@Old_maxpermatchv99 as varchar(50)),space(1)) + '" ' +
		'MinBv99MP="'+ coalesce(cast(@Old_minbetv99MP as varchar(50)),space(1)) + '" ' +
		'MaxBv99MP="'+ coalesce(cast(@Old_maxbetv99MP as varchar(50)),space(1)) + '" ' +
		'MPMv99MP="'+ coalesce(cast(@Old_maxpermatchv99MP as varchar(50)),space(1)) + '" ' +
		
		'MinBv1MP="'+ coalesce(cast(@Old_minbetv1MP as varchar(50)),space(1)) + '" ' +
		'MaxBv1MP="'+ coalesce(cast(@Old_maxbetv1MP as varchar(50)),space(1)) + '" ' +
		'MPMv1MP="'+ coalesce(cast(@Old_maxpermatchv1MP as varchar(50)),space(1)) + '" ' +
		
		'MinBv154="'+ coalesce(cast(@Old_minbetv154 as varchar(50)),space(1))+ '" ' +
		'MaxBv154="'+ coalesce(cast(@Old_maxbetv154 as varchar(50)),space(1))+ '" ' +
		'MPMv154="'+ coalesce(cast(@Old_maxpermatchv154 as varchar(50)),space(1))+ '" ' +
		'MinBv161="'+ coalesce(cast(@Old_minbetv161 as varchar(50)),space(1)) + '" ' +
		'MaxBv161="'+ coalesce(cast(@Old_maxbetv161 as varchar(50)),space(1)) + '" ' +
		'MPMv161="'+ coalesce(cast(@Old_maxpermatchv161 as varchar(50)),space(1)) + '" ' +
		'MPBv161 ="' + coalesce(cast(@Old_MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
		'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
		'UMMB="'+ coalesce(cast(@UpdateMinMaxBet as varchar(50)),space(1)) + '" ' +
		'UMMBv2="'+ coalesce(cast(@UpdateMinMaxBetv2 as varchar(50)),space(1)) + '" ' +
		'UMMBv3="'+ coalesce(cast(@UpdateMinMaxBetv3 as varchar(50)),space(1)) + '" ' +
		'UMMBv5="'+ coalesce(cast(@UpdateMinMaxBetv5 as varchar(50)),space(1)) + '" ' +
		'UMMBv8="'+ coalesce(cast(@UpdateMinMaxBetv8 as varchar(50)),space(1)) + '" ' +
		'UMMBv10="'+ coalesce(cast(@UpdateMinMaxBetv10 as varchar(50)),space(1)) + '" ' +
		'UMMBv11="'+ coalesce(cast(@UpdateMinMaxBetv11 as varchar(50)),space(1)) + '" ' +
		'UMMBv99="'+ coalesce(cast(@UpdateMinMaxBetv99 as varchar(50)),space(1)) + '" ' +
		'UMMBv99MP="'+ coalesce(cast(@UpdateMinMaxBetv99MP as varchar(50)),space(1)) + '" ' +
		
		'UMMBv1MP="'+ coalesce(cast(@UpdateMinMaxBetv1MP as varchar(50)),space(1)) + '" ' +
		
		'UMMBv154="'+ coalesce(cast(@UpdateMinMaxBetv154 as varchar(50)),space(1))+ '" ' +
		'UMMBv161="'+ coalesce(cast(@UpdateMinMaxBetv161 as varchar(50)),space(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 307,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration		
	END CATCH
	---------------------------------------------------------
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxBet] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_MinMaxBet] TO [vnteam] AS [dbo]