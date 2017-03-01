ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Positiontaking]
	@custid  INT,
	@v255apositiontaking_1701 SMALLMONEY,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT	
AS
	/*
		Created: Elodie
		Date: 20150422
		Task: Update positiontaking Gold Deluxe on member
		DB: DBTXN/CustDB
		
		Revisions:
			- 20151007@Elodie: Remove code to check old and new value
			- 20151016@Helen: Data Type Error - [Redmine - 45677] 
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
			
		Parameters Explanation:
	*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = GETDATE()

	DECLARE 
		@recommend INT,	
		@mrecommend INT,
		@srecommend INT,
		@UserName nvarchar(20),
		@ErrAcc varchar(4000), 
		@ErrType varchar(4000),
	
		@v255spositiontaking_1701_min			SMALLMONEY,--n4
		@v255spositiontaking_1701_max			SMALLMONEY,--s4
	
		@v255spositiontaking_1701				SMALLMONEY,--s1
		@v255mpositiontaking_1701				SMALLMONEY, --m1
		@db_v255apositiontaking_1701			SMALLMONEY,--old a1
		@isauto_v255spositiontaking_1701_mem	BIT,--i1
		@auto_v255spositiontaking_1701_mem		SMALLMONEY,--u1
		@isauto_v255mpositiontaking_1701_mem	BIT, --im1
		@auto_v255mpositiontaking_1701_mem		SMALLMONEY,--um1
	
		@v255mpositiontaking_1701_min			SMALLMONEY,--n3
		@v255mpositiontaking_1701_max			SMALLMONEY, --m3
		@isauto_v255spositiontaking_1701		BIT, -- i3
		@auto_v255spositiontaking_1701			SMALLMONEY,--u3
	
		@auto_v255mpositiontaking_1701			SMALLMONEY,--um2
		@isauto_v255mpositiontaking_1701		BIT--im2
	
	DECLARE @roleid TINYINT	

	SELECT 	
		@Recommend = recommend,
		@MRecommend = mrecommend,
		@SRecommend = srecommend,	
		@UserName = username
		, @roleid = roleid
	FROM 
		custinfo WITH (NOLOCK)
	WHERE CustID = @CustID

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	--s1,u1,i1,m1,old_a1,im1,um1
	SELECT @v255spositiontaking_1701 = spositiontaking,
		@v255mpositiontaking_1701	 = mpositiontaking,
		@db_v255apositiontaking_1701 = apositiontaking,
		@auto_v255spositiontaking_1701_mem	= autopositiontaking,
		@isauto_v255spositiontaking_1701_mem = isautopositiontaking,
		@auto_v255mpositiontaking_1701_mem  = autompositiontaking,
		@isauto_v255mpositiontaking_1701_mem = isautompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 255 AND bettype = 1701

	----check if not change value
	--IF @db_v255apositiontaking_1701 = @v255apositiontaking_1701
	--	RETURN

	IF @v255apositiontaking_1701 < 0 OR @v255apositiontaking_1701 > 1
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					END, @ErrCode = 100
		RETURN
	END

	--check n2<=a1_new
	SELECT @ErrType = ''

	SELECT @ErrType = 'Min: ' + CAST(minpositiontaking AS VARCHAR(10))
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701 
		AND minpositiontaking > @v255apositiontaking_1701

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END, @ErrCode = 101
		RETURN	
	END

	--check a1_new < a2
	SELECT @ErrType = ''

	SELECT @ErrType = 'Max: ' + CAST(apositiontaking AS VARCHAR(10))
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701
		AND @v255apositiontaking_1701 > apositiontaking 

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END, @ErrCode = 103
		RETURN	
	END

	--Auto Master PT
	--u2,i2		
	SELECT @auto_v255mpositiontaking_1701 = autompositiontaking ,
		@isauto_v255mpositiontaking_1701 = isautompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701

	--m3,u3,i3
	SELECT @v255mpositiontaking_1701_max = mpositiontaking,
		@auto_v255spositiontaking_1701 = autopositiontaking,
		@isauto_v255spositiontaking_1701 = isautopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 255 AND bettype = 1701 	
		
	--s4
	SELECT @v255spositiontaking_1701_max = spositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 255 AND bettype = 1701 

	---------------------------------------------------------------------------------------------------------------------------------------------
	--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
	SELECT @auto_v255spositiontaking_1701 = CASE WHEN @isauto_v255spositiontaking_1701_mem > 0 THEN @auto_v255spositiontaking_1701_mem ELSE @auto_v255spositiontaking_1701 END,
		@isauto_v255spositiontaking_1701 = CASE WHEN @isauto_v255spositiontaking_1701_mem > 0 THEN @isauto_v255spositiontaking_1701_mem ELSE @isauto_v255spositiontaking_1701 END

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--um=im1>0?um1:um2, 
	--im=im1>0?im1:im2
	SELECT @auto_v255mpositiontaking_1701 = CASE WHEN @isauto_v255mpositiontaking_1701_mem > 0 THEN @auto_v255mpositiontaking_1701_mem ELSE @auto_v255mpositiontaking_1701 END,
		@isauto_v255mpositiontaking_1701 = CASE WHEN @isauto_v255mpositiontaking_1701_mem > 0 THEN @isauto_v255mpositiontaking_1701_mem  ELSE @isauto_v255mpositiontaking_1701 END

	--a1=min(a1,m3)
	SELECT @v255apositiontaking_1701 = CASE WHEN @v255apositiontaking_1701 > @v255mpositiontaking_1701_max THEN @v255mpositiontaking_1701_max ELSE @v255apositiontaking_1701 END

	--if im2 = 0 ,check m1 + a1_new < m3
	SELECT @ErrType = ''
	
	SELECT @ErrType = 'Max: ' + CAST((@v255mpositiontaking_1701_max - @v255mpositiontaking_1701) AS VARCHAR(50)) WHERE @isauto_v255mpositiontaking_1701 = 0 AND @v255mpositiontaking_1701 + @v255apositiontaking_1701 > @v255mpositiontaking_1701_max

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking .<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					END, @ErrCode = 102
		RETURN	
	END

	SELECT @v255apositiontaking_1701 = CASE WHEN @v255apositiontaking_1701 < 0 THEN 0 ELSE @v255apositiontaking_1701 END

	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Master Auto Position Taking***----------------------------------
	--use @auto_mpt at agent
	--@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
	--if um = 0 then m1 = m2
	--else	if um < m3 - a1 then m1 = um
	--		else m1 = m3 - a1

	--m1=iif(im,min(m3-a1,um),m1)
	SELECT @v255mpositiontaking_1701 = CASE WHEN @isauto_v255mpositiontaking_1701 > 0 THEN 
						CASE WHEN @v255mpositiontaking_1701_max - @v255apositiontaking_1701 > @auto_v255mpositiontaking_1701 THEN @auto_v255mpositiontaking_1701 ELSE @v255mpositiontaking_1701_max - @v255apositiontaking_1701 END 
							ELSE @v255mpositiontaking_1701 END

	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Auto Position Taking***----------------------------------
	--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
	--if @auto_spt = 0 then @spt = @spt  -- Auto pt is not used
	--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
	--		else @spt = @max_spt - @mpt - @apt
	SELECT @v255spositiontaking_1701 = CASE WHEN ISNULL(@isauto_v255spositiontaking_1701,0) <= 0 THEN @v255spositiontaking_1701 ELSE
		CASE WHEN @v255spositiontaking_1701_max - @v255mpositiontaking_1701 - @v255apositiontaking_1701 > @auto_v255spositiontaking_1701 THEN @auto_v255spositiontaking_1701 ELSE @v255spositiontaking_1701_max - @v255mpositiontaking_1701 - @v255apositiontaking_1701 END END

	--max_spositiontaking = if(i1||i3)s4:s4-m1-a1
	SELECT @v255spositiontaking_1701_max = CASE WHEN @isauto_v255spositiontaking_1701 > 0 THEN @v255spositiontaking_1701_max ELSE @v255spositiontaking_1701_max - @v255mpositiontaking_1701 - @v255apositiontaking_1701 END

	--//REPLACING CHECK MAX SUPER PT ON MEMBER
	--s1=min(s1,max_spositiontaking)
	SELECT @v255spositiontaking_1701 = CASE WHEN @v255spositiontaking_1701 > @v255spositiontaking_1701_max THEN @v255spositiontaking_1701_max ELSE @v255spositiontaking_1701 END

	UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
	SET	spositiontaking = @v255spositiontaking_1701,
		mpositiontaking = @v255mpositiontaking_1701,
		apositiontaking = @v255apositiontaking_1701
	WHERE custid = @custid AND sporttype = 255 AND bettype = 1701
	
	IF (@@error <> 0)
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104					
		RETURN	
	END	

				EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'GoldDeluxe',
		@SportType = 255,
		@BetType = 1701	

	IF (@@error <> 0)
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 104					
		RETURN	
	END	

	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB VARCHAR(5000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberGoldDeluxe_Positiontaking  custid ="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
						'v255apositiontaking_1701 = "' + COALESCE(CAST(@v255apositiontaking_1701 AS VARCHAR(50)), SPACE(1)) + '" ' + 
						'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(8000)),SPACE(1)) + '" />' 

	SELECT @TrackingValueDB =	'<Acc_CustomerUpdMemberGoldDeluxe_Positiontaking  custid ="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
								'v255apositiontaking_1701 = "' + COALESCE(CAST(@db_v255apositiontaking_1701 AS VARCHAR(50)), SPACE(1)) + '" ' + 
								'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
								'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
								'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
								'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
								'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
								'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(8000)),SPACE(1)) + '" />' 
	
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 460,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberGoldDeluxe_Positiontaking  custid ="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
							'v255apositiontaking_1701 = "' + COALESCE(CAST(@v255apositiontaking_1701 AS VARCHAR(50)), SPACE(1)) + '" ' + 
							'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
							'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
							'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
							'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
							'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
							'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
	
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 460,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Positiontaking] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Positiontaking] TO [vnteam] AS [dbo]