/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Com_CheckParam]
	@custid int OUTPUT,
	@currency int, 
	@credit money,
	@groupa decimal(9,8), 
	@groupb decimal(9,8), 
	@groupc decimal(9,8), 
	@groupd decimal(9,8),
	@discountcs decimal(9,8),
	--1x2
	@discount1x2 decimal(9,8)=0, 

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
	--@v2spositiontaking_9 smallmoney,
	@v2spositiontaking_20 smallmoney,
	@v2spositiontaking_9999 SMALLMONEY = 0,
		
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
	@v99spositiontaking_9 smallmoney,
	@v99spositiontaking_20 smallmoney,	
	@v99spositiontaking_9999 smallmoney,			
	
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
	@mpositiontaking_9999 smallmoney = 0,
	
	@mlivepositiontaking_1 smallmoney,
	@mlivepositiontaking_3 smallmoney,
	@mlivepositiontaking_7 smallmoney,
	@mlivepositiontaking_8 smallmoney,
	
	@v2mpositiontaking_1 smallmoney,
	@v2mpositiontaking_2 smallmoney,
	@v2mpositiontaking_3 smallmoney,
	@v2mpositiontaking_7 smallmoney,
	@v2mpositiontaking_8 smallmoney,
	--@v2mpositiontaking_9 smallmoney,
	@v2mpositiontaking_20 smallmoney,
	@v2mpositiontaking_9999 SMALLMONEY =0,
		
	@v3mpositiontaking_1 smallmoney,
	@v3mpositiontaking_2 smallmoney,
	@v3mpositiontaking_3 smallmoney,
	@v3mpositiontaking_20 smallmoney,

	@v5mpositiontaking_1 smallmoney,
	@v5mpositiontaking_2 smallmoney,
	@v5mpositiontaking_3 smallmoney,
	@v5mpositiontaking_20 smallmoney,
	@v5mpositiontaking_9999 smallmoney = 0,

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
	@v99mpositiontaking_9 smallmoney,
	@v99mpositiontaking_20 smallmoney,
	@v99mpositiontaking_9999 smallmoney,	
		
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
	
	@alivepositiontaking_1 smallmoney,
	@alivepositiontaking_3 smallmoney,
	@alivepositiontaking_7 smallmoney,
	@alivepositiontaking_8 smallmoney,
	
	@v2apositiontaking_1 smallmoney,
	@v2apositiontaking_2 smallmoney,
	@v2apositiontaking_3 smallmoney,
	@v2apositiontaking_7 smallmoney,
	@v2apositiontaking_8 smallmoney,
	--@v2apositiontaking_9 smallmoney,
	@v2apositiontaking_20 smallmoney,
	@v2apositiontaking_9999 SMALLMONEY =0,
	
	@v3apositiontaking_1 smallmoney,
	@v3apositiontaking_2 smallmoney,
	@v3apositiontaking_3 smallmoney,
	@v3apositiontaking_20 smallmoney,

	@v5apositiontaking_1 smallmoney,
	@v5apositiontaking_2 smallmoney,
	@v5apositiontaking_3 smallmoney,
	@v5apositiontaking_20 smallmoney,
	@v5apositiontaking_9999 smallmoney = 0,

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
	@v99apositiontaking_9 smallmoney,
	@v99apositiontaking_20 smallmoney,	
	@v99apositiontaking_9999 smallmoney,	
	
	@discountMyanmarOdds DECIMAL(9,8)=0,
	
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
Task : Check valid parameters when insert super.
DB: DBCUST/CUSTDB
Original:

Revisions:
    - 20090131@Phuc: check valid currency
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Check commission for 1x2 
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20100828@Henry: Add Number Game + Mix Parlay Mixed Sports
	- 20101026@Lukas: Add max per ball (number game)
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, exchange by link database)
	- 20140612@Johnson: Add bettype Others for soccer & tennis [Redmine #16903]
	- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20160627@Winnie: Out right PT [Redmine #59438]
	- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
	- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
	- 20170807@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]  	
	- 20181106@Johnson: add Happy 5 [Redmine: #104006]
	- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]	
	- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
	- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]

Param's Explanation:
• @ErrCode:
    = 0: Checking successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
	declare @ErrType varchar(1000)
	DECLARE @Site NVARCHAR (50), @RoleID TINYINT, @recommend INT

	--AGENT SITE
	SET NOCOUNT ON

	----- /David @ 09 JUN 2015 -------------------

	Select @isvalid = 1
	if 
		@discountcs<0 or @discountcs>0.2
		or @discount1x2 <0 or @discount1x2 >0.2  --1x2
		or @groupa<0 or @groupa>0.2
		or @groupb<0 or @groupb>0.2
		or @groupc<0 or @groupc>0.2
		or @groupd<0 or @groupd>0.2
		OR @discountMyanmarOdds < 0 OR @discountMyanmarOdds > 0.01 -- Myanma Odds
	BEGIN
		select @isvalid = 0, @ErrCode = 1
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Invalid commission rate.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
					end
		return
	END

	If Not Exists(Select 1 From Exchange (nolock) Where ExchangeID = @Currency)
	Begin
		Select  @isvalid = 0, @ErrCode = 5
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Invalid currency.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40015,@Language)
					end
		return
	End
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
		--or @v2spositiontaking_9  <0
		or @v2spositiontaking_20  <0
		OR @v2spositiontaking_9999 < 0
					
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
		or @v99spositiontaking_9 <0
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
		--or @v2mpositiontaking_9  <0
		or @v2mpositiontaking_20  <0
		OR @v2mpositiontaking_9999 < 0 
				
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
		or @v99mpositiontaking_9 <0
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
		--or @v2apositiontaking_9  <0
		or @v2apositiontaking_20  <0
		OR @v2apositiontaking_9999 < 0 
				
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
		or @v99apositiontaking_9 <0
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
		or @v2spositiontaking_10 >0.9
		or @v3spositiontaking_10 >0.9
		or @v5spositiontaking_10 >0.9
		or @v8spositiontaking_10 >0.9
		or @v10spositiontaking_10 >0.9
		or @v11spositiontaking_10 >0.9
		or @v99spositiontaking_10 >0.9
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
		OR @v2spositiontaking_9999 > 0.9
				
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
		or @v99spositiontaking_9 >0.9
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
		or @v2mpositiontaking_10 >0.9
		or @v3mpositiontaking_10 >0.9
		or @v5mpositiontaking_10 >0.9
		or @v8mpositiontaking_10 >0.9
		or @v10mpositiontaking_10 >0.9
		or @v11mpositiontaking_10 >0.9
		or @v99mpositiontaking_10 >0.9
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
		OR @v2mpositiontaking_9999 > 0.9
				
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
		or @v99mpositiontaking_9 >0.9
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
		or @v2apositiontaking_10 >0.9
		or @v3apositiontaking_10 >0.9
		or @v5apositiontaking_10 >0.9
		or @v8apositiontaking_10 >0.9
		or @v10apositiontaking_10 >0.9
		or @v11apositiontaking_10 >0.9
		or @v99apositiontaking_10 >0.9
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
		OR @v2apositiontaking_9999 > 0.9 
		
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
		or @v99apositiontaking_9 >0.9
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
		or @v2spositiontaking_10  <  @v2mpositiontaking_10 
		or @v3spositiontaking_10  <  @v3mpositiontaking_10 
		or @v5spositiontaking_10  <  @v5mpositiontaking_10 
		or @v8spositiontaking_10  <  @v8mpositiontaking_10 
		or @v10spositiontaking_10  <  @v10mpositiontaking_10 
		or @v11spositiontaking_10  <  @v11mpositiontaking_10 
		or @v99spositiontaking_10  <  @v99mpositiontaking_10 
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
		OR @v2spositiontaking_9999 < @v2mpositiontaking_9999
				
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
		or @v99spositiontaking_9 < @v99mpositiontaking_9
		or @v99spositiontaking_20   <  @v99mpositiontaking_20	
		or @v99spositiontaking_9999   <  @v99mpositiontaking_9999		
				  
		or @mpositiontaking_1   <  @apositiontaking_1  
		or @mpositiontaking_2   <  @apositiontaking_2  
		or @mpositiontaking_3	<  @apositiontaking_3  
		or @mpositiontaking_4   <  @apositiontaking_4  
		or @mpositiontaking_5   <  @apositiontaking_5  
		or @mpositiontaking_6   <  @apositiontaking_6  
		or @mpositiontaking_7   <  @apositiontaking_7  
		or @mpositiontaking_8   <  @apositiontaking_8  
		or @mpositiontaking_9   <  @apositiontaking_9  
		or @mpositiontaking_10  <  @apositiontaking_10
		or @v2mpositiontaking_10  <  @v2apositiontaking_10
		or @v3mpositiontaking_10  <  @v3apositiontaking_10
		or @v5mpositiontaking_10  <  @v5apositiontaking_10
		or @v8mpositiontaking_10  <  @v8apositiontaking_10
		or @v10mpositiontaking_10  <  @v10apositiontaking_10
		or @v11mpositiontaking_10  <  @v11apositiontaking_10
		or @v99mpositiontaking_10  <  @v99apositiontaking_10
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
		--or @v2mpositiontaking_9   <  @v2apositiontaking_9
		or @v2mpositiontaking_20   <  @v2apositiontaking_20
		OR @v2mpositiontaking_9999 < @v2apositiontaking_9999
		
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
		 
	BEGIN
		select @isvalid = 0, @ErrCode = 3
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		return
	END

	return
END	
Go

