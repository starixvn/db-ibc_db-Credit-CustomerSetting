USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_SAg]    Script Date: 06/09/2015 18:10:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberVS_SAg    Script Date: 4/23/2014 1:41:43 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberVS_SAg    Script Date: 4/16/2014 11:32:11 AM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberVS_SAg]   
	@CustID int,--memberid   
	@sporttype tinyint,  
	@bettype int,  

	@s1 smallmoney = 0,   
	@us1 smallmoney = 0,   
	@is1 bit = 0,   
	@is3 bit = 0,--i3  

	@UpdatePositiontaking BIT = 0,   
	@UpdateAutoPositiontaking BIT = 0,  
	 
	@UserID int,  
	@language varchar(2) = 'E',  
	@SubAccID int = 0, --Sub-AccountID  
	@IP varchar(15)='',  
	@Username varchar(30) = '',  
	@ErrCode varchar(300) = '' OUTPUT,  
	@ErrMsg nvarchar(4000) = '' OUTPUT  
AS  
--@Source Control  
/*  
	Created: 20120820@Dan  
	Task : Super edits Member(VS)  
	DB: DBTXN/bodb02  
	Original: Acc_CustomerUpdSuper_Member  
	  
	Revisions:  
		 - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language  
		 - 20130130@Scott : Fix bug 5325
		 - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
		 - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)			
		 - 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
		 - 20140318@Johnson: merge code correct pt [Redmine: #11562]
		 - 20150609@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID, temp sport, bettype table) [Redmine:#36216]
		 
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
	  
	Declare @ErrCode_cur int, @ErrMsg_cur nvarchar(4000), @roleid tinyint 
	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney

	
	DECLARE @tmp_cs TABLE (custid INT, sporttype INT, bettype INT, 
				spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, apositiontaking SMALLMONEY, 
				isautopositiontaking BIT, isautompositiontaking BIT, autopositiontaking SMALLMONEY, autompositiontaking SMALLMONEY)	

	DECLARE @tmp_sag TABLE(custid INT, sporttype INT, bettype INT, spositiontaking SMALLMONEY, mpositiontaking SMALLMONEY, minpositiontaking SMALLMONEY, maxpositiontaking SMALLMONEY)
	DECLARE @tmp_mag TABLE(custid INT, sporttype INT, bettype INT, mpositiontaking SMALLMONEY, isautopositiontaking BIT, autopositiontaking SMALLMONEY, minpositiontaking SMALLMONEY, maxpositiontaking SMALLMONEY)
	DECLARE @tmp_ag TABLE(custid INT, sporttype INT, bettype INT, isautompositiontaking BIT, autompositiontaking SMALLMONEY, minpositiontaking SMALLMONEY, maxpositiontaking SMALLMONEY)
	 
	Select @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''  
	  
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
	
	EXEC dbo.Age_CustomerSelCheckBelonging   
		 @SessionCustID = @Userid,   
		 @Custid = @custid,  
		 @Username = @Username OUTPUT,  
		 @roleid = @roleid OUTPUT  
		 if (@roleid <> 1) return-- return if not member  
	  
	--Check disable user  
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output  
	IF @ErrCode_Cur > 0  
	BEGIN  
		 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
		   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
		 return  
	END  
	--end   
	declare   
		 @m1 smallmoney,  
		 @old_s1 smallmoney,  
		 @log_s1 smallmoney,  
		   
		 @mrecommend int,  
		 @recommend int,  
		 @srecommend int,  
		  
		 @a1 smallmoney,   
		 @s1_max smallmoney,   
		 @old_us1 smallmoney ,   
		 @old_is1 bit  
   
	declare @ErrType varchar(1000), @maxpos smallmoney  
	  
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username   
	FROM customer WITH (NOLOCK)   
	WHERE custid = @custid  
	
	INSERT INTO @tmp_cs(custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking)
	SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, isautopositiontaking, isautompositiontaking, autopositiontaking, autompositiontaking
	FROM CustSetting3rd WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype 
  
	SET @maxpos = 0.9   
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
	-- Check param  
	declare @IsValid bit  
	Select @isvalid = 1  
  
	if  (@UpdatePositiontaking = 0 AND @UpdateAutoPositiontaking = 0 )  
		RETURN;  
  
	if  (@s1 <0  
	 or @s1 > @maxpos  
	 or @us1 <0   
	 or @us1 > @maxpos   
	 )  
	  
	BEGIN  
		 select @isvalid = 0, @ErrCode_cur = 101 
		  
		 Select @ErrMsg_cur =  @UserName + ': '+  
		  case @Language   
			  when 'E' then 'Wrong position taking.'  
			  ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)  
			end 
			 
		 SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
		   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)    
		 RETURN  
	END   
  
	--Check Old_PT <> New_PT  
	select @a1 = apositiontaking,   
	  @m1 = mpositiontaking,   
	  @old_s1 = spositiontaking,      
	  @old_us1 = autopositiontaking,   
	  @old_is1 = isautopositiontaking, 
	  @log_s1 = @s1   
	from @tmp_cs
	where custid = @custid and bettype=@bettype and sporttype=@sporttype  
	  
	IF @s1 = @old_s1 AND  
	 @us1 = @old_us1 AND  
	 @is1 = @old_is1    
	BEGIN  
		 Select @ErrCode = @ErrCode + '-103'+char(7), @ErrMsg = @ErrMsg + char(7)  
		 return  
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

	INSERT INTO @tmp_ag(custid, sporttype, bettype, isautompositiontaking, autompositiontaking, minpositiontaking,maxpositiontaking)
	SELECT acs.custid, acs.sporttype, acs.bettype, isautompositiontaking, autompositiontaking, minpositiontaking,maxpositiontaking
	FROM CustSetting3rd acs WITH(NOLOCK)
		INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON acs.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
	WHERE acs.custid = @recommend AND acs.sporttype = @sporttype and acs.bettype = @bettype

	SELECT @ErrType = ''  
  
	if (@UpdateAutoPositiontaking = 1)  
	BEGIN   
		 -- check us1<=l4 when is1=1  
		 select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ convert(varchar(20),co.maxpositiontaking )
		 from @tmp_sag as co inner join  
		 (  
		  select @sporttype as sporttype, @bettype as bettype, @us1 as autopositiontaking, @is1 as isautopositiontaking   
		 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
		 INNER JOIN @tmp_sports s  on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid  
		 where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking))  
		  
		  
		 if @ErrType <>''  
		 BEGIN  
			  select @isvalid = 0, @ErrCode_cur = 102  
			  
			  Select @ErrMsg_cur =  @UserName + ': '+  
			   case @Language   
					when 'E' then 'Wrong position taking (min/max set by company)<br>'+@ErrType
						   ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' +@ErrType
						 end  
				 
			  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			  return  
		END  
		 -- End check parameter  
		 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
		    
		 --Check us1<=s4  
		 select @ErrType = ''  
		 select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'  
		 from @tmp_sag as cs inner join  
		  (  
		   select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking      
		  ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype  
		 INNER JOIN  @tmp_sports s on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid  
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
					  @a1 as apositiontaking, @m1 as mpositiontaking  
			 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
		 INNER JOIN @tmp_sports s on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid  
		 where (b.isautopositiontaking>0 and b.autopositiontaking< case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking >0 then co.minpositiontaking - b.mpositiontaking - b.apositiontaking else 0 end)  
		  
		 if @ErrType <>''  
		 BEGIN  
			  select @isvalid = 0, @ErrCode_cur = 108  
			  
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
				   @a1 as apositiontaking, @m1 as mpositiontaking     
		  ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype  		  
		  inner join @tmp_mag as mcs ON cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype  
		  INNER JOIN @tmp_sports s  on b.sporttype = s.sporttype  
		  INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid  
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
				  @a1 as apositiontaking, @m1 as mpositiontaking  
		 ) as b on co.sporttype=b.sporttype and co.bettype=b.bettype  
		 INNER JOIN @tmp_sports s on b.sporttype = s.sporttype  
		 INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid  
		 where (b.isautopositiontaking=0 and b.spositiontaking< case when co.minpositiontaking - b.mpositiontaking - b.apositiontaking >0 then co.minpositiontaking - b.mpositiontaking - b.apositiontaking else 0 end)  
		  
		 if @ErrType <>''  
		 BEGIN  
			  select @isvalid = 0, @ErrCode_cur = 109  
			  
			  Select @ErrMsg_cur =  @UserName + ': '+  
			   case @Language   
					when 'E' then 'Wrong  position taking.<br>'+@ErrType  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType  
				 end  
				 
			  Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			  return  
		 END  
  
		 SELECT @s1_max = spositiontaking   
		 FROM @tmp_sag
		 WHERE custid = @srecommend and bettype=@bettype and sporttype=@sporttype  
		  
		 SELECT @s1 = CASE WHEN @m1+@s1+@a1>@s1_max THEN @s1_max-@m1-@a1 else @s1 end  
		  
		 SELECT @s1 = CASE WHEN @s1<0 THEN 0 ELSE @s1 END  
	END  
  
	IF @UpdatePositiontaking = 1  
	BEGIN  
		 --don't update s1 for member under master was set i3=1(normal) 
		 UPDATE cs
		 SET cs.spositiontaking = @s1  
		 FROM @tmp_cs cs
			INNER JOIN @tmp_mag mcs ON  cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype  
		 WHERE mcs.isautopositiontaking = 0
		 /* 
		 UPDATE cs WITH (ROWLOCK, UPDLOCK)  
		 SET  
		  cs.spositiontaking = @s1    
		 FROM CustSetting3rd cs  inner join customer c (NOLOCK) ON cs.custid = c.custid  
		  inner join CustSetting3rd scs (NOLOCK) ON scs.custid = c.mrecommend and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype  
		 WHERE cs.custid=@custid and   
		  cs.sporttype = @sporttype and c.roleid = 1 and scs.isautopositiontaking = 0  
		   
		 IF (@@error <> 0)  
		 BEGIN  
		  SELECT @ErrMsg_Cur = CASE @Language   
				WHEN 'E' THEN 'Update process is unsuccessful !'  
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)  
			   END , @ErrCode_Cur = 105  
		              
		  SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
		   @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)      
		  RETURN  
		 END  
		 */
	END  
  
	--Update auto PT  
	IF @UpdateAutoPositiontaking = 1  
	BEGIN  
		UPDATE cs
		SET	autopositiontaking = b.autopositiontaking,  
			isautopositiontaking = b.isautopositiontaking 
		FROM @tmp_cs cs INNER JOIN   
		   (  
			select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking, @is1 as isautopositiontaking     
		   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype  
		 
		/*
		 UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)   
		 SET autopositiontaking = b.autopositiontaking,  
		  isautopositiontaking = b.isautopositiontaking   
		 FROM CustSetting3rd as CS INNER JOIN   
		   (  
			select @bettype as bettype, @sporttype as sporttype, @us1 as autopositiontaking, @is1 as isautopositiontaking     
		   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype  
		 WHERE cs.custid = @custid  
		  
		 if @@Error <> 0  
		 BEGIN  
			  SELECT @ErrMsg_cur =  @UserName + ': '+  
			  case @Language   
			   when 'E' then 'Error updating auto position taking'  
			   ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)     
			  end, @ErrCode_cur = 106  
			  
			  SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),   
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)  
			  return  
		 END  
		*/
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
			  END, @ErrCode_Cur = 107   
		   
		 SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
			 @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)    
		 RETURN  
	END   
	  
	-- get latest s1 to write log after correcting PT for auto  
	IF (@UpdateAutoPositiontaking=1 AND @is3=1 and @is1=0)  
	BEGIN  
		 select @log_s1 = spositiontaking     
		 from CustSetting3rd with (NOLOCK)   
		 where custid = @custid and bettype=@bettype and sporttype=@sporttype  
	END  
	  
	Declare @LogSPData varchar(MAX),  
	  @TrackingValueDB varchar(5000)  
	  
	Select @LogSPData = '<Acc_CustomerUpdMemberVS_SAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
	's1="'+ coalesce(cast(@log_s1 as varchar(50)),space(1)) + '" ' +  
	'us1="'+ coalesce(cast(@us1 as varchar(50)),SPACE(1)) + '" ' +  
	'is1="'+ coalesce(cast(@is1 as varchar(50)),SPACE(1)) + '" ' +  
	'is3="'+ coalesce(cast(@is3 as varchar(50)),SPACE(1)) + '" ' +  
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +  
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'   
	  
	Select @TrackingValueDB = '<Acc_CustomerUpdMemberVS_SAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
	's1="'+ coalesce(cast(@old_s1 as varchar(50)),space(1)) + '" ' +  
	'us1="'+ coalesce(cast(@old_us1 as varchar(50)),SPACE(1)) + '" ' +  
	'is1="'+ coalesce(cast(@old_is1 as varchar(50)),SPACE(1)) + '" ' +  
	'is3="'+ coalesce(cast(@is3 as varchar(50)),SPACE(1)) + '" ' +  
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +  
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
		 @ActionID = 435,  
		 @TrackingValue = @LogSPData,  
		 @TrackingValue2 = @TrackingValueDB,  
		 @duration = @duration  
	END TRY
	BEGIN CATCH	 
		Select @LogSPData = '<Acc_CustomerUpdMemberVS_SAg custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +  
		'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +  
		'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
		's1="'+ coalesce(cast(@log_s1 as varchar(50)),space(1)) + '" ' +  
		'us1="'+ coalesce(cast(@us1 as varchar(50)),SPACE(1)) + '" ' +  
		'is1="'+ coalesce(cast(@is1 as varchar(50)),SPACE(1)) + '" ' +  
		'is3="'+ coalesce(cast(@is3 as varchar(50)),SPACE(1)) + '" ' +  
		'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +  
		'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +  
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +  
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +  
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +  
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'   
		 
		 EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP   
		 @UserID = @UserID,  
		 @CustID = @CustID,  
		 @ActionID = 435,  
		 @TrackingValue = @LogSPData,  
		 @TrackingValue2 = @TrackingValueDB,  
		 @duration = @duration   
	END CATCH
		
	Select @ErrCode = @ErrCode + '-101'+char(7), @ErrMsg = @ErrMsg + char(7)

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberVS_SAg] TO [vnteam] AS [dbo]