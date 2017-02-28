USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustOverrideUpdHR]    Script Date: 06/10/2015 16:48:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdHR    Script Date: 8/28/2014 2:05:10 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdHR    Script Date: 8/21/2014 3:12:18 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdHR    Script Date: 8/21/2014 2:58:07 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdHR    Script Date: 12/5/2013 5:35:45 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustOverrideUpdHR] 
    @custid int,

    @v151positiontaking_31_min smallmoney = 0,-- @minv151positiontaking_31 -> @v151positiontaking_31_min
    @v151positiontaking_32_min smallmoney = 0,-- @minv151positiontaking_32 -> @v151positiontaking_32_min
    @v151positiontaking_41_min smallmoney = 0,-- @minv151positiontaking_41 -> @v151positiontaking_41_min
    @v151positiontaking_42_min smallmoney = 0,-- @minv151positiontaking_42 -> @v151positiontaking_42_min
    @v151positiontaking_51_min smallmoney = 0,
    @v151positiontaking_52_min smallmoney = 0,
    @v152positiontaking_41_min smallmoney = 0,
    @v152positiontaking_42_min smallmoney = 0,
    @v152positiontaking_51_min smallmoney = 0,
    @v152positiontaking_52_min smallmoney = 0,
    @v153positiontaking_51_min smallmoney = 0,
    @v153positiontaking_52_min smallmoney = 0,

    @v151positiontaking_31_max smallmoney = 0.5,-- @maxv151positiontaking_31 -> @v151positiontaking_31_max
    @v151positiontaking_32_max smallmoney = 0.5,
    @v151positiontaking_41_max smallmoney = 0.5,
    @v151positiontaking_42_max smallmoney = 0.5,
    @v151positiontaking_51_max smallmoney = 0.5,
    @v151positiontaking_52_max smallmoney = 0.5,
    @v152positiontaking_41_max smallmoney = 0.5,
    @v152positiontaking_42_max smallmoney = 0.5,
    @v152positiontaking_51_max smallmoney = 0.5,
    @v152positiontaking_52_max smallmoney = 0.5,
    @v153positiontaking_51_max smallmoney = 0.5,
    @v153positiontaking_52_max smallmoney = 0.5,

    @CheckPermission bit = 1,
    @UpdateMinPos bit = 1,
    @UpdateMaxPos bit = 1,
    @language varchar(2) = 'E',
    @UserID int = 0,
    @SubAccID int = 0, --Sub-AccountID
    @WriteLog bit = 1,
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20080514@Thien
Task : Update CustOverride for HR
DB: DBTXN/bodb02
Original: 

Revisions:
    - 20090701@Phuc: remove dbo.IsAllowChangePositiontaking.
                    Write log subaccname instead of subaccid.
    - 20090801@Shifu: check disabled user
    - 20090917@Phuc: write log into DBLOG.
    - 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
    - 20100112@Kiwi: amend to write log in xml format.
    - 20100422@Jamie: Check the total downlines before updating Min PT at super level
    - 20101019@Henry: Record execution time 
    - 20110124@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
    - 20110519@Johnson: write log for old setting
    - 20110709@Johnson: Change to use new server DB053 instead DB052
    - 20111028@Thien: change to call ExecRep SP: Acc_CustSetting3rd_00 & Acc_CustSetting3rd_01 
    - 20111125@Sophia: Correct the translation of Thai and Korean
    - 20120311@Thien: include master level into weekend checking
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130227@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
    - 20131029@Lukas: apply execRep
    - 20131112@Johnson: change to use execrep Acc_CustSetting3rd_04 instead of Acc_CustSetting3rd_00 for updating min pt on super
    - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]                        
    - 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
    
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

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @maxpos smallmoney 
Declare @roleid int, @srecommend int, @mrecommend int, @recommend int
select @roleid = roleid, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend from customer with (NOLOCK) where custid = @custid
select @maxpos = 0.5 --Max posistion for finance = 0.5
----------------------------------------------------------------------------------------------------
declare @IsValid bit, @totalDownlines int 
declare @ErrAcc varchar(4000)

-- Only direct upline have update permission
IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
BEGIN
	SELECT @ErrMsg = 'You don''t have permission to perform this action.',
		   @ErrCode = 103	
	RETURN
END
--Check Allowed downlines    
EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
            @roleid=@roleid,
            @isExecRep=1,
            @isUpdatePT = 1,
            @Sporttype = 1,
            @Language='E',
            @ErrMsg=@ErrMsg output,
            @ErrCode=@ErrCode output
IF    @ErrCode <> 0 
    RETURN 


--Check Old_minmax <> New_minmax
Declare      
    @old_minv151positiontaking_31 smallmoney,
    @old_minv151positiontaking_32 smallmoney,
    @old_minv151positiontaking_41 smallmoney,
    @old_minv151positiontaking_42 smallmoney,
    @old_minv151positiontaking_51 smallmoney,
    @old_minv151positiontaking_52 smallmoney,
    @old_minv152positiontaking_41 smallmoney,
    @old_minv152positiontaking_42 smallmoney,
    @old_minv152positiontaking_51 smallmoney,
    @old_minv152positiontaking_52 smallmoney,
    @old_minv153positiontaking_51 smallmoney,
    @old_minv153positiontaking_52 smallmoney,

    --v151
    @old_maxv151positiontaking_31 smallmoney,
    @old_maxv151positiontaking_32 smallmoney,
    @old_maxv151positiontaking_41 smallmoney,
    @old_maxv151positiontaking_42 smallmoney,
    @old_maxv151positiontaking_51 smallmoney,
    @old_maxv151positiontaking_52 smallmoney,
    @old_maxv152positiontaking_41 smallmoney,
    @old_maxv152positiontaking_42 smallmoney,
    @old_maxv152positiontaking_51 smallmoney,
    @old_maxv152positiontaking_52 smallmoney,
    @old_maxv153positiontaking_51 smallmoney,
    @old_maxv153positiontaking_52 smallmoney
    --Get Old data
    select @old_minv151positiontaking_31 = minpositiontaking, @old_maxv151positiontaking_31 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 31
    select @old_minv151positiontaking_32 = minpositiontaking, @old_maxv151positiontaking_32 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 32
    select @old_minv151positiontaking_41 = minpositiontaking, @old_maxv151positiontaking_41 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 41
    select @old_minv151positiontaking_42 = minpositiontaking, @old_maxv151positiontaking_42 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 42
    select @old_minv151positiontaking_51 = minpositiontaking, @old_maxv151positiontaking_51 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 51
    select @old_minv151positiontaking_52 = minpositiontaking, @old_maxv151positiontaking_52 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 52
    select @old_minv152positiontaking_41 = minpositiontaking, @old_maxv152positiontaking_41 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 41
    select @old_minv152positiontaking_42 = minpositiontaking, @old_maxv152positiontaking_42 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 42
    select @old_minv152positiontaking_51 = minpositiontaking, @old_maxv152positiontaking_51 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 51
    select @old_minv152positiontaking_52 = minpositiontaking, @old_maxv152positiontaking_52 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 52
    select @old_minv153positiontaking_51 = minpositiontaking, @old_maxv153positiontaking_51 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=153 and bettype = 51
    select @old_minv153positiontaking_52 = minpositiontaking, @old_maxv153positiontaking_52 = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=153 and bettype = 52

--Check Old_minmax = New_minmax
IF (@UpdateMinPos = 0 or 
        (
            @v151positiontaking_31_min = @old_minv151positiontaking_31 and
            @v151positiontaking_32_min = @old_minv151positiontaking_32 and
            @v151positiontaking_41_min = @old_minv151positiontaking_41 and
            @v151positiontaking_42_min = @old_minv151positiontaking_42 and
            @v151positiontaking_51_min = @old_minv151positiontaking_51 and
            @v151positiontaking_52_min = @old_minv151positiontaking_52 and
            @v152positiontaking_41_min = @old_minv152positiontaking_41 and
            @v152positiontaking_42_min = @old_minv152positiontaking_42 and
            @v152positiontaking_51_min = @old_minv152positiontaking_51 and
            @v152positiontaking_52_min = @old_minv152positiontaking_52 and
            @v153positiontaking_51_min = @old_minv153positiontaking_51 and
            @v153positiontaking_52_min = @old_minv153positiontaking_52 
        )
    )
    and 
    ( @UpdateMaxPos = 0 or
        (
            @v151positiontaking_31_max = @old_maxv151positiontaking_31 and
            @v151positiontaking_32_max = @old_maxv151positiontaking_32 and
            @v151positiontaking_41_max = @old_maxv151positiontaking_41 and
            @v151positiontaking_42_max = @old_maxv151positiontaking_42 and 
            @v151positiontaking_51_max = @old_maxv151positiontaking_51 and
            @v151positiontaking_52_max = @old_maxv151positiontaking_52 and
            @v152positiontaking_41_max = @old_maxv152positiontaking_41 and
            @v152positiontaking_42_max = @old_maxv152positiontaking_42 and
            @v152positiontaking_51_max = @old_maxv152positiontaking_51 and
            @v152positiontaking_52_max = @old_maxv152positiontaking_52 and
            @v153positiontaking_51_max = @old_maxv153positiontaking_51 and
            @v153positiontaking_52_max = @old_maxv153positiontaking_52
        )
    )
BEGIN
    return
END


--Check param

--1.Check values:
if @UpdateMinPos = 0
BEGIN
    --v151
    select @v151positiontaking_31_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 31
    select @v151positiontaking_32_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 32
    select @v151positiontaking_41_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 41
    select @v151positiontaking_42_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 42
    select @v151positiontaking_51_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 51
    select @v151positiontaking_52_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 52
    select @v152positiontaking_41_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 41
    select @v152positiontaking_42_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 42
    select @v152positiontaking_51_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 51
    select @v152positiontaking_52_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 52
    select @v153positiontaking_51_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=153 and bettype = 51
    select @v153positiontaking_52_min = minpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=153 and bettype = 52
END
if @UpdateMaxPos = 0
BEGIN
    --v151
    select @v151positiontaking_31_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 31
    select @v151positiontaking_32_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 32
    select @v151positiontaking_41_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 41
    select @v151positiontaking_42_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 42
    select @v151positiontaking_51_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 51
    select @v151positiontaking_52_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=151 and bettype = 52
    select @v152positiontaking_41_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 41
    select @v152positiontaking_42_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 42
    select @v152positiontaking_51_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 51
    select @v152positiontaking_52_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=152 and bettype = 52
    select @v153positiontaking_51_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=153 and bettype = 51
    select @v153positiontaking_52_max = maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @custid and sporttype=153 and bettype = 52
END


Select @isvalid = 1
if @UpdateMinPos=1
BEGIN
    if 
        --v151
        @v151positiontaking_31_min <0 or @v151positiontaking_31_min > @maxpos
        or @v151positiontaking_32_min <0 or @v151positiontaking_32_min > @maxpos
        or @v151positiontaking_41_min <0 or @v151positiontaking_41_min > @maxpos
        or @v151positiontaking_42_min <0 or @v151positiontaking_42_min > @maxpos
        or @v151positiontaking_51_min <0 or @v151positiontaking_51_min > @maxpos
        or @v151positiontaking_52_min <0 or @v151positiontaking_52_min > @maxpos
        or @v152positiontaking_41_min <0 or @v152positiontaking_41_min > @maxpos
        or @v152positiontaking_42_min <0 or @v152positiontaking_42_min > @maxpos
        or @v152positiontaking_51_min <0 or @v152positiontaking_51_min > @maxpos
        or @v152positiontaking_52_min <0 or @v152positiontaking_52_min > @maxpos
        or @v153positiontaking_51_min <0 or @v153positiontaking_51_min > @maxpos
        or @v153positiontaking_52_min <0 or @v153positiontaking_52_min > @maxpos
    BEGIN
        select @isvalid = 0, @ErrCode = 1
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong min position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](30001,@Language)
                    end
        return
    END
END

if @UpdateMaxPos=1
BEGIN
    if @v151positiontaking_31_max <0 or @v151positiontaking_31_max > @maxpos
        or @v151positiontaking_32_max <0 or @v151positiontaking_32_max > @maxpos
        or @v151positiontaking_41_max <0 or @v151positiontaking_41_max > @maxpos

        or @v151positiontaking_42_max <0 or @v151positiontaking_42_max > @maxpos
        or @v151positiontaking_51_max <0 or @v151positiontaking_51_max > @maxpos
        or @v151positiontaking_52_max <0 or @v151positiontaking_52_max > @maxpos
        or @v152positiontaking_41_max <0 or @v152positiontaking_41_max > @maxpos
        or @v152positiontaking_42_max <0 or @v152positiontaking_42_max > @maxpos
        or @v152positiontaking_51_max <0 or @v152positiontaking_51_max > @maxpos
        or @v152positiontaking_52_max <0 or @v152positiontaking_52_max > @maxpos
        or @v153positiontaking_51_max <0 or @v153positiontaking_51_max > @maxpos
        or @v153positiontaking_52_max <0 or @v153positiontaking_52_max > @maxpos
    BEGIN
        select @isvalid = 0, @ErrCode = 2
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong max position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](30002,@Language)
                    end
        return
    END
END

if @v151positiontaking_31_min > @v151positiontaking_31_max 
    or @v151positiontaking_32_min > @v151positiontaking_32_max
    or @v151positiontaking_41_min > @v151positiontaking_41_max 
    or @v151positiontaking_42_min > @v151positiontaking_42_max
    or @v151positiontaking_51_min > @v151positiontaking_51_max 
    or @v151positiontaking_52_min > @v151positiontaking_52_max
    or @v152positiontaking_41_min > @v152positiontaking_41_max 
    or @v152positiontaking_42_min > @v152positiontaking_42_max
    or @v152positiontaking_51_min > @v152positiontaking_51_max 
    or @v152positiontaking_52_min > @v152positiontaking_52_max
    or @v153positiontaking_51_min > @v153positiontaking_51_max 
    or @v153positiontaking_52_min > @v153positiontaking_52_max
BEGIN
    select @isvalid = 0, @ErrCode = 3
    Select @ErrMsg =     case @Language 
                        when 'E' then 'Wrong min/max position taking.'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](30003,@Language)
                end
    return
END
IF @roleid = 4 
BEGIN
if @UpdateMinPos = 1
BEGIN
    --check s4 >= new_n4
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        customer as c with (NOLOCK) 
        inner join CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
                            select     151 as sporttype, 31 as bettype, @v151positiontaking_31_min as minpositiontaking
                union all select     151 as sporttype, 32 as bettype, @v151positiontaking_32_min as minpositiontaking
                union all select     151 as sporttype, 41 as bettype, @v151positiontaking_41_min as minpositiontaking
                union all select     151 as sporttype, 42 as bettype, @v151positiontaking_42_min as minpositiontaking
                union all select     151 as sporttype, 51 as bettype, @v151positiontaking_51_min as minpositiontaking
                union all select     151 as sporttype, 52 as bettype, @v151positiontaking_52_min as minpositiontaking
                union all select     152 as sporttype, 41 as bettype, @v152positiontaking_41_min as minpositiontaking
                union all select     152 as sporttype, 42 as bettype, @v152positiontaking_42_min as minpositiontaking
                union all select     152 as sporttype, 51 as bettype, @v152positiontaking_51_min as minpositiontaking
                union all select     152 as sporttype, 52 as bettype, @v152positiontaking_52_min as minpositiontaking
                union all select     153 as sporttype, 51 as bettype, @v153positiontaking_51_min as minpositiontaking
                union all select     153 as sporttype, 52 as bettype, @v153positiontaking_52_min as minpositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where cs.custid = @custid and (cs.spositiontaking<b.minpositiontaking )
    group by username
    if @ErrAcc<>''
    BEGIN
        select @isvalid = 0, @ErrCode = 404
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Current account position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@ErrAcc+').'
                    end
        return
    END
END

END
IF @roleid = 3
BEGIN
    if @UpdateMaxPos = 1
    BEGIN
        --check all (n2)<=l3
        select @ErrAcc = ''

        select top 100 @ErrAcc = @ErrAcc + username + ', '
          from custInfo c with(NOLOCK) 
    inner join CustOverride3rd aco with(NOLOCK) on c.custid = aco.custid
    inner join (select 151 as sporttype
                     , 31 as bettype
                     , @v151positiontaking_31_max as maxpositiontaking

      union all select 151 as sporttype
                     , 32 as bettype
                     , @v151positiontaking_32_max as maxpositiontaking

      union all select 151 as sporttype
                     , 41 as bettype
                     , @v151positiontaking_41_max as maxpositiontaking

      union all select 151 as sporttype
                     , 42 as bettype
                     , @v151positiontaking_42_max as maxpositiontaking

      union all select 151 as sporttype
                     , 51 as bettype
                     , @v151positiontaking_51_max as maxpositiontaking

      union all select 151 as sporttype
                     , 52 as bettype
                     , @v151positiontaking_52_max as maxpositiontaking

      union all select 152 as sporttype
                     , 41 as bettype
                     , @v152positiontaking_41_max as maxpositiontaking

      union all select 152 as sporttype
                     , 42 as bettype
                     , @v152positiontaking_42_max as maxpositiontaking

      union all select 152 as sporttype
                     , 51 as bettype
                     , @v152positiontaking_51_max as maxpositiontaking

      union all select 152 as sporttype
                     , 52 as bettype
                     , @v152positiontaking_52_max as maxpositiontaking

      union all select 153 as sporttype
                     , 51 as bettype
                     , @v153positiontaking_51_max as maxpositiontaking

      union all select 153 as sporttype
                     , 52 as bettype
                     , @v153positiontaking_52_max as maxpositiontaking

               ) b on aco.sporttype = b.sporttype and aco.bettype = b.bettype
         where c.mrecommend = @custid
           and c.roleid     = 2
           AND c.Enabled    = 1
           and aco.minpositiontaking > b.maxpositiontaking
      group by username

        if @ErrAcc <> ''
        BEGIN
            select @isvalid = 0
                 , @ErrCode = 301

            Select @ErrMsg = case @Language 
                               when 'E' then 'Existing agents (minimum position taking) exceeded new maximum position taking' + ' (' + @ErrAcc + ').'
                               ELSE [dbo].[f_Get_MsgNamebyMsgID](30005, @Language) + ' (' + @ErrAcc + ').'
                             end
            return
        END
    END

    if @UpdateMinPos = 1
    BEGIN
        --check m3>=n3
        select @ErrAcc = ''
        --select top 100 @ErrAcc = @ErrAcc + username +' sporttype: '+ convert(varchar(10),b.sporttype) + ', bet type: ' + convert(varchar(10),b.bettype) + ', '
        select top 100 @ErrAcc = @ErrAcc + username + ', '
        from 
            customer as c with (NOLOCK) 
            inner join CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
            inner join (
                                select     151 as sporttype, 31 as bettype, @v151positiontaking_31_min as minpositiontaking
                    union all select     151 as sporttype, 32 as bettype, @v151positiontaking_32_min as minpositiontaking
                    union all select     151 as sporttype, 41 as bettype, @v151positiontaking_41_min as minpositiontaking
                    union all select     151 as sporttype, 42 as bettype, @v151positiontaking_42_min as minpositiontaking
                    union all select     151 as sporttype, 51 as bettype, @v151positiontaking_51_min as minpositiontaking
                    union all select     151 as sporttype, 52 as bettype, @v151positiontaking_52_min as minpositiontaking
                    union all select     152 as sporttype, 41 as bettype, @v152positiontaking_41_min as minpositiontaking
                    union all select     152 as sporttype, 42 as bettype, @v152positiontaking_42_min as minpositiontaking
                    union all select     152 as sporttype, 51 as bettype, @v152positiontaking_51_min as minpositiontaking
                    union all select     152 as sporttype, 52 as bettype, @v152positiontaking_52_min as minpositiontaking
                    union all select     153 as sporttype, 51 as bettype, @v153positiontaking_51_min as minpositiontaking
                    union all select     153 as sporttype, 52 as bettype, @v153positiontaking_52_min as minpositiontaking
                ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
        where cs.custid = @custid and (cs.mpositiontaking<b.minpositiontaking )
        group by username
        if @ErrAcc<>''
        BEGIN
            select @isvalid = 0, @ErrCode = 304
            Select @ErrMsg =     case @Language 
                                when 'E' then 'Current account position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@ErrAcc+').'
                        end
            return
        END
    END
END
IF @roleid = 2
BEGIN
    if @UpdateMinPos = 1
    BEGIN
        --check l3 >= n2
        select @ErrAcc = ''
        select top 100 @ErrAcc = @ErrAcc + username +', '
        from 
            customer as c with (NOLOCK) 
            inner join CustOverride3rd as mco with (NOLOCK) on c.custid = mco.custid
            inner join (
                                select     151 as sporttype, 31 as bettype, @v151positiontaking_31_min as minpositiontaking
                    union all select     151 as sporttype, 32 as bettype, @v151positiontaking_32_min as minpositiontaking
                    union all select     151 as sporttype, 41 as bettype, @v151positiontaking_41_min as minpositiontaking
                    union all select     151 as sporttype, 42 as bettype, @v151positiontaking_42_min as minpositiontaking
                    union all select     151 as sporttype, 51 as bettype, @v151positiontaking_51_min as minpositiontaking
                    union all select     151 as sporttype, 52 as bettype, @v151positiontaking_52_min as minpositiontaking
                    union all select     152 as sporttype, 41 as bettype, @v152positiontaking_41_min as minpositiontaking
                    union all select     152 as sporttype, 42 as bettype, @v152positiontaking_42_min as minpositiontaking
                    union all select     152 as sporttype, 51 as bettype, @v152positiontaking_51_min as minpositiontaking
                    union all select     152 as sporttype, 52 as bettype, @v152positiontaking_52_min as minpositiontaking
                    union all select     153 as sporttype, 51 as bettype, @v153positiontaking_51_min as minpositiontaking
                    union all select     153 as sporttype, 52 as bettype, @v153positiontaking_52_min as minpositiontaking
                ) as b on mco.sporttype=b.sporttype and mco.bettype = b.bettype
        where
            c.custid = (select mrecommend from customer with (NOLOCK) where custid = @custid) and c.roleid=3
            and (mco.maxpositiontaking<b.minpositiontaking )
        group by username
        if @ErrAcc<>''
        BEGIN
            select @isvalid = 0, @ErrCode = 151
            Select @ErrMsg =     case @Language 
                                when 'E' then 'Master maximum position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](30006,@Language) + ' ('+@ErrAcc+').'
                        end
            return
        END

        --check a2 >= n2
        select @ErrAcc = ''
        select top 100 @ErrAcc = @ErrAcc + username +', '
        from 
            customer as c with (NOLOCK) 
            inner join CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
            inner join (
                                select     151 as sporttype, 31 as bettype, @v151positiontaking_31_min as minpositiontaking
                    union all select     151 as sporttype, 32 as bettype, @v151positiontaking_32_min as minpositiontaking
                    union all select     151 as sporttype, 41 as bettype, @v151positiontaking_41_min as minpositiontaking
                    union all select     151 as sporttype, 42 as bettype, @v151positiontaking_42_min as minpositiontaking
                    union all select     151 as sporttype, 51 as bettype, @v151positiontaking_51_min as minpositiontaking
                    union all select     151 as sporttype, 52 as bettype, @v151positiontaking_52_min as minpositiontaking
                    union all select     152 as sporttype, 41 as bettype, @v152positiontaking_41_min as minpositiontaking
                    union all select     152 as sporttype, 42 as bettype, @v152positiontaking_42_min as minpositiontaking
                    union all select     152 as sporttype, 51 as bettype, @v152positiontaking_51_min as minpositiontaking
                    union all select     152 as sporttype, 52 as bettype, @v152positiontaking_52_min as minpositiontaking
                    union all select     153 as sporttype, 51 as bettype, @v153positiontaking_51_min as minpositiontaking
                    union all select     153 as sporttype, 52 as bettype, @v153positiontaking_52_min as minpositiontaking
                ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
        where cs.custid = @custid and (cs.apositiontaking<b.minpositiontaking)
        group by username
        if @ErrAcc<>''
        BEGIN
            select @isvalid = 0, @ErrCode = 203
            Select @ErrMsg =     case @Language 
                                when 'E' then 'Current account position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@ErrAcc+').'
                        end
            return
        END
    END
END

--End check param
if @ErrCode <> 0
BEGIN
    return
END

----------------------------------------------------------------------------------------------------
declare @logdata nvarchar(300)

if @UpdateMinPos = 1
BEGIN
    
    Update CustOverride3rd with (ROWLOCK, UPDLOCK) set minpositiontaking = b.minpositiontaking
    from CustOverride3rd as co inner join     
            (
                          select     @custid as custid,  151 as sporttype, 31 as bettype, @v151positiontaking_31_min as minpositiontaking
                union all select     @custid as custid,  151 as sporttype, 32 as bettype, @v151positiontaking_32_min as minpositiontaking
                union all select     @custid as custid,  151 as sporttype, 41 as bettype, @v151positiontaking_41_min as minpositiontaking
                union all select     @custid as custid,  151 as sporttype, 42 as bettype, @v151positiontaking_42_min as minpositiontaking
                union all select     @custid as custid,  151 as sporttype, 51 as bettype, @v151positiontaking_51_min as minpositiontaking

                union all select     @custid as custid,  151 as sporttype, 52 as bettype, @v151positiontaking_52_min as minpositiontaking
                union all select     @custid as custid,  152 as sporttype, 41 as bettype, @v152positiontaking_41_min as minpositiontaking
                union all select     @custid as custid,  152 as sporttype, 42 as bettype, @v152positiontaking_42_min as minpositiontaking
                union all select     @custid as custid,  152 as sporttype, 51 as bettype, @v152positiontaking_51_min as minpositiontaking
                union all select     @custid as custid,  152 as sporttype, 52 as bettype, @v152positiontaking_52_min as minpositiontaking
                union all select     @custid as custid,  153 as sporttype, 51 as bettype, @v153positiontaking_51_min as minpositiontaking
                union all select     @custid as custid,  153 as sporttype, 52 as bettype, @v153positiontaking_52_min as minpositiontaking
            ) as b on co.custid = b.custid and co.sporttype=b.sporttype and co.bettype = b.bettype
    where co.custid = @custid
END

if @UpdateMaxPos = 1
BEGIN

    Update CustOverride3rd with (ROWLOCK, UPDLOCK) set maxpositiontaking = b.maxpositiontaking
    from CustOverride3rd as co inner join     
            (
                            select     @custid as custid,  151 as sporttype, 31 as bettype, @v151positiontaking_31_max as maxpositiontaking
                union all select     @custid as custid,  151 as sporttype, 32 as bettype, @v151positiontaking_32_max as maxpositiontaking
                union all select     @custid as custid,  151 as sporttype, 41 as bettype, @v151positiontaking_41_max as maxpositiontaking
                union all select     @custid as custid,  151 as sporttype, 42 as bettype, @v151positiontaking_42_max as maxpositiontaking
                union all select     @custid as custid,  151 as sporttype, 51 as bettype, @v151positiontaking_51_max as maxpositiontaking
                union all select     @custid as custid,  151 as sporttype, 52 as bettype, @v151positiontaking_52_max as maxpositiontaking
                union all select     @custid as custid,  152 as sporttype, 41 as bettype, @v152positiontaking_41_max as maxpositiontaking
                union all select     @custid as custid,  152 as sporttype, 42 as bettype, @v152positiontaking_42_max as maxpositiontaking
                union all select     @custid as custid,  152 as sporttype, 51 as bettype, @v152positiontaking_51_max as maxpositiontaking
                union all select     @custid as custid,  152 as sporttype, 52 as bettype, @v152positiontaking_52_max as maxpositiontaking
                union all select     @custid as custid,  153 as sporttype, 51 as bettype, @v153positiontaking_51_max as maxpositiontaking
                union all select     @custid as custid,  153 as sporttype, 52 as bettype, @v153positiontaking_52_max as maxpositiontaking
            ) as b on co.custid = b.custid and co.sporttype=b.sporttype and co.bettype = b.bettype
    where co.custid = @custid
    
END

if @roleid = 2
BEGIN
    --EXEC dbo.Acc_CustomerUpdAgentHR_MinMaxPositiontaking @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend
                EXEC [dbo].[Acc_CustSetting3rd_04] @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend, @roleid = 2, @mode = 'horse'
    -- The minimum position taking value of agent was modified by agent's upline
    EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID
END
else if @roleid = 3
BEGIN
    --EXEC dbo.Acc_CustomerUpdMasterHR_MinMaxPositiontaking @mrecommend = @mrecommend, @srecommend = @srecommend
                EXEC dbo.[Acc_CustSetting3rd_04] @mrecommend = @mrecommend, @srecommend = @srecommend, @roleid = 3, @mode = 'horse'
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMinPos = 1
BEGIN
                EXEC dbo.Acc_CustSetting3rd_04 @srecommend = @srecommend, @roleid = 4, @mode = 'horse'
END
else if @roleid= 4 and @WriteLog = 1 and @UpdateMaxPos = 1
BEGIN
    EXEC dbo.Acc_CustSetting3rd_01 @srecommend = @srecommend, @mode = 'horse'
END



if @WriteLog = 1
BEGIN
    Declare @LogSPData varchar(MAX),
            @TrackingValueDB varchar(4000)
            
    Select @LogSPData = '<Acc_CustOverrideUpdHR><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
    'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
    'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
    'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
    
    '<MinMaxPT minv151pt_31="'+ coalesce(cast(@v151positiontaking_31_min as varchar(50)),space(1)) + '" ' +
    'minv151pt_32="'+ coalesce(cast(@v151positiontaking_32_min as varchar(50)),space(1)) + '" ' +
    'minv151pt_41="'+ coalesce(cast(@v151positiontaking_41_min as varchar(50)),space(1)) + '" ' +
    'minv151pt_42="'+ coalesce(cast(@v151positiontaking_42_min as varchar(50)),space(1)) + '" ' +
    'minv151pt_51="'+ coalesce(cast(@v151positiontaking_51_min as varchar(50)),space(1)) + '" ' +
    'minv151pt_52="'+ coalesce(cast(@v151positiontaking_52_min as varchar(50)),space(1)) + '" ' +
    'minv152pt_41="'+ coalesce(cast(@v152positiontaking_41_min as varchar(50)),space(1)) + '" ' +
    'minv152pt_42="'+ coalesce(cast(@v152positiontaking_42_min as varchar(50)),space(1)) + '" ' +
    'minv152pt_51="'+ coalesce(cast(@v152positiontaking_51_min as varchar(50)),space(1)) + '" ' +
    'minv152pt_52="'+ coalesce(cast(@v152positiontaking_52_min as varchar(50)),space(1)) + '" ' +
    'minv153pt_51="'+ coalesce(cast(@v153positiontaking_51_min as varchar(50)),space(1)) + '" ' +
    'minv153pt_52="'+ coalesce(cast(@v153positiontaking_52_min as varchar(50)),space(1)) + '" ' +

    'maxv151pt_31="'+ coalesce(cast(@v151positiontaking_31_max as varchar(50)),space(1)) + '" ' +
    'maxv151pt_32="'+ coalesce(cast(@v151positiontaking_32_max as varchar(50)),space(1)) + '" ' +
    'maxv151pt_41="'+ coalesce(cast(@v151positiontaking_41_max as varchar(50)),space(1)) + '" ' +
    'maxv151pt_42="'+ coalesce(cast(@v151positiontaking_42_max as varchar(50)),space(1)) + '" ' +
    'maxv151pt_51="'+ coalesce(cast(@v151positiontaking_51_max as varchar(50)),space(1)) + '" ' +
    'maxv151pt_52="'+ coalesce(cast(@v151positiontaking_52_max as varchar(50)),space(1)) + '" ' +
    'maxv152pt_41="'+ coalesce(cast(@v152positiontaking_41_max as varchar(50)),space(1)) + '" ' +
    'maxv152pt_42="'+ coalesce(cast(@v152positiontaking_42_max as varchar(50)),space(1)) + '" ' +
    'maxv152pt_51="'+ coalesce(cast(@v152positiontaking_51_max as varchar(50)),space(1)) + '" ' +
    'maxv152pt_52="'+ coalesce(cast(@v152positiontaking_52_max as varchar(50)),space(1)) + '" ' +
    'maxv153pt_51="'+ coalesce(cast(@v153positiontaking_51_max as varchar(50)),space(1)) + '" ' +
    'maxv153pt_52="'+ coalesce(cast(@v153positiontaking_52_max as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpdHR>'
    
    
    Select @TrackingValueDB = '<Acc_CustOverrideUpdHR><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
    'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
    'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
    'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
    
    '<MinMaxPT minv151pt_31="'+ coalesce(cast(@old_minv151positiontaking_31 as varchar(50)),space(1)) + '" ' +
    'minv151pt_32="'+ coalesce(cast(@old_minv151positiontaking_32 as varchar(50)),space(1)) + '" ' +
    'minv151pt_41="'+ coalesce(cast(@old_minv151positiontaking_41 as varchar(50)),space(1)) + '" ' +
    'minv151pt_42="'+ coalesce(cast(@old_minv151positiontaking_42 as varchar(50)),space(1)) + '" ' +
    'minv151pt_51="'+ coalesce(cast(@old_minv151positiontaking_51 as varchar(50)),space(1)) + '" ' +
    'minv151pt_52="'+ coalesce(cast(@old_minv151positiontaking_52 as varchar(50)),space(1)) + '" ' +
    'minv152pt_41="'+ coalesce(cast(@old_minv152positiontaking_41 as varchar(50)),space(1)) + '" ' +
    'minv152pt_42="'+ coalesce(cast(@old_minv152positiontaking_42 as varchar(50)),space(1)) + '" ' +
    'minv152pt_51="'+ coalesce(cast(@old_minv152positiontaking_51 as varchar(50)),space(1)) + '" ' +
    'minv152pt_52="'+ coalesce(cast(@old_minv152positiontaking_52 as varchar(50)),space(1)) + '" ' +
    'minv153pt_51="'+ coalesce(cast(@old_minv153positiontaking_51 as varchar(50)),space(1)) + '" ' +
    'minv153pt_52="'+ coalesce(cast(@old_minv153positiontaking_52 as varchar(50)),space(1)) + '" ' +

    'maxv151pt_31="'+ coalesce(cast(@old_maxv151positiontaking_31 as varchar(50)),space(1)) + '" ' +
    'maxv151pt_32="'+ coalesce(cast(@old_maxv151positiontaking_32 as varchar(50)),space(1)) + '" ' +
    'maxv151pt_41="'+ coalesce(cast(@old_maxv151positiontaking_41 as varchar(50)),space(1)) + '" ' +
    'maxv151pt_42="'+ coalesce(cast(@old_maxv151positiontaking_42 as varchar(50)),space(1)) + '" ' +
    'maxv151pt_51="'+ coalesce(cast(@old_maxv151positiontaking_51 as varchar(50)),space(1)) + '" ' +
    'maxv151pt_52="'+ coalesce(cast(@old_maxv151positiontaking_52 as varchar(50)),space(1)) + '" ' +
    'maxv152pt_41="'+ coalesce(cast(@old_maxv152positiontaking_41 as varchar(50)),space(1)) + '" ' +
    'maxv152pt_42="'+ coalesce(cast(@old_maxv152positiontaking_42 as varchar(50)),space(1)) + '" ' +
    'maxv152pt_51="'+ coalesce(cast(@old_maxv152positiontaking_51 as varchar(50)),space(1)) + '" ' +
    'maxv152pt_52="'+ coalesce(cast(@old_maxv152positiontaking_52 as varchar(50)),space(1)) + '" ' +
    'maxv153pt_51="'+ coalesce(cast(@old_maxv153positiontaking_51 as varchar(50)),space(1)) + '" ' +
    'maxv153pt_52="'+ coalesce(cast(@old_maxv153positiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpdHR>'
    
    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)
    
    --Write log
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 502,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        Select @LogSPData = '<Acc_CustOverrideUpdHR><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
        'CheckPermission="'+ coalesce(cast(@CheckPermission as varchar(50)),space(1)) + '" ' +
        'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
        'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />' +
        
        '<MinMaxPT minv151pt_31="'+ coalesce(cast(@v151positiontaking_31_min as varchar(50)),space(1)) + '" ' +
        'minv151pt_32="'+ coalesce(cast(@v151positiontaking_32_min as varchar(50)),space(1)) + '" ' +
        'minv151pt_41="'+ coalesce(cast(@v151positiontaking_41_min as varchar(50)),space(1)) + '" ' +
        'minv151pt_42="'+ coalesce(cast(@v151positiontaking_42_min as varchar(50)),space(1)) + '" ' +
        'minv151pt_51="'+ coalesce(cast(@v151positiontaking_51_min as varchar(50)),space(1)) + '" ' +
        'minv151pt_52="'+ coalesce(cast(@v151positiontaking_52_min as varchar(50)),space(1)) + '" ' +
        'minv152pt_41="'+ coalesce(cast(@v152positiontaking_41_min as varchar(50)),space(1)) + '" ' +
        'minv152pt_42="'+ coalesce(cast(@v152positiontaking_42_min as varchar(50)),space(1)) + '" ' +
        'minv152pt_51="'+ coalesce(cast(@v152positiontaking_51_min as varchar(50)),space(1)) + '" ' +
        'minv152pt_52="'+ coalesce(cast(@v152positiontaking_52_min as varchar(50)),space(1)) + '" ' +
        'minv153pt_51="'+ coalesce(cast(@v153positiontaking_51_min as varchar(50)),space(1)) + '" ' +
        'minv153pt_52="'+ coalesce(cast(@v153positiontaking_52_min as varchar(50)),space(1)) + '" ' +

        'maxv151pt_31="'+ coalesce(cast(@v151positiontaking_31_max as varchar(50)),space(1)) + '" ' +
        'maxv151pt_32="'+ coalesce(cast(@v151positiontaking_32_max as varchar(50)),space(1)) + '" ' +
        'maxv151pt_41="'+ coalesce(cast(@v151positiontaking_41_max as varchar(50)),space(1)) + '" ' +
        'maxv151pt_42="'+ coalesce(cast(@v151positiontaking_42_max as varchar(50)),space(1)) + '" ' +
        'maxv151pt_51="'+ coalesce(cast(@v151positiontaking_51_max as varchar(50)),space(1)) + '" ' +
        'maxv151pt_52="'+ coalesce(cast(@v151positiontaking_52_max as varchar(50)),space(1)) + '" ' +
        'maxv152pt_41="'+ coalesce(cast(@v152positiontaking_41_max as varchar(50)),space(1)) + '" ' +
        'maxv152pt_42="'+ coalesce(cast(@v152positiontaking_42_max as varchar(50)),space(1)) + '" ' +
        'maxv152pt_51="'+ coalesce(cast(@v152positiontaking_51_max as varchar(50)),space(1)) + '" ' +
        'maxv152pt_52="'+ coalesce(cast(@v152positiontaking_52_max as varchar(50)),space(1)) + '" ' +
        'maxv153pt_51="'+ coalesce(cast(@v153positiontaking_51_max as varchar(50)),space(1)) + '" ' +
        'maxv153pt_52="'+ coalesce(cast(@v153positiontaking_52_max as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpdHR>'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 502,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdHR] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdHR] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdHR] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpdHR] TO [vnteam] AS [dbo]