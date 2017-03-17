ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_MinMaxBet]
	@custid int,
	
	@MinBet money,
	@MaxBet money,
	@MaxPerMatch money,
	
	@MinBetv2 money,
	@MaxBetv2 money,
	@MaxPerMatchv2 money,

	@MinBetv3 money,
	@MaxBetv3 money,
	@MaxPerMatchv3 money,

	@MinBetv5 money,
	@MaxBetv5 money,
	@MaxPerMatchv5 money,

	@MinBetv8 money,
	@MaxBetv8 money,
	@MaxPerMatchv8 money,

	@MinBetv10 money,
	@MaxBetv10 money,
	@MaxPerMatchv10 money,

	@MinBetv11 money,
	@MaxBetv11 money,
	@MaxPerMatchv11 money,

	@MinBetv99 money,
	@MaxBetv99 money,
	@MaxPerMatchv99 money,	
	
	@MinBetv99MP money,
	@MaxBetv99MP money,
	@MaxPerMatchv99MP money,	
	
	@MinBetv1MP money,
	@MaxBetv1MP money,
	@MaxPerMatchv1MP money,	
	
	@MinBetv154 MONEY = 0,
	@MaxBetv154 MONEY = 0,
	@MaxPerMatchv154 MONEY = 0,
	
	@MinBetv161 money,
	@MaxBetv161 money,
	@MaxPerMatchv161 money,

	@MaxPerBallv161 money = 0,	

	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080514@Thien
Task : Update MinBet, MaxBet, MaxPerMatch
DB: DBTXN/bodb02
Original: [Acc_CustomerUpdSuper_MinMaxBet]
Revisions:
    - 20090424@Phuc:Separate finance sporttype(201).
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100901@Henry: Add Number Game + Mix Parlay Mixed Sports
	- 20101019@Henry: Record execution time
	- 20101027@Lukas: Add max per ball(number game)
	- 20110606@Amy: Write log Old values
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sportype by link database)
	- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	----- David @ 09 JUN 2015 -------------------
	DECLARE @tmp_Sports TABLE (SportType TINYINT, SportName NVARCHAR(50))
	
	BEGIN TRY
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)		
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)	
	END CATCH
	----- /David @ 09 JUN 2015 -------------------
	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	declare @ErrType varchar(1000)

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

	if 
		@MinBet<0
		or @MaxBet < 0
		or @MaxPerMatch <0
		
		or @MinBetv2 <0
		or @MaxBetv2 <0
		or @MaxPerMatchv2 <0

		or @MinBetv3 <0
		or @MaxBetv3 <0
		or @MaxPerMatchv3 <0

		or @MinBetv5 <0
		or @MaxBetv5 <0
		or @MaxPerMatchv5 <0

		or @MinBetv8 <0
		or @MaxBetv8 <0
		or @MaxPerMatchv8 <0

		or @MinBetv10 <0
		or @MaxBetv10 <0
		or @MaxPerMatchv10 <0

		or @MinBetv11 <0
		or @MaxBetv11 <0
		or @MaxPerMatchv11 <0

		or @MinBetv99 <0
		or @MaxBetv99 <0
		or @MaxPerMatchv99 <0
		
		or @MinBetv99MP <0
		or @MaxBetv99MP <0
		or @MaxPerMatchv99MP <0
		
		or @MinBetv1MP <0
		or @MaxBetv1MP <0
		or @MaxPerMatchv1MP <0
		
		or @MinBetv154 <0
		or @MaxBetv154 <0
		or @MaxPerMatchv154 <0
		
		or @MinBetv161 <0
		or @MaxBetv161 <0
		or @MaxPerMatchv161 <0
	BEGIN
		 
		Select @ErrMsg = case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)				
						end, @ErrCode = 101
		return
	END

	if @MaxPerBallv161 < 0
	begin
		Select @ErrMsg = case @Language 
							when 'E' then 'Wrong Max Per Ball (Number Game).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10002,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
						end, @ErrCode = 106
		return
	end

	select @ErrType = ''
	select @ErrType = @ErrType +  (case when MP=0 then s.sportname else 'Mixed Sports' end )       + ', '
	from @tmp_Sports s inner join
	(
					select 1 as sporttype,0 as MP, @MinBet as MinBet, @MaxBet as MaxBet, @MaxPerMatch as MaxPerMatch
		union all	select 2 as sporttype,0 as MP, @MinBetv2 as MinBet, @MaxBetv2 as MaxBet, @MaxPerMatchv2 as MaxPerMatch
		union all	select 3 as sporttype,0 as MP, @MinBetv3 as MinBet, @MaxBetv3 as MaxBet, @MaxPerMatchv3 as MaxPerMatch
		union all	select 5 as sporttype,0 as MP, @MinBetv5 as MinBet, @MaxBetv5 as MaxBet, @MaxPerMatchv5 as MaxPerMatch
		union all	select 8 as sporttype,0 as MP, @MinBetv8 as MinBet, @MaxBetv8 as MaxBet, @MaxPerMatchv8 as MaxPerMatch
		union all	select 10 as sporttype,0 as MP, @MinBetv10 as MinBet, @MaxBetv10 as MaxBet, @MaxPerMatchv10 as MaxPerMatch
		union all	select 11 as sporttype,0 as MP, @MinBetv11 as MinBet, @MaxBetv11 as MaxBet, @MaxPerMatchv11 as MaxPerMatch
		union all	select 99 as sporttype,0 as MP, @MinBetv99 as MinBet, @MaxBetv99 as MaxBet, @MaxPerMatchv99 as MaxPerMatch	 
		union all	select 99 as sporttype,1 as MP, @MinBetv99MP as MinBet, @MaxBetv99MP as MaxBet, @MaxPerMatchv99MP as MaxPerMatch	 
		
		union all	select 1 as sporttype,1 as MP, @MinBetv1MP as MinBet, @MaxBetv1MP as MaxBet, @MaxPerMatchv1MP as MaxPerMatch	 
		
		union all	select 154 as sporttype,0 as MP, @MinBetv154 as MinBet, @MaxBetv154 as MaxBet, @MaxPerMatchv154 as MaxPerMatch	 
		union all	select 161 as sporttype,0 as MP, @MinBetv161 as MinBet, @MaxBetv161 as MaxBet, @MaxPerMatchv161 as MaxPerMatch	 
	) as b on s.sporttype = b.sporttype
	where (MinBet<>0 and MaxBet <> 0 and  MinBet>MaxBet) 
	or (MaxBet<> 0 and MaxPerMatch <> 0 and MaxBet>MaxPerMatch) 
	or (MinBet <> 0 and MaxPerMatch <> 0 and MinBet>MaxPerMatch) 

	if @ErrType <>''
	BEGIN
		SELECT
			@ErrMsg =	case @Language 
								when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match ('+@ErrType+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) + ' ('+@ErrType+').'
						end, @ErrCode = 102
		RETURN
	END
	/* ------------- viet --comment this
	IF @MaxPerBallv161 < @MaxBetv161 or @MaxPerBallv161 > @MaxPerMatchv161
	BEGIN
		SELECT
			@ErrMsg =	case @Language 
								when 'E' then 'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match (Number Game).'
								when 'CS' then N'单粒球最高投注必須大於或等於最高投注和低於或等於单场場游戏最高投注.'
								when 'CT' then N'單粒球最高投注必須大於或等於最高投注和低於或等於單場場遊戲最高投注.'
								when 'TH' then N'ขออภัย, ค่าสูงสุดต่อบอลต้องมากกว่าหรือเท่ากับการเดิมพันสูงสุด และน้อยกว่าหรือเท่ากับการตั้งค่าสูงสุดของการแข่งขัน.'
								else N'Max per ball must be greater than or equal to max bet and less than or equal to max per match (Number Game).'
						end, @ErrCode = 105
		RETURN
	END
	*/

	update custsetting with (ROWLOCK, UPDLOCK)
	set	
		MinBet = case sporttype when 1 then (case bettype when 9 then @MinBetv1MP else @MinBet end) when 2 then @MinBetv2 when 3 then @MinBetv3 when 5 then @MinBetv5 when 8 then @MinBetv8 when 10 then @MinBetv10 when 11 then @MinBetv11 when 99 then (case bettype when 9 then @MinBetv99MP else @MinBetv99 end) when 154 then @MinBetv154  else MinBet end,
		MaxBet = case sporttype when 1 then (case bettype when 9 then @MaxBetv1MP else @MaxBet end)  when 2 then @MaxBetv2 when 3 then @MaxBetv3 when 5 then @MaxBetv5 when 8 then @MaxBetv8 when 10 then @MaxBetv10 when 11 then @MaxBetv11 when 99 then (case bettype when 9 then @MaxBetv99MP else @MaxBetv99 end)  when 154 then @MaxBetv154 else MaxBet end
	where custid=@custid
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 103 
		return
	end

	--v161
	update custsetting3rd with (ROWLOCK, UPDLOCK)
	set	
		MinBet = @MinBetv161,
		MaxBet = @MaxBetv161
	where 
		custid=@custid
		AND sporttype = 161
	if (@@error <> 0)
	begin
		
		Select @ErrMsg = case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 104 
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
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	if @ErrCode > 0
	BEGIN
		return
	END

	EXEC dbo.Acc_CustomerUpdMaxPerBall
		@custid = @custid,
		@maxperballv161 = @maxperballv161,	
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	if @ErrCode > 0
	BEGIN
		return
	END


	Declare @LogSPData varchar(8000)
	Declare @TrackingValue2 varchar(8000)

	Select @LogSPData ='<Acc_CustomerUpdSuper_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1))+ '" ' +
	'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1))+ '" ' +
	'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1))+ '" ' +
	'MinBv2="'+ coalesce(cast(@MinBetv2 as varchar(50)),space(1))+ '" ' +
	'MaxBv2="'+ coalesce(cast(@MaxBetv2 as varchar(50)),space(1))+ '" ' +
	'MPMv2="'+ coalesce(cast(@MaxPerMatchv2 as varchar(50)),space(1))+ '" ' +
	'MinBv3="'+ coalesce(cast(@MinBetv3 as varchar(50)),space(1))+ '" ' +
	'MaxBv3="'+ coalesce(cast(@MaxBetv3 as varchar(50)),space(1))+ '" ' +
	'MPMv3="'+ coalesce(cast(@MaxPerMatchv3 as varchar(50)),space(1))+ '" ' +
	'MinBv5="'+ coalesce(cast(@MinBetv5 as varchar(50)),space(1))+ '" ' +
	'MaxBv5="'+ coalesce(cast(@MaxBetv5 as varchar(50)),space(1))+ '" ' +
	'MPMv5="'+ coalesce(cast(@MaxPerMatchv5 as varchar(50)),space(1))+ '" ' +
	'MinBv8="'+ coalesce(cast(@MinBetv8 as varchar(50)),space(1))+ '" ' +
	'MaxBv8="'+ coalesce(cast(@MaxBetv8 as varchar(50)),space(1))+ '" ' +
	'MPMv8="'+ coalesce(cast(@MaxPerMatchv8 as varchar(50)),space(1))+ '" ' +
	'MinBv10="'+ coalesce(cast(@MinBetv10 as varchar(50)),space(1))+ '" ' +
	'MaxBv10="'+ coalesce(cast(@MaxBetv10 as varchar(50)),space(1))+ '" ' +
	'MPMv10="'+ coalesce(cast(@MaxPerMatchv10 as varchar(50)),space(1))+ '" ' +
	'MinBv11="'+ coalesce(cast(@MinBetv11 as varchar(50)),space(1))+ '" ' +
	'MaxBv11="'+ coalesce(cast(@MaxBetv11 as varchar(50)),space(1))+ '" ' +
	'MPMv11="'+ coalesce(cast(@MaxPerMatchv11 as varchar(50)),space(1))+ '" ' +
	'MinBv99="'+ coalesce(cast(@MinBetv99 as varchar(50)),space(1))+ '" ' +
	'MaxBv99="'+ coalesce(cast(@MaxBetv99 as varchar(50)),space(1))+ '" ' +
	'MPMv99="'+ coalesce(cast(@MaxPerMatchv99 as varchar(50)),space(1))+ '" ' +
	'MinBv99MP="'+ coalesce(cast(@MinBetv99MP as varchar(50)),space(1))+ '" ' +
	'MaxBv99MP="'+ coalesce(cast(@MaxBetv99MP as varchar(50)),space(1))+ '" ' +
	'MPMv99MP="'+ coalesce(cast(@MaxPerMatchv99MP as varchar(50)),space(1))+ '" ' +

	'MinBv1MP="'+ coalesce(cast(@MinBetv1MP as varchar(50)),space(1))+ '" ' +
	'MaxBv1MP="'+ coalesce(cast(@MaxBetv1MP as varchar(50)),space(1))+ '" ' +
	'MPMv1MP="'+ coalesce(cast(@MaxPerMatchv1MP as varchar(50)),space(1))+ '" ' +

	'MinBv154="'+ coalesce(cast(@MinBetv154 as varchar(50)),space(1))+ '" ' +
	'MaxBv154="'+ coalesce(cast(@MaxBetv154 as varchar(50)),space(1))+ '" ' +
	'MPMv154="'+ coalesce(cast(@MaxPerMatchv154 as varchar(50)),space(1))+ '" ' +
	'MinBv161="'+ coalesce(cast(@MinBetv161 as varchar(50)),space(1))+ '" ' +
	'MaxBv161="'+ coalesce(cast(@MaxBetv161 as varchar(50)),space(1))+ '" ' +
	'MPMv161="'+ coalesce(cast(@MaxPerMatchv161 as varchar(50)),space(1))+ '" ' +
	'MPBv161="' + coalesce(cast(@MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'

	Select @TrackingValue2 ='<Acc_CustomerUpdSuper_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'MinB="'+ coalesce(cast(@Old_MinBet as varchar(50)),space(1))+ '" ' +
	'MaxB="'+ coalesce(cast(@Old_MaxBet as varchar(50)),space(1))+ '" ' +
	'MPM="'+ coalesce(cast(@Old_MaxPerMatch as varchar(50)),space(1))+ '" ' +
	'MinBv2="'+ coalesce(cast(@Old_MinBetv2 as varchar(50)),space(1))+ '" ' +
	'MaxBv2="'+ coalesce(cast(@Old_MaxBetv2 as varchar(50)),space(1))+ '" ' +
	'MPMv2="'+ coalesce(cast(@Old_MaxPerMatchv2 as varchar(50)),space(1))+ '" ' +
	'MinBv3="'+ coalesce(cast(@Old_MinBetv3 as varchar(50)),space(1))+ '" ' +
	'MaxBv3="'+ coalesce(cast(@Old_MaxBetv3 as varchar(50)),space(1))+ '" ' +
	'MPMv3="'+ coalesce(cast(@Old_MaxPerMatchv3 as varchar(50)),space(1))+ '" ' +
	'MinBv5="'+ coalesce(cast(@Old_MinBetv5 as varchar(50)),space(1))+ '" ' +
	'MaxBv5="'+ coalesce(cast(@Old_MaxBetv5 as varchar(50)),space(1))+ '" ' +
	'MPMv5="'+ coalesce(cast(@Old_MaxPerMatchv5 as varchar(50)),space(1))+ '" ' +
	'MinBv8="'+ coalesce(cast(@Old_MinBetv8 as varchar(50)),space(1))+ '" ' +
	'MaxBv8="'+ coalesce(cast(@Old_MaxBetv8 as varchar(50)),space(1))+ '" ' +
	'MPMv8="'+ coalesce(cast(@Old_MaxPerMatchv8 as varchar(50)),space(1))+ '" ' +
	'MinBv10="'+ coalesce(cast(@Old_MinBetv10 as varchar(50)),space(1))+ '" ' +
	'MaxBv10="'+ coalesce(cast(@Old_MaxBetv10 as varchar(50)),space(1))+ '" ' +
	'MPMv10="'+ coalesce(cast(@Old_MaxPerMatchv10 as varchar(50)),space(1))+ '" ' +
	'MinBv11="'+ coalesce(cast(@Old_MinBetv11 as varchar(50)),space(1))+ '" ' +
	'MaxBv11="'+ coalesce(cast(@Old_MaxBetv11 as varchar(50)),space(1))+ '" ' +
	'MPMv11="'+ coalesce(cast(@Old_MaxPerMatchv11 as varchar(50)),space(1))+ '" ' +
	'MinBv99="'+ coalesce(cast(@Old_MinBetv99 as varchar(50)),space(1))+ '" ' +
	'MaxBv99="'+ coalesce(cast(@Old_MaxBetv99 as varchar(50)),space(1))+ '" ' +
	'MPMv99="'+ coalesce(cast(@Old_MaxPerMatchv99 as varchar(50)),space(1))+ '" ' +
	'MinBv99MP="'+ coalesce(cast(@Old_MinBetv99MP as varchar(50)),space(1))+ '" ' +
	'MaxBv99MP="'+ coalesce(cast(@Old_MaxBetv99MP as varchar(50)),space(1))+ '" ' +
	'MPMv99MP="'+ coalesce(cast(@Old_MaxPerMatchv99MP as varchar(50)),space(1))+ '" ' +

	'MinBv1MP="'+ coalesce(cast(@Old_MinBetv1MP as varchar(50)),space(1))+ '" ' +
	'MaxBv1MP="'+ coalesce(cast(@Old_MaxBetv1MP as varchar(50)),space(1))+ '" ' +
	'MPMv1MP="'+ coalesce(cast(@Old_MaxPerMatchv1MP as varchar(50)),space(1))+ '" ' +

	'MinBv154="'+ coalesce(cast(@Old_MinBetv154 as varchar(50)),space(1))+ '" ' +
	'MaxBv154="'+ coalesce(cast(@Old_MaxBetv154 as varchar(50)),space(1))+ '" ' +
	'MPMv154="'+ coalesce(cast(@Old_MaxPerMatchv154 as varchar(50)),space(1))+ '" ' +
	'MinBv161="'+ coalesce(cast(@Old_MinBetv161 as varchar(50)),space(1))+ '" ' +
	'MaxBv161="'+ coalesce(cast(@Old_MaxBetv161 as varchar(50)),space(1))+ '" ' +
	'MPMv161="'+ coalesce(cast(@Old_MaxPerMatchv161 as varchar(50)),space(1))+ '" ' +
	'MPBv161="' + coalesce(cast(@Old_MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)


	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 304,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData ='<Acc_CustomerUpdSuper_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
		'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1))+ '" ' +
		'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1))+ '" ' +
		'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1))+ '" ' +
		'MinBv2="'+ coalesce(cast(@MinBetv2 as varchar(50)),space(1))+ '" ' +
		'MaxBv2="'+ coalesce(cast(@MaxBetv2 as varchar(50)),space(1))+ '" ' +
		'MPMv2="'+ coalesce(cast(@MaxPerMatchv2 as varchar(50)),space(1))+ '" ' +
		'MinBv3="'+ coalesce(cast(@MinBetv3 as varchar(50)),space(1))+ '" ' +
		'MaxBv3="'+ coalesce(cast(@MaxBetv3 as varchar(50)),space(1))+ '" ' +
		'MPMv3="'+ coalesce(cast(@MaxPerMatchv3 as varchar(50)),space(1))+ '" ' +
		'MinBv5="'+ coalesce(cast(@MinBetv5 as varchar(50)),space(1))+ '" ' +
		'MaxBv5="'+ coalesce(cast(@MaxBetv5 as varchar(50)),space(1))+ '" ' +
		'MPMv5="'+ coalesce(cast(@MaxPerMatchv5 as varchar(50)),space(1))+ '" ' +
		'MinBv8="'+ coalesce(cast(@MinBetv8 as varchar(50)),space(1))+ '" ' +
		'MaxBv8="'+ coalesce(cast(@MaxBetv8 as varchar(50)),space(1))+ '" ' +
		'MPMv8="'+ coalesce(cast(@MaxPerMatchv8 as varchar(50)),space(1))+ '" ' +
		'MinBv10="'+ coalesce(cast(@MinBetv10 as varchar(50)),space(1))+ '" ' +
		'MaxBv10="'+ coalesce(cast(@MaxBetv10 as varchar(50)),space(1))+ '" ' +
		'MPMv10="'+ coalesce(cast(@MaxPerMatchv10 as varchar(50)),space(1))+ '" ' +
		'MinBv11="'+ coalesce(cast(@MinBetv11 as varchar(50)),space(1))+ '" ' +
		'MaxBv11="'+ coalesce(cast(@MaxBetv11 as varchar(50)),space(1))+ '" ' +
		'MPMv11="'+ coalesce(cast(@MaxPerMatchv11 as varchar(50)),space(1))+ '" ' +
		'MinBv99="'+ coalesce(cast(@MinBetv99 as varchar(50)),space(1))+ '" ' +
		'MaxBv99="'+ coalesce(cast(@MaxBetv99 as varchar(50)),space(1))+ '" ' +
		'MPMv99="'+ coalesce(cast(@MaxPerMatchv99 as varchar(50)),space(1))+ '" ' +
		'MinBv99MP="'+ coalesce(cast(@MinBetv99MP as varchar(50)),space(1))+ '" ' +
		'MaxBv99MP="'+ coalesce(cast(@MaxBetv99MP as varchar(50)),space(1))+ '" ' +
		'MPMv99MP="'+ coalesce(cast(@MaxPerMatchv99MP as varchar(50)),space(1))+ '" ' +
		
		'MinBv1MP="'+ coalesce(cast(@MinBetv1MP as varchar(50)),space(1))+ '" ' +
		'MaxBv1MP="'+ coalesce(cast(@MaxBetv1MP as varchar(50)),space(1))+ '" ' +
		'MPMv1MP="'+ coalesce(cast(@MaxPerMatchv1MP as varchar(50)),space(1))+ '" ' +
		
		'MinBv154="'+ coalesce(cast(@MinBetv154 as varchar(50)),space(1))+ '" ' +
		'MaxBv154="'+ coalesce(cast(@MaxBetv154 as varchar(50)),space(1))+ '" ' +
		'MPMv154="'+ coalesce(cast(@MaxPerMatchv154 as varchar(50)),space(1))+ '" ' +
		'MinBv161="'+ coalesce(cast(@MinBetv161 as varchar(50)),space(1))+ '" ' +
		'MaxBv161="'+ coalesce(cast(@MaxBetv161 as varchar(50)),space(1))+ '" ' +
		'MPMv161="'+ coalesce(cast(@MaxPerMatchv161 as varchar(50)),space(1))+ '" ' +
		'MPBv161="' + coalesce(cast(@MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'

		Select @TrackingValue2 ='<Acc_CustomerUpdSuper_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
		'MinB="'+ coalesce(cast(@Old_MinBet as varchar(50)),space(1))+ '" ' +
		'MaxB="'+ coalesce(cast(@Old_MaxBet as varchar(50)),space(1))+ '" ' +
		'MPM="'+ coalesce(cast(@Old_MaxPerMatch as varchar(50)),space(1))+ '" ' +
		'MinBv2="'+ coalesce(cast(@Old_MinBetv2 as varchar(50)),space(1))+ '" ' +
		'MaxBv2="'+ coalesce(cast(@Old_MaxBetv2 as varchar(50)),space(1))+ '" ' +
		'MPMv2="'+ coalesce(cast(@Old_MaxPerMatchv2 as varchar(50)),space(1))+ '" ' +
		'MinBv3="'+ coalesce(cast(@Old_MinBetv3 as varchar(50)),space(1))+ '" ' +
		'MaxBv3="'+ coalesce(cast(@Old_MaxBetv3 as varchar(50)),space(1))+ '" ' +
		'MPMv3="'+ coalesce(cast(@Old_MaxPerMatchv3 as varchar(50)),space(1))+ '" ' +
		'MinBv5="'+ coalesce(cast(@Old_MinBetv5 as varchar(50)),space(1))+ '" ' +
		'MaxBv5="'+ coalesce(cast(@Old_MaxBetv5 as varchar(50)),space(1))+ '" ' +
		'MPMv5="'+ coalesce(cast(@Old_MaxPerMatchv5 as varchar(50)),space(1))+ '" ' +
		'MinBv8="'+ coalesce(cast(@Old_MinBetv8 as varchar(50)),space(1))+ '" ' +
		'MaxBv8="'+ coalesce(cast(@Old_MaxBetv8 as varchar(50)),space(1))+ '" ' +
		'MPMv8="'+ coalesce(cast(@Old_MaxPerMatchv8 as varchar(50)),space(1))+ '" ' +
		'MinBv10="'+ coalesce(cast(@Old_MinBetv10 as varchar(50)),space(1))+ '" ' +
		'MaxBv10="'+ coalesce(cast(@Old_MaxBetv10 as varchar(50)),space(1))+ '" ' +
		'MPMv10="'+ coalesce(cast(@Old_MaxPerMatchv10 as varchar(50)),space(1))+ '" ' +
		'MinBv11="'+ coalesce(cast(@Old_MinBetv11 as varchar(50)),space(1))+ '" ' +
		'MaxBv11="'+ coalesce(cast(@Old_MaxBetv11 as varchar(50)),space(1))+ '" ' +
		'MPMv11="'+ coalesce(cast(@Old_MaxPerMatchv11 as varchar(50)),space(1))+ '" ' +
		'MinBv99="'+ coalesce(cast(@Old_MinBetv99 as varchar(50)),space(1))+ '" ' +
		'MaxBv99="'+ coalesce(cast(@Old_MaxBetv99 as varchar(50)),space(1))+ '" ' +
		'MPMv99="'+ coalesce(cast(@Old_MaxPerMatchv99 as varchar(50)),space(1))+ '" ' +
		'MinBv99MP="'+ coalesce(cast(@Old_MinBetv99MP as varchar(50)),space(1))+ '" ' +
		'MaxBv99MP="'+ coalesce(cast(@Old_MaxBetv99MP as varchar(50)),space(1))+ '" ' +
		'MPMv99MP="'+ coalesce(cast(@Old_MaxPerMatchv99MP as varchar(50)),space(1))+ '" ' +
		
		'MinBv1MP="'+ coalesce(cast(@Old_MinBetv1MP as varchar(50)),space(1))+ '" ' +
		'MaxBv1MP="'+ coalesce(cast(@Old_MaxBetv1MP as varchar(50)),space(1))+ '" ' +
		'MPMv1MP="'+ coalesce(cast(@Old_MaxPerMatchv1MP as varchar(50)),space(1))+ '" ' +
		
		'MinBv154="'+ coalesce(cast(@Old_MinBetv154 as varchar(50)),space(1))+ '" ' +
		'MaxBv154="'+ coalesce(cast(@Old_MaxBetv154 as varchar(50)),space(1))+ '" ' +
		'MPMv154="'+ coalesce(cast(@Old_MaxPerMatchv154 as varchar(50)),space(1))+ '" ' +
		'MinBv161="'+ coalesce(cast(@Old_MinBetv161 as varchar(50)),space(1))+ '" ' +
		'MaxBv161="'+ coalesce(cast(@Old_MaxBetv161 as varchar(50)),space(1))+ '" ' +
		'MPMv161="'+ coalesce(cast(@Old_MaxPerMatchv161 as varchar(50)),space(1))+ '" ' +
		'MPBv161="' + coalesce(cast(@Old_MaxPerBallv161 as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 304,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
		END CATCH
END