USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperHR_Positiontaking]    Script Date: 06/10/2015 15:49:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperHR_Positiontaking    Script Date: 8/28/2014 2:05:36 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperHR_Positiontaking    Script Date: 8/21/2014 3:12:20 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperHR_Positiontaking    Script Date: 8/21/2014 2:58:12 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperHR_Positiontaking]
    @custid int,-- superid    
    @v151spositiontaking_31 smallmoney = 0.5,
    @v151spositiontaking_32 smallmoney = 0.5,
    @v151spositiontaking_41 smallmoney = 0.5,
    @v151spositiontaking_42 smallmoney = 0.5,

    @v151spositiontaking_51 smallmoney = 0.5,
    @v151spositiontaking_52 smallmoney = 0.5,

    @v152spositiontaking_41 smallmoney = 0.5,
    @v152spositiontaking_42 smallmoney = 0.5,
    @v152spositiontaking_51 smallmoney = 0.5,
    @v152spositiontaking_52 smallmoney = 0.5,

    @v153spositiontaking_51 smallmoney = 0.5,
    @v153spositiontaking_52 smallmoney = 0.5,
    
    @v151mpositiontaking_31 smallmoney = 0.5,
    @v151mpositiontaking_32 smallmoney = 0.5,
    @v151mpositiontaking_41 smallmoney = 0.5,
    @v151mpositiontaking_42 smallmoney = 0.5,
    @v151mpositiontaking_51 smallmoney = 0.5,
    @v151mpositiontaking_52 smallmoney = 0.5,

    @v152mpositiontaking_41 smallmoney = 0.5,
    @v152mpositiontaking_42 smallmoney = 0.5,
    @v152mpositiontaking_51 smallmoney = 0.5,
    @v152mpositiontaking_52 smallmoney = 0.5,

    @v153mpositiontaking_51 smallmoney = 0.5,
    @v153mpositiontaking_52 smallmoney = 0.5,

    @v151apositiontaking_31 smallmoney = 0.5,
    @v151apositiontaking_32 smallmoney = 0.5,
    @v151apositiontaking_41 smallmoney = 0.5,
    @v151apositiontaking_42 smallmoney = 0.5,
    @v151apositiontaking_51 smallmoney = 0.5,
    @v151apositiontaking_52 smallmoney = 0.5,

    @v152apositiontaking_41 smallmoney = 0.5,
    @v152apositiontaking_42 smallmoney = 0.5,
    @v152apositiontaking_51 smallmoney = 0.5,
    @v152apositiontaking_52 smallmoney = 0.5,

    @v153apositiontaking_51 smallmoney = 0.5,
    @v153apositiontaking_52 smallmoney = 0.5,
    
    @v151IBCPositiontaking_31 smallmoney = 0,--Auto PT for IBC(tote) 
    @v151IBCPositiontaking_41 smallmoney = 0,--Auto PT for IBC(fixed odd) 
    @v151IBCPositiontaking_51 smallmoney = 0,
    @v152IBCPositiontaking_41 smallmoney = 0,
    @v152IBCPositiontaking_51 smallmoney = 0,
    @v153IBCPositiontaking_51 smallmoney = 0,

    @UserID int = 0,    
    @Language varchar(2) = 'E',
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090513@Phuc
Task : Update HR's Super PT 
DB: DBTXN/bodb02

Revisions:
    - 20090529@Phuc: check m1+a1<=m4, a1<=a4
    - 20090917@Phuc: write log into DBLOG.
    - 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
    - 20100112@Kiwi: Amend to write log in xml format.
    - 20101019@Henry: Record execution time
    - 20110120@Lukas: Add setting
                    + AU Horse racing
                    + UK, AU Greyhound racing
                    + AU Harness racing
    - 20110331@Lukas: include sport name to error message
    - 20110511@Johnson: Write log for old setting
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130227@Johnson: write log on DBTXN if DBLOG failure
    - 20131105@Johnson: Apply execrep when update pt on members
                and check total downlines before UPDATEs 
    - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
    - 20140814@Logan:   1. Exclude disabled agents, members while updating super PT
                        2. Code aligning
	- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines, temp sport, bettype table) [Redmine:#36216]
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON

    declare @startRun datetime
    declare @endRun datetime
    declare @duration int
    set @startRun = getdate()

    Declare @username varchar(40)
    select @username = username from custinfo with (NOLOCK) where custid = @custid
    --------------------------------------------------------------------------------------------
    --Check Param
    Declare @ErrAcc nvarchar(4000)
    declare @ErrType varchar(1000)
	
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
	
    ---- Johnson@20131105: Checking total downlines before UPDATEs 
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
        @roleid=4,
        @isExecRep=1,
        @isUpdatePT = 1,
        @Sporttype = 1,
        @Language='E',
        @ErrMsg=@ErrMsg output,
        @ErrCode=@ErrCode output
    IF    @ErrCode <> 0 
        RETURN 
        
    if     @v151spositiontaking_31 < 0
        or @v151spositiontaking_32 < 0
        or @v151spositiontaking_41 < 0
        or @v151spositiontaking_42 < 0
        or @v151spositiontaking_51 < 0
        or @v151spositiontaking_52 < 0
        or @v152spositiontaking_41 < 0
        or @v152spositiontaking_42 < 0
        or @v152spositiontaking_51 < 0
        or @v152spositiontaking_52 < 0
        or @v153spositiontaking_51 < 0
        or @v153spositiontaking_52 < 0        
        
        or @v151mpositiontaking_31 < 0
        or @v151mpositiontaking_32 < 0
        or @v151mpositiontaking_41 < 0
        or @v151mpositiontaking_42 < 0
        or @v151mpositiontaking_51 < 0
        or @v151mpositiontaking_52 < 0
        or @v152mpositiontaking_41 < 0
        or @v152mpositiontaking_42 < 0
        or @v152mpositiontaking_51 < 0
        or @v152mpositiontaking_52 < 0
        or @v153mpositiontaking_51 < 0
        or @v153mpositiontaking_52 < 0

        or @v151apositiontaking_31 < 0
        or @v151apositiontaking_32 < 0
        or @v151apositiontaking_41 < 0
        or @v151apositiontaking_42 < 0
        or @v151apositiontaking_51 < 0
        or @v151apositiontaking_52 < 0
        or @v152apositiontaking_41 < 0
        or @v152apositiontaking_42 < 0
        or @v152apositiontaking_51 < 0
        or @v152apositiontaking_52 < 0
        or @v153apositiontaking_51 < 0
        or @v153apositiontaking_52 < 0
        
        or @v151IBCPositiontaking_31 < 0
        or @v151IBCPositiontaking_41 < 0
        or @v151IBCPositiontaking_51 < 0
        or @v152IBCPositiontaking_41 < 0
        or @v152IBCPositiontaking_51 < 0
        or @v153IBCPositiontaking_51 < 0    
        
        or @v151spositiontaking_31 > 0.5
        or @v151spositiontaking_32 > 0.5
        or @v151spositiontaking_41 > 0.5
        or @v151spositiontaking_42 > 0.5
        or @v151spositiontaking_51 > 0.5
        or @v151spositiontaking_52 > 0.5
        or @v152spositiontaking_41 > 0.5
        or @v152spositiontaking_42 > 0.5
        or @v152spositiontaking_51 > 0.5
        or @v152spositiontaking_52 > 0.5
        or @v153spositiontaking_51 > 0.5
        or @v153spositiontaking_52 > 0.5
        
        or @v151mpositiontaking_31 > 0.5
        or @v151mpositiontaking_32 > 0.5
        or @v151mpositiontaking_41 > 0.5
        or @v151mpositiontaking_42 > 0.5
        or @v151mpositiontaking_51 > 0.5
        or @v151mpositiontaking_52 > 0.5
        or @v152mpositiontaking_41 > 0.5
        or @v152mpositiontaking_42 > 0.5
        or @v152mpositiontaking_51 > 0.5
        or @v152mpositiontaking_52 > 0.5
        or @v153mpositiontaking_51 > 0.5
        or @v153mpositiontaking_52 > 0.5

        or @v151apositiontaking_31 > 0.5
        or @v151apositiontaking_32 > 0.5
        or @v151apositiontaking_41 > 0.5
        or @v151apositiontaking_42 > 0.5
        or @v151apositiontaking_51 > 0.5
        or @v151apositiontaking_52 > 0.5
        or @v152apositiontaking_41 > 0.5
        or @v152apositiontaking_42 > 0.5
        or @v152apositiontaking_51 > 0.5
        or @v152apositiontaking_52 > 0.5
        or @v153apositiontaking_51 > 0.5
        or @v153apositiontaking_52 > 0.5
        
        or @v151spositiontaking_31 < @v151mpositiontaking_31
        or @v151spositiontaking_32 < @v151mpositiontaking_32
        or @v151spositiontaking_41 < @v151mpositiontaking_41
        or @v151spositiontaking_42 < @v151mpositiontaking_42
        or @v151spositiontaking_51 < @v151mpositiontaking_51
        or @v151spositiontaking_52 < @v151mpositiontaking_52
        or @v152spositiontaking_41 < @v152mpositiontaking_41
        or @v152spositiontaking_42 < @v152mpositiontaking_42
        or @v152spositiontaking_51 < @v152mpositiontaking_51
        or @v152spositiontaking_52 < @v152mpositiontaking_52
        or @v153spositiontaking_51 < @v153mpositiontaking_51
        or @v153spositiontaking_52 < @v153mpositiontaking_52
        
        or @v151mpositiontaking_31 < @v151apositiontaking_31
        or @v151mpositiontaking_32 < @v151apositiontaking_32
        or @v151mpositiontaking_41 < @v151apositiontaking_41
        or @v151mpositiontaking_42 < @v151apositiontaking_42
        or @v151mpositiontaking_51 < @v151apositiontaking_51
        or @v151mpositiontaking_52 < @v151apositiontaking_52
        or @v152mpositiontaking_41 < @v152apositiontaking_41
        or @v152mpositiontaking_42 < @v152apositiontaking_42
        or @v152mpositiontaking_51 < @v152apositiontaking_51
        or @v152mpositiontaking_52 < @v152apositiontaking_52
        or @v153mpositiontaking_51 < @v153apositiontaking_51
        or @v153mpositiontaking_52 < @v153apositiontaking_52
    BEGIN
        
        Select @ErrMsg = @username + ': ' +
                    case @Language 
                            when 'E' then 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    end, @ErrCode = 101
        return
    END

    --check n4<=s4
        select @ErrType = ''
        select @ErrType = @ErrType + s.SportName + ' - ' +
        case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end  + 
        '-Min: '+ cast((co.minpositiontaking) as varchar(10)) + '<br>'
        from CustOverride3rd as co with (NOLOCK) 
        inner join
        (
                        select 31 as bettype, 151 as sporttype, @v151spositiontaking_31 as spositiontaking
            union all     select 32 as bettype, 151 as sporttype, @v151spositiontaking_32 as spositiontaking
            union all     select 41 as bettype, 151 as sporttype, @v151spositiontaking_41 as spositiontaking
            union all     select 42 as bettype, 151 as sporttype, @v151spositiontaking_42 as spositiontaking
            union all     select 51 as bettype, 151 as sporttype, @v151spositiontaking_51 as spositiontaking
            union all     select 52 as bettype, 151 as sporttype, @v151spositiontaking_52 as spositiontaking
            union all     select 41 as bettype, 152 as sporttype, @v152spositiontaking_41 as spositiontaking
            union all     select 42 as bettype, 152 as sporttype, @v152spositiontaking_42 as spositiontaking
            union all     select 51 as bettype, 152 as sporttype, @v152spositiontaking_51 as spositiontaking
            union all     select 52 as bettype, 152 as sporttype, @v152spositiontaking_52 as spositiontaking
            union all     select 51 as bettype, 153 as sporttype, @v153spositiontaking_51 as spositiontaking
            union all     select 52 as bettype, 153 as sporttype, @v153spositiontaking_52 as spositiontaking
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_sports s on co.sporttype = s.sporttype
    where co.custid = @custid and (b.spositiontaking<co.minpositiontaking) 

    if @ErrType <>''
    BEGIN
        Select @ErrMsg = @username + ': ' +
                    case @Language 
                            when 'E' then 'Wrong position taking (min set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20006,@Language) + '<br>' + @ErrType
                    end, @ErrCode = 102
        return
    END
    select 'here'
    --check all s3+m3<=s4 if i3 = 0,
    --m3<=s4 and u3<=s4 if i3=1
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        custinfo as c with (NOLOCK) 
        inner join CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
                          select     151 as sporttype, 31 as bettype, @v151spositiontaking_31 as maxpositiontaking
                union all select     151 as sporttype, 32 as bettype, @v151spositiontaking_32 as maxpositiontaking
                union all select     151 as sporttype, 41 as bettype, @v151spositiontaking_41 as maxpositiontaking
                union all select     151 as sporttype, 42 as bettype, @v151spositiontaking_42 as maxpositiontaking
                union all select     151 as sporttype, 51 as bettype, @v151spositiontaking_51 as maxpositiontaking
                union all select     151 as sporttype, 52 as bettype, @v151spositiontaking_52 as maxpositiontaking
                union all select     152 as sporttype, 41 as bettype, @v152spositiontaking_41 as maxpositiontaking
                union all select     152 as sporttype, 42 as bettype, @v152spositiontaking_42 as maxpositiontaking
                union all select     152 as sporttype, 51 as bettype, @v152spositiontaking_51 as maxpositiontaking
                union all select     152 as sporttype, 52 as bettype, @v152spositiontaking_52 as maxpositiontaking
                union all select     153 as sporttype, 51 as bettype, @v153spositiontaking_51 as maxpositiontaking
                union all select     153 as sporttype, 52 as bettype, @v153spositiontaking_52 as maxpositiontaking
            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.srecommend = @custid and c.roleid = 3 and (
                            ((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) 
                        )
    group by username
    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg = @username + ': ' +
                    case @Language 
                            when 'E' then 'Existing masters exceeded new super position taking ('+@ErrAcc+').'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20013,@Language) + ' ('+@ErrAcc+').'
                    end, @ErrCode = 103
        return
    END
    --check all s1+m1+a1 <= s4
    --check all u1<=s4 if i1=1
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 151 AS sporttype
                 , 31 AS bettype
                 , @v151spositiontaking_31 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 32 AS bettype
                 , @v151spositiontaking_32 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 41 AS bettype
                 , @v151spositiontaking_41 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 42 AS bettype
                 , @v151spositiontaking_42 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 51 AS bettype
                 , @v151spositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 52 AS bettype
                 , @v151spositiontaking_52 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 41 AS bettype
                 , @v152spositiontaking_41 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 42 AS bettype
                 , @v152spositiontaking_42 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 51 AS bettype
                 , @v152spositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 52 AS bettype
                 , @v152spositiontaking_52 AS maxpositiontaking

  UNION ALL SELECT 153 AS sporttype
                 , 51 AS bettype
                 , @v153spositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 153 AS sporttype
                 , 52 AS bettype
                 , @v153spositiontaking_52 AS maxpositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > b.maxpositiontaking
            OR (cs.isautopositiontaking = 1
                AND cs.autopositiontaking > b.maxpositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @username + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20014,@Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 104
        RETURN
    END
    --------------------------------------------------------------------------------------------
    --Check all m1+a1<=m4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username +', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 151 AS sporttype
                 , 31 AS bettype
                 , @v151mpositiontaking_31 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 32 AS bettype
                 , @v151mpositiontaking_32 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 41 AS bettype
                 , @v151mpositiontaking_41 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 42 AS bettype
                 , @v151mpositiontaking_42 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 51 AS bettype
                 , @v151mpositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 52 AS bettype
                 , @v151mpositiontaking_52 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 41 AS bettype
                 , @v152mpositiontaking_41 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 42 AS bettype
                 , @v152mpositiontaking_42 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 51 AS bettype
                 , @v152mpositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 52 AS bettype
                 , @v152mpositiontaking_52 AS maxpositiontaking

  UNION ALL SELECT 153 AS sporttype
                 , 51 AS bettype
                 , @v153mpositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 153 AS sporttype
                 , 52 AS bettype
                 , @v153mpositiontaking_52 AS maxpositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.mpositiontaking + cs.apositiontaking > b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @username + ': '
                       + CASE @Language

                           WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                          END
              , @ErrCode = 108
        RETURN
    END

    --Check all a1<=a4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 151 AS sporttype
                 , 31 AS bettype
                 , @v151apositiontaking_31 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 32 AS bettype
                 , @v151apositiontaking_32 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 41 AS bettype
                 , @v151apositiontaking_41 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 42 AS bettype
                 , @v151apositiontaking_42 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 51 AS bettype
                 , @v151apositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 151 AS sporttype
                 , 52 AS bettype
                 , @v151apositiontaking_52 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 41 AS bettype
                 , @v152apositiontaking_41 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 42 AS bettype
                 , @v152apositiontaking_42 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 51 AS bettype
                 , @v152apositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 152 AS sporttype
                 , 52 AS bettype
                 , @v152apositiontaking_52 AS maxpositiontaking

  UNION ALL SELECT 153 AS sporttype
                 , 51 AS bettype
                 , @v153apositiontaking_51 AS maxpositiontaking

  UNION ALL SELECT 153 AS sporttype
                 , 52 AS bettype
                 , @v153apositiontaking_52 AS maxpositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.apositiontaking>b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @username + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing members exceeded new agent position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20017, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 109
        RETURN
    END

    DECLARE @db_v151spositiontaking_31 smallmoney,
        @db_v151spositiontaking_32 smallmoney ,
        @db_v151spositiontaking_41 smallmoney ,
        @db_v151spositiontaking_42 smallmoney ,
        @db_v151spositiontaking_51 smallmoney ,
        @db_v151spositiontaking_52 smallmoney ,
        @db_v152spositiontaking_41 smallmoney ,
        @db_v152spositiontaking_42 smallmoney ,
        @db_v152spositiontaking_51 smallmoney ,
        @db_v152spositiontaking_52 smallmoney ,
        @db_v153spositiontaking_51 smallmoney ,
        @db_v153spositiontaking_52 smallmoney ,
        
        @db_v151mpositiontaking_31 smallmoney ,
        @db_v151mpositiontaking_32 smallmoney ,
        @db_v151mpositiontaking_41 smallmoney ,
        @db_v151mpositiontaking_42 smallmoney ,
        @db_v151mpositiontaking_51 smallmoney ,
        @db_v151mpositiontaking_52 smallmoney ,
        @db_v152mpositiontaking_41 smallmoney ,
        @db_v152mpositiontaking_42 smallmoney ,
        @db_v152mpositiontaking_51 smallmoney ,
        @db_v152mpositiontaking_52 smallmoney ,
        @db_v153mpositiontaking_51 smallmoney ,
        @db_v153mpositiontaking_52 smallmoney ,

        @db_v151apositiontaking_31 smallmoney ,
        @db_v151apositiontaking_32 smallmoney ,
        @db_v151apositiontaking_41 smallmoney ,
        @db_v151apositiontaking_42 smallmoney ,
        @db_v151apositiontaking_51 smallmoney ,
        @db_v151apositiontaking_52 smallmoney ,
        @db_v152apositiontaking_41 smallmoney ,
        @db_v152apositiontaking_42 smallmoney ,
        @db_v152apositiontaking_51 smallmoney ,
        @db_v152apositiontaking_52 smallmoney ,
        @db_v153apositiontaking_51 smallmoney ,
        @db_v153apositiontaking_52 smallmoney ,
        
        @db_v151IBCPositiontaking_31 smallmoney ,
        @db_v151IBCPositiontaking_41 smallmoney ,
        @db_v151IBCPositiontaking_51 smallmoney ,
        @db_v152IBCPositiontaking_41 smallmoney ,
        @db_v152IBCPositiontaking_51 smallmoney ,
        @db_v153IBCPositiontaking_51 smallmoney 
        
    SELECT @db_v151spositiontaking_31 = MAX(case when bettype = 31 and sporttype = 151 then spositiontaking else 0 end),
            @db_v151spositiontaking_32 = MAX(case when bettype = 32 and sporttype = 151 then spositiontaking else 0 end),
            @db_v151spositiontaking_41 = MAX(case when bettype = 41 and sporttype = 151 then spositiontaking else 0 end),
            @db_v151spositiontaking_42 = MAX(case when bettype = 42 and sporttype = 151 then spositiontaking else 0 end),
            @db_v151spositiontaking_51 = MAX(case when bettype = 51 and sporttype = 151 then spositiontaking else 0 end),
            @db_v151spositiontaking_52 = MAX(case when bettype = 52 and sporttype = 151 then spositiontaking else 0 end),
            @db_v152spositiontaking_41 = MAX(case when bettype = 41 and sporttype = 152 then spositiontaking else 0 end),
            @db_v152spositiontaking_42 = MAX(case when bettype = 42 and sporttype = 152 then spositiontaking else 0 end),
            @db_v152spositiontaking_51 = MAX(case when bettype = 51 and sporttype = 152 then spositiontaking else 0 end),
            @db_v152spositiontaking_52 = MAX(case when bettype = 52 and sporttype = 152 then spositiontaking else 0 end),
            @db_v153spositiontaking_51 = MAX(case when bettype = 51 and sporttype = 153 then spositiontaking else 0 end),
            @db_v153spositiontaking_52 = MAX(case when bettype = 52 and sporttype = 153 then spositiontaking else 0 end),
            
            @db_v151mpositiontaking_31 = MAX(case when bettype = 31 and sporttype = 151 then mpositiontaking else 0 end),
            @db_v151mpositiontaking_32 = MAX(case when bettype = 32 and sporttype = 151 then mpositiontaking else 0 end),
            @db_v151mpositiontaking_41 = MAX(case when bettype = 41 and sporttype = 151 then mpositiontaking else 0 end),
            @db_v151mpositiontaking_42 = MAX(case when bettype = 42 and sporttype = 151 then mpositiontaking else 0 end),
            @db_v151mpositiontaking_51 = MAX(case when bettype = 51 and sporttype = 151 then mpositiontaking else 0 end),
            @db_v151mpositiontaking_52 = MAX(case when bettype = 52 and sporttype = 151 then mpositiontaking else 0 end),
            @db_v152mpositiontaking_41 = MAX(case when bettype = 41 and sporttype = 152 then mpositiontaking else 0 end),
            @db_v152mpositiontaking_42 = MAX(case when bettype = 42 and sporttype = 152 then mpositiontaking else 0 end),
            @db_v152mpositiontaking_51 = MAX(case when bettype = 51 and sporttype = 152 then mpositiontaking else 0 end),
            @db_v152mpositiontaking_52 = MAX(case when bettype = 52 and sporttype = 152 then mpositiontaking else 0 end),
            @db_v153mpositiontaking_51 = MAX(case when bettype = 51 and sporttype = 153 then mpositiontaking else 0 end),
            @db_v153mpositiontaking_52 = MAX(case when bettype = 52 and sporttype = 153 then mpositiontaking else 0 end),
            
            @db_v151apositiontaking_31 = MAX(case when bettype = 31 and sporttype = 151 then apositiontaking else 0 end),
            @db_v151apositiontaking_32 = MAX(case when bettype = 32 and sporttype = 151 then apositiontaking else 0 end),
            @db_v151apositiontaking_41 = MAX(case when bettype = 41 and sporttype = 151 then apositiontaking else 0 end),
            @db_v151apositiontaking_42 = MAX(case when bettype = 42 and sporttype = 151 then apositiontaking else 0 end),
            @db_v151apositiontaking_51 = MAX(case when bettype = 51 and sporttype = 151 then apositiontaking else 0 end),
            @db_v151apositiontaking_52 = MAX(case when bettype = 52 and sporttype = 151 then apositiontaking else 0 end),
            @db_v152apositiontaking_41 = MAX(case when bettype = 41 and sporttype = 152 then apositiontaking else 0 end),
            @db_v152apositiontaking_42 = MAX(case when bettype = 42 and sporttype = 152 then apositiontaking else 0 end),
            @db_v152apositiontaking_51 = MAX(case when bettype = 51 and sporttype = 152 then apositiontaking else 0 end),
            @db_v152apositiontaking_52 = MAX(case when bettype = 52 and sporttype = 152 then apositiontaking else 0 end),
            @db_v153apositiontaking_51 = MAX(case when bettype = 51 and sporttype = 153 then apositiontaking else 0 end),
            @db_v153apositiontaking_52 = MAX(case when bettype = 52 and sporttype = 153 then apositiontaking else 0 end)
    FROM custsetting3rd with(nolock)
    WHERE custid = @custid and sporttype between 151 and 153


    update CustSetting3rd with (ROWLOCK, UPDLOCK)
    set
        spositiontaking = case    when bettype = 31 and sporttype = 151 then @v151spositiontaking_31 
                                when bettype = 32 and sporttype = 151 then @v151spositiontaking_32 
                                when bettype = 41 and sporttype = 151 then @v151spositiontaking_41 
                                when bettype = 42 and sporttype = 151 then @v151spositiontaking_42 
                                when bettype = 51 and sporttype = 151 then @v151spositiontaking_51 
                                when bettype = 52 and sporttype = 151 then @v151spositiontaking_52 
                                when bettype = 41 and sporttype = 152 then @v152spositiontaking_41 
                                when bettype = 42 and sporttype = 152 then @v152spositiontaking_42 
                                when bettype = 51 and sporttype = 152 then @v152spositiontaking_51 
                                when bettype = 52 and sporttype = 152 then @v152spositiontaking_52 
                                when bettype = 51 and sporttype = 153 then @v153spositiontaking_51 
                                when bettype = 52 and sporttype = 153 then @v153spositiontaking_52 
                                else spositiontaking end,

        mpositiontaking = case    when bettype = 31 and sporttype = 151 then @v151mpositiontaking_31 
                                when bettype = 32 and sporttype = 151 then @v151mpositiontaking_32 
                                when bettype = 41 and sporttype = 151 then @v151mpositiontaking_41 
                                when bettype = 42 and sporttype = 151 then @v151mpositiontaking_42 
                                when bettype = 51 and sporttype = 151 then @v151mpositiontaking_51 
                                when bettype = 52 and sporttype = 151 then @v151mpositiontaking_52 
                                when bettype = 41 and sporttype = 152 then @v152mpositiontaking_41 
                                when bettype = 42 and sporttype = 152 then @v152mpositiontaking_42 
                                when bettype = 51 and sporttype = 152 then @v152mpositiontaking_51 
                                when bettype = 52 and sporttype = 152 then @v152mpositiontaking_52 
                                when bettype = 51 and sporttype = 153 then @v153mpositiontaking_51 
                                when bettype = 52 and sporttype = 153 then @v153mpositiontaking_52 
                                else mpositiontaking end,

        apositiontaking = case    when bettype = 31 and sporttype = 151 then @v151apositiontaking_31 
                                when bettype = 32 and sporttype = 151 then @v151apositiontaking_32 
                                when bettype = 41 and sporttype = 151 then @v151apositiontaking_41 
                                when bettype = 42 and sporttype = 151 then @v151apositiontaking_42 
                                when bettype = 51 and sporttype = 151 then @v151apositiontaking_51 
                                when bettype = 52 and sporttype = 151 then @v151apositiontaking_52 
                                when bettype = 41 and sporttype = 152 then @v152apositiontaking_41 
                                when bettype = 42 and sporttype = 152 then @v152apositiontaking_42 
                                when bettype = 51 and sporttype = 152 then @v152apositiontaking_51 
                                when bettype = 52 and sporttype = 152 then @v152apositiontaking_52 
                                when bettype = 51 and sporttype = 153 then @v153apositiontaking_51 
                                when bettype = 52 and sporttype = 153 then @v153apositiontaking_52 
                                else apositiontaking end
    where custid=@custid 
        and sporttype between 151 and 153
    if (@@error <> 0)
    begin
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end    , @ErrCode = 105                     
        
        return
    end

    SELECT @db_v151IBCPositiontaking_31 = AutoIBCPositiontaking_tote ,
            @db_v151IBCPositiontaking_41 = AutoIBCpositiontaking_fixed ,
            @db_v151IBCPositiontaking_51 = AutoIBCPT151_AU,
            @db_v152IBCPositiontaking_41 = AutoIBCPT152_UK,
            @db_v152IBCPositiontaking_51 = AutoIBCPT152_AU,
            @db_v153IBCPositiontaking_51 = AutoIBCPT153_AU
    FROM custsuper with(nolock)
    WHERE custid = @custid
         
    update custsuper with(ROWLOCK, UPDLOCK)
    set AutoIBCpositiontaking_tote = @v151IBCPositiontaking_31,
        AutoIBCpositiontaking_fixed = @v151IBCPositiontaking_41,
        AutoIBCPT151_AU = @v151IBCPositiontaking_51,
        AutoIBCPT152_UK = @v152IBCPositiontaking_41,
        AutoIBCPT152_AU = @v152IBCPositiontaking_51,
        AutoIBCPT153_AU = @v153IBCPositiontaking_51
    where custid=@custid


    --exec dbo.Acc_CustomerUpdSuper_AutoPositiontaking @srecommend = @custid
                EXEC dbo.Acc_CustSetting3rd_07 @srecommend = @custid, @roleid = 4, @mode = 'horse' 

    /*
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
        and c.roleid = 1 and cs.sporttype between 151 and 153
        and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)

    if (@@error <> 0)
    begin
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end, @ErrCode = 107    
        return
    end
    */

    --Update l4=s4
    update CustOverride3rd with (ROWLOCK, UPDLOCK)
        set maxpositiontaking = case    when bettype = 31 and sporttype = 151 then @v151spositiontaking_31 
                                        when bettype = 32 and sporttype = 151 then @v151spositiontaking_32 
                                        when bettype = 41 and sporttype = 151 then @v151spositiontaking_41 
                                        when bettype = 42 and sporttype = 151 then @v151spositiontaking_42 
                                        when bettype = 51 and sporttype = 151 then @v151spositiontaking_51 
                                        when bettype = 52 and sporttype = 151 then @v151spositiontaking_52 
                                        when bettype = 41 and sporttype = 152 then @v152spositiontaking_41 
                                        when bettype = 42 and sporttype = 152 then @v152spositiontaking_42 
                                        when bettype = 51 and sporttype = 152 then @v152spositiontaking_51 
                                        when bettype = 52 and sporttype = 152 then @v152spositiontaking_52 
                                        when bettype = 51 and sporttype = 153 then @v153spositiontaking_51 
                                        when bettype = 52 and sporttype = 153 then @v153spositiontaking_52 
                                        else maxpositiontaking end
    where custid = @custid and sporttype between 151 and 153

    if (@@error <> 0)
    begin
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end, @ErrCode = 106             
        
        return
    end




    Declare @LogSPData varchar(MAX),
            @TrackingValueDB varchar(5000)

    Select @LogSPData = '<Acc_CustomerUpdSuperHR_Positiontaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

    '<s v151spt_31="'+ coalesce(cast(@v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151spt_32="'+ coalesce(cast(@v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'v151spt_41="'+ coalesce(cast(@v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151spt_42="'+ coalesce(cast(@v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v151spt_51="'+ coalesce(cast(@v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v151spt_52="'+ coalesce(cast(@v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v152spt_41="'+ coalesce(cast(@v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152spt_42="'+ coalesce(cast(@v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v152spt_51="'+ coalesce(cast(@v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152spt_52="'+ coalesce(cast(@v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v153spt_51="'+ coalesce(cast(@v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153spt_52="'+ coalesce(cast(@v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

    '<m v151mpt_31="'+ coalesce(cast(@v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151mpt_32="'+ coalesce(cast(@v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'v151mpt_41="'+ coalesce(cast(@v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151mpt_42="'+ coalesce(cast(@v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v151mpt_51="'+ coalesce(cast(@v151mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v151mpt_52="'+ coalesce(cast(@v151mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v152mpt_41="'+ coalesce(cast(@v152mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152mpt_42="'+ coalesce(cast(@v152mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v152mpt_51="'+ coalesce(cast(@v152mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152mpt_52="'+ coalesce(cast(@v152mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v153mpt_51="'+ coalesce(cast(@v153mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" />' +

    '<ag v151apt_31="'+ coalesce(cast(@v151apositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151apt_32="'+ coalesce(cast(@v151apositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'v151apt_41="'+ coalesce(cast(@v151apositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151apt_42="'+ coalesce(cast(@v151apositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v151apt_51="'+ coalesce(cast(@v151apositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v151apt_52="'+ coalesce(cast(@v151apositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v152apt_41="'+ coalesce(cast(@v152apositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152apt_42="'+ coalesce(cast(@v152apositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v152apt_51="'+ coalesce(cast(@v152apositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152apt_52="'+ coalesce(cast(@v152apositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v153apt_51="'+ coalesce(cast(@v153apositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153apt_52="'+ coalesce(cast(@v153apositiontaking_52 as varchar(50)),space(1)) + '" />' +

    '<ibcpt v151IBCpt_31="'+ coalesce(cast(@v151IBCPositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151IBCpt_41="' + coalesce(cast(@v151IBCPositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151IBCpt_51="' + coalesce(cast(@v151IBCPositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152IBCpt_41="' + coalesce(cast(@v152IBCPositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152IBCpt_51="' + coalesce(cast(@v152IBCPositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153IBCpt_51="' + coalesce(cast(@v153IBCPositiontaking_51 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuperHR_Positiontaking>'


    Select @TrackingValueDB = '<Acc_CustomerUpdSuperHR_Positiontaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

    '<s v151spt_31="'+ coalesce(cast(@db_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151spt_32="'+ coalesce(cast(@db_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'v151spt_41="'+ coalesce(cast(@db_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151spt_42="'+ coalesce(cast(@db_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v151spt_51="'+ coalesce(cast(@db_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v151spt_52="'+ coalesce(cast(@db_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v152spt_41="'+ coalesce(cast(@db_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152spt_42="'+ coalesce(cast(@db_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v152spt_51="'+ coalesce(cast(@db_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152spt_52="'+ coalesce(cast(@db_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v153spt_51="'+ coalesce(cast(@db_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153spt_52="'+ coalesce(cast(@db_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

    '<m v151mpt_31="'+ coalesce(cast(@db_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151mpt_32="'+ coalesce(cast(@db_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'v151mpt_41="'+ coalesce(cast(@db_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151mpt_42="'+ coalesce(cast(@db_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v151mpt_51="'+ coalesce(cast(@db_v151mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v151mpt_52="'+ coalesce(cast(@db_v151mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v152mpt_41="'+ coalesce(cast(@db_v152mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152mpt_42="'+ coalesce(cast(@db_v152mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v152mpt_51="'+ coalesce(cast(@db_v152mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152mpt_52="'+ coalesce(cast(@db_v152mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v153mpt_51="'+ coalesce(cast(@db_v153mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153mpt_52="'+ coalesce(cast(@db_v153mpositiontaking_52 as varchar(50)),space(1)) + '" />' +

    '<ag v151apt_31="'+ coalesce(cast(@db_v151apositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151apt_32="'+ coalesce(cast(@db_v151apositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'v151apt_41="'+ coalesce(cast(@db_v151apositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151apt_42="'+ coalesce(cast(@db_v151apositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v151apt_51="'+ coalesce(cast(@db_v151apositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v151apt_52="'+ coalesce(cast(@db_v151apositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v152apt_41="'+ coalesce(cast(@db_v152apositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152apt_42="'+ coalesce(cast(@db_v152apositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'v152apt_51="'+ coalesce(cast(@db_v152apositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152apt_52="'+ coalesce(cast(@db_v152apositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'v153apt_51="'+ coalesce(cast(@db_v153apositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153apt_52="'+ coalesce(cast(@db_v153apositiontaking_52 as varchar(50)),space(1)) + '" />' +

    '<ibcpt v151IBCpt_31="'+ coalesce(cast(@db_v151IBCPositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'v151IBCpt_41="' + coalesce(cast(@db_v151IBCPositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v151IBCpt_51="' + coalesce(cast(@db_v151IBCPositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v152IBCpt_41="' + coalesce(cast(@db_v152IBCPositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'v152IBCpt_51="' + coalesce(cast(@db_v152IBCPositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'v153IBCpt_51="' + coalesce(cast(@db_v153IBCPositiontaking_51 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuperHR_Positiontaking>'

    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)

    --Log positiontaking
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 418,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        Select @LogSPData = '<Acc_CustomerUpdSuperHR_Positiontaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />' +

        '<s v151spt_31="'+ coalesce(cast(@v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
        'v151spt_32="'+ coalesce(cast(@v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
        'v151spt_41="'+ coalesce(cast(@v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v151spt_42="'+ coalesce(cast(@v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
        'v151spt_51="'+ coalesce(cast(@v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v151spt_52="'+ coalesce(cast(@v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
        'v152spt_41="'+ coalesce(cast(@v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v152spt_42="'+ coalesce(cast(@v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
        'v152spt_51="'+ coalesce(cast(@v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v152spt_52="'+ coalesce(cast(@v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
        'v153spt_51="'+ coalesce(cast(@v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v153spt_52="'+ coalesce(cast(@v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

        '<m v151mpt_31="'+ coalesce(cast(@v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
        'v151mpt_32="'+ coalesce(cast(@v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
        'v151mpt_41="'+ coalesce(cast(@v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v151mpt_42="'+ coalesce(cast(@v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
        'v151mpt_51="'+ coalesce(cast(@v151mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v151mpt_52="'+ coalesce(cast(@v151mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
        'v152mpt_41="'+ coalesce(cast(@v152mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v152mpt_42="'+ coalesce(cast(@v152mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
        'v152mpt_51="'+ coalesce(cast(@v152mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v152mpt_52="'+ coalesce(cast(@v152mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
        'v153mpt_51="'+ coalesce(cast(@v153mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" />' +

        '<ag v151apt_31="'+ coalesce(cast(@v151apositiontaking_31 as varchar(50)),space(1)) + '" ' +
        'v151apt_32="'+ coalesce(cast(@v151apositiontaking_32 as varchar(50)),space(1)) + '" ' +
        'v151apt_41="'+ coalesce(cast(@v151apositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v151apt_42="'+ coalesce(cast(@v151apositiontaking_42 as varchar(50)),space(1)) + '" ' +
        'v151apt_51="'+ coalesce(cast(@v151apositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v151apt_52="'+ coalesce(cast(@v151apositiontaking_52 as varchar(50)),space(1)) + '" ' +
        'v152apt_41="'+ coalesce(cast(@v152apositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v152apt_42="'+ coalesce(cast(@v152apositiontaking_42 as varchar(50)),space(1)) + '" ' +
        'v152apt_51="'+ coalesce(cast(@v152apositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v152apt_52="'+ coalesce(cast(@v152apositiontaking_52 as varchar(50)),space(1)) + '" ' +
        'v153apt_51="'+ coalesce(cast(@v153apositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v153apt_52="'+ coalesce(cast(@v153apositiontaking_52 as varchar(50)),space(1)) + '" />' +

        '<ibcpt v151IBCpt_31="'+ coalesce(cast(@v151IBCPositiontaking_31 as varchar(50)),space(1)) + '" ' +
        'v151IBCpt_41="' + coalesce(cast(@v151IBCPositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v151IBCpt_51="' + coalesce(cast(@v151IBCPositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v152IBCpt_41="' + coalesce(cast(@v152IBCPositiontaking_41 as varchar(50)),space(1)) + '" ' +
        'v152IBCpt_51="' + coalesce(cast(@v152IBCPositiontaking_51 as varchar(50)),space(1)) + '" ' +
        'v153IBCpt_51="' + coalesce(cast(@v153IBCPositiontaking_51 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdSuperHR_Positiontaking>'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 418,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperHR_Positiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperHR_Positiontaking] TO [vnteam] AS [dbo]