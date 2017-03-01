ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_SAg] 
	@CustID INT
	, @SportType TINYINT
	, @BetType INT
	, @s1 SMALLMONEY = 0 --s1
	, @us1 SMALLMONEY = 0 --us1
	, @is1 BIT = 0 -- is1
	, @is3 BIT = 0 -- is3  
	, @UpdatePositiontaking BIT = 0
	, @UpdateAutoPositiontaking BIT = 0

	, @SubAccID	INT = 0
	, @IP VARCHAR(50) = ''
	, @UserID INT = 0
	, @Language VARCHAR(20) = 'E'
	, @ErrCode VARCHAR(300) = '' OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT  
AS  
/*  
	Created: 20140318@Patrick  
	Task : Super edits Member (Keno)  
	DB: DBTXN/CustDB
	Original: Acc_CustomerUpdMemberVS_SAg  
	Revisions:  
		- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
		 
	Param's Explanation:  
	• @ErrCode:  
		<= 0: Update successfully.  
		> 0: Specific Error.  
	    
	• @ErrMsg: Error description.  
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

	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
	SELECT @startRun = GETDATE()

	DECLARE @ErrCode_cur INT, @ErrMsg_cur NVARCHAR(4000)
	DECLARE @mrecommend INT, @recommend INT, @srecommend INT, @ErrType VARCHAR(1000), @roleid TINYINT, @Username VARCHAR(50)
		, @SPositionTaking_Max SMALLMONEY, @MPositionTaking SMALLMONEY, @APositionTaking SMALLMONEY
		, @Old_SPositionTaking SMALLMONEY, @Old_IsAuto_SPositionTaking BIT, @Old_Auto_SPositionTaking SMALLMONEY 
	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney, @log_s1 smallmoney

	SELECT @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

	DECLARE @tmp_cs TABLE (custid INT, sporttype INT, bettype INT, 
				spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, apositiontaking SMALLMONEY, 
				isautopositiontaking BIT, isautompositiontaking BIT, autopositiontaking SMALLMONEY, autompositiontaking SMALLMONEY)	
	DECLARE @tmp_sag TABLE(custid INT, sporttype INT, bettype INT, spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	DECLARE @tmp_mag TABLE(custid INT, sporttype INT, bettype INT, mpositiontaking SMALLMONEY, isautopositiontaking BIT, autopositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)
	DECLARE @tmp_ag TABLE(custid INT, sporttype INT, bettype INT, isautompositiontaking BIT, autompositiontaking SMALLMONEY, minpositiontaking SMALLMONEY)

	--Check downline belongin
	EXEC dbo.Age_CustomerSelCheckBelonging   
		 @SessionCustID = @Userid
		 , @Custid = @custid
		 , @Username = @Username OUTPUT
		 , @roleid = @roleid OUTPUT
	IF (@roleid <> 1) RETURN-- RETURN IF not member  
  
	--Check disable user  
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid
			, @ErrCode = @ErrCode_Cur OUTPUT
			, @ErrMsg = @ErrMsg_Cur OUTPUT
	IF @ErrCode_Cur > 0  
	BEGIN
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
		RETURN
	END  
   
    IF (@UpdatePositiontaking = 0 AND @UpdateAutoPositiontaking = 0)
		RETURN

	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username   
	FROM dbo.customer WITH (NOLOCK) WHERE custid = @custid  
  
	SELECT @SPositionTaking_Max = spositiontaking --s4
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
	WHERE custid = @srecommend AND bettype = @BetType AND sporttype = @SportType

	INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking)
	SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype 

	SELECT @MPositionTaking = mpositiontaking, @APositionTaking = apositiontaking
		, @Old_SPositionTaking = spositiontaking, @Old_IsAuto_SPositionTaking = isautopositiontaking, @Old_Auto_SPositionTaking = autopositiontaking
	FROM @tmp_cs
	WHERE custid = @custid AND bettype = @BetType AND sporttype = @SportType

	SELECT @ErrType = ''  
	IF (@UpdatePositiontaking = 1)  
	BEGIN
		IF @s1 < 0
		BEGIN
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong position taking.' ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) END
				, @ErrCode_Cur = 100
			
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END

		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: ' + CAST(@SPositionTaking_Max AS VARCHAR(10)) 
		WHERE @s1 > @SPositionTaking_Max
		
		IF @ErrType <> ''
		BEGIN 
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong  position taking.<br>' + @ErrType
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
				, @ErrCode_Cur = 101
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN	
		END

		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + 'Max: ' + CAST(@SPositionTaking_Max - @MPositionTaking - @APositionTaking AS VARCHAR(10)) 
		WHERE @s1 + @MPositionTaking + @APositionTaking > @SPositionTaking_Max
	
		IF @ErrType <> ''
		BEGIN 
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong  position taking.<br>' + @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + '<br>' + @ErrType END
				, @ErrCode_Cur = 102
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END
	END
	IF @UpdateAutoPositiontaking = 1
	BEGIN
		IF @us1 < 0
		BEGIN
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong auto position taking.' ELSE [dbo].[f_Get_MsgNamebyMsgID](20009, @Language) END
				, @ErrCode_Cur = 100
			
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END

		SELECT @ErrType = ''
	
		SELECT @ErrType	= @ErrType + 'Max: ' + CAST(@SPositionTaking_Max AS VARCHAR(10)) 
		WHERE @us1 > @SPositionTaking_Max
	
		IF @ErrType <> ''
		BEGIN
			SELECT @ErrMsg_Cur = @UserName + ': '+ CASE @Language WHEN 'E' THEN 'Wrong auto position taking.<br>' + @ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009, @Language) + '<br>' + @ErrType END
				, @ErrCode_Cur = 201
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)			
			RETURN
		END
	END

	--Check Old_PT <> New_PT  
	select @APositionTaking = apositiontaking,   
	  @MPositionTaking = mpositiontaking,   
	  @Old_SPositionTaking = spositiontaking,      
	  @Old_Auto_SPositionTaking = autopositiontaking,   
	  @Old_IsAuto_SPositionTaking = isautopositiontaking, 
	  @log_s1 = @s1   
	from @tmp_cs
	where custid = @custid and bettype=@bettype and sporttype=@sporttype  
	  
	IF @s1 = @Old_SPositionTaking AND  
	 @us1 = @Old_Auto_SPositionTaking AND  
	 @is1 = @Old_IsAuto_SPositionTaking    
	BEGIN  
		 Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)  
		 return  
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

	INSERT INTO @tmp_ag(custid, sporttype, bettype, isautompositiontaking, autompositiontaking, minpositiontaking)
	SELECT acs.custid, acs.sporttype, acs.bettype, isautompositiontaking, autompositiontaking, minpositiontaking
	FROM CustSettingGame acs WITH(NOLOCK)
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON acs.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
	WHERE acs.custid = @recommend AND acs.sporttype = @sporttype and acs.bettype = @bettype

	SELECT @ErrType = ''  
  
	if (@UpdateAutoPositiontaking = 1)  
	BEGIN   
		 --Check us1<=s4  
		 select @ErrType = ''  
		 select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'  
		 from @tmp_sag as cs inner join  
		  (  
		   select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking      
		  ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype  
		 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid  
		 where cs.custid = @srecommend  
		  and   
		  ((cs.spositiontaking<b.autopositiontaking))  
		    
		 if @ErrType <>''  
		 BEGIN  
			  Select @ErrMsg_cur = @UserName + ': '+  
				   case @Language   
					when 'E' then 'Wrong auto position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
				   end , @ErrCode_cur = 103        
			  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			  return  
		 END  
	   
		 -- check us1>= Max(0, N4-M1-A1) when is1=1  
		 select @ErrType = @ErrType + sportname + '-'+ typenamee +   
		  '-Min: '+ cast((case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking >0 then co.minpositiontaking - b.mpositiontaking - b.apositiontaking else 0 end) as varchar(10)) + '<br>'  
		 from @tmp_sag as co inner join  
			 (  
				  select @sporttype as sporttype, @bettype as bettype,   
					  @us1 as autopositiontaking, @is1 as isautopositiontaking ,  
					  @APositionTaking as apositiontaking, @MPositionTaking as mpositiontaking  
			 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
		 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid  
		 where (b.isautopositiontaking>0 and b.autopositiontaking< case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking >0 then co.minpositiontaking - b.mpositiontaking - b.apositiontaking else 0 end)  
		
		 if @ErrType <>''  
		 BEGIN  
			  select @ErrCode_cur = 108  
			  
			  Select @ErrMsg_cur =  @UserName + ': '+  
			   case @Language   
					when 'E' then 'Wrong auto position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType  
				 end 
				  
			  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			  return  
		 END  
	END  
  
	if (@UpdatePositiontaking = 1)  
	BEGIN    
		 --Check s1<=Max(N4-M1-A1, S4-M3)  
		 select @ErrType = ''  
		 select @ErrType = @ErrType + sportname + '-'+ typenamee   
		   + '-Max: '+ cast((case when cs.minpositiontaking - b.mpositiontaking - b.apositiontaking > cs.spositiontaking - mcs.mpositiontaking  
				 then cs.minpositiontaking - b.mpositiontaking - b.apositiontaking  
				 else cs.spositiontaking - mcs.mpositiontaking  
			   end) as varchar(10)) + '<br>'  
		 from @tmp_sag as cs inner join    
		  (  
			   select @bettype as bettype, @sporttype as sporttype,   
				   @s1 as spositiontaking, @is1 as isautopositiontaking ,  
				   @APositionTaking as apositiontaking, @MPositionTaking as mpositiontaking     
		  ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype  		  
		  inner join @tmp_mag as mcs ON cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype  
		  INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype  
		  INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid  
		 where (b.spositiontaking> case when cs.minpositiontaking - b.mpositiontaking - b.apositiontaking > cs.spositiontaking - mcs.mpositiontaking  
				 then cs.minpositiontaking - b.mpositiontaking - b.apositiontaking  
				 else cs.spositiontaking - mcs.mpositiontaking  
				end  
		   )   
		    
		 if @ErrType <>''  
		 BEGIN  
			  Select @ErrMsg_cur = @UserName + ': '+  
				   case @Language   
					when 'E' then 'Wrong  position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
				   end, @ErrCode_cur = 104  
				   
			  Select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7) 
				 
			  return  
		 END  
	   
		 -- check s1>= Max(0, N4-M1-A1)   
		 select @ErrType = @ErrType + sportname + '-'+ typenamee +   
		  '-Min: '+ cast((case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking >0 then co.minpositiontaking - b.mpositiontaking - b.apositiontaking else 0 end) as varchar(10)) + '<br>'  
		 from @tmp_sag as co inner join  
		 (  
			  select @sporttype as sporttype, @bettype as bettype,   
				  @s1 as spositiontaking, @is1 as isautopositiontaking ,  
				  @APositionTaking as apositiontaking, @MPositionTaking as mpositiontaking  
		 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
		 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid  
		 where (b.isautopositiontaking=0 and b.spositiontaking< case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking >0 then co.minpositiontaking - b.mpositiontaking - b.apositiontaking else 0 end)  
		  
		 if @ErrType <>''  
		 BEGIN  
			  select @ErrCode_cur = 109  
			  
			  Select @ErrMsg_cur =  @UserName + ': '+  
			   case @Language   
					when 'E' then 'Wrong  position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
				 end  
				 
			  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			  return  
		 END  
		  
		 SELECT @s1 = CASE WHEN @MPositionTaking+@s1+@APositionTaking>@SPositionTaking_Max THEN @SPositionTaking_Max-@MPositionTaking-@APositionTaking else @s1 end  
		  
		 SELECT @s1 = CASE WHEN @s1<0 THEN 0 ELSE @s1 END  
	END  

	IF @UpdatePositiontaking = 1
	BEGIN
		--don't update s1 for member under master was set i3 = 1(normal)
		UPDATE cs
		SET cs.spositiontaking = @s1
		FROM @tmp_cs cs
			INNER JOIN @tmp_mag mcs ON mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		WHERE mcs.isautopositiontaking = 0
	END

	IF @UpdateAutoPositiontaking = 1
	BEGIN
		UPDATE cs
		SET	autopositiontaking = b.autopositiontaking,  
			isautopositiontaking = b.isautopositiontaking 
		FROM @tmp_cs cs INNER JOIN   
		   (  
			select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking, @is1 as isautopositiontaking     
		   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype  
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
	--SET mpositiontaking = case when mcs.mpositiontaking-cs.apositiontaking<0 then 0 else mcs.mpositiontaking-cs.apositiontaking end,
	--	@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
	--	apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
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

	--Call execrep
	/*
	EXEC dbo.Acc_CustSetting3rd_00_xtest
		@custid = @custid
		, @recommend = @recommend
		, @mrecommend = @mrecommend
		, @srecommend = @srecommend
		, @mode = 'Keno'
		, @sporttype = @SportType
		, @BetType = @BetType
	*/

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
		
	IF (@@ERROR <> 0)  
	BEGIN  
		SELECT @ErrMsg_Cur = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !' ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language) END 
			, @ErrCode_Cur = 105  
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7), @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)      
		RETURN
	END

	-- get latest s1 to write log after correcting PT for auto  
	IF (@UpdateAutoPositiontaking=1 AND @is3=1 and @is1=0)  
	BEGIN  
		 select @log_s1 = spositiontaking     
		 from CustSettingGame with (NOLOCK)   
		 where custid = @custid and bettype=@bettype and sporttype=@sporttype  
	END  

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(5000)
		
	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_SAg CustId = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1))
		+ '" ' + 'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1))
		+ '" ' + 's1 = "' + COALESCE(CAST(@log_s1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'is1 = "' + COALESCE(CAST(@is1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'us1 ="' + COALESCE(CAST(@us1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'is3 = "' + COALESCE(CAST(@is3 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositiontaking ="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositiontaking ="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_SAg CustId = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1))
		+ '" ' + 'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1))
		+ '" ' + 's1 = "' + COALESCE(CAST(@Old_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'is1 = "' + COALESCE(CAST(@Old_IsAuto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'us1 ="' + COALESCE(CAST(@Old_Auto_SPositionTaking AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'is3 = "' + COALESCE(CAST(@is3 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositiontaking ="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositiontaking ="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'
	

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND, @startRun, @endRun)
	--select * from DBLOG.bodb_CustomerLog.dbo.LogAction where actionid = 447
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 447
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_SAg CustId = "' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1))
		+ '" ' + 'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1))
		+ '" ' + 's1 = "' + COALESCE(CAST(@log_s1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'is1 = "' + COALESCE(CAST(@is1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'us1 ="' + COALESCE(CAST(@us1 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'is3 = "' + COALESCE(CAST(@is3 AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UpdatePositiontaking ="' + COALESCE(CAST(@UpdatePositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UpdateAutoPositiontaking ="' + COALESCE(CAST(@UpdateAutoPositiontaking AS VARCHAR(10)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ ERROR_MESSAGE() + '" />'   

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID
			, @CustID = @CustID
			, @ActionID = 447
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @TrackingValueDB
			, @duration = @duration
	END CATCH	
END
