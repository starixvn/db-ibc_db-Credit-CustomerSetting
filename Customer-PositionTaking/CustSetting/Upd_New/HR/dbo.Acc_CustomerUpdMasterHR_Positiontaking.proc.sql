ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterHR_Positiontaking]
    @custid int,-- masterid    
    @v151spositiontaking_31 smallmoney,
    @v151spositiontaking_32 smallmoney,
    @v151spositiontaking_41 smallmoney,
    @v151spositiontaking_42 smallmoney,
    @v151spositiontaking_51 smallmoney = 0,
    @v151spositiontaking_52 smallmoney = 0,
    @v152spositiontaking_41 smallmoney = 0,
    @v152spositiontaking_42 smallmoney = 0,
    @v152spositiontaking_51 smallmoney = 0,
    @v152spositiontaking_52 smallmoney = 0,
    @v153spositiontaking_51 smallmoney = 0,
    @v153spositiontaking_52 smallmoney = 0,

    @auto_v151spositiontaking_31 smallmoney = 0,
    @auto_v151spositiontaking_32 smallmoney = 0,
    @auto_v151spositiontaking_41 smallmoney = 0,
    @auto_v151spositiontaking_42 smallmoney = 0,
    @auto_v151spositiontaking_51 smallmoney = 0,
    @auto_v151spositiontaking_52 smallmoney = 0,
    @auto_v152spositiontaking_41 smallmoney = 0,
    @auto_v152spositiontaking_42 smallmoney = 0,
    @auto_v152spositiontaking_51 smallmoney = 0,
    @auto_v152spositiontaking_52 smallmoney = 0,
    @auto_v153spositiontaking_51 smallmoney = 0,
    @auto_v153spositiontaking_52 smallmoney = 0,
    
    @isauto_v151spositiontaking_31 bit = 0,
    @isauto_v151spositiontaking_32 bit = 0,
    @isauto_v151spositiontaking_41 bit = 0,
    @isauto_v151spositiontaking_42 bit = 0,
    @isauto_v151spositiontaking_51 bit = 0,
    @isauto_v151spositiontaking_52 bit = 0,
    @isauto_v152spositiontaking_41 bit = 0,
    @isauto_v152spositiontaking_42 bit = 0,
    @isauto_v152spositiontaking_51 bit = 0,
    @isauto_v152spositiontaking_52 bit = 0,
    @isauto_v153spositiontaking_51 bit = 0,
    @isauto_v153spositiontaking_52 bit = 0,
    
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
    
    @IsCopyPreset151_31 bit = 0,--@IsCopyPreset_31 -> @IsCopyPreset151_31 Use for copy preset to member
    @IsCopyPreset151_41 bit = 0,--@IsCopyPreset_41 -> @IsCopyPreset151_41 Use for copy preset to member
    @IsCopyPreset151_51 bit = 0,--@IsCopyPreset_51 -> @IsCopyPreset151_51 Use for copy preset to member
    @IsCopyPreset152_41 bit = 0,
    @IsCopyPreset152_51 bit = 0,
    @IsCopyPreset153_51 bit = 0,
    
    @UpdateMultiple BIT = 0,
    @UpdatePositiontakingv151_31 BIT = 1,
    @UpdatePositiontakingv151_41 BIT = 1,
    @UpdatePositiontakingv151_51 BIT = 1,
    @UpdatePositiontakingv152_41 BIT = 1,
    @UpdatePositiontakingv152_51 BIT = 1,
    @UpdatePositiontakingv153_51 BIT = 1,
    
    @updateallmembers bit = 0,--Use for auto PT
    @newspositiontaking smallmoney = 0,--equals max(s+m) - chosen(m)
    @SubAccID int = 0, --Sub-AccountID    
    @UserID int = 0,    
    @Language varchar(2) = 'E',
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
as

--@Source Control
/*
Created: 20090514@Phuc
Task : Update HR's Master Position Taking
DB: DBTXN/bodb02
Original: Acc_CustomerUpdEditCustomer_SAg

Revisions:
    - 20090610@Phuc: copy super preset to member(s3->s1).
    - 20090628@Phuc: auto master PT on member level.
                    Write log subaccname instead of subaccid.
    - 20090917@Phuc: write log into DBLOG.
    - 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
    - 20100112@Kiwi: Amend to write log in xml format.
    - 20101019@Henry: Record execution time
    - 20110129@Henry: Add setting  
      + AU Horse racing  
      + UK, AU Greyhound racing  
      + AU Harness racing 
    - 20110331@Lukas: include sport name to error message
    - 20111018@TOM: Apply Multiple Edit Racing PT.
    - 20111114@TOM: Add parameter input @UpdatePositiontakingv151_31 => _51
                                @UpdatePositiontakingv152_41 => _51
                    Check edit multiple PT.
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130226@Johnson: write log on DBTXN if DBLOG failure
    - 20130418@Johnson: check auto positiontaking negative
    - 20131010@Johnson: fix wrong call table custoverride3rd instead of custoverride
    - 20131105@Johnson: Apply execrep when update pt on members
            and check total downlines before UPDATEs 
    - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
    - 20140729@Logan: 1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                      2.Code aligning on modified parts
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, Use temp table for sports, bettype table)

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

declare @ErrAcc varchar(4000), @ErrType varchar(4000)
declare @UserName nvarchar(20), @srecommend int,
        @maxpos smallmoney,    @maxdownlinepos smallmoney

EXEC Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
    @roleid=3,
    @isExecRep=1,
    @isUpdatePT = 1,
    @Sporttype = 1,
    @Language='E',
    @ErrMsg=@ErrMsg output,
    @ErrCode=@ErrCode output
IF    @ErrCode <> 0 
    RETURN 

        
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @UserName  = username, @srecommend = srecommend 
from custinfo with (NOLOCK) 
where CustID = @CustID

Select @maxpos = 0.5, @maxdownlinepos = 0 --Max pos for HR = 0.5
-- th: @maxpos and @maxdownlinepos are no longer used
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--v201
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151
    if 
        ((@v151spositiontaking_31 <0
        or @v151spositiontaking_32 <0
        or @v151mpositiontaking_31 <0
        or @v151mpositiontaking_32 <0
        or @auto_v151spositiontaking_31 < 0
        or @auto_v151spositiontaking_32 < 0 
        or @auto_v151spositiontaking_31  >@maxpos
        or @auto_v151spositiontaking_32  >@maxpos
        or @v151spositiontaking_31+@v151mpositiontaking_31 >@maxpos
        or @v151spositiontaking_32+@v151mpositiontaking_32 >@maxpos        )
        and @UpdatePositiontakingv151_31 = 1    ) 
        
        or ((@v151mpositiontaking_41 <0
        or @v151mpositiontaking_42 <0                
        or @v151spositiontaking_41 <0
        or @v151spositiontaking_42 <0
        or @auto_v151spositiontaking_41 < 0
        or @auto_v151spositiontaking_42 < 0
        or @auto_v151spositiontaking_41  >@maxpos
        or @auto_v151spositiontaking_42  >@maxpos
        or @v151spositiontaking_41+@v151mpositiontaking_41 >@maxpos
        or @v151spositiontaking_42+@v151mpositiontaking_42 >@maxpos        )
        and @UpdatePositiontakingv151_41 = 1    ) 
                
        or ((@v151spositiontaking_51 <0
        or @v151spositiontaking_52 <0
        or @v151mpositiontaking_51 <0
        or @v151mpositiontaking_52 <0
        or @auto_v151spositiontaking_51 < 0
        or @auto_v151spositiontaking_52 < 0
        or @auto_v151spositiontaking_51  >@maxpos
        or @auto_v151spositiontaking_52  >@maxpos
        or @v151spositiontaking_51+@v151mpositiontaking_51 >@maxpos
        or @v151spositiontaking_52+@v151mpositiontaking_52 >@maxpos        )
        and @UpdatePositiontakingv151_51 = 1    )
        
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg = @UserName + ': ' + 
                    case @Language 
                            when 'E' then 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
    + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
    from custoverride3rd as co with (NOLOCK) inner join
        (
                         select 31 as bettype, 151 as sporttype, @v151spositiontaking_31 as spositiontaking, @v151mpositiontaking_31 as mpositiontaking, @isauto_v151spositiontaking_31 as isauto_spositiontaking, @auto_v151spositiontaking_31 as auto_spositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all    select 32 as bettype, 151 as sporttype, @v151spositiontaking_32 as spositiontaking, @v151mpositiontaking_32 as mpositiontaking, @isauto_v151spositiontaking_32 as isauto_spositiontaking, @auto_v151spositiontaking_32 as auto_spositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all    select 41 as bettype, 151 as sporttype, @v151spositiontaking_41 as spositiontaking, @v151mpositiontaking_41 as mpositiontaking, @isauto_v151spositiontaking_41 as isauto_spositiontaking, @auto_v151spositiontaking_41 as auto_spositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all    select 42 as bettype, 151 as sporttype, @v151spositiontaking_42 as spositiontaking, @v151mpositiontaking_42 as mpositiontaking, @isauto_v151spositiontaking_42 as isauto_spositiontaking, @auto_v151spositiontaking_42 as auto_spositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all    select 51 as bettype, 151 as sporttype, @v151spositiontaking_51 as spositiontaking, @v151mpositiontaking_51 as mpositiontaking, @isauto_v151spositiontaking_51 as isauto_spositiontaking, @auto_v151spositiontaking_51 as auto_spositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all    select 52 as bettype, 151 as sporttype, @v151spositiontaking_52 as spositiontaking, @v151mpositiontaking_52 as mpositiontaking, @isauto_v151spositiontaking_52 as isauto_spositiontaking, @auto_v151spositiontaking_52 as auto_spositiontaking WHERE @UpdatePositiontakingv151_51 = 1

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg = @UserName + ': ' +
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
    + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
    from custoverride3rd as co with (NOLOCK) inner join
        (
                         select 31 as bettype, 151 as sporttype, @v151spositiontaking_31 as spositiontaking, @v151mpositiontaking_31 as mpositiontaking, @isauto_v151spositiontaking_31 as isauto_spositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all    select 32 as bettype, 151 as sporttype, @v151spositiontaking_32 as spositiontaking, @v151mpositiontaking_32 as mpositiontaking, @isauto_v151spositiontaking_32 as isauto_spositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all    select 41 as bettype, 151 as sporttype, @v151spositiontaking_41 as spositiontaking, @v151mpositiontaking_41 as mpositiontaking, @isauto_v151spositiontaking_41 as isauto_spositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all    select 42 as bettype, 151 as sporttype, @v151spositiontaking_42 as spositiontaking, @v151mpositiontaking_42 as mpositiontaking, @isauto_v151spositiontaking_42 as isauto_spositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all    select 51 as bettype, 151 as sporttype, @v151spositiontaking_51 as spositiontaking, @v151mpositiontaking_51 as mpositiontaking, @isauto_v151spositiontaking_51 as isauto_spositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all    select 52 as bettype, 151 as sporttype, @v151spositiontaking_52 as spositiontaking, @v151mpositiontaking_52 as mpositiontaking, @isauto_v151spositiontaking_52 as isauto_spositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
    --                        or (b.sporttype = 2 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg = @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --m2+a2<=m3
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username +', '
      from custinfo c with(NOLOCK) 
inner join CustSetting3rd cs with(NOLOCK) on c.custid = cs.custid
inner join (select 151 as sporttype
                 , 31 as bettype
                 , @v151mpositiontaking_31 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_31 = 1
             
  union all    select 151 as sporttype
                 , 32 as bettype
                 , @v151mpositiontaking_32 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_31 = 1

  union all    select 151 as sporttype
                 , 41 as bettype
                 , @v151mpositiontaking_41 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_41 = 1

  union all    select 151 as sporttype
                 , 42 as bettype
                 , @v151mpositiontaking_42 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_41 = 1

  union all    select 151 as sporttype
                 , 51 as bettype
                 , @v151mpositiontaking_51 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_51 = 1

  union all    select 151 as sporttype
                 , 52 as bettype
                 , @v151mpositiontaking_52 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_51 = 1
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) on c.custid = cs.custid
INNER JOIN (SELECT 151 AS sporttype
                 , 31 AS bettype
                 , @v151mpositiontaking_31 AS maxpositiontaking
             WHERE @UpdatePositiontakingv151_31 = 1

  UNION ALL    SELECT 151 AS sporttype
                 , 32 AS bettype
                 , @v151mpositiontaking_32 AS maxpositiontaking
             WHERE @UpdatePositiontakingv151_31 = 1

  UNION ALL    SELECT 151 AS sporttype
                 , 41 AS bettype
                 , @v151mpositiontaking_41 AS maxpositiontaking
             WHERE @UpdatePositiontakingv151_41 = 1

  UNION ALL    SELECT 151 AS sporttype
                 , 42 AS bettype
                 , @v151mpositiontaking_42 AS maxpositiontaking
             WHERE @UpdatePositiontakingv151_41 = 1

  UNION ALL    SELECT 151 AS sporttype
                 , 51 AS bettype
                 , @v151mpositiontaking_51 AS maxpositiontaking
             WHERE @UpdatePositiontakingv151_51 = 1

  UNION ALL    SELECT 151 AS sporttype
                 , 52 AS bettype
                 , @v151mpositiontaking_52 AS maxpositiontaking
             WHERE @UpdatePositiontakingv151_51 = 1

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg = @UserName + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                         END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName +' - ' +
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((scs.mpositiontaking) as varchar(10)) + '<br>'
    from CustSetting3rd as scs with (NOLOCK) inner join
        (
                             select 31 as bettype, 151 as sporttype, @v151spositiontaking_31 as spositiontaking, @v151mpositiontaking_31 as mpositiontaking, @auto_v151spositiontaking_31 as auto_spositiontaking WHERE @UpdatePositiontakingv151_31 = 1  
            union all         select 32 as bettype, 151 as sporttype, @v151spositiontaking_32 as spositiontaking, @v151mpositiontaking_32 as mpositiontaking, @auto_v151spositiontaking_32 as auto_spositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all         select 41 as bettype, 151 as sporttype, @v151spositiontaking_41 as spositiontaking, @v151mpositiontaking_41 as mpositiontaking, @auto_v151spositiontaking_41 as auto_spositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all         select 42 as bettype, 151 as sporttype, @v151spositiontaking_42 as spositiontaking, @v151mpositiontaking_42 as mpositiontaking, @auto_v151spositiontaking_42 as auto_spositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all         select 51 as bettype, 151 as sporttype, @v151spositiontaking_51 as spositiontaking, @v151mpositiontaking_51 as mpositiontaking, @auto_v151spositiontaking_51 as auto_spositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all         select 52 as bettype, 151 as sporttype, @v151spositiontaking_52 as spositiontaking, @v151mpositiontaking_52 as mpositiontaking, @auto_v151spositiontaking_52 as auto_spositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking 
                        )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 16
        Select @ErrMsg = @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --m3>=u2
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username +', '
      from custinfo c with(NOLOCK) 
inner join CustSetting3rd cs with(NOLOCK) on c.custid = cs.custid
inner join (select 151 as sporttype
                 , 31 as bettype
                 , @v151mpositiontaking_31 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_31 = 1

  union all    select 151 as sporttype
                 , 32 as bettype
                 , @v151mpositiontaking_32 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_31 = 1

  union all    select 151 as sporttype
                 , 41 as bettype
                 , @v151mpositiontaking_41 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_41 = 1

  union all    select 151 as sporttype
                 , 42 as bettype
                 , @v151mpositiontaking_42 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_41 = 1

  union all    select 151 as sporttype
                 , 51 as bettype
                 , @v151mpositiontaking_51 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_51 = 1

  union all    select 151 as sporttype
                 , 52 as bettype
                 , @v151mpositiontaking_52 as maxpositiontaking
             WHERE @UpdatePositiontakingv151_51 = 1
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         end
        return
    END

    --v201
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
    from CustSetting3rd as cs with (NOLOCK) inner join
        (
                            select 31 as bettype, 151 as sporttype, @auto_v151spositiontaking_31 as autopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all        select 32 as bettype, 151 as sporttype, @auto_v151spositiontaking_32 as autopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all        select 41 as bettype, 151 as sporttype, @auto_v151spositiontaking_41 as autopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all        select 42 as bettype, 151 as sporttype, @auto_v151spositiontaking_42 as autopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all        select 51 as bettype, 151 as sporttype, @auto_v151spositiontaking_51 as autopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all        select 52 as bettype, 151 as sporttype, @auto_v151spositiontaking_52 as autopositiontaking WHERE @UpdatePositiontakingv151_51 = 1

        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 223
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((cs.spositiontaking) as varchar(10))+ '<br>'
    from CustSetting3rd as cs with (NOLOCK) inner join
        (
                            select 31 as bettype, 151 as sporttype, @v151spositiontaking_31 as spositiontaking, @v151mpositiontaking_31 as mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all        select 32 as bettype, 151 as sporttype, @v151spositiontaking_32 as spositiontaking, @v151mpositiontaking_32 as mpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all        select 41 as bettype, 151 as sporttype, @v151spositiontaking_41 as spositiontaking, @v151mpositiontaking_41 as mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all        select 42 as bettype, 151 as sporttype, @v151spositiontaking_42 as spositiontaking, @v151mpositiontaking_42 as mpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all        select 51 as bettype, 151 as sporttype, @v151spositiontaking_51 as spositiontaking, @v151mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all        select 52 as bettype, 151 as sporttype, @v151spositiontaking_52 as spositiontaking, @v151mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
    --        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong  position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 224
        return
    END

END--@UpdatePositiontakingv151

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@UpdatePositiontakingv152
    if 
        ((@v152spositiontaking_41 <0
        or @v152spositiontaking_42 <0
        or @v152mpositiontaking_41 <0
        or @v152mpositiontaking_42 <0
        or @auto_v152spositiontaking_41 < 0
        or @auto_v152spositiontaking_42 < 0
        or @auto_v152spositiontaking_41  >@maxpos
        or @auto_v152spositiontaking_42  >@maxpos
        or @v152spositiontaking_41+@v152mpositiontaking_41 >@maxpos
        or @v152spositiontaking_42+@v152mpositiontaking_42 >@maxpos        )
        and @UpdatePositiontakingv152_41 = 1    ) 
        
        or ((@v152spositiontaking_51 <0
        or @v152spositiontaking_52 <0
        or @v152mpositiontaking_51 <0
        or @v152mpositiontaking_52 <0
        or @auto_v152spositiontaking_51 <0
        or @auto_v152spositiontaking_52 <0
        or @auto_v152spositiontaking_51  >@maxpos
        or @auto_v152spositiontaking_52  >@maxpos
        or @v152spositiontaking_51+@v152mpositiontaking_51 >@maxpos
        or @v152spositiontaking_52+@v152mpositiontaking_52 >@maxpos        )
        and @UpdatePositiontakingv152_51 = 1    )
        
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg = @UserName + ': ' + 
                    case @Language 
                            when 'E' then 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
    + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
    from custoverride3rd as co with (NOLOCK) inner join
        (
                         select 41 as bettype, 152 as sporttype, @v152spositiontaking_41 as spositiontaking, @v152mpositiontaking_41 as mpositiontaking, @isauto_v152spositiontaking_41 as isauto_spositiontaking, @auto_v152spositiontaking_41 as auto_spositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all    select 42 as bettype, 152 as sporttype, @v152spositiontaking_42 as spositiontaking, @v152mpositiontaking_42 as mpositiontaking, @isauto_v152spositiontaking_42 as isauto_spositiontaking, @auto_v152spositiontaking_42 as auto_spositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all    select 51 as bettype, 152 as sporttype, @v152spositiontaking_51 as spositiontaking, @v152mpositiontaking_51 as mpositiontaking, @isauto_v152spositiontaking_51 as isauto_spositiontaking, @auto_v152spositiontaking_51 as auto_spositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all    select 52 as bettype, 152 as sporttype, @v152spositiontaking_52 as spositiontaking, @v152mpositiontaking_52 as mpositiontaking, @isauto_v152spositiontaking_52 as isauto_spositiontaking, @auto_v152spositiontaking_52 as auto_spositiontaking WHERE @UpdatePositiontakingv152_51 = 1

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg = @UserName + ': ' +
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
    + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
    from custoverride3rd as co with (NOLOCK) inner join
        (
                         select 41 as bettype, 152 as sporttype, @v152spositiontaking_41 as spositiontaking, @v152mpositiontaking_41 as mpositiontaking, @isauto_v152spositiontaking_41 as isauto_spositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all    select 42 as bettype, 152 as sporttype, @v152spositiontaking_42 as spositiontaking, @v152mpositiontaking_42 as mpositiontaking, @isauto_v152spositiontaking_42 as isauto_spositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all    select 51 as bettype, 152 as sporttype, @v152spositiontaking_51 as spositiontaking, @v152mpositiontaking_51 as mpositiontaking, @isauto_v152spositiontaking_51 as isauto_spositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all    select 52 as bettype, 152 as sporttype, @v152spositiontaking_52 as spositiontaking, @v152mpositiontaking_52 as mpositiontaking, @isauto_v152spositiontaking_52 as isauto_spositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
    --                        or (b.sporttype = 2 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg = @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --m2+a2<=m3
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK) 
inner join CustSetting3rd cs with(NOLOCK) on c.custid = cs.custid
inner join (select 152 as sporttype
                 , 41 as bettype
                 , @v152mpositiontaking_41 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_41 = 1

  union all    select 152 as sporttype
                 , 42 as bettype
                 , @v152mpositiontaking_42 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_41 = 1

  union all    select 152 as sporttype
                 , 51 as bettype
                 , @v152mpositiontaking_51 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_51 = 1

  union all    select 152 as sporttype
                 , 52 as bettype
                 , @v152mpositiontaking_52 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_51 = 1

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 152 AS sporttype
                 , 41 AS bettype
                 , @v152mpositiontaking_41 AS maxpositiontaking
             WHERE @UpdatePositiontakingv152_41 = 1

  UNION ALL    SELECT 152 AS sporttype
                 , 42 AS bettype
                 , @v152mpositiontaking_42 AS maxpositiontaking
             WHERE @UpdatePositiontakingv152_41 = 1

  UNION ALL    SELECT 152 AS sporttype
                 , 51 AS bettype
                 , @v152mpositiontaking_51 AS maxpositiontaking
             WHERE @UpdatePositiontakingv152_51 = 1

  UNION ALL    SELECT 152 AS sporttype
                 , 52 AS bettype
                 , @v152mpositiontaking_52 AS maxpositiontaking
             WHERE @UpdatePositiontakingv152_51 = 1
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg = @UserName + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + N') .'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                         END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName +' - ' +
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((scs.mpositiontaking) as varchar(10)) + '<br>'
    from CustSetting3rd as scs with (NOLOCK) inner join
        (
                             select 41 as bettype, 152 as sporttype, @v152spositiontaking_41 as spositiontaking, @v152mpositiontaking_41 as mpositiontaking, @auto_v152spositiontaking_41 as auto_spositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all         select 42 as bettype, 152 as sporttype, @v152spositiontaking_42 as spositiontaking, @v152mpositiontaking_42 as mpositiontaking, @auto_v152spositiontaking_42 as auto_spositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all         select 51 as bettype, 152 as sporttype, @v152spositiontaking_51 as spositiontaking, @v152mpositiontaking_51 as mpositiontaking, @auto_v152spositiontaking_51 as auto_spositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all         select 52 as bettype, 152 as sporttype, @v152spositiontaking_52 as spositiontaking, @v152mpositiontaking_52 as mpositiontaking, @auto_v152spositiontaking_52 as auto_spositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking 
                        )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 16
        Select @ErrMsg = @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --m3>=u2
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK)
inner join CustSetting3rd cs with(NOLOCK) on c.custid = cs.custid
inner join (select 152 as sporttype
                 , 41 as bettype
                 , @v152mpositiontaking_41 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_41 = 1

  union all    select 152 as sporttype
                 , 42 as bettype
                 , @v152mpositiontaking_42 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_41 = 1

  union all    select 152 as sporttype
                 , 51 as bettype
                 , @v152mpositiontaking_51 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_51 = 1

  union all    select 152 as sporttype
                 , 52 as bettype
                 , @v152mpositiontaking_52 as maxpositiontaking
             WHERE @UpdatePositiontakingv152_51 = 1

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                          end
        return
    END

    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    --v201
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
    from CustSetting3rd as cs with (NOLOCK) inner join
        (
                            select 41 as bettype, 152 as sporttype, @auto_v152spositiontaking_41 as autopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all        select 42 as bettype, 152 as sporttype, @auto_v152spositiontaking_42 as autopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all        select 51 as bettype, 152 as sporttype, @auto_v152spositiontaking_51 as autopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all        select 52 as bettype, 152 as sporttype, @auto_v152spositiontaking_52 as autopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 223
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((cs.spositiontaking) as varchar(10))+ '<br>'
    from CustSetting3rd as cs with (NOLOCK) inner join
        (
                            select 41 as bettype, 152 as sporttype, @v152spositiontaking_41 as spositiontaking, @v152mpositiontaking_41 as mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all        select 42 as bettype, 152 as sporttype, @v152spositiontaking_42 as spositiontaking, @v152mpositiontaking_42 as mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all        select 51 as bettype, 152 as sporttype, @v152spositiontaking_51 as spositiontaking, @v152mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all        select 52 as bettype, 152 as sporttype, @v152spositiontaking_52 as spositiontaking, @v152mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
    --        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong  position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 224
        return
    END

END--@UpdatePositiontakingv152

-------------------------------------------------------------------------------------------------------------------------------------------------
if (@UpdateMultiple = 0  or @UpdatePositiontakingv153_51 = 1)
BEGIN --@UpdatePositiontakingv153
    if 
        (@v153spositiontaking_51 <0
        or @v153spositiontaking_52 <0
        
        or @v153mpositiontaking_51 <0
        or @v153mpositiontaking_52 <0
        
        or @auto_v153spositiontaking_51  <0
        or @auto_v153spositiontaking_52  <0
                     
        or @auto_v153spositiontaking_51  >@maxpos
        or @auto_v153spositiontaking_52  >@maxpos

        or @v153spositiontaking_51+@v153mpositiontaking_51 >@maxpos
        or @v153spositiontaking_52+@v153mpositiontaking_52 >@maxpos
        )and @UpdatePositiontakingv153_51 = 1
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg = @UserName + ': ' + 
                    case @Language 
                            when 'E' then 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
    + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
    from custoverride3rd as co with (NOLOCK) inner join
        (
                         select 51 as bettype, 153 as sporttype, @v153spositiontaking_51 as spositiontaking, @v153mpositiontaking_51 as mpositiontaking, @isauto_v153spositiontaking_51 as isauto_spositiontaking, @auto_v153spositiontaking_51 as auto_spositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            union all    select 52 as bettype, 153 as sporttype, @v153spositiontaking_52 as spositiontaking, @v153mpositiontaking_52 as mpositiontaking, @isauto_v153spositiontaking_52 as isauto_spositiontaking, @auto_v153spositiontaking_52 as auto_spositiontaking WHERE @UpdatePositiontakingv153_51 = 1

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg = @UserName + ': ' +
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
    + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
    from custoverride3rd as co with (NOLOCK) inner join
        (
                         select 51 as bettype, 153 as sporttype, @v153spositiontaking_51 as spositiontaking, @v153mpositiontaking_51 as mpositiontaking, @isauto_v153spositiontaking_51 as isauto_spositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            union all    select 52 as bettype, 153 as sporttype, @v153spositiontaking_52 as spositiontaking, @v153mpositiontaking_52 as mpositiontaking, @isauto_v153spositiontaking_52 as isauto_spositiontaking WHERE @UpdatePositiontakingv153_51 = 1
                    
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
    --                        or (b.sporttype = 2 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg = @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --m2+a2<=m3
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username +', '
      from custinfo c with(NOLOCK)
inner join CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 153 as sporttype
                 , 51 as bettype
                 , @v153mpositiontaking_51 as maxpositiontaking
             WHERE @UpdatePositiontakingv153_51 = 1

  union all    select 153 as sporttype
                 , 52 as bettype
                 , @v153mpositiontaking_52 as maxpositiontaking
             WHERE @UpdatePositiontakingv153_51 = 1

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  group by username
  
    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' (' + @ErrAcc + ').'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c WITH(NOLOCK) 
INNER JOIN CustSetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 153 AS sporttype
                 , 51 AS bettype
                 , @v153mpositiontaking_51 AS maxpositiontaking
             WHERE @UpdatePositiontakingv153_51 = 1

  UNION ALL    SELECT 153 AS sporttype
                 , 52 AS bettype
                 , @v153mpositiontaking_52 AS maxpositiontaking
             WHERE @UpdatePositiontakingv153_51 = 1
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        Select @ErrMsg = @UserName + ': ' + 
                    case @Language 
                            when 'E' then 'Existing members exceeded new master position taking ('+@ErrAcc+') .'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20012,@Language) + ' ('+@ErrAcc+').'
                    end
        return
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName +' - ' +
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((scs.mpositiontaking) as varchar(10)) + '<br>'
    from CustSetting3rd as scs with (NOLOCK) inner join
        (
                             select 51 as bettype, 153 as sporttype, @v153spositiontaking_51 as spositiontaking, @v153mpositiontaking_51 as mpositiontaking, @auto_v153spositiontaking_51 as auto_spositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            union all         select 52 as bettype, 153 as sporttype, @v153spositiontaking_52 as spositiontaking, @v153mpositiontaking_52 as mpositiontaking, @auto_v153spositiontaking_52 as auto_spositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking 
                        )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 16
        Select @ErrMsg = @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --m3>=u2
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK)
inner join CustSetting3rd cs with(NOLOCK) on c.custid = cs.custid
inner join (select 153 as sporttype
                 , 51 as bettype
                 , @v153mpositiontaking_51 as maxpositiontaking
             WHERE @UpdatePositiontakingv153_51 = 1

  union all    select 153 as sporttype
                 , 52 as bettype
                 , @v153mpositiontaking_52 as maxpositiontaking
             WHERE @UpdatePositiontakingv153_51 = 1

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username
  
    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ').'
                          end
        return
    END

    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    --v201
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
    from CustSetting3rd as cs with (NOLOCK) inner join
        (
                            select 51 as bettype, 153 as sporttype, @auto_v153spositiontaking_51 as autopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            union all        select 52 as bettype, 153 as sporttype, @auto_v153spositiontaking_52 as autopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 223
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + s.SportName + ' - ' + 
    case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
     + '-Max: '+ cast((cs.spositiontaking) as varchar(10))+ '<br>'
    from CustSetting3rd as cs with (NOLOCK) inner join
        (
                            select 51 as bettype, 153 as sporttype, @v153spositiontaking_51 as spositiontaking, @v153mpositiontaking_51 as mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            union all        select 52 as bettype, 153 as sporttype, @v153spositiontaking_52 as spositiontaking, @v153mpositiontaking_52 as mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
    --        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong  position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 224
        return
    END

END--@UpdatePositiontakingv153
---------------------------------------------------------------------------------------------------------------------------------------------------------------

declare @old_v151spositiontaking_31 smallmoney,
    @old_v151spositiontaking_32 smallmoney,
    @old_v151spositiontaking_41 smallmoney,
    @old_v151spositiontaking_42 smallmoney,
    @old_v151spositiontaking_51 smallmoney,
    @old_v151spositiontaking_52 smallmoney,
    @old_v152spositiontaking_41 smallmoney,
    @old_v152spositiontaking_42 smallmoney,
    @old_v152spositiontaking_51 smallmoney,
    @old_v152spositiontaking_52 smallmoney,
    @old_v153spositiontaking_51 smallmoney,
    @old_v153spositiontaking_52 smallmoney,
    
    @old_v151mpositiontaking_31 smallmoney,
    @old_v151mpositiontaking_32 smallmoney,
    @old_v151mpositiontaking_41 smallmoney,
    @old_v151mpositiontaking_42 smallmoney,
    @old_v151mpositiontaking_51 smallmoney,
    @old_v151mpositiontaking_52 smallmoney,
    @old_v152mpositiontaking_41 smallmoney,
    @old_v152mpositiontaking_42 smallmoney,
    @old_v152mpositiontaking_51 smallmoney,
    @old_v152mpositiontaking_52 smallmoney,
    @old_v153mpositiontaking_51 smallmoney,
    @old_v153mpositiontaking_52 smallmoney 

select @old_v151spositiontaking_31 = max( case when sporttype = 151 and bettype = 31 then spositiontaking else 0 end),
        @old_v151spositiontaking_32 = max( case when sporttype = 151 and bettype = 32 then spositiontaking else 0 end),
        @old_v151spositiontaking_41 = max( case when sporttype = 151 and bettype = 41 then spositiontaking else 0 end),
        @old_v151spositiontaking_42 = max( case when sporttype = 151 and bettype = 42 then spositiontaking else 0 end),
        @old_v151spositiontaking_51 = max( case when sporttype = 151 and bettype = 51 then spositiontaking else 0 end),
        @old_v151spositiontaking_52 = max( case when sporttype = 151 and bettype = 52 then spositiontaking else 0 end),
        @old_v152spositiontaking_41 = max( case when sporttype = 152 and bettype = 41 then spositiontaking else 0 end),
        @old_v152spositiontaking_42 = max( case when sporttype = 152 and bettype = 42 then spositiontaking else 0 end),
        @old_v152spositiontaking_51 = max( case when sporttype = 152 and bettype = 51 then spositiontaking else 0 end),
        @old_v152spositiontaking_52 = max( case when sporttype = 152 and bettype = 52 then spositiontaking else 0 end),
        @old_v153spositiontaking_51 = max( case when sporttype = 153 and bettype = 51 then spositiontaking else 0 end),
        @old_v153spositiontaking_52 = max( case when sporttype = 153 and bettype = 52 then spositiontaking else 0 end),
        
        @old_v151mpositiontaking_31 = max( case when sporttype = 151 and bettype = 31 then mpositiontaking else 0 end),
        @old_v151mpositiontaking_32 = max( case when sporttype = 151 and bettype = 32 then mpositiontaking else 0 end),
        @old_v151mpositiontaking_41 = max( case when sporttype = 151 and bettype = 41 then mpositiontaking else 0 end),
        @old_v151mpositiontaking_42 = max( case when sporttype = 151 and bettype = 42 then mpositiontaking else 0 end),
        @old_v151mpositiontaking_51 = max( case when sporttype = 151 and bettype = 51 then mpositiontaking else 0 end),
        @old_v151mpositiontaking_52 = max( case when sporttype = 151 and bettype = 52 then mpositiontaking else 0 end),
        @old_v152mpositiontaking_41 = max( case when sporttype = 152 and bettype = 41 then mpositiontaking else 0 end),
        @old_v152mpositiontaking_42 = max( case when sporttype = 152 and bettype = 42 then mpositiontaking else 0 end),
        @old_v152mpositiontaking_51 = max( case when sporttype = 152 and bettype = 51 then mpositiontaking else 0 end),
        @old_v152mpositiontaking_52 = max( case when sporttype = 152 and bettype = 52 then mpositiontaking else 0 end),
        @old_v153mpositiontaking_51 = max( case when sporttype = 153 and bettype = 51 then mpositiontaking else 0 end),
        @old_v153mpositiontaking_52 = max( case when sporttype = 153 and bettype = 52 then mpositiontaking else 0 end)
from custsetting3rd with(nolock)
where custid = @custid and sporttype between 151 and 153

if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151 
    update CustSetting3rd with (ROWLOCK, UPDLOCK)
    set
        spositiontaking = case  
                when bettype = 31 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_31 
                when bettype = 32 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_32 
                when bettype = 41 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_41 
                when bettype = 42 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_42 
                when bettype = 51 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_51 
                when bettype = 52 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_52 
                else spositiontaking end,    
        mpositiontaking = case 
                when bettype = 31 and @UpdatePositiontakingv151_31 = 1 then @v151mpositiontaking_31 
                when bettype = 32 and @UpdatePositiontakingv151_31 = 1 then @v151mpositiontaking_32 
                when bettype = 41 and @UpdatePositiontakingv151_41 = 1 then @v151mpositiontaking_41 
                when bettype = 42 and @UpdatePositiontakingv151_41 = 1 then @v151mpositiontaking_42 
                when bettype = 51 and @UpdatePositiontakingv151_51 = 1 then @v151mpositiontaking_51 
                when bettype = 52 and @UpdatePositiontakingv151_51 = 1 then @v151mpositiontaking_52 
                else mpositiontaking end    
    where custid=@custid and sporttype = 151
    if (@@error <> 0)
    begin
        
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end    , @ErrCode = 122                     
        
        return
    end
END--UpdatePositiontakingv151

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@UpdatePositiontakingv152
    update CustSetting3rd with (ROWLOCK, UPDLOCK)
    set
        spositiontaking = case  
                when bettype = 41 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_41 
                when bettype = 42 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_42 
                when bettype = 51 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_51 
                when bettype = 52 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_52 
                else spositiontaking end,    
        mpositiontaking = case  
                when bettype = 41 and @UpdatePositiontakingv152_41 = 1 then @v152mpositiontaking_41 
                when bettype = 42 and @UpdatePositiontakingv152_41 = 1 then @v152mpositiontaking_42 
                when bettype = 51 and @UpdatePositiontakingv152_51 = 1 then @v152mpositiontaking_51 
                when bettype = 52 and @UpdatePositiontakingv152_51 = 1 then @v152mpositiontaking_52 
                else mpositiontaking end    
    where custid=@custid and sporttype = 152
    if (@@error <> 0)
    begin
        
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end    , @ErrCode = 122                     
        
        return
    end
END--@UpdatePositiontakingv152

if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
BEGIN --@UpdatePositiontakingv153 
    update CustSetting3rd with (ROWLOCK, UPDLOCK)
    set
        spositiontaking = case  
                when bettype=51 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_51 
                when bettype=52 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_52 
                else spositiontaking end,    
        mpositiontaking = case  
                when bettype=51 and @UpdatePositiontakingv153_51 = 1 then @v153mpositiontaking_51 
                when bettype=52 and @UpdatePositiontakingv153_51 = 1 then @v153mpositiontaking_52 
                else mpositiontaking end    
    where custid=@custid and sporttype = 153
    if (@@error <> 0)
    begin
        
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end    , @ErrCode = 122                     
        
        return
    end
END--@UpdatePositiontakingv153

--Auto PT Acc_CustomerUpdMaster_AutoPositiontaking
Declare 
    @old_auto_v151spositiontaking_31 smallmoney,
    @old_auto_v151spositiontaking_32 smallmoney,
    @old_auto_v151spositiontaking_41 smallmoney,
    @old_auto_v151spositiontaking_42 smallmoney,
    @old_auto_v151spositiontaking_51 smallmoney,
    @old_auto_v151spositiontaking_52 smallmoney,
    @old_auto_v152spositiontaking_41 smallmoney,
    @old_auto_v152spositiontaking_42 smallmoney,
    @old_auto_v152spositiontaking_51 smallmoney,
    @old_auto_v152spositiontaking_52 smallmoney,
    @old_auto_v153spositiontaking_51 smallmoney,
    @old_auto_v153spositiontaking_52 smallmoney,
    
    @old_isauto_v151spositiontaking_31 bit,
    @old_isauto_v151spositiontaking_32 bit,
    @old_isauto_v151spositiontaking_41 bit,
    @old_isauto_v151spositiontaking_42 bit,
    @old_isauto_v151spositiontaking_51 bit,
    @old_isauto_v151spositiontaking_52 bit,
    @old_isauto_v152spositiontaking_41 bit,
    @old_isauto_v152spositiontaking_42 bit,
    @old_isauto_v152spositiontaking_51 bit,
    @old_isauto_v152spositiontaking_52 bit,
    @old_isauto_v153spositiontaking_51 bit,
    @old_isauto_v153spositiontaking_52 bit
    
if (@UpdatePositiontakingv151_31 = 1)
    begin    
        select     @old_auto_v151spositiontaking_31    =    autopositiontaking        ,    @old_isauto_v151spositiontaking_31    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=151    and bettype=31
        select     @old_auto_v151spositiontaking_32    =    autopositiontaking        ,    @old_isauto_v151spositiontaking_32    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=151    and bettype=32
    end

if (@UpdatePositiontakingv151_41 = 1)
    begin
        select     @old_auto_v151spositiontaking_41    =    autopositiontaking        ,    @old_isauto_v151spositiontaking_41    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=151    and bettype=41
        select     @old_auto_v151spositiontaking_42    =    autopositiontaking        ,    @old_isauto_v151spositiontaking_42    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=151    and bettype=42
    end
    
if (@UpdatePositiontakingv151_51 = 1)
    begin
        select     @old_auto_v151spositiontaking_51    =    autopositiontaking        ,    @old_isauto_v151spositiontaking_51    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=151    and bettype=51
        select     @old_auto_v151spositiontaking_52    =    autopositiontaking        ,    @old_isauto_v151spositiontaking_52    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=151    and bettype=52
    end
    
if (@UpdatePositiontakingv152_41 = 1)
    begin
        select     @old_auto_v152spositiontaking_41    =    autopositiontaking        ,    @old_isauto_v152spositiontaking_41    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=152    and bettype=41
        select     @old_auto_v152spositiontaking_42    =    autopositiontaking        ,    @old_isauto_v152spositiontaking_42    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=152    and bettype=42
    end
    
if (@UpdatePositiontakingv152_51 = 1)
    begin
        select     @old_auto_v152spositiontaking_51    =    autopositiontaking        ,    @old_isauto_v152spositiontaking_51    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=152    and bettype=51
        select     @old_auto_v152spositiontaking_52    =    autopositiontaking        ,    @old_isauto_v152spositiontaking_52    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=152    and bettype=52
    end

if (@UpdatePositiontakingv153_51 = 1)
    begin
        select     @old_auto_v153spositiontaking_51    =    autopositiontaking        ,    @old_isauto_v153spositiontaking_51    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=153    and bettype=51
        select     @old_auto_v153spositiontaking_52    =    autopositiontaking        ,    @old_isauto_v153spositiontaking_52    =    isautopositiontaking        from CustSetting3rd with (nolock) where custid = @custid and sporttype=153    and bettype=52
    end
--Update Master Agent account
--For HR
update CustSetting3rd with (ROWLOCK, UPDLOCK) 
set 
    autopositiontaking = CASE WHEN @UpdateMultiple = 1 
                                AND (    (cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
                                    OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
                                    OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
                                THEN cs.autopositiontaking 
                            ELSE b.autopositiontaking END, 
    isautopositiontaking = CASE WHEN @UpdateMultiple = 1 
                                AND (    (cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
                                    OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
                                    OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
                                THEN cs.isautopositiontaking
                             ELSE b.isautopositiontaking END
from CustSetting3rd as cs inner join 
        (
                        select 31 as bettype,151 as sporttype, @auto_v151spositiontaking_31 as autopositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all    select 32 as bettype,151 as sporttype, @auto_v151spositiontaking_32 as autopositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
            union all    select 41 as bettype,151 as sporttype, @auto_v151spositiontaking_41 as autopositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all    select 42 as bettype,151 as sporttype, @auto_v151spositiontaking_42 as autopositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
            union all    select 51 as bettype,151 as sporttype, @auto_v151spositiontaking_51 as autopositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all    select 52 as bettype,151 as sporttype, @auto_v151spositiontaking_52 as autopositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
            union all    select 41 as bettype,152 as sporttype, @auto_v152spositiontaking_41 as autopositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all    select 42 as bettype,152 as sporttype, @auto_v152spositiontaking_42 as autopositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
            union all    select 51 as bettype,152 as sporttype, @auto_v152spositiontaking_51 as autopositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all    select 52 as bettype,152 as sporttype, @auto_v152spositiontaking_52 as autopositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
            union all    select 51 as bettype,153 as sporttype, @auto_v153spositiontaking_51 as autopositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
            union all    select 52 as bettype,153 as sporttype, @auto_v153spositiontaking_52 as autopositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
        ) as b on b.bettype = cs.bettype and cs.sporttype=b.sporttype
    INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
where cs.custid = @custid 
if @@Error <> 0
BEGIN
    
    SELECT @ErrMsg = @UserName + ': ' + 
        case @Language 
            when 'E' then 'Error updating auto position taking '
            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
        end    
        ,  @ErrCode=205
    return
END

---20131105@Johnson: Apply execrep when update pt on members
EXEC dbo.Acc_CustSetting3rd_05
    @srecommend = @srecommend,
    @mrecommend = @custid,
    @roleid = 3,
    @mode = 'horse',
    
    @v151spositiontaking_31 = @v151spositiontaking_31,
    @v151spositiontaking_32 = @v151spositiontaking_32,
    @v151spositiontaking_41 = @v151spositiontaking_41,
    @v151spositiontaking_42 = @v151spositiontaking_42,
    @v151spositiontaking_51 = @v151spositiontaking_51,
    @v151spositiontaking_52 = @v151spositiontaking_52,
    @v152spositiontaking_41 = @v152spositiontaking_41,
    @v152spositiontaking_42 = @v152spositiontaking_42,
    @v152spositiontaking_51 = @v152spositiontaking_51,
    @v152spositiontaking_52 = @v152spositiontaking_52,
    @v153spositiontaking_51 = @v153spositiontaking_51,
    @v153spositiontaking_52 = @v153spositiontaking_52,
    
    @auto_v151spositiontaking_31 = @auto_v151spositiontaking_31,
    @auto_v151spositiontaking_32 = @auto_v151spositiontaking_32,
    @auto_v151spositiontaking_41 = @auto_v151spositiontaking_41,
    @auto_v151spositiontaking_42 = @auto_v151spositiontaking_42,
    @auto_v151spositiontaking_51 = @auto_v151spositiontaking_51,
    @auto_v151spositiontaking_52 = @auto_v151spositiontaking_52,
    @auto_v152spositiontaking_41 = @auto_v152spositiontaking_41,
    @auto_v152spositiontaking_42 = @auto_v152spositiontaking_42,
    @auto_v152spositiontaking_51 = @auto_v152spositiontaking_51,
    @auto_v152spositiontaking_52 = @auto_v152spositiontaking_52,
    @auto_v153spositiontaking_51 = @auto_v153spositiontaking_51,
    @auto_v153spositiontaking_52 = @auto_v153spositiontaking_52,
    
    @old_v151spositiontaking_31 = @old_v151spositiontaking_31,
    @old_v151spositiontaking_32 = @old_v151spositiontaking_32,
    @old_v151spositiontaking_41 = @old_v151spositiontaking_41,
    @old_v151spositiontaking_42 = @old_v151spositiontaking_42,
    @old_v151spositiontaking_51 = @old_v151spositiontaking_51,
    @old_v151spositiontaking_52 = @old_v151spositiontaking_52,
    @old_v152spositiontaking_41 = @old_v152spositiontaking_41,
    @old_v152spositiontaking_42 = @old_v152spositiontaking_42,
    @old_v152spositiontaking_51 = @old_v152spositiontaking_51,
    @old_v152spositiontaking_52 = @old_v152spositiontaking_52,
    @old_v153spositiontaking_51 = @old_v153spositiontaking_51,
    @old_v153spositiontaking_52 = @old_v153spositiontaking_52,
    
    @old_auto_v151spositiontaking_31 = @old_auto_v151spositiontaking_31,
    @old_auto_v151spositiontaking_32 = @old_auto_v151spositiontaking_32,
    @old_auto_v151spositiontaking_41 = @old_auto_v151spositiontaking_41,
    @old_auto_v151spositiontaking_42 = @old_auto_v151spositiontaking_42,
    @old_auto_v151spositiontaking_51 = @old_auto_v151spositiontaking_51,
    @old_auto_v151spositiontaking_52 = @old_auto_v151spositiontaking_52,
    @old_auto_v152spositiontaking_41 = @old_auto_v152spositiontaking_41,
    @old_auto_v152spositiontaking_42 = @old_auto_v152spositiontaking_42,
    @old_auto_v152spositiontaking_51 = @old_auto_v152spositiontaking_51,
    @old_auto_v152spositiontaking_52 = @old_auto_v152spositiontaking_52,
    @old_auto_v153spositiontaking_51 = @old_auto_v153spositiontaking_51,
    @old_auto_v153spositiontaking_52 = @old_auto_v153spositiontaking_52,
    
    @isauto_v151spositiontaking_31 = @isauto_v151spositiontaking_31,
    @isauto_v151spositiontaking_32 = @isauto_v151spositiontaking_32,
    @isauto_v151spositiontaking_41 = @isauto_v151spositiontaking_41,
    @isauto_v151spositiontaking_42 = @isauto_v151spositiontaking_42,
    @isauto_v151spositiontaking_51 = @isauto_v151spositiontaking_51,
    @isauto_v151spositiontaking_52 = @isauto_v151spositiontaking_52,
    @isauto_v152spositiontaking_41 = @isauto_v152spositiontaking_41,
    @isauto_v152spositiontaking_42 = @isauto_v152spositiontaking_42,
    @isauto_v152spositiontaking_51 = @isauto_v152spositiontaking_51,
    @isauto_v152spositiontaking_52 = @isauto_v152spositiontaking_52,
    @isauto_v153spositiontaking_51 = @isauto_v153spositiontaking_51,
    @isauto_v153spositiontaking_52 = @isauto_v153spositiontaking_52,
    
    @old_isauto_v151spositiontaking_31 = @old_isauto_v151spositiontaking_31,
    @old_isauto_v151spositiontaking_32 = @old_isauto_v151spositiontaking_32,
    @old_isauto_v151spositiontaking_41 = @old_isauto_v151spositiontaking_41,
    @old_isauto_v151spositiontaking_42 = @old_isauto_v151spositiontaking_42,
    @old_isauto_v151spositiontaking_51 = @old_isauto_v151spositiontaking_51,
    @old_isauto_v151spositiontaking_52 = @old_isauto_v151spositiontaking_52,
    @old_isauto_v152spositiontaking_41 = @old_isauto_v152spositiontaking_41,
    @old_isauto_v152spositiontaking_42 = @old_isauto_v152spositiontaking_42,
    @old_isauto_v152spositiontaking_51 = @old_isauto_v152spositiontaking_51,
    @old_isauto_v152spositiontaking_52 = @old_isauto_v152spositiontaking_52,
    @old_isauto_v153spositiontaking_51 = @old_isauto_v153spositiontaking_51,
    @old_isauto_v153spositiontaking_52 = @old_isauto_v153spositiontaking_52,
    
    @IsCopyPreset151_31 = @IsCopyPreset151_31,
    @IsCopyPreset151_41 = @IsCopyPreset151_41,
    @IsCopyPreset151_51 = @IsCopyPreset151_51,
    @IsCopyPreset152_41 = @IsCopyPreset152_41,
    @IsCopyPreset152_51 = @IsCopyPreset152_51,
    @IsCopyPreset153_51 = @IsCopyPreset153_51,
    
    @UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
    @UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
    @UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
    @UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
    @UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
    @UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51,
    @updateallmembers = @updateallmembers,
    @updatemultiple = @updatemultiple,
    @newspositiontaking = @newspositiontaking
    
/*
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151 
    --31
    if (@auto_v151spositiontaking_31 <> @old_auto_v151spositiontaking_31 or @isauto_v151spositiontaking_31 <> @old_isauto_v151spositiontaking_31 ) and @UpdatePositiontakingv151_31 = 1
    BEGIN
        if @isauto_v151spositiontaking_31 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=151 and bettype = 31
            update cs
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v151spositiontaking_31 then @auto_v151spositiontaking_31 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 31 and cs.sporttype=151 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' +  
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v151spositiontaking_31 <> @old_isauto_v151spositiontaking_31
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 31 and cs.sporttype=151 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +  
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --32
    if (@auto_v151spositiontaking_32 <> @old_auto_v151spositiontaking_32 or @isauto_v151spositiontaking_32 <> @old_isauto_v151spositiontaking_32) and @UpdatePositiontakingv151_31 = 1
    BEGIN
        if @isauto_v151spositiontaking_32 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=151 and bettype = 32
            update cs
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v151spositiontaking_32 then @auto_v151spositiontaking_32 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 32 and cs.sporttype=151 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v151spositiontaking_32 <> @old_isauto_v151spositiontaking_32
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 32 and cs.sporttype=151 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --41
    if (@auto_v151spositiontaking_41 <> @old_auto_v151spositiontaking_41 or @isauto_v151spositiontaking_41 <> @old_isauto_v151spositiontaking_41) and @UpdatePositiontakingv151_41 = 1
    BEGIN
        if @isauto_v151spositiontaking_41 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=151 and bettype = 41
            update cs
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v151spositiontaking_41 then @auto_v151spositiontaking_41 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=151 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' +  
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v151spositiontaking_41 <> @old_isauto_v151spositiontaking_41
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=151 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +  
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --42
    if (@auto_v151spositiontaking_42 <> @old_auto_v151spositiontaking_42 or @isauto_v151spositiontaking_42 <> @old_isauto_v151spositiontaking_42) and @UpdatePositiontakingv151_41 = 1
    BEGIN
        if @isauto_v151spositiontaking_42 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=151 and bettype = 42
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v151spositiontaking_42 then @auto_v151spositiontaking_42 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=151 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v151spositiontaking_42 <> @old_isauto_v151spositiontaking_42
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=151 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --151_51
    if (@auto_v151spositiontaking_51 <> @old_auto_v151spositiontaking_51 or @isauto_v151spositiontaking_51 <> @old_isauto_v151spositiontaking_51) and @UpdatePositiontakingv151_51 = 1
    BEGIN
        if @isauto_v151spositiontaking_51 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=151 and bettype = 51
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v151spositiontaking_51 then @auto_v151spositiontaking_51 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=151 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v151spositiontaking_51 <> @old_isauto_v151spositiontaking_51
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=151 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --151_52
    if (@auto_v151spositiontaking_52 <> @old_auto_v151spositiontaking_52 or @isauto_v151spositiontaking_52 <> @old_isauto_v151spositiontaking_52) and @UpdatePositiontakingv151_51 = 1
    BEGIN
        if @isauto_v151spositiontaking_52 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=151 and bettype = 52
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v151spositiontaking_52 then @auto_v151spositiontaking_52 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=151 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v151spositiontaking_52 <> @old_isauto_v151spositiontaking_52
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=151 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    
    
    --Copy preset to member
    IF @IsCopyPreset151_31 = 1 
    BEGIN
        update cs 
            set spositiontaking = b.spositiontaking
        from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            inner join 
                (
                                select 151 as sporttype, 31 as bettype, @isauto_v151spositiontaking_31 as isautopositiontaking, @old_isauto_v151spositiontaking_31 as oldisautopositiontaking, @v151spositiontaking_31 as spositiontaking
                    union all    select 151 as sporttype, 32 as bettype, @isauto_v151spositiontaking_32 as isautopositiontaking, @old_isauto_v151spositiontaking_32 as oldisautopositiontaking, @v151spositiontaking_32 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
    END
    IF @IsCopyPreset151_41 = 1 
    BEGIN
        update cs 
        set spositiontaking = b.spositiontaking
        from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            inner join 
                (
                                select 151 as sporttype, 41 as bettype, @isauto_v151spositiontaking_41 as isautopositiontaking, @old_isauto_v151spositiontaking_41 as oldisautopositiontaking, @v151spositiontaking_41 as spositiontaking
                    union all    select 151 as sporttype, 42 as bettype, @isauto_v151spositiontaking_42 as isautopositiontaking, @old_isauto_v151spositiontaking_42 as oldisautopositiontaking, @v151spositiontaking_42 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
    END
    IF @IsCopyPreset151_51 = 1 
    BEGIN
        update cs 
        set spositiontaking = b.spositiontaking
        from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            inner join 
                (
                                select 151 as sporttype, 51 as bettype, @isauto_v151spositiontaking_51 as isautopositiontaking, @old_isauto_v151spositiontaking_51 as oldisautopositiontaking, @v151spositiontaking_51 as spositiontaking
                    union all    select 151 as sporttype, 52 as bettype, @isauto_v151spositiontaking_52 as isautopositiontaking, @old_isauto_v151spositiontaking_52 as oldisautopositiontaking, @v151spositiontaking_52 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
    END
    
END --@UpdatePositiontakingv151 

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@UpdatePositiontakingv152
    --152_41
    if (@auto_v152spositiontaking_41 <> @old_auto_v152spositiontaking_41 or @isauto_v152spositiontaking_41 <> @old_isauto_v152spositiontaking_41) and @UpdatePositiontakingv152_41 = 1
    BEGIN
        if @isauto_v152spositiontaking_41 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=152 and bettype = 41
            update cs
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v152spositiontaking_41 then @auto_v152spositiontaking_41 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=152 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' +  
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v152spositiontaking_41 <> @old_isauto_v152spositiontaking_41
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 41 and cs.sporttype=152 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +  
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    
    --152_42
    if (@auto_v152spositiontaking_42 <> @old_auto_v152spositiontaking_42 or @isauto_v152spositiontaking_42 <> @old_isauto_v152spositiontaking_42) and @UpdatePositiontakingv152_41 = 1
    BEGIN
        if @isauto_v152spositiontaking_42 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=152 and bettype = 42
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v152spositiontaking_42 then @auto_v152spositiontaking_42 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=152 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v152spositiontaking_42 <> @old_isauto_v152spositiontaking_42
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 42 and cs.sporttype=152 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --152_51
    if (@auto_v152spositiontaking_51 <> @old_auto_v152spositiontaking_51 or @isauto_v152spositiontaking_51 <> @old_isauto_v152spositiontaking_51) and @UpdatePositiontakingv152_51 = 1
    BEGIN
        if @isauto_v152spositiontaking_51 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=152 and bettype = 51
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v152spositiontaking_51 then @auto_v152spositiontaking_51 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=152 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v152spositiontaking_51 <> @old_isauto_v152spositiontaking_51
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=152 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --152_52
    if (@auto_v152spositiontaking_52 <> @old_auto_v152spositiontaking_52 or @isauto_v152spositiontaking_52 <> @old_isauto_v152spositiontaking_52) and @UpdatePositiontakingv152_51 = 1
    BEGIN
        if @isauto_v152spositiontaking_52 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=152 and bettype = 52
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v152spositiontaking_52 then @auto_v152spositiontaking_52 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=152 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v152spositiontaking_52 <> @old_isauto_v152spositiontaking_52
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=152 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    
    --Copy preset to member
    IF @IsCopyPreset152_41 = 1
    BEGIN
        update cs 
        set spositiontaking = b.spositiontaking
        from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            inner join 
                (
                                select 152 as sporttype, 41 as bettype, @isauto_v152spositiontaking_41 as isautopositiontaking, @old_isauto_v152spositiontaking_41 as oldisautopositiontaking, @v152spositiontaking_41 as spositiontaking
                    union all    select 152 as sporttype, 42 as bettype, @isauto_v152spositiontaking_42 as isautopositiontaking, @old_isauto_v152spositiontaking_42 as oldisautopositiontaking, @v152spositiontaking_42 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
    END
    IF @IsCopyPreset152_51 = 1
    BEGIN
        update cs 
        set spositiontaking = b.spositiontaking
        from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            inner join 
                (
                                select 152 as sporttype, 51 as bettype, @isauto_v152spositiontaking_51 as isautopositiontaking, @old_isauto_v152spositiontaking_51 as oldisautopositiontaking, @v152spositiontaking_51 as spositiontaking
                    union all    select 152 as sporttype, 52 as bettype, @isauto_v152spositiontaking_52 as isautopositiontaking, @old_isauto_v152spositiontaking_52 as oldisautopositiontaking, @v152spositiontaking_52 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
    END

END--@UpdatePositiontakingv152

if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
BEGIN --@UpdatePositiontakingv153
    --153_51
    if (@auto_v153spositiontaking_51 <> @old_auto_v153spositiontaking_51 or @isauto_v153spositiontaking_51 <> @old_isauto_v153spositiontaking_51) and @UpdatePositiontakingv153_51 = 1
    BEGIN
        if @isauto_v153spositiontaking_51 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=153 and bettype = 51
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v153spositiontaking_51 then @auto_v153spositiontaking_51 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=153 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v153spositiontaking_51 <> @old_isauto_v153spositiontaking_51
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 51 and cs.sporttype=153 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    

    --153_52
    if (@auto_v153spositiontaking_52 <> @old_auto_v153spositiontaking_52 or @isauto_v153spositiontaking_52 <> @old_isauto_v153spositiontaking_52) and @UpdatePositiontakingv153_51 = 1
    BEGIN
        if @isauto_v153spositiontaking_52 >0
        BEGIN
            select @maxpos = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and sporttype=153 and bettype = 52
            update cs 
                set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@auto_v153spositiontaking_52 then @auto_v153spositiontaking_52 else @maxpos - mpositiontaking-apositiontaking end
            from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
            where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=153 and cs.isautopositiontaking=0
            if @@Error <> 0
            BEGIN
                
                SELECT @ErrMsg = @UserName + ': ' + 
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=219
                return
            END
        END
        else if @isauto_v153spositiontaking_52 <> @old_isauto_v153spositiontaking_52
        BEGIN
            if @updateallmembers = 1
            BEGIN
                update cs
                    set spositiontaking = case when mcs.spositiontaking<@newspositiontaking then mcs.spositiontaking else @newspositiontaking end
                from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
                inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
                inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @custid and cs.sporttype=mcs.sporttype and cs.bettype=mcs.bettype
                where c.mrecommend = @custid and c.roleid = 1 and cs.bettype = 52 and cs.sporttype=153 and cs.isautopositiontaking=0
                if @@Error <> 0
                BEGIN
                    
                    SELECT @ErrMsg = @UserName + ': ' +
                        case @Language 
                            when 'E' then 'Error updating auto position taking '
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
                        end    
                        ,  @ErrCode=220
                    return
                END
            END
        END
    END    
    --Copy preset to member
    IF @IsCopyPreset153_51 = 1
    BEGIN
        update cs 
        set spositiontaking = b.spositiontaking
        from CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
            inner join custinfo ci (nolock) on ci.custid = cs.custid and ci.mrecommend = @custid and ci.roleid = 1
            inner join 
                (
                                select 153 as sporttype, 51 as bettype, @isauto_v153spositiontaking_51 as isautopositiontaking, @old_isauto_v153spositiontaking_51 as oldisautopositiontaking, @v153spositiontaking_51 as spositiontaking
                    union all    select 153 as sporttype, 52 as bettype, @isauto_v153spositiontaking_52 as isautopositiontaking, @old_isauto_v153spositiontaking_52 as oldisautopositiontaking, @v153spositiontaking_52 as spositiontaking
                ) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
        where b.isautopositiontaking = 0 and b.oldisautopositiontaking = 0  
    END
    
END--@UpdatePositiontakingv153
*/

EXEC dbo.Acc_CustSetting3rd_07 @srecommend = @srecommend, @mrecommend = @custid, @roleid = 3, @mode = 'horse'
/*
EXEC dbo.Acc_CustomerUpdMasterHR_MaxPositiontaking @mrecommend = @custid

*/
if (@@error <> 0)
begin
    
    Select @ErrMsg = @UserName + ': '+
                    case @Language 
                        when 'E' then 'Update process is unsuccessful !'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                    end, @ErrCode = 124                     
    
    return
end



Declare @LogSPData varchar(MAX),
        @TrackingValueDB varchar(5000)
    
Select @LogSPData = '<Acc_CustomerUpdMasterHR_Positiontaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_31="'+ coalesce(cast(@IsCopyPreset151_31 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_41="'+ coalesce(cast(@IsCopyPreset151_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_51="'+ coalesce(cast(@IsCopyPreset151_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_41="'+ coalesce(cast(@IsCopyPreset152_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_51="'+ coalesce(cast(@IsCopyPreset152_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset153_51="'+ coalesce(cast(@IsCopyPreset153_51 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

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
'v153spt_52="'+ coalesce(cast(@v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/>' +

'<au a_v151spt_31="'+ coalesce(cast(@auto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'a_v151spt_32="'+ coalesce(cast(@auto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'a_v151spt_41="'+ coalesce(cast(@auto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v151spt_42="'+ coalesce(cast(@auto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v151spt_51="'+ coalesce(cast(@auto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v151spt_52="'+ coalesce(cast(@auto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v152spt_41="'+ coalesce(cast(@auto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v152spt_42="'+ coalesce(cast(@auto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v152spt_51="'+ coalesce(cast(@auto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v152spt_52="'+ coalesce(cast(@auto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v153spt_51="'+ coalesce(cast(@auto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v153spt_52="'+ coalesce(cast(@auto_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/>' +

'<ia isa_v151spt_31="'+ coalesce(cast(@isauto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_32="'+ coalesce(cast(@isauto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_41="'+ coalesce(cast(@isauto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_42="'+ coalesce(cast(@isauto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_51="'+ coalesce(cast(@isauto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_52="'+ coalesce(cast(@isauto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_41="'+ coalesce(cast(@isauto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_42="'+ coalesce(cast(@isauto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_51="'+ coalesce(cast(@isauto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_52="'+ coalesce(cast(@isauto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_51="'+ coalesce(cast(@isauto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_52="'+ coalesce(cast(@isauto_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/>' +

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
'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/></Acc_CustomerUpdMasterHR_Positiontaking>'


Select @TrackingValueDB = '<Acc_CustomerUpdMasterHR_Positiontaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_31="'+ coalesce(cast(@IsCopyPreset151_31 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_41="'+ coalesce(cast(@IsCopyPreset151_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset_51="'+ coalesce(cast(@IsCopyPreset151_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_41="'+ coalesce(cast(@IsCopyPreset152_41 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset152_51="'+ coalesce(cast(@IsCopyPreset152_51 as varchar(50)),space(1)) + '" ' +
'IsCopyPreset153_51="'+ coalesce(cast(@IsCopyPreset153_51 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

'<s v151spt_31="'+ coalesce(cast(@old_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151spt_32="'+ coalesce(cast(@old_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151spt_41="'+ coalesce(cast(@old_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151spt_42="'+ coalesce(cast(@old_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151spt_51="'+ coalesce(cast(@old_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v151spt_52="'+ coalesce(cast(@old_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v152spt_41="'+ coalesce(cast(@old_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v152spt_42="'+ coalesce(cast(@old_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v152spt_51="'+ coalesce(cast(@old_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v152spt_52="'+ coalesce(cast(@old_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v153spt_51="'+ coalesce(cast(@old_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v153spt_52="'+ coalesce(cast(@old_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/>' +

'<au a_v151spt_31="'+ coalesce(cast(@old_auto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'a_v151spt_32="'+ coalesce(cast(@old_auto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'a_v151spt_41="'+ coalesce(cast(@old_auto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v151spt_42="'+ coalesce(cast(@old_auto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v151spt_51="'+ coalesce(cast(@old_auto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v151spt_52="'+ coalesce(cast(@old_auto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v152spt_41="'+ coalesce(cast(@old_auto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v152spt_42="'+ coalesce(cast(@old_auto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v152spt_51="'+ coalesce(cast(@old_auto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v152spt_52="'+ coalesce(cast(@old_auto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v153spt_51="'+ coalesce(cast(@old_auto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v153spt_52="'+ coalesce(cast(@old_auto_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/>' +

'<ia isa_v151spt_31="'+ coalesce(cast(@old_isauto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_32="'+ coalesce(cast(@old_isauto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_41="'+ coalesce(cast(@old_isauto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_42="'+ coalesce(cast(@old_isauto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_51="'+ coalesce(cast(@old_isauto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_52="'+ coalesce(cast(@old_isauto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_41="'+ coalesce(cast(@old_isauto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_42="'+ coalesce(cast(@old_isauto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_51="'+ coalesce(cast(@old_isauto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_52="'+ coalesce(cast(@old_isauto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_51="'+ coalesce(cast(@old_isauto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_52="'+ coalesce(cast(@old_isauto_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/>' +

'<m v151mpt_31="'+ coalesce(cast(@old_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151mpt_32="'+ coalesce(cast(@old_v151mpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151mpt_41="'+ coalesce(cast(@old_v151mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151mpt_42="'+ coalesce(cast(@old_v151mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151mpt_51="'+ coalesce(cast(@old_v151mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v151mpt_52="'+ coalesce(cast(@old_v151mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v152mpt_41="'+ coalesce(cast(@old_v152mpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v152mpt_42="'+ coalesce(cast(@old_v152mpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v152mpt_51="'+ coalesce(cast(@old_v152mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v152mpt_52="'+ coalesce(cast(@old_v152mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v153mpt_51="'+ coalesce(cast(@old_v153mpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v153mpt_52="'+ coalesce(cast(@old_v153mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'/></Acc_CustomerUpdMasterHR_Positiontaking>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
BEGIN TRY
    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 419,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END TRY
BEGIN CATCH        
    Select @LogSPData = '<Acc_CustomerUpdMasterHR_Positiontaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
    'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
    'IsCopyPreset_31="'+ coalesce(cast(@IsCopyPreset151_31 as varchar(50)),space(1)) + '" ' +
    'IsCopyPreset_41="'+ coalesce(cast(@IsCopyPreset151_41 as varchar(50)),space(1)) + '" ' +
    'IsCopyPreset_51="'+ coalesce(cast(@IsCopyPreset151_51 as varchar(50)),space(1)) + '" ' +
    'IsCopyPreset152_41="'+ coalesce(cast(@IsCopyPreset152_41 as varchar(50)),space(1)) + '" ' +
    'IsCopyPreset152_51="'+ coalesce(cast(@IsCopyPreset152_51 as varchar(50)),space(1)) + '" ' +
    'IsCopyPreset153_51="'+ coalesce(cast(@IsCopyPreset153_51 as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ ERROR_MESSAGE() + '" />' +

    '<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
    'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
    'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
    'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
    'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
    'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
    'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

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
    'v153spt_52="'+ coalesce(cast(@v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    '/>' +

    '<au a_v151spt_31="'+ coalesce(cast(@auto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'a_v151spt_32="'+ coalesce(cast(@auto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'a_v151spt_41="'+ coalesce(cast(@auto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'a_v151spt_42="'+ coalesce(cast(@auto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'a_v151spt_51="'+ coalesce(cast(@auto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'a_v151spt_52="'+ coalesce(cast(@auto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'a_v152spt_41="'+ coalesce(cast(@auto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'a_v152spt_42="'+ coalesce(cast(@auto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'a_v152spt_51="'+ coalesce(cast(@auto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'a_v152spt_52="'+ coalesce(cast(@auto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'a_v153spt_51="'+ coalesce(cast(@auto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'a_v153spt_52="'+ coalesce(cast(@auto_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    '/>' +

    '<ia isa_v151spt_31="'+ coalesce(cast(@isauto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
    'isa_v151spt_32="'+ coalesce(cast(@isauto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
    'isa_v151spt_41="'+ coalesce(cast(@isauto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'isa_v151spt_42="'+ coalesce(cast(@isauto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'isa_v151spt_51="'+ coalesce(cast(@isauto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'isa_v151spt_52="'+ coalesce(cast(@isauto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'isa_v152spt_41="'+ coalesce(cast(@isauto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
    'isa_v152spt_42="'+ coalesce(cast(@isauto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
    'isa_v152spt_51="'+ coalesce(cast(@isauto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'isa_v152spt_52="'+ coalesce(cast(@isauto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    'isa_v153spt_51="'+ coalesce(cast(@isauto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
    'isa_v153spt_52="'+ coalesce(cast(@isauto_v153spositiontaking_52 as varchar(50)),space(1)) + '" ' +
    '/>' +

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
    'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" ' +
    '/></Acc_CustomerUpdMasterHR_Positiontaking>'
    
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 419,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END CATCH

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterHR_Positiontaking] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterHR_Positiontaking] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterHR_Positiontaking] TO [bodbDownlineNet]
GO 
