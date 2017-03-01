ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentVS_PositionTaking]        
	@custid      INT, --agentID        
	@sporttype     TINYINT,        
	@bettype     INT,        
	     
	@a2       SMALLMONEY,          
	@m2       SMALLMONEY,         
	@um2      SMALLMONEY = 0,          
	@im2      BIT = 0,         
	@n2       SMALLMONEY = 0,         
	     
	@updateallmembers   BIT = 0,--Use for auto PT         
	@m1       SMALLMONEY = 0,-- old param: @newmpositiontaking  --equals max(m+a) - chosen(a)        
	    
	@UpdatePositiontaking  BIT = 0,        
	@UpdateAutoPositiontaking BIT = 0,        
	     
	@UpdateMinPositiontaking BIT = 0,        
	    
	@SubAccID     INT = 0, --Sub-AccountID          
	@UserID      INT = 0,         
	@Language     VARCHAR(2) = 'E',        
	@IP       VARCHAR(15)='',        
	@ErrCode VARCHAR(300)  = '' OUTPUT,        
	@ErrMsg NVARCHAR(4000)  = '' OUTPUT        
AS        
--@Source Control        
/*        
Created: 20120808@Dan        
Task : Update VS's Agent Position Taking        
DB: DBTXN/bodb02        
Original: Acc_CustomerUpdAgent_AutoPositiontaking        
        
Revisions:        
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language        
	- 20130131@Scott: Fix bug (5291,5297)  
	- 20130131@Dan: fix bug - do not apply new m1 from popup when unchecking auto PT
	- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20131104@Johnson: apply execrep when update pt on agent
		and check total downlines before UPDATEs
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)						
	- 20131203@Johnson: Pass param @sporttype, @bettype when call sp Acc_CustSetting3rd_07 for agent			
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB, Use temp table for sports, bettype table)
	- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
Param's Explanation:        
• @ErrCode:        
    = 0: Update successfully.        
    > 0: Specific Error.        
          
• @ErrMsg: Error description.        
*/        
        
SET NOCOUNT ON        
        
DECLARE @startRun DATETIME        
DECLARE @endRun DATETIME        
DECLARE @duration INT        

----- Elodie @ 01 JUN 2015 -------------------
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
----- /Elodie @ 01 JUN 2015 -------------------
        
DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)  
DECLARE @roleid TINYINT      
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''        
        
SET @startRun = GETDATE()        
        
DECLARE @UserName nvarchar(20), @mrecommend int, @srecommend int, @maxpos smallmoney        
DECLARE @ErrAcc varchar(4000), @ErrType varchar(4000)        
SET @maxpos = 0.9 --max pt for VS        
        
--Check disable user        
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output        
IF @ErrCode_Cur > 0        
BEGIN        
 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
 return        
END        
--end 

---- Johnson@20131104: Checking total downlines before UPDATEs 
EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
	@roleid=2,
	@isExecRep=1,
	@isUpdatePT = 1,
	@Sporttype = 1,
	@Language='E',
	@ErrMsg=@ErrMsg_Cur output,
	@ErrCode=@ErrCode_Cur output
IF @ErrCode_Cur > 0        
BEGIN        
 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
 return        
END         
        
SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend  
		, @roleid = roleid
FROM custinfo with (NOLOCK)         
WHERE CustID = @CustID        

-- Only direct upline have update permission
IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
BEGIN
	SELECT @ErrMsg = 'You don''t have permission to perform this action.',
		   @ErrCode = 103	
	RETURN
END
        
DECLARE @old_a2 SMALLMONEY,        
  @old_m2 SMALLMONEY,          
  @old_um2 SMALLMONEY,        
  @old_im2 BIT,        
  @old_n2 SMALLMONEY,        
  @m3  SMALLMONEY         
        
-- get old values to check        
SELECT @old_m2 = mpositiontaking, @old_a2 = apositiontaking ,         
  @old_um2 = autompositiontaking, @old_im2 = isautompositiontaking         
FROM CustSetting3rd WITH (NOLOCK)         
WHERE custid = @custid and bettype=@bettype and sporttype=@sporttype        
        
SELECT @old_n2 = minpositiontaking        
FROM dbo.custOverride3rd WITH (NOLOCK)         
WHERE custid = @custid and bettype=@bettype and sporttype=@sporttype        
        
SELECT @m3 = mpositiontaking         
FROM CustSetting3rd WITH (NOLOCK)         
WHERE custid = @mrecommend and bettype=@bettype and sporttype=@sporttype          
      
       
--Update Min PT        
IF @UpdateMinPositiontaking = 1        
BEGIN        
 --check l3 >= n2        
 select @ErrAcc = ''        
 select top 100 @ErrAcc = @ErrAcc + username +', '        
 from         
  customer as c with (NOLOCK)         
  inner join CustOverride3rd as mco with (NOLOCK) on c.custid = mco.custid        
  inner join (        
    select  @sporttype as sporttype, @bettype as bettype, @n2 as minpositiontaking         
   ) as b on mco.sporttype=b.sporttype and mco.bettype = b.bettype        
 where        
  c.custid = (select mrecommend from customer with (NOLOCK) where custid = @custid) and c.roleid=3        
  and (mco.maxpositiontaking<b.minpositiontaking )        
 group by username        
         
 if @ErrAcc<>''        
 BEGIN          
  Select @ErrMsg_Cur =  case @Language         
       when 'E' then 'Master maximum position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'        
        ELSE [dbo].[f_Get_MsgNamebyMsgID](30006,@Language) + ' ('+@ErrAcc+').'        
     end,        
    @ErrCode_Cur = 112         
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)           
  return        
 END        
        
 --check a2 >= n2        
 IF @a2 < @n2        
 BEGIN          
  Select @ErrMsg_Cur =  case @Language         
       when 'E' then 'Current account position taking violates new minimum position taking setting ('+@UserName+').'        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@UserName+').'        
     end,        
    @ErrCode_cur = 113        
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return        
 END          
END        
        
-- check param          
IF (@UpdatePositiontaking = 1 OR @UpdateAutoPositiontaking = 1)        
BEGIN         
         
 IF (@a2  <0         
  or @m2 <0        
  or @m2 > @maxpos          
  or @a2 + @m2 > @maxpos)            
 BEGIN        
  SELECT @ErrCode_Cur = 100        
  SELECT @ErrMsg_Cur =  @UserName + ': '+        
   CASE @Language         
       WHEN 'E' THEN 'Wrong position taking.'        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)        
     END          
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END      
       
 --check m2 > m3      
     
 if (@m2 > @m3 and @im2 = 0)      
 begin      
       
 select @ErrType = ''        
 select @ErrType = @ErrType + s.sportname + ' - ' + typenamee         
  + '-Max: '+ cast( @m3 as varchar(10)) + '<br>'      
 FROM CustOverride3rd AS co WITH (NOLOCK) inner join        
  (        
    SELECT @bettype AS bettype, @sporttype AS sporttype, @a2 AS apositiontaking, @m2 AS mpositiontaking, @im2 AS isauto_mpositiontaking, @um2 AS auto_mpositiontaking            
  ) AS b on co.sporttype=b.sporttype and co.bettype = b.bettype        
  INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid        
  INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype        
 WHERE co.custid = @mrecommend      
           
 end      
       
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 103        
  Select @ErrMsg_Cur = @UserName + ': '+         
     case @Language         
       when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType        
     end        
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END      
         
--end check m2 > m3         
         
         
        
 --check n3<=m2+a2<=l3 if im2 = 0,         
 --a2<=l3 and um2+a2>=n3 if im2 = 1        
 SELECT @ErrType = ''        
 SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Min: '+ cast((co.minpositiontaking) AS VARCHAR(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'        
 FROM CustOverride3rd AS co WITH (NOLOCK) inner join        
  (        
    SELECT @bettype AS bettype, @sporttype AS sporttype, @a2 AS apositiontaking, @m2 AS mpositiontaking, @im2 AS isauto_mpositiontaking, @um2 AS auto_mpositiontaking            
  ) AS b on co.sporttype=b.sporttype and co.bettype = b.bettype        
  INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid        
  INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype        
 WHERE co.custid = @mrecommend and (         
      ((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or         
      (b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))        
     )        
 IF @ErrType <>''        
 BEGIN        
  SELECT @ErrCode_Cur = 101        
  SELECT @ErrMsg_Cur = @UserName + ': '+        
    CASE @Language         
       WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType        
    END        
  SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  RETURN          
 END        
        
 --n2<=a2<=l2        
 select @ErrType = ''        
 select @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
   + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'        
 from CustOverride3rd as co with (NOLOCK) inner join        
  (        
   select @bettype as bettype, @sporttype as sporttype, @a2 as apositiontaking, @m2 as mpositiontaking, @n2 as minmpositiontaking        
  ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype        
  INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
  INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype        
 where co.custid = @custid and (         
      (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<minmpositiontaking)        
     )        
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 102        
  Select @ErrMsg_Cur =  @UserName + ': '+        
     case @Language         
       when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType        
     end        
  IF @ErrCode_Cur > 0        
  BEGIN        
   select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
   return        
  END        
 END        
        
 --max(m2+a2)=min(m3,m4)        
 select @m3 = case when @m3 > mpositiontaking         
     then mpositiontaking else @m3 end         
 from custsetting3rd with (NOLOCK)         
 where custid = @srecommend and bettype=@bettype and sporttype=@sporttype        
         
 --check a2<= Min(A4, M3-M2) if im2 =0        
 --check a2<= Min(A4, M3) if im2 =1        
 select @ErrType = ''        
 select @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Max: '+ cast((      
     case when b.isauto_mpositiontaking=0        
      then (case when scs.apositiontaking<= @m3 - @m2 then scs.apositiontaking else @m3 - @m2 end)        
       else (case when scs.apositiontaking<= @m3 then scs.apositiontaking else @m3 end)        
      end) as varchar(10)) + '<br>'        
 from custinfo as c with (NOLOCK)          
  inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid         
  inner join           
  (        
   select @bettype as bettype, @sporttype as sporttype, @a2 as apositiontaking, @m2 as mpositiontaking, @im2 as isauto_mpositiontaking        
  ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype        
  INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
  INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype          
 where c.custid = @mrecommend and         
  (         
   ((b.isauto_mpositiontaking=0) and (b.apositiontaking > case when scs.apositiontaking<= @m3 - @m2 then scs.apositiontaking else @m3 - @m2 end)) or         
   (b.isauto_mpositiontaking>0 and (b.apositiontaking > case when scs.apositiontaking<= @m3 then scs.apositiontaking else @m3 end))        
  )         
         
         
         
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 103        
  Select @ErrMsg_Cur = @UserName + ': '+         
     case @Language         
       when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType        
     end        
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
     @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END          
         
 --check m2+a2<=min(m3,m4) - Vinh        
 SELECT @ErrType = ''        
 SELECT @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Max: '+ cast((b.max_mapositiontaking) as varchar(10)) + '<br>'        
 FROM        
  (     
   SELECT @bettype AS bettype, @sporttype AS sporttype, @a2 AS apositiontaking, @m2 AS mpositiontaking, @m3 AS max_mapositiontaking        
  ) AS b        
  INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid        
  INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype        
 WHERE (b.apositiontaking+b.mpositiontaking>b.max_mapositiontaking)         
        
 IF @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 104        
  Select @ErrMsg_Cur =  @UserName + ': '+        
       case @Language         
       when 'E' then 'Wrong position taking.<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
     end          
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END        
        
 --check u2<=min(m3,m4,l3) - Phuc@20081209        
 select @ErrType = ''        
 select @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Max: '+ cast((case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end) as varchar(10)) + '<br>'        
 from CustOverride3rd co (nolock) inner join         
 (        
  select @bettype as bettype, @sporttype as sporttype, @um2 as autopositiontaking, @im2 as isautopositiontaking, @m3 as max_mapositiontaking          
 ) as b on b.sporttype = co.sporttype and b.bettype = co.bettype        
 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype        
 where co.custid = @mrecommend and        
 (        
    ( b.isautopositiontaking = 1         
   and b.autopositiontaking > case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end        
    )         
 )        
        
        
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 105        
  Select @ErrMsg_Cur =  @UserName + ': '+        
       case @Language         
       when 'E' then 'Wrong position taking.<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType end          
          
 select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
  @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
         
  return      
        
 END         
         
 --check u2>= Max(0, N3-A4)        
 select @ErrType = ''        
 select @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Min: '+ cast((case when co.minpositiontaking - scs.apositiontaking > 0 then co.minpositiontaking - scs.apositiontaking else 0 end) as varchar(10)) + '<br>'        
 from CustOverride3rd co with (nolock)         
  inner join CustSetting3rd scs with (nolock) ON scs.custid=@srecommend and co.sporttype=scs.sporttype and co.bettype=scs.bettype        
  inner join         
 (        
  select @bettype as bettype, @sporttype as sporttype, @um2 as autopositiontaking, @im2 as isautopositiontaking, @m3 as max_mapositiontaking          
 ) as b on b.sporttype = co.sporttype and b.bettype = co.bettype        
 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype        
         
 where co.custid = @mrecommend and        
 (        
    ( b.isautopositiontaking = 1         
   and b.autopositiontaking < case when co.minpositiontaking - scs.apositiontaking > 0 then co.minpositiontaking - scs.apositiontaking else 0 end        
    )         
 )        
        
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 114        
  Select @ErrMsg_Cur =  @UserName + ': '+        
       case @Language         
       when 'E' then 'Wrong position taking.<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
     end          
          
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END        
         
 --check m2<=min(m3,m4,l3)         
 select @ErrType = ''        
 select @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Max: '+ cast((case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end) as varchar(10)) + '<br>'        
 from CustOverride3rd co (nolock) inner join         
 (        
  select @bettype as bettype, @sporttype as sporttype, @m2 as mpositiontaking, @im2 as isautopositiontaking, @m3 as max_mapositiontaking          
 ) as b on b.sporttype = co.sporttype and b.bettype = co.bettype        
 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype        
 where co.custid = @mrecommend and        
 (        
    ( b.isautopositiontaking = 0         
   and b.mpositiontaking > case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end        
    )         
 )        
        
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 115        
  Select @ErrMsg_Cur =  @UserName + ': '+        
       case @Language         
       when 'E' then 'Wrong position taking.<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
     end          
          
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END         
         
 --check m2>= Max(0, N3-A4)        
 select @ErrType = ''        
 select @ErrType = @ErrType + s.SportName + ' - ' + typenamee         
  + '-Min: '+ cast((case when co.minpositiontaking - scs.apositiontaking > 0 then co.minpositiontaking - scs.apositiontaking else 0 end) as varchar(10)) + '<br>'        
 from CustOverride3rd co with (nolock)         
  inner join CustSetting3rd scs with (nolock) ON scs.custid=@srecommend and co.sporttype=scs.sporttype and co.bettype=scs.bettype        
  inner join         
 (        
  select @bettype as bettype, @sporttype as sporttype, @m2 as mpositiontaking, @im2 as isautopositiontaking, @m3 as max_mapositiontaking          
 ) as b on b.sporttype = co.sporttype and b.bettype = co.bettype        
 INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
 INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype        
         
 where co.custid = @mrecommend and        
 (        
    ( b.isautopositiontaking = 0         
   and b.mpositiontaking < case when co.minpositiontaking - scs.apositiontaking > 0 then co.minpositiontaking - scs.apositiontaking else 0 end        
    )         
 )        
        
 if @ErrType <>''        
 BEGIN        
  select @ErrCode_Cur = 116        
  Select @ErrMsg_Cur =  @UserName + ': '+        
       case @Language         
       when 'E' then 'Wrong position taking.<br>'+@ErrType        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType        
     end          
          
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END        
END        
        
-- end check        
        
--Update Min PT        
IF @UpdateMinPositiontaking = 1        
BEGIN         
        EXEC Acc_CustOverrideUpdVS @custid = @custid, @sporttype = @sporttype, @bettype = @bettype, @positiontaking_min = @n2, @UpdateMinPos=1, @UpdateMaxPos = 0, @IP = @IP ,@UserID = @userid, @WriteLog = 0,@Language = @Language, @ErrCode = @ErrCode_Cur OUTPUT,
  
     
      
@ErrMsg = @ErrMsg_Cur OUTPUT        
         
 IF (@@error <> 0 or @ErrCode_Cur>0)        
 BEGIN        
  IF (@ErrCode_Cur = 0)         
  BEGIN        
   SELECT @ErrMsg_Cur = @UserName + ': '+        
       case @Language         
        when 'E' then 'Update process is unsuccessful !'        
        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)        
       end, @ErrCode_Cur = 110        
  END           
            
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END        
 ELSE        
  SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
END        
        
         
IF (@UpdatePositiontaking = 1)        
BEGIN        
 UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)        
 SET        
  apositiontaking = @a2,        
  mpositiontaking = @m2            
 WHERE custid=@custid and sporttype = @sporttype and bettype=@bettype        
         
 IF (@@error <> 0)        
 BEGIN          
  SELECT @ErrMsg_Cur = @UserName + ':' +         
      case @Language         
       when 'E' then 'Update process is unsuccessful !'        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)        
      end, @ErrCode_cur = 106        
                
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END         
END        
        
--Cal Auto Positiontaking for Master             
IF (@UpdateAutoPositiontaking = 1)         
BEGIN        
 --Update Master Agent account        
 UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)         
 SET autompositiontaking = b.autopositiontaking,         
  isautompositiontaking = b.isautopositiontaking         
 FROM CustSetting3rd as cs inner join         
   (        
    select @bettype as bettype, @sporttype as sporttype, @um2 as autopositiontaking, @im2 as isautopositiontaking        
   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype        
   INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid        
 WHERE cs.custid = @custid         
          
 if @@Error <> 0        
 BEGIN          
  SELECT @ErrMsg_Cur = @UserName + ': '+         
   case @Language         
    when 'E' then 'Error updating auto position taking'        
    ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)        
   end         
   ,  @ErrCode_Cur=107        
             
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END        
          
 ---------------------------------        
 if (@um2 <> @old_um2 or @im2 <> @old_im2 )        
 BEGIN        
	EXEC dbo.Acc_CustSetting3rd_05 
		@mrecommend = @mrecommend,
		@recommend = @custid,
		@roleid = 2,
		@mode = 'virtual-sports',
		
		@vs_sporttype = @sporttype,
		@vs_bettype = @bettype,
		
		@vs_mpositiontaking_max = @m3, --m3
		@vs_auto_mpositiontaking = @um2, --um2
		
		@vs_isauto_mpositiontaking = @im2, --im2
		@old_vs_isauto_mpositiontaking = @old_im2,--old_im2
		
		@updateautopositiontakingvs = 1,
		@updateallmembers = @updateallmembers,				
		@newmpositiontaking = @m1
 /*
  if @im2 >0 --Use AUTO MPT        
  BEGIN        
   --m1=min(m3-a1,u2)        
   SELECT @maxpos = mpositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend and sporttype=@sporttype and bettype = @bettype        
   UPDATE cs         
   SET mpositiontaking = case when @maxpos - apositiontaking>@um2 then @um2 else @maxpos -apositiontaking end        
   FROM CustSetting3rd AS cs WITH (ROWLOCK, UPDLOCK)        
    INNER JOIN custinfo AS c WITH (NOLOCK) on cs.custid = c.custid        
   WHERE c.recommend = @custid and c.roleid = 1 and cs.sporttype=@sporttype and cs.bettype = @bettype        
   if @@Error <> 0        
   BEGIN        
            
    SELECT @ErrMsg_Cur =  @UserName + ': '+        
      case @Language         
       when 'E' then 'Error updating auto position taking'        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)        
      end         
      ,  @ErrCode_Cur=108        
            
    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
      @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
    return            
   END        
  END        
  ELSE IF @im2 <> @old_im2 --Not use AUTO MPT        
  BEGIN        
   IF @updateallmembers = 1 --all member        
   BEGIN                  
    --m1=min(m3-a2,@m1)
    UPDATE cs             
    SET mpositiontaking = case when @m3 - acs.mpositiontaking < @m1 then @m3 - acs.mpositiontaking else @m1 end        
    FROM CustSetting3rd as cs with (ROWLOCK, UPDLOCK)         
     INNER JOIN custinfo as c with (NOLOCK) on cs.custid = c.custid        
     INNER JOIN CustSetting3rd as acs with (NOLOCK) on acs.custid = @custid and cs.sporttype=acs.sporttype and cs.bettype=acs.bettype        
    where c.recommend = @custid and c.roleid = 1 and cs.bettype = @bettype and cs.sporttype=@sporttype        
    if @@Error <> 0        
    BEGIN        
             
     SELECT @ErrMsg_Cur =  @UserName + ': '+        
      case @Language         
       when 'E' then 'Error updating auto position taking'        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)        
      end         
      ,  @ErrCode_Cur=108        
             
     select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
       @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
     return             
    END        
   END        
  END  */       
 END        
END        
      
IF @UpdatePositiontaking=1 AND @UpdateAutoPositiontaking = 0 AND        
 @Updateallmembers = 1 AND @im2=0        
BEGIN   
	EXEC dbo.Acc_CustSetting3rd_05 		
		@recommend = @custid,
		@roleid = 2,
		@mode = 'virtual-sports',
		
		@vs_sporttype = @sporttype,
		@vs_bettype = @bettype,
		
		@vs_isauto_mpositiontaking = @im2, --im2
		@old_vs_isauto_mpositiontaking = @old_im2,--old_im2
		
		@updateautopositiontakingvs = 0,						
		@newmpositiontaking = @m1          
/*
 UPDATE cs        
 SET mpositiontaking = b.mpositiontaking        
 FROM CustSetting3rd as cs with (ROWLOCK, UPDLOCK)        
  INNER JOIN custinfo ci(nolock) on cs.custid = ci.custid and ci.recommend = @custid and ci.roleid = 1        
  INNER JOIN         
   (        
    select @sporttype as sporttype, @bettype as bettype, @im2 as isautopositiontaking, @old_im2 as oldisautopositiontaking, @m1 as mpositiontaking        
   ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype        
 WHERE b.isautopositiontaking = 0 -- and b.oldisautopositiontaking = 0          
  and cs.isautompositiontaking = 0        
         
 IF (@@error <> 0)        
 BEGIN          
  SELECT @ErrMsg_Cur = CASE @Language         
        WHEN 'E' THEN 'Update process is unsuccessful !'        
        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)        
       END, @ErrCode_Cur = 111            
          
  SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),        
      @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)          
  RETURN            
 END  
 */      
END        
        
IF @UpdateAutoPositiontaking = 1 OR @UpdatePositiontaking =1         
BEGIN        

/* 
 EXEC dbo.Acc_CustomerUpdAgentVS_MaxPositiontaking @recommend = @custid        
 */
EXEC dbo.Acc_CustSetting3rd_07 @recommend = @custid, @roleid = 2, @mode = 'virtual-sports', @sporttype = @sporttype, @bettype = @bettype
 
 IF (@@error <> 0)        
 BEGIN          
  SELECT @ErrMsg_Cur = @UserName + ': '+        
      case @Language         
       when 'E' then 'Update process is unsuccessful !'        
       ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)              
      end, @ErrCode_cur = 109        
          
  select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),         
    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)        
  return          
 END        
 ELSE         
  SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
END        
        
        
DECLARE @LogSPData varchar(MAX),        
  @TrackingValueDB VARCHAR(4000)        
        
Select @LogSPData ='<Acc_CustomerUpdAgentVS_PositionTaking custid="'+ coalesce(cast(@custid as varchar(30)),space(1)) + '" ' +        
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +        
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +        
'a2="'+ coalesce(cast(@a2 as varchar(50)),space(1)) + '" ' +        
'm2="'+ coalesce(cast(@m2 as varchar(50)),space(1)) + '" ' +        
'um2="'+ coalesce(cast(@um2 as varchar(50)),space(1)) + '" ' +        
'im2="'+ coalesce(cast(@im2 as varchar(50)),space(1)) + '" ' +        
'n2="'+ coalesce(cast(@n2 as varchar(50)),space(1)) + '" ' +        
'Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +        
'm1="'+ coalesce(cast(@m1 as varchar(50)),space(1)) + '" ' +        
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +        
'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +        
'UpdateMinPositiontaking="'+ coalesce(cast(@UpdateMinPositiontaking as varchar(50)),space(1)) + '" ' +        
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +        
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +        
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +        
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +        
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +        
'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" ' +         
'/>'        
         
        
Select @TrackingValueDB ='<Acc_CustomerUpdAgentVS_PositionTaking custid="'+ coalesce(cast(@custid as varchar(30)),space(1)) + '" ' +        
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +        
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +        
'a2="'+ coalesce(cast(@old_a2 as varchar(50)),space(1)) + '" ' +        
'm2="'+ coalesce(cast(@old_m2 as varchar(50)),space(1)) + '" ' +        
'um2="'+ coalesce(cast(@old_um2 as varchar(50)),space(1)) + '" ' +        
'im2="'+ coalesce(cast(@old_im2 as varchar(50)),space(1)) + '" ' +        
'n2="'+ coalesce(cast(@old_n2 as varchar(50)),space(1)) + '" ' +        
'Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +        
'm1="'+ coalesce(cast(@m1 as varchar(50)),space(1)) + '" ' +        
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +        
'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +        
'UpdateMinPositiontaking="'+ coalesce(cast(@UpdateMinPositiontaking as varchar(50)),space(1)) + '" ' +        
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +        
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +        
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +        
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +        
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +        
'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" ' +        
'/>'        
        
set @endRun = getdate()        
set @duration  = datediff (millisecond,@startRun,@endRun)        
      
--Log positiontaking 
BEGIN TRY       
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP        
	 @UserID = @UserID,        
	 @CustID = @CustID,        
	 @ActionID = 431,        
	 @TrackingValue = @LogSPData,        
	 @TrackingValue2 = @TrackingValueDB,        
	 @duration = @duration 
END TRY
BEGIN CATCH
	Select @LogSPData ='<Acc_CustomerUpdAgentVS_PositionTaking custid="'+ coalesce(cast(@custid as varchar(30)),space(1)) + '" ' +        
	'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +        
	'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +        
	'a2="'+ coalesce(cast(@a2 as varchar(50)),space(1)) + '" ' +        
	'm2="'+ coalesce(cast(@m2 as varchar(50)),space(1)) + '" ' +        
	'um2="'+ coalesce(cast(@um2 as varchar(50)),space(1)) + '" ' +        
	'im2="'+ coalesce(cast(@im2 as varchar(50)),space(1)) + '" ' +        
	'n2="'+ coalesce(cast(@n2 as varchar(50)),space(1)) + '" ' +        
	'Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +        
	'm1="'+ coalesce(cast(@m1 as varchar(50)),space(1)) + '" ' +        
	'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +        
	'UpdateAutoPositiontaking="'+ coalesce(cast(@UpdateAutoPositiontaking as varchar(50)),space(1)) + '" ' +        
	'UpdateMinPositiontaking="'+ coalesce(cast(@UpdateMinPositiontaking as varchar(50)),space(1)) + '" ' +        
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +        
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +        
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +        
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +        
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +        
	'ErrMsg="'+ ERROR_MESSAGE() + '" ' +         
	'/>'     

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP        
	 @UserID = @UserID,        
	 @CustID = @CustID,        
	 @ActionID = 431,        
	 @TrackingValue = @LogSPData,        
	 @TrackingValue2 = @TrackingValueDB,        
	 @duration = @duration
END CATCH


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_PositionTaking] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_PositionTaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentVS_PositionTaking] TO [vnteam] AS [dbo]