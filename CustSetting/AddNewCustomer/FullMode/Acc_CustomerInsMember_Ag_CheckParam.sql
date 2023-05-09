/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Ag_CheckParam]
	@custid int OUTPUT,
	@playerdiscount decimal(9,8),
	@playerdiscountcs decimal(9,8),
	@playerdiscount1x2 decimal(9,8), --1x2
	
	@credit money,
	@recommend int,
	@ugroup varchar(5),
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
	
	@apositiontaking_9999 smallmoney =0,
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
	@v2apositiontaking_9999 smallmoney = 0,

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
	
	-- MyanmarOdds	
	@discountMyanmarOdds DECIMAL(9,8) = 0,
	
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
Task : check valid parameters when add new member
DB: DBCUST/CUSTDB
Original:

Revisions:
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090514@PhuongDao: Check 1x2 Commission
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: Remove Min-Max Bet HR 
    - 20100826@Henry: remove mix parlay of basketball + add new section for MixParlay for Mix Sports + Setting for Numbergame
    - 20101029@Johnson: Include max per ball for number game
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20110929@Johnson: Add more groups under Won currency
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)
	- 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
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

Param's Explanation:
• @ErrCode:
    = 0: Checking successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

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
	DECLARE @Site NVARCHAR (50), @RoleID TINYINT

	Select @isvalid = 1
	if 
		@playerdiscount<0 or @playerdiscount>0.2
		or @playerdiscountcs<0 or @playerdiscountcs>0.2
		or @playerdiscount1x2<0 or @playerdiscount1x2>0.2  --1x2
		or @discountMyanmarOdds < 0 or @discountMyanmarOdds > 0.01		
	BEGIN
		select @isvalid = 0, @ErrCode = 106
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

	if @credit <0
		or @recommend <=0
		or @ugroup not in ('a','b','c','d','hka','hkb','hkc','hkd','indoa','indob','indoc','indod','dea','deb','dec','ded')
	BEGIN
		select @isvalid = 0, @ErrCode = 102
		Select @ErrMsg = 	case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per ball/ Max per match/ Credit/ Agent name/ user group.'
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
		or @v99apositiontaking_9 <0
		or @v99apositiontaking_20  <0
		or @v99apositiontaking_9999  <0					
		
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
		or @v99apositiontaking_9 >0.9
		or @v99apositiontaking_20  >0.9		
		or @v99apositiontaking_9999  >0.9													
	BEGIN
		select @isvalid = 0, @ErrCode = 103
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
					end
		return
	END
	--check n2<=a1<=l2
		select @ErrType = ''
		select @ErrType = @ErrType + sports.name + '-'+ bettype.name + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
		+ case when b.sporttype = 1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
		from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
	--		union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking
	--		union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking
	--		union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9999 as bettype, 2 as sporttype, @v2apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking

			union all 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
			union all	select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all	select 9999 as bettype, 99 as sporttype, @v99apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking
			
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		inner join #tmp_Sports sports on b.sporttype = sports.ID
		inner join #tmp_Bettype bettype on b.bettype = bettype.ID
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)) or 
						((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking)))

	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END	
	
	DROP TABLE #tmp_Sports
	DROP TABLE #tmp_Bettype
	return
END
GO
