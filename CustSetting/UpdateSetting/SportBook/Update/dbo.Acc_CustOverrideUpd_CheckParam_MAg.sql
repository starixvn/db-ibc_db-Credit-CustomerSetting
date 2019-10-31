/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustOverrideUpd_CheckParam_MAg]
    @custid int,
    @minpositiontaking_1 smallmoney,
    @minpositiontaking_2 smallmoney,
    @minpositiontaking_3 smallmoney,
    @minpositiontaking_4 smallmoney,
    @minpositiontaking_5 smallmoney,
    @minpositiontaking_6 smallmoney,
    @minpositiontaking_7 smallmoney,
    @minpositiontaking_8 smallmoney,
    @minpositiontaking_9 smallmoney,
    @minpositiontaking_10 smallmoney,
    @minpositiontaking_9999 smallmoney = 0,
    
    @minlivepositiontaking_1 smallmoney,
    @minlivepositiontaking_3 smallmoney,
    @minlivepositiontaking_7 smallmoney,
    @minlivepositiontaking_8 smallmoney,
    
    @minv2positiontaking_1 smallmoney,
    @minv2positiontaking_2 smallmoney,
    @minv2positiontaking_3 smallmoney,
    @minv2positiontaking_7 smallmoney,
    @minv2positiontaking_8 smallmoney,
    --@minv2positiontaking_9 smallmoney,
    @minv2positiontaking_20 smallmoney,
    @minv2positiontaking_9999 smallmoney,

    @minv3positiontaking_1 smallmoney,
    @minv3positiontaking_2 smallmoney,
    @minv3positiontaking_3 smallmoney,
    @minv3positiontaking_20 smallmoney,

    @minv5positiontaking_1 smallmoney,
    @minv5positiontaking_2 smallmoney,
    @minv5positiontaking_3 smallmoney,
    @minv5positiontaking_20 smallmoney,
    @minv5positiontaking_9999 smallmoney = 0,

    @minv8positiontaking_1 smallmoney,
    @minv8positiontaking_3 smallmoney,
    @minv8positiontaking_20 smallmoney,

    @minv10positiontaking_1 smallmoney,
    @minv10positiontaking_2 smallmoney,
    @minv10positiontaking_3 smallmoney,
    @minv10positiontaking_20 smallmoney,

    @minv11positiontaking_1 smallmoney,
    @minv11positiontaking_20 smallmoney,

    @minv99positiontaking_1 smallmoney,
    @minv99positiontaking_2 smallmoney,
    @minv99positiontaking_3 smallmoney,
    @minv99positiontaking_9 smallmoney,
    @minv99positiontaking_20 smallmoney,
	@minv99positiontaking_9999 smallmoney,

    --v161
    @minv161positiontaking_81 smallmoney,
    @minv161positiontaking_83 smallmoney,
    @minv161positiontaking_86 smallmoney,
    @minv161positiontaking_88 smallmoney,
    @minv161livepositiontaking_85 smallmoney,
    @minv161livepositiontaking_86 smallmoney,
    @minv161livepositiontaking_87 smallmoney,
    @minv161livepositiontaking_89 smallmoney,
    @minv161livepositiontaking_90 smallmoney,
    
    @maxpositiontaking_1 smallmoney,
    @maxpositiontaking_2 smallmoney,
    @maxpositiontaking_3 smallmoney,
    @maxpositiontaking_4 smallmoney,
    @maxpositiontaking_5 smallmoney,
    @maxpositiontaking_6 smallmoney,
    @maxpositiontaking_7 smallmoney,
    @maxpositiontaking_8 smallmoney,
    @maxpositiontaking_9 smallmoney,
    @maxpositiontaking_10 smallmoney,
    @maxpositiontaking_9999 smallmoney = 0,
    
    @maxlivepositiontaking_1 smallmoney,
    @maxlivepositiontaking_3 smallmoney,
    @maxlivepositiontaking_7 smallmoney,
    @maxlivepositiontaking_8 smallmoney,
    
    @maxv2positiontaking_1 smallmoney,
    @maxv2positiontaking_2 smallmoney,
    @maxv2positiontaking_3 smallmoney,
    @maxv2positiontaking_7 smallmoney,
    @maxv2positiontaking_8 smallmoney,
    --@maxv2positiontaking_9 smallmoney,
    @maxv2positiontaking_20 smallmoney,
    @maxv2positiontaking_9999 smallmoney,

    @maxv3positiontaking_1 smallmoney,
    @maxv3positiontaking_2 smallmoney,
    @maxv3positiontaking_3 smallmoney,
    @maxv3positiontaking_20 smallmoney,

    @maxv5positiontaking_1 smallmoney,
    @maxv5positiontaking_2 smallmoney,
    @maxv5positiontaking_3 smallmoney,
    @maxv5positiontaking_20 smallmoney,
    @maxv5positiontaking_9999 smallmoney =0,

    @maxv8positiontaking_1 smallmoney,
    @maxv8positiontaking_3 smallmoney,
    @maxv8positiontaking_20 smallmoney,

    @maxv10positiontaking_1 smallmoney,
    @maxv10positiontaking_2 smallmoney,
    @maxv10positiontaking_3 smallmoney,
    @maxv10positiontaking_20 smallmoney,

    @maxv11positiontaking_1 smallmoney,
    @maxv11positiontaking_20 smallmoney,

    @maxv99positiontaking_1 smallmoney,
    @maxv99positiontaking_2 smallmoney,
    @maxv99positiontaking_3 smallmoney,
    @maxv99positiontaking_9 smallmoney,
    @maxv99positiontaking_20 smallmoney,
	@maxv99positiontaking_9999 smallmoney,
    
    --v161
    @maxv161positiontaking_81 smallmoney,
    @maxv161positiontaking_83 smallmoney,
    @maxv161positiontaking_86 smallmoney,
    @maxv161positiontaking_88 smallmoney,
    @maxv161livepositiontaking_85 smallmoney,
    @maxv161livepositiontaking_86 smallmoney,
    @maxv161livepositiontaking_87 smallmoney,
    @maxv161livepositiontaking_89 smallmoney,
    @maxv161livepositiontaking_90 smallmoney,
    
    -- Outright PT for Sports
	@maxv2positiontaking_10 smallmoney = 0,
	@maxv3positiontaking_10 smallmoney = 0,
	@maxv5positiontaking_10 smallmoney = 0,
	@maxv8positiontaking_10 smallmoney = 0,
	@maxv10positiontaking_10 smallmoney = 0,
	@maxv11positiontaking_10 smallmoney = 0,
	@maxv99positiontaking_10 smallmoney = 0,
	
	@minv2positiontaking_10 smallmoney = 0,
	@minv3positiontaking_10 smallmoney = 0,
	@minv5positiontaking_10 smallmoney = 0,
	@minv8positiontaking_10 smallmoney = 0,
	@minv10positiontaking_10 smallmoney = 0,
	@minv11positiontaking_10 smallmoney = 0,
	@minv99positiontaking_10 smallmoney = 0,
    
    @UpdateMinPos bit = 1,
    @UpdateMaxPos bit = 1,
    @roleid int, 
    @srecommend int, 
    @mrecommend int, 
    @recommend int,
    @isvalid bit OUTPUT,
    @errmsg nvarchar(4000) OUTPUT,
    @errcode int OUTPUT,
    @language varchar(2) = 'E'
AS
--@Source Control
/*
Created: 20080514@Thien
Task : Check parameters to update CustOverride
DB: DBTXN/bodb02
Original: 

Revisions:
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20100903@Henry: Add Mix Parlay Mixed Sports && Number Game
    - 20110802@Lukas: (Number Game)
            - Add more bettypes: Warrior, Next Combo, Number Group
            - Remove Dead ball Over/Under
    - 20111125@Sophia: Correct the translation of Thai and Korean
    - 20120829@Johnson: Check n3 <= min (m3,m4)
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20140618@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
    - 20140725@Logan: 1. Exclude disabled agents while updating master's setting
                      2. Code aligning
    - 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]                  
    - 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]	
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
Param's Explanation:
• @ErrCode:
    = 0: check parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @ErrAcc varchar(4000)

if @UpdateMaxPos = 1
BEGIN

    --check all (n2)<=l3
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + ci.username +', '
      from custoverride as aco with(NOLOCK)
inner join (select 1 as sporttype --1
                 , 1 as bettype
                 , @maxpositiontaking_1 as maxpositiontaking
                 , @maxlivepositiontaking_1 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 2 as bettype
                 , @maxpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 3 as bettype
                 , @maxpositiontaking_3 as maxpositiontaking
                 , @maxlivepositiontaking_3 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 4 as bettype
                 , @maxpositiontaking_4 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 5 as bettype
                 , @maxpositiontaking_5 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 6 as bettype
                 , @maxpositiontaking_6 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 7 as bettype
                 , @maxpositiontaking_7 as maxpositiontaking
                 , @maxlivepositiontaking_7 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 8 as bettype
                 , @maxpositiontaking_8 as maxpositiontaking
                 , @maxlivepositiontaking_8 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 9 as bettype
                 , @maxpositiontaking_9 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 10 as bettype
                 , @maxpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking

	  -- Outright PT for Sports
	union all select 2 as sporttype
					 , 10 as bettype
					 , @maxv2positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	union all select 3 as sporttype
					 , 10 as bettype
					 , @maxv3positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	union all select 5 as sporttype
					 , 10 as bettype
					 , @maxv5positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	union all select 8 as sporttype
					 , 10 as bettype
					 , @maxv8positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	union all select 10 as sporttype
					 , 10 as bettype
					 , @maxv10positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	union all select 11 as sporttype
					 , 10 as bettype
					 , @maxv11positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	union all select 99 as sporttype
					 , 10 as bettype
					 , @maxv99positiontaking_10 as maxpositiontaking
					 , 0 as maxlivepositiontaking
	                                                                                                                     
  union all select 1 as sporttype
                 , 9999 as bettype
                 , @maxpositiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking
--2
  union all select 2 as sporttype
                 , 1 as bettype
                 , @maxv2positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 2 as bettype
                 , @maxv2positiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 3 as bettype
                 , @maxv2positiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 7 as bettype
                 , @maxv2positiontaking_7 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 8 as bettype
                 , @maxv2positiontaking_8 as maxpositiontaking
                 , 0 as maxlivepositiontaking

                --union all select     2 as sporttype, 9 as bettype, @maxv2positiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                
  union all select 2 as sporttype
                 , 20 as bettype
                 , @maxv2positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 2 as sporttype
                 , 9999 as bettype
                 , @maxv2positiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking               
--3
  union all select 3 as sporttype
                 , 1 as bettype
                 , @maxv3positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 2 as bettype
                 , @maxv3positiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 3 as bettype
                 , @maxv3positiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 20 as bettype
                 , @maxv3positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
--5
  union all select 5 as sporttype
                 , 1 as bettype
                 , @maxv5positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 2 as bettype
                 , @maxv5positiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 3 as bettype
                 , @maxv5positiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 20 as bettype
                 , @maxv5positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 9999 as bettype
                 , @maxv5positiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking
--8
  union all select 8 as sporttype
                 , 1 as bettype
                 , @maxv8positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 8 as sporttype
                 , 3 as bettype
                 , @maxv8positiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 8 as sporttype
                 , 20 as bettype
                 , @maxv8positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
--10
  union all select 10 as sporttype
                 , 1 as bettype
                 , @maxv10positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 2 as bettype
                 , @maxv10positiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 3 as bettype
                 , @maxv10positiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 20 as bettype
                 , @maxv10positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
--11
  union all select 11 as sporttype
                 , 1 as bettype
                 , @maxv11positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 11 as sporttype
                 , 20 as bettype
                 , @maxv11positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
--99
  union all select 99 as sporttype
                 , 1 as bettype
                 , @maxv99positiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 2 as bettype
                 , @maxv99positiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 3 as bettype
                 , @maxv99positiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 9 as bettype
                 , @maxv99positiontaking_9 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 20 as bettype
                 , @maxv99positiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 99 as sporttype
                 , 9999 as bettype
                 , @maxv99positiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking

           ) as b on aco.sporttype = b.sporttype and aco.bettype = b.bettype
INNER JOIN custInfo ci ON ci.custid = aco.custid
     where ci.mrecommend = @custid
       and ci.roleid     = 2
       and ci.Enabled    = 1
       and (aco.minpositiontaking > b.maxpositiontaking 
            or (b.sporttype = 1 
                and b.bettype in (1, 3, 7, 8)
                and aco.minlivepositiontaking > b.maxlivepositiontaking
               )
           )
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

    --v161
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + ci.username + ', '
      from custoverride3rd as aco with(NOLOCK)
inner join (select 161 as sporttype
                 , 81 as bettype
                 , @maxv161positiontaking_81 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 83 as bettype
                 , @maxv161positiontaking_83 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 88 as bettype
                 , @maxv161positiontaking_88 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 85 as bettype
                 , 0 as maxpositiontaking
                 , @maxv161livepositiontaking_85 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 86 as bettype
                 , @maxv161positiontaking_86 as maxpositiontaking
                 , @maxv161livepositiontaking_86 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 87 as bettype
                 , 0 as maxpositiontaking
                 , @maxv161livepositiontaking_87 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 89 as bettype
                 , 0 as maxpositiontaking
                 , @maxv161livepositiontaking_89 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 90 as bettype
                 , 0 as maxpositiontaking
                 , @maxv161livepositiontaking_90 as maxlivepositiontaking

           ) as b on aco.sporttype = b.sporttype and aco.bettype = b.bettype
INNER JOIN custInfo ci WITH(NOLOCK) ON ci.custid = aco.custid
     where ci.mrecommend = @custid
       and ci.roleid     = 2
       AND ci.Enabled    = 1
       and (aco.minpositiontaking > b.maxpositiontaking
            or (b.sporttype = 161
                and b.bettype in (85, 86, 87, 89, 90)
                and aco.minlivepositiontaking > b.maxlivepositiontaking
               )
           )
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

/*
    --check m3 <= l3
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        customer as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
    
                select         1 as sporttype, 1 as bettype, @maxpositiontaking_1 as maxpositiontaking,  @maxlivepositiontaking_1 as maxlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @maxpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @maxpositiontaking_3 as maxpositiontaking,  @maxlivepositiontaking_3 as maxlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @maxpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @maxpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @maxpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @maxpositiontaking_7 as maxpositiontaking,  @maxlivepositiontaking_7 as maxlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @maxpositiontaking_8 as maxpositiontaking,  @maxlivepositiontaking_8 as maxlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @maxpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @maxpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 1 as bettype, @maxv2positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @maxv2positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @maxv2positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @maxv2positiontaking_7 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @maxv2positiontaking_8 as maxpositiontaking,  0 as maxlivepositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where cs.custid = @custid and (cs.mpositiontaking>b.maxpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and cs.mlivepositiontaking>b.maxlivepositiontaking))
    group by username
    if @ErrAcc<>''
    BEGIN
        select @isvalid = 0, @ErrCode = 301
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Current account position taking exceeded new maximum position taking ('+@ErrAcc+').'
                            when 'CS' then N'Current account position taking exceeded new maximum position taking ('+@ErrAcc+').'
                            when 'J' then N'Current account position taking exceeded new maximum position taking ('+@ErrAcc+').'
                            else N'Current account position taking exceeded new maximum position taking ('+@ErrAcc+').'
                    end
        return
    END
    
    --check all (m2+a2) <= l3
    --just be provident because this case cannot happen
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        customer as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
    
                select         1 as sporttype, 1 as bettype, @maxpositiontaking_1 as maxpositiontaking,  @maxlivepositiontaking_1 as maxlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @maxpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @maxpositiontaking_3 as maxpositiontaking,  @maxlivepositiontaking_3 as maxlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @maxpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @maxpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @maxpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @maxpositiontaking_7 as maxpositiontaking,  @maxlivepositiontaking_7 as maxlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @maxpositiontaking_8 as maxpositiontaking,  @maxlivepositiontaking_8 as maxlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @maxpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @maxpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 1 as bettype, @maxv2positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @maxv2positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @maxv2positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @maxv2positiontaking_7 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @maxv2positiontaking_8 as maxpositiontaking,  0 as maxlivepositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.mrecommend = @custid and c.roleid = 2 and (cs.apositiontaking+cs.mpositiontaking>b.maxpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and cs.alivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking))
    group by username
    if @ErrAcc<>''
    BEGIN
        select @isvalid = 0, @ErrCode = 302
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Existing agents exceeded new maximum position taking ('+@ErrAcc+').'
                            when 'CS' then N'Existing agents exceeded new maximum position taking ('+@ErrAcc+').'
                            when 'J' then N'Existing agents exceeded new maximum position taking ('+@ErrAcc+').'
                            else N'Existing agents exceeded new maximum position taking ('+@ErrAcc+').'
                    end
        return
    END
    --check all (m1+a1) <= l3
    --just be provident because this case cannot happen
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        customer as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
    
                select         1 as sporttype, 1 as bettype, @maxpositiontaking_1 as maxpositiontaking,  @maxlivepositiontaking_1 as maxlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @maxpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @maxpositiontaking_3 as maxpositiontaking,  @maxlivepositiontaking_3 as maxlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @maxpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @maxpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @maxpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @maxpositiontaking_7 as maxpositiontaking,  @maxlivepositiontaking_7 as maxlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @maxpositiontaking_8 as maxpositiontaking,  @maxlivepositiontaking_8 as maxlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @maxpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @maxpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 1 as bettype, @maxv2positiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @maxv2positiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @maxv2positiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @maxv2positiontaking_7 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @maxv2positiontaking_8 as maxpositiontaking,  0 as maxlivepositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.mrecommend = @custid and c.roleid = 1 and (cs.mpositiontaking+cs.apositiontaking>b.maxpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and cs.mlivepositiontaking+cs.alivepositiontaking>b.maxlivepositiontaking))
    group by username
    if @ErrAcc<>''
    BEGIN
        select @isvalid = 0, @ErrCode = 303
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Existing members exceeded new maximum position taking ('+@ErrAcc+').'
                            when 'CS' then N'Existing members exceeded new maximum position taking ('+@ErrAcc+').'
                            when 'J' then N'Existing members exceeded new maximum position taking ('+@ErrAcc+').'
                            else N'Existing members exceeded new maximum position taking ('+@ErrAcc+').'
                    end
        return
    END
    */
END

if @UpdateMinPos = 1
BEGIN
    --check min(m3,m4)>=n3
    select @ErrAcc = ''
    --select top 100 @ErrAcc = @ErrAcc + username +' sporttype: '+ convert(varchar(10),b.sporttype) + ', bet type: ' + convert(varchar(10),b.bettype) + ', '
    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from customer c with(NOLOCK) 
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid        
inner join (select 1 as sporttype
                 , 1 as bettype
                 , @minpositiontaking_1 as minpositiontaking
                 , @minlivepositiontaking_1 as minlivepositiontaking

  union all select 1 as sporttype
                 , 2 as bettype
                 , @minpositiontaking_2 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 1 as sporttype
                 , 3 as bettype
                 , @minpositiontaking_3 as minpositiontaking
                 , @minlivepositiontaking_3 as minlivepositiontaking

  union all select 1 as sporttype
                 , 4 as bettype
                 , @minpositiontaking_4 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 1 as sporttype
                 , 5 as bettype
                 , @minpositiontaking_5 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 1 as sporttype
                 , 6 as bettype
                 , @minpositiontaking_6 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 1 as sporttype
                 , 7 as bettype
                 , @minpositiontaking_7 as minpositiontaking
                 , @minlivepositiontaking_7 as minlivepositiontaking

  union all select 1 as sporttype
                 , 8 as bettype
                 , @minpositiontaking_8 as minpositiontaking
                 , @minlivepositiontaking_8 as minlivepositiontaking

  union all select 1 as sporttype
                 , 9 as bettype
                 , @minpositiontaking_9 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 1 as sporttype
                 , 10 as bettype
                 , @minpositiontaking_10 as minpositiontaking
                 , 0 as minlivepositiontaking

-- Outright PT for sports
	union all select 2 as sporttype
					 , 10 as bettype
					 , @minv2positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 	
	union all select 3 as sporttype
					 , 10 as bettype
					 , @minv3positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 
	union all select 5 as sporttype
					 , 10 as bettype
					 , @minv5positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 
	union all select 8 as sporttype
					 , 10 as bettype
					 , @minv8positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 
	union all select 10 as sporttype
					 , 10 as bettype
					 , @minv10positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 
	union all select 11 as sporttype
					 , 10 as bettype
					 , @minv11positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 
	union all select 99 as sporttype
					 , 10 as bettype
					 , @minv99positiontaking_10 as minpositiontaking
					 , 0 as minlivepositiontaking
	                 
                                                                                                      
  union all select 1 as sporttype
                 , 9999 as bettype
                 , @minpositiontaking_9999 as minpositiontaking
                 , 0 as minlivepositiontaking
--2
  union all select 2 as sporttype
                 , 1 as bettype
                 , @minv2positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 2 as sporttype
                 , 2 as bettype
                 , @minv2positiontaking_2 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 2 as sporttype
                 , 3 as bettype
                 , @minv2positiontaking_3 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 2 as sporttype
                 , 7 as bettype
                 , @minv2positiontaking_7 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 2 as sporttype
                 , 8 as bettype
                 , @minv2positiontaking_8 as minpositiontaking
                 , 0 as minlivepositiontaking

                --union all select     2 as sporttype, 9 as bettype, @minv2positiontaking_9 as minpositiontaking,  0 as minlivepositiontaking

  union all select 2 as sporttype
                 , 20 as bettype
                 , @minv2positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking
 union all select 2 as sporttype
                 , 9999 as bettype
                 , @minv2positiontaking_9999 as minpositiontaking
                 , 0 as minlivepositiontaking                
--3
  union all select 3 as sporttype
                 , 1 as bettype
                 , @minv3positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 3 as sporttype
                 , 2 as bettype
                 , @minv3positiontaking_2 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 3 as sporttype
                 , 3 as bettype
                 , @minv3positiontaking_3 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 3 as sporttype
                 , 20 as bettype
                 , @minv3positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking
--5
  union all select 5 as sporttype
                 , 1 as bettype
                 , @minv5positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 5 as sporttype
                 , 2 as bettype
                 , @minv5positiontaking_2 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 5 as sporttype
                 , 3 as bettype
                 , @minv5positiontaking_3 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 5 as sporttype
                 , 20 as bettype
                 , @minv5positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 5 as sporttype
                 , 9999 as bettype
                 , @minv5positiontaking_9999 as minpositiontaking
                 , 0 as minlivepositiontaking
--8
  union all select 8 as sporttype
                 , 1 as bettype
                 , @minv8positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 8 as sporttype
                 , 3 as bettype
                 , @minv8positiontaking_3 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 8 as sporttype
                 , 20 as bettype
                 , @minv8positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking
--10
  union all select 10 as sporttype
                 , 1 as bettype
                 , @minv10positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 10 as sporttype
                 , 2 as bettype
                 , @minv10positiontaking_2 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 10 as sporttype
                 , 3 as bettype
                 , @minv10positiontaking_3 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 10 as sporttype
                 , 20 as bettype
                 , @minv10positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking
--11             
  union all select 11 as sporttype
                 , 1 as bettype
                 , @minv11positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 11 as sporttype
                 , 20 as bettype
                 , @minv11positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking
--99
  union all select 99 as sporttype
                 , 1 as bettype
                 , @minv99positiontaking_1 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 99 as sporttype
                 , 2 as bettype
                 , @minv99positiontaking_2 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 99 as sporttype
                 , 3 as bettype
                 , @minv99positiontaking_3 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 99 as sporttype
                 , 9 as bettype
                 , @minv99positiontaking_9 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 99 as sporttype
                 , 20 as bettype
                 , @minv99positiontaking_20 as minpositiontaking
                 , 0 as minlivepositiontaking
  union all select 99 as sporttype
                 , 9999 as bettype
                 , @minv99positiontaking_9999 as minpositiontaking
                 , 0 as minlivepositiontaking

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
inner join custsetting as scs with(NOLOCK) on c.srecommend = scs.custid and scs.sporttype = b.sporttype and scs.bettype = b.bettype
      where cs.custid = @custid
        and (cs.mpositiontaking < b.minpositiontaking
             or scs.mpositiontaking < b.minpositiontaking
             or (b.sporttype = 1
                 and b.bettype in (1, 3, 7, 8)
                 and    (cs.mlivepositiontaking < b.minlivepositiontaking
                      or scs.mlivepositiontaking < b.minpositiontaking
                     )
                )
            )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @isvalid = 0
             , @ErrCode = 304

        Select @ErrMsg = case @Language 
                           when 'E' then 'Current account position taking violates new minimum position taking setting' + ' (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](30004, @Language) + ' (' + @ErrAcc + ').'
                         end
        return
    END

    --v161
    select @ErrAcc = ''
    --select top 100 @ErrAcc = @ErrAcc + username +' sporttype: '+ convert(varchar(10),b.sporttype) + ', bet type: ' + convert(varchar(10),b.bettype) + ', '
    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from customer as c with(NOLOCK) 
inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid        
inner join (select 161 as sporttype
                 , 81 as bettype
                 , @minv161positiontaking_81 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 161 as sporttype
                 , 83 as bettype
                 , @minv161positiontaking_83 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 161 as sporttype
                 , 88 as bettype
                 , @minv161positiontaking_88 as minpositiontaking
                 , 0 as minlivepositiontaking

  union all select 161 as sporttype
                 , 85 as bettype
                 , 0 as minpositiontaking
                 , @minv161livepositiontaking_85 as minlivepositiontaking

  union all select 161 as sporttype
                 , 86 as bettype
                 , @minv161positiontaking_86 as minpositiontaking
                 , @minv161livepositiontaking_86 as minlivepositiontaking

  union all select 161 as sporttype
                 , 87 as bettype
                 , 0 as minpositiontaking
                 , @minv161livepositiontaking_87 as minlivepositiontaking

  union all select 161 as sporttype
                 , 89 as bettype
                 , 0 as minpositiontaking
                 , @minv161livepositiontaking_89 as minlivepositiontaking

  union all select 161 as sporttype
                 , 90 as bettype
                 , 0 as minpositiontaking
                 , @minv161livepositiontaking_90 as minlivepositiontaking

           ) as b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
inner join custsetting3rd as scs with(NOLOCK) on scs.custid = c.srecommend and scs.sporttype = b.sporttype and scs.bettype = b.bettype
      where cs.custid = @custid
        and (cs.mpositiontaking < b.minpositiontaking
             or scs.mpositiontaking < b.minpositiontaking
             or (b.sporttype = 161
                 and b.bettype in (85, 86, 87, 89, 90)
                 and    (cs.mlivepositiontaking < b.minlivepositiontaking
                      or scs.mlivepositiontaking < b.minlivepositiontaking
                     )
                )
            )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @isvalid = 0, @ErrCode = 307
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Current account position taking violates new minimum position taking setting' + ' ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](30004,@Language) + ' ('+@ErrAcc+').'
                    end
        return
    END
    
    /*
    --check all (m2+a2) >= n3
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        customer as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
    
                select         1 as sporttype, 1 as bettype, @minpositiontaking_1 as minpositiontaking,  @minlivepositiontaking_1 as minlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @minpositiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @minpositiontaking_3 as minpositiontaking,  @minlivepositiontaking_3 as minlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @minpositiontaking_4 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @minpositiontaking_5 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @minpositiontaking_6 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @minpositiontaking_7 as minpositiontaking,  @minlivepositiontaking_7 as minlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @minpositiontaking_8 as minpositiontaking,  @minlivepositiontaking_8 as minlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @minpositiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @minpositiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 1 as bettype, @minv2positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @minv2positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @minv2positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @minv2positiontaking_7 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @minv2positiontaking_8 as minpositiontaking,  0 as minlivepositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.mrecommend = @custid and c.roleid = 2 and (cs.apositiontaking+cs.mpositiontaking<b.minpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and cs.alivepositiontaking+cs.mlivepositiontaking<b.minlivepositiontaking))
    group by username
    if @ErrAcc<>''
    BEGIN
        select @isvalid = 0, @ErrCode = 305
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Existing agents violate new minimum position taking setting ('+@ErrAcc+').'
                            when 'CS' then N'Existing agents violate new minimum position taking setting ('+@ErrAcc+').'
                            when 'J' then N'Existing agents violate new minimum position taking setting ('+@ErrAcc+').'
                            else N'Existing agents violate new minimum position taking setting ('+@ErrAcc+').'
                    end
        return
    END
    
    --check all (m1+a1) >= n3
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        customer as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
    
                select         1 as sporttype, 1 as bettype, @minpositiontaking_1 as minpositiontaking,  @minlivepositiontaking_1 as minlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @minpositiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @minpositiontaking_3 as minpositiontaking,  @minlivepositiontaking_3 as minlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @minpositiontaking_4 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @minpositiontaking_5 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @minpositiontaking_6 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @minpositiontaking_7 as minpositiontaking,  @minlivepositiontaking_7 as minlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @minpositiontaking_8 as minpositiontaking,  @minlivepositiontaking_8 as minlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @minpositiontaking_9 as minpositiontaking,  0 as minlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @minpositiontaking_10 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 1 as bettype, @minv2positiontaking_1 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @minv2positiontaking_2 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @minv2positiontaking_3 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @minv2positiontaking_7 as minpositiontaking,  0 as minlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @minv2positiontaking_8 as minpositiontaking,  0 as minlivepositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.mrecommend = @custid and c.roleid = 1 and (cs.mpositiontaking+cs.apositiontaking<b.minpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and cs.mlivepositiontaking+cs.alivepositiontaking<b.minlivepositiontaking))
    group by username
    if @ErrAcc<>''
    BEGIN
        select @isvalid = 0, @ErrCode = 306
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Existing members violate new minimum position taking setting ('+@ErrAcc+').'
                            when 'CS' then N'Existing members violate new minimum position taking setting ('+@ErrAcc+').'
                            when 'J' then N'Existing members violate new minimum position taking setting ('+@ErrAcc+').'
                            else N'Existing members violate new minimum position taking setting ('+@ErrAcc+').'
                    end
        return
    END
    */

END
GO 

 GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpd_CheckParam_MAg] TO [bodbAdminNet]
GO 
