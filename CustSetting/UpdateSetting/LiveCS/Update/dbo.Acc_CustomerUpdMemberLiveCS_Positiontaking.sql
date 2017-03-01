ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_Positiontaking]
	@custid  INT,
	@v162apositiontaking_1101 SMALLMONEY,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT	
AS
	/*
		Created: Johnson
		Date: 17Jan2012
		Task: Update positiontaking live casino on member
		DB: DBTXN/BODB02
		
		Revisions:
			- 20120913@Johnson: correct m1 when im2= 1 and n3 is set
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: write log on DBTXN if DBLOG failure
			- 20130516@Lukas: allow PT = 100%
			- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
			- 20151016@Helen: Data Type Error - [Redmine - 45677] 
		Parameters Explanation:
	*/
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
	
	@v162spositiontaking_1101_min		SMALLMONEY,--n4
	@v162spositiontaking_1101_max		SMALLMONEY,--s4
	
	@v162spositiontaking_1101			SMALLMONEY,--s1
	@v162mpositiontaking_1101			SMALLMONEY, --m1
	@db_v162apositiontaking_1101		SMALLMONEY,--old a1
	@isauto_v162spositiontaking_1101_mem BIT,--i1
	@auto_v162spositiontaking_1101_mem	SMALLMONEY,--u1
	@isauto_v162mpositiontaking_1101_mem BIT, --im1
	@auto_v162mpositiontaking_1101_mem	SMALLMONEY,--um1
	
	@v162mpositiontaking_1101_min		SMALLMONEY,--n3
	@v162mpositiontaking_1101_max		SMALLMONEY, --m3
	@isauto_v162spositiontaking_1101		BIT, -- i3
	@auto_v162spositiontaking_1101		SMALLMONEY,--u3
	
	@auto_v162mpositiontaking_1101		SMALLMONEY,--um2
	@isauto_v162mpositiontaking_1101	BIT,--im2
	@SyncLiveCasino						BIT

SELECT 	
	@Recommend = recommend,
	@MRecommend = mrecommend,
	@SRecommend = srecommend,	
	@SyncLiveCasino = SyncLiveCasino,
	@UserName = username
FROM 
	custinfo WITH (NOLOCK)
WHERE CustID = @CustID

--s1,u1,i1,m1,old_a1,im1,um1
SELECT @v162spositiontaking_1101 = spositiontaking,
	@v162mpositiontaking_1101	 = mpositiontaking,
	@db_v162apositiontaking_1101 = apositiontaking,
	@auto_v162spositiontaking_1101_mem	= autopositiontaking,
	@isauto_v162spositiontaking_1101_mem = isautopositiontaking,
	@auto_v162mpositiontaking_1101_mem  = autompositiontaking,
	@isauto_v162mpositiontaking_1101_mem = isautompositiontaking
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

--check if not change value
IF @db_v162apositiontaking_1101 = @v162apositiontaking_1101 AND @SyncLiveCasino = 1
	RETURN

IF @v162apositiontaking_1101 < 0 OR @v162apositiontaking_1101 > 1
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
WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101 
	AND minpositiontaking > @v162apositiontaking_1101

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
WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101
	AND @v162apositiontaking_1101 > apositiontaking 

IF @ErrType <> ''
BEGIN
	SELECT @ErrMsg = 
				CASE @Language 
					WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
				END, @ErrCode = 103
	RETURN	
END

IF @SyncLiveCasino = 1
BEGIN
	--Auto Master PT
	--u2,i2		
	SELECT @auto_v162mpositiontaking_1101 = autompositiontaking ,
		@isauto_v162mpositiontaking_1101 = isautompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101

	--m3,u3,i3
	SELECT @v162mpositiontaking_1101_max = mpositiontaking,
		@auto_v162spositiontaking_1101 = autopositiontaking,
		@isauto_v162spositiontaking_1101 = isautopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101 	
		
	--s4
	SELECT @v162spositiontaking_1101_max = spositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101 

	---------------------------------------------------------------------------------------------------------------------------------------------
	--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
	SELECT @auto_v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_1101_mem > 0 THEN @auto_v162spositiontaking_1101_mem ELSE @auto_v162spositiontaking_1101 END,
		@isauto_v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_1101_mem > 0 THEN @isauto_v162spositiontaking_1101_mem ELSE @isauto_v162spositiontaking_1101 END

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--um=im1>0?um1:um2, 
	--im=im1>0?im1:im2
	SELECT @auto_v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_1101_mem > 0 THEN @auto_v162mpositiontaking_1101_mem ELSE @auto_v162mpositiontaking_1101 END,
		@isauto_v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_1101_mem > 0 THEN @isauto_v162mpositiontaking_1101_mem  ELSE @isauto_v162mpositiontaking_1101 END

	--a1=min(a1,m3)
	SELECT @v162apositiontaking_1101 = CASE WHEN @v162apositiontaking_1101 > @v162mpositiontaking_1101_max THEN @v162mpositiontaking_1101_max ELSE @v162apositiontaking_1101 END

	--if im2 = 0 ,check m1 + a1_new < m3
	SELECT @ErrType = ''
	
	SELECT @ErrType = 'Max: ' + CAST((@v162mpositiontaking_1101_max - @v162mpositiontaking_1101) AS VARCHAR(50)) WHERE @isauto_v162mpositiontaking_1101 = 0 AND @v162mpositiontaking_1101 + @v162apositiontaking_1101 > @v162mpositiontaking_1101_max

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking .<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					END, @ErrCode = 102
		RETURN	
	END
	--a1=if(!im)if(m1+a1>m3,m3-m1)
	--SELECT @v162apositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_1101 > 0 THEN @v162apositiontaking_1101 
	--		ELSE CASE WHEN  @v162mpositiontaking_1101 + @v162apositiontaking_1101 > @v162mpositiontaking_1101_max THEN @v162mpositiontaking_1101_max - @v162mpositiontaking_1101 ELSE @v162apositiontaking_1101 END END

	SELECT @v162apositiontaking_1101 = CASE WHEN @v162apositiontaking_1101 < 0 THEN 0 ELSE @v162apositiontaking_1101 END

	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Master Auto Position Taking***----------------------------------
	--use @auto_mpt at agent
	--@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
	--if um = 0 then m1 = m2
	--else	if um < m3 - a1 then m1 = um
	--		else m1 = m3 - a1

	--m1=iif(im,min(m3-a1,um),m1)
	SELECT @v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_1101 > 0 THEN 
						CASE WHEN @v162mpositiontaking_1101_max - @v162apositiontaking_1101 > @auto_v162mpositiontaking_1101 THEN @auto_v162mpositiontaking_1101 ELSE @v162mpositiontaking_1101_max - @v162apositiontaking_1101 END 
							ELSE @v162mpositiontaking_1101 END

	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Auto Position Taking***----------------------------------
	--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
	--if @auto_spt = 0 then @spt = @spt  -- Auto pt is not used
	--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
	--		else @spt = @max_spt - @mpt - @apt
	SELECT @v162spositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162spositiontaking_1101,0) <= 0 THEN @v162spositiontaking_1101 ELSE
		CASE WHEN @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 > @auto_v162spositiontaking_1101 THEN @auto_v162spositiontaking_1101 ELSE @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 END END

	--max_spositiontaking = if(i1||i3)s4:s4-m1-a1
	SELECT @v162spositiontaking_1101_max = CASE WHEN @isauto_v162spositiontaking_1101 > 0 THEN @v162spositiontaking_1101_max ELSE @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 END

	--//REPLACING CHECK MAX SUPER PT ON MEMBER
	--s1=min(s1,max_spositiontaking)
	SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 > @v162spositiontaking_1101_max THEN @v162spositiontaking_1101_max ELSE @v162spositiontaking_1101 END

	--BEGIN TRANSACTION
	UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
	SET	spositiontaking = @v162spositiontaking_1101,
		mpositiontaking = @v162mpositiontaking_1101,
		apositiontaking = @v162apositiontaking_1101
	WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
	
	EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'LiveCasino'
	
	---EXEC dbo.Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

	--COMMIT TRANSACTION
END
ELSE -- if member is not sync, re-calculate all pt
BEGIN
	--calculate m1
	--copy m1= m2
	SELECT @v162mpositiontaking_1101 = mpositiontaking 
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101
	
	--n3
	SELECT @v162mpositiontaking_1101_min = minpositiontaking 
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101
	
	--re-cal auto 
	--m3
	SELECT @v162mpositiontaking_1101_max = mpositiontaking 
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101 
	
	--um2,im2
	SELECT @auto_v162mpositiontaking_1101 = autompositiontaking,
		@isauto_v162mpositiontaking_1101 = isautompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101
	
	--m1 = (im2>0?min(m3-a1,um2),m1)
	SELECT @v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_1101 > 0 THEN 
							CASE WHEN @v162mpositiontaking_1101_max - @v162apositiontaking_1101 > @auto_v162mpositiontaking_1101 THEN @auto_v162mpositiontaking_1101 ELSE @v162mpositiontaking_1101_max - @v162apositiontaking_1101 END
						ELSE @v162mpositiontaking_1101 END
	
	--m1 = max(n3-a1,m1)
	SELECT @v162mpositiontaking_1101 = CASE WHEN @v162mpositiontaking_1101_min - @v162apositiontaking_1101 > @v162mpositiontaking_1101 THEN @v162mpositiontaking_1101_min - @v162apositiontaking_1101 ELSE @v162mpositiontaking_1101 END
		
	SELECT @v162mpositiontaking_1101 = CASE WHEN @v162mpositiontaking_1101 > 0 THEN @v162mpositiontaking_1101 ELSE 0 END
	
	--calculate s1
	--copy s1 = s3
	SELECT @v162spositiontaking_1101 = spositiontaking 
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101 
	
	--s4	
	SELECT @v162spositiontaking_1101_max = spositiontaking 
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101 
	
	--n4
	SELECT @v162spositiontaking_1101_min = minpositiontaking 
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101 
	
	--re-cal auto 
	--u3, i3
	SELECT @auto_v162spositiontaking_1101 = autopositiontaking,
		@isauto_v162spositiontaking_1101 = isautopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101 
	
	--s1 = (i3>0?min(s4-m1-a1,u3),s1)
	SELECT @v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_1101 > 0 THEN 
			CASE WHEN @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 > @auto_v162spositiontaking_1101 THEN @auto_v162spositiontaking_1101 
					ELSE @v162spositiontaking_1101_max - @v162mpositiontaking_1101 - @v162apositiontaking_1101 END
				ELSE @v162spositiontaking_1101 END
	
	
	--s1 = max(n4-m1-a1,s1)
	SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101_min - @v162mpositiontaking_1101 - @v162apositiontaking_1101 > @v162spositiontaking_1101 
					THEN @v162spositiontaking_1101_min - @v162mpositiontaking_1101 - @v162apositiontaking_1101
					ELSE @v162spositiontaking_1101 END
	
	SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 > 0 THEN @v162spositiontaking_1101 ELSE 0 END 
	
	UPDATE CustSettingGame WITH(UPDLOCK,ROWLOCK)
	SET	spositiontaking = @v162spositiontaking_1101,
		mpositiontaking = @v162mpositiontaking_1101,
		apositiontaking = @v162apositiontaking_1101
	WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
END

DECLARE @LogSPData VARCHAR(MAX),
		@TrackingValueDB VARCHAR(5000)

SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_Positiontaking  custid ="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162apositiontaking_1101 = "' + COALESCE(CAST(@v162apositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' + 
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(8000)),SPACE(1)) + '" />' 

SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberLiveCS_Positiontaking  custid ="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162apositiontaking_1101 = "' + COALESCE(CAST(@db_v162apositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' + 
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
		@ActionID = 427,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_Positiontaking  custid ="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
	'v162apositiontaking_1101 = "' + COALESCE(CAST(@v162apositiontaking_1101 AS VARCHAR(50)), SPACE(1)) + '" ' + 
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 427,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_Positiontaking] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberLiveCS_Positiontaking] TO [vnteam] AS [dbo]