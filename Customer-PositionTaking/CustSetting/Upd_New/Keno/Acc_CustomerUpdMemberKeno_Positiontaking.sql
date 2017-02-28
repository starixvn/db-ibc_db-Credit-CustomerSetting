ALTER PROCEDURE  [dbo].[Acc_CustomerUpdMemberKeno_Positiontaking]
	@custid		INT,	
	@sporttype INT = 202,
	@bettype INT,

	@a1 SMALLMONEY,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: Elodie
	Date: 2014-03-17
	Task: Agent update setting Keno on member
	DB: DBCUST/CustDB
		
	Revisions:
		- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)		
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
	Parameter's Explanation:	
*/
SET NOCOUNT ON 
----- David @ 09 JUN 2015 -------------------
	DECLARE @tmp_Sports TABLE (SportType TINYINT, SportName NVARCHAR(50))
	DECLARE @tmp_Bettype TABLE (TypeID INT, TypeNamee NVARCHAR(50))

	BEGIN TRY
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)		
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)	
	END CATCH

	BEGIN TRY			
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBAGE.bodb02.dbo.Bettype WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBTXN.bodb02.dbo.Bettype WITH (NOLOCK)
	END CATCH

----- /David @ 09 JUN 2015 -------------------
DECLARE @startRun	DATETIME,
		@endRun		DATETIME,
		@duration	INT,
			
		@srecommend	INT,
		@mrecommend	INT,
		@recommend	INT,
						
		@spositiontaking				SMALLMONEY,
		@spositiontaking_max			SMALLMONEY,
		@mpositiontaking				SMALLMONEY,
		@apositiontaking_old			SMALLMONEY,
		@auto_spositiontaking_mem		SMALLMONEY,
		@isauto_spositiontaking_mem		BIT,
		@auto_mpositiontaking_mem		SMALLMONEY,
		@isauto_mpositiontaking_mem		BIT,
			
		@auto_mpositiontaking			SMALLMONEY,
		@isauto_mpositiontaking			BIT,
			
		@mpositiontaking_max			SMALLMONEY,
		@isauto_spositiontaking			BIT,
		@auto_spositiontaking			SMALLMONEY,
			
		@spositiontaking_min			SMALLMONEY,
			
		@roleid		TINYINT, 		
		@ErrType	NVARCHAR(4000)
			
					
	SELECT @ErrCode = 0, @ErrMsg = ''
		
	SET @startRun = GETDATE()
	
	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF (@roleid = 0) RETURN
	
	---------------------------
	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode > 0
		RETURN
		
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
			, @roleid = roleid
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

	
	IF @a1 < 0 OR @a1 > 0.85
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
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
		+ '-Min: '+ cast((co.minpositiontaking) as varchar(10)) + '<br>'
	FROM CustOverrideGame as co with (NOLOCK) inner join
		(
			select @bettype as bettype, @sporttype as sporttype, @a1 as apositiontaking 			
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	WHERE co.custid = @recommend and b.apositiontaking<co.minpositiontaking	
	
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
	WHERE custid = @recommend AND sporttype = @sporttype AND bettype = @bettype
		AND @a1 > apositiontaking
	
	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END, @ErrCode = 102											
		RETURN	
	END
	
	--s1,u1,i1,m1,old_a1,im1,um1	
	SELECT	@spositiontaking			= spositiontaking,
			@mpositiontaking			= mpositiontaking,
			@apositiontaking_old		= apositiontaking,
			@auto_spositiontaking_mem	= autopositiontaking,
			@isauto_spositiontaking_mem	= isautopositiontaking,
			@auto_mpositiontaking_mem	= autompositiontaking,
			@isauto_mpositiontaking_mem	= isautompositiontaking 
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
	
	IF @apositiontaking_old = @a1 RETURN

	--Auto Master PT
	------------------------------------------------------------------------------------------------------------------------------
	--u2,i2		
	SELECT	@auto_mpositiontaking	= autompositiontaking, 
			@isauto_mpositiontaking = isautompositiontaking 
	FROM custsettingGame WITH (NOLOCK) 
	WHERE custid = @recommend AND bettype = @bettype AND sporttype = @sporttype
	
	--m3,u3,i3
	SELECT	@mpositiontaking_max = mpositiontaking,
			@auto_spositiontaking = autopositiontaking,
			@isauto_spositiontaking = isautopositiontaking
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = @sporttype AND bettype = @bettype
	
	--s4
	SELECT @spositiontaking_max = spositiontaking
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = @sporttype AND bettype = @bettype
	
	--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
	SELECT @auto_spositiontaking = CASE WHEN @isauto_spositiontaking_mem > 0 THEN @auto_spositiontaking_mem ELSE @auto_spositiontaking END,
			@isauto_spositiontaking = CASE WHEN @isauto_spositiontaking_mem > 0 THEN @isauto_spositiontaking_mem ELSE @isauto_spositiontaking END
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--um=im1>0?um1:um2, 
	--im=im1>0?im1:im2
	SELECT @auto_mpositiontaking = CASE WHEN @isauto_mpositiontaking_mem > 0 THEN @auto_mpositiontaking_mem ELSE @auto_mpositiontaking END,
			@isauto_mpositiontaking = CASE WHEN @isauto_mpositiontaking_mem > 0 THEN @isauto_mpositiontaking_mem ELSE @isauto_mpositiontaking END
	
	--a1=min(a1,m3)
	SELECT @a1 = CASE WHEN @a1 > @mpositiontaking_max THEN @mpositiontaking_max ELSE @a1 END	
	
	--if im2 = 0 ,check m1 + a1_new < m3
	SELECT @ErrType = ''
	
	SELECT @ErrType = 'Max: ' + CAST((@mpositiontaking_max - @mpositiontaking) AS VARCHAR(50)) WHERE @isauto_mpositiontaking = 0 AND @mpositiontaking + @a1 > @mpositiontaking_max

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking .<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					END, @ErrCode = 103
		RETURN	
	END
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Master Auto Position Taking***----------------------------------
	--use @auto_mpt at agent
	--@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
	--if um = 0 then m1 = m2
	--else	if um < m3 - a1 then m1 = um
	--		else m1 = m3 - a1

	--m1=iif(im,min(m3-a1,um),m1)
	SELECT @mpositiontaking = CASE WHEN @isauto_mpositiontaking > 0 THEN CASE WHEN @mpositiontaking_max - @a1 > @auto_mpositiontaking THEN @auto_mpositiontaking ELSE @mpositiontaking_max - @a1 END
					ELSE @mpositiontaking END
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Auto Position Taking***----------------------------------
	--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
	--if @auto_spt = 0 then @spt = @spt  -- Auto pt is not used
	--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
	--		else @spt = @max_spt - @mpt - @apt
	SELECT @spositiontaking = CASE WHEN ISNULL(@isauto_spositiontaking,0) <= 0 THEN @spositiontaking ELSE
					CASE WHEN @spositiontaking_max - @mpositiontaking -@a1 > @auto_spositiontaking THEN @auto_spositiontaking ELSE @spositiontaking_max - @mpositiontaking - @a1 END END
	
	
	--max_spositiontaking = if(i1||i3)s4:s4-m1-a1
	SELECT @spositiontaking_max = CASE WHEN @isauto_spositiontaking > 0 THEN @spositiontaking_max ELSE @spositiontaking_max - @mpositiontaking - @a1 END
	
	--//REPLACING CHECK MAX SUPER PT ON MEMBER
	--s1=min(s1,max_spositiontaking)
	SELECT @spositiontaking = CASE WHEN @spositiontaking > @spositiontaking_max THEN @spositiontaking_max ELSE @spositiontaking END	
		
	UPDATE custsettingGame WITH(UPDLOCK, ROWLOCK)
	SET  spositiontaking = @spositiontaking,
		mpositiontaking = @mpositiontaking,
		apositiontaking = @a1
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
	
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
		@mode = 'Keno',
		@sporttype =  @sporttype,   
		@bettype = @bettype
	
	IF (@@error <> 0)
	BEGIN		
		SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode = 105			
		RETURN	
	END	
			
	DECLARE @LogSPData VARCHAR(5000),
		@TrackingValueDB VARCHAR(5000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_Positiontaking  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'a1="' + COALESCE(CAST(@a1 AS VARCHAR(50)), SPACE(1)) + '" ' + 
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(8000)),SPACE(1)) + '" />' 

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_Positiontaking  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' +
		'a1="' + COALESCE(CAST(@apositiontaking_old AS VARCHAR(50)), SPACE(1)) + '" ' + 
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
			@ActionID = 445,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration	
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_Positiontaking  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'a1="' + COALESCE(CAST(@a1 AS VARCHAR(50)), SPACE(1)) + '" ' + 
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 445,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration	
	END CATCH
