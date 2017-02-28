USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberLiveCS_MAg]    Script Date: 06/09/2015 15:38:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberLiveCS_MAg    Script Date: 9/29/2014 10:46:48 PM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberLiveCS_MAg    Script Date: 9/26/2014 2:49:27 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_MAg]
	@custid									INT,		

	@v162mpositiontaking_1101				SMALLMONEY,	
	@auto_v162mpositiontaking_mem_1101			SMALLMONEY,
	@isauto_v162mpositiontaking_mem_1101		BIT,
	--im2
	@isauto_v162mpositiontaking_1101			BIT,

	@v162UpdatePositiontaking_1101			BIT = 1,	
	@v162UpdateAutoPositiontaking_1101		BIT = 1,

	@userid									INT,
	@SubAccID								INT = 0, --Sub-AccountID
	@Language								VARCHAR(2) = 'E',
	@IP										VARCHAR(19),
	@Username								NVARCHAR(50) = '' OUTPUT,	
	@ErrCode								VARCHAR(300) = '' OUTPUT,
	@ErrMsg									NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20120111@Lukas
	Task: Master edit live casino PT setting on member
	DB: DBTXN/BODB02
	
	Revisions:
		- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
		- 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
		- 20130516@Lukas: allow PT = 100%
		- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
		- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
		- 20140318@Johnson: check um1 with constraint um1_min and merge code correct pt [Redmine: #11562]
		- 20140926@Johnson: remove bettype name out of error message
		- 20150606@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID) [Redmine:#36216]
	Parameters Explanation:
*/
BEGIN

	SET NOCOUNT ON 

	declare @startRun datetime,
			@endRun datetime,
			@duration int

	set @startRun = getdate()

	DECLARE @ErrType varchar(1000), @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000),
			@recommend INT,	@srecommend INT, @mrecommend INT, @UplineSyncLiveCS BIT

	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney

	DECLARE @tmp_cs TABLE (custid INT, sporttype INT, bettype INT, 
				spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, apositiontaking SMALLMONEY, 
				isautopositiontaking BIT, isautompositiontaking BIT, autopositiontaking SMALLMONEY, autompositiontaking SMALLMONEY)	

	DECLARE @tmp_sag TABLE(custid INT, sporttype INT, bettype INT, spositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	DECLARE @tmp_mag TABLE(custid INT, sporttype INT, bettype INT, mpositiontaking SMALLMONEY, isautopositiontaking BIT, autopositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	DECLARE @tmp_ag TABLE(custid INT, sporttype INT, bettype INT, apositiontaking SMALLMONEY, isautompositiontaking BIT, autompositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)

	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
		@SessionCustID = @mrecommend, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF (@roleid = 0) RETURN
	---------------------------

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + CONVERT(VARCHAR(300),@ErrCode_cur) + CHAR(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END

	
	select @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend 
	from customer with (NOLOCK) where custid = @custid
	
	
	INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking)
	SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 162 AND bettype = 1101 
	
	IF (@v162mpositiontaking_1101 < 0 OR @v162mpositiontaking_1101 > 1
		OR @auto_v162mpositiontaking_mem_1101 < 0 OR @auto_v162mpositiontaking_mem_1101 > 1)
		AND @v162UpdatePositiontaking_1101 = 1
	BEGIN
		select @ErrCode_cur = 5
		Select @ErrMsg_cur = case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	DECLARE 
	--a1
	@v162apositiontaking_1101 SMALLMONEY,
	--a2
	@max_v162apositiontaking_1101 SMALLMONEY,
	--old_m1	
	@old_v162mpositiontaking_1101 SMALLMONEY,
	--old_um1
	@old_auto_v162mpositiontaking_mem_1101 SMALLMONEY,
	--old_im1
	@old_isauto_v162mpositiontaking_mem_1101 BIT,
	--s4
	@max_v162spositiontaking_1101 SMALLMONEY,
	@v162spositiontaking_1101 SMALLMONEY,
	--u1
	@auto_v162spositiontaking_mem_1101 SMALLMONEY,
	--i1
	@isauto_v162spositiontaking_mem_1101 BIT,
	--u3
	@auto_v162spositiontaking_1101 SMALLMONEY,
	--i3
	@isauto_v162spositiontaking_1101 BIT,
	--um2
	@auto_v162mpositiontaking_1101 SMALLMONEY,
	---- backup to write log
	@isauto_v162mpositiontaking_agent_1101 bit
	
	DECLARE
	@max_v162mapositiontaking_1101 SMALLMONEY
	
	
	-- backup
	SELECT 
	@isauto_v162mpositiontaking_agent_1101 = @isauto_v162mpositiontaking_1101
	--s1,a1,old_m1,u1,i1
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN
		SELECT	@v162spositiontaking_1101 = spositiontaking, 
				@v162apositiontaking_1101 = apositiontaking, 
				@auto_v162spositiontaking_mem_1101 = autopositiontaking, 
				@isauto_v162spositiontaking_mem_1101 = isautopositiontaking, 
				@old_v162mpositiontaking_1101 = mpositiontaking , 
				@old_auto_v162mpositiontaking_mem_1101 = autompositiontaking , 
				@old_isauto_v162mpositiontaking_mem_1101 = isautompositiontaking 
		FROM @tmp_cs
		WHERE bettype=1101 AND sporttype=162
	END

	--Check if old_PT = new_PT return
	IF @v162mpositiontaking_1101 = @old_v162mpositiontaking_1101 AND
		--um1
		@auto_v162mpositiontaking_mem_1101 = @old_auto_v162mpositiontaking_mem_1101 AND
		--im1
		@isauto_v162mpositiontaking_mem_1101 = @old_isauto_v162mpositiontaking_mem_1101
		
	BEGIN	
		Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)
		RETURN 
	END	
		
	INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, minpositiontaking)
	SELECT scs.custid, scs.sporttype, scs.bettype, scs.spositiontaking, sco.minpositiontaking
	FROM CustSettingGame scs WITH(NOLOCK)
		INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON scs.custid = sco.custid AND scs.sporttype = sco.sporttype AND scs.bettype = sco.bettype
	WHERE scs.custid = @srecommend AND scs.sporttype = 162 and scs.bettype = 1101

	INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, isautopositiontaking, autopositiontaking, minpositiontaking)
	SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, isautopositiontaking, autopositiontaking, minpositiontaking
	FROM  CustSettingGame mcs WITH(NOLOCK)
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mcs.custid = mco.custid AND mcs.sporttype = mco.sporttype AND mcs.bettype = mco.bettype
	WHERE mcs.custid = @mrecommend AND mcs.sporttype = 162 and mcs.bettype = 1101

	INSERT INTO @tmp_ag(custid, sporttype, bettype, apositiontaking, isautompositiontaking, autompositiontaking, minpositiontaking)
	SELECT acs.custid, acs.sporttype, acs.bettype, apositiontaking, isautompositiontaking, autompositiontaking, minpositiontaking
	FROM CustSettingGame acs WITH(NOLOCK)
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON acs.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
	WHERE acs.custid = @recommend AND acs.sporttype = 162 and acs.bettype = 1101

	SELECT @UplineSyncLiveCS = SyncLiveCasino FROM CustInfo WITH(NOLOCK) WHERE custid = @recommend 
		

	IF @v162UpdateAutoPositiontaking_1101 = 1 
	BEGIN
		--Check um1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: '+ CAST((mcs.mpositiontaking) AS VARCHAR(10))
		FROM @tmp_mag AS mcs INNER JOIN
			(
				SELECT 162 AS sporttype, 1101 AS bettype, @auto_v162mpositiontaking_mem_1101 AS autopositiontaking, @isauto_v162mpositiontaking_mem_1101 AS isautopositiontaking
			) AS b ON mcs.sporttype=b.sporttype AND mcs.bettype=b.bettype		
		WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>mcs.mpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 7,
				   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		
		--check um1>=u1_min
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType +  'Min: '+ CAST((mco.minpositiontaking - cs.apositiontaking) AS VARCHAR(10))
		FROM @tmp_mag AS mco 
		INNER JOIN @tmp_cs cs ON mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype		
		INNER JOIN	(
				SELECT 162 AS sporttype, 1101 AS bettype, @auto_v162mpositiontaking_mem_1101 AS autopositiontaking, @isauto_v162mpositiontaking_mem_1101 AS isautopositiontaking
			) AS b ON mco.sporttype=b.sporttype AND mco.bettype=b.bettype		
		WHERE (b.isautopositiontaking>0 AND cs.apositiontaking + b.autopositiontaking < mco.minpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 10,
				   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
	END

	--m3,u3,i3	
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN
		SELECT @max_v162mapositiontaking_1101 = mpositiontaking, @auto_v162spositiontaking_1101 = autopositiontaking, @isauto_v162spositiontaking_1101 = isautopositiontaking 
		FROM @tmp_mag 
		WHERE bettype=1101 AND sporttype=162
				
		--s4
		SELECT @max_v162spositiontaking_1101 = spositiontaking 
		FROM @tmp_sag
		WHERE bettype=1101 AND sporttype=162
	END

	--um2
	SELECT 
		@auto_v162mpositiontaking_1101 = MAX(acs.autompositiontaking),
		--a2	
		@max_v162apositiontaking_1101 = MAX(acs.apositiontaking)		
	FROM @tmp_ag acs 
	WHERE acs.sporttype = 162 AND acs.bettype = 1101
			
	IF @v162UpdatePositiontaking_1101 = 1 OR @v162UpdateAutoPositiontaking_1101 = 1
	BEGIN	
		--Check m1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: '+ CAST((mcs.mpositiontaking) AS VARCHAR(10))
		FROM @tmp_mag mcs INNER JOIN 
			(
				SELECT 162 AS sporttype	,	 1101 AS bettype	,	 @v162mpositiontaking_1101 AS mpositiontaking
			)b ON mcs.sporttype = b.sporttype AND mcs.bettype = b.bettype					
		WHERE (b.mpositiontaking>mcs.mpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		
		--check m1 + a1 <= m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: '+ CAST((mcs.mpositiontaking - cs.apositiontaking) AS VARCHAR(10))
		FROM @tmp_mag mcs INNER JOIN 
			(
				SELECT 162 AS sporttype	,	 1101 AS bettype	,	 @v162mpositiontaking_1101 AS mpositiontaking
			)b ON mcs.sporttype = b.sporttype AND mcs.bettype = b.bettype	
			INNER JOIN @tmp_cs cs ON mcs.sporttype = cs.sporttype and mcs.bettype = cs.bettype				
		WHERE (b.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
				
		--Check m1 + a1 >= n3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Min: ' + CAST((mco.minpositiontaking - cs.apositiontaking) AS VARCHAR(10))  
		FROM @tmp_cs cs
			INNER JOIN @tmp_mag mco ON cs.sporttype = mco.sporttype AND cs.bettype = mco.bettype			
		WHERE cs.apositiontaking + @v162mpositiontaking_1101< mco.minpositiontaking
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 9,
					@ErrMsg_cur = CASE @Language 
						WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
				END
										
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		
		--m1=m1+a1>m3?m3-a1:m1
		SELECT 
			@v162mpositiontaking_1101 = CASE WHEN cs.apositiontaking + @v162mpositiontaking_1101> mcs.mpositiontaking THEN mcs.mpositiontaking- cs.apositiontaking ELSE @v162mpositiontaking_1101 END
		FROM @tmp_cs cs
			INNER JOIN @tmp_mag mcs ON cs.sporttype = mcs.sporttype AND cs.bettype = mcs.bettype
		WHERE cs.sporttype = 162 AND cs.bettype = 1101

		--m1=m1+a1<n3?n3-a1:m1
		--SELECT 
		--	@v162mpositiontaking_1101 = CASE WHEN @v162apositiontaking_1101+@v162mpositiontaking_1101<@min_v162mapositiontaking_1101 THEN @min_v162mapositiontaking_1101-@v162apositiontaking_1101 ELSE @v162mpositiontaking_1101 END		

		SELECT 
			@v162mpositiontaking_1101 = CASE WHEN @v162mpositiontaking_1101<0 THEN 0 ELSE @v162mpositiontaking_1101 END
			
			
		--Must include code for auto master
			--um=im1>0?um1:um2
			--im=im1>0?im1:im2
			--m1=im>0?min(um,m3-a1):m1
			----------------------------------------------------------------------------------------------------------------------------
			--auto master

			--um=im1>0?um1:um2
			SELECT 
				@auto_v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_mem_1101>0 THEN @auto_v162mpositiontaking_mem_1101 ELSE @auto_v162mpositiontaking_1101 END,		
				
				--im=im1>0?im1:im31
				@isauto_v162mpositiontaking_1101 = CASE WHEN @isauto_v162mpositiontaking_mem_1101>0 THEN @isauto_v162mpositiontaking_mem_1101 ELSE @isauto_v162mpositiontaking_1101 END			
			---------------------------------------------------------------------------------------------------------------------------------------------
		----------------***Use Auto Position Taking***----------------------------------
		--m1=im>0?min(um,m3-a1):m1
		SELECT @v162mpositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162mpositiontaking_1101, 0)<=0 THEN @v162mpositiontaking_1101 
													ELSE CASE WHEN @auto_v162mpositiontaking_1101 < mcs.mpositiontaking - cs.apositiontaking THEN @auto_v162mpositiontaking_1101 ELSE mcs.mpositiontaking - cs.apositiontaking END END
		FROM @tmp_cs cs
			INNER JOIN @tmp_mag mcs ON cs.sporttype = mcs.sporttype AND cs.bettype = mcs.bettype													
		WHERE cs.sporttype = 162 AND cs.bettype = 1101
		-------------------------------------------------------------------------------
		
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
		SELECT 
			@auto_v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_mem_1101>0 THEN @auto_v162spositiontaking_mem_1101 ELSE @auto_v162spositiontaking_1101 END,
			@isauto_v162spositiontaking_1101 = CASE WHEN @isauto_v162spositiontaking_mem_1101>0 THEN @isauto_v162spositiontaking_mem_1101 ELSE @isauto_v162spositiontaking_1101 END		
		-----------------------------------------------------------------------------------------------------------------------------------------------

		------------------***Use Auto Position Taking***----------------------------------
		SELECT @v162spositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162spositiontaking_1101, 0)<=0 THEN @v162spositiontaking_1101 ELSE CASE WHEN @auto_v162spositiontaking_1101 < @max_v162spositiontaking_1101 - @v162mpositiontaking_1101 - @v162apositiontaking_1101 THEN @auto_v162spositiontaking_1101 ELSE @max_v162spositiontaking_1101 - @v162mpositiontaking_1101 - @v162apositiontaking_1101 END END
		
		---------------------------------------------------------------------------------
		----maxs1=isauto?s4:s4-m2
		SELECT @max_v162spositiontaking_1101 = CASE WHEN ISNULL(@isauto_v162spositiontaking_1101, 0)>0 THEN @max_v162spositiontaking_1101 ELSE @max_v162spositiontaking_1101-@max_v162mapositiontaking_1101 END
		----s1=s1>maxs1?maxs1:s1
		SELECT @v162spositiontaking_1101 = CASE WHEN @v162spositiontaking_1101 > @max_v162spositiontaking_1101 THEN @max_v162spositiontaking_1101 ELSE @v162spositiontaking_1101 END
				
	END
	--don't update m1,s1 for member under agent was set im2=1
	UPDATE cs
	SET	mpositiontaking = @v162mpositiontaking_1101 ,
		spositiontaking = @v162spositiontaking_1101
	FROM @tmp_cs cs
		INNER JOIN @tmp_ag acs ON cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
	WHERE acs.isautompositiontaking = 0 AND cs.sporttype = 162
	/*
	UPDATE cs WITH (ROWLOCK, UPDLOCK)
	SET
		mpositiontaking = CASE	WHEN cs.bettype = 1101 and cs.sporttype = 162 THEN @v162mpositiontaking_1101 
							ELSE cs.mpositiontaking END,
		spositiontaking = CASE WHEN cs.bettype = 1101 and cs.sporttype = 162 THEN @v162spositiontaking_1101 
							ELSE cs.spositiontaking END
	FROM CustSettingGame cs 
		INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
	WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 AND cs.sporttype = 162
	*/
	
	--Update auto PT
	--------------------------------------------------------
	--Update Member account (autompositiontaking field)
	UPDATE cs
	SET autompositiontaking =  b.autompositiontaking, 
		isautompositiontaking = b.isautompositiontaking 
	FROM @tmp_cs cs	inner join 
			(
				--select 1101 as bettype, 162 as sporttype, @auto_v162mpositiontaking_mem_1101 as autompositiontaking, @isauto_v162mpositiontaking_mem_1101 as isautompositiontaking
				select 1101 as bettype, 162 as sporttype, @auto_v162mpositiontaking_mem_1101 as autompositiontaking, @isauto_v162mpositiontaking_mem_1101 as isautompositiontaking
			 ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
	/*
	update CustSettingGame with (ROWLOCK, UPDLOCK) 
	set autompositiontaking =  b.autompositiontaking, 
		isautompositiontaking = b.isautompositiontaking 
	from CustSettingGame as cs inner join 
			(
				--select 1101 as bettype, 162 as sporttype, @auto_v162mpositiontaking_mem_1101 as autompositiontaking, @isauto_v162mpositiontaking_mem_1101 as isautompositiontaking
				select 1101 as bettype, 162 as sporttype, @auto_v162mpositiontaking_mem_1101 as autompositiontaking, @isauto_v162mpositiontaking_mem_1101 as isautompositiontaking
			 ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
	where cs.custid = @custid
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrCode_cur = 101,
				@ErrMsg_cur =  
						case @Language 
							when 'E' then 'Error updating auto position taking'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
						end	
		SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	*/
	
	declare @maxpos smallmoney
	if @isauto_v162mpositiontaking_1101 >0 
	BEGIN
		select @maxpos = mpositiontaking from @tmp_mag where sporttype=162 and bettype = 1101		
		UPDATE cs
		SET mpositiontaking = case when @maxpos - apositiontaking>@auto_v162mpositiontaking_1101 then @auto_v162mpositiontaking_1101 else @maxpos - apositiontaking end
		FROM @tmp_cs cs
		WHERE cs.bettype = 1101 and cs.sporttype = 162
		/*
		select @maxpos = mpositiontaking from CustSettingGame with (NOLOCK) where custid = @mrecommend and sporttype=162 and bettype = 1101
		update CustSettingGame with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v162mpositiontaking_1101 then @auto_v162mpositiontaking_1101 else @maxpos - apositiontaking end
		from CustSettingGame as cs
		where custid = @custid and cs.bettype = 1101 and cs.sporttype = 162
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		*/
	END
	
	---merge code correct pt
	--check agent min/max
	--update a1=n2 when a1<n2
	UPDATE cs
	SET cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
	FROM @tmp_cs cs	
		INNER JOIN @tmp_ag aco ON cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
		INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.apositiontaking < aco.minpositiontaking
	
	--Recal AUTO MPT 
	--Update m1=min(m3-a1,(im1?um1,um2))
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
				CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END ELSE mcs.mpositiontaking - cs.apositiontaking END
	FROM @tmp_cs cs
		INNER JOIN @tmp_ag acs ON acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
		INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
		
	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
	FROM @tmp_cs cs
		INNER JOIN @tmp_mag mco ON mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype= 1101
	
	--update m1,a1 when a1+m1>m3
	--update m1=if(m3-a1<0,0,m3-a1)
	--update a1=if(a1+m1>m3,m3-m1,a1)
	UPDATE cs
	SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN @mpos + cs.apositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END	
	FROM @tmp_cs cs
		INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN @tmp_ag aco ON aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 		
			
	--recal autopos
	UPDATE cs
	SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
										CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
								ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
	FROM @tmp_cs cs
		INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN @tmp_sag scs ON scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101
		AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
		
	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	UPDATE cs
	SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
	FROM @tmp_cs cs
		INNER JOIN @tmp_sag sco ON sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.spositiontaking + cs.mpositiontaking  + cs.apositiontaking < sco.minpositiontaking
	
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	
	UPDATE cs
	SET @spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
		cs.spositiontaking = @spos,
		@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
		@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
		@mapos  = CASE WHEN @mapos > mcs.minpositiontaking THEN @mapos ELSE mcs.minpositiontaking END,		
		@mpos = CASE WHEN @mapos - cs.apositiontaking > 0 THEN @mapos - cs.apositiontaking ELSE 0 END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN @apos ELSE aco.minpositiontaking END
	FROM @tmp_cs cs
		INNER JOIN @tmp_sag scs ON scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 		
		INNER JOIN @tmp_ag aco ON aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE @UplineSyncLiveCS = 1 AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
	
	UPDATE cs
	SET  cs.spositiontaking = t.spositiontaking
		,cs.mpositiontaking = t.mpositiontaking
		,cs.apositiontaking = t.apositiontaking
		,cs.isautopositiontaking = t.isautopositiontaking
		,cs.isautompositiontaking = t.isautompositiontaking 
		,cs.autopositiontaking = t.autopositiontaking
		,cs.autompositiontaking = t.autompositiontaking
	FROM CustSettingGame cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tmp_cs t ON cs.custid = t.custid AND cs.sporttype = t.sporttype AND cs.bettype = t.bettype
	WHERE cs.spositiontaking <> t.spositiontaking
		OR cs.mpositiontaking <> t.mpositiontaking
		OR cs.apositiontaking <> t.apositiontaking
		OR cs.isautopositiontaking <> t.isautopositiontaking
		OR cs.isautompositiontaking <> t.isautompositiontaking 
		OR cs.autopositiontaking <> t.autopositiontaking
		OR cs.autompositiontaking <> t.autompositiontaking
		
	/*
	EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'LiveCasino'
	*/	
	---EXEC dbo.Acc_CustomerUpdMemberLiveCS_MinPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend


	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB VARCHAR(5000)

	Select @LogSPData = '<Acc_CustomerUpdMemberLiveCS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v162mpositiontaking_1101="'+ coalesce(cast(@v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_agent_1101 as varchar(50)),SPACE(1)) + '" ' +
	'isauto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +	
	'auto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@auto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
	'v162updatepositiontaking_1101="' + coalesce(cast(@v162updatepositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	'v162updateautopositiontaking_1101="' + coalesce(cast(@v162updateautopositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 

	
	
	Select @TrackingValueDB = '<Acc_CustomerUpdMemberLiveCS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	
	'v162mpositiontaking_1101="'+ coalesce(cast(@old_v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
	'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_agent_1101 as varchar(50)),SPACE(1)) + '" ' +
	'isauto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@old_isauto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
	'auto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@old_auto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
	'v162updatepositiontaking_1101="' + coalesce(cast(@v162updatepositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	'v162updateautopositiontaking_1101="' + coalesce(cast(@v162updateautopositiontaking_1101 as varchar(10)), space(1)) + '" ' +
	
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' 

	
	
	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	--Log positiontaking
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 429,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdMemberLiveCS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	
		'v162mpositiontaking_1101="'+ coalesce(cast(@v162mpositiontaking_1101 as varchar(50)),space(1)) + '" ' +
		'isauto_v162mpositiontaking_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_agent_1101 as varchar(50)),SPACE(1)) + '" ' +
		'isauto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@isauto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +	
		'auto_v162mpositiontaking_mem_1101="'+ coalesce(cast(@auto_v162mpositiontaking_mem_1101 as varchar(50)),SPACE(1)) + '" ' +
		'v162updatepositiontaking_1101="' + coalesce(cast(@v162updatepositiontaking_1101 as varchar(10)), space(1)) + '" ' +
		'v162updateautopositiontaking_1101="' + coalesce(cast(@v162updateautopositiontaking_1101 as varchar(10)), space(1)) + '" ' +
		
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />' 
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 429,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH


	Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_MAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_MAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_MAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberLiveCS_MAg] TO [vnteam] AS [dbo]