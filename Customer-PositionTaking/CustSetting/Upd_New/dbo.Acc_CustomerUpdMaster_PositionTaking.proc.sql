ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_PositionTaking]
    @custid int,-- masterid    
    
    @spositiontaking_1 smallmoney,
    @spositiontaking_2 smallmoney,
    @spositiontaking_3 smallmoney,
    @spositiontaking_4 smallmoney,
    @spositiontaking_5 smallmoney,
    @spositiontaking_6 smallmoney,
    @spositiontaking_7 smallmoney,
    @spositiontaking_8 smallmoney,
    @spositiontaking_9 smallmoney,
    @spositiontaking_10 smallmoney,
    @spositiontaking_9999 smallmoney = 0,
    @slivepositiontaking_1 smallmoney,
    @slivepositiontaking_3 smallmoney,
    @slivepositiontaking_7 smallmoney,
    @slivepositiontaking_8 smallmoney,
    
    @v2spositiontaking_1 smallmoney,
    @v2spositiontaking_2 smallmoney,
    @v2spositiontaking_3 smallmoney,
    @v2spositiontaking_7 smallmoney,
    @v2spositiontaking_8 smallmoney,
--    @v2spositiontaking_9 smallmoney,
    @v2spositiontaking_20 smallmoney,
    
    @v3spositiontaking_1 smallmoney,
    @v3spositiontaking_2 smallmoney,
    @v3spositiontaking_3 smallmoney,    
    @v3spositiontaking_20 smallmoney,
    
    @v5spositiontaking_1 smallmoney,
    @v5spositiontaking_2 smallmoney,
    @v5spositiontaking_3 smallmoney,    
    @v5spositiontaking_20 smallmoney,
    @v5spositiontaking_9999 smallmoney = 0,
    
    @v8spositiontaking_1 smallmoney,
    @v8spositiontaking_3 smallmoney,    
    @v8spositiontaking_20 smallmoney,
    
    @v10spositiontaking_1 smallmoney,
    @v10spositiontaking_2 smallmoney,
    @v10spositiontaking_3 smallmoney,    
    @v10spositiontaking_20 smallmoney,
    
    @v11spositiontaking_1 smallmoney,
    @v11spositiontaking_20 smallmoney,
    
    @v99spositiontaking_1 smallmoney,
    @v99spositiontaking_2 smallmoney,
    @v99spositiontaking_3 smallmoney,    
    @v99spositiontaking_20 smallmoney,    

    -- mixed sports
    @v99spositiontaking_9 smallmoney,
    
    --HR Fixed Odds
    @v154spositiontaking_20 SMALLMONEY = 0,
    
    -- number game
    @v161spositiontaking_81 smallmoney,
    @v161spositiontaking_83 smallmoney,    
    @v161spositiontaking_86 smallmoney,
    @v161spositiontaking_88 smallmoney = 0,
    @v161slivepositiontaking_85 smallmoney,
    @v161slivepositiontaking_86 smallmoney,
    @v161slivepositiontaking_87 smallmoney,
    @v161slivepositiontaking_89 smallmoney = 0,
    @v161slivepositiontaking_90 smallmoney = 0,
    
    @auto_spositiontaking_1 smallmoney = 0,
    @auto_spositiontaking_2 smallmoney = 0,
    @auto_spositiontaking_3 smallmoney = 0,
    @auto_spositiontaking_4 smallmoney = 0,
    @auto_spositiontaking_5 smallmoney = 0,
    @auto_spositiontaking_6 smallmoney = 0,
    @auto_spositiontaking_7 smallmoney = 0,
    @auto_spositiontaking_8 smallmoney = 0,
    @auto_spositiontaking_9 smallmoney = 0,
    @auto_spositiontaking_10 smallmoney = 0,
    @auto_spositiontaking_9999 smallmoney = 0,
    @auto_slivepositiontaking_1 smallmoney = 0,
    @auto_slivepositiontaking_3 smallmoney = 0,
    @auto_slivepositiontaking_7 smallmoney = 0,
    @auto_slivepositiontaking_8 smallmoney = 0,
    
    @auto_v2spositiontaking_1 smallmoney = 0,
    @auto_v2spositiontaking_2 smallmoney = 0,
    @auto_v2spositiontaking_3 smallmoney = 0,
    @auto_v2spositiontaking_7 smallmoney = 0,
    @auto_v2spositiontaking_8 smallmoney = 0,
--    @auto_v2spositiontaking_9 smallmoney = 0,
    @auto_v2spositiontaking_20 smallmoney = 0,
    
    @auto_v3spositiontaking_1 smallmoney = 0,
    @auto_v3spositiontaking_2 smallmoney = 0,
    @auto_v3spositiontaking_3 smallmoney = 0,
    @auto_v3spositiontaking_20 smallmoney = 0,
    
    @auto_v5spositiontaking_1 smallmoney = 0,
    @auto_v5spositiontaking_2 smallmoney = 0,
    @auto_v5spositiontaking_3 smallmoney = 0,
    @auto_v5spositiontaking_20 smallmoney = 0,
    @auto_v5spositiontaking_9999 smallmoney = 0,
    
    @auto_v8spositiontaking_1 smallmoney = 0,
    @auto_v8spositiontaking_3 smallmoney = 0,
    @auto_v8spositiontaking_20 smallmoney = 0,
    
    @auto_v10spositiontaking_1 smallmoney = 0,
    @auto_v10spositiontaking_2 smallmoney = 0,
    @auto_v10spositiontaking_3 smallmoney = 0,
    @auto_v10spositiontaking_20 smallmoney = 0,
    
    @auto_v11spositiontaking_1 smallmoney = 0,
    @auto_v11spositiontaking_20 smallmoney = 0,

    @auto_v99spositiontaking_1 smallmoney = 0,
    @auto_v99spositiontaking_2 smallmoney = 0,
    @auto_v99spositiontaking_3 smallmoney = 0,
    @auto_v99spositiontaking_20 smallmoney = 0,    

    -- mixed sports
    @auto_v99spositiontaking_9 smallmoney = 0,
    
    --HR Fixed Odds
    @auto_v154spositiontaking_20 SMALLMONEY = 0,
    
    -- number game
    @auto_v161spositiontaking_81 smallmoney = 0,
    @auto_v161spositiontaking_83 smallmoney = 0,    
    @auto_v161spositiontaking_86 smallmoney = 0,
    @auto_v161spositiontaking_88 smallmoney = 0,
    @auto_v161slivepositiontaking_85 smallmoney = 0,
    @auto_v161slivepositiontaking_86 smallmoney = 0,
    @auto_v161slivepositiontaking_87 smallmoney = 0,
    @auto_v161slivepositiontaking_89 smallmoney = 0,
    @auto_v161slivepositiontaking_90 smallmoney = 0,
    
    @isauto_spositiontaking_1 bit = 0,
    @isauto_spositiontaking_2 bit = 0,
    @isauto_spositiontaking_3 bit = 0,
    @isauto_spositiontaking_4 bit = 0,
    @isauto_spositiontaking_5 bit = 0,
    @isauto_spositiontaking_6 bit = 0,
    @isauto_spositiontaking_7 bit = 0,
    @isauto_spositiontaking_8 bit = 0,
    @isauto_spositiontaking_9 bit = 0,
    @isauto_spositiontaking_10 bit = 0,
    @isauto_spositiontaking_9999 bit = 0,
    @isauto_slivepositiontaking_1 bit = 0,
    @isauto_slivepositiontaking_3 bit = 0,
    @isauto_slivepositiontaking_7 bit = 0,
    @isauto_slivepositiontaking_8 bit = 0,
    
    @isauto_v2spositiontaking_1 bit = 0,
    @isauto_v2spositiontaking_2 bit = 0,
    @isauto_v2spositiontaking_3 bit = 0,
    @isauto_v2spositiontaking_7 bit = 0,
    @isauto_v2spositiontaking_8 bit = 0,
--    @isauto_v2spositiontaking_9 bit = 0,
    @isauto_v2spositiontaking_20 bit = 0,
    
    @isauto_v3spositiontaking_1 bit = 0,
    @isauto_v3spositiontaking_2 bit = 0,
    @isauto_v3spositiontaking_3 bit = 0,
    @isauto_v3spositiontaking_20 bit = 0,
    
    @isauto_v5spositiontaking_1 bit = 0,
    @isauto_v5spositiontaking_2 bit = 0,
    @isauto_v5spositiontaking_3 bit = 0,
    @isauto_v5spositiontaking_20 bit = 0,
    @isauto_v5spositiontaking_9999 bit = 0,
    
    @isauto_v8spositiontaking_1 bit = 0,
    @isauto_v8spositiontaking_3 bit = 0,
    @isauto_v8spositiontaking_20 bit = 0,
    
    @isauto_v10spositiontaking_1 bit = 0,
    @isauto_v10spositiontaking_2 bit = 0,
    @isauto_v10spositiontaking_3 bit = 0,
    @isauto_v10spositiontaking_20 bit = 0,
    
    @isauto_v11spositiontaking_1 bit = 0,
    @isauto_v11spositiontaking_20 bit = 0,
    
    @isauto_v99spositiontaking_1 bit = 0,
    @isauto_v99spositiontaking_2 bit = 0,
    @isauto_v99spositiontaking_3 bit = 0,
    @isauto_v99spositiontaking_20 bit = 0,    

    -- mixed sports
    @isauto_v99spositiontaking_9 bit = 0,

    --HR Fixed Odds
    @isauto_v154spositiontaking_20 bit = 0,
    
    -- number game
    @isauto_v161spositiontaking_81 bit = 0,
    @isauto_v161spositiontaking_83 bit = 0,    
    @isauto_v161spositiontaking_86 bit = 0,
    @isauto_v161spositiontaking_88 bit = 0,
    @isauto_v161slivepositiontaking_85 bit = 0,
    @isauto_v161slivepositiontaking_86 bit = 0,
    @isauto_v161slivepositiontaking_87 bit = 0,
    @isauto_v161slivepositiontaking_89 bit = 0,
    @isauto_v161slivepositiontaking_90 bit = 0,
    
    @mpositiontaking_1 smallmoney = 0.7,
    @mpositiontaking_2 smallmoney = 0.7,
    @mpositiontaking_3 smallmoney = 0.7,
    @mpositiontaking_4 smallmoney = 0.7,
    @mpositiontaking_5 smallmoney = 0.7,
    @mpositiontaking_6 smallmoney = 0.7,
    @mpositiontaking_7 smallmoney = 0.7,
    @mpositiontaking_8 smallmoney = 0.7,
    @mpositiontaking_9 smallmoney = 0.7,
    @mpositiontaking_10 smallmoney = 0.7,
    @mpositiontaking_9999 smallmoney = 0.7,
    @mlivepositiontaking_1 smallmoney = 0.7,
    @mlivepositiontaking_3 smallmoney = 0.7,
    @mlivepositiontaking_7 smallmoney = 0.7,
    @mlivepositiontaking_8 smallmoney = 0.7,
    
    @v2mpositiontaking_1 smallmoney = 0.7,
    @v2mpositiontaking_2 smallmoney = 0.7,
    @v2mpositiontaking_3 smallmoney = 0.7,
    @v2mpositiontaking_7 smallmoney = 0.7,
    @v2mpositiontaking_8 smallmoney = 0.7,
--    @v2mpositiontaking_9 smallmoney = 0.7,
    @v2mpositiontaking_20 smallmoney = 0.7,
    
    @v3mpositiontaking_1 smallmoney = 0.7,
    @v3mpositiontaking_2 smallmoney = 0.7,
    @v3mpositiontaking_3 smallmoney = 0.7,
    @v3mpositiontaking_20 smallmoney = 0.7,
    
    @v5mpositiontaking_1 smallmoney = 0.7,
    @v5mpositiontaking_2 smallmoney = 0.7,
    @v5mpositiontaking_3 smallmoney = 0.7,
    @v5mpositiontaking_20 smallmoney = 0.7,
    @v5mpositiontaking_9999 smallmoney = 0.7,
    
    @v8mpositiontaking_1 smallmoney = 0.7,
    @v8mpositiontaking_3 smallmoney = 0.7,
    @v8mpositiontaking_20 smallmoney = 0.7,
    
    @v10mpositiontaking_1 smallmoney = 0.7,
    @v10mpositiontaking_2 smallmoney = 0.7,
    @v10mpositiontaking_3 smallmoney = 0.7,
    @v10mpositiontaking_20 smallmoney = 0.7,
    
    @v11mpositiontaking_1 smallmoney = 0.7,
    @v11mpositiontaking_20 smallmoney = 0.7,

    @v99mpositiontaking_1 smallmoney = 0.7,
    @v99mpositiontaking_2 smallmoney = 0.7,
    @v99mpositiontaking_3 smallmoney = 0.7,
    @v99mpositiontaking_20 smallmoney = 0.7,

    -- mixed sports
    @v99mpositiontaking_9 smallmoney = 0.7,
    
    --HR Fixed Odds
    @v154mpositiontaking_20 smallmoney = 0.7,
    
    -- number game
    @v161mpositiontaking_81 smallmoney = 0.7,
    @v161mpositiontaking_83 smallmoney = 0.7,    
    @v161mpositiontaking_86 smallmoney = 0.7,
    @v161mpositiontaking_88 smallmoney = 0.7,
    @v161mlivepositiontaking_85 smallmoney = 0.7,
    @v161mlivepositiontaking_86 smallmoney = 0.7,
    @v161mlivepositiontaking_87 smallmoney = 0.7,
    @v161mlivepositiontaking_89 smallmoney = 0.7,
    @v161mlivepositiontaking_90 smallmoney = 0.7,
    
    @updateallmembers bit = 0,
    @newspositiontaking smallmoney = 0,--equals max(s+m) - chosen(m)
    
    @UpdateMultiple bit = 0,    
    
    @UpdatePositiontaking bit = 1,
    @UpdatePositiontakingv2 bit = 1,
    @UpdatePositiontakingv3 bit = 1,
    @UpdatePositiontakingv5 bit = 1,
    @UpdatePositiontakingv8 bit = 1,
    @UpdatePositiontakingv10 bit = 1,
    @UpdatePositiontakingv11 bit = 1,
    @UpdatePositiontakingv99 bit = 1,    
    @UpdatePositiontakingv99MP bit = 1,
    @UpdatePositiontakingv154 bit = 1,
    @UpdatePositiontakingv161 bit = 1,
    
    -- Outright PT for sports
    @v2spositiontaking_10 smallmoney = 0,
	@v3spositiontaking_10 smallmoney = 0,
	@v5spositiontaking_10 smallmoney = 0,
	@v8spositiontaking_10 smallmoney = 0,
	@v10spositiontaking_10 smallmoney = 0,
	@v11spositiontaking_10 smallmoney = 0,
	@v99spositiontaking_10 smallmoney = 0,
	
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
	
	@isauto_v2spositiontaking_10 bit = 0,
	@isauto_v3spositiontaking_10 bit = 0,
	@isauto_v5spositiontaking_10 bit = 0,
	@isauto_v8spositiontaking_10 bit = 0,
	@isauto_v10spositiontaking_10 bit = 0,
	@isauto_v11spositiontaking_10 bit = 0,
	@isauto_v99spositiontaking_10 bit = 0,

	@v2mpositiontaking_10 smallmoney = 0.7,
	@v3mpositiontaking_10 smallmoney = 0.7,
	@v5mpositiontaking_10 smallmoney = 0.7,
	@v8mpositiontaking_10 smallmoney = 0.7,
	@v10mpositiontaking_10 smallmoney = 0.7,
	@v11mpositiontaking_10 smallmoney = 0.7,
	@v99mpositiontaking_10 smallmoney = 0.7,
				
    @SubAccID int = 0, --Sub-AccountID    
    
    @UserID int = 0,    
    @Language varchar(2) = 'E',
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
as

--@Source Control
/*
Created: 20080515@Thien
Task : Update Master's Position Taking
DB: DBTXN/CustDB
Original: Acc_CustomerUpdEditCustomer_SAg

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090628@Phuc: auto master PT on member level.
                    Write log subaccname instead of subaccid.
    - 20090917@Phuc: write log into DBLOG.
    - 20100112@Kiwi: amend to write log in xml format.
    - 20100903@Lukas:    - Add Number game Positiontaking
                        - Add Mixed sports Positiontaking
                        - Remove mix parlay of basketball Positiontaking
    - 20101019@Henry: Record execution time
    - 20110606@Amy: Write log Old values
    - 20110729@Lukas: (Number Game)
                - Add three new bettypes: Warrior, Next Combo, Number Group
                - Remove Dead ball Over/Under
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20131026@Thien: Checking total downlines before UPDATEs 
    - 20131030@Johnson: Apply execrep for recalculating pt on members
    - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
    - 20140623@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
    - 20140725@Logan: 1. Exclude disabled agents, members while updating super or master's seting [Redmine: #19631]
                      2. Code aligning
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, Use temp table for sports, bettype table)
	- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
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

declare @ErrAcc varchar(4000)
      , @ErrType varchar(4000)

declare @UserName varchar(30)
      , @srecommend int
      , @maxpos smallmoney
      ,    @maxdownlinepos smallmoney

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @UserName = username
     , @srecommend = srecommend
  from custinfo with(NOLOCK)
 where CustID = @CustID

Select @maxpos = 0.9
     , @maxdownlinepos = 0
-- th: @maxpos and @maxdownlinepos are no longer used
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---- Thien@20131026: Checking total downlines before UPDATEs 
EXEC Acc_CustomerSelCheckAllowedDownlines
    @custid = @custid
  , @roleid = 3
  , @isExecRep = 1
  , @isUpdatePT = 1
  ,    @Sporttype = 1
  ,    @Language = 'E'
  ,    @ErrMsg = @ErrMsg output
  ,    @ErrCode=@ErrCode output

IF    @ErrCode <> 0 
    RETURN 
----------

if @UpdateMultiple = 0 or @UpdatePositiontaking = 1
BEGIN
    IF @spositiontaking_1 < 0
        or @spositiontaking_2 < 0
        or @spositiontaking_3 < 0
        or @spositiontaking_4 < 0
        or @spositiontaking_5 < 0
        or @spositiontaking_6 < 0
        or @spositiontaking_7 < 0
        or @spositiontaking_8 < 0
        or @spositiontaking_9 < 0        
        or @spositiontaking_10 < 0
        or @spositiontaking_9999 < 0
        or @slivepositiontaking_1 < 0
        or @slivepositiontaking_3 < 0
        or @slivepositiontaking_7 < 0
        or @slivepositiontaking_8 < 0
        
        
        or @mpositiontaking_1 < 0
        or @mpositiontaking_2 < 0
        or @mpositiontaking_3 < 0
        or @mpositiontaking_4 < 0
        or @mpositiontaking_5 < 0
        or @mpositiontaking_6 < 0
        or @mpositiontaking_7 < 0
        or @mpositiontaking_8 < 0
        or @mpositiontaking_9 < 0
        or @mpositiontaking_9999 < 0
        or @mlivepositiontaking_1 < 0
        or @mlivepositiontaking_3 < 0
        or @mlivepositiontaking_7 < 0
        or @mlivepositiontaking_8 < 0
        or @mpositiontaking_10 < 0
        
        or @spositiontaking_1 + @mpositiontaking_1 > 0.9
        or @spositiontaking_2 + @mpositiontaking_2 > 0.9
        or @spositiontaking_3 + @mpositiontaking_3 > 0.9
        or @spositiontaking_4 + @mpositiontaking_4 > 0.9
        or @spositiontaking_5 + @mpositiontaking_5 > 0.9
        or @spositiontaking_6 + @mpositiontaking_6 > 0.9
        or @spositiontaking_7 + @mpositiontaking_7 > 0.9
        or @spositiontaking_8 + @mpositiontaking_8 > 0.9
        or @spositiontaking_9 + @mpositiontaking_9 > 0.9
        or @spositiontaking_10 + @mpositiontaking_10 > 0.9
        or @spositiontaking_9999 + @mpositiontaking_9999 > 0.9
        or @slivepositiontaking_1 + @mlivepositiontaking_1 > 0.9
        or @slivepositiontaking_3 + @mlivepositiontaking_3 > 0.9
        or @slivepositiontaking_7 + @mlivepositiontaking_7 > 0.9
        or @slivepositiontaking_8 + @mlivepositiontaking_8 > 0.9
        or @auto_spositiontaking_1 < 0
        or @auto_spositiontaking_2 < 0
        or @auto_spositiontaking_3 < 0
        or @auto_spositiontaking_4 < 0
        or @auto_spositiontaking_5 < 0
        or @auto_spositiontaking_6 < 0
        or @auto_spositiontaking_7 < 0
        or @auto_spositiontaking_8 < 0
        or @auto_spositiontaking_9 < 0
        or @auto_spositiontaking_10 < 0
        or @auto_spositiontaking_9999 < 0
        or @auto_slivepositiontaking_1 < 0
        or @auto_slivepositiontaking_3 < 0
        or @auto_slivepositiontaking_7 < 0
        or @auto_slivepositiontaking_8 < 0
        or @auto_spositiontaking_1 > 0.9
        or @auto_spositiontaking_2 > 0.9
        or @auto_spositiontaking_3 > 0.9
        or @auto_spositiontaking_4 > 0.9
        or @auto_spositiontaking_5 > 0.9
        or @auto_spositiontaking_6 > 0.9
        or @auto_spositiontaking_7 > 0.9
        or @auto_spositiontaking_8 > 0.9
        or @auto_spositiontaking_9 > 0.9
        or @auto_spositiontaking_10 > 0.9
        or @auto_spositiontaking_9999 > 0.9
        or @auto_slivepositiontaking_1 > 0.9
        or @auto_slivepositiontaking_3 > 0.9
        or @auto_slivepositiontaking_7 > 0.9
        or @auto_slivepositiontaking_8 > 0.9

		


    BEGIN
        SELECT @ErrCode = 5

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Wrong position taking (for Soccer).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
                 END
        RETURN
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    
--    select @ErrType = ''
--    select @ErrType = @ErrType + sportname + '-'+ typenamee + 
--    case when b.isauto_spositiontaking=0 then 
--        '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
--        + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end
--    else
--        '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
--        + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end
--    end

    SELECT @ErrType = ''

    SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: ' + cast((co.minpositiontaking) as varchar(10))
                    + '-Max: ' + cast((co.maxpositiontaking) AS VARCHAR(10))
                    + CASE
                        WHEN b.sporttype = 1 and b.bettype in (1, 3, 7, 8) THEN '--MinLive: '+ cast((co.minlivepositiontaking) AS VARCHAR(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) AS VARCHAR(10))
                        ELSE ''
                      END + '<br>'
      FROM custoverride co WITH(NOLOCK)
inner join (SELECT 1 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_1 AS spositiontaking
                 , @slivepositiontaking_1 AS slivepositiontaking
                 , @mpositiontaking_1 AS mpositiontaking
                 , @mlivepositiontaking_1 AS mlivepositiontaking
                 , @isauto_spositiontaking_1 AS isauto_spositiontaking
                 , @isauto_slivepositiontaking_1 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_1 AS auto_spositiontaking
                 , @auto_slivepositiontaking_1 AS auto_slivepositiontaking

  UNION ALL SELECT 3 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_3 AS spositiontaking
                 , @slivepositiontaking_3 AS slivepositiontaking
                 , @mpositiontaking_3 AS mpositiontaking
                 , @mlivepositiontaking_3 AS mlivepositiontaking
                 , @isauto_spositiontaking_3 AS isauto_spositiontaking
                 , @isauto_slivepositiontaking_3 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_3 AS auto_spositiontaking
                 , @auto_slivepositiontaking_3 AS auto_slivepositiontaking

  UNION ALL SELECT 7 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_7 AS spositiontaking
                 , @slivepositiontaking_7 AS slivepositiontaking
                 , @mpositiontaking_7 AS mpositiontaking
                 , @mlivepositiontaking_7 AS mlivepositiontaking
                 , @isauto_spositiontaking_7 AS isauto_spositiontaking
                 , @isauto_slivepositiontaking_7 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_7 AS auto_spositiontaking
                 , @auto_slivepositiontaking_7 AS auto_slivepositiontaking

  UNION ALL SELECT 8 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_8 AS spositiontaking
                 , @slivepositiontaking_8 AS slivepositiontaking
                 , @mpositiontaking_8 AS mpositiontaking
                 , @mlivepositiontaking_8 AS mlivepositiontaking
                 , @isauto_spositiontaking_8 AS isauto_spositiontaking
                 , @isauto_slivepositiontaking_8 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_8 AS auto_spositiontaking
                 , @auto_slivepositiontaking_8 AS auto_slivepositiontaking

  UNION ALL SELECT 2 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_2 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_2 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_2 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_2 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

  UNION ALL SELECT 4 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_4 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_4 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_4 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_4 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

  UNION ALL SELECT 5 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_5 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_5 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_5 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_5 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

  UNION ALL SELECT 6 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_6 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_6 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_6 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_6 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

  UNION ALL SELECT 9 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_9 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_9 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_9 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_9 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

  UNION ALL SELECT 10 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_10 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_10 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_10 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_10 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

  UNION ALL SELECT 9999 AS bettype
                 , 1 AS sporttype
                 , @spositiontaking_9999 AS spositiontaking
                 , 0 AS slivepositiontaking
                 , @mpositiontaking_9999 AS mpositiontaking
                 , 0 AS mlivepositiontaking
                 , @isauto_spositiontaking_9999 AS isauto_spositiontaking
                 , 0 AS isauto_slivepositiontaking
                 , @auto_spositiontaking_9999 AS auto_spositiontaking
                 , 0 AS auto_slivepositiontaking

           ) AS b ON co.sporttype = b.sporttype and co.bettype = b.bettype
INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
     WHERE co.custid = @srecommend
       AND ((b.isauto_spositiontaking = 0
             AND (b.spositiontaking + b.mpositiontaking > co.maxpositiontaking
                  OR b.spositiontaking + b.mpositiontaking < co.minpositiontaking
                 )
            )
            OR (b.isauto_spositiontaking > 0
                AND (b.mpositiontaking > co.maxpositiontaking
                     OR b.mpositiontaking + b.auto_spositiontaking < co.minpositiontaking
                    )
               )
            OR (b.sporttype = 1
                AND b.bettype in (1, 3, 7, 8)
                AND b.isauto_slivepositiontaking = 0
                AND (b.slivepositiontaking + b.mlivepositiontaking > co.maxlivepositiontaking
                     OR b.slivepositiontaking + b.mlivepositiontaking < co.minlivepositiontaking
                    )
               )
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND b.isauto_slivepositiontaking > 0
                AND (b.mlivepositiontaking > co.maxlivepositiontaking
                     OR b.mlivepositiontaking + b.auto_slivepositiontaking < co.minlivepositiontaking
                    )
               )
           )

    if @ErrType <> ''
    BEGIN
        SELECT @ErrCode = 6

        SELECT @ErrMsg = CASE @Language 
                           WHEN 'E' THEN 'Wrong position taking (min/max set by company).<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType
                          END
        RETURN
    END

    --check n3<=m3<=l3 
    SELECT @ErrType = ''

    SELECT @ErrType = @ErrType + sportname + '-' + typenamee + '-Min: '
                    + CAST((co.minpositiontaking) AS VARCHAR(10)) + '-Max: '
                    + CAST((co.maxpositiontaking) AS VARCHAR(10))
                    + CASE
                        WHEN b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '--MinLive: ' + cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10))
                        ELSE ''
                      END + '<br>'
      FROM custoverride co WITH(NOLOCK)
INNER JOIN (SELECT 1 AS bettype
                 , 1 as sporttype
                 , @spositiontaking_1 as spositiontaking
                 , @slivepositiontaking_1 as slivepositiontaking
                 , @mpositiontaking_1 as mpositiontaking
                 , @mlivepositiontaking_1 as mlivepositiontaking
                 , @isauto_spositiontaking_1 as isauto_spositiontaking
                 , @isauto_slivepositiontaking_1 as isauto_slivepositiontaking

  union all select 3 as bettype
                 , 1 as sporttype
                 , @spositiontaking_3 as spositiontaking
                 , @slivepositiontaking_3 as slivepositiontaking
                 , @mpositiontaking_3 as mpositiontaking
                 , @mlivepositiontaking_3 as mlivepositiontaking
                 , @isauto_spositiontaking_3 as isauto_spositiontaking
                 , @isauto_slivepositiontaking_3 as isauto_slivepositiontaking

  union all select 7 as bettype
                 , 1 as sporttype
                 , @spositiontaking_7 as spositiontaking
                 , @slivepositiontaking_7 as slivepositiontaking
                 , @mpositiontaking_7 as mpositiontaking
                 , @mlivepositiontaking_7 as mlivepositiontaking
                 , @isauto_spositiontaking_7 as isauto_spositiontaking
                 , @isauto_slivepositiontaking_7 as isauto_slivepositiontaking

  union all select 8 as bettype
                 , 1 as sporttype
                 , @spositiontaking_8 as spositiontaking
                 , @slivepositiontaking_8 as slivepositiontaking
                 , @mpositiontaking_8 as mpositiontaking
                 , @mlivepositiontaking_8 as mlivepositiontaking
                 , @isauto_spositiontaking_8 as isauto_spositiontaking
                 , @isauto_slivepositiontaking_8 as isauto_slivepositiontaking

  union all select 2 as bettype
                 , 1 as sporttype
                 , @spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_2 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 4 as bettype
                 , 1 as sporttype
                 , @spositiontaking_4 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_4 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_4 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 5 as bettype
                 , 1 as sporttype
                 , @spositiontaking_5 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_5 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_5 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 6 as bettype
                 , 1 as sporttype
                 , @spositiontaking_6 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_6 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_6 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 9 as bettype
                 , 1 as sporttype
                 , @spositiontaking_9 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_9 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_9 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 10 as bettype
                 , 1 as sporttype
                 , @spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_10 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                   	                   	                   	                   	                   	                   	                   	
  union all select 9999 as bettype
                 , 1 as sporttype
                 , @spositiontaking_9999 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_9999 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_spositiontaking_9999 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
           ) as b on co.sporttype = b.sporttype and co.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where co.custid = @custid
       and (b.mpositiontaking > co.maxpositiontaking
            or b.mpositiontaking < co.minpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and (b.mlivepositiontaking > co.maxlivepositiontaking
                     or b.mlivepositiontaking < co.minlivepositiontaking
                    )
               )
           )

    if @ErrType <> ''
    BEGIN
        select @ErrCode = 7

        Select @ErrMsg = @UserName + ': '
                         + case @Language 
                             when 'E' then 'Wrong position taking (min/max set by company).<br>' + @ErrType
                             ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType
                           end
        return
    END

    --a2+m2<=m3
    select @ErrAcc = ''
    --select top 100 @ErrAcc = @ErrAcc + username + ' (' + sportname + '-' + typenamee + ') <br>'
    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with (NOLOCK)
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 1 as sporttype
                 , 1 as bettype
                 , @mpositiontaking_1 as maxpositiontaking
                 , @mlivepositiontaking_1 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 2 as bettype
                 , @mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 3 as bettype
                 , @mpositiontaking_3 as maxpositiontaking
                 , @mlivepositiontaking_3 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 4 as bettype
                 , @mpositiontaking_4 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 5 as bettype
                 , @mpositiontaking_5 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 6 as bettype
                 , @mpositiontaking_6 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 7 as bettype
                 , @mpositiontaking_7 as maxpositiontaking
                 , @mlivepositiontaking_7 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 8 as bettype
                 , @mpositiontaking_8 as maxpositiontaking
                 , @mlivepositiontaking_8 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 9 as bettype
                 , @mpositiontaking_9 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 10 as bettype
                 , @mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking
                                                                                                                       
  union all select 1 as sporttype
                 , 9999 as bettype
                 , @mpositiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
        --INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        --INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where c.mrecommend = @custid
       AND c.Enabled    = 1
       and c.roleid     = 2
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username--, sportname, typenamee

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 8

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Soccer).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](1, @Language) + ')'
                           end
        return
    END

    --a1+m1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 1 AS sporttype
                 , 1 AS bettype
                 , @mpositiontaking_1 AS maxpositiontaking
                 , @mlivepositiontaking_1 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 2 AS bettype
                 , @mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 3 AS bettype
                 , @mpositiontaking_3 AS maxpositiontaking
                 , @mlivepositiontaking_3 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 4 AS bettype
                 , @mpositiontaking_4 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 5 AS bettype
                 , @mpositiontaking_5 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 6 AS bettype
                 , @mpositiontaking_6 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 7 AS bettype
                 , @mpositiontaking_7 AS maxpositiontaking
                 , @mlivepositiontaking_7 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 8 AS bettype
                 , @mpositiontaking_8 AS maxpositiontaking
                 , @mlivepositiontaking_8 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 9 AS bettype
                 , @mpositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 10 AS bettype
                 , @mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

                                                                                             
  UNION ALL SELECT 1 AS sporttype
                 , 9999 AS bettype
                 , @mpositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid = 1
       AND c.Enabled = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 9

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Soccer).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](1, @Language) + ')'
                  END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Max: '
                    + cast((scs.mpositiontaking) as varchar(10))
                    + case
                        when b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custsetting scs with(NOLOCK)
inner join (select 1 as bettype
                 , 1 as sporttype
                 , @spositiontaking_1 as spositiontaking
                 , @slivepositiontaking_1 as slivepositiontaking
                 , @mpositiontaking_1 as mpositiontaking
                 , @mlivepositiontaking_1 as mlivepositiontaking
                 , @auto_spositiontaking_1 as auto_spositiontaking
                 , @auto_slivepositiontaking_1 as auto_slivepositiontaking

  union all select 3 as bettype
                 , 1 as sporttype
                 , @spositiontaking_3 as spositiontaking
                 , @slivepositiontaking_3 as slivepositiontaking
                 , @mpositiontaking_3 as mpositiontaking
                 , @mlivepositiontaking_3 as mlivepositiontaking
                 , @auto_spositiontaking_3 as auto_spositiontaking
                 , @auto_slivepositiontaking_3 as auto_slivepositiontaking

  union all select 7 as bettype
                 , 1 as sporttype
                 , @spositiontaking_7 as spositiontaking
                 , @slivepositiontaking_7 as slivepositiontaking
                 , @mpositiontaking_7 as mpositiontaking
                 , @mlivepositiontaking_7 as mlivepositiontaking
                 , @auto_spositiontaking_7 as auto_spositiontaking
                 , @auto_slivepositiontaking_7 as auto_slivepositiontaking

  union all select 8 as bettype
                 , 1 as sporttype
                 , @spositiontaking_8 as spositiontaking
                 , @slivepositiontaking_8 as slivepositiontaking
                 , @mpositiontaking_8 as mpositiontaking
                 , @mlivepositiontaking_8 as mlivepositiontaking
                 , @auto_spositiontaking_8 as auto_spositiontaking
                 , @auto_slivepositiontaking_8 as auto_slivepositiontaking

  union all select 2 as bettype
                 , 1 as sporttype
                 , @spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_2 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 4 as bettype
                 , 1 as sporttype
                 , @spositiontaking_4 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_4 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_4 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 5 as bettype
                 , 1 as sporttype
                 , @spositiontaking_5 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_5 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_5 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 6 as bettype
                 , 1 as sporttype
                 , @spositiontaking_6 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_6 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_6 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 9 as bettype
                 , 1 as sporttype
                 , @spositiontaking_9 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_9 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_9 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 10 as bettype
                 , 1 as sporttype
                 , @spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_10 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking
  
                                                                                                                         
  union all select 9999 as bettype
                 , 1 as sporttype
                 , @spositiontaking_9999 as spositiontaking
                 , 0 as slivepositiontaking
                 , @mpositiontaking_9999 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_spositiontaking_9999 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking
           ) as b on scs.sporttype = b.sporttype and scs.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where scs.custid = @srecommend
       and (scs.mpositiontaking < b.mpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and scs.mlivepositiontaking < b.mlivepositiontaking
               )
           )

    if @ErrType <>''
    BEGIN
        select @ErrCode = 10
        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
                         end
        return
    END
    
    --m3>=u2
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK)
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 1 as sporttype
                 , 1 as bettype
                 , @mpositiontaking_1 as maxpositiontaking
                 , @mlivepositiontaking_1 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 2 as bettype
                 , @mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 3 as bettype
                 , @mpositiontaking_3 as maxpositiontaking
                 , @mlivepositiontaking_3 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 4 as bettype
                 , @mpositiontaking_4 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 5 as bettype
                 , @mpositiontaking_5 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 6 as bettype
                 , @mpositiontaking_6 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 7 as bettype
                 , @mpositiontaking_7 as maxpositiontaking
                 , @mlivepositiontaking_7 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 8 as bettype
                 , @mpositiontaking_8 as maxpositiontaking
                 , @mlivepositiontaking_8 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 9 as bettype
                 , @mpositiontaking_9 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 1 as sporttype
                 , 10 as bettype
                 , @mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  
                                                                                                                         
  union all select 1 as sporttype
                 , 9999 as bettype
                 , @mpositiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1 
       and ((cs.autompositiontaking > b.maxpositiontaking
             and cs.isautompositiontaking = 1
            )
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.autolivempositiontaking > b.maxlivepositiontaking
                and cs.isautolivempositiontaking = 1
               )
           )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Soccer).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](1, @Language) + ')'
                         end
        return
    END
END


if @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
BEGIN
    if @v2spositiontaking_1 < 0
        or @v2spositiontaking_2 < 0
        or @v2spositiontaking_3 < 0
        or @v2spositiontaking_7 < 0
        or @v2spositiontaking_8 < 0
--        or @v2spositiontaking_9 < 0
        or @v2spositiontaking_20 < 0
        
        or @v2spositiontaking_10 < 0
        or @v2spositiontaking_10+@v2mpositiontaking_10 > 0.9
        
        or @v2spositiontaking_1+@v2mpositiontaking_1 > 0.9
        or @v2spositiontaking_2+@v2mpositiontaking_2 > 0.9
        or @v2spositiontaking_3+@v2mpositiontaking_3 > 0.9
        or @v2spositiontaking_7+@v2mpositiontaking_7 > 0.9
        or @v2spositiontaking_8+@v2mpositiontaking_8 > 0.9
--        or @v2spositiontaking_9+@v2mpositiontaking_9 > 0.9
        or @v2spositiontaking_20+@v2mpositiontaking_20 > 0.9
        
        or @auto_v2spositiontaking_10 > 0.9
        or @auto_v2spositiontaking_1 > 0.9
        or @auto_v2spositiontaking_2 > 0.9
        or @auto_v2spositiontaking_3 > 0.9
        or @auto_v2spositiontaking_7 > 0.9
        or @auto_v2spositiontaking_8 > 0.9
--        or @auto_v2spositiontaking_9 > 0.9
        or @auto_v2spositiontaking_20 > 0.9
        
        or @v2mpositiontaking_1 < 0
        or @v2mpositiontaking_2 < 0
        or @v2mpositiontaking_3 < 0
        or @v2mpositiontaking_7 < 0
        or @v2mpositiontaking_8 < 0
--        or @v2mpositiontaking_9 < 0
        or @v2mpositiontaking_20 < 0
        or @v2mpositiontaking_10 < 0

    BEGIN
        select @ErrCode = 11

        Select @ErrMsg = case @Language 
                           when 'E' then 'Wrong position taking (for Basketball).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2, @Language) + ')'
                         end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Min: '
                    + cast((co.minpositiontaking) as varchar(10)) + '-Max: '
                    + cast((co.maxpositiontaking) as varchar(10)) 
                    + case
                        when b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custoverride co with(NOLOCK)
inner join (select 1 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_1 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_1 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_1 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v2spositiontaking_1 as auto_spositiontaking

  union all select 2 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_2 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v2spositiontaking_2 as auto_spositiontaking

  union all select 3 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_3 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_3 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_3 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v2spositiontaking_3 as auto_spositiontaking

--            union all     select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2spositiontaking_7 as isauto_spositiontaking, < 0 as isauto_slivepositiontaking, @auto_v2spositiontaking_7 as auto_spositiontaking
--            union all     select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2spositiontaking_8 as isauto_spositiontaking, < 0 as isauto_slivepositiontaking, @auto_v2spositiontaking_8 as auto_spositiontaking
--            union all     select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2spositiontaking_9 as isauto_spositiontaking, < 0 as isauto_slivepositiontaking, @auto_v2spositiontaking_9 as auto_spositiontaking
  union all select 20 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_20 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_20 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_20 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v2spositiontaking_20 as auto_spositiontaking
  union all select 10 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_10 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v2spositiontaking_10 as auto_spositiontaking
                 
           ) as b on co.sporttype = b.sporttype and co.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where co.custid = @srecommend
       and ((b.isauto_spositiontaking = 0
             and (b.spositiontaking + b.mpositiontaking > co.maxpositiontaking
                  or b.spositiontaking + b.mpositiontaking < co.minpositiontaking
                 )
            )
            or (b.isauto_spositiontaking > 0
                and (b.mpositiontaking > co.maxpositiontaking
                     or b.mpositiontaking + b.auto_spositiontaking < co.minpositiontaking
                    )
               )
           )

    if @ErrType <> ''
    BEGIN
        select @ErrCode = 12

        Select @ErrMsg = case @Language 
                           when 'E' then 'Wrong position taking (min/max set by company).<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType
                         end
        return
    END

    --check n3<=m3<=l3 
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Min: '
                    + cast((co.minpositiontaking) as varchar(10)) + '-Max: '
                    + cast((co.maxpositiontaking) as varchar(10))
                    + case
                        when b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custoverride co with(NOLOCK)
inner join (select 1 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_1 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_1 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_1 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 2 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_2 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 3 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_3 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_3 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_3 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

--            union all     select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2spositiontaking_7 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
--            union all     select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2spositiontaking_8 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
--            union all     select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2spositiontaking_9 as isauto_spositiontaking, 0 as isauto_slivepositiontaking

  union all select 20 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_20 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_20 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_20 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
  union all select 10 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v2spositiontaking_10 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

           ) b on co.sporttype = b.sporttype and co.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where co.custid = @custid
       and (b.mpositiontaking > co.maxpositiontaking
            or b.mpositiontaking < co.minpositiontaking
--            or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
           )

    if @ErrType <> ''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Wrong position taking (min/max set by company).<br>'+ @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType
                         end
        return
    END

    --a2+m2<=m3
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK)
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 2 as sporttype
                 , 1 as bettype
                 , @v2mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 2 as bettype
                 , @v2mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 3 as bettype
                 , @v2mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

--                union all select     2 as sporttype, 7 as bettype, @v2mpositiontaking_7 as maxpositiontaking, 0 as maxlivepositiontaking
--                union all select     2 as sporttype, 8 as bettype, @v2mpositiontaking_8 as maxpositiontaking, 0 as maxlivepositiontaking
--                union all select     2 as sporttype, 9 as bettype, @v2mpositiontaking_9 as maxpositiontaking, 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 20 as bettype
                 , @v2mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
    union all select 2 as sporttype
                 , 10 as bettype
                 , @v2mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking
                                
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Basketball).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](2, @Language) + ')'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 2 AS sporttype
                 , 1 AS bettype
                 , @v2mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 2 AS bettype
                 , @v2mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 3 AS bettype
                 , @v2mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

--                union all select     2 as sporttype, 7 as bettype, @v2mpositiontaking_7 as maxpositiontaking, 0 as maxlivepositiontaking
--                union all select     2 as sporttype, 8 as bettype, @v2mpositiontaking_8 as maxpositiontaking, 0 as maxlivepositiontaking
--                union all select     2 as sporttype, 9 as bettype, @v2mpositiontaking_9 as maxpositiontaking, 0 as maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 20 AS bettype
                 , @v2mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 10 AS bettype
                 , @v2mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking                 
                 
           ) b ON cs.sporttype = b.sporttype AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Basketball).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](2, @Language) + ')'
                 END
        RETURN
    END
    
    --check m3<=m4
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Max: '
                    + cast((scs.mpositiontaking) as varchar(10))
                    + case
                        when b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '-MaxLive: ' + cast((scs.mlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custsetting scs with(NOLOCK)
inner join (select 1 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_1 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_1 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v2spositiontaking_1 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 2 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v2spositiontaking_2 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 3 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_3 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_3 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v2spositiontaking_3 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

--            union all     select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_7 as auto_spositiontaking, 0 as auto_slivepositiontaking
--            union all     select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_8 as auto_spositiontaking, 0 as auto_slivepositiontaking
--            union all     select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_9 as auto_spositiontaking, 0 as auto_slivepositiontaking
  union all select 20 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_20 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_20 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v2spositiontaking_20 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 10 as bettype
                 , 2 as sporttype
                 , @v2spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v2mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v2spositiontaking_10 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

           ) b on scs.sporttype = b.sporttype and scs.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where scs.custid = @srecommend
       and (scs.mpositiontaking < b.mpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and scs.mlivepositiontaking < b.mlivepositiontaking
               )
           )

    if @ErrType <> ''
    BEGIN
        select @ErrCode = 16
        Select @ErrMsg = @UserName
                       + ': ' + case @Language
                                  when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                                  ELSE [dbo].[f_Get_MsgNamebyMsgID](20003, @Language) + '<br>' + @ErrType
                                end
        return
    END

    --m3>=u2
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK) 
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 2 as sporttype
                 , 1 as bettype
                 , @v2mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 2 as bettype
                 , @v2mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 3 as bettype
                 , @v2mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

--                union all select     2 as sporttype, 7 as bettype, @v2mpositiontaking_7 as maxpositiontaking, 0 as maxlivepositiontaking
--                union all select     2 as sporttype, 8 as bettype, @v2mpositiontaking_8 as maxpositiontaking, 0 as maxlivepositiontaking
--                union all select     2 as sporttype, 9 as bettype, @v2mpositiontaking_9 as maxpositiontaking, 0 as maxlivepositiontaking

  union all select 2 as sporttype
                 , 20 as bettype
                 , @v2mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 2 as sporttype
                 , 10 as bettype
                 , @v2mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking
                 
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

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Basketball).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](2, @Language) + ')'
                         end
        return
    END
END


if @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
BEGIN
    if @v3spositiontaking_1 < 0
        or @v3spositiontaking_2 < 0
        or @v3spositiontaking_3 < 0
        or @v3spositiontaking_20 < 0
        or @v3spositiontaking_10 < 0

		or @v3spositiontaking_10 + @v3mpositiontaking_10 > 0.9
        or @v3spositiontaking_1 + @v3mpositiontaking_1 > 0.9
        or @v3spositiontaking_2 + @v3mpositiontaking_2 > 0.9
        or @v3spositiontaking_3 + @v3mpositiontaking_3 > 0.9
        or @v3spositiontaking_20 + @v3mpositiontaking_20 > 0.9

		or @auto_v3spositiontaking_10 > 0.9
        or @auto_v3spositiontaking_1 > 0.9
        or @auto_v3spositiontaking_2 > 0.9
        or @auto_v3spositiontaking_3 > 0.9
        or @auto_v3spositiontaking_20 > 0.9
		
		or @v3mpositiontaking_10 < 0
        or @v3mpositiontaking_1 < 0
        or @v3mpositiontaking_2 < 0
        or @v3mpositiontaking_3 < 0
        or @v3mpositiontaking_20 < 0

    BEGIN
        select @ErrCode = 11

        Select @ErrMsg = case @Language 
                           when 'E' then 'Wrong position taking (for Football).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3, @Language) + ')'
                         end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Min: '
                    + cast((co.minpositiontaking) as varchar(10)) + '-Max: '
                    + cast((co.maxpositiontaking) as varchar(10))
                    + case
                        when b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '--MinLive: ' + cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custoverride co with(NOLOCK)
inner join (select 1 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_1 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_1 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_1 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v3spositiontaking_1 as auto_spositiontaking

  union all select 2 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_2 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v3spositiontaking_2 as auto_spositiontaking
  union all select 3 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_3 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_3 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_3 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v3spositiontaking_3 as auto_spositiontaking

  union all select 20 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_20 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_20 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_20 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v3spositiontaking_20 as auto_spositiontaking
  union all select 10 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_10 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking
                 , @auto_v3spositiontaking_10 as auto_spositiontaking
                                  
           ) b on co.sporttype = b.sporttype and co.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where co.custid = @srecommend
       and ((b.isauto_spositiontaking = 0
             and (b.spositiontaking + b.mpositiontaking > co.maxpositiontaking
                  or b.spositiontaking + b.mpositiontaking < co.minpositiontaking
                 )
            )
            or (b.isauto_spositiontaking > 0
                and (b.mpositiontaking > co.maxpositiontaking
                     or b.mpositiontaking + b.auto_spositiontaking < co.minpositiontaking
                    )
               )    
           )

    if @ErrType <> ''
    BEGIN
        select @ErrCode = 12

        Select @ErrMsg = case @Language 
                           when 'E' then 'Wrong position taking (min/max set by company).<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20002, @Language) + '<br>' + @ErrType
                         end
        return
    END

    --n3<=m3<=l3
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Min: '
                    + cast((co.minpositiontaking) as varchar(10)) + '-Max: '
                    + cast((co.maxpositiontaking) as varchar(10))
                    + case
                        when b.sporttype = 1 and b.bettype in (1, 3, 7, 8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custoverride co with(NOLOCK)
inner join (select 1 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_1 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_1 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_1 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 2 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_2 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 3 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_3 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_3 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_3 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 20 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_20 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_20 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_20 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking

  union all select 10 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @isauto_v3spositiontaking_10 as isauto_spositiontaking
                 , 0 as isauto_slivepositiontaking


           ) b on co.sporttype = b.sporttype and co.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where co.custid = @custid
       and (b.mpositiontaking > co.maxpositiontaking
            or b.mpositiontaking < co.minpositiontaking
--             or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 3 as sporttype
                 , 1 as bettype
                 , @v3mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 2 as bettype
                 , @v3mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 3 as bettype
                 , @v3mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 20 as bettype
                 , @v3mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 10 as bettype
                 , @v3mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking


           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       and c.Enabled    = 1
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Football).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](3, @Language) + ')'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK)
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 3 AS sporttype
                 , 1 AS bettype
                 , @v3mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 2 AS bettype
                 , @v3mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 3 AS bettype
                 , @v3mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 20 AS bettype
                 , @v3mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 3 AS sporttype
                 , 10 AS bettype
                 , @v3mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
                                  

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15
        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Football).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](3, @Language) + ')'
                 END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''

    select @ErrType = @ErrType + sportname + '-' + typenamee + '-Max: ' + cast((scs.mpositiontaking) as varchar(10))
                    + case
                        when b.sporttype = 1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10))
                        else ''
                      end + '<br>'
      from custsetting scs with(NOLOCK)
inner join (select 1 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_1 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_1 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v3spositiontaking_1 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking
  union all select 2 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_2 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_2 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v3spositiontaking_2 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 3 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_3 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_3 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v3spositiontaking_3 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 20 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_20 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_20 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v3spositiontaking_20 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking

  union all select 10 as bettype
                 , 3 as sporttype
                 , @v3spositiontaking_10 as spositiontaking
                 , 0 as slivepositiontaking
                 , @v3mpositiontaking_10 as mpositiontaking
                 , 0 as mlivepositiontaking
                 , @auto_v3spositiontaking_10 as auto_spositiontaking
                 , 0 as auto_slivepositiontaking


           ) b on scs.sporttype = b.sporttype and scs.bettype = b.bettype
INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where scs.custid = @srecommend
       and (scs.mpositiontaking < b.mpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and scs.mlivepositiontaking < b.mlivepositiontaking
               )
           )

    if @ErrType <> ''
    BEGIN
        select @ErrCode = 16

        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20003, @Language) + '<br>' + @ErrType
                         end
        return
    END
    --m3>=u2

    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK) 
inner join custsetting as cs with(NOLOCK) on c.custid = cs.custid
inner join (select 3 as sporttype
                 , 1 as bettype
                 , @v3mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 2 as bettype
                 , @v3mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 3 as bettype
                 , @v3mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 3 as sporttype
                 , 20 as bettype
                 , @v3mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 3 as sporttype
                 , 10 as bettype
                 , @v3mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking


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

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Football).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](3, @Language) + ')'
                         end
        return
    END
END


if @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
BEGIN
    if @v5spositiontaking_1 < 0
        or @v5spositiontaking_2 < 0
        or @v5spositiontaking_3 < 0
        or @v5spositiontaking_20 < 0
        or @v5spositiontaking_9999 < 0
        or @v5spositiontaking_10 < 0

		or @v5spositiontaking_10 + @v5mpositiontaking_10 > 0.9
        or @v5spositiontaking_1 + @v5mpositiontaking_1 > 0.9
        or @v5spositiontaking_2 + @v5mpositiontaking_2 > 0.9
        or @v5spositiontaking_3 + @v5mpositiontaking_3 > 0.9
        or @v5spositiontaking_20 + @v5mpositiontaking_20 > 0.9
        or @v5spositiontaking_9999 + @v5mpositiontaking_9999 > 0.9

		or @auto_v5spositiontaking_10 > 0.9
        or @auto_v5spositiontaking_1 > 0.9
        or @auto_v5spositiontaking_2 > 0.9
        or @auto_v5spositiontaking_3 > 0.9
        or @auto_v5spositiontaking_20 > 0.9
        or @auto_v5spositiontaking_9999 > 0.9
        
        or @v5mpositiontaking_10 < 0
        or @v5mpositiontaking_1 < 0
        or @v5mpositiontaking_2 < 0
        or @v5mpositiontaking_3 < 0
        or @v5mpositiontaking_20 < 0
        or @v5mpositiontaking_9999 < 0

    BEGIN
        select @ErrCode = 11
        Select @ErrMsg = case @Language 
                           when 'E' then 'Wrong position taking (for Tennis).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5, @Language) + ')'
                         end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v5spositiontaking_1 as auto_spositiontaking
            union all     select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_2 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v5spositiontaking_2 as auto_spositiontaking
            union all     select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v5spositiontaking_3 as auto_spositiontaking
            union all     select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v5spositiontaking_20 as auto_spositiontaking
            union all     select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v5spositiontaking_10 as auto_spositiontaking
            union all     select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_9999 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v5spositiontaking_9999 as auto_spositiontaking

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_2 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5spositiontaking_9999 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
--                        or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 5 as sporttype
                 , 1 as bettype
                 , @v5mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 2 as bettype
                 , @v5mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 3 as bettype
                 , @v5mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 20 as bettype
                 , @v5mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 9999 as bettype
                 , @v5mpositiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 5 as sporttype
                 , 10 as bettype
                 , @v5mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking
                 
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       and c.Enabled    = 1
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
    group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14
        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Tennis).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011,@Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](5, @Language) + ')'
                          end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username +', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 5 AS sporttype
                 , 1 AS bettype
                 , @v5mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 2 AS bettype
                 , @v5mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 3 AS bettype
                 , @v5mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 20 AS bettype
                 , @v5mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 10 AS bettype
                 , @v5mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking


  UNION ALL SELECT 5 AS sporttype
                 , 9999 AS bettype
                 , @v5mpositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid = 1
       AND c.Enabled = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Tennis).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](5, @Language) + ')'
                 END
        RETURN
    END
    
    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
                     select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_1 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_2 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_3 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_20 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_10 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_9999 as auto_spositiontaking, 0 as auto_slivepositiontaking
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
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
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 5 as sporttype
                 , 1 as bettype
                 , @v5mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 2 as bettype
                 , @v5mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 3 as bettype
                 , @v5mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 20 as bettype
                 , @v5mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 5 as sporttype
                 , 10 as bettype
                 , @v5mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking


  union all select 5 as sporttype
                 , 9999 as bettype
                 , @v5mpositiontaking_9999 as maxpositiontaking
                 , 0 as maxlivepositiontaking

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       and c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Tennis).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](5, @Language) + ')'
                         end
        return
    END
END


if @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
BEGIN
    if 
        @v8spositiontaking_1 < 0
        or @v8spositiontaking_3 < 0
        or @v8spositiontaking_20 < 0
        or @v8spositiontaking_10 < 0
        
        or @v8spositiontaking_1+@v8mpositiontaking_1 >0.9
        or @v8spositiontaking_3+@v8mpositiontaking_3 >0.9
        or @v8spositiontaking_20+@v8mpositiontaking_20 >0.9
        or @v8spositiontaking_10+@v8mpositiontaking_10 >0.9
        
        or @auto_v8spositiontaking_10  >0.9
        or @auto_v8spositiontaking_1  >0.9
        or @auto_v8spositiontaking_3  >0.9
        or @auto_v8spositiontaking_20  >0.9
        
        or @v8mpositiontaking_10 < 0
        or @v8mpositiontaking_1 < 0
        or @v8mpositiontaking_3 < 0
        or @v8mpositiontaking_20 < 0
                
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (for Baseball).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v8spositiontaking_1 as auto_spositiontaking
            union all     select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v8spositiontaking_3 as auto_spositiontaking
            union all     select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v8spositiontaking_20 as auto_spositiontaking
            union all     select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v8spositiontaking_10 as auto_spositiontaking

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg =     case @Language
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
--                        or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 8 as sporttype
                 , 1 as bettype
                 , @v8mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 8 as sporttype
                 , 3 as bettype
                 , @v8mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 8 as sporttype
                 , 20 as bettype
                 , @v8mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 8 as sporttype
                 , 10 as bettype
                 , @v8mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking                 
                 
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Baseball).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](8, @Language) + ')'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username +', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 8 AS sporttype
                 , 1 AS bettype
                 , @v8mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 3 AS bettype
                 , @v8mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 20 AS bettype
                 , @v8mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 8 AS sporttype
                 , 10 AS bettype
                 , @v8mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking                 

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg =
                  CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Baseball).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](8, @Language) + ')'
                 END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
                     select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_1 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_3 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_20 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_10 as auto_spositiontaking, 0 as auto_slivepositiontaking
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
                        )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 16
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 8 as sporttype
                 , 1 as bettype
                 , @v8mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 8 as sporttype
                 , 3 as bettype
                 , @v8mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 8 as sporttype
                 , 20 as bettype
                 , @v8mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 8 as sporttype
                 , 10 as bettype
                 , @v8mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking                 

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       and c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username
  
    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Baseball).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](8, @Language) + ')'
                    end
        return
    END

END


if @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
BEGIN
    if 
		
        @v10spositiontaking_1 < 0
        or @v10spositiontaking_2 < 0
        or @v10spositiontaking_3 < 0
        or @v10spositiontaking_20 < 0
        or @v10spositiontaking_10 < 0
        
        or @v10spositiontaking_10+@v10mpositiontaking_10 >0.9
        or @v10spositiontaking_1+@v10mpositiontaking_1 >0.9
        or @v10spositiontaking_2+@v10mpositiontaking_2 >0.9
        or @v10spositiontaking_3+@v10mpositiontaking_3 >0.9
        or @v10spositiontaking_20+@v10mpositiontaking_20 >0.9
        
        or @auto_v10spositiontaking_10  >0.9
        or @auto_v10spositiontaking_1  >0.9
        or @auto_v10spositiontaking_2  >0.9
        or @auto_v10spositiontaking_3  >0.9
        or @auto_v10spositiontaking_20  >0.9
        
        or @v10mpositiontaking_10 < 0
        or @v10mpositiontaking_1 < 0
        or @v10mpositiontaking_2 < 0
        or @v10mpositiontaking_3 < 0
        or @v10mpositiontaking_20 < 0
                
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (for Golf).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v10spositiontaking_1 as auto_spositiontaking
            union all     select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_2 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v10spositiontaking_2 as auto_spositiontaking
            union all     select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v10spositiontaking_3 as auto_spositiontaking
            union all     select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v10spositiontaking_20 as auto_spositiontaking
            union all     select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v10spositiontaking_10 as auto_spositiontaking

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_2 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
--                        or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg =     @UserName + ': '+
                    case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --m2+a2<=m3
    select @ErrAcc = ''
    
    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo as c with (NOLOCK)
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 10 as sporttype
                 , 1 as bettype
                 , @v10mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 2 as bettype
                 , @v10mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 3 as bettype
                 , @v10mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 20 as bettype
                 , @v10mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 10 as sporttype
                 , 10 as bettype
                 , @v10mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking                 

           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
      where c.mrecommend = @custid
        and c.roleid     = 2
        AND c.Enabled    = 1
        and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
             or (b.sporttype = 1
                 and b.bettype in (1, 3, 7, 8)
                 and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
                )
            )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Golf).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
                          end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custInfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 10 AS sporttype
                 , 1 AS bettype
                 , @v10mpositiontaking_1 AS maxpositiontaking
                 , 0 as maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 2 AS bettype
                 , @v10mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  union all select 10 AS sporttype
                 , 3 AS bettype
                 , @v10mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  union all select 10 AS sporttype
                 , 20 AS bettype
                 , @v10mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  union all select 10 AS sporttype
                 , 10 AS bettype
                 , @v10mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
                 
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype in (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg =     
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Golf).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](10, @Language) + ')'
                 END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
                     select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_1 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_2 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_3 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_20 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_10 as auto_spositiontaking, 0 as auto_slivepositiontaking
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
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
      from custinfo c with (NOLOCK)
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 10 as sporttype
                 , 1 as bettype
                 , @v10mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 2 as bettype
                 , @v10mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 3 as bettype
                 , @v10mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 10 as sporttype
                 , 20 as bettype
                 , @v10mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 10 as sporttype
                 , 10 as bettype
                 , @v10mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking

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

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Golf).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](10, @Language) + ')'
                         end
        return
    END
END



if @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1
BEGIN
    if 
		
        @v11spositiontaking_1 < 0
        or @v11spositiontaking_20 < 0
        or @v11spositiontaking_10 < 0
        
        or @v11spositiontaking_10+@v11mpositiontaking_10 >0.9
        
        or @v11spositiontaking_1+@v11mpositiontaking_1 >0.9
        or @v11spositiontaking_20+@v11mpositiontaking_20 >0.9
        
        or @auto_v11spositiontaking_10  >0.9
        or @auto_v11spositiontaking_1  >0.9
        or @auto_v11spositiontaking_20  >0.9
        
        or @v11mpositiontaking_10 < 0
        or @v11mpositiontaking_1 < 0
        or @v11mpositiontaking_20 < 0
                
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (for Motorsports).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v11spositiontaking_1 as auto_spositiontaking
            union all     select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v11spositiontaking_20 as auto_spositiontaking
            union all     select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v11spositiontaking_10 as auto_spositiontaking
            

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
--                        or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 11 as sporttype
                 , 1 as bettype
                 , @v11mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 11 as sporttype
                 , 20 as bettype
                 , @v11mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 11 as sporttype
                 , 10 as bettype
                 , @v11mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking


           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Motorsports).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](11, @Language) + ')'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK)
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 11 AS sporttype
                 , 1 AS bettype
                 , @v11mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 11 AS sporttype
                 , 20 AS bettype
                 , @v11mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 11 AS sporttype
                 , 10 AS bettype
                 , @v11mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg =
                  CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Motorsports).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](11, @Language) + ')'
                 END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
                     select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_1 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_20 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_10 as auto_spositiontaking, 0 as auto_slivepositiontaking
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 11 as sporttype
                 , 1 as bettype
                 , @v11mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 11 as sporttype
                 , 20 as bettype
                 , @v11mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 11 as sporttype
                 , 10 as bettype
                 , @v11mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking


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

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Motorsports).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](11, @Language) + ')'
                         end
        return
    END
END


if @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
BEGIN
    if 
        @v99spositiontaking_1 < 0
        or @v99spositiontaking_2 < 0
        or @v99spositiontaking_3 < 0
        or @v99spositiontaking_20 < 0
        or @v99spositiontaking_10 < 0
        
        or @v99spositiontaking_10+@v99mpositiontaking_10 >0.9
        or @v99spositiontaking_1+@v99mpositiontaking_1 >0.9
        or @v99spositiontaking_2+@v99mpositiontaking_2 >0.9
        or @v99spositiontaking_3+@v99mpositiontaking_3 >0.9
        or @v99spositiontaking_20+@v99mpositiontaking_20 >0.9
        
        or @auto_v99spositiontaking_10  >0.9
        or @auto_v99spositiontaking_1  >0.9
        or @auto_v99spositiontaking_2  >0.9
        or @auto_v99spositiontaking_3  >0.9
        or @auto_v99spositiontaking_20  >0.9
        
        or @v99mpositiontaking_10 < 0
        or @v99mpositiontaking_1 < 0
        or @v99mpositiontaking_2 < 0
        or @v99mpositiontaking_3 < 0
        or @v99mpositiontaking_20 < 0
                
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (for Other sports).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v99spositiontaking_1 as auto_spositiontaking
            union all     select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_2 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v99spositiontaking_2 as auto_spositiontaking
            union all     select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v99spositiontaking_3 as auto_spositiontaking
            union all     select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v99spositiontaking_20 as auto_spositiontaking
            union all     select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v99spositiontaking_10 as auto_spositiontaking

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_1 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_2 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_3 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            union all     select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_10 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
--                        or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 99 as sporttype
                 , 1 as bettype
                 , @v99mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 2 as bettype
                 , @v99mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 3 as bettype
                 , @v99mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 20 as bettype
                 , @v99mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 99 as sporttype
                 , 10 as bettype
                 , @v99mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking
                                  
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
      where c.mrecommend = @custid
        and c.roleid     = 2
        AND c.Enabled    = 1
        and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
             or (b.sporttype = 1
                 and b.bettype in (1, 3, 7, 8)
                 and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
                )
            )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Other sports).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](99, @Language) + ')'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 99 AS sporttype
                 , 1 AS bettype
                 , @v99mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 2 AS bettype
                 , @v99mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 3 AS bettype
                 , @v99mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 20 AS bettype
                 , @v99mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 99 AS sporttype
                 , 10 AS bettype
                 , @v99mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
                 

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 15

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Other sports).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](99, @Language) + ')'
                 END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
                     select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_1 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_2 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_3 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_20 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_10 as auto_spositiontaking, 0 as auto_slivepositiontaking
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
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
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 99 as sporttype
                 , 1 as bettype
                 , @v99mpositiontaking_1 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 2 as bettype
                 , @v99mpositiontaking_2 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 3 as bettype
                 , @v99mpositiontaking_3 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 99 as sporttype
                 , 20 as bettype
                 , @v99mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
  union all select 99 as sporttype
                 , 10 as bettype
                 , @v99mpositiontaking_10 as maxpositiontaking
                 , 0 as maxlivepositiontaking                 
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

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Other sports).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](99, @Language) + ')'
                         end
        return
    END

END

--- mixed sports
if @UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1
BEGIN
    if 
           @v99spositiontaking_9 <  0
        or @v99spositiontaking_9 + @v99mpositiontaking_9 > 0.9
        or @auto_v99spositiontaking_9 > 0.9        
        or @v99mpositiontaking_9 < 0
                
    BEGIN
        SELECT @ErrCode = 11

        SELECT @ErrMsg =
                  CASE @Language 
                   WHEN 'E' THEN 'Wrong position taking (for Mix Sports Parlay).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20001, @Language)
                      + CASE @Language 
                          WHEN 'CS' THEN N'(供混合体育过关)'
                          WHEN 'CT' THEN N'(供混合體育過關)'
                          WHEN 'TH' THEN N'(สำหรับกีฬาบอลชุด)'
                          WHEN 'J' THEN N'(Mix Sports Parlay)'
                          WHEN 'KO' THEN N'(Mix Sports Parlay)'
                          WHEN 'VI' THEN N'(Mix Sports Parlay)'
                          ELSE N'(Mix Sports Parlay)'
                        END
                 END
        RETURN
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    --+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
            select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_9 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v99spositiontaking_9 as auto_spositiontaking
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 201
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    --+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
            select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99spositiontaking_9 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
--                        or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 202
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 99 as sporttype
                 , 9 as bettype
                 , @v99mpositiontaking_9 as maxpositiontaking
                 , 0 as maxlivepositiontaking
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 1
                and b.bettype in (1, 3, 7, 8)
                and cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 203

        SELECT @ErrMsg =
                 CASE @Language 
                   WHEN 'E' THEN 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Mix Sports Parlay).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') '
                      + CASE @Language
                          WHEN 'CS' THEN N'(供混合体育过关)'
                          WHEN 'CT' THEN N'(供混合體育過關)'
                          WHEN 'TH' THEN N'(สำหรับกีฬาบอลชุด)'
                          WHEN 'J' THEN N'(Mix Sports Parlay)'
                          WHEN 'KO' THEN N'(Mix Sports Parlay)'
                          WHEN 'VI' THEN N'(Mix Sports Parlay)'
                          ELSE N'(Mix Sports Parlay)'
                        END
                 END
        RETURN
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 99 AS sporttype
                 , 9 AS bettype
                 , @v99mpositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1 AND b.bettype IN (1, 3, 7, 8) AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 204

        SELECT @ErrMsg =
                  CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Mix Sports Parlay).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012 , @Language) + ' (' + @ErrAcc + ') '
                      + CASE @Language 
                          WHEN 'CS' THEN N'(供混合体育过关)'
                          WHEN 'CT' THEN N'(供混合體育過關)'
                          WHEN 'TH' THEN N'(สำหรับกีฬาบอลชุด)'
                          WHEN 'J' THEN N'(Mix Sports Parlay)'
                          WHEN 'KO' THEN N'(Mix Sports Parlay)'
                          WHEN 'VI' THEN N'(Mix Sports Parlay)'
                          ELSE N'(Mix Sports Parlay)'
                        END
                 END
        RETURN
    END
    
    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    --+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
            select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_9 as auto_spositiontaking, 0 as auto_slivepositiontaking
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
                        )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 205
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 99 as sporttype
                 , 9 as bettype
                 , @v99mpositiontaking_9 as maxpositiontaking
                 , 0 as maxlivepositiontaking
                
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 206

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Mix Sports Parlay).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') ' + case @Language 
                                                                                                           when 'CS' then N'(供混合体育过关)'
                                                                                                           when 'CT' then N'(供混合體育過關)'
                                                                                                           when 'TH' then N'(สำหรับกีฬาบอลชุด)'
                                                                                                           when 'J' then N'(Mix Sports Parlay)'
                                                                                                           when 'KO' then N'(Mix Sports Parlay)'
                                                                                                           when 'VI' then N'(Mix Sports Parlay)'
                                                                                                           else N'(Mix Sports Parlay)'
                                                                                                         END
                         end
        return
    END

END

--HR Fixed Odds
if @UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1
BEGIN
    if 
        @v154spositiontaking_20 < 0        
        or @v154spositiontaking_20 + @v154mpositiontaking_20 > 0.9        
        or @auto_v154spositiontaking_20 > 0.9        
        or @v154mpositiontaking_20 < 0
                
    BEGIN
        select @ErrCode = 11
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (for Motorsports).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
                    end
        return
    END

    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 20 as bettype, 154 as sporttype, @v154spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v154mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v154spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v154spositiontaking_20 as auto_spositiontaking

        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 12
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END
    --n3<=m3<=l3
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
    from custoverride as co with (NOLOCK) inner join
        (
                     select 20 as bettype, 154 as sporttype, @v154spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v154mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v154spositiontaking_20 as isauto_spositiontaking, 0 as isauto_slivepositiontaking
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) 
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 13
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
inner join (select 154 as sporttype
                 , 20 as bettype
                 , @v154mpositiontaking_20 as maxpositiontaking
                 , 0 as maxlivepositiontaking
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 14

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for HR Fixed Odds).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](154, @Language) + ')'
                         end
        return
    END

    --m1+a1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 154 AS sporttype
                 , 20 AS bettype
                 , @v154mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

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

        SELECT @ErrMsg =
                  CASE @Language
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for HR Fixed Odds).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](154, @Language) + ')'
                 END
        RETURN
    END
    
    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10)) + '<br>'
    from custsetting as scs with (NOLOCK) inner join
        (
                     select 20 as bettype, 154 as sporttype, @v154spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v154mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v154spositiontaking_20 as auto_spositiontaking, 0 as auto_slivepositiontaking
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and scs.mpositiontaking<b.mpositiontaking 
                        
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
inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 154 as sporttype
                  , 20 as bettype
                  , @v154mpositiontaking_20 as maxpositiontaking
                  , 0 as maxlivepositiontaking
           ) as b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and cs.autompositiontaking > b.maxpositiontaking
       and cs.isautompositiontaking = 1
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 17

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for HR Fixed Odds).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](154, @Language) + ')'
                         end
        return
    END
END


--- number game
if @UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1
BEGIN
    if 
        @v161spositiontaking_81 < 0
        or @v161spositiontaking_83 < 0        
        or @v161spositiontaking_86 < 0
        or @v161spositiontaking_88 < 0
        or @v161slivepositiontaking_85 < 0
        or @v161slivepositiontaking_86 < 0
        or @v161slivepositiontaking_87 < 0
        or @v161slivepositiontaking_89 < 0
        or @v161slivepositiontaking_90 < 0
        
        or @v161mpositiontaking_81 < 0
        or @v161mpositiontaking_83 < 0        
        or @v161mpositiontaking_86 < 0
        or @v161mpositiontaking_88 < 0
        or @v161mlivepositiontaking_85 < 0
        or @v161mlivepositiontaking_86 < 0
        or @v161mlivepositiontaking_87 < 0
        or @v161mlivepositiontaking_89 < 0
        or @v161mlivepositiontaking_90 < 0
        
        or @v161spositiontaking_81 + @v161mpositiontaking_81 > 0.9
        or @v161spositiontaking_83 + @v161mpositiontaking_83 > 0.9        
        or @v161spositiontaking_86 + @v161mpositiontaking_86 > 0.9
        or @v161spositiontaking_88 + @v161mpositiontaking_88 > 0.9
        or @v161slivepositiontaking_85 + @v161mlivepositiontaking_85 > 0.9
        or @v161slivepositiontaking_86 + @v161mlivepositiontaking_86 > 0.9
        or @v161slivepositiontaking_87 + @v161mlivepositiontaking_87 > 0.9
        or @v161slivepositiontaking_89 + @v161mlivepositiontaking_89 > 0.9
        or @v161slivepositiontaking_90 + @v161mlivepositiontaking_90 > 0.9

        or @auto_v161spositiontaking_81 <  0
        or @auto_v161spositiontaking_83 <  0        
        or @auto_v161spositiontaking_86 <  0
        or @auto_v161spositiontaking_88 <  0
        or @auto_v161slivepositiontaking_85 < 0
        or @auto_v161slivepositiontaking_86 < 0
        or @auto_v161slivepositiontaking_87 < 0
        or @auto_v161slivepositiontaking_89 < 0
        or @auto_v161slivepositiontaking_90 < 0
        
        or @auto_v161spositiontaking_81 > 0.9
        or @auto_v161spositiontaking_83 > 0.9        
        or @auto_v161spositiontaking_86 > 0.9
        or @auto_v161spositiontaking_88 > 0.9
        or @auto_v161slivepositiontaking_85  > 0.9
        or @auto_v161slivepositiontaking_86  > 0.9
        or @auto_v161slivepositiontaking_87  > 0.9
        or @auto_v161slivepositiontaking_89  > 0.9
        or @auto_v161slivepositiontaking_90  > 0.9
                
    BEGIN
        select @ErrCode = 207
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (for Number Game).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
                    end
        return
    END
    
    
    
    --check n4<=s3+m3<=l4 if i3 = 0, 
    --m3<=l4 and u3+m3>=n4 if i3 = 1
    
--    select @ErrType = ''
--    select @ErrType = @ErrType + sportname + '-'+ typenamee + 
--    case when b.isauto_spositiontaking=0 then 
--        '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
--        + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end
--    else
--        '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
--        + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end
--    end
    
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype = 161 and b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from 
        custoverride3rd as co with (NOLOCK) 
        inner join
        (
                         select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_81 as auto_spositiontaking, 0 as auto_slivepositiontaking    
            union all     select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_83 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_88 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_85 as auto_slivepositiontaking
            union all     select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @auto_v161spositiontaking_86 as auto_spositiontaking,  @auto_v161slivepositiontaking_86 as auto_slivepositiontaking
            union all     select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_87 as auto_slivepositiontaking
            union all     select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_89 as auto_slivepositiontaking
            union all     select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_90 as auto_slivepositiontaking
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @srecommend and (    
                        ((b.isauto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
                        (b.isauto_spositiontaking>0 and (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking)) or 
                        ((b.sporttype = 161 and b.bettype in (85,86,87,89,90) and b.isauto_slivepositiontaking=0) and (b.slivepositiontaking+b.mlivepositiontaking>co.maxlivepositiontaking or b.slivepositiontaking+b.mlivepositiontaking<co.minlivepositiontaking)) or
                        ((b.sporttype = 161 and b.bettype in (85,86,87,89,90) and b.isauto_slivepositiontaking>0) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking + b.auto_slivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 208
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --check n3<=m3<=l3 
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
    + case when b.sporttype = 161 and b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from 
        custoverride3rd as co with (NOLOCK) 
        inner join
        (
                        select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_81 as auto_spositiontaking, 0 as auto_slivepositiontaking    
            union all     select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_83 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 83 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_88 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_85 as auto_slivepositiontaking
            union all     select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @auto_v161spositiontaking_86 as auto_spositiontaking,  @auto_v161slivepositiontaking_86 as auto_slivepositiontaking
            union all     select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_87 as auto_slivepositiontaking
            union all     select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_89 as auto_slivepositiontaking
            union all     select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_90 as auto_slivepositiontaking
            
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where co.custid = @custid and (    
                        (b.mpositiontaking>co.maxpositiontaking or b.mpositiontaking<co.minpositiontaking) or 
                        (b.sporttype = 161 and b.bettype in (85,86,87,89,90) and (b.mlivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking<co.minlivepositiontaking))
                    )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 209
        Select @ErrMsg = @UserName + ': '+
            case @Language 
                            when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
                    end
        return
    END

    --a2+m2<=m3
    select @ErrAcc = ''
    --select top 100 @ErrAcc = @ErrAcc + username + ' (' + sportname + '-' + typenamee + ') <br>'
    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK) 
inner join custsetting3rd cs3 with(NOLOCK) on c.custid = cs3.custid
inner join (select 161 as sporttype
                 , 81 as bettype
                 , @v161mpositiontaking_81 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 83 as bettype
                 , @v161mpositiontaking_83 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 88 as bettype
                 , @v161mpositiontaking_88 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 85 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_85 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 86 as bettype
                 , @v161mpositiontaking_86 as maxpositiontaking
                 , @v161mlivepositiontaking_86 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 87 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_87 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 89 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_89 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 90 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_90 as maxlivepositiontaking
           ) b on cs3.sporttype = b.sporttype and cs3.bettype = b.bettype
        --INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        --INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and (cs3.apositiontaking + cs3.mpositiontaking > b.maxpositiontaking
            or (b.sporttype = 161
                and b.bettype in (85, 86, 87, 89, 90)
                and cs3.alivepositiontaking + cs3.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  group by username--, sportname, typenamee
  
    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 210

        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Number Game).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](161, @Language) + ')'
                         end
        return
    END
    
    --a1+m1<=m3
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting3rd cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 161 AS sporttype
                 , 81 AS bettype
                 , @v161mpositiontaking_81 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 83 AS bettype
                 , @v161mpositiontaking_83 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 88 AS bettype
                 , @v161mpositiontaking_88 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 85 AS bettype
                 , 0 AS maxpositiontaking
                 , @v161mlivepositiontaking_85 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 86 AS bettype
                 , @v161mpositiontaking_86 AS maxpositiontaking
                 , @v161mlivepositiontaking_86 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 87 AS bettype
                 , 0 AS maxpositiontaking
                 , @v161mlivepositiontaking_87 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 89 AS bettype
                 , 0 AS maxpositiontaking
                 , @v161mlivepositiontaking_89 AS maxlivepositiontaking

  UNION ALL SELECT 161 AS sporttype
                 , 90 AS bettype
                 , 0 AS maxpositiontaking
                 , @v161mlivepositiontaking_90 AS maxlivepositiontaking
                
           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.mrecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking + cs.mpositiontaking > b.maxpositiontaking
            OR (b.sporttype = 161
                AND b.bettype IN (85, 86, 87, 89, 90)
                AND cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrCode = 211

        SELECT @ErrMsg =
                  CASE @Language 
                   WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ') (for Number Game).'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](161, @Language) + ')'
                 END
        RETURN
    END

    --check m3<=m4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.mpositiontaking) as varchar(10))
    + case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting3rd as scs with (NOLOCK) inner join
        (
                        select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_81 as auto_spositiontaking, 0 as auto_slivepositiontaking    
            union all     select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_83 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking, 0 as isauto_slivepositiontaking, @auto_v161spositiontaking_88 as auto_spositiontaking, 0 as auto_slivepositiontaking
            union all     select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_85 as auto_slivepositiontaking
            union all     select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @auto_v161spositiontaking_86 as auto_spositiontaking,  @auto_v161slivepositiontaking_86 as auto_slivepositiontaking
            union all     select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_87 as auto_slivepositiontaking
            union all     select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_89 as auto_slivepositiontaking
            union all     select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_spositiontaking,  @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, 0 as auto_spositiontaking,  @auto_v161slivepositiontaking_90 as auto_slivepositiontaking
            
        ) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where scs.custid = @srecommend and (
                        scs.mpositiontaking<b.mpositiontaking or (b.sporttype=161 and b.bettype in (85,86,87,89,90) and scs.mlivepositiontaking<b.mlivepositiontaking)
                        )
    if @ErrType <>''
    BEGIN
        select @ErrCode = 212
        Select @ErrMsg =     @UserName + ': '+
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
inner join custsetting3rd as cs with (NOLOCK) on c.custid = cs.custid
inner join (select 161 as sporttype
                 , 81 as bettype
                 , @v161mpositiontaking_81 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 83 as bettype
                 , @v161mpositiontaking_83 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 88 as bettype
                 , @v161mpositiontaking_88 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 85 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_85 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 86 as bettype
                 , @v161mpositiontaking_86 as maxpositiontaking
                 , @v161mlivepositiontaking_86 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 87 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_87 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 89 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_89 as maxlivepositiontaking

  union all select 161 as sporttype
                 , 90 as bettype
                 , 0 as maxpositiontaking
                 , @v161mlivepositiontaking_90 as maxlivepositiontaking
        
           ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
     where c.mrecommend = @custid
       and c.roleid     = 2
       AND c.Enabled    = 1
       and ((cs.autompositiontaking > b.maxpositiontaking
             and cs.isautompositiontaking = 1
            )
            or (b.sporttype = 161
                and b.bettype in (85, 86, 87, 89, 90)
                and cs.autolivempositiontaking > b.maxlivepositiontaking
                and cs.isautolivempositiontaking = 1
               )
           )
  group by username

    if @ErrAcc <> ''
    BEGIN
        select @ErrCode = 213
        Select @ErrMsg = case @Language 
                           when 'E' then 'Existing agents exceeded new master position taking (' + @ErrAcc + ') (for Number Game).'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20011, @Language) + ' (' + @ErrAcc + ') (' + [dbo].[f_Get_SportNameBySporttype](161, @Language) + ')'
                         end
        return
    END
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


declare @Old_spositiontaking_1 smallmoney,
    @Old_spositiontaking_2 smallmoney,
    @Old_spositiontaking_3 smallmoney,
    @Old_spositiontaking_4 smallmoney,
    @Old_spositiontaking_5 smallmoney,
    @Old_spositiontaking_6 smallmoney,
    @Old_spositiontaking_7 smallmoney,
    @Old_spositiontaking_8 smallmoney,
    @Old_spositiontaking_9 smallmoney,
    @Old_spositiontaking_10 smallmoney,
    @Old_spositiontaking_9999 smallmoney,
    @Old_slivepositiontaking_1 smallmoney,
    @Old_slivepositiontaking_3 smallmoney,
    @Old_slivepositiontaking_7 smallmoney,
    @Old_slivepositiontaking_8 smallmoney,
    
    @Old_v2spositiontaking_1 smallmoney,
    @Old_v2spositiontaking_2 smallmoney,
    @Old_v2spositiontaking_3 smallmoney,
    @Old_v2spositiontaking_7 smallmoney,
    @Old_v2spositiontaking_8 smallmoney,
    @Old_v2spositiontaking_20 smallmoney,
    
    @Old_v3spositiontaking_1 smallmoney,
    @Old_v3spositiontaking_2 smallmoney,
    @Old_v3spositiontaking_3 smallmoney,    
    @Old_v3spositiontaking_20 smallmoney,
    
    @Old_v5spositiontaking_1 smallmoney,
    @Old_v5spositiontaking_2 smallmoney,
    @Old_v5spositiontaking_3 smallmoney,    
    @Old_v5spositiontaking_20 smallmoney,
    @Old_v5spositiontaking_9999 smallmoney,
    
    @Old_v8spositiontaking_1 smallmoney,
    @Old_v8spositiontaking_3 smallmoney,    
    @Old_v8spositiontaking_20 smallmoney,
    
    @Old_v10spositiontaking_1 smallmoney,
    @Old_v10spositiontaking_2 smallmoney,
    @Old_v10spositiontaking_3 smallmoney,    
    @Old_v10spositiontaking_20 smallmoney,
    
    @Old_v11spositiontaking_1 smallmoney,
    @Old_v11spositiontaking_20 smallmoney,
    
    @Old_v99spositiontaking_1 smallmoney,
    @Old_v99spositiontaking_2 smallmoney,
    @Old_v99spositiontaking_3 smallmoney,    
    @Old_v99spositiontaking_20 smallmoney,    

    -- mixed sports
    @Old_v99spositiontaking_9 smallmoney,
    
    @Old_v154spositiontaking_20 smallmoney,
    
    -- number game
    @Old_v161spositiontaking_81 smallmoney,
    @Old_v161spositiontaking_83 smallmoney,    
    @Old_v161spositiontaking_86 smallmoney,
    @Old_v161spositiontaking_88 smallmoney,
    @Old_v161slivepositiontaking_85 smallmoney,
    @Old_v161slivepositiontaking_86 smallmoney,
    @Old_v161slivepositiontaking_87 smallmoney,
    @Old_v161slivepositiontaking_89 smallmoney,
    @Old_v161slivepositiontaking_90 smallmoney,
    
    @Old_auto_spositiontaking_1 smallmoney ,
    @Old_auto_spositiontaking_2 smallmoney ,
    @Old_auto_spositiontaking_3 smallmoney ,
    @Old_auto_spositiontaking_4 smallmoney ,
    @Old_auto_spositiontaking_5 smallmoney,
    @Old_auto_spositiontaking_6 smallmoney ,
    @Old_auto_spositiontaking_7 smallmoney ,
    @Old_auto_spositiontaking_8 smallmoney ,
    @Old_auto_spositiontaking_9 smallmoney ,
    @Old_auto_spositiontaking_10 smallmoney ,
    @Old_auto_spositiontaking_9999 smallmoney ,
    @Old_auto_slivepositiontaking_1 smallmoney ,
    @Old_auto_slivepositiontaking_3 smallmoney ,
    @Old_auto_slivepositiontaking_7 smallmoney ,
    @Old_auto_slivepositiontaking_8 smallmoney ,
    
    @Old_auto_v2spositiontaking_1 smallmoney ,
    @Old_auto_v2spositiontaking_2 smallmoney ,
    @Old_auto_v2spositiontaking_3 smallmoney ,
    @Old_auto_v2spositiontaking_7 smallmoney ,
    @Old_auto_v2spositiontaking_8 smallmoney ,
    @Old_auto_v2spositiontaking_20 smallmoney ,
    
    @Old_auto_v3spositiontaking_1 smallmoney ,
    @Old_auto_v3spositiontaking_2 smallmoney ,
    @Old_auto_v3spositiontaking_3 smallmoney ,
    @Old_auto_v3spositiontaking_20 smallmoney ,
    
    @Old_auto_v5spositiontaking_1 smallmoney ,
    @Old_auto_v5spositiontaking_2 smallmoney ,
    @Old_auto_v5spositiontaking_3 smallmoney ,
    @Old_auto_v5spositiontaking_20 smallmoney ,
    @Old_auto_v5spositiontaking_9999 smallmoney ,
    
    @Old_auto_v8spositiontaking_1 smallmoney ,
    @Old_auto_v8spositiontaking_3 smallmoney ,
    @Old_auto_v8spositiontaking_20 smallmoney ,
    
    @Old_auto_v10spositiontaking_1 smallmoney ,
    @Old_auto_v10spositiontaking_2 smallmoney ,
    @Old_auto_v10spositiontaking_3 smallmoney ,
    @Old_auto_v10spositiontaking_20 smallmoney ,
    
    @Old_auto_v11spositiontaking_1 smallmoney ,
    @Old_auto_v11spositiontaking_20 smallmoney ,

    @Old_auto_v99spositiontaking_1 smallmoney ,
    @Old_auto_v99spositiontaking_2 smallmoney ,
    @Old_auto_v99spositiontaking_3 smallmoney ,
    @Old_auto_v99spositiontaking_20 smallmoney ,    

    -- mixed sports
    @Old_auto_v99spositiontaking_9 smallmoney ,
    
    @Old_auto_v154spositiontaking_20 smallmoney ,    

    -- number game
    @Old_auto_v161spositiontaking_81 smallmoney ,
    @Old_auto_v161spositiontaking_83 smallmoney ,    
    @Old_auto_v161spositiontaking_86 smallmoney ,
    @Old_auto_v161spositiontaking_88 smallmoney ,
    @Old_auto_v161slivepositiontaking_85 smallmoney ,
    @Old_auto_v161slivepositiontaking_86 smallmoney ,
    @Old_auto_v161slivepositiontaking_87 smallmoney ,
    @Old_auto_v161slivepositiontaking_89 smallmoney ,
    @Old_auto_v161slivepositiontaking_90 smallmoney ,
    
    @Old_isauto_spositiontaking_1 bit,
    @Old_isauto_spositiontaking_2 bit,
    @Old_isauto_spositiontaking_3 bit,
    @Old_isauto_spositiontaking_4 bit,
    @Old_isauto_spositiontaking_5 bit,
    @Old_isauto_spositiontaking_6 bit,
    @Old_isauto_spositiontaking_7 bit,
    @Old_isauto_spositiontaking_8 bit,
    @Old_isauto_spositiontaking_9 bit,
    @Old_isauto_spositiontaking_10 bit,
    @Old_isauto_spositiontaking_9999 bit,
    @Old_isauto_slivepositiontaking_1 bit,
    @Old_isauto_slivepositiontaking_3 bit,
    @Old_isauto_slivepositiontaking_7 bit,
    @Old_isauto_slivepositiontaking_8 bit,
    
    @Old_isauto_v2spositiontaking_1 bit,
    @Old_isauto_v2spositiontaking_2 bit,
    @Old_isauto_v2spositiontaking_3 bit,
    @Old_isauto_v2spositiontaking_7 bit,
    @Old_isauto_v2spositiontaking_8 bit,
    @Old_isauto_v2spositiontaking_20 bit,
    
    @Old_isauto_v3spositiontaking_1 bit,
    @Old_isauto_v3spositiontaking_2 bit,
    @Old_isauto_v3spositiontaking_3 bit,
    @Old_isauto_v3spositiontaking_20 bit,
    
    @Old_isauto_v5spositiontaking_1 bit,
    @Old_isauto_v5spositiontaking_2 bit,
    @Old_isauto_v5spositiontaking_3 bit,
    @Old_isauto_v5spositiontaking_20 bit,
    @Old_isauto_v5spositiontaking_9999 bit,
    
    @Old_isauto_v8spositiontaking_1 bit,
    @Old_isauto_v8spositiontaking_3 bit,
    @Old_isauto_v8spositiontaking_20 bit,
    
    @Old_isauto_v10spositiontaking_1 bit,
    @Old_isauto_v10spositiontaking_2 bit,
    @Old_isauto_v10spositiontaking_3 bit,
    @Old_isauto_v10spositiontaking_20 bit,
    
    @Old_isauto_v11spositiontaking_1 bit,
    @Old_isauto_v11spositiontaking_20 bit,
    
    @Old_isauto_v99spositiontaking_1 bit,
    @Old_isauto_v99spositiontaking_2 bit,
    @Old_isauto_v99spositiontaking_3 bit,
    @Old_isauto_v99spositiontaking_20 bit,    

    -- mixed sports
    @Old_isauto_v99spositiontaking_9 bit,
    
    @Old_isauto_v154spositiontaking_20 bit,    

    -- number game
    @Old_isauto_v161spositiontaking_81 bit,
    @Old_isauto_v161spositiontaking_83 bit,    
    @Old_isauto_v161spositiontaking_86 bit,
    @Old_isauto_v161spositiontaking_88 bit,
    @Old_isauto_v161slivepositiontaking_85 bit,
    @Old_isauto_v161slivepositiontaking_86 bit,
    @Old_isauto_v161slivepositiontaking_87 bit,
    @Old_isauto_v161slivepositiontaking_89 bit,
    @Old_isauto_v161slivepositiontaking_90 bit,
    
    @Old_mpositiontaking_1 smallmoney,
    @Old_mpositiontaking_2 smallmoney,
    @Old_mpositiontaking_3 smallmoney,
    @Old_mpositiontaking_4 smallmoney,
    @Old_mpositiontaking_5 smallmoney,
    @Old_mpositiontaking_6 smallmoney,
    @Old_mpositiontaking_7 smallmoney,
    @Old_mpositiontaking_8 smallmoney,
    @Old_mpositiontaking_9 smallmoney,
    @Old_mpositiontaking_10 smallmoney,
    @Old_mpositiontaking_9999 smallmoney,
    @Old_mlivepositiontaking_1 smallmoney,
    @Old_mlivepositiontaking_3 smallmoney,
    @Old_mlivepositiontaking_7 smallmoney,
    @Old_mlivepositiontaking_8 smallmoney,
    
    @Old_v2mpositiontaking_1 smallmoney,
    @Old_v2mpositiontaking_2 smallmoney,
    @Old_v2mpositiontaking_3 smallmoney,
    @Old_v2mpositiontaking_7 smallmoney,
    @Old_v2mpositiontaking_8 smallmoney,
    @Old_v2mpositiontaking_20 smallmoney,
    
    @Old_v3mpositiontaking_1 smallmoney,
    @Old_v3mpositiontaking_2 smallmoney,
    @Old_v3mpositiontaking_3 smallmoney,
    @Old_v3mpositiontaking_20 smallmoney,
    
    @Old_v5mpositiontaking_1 smallmoney,
    @Old_v5mpositiontaking_2 smallmoney,
    @Old_v5mpositiontaking_3 smallmoney,
    @Old_v5mpositiontaking_20 smallmoney,
    @Old_v5mpositiontaking_9999 smallmoney,
    
    @Old_v8mpositiontaking_1 smallmoney,
    @Old_v8mpositiontaking_3 smallmoney,
    @Old_v8mpositiontaking_20 smallmoney,
    
    @Old_v10mpositiontaking_1 smallmoney,
    @Old_v10mpositiontaking_2 smallmoney,
    @Old_v10mpositiontaking_3 smallmoney,
    @Old_v10mpositiontaking_20 smallmoney,
    
    @Old_v11mpositiontaking_1 smallmoney,
    @Old_v11mpositiontaking_20 smallmoney,

    @Old_v99mpositiontaking_1 smallmoney,
    @Old_v99mpositiontaking_2 smallmoney,
    @Old_v99mpositiontaking_3 smallmoney,
    @Old_v99mpositiontaking_20 smallmoney,

    -- mixed sports
    @Old_v99mpositiontaking_9 smallmoney,
    
    @Old_v154mpositiontaking_20 smallmoney,
    
    -- number game
    @Old_v161mpositiontaking_81 smallmoney,
    @Old_v161mpositiontaking_83 smallmoney,    
    @Old_v161mpositiontaking_86 smallmoney,
    @Old_v161mpositiontaking_88 smallmoney,
    @Old_v161mlivepositiontaking_85 smallmoney,
    @Old_v161mlivepositiontaking_86 smallmoney,
    @Old_v161mlivepositiontaking_87 smallmoney,
    @Old_v161mlivepositiontaking_89 smallmoney,
    @Old_v161mlivepositiontaking_90 smallmoney,
    
    -- Outright PT for sports
    @Old_v2spositiontaking_10 smallmoney,
    @Old_v3spositiontaking_10 smallmoney,
    @Old_v5spositiontaking_10 smallmoney,
    @Old_v8spositiontaking_10 smallmoney,
    @Old_v10spositiontaking_10 smallmoney,
    @Old_v11spositiontaking_10 smallmoney,
    @Old_v99spositiontaking_10 smallmoney,
    
    
	@Old_auto_v2spositiontaking_10 smallmoney ,
	@Old_auto_v3spositiontaking_10 smallmoney ,
	@Old_auto_v5spositiontaking_10 smallmoney ,
	@Old_auto_v8spositiontaking_10 smallmoney ,
	@Old_auto_v10spositiontaking_10 smallmoney ,
	@Old_auto_v11spositiontaking_10 smallmoney ,
	@Old_auto_v99spositiontaking_10 smallmoney ,
	
	@Old_isauto_v2spositiontaking_10 bit,
	@Old_isauto_v3spositiontaking_10 bit,
	@Old_isauto_v5spositiontaking_10 bit,
	@Old_isauto_v8spositiontaking_10 bit,
	@Old_isauto_v10spositiontaking_10 bit,
	@Old_isauto_v11spositiontaking_10 bit,
	@Old_isauto_v99spositiontaking_10 bit,
	
	@Old_v2mpositiontaking_10 smallmoney,
	@Old_v3mpositiontaking_10 smallmoney,
	@Old_v5mpositiontaking_10 smallmoney,
	@Old_v8mpositiontaking_10 smallmoney,
	@Old_v10mpositiontaking_10 smallmoney,
	@Old_v11mpositiontaking_10 smallmoney,
	@Old_v99mpositiontaking_10 smallmoney



select @old_mpositiontaking_1 = mpositiontaking, @old_mlivepositiontaking_1 = mlivepositiontaking, 
    @old_spositiontaking_1 = spositiontaking, @old_slivepositiontaking_1 = slivepositiontaking,
    @Old_auto_spositiontaking_1 = autopositiontaking, @Old_isauto_spositiontaking_1=isautopositiontaking,
    @Old_auto_slivepositiontaking_1 = autolivepositiontaking, @Old_isauto_slivepositiontaking_1=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1

select @old_mpositiontaking_3 = mpositiontaking, @old_mlivepositiontaking_3 = mlivepositiontaking, 
    @old_spositiontaking_3 = spositiontaking, @old_slivepositiontaking_3 = slivepositiontaking,
    @Old_auto_spositiontaking_3 = autopositiontaking, @Old_isauto_spositiontaking_3=isautopositiontaking,
    @Old_auto_slivepositiontaking_3 = autolivepositiontaking, @Old_isauto_slivepositiontaking_3=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1

select @old_mpositiontaking_7 = mpositiontaking, @old_mlivepositiontaking_7 = mlivepositiontaking, 
    @old_spositiontaking_7 = spositiontaking, @old_slivepositiontaking_7 = slivepositiontaking, 
    @Old_auto_spositiontaking_7 = autopositiontaking, @Old_isauto_spositiontaking_7=isautopositiontaking,
    @Old_auto_slivepositiontaking_7 = autolivepositiontaking, @Old_isauto_slivepositiontaking_7=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1

select @old_mpositiontaking_8 = mpositiontaking, @old_mlivepositiontaking_8 = mlivepositiontaking, 
    @old_spositiontaking_8 = spositiontaking, @old_slivepositiontaking_8 = slivepositiontaking,
    @Old_auto_spositiontaking_8 = autopositiontaking, @Old_isauto_spositiontaking_8=isautopositiontaking,
    @Old_auto_slivepositiontaking_8 = autolivepositiontaking, @Old_isauto_slivepositiontaking_8=isautolivepositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1

select @old_mpositiontaking_2 = mpositiontaking, @old_spositiontaking_2 = spositiontaking, @old_auto_spositiontaking_2 = autopositiontaking, @old_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
select @old_mpositiontaking_4 = mpositiontaking, @old_spositiontaking_4 = spositiontaking, @old_auto_spositiontaking_4 = autopositiontaking, @old_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1
select @old_mpositiontaking_5 = mpositiontaking, @old_spositiontaking_5 = spositiontaking, @old_auto_spositiontaking_5 = autopositiontaking, @old_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
select @old_mpositiontaking_6 = mpositiontaking, @old_spositiontaking_6 = spositiontaking, @old_auto_spositiontaking_6 = autopositiontaking, @old_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
select @old_mpositiontaking_9 = mpositiontaking, @old_spositiontaking_9 = spositiontaking, @old_auto_spositiontaking_9 = autopositiontaking, @old_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
select @old_mpositiontaking_10 = mpositiontaking, @old_spositiontaking_10 = spositiontaking, @old_auto_spositiontaking_10 = autopositiontaking, @old_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1

-- Outright PT for sports
select @old_v2mpositiontaking_10 = mpositiontaking, @old_v2spositiontaking_10 = spositiontaking, @old_auto_v2spositiontaking_10 = autopositiontaking, @old_isauto_v2spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=2
select @old_v3mpositiontaking_10 = mpositiontaking, @old_v3spositiontaking_10 = spositiontaking, @old_auto_v3spositiontaking_10 = autopositiontaking, @old_isauto_v3spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=3
select @old_v5mpositiontaking_10 = mpositiontaking, @old_v5spositiontaking_10 = spositiontaking, @old_auto_v5spositiontaking_10 = autopositiontaking, @old_isauto_v5spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=5
select @old_v8mpositiontaking_10 = mpositiontaking, @old_v8spositiontaking_10 = spositiontaking, @old_auto_v8spositiontaking_10 = autopositiontaking, @old_isauto_v8spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=8
select @old_v10mpositiontaking_10 = mpositiontaking, @old_v10spositiontaking_10 = spositiontaking, @old_auto_v10spositiontaking_10 = autopositiontaking, @old_isauto_v10spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=10
select @old_v11mpositiontaking_10 = mpositiontaking, @old_v11spositiontaking_10 = spositiontaking, @old_auto_v11spositiontaking_10 = autopositiontaking, @old_isauto_v11spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=11
select @old_v99mpositiontaking_10 = mpositiontaking, @old_v99spositiontaking_10 = spositiontaking, @old_auto_v99spositiontaking_10 = autopositiontaking, @old_isauto_v99spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=99

select @old_mpositiontaking_9999 = mpositiontaking, @old_spositiontaking_9999 = spositiontaking, @old_auto_spositiontaking_9999 = autopositiontaking, @old_isauto_spositiontaking_9999 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=1

select @old_v2mpositiontaking_1 = mpositiontaking, @old_v2spositiontaking_1 = spositiontaking, @old_auto_v2spositiontaking_1 = autopositiontaking, @old_isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=2
select @old_v2mpositiontaking_2 = mpositiontaking, @old_v2spositiontaking_2 = spositiontaking, @old_auto_v2spositiontaking_2 = autopositiontaking, @old_isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=2
select @old_v2mpositiontaking_3 = mpositiontaking, @old_v2spositiontaking_3 = spositiontaking, @old_auto_v2spositiontaking_3 = autopositiontaking, @old_isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=2
select @old_v2mpositiontaking_7 = mpositiontaking, @old_v2spositiontaking_7 = spositiontaking, @old_auto_v2spositiontaking_7 = autopositiontaking, @old_isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=2
select @old_v2mpositiontaking_8 = mpositiontaking, @old_v2spositiontaking_8 = spositiontaking, @old_auto_v2spositiontaking_8 = autopositiontaking, @old_isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=2
select @old_v2mpositiontaking_20 = mpositiontaking, @old_v2spositiontaking_20 = spositiontaking, @old_auto_v2spositiontaking_20 = autopositiontaking, @old_isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=2

select @old_v3mpositiontaking_1 = mpositiontaking, @old_v3spositiontaking_1 = spositiontaking, @old_auto_v3spositiontaking_1 = autopositiontaking, @old_isauto_v3spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=3
select @old_v3mpositiontaking_2 = mpositiontaking, @old_v3spositiontaking_2 = spositiontaking, @old_auto_v3spositiontaking_2 = autopositiontaking, @old_isauto_v3spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=3
select @old_v3mpositiontaking_3 = mpositiontaking, @old_v3spositiontaking_3 = spositiontaking, @old_auto_v3spositiontaking_3 = autopositiontaking, @old_isauto_v3spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=3
select @old_v3mpositiontaking_20 = mpositiontaking, @old_v3spositiontaking_20 = spositiontaking, @old_auto_v3spositiontaking_20 = autopositiontaking, @old_isauto_v3spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=3

select @old_v5mpositiontaking_1 = mpositiontaking, @old_v5spositiontaking_1 = spositiontaking, @old_auto_v5spositiontaking_1 = autopositiontaking, @old_isauto_v5spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=5
select @old_v5mpositiontaking_2 = mpositiontaking, @old_v5spositiontaking_2 = spositiontaking, @old_auto_v5spositiontaking_2 = autopositiontaking, @old_isauto_v5spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=5
select @old_v5mpositiontaking_3 = mpositiontaking, @old_v5spositiontaking_3 = spositiontaking, @old_auto_v5spositiontaking_3 = autopositiontaking, @old_isauto_v5spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=5
select @old_v5mpositiontaking_20 = mpositiontaking, @old_v5spositiontaking_20 = spositiontaking, @old_auto_v5spositiontaking_20 = autopositiontaking, @old_isauto_v5spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=5
select @old_v5mpositiontaking_9999 = mpositiontaking, @old_v5spositiontaking_9999 = spositiontaking, @old_auto_v5spositiontaking_9999 = autopositiontaking, @old_isauto_v5spositiontaking_9999 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=5

select @old_v8mpositiontaking_1 = mpositiontaking, @old_v8spositiontaking_1 = spositiontaking, @old_auto_v8spositiontaking_1 = autopositiontaking, @old_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
select @old_v8mpositiontaking_3 = mpositiontaking, @old_v8spositiontaking_3 = spositiontaking, @old_auto_v8spositiontaking_3 = autopositiontaking, @old_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
select @old_v8mpositiontaking_20 = mpositiontaking, @old_v8spositiontaking_20 = spositiontaking, @old_auto_v8spositiontaking_20 = autopositiontaking, @old_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8

select @old_v10mpositiontaking_1 = mpositiontaking, @old_v10spositiontaking_1 = spositiontaking, @old_auto_v10spositiontaking_1 = autopositiontaking, @old_isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=10
select @old_v10mpositiontaking_2 = mpositiontaking, @old_v10spositiontaking_2 = spositiontaking, @old_auto_v10spositiontaking_2 = autopositiontaking, @old_isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=10
select @old_v10mpositiontaking_3 = mpositiontaking, @old_v10spositiontaking_3 = spositiontaking, @old_auto_v10spositiontaking_3 = autopositiontaking, @old_isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=10
select @old_v10mpositiontaking_20 = mpositiontaking, @old_v10spositiontaking_20 = spositiontaking, @old_auto_v10spositiontaking_20 = autopositiontaking, @old_isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=10

select @old_v11mpositiontaking_1 = mpositiontaking, @old_v11spositiontaking_1 = spositiontaking, @old_auto_v11spositiontaking_1 = autopositiontaking, @old_isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=11
select @old_v11mpositiontaking_20 = mpositiontaking, @old_v11spositiontaking_20 = spositiontaking, @old_auto_v11spositiontaking_20 = autopositiontaking, @old_isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=11

select @old_v99mpositiontaking_1 = mpositiontaking, @old_v99spositiontaking_1 = spositiontaking, @old_auto_v99spositiontaking_1 = autopositiontaking, @old_isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=99
select @old_v99mpositiontaking_2 = mpositiontaking, @old_v99spositiontaking_2 = spositiontaking, @old_auto_v99spositiontaking_2 = autopositiontaking, @old_isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=99
select @old_v99mpositiontaking_3 = mpositiontaking, @old_v99spositiontaking_3 = spositiontaking, @old_auto_v99spositiontaking_3 = autopositiontaking, @old_isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=99
select @old_v99mpositiontaking_20 = mpositiontaking, @old_v99spositiontaking_20 = spositiontaking, @old_auto_v99spositiontaking_20 = autopositiontaking, @old_isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=99

-- mixed sports
select @old_v99mpositiontaking_9 = mpositiontaking, @old_v99spositiontaking_9 = spositiontaking, @old_auto_v99spositiontaking_9 = autopositiontaking, @old_isauto_v99spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=99

select @old_v154mpositiontaking_20 = mpositiontaking, @old_v154spositiontaking_20 = spositiontaking, @old_auto_v154spositiontaking_20 = autopositiontaking, @old_isauto_v154spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=154

-- number game
select @old_v161mpositiontaking_81 = mpositiontaking, @old_v161spositiontaking_81 = spositiontaking, @old_auto_v161spositiontaking_81 = autopositiontaking, @old_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161
select @old_v161mpositiontaking_83 = mpositiontaking, @old_v161spositiontaking_83 = spositiontaking, @old_auto_v161spositiontaking_83 = autopositiontaking, @old_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161
select @old_v161mpositiontaking_88 = mpositiontaking, @old_v161spositiontaking_88 = spositiontaking, @old_auto_v161spositiontaking_88 = autopositiontaking, @old_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161
select @old_v161mlivepositiontaking_85 = mlivepositiontaking, @old_v161slivepositiontaking_85 = slivepositiontaking, @old_auto_v161slivepositiontaking_85 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
select @old_v161mlivepositiontaking_86 = mlivepositiontaking, @old_v161mpositiontaking_86 = mpositiontaking,@old_v161spositiontaking_86 = spositiontaking,@old_v161slivepositiontaking_86 = slivepositiontaking, @old_auto_v161spositiontaking_86 = autopositiontaking, @old_isauto_v161spositiontaking_86 = isautopositiontaking, @old_auto_v161slivepositiontaking_86 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
select @old_v161mlivepositiontaking_87 = mlivepositiontaking, @old_v161slivepositiontaking_87 = slivepositiontaking, @old_auto_v161slivepositiontaking_87 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
select @old_v161mlivepositiontaking_89 = mlivepositiontaking, @old_v161slivepositiontaking_89 = slivepositiontaking, @old_auto_v161slivepositiontaking_89 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
select @old_v161mlivepositiontaking_90 = mlivepositiontaking, @old_v161slivepositiontaking_90 = slivepositiontaking, @old_auto_v161slivepositiontaking_90 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161
    
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if @UpdateMultiple = 0 or @UpdatePositiontaking=1 
BEGIN
    --check u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 1 as sporttype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1 as autolivepositiontaking
            union all     select 2 as bettype, 1 as sporttype, @auto_spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 1 as sporttype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3 as autolivepositiontaking
            union all     select 4 as bettype, 1 as sporttype, @auto_spositiontaking_4 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 5 as bettype, 1 as sporttype, @auto_spositiontaking_5 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 6 as bettype, 1 as sporttype, @auto_spositiontaking_6 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 7 as bettype, 1 as sporttype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7 as autolivepositiontaking
            union all     select 8 as bettype, 1 as sporttype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8 as autolivepositiontaking
            union all     select 9 as bettype, 1 as sporttype, @auto_spositiontaking_9 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 1 as sporttype, @auto_spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
                       
            union all     select 9999 as bettype, 1 as sporttype, @auto_spositiontaking_9999 as autopositiontaking, 0 as autolivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking+@maxdownlinepos<b.autolivepositiontaking))


    if @ErrType <>''    
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end    , @ErrCode = 101
        return
    END
    
    --check s3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking
            union all     select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
            union all     select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking
            union all     select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking
            union all     select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking
            union all     select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking
            union all     select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking
            union all     select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking
            union all     select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
            union all     select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
            
            union all     select 9999 as bettype, 1 as sporttype, @spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking+@maxdownlinepos<b.slivepositiontaking+b.mlivepositiontaking))
    
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end    , @ErrCode = 102
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv2=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
            select 1 as bettype, 2 as sporttype, @auto_v2spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 2 as bettype, 2 as sporttype, @auto_v2spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 2 as sporttype, @auto_v2spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 7 as bettype, 2 as sporttype, @auto_v2spositiontaking_7 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 8 as bettype, 2 as sporttype, @auto_v2spositiontaking_8 as autopositiontaking, 0 as autolivepositiontaking
--            union all     select 9 as bettype, 2 as sporttype, @auto_v2spositiontaking_9 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 2 as sporttype, @auto_v2spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 2 as sporttype, @auto_v2spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))

    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 2 as sporttype, @v2spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_1 as mpositiontaking
            union all     select 2 as bettype, 2 as sporttype, @v2spositiontaking_2 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_2 as mpositiontaking
            union all     select 3 as bettype, 2 as sporttype, @v2spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_3 as mpositiontaking
--            union all     select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_7 as mpositiontaking
--            union all     select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_8 as mpositiontaking
--            union all     select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_9 as mpositiontaking
            union all     select 20 as bettype, 2 as sporttype, @v2spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 2 as sporttype, @v2spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v2mpositiontaking_10 as mpositiontaking
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )

    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv3=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 3 as sporttype, @auto_v3spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 2 as bettype, 3 as sporttype, @auto_v3spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 3 as sporttype, @auto_v3spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 3 as sporttype, @auto_v3spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 3 as sporttype, @auto_v3spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))

    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 3 as sporttype, @v3spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v3mpositiontaking_1 as mpositiontaking
            union all     select 2 as bettype, 3 as sporttype, @v3spositiontaking_2 as spositiontaking, 0 as livepositiontaking, @v3mpositiontaking_2 as mpositiontaking
            union all     select 3 as bettype, 3 as sporttype, @v3spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v3mpositiontaking_3 as mpositiontaking
            union all     select 20 as bettype, 3 as sporttype, @v3spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v3mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 3 as sporttype, @v3spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v3mpositiontaking_10 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv5=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 5 as sporttype, @auto_v5spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 2 as bettype, 5 as sporttype, @auto_v5spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 5 as sporttype, @auto_v5spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 5 as sporttype, @auto_v5spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 5 as sporttype, @auto_v5spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 9999 as bettype, 5 as sporttype, @auto_v5spositiontaking_9999 as autopositiontaking, 0 as autolivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v5mpositiontaking_1 as mpositiontaking
            union all     select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as livepositiontaking, @v5mpositiontaking_2 as mpositiontaking
            union all     select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v5mpositiontaking_3 as mpositiontaking
            union all     select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v5mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v5mpositiontaking_10 as mpositiontaking
            union all     select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as livepositiontaking, @v5mpositiontaking_9999 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv8=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 8 as sporttype, @auto_v8spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 8 as sporttype, @auto_v8spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 8 as sporttype, @auto_v8spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 8 as sporttype, @auto_v8spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking 
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_1 as mpositiontaking
            union all     select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_3 as mpositiontaking
            union all     select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v8mpositiontaking_10 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv10=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 10 as sporttype, @auto_v10spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 2 as bettype, 10 as sporttype, @auto_v10spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 10 as sporttype, @auto_v10spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 10 as sporttype, @auto_v10spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 10 as sporttype, @auto_v10spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v10mpositiontaking_1 as mpositiontaking
            union all     select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as livepositiontaking, @v10mpositiontaking_2 as mpositiontaking
            union all     select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v10mpositiontaking_3 as mpositiontaking
            union all     select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v10mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v10mpositiontaking_10 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv11=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 11 as sporttype, @auto_v11spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 11 as sporttype, @auto_v11spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 11 as sporttype, @auto_v11spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v11mpositiontaking_1 as mpositiontaking
            union all     select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v11mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v11mpositiontaking_10 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

if @UpdateMultiple = 0 or @UpdatePositiontakingv99=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 99 as sporttype, @auto_v99spositiontaking_1 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 2 as bettype, 99 as sporttype, @auto_v99spositiontaking_2 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 3 as bettype, 99 as sporttype, @auto_v99spositiontaking_3 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 20 as bettype, 99 as sporttype, @auto_v99spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
            union all     select 10 as bettype, 99 as sporttype, @auto_v99spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking
            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as livepositiontaking, @v99mpositiontaking_1 as mpositiontaking
            union all     select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as livepositiontaking, @v99mpositiontaking_2 as mpositiontaking
            union all     select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as livepositiontaking, @v99mpositiontaking_3 as mpositiontaking
            union all     select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v99mpositiontaking_20 as mpositiontaking
            union all     select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as livepositiontaking, @v99mpositiontaking_10 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

--- mixed sports

if @UpdateMultiple = 0 or @UpdatePositiontakingv99MP=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    --+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
            select 9 as bettype, 99 as sporttype, @auto_v99spositiontaking_9 as autopositiontaking, 0 as autolivepositiontaking            
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    --+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
            select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as livepositiontaking, @v99mpositiontaking_9 as mpositiontaking    
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
--        or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.slivepositiontaking)
        )
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

--HR Fixed Odds
if @UpdateMultiple = 0 or @UpdatePositiontakingv154=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 20 as bettype, 154 as sporttype, @auto_v154spositiontaking_20 as autopositiontaking, 0 as autolivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
    from custsetting as cs with (NOLOCK) inner join
        (
                    select 20 as bettype, 154 as sporttype, @v154spositiontaking_20 as spositiontaking, 0 as livepositiontaking, @v154mpositiontaking_20 as mpositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

--- Number game
if @UpdateMultiple = 0 or @UpdatePositiontakingv161=1 
BEGIN
    --u3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting3rd as cs with (NOLOCK) inner join
        (
                        
                        select 81 as bettype, 161 as sporttype, @auto_v161spositiontaking_81 as autopositiontaking, 0 as autolivepositiontaking            
            union all   select 83 as bettype, 161 as sporttype, @auto_v161spositiontaking_83 as autopositiontaking, 0 as autolivepositiontaking            
            union all   select 88 as bettype, 161 as sporttype, @auto_v161spositiontaking_88 as autopositiontaking, 0 as autolivepositiontaking            
            union all     select 85 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_85 as autolivepositiontaking
            union all     select 86 as bettype, 161 as sporttype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86 as autolivepositiontaking
            union all     select 87 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_86 as autolivepositiontaking
            union all     select 89 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_89 as autolivepositiontaking
            union all     select 90 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161slivepositiontaking_90 as autolivepositiontaking
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and
        ((cs.spositiontaking+@maxdownlinepos<b.autopositiontaking))
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong auto position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 103
        return
    END
    --s3<=s4,s3+m3<=s4
    select @ErrType = ''
    select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) as varchar(10))
    + case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((cs.slivepositiontaking) as varchar(10)) else '' end + '<br>'
    from custsetting3rd as cs with (NOLOCK) inner join
        (
                        select 81 as bettype, 161 as sporttype, @v161spositiontaking_81 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking
            union all    select 83 as bettype, 161 as sporttype, @v161spositiontaking_83 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking    
            union all    select 88 as bettype, 161 as sporttype, @v161spositiontaking_88 as spositiontaking, 0 as slivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking    
            union all    select 85 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_85 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking    
            union all    select 86 as bettype, 161 as sporttype, @v161spositiontaking_86 as spositiontaking, @v161slivepositiontaking_86 as slivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking    
            union all    select 87 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_87 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking    
            union all    select 89 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_89 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking    
            union all    select 90 as bettype, 161 as sporttype, 0 as spositiontaking, @v161slivepositiontaking_90 as slivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking    
        ) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
        INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
        INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
    where cs.custid = @srecommend
        and 
        ((cs.spositiontaking<b.spositiontaking) or (cs.spositiontaking+@maxdownlinepos<b.spositiontaking+b.mpositiontaking)
            or (b.bettype in (85,86,87,89,90) and b.sporttype=161 and cs.slivepositiontaking<b.slivepositiontaking)
        )  
    if @ErrType <>''
    BEGIN
        Select @ErrMsg =    @UserName + ': '+
                            case @Language 
                                when 'E' then 'Wrong position taking.<br>'+@ErrType
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
                            end, @ErrCode = 104
        return
    END
END

------------
update custsetting with (ROWLOCK, UPDLOCK)
set
    spositiontaking = case
                    when @UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0)
                                                    or (sporttype=2 and @UpdatePositiontakingv2 = 0)
                                                    or (sporttype=3 and @UpdatePositiontakingv3 = 0)
                                                    or (sporttype=5 and @UpdatePositiontakingv5 = 0)
                                                    or (sporttype=8 and @UpdatePositiontakingv8 = 0)
                                                    or (sporttype=10 and @UpdatePositiontakingv10 = 0)
                                                    or (sporttype=11 and @UpdatePositiontakingv11 = 0)
                                                    or (sporttype=99 and @UpdatePositiontakingv99 = 0 and bettype <> 9)
                                                    or (sporttype=99 and @UpdatePositiontakingv99MP = 0 and bettype = 9)    
                                                    or (sporttype=154 and @UpdatePositiontakingv154 = 0)
                                                    ) then spositiontaking
                    else case sporttype 
                        when 1 then case bettype when 1 then @spositiontaking_1 when 2 then @spositiontaking_2 when 3 then @spositiontaking_3 when 4 then @spositiontaking_4 when 5 then @spositiontaking_5 when 6 then @spositiontaking_6 when 7 then @spositiontaking_7 when 8 then @spositiontaking_8 when 9 then @spositiontaking_9 when 10 then @spositiontaking_10 when 9999 then @spositiontaking_9999 else 0 end
                        
                        when 2 then case bettype when 1 then @v2spositiontaking_1 when 2 then @v2spositiontaking_2 when 3 then @v2spositiontaking_3 when 7 then @v2spositiontaking_7 when 8 then @v2spositiontaking_8 /*when 9 then @v2spositiontaking_9*/ when 20 then @v2spositiontaking_20 when 10 then @v2spositiontaking_10 else 0 end
                        
                        when 3 then case bettype when 1 then @v3spositiontaking_1 when 2 then @v3spositiontaking_2 when 3 then @v3spositiontaking_3 when 20 then @v3spositiontaking_20 when 10 then @v3spositiontaking_10 else 0 end
                        
                        when 5 then case bettype when 1 then @v5spositiontaking_1 when 2 then @v5spositiontaking_2 when 3 then @v5spositiontaking_3 when 20 then @v5spositiontaking_20 when 9999 then @v5spositiontaking_9999 when 10 then @v5spositiontaking_10 else 0 end
                        
                        when 8 then case bettype when 1 then @v8spositiontaking_1 when 3 then @v8spositiontaking_3 when 20 then @v8spositiontaking_20 when 10 then @v8spositiontaking_10 else 0 end
                        
                        when 10 then case bettype when 1 then @v10spositiontaking_1 when 2 then @v10spositiontaking_2 when 3 then @v10spositiontaking_3 when 20 then @v10spositiontaking_20 when 10 then @v10spositiontaking_10 else 0 end
                        
                        when 11 then case bettype when 1 then @v11spositiontaking_1 when 20 then @v11spositiontaking_20 when 10 then @v11spositiontaking_10 else 0 end
                        
                        when 99 then case bettype when 1 then @v99spositiontaking_1 when 2 then @v99spositiontaking_2 when 3 then @v99spositiontaking_3 when 20 then @v99spositiontaking_20 when 9 then @v99spositiontaking_9 when 10 then @v99spositiontaking_10 else 0 end
                        
                        when 154 then case bettype when 20 then @v154spositiontaking_20 else 0 end
                        else spositiontaking end    end,
    
    slivepositiontaking = case when @UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) 
                                                            or (sporttype=2 and @UpdatePositiontakingv2 = 0) 
                                                            or (sporttype=3 and @UpdatePositiontakingv3 = 0) 
                                                            or (sporttype=5 and @UpdatePositiontakingv5 = 0) 
                                                            or (sporttype=8 and @UpdatePositiontakingv8 = 0) 
                                                            or (sporttype=10 and @UpdatePositiontakingv10 = 0) 
                                                            or (sporttype=11 and @UpdatePositiontakingv11 = 0) 
                                                            or (sporttype=99 and @UpdatePositiontakingv99 = 0) 
                                                            or (sporttype=154 and @UpdatePositiontakingv154 = 0)) then slivepositiontaking 
                        else case sporttype     
                            when 1 then case bettype    when 1 then @slivepositiontaking_1 
                                                        when 3 then @slivepositiontaking_3 
                                                        when 7 then @slivepositiontaking_7 
                                                        when 8 then @slivepositiontaking_8 else slivepositiontaking end 
                            else slivepositiontaking end end,
    
    mpositiontaking = case when @UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) 
                                                            or (sporttype=2 and @UpdatePositiontakingv2 = 0) 
                                                            or (sporttype=3 and @UpdatePositiontakingv3 = 0) 
                                                            or (sporttype=5 and @UpdatePositiontakingv5 = 0) 
                                                            or (sporttype=8 and @UpdatePositiontakingv8 = 0) 
                                                            or (sporttype=10 and @UpdatePositiontakingv10 = 0) 
                                                            or (sporttype=11 and @UpdatePositiontakingv11 = 0) 
                                                            or (sporttype=99 and @UpdatePositiontakingv99 = 0 and bettype <> 9) 
                                                            or (sporttype=99 and @UpdatePositiontakingv99MP = 0 and bettype = 9) 
                                                            or (sporttype=154 and @UpdatePositiontakingv154 = 0)) then mpositiontaking 
                    else case sporttype     
                        when 1 then case bettype when 1 then @mpositiontaking_1 when 2 then @mpositiontaking_2 when 3 then @mpositiontaking_3 when 4 then @mpositiontaking_4 when 5 then @mpositiontaking_5 when 6 then @mpositiontaking_6 when 7 then @mpositiontaking_7 when 8 then @mpositiontaking_8 when 9 then @mpositiontaking_9 when 10 then @mpositiontaking_10 when 9999 then @mpositiontaking_9999 else 0 end                    
                        
                        when 2 then case bettype when 1 then @v2mpositiontaking_1 when 2 then @v2mpositiontaking_2 when 3 then @v2mpositiontaking_3 when 7 then @v2mpositiontaking_7 when 8 then @v2mpositiontaking_8 /*when 9 then @v2mpositiontaking_9*/ when 20 then @v2mpositiontaking_20 when 10 then @v2mpositiontaking_10 else  0 end
                        
                        when 3 then case bettype when 1 then @v3mpositiontaking_1 when 2 then @v3mpositiontaking_2 when 3 then @v3mpositiontaking_3 when 20 then @v3mpositiontaking_20 when 10 then @v3mpositiontaking_10 else 0 end
                        
                        when 5 then case bettype when 1 then @v5mpositiontaking_1 when 2 then @v5mpositiontaking_2 when 3 then @v5mpositiontaking_3 when 20 then @v5mpositiontaking_20 when 9999 then @v5mpositiontaking_9999 when 10 then @v5mpositiontaking_10 else 0 end
                        
                        when 8 then case bettype when 1 then @v8mpositiontaking_1 when 3 then @v8mpositiontaking_3 when 20 then @v8mpositiontaking_20 when 10 then @v8mpositiontaking_10 else 0 end
                        
                        when 10 then case bettype when 1 then @v10mpositiontaking_1 when 2 then @v10mpositiontaking_2 when 3 then @v10mpositiontaking_3 when 20 then @v10mpositiontaking_20 when 10 then @v10mpositiontaking_10 else 0 end
                        
                        when 11 then case bettype when 1 then @v11mpositiontaking_1 when 20 then @v11mpositiontaking_20 when 10 then @v11mpositiontaking_10 else 0 end
                        
                        when 99 then case bettype when 1 then @v99mpositiontaking_1 when 2 then @v99mpositiontaking_2 when 3 then @v99mpositiontaking_3 when 20 then @v99mpositiontaking_20 when 9 then @v99mpositiontaking_9 when 10 then @v99mpositiontaking_10 else 0 end
                        when 154 then case bettype when 20 then @v154mpositiontaking_20 else 0 end
                        else mpositiontaking end end,
    
    mlivepositiontaking = case when @UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) 
                                                            or (sporttype=2 and @UpdatePositiontakingv2 = 0) 
                                                            or (sporttype=3 and @UpdatePositiontakingv3 = 0) 
                                                            or (sporttype=5 and @UpdatePositiontakingv5 = 0) 
                                                            or (sporttype=8 and @UpdatePositiontakingv8 = 0) 
                                                            or (sporttype=10 and @UpdatePositiontakingv10 = 0) 
                                                            or (sporttype=11 and @UpdatePositiontakingv11 = 0)  
                                                            or (sporttype=99 and @UpdatePositiontakingv99 = 0) 
                                                            or (sporttype=154 and @UpdatePositiontakingv154 = 0)) then mlivepositiontaking 
                        else case sporttype     
                                when 1 then case bettype    when 1 then @mlivepositiontaking_1 
                                                            when 3 then @mlivepositiontaking_3 
                                                            when 7 then @mlivepositiontaking_7 
                                                            when 8 then @mlivepositiontaking_8 else mlivepositiontaking end 
                            else mlivepositiontaking end end
    
where custid=@custid
if (@@error <> 0)
begin
    
    Select @ErrMsg = @UserName + ': '+
                    case @Language 
                        when 'E' then 'Update process is unsuccessful !'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                    end    , @ErrCode = 122                     
    
    return
end


--- update number game
update custsetting3rd with(rowlock,updlock)
set spositiontaking = case when @UpdateMultiple = 1 and (sporttype = 161 and @UpdatePositiontakingv161 = 0) then spositiontaking
                           else case sporttype when 161 then case bettype when 81 then @v161spositiontaking_81 when 83 then @v161spositiontaking_83 when 86 then @v161spositiontaking_86 when 88 then @v161spositiontaking_88 else spositiontaking end else spositiontaking end end,
slivepositiontaking = case when @UpdateMultiple = 1 and (sporttype = 161 and @UpdatePositiontakingv161 = 0) then slivepositiontaking 
                           else case sporttype when 161 then case bettype when 85 then @v161slivepositiontaking_85 when 86 then @v161slivepositiontaking_86 when 87 then @v161slivepositiontaking_87 when 89 then @v161slivepositiontaking_89 when 90 then @v161slivepositiontaking_90 else slivepositiontaking end else slivepositiontaking end end,
    mpositiontaking = case when @UpdateMultiple = 1 and (sporttype = 161 and @UpdatePositiontakingv161 = 0) then mpositiontaking
                           else case sporttype when 161 then case bettype when 81 then @v161mpositiontaking_81 when 83 then @v161mpositiontaking_83 when 86 then @v161mpositiontaking_86 when 88 then @v161mpositiontaking_88 else mpositiontaking end else mpositiontaking end end,
mlivepositiontaking = case when @UpdateMultiple = 1 and (sporttype = 161 and @UpdatePositiontakingv161 = 0) then mlivepositiontaking 
                           else case sporttype when 161 then case bettype when 85 then @v161mlivepositiontaking_85 when 86 then @v161mlivepositiontaking_86 when 87 then @v161mlivepositiontaking_87 when 89 then @v161mlivepositiontaking_89 when 90 then @v161mlivepositiontaking_90 else mlivepositiontaking end else mlivepositiontaking end end
where custid = @custid

if (@@error <> 0)
begin
    
    Select @ErrMsg = @UserName + ': '+
                    case @Language 
                        when 'E' then 'Update process is unsuccessful !'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                    end    , @ErrCode = 122                     
    
    return
end

EXEC dbo.Acc_CustomerUpdMaster_AutoPositiontaking
        @mrecommend=@custid, @srecommend = @srecommend,
        @auto_spositiontaking_1 = @auto_spositiontaking_1,
        @auto_spositiontaking_2 = @auto_spositiontaking_2, 
        @auto_spositiontaking_3 = @auto_spositiontaking_3,
        @auto_spositiontaking_4 = @auto_spositiontaking_4,
        @auto_spositiontaking_5 = @auto_spositiontaking_5, 
        @auto_spositiontaking_6 = @auto_spositiontaking_6,
        @auto_spositiontaking_7 = @auto_spositiontaking_7,
        @auto_spositiontaking_8 = @auto_spositiontaking_8, 
        @auto_spositiontaking_9 = @auto_spositiontaking_9,
        @auto_spositiontaking_10 = @auto_spositiontaking_10,
        @auto_spositiontaking_9999 = @auto_spositiontaking_9999,
        
        @auto_slivepositiontaking_1 = @auto_slivepositiontaking_1, 
        @auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
        @auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
        @auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
         
        @auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
        @auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
        @auto_v2spositiontaking_3 = @auto_v2spositiontaking_3, 
        @auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
        @auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,
--        @auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
        @auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
        
        @auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
        @auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
        @auto_v3spositiontaking_3 = @auto_v3spositiontaking_3, 
        @auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,

        @auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
        @auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
        @auto_v5spositiontaking_3 = @auto_v5spositiontaking_3, 
        @auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
        @auto_v5spositiontaking_9999 = @auto_v5spositiontaking_9999, 

        @auto_v8spositiontaking_1 = @auto_v8spositiontaking_1,
        @auto_v8spositiontaking_3 = @auto_v8spositiontaking_3, 
        @auto_v8spositiontaking_20 = @auto_v8spositiontaking_20,

        @auto_v10spositiontaking_1 = @auto_v10spositiontaking_1,
        @auto_v10spositiontaking_2 = @auto_v10spositiontaking_2,
        @auto_v10spositiontaking_3 = @auto_v10spositiontaking_3, 
        @auto_v10spositiontaking_20 = @auto_v10spositiontaking_20,

        @auto_v11spositiontaking_1 = @auto_v11spositiontaking_1,
        @auto_v11spositiontaking_20 = @auto_v11spositiontaking_20,

        @auto_v99spositiontaking_1 = @auto_v99spositiontaking_1,
        @auto_v99spositiontaking_2 = @auto_v99spositiontaking_2,
        @auto_v99spositiontaking_3 = @auto_v99spositiontaking_3, 
        @auto_v99spositiontaking_20 = @auto_v99spositiontaking_20,

        -- mixed sports
        @auto_v99spositiontaking_9 = @auto_v99spositiontaking_9, 
        @auto_v154spositiontaking_20 = @auto_v154spositiontaking_20,
    
        -- number game
        @auto_v161spositiontaking_81 = @auto_v161spositiontaking_81, 
        @auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,         
        @auto_v161spositiontaking_86 = @auto_v161spositiontaking_86, 
        @auto_v161spositiontaking_88 = @auto_v161spositiontaking_88, 
        @auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85, 
        @auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86, 
        @auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87, 
        @auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89, 
        @auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90, 
        
        @updatemultiple = @updatemultiple,
        @updatepositiontaking = @updatepositiontaking, 
        
        @UpdatePositiontakingv2 = @UpdatePositiontakingv2,
        @UpdatePositiontakingv3 = @UpdatePositiontakingv3,
        @UpdatePositiontakingv5 = @UpdatePositiontakingv5,
        @UpdatePositiontakingv8 = @UpdatePositiontakingv8,
        @UpdatePositiontakingv10 = @UpdatePositiontakingv10,
        @UpdatePositiontakingv11 = @UpdatePositiontakingv11,
        @UpdatePositiontakingv99 = @UpdatePositiontakingv99,

        -- mixed sports
        @UpdatePositiontakingv99MP = @UpdatePositiontakingv99MP,
        @UpdatePositiontakingv154 = @UpdatePositiontakingv154,
        
        -- number game
        @UpdatePositiontakingv161 = @UpdatePositiontakingv161,
        
        @language = @language,
        @updateallmembers = @updateallmembers,
        @newspositiontaking = @newspositiontaking,
        @userid = @userid,

        @isauto_spositiontaking_1    =     @isauto_spositiontaking_1,
        @isauto_spositiontaking_2    =     @isauto_spositiontaking_2,
        @isauto_spositiontaking_3    =     @isauto_spositiontaking_3,

        @isauto_spositiontaking_4    =     @isauto_spositiontaking_4,
        @isauto_spositiontaking_5    =     @isauto_spositiontaking_5,
        @isauto_spositiontaking_6    =     @isauto_spositiontaking_6,
        @isauto_spositiontaking_7    =     @isauto_spositiontaking_7,
        @isauto_spositiontaking_8    =     @isauto_spositiontaking_8,
        @isauto_spositiontaking_9    =     @isauto_spositiontaking_9,
        @isauto_spositiontaking_10    =     @isauto_spositiontaking_10,
        @isauto_spositiontaking_9999    =     @isauto_spositiontaking_9999,
        
        @isauto_slivepositiontaking_1    =     @isauto_slivepositiontaking_1,
        @isauto_slivepositiontaking_3    =     @isauto_slivepositiontaking_3,
        @isauto_slivepositiontaking_7    =     @isauto_slivepositiontaking_7,
        @isauto_slivepositiontaking_8    =     @isauto_slivepositiontaking_8,
        
        @isauto_v2spositiontaking_1    =     @isauto_v2spositiontaking_1,
        @isauto_v2spositiontaking_2    =     @isauto_v2spositiontaking_2,
        @isauto_v2spositiontaking_3    =     @isauto_v2spositiontaking_3,
        @isauto_v2spositiontaking_7    =     @isauto_v2spositiontaking_7,
        @isauto_v2spositiontaking_8    =     @isauto_v2spositiontaking_8,
--        @isauto_v2spositiontaking_9    =     @isauto_v2spositiontaking_9,
        @isauto_v2spositiontaking_20    =     @isauto_v2spositiontaking_20,
        
        @isauto_v3spositiontaking_1    =     @isauto_v3spositiontaking_1,
        @isauto_v3spositiontaking_2    =     @isauto_v3spositiontaking_2,
        @isauto_v3spositiontaking_3    =     @isauto_v3spositiontaking_3,
        @isauto_v3spositiontaking_20    =     @isauto_v3spositiontaking_20,

        @isauto_v5spositiontaking_1    =     @isauto_v5spositiontaking_1,
        @isauto_v5spositiontaking_2    =     @isauto_v5spositiontaking_2,
        @isauto_v5spositiontaking_3    =     @isauto_v5spositiontaking_3,
        @isauto_v5spositiontaking_20    =     @isauto_v5spositiontaking_20,
        @isauto_v5spositiontaking_9999    =     @isauto_v5spositiontaking_9999,

        @isauto_v8spositiontaking_1    =     @isauto_v8spositiontaking_1,
        @isauto_v8spositiontaking_3    =     @isauto_v8spositiontaking_3,
        @isauto_v8spositiontaking_20    =     @isauto_v8spositiontaking_20,

        @isauto_v10spositiontaking_1    =     @isauto_v10spositiontaking_1,
        @isauto_v10spositiontaking_2    =     @isauto_v10spositiontaking_2,
        @isauto_v10spositiontaking_3    =     @isauto_v10spositiontaking_3,
        @isauto_v10spositiontaking_20    =     @isauto_v10spositiontaking_20,

        @isauto_v11spositiontaking_1    =     @isauto_v11spositiontaking_1,
        @isauto_v11spositiontaking_20    =     @isauto_v11spositiontaking_20,

        @isauto_v99spositiontaking_1    =     @isauto_v99spositiontaking_1,
        @isauto_v99spositiontaking_2    =     @isauto_v99spositiontaking_2,
        @isauto_v99spositiontaking_3    =     @isauto_v99spositiontaking_3,
        @isauto_v99spositiontaking_20    =     @isauto_v99spositiontaking_20,

        -- mixed sports
        @isauto_v99spositiontaking_9    =     @isauto_v99spositiontaking_9,
        @isauto_v154spositiontaking_20    =     @isauto_v154spositiontaking_20,

        -- number game
        @isauto_v161spositiontaking_81    =     @isauto_v161spositiontaking_81,
        @isauto_v161spositiontaking_83    =     @isauto_v161spositiontaking_83,        
        @isauto_v161spositiontaking_86    =     @isauto_v161spositiontaking_86,
        @isauto_v161spositiontaking_88    =     @isauto_v161spositiontaking_88,
        @isauto_v161slivepositiontaking_85    =     @isauto_v161slivepositiontaking_85,
        @isauto_v161slivepositiontaking_86    =     @isauto_v161slivepositiontaking_86,
        @isauto_v161slivepositiontaking_87    =     @isauto_v161slivepositiontaking_87,
        @isauto_v161slivepositiontaking_89    =     @isauto_v161slivepositiontaking_89,
        @isauto_v161slivepositiontaking_90    =     @isauto_v161slivepositiontaking_90,

		-- Outright PT for sports
		@auto_v2spositiontaking_10 = @auto_v2spositiontaking_10,
		@auto_v3spositiontaking_10 = @auto_v3spositiontaking_10,
		@auto_v5spositiontaking_10 = @auto_v5spositiontaking_10,
		@auto_v8spositiontaking_10 = @auto_v8spositiontaking_10,
		@auto_v10spositiontaking_10 = @auto_v10spositiontaking_10,
		@auto_v11spositiontaking_10 = @auto_v11spositiontaking_10,
		@auto_v99spositiontaking_10 = @auto_v99spositiontaking_10,
		
		@isauto_v2spositiontaking_10 = @isauto_v2spositiontaking_10,
		@isauto_v3spositiontaking_10 = @isauto_v3spositiontaking_10,
		@isauto_v5spositiontaking_10 = @isauto_v5spositiontaking_10,
		@isauto_v8spositiontaking_10 = @isauto_v8spositiontaking_10,
		@isauto_v10spositiontaking_10 = @isauto_v10spositiontaking_10,
		@isauto_v11spositiontaking_10 = @isauto_v11spositiontaking_10,
		@isauto_v99spositiontaking_10 = @isauto_v99spositiontaking_10,

        @ErrCode = @ErrCode OUTPUT,
        @ErrMsg = @ErrMsg OUTPUT
        
if (@@error <> 0)
begin
    
    Select @ErrMsg = @UserName + ': '+
                    case @Language 
                        when 'E' then 'Update process is unsuccessful !'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                    end, @ErrCode = 123                     
    
    return
end

--- 20131030@Johnson: Apply execrep for recalculating pt on members
EXEC dbo.Acc_CustSetting_07 @srecommend = @srecommend, @mrecommend = @custid, @roleid = 3

EXEC dbo.Acc_CustSetting3rd_07 @srecommend = @srecommend, @mrecommend = @custid, @roleid = 3, @mode = 'number'
/*
EXEC dbo.Acc_CustomerUpdMaster_MaxPositiontaking @mrecommend = @custid
if (@@error <> 0)
begin
    
    Select @ErrMsg = @UserName + ': '+
                    case @Language 
                        when 'E' then 'Update process is unsuccessful !'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                    end, @ErrCode = 124                     
    
    return
end
*/

Declare @LogSPData varchar(MAX)
Declare @TrackingValue2 varchar(MAX)
----------
-- 20150715@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
---------------------------------
SELECT  @spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_1 ELSE @spositiontaking_1 END,
    @spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_2 ELSE @spositiontaking_2 END,
    @spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_3 ELSE @spositiontaking_3 END,
    @spositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_4 ELSE @spositiontaking_4 END,
    @spositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_5 ELSE @spositiontaking_5 END,
    @spositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_6 ELSE @spositiontaking_6 END,
    @spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_7 ELSE @spositiontaking_7 END,
    @spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_8 ELSE @spositiontaking_8 END,
    @spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_9 ELSE @spositiontaking_9 END,
    @spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_10 ELSE @spositiontaking_10 END,
    -- Outright PT for sports
    @v2spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2spositiontaking_10 ELSE @v2spositiontaking_10 END,
    @v3spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3spositiontaking_10 ELSE @v3spositiontaking_10 END,
    @v5spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5spositiontaking_10 ELSE @v5spositiontaking_10 END,
    @v8spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8spositiontaking_10 ELSE @v8spositiontaking_10 END,
    @v10spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10spositiontaking_10 ELSE @v10spositiontaking_10 END,
    @v11spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11spositiontaking_10 ELSE @v11spositiontaking_10 END,
    @v99spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99spositiontaking_10 ELSE @v99spositiontaking_10 END,
    
    @spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_9999 ELSE @spositiontaking_9999 END,
    @slivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_slivepositiontaking_1 ELSE @slivepositiontaking_1 END,
    @slivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_slivepositiontaking_3 ELSE @slivepositiontaking_3 END,
    @slivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_slivepositiontaking_7 ELSE @slivepositiontaking_7 END,
    @slivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_slivepositiontaking_8 ELSE @slivepositiontaking_8 END,
    
	@auto_spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_1 ELSE @auto_spositiontaking_1 END,
    @auto_spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_2 ELSE @auto_spositiontaking_2 END,
    @auto_spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_3 ELSE @auto_spositiontaking_3 END,
    @auto_spositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_4 ELSE @auto_spositiontaking_4 END,
    @auto_spositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_5 ELSE @auto_spositiontaking_5 END,
    @auto_spositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_6 ELSE @auto_spositiontaking_6 END,
    @auto_spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_7 ELSE @auto_spositiontaking_7 END,
    @auto_spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_8 ELSE @auto_spositiontaking_8 END,
    @auto_spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_9 ELSE @auto_spositiontaking_9 END,
    @auto_spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_10 ELSE @auto_spositiontaking_10 END,
    
    -- Outright PT for sports
    @auto_v2spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2spositiontaking_10 ELSE @auto_v2spositiontaking_10 END,
    @auto_v3spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_auto_v3spositiontaking_10 ELSE @auto_v3spositiontaking_10 END,
    @auto_v5spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5spositiontaking_10 ELSE @auto_v5spositiontaking_10 END,
    @auto_v8spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_auto_v8spositiontaking_10 ELSE @auto_v8spositiontaking_10 END,
    @auto_v10spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_auto_v10spositiontaking_10 ELSE @auto_v10spositiontaking_10 END,
    @auto_v11spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_auto_v11spositiontaking_10 ELSE @auto_v11spositiontaking_10 END,
    @auto_v99spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_auto_v99spositiontaking_10 ELSE @auto_v99spositiontaking_10 END,
    
    @auto_spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_spositiontaking_9999 ELSE @auto_spositiontaking_9999 END,
    @auto_slivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_slivepositiontaking_1 ELSE @auto_slivepositiontaking_1 END,
    @auto_slivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_slivepositiontaking_3 ELSE @auto_slivepositiontaking_3 END,
    @auto_slivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_slivepositiontaking_7 ELSE @auto_slivepositiontaking_7 END,
    @auto_slivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_slivepositiontaking_8 ELSE @auto_slivepositiontaking_8 END,

	@isauto_spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_1 ELSE @isauto_spositiontaking_1 END,
    @isauto_spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_2 ELSE @isauto_spositiontaking_2 END,
    @isauto_spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_3 ELSE @isauto_spositiontaking_3 END,
    @isauto_spositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_4 ELSE @isauto_spositiontaking_4 END,
    @isauto_spositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_5 ELSE @isauto_spositiontaking_5 END,
    @isauto_spositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_6 ELSE @isauto_spositiontaking_6 END,
    @isauto_spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_7 ELSE @isauto_spositiontaking_7 END,
    @isauto_spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_8 ELSE @isauto_spositiontaking_8 END,
    @isauto_spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_9 ELSE @isauto_spositiontaking_9 END,
    @isauto_spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_10 ELSE @isauto_spositiontaking_10 END,
    
    -- Outright PT for sports
    @isauto_v2spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_10 ELSE @isauto_v2spositiontaking_10 END,
    @isauto_v3spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3spositiontaking_10 ELSE @isauto_v3spositiontaking_10 END,
    @isauto_v5spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_10 ELSE @isauto_v5spositiontaking_10 END,
    @isauto_v8spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8spositiontaking_10 ELSE @isauto_v8spositiontaking_10 END,
    @isauto_v10spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10spositiontaking_10 ELSE @isauto_v10spositiontaking_10 END,
    @isauto_v11spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11spositiontaking_10 ELSE @isauto_v11spositiontaking_10 END,
    @isauto_v99spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99spositiontaking_10 ELSE @isauto_v99spositiontaking_10 END,
    
    @isauto_spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_9999 ELSE @isauto_spositiontaking_9999 END,
    @isauto_slivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_isauto_slivepositiontaking_1 ELSE @isauto_slivepositiontaking_1 END,
    @isauto_slivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_isauto_slivepositiontaking_3 ELSE @isauto_slivepositiontaking_3 END,
    @isauto_slivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_isauto_slivepositiontaking_7 ELSE @isauto_slivepositiontaking_7 END,
    @isauto_slivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_isauto_slivepositiontaking_8 ELSE @isauto_slivepositiontaking_8 END,

	@mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_1 ELSE @mpositiontaking_1 END,
    @mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_2 ELSE @mpositiontaking_2 END,
    @mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_3 ELSE @mpositiontaking_3 END,
    @mpositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_4 ELSE @mpositiontaking_4 END,
    @mpositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_5 ELSE @mpositiontaking_5 END,
    @mpositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_6 ELSE @mpositiontaking_6 END,
    @mpositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_7 ELSE @mpositiontaking_7 END,
    @mpositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_8 ELSE @mpositiontaking_8 END,
    @mpositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_9 ELSE @mpositiontaking_9 END,
    @mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_10 ELSE @mpositiontaking_10 END,
    
    -- Outright PT for sports
    @v2mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_10 ELSE @v2mpositiontaking_10 END,
    @v3mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_10 ELSE @v3mpositiontaking_10 END,
    @v5mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_10 ELSE @v5mpositiontaking_10 END,
    @v8mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_10 ELSE @v8mpositiontaking_10 END,
    @v10mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_10 ELSE @v10mpositiontaking_10 END,
    @v11mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11mpositiontaking_10 ELSE @v11mpositiontaking_10 END,
    @v99mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_10 ELSE @v99mpositiontaking_10 END,
    
    
    @mpositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_9999 ELSE @mpositiontaking_9999 END,
    @mlivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mlivepositiontaking_1 ELSE @mlivepositiontaking_1 END,
    @mlivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mlivepositiontaking_3 ELSE @mlivepositiontaking_3 END,
    @mlivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mlivepositiontaking_7 ELSE @mlivepositiontaking_7 END,
    @mlivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mlivepositiontaking_8 ELSE @mlivepositiontaking_8 END,

    @v2spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_1 ELSE @v2spositiontaking_1 END,
    @v2spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_2 ELSE @v2spositiontaking_2 END,
    @v2spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_3 ELSE @v2spositiontaking_3 END,
    @v2spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_7 ELSE @v2spositiontaking_7 END,
    @v2spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_8 ELSE @v2spositiontaking_8 END,
--  @v2spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_9 ELSE @v2spositiontaking_9 END,
    @v2spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_20 ELSE @v2spositiontaking_20 END,
    
	@auto_v2spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_1 ELSE @auto_v2spositiontaking_1 END,
    @auto_v2spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_2 ELSE @auto_v2spositiontaking_2 END,
    @auto_v2spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_3 ELSE @auto_v2spositiontaking_3 END,
    @auto_v2spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_7 ELSE @auto_v2spositiontaking_7 END,
    @auto_v2spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_8 ELSE @auto_v2spositiontaking_8 END,
--    @auto_v2spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_9 ELSE @auto_v2spositiontaking_9 END,
    @auto_v2spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_20 ELSE @auto_v2spositiontaking_20 END,

	@isauto_v2spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_1 ELSE @isauto_v2spositiontaking_1 END,
    @isauto_v2spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_2 ELSE @isauto_v2spositiontaking_2 END,
    @isauto_v2spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_3 ELSE @isauto_v2spositiontaking_3 END,
    @isauto_v2spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_7 ELSE @isauto_v2spositiontaking_7 END,
    @isauto_v2spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_8 ELSE @isauto_v2spositiontaking_8 END,
--    @isauto_v2spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_9 ELSE @isauto_v2spositiontaking_9 END,
    @isauto_v2spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_20 ELSE @isauto_v2spositiontaking_20 END,
    
	@v2mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_1 ELSE @v2mpositiontaking_1 END,
    @v2mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_2 ELSE @v2mpositiontaking_2 END,
    @v2mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_3 ELSE @v2mpositiontaking_3 END,
    @v2mpositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_7 ELSE @v2mpositiontaking_7 END,
    @v2mpositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_8 ELSE @v2mpositiontaking_8 END,
--    @v2mpositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_9 ELSE @v2mpositiontaking_9 END,
    @v2mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_20 ELSE @v2mpositiontaking_20 END,
	
    @v3spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3spositiontaking_1 ELSE @v3spositiontaking_1 END,
    @v3spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3spositiontaking_2 ELSE @v3spositiontaking_2 END,
    @v3spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3spositiontaking_3 ELSE @v3spositiontaking_3 END,
    @v3spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3spositiontaking_20 ELSE @v3spositiontaking_20 END,
    
	@auto_v3spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3spositiontaking_1 ELSE @auto_v3spositiontaking_1 END,
    @auto_v3spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3spositiontaking_2 ELSE @auto_v3spositiontaking_2 END,
    @auto_v3spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3spositiontaking_3 ELSE @auto_v3spositiontaking_3 END,
    @auto_v3spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3spositiontaking_20 ELSE @auto_v3spositiontaking_20 END,

	@isauto_v3spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3spositiontaking_1 ELSE @isauto_v3spositiontaking_1 END,
    @isauto_v3spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3spositiontaking_2 ELSE @isauto_v3spositiontaking_2 END,
    @isauto_v3spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3spositiontaking_3 ELSE @isauto_v3spositiontaking_3 END,
    @isauto_v3spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3spositiontaking_20 ELSE @isauto_v3spositiontaking_20 END,

	@v3mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_1 ELSE @v3mpositiontaking_1 END,
    @v3mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_2 ELSE @v3mpositiontaking_2 END,
    @v3mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_3 ELSE @v3mpositiontaking_3 END,
    @v3mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_20 ELSE @v3mpositiontaking_20 END,

    @v5spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5spositiontaking_1 ELSE @v5spositiontaking_1 END,
    @v5spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5spositiontaking_2 ELSE @v5spositiontaking_2 END,
    @v5spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5spositiontaking_3 ELSE @v5spositiontaking_3 END,
    @v5spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5spositiontaking_20 ELSE @v5spositiontaking_20 END,
    @v5spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5spositiontaking_9999 ELSE @v5spositiontaking_9999 END,
    
	@auto_v5spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5spositiontaking_1 ELSE @auto_v5spositiontaking_1 END,
    @auto_v5spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5spositiontaking_2 ELSE @auto_v5spositiontaking_2 END,
    @auto_v5spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5spositiontaking_3 ELSE @auto_v5spositiontaking_3 END,
    @auto_v5spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5spositiontaking_20 ELSE @auto_v5spositiontaking_20 END,
    @auto_v5spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5spositiontaking_9999 ELSE @auto_v5spositiontaking_9999 END,

	@isauto_v5spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_1 ELSE @isauto_v5spositiontaking_1 END,
    @isauto_v5spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_2 ELSE @isauto_v5spositiontaking_2 END,
    @isauto_v5spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_3 ELSE @isauto_v5spositiontaking_3 END,
    @isauto_v5spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_20 ELSE @isauto_v5spositiontaking_20 END,
    @isauto_v5spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_9999 ELSE @isauto_v5spositiontaking_9999 END,

	@v5mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_1 ELSE @v5mpositiontaking_1 END,
    @v5mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_2 ELSE @v5mpositiontaking_2 END,
    @v5mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_3 ELSE @v5mpositiontaking_3 END,
    @v5mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_20 ELSE @v5mpositiontaking_20 END,
    @v5mpositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_9999 ELSE @v5mpositiontaking_9999 END,

    @v8spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8spositiontaking_1 ELSE @v8spositiontaking_1 END,
    @v8spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8spositiontaking_3 ELSE @v8spositiontaking_3 END,
    @v8spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8spositiontaking_20 ELSE @v8spositiontaking_20 END,
    
	@auto_v8spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_1 ELSE @auto_v8spositiontaking_1 END,
    @auto_v8spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_3 ELSE @auto_v8spositiontaking_3 END,
    @auto_v8spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_20 ELSE @auto_v8spositiontaking_20 END,

	@isauto_v8spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_1 ELSE @auto_v8spositiontaking_1 END,
    @isauto_v8spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_3 ELSE @auto_v8spositiontaking_3 END,
    @isauto_v8spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_20 ELSE @auto_v8spositiontaking_20 END,

	@v8mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_1 ELSE @v8mpositiontaking_1 END,
    @v8mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_3 ELSE @v8mpositiontaking_3 END,
    @v8mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_20 ELSE @v8mpositiontaking_20 END,

    @v10spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10spositiontaking_1 ELSE @v10spositiontaking_1 END,
    @v10spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10spositiontaking_2 ELSE @v10spositiontaking_2 END,
    @v10spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10spositiontaking_3 ELSE @v10spositiontaking_3 END,
    @v10spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10spositiontaking_20 ELSE @v10spositiontaking_20 END,
    
	@auto_v10spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10spositiontaking_1 ELSE @auto_v10spositiontaking_1 END,
    @auto_v10spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10spositiontaking_2 ELSE @auto_v10spositiontaking_2 END,
    @auto_v10spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10spositiontaking_3 ELSE @auto_v10spositiontaking_3 END,
    @auto_v10spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10spositiontaking_20 ELSE @auto_v10spositiontaking_20 END,

	@isauto_v10spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10spositiontaking_1 ELSE @isauto_v10spositiontaking_1 END,
    @isauto_v10spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10spositiontaking_2 ELSE @isauto_v10spositiontaking_2 END,
    @isauto_v10spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10spositiontaking_3 ELSE @isauto_v10spositiontaking_3 END,
    @isauto_v10spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10spositiontaking_20 ELSE @isauto_v10spositiontaking_20 END,

	@v10mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_1 ELSE @v10mpositiontaking_1 END,
    @v10mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_2 ELSE @v10mpositiontaking_2 END,
    @v10mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_3 ELSE @v10mpositiontaking_3 END,
    @v10mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_20 ELSE @v10mpositiontaking_20 END,

    @v11spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11spositiontaking_1 ELSE @v11spositiontaking_1 END,
    @v11spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11spositiontaking_20 ELSE @v11spositiontaking_20 END,
    
	@auto_v11spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11spositiontaking_1 ELSE @auto_v11spositiontaking_1 END,
    @auto_v11spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11spositiontaking_20 ELSE @auto_v11spositiontaking_20 END,

	@isauto_v11spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11spositiontaking_1 ELSE @isauto_v11spositiontaking_1 END,
    @isauto_v11spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11spositiontaking_20 ELSE @isauto_v11spositiontaking_20 END,

	@v11mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11mpositiontaking_1 ELSE @v11mpositiontaking_1 END,
    @v11mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11mpositiontaking_20 ELSE @v11mpositiontaking_20 END,

    @v99spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99spositiontaking_1 ELSE @v99spositiontaking_1 END,
    @v99spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99spositiontaking_2 ELSE @v99spositiontaking_2 END,
    @v99spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99spositiontaking_3 ELSE @v99spositiontaking_3 END,
    @v99spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99spositiontaking_20 ELSE @v99spositiontaking_20 END,

	@auto_v99spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99spositiontaking_1 ELSE @auto_v99spositiontaking_1 END,
    @auto_v99spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99spositiontaking_2 ELSE @auto_v99spositiontaking_2 END,
    @auto_v99spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99spositiontaking_3 ELSE @auto_v99spositiontaking_3 END,
    @auto_v99spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99spositiontaking_20 ELSE @auto_v99spositiontaking_20 END,

	@isauto_v99spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99spositiontaking_1 ELSE @isauto_v99spositiontaking_1 END,
    @isauto_v99spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99spositiontaking_2 ELSE @isauto_v99spositiontaking_2 END,
    @isauto_v99spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99spositiontaking_3 ELSE @isauto_v99spositiontaking_3 END,
    @isauto_v99spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99spositiontaking_20 ELSE @isauto_v99spositiontaking_20 END,

	@v99mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_1 ELSE @v99mpositiontaking_1 END,
    @v99mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_2 ELSE @v99mpositiontaking_2 END,
    @v99mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_3 ELSE @v99mpositiontaking_3 END,
    @v99mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_20 ELSE @v99mpositiontaking_20 END,

    -- mixed sports
    @v99spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_v99spositiontaking_9 ELSE @v99spositiontaking_9 END,    
	@auto_v99spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_auto_v99spositiontaking_9 ELSE @auto_v99spositiontaking_9 END,
	@isauto_v99spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_isauto_v99spositiontaking_9 ELSE @isauto_v99spositiontaking_9 END,
	@v99mpositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_v99mpositiontaking_9 ELSE @v99mpositiontaking_9 END,

    --HR Fixed Odds
    @v154spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_v154spositiontaking_20 ELSE @v154spositiontaking_20 END,    
    @auto_v154spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_auto_v154spositiontaking_20 ELSE @auto_v154spositiontaking_20 END,    
	@isauto_v154spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_isauto_v154spositiontaking_20 ELSE @isauto_v154spositiontaking_20 END,    
	@v154mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_v154mpositiontaking_20 ELSE @v154mpositiontaking_20 END,    

    -- number game
    @v161spositiontaking_81 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161spositiontaking_81 ELSE @v161spositiontaking_81 END,    
    @v161spositiontaking_83 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161spositiontaking_83 ELSE @v161spositiontaking_83 END,    
    @v161spositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161spositiontaking_86 ELSE @v161spositiontaking_86 END,    
    @v161spositiontaking_88 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161spositiontaking_88 ELSE @v161spositiontaking_88 END,    
    @v161slivepositiontaking_85 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161slivepositiontaking_85 ELSE @v161slivepositiontaking_85 END,    
    @v161slivepositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161slivepositiontaking_86 ELSE @v161slivepositiontaking_86 END,    
    @v161slivepositiontaking_87 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161slivepositiontaking_87 ELSE @v161slivepositiontaking_87 END,    
    @v161slivepositiontaking_89 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161slivepositiontaking_89 ELSE @v161slivepositiontaking_89 END,    
    @v161slivepositiontaking_90 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161slivepositiontaking_90 ELSE @v161slivepositiontaking_90 END,    
    
    @auto_v161spositiontaking_81 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161spositiontaking_81 ELSE @auto_v161spositiontaking_81 END,    
    @auto_v161spositiontaking_83 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161spositiontaking_83 ELSE @auto_v161spositiontaking_83 END,    
    @auto_v161spositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161spositiontaking_86 ELSE @auto_v161spositiontaking_86 END,    
    @auto_v161spositiontaking_88 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161spositiontaking_88 ELSE @auto_v161spositiontaking_88 END,    
    @auto_v161slivepositiontaking_85 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161slivepositiontaking_85 ELSE @auto_v161slivepositiontaking_85 END,    
    @auto_v161slivepositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161slivepositiontaking_86 ELSE @auto_v161slivepositiontaking_86 END,    
    @auto_v161slivepositiontaking_87 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161slivepositiontaking_87 ELSE @auto_v161slivepositiontaking_87 END,    
    @auto_v161slivepositiontaking_89 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161slivepositiontaking_89 ELSE @auto_v161slivepositiontaking_89 END,    
    @auto_v161slivepositiontaking_90 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_auto_v161slivepositiontaking_90 ELSE @auto_v161slivepositiontaking_90 END,    
    
    @isauto_v161spositiontaking_81 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161spositiontaking_81 ELSE @isauto_v161spositiontaking_81 END,    
    @isauto_v161spositiontaking_83 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161spositiontaking_83 ELSE @isauto_v161spositiontaking_83 END,    
    @isauto_v161spositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161spositiontaking_86 ELSE @isauto_v161spositiontaking_86 END,    
    @isauto_v161spositiontaking_88 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161spositiontaking_88 ELSE @isauto_v161spositiontaking_88 END,    
    @isauto_v161slivepositiontaking_85 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161slivepositiontaking_85 ELSE @isauto_v161slivepositiontaking_85 END,    
    @isauto_v161slivepositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161slivepositiontaking_86 ELSE @isauto_v161slivepositiontaking_86 END,
    @isauto_v161slivepositiontaking_87 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161slivepositiontaking_87 ELSE @isauto_v161slivepositiontaking_87 END,
    @isauto_v161slivepositiontaking_89 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161slivepositiontaking_89 ELSE @isauto_v161slivepositiontaking_89 END,
    @isauto_v161slivepositiontaking_90 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161slivepositiontaking_90 ELSE @isauto_v161slivepositiontaking_90 END,
    
    @v161mpositiontaking_81 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mpositiontaking_81 ELSE @v161mpositiontaking_81 END,
    @v161mpositiontaking_83 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mpositiontaking_83 ELSE @v161mpositiontaking_83 END,
    @v161mpositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mpositiontaking_86 ELSE @v161mpositiontaking_86 END,
    @v161mpositiontaking_88 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mpositiontaking_88 ELSE @v161mpositiontaking_88 END,
    @v161mlivepositiontaking_85 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mlivepositiontaking_85 ELSE @v161mlivepositiontaking_85 END,
    @v161mlivepositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mlivepositiontaking_86 ELSE @v161mlivepositiontaking_86 END,
    @v161mlivepositiontaking_87 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mlivepositiontaking_87 ELSE @v161mlivepositiontaking_87 END,
    @v161mlivepositiontaking_89 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mlivepositiontaking_89 ELSE @v161mlivepositiontaking_89 END,
    @v161mlivepositiontaking_90 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_v161mlivepositiontaking_90 ELSE @v161mlivepositiontaking_90 END
------------------------------------------


Select @LogSPData = '<Acc_CustomerUpdMaster_PositionTaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s spt_1="'+ coalesce(cast(@spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'spt_6="'+ coalesce(cast(@spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@spositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'v2spt_10="'+ coalesce(cast(@v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3spt_10="'+ coalesce(cast(@v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5spt_10="'+ coalesce(cast(@v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8spt_10="'+ coalesce(cast(@v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10spt_10="'+ coalesce(cast(@v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11spt_10="'+ coalesce(cast(@v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99spt_10="'+ coalesce(cast(@v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +

'spt_9999="'+ coalesce(cast(@spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--v2
'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v3
'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v5
'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5spt_9999="'+ coalesce(cast(@v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

--v8
'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v10
'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v11
'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v99
'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- mixed sports
'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'v154spt_20="'+ coalesce(cast(@v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--number game
'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'a_v2spt_10="'+ coalesce(cast(@auto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v3spt_10="'+ coalesce(cast(@auto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v5spt_10="'+ coalesce(cast(@auto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v8spt_10="'+ coalesce(cast(@auto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v10spt_10="'+ coalesce(cast(@auto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v11spt_10="'+ coalesce(cast(@auto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v99spt_10="'+ coalesce(cast(@auto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +

'a_spt_9999="'+ coalesce(cast(@auto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'a_v5spt_9999="'+ coalesce(cast(@auto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
-- mixed sports
'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'a_v154spt_20="'+ coalesce(cast(@auto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- number game
'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'isa_v2spt_10="'+ coalesce(cast(@isauto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_10="'+ coalesce(cast(@isauto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_10="'+ coalesce(cast(@isauto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_10="'+ coalesce(cast(@isauto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_10="'+ coalesce(cast(@isauto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v11spt_10="'+ coalesce(cast(@isauto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_10="'+ coalesce(cast(@isauto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +

'isa_spt_9999="'+ coalesce(cast(@isauto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'isa_v2spt_1="'+ coalesce(cast(@isauto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_2="'+ coalesce(cast(@isauto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_3="'+ coalesce(cast(@isauto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_7="'+ coalesce(cast(@isauto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_8="'+ coalesce(cast(@isauto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'isa_v2spt_9="'+ coalesce(cast(@isauto_v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_20="'+ coalesce(cast(@isauto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v3spt_1="'+ coalesce(cast(@isauto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_2="'+ coalesce(cast(@isauto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_3="'+ coalesce(cast(@isauto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_20="'+ coalesce(cast(@isauto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v5spt_1="'+ coalesce(cast(@isauto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_2="'+ coalesce(cast(@isauto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_3="'+ coalesce(cast(@isauto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_20="'+ coalesce(cast(@isauto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_9999="'+ coalesce(cast(@isauto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v10spt_1="'+ coalesce(cast(@isauto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_2="'+ coalesce(cast(@isauto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_3="'+ coalesce(cast(@isauto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_20="'+ coalesce(cast(@isauto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v11spt_1="'+ coalesce(cast(@isauto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v11spt_20="'+ coalesce(cast(@isauto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v99spt_1="'+ coalesce(cast(@isauto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_2="'+ coalesce(cast(@isauto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_3="'+ coalesce(cast(@isauto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_20="'+ coalesce(cast(@isauto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
---mixed sports
'isa_v99spt_9="'+ coalesce(cast(@isauto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'isa_v154spt_20="'+ coalesce(cast(@isauto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
--- number game
'isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'v2mpt_10="'+ coalesce(cast(@v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3mpt_10="'+ coalesce(cast(@v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5mpt_10="'+ coalesce(cast(@v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8mpt_10="'+ coalesce(cast(@v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10mpt_10="'+ coalesce(cast(@v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11mpt_10="'+ coalesce(cast(@v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99mpt_10="'+ coalesce(cast(@v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'mpt_9999="'+ coalesce(cast(@mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2mpt_1="'+ coalesce(cast(@v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2mpt_2="'+ coalesce(cast(@v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2mpt_3="'+ coalesce(cast(@v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2mpt_7="'+ coalesce(cast(@v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2mpt_8="'+ coalesce(cast(@v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2mpt_20="'+ coalesce(cast(@v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3mpt_1="'+ coalesce(cast(@v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3mpt_2="'+ coalesce(cast(@v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3mpt_3="'+ coalesce(cast(@v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3mpt_20="'+ coalesce(cast(@v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5mpt_1="'+ coalesce(cast(@v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5mpt_2="'+ coalesce(cast(@v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5mpt_3="'+ coalesce(cast(@v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5mpt_20="'+ coalesce(cast(@v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5mpt_9999="'+ coalesce(cast(@v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10mpt_1="'+ coalesce(cast(@v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10mpt_2="'+ coalesce(cast(@v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10mpt_3="'+ coalesce(cast(@v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10mpt_20="'+ coalesce(cast(@v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11mpt_1="'+ coalesce(cast(@v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11mpt_20="'+ coalesce(cast(@v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99mpt_1="'+ coalesce(cast(@v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99mpt_2="'+ coalesce(cast(@v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99mpt_3="'+ coalesce(cast(@v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
--mixed sports
'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'v154mpt_20="'+ coalesce(cast(@v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- number game
'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMaster_PositionTaking>' 


Select @TrackingValue2 = '<Acc_CustomerUpdMaster_PositionTaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'v2spt_10="'+ coalesce(cast(@Old_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3spt_10="'+ coalesce(cast(@Old_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5spt_10="'+ coalesce(cast(@Old_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8spt_10="'+ coalesce(cast(@Old_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10spt_10="'+ coalesce(cast(@Old_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11spt_10="'+ coalesce(cast(@Old_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99spt_10="'+ coalesce(cast(@Old_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +

'spt_9999="'+ coalesce(cast(@Old_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--v2
'v2spt_1="'+ coalesce(cast(@Old_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2spt_2="'+ coalesce(cast(@Old_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2spt_3="'+ coalesce(cast(@Old_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2spt_7="'+ coalesce(cast(@Old_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2spt_8="'+ coalesce(cast(@Old_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'v2spt_20="'+ coalesce(cast(@Old_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v3
'v3spt_1="'+ coalesce(cast(@Old_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3spt_2="'+ coalesce(cast(@Old_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3spt_3="'+ coalesce(cast(@Old_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3spt_20="'+ coalesce(cast(@Old_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v5
'v5spt_1="'+ coalesce(cast(@Old_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5spt_2="'+ coalesce(cast(@Old_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5spt_3="'+ coalesce(cast(@Old_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5spt_20="'+ coalesce(cast(@Old_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5spt_9999="'+ coalesce(cast(@Old_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

--v8
'v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v10
'v10spt_1="'+ coalesce(cast(@Old_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10spt_2="'+ coalesce(cast(@Old_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10spt_3="'+ coalesce(cast(@Old_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10spt_20="'+ coalesce(cast(@Old_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v11
'v11spt_1="'+ coalesce(cast(@Old_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11spt_20="'+ coalesce(cast(@Old_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

--v99
'v99spt_1="'+ coalesce(cast(@Old_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99spt_2="'+ coalesce(cast(@Old_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99spt_3="'+ coalesce(cast(@Old_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99spt_20="'+ coalesce(cast(@Old_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- mixed sports
'v99spt_9="'+ coalesce(cast(@Old_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'v154spt_20="'+ coalesce(cast(@Old_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
--number game
'v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'a_v2spt_10="'+ coalesce(cast(@Old_auto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v3spt_10="'+ coalesce(cast(@Old_auto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v5spt_10="'+ coalesce(cast(@Old_auto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v8spt_10="'+ coalesce(cast(@Old_auto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v10spt_10="'+ coalesce(cast(@Old_auto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v11spt_10="'+ coalesce(cast(@Old_auto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v99spt_10="'+ coalesce(cast(@Old_auto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +

'a_spt_9999="'+ coalesce(cast(@Old_auto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'a_v2spt_1="'+ coalesce(cast(@Old_auto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v2spt_2="'+ coalesce(cast(@Old_auto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v2spt_3="'+ coalesce(cast(@Old_auto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v2spt_7="'+ coalesce(cast(@Old_auto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_v2spt_8="'+ coalesce(cast(@Old_auto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_v2spt_20="'+ coalesce(cast(@Old_auto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v3spt_1="'+ coalesce(cast(@Old_auto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v3spt_2="'+ coalesce(cast(@Old_auto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v3spt_3="'+ coalesce(cast(@Old_auto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v3spt_20="'+ coalesce(cast(@Old_auto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v5spt_1="'+ coalesce(cast(@Old_auto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v5spt_2="'+ coalesce(cast(@Old_auto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v5spt_3="'+ coalesce(cast(@Old_auto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v5spt_20="'+ coalesce(cast(@Old_auto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'a_v5spt_9999="'+ coalesce(cast(@Old_auto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v10spt_1="'+ coalesce(cast(@Old_auto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v10spt_2="'+ coalesce(cast(@Old_auto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v10spt_3="'+ coalesce(cast(@Old_auto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v10spt_20="'+ coalesce(cast(@Old_auto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v11spt_1="'+ coalesce(cast(@Old_auto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v11spt_20="'+ coalesce(cast(@Old_auto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'a_v99spt_1="'+ coalesce(cast(@Old_auto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v99spt_2="'+ coalesce(cast(@Old_auto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v99spt_3="'+ coalesce(cast(@Old_auto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v99spt_20="'+ coalesce(cast(@Old_auto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
-- mixed sports
'a_v99spt_9="'+ coalesce(cast(@Old_auto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'a_v154spt_20="'+ coalesce(cast(@Old_auto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- number game
'a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'isa_v2spt_10="'+ coalesce(cast(@Old_isauto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_10="'+ coalesce(cast(@Old_isauto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_10="'+ coalesce(cast(@Old_isauto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_10="'+ coalesce(cast(@Old_isauto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_10="'+ coalesce(cast(@Old_isauto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v11spt_10="'+ coalesce(cast(@Old_isauto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_10="'+ coalesce(cast(@Old_isauto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +

'isa_spt_9999="'+ coalesce(cast(@Old_isauto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'isa_v2spt_1="'+ coalesce(cast(@Old_isauto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_2="'+ coalesce(cast(@Old_isauto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_3="'+ coalesce(cast(@Old_isauto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_7="'+ coalesce(cast(@Old_isauto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_8="'+ coalesce(cast(@Old_isauto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_v2spt_20="'+ coalesce(cast(@Old_isauto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v3spt_1="'+ coalesce(cast(@Old_isauto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_2="'+ coalesce(cast(@Old_isauto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_3="'+ coalesce(cast(@Old_isauto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v3spt_20="'+ coalesce(cast(@Old_isauto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v5spt_1="'+ coalesce(cast(@Old_isauto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_2="'+ coalesce(cast(@Old_isauto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_3="'+ coalesce(cast(@Old_isauto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_20="'+ coalesce(cast(@Old_isauto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
'isa_v5spt_9999="'+ coalesce(cast(@Old_isauto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v10spt_1="'+ coalesce(cast(@Old_isauto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_2="'+ coalesce(cast(@Old_isauto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_3="'+ coalesce(cast(@Old_isauto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v10spt_20="'+ coalesce(cast(@Old_isauto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v11spt_1="'+ coalesce(cast(@Old_isauto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v11spt_20="'+ coalesce(cast(@Old_isauto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'isa_v99spt_1="'+ coalesce(cast(@Old_isauto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_2="'+ coalesce(cast(@Old_isauto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_3="'+ coalesce(cast(@Old_isauto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v99spt_20="'+ coalesce(cast(@Old_isauto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
---mixed sports
'isa_v99spt_9="'+ coalesce(cast(@Old_isauto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'isa_v154spt_20="'+ coalesce(cast(@Old_isauto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
--- number game
'isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@Old_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@Old_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@Old_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@Old_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@Old_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@Old_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@Old_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@Old_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@Old_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@Old_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'v2mpt_10="'+ coalesce(cast(@Old_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3mpt_10="'+ coalesce(cast(@Old_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5mpt_10="'+ coalesce(cast(@Old_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8mpt_10="'+ coalesce(cast(@Old_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10mpt_10="'+ coalesce(cast(@Old_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11mpt_10="'+ coalesce(cast(@Old_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99mpt_10="'+ coalesce(cast(@Old_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'mpt_9999="'+ coalesce(cast(@Old_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@Old_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@Old_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@Old_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@Old_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2mpt_1="'+ coalesce(cast(@Old_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2mpt_2="'+ coalesce(cast(@Old_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2mpt_3="'+ coalesce(cast(@Old_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2mpt_7="'+ coalesce(cast(@Old_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2mpt_8="'+ coalesce(cast(@Old_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'v2mpt_20="'+ coalesce(cast(@Old_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3mpt_1="'+ coalesce(cast(@Old_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3mpt_2="'+ coalesce(cast(@Old_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3mpt_3="'+ coalesce(cast(@Old_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3mpt_20="'+ coalesce(cast(@Old_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5mpt_1="'+ coalesce(cast(@Old_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5mpt_2="'+ coalesce(cast(@Old_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5mpt_3="'+ coalesce(cast(@Old_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5mpt_20="'+ coalesce(cast(@Old_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5mpt_9999="'+ coalesce(cast(@Old_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8mpt_1="'+ coalesce(cast(@Old_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@Old_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@Old_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10mpt_1="'+ coalesce(cast(@Old_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10mpt_2="'+ coalesce(cast(@Old_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10mpt_3="'+ coalesce(cast(@Old_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10mpt_20="'+ coalesce(cast(@Old_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11mpt_1="'+ coalesce(cast(@Old_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11mpt_20="'+ coalesce(cast(@Old_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99mpt_1="'+ coalesce(cast(@Old_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99mpt_2="'+ coalesce(cast(@Old_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99mpt_3="'+ coalesce(cast(@Old_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99mpt_20="'+ coalesce(cast(@Old_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
--mixed sports
'v99mpt_9="'+ coalesce(cast(@Old_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
--v154
'v154mpt_20="'+ coalesce(cast(@Old_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- number game
'v161mpt_81="'+ coalesce(cast(@Old_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@Old_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@Old_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@Old_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@Old_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@Old_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@Old_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@Old_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@Old_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMaster_PositionTaking>' 

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
    --Log positiontaking
    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 411,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValue2,
        @duration = @duration
END TRY
BEGIN CATCH
    Select @LogSPData = '<Acc_CustomerUpdMaster_PositionTaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
    'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
    'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
    'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
    'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
    'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
    'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
    'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
    'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
    'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
    'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
    'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
    'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
    'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

    '<s spt_1="'+ coalesce(cast(@spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'spt_2="'+ coalesce(cast(@spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'spt_3="'+ coalesce(cast(@spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'spt_4="'+ coalesce(cast(@spositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'spt_5="'+ coalesce(cast(@spositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'spt_6="'+ coalesce(cast(@spositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'spt_7="'+ coalesce(cast(@spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'spt_8="'+ coalesce(cast(@spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'spt_9="'+ coalesce(cast(@spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'spt_10="'+ coalesce(cast(@spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    -- Outright PT for sports
    'v2spt_10="'+ coalesce(cast(@v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v3spt_10="'+ coalesce(cast(@v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v5spt_10="'+ coalesce(cast(@v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v8spt_10="'+ coalesce(cast(@v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v10spt_10="'+ coalesce(cast(@v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v11spt_10="'+ coalesce(cast(@v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v99spt_10="'+ coalesce(cast(@v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'spt_9999="'+ coalesce(cast(@spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    --v2
    'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    --'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v3
    'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v5
    'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'v5spt_9999="'+ coalesce(cast(@v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    --v8
    'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v10
    'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v11
    'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v99
    'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    -- mixed sports
    'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'v154spt_20="'+ coalesce(cast(@v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --number game
    'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

    '<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    -- Outright PT for sports
    'a_v2spt_10="'+ coalesce(cast(@auto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_10="'+ coalesce(cast(@auto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_10="'+ coalesce(cast(@auto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v8spt_10="'+ coalesce(cast(@auto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_10="'+ coalesce(cast(@auto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v11spt_10="'+ coalesce(cast(@auto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_10="'+ coalesce(cast(@auto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'a_spt_9999="'+ coalesce(cast(@auto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    --'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_9999="'+ coalesce(cast(@auto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
    -- mixed sports
    'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'a_v154spt_20="'+ coalesce(cast(@auto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    -- number game
    'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

    '<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    -- Outright PT for sports
    'isa_v2spt_10="'+ coalesce(cast(@isauto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_10="'+ coalesce(cast(@isauto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_10="'+ coalesce(cast(@isauto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v8spt_10="'+ coalesce(cast(@isauto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_10="'+ coalesce(cast(@isauto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v11spt_10="'+ coalesce(cast(@isauto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_10="'+ coalesce(cast(@isauto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'isa_spt_9999="'+ coalesce(cast(@isauto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    'isa_v2spt_1="'+ coalesce(cast(@isauto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_2="'+ coalesce(cast(@isauto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_3="'+ coalesce(cast(@isauto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_7="'+ coalesce(cast(@isauto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_8="'+ coalesce(cast(@isauto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    --'isa_v2spt_9="'+ coalesce(cast(@isauto_v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_20="'+ coalesce(cast(@isauto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v3spt_1="'+ coalesce(cast(@isauto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_2="'+ coalesce(cast(@isauto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_3="'+ coalesce(cast(@isauto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_20="'+ coalesce(cast(@isauto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v5spt_1="'+ coalesce(cast(@isauto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_2="'+ coalesce(cast(@isauto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_3="'+ coalesce(cast(@isauto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_20="'+ coalesce(cast(@isauto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_9999="'+ coalesce(cast(@isauto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    'isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v10spt_1="'+ coalesce(cast(@isauto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_2="'+ coalesce(cast(@isauto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_3="'+ coalesce(cast(@isauto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_20="'+ coalesce(cast(@isauto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v11spt_1="'+ coalesce(cast(@isauto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v11spt_20="'+ coalesce(cast(@isauto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v99spt_1="'+ coalesce(cast(@isauto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_2="'+ coalesce(cast(@isauto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_3="'+ coalesce(cast(@isauto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_20="'+ coalesce(cast(@isauto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
    ---mixed sports
    'isa_v99spt_9="'+ coalesce(cast(@isauto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'isa_v154spt_20="'+ coalesce(cast(@isauto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    --- number game
    'isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

    '<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    -- Outright PT for sports
    'v2mpt_10="'+ coalesce(cast(@v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v3mpt_10="'+ coalesce(cast(@v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v5mpt_10="'+ coalesce(cast(@v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v8mpt_10="'+ coalesce(cast(@v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v10mpt_10="'+ coalesce(cast(@v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v11mpt_10="'+ coalesce(cast(@v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v99mpt_10="'+ coalesce(cast(@v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'mpt_9999="'+ coalesce(cast(@mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    'v2mpt_1="'+ coalesce(cast(@v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v2mpt_2="'+ coalesce(cast(@v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v2mpt_3="'+ coalesce(cast(@v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v2mpt_7="'+ coalesce(cast(@v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'v2mpt_8="'+ coalesce(cast(@v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
    --'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'v2mpt_20="'+ coalesce(cast(@v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v3mpt_1="'+ coalesce(cast(@v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v3mpt_2="'+ coalesce(cast(@v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v3mpt_3="'+ coalesce(cast(@v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v3mpt_20="'+ coalesce(cast(@v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v5mpt_1="'+ coalesce(cast(@v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v5mpt_2="'+ coalesce(cast(@v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v5mpt_3="'+ coalesce(cast(@v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v5mpt_20="'+ coalesce(cast(@v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'v5mpt_9999="'+ coalesce(cast(@v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    'v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v10mpt_1="'+ coalesce(cast(@v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v10mpt_2="'+ coalesce(cast(@v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v10mpt_3="'+ coalesce(cast(@v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v10mpt_20="'+ coalesce(cast(@v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v11mpt_1="'+ coalesce(cast(@v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v11mpt_20="'+ coalesce(cast(@v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v99mpt_1="'+ coalesce(cast(@v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v99mpt_2="'+ coalesce(cast(@v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v99mpt_3="'+ coalesce(cast(@v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
    --mixed sports
    'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'v154mpt_20="'+ coalesce(cast(@v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
    -- number game
    'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMaster_PositionTaking>' 


    Select @TrackingValue2 = '<Acc_CustomerUpdMaster_PositionTaking><info Updallmembers="'+ coalesce(cast(@updateallmembers as varchar(50)),space(1)) + '" ' +
    'newspt="'+ coalesce(cast(@newspositiontaking as varchar(50)),space(1)) + '" ' +
    'UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
    'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
    'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
    'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
    'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
    'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
    'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
    'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
    'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
    'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
    'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
    'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

    '<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    -- Outright PT for sports
    'v2spt_10="'+ coalesce(cast(@Old_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v3spt_10="'+ coalesce(cast(@Old_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v5spt_10="'+ coalesce(cast(@Old_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v8spt_10="'+ coalesce(cast(@Old_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v10spt_10="'+ coalesce(cast(@Old_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v11spt_10="'+ coalesce(cast(@Old_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v99spt_10="'+ coalesce(cast(@Old_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'spt_9999="'+ coalesce(cast(@Old_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    --v2
    'v2spt_1="'+ coalesce(cast(@Old_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v2spt_2="'+ coalesce(cast(@Old_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v2spt_3="'+ coalesce(cast(@Old_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v2spt_7="'+ coalesce(cast(@Old_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'v2spt_8="'+ coalesce(cast(@Old_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'v2spt_20="'+ coalesce(cast(@Old_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v3
    'v3spt_1="'+ coalesce(cast(@Old_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v3spt_2="'+ coalesce(cast(@Old_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v3spt_3="'+ coalesce(cast(@Old_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v3spt_20="'+ coalesce(cast(@Old_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v5
    'v5spt_1="'+ coalesce(cast(@Old_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v5spt_2="'+ coalesce(cast(@Old_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v5spt_3="'+ coalesce(cast(@Old_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v5spt_20="'+ coalesce(cast(@Old_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'v5spt_9999="'+ coalesce(cast(@Old_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    --v8
    'v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v10
    'v10spt_1="'+ coalesce(cast(@Old_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v10spt_2="'+ coalesce(cast(@Old_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v10spt_3="'+ coalesce(cast(@Old_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v10spt_20="'+ coalesce(cast(@Old_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v11
    'v11spt_1="'+ coalesce(cast(@Old_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v11spt_20="'+ coalesce(cast(@Old_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    --v99
    'v99spt_1="'+ coalesce(cast(@Old_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v99spt_2="'+ coalesce(cast(@Old_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v99spt_3="'+ coalesce(cast(@Old_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v99spt_20="'+ coalesce(cast(@Old_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    -- mixed sports
    'v99spt_9="'+ coalesce(cast(@Old_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'v154spt_20="'+ coalesce(cast(@Old_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    --number game
    'v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

    '<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    -- Outright PT for sports
    
    'a_v2spt_10="'+ coalesce(cast(@Old_auto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_10="'+ coalesce(cast(@Old_auto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_10="'+ coalesce(cast(@Old_auto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v8spt_10="'+ coalesce(cast(@Old_auto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_10="'+ coalesce(cast(@Old_auto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v11spt_10="'+ coalesce(cast(@Old_auto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_10="'+ coalesce(cast(@Old_auto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'a_spt_9999="'+ coalesce(cast(@Old_auto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    'a_v2spt_1="'+ coalesce(cast(@Old_auto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_2="'+ coalesce(cast(@Old_auto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_3="'+ coalesce(cast(@Old_auto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_7="'+ coalesce(cast(@Old_auto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_8="'+ coalesce(cast(@Old_auto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'a_v2spt_20="'+ coalesce(cast(@Old_auto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v3spt_1="'+ coalesce(cast(@Old_auto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_2="'+ coalesce(cast(@Old_auto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_3="'+ coalesce(cast(@Old_auto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v3spt_20="'+ coalesce(cast(@Old_auto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v5spt_1="'+ coalesce(cast(@Old_auto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_2="'+ coalesce(cast(@Old_auto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_3="'+ coalesce(cast(@Old_auto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_20="'+ coalesce(cast(@Old_auto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'a_v5spt_9999="'+ coalesce(cast(@Old_auto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    'a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v10spt_1="'+ coalesce(cast(@Old_auto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_2="'+ coalesce(cast(@Old_auto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_3="'+ coalesce(cast(@Old_auto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v10spt_20="'+ coalesce(cast(@Old_auto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v11spt_1="'+ coalesce(cast(@Old_auto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v11spt_20="'+ coalesce(cast(@Old_auto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'a_v99spt_1="'+ coalesce(cast(@Old_auto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_2="'+ coalesce(cast(@Old_auto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_3="'+ coalesce(cast(@Old_auto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'a_v99spt_20="'+ coalesce(cast(@Old_auto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
    -- mixed sports
    'a_v99spt_9="'+ coalesce(cast(@Old_auto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'a_v154spt_20="'+ coalesce(cast(@Old_auto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    -- number game
    'a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

    '<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    -- Outright PT for sports
    'isa_v2spt_10="'+ coalesce(cast(@Old_isauto_v2spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_10="'+ coalesce(cast(@Old_isauto_v3spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_10="'+ coalesce(cast(@Old_isauto_v5spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v8spt_10="'+ coalesce(cast(@Old_isauto_v8spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_10="'+ coalesce(cast(@Old_isauto_v10spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v11spt_10="'+ coalesce(cast(@Old_isauto_v11spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_10="'+ coalesce(cast(@Old_isauto_v99spositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'isa_spt_9999="'+ coalesce(cast(@Old_isauto_spositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    'isa_v2spt_1="'+ coalesce(cast(@Old_isauto_v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_2="'+ coalesce(cast(@Old_isauto_v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_3="'+ coalesce(cast(@Old_isauto_v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_7="'+ coalesce(cast(@Old_isauto_v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_8="'+ coalesce(cast(@Old_isauto_v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'isa_v2spt_20="'+ coalesce(cast(@Old_isauto_v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v3spt_1="'+ coalesce(cast(@Old_isauto_v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_2="'+ coalesce(cast(@Old_isauto_v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_3="'+ coalesce(cast(@Old_isauto_v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v3spt_20="'+ coalesce(cast(@Old_isauto_v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v5spt_1="'+ coalesce(cast(@Old_isauto_v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_2="'+ coalesce(cast(@Old_isauto_v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_3="'+ coalesce(cast(@Old_isauto_v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_20="'+ coalesce(cast(@Old_isauto_v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'isa_v5spt_9999="'+ coalesce(cast(@Old_isauto_v5spositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    'isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v10spt_1="'+ coalesce(cast(@Old_isauto_v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_2="'+ coalesce(cast(@Old_isauto_v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_3="'+ coalesce(cast(@Old_isauto_v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v10spt_20="'+ coalesce(cast(@Old_isauto_v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v11spt_1="'+ coalesce(cast(@Old_isauto_v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v11spt_20="'+ coalesce(cast(@Old_isauto_v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'isa_v99spt_1="'+ coalesce(cast(@Old_isauto_v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_2="'+ coalesce(cast(@Old_isauto_v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_3="'+ coalesce(cast(@Old_isauto_v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'isa_v99spt_20="'+ coalesce(cast(@Old_isauto_v99spositiontaking_20 as varchar(50)),space(1)) + '" ' + 
    ---mixed sports
    'isa_v99spt_9="'+ coalesce(cast(@Old_isauto_v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'isa_v154spt_20="'+ coalesce(cast(@Old_isauto_v154spositiontaking_20 as varchar(50)),space(1)) + '" ' +
    --- number game
    'isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

    '<m mpt_1="'+ coalesce(cast(@Old_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'mpt_2="'+ coalesce(cast(@Old_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'mpt_3="'+ coalesce(cast(@Old_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'mpt_4="'+ coalesce(cast(@Old_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
    'mpt_5="'+ coalesce(cast(@Old_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
    'mpt_6="'+ coalesce(cast(@Old_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
    'mpt_7="'+ coalesce(cast(@Old_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'mpt_8="'+ coalesce(cast(@Old_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'mpt_9="'+ coalesce(cast(@Old_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
    'mpt_10="'+ coalesce(cast(@Old_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    -- Outright PT for sports
    'v2mpt_10="'+ coalesce(cast(@Old_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v3mpt_10="'+ coalesce(cast(@Old_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v5mpt_10="'+ coalesce(cast(@Old_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v8mpt_10="'+ coalesce(cast(@Old_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v10mpt_10="'+ coalesce(cast(@Old_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v11mpt_10="'+ coalesce(cast(@Old_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    'v99mpt_10="'+ coalesce(cast(@Old_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
    
    'mpt_9999="'+ coalesce(cast(@Old_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
    'mlivept_1="'+ coalesce(cast(@Old_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'mlivept_3="'+ coalesce(cast(@Old_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'mlivept_7="'+ coalesce(cast(@Old_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'mlivept_8="'+ coalesce(cast(@Old_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

    'v2mpt_1="'+ coalesce(cast(@Old_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v2mpt_2="'+ coalesce(cast(@Old_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v2mpt_3="'+ coalesce(cast(@Old_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v2mpt_7="'+ coalesce(cast(@Old_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
    'v2mpt_8="'+ coalesce(cast(@Old_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
    'v2mpt_20="'+ coalesce(cast(@Old_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v3mpt_1="'+ coalesce(cast(@Old_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v3mpt_2="'+ coalesce(cast(@Old_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v3mpt_3="'+ coalesce(cast(@Old_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v3mpt_20="'+ coalesce(cast(@Old_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v5mpt_1="'+ coalesce(cast(@Old_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v5mpt_2="'+ coalesce(cast(@Old_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v5mpt_3="'+ coalesce(cast(@Old_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v5mpt_20="'+ coalesce(cast(@Old_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
    'v5mpt_9999="'+ coalesce(cast(@Old_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

    'v8mpt_1="'+ coalesce(cast(@Old_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v8mpt_3="'+ coalesce(cast(@Old_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v8mpt_20="'+ coalesce(cast(@Old_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v10mpt_1="'+ coalesce(cast(@Old_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v10mpt_2="'+ coalesce(cast(@Old_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v10mpt_3="'+ coalesce(cast(@Old_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v10mpt_20="'+ coalesce(cast(@Old_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v11mpt_1="'+ coalesce(cast(@Old_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v11mpt_20="'+ coalesce(cast(@Old_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

    'v99mpt_1="'+ coalesce(cast(@Old_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
    'v99mpt_2="'+ coalesce(cast(@Old_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
    'v99mpt_3="'+ coalesce(cast(@Old_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
    'v99mpt_20="'+ coalesce(cast(@Old_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
    --mixed sports
    'v99mpt_9="'+ coalesce(cast(@Old_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
    --v154
    'v154mpt_20="'+ coalesce(cast(@Old_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
    -- number game
    'v161mpt_81="'+ coalesce(cast(@Old_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
    'v161mpt_83="'+ coalesce(cast(@Old_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
    'v161mpt_86="'+ coalesce(cast(@Old_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161mpt_88="'+ coalesce(cast(@Old_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_85="'+ coalesce(cast(@Old_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_86="'+ coalesce(cast(@Old_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_87="'+ coalesce(cast(@Old_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_89="'+ coalesce(cast(@Old_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
    'v161mlivept_90="'+ coalesce(cast(@Old_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMaster_PositionTaking>' 

    --Log positiontaking
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 411,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValue2,
        @duration = @duration
END CATCH

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_PositionTaking] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_PositionTaking] TO [bodbExtAccNet]
GO 
