/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_MAg_CheckParam]
	@custid int OUTPUT, --20200305@Tiara
	@discountcs decimal(9,8),
	@discount1x2 decimal(9,8)=0, --1x2
	@groupa decimal(9,8),
	@groupb decimal(9,8),
	@groupc decimal(9,8),
	@groupd decimal(9,8),
	
	@credit money,
	@maxcredit money = null,
	@mrecommend int,
	
	@apositiontaking_1 smallmoney,
	@apositiontaking_2 smallmoney,
	@apositiontaking_3 smallmoney,
	@apositiontaking_4 smallmoney,
	@apositiontaking_5 smallmoney,
	@apositiontaking_6 smallmoney,
	@apositiontaking_7 smallmoney,
	@apositiontaking_8 smallmoney,
	@apositiontaking_9 smallmoney,
	@apositiontaking_10 smallmoney,
	@v2apositiontaking_10 smallmoney,
	@v3apositiontaking_10 smallmoney,
	@v5apositiontaking_10 smallmoney,
	@v8apositiontaking_10 smallmoney,
	@v10apositiontaking_10 smallmoney,
	@v11apositiontaking_10 smallmoney,
	@v99apositiontaking_10 smallmoney,
	@apositiontaking_9999 smallmoney = 0,
	
	@mpositiontaking_1 smallmoney,
	@mpositiontaking_2 smallmoney,
	@mpositiontaking_3 smallmoney,
	@mpositiontaking_4 smallmoney,
	@mpositiontaking_5 smallmoney,
	@mpositiontaking_6 smallmoney,
	@mpositiontaking_7 smallmoney,
	@mpositiontaking_8 smallmoney,
	@mpositiontaking_9 smallmoney,
	@mpositiontaking_10 smallmoney,
	@v2mpositiontaking_10 smallmoney,
	@v3mpositiontaking_10 smallmoney,
	@v5mpositiontaking_10 smallmoney,
	@v8mpositiontaking_10 smallmoney,
	@v10mpositiontaking_10 smallmoney,
	@v11mpositiontaking_10 smallmoney,
	@v99mpositiontaking_10 smallmoney,
	@mpositiontaking_9999 smallmoney =0,
	
	@alivepositiontaking_1 smallmoney,
	@alivepositiontaking_3 smallmoney,
	@alivepositiontaking_7 smallmoney,
	@alivepositiontaking_8 smallmoney,
	@mlivepositiontaking_1 smallmoney,
	@mlivepositiontaking_3 smallmoney,
	@mlivepositiontaking_7 smallmoney,
	@mlivepositiontaking_8 smallmoney,
	
	@v2apositiontaking_1 smallmoney,
	@v2apositiontaking_2 smallmoney,
	@v2apositiontaking_3 smallmoney,
	@v2apositiontaking_7 smallmoney,
	@v2apositiontaking_8 smallmoney,
--	@v2apositiontaking_9 smallmoney,
	@v2apositiontaking_20 smallmoney,
	@v2apositiontaking_9999 smallmoney = 0,

	@v3apositiontaking_1 smallmoney,
	@v3apositiontaking_2 smallmoney,
	@v3apositiontaking_3 smallmoney,
	@v3apositiontaking_20 smallmoney,

	@v5apositiontaking_1 smallmoney,
	@v5apositiontaking_2 smallmoney,
	@v5apositiontaking_3 smallmoney,
	@v5apositiontaking_20 smallmoney,
	@v5apositiontaking_9999 smallmoney =0,

	@v8apositiontaking_1 smallmoney,
	@v8apositiontaking_3 smallmoney,
	@v8apositiontaking_20 smallmoney,

	@v10apositiontaking_1 smallmoney,
	@v10apositiontaking_2 smallmoney,
	@v10apositiontaking_3 smallmoney,
	@v10apositiontaking_20 smallmoney,

	@v11apositiontaking_1 smallmoney,
	@v11apositiontaking_20 smallmoney,

	@v99apositiontaking_1 smallmoney,
	@v99apositiontaking_2 smallmoney,
	@v99apositiontaking_3 smallmoney,
	@v99apositiontaking_20 smallmoney,
	@v99apositiontaking_9999 smallmoney,
	-- mix parlay of mixed sports
	@v99apositiontaking_9 smallmoney,
		
	@v2mpositiontaking_1 smallmoney,
	@v2mpositiontaking_2 smallmoney,
	@v2mpositiontaking_3 smallmoney,
	@v2mpositiontaking_7 smallmoney,
	@v2mpositiontaking_8 smallmoney,
--	@v2mpositiontaking_9 smallmoney,
	@v2mpositiontaking_20 smallmoney,
	@v2mpositiontaking_9999 smallmoney = 0,

	@v3mpositiontaking_1 smallmoney,
	@v3mpositiontaking_2 smallmoney,
	@v3mpositiontaking_3 smallmoney,
	@v3mpositiontaking_20 smallmoney,

	@v5mpositiontaking_1 smallmoney,
	@v5mpositiontaking_2 smallmoney,
	@v5mpositiontaking_3 smallmoney,
	@v5mpositiontaking_20 smallmoney,
	@v5mpositiontaking_9999 smallmoney =0,

	@v8mpositiontaking_1 smallmoney,
	@v8mpositiontaking_3 smallmoney,
	@v8mpositiontaking_20 smallmoney,

	@v10mpositiontaking_1 smallmoney,
	@v10mpositiontaking_2 smallmoney,
	@v10mpositiontaking_3 smallmoney,
	@v10mpositiontaking_20 smallmoney,

	@v11mpositiontaking_1 smallmoney,
	@v11mpositiontaking_20 smallmoney,

	@v99mpositiontaking_1 smallmoney,
	@v99mpositiontaking_2 smallmoney,
	@v99mpositiontaking_3 smallmoney,
	@v99mpositiontaking_20 smallmoney,
	@v99mpositiontaking_9999 smallmoney,
	-- mix parlay of mixed sports
	@v99mpositiontaking_9 smallmoney,		

	--Auto Master PT
	@auto_mpositiontaking_1 smallmoney = 0,
	@auto_mpositiontaking_2 smallmoney = 0,
	@auto_mpositiontaking_3 smallmoney = 0,
	@auto_mpositiontaking_4 smallmoney = 0,
	@auto_mpositiontaking_5 smallmoney = 0,
	@auto_mpositiontaking_6 smallmoney = 0,
	@auto_mpositiontaking_7 smallmoney = 0,
	@auto_mpositiontaking_8 smallmoney = 0,
	@auto_mpositiontaking_9 smallmoney = 0,
	@auto_mpositiontaking_10 smallmoney = 0,
	@auto_v2mpositiontaking_10 smallmoney = 0,
	@auto_v3mpositiontaking_10 smallmoney = 0,
	@auto_v5mpositiontaking_10 smallmoney = 0,
	@auto_v8mpositiontaking_10 smallmoney = 0,
	@auto_v10mpositiontaking_10 smallmoney = 0,
	@auto_v11mpositiontaking_10 smallmoney = 0,
	@auto_v99mpositiontaking_10 smallmoney = 0,
	@auto_mpositiontaking_9999 smallmoney = 0,
	@auto_mlivepositiontaking_1 smallmoney = 0,
	@auto_mlivepositiontaking_3 smallmoney = 0,
	@auto_mlivepositiontaking_7 smallmoney = 0,
	@auto_mlivepositiontaking_8 smallmoney = 0,
	
	@auto_v2mpositiontaking_1 smallmoney = 0,
	@auto_v2mpositiontaking_2 smallmoney = 0,
	@auto_v2mpositiontaking_3 smallmoney = 0,
	@auto_v2mpositiontaking_7 smallmoney = 0,
	@auto_v2mpositiontaking_8 smallmoney = 0,
--	@auto_v2mpositiontaking_9 smallmoney = 0,
	@auto_v2mpositiontaking_20 smallmoney = 0,
	@auto_v2mpositiontaking_9999 smallmoney = 0,
	
	@auto_v3mpositiontaking_1 smallmoney = 0,
	@auto_v3mpositiontaking_2 smallmoney = 0,
	@auto_v3mpositiontaking_3 smallmoney = 0,	
	@auto_v3mpositiontaking_20 smallmoney = 0,
	
	@auto_v5mpositiontaking_1 smallmoney = 0,
	@auto_v5mpositiontaking_2 smallmoney = 0,
	@auto_v5mpositiontaking_3 smallmoney = 0,	
	@auto_v5mpositiontaking_20 smallmoney = 0,
	@auto_v5mpositiontaking_9999 smallmoney = 0,
	
	@auto_v8mpositiontaking_1 smallmoney = 0,	
	@auto_v8mpositiontaking_3 smallmoney = 0,	
	@auto_v8mpositiontaking_20 smallmoney = 0,
	
	@auto_v10mpositiontaking_1 smallmoney = 0,
	@auto_v10mpositiontaking_2 smallmoney = 0,
	@auto_v10mpositiontaking_3 smallmoney = 0,	
	@auto_v10mpositiontaking_20 smallmoney = 0,
	
	@auto_v11mpositiontaking_1 smallmoney = 0,	
	@auto_v11mpositiontaking_20 smallmoney = 0,
	
	@auto_v99mpositiontaking_1 smallmoney = 0,
	@auto_v99mpositiontaking_2 smallmoney = 0,
	@auto_v99mpositiontaking_3 smallmoney = 0,	
	@auto_v99mpositiontaking_20 smallmoney = 0,
	@auto_v99mpositiontaking_9999 smallmoney = 0,
	-- mix parlay of mixed sports
	@auto_v99mpositiontaking_9 smallmoney,
	
	-- MyanmarOdds	
	@discountMyanmarOdds DECIMAL(9,8) = 0,

	@isvalid bit OUTPUT,
	@errmsg nvarchar(4000) OUTPUT,
	@errcode int OUTPUT,
	@language varchar(2) = 'E',
	@SystemID TINYINT = 1,--20200305@Tiara
	@creator INT
AS

--@Source Control

/*
Created: 20090121@Thien
Task : check valid parameters.
DB: DBCUST/CUSTDB
Original:

Revisions:
    - 20081009@Phuc: Auto Master PT 
    - 20090424@Phuc:Separate finance sporttype(201).
    - 200905014@PhuongDao: Check 1x2 Commission
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
	- 20100831@Lukas:	- Add & validate Number params
						- Add & validate Mix parlay of mixed sports
	- 20101027@Lukas: Add max per ball (number game)
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20120322@Lukas: fix bug: get number game info from wrong table - custsetting
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20140626@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170807@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]  	
	- 20180326@Winnie: Customer Setting - urgent fix to support for long bettype name. [RedmineID: #91216]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]		
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230921@Johnson: extend MaxPT = 0.93 [redmine:194132]
Param's Explanation:
• @ErrCode:
    = 0: check valid parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
	----- David @ 09 JUN 2015 -------------------
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

	
	----- /David @ 09 JUN 2015 -------------------

	declare @ErrType varchar(4000)
	DECLARE @Site NVARCHAR (50), @RoleID TINYINT, @recommend INT

	Select @isvalid = 1
	if 
		@discountcs<0 or @discountcs>0.2
		--1x2
		or @discount1x2 <0 or @discount1x2 > 0.2 
		or @groupa<0 or @groupa>0.2
		or @groupb<0 or @groupb>0.2
		or @groupc<0 or @groupc>0.2
		or @groupd<0 or @groupd>0.2
		OR @discountMyanmarOdds < 0 OR @discountMyanmarOdds > 0.01		-- MyanmarOdds
		
	BEGIN
		select @isvalid = 0, @ErrCode = 1
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Invalid commission rate.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
					end
		return
	END

	--Get site info
	SELECT @RoleID=RoleID  FROM custinfo(NOLOCK) WHERE custid=@custid
	IF @RoleID IN (2,3,4)
		SELECT @Site = C.site FROM Customer C WITH (NOLOCK) WHERE C.custid = @custid
	ELSE IF @RoleID = 1
	BEGIN
		SELECT @recommend = recommend FROM custinfo (NOLOCK) WHERE custid=@custid
		SELECT @Site = C.site FROM Customer C WITH (NOLOCK) WHERE C.custid = @recommend
	END

	IF @credit <0
		or @maxcredit < 0
		or @mrecommend <=0
	BEGIN
		select @isvalid = 0, @ErrCode = 2
		Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match/ Credit/ Master Agent name/ user group.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10001,@Language)
						end
		return
	END

	if 
		@apositiontaking_1  <0
		or @apositiontaking_2  <0
		or @apositiontaking_3  <0
		or @apositiontaking_4  <0
		or @apositiontaking_5  <0
		or @apositiontaking_6  <0
		or @apositiontaking_7  <0
		or @apositiontaking_8  <0
		or @apositiontaking_9  <0
		or @apositiontaking_10 <0
		or @v2apositiontaking_10 <0
		or @v3apositiontaking_10 <0
		or @v5apositiontaking_10 <0
		or @v8apositiontaking_10 <0
		or @v10apositiontaking_10 <0
		or @v11apositiontaking_10 <0
		or @v99apositiontaking_10 <0
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
	--	or @v2apositiontaking_9  <0
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
		or @v99apositiontaking_20  <0
		or @v99apositiontaking_9999  <0

		-- mix parlay of mixed sports
		or @v99apositiontaking_9 < 0			

		or @apositiontaking_1  >0.93
		or @apositiontaking_2  >0.93
		or @apositiontaking_3  >0.93
		or @apositiontaking_4  >0.93
		or @apositiontaking_5  >0.93
		or @apositiontaking_6  >0.93
		or @apositiontaking_7  >0.93
		or @apositiontaking_8  >0.93
		or @apositiontaking_9  >0.93
		or @apositiontaking_10 >0.93
		or @v2apositiontaking_10 >0.93
		or @v3apositiontaking_10 >0.93
		or @v5apositiontaking_10 >0.93
		or @v8apositiontaking_10 >0.93
		or @v10apositiontaking_10 >0.93
		or @v11apositiontaking_10 >0.93
		or @v99apositiontaking_10 >0.93
		or @apositiontaking_9999  >0.93
		
		or @alivepositiontaking_1  >0.93
		or @alivepositiontaking_3  >0.93
		or @alivepositiontaking_7  >0.93
		or @alivepositiontaking_8  >0.93
		
		or @v2apositiontaking_1  >0.93
		or @v2apositiontaking_2  >0.93
		or @v2apositiontaking_3  >0.93
		or @v2apositiontaking_7  >0.93
		or @v2apositiontaking_8  >0.93
	--	or @v2apositiontaking_9  >0.93
		or @v2apositiontaking_20  >0.93
		or @v2apositiontaking_9999  >0.93

		or @v3apositiontaking_1  >0.93
		or @v3apositiontaking_2  >0.93
		or @v3apositiontaking_3  >0.93
		or @v3apositiontaking_20  >0.93

		or @v5apositiontaking_1  >0.93
		or @v5apositiontaking_2  >0.93
		or @v5apositiontaking_3  >0.93
		or @v5apositiontaking_20  >0.93
		or @v5apositiontaking_9999  >0.93
		
		or @v8apositiontaking_1  >0.93
		or @v8apositiontaking_3  >0.93
		or @v8apositiontaking_20  >0.93

		or @v10apositiontaking_1  >0.93
		or @v10apositiontaking_2  >0.93
		or @v10apositiontaking_3  >0.93
		or @v10apositiontaking_20  >0.93

		or @v11apositiontaking_1  >0.93
		or @v11apositiontaking_20  >0.93

		or @v99apositiontaking_1  >0.93
		or @v99apositiontaking_2  >0.93
		or @v99apositiontaking_3  >0.93
		or @v99apositiontaking_20  >0.93
		or @v99apositiontaking_9999  >0.93

		-- mix parlay of mixed sports
		or @v99apositiontaking_9  > 0.93
			
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
		or @v2mpositiontaking_10 <0
		or @v3mpositiontaking_10 <0
		or @v5mpositiontaking_10 <0
		or @v8mpositiontaking_10 <0
		or @v10mpositiontaking_10 <0
		or @v11mpositiontaking_10 <0
		or @v99mpositiontaking_10 <0
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
	--	or @v2mpositiontaking_9  <0
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
		or @v99mpositiontaking_20  <0	
		or @v99mpositiontaking_9999  <0	

		-- mix parlay of mixed sports
		or @v99mpositiontaking_9  <0			

		or @mpositiontaking_1  >0.93
		or @mpositiontaking_2  >0.93
		or @mpositiontaking_3  >0.93
		or @mpositiontaking_4  >0.93
		or @mpositiontaking_5  >0.93
		or @mpositiontaking_6  >0.93
		or @mpositiontaking_7  >0.93
		or @mpositiontaking_8  >0.93
		or @mpositiontaking_9  >0.93
		or @mpositiontaking_10 >0.93
		or @v2mpositiontaking_10 >0.93
		or @v3mpositiontaking_10 >0.93
		or @v5mpositiontaking_10 >0.93
		or @v8mpositiontaking_10 >0.93
		or @v10mpositiontaking_10 >0.93
		or @v11mpositiontaking_10 >0.93
		or @v99mpositiontaking_10 >0.93
		or @mpositiontaking_9999  >0.93
		
		or @mlivepositiontaking_1  >0.93
		or @mlivepositiontaking_3  >0.93
		or @mlivepositiontaking_7  >0.93
		or @mlivepositiontaking_8  >0.93
		
		or @v2mpositiontaking_1  >0.93
		or @v2mpositiontaking_2  >0.93
		or @v2mpositiontaking_3  >0.93
		or @v2mpositiontaking_7  >0.93
		or @v2mpositiontaking_8  >0.93
	--	or @v2mpositiontaking_9  >0.93
		or @v2mpositiontaking_20  >0.93
		or @v2mpositiontaking_9999  >0.93

		or @v3mpositiontaking_1  >0.93
		or @v3mpositiontaking_2  >0.93
		or @v3mpositiontaking_3  >0.93
		or @v3mpositiontaking_20  >0.93

		or @v5mpositiontaking_1  >0.93
		or @v5mpositiontaking_2  >0.93
		or @v5mpositiontaking_3  >0.93
		or @v5mpositiontaking_20  >0.93
		or @v5mpositiontaking_9999  >0.93

		or @v8mpositiontaking_1  >0.93
		or @v8mpositiontaking_3  >0.93
		or @v8mpositiontaking_20  >0.93

		or @v10mpositiontaking_1  >0.93
		or @v10mpositiontaking_2  >0.93
		or @v10mpositiontaking_3  >0.93
		or @v10mpositiontaking_20  >0.93

		or @v11mpositiontaking_1  >0.93
		or @v11mpositiontaking_20  >0.93

		or @v99mpositiontaking_1  >0.93
		or @v99mpositiontaking_2  >0.93
		or @v99mpositiontaking_3  >0.93
		or @v99mpositiontaking_20  >0.93
		or @v99mpositiontaking_9999  >0.93

		-- mix parlay of mixed sports
		or @v99mpositiontaking_9  > 0.93
		
		--Auto Master PT
		or @auto_mpositiontaking_1  <0
		or @auto_mpositiontaking_1 < 0
		or @auto_mpositiontaking_2 < 0
		or @auto_mpositiontaking_3 < 0
		or @auto_mpositiontaking_4 < 0
		or @auto_mpositiontaking_5 < 0
		or @auto_mpositiontaking_6 < 0
		or @auto_mpositiontaking_7 < 0
		or @auto_mpositiontaking_8 < 0
		or @auto_mpositiontaking_9 < 0
		or @auto_mpositiontaking_10 < 0
		or @auto_v2mpositiontaking_10 < 0
		or @auto_v3mpositiontaking_10 < 0
		or @auto_v5mpositiontaking_10 < 0
		or @auto_v8mpositiontaking_10 < 0
		or @auto_v10mpositiontaking_10 < 0
		or @auto_v11mpositiontaking_10 < 0
		or @auto_v99mpositiontaking_10 < 0
		or @auto_mpositiontaking_9999 < 0
		or @auto_mlivepositiontaking_1 < 0
		or @auto_mlivepositiontaking_3 < 0
		or @auto_mlivepositiontaking_7 < 0
		or @auto_mlivepositiontaking_8 < 0
		
		or @auto_v2mpositiontaking_1 < 0
		or @auto_v2mpositiontaking_2 < 0
		or @auto_v2mpositiontaking_3 < 0
		or @auto_v2mpositiontaking_7 < 0
		or @auto_v2mpositiontaking_8 < 0
	--	or @auto_v2mpositiontaking_9 < 0
		or @auto_v2mpositiontaking_20 < 0
		or @auto_v2mpositiontaking_9999 < 0
		
		or @auto_v3mpositiontaking_1 < 0
		or @auto_v3mpositiontaking_2 < 0
		or @auto_v3mpositiontaking_3 < 0	
		or @auto_v3mpositiontaking_20 < 0
		
		or @auto_v5mpositiontaking_1 < 0
		or @auto_v5mpositiontaking_2 < 0
		or @auto_v5mpositiontaking_3 < 0	
		or @auto_v5mpositiontaking_20 < 0
		or @auto_v5mpositiontaking_9999 < 0	
		
		or @auto_v8mpositiontaking_1 < 0	
		or @auto_v8mpositiontaking_3 < 0	
		or @auto_v8mpositiontaking_20 < 0
		
		or @auto_v10mpositiontaking_1 < 0
		or @auto_v10mpositiontaking_2 < 0
		or @auto_v10mpositiontaking_3 < 0	
		or @auto_v10mpositiontaking_20 < 0
		
		or @auto_v11mpositiontaking_1 < 0	
		or @auto_v11mpositiontaking_20 < 0
		
		or @auto_v99mpositiontaking_1 < 0
		or @auto_v99mpositiontaking_2 < 0
		or @auto_v99mpositiontaking_3 < 0	
		or @auto_v99mpositiontaking_20 < 0
		or @auto_v99mpositiontaking_9999 < 0
		-- mix parlay of mixed sports
		or @auto_v99mpositiontaking_9 < 0			
		
		or @auto_mpositiontaking_1>0.93
		or @auto_mpositiontaking_2>0.93
		or @auto_mpositiontaking_3>0.93
		or @auto_mpositiontaking_4>0.93
		or @auto_mpositiontaking_5>0.93
		or @auto_mpositiontaking_6>0.93
		or @auto_mpositiontaking_7>0.93
		or @auto_mpositiontaking_8>0.93
		or @auto_mpositiontaking_9>0.93
		or @auto_mpositiontaking_10>0.93
		or @auto_v2mpositiontaking_10>0.93
		or @auto_v3mpositiontaking_10>0.93
		or @auto_v5mpositiontaking_10>0.93
		or @auto_v8mpositiontaking_10>0.93
		or @auto_v10mpositiontaking_10>0.93
		or @auto_v11mpositiontaking_10>0.93
		or @auto_v99mpositiontaking_10>0.93
		or @auto_mpositiontaking_9999>0.93
		or @auto_mlivepositiontaking_1>0.93
		or @auto_mlivepositiontaking_3>0.93
		or @auto_mlivepositiontaking_7>0.93
		or @auto_mlivepositiontaking_8>0.93
		
		or @auto_v2mpositiontaking_1>0.93
		or @auto_v2mpositiontaking_2>0.93
		or @auto_v2mpositiontaking_3>0.93
		or @auto_v2mpositiontaking_7>0.93
		or @auto_v2mpositiontaking_8>0.93
	--	or @auto_v2mpositiontaking_9>0.93
		or @auto_v2mpositiontaking_20>0.93
		or @auto_v2mpositiontaking_9999>0.93
		
		or @auto_v3mpositiontaking_1>0.93
		or @auto_v3mpositiontaking_2>0.93
		or @auto_v3mpositiontaking_3>0.93	
		or @auto_v3mpositiontaking_20>0.93
		
		or @auto_v5mpositiontaking_1>0.93
		or @auto_v5mpositiontaking_2>0.93
		or @auto_v5mpositiontaking_3>0.93	
		or @auto_v5mpositiontaking_20>0.93
		or @auto_v5mpositiontaking_9999>0.93
		
		or @auto_v8mpositiontaking_1>0.93	
		or @auto_v8mpositiontaking_3>0.93	
		or @auto_v8mpositiontaking_20>0.93
		
		or @auto_v10mpositiontaking_1>0.93
		or @auto_v10mpositiontaking_2>0.93
		or @auto_v10mpositiontaking_3>0.93	
		or @auto_v10mpositiontaking_20>0.93
		
		or @auto_v11mpositiontaking_1>0.93	
		or @auto_v11mpositiontaking_20>0.93
		
		or @auto_v99mpositiontaking_1>0.93
		or @auto_v99mpositiontaking_2>0.93
		or @auto_v99mpositiontaking_3>0.93	
		or @auto_v99mpositiontaking_20>0.93
		or @auto_v99mpositiontaking_9999>0.93
		-- mix parlay of mixed sports
		or @auto_v99mpositiontaking_9 > 0.93		

	BEGIN
		select @isvalid = 0, @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		return
	END
		--Check if(!i2)n3<=m2+a2<=l3
		--			else a2<=l3 and u2+a2>=n3
		select @ErrType = ''
		select @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
		+ case when b.sporttype = 1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
		from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @auto_mpositiontaking_1 as auto_mpositiontaking,  @auto_mlivepositiontaking_1 as auto_mlivepositiontaking 
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @auto_mpositiontaking_3 as auto_mpositiontaking,  @auto_mlivepositiontaking_3 as auto_mlivepositiontaking 
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @auto_mpositiontaking_7 as auto_mpositiontaking,  @auto_mlivepositiontaking_7 as auto_mlivepositiontaking 
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @auto_mpositiontaking_8 as auto_mpositiontaking,  @auto_mlivepositiontaking_8 as auto_mlivepositiontaking 
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_4 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_5 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_6 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_9 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_mpositiontaking_9999 as auto_mpositiontaking,  0 as auto_mlivepositiontaking

			union all 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_3 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
	--		union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking
	--		union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking
	--		union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_9 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9999 as bettype, 2 as sporttype, @v2apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2mpositiontaking_9999 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
						
			union all 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3mpositiontaking_3 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking

			union all 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5mpositiontaking_3 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5mpositiontaking_9999 as auto_mpositiontaking,  0 as auto_mlivepositiontaking

			union all 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8mpositiontaking_3 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking

			union all 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10mpositiontaking_3 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking

			union all 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking

			union all 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_1 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_3 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_20 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9999 as bettype, 99 as sporttype, @v99apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_9999 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99mpositiontaking_9 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
		
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		inner join #tmp_Sports sports on b.sporttype = sports.ID
		inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	where co.custid = @mrecommend and 
		(
			((b.auto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
			((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.auto_mlivepositiontaking=0) and (b.mlivepositiontaking+b.alivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking+b.alivepositiontaking<co.minlivepositiontaking)) or
			((b.auto_mpositiontaking>0) and (b.apositiontaking>co.maxpositiontaking)) or 
			((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.auto_mlivepositiontaking>0) and (b.alivepositiontaking>co.maxlivepositiontaking)) or
			
			((b.auto_mpositiontaking>0) and (b.apositiontaking + b.auto_mpositiontaking < co.minpositiontaking)) or 
			((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.auto_mlivepositiontaking>0) and (b.alivepositiontaking + b.auto_mlivepositiontaking < co.minlivepositiontaking))
		
		)

	/*
	(( (b.apositiontaking+b.mpositiontaking>co.maxpositiontaking or b.apositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
						((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking+b.mlivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking+b.mlivepositiontaking<co.minlivepositiontaking)))
	*/

	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode = 4
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END				

		--check a2<=a4
		select @ErrType = ''
		select @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
		+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
		from  customer as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
					select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking

			union all 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
	--		union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking
	--		union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking
	--		union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 2 as sporttype, @v2apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
		
			union all 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking

			union all 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking

			union all 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking

			union all 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking

			union all 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking

			union all 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 99 as sporttype, @v99apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
	
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		inner join #tmp_Sports sports on b.sporttype = sports.ID
		inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))

	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode = 5
		Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType						
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType						
					end
		return
	END		
	DROP TABLE #tmp_Sports
	DROP TABLE #tmp_Bettype
	return
END
GO
