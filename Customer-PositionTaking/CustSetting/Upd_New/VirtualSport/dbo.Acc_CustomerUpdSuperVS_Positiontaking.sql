USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperVS_Positiontaking]    Script Date: 06/10/2015 16:12:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperVS_Positiontaking    Script Date: 8/28/2014 2:05:05 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperVS_Positiontaking    Script Date: 8/21/2014 3:12:18 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperVS_Positiontaking    Script Date: 8/21/2014 2:58:06 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperVS_Positiontaking]
    @custid int,-- superid    
    @sporttype tinyint,
    @bettype int,
    
    @s4 smallmoney = 0,
    @m4 smallmoney = 0,
    @a4 smallmoney = 0,
    @n4 smallmoney = 0,    
        
    @UpdatePositiontaking    bit = 0,
    @UpdateMinPositiontaking    BIT = 0,
    
    @UserID int = 0,    
    @Language varchar(2) = 'E',
    @IP varchar(15)='',
    @ErrCode VARCHAR(300)  = '' OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
--@Source Control
/*
    Created: 20120802@Dan
    Task : Update VS's Super PT 
    DB: DBCUST/bodb02

    Revisions:
        - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
        - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
        - 20131101@Johnson: Apply execrep when correct pt on members
                        and check total downlines before UPDATEs
        - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
        - 20140725@Logan: 1. Exclude disabled accounts while updating SM's seting [Redmine: #19631]
                          2. Code aligning for modified parts
		- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, temp sport, bettype table) [Redmine:#36216]                          
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]

    Param's Explanation:
    • @ErrCode:
        = 0: Transaction recorded successfully.
        > 0: Specific Error.
      
    • @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

DECLARE @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000)
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
            @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
    return
END
--end

---- Johnson@20131104: Checking total downlines before UPDATEs 
EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
    @roleid=4,
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
    
Declare @username varchar(40)
select @username = username from custinfo with (NOLOCK) where custid = @custid

            
-- Only direct upline have update permission
IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,4,@userid))
BEGIN
	SELECT @ErrMsg = 'You don''t have permission to perform this action.',
		   @ErrCode = 103	
	RETURN
END


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
	
DECLARE @s4_old smallmoney,
    @m4_old smallmoney ,
    @a4_old smallmoney,
    @n4_old smallmoney
            
SELECT @s4_old = spositiontaking,            
        @m4_old = mpositiontaking,                
        @a4_old = apositiontaking        
FROM custsetting3rd with(nolock)
WHERE custid = @custid and sporttype = @sporttype and bettype=@bettype 

select @n4_old = minpositiontaking
from CustOverride3rd with (NOLOCK) 
where custid = @custid and sporttype=@sporttype and bettype = @bettype

--Update Min PT
IF @UpdateMinPositiontaking = 1
BEGIN
    --check n4<=s4
    IF @s4 < @n4
    BEGIN 
        Select @ErrMsg_Cur = 
                    case @Language 
                            when 'E' then 'Wrong position taking.<br>'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
                    end, @ErrCode_Cur = 100
                    
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return    
    END
END    
    
IF @UpdatePositiontaking=1
BEGIN
    --------------------------------------------------------------------------------------------
    --Check Param
    Declare @ErrAcc nvarchar(4000)
    declare @ErrType varchar(1000)

    if     @s4 < 0    
        or @m4 < 0    
        or @a4 < 0
        
        or @s4 > 0.9    
        or @m4 > 0.9
        or @a4 > 0.9
            
        or @s4 < @m4        
        or @m4 < @a4    
    BEGIN
        
        SELECT @ErrMsg_Cur = @username + ': ' +
                    CASE @Language 
                            WHEN 'E' THEN 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    END, @ErrCode_Cur = 101
        
        
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return            
    END

    IF @UpdateMinPositiontaking = 0
    BEGIN
        --check n4<=s4
        select @ErrType = ''
        select @ErrType = @ErrType + s.SportName + ' - ' + typenamee +     '-Min: '+ cast((co.minpositiontaking) as varchar(10)) + '<br>'
        from CustOverride3rd as co with (NOLOCK) 
        inner join
            (
                select @bettype as bettype, @sporttype as sporttype, @s4 as spositiontaking
            ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
            INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid
            INNER JOIN @tmp_sports s  on co.sporttype = s.sporttype
        where co.custid = @custid and (b.spositiontaking<co.minpositiontaking) 

        if @ErrType <>''
        BEGIN
            Select @ErrMsg_Cur = @username + ': ' +
                        case @Language 
                                when 'E' then 'Wrong position taking (min set by company).<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20006,@Language) + '<br>' + @ErrType
                        end, @ErrCode_cur = 102
                    
            select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                    @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
            return        
        END
    END

    --check all s3+m3<=s4 if i3 = 0,
    --m3<=s4 and u3<=s4 if i3=1
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        custinfo as c with (NOLOCK) 
        inner join CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
                select     @sporttype as sporttype, @bettype as bettype, @s4 as maxpositiontaking        
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.srecommend = @custid and c.roleid = 3 and (
                            ((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) 
                        )
    group by username
    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg_Cur = @username + ': ' +
                    case @Language 
                            when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
                    end, @ErrCode_cur = 103
        
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return        
    END
    --check all s1+m1+a1 <= s4
    --check all u1<=s4 if i1=1
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT @sporttype AS sporttype
                 , @bettype AS bettype
                 , @s4 AS maxpositiontaking
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.spositiontaking+cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking
            OR (cs.isautopositiontaking = 1
                and cs.autopositiontaking > b.maxpositiontaking
               )  
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg_Cur = @username + ': '
                           + CASE @Language 
                               WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
                               ELSE [dbo].[f_Get_MsgNamebyMsgID](20014, @Language) + ' (' + @ErrAcc + ').'
                             END
             , @ErrCode_Cur = 104
        
        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
             , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

        RETURN
    END
    
    --------------------------------------------------------------------------------------------
    --Check all m3<=m4
    --VS
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        custinfo as c with (NOLOCK) 
        inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
                select     @sporttype as sporttype, @bettype as bettype, @m4 as maxpositiontaking
                ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.srecommend = @custid and c.roleid = 3 and 
                (cs.mpositiontaking > b.maxpositiontaking)                
    group by username

    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg =     @UserName + ': '+
            case @Language 
                            when 'E' then 'Existing masters exceeded new master position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20015,@Language) + ' ('+@ErrAcc+').'
                    end, @ErrCode = 108
        return
    END

    --------------------------------------------------------------------------------------------
    --Check all m1+a1<=m4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT @sporttype AS sporttype
                 , @bettype AS bettype
                 , @m4 AS maxpositiontaking
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.mpositiontaking + cs.apositiontaking > b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg_Cur = @username + ': '
                           + CASE @Language 
                               WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                               ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                             END
             , @ErrCode_Cur = 105

        SELECT @ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
             , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

        RETURN
    END
    -------------------------------------------------------------------------------------------------------------------
    --Check all a2<=a4
    --VS
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT @sporttype AS sporttype
                 , @bettype AS bettype
                 , @a4 AS maxpositiontaking                  
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 2
       AND c.Enabled    = 1
       AND cs.apositiontaking > b.maxpositiontaking                                
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @UserName + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing agents exceeded new agent position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20016, @Language) + ' (' + @ErrAcc + ').'
                          END
              , @ErrCode = 109

        RETURN
    END

    --Check all a1<=a4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT @sporttype AS sporttype
                 , @bettype AS bettype
                 , @a4 AS maxpositiontaking            
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.apositiontaking > b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg_Cur = @username + ': '
                           + CASE @Language
                               WHEN 'E' THEN 'Existing members exceeded new agent position taking (' + @ErrAcc + ').'
                               ELSE [dbo].[f_Get_MsgNamebyMsgID](20017, @Language) + ' (' + @ErrAcc + ').'
                              END
              , @ErrCode_Cur = 106

        SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)
             , @ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)

        RETURN
    END

    UPDATE CustSetting3rd with (ROWLOCK, UPDLOCK)
    SET
        spositiontaking = @s4,
        mpositiontaking = @m4,
        apositiontaking = @a4                        
    where custid=@custid and sporttype=@sporttype and bettype=@bettype 

    if (@@error <> 0)
    begin
        Select @ErrMsg_Cur = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end    , @ErrCode_Cur = 107                     
        
        
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return        
    end

    --exec dbo.Acc_CustomerUpdSuper_AutoPositiontaking @srecommend = @custid
    
    ---20131101@Johnson: apply execrep when correct pt on members
                EXEC dbo.Acc_CustSetting3rd_07
        @srecommend = @custid,
        @roleid = 4,
        @mode = 'virtual-sports',
        @sporttype = @sporttype,
        @bettype = @bettype
    /*
    -- Auto PT: update s1 
    -- if is1=1 then s1=min(s4-m1-a1), us1)
    -- else is3=1 then s1=min(s4-m1-a1), us3)

    Update cs
        set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
                                (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
    from
        CustSetting3rd as cs with(ROWLOCK, UPDLOCK)
        inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
        inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
        inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @custid and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where
        c.srecommend = @custid
        and c.roleid = 1 and cs.sporttype=@sporttype and cs.bettype=@bettype 
        and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)

    if (@@error <> 0)
    begin
        Select @ErrMsg_Cur = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end, @ErrCode_Cur = 108    
        
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return        
    end
    */
    
    --Update l4=s4
                                EXEC Acc_CustOverrideUpdVS @custid = @custid, @sporttype = @sporttype, @bettype = @bettype, @positiontaking_max = @s4, @UpdateMinPos=0, @UpdateMaxPos = 1, @IP = @IP ,@UserID = @userid, @WriteLog = 0, @Language = @Language, @ErrCode    = @ErrCode_Cur OUTPUT, @ErrMsg    =@ErrMsg_Cur OUTPUT

    if (@@error <> 0)
    begin
        Select @ErrMsg_Cur = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end, @ErrCode_Cur = 109                
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return        
    end
    ELSE
        SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)
END

--Update Min PT
IF @UpdateMinPositiontaking = 1
BEGIN        
                                EXEC Acc_CustOverrideUpdVS @custid = @custid, @sporttype = @sporttype, @bettype = @bettype, @positiontaking_min = @n4, @UpdateMinPos=1, @UpdateMaxPos = 0, @IP = @IP ,@UserID = @userid, @WriteLog = 0,@Language = @Language, @ErrCode    = @ErrCode_Cur OUTPUT, @ErrMsg    = @ErrMsg_Cur OUTPUT
    
    IF (@@error <> 0 or @ErrCode_Cur>0)
    BEGIN
        IF (@ErrCode_Cur = 0) 
        BEGIN
            Select @ErrMsg_Cur = @UserName + ': '+
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


Declare @LogSPData varchar(MAX),
        @TrackingValueDB varchar(5000)

Select @LogSPData = '<Acc_CustomerUpdSuperVS_Positiontaking custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
's4="'+ coalesce(cast(@s4 as varchar(50)),space(1)) + '" ' +
'm4="'+ coalesce(cast(@m4 as varchar(50)),space(1)) + '" ' +
'a4="'+ coalesce(cast(@a4 as varchar(50)),space(1)) + '" '+
'n4="'+ coalesce(cast(@n4 as varchar(50)),space(1)) + '" '+
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
'UpdateMinPositiontaking="'+ coalesce(cast(@UpdateMinPositiontaking as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" ' +
'/>'


Select @TrackingValueDB = '<Acc_CustomerUpdSuperVS_Positiontaking custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
's4="'+ coalesce(cast(@s4_old as varchar(50)),space(1)) + '" ' +
'm4="'+ coalesce(cast(@m4_old as varchar(50)),space(1)) + '" ' +
'a4="'+ coalesce(cast(@a4_old as varchar(50)),space(1)) + '" ' + 
'n4="'+ coalesce(cast(@n4_old as varchar(50)),space(1)) + '" ' + 
'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
'UpdateMinPositiontaking="'+ coalesce(cast(@UpdateMinPositiontaking as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
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
        @ActionID = 430,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END TRY
BEGIN CATCH    
    Select @LogSPData = '<Acc_CustomerUpdSuperVS_Positiontaking custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
    'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
    's4="'+ coalesce(cast(@s4 as varchar(50)),space(1)) + '" ' +
    'm4="'+ coalesce(cast(@m4 as varchar(50)),space(1)) + '" ' +
    'a4="'+ coalesce(cast(@a4 as varchar(50)),space(1)) + '" '+
    'n4="'+ coalesce(cast(@n4 as varchar(50)),space(1)) + '" '+
    'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
    'UpdateMinPositiontaking="'+ coalesce(cast(@UpdateMinPositiontaking as varchar(50)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +
    'ErrMsg="'+ ERROR_MESSAGE() + '" ' +
    '/>'
    
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 430,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperVS_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperVS_Positiontaking] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperVS_Positiontaking] TO [vnteam] AS [dbo]