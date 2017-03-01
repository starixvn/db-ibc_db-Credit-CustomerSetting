ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentVS_MinMaxBet]
	@custid int,-- agentID
	@sporttype tinyint,
	@bettype int,	
	@minbet money,
	@maxbet money,
	@maxpermatch money,	
	@SubAccID int = 0, --Sub-AccountID		
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode	VARCHAR(300)  = ''  OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
as
/*
Created: 20120816@Dan
Task : Update agent's minbet, maxbet, max per match for VS
DB: DBTXN/custDB
Original: 

Revisions:
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121130@Scott: Add Virtual Tennis (sporttype = 186)
	- 20130221@Johnson: - add virtual horse racing setting (sporttype : 181)
						- change linked server DB053 to DBAGE, DB03 to DBONUSER
						- write log on DBTXN if DBLOG failure
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)		
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]				
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

Declare 
	@MinMinBet money, @MaxMaxBet money,	@MaxMaxPerMatch money	
declare @UserName varchar(30), @mrecommend int

DECLARE @roleid TINYINT
		
Select @UserName = username, @mrecommend = mrecommend, @roleid = roleid
from customer with (NOLOCK)
where CustID = @CustID and roleid = 2

-- Only direct upline have update permission
IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
BEGIN
	SELECT @ErrMsg = 'You don''t have permission to perform this action.',
		   @ErrCode = 103	
	RETURN
END

if (@UserName = NULL) return

if 
	@MinBet<0
	or @MaxBet < 0
	or @MaxPerMatch <0
BEGIN
	select @ErrCode_Cur = 101
	Select @ErrMsg_Cur = 	case @Language 
						when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
				end
				
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END

Select @MinMinBet = 0, @MaxMaxBet = 0

Select 
	@MinMinBet = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxMaxBet = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	CustSetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = @bettype and cs.sporttype=@sporttype
where ci.custid = @MRecommend


Select	
	@MaxMaxperMatch = case	when @sporttype = 180 then isnull(Min(case when cs.MaxPerMatch180 = 0 then NULL else cs.MaxPerMatch180 end),0)
							when @sporttype = 181 then isnull(Min(case when cs.MaxPerMatch181 = 0 then NULL else cs.MaxPerMatch181 end),0)
							when @sporttype = 182 then isnull(Min(case when cs.MaxPerMatch182 = 0 then NULL else cs.MaxPerMatch182 end),0)
							when @sporttype = 183 then isnull(Min(case when cs.MaxPerMatch183 = 0 then NULL else cs.MaxPerMatch183 end),0)
							when @sporttype = 184 then isnull(Min(case when cs.MaxPerMatch184 = 0 then NULL else cs.MaxPerMatch184 end),0)
							when @sporttype = 185 then isnull(Min(case when cs.MaxPerMatch185 = 0 then NULL else cs.MaxPerMatch185 end),0)
							when @sporttype = 186 then isnull(Min(case when cs.MaxPerMatch186 = 0 then NULL else cs.MaxPerMatch186 end),0) end
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID



if (@MinBet<>0 and @MaxBet <> 0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxPerMatch <> 0 and @MaxBet>@MaxPerMatch) 
BEGIN
	SELECT @ErrMsg_Cur =	@UserName + ': '+
					case @Language 
						when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
					end						
					+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch)
			, @ErrCode_Cur = 102					 
	
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END

if (@MinMinBet>0 and @MinBet>0 and @MinBet<@MinMinBet)
BEGIN
	SELECT @ErrMsg_Cur =	@UserName + ': '+
					case @Language 
						when 'E' then 'Min bet must be equal to or greater than Master Agent min bet'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10019,@Language)
					end						
					+' (' + convert(varchar(20), @MinMinBet) + ').'
		, @ErrCode_Cur = 103
	
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END
	
if (@MaxMaxBet>0 and @MaxBet>0 and @MaxBet>@MaxMaxBet)
BEGIN
	SELECT @ErrMsg_Cur =	@UserName + ': '+
					case @Language 
						when 'E' then 'Max bet must be equal to or less than Master Agent max bet'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10020,@Language)
					end						
					+' (' + convert(varchar(20), @MaxMaxBet) + ').'
			, @ErrCode_Cur = 104
	
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END
	
if (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)
BEGIN
	SELECT @ErrMsg_Cur =	@UserName + ': '+
					case @Language 
						when 'E' then 'Max Per Match must be equal to or less than Master Agent Max Per Match'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](10021,@Language)
					end						
					+' (' + convert(varchar(20), @MaxMaxPerMatch) + ').', @ErrCode_Cur = 111					 
	
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
END

---------------------------------------------------------------
--check old values and new values before update
DECLARE @old_minbet money, @old_maxbet money
SELECT @old_minbet = minbet , @old_maxbet = maxbet
FROM custsetting3rd WITH(NOLOCK) 
WHERE custid = @custid AND sporttype = @sporttype and bettype = @bettype

IF @old_minbet <> @minbet OR @old_maxbet <> @maxbet
BEGIN
	update CustSetting3rd with (ROWLOCK, UPDLOCK)
	set
		MinBet= @MinBet,
		MaxBet= @MaxBet 
	where custid=@custid and sporttype = @sporttype and bettype = @bettype

	if (@@error <> 0)
	begin
		
		Select @ErrMsg_Cur = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode_Cur = 105	
		IF @ErrCode_Cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	end
	ELSE	
		SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
END

--check old value and new value before update
DECLARE @old_maxpermatch money
SELECT @old_maxpermatch = case	when @sporttype = 180 then maxpermatch180
								when @sporttype = 181 then maxpermatch181
								when @sporttype = 182 then maxpermatch182
								when @sporttype = 183 then maxpermatch183
								when @sporttype = 184 then maxpermatch184
								when @sporttype = 185 then maxpermatch185
								when @sporttype = 186 then maxpermatch186 end
FROM custinfo WITH(NOLOCK)
WHERE custid = @custid
	
IF @old_maxpermatch <> @maxpermatch
BEGIN
	
	IF (@sporttype = 180)
	BEGIN
	
				EXEC dbo.Acc_CustomerUpdMaxPerMatchVS180_1201 
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END
	
	IF (@sporttype = 181)
	BEGIN
	
				EXEC dbo.Acc_CustomerUpdMaxPerMatchVS181_1231 
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END
	
	IF (@sporttype = 182)
	BEGIN
	
				EXEC dbo.Acc_CustomerUpdMaxPerMatchVS182_1231 
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END

	IF (@sporttype = 183)
	BEGIN
	
																EXEC dbo.Acc_CustomerUpdMaxPerMatchVS183_1231 
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END

	
	IF (@sporttype = 184)
	BEGIN
	
				EXEC dbo.Acc_CustomerUpdMaxPerMatchVS184_1231 
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END

	IF (@sporttype = 185)
	BEGIN
	
																EXEC dbo.Acc_CustomerUpdMaxPerMatchVS185_1231 
			@custid = @custid,
			@MaxPerMatch = @MaxPerMatch,
			@Language = @Language,
			@ErrCode = @ErrCode_Cur OUTPUT,
			@ErrMsg = @ErrMsg_Cur OUTPUT
	END
	
	IF (@sporttype = 186)
	BEGIN
				EXEC dbo.Acc_CustomerUpdMaxPerMatchVS186_1220
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

-- Compare old value & new value Betting Limit: Popup Message For Betting Limit 
IF @MinBet != @old_minbet OR @MaxBet != @old_maxbet OR @MaxPerMatch != @old_maxpermatch
BEGIN
	EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID, @TypeID = 2
END

Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(4000)
		
Select @LogSPData ='<Acc_CustomerUpdAgentVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

Select @TrackingValueDB ='<Acc_CustomerUpdAgentVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@old_minbet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@old_maxbet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@old_maxpermatch as varchar(50)),space(1)) + '" ' +
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
		@ActionID = 371,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData ='<Acc_CustomerUpdAgentVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
	'MinB="'+ coalesce(cast(@minbet as varchar(50)),space(1)) + '" ' +
	'MaxB="'+ coalesce(cast(@maxbet as varchar(50)),space(1)) + '" ' +
	'MPM="'+ coalesce(cast(@maxpermatch as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 371,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH
---------------------------------------------------------



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_MinMaxBet] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentVS_MinMaxBet] TO [vnteam] AS [dbo]