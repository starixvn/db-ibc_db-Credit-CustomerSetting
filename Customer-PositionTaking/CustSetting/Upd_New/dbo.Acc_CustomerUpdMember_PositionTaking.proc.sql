ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_PositionTaking]
	@custid INT,--memberid		
		
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
	@apositiontaking_9999 SMALLMONEY = 0,
	
	@alivepositiontaking_1 SMALLMONEY,
	@alivepositiontaking_3 SMALLMONEY,
	@alivepositiontaking_7 SMALLMONEY,
	@alivepositiontaking_8 SMALLMONEY,
	
	@v2apositiontaking_1 SMALLMONEY,
	@v2apositiontaking_2 SMALLMONEY,
	@v2apositiontaking_3 SMALLMONEY,
	@v2apositiontaking_7 SMALLMONEY,
	@v2apositiontaking_8 SMALLMONEY,
	--@v2apositiontaking_9 SMALLMONEY,
	@v2apositiontaking_20 SMALLMONEY,
	
	@v3apositiontaking_1 SMALLMONEY,
	@v3apositiontaking_2 SMALLMONEY,
	@v3apositiontaking_3 SMALLMONEY,
	@v3apositiontaking_20 SMALLMONEY,

	@v5apositiontaking_1 SMALLMONEY,
	@v5apositiontaking_2 SMALLMONEY,
	@v5apositiontaking_3 SMALLMONEY,
	@v5apositiontaking_20 SMALLMONEY,
	@v5apositiontaking_9999 SMALLMONEY = 0,

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
	@v99apositiontaking_9 SMALLMONEY,
	@v99apositiontaking_20 SMALLMONEY,
	
	@v154apositiontaking_20 SMALLMONEY,
		
	--v161
	@v161apositiontaking_81 smallmoney, 
	@v161apositiontaking_83 smallmoney, 	
	@v161apositiontaking_86 smallmoney, 
	@v161apositiontaking_88 smallmoney = 0, 
	@v161alivepositiontaking_85 smallmoney,
	@v161alivepositiontaking_86 smallmoney,
	@v161alivepositiontaking_87 smallmoney,
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0,
	
	-- Outright PT for sports
	@v2apositiontaking_10 smallmoney = 0,
	@v3apositiontaking_10 smallmoney = 0,
	@v5apositiontaking_10 smallmoney = 0,
	@v8apositiontaking_10 smallmoney = 0,
	@v10apositiontaking_10 smallmoney = 0,
	@v11apositiontaking_10 smallmoney = 0,
	@v99apositiontaking_10 smallmoney = 0,
	     
	     
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
	@UpdatePositiontakingv154 BIT = 1,
	
	@UpdatePositiontakingv161 BIT = 1,
	
	@UserID INT,	
	
	@IP varchar(15)='',	
	@Language VARCHAR(2)= 'E',	
	@SubAccID INT = 0, --Sub-AccountID	
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080516@Thien
Task : Update Member's Position Taking
DB: DBTXN/bodb02
Original:

Revisions:
   	- 20080810@Thien: This SP is used by Acc_CustomerUpdMoveMember also
    - 20081023@Phuc: Add new sporttype 201, bettype 3, hard code copy min/max/maxperbet/PT for 201 from 2 sporttype 
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100830@Henry: Amend to update for Number Game + Mix Parlay Mixed Sports
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Write Log Old values
	- 20110801@Lukas: (Number Game)
				- Add new bettypes: Warrior, Next Combo, Number Group
				- Remove Dead ball Over/Under
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20130614@Johnson: check a1 with valid range of a1
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131031@Johnson: Apply execrep when update pt on member
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)					
	- 20131113@Johnson: Use execrept Acc_CustSetting_00/Acc_CustSetting3rd_00 to correct after update pt on member 
	- 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
	- 20150804@Johnson:  Write log value from db if not change when update multiple [Redmine: #40880]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
	
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON
----- David @ 09 JUN 2015 -------------------
	DECLARE @tmp_Sports TABLE (SportType TINYINT, SportName NVARCHAR(50))
	DECLARE @tmp_Bettype TABLE (TypeID INT, TypeNamee NVARCHAR(50))
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)

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

	BEGIN TRY		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
----- /David @ 09 JUN 2015 -------------------
declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()


DECLARE 	
	@Recommend INT,	
	@MRecommend INT,
	@SRecommend INT,
	@UserName varchar(40),
	@ErrAcc varchar(4000), @ErrType varchar(4000),
	--m1
	@mpositiontaking_1 SMALLMONEY,
	@mpositiontaking_2 SMALLMONEY,
	@mpositiontaking_3 SMALLMONEY,
	@mpositiontaking_4 SMALLMONEY,
	@mpositiontaking_5 SMALLMONEY,
	@mpositiontaking_6 SMALLMONEY,
	@mpositiontaking_7 SMALLMONEY,
	@mpositiontaking_8 SMALLMONEY,
	@mpositiontaking_9 SMALLMONEY,
	@mpositiontaking_10 SMALLMONEY,
	@mpositiontaking_9999 SMALLMONEY,
	
	@mlivepositiontaking_1 SMALLMONEY,
	@mlivepositiontaking_3 SMALLMONEY,
	@mlivepositiontaking_7 SMALLMONEY,
	@mlivepositiontaking_8 SMALLMONEY,
	
	@v2mpositiontaking_1 SMALLMONEY,
	@v2mpositiontaking_2 SMALLMONEY,
	@v2mpositiontaking_3 SMALLMONEY,
	@v2mpositiontaking_7 SMALLMONEY,
	@v2mpositiontaking_8 SMALLMONEY,
	--@v2mpositiontaking_9 SMALLMONEY,
	@v2mpositiontaking_20 SMALLMONEY,

	@v3mpositiontaking_1 SMALLMONEY,
	@v3mpositiontaking_2 SMALLMONEY,
	@v3mpositiontaking_3 SMALLMONEY,
	@v3mpositiontaking_20 SMALLMONEY,

	@v5mpositiontaking_1 SMALLMONEY,
	@v5mpositiontaking_2 SMALLMONEY,
	@v5mpositiontaking_3 SMALLMONEY,
	@v5mpositiontaking_20 SMALLMONEY,
	@v5mpositiontaking_9999 SMALLMONEY,

	@v8mpositiontaking_1 SMALLMONEY,
	@v8mpositiontaking_3 SMALLMONEY,
	@v8mpositiontaking_20 SMALLMONEY,

	@v10mpositiontaking_1 SMALLMONEY,
	@v10mpositiontaking_2 SMALLMONEY,
	@v10mpositiontaking_3 SMALLMONEY,
	@v10mpositiontaking_20 SMALLMONEY,

	@v11mpositiontaking_1 SMALLMONEY,
	@v11mpositiontaking_20 SMALLMONEY,

	@v99mpositiontaking_1 SMALLMONEY,
	@v99mpositiontaking_2 SMALLMONEY,
	@v99mpositiontaking_3 SMALLMONEY,
	@v99mpositiontaking_9 SMALLMONEY,
	@v99mpositiontaking_20 SMALLMONEY,
	
	@v154mpositiontaking_20 SMALLMONEY,
	
	
	--v161
	@v161mpositiontaking_81 smallmoney, 
	@v161mpositiontaking_83 smallmoney, 	 
	@v161mpositiontaking_86 smallmoney, 
	@v161mpositiontaking_88 smallmoney,
	@v161mlivepositiontaking_85 smallmoney,
	@v161mlivepositiontaking_86 smallmoney,
	@v161mlivepositiontaking_87 smallmoney,
	@v161mlivepositiontaking_89 smallmoney,
	@v161mlivepositiontaking_90 smallmoney,
	
	
	--m3
	@mapositiontaking_1_max SMALLMONEY,
	@mapositiontaking_2_max SMALLMONEY,
	@mapositiontaking_3_max SMALLMONEY,
	@mapositiontaking_4_max SMALLMONEY,
	@mapositiontaking_5_max SMALLMONEY,
	@mapositiontaking_6_max SMALLMONEY,
	@mapositiontaking_7_max SMALLMONEY,
	@mapositiontaking_8_max SMALLMONEY,
	@mapositiontaking_9_max SMALLMONEY,
	@mapositiontaking_10_max SMALLMONEY,
	@mapositiontaking_9999_max SMALLMONEY,
	
	@malivepositiontaking_1_max SMALLMONEY,
	@malivepositiontaking_3_max SMALLMONEY,
	@malivepositiontaking_7_max SMALLMONEY,
	@malivepositiontaking_8_max SMALLMONEY,
	
	@v2mapositiontaking_1_max SMALLMONEY,
	@v2mapositiontaking_2_max SMALLMONEY,
	@v2mapositiontaking_3_max SMALLMONEY,
	@v2mapositiontaking_7_max SMALLMONEY,
	@v2mapositiontaking_8_max SMALLMONEY,
	--@v2mapositiontaking_9_max SMALLMONEY,
	@v2mapositiontaking_20_max SMALLMONEY,
	
	@v3mapositiontaking_1_max SMALLMONEY,
	@v3mapositiontaking_2_max SMALLMONEY,
	@v3mapositiontaking_3_max SMALLMONEY,
	@v3mapositiontaking_20_max SMALLMONEY,

	@v5mapositiontaking_1_max SMALLMONEY,
	@v5mapositiontaking_2_max SMALLMONEY,
	@v5mapositiontaking_3_max SMALLMONEY,
	@v5mapositiontaking_20_max SMALLMONEY,
	@v5mapositiontaking_9999_max SMALLMONEY = 0,

	@v8mapositiontaking_1_max SMALLMONEY,
	@v8mapositiontaking_3_max SMALLMONEY,
	@v8mapositiontaking_20_max SMALLMONEY,

	@v10mapositiontaking_1_max SMALLMONEY,
	@v10mapositiontaking_2_max SMALLMONEY,
	@v10mapositiontaking_3_max SMALLMONEY,
	@v10mapositiontaking_20_max SMALLMONEY,

	@v11mapositiontaking_1_max SMALLMONEY,
	@v11mapositiontaking_20_max SMALLMONEY,

	@v99mapositiontaking_1_max SMALLMONEY,
	@v99mapositiontaking_2_max SMALLMONEY,
	@v99mapositiontaking_3_max SMALLMONEY,
	@v99mapositiontaking_9_max SMALLMONEY,	
	@v99mapositiontaking_20_max SMALLMONEY,	
	
	@v154mapositiontaking_20_max SMALLMONEY,
	
	
	--v161
	@v161mapositiontaking_81_max smallmoney, 
	@v161mapositiontaking_83_max smallmoney, 	
	@v161mapositiontaking_86_max smallmoney, 
	@v161mapositiontaking_88_max smallmoney, 
	@v161malivepositiontaking_85_max smallmoney,
	@v161malivepositiontaking_86_max smallmoney,
	@v161malivepositiontaking_87_max smallmoney,
	@v161malivepositiontaking_89_max smallmoney,
	@v161malivepositiontaking_90_max smallmoney,
	
	
	--old_a1
	@old_apositiontaking_1 SMALLMONEY,
	@old_apositiontaking_2 SMALLMONEY,
	@old_apositiontaking_3 SMALLMONEY,
	@old_apositiontaking_4 SMALLMONEY,
	@old_apositiontaking_5 SMALLMONEY,
	@old_apositiontaking_6 SMALLMONEY,
	@old_apositiontaking_7 SMALLMONEY,
	@old_apositiontaking_8 SMALLMONEY,
	@old_apositiontaking_9 SMALLMONEY,
	@old_apositiontaking_10 SMALLMONEY,
	@old_apositiontaking_9999 SMALLMONEY,
	
	@old_alivepositiontaking_1 SMALLMONEY,
	@old_alivepositiontaking_3 SMALLMONEY,
	@old_alivepositiontaking_7 SMALLMONEY,
	@old_alivepositiontaking_8 SMALLMONEY,
	
	@old_v2apositiontaking_1 SMALLMONEY,
	@old_v2apositiontaking_2 SMALLMONEY,
	@old_v2apositiontaking_3 SMALLMONEY,
	@old_v2apositiontaking_7 SMALLMONEY,
	@old_v2apositiontaking_8 SMALLMONEY,
	--@old_v2apositiontaking_9 SMALLMONEY,
	@old_v2apositiontaking_20 SMALLMONEY,

	@old_v3apositiontaking_1 SMALLMONEY,
	@old_v3apositiontaking_2 SMALLMONEY,
	@old_v3apositiontaking_3 SMALLMONEY,
	@old_v3apositiontaking_20 SMALLMONEY,

	@old_v5apositiontaking_1 SMALLMONEY,
	@old_v5apositiontaking_2 SMALLMONEY,
	@old_v5apositiontaking_3 SMALLMONEY,
	@old_v5apositiontaking_20 SMALLMONEY,
	@old_v5apositiontaking_9999 SMALLMONEY,

	@old_v8apositiontaking_1 SMALLMONEY,
	@old_v8apositiontaking_3 SMALLMONEY,
	@old_v8apositiontaking_20 SMALLMONEY,

	@old_v10apositiontaking_1 SMALLMONEY,
	@old_v10apositiontaking_2 SMALLMONEY,
	@old_v10apositiontaking_3 SMALLMONEY,
	@old_v10apositiontaking_20 SMALLMONEY,

	@old_v11apositiontaking_1 SMALLMONEY,
	@old_v11apositiontaking_20 SMALLMONEY,

	@old_v99apositiontaking_1 SMALLMONEY,
	@old_v99apositiontaking_2 SMALLMONEY,
	@old_v99apositiontaking_3 SMALLMONEY,
	@old_v99apositiontaking_9 SMALLMONEY,	
	@old_v99apositiontaking_20 SMALLMONEY,	
	
	@old_v154apositiontaking_20 SMALLMONEY,
	
	
	--v161
	@old_v161apositiontaking_81 smallmoney, 
	@old_v161apositiontaking_83 smallmoney, 	 
	@old_v161apositiontaking_86 smallmoney, 
	@old_v161apositiontaking_88 smallmoney,
	@old_v161alivepositiontaking_85 smallmoney,
	@old_v161alivepositiontaking_86 smallmoney,
	@old_v161alivepositiontaking_87 smallmoney,
	@old_v161alivepositiontaking_89 smallmoney,
	@old_v161alivepositiontaking_90 smallmoney,
	
	
	
	--s1
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
	--@v2spositiontaking_9 SMALLMONEY,
	@v2spositiontaking_20 SMALLMONEY,
	
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
	@v99spositiontaking_9 SMALLMONEY,
	@v99spositiontaking_20 SMALLMONEY,	
	
	@v154spositiontaking_20 SMALLMONEY,
		
	
	--v161
	@v161spositiontaking_81 smallmoney, 
	@v161spositiontaking_83 smallmoney, 	 
	@v161spositiontaking_86 smallmoney, 
	@v161spositiontaking_88 smallmoney,
	@v161slivepositiontaking_85 smallmoney,
	@v161slivepositiontaking_86 smallmoney,
	@v161slivepositiontaking_87 smallmoney,
	@v161slivepositiontaking_89 smallmoney,
	@v161slivepositiontaking_90 smallmoney,
	
	
	
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
	--@auto_v2spositiontaking_9 SMALLMONEY,
	@auto_v2spositiontaking_20 SMALLMONEY,
	
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
	@auto_v99spositiontaking_9 SMALLMONEY,
	@auto_v99spositiontaking_20 SMALLMONEY,
	
	@auto_v154spositiontaking_20 SMALLMONEY,
	
	
	--v161
	@auto_v161spositiontaking_81 smallmoney, 
	@auto_v161spositiontaking_83 smallmoney, 	 
	@auto_v161spositiontaking_86 smallmoney, 
	@auto_v161spositiontaking_88 smallmoney,
	@auto_v161slivepositiontaking_85 smallmoney,
	@auto_v161slivepositiontaking_86 smallmoney,
	@auto_v161slivepositiontaking_87 smallmoney,
	@auto_v161slivepositiontaking_89 smallmoney,
	@auto_v161slivepositiontaking_90 smallmoney,
	
	
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
	--@max_v2spositiontaking_9 SMALLMONEY,
	@max_v2spositiontaking_20 SMALLMONEY,
	
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
	@max_v99spositiontaking_9 SMALLMONEY,
	@max_v99spositiontaking_20 SMALLMONEY,	
	
	@max_v154spositiontaking_20 SMALLMONEY,
	
	
	--v161
	@max_v161spositiontaking_81 smallmoney, 
	@max_v161spositiontaking_83 smallmoney, 	 
	@max_v161spositiontaking_86 smallmoney, 
	@max_v161spositiontaking_88 smallmoney,
	@max_v161slivepositiontaking_85 smallmoney,
	@max_v161slivepositiontaking_86 smallmoney,
	@max_v161slivepositiontaking_87 smallmoney,
	@max_v161slivepositiontaking_89 smallmoney,
	@max_v161slivepositiontaking_90 smallmoney,
	
	
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
	--@auto_v2spositiontaking_mem_9 SMALLMONEY,
	@auto_v2spositiontaking_mem_20 SMALLMONEY,
	
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
	@auto_v99spositiontaking_mem_9 SMALLMONEY,
	@auto_v99spositiontaking_mem_20 SMALLMONEY,	
	
	@auto_v154spositiontaking_mem_20 SMALLMONEY,
	
	
	--v161
	@auto_v161spositiontaking_mem_81 smallmoney, 
	@auto_v161spositiontaking_mem_83 smallmoney, 	 
	@auto_v161spositiontaking_mem_86 smallmoney, 
	@auto_v161spositiontaking_mem_88 smallmoney,
	@auto_v161slivepositiontaking_mem_85 smallmoney,
	@auto_v161slivepositiontaking_mem_86 smallmoney,
	@auto_v161slivepositiontaking_mem_87 smallmoney,
	@auto_v161slivepositiontaking_mem_89 smallmoney,
	@auto_v161slivepositiontaking_mem_90 smallmoney,
	
	
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
	--@isauto_v2spositiontaking_9 BIT,
	@isauto_v2spositiontaking_20 BIT,
	
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
	@isauto_v99spositiontaking_9 BIT,
	@isauto_v99spositiontaking_20 BIT,
	
	@isauto_v154spositiontaking_20 BIT,
	
	@isauto_v161spositiontaking_81 BIT, 
	@isauto_v161spositiontaking_83 BIT, 	 
	@isauto_v161spositiontaking_86 BIT, 
	@isauto_v161spositiontaking_88 BIT,
	@isauto_v161slivepositiontaking_85 BIT, 
	@isauto_v161slivepositiontaking_86 BIT, 
	@isauto_v161slivepositiontaking_87 BIT, 
	@isauto_v161slivepositiontaking_89 BIT, 
	@isauto_v161slivepositiontaking_90 BIT, 
	
	
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
	--@isauto_v2spositiontaking_mem_9 BIT,
	@isauto_v2spositiontaking_mem_20 BIT,
	
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
	@isauto_v99spositiontaking_mem_9 BIT,
	@isauto_v99spositiontaking_mem_20 BIT,
	
	@isauto_v154spositiontaking_mem_20 BIT,
	
	
	--v161
	@isauto_v161spositiontaking_mem_81 BIT,
	@isauto_v161spositiontaking_mem_83 BIT,	 
	@isauto_v161spositiontaking_mem_86 BIT,
	@isauto_v161spositiontaking_mem_88 BIT,
	@isauto_v161slivepositiontaking_mem_85 BIT,
	@isauto_v161slivepositiontaking_mem_86 BIT,
	@isauto_v161slivepositiontaking_mem_87 BIT,
	@isauto_v161slivepositiontaking_mem_89 BIT,
	@isauto_v161slivepositiontaking_mem_90 BIT,
	
	

	--um2
	@auto_mpositiontaking_1 SMALLMONEY,
	@auto_mpositiontaking_2 SMALLMONEY,
	@auto_mpositiontaking_3 SMALLMONEY,
	@auto_mpositiontaking_4 SMALLMONEY,
	@auto_mpositiontaking_5 SMALLMONEY,
	@auto_mpositiontaking_6 SMALLMONEY,
	@auto_mpositiontaking_7 SMALLMONEY,
	@auto_mpositiontaking_8 SMALLMONEY,
	@auto_mpositiontaking_9 SMALLMONEY,
	@auto_mpositiontaking_10 SMALLMONEY,
	@auto_mpositiontaking_9999 SMALLMONEY,
	@auto_mlivepositiontaking_1 SMALLMONEY,
	@auto_mlivepositiontaking_3 SMALLMONEY,
	@auto_mlivepositiontaking_7 SMALLMONEY,
	@auto_mlivepositiontaking_8 SMALLMONEY,
	
	@auto_v2mpositiontaking_1 SMALLMONEY,
	@auto_v2mpositiontaking_2 SMALLMONEY,
	@auto_v2mpositiontaking_3 SMALLMONEY,
	@auto_v2mpositiontaking_7 SMALLMONEY,
	@auto_v2mpositiontaking_8 SMALLMONEY,
	--@auto_v2mpositiontaking_9 SMALLMONEY,
	@auto_v2mpositiontaking_20 SMALLMONEY,
	
	@auto_v3mpositiontaking_1 SMALLMONEY,
	@auto_v3mpositiontaking_2 SMALLMONEY,
	@auto_v3mpositiontaking_3 SMALLMONEY,
	@auto_v3mpositiontaking_20 SMALLMONEY,

	@auto_v5mpositiontaking_1 SMALLMONEY,
	@auto_v5mpositiontaking_2 SMALLMONEY,
	@auto_v5mpositiontaking_3 SMALLMONEY,
	@auto_v5mpositiontaking_20 SMALLMONEY,
	@auto_v5mpositiontaking_9999 SMALLMONEY,

	@auto_v8mpositiontaking_1 SMALLMONEY,
	@auto_v8mpositiontaking_3 SMALLMONEY,
	@auto_v8mpositiontaking_20 SMALLMONEY,

	@auto_v10mpositiontaking_1 SMALLMONEY,
	@auto_v10mpositiontaking_2 SMALLMONEY,
	@auto_v10mpositiontaking_3 SMALLMONEY,
	@auto_v10mpositiontaking_20 SMALLMONEY,

	@auto_v11mpositiontaking_1 SMALLMONEY,
	@auto_v11mpositiontaking_20 SMALLMONEY,

	@auto_v99mpositiontaking_1 SMALLMONEY,
	@auto_v99mpositiontaking_2 SMALLMONEY,
	@auto_v99mpositiontaking_3 SMALLMONEY,
	@auto_v99mpositiontaking_9 SMALLMONEY,
	@auto_v99mpositiontaking_20 SMALLMONEY,
	
	@auto_v154mpositiontaking_20 SMALLMONEY,
	
	
	--v161
	@auto_v161mpositiontaking_81 SMALLMONEY,
	@auto_v161mpositiontaking_83 SMALLMONEY,	
	@auto_v161mpositiontaking_86 SMALLMONEY,
	@auto_v161mpositiontaking_88 SMALLMONEY, 
	@auto_v161mlivepositiontaking_85 SMALLMONEY,
	@auto_v161mlivepositiontaking_86 SMALLMONEY,
	@auto_v161mlivepositiontaking_87 SMALLMONEY,
	@auto_v161mlivepositiontaking_89 SMALLMONEY,
	@auto_v161mlivepositiontaking_90 SMALLMONEY,
	
	
	--im2
	@isauto_mpositiontaking_1 BIT,
	@isauto_mpositiontaking_2 BIT,
	@isauto_mpositiontaking_3 BIT,
	@isauto_mpositiontaking_4 BIT,
	@isauto_mpositiontaking_5 BIT,
	@isauto_mpositiontaking_6 BIT,
	@isauto_mpositiontaking_7 BIT,
	@isauto_mpositiontaking_8 BIT,
	@isauto_mpositiontaking_9 BIT,
	@isauto_mpositiontaking_10 BIT,
	@isauto_mpositiontaking_9999 BIT,
	
	@isauto_mlivepositiontaking_1 BIT,
	@isauto_mlivepositiontaking_3 BIT,
	@isauto_mlivepositiontaking_7 BIT,
	@isauto_mlivepositiontaking_8 BIT,
	
	@isauto_v2mpositiontaking_1 BIT,
	@isauto_v2mpositiontaking_2 BIT,
	@isauto_v2mpositiontaking_3 BIT,
	@isauto_v2mpositiontaking_7 BIT,
	@isauto_v2mpositiontaking_8 BIT,
	--@isauto_v2mpositiontaking_9 BIT,
	@isauto_v2mpositiontaking_20 BIT,
	
	@isauto_v3mpositiontaking_1 BIT,
	@isauto_v3mpositiontaking_2 BIT,
	@isauto_v3mpositiontaking_3 BIT,
	@isauto_v3mpositiontaking_20 BIT,

	@isauto_v5mpositiontaking_1 BIT,
	@isauto_v5mpositiontaking_2 BIT,
	@isauto_v5mpositiontaking_3 BIT,
	@isauto_v5mpositiontaking_20 BIT,
	@isauto_v5mpositiontaking_9999 BIT,

	@isauto_v8mpositiontaking_1 BIT,
	@isauto_v8mpositiontaking_3 BIT,
	@isauto_v8mpositiontaking_20 BIT,

	@isauto_v10mpositiontaking_1 BIT,
	@isauto_v10mpositiontaking_2 BIT,
	@isauto_v10mpositiontaking_3 BIT,
	@isauto_v10mpositiontaking_20 BIT,

	@isauto_v11mpositiontaking_1 BIT,
	@isauto_v11mpositiontaking_20 BIT,

	@isauto_v99mpositiontaking_1 BIT,
	@isauto_v99mpositiontaking_2 BIT,
	@isauto_v99mpositiontaking_3 BIT,
	@isauto_v99mpositiontaking_9 BIT,
	@isauto_v99mpositiontaking_20 BIT,
	
	@isauto_v154mpositiontaking_20 BIT,
	
	--v161
	@isauto_v161mpositiontaking_81 BIT,
	@isauto_v161mpositiontaking_83 BIT, 
	@isauto_v161mpositiontaking_86 BIT,
	@isauto_v161mpositiontaking_88 BIT,
	@isauto_v161mlivepositiontaking_85 BIT,
	@isauto_v161mlivepositiontaking_86 BIT,
	@isauto_v161mlivepositiontaking_87 BIT,
	@isauto_v161mlivepositiontaking_89 BIT,
	@isauto_v161mlivepositiontaking_90 BIT,
	
	
	--im1
	@isauto_mpositiontaking_mem_1 BIT,
	@isauto_mpositiontaking_mem_2 BIT,
	@isauto_mpositiontaking_mem_3 BIT,
	@isauto_mpositiontaking_mem_4 BIT,
	@isauto_mpositiontaking_mem_5 BIT,
	@isauto_mpositiontaking_mem_6 BIT,
	@isauto_mpositiontaking_mem_7 BIT,
	@isauto_mpositiontaking_mem_8 BIT,
	@isauto_mpositiontaking_mem_9 BIT,
	@isauto_mpositiontaking_mem_10 BIT,
	
	@isauto_mpositiontaking_mem_9999 BIT,
	@isauto_mlivepositiontaking_mem_1 BIT,
	@isauto_mlivepositiontaking_mem_3 BIT,
	@isauto_mlivepositiontaking_mem_7 BIT,
	@isauto_mlivepositiontaking_mem_8 BIT,
	
	@isauto_v2mpositiontaking_mem_1 BIT,
	@isauto_v2mpositiontaking_mem_2 BIT,
	@isauto_v2mpositiontaking_mem_3 BIT,
	@isauto_v2mpositiontaking_mem_7 BIT,
	@isauto_v2mpositiontaking_mem_8 BIT,
	--@isauto_v2mpositiontaking_mem_9 BIT,
	@isauto_v2mpositiontaking_mem_20 BIT,
	
	@isauto_v3mpositiontaking_mem_1 BIT,
	@isauto_v3mpositiontaking_mem_2 BIT,
	@isauto_v3mpositiontaking_mem_3 BIT,
	@isauto_v3mpositiontaking_mem_20 BIT,
	
	@isauto_v5mpositiontaking_mem_1 BIT,
	@isauto_v5mpositiontaking_mem_2 BIT,
	@isauto_v5mpositiontaking_mem_3 BIT,
	@isauto_v5mpositiontaking_mem_20 BIT,
	@isauto_v5mpositiontaking_mem_9999 BIT,
	
	@isauto_v8mpositiontaking_mem_1 BIT,
	@isauto_v8mpositiontaking_mem_3 BIT,
	@isauto_v8mpositiontaking_mem_20 BIT,
	
	@isauto_v10mpositiontaking_mem_1 BIT,
	@isauto_v10mpositiontaking_mem_2 BIT,
	@isauto_v10mpositiontaking_mem_3 BIT,
	@isauto_v10mpositiontaking_mem_20 BIT,
	
	@isauto_v11mpositiontaking_mem_1 BIT,
	@isauto_v11mpositiontaking_mem_20 BIT,

	@isauto_v99mpositiontaking_mem_1 BIT,
	@isauto_v99mpositiontaking_mem_2 BIT,
	@isauto_v99mpositiontaking_mem_3 BIT,
	@isauto_v99mpositiontaking_mem_9 BIT,
	@isauto_v99mpositiontaking_mem_20 BIT,	
		
	@isauto_v154mpositiontaking_mem_20 BIT,
	
	--v161
	@isauto_v161mpositiontaking_mem_81 BIT,
	@isauto_v161mpositiontaking_mem_83 BIT, 
	@isauto_v161mpositiontaking_mem_86 BIT,
	@isauto_v161mpositiontaking_mem_88 BIT,
	@isauto_v161mlivepositiontaking_mem_85 BIT,
	@isauto_v161mlivepositiontaking_mem_86 BIT,
	@isauto_v161mlivepositiontaking_mem_87 BIT,
	@isauto_v161mlivepositiontaking_mem_89 BIT,
	@isauto_v161mlivepositiontaking_mem_90 BIT,
	

	--um1
	@auto_mpositiontaking_mem_1 SMALLMONEY,
	@auto_mpositiontaking_mem_2 SMALLMONEY,
	@auto_mpositiontaking_mem_3 SMALLMONEY,
	@auto_mpositiontaking_mem_4 SMALLMONEY,
	@auto_mpositiontaking_mem_5 SMALLMONEY,
	@auto_mpositiontaking_mem_6 SMALLMONEY,
	@auto_mpositiontaking_mem_7 SMALLMONEY,
	@auto_mpositiontaking_mem_8 SMALLMONEY,
	@auto_mpositiontaking_mem_9 SMALLMONEY,
	@auto_mpositiontaking_mem_10 SMALLMONEY,
	@auto_mpositiontaking_mem_9999 SMALLMONEY,
	@auto_mlivepositiontaking_mem_1 SMALLMONEY,
	@auto_mlivepositiontaking_mem_3 SMALLMONEY,
	@auto_mlivepositiontaking_mem_7 SMALLMONEY,
	@auto_mlivepositiontaking_mem_8 SMALLMONEY,
	
	@auto_v2mpositiontaking_mem_1 SMALLMONEY,
	@auto_v2mpositiontaking_mem_2 SMALLMONEY,
	@auto_v2mpositiontaking_mem_3 SMALLMONEY,
	@auto_v2mpositiontaking_mem_7 SMALLMONEY,
	@auto_v2mpositiontaking_mem_8 SMALLMONEY,
	--@auto_v2mpositiontaking_mem_9 SMALLMONEY,
	@auto_v2mpositiontaking_mem_20 SMALLMONEY,
	
	@auto_v3mpositiontaking_mem_1 SMALLMONEY,
	@auto_v3mpositiontaking_mem_2 SMALLMONEY,
	@auto_v3mpositiontaking_mem_3 SMALLMONEY,
	@auto_v3mpositiontaking_mem_20 SMALLMONEY,
	
	@auto_v5mpositiontaking_mem_1 SMALLMONEY,
	@auto_v5mpositiontaking_mem_2 SMALLMONEY,
	@auto_v5mpositiontaking_mem_3 SMALLMONEY,
	@auto_v5mpositiontaking_mem_20 SMALLMONEY,
	@auto_v5mpositiontaking_mem_9999 SMALLMONEY,
	
	@auto_v8mpositiontaking_mem_1 SMALLMONEY,
	@auto_v8mpositiontaking_mem_3 SMALLMONEY,
	@auto_v8mpositiontaking_mem_20 SMALLMONEY,
	
	@auto_v10mpositiontaking_mem_1 SMALLMONEY,
	@auto_v10mpositiontaking_mem_2 SMALLMONEY,
	@auto_v10mpositiontaking_mem_3 SMALLMONEY,
	@auto_v10mpositiontaking_mem_20 SMALLMONEY,
	
	@auto_v11mpositiontaking_mem_1 SMALLMONEY,
	@auto_v11mpositiontaking_mem_20 SMALLMONEY,

	@auto_v99mpositiontaking_mem_1 SMALLMONEY,
	@auto_v99mpositiontaking_mem_2 SMALLMONEY,
	@auto_v99mpositiontaking_mem_3 SMALLMONEY,
	@auto_v99mpositiontaking_mem_9 SMALLMONEY,
	@auto_v99mpositiontaking_mem_20 SMALLMONEY,
	
	@auto_v154mpositiontaking_mem_20 SMALLMONEY,
	
	--v161
	@auto_v161mpositiontaking_mem_81 SMALLMONEY,
	@auto_v161mpositiontaking_mem_83 SMALLMONEY,
	@auto_v161mpositiontaking_mem_86 SMALLMONEY,
	@auto_v161mpositiontaking_mem_88 SMALLMONEY, 
	@auto_v161mlivepositiontaking_mem_85 SMALLMONEY,
	@auto_v161mlivepositiontaking_mem_86 SMALLMONEY,
	@auto_v161mlivepositiontaking_mem_87 SMALLMONEY,
	@auto_v161mlivepositiontaking_mem_89 SMALLMONEY,
	@auto_v161mlivepositiontaking_mem_90 SMALLMONEY,
	
	--cs_ap =iff(im,a2:iif(i1|i3,m3-m1,min(m3-m1,s4-s1-m1)))
	@cs_ap_1 smallmoney,@cs_ap_2 smallmoney,@cs_ap_3 smallmoney,@cs_ap_4 smallmoney,@cs_ap_5 smallmoney,@cs_ap_6 smallmoney,@cs_ap_7 smallmoney,@cs_ap_8 smallmoney,@cs_ap_9 smallmoney,@cs_ap_10 smallmoney,@cs_ap_9999 smallmoney,
	@cs_alp_1 smallmoney,@cs_alp_3 smallmoney,@cs_alp_7 smallmoney,@cs_alp_8 smallmoney,
	@cs_v2ap_1 smallmoney,@cs_v2ap_2 smallmoney,@cs_v2ap_3 smallmoney,@cs_v2ap_7 smallmoney,@cs_v2ap_8 smallmoney,@cs_v2ap_20 smallmoney,
	@cs_v3ap_1 smallmoney,@cs_v3ap_2 smallmoney,@cs_v3ap_3 smallmoney,@cs_v3ap_20 smallmoney,
	@cs_v5ap_1 smallmoney,@cs_v5ap_2 smallmoney,@cs_v5ap_3 smallmoney,@cs_v5ap_20 smallmoney,@cs_v5ap_9999 smallmoney,
	@cs_v8ap_1 smallmoney,@cs_v8ap_3 smallmoney,@cs_v8ap_20 smallmoney,
	@cs_v10ap_1 smallmoney,@cs_v10ap_2 smallmoney,@cs_v10ap_3 smallmoney,@cs_v10ap_20 smallmoney,
	@cs_v11ap_1 smallmoney,@cs_v11ap_20 smallmoney,
	@cs_v154ap_20 smallmoney,
	@cs_v99ap_1 smallmoney,@cs_v99ap_2 smallmoney,@cs_v99ap_3 smallmoney,@cs_v99ap_9 smallmoney,@cs_v99ap_20 smallmoney,
	@cs_v161ap_81 smallmoney,@cs_v161ap_83 smallmoney,@cs_v161ap_86 smallmoney,@cs_v161ap_88 smallmoney,
	@cs_v161alp_85 smallmoney,@cs_v161alp_86 smallmoney,@cs_v161alp_87 smallmoney,@cs_v161alp_89 smallmoney,@cs_v161alp_90 smallmoney,

	-- Outright PT for sports
	@cs_v2ap_10 smallmoney,
	@cs_v3ap_10 smallmoney,
	@cs_v5ap_10 smallmoney,
	@cs_v8ap_10 smallmoney,
	@cs_v10ap_10 smallmoney,
	@cs_v11ap_10 smallmoney,
	@cs_v99ap_10 smallmoney,
	
	@isauto_v2mpositiontaking_mem_10 BIT,
	@isauto_v3mpositiontaking_mem_10 BIT,
	@isauto_v5mpositiontaking_mem_10 BIT,
	@isauto_v8mpositiontaking_mem_10 BIT,
	@isauto_v10mpositiontaking_mem_10 BIT,
	@isauto_v11mpositiontaking_mem_10 BIT,
	@isauto_v99mpositiontaking_mem_10 BIT,
	
	@auto_v2mpositiontaking_mem_10 SMALLMONEY,
	@auto_v3mpositiontaking_mem_10 SMALLMONEY,
	@auto_v5mpositiontaking_mem_10 SMALLMONEY,
	@auto_v8mpositiontaking_mem_10 SMALLMONEY,
	@auto_v10mpositiontaking_mem_10 SMALLMONEY,
	@auto_v11mpositiontaking_mem_10 SMALLMONEY,
	@auto_v99mpositiontaking_mem_10 SMALLMONEY,
	
	@auto_v2spositiontaking_mem_10 SMALLMONEY,
	@auto_v3spositiontaking_mem_10 SMALLMONEY,
	@auto_v5spositiontaking_mem_10 SMALLMONEY,
	@auto_v8spositiontaking_mem_10 SMALLMONEY,
	@auto_v10spositiontaking_mem_10 SMALLMONEY,
	@auto_v11spositiontaking_mem_10 SMALLMONEY,
	@auto_v99spositiontaking_mem_10 SMALLMONEY,
	
	@isauto_v2spositiontaking_mem_10 BIT,
	@isauto_v3spositiontaking_mem_10 BIT,
	@isauto_v5spositiontaking_mem_10 BIT,
	@isauto_v8spositiontaking_mem_10 BIT,
	@isauto_v10spositiontaking_mem_10 BIT,
	@isauto_v11spositiontaking_mem_10 BIT,
	@isauto_v99spositiontaking_mem_10 BIT,
	
	--a1_max
	@apositiontaking_1_max smallmoney,
	@apositiontaking_2_max smallmoney,
	@apositiontaking_3_max smallmoney,
	@apositiontaking_4_max smallmoney,
	@apositiontaking_5_max smallmoney,
	@apositiontaking_6_max smallmoney,
	@apositiontaking_7_max smallmoney,
	@apositiontaking_8_max smallmoney,
	@apositiontaking_9_max smallmoney,
	@apositiontaking_10_max smallmoney,
	@apositiontaking_9999_max smallmoney,
	
	@alivepositiontaking_1_max smallmoney,
	@alivepositiontaking_3_max smallmoney,
	@alivepositiontaking_7_max smallmoney,
	@alivepositiontaking_8_max smallmoney,
	
	@v2apositiontaking_1_max smallmoney,
	@v2apositiontaking_2_max smallmoney,
	@v2apositiontaking_3_max smallmoney,
	@v2apositiontaking_7_max smallmoney,
	@v2apositiontaking_8_max smallmoney,
	--@v2apositiontaking_9_max smallmoney,
	@v2apositiontaking_20_max smallmoney,
	
	@v3apositiontaking_1_max smallmoney,
	@v3apositiontaking_2_max smallmoney,
	@v3apositiontaking_3_max smallmoney,
	@v3apositiontaking_20_max smallmoney,

	@v5apositiontaking_1_max smallmoney,
	@v5apositiontaking_2_max smallmoney,
	@v5apositiontaking_3_max smallmoney,
	@v5apositiontaking_20_max smallmoney,
	@v5apositiontaking_9999_max smallmoney,

	@v8apositiontaking_1_max smallmoney,
	@v8apositiontaking_3_max smallmoney,
	@v8apositiontaking_20_max smallmoney,

	@v10apositiontaking_1_max smallmoney,
	@v10apositiontaking_2_max smallmoney,
	@v10apositiontaking_3_max smallmoney,
	@v10apositiontaking_20_max smallmoney,

	@v11apositiontaking_1_max smallmoney,
	@v11apositiontaking_20_max smallmoney,

	@v99apositiontaking_1_max smallmoney,
	@v99apositiontaking_2_max smallmoney,
	@v99apositiontaking_3_max smallmoney,
	@v99apositiontaking_9_max smallmoney,
	@v99apositiontaking_20_max smallmoney,
	
	@v154apositiontaking_20_max smallmoney,
	
	--v161
	@v161apositiontaking_81_max smallmoney,
	@v161apositiontaking_83_max smallmoney,
	@v161apositiontaking_86_max smallmoney,
	@v161apositiontaking_88_max smallmoney,
	@v161alivepositiontaking_85_max smallmoney,
	@v161alivepositiontaking_86_max smallmoney,
	@v161alivepositiontaking_87_max smallmoney,
	@v161alivepositiontaking_89_max smallmoney,
	@v161alivepositiontaking_90_max smallmoney,
	
	-- Outright PT for sports
	
	@v2mpositiontaking_10 SMALLMONEY,
	@v3mpositiontaking_10 SMALLMONEY,
	@v5mpositiontaking_10 SMALLMONEY,
	@v8mpositiontaking_10 SMALLMONEY,
	@v10mpositiontaking_10 SMALLMONEY,
	@v11mpositiontaking_10 SMALLMONEY,
	@v99mpositiontaking_10 SMALLMONEY,
	
	
	@v2mapositiontaking_10_max SMALLMONEY,
	@v3mapositiontaking_10_max SMALLMONEY,
	@v5mapositiontaking_10_max SMALLMONEY,
	@v8mapositiontaking_10_max SMALLMONEY,
	@v10mapositiontaking_10_max SMALLMONEY,
	@v11mapositiontaking_10_max SMALLMONEY,
	@v99mapositiontaking_10_max SMALLMONEY,
	
	@old_v2apositiontaking_10 SMALLMONEY,
	@old_v3apositiontaking_10 SMALLMONEY,
	@old_v5apositiontaking_10 SMALLMONEY,
	@old_v8apositiontaking_10 SMALLMONEY,
	@old_v10apositiontaking_10 SMALLMONEY,
	@old_v11apositiontaking_10 SMALLMONEY,
	@old_v99apositiontaking_10 SMALLMONEY,
	
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
	
	@max_v2spositiontaking_10 SMALLMONEY,
	@max_v3spositiontaking_10 SMALLMONEY,
	@max_v5spositiontaking_10 SMALLMONEY,
	@max_v8spositiontaking_10 SMALLMONEY,
	@max_v10spositiontaking_10 SMALLMONEY,
	@max_v11spositiontaking_10 SMALLMONEY,
	@max_v99spositiontaking_10 SMALLMONEY,
	
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
	
	@isauto_v2mpositiontaking_10 BIT,
	@isauto_v3mpositiontaking_10 BIT,
	@isauto_v5mpositiontaking_10 BIT,
	@isauto_v8mpositiontaking_10 BIT,
	@isauto_v10mpositiontaking_10 BIT,
	@isauto_v11mpositiontaking_10 BIT,
	@isauto_v99mpositiontaking_10 BIT,
	
	@v2apositiontaking_10_max smallmoney,
	@v3apositiontaking_10_max smallmoney,
	@v5apositiontaking_10_max smallmoney,
	@v8apositiontaking_10_max smallmoney,
	@v10apositiontaking_10_max smallmoney,
	@v11apositiontaking_10_max smallmoney,
	@v99apositiontaking_10_max smallmoney

	

SELECT 	
	@Recommend = recommend,
	@MRecommend = mrecommend,
	@SRecommend = srecommend,	
	@UserName = username
FROM custinfo WITH (NOLOCK)
WHERE CustID = @CustID

 --@apos_max = min(a4,a2,l2)
Select 	
	@apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_4_max = max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_5_max = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_6_max = max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	-- Outright PT for sports
	@v2apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v8apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v11apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_10_max = max(case when cs.bettype = 10 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	@apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@alivepositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@alivepositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@alivepositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@alivepositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),

	@v2apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_7_max = max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_8_max = max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	--@v2apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v2apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v3apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v3apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v5apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v5apositiontaking_9999_max = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v8apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v8apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v8apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v10apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v10apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v11apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v11apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@v99apositiontaking_1_max = max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_2_max = max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_3_max = max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_9_max = max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v99apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v154apositiontaking_20_max = max(case when cs.bettype = 20 and cs.sporttype=154 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end)
	
From 
	CustSetting as cs with (NOLOCK)
	LEFT JOIN custoverride as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @recommend


SELECT
	--v161
	@v161apositiontaking_81_max = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end),
	@v161apositiontaking_83_max = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end),	
	@v161apositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end),
	@v161apositiontaking_88_max = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end),
	
	@v161alivepositiontaking_85_max = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161alivepositiontaking_86_max = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161alivepositiontaking_87_max = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161alivepositiontaking_89_max = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end),
	@v161alivepositiontaking_90_max = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end)
FROM
	CustSetting3rd as cs3 with (NOLOCK)
	LEFT JOIN CustOverride3rd as co3 with (NOLOCK) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
Where cs3.CustID = @recommend


SELECT 
	@apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_1_max then scs.apositiontaking else @apositiontaking_1_max end else 0 end),
	@apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_2_max then scs.apositiontaking else @apositiontaking_2_max end else 0 end),
	@apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_3_max then scs.apositiontaking else @apositiontaking_3_max end else 0 end),
	@apositiontaking_4_max = max(case when scs.bettype = 4 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_4_max then scs.apositiontaking else @apositiontaking_4_max end else 0 end),
	@apositiontaking_5_max = max(case when scs.bettype = 5 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_5_max then scs.apositiontaking else @apositiontaking_5_max end else 0 end),
	@apositiontaking_6_max = max(case when scs.bettype = 6 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_6_max then scs.apositiontaking else @apositiontaking_6_max end else 0 end),
	@apositiontaking_7_max = max(case when scs.bettype = 7 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_7_max then scs.apositiontaking else @apositiontaking_7_max end else 0 end),
	@apositiontaking_8_max = max(case when scs.bettype = 8 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_8_max then scs.apositiontaking else @apositiontaking_8_max end else 0 end),
	@apositiontaking_9_max = max(case when scs.bettype = 9 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_9_max then scs.apositiontaking else @apositiontaking_9_max end else 0 end),
	@apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_10_max then scs.apositiontaking else @apositiontaking_10_max end else 0 end),
	
	-- Outright PT for sports
	@v2apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_10_max then scs.apositiontaking else @v2apositiontaking_10_max end else 0 end),
	@v3apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_10_max then scs.apositiontaking else @v3apositiontaking_10_max end else 0 end),
	@v5apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_10_max then scs.apositiontaking else @v5apositiontaking_10_max end else 0 end),
	@v8apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_10_max then scs.apositiontaking else @v8apositiontaking_10_max end else 0 end),
	@v10apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_10_max then scs.apositiontaking else @v10apositiontaking_10_max end else 0 end),
	@v11apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=11 then case when scs.apositiontaking<@v11apositiontaking_10_max then scs.apositiontaking else @v11apositiontaking_10_max end else 0 end),
	@v99apositiontaking_10_max = max(case when scs.bettype = 10 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_10_max then scs.apositiontaking else @v99apositiontaking_10_max end else 0 end),
	
	@apositiontaking_9999_max = max(case when scs.bettype = 9999 and scs.sporttype=1 then case when scs.apositiontaking<@apositiontaking_9999_max then scs.apositiontaking else @apositiontaking_9999_max end else 0 end),
	
	@alivepositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_1_max then scs.alivepositiontaking else @alivepositiontaking_1_max end else 0 end),
	@alivepositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_3_max then scs.alivepositiontaking else @alivepositiontaking_3_max end else 0 end),
	@alivepositiontaking_7_max = max(case when scs.bettype = 7 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_7_max then scs.alivepositiontaking else @alivepositiontaking_7_max end else 0 end),
	@alivepositiontaking_8_max = max(case when scs.bettype = 8 and scs.sporttype=1 then case when scs.alivepositiontaking<@alivepositiontaking_8_max then scs.alivepositiontaking else @alivepositiontaking_8_max end else 0 end),

	@v2apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_1_max then scs.apositiontaking else @v2apositiontaking_1_max end else 0 end),
	@v2apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_2_max then scs.apositiontaking else @v2apositiontaking_2_max end else 0 end),
	@v2apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_3_max then scs.apositiontaking else @v2apositiontaking_3_max end else 0 end),
	@v2apositiontaking_7_max = max(case when scs.bettype = 7 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_7_max then scs.apositiontaking else @v2apositiontaking_7_max end else 0 end),
	@v2apositiontaking_8_max = max(case when scs.bettype = 8 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_8_max then scs.apositiontaking else @v2apositiontaking_8_max end else 0 end),
	--@v2apositiontaking_9_max = max(case when scs.bettype = 9 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_9_max then scs.apositiontaking else @v2apositiontaking_9_max end else 0 end),
	@v2apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=2 then case when scs.apositiontaking<@v2apositiontaking_20_max then scs.apositiontaking else @v2apositiontaking_20_max end else 0 end),

	@v3apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_1_max then scs.apositiontaking else @v3apositiontaking_1_max end else 0 end),
	@v3apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_2_max then scs.apositiontaking else @v3apositiontaking_2_max end else 0 end),
	@v3apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_3_max then scs.apositiontaking else @v3apositiontaking_3_max end else 0 end),
	@v3apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=3 then case when scs.apositiontaking<@v3apositiontaking_20_max then scs.apositiontaking else @v3apositiontaking_20_max end else 0 end),

	@v5apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_1_max then scs.apositiontaking else @v5apositiontaking_1_max end else 0 end),
	@v5apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_2_max then scs.apositiontaking else @v5apositiontaking_2_max end else 0 end),
	@v5apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_3_max then scs.apositiontaking else @v5apositiontaking_3_max end else 0 end),
	@v5apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_20_max then scs.apositiontaking else @v5apositiontaking_20_max end else 0 end),
	@v5apositiontaking_9999_max = max(case when scs.bettype = 9999 and scs.sporttype=5 then case when scs.apositiontaking<@v5apositiontaking_9999_max then scs.apositiontaking else @v5apositiontaking_9999_max end else 0 end),

	@v8apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_1_max then scs.apositiontaking else @v8apositiontaking_1_max end else 0 end),
	@v8apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_3_max then scs.apositiontaking else @v8apositiontaking_3_max end else 0 end),
	@v8apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=8 then case when scs.apositiontaking<@v8apositiontaking_20_max then scs.apositiontaking else @v8apositiontaking_20_max end else 0 end),

	@v10apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_1_max then scs.apositiontaking else @v10apositiontaking_1_max end else 0 end),
	@v10apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_2_max then scs.apositiontaking else @v10apositiontaking_2_max end else 0 end),
	@v10apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_3_max then scs.apositiontaking else @v10apositiontaking_3_max end else 0 end),
	@v10apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=10 then case when scs.apositiontaking<@v10apositiontaking_20_max then scs.apositiontaking else @v10apositiontaking_20_max end else 0 end),

	@v11apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=11 then case when scs.apositiontaking<@v11apositiontaking_1_max then scs.apositiontaking else @v11apositiontaking_1_max end else 0 end),
	@v11apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=11 then case when scs.apositiontaking<@v11apositiontaking_20_max then scs.apositiontaking else @v11apositiontaking_20_max end else 0 end),

	@v99apositiontaking_1_max = max(case when scs.bettype = 1 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_1_max then scs.apositiontaking else @v99apositiontaking_1_max end else 0 end),
	@v99apositiontaking_2_max = max(case when scs.bettype = 2 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_2_max then scs.apositiontaking else @v99apositiontaking_2_max end else 0 end),
	@v99apositiontaking_3_max = max(case when scs.bettype = 3 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_3_max then scs.apositiontaking else @v99apositiontaking_3_max end else 0 end),
	@v99apositiontaking_9_max = max(case when scs.bettype = 9 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_9_max then scs.apositiontaking else @v99apositiontaking_9_max end else 0 end),
	@v99apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=99 then case when scs.apositiontaking<@v99apositiontaking_20_max then scs.apositiontaking else @v99apositiontaking_20_max end else 0 end),		
	@v154apositiontaking_20_max = max(case when scs.bettype = 20 and scs.sporttype=154 then case when scs.apositiontaking<@v154apositiontaking_20_max then scs.apositiontaking else @v154apositiontaking_20_max end else 0 end)
	
From
	Custsetting as scs WITH(NOLOCK)
WHERE 
	scs.custid = @srecommend

SELECT
	@v161apositiontaking_81_max = max(case when scs3.bettype = 81 and scs3.sporttype=161 then case when scs3.apositiontaking<@v161apositiontaking_81_max then scs3.apositiontaking else @v161apositiontaking_81_max end else 0 end),
	@v161apositiontaking_83_max = max(case when scs3.bettype = 83 and scs3.sporttype=161 then case when scs3.apositiontaking<@v161apositiontaking_83_max then scs3.apositiontaking else @v161apositiontaking_83_max end else 0 end),	
	@v161apositiontaking_86_max = max(case when scs3.bettype = 86 and scs3.sporttype=161 then case when scs3.apositiontaking<@v161apositiontaking_86_max then scs3.apositiontaking else @v161apositiontaking_86_max end else 0 end),
	@v161apositiontaking_88_max = max(case when scs3.bettype = 88 and scs3.sporttype=161 then case when scs3.apositiontaking<@v161apositiontaking_88_max then scs3.apositiontaking else @v161apositiontaking_88_max end else 0 end),
	
	@v161alivepositiontaking_85_max = max(case when scs3.bettype = 85 and scs3.sporttype=161 then case when scs3.alivepositiontaking<@v161alivepositiontaking_85_max then scs3.alivepositiontaking else @v161alivepositiontaking_85_max end else 0 end),
	@v161alivepositiontaking_86_max = max(case when scs3.bettype = 86 and scs3.sporttype=161 then case when scs3.alivepositiontaking<@v161alivepositiontaking_86_max then scs3.alivepositiontaking else @v161alivepositiontaking_86_max end else 0 end),
	@v161alivepositiontaking_87_max = max(case when scs3.bettype = 87 and scs3.sporttype=161 then case when scs3.alivepositiontaking<@v161alivepositiontaking_87_max then scs3.alivepositiontaking else @v161alivepositiontaking_87_max end else 0 end),
	@v161alivepositiontaking_89_max = max(case when scs3.bettype = 89 and scs3.sporttype=161 then case when scs3.alivepositiontaking<@v161alivepositiontaking_89_max then scs3.alivepositiontaking else @v161alivepositiontaking_89_max end else 0 end),
	@v161alivepositiontaking_90_max = max(case when scs3.bettype = 90 and scs3.sporttype=161 then case when scs3.alivepositiontaking<@v161alivepositiontaking_90_max then scs3.alivepositiontaking else @v161alivepositiontaking_90_max end else 0 end)
FROM
	CustSetting3rd as Scs3 with (NOLOCK)
WHERE
	scs3.custid = @srecommend


--=iff(im,a2:iif(i1|i3,m3-m1,min(m3-m1,s4-s1-m1)))
Select 
	@cs_ap_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_2 = max(case when cs.bettype = 2 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_4 = max(case when cs.bettype = 4 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_5 = max(case when cs.bettype = 5 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_6 = max(case when cs.bettype = 6 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_9 = max(case when cs.bettype = 9 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_ap_10 = max(case when cs.bettype = 10 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	-- Outright PT for sports
	@cs_v2ap_10 = max(case when cs.bettype = 10 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_10 = max(case when cs.bettype = 10 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_10 = max(case when cs.bettype = 10 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v8ap_10 = max(case when cs.bettype = 10 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_10 = max(case when cs.bettype = 10 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v11ap_10 = max(case when cs.bettype = 10 and cs.sporttype=11 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_10 = max(case when cs.bettype = 10 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
		
	@cs_ap_9999 = max(case when cs.bettype = 9999 and cs.sporttype=1 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)  then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_alp_1 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	@cs_alp_3 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	@cs_alp_7 = max(case when cs.bettype = 7 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	@cs_alp_8 = max(case when cs.bettype = 8 and cs.sporttype=1 then case when (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1) then acs.alivepositiontaking else case when not (cs.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 ) then mcs.mlivepositiontaking-cs.mlivepositiontaking else case when mcs.mlivepositiontaking-cs.mlivepositiontaking<=scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking then  mcs.mlivepositiontaking-cs.mlivepositiontaking else scs.slivepositiontaking-cs.slivepositiontaking-cs.mlivepositiontaking end end end else 0 end),
	
	@cs_v2ap_1 = max(case when cs.bettype = 1 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_2 = max(case when cs.bettype = 2 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_3 = max(case when cs.bettype = 3 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_7 = max(case when cs.bettype = 7 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_8 = max(case when cs.bettype = 8 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	--@cs_v2ap_9 = max(case when cs.bettype = 9 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v2ap_20 = max(case when cs.bettype = 20 and cs.sporttype=2 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v3ap_1 = max(case when cs.bettype = 1 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_2 = max(case when cs.bettype = 2 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_3 = max(case when cs.bettype = 3 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v3ap_20 = max(case when cs.bettype = 20 and cs.sporttype=3 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v5ap_1 = max(case when cs.bettype = 1 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_2 = max(case when cs.bettype = 2 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_3 = max(case when cs.bettype = 3 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_20 = max(case when cs.bettype = 20 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v5ap_9999 = max(case when cs.bettype = 9999 and cs.sporttype=5 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v8ap_1 = max(case when cs.bettype = 1 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v8ap_3 = max(case when cs.bettype = 3 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v8ap_20 = max(case when cs.bettype = 20 and cs.sporttype=8 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v10ap_1 = max(case when cs.bettype = 1 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_2 = max(case when cs.bettype = 2 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_3 = max(case when cs.bettype = 3 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v10ap_20 = max(case when cs.bettype = 20 and cs.sporttype=10 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v11ap_1 = max(case when cs.bettype = 1 and cs.sporttype=11 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v11ap_20 = max(case when cs.bettype = 20 and cs.sporttype=11 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),

	@cs_v99ap_1 = max(case when cs.bettype = 1 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_2 = max(case when cs.bettype = 2 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_3 = max(case when cs.bettype = 3 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_9 = max(case when cs.bettype = 9 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v99ap_20 = max(case when cs.bettype = 20 and cs.sporttype=99 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v154ap_20 = max(case when cs.bettype = 20 and cs.sporttype=154 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end)
		
From CustSetting as cs with (NOLOCK) 
	inner join custsetting as scs with (nolock) on scs.custid = @srecommend and scs.bettype = cs.bettype and scs.sporttype = cs.sporttype
	inner join custsetting as mcs with (nolock) on mcs.custid = @mrecommend and mcs.bettype = cs.bettype and mcs.sporttype = cs.sporttype
	inner join custsetting as acs with (nolock) on acs.custid = @recommend and acs.bettype = cs.bettype and acs.sporttype = cs.sporttype
WHERE 	
	cs.custid = @custid


SELECT
	--v161
	@cs_v161ap_81 = max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1) then acs3.apositiontaking else case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0 ) then mcs3.mpositiontaking-cs3.mpositiontaking else case when mcs3.mpositiontaking-cs3.mpositiontaking<=scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking then  mcs3.mpositiontaking-cs3.mpositiontaking else scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking end end end else 0 end),
	@cs_v161ap_83 = max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1) then acs3.apositiontaking else case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0 ) then mcs3.mpositiontaking-cs3.mpositiontaking else case when mcs3.mpositiontaking-cs3.mpositiontaking<=scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking then  mcs3.mpositiontaking-cs3.mpositiontaking else scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking end end end else 0 end),
	@cs_v161ap_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1) then acs3.apositiontaking else case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0 ) then mcs3.mpositiontaking-cs3.mpositiontaking else case when mcs3.mpositiontaking-cs3.mpositiontaking<=scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking then  mcs3.mpositiontaking-cs3.mpositiontaking else scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking end end end else 0 end),
	@cs_v161ap_88 = max(case when cs3.bettype = 88 and cs3.sporttype=161 then case when (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1) then acs3.apositiontaking else case when not (cs3.isautopositiontaking=0 and mcs3.isautopositiontaking=0 ) then mcs3.mpositiontaking-cs3.mpositiontaking else case when mcs3.mpositiontaking-cs3.mpositiontaking<=scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking then  mcs3.mpositiontaking-cs3.mpositiontaking else scs3.spositiontaking-cs3.spositiontaking-cs3.mpositiontaking end end end else 0 end),
	@cs_v161alp_85 = max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1) then acs3.alivepositiontaking else case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0 ) then mcs3.mlivepositiontaking-cs3.mlivepositiontaking else case when mcs3.mlivepositiontaking-cs3.mlivepositiontaking<=scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking then  mcs3.mlivepositiontaking-cs3.mlivepositiontaking else scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking end end end else 0 end),
	@cs_v161alp_86 = max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1) then acs3.alivepositiontaking else case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0 ) then mcs3.mlivepositiontaking-cs3.mlivepositiontaking else case when mcs3.mlivepositiontaking-cs3.mlivepositiontaking<=scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking then  mcs3.mlivepositiontaking-cs3.mlivepositiontaking else scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking end end end else 0 end),
	@cs_v161alp_87 = max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1) then acs3.alivepositiontaking else case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0 ) then mcs3.mlivepositiontaking-cs3.mlivepositiontaking else case when mcs3.mlivepositiontaking-cs3.mlivepositiontaking<=scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking then  mcs3.mlivepositiontaking-cs3.mlivepositiontaking else scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking end end end else 0 end),
	@cs_v161alp_89 = max(case when cs3.bettype = 89 and cs3.sporttype=161 then case when (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1) then acs3.alivepositiontaking else case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0 ) then mcs3.mlivepositiontaking-cs3.mlivepositiontaking else case when mcs3.mlivepositiontaking-cs3.mlivepositiontaking<=scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking then  mcs3.mlivepositiontaking-cs3.mlivepositiontaking else scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking end end end else 0 end),
	@cs_v161alp_90 = max(case when cs3.bettype = 90 and cs3.sporttype=161 then case when (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1) then acs3.alivepositiontaking else case when not (cs3.isautolivepositiontaking=0 and mcs3.isautolivepositiontaking=0 ) then mcs3.mlivepositiontaking-cs3.mlivepositiontaking else case when mcs3.mlivepositiontaking-cs3.mlivepositiontaking<=scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking then  mcs3.mlivepositiontaking-cs3.mlivepositiontaking else scs3.slivepositiontaking-cs3.slivepositiontaking-cs3.mlivepositiontaking end end end else 0 end)
FROM
	CustSetting3rd as cs3 WITH (NOLOCK)  
	INNER JOIN custsetting3rd as scs3 WITH (NOLOCK) ON scs3.custid = @srecommend and scs3.bettype = cs3.bettype and scs3.sporttype = cs3.sporttype
	INNER JOIN custsetting3rd as mcs3 WITH (NOLOCK) ON mcs3.custid = @mrecommend and mcs3.bettype = cs3.bettype and mcs3.sporttype = cs3.sporttype
	INNER JOIN custsetting3rd as acs3 WITH (NOLOCK) ON acs3.custid = @recommend and acs3.bettype = cs3.bettype and acs3.sporttype = cs3.sporttype
WHERE cs3.custid = @custid


select 
	@apositiontaking_1_max = case when @apositiontaking_1_max <= @cs_ap_1 then @apositiontaking_1_max else @cs_ap_1 end,
	@apositiontaking_2_max = case when @apositiontaking_2_max <= @cs_ap_2 then @apositiontaking_2_max else @cs_ap_2 end,
	@apositiontaking_3_max = case when @apositiontaking_3_max <= @cs_ap_3 then @apositiontaking_3_max else @cs_ap_3 end,
	@apositiontaking_4_max = case when @apositiontaking_4_max <= @cs_ap_4 then @apositiontaking_4_max else @cs_ap_4 end,
	@apositiontaking_5_max = case when @apositiontaking_5_max <= @cs_ap_5 then @apositiontaking_5_max else @cs_ap_5 end,
	@apositiontaking_6_max = case when @apositiontaking_6_max <= @cs_ap_6 then @apositiontaking_6_max else @cs_ap_6 end,
	@apositiontaking_7_max = case when @apositiontaking_7_max <= @cs_ap_7 then @apositiontaking_7_max else @cs_ap_7 end,
	@apositiontaking_8_max = case when @apositiontaking_8_max <= @cs_ap_8 then @apositiontaking_8_max else @cs_ap_8 end,
	@apositiontaking_9_max = case when @apositiontaking_9_max <= @cs_ap_9 then @apositiontaking_9_max else @cs_ap_9 end,
	@apositiontaking_10_max = case when @apositiontaking_10_max <= @cs_ap_10 then @apositiontaking_10_max else @cs_ap_10 end,
	-- Outright PT for sports
	@v2apositiontaking_10_max = case when @v2apositiontaking_10_max <= @cs_v2ap_10 then @v2apositiontaking_10_max else @cs_v2ap_10 end,
	@v3apositiontaking_10_max = case when @v3apositiontaking_10_max <= @cs_v3ap_10 then @v3apositiontaking_10_max else @cs_v3ap_10 end,
	@v5apositiontaking_10_max = case when @v5apositiontaking_10_max <= @cs_v5ap_10 then @v5apositiontaking_10_max else @cs_v5ap_10 end,
	@v8apositiontaking_10_max = case when @v8apositiontaking_10_max <= @cs_v8ap_10 then @v8apositiontaking_10_max else @cs_v8ap_10 end,
	@v10apositiontaking_10_max = case when @v10apositiontaking_10_max <= @cs_v10ap_10 then @v10apositiontaking_10_max else @cs_v10ap_10 end,
	@v11apositiontaking_10_max = case when @v11apositiontaking_10_max <= @cs_v11ap_10 then @v11apositiontaking_10_max else @cs_v11ap_10 end,
	@v99apositiontaking_10_max = case when @v99apositiontaking_10_max <= @cs_v99ap_10 then @v99apositiontaking_10_max else @cs_v99ap_10 end,
	
	@apositiontaking_9999_max = case when @apositiontaking_9999_max <= @cs_ap_9999 then @apositiontaking_9999_max else @cs_ap_9999 end,

	@alivepositiontaking_1_max = case when @alivepositiontaking_1_max <= @cs_alp_1 then @alivepositiontaking_1_max else @cs_alp_1 end,
	@alivepositiontaking_3_max = case when @alivepositiontaking_3_max <= @cs_alp_3 then @alivepositiontaking_3_max else @cs_alp_3 end,
	@alivepositiontaking_7_max = case when @alivepositiontaking_7_max <= @cs_alp_7 then @alivepositiontaking_7_max else @cs_alp_7 end,
	@alivepositiontaking_8_max = case when @alivepositiontaking_8_max <= @cs_alp_8 then @alivepositiontaking_8_max else @cs_alp_8 end,

	@v2apositiontaking_1_max = case when @v2apositiontaking_1_max <= @cs_v2ap_1 then @v2apositiontaking_1_max else @cs_v2ap_1 end,
	@v2apositiontaking_2_max = case when @v2apositiontaking_2_max <= @cs_v2ap_2 then @v2apositiontaking_2_max else @cs_v2ap_2 end,
	@v2apositiontaking_3_max = case when @v2apositiontaking_3_max <= @cs_v2ap_3 then @v2apositiontaking_3_max else @cs_v2ap_3 end,
	@v2apositiontaking_7_max = case when @v2apositiontaking_7_max <= @cs_v2ap_7 then @v2apositiontaking_7_max else @cs_v2ap_7 end,
	@v2apositiontaking_8_max = case when @v2apositiontaking_8_max <= @cs_v2ap_8 then @v2apositiontaking_8_max else @cs_v2ap_8 end,
	--@v2apositiontaking_9_max = case when @v2apositiontaking_9_max <= @cs_v2ap_9 then @v2apositiontaking_9_max else @cs_v2ap_9 end,
	@v2apositiontaking_20_max = case when @v2apositiontaking_20_max <= @cs_v2ap_20 then @v2apositiontaking_20_max else @cs_v2ap_20 end,
	
	@v3apositiontaking_1_max = case when @v3apositiontaking_1_max <= @cs_v3ap_1 then @v3apositiontaking_1_max else @cs_v3ap_1 end,
	@v3apositiontaking_2_max = case when @v3apositiontaking_2_max <= @cs_v3ap_2 then @v3apositiontaking_2_max else @cs_v3ap_2 end,
	@v3apositiontaking_3_max = case when @v3apositiontaking_3_max <= @cs_v3ap_3 then @v3apositiontaking_3_max else @cs_v3ap_3 end,
	@v3apositiontaking_20_max = case when @v3apositiontaking_20_max <= @cs_v3ap_20 then @v3apositiontaking_20_max else @cs_v3ap_20 end,

	@v5apositiontaking_1_max = case when @v5apositiontaking_1_max <= @cs_v5ap_1 then @v5apositiontaking_1_max else @cs_v5ap_1 end,
	@v5apositiontaking_2_max = case when @v5apositiontaking_2_max <= @cs_v5ap_2 then @v5apositiontaking_2_max else @cs_v5ap_2 end,
	@v5apositiontaking_3_max = case when @v5apositiontaking_3_max <= @cs_v5ap_3 then @v5apositiontaking_3_max else @cs_v5ap_3 end,
	@v5apositiontaking_20_max = case when @v5apositiontaking_20_max <= @cs_v5ap_20 then @v5apositiontaking_20_max else @cs_v5ap_20 end,
	@v5apositiontaking_9999_max = case when @v5apositiontaking_9999_max <= @cs_v5ap_9999 then @v5apositiontaking_9999_max else @cs_v5ap_9999 end,

	@v8apositiontaking_1_max = case when @v8apositiontaking_1_max <= @cs_v8ap_1 then @v8apositiontaking_1_max else @cs_v8ap_1 end,
	@v8apositiontaking_3_max = case when @v8apositiontaking_3_max <= @cs_v8ap_3 then @v8apositiontaking_3_max else @cs_v8ap_3 end,
	@v8apositiontaking_20_max = case when @v8apositiontaking_20_max <= @cs_v8ap_20 then @v8apositiontaking_20_max else @cs_v8ap_20 end,

	@v10apositiontaking_1_max = case when @v10apositiontaking_1_max <= @cs_v10ap_1 then @v10apositiontaking_1_max else @cs_v10ap_1 end,
	@v10apositiontaking_2_max = case when @v10apositiontaking_2_max <= @cs_v10ap_2 then @v10apositiontaking_2_max else @cs_v10ap_2 end,
	@v10apositiontaking_3_max = case when @v10apositiontaking_3_max <= @cs_v10ap_3 then @v10apositiontaking_3_max else @cs_v10ap_3 end,
	@v10apositiontaking_20_max = case when @v10apositiontaking_20_max <= @cs_v10ap_20 then @v10apositiontaking_20_max else @cs_v10ap_20 end,

	@v11apositiontaking_1_max = case when @v11apositiontaking_1_max <= @cs_v11ap_1 then @v11apositiontaking_1_max else @cs_v11ap_1 end,
	@v11apositiontaking_20_max = case when @v11apositiontaking_20_max <= @cs_v11ap_20 then @v11apositiontaking_20_max else @cs_v11ap_20 end,

	@v99apositiontaking_1_max = case when @v99apositiontaking_1_max <= @cs_v99ap_1 then @v99apositiontaking_1_max else @cs_v99ap_1 end,
	@v99apositiontaking_2_max = case when @v99apositiontaking_2_max <= @cs_v99ap_2 then @v99apositiontaking_2_max else @cs_v99ap_2 end,
	@v99apositiontaking_3_max = case when @v99apositiontaking_3_max <= @cs_v99ap_3 then @v99apositiontaking_3_max else @cs_v99ap_3 end,
	@v99apositiontaking_9_max = case when @v99apositiontaking_9_max <= @cs_v99ap_9 then @v99apositiontaking_9_max else @cs_v99ap_9 end,
	@v99apositiontaking_20_max = case when @v99apositiontaking_20_max <= @cs_v99ap_20 then @v99apositiontaking_20_max else @cs_v99ap_20 end,
	
	@v154apositiontaking_20_max = case when @v154apositiontaking_20_max <= @cs_v154ap_20 then @v154apositiontaking_20_max else @cs_v154ap_20 end,
	
	--v161
	@v161apositiontaking_81_max = case when @v161apositiontaking_81_max <= @cs_v161ap_81 then @v161apositiontaking_81_max else @cs_v161ap_81 end,
	@v161apositiontaking_83_max = case when @v161apositiontaking_83_max <= @cs_v161ap_83 then @v161apositiontaking_83_max else @cs_v161ap_83 end,	
	@v161apositiontaking_86_max = case when @v161apositiontaking_86_max <= @cs_v161ap_86 then @v161apositiontaking_86_max else @cs_v161ap_86 end,
	@v161apositiontaking_88_max = case when @v161apositiontaking_88_max <= @cs_v161ap_88 then @v161apositiontaking_88_max else @cs_v161ap_88 end,
	@v161alivepositiontaking_85_max = case when @v161alivepositiontaking_85_max <= @cs_v161alp_85 then @v161alivepositiontaking_85_max else @cs_v161alp_85 end,
	@v161alivepositiontaking_86_max = case when @v161alivepositiontaking_86_max <= @cs_v161alp_86 then @v161alivepositiontaking_86_max else @cs_v161alp_86 end,
	@v161alivepositiontaking_87_max = case when @v161alivepositiontaking_87_max <= @cs_v161alp_87 then @v161alivepositiontaking_87_max else @cs_v161alp_87 end,
	@v161alivepositiontaking_89_max = case when @v161alivepositiontaking_89_max <= @cs_v161alp_89 then @v161alivepositiontaking_89_max else @cs_v161alp_89 end,
	@v161alivepositiontaking_90_max = case when @v161alivepositiontaking_90_max <= @cs_v161alp_90 then @v161alivepositiontaking_90_max else @cs_v161alp_90 end

		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if @UpdateMultiple = 0 or @UpdatePositiontaking = 1
BEGIN
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
		or @apositiontaking_9999  <0
		or @alivepositiontaking_1  <0
		or @alivepositiontaking_3  <0
		or @alivepositiontaking_7  <0
		or @alivepositiontaking_8  <0		
		or @apositiontaking_10 <0
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
		
	BEGIN
		select @ErrCode = 5
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Soccer).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking			
			
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)) or 
						((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking)))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 6
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
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
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking
			) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 7
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((t.alivepositiontaking_max) as varchar(10)) else '' end + '<br>'
	from 
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
				union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking
			) b
		INNER JOIN 
			(
						select 1 as bettype, 1 as sporttype, @apositiontaking_1_max as apositiontaking_max, @alivepositiontaking_1_max as alivepositiontaking_max
				union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3_max as apositiontaking_max, @alivepositiontaking_3_max as alivepositiontaking_max
				union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7_max as apositiontaking_max, @alivepositiontaking_7_max as alivepositiontaking_max
				union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8_max as apositiontaking_max, @alivepositiontaking_8_max as alivepositiontaking_max
				union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999_max as apositiontaking_max, 0 as alivepositiontaking_max
			) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max OR b.alivepositiontaking > t.alivepositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 100
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
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
			) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Basketball
if @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
BEGIN
	if 
		@v2apositiontaking_1  <0
		or @v2apositiontaking_2  <0
		or @v2apositiontaking_3  <0
		or @v2apositiontaking_7  <0
		or @v2apositiontaking_8  <0
		--or @v2apositiontaking_9  <0
		or @v2apositiontaking_10  <0
		or @v2apositiontaking_20  <0		
		
		
		or @v2apositiontaking_1  >0.9
		or @v2apositiontaking_2  >0.9
		or @v2apositiontaking_3  >0.9
		or @v2apositiontaking_7  >0.9
		or @v2apositiontaking_8  >0.9
		--or @v2apositiontaking_9  >0.9
		or @v2apositiontaking_10  >0.9
		or @v2apositiontaking_20  >0.9
		
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Basketball).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking

		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 2 as sporttype, @v2apositiontaking_1_max as apositiontaking_max
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2_max as apositiontaking_max
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3_max as apositiontaking_max
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 101
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 		select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, 0 as alivepositiontaking
--			union all 	select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Football
if @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
BEGIN
	if 
		@v3apositiontaking_1  <0
		or @v3apositiontaking_2  <0
		or @v3apositiontaking_3  <0
		or @v3apositiontaking_20  <0		
		or @v3apositiontaking_10  <0
		
		or @v3apositiontaking_1  >0.9
		or @v3apositiontaking_2  >0.9
		or @v3apositiontaking_3  >0.9
		or @v3apositiontaking_20  >0.9
		or @v3apositiontaking_10  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Football).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking			
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s  on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 3 as sporttype, @v3apositiontaking_1_max as apositiontaking_max
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2_max as apositiontaking_max
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3_max as apositiontaking_max
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 102
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 		select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Tennis
if @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
BEGIN
	if 
		@v5apositiontaking_1  <0
		or @v5apositiontaking_2  <0
		or @v5apositiontaking_3  <0
		or @v5apositiontaking_20  <0		
		or @v5apositiontaking_9999  <0
		or @v5apositiontaking_10  <0
		or @v5apositiontaking_1  >0.9
		or @v5apositiontaking_2  >0.9
		or @v5apositiontaking_3  >0.9
		or @v5apositiontaking_20  >0.9
		or @v5apositiontaking_9999  >0.9
		or @v5apositiontaking_10  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Tennis).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking			
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 5 as sporttype, @v5apositiontaking_1_max as apositiontaking_max
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2_max as apositiontaking_max
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3_max as apositiontaking_max
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20_max as apositiontaking_max
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 103
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 		select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Baseball
if @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
BEGIN
	if 
		@v8apositiontaking_1  <0
		or @v8apositiontaking_3  <0
		or @v8apositiontaking_20  <0		
		or @v8apositiontaking_10  <0
		or @v8apositiontaking_1  >0.9
		or @v8apositiontaking_3  >0.9
		or @v8apositiontaking_20  >0.9
		or @v8apositiontaking_10  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Baseball).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking			
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 8 as sporttype, @v8apositiontaking_1_max as apositiontaking_max			
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3_max as apositiontaking_max
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 103
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Golf
if @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
BEGIN
	if 
		@v10apositiontaking_1  <0
		or @v10apositiontaking_2  <0
		or @v10apositiontaking_3  <0
		or @v10apositiontaking_20  <0		
		or @v10apositiontaking_10  <0
		or @v10apositiontaking_1  >0.9
		or @v10apositiontaking_2  >0.9
		or @v10apositiontaking_3  >0.9
		or @v10apositiontaking_20  >0.9
		or @v10apositiontaking_10  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Golf).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking			
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 10 as sporttype, @v10apositiontaking_1_max as apositiontaking_max
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2_max as apositiontaking_max
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3_max as apositiontaking_max
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 		select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Motorsports
if @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1
BEGIN
	if 
		@v11apositiontaking_1  <0
		or @v11apositiontaking_20  <0		
		or @v11apositiontaking_10  <0		
		or @v11apositiontaking_1  >0.9
		or @v11apositiontaking_20  >0.9
		or @v11apositiontaking_10  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Motorsports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking					
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking				 	
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking					
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 11 as sporttype, @v11apositiontaking_1_max as apositiontaking_max
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 		select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Other sports
if @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
BEGIN
	if 
		@v99apositiontaking_1  <0
		or @v99apositiontaking_2  <0
		or @v99apositiontaking_3  <0
		or @v99apositiontaking_20  <0		
		or @v99apositiontaking_10  <0
		or @v99apositiontaking_1  >0.9
		or @v99apositiontaking_2  >0.9
		or @v99apositiontaking_3  >0.9
		or @v99apositiontaking_20  >0.9
		or @v99apositiontaking_10  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Other sports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking			
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 1 as bettype, 99 as sporttype, @v99apositiontaking_1_max as apositiontaking_max
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2_max as apositiontaking_max
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3_max as apositiontaking_max
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10_max as apositiontaking_max
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
	/*
	--check a1<=a2 - Phuc
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((acs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((acs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custsetting as acs with (NOLOCK) inner join 
		(
				 		select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on acs.sporttype=b.sporttype and acs.bettype = b.bettype and acs.custid = @recommend  
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where (b.apositiontaking>acs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>acs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 203
		Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong agent position taking. <br>'+@ErrType
									when 'CS' then N'代理占成数不正确. <br>'+@ErrType
									when 'CT' then N'代理佔成數不正確. <br>'+@ErrType
									when 'TH' then N'การกำหนดตัวแทนไม่ถูกต้อง. <br>'+@ErrType
									when 'J' then N'ポジション設定が無効です。. <br>'+@ErrType
									when 'ES' then N'Posición de agente incorrecta . <br>'+@ErrType
									else N'Wrong agent position taking. <br>'+@ErrType
							end
		return
	END
	*/
END

--Mix Parlay Mixed Sports
if @UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1
BEGIN
	if 
		@v99apositiontaking_9  <0
		or @v99apositiontaking_9  >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Mix Sports Parlay).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
					end
		return
	END

	--check n2<=a1<=l2 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	--or ((b.sporttype = 1 and b.bettype in (1,3,7,8)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s  on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and b.apositiontaking>scs.apositiontaking
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking
		) b
		INNER JOIN 
		(
					select 9 as bettype, 99 as sporttype, @v99apositiontaking_9_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s  on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 105
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--HR Fixed Odds
if @UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1
BEGIN
	if 
		@v154apositiontaking_20  <0		
		or @v154apositiontaking_20  >0.9
		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Motorsports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
					select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking, 0 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and b.apositiontaking>scs.apositiontaking 
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
		--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
	from 
		(
					select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking
		) b
		INNER JOIN 
		(
					select 20 as bettype, 154 as sporttype, @v154apositiontaking_20_max as apositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 104
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END	
END

--v161
if @UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1
BEGIN
	if 
		@v161apositiontaking_81  <0
		or @v161apositiontaking_83  <0
		or @v161apositiontaking_86  <0
		or @v161apositiontaking_88  <0
		or @v161alivepositiontaking_85  <0
		or @v161alivepositiontaking_86  <0
		or @v161alivepositiontaking_87  <0
		or @v161alivepositiontaking_89  <0
		or @v161alivepositiontaking_90  <0
		
		or @v161apositiontaking_81  >0.9
		or @v161apositiontaking_83  >0.9
		or @v161apositiontaking_86  >0.9
		or @v161apositiontaking_88  >0.9
		or @v161alivepositiontaking_85  >0.9
		or @v161alivepositiontaking_86  >0.9
		or @v161alivepositiontaking_87  >0.9
		or @v161alivepositiontaking_89  >0.9
		or @v161alivepositiontaking_90  >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Number Game).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
					end
		return
	END

	--check n2<=a1<=l2 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custoverride3rd as co with (NOLOCK) inner join
		(
					select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking
		union all	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking
		union all	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking
		union all	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking
		union all	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking
		union all	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking
		union all	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking
		union all	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)) or 
						((b.sporttype = 161 and b.bettype in (85,86,87,89,90)) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking)))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a1<=a4 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
					select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking
		union all	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking
		union all	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking
		union all 	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking
		union all	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking
		union all	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking
		union all	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking
		union all	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 161 and b.bettype in (85,86,87,89,90) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--check a1 with a1_max
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((t.apositiontaking_max) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((t.alivepositiontaking_max) as varchar(10)) else '' end + '<br>'
	from 
			(
						select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking
				union all 	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking
				union all 	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking
				union all 	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking
				union all 	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking
				union all 	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking
				union all 	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking
				union all 	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking
			) b
		INNER JOIN 
			(
					select 81 as bettype, 161 as sporttype, @v161apositiontaking_81_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88_max as apositiontaking_max, 0 as alivepositiontaking_max
				union all 	select 85 as bettype, 161 as sporttype, 0 as apositiontaking_max, @v161alivepositiontaking_85_max as alivepositiontaking_max
				union all 	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86_max as apositiontaking, @v161alivepositiontaking_86_max as alivepositiontaking_max
				union all 	select 87 as bettype, 161 as sporttype, 0 as apositiontaking_max, @v161alivepositiontaking_87_max as alivepositiontaking_max
				union all 	select 89 as bettype, 161 as sporttype, 0 as apositiontaking_max, @v161alivepositiontaking_89_max as alivepositiontaking_max
				union all 	select 90 as bettype, 161 as sporttype, 0 as apositiontaking_max, @v161alivepositiontaking_90_max as alivepositiontaking_max
			) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt  on b.bettype = bt.typeid
	WHERE b.apositiontaking > t.apositiontaking_max OR b.alivepositiontaking > t.alivepositiontaking_max
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 106
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (max set by upline).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20028,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--m1,s1,u1,i1,um1,im1
SELECT @spositiontaking_1 = spositiontaking, @slivepositiontaking_1 = slivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @auto_spositiontaking_mem_1 = autopositiontaking, @auto_slivepositiontaking_mem_1 = autolivepositiontaking, @isauto_spositiontaking_mem_1 = isautopositiontaking, @isauto_slivepositiontaking_mem_1 = isautolivepositiontaking, @old_apositiontaking_1 = apositiontaking, @old_alivepositiontaking_1 = alivepositiontaking, @auto_mpositiontaking_mem_1 = autompositiontaking, @isauto_mpositiontaking_mem_1 = isautompositiontaking, @auto_mlivepositiontaking_mem_1 = autolivempositiontaking, @isauto_mlivepositiontaking_mem_1 = isautolivempositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=1
SELECT @spositiontaking_3 = spositiontaking, @slivepositiontaking_3 = slivepositiontaking, @mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @auto_spositiontaking_mem_3 = autopositiontaking, @auto_slivepositiontaking_mem_3 = autolivepositiontaking, @isauto_spositiontaking_mem_3 = isautopositiontaking, @isauto_slivepositiontaking_mem_3 = isautolivepositiontaking, @old_apositiontaking_3 = apositiontaking, @old_alivepositiontaking_3 = alivepositiontaking, @auto_mpositiontaking_mem_3 = autompositiontaking, @isauto_mpositiontaking_mem_3 = isautompositiontaking, @auto_mlivepositiontaking_mem_3 = autolivempositiontaking, @isauto_mlivepositiontaking_mem_3 = isautolivempositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=1
SELECT @spositiontaking_7 = spositiontaking, @slivepositiontaking_7 = slivepositiontaking, @mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @auto_spositiontaking_mem_7 = autopositiontaking, @auto_slivepositiontaking_mem_7 = autolivepositiontaking, @isauto_spositiontaking_mem_7 = isautopositiontaking, @isauto_slivepositiontaking_mem_7 = isautolivepositiontaking, @old_apositiontaking_7 = apositiontaking, @old_alivepositiontaking_7 = alivepositiontaking, @auto_mpositiontaking_mem_7 = autompositiontaking, @isauto_mpositiontaking_mem_7 = isautompositiontaking, @auto_mlivepositiontaking_mem_7 = autolivempositiontaking, @isauto_mlivepositiontaking_mem_7 = isautolivempositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=7 AND sporttype=1
SELECT @spositiontaking_8 = spositiontaking, @slivepositiontaking_8 = slivepositiontaking, @mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @auto_spositiontaking_mem_8 = autopositiontaking, @auto_slivepositiontaking_mem_8 = autolivepositiontaking, @isauto_spositiontaking_mem_8 = isautopositiontaking, @isauto_slivepositiontaking_mem_8 = isautolivepositiontaking, @old_apositiontaking_8 = apositiontaking, @old_alivepositiontaking_8 = alivepositiontaking, @auto_mpositiontaking_mem_8 = autompositiontaking, @isauto_mpositiontaking_mem_8 = isautompositiontaking, @auto_mlivepositiontaking_mem_8 = autolivempositiontaking, @isauto_mlivepositiontaking_mem_8 = isautolivempositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=8 AND sporttype=1

SELECT @spositiontaking_2 = spositiontaking, @mpositiontaking_2 = mpositiontaking, @old_apositiontaking_2 = apositiontaking, @auto_spositiontaking_mem_2 = autopositiontaking, @isauto_spositiontaking_mem_2 = isautopositiontaking, @auto_mpositiontaking_mem_2 = autompositiontaking, @isauto_mpositiontaking_mem_2 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=2 AND sporttype=1
SELECT @spositiontaking_4 = spositiontaking, @mpositiontaking_4 = mpositiontaking, @old_apositiontaking_4 = apositiontaking, @auto_spositiontaking_mem_4 = autopositiontaking, @isauto_spositiontaking_mem_4 = isautopositiontaking, @auto_mpositiontaking_mem_4 = autompositiontaking, @isauto_mpositiontaking_mem_4 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=4 AND sporttype=1
SELECT @spositiontaking_5 = spositiontaking, @mpositiontaking_5 = mpositiontaking, @old_apositiontaking_5 = apositiontaking, @auto_spositiontaking_mem_5 = autopositiontaking, @isauto_spositiontaking_mem_5 = isautopositiontaking, @auto_mpositiontaking_mem_5 = autompositiontaking, @isauto_mpositiontaking_mem_5 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=5 AND sporttype=1
SELECT @spositiontaking_6 = spositiontaking, @mpositiontaking_6 = mpositiontaking, @old_apositiontaking_6 = apositiontaking, @auto_spositiontaking_mem_6 = autopositiontaking, @isauto_spositiontaking_mem_6 = isautopositiontaking, @auto_mpositiontaking_mem_6 = autompositiontaking, @isauto_mpositiontaking_mem_6 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=6 AND sporttype=1
SELECT @spositiontaking_9 = spositiontaking, @mpositiontaking_9 = mpositiontaking, @old_apositiontaking_9 = apositiontaking, @auto_spositiontaking_mem_9 = autopositiontaking, @isauto_spositiontaking_mem_9 = isautopositiontaking, @auto_mpositiontaking_mem_9 = autompositiontaking, @isauto_mpositiontaking_mem_9 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=9 AND sporttype=1
SELECT @spositiontaking_10 = spositiontaking, @mpositiontaking_10 = mpositiontaking, @old_apositiontaking_10 = apositiontaking, @auto_spositiontaking_mem_10 = autopositiontaking, @isauto_spositiontaking_mem_10 = isautopositiontaking, @auto_mpositiontaking_mem_10 = autompositiontaking, @isauto_mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=1

-- Outright PT for sports
SELECT @v2spositiontaking_10 = spositiontaking, @v2mpositiontaking_10 = mpositiontaking, @old_v2apositiontaking_10 = apositiontaking, @auto_v2spositiontaking_mem_10 = autopositiontaking, @isauto_v2spositiontaking_mem_10 = isautopositiontaking, @auto_v2mpositiontaking_mem_10 = autompositiontaking, @isauto_v2mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=2
SELECT @v3spositiontaking_10 = spositiontaking, @v3mpositiontaking_10 = mpositiontaking, @old_v3apositiontaking_10 = apositiontaking, @auto_v3spositiontaking_mem_10 = autopositiontaking, @isauto_v3spositiontaking_mem_10 = isautopositiontaking, @auto_v3mpositiontaking_mem_10 = autompositiontaking, @isauto_v3mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=3
SELECT @v5spositiontaking_10 = spositiontaking, @v5mpositiontaking_10 = mpositiontaking, @old_v5apositiontaking_10 = apositiontaking, @auto_v5spositiontaking_mem_10 = autopositiontaking, @isauto_v5spositiontaking_mem_10 = isautopositiontaking, @auto_v5mpositiontaking_mem_10 = autompositiontaking, @isauto_v5mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=5
SELECT @v8spositiontaking_10 = spositiontaking, @v8mpositiontaking_10 = mpositiontaking, @old_v8apositiontaking_10 = apositiontaking, @auto_v8spositiontaking_mem_10 = autopositiontaking, @isauto_v8spositiontaking_mem_10 = isautopositiontaking, @auto_v8mpositiontaking_mem_10 = autompositiontaking, @isauto_v8mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=8
SELECT @v10spositiontaking_10 = spositiontaking, @v10mpositiontaking_10 = mpositiontaking, @old_v10apositiontaking_10 = apositiontaking, @auto_v10spositiontaking_mem_10 = autopositiontaking, @isauto_v10spositiontaking_mem_10 = isautopositiontaking, @auto_v10mpositiontaking_mem_10 = autompositiontaking, @isauto_v10mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=10
SELECT @v11spositiontaking_10 = spositiontaking, @v11mpositiontaking_10 = mpositiontaking, @old_v11apositiontaking_10 = apositiontaking, @auto_v11spositiontaking_mem_10 = autopositiontaking, @isauto_v11spositiontaking_mem_10 = isautopositiontaking, @auto_v11mpositiontaking_mem_10 = autompositiontaking, @isauto_v11mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=11
SELECT @v99spositiontaking_10 = spositiontaking, @v99mpositiontaking_10 = mpositiontaking, @old_v99apositiontaking_10 = apositiontaking, @auto_v99spositiontaking_mem_10 = autopositiontaking, @isauto_v99spositiontaking_mem_10 = isautopositiontaking, @auto_v99mpositiontaking_mem_10 = autompositiontaking, @isauto_v99mpositiontaking_mem_10 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=10 AND sporttype=99

SELECT @spositiontaking_9999 = spositiontaking, @mpositiontaking_9999 = mpositiontaking, @old_apositiontaking_9999 = apositiontaking, @auto_spositiontaking_mem_9999 = autopositiontaking, @isauto_spositiontaking_mem_9999 = isautopositiontaking, @auto_mpositiontaking_mem_9999 = autompositiontaking, @isauto_mpositiontaking_mem_9999 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=9999 AND sporttype=1

SELECT @v2spositiontaking_1 = spositiontaking, @v2mpositiontaking_1 = mpositiontaking, @auto_v2spositiontaking_mem_1 = autopositiontaking, @isauto_v2spositiontaking_mem_1 = isautopositiontaking, @old_v2apositiontaking_1 = apositiontaking, @auto_v2mpositiontaking_mem_1 = autompositiontaking, @isauto_v2mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=2
SELECT @v2spositiontaking_2 = spositiontaking, @v2mpositiontaking_2 = mpositiontaking, @auto_v2spositiontaking_mem_2 = autopositiontaking, @isauto_v2spositiontaking_mem_2 = isautopositiontaking, @old_v2apositiontaking_2 = apositiontaking, @auto_v2mpositiontaking_mem_2 = autompositiontaking, @isauto_v2mpositiontaking_mem_2 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=2 AND sporttype=2
SELECT @v2spositiontaking_3 = spositiontaking, @v2mpositiontaking_3 = mpositiontaking, @auto_v2spositiontaking_mem_3 = autopositiontaking, @isauto_v2spositiontaking_mem_3 = isautopositiontaking, @old_v2apositiontaking_3 = apositiontaking, @auto_v2mpositiontaking_mem_3 = autompositiontaking, @isauto_v2mpositiontaking_mem_3 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=2
SELECT @v2spositiontaking_7 = spositiontaking, @v2mpositiontaking_7 = mpositiontaking, @auto_v2spositiontaking_mem_7 = autopositiontaking, @isauto_v2spositiontaking_mem_7 = isautopositiontaking, @old_v2apositiontaking_7 = apositiontaking, @auto_v2mpositiontaking_mem_7 = autompositiontaking, @isauto_v2mpositiontaking_mem_7 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=7 AND sporttype=2
SELECT @v2spositiontaking_8 = spositiontaking, @v2mpositiontaking_8 = mpositiontaking, @auto_v2spositiontaking_mem_8 = autopositiontaking, @isauto_v2spositiontaking_mem_8 = isautopositiontaking, @old_v2apositiontaking_8 = apositiontaking, @auto_v2mpositiontaking_mem_8 = autompositiontaking, @isauto_v2mpositiontaking_mem_8 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=8 AND sporttype=2
--SELECT @v2spositiontaking_9 = spositiontaking, @v2mpositiontaking_9 = mpositiontaking, @auto_v2spositiontaking_mem_9 = autopositiontaking, @isauto_v2spositiontaking_mem_9 = isautopositiontaking, @old_v2apositiontaking_9 = apositiontaking, @auto_v2mpositiontaking_mem_9 = autompositiontaking, @isauto_v2mpositiontaking_mem_9 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=9 AND sporttype=2
SELECT @v2spositiontaking_20 = spositiontaking, @v2mpositiontaking_20 = mpositiontaking, @auto_v2spositiontaking_mem_20 = autopositiontaking, @isauto_v2spositiontaking_mem_20 = isautopositiontaking, @old_v2apositiontaking_20 = apositiontaking, @auto_v2mpositiontaking_mem_20 = autompositiontaking, @isauto_v2mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=2

SELECT @v3spositiontaking_1 = spositiontaking, @v3mpositiontaking_1 = mpositiontaking, @auto_v3spositiontaking_mem_1 = autopositiontaking, @isauto_v3spositiontaking_mem_1 = isautopositiontaking, @old_v3apositiontaking_1 = apositiontaking, @auto_v3mpositiontaking_mem_1 = autompositiontaking, @isauto_v3mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=3
SELECT @v3spositiontaking_2 = spositiontaking, @v3mpositiontaking_2 = mpositiontaking, @auto_v3spositiontaking_mem_2 = autopositiontaking, @isauto_v3spositiontaking_mem_2 = isautopositiontaking, @old_v3apositiontaking_2 = apositiontaking, @auto_v3mpositiontaking_mem_2 = autompositiontaking, @isauto_v3mpositiontaking_mem_2 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=2 AND sporttype=3
SELECT @v3spositiontaking_3 = spositiontaking, @v3mpositiontaking_3 = mpositiontaking, @auto_v3spositiontaking_mem_3 = autopositiontaking, @isauto_v3spositiontaking_mem_3 = isautopositiontaking, @old_v3apositiontaking_3 = apositiontaking, @auto_v3mpositiontaking_mem_3 = autompositiontaking, @isauto_v3mpositiontaking_mem_3 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=3
SELECT @v3spositiontaking_20 = spositiontaking, @v3mpositiontaking_20 = mpositiontaking, @auto_v3spositiontaking_mem_20 = autopositiontaking, @isauto_v3spositiontaking_mem_20 = isautopositiontaking, @old_v3apositiontaking_20 = apositiontaking, @auto_v3mpositiontaking_mem_20 = autompositiontaking, @isauto_v3mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=3

SELECT @v5spositiontaking_1 = spositiontaking, @v5mpositiontaking_1 = mpositiontaking, @auto_v5spositiontaking_mem_1 = autopositiontaking, @isauto_v5spositiontaking_mem_1 = isautopositiontaking, @old_v5apositiontaking_1 = apositiontaking, @auto_v5mpositiontaking_mem_1 = autompositiontaking, @isauto_v5mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=5
SELECT @v5spositiontaking_2 = spositiontaking, @v5mpositiontaking_2 = mpositiontaking, @auto_v5spositiontaking_mem_2 = autopositiontaking, @isauto_v5spositiontaking_mem_2 = isautopositiontaking, @old_v5apositiontaking_2 = apositiontaking, @auto_v5mpositiontaking_mem_2 = autompositiontaking, @isauto_v5mpositiontaking_mem_2 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=2 AND sporttype=5
SELECT @v5spositiontaking_3 = spositiontaking, @v5mpositiontaking_3 = mpositiontaking, @auto_v5spositiontaking_mem_3 = autopositiontaking, @isauto_v5spositiontaking_mem_3 = isautopositiontaking, @old_v5apositiontaking_3 = apositiontaking, @auto_v5mpositiontaking_mem_3 = autompositiontaking, @isauto_v5mpositiontaking_mem_3 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=5
SELECT @v5spositiontaking_20 = spositiontaking, @v5mpositiontaking_20 = mpositiontaking, @auto_v5spositiontaking_mem_20 = autopositiontaking, @isauto_v5spositiontaking_mem_20 = isautopositiontaking, @old_v5apositiontaking_20 = apositiontaking, @auto_v5mpositiontaking_mem_20 = autompositiontaking, @isauto_v5mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=5
SELECT @v5spositiontaking_9999 = spositiontaking, @v5mpositiontaking_9999 = mpositiontaking, @auto_v5spositiontaking_mem_9999 = autopositiontaking, @isauto_v5spositiontaking_mem_9999 = isautopositiontaking, @old_v5apositiontaking_9999 = apositiontaking, @auto_v5mpositiontaking_mem_9999 = autompositiontaking, @isauto_v5mpositiontaking_mem_9999 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=9999 AND sporttype=5

SELECT @v8spositiontaking_1 = spositiontaking, @v8mpositiontaking_1 = mpositiontaking, @auto_v8spositiontaking_mem_1 = autopositiontaking, @isauto_v8spositiontaking_mem_1 = isautopositiontaking, @old_v8apositiontaking_1 = apositiontaking, @auto_v8mpositiontaking_mem_1 = autompositiontaking, @isauto_v8mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=8
SELECT @v8spositiontaking_3 = spositiontaking, @v8mpositiontaking_3 = mpositiontaking, @auto_v8spositiontaking_mem_3 = autopositiontaking, @isauto_v8spositiontaking_mem_3 = isautopositiontaking, @old_v8apositiontaking_3 = apositiontaking, @auto_v8mpositiontaking_mem_3 = autompositiontaking, @isauto_v8mpositiontaking_mem_3 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=8
SELECT @v8spositiontaking_20 = spositiontaking, @v8mpositiontaking_20 = mpositiontaking, @auto_v8spositiontaking_mem_20 = autopositiontaking, @isauto_v8spositiontaking_mem_20 = isautopositiontaking, @old_v8apositiontaking_20 = apositiontaking, @auto_v8mpositiontaking_mem_20 = autompositiontaking, @isauto_v8mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=8

SELECT @v10spositiontaking_1 = spositiontaking, @v10mpositiontaking_1 = mpositiontaking, @auto_v10spositiontaking_mem_1 = autopositiontaking, @isauto_v10spositiontaking_mem_1 = isautopositiontaking, @old_v10apositiontaking_1 = apositiontaking, @auto_v10mpositiontaking_mem_1 = autompositiontaking, @isauto_v10mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=10
SELECT @v10spositiontaking_2 = spositiontaking, @v10mpositiontaking_2 = mpositiontaking, @auto_v10spositiontaking_mem_2 = autopositiontaking, @isauto_v10spositiontaking_mem_2 = isautopositiontaking, @old_v10apositiontaking_2 = apositiontaking, @auto_v10mpositiontaking_mem_2 = autompositiontaking, @isauto_v10mpositiontaking_mem_2 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=2 AND sporttype=10
SELECT @v10spositiontaking_3 = spositiontaking, @v10mpositiontaking_3 = mpositiontaking, @auto_v10spositiontaking_mem_3 = autopositiontaking, @isauto_v10spositiontaking_mem_3 = isautopositiontaking, @old_v10apositiontaking_3 = apositiontaking, @auto_v10mpositiontaking_mem_3 = autompositiontaking, @isauto_v10mpositiontaking_mem_3 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=10
SELECT @v10spositiontaking_20 = spositiontaking, @v10mpositiontaking_20 = mpositiontaking, @auto_v10spositiontaking_mem_20 = autopositiontaking, @isauto_v10spositiontaking_mem_20 = isautopositiontaking, @old_v10apositiontaking_20 = apositiontaking, @auto_v10mpositiontaking_mem_20 = autompositiontaking, @isauto_v10mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=10

SELECT @v11spositiontaking_1 = spositiontaking, @v11mpositiontaking_1 = mpositiontaking, @auto_v11spositiontaking_mem_1 = autopositiontaking, @isauto_v11spositiontaking_mem_1 = isautopositiontaking, @old_v11apositiontaking_1 = apositiontaking, @auto_v11mpositiontaking_mem_1 = autompositiontaking, @isauto_v11mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=11
SELECT @v11spositiontaking_20 = spositiontaking, @v11mpositiontaking_20 = mpositiontaking, @auto_v11spositiontaking_mem_20 = autopositiontaking, @isauto_v11spositiontaking_mem_20 = isautopositiontaking, @old_v11apositiontaking_20 = apositiontaking, @auto_v11mpositiontaking_mem_20 = autompositiontaking, @isauto_v11mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=11

SELECT @v99spositiontaking_1 = spositiontaking, @v99mpositiontaking_1 = mpositiontaking, @auto_v99spositiontaking_mem_1 = autopositiontaking, @isauto_v99spositiontaking_mem_1 = isautopositiontaking, @old_v99apositiontaking_1 = apositiontaking, @auto_v99mpositiontaking_mem_1 = autompositiontaking, @isauto_v99mpositiontaking_mem_1 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=1 AND sporttype=99
SELECT @v99spositiontaking_2 = spositiontaking, @v99mpositiontaking_2 = mpositiontaking, @auto_v99spositiontaking_mem_2 = autopositiontaking, @isauto_v99spositiontaking_mem_2 = isautopositiontaking, @old_v99apositiontaking_2 = apositiontaking, @auto_v99mpositiontaking_mem_2 = autompositiontaking, @isauto_v99mpositiontaking_mem_2 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=2 AND sporttype=99
SELECT @v99spositiontaking_3 = spositiontaking, @v99mpositiontaking_3 = mpositiontaking, @auto_v99spositiontaking_mem_3 = autopositiontaking, @isauto_v99spositiontaking_mem_3 = isautopositiontaking, @old_v99apositiontaking_3 = apositiontaking, @auto_v99mpositiontaking_mem_3 = autompositiontaking, @isauto_v99mpositiontaking_mem_3 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=3 AND sporttype=99
SELECT @v99spositiontaking_9 = spositiontaking, @v99mpositiontaking_9 = mpositiontaking, @auto_v99spositiontaking_mem_9 = autopositiontaking, @isauto_v99spositiontaking_mem_9 = isautopositiontaking, @old_v99apositiontaking_9 = apositiontaking, @auto_v99mpositiontaking_mem_9 = autompositiontaking, @isauto_v99mpositiontaking_mem_9 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=9 AND sporttype=99
SELECT @v99spositiontaking_20 = spositiontaking, @v99mpositiontaking_20 = mpositiontaking, @auto_v99spositiontaking_mem_20 = autopositiontaking, @isauto_v99spositiontaking_mem_20 = isautopositiontaking, @old_v99apositiontaking_20 = apositiontaking, @auto_v99mpositiontaking_mem_20 = autompositiontaking, @isauto_v99mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=99

SELECT @v154spositiontaking_20 = spositiontaking, @v154mpositiontaking_20 = mpositiontaking, @auto_v154spositiontaking_mem_20 = autopositiontaking, @isauto_v154spositiontaking_mem_20 = isautopositiontaking, @old_v154apositiontaking_20 = apositiontaking, @auto_v154mpositiontaking_mem_20 = autompositiontaking, @isauto_v154mpositiontaking_mem_20 = isautompositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @custid AND bettype=20 AND sporttype=154

--v161
SELECT @v161spositiontaking_81 = spositiontaking, @v161mpositiontaking_81 = mpositiontaking, @auto_v161spositiontaking_mem_81 = autopositiontaking, @isauto_v161spositiontaking_mem_81 = isautopositiontaking, @old_v161apositiontaking_81 = apositiontaking, @auto_v161mpositiontaking_mem_81 = autompositiontaking, @isauto_v161mpositiontaking_mem_81 = isautompositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=81 AND sporttype=161
SELECT @v161spositiontaking_83 = spositiontaking, @v161mpositiontaking_83 = mpositiontaking, @auto_v161spositiontaking_mem_83 = autopositiontaking, @isauto_v161spositiontaking_mem_83 = isautopositiontaking, @old_v161apositiontaking_83 = apositiontaking, @auto_v161mpositiontaking_mem_83 = autompositiontaking, @isauto_v161mpositiontaking_mem_83 = isautompositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=83 AND sporttype=161
SELECT @v161spositiontaking_88 = spositiontaking, @v161mpositiontaking_88 = mpositiontaking, @auto_v161spositiontaking_mem_88 = autopositiontaking, @isauto_v161spositiontaking_mem_88 = isautopositiontaking, @old_v161apositiontaking_88 = apositiontaking, @auto_v161mpositiontaking_mem_88 = autompositiontaking, @isauto_v161mpositiontaking_mem_88 = isautompositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=88 AND sporttype=161
SELECT @v161slivepositiontaking_85 = slivepositiontaking,  @v161mlivepositiontaking_85 = mlivepositiontaking, @auto_v161slivepositiontaking_mem_85 = autolivepositiontaking, @isauto_v161slivepositiontaking_mem_85 = isautolivepositiontaking, @old_v161alivepositiontaking_85 = alivepositiontaking, @auto_v161mlivepositiontaking_mem_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_mem_85 = isautolivempositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=85 AND sporttype=161
SELECT @v161spositiontaking_86 = spositiontaking, @v161slivepositiontaking_86 = slivepositiontaking, @v161mpositiontaking_86 = mpositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @auto_v161spositiontaking_mem_86 = autopositiontaking, @auto_v161slivepositiontaking_mem_86 = autolivepositiontaking, @isauto_v161spositiontaking_mem_86 = isautopositiontaking, @isauto_v161slivepositiontaking_mem_86 = isautolivepositiontaking, @old_v161apositiontaking_86 = apositiontaking, @old_v161alivepositiontaking_86 = alivepositiontaking, @auto_v161mpositiontaking_mem_86 = autompositiontaking, @isauto_v161mpositiontaking_mem_86 = isautompositiontaking, @auto_v161mlivepositiontaking_mem_86 = autolivempositiontaking, @isauto_v161mlivepositiontaking_mem_86 = isautolivempositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=86 AND sporttype=161
SELECT @v161slivepositiontaking_87 = slivepositiontaking,  @v161mlivepositiontaking_87 = mlivepositiontaking, @auto_v161slivepositiontaking_mem_87 = autolivepositiontaking, @isauto_v161slivepositiontaking_mem_87 = isautolivepositiontaking, @old_v161alivepositiontaking_87 = alivepositiontaking, @auto_v161mlivepositiontaking_mem_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_mem_87 = isautolivempositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=87 AND sporttype=161
SELECT @v161slivepositiontaking_89 = slivepositiontaking,  @v161mlivepositiontaking_89 = mlivepositiontaking, @auto_v161slivepositiontaking_mem_89 = autolivepositiontaking, @isauto_v161slivepositiontaking_mem_89 = isautolivepositiontaking, @old_v161alivepositiontaking_89 = alivepositiontaking, @auto_v161mlivepositiontaking_mem_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_mem_89 = isautolivempositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=89 AND sporttype=161
SELECT @v161slivepositiontaking_90 = slivepositiontaking,  @v161mlivepositiontaking_90 = mlivepositiontaking, @auto_v161slivepositiontaking_mem_90 = autolivepositiontaking, @isauto_v161slivepositiontaking_mem_90 = isautolivepositiontaking, @old_v161alivepositiontaking_90 = alivepositiontaking, @auto_v161mlivepositiontaking_mem_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_mem_90 = isautolivempositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=90 AND sporttype=161

------------------------------------------------------------------------------------------------------------------------------
--Auto Master PT
------------------------------------------------------------------------------------------------------------------------------
--um2,im2
select @auto_mpositiontaking_1 = autompositiontaking, @auto_mlivepositiontaking_1 = autolivempositiontaking, @isauto_mpositiontaking_1 = isautompositiontaking, @isauto_mlivepositiontaking_1 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=1
--select @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @minMinBet = MinBet, @maxMaxBet = MaxBet, @maxdiscount = case when @ugroup in ('a','hka') then groupa when @ugroup in ('b','hkb') then groupb when @ugroup in ('c','hkc') then groupc else groupd end from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=1
select @auto_mpositiontaking_3 = autompositiontaking, @auto_mlivepositiontaking_3 = autolivempositiontaking, @isauto_mpositiontaking_3 = isautompositiontaking, @isauto_mlivepositiontaking_3 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=1
select @auto_mpositiontaking_7 = autompositiontaking, @auto_mlivepositiontaking_7 = autolivempositiontaking, @isauto_mpositiontaking_7 = isautompositiontaking, @isauto_mlivepositiontaking_7 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=7 and sporttype=1
select @auto_mpositiontaking_8 = autompositiontaking, @auto_mlivepositiontaking_8 = autolivempositiontaking, @isauto_mpositiontaking_8 = isautompositiontaking, @isauto_mlivepositiontaking_8 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=8 and sporttype=1
select @auto_mpositiontaking_2 = autompositiontaking, @isauto_mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=1
select @auto_mpositiontaking_4 = autompositiontaking, @isauto_mpositiontaking_4 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=4 and sporttype=1
--select @mpositiontaking_4 = mpositiontaking, @maxdiscountcs = discount from custsetting with (NOLOCK) where custid = @recommend and bettype=4 and sporttype=1
select @auto_mpositiontaking_5 = autompositiontaking, @isauto_mpositiontaking_5 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=5 and sporttype=1
select @auto_mpositiontaking_6 = autompositiontaking, @isauto_mpositiontaking_6 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=6 and sporttype=1
select @auto_mpositiontaking_9 = autompositiontaking, @isauto_mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=1
select @auto_mpositiontaking_10 = autompositiontaking, @isauto_mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=1
-- Outright PT for sports
select @auto_v2mpositiontaking_10 = autompositiontaking, @isauto_v2mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=2
select @auto_v3mpositiontaking_10 = autompositiontaking, @isauto_v3mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=3
select @auto_v5mpositiontaking_10 = autompositiontaking, @isauto_v5mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=5
select @auto_v8mpositiontaking_10 = autompositiontaking, @isauto_v8mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=8
select @auto_v10mpositiontaking_10 = autompositiontaking, @isauto_v10mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=10
select @auto_v11mpositiontaking_10 = autompositiontaking, @isauto_v11mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=11
select @auto_v99mpositiontaking_10 = autompositiontaking, @isauto_v99mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=99


select @auto_mpositiontaking_9999 = autompositiontaking, @isauto_mpositiontaking_9999 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9999 and sporttype=1

select @auto_v2mpositiontaking_1 = autompositiontaking, @isauto_v2mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=2
select @auto_v2mpositiontaking_2 = autompositiontaking, @isauto_v2mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=2
select @auto_v2mpositiontaking_3 = autompositiontaking, @isauto_v2mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=2
select @auto_v2mpositiontaking_7 = autompositiontaking, @isauto_v2mpositiontaking_7 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=7 and sporttype=2
select @auto_v2mpositiontaking_8 = autompositiontaking, @isauto_v2mpositiontaking_8 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=8 and sporttype=2
--select @auto_v2mpositiontaking_9 = autompositiontaking, @isauto_v2mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=2
select @auto_v2mpositiontaking_20 = autompositiontaking, @isauto_v2mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=2

select @auto_v3mpositiontaking_1 = autompositiontaking, @isauto_v3mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=3
select @auto_v3mpositiontaking_2 = autompositiontaking, @isauto_v3mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=3
select @auto_v3mpositiontaking_3 = autompositiontaking, @isauto_v3mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=3
select @auto_v3mpositiontaking_20 = autompositiontaking, @isauto_v3mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=3

select @auto_v5mpositiontaking_1 = autompositiontaking, @isauto_v5mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=5
select @auto_v5mpositiontaking_2 = autompositiontaking, @isauto_v5mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=5
select @auto_v5mpositiontaking_3 = autompositiontaking, @isauto_v5mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=5
select @auto_v5mpositiontaking_20 = autompositiontaking, @isauto_v5mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=5
select @auto_v5mpositiontaking_9999 = autompositiontaking, @isauto_v5mpositiontaking_9999 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9999 and sporttype=5

select @auto_v8mpositiontaking_1 = autompositiontaking, @isauto_v8mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=8
select @auto_v8mpositiontaking_3 = autompositiontaking, @isauto_v8mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=8
select @auto_v8mpositiontaking_20 = autompositiontaking, @isauto_v8mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=8

select @auto_v10mpositiontaking_1 = autompositiontaking, @isauto_v10mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=10
select @auto_v10mpositiontaking_2 = autompositiontaking, @isauto_v10mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=10
select @auto_v10mpositiontaking_3 = autompositiontaking, @isauto_v10mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=10
select @auto_v10mpositiontaking_20 = autompositiontaking, @isauto_v10mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=10

select @auto_v11mpositiontaking_1 = autompositiontaking, @isauto_v11mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=11
select @auto_v11mpositiontaking_20 = autompositiontaking, @isauto_v11mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=11

select @auto_v99mpositiontaking_1 = autompositiontaking, @isauto_v99mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=99
select @auto_v99mpositiontaking_2 = autompositiontaking, @isauto_v99mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=99
select @auto_v99mpositiontaking_3 = autompositiontaking, @isauto_v99mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=99
select @auto_v99mpositiontaking_9 = autompositiontaking, @isauto_v99mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=99
select @auto_v99mpositiontaking_20 = autompositiontaking, @isauto_v99mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=99

select @auto_v154mpositiontaking_20 = autompositiontaking, @isauto_v154mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=154

select @auto_v161mpositiontaking_81 = autompositiontaking,  @isauto_v161mpositiontaking_81 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=81 and sporttype=161
select @auto_v161mpositiontaking_83 = autompositiontaking,  @isauto_v161mpositiontaking_83 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=83 and sporttype=161
select @auto_v161mpositiontaking_88 = autompositiontaking,  @isauto_v161mpositiontaking_88 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=88 and sporttype=161
select @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=85 and sporttype=161
select @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=86 and sporttype=161
select @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=87 and sporttype=161
select @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=89 and sporttype=161
select @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=90 and sporttype=161
------------------------------------------------------------------------------------------------------------------------------



--s3,m3,u3,i3
SELECT @mapositiontaking_1_max = mpositiontaking, @malivepositiontaking_1_max = mlivepositiontaking, @auto_spositiontaking_1 = autopositiontaking, @auto_slivepositiontaking_1 = autolivepositiontaking, @isauto_spositiontaking_1 = isautopositiontaking, @isauto_slivepositiontaking_1 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=1
SELECT @mapositiontaking_3_max = mpositiontaking, @malivepositiontaking_3_max = mlivepositiontaking, @auto_spositiontaking_3 = autopositiontaking, @auto_slivepositiontaking_3 = autolivepositiontaking, @isauto_spositiontaking_3 = isautopositiontaking, @isauto_slivepositiontaking_3 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=1
SELECT @mapositiontaking_7_max = mpositiontaking, @malivepositiontaking_7_max = mlivepositiontaking, @auto_spositiontaking_7 = autopositiontaking, @auto_slivepositiontaking_7 = autolivepositiontaking, @isauto_spositiontaking_7 = isautopositiontaking, @isauto_slivepositiontaking_7 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=1
SELECT @mapositiontaking_8_max = mpositiontaking, @malivepositiontaking_8_max = mlivepositiontaking, @auto_spositiontaking_8 = autopositiontaking, @auto_slivepositiontaking_8 = autolivepositiontaking, @isauto_spositiontaking_8 = isautopositiontaking, @isauto_slivepositiontaking_8 = isautolivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=1
SELECT @mapositiontaking_2_max = mpositiontaking, @auto_spositiontaking_2 = autopositiontaking, @isauto_spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=1
SELECT @mapositiontaking_4_max = mpositiontaking, @auto_spositiontaking_4 = autopositiontaking, @isauto_spositiontaking_4 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=4 AND sporttype=1
SELECT @mapositiontaking_5_max = mpositiontaking, @auto_spositiontaking_5 = autopositiontaking, @isauto_spositiontaking_5 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=5 AND sporttype=1
SELECT @mapositiontaking_6_max = mpositiontaking, @auto_spositiontaking_6 = autopositiontaking, @isauto_spositiontaking_6 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=6 AND sporttype=1
SELECT @mapositiontaking_9_max = mpositiontaking, @auto_spositiontaking_9 = autopositiontaking, @isauto_spositiontaking_9 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=1
SELECT @mapositiontaking_10_max = mpositiontaking, @auto_spositiontaking_10 = autopositiontaking, @isauto_spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=1

-- Outright PT for sports
SELECT @v2mapositiontaking_10_max = mpositiontaking, @auto_v2spositiontaking_10 = autopositiontaking, @isauto_v2spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=2
SELECT @v3mapositiontaking_10_max = mpositiontaking, @auto_v3spositiontaking_10 = autopositiontaking, @isauto_v3spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=3
SELECT @v5mapositiontaking_10_max = mpositiontaking, @auto_v5spositiontaking_10 = autopositiontaking, @isauto_v5spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=5
SELECT @v8mapositiontaking_10_max = mpositiontaking, @auto_v8spositiontaking_10 = autopositiontaking, @isauto_v8spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=8
SELECT @v10mapositiontaking_10_max = mpositiontaking, @auto_v10spositiontaking_10 = autopositiontaking, @isauto_v10spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=10
SELECT @v11mapositiontaking_10_max = mpositiontaking, @auto_v11spositiontaking_10 = autopositiontaking, @isauto_v11spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=11
SELECT @v99mapositiontaking_10_max = mpositiontaking, @auto_v99spositiontaking_10 = autopositiontaking, @isauto_v99spositiontaking_10 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=10 AND sporttype=99

SELECT @mapositiontaking_9999_max = mpositiontaking, @auto_spositiontaking_9999 = autopositiontaking, @isauto_spositiontaking_9999 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=1

SELECT @v2mapositiontaking_1_max = mpositiontaking, @auto_v2spositiontaking_1 = autopositiontaking, @isauto_v2spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=2
SELECT @v2mapositiontaking_2_max = mpositiontaking, @auto_v2spositiontaking_2 = autopositiontaking, @isauto_v2spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=2
SELECT @v2mapositiontaking_3_max = mpositiontaking, @auto_v2spositiontaking_3 = autopositiontaking, @isauto_v2spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=2
SELECT @v2mapositiontaking_7_max = mpositiontaking, @auto_v2spositiontaking_7 = autopositiontaking, @isauto_v2spositiontaking_7 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=7 AND sporttype=2
SELECT @v2mapositiontaking_8_max = mpositiontaking, @auto_v2spositiontaking_8 = autopositiontaking, @isauto_v2spositiontaking_8 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=8 AND sporttype=2
--SELECT @v2mapositiontaking_9_max = mpositiontaking, @auto_v2spositiontaking_9 = autopositiontaking, @isauto_v2spositiontaking_9 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=2
SELECT @v2mapositiontaking_20_max = mpositiontaking, @auto_v2spositiontaking_20 = autopositiontaking, @isauto_v2spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=2

SELECT @v3mapositiontaking_1_max = mpositiontaking, @auto_v3spositiontaking_1 = autopositiontaking, @isauto_v3spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=3
SELECT @v3mapositiontaking_2_max = mpositiontaking, @auto_v3spositiontaking_2 = autopositiontaking, @isauto_v3spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=3
SELECT @v3mapositiontaking_3_max = mpositiontaking, @auto_v3spositiontaking_3 = autopositiontaking, @isauto_v3spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=3
SELECT @v3mapositiontaking_20_max = mpositiontaking, @auto_v3spositiontaking_20 = autopositiontaking, @isauto_v3spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=3

SELECT @v5mapositiontaking_1_max = mpositiontaking, @auto_v5spositiontaking_1 = autopositiontaking, @isauto_v5spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=5
SELECT @v5mapositiontaking_2_max = mpositiontaking, @auto_v5spositiontaking_2 = autopositiontaking, @isauto_v5spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=5
SELECT @v5mapositiontaking_3_max = mpositiontaking, @auto_v5spositiontaking_3 = autopositiontaking, @isauto_v5spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=5
SELECT @v5mapositiontaking_20_max = mpositiontaking, @auto_v5spositiontaking_20 = autopositiontaking, @isauto_v5spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=5
SELECT @v5mapositiontaking_9999_max = mpositiontaking, @auto_v5spositiontaking_9999 = autopositiontaking, @isauto_v5spositiontaking_9999 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9999 AND sporttype=5

SELECT @v8mapositiontaking_1_max = mpositiontaking, @auto_v8spositiontaking_1 = autopositiontaking, @isauto_v8spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=8
SELECT @v8mapositiontaking_3_max = mpositiontaking, @auto_v8spositiontaking_3 = autopositiontaking, @isauto_v8spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=8
SELECT @v8mapositiontaking_20_max = mpositiontaking, @auto_v8spositiontaking_20 = autopositiontaking, @isauto_v8spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=8

SELECT @v10mapositiontaking_1_max = mpositiontaking, @auto_v10spositiontaking_1 = autopositiontaking, @isauto_v10spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=10
SELECT @v10mapositiontaking_2_max = mpositiontaking, @auto_v10spositiontaking_2 = autopositiontaking, @isauto_v10spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=10
SELECT @v10mapositiontaking_3_max = mpositiontaking, @auto_v10spositiontaking_3 = autopositiontaking, @isauto_v10spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=10
SELECT @v10mapositiontaking_20_max = mpositiontaking, @auto_v10spositiontaking_20 = autopositiontaking, @isauto_v10spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=10

SELECT @v11mapositiontaking_1_max = mpositiontaking, @auto_v11spositiontaking_1 = autopositiontaking, @isauto_v11spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=11
SELECT @v11mapositiontaking_20_max = mpositiontaking, @auto_v11spositiontaking_20 = autopositiontaking, @isauto_v11spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=11

SELECT @v99mapositiontaking_1_max = mpositiontaking, @auto_v99spositiontaking_1 = autopositiontaking, @isauto_v99spositiontaking_1 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=1 AND sporttype=99
SELECT @v99mapositiontaking_2_max = mpositiontaking, @auto_v99spositiontaking_2 = autopositiontaking, @isauto_v99spositiontaking_2 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=2 AND sporttype=99
SELECT @v99mapositiontaking_3_max = mpositiontaking, @auto_v99spositiontaking_3 = autopositiontaking, @isauto_v99spositiontaking_3 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=3 AND sporttype=99
SELECT @v99mapositiontaking_9_max = mpositiontaking, @auto_v99spositiontaking_9 = autopositiontaking, @isauto_v99spositiontaking_9 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=9 AND sporttype=99
SELECT @v99mapositiontaking_20_max = mpositiontaking, @auto_v99spositiontaking_20 = autopositiontaking, @isauto_v99spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=99

SELECT @v154mapositiontaking_20_max = mpositiontaking, @auto_v154spositiontaking_20 = autopositiontaking, @isauto_v154spositiontaking_20 = isautopositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=20 AND sporttype=154

--v161
SELECT @v161mapositiontaking_81_max = mpositiontaking, @auto_v161spositiontaking_81 = autopositiontaking, @isauto_v161spositiontaking_81 = isautopositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=81 AND sporttype=161
SELECT @v161mapositiontaking_83_max = mpositiontaking, @auto_v161spositiontaking_83 = autopositiontaking, @isauto_v161spositiontaking_83 = isautopositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=83 AND sporttype=161
SELECT @v161mapositiontaking_88_max = mpositiontaking, @auto_v161spositiontaking_88 = autopositiontaking, @isauto_v161spositiontaking_88 = isautopositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=88 AND sporttype=161
SELECT @v161malivepositiontaking_85_max = mlivepositiontaking, @auto_v161slivepositiontaking_85 = autolivepositiontaking, @isauto_v161slivepositiontaking_85 = isautolivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=85 AND sporttype=161
SELECT @v161mapositiontaking_86_max = mpositiontaking, @v161malivepositiontaking_86_max = mlivepositiontaking, @auto_v161spositiontaking_86 = autopositiontaking, @auto_v161slivepositiontaking_86 = autolivepositiontaking, @isauto_v161spositiontaking_86 = isautopositiontaking, @isauto_v161slivepositiontaking_86 = isautolivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=86 AND sporttype=161
SELECT @v161malivepositiontaking_87_max = mlivepositiontaking, @auto_v161slivepositiontaking_87 = autolivepositiontaking, @isauto_v161slivepositiontaking_87 = isautolivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=87 AND sporttype=161
SELECT @v161malivepositiontaking_89_max = mlivepositiontaking, @auto_v161slivepositiontaking_89 = autolivepositiontaking, @isauto_v161slivepositiontaking_89 = isautolivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=89 AND sporttype=161
SELECT @v161malivepositiontaking_90_max = mlivepositiontaking, @auto_v161slivepositiontaking_90 = autolivepositiontaking, @isauto_v161slivepositiontaking_90 = isautolivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=90 AND sporttype=161

--s4
SELECT @max_spositiontaking_1 = spositiontaking, @max_slivepositiontaking_1 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=1
SELECT @max_spositiontaking_3 = spositiontaking, @max_slivepositiontaking_3 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=1
SELECT @max_spositiontaking_7 = spositiontaking, @max_slivepositiontaking_7 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype=1
SELECT @max_spositiontaking_8 = spositiontaking, @max_slivepositiontaking_8 = slivepositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype=1
SELECT @max_spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=1
SELECT @max_spositiontaking_4 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=4 AND sporttype=1
SELECT @max_spositiontaking_5 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=5 AND sporttype=1
SELECT @max_spositiontaking_6 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=6 AND sporttype=1
SELECT @max_spositiontaking_9 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=1
SELECT @max_spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=1

-- Outright PT for sports
SELECT @max_v2spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=2
SELECT @max_v3spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=3
SELECT @max_v5spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=5
SELECT @max_v8spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=8
SELECT @max_v10spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=10
SELECT @max_v11spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=11
SELECT @max_v99spositiontaking_10 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=10 AND sporttype=99

SELECT @max_spositiontaking_9999 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=1

SELECT @max_v2spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=2
SELECT @max_v2spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=2
SELECT @max_v2spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=2
SELECT @max_v2spositiontaking_7 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=7 AND sporttype=2
SELECT @max_v2spositiontaking_8 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=8 AND sporttype=2
--SELECT @max_v2spositiontaking_9 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=2
SELECT @max_v2spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=2

SELECT @max_v3spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=3
SELECT @max_v3spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=3
SELECT @max_v3spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=3
SELECT @max_v3spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=3

SELECT @max_v5spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=5
SELECT @max_v5spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=5
SELECT @max_v5spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=5
SELECT @max_v5spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=5
SELECT @max_v5spositiontaking_9999 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9999 AND sporttype=5

SELECT @max_v8spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=8
SELECT @max_v8spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=8
SELECT @max_v8spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=8

SELECT @max_v10spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=10
SELECT @max_v10spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=10
SELECT @max_v10spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=10
SELECT @max_v10spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=10

SELECT @max_v11spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=11
SELECT @max_v11spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=11

SELECT @max_v99spositiontaking_1 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=1 AND sporttype=99
SELECT @max_v99spositiontaking_2 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=2 AND sporttype=99
SELECT @max_v99spositiontaking_3 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=3 AND sporttype=99
SELECT @max_v99spositiontaking_9 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=9 AND sporttype=99
SELECT @max_v99spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=99

SELECT @max_v154spositiontaking_20 = spositiontaking FROM custsetting WITH (NOLOCK) WHERE custid = @srecommend AND bettype=20 AND sporttype=154

--v161
SELECT @max_v161spositiontaking_81 = spositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=81 AND sporttype=161
SELECT @max_v161spositiontaking_83 = spositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=83 AND sporttype=161
SELECT @max_v161spositiontaking_88 = spositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=88 AND sporttype=161
SELECT @max_v161slivepositiontaking_85 = slivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=85 AND sporttype=161
SELECT @max_v161spositiontaking_86 = spositiontaking, @max_v161slivepositiontaking_86 = slivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=86 AND sporttype=161
SELECT @max_v161slivepositiontaking_87 = slivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=87 AND sporttype=161
SELECT @max_v161slivepositiontaking_89 = slivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=89 AND sporttype=161
SELECT @max_v161slivepositiontaking_90 = slivepositiontaking FROM custsetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=90 AND sporttype=161

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
	--@auto_v2spositiontaking_9 = CASE WHEN @isauto_v2spositiontaking_mem_9>0 THEN @auto_v2spositiontaking_mem_9 ELSE @auto_v2spositiontaking_9 END,
	@auto_v2spositiontaking_20 = CASE WHEN @isauto_v2spositiontaking_mem_20>0 THEN @auto_v2spositiontaking_mem_20 ELSE @auto_v2spositiontaking_20 END,

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
	@auto_v99spositiontaking_9 = CASE WHEN @isauto_v99spositiontaking_mem_9>0 THEN @auto_v99spositiontaking_mem_9 ELSE @auto_v99spositiontaking_9 END,
	@auto_v99spositiontaking_20 = CASE WHEN @isauto_v99spositiontaking_mem_20>0 THEN @auto_v99spositiontaking_mem_20 ELSE @auto_v99spositiontaking_20 END,
	
	@auto_v154spositiontaking_20 = CASE WHEN @isauto_v154spositiontaking_mem_20>0 THEN @auto_v154spositiontaking_mem_20 ELSE @auto_v154spositiontaking_20 END,
	
	--v161
	@auto_v161spositiontaking_81 = CASE WHEN @isauto_v161spositiontaking_mem_81>0 THEN @isauto_v161spositiontaking_mem_81 ELSE @auto_v161spositiontaking_81 END,
	@auto_v161spositiontaking_83 = CASE WHEN @isauto_v161spositiontaking_mem_83>0 THEN @isauto_v161spositiontaking_mem_83 ELSE @auto_v161spositiontaking_83 END,	
	@auto_v161spositiontaking_86 = CASE WHEN @isauto_v161spositiontaking_mem_86>0 THEN @isauto_v161spositiontaking_mem_86 ELSE @auto_v161spositiontaking_86 END,
	@auto_v161spositiontaking_88 = CASE WHEN @isauto_v161spositiontaking_mem_88>0 THEN @isauto_v161spositiontaking_mem_88 ELSE @auto_v161spositiontaking_88 END,
	
	@auto_v161slivepositiontaking_85 = CASE WHEN @isauto_v161slivepositiontaking_mem_85>0 THEN @auto_v161slivepositiontaking_mem_85 ELSE @auto_v161slivepositiontaking_85 END,	
	@auto_v161slivepositiontaking_86 = CASE WHEN @isauto_v161slivepositiontaking_mem_86>0 THEN @auto_v161slivepositiontaking_mem_86 ELSE @auto_v161slivepositiontaking_86 END,	
	@auto_v161slivepositiontaking_87 = CASE WHEN @isauto_v161slivepositiontaking_mem_87>0 THEN @auto_v161slivepositiontaking_mem_87 ELSE @auto_v161slivepositiontaking_87 END,	
	@auto_v161slivepositiontaking_89 = CASE WHEN @isauto_v161slivepositiontaking_mem_89>0 THEN @auto_v161slivepositiontaking_mem_89 ELSE @auto_v161slivepositiontaking_89 END,
	@auto_v161slivepositiontaking_90 = CASE WHEN @isauto_v161slivepositiontaking_mem_90>0 THEN @auto_v161slivepositiontaking_mem_90 ELSE @auto_v161slivepositiontaking_90 END,

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
	--@isauto_v2spositiontaking_9 = CASE WHEN @isauto_v2spositiontaking_mem_9>0 THEN @isauto_v2spositiontaking_mem_9 ELSE @isauto_v2spositiontaking_9 END,
	@isauto_v2spositiontaking_20 = CASE WHEN @isauto_v2spositiontaking_mem_20>0 THEN @isauto_v2spositiontaking_mem_20 ELSE @isauto_v2spositiontaking_20 END,
	
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
	@isauto_v99spositiontaking_9 = CASE WHEN @isauto_v99spositiontaking_mem_9>0 THEN @isauto_v99spositiontaking_mem_9 ELSE @isauto_v99spositiontaking_9 END,
	@isauto_v99spositiontaking_20 = CASE WHEN @isauto_v99spositiontaking_mem_20>0 THEN @isauto_v99spositiontaking_mem_20 ELSE @isauto_v99spositiontaking_20 END,
	
	@isauto_v154spositiontaking_20 = CASE WHEN @isauto_v154spositiontaking_mem_20>0 THEN @isauto_v154spositiontaking_mem_20 ELSE @isauto_v154spositiontaking_20 END,
	
	--v161
	@isauto_v161spositiontaking_81 = CASE WHEN @isauto_v161spositiontaking_mem_81>0 THEN @isauto_v161spositiontaking_mem_81 ELSE @isauto_v161spositiontaking_81 END,
	@isauto_v161spositiontaking_83 = CASE WHEN @isauto_v161spositiontaking_mem_83>0 THEN @isauto_v161spositiontaking_mem_83 ELSE @isauto_v161spositiontaking_83 END,	
	@isauto_v161spositiontaking_86 = CASE WHEN @isauto_v161spositiontaking_mem_86>0 THEN @isauto_v161spositiontaking_mem_86 ELSE @isauto_v161spositiontaking_86 END,
	@isauto_v161spositiontaking_88 = CASE WHEN @isauto_v161spositiontaking_mem_88>0 THEN @isauto_v161spositiontaking_mem_88 ELSE @isauto_v161spositiontaking_88 END,

	@isauto_v161slivepositiontaking_85 = CASE WHEN @isauto_v161slivepositiontaking_mem_85>0 THEN @isauto_v161slivepositiontaking_mem_85 ELSE @isauto_v161slivepositiontaking_85 END,
	@isauto_v161slivepositiontaking_86 = CASE WHEN @isauto_v161slivepositiontaking_mem_86>0 THEN @isauto_v161slivepositiontaking_mem_86 ELSE @isauto_v161slivepositiontaking_86 END,
	@isauto_v161slivepositiontaking_87 = CASE WHEN @isauto_v161slivepositiontaking_mem_87>0 THEN @isauto_v161slivepositiontaking_mem_87 ELSE @isauto_v161slivepositiontaking_87 END,
	@isauto_v161slivepositiontaking_89 = CASE WHEN @isauto_v161slivepositiontaking_mem_89>0 THEN @isauto_v161slivepositiontaking_mem_89 ELSE @isauto_v161slivepositiontaking_89 END,
	@isauto_v161slivepositiontaking_90 = CASE WHEN @isauto_v161slivepositiontaking_mem_90>0 THEN @isauto_v161slivepositiontaking_mem_90 ELSE @isauto_v161slivepositiontaking_90 END
	
	
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	--@auto_v2mpositiontaking_9 = CASE WHEN @isauto_v2mpositiontaking_mem_9>0 THEN @auto_v2mpositiontaking_mem_9 ELSE @auto_v2mpositiontaking_9 END,
	@auto_v2mpositiontaking_20 = CASE WHEN @isauto_v2mpositiontaking_mem_20>0 THEN @auto_v2mpositiontaking_mem_20 ELSE @auto_v2mpositiontaking_20 END,

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
	@auto_v99mpositiontaking_9 = CASE WHEN @isauto_v99mpositiontaking_mem_9>0 THEN @auto_v99mpositiontaking_mem_9 ELSE @auto_v99mpositiontaking_9 END,
	@auto_v99mpositiontaking_20 = CASE WHEN @isauto_v99mpositiontaking_mem_20>0 THEN @auto_v99mpositiontaking_mem_20 ELSE @auto_v99mpositiontaking_20 END,

	@auto_v154mpositiontaking_20 = CASE WHEN @isauto_v154mpositiontaking_mem_20>0 THEN @auto_v154mpositiontaking_mem_20 ELSE @auto_v154mpositiontaking_20 END,
	
	@auto_v161mpositiontaking_81 = CASE WHEN @isauto_v161mpositiontaking_mem_81>0 THEN @auto_v161mpositiontaking_mem_81 ELSE @auto_v161mpositiontaking_81 END,
	@auto_v161mpositiontaking_83 = CASE WHEN @isauto_v161mpositiontaking_mem_83>0 THEN @auto_v161mpositiontaking_mem_83 ELSE @auto_v161mpositiontaking_83 END,	
	@auto_v161mpositiontaking_86 = CASE WHEN @isauto_v161mpositiontaking_mem_86>0 THEN @auto_v161mpositiontaking_mem_86 ELSE @auto_v161mpositiontaking_86 END,
	@auto_v161mpositiontaking_88 = CASE WHEN @isauto_v161mpositiontaking_mem_88>0 THEN @auto_v161mpositiontaking_mem_88 ELSE @auto_v161mpositiontaking_88 END,
	
	@auto_v161mlivepositiontaking_85 = CASE WHEN @isauto_v161mlivepositiontaking_mem_85>0 THEN @auto_v161mlivepositiontaking_mem_85 ELSE @auto_v161mlivepositiontaking_85 END,
	@auto_v161mlivepositiontaking_86 = CASE WHEN @isauto_v161mlivepositiontaking_mem_86>0 THEN @auto_v161mlivepositiontaking_mem_86 ELSE @auto_v161mlivepositiontaking_86 END,
	@auto_v161mlivepositiontaking_87 = CASE WHEN @isauto_v161mlivepositiontaking_mem_87>0 THEN @auto_v161mlivepositiontaking_mem_87 ELSE @auto_v161mlivepositiontaking_87 END,
	@auto_v161mlivepositiontaking_89 = CASE WHEN @isauto_v161mlivepositiontaking_mem_89>0 THEN @auto_v161mlivepositiontaking_mem_89 ELSE @auto_v161mlivepositiontaking_89 END,
	@auto_v161mlivepositiontaking_90 = CASE WHEN @isauto_v161mlivepositiontaking_mem_90>0 THEN @auto_v161mlivepositiontaking_mem_90 ELSE @auto_v161mlivepositiontaking_90 END,
	
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
	--@isauto_v2mpositiontaking_9 = CASE WHEN @isauto_v2mpositiontaking_mem_9>0 THEN @isauto_v2mpositiontaking_mem_9 ELSE @isauto_v2mpositiontaking_9 END,
	@isauto_v2mpositiontaking_20 = CASE WHEN @isauto_v2mpositiontaking_mem_20>0 THEN @isauto_v2mpositiontaking_mem_20 ELSE @isauto_v2mpositiontaking_20 END,

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
	@isauto_v99mpositiontaking_9 = CASE WHEN @isauto_v99mpositiontaking_mem_9>0 THEN @isauto_v99mpositiontaking_mem_9 ELSE @isauto_v99mpositiontaking_9 END,
	@isauto_v99mpositiontaking_20 = CASE WHEN @isauto_v99mpositiontaking_mem_20>0 THEN @isauto_v99mpositiontaking_mem_20 ELSE @isauto_v99mpositiontaking_20 END,
	
	@isauto_v154mpositiontaking_20 = CASE WHEN @isauto_v154mpositiontaking_mem_20>0 THEN @isauto_v154mpositiontaking_mem_20 ELSE @isauto_v154mpositiontaking_20 END,
	
	--v161
	@isauto_v161mpositiontaking_81 = CASE WHEN @isauto_v161mpositiontaking_mem_81>0 THEN @isauto_v161mpositiontaking_mem_81 ELSE @isauto_v161mpositiontaking_81 END,
	@isauto_v161mpositiontaking_83 = CASE WHEN @isauto_v161mpositiontaking_mem_83>0 THEN @isauto_v161mpositiontaking_mem_83 ELSE @isauto_v161mpositiontaking_83 END,	
	@isauto_v161mpositiontaking_86 = CASE WHEN @isauto_v161mpositiontaking_mem_86>0 THEN @isauto_v161mpositiontaking_mem_86 ELSE @isauto_v161mpositiontaking_86 END,
	@isauto_v161mpositiontaking_88 = CASE WHEN @isauto_v161mpositiontaking_mem_88>0 THEN @isauto_v161mpositiontaking_mem_88 ELSE @isauto_v161mpositiontaking_88 END,
	
	@isauto_v161mlivepositiontaking_85 = CASE WHEN @isauto_v161mlivepositiontaking_mem_85>0 THEN @isauto_v161mlivepositiontaking_mem_85 ELSE @isauto_v161mlivepositiontaking_85 END,
	@isauto_v161mlivepositiontaking_86 = CASE WHEN @isauto_v161mlivepositiontaking_mem_86>0 THEN @isauto_v161mlivepositiontaking_mem_86 ELSE @isauto_v161mlivepositiontaking_86 END,
	@isauto_v161mlivepositiontaking_87 = CASE WHEN @isauto_v161mlivepositiontaking_mem_87>0 THEN @isauto_v161mlivepositiontaking_mem_87 ELSE @isauto_v161mlivepositiontaking_87 END,
	@isauto_v161mlivepositiontaking_89 = CASE WHEN @isauto_v161mlivepositiontaking_mem_89>0 THEN @isauto_v161mlivepositiontaking_mem_89 ELSE @isauto_v161mlivepositiontaking_89 END,
	@isauto_v161mlivepositiontaking_90 = CASE WHEN @isauto_v161mlivepositiontaking_mem_90>0 THEN @isauto_v161mlivepositiontaking_mem_90 ELSE @isauto_v161mlivepositiontaking_90 END
	
---------------------------------------------------------------------------------------------------------------------------------------------


--a1=min(a1,m3)
SELECT 
	@apositiontaking_1 = CASE WHEN @apositiontaking_1>@mapositiontaking_1_max THEN @mapositiontaking_1_max ELSE @apositiontaking_1 END,
	@apositiontaking_2 = CASE WHEN @apositiontaking_2>@mapositiontaking_2_max THEN @mapositiontaking_2_max ELSE @apositiontaking_2 END,
	@apositiontaking_3 = CASE WHEN @apositiontaking_3>@mapositiontaking_3_max THEN @mapositiontaking_3_max ELSE @apositiontaking_3 END,
	@apositiontaking_4 = CASE WHEN @apositiontaking_4>@mapositiontaking_4_max THEN @mapositiontaking_4_max ELSE @apositiontaking_4 END,
	@apositiontaking_5 = CASE WHEN @apositiontaking_5>@mapositiontaking_5_max THEN @mapositiontaking_5_max ELSE @apositiontaking_5 END,
	@apositiontaking_6 = CASE WHEN @apositiontaking_6>@mapositiontaking_6_max THEN @mapositiontaking_6_max ELSE @apositiontaking_6 END,
	@apositiontaking_7 = CASE WHEN @apositiontaking_7>@mapositiontaking_7_max THEN @mapositiontaking_7_max ELSE @apositiontaking_7 END,
	@apositiontaking_8 = CASE WHEN @apositiontaking_8>@mapositiontaking_8_max THEN @mapositiontaking_8_max ELSE @apositiontaking_8 END,
	@apositiontaking_9 = CASE WHEN @apositiontaking_9>@mapositiontaking_9_max THEN @mapositiontaking_9_max ELSE @apositiontaking_9 END,
	@apositiontaking_10 = CASE WHEN @apositiontaking_10>@mapositiontaking_10_max THEN @mapositiontaking_10_max ELSE @apositiontaking_10 END,
	
	-- Outright PT for sports
	@v2apositiontaking_10 = CASE WHEN @v2apositiontaking_10>@v2mapositiontaking_10_max THEN @v2mapositiontaking_10_max ELSE @v2apositiontaking_10 END,
	@v3apositiontaking_10 = CASE WHEN @v3apositiontaking_10>@v3mapositiontaking_10_max THEN @v3mapositiontaking_10_max ELSE @v3apositiontaking_10 END,
	@v5apositiontaking_10 = CASE WHEN @v5apositiontaking_10>@v5mapositiontaking_10_max THEN @v5mapositiontaking_10_max ELSE @v5apositiontaking_10 END,
	@v8apositiontaking_10 = CASE WHEN @v8apositiontaking_10>@v8mapositiontaking_10_max THEN @v8mapositiontaking_10_max ELSE @v8apositiontaking_10 END,
	@v10apositiontaking_10 = CASE WHEN @v10apositiontaking_10>@v10mapositiontaking_10_max THEN @v10mapositiontaking_10_max ELSE @v10apositiontaking_10 END,
	@v11apositiontaking_10 = CASE WHEN @v11apositiontaking_10>@v11mapositiontaking_10_max THEN @v11mapositiontaking_10_max ELSE @v11apositiontaking_10 END,
	@v99apositiontaking_10 = CASE WHEN @v99apositiontaking_10>@v99mapositiontaking_10_max THEN @v99mapositiontaking_10_max ELSE @v99apositiontaking_10 END,
	
	@apositiontaking_9999 = CASE WHEN @apositiontaking_9999>@mapositiontaking_9999_max THEN @mapositiontaking_9999_max ELSE @apositiontaking_9999 END,

	@alivepositiontaking_1 = CASE WHEN @alivepositiontaking_1>@malivepositiontaking_1_max THEN @malivepositiontaking_1_max ELSE @alivepositiontaking_1 END,
	@alivepositiontaking_3 = CASE WHEN @alivepositiontaking_3>@malivepositiontaking_3_max THEN @malivepositiontaking_3_max ELSE @alivepositiontaking_3 END,
	@alivepositiontaking_7 = CASE WHEN @alivepositiontaking_7>@malivepositiontaking_7_max THEN @malivepositiontaking_7_max ELSE @alivepositiontaking_7 END,
	@alivepositiontaking_8 = CASE WHEN @alivepositiontaking_8>@malivepositiontaking_8_max THEN @malivepositiontaking_8_max ELSE @alivepositiontaking_8 END,

	@v2apositiontaking_1 = CASE WHEN @v2apositiontaking_1>@v2mapositiontaking_1_max THEN @v2mapositiontaking_1_max ELSE @v2apositiontaking_1 END,
	@v2apositiontaking_2 = CASE WHEN @v2apositiontaking_2>@v2mapositiontaking_2_max THEN @v2mapositiontaking_2_max ELSE @v2apositiontaking_2 END,
	@v2apositiontaking_3 = CASE WHEN @v2apositiontaking_3>@v2mapositiontaking_3_max THEN @v2mapositiontaking_3_max ELSE @v2apositiontaking_3 END,
	@v2apositiontaking_7 = CASE WHEN @v2apositiontaking_7>@v2mapositiontaking_7_max THEN @v2mapositiontaking_7_max ELSE @v2apositiontaking_7 END,
	@v2apositiontaking_8 = CASE WHEN @v2apositiontaking_8>@v2mapositiontaking_8_max THEN @v2mapositiontaking_8_max ELSE @v2apositiontaking_8 END,
	--@v2apositiontaking_9 = CASE WHEN @v2apositiontaking_9>@v2mapositiontaking_9_max THEN @v2mapositiontaking_9_max ELSE @v2apositiontaking_9 END,
	@v2apositiontaking_20 = CASE WHEN @v2apositiontaking_20>@v2mapositiontaking_20_max THEN @v2mapositiontaking_20_max ELSE @v2apositiontaking_20 END,
	
	@v3apositiontaking_1 = CASE WHEN @v3apositiontaking_1>@v3mapositiontaking_1_max THEN @v3mapositiontaking_1_max ELSE @v3apositiontaking_1 END,
	@v3apositiontaking_2 = CASE WHEN @v3apositiontaking_2>@v3mapositiontaking_2_max THEN @v3mapositiontaking_2_max ELSE @v3apositiontaking_2 END,
	@v3apositiontaking_3 = CASE WHEN @v3apositiontaking_3>@v3mapositiontaking_3_max THEN @v3mapositiontaking_3_max ELSE @v3apositiontaking_3 END,
	@v3apositiontaking_20 = CASE WHEN @v3apositiontaking_20>@v3mapositiontaking_20_max THEN @v3mapositiontaking_20_max ELSE @v3apositiontaking_20 END,

	@v5apositiontaking_1 = CASE WHEN @v5apositiontaking_1>@v5mapositiontaking_1_max THEN @v5mapositiontaking_1_max ELSE @v5apositiontaking_1 END,
	@v5apositiontaking_2 = CASE WHEN @v5apositiontaking_2>@v5mapositiontaking_2_max THEN @v5mapositiontaking_2_max ELSE @v5apositiontaking_2 END,
	@v5apositiontaking_3 = CASE WHEN @v5apositiontaking_3>@v5mapositiontaking_3_max THEN @v5mapositiontaking_3_max ELSE @v5apositiontaking_3 END,
	@v5apositiontaking_20 = CASE WHEN @v5apositiontaking_20>@v5mapositiontaking_20_max THEN @v5mapositiontaking_20_max ELSE @v5apositiontaking_20 END,
	@v5apositiontaking_9999 = CASE WHEN @v5apositiontaking_9999>@v5mapositiontaking_9999_max THEN @v5mapositiontaking_9999_max ELSE @v5apositiontaking_9999 END,

	@v8apositiontaking_1 = CASE WHEN @v8apositiontaking_1>@v8mapositiontaking_1_max THEN @v8mapositiontaking_1_max ELSE @v8apositiontaking_1 END,
	@v8apositiontaking_3 = CASE WHEN @v8apositiontaking_3>@v8mapositiontaking_3_max THEN @v8mapositiontaking_3_max ELSE @v8apositiontaking_3 END,
	@v8apositiontaking_20 = CASE WHEN @v8apositiontaking_20>@v8mapositiontaking_20_max THEN @v8mapositiontaking_20_max ELSE @v8apositiontaking_20 END,

	@v10apositiontaking_1 = CASE WHEN @v10apositiontaking_1>@v10mapositiontaking_1_max THEN @v10mapositiontaking_1_max ELSE @v10apositiontaking_1 END,
	@v10apositiontaking_2 = CASE WHEN @v10apositiontaking_2>@v10mapositiontaking_2_max THEN @v10mapositiontaking_2_max ELSE @v10apositiontaking_2 END,
	@v10apositiontaking_3 = CASE WHEN @v10apositiontaking_3>@v10mapositiontaking_3_max THEN @v10mapositiontaking_3_max ELSE @v10apositiontaking_3 END,
	@v10apositiontaking_20 = CASE WHEN @v10apositiontaking_20>@v10mapositiontaking_20_max THEN @v10mapositiontaking_20_max ELSE @v10apositiontaking_20 END,

	@v11apositiontaking_1 = CASE WHEN @v11apositiontaking_1>@v11mapositiontaking_1_max THEN @v11mapositiontaking_1_max ELSE @v11apositiontaking_1 END,
	@v11apositiontaking_20 = CASE WHEN @v11apositiontaking_20>@v11mapositiontaking_20_max THEN @v11mapositiontaking_20_max ELSE @v11apositiontaking_20 END,

	@v99apositiontaking_1 = CASE WHEN @v99apositiontaking_1>@v99mapositiontaking_1_max THEN @v99mapositiontaking_1_max ELSE @v99apositiontaking_1 END,
	@v99apositiontaking_2 = CASE WHEN @v99apositiontaking_2>@v99mapositiontaking_2_max THEN @v99mapositiontaking_2_max ELSE @v99apositiontaking_2 END,
	@v99apositiontaking_3 = CASE WHEN @v99apositiontaking_3>@v99mapositiontaking_3_max THEN @v99mapositiontaking_3_max ELSE @v99apositiontaking_3 END,
	@v99apositiontaking_9 = CASE WHEN @v99apositiontaking_9>@v99mapositiontaking_9_max THEN @v99mapositiontaking_9_max ELSE @v99apositiontaking_9 END,
	@v99apositiontaking_20 = CASE WHEN @v99apositiontaking_20>@v99mapositiontaking_20_max THEN @v99mapositiontaking_20_max ELSE @v99apositiontaking_20 END,
	
	@v154apositiontaking_20 = CASE WHEN @v154apositiontaking_20>@v154mapositiontaking_20_max THEN @v154mapositiontaking_20_max ELSE @v154apositiontaking_20 END,
	
	@v161apositiontaking_81 = CASE WHEN @v161apositiontaking_81>@v161mapositiontaking_81_max THEN @v161mapositiontaking_81_max ELSE @v161apositiontaking_81 END,
	@v161apositiontaking_83 = CASE WHEN @v161apositiontaking_83>@v161mapositiontaking_83_max THEN @v161mapositiontaking_83_max ELSE @v161apositiontaking_83 END,	
	@v161apositiontaking_86 = CASE WHEN @v161apositiontaking_86>@v161mapositiontaking_86_max THEN @v161mapositiontaking_86_max ELSE @v161apositiontaking_86 END,
	@v161apositiontaking_88 = CASE WHEN @v161apositiontaking_88>@v161mapositiontaking_88_max THEN @v161mapositiontaking_88_max ELSE @v161apositiontaking_88 END,
	@v161alivepositiontaking_85 = CASE WHEN @v161alivepositiontaking_85>@v161malivepositiontaking_85_max THEN @v161malivepositiontaking_85_max ELSE @v161alivepositiontaking_85 END,
	@v161alivepositiontaking_86 = CASE WHEN @v161alivepositiontaking_86>@v161malivepositiontaking_86_max THEN @v161malivepositiontaking_86_max ELSE @v161alivepositiontaking_86 END,
	@v161alivepositiontaking_87 = CASE WHEN @v161alivepositiontaking_87>@v161malivepositiontaking_87_max THEN @v161malivepositiontaking_87_max ELSE @v161alivepositiontaking_87 END,
	@v161alivepositiontaking_89 = CASE WHEN @v161alivepositiontaking_89>@v161malivepositiontaking_89_max THEN @v161malivepositiontaking_89_max ELSE @v161alivepositiontaking_89 END,
	@v161alivepositiontaking_90 = CASE WHEN @v161alivepositiontaking_90>@v161malivepositiontaking_90_max THEN @v161malivepositiontaking_90_max ELSE @v161alivepositiontaking_90 END

--a1=if(!im)if(m1+a1>m3,m3-m1)
SELECT 
	@apositiontaking_1 = CASE WHEN @isauto_mpositiontaking_1 > 0 THEN @apositiontaking_1 ELSE CASE WHEN @apositiontaking_1+@mpositiontaking_1>@mapositiontaking_1_max THEN @mapositiontaking_1_max-@mpositiontaking_1 ELSE @apositiontaking_1 END END,
	@apositiontaking_2 = CASE WHEN @isauto_mpositiontaking_2 > 0 THEN @apositiontaking_2 ELSE CASE WHEN @apositiontaking_2+@mpositiontaking_2>@mapositiontaking_2_max THEN @mapositiontaking_2_max-@mpositiontaking_2 ELSE @apositiontaking_2 END END,
	@apositiontaking_3 = CASE WHEN @isauto_mpositiontaking_3 > 0 THEN @apositiontaking_3 ELSE CASE WHEN @apositiontaking_3+@mpositiontaking_3>@mapositiontaking_3_max THEN @mapositiontaking_3_max-@mpositiontaking_3 ELSE @apositiontaking_3 END END,
	@apositiontaking_4 = CASE WHEN @isauto_mpositiontaking_4 > 0 THEN @apositiontaking_4 ELSE CASE WHEN @apositiontaking_4+@mpositiontaking_4>@mapositiontaking_4_max THEN @mapositiontaking_4_max-@mpositiontaking_4 ELSE @apositiontaking_4 END END,
	@apositiontaking_5 = CASE WHEN @isauto_mpositiontaking_5 > 0 THEN @apositiontaking_5 ELSE CASE WHEN @apositiontaking_5+@mpositiontaking_5>@mapositiontaking_5_max THEN @mapositiontaking_5_max-@mpositiontaking_5 ELSE @apositiontaking_5 END END,
	@apositiontaking_6 = CASE WHEN @isauto_mpositiontaking_6 > 0 THEN @apositiontaking_6 ELSE CASE WHEN @apositiontaking_6+@mpositiontaking_6>@mapositiontaking_6_max THEN @mapositiontaking_6_max-@mpositiontaking_6 ELSE @apositiontaking_6 END END,
	@apositiontaking_7 = CASE WHEN @isauto_mpositiontaking_7 > 0 THEN @apositiontaking_7 ELSE CASE WHEN @apositiontaking_7+@mpositiontaking_7>@mapositiontaking_7_max THEN @mapositiontaking_7_max-@mpositiontaking_7 ELSE @apositiontaking_7 END END,
	@apositiontaking_8 = CASE WHEN @isauto_mpositiontaking_8 > 0 THEN @apositiontaking_8 ELSE CASE WHEN @apositiontaking_8+@mpositiontaking_8>@mapositiontaking_8_max THEN @mapositiontaking_8_max-@mpositiontaking_8 ELSE @apositiontaking_8 END END,
	@apositiontaking_9 = CASE WHEN @isauto_mpositiontaking_9 > 0 THEN @apositiontaking_9 ELSE CASE WHEN @apositiontaking_9+@mpositiontaking_9>@mapositiontaking_9_max THEN @mapositiontaking_9_max-@mpositiontaking_9 ELSE @apositiontaking_9 END END,
	@apositiontaking_10 = CASE WHEN @isauto_mpositiontaking_10 > 0 THEN @apositiontaking_10 ELSE CASE WHEN @apositiontaking_10+@mpositiontaking_10>@mapositiontaking_10_max THEN @mapositiontaking_10_max-@mpositiontaking_10 ELSE @apositiontaking_10 END END,
	
	-- Outright PT for sports
	@v2apositiontaking_10 = CASE WHEN @isauto_v2mpositiontaking_10 > 0 THEN @v2apositiontaking_10 ELSE CASE WHEN @v2apositiontaking_10+@v2mpositiontaking_10>@v2mapositiontaking_10_max THEN @v2mapositiontaking_10_max-@v2mpositiontaking_10 ELSE @v2apositiontaking_10 END END,
	@v3apositiontaking_10 = CASE WHEN @isauto_v3mpositiontaking_10 > 0 THEN @v3apositiontaking_10 ELSE CASE WHEN @v3apositiontaking_10+@v3mpositiontaking_10>@v3mapositiontaking_10_max THEN @v3mapositiontaking_10_max-@v3mpositiontaking_10 ELSE @v3apositiontaking_10 END END,
	@v5apositiontaking_10 = CASE WHEN @isauto_v5mpositiontaking_10 > 0 THEN @v5apositiontaking_10 ELSE CASE WHEN @v5apositiontaking_10+@v5mpositiontaking_10>@v5mapositiontaking_10_max THEN @v5mapositiontaking_10_max-@v5mpositiontaking_10 ELSE @v5apositiontaking_10 END END,
	@v8apositiontaking_10 = CASE WHEN @isauto_v8mpositiontaking_10 > 0 THEN @v8apositiontaking_10 ELSE CASE WHEN @v8apositiontaking_10+@v8mpositiontaking_10>@v8mapositiontaking_10_max THEN @v8mapositiontaking_10_max-@v8mpositiontaking_10 ELSE @v8apositiontaking_10 END END,
	@v10apositiontaking_10 = CASE WHEN @isauto_v10mpositiontaking_10 > 0 THEN @v10apositiontaking_10 ELSE CASE WHEN @v10apositiontaking_10+@v10mpositiontaking_10>@v10mapositiontaking_10_max THEN @v10mapositiontaking_10_max-@v10mpositiontaking_10 ELSE @v10apositiontaking_10 END END,
	@v11apositiontaking_10 = CASE WHEN @isauto_v11mpositiontaking_10 > 0 THEN @v11apositiontaking_10 ELSE CASE WHEN @v11apositiontaking_10+@v11mpositiontaking_10>@v11mapositiontaking_10_max THEN @v11mapositiontaking_10_max-@v11mpositiontaking_10 ELSE @v11apositiontaking_10 END END,
	@v99apositiontaking_10 = CASE WHEN @isauto_v99mpositiontaking_10 > 0 THEN @v99apositiontaking_10 ELSE CASE WHEN @v99apositiontaking_10+@v99mpositiontaking_10>@v99mapositiontaking_10_max THEN @v99mapositiontaking_10_max-@v99mpositiontaking_10 ELSE @v99apositiontaking_10 END END,
	
	@apositiontaking_9999 = CASE WHEN @isauto_mpositiontaking_9999 > 0 THEN @apositiontaking_9999 ELSE CASE WHEN @apositiontaking_9999+@mpositiontaking_9999>@mapositiontaking_9999_max THEN @mapositiontaking_9999_max-@mpositiontaking_9999 ELSE @apositiontaking_9999 END END,

	@alivepositiontaking_1 = CASE WHEN @isauto_mlivepositiontaking_1 > 0 THEN @alivepositiontaking_1 ELSE CASE WHEN @alivepositiontaking_1+@mlivepositiontaking_1>@malivepositiontaking_1_max THEN @malivepositiontaking_1_max-@mlivepositiontaking_1 ELSE @alivepositiontaking_1 END END,
	@alivepositiontaking_3 = CASE WHEN @isauto_mlivepositiontaking_3 > 0 THEN @alivepositiontaking_3 ELSE CASE WHEN @alivepositiontaking_3+@mlivepositiontaking_3>@malivepositiontaking_3_max THEN @malivepositiontaking_3_max-@mlivepositiontaking_3 ELSE @alivepositiontaking_3 END END,
	@alivepositiontaking_7 = CASE WHEN @isauto_mlivepositiontaking_7 > 0 THEN @alivepositiontaking_7 ELSE CASE WHEN @alivepositiontaking_7+@mlivepositiontaking_7>@malivepositiontaking_7_max THEN @malivepositiontaking_7_max-@mlivepositiontaking_7 ELSE @alivepositiontaking_7 END END,
	@alivepositiontaking_8 = CASE WHEN @isauto_mlivepositiontaking_8 > 0 THEN @alivepositiontaking_8 ELSE CASE WHEN @alivepositiontaking_8+@mlivepositiontaking_8>@malivepositiontaking_8_max THEN @malivepositiontaking_8_max-@mlivepositiontaking_8 ELSE @alivepositiontaking_8 END END,

	@v2apositiontaking_1 = CASE WHEN @isauto_v2mpositiontaking_1 > 0 THEN @v2apositiontaking_1 ELSE CASE WHEN @v2apositiontaking_1+@v2mpositiontaking_1>@v2mapositiontaking_1_max THEN @v2mapositiontaking_1_max-@v2mpositiontaking_1 ELSE @v2apositiontaking_1 END END,
	@v2apositiontaking_2 = CASE WHEN @isauto_v2mpositiontaking_2 > 0 THEN @v2apositiontaking_2 ELSE CASE WHEN @v2apositiontaking_2+@v2mpositiontaking_2>@v2mapositiontaking_2_max THEN @v2mapositiontaking_2_max-@v2mpositiontaking_2 ELSE @v2apositiontaking_2 END END,
	@v2apositiontaking_3 = CASE WHEN @isauto_v2mpositiontaking_3 > 0 THEN @v2apositiontaking_3 ELSE CASE WHEN @v2apositiontaking_3+@v2mpositiontaking_3>@v2mapositiontaking_3_max THEN @v2mapositiontaking_3_max-@v2mpositiontaking_3 ELSE @v2apositiontaking_3 END END,
	@v2apositiontaking_7 = CASE WHEN @isauto_v2mpositiontaking_7 > 0 THEN @v2apositiontaking_7 ELSE CASE WHEN @v2apositiontaking_7+@v2mpositiontaking_7>@v2mapositiontaking_7_max THEN @v2mapositiontaking_7_max-@v2mpositiontaking_7 ELSE @v2apositiontaking_7 END END,
	@v2apositiontaking_8 = CASE WHEN @isauto_v2mpositiontaking_8 > 0 THEN @v2apositiontaking_8 ELSE CASE WHEN @v2apositiontaking_8+@v2mpositiontaking_8>@v2mapositiontaking_8_max THEN @v2mapositiontaking_8_max-@v2mpositiontaking_8 ELSE @v2apositiontaking_8 END END,
	--@v2apositiontaking_9 = CASE WHEN @isauto_v2mpositiontaking_9 > 0 THEN @v2apositiontaking_9 ELSE CASE WHEN @v2apositiontaking_9+@v2mpositiontaking_9>@v2mapositiontaking_9_max THEN @v2mapositiontaking_9_max-@v2mpositiontaking_9 ELSE @v2apositiontaking_9 END END,
	@v2apositiontaking_20 = CASE WHEN @isauto_v2mpositiontaking_20 > 0 THEN @v2apositiontaking_20 ELSE CASE WHEN @v2apositiontaking_20+@v2mpositiontaking_20>@v2mapositiontaking_20_max THEN @v2mapositiontaking_20_max-@v2mpositiontaking_20 ELSE @v2apositiontaking_20 END END,

	@v3apositiontaking_1 = CASE WHEN @isauto_v3mpositiontaking_1 > 0 THEN @v3apositiontaking_1 ELSE CASE WHEN @v3apositiontaking_1+@v3mpositiontaking_1>@v3mapositiontaking_1_max THEN @v3mapositiontaking_1_max-@v3mpositiontaking_1 ELSE @v3apositiontaking_1 END END,
	@v3apositiontaking_2 = CASE WHEN @isauto_v3mpositiontaking_2 > 0 THEN @v3apositiontaking_2 ELSE CASE WHEN @v3apositiontaking_2+@v3mpositiontaking_2>@v3mapositiontaking_2_max THEN @v3mapositiontaking_2_max-@v3mpositiontaking_2 ELSE @v3apositiontaking_2 END END,
	@v3apositiontaking_3 = CASE WHEN @isauto_v3mpositiontaking_3 > 0 THEN @v3apositiontaking_3 ELSE CASE WHEN @v3apositiontaking_3+@v3mpositiontaking_3>@v3mapositiontaking_3_max THEN @v3mapositiontaking_3_max-@v3mpositiontaking_3 ELSE @v3apositiontaking_3 END END,
	@v3apositiontaking_20 = CASE WHEN @isauto_v3mpositiontaking_20 > 0 THEN @v3apositiontaking_20 ELSE CASE WHEN @v3apositiontaking_20+@v3mpositiontaking_20>@v3mapositiontaking_20_max THEN @v3mapositiontaking_20_max-@v3mpositiontaking_20 ELSE @v3apositiontaking_20 END END,

	@v5apositiontaking_1 = CASE WHEN @isauto_v5mpositiontaking_1 > 0 THEN @v5apositiontaking_1 ELSE CASE WHEN @v5apositiontaking_1+@v5mpositiontaking_1>@v5mapositiontaking_1_max THEN @v5mapositiontaking_1_max-@v5mpositiontaking_1 ELSE @v5apositiontaking_1 END END,
	@v5apositiontaking_2 = CASE WHEN @isauto_v5mpositiontaking_2 > 0 THEN @v5apositiontaking_2 ELSE CASE WHEN @v5apositiontaking_2+@v5mpositiontaking_2>@v5mapositiontaking_2_max THEN @v5mapositiontaking_2_max-@v5mpositiontaking_2 ELSE @v5apositiontaking_2 END END,
	@v5apositiontaking_3 = CASE WHEN @isauto_v5mpositiontaking_3 > 0 THEN @v5apositiontaking_3 ELSE CASE WHEN @v5apositiontaking_3+@v5mpositiontaking_3>@v5mapositiontaking_3_max THEN @v5mapositiontaking_3_max-@v5mpositiontaking_3 ELSE @v5apositiontaking_3 END END,
	@v5apositiontaking_20 = CASE WHEN @isauto_v5mpositiontaking_20 > 0 THEN @v5apositiontaking_20 ELSE CASE WHEN @v5apositiontaking_20+@v5mpositiontaking_20>@v5mapositiontaking_20_max THEN @v5mapositiontaking_20_max-@v5mpositiontaking_20 ELSE @v5apositiontaking_20 END END,
	@v5apositiontaking_9999 = CASE WHEN @isauto_v5mpositiontaking_9999 > 0 THEN @v5apositiontaking_9999 ELSE CASE WHEN @v5apositiontaking_9999+@v5mpositiontaking_9999>@v5mapositiontaking_9999_max THEN @v5mapositiontaking_9999_max-@v5mpositiontaking_9999 ELSE @v5apositiontaking_9999 END END,

	@v8apositiontaking_1 = CASE WHEN @isauto_v8mpositiontaking_1 > 0 THEN @v8apositiontaking_1 ELSE CASE WHEN @v8apositiontaking_1+@v8mpositiontaking_1>@v8mapositiontaking_1_max THEN @v8mapositiontaking_1_max-@v8mpositiontaking_1 ELSE @v8apositiontaking_1 END END,
	@v8apositiontaking_3 = CASE WHEN @isauto_v8mpositiontaking_3 > 0 THEN @v8apositiontaking_3 ELSE CASE WHEN @v8apositiontaking_3+@v8mpositiontaking_3>@v8mapositiontaking_3_max THEN @v8mapositiontaking_3_max-@v8mpositiontaking_3 ELSE @v8apositiontaking_3 END END,
	@v8apositiontaking_20 = CASE WHEN @isauto_v8mpositiontaking_20 > 0 THEN @v8apositiontaking_20 ELSE CASE WHEN @v8apositiontaking_20+@v8mpositiontaking_20>@v8mapositiontaking_20_max THEN @v8mapositiontaking_20_max-@v8mpositiontaking_20 ELSE @v8apositiontaking_20 END END,

	@v10apositiontaking_1 = CASE WHEN @isauto_v10mpositiontaking_1 > 0 THEN @v10apositiontaking_1 ELSE CASE WHEN @v10apositiontaking_1+@v10mpositiontaking_1>@v10mapositiontaking_1_max THEN @v10mapositiontaking_1_max-@v10mpositiontaking_1 ELSE @v10apositiontaking_1 END END,
	@v10apositiontaking_2 = CASE WHEN @isauto_v10mpositiontaking_2 > 0 THEN @v10apositiontaking_2 ELSE CASE WHEN @v10apositiontaking_2+@v10mpositiontaking_2>@v10mapositiontaking_2_max THEN @v10mapositiontaking_2_max-@v10mpositiontaking_2 ELSE @v10apositiontaking_2 END END,
	@v10apositiontaking_3 = CASE WHEN @isauto_v10mpositiontaking_3 > 0 THEN @v10apositiontaking_3 ELSE CASE WHEN @v10apositiontaking_3+@v10mpositiontaking_3>@v10mapositiontaking_3_max THEN @v10mapositiontaking_3_max-@v10mpositiontaking_3 ELSE @v10apositiontaking_3 END END,
	@v10apositiontaking_20 = CASE WHEN @isauto_v10mpositiontaking_20 > 0 THEN @v10apositiontaking_20 ELSE CASE WHEN @v10apositiontaking_20+@v10mpositiontaking_20>@v10mapositiontaking_20_max THEN @v10mapositiontaking_20_max-@v10mpositiontaking_20 ELSE @v10apositiontaking_20 END END,

	@v11apositiontaking_1 = CASE WHEN @isauto_v11mpositiontaking_1 > 0 THEN @v11apositiontaking_1 ELSE CASE WHEN @v11apositiontaking_1+@v11mpositiontaking_1>@v11mapositiontaking_1_max THEN @v11mapositiontaking_1_max-@v11mpositiontaking_1 ELSE @v11apositiontaking_1 END END,
	@v11apositiontaking_20 = CASE WHEN @isauto_v11mpositiontaking_20 > 0 THEN @v11apositiontaking_20 ELSE CASE WHEN @v11apositiontaking_20+@v11mpositiontaking_20>@v11mapositiontaking_20_max THEN @v11mapositiontaking_20_max-@v11mpositiontaking_20 ELSE @v11apositiontaking_20 END END,

	@v99apositiontaking_1 = CASE WHEN @isauto_v99mpositiontaking_1 > 0 THEN @v99apositiontaking_1 ELSE CASE WHEN @v99apositiontaking_1+@v99mpositiontaking_1>@v99mapositiontaking_1_max THEN @v99mapositiontaking_1_max-@v99mpositiontaking_1 ELSE @v99apositiontaking_1 END END,
	@v99apositiontaking_2 = CASE WHEN @isauto_v99mpositiontaking_2 > 0 THEN @v99apositiontaking_2 ELSE CASE WHEN @v99apositiontaking_2+@v99mpositiontaking_2>@v99mapositiontaking_2_max THEN @v99mapositiontaking_2_max-@v99mpositiontaking_2 ELSE @v99apositiontaking_2 END END,
	@v99apositiontaking_3 = CASE WHEN @isauto_v99mpositiontaking_3 > 0 THEN @v99apositiontaking_3 ELSE CASE WHEN @v99apositiontaking_3+@v99mpositiontaking_3>@v99mapositiontaking_3_max THEN @v99mapositiontaking_3_max-@v99mpositiontaking_3 ELSE @v99apositiontaking_3 END END,
	@v99apositiontaking_9 = CASE WHEN @isauto_v99mpositiontaking_9 > 0 THEN @v99apositiontaking_9 ELSE CASE WHEN @v99apositiontaking_9+@v99mpositiontaking_9>@v99mapositiontaking_9_max THEN @v99mapositiontaking_9_max-@v99mpositiontaking_9 ELSE @v99apositiontaking_9 END END,
	@v99apositiontaking_20 = CASE WHEN @isauto_v99mpositiontaking_20 > 0 THEN @v99apositiontaking_20 ELSE CASE WHEN @v99apositiontaking_20+@v99mpositiontaking_20>@v99mapositiontaking_20_max THEN @v99mapositiontaking_20_max-@v99mpositiontaking_20 ELSE @v99apositiontaking_20 END END,
	
	@v154apositiontaking_20 = CASE WHEN @isauto_v154mpositiontaking_20 > 0 THEN @v154apositiontaking_20 ELSE CASE WHEN @v154apositiontaking_20+@v154mpositiontaking_20>@v154mapositiontaking_20_max THEN @v154mapositiontaking_20_max-@v154mpositiontaking_20 ELSE @v154apositiontaking_20 END END,
	
	--v161
	@v161apositiontaking_81 = CASE WHEN @isauto_v161mpositiontaking_81 > 0 THEN @v161apositiontaking_81 ELSE CASE WHEN @v161apositiontaking_81+@v161mpositiontaking_81>@v161mapositiontaking_81_max THEN @v161mapositiontaking_81_max-@v161mpositiontaking_81 ELSE @v161apositiontaking_81 END END,
	@v161apositiontaking_83 = CASE WHEN @isauto_v161mpositiontaking_83 > 0 THEN @v161apositiontaking_83 ELSE CASE WHEN @v161apositiontaking_83+@v161mpositiontaking_83>@v161mapositiontaking_83_max THEN @v161mapositiontaking_83_max-@v161mpositiontaking_83 ELSE @v161apositiontaking_83 END END,	
	@v161apositiontaking_86 = CASE WHEN @isauto_v161mpositiontaking_86 > 0 THEN @v161apositiontaking_86 ELSE CASE WHEN @v161apositiontaking_86+@v161mpositiontaking_86>@v161mapositiontaking_86_max THEN @v161mapositiontaking_86_max-@v161mpositiontaking_86 ELSE @v161apositiontaking_86 END END,
	@v161apositiontaking_88 = CASE WHEN @isauto_v161mpositiontaking_88 > 0 THEN @v161apositiontaking_88 ELSE CASE WHEN @v161apositiontaking_88+@v161mpositiontaking_88>@v161mapositiontaking_88_max THEN @v161mapositiontaking_88_max-@v161mpositiontaking_88 ELSE @v161apositiontaking_88 END END,
	
	@v161alivepositiontaking_85 = CASE WHEN @isauto_v161mlivepositiontaking_85 > 0 THEN @v161alivepositiontaking_85 ELSE CASE WHEN @v161alivepositiontaking_85+@v161mlivepositiontaking_85>@v161malivepositiontaking_85_max THEN @v161malivepositiontaking_85_max-@v161mlivepositiontaking_85 ELSE @v161alivepositiontaking_85 END END,
	@v161alivepositiontaking_86 = CASE WHEN @isauto_v161mlivepositiontaking_86 > 0 THEN @v161alivepositiontaking_86 ELSE CASE WHEN @v161alivepositiontaking_86+@v161mlivepositiontaking_86>@v161malivepositiontaking_86_max THEN @v161malivepositiontaking_86_max-@v161mlivepositiontaking_86 ELSE @v161alivepositiontaking_86 END END,
	@v161alivepositiontaking_87 = CASE WHEN @isauto_v161mlivepositiontaking_87 > 0 THEN @v161alivepositiontaking_87 ELSE CASE WHEN @v161alivepositiontaking_87+@v161mlivepositiontaking_87>@v161malivepositiontaking_87_max THEN @v161malivepositiontaking_87_max-@v161mlivepositiontaking_87 ELSE @v161alivepositiontaking_87 END END,
	@v161alivepositiontaking_89 = CASE WHEN @isauto_v161mlivepositiontaking_89 > 0 THEN @v161alivepositiontaking_89 ELSE CASE WHEN @v161alivepositiontaking_89+@v161mlivepositiontaking_89>@v161malivepositiontaking_89_max THEN @v161malivepositiontaking_89_max-@v161mlivepositiontaking_89 ELSE @v161alivepositiontaking_89 END END,
	@v161alivepositiontaking_90 = CASE WHEN @isauto_v161mlivepositiontaking_90 > 0 THEN @v161alivepositiontaking_90 ELSE CASE WHEN @v161alivepositiontaking_90+@v161mlivepositiontaking_90>@v161malivepositiontaking_90_max THEN @v161malivepositiontaking_90_max-@v161mlivepositiontaking_90 ELSE @v161alivepositiontaking_90 END END

SELECT 
	@apositiontaking_1 = CASE WHEN @apositiontaking_1<0 THEN 0 ELSE @apositiontaking_1 END,
	@apositiontaking_2 = CASE WHEN @apositiontaking_2<0 THEN 0 ELSE @apositiontaking_2 END,
	@apositiontaking_3 = CASE WHEN @apositiontaking_3<0 THEN 0 ELSE @apositiontaking_3 END,
	@apositiontaking_4 = CASE WHEN @apositiontaking_4<0 THEN 0 ELSE @apositiontaking_4 END,
	@apositiontaking_5 = CASE WHEN @apositiontaking_5<0 THEN 0 ELSE @apositiontaking_5 END,
	@apositiontaking_6 = CASE WHEN @apositiontaking_6<0 THEN 0 ELSE @apositiontaking_6 END,
	@apositiontaking_7 = CASE WHEN @apositiontaking_7<0 THEN 0 ELSE @apositiontaking_7 END,
	@apositiontaking_8 = CASE WHEN @apositiontaking_8<0 THEN 0 ELSE @apositiontaking_8 END,
	@apositiontaking_9 = CASE WHEN @apositiontaking_9<0 THEN 0 ELSE @apositiontaking_9 END,
	@apositiontaking_10 = CASE WHEN @apositiontaking_10<0 THEN 0 ELSE @apositiontaking_10 END,
	
	-- Outright PT for sports
	@v2apositiontaking_10 = CASE WHEN @v2apositiontaking_10<0 THEN 0 ELSE @v2apositiontaking_10 END,
	@v3apositiontaking_10 = CASE WHEN @v3apositiontaking_10<0 THEN 0 ELSE @v3apositiontaking_10 END,
	@v5apositiontaking_10 = CASE WHEN @v5apositiontaking_10<0 THEN 0 ELSE @v5apositiontaking_10 END,
	@v8apositiontaking_10 = CASE WHEN @v8apositiontaking_10<0 THEN 0 ELSE @v8apositiontaking_10 END,
	@v10apositiontaking_10 = CASE WHEN @v10apositiontaking_10<0 THEN 0 ELSE @v10apositiontaking_10 END,
	@v11apositiontaking_10 = CASE WHEN @v11apositiontaking_10<0 THEN 0 ELSE @v11apositiontaking_10 END,
	@v99apositiontaking_10 = CASE WHEN @v99apositiontaking_10<0 THEN 0 ELSE @v99apositiontaking_10 END,
	
	@apositiontaking_9999 = CASE WHEN @apositiontaking_9999<0 THEN 0 ELSE @apositiontaking_9999 END,

	@alivepositiontaking_1 = CASE WHEN @alivepositiontaking_1<0 THEN 0 ELSE @alivepositiontaking_1 END,
	@alivepositiontaking_3 = CASE WHEN @alivepositiontaking_3<0 THEN 0 ELSE @alivepositiontaking_3 END,
	@alivepositiontaking_7 = CASE WHEN @alivepositiontaking_7<0 THEN 0 ELSE @alivepositiontaking_7 END,
	@alivepositiontaking_8 = CASE WHEN @alivepositiontaking_8<0 THEN 0 ELSE @alivepositiontaking_8 END,

	@v2apositiontaking_1 = CASE WHEN @v2apositiontaking_1<0 THEN 0 ELSE @v2apositiontaking_1 END,
	@v2apositiontaking_2 = CASE WHEN @v2apositiontaking_2<0 THEN 0 ELSE @v2apositiontaking_2 END,
	@v2apositiontaking_3 = CASE WHEN @v2apositiontaking_3<0 THEN 0 ELSE @v2apositiontaking_3 END,
	@v2apositiontaking_7 = CASE WHEN @v2apositiontaking_7<0 THEN 0 ELSE @v2apositiontaking_7 END,
	@v2apositiontaking_8 = CASE WHEN @v2apositiontaking_8<0 THEN 0 ELSE @v2apositiontaking_8 END,
	--@v2apositiontaking_9 = CASE WHEN @v2apositiontaking_9<0 THEN 0 ELSE @v2apositiontaking_9 END,
	@v2apositiontaking_20 = CASE WHEN @v2apositiontaking_20<0 THEN 0 ELSE @v2apositiontaking_20 END,

	@v3apositiontaking_1 = CASE WHEN @v3apositiontaking_1<0 THEN 0 ELSE @v3apositiontaking_1 END,
	@v3apositiontaking_2 = CASE WHEN @v3apositiontaking_2<0 THEN 0 ELSE @v3apositiontaking_2 END,
	@v3apositiontaking_3 = CASE WHEN @v3apositiontaking_3<0 THEN 0 ELSE @v3apositiontaking_3 END,
	@v3apositiontaking_20 = CASE WHEN @v3apositiontaking_20<0 THEN 0 ELSE @v3apositiontaking_20 END,

	@v5apositiontaking_1 = CASE WHEN @v5apositiontaking_1<0 THEN 0 ELSE @v5apositiontaking_1 END,
	@v5apositiontaking_2 = CASE WHEN @v5apositiontaking_2<0 THEN 0 ELSE @v5apositiontaking_2 END,
	@v5apositiontaking_3 = CASE WHEN @v5apositiontaking_3<0 THEN 0 ELSE @v5apositiontaking_3 END,
	@v5apositiontaking_20 = CASE WHEN @v5apositiontaking_20<0 THEN 0 ELSE @v5apositiontaking_20 END,
	@v5apositiontaking_9999 = CASE WHEN @v5apositiontaking_9999<0 THEN 0 ELSE @v5apositiontaking_9999 END,

	@v8apositiontaking_1 = CASE WHEN @v8apositiontaking_1<0 THEN 0 ELSE @v8apositiontaking_1 END,
	@v8apositiontaking_3 = CASE WHEN @v8apositiontaking_3<0 THEN 0 ELSE @v8apositiontaking_3 END,
	@v8apositiontaking_20 = CASE WHEN @v8apositiontaking_20<0 THEN 0 ELSE @v8apositiontaking_20 END,

	@v10apositiontaking_1 = CASE WHEN @v10apositiontaking_1<0 THEN 0 ELSE @v10apositiontaking_1 END,
	@v10apositiontaking_2 = CASE WHEN @v10apositiontaking_2<0 THEN 0 ELSE @v10apositiontaking_2 END,
	@v10apositiontaking_3 = CASE WHEN @v10apositiontaking_3<0 THEN 0 ELSE @v10apositiontaking_3 END,
	@v10apositiontaking_20 = CASE WHEN @v10apositiontaking_20<0 THEN 0 ELSE @v10apositiontaking_20 END,

	@v11apositiontaking_1 = CASE WHEN @v11apositiontaking_1<0 THEN 0 ELSE @v11apositiontaking_1 END,
	@v11apositiontaking_20 = CASE WHEN @v11apositiontaking_20<0 THEN 0 ELSE @v11apositiontaking_20 END,

	@v99apositiontaking_1 = CASE WHEN @v99apositiontaking_1<0 THEN 0 ELSE @v99apositiontaking_1 END,
	@v99apositiontaking_2 = CASE WHEN @v99apositiontaking_2<0 THEN 0 ELSE @v99apositiontaking_2 END,
	@v99apositiontaking_3 = CASE WHEN @v99apositiontaking_3<0 THEN 0 ELSE @v99apositiontaking_3 END,
	@v99apositiontaking_9 = CASE WHEN @v99apositiontaking_9<0 THEN 0 ELSE @v99apositiontaking_9 END,
	@v99apositiontaking_20 = CASE WHEN @v99apositiontaking_20<0 THEN 0 ELSE @v99apositiontaking_20 END,
	
	@v154apositiontaking_20 = CASE WHEN @v154apositiontaking_20<0 THEN 0 ELSE @v154apositiontaking_20 END,
	
	--v161
	@v161apositiontaking_81 = CASE WHEN @v161apositiontaking_81<0 THEN 0 ELSE @v161apositiontaking_81 END,
	@v161apositiontaking_83 = CASE WHEN @v161apositiontaking_83<0 THEN 0 ELSE @v161apositiontaking_83 END,	
	@v161apositiontaking_86 = CASE WHEN @v161apositiontaking_86<0 THEN 0 ELSE @v161apositiontaking_86 END,
	@v161apositiontaking_88 = CASE WHEN @v161apositiontaking_88<0 THEN 0 ELSE @v161apositiontaking_88 END,
	
	@v161alivepositiontaking_85 = CASE WHEN @v161alivepositiontaking_85<0 THEN 0 ELSE @v161alivepositiontaking_85 END,
	@v161alivepositiontaking_86 = CASE WHEN @v161alivepositiontaking_86<0 THEN 0 ELSE @v161alivepositiontaking_86 END,
	@v161alivepositiontaking_87 = CASE WHEN @v161alivepositiontaking_87<0 THEN 0 ELSE @v161alivepositiontaking_87 END,
	@v161alivepositiontaking_89 = CASE WHEN @v161alivepositiontaking_89<0 THEN 0 ELSE @v161alivepositiontaking_89 END,
	@v161alivepositiontaking_90 = CASE WHEN @v161alivepositiontaking_90<0 THEN 0 ELSE @v161alivepositiontaking_90 END


---------------------------------------------------------------------------------------------------------------------------------------------
----------------***Use Master Auto Position Taking***----------------------------------
--use @auto_mpt at agent
--@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
--if u2 = 0 then m1 = m2
--else	if u2 < m3 - a1 then m1 = u2
--		else m1 = m3 - a1

select @mpositiontaking_1 = case when isnull(@isauto_mpositiontaking_1, 0)=0 then @mpositiontaking_1 else case when @auto_mpositiontaking_1 < @mapositiontaking_1_max - @apositiontaking_1 then @auto_mpositiontaking_1 else @mapositiontaking_1_max - @apositiontaking_1 end end
select @mpositiontaking_3 = case when isnull(@isauto_mpositiontaking_3, 0)=0 then @mpositiontaking_3 else case when @auto_mpositiontaking_3 < @mapositiontaking_3_max - @apositiontaking_3 then @auto_mpositiontaking_3 else @mapositiontaking_3_max - @apositiontaking_3 end end
select @mpositiontaking_7 = case when isnull(@isauto_mpositiontaking_7, 0)=0 then @mpositiontaking_7 else case when @auto_mpositiontaking_7 < @mapositiontaking_7_max - @apositiontaking_7 then @auto_mpositiontaking_7 else @mapositiontaking_7_max - @apositiontaking_7 end end
select @mpositiontaking_8 = case when isnull(@isauto_mpositiontaking_8, 0)=0 then @mpositiontaking_8 else case when @auto_mpositiontaking_8 < @mapositiontaking_8_max - @apositiontaking_8 then @auto_mpositiontaking_8 else @mapositiontaking_8_max - @apositiontaking_8 end end

select @mlivepositiontaking_1 = case when isnull(@isauto_mlivepositiontaking_1, 0)=0 then @mlivepositiontaking_1 else case when @auto_mlivepositiontaking_1 < @malivepositiontaking_1_max - @alivepositiontaking_1 then @auto_mlivepositiontaking_1 else @malivepositiontaking_1_max - @alivepositiontaking_1 end end
select @mlivepositiontaking_3 = case when isnull(@isauto_mlivepositiontaking_3, 0)=0 then @mlivepositiontaking_3 else case when @auto_mlivepositiontaking_3 < @malivepositiontaking_3_max - @alivepositiontaking_3 then @auto_mlivepositiontaking_3 else @malivepositiontaking_3_max - @alivepositiontaking_3 end end
select @mlivepositiontaking_7 = case when isnull(@isauto_mlivepositiontaking_7, 0)=0 then @mlivepositiontaking_7 else case when @auto_mlivepositiontaking_7 < @malivepositiontaking_7_max - @alivepositiontaking_7 then @auto_mlivepositiontaking_7 else @malivepositiontaking_7_max - @alivepositiontaking_7 end end
select @mlivepositiontaking_8 = case when isnull(@isauto_mlivepositiontaking_8, 0)=0 then @mlivepositiontaking_8 else case when @auto_mlivepositiontaking_8 < @malivepositiontaking_8_max - @alivepositiontaking_8 then @auto_mlivepositiontaking_8 else @malivepositiontaking_8_max - @alivepositiontaking_8 end end

select @mpositiontaking_2 = case when isnull(@isauto_mpositiontaking_2, 0)=0 then @mpositiontaking_2 else case when @auto_mpositiontaking_2 < @mapositiontaking_2_max - @apositiontaking_2 then @auto_mpositiontaking_2 else @mapositiontaking_2_max - @apositiontaking_2 end end
select @mpositiontaking_4 = case when isnull(@isauto_mpositiontaking_4, 0)=0 then @mpositiontaking_4 else case when @auto_mpositiontaking_4 < @mapositiontaking_4_max - @apositiontaking_4 then @auto_mpositiontaking_4 else @mapositiontaking_4_max - @apositiontaking_4 end end
select @mpositiontaking_5 = case when isnull(@isauto_mpositiontaking_5, 0)=0 then @mpositiontaking_5 else case when @auto_mpositiontaking_5 < @mapositiontaking_5_max - @apositiontaking_5 then @auto_mpositiontaking_5 else @mapositiontaking_5_max - @apositiontaking_5 end end
select @mpositiontaking_6 = case when isnull(@isauto_mpositiontaking_6, 0)=0 then @mpositiontaking_6 else case when @auto_mpositiontaking_6 < @mapositiontaking_6_max - @apositiontaking_6 then @auto_mpositiontaking_6 else @mapositiontaking_6_max - @apositiontaking_6 end end
select @mpositiontaking_9 = case when isnull(@isauto_mpositiontaking_9, 0)=0 then @mpositiontaking_9 else case when @auto_mpositiontaking_9 < @mapositiontaking_9_max - @apositiontaking_9 then @auto_mpositiontaking_9 else @mapositiontaking_9_max - @apositiontaking_9 end end
select @mpositiontaking_10 = case when isnull(@isauto_mpositiontaking_10, 0)=0 then @mpositiontaking_10 else case when @auto_mpositiontaking_10 < @mapositiontaking_10_max - @apositiontaking_10 then @auto_mpositiontaking_10 else @mapositiontaking_10_max - @apositiontaking_10 end end

-- Outright PT for sports
select @v2mpositiontaking_10 = case when isnull(@isauto_v2mpositiontaking_10, 0)=0 then @v2mpositiontaking_10 else case when @auto_v2mpositiontaking_10 < @v2mapositiontaking_10_max - @v2apositiontaking_10 then @auto_v2mpositiontaking_10 else @v2mapositiontaking_10_max - @v2apositiontaking_10 end end
select @v3mpositiontaking_10 = case when isnull(@isauto_v3mpositiontaking_10, 0)=0 then @v3mpositiontaking_10 else case when @auto_v3mpositiontaking_10 < @v3mapositiontaking_10_max - @v3apositiontaking_10 then @auto_v3mpositiontaking_10 else @v3mapositiontaking_10_max - @v3apositiontaking_10 end end
select @v5mpositiontaking_10 = case when isnull(@isauto_v5mpositiontaking_10, 0)=0 then @v5mpositiontaking_10 else case when @auto_v5mpositiontaking_10 < @v5mapositiontaking_10_max - @v5apositiontaking_10 then @auto_v5mpositiontaking_10 else @v5mapositiontaking_10_max - @v5apositiontaking_10 end end
select @v8mpositiontaking_10 = case when isnull(@isauto_v8mpositiontaking_10, 0)=0 then @v8mpositiontaking_10 else case when @auto_v8mpositiontaking_10 < @v8mapositiontaking_10_max - @v8apositiontaking_10 then @auto_v8mpositiontaking_10 else @v8mapositiontaking_10_max - @v8apositiontaking_10 end end
select @v10mpositiontaking_10 = case when isnull(@isauto_v10mpositiontaking_10, 0)=0 then @v10mpositiontaking_10 else case when @auto_v10mpositiontaking_10 < @v10mapositiontaking_10_max - @v10apositiontaking_10 then @auto_v10mpositiontaking_10 else @v10mapositiontaking_10_max - @v10apositiontaking_10 end end
select @v11mpositiontaking_10 = case when isnull(@isauto_v11mpositiontaking_10, 0)=0 then @v11mpositiontaking_10 else case when @auto_v11mpositiontaking_10 < @v11mapositiontaking_10_max - @v11apositiontaking_10 then @auto_v11mpositiontaking_10 else @v11mapositiontaking_10_max - @v11apositiontaking_10 end end
select @v99mpositiontaking_10 = case when isnull(@isauto_v99mpositiontaking_10, 0)=0 then @v99mpositiontaking_10 else case when @auto_v99mpositiontaking_10 < @v99mapositiontaking_10_max - @v99apositiontaking_10 then @auto_v99mpositiontaking_10 else @v99mapositiontaking_10_max - @v99apositiontaking_10 end end

select @mpositiontaking_9999 = case when isnull(@isauto_mpositiontaking_9999, 0)=0 then @mpositiontaking_9999 else case when @auto_mpositiontaking_9999 < @mapositiontaking_9999_max - @apositiontaking_9999 then @auto_mpositiontaking_9999 else @mapositiontaking_9999_max - @apositiontaking_9999 end end

select @v2mpositiontaking_1 = case when isnull(@isauto_v2mpositiontaking_1, 0)=0 then @v2mpositiontaking_1 else case when @auto_v2mpositiontaking_1 < @v2mapositiontaking_1_max - @v2apositiontaking_1 then @auto_v2mpositiontaking_1 else @v2mapositiontaking_1_max - @v2apositiontaking_1 end end
select @v2mpositiontaking_2 = case when isnull(@isauto_v2mpositiontaking_2, 0)=0 then @v2mpositiontaking_2 else case when @auto_v2mpositiontaking_2 < @v2mapositiontaking_2_max - @v2apositiontaking_2 then @auto_v2mpositiontaking_2 else @v2mapositiontaking_2_max - @v2apositiontaking_2 end end
select @v2mpositiontaking_3 = case when isnull(@isauto_v2mpositiontaking_3, 0)=0 then @v2mpositiontaking_3 else case when @auto_v2mpositiontaking_3 < @v2mapositiontaking_3_max - @v2apositiontaking_3 then @auto_v2mpositiontaking_3 else @v2mapositiontaking_3_max - @v2apositiontaking_3 end end
select @v2mpositiontaking_7 = case when isnull(@isauto_v2mpositiontaking_7, 0)=0 then @v2mpositiontaking_7 else case when @auto_v2mpositiontaking_7 < @v2mapositiontaking_7_max - @v2apositiontaking_7 then @auto_v2mpositiontaking_7 else @v2mapositiontaking_7_max - @v2apositiontaking_7 end end
select @v2mpositiontaking_8 = case when isnull(@isauto_v2mpositiontaking_8, 0)=0 then @v2mpositiontaking_8 else case when @auto_v2mpositiontaking_8 < @v2mapositiontaking_8_max - @v2apositiontaking_8 then @auto_v2mpositiontaking_8 else @v2mapositiontaking_8_max - @v2apositiontaking_8 end end
--select @v2mpositiontaking_9 = case when isnull(@isauto_v2mpositiontaking_9, 0)=0 then @v2mpositiontaking_9 else case when @auto_v2mpositiontaking_9 < @v2mapositiontaking_9_max - @v2apositiontaking_9 then @auto_v2mpositiontaking_9 else @v2mapositiontaking_9_max - @v2apositiontaking_9 end end
select @v2mpositiontaking_20 = case when isnull(@isauto_v2mpositiontaking_20, 0)=0 then @v2mpositiontaking_20 else case when @auto_v2mpositiontaking_20 < @v2mapositiontaking_20_max - @v2apositiontaking_20 then @auto_v2mpositiontaking_20 else @v2mapositiontaking_20_max - @v2apositiontaking_20 end end

select @v3mpositiontaking_1 = case when isnull(@isauto_v3mpositiontaking_1, 0)=0 then @v3mpositiontaking_1 else case when @auto_v3mpositiontaking_1 < @v3mapositiontaking_1_max - @v3apositiontaking_1 then @auto_v3mpositiontaking_1 else @v3mapositiontaking_1_max - @v3apositiontaking_1 end end
select @v3mpositiontaking_2 = case when isnull(@isauto_v3mpositiontaking_2, 0)=0 then @v3mpositiontaking_2 else case when @auto_v3mpositiontaking_2 < @v3mapositiontaking_2_max - @v3apositiontaking_2 then @auto_v3mpositiontaking_2 else @v3mapositiontaking_2_max - @v3apositiontaking_2 end end
select @v3mpositiontaking_3 = case when isnull(@isauto_v3mpositiontaking_3, 0)=0 then @v3mpositiontaking_3 else case when @auto_v3mpositiontaking_3 < @v3mapositiontaking_3_max - @v3apositiontaking_3 then @auto_v3mpositiontaking_3 else @v3mapositiontaking_3_max - @v3apositiontaking_3 end end
select @v3mpositiontaking_20 = case when isnull(@isauto_v3mpositiontaking_20, 0)=0 then @v3mpositiontaking_20 else case when @auto_v3mpositiontaking_20 < @v3mapositiontaking_20_max - @v3apositiontaking_20 then @auto_v3mpositiontaking_20 else @v3mapositiontaking_20_max - @v3apositiontaking_20 end end

select @v5mpositiontaking_1 = case when isnull(@isauto_v5mpositiontaking_1, 0)=0 then @v5mpositiontaking_1 else case when @auto_v5mpositiontaking_1 < @v5mapositiontaking_1_max - @v5apositiontaking_1 then @auto_v5mpositiontaking_1 else @v5mapositiontaking_1_max - @v5apositiontaking_1 end end
select @v5mpositiontaking_2 = case when isnull(@isauto_v5mpositiontaking_2, 0)=0 then @v5mpositiontaking_2 else case when @auto_v5mpositiontaking_2 < @v5mapositiontaking_2_max - @v5apositiontaking_2 then @auto_v5mpositiontaking_2 else @v5mapositiontaking_2_max - @v5apositiontaking_2 end end
select @v5mpositiontaking_3 = case when isnull(@isauto_v5mpositiontaking_3, 0)=0 then @v5mpositiontaking_3 else case when @auto_v5mpositiontaking_3 < @v5mapositiontaking_3_max - @v5apositiontaking_3 then @auto_v5mpositiontaking_3 else @v5mapositiontaking_3_max - @v5apositiontaking_3 end end
select @v5mpositiontaking_20 = case when isnull(@isauto_v5mpositiontaking_20, 0)=0 then @v5mpositiontaking_20 else case when @auto_v5mpositiontaking_20 < @v5mapositiontaking_20_max - @v5apositiontaking_20 then @auto_v5mpositiontaking_20 else @v5mapositiontaking_20_max - @v5apositiontaking_20 end end
select @v5mpositiontaking_9999 = case when isnull(@isauto_v5mpositiontaking_9999, 0)=0 then @v5mpositiontaking_9999 else case when @auto_v5mpositiontaking_9999 < @v5mapositiontaking_9999_max - @v5apositiontaking_9999 then @auto_v5mpositiontaking_9999 else @v5mapositiontaking_9999_max - @v5apositiontaking_9999 end end

select @v8mpositiontaking_1 = case when isnull(@isauto_v8mpositiontaking_1, 0)=0 then @v8mpositiontaking_1 else case when @auto_v8mpositiontaking_1 < @v8mapositiontaking_1_max - @v8apositiontaking_1 then @auto_v8mpositiontaking_1 else @v8mapositiontaking_1_max - @v8apositiontaking_1 end end
select @v8mpositiontaking_3 = case when isnull(@isauto_v8mpositiontaking_3, 0)=0 then @v8mpositiontaking_3 else case when @auto_v8mpositiontaking_3 < @v8mapositiontaking_3_max - @v8apositiontaking_3 then @auto_v8mpositiontaking_3 else @v8mapositiontaking_3_max - @v8apositiontaking_3 end end
select @v8mpositiontaking_20 = case when isnull(@isauto_v8mpositiontaking_20, 0)=0 then @v8mpositiontaking_20 else case when @auto_v8mpositiontaking_20 < @v8mapositiontaking_20_max - @v8apositiontaking_20 then @auto_v8mpositiontaking_20 else @v8mapositiontaking_20_max - @v8apositiontaking_20 end end

select @v10mpositiontaking_1 = case when isnull(@isauto_v10mpositiontaking_1, 0)=0 then @v10mpositiontaking_1 else case when @auto_v10mpositiontaking_1 < @v10mapositiontaking_1_max - @v10apositiontaking_1 then @auto_v10mpositiontaking_1 else @v10mapositiontaking_1_max - @v10apositiontaking_1 end end
select @v10mpositiontaking_2 = case when isnull(@isauto_v10mpositiontaking_2, 0)=0 then @v10mpositiontaking_2 else case when @auto_v10mpositiontaking_2 < @v10mapositiontaking_2_max - @v10apositiontaking_2 then @auto_v10mpositiontaking_2 else @v10mapositiontaking_2_max - @v10apositiontaking_2 end end
select @v10mpositiontaking_3 = case when isnull(@isauto_v10mpositiontaking_3, 0)=0 then @v10mpositiontaking_3 else case when @auto_v10mpositiontaking_3 < @v10mapositiontaking_3_max - @v10apositiontaking_3 then @auto_v10mpositiontaking_3 else @v10mapositiontaking_3_max - @v10apositiontaking_3 end end
select @v10mpositiontaking_20 = case when isnull(@isauto_v10mpositiontaking_20, 0)=0 then @v10mpositiontaking_20 else case when @auto_v10mpositiontaking_20 < @v10mapositiontaking_20_max - @v10apositiontaking_20 then @auto_v10mpositiontaking_20 else @v10mapositiontaking_20_max - @v10apositiontaking_20 end end

select @v11mpositiontaking_1 = case when isnull(@isauto_v11mpositiontaking_1, 0)=0 then @v11mpositiontaking_1 else case when @auto_v11mpositiontaking_1 < @v11mapositiontaking_1_max - @v11apositiontaking_1 then @auto_v11mpositiontaking_1 else @v11mapositiontaking_1_max - @v11apositiontaking_1 end end
select @v11mpositiontaking_20 = case when isnull(@isauto_v11mpositiontaking_20, 0)=0 then @v11mpositiontaking_20 else case when @auto_v11mpositiontaking_20 < @v11mapositiontaking_20_max - @v11apositiontaking_20 then @auto_v11mpositiontaking_20 else @v11mapositiontaking_20_max - @v11apositiontaking_20 end end

select @v99mpositiontaking_1 = case when isnull(@isauto_v99mpositiontaking_1, 0)=0 then @v99mpositiontaking_1 else case when @auto_v99mpositiontaking_1 < @v99mapositiontaking_1_max - @v99apositiontaking_1 then @auto_v99mpositiontaking_1 else @v99mapositiontaking_1_max - @v99apositiontaking_1 end end
select @v99mpositiontaking_2 = case when isnull(@isauto_v99mpositiontaking_2, 0)=0 then @v99mpositiontaking_2 else case when @auto_v99mpositiontaking_2 < @v99mapositiontaking_2_max - @v99apositiontaking_2 then @auto_v99mpositiontaking_2 else @v99mapositiontaking_2_max - @v99apositiontaking_2 end end
select @v99mpositiontaking_3 = case when isnull(@isauto_v99mpositiontaking_3, 0)=0 then @v99mpositiontaking_3 else case when @auto_v99mpositiontaking_3 < @v99mapositiontaking_3_max - @v99apositiontaking_3 then @auto_v99mpositiontaking_3 else @v99mapositiontaking_3_max - @v99apositiontaking_3 end end
select @v99mpositiontaking_9 = case when isnull(@isauto_v99mpositiontaking_9, 0)=0 then @v99mpositiontaking_9 else case when @auto_v99mpositiontaking_9 < @v99mapositiontaking_9_max - @v99apositiontaking_9 then @auto_v99mpositiontaking_9 else @v99mapositiontaking_9_max - @v99apositiontaking_9 end end
select @v99mpositiontaking_20 = case when isnull(@isauto_v99mpositiontaking_20, 0)=0 then @v99mpositiontaking_20 else case when @auto_v99mpositiontaking_20 < @v99mapositiontaking_20_max - @v99apositiontaking_20 then @auto_v99mpositiontaking_20 else @v99mapositiontaking_20_max - @v99apositiontaking_20 end end

select @v154mpositiontaking_20 = case when isnull(@isauto_v154mpositiontaking_20, 0)=0 then @v154mpositiontaking_20 else case when @auto_v154mpositiontaking_20 < @v154mapositiontaking_20_max - @v154apositiontaking_20 then @auto_v154mpositiontaking_20 else @v154mapositiontaking_20_max - @v154apositiontaking_20 end end

--v161
select @v161mpositiontaking_81 = case when isnull(@isauto_v161mpositiontaking_81, 0)=0 then @v161mpositiontaking_81 else case when @auto_v161mpositiontaking_81 < @v161mapositiontaking_81_max - @v161apositiontaking_81 then @auto_v161mpositiontaking_81 else @v161mapositiontaking_81_max - @v161apositiontaking_81 end end
select @v161mpositiontaking_83 = case when isnull(@isauto_v161mpositiontaking_83, 0)=0 then @v161mpositiontaking_83 else case when @auto_v161mpositiontaking_83 < @v161mapositiontaking_83_max - @v161apositiontaking_83 then @auto_v161mpositiontaking_83 else @v161mapositiontaking_83_max - @v161apositiontaking_83 end end
select @v161mpositiontaking_86 = case when isnull(@isauto_v161mpositiontaking_86, 0)=0 then @v161mpositiontaking_86 else case when @auto_v161mpositiontaking_86 < @v161mapositiontaking_86_max - @v161apositiontaking_86 then @auto_v161mpositiontaking_86 else @v161mapositiontaking_86_max - @v161apositiontaking_86 end end
select @v161mpositiontaking_88 = case when isnull(@isauto_v161mpositiontaking_88, 0)=0 then @v161mpositiontaking_88 else case when @auto_v161mpositiontaking_88 < @v161mapositiontaking_88_max - @v161apositiontaking_88 then @auto_v161mpositiontaking_88 else @v161mapositiontaking_88_max - @v161apositiontaking_88 end end

select @v161mlivepositiontaking_85 = case when isnull(@isauto_v161mlivepositiontaking_85, 0)=0 then @v161mlivepositiontaking_85 else case when @auto_v161mlivepositiontaking_85 < @v161malivepositiontaking_85_max - @v161alivepositiontaking_85 then @auto_v161mlivepositiontaking_85 else @v161malivepositiontaking_85_max - @v161alivepositiontaking_85 end end
select @v161mlivepositiontaking_86 = case when isnull(@isauto_v161mlivepositiontaking_86, 0)=0 then @v161mlivepositiontaking_86 else case when @auto_v161mlivepositiontaking_86 < @v161malivepositiontaking_86_max - @v161alivepositiontaking_86 then @auto_v161mlivepositiontaking_86 else @v161malivepositiontaking_86_max - @v161alivepositiontaking_86 end end
select @v161mlivepositiontaking_87 = case when isnull(@isauto_v161mlivepositiontaking_87, 0)=0 then @v161mlivepositiontaking_87 else case when @auto_v161mlivepositiontaking_87 < @v161malivepositiontaking_87_max - @v161alivepositiontaking_87 then @auto_v161mlivepositiontaking_87 else @v161malivepositiontaking_87_max - @v161alivepositiontaking_87 end end
select @v161mlivepositiontaking_89 = case when isnull(@isauto_v161mlivepositiontaking_89, 0)=0 then @v161mlivepositiontaking_89 else case when @auto_v161mlivepositiontaking_89 < @v161malivepositiontaking_89_max - @v161alivepositiontaking_89 then @auto_v161mlivepositiontaking_89 else @v161malivepositiontaking_89_max - @v161alivepositiontaking_89 end end
select @v161mlivepositiontaking_90 = case when isnull(@isauto_v161mlivepositiontaking_90, 0)=0 then @v161mlivepositiontaking_90 else case when @auto_v161mlivepositiontaking_90 < @v161malivepositiontaking_90_max - @v161alivepositiontaking_90 then @auto_v161mlivepositiontaking_90 else @v161malivepositiontaking_90_max - @v161alivepositiontaking_90 end end
--------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------

----------------***Use Auto Position Taking***----------------------------------
--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
--if @auto_spt = 0 then @spt = @spt  -- Auto pt is not used
--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
--		else @spt = @max_spt - @mpt - @apt
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
SELECT @v99spositiontaking_9 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9, 0)<=0 THEN @v99spositiontaking_9 ELSE CASE WHEN @auto_v99spositiontaking_9 < @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 THEN @auto_v99spositiontaking_9 ELSE @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 END END
SELECT @v99spositiontaking_20 = CASE WHEN ISNULL(@isauto_v99spositiontaking_20, 0)<=0 THEN @v99spositiontaking_20 ELSE CASE WHEN @auto_v99spositiontaking_20 < @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 THEN @auto_v99spositiontaking_20 ELSE @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 END END

SELECT @v154spositiontaking_20 = CASE WHEN ISNULL(@isauto_v154spositiontaking_20, 0)<=0 THEN @v154spositiontaking_20 ELSE CASE WHEN @auto_v154spositiontaking_20 < @max_v154spositiontaking_20 - @v154mpositiontaking_20 - @v154apositiontaking_20 THEN @auto_v154spositiontaking_20 ELSE @max_v154spositiontaking_20 - @v154mpositiontaking_20 - @v154apositiontaking_20 END END

--v161
SELECT @v161spositiontaking_81 = CASE WHEN ISNULL(@isauto_v161spositiontaking_81, 0)<=0 THEN @v161spositiontaking_81 ELSE CASE WHEN @auto_v161spositiontaking_81 < @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 THEN @auto_v161spositiontaking_81 ELSE @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 END END
SELECT @v161spositiontaking_83 = CASE WHEN ISNULL(@isauto_v161spositiontaking_83, 0)<=0 THEN @v161spositiontaking_83 ELSE CASE WHEN @auto_v161spositiontaking_83 < @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 THEN @auto_v161spositiontaking_83 ELSE @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 END END
SELECT @v161spositiontaking_86 = CASE WHEN ISNULL(@isauto_v161spositiontaking_86, 0)<=0 THEN @v161spositiontaking_86 ELSE CASE WHEN @auto_v161spositiontaking_86 < @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 THEN @auto_v161spositiontaking_86 ELSE @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 END END
SELECT @v161spositiontaking_88 = CASE WHEN ISNULL(@isauto_v161spositiontaking_88, 0)<=0 THEN @v161spositiontaking_88 ELSE CASE WHEN @auto_v161spositiontaking_88 < @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 THEN @auto_v161spositiontaking_88 ELSE @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 END END

SELECT @v161slivepositiontaking_85 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_85, 0)<=0 THEN @v161slivepositiontaking_85 ELSE CASE WHEN @auto_v161slivepositiontaking_85 < @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 THEN @auto_v161slivepositiontaking_85 ELSE @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 END END
SELECT @v161slivepositiontaking_86 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_86, 0)<=0 THEN @v161slivepositiontaking_86 ELSE CASE WHEN @auto_v161slivepositiontaking_86 < @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 THEN @auto_v161slivepositiontaking_86 ELSE @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 END END
SELECT @v161slivepositiontaking_87 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_87, 0)<=0 THEN @v161slivepositiontaking_87 ELSE CASE WHEN @auto_v161slivepositiontaking_87 < @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 THEN @auto_v161slivepositiontaking_87 ELSE @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 END END
SELECT @v161slivepositiontaking_89 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_89, 0)<=0 THEN @v161slivepositiontaking_89 ELSE CASE WHEN @auto_v161slivepositiontaking_89 < @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 THEN @auto_v161slivepositiontaking_89 ELSE @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 END END
SELECT @v161slivepositiontaking_90 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_90, 0)<=0 THEN @v161slivepositiontaking_90 ELSE CASE WHEN @auto_v161slivepositiontaking_90 < @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 THEN @auto_v161slivepositiontaking_90 ELSE @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 END END


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--REPLACING CHECK MAX SUPER PT ON MEMBER
/*
SELECT @max_spositiontaking_1 = CASE WHEN ISNULL(@isauto_spositiontaking_1, 0)>0 THEN @max_spositiontaking_1 ELSE @max_spositiontaking_1 - @mapositiontaking_1_max END
SELECT @max_spositiontaking_3 = CASE WHEN ISNULL(@isauto_spositiontaking_3, 0)>0 THEN @max_spositiontaking_3 ELSE @max_spositiontaking_3 - @mapositiontaking_3_max END
SELECT @max_spositiontaking_7 = CASE WHEN ISNULL(@isauto_spositiontaking_7, 0)>0 THEN @max_spositiontaking_7 ELSE @max_spositiontaking_7 - @mapositiontaking_7_max END
SELECT @max_spositiontaking_8 = CASE WHEN ISNULL(@isauto_spositiontaking_8, 0)>0 THEN @max_spositiontaking_8 ELSE @max_spositiontaking_8 - @mapositiontaking_8_max END

SELECT @max_slivepositiontaking_1 = CASE WHEN ISNULL(@isauto_slivepositiontaking_1, 0)>0 THEN @max_slivepositiontaking_1 ELSE @max_slivepositiontaking_1 - @malivepositiontaking_1_max END
SELECT @max_slivepositiontaking_3 = CASE WHEN ISNULL(@isauto_slivepositiontaking_3, 0)>0 THEN @max_slivepositiontaking_3 ELSE @max_slivepositiontaking_3 - @malivepositiontaking_3_max END
SELECT @max_slivepositiontaking_7 = CASE WHEN ISNULL(@isauto_slivepositiontaking_7, 0)>0 THEN @max_slivepositiontaking_7 ELSE @max_slivepositiontaking_7 - @malivepositiontaking_7_max END
SELECT @max_slivepositiontaking_8 = CASE WHEN ISNULL(@isauto_slivepositiontaking_8, 0)>0 THEN @max_slivepositiontaking_8 ELSE @max_slivepositiontaking_8 - @malivepositiontaking_8_max END

SELECT @max_spositiontaking_2 = CASE WHEN ISNULL(@isauto_spositiontaking_2, 0)>0 THEN @max_spositiontaking_2 ELSE @max_spositiontaking_2 - @mapositiontaking_2_max END
SELECT @max_spositiontaking_4 = CASE WHEN ISNULL(@isauto_spositiontaking_4, 0)>0 THEN @max_spositiontaking_4 ELSE @max_spositiontaking_4 - @mapositiontaking_4_max END
SELECT @max_spositiontaking_5 = CASE WHEN ISNULL(@isauto_spositiontaking_5, 0)>0 THEN @max_spositiontaking_5 ELSE @max_spositiontaking_5 - @mapositiontaking_5_max END
SELECT @max_spositiontaking_6 = CASE WHEN ISNULL(@isauto_spositiontaking_6, 0)>0 THEN @max_spositiontaking_6 ELSE @max_spositiontaking_6 - @mapositiontaking_6_max END
SELECT @max_spositiontaking_9 = CASE WHEN ISNULL(@isauto_spositiontaking_9, 0)>0 THEN @max_spositiontaking_9 ELSE @max_spositiontaking_9 - @mapositiontaking_9_max END
SELECT @max_spositiontaking_10 = CASE WHEN ISNULL(@isauto_spositiontaking_10, 0)>0 THEN @max_spositiontaking_10 ELSE @max_spositiontaking_10 - @mapositiontaking_10_max END

SELECT @max_v2spositiontaking_1 = CASE WHEN ISNULL(@isauto_v2spositiontaking_1, 0)>0 THEN @max_v2spositiontaking_1 ELSE @max_v2spositiontaking_1 - @v2mapositiontaking_1_max END
SELECT @max_v2spositiontaking_2 = CASE WHEN ISNULL(@isauto_v2spositiontaking_2, 0)>0 THEN @max_v2spositiontaking_2 ELSE @max_v2spositiontaking_2 - @v2mapositiontaking_2_max END
SELECT @max_v2spositiontaking_3 = CASE WHEN ISNULL(@isauto_v2spositiontaking_3, 0)>0 THEN @max_v2spositiontaking_3 ELSE @max_v2spositiontaking_3 - @v2mapositiontaking_3_max END
SELECT @max_v2spositiontaking_7 = CASE WHEN ISNULL(@isauto_v2spositiontaking_7, 0)>0 THEN @max_v2spositiontaking_7 ELSE @max_v2spositiontaking_7 - @v2mapositiontaking_7_max END
SELECT @max_v2spositiontaking_8 = CASE WHEN ISNULL(@isauto_v2spositiontaking_8, 0)>0 THEN @max_v2spositiontaking_8 ELSE @max_v2spositiontaking_8 - @v2mapositiontaking_8_max END
SELECT @max_v2spositiontaking_9 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9, 0)>0 THEN @max_v2spositiontaking_9 ELSE @max_v2spositiontaking_9 - @v2mapositiontaking_9_max END
SELECT @max_v2spositiontaking_20 = CASE WHEN ISNULL(@isauto_v2spositiontaking_20, 0)>0 THEN @max_v2spositiontaking_20 ELSE @max_v2spositiontaking_20 - @v2mapositiontaking_20_max END

SELECT @max_v3spositiontaking_1 = CASE WHEN ISNULL(@isauto_v3spositiontaking_1, 0)>0 THEN @max_v3spositiontaking_1 ELSE @max_v3spositiontaking_1 - @v3mapositiontaking_1_max END
SELECT @max_v3spositiontaking_2 = CASE WHEN ISNULL(@isauto_v3spositiontaking_2, 0)>0 THEN @max_v3spositiontaking_2 ELSE @max_v3spositiontaking_2 - @v3mapositiontaking_2_max END
SELECT @max_v3spositiontaking_3 = CASE WHEN ISNULL(@isauto_v3spositiontaking_3, 0)>0 THEN @max_v3spositiontaking_3 ELSE @max_v3spositiontaking_3 - @v3mapositiontaking_3_max END
SELECT @max_v3spositiontaking_20 = CASE WHEN ISNULL(@isauto_v3spositiontaking_20, 0)>0 THEN @max_v3spositiontaking_20 ELSE @max_v3spositiontaking_20 - @v3mapositiontaking_20_max END

SELECT @max_v5spositiontaking_1 = CASE WHEN ISNULL(@isauto_v5spositiontaking_1, 0)>0 THEN @max_v5spositiontaking_1 ELSE @max_v5spositiontaking_1 - @v5mapositiontaking_1_max END
SELECT @max_v5spositiontaking_2 = CASE WHEN ISNULL(@isauto_v5spositiontaking_2, 0)>0 THEN @max_v5spositiontaking_2 ELSE @max_v5spositiontaking_2 - @v5mapositiontaking_2_max END
SELECT @max_v5spositiontaking_3 = CASE WHEN ISNULL(@isauto_v5spositiontaking_3, 0)>0 THEN @max_v5spositiontaking_3 ELSE @max_v5spositiontaking_3 - @v5mapositiontaking_3_max END
SELECT @max_v5spositiontaking_20 = CASE WHEN ISNULL(@isauto_v5spositiontaking_20, 0)>0 THEN @max_v5spositiontaking_20 ELSE @max_v5spositiontaking_20 - @v5mapositiontaking_20_max END

SELECT @max_v8spositiontaking_1 = CASE WHEN ISNULL(@isauto_v8spositiontaking_1, 0)>0 THEN @max_v8spositiontaking_1 ELSE @max_v8spositiontaking_1 - @v8mapositiontaking_1_max END
SELECT @max_v8spositiontaking_3 = CASE WHEN ISNULL(@isauto_v8spositiontaking_3, 0)>0 THEN @max_v8spositiontaking_3 ELSE @max_v8spositiontaking_3 - @v8mapositiontaking_3_max END
SELECT @max_v8spositiontaking_20 = CASE WHEN ISNULL(@isauto_v8spositiontaking_20, 0)>0 THEN @max_v8spositiontaking_20 ELSE @max_v8spositiontaking_20 - @v8mapositiontaking_20_max END

SELECT @max_v10spositiontaking_1 = CASE WHEN ISNULL(@isauto_v10spositiontaking_1, 0)>0 THEN @max_v10spositiontaking_1 ELSE @max_v10spositiontaking_1 - @v10mapositiontaking_1_max END
SELECT @max_v10spositiontaking_2 = CASE WHEN ISNULL(@isauto_v10spositiontaking_2, 0)>0 THEN @max_v10spositiontaking_2 ELSE @max_v10spositiontaking_2 - @v10mapositiontaking_2_max END
SELECT @max_v10spositiontaking_3 = CASE WHEN ISNULL(@isauto_v10spositiontaking_3, 0)>0 THEN @max_v10spositiontaking_3 ELSE @max_v10spositiontaking_3 - @v10mapositiontaking_3_max END
SELECT @max_v10spositiontaking_20 = CASE WHEN ISNULL(@isauto_v10spositiontaking_20, 0)>0 THEN @max_v10spositiontaking_20 ELSE @max_v10spositiontaking_20 - @v10mapositiontaking_20_max END

SELECT @max_v11spositiontaking_1 = CASE WHEN ISNULL(@isauto_v11spositiontaking_1, 0)>0 THEN @max_v11spositiontaking_1 ELSE @max_v11spositiontaking_1 - @v11mapositiontaking_1_max END
SELECT @max_v11spositiontaking_20 = CASE WHEN ISNULL(@isauto_v11spositiontaking_20, 0)>0 THEN @max_v11spositiontaking_20 ELSE @max_v11spositiontaking_20 - @v11mapositiontaking_20_max END

SELECT @max_v12spositiontaking_2 = CASE WHEN ISNULL(@isauto_v12spositiontaking_2, 0)>0 THEN @max_v12spositiontaking_2 ELSE @max_v12spositiontaking_2 - @v12mapositiontaking_2_max END
SELECT @max_v12spositiontaking_21 = CASE WHEN ISNULL(@isauto_v12spositiontaking_21, 0)>0 THEN @max_v12spositiontaking_21 ELSE @max_v12spositiontaking_21 - @v12mapositiontaking_21_max END
SELECT @max_v12spositiontaking_22 = CASE WHEN ISNULL(@isauto_v12spositiontaking_22, 0)>0 THEN @max_v12spositiontaking_22 ELSE @max_v12spositiontaking_22 - @v12mapositiontaking_22_max END

SELECT @max_v99spositiontaking_1 = CASE WHEN ISNULL(@isauto_v99spositiontaking_1, 0)>0 THEN @max_v99spositiontaking_1 ELSE @max_v99spositiontaking_1 - @v99mapositiontaking_1_max END
SELECT @max_v99spositiontaking_2 = CASE WHEN ISNULL(@isauto_v99spositiontaking_2, 0)>0 THEN @max_v99spositiontaking_2 ELSE @max_v99spositiontaking_2 - @v99mapositiontaking_2_max END
SELECT @max_v99spositiontaking_3 = CASE WHEN ISNULL(@isauto_v99spositiontaking_3, 0)>0 THEN @max_v99spositiontaking_3 ELSE @max_v99spositiontaking_3 - @v99mapositiontaking_3_max END
SELECT @max_v99spositiontaking_20 = CASE WHEN ISNULL(@isauto_v99spositiontaking_20, 0)>0 THEN @max_v99spositiontaking_20 ELSE @max_v99spositiontaking_20 - @v99mapositiontaking_20_max END
*/


--max_spositiontaking = if(i1||i3)s4:s4-m1-a1
SELECT @max_spositiontaking_1 = CASE WHEN ISNULL(@isauto_spositiontaking_1, 0)>0 THEN @max_spositiontaking_1 ELSE @max_spositiontaking_1 - @mpositiontaking_1 - @apositiontaking_1 END
SELECT @max_spositiontaking_3 = CASE WHEN ISNULL(@isauto_spositiontaking_3, 0)>0 THEN @max_spositiontaking_3 ELSE @max_spositiontaking_3 - @mpositiontaking_3 - @apositiontaking_3 END
SELECT @max_spositiontaking_7 = CASE WHEN ISNULL(@isauto_spositiontaking_7, 0)>0 THEN @max_spositiontaking_7 ELSE @max_spositiontaking_7 - @mpositiontaking_7 - @apositiontaking_7 END
SELECT @max_spositiontaking_8 = CASE WHEN ISNULL(@isauto_spositiontaking_8, 0)>0 THEN @max_spositiontaking_8 ELSE @max_spositiontaking_8 - @mpositiontaking_8 - @apositiontaking_8 END

SELECT @max_slivepositiontaking_1 = CASE WHEN ISNULL(@isauto_slivepositiontaking_1, 0)>0 THEN @max_slivepositiontaking_1 ELSE @max_slivepositiontaking_1 - @mlivepositiontaking_1 - @alivepositiontaking_1 END
SELECT @max_slivepositiontaking_3 = CASE WHEN ISNULL(@isauto_slivepositiontaking_3, 0)>0 THEN @max_slivepositiontaking_3 ELSE @max_slivepositiontaking_3 - @mlivepositiontaking_3 - @alivepositiontaking_3 END
SELECT @max_slivepositiontaking_7 = CASE WHEN ISNULL(@isauto_slivepositiontaking_7, 0)>0 THEN @max_slivepositiontaking_7 ELSE @max_slivepositiontaking_7 - @mlivepositiontaking_7 - @alivepositiontaking_7 END
SELECT @max_slivepositiontaking_8 = CASE WHEN ISNULL(@isauto_slivepositiontaking_8, 0)>0 THEN @max_slivepositiontaking_8 ELSE @max_slivepositiontaking_8 - @mlivepositiontaking_8 - @alivepositiontaking_8 END

SELECT @max_spositiontaking_2 = CASE WHEN ISNULL(@isauto_spositiontaking_2, 0)>0 THEN @max_spositiontaking_2 ELSE @max_spositiontaking_2 - @mpositiontaking_2 - @apositiontaking_2 END
SELECT @max_spositiontaking_4 = CASE WHEN ISNULL(@isauto_spositiontaking_4, 0)>0 THEN @max_spositiontaking_4 ELSE @max_spositiontaking_4 - @mpositiontaking_4 - @apositiontaking_4 END
SELECT @max_spositiontaking_5 = CASE WHEN ISNULL(@isauto_spositiontaking_5, 0)>0 THEN @max_spositiontaking_5 ELSE @max_spositiontaking_5 - @mpositiontaking_5 - @apositiontaking_5 END
SELECT @max_spositiontaking_6 = CASE WHEN ISNULL(@isauto_spositiontaking_6, 0)>0 THEN @max_spositiontaking_6 ELSE @max_spositiontaking_6 - @mpositiontaking_6 - @apositiontaking_6 END
SELECT @max_spositiontaking_9 = CASE WHEN ISNULL(@isauto_spositiontaking_9, 0)>0 THEN @max_spositiontaking_9 ELSE @max_spositiontaking_9 - @mpositiontaking_9 - @apositiontaking_9 END
SELECT @max_spositiontaking_10 = CASE WHEN ISNULL(@isauto_spositiontaking_10, 0)>0 THEN @max_spositiontaking_10 ELSE @max_spositiontaking_10 - @mpositiontaking_10 - @apositiontaking_10 END

-- Outright PT for sports
SELECT @max_v2spositiontaking_10 = CASE WHEN ISNULL(@isauto_v2spositiontaking_10, 0)>0 THEN @max_v2spositiontaking_10 ELSE @max_v2spositiontaking_10 - @v2mpositiontaking_10 - @v2apositiontaking_10 END
SELECT @max_v3spositiontaking_10 = CASE WHEN ISNULL(@isauto_v3spositiontaking_10, 0)>0 THEN @max_v3spositiontaking_10 ELSE @max_v3spositiontaking_10 - @v3mpositiontaking_10 - @v3apositiontaking_10 END
SELECT @max_v5spositiontaking_10 = CASE WHEN ISNULL(@isauto_v5spositiontaking_10, 0)>0 THEN @max_v5spositiontaking_10 ELSE @max_v5spositiontaking_10 - @v5mpositiontaking_10 - @v5apositiontaking_10 END
SELECT @max_v8spositiontaking_10 = CASE WHEN ISNULL(@isauto_v8spositiontaking_10, 0)>0 THEN @max_v8spositiontaking_10 ELSE @max_v8spositiontaking_10 - @v8mpositiontaking_10 - @v8apositiontaking_10 END
SELECT @max_v10spositiontaking_10 = CASE WHEN ISNULL(@isauto_v10spositiontaking_10, 0)>0 THEN @max_v10spositiontaking_10 ELSE @max_v10spositiontaking_10 - @v10mpositiontaking_10 - @v10apositiontaking_10 END
SELECT @max_v11spositiontaking_10 = CASE WHEN ISNULL(@isauto_v11spositiontaking_10, 0)>0 THEN @max_v11spositiontaking_10 ELSE @max_v11spositiontaking_10 - @v11mpositiontaking_10 - @v11apositiontaking_10 END
SELECT @max_v99spositiontaking_10 = CASE WHEN ISNULL(@isauto_v99spositiontaking_10, 0)>0 THEN @max_v99spositiontaking_10 ELSE @max_v99spositiontaking_10 - @v99mpositiontaking_10 - @v99apositiontaking_10 END

SELECT @max_spositiontaking_9999 = CASE WHEN ISNULL(@isauto_spositiontaking_9999, 0)>0 THEN @max_spositiontaking_9999 ELSE @max_spositiontaking_9999 - @mpositiontaking_9999 - @apositiontaking_9999 END

SELECT @max_v2spositiontaking_1 = CASE WHEN ISNULL(@isauto_v2spositiontaking_1, 0)>0 THEN @max_v2spositiontaking_1 ELSE @max_v2spositiontaking_1 - @v2mpositiontaking_1 - @v2apositiontaking_1 END
SELECT @max_v2spositiontaking_2 = CASE WHEN ISNULL(@isauto_v2spositiontaking_2, 0)>0 THEN @max_v2spositiontaking_2 ELSE @max_v2spositiontaking_2 - @v2mpositiontaking_2 - @v2apositiontaking_2 END
SELECT @max_v2spositiontaking_3 = CASE WHEN ISNULL(@isauto_v2spositiontaking_3, 0)>0 THEN @max_v2spositiontaking_3 ELSE @max_v2spositiontaking_3 - @v2mpositiontaking_3 - @v2apositiontaking_3 END
SELECT @max_v2spositiontaking_7 = CASE WHEN ISNULL(@isauto_v2spositiontaking_7, 0)>0 THEN @max_v2spositiontaking_7 ELSE @max_v2spositiontaking_7 - @v2mpositiontaking_7 - @v2apositiontaking_7 END
SELECT @max_v2spositiontaking_8 = CASE WHEN ISNULL(@isauto_v2spositiontaking_8, 0)>0 THEN @max_v2spositiontaking_8 ELSE @max_v2spositiontaking_8 - @v2mpositiontaking_8 - @v2apositiontaking_8 END
--SELECT @max_v2spositiontaking_9 = CASE WHEN ISNULL(@isauto_v2spositiontaking_9, 0)>0 THEN @max_v2spositiontaking_9 ELSE @max_v2spositiontaking_9 - @v2mpositiontaking_9 - @v2apositiontaking_9 END
SELECT @max_v2spositiontaking_20 = CASE WHEN ISNULL(@isauto_v2spositiontaking_20, 0)>0 THEN @max_v2spositiontaking_20 ELSE @max_v2spositiontaking_20 - @v2mpositiontaking_20 - @v2apositiontaking_20 END

SELECT @max_v3spositiontaking_1 = CASE WHEN ISNULL(@isauto_v3spositiontaking_1, 0)>0 THEN @max_v3spositiontaking_1 ELSE @max_v3spositiontaking_1 - @v3mpositiontaking_1 - @v3apositiontaking_1 END
SELECT @max_v3spositiontaking_2 = CASE WHEN ISNULL(@isauto_v3spositiontaking_2, 0)>0 THEN @max_v3spositiontaking_2 ELSE @max_v3spositiontaking_2 - @v3mpositiontaking_2 - @v3apositiontaking_2 END
SELECT @max_v3spositiontaking_3 = CASE WHEN ISNULL(@isauto_v3spositiontaking_3, 0)>0 THEN @max_v3spositiontaking_3 ELSE @max_v3spositiontaking_3 - @v3mpositiontaking_3 - @v3apositiontaking_3 END
SELECT @max_v3spositiontaking_20 = CASE WHEN ISNULL(@isauto_v3spositiontaking_20, 0)>0 THEN @max_v3spositiontaking_20 ELSE @max_v3spositiontaking_20 - @v3mpositiontaking_20 - @v3apositiontaking_20 END

SELECT @max_v5spositiontaking_1 = CASE WHEN ISNULL(@isauto_v5spositiontaking_1, 0)>0 THEN @max_v5spositiontaking_1 ELSE @max_v5spositiontaking_1 - @v5mpositiontaking_1 - @v5apositiontaking_1 END
SELECT @max_v5spositiontaking_2 = CASE WHEN ISNULL(@isauto_v5spositiontaking_2, 0)>0 THEN @max_v5spositiontaking_2 ELSE @max_v5spositiontaking_2 - @v5mpositiontaking_2 - @v5apositiontaking_2 END
SELECT @max_v5spositiontaking_3 = CASE WHEN ISNULL(@isauto_v5spositiontaking_3, 0)>0 THEN @max_v5spositiontaking_3 ELSE @max_v5spositiontaking_3 - @v5mpositiontaking_3 - @v5apositiontaking_3 END
SELECT @max_v5spositiontaking_20 = CASE WHEN ISNULL(@isauto_v5spositiontaking_20, 0)>0 THEN @max_v5spositiontaking_20 ELSE @max_v5spositiontaking_20 - @v5mpositiontaking_20 - @v5apositiontaking_20 END
SELECT @max_v5spositiontaking_9999 = CASE WHEN ISNULL(@isauto_v5spositiontaking_9999, 0)>0 THEN @max_v5spositiontaking_9999 ELSE @max_v5spositiontaking_9999 - @v5mpositiontaking_9999 - @v5apositiontaking_9999 END

SELECT @max_v8spositiontaking_1 = CASE WHEN ISNULL(@isauto_v8spositiontaking_1, 0)>0 THEN @max_v8spositiontaking_1 ELSE @max_v8spositiontaking_1 - @v8mpositiontaking_1 - @v8apositiontaking_1 END
SELECT @max_v8spositiontaking_3 = CASE WHEN ISNULL(@isauto_v8spositiontaking_3, 0)>0 THEN @max_v8spositiontaking_3 ELSE @max_v8spositiontaking_3 - @v8mpositiontaking_3 - @v8apositiontaking_3 END
SELECT @max_v8spositiontaking_20 = CASE WHEN ISNULL(@isauto_v8spositiontaking_20, 0)>0 THEN @max_v8spositiontaking_20 ELSE @max_v8spositiontaking_20 - @v8mpositiontaking_20 - @v8apositiontaking_20 END

SELECT @max_v10spositiontaking_1 = CASE WHEN ISNULL(@isauto_v10spositiontaking_1, 0)>0 THEN @max_v10spositiontaking_1 ELSE @max_v10spositiontaking_1 - @v10mpositiontaking_1 - @v10apositiontaking_1 END
SELECT @max_v10spositiontaking_2 = CASE WHEN ISNULL(@isauto_v10spositiontaking_2, 0)>0 THEN @max_v10spositiontaking_2 ELSE @max_v10spositiontaking_2 - @v10mpositiontaking_2 - @v10apositiontaking_2 END
SELECT @max_v10spositiontaking_3 = CASE WHEN ISNULL(@isauto_v10spositiontaking_3, 0)>0 THEN @max_v10spositiontaking_3 ELSE @max_v10spositiontaking_3 - @v10mpositiontaking_3 - @v10apositiontaking_3 END
SELECT @max_v10spositiontaking_20 = CASE WHEN ISNULL(@isauto_v10spositiontaking_20, 0)>0 THEN @max_v10spositiontaking_20 ELSE @max_v10spositiontaking_20 - @v10mpositiontaking_20 - @v10apositiontaking_20 END

SELECT @max_v11spositiontaking_1 = CASE WHEN ISNULL(@isauto_v11spositiontaking_1, 0)>0 THEN @max_v11spositiontaking_1 ELSE @max_v11spositiontaking_1 - @v11mpositiontaking_1 - @v11apositiontaking_1 END
SELECT @max_v11spositiontaking_20 = CASE WHEN ISNULL(@isauto_v11spositiontaking_20, 0)>0 THEN @max_v11spositiontaking_20 ELSE @max_v11spositiontaking_20 - @v11mpositiontaking_20 - @v11apositiontaking_20 END

SELECT @max_v99spositiontaking_1 = CASE WHEN ISNULL(@isauto_v99spositiontaking_1, 0)>0 THEN @max_v99spositiontaking_1 ELSE @max_v99spositiontaking_1 - @v99mpositiontaking_1 - @v99apositiontaking_1 END
SELECT @max_v99spositiontaking_2 = CASE WHEN ISNULL(@isauto_v99spositiontaking_2, 0)>0 THEN @max_v99spositiontaking_2 ELSE @max_v99spositiontaking_2 - @v99mpositiontaking_2 - @v99apositiontaking_2 END
SELECT @max_v99spositiontaking_3 = CASE WHEN ISNULL(@isauto_v99spositiontaking_3, 0)>0 THEN @max_v99spositiontaking_3 ELSE @max_v99spositiontaking_3 - @v99mpositiontaking_3 - @v99apositiontaking_3 END
SELECT @max_v99spositiontaking_9 = CASE WHEN ISNULL(@isauto_v99spositiontaking_9, 0)>0 THEN @max_v99spositiontaking_9 ELSE @max_v99spositiontaking_9 - @v99mpositiontaking_9 - @v99apositiontaking_9 END
SELECT @max_v99spositiontaking_20 = CASE WHEN ISNULL(@isauto_v99spositiontaking_20, 0)>0 THEN @max_v99spositiontaking_20 ELSE @max_v99spositiontaking_20 - @v99mpositiontaking_20 - @v99apositiontaking_20 END

SELECT @max_v154spositiontaking_20 = CASE WHEN ISNULL(@isauto_v154spositiontaking_20, 0)>0 THEN @max_v154spositiontaking_20 ELSE @max_v154spositiontaking_20 - @v154mpositiontaking_20 - @v154apositiontaking_20 END

--v161
SELECT @max_v161spositiontaking_81 = CASE WHEN ISNULL(@isauto_v161spositiontaking_81, 0)>0 THEN @max_v161spositiontaking_81 ELSE @max_v161spositiontaking_81 - @v161mpositiontaking_81 - @v161apositiontaking_81 END
SELECT @max_v161spositiontaking_83 = CASE WHEN ISNULL(@isauto_v161spositiontaking_83, 0)>0 THEN @max_v161spositiontaking_83 ELSE @max_v161spositiontaking_83 - @v161mpositiontaking_83 - @v161apositiontaking_83 END
SELECT @max_v161spositiontaking_86 = CASE WHEN ISNULL(@isauto_v161spositiontaking_86, 0)>0 THEN @max_v161spositiontaking_86 ELSE @max_v161spositiontaking_86 - @v161mpositiontaking_86 - @v161apositiontaking_86 END
SELECT @max_v161spositiontaking_88 = CASE WHEN ISNULL(@isauto_v161spositiontaking_88, 0)>0 THEN @max_v161spositiontaking_88 ELSE @max_v161spositiontaking_88 - @v161mpositiontaking_88 - @v161apositiontaking_88 END
SELECT @max_v161slivepositiontaking_85 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_85, 0)>0 THEN @max_v161slivepositiontaking_85 ELSE @max_v161slivepositiontaking_85 - @v161mlivepositiontaking_85 - @v161alivepositiontaking_85 END
SELECT @max_v161slivepositiontaking_86 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_86, 0)>0 THEN @max_v161slivepositiontaking_86 ELSE @max_v161slivepositiontaking_86 - @v161mlivepositiontaking_86 - @v161alivepositiontaking_86 END
SELECT @max_v161slivepositiontaking_87 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_87, 0)>0 THEN @max_v161slivepositiontaking_87 ELSE @max_v161slivepositiontaking_87 - @v161mlivepositiontaking_87 - @v161alivepositiontaking_87 END
SELECT @max_v161slivepositiontaking_89 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_89, 0)>0 THEN @max_v161slivepositiontaking_89 ELSE @max_v161slivepositiontaking_89 - @v161mlivepositiontaking_89 - @v161alivepositiontaking_89 END
SELECT @max_v161slivepositiontaking_90 = CASE WHEN ISNULL(@isauto_v161slivepositiontaking_90, 0)>0 THEN @max_v161slivepositiontaking_90 ELSE @max_v161slivepositiontaking_90 - @v161mlivepositiontaking_90 - @v161alivepositiontaking_90 END
--//REPLACING CHECK MAX SUPER PT ON MEMBER

--s1=min(s1,max_spositiontaking)
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
SELECT @v99spositiontaking_9 = CASE WHEN @v99spositiontaking_9 > @max_v99spositiontaking_9 THEN @max_v99spositiontaking_9 ELSE @v99spositiontaking_9 END
SELECT @v99spositiontaking_20 = CASE WHEN @v99spositiontaking_20 > @max_v99spositiontaking_20 THEN @max_v99spositiontaking_20 ELSE @v99spositiontaking_20 END

SELECT @v154spositiontaking_20 = CASE WHEN @v154spositiontaking_20 > @max_v154spositiontaking_20 THEN @max_v154spositiontaking_20 ELSE @v154spositiontaking_20 END

--v161
SELECT @v161spositiontaking_81 = CASE WHEN @v161spositiontaking_81 > @max_v161spositiontaking_81 THEN @max_v161spositiontaking_81 ELSE @v161spositiontaking_81 END
SELECT @v161spositiontaking_83 = CASE WHEN @v161spositiontaking_83 > @max_v161spositiontaking_83 THEN @max_v161spositiontaking_83 ELSE @v161spositiontaking_83 END
SELECT @v161spositiontaking_86 = CASE WHEN @v161spositiontaking_86 > @max_v161spositiontaking_86 THEN @max_v161spositiontaking_86 ELSE @v161spositiontaking_86 END
SELECT @v161spositiontaking_88 = CASE WHEN @v161spositiontaking_88 > @max_v161spositiontaking_88 THEN @max_v161spositiontaking_88 ELSE @v161spositiontaking_88 END
SELECT @v161slivepositiontaking_85 = CASE WHEN @v161slivepositiontaking_85 > @max_v161slivepositiontaking_85 THEN @max_v161slivepositiontaking_85 ELSE @v161slivepositiontaking_85 END
SELECT @v161slivepositiontaking_86 = CASE WHEN @v161slivepositiontaking_86 > @max_v161slivepositiontaking_86 THEN @max_v161slivepositiontaking_86 ELSE @v161slivepositiontaking_86 END
SELECT @v161slivepositiontaking_87 = CASE WHEN @v161slivepositiontaking_87 > @max_v161slivepositiontaking_87 THEN @max_v161slivepositiontaking_87 ELSE @v161slivepositiontaking_87 END
SELECT @v161slivepositiontaking_89 = CASE WHEN @v161slivepositiontaking_89 > @max_v161slivepositiontaking_89 THEN @max_v161slivepositiontaking_89 ELSE @v161slivepositiontaking_89 END
SELECT @v161slivepositiontaking_90 = CASE WHEN @v161slivepositiontaking_90 > @max_v161slivepositiontaking_90 THEN @max_v161slivepositiontaking_90 ELSE @v161slivepositiontaking_90 END



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------
--- 20131031@Johnson: Apply execrep when update pt on member
		EXEC dbo.Acc_CustSetting_08
		@custid = @custid,
		@roleid = 2,
		
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

		-- mixed sports
		@v99spositiontaking_9 = @v99spositiontaking_9,
		@v154spositiontaking_20 = @v154spositiontaking_20,
		
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

		-- mixed sports
		@v99mpositiontaking_9 = @v99mpositiontaking_9,
		@v154mpositiontaking_20 = @v154mpositiontaking_20,
						
		@apositiontaking_1 = @apositiontaking_1,
		@apositiontaking_2 = @apositiontaking_2,
		@apositiontaking_3 = @apositiontaking_3,
		@apositiontaking_4 = @apositiontaking_4,
		@apositiontaking_5 = @apositiontaking_5,
		@apositiontaking_6 = @apositiontaking_6,
		@apositiontaking_7 = @apositiontaking_7,
		@apositiontaking_8 = @apositiontaking_8,
		@apositiontaking_9 = @apositiontaking_9,
		@apositiontaking_10 = @apositiontaking_10,
		@apositiontaking_9999 = @apositiontaking_9999,
		
		@alivepositiontaking_1 = @alivepositiontaking_1,
		@alivepositiontaking_3 = @alivepositiontaking_3,
		@alivepositiontaking_7 = @alivepositiontaking_7,
		@alivepositiontaking_8 = @alivepositiontaking_8,
		
		@v2apositiontaking_1 = @v2apositiontaking_1,
		@v2apositiontaking_2 = @v2apositiontaking_2,
		@v2apositiontaking_3 = @v2apositiontaking_3,
		@v2apositiontaking_7 = @v2apositiontaking_7,
		@v2apositiontaking_8 = @v2apositiontaking_8,
		--@v2apositiontaking_9 = @v2apositiontaking_9,
		@v2apositiontaking_20 = @v2apositiontaking_20,
		
		@v3apositiontaking_1 = @v3apositiontaking_1,
		@v3apositiontaking_2 = @v3apositiontaking_2,
		@v3apositiontaking_3 = @v3apositiontaking_3,
		@v3apositiontaking_20 = @v3apositiontaking_20,

		@v5apositiontaking_1 = @v5apositiontaking_1,
		@v5apositiontaking_2 = @v5apositiontaking_2,
		@v5apositiontaking_3 = @v5apositiontaking_3,
		@v5apositiontaking_20 = @v5apositiontaking_20,
		@v5apositiontaking_9999 = @v5apositiontaking_9999,

		@v8apositiontaking_1 = @v8apositiontaking_1,
		@v8apositiontaking_3 = @v8apositiontaking_3,
		@v8apositiontaking_20 = @v8apositiontaking_20,

		@v10apositiontaking_1 = @v10apositiontaking_1,
		@v10apositiontaking_2 = @v10apositiontaking_2,
		@v10apositiontaking_3 = @v10apositiontaking_3,
		@v10apositiontaking_20 = @v10apositiontaking_20,

		@v11apositiontaking_1 = @v11apositiontaking_1,
		@v11apositiontaking_20 = @v11apositiontaking_20,

		@v99apositiontaking_1 = @v99apositiontaking_1,
		@v99apositiontaking_2 = @v99apositiontaking_2,
		@v99apositiontaking_3 = @v99apositiontaking_3,
		@v99apositiontaking_9 = @v99apositiontaking_9,
		@v99apositiontaking_20 = @v99apositiontaking_20,
		@v154apositiontaking_20 = @v154apositiontaking_20,
		
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
		@UpdatePositiontakingv154 = @UpdatePositiontakingv154,
		
		-- Outright PT for sports
		@v2spositiontaking_10 = @v2spositiontaking_10,
		@v3spositiontaking_10 = @v3spositiontaking_10,
		@v5spositiontaking_10 = @v5spositiontaking_10,
		@v8spositiontaking_10 = @v8spositiontaking_10,
		@v10spositiontaking_10 = @v10spositiontaking_10,
		@v11spositiontaking_10 = @v11spositiontaking_10,
		@v99spositiontaking_10 = @v99spositiontaking_10,
		
		@v2mpositiontaking_10 = @v2mpositiontaking_10,
		@v3mpositiontaking_10 = @v3mpositiontaking_10,
		@v5mpositiontaking_10 = @v5mpositiontaking_10,
		@v8mpositiontaking_10 = @v8mpositiontaking_10,
		@v10mpositiontaking_10 = @v10mpositiontaking_10,
		@v11mpositiontaking_10 = @v11mpositiontaking_10,
		@v99mpositiontaking_10 = @v99mpositiontaking_10,
		
		@v2apositiontaking_10 = @v2apositiontaking_10,
		@v3apositiontaking_10 = @v3apositiontaking_10,
		@v5apositiontaking_10 = @v5apositiontaking_10,
		@v8apositiontaking_10 = @v8apositiontaking_10,
		@v10apositiontaking_10 = @v10apositiontaking_10,
		@v11apositiontaking_10 = @v11apositiontaking_10,
		@v99apositiontaking_10 = @v99apositiontaking_10
	
	
	--v161
	IF (@UpdateMultiple=0 OR @UpdatePositiontakingv161=1)
	BEGIN	
		EXEC dbo.Acc_CustSetting3rd_08
			@custid = @custid,
			@roleid = 2,
			@mode = 'number',
			
			@v161spositiontaking_81 = @v161spositiontaking_81,
			@v161spositiontaking_83 = @v161spositiontaking_83,
			@v161spositiontaking_86 = @v161spositiontaking_86,
			@v161spositiontaking_88 = @v161spositiontaking_88,
			@v161slivepositiontaking_85 = @v161slivepositiontaking_85,
			@v161slivepositiontaking_86 = @v161slivepositiontaking_86,
			@v161slivepositiontaking_87 = @v161slivepositiontaking_87,
			@v161slivepositiontaking_89 = @v161slivepositiontaking_89,
			@v161slivepositiontaking_90 = @v161slivepositiontaking_90,
			
			@v161mpositiontaking_81 = @v161mpositiontaking_81,
			@v161mpositiontaking_83 = @v161mpositiontaking_83,
			@v161mpositiontaking_86 = @v161mpositiontaking_86,
			@v161mpositiontaking_88 = @v161mpositiontaking_88,
			@v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
			@v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
			@v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
			@v161mlivepositiontaking_89 = @v161mlivepositiontaking_89,
			@v161mlivepositiontaking_90 = @v161mlivepositiontaking_90,
			
			@v161apositiontaking_81 = @v161apositiontaking_81, 
			@v161apositiontaking_83 = @v161apositiontaking_83, 	
			@v161apositiontaking_86 = @v161apositiontaking_86, 
			@v161apositiontaking_88 = @v161apositiontaking_88, 
			@v161alivepositiontaking_85 = @v161alivepositiontaking_85,
			@v161alivepositiontaking_86 = @v161alivepositiontaking_86,
			@v161alivepositiontaking_87 = @v161alivepositiontaking_87,
			@v161alivepositiontaking_89 = @v161alivepositiontaking_89,
			@v161alivepositiontaking_90 = @v161alivepositiontaking_90
	END
	EXEC dbo.Acc_CustSetting_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend
		
	EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'number'
	
	---EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

	
/*
BEGIN TRANSACTION
---------------------------------------

UPDATE custsetting WITH (ROWLOCK, UPDLOCK)
SET
	apositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9 AND @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9 AND @UpdatePositiontakingv99MP = 0) )) THEN apositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @apositiontaking_1 WHEN 2 THEN @apositiontaking_2 WHEN 3 THEN @apositiontaking_3 WHEN 4 THEN @apositiontaking_4 WHEN 5 THEN @apositiontaking_5 WHEN 6 THEN @apositiontaking_6 WHEN 7 THEN @apositiontaking_7 WHEN 8 THEN @apositiontaking_8 WHEN 9 THEN @apositiontaking_9 WHEN 10 THEN @apositiontaking_10 ELSE 0 END
					WHEN 2 THEN CASE bettype WHEN 1 THEN @v2apositiontaking_1 WHEN 2 THEN @v2apositiontaking_2 WHEN 3 THEN @v2apositiontaking_3 WHEN 7 THEN @v2apositiontaking_7 WHEN 8 THEN @v2apositiontaking_8 WHEN 20 THEN @v2apositiontaking_20 ELSE 0 END
					WHEN 3 THEN CASE bettype WHEN 1 THEN @v3apositiontaking_1 WHEN 2 THEN @v3apositiontaking_2 WHEN 3 THEN @v3apositiontaking_3 WHEN 20 THEN @v3apositiontaking_20 ELSE 0 END
					WHEN 5 THEN CASE bettype WHEN 1 THEN @v5apositiontaking_1 WHEN 2 THEN @v5apositiontaking_2 WHEN 3 THEN @v5apositiontaking_3 WHEN 20 THEN @v5apositiontaking_20 ELSE 0 END
					WHEN 8 THEN CASE bettype WHEN 1 THEN @v8apositiontaking_1 WHEN 3 THEN @v8apositiontaking_3 WHEN 20 THEN @v8apositiontaking_20 ELSE 0 END
					WHEN 10 THEN CASE bettype WHEN 1 THEN @v10apositiontaking_1 WHEN 2 THEN @v10apositiontaking_2 WHEN 3 THEN @v10apositiontaking_3 WHEN 20 THEN @v10apositiontaking_20 ELSE 0 END
					WHEN 11 THEN CASE bettype WHEN 1 THEN @v11apositiontaking_1 WHEN 20 THEN @v11apositiontaking_20 ELSE 0 END
					WHEN 99 THEN CASE bettype WHEN 1 THEN @v99apositiontaking_1 WHEN 2 THEN @v99apositiontaking_2 WHEN 3 THEN @v99apositiontaking_3 WHEN 9 THEN @v99apositiontaking_9 WHEN 20 THEN @v99apositiontaking_20 ELSE 0 END
					WHEN 154 THEN CASE bettype WHEN 20 THEN @v154apositiontaking_20 ELSE 0 END					
					ELSE apositiontaking END END,
	alivepositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0))) THEN alivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @alivepositiontaking_1 WHEN 3 THEN @alivepositiontaking_3 WHEN 7 THEN @alivepositiontaking_7 WHEN 8 THEN @alivepositiontaking_8 ELSE alivepositiontaking END ELSE alivepositiontaking END END,
	
	--Auto Master PT
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	mpositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9 AND @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9 AND @UpdatePositiontakingv99MP = 0) )) THEN mpositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @mpositiontaking_1 WHEN 2 THEN @mpositiontaking_2 WHEN 3 THEN @mpositiontaking_3 WHEN 4 THEN @mpositiontaking_4 WHEN 5 THEN @mpositiontaking_5 WHEN 6 THEN @mpositiontaking_6 WHEN 7 THEN @mpositiontaking_7 WHEN 8 THEN @mpositiontaking_8 WHEN 9 THEN @mpositiontaking_9 WHEN 10 THEN @mpositiontaking_10 ELSE 0 END
					WHEN 2 THEN CASE bettype WHEN 1 THEN @v2mpositiontaking_1 WHEN 2 THEN @v2mpositiontaking_2 WHEN 3 THEN @v2mpositiontaking_3 WHEN 7 THEN @v2mpositiontaking_7 WHEN 8 THEN @v2mpositiontaking_8 WHEN 20 THEN @v2mpositiontaking_20 ELSE 0 END
					WHEN 3 THEN CASE bettype WHEN 1 THEN @v3mpositiontaking_1 WHEN 2 THEN @v3mpositiontaking_2 WHEN 3 THEN @v3mpositiontaking_3 WHEN 20 THEN @v3mpositiontaking_20 ELSE 0 END
					WHEN 5 THEN CASE bettype WHEN 1 THEN @v5mpositiontaking_1 WHEN 2 THEN @v5mpositiontaking_2 WHEN 3 THEN @v5mpositiontaking_3 WHEN 20 THEN @v5mpositiontaking_20 ELSE 0 END
					WHEN 8 THEN CASE bettype WHEN 1 THEN @v8mpositiontaking_1 WHEN 3 THEN @v8mpositiontaking_3 WHEN 20 THEN @v8mpositiontaking_20 ELSE 0 END
					WHEN 10 THEN CASE bettype WHEN 1 THEN @v10mpositiontaking_1 WHEN 2 THEN @v10mpositiontaking_2 WHEN 3 THEN @v10mpositiontaking_3 WHEN 20 THEN @v10mpositiontaking_20 ELSE 0 END
					WHEN 11 THEN CASE bettype WHEN 1 THEN @v11mpositiontaking_1 WHEN 20 THEN @v11mpositiontaking_20 ELSE 0 END
					WHEN 99 THEN CASE bettype WHEN 1 THEN @v99mpositiontaking_1 WHEN 2 THEN @v99mpositiontaking_2 WHEN 3 THEN @v99mpositiontaking_3 WHEN 9 THEN @v99mpositiontaking_9 WHEN 20 THEN @v99mpositiontaking_20 ELSE 0 END
					WHEN 154 THEN CASE bettype WHEN 20 THEN @v154mpositiontaking_20 ELSE 0 END										
					ELSE mpositiontaking END END,
	mlivepositiontaking = CASE WHEN ( @UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0) OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0))) THEN mlivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @mlivepositiontaking_1 WHEN 3 THEN @mlivepositiontaking_3 WHEN 7 THEN @mlivepositiontaking_7 WHEN 8 THEN @mlivepositiontaking_8 ELSE mlivepositiontaking END ELSE mlivepositiontaking END END,
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	spositiontaking = CASE WHEN (@UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0)  OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND bettype<>9  AND  @UpdatePositiontakingv99 = 0) OR (sporttype=99 AND bettype=9  AND  @UpdatePositiontakingv99MP = 0) )) THEN spositiontaking ELSE CASE sporttype WHEN 1 THEN CASE bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
					WHEN 2 THEN CASE bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8 WHEN 20 THEN @v2spositiontaking_20 ELSE 0 END
					WHEN 3 THEN CASE bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
					WHEN 5 THEN CASE bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
					WHEN 8 THEN CASE bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
					WHEN 10 THEN CASE bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
					WHEN 11 THEN CASE bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
					WHEN 99 THEN CASE bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9  WHEN 20 THEN @v99spositiontaking_20 ELSE 0 END
					WHEN 154 THEN CASE bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END
					ELSE spositiontaking END END,
	slivepositiontaking = CASE WHEN ( @UpdateMultiple = 1 AND ((sporttype=1 AND @UpdatePositiontaking = 0) OR (sporttype=2 AND @UpdatePositiontakingv2 = 0) OR (sporttype=3 AND @UpdatePositiontakingv3 = 0) OR (sporttype=5 AND @UpdatePositiontakingv5 = 0) OR (sporttype=8 AND @UpdatePositiontakingv8 = 0) OR (sporttype=10 AND @UpdatePositiontakingv10 = 0) OR (sporttype=11 AND @UpdatePositiontakingv11 = 0) OR (sporttype=99 AND @UpdatePositiontakingv99 = 0))) THEN slivepositiontaking ELSE CASE sporttype 	WHEN 1 THEN CASE bettype WHEN 1 THEN @slivepositiontaking_1 WHEN 3 THEN @slivepositiontaking_3 WHEN 7 THEN @slivepositiontaking_7 WHEN 8 THEN @slivepositiontaking_8 ELSE slivepositiontaking END ELSE slivepositiontaking END END
WHERE custid=@custid

--v161
IF (@UpdateMultiple=0 OR @UpdatePositiontakingv161=1)
BEGIN	
	
	UPDATE custsetting3rd WITH (ROWLOCK, UPDLOCK)
	SET 
		apositiontaking = CASE bettype 
						WHEN 81 then @v161apositiontaking_81
						WHEN 83 then @v161apositiontaking_83
						WHEN 86 then @v161apositiontaking_86
						WHEN 88 then @v161apositiontaking_88
						ELSE 0
						END,
		alivepositiontaking = CASE bettype
						WHEN 85 then @v161alivepositiontaking_85
						WHEN 86 then @v161alivepositiontaking_86
						WHEN 87 then @v161alivepositiontaking_87 
						WHEN 89 then @v161alivepositiontaking_89
						WHEN 90 then @v161alivepositiontaking_90
						ELSE 0
						END,
		mpositiontaking = CASE bettype 
						WHEN 81 then @v161mpositiontaking_81
						WHEN 83 then @v161mpositiontaking_83
						WHEN 86 then @v161mpositiontaking_86
						WHEN 88 then @v161mpositiontaking_88
						ELSE 0
						END, 
		mlivepositiontaking = CASE bettype
						WHEN 85 then @v161mlivepositiontaking_85
						WHEN 86 then @v161mlivepositiontaking_86
						WHEN 87 then @v161mlivepositiontaking_87 
						WHEN 89 then @v161mlivepositiontaking_89
						WHEN 90 then @v161mlivepositiontaking_90
						ELSE 0
						END,
		spositiontaking = CASE bettype 
						WHEN 81 then @v161spositiontaking_81
						WHEN 83 then @v161spositiontaking_83
						WHEN 86 then @v161spositiontaking_86
						WHEN 88 then @v161spositiontaking_88
						ELSE 0
						 END,
		slivepositiontaking = CASE bettype
						WHEN 85 then @v161slivepositiontaking_85
						WHEN 86 then @v161slivepositiontaking_86
						WHEN 87 then @v161slivepositiontaking_87 
						WHEN 89 then @v161slivepositiontaking_89
						WHEN 90 then @v161slivepositiontaking_90
						ELSE 0
						END			
	WHERE custid = @custid AND sporttype = 161
END


EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

COMMIT TRANSACTION
*/

SELECT 
	@apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_1 ELSE @apositiontaking_1 END,
	@apositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_2 ELSE @apositiontaking_2 END,
	@apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_3 ELSE @apositiontaking_3 END,
	@apositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_4 ELSE @apositiontaking_4 END,
	@apositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_5 ELSE @apositiontaking_5 END,
	@apositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_6 ELSE @apositiontaking_6 END,
	@apositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_7 ELSE @apositiontaking_7 END,
	@apositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_8 ELSE @apositiontaking_8 END,
	@apositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_9 ELSE @apositiontaking_9 END,
	@apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_10 ELSE @apositiontaking_10 END,
	
	-- Outright PT for sports
	@v2apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_10 ELSE @v2apositiontaking_10 END,
	@v3apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_10 ELSE @v3apositiontaking_10 END,
	@v5apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_10 ELSE @v5apositiontaking_10 END,
	@v8apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_10 ELSE @v8apositiontaking_10 END,
	@v10apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_10 ELSE @v10apositiontaking_10 END,
	@v11apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11apositiontaking_10 ELSE @v11apositiontaking_10 END,
	@v99apositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_10 ELSE @v99apositiontaking_10 END,
	
	
	@apositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_9999 ELSE @apositiontaking_9999 END,
	
	@alivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_1 ELSE @alivepositiontaking_1 END,
	@alivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_3 ELSE @alivepositiontaking_3 END,
	@alivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_7 ELSE @alivepositiontaking_7 END,
	@alivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_8 ELSE @alivepositiontaking_8 END,
	
	@v2apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_1 ELSE @v2apositiontaking_1 END,
	@v2apositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_2 ELSE @v2apositiontaking_2 END,
	@v2apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_3 ELSE @v2apositiontaking_3 END,
	@v2apositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_7 ELSE @v2apositiontaking_7 END,
	@v2apositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_8 ELSE @v2apositiontaking_8 END,	
	@v2apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_20 ELSE @v2apositiontaking_20 END,
	
	@v3apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_1 ELSE @v3apositiontaking_1 END,
	@v3apositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_2 ELSE @v3apositiontaking_2 END,
	@v3apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_3 ELSE @v3apositiontaking_3 END,
	@v3apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_20 ELSE @v3apositiontaking_20 END,

	@v5apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_1 ELSE @v5apositiontaking_1 END,
	@v5apositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_2 ELSE @v5apositiontaking_2 END,
	@v5apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_3 ELSE @v5apositiontaking_3 END,
	@v5apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_20 ELSE @v5apositiontaking_20 END,
	@v5apositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_9999 ELSE @v5apositiontaking_9999 END,

	@v8apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_1 ELSE @v8apositiontaking_1 END,
	@v8apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_3 ELSE @v8apositiontaking_3 END,
	@v8apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_20 ELSE @v8apositiontaking_20 END,

	@v10apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_1 ELSE @v10apositiontaking_1 END,
	@v10apositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_2 ELSE @v10apositiontaking_2 END,
	@v10apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_3 ELSE @v10apositiontaking_3 END,
	@v10apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_20 ELSE @v10apositiontaking_20 END,

	@v11apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11apositiontaking_1 ELSE @v11apositiontaking_1 END,
	@v11apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11apositiontaking_20 ELSE @v11apositiontaking_20 END,

	@v99apositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_1 ELSE @v99apositiontaking_1 END,
	@v99apositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_2 ELSE @v99apositiontaking_2 END,
	@v99apositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_3 ELSE @v99apositiontaking_3 END,	
	@v99apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_20 ELSE @v99apositiontaking_20 END,
	
	@v99apositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @Old_v99apositiontaking_9 ELSE @v99apositiontaking_9 END,
	
	@v154apositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @Old_v154apositiontaking_20 ELSE @v154apositiontaking_20 END,
		
	--v161
	@v161apositiontaking_81 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_81 ELSE @v161apositiontaking_81 END,
	@v161apositiontaking_83 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_83 ELSE @v161apositiontaking_83 END,
	@v161apositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_86 ELSE @v161apositiontaking_86 END,
	@v161apositiontaking_88 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_88 ELSE @v161apositiontaking_88 END,
	@v161alivepositiontaking_85 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_85 ELSE @v161alivepositiontaking_85 END,
	@v161alivepositiontaking_86 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_86 ELSE @v161alivepositiontaking_86 END,
	@v161alivepositiontaking_87 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_87 ELSE @v161alivepositiontaking_87 END,
	@v161alivepositiontaking_89 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_89 ELSE @v161alivepositiontaking_89 END,
	@v161alivepositiontaking_90 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_90 ELSE @v161alivepositiontaking_90 END


Declare @LogSPData varchar(MAX)
Declare @TrackingValue2 varchar(MAX)

Select @LogSPData = '<Acc_CustomerUpdMember_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
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
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(8000)),space(1)) + '" />' +

'<ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'v2apt_10="'+ coalesce(cast(@v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3apt_10="'+ coalesce(cast(@v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5apt_10="'+ coalesce(cast(@v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8apt_10="'+ coalesce(cast(@v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10apt_10="'+ coalesce(cast(@v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11apt_10="'+ coalesce(cast(@v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99apt_10="'+ coalesce(cast(@v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +

'apt_9999="'+ coalesce(cast(@apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2apt_1="'+ coalesce(cast(@v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2apt_2="'+ coalesce(cast(@v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2apt_3="'+ coalesce(cast(@v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2apt_7="'+ coalesce(cast(@v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2apt_8="'+ coalesce(cast(@v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2apt_20="'+ coalesce(cast(@v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3apt_1="'+ coalesce(cast(@v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3apt_2="'+ coalesce(cast(@v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3apt_3="'+ coalesce(cast(@v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3apt_20="'+ coalesce(cast(@v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5apt_1="'+ coalesce(cast(@v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5apt_2="'+ coalesce(cast(@v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5apt_3="'+ coalesce(cast(@v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5apt_20="'+ coalesce(cast(@v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5apt_9999="'+ coalesce(cast(@v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10apt_1="'+ coalesce(cast(@v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10apt_2="'+ coalesce(cast(@v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10apt_3="'+ coalesce(cast(@v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10apt_20="'+ coalesce(cast(@v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11apt_1="'+ coalesce(cast(@v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11apt_20="'+ coalesce(cast(@v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99apt_1="'+ coalesce(cast(@v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99apt_2="'+ coalesce(cast(@v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99apt_3="'+ coalesce(cast(@v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v154apt_20="'+ coalesce(cast(@v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_PositionTaking>'

Select @TrackingValue2 = '<Acc_CustomerUpdMember_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
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
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(8000)),space(1)) + '" />' +

'<ag apt_1="'+ coalesce(cast(@Old_apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@Old_apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@Old_apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@Old_apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@Old_apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@Old_apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@Old_apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@Old_apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@Old_apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@Old_apositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'v2apt_10="'+ coalesce(cast(@Old_v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3apt_10="'+ coalesce(cast(@Old_v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5apt_10="'+ coalesce(cast(@Old_v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8apt_10="'+ coalesce(cast(@Old_v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10apt_10="'+ coalesce(cast(@Old_v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11apt_10="'+ coalesce(cast(@Old_v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99apt_10="'+ coalesce(cast(@Old_v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +

'apt_9999="'+ coalesce(cast(@Old_apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@Old_alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@Old_alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@Old_alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@Old_alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2apt_1="'+ coalesce(cast(@Old_v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2apt_2="'+ coalesce(cast(@Old_v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2apt_3="'+ coalesce(cast(@Old_v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2apt_7="'+ coalesce(cast(@Old_v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2apt_8="'+ coalesce(cast(@Old_v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'v2apt_20="'+ coalesce(cast(@Old_v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3apt_1="'+ coalesce(cast(@Old_v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3apt_2="'+ coalesce(cast(@Old_v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3apt_3="'+ coalesce(cast(@Old_v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3apt_20="'+ coalesce(cast(@Old_v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5apt_1="'+ coalesce(cast(@Old_v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5apt_2="'+ coalesce(cast(@Old_v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5apt_3="'+ coalesce(cast(@Old_v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5apt_20="'+ coalesce(cast(@Old_v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5apt_9999="'+ coalesce(cast(@Old_v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8apt_1="'+ coalesce(cast(@Old_v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@Old_v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@Old_v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10apt_1="'+ coalesce(cast(@Old_v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10apt_2="'+ coalesce(cast(@Old_v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10apt_3="'+ coalesce(cast(@Old_v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10apt_20="'+ coalesce(cast(@Old_v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11apt_1="'+ coalesce(cast(@Old_v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11apt_20="'+ coalesce(cast(@Old_v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99apt_1="'+ coalesce(cast(@Old_v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99apt_2="'+ coalesce(cast(@Old_v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99apt_3="'+ coalesce(cast(@Old_v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99apt_9="'+ coalesce(cast(@Old_v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v99apt_20="'+ coalesce(cast(@Old_v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v154apt_20="'+ coalesce(cast(@Old_v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v161apt_81="'+ coalesce(cast(@Old_v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@Old_v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@Old_v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@Old_v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
'v161alivept_85="'+ coalesce(cast(@Old_v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@Old_v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@Old_v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161alivept_89="'+ coalesce(cast(@Old_v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@Old_v161alivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_PositionTaking>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 413,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdMember_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
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
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(8000)),space(1)) + '" />' +

	'<ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'v2apt_10="'+ coalesce(cast(@v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v3apt_10="'+ coalesce(cast(@v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v5apt_10="'+ coalesce(cast(@v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v8apt_10="'+ coalesce(cast(@v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v10apt_10="'+ coalesce(cast(@v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v11apt_10="'+ coalesce(cast(@v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v99apt_10="'+ coalesce(cast(@v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'apt_9999="'+ coalesce(cast(@apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2apt_1="'+ coalesce(cast(@v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2apt_2="'+ coalesce(cast(@v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2apt_3="'+ coalesce(cast(@v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2apt_7="'+ coalesce(cast(@v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2apt_8="'+ coalesce(cast(@v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2apt_20="'+ coalesce(cast(@v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3apt_1="'+ coalesce(cast(@v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3apt_2="'+ coalesce(cast(@v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3apt_3="'+ coalesce(cast(@v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3apt_20="'+ coalesce(cast(@v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5apt_1="'+ coalesce(cast(@v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5apt_2="'+ coalesce(cast(@v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5apt_3="'+ coalesce(cast(@v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5apt_20="'+ coalesce(cast(@v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v5apt_9999="'+ coalesce(cast(@v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	'v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10apt_1="'+ coalesce(cast(@v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10apt_2="'+ coalesce(cast(@v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10apt_3="'+ coalesce(cast(@v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10apt_20="'+ coalesce(cast(@v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11apt_1="'+ coalesce(cast(@v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11apt_20="'+ coalesce(cast(@v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99apt_1="'+ coalesce(cast(@v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99apt_2="'+ coalesce(cast(@v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99apt_3="'+ coalesce(cast(@v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v154apt_20="'+ coalesce(cast(@v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +	
	'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
	'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_PositionTaking>'

	Select @TrackingValue2 = '<Acc_CustomerUpdMember_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
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
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(8000)),space(1)) + '" />' +

	'<ag apt_1="'+ coalesce(cast(@Old_apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'apt_2="'+ coalesce(cast(@Old_apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'apt_3="'+ coalesce(cast(@Old_apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'apt_4="'+ coalesce(cast(@Old_apositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'apt_5="'+ coalesce(cast(@Old_apositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'apt_6="'+ coalesce(cast(@Old_apositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'apt_7="'+ coalesce(cast(@Old_apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'apt_8="'+ coalesce(cast(@Old_apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'apt_9="'+ coalesce(cast(@Old_apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'apt_10="'+ coalesce(cast(@Old_apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	-- Outright PT for sports
	'v2apt_10="'+ coalesce(cast(@Old_v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v3apt_10="'+ coalesce(cast(@Old_v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v5apt_10="'+ coalesce(cast(@Old_v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v8apt_10="'+ coalesce(cast(@Old_v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v10apt_10="'+ coalesce(cast(@Old_v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v11apt_10="'+ coalesce(cast(@Old_v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v99apt_10="'+ coalesce(cast(@Old_v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'apt_9999="'+ coalesce(cast(@Old_apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'alivept_1="'+ coalesce(cast(@Old_alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'alivept_3="'+ coalesce(cast(@Old_alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'alivept_7="'+ coalesce(cast(@Old_alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'alivept_8="'+ coalesce(cast(@Old_alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2apt_1="'+ coalesce(cast(@Old_v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2apt_2="'+ coalesce(cast(@Old_v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2apt_3="'+ coalesce(cast(@Old_v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2apt_7="'+ coalesce(cast(@Old_v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2apt_8="'+ coalesce(cast(@Old_v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'v2apt_20="'+ coalesce(cast(@Old_v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3apt_1="'+ coalesce(cast(@Old_v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3apt_2="'+ coalesce(cast(@Old_v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3apt_3="'+ coalesce(cast(@Old_v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3apt_20="'+ coalesce(cast(@Old_v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5apt_1="'+ coalesce(cast(@Old_v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5apt_2="'+ coalesce(cast(@Old_v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5apt_3="'+ coalesce(cast(@Old_v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5apt_20="'+ coalesce(cast(@Old_v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v5apt_9999="'+ coalesce(cast(@Old_v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	'v8apt_1="'+ coalesce(cast(@Old_v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8apt_3="'+ coalesce(cast(@Old_v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8apt_20="'+ coalesce(cast(@Old_v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10apt_1="'+ coalesce(cast(@Old_v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10apt_2="'+ coalesce(cast(@Old_v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10apt_3="'+ coalesce(cast(@Old_v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10apt_20="'+ coalesce(cast(@Old_v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11apt_1="'+ coalesce(cast(@Old_v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11apt_20="'+ coalesce(cast(@Old_v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99apt_1="'+ coalesce(cast(@Old_v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99apt_2="'+ coalesce(cast(@Old_v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99apt_3="'+ coalesce(cast(@Old_v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99apt_9="'+ coalesce(cast(@Old_v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v99apt_20="'+ coalesce(cast(@Old_v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v154apt_20="'+ coalesce(cast(@Old_v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +	
	'v161apt_81="'+ coalesce(cast(@Old_v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161apt_83="'+ coalesce(cast(@Old_v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
	'v161apt_86="'+ coalesce(cast(@Old_v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161apt_88="'+ coalesce(cast(@Old_v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +
	'v161alivept_85="'+ coalesce(cast(@Old_v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161alivept_86="'+ coalesce(cast(@Old_v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161alivept_87="'+ coalesce(cast(@Old_v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161alivept_89="'+ coalesce(cast(@Old_v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161alivept_90="'+ coalesce(cast(@Old_v161alivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_PositionTaking>'

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 413,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
END CATCH
