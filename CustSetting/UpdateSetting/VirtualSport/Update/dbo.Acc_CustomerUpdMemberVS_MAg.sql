ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberVS_MAg]   
	 @CustID int,--memberid  
	 @sporttype tinyint,  
	 @bettype int,  
	    
	 @m1 smallmoney  = 0,   
	 @im2 bit = 0,    
	 @im1 bit = 0,    
	 @um1 SMALLMONEY = 0,    
	  
	 @UpdatePositiontaking BIT = 1,   
	 @UpdateAutoPositiontaking BIT = 1,  
	  
	 @UserID int,--masterid   
	 @Language varchar(2) = 'E',  
	 @SubAccID int = 0, --Sub-AccountID  
	 @IP varchar(15)='',  
	 @Username varchar(30) = '',  
	 @ErrCode varchar(300) = '' OUTPUT,  
	 @ErrMsg nvarchar(4000) = '' OUTPUT  
AS  
--@Source Control  
/*  
	Created: 20120813@Dan  
	Task : Master edit member(VS)  
	DB: DBTXN/bodb02  
	Original: [Acc_CustomerUpdMaster_Member]  
	  
	Revisions:  
	 - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language  
	 - 20121224@Scott : Fix bug 5441( get @m3 before checking)
	 - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	 - 20131108@Elodie: Splitting DBTXN into DBCUST (call sport, bettype by link database)			
	 - 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
	 - 20140320@Johnson: merge code correct pt [Redmine: #11562]
	 - 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
	Param's Explanation:  
	• @ErrCode:  
		= 0: Update successfully.  
		> 0: Specific Error.  
	    
	• @ErrMsg: Error description.  
*/  
  
SET NOCOUNT ON  
	  
	declare @startRun datetime  
	declare @endRun datetime  
	declare @duration int  
	set @startRun = getdate()  
	  
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

	Declare @ErrType varchar(1000), @roleid tinyint, @recommend INT, @mrecommend INT, @srecommend INT,  
			@ErrCode_cur int, @ErrMsg_cur nvarchar(4000)
	
	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney

	DECLARE @tmp_cs TABLE (custid INT, sporttype INT, bettype INT, 
				spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, apositiontaking SMALLMONEY, 
				isautopositiontaking BIT, isautompositiontaking BIT, autopositiontaking SMALLMONEY, autompositiontaking SMALLMONEY)	

	DECLARE @tmp_sag TABLE(custid INT, sporttype INT, bettype INT, spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, minpositiontaking SMALLMONEY, maxpositiontaking SMALLMONEY)
	DECLARE @tmp_mag TABLE(custid INT, sporttype INT, bettype INT, mpositiontaking SMALLMONEY, isautopositiontaking BIT, autopositiontaking SMALLMONEY, minpositiontaking SMALLMONEY, maxpositiontaking SMALLMONEY)
	DECLARE @tmp_ag TABLE(custid INT, sporttype INT, bettype INT, apositiontaking SMALLMONEY, isautompositiontaking BIT, autompositiontaking SMALLMONEY, minpositiontaking SMALLMONEY, maxpositiontaking SMALLMONEY)
	   
	Select @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''  
	  
	EXEC Age_CustomerSelCheckBelongingByCustID
		 @SessionCustID = @Userid,   
		 @username = @username output,  
		 @Custid = @custid,  
		 @roleid = @roleid OUTPUT  
	if (@roleid <> 1) return -- return if not member  
	  
	--Check disable user  
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output  
	IF @ErrCode_Cur > 0  
	BEGIN  
	 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
	   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
	 return  
	END  
	--end  
	  
	select @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend   
	from customer with (NOLOCK) where custid = @custid  
	
	INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking)
	SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking
	FROM CustSetting3rd WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype 
  
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	-- Check parameter  
	  
	declare @maxpos smallmoney  
	set @maxpos = 0.9  
	  
	if (@m1 <0  
	 or @m1 > @maxpos  
	 or @um1 <0   
	 or @um1 > @maxpos   
	 )   
	 AND (@UpdatePositiontaking = 1 or @UpdateAutoPositiontaking=1)  
	BEGIN  
		 select @ErrCode_cur = 5  
		 Select @ErrMsg_cur =  @UserName + ': ' +  
		  case @Language   
			  when 'E' then 'Wrong position taking.'  
			  ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)  
			end  
			
		 Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
		   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
		 RETURN  
	END  
	-- End check param  
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
    
	DECLARE    
		 @a1 SMALLMONEY,    
		 @a2 SMALLMONEY,    
		   
		 @old_m1 SMALLMONEY,     
		 @old_um1 SMALLMONEY,    
		 @old_im1 BIT,  
		 @m1_log SMALLMONEY,  
		   
		 @s4 SMALLMONEY,   
		   
		 @s1 SMALLMONEY,    
		 @u1 SMALLMONEY,   
		 @i1 BIT,  
		   
		 @m3 SMALLMONEY,   
		 @u3 SMALLMONEY,     
		 @i3 BIT,   
		 @n3 SMALLMONEY,  
		   
		 --um2  
		 @um2 SMALLMONEY,  
		   
		 ---- backup to write log  
		 @old_im2 bit  
  
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------  
	/*  
	if @srecommend>100 and @custid<>79711  
	BEGIN  
	 declare @ErrMsg varchar(200)  
	 Select @ErrMsg = 'Sorry, please try again later.'  
	 RaisError (@ErrMsg, 16, 1)  
	 return  
	END  
	*/  
  
	-- backup  
	SELECT @old_im2 = @im2  
	  
	--s1,a1,old_m1,u1,i1  
	SELECT @s1 = spositiontaking, @a1 = apositiontaking,   
		 @u1 = autopositiontaking, @i1 = isautopositiontaking,   
		 @old_m1 = mpositiontaking , @old_um1 = autompositiontaking ,   
		 @old_im1 = isautompositiontaking,  
		 @m1_log = @m1  
	FROM @tmp_cs	
	WHERE bettype = @bettype AND sporttype = @sporttype  
	  
	--Check if old_PT = new_PT return  
	IF @m1 = @old_m1 AND @um1 = @old_um1 AND @im1 = @old_im1   
	BEGIN   
	 SELECT @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)  
	 RETURN   
	END  
  	
	INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, mpositiontaking, minpositiontaking, maxpositiontaking)
	SELECT scs.custid, scs.sporttype, scs.bettype, scs.spositiontaking, scs.mpositiontaking, sco.minpositiontaking, sco.maxpositiontaking
	FROM CustSetting3rd scs WITH(NOLOCK)
		INNER JOIN CustOverride3rd sco WITH(NOLOCK) ON scs.custid = sco.custid AND scs.sporttype = sco.sporttype AND scs.bettype = sco.bettype
	WHERE scs.custid = @srecommend AND scs.sporttype = @sporttype and scs.bettype = @bettype

	INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, isautopositiontaking, autopositiontaking, minpositiontaking, maxpositiontaking)
	SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, isautopositiontaking, autopositiontaking, minpositiontaking, mco.maxpositiontaking
	FROM  CustSetting3rd mcs WITH(NOLOCK)
		INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mcs.custid = mco.custid AND mcs.sporttype = mco.sporttype AND mcs.bettype = mco.bettype
	WHERE mcs.custid = @mrecommend AND mcs.sporttype = @sporttype and mcs.bettype = @bettype

	INSERT INTO @tmp_ag(custid, sporttype, bettype, apositiontaking, isautompositiontaking, autompositiontaking, minpositiontaking,maxpositiontaking)
	SELECT acs.custid, acs.sporttype, acs.bettype, apositiontaking, isautompositiontaking, autompositiontaking, minpositiontaking,maxpositiontaking
	FROM CustSetting3rd acs WITH(NOLOCK)
		INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON acs.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
	WHERE acs.custid = @recommend AND acs.sporttype = @sporttype and acs.bettype = @bettype

	--m3,u3,i3  
	SELECT @m3 = mpositiontaking, @u3 = autopositiontaking, @i3 = isautopositiontaking   
	FROM @tmp_mag
	WHERE custid = @mrecommend AND bettype=@bettype AND sporttype=@sporttype  

	  
	IF (@UpdateAutoPositiontaking = 1)  
	BEGIN  
		 --Check um1<=l3  
		 SELECT @ErrType = ''  
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
		  + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))  
		 FROM @tmp_mag AS co INNER JOIN  
		  (  
				SELECT @sporttype AS sporttype, @bettype AS bettype, @um1 AS autopositiontaking, @im1 AS isautopositiontaking        
		  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
		 INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid  
		 WHERE co.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking)  
		  
		 IF @ErrType <>''  
		 BEGIN  
			  SELECT @ErrCode_cur = 6,  
				  @ErrMsg_cur = CASE @Language   
					 WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'  
					 ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
				   END  
				   
			  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)          
			  RETURN  
		 END   
	  
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
		   SELECT @sporttype AS sporttype, @bettype AS bettype, @um1 AS autopositiontaking, @im1 AS isautopositiontaking, @a1 as  apositiontaking  
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
	   
	--s4  
	SELECT @s4 = spositiontaking   
	FROM @tmp_sag
	WHERE custid = @srecommend AND bettype=@bettype AND sporttype=@sporttype  
	  
	--m1_max = min(m3,m4), s4  
	SELECT @s4 = spositiontaking,  
	  @m3 = case when @m3 > mpositiontaking then mpositiontaking   
		 else @m3 end    
	FROM @tmp_sag
	WHERE custid = @srecommend AND bettype=@bettype AND sporttype=@sporttype  
	    
	--um2, a2  
	SELECT   
	 @um2 = acs.autompositiontaking ,   
	 @a2 = acs.apositiontaking   
	FROM @tmp_ag acs 
	WHERE acs.custid = @recommend  
	  and acs.sporttype = @sporttype  
	  and bettype=@bettype   
	  
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
			 @s1 AS spositiontaking, @m1 AS mpositiontaking, @a1 AS apositiontaking,   
			 @m3 AS maxmpositiontaking, @s4 AS maxspositiontaking  
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
   
		 --Check m1<=l3  
		 SELECT @ErrType = ''  
		 SELECT @ErrType = @ErrType + sportname + '-'+ typenamee   
		  + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))  
		 FROM @tmp_mag AS co INNER JOIN  
		  (  
		   SELECT @sporttype AS sporttype ,  @sporttype AS bettype ,  @m1 AS mpositiontaking       
		  ) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype  
		  INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype  
		  INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid  
		 WHERE co.custid = @mrecommend AND (b.mpositiontaking>co.maxpositiontaking)   
		
		 IF @ErrType <>''  
		 BEGIN  
			  SELECT @ErrCode_cur = 9,  
				@ErrMsg_cur = @UserName + ': '+  
				  CASE @Language   
				   WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'  
				   ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'  
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
		   SELECT @sporttype AS sporttype, @bettype AS bettype, @m1 AS mpositiontaking, @im1 AS isautopositiontaking, @a1 as  apositiontaking  
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
		  @m1 = CASE WHEN @a1+@m1>@m3 THEN @m3-@a1 ELSE @m1 END    
		  
		 --m1=m1+a1<n3?n3-a1:m1  
		 SELECT   
		  @m1 = CASE WHEN @a1+@m1<@n3 THEN @n3-@a1 ELSE @m1 END    
		  
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
		  @um2 = CASE WHEN @im1>0 THEN @um1 ELSE @um2 END,   
		  --im=im1>0?im1:im31  
		  @im2 = CASE WHEN @im1>0 THEN @im1 ELSE @im2 END  
		 ---------------------------------------------------------------------------------------------------------------------------------------------  
		  
		 ----------------***Use Auto Position Taking***----------------------------------  
		 --m1=im>0?min(um,m3-a1):m1  
		 SELECT @m1 = CASE WHEN ISNULL(@im2, 0)<=0 THEN @m1 ELSE CASE WHEN @um2 < @m3 - @a1 THEN @um2 ELSE @m3 - @a1 END END  
		   
		 ---------------------------------------------------------------------------------------------------------------------------------------------  
		 --CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)  
		 SELECT   
		  @u3 = CASE WHEN @i1>0 THEN @u1 ELSE @u3 END,    
		  @i3 = CASE WHEN @i1>0 THEN @i1 ELSE @i3 END  
				    
		 ----------------***Use Auto Position Taking***----------------------------------  
		 SELECT @s1 = CASE WHEN ISNULL(@i3, 0)<=0 THEN @s1 ELSE CASE WHEN @u3 < @s4 - @m1 - @a1 THEN @u3 ELSE @s4 - @m1 - @a1 END END  
		   
		 -------------------------------------------------------------------------------  
		 --maxs1=isauto?s4:s4-m2  
		 SELECT @s4 = CASE WHEN ISNULL(@i3, 0)>0 THEN @s4 ELSE @s4-@m3 END  
		   
		 --s1=s1>maxs1?maxs1:s1  
		 SELECT @s1 = CASE WHEN @s1 > @s4 THEN @s4 ELSE @s1 END  
	END   
			  
	--don't update m1,s1 for member under agent was set im2=1  
	UPDATE cs
	SET mpositiontaking = @m1 ,  
		spositiontaking = @s1  
	FROM @tmp_cs cs 
		INNER JOIN @tmp_ag acs ON cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype   
	WHERE acs.isautompositiontaking = 0   
	 AND cs.sporttype = @sporttype and cs.bettype = @bettype  
	/*
	UPDATE cs WITH (ROWLOCK, UPDLOCK)  
	SET  
	 mpositiontaking = @m1 ,  
	 spositiontaking = @s1  
	FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid  
	 INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype   
	WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0   
	 AND cs.sporttype = @sporttype and cs.bettype = @bettype  
	*/  
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
	 
	/*
	update CustSetting3rd with (ROWLOCK, UPDLOCK)   
	set autompositiontaking =  b.autompositiontaking ,   
	 isautompositiontaking = b.isautompositiontaking    
	from CustSetting3rd as cs inner join   
	  (  
	   select @bettype as bettype, @sporttype as sporttype, @um1 as autompositiontaking, @im1 as isautompositiontaking   
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
	
	if @im2 >0  
	BEGIN  
		 select @maxpos = mpositiontaking from @tmp_mag
		 where custid = @mrecommend and sporttype=@sporttype and bettype = @bettype  
		   
		 update cs  
		 set mpositiontaking = case when @maxpos - apositiontaking>@um2 then @um2 else @maxpos - apositiontaking end  
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
	
	--update a1=l2 when a1>l2
	Update cs
	set apositiontaking = aco.maxpositiontaking
	from 
		@tmp_cs cs
		inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.sporttype = @sporttype and cs.apositiontaking>aco.maxpositiontaking
	
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
	
	--update m1,a1 when a1+m1>l3
	--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	Update cs
		set @maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
			@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
			mpositiontaking = @mpos,
			@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
			apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		@tmp_cs as cs 		
		inner join @tmp_mag as mcs on mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype		
		inner join @tmp_ag as aco on aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking>mcs.maxpositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
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
			
	/*
	EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'virtual-sports',
		@sporttype =  @sporttype,   
		@bettype = @bettype
	*/      

	UPDATE cs
	SET cs.spositiontaking = t.spositiontaking
		,cs.mpositiontaking = t.mpositiontaking
		,cs.apositiontaking = t.apositiontaking
		,cs.isautopositiontaking = t.isautopositiontaking
		,cs.isautompositiontaking = t.isautompositiontaking		
		,cs.autopositiontaking = t.autopositiontaking
		,cs.autompositiontaking = t.autompositiontaking
	FROM CustSetting3rd cs WITH(UPDLOCK,ROWLOCK)
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
		 from CustSetting3rd with (NOLOCK)   
		 where custid = @custid and bettype=@bettype and sporttype=@sporttype  
	END  
		  
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------  
	DECLARE @LogSPData VARCHAR(MAX),  
	  @TrackingValueDB VARCHAR(5000)  
	  
	Select @LogSPData = '<Acc_CustomerUpdMemberVS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
	  
	'm1="'+ coalesce(cast(@m1_log as varchar(50)),space(1)) + '" ' +  
	'im2="'+ coalesce(cast(@old_im2 as varchar(50)),SPACE(1)) + '" ' +  
	'im1="'+ coalesce(cast(@im1 as varchar(50)),SPACE(1)) + '" ' +  
	'um1="'+ coalesce(cast(@um1 as varchar(50)),SPACE(1)) + '" ' +  
	  
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
	  
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +  
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'   
	  
	Select @TrackingValueDB = '<Acc_CustomerUpdMemberVS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
	  
	'm1="'+ coalesce(cast(@old_m1 as varchar(50)),space(1)) + '" ' +  
	'im2="'+ coalesce(cast(@old_im2 as varchar(50)),SPACE(1)) + '" ' +  
	'im1="'+ coalesce(cast(@old_im1 as varchar(50)),SPACE(1)) + '" ' +  
	'um1="'+ coalesce(cast(@old_um1 as varchar(50)),SPACE(1)) + '" ' +  
	  
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
	  
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
		 @ActionID = 432,  
		 @TrackingValue = @LogSPData,  
		 @TrackingValue2 = @TrackingValueDB,  
		 @duration = @duration  
	END TRY
	BEGIN CATCH		
		Select @LogSPData = '<Acc_CustomerUpdMemberVS_MAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
		'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
		'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
		  
		'm1="'+ coalesce(cast(@m1_log as varchar(50)),space(1)) + '" ' +  
		'im2="'+ coalesce(cast(@old_im2 as varchar(50)),SPACE(1)) + '" ' +  
		'im1="'+ coalesce(cast(@im1 as varchar(50)),SPACE(1)) + '" ' +  
		'um1="'+ coalesce(cast(@um1 as varchar(50)),SPACE(1)) + '" ' +  
		  
		'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
		'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
		  
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +  
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'   
		 
		 EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
		 @UserID = @UserID,  
		 @CustID = @CustID,  
		 @ActionID = 432,  
		 @TrackingValue = @LogSPData,  
		 @TrackingValue2 = @TrackingValueDB,  
		 @duration = @duration 
	END CATCH  
	 
	Select @ErrCode = @ErrCode + '-101'+char(7), @ErrMsg = @ErrMsg + char(7)

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberVS_MAg] TO [vnteam] AS [dbo]