/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_Master]
	@CustID INT,--memberid

	--m1
	@mpositiontaking_1 SMALLMONEY OUTPUT,
	@mpositiontaking_2 SMALLMONEY OUTPUT,
	@mpositiontaking_3 SMALLMONEY OUTPUT,
	@mpositiontaking_4 SMALLMONEY OUTPUT,
	@mpositiontaking_5 SMALLMONEY OUTPUT,
	@mpositiontaking_6 SMALLMONEY OUTPUT,
	@mpositiontaking_7 SMALLMONEY OUTPUT,
	@mpositiontaking_8 SMALLMONEY OUTPUT,
	@mpositiontaking_9 SMALLMONEY OUTPUT,
	@mpositiontaking_10 SMALLMONEY OUTPUT,
	@mpositiontaking_9999 SMALLMONEY = 0 OUTPUT,
	@mlivepositiontaking_1 SMALLMONEY OUTPUT,
	@mlivepositiontaking_3 SMALLMONEY OUTPUT,
	@mlivepositiontaking_7 SMALLMONEY OUTPUT,
	@mlivepositiontaking_8 SMALLMONEY OUTPUT,
	
	@v2mpositiontaking_1 SMALLMONEY OUTPUT,
	@v2mpositiontaking_2 SMALLMONEY OUTPUT,
	@v2mpositiontaking_3 SMALLMONEY OUTPUT,
	@v2mpositiontaking_7 SMALLMONEY OUTPUT,
	@v2mpositiontaking_8 SMALLMONEY OUTPUT,
--	@v2mpositiontaking_9 SMALLMONEY OUTPUT,
	@v2mpositiontaking_20 SMALLMONEY OUTPUT,
	@v2mpositiontaking_9999 SMALLMONEY OUTPUT,

	@v3mpositiontaking_1 SMALLMONEY OUTPUT,
	@v3mpositiontaking_2 SMALLMONEY OUTPUT,
	@v3mpositiontaking_3 SMALLMONEY OUTPUT,
	@v3mpositiontaking_20 SMALLMONEY OUTPUT,

	@v5mpositiontaking_1 SMALLMONEY OUTPUT,
	@v5mpositiontaking_2 SMALLMONEY OUTPUT,
	@v5mpositiontaking_3 SMALLMONEY OUTPUT,
	@v5mpositiontaking_20 SMALLMONEY OUTPUT,
	@v5mpositiontaking_9999 SMALLMONEY = 0 OUTPUT,

	@v8mpositiontaking_1 SMALLMONEY OUTPUT,
	@v8mpositiontaking_3 SMALLMONEY OUTPUT,
	@v8mpositiontaking_20 SMALLMONEY OUTPUT,

	@v10mpositiontaking_1 SMALLMONEY OUTPUT,
	@v10mpositiontaking_2 SMALLMONEY OUTPUT,
	@v10mpositiontaking_3 SMALLMONEY OUTPUT,
	@v10mpositiontaking_20 SMALLMONEY OUTPUT,

	@v11mpositiontaking_1 SMALLMONEY OUTPUT,
	@v11mpositiontaking_20 SMALLMONEY OUTPUT,

	@v99mpositiontaking_1 SMALLMONEY OUTPUT,
	@v99mpositiontaking_2 SMALLMONEY OUTPUT,
	@v99mpositiontaking_3 SMALLMONEY OUTPUT,
	@v99mpositiontaking_20 SMALLMONEY OUTPUT,
	@v99mpositiontaking_9999 SMALLMONEY OUTPUT,
	-- mixed sports
	@v99mpositiontaking_9 SMALLMONEY OUTPUT,
	
	--im2
	@isauto_mpositiontaking_1 BIT = 0,
	@isauto_mpositiontaking_2 BIT = 0,
	@isauto_mpositiontaking_3 BIT = 0,
	@isauto_mpositiontaking_4 BIT = 0,
	@isauto_mpositiontaking_5 BIT= 0,
	@isauto_mpositiontaking_6 BIT = 0,
	@isauto_mpositiontaking_7 BIT = 0,
	@isauto_mpositiontaking_8 BIT = 0,
	@isauto_mpositiontaking_9 BIT = 0,
	@isauto_mpositiontaking_10 BIT = 0,
	@isauto_mpositiontaking_9999 BIT = 0,
	@isauto_mlivepositiontaking_1 BIT = 0,
	@isauto_mlivepositiontaking_3 BIT = 0,
	@isauto_mlivepositiontaking_7 BIT = 0,
	@isauto_mlivepositiontaking_8 BIT = 0,
	
	@isauto_v2mpositiontaking_1 BIT = 0,
	@isauto_v2mpositiontaking_2 BIT = 0,
	@isauto_v2mpositiontaking_3 BIT = 0,
	@isauto_v2mpositiontaking_7 BIT = 0,
	@isauto_v2mpositiontaking_8 BIT = 0,
--	@isauto_v2mpositiontaking_9 BIT = 0,
	@isauto_v2mpositiontaking_20 BIT = 0,
	@isauto_v2mpositiontaking_9999 BIT = 0,
	
	@isauto_v3mpositiontaking_1 BIT = 0,
	@isauto_v3mpositiontaking_2 BIT = 0,
	@isauto_v3mpositiontaking_3 BIT = 0,
	@isauto_v3mpositiontaking_20 BIT = 0,
	
	@isauto_v5mpositiontaking_1 BIT = 0,
	@isauto_v5mpositiontaking_2 BIT = 0,
	@isauto_v5mpositiontaking_3 BIT = 0,
	@isauto_v5mpositiontaking_20 BIT = 0,
	@isauto_v5mpositiontaking_9999 BIT = 0,
	
	@isauto_v8mpositiontaking_1 BIT = 0,
	@isauto_v8mpositiontaking_3 BIT = 0,
	@isauto_v8mpositiontaking_20 BIT = 0,
	
	@isauto_v10mpositiontaking_1 BIT = 0,
	@isauto_v10mpositiontaking_2 BIT = 0,
	@isauto_v10mpositiontaking_3 BIT = 0,
	@isauto_v10mpositiontaking_20 BIT = 0,
	
	@isauto_v11mpositiontaking_1 BIT = 0,
	@isauto_v11mpositiontaking_20 BIT = 0,

	@isauto_v99mpositiontaking_1 BIT = 0,
	@isauto_v99mpositiontaking_2 BIT = 0,
	@isauto_v99mpositiontaking_3 BIT = 0,
	@isauto_v99mpositiontaking_20 BIT = 0,	
	@isauto_v99mpositiontaking_9999 BIT = 0,	
	-- mixed sports
	@isauto_v99mpositiontaking_9 BIT = 0,
	
	--im1
	@isauto_mpositiontaking_mem_1 BIT = 0,
	@isauto_mpositiontaking_mem_2 BIT = 0,
	@isauto_mpositiontaking_mem_3 BIT = 0,
	@isauto_mpositiontaking_mem_4 BIT = 0,
	@isauto_mpositiontaking_mem_5 BIT= 0,
	@isauto_mpositiontaking_mem_6 BIT = 0,
	@isauto_mpositiontaking_mem_7 BIT = 0,
	@isauto_mpositiontaking_mem_8 BIT = 0,
	@isauto_mpositiontaking_mem_9 BIT = 0,
	@isauto_mpositiontaking_mem_10 BIT = 0,
	@isauto_mpositiontaking_mem_9999 BIT = 0,
	@isauto_mlivepositiontaking_mem_1 BIT = 0,
	@isauto_mlivepositiontaking_mem_3 BIT = 0,
	@isauto_mlivepositiontaking_mem_7 BIT = 0,
	@isauto_mlivepositiontaking_mem_8 BIT = 0,
	
	@isauto_v2mpositiontaking_mem_1 BIT = 0,
	@isauto_v2mpositiontaking_mem_2 BIT = 0,
	@isauto_v2mpositiontaking_mem_3 BIT = 0,
	@isauto_v2mpositiontaking_mem_7 BIT = 0,
	@isauto_v2mpositiontaking_mem_8 BIT = 0,
--	@isauto_v2mpositiontaking_mem_9 BIT = 0,
	@isauto_v2mpositiontaking_mem_20 BIT = 0,
	@isauto_v2mpositiontaking_mem_9999 BIT = 0,
	
	@isauto_v3mpositiontaking_mem_1 BIT = 0,
	@isauto_v3mpositiontaking_mem_2 BIT = 0,
	@isauto_v3mpositiontaking_mem_3 BIT = 0,
	@isauto_v3mpositiontaking_mem_20 BIT = 0,
	
	@isauto_v5mpositiontaking_mem_1 BIT = 0,
	@isauto_v5mpositiontaking_mem_2 BIT = 0,
	@isauto_v5mpositiontaking_mem_3 BIT = 0,
	@isauto_v5mpositiontaking_mem_20 BIT = 0,
	@isauto_v5mpositiontaking_mem_9999 BIT = 0,
	
	@isauto_v8mpositiontaking_mem_1 BIT = 0,
	@isauto_v8mpositiontaking_mem_3 BIT = 0,
	@isauto_v8mpositiontaking_mem_20 BIT = 0,
	
	@isauto_v10mpositiontaking_mem_1 BIT = 0,
	@isauto_v10mpositiontaking_mem_2 BIT = 0,
	@isauto_v10mpositiontaking_mem_3 BIT = 0,
	@isauto_v10mpositiontaking_mem_20 BIT = 0,
	
	@isauto_v11mpositiontaking_mem_1 BIT = 0,
	@isauto_v11mpositiontaking_mem_20 BIT = 0,

	@isauto_v99mpositiontaking_mem_1 BIT = 0,
	@isauto_v99mpositiontaking_mem_2 BIT = 0,
	@isauto_v99mpositiontaking_mem_3 BIT = 0,
	@isauto_v99mpositiontaking_mem_20 BIT = 0,	
	@isauto_v99mpositiontaking_mem_9999 BIT = 0,	
	-- mixed sports
	@isauto_v99mpositiontaking_mem_9 BIT = 0,
	
	--um1
	@auto_mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_2 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_4 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_5 SMALLMONEY= 0,
	@auto_mpositiontaking_mem_6 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_7 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_8 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_9 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_mpositiontaking_mem_9999 SMALLMONEY = 0,
	@auto_mlivepositiontaking_mem_1 SMALLMONEY = 0,
	@auto_mlivepositiontaking_mem_3 SMALLMONEY = 0,
	@auto_mlivepositiontaking_mem_7 SMALLMONEY = 0,
	@auto_mlivepositiontaking_mem_8 SMALLMONEY = 0,
	
	@auto_v2mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v2mpositiontaking_mem_2 SMALLMONEY = 0,
	@auto_v2mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_v2mpositiontaking_mem_7 SMALLMONEY = 0,
	@auto_v2mpositiontaking_mem_8 SMALLMONEY = 0,
--	@auto_v2mpositiontaking_mem_9 SMALLMONEY = 0,
	@auto_v2mpositiontaking_mem_20 SMALLMONEY = 0,
	@auto_v2mpositiontaking_mem_9999 SMALLMONEY = 0,
	
	@auto_v3mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v3mpositiontaking_mem_2 SMALLMONEY = 0,
	@auto_v3mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_v3mpositiontaking_mem_20 SMALLMONEY = 0,
	
	@auto_v5mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v5mpositiontaking_mem_2 SMALLMONEY = 0,
	@auto_v5mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_v5mpositiontaking_mem_20 SMALLMONEY = 0,
	@auto_v5mpositiontaking_mem_9999 SMALLMONEY = 0,
	
	@auto_v8mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v8mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_v8mpositiontaking_mem_20 SMALLMONEY = 0,
	
	@auto_v10mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v10mpositiontaking_mem_2 SMALLMONEY = 0,
	@auto_v10mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_v10mpositiontaking_mem_20 SMALLMONEY = 0,
	
	@auto_v11mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v11mpositiontaking_mem_20 SMALLMONEY = 0,

	@auto_v99mpositiontaking_mem_1 SMALLMONEY = 0,
	@auto_v99mpositiontaking_mem_2 SMALLMONEY = 0,
	@auto_v99mpositiontaking_mem_3 SMALLMONEY = 0,
	@auto_v99mpositiontaking_mem_20 SMALLMONEY = 0,	
	@auto_v99mpositiontaking_mem_9999 SMALLMONEY = 0,	
	-- mixed sports
	@auto_v99mpositiontaking_mem_9 SMALLMONEY = 0,
	
	@v2mpositiontaking_10 SMALLMONEY OUTPUT,
	@v3mpositiontaking_10 SMALLMONEY OUTPUT,
	@v5mpositiontaking_10 SMALLMONEY OUTPUT,
	@v8mpositiontaking_10 SMALLMONEY OUTPUT,
	@v10mpositiontaking_10 SMALLMONEY OUTPUT,
	@v11mpositiontaking_10 SMALLMONEY OUTPUT,
	@v99mpositiontaking_10 SMALLMONEY OUTPUT,
	
	
	@isauto_v2mpositiontaking_10 BIT = 0,
	@isauto_v3mpositiontaking_10 BIT = 0,
	@isauto_v5mpositiontaking_10 BIT = 0,
	@isauto_v8mpositiontaking_10 BIT = 0,
	@isauto_v10mpositiontaking_10 BIT = 0,
	@isauto_v11mpositiontaking_10 BIT = 0,
	@isauto_v99mpositiontaking_10 BIT = 0,

	@auto_v2mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_v3mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_v5mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_v8mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_v10mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_v11mpositiontaking_mem_10 SMALLMONEY = 0,
	@auto_v99mpositiontaking_mem_10 SMALLMONEY = 0,
	
	@isauto_v2mpositiontaking_mem_10 BIT = 0,
	@isauto_v3mpositiontaking_mem_10 BIT = 0,
	@isauto_v5mpositiontaking_mem_10 BIT = 0,
	@isauto_v8mpositiontaking_mem_10 BIT = 0,
	@isauto_v10mpositiontaking_mem_10 BIT = 0,
	@isauto_v11mpositiontaking_mem_10 BIT = 0,
	@isauto_v99mpositiontaking_mem_10 BIT = 0,
	
	
	@UpdateMultiple BIT = 0,
	@UpdatePositiontaking BIT = 1,
	@UpdatePositiontakingv2 BIT = 1,
	@UpdatePositiontakingv3 BIT = 1,
	@UpdatePositiontakingv5 BIT = 1,
	@UpdatePositiontakingv8 BIT = 1,
	@UpdatePositiontakingv10 BIT = 1,
	@UpdatePositiontakingv11 BIT = 1,
	@UpdatePositiontakingv99 BIT = 1,
	@UpdatePositiontakingv99MP BIT = 1,
	
	@SystemID		TINYINT=1,

	@UserID INT,--masterid	
	
	@Language VARCHAR(2) = 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@IP VARCHAR(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090122@[creator]
Task : Master edit member
DB: DBTXN/bodb02
Original: [Acc_CustomerUpdMaster_Member]

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3, hard code copy min/max/maxperbet/PT for 201 from 2 sporttype
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
				Write log subaccname instead of subaccid.
    - 20090616@Phuc: Auto master PT on member level.
					 Enrich error message.(-101: general info, -102: closed, -103: suspended, 
						-104: credit, -105: commission, -106: min/max bet, -107: positiontaking
						-108: disable FI, -109: disableHR)
	- 20090801@Shifu: check disabled user
	- 20090806@Phuc: remove check m1=min(m3-a2,m1)
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091125@Terry: check disabled casino
	- 20100112@Kiwi: Amend to write log in xml format.
	- 20100730@Henry: invoke execute to bodbExtAccNet,wsv_xnap
	- 20100915@Lukas:	- Add number game setting
						- Add mixed sports setting
						- Remove mix parlay of basketball
	- 20100925@Lukas:	check upline status when update member status
	- 20101019@Henry: Record execution time
	- 20110603@Amy: Write Log Old value and IP, Sub-Acc for PT section
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20110831@Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20111017@TOM: Apply Multiple Edit PT.
	- 20120704@Johnson: Remove setting hard code of number group
	- 20120831@Johnson: check m1_max = min(m3,m4) 
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20131030@Johnson: Apply execrep when update pt on member[redmine:#3244]
	- 20131016@Kathy: Add HR Fixed Odds(154) [Redmine:#6505]
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)	
	- 20131113@Johnson: Use execrept Acc_CustSetting_00/Acc_CustSetting3rd_00 to correct after update pt on member 
	- 20140225@Johnson: check m1, um1 with m1_min [redmine:#11562]
						apply new m1_max is m3-a1 not apply range !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1) [Redmine:#12953]
    - 20140630@Logan: Add new bettype BetRadar for Soccer and Tennis(9999) [Redmine: #18432]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Use temp table for sports, bettype table)
	- 20150806@Johnson:  Write log value from db if not change when update multiple [Redmine: #40880]				
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]  			
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170628@Winnie: Apply color for closed account - [Redmine: 74494]
	- 20170807@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180326@Winnie: Customer Setting - urgent fix to support for long bettype name. [RedmineID: #91216]	
	- 20181122@Johnson: remove redundant log status [redmine: #105164]
	- 20190508@Johnson: fix bug for missing bettype of Number Game [redmine: #112318]
	- 20190510@Johnson: remove suspend status on setting page [redmine: #105587]
	- 20190716@Winnie: Hotfix view log [redmine: #116524]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20201028@Eden: Adjust new pt for 789y [Redmine: #143764]
	- 20210111@Johnson: dont allow update Master AutoPT when DisableAutoMPT = 1 [redmine:#148027]
	- 20210714@Tina: Lock account & indirect close account [redmine: #148600]
	- 20220620@Johnson: define temp table to avoid dump db [redmine:#174035]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230921@Johnson: extend MaxPT = 0.93 [redmine:194132]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	/*
	if not exists (select 1 from custinfo with (nolock) where custid = @custid and srecommend in (181940,197461))
	BEGIN
		declare @ErrMsg varchar(200)
		Select @ErrMsg = 'Sorry, please try again later.'
		RaisError (@ErrMsg, 16, 1)
		return
	END
	*/
	----- Elodie @ 01 JUN 2015 -------------------
	CREATE TABLE #tmp_Sports(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	CREATE TABLE #tmp_Bettype(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	
	BEGIN TRY
		INSERT INTO #tmp_Sports(ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID
		FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBAGE')	
	END TRY
	BEGIN CATCH
		IF OBJECT_ID(N'tempdb..#tmp_Sports') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Sports
			INSERT INTO #tmp_Sports(ID, Name, IsDisabled, IBCBettypeID)
			SELECT ID, Name, IsDisabled, IBCBettypeID
			FROM dbo.f_GetSportTypeBetTypeGameType(1,'DBTXN')	
		END
	END CATCH

	BEGIN TRY			
		INSERT INTO #tmp_Bettype(ID, Name, IsDisabled, IBCBettypeID)
		SELECT ID, Name, IsDisabled, IBCBettypeID		
		FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBAGE')	
	END TRY
	BEGIN CATCH		
		IF OBJECT_ID(N'tempdb..#tmp_Bettype') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #tmp_Bettype
			INSERT INTO #tmp_Bettype(ID, Name, IsDisabled, IBCBettypeID)
			SELECT ID, Name, IsDisabled, IBCBettypeID	
			FROM dbo.f_GetSportTypeBetTypeGameType(2,'DBTXN')	
		END
	END CATCH
----- /Elodie @ 01 JUN 2015 -------------------

DECLARE @ErrType varchar(1000), @ErrCode_cur int, @ErrMsg_cur NVARCHAR(4000)
SELECT @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

DECLARE @old_closed BIT,
	@recommend INT,
	@mrecommend INT,
	@srecommend INT
	
SELECT @old_closed = closed, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend, @UserName = username
FROM custinfo WITH (NOLOCK) WHERE custid = @custid

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

--Update Customer Info First.
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

-----------------------------------------------------------------------------------------------------------------------------------
--BEGIN Update Position Taking
if	@UpdatePositiontaking   = 1  or
	@UpdatePositiontakingv2   = 1  or
	@UpdatePositiontakingv3   = 1  or
	@UpdatePositiontakingv5   = 1  or
	@UpdatePositiontakingv8   = 1  or
	@UpdatePositiontakingv10   = 1  or
	@UpdatePositiontakingv11   = 1  or
	@UpdatePositiontakingv99   = 1  or
	@UpdatePositiontakingv99MP = 1 
	
	BEGIN--Update Position Taking
		DECLARE 
		--a1
		@apositiontaking_1 SMALLMONEY,
		@apositiontaking_2 SMALLMONEY,
		@apositiontaking_3 SMALLMONEY,
		@apositiontaking_4 SMALLMONEY,
		@apositiontaking_5 SMALLMONEY,
		@apositiontaking_6 SMALLMONEY,
		@apositiontaking_7 SMALLMONEY,
		@apositiontaking_8 SMALLMONEY,
		@apositiontaking_9 SMALLMONEY,
		@apositiontaking_10 SMALLMONEY,
		@apositiontaking_9999 SMALLMONEY,
		@alivepositiontaking_1 SMALLMONEY,
		@alivepositiontaking_3 SMALLMONEY,
		@alivepositiontaking_7 SMALLMONEY,
		@alivepositiontaking_8 SMALLMONEY,
		
		@v2apositiontaking_1 SMALLMONEY,
		@v2apositiontaking_2 SMALLMONEY,
		@v2apositiontaking_3 SMALLMONEY,
		@v2apositiontaking_7 SMALLMONEY,
		@v2apositiontaking_8 SMALLMONEY,
	--	@v2apositiontaking_9 SMALLMONEY,
		@v2apositiontaking_20 SMALLMONEY,
		@v2apositiontaking_9999 SMALLMONEY,

		@v3apositiontaking_1 SMALLMONEY,
		@v3apositiontaking_2 SMALLMONEY,
		@v3apositiontaking_3 SMALLMONEY,
		@v3apositiontaking_20 SMALLMONEY,

		@v5apositiontaking_1 SMALLMONEY,
		@v5apositiontaking_2 SMALLMONEY,
		@v5apositiontaking_3 SMALLMONEY,
		@v5apositiontaking_20 SMALLMONEY,
		@v5apositiontaking_9999 SMALLMONEY,

		@v8apositiontaking_1 SMALLMONEY,
		@v8apositiontaking_3 SMALLMONEY,
		@v8apositiontaking_20 SMALLMONEY,

		@v10apositiontaking_1 SMALLMONEY,
		@v10apositiontaking_2 SMALLMONEY,
		@v10apositiontaking_3 SMALLMONEY,
		@v10apositiontaking_20 SMALLMONEY,

		@v11apositiontaking_1 SMALLMONEY,
		@v11apositiontaking_20 SMALLMONEY,
		
		@v99apositiontaking_1 SMALLMONEY,
		@v99apositiontaking_2 SMALLMONEY,
		@v99apositiontaking_3 SMALLMONEY,
		@v99apositiontaking_20 SMALLMONEY,
		@v99apositiontaking_9999 SMALLMONEY,
		--- mixed sports
		@v99apositiontaking_9 SMALLMONEY,	
				
		--a2
		@max_apositiontaking_1 SMALLMONEY,
		@max_apositiontaking_2 SMALLMONEY,
		@max_apositiontaking_3 SMALLMONEY,
		@max_apositiontaking_4 SMALLMONEY,
		@max_apositiontaking_5 SMALLMONEY,
		@max_apositiontaking_6 SMALLMONEY,
		@max_apositiontaking_7 SMALLMONEY,
		@max_apositiontaking_8 SMALLMONEY,
		@max_apositiontaking_9 SMALLMONEY,
		@max_apositiontaking_10 SMALLMONEY,
		@max_apositiontaking_9999 SMALLMONEY,
		@max_alivepositiontaking_1 SMALLMONEY,
		@max_alivepositiontaking_3 SMALLMONEY,
		@max_alivepositiontaking_7 SMALLMONEY,
		@max_alivepositiontaking_8 SMALLMONEY,
		
		@max_v2apositiontaking_1 SMALLMONEY,
		@max_v2apositiontaking_2 SMALLMONEY,
		@max_v2apositiontaking_3 SMALLMONEY,
		@max_v2apositiontaking_7 SMALLMONEY,
		@max_v2apositiontaking_8 SMALLMONEY,
	--	@max_v2apositiontaking_9 SMALLMONEY,
		@max_v2apositiontaking_20 SMALLMONEY,
		@max_v2apositiontaking_9999 SMALLMONEY,

		@max_v3apositiontaking_1 SMALLMONEY,
		@max_v3apositiontaking_2 SMALLMONEY,
		@max_v3apositiontaking_3 SMALLMONEY,
		@max_v3apositiontaking_20 SMALLMONEY,

		@max_v5apositiontaking_1 SMALLMONEY,
		@max_v5apositiontaking_2 SMALLMONEY,
		@max_v5apositiontaking_3 SMALLMONEY,
		@max_v5apositiontaking_20 SMALLMONEY,
		@max_v5apositiontaking_9999 SMALLMONEY,

		@max_v8apositiontaking_1 SMALLMONEY,
		@max_v8apositiontaking_3 SMALLMONEY,
		@max_v8apositiontaking_20 SMALLMONEY,

		@max_v10apositiontaking_1 SMALLMONEY,
		@max_v10apositiontaking_2 SMALLMONEY,
		@max_v10apositiontaking_3 SMALLMONEY,
		@max_v10apositiontaking_20 SMALLMONEY,

		@max_v11apositiontaking_1 SMALLMONEY,
		@max_v11apositiontaking_20 SMALLMONEY,
		
		@max_v99apositiontaking_1 SMALLMONEY,
		@max_v99apositiontaking_2 SMALLMONEY,
		@max_v99apositiontaking_3 SMALLMONEY,
		@max_v99apositiontaking_20 SMALLMONEY,
		@max_v99apositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@max_v99apositiontaking_9 SMALLMONEY,
			
		--old_m1	
		@old_mpositiontaking_1 SMALLMONEY,
		@old_mpositiontaking_2 SMALLMONEY,
		@old_mpositiontaking_3 SMALLMONEY,
		@old_mpositiontaking_4 SMALLMONEY,
		@old_mpositiontaking_5 SMALLMONEY,
		@old_mpositiontaking_6 SMALLMONEY,
		@old_mpositiontaking_7 SMALLMONEY,
		@old_mpositiontaking_8 SMALLMONEY,
		@old_mpositiontaking_9 SMALLMONEY,
		@old_mpositiontaking_10 SMALLMONEY,
		@old_mpositiontaking_9999 SMALLMONEY,
		
		@old_mlivepositiontaking_1 SMALLMONEY,
		@old_mlivepositiontaking_3 SMALLMONEY,
		@old_mlivepositiontaking_7 SMALLMONEY,
		@old_mlivepositiontaking_8 SMALLMONEY,
		
		@old_v2mpositiontaking_1 SMALLMONEY,
		@old_v2mpositiontaking_2 SMALLMONEY,
		@old_v2mpositiontaking_3 SMALLMONEY,
		@old_v2mpositiontaking_7 SMALLMONEY,
		@old_v2mpositiontaking_8 SMALLMONEY,
	--	@old_v2mpositiontaking_9 SMALLMONEY,
		@old_v2mpositiontaking_20 SMALLMONEY,
		@old_v2mpositiontaking_9999 SMALLMONEY,

		@old_v3mpositiontaking_1 SMALLMONEY,
		@old_v3mpositiontaking_2 SMALLMONEY,
		@old_v3mpositiontaking_3 SMALLMONEY,
		@old_v3mpositiontaking_20 SMALLMONEY,

		@old_v5mpositiontaking_1 SMALLMONEY,
		@old_v5mpositiontaking_2 SMALLMONEY,
		@old_v5mpositiontaking_3 SMALLMONEY,
		@old_v5mpositiontaking_20 SMALLMONEY,
		@old_v5mpositiontaking_9999 SMALLMONEY,

		@old_v8mpositiontaking_1 SMALLMONEY,
		@old_v8mpositiontaking_3 SMALLMONEY,
		@old_v8mpositiontaking_20 SMALLMONEY,

		@old_v10mpositiontaking_1 SMALLMONEY,
		@old_v10mpositiontaking_2 SMALLMONEY,
		@old_v10mpositiontaking_3 SMALLMONEY,
		@old_v10mpositiontaking_20 SMALLMONEY,

		@old_v11mpositiontaking_1 SMALLMONEY,
		@old_v11mpositiontaking_20 SMALLMONEY,

		@old_v99mpositiontaking_1 SMALLMONEY,
		@old_v99mpositiontaking_2 SMALLMONEY,
		@old_v99mpositiontaking_3 SMALLMONEY,
		@old_v99mpositiontaking_20 SMALLMONEY,
		@old_v99mpositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@old_v99mpositiontaking_9 SMALLMONEY,

		--old_um1
		@old_auto_mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_mpositiontaking_mem_2 SMALLMONEY,
		@old_auto_mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_mpositiontaking_mem_4 SMALLMONEY,
		@old_auto_mpositiontaking_mem_5 SMALLMONEY,
		@old_auto_mpositiontaking_mem_6 SMALLMONEY,
		@old_auto_mpositiontaking_mem_7 SMALLMONEY,
		@old_auto_mpositiontaking_mem_8 SMALLMONEY,
		@old_auto_mpositiontaking_mem_9 SMALLMONEY,
		@old_auto_mpositiontaking_mem_10 SMALLMONEY,
		
		
		@old_auto_mpositiontaking_mem_9999 SMALLMONEY,
		
		@old_auto_mlivepositiontaking_mem_1 SMALLMONEY,
		@old_auto_mlivepositiontaking_mem_3 SMALLMONEY,
		@old_auto_mlivepositiontaking_mem_7 SMALLMONEY,
		@old_auto_mlivepositiontaking_mem_8 SMALLMONEY,
		
		@old_auto_v2mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v2mpositiontaking_mem_2 SMALLMONEY,
		@old_auto_v2mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_v2mpositiontaking_mem_7 SMALLMONEY,
		@old_auto_v2mpositiontaking_mem_8 SMALLMONEY,
	--	@old_auto_v2mpositiontaking_mem_9 SMALLMONEY,
		@old_auto_v2mpositiontaking_mem_20 SMALLMONEY,
		@old_auto_v2mpositiontaking_mem_9999 SMALLMONEY,

		@old_auto_v3mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v3mpositiontaking_mem_2 SMALLMONEY,
		@old_auto_v3mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_v3mpositiontaking_mem_20 SMALLMONEY,

		@old_auto_v5mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v5mpositiontaking_mem_2 SMALLMONEY,
		@old_auto_v5mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_v5mpositiontaking_mem_20 SMALLMONEY,
		@old_auto_v5mpositiontaking_mem_9999 SMALLMONEY,

		@old_auto_v8mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v8mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_v8mpositiontaking_mem_20 SMALLMONEY,

		@old_auto_v10mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v10mpositiontaking_mem_2 SMALLMONEY,
		@old_auto_v10mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_v10mpositiontaking_mem_20 SMALLMONEY,

		@old_auto_v11mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v11mpositiontaking_mem_20 SMALLMONEY,

		@old_auto_v99mpositiontaking_mem_1 SMALLMONEY,
		@old_auto_v99mpositiontaking_mem_2 SMALLMONEY,
		@old_auto_v99mpositiontaking_mem_3 SMALLMONEY,
		@old_auto_v99mpositiontaking_mem_20 SMALLMONEY,
		@old_auto_v99mpositiontaking_mem_9999 SMALLMONEY,
		-- mixed sports
		@old_auto_v99mpositiontaking_mem_9 SMALLMONEY,

		--old_im1
		@old_isauto_mpositiontaking_mem_1 BIT,
		@old_isauto_mpositiontaking_mem_2 BIT,
		@old_isauto_mpositiontaking_mem_3 BIT,
		@old_isauto_mpositiontaking_mem_4 BIT,
		@old_isauto_mpositiontaking_mem_5 BIT,
		@old_isauto_mpositiontaking_mem_6 BIT,
		@old_isauto_mpositiontaking_mem_7 BIT,
		@old_isauto_mpositiontaking_mem_8 BIT,
		@old_isauto_mpositiontaking_mem_9 BIT,
		@old_isauto_mpositiontaking_mem_10 BIT,
		@old_isauto_mpositiontaking_mem_9999 BIT,
		
		@old_isauto_mlivepositiontaking_mem_1 BIT,
		@old_isauto_mlivepositiontaking_mem_3 BIT,
		@old_isauto_mlivepositiontaking_mem_7 BIT,
		@old_isauto_mlivepositiontaking_mem_8 BIT,
		
		@old_isauto_v2mpositiontaking_mem_1 BIT,
		@old_isauto_v2mpositiontaking_mem_2 BIT,
		@old_isauto_v2mpositiontaking_mem_3 BIT,
		@old_isauto_v2mpositiontaking_mem_7 BIT,
		@old_isauto_v2mpositiontaking_mem_8 BIT,
	--	@old_isauto_v2mpositiontaking_mem_9 BIT,
		@old_isauto_v2mpositiontaking_mem_20 BIT,
		@old_isauto_v2mpositiontaking_mem_9999 BIT,

		@old_isauto_v3mpositiontaking_mem_1 BIT,
		@old_isauto_v3mpositiontaking_mem_2 BIT,
		@old_isauto_v3mpositiontaking_mem_3 BIT,
		@old_isauto_v3mpositiontaking_mem_20 BIT,

		@old_isauto_v5mpositiontaking_mem_1 BIT,
		@old_isauto_v5mpositiontaking_mem_2 BIT,
		@old_isauto_v5mpositiontaking_mem_3 BIT,
		@old_isauto_v5mpositiontaking_mem_20 BIT,
		@old_isauto_v5mpositiontaking_mem_9999 BIT,

		@old_isauto_v8mpositiontaking_mem_1 BIT,
		@old_isauto_v8mpositiontaking_mem_3 BIT,
		@old_isauto_v8mpositiontaking_mem_20 BIT,

		@old_isauto_v10mpositiontaking_mem_1 BIT,
		@old_isauto_v10mpositiontaking_mem_2 BIT,
		@old_isauto_v10mpositiontaking_mem_3 BIT,
		@old_isauto_v10mpositiontaking_mem_20 BIT,

		@old_isauto_v11mpositiontaking_mem_1 BIT,
		@old_isauto_v11mpositiontaking_mem_20 BIT,

		@old_isauto_v99mpositiontaking_mem_1 BIT,
		@old_isauto_v99mpositiontaking_mem_2 BIT,
		@old_isauto_v99mpositiontaking_mem_3 BIT,
		@old_isauto_v99mpositiontaking_mem_20 BIT,
		@old_isauto_v99mpositiontaking_mem_9999 BIT,
		-- mixed sports
		@old_isauto_v99mpositiontaking_mem_9 BIT,

		--@maxpos smallmoney,
		--s4
		@max_spositiontaking_1 SMALLMONEY,
		@max_spositiontaking_2 SMALLMONEY,
		@max_spositiontaking_3 SMALLMONEY,
		@max_spositiontaking_4 SMALLMONEY,
		@max_spositiontaking_5 SMALLMONEY,
		@max_spositiontaking_6 SMALLMONEY,
		@max_spositiontaking_7 SMALLMONEY,
		@max_spositiontaking_8 SMALLMONEY,
		@max_spositiontaking_9 SMALLMONEY,
		@max_spositiontaking_10 SMALLMONEY,
		@max_spositiontaking_9999 SMALLMONEY,
		
		@max_slivepositiontaking_1 SMALLMONEY,
		@max_slivepositiontaking_3 SMALLMONEY,
		@max_slivepositiontaking_7 SMALLMONEY,
		@max_slivepositiontaking_8 SMALLMONEY,
		
		@max_v2spositiontaking_1 SMALLMONEY,
		@max_v2spositiontaking_2 SMALLMONEY,
		@max_v2spositiontaking_3 SMALLMONEY,
		@max_v2spositiontaking_7 SMALLMONEY,
		@max_v2spositiontaking_8 SMALLMONEY,
	--	@max_v2spositiontaking_9 SMALLMONEY,
		@max_v2spositiontaking_20 SMALLMONEY,
		@max_v2spositiontaking_9999 SMALLMONEY,

		@max_v3spositiontaking_1 SMALLMONEY,
		@max_v3spositiontaking_2 SMALLMONEY,
		@max_v3spositiontaking_3 SMALLMONEY,
		@max_v3spositiontaking_20 SMALLMONEY,

		@max_v5spositiontaking_1 SMALLMONEY,
		@max_v5spositiontaking_2 SMALLMONEY,
		@max_v5spositiontaking_3 SMALLMONEY,
		@max_v5spositiontaking_20 SMALLMONEY,
		@max_v5spositiontaking_9999 SMALLMONEY,

		@max_v8spositiontaking_1 SMALLMONEY,
		@max_v8spositiontaking_3 SMALLMONEY,
		@max_v8spositiontaking_20 SMALLMONEY,

		@max_v10spositiontaking_1 SMALLMONEY,
		@max_v10spositiontaking_2 SMALLMONEY,
		@max_v10spositiontaking_3 SMALLMONEY,
		@max_v10spositiontaking_20 SMALLMONEY,

		@max_v11spositiontaking_1 SMALLMONEY,
		@max_v11spositiontaking_20 SMALLMONEY,

		@max_v99spositiontaking_1 SMALLMONEY,
		@max_v99spositiontaking_2 SMALLMONEY,
		@max_v99spositiontaking_3 SMALLMONEY,
		@max_v99spositiontaking_20 SMALLMONEY,
		@max_v99spositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@max_v99spositiontaking_9 SMALLMONEY,
		
		@spositiontaking_1 SMALLMONEY,
		@spositiontaking_2 SMALLMONEY,
		@spositiontaking_3 SMALLMONEY,
		@spositiontaking_4 SMALLMONEY,
		@spositiontaking_5 SMALLMONEY,
		@spositiontaking_6 SMALLMONEY,
		@spositiontaking_7 SMALLMONEY,
		@spositiontaking_8 SMALLMONEY,
		@spositiontaking_9 SMALLMONEY,
		@spositiontaking_10 SMALLMONEY,
		@spositiontaking_9999 SMALLMONEY,
		
		@slivepositiontaking_1 SMALLMONEY,
		@slivepositiontaking_3 SMALLMONEY,
		@slivepositiontaking_7 SMALLMONEY,
		@slivepositiontaking_8 SMALLMONEY,
		
		@v2spositiontaking_1 SMALLMONEY,
		@v2spositiontaking_2 SMALLMONEY,
		@v2spositiontaking_3 SMALLMONEY,
		@v2spositiontaking_7 SMALLMONEY,
		@v2spositiontaking_8 SMALLMONEY,
	--	@v2spositiontaking_9 SMALLMONEY,
		@v2spositiontaking_20 SMALLMONEY,
		@v2spositiontaking_9999 SMALLMONEY,

		@v3spositiontaking_1 SMALLMONEY,
		@v3spositiontaking_2 SMALLMONEY,
		@v3spositiontaking_3 SMALLMONEY,
		@v3spositiontaking_20 SMALLMONEY,

		@v5spositiontaking_1 SMALLMONEY,
		@v5spositiontaking_2 SMALLMONEY,
		@v5spositiontaking_3 SMALLMONEY,
		@v5spositiontaking_20 SMALLMONEY,
		@v5spositiontaking_9999 SMALLMONEY,

		@v8spositiontaking_1 SMALLMONEY,
		@v8spositiontaking_3 SMALLMONEY,
		@v8spositiontaking_20 SMALLMONEY,

		@v10spositiontaking_1 SMALLMONEY,
		@v10spositiontaking_2 SMALLMONEY,
		@v10spositiontaking_3 SMALLMONEY,
		@v10spositiontaking_20 SMALLMONEY,

		@v11spositiontaking_1 SMALLMONEY,
		@v11spositiontaking_20 SMALLMONEY,

		@v99spositiontaking_1 SMALLMONEY,
		@v99spositiontaking_2 SMALLMONEY,
		@v99spositiontaking_3 SMALLMONEY,
		@v99spositiontaking_20 SMALLMONEY,	
		@v99spositiontaking_9999 SMALLMONEY,	
		-- mixed sports
		@v99spositiontaking_9 SMALLMONEY,

		--u1
		@auto_spositiontaking_mem_1 SMALLMONEY,
		@auto_spositiontaking_mem_2 SMALLMONEY,
		@auto_spositiontaking_mem_3 SMALLMONEY,
		@auto_spositiontaking_mem_4 SMALLMONEY,
		@auto_spositiontaking_mem_5 SMALLMONEY,
		@auto_spositiontaking_mem_6 SMALLMONEY,
		@auto_spositiontaking_mem_7 SMALLMONEY,
		@auto_spositiontaking_mem_8 SMALLMONEY,
		@auto_spositiontaking_mem_9 SMALLMONEY,
		@auto_spositiontaking_mem_10 SMALLMONEY,
		-- Outright for Sports
		
		@auto_v2spositiontaking_mem_10 SMALLMONEY,
		@auto_v3spositiontaking_mem_10 SMALLMONEY,
		@auto_v5spositiontaking_mem_10 SMALLMONEY,
		@auto_v8spositiontaking_mem_10 SMALLMONEY,
		@auto_v10spositiontaking_mem_10 SMALLMONEY,
		@auto_v11spositiontaking_mem_10 SMALLMONEY,
		@auto_v99spositiontaking_mem_10 SMALLMONEY,
		
		@auto_spositiontaking_mem_9999 SMALLMONEY,
		
		@auto_slivepositiontaking_mem_1 SMALLMONEY,
		@auto_slivepositiontaking_mem_3 SMALLMONEY,
		@auto_slivepositiontaking_mem_7 SMALLMONEY,
		@auto_slivepositiontaking_mem_8 SMALLMONEY,
		
		@auto_v2spositiontaking_mem_1 SMALLMONEY,
		@auto_v2spositiontaking_mem_2 SMALLMONEY,
		@auto_v2spositiontaking_mem_3 SMALLMONEY,
		@auto_v2spositiontaking_mem_7 SMALLMONEY,
		@auto_v2spositiontaking_mem_8 SMALLMONEY,
	--	@auto_v2spositiontaking_mem_9 SMALLMONEY,
		@auto_v2spositiontaking_mem_20 SMALLMONEY,
		@auto_v2spositiontaking_mem_9999 SMALLMONEY,

		@auto_v3spositiontaking_mem_1 SMALLMONEY,
		@auto_v3spositiontaking_mem_2 SMALLMONEY,
		@auto_v3spositiontaking_mem_3 SMALLMONEY,
		@auto_v3spositiontaking_mem_20 SMALLMONEY,

		@auto_v5spositiontaking_mem_1 SMALLMONEY,
		@auto_v5spositiontaking_mem_2 SMALLMONEY,
		@auto_v5spositiontaking_mem_3 SMALLMONEY,
		@auto_v5spositiontaking_mem_20 SMALLMONEY,
		@auto_v5spositiontaking_mem_9999 SMALLMONEY,

		@auto_v8spositiontaking_mem_1 SMALLMONEY,
		@auto_v8spositiontaking_mem_3 SMALLMONEY,
		@auto_v8spositiontaking_mem_20 SMALLMONEY,

		@auto_v10spositiontaking_mem_1 SMALLMONEY,
		@auto_v10spositiontaking_mem_2 SMALLMONEY,
		@auto_v10spositiontaking_mem_3 SMALLMONEY,
		@auto_v10spositiontaking_mem_20 SMALLMONEY,

		@auto_v11spositiontaking_mem_1 SMALLMONEY,
		@auto_v11spositiontaking_mem_20 SMALLMONEY,

		@auto_v99spositiontaking_mem_1 SMALLMONEY,
		@auto_v99spositiontaking_mem_2 SMALLMONEY,
		@auto_v99spositiontaking_mem_3 SMALLMONEY,
		@auto_v99spositiontaking_mem_20 SMALLMONEY,
		@auto_v99spositiontaking_mem_9999 SMALLMONEY,
		-- mixed sports
		@auto_v99spositiontaking_mem_9 SMALLMONEY,

		--i1
		@isauto_spositiontaking_mem_1 BIT,
		@isauto_spositiontaking_mem_2 BIT,
		@isauto_spositiontaking_mem_3 BIT,
		@isauto_spositiontaking_mem_4 BIT,
		@isauto_spositiontaking_mem_5 BIT,
		@isauto_spositiontaking_mem_6 BIT,
		@isauto_spositiontaking_mem_7 BIT,
		@isauto_spositiontaking_mem_8 BIT,
		@isauto_spositiontaking_mem_9 BIT,
		@isauto_spositiontaking_mem_10 BIT,
		
		-- Outright PT for sports
		@isauto_v2spositiontaking_mem_10 BIT,
		@isauto_v3spositiontaking_mem_10 BIT,
		@isauto_v5spositiontaking_mem_10 BIT,
		@isauto_v8spositiontaking_mem_10 BIT,
		@isauto_v10spositiontaking_mem_10 BIT,
		@isauto_v11spositiontaking_mem_10 BIT,
		@isauto_v99spositiontaking_mem_10 BIT,
		
		@isauto_spositiontaking_mem_9999 BIT,
		
		@isauto_slivepositiontaking_mem_1 BIT,
		@isauto_slivepositiontaking_mem_3 BIT,
		@isauto_slivepositiontaking_mem_7 BIT,
		@isauto_slivepositiontaking_mem_8 BIT,
		
		@isauto_v2spositiontaking_mem_1 BIT,
		@isauto_v2spositiontaking_mem_2 BIT,
		@isauto_v2spositiontaking_mem_3 BIT,
		@isauto_v2spositiontaking_mem_7 BIT,
		@isauto_v2spositiontaking_mem_8 BIT,
	--	@isauto_v2spositiontaking_mem_9 BIT,
		@isauto_v2spositiontaking_mem_20 BIT,
		@isauto_v2spositiontaking_mem_9999 BIT,

		@isauto_v3spositiontaking_mem_1 BIT,
		@isauto_v3spositiontaking_mem_2 BIT,
		@isauto_v3spositiontaking_mem_3 BIT,
		@isauto_v3spositiontaking_mem_20 BIT,

		@isauto_v5spositiontaking_mem_1 BIT,
		@isauto_v5spositiontaking_mem_2 BIT,
		@isauto_v5spositiontaking_mem_3 BIT,
		@isauto_v5spositiontaking_mem_20 BIT,
		@isauto_v5spositiontaking_mem_9999 BIT,

		@isauto_v8spositiontaking_mem_1 BIT,
		@isauto_v8spositiontaking_mem_3 BIT,
		@isauto_v8spositiontaking_mem_20 BIT,

		@isauto_v10spositiontaking_mem_1 BIT,
		@isauto_v10spositiontaking_mem_2 BIT,
		@isauto_v10spositiontaking_mem_3 BIT,
		@isauto_v10spositiontaking_mem_20 BIT,

		@isauto_v11spositiontaking_mem_1 BIT,
		@isauto_v11spositiontaking_mem_20 BIT,

		@isauto_v99spositiontaking_mem_1 BIT,
		@isauto_v99spositiontaking_mem_2 BIT,
		@isauto_v99spositiontaking_mem_3 BIT,
		@isauto_v99spositiontaking_mem_20 BIT,
		@isauto_v99spositiontaking_mem_9999 BIT,
		-- mixed sports
		@isauto_v99spositiontaking_mem_9 BIT,

		--u3
		@auto_spositiontaking_1 SMALLMONEY,
		@auto_spositiontaking_2 SMALLMONEY,
		@auto_spositiontaking_3 SMALLMONEY,
		@auto_spositiontaking_4 SMALLMONEY,
		@auto_spositiontaking_5 SMALLMONEY,
		@auto_spositiontaking_6 SMALLMONEY,
		@auto_spositiontaking_7 SMALLMONEY,
		@auto_spositiontaking_8 SMALLMONEY,
		@auto_spositiontaking_9 SMALLMONEY,
		@auto_spositiontaking_10 SMALLMONEY,
		@auto_spositiontaking_9999 SMALLMONEY,
		
		@auto_slivepositiontaking_1 SMALLMONEY,
		@auto_slivepositiontaking_3 SMALLMONEY,
		@auto_slivepositiontaking_7 SMALLMONEY,
		@auto_slivepositiontaking_8 SMALLMONEY,
		
		@auto_v2spositiontaking_1 SMALLMONEY,
		@auto_v2spositiontaking_2 SMALLMONEY,
		@auto_v2spositiontaking_3 SMALLMONEY,
		@auto_v2spositiontaking_7 SMALLMONEY,
		@auto_v2spositiontaking_8 SMALLMONEY,
	--	@auto_v2spositiontaking_9 SMALLMONEY,
		@auto_v2spositiontaking_20 SMALLMONEY,
		@auto_v2spositiontaking_9999 SMALLMONEY,

		@auto_v3spositiontaking_1 SMALLMONEY,
		@auto_v3spositiontaking_2 SMALLMONEY,
		@auto_v3spositiontaking_3 SMALLMONEY,
		@auto_v3spositiontaking_20 SMALLMONEY,

		@auto_v5spositiontaking_1 SMALLMONEY,
		@auto_v5spositiontaking_2 SMALLMONEY,
		@auto_v5spositiontaking_3 SMALLMONEY,
		@auto_v5spositiontaking_20 SMALLMONEY,
		@auto_v5spositiontaking_9999 SMALLMONEY,

		@auto_v8spositiontaking_1 SMALLMONEY,
		@auto_v8spositiontaking_3 SMALLMONEY,
		@auto_v8spositiontaking_20 SMALLMONEY,

		@auto_v10spositiontaking_1 SMALLMONEY,
		@auto_v10spositiontaking_2 SMALLMONEY,
		@auto_v10spositiontaking_3 SMALLMONEY,
		@auto_v10spositiontaking_20 SMALLMONEY,

		@auto_v11spositiontaking_1 SMALLMONEY,
		@auto_v11spositiontaking_20 SMALLMONEY,

		@auto_v99spositiontaking_1 SMALLMONEY,
		@auto_v99spositiontaking_2 SMALLMONEY,
		@auto_v99spositiontaking_3 SMALLMONEY,
		@auto_v99spositiontaking_20 SMALLMONEY,
		@auto_v99spositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@auto_v99spositiontaking_9 SMALLMONEY,

		--i3
		@isauto_spositiontaking_1 BIT,
		@isauto_spositiontaking_2 BIT,
		@isauto_spositiontaking_3 BIT,
		@isauto_spositiontaking_4 BIT,
		@isauto_spositiontaking_5 BIT,
		@isauto_spositiontaking_6 BIT,
		@isauto_spositiontaking_7 BIT,
		@isauto_spositiontaking_8 BIT,
		@isauto_spositiontaking_9 BIT,
		@isauto_spositiontaking_10 BIT,
		@isauto_spositiontaking_9999 BIT,
		@isauto_slivepositiontaking_1 BIT,
		@isauto_slivepositiontaking_3 BIT,
		@isauto_slivepositiontaking_7 BIT,
		@isauto_slivepositiontaking_8 BIT,
		
		@isauto_v2spositiontaking_1 BIT,
		@isauto_v2spositiontaking_2 BIT,
		@isauto_v2spositiontaking_3 BIT,
		@isauto_v2spositiontaking_7 BIT,
		@isauto_v2spositiontaking_8 BIT,
	--	@isauto_v2spositiontaking_9 BIT,
		@isauto_v2spositiontaking_20 BIT,
		@isauto_v2spositiontaking_9999 BIT,

		@isauto_v3spositiontaking_1 BIT,
		@isauto_v3spositiontaking_2 BIT,
		@isauto_v3spositiontaking_3 BIT,
		@isauto_v3spositiontaking_20 BIT,

		@isauto_v5spositiontaking_1 BIT,
		@isauto_v5spositiontaking_2 BIT,
		@isauto_v5spositiontaking_3 BIT,
		@isauto_v5spositiontaking_20 BIT,
		@isauto_v5spositiontaking_9999 BIT,

		@isauto_v8spositiontaking_1 BIT,
		@isauto_v8spositiontaking_3 BIT,
		@isauto_v8spositiontaking_20 BIT,

		@isauto_v10spositiontaking_1 BIT,
		@isauto_v10spositiontaking_2 BIT,
		@isauto_v10spositiontaking_3 BIT,
		@isauto_v10spositiontaking_20 BIT,

		@isauto_v11spositiontaking_1 BIT,
		@isauto_v11spositiontaking_20 BIT,

		@isauto_v99spositiontaking_1 BIT,
		@isauto_v99spositiontaking_2 BIT,
		@isauto_v99spositiontaking_3 BIT,
		@isauto_v99spositiontaking_20 BIT,
		@isauto_v99spositiontaking_9999 BIT,
		-- mixed sports
		@isauto_v99spositiontaking_9 BIT,

		--um2
		@auto_mpositiontaking_1 SMALLMONEY ,
		@auto_mpositiontaking_2 SMALLMONEY ,
		@auto_mpositiontaking_3 SMALLMONEY ,
		@auto_mpositiontaking_4 SMALLMONEY ,
		@auto_mpositiontaking_5 SMALLMONEY ,
		@auto_mpositiontaking_6 SMALLMONEY ,
		@auto_mpositiontaking_7 SMALLMONEY ,
		@auto_mpositiontaking_8 SMALLMONEY ,
		@auto_mpositiontaking_9 SMALLMONEY ,
		@auto_mpositiontaking_10 SMALLMONEY,
		@auto_mpositiontaking_9999 SMALLMONEY,
		@auto_mlivepositiontaking_1 SMALLMONEY ,
		@auto_mlivepositiontaking_3 SMALLMONEY ,
		@auto_mlivepositiontaking_7 SMALLMONEY ,
		@auto_mlivepositiontaking_8 SMALLMONEY ,
		
		@auto_v2mpositiontaking_1 SMALLMONEY ,
		@auto_v2mpositiontaking_2 SMALLMONEY ,
		@auto_v2mpositiontaking_3 SMALLMONEY ,
		@auto_v2mpositiontaking_7 SMALLMONEY ,
		@auto_v2mpositiontaking_8 SMALLMONEY ,
	--	@auto_v2mpositiontaking_9 SMALLMONEY ,
		@auto_v2mpositiontaking_20 SMALLMONEY ,
		@auto_v2mpositiontaking_9999 SMALLMONEY ,
		
		@auto_v3mpositiontaking_1 SMALLMONEY ,
		@auto_v3mpositiontaking_2 SMALLMONEY ,
		@auto_v3mpositiontaking_3 SMALLMONEY ,
		@auto_v3mpositiontaking_20 SMALLMONEY ,
		
		@auto_v5mpositiontaking_1 SMALLMONEY ,
		@auto_v5mpositiontaking_2 SMALLMONEY ,
		@auto_v5mpositiontaking_3 SMALLMONEY ,
		@auto_v5mpositiontaking_20 SMALLMONEY,
		@auto_v5mpositiontaking_9999 SMALLMONEY,
		
		@auto_v8mpositiontaking_1 SMALLMONEY ,
		@auto_v8mpositiontaking_3 SMALLMONEY ,
		@auto_v8mpositiontaking_20 SMALLMONEY ,
		
		@auto_v10mpositiontaking_1 SMALLMONEY ,
		@auto_v10mpositiontaking_2 SMALLMONEY ,
		@auto_v10mpositiontaking_3 SMALLMONEY ,
		@auto_v10mpositiontaking_20 SMALLMONEY ,
		
		@auto_v11mpositiontaking_1 SMALLMONEY ,
		@auto_v11mpositiontaking_20 SMALLMONEY ,

		@auto_v99mpositiontaking_1 SMALLMONEY ,
		@auto_v99mpositiontaking_2 SMALLMONEY ,
		@auto_v99mpositiontaking_3 SMALLMONEY ,
		@auto_v99mpositiontaking_20 SMALLMONEY,
		@auto_v99mpositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@auto_v99mpositiontaking_9 SMALLMONEY,

		@v2apositiontaking_10 SMALLMONEY,
		@v3apositiontaking_10 SMALLMONEY,
		@v5apositiontaking_10 SMALLMONEY,
		@v8apositiontaking_10 SMALLMONEY,
		@v10apositiontaking_10 SMALLMONEY,
		@v11apositiontaking_10 SMALLMONEY,
		@v99apositiontaking_10 SMALLMONEY,
		
		@max_v2apositiontaking_10 SMALLMONEY,
		@max_v3apositiontaking_10 SMALLMONEY,
		@max_v5apositiontaking_10 SMALLMONEY,
		@max_v8apositiontaking_10 SMALLMONEY,
		@max_v10apositiontaking_10 SMALLMONEY,
		@max_v11apositiontaking_10 SMALLMONEY,
		@max_v99apositiontaking_10 SMALLMONEY,
		
		
		@old_v2mpositiontaking_10 SMALLMONEY,
		@old_v3mpositiontaking_10 SMALLMONEY,
		@old_v5mpositiontaking_10 SMALLMONEY,
		@old_v8mpositiontaking_10 SMALLMONEY,
		@old_v10mpositiontaking_10 SMALLMONEY,
		@old_v11mpositiontaking_10 SMALLMONEY,
		@old_v99mpositiontaking_10 SMALLMONEY,
		
		@max_v2spositiontaking_10 SMALLMONEY,
		@max_v3spositiontaking_10 SMALLMONEY,
		@max_v5spositiontaking_10 SMALLMONEY,
		@max_v8spositiontaking_10 SMALLMONEY,
		@max_v10spositiontaking_10 SMALLMONEY,
		@max_v11spositiontaking_10 SMALLMONEY,
		@max_v99spositiontaking_10 SMALLMONEY,
		
		@v2spositiontaking_10 SMALLMONEY,
		@v3spositiontaking_10 SMALLMONEY,
		@v5spositiontaking_10 SMALLMONEY,
		@v8spositiontaking_10 SMALLMONEY,
		@v10spositiontaking_10 SMALLMONEY,
		@v11spositiontaking_10 SMALLMONEY,
		@v99spositiontaking_10 SMALLMONEY,
		
		@auto_v2spositiontaking_10 SMALLMONEY,
		@auto_v3spositiontaking_10 SMALLMONEY,
		@auto_v5spositiontaking_10 SMALLMONEY,
		@auto_v8spositiontaking_10 SMALLMONEY,
		@auto_v10spositiontaking_10 SMALLMONEY,
		@auto_v11spositiontaking_10 SMALLMONEY,
		@auto_v99spositiontaking_10 SMALLMONEY,
		
		@isauto_v2spositiontaking_10 BIT,
		@isauto_v3spositiontaking_10 BIT,
		@isauto_v5spositiontaking_10 BIT,
		@isauto_v8spositiontaking_10 BIT,
		@isauto_v10spositiontaking_10 BIT,
		@isauto_v11spositiontaking_10 BIT,
		@isauto_v99spositiontaking_10 BIT,
		
		@auto_v2mpositiontaking_10 SMALLMONEY,
		@auto_v3mpositiontaking_10 SMALLMONEY,
		@auto_v5mpositiontaking_10 SMALLMONEY,
		@auto_v8mpositiontaking_10 SMALLMONEY,
		@auto_v10mpositiontaking_10 SMALLMONEY,
		@auto_v11mpositiontaking_10 SMALLMONEY,
		@auto_v99mpositiontaking_10 SMALLMONEY,
		
		@old_auto_v2mpositiontaking_mem_10 SMALLMONEY,
		@old_auto_v3mpositiontaking_mem_10 SMALLMONEY,
		@old_auto_v5mpositiontaking_mem_10 SMALLMONEY,
		@old_auto_v8mpositiontaking_mem_10 SMALLMONEY,
		@old_auto_v10mpositiontaking_mem_10 SMALLMONEY,
		@old_auto_v11mpositiontaking_mem_10 SMALLMONEY,
		@old_auto_v99mpositiontaking_mem_10 SMALLMONEY,
		
		@old_isauto_v2mpositiontaking_mem_10 BIT,
		@old_isauto_v3mpositiontaking_mem_10 BIT,
		@old_isauto_v5mpositiontaking_mem_10 BIT,
		@old_isauto_v8mpositiontaking_mem_10 BIT,
		@old_isauto_v10mpositiontaking_mem_10 BIT,
		@old_isauto_v11mpositiontaking_mem_10 BIT,
		@old_isauto_v99mpositiontaking_mem_10 BIT



	DECLARE
		--min(m3,m4,l3)
		@max_mapositiontaking_1 SMALLMONEY,
		@max_mapositiontaking_2 SMALLMONEY,
		@max_mapositiontaking_3 SMALLMONEY,
		@max_mapositiontaking_4 SMALLMONEY,
		@max_mapositiontaking_5 SMALLMONEY,
		@max_mapositiontaking_6 SMALLMONEY,
		@max_mapositiontaking_7 SMALLMONEY,
		@max_mapositiontaking_8 SMALLMONEY,
		@max_mapositiontaking_9 SMALLMONEY,
		@max_mapositiontaking_10 SMALLMONEY,
		-- Outright PT for sports
		@max_v2mapositiontaking_10 SMALLMONEY,
		@max_v3mapositiontaking_10 SMALLMONEY,
		@max_v5mapositiontaking_10 SMALLMONEY,
		@max_v8mapositiontaking_10 SMALLMONEY,
		@max_v10mapositiontaking_10 SMALLMONEY,
		@max_v11mapositiontaking_10 SMALLMONEY,
		@max_v99mapositiontaking_10 SMALLMONEY,
		
		@max_mapositiontaking_9999 SMALLMONEY,
		
		@max_malivepositiontaking_1 SMALLMONEY,
		@max_malivepositiontaking_3 SMALLMONEY,
		@max_malivepositiontaking_7 SMALLMONEY,
		@max_malivepositiontaking_8 SMALLMONEY,
		
		@max_v2mapositiontaking_1 SMALLMONEY,
		@max_v2mapositiontaking_2 SMALLMONEY,
		@max_v2mapositiontaking_3 SMALLMONEY,
		@max_v2mapositiontaking_7 SMALLMONEY,
		@max_v2mapositiontaking_8 SMALLMONEY,
	--	@max_v2mapositiontaking_9 SMALLMONEY,
		@max_v2mapositiontaking_20 SMALLMONEY,
		@max_v2mapositiontaking_9999 SMALLMONEY,

		@max_v3mapositiontaking_1 SMALLMONEY,
		@max_v3mapositiontaking_2 SMALLMONEY,
		@max_v3mapositiontaking_3 SMALLMONEY,
		@max_v3mapositiontaking_20 SMALLMONEY,

		@max_v5mapositiontaking_1 SMALLMONEY,
		@max_v5mapositiontaking_2 SMALLMONEY,
		@max_v5mapositiontaking_3 SMALLMONEY,
		@max_v5mapositiontaking_20 SMALLMONEY,
		@max_v5mapositiontaking_9999 SMALLMONEY,

		@max_v8mapositiontaking_1 SMALLMONEY,
		@max_v8mapositiontaking_3 SMALLMONEY,
		@max_v8mapositiontaking_20 SMALLMONEY,

		@max_v10mapositiontaking_1 SMALLMONEY,
		@max_v10mapositiontaking_2 SMALLMONEY,
		@max_v10mapositiontaking_3 SMALLMONEY,
		@max_v10mapositiontaking_20 SMALLMONEY,

		@max_v11mapositiontaking_1 SMALLMONEY,
		@max_v11mapositiontaking_20 SMALLMONEY,

		@max_v99mapositiontaking_1 SMALLMONEY,
		@max_v99mapositiontaking_2 SMALLMONEY,
		@max_v99mapositiontaking_3 SMALLMONEY,
		@max_v99mapositiontaking_20 SMALLMONEY,
		@max_v99mapositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@max_v99mapositiontaking_9 SMALLMONEY
				
	DECLARE
		@min_mapositiontaking_1 SMALLMONEY,
		@min_mapositiontaking_2 SMALLMONEY,
		@min_mapositiontaking_3 SMALLMONEY,
		@min_mapositiontaking_4 SMALLMONEY,
		@min_mapositiontaking_5 SMALLMONEY,
		@min_mapositiontaking_6 SMALLMONEY,
		@min_mapositiontaking_7 SMALLMONEY,
		@min_mapositiontaking_8 SMALLMONEY,
		@min_mapositiontaking_9 SMALLMONEY,
		@min_mapositiontaking_10 SMALLMONEY,
		
		-- Outright for sports
		@min_v2mapositiontaking_10 SMALLMONEY,
		@min_v3mapositiontaking_10 SMALLMONEY,
		@min_v5mapositiontaking_10 SMALLMONEY,
		@min_v8mapositiontaking_10 SMALLMONEY,
		@min_v10mapositiontaking_10 SMALLMONEY,
		@min_v11mapositiontaking_10 SMALLMONEY,
		@min_v99mapositiontaking_10 SMALLMONEY,
		
		@min_mapositiontaking_9999 SMALLMONEY,
		@min_malivepositiontaking_1 SMALLMONEY,
		@min_malivepositiontaking_3 SMALLMONEY,
		@min_malivepositiontaking_7 SMALLMONEY,
		@min_malivepositiontaking_8 SMALLMONEY,
		
		@min_v2mapositiontaking_1 SMALLMONEY,
		@min_v2mapositiontaking_2 SMALLMONEY,
		@min_v2mapositiontaking_3 SMALLMONEY,
		@min_v2mapositiontaking_7 SMALLMONEY,
		@min_v2mapositiontaking_8 SMALLMONEY,
	--	@min_v2mapositiontaking_9 SMALLMONEY,
		@min_v2mapositiontaking_20 SMALLMONEY,
		@min_v2mapositiontaking_9999 SMALLMONEY,

		@min_v3mapositiontaking_1 SMALLMONEY,
		@min_v3mapositiontaking_2 SMALLMONEY,
		@min_v3mapositiontaking_3 SMALLMONEY,
		@min_v3mapositiontaking_20 SMALLMONEY,

		@min_v5mapositiontaking_1 SMALLMONEY,
		@min_v5mapositiontaking_2 SMALLMONEY,
		@min_v5mapositiontaking_3 SMALLMONEY,
		@min_v5mapositiontaking_20 SMALLMONEY,
		@min_v5mapositiontaking_9999 SMALLMONEY,

		@min_v8mapositiontaking_1 SMALLMONEY,
		@min_v8mapositiontaking_3 SMALLMONEY,
		@min_v8mapositiontaking_20 SMALLMONEY,

		@min_v10mapositiontaking_1 SMALLMONEY,
		@min_v10mapositiontaking_2 SMALLMONEY,
		@min_v10mapositiontaking_3 SMALLMONEY,
		@min_v10mapositiontaking_20 SMALLMONEY,

		@min_v11mapositiontaking_1 SMALLMONEY,
		@min_v11mapositiontaking_20 SMALLMONEY,

		@min_v99mapositiontaking_1 SMALLMONEY,
		@min_v99mapositiontaking_2 SMALLMONEY,
		@min_v99mapositiontaking_3 SMALLMONEY,
		@min_v99mapositiontaking_20 SMALLMONEY,
		@min_v99mapositiontaking_9999 SMALLMONEY,
		-- mixed sports
		@min_v99mapositiontaking_9 SMALLMONEY

			
	--maxpos_1=min[@max_mp,min(m3,l3)-a1]
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	DECLARE 
		@max_mp_1 smallmoney,
		@max_mp_2 smallmoney,
		@max_mp_3 smallmoney,
		@max_mp_4 smallmoney,
		@max_mp_5 smallmoney,
		@max_mp_6 smallmoney,
		@max_mp_7 smallmoney,
		@max_mp_8 smallmoney,
		@max_mp_9 smallmoney,
		@max_mp_10 smallmoney,
		@max_mp_9999 smallmoney,
		-- Outright PT for sports
		@max_v2mp_10 smallmoney,
		@max_v3mp_10 smallmoney,
		@max_v5mp_10 smallmoney,
		@max_v8mp_10 smallmoney,
		@max_v10mp_10 smallmoney,
		@max_v11mp_10 smallmoney,
		@max_v99mp_10 smallmoney,
		
		@max_mlp_1 smallmoney,
		@max_mlp_3 smallmoney,
		@max_mlp_7 smallmoney,
		@max_mlp_8 smallmoney,
		
		@max_v2mp_1 smallmoney,
		@max_v2mp_2 smallmoney,
		@max_v2mp_3 smallmoney,
		@max_v2mp_7 smallmoney,
		@max_v2mp_8 smallmoney,
	--	@max_v2mp_9 smallmoney,
		@max_v2mp_20 smallmoney,
		@max_v2mp_9999 smallmoney,

		@max_v3mp_1 smallmoney,
		@max_v3mp_2 smallmoney,
		@max_v3mp_3 smallmoney,
		@max_v3mp_20 smallmoney,

		@max_v5mp_1 smallmoney,
		@max_v5mp_2 smallmoney,
		@max_v5mp_3 smallmoney,
		@max_v5mp_20 smallmoney,
		@max_v5mp_9999 smallmoney,

		@max_v8mp_1 smallmoney,
		@max_v8mp_3 smallmoney,
		@max_v8mp_20 smallmoney,

		@max_v10mp_1 smallmoney,
		@max_v10mp_2 smallmoney,
		@max_v10mp_3 smallmoney,
		@max_v10mp_20 smallmoney,

		@max_v11mp_1 smallmoney,
		@max_v11mp_20 smallmoney,

		@max_v99mp_1 smallmoney,
		@max_v99mp_2 smallmoney,
		@max_v99mp_3 smallmoney,
		@max_v99mp_20 smallmoney,
		@max_v99mp_9999 smallmoney,
		-- mixed sports
		@max_v99mp_9 smallmoney,
		
		@min_mp_1 smallmoney,
		@min_mp_2 smallmoney,
		@min_mp_3 smallmoney,
		@min_mp_4 smallmoney,
		@min_mp_5 smallmoney,
		@min_mp_6 smallmoney,
		@min_mp_7 smallmoney,
		@min_mp_8 smallmoney,
		@min_mp_9 smallmoney,
		@min_mp_10 smallmoney,
		@min_mp_9999 smallmoney,
		
		-- Outright PT for sports
		@min_v2mp_10 smallmoney,
		@min_v3mp_10 smallmoney,
		@min_v5mp_10 smallmoney,
		@min_v8mp_10 smallmoney,
		@min_v10mp_10 smallmoney,
		@min_v11mp_10 smallmoney,
		@min_v99mp_10 smallmoney,
		
		@min_mlp_1 smallmoney,
		@min_mlp_3 smallmoney,
		@min_mlp_7 smallmoney,
		@min_mlp_8 smallmoney,
		
		@min_v2mp_1 smallmoney,

		@min_v2mp_2 smallmoney,
		@min_v2mp_3 smallmoney,
		@min_v2mp_7 smallmoney,
		@min_v2mp_8 smallmoney,
	--	@min_v2mp_9 smallmoney,
		@min_v2mp_20 smallmoney,
		@min_v2mp_9999 smallmoney,

		@min_v3mp_1 smallmoney,
		@min_v3mp_2 smallmoney,
		@min_v3mp_3 smallmoney,
		@min_v3mp_20 smallmoney,

		@min_v5mp_1 smallmoney,
		@min_v5mp_2 smallmoney,
		@min_v5mp_3 smallmoney,
		@min_v5mp_20 smallmoney,
		@min_v5mp_9999 smallmoney,

		@min_v8mp_1 smallmoney,
		@min_v8mp_3 smallmoney,
		@min_v8mp_20 smallmoney,

		@min_v10mp_1 smallmoney,
		@min_v10mp_2 smallmoney,
		@min_v10mp_3 smallmoney,
		@min_v10mp_20 smallmoney,

		@min_v11mp_1 smallmoney,
		@min_v11mp_20 smallmoney,

		@min_v99mp_1 smallmoney,
		@min_v99mp_2 smallmoney,
		@min_v99mp_3 smallmoney,
		@min_v99mp_20 smallmoney,
		@min_v99mp_9999 smallmoney,
		-- mixed sports
		@min_v99mp_9 smallmoney

	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @IsValid BIT
		SELECT @isvalid = 1 

		--s1,a1,old_m1,u1,i1
		SELECT 	@spositiontaking_1	=	spositiontaking,	@slivepositiontaking_1	=	slivepositiontaking,	@apositiontaking_1	=	apositiontaking,	@alivepositiontaking_1	=	alivepositiontaking,	@auto_spositiontaking_mem_1	=	autopositiontaking,	@auto_slivepositiontaking_mem_1	=	autolivepositiontaking,	@isauto_spositiontaking_mem_1	=	isautopositiontaking,	@isauto_slivepositiontaking_mem_1	=	isautolivepositiontaking,	@old_mpositiontaking_1	=	mpositiontaking,	@old_auto_mpositiontaking_mem_1	=	autompositiontaking,	@old_isauto_mpositiontaking_mem_1	=	isautompositiontaking,	@old_mlivepositiontaking_1	=	mlivepositiontaking	,@old_auto_mlivepositiontaking_mem_1	=	autolivempositiontaking,	@old_isauto_mlivepositiontaking_mem_1	=	isautolivempositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=1
		SELECT	@spositiontaking_3	=	spositiontaking,	@slivepositiontaking_3	=	slivepositiontaking,	@apositiontaking_3	=	apositiontaking,	@alivepositiontaking_3	=	alivepositiontaking,	@auto_spositiontaking_mem_3	=	autopositiontaking,	@auto_slivepositiontaking_mem_3	=	autolivepositiontaking,	@isauto_spositiontaking_mem_3	=	isautopositiontaking,	@isauto_slivepositiontaking_mem_3	=	isautolivepositiontaking,	@old_mpositiontaking_3	=	mpositiontaking,	@old_auto_mpositiontaking_mem_3	=	autompositiontaking,	@old_isauto_mpositiontaking_mem_3	=	isautompositiontaking,	@old_mlivepositiontaking_3	=	mlivepositiontaking	,@old_auto_mlivepositiontaking_mem_3	=	autolivempositiontaking,	@old_isauto_mlivepositiontaking_mem_3	=	isautolivempositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	AND	sporttype=1
		SELECT	@spositiontaking_7	=	spositiontaking,	@slivepositiontaking_7	=	slivepositiontaking,	@apositiontaking_7	=	apositiontaking,	@alivepositiontaking_7	=	alivepositiontaking,	@auto_spositiontaking_mem_7	=	autopositiontaking,	@auto_slivepositiontaking_mem_7	=	autolivepositiontaking,	@isauto_spositiontaking_mem_7	=	isautopositiontaking,	@isauto_slivepositiontaking_mem_7	=	isautolivepositiontaking,	@old_mpositiontaking_7	=	mpositiontaking,	@old_auto_mpositiontaking_mem_7	=	autompositiontaking,	@old_isauto_mpositiontaking_mem_7	=	isautompositiontaking,	@old_mlivepositiontaking_7	=	mlivepositiontaking	,@old_auto_mlivepositiontaking_mem_7	=	autolivempositiontaking,	@old_isauto_mlivepositiontaking_mem_7	=	isautolivempositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=7	AND	sporttype=1
		SELECT	@spositiontaking_8	=	spositiontaking,	@slivepositiontaking_8	=	slivepositiontaking,	@apositiontaking_8	=	apositiontaking,	@alivepositiontaking_8	=	alivepositiontaking,	@auto_spositiontaking_mem_8	=	autopositiontaking,	@auto_slivepositiontaking_mem_8	=	autolivepositiontaking,	@isauto_spositiontaking_mem_8	=	isautopositiontaking,	@isauto_slivepositiontaking_mem_8	=	isautolivepositiontaking,	@old_mpositiontaking_8	=	mpositiontaking,	@old_auto_mpositiontaking_mem_8	=	autompositiontaking,	@old_isauto_mpositiontaking_mem_8	=	isautompositiontaking,	@old_mlivepositiontaking_8	=	mlivepositiontaking	,@old_auto_mlivepositiontaking_mem_8	=	autolivempositiontaking,	@old_isauto_mlivepositiontaking_mem_8	=	isautolivempositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=8	AND	sporttype=1

		SELECT	@spositiontaking_2	    =	spositiontaking,	@apositiontaking_2	    =	apositiontaking,	@old_mpositiontaking_2	    =	mpositiontaking,	@auto_spositiontaking_mem_2	    =	autopositiontaking,	@isauto_spositiontaking_mem_2	    =	isautopositiontaking	,	@old_auto_mpositiontaking_mem_2	    =	autompositiontaking	,	@old_isauto_mpositiontaking_mem_2	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=2	    AND	sporttype=1
		SELECT	@spositiontaking_4	    =	spositiontaking,	@apositiontaking_4	    =	apositiontaking,	@old_mpositiontaking_4	    =	mpositiontaking,	@auto_spositiontaking_mem_4	    =	autopositiontaking,	@isauto_spositiontaking_mem_4	    =	isautopositiontaking	,	@old_auto_mpositiontaking_mem_4	    =	autompositiontaking	,	@old_isauto_mpositiontaking_mem_4	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=4	    AND	sporttype=1
		SELECT	@spositiontaking_5	    =	spositiontaking,	@apositiontaking_5	    =	apositiontaking,	@old_mpositiontaking_5	    =	mpositiontaking,	@auto_spositiontaking_mem_5	    =	autopositiontaking,	@isauto_spositiontaking_mem_5	    =	isautopositiontaking	,	@old_auto_mpositiontaking_mem_5	    =	autompositiontaking	,	@old_isauto_mpositiontaking_mem_5	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=5	    AND	sporttype=1
		SELECT	@spositiontaking_6	    =	spositiontaking,	@apositiontaking_6	    =	apositiontaking,	@old_mpositiontaking_6	    =	mpositiontaking,	@auto_spositiontaking_mem_6	    =	autopositiontaking,	@isauto_spositiontaking_mem_6	    =	isautopositiontaking	,	@old_auto_mpositiontaking_mem_6	    =	autompositiontaking	,	@old_isauto_mpositiontaking_mem_6	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=6	    AND	sporttype=1
		SELECT	@spositiontaking_9	    =	spositiontaking,	@apositiontaking_9	    =	apositiontaking,	@old_mpositiontaking_9	    =	mpositiontaking,	@auto_spositiontaking_mem_9	    =	autopositiontaking,	@isauto_spositiontaking_mem_9	    =	isautopositiontaking	,	@old_auto_mpositiontaking_mem_9	    =	autompositiontaking	,	@old_isauto_mpositiontaking_mem_9	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9	    AND	sporttype=1
		SELECT	@spositiontaking_10	    =	spositiontaking,	@apositiontaking_10	    =	apositiontaking,	@old_mpositiontaking_10	    =	mpositiontaking,	@auto_spositiontaking_mem_10	=	autopositiontaking,	@isauto_spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=1
		
		-- Outright PT for sports
		SELECT	@v2spositiontaking_10	    =	spositiontaking,	@v2apositiontaking_10	    =	apositiontaking,	@old_v2mpositiontaking_10	    =	mpositiontaking,	@auto_v2spositiontaking_mem_10	=	autopositiontaking,	@isauto_v2spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v2mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=2
		SELECT	@v3spositiontaking_10	    =	spositiontaking,	@v3apositiontaking_10	    =	apositiontaking,	@old_v3mpositiontaking_10	    =	mpositiontaking,	@auto_v3spositiontaking_mem_10	=	autopositiontaking,	@isauto_v3spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v3mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v3mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=3
		SELECT	@v5spositiontaking_10	    =	spositiontaking,	@v5apositiontaking_10	    =	apositiontaking,	@old_v5mpositiontaking_10	    =	mpositiontaking,	@auto_v5spositiontaking_mem_10	=	autopositiontaking,	@isauto_v5spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v5mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v5mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=5
		SELECT	@v8spositiontaking_10	    =	spositiontaking,	@v8apositiontaking_10	    =	apositiontaking,	@old_v8mpositiontaking_10	    =	mpositiontaking,	@auto_v8spositiontaking_mem_10	=	autopositiontaking,	@isauto_v8spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v8mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v8mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=8
		SELECT	@v10spositiontaking_10	    =	spositiontaking,	@v10apositiontaking_10	    =	apositiontaking,	@old_v10mpositiontaking_10	    =	mpositiontaking,	@auto_v10spositiontaking_mem_10	=	autopositiontaking,	@isauto_v10spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v10mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v10mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=10
		SELECT	@v11spositiontaking_10	    =	spositiontaking,	@v11apositiontaking_10	    =	apositiontaking,	@old_v11mpositiontaking_10	    =	mpositiontaking,	@auto_v11spositiontaking_mem_10	=	autopositiontaking,	@isauto_v11spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v11mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v11mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=11
		SELECT	@v99spositiontaking_10	    =	spositiontaking,	@v99apositiontaking_10	    =	apositiontaking,	@old_v99mpositiontaking_10	    =	mpositiontaking,	@auto_v99spositiontaking_mem_10	=	autopositiontaking,	@isauto_v99spositiontaking_mem_10	    =	isautopositiontaking	,	@old_auto_v99mpositiontaking_mem_10	=	autompositiontaking	,	@old_isauto_v99mpositiontaking_mem_10	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=10	    AND	sporttype=99
		
		SELECT	@spositiontaking_9999	= 	spositiontaking,	@apositiontaking_9999	=	apositiontaking,	@old_mpositiontaking_9999	=	mpositiontaking,	@auto_spositiontaking_mem_9999	=	autopositiontaking,	@isauto_spositiontaking_mem_9999	=	isautopositiontaking	,	@old_auto_mpositiontaking_mem_9999	=	autompositiontaking	,	@old_isauto_mpositiontaking_mem_9999	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9999	AND	sporttype=1
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																	
		SELECT	@v2spositiontaking_1	=	spositiontaking,	@v2apositiontaking_1	=	apositiontaking,	@auto_v2spositiontaking_mem_1	=	autopositiontaking,	@isauto_v2spositiontaking_mem_1	=	isautopositiontaking,	@old_v2mpositiontaking_1	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_1	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_1	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=2
		SELECT	@v2spositiontaking_2	=	spositiontaking,	@v2apositiontaking_2	=	apositiontaking,	@auto_v2spositiontaking_mem_2	=	autopositiontaking,	@isauto_v2spositiontaking_mem_2	=	isautopositiontaking,	@old_v2mpositiontaking_2	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_2	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_2	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=2	AND	sporttype=2
		SELECT	@v2spositiontaking_3	=	spositiontaking,	@v2apositiontaking_3	=	apositiontaking,	@auto_v2spositiontaking_mem_3	=	autopositiontaking,	@isauto_v2spositiontaking_mem_3	=	isautopositiontaking,	@old_v2mpositiontaking_3	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_3	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_3	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	AND	sporttype=2
		SELECT	@v2spositiontaking_7	=	spositiontaking,	@v2apositiontaking_7	=	apositiontaking,	@auto_v2spositiontaking_mem_7	=	autopositiontaking,	@isauto_v2spositiontaking_mem_7	=	isautopositiontaking,	@old_v2mpositiontaking_7	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_7	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_7	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=7	AND	sporttype=2
		SELECT	@v2spositiontaking_8	=	spositiontaking,	@v2apositiontaking_8	=	apositiontaking,	@auto_v2spositiontaking_mem_8	=	autopositiontaking,	@isauto_v2spositiontaking_mem_8	=	isautopositiontaking,	@old_v2mpositiontaking_8	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_8	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_8	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=8	AND	sporttype=2
		--SELECT	@v2spositiontaking_9	=	spositiontaking,	@v2apositiontaking_9	=	apositiontaking,	@auto_v2spositiontaking_mem_9	=	autopositiontaking,	@isauto_v2spositiontaking_mem_9	=	isautopositiontaking,	@old_v2mpositiontaking_9	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_9	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_9	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9	AND	sporttype=2																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																												
		SELECT	@v2spositiontaking_20	=	spositiontaking,	@v2apositiontaking_20	=	apositiontaking,	@auto_v2spositiontaking_mem_20	=	autopositiontaking,	@isauto_v2spositiontaking_mem_20	=	isautopositiontaking,	@old_v2mpositiontaking_20	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_20	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	AND	sporttype=2
		SELECT	@v2spositiontaking_9999	=	spositiontaking,	@v2apositiontaking_9999	=	apositiontaking,	@auto_v2spositiontaking_mem_9999=	autopositiontaking,	@isauto_v2spositiontaking_mem_9999	=	isautopositiontaking,	@old_v2mpositiontaking_9999	=	mpositiontaking	,	@old_auto_v2mpositiontaking_mem_9999	=	autompositiontaking	,	@old_isauto_v2mpositiontaking_mem_9999	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9999	AND	sporttype=2

		SELECT	@v3spositiontaking_1	=	spositiontaking,	@v3apositiontaking_1	=	apositiontaking,	@auto_v3spositiontaking_mem_1	=	autopositiontaking,	@isauto_v3spositiontaking_mem_1	=	isautopositiontaking,	@old_v3mpositiontaking_1	=	mpositiontaking	,	@old_auto_v3mpositiontaking_mem_1	=	autompositiontaking	,	@old_isauto_v3mpositiontaking_mem_1	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=3
		SELECT	@v3spositiontaking_2	=	spositiontaking,	@v3apositiontaking_2	=	apositiontaking,	@auto_v3spositiontaking_mem_2	=	autopositiontaking,	@isauto_v3spositiontaking_mem_2	=	isautopositiontaking,	@old_v3mpositiontaking_2	=	mpositiontaking	,	@old_auto_v3mpositiontaking_mem_2	=	autompositiontaking	,	@old_isauto_v3mpositiontaking_mem_2	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=2	AND	sporttype=3
		SELECT	@v3spositiontaking_3	=	spositiontaking,	@v3apositiontaking_3	=	apositiontaking,	@auto_v3spositiontaking_mem_3	=	autopositiontaking,	@isauto_v3spositiontaking_mem_3	=	isautopositiontaking,	@old_v3mpositiontaking_3	=	mpositiontaking	,	@old_auto_v3mpositiontaking_mem_3	=	autompositiontaking	,	@old_isauto_v3mpositiontaking_mem_3	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	AND	sporttype=3
		SELECT	@v3spositiontaking_20	=	spositiontaking,	@v3apositiontaking_20	=	apositiontaking,	@auto_v3spositiontaking_mem_20	=	autopositiontaking,	@isauto_v3spositiontaking_mem_20	=	isautopositiontaking,	@old_v3mpositiontaking_20	=	mpositiontaking	,	@old_auto_v3mpositiontaking_mem_20	=	autompositiontaking	,	@old_isauto_v3mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	AND	sporttype=3

		SELECT	@v5spositiontaking_1	=	spositiontaking,	@v5apositiontaking_1	=	apositiontaking,	@auto_v5spositiontaking_mem_1	    =	autopositiontaking,	@isauto_v5spositiontaking_mem_1	    =	isautopositiontaking,	@old_v5mpositiontaking_1	=	mpositiontaking	,	@old_auto_v5mpositiontaking_mem_1	    =	autompositiontaking	,	@old_isauto_v5mpositiontaking_mem_1	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	    AND	sporttype=5
		SELECT	@v5spositiontaking_2	=	spositiontaking,	@v5apositiontaking_2	=	apositiontaking,	@auto_v5spositiontaking_mem_2	    =	autopositiontaking,	@isauto_v5spositiontaking_mem_2	    =	isautopositiontaking,	@old_v5mpositiontaking_2	=	mpositiontaking	,	@old_auto_v5mpositiontaking_mem_2	    =	autompositiontaking	,	@old_isauto_v5mpositiontaking_mem_2	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=2	    AND	sporttype=5
		SELECT	@v5spositiontaking_3	=	spositiontaking,	@v5apositiontaking_3	=	apositiontaking,	@auto_v5spositiontaking_mem_3	    =	autopositiontaking,	@isauto_v5spositiontaking_mem_3	    =	isautopositiontaking,	@old_v5mpositiontaking_3	=	mpositiontaking	,	@old_auto_v5mpositiontaking_mem_3	    =	autompositiontaking	,	@old_isauto_v5mpositiontaking_mem_3	    =	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	    AND	sporttype=5
		SELECT	@v5spositiontaking_20	=	spositiontaking,	@v5apositiontaking_20	=	apositiontaking,	@auto_v5spositiontaking_mem_20	    =	autopositiontaking,	@isauto_v5spositiontaking_mem_20	=	isautopositiontaking,	@old_v5mpositiontaking_20	=	mpositiontaking	,	@old_auto_v5mpositiontaking_mem_20	    =	autompositiontaking	,	@old_isauto_v5mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	    AND	sporttype=5
		SELECT	@v5spositiontaking_9999	=	spositiontaking,	@v5apositiontaking_9999	=	apositiontaking,	@auto_v5spositiontaking_mem_9999	=	autopositiontaking,	@isauto_v5spositiontaking_mem_9999	=	isautopositiontaking,	@old_v5mpositiontaking_9999	=	mpositiontaking	,	@old_auto_v5mpositiontaking_mem_9999	=	autompositiontaking	,	@old_isauto_v5mpositiontaking_mem_9999	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9999	AND	sporttype=5

		SELECT	@v8spositiontaking_1	=	spositiontaking,	@v8apositiontaking_1	=	apositiontaking,	@auto_v8spositiontaking_mem_1	=	autopositiontaking,	@isauto_v8spositiontaking_mem_1	=	isautopositiontaking,	@old_v8mpositiontaking_1	=	mpositiontaking	,	@old_auto_v8mpositiontaking_mem_1	=	autompositiontaking	,	@old_isauto_v8mpositiontaking_mem_1	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=8
		SELECT	@v8spositiontaking_3	=	spositiontaking,	@v8apositiontaking_3	=	apositiontaking,	@auto_v8spositiontaking_mem_3	=	autopositiontaking,	@isauto_v8spositiontaking_mem_3	=	isautopositiontaking,	@old_v8mpositiontaking_3	=	mpositiontaking	,	@old_auto_v8mpositiontaking_mem_3	=	autompositiontaking	,	@old_isauto_v8mpositiontaking_mem_3	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	AND	sporttype=8
		SELECT	@v8spositiontaking_20	=	spositiontaking,	@v8apositiontaking_20	=	apositiontaking,	@auto_v8spositiontaking_mem_20	=	autopositiontaking,	@isauto_v8spositiontaking_mem_20	=	isautopositiontaking,	@old_v8mpositiontaking_20	=	mpositiontaking	,	@old_auto_v8mpositiontaking_mem_20	=	autompositiontaking	,	@old_isauto_v8mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	AND	sporttype=8

		SELECT	@v10spositiontaking_1	=	spositiontaking,	@v10apositiontaking_1	=	apositiontaking,	@auto_v10spositiontaking_mem_1	=	autopositiontaking,	@isauto_v10spositiontaking_mem_1	=	isautopositiontaking,	@old_v10mpositiontaking_1	=	mpositiontaking	,	@old_auto_v10mpositiontaking_mem_1	=	autompositiontaking	,	@old_isauto_v10mpositiontaking_mem_1	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=10
		SELECT	@v10spositiontaking_2	=	spositiontaking,	@v10apositiontaking_2	=	apositiontaking,	@auto_v10spositiontaking_mem_2	=	autopositiontaking,	@isauto_v10spositiontaking_mem_2	=	isautopositiontaking,	@old_v10mpositiontaking_2	=	mpositiontaking	,	@old_auto_v10mpositiontaking_mem_2	=	autompositiontaking	,	@old_isauto_v10mpositiontaking_mem_2	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=2	AND	sporttype=10
		SELECT	@v10spositiontaking_3	=	spositiontaking,	@v10apositiontaking_3	=	apositiontaking,	@auto_v10spositiontaking_mem_3	=	autopositiontaking,	@isauto_v10spositiontaking_mem_3	=	isautopositiontaking,	@old_v10mpositiontaking_3	=	mpositiontaking	,	@old_auto_v10mpositiontaking_mem_3	=	autompositiontaking	,	@old_isauto_v10mpositiontaking_mem_3	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	AND	sporttype=10
		SELECT	@v10spositiontaking_20	=	spositiontaking,	@v10apositiontaking_20	=	apositiontaking,	@auto_v10spositiontaking_mem_20	=	autopositiontaking,	@isauto_v10spositiontaking_mem_20	=	isautopositiontaking,	@old_v10mpositiontaking_20	=	mpositiontaking	,	@old_auto_v10mpositiontaking_mem_20	=	autompositiontaking	,	@old_isauto_v10mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	AND	sporttype=10

		SELECT	@v11spositiontaking_1	=	spositiontaking,	@v11apositiontaking_1	=	apositiontaking,	@auto_v11spositiontaking_mem_1	=	autopositiontaking,	@isauto_v11spositiontaking_mem_1	=	isautopositiontaking,	@old_v11mpositiontaking_1	=	mpositiontaking	,	@old_auto_v11mpositiontaking_mem_1	=	autompositiontaking	,	@old_isauto_v11mpositiontaking_mem_1	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=11
		SELECT	@v11spositiontaking_20	=	spositiontaking,	@v11apositiontaking_20	=	apositiontaking,	@auto_v11spositiontaking_mem_20	=	autopositiontaking,	@isauto_v11spositiontaking_mem_20	=	isautopositiontaking,	@old_v11mpositiontaking_20	=	mpositiontaking	,	@old_auto_v11mpositiontaking_mem_20	=	autompositiontaking	,	@old_isauto_v11mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	AND	sporttype=11

		SELECT	@v99spositiontaking_1	=	spositiontaking,	@v99apositiontaking_1	=	apositiontaking,	@auto_v99spositiontaking_mem_1	=	autopositiontaking,	@isauto_v99spositiontaking_mem_1	=	isautopositiontaking,	@old_v99mpositiontaking_1	=	mpositiontaking	,	@old_auto_v99mpositiontaking_mem_1	=	autompositiontaking	,	@old_isauto_v99mpositiontaking_mem_1	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=1	AND	sporttype=99
		SELECT	@v99spositiontaking_2	=	spositiontaking,	@v99apositiontaking_2	=	apositiontaking,	@auto_v99spositiontaking_mem_2	=	autopositiontaking,	@isauto_v99spositiontaking_mem_2	=	isautopositiontaking,	@old_v99mpositiontaking_2	=	mpositiontaking	,	@old_auto_v99mpositiontaking_mem_2	=	autompositiontaking	,	@old_isauto_v99mpositiontaking_mem_2	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=2	AND	sporttype=99
		SELECT	@v99spositiontaking_3	=	spositiontaking,	@v99apositiontaking_3	=	apositiontaking,	@auto_v99spositiontaking_mem_3	=	autopositiontaking,	@isauto_v99spositiontaking_mem_3	=	isautopositiontaking,	@old_v99mpositiontaking_3	=	mpositiontaking	,	@old_auto_v99mpositiontaking_mem_3	=	autompositiontaking	,	@old_isauto_v99mpositiontaking_mem_3	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=3	AND	sporttype=99
		SELECT	@v99spositiontaking_20	=	spositiontaking,	@v99apositiontaking_20	=	apositiontaking,	@auto_v99spositiontaking_mem_20	=	autopositiontaking,	@isauto_v99spositiontaking_mem_20	=	isautopositiontaking,	@old_v99mpositiontaking_20	=	mpositiontaking	,	@old_auto_v99mpositiontaking_mem_20	=	autompositiontaking	,	@old_isauto_v99mpositiontaking_mem_20	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=20	AND	sporttype=99
		SELECT	@v99spositiontaking_9999	=	spositiontaking,	@v99apositiontaking_9999	=	apositiontaking,	@auto_v99spositiontaking_mem_9999	=	autopositiontaking,	@isauto_v99spositiontaking_mem_9999	=	isautopositiontaking,	@old_v99mpositiontaking_9999	=	mpositiontaking	,	@old_auto_v99mpositiontaking_mem_9999	=	autompositiontaking	,	@old_isauto_v99mpositiontaking_mem_9999	=	isautompositiontaking	FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9999	AND	sporttype=99

		-- mixed sports
		SELECT	@v99spositiontaking_9	=	spositiontaking,	
		        @v99apositiontaking_9	=	apositiontaking,	
		        @auto_v99spositiontaking_mem_9	=	autopositiontaking,
			    @isauto_v99spositiontaking_mem_9	=	isautopositiontaking,
			    @old_v99mpositiontaking_9	=	mpositiontaking	,	
			    @old_auto_v99mpositiontaking_mem_9	=	autompositiontaking	,	
			    @old_isauto_v99mpositiontaking_mem_9	=	isautompositiontaking	
		FROM	custsetting	WITH	(NOLOCK)	WHERE	custid	=	@custid	AND	bettype=9	AND	sporttype=99

		--m3,u3,i3
		SELECT @max_mapositiontaking_1 =mpositiontaking, @max_malivepositiontaking_1 =mlivepositiontaking, @auto_spositiontaking_1 = autopositiontaking, @auto_slivepositiontaking_1 = autolivepositiontaking, @isauto_spositiontaking_1 = isautopositiontaking, @isauto_slivepositiontaking_1 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=1
		SELECT @max_mapositiontaking_3 =mpositiontaking, @max_malivepositiontaking_3 =mlivepositiontaking, @auto_spositiontaking_3 = autopositiontaking, @auto_slivepositiontaking_3 = autolivepositiontaking, @isauto_spositiontaking_3 = isautopositiontaking, @isauto_slivepositiontaking_3 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=1
		SELECT @max_mapositiontaking_7 =mpositiontaking, @max_malivepositiontaking_7 =mlivepositiontaking, @auto_spositiontaking_7 = autopositiontaking, @auto_slivepositiontaking_7 = autolivepositiontaking, @isauto_spositiontaking_7 = isautopositiontaking, @isauto_slivepositiontaking_7 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=1
		SELECT @max_mapositiontaking_8 =mpositiontaking, @max_malivepositiontaking_8 =mlivepositiontaking, @auto_spositiontaking_8 = autopositiontaking, @auto_slivepositiontaking_8 = autolivepositiontaking, @isauto_spositiontaking_8 = isautopositiontaking, @isauto_slivepositiontaking_8 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=1
		SELECT @max_mapositiontaking_2 =mpositiontaking, @auto_spositiontaking_2 = autopositiontaking, @isauto_spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=1
		SELECT @max_mapositiontaking_4 =mpositiontaking, @auto_spositiontaking_4 = autopositiontaking, @isauto_spositiontaking_4 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=4 AND sporttype=1
		SELECT @max_mapositiontaking_5 =mpositiontaking, @auto_spositiontaking_5 = autopositiontaking, @isauto_spositiontaking_5 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=5 AND sporttype=1
		SELECT @max_mapositiontaking_6 =mpositiontaking, @auto_spositiontaking_6 = autopositiontaking, @isauto_spositiontaking_6 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=6 AND sporttype=1
		SELECT @max_mapositiontaking_9 =mpositiontaking, @auto_spositiontaking_9 = autopositiontaking, @isauto_spositiontaking_9 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=1
		SELECT @max_mapositiontaking_10 =mpositiontaking, @auto_spositiontaking_10 = autopositiontaking, @isauto_spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=1
		
		-- Outright PT for sports
		SELECT @max_v2mapositiontaking_10 =mpositiontaking, @auto_v2spositiontaking_10 = autopositiontaking, @isauto_v2spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=2
		SELECT @max_v3mapositiontaking_10 =mpositiontaking, @auto_v3spositiontaking_10 = autopositiontaking, @isauto_v3spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=3
		SELECT @max_v5mapositiontaking_10 =mpositiontaking, @auto_v5spositiontaking_10 = autopositiontaking, @isauto_v5spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=5
		SELECT @max_v8mapositiontaking_10 =mpositiontaking, @auto_v8spositiontaking_10 = autopositiontaking, @isauto_v8spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=8
		SELECT @max_v10mapositiontaking_10 =mpositiontaking, @auto_v10spositiontaking_10 = autopositiontaking, @isauto_v10spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=10
		SELECT @max_v11mapositiontaking_10 =mpositiontaking, @auto_v11spositiontaking_10 = autopositiontaking, @isauto_v11spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=11
		SELECT @max_v99mapositiontaking_10 =mpositiontaking, @auto_v99spositiontaking_10 = autopositiontaking, @isauto_v99spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=99
		
		SELECT @max_mapositiontaking_9999 =mpositiontaking, @auto_spositiontaking_9999 = autopositiontaking, @isauto_spositiontaking_9999 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=1

		SELECT @max_v2mapositiontaking_1 =mpositiontaking, @auto_v2spositiontaking_1 = autopositiontaking, @isauto_v2spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=2
		SELECT @max_v2mapositiontaking_2 =mpositiontaking, @auto_v2spositiontaking_2 = autopositiontaking, @isauto_v2spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=2
		SELECT @max_v2mapositiontaking_3 =mpositiontaking, @auto_v2spositiontaking_3 = autopositiontaking, @isauto_v2spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=2
		SELECT @max_v2mapositiontaking_7 =mpositiontaking, @auto_v2spositiontaking_7 = autopositiontaking, @isauto_v2spositiontaking_7 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=2
		SELECT @max_v2mapositiontaking_8 =mpositiontaking, @auto_v2spositiontaking_8 = autopositiontaking, @isauto_v2spositiontaking_8 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=2
		---SELECT @max_v2mapositiontaking_9 =mpositiontaking, @auto_v2spositiontaking_9 = autopositiontaking, @isauto_v2spositiontaking_9 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=2
		SELECT @max_v2mapositiontaking_20 =mpositiontaking, @auto_v2spositiontaking_20 = autopositiontaking, @isauto_v2spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=2
		SELECT @max_v2mapositiontaking_9999 =mpositiontaking, @auto_v2spositiontaking_9999 = autopositiontaking, @isauto_v2spositiontaking_9999 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=2

		SELECT @max_v3mapositiontaking_1 =mpositiontaking, @auto_v3spositiontaking_1 = autopositiontaking, @isauto_v3spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=3
		SELECT @max_v3mapositiontaking_2 =mpositiontaking, @auto_v3spositiontaking_2 = autopositiontaking, @isauto_v3spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=3
		SELECT @max_v3mapositiontaking_3 =mpositiontaking, @auto_v3spositiontaking_3 = autopositiontaking, @isauto_v3spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=3
		SELECT @max_v3mapositiontaking_20 =mpositiontaking, @auto_v3spositiontaking_20 = autopositiontaking, @isauto_v3spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=3

		SELECT @max_v5mapositiontaking_1 =mpositiontaking, @auto_v5spositiontaking_1 = autopositiontaking, @isauto_v5spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=5
		SELECT @max_v5mapositiontaking_2 =mpositiontaking, @auto_v5spositiontaking_2 = autopositiontaking, @isauto_v5spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=5
		SELECT @max_v5mapositiontaking_3 =mpositiontaking, @auto_v5spositiontaking_3 = autopositiontaking, @isauto_v5spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=5
		SELECT @max_v5mapositiontaking_20 =mpositiontaking, @auto_v5spositiontaking_20 = autopositiontaking, @isauto_v5spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=5
		SELECT @max_v5mapositiontaking_9999 =mpositiontaking, @auto_v5spositiontaking_9999 = autopositiontaking, @isauto_v5spositiontaking_9999 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=5

		SELECT @max_v8mapositiontaking_1 =mpositiontaking, @auto_v8spositiontaking_1 = autopositiontaking, @isauto_v8spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=8
		SELECT @max_v8mapositiontaking_3 =mpositiontaking, @auto_v8spositiontaking_3 = autopositiontaking, @isauto_v8spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=8
		SELECT @max_v8mapositiontaking_20 =mpositiontaking, @auto_v8spositiontaking_20 = autopositiontaking, @isauto_v8spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=8

		SELECT @max_v10mapositiontaking_1 =mpositiontaking, @auto_v10spositiontaking_1 = autopositiontaking, @isauto_v10spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=10
		SELECT @max_v10mapositiontaking_2 =mpositiontaking, @auto_v10spositiontaking_2 = autopositiontaking, @isauto_v10spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=10
		SELECT @max_v10mapositiontaking_3 =mpositiontaking, @auto_v10spositiontaking_3 = autopositiontaking, @isauto_v10spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=10
		SELECT @max_v10mapositiontaking_20 =mpositiontaking, @auto_v10spositiontaking_20 = autopositiontaking, @isauto_v10spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=10

		SELECT @max_v11mapositiontaking_1 =mpositiontaking, @auto_v11spositiontaking_1 = autopositiontaking, @isauto_v11spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=11
		SELECT @max_v11mapositiontaking_20 =mpositiontaking, @auto_v11spositiontaking_20 = autopositiontaking, @isauto_v11spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=11

		SELECT @max_v99mapositiontaking_1 =mpositiontaking, @auto_v99spositiontaking_1 = autopositiontaking, @isauto_v99spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=99
		SELECT @max_v99mapositiontaking_2 =mpositiontaking, @auto_v99spositiontaking_2 = autopositiontaking, @isauto_v99spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=99
		SELECT @max_v99mapositiontaking_3 =mpositiontaking, @auto_v99spositiontaking_3 = autopositiontaking, @isauto_v99spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=99
		SELECT @max_v99mapositiontaking_20 =mpositiontaking, @auto_v99spositiontaking_20 = autopositiontaking, @isauto_v99spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=99
		SELECT @max_v99mapositiontaking_9999 =mpositiontaking, @auto_v99spositiontaking_9999 = autopositiontaking, @isauto_v99spositiontaking_9999 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=99

		---mixed sports
		SELECT @max_v99mapositiontaking_9 =mpositiontaking, 
			@auto_v99spositiontaking_9 = autopositiontaking, 
			@isauto_v99spositiontaking_9 = isautopositiontaking 
		FROM custsetting WITH (NOLOCK) 
		WHERE custid = @mrecommend AND bettype=9 AND sporttype=99

		--n3
		SELECT @min_mapositiontaking_1 = minpositiontaking, @min_malivepositiontaking_1 = minlivepositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=1
		SELECT @min_mapositiontaking_3 = minpositiontaking, @min_malivepositiontaking_3 = minlivepositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=1
		SELECT @min_mapositiontaking_7 = minpositiontaking, @min_malivepositiontaking_7 = minlivepositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=1
		SELECT @min_mapositiontaking_8 = minpositiontaking, @min_malivepositiontaking_8 = minlivepositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=1
		SELECT @min_mapositiontaking_2 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=1
		SELECT @min_mapositiontaking_4 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=4 AND sporttype=1
		SELECT @min_mapositiontaking_5 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=5 AND sporttype=1
		SELECT @min_mapositiontaking_6 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=6 AND sporttype=1
		SELECT @min_mapositiontaking_9 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=1
		SELECT @min_mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=1
		
		-- Outright PT for sports
		SELECT @min_v2mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=2
		SELECT @min_v3mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=3
		SELECT @min_v5mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=5
		SELECT @min_v8mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=8
		SELECT @min_v10mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=10
		SELECT @min_v11mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=11
		SELECT @min_v99mapositiontaking_10 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=99
		
		SELECT @min_mapositiontaking_9999 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=1

		SELECT @min_v2mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=2

		SELECT @min_v2mapositiontaking_2 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=2 
		SELECT @min_v2mapositiontaking_3 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=2
		SELECT @min_v2mapositiontaking_7 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=2
		SELECT @min_v2mapositiontaking_8 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=2
		--SELECT @min_v2mapositiontaking_9 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=2
		SELECT @min_v2mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=2
		SELECT @min_v2mapositiontaking_9999 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=2

		SELECT @min_v3mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=3
		SELECT @min_v3mapositiontaking_2 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=3 
		SELECT @min_v3mapositiontaking_3 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=3
		SELECT @min_v3mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=3

		SELECT @min_v5mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=5
		SELECT @min_v5mapositiontaking_2 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=5 
		SELECT @min_v5mapositiontaking_3 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=5
		SELECT @min_v5mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=5
		SELECT @min_v5mapositiontaking_9999 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=5

		SELECT @min_v8mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=8
		SELECT @min_v8mapositiontaking_3 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=8
		SELECT @min_v8mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=8

		SELECT @min_v10mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=10
		SELECT @min_v10mapositiontaking_2 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=10 
		SELECT @min_v10mapositiontaking_3 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=10
		SELECT @min_v10mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=10

		SELECT @min_v11mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=11
		SELECT @min_v11mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=11

		SELECT @min_v99mapositiontaking_1 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=99
		SELECT @min_v99mapositiontaking_2 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=99
		SELECT @min_v99mapositiontaking_3 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=99
		SELECT @min_v99mapositiontaking_20 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=99
		SELECT @min_v99mapositiontaking_9999 = minpositiontaking FROM custoverride WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=99

		-- mixed sports
		SELECT @min_v99mapositiontaking_9 = minpositiontaking 
		FROM custoverride WITH (NOLOCK)
		WHERE custid = @mrecommend 
		AND bettype=9 
		AND sporttype=99

		--m1_max = min(m3,m4), s4
		SELECT @max_mapositiontaking_1 = case when @max_mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_mapositiontaking_1 end ,@max_spositiontaking_1 = spositiontaking, @max_slivepositiontaking_1 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=1
		SELECT @max_mapositiontaking_3 = case when @max_mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_mapositiontaking_3 end ,@max_spositiontaking_3 = spositiontaking, @max_slivepositiontaking_3 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=1
		SELECT @max_mapositiontaking_7 = case when @max_mapositiontaking_7 > mpositiontaking then mpositiontaking else @max_mapositiontaking_7 end ,@max_spositiontaking_7 = spositiontaking, @max_slivepositiontaking_7 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype=1
		SELECT @max_mapositiontaking_8 = case when @max_mapositiontaking_8 > mpositiontaking then mpositiontaking else @max_mapositiontaking_8 end ,@max_spositiontaking_8 = spositiontaking, @max_slivepositiontaking_8 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype=1
		SELECT @max_mapositiontaking_2 = case when @max_mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_mapositiontaking_2 end ,@max_spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=1
		SELECT @max_mapositiontaking_4 = case when @max_mapositiontaking_4 > mpositiontaking then mpositiontaking else @max_mapositiontaking_4 end ,@max_spositiontaking_4 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=4 AND sporttype=1
		SELECT @max_mapositiontaking_5 = case when @max_mapositiontaking_5 > mpositiontaking then mpositiontaking else @max_mapositiontaking_5 end ,@max_spositiontaking_5 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=5 AND sporttype=1
		SELECT @max_mapositiontaking_6 = case when @max_mapositiontaking_6 > mpositiontaking then mpositiontaking else @max_mapositiontaking_6 end ,@max_spositiontaking_6 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=6 AND sporttype=1
		SELECT @max_mapositiontaking_9 = case when @max_mapositiontaking_9 > mpositiontaking then mpositiontaking else @max_mapositiontaking_9 end ,@max_spositiontaking_9 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=1
		SELECT @max_mapositiontaking_10 = case when @max_mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_mapositiontaking_10 end ,@max_spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=1
		
		-- Outright PT for sports
		SELECT @max_v2mapositiontaking_10 = case when @max_v2mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_10 end ,@max_v2spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=2
		SELECT @max_v3mapositiontaking_10 = case when @max_v3mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_10 end ,@max_v3spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=3
		SELECT @max_v5mapositiontaking_10 = case when @max_v5mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_10 end ,@max_v5spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=5
		SELECT @max_v8mapositiontaking_10 = case when @max_v8mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_10 end ,@max_v8spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=8
		SELECT @max_v10mapositiontaking_10 = case when @max_v10mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_10 end ,@max_v10spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=10
		SELECT @max_v11mapositiontaking_10 = case when @max_v11mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v11mapositiontaking_10 end ,@max_v11spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=11
		SELECT @max_v99mapositiontaking_10 = case when @max_v99mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_10 end ,@max_v99spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=99
		
		SELECT @max_mapositiontaking_9999 = case when @max_mapositiontaking_9999 > mpositiontaking then mpositiontaking else @max_mapositiontaking_9999 end ,@max_spositiontaking_9999 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=1

		SELECT @max_v2mapositiontaking_1 = case when @max_v2mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_1 end ,@max_v2spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=2
		SELECT @max_v2mapositiontaking_2 = case when @max_v2mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_2 end ,@max_v2spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=2
		SELECT @max_v2mapositiontaking_3 = case when @max_v2mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_3 end ,@max_v2spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=2
		SELECT @max_v2mapositiontaking_7 = case when @max_v2mapositiontaking_7 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_7 end ,@max_v2spositiontaking_7 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype=2
		SELECT @max_v2mapositiontaking_8 = case when @max_v2mapositiontaking_8 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_8 end ,@max_v2spositiontaking_8 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype=2
		--SELECT @max_v2spositiontaking_9 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=2
		SELECT @max_v2mapositiontaking_20 = case when @max_v2mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_20 end ,@max_v2spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=2
		SELECT @max_v2mapositiontaking_9999 = case when @max_v2mapositiontaking_9999 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_9999 end ,@max_v2spositiontaking_9999 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=2

		SELECT @max_v3mapositiontaking_1 = case when @max_v3mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_1 end ,@max_v3spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=3
		SELECT @max_v3mapositiontaking_2 = case when @max_v3mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_2 end ,@max_v3spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=3
		SELECT @max_v3mapositiontaking_3 = case when @max_v3mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_3 end ,@max_v3spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=3
		SELECT @max_v3mapositiontaking_20 = case when @max_v3mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_20 end ,@max_v3spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=3

		SELECT @max_v5mapositiontaking_1 = case when @max_v5mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_1 end ,@max_v5spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=5
		SELECT @max_v5mapositiontaking_2 = case when @max_v5mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_2 end ,@max_v5spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=5
		SELECT @max_v5mapositiontaking_3 = case when @max_v5mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_3 end ,@max_v5spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=5
		SELECT @max_v5mapositiontaking_20 = case when @max_v5mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_20 end ,@max_v5spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=5
		SELECT @max_v5mapositiontaking_9999 = case when @max_v5mapositiontaking_9999 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_9999 end ,@max_v5spositiontaking_9999 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=5

		SELECT @max_v8mapositiontaking_1 = case when @max_v8mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_1 end ,@max_v8spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=8
		SELECT @max_v8mapositiontaking_3 = case when @max_v8mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_3 end ,@max_v8spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=8
		SELECT @max_v8mapositiontaking_20 = case when @max_v8mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_20 end ,@max_v8spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=8

		SELECT @max_v10mapositiontaking_1 = case when @max_v10mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_1 end ,@max_v10spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=10
		SELECT @max_v10mapositiontaking_2 = case when @max_v10mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_2 end ,@max_v10spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=10
		SELECT @max_v10mapositiontaking_3 = case when @max_v10mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_3 end ,@max_v10spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=10
		SELECT @max_v10mapositiontaking_20 = case when @max_v10mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_20 end ,@max_v10spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=10

		SELECT @max_v11mapositiontaking_1 = case when @max_v11mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v11mapositiontaking_1 end ,@max_v11spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=11
		SELECT @max_v11mapositiontaking_20 = case when @max_v11mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v11mapositiontaking_20 end ,@max_v11spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=11

		SELECT @max_v99mapositiontaking_1 = case when @max_v99mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_1 end ,@max_v99spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=99
		SELECT @max_v99mapositiontaking_2 = case when @max_v99mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_2 end ,@max_v99spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=99
		SELECT @max_v99mapositiontaking_3 = case when @max_v99mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_3 end ,@max_v99spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=99
		SELECT @max_v99mapositiontaking_20 = case when @max_v99mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_20 end ,@max_v99spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=99
		SELECT @max_v99mapositiontaking_9999 = case when @max_v99mapositiontaking_9999 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_9999 end ,@max_v99spositiontaking_9999 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=99
		-- mixed sports
		SELECT @max_v99mapositiontaking_9 = case when 
														@max_v99mapositiontaking_9 > mpositiontaking 
															then mpositiontaking 
												else @max_v99mapositiontaking_9 
											end ,
				@max_v99spositiontaking_9 = spositiontaking 
		FROM custsetting WITH (NOLOCK) 
		WHERE custid = @srecommend AND bettype=9 AND sporttype=99

		--um2
		SELECT 
			@auto_mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_4 = MAX(CASE WHEN acs.bettype = 4 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_5 = MAX(CASE WHEN acs.bettype = 5 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_6 = MAX(CASE WHEN acs.bettype = 6 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			@auto_mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			
			-- Outright PT for sports
			@auto_v2mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v3mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=3 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v5mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=5 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v8mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=8 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v10mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=10 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v11mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=11 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v99mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),
			
			@auto_mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=1 THEN acs.autompositiontaking ELSE 0 END),
			
			@auto_mlivepositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=1 THEN acs.autolivempositiontaking ELSE 0 END),
			@auto_mlivepositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=1 THEN acs.autolivempositiontaking ELSE 0 END),
			@auto_mlivepositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=1 THEN acs.autolivempositiontaking ELSE 0 END),
			@auto_mlivepositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=1 THEN acs.autolivempositiontaking ELSE 0 END),

			@auto_v2mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v2mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v2mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v2mpositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v2mpositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
		--	@auto_v2mpositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v2mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v2mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=2 THEN acs.autompositiontaking ELSE 0 END),

			@auto_v3mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=3 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v3mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=3 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v3mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=3 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v3mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=3 THEN acs.autompositiontaking ELSE 0 END),

			@auto_v5mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=5 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v5mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=5 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v5mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=5 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v5mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=5 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v5mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=5 THEN acs.autompositiontaking ELSE 0 END),

			@auto_v8mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=8 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v8mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=8 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v8mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=8 THEN acs.autompositiontaking ELSE 0 END),

			@auto_v10mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=10 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v10mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=10 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v10mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=10 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v10mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=10 THEN acs.autompositiontaking ELSE 0 END),

			@auto_v11mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=11 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v11mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=11 THEN acs.autompositiontaking ELSE 0 END),

			@auto_v99mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v99mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v99mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v99mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),
			@auto_v99mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),
			-- mixed sports
			@auto_v99mpositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=99 THEN acs.autompositiontaking ELSE 0 END),

			--a2	
			@max_apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_4 = MAX(CASE WHEN acs.bettype = 4 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_5 = MAX(CASE WHEN acs.bettype = 5 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_6 = MAX(CASE WHEN acs.bettype = 6 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			@max_apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			
			-- Outright PT for sports
			@max_v2apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v3apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=3 THEN acs.apositiontaking ELSE 0 END),
			@max_v5apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=5 THEN acs.apositiontaking ELSE 0 END),
			@max_v8apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=8 THEN acs.apositiontaking ELSE 0 END),
			@max_v10apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=10 THEN acs.apositiontaking ELSE 0 END),
			@max_v11apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=11 THEN acs.apositiontaking ELSE 0 END),
			@max_v99apositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			
			
			@max_apositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=1 THEN acs.apositiontaking ELSE 0 END),
			
			@max_alivepositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=1 THEN acs.alivepositiontaking ELSE 0 END),
			@max_alivepositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=1 THEN acs.alivepositiontaking ELSE 0 END),
			@max_alivepositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=1 THEN acs.alivepositiontaking ELSE 0 END),
			@max_alivepositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=1 THEN acs.alivepositiontaking ELSE 0 END),

			@max_v2apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v2apositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v2apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v2apositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v2apositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
		--	@max_v2apositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v2apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),
			@max_v2apositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=2 THEN acs.apositiontaking ELSE 0 END),

			@max_v3apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=3 THEN acs.apositiontaking ELSE 0 END),
			@max_v3apositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=3 THEN acs.apositiontaking ELSE 0 END),
			@max_v3apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=3 THEN acs.apositiontaking ELSE 0 END),
			@max_v3apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=3 THEN acs.apositiontaking ELSE 0 END),

			@max_v5apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=5 THEN acs.apositiontaking ELSE 0 END),
			@max_v5apositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=5 THEN acs.apositiontaking ELSE 0 END),
			@max_v5apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=5 THEN acs.apositiontaking ELSE 0 END),
			@max_v5apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=5 THEN acs.apositiontaking ELSE 0 END),
			@max_v5apositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=5 THEN acs.apositiontaking ELSE 0 END),

			@max_v8apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=8 THEN acs.apositiontaking ELSE 0 END),
			@max_v8apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=8 THEN acs.apositiontaking ELSE 0 END),
			@max_v8apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=8 THEN acs.apositiontaking ELSE 0 END),

			@max_v10apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=10 THEN acs.apositiontaking ELSE 0 END),
			@max_v10apositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=10 THEN acs.apositiontaking ELSE 0 END),
			@max_v10apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=10 THEN acs.apositiontaking ELSE 0 END),
			@max_v10apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=10 THEN acs.apositiontaking ELSE 0 END),

			@max_v11apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=11 THEN acs.apositiontaking ELSE 0 END),
			@max_v11apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=11 THEN acs.apositiontaking ELSE 0 END),

			@max_v99apositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			@max_v99apositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			@max_v99apositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			@max_v99apositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			@max_v99apositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			-- mixed sports
			@max_v99apositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=99 THEN acs.apositiontaking ELSE 0 END),
			

			--im2
			@isauto_mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_4 = MAX(CASE WHEN acs.bettype = 4 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_5 = MAX(CASE WHEN acs.bettype = 5 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_6 = MAX(CASE WHEN acs.bettype = 6 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),
			-- Outright PT for sports
			@isauto_v2mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v3mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=3 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v5mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=5 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v8mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=8 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v10mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=10 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v11mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=11 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v99mpositiontaking_10 = MAX(CASE WHEN acs.bettype = 10 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=1 THEN acs.isautompositiontaking ELSE 0 END),

			@isauto_mlivepositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=1 THEN acs.isautolivempositiontaking ELSE 0 END),			
			@isauto_mlivepositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=1 THEN acs.isautolivempositiontaking ELSE 0 END),
			@isauto_mlivepositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=1 THEN acs.isautolivempositiontaking ELSE 0 END),
			@isauto_mlivepositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=1 THEN acs.isautolivempositiontaking ELSE 0 END),
			
			@isauto_v2mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v2mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v2mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v2mpositiontaking_7 = MAX(CASE WHEN acs.bettype = 7 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v2mpositiontaking_8 = MAX(CASE WHEN acs.bettype = 8 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			--@isauto_v2mpositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v2mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v2mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=2 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_v3mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=3 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v3mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=3 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v3mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=3 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v3mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=3 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_v5mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=5 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v5mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=5 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v5mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=5 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v5mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=5 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v5mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=5 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_v8mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=8 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v8mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=8 THEN acs.isautompositiontaking ELSE 0 END),			
			@isauto_v8mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=8 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_v10mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=10 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v10mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=10 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v10mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=10 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v10mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=10 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_v11mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=11 THEN acs.isautompositiontaking ELSE 0 END),			
			@isauto_v11mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=11 THEN acs.isautompositiontaking ELSE 0 END),
			
			@isauto_v99mpositiontaking_1 = MAX(CASE WHEN acs.bettype = 1 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v99mpositiontaking_2 = MAX(CASE WHEN acs.bettype = 2 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v99mpositiontaking_3 = MAX(CASE WHEN acs.bettype = 3 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v99mpositiontaking_20 = MAX(CASE WHEN acs.bettype = 20 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v99mpositiontaking_9999 = MAX(CASE WHEN acs.bettype = 9999 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END),
			@isauto_v99mpositiontaking_9 = MAX(CASE WHEN acs.bettype = 9 AND acs.sporttype=99 THEN acs.isautompositiontaking ELSE 0 END)
		FROM custsetting acs WITH(NOLOCK)		
		WHERE acs.custid = @recommend
	
		SELECT 
			@max_mp_1 = @max_mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_2 = @max_mapositiontaking_2 - max(case when cs.bettype = 2 and cs.sporttype=1 then cs.apositiontaking else 0 end), 
			@max_mp_3 = @max_mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_4 = @max_mapositiontaking_4 - max(case when cs.bettype = 4 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_5 = @max_mapositiontaking_5 - max(case when cs.bettype = 5 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_6 = @max_mapositiontaking_6 - max(case when cs.bettype = 6 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_7 = @max_mapositiontaking_7 - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_8 = @max_mapositiontaking_8 - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_9 = @max_mapositiontaking_9 - max(case when cs.bettype = 9 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			@max_mp_10 = @max_mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			
			-- Outright PT for sports
			@max_v2mp_10 = @max_v2mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v3mp_10 = @max_v3mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=3 then cs.apositiontaking else 0 end),
			@max_v5mp_10 = @max_v5mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=5 then cs.apositiontaking else 0 end),
			@max_v8mp_10 = @max_v8mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=8 then cs.apositiontaking else 0 end),
			@max_v10mp_10 = @max_v10mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=10 then cs.apositiontaking else 0 end),
			@max_v11mp_10 = @max_v11mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=11 then cs.apositiontaking else 0 end),
			@max_v99mp_10 = @max_v99mapositiontaking_10 - max(case when cs.bettype = 10 and cs.sporttype=99 then cs.apositiontaking else 0 end),
			
			@max_mp_9999 = @max_mapositiontaking_9999 - max(case when cs.bettype = 9999 and cs.sporttype=1 then cs.apositiontaking else 0 end),
			
			@max_mlp_1 = @max_malivepositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
			@max_mlp_3 = @max_malivepositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
			@max_mlp_7 = @max_malivepositiontaking_7 - max(case when cs.bettype = 7 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
			@max_mlp_8 = @max_malivepositiontaking_8 - max(case when cs.bettype = 8 and cs.sporttype=1 then cs.alivepositiontaking else 0 end),
			
			--v2
			@max_v2mp_1 = @max_v2mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v2mp_2 = @max_v2mapositiontaking_2 - max(case when cs.bettype = 2 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v2mp_3 = @max_v2mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v2mp_7 = @max_v2mapositiontaking_7 - max(case when cs.bettype = 7 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v2mp_8 = @max_v2mapositiontaking_8 - max(case when cs.bettype = 8 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			--@max_v2mp_9 = @max_v2mapositiontaking_9 - max(case when cs.bettype = 9 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v2mp_20 = @max_v2mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			@max_v2mp_9999 = @max_v2mapositiontaking_9999 - max(case when cs.bettype = 9999 and cs.sporttype=2 then cs.apositiontaking else 0 end),
			
			--v3
			@max_v3mp_1 = @max_v3mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=3 then cs.apositiontaking else 0 end),
			@max_v3mp_2 = @max_v3mapositiontaking_2 - max(case when cs.bettype = 2 and cs.sporttype=3 then cs.apositiontaking else 0 end),
			@max_v3mp_3 = @max_v3mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=3 then cs.apositiontaking else 0 end),
			@max_v3mp_20 = @max_v3mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=3 then cs.apositiontaking else 0 end),
			
			--v5
			@max_v5mp_1 = @max_v5mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=5 then cs.apositiontaking else 0 end),
			@max_v5mp_2 = @max_v5mapositiontaking_2 - max(case when cs.bettype = 2 and cs.sporttype=5 then cs.apositiontaking else 0 end),
			@max_v5mp_3 = @max_v5mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=5 then cs.apositiontaking else 0 end),
			@max_v5mp_20 = @max_v5mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=5 then cs.apositiontaking else 0 end),
			@max_v5mp_9999 = @max_v5mapositiontaking_9999 - max(case when cs.bettype = 9999 and cs.sporttype=5 then cs.apositiontaking else 0 end),

			--v8
			@max_v8mp_1 = @max_v8mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=8 then cs.apositiontaking else 0 end),			
			@max_v8mp_3 = @max_v8mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=8 then cs.apositiontaking else 0 end),
			@max_v8mp_20 = @max_v8mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=8 then cs.apositiontaking else 0 end),

			--v10
			@max_v10mp_1 = @max_v10mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=10 then cs.apositiontaking else 0 end),
			@max_v10mp_2 = @max_v10mapositiontaking_2 - max(case when cs.bettype = 2 and cs.sporttype=10 then cs.apositiontaking else 0 end),
			@max_v10mp_3 = @max_v10mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=10 then cs.apositiontaking else 0 end),
			@max_v10mp_20 = @max_v10mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=10 then cs.apositiontaking else 0 end),

			--v11
			@max_v11mp_1 = @max_v11mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=11 then cs.apositiontaking else 0 end),
			@max_v11mp_20 = @max_v11mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=11 then cs.apositiontaking else 0 end),
		
			--v99
			@max_v99mp_1 = @max_v99mapositiontaking_1 - max(case when cs.bettype = 1 and cs.sporttype=99 then cs.apositiontaking else 0 end),
			@max_v99mp_2 = @max_v99mapositiontaking_2 - max(case when cs.bettype = 2 and cs.sporttype=99 then cs.apositiontaking else 0 end),
			@max_v99mp_3 = @max_v99mapositiontaking_3 - max(case when cs.bettype = 3 and cs.sporttype=99 then cs.apositiontaking else 0 end),
			@max_v99mp_20 = @max_v99mapositiontaking_20 - max(case when cs.bettype = 20 and cs.sporttype=99 then cs.apositiontaking else 0 end),
			@max_v99mp_9999 = @max_v99mapositiontaking_9999 - max(case when cs.bettype = 9999 and cs.sporttype=99 then cs.apositiontaking else 0 end),
			@max_v99mp_9 = @max_v99mapositiontaking_9 - max(case when cs.bettype = 9 and cs.sporttype=99 then cs.apositiontaking else 0 end)
			
		FROM 
			CustSetting cs WITH(NOLOCK) 
		WHERE 
			cs.custid = @custid		
		
		--------------------------------------------------------------------------------				
		--m1_min = max(n3 - a1	,0)
		SELECT 
			@min_mp_1 = CASE WHEN @min_mapositiontaking_1 - @apositiontaking_1 > 0 THEN @min_mapositiontaking_1 - @apositiontaking_1 ELSE 0 END,
			@min_mp_2 = CASE WHEN @min_mapositiontaking_2 - @apositiontaking_2 > 0 THEN @min_mapositiontaking_2 - @apositiontaking_2 ELSE 0 END,
			@min_mp_3 = CASE WHEN @min_mapositiontaking_3 - @apositiontaking_3 > 0 THEN @min_mapositiontaking_3 - @apositiontaking_3 ELSE 0 END,
			@min_mp_4 = CASE WHEN @min_mapositiontaking_4 - @apositiontaking_4 > 0 THEN @min_mapositiontaking_4 - @apositiontaking_4 ELSE 0 END,
			@min_mp_5 = CASE WHEN @min_mapositiontaking_5 - @apositiontaking_5 > 0 THEN @min_mapositiontaking_5 - @apositiontaking_5 ELSE 0 END,
			@min_mp_6 = CASE WHEN @min_mapositiontaking_6 - @apositiontaking_6 > 0 THEN @min_mapositiontaking_6 - @apositiontaking_6 ELSE 0 END,
			@min_mp_7 = CASE WHEN @min_mapositiontaking_7 - @apositiontaking_7 > 0 THEN @min_mapositiontaking_7 - @apositiontaking_7 ELSE 0 END,
			@min_mp_8 = CASE WHEN @min_mapositiontaking_8 - @apositiontaking_8 > 0 THEN @min_mapositiontaking_8 - @apositiontaking_8 ELSE 0 END,
			@min_mp_9 = CASE WHEN @min_mapositiontaking_9 - @apositiontaking_9 > 0 THEN @min_mapositiontaking_9 - @apositiontaking_9 ELSE 0 END,
			@min_mp_10 = CASE WHEN @min_mapositiontaking_10 - @apositiontaking_10 > 0 THEN @min_mapositiontaking_10 - @apositiontaking_10 ELSE 0 END,
			
			-- Outright PT for sports
			@min_v2mp_10 = CASE WHEN @min_v2mapositiontaking_10 - @v2apositiontaking_10 > 0 THEN @min_v2mapositiontaking_10 - @v2apositiontaking_10 ELSE 0 END,
			@min_v3mp_10 = CASE WHEN @min_v3mapositiontaking_10 - @v3apositiontaking_10 > 0 THEN @min_v3mapositiontaking_10 - @v3apositiontaking_10 ELSE 0 END,
			@min_v5mp_10 = CASE WHEN @min_v5mapositiontaking_10 - @v5apositiontaking_10 > 0 THEN @min_v5mapositiontaking_10 - @v5apositiontaking_10 ELSE 0 END,
			@min_v8mp_10 = CASE WHEN @min_v8mapositiontaking_10 - @v8apositiontaking_10 > 0 THEN @min_v8mapositiontaking_10 - @v8apositiontaking_10 ELSE 0 END,
			@min_v10mp_10 = CASE WHEN @min_v10mapositiontaking_10 - @v10apositiontaking_10 > 0 THEN @min_v10mapositiontaking_10 - @v10apositiontaking_10 ELSE 0 END,
			@min_v11mp_10 = CASE WHEN @min_v11mapositiontaking_10 - @v11apositiontaking_10 > 0 THEN @min_v11mapositiontaking_10 - @v11apositiontaking_10 ELSE 0 END,
			@min_v99mp_10 = CASE WHEN @min_v99mapositiontaking_10 - @v99apositiontaking_10 > 0 THEN @min_v99mapositiontaking_10 - @v99apositiontaking_10 ELSE 0 END,
			
			@min_mp_9999 = CASE WHEN @min_mapositiontaking_9999 - @apositiontaking_9999 > 0 THEN @min_mapositiontaking_9999 - @apositiontaking_9999 ELSE 0 END,

			@min_mlp_1 = CASE WHEN @min_malivepositiontaking_1 - @alivepositiontaking_1 > 0 THEN @min_malivepositiontaking_1 - @alivepositiontaking_1 ELSE 0 END,
			@min_mlp_3 = CASE WHEN @min_malivepositiontaking_3 - @alivepositiontaking_3 > 0 THEN @min_malivepositiontaking_3 - @alivepositiontaking_3 ELSE 0 END,
			@min_mlp_7 = CASE WHEN @min_malivepositiontaking_7 - @alivepositiontaking_7 > 0 THEN @min_malivepositiontaking_7 - @alivepositiontaking_7 ELSE 0 END,
			@min_mlp_8 = CASE WHEN @min_malivepositiontaking_8 - @alivepositiontaking_8 > 0 THEN @min_malivepositiontaking_8 - @alivepositiontaking_8 ELSE 0 END,
			
			@min_v2mp_1 = CASE WHEN @min_v2mapositiontaking_1 - @v2apositiontaking_1 > 0 THEN @min_v2mapositiontaking_1 - @v2apositiontaking_1 ELSE 0 END,
			@min_v2mp_2 = CASE WHEN @min_v2mapositiontaking_2 - @v2apositiontaking_2 > 0 THEN @min_v2mapositiontaking_2 - @v2apositiontaking_2 ELSE 0 END,
			@min_v2mp_3 = CASE WHEN @min_v2mapositiontaking_3 - @v2apositiontaking_3 > 0 THEN @min_v2mapositiontaking_3 - @v2apositiontaking_3 ELSE 0 END,
			@min_v2mp_7 = CASE WHEN @min_v2mapositiontaking_7 - @v2apositiontaking_7 > 0 THEN @min_v2mapositiontaking_7 - @v2apositiontaking_7 ELSE 0 END,
			@min_v2mp_8 = CASE WHEN @min_v2mapositiontaking_8 - @v2apositiontaking_8 > 0 THEN @min_v2mapositiontaking_8 - @v2apositiontaking_8 ELSE 0 END,
			--@min_v2mp_9 = CASE WHEN @min_v2mapositiontaking_9 - @v2apositiontaking_9 > 0 THEN @min_v2mapositiontaking_9 - @v2apositiontaking_9 ELSE 0 END,
			@min_v2mp_20 = CASE WHEN @min_v2mapositiontaking_20 - @v2apositiontaking_20 > 0 THEN @min_v2mapositiontaking_20 - @v2apositiontaking_20 ELSE 0 END,
			@min_v2mp_9999 = CASE WHEN @min_v2mapositiontaking_9999 - @v2apositiontaking_9999 > 0 THEN @min_v2mapositiontaking_9999 - @v2apositiontaking_9999 ELSE 0 END,
			
			@min_v3mp_1 = CASE WHEN @min_v3mapositiontaking_1 - @v3apositiontaking_1 > 0 THEN @min_v3mapositiontaking_1 - @v3apositiontaking_1 ELSE 0 END,
			@min_v3mp_2 = CASE WHEN @min_v3mapositiontaking_2 - @v3apositiontaking_2 > 0 THEN @min_v3mapositiontaking_2 - @v3apositiontaking_2 ELSE 0 END,
			@min_v3mp_3 = CASE WHEN @min_v3mapositiontaking_3 - @v3apositiontaking_3 > 0 THEN @min_v3mapositiontaking_3 - @v3apositiontaking_3 ELSE 0 END,
			@min_v3mp_20 = CASE WHEN @min_v3mapositiontaking_20 - @v3apositiontaking_20 > 0 THEN @min_v3mapositiontaking_20 - @v3apositiontaking_20 ELSE 0 END,
			
			@min_v5mp_1 = CASE WHEN @min_v5mapositiontaking_1 - @v5apositiontaking_1 > 0 THEN @min_v5mapositiontaking_1 - @v5apositiontaking_1 ELSE 0 END,
			@min_v5mp_2 = CASE WHEN @min_v5mapositiontaking_2 - @v5apositiontaking_2 > 0 THEN @min_v5mapositiontaking_2 - @v5apositiontaking_2 ELSE 0 END,
			@min_v5mp_3 = CASE WHEN @min_v5mapositiontaking_3 - @v5apositiontaking_3 > 0 THEN @min_v5mapositiontaking_3 - @v5apositiontaking_3 ELSE 0 END,
			@min_v5mp_20 = CASE WHEN @min_v5mapositiontaking_20 - @v5apositiontaking_20 > 0 THEN @min_v5mapositiontaking_20 - @v5apositiontaking_20 ELSE 0 END,
			@min_v5mp_9999 = CASE WHEN @min_v5mapositiontaking_9999 - @v5apositiontaking_9999 > 0 THEN @min_v5mapositiontaking_9999 - @v5apositiontaking_9999 ELSE 0 END,

			@min_v8mp_1 = CASE WHEN @min_v8mapositiontaking_1 - @v8apositiontaking_1 > 0 THEN @min_v8mapositiontaking_1 - @v8apositiontaking_1 ELSE 0 END,			
			@min_v8mp_3 = CASE WHEN @min_v8mapositiontaking_3 - @v8apositiontaking_3 > 0 THEN @min_v8mapositiontaking_3 - @v8apositiontaking_3 ELSE 0 END,
			@min_v8mp_20 = CASE WHEN @min_v8mapositiontaking_20 - @v8apositiontaking_20 > 0 THEN @min_v8mapositiontaking_20 - @v8apositiontaking_20 ELSE 0 END,
			
			@min_v10mp_1 = CASE WHEN @min_v10mapositiontaking_1 - @v10apositiontaking_1 > 0 THEN @min_v10mapositiontaking_1 - @v10apositiontaking_1 ELSE 0 END,
			@min_v10mp_2 = CASE WHEN @min_v10mapositiontaking_2 - @v10apositiontaking_2 > 0 THEN @min_v10mapositiontaking_2 - @v10apositiontaking_2 ELSE 0 END,
			@min_v10mp_3 = CASE WHEN @min_v10mapositiontaking_3 - @v10apositiontaking_3 > 0 THEN @min_v10mapositiontaking_3 - @v10apositiontaking_3 ELSE 0 END,
			@min_v10mp_20 = CASE WHEN @min_v10mapositiontaking_20 - @v10apositiontaking_20 > 0 THEN @min_v10mapositiontaking_20 - @v10apositiontaking_20 ELSE 0 END,
			
			@min_v11mp_1 = CASE WHEN @min_v11mapositiontaking_1 - @v11apositiontaking_1 > 0 THEN @min_v11mapositiontaking_1 - @v11apositiontaking_1 ELSE 0 END,
			@min_v11mp_20 = CASE WHEN @min_v11mapositiontaking_20 - @v11apositiontaking_20 > 0 THEN @min_v11mapositiontaking_20 - @v11apositiontaking_20 ELSE 0 END,
			
			@min_v99mp_1 = CASE WHEN @min_v99mapositiontaking_1 - @v99apositiontaking_1 > 0 THEN @min_v99mapositiontaking_1 - @v99apositiontaking_1 ELSE 0 END,
			@min_v99mp_2 = CASE WHEN @min_v99mapositiontaking_2 - @v99apositiontaking_2 > 0 THEN @min_v99mapositiontaking_2 - @v99apositiontaking_2 ELSE 0 END,
			@min_v99mp_3 = CASE WHEN @min_v99mapositiontaking_3 - @v99apositiontaking_3 > 0 THEN @min_v99mapositiontaking_3 - @v99apositiontaking_3 ELSE 0 END,
			@min_v99mp_20 = CASE WHEN @min_v99mapositiontaking_20 - @v99apositiontaking_20 > 0 THEN @min_v99mapositiontaking_20 - @v99apositiontaking_20 ELSE 0 END,
			@min_v99mp_9999 = CASE WHEN @min_v99mapositiontaking_9999 - @v99apositiontaking_9999 > 0 THEN @min_v99mapositiontaking_9999 - @v99apositiontaking_9999 ELSE 0 END,
			@min_v99mp_9 = CASE WHEN @min_v99mapositiontaking_9 - @v99apositiontaking_9 > 0 THEN @min_v99mapositiontaking_9 - @v99apositiontaking_9 ELSE 0 END

		--Check if old_PT = new_PT return
		IF @mpositiontaking_1 = @old_mpositiontaking_1 AND
			@mpositiontaking_2 = @old_mpositiontaking_2 AND
			@mpositiontaking_3 = @old_mpositiontaking_3 AND
			@mpositiontaking_4 = @old_mpositiontaking_4 AND
			@mpositiontaking_5 = @old_mpositiontaking_5 AND
			@mpositiontaking_6 = @old_mpositiontaking_6 AND
			@mpositiontaking_7 = @old_mpositiontaking_7 AND
			@mpositiontaking_8 = @old_mpositiontaking_8 AND
			@mpositiontaking_9 = @old_mpositiontaking_9 AND
			@mpositiontaking_10 = @old_mpositiontaking_10 AND
			-- Outright PT for sports
			@v2mpositiontaking_10 = @old_v2mpositiontaking_10 AND
			@v3mpositiontaking_10 = @old_v3mpositiontaking_10 AND
			@v5mpositiontaking_10 = @old_v5mpositiontaking_10 AND
			@v8mpositiontaking_10 = @old_v8mpositiontaking_10 AND
			@v10mpositiontaking_10 = @old_v10mpositiontaking_10 AND
			@v11mpositiontaking_10 = @old_v11mpositiontaking_10 AND
			@v99mpositiontaking_10 = @old_v99mpositiontaking_10 AND
			
			@mpositiontaking_9999 = @old_mpositiontaking_9999 AND
			@mlivepositiontaking_1 = @old_mlivepositiontaking_1 AND
			@mlivepositiontaking_3 = @old_mlivepositiontaking_3 AND
			@mlivepositiontaking_7 = @old_mlivepositiontaking_7 AND
			@mlivepositiontaking_8 = @old_mlivepositiontaking_8 AND

			@v2mpositiontaking_1 = @old_v2mpositiontaking_1 AND
			@v2mpositiontaking_2 = @old_v2mpositiontaking_2 AND
			@v2mpositiontaking_3 = @old_v2mpositiontaking_3 AND
			@v2mpositiontaking_7 = @old_v2mpositiontaking_7 AND
			@v2mpositiontaking_8 = @old_v2mpositiontaking_8 AND
		--	@v2mpositiontaking_9 = @old_v2mpositiontaking_9 AND
			@v2mpositiontaking_20 = @old_v2mpositiontaking_20 AND
			@v2mpositiontaking_9999 = @old_v2mpositiontaking_9999 AND

			@v3mpositiontaking_1 = @old_v3mpositiontaking_1 AND
			@v3mpositiontaking_2 = @old_v3mpositiontaking_2 AND
			@v3mpositiontaking_3 = @old_v3mpositiontaking_3 AND
			@v3mpositiontaking_20 = @old_v3mpositiontaking_20 AND

			@v5mpositiontaking_1 = @old_v5mpositiontaking_1 AND
			@v5mpositiontaking_2 = @old_v5mpositiontaking_2 AND
			@v5mpositiontaking_3 = @old_v5mpositiontaking_3 AND
			@v5mpositiontaking_20 = @old_v5mpositiontaking_20 AND
			@v5mpositiontaking_9999 = @old_v5mpositiontaking_9999 AND

			@v8mpositiontaking_1 = @old_v8mpositiontaking_1 AND
			@v8mpositiontaking_3 = @old_v8mpositiontaking_3 AND
			@v8mpositiontaking_20 = @old_v8mpositiontaking_20 AND

			@v10mpositiontaking_1 = @old_v10mpositiontaking_1 AND
			@v10mpositiontaking_2 = @old_v10mpositiontaking_2 AND
			@v10mpositiontaking_3 = @old_v10mpositiontaking_3 AND
			@v10mpositiontaking_20 = @old_v10mpositiontaking_20 AND

			@v11mpositiontaking_1 = @old_v11mpositiontaking_1 AND
			@v11mpositiontaking_20 = @old_v11mpositiontaking_20 AND

			@v99mpositiontaking_1 = @old_v99mpositiontaking_1 AND
			@v99mpositiontaking_2 = @old_v99mpositiontaking_2 AND
			@v99mpositiontaking_3 = @old_v99mpositiontaking_3 AND
			@v99mpositiontaking_20 = @old_v99mpositiontaking_20 AND
			@v99mpositiontaking_9999 = @old_v99mpositiontaking_9999 AND
			-- mixed sports
			@v99mpositiontaking_9 = @old_v99mpositiontaking_9 AND

			--um1
			@auto_mpositiontaking_mem_1 = @old_auto_mpositiontaking_mem_1 AND
			@auto_mpositiontaking_mem_2 = @old_auto_mpositiontaking_mem_2 AND
			@auto_mpositiontaking_mem_3 = @old_auto_mpositiontaking_mem_3 AND
			@auto_mpositiontaking_mem_4 = @old_auto_mpositiontaking_mem_4 AND
			@auto_mpositiontaking_mem_5 = @old_auto_mpositiontaking_mem_5 AND
			@auto_mpositiontaking_mem_6 = @old_auto_mpositiontaking_mem_6 AND
			@auto_mpositiontaking_mem_7 = @old_auto_mpositiontaking_mem_7 AND
			@auto_mpositiontaking_mem_8 = @old_auto_mpositiontaking_mem_8 AND
			@auto_mpositiontaking_mem_9 = @old_auto_mpositiontaking_mem_9 AND
			@auto_mpositiontaking_mem_10 = @old_auto_mpositiontaking_mem_10 AND
			-- Outright PT for sports
			@auto_v2mpositiontaking_mem_10 = @old_auto_v2mpositiontaking_mem_10 AND
			@auto_v3mpositiontaking_mem_10 = @old_auto_v3mpositiontaking_mem_10 AND
			@auto_v5mpositiontaking_mem_10 = @old_auto_v5mpositiontaking_mem_10 AND
			@auto_v8mpositiontaking_mem_10 = @old_auto_v8mpositiontaking_mem_10 AND
			@auto_v10mpositiontaking_mem_10 = @old_auto_v10mpositiontaking_mem_10 AND
			@auto_v11mpositiontaking_mem_10 = @old_auto_v11mpositiontaking_mem_10 AND
			@auto_v99mpositiontaking_mem_10 = @old_auto_v99mpositiontaking_mem_10 AND
			
			@auto_mpositiontaking_mem_9999 = @old_auto_mpositiontaking_mem_9999 AND
			@auto_mlivepositiontaking_mem_1 = @old_auto_mlivepositiontaking_mem_1 AND
			@auto_mlivepositiontaking_mem_3 = @old_auto_mlivepositiontaking_mem_3 AND
			@auto_mlivepositiontaking_mem_7 = @old_auto_mlivepositiontaking_mem_7 AND
			@auto_mlivepositiontaking_mem_8 = @old_auto_mlivepositiontaking_mem_8 AND
			
			@auto_v2mpositiontaking_mem_1 = @old_auto_v2mpositiontaking_mem_1 AND
			@auto_v2mpositiontaking_mem_2 = @old_auto_v2mpositiontaking_mem_2 AND
			@auto_v2mpositiontaking_mem_3 = @old_auto_v2mpositiontaking_mem_3 AND
			@auto_v2mpositiontaking_mem_7 = @old_auto_v2mpositiontaking_mem_7 AND
			@auto_v2mpositiontaking_mem_8 = @old_auto_v2mpositiontaking_mem_8 AND
		--	@auto_v2mpositiontaking_mem_9 = @old_auto_v2mpositiontaking_mem_9 AND
			@auto_v2mpositiontaking_mem_20 = @old_auto_v2mpositiontaking_mem_20 AND
			@auto_v2mpositiontaking_mem_9999 = @old_auto_v2mpositiontaking_mem_9999 AND

			@auto_v3mpositiontaking_mem_1 = @old_auto_v3mpositiontaking_mem_1 AND
			@auto_v3mpositiontaking_mem_2 = @old_auto_v3mpositiontaking_mem_2 AND
			@auto_v3mpositiontaking_mem_3 = @old_auto_v3mpositiontaking_mem_3 AND
			@auto_v3mpositiontaking_mem_20 = @old_auto_v3mpositiontaking_mem_20 AND

			@auto_v5mpositiontaking_mem_1 = @old_auto_v5mpositiontaking_mem_1 AND
			@auto_v5mpositiontaking_mem_2 = @old_auto_v5mpositiontaking_mem_2 AND
			@auto_v5mpositiontaking_mem_3 = @old_auto_v5mpositiontaking_mem_3 AND
			@auto_v5mpositiontaking_mem_20 = @old_auto_v5mpositiontaking_mem_20 AND
			@auto_v5mpositiontaking_mem_9999 = @old_auto_v5mpositiontaking_mem_9999 AND

			@auto_v8mpositiontaking_mem_1 = @old_auto_v8mpositiontaking_mem_1 AND
			@auto_v8mpositiontaking_mem_3 = @old_auto_v8mpositiontaking_mem_3 AND
			@auto_v8mpositiontaking_mem_20 = @old_auto_v8mpositiontaking_mem_20 AND

			@auto_v10mpositiontaking_mem_1 = @old_auto_v10mpositiontaking_mem_1 AND
			@auto_v10mpositiontaking_mem_2 = @old_auto_v10mpositiontaking_mem_2 AND
			@auto_v10mpositiontaking_mem_3 = @old_auto_v10mpositiontaking_mem_3 AND
			@auto_v10mpositiontaking_mem_20 = @old_auto_v10mpositiontaking_mem_20 AND

			@auto_v11mpositiontaking_mem_1 = @old_auto_v11mpositiontaking_mem_1 AND
			@auto_v11mpositiontaking_mem_20 = @old_auto_v11mpositiontaking_mem_20 AND

			@auto_v99mpositiontaking_mem_1 = @old_auto_v99mpositiontaking_mem_1 AND
			@auto_v99mpositiontaking_mem_2 = @old_auto_v99mpositiontaking_mem_2 AND
			@auto_v99mpositiontaking_mem_3 = @old_auto_v99mpositiontaking_mem_3 AND
			@auto_v99mpositiontaking_mem_20 = @old_auto_v99mpositiontaking_mem_20 AND
			@auto_v99mpositiontaking_mem_9999 = @old_auto_v99mpositiontaking_mem_9999 AND
			-- mixed sports
			@auto_v99mpositiontaking_mem_9 = @old_auto_v99mpositiontaking_mem_9 AND
		
			--im1
			@isauto_mpositiontaking_mem_1 = @old_isauto_mpositiontaking_mem_1 AND
			@isauto_mpositiontaking_mem_2 = @old_isauto_mpositiontaking_mem_2 AND
			@isauto_mpositiontaking_mem_3 = @old_isauto_mpositiontaking_mem_3 AND
			@isauto_mpositiontaking_mem_4 = @old_isauto_mpositiontaking_mem_4 AND
			@isauto_mpositiontaking_mem_5 = @old_isauto_mpositiontaking_mem_5 AND
			@isauto_mpositiontaking_mem_6 = @old_isauto_mpositiontaking_mem_6 AND
			@isauto_mpositiontaking_mem_7 = @old_isauto_mpositiontaking_mem_7 AND
			@isauto_mpositiontaking_mem_8 = @old_isauto_mpositiontaking_mem_8 AND
			@isauto_mpositiontaking_mem_9 = @old_isauto_mpositiontaking_mem_9 AND
			@isauto_mpositiontaking_mem_10 = @old_isauto_mpositiontaking_mem_10 AND
			
			-- Outright PT for sports
			@isauto_v2mpositiontaking_mem_10 = @old_isauto_v2mpositiontaking_mem_10 AND
			@isauto_v3mpositiontaking_mem_10 = @old_isauto_v3mpositiontaking_mem_10 AND
			@isauto_v5mpositiontaking_mem_10 = @old_isauto_v5mpositiontaking_mem_10 AND
			@isauto_v8mpositiontaking_mem_10 = @old_isauto_v8mpositiontaking_mem_10 AND
			@isauto_v10mpositiontaking_mem_10 = @old_isauto_v10mpositiontaking_mem_10 AND
			@isauto_v11mpositiontaking_mem_10 = @old_isauto_v11mpositiontaking_mem_10 AND
			@isauto_v99mpositiontaking_mem_10 = @old_isauto_v99mpositiontaking_mem_10 AND
			
			@isauto_mpositiontaking_mem_9999 = @old_isauto_mpositiontaking_mem_9999 AND
			@isauto_mlivepositiontaking_mem_1 = @old_isauto_mlivepositiontaking_mem_1 AND
			@isauto_mlivepositiontaking_mem_3 = @old_isauto_mlivepositiontaking_mem_3 AND
			@isauto_mlivepositiontaking_mem_7 = @old_isauto_mlivepositiontaking_mem_7 AND
			@isauto_mlivepositiontaking_mem_8 = @old_isauto_mlivepositiontaking_mem_8 AND

			@isauto_v2mpositiontaking_mem_1 = @old_isauto_v2mpositiontaking_mem_1 AND
			@isauto_v2mpositiontaking_mem_2 = @old_isauto_v2mpositiontaking_mem_2 AND
			@isauto_v2mpositiontaking_mem_3 = @old_isauto_v2mpositiontaking_mem_3 AND
			@isauto_v2mpositiontaking_mem_7 = @old_isauto_v2mpositiontaking_mem_7 AND
			@isauto_v2mpositiontaking_mem_8 = @old_isauto_v2mpositiontaking_mem_8 AND
		--	@isauto_v2mpositiontaking_mem_9 = @old_isauto_v2mpositiontaking_mem_9 AND
			@isauto_v2mpositiontaking_mem_20 = @old_isauto_v2mpositiontaking_mem_20 AND
			@isauto_v2mpositiontaking_mem_9999 = @old_isauto_v2mpositiontaking_mem_9999 AND

			@isauto_v3mpositiontaking_mem_1 = @old_isauto_v3mpositiontaking_mem_1 AND
			@isauto_v3mpositiontaking_mem_2 = @old_isauto_v3mpositiontaking_mem_2 AND
			@isauto_v3mpositiontaking_mem_3 = @old_isauto_v3mpositiontaking_mem_3 AND
			@isauto_v3mpositiontaking_mem_20 = @old_isauto_v3mpositiontaking_mem_20 AND

			@isauto_v5mpositiontaking_mem_1 = @old_isauto_v5mpositiontaking_mem_1 AND
			@isauto_v5mpositiontaking_mem_2 = @old_isauto_v5mpositiontaking_mem_2 AND
			@isauto_v5mpositiontaking_mem_3 = @old_isauto_v5mpositiontaking_mem_3 AND
			@isauto_v5mpositiontaking_mem_20 = @old_isauto_v5mpositiontaking_mem_20 AND
			@isauto_v5mpositiontaking_mem_9999 = @old_isauto_v5mpositiontaking_mem_9999 AND

			@isauto_v8mpositiontaking_mem_1 = @old_isauto_v8mpositiontaking_mem_1 AND
			@isauto_v8mpositiontaking_mem_3 = @old_isauto_v8mpositiontaking_mem_3 AND
			@isauto_v8mpositiontaking_mem_20 = @old_isauto_v8mpositiontaking_mem_20 AND

			@isauto_v10mpositiontaking_mem_1 = @old_isauto_v10mpositiontaking_mem_1 AND
			@isauto_v10mpositiontaking_mem_2 = @old_isauto_v10mpositiontaking_mem_2 AND
			@isauto_v10mpositiontaking_mem_3 = @old_isauto_v10mpositiontaking_mem_3 AND
			@isauto_v10mpositiontaking_mem_20 = @old_isauto_v10mpositiontaking_mem_20 AND

			@isauto_v11mpositiontaking_mem_1 = @old_isauto_v11mpositiontaking_mem_1 AND
			@isauto_v11mpositiontaking_mem_20 = @old_isauto_v11mpositiontaking_mem_20 AND

			@isauto_v99mpositiontaking_mem_1 = @old_isauto_v99mpositiontaking_mem_1 AND
			@isauto_v99mpositiontaking_mem_2 = @old_isauto_v99mpositiontaking_mem_2 AND
			@isauto_v99mpositiontaking_mem_3 = @old_isauto_v99mpositiontaking_mem_3 AND
			@isauto_v99mpositiontaking_mem_20 = @old_isauto_v99mpositiontaking_mem_20 AND 
			@isauto_v99mpositiontaking_mem_9999 = @old_isauto_v99mpositiontaking_mem_9999 AND 
			-- mixed sports
			@isauto_v99mpositiontaking_mem_9 = @old_isauto_v99mpositiontaking_mem_9 
		BEGIN
			Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
			RETURN 
		END

		if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
			BEGIN --@UpdatePositiontaking 
				if 
					@mpositiontaking_1  <0 OR @mpositiontaking_1  >0.93
					OR @mpositiontaking_2  <0 OR @mpositiontaking_2  >0.93
					OR @mpositiontaking_3  <0 OR @mpositiontaking_3  >0.93
					OR @mpositiontaking_4  <0 OR @mpositiontaking_4  >0.93
					OR @mpositiontaking_5  <0 OR @mpositiontaking_5  >0.93
					OR @mpositiontaking_6  <0 OR @mpositiontaking_6  >0.93
					OR @mpositiontaking_7  <0 OR @mpositiontaking_7  >0.93
					OR @mpositiontaking_8  <0 OR @mpositiontaking_8  >0.93
					OR @mpositiontaking_9  <0 OR @mpositiontaking_9  >0.93
					OR @mpositiontaking_10 <0 OR @mpositiontaking_10 >0.93
					OR @mpositiontaking_9999 <0 OR @mpositiontaking_9999 >0.93
					OR @mlivepositiontaking_1  <0 OR @mlivepositiontaking_1  >0.93
					OR @mlivepositiontaking_3  <0 OR @mlivepositiontaking_3  >0.93
					OR @mlivepositiontaking_7  <0 OR @mlivepositiontaking_7  >0.93
					OR @mlivepositiontaking_8  <0 OR @mlivepositiontaking_8  >0.93
				BEGIN
						SELECT @isvalid = 0, @ErrCode_cur = 5
						SELECT @ErrMsg_cur = 	CASE @Language 
											WHEN 'E' THEN 'Wrong position taking.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
									END
						SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
								
						RETURN
				END
			
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_mpositiontaking_mem_1 = 1 AND @old_isauto_mpositiontaking_mem_1 = 0)
				OR (@isauto_mpositiontaking_mem_2 = 1 AND @old_isauto_mpositiontaking_mem_2 = 0)
				OR (@isauto_mpositiontaking_mem_3 = 1 AND @old_isauto_mpositiontaking_mem_3 = 0)
				OR (@isauto_mpositiontaking_mem_4 = 1 AND @old_isauto_mpositiontaking_mem_4 = 0)
				OR (@isauto_mpositiontaking_mem_5 = 1 AND @old_isauto_mpositiontaking_mem_5 = 0)
				OR (@isauto_mpositiontaking_mem_6 = 1 AND @old_isauto_mpositiontaking_mem_6 = 0)
				OR (@isauto_mpositiontaking_mem_7 = 1 AND @old_isauto_mpositiontaking_mem_7 = 0)
				OR (@isauto_mpositiontaking_mem_8 = 1 AND @old_isauto_mpositiontaking_mem_8 = 0)
				OR (@isauto_mpositiontaking_mem_9 = 1 AND @old_isauto_mpositiontaking_mem_9 = 0)
				OR (@isauto_mpositiontaking_mem_10 = 1 AND @old_isauto_mpositiontaking_mem_10 = 0)
				OR (@isauto_mlivepositiontaking_mem_1 = 1 AND @old_isauto_mlivepositiontaking_mem_1 = 0)
				OR (@isauto_mlivepositiontaking_mem_3 = 1 AND @old_isauto_mlivepositiontaking_mem_3 = 0)
				OR (@isauto_mlivepositiontaking_mem_7 = 1 AND @old_isauto_mlivepositiontaking_mem_7 = 0)
				OR (@isauto_mlivepositiontaking_mem_8 = 1 AND @old_isauto_mlivepositiontaking_mem_8 = 0)				
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END	
			
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(	SELECT 1 AS sporttype, 1 AS bettype, @auto_mpositiontaking_mem_1 AS autopositiontaking, @isauto_mpositiontaking_mem_1 AS isautopositiontaking, @auto_mlivepositiontaking_mem_1 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_1 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 3 AS bettype, @auto_mpositiontaking_mem_3 AS autopositiontaking, @isauto_mpositiontaking_mem_3 AS isautopositiontaking, @auto_mlivepositiontaking_mem_3 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_3 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 7 AS bettype, @auto_mpositiontaking_mem_7 AS autopositiontaking, @isauto_mpositiontaking_mem_7 AS isautopositiontaking, @auto_mlivepositiontaking_mem_7 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_7 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 8 AS bettype, @auto_mpositiontaking_mem_8 AS autopositiontaking, @isauto_mpositiontaking_mem_8 AS isautopositiontaking, @auto_mlivepositiontaking_mem_8 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_8 AS isautolivepositiontaking

					UNION ALL		SELECT 1 AS sporttype, 2 AS bettype, @auto_mpositiontaking_mem_2 AS autopositiontaking, @isauto_mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 4 AS bettype, @auto_mpositiontaking_mem_4 AS autopositiontaking, @isauto_mpositiontaking_mem_4 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 5 AS bettype, @auto_mpositiontaking_mem_5 AS autopositiontaking, @isauto_mpositiontaking_mem_5 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 6 AS bettype, @auto_mpositiontaking_mem_6 AS autopositiontaking, @isauto_mpositiontaking_mem_6 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 9 AS bettype, @auto_mpositiontaking_mem_9 AS autopositiontaking, @isauto_mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 10 AS bettype, @auto_mpositiontaking_mem_10 AS autopositiontaking, @isauto_mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 9999 AS bettype, @auto_mpositiontaking_mem_9999 AS autopositiontaking, @isauto_mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END

		--Check um1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(	SELECT 1 AS sporttype, 1 AS bettype, @max_mapositiontaking_1 AS maxmpositiontaking, @auto_mpositiontaking_mem_1 AS autopositiontaking, @isauto_mpositiontaking_mem_1 AS isautopositiontaking, @auto_mlivepositiontaking_mem_1 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_1 AS isautolivepositiontaking, @max_malivepositiontaking_1 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 3 AS bettype, @max_mapositiontaking_3 AS maxmpositiontaking	,@auto_mpositiontaking_mem_3 AS autopositiontaking, @isauto_mpositiontaking_mem_3 AS isautopositiontaking, @auto_mlivepositiontaking_mem_3 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_3 AS isautolivepositiontaking, @max_malivepositiontaking_3 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 7 AS bettype, @max_mapositiontaking_7 AS maxmpositiontaking	,@auto_mpositiontaking_mem_7 AS autopositiontaking, @isauto_mpositiontaking_mem_7 AS isautopositiontaking, @auto_mlivepositiontaking_mem_7 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_7 AS isautolivepositiontaking, @max_malivepositiontaking_7 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 8 AS bettype, @max_mapositiontaking_8 AS maxmpositiontaking	,@auto_mpositiontaking_mem_8 AS autopositiontaking, @isauto_mpositiontaking_mem_8 AS isautopositiontaking, @auto_mlivepositiontaking_mem_8 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_8 AS isautolivepositiontaking, @max_malivepositiontaking_8 AS maxmlivepositiontaking

					UNION ALL		SELECT 1 AS sporttype, 2 AS bettype, @max_mapositiontaking_2 AS maxmpositiontaking	,@auto_mpositiontaking_mem_2 AS autopositiontaking, @isauto_mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 4 AS bettype, @max_mapositiontaking_4 AS maxmpositiontaking	,@auto_mpositiontaking_mem_4 AS autopositiontaking, @isauto_mpositiontaking_mem_4 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 5 AS bettype, @max_mapositiontaking_5 AS maxmpositiontaking	,@auto_mpositiontaking_mem_5 AS autopositiontaking, @isauto_mpositiontaking_mem_5 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 6 AS bettype, @max_mapositiontaking_6 AS maxmpositiontaking	,@auto_mpositiontaking_mem_6 AS autopositiontaking, @isauto_mpositiontaking_mem_6 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 9 AS bettype, @max_mapositiontaking_9 AS maxmpositiontaking	,@auto_mpositiontaking_mem_9 AS autopositiontaking, @isauto_mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 10 AS bettype, @max_mapositiontaking_10 AS maxmpositiontaking	,@auto_mpositiontaking_mem_10 AS autopositiontaking, @isauto_mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 9999 AS bettype, @max_mapositiontaking_9999 AS maxmpositiontaking	,@auto_mpositiontaking_mem_9999 AS autopositiontaking, @isauto_mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
		WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 7,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END		
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
										
			RETURN
		END
		
		--Check um1>= um1_min(= m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(	SELECT 1 AS sporttype, 1 AS bettype, @min_mp_1 AS minmpositiontaking, @auto_mpositiontaking_mem_1 AS autopositiontaking, @isauto_mpositiontaking_mem_1 AS isautopositiontaking, @auto_mlivepositiontaking_mem_1 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_1 AS isautolivepositiontaking, @min_mlp_1 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 3 AS bettype, @min_mp_3 AS minmpositiontaking	,@auto_mpositiontaking_mem_3 AS autopositiontaking, @isauto_mpositiontaking_mem_3 AS isautopositiontaking, @auto_mlivepositiontaking_mem_3 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_3 AS isautolivepositiontaking, @min_mlp_3 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 7 AS bettype, @min_mp_7 AS minmpositiontaking	,@auto_mpositiontaking_mem_7 AS autopositiontaking, @isauto_mpositiontaking_mem_7 AS isautopositiontaking, @auto_mlivepositiontaking_mem_7 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_7 AS isautolivepositiontaking, @min_mlp_7 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 8 AS bettype, @min_mp_8 AS minmpositiontaking	,@auto_mpositiontaking_mem_8 AS autopositiontaking, @isauto_mpositiontaking_mem_8 AS isautopositiontaking, @auto_mlivepositiontaking_mem_8 AS autolivepositiontaking, @isauto_mlivepositiontaking_mem_8 AS isautolivepositiontaking, @min_mlp_8 AS minmlivepositiontaking

					UNION ALL		SELECT 1 AS sporttype, 2 AS bettype, @min_mp_2 AS minmpositiontaking	,@auto_mpositiontaking_mem_2 AS autopositiontaking, @isauto_mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 4 AS bettype, @min_mp_4 AS minmpositiontaking	,@auto_mpositiontaking_mem_4 AS autopositiontaking, @isauto_mpositiontaking_mem_4 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 5 AS bettype, @min_mp_5 AS minmpositiontaking	,@auto_mpositiontaking_mem_5 AS autopositiontaking, @isauto_mpositiontaking_mem_5 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 6 AS bettype, @min_mp_6 AS minmpositiontaking	,@auto_mpositiontaking_mem_6 AS autopositiontaking, @isauto_mpositiontaking_mem_6 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 9 AS bettype, @min_mp_9 AS minmpositiontaking	,@auto_mpositiontaking_mem_9 AS autopositiontaking, @isauto_mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 10 AS bettype, @min_mp_10 AS minmpositiontaking	,@auto_mpositiontaking_mem_10 AS autopositiontaking, @isauto_mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype, 9999 AS bettype, @min_mp_9999 AS minmpositiontaking	,@auto_mpositiontaking_mem_9999 AS autopositiontaking, @isauto_mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
		WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 11,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END		
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
										
			RETURN
		END
		
		--Check m1<=min(m3,m4)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
		+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
		FROM (
								SELECT 1 AS sporttype	,	 1 AS bettype	,	 @mpositiontaking_1 AS mpositiontaking	,	 @max_mapositiontaking_1 AS maxmpositiontaking	,	 @mlivepositiontaking_1 AS mlivepositiontaking	,	 @max_malivepositiontaking_1 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 3 AS bettype	,	 @mpositiontaking_3 AS mpositiontaking	,	 @max_mapositiontaking_3 AS maxmpositiontaking	,	 @mlivepositiontaking_3 AS mlivepositiontaking	,	 @max_malivepositiontaking_3 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 7 AS bettype	,	 @mpositiontaking_7 AS mpositiontaking	,	 @max_mapositiontaking_7 AS maxmpositiontaking	,	 @mlivepositiontaking_7 AS mlivepositiontaking	,	 @max_malivepositiontaking_7 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 8 AS bettype	,	 @mpositiontaking_8 AS mpositiontaking	,	 @max_mapositiontaking_8 AS maxmpositiontaking	,	 @mlivepositiontaking_8 AS mlivepositiontaking	,	 @max_malivepositiontaking_8 AS maxmlivepositiontaking
																
				UNION ALL		SELECT 1 AS sporttype	,	 2 AS bettype	,	 @mpositiontaking_2 AS mpositiontaking	,	 @max_mapositiontaking_2 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 4 AS bettype	,	 @mpositiontaking_4 AS mpositiontaking	,	 @max_mapositiontaking_4 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 5 AS bettype	,	 @mpositiontaking_5 AS mpositiontaking	,	 @max_mapositiontaking_5 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 6 AS bettype	,	 @mpositiontaking_6 AS mpositiontaking	,	 @max_mapositiontaking_6 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 9 AS bettype	,	 @mpositiontaking_9 AS mpositiontaking	,	 @max_mapositiontaking_9 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 10 AS bettype	,	 @mpositiontaking_10 AS mpositiontaking	,	 @max_mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 9999 AS bettype	,	 @mpositiontaking_9999 AS mpositiontaking	,	 @max_mapositiontaking_9999 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
			
		)b 	
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
		WHERE (b.mpositiontaking>b.maxmpositiontaking) 
			OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
			RETURN
		END

		--Check m1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
		+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(
									SELECT 1 AS sporttype	,	 1 AS bettype	,	 @mpositiontaking_1 AS mpositiontaking	,	 @mlivepositiontaking_1 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 3 AS bettype	,	 @mpositiontaking_3 AS mpositiontaking	,	 @mlivepositiontaking_3 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 7 AS bettype	,	 @mpositiontaking_7 AS mpositiontaking	,	 @mlivepositiontaking_7 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 8 AS bettype	,	 @mpositiontaking_8 AS mpositiontaking	,	 @mlivepositiontaking_8 AS mlivepositiontaking
													
					UNION ALL		SELECT 1 AS sporttype	,	 2 AS bettype	,	 @mpositiontaking_2 AS mpositiontaking	,	 0 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 4 AS bettype	,	 @mpositiontaking_4 AS mpositiontaking	,	 0 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 5 AS bettype	,	 @mpositiontaking_5 AS mpositiontaking	,	 0 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 6 AS bettype	,	 @mpositiontaking_6 AS mpositiontaking	,	 0 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 9 AS bettype	,	 @mpositiontaking_9 AS mpositiontaking	,	 0 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 10 AS bettype	,	 @mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
					UNION ALL		SELECT 1 AS sporttype	,	 9999 AS bettype	,	 @mpositiontaking_9999 AS mpositiontaking	,	 0 AS mlivepositiontaking
													
					
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype  bettype ON b.bettype = bettype.ID
		WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 9,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
						END
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1<=m1_max
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
		+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
		FROM
			(
					SELECT 1 AS sporttype	,	 1 AS bettype	,	 @mpositiontaking_1 AS mpositiontaking	,@max_mp_1 as maxmpositiontaking, @isauto_mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_1 as isauto_mpositiontaking, @mlivepositiontaking_1 AS mlivepositiontaking ,@max_mlp_1 as maxmlivepositiontaking, @isauto_mlivepositiontaking_mem_1 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_1 as isauto_mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 3 AS bettype	,	 @mpositiontaking_3 AS mpositiontaking	,	 @max_mp_3 as maxmpositiontaking, @isauto_mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_3 as isauto_mpositiontaking, @mlivepositiontaking_3 AS mlivepositiontaking, @max_mlp_3 as maxmlivepositiontaking, @isauto_mlivepositiontaking_mem_3 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_3 as isauto_mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 7 AS bettype	,	 @mpositiontaking_7 AS mpositiontaking	,	 @max_mp_7 as maxmpositiontaking, @isauto_mpositiontaking_mem_7 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_7 as isauto_mpositiontaking, @mlivepositiontaking_7 AS mlivepositiontaking, @max_mlp_7 as maxmlivepositiontaking, @isauto_mlivepositiontaking_mem_7 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_7 as isauto_mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 8 AS bettype	,	 @mpositiontaking_8 AS mpositiontaking	,	 @max_mp_8 as maxmpositiontaking, @isauto_mpositiontaking_mem_8 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_8 as isauto_mpositiontaking, @mlivepositiontaking_8 AS mlivepositiontaking, @max_mlp_8 as maxmlivepositiontaking, @isauto_mlivepositiontaking_mem_8 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_8 as isauto_mlivepositiontaking
												
				UNION ALL		SELECT 1 AS sporttype	,	 2 AS bettype	,	 @mpositiontaking_2 AS mpositiontaking	,	 @max_mp_2 as maxmpositiontaking, @isauto_mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_2 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 4 AS bettype	,	 @mpositiontaking_4 AS mpositiontaking	,	 @max_mp_4 as maxmpositiontaking, @isauto_mpositiontaking_mem_4 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_4 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 5 AS bettype	,	 @mpositiontaking_5 AS mpositiontaking	,	 @max_mp_5 as maxmpositiontaking, @isauto_mpositiontaking_mem_5 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_5 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 6 AS bettype	,	 @mpositiontaking_6 AS mpositiontaking	,	 @max_mp_6 as maxmpositiontaking, @isauto_mpositiontaking_mem_6 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_6 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 9 AS bettype	,	 @mpositiontaking_9 AS mpositiontaking	,	 @max_mp_9 as maxmpositiontaking, @isauto_mpositiontaking_mem_9 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_9 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 10 AS bettype	,	 @mpositiontaking_10 AS mpositiontaking	,	 @max_mp_10 as maxmpositiontaking, @isauto_mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_10 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 9999 AS bettype	,	 @mpositiontaking_9999 AS mpositiontaking	,	 @max_mp_9999 as maxmpositiontaking, @isauto_mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_9999 as isauto_mpositiontaking, 0 as maxmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
			) b
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
		WHERE (b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0) OR (b.bettype IN (1,3,7,8) and b.mlivepositiontaking > maxmlivepositiontaking and isauto_mlivepositiontaking_mem = 0 and isauto_mlivepositiontaking = 0)
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 10,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
			RETURN
		END
		
		--check m1>=m1_min
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
		+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
		FROM
			(
					SELECT 1 AS sporttype	,	 1 AS bettype	,	 @mpositiontaking_1 AS mpositiontaking	,@min_mp_1 as minmpositiontaking, @isauto_mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_1 as isauto_mpositiontaking, @mlivepositiontaking_1 AS mlivepositiontaking ,@min_mlp_1 as minmlivepositiontaking, @isauto_mlivepositiontaking_mem_1 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_1 as isauto_mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 3 AS bettype	,	 @mpositiontaking_3 AS mpositiontaking	,	 @min_mp_3 as minmpositiontaking, @isauto_mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_3 as isauto_mpositiontaking, @mlivepositiontaking_3 AS mlivepositiontaking, @min_mlp_3 as minmlivepositiontaking, @isauto_mlivepositiontaking_mem_3 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_3 as isauto_mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 7 AS bettype	,	 @mpositiontaking_7 AS mpositiontaking	,	 @min_mp_7 as minmpositiontaking, @isauto_mpositiontaking_mem_7 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_7 as isauto_mpositiontaking, @mlivepositiontaking_7 AS mlivepositiontaking, @min_mlp_7 as minmlivepositiontaking, @isauto_mlivepositiontaking_mem_7 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_7 as isauto_mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 8 AS bettype	,	 @mpositiontaking_8 AS mpositiontaking	,	 @min_mp_8 as minmpositiontaking, @isauto_mpositiontaking_mem_8 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_8 as isauto_mpositiontaking, @mlivepositiontaking_8 AS mlivepositiontaking, @min_mlp_8 as minmlivepositiontaking, @isauto_mlivepositiontaking_mem_8 as isauto_mlivepositiontaking_mem, @isauto_mlivepositiontaking_8 as isauto_mlivepositiontaking
												
				UNION ALL		SELECT 1 AS sporttype	,	 2 AS bettype	,	 @mpositiontaking_2 AS mpositiontaking	,	 @min_mp_2 as minmpositiontaking, @isauto_mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_2 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 4 AS bettype	,	 @mpositiontaking_4 AS mpositiontaking	,	 @min_mp_4 as minmpositiontaking, @isauto_mpositiontaking_mem_4 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_4 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 5 AS bettype	,	 @mpositiontaking_5 AS mpositiontaking	,	 @min_mp_5 as minmpositiontaking, @isauto_mpositiontaking_mem_5 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_5 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 6 AS bettype	,	 @mpositiontaking_6 AS mpositiontaking	,	 @min_mp_6 as minmpositiontaking, @isauto_mpositiontaking_mem_6 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_6 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 9 AS bettype	,	 @mpositiontaking_9 AS mpositiontaking	,	 @min_mp_9 as minmpositiontaking, @isauto_mpositiontaking_mem_9 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_9 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 10 AS bettype	,	 @mpositiontaking_10 AS mpositiontaking	,	 @min_mp_10 as minmpositiontaking, @isauto_mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_10 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
				UNION ALL		SELECT 1 AS sporttype	,	 9999 AS bettype	,	 @mpositiontaking_9999 AS mpositiontaking	,	 @min_mp_9999 as minmpositiontaking, @isauto_mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_mpositiontaking_9999 as isauto_mpositiontaking, 0 as minmlivepositiontaking, 0 as isauto_mlivepositiontaking_mem, 0 as isauto_mlivepositiontaking, 0 AS mlivepositiontaking
			) b
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
		WHERE (b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0) OR (b.bettype IN (1,3,7,8) and b.mlivepositiontaking < minmlivepositiontaking and isauto_mlivepositiontaking_mem = 0 and isauto_mlivepositiontaking = 0)
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 12,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
			RETURN
		END
		
	END--@UpdatePositiontaking 


			--Basketball
	if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
		BEGIN --@UpdatePositiontakingv2
			IF 
				@v2mpositiontaking_1 <0 OR @v2mpositiontaking_1 >0.93
				OR @v2mpositiontaking_2 <0 OR @v2mpositiontaking_2 >0.93
				OR @v2mpositiontaking_3 <0 OR @v2mpositiontaking_3 >0.93
				OR @v2mpositiontaking_7 <0 OR @v2mpositiontaking_7 >0.93
				OR @v2mpositiontaking_8 <0 OR @v2mpositiontaking_8 >0.93
			--	OR @v2mpositiontaking_9 <0 OR @v2mpositiontaking_9 >0.93
				OR @v2mpositiontaking_20 <0 OR @v2mpositiontaking_20 >0.93
				OR @v2mpositiontaking_9999 <0 OR @v2mpositiontaking_9999 >0.93
				
				OR @v2mpositiontaking_10 <0 OR @v2mpositiontaking_10 >0.93
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 5
				SELECT @ErrMsg_cur = 	CASE @Language 
									WHEN 'E' THEN 'Wrong position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END	
			
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_v2mpositiontaking_mem_1 = 1 AND @old_isauto_v2mpositiontaking_mem_1 = 0)
				OR (@isauto_v2mpositiontaking_mem_2 = 1 AND @old_isauto_v2mpositiontaking_mem_2 = 0)
				OR (@isauto_v2mpositiontaking_mem_3 = 1 AND @old_isauto_v2mpositiontaking_mem_3 = 0)
				OR (@isauto_v2mpositiontaking_mem_7 = 1 AND @old_isauto_v2mpositiontaking_mem_7 = 0)
				OR (@isauto_v2mpositiontaking_mem_8 = 1 AND @old_isauto_v2mpositiontaking_mem_8 = 0)
				OR (@isauto_v2mpositiontaking_mem_10 = 1 AND @old_isauto_v2mpositiontaking_mem_10 = 0)
				OR (@isauto_v2mpositiontaking_mem_20 = 1 AND @old_isauto_v2mpositiontaking_mem_20 = 0)
				OR (@isauto_v2mpositiontaking_mem_9999 = 1 AND @old_isauto_v2mpositiontaking_mem_9999 = 0)
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END
			
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(	SELECT 2 AS sporttype, 1 AS bettype, @auto_v2mpositiontaking_mem_1 AS autopositiontaking, @isauto_v2mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 2 AS bettype, @auto_v2mpositiontaking_mem_2 AS autopositiontaking, @isauto_v2mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 3 AS bettype, @auto_v2mpositiontaking_mem_3 AS autopositiontaking, @isauto_v2mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 7 AS bettype, @auto_v2mpositiontaking_mem_7 AS autopositiontaking, @isauto_v2mpositiontaking_mem_7 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 8 AS bettype, @auto_v2mpositiontaking_mem_8 AS autopositiontaking, @isauto_v2mpositiontaking_mem_8 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
		--			UNION ALL		SELECT 2 AS sporttype, 9 AS bettype, @auto_v2mpositiontaking_mem_9 AS autopositiontaking, @isauto_v2mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 10 AS bettype, @auto_v2mpositiontaking_mem_10 AS autopositiontaking, @isauto_v2mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 20 AS bettype, @auto_v2mpositiontaking_mem_20 AS autopositiontaking, @isauto_v2mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 9999 AS bettype, @auto_v2mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v2mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END
			
			--Check um1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(
					SELECT 2 AS sporttype, 1 AS bettype, @max_v2mapositiontaking_1 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_1 AS autopositiontaking, @isauto_v2mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 2 AS bettype, @max_v2mapositiontaking_2 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_2 AS autopositiontaking, @isauto_v2mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 3 AS bettype, @max_v2mapositiontaking_3 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_3 AS autopositiontaking, @isauto_v2mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 7 AS bettype, @max_v2mapositiontaking_7 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_7 AS autopositiontaking, @isauto_v2mpositiontaking_mem_7 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 8 AS bettype, @max_v2mapositiontaking_8 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_8 AS autopositiontaking, @isauto_v2mpositiontaking_mem_8 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
		--			UNION ALL		SELECT 2 AS sporttype, 9 AS bettype, @auto_v2mpositiontaking_mem_9 AS autopositiontaking, @isauto_v2mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 10 AS bettype, @max_v2mapositiontaking_10 AS maxmpositiontaking	,@auto_v2mpositiontaking_mem_10 AS autopositiontaking, @isauto_v2mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 20 AS bettype, @max_v2mapositiontaking_20 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_20 AS autopositiontaking, @isauto_v2mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 9999 AS bettype, @max_v2mapositiontaking_9999 AS maxmpositiontaking, @auto_v2mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v2mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS maxmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check um1>= um1_min (= m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(
					SELECT 2 AS sporttype, 1 AS bettype, @min_v2mp_1 AS minmpositiontaking, @auto_v2mpositiontaking_mem_1 AS autopositiontaking, @isauto_v2mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 2 AS bettype, @min_v2mp_2 AS minmpositiontaking, @auto_v2mpositiontaking_mem_2 AS autopositiontaking, @isauto_v2mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 3 AS bettype, @min_v2mp_3 AS minmpositiontaking, @auto_v2mpositiontaking_mem_3 AS autopositiontaking, @isauto_v2mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 7 AS bettype, @min_v2mp_7 AS minmpositiontaking, @auto_v2mpositiontaking_mem_7 AS autopositiontaking, @isauto_v2mpositiontaking_mem_7 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 8 AS bettype, @min_v2mp_8 AS minmpositiontaking, @auto_v2mpositiontaking_mem_8 AS autopositiontaking, @isauto_v2mpositiontaking_mem_8 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
		--			UNION ALL		SELECT 2 AS sporttype, 9 AS bettype, @min_v2mp_9 AS minmpositiontaking @isauto_v2mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 10 AS bettype, @min_v2mp_10 AS minmpositiontaking	,@auto_v2mpositiontaking_mem_10 AS autopositiontaking, @isauto_v2mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 20 AS bettype, @min_v2mp_20 AS minmpositiontaking, @auto_v2mpositiontaking_mem_20 AS autopositiontaking, @isauto_v2mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype, 9999 AS bettype, @min_v2mp_9999 AS minmpositiontaking, @auto_v2mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v2mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking,  0 AS minmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 11,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check m1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM (	SELECT 2 AS sporttype	,	 1 AS bettype	,	 @v2mpositiontaking_1 AS mpositiontaking	,	 @max_v2mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 2 AS bettype	,	 @v2mpositiontaking_2 AS mpositiontaking	,	 @max_v2mapositiontaking_2 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 3 AS bettype	,	 @v2mpositiontaking_3 AS mpositiontaking	,	 @max_v2mapositiontaking_3 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 7 AS bettype	,	 @v2mpositiontaking_7 AS mpositiontaking	,	 @max_v2mapositiontaking_7 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 8 AS bettype	,	 @v2mpositiontaking_8 AS mpositiontaking	,	 @max_v2mapositiontaking_8 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 10 AS bettype	,	 @v2mpositiontaking_10 AS mpositiontaking	,	 @max_v2mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 20 AS bettype	,	 @v2mpositiontaking_20 AS mpositiontaking	,	 @max_v2mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 9999 AS bettype	,	 @v2mpositiontaking_9999 AS mpositiontaking	,	 @max_v2mapositiontaking_9999 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking

			)b 	
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.mpositiontaking>b.maxmpositiontaking) 
				OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 8,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END

			--Check m1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(							
										SELECT 2 AS sporttype	,	 1 AS bettype	,	 @v2mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 2 AS bettype	,	 @v2mpositiontaking_2 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 3 AS bettype	,	 @v2mpositiontaking_3 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 7 AS bettype	,	 @v2mpositiontaking_7 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 8 AS bettype	,	 @v2mpositiontaking_8 AS mpositiontaking	,	 0 AS mlivepositiontaking
			--			UNION ALL		SELECT 2 AS sporttype	,	 9 AS bettype	,	 @v2mpositiontaking_9 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 10 AS bettype	,	 @v2mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 20 AS bettype	,	 @v2mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 2 AS sporttype	,	 9999 AS bettype	,	 @v2mpositiontaking_9999 AS mpositiontaking	,	 0 AS mlivepositiontaking

					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 9,
  						@ErrMsg_cur = @UserName + ': '+
							 CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
			
			--check m1<=m1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 2 AS sporttype	,	 1 AS bettype	,	 @v2mpositiontaking_1 AS mpositiontaking	,@max_v2mp_1 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 2 AS bettype	,	 @v2mpositiontaking_2 AS mpositiontaking	,	 @max_v2mp_2 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 3 AS bettype	,	 @v2mpositiontaking_3 AS mpositiontaking	,	 @max_v2mp_3 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 7 AS bettype	,	 @v2mpositiontaking_7 AS mpositiontaking	,	 @max_v2mp_7 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_7 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_7 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 8 AS bettype	,	 @v2mpositiontaking_8 AS mpositiontaking	,	 @max_v2mp_8 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_8 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_8 as isauto_mpositiontaking
					--UNION ALL		SELECT 2 AS sporttype	,	 9 AS bettype	,	 @v2mpositiontaking_9 AS mpositiontaking	,	 @max_v2mp_9 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_9 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_9 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 10 AS bettype	,	 @v2mpositiontaking_10 AS mpositiontaking	,	 @max_v2mp_10 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_10 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 20 AS bettype	,	 @v2mpositiontaking_20 AS mpositiontaking	,	 @max_v2mp_20 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 9999 AS bettype	,	 @v2mpositiontaking_9999 AS mpositiontaking	,	 @max_v2mp_9999 as maxmpositiontaking, @isauto_v2mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_9999 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--check m1>=m1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 2 AS sporttype	,	 1 AS bettype	,	 @v2mpositiontaking_1 AS mpositiontaking	,@min_v2mp_1 as minmpositiontaking, @isauto_v2mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 2 AS bettype	,	 @v2mpositiontaking_2 AS mpositiontaking	,	 @min_v2mp_2 as minmpositiontaking, @isauto_v2mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 3 AS bettype	,	 @v2mpositiontaking_3 AS mpositiontaking	,	 @min_v2mp_3 as minmpositiontaking, @isauto_v2mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 7 AS bettype	,	 @v2mpositiontaking_7 AS mpositiontaking	,	 @min_v2mp_7 as minmpositiontaking, @isauto_v2mpositiontaking_mem_7 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_7 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 8 AS bettype	,	 @v2mpositiontaking_8 AS mpositiontaking	,	 @min_v2mp_8 as minmpositiontaking, @isauto_v2mpositiontaking_mem_8 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_8 as isauto_mpositiontaking
					--UNION ALL		SELECT 2 AS sporttype	,	 9 AS bettype	,	 @v2mpositiontaking_9 AS mpositiontaking	,	 @min_v2mp_9 as minmpositiontaking @isauto_v2mpositiontaking_mem_9 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_9 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 10 AS bettype	,	 @v2mpositiontaking_10 AS mpositiontaking	,	 @min_v2mp_10 as minmpositiontaking, @isauto_v2mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_10 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 20 AS bettype	,	 @v2mpositiontaking_20 AS mpositiontaking	,	 @min_v2mp_20 as minmpositiontaking, @isauto_v2mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 2 AS sporttype	,	 9999 AS bettype	,	 @v2mpositiontaking_9999 AS mpositiontaking	,	 @min_v2mp_9999 as minmpositiontaking, @isauto_v2mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_v2mpositiontaking_9999 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END

		END --@UpdatePositiontakingv2

		--Football
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
		BEGIN --@UpdatePositiontakingv3 
			IF 	
				@v3mpositiontaking_1 <0 OR @v3mpositiontaking_1 >0.93
				OR @v3mpositiontaking_2 <0 OR @v3mpositiontaking_2 >0.93
				OR @v3mpositiontaking_3 <0 OR @v3mpositiontaking_3 >0.93
				OR @v3mpositiontaking_20 <0 OR @v3mpositiontaking_20 >0.93				
				OR @v3mpositiontaking_10 <0 OR @v3mpositiontaking_10 >0.93				
				
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 5
				SELECT @ErrMsg_cur = 	CASE @Language 
									WHEN 'E' THEN 'Wrong position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
				RETURN
			END
			
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_v3mpositiontaking_mem_1 = 1 AND @old_isauto_v3mpositiontaking_mem_1 = 0)
				OR (@isauto_v3mpositiontaking_mem_2 = 1 AND @old_isauto_v3mpositiontaking_mem_2 = 0)
				OR (@isauto_v3mpositiontaking_mem_3 = 1 AND @old_isauto_v3mpositiontaking_mem_3 = 0)
				OR (@isauto_v3mpositiontaking_mem_10 = 1 AND @old_isauto_v3mpositiontaking_mem_10 = 0)
				OR (@isauto_v3mpositiontaking_mem_20 = 1 AND @old_isauto_v3mpositiontaking_mem_20 = 0)
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END
			
			--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(
									SELECT 3 AS sporttype, 1 AS bettype, @auto_v3mpositiontaking_mem_1 AS autopositiontaking, @isauto_v3mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 3 AS sporttype, 2 AS bettype, @auto_v3mpositiontaking_mem_2 AS autopositiontaking, @isauto_v3mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 3 AS sporttype, 3 AS bettype, @auto_v3mpositiontaking_mem_3 AS autopositiontaking, @isauto_v3mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 3 AS sporttype, 10 AS bettype, @auto_v3mpositiontaking_mem_10 AS autopositiontaking, @isauto_v3mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 3 AS sporttype, 20 AS bettype, @auto_v3mpositiontaking_mem_20 AS autopositiontaking, @isauto_v3mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END

			--Check um1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(
										SELECT 3 AS sporttype, 1 AS bettype, @max_v3mapositiontaking_1 AS maxmpositiontaking, @auto_v3mpositiontaking_mem_1 AS autopositiontaking, @isauto_v3mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 2 AS bettype, @max_v3mapositiontaking_2 AS maxmpositiontaking, @auto_v3mpositiontaking_mem_2 AS autopositiontaking, @isauto_v3mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 3 AS bettype, @max_v3mapositiontaking_3 AS maxmpositiontaking, @auto_v3mpositiontaking_mem_3 AS autopositiontaking, @isauto_v3mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 10 AS bettype, @max_v3mapositiontaking_10 AS maxmpositiontaking, @auto_v3mpositiontaking_mem_10 AS autopositiontaking, @isauto_v3mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 20 AS bettype, @max_v3mapositiontaking_20 AS maxmpositiontaking, @auto_v3mpositiontaking_mem_20 AS autopositiontaking, @isauto_v3mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check um1>= um1_min(=m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(
										SELECT 3 AS sporttype, 1 AS bettype, @min_v3mp_1 AS minmpositiontaking, @auto_v3mpositiontaking_mem_1 AS autopositiontaking, @isauto_v3mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 2 AS bettype, @min_v3mp_2 AS minmpositiontaking, @auto_v3mpositiontaking_mem_2 AS autopositiontaking, @isauto_v3mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 3 AS bettype, @min_v3mp_3 AS minmpositiontaking, @auto_v3mpositiontaking_mem_3 AS autopositiontaking, @isauto_v3mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 10 AS bettype, @min_v3mp_10 AS minmpositiontaking, @auto_v3mpositiontaking_mem_10 AS autopositiontaking, @isauto_v3mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype, 20 AS bettype, @min_v3mp_20 AS minmpositiontaking, @auto_v3mpositiontaking_mem_20 AS autopositiontaking, @isauto_v3mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 11,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check m1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM (
									SELECT 3 AS sporttype	,	 1 AS bettype	,	 @v3mpositiontaking_1 AS mpositiontaking	,	 @max_v3mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 2 AS bettype	,	 @v3mpositiontaking_2 AS mpositiontaking	,	 @max_v3mapositiontaking_2 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 3 AS bettype	,	 @v3mpositiontaking_3 AS mpositiontaking	,	 @max_v3mapositiontaking_3 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 10 AS bettype	,	 @v3mpositiontaking_10 AS mpositiontaking	,	 @max_v3mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 20 AS bettype	,	 @v3mpositiontaking_20 AS mpositiontaking	,	 @max_v3mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
																	
					
			)b 	
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.mpositiontaking>b.maxmpositiontaking) 
				OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 8,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END

			--Check m1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(								
										SELECT 3 AS sporttype	,	 1 AS bettype	,	 @v3mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype	,	 2 AS bettype	,	 @v3mpositiontaking_2 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype	,	 3 AS bettype	,	 @v3mpositiontaking_3 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype	,	 10 AS bettype	,	 @v3mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 3 AS sporttype	,	 20 AS bettype	,	 @v3mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
				
					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 9,
  						@ErrMsg_cur = @UserName + ': '+
							 CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END		
			
			--check m1<=m1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 3 AS sporttype	,	 1 AS bettype	,	 @v3mpositiontaking_1 AS mpositiontaking	,@max_v3mp_1 as maxmpositiontaking, @isauto_v3mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 2 AS bettype	,	 @v3mpositiontaking_2 AS mpositiontaking	,	 @max_v3mp_2 as maxmpositiontaking, @isauto_v3mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 3 AS bettype	,	 @v3mpositiontaking_3 AS mpositiontaking	,	 @max_v3mp_3 as maxmpositiontaking, @isauto_v3mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 10 AS bettype	,	 @v3mpositiontaking_10 AS mpositiontaking	,	 @max_v3mp_10 as maxmpositiontaking, @isauto_v3mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_10 as isauto_mpositiontaking
					
					UNION ALL		SELECT 3 AS sporttype	,	 20 AS bettype	,	 @v3mpositiontaking_20 AS mpositiontaking	,	 @max_v3mp_20 as maxmpositiontaking, @isauto_v3mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_20 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--check m1>=m1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 3 AS sporttype	,	 1 AS bettype	,	 @v3mpositiontaking_1 AS mpositiontaking	,@min_v3mp_1 as minmpositiontaking, @isauto_v3mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 2 AS bettype	,	 @v3mpositiontaking_2 AS mpositiontaking	,	 @min_v3mp_2 as minmpositiontaking, @isauto_v3mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 3 AS bettype	,	 @v3mpositiontaking_3 AS mpositiontaking	,	 @min_v3mp_3 as minmpositiontaking, @isauto_v3mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 20 AS bettype	,	 @v3mpositiontaking_20 AS mpositiontaking	,	 @min_v3mp_20 as minmpositiontaking, @isauto_v3mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 3 AS sporttype	,	 10 AS bettype	,	 @v3mpositiontaking_10 AS mpositiontaking	,	 @min_v3mp_10 as minmpositiontaking, @isauto_v3mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v3mpositiontaking_10 as isauto_mpositiontaking
					
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 12,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
				
		END --@UpdatePositiontakingv3 

		--Tennis
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv5 = 1 )
		BEGIN --@UpdatePositiontakingv5
			if 
				@v5mpositiontaking_1 <0 OR @v5mpositiontaking_1 >0.93
				OR @v5mpositiontaking_2 <0 OR @v5mpositiontaking_2 >0.93
				OR @v5mpositiontaking_3 <0 OR @v5mpositiontaking_3 >0.93
				OR @v5mpositiontaking_20 <0 OR @v5mpositiontaking_20 >0.93
				OR @v5mpositiontaking_9999 <0 OR @v5mpositiontaking_9999 >0.93
				OR @v5mpositiontaking_10 <0 OR @v5mpositiontaking_10 >0.93
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 5
				SELECT @ErrMsg_cur = 	CASE @Language 
									WHEN 'E' THEN 'Wrong position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
				RETURN
			END
			
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_v5mpositiontaking_mem_1 = 1 AND @old_isauto_v5mpositiontaking_mem_1 = 0)
				OR (@isauto_v5mpositiontaking_mem_2 = 1 AND @old_isauto_v5mpositiontaking_mem_2 = 0)
				OR (@isauto_v5mpositiontaking_mem_3 = 1 AND @old_isauto_v5mpositiontaking_mem_3 = 0)
				OR (@isauto_v5mpositiontaking_mem_10 = 1 AND @old_isauto_v5mpositiontaking_mem_10 = 0)
				OR (@isauto_v5mpositiontaking_mem_20 = 1 AND @old_isauto_v5mpositiontaking_mem_20 = 0)
				OR (@isauto_v5mpositiontaking_mem_9999 = 1 AND @old_isauto_v5mpositiontaking_mem_9999 = 0)
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END
			
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(	SELECT 5 AS sporttype, 1 AS bettype, @auto_v5mpositiontaking_mem_1 AS autopositiontaking, @isauto_v5mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL		SELECT 5 AS sporttype, 2 AS bettype, @auto_v5mpositiontaking_mem_2 AS autopositiontaking, @isauto_v5mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL		SELECT 5 AS sporttype, 3 AS bettype, @auto_v5mpositiontaking_mem_3 AS autopositiontaking, @isauto_v5mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL		SELECT 5 AS sporttype, 20 AS bettype, @auto_v5mpositiontaking_mem_20 AS autopositiontaking, @isauto_v5mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL		SELECT 5 AS sporttype, 10 AS bettype, @auto_v5mpositiontaking_mem_10 AS autopositiontaking, @isauto_v5mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						
						UNION ALL		SELECT 5 AS sporttype, 9999 AS bettype, @auto_v5mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v5mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END

		--Check um1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(
									SELECT 5 AS sporttype, 1 AS bettype, @max_v5mapositiontaking_1 AS maxmpositiontaking, @auto_v5mpositiontaking_mem_1 AS autopositiontaking, @isauto_v5mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 2 AS bettype, @max_v5mapositiontaking_2 AS maxmpositiontaking, @auto_v5mpositiontaking_mem_2 AS autopositiontaking, @isauto_v5mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 3 AS bettype, @max_v5mapositiontaking_3 AS maxmpositiontaking, @auto_v5mpositiontaking_mem_3 AS autopositiontaking, @isauto_v5mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 20 AS bettype, @max_v5mapositiontaking_20 AS maxmpositiontaking, @auto_v5mpositiontaking_mem_20 AS autopositiontaking, @isauto_v5mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 10 AS bettype, @max_v5mapositiontaking_10 AS maxmpositiontaking, @auto_v5mpositiontaking_mem_10 AS autopositiontaking, @isauto_v5mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 9999 AS bettype, @max_v5mapositiontaking_9999 AS maxmpositiontaking, @auto_v5mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v5mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END
			
		--Check um1>= um1_min(=m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(
									SELECT 5 AS sporttype, 1 AS bettype, @min_v5mp_1 AS minmpositiontaking, @auto_v5mpositiontaking_mem_1 AS autopositiontaking, @isauto_v5mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 2 AS bettype, @min_v5mp_2 AS minmpositiontaking, @auto_v5mpositiontaking_mem_2 AS autopositiontaking, @isauto_v5mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 3 AS bettype, @min_v5mp_3 AS minmpositiontaking, @auto_v5mpositiontaking_mem_3 AS autopositiontaking, @isauto_v5mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 20 AS bettype, @min_v5mp_20 AS minmpositiontaking, @auto_v5mpositiontaking_mem_20 AS autopositiontaking, @isauto_v5mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype, 10 AS bettype, @min_v5mp_10 AS minmpositiontaking, @auto_v5mpositiontaking_mem_10 AS autopositiontaking, @isauto_v5mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					
					UNION ALL		SELECT 5 AS sporttype, 9999 AS bettype, @min_v5mp_9999 AS minmpositiontaking, @auto_v5mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v5mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking < b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END
							
			--Check m1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM (
							SELECT 5 AS sporttype	,	 1 AS bettype	,	 @v5mpositiontaking_1 AS mpositiontaking	,	 @max_v5mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 2 AS bettype	,	 @v5mpositiontaking_2 AS mpositiontaking	,	 @max_v5mapositiontaking_2 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 3 AS bettype	,	 @v5mpositiontaking_3 AS mpositiontaking	,	 @max_v5mapositiontaking_3 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 20 AS bettype	,	 @v5mpositiontaking_20 AS mpositiontaking	,	 @max_v5mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					
					UNION ALL		SELECT 5 AS sporttype	,	 10 AS bettype	,	 @v5mpositiontaking_10 AS mpositiontaking	,	 @max_v5mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					
					UNION ALL		SELECT 5 AS sporttype	,	 9999 AS bettype	,	 @v5mpositiontaking_9999 AS mpositiontaking	,	 @max_v5mapositiontaking_9999 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
			)b 	
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.mpositiontaking>b.maxmpositiontaking) 
				OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 8,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7),
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--Check m1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(
								SELECT 5 AS sporttype	,	 1 AS bettype	,	 @v5mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 5 AS sporttype	,	 2 AS bettype	,	 @v5mpositiontaking_2 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 5 AS sporttype	,	 3 AS bettype	,	 @v5mpositiontaking_3 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 5 AS sporttype	,	 20 AS bettype	,	 @v5mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 5 AS sporttype	,	 10 AS bettype	,	 @v5mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
						
						UNION ALL		SELECT 5 AS sporttype	,	 9999 AS bettype	,	 @v5mpositiontaking_9999 AS mpositiontaking	,	 0 AS mlivepositiontaking

					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 9,
  						@ErrMsg_cur = @UserName + ': '+
							 CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END	
			
			--check m1<=m1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 5 AS sporttype	,	 1 AS bettype	,	 @v5mpositiontaking_1 AS mpositiontaking	,@max_v5mp_1 as maxmpositiontaking, @isauto_v5mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 2 AS bettype	,	 @v5mpositiontaking_2 AS mpositiontaking	,	 @max_v5mp_2 as maxmpositiontaking, @isauto_v5mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 3 AS bettype	,	 @v5mpositiontaking_3 AS mpositiontaking	,	 @max_v5mp_3 as maxmpositiontaking, @isauto_v5mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 20 AS bettype	,	 @v5mpositiontaking_20 AS mpositiontaking	,	 @max_v5mp_20 as maxmpositiontaking, @isauto_v5mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 10 AS bettype	,	 @v5mpositiontaking_10 AS mpositiontaking	,	 @max_v5mp_10 as maxmpositiontaking, @isauto_v5mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_10 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 9999 AS bettype	,	 @v5mpositiontaking_9999 AS mpositiontaking	,	 @max_v5mp_9999 as maxmpositiontaking, @isauto_v5mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_9999 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END		
			
			--check m1>=m1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 5 AS sporttype	,	 1 AS bettype	,	 @v5mpositiontaking_1 AS mpositiontaking	,@min_v5mp_1 as minmpositiontaking, @isauto_v5mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 2 AS bettype	,	 @v5mpositiontaking_2 AS mpositiontaking	,	 @min_v5mp_2 as minmpositiontaking, @isauto_v5mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 3 AS bettype	,	 @v5mpositiontaking_3 AS mpositiontaking	,	 @min_v5mp_3 as minmpositiontaking, @isauto_v5mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 20 AS bettype	,	 @v5mpositiontaking_20 AS mpositiontaking	,	 @min_v5mp_20 as minmpositiontaking, @isauto_v5mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 5 AS sporttype	,	 10 AS bettype	,	 @v5mpositiontaking_10 AS mpositiontaking	,	 @min_v5mp_10 as minmpositiontaking, @isauto_v5mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_10 as isauto_mpositiontaking
					
					UNION ALL		SELECT 5 AS sporttype	,	 9999 AS bettype	,	 @v5mpositiontaking_9999 AS mpositiontaking	,	 @min_v5mp_9999 as minmpositiontaking, @isauto_v5mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_v5mpositiontaking_9999 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 12,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END		
		END --@UpdatePositiontakingv5

		--Baseball
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1 )
			BEGIN --@UpdatePositiontakingv8 
				if 	@v8mpositiontaking_1 <0 OR @v8mpositiontaking_1 >0.93
					OR @v8mpositiontaking_3 <0  OR @v8mpositiontaking_3 >0.93
					OR @v8mpositiontaking_20 <0 OR @v8mpositiontaking_20 >0.93					
					OR @v8mpositiontaking_10 <0 OR @v8mpositiontaking_10 >0.93					
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 5
					SELECT @ErrMsg_cur = 	CASE @Language 
										WHEN 'E' THEN 'Wrong position taking.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
							
					RETURN
				END
				
				--don't allow update autoPT incase DisableAutoMPT = 1
				IF ((@isauto_v8mpositiontaking_mem_1 = 1 AND @old_isauto_v8mpositiontaking_mem_1 = 0)					
					OR (@isauto_v8mpositiontaking_mem_3 = 1 AND @old_isauto_v8mpositiontaking_mem_3 = 0)
					OR (@isauto_v8mpositiontaking_mem_10 = 1 AND @old_isauto_v8mpositiontaking_mem_10 = 0)
					OR (@isauto_v8mpositiontaking_mem_20 = 1 AND @old_isauto_v8mpositiontaking_mem_20 = 0)					
					)
					AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
								WHERE custid = @mrecommend 
									AND DisableAutoMPT = 1)
				BEGIN
					SELECT @ErrCode = 110,
						   @ErrMsg = CASE @Language 			   
											WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
										END	
					RETURN					
				END
				--Check um1<=l3
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(	SELECT 8 AS sporttype, 1 AS bettype, @auto_v8mpositiontaking_mem_1 AS autopositiontaking, @isauto_v8mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL		SELECT 8 AS sporttype, 3 AS bettype, @auto_v8mpositiontaking_mem_3 AS autopositiontaking, @isauto_v8mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL		SELECT 8 AS sporttype, 20 AS bettype, @auto_v8mpositiontaking_mem_20 AS autopositiontaking, @isauto_v8mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						
						UNION ALL		SELECT 8 AS sporttype, 10 AS bettype, @auto_v8mpositiontaking_mem_10 AS autopositiontaking, @isauto_v8mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

				WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 6,
						   @ErrMsg_cur = CASE @Language 
										WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
								END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

					RETURN
				END

			--Check um1<=min(m3,m4)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(	SELECT 8 AS sporttype, 1 AS bettype, @max_v8mapositiontaking_1 AS maxmpositiontaking, @auto_v8mpositiontaking_mem_1 AS autopositiontaking, @isauto_v8mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 8 AS sporttype, 3 AS bettype, @max_v8mapositiontaking_3 AS maxmpositiontaking, @auto_v8mpositiontaking_mem_3 AS autopositiontaking, @isauto_v8mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 8 AS sporttype, 20 AS bettype, @max_v8mapositiontaking_20 AS maxmpositiontaking, @auto_v8mpositiontaking_mem_20 AS autopositiontaking, @isauto_v8mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						
						UNION ALL		SELECT 8 AS sporttype, 10 AS bettype, @max_v8mapositiontaking_10 AS maxmpositiontaking, @auto_v8mpositiontaking_mem_10 AS autopositiontaking, @isauto_v8mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						
					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 7,
						   @ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END		
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
												
					RETURN
				END
				
			--Check um1>=um1_min(=m1_min)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(	SELECT 8 AS sporttype, 1 AS bettype, @min_v8mp_1 AS minmpositiontaking, @auto_v8mpositiontaking_mem_1 AS autopositiontaking, @isauto_v8mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 8 AS sporttype, 3 AS bettype, @min_v8mp_3 AS minmpositiontaking, @auto_v8mpositiontaking_mem_3 AS autopositiontaking, @isauto_v8mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 8 AS sporttype, 20 AS bettype, @min_v8mp_20 AS minmpositiontaking, @auto_v8mpositiontaking_mem_20 AS autopositiontaking, @isauto_v8mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						
						UNION ALL		SELECT 8 AS sporttype, 10 AS bettype, @min_v8mp_10 AS minmpositiontaking, @auto_v8mpositiontaking_mem_10 AS autopositiontaking, @isauto_v8mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						
					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 12,
						   @ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END		
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
												
					RETURN
				END
						
				--Check m1<=min(m3,m4)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
				+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
				FROM (
																	
								SELECT 8 AS sporttype	,	 1 AS bettype	,	 @v8mpositiontaking_1 AS mpositiontaking	,	 @max_v8mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 3 AS bettype	,	 @v8mpositiontaking_3 AS mpositiontaking	,	 @max_v8mapositiontaking_3 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 20 AS bettype	,	 @v8mpositiontaking_20 AS mpositiontaking	,	 @max_v8mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
						
						UNION ALL		SELECT 8 AS sporttype	,	 10 AS bettype	,	 @v8mpositiontaking_10 AS mpositiontaking	,	 @max_v8mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
						
				)b 	
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE (b.mpositiontaking>b.maxmpositiontaking) 
					OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 8,
							@ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END							
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
					RETURN
				END
				
				--Check m1<=l3
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
					FROM custoverride AS co WITH (NOLOCK) INNER JOIN
						(
											SELECT 8 AS sporttype	,	 1 AS bettype	,	 @v8mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
							UNION ALL		SELECT 8 AS sporttype	,	 3 AS bettype	,	 @v8mpositiontaking_3 AS mpositiontaking	,	 0 AS mlivepositiontaking
							UNION ALL		SELECT 8 AS sporttype	,	 20 AS bettype	,	 @v8mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
							UNION ALL		SELECT 8 AS sporttype	,	 10 AS bettype	,	 @v8mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
															

						) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 9,
  							@ErrMsg_cur = @UserName + ': '+
								 CASE @Language 
										WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
								END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					RETURN
				END		
				
				--check m1<=m1_max
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
				FROM
					(
							SELECT 8 AS sporttype	,	 1 AS bettype	,	 @v8mpositiontaking_1 AS mpositiontaking	,@max_v8mp_1 as maxmpositiontaking, @isauto_v8mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_1 as isauto_mpositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 3 AS bettype	,	 @v8mpositiontaking_3 AS mpositiontaking	,	 @max_v8mp_3 as maxmpositiontaking, @isauto_v8mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_3 as isauto_mpositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 20 AS bettype	,	 @v8mpositiontaking_20 AS mpositiontaking	,	 @max_v8mp_20 as maxmpositiontaking, @isauto_v8mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_20 as isauto_mpositiontaking
						
						UNION ALL		SELECT 8 AS sporttype	,	 10 AS bettype	,	 @v8mpositiontaking_10 AS mpositiontaking	,	 @max_v8mp_10 as maxmpositiontaking, @isauto_v8mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_10 as isauto_mpositiontaking
						
					) b
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
				
				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 10,
							@ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END							
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
					RETURN
				END
				
				--check m1>=m1_min
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
				FROM
					(
							SELECT 8 AS sporttype	,	 1 AS bettype	,	 @v8mpositiontaking_1 AS mpositiontaking	,@min_v8mp_1 as minmpositiontaking, @isauto_v8mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_1 as isauto_mpositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 3 AS bettype	,	 @v8mpositiontaking_3 AS mpositiontaking	,	 @min_v8mp_3 as minmpositiontaking, @isauto_v8mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_3 as isauto_mpositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 20 AS bettype	,	 @v8mpositiontaking_20 AS mpositiontaking	,	 @min_v8mp_20 as minmpositiontaking, @isauto_v8mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_20 as isauto_mpositiontaking
						UNION ALL		SELECT 8 AS sporttype	,	 10 AS bettype	,	 @v8mpositiontaking_10 AS mpositiontaking	,	 @min_v8mp_10 as minmpositiontaking, @isauto_v8mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v8mpositiontaking_10 as isauto_mpositiontaking
						
					) b
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
				
				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 12,
							@ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
					RETURN
				END
			END --@UpdatePositiontakingv8 
			
		--Golf
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv10 = 1 )
		BEGIN -- @UpdatePositiontakingv10
			if 
				 @v10mpositiontaking_1 <0 OR @v10mpositiontaking_1 >0.93
				OR @v10mpositiontaking_2 <0 OR @v10mpositiontaking_2 >0.93
				OR @v10mpositiontaking_3 <0 OR @v10mpositiontaking_3 >0.93
				OR @v10mpositiontaking_20 <0 OR @v10mpositiontaking_20 >0.93				
				OR @v10mpositiontaking_10 <0 OR @v10mpositiontaking_10 >0.93				
				
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 5
				SELECT @ErrMsg_cur = 	CASE @Language 
									WHEN 'E' THEN 'Wrong position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
				RETURN
			END	
			
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_v10mpositiontaking_mem_1 = 1 AND @old_isauto_v10mpositiontaking_mem_1 = 0)
				OR (@isauto_v10mpositiontaking_mem_2 = 1 AND @old_isauto_v10mpositiontaking_mem_2 = 0)
				OR (@isauto_v10mpositiontaking_mem_3 = 1 AND @old_isauto_v10mpositiontaking_mem_3 = 0)
				OR (@isauto_v10mpositiontaking_mem_10 = 1 AND @old_isauto_v10mpositiontaking_mem_10 = 0)
				OR (@isauto_v10mpositiontaking_mem_20 = 1 AND @old_isauto_v10mpositiontaking_mem_20 = 0)				
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END
			
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(	SELECT 10 AS sporttype, 1 AS bettype, @auto_v10mpositiontaking_mem_1 AS autopositiontaking, @isauto_v10mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 2 AS bettype, @auto_v10mpositiontaking_mem_2 AS autopositiontaking, @isauto_v10mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 3 AS bettype, @auto_v10mpositiontaking_mem_3 AS autopositiontaking, @isauto_v10mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 20 AS bettype, @auto_v10mpositiontaking_mem_20 AS autopositiontaking, @isauto_v10mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 10 AS bettype, @auto_v10mpositiontaking_mem_10 AS autopositiontaking, @isauto_v10mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 6,
				   @ErrMsg_cur = CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
						END
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

			RETURN
		END
		
		--Check um1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(	SELECT 10 AS sporttype, 1 AS bettype, @max_v10mapositiontaking_1 AS maxmpositiontaking, @auto_v10mpositiontaking_mem_1 AS autopositiontaking, @isauto_v10mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 2 AS bettype, @max_v10mapositiontaking_2 AS maxmpositiontaking, @auto_v10mpositiontaking_mem_2 AS autopositiontaking, @isauto_v10mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 3 AS bettype, @max_v10mapositiontaking_3 AS maxmpositiontaking, @auto_v10mpositiontaking_mem_3 AS autopositiontaking, @isauto_v10mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 20 AS bettype, @max_v10mapositiontaking_20 AS maxmpositiontaking, @auto_v10mpositiontaking_mem_20 AS autopositiontaking, @isauto_v10mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 10 AS bettype, @max_v10mapositiontaking_10 AS maxmpositiontaking, @auto_v10mpositiontaking_mem_10 AS autopositiontaking, @isauto_v10mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check um1<=um1_min(=m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(	SELECT 10 AS sporttype, 1 AS bettype, @min_v10mp_1 AS minmpositiontaking, @auto_v10mpositiontaking_mem_1 AS autopositiontaking, @isauto_v10mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 2 AS bettype, @min_v10mp_2 AS minmpositiontaking, @auto_v10mpositiontaking_mem_2 AS autopositiontaking, @isauto_v10mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 3 AS bettype, @min_v10mp_3 AS minmpositiontaking, @auto_v10mpositiontaking_mem_3 AS autopositiontaking, @isauto_v10mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 20 AS bettype, @min_v10mp_20 AS minmpositiontaking, @auto_v10mpositiontaking_mem_20 AS autopositiontaking, @isauto_v10mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype, 10 AS bettype, @min_v10mp_10 AS minmpositiontaking, @auto_v10mpositiontaking_mem_10 AS autopositiontaking, @isauto_v10mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking

				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 11,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check m1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM (
									SELECT 10 AS sporttype	,	 1 AS bettype	,	 @v10mpositiontaking_1 AS mpositiontaking	,	 @max_v10mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 2 AS bettype	,	 @v10mpositiontaking_2 AS mpositiontaking	,	 @max_v10mapositiontaking_2 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 3 AS bettype	,	 @v10mpositiontaking_3 AS mpositiontaking	,	 @max_v10mapositiontaking_3 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 20 AS bettype	,	 @v10mpositiontaking_20 AS mpositiontaking	,	 @max_v10mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 10 AS bettype	,	 @v10mpositiontaking_10 AS mpositiontaking	,	 @max_v10mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
			)b 			
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.mpositiontaking>b.maxmpositiontaking) 
				OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 8,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END

			--Check m1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(
										SELECT 10 AS sporttype	,	 1 AS bettype	,	 @v10mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 10 AS sporttype	,	 2 AS bettype	,	 @v10mpositiontaking_2 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 10 AS sporttype	,	 3 AS bettype	,	 @v10mpositiontaking_3 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 10 AS sporttype	,	 20 AS bettype	,	 @v10mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 10 AS sporttype	,	 10 AS bettype	,	 @v10mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking

					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 9,
  						@ErrMsg_cur = @UserName + ': '+
							 CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END	
			
			--check m1<=m1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 10 AS sporttype	,	 1 AS bettype	,	 @v10mpositiontaking_1 AS mpositiontaking	,@max_v10mp_1 as maxmpositiontaking, @isauto_v10mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 2 AS bettype	,	 @v10mpositiontaking_2 AS mpositiontaking	,	 @max_v10mp_2 as maxmpositiontaking, @isauto_v10mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 3 AS bettype	,	 @v10mpositiontaking_3 AS mpositiontaking	,	 @max_v10mp_3 as maxmpositiontaking, @isauto_v10mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 20 AS bettype	,	 @v10mpositiontaking_20 AS mpositiontaking	,	 @max_v10mp_20 as maxmpositiontaking, @isauto_v10mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 10 AS bettype	,	 @v10mpositiontaking_10 AS mpositiontaking	,	 @max_v10mp_10 as maxmpositiontaking, @isauto_v10mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_10 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--check m1>=m1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 10 AS sporttype	,	 1 AS bettype	,	 @v10mpositiontaking_1 AS mpositiontaking	,@min_v10mp_1 as minmpositiontaking, @isauto_v10mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 2 AS bettype	,	 @v10mpositiontaking_2 AS mpositiontaking	,	 @min_v10mp_2 as minmpositiontaking, @isauto_v10mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 3 AS bettype	,	 @v10mpositiontaking_3 AS mpositiontaking	,	 @min_v10mp_3 as minmpositiontaking, @isauto_v10mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 20 AS bettype	,	 @v10mpositiontaking_20 AS mpositiontaking	,	 @min_v10mp_20 as minmpositiontaking, @isauto_v10mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 10 AS sporttype	,	 10 AS bettype	,	 @v10mpositiontaking_10 AS mpositiontaking	,	 @min_v10mp_10 as minmpositiontaking, @isauto_v10mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v10mpositiontaking_10 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 12,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
		END -- @UpdatePositiontakingv10

		--Motorsports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
		BEGIN--@UpdatePositiontakingv11
			if 
				@v11mpositiontaking_1 <0 OR @v11mpositiontaking_1 >0.93
				OR @v11mpositiontaking_20 <0 OR @v11mpositiontaking_20 >0.93				
				OR @v11mpositiontaking_10 <0 OR @v11mpositiontaking_10 >0.93				
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 5
				SELECT @ErrMsg_cur = 	CASE @Language 
									WHEN 'E' THEN 'Wrong position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
				RETURN
			END				
						
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_v11mpositiontaking_mem_1 = 1 AND @old_isauto_v11mpositiontaking_mem_1 = 0)
				OR (@isauto_v11mpositiontaking_mem_10 = 1 AND @old_isauto_v11mpositiontaking_mem_10 = 0)
				OR (@isauto_v11mpositiontaking_mem_20 = 1 AND @old_isauto_v11mpositiontaking_mem_20 = 0)				
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END
			
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(	SELECT 11 AS sporttype, 1 AS bettype, @auto_v11mpositiontaking_mem_1 AS autopositiontaking, @isauto_v11mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 11 AS sporttype, 20 AS bettype, @auto_v11mpositiontaking_mem_20 AS autopositiontaking, @isauto_v11mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 11 AS sporttype, 10 AS bettype, @auto_v11mpositiontaking_mem_10 AS autopositiontaking, @isauto_v11mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END

			--Check um1<=min(m3,m4)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(	SELECT 11 AS sporttype, 1 AS bettype, @max_v11mapositiontaking_1 AS maxmpositiontaking, @auto_v11mpositiontaking_mem_1 AS autopositiontaking, @isauto_v11mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 11 AS sporttype, 20 AS bettype, @max_v11mapositiontaking_20 AS maxmpositiontaking, @auto_v11mpositiontaking_mem_20 AS autopositiontaking, @isauto_v11mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
						UNION ALL		SELECT 11 AS sporttype, 10 AS bettype, @max_v11mapositiontaking_10 AS maxmpositiontaking, @auto_v11mpositiontaking_mem_10 AS autopositiontaking, @isauto_v11mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking

					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check um1>=um1_min(=m1_min)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(	SELECT 11 AS sporttype, 1 AS bettype, @min_v11mp_1 AS minmpositiontaking, @auto_v11mpositiontaking_mem_1 AS autopositiontaking, @isauto_v11mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 11 AS sporttype, 20 AS bettype, @min_v11mp_20 AS minmpositiontaking, @auto_v11mpositiontaking_mem_20 AS autopositiontaking, @isauto_v11mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
						UNION ALL		SELECT 11 AS sporttype, 10 AS bettype, @min_v11mp_10 AS minmpositiontaking, @auto_v11mpositiontaking_mem_10 AS autopositiontaking, @isauto_v11mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking

					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 11,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END	
			
			--Check m1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM (
					
									SELECT 11 AS sporttype	,	 1 AS bettype	,	 @v11mpositiontaking_1 AS mpositiontaking	,	 @max_v11mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 11 AS sporttype	,	 20 AS bettype	,	 @v11mpositiontaking_20 AS mpositiontaking	,	 @max_v11mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 11 AS sporttype	,	 10 AS bettype	,	 @v11mpositiontaking_10 AS mpositiontaking	,	 @max_v11mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					
					
			)b 	
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.mpositiontaking>b.maxmpositiontaking) 
				OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 8,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--Check m1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(
										SELECT 11 AS sporttype	,	 1 AS bettype	,	 @v11mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 11 AS sporttype	,	 20 AS bettype	,	 @v11mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 11 AS sporttype	,	 10 AS bettype	,	 @v11mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
						
					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 9,
  						@ErrMsg_cur = @UserName + ': '+
							 CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
			
			--check m1<=m1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 11 AS sporttype	,	 1 AS bettype	,	 @v11mpositiontaking_1 AS mpositiontaking	,@max_v11mp_1 as maxmpositiontaking, @isauto_v11mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v11mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 11 AS sporttype	,	 20 AS bettype	,	 @v11mpositiontaking_20 AS mpositiontaking	,	 @max_v11mp_20 as maxmpositiontaking, @isauto_v11mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v11mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 11 AS sporttype	,	 10 AS bettype	,	 @v11mpositiontaking_10 AS mpositiontaking	,	 @max_v11mp_10 as maxmpositiontaking, @isauto_v11mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v11mpositiontaking_10 as isauto_mpositiontaking
					
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--check m1>=m1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 11 AS sporttype	,	 1 AS bettype	,	 @v11mpositiontaking_1 AS mpositiontaking	,@min_v11mp_1 as minmpositiontaking, @isauto_v11mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v11mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 11 AS sporttype	,	 20 AS bettype	,	 @v11mpositiontaking_20 AS mpositiontaking	,	 @min_v11mp_20 as minmpositiontaking, @isauto_v11mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v11mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 11 AS sporttype	,	 10 AS bettype	,	 @v11mpositiontaking_10 AS mpositiontaking	,	 @min_v11mp_10 as minmpositiontaking, @isauto_v11mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v11mpositiontaking_10 as isauto_mpositiontaking
					
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 12,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END

		END --@UpdatePositiontakingv11

		--Other sports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1 )
		BEGIN--@UpdatePositiontakingv99
			if 
				@v99mpositiontaking_1 <0 OR @v99mpositiontaking_1 >0.93
				OR @v99mpositiontaking_2 <0 OR @v99mpositiontaking_2 >0.93
				OR @v99mpositiontaking_3 <0 OR @v99mpositiontaking_3 >0.93
				OR @v99mpositiontaking_20 <0 OR @v99mpositiontaking_20 >0.93							
				OR @v99mpositiontaking_10 <0 OR @v99mpositiontaking_10 >0.93		
				OR @v99mpositiontaking_9999 <0 OR @v99mpositiontaking_9999 >0.93							
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 5
				SELECT @ErrMsg_cur = 	CASE @Language 
									WHEN 'E' THEN 'Wrong position taking.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
				RETURN
			END				
			
			--don't allow update autoPT incase DisableAutoMPT = 1
			IF ((@isauto_v99mpositiontaking_mem_1 = 1 AND @old_isauto_v99mpositiontaking_mem_1 = 0)
				OR (@isauto_v99mpositiontaking_mem_2 = 1 AND @old_isauto_v99mpositiontaking_mem_2 = 0)
				OR (@isauto_v99mpositiontaking_mem_3 = 1 AND @old_isauto_v99mpositiontaking_mem_3 = 0)
				OR (@isauto_v99mpositiontaking_mem_10 = 1 AND @old_isauto_v99mpositiontaking_mem_10 = 0)
				OR (@isauto_v99mpositiontaking_mem_20 = 1 AND @old_isauto_v99mpositiontaking_mem_20 = 0)
				OR (@isauto_v99mpositiontaking_mem_9999 = 1 AND @old_isauto_v99mpositiontaking_mem_9999 = 0)
				)
				AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
							WHERE custid = @mrecommend 
								AND DisableAutoMPT = 1)
			BEGIN
				SELECT @ErrCode = 110,
					   @ErrMsg = CASE @Language 			   
										WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
									END	
				RETURN					
			END
			
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
			FROM custoverride AS co WITH (NOLOCK) INNER JOIN
				(	SELECT 99 AS sporttype, 1 AS bettype, @auto_v99mpositiontaking_mem_1 AS autopositiontaking, @isauto_v99mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 2 AS bettype, @auto_v99mpositiontaking_mem_2 AS autopositiontaking, @isauto_v99mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 3 AS bettype, @auto_v99mpositiontaking_mem_3 AS autopositiontaking, @isauto_v99mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 20 AS bettype, @auto_v99mpositiontaking_mem_20 AS autopositiontaking, @isauto_v99mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 10 AS bettype, @auto_v99mpositiontaking_mem_10 AS autopositiontaking, @isauto_v99mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 9999 AS bettype, @auto_v99mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v99mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

			WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

				RETURN
			END

			--Check um1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(	SELECT 99 AS sporttype, 1 AS bettype, @max_v99mapositiontaking_1 AS maxmpositiontaking, @auto_v99mpositiontaking_mem_1 AS autopositiontaking, @isauto_v99mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 2 AS bettype, @max_v99mapositiontaking_2 AS maxmpositiontaking,@auto_v99mpositiontaking_mem_2 AS autopositiontaking, @isauto_v99mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 3 AS bettype, @max_v99mapositiontaking_3 AS maxmpositiontaking,@auto_v99mpositiontaking_mem_3 AS autopositiontaking, @isauto_v99mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 20 AS bettype, @max_v99mapositiontaking_20 AS maxmpositiontaking,@auto_v99mpositiontaking_mem_20 AS autopositiontaking, @isauto_v99mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 10 AS bettype, @max_v99mapositiontaking_10 AS maxmpositiontaking,@auto_v99mpositiontaking_mem_10 AS autopositiontaking, @isauto_v99mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 9999 AS bettype, @max_v99mapositiontaking_9999 AS maxmpositiontaking,@auto_v99mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v99mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
				
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END
			
			--Check um1>= um1_min (=m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
			FROM 
				(	SELECT 99 AS sporttype, 1 AS bettype, @min_v99mp_1 AS minmpositiontaking, @auto_v99mpositiontaking_mem_1 AS autopositiontaking, @isauto_v99mpositiontaking_mem_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 2 AS bettype, @min_v99mp_2 AS minmpositiontaking,@auto_v99mpositiontaking_mem_2 AS autopositiontaking, @isauto_v99mpositiontaking_mem_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 3 AS bettype, @min_v99mp_3 AS minmpositiontaking,@auto_v99mpositiontaking_mem_3 AS autopositiontaking, @isauto_v99mpositiontaking_mem_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 20 AS bettype, @min_v99mp_20 AS minmpositiontaking,@auto_v99mpositiontaking_mem_20 AS autopositiontaking, @isauto_v99mpositiontaking_mem_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 10 AS bettype, @min_v99mp_10 AS minmpositiontaking,@auto_v99mpositiontaking_mem_10 AS autopositiontaking, @isauto_v99mpositiontaking_mem_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype, 9999 AS bettype, @min_v99mp_9999 AS minmpositiontaking,@auto_v99mpositiontaking_mem_9999 AS autopositiontaking, @isauto_v99mpositiontaking_mem_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
				) AS b 
			inner join #tmp_Sports sports ON b.sporttype = sports.ID
			inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 11,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END		
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
											
				RETURN
			END
						
			--Check m1<=min(m3,m4)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
			+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
			FROM (
									SELECT 99 AS sporttype	,	 1 AS bettype	,	 @v99mpositiontaking_1 AS mpositiontaking	,	 @max_v99mapositiontaking_1 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 2 AS bettype	,	 @v99mpositiontaking_2 AS mpositiontaking	,	 @max_v99mapositiontaking_2 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 3 AS bettype	,	 @v99mpositiontaking_3 AS mpositiontaking	,	 @max_v99mapositiontaking_3 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 20 AS bettype	,	 @v99mpositiontaking_20 AS mpositiontaking	,	 @max_v99mapositiontaking_20 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 10 AS bettype	,	 @v99mpositiontaking_10 AS mpositiontaking	,	 @max_v99mapositiontaking_10 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 9999 AS bettype	,	 @v99mpositiontaking_9999 AS mpositiontaking	,	 @max_v99mapositiontaking_9999 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking
			)b 	
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE (b.mpositiontaking>b.maxmpositiontaking) 
				OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 8,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			--Check m1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
			+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(
										SELECT 99 AS sporttype	,	 1 AS bettype	,	 @v99mpositiontaking_1 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 99 AS sporttype	,	 2 AS bettype	,	 @v99mpositiontaking_2 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 99 AS sporttype	,	 3 AS bettype	,	 @v99mpositiontaking_3 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 99 AS sporttype	,	 20 AS bettype	,	 @v99mpositiontaking_20 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 99 AS sporttype	,	 10 AS bettype	,	 @v99mpositiontaking_10 AS mpositiontaking	,	 0 AS mlivepositiontaking
						UNION ALL		SELECT 99 AS sporttype	,	 9999 AS bettype	,	 @v99mpositiontaking_9999 AS mpositiontaking	,	 0 AS mlivepositiontaking
					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 9,
  						@ErrMsg_cur = @UserName + ': '+
							 CASE @Language 
									WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
							END
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
			
			--check m1<=m1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 99 AS sporttype	,	 1 AS bettype	,	 @v99mpositiontaking_1 AS mpositiontaking	,@max_v99mp_1 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 2 AS bettype	,	 @v99mpositiontaking_2 AS mpositiontaking	,	 @max_v99mp_2 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 3 AS bettype	,	 @v99mpositiontaking_3 AS mpositiontaking	,	 @max_v99mp_3 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 20 AS bettype	,	 @v99mpositiontaking_20 AS mpositiontaking	,	 @max_v99mp_20 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 10 AS bettype	,	 @v99mpositiontaking_10 AS mpositiontaking	,	 @max_v99mp_10 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_10 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 9999 AS bettype	,	 @v99mpositiontaking_9999 AS mpositiontaking	,	 @max_v99mp_9999 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_9999 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 10,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
			
			--check m1>=m1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
			FROM
				(
						SELECT 99 AS sporttype	,	 1 AS bettype	,	 @v99mpositiontaking_1 AS mpositiontaking	,@min_v99mp_1 as minmpositiontaking, @isauto_v99mpositiontaking_mem_1 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_1 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 2 AS bettype	,	 @v99mpositiontaking_2 AS mpositiontaking	,	 @min_v99mp_2 as minmpositiontaking, @isauto_v99mpositiontaking_mem_2 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_2 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 3 AS bettype	,	 @v99mpositiontaking_3 AS mpositiontaking	,	 @min_v99mp_3 as minmpositiontaking, @isauto_v99mpositiontaking_mem_3 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_3 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 20 AS bettype	,	 @v99mpositiontaking_20 AS mpositiontaking	,	 @min_v99mp_20 as minmpositiontaking, @isauto_v99mpositiontaking_mem_20 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_20 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 10 AS bettype	,	 @v99mpositiontaking_10 AS mpositiontaking	,	 @min_v99mp_10 as minmpositiontaking, @isauto_v99mpositiontaking_mem_10 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_10 as isauto_mpositiontaking
					UNION ALL		SELECT 99 AS sporttype	,	 9999 AS bettype	,	 @v99mpositiontaking_9999 AS mpositiontaking	,	 @min_v99mp_9999 as minmpositiontaking, @isauto_v99mpositiontaking_mem_9999 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_9999 as isauto_mpositiontaking
				) b
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
			WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
			
			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 12,
						@ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END							
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					
				RETURN
			END
		
		END	--@UpdatePositiontakingv99
			
		--Mix Parlay Mixed Sports
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv99MP = 1	)
			BEGIN--@UpdatePositiontakingv99MP
				if 			
					@v99mpositiontaking_9 <0 OR @v99mpositiontaking_9 >0.93
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 5
					SELECT @ErrMsg_cur = 	CASE @Language 
										WHEN 'E' THEN 'Wrong position taking.'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
								END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
							
					RETURN
				END				
				
				--don't allow update autoPT incase DisableAutoMPT = 1
				IF (@isauto_v99mpositiontaking_mem_9 = 1 AND @old_isauto_v99mpositiontaking_mem_9 = 0)					
					AND EXISTS (SELECT 1 FROM CustMaster WITH(NOLOCK) 
								WHERE custid = @mrecommend 
									AND DisableAutoMPT = 1)
				BEGIN
					SELECT @ErrCode = 110,
						   @ErrMsg = CASE @Language 			   
											WHEN 'E' THEN 'You are not allowed to have Auto PT, please contact your upline.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20044,@Language) 
										END	
					RETURN					
				END
				
			--Check um1<=l3
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
				FROM custoverride AS co WITH (NOLOCK) INNER JOIN
					(	
						SELECT 99 AS sporttype, 9 AS bettype, @auto_v99mpositiontaking_mem_9 AS autopositiontaking, @isauto_v99mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID

				WHERE co.custid = @mrecommend AND ((b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>co.maxlivepositiontaking))

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 6,
						   @ErrMsg_cur = CASE @Language 
										WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
								END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)

					RETURN
				END

				--Check um1<=min(m3,m4)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(	
						SELECT 99 AS sporttype, 9 AS bettype, @max_v99mapositiontaking_9 AS maxmpositiontaking, @auto_v99mpositiontaking_mem_9 AS autopositiontaking, @isauto_v99mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS maxmlivepositiontaking
					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE (b.isautopositiontaking>0 AND b.autopositiontaking>b.maxmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking>b.maxmlivepositiontaking)

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 7,
						   @ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END		
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
												
					RETURN
				END	
				
				--Check um1>=um1_min(=m1_min)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MinLive: '+ dbo.f_FomatNumericToChar((b.minmlivepositiontaking)) ELSE '' END + '<br>'
				FROM 
					(	
						SELECT 99 AS sporttype, 9 AS bettype, @min_v99mp_9 AS minmpositiontaking, @auto_v99mpositiontaking_mem_9 AS autopositiontaking, @isauto_v99mpositiontaking_mem_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS minmlivepositiontaking
					) AS b 
				inner join #tmp_Sports sports ON b.sporttype = sports.ID
				inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minmpositiontaking) OR (b.isautolivepositiontaking>0 AND b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.autolivepositiontaking<b.minmlivepositiontaking)

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 11,
						   @ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END		
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
												
					RETURN
				END	
								
				--Check m1<=min(m3,m4)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking))
				+ CASE WHEN b.sporttype in (1) AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((b.maxmlivepositiontaking)) ELSE '' END + '<br>'
				FROM (
						SELECT 99 AS sporttype	,	 9 AS bettype	,	 @v99mpositiontaking_9 AS mpositiontaking	,	 @max_v99mapositiontaking_9 AS maxmpositiontaking	,	 0 AS mlivepositiontaking	,	 0 AS maxmlivepositiontaking

				)b 	
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE (b.mpositiontaking>b.maxmpositiontaking) 
					OR (b.sporttype in (1) AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>b.maxmlivepositiontaking)

				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 8,
							@ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END							
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
					RETURN
				END


				--Check m1<=l3
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Max: '+ dbo.f_FomatNumericToChar((co.maxpositiontaking))
				+ CASE WHEN b.sporttype=1 AND b.bettype IN (1,3,7,8) THEN '-MaxLive: '+ dbo.f_FomatNumericToChar((co.maxlivepositiontaking)) ELSE '' END + '<br>'
					FROM custoverride AS co WITH (NOLOCK) INNER JOIN
						(
							SELECT 99 AS sporttype	,	 9 AS bettype	,	 @v99mpositiontaking_9 AS mpositiontaking	,	 0 AS mlivepositiontaking
						) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE co.custid = @mrecommend AND ((b.mpositiontaking>co.maxpositiontaking) OR (b.sporttype=1 AND b.bettype IN (1,3,7,8) AND b.mlivepositiontaking>co.maxlivepositiontaking))
				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 9,
  							@ErrMsg_cur = @UserName + ': '+
								 CASE @Language 
										WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
								END
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						   @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					RETURN
				END		
				
				--check m1<=m1_max
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Max: '+ dbo.f_FomatNumericToChar((b.maxmpositiontaking)) + '<br>'
				FROM
					(
							SELECT 99 AS sporttype	,	 9 AS bettype	,	 @v99mpositiontaking_9 AS mpositiontaking	,@max_v99mp_9 as maxmpositiontaking, @isauto_v99mpositiontaking_mem_9 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_9 as isauto_mpositiontaking
					) b
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE b.mpositiontaking > maxmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
				
				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 10,
							@ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END							
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
					RETURN
				END		
				
				--check m1>=m1_min
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sports.Name + '-'+ bettype.Name + '-Min: '+ dbo.f_FomatNumericToChar((b.minmpositiontaking)) + '<br>'
				FROM
					(
							SELECT 99 AS sporttype	,	 9 AS bettype	,	 @v99mpositiontaking_9 AS mpositiontaking	,@min_v99mp_9 as minmpositiontaking, @isauto_v99mpositiontaking_mem_9 as isauto_mpositiontaking_mem, @isauto_v99mpositiontaking_9 as isauto_mpositiontaking
					) b
					inner join #tmp_Sports sports ON b.sporttype = sports.ID
					inner join #tmp_Bettype bettype ON b.bettype = bettype.ID
				WHERE b.mpositiontaking < minmpositiontaking and isauto_mpositiontaking_mem = 0 and isauto_mpositiontaking = 0 
				
				IF @ErrType <>''
				BEGIN
					SELECT @ErrCode_cur = 12,
							@ErrMsg_cur = @UserName + ': '+
										CASE @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END							
					SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						
					RETURN
				END		
				
			END--@UpdatePositiontakingv99MP

		--m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1
		SELECT 
			@mpositiontaking_1 = CASE WHEN @mpositiontaking_1+@apositiontaking_1>@max_mapositiontaking_1 THEN @max_mapositiontaking_1-@apositiontaking_1 ELSE @mpositiontaking_1 END,
			@mpositiontaking_2 = CASE WHEN @mpositiontaking_2+@apositiontaking_2>@max_mapositiontaking_2 THEN @max_mapositiontaking_2-@apositiontaking_2 ELSE @mpositiontaking_2 END,
			@mpositiontaking_3 = CASE WHEN @mpositiontaking_3+@apositiontaking_3>@max_mapositiontaking_3 THEN @max_mapositiontaking_3-@apositiontaking_3 ELSE @mpositiontaking_3 END,
			@mpositiontaking_4 = CASE WHEN @mpositiontaking_4+@apositiontaking_4>@max_mapositiontaking_4 THEN @max_mapositiontaking_4-@apositiontaking_4 ELSE @mpositiontaking_4 END,
			@mpositiontaking_5 = CASE WHEN @mpositiontaking_5+@apositiontaking_5>@max_mapositiontaking_5 THEN @max_mapositiontaking_5-@apositiontaking_5 ELSE @mpositiontaking_5 END,
			@mpositiontaking_6 = CASE WHEN @mpositiontaking_6+@apositiontaking_6>@max_mapositiontaking_6 THEN @max_mapositiontaking_6-@apositiontaking_6 ELSE @mpositiontaking_6 END,
			@mpositiontaking_7 = CASE WHEN @mpositiontaking_7+@apositiontaking_7>@max_mapositiontaking_7 THEN @max_mapositiontaking_7-@apositiontaking_7 ELSE @mpositiontaking_7 END,
			@mpositiontaking_8 = CASE WHEN @mpositiontaking_8+@apositiontaking_8>@max_mapositiontaking_8 THEN @max_mapositiontaking_8-@apositiontaking_8 ELSE @mpositiontaking_8 END,
			@mpositiontaking_9 = CASE WHEN @mpositiontaking_9+@apositiontaking_9>@max_mapositiontaking_9 THEN @max_mapositiontaking_9-@apositiontaking_9 ELSE @mpositiontaking_9 END,
			@mpositiontaking_10 = CASE WHEN @mpositiontaking_10+@apositiontaking_10>@max_mapositiontaking_10 THEN @max_mapositiontaking_10-@apositiontaking_10 ELSE @mpositiontaking_10 END,
			
			-- Outright PT for sports
			@v2mpositiontaking_10 = CASE WHEN @v2mpositiontaking_10+@v2apositiontaking_10>@max_v2mapositiontaking_10 THEN @max_v2mapositiontaking_10-@v2apositiontaking_10 ELSE @v2mpositiontaking_10 END,
			@v3mpositiontaking_10 = CASE WHEN @v3mpositiontaking_10+@v3apositiontaking_10>@max_v3mapositiontaking_10 THEN @max_v3mapositiontaking_10-@v3apositiontaking_10 ELSE @v3mpositiontaking_10 END,
			@v5mpositiontaking_10 = CASE WHEN @v5mpositiontaking_10+@v5apositiontaking_10>@max_v5mapositiontaking_10 THEN @max_v5mapositiontaking_10-@v5apositiontaking_10 ELSE @v5mpositiontaking_10 END,
			@v8mpositiontaking_10 = CASE WHEN @v8mpositiontaking_10+@v8apositiontaking_10>@max_v8mapositiontaking_10 THEN @max_v8mapositiontaking_10-@v8apositiontaking_10 ELSE @v8mpositiontaking_10 END,
			@v10mpositiontaking_10 = CASE WHEN @v10mpositiontaking_10+@v10apositiontaking_10>@max_v10mapositiontaking_10 THEN @max_v10mapositiontaking_10-@v10apositiontaking_10 ELSE @v10mpositiontaking_10 END,
			@v11mpositiontaking_10 = CASE WHEN @v11mpositiontaking_10+@v11apositiontaking_10>@max_v11mapositiontaking_10 THEN @max_v11mapositiontaking_10-@v11apositiontaking_10 ELSE @v11mpositiontaking_10 END,
			@v99mpositiontaking_10 = CASE WHEN @v99mpositiontaking_10+@v99apositiontaking_10>@max_v99mapositiontaking_10 THEN @max_v99mapositiontaking_10-@v99apositiontaking_10 ELSE @v99mpositiontaking_10 END,
			
			
			@mpositiontaking_9999 = CASE WHEN @mpositiontaking_9999+@apositiontaking_9999>@max_mapositiontaking_9999 THEN @max_mapositiontaking_9999-@apositiontaking_9999 ELSE @mpositiontaking_9999 END,

			@mlivepositiontaking_1 = CASE WHEN @mlivepositiontaking_1+@alivepositiontaking_1>@max_malivepositiontaking_1 THEN @max_malivepositiontaking_1-@alivepositiontaking_1 ELSE @mlivepositiontaking_1 END,
			@mlivepositiontaking_3 = CASE WHEN @mlivepositiontaking_3+@alivepositiontaking_3>@max_malivepositiontaking_3 THEN @max_malivepositiontaking_3-@alivepositiontaking_3 ELSE @mlivepositiontaking_3 END,
			@mlivepositiontaking_7 = CASE WHEN @mlivepositiontaking_7+@alivepositiontaking_7>@max_malivepositiontaking_7 THEN @max_malivepositiontaking_7-@alivepositiontaking_7 ELSE @mlivepositiontaking_7 END,
			@mlivepositiontaking_8 = CASE WHEN @mlivepositiontaking_8+@alivepositiontaking_8>@max_malivepositiontaking_8 THEN @max_malivepositiontaking_8-@alivepositiontaking_8 ELSE @mlivepositiontaking_8 END,

			@v2mpositiontaking_1 = CASE WHEN @v2apositiontaking_1+@v2mpositiontaking_1>@max_v2mapositiontaking_1 THEN @max_v2mapositiontaking_1-@v2apositiontaking_1 ELSE @v2mpositiontaking_1 END,
			@v2mpositiontaking_2 = CASE WHEN @v2apositiontaking_2+@v2mpositiontaking_2>@max_v2mapositiontaking_2 THEN @max_v2mapositiontaking_2-@v2apositiontaking_2 ELSE @v2mpositiontaking_2 END,
			@v2mpositiontaking_3 = CASE WHEN @v2apositiontaking_3+@v2mpositiontaking_3>@max_v2mapositiontaking_3 THEN @max_v2mapositiontaking_3-@v2apositiontaking_3 ELSE @v2mpositiontaking_3 END,
			@v2mpositiontaking_7 = CASE WHEN @v2apositiontaking_7+@v2mpositiontaking_7>@max_v2mapositiontaking_7 THEN @max_v2mapositiontaking_7-@v2apositiontaking_7 ELSE @v2mpositiontaking_7 END,
			@v2mpositiontaking_8 = CASE WHEN @v2apositiontaking_8+@v2mpositiontaking_8>@max_v2mapositiontaking_8 THEN @max_v2mapositiontaking_8-@v2apositiontaking_8 ELSE @v2mpositiontaking_8 END,
		--	@v2mpositiontaking_9 = CASE WHEN @v2apositiontaking_9+@v2mpositiontaking_9>@max_v2mapositiontaking_9 THEN @max_v2mapositiontaking_9-@v2apositiontaking_9 ELSE @v2mpositiontaking_9 END,
			@v2mpositiontaking_20 = CASE WHEN @v2apositiontaking_20+@v2mpositiontaking_20>@max_v2mapositiontaking_20 THEN @max_v2mapositiontaking_20-@v2apositiontaking_20 ELSE @v2mpositiontaking_20 END,
			@v2mpositiontaking_9999 = CASE WHEN @v2apositiontaking_9999+@v2mpositiontaking_9999>@max_v2mapositiontaking_9999 THEN @max_v2mapositiontaking_9999-@v2apositiontaking_9999 ELSE @v2mpositiontaking_9999 END,

			@v3mpositiontaking_1 = CASE WHEN @v3apositiontaking_1+@v3mpositiontaking_1>@max_v3mapositiontaking_1 THEN @max_v3mapositiontaking_1-@v3apositiontaking_1 ELSE @v3mpositiontaking_1 END,
			@v3mpositiontaking_2 = CASE WHEN @v3apositiontaking_2+@v3mpositiontaking_2>@max_v3mapositiontaking_2 THEN @max_v3mapositiontaking_2-@v3apositiontaking_2 ELSE @v3mpositiontaking_2 END,
			@v3mpositiontaking_3 = CASE WHEN @v3apositiontaking_3+@v3mpositiontaking_3>@max_v3mapositiontaking_3 THEN @max_v3mapositiontaking_3-@v3apositiontaking_3 ELSE @v3mpositiontaking_3 END,
			@v3mpositiontaking_20 = CASE WHEN @v3apositiontaking_20+@v3mpositiontaking_20>@max_v3mapositiontaking_20 THEN @max_v3mapositiontaking_20-@v3apositiontaking_20 ELSE @v3mpositiontaking_20 END,

			@v5mpositiontaking_1 = CASE WHEN @v5apositiontaking_1+@v5mpositiontaking_1>@max_v5mapositiontaking_1 THEN @max_v5mapositiontaking_1-@v5apositiontaking_1 ELSE @v5mpositiontaking_1 END,
			@v5mpositiontaking_2 = CASE WHEN @v5apositiontaking_2+@v5mpositiontaking_2>@max_v5mapositiontaking_2 THEN @max_v5mapositiontaking_2-@v5apositiontaking_2 ELSE @v5mpositiontaking_2 END,
			@v5mpositiontaking_3 = CASE WHEN @v5apositiontaking_3+@v5mpositiontaking_3>@max_v5mapositiontaking_3 THEN @max_v5mapositiontaking_3-@v5apositiontaking_3 ELSE @v5mpositiontaking_3 END,
			@v5mpositiontaking_20 = CASE WHEN @v5apositiontaking_20+@v5mpositiontaking_20>@max_v5mapositiontaking_20 THEN @max_v5mapositiontaking_20-@v5apositiontaking_20 ELSE @v5mpositiontaking_20 END,
			@v5mpositiontaking_9999 = CASE WHEN @v5apositiontaking_9999+@v5mpositiontaking_9999>@max_v5mapositiontaking_9999 THEN @max_v5mapositiontaking_9999-@v5apositiontaking_9999 ELSE @v5mpositiontaking_9999 END,

			@v8mpositiontaking_1 = CASE WHEN @v8apositiontaking_1+@v8mpositiontaking_1>@max_v8mapositiontaking_1 THEN @max_v8mapositiontaking_1-@v8apositiontaking_1 ELSE @v8mpositiontaking_1 END,
			@v8mpositiontaking_3 = CASE WHEN @v8apositiontaking_3+@v8mpositiontaking_3>@max_v8mapositiontaking_3 THEN @max_v8mapositiontaking_3-@v8apositiontaking_3 ELSE @v8mpositiontaking_3 END,
			@v8mpositiontaking_20 = CASE WHEN @v8apositiontaking_20+@v8mpositiontaking_20>@max_v8mapositiontaking_20 THEN @max_v8mapositiontaking_20-@v8apositiontaking_20 ELSE @v8mpositiontaking_20 END,

			@v10mpositiontaking_1 = CASE WHEN @v10apositiontaking_1+@v10mpositiontaking_1>@max_v10mapositiontaking_1 THEN @max_v10mapositiontaking_1-@v10apositiontaking_1 ELSE @v10mpositiontaking_1 END,
			@v10mpositiontaking_2 = CASE WHEN @v10apositiontaking_2+@v10mpositiontaking_2>@max_v10mapositiontaking_2 THEN @max_v10mapositiontaking_2-@v10apositiontaking_2 ELSE @v10mpositiontaking_2 END,
			@v10mpositiontaking_3 = CASE WHEN @v10apositiontaking_3+@v10mpositiontaking_3>@max_v10mapositiontaking_3 THEN @max_v10mapositiontaking_3-@v10apositiontaking_3 ELSE @v10mpositiontaking_3 END,
			@v10mpositiontaking_20 = CASE WHEN @v10apositiontaking_20+@v10mpositiontaking_20>@max_v10mapositiontaking_20 THEN @max_v10mapositiontaking_20-@v10apositiontaking_20 ELSE @v10mpositiontaking_20 END,

			@v11mpositiontaking_1 = CASE WHEN @v11apositiontaking_1+@v11mpositiontaking_1>@max_v11mapositiontaking_1 THEN @max_v11mapositiontaking_1-@v11apositiontaking_1 ELSE @v11mpositiontaking_1 END,
			@v11mpositiontaking_20 = CASE WHEN @v11apositiontaking_20+@v11mpositiontaking_20>@max_v11mapositiontaking_20 THEN @max_v11mapositiontaking_20-@v11apositiontaking_20 ELSE @v11mpositiontaking_20 END,

			@v99mpositiontaking_1 = CASE WHEN @v99apositiontaking_1+@v99mpositiontaking_1>@max_v99mapositiontaking_1 THEN @max_v99mapositiontaking_1-@v99apositiontaking_1 ELSE @v99mpositiontaking_1 END,
			@v99mpositiontaking_2 = CASE WHEN @v99apositiontaking_2+@v99mpositiontaking_2>@max_v99mapositiontaking_2 THEN @max_v99mapositiontaking_2-@v99apositiontaking_2 ELSE @v99mpositiontaking_2 END,
			@v99mpositiontaking_3 = CASE WHEN @v99apositiontaking_3+@v99mpositiontaking_3>@max_v99mapositiontaking_3 THEN @max_v99mapositiontaking_3-@v99apositiontaking_3 ELSE @v99mpositiontaking_3 END,
			@v99mpositiontaking_20 = CASE WHEN @v99apositiontaking_20+@v99mpositiontaking_20>@max_v99mapositiontaking_20 THEN @max_v99mapositiontaking_20-@v99apositiontaking_20 ELSE @v99mpositiontaking_20 END,
			@v99mpositiontaking_9999 = CASE WHEN @v99apositiontaking_9999+@v99mpositiontaking_9999>@max_v99mapositiontaking_9999 THEN @max_v99mapositiontaking_9999-@v99apositiontaking_9999 ELSE @v99mpositiontaking_9999 END,
			-- mixed sports
			@v99mpositiontaking_9 = CASE WHEN @v99apositiontaking_9+@v99mpositiontaking_9>@max_v99mapositiontaking_9 THEN @max_v99mapositiontaking_9-@v99apositiontaking_9 ELSE @v99mpositiontaking_9 END
		
		--m1=m1+a1<n3?n3-a1:m1
		SELECT 
			@mpositiontaking_1 = CASE WHEN @mpositiontaking_1+@apositiontaking_1<@min_mapositiontaking_1 THEN @min_mapositiontaking_1-@apositiontaking_1 ELSE @mpositiontaking_1 END,
			@mpositiontaking_2 = CASE WHEN @mpositiontaking_2+@apositiontaking_2<@min_mapositiontaking_2 THEN @min_mapositiontaking_2-@apositiontaking_2 ELSE @mpositiontaking_2 END,
			@mpositiontaking_3 = CASE WHEN @mpositiontaking_3+@apositiontaking_3<@min_mapositiontaking_3 THEN @min_mapositiontaking_3-@apositiontaking_3 ELSE @mpositiontaking_3 END,
			@mpositiontaking_4 = CASE WHEN @mpositiontaking_4+@apositiontaking_4<@min_mapositiontaking_4 THEN @min_mapositiontaking_4-@apositiontaking_4 ELSE @mpositiontaking_4 END,
			@mpositiontaking_5 = CASE WHEN @mpositiontaking_5+@apositiontaking_5<@min_mapositiontaking_5 THEN @min_mapositiontaking_5-@apositiontaking_5 ELSE @mpositiontaking_5 END,
			@mpositiontaking_6 = CASE WHEN @mpositiontaking_6+@apositiontaking_6<@min_mapositiontaking_6 THEN @min_mapositiontaking_6-@apositiontaking_6 ELSE @mpositiontaking_6 END,
			@mpositiontaking_7 = CASE WHEN @mpositiontaking_7+@apositiontaking_7<@min_mapositiontaking_7 THEN @min_mapositiontaking_7-@apositiontaking_7 ELSE @mpositiontaking_7 END,
			@mpositiontaking_8 = CASE WHEN @mpositiontaking_8+@apositiontaking_8<@min_mapositiontaking_8 THEN @min_mapositiontaking_8-@apositiontaking_8 ELSE @mpositiontaking_8 END,
			@mpositiontaking_9 = CASE WHEN @mpositiontaking_9+@apositiontaking_9<@min_mapositiontaking_9 THEN @min_mapositiontaking_9-@apositiontaking_9 ELSE @mpositiontaking_9 END,
			@mpositiontaking_10 = CASE WHEN @mpositiontaking_10+@apositiontaking_10<@min_mapositiontaking_10 THEN @min_mapositiontaking_10-@apositiontaking_10 ELSE @mpositiontaking_10 END,
			
			-- Outright PT for sports
			@v2mpositiontaking_10 = CASE WHEN @v2mpositiontaking_10+@v2apositiontaking_10<@min_v2mapositiontaking_10 THEN @min_v2mapositiontaking_10-@v2apositiontaking_10 ELSE @v2mpositiontaking_10 END,
			@v3mpositiontaking_10 = CASE WHEN @v3mpositiontaking_10+@v3apositiontaking_10<@min_v3mapositiontaking_10 THEN @min_v3mapositiontaking_10-@v3apositiontaking_10 ELSE @v3mpositiontaking_10 END,
			@v5mpositiontaking_10 = CASE WHEN @v5mpositiontaking_10+@v5apositiontaking_10<@min_v5mapositiontaking_10 THEN @min_v5mapositiontaking_10-@v5apositiontaking_10 ELSE @v5mpositiontaking_10 END,
			@v8mpositiontaking_10 = CASE WHEN @v8mpositiontaking_10+@v8apositiontaking_10<@min_v8mapositiontaking_10 THEN @min_v8mapositiontaking_10-@v8apositiontaking_10 ELSE @v8mpositiontaking_10 END,
			@v10mpositiontaking_10 = CASE WHEN @v10mpositiontaking_10+@v10apositiontaking_10<@min_v10mapositiontaking_10 THEN @min_v10mapositiontaking_10-@v10apositiontaking_10 ELSE @v10mpositiontaking_10 END,
			@v11mpositiontaking_10 = CASE WHEN @v11mpositiontaking_10+@v11apositiontaking_10<@min_v11mapositiontaking_10 THEN @min_v11mapositiontaking_10-@v11apositiontaking_10 ELSE @v11mpositiontaking_10 END,
			@v99mpositiontaking_10 = CASE WHEN @v99mpositiontaking_10+@v99apositiontaking_10<@min_v99mapositiontaking_10 THEN @min_v99mapositiontaking_10-@v99apositiontaking_10 ELSE @v99mpositiontaking_10 END,
			
			@mpositiontaking_9999 = CASE WHEN @mpositiontaking_9999+@apositiontaking_9999<@min_mapositiontaking_9999 THEN @min_mapositiontaking_9999-@apositiontaking_9999 ELSE @mpositiontaking_9999 END,

			@mlivepositiontaking_1 = CASE WHEN @mlivepositiontaking_1+@alivepositiontaking_1<@min_malivepositiontaking_1 THEN @min_malivepositiontaking_1-@alivepositiontaking_1 ELSE @mlivepositiontaking_1 END,
			@mlivepositiontaking_3 = CASE WHEN @mlivepositiontaking_3+@alivepositiontaking_3<@min_malivepositiontaking_3 THEN @min_malivepositiontaking_3-@alivepositiontaking_3 ELSE @mlivepositiontaking_3 END,
			@mlivepositiontaking_7 = CASE WHEN @mlivepositiontaking_7+@alivepositiontaking_7<@min_malivepositiontaking_7 THEN @min_malivepositiontaking_7-@alivepositiontaking_7 ELSE @mlivepositiontaking_7 END,
			@mlivepositiontaking_8 = CASE WHEN @mlivepositiontaking_8+@alivepositiontaking_8<@min_malivepositiontaking_8 THEN @min_malivepositiontaking_8-@alivepositiontaking_8 ELSE @mlivepositiontaking_8 END,

			@v2mpositiontaking_1 = CASE WHEN @v2apositiontaking_1+@v2mpositiontaking_1<@min_v2mapositiontaking_1 THEN @min_v2mapositiontaking_1-@v2apositiontaking_1 ELSE @v2mpositiontaking_1 END,
			@v2mpositiontaking_2 = CASE WHEN @v2apositiontaking_2+@v2mpositiontaking_2<@min_v2mapositiontaking_2 THEN @min_v2mapositiontaking_2-@v2apositiontaking_2 ELSE @v2mpositiontaking_2 END,
			@v2mpositiontaking_3 = CASE WHEN @v2apositiontaking_3+@v2mpositiontaking_3<@min_v2mapositiontaking_3 THEN @min_v2mapositiontaking_3-@v2apositiontaking_3 ELSE @v2mpositiontaking_3 END,
			@v2mpositiontaking_7 = CASE WHEN @v2apositiontaking_7+@v2mpositiontaking_7<@min_v2mapositiontaking_7 THEN @min_v2mapositiontaking_7-@v2apositiontaking_7 ELSE @v2mpositiontaking_7 END,
			@v2mpositiontaking_8 = CASE WHEN @v2apositiontaking_8+@v2mpositiontaking_8<@min_v2mapositiontaking_8 THEN @min_v2mapositiontaking_8-@v2apositiontaking_8 ELSE @v2mpositiontaking_8 END,
		--	@v2mpositiontaking_9 = CASE WHEN @v2apositiontaking_9+@v2mpositiontaking_9<@min_v2mapositiontaking_9 THEN @min_v2mapositiontaking_9-@v2apositiontaking_9 ELSE @v2mpositiontaking_9 END,
			@v2mpositiontaking_20 = CASE WHEN @v2apositiontaking_20+@v2mpositiontaking_20<@min_v2mapositiontaking_20 THEN @min_v2mapositiontaking_20-@v2apositiontaking_20 ELSE @v2mpositiontaking_20 END,
			@v2mpositiontaking_9999 = CASE WHEN @v2apositiontaking_9999+@v2mpositiontaking_9999<@min_v2mapositiontaking_9999 THEN @min_v2mapositiontaking_9999-@v2apositiontaking_9999 ELSE @v2mpositiontaking_9999 END,

			@v3mpositiontaking_1 = CASE WHEN @v3apositiontaking_1+@v3mpositiontaking_1<@min_v3mapositiontaking_1 THEN @min_v3mapositiontaking_1-@v3apositiontaking_1 ELSE @v3mpositiontaking_1 END,
			@v3mpositiontaking_2 = CASE WHEN @v3apositiontaking_2+@v3mpositiontaking_2<@min_v3mapositiontaking_2 THEN @min_v3mapositiontaking_2-@v3apositiontaking_2 ELSE @v3mpositiontaking_2 END,
			@v3mpositiontaking_3 = CASE WHEN @v3apositiontaking_3+@v3mpositiontaking_3<@min_v3mapositiontaking_3 THEN @min_v3mapositiontaking_3-@v3apositiontaking_3 ELSE @v3mpositiontaking_3 END,
			@v3mpositiontaking_20 = CASE WHEN @v3apositiontaking_20+@v3mpositiontaking_20<@min_v3mapositiontaking_20 THEN @min_v3mapositiontaking_20-@v3apositiontaking_20 ELSE @v3mpositiontaking_20 END,

			@v5mpositiontaking_1 = CASE WHEN @v5apositiontaking_1+@v5mpositiontaking_1<@min_v5mapositiontaking_1 THEN @min_v5mapositiontaking_1-@v5apositiontaking_1 ELSE @v5mpositiontaking_1 END,
			@v5mpositiontaking_2 = CASE WHEN @v5apositiontaking_2+@v5mpositiontaking_2<@min_v5mapositiontaking_2 THEN @min_v5mapositiontaking_2-@v5apositiontaking_2 ELSE @v5mpositiontaking_2 END,
			@v5mpositiontaking_3 = CASE WHEN @v5apositiontaking_3+@v5mpositiontaking_3<@min_v5mapositiontaking_3 THEN @min_v5mapositiontaking_3-@v5apositiontaking_3 ELSE @v5mpositiontaking_3 END,
			@v5mpositiontaking_20 = CASE WHEN @v5apositiontaking_20+@v5mpositiontaking_20<@min_v5mapositiontaking_20 THEN @min_v5mapositiontaking_20-@v5apositiontaking_20 ELSE @v5mpositiontaking_20 END,
			@v5mpositiontaking_9999 = CASE WHEN @v5apositiontaking_9999+@v5mpositiontaking_9999<@min_v5mapositiontaking_9999 THEN @min_v5mapositiontaking_9999-@v5apositiontaking_9999 ELSE @v5mpositiontaking_9999 END,

			@v8mpositiontaking_1 = CASE WHEN @v8apositiontaking_1+@v8mpositiontaking_1<@min_v8mapositiontaking_1 THEN @min_v8mapositiontaking_1-@v8apositiontaking_1 ELSE @v8mpositiontaking_1 END,
			@v8mpositiontaking_3 = CASE WHEN @v8apositiontaking_3+@v8mpositiontaking_3<@min_v8mapositiontaking_3 THEN @min_v8mapositiontaking_3-@v8apositiontaking_3 ELSE @v8mpositiontaking_3 END,
			@v8mpositiontaking_20 = CASE WHEN @v8apositiontaking_20+@v8mpositiontaking_20<@min_v8mapositiontaking_20 THEN @min_v8mapositiontaking_20-@v8apositiontaking_20 ELSE @v8mpositiontaking_20 END,

			@v10mpositiontaking_1 = CASE WHEN @v10apositiontaking_1+@v10mpositiontaking_1<@min_v10mapositiontaking_1 THEN @min_v10mapositiontaking_1-@v10apositiontaking_1 ELSE @v10mpositiontaking_1 END,
			@v10mpositiontaking_2 = CASE WHEN @v10apositiontaking_2+@v10mpositiontaking_2<@min_v10mapositiontaking_2 THEN @min_v10mapositiontaking_2-@v10apositiontaking_2 ELSE @v10mpositiontaking_2 END,
			@v10mpositiontaking_3 = CASE WHEN @v10apositiontaking_3+@v10mpositiontaking_3<@min_v10mapositiontaking_3 THEN @min_v10mapositiontaking_3-@v10apositiontaking_3 ELSE @v10mpositiontaking_3 END,
			@v10mpositiontaking_20 = CASE WHEN @v10apositiontaking_20+@v10mpositiontaking_20<@min_v10mapositiontaking_20 THEN @min_v10mapositiontaking_20-@v10apositiontaking_20 ELSE @v10mpositiontaking_20 END,

			@v11mpositiontaking_1 = CASE WHEN @v11apositiontaking_1+@v11mpositiontaking_1<@min_v11mapositiontaking_1 THEN @min_v11mapositiontaking_1-@v11apositiontaking_1 ELSE @v11mpositiontaking_1 END,
			@v11mpositiontaking_20 = CASE WHEN @v11apositiontaking_20+@v11mpositiontaking_20<@min_v11mapositiontaking_20 THEN @min_v11mapositiontaking_20-@v11apositiontaking_20 ELSE @v11mpositiontaking_20 END,

			@v99mpositiontaking_1 = CASE WHEN @v99apositiontaking_1+@v99mpositiontaking_1<@min_v99mapositiontaking_1 THEN @min_v99mapositiontaking_1-@v99apositiontaking_1 ELSE @v99mpositiontaking_1 END,
			@v99mpositiontaking_2 = CASE WHEN @v99apositiontaking_2+@v99mpositiontaking_2<@min_v99mapositiontaking_2 THEN @min_v99mapositiontaking_2-@v99apositiontaking_2 ELSE @v99mpositiontaking_2 END,
			@v99mpositiontaking_3 = CASE WHEN @v99apositiontaking_3+@v99mpositiontaking_3<@min_v99mapositiontaking_3 THEN @min_v99mapositiontaking_3-@v99apositiontaking_3 ELSE @v99mpositiontaking_3 END,
			@v99mpositiontaking_20 = CASE WHEN @v99apositiontaking_20+@v99mpositiontaking_20<@min_v99mapositiontaking_20 THEN @min_v99mapositiontaking_20-@v99apositiontaking_20 ELSE @v99mpositiontaking_20 END,
			@v99mpositiontaking_9999 = CASE WHEN @v99apositiontaking_9999+@v99mpositiontaking_9999<@min_v99mapositiontaking_9999 THEN @min_v99mapositiontaking_9999-@v99apositiontaking_9999 ELSE @v99mpositiontaking_9999 END,
			-- mixed sports
			@v99mpositiontaking_9 = CASE WHEN @v99apositiontaking_9+@v99mpositiontaking_9<@min_v99mapositiontaking_9 THEN @min_v99mapositiontaking_9-@v99apositiontaking_9 ELSE @v99mpositiontaking_9 END

		SELECT 
			@mpositiontaking_1 = CASE WHEN @mpositiontaking_1<0 THEN 0 ELSE @mpositiontaking_1 END,
			@mpositiontaking_2 = CASE WHEN @mpositiontaking_2<0 THEN 0 ELSE @mpositiontaking_2 END,
			@mpositiontaking_3 = CASE WHEN @mpositiontaking_3<0 THEN 0 ELSE @mpositiontaking_3 END,
			@mpositiontaking_4 = CASE WHEN @mpositiontaking_4<0 THEN 0 ELSE @mpositiontaking_4 END,
			@mpositiontaking_5 = CASE WHEN @mpositiontaking_5<0 THEN 0 ELSE @mpositiontaking_5 END,
			@mpositiontaking_6 = CASE WHEN @mpositiontaking_6<0 THEN 0 ELSE @mpositiontaking_6 END,
			@mpositiontaking_7 = CASE WHEN @mpositiontaking_7<0 THEN 0 ELSE @mpositiontaking_7 END,
			@mpositiontaking_8 = CASE WHEN @mpositiontaking_8<0 THEN 0 ELSE @mpositiontaking_8 END,
			@mpositiontaking_9 = CASE WHEN @mpositiontaking_9<0 THEN 0 ELSE @mpositiontaking_9 END,
			@mpositiontaking_10 = CASE WHEN @mpositiontaking_10<0 THEN 0 ELSE @mpositiontaking_10 END,
			
			-- Outright PT for sports
			@v2mpositiontaking_10 = CASE WHEN @v2mpositiontaking_10<0 THEN 0 ELSE @v2mpositiontaking_10 END,
			@v3mpositiontaking_10 = CASE WHEN @v3mpositiontaking_10<0 THEN 0 ELSE @v3mpositiontaking_10 END,
			@v5mpositiontaking_10 = CASE WHEN @v5mpositiontaking_10<0 THEN 0 ELSE @v5mpositiontaking_10 END,
			@v8mpositiontaking_10 = CASE WHEN @v8mpositiontaking_10<0 THEN 0 ELSE @v8mpositiontaking_10 END,
			@v10mpositiontaking_10 = CASE WHEN @v10mpositiontaking_10<0 THEN 0 ELSE @v10mpositiontaking_10 END,
			@v11mpositiontaking_10 = CASE WHEN @v11mpositiontaking_10<0 THEN 0 ELSE @v11mpositiontaking_10 END,
			@v99mpositiontaking_10 = CASE WHEN @v99mpositiontaking_10<0 THEN 0 ELSE @v99mpositiontaking_10 END,
			
			@mpositiontaking_9999 = CASE WHEN @mpositiontaking_9999<0 THEN 0 ELSE @mpositiontaking_9999 END,

			@mlivepositiontaking_1 = CASE WHEN @mlivepositiontaking_1<0 THEN 0 ELSE @mlivepositiontaking_1 END,
			@mlivepositiontaking_3 = CASE WHEN @mlivepositiontaking_3<0 THEN 0 ELSE @mlivepositiontaking_3 END,
			@mlivepositiontaking_7 = CASE WHEN @mlivepositiontaking_7<0 THEN 0 ELSE @mlivepositiontaking_7 END,
			@mlivepositiontaking_8 = CASE WHEN @mlivepositiontaking_8<0 THEN 0 ELSE @mlivepositiontaking_8 END,

			@v2mpositiontaking_1 = CASE WHEN @v2mpositiontaking_1<0 THEN 0 ELSE @v2mpositiontaking_1 END,
			@v2mpositiontaking_2 = CASE WHEN @v2mpositiontaking_2<0 THEN 0 ELSE @v2mpositiontaking_2 END,
			@v2mpositiontaking_3 = CASE WHEN @v2mpositiontaking_3<0 THEN 0 ELSE @v2mpositiontaking_3 END,
			@v2mpositiontaking_7 = CASE WHEN @v2mpositiontaking_7<0 THEN 0 ELSE @v2mpositiontaking_7 END,
			@v2mpositiontaking_8 = CASE WHEN @v2mpositiontaking_8<0 THEN 0 ELSE @v2mpositiontaking_8 END,
		--	@v2mpositiontaking_9 = CASE WHEN @v2mpositiontaking_9<0 THEN 0 ELSE @v2mpositiontaking_9 END,
			@v2mpositiontaking_20 = CASE WHEN @v2mpositiontaking_20<0 THEN 0 ELSE @v2mpositiontaking_20 END,
			@v2mpositiontaking_9999 = CASE WHEN @v2mpositiontaking_9999<0 THEN 0 ELSE @v2mpositiontaking_9999 END,

			@v3mpositiontaking_1 = CASE WHEN @v3mpositiontaking_1<0 THEN 0 ELSE @v3mpositiontaking_1 END,
			@v3mpositiontaking_2 = CASE WHEN @v3mpositiontaking_2<0 THEN 0 ELSE @v3mpositiontaking_2 END,
			@v3mpositiontaking_3 = CASE WHEN @v3mpositiontaking_3<0 THEN 0 ELSE @v3mpositiontaking_3 END,
			@v3mpositiontaking_20 = CASE WHEN @v3mpositiontaking_20<0 THEN 0 ELSE @v3mpositiontaking_20 END,

			@v5mpositiontaking_1 = CASE WHEN @v5mpositiontaking_1<0 THEN 0 ELSE @v5mpositiontaking_1 END,
			@v5mpositiontaking_2 = CASE WHEN @v5mpositiontaking_2<0 THEN 0 ELSE @v5mpositiontaking_2 END,
			@v5mpositiontaking_3 = CASE WHEN @v5mpositiontaking_3<0 THEN 0 ELSE @v5mpositiontaking_3 END,
			@v5mpositiontaking_20 = CASE WHEN @v5mpositiontaking_20<0 THEN 0 ELSE @v5mpositiontaking_20 END,
			@v5mpositiontaking_9999 = CASE WHEN @v5mpositiontaking_9999<0 THEN 0 ELSE @v5mpositiontaking_9999 END,

			@v8mpositiontaking_1 = CASE WHEN @v8mpositiontaking_1<0 THEN 0 ELSE @v8mpositiontaking_1 END,
			@v8mpositiontaking_3 = CASE WHEN @v8mpositiontaking_3<0 THEN 0 ELSE @v8mpositiontaking_3 END,
			@v8mpositiontaking_20 = CASE WHEN @v8mpositiontaking_20<0 THEN 0 ELSE @v8mpositiontaking_20 END,

			@v10mpositiontaking_1 = CASE WHEN @v10mpositiontaking_1<0 THEN 0 ELSE @v10mpositiontaking_1 END,
			@v10mpositiontaking_2 = CASE WHEN @v10mpositiontaking_2<0 THEN 0 ELSE @v10mpositiontaking_2 END,
			@v10mpositiontaking_3 = CASE WHEN @v10mpositiontaking_3<0 THEN 0 ELSE @v10mpositiontaking_3 END,
			@v10mpositiontaking_20 = CASE WHEN @v10mpositiontaking_20<0 THEN 0 ELSE @v10mpositiontaking_20 END,

			@v11mpositiontaking_1 = CASE WHEN @v11mpositiontaking_1<0 THEN 0 ELSE @v11mpositiontaking_1 END,
			@v11mpositiontaking_20 = CASE WHEN @v11mpositiontaking_20<0 THEN 0 ELSE @v11mpositiontaking_20 END,

			@v99mpositiontaking_1 = CASE WHEN @v99mpositiontaking_1<0 THEN 0 ELSE @v99mpositiontaking_1 END,
			@v99mpositiontaking_2 = CASE WHEN @v99mpositiontaking_2<0 THEN 0 ELSE @v99mpositiontaking_2 END,
			@v99mpositiontaking_3 = CASE WHEN @v99mpositiontaking_3<0 THEN 0 ELSE @v99mpositiontaking_3 END,
			@v99mpositiontaking_20 = CASE WHEN @v99mpositiontaking_20<0 THEN 0 ELSE @v99mpositiontaking_20 END,
			@v99mpositiontaking_9999 = CASE WHEN @v99mpositiontaking_9999<0 THEN 0 ELSE @v99mpositiontaking_9999 END,
			-- mixed sports
			@v99mpositiontaking_9 = CASE WHEN @v99mpositiontaking_9<0 THEN 0 ELSE @v99mpositiontaking_9 END

		--Must include code for auto master
		--um=im1>0?um1:um2
		--im=im1>0?im1:im2
		--m1=im>0?min(um,m3-a1):m1
		----------------------------------------------------------------------------------------------------------------------------
		--auto master

		--um=im1>0?um1:um2
		SELECT 
			@auto_mpositiontaking_1 = CASE WHEN @isauto_mpositiontaking_mem_1>0 THEN @auto_mpositiontaking_mem_1 ELSE @auto_mpositiontaking_1 END,
			@auto_mpositiontaking_2 = CASE WHEN @isauto_mpositiontaking_mem_2>0 THEN @auto_mpositiontaking_mem_2 ELSE @auto_mpositiontaking_2 END,
			@auto_mpositiontaking_3 = CASE WHEN @isauto_mpositiontaking_mem_3>0 THEN @auto_mpositiontaking_mem_3 ELSE @auto_mpositiontaking_3 END,
			@auto_mpositiontaking_4 = CASE WHEN @isauto_mpositiontaking_mem_4>0 THEN @auto_mpositiontaking_mem_4 ELSE @auto_mpositiontaking_4 END,
			@auto_mpositiontaking_5 = CASE WHEN @isauto_mpositiontaking_mem_5>0 THEN @auto_mpositiontaking_mem_5 ELSE @auto_mpositiontaking_5 END,
			@auto_mpositiontaking_6 = CASE WHEN @isauto_mpositiontaking_mem_6>0 THEN @auto_mpositiontaking_mem_6 ELSE @auto_mpositiontaking_6 END,
			@auto_mpositiontaking_7 = CASE WHEN @isauto_mpositiontaking_mem_7>0 THEN @auto_mpositiontaking_mem_7 ELSE @auto_mpositiontaking_7 END,
			@auto_mpositiontaking_8 = CASE WHEN @isauto_mpositiontaking_mem_8>0 THEN @auto_mpositiontaking_mem_8 ELSE @auto_mpositiontaking_8 END,
			@auto_mpositiontaking_9 = CASE WHEN @isauto_mpositiontaking_mem_9>0 THEN @auto_mpositiontaking_mem_9 ELSE @auto_mpositiontaking_9 END,
			@auto_mpositiontaking_10 = CASE WHEN @isauto_mpositiontaking_mem_10>0 THEN @auto_mpositiontaking_mem_10 ELSE @auto_mpositiontaking_10 END,
			
			-- Outright PT for sports
			@auto_v2mpositiontaking_10 = CASE WHEN @isauto_v2mpositiontaking_mem_10>0 THEN @auto_v2mpositiontaking_mem_10 ELSE @auto_v2mpositiontaking_10 END,
			@auto_v3mpositiontaking_10 = CASE WHEN @isauto_v3mpositiontaking_mem_10>0 THEN @auto_v3mpositiontaking_mem_10 ELSE @auto_v3mpositiontaking_10 END,
			@auto_v5mpositiontaking_10 = CASE WHEN @isauto_v5mpositiontaking_mem_10>0 THEN @auto_v5mpositiontaking_mem_10 ELSE @auto_v5mpositiontaking_10 END,
			@auto_v8mpositiontaking_10 = CASE WHEN @isauto_v8mpositiontaking_mem_10>0 THEN @auto_v8mpositiontaking_mem_10 ELSE @auto_v8mpositiontaking_10 END,
			@auto_v10mpositiontaking_10 = CASE WHEN @isauto_v10mpositiontaking_mem_10>0 THEN @auto_v10mpositiontaking_mem_10 ELSE @auto_v10mpositiontaking_10 END,
			@auto_v11mpositiontaking_10 = CASE WHEN @isauto_v11mpositiontaking_mem_10>0 THEN @auto_v11mpositiontaking_mem_10 ELSE @auto_v11mpositiontaking_10 END,
			@auto_v99mpositiontaking_10 = CASE WHEN @isauto_v99mpositiontaking_mem_10>0 THEN @auto_v99mpositiontaking_mem_10 ELSE @auto_v99mpositiontaking_10 END,
			
			
			@auto_mpositiontaking_9999 = CASE WHEN @isauto_mpositiontaking_mem_9999>0 THEN @auto_mpositiontaking_mem_9999 ELSE @auto_mpositiontaking_9999 END,

			@auto_mlivepositiontaking_1 = CASE WHEN @isauto_mlivepositiontaking_mem_1>0 THEN @auto_mlivepositiontaking_mem_1 ELSE @auto_mlivepositiontaking_1 END,
			@auto_mlivepositiontaking_3 = CASE WHEN @isauto_mlivepositiontaking_mem_3>0 THEN @auto_mlivepositiontaking_mem_3 ELSE @auto_mlivepositiontaking_3 END,
			@auto_mlivepositiontaking_7 = CASE WHEN @isauto_mlivepositiontaking_mem_7>0 THEN @auto_mlivepositiontaking_mem_7 ELSE @auto_mlivepositiontaking_7 END,
			@auto_mlivepositiontaking_8 = CASE WHEN @isauto_mlivepositiontaking_mem_8>0 THEN @auto_mlivepositiontaking_mem_8 ELSE @auto_mlivepositiontaking_8 END,

			@auto_v2mpositiontaking_1 = CASE WHEN @isauto_v2mpositiontaking_mem_1>0 THEN @auto_v2mpositiontaking_mem_1 ELSE @auto_v2mpositiontaking_1 END,
			@auto_v2mpositiontaking_2 = CASE WHEN @isauto_v2mpositiontaking_mem_2>0 THEN @auto_v2mpositiontaking_mem_2 ELSE @auto_v2mpositiontaking_2 END,
			@auto_v2mpositiontaking_3 = CASE WHEN @isauto_v2mpositiontaking_mem_3>0 THEN @auto_v2mpositiontaking_mem_3 ELSE @auto_v2mpositiontaking_3 END,
			@auto_v2mpositiontaking_7 = CASE WHEN @isauto_v2mpositiontaking_mem_7>0 THEN @auto_v2mpositiontaking_mem_7 ELSE @auto_v2mpositiontaking_7 END,
			@auto_v2mpositiontaking_8 = CASE WHEN @isauto_v2mpositiontaking_mem_8>0 THEN @auto_v2mpositiontaking_mem_8 ELSE @auto_v2mpositiontaking_8 END,
		--	@auto_v2mpositiontaking_9 = CASE WHEN @isauto_v2mpositiontaking_mem_9>0 THEN @auto_v2mpositiontaking_mem_9 ELSE @auto_v2mpositiontaking_9 END,
			@auto_v2mpositiontaking_20 = CASE WHEN @isauto_v2mpositiontaking_mem_20>0 THEN @auto_v2mpositiontaking_mem_20 ELSE @auto_v2mpositiontaking_20 END,
			@auto_v2mpositiontaking_9999 = CASE WHEN @isauto_v2mpositiontaking_mem_9999>0 THEN @auto_v2mpositiontaking_mem_9999 ELSE @auto_v2mpositiontaking_9999 END,

			@auto_v3mpositiontaking_1 = CASE WHEN @isauto_v3mpositiontaking_mem_1>0 THEN @auto_v3mpositiontaking_mem_1 ELSE @auto_v3mpositiontaking_1 END,
			@auto_v3mpositiontaking_2 = CASE WHEN @isauto_v3mpositiontaking_mem_2>0 THEN @auto_v3mpositiontaking_mem_2 ELSE @auto_v3mpositiontaking_2 END,
			@auto_v3mpositiontaking_3 = CASE WHEN @isauto_v3mpositiontaking_mem_3>0 THEN @auto_v3mpositiontaking_mem_3 ELSE @auto_v3mpositiontaking_3 END,
			@auto_v3mpositiontaking_20 = CASE WHEN @isauto_v3mpositiontaking_mem_20>0 THEN @auto_v3mpositiontaking_mem_20 ELSE @auto_v3mpositiontaking_20 END,

			@auto_v5mpositiontaking_1 = CASE WHEN @isauto_v5mpositiontaking_mem_1>0 THEN @auto_v5mpositiontaking_mem_1 ELSE @auto_v5mpositiontaking_1 END,
			@auto_v5mpositiontaking_2 = CASE WHEN @isauto_v5mpositiontaking_mem_2>0 THEN @auto_v5mpositiontaking_mem_2 ELSE @auto_v5mpositiontaking_2 END,
			@auto_v5mpositiontaking_3 = CASE WHEN @isauto_v5mpositiontaking_mem_3>0 THEN @auto_v5mpositiontaking_mem_3 ELSE @auto_v5mpositiontaking_3 END,
			@auto_v5mpositiontaking_20 = CASE WHEN @isauto_v5mpositiontaking_mem_20>0 THEN @auto_v5mpositiontaking_mem_20 ELSE @auto_v5mpositiontaking_20 END,
			@auto_v5mpositiontaking_9999 = CASE WHEN @isauto_v5mpositiontaking_mem_9999>0 THEN @auto_v5mpositiontaking_mem_9999 ELSE @auto_v5mpositiontaking_9999 END,

			@auto_v8mpositiontaking_1 = CASE WHEN @isauto_v8mpositiontaking_mem_1>0 THEN @auto_v8mpositiontaking_mem_1 ELSE @auto_v8mpositiontaking_1 END,
			@auto_v8mpositiontaking_3 = CASE WHEN @isauto_v8mpositiontaking_mem_3>0 THEN @auto_v8mpositiontaking_mem_3 ELSE @auto_v8mpositiontaking_3 END,
			@auto_v8mpositiontaking_20 = CASE WHEN @isauto_v8mpositiontaking_mem_20>0 THEN @auto_v8mpositiontaking_mem_20 ELSE @auto_v8mpositiontaking_20 END,

			@auto_v10mpositiontaking_1 = CASE WHEN @isauto_v10mpositiontaking_mem_1>0 THEN @auto_v10mpositiontaking_mem_1 ELSE @auto_v10mpositiontaking_1 END,
			@auto_v10mpositiontaking_2 = CASE WHEN @isauto_v10mpositiontaking_mem_2>0 THEN @auto_v10mpositiontaking_mem_2 ELSE @auto_v10mpositiontaking_2 END,
			@auto_v10mpositiontaking_3 = CASE WHEN @isauto_v10mpositiontaking_mem_3>0 THEN @auto_v10mpositiontaking_mem_3 ELSE @auto_v10mpositiontaking_3 END,
			@auto_v10mpositiontaking_20 = CASE WHEN @isauto_v10mpositiontaking_mem_20>0 THEN @auto_v10mpositiontaking_mem_20 ELSE @auto_v10mpositiontaking_20 END,

			@auto_v11mpositiontaking_1 = CASE WHEN @isauto_v11mpositiontaking_mem_1>0 THEN @auto_v11mpositiontaking_mem_1 ELSE @auto_v11mpositiontaking_1 END,
			@auto_v11mpositiontaking_20 = CASE WHEN @isauto_v11mpositiontaking_mem_20>0 THEN @auto_v11mpositiontaking_mem_20 ELSE @auto_v11mpositiontaking_20 END,

			@auto_v99mpositiontaking_1 = CASE WHEN @isauto_v99mpositiontaking_mem_1>0 THEN @auto_v99mpositiontaking_mem_1 ELSE @auto_v99mpositiontaking_1 END,
			@auto_v99mpositiontaking_2 = CASE WHEN @isauto_v99mpositiontaking_mem_2>0 THEN @auto_v99mpositiontaking_mem_2 ELSE @auto_v99mpositiontaking_2 END,
			@auto_v99mpositiontaking_3 = CASE WHEN @isauto_v99mpositiontaking_mem_3>0 THEN @auto_v99mpositiontaking_mem_3 ELSE @auto_v99mpositiontaking_3 END,
			@auto_v99mpositiontaking_20 = CASE WHEN @isauto_v99mpositiontaking_mem_20>0 THEN @auto_v99mpositiontaking_mem_20 ELSE @auto_v99mpositiontaking_20 END,
			@auto_v99mpositiontaking_9999 = CASE WHEN @isauto_v99mpositiontaking_mem_9999>0 THEN @auto_v99mpositiontaking_mem_9999 ELSE @auto_v99mpositiontaking_9999 END,
			-- mixed sports
			@auto_v99mpositiontaking_9 = CASE WHEN @isauto_v99mpositiontaking_mem_9>0 THEN @auto_v99mpositiontaking_mem_9 ELSE @auto_v99mpositiontaking_9 END,

			--im=im1>0?im1:im2
			@isauto_mpositiontaking_1 = CASE WHEN @isauto_mpositiontaking_mem_1>0 THEN @isauto_mpositiontaking_mem_1 ELSE @isauto_mpositiontaking_1 END,
			@isauto_mpositiontaking_2 = CASE WHEN @isauto_mpositiontaking_mem_2>0 THEN @isauto_mpositiontaking_mem_2 ELSE @isauto_mpositiontaking_2 END,
			@isauto_mpositiontaking_3 = CASE WHEN @isauto_mpositiontaking_mem_3>0 THEN @isauto_mpositiontaking_mem_3 ELSE @isauto_mpositiontaking_3 END,
			@isauto_mpositiontaking_4 = CASE WHEN @isauto_mpositiontaking_mem_4>0 THEN @isauto_mpositiontaking_mem_4 ELSE @isauto_mpositiontaking_4 END,
			@isauto_mpositiontaking_5 = CASE WHEN @isauto_mpositiontaking_mem_5>0 THEN @isauto_mpositiontaking_mem_5 ELSE @isauto_mpositiontaking_5 END,
			@isauto_mpositiontaking_6 = CASE WHEN @isauto_mpositiontaking_mem_6>0 THEN @isauto_mpositiontaking_mem_6 ELSE @isauto_mpositiontaking_6 END,
			@isauto_mpositiontaking_7 = CASE WHEN @isauto_mpositiontaking_mem_7>0 THEN @isauto_mpositiontaking_mem_7 ELSE @isauto_mpositiontaking_7 END,
			@isauto_mpositiontaking_8 = CASE WHEN @isauto_mpositiontaking_mem_8>0 THEN @isauto_mpositiontaking_mem_8 ELSE @isauto_mpositiontaking_8 END,
			@isauto_mpositiontaking_9 = CASE WHEN @isauto_mpositiontaking_mem_9>0 THEN @isauto_mpositiontaking_mem_9 ELSE @isauto_mpositiontaking_9 END,
			@isauto_mpositiontaking_10 = CASE WHEN @isauto_mpositiontaking_mem_10>0 THEN @isauto_mpositiontaking_mem_10 ELSE @isauto_mpositiontaking_10 END,
			
			-- Outright PT for sports
			@isauto_v2mpositiontaking_10 = CASE WHEN @isauto_v2mpositiontaking_mem_10>0 THEN @isauto_v2mpositiontaking_mem_10 ELSE @isauto_v2mpositiontaking_10 END,
			@isauto_v3mpositiontaking_10 = CASE WHEN @isauto_v3mpositiontaking_mem_10>0 THEN @isauto_v3mpositiontaking_mem_10 ELSE @isauto_v3mpositiontaking_10 END,
			@isauto_v5mpositiontaking_10 = CASE WHEN @isauto_v5mpositiontaking_mem_10>0 THEN @isauto_v5mpositiontaking_mem_10 ELSE @isauto_v5mpositiontaking_10 END,
			@isauto_v8mpositiontaking_10 = CASE WHEN @isauto_v8mpositiontaking_mem_10>0 THEN @isauto_v8mpositiontaking_mem_10 ELSE @isauto_v8mpositiontaking_10 END,
			@isauto_v10mpositiontaking_10 = CASE WHEN @isauto_v10mpositiontaking_mem_10>0 THEN @isauto_v10mpositiontaking_mem_10 ELSE @isauto_v10mpositiontaking_10 END,
			@isauto_v11mpositiontaking_10 = CASE WHEN @isauto_v11mpositiontaking_mem_10>0 THEN @isauto_v11mpositiontaking_mem_10 ELSE @isauto_v11mpositiontaking_10 END,
			@isauto_v99mpositiontaking_10 = CASE WHEN @isauto_v99mpositiontaking_mem_10>0 THEN @isauto_v99mpositiontaking_mem_10 ELSE @isauto_v99mpositiontaking_10 END,
			
			@isauto_mpositiontaking_9999 = CASE WHEN @isauto_mpositiontaking_mem_9999>0 THEN @isauto_mpositiontaking_mem_9999 ELSE @isauto_mpositiontaking_9999 END,

			@isauto_mlivepositiontaking_1 = CASE WHEN @isauto_mlivepositiontaking_mem_1>0 THEN @isauto_mlivepositiontaking_mem_1 ELSE @isauto_mlivepositiontaking_1 END,
			@isauto_mlivepositiontaking_3 = CASE WHEN @isauto_mlivepositiontaking_mem_3>0 THEN @isauto_mlivepositiontaking_mem_3 ELSE @isauto_mlivepositiontaking_3 END,
			@isauto_mlivepositiontaking_7 = CASE WHEN @isauto_mlivepositiontaking_mem_7>0 THEN @isauto_mlivepositiontaking_mem_7 ELSE @isauto_mlivepositiontaking_7 END,
			@isauto_mlivepositiontaking_8 = CASE WHEN @isauto_mlivepositiontaking_mem_8>0 THEN @isauto_mlivepositiontaking_mem_8 ELSE @isauto_mlivepositiontaking_8 END,

			@isauto_v2mpositiontaking_1 = CASE WHEN @isauto_v2mpositiontaking_mem_1>0 THEN @isauto_v2mpositiontaking_mem_1 ELSE @isauto_v2mpositiontaking_1 END,
			@isauto_v2mpositiontaking_2 = CASE WHEN @isauto_v2mpositiontaking_mem_2>0 THEN @isauto_v2mpositiontaking_mem_2 ELSE @isauto_v2mpositiontaking_2 END,
			@isauto_v2mpositiontaking_3 = CASE WHEN @isauto_v2mpositiontaking_mem_3>0 THEN @isauto_v2mpositiontaking_mem_3 ELSE @isauto_v2mpositiontaking_3 END,
			@isauto_v2mpositiontaking_7 = CASE WHEN @isauto_v2mpositiontaking_mem_7>0 THEN @isauto_v2mpositiontaking_mem_7 ELSE @isauto_v2mpositiontaking_7 END,
			@isauto_v2mpositiontaking_8 = CASE WHEN @isauto_v2mpositiontaking_mem_8>0 THEN @isauto_v2mpositiontaking_mem_8 ELSE @isauto_v2mpositiontaking_8 END,
		--	@isauto_v2mpositiontaking_9 = CASE WHEN @isauto_v2mpositiontaking_mem_9>0 THEN @isauto_v2mpositiontaking_mem_9 ELSE @isauto_v2mpositiontaking_9 END,
			@isauto_v2mpositiontaking_20 = CASE WHEN @isauto_v2mpositiontaking_mem_20>0 THEN @isauto_v2mpositiontaking_mem_20 ELSE @isauto_v2mpositiontaking_20 END,
			@isauto_v2mpositiontaking_9999 = CASE WHEN @isauto_v2mpositiontaking_mem_9999>0 THEN @isauto_v2mpositiontaking_mem_9999 ELSE @isauto_v2mpositiontaking_9999 END,

			@isauto_v3mpositiontaking_1 = CASE WHEN @isauto_v3mpositiontaking_mem_1>0 THEN @isauto_v3mpositiontaking_mem_1 ELSE @isauto_v3mpositiontaking_1 END,
			@isauto_v3mpositiontaking_2 = CASE WHEN @isauto_v3mpositiontaking_mem_2>0 THEN @isauto_v3mpositiontaking_mem_2 ELSE @isauto_v3mpositiontaking_2 END,
			@isauto_v3mpositiontaking_3 = CASE WHEN @isauto_v3mpositiontaking_mem_3>0 THEN @isauto_v3mpositiontaking_mem_3 ELSE @isauto_v3mpositiontaking_3 END,
			@isauto_v3mpositiontaking_20 = CASE WHEN @isauto_v3mpositiontaking_mem_20>0 THEN @isauto_v3mpositiontaking_mem_20 ELSE @isauto_v3mpositiontaking_20 END,

			@isauto_v5mpositiontaking_1 = CASE WHEN @isauto_v5mpositiontaking_mem_1>0 THEN @isauto_v5mpositiontaking_mem_1 ELSE @isauto_v5mpositiontaking_1 END,
			@isauto_v5mpositiontaking_2 = CASE WHEN @isauto_v5mpositiontaking_mem_2>0 THEN @isauto_v5mpositiontaking_mem_2 ELSE @isauto_v5mpositiontaking_2 END,
			@isauto_v5mpositiontaking_3 = CASE WHEN @isauto_v5mpositiontaking_mem_3>0 THEN @isauto_v5mpositiontaking_mem_3 ELSE @isauto_v5mpositiontaking_3 END,
			@isauto_v5mpositiontaking_20 = CASE WHEN @isauto_v5mpositiontaking_mem_20>0 THEN @isauto_v5mpositiontaking_mem_20 ELSE @isauto_v5mpositiontaking_20 END,
			@isauto_v5mpositiontaking_9999 = CASE WHEN @isauto_v5mpositiontaking_mem_9999>0 THEN @isauto_v5mpositiontaking_mem_9999 ELSE @isauto_v5mpositiontaking_9999 END,

			@isauto_v8mpositiontaking_1 = CASE WHEN @isauto_v8mpositiontaking_mem_1>0 THEN @isauto_v8mpositiontaking_mem_1 ELSE @isauto_v8mpositiontaking_1 END,
			@isauto_v8mpositiontaking_3 = CASE WHEN @isauto_v8mpositiontaking_mem_3>0 THEN @isauto_v8mpositiontaking_mem_3 ELSE @isauto_v8mpositiontaking_3 END,
			@isauto_v8mpositiontaking_20 = CASE WHEN @isauto_v8mpositiontaking_mem_20>0 THEN @isauto_v8mpositiontaking_mem_20 ELSE @isauto_v8mpositiontaking_20 END,

			@isauto_v10mpositiontaking_1 = CASE WHEN @isauto_v10mpositiontaking_mem_1>0 THEN @isauto_v10mpositiontaking_mem_1 ELSE @isauto_v10mpositiontaking_1 END,
			@isauto_v10mpositiontaking_2 = CASE WHEN @isauto_v10mpositiontaking_mem_2>0 THEN @isauto_v10mpositiontaking_mem_2 ELSE @isauto_v10mpositiontaking_2 END,
			@isauto_v10mpositiontaking_3 = CASE WHEN @isauto_v10mpositiontaking_mem_3>0 THEN @isauto_v10mpositiontaking_mem_3 ELSE @isauto_v10mpositiontaking_3 END,
			@isauto_v10mpositiontaking_20 = CASE WHEN @isauto_v10mpositiontaking_mem_20>0 THEN @isauto_v10mpositiontaking_mem_20 ELSE @isauto_v10mpositiontaking_20 END,

			@isauto_v11mpositiontaking_1 = CASE WHEN @isauto_v11mpositiontaking_mem_1>0 THEN @isauto_v11mpositiontaking_mem_1 ELSE @isauto_v11mpositiontaking_1 END,
			@isauto_v11mpositiontaking_20 = CASE WHEN @isauto_v11mpositiontaking_mem_20>0 THEN @isauto_v11mpositiontaking_mem_20 ELSE @isauto_v11mpositiontaking_20 END,

			@isauto_v99mpositiontaking_1 = CASE WHEN @isauto_v99mpositiontaking_mem_1>0 THEN @isauto_v99mpositiontaking_mem_1 ELSE @isauto_v99mpositiontaking_1 END,
			@isauto_v99mpositiontaking_2 = CASE WHEN @isauto_v99mpositiontaking_mem_2>0 THEN @isauto_v99mpositiontaking_mem_2 ELSE @isauto_v99mpositiontaking_2 END,
			@isauto_v99mpositiontaking_3 = CASE WHEN @isauto_v99mpositiontaking_mem_3>0 THEN @isauto_v99mpositiontaking_mem_3 ELSE @isauto_v99mpositiontaking_3 END,
			@isauto_v99mpositiontaking_20 = CASE WHEN @isauto_v99mpositiontaking_mem_20>0 THEN @isauto_v99mpositiontaking_mem_20 ELSE @isauto_v99mpositiontaking_20 END,
			@isauto_v99mpositiontaking_9999 = CASE WHEN @isauto_v99mpositiontaking_mem_9999>0 THEN @isauto_v99mpositiontaking_mem_9999 ELSE @isauto_v99mpositiontaking_9999 END,
			-- mixed sports
			@isauto_v99mpositiontaking_9 = CASE WHEN @isauto_v99mpositiontaking_mem_9>0 THEN @isauto_v99mpositiontaking_mem_9 ELSE @isauto_v99mpositiontaking_9 END

		----------------***Use Auto Position Taking***----------------------------------
		--m1=im>0?min(um,m3-a1):m1
		SELECT @mpositiontaking_1 = CASE WHEN ISNULL(@isauto_mpositiontaking_1, 0)<=0 THEN @mpositiontaking_1 ELSE CASE WHEN @auto_mpositiontaking_1 < @max_mapositiontaking_1 - @apositiontaking_1 THEN @auto_mpositiontaking_1 ELSE @max_mapositiontaking_1 - @apositiontaking_1 END END
		SELECT @mpositiontaking_3 = CASE WHEN ISNULL(@isauto_mpositiontaking_3, 0)<=0 THEN @mpositiontaking_3 ELSE CASE WHEN @auto_mpositiontaking_3 < @max_mapositiontaking_3 - @apositiontaking_3 THEN @auto_mpositiontaking_3 ELSE @max_mapositiontaking_3 - @apositiontaking_3 END END
		SELECT @mpositiontaking_7 = CASE WHEN ISNULL(@isauto_mpositiontaking_7, 0)<=0 THEN @mpositiontaking_7 ELSE CASE WHEN @auto_mpositiontaking_7 < @max_mapositiontaking_7 - @apositiontaking_7 THEN @auto_mpositiontaking_7 ELSE @max_mapositiontaking_7 - @apositiontaking_7 END END
		SELECT @mpositiontaking_8 = CASE WHEN ISNULL(@isauto_mpositiontaking_8, 0)<=0 THEN @mpositiontaking_8 ELSE CASE WHEN @auto_mpositiontaking_8 < @max_mapositiontaking_8 - @apositiontaking_8 THEN @auto_mpositiontaking_8 ELSE @max_mapositiontaking_8 - @apositiontaking_8 END END

		SELECT @mlivepositiontaking_1 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_1, 0)<=0 THEN @mlivepositiontaking_1 ELSE CASE WHEN @auto_mlivepositiontaking_1 < @max_malivepositiontaking_1 - @alivepositiontaking_1 THEN @auto_mlivepositiontaking_1 ELSE @max_malivepositiontaking_1 - @alivepositiontaking_1 END END
		SELECT @mlivepositiontaking_3 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_3, 0)<=0 THEN @mlivepositiontaking_3 ELSE CASE WHEN @auto_mlivepositiontaking_3 < @max_malivepositiontaking_3 - @alivepositiontaking_3 THEN @auto_mlivepositiontaking_3 ELSE @max_malivepositiontaking_3 - @alivepositiontaking_3 END END
		SELECT @mlivepositiontaking_7 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_7, 0)<=0 THEN @mlivepositiontaking_7 ELSE CASE WHEN @auto_mlivepositiontaking_7 < @max_malivepositiontaking_7 - @alivepositiontaking_7 THEN @auto_mlivepositiontaking_7 ELSE @max_malivepositiontaking_7 - @alivepositiontaking_7 END END
		SELECT @mlivepositiontaking_8 = CASE WHEN ISNULL(@isauto_mlivepositiontaking_8, 0)<=0 THEN @mlivepositiontaking_8 ELSE CASE WHEN @auto_mlivepositiontaking_8 < @max_malivepositiontaking_8 - @alivepositiontaking_8 THEN @auto_mlivepositiontaking_8 ELSE @max_malivepositiontaking_8 - @alivepositiontaking_8 END END

		SELECT @mpositiontaking_2 = CASE WHEN ISNULL(@isauto_mpositiontaking_2, 0)<=0 THEN @mpositiontaking_2 ELSE CASE WHEN @auto_mpositiontaking_2 < @max_mapositiontaking_2 - @apositiontaking_2 THEN @auto_mpositiontaking_2 ELSE @max_mapositiontaking_2 - @apositiontaking_2 END END
		SELECT @mpositiontaking_4 = CASE WHEN ISNULL(@isauto_mpositiontaking_4, 0)<=0 THEN @mpositiontaking_4 ELSE CASE WHEN @auto_mpositiontaking_4 < @max_mapositiontaking_4 - @apositiontaking_4 THEN @auto_mpositiontaking_4 ELSE @max_mapositiontaking_4 - @apositiontaking_4 END END
		SELECT @mpositiontaking_5 = CASE WHEN ISNULL(@isauto_mpositiontaking_5, 0)<=0 THEN @mpositiontaking_5 ELSE CASE WHEN @auto_mpositiontaking_5 < @max_mapositiontaking_5 - @apositiontaking_5 THEN @auto_mpositiontaking_5 ELSE @max_mapositiontaking_5 - @apositiontaking_5 END END
		SELECT @mpositiontaking_6 = CASE WHEN ISNULL(@isauto_mpositiontaking_6, 0)<=0 THEN @mpositiontaking_6 ELSE CASE WHEN @auto_mpositiontaking_6 < @max_mapositiontaking_6 - @apositiontaking_6 THEN @auto_mpositiontaking_6 ELSE @max_mapositiontaking_6 - @apositiontaking_6 END END
		SELECT @mpositiontaking_9 = CASE WHEN ISNULL(@isauto_mpositiontaking_9, 0)<=0 THEN @mpositiontaking_9 ELSE CASE WHEN @auto_mpositiontaking_9 < @max_mapositiontaking_9 - @apositiontaking_9 THEN @auto_mpositiontaking_9 ELSE @max_mapositiontaking_9 - @apositiontaking_9 END END
		SELECT @mpositiontaking_10 = CASE WHEN ISNULL(@isauto_mpositiontaking_10, 0)<=0 THEN @mpositiontaking_10 ELSE CASE WHEN @auto_mpositiontaking_10 < @max_mapositiontaking_10 - @apositiontaking_10 THEN @auto_mpositiontaking_10 ELSE @max_mapositiontaking_10 - @apositiontaking_10 END END
		
		-- Outright PT for sports
		SELECT @v2mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_10, 0)<=0 THEN @v2mpositiontaking_10 ELSE CASE WHEN @auto_v2mpositiontaking_10 < @max_v2mapositiontaking_10 - @v2apositiontaking_10 THEN @auto_v2mpositiontaking_10 ELSE @max_v2mapositiontaking_10 - @v2apositiontaking_10 END END
		SELECT @v3mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_10, 0)<=0 THEN @v3mpositiontaking_10 ELSE CASE WHEN @auto_v3mpositiontaking_10 < @max_v3mapositiontaking_10 - @v3apositiontaking_10 THEN @auto_v3mpositiontaking_10 ELSE @max_v3mapositiontaking_10 - @v3apositiontaking_10 END END
		SELECT @v5mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_10, 0)<=0 THEN @v5mpositiontaking_10 ELSE CASE WHEN @auto_v5mpositiontaking_10 < @max_v5mapositiontaking_10 - @v5apositiontaking_10 THEN @auto_v5mpositiontaking_10 ELSE @max_v5mapositiontaking_10 - @v5apositiontaking_10 END END
		SELECT @v8mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_10, 0)<=0 THEN @v8mpositiontaking_10 ELSE CASE WHEN @auto_v8mpositiontaking_10 < @max_v8mapositiontaking_10 - @v8apositiontaking_10 THEN @auto_v8mpositiontaking_10 ELSE @max_v8mapositiontaking_10 - @v8apositiontaking_10 END END
		SELECT @v10mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_10, 0)<=0 THEN @v10mpositiontaking_10 ELSE CASE WHEN @auto_v10mpositiontaking_10 < @max_v10mapositiontaking_10 - @v10apositiontaking_10 THEN @auto_v10mpositiontaking_10 ELSE @max_v10mapositiontaking_10 - @v10apositiontaking_10 END END
		SELECT @v11mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v11mpositiontaking_10, 0)<=0 THEN @v11mpositiontaking_10 ELSE CASE WHEN @auto_v11mpositiontaking_10 < @max_v11mapositiontaking_10 - @v11apositiontaking_10 THEN @auto_v11mpositiontaking_10 ELSE @max_v11mapositiontaking_10 - @v11apositiontaking_10 END END
		SELECT @v99mpositiontaking_10 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_10, 0)<=0 THEN @v99mpositiontaking_10 ELSE CASE WHEN @auto_v99mpositiontaking_10 < @max_v99mapositiontaking_10 - @v99apositiontaking_10 THEN @auto_v99mpositiontaking_10 ELSE @max_v99mapositiontaking_10 - @v99apositiontaking_10 END END
		
		SELECT @mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_mpositiontaking_9999, 0)<=0 THEN @mpositiontaking_9999 ELSE CASE WHEN @auto_mpositiontaking_9999 < @max_mapositiontaking_9999 - @apositiontaking_9999 THEN @auto_mpositiontaking_9999 ELSE @max_mapositiontaking_9999 - @apositiontaking_9999 END END

		SELECT @v2mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_1, 0)<=0 THEN @v2mpositiontaking_1 ELSE CASE WHEN @auto_v2mpositiontaking_1 < @max_v2mapositiontaking_1 - @v2apositiontaking_1 THEN @auto_v2mpositiontaking_1 ELSE @max_v2mapositiontaking_1 - @v2apositiontaking_1 END END
		SELECT @v2mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_2, 0)<=0 THEN @v2mpositiontaking_2 ELSE CASE WHEN @auto_v2mpositiontaking_2 < @max_v2mapositiontaking_2 - @v2apositiontaking_2 THEN @auto_v2mpositiontaking_2 ELSE @max_v2mapositiontaking_2 - @v2apositiontaking_2 END END
		SELECT @v2mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_3, 0)<=0 THEN @v2mpositiontaking_3 ELSE CASE WHEN @auto_v2mpositiontaking_3 < @max_v2mapositiontaking_3 - @v2apositiontaking_3 THEN @auto_v2mpositiontaking_3 ELSE @max_v2mapositiontaking_3 - @v2apositiontaking_3 END END
		SELECT @v2mpositiontaking_7 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_7, 0)<=0 THEN @v2mpositiontaking_7 ELSE CASE WHEN @auto_v2mpositiontaking_7 < @max_v2mapositiontaking_7 - @v2apositiontaking_7 THEN @auto_v2mpositiontaking_7 ELSE @max_v2mapositiontaking_7 - @v2apositiontaking_7 END END
		SELECT @v2mpositiontaking_8 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_8, 0)<=0 THEN @v2mpositiontaking_8 ELSE CASE WHEN @auto_v2mpositiontaking_8 < @max_v2mapositiontaking_8 - @v2apositiontaking_8 THEN @auto_v2mpositiontaking_8 ELSE @max_v2mapositiontaking_8 - @v2apositiontaking_8 END END
		--SELECT @v2mpositiontaking_9 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_9, 0)<=0 THEN @v2mpositiontaking_9 ELSE CASE WHEN @auto_v2mpositiontaking_9 < @max_v2mapositiontaking_9 - @v2apositiontaking_9 THEN @auto_v2mpositiontaking_9 ELSE @max_v2mapositiontaking_9 - @v2apositiontaking_9 END END
		SELECT @v2mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_20, 0)<=0 THEN @v2mpositiontaking_20 ELSE CASE WHEN @auto_v2mpositiontaking_20 < @max_v2mapositiontaking_20 - @v2apositiontaking_20 THEN @auto_v2mpositiontaking_20 ELSE @max_v2mapositiontaking_20 - @v2apositiontaking_20 END END
		SELECT @v2mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_v2mpositiontaking_9999, 0)<=0 THEN @v2mpositiontaking_9999 ELSE CASE WHEN @auto_v2mpositiontaking_9999 < @max_v2mapositiontaking_9999 - @v2apositiontaking_9999 THEN @auto_v2mpositiontaking_9999 ELSE @max_v2mapositiontaking_9999 - @v2apositiontaking_9999 END END

		SELECT @v3mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_1, 0)<=0 THEN @v3mpositiontaking_1 ELSE CASE WHEN @auto_v3mpositiontaking_1 < @max_v3mapositiontaking_1 - @v3apositiontaking_1 THEN @auto_v3mpositiontaking_1 ELSE @max_v3mapositiontaking_1 - @v3apositiontaking_1 END END
		SELECT @v3mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_2, 0)<=0 THEN @v3mpositiontaking_2 ELSE CASE WHEN @auto_v3mpositiontaking_2 < @max_v3mapositiontaking_2 - @v3apositiontaking_2 THEN @auto_v3mpositiontaking_2 ELSE @max_v3mapositiontaking_2 - @v3apositiontaking_2 END END
		SELECT @v3mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_3, 0)<=0 THEN @v3mpositiontaking_3 ELSE CASE WHEN @auto_v3mpositiontaking_3 < @max_v3mapositiontaking_3 - @v3apositiontaking_3 THEN @auto_v3mpositiontaking_3 ELSE @max_v3mapositiontaking_3 - @v3apositiontaking_3 END END
		SELECT @v3mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v3mpositiontaking_20, 0)<=0 THEN @v3mpositiontaking_20 ELSE CASE WHEN @auto_v3mpositiontaking_20 < @max_v3mapositiontaking_20 - @v3apositiontaking_20 THEN @auto_v3mpositiontaking_20 ELSE @max_v3mapositiontaking_20 -  @v3apositiontaking_20 END END

		SELECT @v5mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_1, 0)<=0 THEN @v5mpositiontaking_1 ELSE CASE WHEN @auto_v5mpositiontaking_1 < @max_v5mapositiontaking_1 - @v5apositiontaking_1 THEN @auto_v5mpositiontaking_1 ELSE @max_v5mapositiontaking_1 - @v5apositiontaking_1 END END
		SELECT @v5mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_2, 0)<=0 THEN @v5mpositiontaking_2 ELSE CASE WHEN @auto_v5mpositiontaking_2 < @max_v5mapositiontaking_2 - @v5apositiontaking_2 THEN @auto_v5mpositiontaking_2 ELSE @max_v5mapositiontaking_2 - @v5apositiontaking_2 END END
		SELECT @v5mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_3, 0)<=0 THEN @v5mpositiontaking_3 ELSE CASE WHEN @auto_v5mpositiontaking_3 < @max_v5mapositiontaking_3 - @v5apositiontaking_3 THEN @auto_v5mpositiontaking_3 ELSE @max_v5mapositiontaking_3 - @v5apositiontaking_3 END END
		SELECT @v5mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_20, 0)<=0 THEN @v5mpositiontaking_20 ELSE CASE WHEN @auto_v5mpositiontaking_20 < @max_v5mapositiontaking_20 - @v5apositiontaking_20 THEN @auto_v5mpositiontaking_20 ELSE @max_v5mapositiontaking_20 - @v5apositiontaking_20 END END
		SELECT @v5mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_v5mpositiontaking_9999, 0)<=0 THEN @v5mpositiontaking_9999 ELSE CASE WHEN @auto_v5mpositiontaking_9999 < @max_v5mapositiontaking_9999 - @v5apositiontaking_9999 THEN @auto_v5mpositiontaking_9999 ELSE @max_v5mapositiontaking_9999 - @v5apositiontaking_9999 END END

		SELECT @v8mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_1, 0)<=0 THEN @v8mpositiontaking_1 ELSE CASE WHEN @auto_v8mpositiontaking_1 < @max_v8mapositiontaking_1 - @v8apositiontaking_1 THEN @auto_v8mpositiontaking_1 ELSE @max_v8mapositiontaking_1 - @v8apositiontaking_1 END END
		SELECT @v8mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_3, 0)<=0 THEN @v8mpositiontaking_3 ELSE CASE WHEN @auto_v8mpositiontaking_3 < @max_v8mapositiontaking_3 - @v8apositiontaking_3 THEN @auto_v8mpositiontaking_3 ELSE @max_v8mapositiontaking_3 - @v8apositiontaking_3 END END
		SELECT @v8mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v8mpositiontaking_20, 0)<=0 THEN @v8mpositiontaking_20 ELSE CASE WHEN @auto_v8mpositiontaking_20 < @max_v8mapositiontaking_20 - @v8apositiontaking_20 THEN @auto_v8mpositiontaking_20 ELSE @max_v8mapositiontaking_20 - @v8apositiontaking_20 END END

		SELECT @v10mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_1, 0)<=0 THEN @v10mpositiontaking_1 ELSE CASE WHEN @auto_v10mpositiontaking_1 < @max_v10mapositiontaking_1 - @v10apositiontaking_1 THEN @auto_v10mpositiontaking_1 ELSE @max_v10mapositiontaking_1 - @v10apositiontaking_1 END END
		SELECT @v10mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_2, 0)<=0 THEN @v10mpositiontaking_2 ELSE CASE WHEN @auto_v10mpositiontaking_2 < @max_v10mapositiontaking_2 - @v10apositiontaking_2 THEN @auto_v10mpositiontaking_2 ELSE @max_v10mapositiontaking_2 - @v10apositiontaking_2 END END
		SELECT @v10mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_3, 0)<=0 THEN @v10mpositiontaking_3 ELSE CASE WHEN @auto_v10mpositiontaking_3 < @max_v10mapositiontaking_3 - @v10apositiontaking_3 THEN @auto_v10mpositiontaking_3 ELSE @max_v10mapositiontaking_3 - @v10apositiontaking_3 END END
		SELECT @v10mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v10mpositiontaking_20, 0)<=0 THEN @v10mpositiontaking_20 ELSE CASE WHEN @auto_v10mpositiontaking_20 < @max_v10mapositiontaking_20 - @v10apositiontaking_20 THEN @auto_v10mpositiontaking_20 ELSE @max_v10mapositiontaking_20 - @v10apositiontaking_20 END END

		SELECT @v11mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v11mpositiontaking_1, 0)<=0 THEN @v11mpositiontaking_1 ELSE CASE WHEN @auto_v11mpositiontaking_1 < @max_v11mapositiontaking_1 - @v11apositiontaking_1 THEN @auto_v11mpositiontaking_1 ELSE @max_v11mapositiontaking_1 - @v11apositiontaking_1 END END
		SELECT @v11mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v11mpositiontaking_20, 0)<=0 THEN @v11mpositiontaking_20 ELSE CASE WHEN @auto_v11mpositiontaking_20 < @max_v11mapositiontaking_20 - @v11apositiontaking_20 THEN @auto_v11mpositiontaking_20 ELSE @max_v11mapositiontaking_20 - @v11apositiontaking_20 END END

		SELECT @v99mpositiontaking_1 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_1, 0)<=0 THEN @v99mpositiontaking_1 ELSE CASE WHEN @auto_v99mpositiontaking_1 < @max_v99mapositiontaking_1 - @v99apositiontaking_1 THEN @auto_v99mpositiontaking_1 ELSE @max_v99mapositiontaking_1 - @v99apositiontaking_1 END END
		SELECT @v99mpositiontaking_2 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_2, 0)<=0 THEN @v99mpositiontaking_2 ELSE CASE WHEN @auto_v99mpositiontaking_2 < @max_v99mapositiontaking_2 - @v99apositiontaking_2 THEN @auto_v99mpositiontaking_2 ELSE @max_v99mapositiontaking_2 - @v99apositiontaking_2 END END
		SELECT @v99mpositiontaking_3 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_3, 0)<=0 THEN @v99mpositiontaking_3 ELSE CASE WHEN @auto_v99mpositiontaking_3 < @max_v99mapositiontaking_3 - @v99apositiontaking_3 THEN @auto_v99mpositiontaking_3 ELSE @max_v99mapositiontaking_3 - @v99apositiontaking_3 END END
		SELECT @v99mpositiontaking_20 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_20, 0)<=0 THEN @v99mpositiontaking_20 ELSE CASE WHEN @auto_v99mpositiontaking_20 < @max_v99mapositiontaking_20 - @v99apositiontaking_20 THEN @auto_v99mpositiontaking_20 ELSE @max_v99mapositiontaking_20 - @v99apositiontaking_20 END END
		SELECT @v99mpositiontaking_9999 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_9999, 0)<=0 THEN @v99mpositiontaking_9999 ELSE CASE WHEN @auto_v99mpositiontaking_9999 < @max_v99mapositiontaking_9999 - @v99apositiontaking_9999 THEN @auto_v99mpositiontaking_9999 ELSE @max_v99mapositiontaking_9999 - @v99apositiontaking_9999 END END
		--- mixed sports
		SELECT @v99mpositiontaking_9 = CASE WHEN ISNULL(@isauto_v99mpositiontaking_9, 0)<=0 THEN @v99mpositiontaking_9 ELSE CASE WHEN @auto_v99mpositiontaking_9 < @max_v99mapositiontaking_9 - @v99apositiontaking_9 THEN @auto_v99mpositiontaking_9 ELSE @max_v99mapositiontaking_9 - @v99apositiontaking_9 END END
		
		---------------------------------------------------------------------------------------------------------------------------------------------
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
		SELECT 
			@auto_spositiontaking_1 = CASE WHEN @isauto_spositiontaking_mem_1>0 THEN @auto_spositiontaking_mem_1 ELSE @auto_spositiontaking_1 END,
			@auto_spositiontaking_2 = CASE WHEN @isauto_spositiontaking_mem_2>0 THEN @auto_spositiontaking_mem_2 ELSE @auto_spositiontaking_2 END,
			@auto_spositiontaking_3 = CASE WHEN @isauto_spositiontaking_mem_3>0 THEN @auto_spositiontaking_mem_3 ELSE @auto_spositiontaking_3 END,
			@auto_spositiontaking_4 = CASE WHEN @isauto_spositiontaking_mem_4>0 THEN @auto_spositiontaking_mem_4 ELSE @auto_spositiontaking_4 END,
			@auto_spositiontaking_5 = CASE WHEN @isauto_spositiontaking_mem_5>0 THEN @auto_spositiontaking_mem_5 ELSE @auto_spositiontaking_5 END,
			@auto_spositiontaking_6 = CASE WHEN @isauto_spositiontaking_mem_6>0 THEN @auto_spositiontaking_mem_6 ELSE @auto_spositiontaking_6 END,
			@auto_spositiontaking_7 = CASE WHEN @isauto_spositiontaking_mem_7>0 THEN @auto_spositiontaking_mem_7 ELSE @auto_spositiontaking_7 END,
			@auto_spositiontaking_8 = CASE WHEN @isauto_spositiontaking_mem_8>0 THEN @auto_spositiontaking_mem_8 ELSE @auto_spositiontaking_8 END,
			@auto_spositiontaking_9 = CASE WHEN @isauto_spositiontaking_mem_9>0 THEN @auto_spositiontaking_mem_9 ELSE @auto_spositiontaking_9 END,
			@auto_spositiontaking_10 = CASE WHEN @isauto_spositiontaking_mem_10>0 THEN @auto_spositiontaking_mem_10 ELSE @auto_spositiontaking_10 END,
			
			-- Outright PT for sports
			@auto_v2spositiontaking_10 = CASE WHEN @isauto_v2spositiontaking_mem_10>0 THEN @auto_v2spositiontaking_mem_10 ELSE @auto_v2spositiontaking_10 END,
			@auto_v3spositiontaking_10 = CASE WHEN @isauto_v3spositiontaking_mem_10>0 THEN @auto_v3spositiontaking_mem_10 ELSE @auto_v3spositiontaking_10 END,
			@auto_v5spositiontaking_10 = CASE WHEN @isauto_v5spositiontaking_mem_10>0 THEN @auto_v5spositiontaking_mem_10 ELSE @auto_v5spositiontaking_10 END,
			@auto_v8spositiontaking_10 = CASE WHEN @isauto_v8spositiontaking_mem_10>0 THEN @auto_v8spositiontaking_mem_10 ELSE @auto_v8spositiontaking_10 END,
			@auto_v10spositiontaking_10 = CASE WHEN @isauto_v10spositiontaking_mem_10>0 THEN @auto_v10spositiontaking_mem_10 ELSE @auto_v10spositiontaking_10 END,
			@auto_v11spositiontaking_10 = CASE WHEN @isauto_v11spositiontaking_mem_10>0 THEN @auto_v11spositiontaking_mem_10 ELSE @auto_v11spositiontaking_10 END,
			@auto_v99spositiontaking_10 = CASE WHEN @isauto_v99spositiontaking_mem_10>0 THEN @auto_v99spositiontaking_mem_10 ELSE @auto_v99spositiontaking_10 END,
			
			@auto_spositiontaking_9999 = CASE WHEN @isauto_spositiontaking_mem_9999>0 THEN @auto_spositiontaking_mem_9999 ELSE @auto_spositiontaking_9999 END,

			@auto_slivepositiontaking_1 = CASE WHEN @isauto_slivepositiontaking_mem_1>0 THEN @auto_slivepositiontaking_mem_1 ELSE @auto_slivepositiontaking_1 END,
			@auto_slivepositiontaking_3 = CASE WHEN @isauto_slivepositiontaking_mem_3>0 THEN @auto_slivepositiontaking_mem_3 ELSE @auto_slivepositiontaking_3 END,
			@auto_slivepositiontaking_7 = CASE WHEN @isauto_slivepositiontaking_mem_7>0 THEN @auto_slivepositiontaking_mem_7 ELSE @auto_slivepositiontaking_7 END,
			@auto_slivepositiontaking_8 = CASE WHEN @isauto_slivepositiontaking_mem_8>0 THEN @auto_slivepositiontaking_mem_8 ELSE @auto_slivepositiontaking_8 END,

			@auto_v2spositiontaking_1 = CASE WHEN @isauto_v2spositiontaking_mem_1>0 THEN @auto_v2spositiontaking_mem_1 ELSE @auto_v2spositiontaking_1 END,
			@auto_v2spositiontaking_2 = CASE WHEN @isauto_v2spositiontaking_mem_2>0 THEN @auto_v2spositiontaking_mem_2 ELSE @auto_v2spositiontaking_2 END,
			@auto_v2spositiontaking_3 = CASE WHEN @isauto_v2spositiontaking_mem_3>0 THEN @auto_v2spositiontaking_mem_3 ELSE @auto_v2spositiontaking_3 END,
			@auto_v2spositiontaking_7 = CASE WHEN @isauto_v2spositiontaking_mem_7>0 THEN @auto_v2spositiontaking_mem_7 ELSE @auto_v2spositiontaking_7 END,
			@auto_v2spositiontaking_8 = CASE WHEN @isauto_v2spositiontaking_mem_8>0 THEN @auto_v2spositiontaking_mem_8 ELSE @auto_v2spositiontaking_8 END,
		--	@auto_v2spositiontaking_9 = CASE WHEN @isauto_v2spositiontaking_mem_9>0 THEN @auto_v2spositiontaking_mem_9 ELSE @auto_v2spositiontaking_9 END,
			@auto_v2spositiontaking_20 = CASE WHEN @isauto_v2spositiontaking_mem_20>0 THEN @auto_v2spositiontaking_mem_20 ELSE @auto_v2spositiontaking_20 END,
			@auto_v2spositiontaking_9999 = CASE WHEN @isauto_v2spositiontaking_mem_9999>0 THEN @auto_v2spositiontaking_mem_9999 ELSE @auto_v2spositiontaking_9999 END,

			@auto_v3spositiontaking_1 = CASE WHEN @isauto_v3spositiontaking_mem_1>0 THEN @auto_v3spositiontaking_mem_1 ELSE @auto_v3spositiontaking_1 END,
			@auto_v3spositiontaking_2 = CASE WHEN @isauto_v3spositiontaking_mem_2>0 THEN @auto_v3spositiontaking_mem_2 ELSE @auto_v3spositiontaking_2 END,
			@auto_v3spositiontaking_3 = CASE WHEN @isauto_v3spositiontaking_mem_3>0 THEN @auto_v3spositiontaking_mem_3 ELSE @auto_v3spositiontaking_3 END,
			@auto_v3spositiontaking_20 = CASE WHEN @isauto_v3spositiontaking_mem_20>0 THEN @auto_v3spositiontaking_mem_20 ELSE @auto_v3spositiontaking_20 END,

			@auto_v5spositiontaking_1 = CASE WHEN @isauto_v5spositiontaking_mem_1>0 THEN @auto_v5spositiontaking_mem_1 ELSE @auto_v5spositiontaking_1 END,
			@auto_v5spositiontaking_2 = CASE WHEN @isauto_v5spositiontaking_mem_2>0 THEN @auto_v5spositiontaking_mem_2 ELSE @auto_v5spositiontaking_2 END,
			@auto_v5spositiontaking_3 = CASE WHEN @isauto_v5spositiontaking_mem_3>0 THEN @auto_v5spositiontaking_mem_3 ELSE @auto_v5spositiontaking_3 END,
			@auto_v5spositiontaking_20 = CASE WHEN @isauto_v5spositiontaking_mem_20>0 THEN @auto_v5spositiontaking_mem_20 ELSE @auto_v5spositiontaking_20 END,
			@auto_v5spositiontaking_9999 = CASE WHEN @isauto_v5spositiontaking_mem_9999>0 THEN @auto_v5spositiontaking_mem_9999 ELSE @auto_v5spositiontaking_9999 END,

			@auto_v8spositiontaking_1 = CASE WHEN @isauto_v8spositiontaking_mem_1>0 THEN @auto_v8spositiontaking_mem_1 ELSE @auto_v8spositiontaking_1 END,
			@auto_v8spositiontaking_3 = CASE WHEN @isauto_v8spositiontaking_mem_3>0 THEN @auto_v8spositiontaking_mem_3 ELSE @auto_v8spositiontaking_3 END,
			@auto_v8spositiontaking_20 = CASE WHEN @isauto_v8spositiontaking_mem_20>0 THEN @auto_v8spositiontaking_mem_20 ELSE @auto_v8spositiontaking_20 END,

			@auto_v10spositiontaking_1 = CASE WHEN @isauto_v10spositiontaking_mem_1>0 THEN @auto_v10spositiontaking_mem_1 ELSE @auto_v10spositiontaking_1 END,
			@auto_v10spositiontaking_2 = CASE WHEN @isauto_v10spositiontaking_mem_2>0 THEN @auto_v10spositiontaking_mem_2 ELSE @auto_v10spositiontaking_2 END,
			@auto_v10spositiontaking_3 = CASE WHEN @isauto_v10spositiontaking_mem_3>0 THEN @auto_v10spositiontaking_mem_3 ELSE @auto_v10spositiontaking_3 END,
			@auto_v10spositiontaking_20 = CASE WHEN @isauto_v10spositiontaking_mem_20>0 THEN @auto_v10spositiontaking_mem_20 ELSE @auto_v10spositiontaking_20 END,

			@auto_v11spositiontaking_1 = CASE WHEN @isauto_v11spositiontaking_mem_1>0 THEN @auto_v11spositiontaking_mem_1 ELSE @auto_v11spositiontaking_1 END,
			@auto_v11spositiontaking_20 = CASE WHEN @isauto_v11spositiontaking_mem_20>0 THEN @auto_v11spositiontaking_mem_20 ELSE @auto_v11spositiontaking_20 END,

			@auto_v99spositiontaking_1 = CASE WHEN @isauto_v99spositiontaking_mem_1>0 THEN @auto_v99spositiontaking_mem_1 ELSE @auto_v99spositiontaking_1 END,
			@auto_v99spositiontaking_2 = CASE WHEN @isauto_v99spositiontaking_mem_2>0 THEN @auto_v99spositiontaking_mem_2 ELSE @auto_v99spositiontaking_2 END,
			@auto_v99spositiontaking_3 = CASE WHEN @isauto_v99spositiontaking_mem_3>0 THEN @auto_v99spositiontaking_mem_3 ELSE @auto_v99spositiontaking_3 END,
			@auto_v99spositiontaking_20 = CASE WHEN @isauto_v99spositiontaking_mem_20>0 THEN @auto_v99spositiontaking_mem_20 ELSE @auto_v99spositiontaking_20 END,
			@auto_v99spositiontaking_9999 = CASE WHEN @isauto_v99spositiontaking_mem_9999>0 THEN @auto_v99spositiontaking_mem_9999 ELSE @auto_v99spositiontaking_9999 END,
			-- mixed sports
			@auto_v99spositiontaking_9 = CASE WHEN @isauto_v99spositiontaking_mem_9>0 THEN @auto_v99spositiontaking_mem_9 ELSE @auto_v99spositiontaking_9 END,
	
			@isauto_spositiontaking_1 = CASE WHEN @isauto_spositiontaking_mem_1>0 THEN @isauto_spositiontaking_mem_1 ELSE @isauto_spositiontaking_1 END,
			@isauto_spositiontaking_2 = CASE WHEN @isauto_spositiontaking_mem_2>0 THEN @isauto_spositiontaking_mem_2 ELSE @isauto_spositiontaking_2 END,
			@isauto_spositiontaking_3 = CASE WHEN @isauto_spositiontaking_mem_3>0 THEN @isauto_spositiontaking_mem_3 ELSE @isauto_spositiontaking_3 END,
			@isauto_spositiontaking_4 = CASE WHEN @isauto_spositiontaking_mem_4>0 THEN @isauto_spositiontaking_mem_4 ELSE @isauto_spositiontaking_4 END,
			@isauto_spositiontaking_5 = CASE WHEN @isauto_spositiontaking_mem_5>0 THEN @isauto_spositiontaking_mem_5 ELSE @isauto_spositiontaking_5 END,
			@isauto_spositiontaking_6 = CASE WHEN @isauto_spositiontaking_mem_6>0 THEN @isauto_spositiontaking_mem_6 ELSE @isauto_spositiontaking_6 END,
			@isauto_spositiontaking_7 = CASE WHEN @isauto_spositiontaking_mem_7>0 THEN @isauto_spositiontaking_mem_7 ELSE @isauto_spositiontaking_7 END,
			@isauto_spositiontaking_8 = CASE WHEN @isauto_spositiontaking_mem_8>0 THEN @isauto_spositiontaking_mem_8 ELSE @isauto_spositiontaking_8 END,
			@isauto_spositiontaking_9 = CASE WHEN @isauto_spositiontaking_mem_9>0 THEN @isauto_spositiontaking_mem_9 ELSE @isauto_spositiontaking_9 END,
			@isauto_spositiontaking_10 = CASE WHEN @isauto_spositiontaking_mem_10>0 THEN @isauto_spositiontaking_mem_10 ELSE @isauto_spositiontaking_10 END,
			
			-- Outright PT for sports
			@isauto_v2spositiontaking_10 = CASE WHEN @isauto_v2spositiontaking_mem_10>0 THEN @isauto_v2spositiontaking_mem_10 ELSE @isauto_v2spositiontaking_10 END,
			@isauto_v3spositiontaking_10 = CASE WHEN @isauto_v3spositiontaking_mem_10>0 THEN @isauto_v3spositiontaking_mem_10 ELSE @isauto_v3spositiontaking_10 END,
			@isauto_v5spositiontaking_10 = CASE WHEN @isauto_v5spositiontaking_mem_10>0 THEN @isauto_v5spositiontaking_mem_10 ELSE @isauto_v5spositiontaking_10 END,
			@isauto_v8spositiontaking_10 = CASE WHEN @isauto_v8spositiontaking_mem_10>0 THEN @isauto_v8spositiontaking_mem_10 ELSE @isauto_v8spositiontaking_10 END,
			@isauto_v10spositiontaking_10 = CASE WHEN @isauto_v10spositiontaking_mem_10>0 THEN @isauto_v10spositiontaking_mem_10 ELSE @isauto_v10spositiontaking_10 END,
			@isauto_v11spositiontaking_10 = CASE WHEN @isauto_v11spositiontaking_mem_10>0 THEN @isauto_v11spositiontaking_mem_10 ELSE @isauto_v11spositiontaking_10 END,
			@isauto_v99spositiontaking_10 = CASE WHEN @isauto_v99spositiontaking_mem_10>0 THEN @isauto_v99spositiontaking_mem_10 ELSE @isauto_v99spositiontaking_10 END,
			
			@isauto_spositiontaking_9999 = CASE WHEN @isauto_spositiontaking_mem_9999>0 THEN @isauto_spositiontaking_mem_9999 ELSE @isauto_spositiontaking_9999 END,

			@isauto_slivepositiontaking_1 = CASE WHEN @isauto_slivepositiontaking_mem_1>0 THEN @isauto_slivepositiontaking_mem_1 ELSE @isauto_slivepositiontaking_1 END,
			@isauto_slivepositiontaking_3 = CASE WHEN @isauto_slivepositiontaking_mem_3>0 THEN @isauto_slivepositiontaking_mem_3 ELSE @isauto_slivepositiontaking_3 END,
			@isauto_slivepositiontaking_7 = CASE WHEN @isauto_slivepositiontaking_mem_7>0 THEN @isauto_slivepositiontaking_mem_7 ELSE @isauto_slivepositiontaking_7 END,
			@isauto_slivepositiontaking_8 = CASE WHEN @isauto_slivepositiontaking_mem_8>0 THEN @isauto_slivepositiontaking_mem_8 ELSE @isauto_slivepositiontaking_8 END,

			@isauto_v2spositiontaking_1 = CASE WHEN @isauto_v2spositiontaking_mem_1>0 THEN @isauto_v2spositiontaking_mem_1 ELSE @isauto_v2spositiontaking_1 END,
			@isauto_v2spositiontaking_2 = CASE WHEN @isauto_v2spositiontaking_mem_2>0 THEN @isauto_v2spositiontaking_mem_2 ELSE @isauto_v2spositiontaking_2 END,
			@isauto_v2spositiontaking_3 = CASE WHEN @isauto_v2spositiontaking_mem_3>0 THEN @isauto_v2spositiontaking_mem_3 ELSE @isauto_v2spositiontaking_3 END,
			@isauto_v2spositiontaking_7 = CASE WHEN @isauto_v2spositiontaking_mem_7>0 THEN @isauto_v2spositiontaking_mem_7 ELSE @isauto_v2spositiontaking_7 END,
			@isauto_v2spositiontaking_8 = CASE WHEN @isauto_v2spositiontaking_mem_8>0 THEN @isauto_v2spositiontaking_mem_8 ELSE @isauto_v2spositiontaking_8 END,
		--	@isauto_v2spositiontaking_9 = CASE WHEN @isauto_v2spositiontaking_mem_9>0 THEN @isauto_v2spositiontaking_mem_9 ELSE @isauto_v2spositiontaking_9 END,
			@isauto_v2spositiontaking_20 = CASE WHEN @isauto_v2spositiontaking_mem_20>0 THEN @isauto_v2spositiontaking_mem_20 ELSE @isauto_v2spositiontaking_20 END,
			@isauto_v2spositiontaking_9999 = CASE WHEN @isauto_v2spositiontaking_mem_9999>0 THEN @isauto_v2spositiontaking_mem_9999 ELSE @isauto_v2spositiontaking_9999 END,

			@isauto_v3spositiontaking_1 = CASE WHEN @isauto_v3spositiontaking_mem_1>0 THEN @isauto_v3spositiontaking_mem_1 ELSE @isauto_v3spositiontaking_1 END,
			@isauto_v3spositiontaking_2 = CASE WHEN @isauto_v3spositiontaking_mem_2>0 THEN @isauto_v3spositiontaking_mem_2 ELSE @isauto_v3spositiontaking_2 END,
			@isauto_v3spositiontaking_3 = CASE WHEN @isauto_v3spositiontaking_mem_3>0 THEN @isauto_v3spositiontaking_mem_3 ELSE @isauto_v3spositiontaking_3 END,
			@isauto_v3spositiontaking_20 = CASE WHEN @isauto_v3spositiontaking_mem_20>0 THEN @isauto_v3spositiontaking_mem_20 ELSE @isauto_v3spositiontaking_20 END,

			@isauto_v5spositiontaking_1 = CASE WHEN @isauto_v5spositiontaking_mem_1>0 THEN @isauto_v5spositiontaking_mem_1 ELSE @isauto_v5spositiontaking_1 END,
			@isauto_v5spositiontaking_2 = CASE WHEN @isauto_v5spositiontaking_mem_2>0 THEN @isauto_v5spositiontaking_mem_2 ELSE @isauto_v5spositiontaking_2 END,
			@isauto_v5spositiontaking_3 = CASE WHEN @isauto_v5spositiontaking_mem_3>0 THEN @isauto_v5spositiontaking_mem_3 ELSE @isauto_v5spositiontaking_3 END,
			@isauto_v5spositiontaking_20 = CASE WHEN @isauto_v5spositiontaking_mem_20>0 THEN @isauto_v5spositiontaking_mem_20 ELSE @isauto_v5spositiontaking_20 END,
			@isauto_v5spositiontaking_9999 = CASE WHEN @isauto_v5spositiontaking_mem_9999>0 THEN @isauto_v5spositiontaking_mem_9999 ELSE @isauto_v5spositiontaking_9999 END,

			@isauto_v8spositiontaking_1 = CASE WHEN @isauto_v8spositiontaking_mem_1>0 THEN @isauto_v8spositiontaking_mem_1 ELSE @isauto_v8spositiontaking_1 END,
			@isauto_v8spositiontaking_3 = CASE WHEN @isauto_v8spositiontaking_mem_3>0 THEN @isauto_v8spositiontaking_mem_3 ELSE @isauto_v8spositiontaking_3 END,
			@isauto_v8spositiontaking_20 = CASE WHEN @isauto_v8spositiontaking_mem_20>0 THEN @isauto_v8spositiontaking_mem_20 ELSE @isauto_v8spositiontaking_20 END,

			@isauto_v10spositiontaking_1 = CASE WHEN @isauto_v10spositiontaking_mem_1>0 THEN @isauto_v10spositiontaking_mem_1 ELSE @isauto_v10spositiontaking_1 END,
			@isauto_v10spositiontaking_2 = CASE WHEN @isauto_v10spositiontaking_mem_2>0 THEN @isauto_v10spositiontaking_mem_2 ELSE @isauto_v10spositiontaking_2 END,
			@isauto_v10spositiontaking_3 = CASE WHEN @isauto_v10spositiontaking_mem_3>0 THEN @isauto_v10spositiontaking_mem_3 ELSE @isauto_v10spositiontaking_3 END,
			@isauto_v10spositiontaking_20 = CASE WHEN @isauto_v10spositiontaking_mem_20>0 THEN @isauto_v10spositiontaking_mem_20 ELSE @isauto_v10spositiontaking_20 END,

			@isauto_v11spositiontaking_1 = CASE WHEN @isauto_v11spositiontaking_mem_1>0 THEN @isauto_v11spositiontaking_mem_1 ELSE @isauto_v11spositiontaking_1 END,
			@isauto_v11spositiontaking_20 = CASE WHEN @isauto_v11spositiontaking_mem_20>0 THEN @isauto_v11spositiontaking_mem_20 ELSE @isauto_v11spositiontaking_20 END,

			@isauto_v99spositiontaking_1 = CASE WHEN @isauto_v99spositiontaking_mem_1>0 THEN @isauto_v99spositiontaking_mem_1 ELSE @isauto_v99spositiontaking_1 END,
			@isauto_v99spositiontaking_2 = CASE WHEN @isauto_v99spositiontaking_mem_2>0 THEN @isauto_v99spositiontaking_mem_2 ELSE @isauto_v99spositiontaking_2 END,
			@isauto_v99spositiontaking_3 = CASE WHEN @isauto_v99spositiontaking_mem_3>0 THEN @isauto_v99spositiontaking_mem_3 ELSE @isauto_v99spositiontaking_3 END,
			@isauto_v99spositiontaking_20 = CASE WHEN @isauto_v99spositiontaking_mem_20>0 THEN @isauto_v99spositiontaking_mem_20 ELSE @isauto_v99spositiontaking_20 END,
			@isauto_v99spositiontaking_9999 = CASE WHEN @isauto_v99spositiontaking_mem_9999>0 THEN @isauto_v99spositiontaking_mem_9999 ELSE @isauto_v99spositiontaking_9999 END,
			-- mixed sports
			@isauto_v99spositiontaking_9 = CASE WHEN @isauto_v99spositiontaking_mem_9>0 THEN @isauto_v99spositiontaking_mem_9 ELSE @isauto_v99spositiontaking_9 END

		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		SELECT @spositiontaking_1 = CASE WHEN ISNULL(@isauto_spositiontaking_1, 0)<=0 THEN @spositiontaking_1 ELSE CASE WHEN @auto_spositiontaking_1 < @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 THEN @auto_spositiontaking_1 ELSE @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 END END
		SELECT @spositiontaking_3 = CASE WHEN ISNULL(@isauto_spositiontaking_3, 0)<=0 THEN @spositiontaking_3 ELSE CASE WHEN @auto_spositiontaking_3 < @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 THEN @auto_spositiontaking_3 ELSE @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 END END
		SELECT @spositiontaking_7 = CASE WHEN ISNULL(@isauto_spositiontaking_7, 0)<=0 THEN @spositiontaking_7 ELSE CASE WHEN @auto_spositiontaking_7 < @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 THEN @auto_spositiontaking_7 ELSE @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 END END
		SELECT @spositiontaking_8 = CASE WHEN ISNULL(@isauto_spositiontaking_8, 0)<=0 THEN @spositiontaking_8 ELSE CASE WHEN @auto_spositiontaking_8 < @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 THEN @auto_spositiontaking_8 ELSE @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 END END

		SELECT @slivepositiontaking_1 = CASE WHEN ISNULL(@isauto_slivepositiontaking_1, 0)<=0 THEN @slivepositiontaking_1 ELSE CASE WHEN @auto_slivepositiontaking_1 < @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 THEN @auto_slivepositiontaking_1 ELSE @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 END END
		SELECT @slivepositiontaking_3 = CASE WHEN ISNULL(@isauto_slivepositiontaking_3, 0)<=0 THEN @slivepositiontaking_3 ELSE CASE WHEN @auto_slivepositiontaking_3 < @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 THEN @auto_slivepositiontaking_3 ELSE @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 END END
		SELECT @slivepositiontaking_7 = CASE WHEN ISNULL(@isauto_slivepositiontaking_7, 0)<=0 THEN @slivepositiontaking_7 ELSE CASE WHEN @auto_slivepositiontaking_7 < @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 THEN @auto_slivepositiontaking_7 ELSE @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 END END
		SELECT @slivepositiontaking_8 = CASE WHEN ISNULL(@isauto_slivepositiontaking_8, 0)<=0 THEN @slivepositiontaking_8 ELSE CASE WHEN @auto_slivepositiontaking_8 < @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 THEN @auto_slivepositiontaking_8 ELSE @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 END END

		SELECT @spositiontaking_2 = CASE WHEN ISNULL(@isauto_spositiontaking_2, 0)<=0 THEN @spositiontaking_2 ELSE CASE WHEN @auto_spositiontaking_2 < @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 THEN @auto_spositiontaking_2 ELSE @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 END END
		SELECT @spositiontaking_4 = CASE WHEN ISNULL(@isauto_spositiontaking_4, 0)<=0 THEN @spositiontaking_4 ELSE CASE WHEN @auto_spositiontaking_4 < @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 THEN @auto_spositiontaking_4 ELSE @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 END END
		SELECT @spositiontaking_5 = CASE WHEN ISNULL(@isauto_spositiontaking_5, 0)<=0 THEN @spositiontaking_5 ELSE CASE WHEN @auto_spositiontaking_5 < @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 THEN @auto_spositiontaking_5 ELSE @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 END END
		SELECT @spositiontaking_6 = CASE WHEN ISNULL(@isauto_spositiontaking_6, 0)<=0 THEN @spositiontaking_6 ELSE CASE WHEN @auto_spositiontaking_6 < @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 THEN @auto_spositiontaking_6 ELSE @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 END END
		SELECT @spositiontaking_9 = CASE WHEN ISNULL(@isauto_spositiontaking_9, 0)<=0 THEN @spositiontaking_9 ELSE CASE WHEN @auto_spositiontaking_9 < @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 THEN @auto_spositiontaking_9 ELSE @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 END END
		SELECT @spositiontaking_10 = CASE WHEN ISNULL(@isauto_spositiontaking_10, 0)<=0 THEN @spositiontaking_10 ELSE CASE WHEN @auto_spositiontaking_10 < @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 THEN @auto_spositiontaking_10 ELSE @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 END END
		
		-- Outright PT for sports
		SELECT @v2spositiontaking_10 = CASE WHEN ISNULL(@isauto_v2spositiontaking_10, 0)<=0 THEN @v2spositiontaking_10 ELSE CASE WHEN @auto_v2spositiontaking_10 < @max_v2spositiontaking_10 - @v2mpositiontaking_10 - @v2apositiontaking_10 THEN @auto_v2spositiontaking_10 ELSE @max_v2spositiontaking_10 - @v2mpositiontaking_10 - @v2apositiontaking_10 END END
		SELECT @v3spositiontaking_10 = CASE WHEN ISNULL(@isauto_v3spositiontaking_10, 0)<=0 THEN @v3spositiontaking_10 ELSE CASE WHEN @auto_v3spositiontaking_10 < @max_v3spositiontaking_10 - @v3mpositiontaking_10 - @v3apositiontaking_10 THEN @auto_v3spositiontaking_10 ELSE @max_v3spositiontaking_10 - @v3mpositiontaking_10 - @v3apositiontaking_10 END END
		SELECT @v5spositiontaking_10 = CASE WHEN ISNULL(@isauto_v5spositiontaking_10, 0)<=0 THEN @v5spositiontaking_10 ELSE CASE WHEN @auto_v5spositiontaking_10 < @max_v5spositiontaking_10 - @v5mpositiontaking_10 - @v5apositiontaking_10 THEN @auto_v5spositiontaking_10 ELSE @max_v5spositiontaking_10 - @v5mpositiontaking_10 - @v5apositiontaking_10 END END
		SELECT @v8spositiontaking_10 = CASE WHEN ISNULL(@isauto_v8spositiontaking_10, 0)<=0 THEN @v8spositiontaking_10 ELSE CASE WHEN @auto_v8spositiontaking_10 < @max_v8spositiontaking_10 - @v8mpositiontaking_10 - @v8apositiontaking_10 THEN @auto_v8spositiontaking_10 ELSE @max_v8spositiontaking_10 - @v8mpositiontaking_10 - @v8apositiontaking_10 END END
		SELECT @v10spositiontaking_10 = CASE WHEN ISNULL(@isauto_v10spositiontaking_10, 0)<=0 THEN @v10spositiontaking_10 ELSE CASE WHEN @auto_v10spositiontaking_10 < @max_v10spositiontaking_10 - @v10mpositiontaking_10 - @v10apositiontaking_10 THEN @auto_v10spositiontaking_10 ELSE @max_v10spositiontaking_10 - @v10mpositiontaking_10 - @v10apositiontaking_10 END END
		SELECT @v11spositiontaking_10 = CASE WHEN ISNULL(@isauto_v11spositiontaking_10, 0)<=0 THEN @v11spositiontaking_10 ELSE CASE WHEN @auto_v11spositiontaking_10 < @max_v11spositiontaking_10 - @v11mpositiontaking_10 - @v11apositiontaking_10 THEN @auto_v11spositiontaking_10 ELSE @max_v11spositiontaking_10 - @v11mpositiontaking_10 - @v11apositiontaking_10 END END
		SELECT @v99spositiontaking_10 = CASE WHEN ISNULL(@isauto_v99spositiontaking_10, 0)<=0 THEN @v99spositiontaking_10 ELSE CASE WHEN @auto_v99spositiontaking_10 < @max_v99spositiontaking_10 - @v99mpositiontaking_10 - @v99apositiontaking_10 THEN @auto_v99spositiontaking_10 ELSE @max_v99spositiontaking_10 - @v99mpositiontaking_10 - @v99apositiontaking_10 END END
		
		SELECT @spositiontaking_9999 = CASE WHEN ISNULL(@isauto_spositiontaking_9999, 0)<=0 THEN @spositiontaking_9999 ELSE CASE WHEN @auto_spositiontaking_9999 < @max_spositiontaking_9999 - @mpositiontaking_9999 - @apositiontaking_9999 THEN @auto_spositiontaking_9999 ELSE @max_spositiontaking_9999 - @mpositiontaking_9999 - @apositiontaking_9999 END END

		SELECT @v2spositiontaking_1 = CASE WHEN ISNULL(@isauto_v2spositiontaking_1, 0)<=0 THEN @v2spositiontaking_1 ELSE CASE WHEN @auto_v2spositiontaking_1 < @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 THEN @auto_v2spositiontaking_1 ELSE @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 END END
		SELECT @v2spositiontaking_2 = CASE WHEN ISNULL(@isauto_v2spositiontaking_2, 0)<=0 THEN @v2spositiontaking_2 ELSE CASE WHEN @auto_v2spositiontaking_2 < @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 THEN @auto_v2spositiontaking_2 ELSE @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 END END
		SELECT @v2spositiontaking_3 = CASE WHEN ISNULL(@isauto_v2spositiontaking_3, 0)<=0 THEN @v2spositiontaking_3 ELSE CASE WHEN @auto_v2spositiontaking_3 < @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 THEN @auto_v2spositiontaking_3 ELSE @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 END END
		SELECT @v2spositiontaking_7 = CASE WHEN ISNULL(@isauto_v2spositiontaking_7, 0)<=0 THEN @v2spositiontaking_7 ELSE CASE WHEN @auto_v2spositiontaking_7 < @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 THEN @auto_v2spositiontaking_7 ELSE @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 END END
		SELECT @v2spositiontaking_8 = CASE WHEN ISNULL(@isauto_v2spositiontaking_8, 0)<=0 THEN @v2spositiontaking_8 ELSE CASE WHEN @auto_v2spositiontaking_8 < @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 THEN @auto_v2spositiontaking_8 ELSE @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 END END
		--SELECT @v2spositiontaking_9 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9, 0)<=0 THEN @v2spositiontaking_9 ELSE CASE WHEN @auto_v2spositiontaking_9 < @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 THEN @auto_v2spositiontaking_9 ELSE @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 END END
		SELECT @v2spositiontaking_20 = CASE WHEN ISNULL(@isauto_v2spositiontaking_20, 0)<=0 THEN @v2spositiontaking_20 ELSE CASE WHEN @auto_v2spositiontaking_20 < @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 THEN @auto_v2spositiontaking_20 ELSE @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 END END
		SELECT @v2spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9999, 0)<=0 THEN @v2spositiontaking_9999 ELSE CASE WHEN @auto_v2spositiontaking_9999 < @max_v2spositiontaking_9999 - @v2mpositiontaking_9999 - @v2apositiontaking_9999 THEN @auto_v2spositiontaking_9999 ELSE @max_v2spositiontaking_9999 - @v2mpositiontaking_9999 - @v2apositiontaking_9999 END END

		SELECT @v3spositiontaking_1 = CASE WHEN ISNULL(@isauto_v3spositiontaking_1, 0)<=0 THEN @v3spositiontaking_1 ELSE CASE WHEN @auto_v3spositiontaking_1 < @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 THEN @auto_v3spositiontaking_1 ELSE @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 END END
		SELECT @v3spositiontaking_2 = CASE WHEN ISNULL(@isauto_v3spositiontaking_2, 0)<=0 THEN @v3spositiontaking_2 ELSE CASE WHEN @auto_v3spositiontaking_2 < @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 THEN @auto_v3spositiontaking_2 ELSE @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 END END
		SELECT @v3spositiontaking_3 = CASE WHEN ISNULL(@isauto_v3spositiontaking_3, 0)<=0 THEN @v3spositiontaking_3 ELSE CASE WHEN @auto_v3spositiontaking_3 < @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 THEN @auto_v3spositiontaking_3 ELSE @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 END END
		SELECT @v3spositiontaking_20 = CASE WHEN ISNULL(@isauto_v3spositiontaking_20, 0)<=0 THEN @v3spositiontaking_20 ELSE CASE WHEN @auto_v3spositiontaking_20 < @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 THEN @auto_v3spositiontaking_20 ELSE @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 END END

		SELECT @v5spositiontaking_1 = CASE WHEN ISNULL(@isauto_v5spositiontaking_1, 0)<=0 THEN @v5spositiontaking_1 ELSE CASE WHEN @auto_v5spositiontaking_1 < @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 THEN @auto_v5spositiontaking_1 ELSE @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 END END
		SELECT @v5spositiontaking_2 = CASE WHEN ISNULL(@isauto_v5spositiontaking_2, 0)<=0 THEN @v5spositiontaking_2 ELSE CASE WHEN @auto_v5spositiontaking_2 < @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 THEN @auto_v5spositiontaking_2 ELSE @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 END END
		SELECT @v5spositiontaking_3 = CASE WHEN ISNULL(@isauto_v5spositiontaking_3, 0)<=0 THEN @v5spositiontaking_3 ELSE CASE WHEN @auto_v5spositiontaking_3 < @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 THEN @auto_v5spositiontaking_3 ELSE @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 END END
		SELECT @v5spositiontaking_20 = CASE WHEN ISNULL(@isauto_v5spositiontaking_20, 0)<=0 THEN @v5spositiontaking_20 ELSE CASE WHEN @auto_v5spositiontaking_20 < @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 THEN @auto_v5spositiontaking_20 ELSE @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 END END
		SELECT @v5spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v5spositiontaking_9999, 0)<=0 THEN @v5spositiontaking_9999 ELSE CASE WHEN @auto_v5spositiontaking_9999 < @max_v5spositiontaking_9999 - @v5mpositiontaking_9999 - @v5apositiontaking_9999 THEN @auto_v5spositiontaking_9999 ELSE @max_v5spositiontaking_9999 - @v5mpositiontaking_9999 - @v5apositiontaking_9999 END END

		SELECT @v8spositiontaking_1 = CASE WHEN ISNULL(@isauto_v8spositiontaking_1, 0)<=0 THEN @v8spositiontaking_1 ELSE CASE WHEN @auto_v8spositiontaking_1 < @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 THEN @auto_v8spositiontaking_1 ELSE @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 END END
		SELECT @v8spositiontaking_3 = CASE WHEN ISNULL(@isauto_v8spositiontaking_3, 0)<=0 THEN @v8spositiontaking_3 ELSE CASE WHEN @auto_v8spositiontaking_3 < @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 THEN @auto_v8spositiontaking_3 ELSE @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 END END
		SELECT @v8spositiontaking_20 = CASE WHEN ISNULL(@isauto_v8spositiontaking_20, 0)<=0 THEN @v8spositiontaking_20 ELSE CASE WHEN @auto_v8spositiontaking_20 < @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 THEN @auto_v8spositiontaking_20 ELSE @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 END END

		SELECT @v10spositiontaking_1 = CASE WHEN ISNULL(@isauto_v10spositiontaking_1, 0)<=0 THEN @v10spositiontaking_1 ELSE CASE WHEN @auto_v10spositiontaking_1 < @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 THEN @auto_v10spositiontaking_1 ELSE @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 END END
		SELECT @v10spositiontaking_2 = CASE WHEN ISNULL(@isauto_v10spositiontaking_2, 0)<=0 THEN @v10spositiontaking_2 ELSE CASE WHEN @auto_v10spositiontaking_2 < @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 THEN @auto_v10spositiontaking_2 ELSE @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 END END
		SELECT @v10spositiontaking_3 = CASE WHEN ISNULL(@isauto_v10spositiontaking_3, 0)<=0 THEN @v10spositiontaking_3 ELSE CASE WHEN @auto_v10spositiontaking_3 < @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 THEN @auto_v10spositiontaking_3 ELSE @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 END END
		SELECT @v10spositiontaking_20 = CASE WHEN ISNULL(@isauto_v10spositiontaking_20, 0)<=0 THEN @v10spositiontaking_20 ELSE CASE WHEN @auto_v10spositiontaking_20 < @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 THEN @auto_v10spositiontaking_20 ELSE @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 END END

		SELECT @v11spositiontaking_1 = CASE WHEN ISNULL(@isauto_v11spositiontaking_1, 0)<=0 THEN @v11spositiontaking_1 ELSE CASE WHEN @auto_v11spositiontaking_1 < @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 THEN @auto_v11spositiontaking_1 ELSE @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 END END
		SELECT @v11spositiontaking_20 = CASE WHEN ISNULL(@isauto_v11spositiontaking_20, 0)<=0 THEN @v11spositiontaking_20 ELSE CASE WHEN @auto_v11spositiontaking_20 < @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 THEN @auto_v11spositiontaking_20 ELSE @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 END END

		SELECT @v99spositiontaking_1 = CASE WHEN ISNULL(@isauto_v99spositiontaking_1, 0)<=0 THEN @v99spositiontaking_1 ELSE CASE WHEN @auto_v99spositiontaking_1 < @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 THEN @auto_v99spositiontaking_1 ELSE @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 END END
		SELECT @v99spositiontaking_2 = CASE WHEN ISNULL(@isauto_v99spositiontaking_2, 0)<=0 THEN @v99spositiontaking_2 ELSE CASE WHEN @auto_v99spositiontaking_2 < @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 THEN @auto_v99spositiontaking_2 ELSE @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 END END
		SELECT @v99spositiontaking_3 = CASE WHEN ISNULL(@isauto_v99spositiontaking_3, 0)<=0 THEN @v99spositiontaking_3 ELSE CASE WHEN @auto_v99spositiontaking_3 < @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 THEN @auto_v99spositiontaking_3 ELSE @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 END END
		SELECT @v99spositiontaking_20 = CASE WHEN ISNULL(@isauto_v99spositiontaking_20, 0)<=0 THEN @v99spositiontaking_20 ELSE CASE WHEN @auto_v99spositiontaking_20 < @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 THEN @auto_v99spositiontaking_20 ELSE @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 END END
		SELECT @v99spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9999, 0)<=0 THEN @v99spositiontaking_9999 ELSE CASE WHEN @auto_v99spositiontaking_9999 < @max_v99spositiontaking_9999 - @v99mpositiontaking_9999 - @v99apositiontaking_9999 THEN @auto_v99spositiontaking_9999 ELSE @max_v99spositiontaking_9999 - @v99mpositiontaking_9999 - @v99apositiontaking_9999 END END
		-- mixed sports
		SELECT @v99spositiontaking_9 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9, 0)<=0 
											THEN @v99spositiontaking_9 
											ELSE CASE WHEN @auto_v99spositiontaking_9 
															< @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 
														THEN @auto_v99spositiontaking_9 
														ELSE @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 
												END
									 END
		-------------------------------------------------------------------------------
		--maxs1=isauto?s4:s4-m3
		SELECT @max_spositiontaking_1 = CASE WHEN ISNULL(@isauto_spositiontaking_1, 0)>0 THEN @max_spositiontaking_1 ELSE @max_spositiontaking_1-@max_mapositiontaking_1 END
		SELECT @max_spositiontaking_3 = CASE WHEN ISNULL(@isauto_spositiontaking_3, 0)>0 THEN @max_spositiontaking_3 ELSE @max_spositiontaking_3-@max_mapositiontaking_3 END
		SELECT @max_spositiontaking_7 = CASE WHEN ISNULL(@isauto_spositiontaking_7, 0)>0 THEN @max_spositiontaking_7 ELSE @max_spositiontaking_7-@max_mapositiontaking_7 END
		SELECT @max_spositiontaking_8 = CASE WHEN ISNULL(@isauto_spositiontaking_8, 0)>0 THEN @max_spositiontaking_8 ELSE @max_spositiontaking_8-@max_mapositiontaking_8 END

		SELECT @max_slivepositiontaking_1 = CASE WHEN ISNULL(@isauto_slivepositiontaking_1, 0)>0 THEN @max_slivepositiontaking_1 ELSE @max_slivepositiontaking_1-@max_malivepositiontaking_1 END
		SELECT @max_slivepositiontaking_3 = CASE WHEN ISNULL(@isauto_slivepositiontaking_3, 0)>0 THEN @max_slivepositiontaking_3 ELSE @max_slivepositiontaking_3-@max_malivepositiontaking_3 END
		SELECT @max_slivepositiontaking_7 = CASE WHEN ISNULL(@isauto_slivepositiontaking_7, 0)>0 THEN @max_slivepositiontaking_7 ELSE @max_slivepositiontaking_7-@max_malivepositiontaking_7 END
		SELECT @max_slivepositiontaking_8 = CASE WHEN ISNULL(@isauto_slivepositiontaking_8, 0)>0 THEN @max_slivepositiontaking_8 ELSE @max_slivepositiontaking_8-@max_malivepositiontaking_8 END

		SELECT @max_spositiontaking_2 = CASE WHEN ISNULL(@isauto_spositiontaking_2, 0)>0 THEN @max_spositiontaking_2 ELSE @max_spositiontaking_2-@max_mapositiontaking_2 END
		SELECT @max_spositiontaking_4 = CASE WHEN ISNULL(@isauto_spositiontaking_4, 0)>0 THEN @max_spositiontaking_4 ELSE @max_spositiontaking_4-@max_mapositiontaking_4 END
		SELECT @max_spositiontaking_5 = CASE WHEN ISNULL(@isauto_spositiontaking_5, 0)>0 THEN @max_spositiontaking_5 ELSE @max_spositiontaking_5-@max_mapositiontaking_5 END
		SELECT @max_spositiontaking_6 = CASE WHEN ISNULL(@isauto_spositiontaking_6, 0)>0 THEN @max_spositiontaking_6 ELSE @max_spositiontaking_6-@max_mapositiontaking_6 END
		SELECT @max_spositiontaking_9 = CASE WHEN ISNULL(@isauto_spositiontaking_9, 0)>0 THEN @max_spositiontaking_9 ELSE @max_spositiontaking_9-@max_mapositiontaking_9 END
		SELECT @max_spositiontaking_10 = CASE WHEN ISNULL(@isauto_spositiontaking_10, 0)>0 THEN @max_spositiontaking_10 ELSE @max_spositiontaking_10-@max_mapositiontaking_10 END
		
		-- Outright PT for sports
		SELECT @max_v2spositiontaking_10 = CASE WHEN ISNULL(@isauto_v2spositiontaking_10, 0)>0 THEN @max_v2spositiontaking_10 ELSE @max_v2spositiontaking_10-@max_v2mapositiontaking_10 END
		SELECT @max_v3spositiontaking_10 = CASE WHEN ISNULL(@isauto_v3spositiontaking_10, 0)>0 THEN @max_v3spositiontaking_10 ELSE @max_v3spositiontaking_10-@max_v3mapositiontaking_10 END
		SELECT @max_v5spositiontaking_10 = CASE WHEN ISNULL(@isauto_v5spositiontaking_10, 0)>0 THEN @max_v5spositiontaking_10 ELSE @max_v5spositiontaking_10-@max_v5mapositiontaking_10 END
		SELECT @max_v8spositiontaking_10 = CASE WHEN ISNULL(@isauto_v8spositiontaking_10, 0)>0 THEN @max_v8spositiontaking_10 ELSE @max_v8spositiontaking_10-@max_v8mapositiontaking_10 END
		SELECT @max_v10spositiontaking_10 = CASE WHEN ISNULL(@isauto_v10spositiontaking_10, 0)>0 THEN @max_v10spositiontaking_10 ELSE @max_v10spositiontaking_10-@max_v10mapositiontaking_10 END
		SELECT @max_v11spositiontaking_10 = CASE WHEN ISNULL(@isauto_v11spositiontaking_10, 0)>0 THEN @max_v11spositiontaking_10 ELSE @max_v11spositiontaking_10-@max_v11mapositiontaking_10 END
		SELECT @max_v99spositiontaking_10 = CASE WHEN ISNULL(@isauto_v99spositiontaking_10, 0)>0 THEN @max_v99spositiontaking_10 ELSE @max_v99spositiontaking_10-@max_v99mapositiontaking_10 END
		
		SELECT @max_spositiontaking_9999 = CASE WHEN ISNULL(@isauto_spositiontaking_9999, 0)>0 THEN @max_spositiontaking_9999 ELSE @max_spositiontaking_9999-@max_mapositiontaking_9999 END

		SELECT @max_v2spositiontaking_1 = CASE WHEN ISNULL(@isauto_v2spositiontaking_1, 0)>0 THEN @max_v2spositiontaking_1 ELSE @max_v2spositiontaking_1-@max_v2mapositiontaking_1 END
		SELECT @max_v2spositiontaking_2 = CASE WHEN ISNULL(@isauto_v2spositiontaking_2, 0)>0 THEN @max_v2spositiontaking_2 ELSE @max_v2spositiontaking_2-@max_v2mapositiontaking_2 END
		SELECT @max_v2spositiontaking_3 = CASE WHEN ISNULL(@isauto_v2spositiontaking_3, 0)>0 THEN @max_v2spositiontaking_3 ELSE @max_v2spositiontaking_3-@max_v2mapositiontaking_3 END
		SELECT @max_v2spositiontaking_7 = CASE WHEN ISNULL(@isauto_v2spositiontaking_7, 0)>0 THEN @max_v2spositiontaking_7 ELSE @max_v2spositiontaking_7-@max_v2mapositiontaking_7 END
		SELECT @max_v2spositiontaking_8 = CASE WHEN ISNULL(@isauto_v2spositiontaking_8, 0)>0 THEN @max_v2spositiontaking_8 ELSE @max_v2spositiontaking_8-@max_v2mapositiontaking_8 END
		--SELECT @max_v2spositiontaking_9 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9, 0)>0 THEN @max_v2spositiontaking_9 ELSE @max_v2spositiontaking_9-@max_v2mapositiontaking_9 END
		SELECT @max_v2spositiontaking_20 = CASE WHEN ISNULL(@isauto_v2spositiontaking_20, 0)>0 THEN @max_v2spositiontaking_20 ELSE @max_v2spositiontaking_20-@max_v2mapositiontaking_20 END
		SELECT @max_v2spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9999, 0)>0 THEN @max_v2spositiontaking_9999 ELSE @max_v2spositiontaking_9999-@max_v2mapositiontaking_9999 END

		SELECT @max_v3spositiontaking_1 = CASE WHEN ISNULL(@isauto_v3spositiontaking_1, 0)>0 THEN @max_v3spositiontaking_1 ELSE @max_v3spositiontaking_1-@max_v3mapositiontaking_1 END
		SELECT @max_v3spositiontaking_2 = CASE WHEN ISNULL(@isauto_v3spositiontaking_2, 0)>0 THEN @max_v3spositiontaking_2 ELSE @max_v3spositiontaking_2-@max_v3mapositiontaking_2 END
		SELECT @max_v3spositiontaking_3 = CASE WHEN ISNULL(@isauto_v3spositiontaking_3, 0)>0 THEN @max_v3spositiontaking_3 ELSE @max_v3spositiontaking_3-@max_v3mapositiontaking_3 END
		SELECT @max_v3spositiontaking_20 = CASE WHEN ISNULL(@isauto_v3spositiontaking_20, 0)>0 THEN @max_v3spositiontaking_20 ELSE @max_v3spositiontaking_20-@max_v3mapositiontaking_20 END

		SELECT @max_v5spositiontaking_1 = CASE WHEN ISNULL(@isauto_v5spositiontaking_1, 0)>0 THEN @max_v5spositiontaking_1 ELSE @max_v5spositiontaking_1-@max_v5mapositiontaking_1 END
		SELECT @max_v5spositiontaking_2 = CASE WHEN ISNULL(@isauto_v5spositiontaking_2, 0)>0 THEN @max_v5spositiontaking_2 ELSE @max_v5spositiontaking_2-@max_v5mapositiontaking_2 END
		SELECT @max_v5spositiontaking_3 = CASE WHEN ISNULL(@isauto_v5spositiontaking_3, 0)>0 THEN @max_v5spositiontaking_3 ELSE @max_v5spositiontaking_3-@max_v5mapositiontaking_3 END
		SELECT @max_v5spositiontaking_20 = CASE WHEN ISNULL(@isauto_v5spositiontaking_20, 0)>0 THEN @max_v5spositiontaking_20 ELSE @max_v5spositiontaking_20-@max_v5mapositiontaking_20 END
		SELECT @max_v5spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v5spositiontaking_9999, 0)>0 THEN @max_v5spositiontaking_9999 ELSE @max_v5spositiontaking_9999-@max_v5mapositiontaking_9999 END

		SELECT @max_v8spositiontaking_1 = CASE WHEN ISNULL(@isauto_v8spositiontaking_1, 0)>0 THEN @max_v8spositiontaking_1 ELSE @max_v8spositiontaking_1-@max_v8mapositiontaking_1 END
		SELECT @max_v8spositiontaking_3 = CASE WHEN ISNULL(@isauto_v8spositiontaking_3, 0)>0 THEN @max_v8spositiontaking_3 ELSE @max_v8spositiontaking_3-@max_v8mapositiontaking_3 END
		SELECT @max_v8spositiontaking_20 = CASE WHEN ISNULL(@isauto_v8spositiontaking_20, 0)>0 THEN @max_v8spositiontaking_20 ELSE @max_v8spositiontaking_20-@max_v8mapositiontaking_20 END

		SELECT @max_v10spositiontaking_1 = CASE WHEN ISNULL(@isauto_v10spositiontaking_1, 0)>0 THEN @max_v10spositiontaking_1 ELSE @max_v10spositiontaking_1-@max_v10mapositiontaking_1 END
		SELECT @max_v10spositiontaking_2 = CASE WHEN ISNULL(@isauto_v10spositiontaking_2, 0)>0 THEN @max_v10spositiontaking_2 ELSE @max_v10spositiontaking_2-@max_v10mapositiontaking_2 END
		SELECT @max_v10spositiontaking_3 = CASE WHEN ISNULL(@isauto_v10spositiontaking_3, 0)>0 THEN @max_v10spositiontaking_3 ELSE @max_v10spositiontaking_3-@max_v10mapositiontaking_3 END
		SELECT @max_v10spositiontaking_20 = CASE WHEN ISNULL(@isauto_v10spositiontaking_20, 0)>0 THEN @max_v10spositiontaking_20 ELSE @max_v10spositiontaking_20-@max_v10mapositiontaking_20 END

		SELECT @max_v11spositiontaking_1 = CASE WHEN ISNULL(@isauto_v11spositiontaking_1, 0)>0 THEN @max_v11spositiontaking_1 ELSE @max_v11spositiontaking_1-@max_v11mapositiontaking_1 END
		SELECT @max_v11spositiontaking_20 = CASE WHEN ISNULL(@isauto_v11spositiontaking_20, 0)>0 THEN @max_v11spositiontaking_20 ELSE @max_v11spositiontaking_20-@max_v11mapositiontaking_20 END

		SELECT @max_v99spositiontaking_1 = CASE WHEN ISNULL(@isauto_v99spositiontaking_1, 0)>0 THEN @max_v99spositiontaking_1 ELSE @max_v99spositiontaking_1-@max_v99mapositiontaking_1 END
		SELECT @max_v99spositiontaking_2 = CASE WHEN ISNULL(@isauto_v99spositiontaking_2, 0)>0 THEN @max_v99spositiontaking_2 ELSE @max_v99spositiontaking_2-@max_v99mapositiontaking_2 END
		SELECT @max_v99spositiontaking_3 = CASE WHEN ISNULL(@isauto_v99spositiontaking_3, 0)>0 THEN @max_v99spositiontaking_3 ELSE @max_v99spositiontaking_3-@max_v99mapositiontaking_3 END
		SELECT @max_v99spositiontaking_20 = CASE WHEN ISNULL(@isauto_v99spositiontaking_20, 0)>0 THEN @max_v99spositiontaking_20 ELSE @max_v99spositiontaking_20-@max_v99mapositiontaking_20 END
		SELECT @max_v99spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9999, 0)>0 THEN @max_v99spositiontaking_9999 ELSE @max_v99spositiontaking_9999-@max_v99mapositiontaking_9999 END
		-- mixed sports
		SELECT @max_v99spositiontaking_9 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9, 0)>0 THEN @max_v99spositiontaking_9 ELSE @max_v99spositiontaking_9-@max_v99mapositiontaking_9 END

		--s1=s1>maxs1?maxs1:s1
		SELECT @spositiontaking_1 = CASE WHEN @spositiontaking_1 > @max_spositiontaking_1 THEN @max_spositiontaking_1 ELSE @spositiontaking_1 END
		SELECT @spositiontaking_3 = CASE WHEN @spositiontaking_3 > @max_spositiontaking_3 THEN @max_spositiontaking_3 ELSE @spositiontaking_3 END
		SELECT @spositiontaking_7 = CASE WHEN @spositiontaking_7 > @max_spositiontaking_7 THEN @max_spositiontaking_7 ELSE @spositiontaking_7 END
		SELECT @spositiontaking_8 = CASE WHEN @spositiontaking_8 > @max_spositiontaking_8 THEN @max_spositiontaking_8 ELSE @spositiontaking_8 END

		SELECT @slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1 > @max_slivepositiontaking_1 THEN @max_slivepositiontaking_1 ELSE @slivepositiontaking_1 END
		SELECT @slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3 > @max_slivepositiontaking_3 THEN @max_slivepositiontaking_3 ELSE @slivepositiontaking_3 END
		SELECT @slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7 > @max_slivepositiontaking_7 THEN @max_slivepositiontaking_7 ELSE @slivepositiontaking_7 END
		SELECT @slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8 > @max_slivepositiontaking_8 THEN @max_slivepositiontaking_8 ELSE @slivepositiontaking_8 END

		SELECT @spositiontaking_2 = CASE WHEN @spositiontaking_2 > @max_spositiontaking_2 THEN @max_spositiontaking_2 ELSE @spositiontaking_2 END
		SELECT @spositiontaking_4 = CASE WHEN @spositiontaking_4 > @max_spositiontaking_4 THEN @max_spositiontaking_4 ELSE @spositiontaking_4 END
		SELECT @spositiontaking_5 = CASE WHEN @spositiontaking_5 > @max_spositiontaking_5 THEN @max_spositiontaking_5 ELSE @spositiontaking_5 END
		SELECT @spositiontaking_6 = CASE WHEN @spositiontaking_6 > @max_spositiontaking_6 THEN @max_spositiontaking_6 ELSE @spositiontaking_6 END
		SELECT @spositiontaking_9 = CASE WHEN @spositiontaking_9 > @max_spositiontaking_9 THEN @max_spositiontaking_9 ELSE @spositiontaking_9 END
		SELECT @spositiontaking_10 = CASE WHEN @spositiontaking_10 > @max_spositiontaking_10 THEN @max_spositiontaking_10 ELSE @spositiontaking_10 END
		-- Outright PT for sports
		SELECT @v2spositiontaking_10 = CASE WHEN @v2spositiontaking_10 > @max_v2spositiontaking_10 THEN @max_v2spositiontaking_10 ELSE @v2spositiontaking_10 END
		SELECT @v3spositiontaking_10 = CASE WHEN @v3spositiontaking_10 > @max_v3spositiontaking_10 THEN @max_v3spositiontaking_10 ELSE @v3spositiontaking_10 END
		SELECT @v5spositiontaking_10 = CASE WHEN @v5spositiontaking_10 > @max_v5spositiontaking_10 THEN @max_v5spositiontaking_10 ELSE @v5spositiontaking_10 END
		SELECT @v8spositiontaking_10 = CASE WHEN @v8spositiontaking_10 > @max_v8spositiontaking_10 THEN @max_v8spositiontaking_10 ELSE @v8spositiontaking_10 END
		SELECT @v10spositiontaking_10 = CASE WHEN @v10spositiontaking_10 > @max_v10spositiontaking_10 THEN @max_v10spositiontaking_10 ELSE @v10spositiontaking_10 END
		SELECT @v11spositiontaking_10 = CASE WHEN @v11spositiontaking_10 > @max_v11spositiontaking_10 THEN @max_v11spositiontaking_10 ELSE @v11spositiontaking_10 END
		SELECT @v99spositiontaking_10 = CASE WHEN @v99spositiontaking_10 > @max_v99spositiontaking_10 THEN @max_v99spositiontaking_10 ELSE @v99spositiontaking_10 END
		
		SELECT @spositiontaking_9999 = CASE WHEN @spositiontaking_9999 > @max_spositiontaking_9999 THEN @max_spositiontaking_9999 ELSE @spositiontaking_9999 END

		SELECT @v2spositiontaking_1 = CASE WHEN @v2spositiontaking_1 > @max_v2spositiontaking_1 THEN @max_v2spositiontaking_1 ELSE @v2spositiontaking_1 END
		SELECT @v2spositiontaking_2 = CASE WHEN @v2spositiontaking_2 > @max_v2spositiontaking_2 THEN @max_v2spositiontaking_2 ELSE @v2spositiontaking_2 END
		SELECT @v2spositiontaking_3 = CASE WHEN @v2spositiontaking_3 > @max_v2spositiontaking_3 THEN @max_v2spositiontaking_3 ELSE @v2spositiontaking_3 END
		SELECT @v2spositiontaking_7 = CASE WHEN @v2spositiontaking_7 > @max_v2spositiontaking_7 THEN @max_v2spositiontaking_7 ELSE @v2spositiontaking_7 END
		SELECT @v2spositiontaking_8 = CASE WHEN @v2spositiontaking_8 > @max_v2spositiontaking_8 THEN @max_v2spositiontaking_8 ELSE @v2spositiontaking_8 END
		--SELECT @v2spositiontaking_9 = CASE WHEN @v2spositiontaking_9 > @max_v2spositiontaking_9 THEN @max_v2spositiontaking_9 ELSE @v2spositiontaking_9 END
		SELECT @v2spositiontaking_20 = CASE WHEN @v2spositiontaking_20 > @max_v2spositiontaking_20 THEN @max_v2spositiontaking_20 ELSE @v2spositiontaking_20 END
		SELECT @v2spositiontaking_9999 = CASE WHEN @v2spositiontaking_9999 > @max_v2spositiontaking_9999 THEN @max_v2spositiontaking_9999 ELSE @v2spositiontaking_9999 END

		SELECT @v3spositiontaking_1 = CASE WHEN @v3spositiontaking_1 > @max_v3spositiontaking_1 THEN @max_v3spositiontaking_1 ELSE @v3spositiontaking_1 END
		SELECT @v3spositiontaking_2 = CASE WHEN @v3spositiontaking_2 > @max_v3spositiontaking_2 THEN @max_v3spositiontaking_2 ELSE @v3spositiontaking_2 END
		SELECT @v3spositiontaking_3 = CASE WHEN @v3spositiontaking_3 > @max_v3spositiontaking_3 THEN @max_v3spositiontaking_3 ELSE @v3spositiontaking_3 END
		SELECT @v3spositiontaking_20 = CASE WHEN @v3spositiontaking_20 > @max_v3spositiontaking_20 THEN @max_v3spositiontaking_20 ELSE @v3spositiontaking_20 END

		SELECT @v5spositiontaking_1 = CASE WHEN @v5spositiontaking_1 > @max_v5spositiontaking_1 THEN @max_v5spositiontaking_1 ELSE @v5spositiontaking_1 END
		SELECT @v5spositiontaking_2 = CASE WHEN @v5spositiontaking_2 > @max_v5spositiontaking_2 THEN @max_v5spositiontaking_2 ELSE @v5spositiontaking_2 END
		SELECT @v5spositiontaking_3 = CASE WHEN @v5spositiontaking_3 > @max_v5spositiontaking_3 THEN @max_v5spositiontaking_3 ELSE @v5spositiontaking_3 END
		SELECT @v5spositiontaking_20 = CASE WHEN @v5spositiontaking_20 > @max_v5spositiontaking_20 THEN @max_v5spositiontaking_20 ELSE @v5spositiontaking_20 END
		SELECT @v5spositiontaking_9999 = CASE WHEN @v5spositiontaking_9999 > @max_v5spositiontaking_9999 THEN @max_v5spositiontaking_9999 ELSE @v5spositiontaking_9999 END

		SELECT @v8spositiontaking_1 = CASE WHEN @v8spositiontaking_1 > @max_v8spositiontaking_1 THEN @max_v8spositiontaking_1 ELSE @v8spositiontaking_1 END
		SELECT @v8spositiontaking_3 = CASE WHEN @v8spositiontaking_3 > @max_v8spositiontaking_3 THEN @max_v8spositiontaking_3 ELSE @v8spositiontaking_3 END
		SELECT @v8spositiontaking_20 = CASE WHEN @v8spositiontaking_20 > @max_v8spositiontaking_20 THEN @max_v8spositiontaking_20 ELSE @v8spositiontaking_20 END

		SELECT @v10spositiontaking_1 = CASE WHEN @v10spositiontaking_1 > @max_v10spositiontaking_1 THEN @max_v10spositiontaking_1 ELSE @v10spositiontaking_1 END
		SELECT @v10spositiontaking_2 = CASE WHEN @v10spositiontaking_2 > @max_v10spositiontaking_2 THEN @max_v10spositiontaking_2 ELSE @v10spositiontaking_2 END
		SELECT @v10spositiontaking_3 = CASE WHEN @v10spositiontaking_3 > @max_v10spositiontaking_3 THEN @max_v10spositiontaking_3 ELSE @v10spositiontaking_3 END
		SELECT @v10spositiontaking_20 = CASE WHEN @v10spositiontaking_20 > @max_v10spositiontaking_20 THEN @max_v10spositiontaking_20 ELSE @v10spositiontaking_20 END

		SELECT @v11spositiontaking_1 = CASE WHEN @v11spositiontaking_1 > @max_v11spositiontaking_1 THEN @max_v11spositiontaking_1 ELSE @v11spositiontaking_1 END
		SELECT @v11spositiontaking_20 = CASE WHEN @v11spositiontaking_20 > @max_v11spositiontaking_20 THEN @max_v11spositiontaking_20 ELSE @v11spositiontaking_20 END

		SELECT @v99spositiontaking_1 = CASE WHEN @v99spositiontaking_1 > @max_v99spositiontaking_1 THEN @max_v99spositiontaking_1 ELSE @v99spositiontaking_1 END
		SELECT @v99spositiontaking_2 = CASE WHEN @v99spositiontaking_2 > @max_v99spositiontaking_2 THEN @max_v99spositiontaking_2 ELSE @v99spositiontaking_2 END
		SELECT @v99spositiontaking_3 = CASE WHEN @v99spositiontaking_3 > @max_v99spositiontaking_3 THEN @max_v99spositiontaking_3 ELSE @v99spositiontaking_3 END
		SELECT @v99spositiontaking_20 = CASE WHEN @v99spositiontaking_20 > @max_v99spositiontaking_20 THEN @max_v99spositiontaking_20 ELSE @v99spositiontaking_20 END
		SELECT @v99spositiontaking_9999 = CASE WHEN @v99spositiontaking_9999 > @max_v99spositiontaking_9999 THEN @max_v99spositiontaking_9999 ELSE @v99spositiontaking_9999 END
		-- mixed sports
		SELECT @v99spositiontaking_9 = CASE WHEN @v99spositiontaking_9 > @max_v99spositiontaking_9 
											THEN @max_v99spositiontaking_9 
											ELSE @v99spositiontaking_9 
										END

		--- 20131030@Johnson: Apply execrep when update pt on member
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''

			EXEC dbo.Acc_CustSetting_08
			@custid = @custid,
			@roleid = 3,
			
			@mpositiontaking_1 = @mpositiontaking_1,
			@mpositiontaking_2 = @mpositiontaking_2,
			@mpositiontaking_3 = @mpositiontaking_3,
			@mpositiontaking_4 = @mpositiontaking_4,
			@mpositiontaking_5 = @mpositiontaking_5,
			@mpositiontaking_6 = @mpositiontaking_6,
			@mpositiontaking_7 = @mpositiontaking_7,
			@mpositiontaking_8 = @mpositiontaking_8,
			@mpositiontaking_9 = @mpositiontaking_9,
			@mpositiontaking_10 = @mpositiontaking_10,
			@mpositiontaking_9999 = @mpositiontaking_9999,

			@mlivepositiontaking_1 = @mlivepositiontaking_1,
			@mlivepositiontaking_3 = @mlivepositiontaking_3,
			@mlivepositiontaking_7 = @mlivepositiontaking_7,
			@mlivepositiontaking_8 = @mlivepositiontaking_8,
			
			@v2mpositiontaking_1 = @v2mpositiontaking_1,
			@v2mpositiontaking_2 = @v2mpositiontaking_2,
			@v2mpositiontaking_3 = @v2mpositiontaking_3,
			@v2mpositiontaking_7 = @v2mpositiontaking_7,
			@v2mpositiontaking_8 = @v2mpositiontaking_8,
		--	@v2mpositiontaking_9 = @v2mpositiontaking_9,
			@v2mpositiontaking_20 = @v2mpositiontaking_20,
			@v2mpositiontaking_9999 = @v2mpositiontaking_9999,

			@v3mpositiontaking_1 = @v3mpositiontaking_1,
			@v3mpositiontaking_2 = @v3mpositiontaking_2,
			@v3mpositiontaking_3 = @v3mpositiontaking_3,
			@v3mpositiontaking_20 = @v3mpositiontaking_20,

			@v5mpositiontaking_1 = @v5mpositiontaking_1,
			@v5mpositiontaking_2 = @v5mpositiontaking_2,
			@v5mpositiontaking_3 = @v5mpositiontaking_3,
			@v5mpositiontaking_20 = @v5mpositiontaking_20,
			@v5mpositiontaking_9999 = @v5mpositiontaking_9999,

			@v8mpositiontaking_1 = @v8mpositiontaking_1,
			@v8mpositiontaking_3 = @v8mpositiontaking_3,
			@v8mpositiontaking_20 = @v8mpositiontaking_20,

			@v10mpositiontaking_1 = @v10mpositiontaking_1,
			@v10mpositiontaking_2 = @v10mpositiontaking_2,
			@v10mpositiontaking_3 = @v10mpositiontaking_3,
			@v10mpositiontaking_20 = @v10mpositiontaking_20,

			@v11mpositiontaking_1 = @v11mpositiontaking_1,
			@v11mpositiontaking_20 = @v11mpositiontaking_20,

			@v99mpositiontaking_1 = @v99mpositiontaking_1,
			@v99mpositiontaking_2 = @v99mpositiontaking_2,
			@v99mpositiontaking_3 = @v99mpositiontaking_3,
			@v99mpositiontaking_20 = @v99mpositiontaking_20,
			@v99mpositiontaking_9999 = @v99mpositiontaking_9999,
			-- mixed sports
			@v99mpositiontaking_9  = @v99mpositiontaking_9,

			
			@spositiontaking_1 = @spositiontaking_1,
			@spositiontaking_2 = @spositiontaking_2,
			@spositiontaking_3 = @spositiontaking_3,
			@spositiontaking_4 = @spositiontaking_4,
			@spositiontaking_5 = @spositiontaking_5,
			@spositiontaking_6 = @spositiontaking_6,
			@spositiontaking_7 = @spositiontaking_7,
			@spositiontaking_8 = @spositiontaking_8,
			@spositiontaking_9 = @spositiontaking_9,
			@spositiontaking_10 = @spositiontaking_10,
			@spositiontaking_9999 = @spositiontaking_9999,
			
			@slivepositiontaking_1 = @slivepositiontaking_1,
			@slivepositiontaking_3 = @slivepositiontaking_3,
			@slivepositiontaking_7 = @slivepositiontaking_7,
			@slivepositiontaking_8 = @slivepositiontaking_8,
			
			@v2spositiontaking_1 = @v2spositiontaking_1,
			@v2spositiontaking_2 = @v2spositiontaking_2,
			@v2spositiontaking_3 = @v2spositiontaking_3,
			@v2spositiontaking_7 = @v2spositiontaking_7,
			@v2spositiontaking_8 = @v2spositiontaking_8,
		--	@v2spositiontaking_9 = @v2spositiontaking_9,
			@v2spositiontaking_20 = @v2spositiontaking_20,
			@v2spositiontaking_9999 = @v2spositiontaking_9999,

			@v3spositiontaking_1 = @v3spositiontaking_1,
			@v3spositiontaking_2 = @v3spositiontaking_2,
			@v3spositiontaking_3 = @v3spositiontaking_3,
			@v3spositiontaking_20 = @v3spositiontaking_20,

			@v5spositiontaking_1 = @v5spositiontaking_1,
			@v5spositiontaking_2 = @v5spositiontaking_2,
			@v5spositiontaking_3 = @v5spositiontaking_3,
			@v5spositiontaking_20 = @v5spositiontaking_20,
			@v5spositiontaking_9999 = @v5spositiontaking_9999,

			@v8spositiontaking_1 = @v8spositiontaking_1,
			@v8spositiontaking_3 = @v8spositiontaking_3,
			@v8spositiontaking_20 = @v8spositiontaking_20,

			@v10spositiontaking_1 = @v10spositiontaking_1,
			@v10spositiontaking_2 = @v10spositiontaking_2,
			@v10spositiontaking_3 = @v10spositiontaking_3,
			@v10spositiontaking_20 = @v10spositiontaking_20,

			@v11spositiontaking_1 = @v11spositiontaking_1,
			@v11spositiontaking_20 = @v11spositiontaking_20,

			@v99spositiontaking_1 = @v99spositiontaking_1,
			@v99spositiontaking_2 = @v99spositiontaking_2,
			@v99spositiontaking_3 = @v99spositiontaking_3,
			@v99spositiontaking_20 = @v99spositiontaking_20,	
			@v99spositiontaking_9999 = @v99spositiontaking_9999,	
			-- mixed sports
			@v99spositiontaking_9 = @v99spositiontaking_9,



			@UpdateMultiple = @UpdateMultiple,
			@UpdatePositiontaking = @UpdatePositiontaking,
			@UpdatePositiontakingv2 = @UpdatePositiontakingv2,
			@UpdatePositiontakingv3 = @UpdatePositiontakingv3,
			@UpdatePositiontakingv5 = @UpdatePositiontakingv5,
			@UpdatePositiontakingv8 = @UpdatePositiontakingv8,
			@UpdatePositiontakingv10 = @UpdatePositiontakingv10,
			@UpdatePositiontakingv11 = @UpdatePositiontakingv11,
			@UpdatePositiontakingv99 = @UpdatePositiontakingv99,
			@UpdatePositiontakingv99MP = @UpdatePositiontakingv99MP,
		
			
			-- Outright PT for sports
			@v2mpositiontaking_10 = @v2mpositiontaking_10,
			@v3mpositiontaking_10 = @v3mpositiontaking_10,
			@v5mpositiontaking_10 = @v5mpositiontaking_10,
			@v8mpositiontaking_10 = @v8mpositiontaking_10,
			@v10mpositiontaking_10 = @v10mpositiontaking_10,
			@v11mpositiontaking_10 = @v11mpositiontaking_10,
			@v99mpositiontaking_10 = @v99mpositiontaking_10,
			
			@v2spositiontaking_10 = @v2spositiontaking_10,
			@v3spositiontaking_10 = @v3spositiontaking_10,
			@v5spositiontaking_10 = @v5spositiontaking_10,
			@v8spositiontaking_10 = @v8spositiontaking_10,
			@v10spositiontaking_10 = @v10spositiontaking_10,
			@v11spositiontaking_10 = @v11spositiontaking_10,
			@v99spositiontaking_10 = @v99spositiontaking_10				
			
	
		EXEC dbo.Acc_CustSetting_09
			@custid = @custid,
			@roleid = 3,
			
			@auto_mpositiontaking_mem_1 = @auto_mpositiontaking_mem_1,
			@auto_mpositiontaking_mem_2 = @auto_mpositiontaking_mem_2,
			@auto_mpositiontaking_mem_3 = @auto_mpositiontaking_mem_3,
			@auto_mpositiontaking_mem_4 = @auto_mpositiontaking_mem_4,
			@auto_mpositiontaking_mem_5 = @auto_mpositiontaking_mem_5,
			@auto_mpositiontaking_mem_6 = @auto_mpositiontaking_mem_6,
			@auto_mpositiontaking_mem_7 = @auto_mpositiontaking_mem_7,
			@auto_mpositiontaking_mem_8 = @auto_mpositiontaking_mem_8,
			@auto_mpositiontaking_mem_9 = @auto_mpositiontaking_mem_9,
			@auto_mpositiontaking_mem_10 = @auto_mpositiontaking_mem_10,
			
			-- Outright PT for sports
			@auto_v2mpositiontaking_mem_10 = @auto_v2mpositiontaking_mem_10,
			@auto_v3mpositiontaking_mem_10 = @auto_v3mpositiontaking_mem_10,
			@auto_v5mpositiontaking_mem_10 = @auto_v5mpositiontaking_mem_10,
			@auto_v8mpositiontaking_mem_10 = @auto_v8mpositiontaking_mem_10,
			@auto_v10mpositiontaking_mem_10 = @auto_v10mpositiontaking_mem_10,
			@auto_v11mpositiontaking_mem_10 = @auto_v11mpositiontaking_mem_10,
			@auto_v99mpositiontaking_mem_10 = @auto_v99mpositiontaking_mem_10,
			
			@auto_mpositiontaking_mem_9999 = @auto_mpositiontaking_mem_9999,

			@auto_mlivepositiontaking_mem_1 = @auto_mlivepositiontaking_mem_1,
			@auto_mlivepositiontaking_mem_3 = @auto_mlivepositiontaking_mem_3,
			@auto_mlivepositiontaking_mem_7 = @auto_mlivepositiontaking_mem_7,
			@auto_mlivepositiontaking_mem_8 = @auto_mlivepositiontaking_mem_8,
			
			@auto_v2mpositiontaking_mem_1 = @auto_v2mpositiontaking_mem_1,
			@auto_v2mpositiontaking_mem_2 = @auto_v2mpositiontaking_mem_2,
			@auto_v2mpositiontaking_mem_3 = @auto_v2mpositiontaking_mem_3,
			@auto_v2mpositiontaking_mem_7 = @auto_v2mpositiontaking_mem_7,
			@auto_v2mpositiontaking_mem_8 = @auto_v2mpositiontaking_mem_8,
		--	@auto_v2mpositiontaking_mem_9 = @auto_v2mpositiontaking_mem_9,
			@auto_v2mpositiontaking_mem_20 = @auto_v2mpositiontaking_mem_20,
			@auto_v2mpositiontaking_mem_9999 = @auto_v2mpositiontaking_mem_9999,
			
			@auto_v3mpositiontaking_mem_1 = @auto_v3mpositiontaking_mem_1,
			@auto_v3mpositiontaking_mem_2 = @auto_v3mpositiontaking_mem_2,
			@auto_v3mpositiontaking_mem_3 = @auto_v3mpositiontaking_mem_3,
			@auto_v3mpositiontaking_mem_20 = @auto_v3mpositiontaking_mem_20,
			
			@auto_v5mpositiontaking_mem_1 = @auto_v5mpositiontaking_mem_1,
			@auto_v5mpositiontaking_mem_2 = @auto_v5mpositiontaking_mem_2,
			@auto_v5mpositiontaking_mem_3 = @auto_v5mpositiontaking_mem_3,
			@auto_v5mpositiontaking_mem_20 = @auto_v5mpositiontaking_mem_20,
			@auto_v5mpositiontaking_mem_9999 = @auto_v5mpositiontaking_mem_9999,
			
			@auto_v8mpositiontaking_mem_1 = @auto_v8mpositiontaking_mem_1,
			@auto_v8mpositiontaking_mem_3 = @auto_v8mpositiontaking_mem_3,
			@auto_v8mpositiontaking_mem_20 = @auto_v8mpositiontaking_mem_20,

			@auto_v10mpositiontaking_mem_1 = @auto_v10mpositiontaking_mem_1,
			@auto_v10mpositiontaking_mem_2 = @auto_v10mpositiontaking_mem_2,
			@auto_v10mpositiontaking_mem_3 = @auto_v10mpositiontaking_mem_3,
			@auto_v10mpositiontaking_mem_20 = @auto_v10mpositiontaking_mem_20,

			@auto_v11mpositiontaking_mem_1 = @auto_v11mpositiontaking_mem_1,
			@auto_v11mpositiontaking_mem_20 = @auto_v11mpositiontaking_mem_20,

			@auto_v99mpositiontaking_mem_1 = @auto_v99mpositiontaking_mem_1,
			@auto_v99mpositiontaking_mem_2 = @auto_v99mpositiontaking_mem_2,
			@auto_v99mpositiontaking_mem_3 = @auto_v99mpositiontaking_mem_3,
			@auto_v99mpositiontaking_mem_20 = @auto_v99mpositiontaking_mem_20,
			@auto_v99mpositiontaking_mem_9999 = @auto_v99mpositiontaking_mem_9999,
			-- mixed sprots
			@auto_v99mpositiontaking_mem_9 = @auto_v99mpositiontaking_mem_9,
		
			
			@isauto_mpositiontaking_mem_1 = @isauto_mpositiontaking_mem_1,
			@isauto_mpositiontaking_mem_2 = @isauto_mpositiontaking_mem_2,
			@isauto_mpositiontaking_mem_3 = @isauto_mpositiontaking_mem_3,
			@isauto_mpositiontaking_mem_4 = @isauto_mpositiontaking_mem_4,
			@isauto_mpositiontaking_mem_5 = @isauto_mpositiontaking_mem_5,
			@isauto_mpositiontaking_mem_6 = @isauto_mpositiontaking_mem_6,
			@isauto_mpositiontaking_mem_7 = @isauto_mpositiontaking_mem_7,
			@isauto_mpositiontaking_mem_8 = @isauto_mpositiontaking_mem_8,
			@isauto_mpositiontaking_mem_9 = @isauto_mpositiontaking_mem_9,
			@isauto_mpositiontaking_mem_10 = @isauto_mpositiontaking_mem_10,
			
			-- Outright PT for sports
			@isauto_v2mpositiontaking_mem_10 = @isauto_v2mpositiontaking_mem_10,
			@isauto_v3mpositiontaking_mem_10 = @isauto_v3mpositiontaking_mem_10,
			@isauto_v5mpositiontaking_mem_10 = @isauto_v5mpositiontaking_mem_10,
			@isauto_v8mpositiontaking_mem_10 = @isauto_v8mpositiontaking_mem_10,
			@isauto_v10mpositiontaking_mem_10 = @isauto_v10mpositiontaking_mem_10,
			@isauto_v11mpositiontaking_mem_10 = @isauto_v11mpositiontaking_mem_10,
			@isauto_v99mpositiontaking_mem_10 = @isauto_v99mpositiontaking_mem_10,
			
			
			@isauto_mpositiontaking_mem_9999 = @isauto_mpositiontaking_mem_9999,

			@isauto_mlivepositiontaking_mem_1 = @isauto_mlivepositiontaking_mem_1,
			@isauto_mlivepositiontaking_mem_3 = @isauto_mlivepositiontaking_mem_3,
			@isauto_mlivepositiontaking_mem_7 = @isauto_mlivepositiontaking_mem_7,
			@isauto_mlivepositiontaking_mem_8 = @isauto_mlivepositiontaking_mem_8,

			@isauto_v2mpositiontaking_mem_1 = @isauto_v2mpositiontaking_mem_1,
			@isauto_v2mpositiontaking_mem_2 = @isauto_v2mpositiontaking_mem_2,
			@isauto_v2mpositiontaking_mem_3 = @isauto_v2mpositiontaking_mem_3,
			@isauto_v2mpositiontaking_mem_7 = @isauto_v2mpositiontaking_mem_7,
			@isauto_v2mpositiontaking_mem_8 = @isauto_v2mpositiontaking_mem_8,
		--	@isauto_v2mpositiontaking_mem_9 = @isauto_v2mpositiontaking_mem_9,
			@isauto_v2mpositiontaking_mem_20 = @isauto_v2mpositiontaking_mem_20,
			@isauto_v2mpositiontaking_mem_9999 = @isauto_v2mpositiontaking_mem_9999,

			@isauto_v3mpositiontaking_mem_1 = @isauto_v3mpositiontaking_mem_1,
			@isauto_v3mpositiontaking_mem_2 = @isauto_v3mpositiontaking_mem_2,
			@isauto_v3mpositiontaking_mem_3 = @isauto_v3mpositiontaking_mem_3,
			@isauto_v3mpositiontaking_mem_20 = @isauto_v3mpositiontaking_mem_20,

			@isauto_v5mpositiontaking_mem_1 = @isauto_v5mpositiontaking_mem_1,
			@isauto_v5mpositiontaking_mem_2 = @isauto_v5mpositiontaking_mem_2,
			@isauto_v5mpositiontaking_mem_3 = @isauto_v5mpositiontaking_mem_3,
			@isauto_v5mpositiontaking_mem_20 = @isauto_v5mpositiontaking_mem_20,
			@isauto_v5mpositiontaking_mem_9999 = @isauto_v5mpositiontaking_mem_9999,

			@isauto_v8mpositiontaking_mem_1 = @isauto_v8mpositiontaking_mem_1,
			@isauto_v8mpositiontaking_mem_3 = @isauto_v8mpositiontaking_mem_3,
			@isauto_v8mpositiontaking_mem_20 = @isauto_v8mpositiontaking_mem_20,

			@isauto_v10mpositiontaking_mem_1 = @isauto_v10mpositiontaking_mem_1,
			@isauto_v10mpositiontaking_mem_2 = @isauto_v10mpositiontaking_mem_2,
			@isauto_v10mpositiontaking_mem_3 = @isauto_v10mpositiontaking_mem_3,
			@isauto_v10mpositiontaking_mem_20 = @isauto_v10mpositiontaking_mem_20,

			@isauto_v11mpositiontaking_mem_1 = @isauto_v11mpositiontaking_mem_1,
			@isauto_v11mpositiontaking_mem_20 = @isauto_v11mpositiontaking_mem_20,

			@isauto_v99mpositiontaking_mem_1 = @isauto_v99mpositiontaking_mem_1,
			@isauto_v99mpositiontaking_mem_2 = @isauto_v99mpositiontaking_mem_2,
			@isauto_v99mpositiontaking_mem_3 = @isauto_v99mpositiontaking_mem_3,
			@isauto_v99mpositiontaking_mem_20 = @isauto_v99mpositiontaking_mem_20,
			@isauto_v99mpositiontaking_mem_9999 = @isauto_v99mpositiontaking_mem_9999,
			-- mixed sports
			@isauto_v99mpositiontaking_mem_9 = @isauto_v99mpositiontaking_mem_9		
			
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	ELSE
	BEGIN
		Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
	END

		 
	SELECT @mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_1 ELSE @mpositiontaking_1 END,
		@mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_2 ELSE @mpositiontaking_2 END,
		@mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_3 ELSE @mpositiontaking_3 END,
		@mpositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_4 ELSE @mpositiontaking_4 END,
		@mpositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_5 ELSE @mpositiontaking_5 END,
		@mpositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_6 ELSE @mpositiontaking_6 END,
		@mpositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_7 ELSE @mpositiontaking_7 END,
		@mpositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_8 ELSE @mpositiontaking_8 END,
		@mpositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_9 ELSE @mpositiontaking_9 END,
		@mpositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_mpositiontaking_10 ELSE @mpositiontaking_10 END,
		
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
				
		--im1
		@isauto_mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_1 ELSE @isauto_mpositiontaking_mem_1 END,
		@isauto_mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_2 ELSE @isauto_mpositiontaking_mem_2 END,
		@isauto_mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_3 ELSE @isauto_mpositiontaking_mem_3 END,
		@isauto_mpositiontaking_mem_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_4 ELSE @isauto_mpositiontaking_mem_4 END,
		@isauto_mpositiontaking_mem_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_5 ELSE @isauto_mpositiontaking_mem_5 END,
		@isauto_mpositiontaking_mem_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_6 ELSE @isauto_mpositiontaking_mem_6 END,
		@isauto_mpositiontaking_mem_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_7 ELSE @isauto_mpositiontaking_mem_7 END,
		@isauto_mpositiontaking_mem_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_8 ELSE @isauto_mpositiontaking_mem_8 END,
		@isauto_mpositiontaking_mem_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_9 ELSE @isauto_mpositiontaking_mem_9 END,
		@isauto_mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_10 ELSE @isauto_mpositiontaking_mem_10 END,
		
		-- Outright PT for sports
		@isauto_v2mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_10 ELSE @isauto_v2mpositiontaking_mem_10 END,
		@isauto_v3mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_mem_10 ELSE @isauto_v3mpositiontaking_mem_10 END,
		@isauto_v5mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_mem_10 ELSE @isauto_v5mpositiontaking_mem_10 END,
		@isauto_v8mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_mem_10 ELSE @isauto_v8mpositiontaking_mem_10 END,
		@isauto_v10mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_mem_10 ELSE @isauto_v10mpositiontaking_mem_10 END,
		@isauto_v11mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11mpositiontaking_mem_10 ELSE @isauto_v11mpositiontaking_mem_10 END,
		@isauto_v99mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_mem_10 ELSE @isauto_v99mpositiontaking_mem_10 END,
		
		@isauto_mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_mem_9999 ELSE @isauto_mpositiontaking_mem_9999 END,
		@isauto_mlivepositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_mem_1 ELSE @isauto_mlivepositiontaking_mem_1 END,
		@isauto_mlivepositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_mem_3 ELSE @isauto_mlivepositiontaking_mem_3 END,
		@isauto_mlivepositiontaking_mem_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_mem_7 ELSE @isauto_mlivepositiontaking_mem_7 END,
		@isauto_mlivepositiontaking_mem_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_mem_8 ELSE @isauto_mlivepositiontaking_mem_8 END,
		
		--um1
		@auto_mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_1 ELSE @auto_mpositiontaking_mem_1 END,
		@auto_mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_2 ELSE @auto_mpositiontaking_mem_2 END,
		@auto_mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_3 ELSE @auto_mpositiontaking_mem_3 END,
		@auto_mpositiontaking_mem_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_4 ELSE @auto_mpositiontaking_mem_4 END,
		@auto_mpositiontaking_mem_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_5 ELSE @auto_mpositiontaking_mem_5 END,
		@auto_mpositiontaking_mem_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_6 ELSE @auto_mpositiontaking_mem_6 END,
		@auto_mpositiontaking_mem_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_7 ELSE @auto_mpositiontaking_mem_7 END,
		@auto_mpositiontaking_mem_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_8 ELSE @auto_mpositiontaking_mem_8 END,
		@auto_mpositiontaking_mem_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_9 ELSE @auto_mpositiontaking_mem_9 END,
		@auto_mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_10 ELSE @auto_mpositiontaking_mem_10 END,
		
		-- Outright PT for sports
		@auto_v2mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_10 ELSE @auto_v2mpositiontaking_mem_10 END,
		@auto_v3mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3mpositiontaking_mem_10 ELSE @auto_v3mpositiontaking_mem_10 END,
		@auto_v5mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5mpositiontaking_mem_10 ELSE @auto_v5mpositiontaking_mem_10 END,
		@auto_v8mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8mpositiontaking_mem_10 ELSE @auto_v8mpositiontaking_mem_10 END,
		@auto_v10mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10mpositiontaking_mem_10 ELSE @auto_v10mpositiontaking_mem_10 END,
		@auto_v11mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11mpositiontaking_mem_10 ELSE @auto_v11mpositiontaking_mem_10 END,
		@auto_v99mpositiontaking_mem_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99mpositiontaking_mem_10 ELSE @auto_v99mpositiontaking_mem_10 END,
		
		@auto_mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mpositiontaking_mem_9999 ELSE @auto_mpositiontaking_mem_9999 END,
		@auto_mlivepositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mlivepositiontaking_mem_1 ELSE @auto_mlivepositiontaking_mem_1 END,
		@auto_mlivepositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mlivepositiontaking_mem_3 ELSE @auto_mlivepositiontaking_mem_3 END,
		@auto_mlivepositiontaking_mem_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mlivepositiontaking_mem_7 ELSE @auto_mlivepositiontaking_mem_7 END,
		@auto_mlivepositiontaking_mem_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_mlivepositiontaking_mem_8 ELSE @auto_mlivepositiontaking_mem_8 END,
		
		@v2mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_1 ELSE @v2mpositiontaking_1 END,
		@v2mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_2 ELSE @v2mpositiontaking_2 END,
		@v2mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_3 ELSE @v2mpositiontaking_3 END,
		@v2mpositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_7 ELSE @v2mpositiontaking_7 END,
		@v2mpositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_8 ELSE @v2mpositiontaking_8 END,	
		@v2mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_20 ELSE @v2mpositiontaking_20 END,
		@v2mpositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2mpositiontaking_9999 ELSE @v2mpositiontaking_9999 END,
	
		@isauto_v2mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_1 ELSE @isauto_v2mpositiontaking_mem_1 END,
		@isauto_v2mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_2 ELSE @isauto_v2mpositiontaking_mem_2 END,
		@isauto_v2mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_3 ELSE @isauto_v2mpositiontaking_mem_3 END,
		@isauto_v2mpositiontaking_mem_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_7 ELSE @isauto_v2mpositiontaking_mem_7 END,
		@isauto_v2mpositiontaking_mem_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_8 ELSE @isauto_v2mpositiontaking_mem_8 END,	
		@isauto_v2mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_20 ELSE @isauto_v2mpositiontaking_mem_20 END,
		@isauto_v2mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_mem_9999 ELSE @isauto_v2mpositiontaking_mem_9999 END,
		
		@auto_v2mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_1 ELSE @auto_v2mpositiontaking_mem_1 END,
		@auto_v2mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_2 ELSE @auto_v2mpositiontaking_mem_2 END,
		@auto_v2mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_3 ELSE @auto_v2mpositiontaking_mem_3 END,
		@auto_v2mpositiontaking_mem_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_7 ELSE @auto_v2mpositiontaking_mem_7 END,
		@auto_v2mpositiontaking_mem_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_8 ELSE @auto_v2mpositiontaking_mem_8 END,	
		@auto_v2mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_20 ELSE @auto_v2mpositiontaking_mem_20 END,
		@auto_v2mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2mpositiontaking_mem_9999 ELSE @auto_v2mpositiontaking_mem_9999 END,
				
		@v3mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_1 ELSE @v3mpositiontaking_1 END,
		@v3mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_2 ELSE @v3mpositiontaking_2 END,
		@v3mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_3 ELSE @v3mpositiontaking_3 END,
		@v3mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_v3mpositiontaking_20 ELSE @v3mpositiontaking_20 END,
				
		@isauto_v3mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_mem_1 ELSE @isauto_v3mpositiontaking_mem_1 END,
		@isauto_v3mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_mem_2 ELSE @isauto_v3mpositiontaking_mem_2 END,
		@isauto_v3mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_mem_3 ELSE @isauto_v3mpositiontaking_mem_3 END,
		@isauto_v3mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_mem_20 ELSE @isauto_v3mpositiontaking_mem_20 END,
		
		@auto_v3mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3mpositiontaking_mem_1 ELSE @auto_v3mpositiontaking_mem_1 END,
		@auto_v3mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3mpositiontaking_mem_2 ELSE @auto_v3mpositiontaking_mem_2 END,
		@auto_v3mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3mpositiontaking_mem_3 ELSE @auto_v3mpositiontaking_mem_3 END,
		@auto_v3mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3mpositiontaking_mem_20 ELSE @auto_v3mpositiontaking_mem_20 END,
				
		@v5mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_1 ELSE @v5mpositiontaking_1 END,
		@v5mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_2 ELSE @v5mpositiontaking_2 END,
		@v5mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_3 ELSE @v5mpositiontaking_3 END,
		@v5mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_20 ELSE @v5mpositiontaking_20 END,
		@v5mpositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_v5mpositiontaking_9999 ELSE @v5mpositiontaking_9999 END,
				
		@isauto_v5mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_mem_1 ELSE @isauto_v5mpositiontaking_mem_1 END,
		@isauto_v5mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_mem_2 ELSE @isauto_v5mpositiontaking_mem_2 END,
		@isauto_v5mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_mem_3 ELSE @isauto_v5mpositiontaking_mem_3 END,
		@isauto_v5mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_mem_20 ELSE @isauto_v5mpositiontaking_mem_20 END,
		@isauto_v5mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_mem_9999 ELSE @isauto_v5mpositiontaking_mem_9999 END,
		
		@auto_v5mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5mpositiontaking_mem_1 ELSE @auto_v5mpositiontaking_mem_1 END,
		@auto_v5mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5mpositiontaking_mem_2 ELSE @auto_v5mpositiontaking_mem_2 END,
		@auto_v5mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5mpositiontaking_mem_3 ELSE @auto_v5mpositiontaking_mem_3 END,
		@auto_v5mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5mpositiontaking_mem_20 ELSE @auto_v5mpositiontaking_mem_20 END,
		@auto_v5mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5mpositiontaking_mem_9999 ELSE @auto_v5mpositiontaking_mem_9999 END,
		
		@v8mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_1 ELSE @v8mpositiontaking_1 END,
		@v8mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_3 ELSE @v8mpositiontaking_3 END,
		@v8mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8mpositiontaking_20 ELSE @v8mpositiontaking_20 END,
		
		@isauto_v8mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_mem_1 ELSE @isauto_v8mpositiontaking_mem_1 END,
		@isauto_v8mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_mem_3 ELSE @isauto_v8mpositiontaking_mem_3 END,
		@isauto_v8mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_mem_20 ELSE @isauto_v8mpositiontaking_mem_20 END,
		
		@auto_v8mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8mpositiontaking_mem_1 ELSE @auto_v8mpositiontaking_mem_1 END,
		@auto_v8mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8mpositiontaking_mem_3 ELSE @auto_v8mpositiontaking_mem_3 END,
		@auto_v8mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8mpositiontaking_mem_20 ELSE @auto_v8mpositiontaking_mem_20 END,
				
		@v10mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_1 ELSE @v10mpositiontaking_1 END,
		@v10mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_2 ELSE @v10mpositiontaking_2 END,
		@v10mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_3 ELSE @v10mpositiontaking_3 END,
		@v10mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_v10mpositiontaking_20 ELSE @v10mpositiontaking_20 END,
		
		@isauto_v10mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_mem_1 ELSE @isauto_v10mpositiontaking_mem_1 END,
		@isauto_v10mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_mem_2 ELSE @isauto_v10mpositiontaking_mem_2 END,
		@isauto_v10mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_mem_3 ELSE @isauto_v10mpositiontaking_mem_3 END,
		@isauto_v10mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_mem_20 ELSE @isauto_v10mpositiontaking_mem_20 END,
		
		@auto_v10mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10mpositiontaking_mem_1 ELSE @auto_v10mpositiontaking_mem_1 END,
		@auto_v10mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10mpositiontaking_mem_2 ELSE @auto_v10mpositiontaking_mem_2 END,
		@auto_v10mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10mpositiontaking_mem_3 ELSE @auto_v10mpositiontaking_mem_3 END,
		@auto_v10mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10mpositiontaking_mem_20 ELSE @auto_v10mpositiontaking_mem_20 END,
		
		
		@v11mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11mpositiontaking_1 ELSE @v11mpositiontaking_1 END,
		@v11mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11mpositiontaking_20 ELSE @v11mpositiontaking_20 END,
		
		@isauto_v11mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11mpositiontaking_mem_1 ELSE @isauto_v11mpositiontaking_mem_1 END,
		@isauto_v11mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11mpositiontaking_mem_1 ELSE @isauto_v11mpositiontaking_mem_1 END,
		
		@auto_v11mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11mpositiontaking_mem_1 ELSE @auto_v11mpositiontaking_mem_1 END,
		@auto_v11mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11mpositiontaking_mem_20 ELSE @auto_v11mpositiontaking_mem_20 END,
		
		@v99mpositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_1 ELSE @v99mpositiontaking_1 END,
		@v99mpositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_2 ELSE @v99mpositiontaking_2 END,
		@v99mpositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_3 ELSE @v99mpositiontaking_3 END,
		@v99mpositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_20 ELSE @v99mpositiontaking_20 END,
		@v99mpositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_v99mpositiontaking_9999 ELSE @v99mpositiontaking_9999 END,
		
		@isauto_v99mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_mem_1 ELSE @isauto_v99mpositiontaking_mem_1 END,
		@isauto_v99mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_mem_2 ELSE @isauto_v99mpositiontaking_mem_2 END,
		@isauto_v99mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_mem_3 ELSE @isauto_v99mpositiontaking_mem_3 END,
		@isauto_v99mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_mem_20 ELSE @isauto_v99mpositiontaking_mem_20 END,
		@isauto_v99mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_mem_9999 ELSE @isauto_v99mpositiontaking_mem_9999 END,
		
		@auto_v99mpositiontaking_mem_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99mpositiontaking_mem_1 ELSE @auto_v99mpositiontaking_mem_1 END,
		@auto_v99mpositiontaking_mem_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99mpositiontaking_mem_2 ELSE @auto_v99mpositiontaking_mem_2 END,
		@auto_v99mpositiontaking_mem_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99mpositiontaking_mem_3 ELSE @auto_v99mpositiontaking_mem_3 END,
		@auto_v99mpositiontaking_mem_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99mpositiontaking_mem_20 ELSE @auto_v99mpositiontaking_mem_20 END,
		@auto_v99mpositiontaking_mem_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99mpositiontaking_mem_9999 ELSE @auto_v99mpositiontaking_mem_9999 END,
		-- mixed sports
		@v99mpositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_v99mpositiontaking_9 ELSE @v99mpositiontaking_9 END,
		@isauto_v99mpositiontaking_mem_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_isauto_v99mpositiontaking_mem_9 ELSE @isauto_v99mpositiontaking_mem_9 END,
		@auto_v99mpositiontaking_mem_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_auto_v99mpositiontaking_mem_9 ELSE @auto_v99mpositiontaking_mem_9 END	

		--Log for PT
		DECLARE @TrackingValue2 VARCHAR(MAX)
				,@LogSPData VARCHAR(MAX)
				
		SELECT @LogSPData = '<Acc_CustomerUpdMember_Master><info Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

		'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" />' +

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
		'v99mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_2),space(1))  + '" ' +
		'v99mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_3),space(1)) + '" ' +
		'v99mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_20),space(1)) + '" ' +
		'v99mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_9999),space(1)) + '" ' +
		-- mixed sports
		'v99mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@v99mpositiontaking_9),space(1)) + '" />' +

		'<iame isa_mpt_mem_1="'+ coalesce(cast(@isauto_mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_2="'+ coalesce(cast(@isauto_mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_3="'+ coalesce(cast(@isauto_mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_4="'+ coalesce(cast(@isauto_mpositiontaking_mem_4 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_5="'+ coalesce(cast(@isauto_mpositiontaking_mem_5 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_6="'+ coalesce(cast(@isauto_mpositiontaking_mem_6 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_7="'+ coalesce(cast(@isauto_mpositiontaking_mem_7 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_8="'+ coalesce(cast(@isauto_mpositiontaking_mem_8 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_9="'+ coalesce(cast(@isauto_mpositiontaking_mem_9 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_10="'+ coalesce(cast(@isauto_mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for Sports
		'isa_v2mpt_mem_10="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_10="'+ coalesce(cast(@isauto_v3mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_10="'+ coalesce(cast(@isauto_v5mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v8mpt_mem_10="'+ coalesce(cast(@isauto_v8mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_10="'+ coalesce(cast(@isauto_v10mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v11mpt_mem_10="'+ coalesce(cast(@isauto_v11mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_10="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		
		'isa_mpt_mem_9999="'+ coalesce(cast(@isauto_mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +
		
		'isa_mlivept_mem_1="'+ coalesce(cast(@isauto_mlivepositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_mlivept_mem_3="'+ coalesce(cast(@isauto_mlivepositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_mlivept_mem_7="'+ coalesce(cast(@isauto_mlivepositiontaking_mem_7 as varchar(50)),space(1)) + '" ' +
		'isa_mlivept_mem_8="'+ coalesce(cast(@isauto_mlivepositiontaking_mem_8 as varchar(50)),space(1)) + '" ' +

		'isa_v2mpt_mem_1="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_2="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_3="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_7="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_7 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_8="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_8 as varchar(50)),space(1)) + '" ' +
		--'isa_v2mpt_mem_9="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_9 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_20="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_9999="'+ coalesce(cast(@isauto_v2mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +

		'isa_v3mpt_mem_1="'+ coalesce(cast(@isauto_v3mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_2="'+ coalesce(cast(@isauto_v3mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_3="'+ coalesce(cast(@isauto_v3mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_20="'+ coalesce(cast(@isauto_v3mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v5mpt_mem_1="'+ coalesce(cast(@isauto_v5mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_2="'+ coalesce(cast(@isauto_v5mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_3="'+ coalesce(cast(@isauto_v5mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_20="'+ coalesce(cast(@isauto_v5mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_9999="'+ coalesce(cast(@isauto_v5mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +

		'isa_v8mpt_mem_1="'+ coalesce(cast(@isauto_v8mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v8mpt_mem_3="'+ coalesce(cast(@isauto_v8mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v8mpt_mem_20="'+ coalesce(cast(@isauto_v8mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v10mpt_mem_1="'+ coalesce(cast(@isauto_v10mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_2="'+ coalesce(cast(@isauto_v10mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_3="'+ coalesce(cast(@isauto_v10mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_20="'+ coalesce(cast(@isauto_v10mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v11mpt_mem_1="'+ coalesce(cast(@isauto_v11mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v11mpt_mem_20="'+ coalesce(cast(@isauto_v11mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v99mpt_mem_1="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_2="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_3="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_20="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_9999="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'isa_v99mpt_mem_9="'+ coalesce(cast(@isauto_v99mpositiontaking_mem_9 as varchar(50)),space(1)) + '" />' +

		'<aume a_mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_1),space(1)) + '" ' +
		'a_mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_2),space(1)) + '" ' +
		'a_mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_3),space(1)) + '" ' +
		'a_mpt_mem_4="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_4),space(1)) + '" ' +
		'a_mpt_mem_5="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_5),space(1)) + '" ' +
		'a_mpt_mem_6="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_6),space(1)) + '" ' +
		'a_mpt_mem_7="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_7),space(1)) + '" ' +
		'a_mpt_mem_8="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_8),space(1)) + '" ' +
		'a_mpt_mem_9="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_9),space(1)) + '" ' +
		'a_mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_10),space(1)) + '" ' +
		'a_mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mpositiontaking_mem_9999),space(1)) + '" ' +
		-- Outright PT for sports
		'a_v2mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v3mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v5mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v8mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v10mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v11mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v11mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v99mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_10),space(1)) + '" ' +

		'a_mlivept_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_mem_1),space(1)) + '" ' +
		'a_mlivept_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_mem_3),space(1)) + '" ' +
		'a_mlivept_mem_7="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_mem_7),space(1)) + '" ' +
		'a_mlivept_mem_8="'+ coalesce(dbo.f_FomatNumericToChar(@auto_mlivepositiontaking_mem_8),space(1)) + '" ' +

		'a_v2mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v2mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v2mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v2mpt_mem_7="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_7),space(1)) + '" ' +
		'a_v2mpt_mem_8="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_8),space(1)) + '" ' +
		--'a_v2mpt_mem_9="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_9),space(1)) + '" ' +
		'a_v2mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_20),space(1)) + '" ' +
		'a_v2mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v2mpositiontaking_mem_9999),space(1)) + '" ' +

		'a_v3mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v3mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v3mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v3mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v3mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v5mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v5mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v5mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v5mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_mem_20),space(1)) + '" ' +
		'a_v5mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v5mpositiontaking_mem_9999),space(1)) + '" ' +

		'a_v8mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v8mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v8mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v8mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v10mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v10mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v10mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v10mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v10mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v11mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v11mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v11mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v11mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v99mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v99mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v99mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v99mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_20),space(1)) + '" ' +
		'a_v99mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_9999),space(1)) + '" ' +
		-- mixed sports
		'a_v99mpt_mem_9="'+ coalesce(dbo.f_FomatNumericToChar(@auto_v99mpositiontaking_mem_9),space(1)) + '" /></Acc_CustomerUpdMember_Master>'

		SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_Master><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP AS VARCHAR(15)),SPACE(1)) + '" />' +

		'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontaking="'+ coalesce(cast(@UpdatePositiontaking as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" />' +

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
		'v99mpt_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_2),space(1))  + '" ' +
		'v99mpt_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_3),space(1)) + '" ' +
		'v99mpt_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_20),space(1)) + '" ' +
		'v99mpt_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_9999),space(1)) + '" ' +
		-- mixed sports
		'v99mpt_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_v99mpositiontaking_9),space(1)) + '" />' +


		'<iame isa_mpt_mem_1="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_2="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_3="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_4="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_4 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_5="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_5 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_6="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_6 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_7="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_7 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_8="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_8 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_9="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_9 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_10="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_mpt_mem_9999="'+ coalesce(CAST(@Old_isauto_mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for sports
		'isa_v2mpt_mem_10="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_10="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_10="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v8mpt_mem_10="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_10="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v11mpt_mem_10="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_10="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_10 as varchar(50)),space(1)) + '" ' +
		
		'isa_mlivept_mem_1="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_mlivept_mem_3="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_mlivept_mem_7="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_mem_7 as varchar(50)),space(1)) + '" ' +
		'isa_mlivept_mem_8="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_mem_8 as varchar(50)),space(1)) + '" ' +

		'isa_v2mpt_mem_1="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_2="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_3="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_7="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_7 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_8="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_8 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_20="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +
		'isa_v2mpt_mem_9999="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +

		'isa_v3mpt_mem_1="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_2="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_3="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v3mpt_mem_20="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v5mpt_mem_1="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_2="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_3="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_20="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +
		'isa_v5mpt_mem_9999="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +

		'isa_v8mpt_mem_1="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v8mpt_mem_3="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v8mpt_mem_20="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v10mpt_mem_1="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_2="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_3="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v10mpt_mem_20="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v11mpt_mem_1="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v11mpt_mem_20="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +

		'isa_v99mpt_mem_1="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_1 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_2="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_2 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_3="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_3 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_20="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_20 as varchar(50)),space(1)) + '" ' +
		'isa_v99mpt_mem_9999="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_9999 as varchar(50)),space(1)) + '" ' +
		-- mixed sports
		-- mixed sports
		'isa_v99mpt_mem_9="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_mem_9 as varchar(50)),space(1)) + '" />' +

		'<aume a_mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_1),space(1)) + '" ' +
		'a_mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_2),space(1)) + '" ' +
		'a_mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_3),space(1)) + '" ' +
		'a_mpt_mem_4="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_4),space(1)) + '" ' +
		'a_mpt_mem_5="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_5),space(1)) + '" ' +
		'a_mpt_mem_6="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_6),space(1)) + '" ' +
		'a_mpt_mem_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_7),space(1)) + '" ' +
		'a_mpt_mem_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_8),space(1)) + '" ' +
		'a_mpt_mem_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_9),space(1)) + '" ' +
		'a_mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_10),space(1)) + '" ' +
		'a_mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mpositiontaking_mem_9999),space(1)) + '" ' +
		
		-- Outright PT for sports
		'a_v2mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v3mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v3mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v5mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v5mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v8mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v8mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v10mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v10mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v11mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v11mpositiontaking_mem_10),space(1)) + '" ' +
		'a_v99mpt_mem_10="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_10),space(1)) + '" ' +
		
		
		'a_mlivept_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mlivepositiontaking_mem_1),space(1)) + '" ' +
		'a_mlivept_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mlivepositiontaking_mem_3),space(1)) + '" ' +
		'a_mlivept_mem_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mlivepositiontaking_mem_7),space(1)) + '" ' +
		'a_mlivept_mem_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_mlivepositiontaking_mem_8),space(1)) + '" ' +

		'a_v2mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v2mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v2mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v2mpt_mem_7="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_7),space(1)) + '" ' +
		'a_v2mpt_mem_8="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_8),space(1)) + '" ' +
		'a_v2mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_20),space(1)) + '" ' +
		'a_v2mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v2mpositiontaking_mem_9999),space(1)) + '" ' +

		'a_v3mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v3mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v3mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v3mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v3mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v3mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v3mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v3mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v5mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v5mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v5mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v5mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v5mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v5mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v5mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v5mpositiontaking_mem_20),space(1)) + '" ' +
		'a_v5mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v5mpositiontaking_mem_9999),space(1)) + '" ' +

		'a_v8mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v8mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v8mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v8mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v8mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v8mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v10mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v10mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v10mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v10mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v10mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v10mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v10mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v10mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v11mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v11mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v11mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v11mpositiontaking_mem_20),space(1)) + '" ' +

		'a_v99mpt_mem_1="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_1),space(1)) + '" ' +
		'a_v99mpt_mem_2="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_2),space(1)) + '" ' +
		'a_v99mpt_mem_3="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_3),space(1)) + '" ' +
		'a_v99mpt_mem_20="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_20),space(1)) + '" ' +
		'a_v99mpt_mem_9999="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_9999),space(1)) + '" ' +
		-- mixed sports
		'a_v99mpt_mem_9="'+ coalesce(dbo.f_FomatNumericToChar(@Old_auto_v99mpositiontaking_mem_9),space(1)) + '" /></Acc_CustomerUpdMember_Master>'

		set @endRun = getdate()
		set @duration  = datediff (millisecond,@startRun,@endRun)

		--Log positiontaking
		EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 407,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration		

	END--UpdatePositiontaking
	
	DROP TABLE #tmp_Sports
	DROP TABLE #tmp_Bettype

END

GO
