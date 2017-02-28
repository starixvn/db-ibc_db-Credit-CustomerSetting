ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentGoldDeluxe_PositionTaking]
(
	@custid								INT,
	
	@v255mpositiontaking_1701			SMALLMONEY,
	@auto_v255mpositiontaking_1701		SMALLMONEY,
	@isauto_v255mpositiontaking_1701	BIT = 0,
	@v255apositiontaking_1701			SMALLMONEY,
	@min_v255apositiontaking_1701		SMALLMONEY,
	@updateallmembers					BIT = 0,
	@newmpositiontaking					SMALLMONEY = 0,--equals max(m+a) - chosen(a)
	
	@v255UpdatePositiontaking_1701		BIT = 0,
	@v255UpdateAutoPositiontaking_1701	BIT = 0,
	
	@SubAccID							INT = 0, --Sub-AccountID		
	@UserID								INT = 0,	
	@Language							VARCHAR(2) = 'E',
	@IP									VARCHAR(15)='',
	@ErrCode							INT = 0 OUTPUT,
	@ErrMsg								NVARCHAR(4000) = '' OUTPUT
)
AS
/*
	Created: 20150422@Elodie
	Task: master update agent's Gold Deluxe PT setting
	DB: DBTXN/CustDB
	
	Revisions:
		- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
		- 20151007@Elodie: Remove code to check old and new value
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]			            
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
	
	DECLARE @roleid TINYINT	
	
	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend
			, @roleid = roleid
	FROM custinfo WITH(NOLOCK) 
	WHERE CustID = @CustID
	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	DECLARE @old_v255apositiontaking_1701			SMALLMONEY,
			@old_v255mpositiontaking_1701			SMALLMONEY,				
			@old_auto_v255mpositiontaking_1701		SMALLMONEY,	
			@old_isauto_v255mpositiontaking_1701	BIT,
			@max_v255mapositiontaking_1701			SMALLMONEY,
			@maxpos									SMALLMONEY
			
	SELECT	@old_v255mpositiontaking_1701 = mpositiontaking, 
			@old_v255apositiontaking_1701 = apositiontaking ,
			@old_auto_v255mpositiontaking_1701 = autompositiontaking, 
			@old_isauto_v255mpositiontaking_1701 = isautompositiontaking	
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @custid AND bettype = 1701 AND sporttype = 255
	
	
	--check if not change setting
	--IF @old_v255mpositiontaking_1701 = @v255mpositiontaking_1701
	--	AND @old_v255apositiontaking_1701 = @v255apositiontaking_1701
	--	AND @old_auto_v255mpositiontaking_1701 = @auto_v255mpositiontaking_1701
	--	AND @old_isauto_v255mpositiontaking_1701 = @isauto_v255mpositiontaking_1701
	--		RETURN
				
	IF	@v255apositiontaking_1701 < 0	
		OR @v255mpositiontaking_1701 < 0
		OR @v255apositiontaking_1701 + @v255mpositiontaking_1701 > 1
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
				SELECT 1701 AS bettype, 255 AS sporttype, @v255apositiontaking_1701 AS apositiontaking, @v255mpositiontaking_1701 AS mpositiontaking, @isauto_v255mpositiontaking_1701 AS isauto_mpositiontaking, @auto_v255mpositiontaking_1701 AS auto_mpositiontaking
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
			SELECT 1701 AS bettype, 255 AS sporttype, @min_v255apositiontaking_1701 AS minpositiontaking
		) AS co
		INNER JOIN 
		(
			select 1701 AS bettype, 255 AS sporttype, @v255apositiontaking_1701 AS apositiontaking
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
	
	SELECT @max_v255mapositiontaking_1701 = mpositiontaking 
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @mrecommend AND bettype = 1701 AND sporttype = 255
	
	
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType +  'Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'
	FROM
		(				
			select 1701 as bettype, 255 as sporttype, @v255apositiontaking_1701 AS apositiontaking, @v255mpositiontaking_1701 AS mpositiontaking, @max_v255mapositiontaking_1701 AS max_mapositiontaking
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
		select 1701 AS bettype, 255 as sporttype, @auto_v255mpositiontaking_1701 as autopositiontaking, @isauto_v255mpositiontaking_1701 as isautopositiontaking, @max_v255mapositiontaking_1701 as max_mapositiontaking		
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
	IF @v255UpdatePositiontaking_1701 = 1
	BEGIN	
		update CustSettingGame with (ROWLOCK, UPDLOCK)
		set
			apositiontaking = @v255apositiontaking_1701,		
			mpositiontaking = @v255mpositiontaking_1701 
		where custid = @custid AND sporttype = 255 AND bettype = 1701
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
	IF @v255UpdateAutoPositiontaking_1701 = 1
	BEGIN	
		UPDATE CustSettingGame WITH(ROWLOCK, UPDLOCK) 
		set autompositiontaking		= @auto_v255mpositiontaking_1701,
			isautompositiontaking	= @isauto_v255mpositiontaking_1701
		where custid = @custid AND bettype = 1701 AND sporttype = 255
		
		if @@Error <> 0
		BEGIN
			
			SELECT @ErrMsg = case @Language 
					when 'E' then 'Error updating auto position taking'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
				end	
				,  @ErrCode=106
			return
		END
	
	
		if (@auto_v255mpositiontaking_1701 <> @old_auto_v255mpositiontaking_1701 or @isauto_v255mpositiontaking_1701 <> @old_isauto_v255mpositiontaking_1701 )
		BEGIN
			EXEC dbo.Acc_CustSetting3rd_05
				@mrecommend = @mrecommend,
				@recommend = @custid,
				@roleid = 2,
				@mode = 'GoldDeluxe',
				
				@isauto_v255mpositiontaking_1701 = @isauto_v255mpositiontaking_1701,
				@old_isauto_v255mpositiontaking_1701 = @old_isauto_v255mpositiontaking_1701,
				
				@auto_v255mpositiontaking_1701 = @auto_v255mpositiontaking_1701,
				
				@updateallmembers = @updateallmembers,
				@newmpositiontaking = @newmpositiontaking			
		END	
	END
	
	IF @v255UpdateAutoPositiontaking_1701 = 1 OR @v255UpdatePositiontaking_1701 =1 
	BEGIN 
		
		EXEC dbo.Acc_CustSetting3rd_07 @recommend = @custid, @roleid = 2, @mode = 'GoldDeluxe', @Sporttype = 255, @BetType = 1701
		
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

Select @LogSPData ='<Acc_CustomerUpdAgentGoldDeluxe_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +

					'updateallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
					'newmpositiontaking="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
					'v255apositiontaking_1701="'+ coalesce(cast(@v255apositiontaking_1701 as varchar(50)),space(1)) + '" ' +
					'v255mpositiontaking_1701="'+ coalesce(cast(@v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
					'auto_v255mpositiontaking_1701="'+ coalesce(cast(@auto_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
					'isauto_v255mpositiontaking_1701="'+ coalesce(cast(@isauto_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
					'v255UpdatePositiontaking_1701="' + coalesce(cast(@v255UpdatePositiontaking_1701 as varchar(10)), space(1)) + '" ' +
					'v255UpdateAutoPositiontaking_1701="' + coalesce(cast(@v255UpdateAutoPositiontaking_1701 as varchar(10)), space(1)) + '" ' +

					'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
					'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
					'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
					'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
					'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
					'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' 


Select @TrackingValueDB =	'<Acc_CustomerUpdAgentGoldDeluxe_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
							'updateallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
							'newmpositiontaking="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
							'v255apositiontaking_1701="'+ coalesce(cast(@old_v255apositiontaking_1701 as varchar(50)),space(1)) + '" ' + 
							'v255mpositiontaking_1701="'+ coalesce(cast(@old_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
							'auto_v255mpositiontaking_1701="'+ coalesce(cast(@old_auto_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
							'isauto_v255mpositiontaking_1701="'+ coalesce(cast(@old_isauto_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' + 
							'v255UpdatePositiontaking_1701="' + coalesce(cast(@v255UpdatePositiontaking_1701 as varchar(10)), space(1)) + '" ' +
							'v255UpdateAutoPositiontaking_1701="' + coalesce(cast(@v255UpdateAutoPositiontaking_1701 as varchar(10)), space(1)) + '" ' +

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
		@ActionID = 459,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData =	'<Acc_CustomerUpdAgentGoldDeluxe_PositionTaking CustID="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +

						'updateallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
						'newmpositiontaking="'+ coalesce(cast(@newmpositiontaking as varchar(50)),space(1)) + '" ' +
						'v255apositiontaking_1701="'+ coalesce(cast(@v255apositiontaking_1701 as varchar(50)),space(1)) + '" ' +
						'v255mpositiontaking_1701="'+ coalesce(cast(@v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
						'auto_v255mpositiontaking_1701="'+ coalesce(cast(@auto_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
						'isauto_v255mpositiontaking_1701="'+ coalesce(cast(@isauto_v255mpositiontaking_1701 as varchar(50)),space(1)) + '" ' +
						'v255UpdatePositiontaking_1701="' + coalesce(cast(@v255UpdatePositiontaking_1701 as varchar(10)), space(1)) + '" ' +
						'v255UpdateAutoPositiontaking_1701="' + coalesce(cast(@v255UpdateAutoPositiontaking_1701 as varchar(10)), space(1)) + '" ' +

						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 459,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH	
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_PositionTaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_PositionTaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_PositionTaking] TO [vnteam] AS [dbo]