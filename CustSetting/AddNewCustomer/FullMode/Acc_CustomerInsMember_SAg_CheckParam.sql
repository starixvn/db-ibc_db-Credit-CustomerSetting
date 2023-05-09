/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_SAg_CheckParam]
	@custid int OUTPUT,
	@credit money,
	@srecommend int,
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
	@v2spositiontaking_10 smallmoney,
	@v3spositiontaking_10 smallmoney,
	@v5spositiontaking_10 smallmoney,
	@v8spositiontaking_10 smallmoney,
	@v10spositiontaking_10 smallmoney,
	@v11spositiontaking_10 smallmoney,
	@v99spositiontaking_10 smallmoney,
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
--	@v2spositiontaking_9 smallmoney,
	@v2spositiontaking_20 smallmoney,
	@v2spositiontaking_9999 smallmoney = 0,
	
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

	@v99spositiontaking_9 smallmoney,
	@v99spositiontaking_9999 smallmoney,
		
	@groupa decimal(9,8),
	@groupb decimal(9,8),
	@groupc decimal(9,8),
	@groupd decimal(9,8),
	@discountcs decimal(9,8),
	--1x2
	@discount1x2 decimal(9,8),
	-- MyanmarOdds
	@discountMyanmarOdds  DECIMAL(9,8) = 0,
	
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
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
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

	@auto_v2spositiontaking_20 smallmoney = 0,
	@auto_v2spositiontaking_9999 smallmoney = 0,
	
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

	@auto_v99spositiontaking_9 smallmoney = 0,
	@auto_v99spositiontaking_9999 smallmoney = 0,
	
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
	@v2mpositiontaking_10 smallmoney = 0.7,
	@v3mpositiontaking_10 smallmoney = 0.7,
	@v5mpositiontaking_10 smallmoney = 0.7,
	@v8mpositiontaking_10 smallmoney = 0.7,
	@v10mpositiontaking_10 smallmoney = 0.7,
	@v11mpositiontaking_10 smallmoney = 0.7,
	@v99mpositiontaking_10 smallmoney = 0.7,
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
--	@v2mpositiontaking_9 smallmoney = 0.7,
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
	@v11mpositiontaking_20 smallmoney = 0.7,
	
	@v99mpositiontaking_1 smallmoney = 0.7,
	@v99mpositiontaking_2 smallmoney = 0.7,
	@v99mpositiontaking_3 smallmoney = 0.7,		
	@v99mpositiontaking_20 smallmoney = 0.7,

	@v99mpositiontaking_9 smallmoney = 0.7,
	@v99mpositiontaking_9999 smallmoney = 0.7,
	
	@isvalid bit OUTPUT,
	@errmsg nvarchar(4000) OUTPUT,
	@errcode int OUTPUT,
	@language varchar(2) = 'E',
	@SystemID TINYINT = 1,--20200305@Tiara
	@creator INT
AS
BEGIN
--@Source Control
/*
Created: 20090121@Thien
Task : Check valid parameters.
DB: DBCUST/CUSTDB
Original:

Revisions:
    - 20081009@Phuc: Apply Auto Super PT when create Master
		check if(!i3)
				n4<=s3+m3<=l4
			else u3+m3>=n4 and m3<=l4
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20000514@PhuongDao: Check commission 1x2
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20100803@Henry: grant execute permission to [bodbExtAccNet]
	- 20100827@Lukas:	- Add & validate params for Number game
						- Add & validate params for Mix Parlay for Mixed Sports
						- Remove params for Mix Parlay for Basketball
	- 20101026@Lukas: Add max per ball (number game)
	- 20110801@Lukas: (Number Game)
				- Add more bettypes: Warrior, Next Combo, Number Group
				- Remove dead ball Over/Under
	- 20120323@Luks: Fix bug: get live bettype
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
	- 20140620@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170807@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]  	
	- 20180326@Winnie: Customer Setting - urgent fix to support for long bettype name. [RedmineID: #91216]
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190909@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]	
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
Param's Explanation:
• @ErrCode:
    = 0: check valid parameters successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/


	SET NOCOUNT ON
	
	CREATE TABLE #tmp_Sports(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	CREATE TABLE #tmp_Bettype(ID INT, Name NVARCHAR(500),IsDisabled BIT,IBCBettypeID INT)
	
	----- David @ 09 JUN 2015 -------------------
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
		or @discount1x2 < 0 or @discount1x2 >0.2
		OR @discountMyanmarOdds < 0 or @discountMyanmarOdds > 0.01   -- MyanmarOdds
		or @groupa<0 or @groupa>0.2
		or @groupb<0 or @groupb>0.2
		or @groupc<0 or @groupc>0.2
		or @groupd<0 or @groupd>0.2
		
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
		or @srecommend <=0
	BEGIN
		select @isvalid = 0, @ErrCode = 2
		Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match/ Credit/ Master Agent name/ user group.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10001,@Language)
						end
		return
	END

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
		or @v2spositiontaking_10 <0
		or @v3spositiontaking_10 <0
		or @v5spositiontaking_10 <0
		or @v8spositiontaking_10 <0
		or @v10spositiontaking_10 <0
		or @v11spositiontaking_10 <0
		or @v99spositiontaking_10 <0
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
	--	or @v2spositiontaking_9  <0
		or @v2spositiontaking_20  <0
		or @v2spositiontaking_9999  <0
		
		or @v3spositiontaking_1 <0
		or @v3spositiontaking_2 <0
		or @v3spositiontaking_3 <0
		or @v3spositiontaking_20 <0
		
		or @v5spositiontaking_1 <0
		or @v5spositiontaking_2 <0
		or @v5spositiontaking_3 <0
		or @v5spositiontaking_20 <0
		or @v5spositiontaking_9999 <0
		
		or @v8spositiontaking_1 <0	
		or @v8spositiontaking_3 <0
		or @v8spositiontaking_20 <0
		
		or @v10spositiontaking_1 <0
		or @v10spositiontaking_2 <0
		or @v10spositiontaking_3 <0
		or @v10spositiontaking_20 <0
		
		or @v11spositiontaking_1 <0	
		or @v11spositiontaking_20 <0
		
		or @v99spositiontaking_1 <0
		or @v99spositiontaking_2 <0
		or @v99spositiontaking_3 <0
		or @v99spositiontaking_9 <0
		or @v99spositiontaking_20 <0
		or @v99spositiontaking_9999 <0		

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
		
		or @v3mpositiontaking_1 <0
		or @v3mpositiontaking_2 <0
		or @v3mpositiontaking_3 <0	
		or @v3mpositiontaking_20 <0
		
		or @v5mpositiontaking_1 <0
		or @v5mpositiontaking_2 <0
		or @v5mpositiontaking_3 <0	
		or @v5mpositiontaking_20 <0
		or @v5mpositiontaking_9999 <0	
		
		or @v8mpositiontaking_1 <0	
		or @v8mpositiontaking_3 <0	
		or @v8mpositiontaking_20 <0
		
		or @v10mpositiontaking_1 <0
		or @v10mpositiontaking_2 <0
		or @v10mpositiontaking_3 <0	
		or @v10mpositiontaking_20 <0
		
		or @v11mpositiontaking_1 <0	
		or @v11mpositiontaking_20 <0
		
		or @v99mpositiontaking_1 <0
		or @v99mpositiontaking_2 <0
		or @v99mpositiontaking_3 <0	
		or @v99mpositiontaking_9 <0
		or @v99mpositiontaking_20 <0
		or @v99mpositiontaking_9999 <0
		
		or @spositiontaking_1   	+	@mpositiontaking_1 		> 0.9
		or @spositiontaking_2   	+	@mpositiontaking_2 		> 0.9
		or @spositiontaking_3   	+	@mpositiontaking_3 		> 0.9
		or @spositiontaking_4   	+	@mpositiontaking_4 		> 0.9
		or @spositiontaking_5   	+	@mpositiontaking_5 		> 0.9
		or @spositiontaking_6   	+	@mpositiontaking_6 		> 0.9
		or @spositiontaking_7   	+	@mpositiontaking_7 		> 0.9
		or @spositiontaking_8   	+	@mpositiontaking_8 		> 0.9
		or @spositiontaking_9   	+	@mpositiontaking_9 		> 0.9
		or @spositiontaking_10  	+	@mpositiontaking_10 		> 0.9
		or @v2spositiontaking_10  	+	@v2mpositiontaking_10 		> 0.9
		or @v3spositiontaking_10  	+	@v3mpositiontaking_10 		> 0.9
		or @v5spositiontaking_10  	+	@v5mpositiontaking_10 		> 0.9
		or @v8spositiontaking_10  	+	@v8mpositiontaking_10 		> 0.9
		or @v10spositiontaking_10  	+	@v10mpositiontaking_10 		> 0.9
		or @v11spositiontaking_10  	+	@v11mpositiontaking_10 		> 0.9
		or @v99spositiontaking_10  	+	@v99mpositiontaking_10 		> 0.9
		or @spositiontaking_9999   	+	@mpositiontaking_9999 		> 0.9
						
		or @slivepositiontaking_1   	+	@mlivepositiontaking_1 		> 0.9
		or @slivepositiontaking_3   	+	@mlivepositiontaking_3 		> 0.9
		or @slivepositiontaking_7   	+	@mlivepositiontaking_7 		> 0.9
		or @slivepositiontaking_8   	+	@mlivepositiontaking_8 		> 0.9
						
		or @v2spositiontaking_1   	+	@v2mpositiontaking_1 		> 0.9
		or @v2spositiontaking_2   	+	@v2mpositiontaking_2 		> 0.9
		or @v2spositiontaking_3   	+	@v2mpositiontaking_3 		> 0.9
		or @v2spositiontaking_7   	+	@v2mpositiontaking_7 		> 0.9
		or @v2spositiontaking_8   	+	@v2mpositiontaking_8 		> 0.9
	--	or @v2spositiontaking_9   	+	@v2mpositiontaking_9 		> 0.9
		or @v2spositiontaking_20   	+	@v2mpositiontaking_20 		> 0.9
		or @v2spositiontaking_9999 	+	@v2mpositiontaking_9999 	> 0.9
						
		or @v3spositiontaking_1  	+	@v3mpositiontaking_1 		> 0.9
		or @v3spositiontaking_2  	+	@v3mpositiontaking_2 		> 0.9
		or @v3spositiontaking_3  	+	@v3mpositiontaking_3 		> 0.9
		or @v3spositiontaking_20  	+	@v3mpositiontaking_20 		> 0.9	
						
		or @v5spositiontaking_1  	+	@v5mpositiontaking_1 		> 0.9
		or @v5spositiontaking_2  	+	@v5mpositiontaking_2 		> 0.9
		or @v5spositiontaking_3  	+	@v5mpositiontaking_3 		> 0.9
		or @v5spositiontaking_20  	+	@v5mpositiontaking_20 		> 0.9
		or @v5spositiontaking_9999  +	@v5mpositiontaking_9999 	> 0.9
						
		or @v8spositiontaking_1  	+	@v8mpositiontaking_1 		> 0.9
		or @v8spositiontaking_3  	+	@v8mpositiontaking_3 		> 0.9
		or @v8spositiontaking_20  	+	@v8mpositiontaking_20 		> 0.9
						
		or @v10spositiontaking_1  	+	@v10mpositiontaking_1 		> 0.9
		or @v10spositiontaking_2  	+	@v10mpositiontaking_2 		> 0.9
		or @v10spositiontaking_3  	+	@v10mpositiontaking_3 		> 0.9
		or @v10spositiontaking_20  	+	@v10mpositiontaking_20 		> 0.9
						
		or @v11spositiontaking_1  	+	@v11mpositiontaking_1 		> 0.9
		or @v11spositiontaking_20  	+	@v11mpositiontaking_20 		> 0.9
					
		or @v99spositiontaking_1  	+	@v99mpositiontaking_1 		> 0.9
		or @v99spositiontaking_2  	+	@v99mpositiontaking_2 		> 0.9
		or @v99spositiontaking_3  	+	@v99mpositiontaking_3 		> 0.9
		or @v99spositiontaking_9  	+	@v99mpositiontaking_9 		> 0.9
		or @v99spositiontaking_20  	+	@v99mpositiontaking_20 		> 0.9
		or @v99spositiontaking_9999  	+	@v99mpositiontaking_9999 		> 0.9
		
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
		or @auto_v2spositiontaking_10 < 0 
		or @auto_v3spositiontaking_10 < 0 
		or @auto_v5spositiontaking_10 < 0 
		or @auto_v8spositiontaking_10 < 0 
		or @auto_v10spositiontaking_10 < 0 
		or @auto_v11spositiontaking_10 < 0 
		or @auto_v99spositiontaking_10 < 0 
		or @auto_spositiontaking_9999 < 0 
		or @auto_slivepositiontaking_1 < 0 
		or @auto_slivepositiontaking_3 < 0 
		or @auto_slivepositiontaking_7 < 0 
		or @auto_slivepositiontaking_8 < 0 

		or @auto_v2spositiontaking_1 < 0 
		or @auto_v2spositiontaking_2 < 0 
		or @auto_v2spositiontaking_3 < 0 
		or @auto_v2spositiontaking_7 < 0 
		or @auto_v2spositiontaking_8 < 0 
	--	or @auto_v2spositiontaking_9 < 0 
		or @auto_v2spositiontaking_20 < 0 
		or @auto_v2spositiontaking_9999 < 0 

		or @auto_v3spositiontaking_1 < 0 
		or @auto_v3spositiontaking_2 < 0 
		or @auto_v3spositiontaking_3 < 0 
		or @auto_v3spositiontaking_20 < 0 

		or @auto_v5spositiontaking_1 < 0 
		or @auto_v5spositiontaking_2 < 0 
		or @auto_v5spositiontaking_3 < 0 
		or @auto_v5spositiontaking_20 < 0
		or @auto_v5spositiontaking_9999 < 0  

		or @auto_v8spositiontaking_1 < 0 
		or @auto_v8spositiontaking_3 < 0 
		or @auto_v8spositiontaking_20 < 0 

		or @auto_v10spositiontaking_1 < 0 
		or @auto_v10spositiontaking_2 < 0 
		or @auto_v10spositiontaking_3 < 0 
		or @auto_v10spositiontaking_20 < 0 

		or @auto_v11spositiontaking_1 < 0 
		or @auto_v11spositiontaking_20 < 0 

		or @auto_v99spositiontaking_1 < 0 
		or @auto_v99spositiontaking_2 < 0 
		or @auto_v99spositiontaking_3 < 0 
		or @auto_v99spositiontaking_9 < 0 
		or @auto_v99spositiontaking_20 < 0 
		or @auto_v99spositiontaking_9999 < 0 	

		or @auto_spositiontaking_1 >0.9 
		or @auto_spositiontaking_2 >0.9 
		or @auto_spositiontaking_3 >0.9 
		or @auto_spositiontaking_4 >0.9 
		or @auto_spositiontaking_5 >0.9 
		or @auto_spositiontaking_6 >0.9 
		or @auto_spositiontaking_7 >0.9 
		or @auto_spositiontaking_8 >0.9 
		or @auto_spositiontaking_9 >0.9 
		or @auto_spositiontaking_10 >0.9 
		or @auto_v2spositiontaking_10 >0.9 
		or @auto_v3spositiontaking_10 >0.9 
		or @auto_v5spositiontaking_10 >0.9 
		or @auto_v8spositiontaking_10 >0.9 
		or @auto_v10spositiontaking_10 >0.9 
		or @auto_v11spositiontaking_10 >0.9 
		or @auto_v99spositiontaking_10 >0.9 	
		or @auto_spositiontaking_9999 >0.9 
		or @auto_slivepositiontaking_1 >0.9 
		or @auto_slivepositiontaking_3 >0.9 
		or @auto_slivepositiontaking_7 >0.9 
		or @auto_slivepositiontaking_8 >0.9 

		or @auto_v2spositiontaking_1 >0.9 
		or @auto_v2spositiontaking_2 >0.9 
		or @auto_v2spositiontaking_3 >0.9 
		or @auto_v2spositiontaking_7 >0.9 
		or @auto_v2spositiontaking_8 >0.9 
	--	or @auto_v2spositiontaking_9 >0.9 
		or @auto_v2spositiontaking_20 >0.9 
		or @auto_v2spositiontaking_9999 >0.9 

		or @auto_v3spositiontaking_1 >0.9 
		or @auto_v3spositiontaking_2 >0.9 
		or @auto_v3spositiontaking_3 >0.9 
		or @auto_v3spositiontaking_20 >0.9 

		or @auto_v5spositiontaking_1 >0.9 
		or @auto_v5spositiontaking_2 >0.9 
		or @auto_v5spositiontaking_3 >0.9 
		or @auto_v5spositiontaking_20 >0.9 
		or @auto_v5spositiontaking_9999 >0.9 

		or @auto_v8spositiontaking_1 >0.9 
		or @auto_v8spositiontaking_3 >0.9 
		or @auto_v8spositiontaking_20 >0.9 

		or @auto_v10spositiontaking_1 >0.9 
		or @auto_v10spositiontaking_2 >0.9 
		or @auto_v10spositiontaking_3 >0.9 
		or @auto_v10spositiontaking_20 >0.9 

		or @auto_v11spositiontaking_1 >0.9 
		or @auto_v11spositiontaking_20 >0.9 

		or @auto_v99spositiontaking_1 >0.9 
		or @auto_v99spositiontaking_2 >0.9 
		or @auto_v99spositiontaking_3 >0.9 
		or @auto_v99spositiontaking_9 >0.9
		or @auto_v99spositiontaking_20 >0.9 
		or @auto_v99spositiontaking_9999 >0.9 		
	BEGIN
		select @isvalid = 0, @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		return
	END
		--check if(!i3)
		--			n4<=s3+m3<=l4
		--		else u3+m3>=n4 and m3<=l4
		select @ErrType = ''
		select @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
		+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
		from custoverride as co with (NOLOCK) inner join
		(
						select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @auto_spositiontaking_1 as auto_spositiontaking,  @auto_slivepositiontaking_1 as auto_slivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @auto_spositiontaking_3 as auto_spositiontaking,  @auto_slivepositiontaking_3 as auto_slivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @auto_spositiontaking_7 as auto_spositiontaking,  @auto_slivepositiontaking_7 as auto_slivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @auto_spositiontaking_8 as auto_spositiontaking,  @auto_slivepositiontaking_8 as auto_slivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_4 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_5 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_6 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 1 as sporttype, @spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 2 as sporttype, @v2spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
	--		union all 	select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_7 as auto_spositiontaking,  0 as auto_slivepositiontaking
	--		union all 	select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_8 as auto_spositiontaking,  0 as auto_slivepositiontaking
	--		union all 	select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 2 as sporttype, @v2spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 3 as sporttype, @v3spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking		
			union all 	select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 99 as sporttype, @v99spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking


		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		inner join #tmp_Sports sports on b.sporttype = sports.ID
		inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	where co.custid = @srecommend 
		and (
				((b.auto_spositiontaking=0) and (b.spositiontaking+b.mpositiontaking>co.maxpositiontaking or b.spositiontaking+b.mpositiontaking<co.minpositiontaking)) or 
				((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.auto_slivepositiontaking=0) and (b.slivepositiontaking+b.mlivepositiontaking>co.maxlivepositiontaking or b.slivepositiontaking+b.mlivepositiontaking<co.minlivepositiontaking)) or
				((b.auto_spositiontaking>0) and (b.mpositiontaking>co.maxpositiontaking)) or 
				((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.auto_slivepositiontaking>0) and (b.mlivepositiontaking>co.maxlivepositiontaking)) or
				
				((b.auto_spositiontaking>0) and (b.mpositiontaking + b.auto_spositiontaking<co.minpositiontaking)) or 
				((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.auto_slivepositiontaking>0) and (b.mlivepositiontaking + b.auto_slivepositiontaking<co.minlivepositiontaking))
			)

	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode = 4
		Select @ErrMsg = 	case @Language  
							when 'E' then 'Wrong position taking (min/max set by company).' + '<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language)
					end
		return
	END		

		--check m3<=m4
		select @ErrType = ''
		select @ErrType = @ErrType + sports.name + '-' + bettype.name + '-Max:'+ cast((scs.mpositiontaking) as varchar(10))
		+ case when b.sporttype = 1 and b.bettype in (1,3,7,8) then '--Live:'+ cast((scs.mlivepositiontaking) as varchar(10)) else '' end + '<br>'
		from custsetting as scs with (NOLOCK) inner join
		(
						select 1 as bettype, 1 as sporttype, @spositiontaking_1 as spositiontaking, @slivepositiontaking_1 as slivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @auto_spositiontaking_1 as auto_spositiontaking,  @auto_slivepositiontaking_1 as auto_slivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @spositiontaking_3 as spositiontaking, @slivepositiontaking_3 as slivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @auto_spositiontaking_3 as auto_spositiontaking,  @auto_slivepositiontaking_3 as auto_slivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @spositiontaking_7 as spositiontaking, @slivepositiontaking_7 as slivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @auto_spositiontaking_7 as auto_spositiontaking,  @auto_slivepositiontaking_7 as auto_slivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @spositiontaking_8 as spositiontaking, @slivepositiontaking_8 as slivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @auto_spositiontaking_8 as auto_spositiontaking,  @auto_slivepositiontaking_8 as auto_slivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @spositiontaking_4 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_4 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @spositiontaking_5 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_5 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @spositiontaking_6 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_6 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99spositiontaking_10 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_10 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 1 as sporttype, @spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 2 as sporttype, @v2spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
	--		union all 	select 7 as bettype, 2 as sporttype, @v2spositiontaking_7 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_7 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_7 as auto_spositiontaking,  0 as auto_slivepositiontaking
	--		union all 	select 8 as bettype, 2 as sporttype, @v2spositiontaking_8 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_8 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_8 as auto_spositiontaking,  0 as auto_slivepositiontaking
	--		union all 	select 9 as bettype, 2 as sporttype, @v2spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 2 as sporttype, @v2spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v2mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v2spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 3 as sporttype, @v3spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v3spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			
			union all 	select 1 as bettype, 5 as sporttype, @v5spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v5spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking
			
			union all 	select 1 as bettype, 8 as sporttype, @v8spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v8spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			
			union all 	select 1 as bettype, 10 as sporttype, @v10spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v10spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			
			union all 	select 1 as bettype, 11 as sporttype, @v11spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 20 as bettype, 11 as sporttype, @v11spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v11spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking

			union all 	select 1 as bettype, 99 as sporttype, @v99spositiontaking_1 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_1 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99spositiontaking_2 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_2 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99spositiontaking_3 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_3 as auto_spositiontaking,  0 as auto_slivepositiontaking		
			union all 	select 20 as bettype, 99 as sporttype, @v99spositiontaking_20 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_20 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9 as bettype, 99 as sporttype, @v99spositiontaking_9 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_9 as auto_spositiontaking,  0 as auto_slivepositiontaking
			union all 	select 9999 as bettype, 99 as sporttype, @v99spositiontaking_9999 as spositiontaking, 0 as slivepositiontaking, @v99mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @auto_v99spositiontaking_9999 as auto_spositiontaking,  0 as auto_slivepositiontaking
						
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		inner join #tmp_Sports sports on b.sporttype = sports.ID
		inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	where scs.custid = @srecommend and (
						scs.mpositiontaking<b.mpositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and scs.mlivepositiontaking<b.mlivepositiontaking)
						)

	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode = 5
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max for master set by company).' + '<br>' + @ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20003,@Language) + '<br>' + @ErrType
					end
		return
	END
				
	DROP TABLE #tmp_Sports
	DROP TABLE #tmp_Bettype
	return
END
GO