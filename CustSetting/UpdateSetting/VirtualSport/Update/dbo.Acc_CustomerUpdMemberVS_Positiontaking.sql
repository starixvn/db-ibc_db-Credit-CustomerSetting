USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]    Script Date: 06/16/2015 15:52:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberVS_Positiontaking    Script Date: 12/23/2013 2:26:52 PM ******/
ALTER PROCEDURE  [dbo].[Acc_CustomerUpdMemberVS_Positiontaking]
	@custid		INT,	
	
	@sporttype	INT,
	@bettype	INT,
	@a1			SMALLMONEY,
	
	@SubAccID	INT = 0,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT	
AS
	/*
		Created: Johnson
		Date: 2012-08-16
		Task: Agent update setting virtual sports on member
		DB: DBTXN/BODB02
		
		Revisions:
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20121204@Scott: Add more field Sporttype,bettype to Log
			- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
			- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)			
			- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
			- 20150606@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID, temp sport, bettype table) [Redmine:#36216]
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
		Parameter's Explanation:	
	*/
SET NOCOUNT ON 
------------------------
	DECLARE @startRun	DATETIME,
			@endRun		DATETIME,
			@duration	INT,
			
			@srecommend	INT,
			@mrecommend	INT,
			@recommend	INT,
						
			@s1			SMALLMONEY,
			@s1_max		SMALLMONEY,
			@m1			SMALLMONEY,
			@a1_old		SMALLMONEY,
			@us1		SMALLMONEY,
			@is1		BIT,
			@um1		SMALLMONEY,
			@im1		BIT,
			
			@um2		SMALLMONEY,
			@im2		BIT,
			
			@m3			SMALLMONEY,
			@is3		BIT,
			@us3		SMALLMONEY,
			
			@s4			SMALLMONEY,
			
			@roleid		TINYINT, 
			@ErrCode_Cur INT, 
			@ErrMsg_Cur NVARCHAR(4000),
			@ErrType	NVARCHAR(4000)
			
					
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''
		
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

	SET @startRun = GETDATE()
	
	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF (@roleid = 0) RETURN
	
	---------------------------
	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	--end
		
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
		
	IF @a1 < 0 OR @a1 > 0.9
	BEGIN
		SELECT @ErrMsg_Cur = 
						CASE @Language 
							WHEN 'E' THEN 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						END, @ErrCode_Cur = 100
						
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		
		RETURN		
	END
	
	--check n2<=a1<=l2 - Vinh
	SELECT @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee 
		+ '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
	FROM CustOverride3rd as co with (NOLOCK) inner join
		(
			select @bettype as bettype, @sporttype as sporttype, @a1 as apositiontaking 			
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_sports s on b.sporttype = s.sporttype
	WHERE co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	)		
	
	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg_Cur = 
						CASE @Language 
							WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
						END, @ErrCode_Cur = 101
		
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		
		RETURN	
	END
	
	--check a1<=min(a2,a4)
	SELECT @ErrType = ''

	SELECT @ErrType = 'Max: ' + CAST(CASE WHEN acs.apositiontaking > scs.apositiontaking THEN scs.apositiontaking ELSE acs.apositiontaking END AS VARCHAR(10))
	FROM CustSetting3rd acs WITH(NOLOCK)
		INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = acs.sporttype AND scs.bettype = acs.bettype	
	WHERE acs.custid = @recommend AND acs.sporttype = @sporttype AND acs.bettype = @bettype
		AND (@a1 > acs.apositiontaking OR @a1> scs.apositiontaking)
	
	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg_Cur = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					END, @ErrCode_Cur = 102
					
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
				
		RETURN	
	END
	
	--s1,u1,i1,m1,old_a1,im1,um1	
	SELECT @s1		= spositiontaking,
			@m1		= mpositiontaking,
			@a1_old = apositiontaking,
			@us1	= autopositiontaking,
			@is1	= isautopositiontaking,
			@um1	= autompositiontaking,
			@im1	= isautompositiontaking 
	FROM custsetting3rd WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
	
	--Auto Master PT
	------------------------------------------------------------------------------------------------------------------------------
	--u2,i2		
	SELECT @um2 = autompositiontaking, 
			@im2 = isautompositiontaking 
	FROM CustSetting3rd WITH (NOLOCK) 
	WHERE custid = @recommend AND bettype = @bettype AND sporttype = @sporttype
	
	--m3,u3,i3
	SELECT @m3 = mpositiontaking,
			@us3 = autopositiontaking,
			@is3 = isautopositiontaking
	FROM custsetting3rd WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = @sporttype AND bettype = @bettype
	
	--s4
	SELECT @s4 = spositiontaking
	FROM custsetting3rd WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = @sporttype AND bettype = @bettype
	
	--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
	SELECT @us3 = CASE WHEN @is1 > 0 THEN @us1 ELSE @us3 END,
			@is3 = CASE WHEN @is1 > 0 THEN @is1 ELSE @is3 END
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--um=im1>0?um1:um2, 
	--im=im1>0?im1:im2
	SELECT @um2 = CASE WHEN @im1 > 0 THEN @um1 ELSE @um2 END,
			@im2 = CASE WHEN @im1 > 0 THEN @im1 ELSE @im2 END
	
	--a1=min(a1,m3)
	SELECT @a1 = CASE WHEN @a1 > @m3 THEN @m3 ELSE @a1 END	
	
	--if im2 = 0 ,check m1 + a1_new < m3
	SELECT @ErrType = ''
	
	SELECT @ErrType = 'Max: ' + CAST((@m3 - @m1) AS VARCHAR(50)) WHERE @im2 = 0 AND @m1 + @a1 > @m3

	IF @ErrType <> ''
	BEGIN
		SELECT @ErrMsg_Cur = 
					CASE @Language 
						WHEN 'E' THEN 'Wrong position taking .<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					END, @ErrCode_Cur = 103
		
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
							
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
	SELECT @m1 = CASE WHEN @im2 > 0 THEN CASE WHEN @m3 - @a1 > @um2 THEN @um2 ELSE @m3 - @a1 END
					ELSE @m1 END
	
	---------------------------------------------------------------------------------------------------------------------------------------------
	----------------***Use Auto Position Taking***----------------------------------
	--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
	--if @auto_spt = 0 then @spt = @spt  -- Auto pt is not used
	--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
	--		else @spt = @max_spt - @mpt - @apt
	SELECT @s1 = CASE WHEN ISNULL(@is3,0) <= 0 THEN @s1 ELSE
					CASE WHEN @s4 - @m1 -@a1 > @us3 THEN @us3 ELSE @s4 - @m1 - @a1 END END
	
	
	--max_spositiontaking = if(i1||i3)s4:s4-m1-a1
	SELECT @s1_max = CASE WHEN @is3 > 0 THEN @s4 ELSE @s4 - @m1 - @a1 END
	
	--//REPLACING CHECK MAX SUPER PT ON MEMBER
	--s1=min(s1,max_spositiontaking)
	SELECT @s1 = CASE WHEN @s1 > @s1_max THEN @s1_max ELSE @s1 END	
		
	UPDATE custsetting3rd WITH(UPDLOCK, ROWLOCK)
	SET  spositiontaking = @s1,
		mpositiontaking = @m1,
		apositiontaking = @a1
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
	
	IF (@@error <> 0)
	BEGIN		
		SELECT @ErrMsg_Cur = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode_Cur = 104	
		
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)	
		RETURN	
	END	
	
	EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'virtual-sports',
		@sporttype =  @sporttype,   
		@bettype = @bettype
	---EXEC dbo.Acc_CustomerUpdMemberVS_MinMaxPositiontaking @sporttype = @sporttype, @bettype = @bettype, @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
	
	IF (@@error <> 0)
	BEGIN		
		SELECT @ErrMsg_Cur = CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END, @ErrCode_Cur = 105	
		
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)	
		RETURN	
	END	
			
	DECLARE @LogSPData VARCHAR(5000),
		@TrackingValueDB VARCHAR(5000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberVS_Positiontaking  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'a1="' + COALESCE(CAST(@a1 AS VARCHAR(50)), SPACE(1)) + '" ' + 
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(8000)),SPACE(1)) + '" />' 

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberVS_Positiontaking  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
		'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
		'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' +
		'a1="' + COALESCE(CAST(@a1_old AS VARCHAR(50)), SPACE(1)) + '" ' + 
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
			@ActionID = 434,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration	
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberVS_Positiontaking  custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) + '" ' +
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
			@ActionID = 434,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration	
	END CATCH			
	
	SELECT @ErrCode_Cur = -101 --success
	
	SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_Positiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberVS_Positiontaking] TO [vnteam] AS [dbo]