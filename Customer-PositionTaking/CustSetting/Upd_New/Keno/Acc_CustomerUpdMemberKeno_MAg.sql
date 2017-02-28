ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_MAg]
	@custid INT
	, @SportType INT = 202 
	, @BetType INT

	, @m1 SMALLMONEY --m1
	, @um1 SMALLMONEY --um1
	, @im1 BIT --im1
	, @im2 BIT --im2

	, @UpdatePositiontaking BIT = 1
	, @UpdateAutoPositiontaking BIT = 1
	
	, @UserId INT
	, @SubAccID	INT = 0 --Sub-AccountID
	, @Language VARCHAR(2) = 'E'
	, @IP VARCHAR(19) = ''
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20140318@Patrick
	Task: Master edit Keno PT setting on member
	DB: DBTXN/CustDB
	Revisions:
		- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	Parameters Explanation:
	• @ErrCode:  
		<= 0: Update successfully.  
		> 0: Specific Error.
*/
BEGIN

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

	declare @startRun datetime  
	declare @endRun datetime  
	declare @duration int  
	set @startRun = getdate()  

	DECLARE @ErrType VARCHAR(1000), @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), 
			@recommend INT, @srecommend INT, @mrecommend INT, @UserName VARCHAR(50), @roleid TINYINT

	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney, @MaxPositionTaking smallmoney

	DECLARE @tmp_cs TABLE (custid INT, sporttype INT, bettype INT, 
				spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, apositiontaking SMALLMONEY, 
				isautopositiontaking BIT, isautompositiontaking BIT, autopositiontaking SMALLMONEY, autompositiontaking SMALLMONEY)	

	DECLARE @tmp_sag TABLE(custid INT, sporttype INT, bettype INT, spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	DECLARE @tmp_mag TABLE(custid INT, sporttype INT, bettype INT, mpositiontaking SMALLMONEY, isautopositiontaking BIT, autopositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	DECLARE @tmp_ag TABLE(custid INT, sporttype INT, bettype INT, apositiontaking SMALLMONEY, isautompositiontaking BIT, autompositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	
	DECLARE @APositionTaking SMALLMONEY--a1
		, @APositionTaking_Max SMALLMONEY--a2

		, @Old_MPositionTaking SMALLMONEY--old_m1
		, @Old_Auto_MPositionTaking_Mem SMALLMONEY--old_um1
		, @Old_IsAuto_MPositionTaking_Mem BIT--old_im1
		, @m1_log SMALLMONEY

		, @SPositionTaking_Max SMALLMONEY--s4

		, @SPositionTaking SMALLMONEY --s1
		, @Auto_SPositionTaking_Mem SMALLMONEY--u1
		, @IsAuto_SPositionTaking_Mem BIT--i1

		, @Auto_SPositionTaking SMALLMONEY--u3
		, @IsAuto_SPositionTaking BIT--i3
		, @Auto_MPositionTaking SMALLMONEY--um2
		, @IsAuto_MPositionTaking_BK bit-- backup to write log

		, @m3 SMALLMONEY
		, @u3 SMALLMONEY
		, @i3 BIT
		, @n3 SMALLMONEY

		, @MPositionTaking_Max SMALLMONEY
		, @MPositionTaking_Min SMALLMONEY
	

	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = '', @startRun = GETDATE()

	EXEC Age_CustomerSelCheckBelonging   
		 @SessionCustID = @Userid,   
		 @username = @username output,  
		 @Custid = @custid,  
		 @roleid = @roleid OUTPUT  
	if (@roleid <> 1) return -- return if not member 

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
													, @ErrCode = @ErrCode_Cur OUTPUT
													, @ErrMsg = @ErrMsg_Cur OUTPUT
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + CONVERT(VARCHAR(300), @ErrCode_cur) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	
	SELECT @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend 
	FROM dbo.customer WITH (NOLOCK) WHERE custid = @custid

	INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking)
	SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype 

	SELECT @MaxPositionTaking = mpositiontaking --m3			
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
	WHERE custid = @mrecommend AND bettype = @BetType AND sporttype = @SportType

	IF @UpdatePositiontaking = 1 AND (@m1 < 0 OR @m1 > @MaxPositionTaking
												OR @um1 < 0 OR @um1 > @MaxPositionTaking)
	BEGIN
		SELECT @ErrCode_cur = 5
		SELECT @ErrMsg_cur = @UserName + ': ' +	CASE @Language WHEN 'E' THEN 'Wrong position taking.' ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
		SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		RETURN
	END
	
	-- backup
	SELECT @IsAuto_MPositionTaking_BK = @im2

	----DB adjust value @IsAuto_MPositionTaking
	--SELECT @IsAuto_MPositionTaking = isautompositiontaking
	--FROM dbo.CustSettingGame WITH (NOLOCK)
	--WHERE custid = @recommend AND bettype = @BetType AND sporttype = @SportType

	
	--s1,a1,old_m1,u1,i1
	SELECT	@SPositionTaking = spositiontaking --s1
		, @APositionTaking = apositiontaking --a1
		, @Auto_SPositionTaking_Mem = autopositiontaking
		, @IsAuto_SPositionTaking_Mem = isautopositiontaking
		, @Old_MPositionTaking = mpositiontaking
		, @Old_Auto_MPositionTaking_Mem = autompositiontaking
		, @Old_IsAuto_MPositionTaking_Mem = isautompositiontaking
		, @m1_log = @m1  
	FROM @tmp_cs
	WHERE bettype = @BetType AND sporttype = @SportType


	--Check if old_PT = new_PT RETURN
	IF (@m1 = @Old_MPositionTaking
		AND	@um1 = @Old_Auto_MPositionTaking_Mem
		AND @im1 = @Old_IsAuto_MPositionTaking_Mem)
	BEGIN	
		SELECT @ErrCode = @ErrCode + '-103' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
		RETURN
	END
	
	INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, mpositiontaking, minpositiontaking)
	SELECT scs.custid, scs.sporttype, scs.bettype, scs.spositiontaking, scs.mpositiontaking, sco.minpositiontaking
	FROM CustSettingGame scs WITH(NOLOCK)
		INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON scs.custid = sco.custid AND scs.sporttype = sco.sporttype AND scs.bettype = sco.bettype
	WHERE scs.custid = @srecommend AND scs.sporttype = @sporttype and scs.bettype = @bettype

	INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, isautopositiontaking, autopositiontaking, minpositiontaking)
	SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, isautopositiontaking, autopositiontaking, minpositiontaking
	FROM  CustSettingGame mcs WITH(NOLOCK)
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mcs.custid = mco.custid AND mcs.sporttype = mco.sporttype AND mcs.bettype = mco.bettype
	WHERE mcs.custid = @mrecommend AND mcs.sporttype = @sporttype and mcs.bettype = @bettype

	INSERT INTO @tmp_ag(custid, sporttype, bettype, apositiontaking, isautompositiontaking, autompositiontaking, minpositiontaking)
	SELECT acs.custid, acs.sporttype, acs.bettype, apositiontaking, isautompositiontaking, autompositiontaking, minpositiontaking
	FROM CustSettingGame acs WITH(NOLOCK)
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON acs.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
	WHERE acs.custid = @recommend AND acs.sporttype = @sporttype and acs.bettype = @bettype

	--m3,u3,i3  
	SELECT @m3 = mpositiontaking, @u3 = autopositiontaking, @i3 = isautopositiontaking   
	FROM @tmp_mag
	WHERE custid = @mrecommend AND bettype=@bettype AND sporttype=@sporttype  

	IF (@UpdateAutoPositiontaking = 1)  
	BEGIN  
		 --Check um1<=min(m3,m4)  
		 SELECT @ErrType = ''  
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee  + '-Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10))  
		 FROM  
		  (  
		   SELECT @sporttype AS sporttype, @bettype AS bettype, @m3 AS maxmpositiontaking, @um1 AS autopositiontaking, @im1 AS isautopositiontaking    
		  ) AS b   
		 INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid  
		 WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking)  
		  
		 IF @ErrType <>''  
		 BEGIN  
			  SELECT @ErrCode_cur = 7,  
				  @ErrMsg_cur = @UserName + ': '+  
				   CASE @Language   
					WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
				   END      
				      
			  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			    
			  RETURN  
		 END  
	   
		 --Check um1>=Max(0, N3-A1)  
		 SELECT @ErrType = ''  
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
		  + '-Min: '+ CAST((case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end) AS VARCHAR(10))  
		 FROM @tmp_mag AS co INNER JOIN  
		  (  
		   SELECT @sporttype AS sporttype, @bettype AS bettype, @um1 AS autopositiontaking, @im1 AS isautopositiontaking, @APositionTaking as  apositiontaking  
		  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
		 INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid  
		 WHERE co.custid = @mrecommend AND   
		  (b.isautopositiontaking>0 AND b.autopositiontaking< case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end)  
		  
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
	  
	--n3  
	SELECT @n3 = minpositiontaking   
	FROM @tmp_mag
	WHERE custid = @mrecommend AND bettype=@bettype AND sporttype=@sporttype  
	   
	--m1_max = min(m3,m4), s4  
	SELECT @SPositionTaking_Max = spositiontaking,  
	  @m3 = case when @m3 > mpositiontaking then mpositiontaking   
		 else @m3 end    
	FROM @tmp_sag
	WHERE custid = @srecommend AND bettype=@bettype AND sporttype=@sporttype  
	    
	--um2, a2  
	SELECT   
	 @Auto_MPositionTaking = acs.autompositiontaking ,   
	 @APositionTaking_Max = acs.apositiontaking   
	FROM @tmp_ag acs 
	WHERE acs.custid = @recommend and acs.sporttype = @sporttype and bettype=@bettype   
	  
	IF @UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1  
	BEGIN   
		 --Check m1<= Max(0, MIN(M3,M4)-A1)  
		 SELECT @ErrType = ''  
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
		   + '-Max: '+ CAST((case when b.maxmpositiontaking - b.apositiontaking  < b.maxspositiontaking -spositiontaking - apositiontaking  
				 then (case when b.maxmpositiontaking - b.apositiontaking > 0 then b.maxmpositiontaking - b.apositiontaking else 0 end)  
				 else (case when b.maxspositiontaking -spositiontaking - apositiontaking > 0 then b.maxspositiontaking -spositiontaking - apositiontaking else 0 end)  
			  end ) AS VARCHAR(10))  
		 FROM (  
		   SELECT @sporttype AS sporttype, @bettype AS bettype ,        
			 @SPositionTaking AS spositiontaking, @m1 AS mpositiontaking, @APositionTaking AS apositiontaking,   
			 @m3 AS maxmpositiontaking, @SPositionTaking_Max AS maxspositiontaking  
		 )b    
		  INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype  
		  INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid  
		 WHERE @im1 = 0 and b.mpositiontaking > b.maxmpositiontaking - b.apositiontaking           
		  
		 IF @ErrType <>''  
		 BEGIN  
			  SELECT @ErrCode_cur = 8,  
				@ErrMsg_cur = @UserName + ': '+  
				   CASE @Language   
					WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
				   END    
				        
			  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			    
			  RETURN  
		 END  
   
		 --Check m1>=Max(0, N3-A1)  
		 SELECT @ErrType = ''  
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
		  + '-Min: '+ CAST((case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end) AS VARCHAR(10))  
		 FROM @tmp_mag AS co INNER JOIN  
		  (  
		   SELECT @sporttype AS sporttype, @bettype AS bettype, @m1 AS mpositiontaking, @im1 AS isautopositiontaking, @APositionTaking as  apositiontaking  
		  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
		 INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid  
		 WHERE co.custid = @mrecommend AND   
		  (b.isautopositiontaking=0 AND b.mpositiontaking< case when co.minpositiontaking - b.apositiontaking > 0 then co.minpositiontaking - b.apositiontaking else 0 end)  
		  
		 IF @ErrType <>''  
		 BEGIN  
			  SELECT @ErrCode_cur = 11,  
				  @ErrMsg_cur = CASE @Language   
					 WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'  
					 ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
				   END 
				    
			  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)          
			  RETURN  
		 END   
		   
		 --m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1  
		 SELECT   
		  @m1 = CASE WHEN @APositionTaking+@m1>@m3 THEN @m3-@APositionTaking ELSE @m1 END    
		  
		 --m1=m1+a1<n3?n3-a1:m1  
		 SELECT   
		  @m1 = CASE WHEN @APositionTaking+@m1<@n3 THEN @n3-@APositionTaking ELSE @m1 END    
		  
		 SELECT   
		  @m1 = CASE WHEN @m1<0 THEN 0 ELSE @m1 END  
		    
		  
		 --Must include code for auto master  
		 --um=im1>0?um1:um2  
		 --im=im1>0?im1:im2  
		 --m1=im>0?min(um,m3-a1):m1  
		 ----------------------------------------------------------------------------------------------------------------------------  
		 --auto master  
		  
		 --um=im1>0?um1:um2  
		 SELECT   
		  @Auto_MPositionTaking = CASE WHEN @im1>0 THEN @um1 ELSE @Auto_MPositionTaking END,   
		  --im=im1>0?im1:im31  
		  @im2 = CASE WHEN @im1>0 THEN @im1 ELSE @im2 END  
		 ---------------------------------------------------------------------------------------------------------------------------------------------  
		  
		 ----------------***Use Auto Position Taking***----------------------------------  
		 --m1=im>0?min(um,m3-a1):m1  
		 SELECT @m1 = CASE WHEN ISNULL(@im2, 0)<=0 THEN @m1 ELSE CASE WHEN @Auto_MPositionTaking < @m3 - @APositionTaking THEN @Auto_MPositionTaking ELSE @m3 - @APositionTaking END END  
		   
		 ---------------------------------------------------------------------------------------------------------------------------------------------  
		 --CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)  
		 SELECT   
		  @u3 = CASE WHEN @IsAuto_SPositionTaking_Mem>0 THEN @Auto_SPositionTaking_Mem ELSE @u3 END,    
		  @i3 = CASE WHEN @IsAuto_SPositionTaking_Mem>0 THEN @IsAuto_SPositionTaking_Mem ELSE @IsAuto_SPositionTaking END  
				    
		 ----------------***Use Auto Position Taking***----------------------------------  
		 SELECT @SPositionTaking = CASE WHEN ISNULL(@i3, 0)<=0 THEN @SPositionTaking ELSE CASE WHEN @u3 < @SPositionTaking_Max - @m1 - @APositionTaking THEN @u3 ELSE @SPositionTaking_Max - @m1 - @APositionTaking END END  
		   
		 -------------------------------------------------------------------------------  
		 --maxs1=isauto?s4:s4-m2  
		 SELECT @SPositionTaking_Max = CASE WHEN ISNULL(@i3, 0)>0 THEN @SPositionTaking_Max ELSE @SPositionTaking_Max-@m3 END  
		   
		 --s1=s1>maxs1?maxs1:s1  
		 SELECT @SPositionTaking = CASE WHEN @SPositionTaking > @SPositionTaking_Max THEN @SPositionTaking_Max ELSE @SPositionTaking END  
	END   
			  
	--don't update m1,s1 for member under agent was set im2=1  
	UPDATE cs
	SET mpositiontaking = @m1 ,  
		spositiontaking = @SPositionTaking  
	FROM @tmp_cs cs 
		INNER JOIN @tmp_ag acs ON cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype   
	WHERE acs.isautompositiontaking = 0   
	 AND cs.sporttype = @sporttype and cs.bettype = @bettype  
	
	--Update auto PT  
	--------------------------------------------------------  
	--Update Member account (autompositiontaking field)
	UPDATE cs
	SET autompositiontaking =  b.autompositiontaking ,   
		isautompositiontaking = b.isautompositiontaking    
	FROM @tmp_cs cs inner join   
	  (  
	   select @bettype as bettype, @sporttype as sporttype, @um1 as autompositiontaking, @im1 as isautompositiontaking   
	  ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype  
	 
	if @im2 >0  
	BEGIN  
		 update cs  
		 set mpositiontaking = case when @MaxPositionTaking - apositiontaking>@Auto_MPositionTaking then @Auto_MPositionTaking else @MaxPositionTaking - apositiontaking end  
		 from @tmp_cs as cs  
		 where custid = @custid and cs.bettype = @bettype and cs.sporttype = @sporttype  
		   
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
	END  
	--merge code correct pt 
	--check agent min/max
	--update a1=n2 when a1<n2
	Update cs 
	set cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
	from 
		@tmp_cs as cs 		
		inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.apositiontaking<aco.minpositiontaking
		and cs.sporttype = @sporttype
		and cs.bettype = @bettype
	
	--Recal AUTO MPT 
	--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
	---------------
	Update cs
		set mpositiontaking = 
			case when scs.mpositiontaking > mcs.mpositiontaking then 
				case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				else  mcs.mpositiontaking-cs.apositiontaking end
			else
				case when scs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				else  scs.mpositiontaking-cs.apositiontaking end
			end
	from
		@tmp_cs as cs 		
		inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join @tmp_sag as scs on scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
		inner join @tmp_ag as acs on acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
	where
		(acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	Update cs
		set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
	from 
		@tmp_cs as cs 		
		inner join @tmp_mag as mco on mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	----update m1,a1 when a1+m1>l3
	----update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	----update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	--Update cs
	--	set @maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
	--		@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
	--		mpositiontaking = @mpos,
	--		@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
	--		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	--from 
	--	@tmp_cs as cs 		
	--	inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype		
	--	inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	--where cs.apositiontaking+cs.mpositiontaking>mcs.maxpositiontaking
	--	and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	--recal autopos
	Update cs
		set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
								(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
	from
		@tmp_cs as cs 		
		inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join @tmp_sag as scs on scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	where (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	Update cs
		set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
	from 
		@tmp_cs as cs		
		inner join @tmp_sag as sco on sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
		
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)	
	--@mapos2=min(@mapos1,m3)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	Update cs
		set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
			spositiontaking = @spos,
			@mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,			
			@mapos2 = case when @mapos1 > mcs.mpositiontaking then mcs.mpositiontaking else @mapos1 end,
			@mapos = case when @mapos2<mcs.minpositiontaking then mcs.minpositiontaking else @mapos2 end,
			@mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
			mpositiontaking = @mpos,
			@apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
			apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		@tmp_cs as cs		
		inner join @tmp_sag as scs on scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
		inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype		
		inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
			
	UPDATE cs
	SET cs.spositiontaking = t.spositiontaking
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
		
	IF (@@error <> 0)  
	BEGIN    
		 SELECT @ErrMsg_Cur = CASE @Language   
			   WHEN 'E' THEN 'Update process is unsuccessful !'  
			   ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)  
			  END, @ErrCode_Cur = 304   
		   
		 SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
			 @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)    
		 RETURN  
	END   
	  
	-- get latest m1 to write log after correcting PT for auto  
	IF (@UpdateAutoPositiontaking=1 AND @im2=1 and @im1=0)  
	BEGIN  
		 select @m1_log = mpositiontaking     
		 from CustSettingGame with (NOLOCK)   
		 where custid = @custid and bettype=@bettype and sporttype=@sporttype 
	END 

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(5000)
	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MAg CustId="'+ COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1))
		+ '" ' + 'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1))
		+ '" ' + 'm1="' + COALESCE(CAST(@m1_log AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_BK="' + COALESCE(CAST(@IsAuto_MPositionTaking_BK AS VARCHAR(50)),SPACE(1))
		+ '" ' + 'im1="' + COALESCE(CAST(@im1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'um1="' + COALESCE(CAST(@um1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />' 

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_MAg CustId="'+ COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1))
		+ '" ' + 'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1))
		+ '" ' + 'm1="' + COALESCE(CAST(@Old_MPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_BK="' + COALESCE(CAST(@IsAuto_MPositionTaking_BK AS VARCHAR(50)),SPACE(1))
		+ '" ' + 'im1="' + COALESCE(CAST(@Old_IsAuto_MPositionTaking_Mem AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'um1="' + COALESCE(CAST(@Old_Auto_MPositionTaking_Mem AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />' 
	
	SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	--Log positiontaking
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 446
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MAg CustId="'+ COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1))
		+ '" ' + 'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1))
		+ '" ' + 'm1="' + COALESCE(CAST(@m1_log AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'IsAuto_MPositionTaking_BK="' + COALESCE(CAST(@IsAuto_MPositionTaking_BK AS VARCHAR(50)),SPACE(1))
		+ '" ' + 'im1="' + COALESCE(CAST(@im1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'um1="' + COALESCE(CAST(@um1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositionTaking="' + COALESCE(CAST(@UpdatePositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositionTaking="' + COALESCE(CAST(@UpdateAutoPositionTaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ ERROR_MESSAGE() + '" />'   

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 446
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH

END
