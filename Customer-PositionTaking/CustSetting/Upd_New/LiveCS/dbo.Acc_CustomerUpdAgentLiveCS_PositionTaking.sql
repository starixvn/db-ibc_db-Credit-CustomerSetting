ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentLiveCS_PositionTaking]
(
	@custid								INT,
	
	@v162mpositiontaking_1101			SMALLMONEY,
	@auto_v162mpositiontaking_1101		SMALLMONEY,
	@isauto_v162mpositiontaking_1101	BIT = 0,
	@v162apositiontaking_1101			SMALLMONEY,
	@min_v162apositiontaking_1101		SMALLMONEY,
	@updateallmembers					BIT = 0,
	@newmpositiontaking					SMALLMONEY = 0,--equals max(m+a) - chosen(a)
	
	@v162UpdatePositiontaking_1101		BIT = 0,
	@v162UpdateAutoPositiontaking_1101	BIT = 0,
	
	@SubAccID							INT = 0, --Sub-AccountID		
	@UserID								INT = 0,	
	@Language							VARCHAR(2) = 'E',
	@IP									VARCHAR(15)='',
	@ErrCode							INT = 0 OUTPUT,
	@ErrMsg								NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20120116@Lukas
	Task: master update agent's live casino PT setting
	DB: DBTXN/BODB02
	
	Revisions:
		- 20120405@Johnson: not check pt change for agent not synchronized
		- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
		- 20130301@Johnson: write log on DBTXN if DBLOG failure
		- 20130516@Lukas: allow PT = 100%
		- 20131104@Johnson: Apply execrep when recalculate pt on members
				and check total downlines before UPDATEs 
		- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)				
		- 20140925@Johnson: remove bettype name out of error message
		- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)

	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun	DATETIME,
			@endRun		DATETIME,
			@duration	INT
	SET @startRun = GETDATE()

	DECLARE @UserName			NVARCHAR(50), 
			@mrecommend			INT, 
			@srecommend			INT, 
			@SyncLiveCasino		BIT,
			@ErrAcc				VARCHAR(4000), 
			@ErrType			VARCHAR(4000)			
	
	---- Johnson@20131104: Checking total downlines before UPDATEs 
	EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
		@roleid=2,
		@isExecRep=1,
		@isUpdatePT = 1,
		@Sporttype = 1,
		@Language='E',
		@ErrMsg=@ErrMsg output,
		@ErrCode=@ErrCode output
	IF	@ErrCode <> 0 
		RETURN 
		
	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend, @SyncLiveCasino = SyncLiveCasino 
	FROM custinfo WITH(NOLOCK) 
	WHERE CustID = @CustID
	
	DECLARE @old_v162apositiontaking_1101 SMALLMONEY,
			@old_v162mpositiontaking_1101 SMALLMONEY,				
			@old_auto_v162mpositiontaking_1101 SMALLMONEY,	
			@old_isauto_v162mpositiontaking_1101 BIT,
			@max_v162mapositiontaking_1101 SMALLMONEY,
			@maxpos							SMALLMONEY
			
	SELECT @old_v162mpositiontaking_1101 = mpositiontaking, @old_v162apositiontaking_1101 = apositiontaking ,
		@old_auto_v162mpositiontaking_1101 = autompositiontaking, @old_isauto_v162mpositiontaking_1101 = isautompositiontaking	
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @custid AND bettype = 1101 AND sporttype = 162
	
	
	--check if not change setting
	IF @old_v162mpositiontaking_1101 = @v162mpositiontaking_1101
		AND @old_v162apositiontaking_1101 = @v162apositiontaking_1101
		AND @old_auto_v162mpositiontaking_1101 = @auto_v162mpositiontaking_1101
		AND @old_isauto_v162mpositiontaking_1101 = @isauto_v162mpositiontaking_1101
		AND @SyncLiveCasino = 1
			RETURN
				
	IF	@v162apositiontaking_1101 < 0	
		OR @v162mpositiontaking_1101 < 0
		OR @v162apositiontaking_1101 + @v162mpositiontaking_1101 > 1
	BEGIN
		SELECT @ErrCode = 100
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					END
		RETURN
	END
	
	--check n3<=m2+a2  if im2 = 0, 
	--a2<=l3 and um2+a2>=n3 if im2 = 1
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + 'Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10))+ '<br>'
	FROM custoverrideGame co WITH(NOLOCK)
		INNER JOIN 
			(
				SELECT 1101 AS bettype, 162 AS sporttype, @v162apositiontaking_1101 AS apositiontaking, @v162mpositiontaking_1101 AS mpositiontaking, @isauto_v162mpositiontaking_1101 AS isauto_mpositiontaking, @auto_v162mpositiontaking_1101 AS auto_mpositiontaking
			) b ON co.sporttype = b.sporttype AND co.bettype = b.bettype				
	WHERE co.custid = @mrecommend AND (	
						((b.isauto_mpositiontaking = 0) AND (b.mpositiontaking + b.apositiontaking < co.minpositiontaking)) or 
						(b.isauto_mpositiontaking > 0 AND (b.apositiontaking + b.auto_mpositiontaking < co.minpositiontaking))
					)
	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode = 101
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END
		RETURN
	END

	--n2<=a2
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + 'Min: '+ CAST((co.minpositiontaking) AS VARCHAR(10)) + '<br>'
	FROM 
		( 
			SELECT 1101 AS bettype, 162 AS sporttype, @min_v162apositiontaking_1101 AS minpositiontaking
		) AS co
		INNER JOIN 
		(
			select 1101 AS bettype, 162 AS sporttype, @v162apositiontaking_1101 AS apositiontaking
		) AS b ON co.sporttype = b.sporttype AND co.bettype = b.bettype				
	WHERE b.apositiontaking < co.minpositiontaking

	IF @ErrType <>''
	BEGIN
		SELECT @ErrCode = 102
		SELECT @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		RETURN
	END
	
	SELECT @max_v162mapositiontaking_1101 = mpositiontaking 
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @mrecommend AND bettype = 1101 AND sporttype = 162
	
	
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType +  'Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'
	FROM
		(				
			select 1101 as bettype, 162 as sporttype, @v162apositiontaking_1101 AS apositiontaking, @v162mpositiontaking_1101 AS mpositiontaking, @max_v162mapositiontaking_1101 AS max_mapositiontaking
		) b				
	WHERE (b.apositiontaking + b.mpositiontaking > b.max_mapositiontaking) 

	IF @ErrType <>''
	BEGIN
		select @ErrCode = 103
		Select @ErrMsg = case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
	
	--check um2<=min(m3,l3) - Phuc@20081209
	select @ErrType = ''
	select @ErrType = @ErrType + 'Max: '+ cast(max_mapositiontaking as varchar(10)) + '<br>'
	from 
	(
		select 1101 AS bettype, 162 as sporttype, @auto_v162mpositiontaking_1101 as autopositiontaking, @isauto_v162mpositiontaking_1101 as isautopositiontaking, @max_v162mapositiontaking_1101 as max_mapositiontaking		
	) as b 				
	where b.isautopositiontaking = 1 
		AND b.autopositiontaking > max_mapositiontaking
		

	if @ErrType <>''
	BEGIN
		select @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
	
	
	---- update
	IF @v162UpdatePositiontaking_1101 = 1
	BEGIN	
		update CustSettingGame with (ROWLOCK, UPDLOCK)
		set
			apositiontaking = @v162apositiontaking_1101,		
			mpositiontaking = @v162mpositiontaking_1101 
		where custid = @custid AND sporttype = 162 AND bettype = 1101
		if (@@error <> 0)
		begin
			
			Select @ErrMsg = case @Language 
								when 'E' then 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							end, @ErrCode = 105
			return
		end
	END
		
	--Update Master Agent account
	IF @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN	
		UPDATE CustSettingGame WITH(ROWLOCK, UPDLOCK) 
		set autompositiontaking		= @auto_v162mpositiontaking_1101,
			isautompositiontaking	= @isauto_v162mpositiontaking_1101
		where custid = @custid AND bettype = 1101 AND sporttype = 162
		
		if @@Error <> 0
		BEGIN
			
			SELECT @ErrMsg = case @Language 
					when 'E' then 'Error updating auto position taking'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
				end	
				,  @ErrCode=106
			return
		END
	
	
		if (@auto_v162mpositiontaking_1101 <> @old_auto_v162mpositiontaking_1101 or @isauto_v162mpositiontaking_1101 <> @old_isauto_v162mpositiontaking_1101 )
		BEGIN
			EXEC dbo.Acc_CustSetting3rd_05
				@mrecommend = @mrecommend,
				@recommend = @custid,
				@roleid = 2,
				@mode = 'LiveCasino',
				
				@isauto_v162mpositiontaking_1101 = @isauto_v162mpositiontaking_1101,
				@old_isauto_v162mpositiontaking_1101 = @old_isauto_v162mpositiontaking_1101,
				
				@auto_v162mpositiontaking_1101 = @auto_v162mpositiontaking_1101,
				
				@updateallmembers = @updateallmembers,
				@newmpositiontaking = @newmpositiontaking
			/*
			if @isauto_v162mpositiontaking_1101 >0 --Use AUTO MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from CustSettingGame with (NOLOCK) where custid = @mrecommend and sporttype=162 and bettype = 1101
				update cs 
					set mpositiontaking = case when @maxpos - apositiontaking > @auto_v162mpositiontaking_1101 then @auto_v162mpositiontaking_1101 else @maxpos -apositiontaking end
				from CustSettingGame as cs with (ROWLOCK, UPDLOCK) 
					inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
				where c.recommend = @custid and c.roleid = 1 and c.SyncLiveCasino = 1
					and cs.bettype = 1101 and cs.sporttype=162
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Error updating auto position taking'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
							end	
							,  @ErrCode=107
					return
				END
			END
			else if @isauto_v162mpositiontaking_1101 <> @old_isauto_v162mpositiontaking_1101 --Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 --all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update cs 
						set mpositiontaking = case when acs.mpositiontaking < @newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from CustSettingGame as cs with (ROWLOCK, UPDLOCK) 
					inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
					inner join CustSettingGame as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype
					where c.recommend = @custid and c.roleid = 1 and c.SyncLiveCasino = 1
						and cs.bettype = 1101 and cs.sporttype = 162
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  @UserName + ': '+
							case @Language 
								when 'E' then 'Error updating auto position taking'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
							end	
							,  @ErrCode=108
						return
					END
				END
			END*/
		END	
	END
	
	IF @v162UpdateAutoPositiontaking_1101 = 1 OR @v162UpdatePositiontaking_1101 =1 
	BEGIN 
		
		EXEC dbo.Acc_CustSetting3rd_07 @recommend = @custid, @roleid = 2, @mode = 'LiveCasino'
	/*
		EXEC dbo.Acc_CustomerUpdAgentLiveCS_MaxPositiontaking @recommend = @custid
	*/	
		IF (@@error <> 0)
		BEGIN
			
			SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 109					 
			
			RETURN
		END
	END
Declare @LogSPData varchar(MAX),
		@TrackingValueDB VARCHAR(4000)

Select @LogSPData ='<Acc_CustomerUpdAgentLiveCS_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +

'updateallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newmpositiontaking="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
'v162apositiontaking_1101="'+ coalesce(cast(@v162apositiontaking_1101 as varchar(50)),space(1)) + '" ' +
'v162mpositiontaking_1101="'+ coalesce(cast(@v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
'auto_v162mpositiontaking_1101="'+ coalesce(cast(@auto_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
'v162UpdatePositiontaking_1101="' + coalesce(cast(@v162UpdatePositiontaking_1101 as varchar(10)), space(1)) + '" ' +
'v162UpdateAutoPositiontaking_1101="' + coalesce(cast(@v162UpdateAutoPositiontaking_1101 as varchar(10)), space(1)) + '" ' +

'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' 


Select @TrackingValueDB ='<Acc_CustomerUpdAgentLiveCS_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +

'updateallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newmpositiontaking="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
'v162apositiontaking_1101="'+ coalesce(cast(@old_v162apositiontaking_1101 as varchar(50)),space(1)) + '" ' + 
'v162mpositiontaking_1101="'+ coalesce(cast(@old_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
'auto_v162mpositiontaking_1101="'+ coalesce(cast(@old_auto_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@old_isauto_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' + 
'v162UpdatePositiontaking_1101="' + coalesce(cast(@v162UpdatePositiontaking_1101 as varchar(10)), space(1)) + '" ' +
'v162UpdateAutoPositiontaking_1101="' + coalesce(cast(@v162UpdateAutoPositiontaking_1101 as varchar(10)), space(1)) + '" ' +

'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' 


set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 426,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData ='<Acc_CustomerUpdAgentLiveCS_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +

	'updateallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
	'newmpositiontaking="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
	'v162apositiontaking_1101="'+ coalesce(cast(@v162apositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'v162mpositiontaking_1101="'+ coalesce(cast(@v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'auto_v162mpositiontaking_1101="'+ coalesce(cast(@auto_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'v162UpdatePositiontaking_1101="' + coalesce(cast(@v162UpdatePositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	'v162UpdateAutoPositiontaking_1101="' + coalesce(cast(@v162UpdateAutoPositiontaking_1101 as varchar(10)), space(1)) + '" ' +

	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 426,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH	
END



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_PositionTaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_PositionTaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentLiveCS_PositionTaking] TO [vnteam] AS [dbo]