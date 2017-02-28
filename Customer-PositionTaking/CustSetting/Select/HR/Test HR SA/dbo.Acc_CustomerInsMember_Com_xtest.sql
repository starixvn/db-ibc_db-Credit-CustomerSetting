
CREATE PROCEDURE [dbo].[Acc_CustomerInsMember_Com_xtest]

	@custid int OUTPUT,
	@firstname nvarchar(50),
	@lastname nvarchar(50),
	@address nvarchar(80),
	@postal nvarchar(50),
	@city nvarchar(50),
	@state nvarchar(50),
	@country nvarchar(50),
	@phone nvarchar(50),
	@mobilephone nvarchar(50),
	@email nvarchar(50) = '',
	@fax nvarchar(50),
	@refcode1 nvarchar(50),
	@creator int,
	@username varchar(30),
	@userpwd varchar(40),
	@site nvarchar(50),
	@currency int, 
	@credit money,
	@groupa decimal(9,8), 
	@groupb decimal(9,8), 
	@groupc decimal(9,8), 
	@groupd decimal(9,8),
	@discountcs decimal(9,8)=0, 
	--comm 1x2
	@discount1x2 decimal(9,8)=0,
	
	@discountnumber decimal(9,8)=0,
	@isinternal bit = 0,

	@MinBet money,
	@MaxBet money,
	@MaxPerMatch money,
	
	@MinBetv2 money,
	@MaxBetv2 money,
	@MaxPerMatchv2 money,
	
	@MinBetv3 money,
	@MaxBetv3 money,
	@MaxPerMatchv3 money,

	@MinBetv5 money,
	@MaxBetv5 money,
	@MaxPerMatchv5 money,

	@MinBetv8 money,
	@MaxBetv8 money,
	@MaxPerMatchv8 money,

	@MinBetv10 money,
	@MaxBetv10 money,
	@MaxPerMatchv10 money,

	@MinBetv11 money,
	@MaxBetv11 money,
	@MaxPerMatchv11 money,

	@MinBetv99 money,
	@MaxBetv99 money,
	@MaxPerMatchv99 money,
	
	--Mix Parlay mix sports
	@MinBetv99MP money,
	@MaxBetv99MP money,
	@MaxPerMatchv99MP money,
	
	--Number game
	@MinBetv161 money,
	@MaxBetv161 money,
	@MaxPerMatchv161 money,

	@MaxPerBallv161 money = 0,
	
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
	
	@v3spositiontaking_1 smallmoney,
	@v3spositiontaking_2 smallmoney,
	@v3spositiontaking_3 smallmoney,
	@v3spositiontaking_20 smallmoney,

	@v5spositiontaking_1 smallmoney,
	@v5spositiontaking_2 smallmoney,
	@v5spositiontaking_3 smallmoney,
	@v5spositiontaking_20 smallmoney,

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
	
	
	
	--v161
	@v161spositiontaking_81 smallmoney,
	@v161spositiontaking_83 smallmoney,
	@v161spositiontaking_85 smallmoney,
	@v161spositiontaking_86 smallmoney,
	@v161slivepositiontaking_85 smallmoney,
	@v161slivepositiontaking_86 smallmoney,
	@v161slivepositiontaking_87 smallmoney,
	
	
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

	@v3mpositiontaking_1 smallmoney,
	@v3mpositiontaking_2 smallmoney,
	@v3mpositiontaking_3 smallmoney,
	@v3mpositiontaking_20 smallmoney,

	@v5mpositiontaking_1 smallmoney,
	@v5mpositiontaking_2 smallmoney,
	@v5mpositiontaking_3 smallmoney,
	@v5mpositiontaking_20 smallmoney,

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
	
	
	
	--v161
	@v161mpositiontaking_81 smallmoney,
	@v161mpositiontaking_83 smallmoney,
	@v161mpositiontaking_85 smallmoney,
	@v161mpositiontaking_86 smallmoney,
	@v161mlivepositiontaking_85 smallmoney,
	@v161mlivepositiontaking_86 smallmoney,
	@v161mlivepositiontaking_87 smallmoney,
	
	
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

	@v3apositiontaking_1 smallmoney,
	@v3apositiontaking_2 smallmoney,
	@v3apositiontaking_3 smallmoney,
	@v3apositiontaking_20 smallmoney,

	@v5apositiontaking_1 smallmoney,
	@v5apositiontaking_2 smallmoney,
	@v5apositiontaking_3 smallmoney,
	@v5apositiontaking_20 smallmoney,

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
	
	
	
	--v161
	@v161apositiontaking_81 smallmoney,
	@v161apositiontaking_83 smallmoney,
	@v161apositiontaking_85 smallmoney,
	@v161apositiontaking_86 smallmoney,
	@v161alivepositiontaking_85 smallmoney,
	@v161alivepositiontaking_86 smallmoney,
	@v161alivepositiontaking_87 smallmoney,
	
	
	@Disable151_31 bit = 0,-- @DisableHorseRacing -> @Disable151_31
	@Disable151_41 bit = 0,-- @DisableOpenTote -> @Disable151_41
	@Disable151_51 bit = 0,-- @Disable151_AU -> @Disable151_51
	@Disable152_41 bit = 0,-- @Disable152_UK -> @Disable152_41
	@Disable152_51 bit = 0,-- @Disable152_AU -> @Disable152_51
	@Disable153_51 bit = 0,-- @Disable153_AU -> @Disable153_51
	@DisableFinancial bit = 0,
	@DisableCasino bit = 0, 
	@DisableBingo bit = 0,
	@DisableNumber bit = 0,
	@IP varchar(15)='',
	@Language varchar(2)= 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(2000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090121@Thien
Task : Company create Super
DB: DBTRANS.bodb02
Original:

Revisions:
    - 20081021@Phuc: Add new sporttype 201, bettype 3,Hard code copy min/max/maxperbet/PT for sporttype 201 from 2 sporttype 
	- 20090122@PhuongBich: Add new sporttype 201, bettype 2.
	- 20090122@PhuongNguyen: Remove userpwd from log writing
	- 20090218@PhuongDao: Check username2 
	- 20090317@Phuc: disable Financial
    - 20090424@Phuc:Separate finance sporttype(201).
	- 20090514@PhuongDao: Add commission for 1x2  
    - 20090520@PhuongDao: Add default HR PT Tote and Fixed 
    - 20090521@PhuongDao: Remove HR input params of Min-Max BET and commission 
    - 20090525@Kiwi: not using Allowed HR currency from systemsetting table
    - 20090901@Shifu: Add IsInternal user option
    - 20090903@Simon: Write Credit Log into Userlog_Credit table.
	- 20090917@Phuc: write log into DBLOG.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100414@Kiwi: Remove to do not insert answer field.
	- 20100506@Huynguyen: Add param @DisableOpenTote
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20100828@Henry: remove mix parlay of basketball + add new section for MixParlay for Mix Sports + Setting for Numbergame
	- 20100909@Jamie: Add param @DisableCasino 
	- 20101019@Henry: Record execution time
	- 20101026@Lukas: add max per ball(number game)
	- 20101205@Henry: change the commision to use discountcs of Mix Sports Parlay instead of Group A/B/C/D
	-20103012@Johnson: Add setting for HR AU, Greyhound, Harness
Param's Explanation:
• @ErrCode:
    = 0: Create super successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON
declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()


declare @transcode bigint 
declare @isvalid bit
Select @ErrCode = 0
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC dbo.Acc_CustomerInsMember_Com_CheckParam 
			@custid = @custid OUTPUT,
			@currency = @currency,
			@credit = @credit,
			@groupa = @groupa,
			@groupb = @groupb,
			@groupc = @groupc,
			@groupd = @groupd,
			@discountcs = @discountcs,	
			@discount1x2 = @discount1x2, --1x2		
			@discountnumber = @discountnumber, --Number Game
			
			@MinBet = @MinBet,
			@MaxBet = @MaxBet,
			@MaxPerMatch = @MaxPerMatch,
			@MinBetv2 = @MinBetv2,
			@MaxBetv2 = @MaxBetv2,
			@MaxPerMatchv2 = @MaxPerMatchv2,
			@MinBetv3 = @MinBetv3,
			@MaxBetv3 = @MaxBetv3,
			@MaxPerMatchv3 = @MaxPerMatchv3,
			@MinBetv5 = @MinBetv5,
			@MaxBetv5 = @MaxBetv5,
			@MaxPerMatchv5 = @MaxPerMatchv5,
			@MinBetv8 = @MinBetv8,
			@MaxBetv8 = @MaxBetv8,
			@MaxPerMatchv8 = @MaxPerMatchv8,
			@MinBetv10 = @MinBetv10,
			@MaxBetv10 = @MaxBetv10,
			@MaxPerMatchv10 = @MaxPerMatchv10,
			@MinBetv11 = @MinBetv11,
			@MaxBetv11 = @MaxBetv11,
			@MaxPerMatchv11 = @MaxPerMatchv11,

			@MinBetv99 = @MinBetv99,
			@MaxBetv99 = @MaxBetv99,
			@MaxPerMatchv99 = @MaxPerMatchv99,
			
			--Mix Parlay mix sports
			@MinBetv99MP = @MinBetv99MP,
			@MaxBetv99MP = @MaxBetv99MP,
			@MaxPerMatchv99MP = @MaxPerMatchv99MP,
			
			--Number game
			@MinBetv161 = @MinBetv161,
			@MaxBetv161 = @MaxBetv161,
			@MaxPerMatchv161 = @MaxPerMatchv161,

			@MaxPerBallv161 = @MaxPerBallv161,
			
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
			@slivepositiontaking_1 = @slivepositiontaking_1,
			@slivepositiontaking_3 = @slivepositiontaking_3,
			@slivepositiontaking_7 = @slivepositiontaking_7,
			@slivepositiontaking_8 = @slivepositiontaking_8,
			@v2spositiontaking_1 = @v2spositiontaking_1,
			@v2spositiontaking_2 = @v2spositiontaking_2,
			@v2spositiontaking_3 = @v2spositiontaking_3,
			@v2spositiontaking_7 = @v2spositiontaking_7,
			@v2spositiontaking_8 = @v2spositiontaking_8,
			--@v2spositiontaking_9 = @v2spositiontaking_9,
			@v2spositiontaking_20 = @v2spositiontaking_20,

			@v3spositiontaking_1 = @v3spositiontaking_1,
			@v3spositiontaking_2 = @v3spositiontaking_2,
			@v3spositiontaking_3 = @v3spositiontaking_3,
			@v3spositiontaking_20 = @v3spositiontaking_20,
			@v5spositiontaking_1 = @v5spositiontaking_1,
			@v5spositiontaking_2 = @v5spositiontaking_2,
			@v5spositiontaking_3 = @v5spositiontaking_3,
			@v5spositiontaking_20 = @v5spositiontaking_20,
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
			@v99spositiontaking_9 = @v99spositiontaking_9,
			@v99spositiontaking_20 = @v99spositiontaking_20,
			
			
			
			
			--v161
			@v161spositiontaking_81 = @v161spositiontaking_81,
			@v161spositiontaking_83 = @v161spositiontaking_83,
			@v161spositiontaking_85 = @v161spositiontaking_85,
			@v161spositiontaking_86 = @v161spositiontaking_86,
			@v161slivepositiontaking_85 = @v161slivepositiontaking_85,
			@v161slivepositiontaking_86 = @v161slivepositiontaking_86,
			@v161slivepositiontaking_87 = @v161slivepositiontaking_87,
			
			
			
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
			@mlivepositiontaking_1 = @mlivepositiontaking_1,
			@mlivepositiontaking_3 = @mlivepositiontaking_3,
			@mlivepositiontaking_7 = @mlivepositiontaking_7,
			@mlivepositiontaking_8 = @mlivepositiontaking_8,
			@v2mpositiontaking_1 = @v2mpositiontaking_1,
			@v2mpositiontaking_2 = @v2mpositiontaking_2,
			@v2mpositiontaking_3 = @v2mpositiontaking_3,
			@v2mpositiontaking_7 = @v2mpositiontaking_7,
			@v2mpositiontaking_8 = @v2mpositiontaking_8,
			--@v2mpositiontaking_9 = @v2mpositiontaking_9,
			@v2mpositiontaking_20 = @v2mpositiontaking_20,

			@v3mpositiontaking_1 = @v3mpositiontaking_1,
			@v3mpositiontaking_2 = @v3mpositiontaking_2,
			@v3mpositiontaking_3 = @v3mpositiontaking_3,
			@v3mpositiontaking_20 = @v3mpositiontaking_20,
			@v5mpositiontaking_1 = @v5mpositiontaking_1,
			@v5mpositiontaking_2 = @v5mpositiontaking_2,
			@v5mpositiontaking_3 = @v5mpositiontaking_3,
			@v5mpositiontaking_20 = @v5mpositiontaking_20,
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
			@v99mpositiontaking_9 = @v99mpositiontaking_9,
			@v99mpositiontaking_20 = @v99mpositiontaking_20,
			
			
			
			
			--v161
			@v161mpositiontaking_81 = @v161mpositiontaking_81,
			@v161mpositiontaking_83 = @v161mpositiontaking_83,
			@v161mpositiontaking_85 = @v161mpositiontaking_85,
			@v161mpositiontaking_86 = @v161mpositiontaking_86,
			@v161mlivepositiontaking_85 = @v161mlivepositiontaking_85,
			@v161mlivepositiontaking_86 = @v161mlivepositiontaking_86,
			@v161mlivepositiontaking_87 = @v161mlivepositiontaking_87,
			
			
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
			
			--v161
			@v161apositiontaking_81 = @v161apositiontaking_81,
			@v161apositiontaking_83 = @v161apositiontaking_83,
			@v161apositiontaking_85 = @v161apositiontaking_85,
			@v161apositiontaking_86 = @v161apositiontaking_86,
			@v161alivepositiontaking_85 = @v161alivepositiontaking_85,
			@v161alivepositiontaking_86 = @v161alivepositiontaking_86,
			@v161alivepositiontaking_87 = @v161alivepositiontaking_87,
			
			
			@isvalid = @isvalid OUTPUT,
			@errmsg = @errmsg OUTPUT,
			@errcode = @errcode OUTPUT,
			@language = @language

if @ErrCode <> 0
BEGIN	
	return
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if exists(select 1 from customer with (NOLOCK) where username= @username)
	or exists (select 1 from customer with (NOLOCK) where username2 = @username)
	or exists(select 1 from custsub with (NOLOCK) where username= @username)
BEGIN
	Select @ErrMsg = case @Language 
						when 'E' then 'This username is not available.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](40001,@Language)
					end
	select @ErrCode = 101		
	return
END

--check for allow play horseracing
DECLARE @IsAllowedHR BIT
EXEC Acc_CheckHRAllowedCurrency_xtest
	@CurrencyID = @currency,
	@Allowed = @IsAllowedHR OUTPUT
IF @IsAllowedHR = 0 
	SELECT @Disable151_31 = 1
	
--Insert general info
EXEC dbo.Acc_CustomerInsUserInfo 
	@custid = @custid OUTPUT,
	@firstname = @firstname,
	@lastname = @lastname,
	@creator = @creator,
	@username = @username,
	@userpwd = @userpwd,
	@pwdexpiry = null,
	@currency = @currency,
	@site = @site,
	@srecommend = 0,
	@mrecommend = 0,
	@recommend = 0,
	@roleid = 4,
	@phone = @phone,
	@mobilephone = @mobilephone,
	@email = @email,
	@fax = @fax,
	@address = @address,
	@city = @city,
	@state = @state,
	@country = @country,
	@postal = @postal,
	@TransferOption = null,
	@suspended = 0,
	@Disable151_31 = @Disable151_31,
	@Disable151_41 = @Disable151_41,
	@Disable151_51 = @Disable151_51,
	@Disable152_41 = @Disable152_41,
	@Disable152_51 = @Disable152_51,
	@Disable153_51 = @Disable153_51,
	@matchlimit = 1,
	@virtualmultiplier = 1,
	@DisableFinancial = @DisableFinancial,
	@DisableBingo = @DisableBingo,
	@DisableNumber = @DisableNumber,
	@DisableCasino = @DisableCasino,
	@MaxPerMatch = @MaxPerMatch,
	@MaxPerMatchv2 = @MaxPerMatchv2,
	@MaxPerMatchv3 = @MaxPerMatchv3,
	@MaxPerMatchv5 = @MaxPerMatchv5,
	@MaxPerMatchv8 = @MaxPerMatchv8,
	@MaxPerMatchv10 = @MaxPerMatchv10,
	@MaxPerMatchv11 = @MaxPerMatchv11,
	@MaxPerMatchv99 = @MaxPerMatchv99,
	@MaxPerMatchv99MP = @MaxPerMatchv99MP,
	@MaxPerMatchv161 = @MaxPerMatchv161,
	@MaxPerBallv161 = @MaxPerBallv161,
	@credit = @credit,
	@maxcredit = null,
	@IP = @IP,
	@isinternal = @isinternal,
	@TransferOption_dec = null,
	@Language = @Language,
	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT
--Error occurs
IF @ErrCode <> 0
	return
	
INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], [MinBet], [MaxBet], autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking)
		select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1, @spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0

--1x2
UNION ALL	select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, 0, 0, 0, @discount1x2, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0

UNION ALL	select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0
UNION ALL	select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0

UNION ALL	select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL	select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL	select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL	select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL	select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
--UNION ALL	select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0
UNION ALL	select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0

UNION ALL	select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
UNION ALL	select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
UNION ALL	select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0
UNION ALL	select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0

UNION ALL	select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
UNION ALL	select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
UNION ALL	select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0
UNION ALL	select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0

UNION ALL	select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0
UNION ALL	select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0
UNION ALL	select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0

UNION ALL	select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
UNION ALL	select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
UNION ALL	select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0
UNION ALL	select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0

UNION ALL	select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0
UNION ALL	select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0

UNION ALL	select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
UNION ALL	select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
UNION ALL	select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
UNION ALL	select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0
--Mix Sports Parlay
UNION ALL	select @custid, 9, 99, @v99apositiontaking_9, @v99mpositiontaking_9, @v99spositiontaking_9, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv99MP, @MaxBetv99MP, 0, 0, 0, 0


if @@Error <> 0
BEGIN
	--Error Occurs
	
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			, @ErrCode=116
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

--insert into CustSetting3rd
INSERT INTO [dbo].[CustSetting3rd]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking],  [playerdiscount], [discount], [adiscount], [sdiscount], [MinBet], [MaxBet], autopositiontaking, isautopositiontaking, alivepositiontaking, mlivepositiontaking, slivepositiontaking, autolivepositiontaking, isautolivepositiontaking)
			select @custid, 2, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 3, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v151
UNION ALL	select @custid, 31, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 32, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 41, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 42, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 51, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 52, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v152
UNION ALL	select @custid, 41, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 42, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 51, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 52, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v153
UNION ALL	select @custid, 51, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 52, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

--v161
UNION ALL	select @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, @v161spositiontaking_81, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, @v161spositiontaking_83, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, 0, 0, 0
UNION ALL	select @custid, 85, 161, @v161apositiontaking_85, @v161mpositiontaking_85, @v161spositiontaking_85, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_85, @v161mlivepositiontaking_85, @v161slivepositiontaking_85, 0, 0
UNION ALL	select @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, @v161spositiontaking_86, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_86, @v161mlivepositiontaking_86, @v161slivepositiontaking_86, 0, 0
UNION ALL	select @custid, 87, 161, 0, 0, 0, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_87, @v161mlivepositiontaking_87, @v161slivepositiontaking_87, 0, 0

if @@Error <> 0
BEGIN
	--Error Occurs
	
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			, @ErrCode=116
	
	-- ROLLBACK MANUALLY
	Delete custsetting with (ROWLOCK) where custid  =@custid
	Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
select @custid, 1, 1, 0, @spositiontaking_1, 0, @slivepositiontaking_1
UNION ALL select @custid, 3, 1, 0, @spositiontaking_3, 0, @slivepositiontaking_3
UNION ALL select @custid, 7, 1, 0, @spositiontaking_7, 0, @slivepositiontaking_7
UNION ALL select @custid, 8, 1, 0, @spositiontaking_8, 0, @slivepositiontaking_8
UNION ALL select @custid, 2, 1, 0, @spositiontaking_2, 0, 0.9
UNION ALL select @custid, 4, 1, 0, @spositiontaking_4, 0, 0.9
UNION ALL select @custid, 5, 1, 0, @spositiontaking_5, 0, 0.9
UNION ALL select @custid, 6, 1, 0, @spositiontaking_6, 0, 0.9
UNION ALL select @custid, 9, 1, 0, @spositiontaking_9, 0, 0.9
UNION ALL select @custid, 10, 1, 0, @spositiontaking_10, 0, 0.9

UNION ALL select @custid, 1, 2, 0, @v2spositiontaking_1, 0, 0.9
UNION ALL select @custid, 2, 2, 0, @v2spositiontaking_2, 0, 0.9
UNION ALL select @custid, 3, 2, 0, @v2spositiontaking_3, 0, 0.9
UNION ALL select @custid, 7, 2, 0, @v2spositiontaking_7, 0, 0.9
UNION ALL select @custid, 8, 2, 0, @v2spositiontaking_8, 0, 0.9
--UNION ALL select @custid, 9, 2, 0, @v2spositiontaking_9, 0, 0.9
UNION ALL select @custid, 20, 2, 0, @v2spositiontaking_20, 0, 0.9

UNION ALL select @custid, 1, 3, 0, @v3spositiontaking_1, 0, 0.9
UNION ALL select @custid, 2, 3, 0, @v3spositiontaking_2, 0, 0.9
UNION ALL select @custid, 3, 3, 0, @v3spositiontaking_3, 0, 0.9
UNION ALL select @custid, 20, 3, 0, @v3spositiontaking_20, 0, 0.9

UNION ALL select @custid, 1, 5, 0, @v5spositiontaking_1, 0, 0.9
UNION ALL select @custid, 2, 5, 0, @v5spositiontaking_2, 0, 0.9
UNION ALL select @custid, 3, 5, 0, @v5spositiontaking_3, 0, 0.9
UNION ALL select @custid, 20, 5, 0, @v5spositiontaking_20, 0, 0.9

UNION ALL select @custid, 1, 8, 0, @v8spositiontaking_1, 0, 0.9
UNION ALL select @custid, 3, 8, 0, @v8spositiontaking_3, 0, 0.9
UNION ALL select @custid, 20, 8, 0, @v8spositiontaking_20, 0, 0.9

UNION ALL select @custid, 1, 10, 0, @v10spositiontaking_1, 0, 0.9
UNION ALL select @custid, 2, 10, 0, @v10spositiontaking_2, 0, 0.9
UNION ALL select @custid, 3, 10, 0, @v10spositiontaking_3, 0, 0.9
UNION ALL select @custid, 20, 10, 0, @v10spositiontaking_20, 0, 0.9

UNION ALL select @custid, 1, 11, 0, @v11spositiontaking_1, 0, 0.9
UNION ALL select @custid, 20, 11, 0, @v11spositiontaking_20, 0, 0.9

UNION ALL select @custid, 1, 99, 0, @v99spositiontaking_1, 0, 0.9
UNION ALL select @custid, 2, 99, 0, @v99spositiontaking_2, 0, 0.9
UNION ALL select @custid, 3, 99, 0, @v99spositiontaking_3, 0, 0.9
UNION ALL select @custid, 9, 99, 0, @v99spositiontaking_9, 0, 0.9
UNION ALL select @custid, 20, 99, 0, @v99spositiontaking_20, 0, 0.9


if @@Error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			, @ErrCode=116
	
	-- ROLLBACK MANUALLY
	Delete [custoverride] with (ROWLOCK) where custid  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END

-- Insert Into CustOverride3rd
INSERT INTO [dbo].[CustOverride3rd]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking,minlivepositiontaking,maxlivepositiontaking)
select @custid, 2, 201, 0, 0.5, 0, 0.9
UNION ALL select @custid, 3, 201, 0, 0.5, 0, 0.9
--v151 
UNION ALL select @custid, 31, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 32, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 41, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 42, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 51, 151, 0, 0.5, 0, 0.9
UNION ALL select @custid, 52, 151, 0, 0.5, 0, 0.9
--v152
UNION ALL select @custid, 41, 152, 0, 0.5, 0, 0.9
UNION ALL select @custid, 42, 152, 0, 0.5, 0, 0.9
UNION ALL select @custid, 51, 152, 0, 0.5, 0, 0.9
UNION ALL select @custid, 52, 152, 0, 0.5, 0, 0.9
--v153
UNION ALL select @custid, 51, 153, 0, 0.5, 0, 0.9
UNION ALL select @custid, 52, 153, 0, 0.5, 0, 0.9
--v161
UNION ALL select @custid, 81, 161, 0, @v161spositiontaking_81, 0, 0.9
UNION ALL select @custid, 83, 161, 0, @v161spositiontaking_83, 0, 0.9
UNION ALL select @custid, 85, 161, 0, @v161spositiontaking_85, 0, @v161slivepositiontaking_85
UNION ALL select @custid, 86, 161, 0, @v161spositiontaking_86, 0, @v161slivepositiontaking_86
UNION ALL select @custid, 87, 161, 0, 0.9, 0, @v161slivepositiontaking_87

if @@Error <> 0
BEGIN
	--Error Occurs
	SELECT @ErrMsg = case @Language 
							when 'E' then 'Add customer fail. Please try again'
							when 'CS' then N'新增会员不成功，请重新尝试'
							when 'CT' then N'新增會員不成功,請重新再試'
							when 'TH' then N'เพิ่มรายการลูกค้าไม่สมบูรณ์ กรุณาทำรายการอีกครั้ง'
							when 'J' then N'Add customer fail. Please try again'
							when 'KO' then N'고객추가에 실패했습니다. 다시 시도해주시기 바랍니다.'
							else N'Add customer fail. Please try again'
						end	
			, @ErrCode=116
	
	-- ROLLBACK MANUALLY
	Delete [custoverride] with (ROWLOCK) where custid  =@custid
	Delete [CustOverride3rd] with (ROWLOCK) where custid  =@custid
	
	EXEC Acc_CustomerInsUserInfo_Rollback @CustID = @CustID
	return
END





set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

Declare @LogSPData varchar(4000)
--Write general info
Select @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +

'fname="'+ coalesce(cast(@firstname as varchar(100)),space(1)) + '" ' +
'lname="'+ coalesce(cast(@lastname as varchar(100)),space(1)) + '" ' +
'address="'+ coalesce(cast(@address as varchar(160)),space(1)) + '" ' +
'postal="'+ coalesce(cast(@postal as varchar(100)),space(1)) + '" ' +
'city="'+ coalesce(cast(@city as varchar(100)),space(1)) + '" ' +
'state="'+ coalesce(cast(@state as varchar(100)),space(1)) + '" ' +
'country="'+ coalesce(cast(@country as varchar(100)),space(1)) + '" ' +
'phone="'+ coalesce(cast(@phone as varchar(100)),space(1)) + '" ' +
'mphone="'+ coalesce(cast(@mobilephone as varchar(100)),space(1)) + '" ' +
'email="'+ coalesce(cast(@email as varchar(100)),space(1)) + '" ' +
'fax="'+ coalesce(cast(@fax as varchar(100)),space(1)) + '" ' +
'refcode1="'+ coalesce(cast(@refcode1 as varchar(100)),space(1)) + '" ' +
'creator="'+ coalesce(cast(@creator as varchar(50)),space(1)) + '" ' +
'username="'+ coalesce(cast(@username as varchar(20)),space(1)) + '" ' +
'site="'+ coalesce(cast(@site as varchar(100)),space(1)) + '" ' +
'currency="'+ coalesce(cast(@currency as varchar(50)),space(1)) + '" ' +
'credit="'+ coalesce(cast(@credit as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(4000)),space(1)) + '" />'
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 600,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
--Write commission log
Select @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'groupa="'+ coalesce(cast(@groupa as varchar(50)),space(1)) + '" ' +
'groupb="'+ coalesce(cast(@groupb as varchar(50)),space(1)) + '" ' +
'groupc="'+ coalesce(cast(@groupc as varchar(50)),space(1)) + '" ' +
'groupd="'+ coalesce(cast(@groupd as varchar(50)),space(1)) + '" ' +
'discountcs="'+ coalesce(cast(@discountcs as varchar(50)),space(1)) + '" ' +
'discount1x2="'+ coalesce(cast(@discount1x2 as varchar(50)),space(1)) + '" ' +
'discountnumber="'+ coalesce(cast(@discountnumber as varchar(50)),space(1)) + '" />'
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 200,
	@TrackingValue = @LogSPData,
	@duration = @duration

--Write status log
Select @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'disablehorseracing="'+ coalesce(cast(@Disable151_31 as varchar(1)),space(1)) + '" ' +
'disableOT="'+ coalesce(cast(@Disable151_41 as varchar(1)),space(1)) + '" ' +
'disable151_51="'+ coalesce(cast(@Disable151_51 as varchar(1)),space(1)) + '" ' +
'disable152_41="'+ coalesce(cast(@Disable152_41 as varchar(1)),space(1)) + '" ' +
'disable152_51="'+ coalesce(cast(@Disable152_51 as varchar(1)),space(1)) + '" ' +
'disable153_51="'+ coalesce(cast(@Disable153_51 as varchar(1)),space(1)) + '" ' +
'disablefinancial="'+ coalesce(cast(@disablefinancial as varchar(1)),space(1)) + '" ' +
'disableCasino="'+ coalesce(cast(@disableCasino as varchar(1)),space(1)) + '" ' +
'disablebingo="'+ coalesce(cast(@disablebingo as varchar(1)),space(1)) + '" ' +
'disablenumber="'+ coalesce(cast(@disablenumber as varchar(1)),space(1)) + '" ' +
'isinternal="'+ coalesce(cast(@isinternal as varchar(1)),space(1)) + '" />'
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 1100,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
--Write Bet setting log
Select @LogSPData = '<Acc_CustomerInsMember_Com custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
'MinBv2="'+ coalesce(cast(@MinBetv2 as varchar(50)),space(1)) + '" ' +
'MaxBv2="'+ coalesce(cast(@MaxBetv2 as varchar(50)),space(1)) + '" ' +
'MPMv2="'+ coalesce(cast(@MaxPerMatchv2 as varchar(50)),space(1)) + '" ' +
'MinBv3="'+ coalesce(cast(@MinBetv3 as varchar(50)),space(1)) + '" ' +
'MaxBv3="'+ coalesce(cast(@MaxBetv3 as varchar(50)),space(1)) + '" ' +
'MPMv3="'+ coalesce(cast(@MaxPerMatchv3 as varchar(50)),space(1)) + '" ' +
'MinBv5="'+ coalesce(cast(@MinBetv5 as varchar(50)),space(1)) + '" ' +
'MaxBv5="'+ coalesce(cast(@MaxBetv5 as varchar(50)),space(1)) + '" ' +
'MPMv5="'+ coalesce(cast(@MaxPerMatchv5 as varchar(50)),space(1)) + '" ' +
'MinBv8="'+ coalesce(cast(@MinBetv8 as varchar(50)),space(1)) + '" ' +
'MaxBv8="'+ coalesce(cast(@MaxBetv8 as varchar(50)),space(1)) + '" ' +
'MPMv8="'+ coalesce(cast(@MaxPerMatchv8 as varchar(50)),space(1)) + '" ' +
'MinBv10="'+ coalesce(cast(@MinBetv10 as varchar(50)),space(1)) + '" ' +
'MaxBv10="'+ coalesce(cast(@MaxBetv10 as varchar(50)),space(1)) + '" ' +
'MPMv10="'+ coalesce(cast(@MaxPerMatchv10 as varchar(50)),space(1)) + '" ' +
'MinBv11="'+ coalesce(cast(@MinBetv11 as varchar(50)),space(1)) + '" ' +
'MaxBv11="'+ coalesce(cast(@MaxBetv11 as varchar(50)),space(1)) + '" ' +
'MPMv11="'+ coalesce(cast(@MaxPerMatchv11 as varchar(50)),space(1)) + '" ' +
'MinBv99="'+ coalesce(cast(@MinBetv99 as varchar(50)),space(1)) + '" ' +
'MaxBv99="'+ coalesce(cast(@MaxBetv99 as varchar(50)),space(1)) + '" ' +
'MPMv99="'+ coalesce(cast(@MaxPerMatchv99 as varchar(50)),space(1)) + '" ' +
'MinBv99MP="'+ coalesce(cast(@MinBetv99MP as varchar(50)),space(1)) + '" ' +
'MaxBv99MP="'+ coalesce(cast(@MaxBetv99MP as varchar(50)),space(1)) + '" ' +
'MPMv99MP="'+ coalesce(cast(@MaxPerMatchv99MP as varchar(50)),space(1)) + '" ' +
'MinBv161="'+ coalesce(cast(@MinBetv161 as varchar(50)),space(1)) + '" ' +
'MaxBv161="'+ coalesce(cast(@MaxBetv161 as varchar(50)),space(1)) + '" ' +
'MPMv161="'+ coalesce(cast(@MaxPerMatchv161 as varchar(50)),space(1)) + '" ' +
'MPBv161="' + coalesce(cast(@MaxPerBallv161 as varchar(50)),space(1)) + '" />' 


EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 300,
	@TrackingValue = @LogSPData,
	@duration = @duration
	
-- Write Log Credit	
Declare @LogSPCredit varchar(200)
Select @LogSPCredit = 'UserName='+ coalesce(cast(@username as varchar(30)),space(1))
EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
	@UserID = @Creator,
	@CustID = @CustID,
	@Doing = @LogSPCredit,
	@NewValue = @credit,
	@IP = @IP,
	@ActionID = 1208
--Write PT log
Select @LogSPData = '<Acc_CustomerInsMember_Com><s spt_1="'+ coalesce(cast(@spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'spt_2="'+ coalesce(cast(@spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'spt_3="'+ coalesce(cast(@spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'spt_4="'+ coalesce(cast(@spositiontaking_4 as varchar(50)),space(1)) + '" ' +
'spt_5="'+ coalesce(cast(@spositiontaking_5 as varchar(50)),space(1)) + '" ' +
'spt_6="'+ coalesce(cast(@spositiontaking_6 as varchar(50)),space(1)) + '" ' +
'spt_7="'+ coalesce(cast(@spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'spt_8="'+ coalesce(cast(@spositiontaking_8 as varchar(50)),space(1)) + '" ' +
'spt_9="'+ coalesce(cast(@spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'spt_10="'+ coalesce(cast(@spositiontaking_10 as varchar(50)),space(1)) + '" ' +
'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161spt_85="'+ coalesce(cast(@v161spositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 as varchar(50)),space(1)) + '" />' +


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
'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" />' +


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

'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" /></Acc_CustomerInsMember_Com>' 


EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
	@UserID = @Creator,
	@CustID = @CustID,
	@ActionID = 400,
	@TrackingValue = @LogSPData,
	@duration = @duration




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_Com_xtest] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInsMember_Com_xtest] TO vnteam
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerInsMember_Com_xtest] TO [bodbExtAccNet]
 