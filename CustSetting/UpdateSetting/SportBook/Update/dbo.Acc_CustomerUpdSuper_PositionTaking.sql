/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_PositionTaking]
    @custid int,-- superid    
    
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
    @spositiontaking_9999 smallmoney = 0.9,
    
    @slivepositiontaking_1 smallmoney,
    @slivepositiontaking_3 smallmoney,
    @slivepositiontaking_7 smallmoney,
    @slivepositiontaking_8 smallmoney,
    
    @v2spositiontaking_1 smallmoney,
    @v2spositiontaking_2 smallmoney,
    @v2spositiontaking_3 smallmoney,
    @v2spositiontaking_7 smallmoney,
    @v2spositiontaking_8 smallmoney,
    --@v2spositiontaking_9 smallmoney,
    @v2spositiontaking_20 smallmoney,
    @v2spositiontaking_9999 smallmoney,

    @v3spositiontaking_1 smallmoney,
    @v3spositiontaking_2 smallmoney,
    @v3spositiontaking_3 smallmoney,
    @v3spositiontaking_20 smallmoney,

    @v5spositiontaking_1 smallmoney,
    @v5spositiontaking_2 smallmoney,
    @v5spositiontaking_3 smallmoney,
    @v5spositiontaking_20 smallmoney,
    @v5spositiontaking_9999 smallmoney = 0.9,

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
    @v99spositiontaking_9 smallmoney,
    @v99spositiontaking_20 smallmoney,
	@v99spositiontaking_9999 smallmoney,   
    
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
    --@v2mpositiontaking_9 smallmoney = 0.7,
    @v2mpositiontaking_20 smallmoney = 0.7,
    @v2mpositiontaking_9999 smallmoney = 0.7,

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
    @v11mpositiontaking_2 smallmoney = 0.7,
    @v11mpositiontaking_20 smallmoney = 0.7,

    @v99mpositiontaking_1 smallmoney = 0.7,
    @v99mpositiontaking_2 smallmoney = 0.7,
    @v99mpositiontaking_3 smallmoney = 0.7,
    @v99mpositiontaking_9 smallmoney = 0.7,
    @v99mpositiontaking_20 smallmoney = 0.7,
	@v99mpositiontaking_9999 smallmoney = 0.7,
      
    @apositiontaking_1 smallmoney = 0.7,
    @apositiontaking_2 smallmoney = 0.7,
    @apositiontaking_3 smallmoney = 0.7,
    @apositiontaking_4 smallmoney = 0.7,
    @apositiontaking_5 smallmoney = 0.7,
    @apositiontaking_6 smallmoney = 0.7,
    @apositiontaking_7 smallmoney = 0.7,
    @apositiontaking_8 smallmoney = 0.7,
    @apositiontaking_9 smallmoney = 0.7,
    @apositiontaking_10 smallmoney = 0.7,
    @apositiontaking_9999 smallmoney = 0.7,
    
    @alivepositiontaking_1 smallmoney = 0.7,
    @alivepositiontaking_3 smallmoney = 0.7,
    @alivepositiontaking_7 smallmoney = 0.7,
    @alivepositiontaking_8 smallmoney = 0.7,
    
    @v2apositiontaking_1 smallmoney = 0.7,
    @v2apositiontaking_2 smallmoney = 0.7,
    @v2apositiontaking_3 smallmoney = 0.7,
    @v2apositiontaking_7 smallmoney = 0.7,
    @v2apositiontaking_8 smallmoney = 0.7,
    --@v2apositiontaking_9 smallmoney = 0.7,
    @v2apositiontaking_20 smallmoney = 0.7,
    @v2apositiontaking_9999 smallmoney = 0.7,

    @v3apositiontaking_1 smallmoney = 0.7,
    @v3apositiontaking_2 smallmoney = 0.7,
    @v3apositiontaking_3 smallmoney = 0.7,
    @v3apositiontaking_20 smallmoney = 0.7,

    @v5apositiontaking_1 smallmoney = 0.7,
    @v5apositiontaking_2 smallmoney = 0.7,
    @v5apositiontaking_3 smallmoney = 0.7,
    @v5apositiontaking_20 smallmoney = 0.7,
    @v5apositiontaking_9999 smallmoney = 0.7,

    @v8apositiontaking_1 smallmoney = 0.7,
    @v8apositiontaking_3 smallmoney = 0.7,
    @v8apositiontaking_20 smallmoney = 0.7,

    @v10apositiontaking_1 smallmoney = 0.7,
    @v10apositiontaking_2 smallmoney = 0.7,
    @v10apositiontaking_3 smallmoney = 0.7,
    @v10apositiontaking_20 smallmoney = 0.7,

    @v11apositiontaking_1 smallmoney = 0.7,
    @v11apositiontaking_20 smallmoney = 0.7,

    @v99apositiontaking_1 smallmoney = 0.7,
    @v99apositiontaking_2 smallmoney = 0.7,
    @v99apositiontaking_3 smallmoney = 0.7,
    @v99apositiontaking_9 smallmoney = 0.7,
    @v99apositiontaking_20 smallmoney = 0.7,
	@v99apositiontaking_9999 smallmoney = 0.7,
      
    -- Provide Outright PT for Sports
    @v2spositiontaking_10 smallmoney,
	@v3spositiontaking_10 smallmoney,
	@v5spositiontaking_10 smallmoney,
	@v8spositiontaking_10 smallmoney,
	@v10spositiontaking_10 smallmoney,
	@v11spositiontaking_10 smallmoney,
	@v99spositiontaking_10 smallmoney,
	
	@v2mpositiontaking_10 smallmoney = 0.7,
	@v3mpositiontaking_10 smallmoney = 0.7,
	@v5mpositiontaking_10 smallmoney = 0.7,
	@v8mpositiontaking_10 smallmoney = 0.7,
	@v10mpositiontaking_10 smallmoney = 0.7,
	@v11mpositiontaking_10 smallmoney = 0.7,
	@v99mpositiontaking_10 smallmoney = 0.7,
	
	@v2apositiontaking_10 smallmoney = 0.7,
	@v3apositiontaking_10 smallmoney = 0.7,
	@v5apositiontaking_10 smallmoney = 0.7,
	@v8apositiontaking_10 smallmoney = 0.7,
	@v10apositiontaking_10 smallmoney = 0.7,
	@v11apositiontaking_10 smallmoney = 0.7,
	@v99apositiontaking_10 smallmoney = 0.7,
	
	
    @UserID int = 0,    
    @Language varchar(2) = 'E',
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080514@Thien
Task : Update Super's PT
DB: DBTXN/bodb02
Original: Acc_CustomerUpdEditCustomer_Com

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3 
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090715@Phuc: check m4>=m1+a1, a4>=a1
    - 20090917@Phuc: write log into DBLOG.
    - 20100112@Kiwi: amend to write log in xml format.
    - 20100901@Henry: Add Number Game + Mix Parlay Mixed Sports
    - 20101019@Henry: Record execution time
    - 20110606@Amy: Write log Old values
    - 20110728@Johnson: - remove bettype dead ball over/under of number game
                        - add more bettype for nubmer game Warrior,  Next combo and Number Group
    - 20120914@Johnson: check m4 with exsisting m3 and a4 with existing a1,a2
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20131030@Johnson: Apply exec rep for recalculating pt on member
                and check total downlines before UPDATEs
    - 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)                
    - 20140618@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
    - 20140729@Logan: 1.Exclude disabled agents, members while updating SM's setting [Redmine: #19631]
                      2.Code aligning on modified parts
    - 20150609@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, temp sport, bettype table) [Redmine:#36216]
    - 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
    - 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
    - 20170808@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]	
	- 20180326@Winnie: Customer Setting - urgent fix to support for long bettype name. [RedmineID: #91216]	
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20201028@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
    SET NOCOUNT ON

	CREATE TABLE #tmp_Sports (ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	CREATE TABLE #tmp_Bettype (ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)

    declare @startRun datetime
    declare @endRun datetime
    declare @duration int
    set @startRun = getdate()

    Declare @username varchar(40)
    select @username = username from custinfo with (NOLOCK) where custid = @custid
    --------------------------------------------------------------------------------------------

    ---- Thien@20131026: Checking total downlines before UPDATEs 
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
    ----------
	BEGIN TRY
		INSERT INTO #tmp_Sports (ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID
		FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBAGE')	
	END TRY
	BEGIN CATCH
		IF OBJECT_ID(N'tempdb..#tmp_Sports') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Sports
			INSERT INTO #tmp_Sports
			SELECT ID, Name, IsDisabled, IBCBettypeID
			FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBTXN')	
		END
	END CATCH

	BEGIN TRY			
		INSERT INTO #tmp_Bettype (ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID
		FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBAGE')	
	END TRY
	BEGIN CATCH		
		IF OBJECT_ID(N'tempdb..#tmp_Bettype') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Bettype
			INSERT INTO #tmp_Bettype
			SELECT ID, Name, IsDisabled, IBCBettypeID
			FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBTXN')	
		END
	END CATCH
	
    --Check Param
    Declare @ErrAcc nvarchar(4000)
    declare @ErrType varchar(1000)

    if 
        @spositiontaking_1  <0
        or @spositiontaking_2  <0
        or @spositiontaking_3  <0
        or @spositiontaking_4  <0
        or @spositiontaking_5  <0
        or @spositiontaking_6  <0
        or @spositiontaking_7  <0
        or @spositiontaking_8  <0
        or @spositiontaking_9  <0
        or @spositiontaking_10 <0
        or @spositiontaking_9999  <0
        
        or @slivepositiontaking_1  <0
        or @slivepositiontaking_3  <0
        or @slivepositiontaking_7  <0
        or @slivepositiontaking_8  <0
        
        or @v2spositiontaking_1  <0
        or @v2spositiontaking_2  <0
        or @v2spositiontaking_3  <0
        or @v2spositiontaking_7  <0
        or @v2spositiontaking_8  <0
        --or @v2spositiontaking_9  <0
        or @v2spositiontaking_20  <0
        or @v2spositiontaking_9999  <0
        
        or @v3spositiontaking_1  <0
        or @v3spositiontaking_2  <0
        or @v3spositiontaking_3  <0
        or @v3spositiontaking_20  <0

        or @v5spositiontaking_1  <0
        or @v5spositiontaking_2  <0
        or @v5spositiontaking_3  <0
        or @v5spositiontaking_20  <0
        or @v5spositiontaking_9999  <0

        or @v8spositiontaking_1  <0
        or @v8spositiontaking_3  <0
        or @v8spositiontaking_20  <0

        or @v10spositiontaking_1  <0
        or @v10spositiontaking_2  <0
        or @v10spositiontaking_3  <0
        or @v10spositiontaking_20  <0

        or @v11spositiontaking_1  <0
        or @v11spositiontaking_20  <0

        or @v99spositiontaking_1  <0
        or @v99spositiontaking_2  <0
        or @v99spositiontaking_3  <0
        or @v99spositiontaking_9  <0    
        or @v99spositiontaking_20  <0    
		or @v99spositiontaking_9999  <0                        
        
        or @mpositiontaking_1  <0
        or @mpositiontaking_2  <0
        or @mpositiontaking_3  <0
        or @mpositiontaking_4  <0
        or @mpositiontaking_5  <0
        or @mpositiontaking_6  <0
        or @mpositiontaking_7  <0
        or @mpositiontaking_8  <0
        or @mpositiontaking_9  <0
        or @mpositiontaking_10 <0
        or @mpositiontaking_9999  <0
        
        or @mlivepositiontaking_1  <0
        or @mlivepositiontaking_3  <0
        or @mlivepositiontaking_7  <0
        or @mlivepositiontaking_8  <0
        
        or @v2mpositiontaking_1  <0
        or @v2mpositiontaking_2  <0
        or @v2mpositiontaking_3  <0
        or @v2mpositiontaking_7  <0
        or @v2mpositiontaking_8  <0
        --or @v2mpositiontaking_9  <0
        or @v2mpositiontaking_20  <0
        or @v2mpositiontaking_9999  <0

        or @v3mpositiontaking_1  <0
        or @v3mpositiontaking_2  <0
        or @v3mpositiontaking_3  <0
        or @v3mpositiontaking_20  <0
        
        or @v5mpositiontaking_1  <0
        or @v5mpositiontaking_2  <0
        or @v5mpositiontaking_3  <0
        or @v5mpositiontaking_20  <0
        or @v5mpositiontaking_9999  <0

        or @v8mpositiontaking_1  <0
        or @v8mpositiontaking_3  <0
        or @v8mpositiontaking_20  <0

        or @v10mpositiontaking_1  <0
        or @v10mpositiontaking_2  <0
        or @v10mpositiontaking_3  <0
        or @v10mpositiontaking_20  <0

        or @v11mpositiontaking_1  <0
        or @v11mpositiontaking_20  <0

        or @v99mpositiontaking_1  <0
        or @v99mpositiontaking_2  <0
        or @v99mpositiontaking_3  <0
        or @v99mpositiontaking_9  <0
        or @v99mpositiontaking_20  <0    
		or @v99mpositiontaking_9999  <0               

        or @apositiontaking_1  <0
        or @apositiontaking_2  <0
        or @apositiontaking_3  <0
        or @apositiontaking_4  <0
        or @apositiontaking_5  <0
        or @apositiontaking_6  <0
        or @apositiontaking_7  <0
        or @apositiontaking_8  <0
        or @apositiontaking_9  <0
        or @apositiontaking_10 <0
        or @apositiontaking_9999  <0
        
        or @alivepositiontaking_1  <0
        or @alivepositiontaking_3  <0
        or @alivepositiontaking_7  <0
        or @alivepositiontaking_8  <0
        
        or @v2apositiontaking_1  <0
        or @v2apositiontaking_2  <0
        or @v2apositiontaking_3  <0
        or @v2apositiontaking_7  <0
        or @v2apositiontaking_8  <0
        --or @v2apositiontaking_9  <0
        or @v2apositiontaking_20  <0
        or @v2apositiontaking_9999  <0

        or @v3apositiontaking_1  <0
        or @v3apositiontaking_2  <0
        or @v3apositiontaking_3  <0
        or @v3apositiontaking_20  <0

        or @v5apositiontaking_1  <0
        or @v5apositiontaking_2  <0
        or @v5apositiontaking_3  <0
        or @v5apositiontaking_20  <0
        or @v5apositiontaking_9999  <0

        or @v8apositiontaking_1  <0
        or @v8apositiontaking_3  <0
        or @v8apositiontaking_20  <0

        or @v10apositiontaking_1  <0
        or @v10apositiontaking_2  <0
        or @v10apositiontaking_3  <0
        or @v10apositiontaking_20  <0

        or @v11apositiontaking_1  <0
        or @v11apositiontaking_20  <0

        or @v99apositiontaking_1  <0
        or @v99apositiontaking_2  <0
        or @v99apositiontaking_3  <0
        or @v99apositiontaking_9  <0
        or @v99apositiontaking_20  <0    
        or @v99apositiontaking_9999  <0    
            
        or @spositiontaking_1  >0.9
        or @spositiontaking_2  >0.9
        or @spositiontaking_3  >0.9
        or @spositiontaking_4  >0.9
        or @spositiontaking_5  >0.9
        or @spositiontaking_6  >0.9
        or @spositiontaking_7  >0.9
        or @spositiontaking_8  >0.9
        or @spositiontaking_9  >0.9
        or @spositiontaking_10 >0.9
        or @spositiontaking_9999  >0.9
        
        or @slivepositiontaking_1  >0.9
        or @slivepositiontaking_3  >0.9
        or @slivepositiontaking_7  >0.9
        or @slivepositiontaking_8  >0.9
        
        or @v2spositiontaking_1  >0.9
        or @v2spositiontaking_2  >0.9
        or @v2spositiontaking_3  >0.9
        or @v2spositiontaking_7  >0.9
        or @v2spositiontaking_8  >0.9
        --or @v2spositiontaking_9  >0.9
        or @v2spositiontaking_20  >0.9
        or @v2spositiontaking_9999  >0.9

        or @v3spositiontaking_1  >0.9
        or @v3spositiontaking_2  >0.9
        or @v3spositiontaking_3  >0.9
        or @v3spositiontaking_20  >0.9

        or @v5spositiontaking_1  >0.9
        or @v5spositiontaking_2  >0.9
        or @v5spositiontaking_3  >0.9
        or @v5spositiontaking_20  >0.9
        or @v5spositiontaking_9999  >0.9

        or @v8spositiontaking_1  >0.9
        or @v8spositiontaking_3  >0.9
        or @v8spositiontaking_20  >0.9

        or @v10spositiontaking_1  >0.9
        or @v10spositiontaking_2  >0.9
        or @v10spositiontaking_3  >0.9
        or @v10spositiontaking_20  >0.9

        or @v11spositiontaking_1  >0.9
        or @v11spositiontaking_20  >0.9

        or @v99spositiontaking_1  >0.9
        or @v99spositiontaking_2  >0.9
        or @v99spositiontaking_3  >0.9
        or @v99spositiontaking_9  >0.9
        or @v99spositiontaking_20  >0.9
		or @v99spositiontaking_9999  >0.9             
        
        or @mpositiontaking_1  >0.9
        or @mpositiontaking_2  >0.9
        or @mpositiontaking_3  >0.9
        or @mpositiontaking_4  >0.9
        or @mpositiontaking_5  >0.9
        or @mpositiontaking_6  >0.9
        or @mpositiontaking_7  >0.9
        or @mpositiontaking_8  >0.9
        or @mpositiontaking_9  >0.9
        or @mpositiontaking_10 >0.9
        or @mpositiontaking_9999  >0.9
        
        or @mlivepositiontaking_1  >0.9
        or @mlivepositiontaking_3  >0.9
        or @mlivepositiontaking_7  >0.9
        or @mlivepositiontaking_8  >0.9
        
        or @v2mpositiontaking_1  >0.9
        or @v2mpositiontaking_2  >0.9
        or @v2mpositiontaking_3  >0.9
        or @v2mpositiontaking_7  >0.9
        or @v2mpositiontaking_8  >0.9
        --or @v2mpositiontaking_9  >0.9
        or @v2mpositiontaking_20  >0.9
        or @v2mpositiontaking_9999  >0.9

        or @v3mpositiontaking_1  >0.9
        or @v3mpositiontaking_2  >0.9
        or @v3mpositiontaking_3  >0.9
        or @v3mpositiontaking_20  >0.9

        or @v5mpositiontaking_1  >0.9
        or @v5mpositiontaking_2  >0.9
        or @v5mpositiontaking_3  >0.9
        or @v5mpositiontaking_20  >0.9
        or @v5mpositiontaking_9999  >0.9

        or @v8mpositiontaking_1  >0.9
        or @v8mpositiontaking_3  >0.9
        or @v8mpositiontaking_20  >0.9

        or @v10mpositiontaking_1  >0.9
        or @v10mpositiontaking_2  >0.9
        or @v10mpositiontaking_3  >0.9
        or @v10mpositiontaking_20  >0.9

        or @v11mpositiontaking_1  >0.9
        or @v11mpositiontaking_20  >0.9

        or @v99mpositiontaking_1  >0.9
        or @v99mpositiontaking_2  >0.9
        or @v99mpositiontaking_3  >0.9
        or @v99mpositiontaking_9  >0.9
        or @v99mpositiontaking_20  >0.9
		or @v99mpositiontaking_9999  >0.9          

        or @apositiontaking_1  >0.9
        or @apositiontaking_2  >0.9
        or @apositiontaking_3  >0.9
        or @apositiontaking_4  >0.9
        or @apositiontaking_5  >0.9
        or @apositiontaking_6  >0.9
        or @apositiontaking_7  >0.9
        or @apositiontaking_8  >0.9
        or @apositiontaking_9  >0.9
        or @apositiontaking_10 >0.9
        or @apositiontaking_9999  >0.9
        or @alivepositiontaking_1  >0.9
        or @alivepositiontaking_3  >0.9
        or @alivepositiontaking_7  >0.9
        or @alivepositiontaking_8  >0.9
        
        or @v2apositiontaking_1  >0.9
        or @v2apositiontaking_2  >0.9
        or @v2apositiontaking_3  >0.9
        or @v2apositiontaking_7  >0.9
        or @v2apositiontaking_8  >0.9
        --or @v2apositiontaking_9  >0.9
        or @v2apositiontaking_20  >0.9
        or @v2apositiontaking_9999  >0.9

        or @v3apositiontaking_1  >0.9
        or @v3apositiontaking_2  >0.9
        or @v3apositiontaking_3  >0.9
        or @v3apositiontaking_20  >0.9

        or @v5apositiontaking_1  >0.9
        or @v5apositiontaking_2  >0.9
        or @v5apositiontaking_3  >0.9
        or @v5apositiontaking_20  >0.9
        or @v5apositiontaking_9999  >0.9

        or @v8apositiontaking_1  >0.9
        or @v8apositiontaking_3  >0.9
        or @v8apositiontaking_20  >0.9

        or @v10apositiontaking_1  >0.9
        or @v10apositiontaking_2  >0.9
        or @v10apositiontaking_3  >0.9
        or @v10apositiontaking_20  >0.9

        or @v11apositiontaking_1  >0.9
        or @v11apositiontaking_20  >0.9

        or @v99apositiontaking_1  >0.9
        or @v99apositiontaking_2  >0.9
        or @v99apositiontaking_3  >0.9
        or @v99apositiontaking_9  >0.9
        or @v99apositiontaking_20  >0.9
		or @v99apositiontaking_9999  >0.9        

        or @spositiontaking_1   <  @mpositiontaking_1  
        or @spositiontaking_2   <  @mpositiontaking_2  
        or @spositiontaking_3   <  @mpositiontaking_3  
        or @spositiontaking_4   <  @mpositiontaking_4  
        or @spositiontaking_5   <  @mpositiontaking_5  
        or @spositiontaking_6   <  @mpositiontaking_6  
        or @spositiontaking_7   <  @mpositiontaking_7  
        or @spositiontaking_8   <  @mpositiontaking_8  
        or @spositiontaking_9   <  @mpositiontaking_9  
        or @spositiontaking_10  <  @mpositiontaking_10 
        or @spositiontaking_9999   <  @mpositiontaking_9999 
        or @slivepositiontaking_1   <  @mlivepositiontaking_1  
        or @slivepositiontaking_3   <  @mlivepositiontaking_3
        or @slivepositiontaking_7   <  @mlivepositiontaking_7  
        or @slivepositiontaking_8   <  @mlivepositiontaking_8
         
        or @v2spositiontaking_1   <  @v2mpositiontaking_1 
        or @v2spositiontaking_2   <  @v2mpositiontaking_2
        or @v2spositiontaking_3   <  @v2mpositiontaking_3 
        or @v2spositiontaking_7   <  @v2mpositiontaking_7  
        or @v2spositiontaking_8   <  @v2mpositiontaking_8
        --or @v2spositiontaking_9   <  @v2mpositiontaking_9
        or @v2spositiontaking_20   <  @v2mpositiontaking_20
        or @v2spositiontaking_9999   <  @v2mpositiontaking_9999

        or @v3spositiontaking_1   <  @v3mpositiontaking_1 
        or @v3spositiontaking_2   <  @v3mpositiontaking_2
        or @v3spositiontaking_3   <  @v3mpositiontaking_3 
        or @v3spositiontaking_20   <  @v3mpositiontaking_20

        or @v5spositiontaking_1   <  @v5mpositiontaking_1 
        or @v5spositiontaking_2   <  @v5mpositiontaking_2
        or @v5spositiontaking_3   <  @v5mpositiontaking_3 
        or @v5spositiontaking_20   <  @v5mpositiontaking_20
        or @v5spositiontaking_9999   <  @v5mpositiontaking_9999

        or @v8spositiontaking_1   <  @v8mpositiontaking_1 
        or @v8spositiontaking_3   <  @v8mpositiontaking_3 
        or @v8spositiontaking_20   <  @v8mpositiontaking_20

        or @v10spositiontaking_1   <  @v10mpositiontaking_1 
        or @v10spositiontaking_2   <  @v10mpositiontaking_2
        or @v10spositiontaking_3   <  @v10mpositiontaking_3 
        or @v10spositiontaking_20   <  @v10mpositiontaking_20

        or @v11spositiontaking_1   <  @v11mpositiontaking_1 
        or @v11spositiontaking_20   <  @v11mpositiontaking_20

        or @v99spositiontaking_1   <  @v99mpositiontaking_1 
        or @v99spositiontaking_2   <  @v99mpositiontaking_2
        or @v99spositiontaking_3   <  @v99mpositiontaking_3 
        or @v99spositiontaking_9   <  @v99mpositiontaking_9
        or @v99spositiontaking_20   <  @v99mpositiontaking_20
		or @v99spositiontaking_9999   <  @v99mpositiontaking_9999         
          
        or @mpositiontaking_1    < @apositiontaking_1  
        or @mpositiontaking_2   <  @apositiontaking_2  
        or @mpositiontaking_3   <  @apositiontaking_3  
        or @mpositiontaking_4   <  @apositiontaking_4  
        or @mpositiontaking_5   <  @apositiontaking_5  
        or @mpositiontaking_6   <  @apositiontaking_6  
        or @mpositiontaking_7   <  @apositiontaking_7  
        or @mpositiontaking_8   <  @apositiontaking_8  
        or @mpositiontaking_9   <  @apositiontaking_9  
        or @mpositiontaking_10  <  @apositiontaking_10 
        or @mpositiontaking_9999   <  @apositiontaking_9999  
        or @mlivepositiontaking_1   <  @alivepositiontaking_1  
        or @mlivepositiontaking_3   <  @alivepositiontaking_3  
        or @mlivepositiontaking_7   <  @alivepositiontaking_7  
        or @mlivepositiontaking_8   <  @alivepositiontaking_8 
         
        or @v2mpositiontaking_1   <  @v2apositiontaking_1  
        or @v2mpositiontaking_2   <  @v2apositiontaking_2  
        or @v2mpositiontaking_3   <  @v2apositiontaking_3  
        or @v2mpositiontaking_7   <  @v2apositiontaking_7  
        or @v2mpositiontaking_8   <  @v2apositiontaking_8
        or @v2mpositiontaking_20   <  @v2apositiontaking_20
        or @v2mpositiontaking_9999   <  @v2apositiontaking_9999
        --or @v2mpositiontaking_9   <  @v2apositiontaking_9

        or @v3mpositiontaking_1   <  @v3apositiontaking_1  
        or @v3mpositiontaking_2   <  @v3apositiontaking_2  
        or @v3mpositiontaking_3   <  @v3apositiontaking_3  
        or @v3mpositiontaking_20   <  @v3apositiontaking_20

        or @v5mpositiontaking_1   <  @v5apositiontaking_1  
        or @v5mpositiontaking_2   <  @v5apositiontaking_2  
        or @v5mpositiontaking_3   <  @v5apositiontaking_3  
        or @v5mpositiontaking_20   <  @v5apositiontaking_20
        or @v5mpositiontaking_9999   <  @v5apositiontaking_9999  

        or @v8mpositiontaking_1   <  @v8apositiontaking_1  
        or @v8mpositiontaking_3   <  @v8apositiontaking_3  
        or @v8mpositiontaking_20   <  @v8apositiontaking_20

        or @v10mpositiontaking_1   <  @v10apositiontaking_1  
        or @v10mpositiontaking_2   <  @v10apositiontaking_2  
        or @v10mpositiontaking_3   <  @v10apositiontaking_3  
        or @v10mpositiontaking_20   <  @v10apositiontaking_20

        or @v11mpositiontaking_1   <  @v11apositiontaking_1  
        or @v11mpositiontaking_20   <  @v11apositiontaking_20

        or @v99mpositiontaking_1   <  @v99apositiontaking_1  
        or @v99mpositiontaking_2   <  @v99apositiontaking_2  
        or @v99mpositiontaking_3   <  @v99apositiontaking_3  
        or @v99mpositiontaking_9   <  @v99apositiontaking_9
        or @v99mpositiontaking_20   <  @v99apositiontaking_20
		or @v99mpositiontaking_9999   <  @v99apositiontaking_9999
        
        -- Outright PT for sports
        or @v2spositiontaking_10 <0
        or @v3spositiontaking_10 <0
        or @v5spositiontaking_10 <0
        or @v8spositiontaking_10 <0
        or @v10spositiontaking_10 <0
        or @v11spositiontaking_10 <0
        or @v99spositiontaking_10 <0
        
		or @v2mpositiontaking_10 <0
		or @v3mpositiontaking_10 <0
		or @v5mpositiontaking_10 <0
		or @v8mpositiontaking_10 <0
		or @v10mpositiontaking_10 <0
		or @v11mpositiontaking_10 <0
		or @v99mpositiontaking_10 <0
		
		or @v2apositiontaking_10 <0
		or @v3apositiontaking_10 <0
		or @v5apositiontaking_10 <0
		or @v8apositiontaking_10 <0
		or @v10apositiontaking_10 <0
		or @v11apositiontaking_10 <0
		or @v99apositiontaking_10 <0
		

		or @v2spositiontaking_10 >0.9
		or @v3spositiontaking_10 >0.9
		or @v5spositiontaking_10 >0.9
		or @v8spositiontaking_10 >0.9
		or @v10spositiontaking_10 >0.9
		or @v11spositiontaking_10 >0.9
		or @v99spositiontaking_10 >0.9
		
		
		or @v2mpositiontaking_10 >0.9
		or @v3mpositiontaking_10 >0.9
		or @v5mpositiontaking_10 >0.9
		or @v8mpositiontaking_10 >0.9
		or @v10mpositiontaking_10 >0.9
		or @v11mpositiontaking_10 >0.9
		or @v99mpositiontaking_10 >0.9
		
		or @v2apositiontaking_10 >0.9
		or @v3apositiontaking_10 >0.9
		or @v5apositiontaking_10 >0.9
		or @v8apositiontaking_10 >0.9
		or @v10apositiontaking_10 >0.9
		or @v11apositiontaking_10 >0.9
		or @v99apositiontaking_10 >0.9

		or @v2spositiontaking_10  <  @v2mpositiontaking_10 
		or @v3spositiontaking_10  <  @v3mpositiontaking_10 
		or @v5spositiontaking_10  <  @v5mpositiontaking_10 
		or @v8spositiontaking_10  <  @v8mpositiontaking_10 
		or @v10spositiontaking_10  <  @v10mpositiontaking_10 
		or @v11spositiontaking_10  <  @v11mpositiontaking_10 
		or @v99spositiontaking_10  <  @v99mpositiontaking_10 
		
		or @v2mpositiontaking_10  <  @v2apositiontaking_10 
		or @v3mpositiontaking_10  <  @v3apositiontaking_10 
		or @v5mpositiontaking_10  <  @v5apositiontaking_10 
		or @v8mpositiontaking_10  <  @v8apositiontaking_10 
		or @v10mpositiontaking_10  <  @v10apositiontaking_10 
		or @v11mpositiontaking_10  <  @v11apositiontaking_10 
		or @v99mpositiontaking_10  <  @v99apositiontaking_10 


    BEGIN
        
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
                    end, @ErrCode = 101
        return
    END

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
        --@Old_v2spositiontaking_9 smallmoney,
        @Old_v2spositiontaking_20 smallmoney,
        @Old_v2spositiontaking_9999 smallmoney,

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
        @Old_v99spositiontaking_9 smallmoney,
        @Old_v99spositiontaking_20 smallmoney,
		@Old_v99spositiontaking_9999 smallmoney,
         
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
        --@Old_v2mpositiontaking_9 smallmoney,
        @Old_v2mpositiontaking_20 smallmoney,
        @Old_v2mpositiontaking_9999 smallmoney,

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
        @Old_v11mpositiontaking_2 smallmoney,
        @Old_v11mpositiontaking_20 smallmoney,

        @Old_v99mpositiontaking_1 smallmoney,
        @Old_v99mpositiontaking_2 smallmoney,
        @Old_v99mpositiontaking_3 smallmoney,
        @Old_v99mpositiontaking_9 smallmoney,
        @Old_v99mpositiontaking_20 smallmoney,
		@Old_v99mpositiontaking_9999 smallmoney,      
        
        @Old_apositiontaking_1 smallmoney,
        @Old_apositiontaking_2 smallmoney,
        @Old_apositiontaking_3 smallmoney,
        @Old_apositiontaking_4 smallmoney,
        @Old_apositiontaking_5 smallmoney,
        @Old_apositiontaking_6 smallmoney,
        @Old_apositiontaking_7 smallmoney,
        @Old_apositiontaking_8 smallmoney,
        @Old_apositiontaking_9 smallmoney,
        @Old_apositiontaking_10 smallmoney,
        @Old_apositiontaking_9999 smallmoney,
        
        @Old_alivepositiontaking_1 smallmoney,
        @Old_alivepositiontaking_3 smallmoney,
        @Old_alivepositiontaking_7 smallmoney,
        @Old_alivepositiontaking_8 smallmoney,
        
        @Old_v2apositiontaking_1 smallmoney,
        @Old_v2apositiontaking_2 smallmoney,
        @Old_v2apositiontaking_3 smallmoney,
        @Old_v2apositiontaking_7 smallmoney,
        @Old_v2apositiontaking_8 smallmoney,
        --@Old_v2apositiontaking_9 smallmoney,
        @Old_v2apositiontaking_20 smallmoney,
        @Old_v2apositiontaking_9999 smallmoney,

        @Old_v3apositiontaking_1 smallmoney,
        @Old_v3apositiontaking_2 smallmoney,
        @Old_v3apositiontaking_3 smallmoney,
        @Old_v3apositiontaking_20 smallmoney,

        @Old_v5apositiontaking_1 smallmoney,
        @Old_v5apositiontaking_2 smallmoney,
        @Old_v5apositiontaking_3 smallmoney,
        @Old_v5apositiontaking_20 smallmoney,
        @Old_v5apositiontaking_9999 smallmoney,

        @Old_v8apositiontaking_1 smallmoney,
        @Old_v8apositiontaking_3 smallmoney,
        @Old_v8apositiontaking_20 smallmoney,

        @Old_v10apositiontaking_1 smallmoney,
        @Old_v10apositiontaking_2 smallmoney,
        @Old_v10apositiontaking_3 smallmoney,
        @Old_v10apositiontaking_20 smallmoney,

        @Old_v11apositiontaking_1 smallmoney,
        @Old_v11apositiontaking_20 smallmoney,

        @Old_v99apositiontaking_1 smallmoney,
        @Old_v99apositiontaking_2 smallmoney,
        @Old_v99apositiontaking_3 smallmoney,
        @Old_v99apositiontaking_9 smallmoney,
        @Old_v99apositiontaking_20 smallmoney,
		@Old_v99apositiontaking_9999 smallmoney,         
        
        -- For Outright PT for sports
        
		@Old_v2spositiontaking_10 smallmoney,
		@Old_v3spositiontaking_10 smallmoney,
		@Old_v5spositiontaking_10 smallmoney,
		@Old_v8spositiontaking_10 smallmoney,
		@Old_v10spositiontaking_10 smallmoney,
		@Old_v11spositiontaking_10 smallmoney,
		@Old_v99spositiontaking_10 smallmoney,
		
		@Old_v2mpositiontaking_10 smallmoney,
		@Old_v3mpositiontaking_10 smallmoney,
		@Old_v5mpositiontaking_10 smallmoney,
		@Old_v8mpositiontaking_10 smallmoney,
		@Old_v10mpositiontaking_10 smallmoney,
		@Old_v11mpositiontaking_10 smallmoney,
		@Old_v99mpositiontaking_10 smallmoney,
		
		@Old_v2apositiontaking_10 smallmoney,
		@Old_v3apositiontaking_10 smallmoney,
		@Old_v5apositiontaking_10 smallmoney,
		@Old_v8apositiontaking_10 smallmoney,
		@Old_v10apositiontaking_10 smallmoney,
		@Old_v11apositiontaking_10 smallmoney,
		@Old_v99apositiontaking_10 smallmoney
        
    select @Old_spositiontaking_1= spositiontaking, @Old_mpositiontaking_1= mpositiontaking, @Old_apositiontaking_1= apositiontaking,
        @Old_slivepositiontaking_1= slivepositiontaking, @Old_mlivepositiontaking_1= mlivepositiontaking, @Old_alivepositiontaking_1= alivepositiontaking
    from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=1

    select @Old_spositiontaking_3= spositiontaking, @Old_mpositiontaking_3= mpositiontaking, @Old_apositiontaking_3= apositiontaking, 
        @Old_slivepositiontaking_3= slivepositiontaking, @Old_mlivepositiontaking_3= mlivepositiontaking, @Old_alivepositiontaking_3= alivepositiontaking
    from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=1

    select @Old_spositiontaking_7= spositiontaking, @Old_mpositiontaking_7= mpositiontaking, @Old_apositiontaking_7= apositiontaking, 
        @Old_slivepositiontaking_7= slivepositiontaking, @Old_mlivepositiontaking_7= mlivepositiontaking, @Old_alivepositiontaking_7= alivepositiontaking
    from custsetting with (nolock) where custid=@custid and bettype=7 and sporttype=1

    select @Old_spositiontaking_8= spositiontaking, @Old_mpositiontaking_8= mpositiontaking, @Old_apositiontaking_8= apositiontaking, 
        @Old_slivepositiontaking_8= slivepositiontaking, @Old_mlivepositiontaking_8= mlivepositiontaking, @Old_alivepositiontaking_8= alivepositiontaking
    from custsetting with (nolock) where custid=@custid and bettype=8 and sporttype=1

    select @Old_spositiontaking_2= spositiontaking, @Old_mpositiontaking_2= mpositiontaking, @Old_apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=1
    select @Old_spositiontaking_4= spositiontaking, @Old_mpositiontaking_4= mpositiontaking, @Old_apositiontaking_4= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=4 and sporttype=1
    select @Old_spositiontaking_5= spositiontaking, @Old_mpositiontaking_5= mpositiontaking, @Old_apositiontaking_5= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=5 and sporttype=1
    select @Old_spositiontaking_6= spositiontaking, @Old_mpositiontaking_6= mpositiontaking, @Old_apositiontaking_6= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=6 and sporttype=1
    select @Old_spositiontaking_9= spositiontaking, @Old_mpositiontaking_9= mpositiontaking, @Old_apositiontaking_9= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9 and sporttype=1
    select @Old_spositiontaking_10= spositiontaking, @Old_mpositiontaking_10= mpositiontaking, @Old_apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=1
    -- provide outright PT for Sports
    select @Old_v2spositiontaking_10= spositiontaking, @Old_v2mpositiontaking_10= mpositiontaking, @Old_v2apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=2
    select @Old_v3spositiontaking_10= spositiontaking, @Old_v3mpositiontaking_10= mpositiontaking, @Old_v3apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=3
    select @Old_v5spositiontaking_10= spositiontaking, @Old_v5mpositiontaking_10= mpositiontaking, @Old_v5apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=5
    select @Old_v8spositiontaking_10= spositiontaking, @Old_v8mpositiontaking_10= mpositiontaking, @Old_v8apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=8
    select @Old_v10spositiontaking_10= spositiontaking, @Old_v10mpositiontaking_10= mpositiontaking, @Old_v10apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=10
    select @Old_v11spositiontaking_10= spositiontaking, @Old_v11mpositiontaking_10= mpositiontaking, @Old_v11apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=11
    select @Old_v99spositiontaking_10= spositiontaking, @Old_v99mpositiontaking_10= mpositiontaking, @Old_v99apositiontaking_10= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=10 and sporttype=99
    
    
    select @Old_spositiontaking_9999= spositiontaking, @Old_mpositiontaking_9999= mpositiontaking, @Old_apositiontaking_9999= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9999 and sporttype=1


    select @Old_v2spositiontaking_1= spositiontaking, @Old_v2mpositiontaking_1= mpositiontaking, @Old_v2apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=2
    select @Old_v2spositiontaking_2= spositiontaking, @Old_v2mpositiontaking_2= mpositiontaking, @Old_v2apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=2
    select @Old_v2spositiontaking_3= spositiontaking, @Old_v2mpositiontaking_3= mpositiontaking, @Old_v2apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=2
    select @Old_v2spositiontaking_7= spositiontaking, @Old_v2mpositiontaking_7= mpositiontaking, @Old_v2apositiontaking_7= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=7 and sporttype=2
    select @Old_v2spositiontaking_8= spositiontaking, @Old_v2mpositiontaking_8= mpositiontaking, @Old_v2apositiontaking_8= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=8 and sporttype=2
    select @Old_v2spositiontaking_20= spositiontaking, @Old_v2mpositiontaking_20= mpositiontaking, @Old_v2apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=2
    select @Old_v2spositiontaking_9999= spositiontaking, @Old_v2mpositiontaking_9999= mpositiontaking, @Old_v2apositiontaking_9999= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9999 and sporttype=2

    select @Old_v3spositiontaking_1= spositiontaking, @Old_v3mpositiontaking_1= mpositiontaking, @Old_v3apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=3
    select @Old_v3spositiontaking_2= spositiontaking, @Old_v3mpositiontaking_2= mpositiontaking, @Old_v3apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=3
    select @Old_v3spositiontaking_3= spositiontaking, @Old_v3mpositiontaking_3= mpositiontaking, @Old_v3apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=3
    select @Old_v3spositiontaking_20= spositiontaking, @Old_v3mpositiontaking_20= mpositiontaking, @Old_v3apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=3

    select @Old_v5spositiontaking_1= spositiontaking, @Old_v5mpositiontaking_1= mpositiontaking, @Old_v5apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=5
    select @Old_v5spositiontaking_2= spositiontaking, @Old_v5mpositiontaking_2= mpositiontaking, @Old_v5apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=5
    select @Old_v5spositiontaking_3= spositiontaking, @Old_v5mpositiontaking_3= mpositiontaking, @Old_v5apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=5
    select @Old_v5spositiontaking_20= spositiontaking, @Old_v5mpositiontaking_20= mpositiontaking, @Old_v5apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=5
    select @Old_v5spositiontaking_9999= spositiontaking, @Old_v5mpositiontaking_9999= mpositiontaking, @Old_v5apositiontaking_9999= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9999 and sporttype=5

    select @Old_v8spositiontaking_1= spositiontaking, @Old_v8mpositiontaking_1= mpositiontaking, @Old_v8apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=8
    select @Old_v8spositiontaking_3= spositiontaking, @Old_v8mpositiontaking_3= mpositiontaking, @Old_v8apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=8
    select @Old_v8spositiontaking_20= spositiontaking, @Old_v8mpositiontaking_20= mpositiontaking, @Old_v8apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=8

    select @Old_v10spositiontaking_1= spositiontaking, @Old_v10mpositiontaking_1= mpositiontaking, @Old_v10apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=10
    select @Old_v10spositiontaking_2= spositiontaking, @Old_v10mpositiontaking_2= mpositiontaking, @Old_v10apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=10
    select @Old_v10spositiontaking_3= spositiontaking, @Old_v10mpositiontaking_3= mpositiontaking, @Old_v10apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=10
    select @Old_v10spositiontaking_20= spositiontaking, @Old_v10mpositiontaking_20= mpositiontaking, @Old_v10apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=10

    select @Old_v11spositiontaking_1= spositiontaking, @Old_v11mpositiontaking_1= mpositiontaking, @Old_v11apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=11
    select @Old_v11spositiontaking_20= spositiontaking, @Old_v11mpositiontaking_20= mpositiontaking, @Old_v11apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=11

    select @Old_v99spositiontaking_1= spositiontaking, @Old_v99mpositiontaking_1= mpositiontaking, @Old_v99apositiontaking_1= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=1 and sporttype=99
    select @Old_v99spositiontaking_2= spositiontaking, @Old_v99mpositiontaking_2= mpositiontaking, @Old_v99apositiontaking_2= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=2 and sporttype=99
    select @Old_v99spositiontaking_3= spositiontaking, @Old_v99mpositiontaking_3= mpositiontaking, @Old_v99apositiontaking_3= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=3 and sporttype=99
    select @Old_v99spositiontaking_20= spositiontaking, @Old_v99mpositiontaking_20= mpositiontaking, @Old_v99apositiontaking_20= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=20 and sporttype=99
    select @Old_v99spositiontaking_9= spositiontaking, @Old_v99mpositiontaking_9= mpositiontaking, @Old_v99apositiontaking_9= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9 and sporttype=99
	select @Old_v99spositiontaking_9999= spositiontaking, @Old_v99mpositiontaking_9999= mpositiontaking, @Old_v99apositiontaking_9999= apositiontaking from custsetting with (nolock) where custid=@custid and bettype=9999 and sporttype=99

    --check n4<=s4
        select @ErrType = ''
        select @ErrType = @ErrType + s.name + '-'+ bt.Name + '-Min: '+ dbo.f_FomatNumericToChar(co.minpositiontaking)
        + case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MinLive: '+ dbo.f_FomatNumericToChar(co.minlivepositiontaking) else '' end + '<br>'
        from custoverride as co with (NOLOCK) 
        inner join
        (
                    select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking
            union all     select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking
            union all     select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking
            union all     select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking
            union all     select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
            union all     select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking
            union all     select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking
            union all     select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking
            union all     select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            -- Outright PT for sports
            union all     select 10 as bettype, 2 as sporttype, @v2spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 3 as sporttype, @v3spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            union all     select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as slivepositiontaking
            
            union all     select 9999 as bettype, 1 as sporttype, @spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking
            
            union all     select 1 as bettype, 2 as sporttype, @v2spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 2 as bettype, 2 as sporttype, @v2spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
            union all     select 3 as bettype, 2 as sporttype, @v2spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
            --union all     select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking
            --union all     select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking
            --union all     select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 2 as sporttype, @v2spositiontaking_20 as spositiontaking, 0 as slivepositiontaking
            union all     select 9999 as bettype, 2 as sporttype, @v2spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking
			
            union all     select 1 as bettype, 3 as sporttype, @v3spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 2 as bettype, 3 as sporttype, @v3spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
            union all     select 3 as bettype, 3 as sporttype, @v3spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 3 as sporttype, @v3spositiontaking_20 as spositiontaking, 0 as slivepositiontaking

            union all     select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
            union all     select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking
            union all     select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking

            union all     select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking

            union all     select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
            union all     select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking

            union all     select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking

            union all     select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking
            union all     select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking
            union all     select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking
            union all     select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking
            union all     select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking
			union all     select 9999 as bettype, 99 as sporttype, @v99spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking
    
        ) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
        INNER JOIN #tmp_sports s on b.sporttype = s.ID
        INNER JOIN #tmp_bettype bt on b.bettype = bt.ID
    where co.custid = @custid and (    
                        (b.spositiontaking<co.minpositiontaking) or 
                        (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.slivepositiontaking<co.minlivepositiontaking))
                    )

    if @ErrType <>''
    BEGIN
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong position taking (min set by company).<br>'+@ErrType
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](20006,@Language) + '<br>' + @ErrType
                    end, @ErrCode = 102
        return
    END   

    --check all s3+m3<=s4 if i3 = 0,
    --m3<=s4 and u3<=s4 if i3=1
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        custinfo as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (

                select         1 as sporttype, 1 as bettype, @spositiontaking_1 as maxpositiontaking,  @slivepositiontaking_1 as maxlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @spositiontaking_3 as maxpositiontaking,  @slivepositiontaking_3 as maxlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @spositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @spositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @spositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @spositiontaking_7 as maxpositiontaking,  @slivepositiontaking_7 as maxlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @spositiontaking_8 as maxpositiontaking,  @slivepositiontaking_8 as maxlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @spositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                
                -- Outright PT for Sports
                union all select     2 as sporttype, 10 as bettype, @v2spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 10 as bettype, @v3spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 10 as bettype, @v5spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     8 as sporttype, 10 as bettype, @v8spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 10 as bettype, @v10spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     11 as sporttype, 10 as bettype, @v11spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 10 as bettype, @v99spositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                
                union all select     1 as sporttype, 9999 as bettype, @spositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     2 as sporttype, 1 as bettype, @v2spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @v2spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @v2spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @v2spositiontaking_7 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @v2spositiontaking_8 as maxpositiontaking,  0 as maxlivepositiontaking
                --union all select     2 as sporttype, 9 as bettype, @v2spositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 20 as bettype, @v2spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 9999 as bettype, @v2spositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     3 as sporttype, 1 as bettype, @v3spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 2 as bettype, @v3spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 3 as bettype, @v3spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 20 as bettype, @v3spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     5 as sporttype, 1 as bettype, @v5spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 2 as bettype, @v5spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 3 as bettype, @v5spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 20 as bettype, @v5spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 9999 as bettype, @v5spositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     8 as sporttype, 1 as bettype, @v8spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     8 as sporttype, 3 as bettype, @v8spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     8 as sporttype, 20 as bettype, @v8spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     10 as sporttype, 1 as bettype, @v10spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 2 as bettype, @v10spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 3 as bettype, @v10spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 20 as bettype, @v10spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     11 as sporttype, 1 as bettype, @v11spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     11 as sporttype, 20 as bettype, @v11spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     99 as sporttype, 1 as bettype, @v99spositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 2 as bettype, @v99spositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 3 as bettype, @v99spositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 9 as bettype, @v99spositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 20 as bettype, @v99spositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
				union all select     99 as sporttype, 9999 as bettype, @v99spositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

            ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.srecommend = @custid and c.roleid = 3 and (
                            ((cs.isautopositiontaking=0) and (cs.spositiontaking+cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.mpositiontaking>b.maxpositiontaking)) or 
                            ((cs.isautopositiontaking=1) and (cs.autopositiontaking>b.maxpositiontaking)) or 
                            ((b.sporttype=1) and (b.bettype in (1,3,7,8)) and (cs.isautolivepositiontaking=0) and (cs.slivepositiontaking+cs.mlivepositiontaking>b.maxlivepositiontaking)) or
                            ((b.sporttype=1) and (b.bettype in (1,3,7,8)) and (cs.isautolivepositiontaking=1) and (cs.mlivepositiontaking>b.maxlivepositiontaking)) or
                            ((b.sporttype=1) and (b.bettype in (1,3,7,8)) and (cs.isautolivepositiontaking=1) and (cs.autolivepositiontaking>b.maxlivepositiontaking))                        
                            )
    group by username
    if @ErrAcc<>''
    BEGIN
        Select @ErrMsg =     case @Language 
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
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 1 AS sporttype--1
                 , 1 AS bettype
                 , @spositiontaking_1 AS maxpositiontaking
                 , @slivepositiontaking_1 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 2 AS bettype
                 , @spositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 3 AS bettype
                 , @spositiontaking_3 AS maxpositiontaking
                 , @slivepositiontaking_3 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 4 AS bettype
                 , @spositiontaking_4 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 5 AS bettype
                 , @spositiontaking_5 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL select 1 as sporttype
                 , 6 as bettype
                 , @spositiontaking_6 as maxpositiontaking
                 , 0 as maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 7 AS bettype
                 , @spositiontaking_7 AS maxpositiontaking
                 , @slivepositiontaking_7 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 8 AS bettype
                 , @spositiontaking_8 AS maxpositiontaking
                 , @slivepositiontaking_8 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 9 AS bettype
                 , @spositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 10 AS bettype
                 , @spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  -- Outright PT for Reports
  UNION ALL SELECT 2 AS sporttype
                 , 10 AS bettype
                 , @v2spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 3 AS sporttype
                 , 10 AS bettype
                 , @v3spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 5 AS sporttype
                 , 10 AS bettype
                 , @v5spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 8 AS sporttype
                 , 10 AS bettype
                 , @v8spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
                 
  UNION ALL SELECT 10 AS sporttype
                 , 10 AS bettype
                 , @v10spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 11 AS sporttype
                 , 10 AS bettype
                 , @v11spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 99 AS sporttype
                 , 10 AS bettype
                 , @v99spositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
                 
                                                                                                                 
  UNION all SELECT 1 AS sporttype
                 , 9999 AS bettype
                 , @spositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--2
  UNION all SELECT 2 AS sporttype
                 , 1 AS bettype
                 , @v2spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION all SELECT 2 AS sporttype
                 , 2 AS bettype
                 , @v2spositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 3 AS bettype
                 , @v2spositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 7 AS bettype
                 , @v2spositiontaking_7 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 8 AS bettype
                 , @v2spositiontaking_8 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

                --union all select     2 as sporttype, 9 as bettype, @v2spositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 20 AS bettype
                 , @v2spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 9999 AS bettype
                 , @v2spositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--3
  UNION ALL SELECT 3 AS sporttype
                 , 1 AS bettype
                 , @v3spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 2 AS bettype
                 , @v3spositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 3 AS bettype
                 , @v3spositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 20 AS bettype
                 , @v3spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--5
  UNION ALL SELECT 5 AS sporttype
                 , 1 AS bettype
                 , @v5spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 2 AS bettype
                 , @v5spositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 3 AS bettype
                 , @v5spositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 20 AS bettype
                 , @v5spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 9999 AS bettype
                 , @v5spositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--8
  UNION ALL SELECT 8 AS sporttype
                 , 1 AS bettype
                 , @v8spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 3 AS bettype
                 , @v8spositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 20 AS bettype
                 , @v8spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--10
  UNION ALL SELECT 10 AS sporttype
                 , 1 AS bettype
                 , @v10spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 2 AS bettype
                 , @v10spositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 3 AS bettype
                 , @v10spositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 20 AS bettype
                 , @v10spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--11
  UNION ALL SELECT 11 AS sporttype
                 , 1 AS bettype
                 , @v11spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 11 AS sporttype
                 , 20 AS bettype
                 , @v11spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--99
  UNION ALL SELECT 99 AS sporttype
                 , 1 AS bettype
                 , @v99spositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 2 AS bettype
                 , @v99spositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 3 AS bettype
                 , @v99spositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 9 AS bettype
                 , @v99spositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 20 AS bettype
                 , @v99spositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 99 AS sporttype
                 , 9999 AS bettype
                 , @v99spositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking> b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.slivepositiontaking + cs.alivepositiontaking + cs.mlivepositiontaking > b.maxlivepositiontaking
               )
            OR (cs.isautopositiontaking = 1
                AND cs.autopositiontaking > b.maxpositiontaking
               )
            OR (cs.isautolivepositiontaking = 1
                AND b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.autolivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg =
                  CASE @Language
                   WHEN 'E' THEN 'Existing members exceeded new super position taking (' + @ErrAcc + ').'
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](20014, @Language) + ' (' + @ErrAcc + ').'
                 END
             , @ErrCode = 104
        RETURN
    END    

    --------------------------------------------------------------------------------------------
    --Check all m3<=m4
    select @ErrAcc = ''
    select top 100 @ErrAcc = @ErrAcc + username +', '
    from 
        custinfo as c with (NOLOCK) 
        inner join custsetting as cs with (NOLOCK) on c.custid = cs.custid
        inner join (
                          select         1 as sporttype, 1 as bettype, @mpositiontaking_1 as maxpositiontaking,  @mlivepositiontaking_1 as maxlivepositiontaking
                union all select     1 as sporttype, 2 as bettype, @mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 3 as bettype, @mpositiontaking_3 as maxpositiontaking,  @mlivepositiontaking_3 as maxlivepositiontaking
                union all select     1 as sporttype, 4 as bettype, @mpositiontaking_4 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 5 as bettype, @mpositiontaking_5 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 6 as bettype, @mpositiontaking_6 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 7 as bettype, @mpositiontaking_7 as maxpositiontaking,  @mlivepositiontaking_7 as maxlivepositiontaking
                union all select     1 as sporttype, 8 as bettype, @mpositiontaking_8 as maxpositiontaking,  @mlivepositiontaking_8 as maxlivepositiontaking
                union all select     1 as sporttype, 9 as bettype, @mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     1 as sporttype, 10 as bettype, @mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                
                -- Outright PT for sports
                union all select     2 as sporttype, 10 as bettype, @v2mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 10 as bettype, @v3mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 10 as bettype, @v5mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     8 as sporttype, 10 as bettype, @v8mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 10 as bettype, @v10mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     11 as sporttype, 10 as bettype, @v11mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 10 as bettype, @v99mpositiontaking_10 as maxpositiontaking,  0 as maxlivepositiontaking
                
                
                union all select     1 as sporttype, 9999 as bettype, @mpositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     2 as sporttype, 1 as bettype, @v2mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 2 as bettype, @v2mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 3 as bettype, @v2mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 7 as bettype, @v2mpositiontaking_7 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 8 as bettype, @v2mpositiontaking_8 as maxpositiontaking,  0 as maxlivepositiontaking
                --union all select     2 as sporttype, 9 as bettype, @v2mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 20 as bettype, @v2mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     2 as sporttype, 9999 as bettype, @v2mpositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     3 as sporttype, 1 as bettype, @v3mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 2 as bettype, @v3mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 3 as bettype, @v3mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     3 as sporttype, 20 as bettype, @v3mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     5 as sporttype, 1 as bettype, @v5mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 2 as bettype, @v5mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 3 as bettype, @v5mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 20 as bettype, @v5mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     5 as sporttype, 9999 as bettype, @v5mpositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     8 as sporttype, 1 as bettype, @v8mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     8 as sporttype, 3 as bettype, @v8mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     8 as sporttype, 20 as bettype, @v8mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     10 as sporttype, 1 as bettype, @v10mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 2 as bettype, @v10mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 3 as bettype, @v10mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     10 as sporttype, 20 as bettype, @v10mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     11 as sporttype, 1 as bettype, @v11mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     11 as sporttype, 20 as bettype, @v11mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking

                union all select     99 as sporttype, 1 as bettype, @v99mpositiontaking_1 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 2 as bettype, @v99mpositiontaking_2 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 3 as bettype, @v99mpositiontaking_3 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 9 as bettype, @v99mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 20 as bettype, @v99mpositiontaking_20 as maxpositiontaking,  0 as maxlivepositiontaking
                union all select     99 as sporttype, 9999 as bettype, @v99mpositiontaking_9999 as maxpositiontaking,  0 as maxlivepositiontaking

                
                ) as b on cs.sporttype=b.sporttype and cs.bettype = b.bettype
    where c.srecommend = @custid and c.roleid = 3 and (
                (cs.mpositiontaking>b.maxpositiontaking) 
                or 
                (b.sporttype=1 and b.bettype in (1,3,7,8) and cs.mlivepositiontaking>b.maxlivepositiontaking)   
                )
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
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 1 AS sporttype--1
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
   --  Outright PT for sports
   UNION ALL SELECT 2 AS sporttype
                 , 10 AS bettype
                 , @v2mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
   UNION ALL SELECT 3 AS sporttype
                 , 10 AS bettype
                 , @v3mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

   UNION ALL SELECT 5 AS sporttype
                 , 10 AS bettype
                 , @v5mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

   UNION ALL SELECT 8 AS sporttype
                 , 10 AS bettype
                 , @v8mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

   UNION ALL SELECT 10 AS sporttype
                 , 10 AS bettype
                 , @v10mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

   UNION ALL SELECT 11 AS sporttype
                 , 10 AS bettype
                 , @v11mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

   UNION ALL SELECT 99 AS sporttype
                 , 10 AS bettype
                 , @v99mpositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

                 	
  UNION ALL SELECT 1 AS sporttype
                 , 9999 AS bettype
                 , @mpositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--2
  UNION ALL SELECT 2 AS sporttype
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

  UNION ALL SELECT 2 AS sporttype
                 , 7 AS bettype
                 , @v2mpositiontaking_7 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 8 AS bettype
                 , @v2mpositiontaking_8 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

                --union all select     2 as sporttype, 9 as bettype, @v2mpositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 20 AS bettype
                 , @v2mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 9999 AS bettype
                 , @v2mpositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking               
--3
  UNION ALL SELECT 3 AS sporttype
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
--5
  UNION ALL SELECT 5 AS sporttype
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
--8
  UNION ALL SELECT 8 AS sporttype
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
--10
  UNION ALL SELECT 10 AS sporttype
                 , 1 AS bettype
                 , @v10mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 2 AS bettype
                 , @v10mpositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 3 AS bettype
                 , @v10mpositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 20 AS bettype
                 , @v10mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--11
  UNION ALL SELECT 11 AS sporttype
                 , 1 AS bettype
                 , @v11mpositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 11 AS sporttype
                 , 20 AS bettype
                 , @v11mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
--99
  UNION ALL SELECT 99 AS sporttype
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
                 , 9 AS bettype
                 , @v99mpositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 20 AS bettype
                 , @v99mpositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 99 AS sporttype
                 , 9999 AS bettype
                 , @v99mpositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.mpositiontaking + cs.apositiontaking > b.maxpositiontaking
               OR (b.sporttype = 1
                   AND b.bettype IN (1, 3, 7, 8)
                   AND cs.mlivepositiontaking + cs.alivepositiontaking > b.maxlivepositiontaking)
               )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @UserName
                       + ': ' + CASE @Language 
                                  WHEN 'E' THEN 'Existing members exceeded new master position taking (' + @ErrAcc + ').'
                                  ELSE [dbo].[f_Get_MsgNamebyMsgID](20012, @Language) + ' (' + @ErrAcc + ').'
                                END
             , @ErrCode = 108
        RETURN
    END    

    -------------------------------------------------------------------------------------------------------------------
    --Check all a2<=a4
    select @ErrAcc = ''

    select top 100 @ErrAcc = @ErrAcc + username + ', '
      from custinfo c with(NOLOCK)
    inner join custsetting cs with(NOLOCK) on c.custid = cs.custid
    inner join (select 1 as sporttype
                     , 1 as bettype
                     , @apositiontaking_1 as maxpositiontaking
                     , @alivepositiontaking_1 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 2 as bettype
                     , @apositiontaking_2 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 3 as bettype
                     , @apositiontaking_3 as maxpositiontaking
                     , @alivepositiontaking_3 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 4 as bettype
                     , @apositiontaking_4 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 5 as bettype
                     , @apositiontaking_5 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 6 as bettype
                     , @apositiontaking_6 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 7 as bettype
                     , @apositiontaking_7 as maxpositiontaking
                     , @alivepositiontaking_7 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 8 as bettype
                     , @apositiontaking_8 as maxpositiontaking
                     , @alivepositiontaking_8 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 9 as bettype
                     , @apositiontaking_9 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 1 as sporttype
                     , 10 as bettype
                     , @apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking
	  -- Outright PT for sports
	  union all select 2 as sporttype
                     , 10 as bettype
                     , @v2apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking
                     		
	  union all select 3 as sporttype
                     , 10 as bettype
                     , @v3apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking

	  union all select 5 as sporttype
                     , 10 as bettype
                     , @v5apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking

	  union all select 8 as sporttype
                     , 10 as bettype
                     , @v8apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking

	  union all select 10 as sporttype
                     , 10 as bettype
                     , @v10apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking

	  union all select 11 as sporttype
                     , 10 as bettype
                     , @v11apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking

	  union all select 99 as sporttype
                     , 10 as bettype
                     , @v99apositiontaking_10 as maxpositiontaking
                     , 0 as maxlivepositiontaking


      union all select 1 as sporttype
                     , 9999 as bettype
                     , @apositiontaking_9999 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 2 as sporttype
                     , 1 as bettype
                     , @v2apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 2 as sporttype
                     , 2 as bettype
                     , @v2apositiontaking_2 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 2 as sporttype
                     , 3 as bettype
                     , @v2apositiontaking_3 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 2 as sporttype
                     , 7 as bettype
                     , @v2apositiontaking_7 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 2 as sporttype
                     , 8 as bettype
                     , @v2apositiontaking_8 as maxpositiontaking
                     , 0 as maxlivepositiontaking

                --union all select     2 as sporttype, 9 as bettype, @v2apositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
      union all select 2 as sporttype
                     , 20 as bettype
                     , @v2apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking
	  union all select 2 as sporttype
                     , 9999 as bettype
                     , @v2apositiontaking_9999 as maxpositiontaking
                     , 0 as maxlivepositiontaking
                     
      union all select 3 as sporttype
                     , 1 as bettype
                     , @v3apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 3 as sporttype
                     , 2 as bettype
                     , @v3apositiontaking_2 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 3 as sporttype
                     , 3 as bettype
                     , @v3apositiontaking_3 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 3 as sporttype
                     , 20 as bettype
                     , @v3apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 5 as sporttype
                     , 1 as bettype
                     , @v5apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 5 as sporttype
                     , 2 as bettype
                     , @v5apositiontaking_2 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 5 as sporttype
                     , 3 as bettype
                     , @v5apositiontaking_3 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 5 as sporttype
                     , 20 as bettype
                     , @v5apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 5 as sporttype
                     , 9999 as bettype
                     , @v5apositiontaking_9999 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 8 as sporttype
                     , 1 as bettype
                     , @v8apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 8 as sporttype
                     , 3 as bettype
                     , @v8apositiontaking_3 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 8 as sporttype
                     , 20 as bettype
                     , @v8apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 10 as sporttype
                     , 1 as bettype
                     , @v10apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 10 as sporttype
                     , 2 as bettype
                     , @v10apositiontaking_2 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 10 as sporttype
                     , 3 as bettype
                     , @v10apositiontaking_3 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 10 as sporttype
                     , 20 as bettype
                     , @v10apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 11 as sporttype
                     , 1 as bettype
                     , @v11apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 11 as sporttype
                     , 20 as bettype
                     , @v11apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 99 as sporttype
                     , 1 as bettype
                     , @v99apositiontaking_1 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 99 as sporttype
                     , 2 as bettype
                     , @v99apositiontaking_2 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 99 as sporttype
                     , 3 as bettype
                     , @v99apositiontaking_3 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 99 as sporttype
                     , 9 as bettype
                     , @v99apositiontaking_9 as maxpositiontaking
                     , 0 as maxlivepositiontaking

      union all select 99 as sporttype
                     , 20 as bettype
                     , @v99apositiontaking_20 as maxpositiontaking
                     , 0 as maxlivepositiontaking
	  union all select 99 as sporttype
					, 9999 as bettype
					, @v99apositiontaking_9999 as maxpositiontaking
					, 0 as maxlivepositiontaking

               ) b on cs.sporttype = b.sporttype and cs.bettype = b.bettype
         where c.srecommend = @custid
           and c.roleid     = 2
           AND c.Enabled    = 1
           and (cs.apositiontaking > b.maxpositiontaking
                or (b.sporttype = 1
                    and b.bettype in (1, 3, 7, 8)
                    and cs.alivepositiontaking > b.maxlivepositiontaking
                   )
               )
      group by username

    if @ErrAcc <> ''
    BEGIN
        Select @ErrMsg = @UserName + ': '
                       + case @Language 
                           when 'E' then 'Existing agents exceeded new agent position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20016, @Language) + ' (' + @ErrAcc + ').'
                         end
             , @ErrCode = 109
        return
    END    

    --Check all a1<=a4
    SELECT @ErrAcc = ''

    SELECT TOP 100 @ErrAcc = @ErrAcc + username + ', '
      FROM custinfo c WITH(NOLOCK) 
INNER JOIN custsetting cs WITH(NOLOCK) ON c.custid = cs.custid
INNER JOIN (SELECT 1 AS sporttype
                 , 1 AS bettype
                 , @apositiontaking_1 AS maxpositiontaking
                 , @alivepositiontaking_1 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 2 AS bettype
                 , @apositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 3 AS bettype
                 , @apositiontaking_3 AS maxpositiontaking
                 , @alivepositiontaking_3 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 4 AS bettype
                 , @apositiontaking_4 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 5 AS bettype
                 , @apositiontaking_5 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 6 AS bettype
                 , @apositiontaking_6 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 7 AS bettype
                 , @apositiontaking_7 AS maxpositiontaking
                 , @alivepositiontaking_7 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 8 AS bettype
                 , @apositiontaking_8 AS maxpositiontaking
                 , @alivepositiontaking_8 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 9 AS bettype
                 , @apositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 1 AS sporttype
                 , 10 AS bettype
                 , @apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  -- Outright PT for sports
  UNION ALL SELECT 2 AS sporttype
                 , 10 AS bettype
                 , @v2apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
                 
  UNION ALL SELECT 3 AS sporttype
                 , 10 AS bettype
                 , @v3apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 10 AS bettype
                 , @v5apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 10 AS bettype
                 , @v8apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 10 AS bettype
                 , @v10apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 11 AS sporttype
                 , 10 AS bettype
                 , @v11apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 10 AS bettype
                 , @v99apositiontaking_10 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

                 
  UNION ALL SELECT 1 AS sporttype
                 , 9999 AS bettype
                 , @apositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 1 AS bettype
                 , @v2apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 2 AS bettype
                 , @v2apositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 3 AS bettype
                 , @v2apositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 7 AS bettype
                 , @v2apositiontaking_7 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 2 AS sporttype
                 , 8 AS bettype
                 , @v2apositiontaking_8 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

                --union all select     2 as sporttype, 9 as bettype, @v2apositiontaking_9 as maxpositiontaking,  0 as maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 20 AS bettype
                 , @v2apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 2 AS sporttype
                 , 9999 AS bettype
                 , @v2apositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 3 AS sporttype
                 , 1 AS bettype
                 , @v3apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 2 AS bettype
                 , @v3apositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 3 AS sporttype
                 , 3 AS bettype
                 , @v3apositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 3 AS sporttype
                 , 20 AS bettype
                 , @v3apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 1 AS bettype
                 , @v5apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 2 AS bettype
                 , @v5apositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 3 AS bettype
                 , @v5apositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 20 AS bettype
                 , @v5apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 5 AS sporttype
                 , 9999 AS bettype
                 , @v5apositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 1 AS bettype
                 , @v8apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 3 AS bettype
                 , @v8apositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 8 AS sporttype
                 , 20 AS bettype
                 , @v8apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 1 AS bettype
                 , @v10apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 2 AS bettype
                 , @v10apositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 3 AS bettype
                 , @v10apositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 10 AS sporttype
                 , 20 AS bettype
                 , @v10apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 11 AS sporttype
                 , 1 AS bettype
                 , @v11apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 11 AS sporttype
                 , 20 AS bettype
                 , @v11apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 1 AS bettype
                 , @v99apositiontaking_1 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 2 AS bettype
                 , @v99apositiontaking_2 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 3 AS bettype
                 , @v99apositiontaking_3 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 9 AS bettype
                 , @v99apositiontaking_9 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

  UNION ALL SELECT 99 AS sporttype
                 , 20 AS bettype
                 , @v99apositiontaking_20 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking
  UNION ALL SELECT 99 AS sporttype
                 , 9999 AS bettype
                 , @v99apositiontaking_9999 AS maxpositiontaking
                 , 0 AS maxlivepositiontaking

           ) b ON cs.sporttype = b.sporttype
              AND cs.bettype = b.bettype
     WHERE c.srecommend = @custid
       AND c.roleid     = 1
       AND c.Enabled    = 1
       AND (cs.apositiontaking > b.maxpositiontaking
            OR (b.sporttype = 1
                AND b.bettype IN (1, 3, 7, 8)
                AND cs.alivepositiontaking > b.maxlivepositiontaking
               )
           )
  GROUP BY username

    IF @ErrAcc <> ''
    BEGIN
        SELECT @ErrMsg = @UserName + ': '
                       + CASE @Language 
                           WHEN 'E' THEN 'Existing members exceeded new agent position taking (' + @ErrAcc + ').'
                           ELSE [dbo].[f_Get_MsgNamebyMsgID](20017, @Language) + ' (' + @ErrAcc + ').'
                         END
             , @ErrCode = 109
        RETURN
    END    

    --------------------------------------------------------------------------------------------

    update custsetting with (ROWLOCK, UPDLOCK)
    set
        spositiontaking = case sporttype     
						when 1 then case bettype when 1 then @spositiontaking_1 when 2 then @spositiontaking_2 when 3 then @spositiontaking_3 when 4 then @spositiontaking_4 when 5 then @spositiontaking_5 when 6 then @spositiontaking_6 when 7 then @spositiontaking_7 when 8 then @spositiontaking_8 when 9 then @spositiontaking_9  when 10 then @spositiontaking_10 when 9999 then @spositiontaking_9999 else 0 end
                        
                        when 2 then case bettype when 1 then @v2spositiontaking_1 when 2 then @v2spositiontaking_2 when 3 then @v2spositiontaking_3 when 7 then @v2spositiontaking_7 when 8 then @v2spositiontaking_8 when 20 then @v2spositiontaking_20 when 9999 then @v2spositiontaking_9999 when 10 then @v2spositiontaking_10 else 0 end
                        
                        when 3 then case bettype when 1 then @v3spositiontaking_1 when 2 then @v3spositiontaking_2 when 3 then @v3spositiontaking_3 when 20 then @v3spositiontaking_20 when 10 then @v3spositiontaking_10 else 0 end
                        
                        when 5 then case bettype when 1 then @v5spositiontaking_1 when 2 then @v5spositiontaking_2 when 3 then @v5spositiontaking_3 when 20 then @v5spositiontaking_20 when 9999 then @v5spositiontaking_9999  when 10 then @v5spositiontaking_10 else 0 end
                        
                        when 8 then case bettype when 1 then @v8spositiontaking_1 when 3 then @v8spositiontaking_3 when 20 then @v8spositiontaking_20 when 10 then @v8spositiontaking_10 else 0 end
                        
                        when 10 then case bettype when 1 then @v10spositiontaking_1 when 2 then @v10spositiontaking_2 when 3 then @v10spositiontaking_3 when 20 then @v10spositiontaking_20 when 10 then @v10spositiontaking_10 else 0 end
                        
                        when 11 then case bettype when 1 then @v11spositiontaking_1 when 20 then @v11spositiontaking_20 when 10 then @v11spositiontaking_10 else 0 end
                        
                        when 99 then case bettype when 1 then @v99spositiontaking_1 when 2 then @v99spositiontaking_2 when 3 then @v99spositiontaking_3 when 9 then @v99spositiontaking_9  when 20 then @v99spositiontaking_20 when 10 then @v99spositiontaking_10 when 9999 then @v99spositiontaking_9999 else 0 end
                        
                        
                        else spositiontaking end,
        
        slivepositiontaking = case sporttype     when 1 then case bettype when 1 then @slivepositiontaking_1 when 3 then @slivepositiontaking_3 when 7 then @slivepositiontaking_7 when 8 then @slivepositiontaking_8 else slivepositiontaking end else slivepositiontaking end,
        
        mpositiontaking = case sporttype     
						when 1 then case bettype when 1 then @mpositiontaking_1 when 2 then @mpositiontaking_2 when 3 then @mpositiontaking_3 when 4 then @mpositiontaking_4 when 5 then @mpositiontaking_5 when 6 then @mpositiontaking_6 when 7 then @mpositiontaking_7 when 8 then @mpositiontaking_8 when 9 then @mpositiontaking_9  when 10 then @mpositiontaking_10 when 9999 then @mpositiontaking_9999 else 0 end
						
                        when 2 then case bettype when 1 then @v2mpositiontaking_1 when 2 then @v2mpositiontaking_2 when 3 then @v2mpositiontaking_3 when 7 then @v2mpositiontaking_7 when 8 then @v2mpositiontaking_8 when 20 then @v2mpositiontaking_20 when 9999 then @v2mpositiontaking_9999 when 10 then @v2mpositiontaking_10 else 0 end
                        
                        when 3 then case bettype when 1 then @v3mpositiontaking_1 when 2 then @v3mpositiontaking_2 when 3 then @v3mpositiontaking_3 when 20 then @v3mpositiontaking_20 when 10 then @v3mpositiontaking_10 else 0 end
                        
                        when 5 then case bettype when 1 then @v5mpositiontaking_1 when 2 then @v5mpositiontaking_2 when 3 then @v5mpositiontaking_3 when 20 then @v5mpositiontaking_20 when 9999 then @v5mpositiontaking_9999 when 10 then @v5mpositiontaking_10 else 0 end
                        
                        when 8 then case bettype when 1 then @v8mpositiontaking_1 when 3 then @v8mpositiontaking_3 when 20 then @v8mpositiontaking_20 when 10 then @v8mpositiontaking_10 else 0 end
                        
                        when 10 then case bettype when 1 then @v10mpositiontaking_1 when 2 then @v10mpositiontaking_2 when 3 then @v10mpositiontaking_3 when 20 then @v10mpositiontaking_20 when 10 then @v10mpositiontaking_10  else 0 end
                        
                        when 11 then case bettype when 1 then @v11mpositiontaking_1 when 20 then @v11mpositiontaking_20 when 10 then @v11mpositiontaking_10 else 0 end
                        
                        when 99 then case bettype when 1 then @v99mpositiontaking_1 when 2 then @v99mpositiontaking_2 when 3 then @v99mpositiontaking_3 when 9 then @v99mpositiontaking_9 when 20 then @v99mpositiontaking_20 when 10 then @v99mpositiontaking_10 when 9999 then @v99mpositiontaking_9999 else 0 end
                        
                       
                        else mpositiontaking end,
        
        mlivepositiontaking = case sporttype     when 1 then case bettype when 1 then @mlivepositiontaking_1 when 3 then @mlivepositiontaking_3 when 7 then @mlivepositiontaking_7 when 8 then @mlivepositiontaking_8 else mlivepositiontaking end else mlivepositiontaking end,
        apositiontaking = case sporttype     
						
						when 1 then case bettype when 1 then @apositiontaking_1 when 2 then @apositiontaking_2 when 3 then @apositiontaking_3 when 4 then @apositiontaking_4 when 5 then @apositiontaking_5 when 6 then @apositiontaking_6 when 7 then @apositiontaking_7 when 8 then @apositiontaking_8 when 9 then @apositiontaking_9  when 10 then @apositiontaking_10 when 9999 then @apositiontaking_9999 else 0 end
                        
                        when 2 then case bettype when 1 then @v2apositiontaking_1 when 2 then @v2apositiontaking_2 when 3 then @v2apositiontaking_3 when 7 then @v2apositiontaking_7 when 8 then @v2apositiontaking_8 when 20 then @v2apositiontaking_20 when 9999 then @v2apositiontaking_9999  when 10 then @v2apositiontaking_10 else 0 end
                        
                        when 3 then case bettype when 1 then @v3apositiontaking_1 when 2 then @v3apositiontaking_2 when 3 then @v3apositiontaking_3 when 20 then @v3apositiontaking_20  when 10 then @v3apositiontaking_10 else 0 end
                        
                        when 5 then case bettype when 1 then @v5apositiontaking_1 when 2 then @v5apositiontaking_2 when 3 then @v5apositiontaking_3 when 20 then @v5apositiontaking_20 when 9999 then @v5apositiontaking_9999  when 10 then @v5apositiontaking_10 else 0 end
                        
                        when 8 then case bettype when 1 then @v8apositiontaking_1 when 3 then @v8apositiontaking_3 when 20 then @v8apositiontaking_20  when 10 then @v8apositiontaking_10 else 0 end
                        
                        when 10 then case bettype when 1 then @v10apositiontaking_1 when 2 then @v10apositiontaking_2 when 3 then @v10apositiontaking_3 when 20 then @v10apositiontaking_20  when 10 then @v10apositiontaking_10 else 0 end
                        
                        when 11 then case bettype when 1 then @v11apositiontaking_1 when 20 then @v11apositiontaking_20  when 10 then @v11apositiontaking_10 else 0 end
                        
                        when 99 then case bettype when 1 then @v99apositiontaking_1 when 2 then @v99apositiontaking_2 when 3 then @v99apositiontaking_3 when 9 then @v99apositiontaking_9 when 20 then @v99apositiontaking_20  when 10 then @v99apositiontaking_10 when 9999 then @v99apositiontaking_9999 else 0 end
                       
                        else apositiontaking end,
        
        alivepositiontaking = case sporttype     when 1 then case bettype when 1 then @alivepositiontaking_1 when 3 then @alivepositiontaking_3 when 7 then @alivepositiontaking_7 when 8 then @alivepositiontaking_8 else alivepositiontaking end else alivepositiontaking end    
    where custid=@custid
    if (@@error <> 0)
    begin
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end    , @ErrCode = 105                     
        
        return
    end   

    -- 20131030@Johnson: Apply exec rep for recalculating pt on member
    EXEC dbo.Acc_CustSetting_07 @srecommend = @custid, @roleid = 4 

    /*
    exec dbo.Acc_CustomerUpdSuper_AutoPositiontaking @srecommend = @custid
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
    EXEC dbo.Acc_CustOverrideUpd
            @custid = @custid,
            @minpositiontaking_1 = 0,
            @minpositiontaking_2 = 0,
            @minpositiontaking_3 = 0,
            @minpositiontaking_4 = 0,
            @minpositiontaking_5 = 0,
            @minpositiontaking_6 = 0,
            @minpositiontaking_7 = 0,
            @minpositiontaking_8 = 0,
            @minpositiontaking_9 = 0,
            @minpositiontaking_10 = 0,
            @minpositiontaking_9999 = 0,
            @minlivepositiontaking_1 = 0,
            @minlivepositiontaking_3 = 0,
            @minlivepositiontaking_7 = 0,
            @minlivepositiontaking_8 = 0,
            @minv2positiontaking_1 = 0,
            @minv2positiontaking_2 = 0,
            @minv2positiontaking_3 = 0,
            @minv2positiontaking_7 = 0,
            @minv2positiontaking_8 = 0,
            --@minv2positiontaking_9 = 0,
            @minv2positiontaking_20 = 0,
            @minv2positiontaking_9999 = 0,

            @minv3positiontaking_1 = 0,
            @minv3positiontaking_2 = 0,
            @minv3positiontaking_3 = 0,
            @minv3positiontaking_20 = 0,

            @minv5positiontaking_1 = 0,
            @minv5positiontaking_2 = 0,
            @minv5positiontaking_3 = 0,
            @minv5positiontaking_20 = 0,
            @minv5positiontaking_9999 = 0,

            @minv8positiontaking_1 = 0,
            @minv8positiontaking_3 = 0,
            @minv8positiontaking_20 = 0,

            @minv10positiontaking_1 = 0,
            @minv10positiontaking_2 = 0,
            @minv10positiontaking_3 = 0,
            @minv10positiontaking_20 = 0,

            @minv11positiontaking_1 = 0,
            @minv11positiontaking_20 = 0,

            @minv99positiontaking_1 = 0,
            @minv99positiontaking_2 = 0,
            @minv99positiontaking_3 = 0,
            @minv99positiontaking_9 = 0,
            @minv99positiontaking_20 = 0,
			@minv99positiontaking_9999 = 0,                        
            
            @maxpositiontaking_1 = @spositiontaking_1,
            @maxpositiontaking_2 = @spositiontaking_2,
            @maxpositiontaking_3 = @spositiontaking_3,
            @maxpositiontaking_4 = @spositiontaking_4,
            @maxpositiontaking_5 = @spositiontaking_5,
            @maxpositiontaking_6 = @spositiontaking_6,
            @maxpositiontaking_7 = @spositiontaking_7,
            @maxpositiontaking_8 = @spositiontaking_8,
            @maxpositiontaking_9 = @spositiontaking_9,
            @maxpositiontaking_10 = @spositiontaking_10,
            @maxpositiontaking_9999 = @spositiontaking_9999,
            @maxlivepositiontaking_1 = @slivepositiontaking_1,
            @maxlivepositiontaking_3 = @slivepositiontaking_3,
            @maxlivepositiontaking_7 = @slivepositiontaking_7,
            @maxlivepositiontaking_8 = @slivepositiontaking_8,
            
            @maxv2positiontaking_1 = @v2spositiontaking_1,
            @maxv2positiontaking_2 = @v2spositiontaking_2,
            @maxv2positiontaking_3 = @v2spositiontaking_3,
            @maxv2positiontaking_7 = @v2spositiontaking_7,
            @maxv2positiontaking_8 = @v2spositiontaking_8,
            --@maxv2positiontaking_9 = @v2spositiontaking_9,
            @maxv2positiontaking_20 = @v2spositiontaking_20,
            @maxv2positiontaking_9999 = @v2spositiontaking_9999,

            @maxv3positiontaking_1 = @v3spositiontaking_1,
            @maxv3positiontaking_2 = @v3spositiontaking_2,
            @maxv3positiontaking_3 = @v3spositiontaking_3,
            @maxv3positiontaking_20 = @v3spositiontaking_20,

            @maxv5positiontaking_1 = @v5spositiontaking_1,
            @maxv5positiontaking_2 = @v5spositiontaking_2,
            @maxv5positiontaking_3 = @v5spositiontaking_3,
            @maxv5positiontaking_20 = @v5spositiontaking_20,
            @maxv5positiontaking_9999 = @v5spositiontaking_9999,

            @maxv8positiontaking_1 = @v8spositiontaking_1,
            @maxv8positiontaking_3 = @v8spositiontaking_3,
            @maxv8positiontaking_20 = @v8spositiontaking_20,

            @maxv10positiontaking_1 = @v10spositiontaking_1,
            @maxv10positiontaking_2 = @v10spositiontaking_2,
            @maxv10positiontaking_3 = @v10spositiontaking_3,
            @maxv10positiontaking_20 = @v10spositiontaking_20,

            @maxv11positiontaking_1 = @v11spositiontaking_1,
            @maxv11positiontaking_20 = @v11spositiontaking_20,

            @maxv99positiontaking_1 = @v99spositiontaking_1,
            @maxv99positiontaking_2 = @v99spositiontaking_2,
            @maxv99positiontaking_3 = @v99spositiontaking_3,
            @maxv99positiontaking_9 = @v99spositiontaking_9,
            @maxv99positiontaking_20 = @v99spositiontaking_20,
			@maxv99positiontaking_9999 = @v99spositiontaking_9999,                   
            
            -- Outright PT for sports
            @minv2positiontaking_10 = 0,
            @minv3positiontaking_10 = 0,
            @minv5positiontaking_10 = 0,
            @minv8positiontaking_10 = 0,
            @minv10positiontaking_10 = 0,
            @minv11positiontaking_10 = 0,
            @minv99positiontaking_10 = 0,
            
			@maxv2positiontaking_10 = @v2spositiontaking_10,
			@maxv3positiontaking_10 = @v3spositiontaking_10,
			@maxv5positiontaking_10 = @v5spositiontaking_10,
			@maxv8positiontaking_10 = @v8spositiontaking_10,
			@maxv10positiontaking_10 = @v10spositiontaking_10,
			@maxv11positiontaking_10 = @v11spositiontaking_10,
			@maxv99positiontaking_10 = @v99spositiontaking_10,
			
            @CheckPermission = 0,
            @UpdateMinPos = 0,
            @UpdateMaxPos = 1,
            @language = @language,
            @UserID = @UserID,
            @SubAccID = 0,
            @WriteLog = 0

    if (@@error <> 0)
    begin
        Select @ErrMsg = @UserName + ': '+
                        case @Language 
                            when 'E' then 'Update process is unsuccessful !'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
                        end, @ErrCode = 106             
        
        return
    end



    Declare @LogSPData varchar(MAX)

    Declare @TrackingValue2 varchar(MAX)

    Select @LogSPData = '<Acc_CustomerUpdSuper_PositionTaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

    '<s spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_1),space(1)) + '" ' +
    'spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_2),space(1)) + '" ' +
    'spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_3),space(1)) + '" ' +
    'spt_4="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_4),space(1)) + '" ' +
    'spt_5="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_5),space(1)) + '" ' +
    'spt_6="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_6),space(1)) + '" ' +
    'spt_7="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_7),space(1)) + '" ' +
    'spt_8="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_8),space(1)) + '" ' +
    'spt_9="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_9),space(1)) + '" ' +
    
    'spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_10),space(1)) + '" ' +
    -- Outright PT for sports
    'v2spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_10),space(1)) + '" ' +
    'v3spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v3spositiontaking_10),space(1)) + '" ' +
    'v5spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v5spositiontaking_10),space(1)) + '" ' +
    'v8spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v8spositiontaking_10),space(1)) + '" ' +
    'v10spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v10spositiontaking_10),space(1)) + '" ' +
    'v11spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v11spositiontaking_10),space(1)) + '" ' +
    'v99spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_10),space(1)) + '" ' +
    
    'spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@spositiontaking_9999),space(1)) + '" ' +
    'slivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@slivepositiontaking_1),space(1)) + '" ' +
    'slivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@slivepositiontaking_3),space(1)) + '" ' +
    'slivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@slivepositiontaking_7),space(1)) + '" ' +
    'slivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@slivepositiontaking_8),space(1)) + '" ' +

    'v2spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_1),space(1)) + '" ' +
    'v2spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_2),space(1)) + '" ' +
    'v2spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_3),space(1)) + '" ' +
    'v2spt_7="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_7),space(1)) + '" ' +
    'v2spt_8="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_8),space(1)) + '" ' +
    --'v2spt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_9),space(1)) + '" ' +
    'v2spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_20),space(1)) + '" ' +
    'v2spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v2spositiontaking_9999),space(1)) + '" ' +

    'v3spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v3spositiontaking_1),space(1)) + '" ' +
    'v3spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v3spositiontaking_2),space(1)) + '" ' +
    'v3spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v3spositiontaking_3),space(1)) + '" ' +
    'v3spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v3spositiontaking_20),space(1)) + '" ' +

    'v5spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v5spositiontaking_1),space(1)) + '" ' +
    'v5spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v5spositiontaking_2),space(1)) + '" ' +
    'v5spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v5spositiontaking_3),space(1)) + '" ' +
    'v5spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v5spositiontaking_20),space(1)) + '" ' +
    'v5spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v5spositiontaking_9999),space(1)) + '" ' +

    'v8spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v8spositiontaking_1),space(1)) + '" ' +
    'v8spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v8spositiontaking_3),space(1)) + '" ' +
    'v8spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v8spositiontaking_20),space(1)) + '" ' +

    'v10spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v10spositiontaking_1),space(1)) + '" ' +
    'v10spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v10spositiontaking_2),space(1)) + '" ' +
    'v10spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v10spositiontaking_3),space(1)) + '" ' +
    'v10spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v10spositiontaking_20),space(1)) + '" ' +

    'v11spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v11spositiontaking_1),space(1)) + '" ' +
    'v11spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v11spositiontaking_20),space(1)) + '" ' +

    'v99spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_1),space(1)) + '" ' +
    'v99spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_2),space(1)) + '" ' +
    'v99spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_3),space(1)) + '" ' +
    'v99spt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_9),space(1)) + '" ' +
    'v99spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_20),space(1)) + '" ' +
	'v99spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v99spositiontaking_9999),space(1)) + '" />' +    

    '<m mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_1),space(1)) + '" ' +
    'mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_2),space(1)) + '" ' +
    'mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_3),space(1)) + '" ' +
    'mpt_4="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_4),space(1)) + '" ' +
    'mpt_5="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_5),space(1)) + '" ' +
    'mpt_6="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_6),space(1)) + '" ' +
    'mpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_7),space(1)) + '" ' +
    'mpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_8),space(1)) + '" ' +
    'mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_9),space(1)) + '" ' +
    'mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_10),space(1)) + '" ' +
    -- Outright PT for sports
    'v2mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_10),space(1)) + '" ' +
    'v3mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v3mpositiontaking_10),space(1)) + '" ' +
    'v5mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v5mpositiontaking_10),space(1)) + '" ' +
    'v8mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v8mpositiontaking_10),space(1)) + '" ' +
    'v10mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v10mpositiontaking_10),space(1)) + '" ' +
    'v11mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v11mpositiontaking_10),space(1)) + '" ' +
    'v99mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_10),space(1)) + '" ' +
    
    
    'mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@mpositiontaking_9999),space(1)) + '" ' +
    'mlivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@mlivepositiontaking_1),space(1)) + '" ' +
    'mlivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@mlivepositiontaking_3),space(1)) + '" ' +
    'mlivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@mlivepositiontaking_7),space(1)) + '" ' +
    'mlivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@mlivepositiontaking_8),space(1)) + '" ' +

    'v2mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_1),space(1)) + '" ' +
    'v2mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_2),space(1)) + '" ' +
    'v2mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_3),space(1)) + '" ' +
    'v2mpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_7),space(1)) + '" ' +
    'v2mpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_8),space(1)) + '" ' +
    --'v2mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_9),space(1)) + '" ' +
    'v2mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_20),space(1)) + '" ' +
    'v2mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v2mpositiontaking_9999),space(1)) + '" ' +

    'v3mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v3mpositiontaking_1),space(1)) + '" ' +
    'v3mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v3mpositiontaking_2),space(1)) + '" ' +
    'v3mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v3mpositiontaking_3),space(1)) + '" ' +
    'v3mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v3mpositiontaking_20),space(1)) + '" ' +

    'v5mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v5mpositiontaking_1),space(1)) + '" ' +
    'v5mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v5mpositiontaking_2),space(1)) + '" ' +
    'v5mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v5mpositiontaking_3),space(1)) + '" ' +
    'v5mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v5mpositiontaking_20),space(1)) + '" ' +
    'v5mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v5mpositiontaking_9999),space(1)) + '" ' +

    'v8mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v8mpositiontaking_1),space(1)) + '" ' +
    'v8mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v8mpositiontaking_3),space(1)) + '" ' +
    'v8mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v8mpositiontaking_20),space(1)) + '" ' +

    'v10mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v10mpositiontaking_1),space(1)) + '" ' +
    'v10mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v10mpositiontaking_2),space(1)) + '" ' +
    'v10mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v10mpositiontaking_3),space(1)) + '" ' +
    'v10mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v10mpositiontaking_20),space(1)) + '" ' +

    'v11mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v11mpositiontaking_1),space(1)) + '" ' +
    'v11mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v11mpositiontaking_20),space(1)) + '" ' +

    'v99mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_1),space(1)) + '" ' +
    'v99mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_2),space(1)) + '" ' +
    'v99mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_3),space(1)) + '" ' +
    'v99mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_9),space(1)) + '" ' +
    'v99mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_20),space(1)) + '" ' +
	'v99mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_9999),space(1)) + '" />' +

    '<ag apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_1),space(1)) + '" ' +
    'apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_2),space(1)) + '" ' +
    'apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_3),space(1)) + '" ' +
    'apt_4="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_4),space(1)) + '" ' +
    'apt_5="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_5),space(1)) + '" ' +
    'apt_6="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_6),space(1)) + '" ' +
    'apt_7="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_7),space(1)) + '" ' +
    'apt_8="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_8),space(1)) + '" ' +
    'apt_9="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_9),space(1)) + '" ' +
    'apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_10),space(1)) + '" ' +
    -- Outright PT for sports
    'v2apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_10),space(1)) + '" ' +
    'v3apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v3apositiontaking_10),space(1)) + '" ' +
    'v5apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v5apositiontaking_10),space(1)) + '" ' +
    'v8apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v8apositiontaking_10),space(1)) + '" ' +
    'v10apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v10apositiontaking_10),space(1)) + '" ' +
    'v11apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v11apositiontaking_10),space(1)) + '" ' +
    'v99apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_10),space(1)) + '" ' +
    
    'apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@apositiontaking_9999),space(1)) + '" ' +
    'alivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@alivepositiontaking_1),space(1)) + '" ' +
    'alivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@alivepositiontaking_3),space(1)) + '" ' +
    'alivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@alivepositiontaking_7),space(1)) + '" ' +
    'alivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@alivepositiontaking_8),space(1)) + '" ' +

    'v2apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_1),space(1)) + '" ' +
    'v2apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_2),space(1)) + '" ' +
    'v2apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_3),space(1)) + '" ' +
    'v2apt_7="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_7),space(1)) + '" ' +
    'v2apt_8="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_8),space(1)) + '" ' +
    --'v2apt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_9),space(1)) + '" ' +
    'v2apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_20),space(1)) + '" ' +
    'v2apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v2apositiontaking_9999),space(1)) + '" ' +

    'v3apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v3apositiontaking_1),space(1)) + '" ' +
    'v3apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v3apositiontaking_2),space(1)) + '" ' +
    'v3apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v3apositiontaking_3),space(1)) + '" ' +
    'v3apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v3apositiontaking_20),space(1)) + '" ' +

    'v5apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v5apositiontaking_1),space(1)) + '" ' +
    'v5apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v5apositiontaking_2),space(1)) + '" ' +
    'v5apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v5apositiontaking_3),space(1)) + '" ' +
    'v5apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v5apositiontaking_20),space(1)) + '" ' +
    'v5apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v5apositiontaking_9999),space(1)) + '" ' +

    'v8apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v8apositiontaking_1),space(1)) + '" ' +
    'v8apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v8apositiontaking_3),space(1)) + '" ' +
    'v8apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v8apositiontaking_20),space(1)) + '" ' +

    'v10apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v10apositiontaking_1),space(1)) + '" ' +
    'v10apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v10apositiontaking_2),space(1)) + '" ' +
    'v10apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v10apositiontaking_3),space(1)) + '" ' +
    'v10apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v10apositiontaking_20),space(1)) + '" ' +

    'v11apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v11apositiontaking_1),space(1)) + '" ' +
    'v11apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v11apositiontaking_20),space(1)) + '" ' +

    'v99apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_1),space(1)) + '" ' +
    'v99apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_2),space(1)) + '" ' +
    'v99apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_3),space(1)) + '" ' +
    'v99apt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_3),space(1)) + '" ' +
    'v99apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_20),space(1)) + '" ' + 
	'v99apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v99apositiontaking_9999),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking>'   

    Select @TrackingValue2 = '<Acc_CustomerUpdSuper_PositionTaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

    '<s spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_1),space(1)) + '" ' +
    'spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_2),space(1)) + '" ' +
    'spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_3),space(1)) + '" ' +
    'spt_4="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_4),space(1)) + '" ' +
    'spt_5="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_5),space(1)) + '" ' +
    'spt_6="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_6),space(1)) + '" ' +
    'spt_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_7),space(1)) + '" ' +
    'spt_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_8),space(1)) + '" ' +
    'spt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_9),space(1)) + '" ' +
    'spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_10),space(1)) + '" ' +
    
    -- Outright PT for sports
    'v2spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_10),space(1)) + '" ' +
    'v3spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3spositiontaking_10),space(1)) + '" ' +
    'v5spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5spositiontaking_10),space(1)) + '" ' +
    'v8spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8spositiontaking_10),space(1)) + '" ' +
    'v10spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10spositiontaking_10),space(1)) + '" ' +
    'v11spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11spositiontaking_10),space(1)) + '" ' +
    'v99spt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_10),space(1)) + '" ' +
    
    'spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_spositiontaking_9999),space(1)) + '" ' +
    'slivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_slivepositiontaking_1),space(1)) + '" ' +
    'slivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_slivepositiontaking_3),space(1)) + '" ' +
    'slivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_slivepositiontaking_7),space(1)) + '" ' +
    'slivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_slivepositiontaking_8),space(1)) + '" ' +

    'v2spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_1),space(1)) + '" ' +
    'v2spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_2),space(1)) + '" ' +
    'v2spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_3),space(1)) + '" ' +
    'v2spt_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_7),space(1)) + '" ' +
    'v2spt_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_8),space(1)) + '" ' +
    --'v2spt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_9),space(1)) + '" ' +
    'v2spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_20),space(1)) + '" ' +
    'v2spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2spositiontaking_9999),space(1)) + '" ' +

    'v3spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3spositiontaking_1),space(1)) + '" ' +
    'v3spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3spositiontaking_2),space(1)) + '" ' +
    'v3spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3spositiontaking_3),space(1)) + '" ' +
    'v3spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3spositiontaking_20),space(1)) + '" ' +

    'v5spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5spositiontaking_1),space(1)) + '" ' +
    'v5spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5spositiontaking_2),space(1)) + '" ' +
    'v5spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5spositiontaking_3),space(1)) + '" ' +
    'v5spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5spositiontaking_20),space(1)) + '" ' +
    'v5spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5spositiontaking_9999),space(1)) + '" ' +

    'v8spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8spositiontaking_1),space(1)) + '" ' +
    'v8spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8spositiontaking_3),space(1)) + '" ' +
    'v8spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8spositiontaking_20),space(1)) + '" ' +

    'v10spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10spositiontaking_1),space(1)) + '" ' +
    'v10spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10spositiontaking_2),space(1)) + '" ' +
    'v10spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10spositiontaking_3),space(1)) + '" ' +
    'v10spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10spositiontaking_20),space(1)) + '" ' +

    'v11spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11spositiontaking_1),space(1)) + '" ' +
    'v11spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11spositiontaking_20),space(1)) + '" ' +

    'v99spt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_1),space(1)) + '" ' +
    'v99spt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_2),space(1)) + '" ' +
    'v99spt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_3),space(1)) + '" ' +
    'v99spt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_9),space(1)) + '" ' +
    'v99spt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_20),space(1)) + '" ' +
	'v99spt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99spositiontaking_9999),space(1)) + '" />' + 

    '<m mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_1),space(1)) + '" ' +
    'mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_2),space(1)) + '" ' +
    'mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_3),space(1)) + '" ' +
    'mpt_4="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_4),space(1)) + '" ' +
    'mpt_5="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_5),space(1)) + '" ' +
    'mpt_6="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_6),space(1)) + '" ' +
    'mpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_7),space(1)) + '" ' +
    'mpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_8),space(1)) + '" ' +
    'mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_9),space(1)) + '" ' +
    'mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_10),space(1)) + '" ' +
    -- Outright PT for sports
    'v2mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_10),space(1)) + '" ' +
    'v3mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3mpositiontaking_10),space(1)) + '" ' +
    'v5mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5mpositiontaking_10),space(1)) + '" ' +
    'v8mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8mpositiontaking_10),space(1)) + '" ' +
    'v10mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10mpositiontaking_10),space(1)) + '" ' +
    'v11mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11mpositiontaking_10),space(1)) + '" ' +
    'v99mpt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_10),space(1)) + '" ' +
    
    'mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mpositiontaking_9999),space(1)) + '" ' +
    'mlivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mlivepositiontaking_1),space(1)) + '" ' +
    'mlivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mlivepositiontaking_3),space(1)) + '" ' +
    'mlivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mlivepositiontaking_7),space(1)) + '" ' +
    'mlivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_mlivepositiontaking_8),space(1)) + '" ' +

    'v2mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_1),space(1)) + '" ' +
    'v2mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_2),space(1)) + '" ' +
    'v2mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_3),space(1)) + '" ' +
    'v2mpt_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_7),space(1)) + '" ' +
    'v2mpt_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_8),space(1)) + '" ' +
    --'v2mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_9),space(1)) + '" ' +
    'v2mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_20),space(1)) + '" ' +
    'v2mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2mpositiontaking_9999),space(1)) + '" ' +

    'v3mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3mpositiontaking_1),space(1)) + '" ' +
    'v3mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3mpositiontaking_2),space(1)) + '" ' +
    'v3mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3mpositiontaking_3),space(1)) + '" ' +
    'v3mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3mpositiontaking_20),space(1)) + '" ' +

    'v5mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5mpositiontaking_1),space(1)) + '" ' +
    'v5mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5mpositiontaking_2),space(1)) + '" ' +
    'v5mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5mpositiontaking_3),space(1)) + '" ' +
    'v5mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5mpositiontaking_20),space(1)) + '" ' +
    'v5mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5mpositiontaking_9999),space(1)) + '" ' +

    'v8mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8mpositiontaking_1),space(1)) + '" ' +
    'v8mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8mpositiontaking_3),space(1)) + '" ' +
    'v8mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8mpositiontaking_20),space(1)) + '" ' +

    'v10mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10mpositiontaking_1),space(1)) + '" ' +
    'v10mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10mpositiontaking_2),space(1)) + '" ' +
    'v10mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10mpositiontaking_3),space(1)) + '" ' +
    'v10mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10mpositiontaking_20),space(1)) + '" ' +

    'v11mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11mpositiontaking_1),space(1)) + '" ' +
    'v11mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11mpositiontaking_20),space(1)) + '" ' +

    'v99mpt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_1),space(1)) + '" ' +
    'v99mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_2),space(1)) + '" ' +
    'v99mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_3),space(1)) + '" ' +
    'v99mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_9),space(1)) + '" ' +
    'v99mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_20),space(1)) + '" ' +
	'v99mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_9999),space(1)) + '" />' +   

    '<ag apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_1),space(1)) + '" ' +
    'apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_2),space(1)) + '" ' +
    'apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_3),space(1)) + '" ' +
    'apt_4="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_4),space(1)) + '" ' +
    'apt_5="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_5),space(1)) + '" ' +
    'apt_6="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_6),space(1)) + '" ' +
    'apt_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_7),space(1)) + '" ' +
    'apt_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_8),space(1)) + '" ' +
    'apt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_9),space(1)) + '" ' +
    'apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_10),space(1)) + '" ' +
    
    -- Outright PT for sports
    'v2apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_10),space(1)) + '" ' +
    'v3apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3apositiontaking_10),space(1)) + '" ' +
    'v5apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5apositiontaking_10),space(1)) + '" ' +
    'v8apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8apositiontaking_10),space(1)) + '" ' +
    'v10apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10apositiontaking_10),space(1)) + '" ' +
    'v11apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11apositiontaking_10),space(1)) + '" ' +
    'v99apt_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_10),space(1)) + '" ' +
    
    'apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_apositiontaking_9999),space(1)) + '" ' +
    'alivept_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_alivepositiontaking_1),space(1)) + '" ' +
    'alivept_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_alivepositiontaking_3),space(1)) + '" ' +
    'alivept_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_alivepositiontaking_7),space(1)) + '" ' +
    'alivept_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_alivepositiontaking_8),space(1)) + '" ' +

    'v2apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_1),space(1)) + '" ' +
    'v2apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_2),space(1)) + '" ' +
    'v2apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_3),space(1)) + '" ' +
    'v2apt_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_7),space(1)) + '" ' +
    'v2apt_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_8),space(1)) + '" ' +
    --'v2apt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_9),space(1)) + '" ' +
    'v2apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_20),space(1)) + '" ' +
    'v2apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v2apositiontaking_9999),space(1)) + '" ' +

    'v3apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3apositiontaking_1),space(1)) + '" ' +
    'v3apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3apositiontaking_2),space(1)) + '" ' +
    'v3apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3apositiontaking_3),space(1)) + '" ' +
    'v3apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v3apositiontaking_20),space(1)) + '" ' +

    'v5apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5apositiontaking_1),space(1)) + '" ' +
    'v5apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5apositiontaking_2),space(1)) + '" ' +
    'v5apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5apositiontaking_3),space(1)) + '" ' +
    'v5apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5apositiontaking_20),space(1)) + '" ' +
    'v5apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v5apositiontaking_9999),space(1)) + '" ' +

    'v8apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8apositiontaking_1),space(1)) + '" ' +
    'v8apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8apositiontaking_3),space(1)) + '" ' +
    'v8apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v8apositiontaking_20),space(1)) + '" ' +

    'v10apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10apositiontaking_1),space(1)) + '" ' +
    'v10apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10apositiontaking_2),space(1)) + '" ' +
    'v10apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10apositiontaking_3),space(1)) + '" ' +
    'v10apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v10apositiontaking_20),space(1)) + '" ' +

    'v11apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11apositiontaking_1),space(1)) + '" ' +
    'v11apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v11apositiontaking_20),space(1)) + '" ' +

    'v99apt_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_1),space(1)) + '" ' +
    'v99apt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_2),space(1)) + '" ' +
    'v99apt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_3),space(1)) + '" ' +
    'v99apt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_9),space(1)) + '" ' +
    'v99apt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_20),space(1)) + '" ' + 
	'v99apt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99apositiontaking_9999),space(1)) + '" /></Acc_CustomerUpdSuper_PositionTaking>'
    
    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)

	--Log positiontaking
    EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 410,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration   

	DROP TABLE #tmp_Bettype
	DROP TABLE #tmp_Sports
END
GO