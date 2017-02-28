USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperVS_MinMaxBet]    Script Date: 06/10/2015 16:08:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperVS_MinMaxBet    Script Date: 4/22/2014 1:45:55 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperVS_MinMaxBet    Script Date: 10/04/2014 5:25:04 PM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperVS_MinMaxBet    Script Date: 12/5/2013 5:35:50 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperVS_MinMaxBet]
	@custid			INT,
	@sporttype tinyint,
	@bettype int,
	@MinBet			MONEY,
	@MaxBet			MONEY,
	@MaxPerMatch	MONEY,
	@UserID			INT = 0,	
	@Language		VARCHAR(2) = 'E',
	@IP				VARCHAR(15)='',
	@ErrCode		VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg			NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20120801@Dan.Nguyen
Task : Update super's minbet, maxbet, max per match for Virtual Soccer
DB: DBCUST/custDB

Revisions:
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Scott : add virtual tennis ( sporttype = 186 )
	- 20130220@Johnson: - add virtual horse racing (sporttype : 181)
						- change linked server DB053 to DBAGE
						- write log on DBTXN if DBLOG failure
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)	
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB) [Redmine:#36216]                                
	- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
							
Param's Explanation:
* @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
* @ErrMsg: Error description.
*/
 
SET NOCOUNT ON
DECLARE @startRun datetime, 
		@endRun datetime, 
		@duration int,
		@minbet_old money,
		@maxbet_old money,
		@maxpermatch_old money

set @startRun = getdate()

DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

-- Only direct upline have update permission
IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,4,@userid))
BEGIN
	SELECT @ErrMsg = 'You don''t have permission to perform this action.',
		   @ErrCode = 103	
	RETURN
END


if 
	@MinBet<0
	or @MaxBet < 0
	or @MaxPerMatch <0	
BEGIN
	 
	Select @ErrMsg_Cur = case @Language 
						when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)					
					end, @ErrCode_Cur = 101
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END

if(@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) 
	or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
	or (@MinBet <> 0 and @MaxPerMatch <> 0 and @MinBet>@MaxPerMatch) 
BEGIN
	SELECT
		@ErrMsg_Cur =	case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
					end, @ErrCode_Cur = 102
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END

SELECT @minbet_old = MinBet, @maxbet_old = MaxBet
FROM custsetting3rd WITH(NOLOCK)
WHERE custid = @custid and sporttype = @sporttype AND bettype = @bettype

SELECT @maxpermatch_old = CASE	WHEN @sporttype = 180 THEN maxpermatch180 
								WHEN @sporttype = 181 THEN maxpermatch181
								WHEN @sporttype = 182 THEN maxpermatch182
								WHEN @sporttype = 183 THEN maxpermatch183
								WHEN @sporttype = 184 THEN maxpermatch184
								WHEN @sporttype = 185 THEN maxpermatch185
								WHEN @sporttype = 186 THEN maxpermatch186 END --20121130@Scott
FROM custinfo WITH(NOLOCK) 
WHERE custid = @custid


IF @MinBet <> @minbet_old OR @MaxBet <> @maxbet_old
BEGIN
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set	MinBet = @MinBet, 
		MaxBet= @MaxBet
	where custid=@custid and sporttype = @sporttype AND bettype = @bettype
	
	if (@@error <> 0)
	begin
		
		Select @ErrMsg_Cur = case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode_Cur = 103 
		return
	end
	
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE	
		SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
END

IF @MaxPerMatch <> @maxpermatch_old
BEGIN
	IF (@sporttype = 180)
	BEGIN
				EXEC Acc_CustomerUpdMaxPerMatchVS180_1201
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END
	
	IF (@sporttype = 181)
	BEGIN
				EXEC Acc_CustomerUpdMaxPerMatchVS181_1231
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END
	
	IF (@sporttype = 182)
	BEGIN
				EXEC Acc_CustomerUpdMaxPerMatchVS182_1231
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END

	IF (@sporttype = 183)
	BEGIN
																EXEC Acc_CustomerUpdMaxPerMatchVS183_1231
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END

	IF (@sporttype = 184)
	BEGIN
				EXEC Acc_CustomerUpdMaxPerMatchVS184_1231
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END

	IF (@sporttype = 185)
	BEGIN
																EXEC Acc_CustomerUpdMaxPerMatchVS185_1231
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END
	
	IF (@sporttype = 186) --20121130@Scott
	BEGIN
				EXEC Acc_CustomerUpdMaxPerMatchVS186_1220
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
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
		SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
END


Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
		
Select @LogSPData ='<Acc_CustomerUpdSuperVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'

SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet_old as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet_old as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch_old as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY 
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 370,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData ='<Acc_CustomerUpdSuperVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 370,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperVS_MinMaxBet] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperVS_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperVS_MinMaxBet] TO [vnteam] AS [dbo]