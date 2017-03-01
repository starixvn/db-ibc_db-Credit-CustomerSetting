ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_Super] 
	@CustID INT,--memberid
	@Closed BIT,
	@disCasino BIT = 0,
	@UpdateClosed BIT = 0,
	@Suspended BIT = null,
	@updatesuspended BIT = 0,
	@DisabledFI BIT = 0,
	@spositiontaking_1 SMALLMONEY OUTPUT,
	@spositiontaking_2 SMALLMONEY OUTPUT,
	@spositiontaking_3 SMALLMONEY OUTPUT,
	@spositiontaking_4 SMALLMONEY OUTPUT,
	@spositiontaking_5 SMALLMONEY OUTPUT,
	@spositiontaking_6 SMALLMONEY OUTPUT,
	@spositiontaking_7 SMALLMONEY OUTPUT,
	@spositiontaking_8 SMALLMONEY OUTPUT,
	@spositiontaking_9 SMALLMONEY OUTPUT,
	@spositiontaking_10 SMALLMONEY OUTPUT,
	@spositiontaking_9999 SMALLMONEY  = 0 OUTPUT,
	
	@slivepositiontaking_1 SMALLMONEY OUTPUT,
	@slivepositiontaking_3 SMALLMONEY OUTPUT,
	@slivepositiontaking_7 SMALLMONEY OUTPUT,
	@slivepositiontaking_8 SMALLMONEY OUTPUT,
	
	@v2spositiontaking_1 SMALLMONEY OUTPUT,
	@v2spositiontaking_2 SMALLMONEY OUTPUT,
	@v2spositiontaking_3 SMALLMONEY OUTPUT,
	@v2spositiontaking_7 SMALLMONEY OUTPUT,
	@v2spositiontaking_8 SMALLMONEY OUTPUT,
--	@v2spositiontaking_9 SMALLMONEY OUTPUT,
	@v2spositiontaking_20 SMALLMONEY OUTPUT,

	@v3spositiontaking_1 SMALLMONEY OUTPUT,
	@v3spositiontaking_2 SMALLMONEY OUTPUT,
	@v3spositiontaking_3 SMALLMONEY OUTPUT,
	@v3spositiontaking_20 SMALLMONEY OUTPUT,

	@v5spositiontaking_1 SMALLMONEY OUTPUT,
	@v5spositiontaking_2 SMALLMONEY OUTPUT,
	@v5spositiontaking_3 SMALLMONEY OUTPUT,
	@v5spositiontaking_20 SMALLMONEY OUTPUT,
	@v5spositiontaking_9999 SMALLMONEY  = 0 OUTPUT,

	@v8spositiontaking_1 SMALLMONEY OUTPUT,
	@v8spositiontaking_3 SMALLMONEY OUTPUT,
	@v8spositiontaking_20 SMALLMONEY OUTPUT,

	@v10spositiontaking_1 SMALLMONEY OUTPUT,
	@v10spositiontaking_2 SMALLMONEY OUTPUT,
	@v10spositiontaking_3 SMALLMONEY OUTPUT,
	@v10spositiontaking_20 SMALLMONEY OUTPUT,

	@v11spositiontaking_1 SMALLMONEY OUTPUT,
	@v11spositiontaking_20 SMALLMONEY OUTPUT,

	--v151
	--@v151spositiontaking_31 SMALLMONEY OUTPUT,
	--@v151spositiontaking_32 SMALLMONEY OUTPUT,

	@v99spositiontaking_1 SMALLMONEY OUTPUT,
	@v99spositiontaking_2 SMALLMONEY OUTPUT,
	@v99spositiontaking_3 SMALLMONEY OUTPUT,
	@v99spositiontaking_20 SMALLMONEY OUTPUT,

	-- mixed sports
	@v99spositiontaking_9 SMALLMONEY = 0 OUTPUT,
	
	-- HR fixodds
	@v154spositiontaking_20 SMALLMONEY  = 0 OUTPUT,

	-- number game
	@v161spositiontaking_81 SMALLMONEY OUTPUT,
	@v161spositiontaking_83 SMALLMONEY OUTPUT,
	@v161spositiontaking_86 SMALLMONEY OUTPUT,
	@v161spositiontaking_88 SMALLMONEY = 0 OUTPUT,
	@v161slivepositiontaking_85 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_86 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_87 SMALLMONEY OUTPUT,
	@v161slivepositiontaking_89 SMALLMONEY = 0 OUTPUT,
	@v161slivepositiontaking_90 SMALLMONEY = 0 OUTPUT,
	
	
	@UserID int,
	
	@auto_spositiontaking_1 SMALLMONEY = 0,
	@auto_spositiontaking_2 SMALLMONEY = 0,
	@auto_spositiontaking_3 SMALLMONEY = 0,
	@auto_spositiontaking_4 SMALLMONEY = 0,
	@auto_spositiontaking_5 SMALLMONEY= 0,
	@auto_spositiontaking_6 SMALLMONEY = 0,
	@auto_spositiontaking_7 SMALLMONEY = 0,
	@auto_spositiontaking_8 SMALLMONEY = 0,
	@auto_spositiontaking_9 SMALLMONEY = 0,
	@auto_spositiontaking_10 SMALLMONEY = 0,
	@auto_spositiontaking_9999 SMALLMONEY = 0,
	
	@auto_slivepositiontaking_1 SMALLMONEY = 0,
	@auto_slivepositiontaking_3 SMALLMONEY = 0,
	@auto_slivepositiontaking_7 SMALLMONEY = 0,
	@auto_slivepositiontaking_8 SMALLMONEY = 0,
	
	@auto_v2spositiontaking_1 SMALLMONEY = 0,
	@auto_v2spositiontaking_2 SMALLMONEY = 0,
	@auto_v2spositiontaking_3 SMALLMONEY = 0,
	@auto_v2spositiontaking_7 SMALLMONEY = 0,
	@auto_v2spositiontaking_8 SMALLMONEY = 0,
--	@auto_v2spositiontaking_9 SMALLMONEY = 0,
	@auto_v2spositiontaking_20 SMALLMONEY = 0,

	@auto_v3spositiontaking_1 SMALLMONEY = 0,
	@auto_v3spositiontaking_2 SMALLMONEY = 0,
	@auto_v3spositiontaking_3 SMALLMONEY = 0,
	@auto_v3spositiontaking_20 SMALLMONEY = 0,

	@auto_v5spositiontaking_1 SMALLMONEY = 0,
	@auto_v5spositiontaking_2 SMALLMONEY = 0,
	@auto_v5spositiontaking_3 SMALLMONEY = 0,
	@auto_v5spositiontaking_20 SMALLMONEY = 0,
	@auto_v5spositiontaking_9999 SMALLMONEY = 0,

	@auto_v8spositiontaking_1 SMALLMONEY = 0,
	@auto_v8spositiontaking_3 SMALLMONEY = 0,
	@auto_v8spositiontaking_20 SMALLMONEY = 0,

	@auto_v10spositiontaking_1 SMALLMONEY = 0,
	@auto_v10spositiontaking_2 SMALLMONEY = 0,
	@auto_v10spositiontaking_3 SMALLMONEY = 0,
	@auto_v10spositiontaking_20 SMALLMONEY = 0,

	@auto_v11spositiontaking_1 SMALLMONEY = 0,
	@auto_v11spositiontaking_20 SMALLMONEY = 0,

	@auto_v99spositiontaking_1 SMALLMONEY = 0,
	@auto_v99spositiontaking_2 SMALLMONEY = 0,
	@auto_v99spositiontaking_3 SMALLMONEY = 0,
	@auto_v99spositiontaking_20 SMALLMONEY = 0,

	-- mixed sports
	@auto_v99spositiontaking_9 SMALLMONEY = 0,
		
	-- HR Fixodds
	@auto_v154spositiontaking_20 SMALLMONEY = 0,

	-- number game
	@auto_v161spositiontaking_81 SMALLMONEY = 0,
	@auto_v161spositiontaking_83 SMALLMONEY = 0,
	@auto_v161spositiontaking_86 SMALLMONEY = 0,
	@auto_v161spositiontaking_88 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_85 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_86 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_87 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_89 SMALLMONEY = 0,
	@auto_v161slivepositiontaking_90 SMALLMONEY = 0,

	--i1
	@isauto_spositiontaking_1 BIT = 0,
	@isauto_spositiontaking_2 BIT = 0,
	@isauto_spositiontaking_3 BIT = 0,
	@isauto_spositiontaking_4 BIT = 0,
	@isauto_spositiontaking_5 bit= 0,
	@isauto_spositiontaking_6 BIT = 0,
	@isauto_spositiontaking_7 BIT = 0,
	@isauto_spositiontaking_8 BIT = 0,
	@isauto_spositiontaking_9 BIT = 0,
	@isauto_spositiontaking_10 BIT = 0,
	@isauto_spositiontaking_9999 BIT = 0,
	
	@isauto_slivepositiontaking_1 BIT = 0,
	@isauto_slivepositiontaking_3 BIT = 0,
	@isauto_slivepositiontaking_7 BIT = 0,
	@isauto_slivepositiontaking_8 BIT = 0,
	
	@isauto_v2spositiontaking_1 BIT = 0,
	@isauto_v2spositiontaking_2 BIT = 0,
	@isauto_v2spositiontaking_3 BIT = 0,
	@isauto_v2spositiontaking_7 BIT = 0,
	@isauto_v2spositiontaking_8 BIT = 0,
--	@isauto_v2spositiontaking_9 BIT = 0,
	@isauto_v2spositiontaking_20 BIT = 0,

	@isauto_v3spositiontaking_1 BIT = 0,
	@isauto_v3spositiontaking_2 BIT = 0,
	@isauto_v3spositiontaking_3 BIT = 0,
	@isauto_v3spositiontaking_20 BIT = 0,

	@isauto_v5spositiontaking_1 BIT = 0,
	@isauto_v5spositiontaking_2 BIT = 0,
	@isauto_v5spositiontaking_3 BIT = 0,
	@isauto_v5spositiontaking_20 BIT = 0,
	@isauto_v5spositiontaking_9999 BIT = 0,

	@isauto_v8spositiontaking_1 BIT = 0,
	@isauto_v8spositiontaking_3 BIT = 0,
	@isauto_v8spositiontaking_20 BIT = 0,

	@isauto_v10spositiontaking_1 BIT = 0,
	@isauto_v10spositiontaking_2 BIT = 0,
	@isauto_v10spositiontaking_3 BIT = 0,
	@isauto_v10spositiontaking_20 BIT = 0,

	@isauto_v11spositiontaking_1 BIT = 0,
	@isauto_v11spositiontaking_20 BIT = 0,

	@isauto_v99spositiontaking_1 BIT = 0,
	@isauto_v99spositiontaking_2 BIT = 0,
	@isauto_v99spositiontaking_3 BIT = 0,
	@isauto_v99spositiontaking_20 BIT = 0,

	-- mixed sports
	@isauto_v99spositiontaking_9 BIT = 0,	
	
	-- HR fixodds
	@isauto_v154spositiontaking_20 BIT = 0,

	-- number game
	@isauto_v161spositiontaking_81 BIT = 0,	
	@isauto_v161spositiontaking_83 BIT = 0,	
	@isauto_v161spositiontaking_86 BIT = 0,	
	@isauto_v161spositiontaking_88 BIT = 0,	
	@isauto_v161slivepositiontaking_85 BIT = 0,	
	@isauto_v161slivepositiontaking_86 BIT = 0,	
	@isauto_v161slivepositiontaking_87 BIT = 0,	
	@isauto_v161slivepositiontaking_89 BIT = 0,
	@isauto_v161slivepositiontaking_90 BIT = 0,

	--i3
	@isauto_smpositiontaking_1 BIT = 0,
	@isauto_smpositiontaking_2 BIT = 0,
	@isauto_smpositiontaking_3 BIT = 0,
	@isauto_smpositiontaking_4 BIT = 0,
	@isauto_smpositiontaking_5 bit= 0,
	@isauto_smpositiontaking_6 BIT = 0,
	@isauto_smpositiontaking_7 BIT = 0,
	@isauto_smpositiontaking_8 BIT = 0,
	@isauto_smpositiontaking_9 BIT = 0,
	@isauto_smpositiontaking_10 BIT = 0,
	@isauto_smpositiontaking_9999 BIT = 0,
	
	@isauto_smlivepositiontaking_1 BIT = 0,
	@isauto_smlivepositiontaking_3 BIT = 0,
	@isauto_smlivepositiontaking_7 BIT = 0,
	@isauto_smlivepositiontaking_8 BIT = 0,
	
	@isauto_v2smpositiontaking_1 BIT = 0,
	@isauto_v2smpositiontaking_2 BIT = 0,
	@isauto_v2smpositiontaking_3 BIT = 0,
	@isauto_v2smpositiontaking_7 BIT = 0,
	@isauto_v2smpositiontaking_8 BIT = 0,
--	@isauto_v2smpositiontaking_9 BIT = 0,
	@isauto_v2smpositiontaking_20 BIT = 0,

	@isauto_v3smpositiontaking_1 BIT = 0,
	@isauto_v3smpositiontaking_2 BIT = 0,
	@isauto_v3smpositiontaking_3 BIT = 0,
	@isauto_v3smpositiontaking_20 BIT = 0,

	@isauto_v5smpositiontaking_1 BIT = 0,
	@isauto_v5smpositiontaking_2 BIT = 0,
	@isauto_v5smpositiontaking_3 BIT = 0,
	@isauto_v5smpositiontaking_20 BIT = 0,
	@isauto_v5smpositiontaking_9999 BIT = 0,

	@isauto_v8smpositiontaking_1 BIT = 0,
	@isauto_v8smpositiontaking_3 BIT = 0,
	@isauto_v8smpositiontaking_20 BIT = 0,

	@isauto_v10smpositiontaking_1 BIT = 0,
	@isauto_v10smpositiontaking_2 BIT = 0,
	@isauto_v10smpositiontaking_3 BIT = 0,
	@isauto_v10smpositiontaking_20 BIT = 0,

	@isauto_v11smpositiontaking_1 BIT = 0,
	@isauto_v11smpositiontaking_20 BIT = 0,

	@isauto_v99smpositiontaking_1 BIT = 0,
	@isauto_v99smpositiontaking_2 BIT = 0,
	@isauto_v99smpositiontaking_3 BIT = 0,
	@isauto_v99smpositiontaking_20 BIT = 0,

	-- mixed sports
	@isauto_v99smpositiontaking_9 BIT = 0,		
	
	-- HR Fixodds
	@isauto_v154smpositiontaking_20 BIT = 0,		

	-- number game
	@isauto_v161smpositiontaking_81 BIT = 0,		
	@isauto_v161smpositiontaking_83 BIT = 0,		
	@isauto_v161smpositiontaking_86 BIT = 0,		
	@isauto_v161smpositiontaking_88 BIT = 0,		
	@isauto_v161smlivepositiontaking_85 BIT = 0,		
	@isauto_v161smlivepositiontaking_86 BIT = 0,		
	@isauto_v161smlivepositiontaking_87 BIT = 0,		
	@isauto_v161smlivepositiontaking_89 BIT = 0,
	@isauto_v161smlivepositiontaking_90 BIT = 0,

	-- Outright PT for sports
	@v2spositiontaking_10 SMALLMONEY OUTPUT,
	@v3spositiontaking_10 SMALLMONEY OUTPUT,
	@v5spositiontaking_10 SMALLMONEY OUTPUT,
	@v8spositiontaking_10 SMALLMONEY OUTPUT,
	@v10spositiontaking_10 SMALLMONEY OUTPUT,
	@v11spositiontaking_10 SMALLMONEY OUTPUT,
	@v99spositiontaking_10 SMALLMONEY OUTPUT,
	
	@auto_v2spositiontaking_10 SMALLMONEY = 0,
	@auto_v3spositiontaking_10 SMALLMONEY = 0,
	@auto_v5spositiontaking_10 SMALLMONEY = 0,
	@auto_v8spositiontaking_10 SMALLMONEY = 0,
	@auto_v10spositiontaking_10 SMALLMONEY = 0,
	@auto_v11spositiontaking_10 SMALLMONEY = 0,
	@auto_v99spositiontaking_10 SMALLMONEY = 0,
	
	@isauto_v2spositiontaking_10 BIT = 0,
	@isauto_v3spositiontaking_10 BIT = 0,
	@isauto_v5spositiontaking_10 BIT = 0,
	@isauto_v8spositiontaking_10 BIT = 0,
	@isauto_v10spositiontaking_10 BIT = 0,
	@isauto_v11spositiontaking_10 BIT = 0,
	@isauto_v99spositiontaking_10 BIT = 0,
	
	@isauto_v2smpositiontaking_10 BIT = 0,
	@isauto_v3smpositiontaking_10 BIT = 0,
	@isauto_v5smpositiontaking_10 BIT = 0,
	@isauto_v8smpositiontaking_10 BIT = 0,
	@isauto_v10smpositiontaking_10 BIT = 0,
	@isauto_v11smpositiontaking_10 BIT = 0,
	@isauto_v99smpositiontaking_10 BIT = 0,

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

	@language varchar(2) = 'E',
	@SubAccID INT = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080515@Thien
Task : Super edits Member
DB: DBTXN/bodb02
Original: Acc_CustomerUpdSuper_Member

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3, hard code copy min/max/maxperbet/PT for 201 from 2 sporttype 
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
	- 20090403@Phuc: Add new tag on write log session <isau> for i3
					 Check to update old value (disable FI cases) for update multiple member.
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.		
    - 20090717@Phuc: Enrich error message.(-101: general info, -102: closed, -103: suspended, 
						-104: credit, -105: commission, -106: min/max bet, -107: positiontaking
						-108: disable FI, -109: disableHR)
	- 20090801@Shifu: check disabled user
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091127@Jamie: Remove input @UpdateMultiple and write log @updatesuspended
	- 20100112@Kiwi: amEND to write log in xml format.
	- 20100730@Henry: grant execute to bodbExtAccNet
	- 20100908@Lukas:	- Add number game setting
						- Add mixed sports setting
						- Remove mix parlay of basketball
	- 20100925@Lukas:	check upline status WHEN update member status
	- 20101019@Henry: Record execution time
	- 20110606@Amy: Write Log Old values
	- 20110802@Lukas: (Number Game)
				- Add new bettypes: Warrior, Next Combo, Number Group
				- Remove Dead ball Over/Under
	- 20110831@Lukas: Hardcode to fix bug ( set 0 for Number Group PT values)
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20111014@TOM: Apply Multiple Edit PT.
	- 20111223@Tom: Add parameter @UpdatePositiontaking_xxx to check multiple edit PT when call sp Acc_CustomerUpdMember_AutoPositiontaking
	- 20120704@Johnson: Remove setting hard code of number group
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20130617@Johnson: check s1 with valid range of s1
	- 20131014@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]	
	- 20131031@Johnson: Aplly execrep when update pt on member [redmine:#3244]	
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)	
	- 20131113@Johnson: Use execrept Acc_CustSetting_00/Acc_CustSetting3rd_00 to correct after update pt on member 
	- 20140214@Johnson: Check s1, us1 with constraint min_s1
	- 20140701@Johnson: Add bettype Others for soccer & tennis [Redmine #16903] 		
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Use temp table for sports, bettype table)	
	- 20150806@Johnson:  Write log value from db if not change when update multiple [Redmine: #40880]				
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

DECLARE @startRun DATETIME
DECLARE @ENDRun DATETIME
DECLARE @duration INT
SET @startRun = getdate()

/*
if not exists (select 1 from custinfo with (nolock) where custid = @custid and srecommEND in (181940,197461))
BEGIN
	DECLARE @ErrMsg varchar(200)
	SELECT @ErrMsg = 'Sorry, please try again later.'
	RaisError (@ErrMsg, 16, 1)
	return
END
*/
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

DECLARE @ErrCode_cur int, @ErrMsg_cur nvarchar(4000), @mrecommEND int, @recommEND int,	@srecommEND int

SELECT @DisabledFI = isnull(@DisabledFI,0), @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

SELECT @srecommEND = srecommEND, @mrecommEND = mrecommEND, @recommEND = recommEND, @username = username FROM custinfo WITH (NOLOCK) Where custid = @custid

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--END
 
-- Update customer info first
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
IF @disCasino = 1 AND EXISTS(SELECT 1 FROM Custinfo WITH (NOLOCK) WHERE syncCasino = 1 AND custID = @CustID)
	BEGIN
		IF @UpdateClosed = 1
		BEGIN
			SELECT @ErrMsg_Cur = case @Language 
								WHEN 'E' THEN 'This CLOSED function is temporarily unavailable, please update later.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60004,@Language)
							END	,
				@ErrCode_Cur = 902
				
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
		
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
		IF @updatesuspended = 1
		BEGIN
			SELECT @ErrMsg_Cur = case @Language 
								WHEN 'E' THEN 'This SUSPENDED function is temporarily unavailable, please update later.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60001,@Language)
							END	,
				@ErrCode_Cur = 903
				
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		END
		
		SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = ''
	END
ELSE
	BEGIN	--- update close
		IF @UpdateClosed = 1 --OR @closed is not null
		BEGIN
			EXEC [dbo].[Acc_CustomerUpdClosed] 
				@CustID = @CustID, 
				@Closed = @closed, 
				@SubAccID = @SubAccID, 
				@UserID = @UserID, 
				@disCasino = @disCasino, 
				@Language = @language,
				@ErrCode = @ErrCode_cur output, 
				@ErrMsg = @ErrMsg_cur output, 
				@IP = @IP
				
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
		
		--- update SuspENDed
		IF @updatesuspended = 1 --OR @Suspended is not null
		BEGIN
			EXEC [dbo].[Acc_CustomerUpdSuspENDed] 
				@CustID = @CustID, 
				@Suspended = @Suspended, 
				@SubAccID = @SubAccID, 
				@UserID = @UserID, 
				@disCasino = @disCasino, 
				@Language = @language,
				@ErrCode = @ErrCode_cur output, 
				@ErrMsg = @ErrMsg_cur output, 
				@IP = @IP
				
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END
		END
		/*
		UPDATE custinfo with (ROWLOCK, UPDLOCK) SET 
			closed= CASE WHEN @closed is null or @UpdateClosed = 0 THEN closed ELSE @closed END,
			reject = case  WHEN @Suspended is null or @updatesuspended = 0 THEN reject ELSE @Suspended END
		WHERE custid=@CustID
		*/
		SELECT @ErrCode = @ErrCode + '-102'+char(7), @ErrMsg = @ErrMsg + char(7)
		
	END

--Log customer info
DECLARE @LogSPData varchar(MAX)

Select @LogSPData = '<Acc_CustomerUpdMember_Super custid="'+ coalesce(cast(@CustID AS varchar(50)),space(1)) + '" ' +
	'Closed="'+ coalesce(cast(@Closed AS varchar(50)),space(1)) + '" ' +
	'ClosedMultiple="'+ coalesce(cast(@UpdateClosed AS varchar(2)),space(1)) + '" ' +
	'SuspENDed="'+ coalesce(cast(@Suspended AS varchar(2)),space(1)) + '" ' +
	'SuspENDedMultiple="'+ coalesce(cast(@updatesuspended AS varchar(2)),space(1)) + '" ' +
	'DisabledFI="'+ coalesce(cast(@DisabledFI AS varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID AS varchar(50)),space(1)) + '" ' +
	'language="'+ coalesce(cast(@language AS varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP AS varchar(15)),space(1)) + '" />'

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1116,
		@TrackingValue = @LogSPData
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdMember_Super custid="'+ coalesce(cast(@CustID AS varchar(50)),space(1)) + '" ' +
		'Closed="'+ coalesce(cast(@Closed AS varchar(50)),space(1)) + '" ' +
		'ClosedMultiple="'+ coalesce(cast(@UpdateClosed AS varchar(2)),space(1)) + '" ' +
		'SuspENDed="'+ coalesce(cast(@Suspended AS varchar(2)),space(1)) + '" ' +
		'SuspENDedMultiple="'+ coalesce(cast(@updatesuspended AS varchar(2)),space(1)) + '" ' +
		'DisabledFI="'+ coalesce(cast(@DisabledFI AS varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID AS varchar(50)),space(1)) + '" ' +
		'language="'+ coalesce(cast(@language AS varchar(2)),space(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP AS varchar(15)),space(1)) + '" />'

	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1116,
		@TrackingValue = @LogSPData
END CATCH

--Update Position Taking
if	@UpdatePositiontaking   = 1  or
	@UpdatePositiontakingv2   = 1  or
	@UpdatePositiontakingv3   = 1  or
	@UpdatePositiontakingv5   = 1  or
	@UpdatePositiontakingv8   = 1  or
	@UpdatePositiontakingv10   = 1  or
	@UpdatePositiontakingv11   = 1  or
	@UpdatePositiontakingv99   = 1  or
	@UpdatePositiontakingv99MP = 1 OR
	@UpdatePositiontakingv154 = 1 OR

	@UpdatePositiontakingv161 = 1
BEGIN--Update Position Taking
	DECLARE 
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
	--	@v2mpositiontaking_9 SMALLMONEY,
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
		@v99mpositiontaking_20 SMALLMONEY,

		-- mixed sports
		@v99mpositiontaking_9 SMALLMONEY,
		
		-- HR Fixed Odds
		@v154mpositiontaking_20 SMALLMONEY,

		-- number game
		@v161mpositiontaking_81 SMALLMONEY,
		@v161mpositiontaking_83 SMALLMONEY,
		@v161mpositiontaking_86 SMALLMONEY,
		@v161mpositiontaking_88 SMALLMONEY,
		@v161mlivepositiontaking_85 SMALLMONEY,
		@v161mlivepositiontaking_86 SMALLMONEY,
		@v161mlivepositiontaking_87 SMALLMONEY,
		@v161mlivepositiontaking_89 SMALLMONEY,
		@v161mlivepositiontaking_90 SMALLMONEY,
		
		@old_spositiontaking_1 SMALLMONEY,
		@old_spositiontaking_2 SMALLMONEY,
		@old_spositiontaking_3 SMALLMONEY,
		@old_spositiontaking_4 SMALLMONEY,
		@old_spositiontaking_5 SMALLMONEY,
		@old_spositiontaking_6 SMALLMONEY,
		@old_spositiontaking_7 SMALLMONEY,
		@old_spositiontaking_8 SMALLMONEY,
		@old_spositiontaking_9 SMALLMONEY,
		@old_spositiontaking_10 SMALLMONEY,
		@old_spositiontaking_9999 SMALLMONEY,
		
		@old_slivepositiontaking_1 SMALLMONEY,
		@old_slivepositiontaking_3 SMALLMONEY,
		@old_slivepositiontaking_7 SMALLMONEY,
		@old_slivepositiontaking_8 SMALLMONEY,
		
		@old_v2spositiontaking_1 SMALLMONEY,
		@old_v2spositiontaking_2 SMALLMONEY,
		@old_v2spositiontaking_3 SMALLMONEY,
		@old_v2spositiontaking_7 SMALLMONEY,
		@old_v2spositiontaking_8 SMALLMONEY,
	--	@old_v2spositiontaking_9 SMALLMONEY,
		@old_v2spositiontaking_20 SMALLMONEY,
		
		@old_v3spositiontaking_1 SMALLMONEY,
		@old_v3spositiontaking_2 SMALLMONEY,
		@old_v3spositiontaking_3 SMALLMONEY,
		@old_v3spositiontaking_20 SMALLMONEY,

		@old_v5spositiontaking_1 SMALLMONEY,
		@old_v5spositiontaking_2 SMALLMONEY,
		@old_v5spositiontaking_3 SMALLMONEY,
		@old_v5spositiontaking_20 SMALLMONEY,
		@old_v5spositiontaking_9999 SMALLMONEY,

		@old_v8spositiontaking_1 SMALLMONEY,
		@old_v8spositiontaking_3 SMALLMONEY,
		@old_v8spositiontaking_20 SMALLMONEY,

		@old_v10spositiontaking_1 SMALLMONEY,
		@old_v10spositiontaking_2 SMALLMONEY,
		@old_v10spositiontaking_3 SMALLMONEY,
		@old_v10spositiontaking_20 SMALLMONEY,

		@old_v11spositiontaking_1 SMALLMONEY,
		@old_v11spositiontaking_20 SMALLMONEY,

		@old_v99spositiontaking_1 SMALLMONEY,
		@old_v99spositiontaking_2 SMALLMONEY,
		@old_v99spositiontaking_3 SMALLMONEY,
		@old_v99spositiontaking_20 SMALLMONEY,


		-- mixed sports
		@old_v99spositiontaking_9 SMALLMONEY,
		
		-- HR Fixed Odds
		@old_v154spositiontaking_20 SMALLMONEY,

		-- number game
		@old_v161spositiontaking_81 SMALLMONEY,
		@old_v161spositiontaking_83 SMALLMONEY,
		@old_v161spositiontaking_86 SMALLMONEY,
		@old_v161spositiontaking_88 SMALLMONEY,
		@old_v161slivepositiontaking_85 SMALLMONEY,
		@old_v161slivepositiontaking_86 SMALLMONEY,
		@old_v161slivepositiontaking_87 SMALLMONEY,
		@old_v161slivepositiontaking_89 SMALLMONEY,
		@old_v161slivepositiontaking_90 SMALLMONEY,

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
		
		-- mixed sports
		@v99apositiontaking_9 SMALLMONEY,
		
		-- HR Fixed Odds
		@v154apositiontaking_20 SMALLMONEY,

		-- number game
		@v161apositiontaking_81 SMALLMONEY,
		@v161apositiontaking_83 SMALLMONEY,
		@v161apositiontaking_86 SMALLMONEY,
		@v161apositiontaking_88 SMALLMONEY,
		@v161alivepositiontaking_85 SMALLMONEY,
		@v161alivepositiontaking_86 SMALLMONEY,
		@v161alivepositiontaking_87 SMALLMONEY,
		@v161alivepositiontaking_89 SMALLMONEY,
		@v161alivepositiontaking_90 SMALLMONEY,

		@spositiontaking_1_max SMALLMONEY,
		@spositiontaking_2_max SMALLMONEY,
		@spositiontaking_3_max SMALLMONEY,
		@spositiontaking_4_max SMALLMONEY,
		@spositiontaking_5_max SMALLMONEY,
		@spositiontaking_6_max SMALLMONEY,
		@spositiontaking_7_max SMALLMONEY,
		@spositiontaking_8_max SMALLMONEY,
		@spositiontaking_9_max SMALLMONEY,
		@spositiontaking_10_max SMALLMONEY,
		@spositiontaking_9999_max SMALLMONEY,
		
		@slivepositiontaking_1_max SMALLMONEY,
		@slivepositiontaking_3_max SMALLMONEY,
		@slivepositiontaking_7_max SMALLMONEY,
		@slivepositiontaking_8_max SMALLMONEY,
		
		@v2spositiontaking_1_max SMALLMONEY,
		@v2spositiontaking_2_max SMALLMONEY,
		@v2spositiontaking_3_max SMALLMONEY,
		@v2spositiontaking_7_max SMALLMONEY,
		@v2spositiontaking_8_max SMALLMONEY,
	--	@v2spositiontaking_9_max SMALLMONEY,
		@v2spositiontaking_20_max SMALLMONEY,
		
		@v3spositiontaking_1_max SMALLMONEY,
		@v3spositiontaking_2_max SMALLMONEY,
		@v3spositiontaking_3_max SMALLMONEY,
		@v3spositiontaking_20_max SMALLMONEY,

		@v5spositiontaking_1_max SMALLMONEY,
		@v5spositiontaking_2_max SMALLMONEY,
		@v5spositiontaking_3_max SMALLMONEY,
		@v5spositiontaking_20_max SMALLMONEY,
		@v5spositiontaking_9999_max SMALLMONEY,

		@v8spositiontaking_1_max SMALLMONEY,
		@v8spositiontaking_3_max SMALLMONEY,
		@v8spositiontaking_20_max SMALLMONEY,

		@v10spositiontaking_1_max SMALLMONEY,
		@v10spositiontaking_2_max SMALLMONEY,
		@v10spositiontaking_3_max SMALLMONEY,
		@v10spositiontaking_20_max SMALLMONEY,

		@v11spositiontaking_1_max SMALLMONEY,
		@v11spositiontaking_20_max SMALLMONEY,

		@v99spositiontaking_1_max SMALLMONEY,
		@v99spositiontaking_2_max SMALLMONEY,
		@v99spositiontaking_3_max SMALLMONEY,
		@v99spositiontaking_20_max SMALLMONEY,
		
		-- mixed sports
		@v99spositiontaking_9_max SMALLMONEY,
		
		-- HR Fixed Odds
		@v154spositiontaking_20_max SMALLMONEY,
		
		-- number game
		@v161spositiontaking_81_max SMALLMONEY,
		@v161spositiontaking_83_max SMALLMONEY,
		@v161spositiontaking_86_max SMALLMONEY,
		@v161spositiontaking_88_max SMALLMONEY,
		@v161slivepositiontaking_85_max SMALLMONEY,
		@v161slivepositiontaking_86_max SMALLMONEY,
		@v161slivepositiontaking_87_max SMALLMONEY,
		@v161slivepositiontaking_89_max SMALLMONEY,
		@v161slivepositiontaking_90_max SMALLMONEY,

		--Old u1,i1
		@old_auto_spositiontaking_1 SMALLMONEY ,
		@old_auto_spositiontaking_2 SMALLMONEY ,
		@old_auto_spositiontaking_3 SMALLMONEY ,
		@old_auto_spositiontaking_4 SMALLMONEY ,
		@old_auto_spositiontaking_5 SMALLMONEY,
		@old_auto_spositiontaking_6 SMALLMONEY ,
		@old_auto_spositiontaking_7 SMALLMONEY ,
		@old_auto_spositiontaking_8 SMALLMONEY ,
		@old_auto_spositiontaking_9 SMALLMONEY ,
		@old_auto_spositiontaking_10 SMALLMONEY ,
		@old_auto_spositiontaking_9999 SMALLMONEY ,
		
		@old_auto_slivepositiontaking_1 SMALLMONEY ,
		@old_auto_slivepositiontaking_3 SMALLMONEY ,
		@old_auto_slivepositiontaking_7 SMALLMONEY ,
		@old_auto_slivepositiontaking_8 SMALLMONEY ,
		
		@old_auto_v2spositiontaking_1 SMALLMONEY ,
		@old_auto_v2spositiontaking_2 SMALLMONEY ,
		@old_auto_v2spositiontaking_3 SMALLMONEY ,
		@old_auto_v2spositiontaking_7 SMALLMONEY ,
		@old_auto_v2spositiontaking_8 SMALLMONEY ,
	--	@old_auto_v2spositiontaking_9 SMALLMONEY ,
		@old_auto_v2spositiontaking_20 SMALLMONEY ,

		@old_auto_v3spositiontaking_1 SMALLMONEY ,
		@old_auto_v3spositiontaking_2 SMALLMONEY ,
		@old_auto_v3spositiontaking_3 SMALLMONEY ,
		@old_auto_v3spositiontaking_20 SMALLMONEY ,

		@old_auto_v5spositiontaking_1 SMALLMONEY ,
		@old_auto_v5spositiontaking_2 SMALLMONEY ,
		@old_auto_v5spositiontaking_3 SMALLMONEY ,
		@old_auto_v5spositiontaking_20 SMALLMONEY ,
		@old_auto_v5spositiontaking_9999 SMALLMONEY ,

		@old_auto_v8spositiontaking_1 SMALLMONEY ,
		@old_auto_v8spositiontaking_3 SMALLMONEY ,
		@old_auto_v8spositiontaking_20 SMALLMONEY ,

		@old_auto_v10spositiontaking_1 SMALLMONEY ,
		@old_auto_v10spositiontaking_2 SMALLMONEY ,
		@old_auto_v10spositiontaking_3 SMALLMONEY ,
		@old_auto_v10spositiontaking_20 SMALLMONEY ,

		@old_auto_v11spositiontaking_1 SMALLMONEY ,
		@old_auto_v11spositiontaking_20 SMALLMONEY ,

		@old_auto_v99spositiontaking_1 SMALLMONEY ,
		@old_auto_v99spositiontaking_2 SMALLMONEY ,
		@old_auto_v99spositiontaking_3 SMALLMONEY ,
		@old_auto_v99spositiontaking_20 SMALLMONEY ,

		-- mixed sports
		@old_auto_v99spositiontaking_9 SMALLMONEY ,	
		
		-- HR Fixed Odds
		@old_auto_v154spositiontaking_20 SMALLMONEY,

		-- number game
		@old_auto_v161spositiontaking_81 SMALLMONEY ,
		@old_auto_v161spositiontaking_83 SMALLMONEY ,
		@old_auto_v161spositiontaking_86 SMALLMONEY ,
		@old_auto_v161spositiontaking_88 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_85 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_86 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_87 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_89 SMALLMONEY ,
		@old_auto_v161slivepositiontaking_90 SMALLMONEY ,

		@old_isauto_spositiontaking_1 BIT ,
		@old_isauto_spositiontaking_2 BIT ,
		@old_isauto_spositiontaking_3 BIT ,
		@old_isauto_spositiontaking_4 BIT ,
		@old_isauto_spositiontaking_5 bit,
		@old_isauto_spositiontaking_6 BIT ,
		@old_isauto_spositiontaking_7 BIT ,
		@old_isauto_spositiontaking_8 BIT ,
		@old_isauto_spositiontaking_9 BIT ,
		@old_isauto_spositiontaking_10 BIT ,
		@old_isauto_spositiontaking_9999 BIT ,
		
		@old_isauto_slivepositiontaking_1 BIT ,
		@old_isauto_slivepositiontaking_3 BIT ,
		@old_isauto_slivepositiontaking_7 BIT ,
		@old_isauto_slivepositiontaking_8 BIT ,
		
		@old_isauto_v2spositiontaking_1 BIT ,
		@old_isauto_v2spositiontaking_2 BIT ,
		@old_isauto_v2spositiontaking_3 BIT ,
		@old_isauto_v2spositiontaking_7 BIT ,
		@old_isauto_v2spositiontaking_8 BIT ,
	--	@old_isauto_v2spositiontaking_9 BIT ,
		@old_isauto_v2spositiontaking_20 BIT ,

		@old_isauto_v3spositiontaking_1 BIT ,
		@old_isauto_v3spositiontaking_2 BIT ,
		@old_isauto_v3spositiontaking_3 BIT ,
		@old_isauto_v3spositiontaking_20 BIT ,

		@old_isauto_v5spositiontaking_1 BIT ,
		@old_isauto_v5spositiontaking_2 BIT ,
		@old_isauto_v5spositiontaking_3 BIT ,
		@old_isauto_v5spositiontaking_20 BIT ,
		@old_isauto_v5spositiontaking_9999 BIT ,

		@old_isauto_v8spositiontaking_1 BIT ,
		@old_isauto_v8spositiontaking_3 BIT ,
		@old_isauto_v8spositiontaking_20 BIT ,

		@old_isauto_v10spositiontaking_1 BIT ,
		@old_isauto_v10spositiontaking_2 BIT ,
		@old_isauto_v10spositiontaking_3 BIT ,
		@old_isauto_v10spositiontaking_20 BIT ,

		@old_isauto_v11spositiontaking_1 BIT ,
		@old_isauto_v11spositiontaking_20 BIT ,

		@old_isauto_v99spositiontaking_1 BIT ,
		@old_isauto_v99spositiontaking_2 BIT ,
		@old_isauto_v99spositiontaking_3 BIT ,
		@old_isauto_v99spositiontaking_20 BIT ,

		-- mixed sports
		@old_isauto_v99spositiontaking_9 BIT ,
		
		-- HR Fixed Odds
		@old_isauto_v154spositiontaking_20 BIT, 
		
		-- number game
		@old_isauto_v161spositiontaking_81 BIT ,
		@old_isauto_v161spositiontaking_83 BIT ,
		@old_isauto_v161spositiontaking_86 BIT ,
		@old_isauto_v161spositiontaking_88 BIT ,
		@old_isauto_v161slivepositiontaking_85 BIT ,
		@old_isauto_v161slivepositiontaking_86 BIT ,
		@old_isauto_v161slivepositiontaking_87 BIT ,
		@old_isauto_v161slivepositiontaking_89 BIT ,
		@old_isauto_v161slivepositiontaking_90 BIT,
		
		--max_s1 = min(s4,l4) - m3
		@mspositiontaking_1_max SMALLMONEY,  
		@mspositiontaking_2_max SMALLMONEY,  
		@mspositiontaking_3_max SMALLMONEY,  
		@mspositiontaking_4_max SMALLMONEY,  
		@mspositiontaking_5_max SMALLMONEY,  
		@mspositiontaking_6_max SMALLMONEY,  
		@mspositiontaking_7_max SMALLMONEY,  
		@mspositiontaking_8_max SMALLMONEY,  
		@mspositiontaking_9_max SMALLMONEY,  
		@mspositiontaking_10_max SMALLMONEY,  
		@mspositiontaking_9999_max SMALLMONEY,

		@mslivepositiontaking_1_max SMALLMONEY,  
		@mslivepositiontaking_3_max SMALLMONEY,  
		@mslivepositiontaking_7_max SMALLMONEY,  
		@mslivepositiontaking_8_max SMALLMONEY,  

		@v2mspositiontaking_1_max SMALLMONEY,  
		@v2mspositiontaking_2_max SMALLMONEY,  
		@v2mspositiontaking_3_max SMALLMONEY,  
		@v2mspositiontaking_7_max SMALLMONEY,  
		@v2mspositiontaking_8_max SMALLMONEY,  	
		@v2mspositiontaking_20_max SMALLMONEY,  

		@v3mspositiontaking_1_max SMALLMONEY,  
		@v3mspositiontaking_2_max SMALLMONEY,  
		@v3mspositiontaking_3_max SMALLMONEY,   
		@v3mspositiontaking_20_max SMALLMONEY,  

		@v5mspositiontaking_1_max SMALLMONEY,  
		@v5mspositiontaking_2_max SMALLMONEY,  
		@v5mspositiontaking_3_max SMALLMONEY,   
		@v5mspositiontaking_20_max SMALLMONEY,
		@v5mspositiontaking_9999_max SMALLMONEY,   

		@v8mspositiontaking_1_max SMALLMONEY,  
		@v8mspositiontaking_3_max SMALLMONEY,   
		@v8mspositiontaking_20_max SMALLMONEY,  

		@v10mspositiontaking_1_max SMALLMONEY,  
		@v10mspositiontaking_2_max SMALLMONEY,  
		@v10mspositiontaking_3_max SMALLMONEY,   
		@v10mspositiontaking_20_max SMALLMONEY,  

		@v11mspositiontaking_1_max SMALLMONEY,  
		@v11mspositiontaking_20_max SMALLMONEY,  
		
		@v99mspositiontaking_1_max SMALLMONEY,  
		@v99mspositiontaking_2_max SMALLMONEY,  
		@v99mspositiontaking_3_max SMALLMONEY,   
		@v99mspositiontaking_20_max SMALLMONEY,
		
		@v154mspositiontaking_20_max SMALLMONEY,
		
		@v161mspositiontaking_81_max SMALLMONEY,  
		@v161mspositiontaking_83_max SMALLMONEY,  
		@v161mspositiontaking_86_max SMALLMONEY,   
		@v161mspositiontaking_88_max SMALLMONEY,
		
		@v161mslivepositiontaking_85_max SMALLMONEY,  
		@v161mslivepositiontaking_86_max SMALLMONEY,  
		@v161mslivepositiontaking_87_max SMALLMONEY,   
		@v161mslivepositiontaking_89_max SMALLMONEY,
		@v161mslivepositiontaking_90_max SMALLMONEY,
		
		@v99mspositiontaking_9_max SMALLMONEY,
		
		--min_s1 = max(n4-m1-a1,0)
		@mspositiontaking_1_min SMALLMONEY,  
		@mspositiontaking_2_min SMALLMONEY,  
		@mspositiontaking_3_min SMALLMONEY,  
		@mspositiontaking_4_min SMALLMONEY,  
		@mspositiontaking_5_min SMALLMONEY,  
		@mspositiontaking_6_min SMALLMONEY,  
		@mspositiontaking_7_min SMALLMONEY,  
		@mspositiontaking_8_min SMALLMONEY,  
		@mspositiontaking_9_min SMALLMONEY,  
		@mspositiontaking_10_min SMALLMONEY,
		@mspositiontaking_9999_min SMALLMONEY,   

		@mslivepositiontaking_1_min SMALLMONEY,  
		@mslivepositiontaking_3_min SMALLMONEY,  
		@mslivepositiontaking_7_min SMALLMONEY,  
		@mslivepositiontaking_8_min SMALLMONEY,  

		@v2mspositiontaking_1_min SMALLMONEY,  
		@v2mspositiontaking_2_min SMALLMONEY,  
		@v2mspositiontaking_3_min SMALLMONEY,  
		@v2mspositiontaking_7_min SMALLMONEY,  
		@v2mspositiontaking_8_min SMALLMONEY,  	
		@v2mspositiontaking_20_min SMALLMONEY,  

		@v3mspositiontaking_1_min SMALLMONEY,  
		@v3mspositiontaking_2_min SMALLMONEY,  
		@v3mspositiontaking_3_min SMALLMONEY,   
		@v3mspositiontaking_20_min SMALLMONEY,  

		@v5mspositiontaking_1_min SMALLMONEY,  
		@v5mspositiontaking_2_min SMALLMONEY,  
		@v5mspositiontaking_3_min SMALLMONEY,   
		@v5mspositiontaking_20_min SMALLMONEY,  
		@v5mspositiontaking_9999_min SMALLMONEY, 

		@v8mspositiontaking_1_min SMALLMONEY,  
		@v8mspositiontaking_3_min SMALLMONEY,   
		@v8mspositiontaking_20_min SMALLMONEY,  

		@v10mspositiontaking_1_min SMALLMONEY,  
		@v10mspositiontaking_2_min SMALLMONEY,  
		@v10mspositiontaking_3_min SMALLMONEY,   
		@v10mspositiontaking_20_min SMALLMONEY,  

		@v11mspositiontaking_1_min SMALLMONEY,  
		@v11mspositiontaking_20_min SMALLMONEY,  
		
		@v99mspositiontaking_1_min SMALLMONEY,  
		@v99mspositiontaking_2_min SMALLMONEY,  
		@v99mspositiontaking_3_min SMALLMONEY,   
		@v99mspositiontaking_20_min SMALLMONEY,
		
		@v154mspositiontaking_20_min SMALLMONEY,
		
		@v161mspositiontaking_81_min SMALLMONEY,  
		@v161mspositiontaking_83_min SMALLMONEY,  
		@v161mspositiontaking_86_min SMALLMONEY,   
		@v161mspositiontaking_88_min SMALLMONEY,
		
		@v161mslivepositiontaking_85_min SMALLMONEY,  
		@v161mslivepositiontaking_86_min SMALLMONEY,  
		@v161mslivepositiontaking_87_min SMALLMONEY,   
		@v161mslivepositiontaking_89_min SMALLMONEY,
		@v161mslivepositiontaking_90_min SMALLMONEY,
		
		@v99mspositiontaking_9_min SMALLMONEY,
		
		--m3
		@mpos_1 SMALLMONEY,  
		@mpos_2 SMALLMONEY,  
		@mpos_3 SMALLMONEY,  
		@mpos_4 SMALLMONEY,  
		@mpos_5 SMALLMONEY,  
		@mpos_6 SMALLMONEY,  
		@mpos_7 SMALLMONEY,  
		@mpos_8 SMALLMONEY,  
		@mpos_9 SMALLMONEY,  
		@mpos_10 SMALLMONEY, 
		@mpos_9999 SMALLMONEY,   

		@mlivepos_1 SMALLMONEY,  
		@mlivepos_3 SMALLMONEY,  
		@mlivepos_7 SMALLMONEY,  
		@mlivepos_8 SMALLMONEY,  

		@v2mpos_1 SMALLMONEY,  
		@v2mpos_2 SMALLMONEY,  
		@v2mpos_3 SMALLMONEY,  
		@v2mpos_7 SMALLMONEY,  
		@v2mpos_8 SMALLMONEY,  	 
		@v2mpos_20 SMALLMONEY,  

		@v3mpos_1 SMALLMONEY,  
		@v3mpos_2 SMALLMONEY,  
		@v3mpos_3 SMALLMONEY,   
		@v3mpos_20 SMALLMONEY,  

		@v5mpos_1 SMALLMONEY,  
		@v5mpos_2 SMALLMONEY,  
		@v5mpos_3 SMALLMONEY,   
		@v5mpos_20 SMALLMONEY,  
		@v5mpos_9999 SMALLMONEY,

		@v8mpos_1 SMALLMONEY,  
		@v8mpos_3 SMALLMONEY,   
		@v8mpos_20 SMALLMONEY,  

		@v10mpos_1 SMALLMONEY,  
		@v10mpos_2 SMALLMONEY,  
		@v10mpos_3 SMALLMONEY,   
		@v10mpos_20 SMALLMONEY,  

		@v11mpos_1 SMALLMONEY,  
		@v11mpos_20 SMALLMONEY,  
		
		@v99mpos_1 SMALLMONEY,  
		@v99mpos_2 SMALLMONEY,  
		@v99mpos_3 SMALLMONEY,   
		@v99mpos_20 SMALLMONEY,
		
		@v154mpos_20 SMALLMONEY,
		
		@v161mpos_81 SMALLMONEY,  
		@v161mpos_83 SMALLMONEY,  
		@v161mpos_86 SMALLMONEY,   
		@v161mpos_88 SMALLMONEY,
	  
		@v161mlivepos_85 SMALLMONEY,  
		@v161mlivepos_86 SMALLMONEY,  
		@v161mlivepos_87 SMALLMONEY,
		@v161mlivepos_89 SMALLMONEY,
		@v161mlivepos_90 SMALLMONEY,
		
		@v99mpos_9 SMALLMONEY,
		
		-- Outright PT for sports
		@v2mpositiontaking_10 SMALLMONEY,
		@v3mpositiontaking_10 SMALLMONEY,
		@v5mpositiontaking_10 SMALLMONEY,
		@v8mpositiontaking_10 SMALLMONEY,
		@v10mpositiontaking_10 SMALLMONEY,
		@v11mpositiontaking_10 SMALLMONEY,
		@v99mpositiontaking_10 SMALLMONEY,
		
		@old_v2spositiontaking_10 SMALLMONEY,
		@old_v3spositiontaking_10 SMALLMONEY,
		@old_v5spositiontaking_10 SMALLMONEY,
		@old_v8spositiontaking_10 SMALLMONEY,
		@old_v10spositiontaking_10 SMALLMONEY,
		@old_v11spositiontaking_10 SMALLMONEY,
		@old_v99spositiontaking_10 SMALLMONEY,
		
		@v2apositiontaking_10 SMALLMONEY,
		@v3apositiontaking_10 SMALLMONEY,
		@v5apositiontaking_10 SMALLMONEY,
		@v8apositiontaking_10 SMALLMONEY,
		@v10apositiontaking_10 SMALLMONEY,
		@v11apositiontaking_10 SMALLMONEY,
		@v99apositiontaking_10 SMALLMONEY,
		
		@v2spositiontaking_10_max SMALLMONEY,
		@v3spositiontaking_10_max SMALLMONEY,
		@v5spositiontaking_10_max SMALLMONEY,
		@v8spositiontaking_10_max SMALLMONEY,
		@v10spositiontaking_10_max SMALLMONEY,
		@v11spositiontaking_10_max SMALLMONEY,
		@v99spositiontaking_10_max SMALLMONEY,
		
		@old_auto_v2spositiontaking_10 SMALLMONEY ,
		@old_auto_v3spositiontaking_10 SMALLMONEY ,
		@old_auto_v5spositiontaking_10 SMALLMONEY ,
		@old_auto_v8spositiontaking_10 SMALLMONEY ,
		@old_auto_v10spositiontaking_10 SMALLMONEY ,
		@old_auto_v11spositiontaking_10 SMALLMONEY ,
		@old_auto_v99spositiontaking_10 SMALLMONEY ,
		
		@old_isauto_v2spositiontaking_10 BIT ,
		@old_isauto_v3spositiontaking_10 BIT ,
		@old_isauto_v5spositiontaking_10 BIT ,
		@old_isauto_v8spositiontaking_10 BIT ,
		@old_isauto_v10spositiontaking_10 BIT ,
		@old_isauto_v11spositiontaking_10 BIT ,
		@old_isauto_v99spositiontaking_10 BIT ,
		
		@v2mspositiontaking_10_max SMALLMONEY,  
		@v3mspositiontaking_10_max SMALLMONEY,  
		@v5mspositiontaking_10_max SMALLMONEY,  
		@v8mspositiontaking_10_max SMALLMONEY,  
		@v10mspositiontaking_10_max SMALLMONEY,  
		@v11mspositiontaking_10_max SMALLMONEY,  
		@v99mspositiontaking_10_max SMALLMONEY,  
		
		@v2mspositiontaking_10_min SMALLMONEY,
		@v3mspositiontaking_10_min SMALLMONEY,
		@v5mspositiontaking_10_min SMALLMONEY,
		@v8mspositiontaking_10_min SMALLMONEY,
		@v10mspositiontaking_10_min SMALLMONEY,
		@v11mspositiontaking_10_min SMALLMONEY,
		@v99mspositiontaking_10_min SMALLMONEY,
		
		@v2mpos_10 SMALLMONEY, 
		@v3mpos_10 SMALLMONEY, 
		@v5mpos_10 SMALLMONEY, 
		@v8mpos_10 SMALLMONEY, 
		@v10mpos_10 SMALLMONEY, 
		@v11mpos_10 SMALLMONEY, 
		@v99mpos_10 SMALLMONEY 

				


	DECLARE @ErrType varchar(1000) 
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Check param
	DECLARE @IsValid bit
	SELECT @IsValid = 1



	--Check Old_PT <> New_PT
	SELECT @apositiontaking_1 = apositiontaking, @alivepositiontaking_1 = alivepositiontaking, @mpositiontaking_1 = mpositiontaking, @mlivepositiontaking_1 = mlivepositiontaking, @old_spositiontaking_1 = spositiontaking, @old_slivepositiontaking_1 = slivepositiontaking, @old_auto_spositiontaking_1 = autopositiontaking, @old_auto_slivepositiontaking_1 = autolivepositiontaking, @old_isauto_spositiontaking_1 = isautopositiontaking, @old_isauto_slivepositiontaking_1 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1
	SELECT @apositiontaking_3 = apositiontaking, @alivepositiontaking_3 = alivepositiontaking,@mpositiontaking_3 = mpositiontaking, @mlivepositiontaking_3 = mlivepositiontaking, @old_spositiontaking_3 = spositiontaking, @old_slivepositiontaking_3 = slivepositiontaking, @old_auto_spositiontaking_3 = autopositiontaking, @old_auto_slivepositiontaking_3 = autolivepositiontaking, @old_isauto_spositiontaking_3 = isautopositiontaking, @old_isauto_slivepositiontaking_3 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1
	SELECT @apositiontaking_7 = apositiontaking, @alivepositiontaking_7 = alivepositiontaking,@mpositiontaking_7 = mpositiontaking, @mlivepositiontaking_7 = mlivepositiontaking, @old_spositiontaking_7 = spositiontaking, @old_slivepositiontaking_7 = slivepositiontaking, @old_auto_spositiontaking_7 = autopositiontaking, @old_auto_slivepositiontaking_7 = autolivepositiontaking, @old_isauto_spositiontaking_7 = isautopositiontaking, @old_isauto_slivepositiontaking_7 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1
	SELECT @apositiontaking_8 = apositiontaking, @alivepositiontaking_8 = alivepositiontaking,@mpositiontaking_8 = mpositiontaking, @mlivepositiontaking_8 = mlivepositiontaking, @old_spositiontaking_8 = spositiontaking, @old_slivepositiontaking_8 = slivepositiontaking, @old_auto_spositiontaking_8 = autopositiontaking, @old_auto_slivepositiontaking_8 = autolivepositiontaking, @old_isauto_spositiontaking_8 = isautopositiontaking, @old_isauto_slivepositiontaking_8 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1

	SELECT @apositiontaking_2 = apositiontaking, @mpositiontaking_2 = mpositiontaking, @old_spositiontaking_2 = spositiontaking, @old_auto_spositiontaking_2 = autopositiontaking, @old_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
	SELECT @apositiontaking_4 = apositiontaking, @mpositiontaking_4 = mpositiontaking, @old_spositiontaking_4 = spositiontaking, @old_auto_spositiontaking_4 = autopositiontaking, @old_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1
	SELECT @apositiontaking_5 = apositiontaking, @mpositiontaking_5 = mpositiontaking, @old_spositiontaking_5 = spositiontaking, @old_auto_spositiontaking_5 = autopositiontaking, @old_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
	SELECT @apositiontaking_6 = apositiontaking, @mpositiontaking_6 = mpositiontaking, @old_spositiontaking_6 = spositiontaking, @old_auto_spositiontaking_6 = autopositiontaking, @old_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
	SELECT @apositiontaking_9 = apositiontaking, @mpositiontaking_9 = mpositiontaking, @old_spositiontaking_9 = spositiontaking, @old_auto_spositiontaking_9 = autopositiontaking, @old_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
	SELECT @apositiontaking_10 = apositiontaking, @mpositiontaking_10 = mpositiontaking, @old_spositiontaking_10 = spositiontaking, @old_auto_spositiontaking_10 = autopositiontaking, @old_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1
	
	-- Outright PT for sports
	SELECT @v2apositiontaking_10 = apositiontaking, @v2mpositiontaking_10 = mpositiontaking, @old_v2spositiontaking_10 = spositiontaking, @old_auto_v2spositiontaking_10 = autopositiontaking, @old_isauto_v2spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=2
	SELECT @v3apositiontaking_10 = apositiontaking, @v3mpositiontaking_10 = mpositiontaking, @old_v3spositiontaking_10 = spositiontaking, @old_auto_v3spositiontaking_10 = autopositiontaking, @old_isauto_v3spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=3
	SELECT @v5apositiontaking_10 = apositiontaking, @v5mpositiontaking_10 = mpositiontaking, @old_v5spositiontaking_10 = spositiontaking, @old_auto_v5spositiontaking_10 = autopositiontaking, @old_isauto_v5spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=5
	SELECT @v8apositiontaking_10 = apositiontaking, @v8mpositiontaking_10 = mpositiontaking, @old_v8spositiontaking_10 = spositiontaking, @old_auto_v8spositiontaking_10 = autopositiontaking, @old_isauto_v8spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=8
	SELECT @v10apositiontaking_10 = apositiontaking, @v10mpositiontaking_10 = mpositiontaking, @old_v10spositiontaking_10 = spositiontaking, @old_auto_v10spositiontaking_10 = autopositiontaking, @old_isauto_v10spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=10
	SELECT @v11apositiontaking_10 = apositiontaking, @v11mpositiontaking_10 = mpositiontaking, @old_v11spositiontaking_10 = spositiontaking, @old_auto_v11spositiontaking_10 = autopositiontaking, @old_isauto_v11spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=11
	SELECT @v99apositiontaking_10 = apositiontaking, @v99mpositiontaking_10 = mpositiontaking, @old_v99spositiontaking_10 = spositiontaking, @old_auto_v99spositiontaking_10 = autopositiontaking, @old_isauto_v99spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=99
	
	SELECT @apositiontaking_9999 = apositiontaking, @mpositiontaking_9999 = mpositiontaking, @old_spositiontaking_9999 = spositiontaking, @old_auto_spositiontaking_9999 = autopositiontaking, @old_isauto_spositiontaking_9999 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=1

	SELECT @v2apositiontaking_1 = apositiontaking, @v2mpositiontaking_1 = mpositiontaking, @old_v2spositiontaking_1 = spositiontaking, @old_auto_v2spositiontaking_1 = autopositiontaking, @old_isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=2
	SELECT @v2apositiontaking_2 = apositiontaking, @v2mpositiontaking_2 = mpositiontaking, @old_v2spositiontaking_2 = spositiontaking, @old_auto_v2spositiontaking_2 = autopositiontaking, @old_isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=2
	SELECT @v2apositiontaking_3 = apositiontaking, @v2mpositiontaking_3 = mpositiontaking, @old_v2spositiontaking_3 = spositiontaking, @old_auto_v2spositiontaking_3 = autopositiontaking, @old_isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=2
	SELECT @v2apositiontaking_7 = apositiontaking, @v2mpositiontaking_7 = mpositiontaking, @old_v2spositiontaking_7 = spositiontaking, @old_auto_v2spositiontaking_7 = autopositiontaking, @old_isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=2
	SELECT @v2apositiontaking_8 = apositiontaking, @v2mpositiontaking_8 = mpositiontaking, @old_v2spositiontaking_8 = spositiontaking, @old_auto_v2spositiontaking_8 = autopositiontaking, @old_isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=2
	--select @v2apositiontaking_9 = apositiontaking, @v2mpositiontaking_9 = mpositiontaking, @old_v2spositiontaking_9 = spositiontaking, @old_auto_v2spositiontaking_9 = autopositiontaking, @old_isauto_v2spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=2
	SELECT @v2apositiontaking_20 = apositiontaking, @v2mpositiontaking_20 = mpositiontaking, @old_v2spositiontaking_20 = spositiontaking, @old_auto_v2spositiontaking_20 = autopositiontaking, @old_isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=2

	SELECT @v3apositiontaking_1 = apositiontaking, @v3mpositiontaking_1 = mpositiontaking, @old_v3spositiontaking_1 = spositiontaking, @old_auto_v3spositiontaking_1 = autopositiontaking, @old_isauto_v3spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=3
	SELECT @v3apositiontaking_2 = apositiontaking, @v3mpositiontaking_2 = mpositiontaking, @old_v3spositiontaking_2 = spositiontaking, @old_auto_v3spositiontaking_2 = autopositiontaking, @old_isauto_v3spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=3
	SELECT @v3apositiontaking_3 = apositiontaking, @v3mpositiontaking_3 = mpositiontaking, @old_v3spositiontaking_3 = spositiontaking, @old_auto_v3spositiontaking_3 = autopositiontaking, @old_isauto_v3spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=3
	SELECT @v3apositiontaking_20 = apositiontaking, @v3mpositiontaking_20 = mpositiontaking, @old_v3spositiontaking_20 = spositiontaking, @old_auto_v3spositiontaking_20 = autopositiontaking, @old_isauto_v3spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=3

	SELECT @v5apositiontaking_1 = apositiontaking, @v5mpositiontaking_1 = mpositiontaking, @old_v5spositiontaking_1 = spositiontaking, @old_auto_v5spositiontaking_1 = autopositiontaking, @old_isauto_v5spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=5
	SELECT @v5apositiontaking_2 = apositiontaking, @v5mpositiontaking_2 = mpositiontaking, @old_v5spositiontaking_2 = spositiontaking, @old_auto_v5spositiontaking_2 = autopositiontaking, @old_isauto_v5spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=5
	SELECT @v5apositiontaking_3 = apositiontaking, @v5mpositiontaking_3 = mpositiontaking, @old_v5spositiontaking_3 = spositiontaking, @old_auto_v5spositiontaking_3 = autopositiontaking, @old_isauto_v5spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=5
	SELECT @v5apositiontaking_20 = apositiontaking, @v5mpositiontaking_20 = mpositiontaking, @old_v5spositiontaking_20 = spositiontaking, @old_auto_v5spositiontaking_20 = autopositiontaking, @old_isauto_v5spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=5
	SELECT @v5apositiontaking_9999 = apositiontaking, @v5mpositiontaking_9999 = mpositiontaking, @old_v5spositiontaking_9999 = spositiontaking, @old_auto_v5spositiontaking_9999 = autopositiontaking, @old_isauto_v5spositiontaking_9999 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=5

	SELECT @v8apositiontaking_1 = apositiontaking, @v8mpositiontaking_1 = mpositiontaking, @old_v8spositiontaking_1 = spositiontaking, @old_auto_v8spositiontaking_1 = autopositiontaking, @old_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
	SELECT @v8apositiontaking_3 = apositiontaking, @v8mpositiontaking_3 = mpositiontaking, @old_v8spositiontaking_3 = spositiontaking, @old_auto_v8spositiontaking_3 = autopositiontaking, @old_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
	SELECT @v8apositiontaking_20 = apositiontaking, @v8mpositiontaking_20 = mpositiontaking, @old_v8spositiontaking_20 = spositiontaking, @old_auto_v8spositiontaking_20 = autopositiontaking, @old_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8

	SELECT @v10apositiontaking_1 = apositiontaking, @v10mpositiontaking_1 = mpositiontaking, @old_v10spositiontaking_1 = spositiontaking, @old_auto_v10spositiontaking_1 = autopositiontaking, @old_isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=10
	SELECT @v10apositiontaking_2 = apositiontaking, @v10mpositiontaking_2 = mpositiontaking, @old_v10spositiontaking_2 = spositiontaking, @old_auto_v10spositiontaking_2 = autopositiontaking, @old_isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=10
	SELECT @v10apositiontaking_3 = apositiontaking, @v10mpositiontaking_3 = mpositiontaking, @old_v10spositiontaking_3 = spositiontaking, @old_auto_v10spositiontaking_3 = autopositiontaking, @old_isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=10
	SELECT @v10apositiontaking_20 = apositiontaking, @v10mpositiontaking_20 = mpositiontaking, @old_v10spositiontaking_20 = spositiontaking, @old_auto_v10spositiontaking_20 = autopositiontaking, @old_isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=10

	SELECT @v11apositiontaking_1 = apositiontaking, @v11mpositiontaking_1 = mpositiontaking, @old_v11spositiontaking_1 = spositiontaking, @old_auto_v11spositiontaking_1 = autopositiontaking, @old_isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=11
	SELECT @v11apositiontaking_20 = apositiontaking, @v11mpositiontaking_20 = mpositiontaking, @old_v11spositiontaking_20 = spositiontaking, @old_auto_v11spositiontaking_20 = autopositiontaking, @old_isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=11

	SELECT @v99apositiontaking_1 = apositiontaking, @v99mpositiontaking_1 = mpositiontaking, @old_v99spositiontaking_1 = spositiontaking, @old_auto_v99spositiontaking_1 = autopositiontaking, @old_isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=99
	SELECT @v99apositiontaking_2 = apositiontaking, @v99mpositiontaking_2 = mpositiontaking, @old_v99spositiontaking_2 = spositiontaking, @old_auto_v99spositiontaking_2 = autopositiontaking, @old_isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=99
	SELECT @v99apositiontaking_3 = apositiontaking, @v99mpositiontaking_3 = mpositiontaking, @old_v99spositiontaking_3 = spositiontaking, @old_auto_v99spositiontaking_3 = autopositiontaking, @old_isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=99
	SELECT @v99apositiontaking_20 = apositiontaking, @v99mpositiontaking_20 = mpositiontaking, @old_v99spositiontaking_20 = spositiontaking, @old_auto_v99spositiontaking_20 = autopositiontaking, @old_isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=99

	-- mixed sports
	SELECT @v99apositiontaking_9 = apositiontaking, @v99mpositiontaking_9 = mpositiontaking, @old_v99spositiontaking_9 = spositiontaking, 
	@old_auto_v99spositiontaking_9 = autopositiontaking, @old_isauto_v99spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=99

	-- HR Fixed Odds
	SELECT @v154apositiontaking_20 = apositiontaking, @v154mpositiontaking_20 = mpositiontaking, 
	@old_v154spositiontaking_20 = spositiontaking, @old_auto_v154spositiontaking_20 = autopositiontaking, 
	@old_isauto_v154spositiontaking_20 = isautopositiontaking
	from custsetting with (NOLOCK) where custid = @custid and bettype = 20 and sporttype = 154 
	
	-- number game
	SELECT @v161apositiontaking_81 = apositiontaking, @v161mpositiontaking_81 = mpositiontaking, @old_v161spositiontaking_81 = spositiontaking, @old_auto_v161spositiontaking_81 = autopositiontaking, @old_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161
	SELECT @v161apositiontaking_83 = apositiontaking, @v161mpositiontaking_83 = mpositiontaking, @old_v161spositiontaking_83 = spositiontaking, @old_auto_v161spositiontaking_83 = autopositiontaking, @old_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161
	SELECT @v161apositiontaking_86 = apositiontaking, @v161mpositiontaking_86 = mpositiontaking, @old_v161spositiontaking_86 = spositiontaking, @old_auto_v161spositiontaking_86 = autopositiontaking, @old_isauto_v161spositiontaking_86 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
	SELECT @v161apositiontaking_88 = apositiontaking, @v161mpositiontaking_88 = mpositiontaking, @old_v161spositiontaking_88 = spositiontaking, @old_auto_v161spositiontaking_88 = autopositiontaking, @old_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161
	SELECT @v161alivepositiontaking_85 = alivepositiontaking, @v161mlivepositiontaking_85 = mlivepositiontaking, @old_v161slivepositiontaking_85 = slivepositiontaking, @old_auto_v161slivepositiontaking_85 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
	SELECT @v161alivepositiontaking_86 = alivepositiontaking, @v161mlivepositiontaking_86 = mlivepositiontaking, @old_v161slivepositiontaking_86 = slivepositiontaking, @old_auto_v161slivepositiontaking_86 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
	SELECT @v161alivepositiontaking_87 = alivepositiontaking, @v161mlivepositiontaking_87 = mlivepositiontaking, @old_v161slivepositiontaking_87 = slivepositiontaking, @old_auto_v161slivepositiontaking_87 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
	SELECT @v161alivepositiontaking_89 = alivepositiontaking, @v161mlivepositiontaking_89 = mlivepositiontaking, @old_v161slivepositiontaking_89 = slivepositiontaking, @old_auto_v161slivepositiontaking_89 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
	SELECT @v161alivepositiontaking_90 = alivepositiontaking, @v161mlivepositiontaking_90 = mlivepositiontaking, @old_v161slivepositiontaking_90 = slivepositiontaking, @old_auto_v161slivepositiontaking_90 = autolivepositiontaking, @old_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161

	IF @spositiontaking_1 = @old_spositiontaking_1 AND
		@spositiontaking_2 = @old_spositiontaking_2 AND
		@spositiontaking_3 = @old_spositiontaking_3 AND
		@spositiontaking_4 = @old_spositiontaking_4 AND
		@spositiontaking_5 = @old_spositiontaking_5 AND
		@spositiontaking_6 = @old_spositiontaking_6 AND
		@spositiontaking_7 = @old_spositiontaking_7 AND
		@spositiontaking_8 = @old_spositiontaking_8 AND
		@spositiontaking_9 = @old_spositiontaking_9 AND
		@spositiontaking_10 = @old_spositiontaking_10 AND
		@spositiontaking_9999 = @old_spositiontaking_9999 AND
		@slivepositiontaking_1 = @old_slivepositiontaking_1 AND
		@slivepositiontaking_3 = @old_slivepositiontaking_3 AND
		@slivepositiontaking_7 = @old_slivepositiontaking_7 AND
		@slivepositiontaking_8 = @old_slivepositiontaking_8 AND

		@v2spositiontaking_1 = @old_v2spositiontaking_1 AND
		@v2spositiontaking_2 = @old_v2spositiontaking_2 AND
		@v2spositiontaking_3 = @old_v2spositiontaking_3 AND
		@v2spositiontaking_7 = @old_v2spositiontaking_7 AND
		@v2spositiontaking_8 = @old_v2spositiontaking_8 AND
	--	@v2spositiontaking_9 = @old_v2spositiontaking_9 AND
		@v2spositiontaking_20 = @old_v2spositiontaking_20 AND
		
		@v3spositiontaking_1 = @old_v3spositiontaking_1 AND
		@v3spositiontaking_2 = @old_v3spositiontaking_2 AND
		@v3spositiontaking_3 = @old_v3spositiontaking_3 AND
		@v3spositiontaking_20 = @old_v3spositiontaking_20 AND
		
		@v5spositiontaking_1 = @old_v5spositiontaking_1 AND
		@v5spositiontaking_2 = @old_v5spositiontaking_2 AND
		@v5spositiontaking_3 = @old_v5spositiontaking_3 AND
		@v5spositiontaking_20 = @old_v5spositiontaking_20 AND
		@v5spositiontaking_9999 = @old_v5spositiontaking_9999 AND
		
		@v8spositiontaking_1 = @old_v8spositiontaking_1 AND
		@v8spositiontaking_3 = @old_v8spositiontaking_3 AND
		@v8spositiontaking_20 = @old_v8spositiontaking_20 AND
		
		@v10spositiontaking_1 = @old_v10spositiontaking_1 AND
		@v10spositiontaking_2 = @old_v10spositiontaking_2 AND
		@v10spositiontaking_3 = @old_v10spositiontaking_3 AND
		@v10spositiontaking_20 = @old_v10spositiontaking_20 AND
		
		@v11spositiontaking_1 = @old_v11spositiontaking_1 AND
		@v11spositiontaking_20 = @old_v11spositiontaking_20 AND
		
		@v99spositiontaking_1 = @old_v99spositiontaking_1 AND
		@v99spositiontaking_2 = @old_v99spositiontaking_2 AND
		@v99spositiontaking_3 = @old_v99spositiontaking_3 AND
		@v99spositiontaking_20 = @old_v99spositiontaking_20 AND

		-- mixed sports
		@v99spositiontaking_9 = @old_v99spositiontaking_9 AND
		
		-- HR Fixed Odds
		@v154spositiontaking_20 = @old_v154spositiontaking_20 AND
		-- number game
		@v161spositiontaking_81 = @old_v161spositiontaking_81 AND
		@v161spositiontaking_83 = @old_v161spositiontaking_83 AND
		@v161spositiontaking_86 = @old_v161spositiontaking_86 AND
		@v161spositiontaking_88 = @old_v161spositiontaking_88 AND
		@v161slivepositiontaking_85 = @old_v161slivepositiontaking_85 AND
		@v161slivepositiontaking_86 = @old_v161slivepositiontaking_86 AND
		@v161slivepositiontaking_87 = @old_v161slivepositiontaking_87 AND
		@v161slivepositiontaking_89 = @old_v161slivepositiontaking_89 AND
		@v161slivepositiontaking_90 = @old_v161slivepositiontaking_90 AND
		
		@auto_spositiontaking_1 = @old_auto_spositiontaking_1 AND
		@auto_spositiontaking_2 = @old_auto_spositiontaking_2 AND
		@auto_spositiontaking_3 = @old_auto_spositiontaking_3 AND
		@auto_spositiontaking_4 = @old_auto_spositiontaking_4 AND
		@auto_spositiontaking_5 = @old_auto_spositiontaking_5 AND
		@auto_spositiontaking_6 = @old_auto_spositiontaking_6 AND
		@auto_spositiontaking_7 = @old_auto_spositiontaking_7 AND
		@auto_spositiontaking_8 = @old_auto_spositiontaking_8 AND
		@auto_spositiontaking_9 = @old_auto_spositiontaking_9 AND
		@auto_spositiontaking_10 = @old_auto_spositiontaking_10 AND
		@auto_spositiontaking_9999 = @old_auto_spositiontaking_9999 AND
		@auto_slivepositiontaking_1 = @old_auto_slivepositiontaking_1 AND
		@auto_slivepositiontaking_3 = @old_auto_slivepositiontaking_3 AND
		@auto_slivepositiontaking_7 = @old_auto_slivepositiontaking_7 AND
		@auto_slivepositiontaking_8 = @old_auto_slivepositiontaking_8 AND
		
		@auto_v2spositiontaking_1 = @old_auto_v2spositiontaking_1 AND
		@auto_v2spositiontaking_2 = @old_auto_v2spositiontaking_2 AND
		@auto_v2spositiontaking_3 = @old_auto_v2spositiontaking_3 AND
		@auto_v2spositiontaking_7 = @old_auto_v2spositiontaking_7 AND
		@auto_v2spositiontaking_8 = @old_auto_v2spositiontaking_8 AND
	--	@auto_v2spositiontaking_9 = @old_auto_v2spositiontaking_9 AND
		@auto_v2spositiontaking_20 = @old_auto_v2spositiontaking_20 AND
		
		@auto_v3spositiontaking_1 = @old_auto_v3spositiontaking_1 AND
		@auto_v3spositiontaking_2 = @old_auto_v3spositiontaking_2 AND
		@auto_v3spositiontaking_3 = @old_auto_v3spositiontaking_3 AND
		@auto_v3spositiontaking_20 = @old_auto_v3spositiontaking_20 AND
		
		@auto_v5spositiontaking_1 = @old_auto_v5spositiontaking_1 AND
		@auto_v5spositiontaking_2 = @old_auto_v5spositiontaking_2 AND
		@auto_v5spositiontaking_3 = @old_auto_v5spositiontaking_3 AND
		@auto_v5spositiontaking_20 = @old_auto_v5spositiontaking_20 AND
		@auto_v5spositiontaking_9999 = @old_auto_v5spositiontaking_9999 AND
		
		@auto_v8spositiontaking_1 = @old_auto_v8spositiontaking_1 AND
		@auto_v8spositiontaking_3 = @old_auto_v8spositiontaking_3 AND
		@auto_v8spositiontaking_20 = @old_auto_v8spositiontaking_20 AND
		
		@auto_v10spositiontaking_1 = @old_auto_v10spositiontaking_1 AND
		@auto_v10spositiontaking_2 = @old_auto_v10spositiontaking_2 AND
		@auto_v10spositiontaking_3 = @old_auto_v10spositiontaking_3 AND
		@auto_v10spositiontaking_20 = @old_auto_v10spositiontaking_20 AND
		
		@auto_v11spositiontaking_1 = @old_auto_v11spositiontaking_1 AND
		@auto_v11spositiontaking_20 = @old_auto_v11spositiontaking_20 AND

		@auto_v99spositiontaking_1 = @old_auto_v99spositiontaking_1 AND
		@auto_v99spositiontaking_2 = @old_auto_v99spositiontaking_2 AND
		@auto_v99spositiontaking_3 = @old_auto_v99spositiontaking_3 AND
		@auto_v99spositiontaking_20 = @old_auto_v99spositiontaking_20 AND

		-- mixed sports
		@auto_v99spositiontaking_9 = @old_auto_v99spositiontaking_9 AND
		
		-- HR Fixed Odds
		@auto_v154spositiontaking_20 = @old_auto_v154spositiontaking_20 AND

		-- number game
		@auto_v161spositiontaking_81 = @old_auto_v161spositiontaking_81 AND
		@auto_v161spositiontaking_83 = @old_auto_v161spositiontaking_83 AND
		@auto_v161spositiontaking_86 = @old_auto_v161spositiontaking_86 AND
		@auto_v161spositiontaking_88 = @old_auto_v161spositiontaking_88 AND
		@auto_v161slivepositiontaking_85 = @old_auto_v161slivepositiontaking_85 AND
		@auto_v161slivepositiontaking_86 = @old_auto_v161slivepositiontaking_86 AND
		@auto_v161slivepositiontaking_87 = @old_auto_v161slivepositiontaking_87 AND
		@auto_v161slivepositiontaking_89 = @old_auto_v161slivepositiontaking_89 AND
		@auto_v161slivepositiontaking_90 = @old_auto_v161slivepositiontaking_90 AND
		
		@isauto_spositiontaking_1 = @old_isauto_spositiontaking_1 AND
		@isauto_spositiontaking_2 = @old_isauto_spositiontaking_2 AND
		@isauto_spositiontaking_3 = @old_isauto_spositiontaking_3 AND
		@isauto_spositiontaking_4 = @old_isauto_spositiontaking_4 AND
		@isauto_spositiontaking_5 = @old_isauto_spositiontaking_5 AND
		@isauto_spositiontaking_6 = @old_isauto_spositiontaking_6 AND
		@isauto_spositiontaking_7 = @old_isauto_spositiontaking_7 AND
		@isauto_spositiontaking_8 = @old_isauto_spositiontaking_8 AND
		@isauto_spositiontaking_9 = @old_isauto_spositiontaking_9 AND
		@isauto_spositiontaking_10 = @old_isauto_spositiontaking_10 AND
		@isauto_spositiontaking_9999 = @old_isauto_spositiontaking_9999 AND
		@isauto_slivepositiontaking_1 = @old_isauto_slivepositiontaking_1 AND
		@isauto_slivepositiontaking_3 = @old_isauto_slivepositiontaking_3 AND
		@isauto_slivepositiontaking_7 = @old_isauto_slivepositiontaking_7 AND
		@isauto_slivepositiontaking_8 = @old_isauto_slivepositiontaking_8 AND
		
		@isauto_v2spositiontaking_1 = @old_isauto_v2spositiontaking_1 AND
		@isauto_v2spositiontaking_2 = @old_isauto_v2spositiontaking_2 AND
		@isauto_v2spositiontaking_3 = @old_isauto_v2spositiontaking_3 AND
		@isauto_v2spositiontaking_7 = @old_isauto_v2spositiontaking_7 AND
		@isauto_v2spositiontaking_8 = @old_isauto_v2spositiontaking_8 AND
	--	@isauto_v2spositiontaking_9 = @old_isauto_v2spositiontaking_9 AND
		@isauto_v2spositiontaking_20 = @old_isauto_v2spositiontaking_20 AND
		
		@isauto_v3spositiontaking_1 = @old_isauto_v3spositiontaking_1 AND
		@isauto_v3spositiontaking_2 = @old_isauto_v3spositiontaking_2 AND
		@isauto_v3spositiontaking_3 = @old_isauto_v3spositiontaking_3 AND
		@isauto_v3spositiontaking_20 = @old_isauto_v3spositiontaking_20 AND
		
		@isauto_v5spositiontaking_1 = @old_isauto_v5spositiontaking_1 AND
		@isauto_v5spositiontaking_2 = @old_isauto_v5spositiontaking_2 AND
		@isauto_v5spositiontaking_3 = @old_isauto_v5spositiontaking_3 AND
		@isauto_v5spositiontaking_20 = @old_isauto_v5spositiontaking_20 AND
		@isauto_v5spositiontaking_9999 = @old_isauto_v5spositiontaking_9999 AND
		
		@isauto_v8spositiontaking_1 = @old_isauto_v8spositiontaking_1 AND
		@isauto_v8spositiontaking_3 = @old_isauto_v8spositiontaking_3 AND
		@isauto_v8spositiontaking_20 = @old_isauto_v8spositiontaking_20 AND
		
		@isauto_v10spositiontaking_1 = @old_isauto_v10spositiontaking_1 AND
		@isauto_v10spositiontaking_2 = @old_isauto_v10spositiontaking_2 AND
		@isauto_v10spositiontaking_3 = @old_isauto_v10spositiontaking_3 AND
		@isauto_v10spositiontaking_20 = @old_isauto_v10spositiontaking_20 AND
		
		@isauto_v11spositiontaking_1 = @old_isauto_v11spositiontaking_1 AND
		@isauto_v11spositiontaking_20 = @old_isauto_v11spositiontaking_20 AND
		
		@isauto_v99spositiontaking_1 = @old_isauto_v99spositiontaking_1 AND
		@isauto_v99spositiontaking_2 = @old_isauto_v99spositiontaking_2 AND
		@isauto_v99spositiontaking_3 = @old_isauto_v99spositiontaking_3 AND
		@isauto_v99spositiontaking_20 = @old_isauto_v99spositiontaking_20 AND

		-- mixed sports
		@isauto_v99spositiontaking_9 = @old_isauto_v99spositiontaking_9 AND
		
		-- HR Fixed Odds
		
		@isauto_v154spositiontaking_20 = @old_isauto_v154spositiontaking_20 AND

		-- number game
		@isauto_v161spositiontaking_81 = @old_isauto_v161spositiontaking_81 AND
		@isauto_v161spositiontaking_83 = @old_isauto_v161spositiontaking_83 AND
		@isauto_v161spositiontaking_86 = @old_isauto_v161spositiontaking_86 AND
		@isauto_v161spositiontaking_88 = @old_isauto_v161spositiontaking_88 AND
		@isauto_v161slivepositiontaking_85 = @old_isauto_v161slivepositiontaking_85 AND
		@isauto_v161slivepositiontaking_86 = @old_isauto_v161slivepositiontaking_86 AND
		@isauto_v161slivepositiontaking_87 = @old_isauto_v161slivepositiontaking_87 AND
		@isauto_v161slivepositiontaking_89 = @old_isauto_v161slivepositiontaking_89 AND
		@isauto_v161slivepositiontaking_90 = @old_isauto_v161slivepositiontaking_90 AND
		-- Outright PT for sports
		@v2spositiontaking_10 = @old_v2spositiontaking_10 AND
		@v3spositiontaking_10 = @old_v3spositiontaking_10 AND
		@v5spositiontaking_10 = @old_v5spositiontaking_10 AND
		@v8spositiontaking_10 = @old_v8spositiontaking_10 AND
		@v10spositiontaking_10 = @old_v10spositiontaking_10 AND
		@v11spositiontaking_10 = @old_v11spositiontaking_10 AND
		@v99spositiontaking_10 = @old_v99spositiontaking_10 AND
		
		@auto_v2spositiontaking_10 = @old_auto_v2spositiontaking_10 AND
		@auto_v3spositiontaking_10 = @old_auto_v3spositiontaking_10 AND
		@auto_v5spositiontaking_10 = @old_auto_v5spositiontaking_10 AND
		@auto_v8spositiontaking_10 = @old_auto_v8spositiontaking_10 AND
		@auto_v10spositiontaking_10 = @old_auto_v10spositiontaking_10 AND
		@auto_v11spositiontaking_10 = @old_auto_v11spositiontaking_10 AND
		@auto_v99spositiontaking_10 = @old_auto_v99spositiontaking_10 AND
		
		@isauto_v2spositiontaking_10 = @old_isauto_v2spositiontaking_10 AND
		@isauto_v3spositiontaking_10 = @old_isauto_v3spositiontaking_10 AND
		@isauto_v5spositiontaking_10 = @old_isauto_v5spositiontaking_10 AND
		@isauto_v8spositiontaking_10 = @old_isauto_v8spositiontaking_10 AND
		@isauto_v10spositiontaking_10 = @old_isauto_v10spositiontaking_10 AND
		@isauto_v11spositiontaking_10 = @old_isauto_v11spositiontaking_10 AND
		@isauto_v99spositiontaking_10 = @old_isauto_v99spositiontaking_10 


	BEGIN
		SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
		return
	END 
	
	
	--i3,m3
	Select 
		@isauto_smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_4 = max(case when mcs.bettype = 4 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_5 = max(case when mcs.bettype = 5 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_6 = max(case when mcs.bettype = 6 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_9 = max(case when mcs.bettype = 9 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		@isauto_smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		
		--outright PT for sports
		@isauto_v2smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v3smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v5smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v8smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),
		@isauto_v10smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v11smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=11 then mcs.isautopositiontaking else 0 end),
		@isauto_v99smpositiontaking_10 = max(case when mcs.bettype = 10 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		
		@isauto_smpositiontaking_9999 = max(case when mcs.bettype = 9999 and mcs.sporttype=1 then mcs.isautopositiontaking else 0 end),
		
		@isauto_smlivepositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
		@isauto_smlivepositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
		@isauto_smlivepositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),
		@isauto_smlivepositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=1 then mcs.isautolivepositiontaking else 0 end),

		@isauto_v2smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2smpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2smpositiontaking_7 = max(case when mcs.bettype = 7 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),
		@isauto_v2smpositiontaking_8 = max(case when mcs.bettype = 8 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),	
		@isauto_v2smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=2 then mcs.isautopositiontaking else 0 end),

		@isauto_v3smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v3smpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v3smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),
		@isauto_v3smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=3 then mcs.isautopositiontaking else 0 end),

		@isauto_v5smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5smpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),
		@isauto_v5smpositiontaking_9999 = max(case when mcs.bettype = 9999 and mcs.sporttype=5 then mcs.isautopositiontaking else 0 end),

		@isauto_v8smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),
		@isauto_v8smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),
		@isauto_v8smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=8 then mcs.isautopositiontaking else 0 end),

		@isauto_v10smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v10smpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v10smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),
		@isauto_v10smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=10 then mcs.isautopositiontaking else 0 end),

		@isauto_v11smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=11 then mcs.isautopositiontaking else 0 end),
		@isauto_v11smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=11 then mcs.isautopositiontaking else 0 end),

		@isauto_v99smpositiontaking_1 = max(case when mcs.bettype = 1 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99smpositiontaking_2 = max(case when mcs.bettype = 2 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99smpositiontaking_3 = max(case when mcs.bettype = 3 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		@isauto_v99smpositiontaking_20 = max(case when mcs.bettype = 20 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		
		

		@isauto_v99smpositiontaking_9 = max(case when mcs.bettype = 9 and mcs.sporttype=99 then mcs.isautopositiontaking else 0 end),
		
		-- HR Fixed Odds
		@isauto_v154smpositiontaking_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype = 154 THEN mcs.isautopositiontaking ELSE 0 END),
		
		--m3
		@mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_4 = MAX(CASE WHEN mcs.bettype = 4 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_5 = MAX(CASE WHEN mcs.bettype = 5 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_6 = MAX(CASE WHEN mcs.bettype = 6 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_7 = MAX(CASE WHEN mcs.bettype = 7 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_8 = MAX(CASE WHEN mcs.bettype = 8 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_9 = MAX(CASE WHEN mcs.bettype = 9 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		@mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  
		-- Outrignt PT for sports
		@v2mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v8mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v11mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=11 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpos_10 = MAX(CASE WHEN mcs.bettype = 10 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		
		@mpos_9999 = MAX(CASE WHEN mcs.bettype = 9999 AND mcs.sporttype=1 THEN mcs.mpositiontaking ELSE 0 END),  

		@mlivepos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  
		@mlivepos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  
		@mlivepos_7 = MAX(CASE WHEN mcs.bettype = 7 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  
		@mlivepos_8 = MAX(CASE WHEN mcs.bettype = 8 AND mcs.sporttype=1 THEN mcs.mlivepositiontaking ELSE 0 END),  

		@v2mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpos_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpos_7 = MAX(CASE WHEN mcs.bettype = 7 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  
		@v2mpos_8 = MAX(CASE WHEN mcs.bettype = 8 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  	
		@v2mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=2 THEN mcs.mpositiontaking ELSE 0 END),  

		@v3mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpos_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  
		@v3mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=3 THEN mcs.mpositiontaking ELSE 0 END),  

		@v5mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpos_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  
		@v5mpos_9999 = MAX(CASE WHEN mcs.bettype = 9999 AND mcs.sporttype=5 THEN mcs.mpositiontaking ELSE 0 END),  

		@v8mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  
		@v8mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  
		@v8mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=8 THEN mcs.mpositiontaking ELSE 0 END),  

		@v10mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpos_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  
		@v10mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=10 THEN mcs.mpositiontaking ELSE 0 END),  

		@v11mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=11 THEN mcs.mpositiontaking ELSE 0 END),  
		@v11mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=11 THEN mcs.mpositiontaking ELSE 0 END),  
		
		@v99mpos_1 = MAX(CASE WHEN mcs.bettype = 1 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpos_2 = MAX(CASE WHEN mcs.bettype = 2 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpos_3 = MAX(CASE WHEN mcs.bettype = 3 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),  
		@v99mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),
			
		@v99mpos_9 = MAX(CASE WHEN mcs.bettype = 9 AND mcs.sporttype=99 THEN mcs.mpositiontaking ELSE 0 END),
		
		-- HR Fixed Odds
		@v154mpos_20 = MAX(CASE WHEN mcs.bettype = 20 AND mcs.sporttype = 154 THEN mcs.mpositiontaking ELSE 0 END)
		  
	From custsetting mcs with (NOLOCK)
	WHERE custid = @mrecommend

	SELECT
		@isauto_v161smpositiontaking_81 = max(case when mcs3.bettype = 81 and mcs3.sporttype=161 then mcs3.isautopositiontaking else 0 end),
		@isauto_v161smpositiontaking_83 = max(case when mcs3.bettype = 83 and mcs3.sporttype=161 then mcs3.isautopositiontaking else 0 end),	
		@isauto_v161smpositiontaking_86 = max(case when mcs3.bettype = 86 and mcs3.sporttype=161 then mcs3.isautopositiontaking else 0 end),
		@isauto_v161smpositiontaking_88 = max(case when mcs3.bettype = 88 and mcs3.sporttype=161 then mcs3.isautopositiontaking else 0 end),
		
		@isauto_v161smlivepositiontaking_85 = max(case when mcs3.bettype = 85 and mcs3.sporttype=161 then mcs3.isautolivepositiontaking else 0 end),
		@isauto_v161smlivepositiontaking_86 = max(case when mcs3.bettype = 86 and mcs3.sporttype=161 then mcs3.isautolivepositiontaking else 0 end),
		@isauto_v161smlivepositiontaking_87 = max(case when mcs3.bettype = 87 and mcs3.sporttype=161 then mcs3.isautolivepositiontaking else 0 end),
		@isauto_v161smlivepositiontaking_89 = max(case when mcs3.bettype = 89 and mcs3.sporttype=161 then mcs3.isautolivepositiontaking else 0 end),
		@isauto_v161smlivepositiontaking_90 = max(case when mcs3.bettype = 90 and mcs3.sporttype=161 then mcs3.isautolivepositiontaking else 0 end),
		
		@v161mpos_81 = MAX(CASE WHEN mcs3.bettype = 81 AND mcs3.sporttype=161 THEN mcs3.mpositiontaking ELSE 0 END),  
		@v161mpos_83 = MAX(CASE WHEN mcs3.bettype = 83 AND mcs3.sporttype=161 THEN mcs3.mpositiontaking ELSE 0 END),  	
		@v161mpos_86 = MAX(CASE WHEN mcs3.bettype = 86 AND mcs3.sporttype=161 THEN mcs3.mpositiontaking ELSE 0 END),
		@v161mpos_88 = MAX(CASE WHEN mcs3.bettype = 88 AND mcs3.sporttype=161 THEN mcs3.mpositiontaking ELSE 0 END),  
		
		@v161mlivepos_85 = MAX(CASE WHEN mcs3.bettype = 85 AND mcs3.sporttype=161 THEN mcs3.mlivepositiontaking ELSE 0 END),  
		@v161mlivepos_86 = MAX(CASE WHEN mcs3.bettype = 86 AND mcs3.sporttype=161 THEN mcs3.mlivepositiontaking ELSE 0 END),  
		@v161mlivepos_87 = MAX(CASE WHEN mcs3.bettype = 87 AND mcs3.sporttype=161 THEN mcs3.mlivepositiontaking ELSE 0 END),
		@v161mlivepos_89 = MAX(CASE WHEN mcs3.bettype = 89 AND mcs3.sporttype=161 THEN mcs3.mlivepositiontaking ELSE 0 END),
		@v161mlivepos_90 = MAX(CASE WHEN mcs3.bettype = 90 AND mcs3.sporttype=161 THEN mcs3.mlivepositiontaking ELSE 0 END)	
	FROM  custsetting3rd mcs3 with (NOLOCK)
	where custid = @mrecommend

	SELECT  
	--s1_max = min(s4,l4)  - m3
		@mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_4_max = MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_5_max = MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_6_max = MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_7_max = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_8_max = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_9_max = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		-- Outright PT for sports
		@v2mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v8mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v11mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_10_max = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		@mspositiontaking_9999_max = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@mslivepositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  
		@mslivepositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  
		@mslivepositiontaking_7_max = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  
		@mslivepositiontaking_8_max = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END ELSE 0 END),  

		@v2mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_7_max = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v2mspositiontaking_8_max = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  	
		@v2mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v3mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v3mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v5mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v5mspositiontaking_9999_max = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v8mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v8mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v8mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v10mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v10mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  

		@v11mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v11mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		
		@v99mspositiontaking_1_max = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_2_max = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_3_max = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
		@v99mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),  
			
		@v99mspositiontaking_9_max = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),
		
		-- HR Fixed Odds
		@v154mspositiontaking_20_max = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype = 154 THEN CASE WHEN cs.spositiontaking< co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END ELSE 0 END),
	
	--s1_min = max(n4-m1-a1,0)
		@mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_4_min = MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_5_min = MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_6_min = MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_7_min = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_8_min = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_9_min = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		@mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  
		
		-- Outright PT for sports
		
		@v2mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v8mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v11mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		
		@mspositiontaking_9999_min = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN co.minpositiontaking ELSE 0 END),  

		@mslivepositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  
		@mslivepositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  
		@mslivepositiontaking_7_min = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  
		@mslivepositiontaking_8_min = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN co.minlivepositiontaking ELSE 0 END),  

		@v2mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_7_min = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_8_min = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  
		@v2mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN co.minpositiontaking ELSE 0 END),  

		@v3mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  
		@v3mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN co.minpositiontaking ELSE 0 END),  

		@v5mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  
		@v5mspositiontaking_9999_min = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN co.minpositiontaking ELSE 0 END),  

		@v8mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  
		@v8mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  
		@v8mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN co.minpositiontaking ELSE 0 END),  

		@v10mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  
		@v10mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN co.minpositiontaking ELSE 0 END),  

		@v11mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN co.minpositiontaking ELSE 0 END),  
		@v11mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN co.minpositiontaking ELSE 0 END),  
		
		@v99mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		@v99mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
			
		@v99mspositiontaking_9_min = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN co.minpositiontaking ELSE 0 END),  
		
		-- HR Fixed Odds
		@v154mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype = 154 THEN co.minpositiontaking ELSE 0 END)
	
	FROM 	
		CustSetting AS cs WITH (NOLOCK)
	LEFT JOIN custoverride AS co WITH (NOLOCK) ON cs.custid = co.custid AND cs.sporttype=co.sporttype AND cs.bettype=co.bettype  

	WHERE cs.CustID = @srecommend
	
	SELECT
		@v161mspositiontaking_81_max = MAX(CASE WHEN cs3.bettype = 81 AND cs3.sporttype=161 THEN CASE WHEN cs3.spositiontaking<co3.maxpositiontaking THEN cs3.spositiontaking ELSE co3.maxpositiontaking END ELSE 0 END),  
		@v161mspositiontaking_83_max = MAX(CASE WHEN cs3.bettype = 83 AND cs3.sporttype=161 THEN CASE WHEN cs3.spositiontaking<co3.maxpositiontaking THEN cs3.spositiontaking ELSE co3.maxpositiontaking END ELSE 0 END),  	
		@v161mspositiontaking_86_max = MAX(CASE WHEN cs3.bettype = 86 AND cs3.sporttype=161 THEN CASE WHEN cs3.spositiontaking<co3.maxpositiontaking THEN cs3.spositiontaking ELSE co3.maxpositiontaking END ELSE 0 END),
		@v161mspositiontaking_88_max = MAX(CASE WHEN cs3.bettype = 88 AND cs3.sporttype=161 THEN CASE WHEN cs3.spositiontaking<co3.maxpositiontaking THEN cs3.spositiontaking ELSE co3.maxpositiontaking END ELSE 0 END),  	  
		
		@v161mslivepositiontaking_85_max = MAX(CASE WHEN cs3.bettype = 85 AND cs3.sporttype=161 THEN CASE WHEN cs3.slivepositiontaking<co3.maxlivepositiontaking THEN cs3.slivepositiontaking ELSE co3.maxlivepositiontaking END ELSE 0 END),  
		@v161mslivepositiontaking_86_max = MAX(CASE WHEN cs3.bettype = 86 AND cs3.sporttype=161 THEN CASE WHEN cs3.slivepositiontaking<co3.maxlivepositiontaking THEN cs3.slivepositiontaking ELSE co3.maxlivepositiontaking END ELSE 0 END),  
		@v161mslivepositiontaking_87_max = MAX(CASE WHEN cs3.bettype = 87 AND cs3.sporttype=161 THEN CASE WHEN cs3.slivepositiontaking<co3.maxlivepositiontaking THEN cs3.slivepositiontaking ELSE co3.maxlivepositiontaking END ELSE 0 END),  
		@v161mslivepositiontaking_89_max = MAX(CASE WHEN cs3.bettype = 89 AND cs3.sporttype=161 THEN CASE WHEN cs3.slivepositiontaking<co3.maxlivepositiontaking THEN cs3.slivepositiontaking ELSE co3.maxlivepositiontaking END ELSE 0 END),  
		@v161mslivepositiontaking_90_max = MAX(CASE WHEN cs3.bettype = 90 AND cs3.sporttype=161 THEN CASE WHEN cs3.slivepositiontaking<co3.maxlivepositiontaking THEN cs3.slivepositiontaking ELSE co3.maxlivepositiontaking END ELSE 0 END),		
		
		@v161mspositiontaking_81_min = MAX(CASE WHEN cs3.bettype = 81 AND cs3.sporttype=161 THEN co3.minpositiontaking ELSE 0 END),  
		@v161mspositiontaking_83_min = MAX(CASE WHEN cs3.bettype = 83 AND cs3.sporttype=161 THEN co3.minpositiontaking ELSE 0 END),  
		@v161mspositiontaking_86_min = MAX(CASE WHEN cs3.bettype = 86 AND cs3.sporttype=161 THEN co3.minpositiontaking ELSE 0 END),  
		@v161mspositiontaking_88_min = MAX(CASE WHEN cs3.bettype = 88 AND cs3.sporttype=161 THEN co3.minpositiontaking ELSE 0 END),  
		
		@v161mslivepositiontaking_85_min = MAX(CASE WHEN cs3.bettype = 85 AND cs3.sporttype=161 THEN co3.minlivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_86_min = MAX(CASE WHEN cs3.bettype = 86 AND cs3.sporttype=161 THEN co3.minlivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_87_min = MAX(CASE WHEN cs3.bettype = 87 AND cs3.sporttype=161 THEN co3.minlivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_89_min = MAX(CASE WHEN cs3.bettype = 89 AND cs3.sporttype=161 THEN co3.minlivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_90_min = MAX(CASE WHEN cs3.bettype = 90 AND cs3.sporttype=161 THEN co3.minlivepositiontaking ELSE 0 END)

	FROM 
		CustSetting3rd as cs3 WITH (NOLOCK) 
	LEFT join custoverride3rd as co3 WITH (NOLOCK) on cs3.custid = co3.custid AND cs3.sporttype=co3.sporttype AND cs3.bettype=co3.bettype 
	WHERE cs3.CustID = @srecommend 
	
		
	--min_s1 = max(n4-m1-a1,0)
	SELECT @mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN @mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=1 THEN @mspositiontaking_2_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN @mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_4_min = MAX(CASE WHEN cs.bettype = 4 AND cs.sporttype=1 THEN @mspositiontaking_4_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_5_min = MAX(CASE WHEN cs.bettype = 5 AND cs.sporttype=1 THEN @mspositiontaking_5_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_6_min = MAX(CASE WHEN cs.bettype = 6 AND cs.sporttype=1 THEN @mspositiontaking_6_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_7_min = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN @mspositiontaking_7_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_8_min = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN @mspositiontaking_8_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_9_min = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=1 THEN @mspositiontaking_9_min - mpositiontaking - apositiontaking ELSE 0 END),
			@mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=1 THEN @mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			-- Outright PT for sports
			@v2mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=2 THEN @v2mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v3mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=3 THEN @v3mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v5mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=5 THEN @v5mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v8mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=8 THEN @v8mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v10mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=10 THEN @v10mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v11mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=11 THEN @v11mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v99mspositiontaking_10_min = MAX(CASE WHEN cs.bettype = 10 AND cs.sporttype=99 THEN @v99mspositiontaking_10_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			
			@mspositiontaking_9999_min = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=1 THEN @mspositiontaking_9999_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@mslivepositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=1 THEN @mslivepositiontaking_1_min - mlivepositiontaking - alivepositiontaking ELSE 0 END),
			@mslivepositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=1 THEN @mslivepositiontaking_3_min - mlivepositiontaking - alivepositiontaking ELSE 0 END),
			@mslivepositiontaking_7_min = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=1 THEN @mslivepositiontaking_7_min - mlivepositiontaking - alivepositiontaking ELSE 0 END),
			@mslivepositiontaking_8_min = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=1 THEN @mslivepositiontaking_8_min - mlivepositiontaking - alivepositiontaking ELSE 0 END),
			
			@v2mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=2 THEN @v2mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v2mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=2 THEN @v2mspositiontaking_2_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v2mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=2 THEN @v2mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v2mspositiontaking_7_min = MAX(CASE WHEN cs.bettype = 7 AND cs.sporttype=2 THEN @v2mspositiontaking_7_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v2mspositiontaking_8_min = MAX(CASE WHEN cs.bettype = 8 AND cs.sporttype=2 THEN @v2mspositiontaking_8_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v2mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=2 THEN @v2mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v3mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=3 THEN @v3mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v3mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=3 THEN @v3mspositiontaking_2_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v3mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=3 THEN @v3mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v3mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=3 THEN @v3mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v5mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=5 THEN @v5mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v5mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=5 THEN @v5mspositiontaking_2_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v5mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=5 THEN @v5mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v5mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=5 THEN @v5mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v5mspositiontaking_9999_min = MAX(CASE WHEN cs.bettype = 9999 AND cs.sporttype=5 THEN @v5mspositiontaking_9999_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v8mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=8 THEN @v8mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v8mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=8 THEN @v8mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v8mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=8 THEN @v8mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v10mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=10 THEN @v10mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v10mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=10 THEN @v10mspositiontaking_2_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v10mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=10 THEN @v10mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v10mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=10 THEN @v10mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v11mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=11 THEN @v11mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),			
			@v11mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=11 THEN @v11mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v99mspositiontaking_1_min = MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype=99 THEN @v99mspositiontaking_1_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v99mspositiontaking_2_min = MAX(CASE WHEN cs.bettype = 2 AND cs.sporttype=99 THEN @v99mspositiontaking_2_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v99mspositiontaking_3_min = MAX(CASE WHEN cs.bettype = 3 AND cs.sporttype=99 THEN @v99mspositiontaking_3_min - mpositiontaking - apositiontaking ELSE 0 END),
			@v99mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=99 THEN @v99mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v99mspositiontaking_9_min = MAX(CASE WHEN cs.bettype = 9 AND cs.sporttype=99 THEN @v99mspositiontaking_9_min - mpositiontaking - apositiontaking ELSE 0 END),
			
			@v154mspositiontaking_20_min = MAX(CASE WHEN cs.bettype = 20 AND cs.sporttype=154 THEN @v154mspositiontaking_20_min - mpositiontaking - apositiontaking ELSE 0 END)
	FROM CustSetting cs WITH(NOLOCK)
		
	WHERE custid = @custid 
	
	SELECT @v161mspositiontaking_81_min = MAX(CASE WHEN cs3.bettype = 81 AND cs3.sporttype=161 THEN @v161mspositiontaking_81_min - cs3.mpositiontaking - cs3.apositiontaking ELSE 0 END),  
		@v161mspositiontaking_83_min = MAX(CASE WHEN cs3.bettype = 83 AND cs3.sporttype=161 THEN @v161mspositiontaking_83_min - cs3.mpositiontaking - cs3.apositiontaking ELSE 0 END),  
		@v161mspositiontaking_86_min = MAX(CASE WHEN cs3.bettype = 86 AND cs3.sporttype=161 THEN @v161mspositiontaking_86_min - cs3.mpositiontaking - cs3.apositiontaking ELSE 0 END),  
		@v161mspositiontaking_88_min = MAX(CASE WHEN cs3.bettype = 88 AND cs3.sporttype=161 THEN @v161mspositiontaking_88_min - cs3.mpositiontaking - cs3.apositiontaking ELSE 0 END),  
		
		@v161mslivepositiontaking_85_min = MAX(CASE WHEN cs3.bettype = 85 AND cs3.sporttype=161 THEN @v161mslivepositiontaking_85_min - cs3.mlivepositiontaking - cs3.alivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_86_min = MAX(CASE WHEN cs3.bettype = 86 AND cs3.sporttype=161 THEN @v161mslivepositiontaking_86_min - cs3.mlivepositiontaking - cs3.alivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_87_min = MAX(CASE WHEN cs3.bettype = 87 AND cs3.sporttype=161 THEN @v161mslivepositiontaking_87_min - cs3.mlivepositiontaking - cs3.alivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_89_min = MAX(CASE WHEN cs3.bettype = 89 AND cs3.sporttype=161 THEN @v161mslivepositiontaking_89_min - cs3.mlivepositiontaking - cs3.alivepositiontaking ELSE 0 END),  
		@v161mslivepositiontaking_90_min = MAX(CASE WHEN cs3.bettype = 90 AND cs3.sporttype=161 THEN @v161mslivepositiontaking_90_min - cs3.mlivepositiontaking - cs3.alivepositiontaking ELSE 0 END)

	FROM CustSetting3rd cs3 WITH(NOLOCK)
	
	WHERE custid = @custid 
	
	
	--s1_max = max(min(s4,l4) - m3,s1_min)	
	SELECT @mspositiontaking_1_max = case when @mspositiontaking_1_max - @mpos_1 > @mspositiontaking_1_min THEN @mspositiontaking_1_max - @mpos_1 ELSE @mspositiontaking_1_min end,
			@mspositiontaking_2_max = case when @mspositiontaking_2_max - @mpos_2 > @mspositiontaking_2_min THEN @mspositiontaking_2_max - @mpos_2 ELSE @mspositiontaking_2_min end,
			@mspositiontaking_3_max = case when @mspositiontaking_3_max - @mpos_3 > @mspositiontaking_3_min THEN @mspositiontaking_3_max - @mpos_3 ELSE @mspositiontaking_3_min end,
			@mspositiontaking_4_max = case when @mspositiontaking_4_max - @mpos_4 > @mspositiontaking_4_min THEN @mspositiontaking_4_max - @mpos_4 ELSE @mspositiontaking_4_min end,
			@mspositiontaking_5_max = case when @mspositiontaking_5_max - @mpos_5 > @mspositiontaking_5_min THEN @mspositiontaking_5_max - @mpos_5 ELSE @mspositiontaking_5_min  end,
			@mspositiontaking_6_max = case when @mspositiontaking_6_max - @mpos_6 > @mspositiontaking_6_min THEN @mspositiontaking_6_max - @mpos_6 ELSE @mspositiontaking_6_min end,
			@mspositiontaking_7_max = case when @mspositiontaking_7_max - @mpos_7 > @mspositiontaking_7_min THEN @mspositiontaking_7_max - @mpos_7 ELSE @mspositiontaking_7_min end,
			@mspositiontaking_8_max = case when @mspositiontaking_8_max - @mpos_8 > @mspositiontaking_8_min THEN @mspositiontaking_8_max - @mpos_8 ELSE @mspositiontaking_8_min  end,
			@mspositiontaking_9_max = case when @mspositiontaking_9_max - @mpos_9 > @mspositiontaking_9_min THEN @mspositiontaking_9_max - @mpos_9 ELSE @mspositiontaking_9_min end,
			@mspositiontaking_10_max = case when @mspositiontaking_10_max - @mpos_10 > @mspositiontaking_10_min THEN @mspositiontaking_10_max - @mpos_10 ELSE @mspositiontaking_10_min end,
			
			-- Outright PT for sports
			@v2mspositiontaking_10_max = case when @v2mspositiontaking_10_max - @v2mpos_10 > @v2mspositiontaking_10_min THEN @v2mspositiontaking_10_max - @v2mpos_10 ELSE @v2mspositiontaking_10_min end,
			@v3mspositiontaking_10_max = case when @v3mspositiontaking_10_max - @v3mpos_10 > @v3mspositiontaking_10_min THEN @v3mspositiontaking_10_max - @v3mpos_10 ELSE @v3mspositiontaking_10_min end,
			@v5mspositiontaking_10_max = case when @v5mspositiontaking_10_max - @v5mpos_10 > @v5mspositiontaking_10_min THEN @v5mspositiontaking_10_max - @v5mpos_10 ELSE @v5mspositiontaking_10_min end,
			@v8mspositiontaking_10_max = case when @v8mspositiontaking_10_max - @v8mpos_10 > @v8mspositiontaking_10_min THEN @v8mspositiontaking_10_max - @v8mpos_10 ELSE @v8mspositiontaking_10_min end,
			@v10mspositiontaking_10_max = case when @v10mspositiontaking_10_max - @v10mpos_10 > @v10mspositiontaking_10_min THEN @v10mspositiontaking_10_max - @v10mpos_10 ELSE @v10mspositiontaking_10_min end,
			@v11mspositiontaking_10_max = case when @v11mspositiontaking_10_max - @v11mpos_10 > @v11mspositiontaking_10_min THEN @v11mspositiontaking_10_max - @v11mpos_10 ELSE @v11mspositiontaking_10_min end,
			@v99mspositiontaking_10_max = case when @v99mspositiontaking_10_max - @v99mpos_10 > @v99mspositiontaking_10_min THEN @v99mspositiontaking_10_max - @v99mpos_10 ELSE @v99mspositiontaking_10_min end,
			
			@mspositiontaking_9999_max = case when @mspositiontaking_9999_max - @mpos_9999 > @mspositiontaking_9999_min THEN @mspositiontaking_9999_max - @mpos_9999 ELSE @mspositiontaking_9999_min end,
			
			@mslivepositiontaking_1_max = case when @mslivepositiontaking_1_max - @mlivepos_1 > @mslivepositiontaking_1_min THEN @mslivepositiontaking_1_max - @mlivepos_1 ELSE @mslivepositiontaking_1_min end,
			@mslivepositiontaking_3_max = case when @mslivepositiontaking_3_max - @mlivepos_3 > @mslivepositiontaking_3_min THEN @mslivepositiontaking_3_max - @mlivepos_3 ELSE @mslivepositiontaking_3_min end,
			@mslivepositiontaking_7_max = case when @mslivepositiontaking_7_max - @mlivepos_7 > @mslivepositiontaking_7_min THEN @mslivepositiontaking_7_max - @mlivepos_7 ELSE @mslivepositiontaking_7_min end,
			@mslivepositiontaking_8_max = case when @mslivepositiontaking_8_max - @mlivepos_8 > @mslivepositiontaking_8_min THEN @mslivepositiontaking_8_max - @mlivepos_8 ELSE @mslivepositiontaking_8_min end,
			
			@v2mspositiontaking_1_max = case when @v2mspositiontaking_1_max - @v2mpos_1 > @v2mspositiontaking_1_min THEN @v2mspositiontaking_1_max - @v2mpos_1 ELSE @v2mspositiontaking_1_min end ,
			@v2mspositiontaking_2_max = case when @v2mspositiontaking_2_max - @v2mpos_2 > @v2mspositiontaking_2_min THEN @v2mspositiontaking_2_max - @v2mpos_2 ELSE @v2mspositiontaking_2_min end,
			@v2mspositiontaking_3_max = case when @v2mspositiontaking_3_max - @v2mpos_3 > @v2mspositiontaking_3_min THEN @v2mspositiontaking_3_max - @v2mpos_3 ELSE @v2mspositiontaking_3_min end ,			
			@v2mspositiontaking_7_max = case when @v2mspositiontaking_7_max - @v2mpos_7 > @v2mspositiontaking_7_min THEN @v2mspositiontaking_7_max - @v2mpos_7 ELSE @v2mspositiontaking_7_min end,
			@v2mspositiontaking_8_max = case when @v2mspositiontaking_8_max - @v2mpos_8 > @v2mspositiontaking_8_min THEN @v2mspositiontaking_8_max - @v2mpos_8 ELSE @v2mspositiontaking_8_min end,
			@v2mspositiontaking_20_max = case when @v2mspositiontaking_20_max - @v2mpos_20 > @v2mspositiontaking_20_min THEN @v2mspositiontaking_20_max - @v2mpos_20 ELSE @v2mspositiontaking_20_min end,
			
			@v3mspositiontaking_1_max = case when @v3mspositiontaking_1_max - @v3mpos_1 > @v3mspositiontaking_1_min THEN @v3mspositiontaking_1_max - @v3mpos_1 ELSE @v3mspositiontaking_1_min end,
			@v3mspositiontaking_2_max = case when @v3mspositiontaking_2_max - @v3mpos_2 > @v3mspositiontaking_2_min THEN @v3mspositiontaking_2_max - @v3mpos_2 ELSE @v3mspositiontaking_2_min end,
			@v3mspositiontaking_3_max = case when @v3mspositiontaking_3_max - @v3mpos_3 > @v3mspositiontaking_3_min THEN @v3mspositiontaking_3_max - @v3mpos_3 ELSE @v3mspositiontaking_3_min end,
			@v3mspositiontaking_20_max = case when @v3mspositiontaking_20_max - @v3mpos_20 > @v3mspositiontaking_20_min THEN @v3mspositiontaking_20_max - @v3mpos_20 ELSE @v3mspositiontaking_20_min end,
			
			@v5mspositiontaking_1_max = case when @v5mspositiontaking_1_max - @v5mpos_1 > @v5mspositiontaking_1_min THEN @v5mspositiontaking_1_max - @v5mpos_1 ELSE @v5mspositiontaking_1_min end ,
			@v5mspositiontaking_2_max = case when @v5mspositiontaking_2_max - @v5mpos_2 > @v5mspositiontaking_2_min THEN @v5mspositiontaking_3_max - @v5mpos_2 ELSE @v5mspositiontaking_2_min end ,
			@v5mspositiontaking_3_max = case when @v5mspositiontaking_3_max - @v5mpos_3 > @v5mspositiontaking_3_min THEN @v5mspositiontaking_3_max - @v5mpos_3 ELSE @v5mspositiontaking_3_min end ,
			@v5mspositiontaking_20_max = case when @v5mspositiontaking_20_max - @v5mpos_20 > @v5mspositiontaking_20_min THEN @v5mspositiontaking_20_max - @v5mpos_20 ELSE @v5mspositiontaking_20_min end ,
			@v5mspositiontaking_9999_max = case when @v5mspositiontaking_9999_max - @v5mpos_9999 > @v5mspositiontaking_9999_min THEN @v5mspositiontaking_9999_max - @v5mpos_9999 ELSE @v5mspositiontaking_9999_min end ,
			
			@v8mspositiontaking_1_max = case when @v8mspositiontaking_1_max - @v8mpos_1 > @v8mspositiontaking_1_min THEN @v8mspositiontaking_1_max - @v8mpos_1 ELSE @v8mspositiontaking_1_min end,
			@v8mspositiontaking_3_max = case when @v8mspositiontaking_3_max - @v8mpos_3 > @v8mspositiontaking_3_min THEN @v8mspositiontaking_3_max - @v8mpos_3 ELSE @v8mspositiontaking_3_min end,
			@v8mspositiontaking_20_max = case when @v8mspositiontaking_20_max - @v8mpos_20 > @v8mspositiontaking_20_min THEN @v8mspositiontaking_20_max - @v8mpos_20 ELSE @v8mspositiontaking_20_min end,
			
			@v10mspositiontaking_1_max = case when @v10mspositiontaking_1_max - @v10mpos_1 > @v10mspositiontaking_1_min THEN @v10mspositiontaking_1_max - @v10mpos_1 ELSE @v10mspositiontaking_1_min end,
			@v10mspositiontaking_2_max = case when @v10mspositiontaking_2_max - @v10mpos_2 > @v10mspositiontaking_2_min THEN @v10mspositiontaking_2_max - @v10mpos_2 ELSE @v10mspositiontaking_2_min end,
			@v10mspositiontaking_3_max = case when @v10mspositiontaking_3_max - @v10mpos_3 > @v10mspositiontaking_3_min THEN @v10mspositiontaking_3_max - @v10mpos_3 ELSE @v10mspositiontaking_3_min end,
			@v10mspositiontaking_20_max = case when @v10mspositiontaking_20_max - @v10mpos_20 > @v10mspositiontaking_20_min THEN @v10mspositiontaking_20_max - @v10mpos_20 ELSE @v10mspositiontaking_20_min end,
			
			@v11mspositiontaking_1_max = case when @v11mspositiontaking_1_max - @v11mpos_1 > @v11mspositiontaking_1_min THEN @v11mspositiontaking_1_max - @v11mpos_1 ELSE @v11mspositiontaking_1_min end,
			@v11mspositiontaking_20_max = case when @v11mspositiontaking_20_max - @v11mpos_20 > @v11mspositiontaking_20_min THEN @v11mspositiontaking_20_max - @v11mpos_20 ELSE @v11mspositiontaking_20_min end,
			
			@v99mspositiontaking_1_max = case when @v99mspositiontaking_1_max - @v99mpos_1 > @v99mspositiontaking_1_min THEN @v99mspositiontaking_1_max - @v99mpos_1 ELSE @v99mspositiontaking_1_min end,
			@v99mspositiontaking_2_max = case when @v99mspositiontaking_2_max - @v99mpos_2 > @v99mspositiontaking_2_min THEN @v99mspositiontaking_2_max - @v99mpos_2 ELSE @v99mspositiontaking_2_min end,
			@v99mspositiontaking_3_max = case when @v99mspositiontaking_3_max - @v99mpos_3 > @v99mspositiontaking_3_min THEN @v99mspositiontaking_3_max - @v99mpos_3 ELSE @v99mspositiontaking_3_min end,
			@v99mspositiontaking_20_max = case when @v99mspositiontaking_20_max - @v99mpos_20 > @v99mspositiontaking_20_min THEN @v99mspositiontaking_20_max - @v99mpos_20 ELSE @v99mspositiontaking_20_min end,
			
			@v99mspositiontaking_9_max = case when @v99mspositiontaking_9_max - @v99mpos_9 > @v99mspositiontaking_9_min THEN @v99mspositiontaking_9_max - @v99mpos_9 ELSE @v99mspositiontaking_9_min end,
			
			@v154mspositiontaking_20_max = case when @v154mspositiontaking_20_max - @v154mpos_20 > @v154mspositiontaking_20_min THEN @v154mspositiontaking_20_max - @v154mpos_20 ELSE @v154mspositiontaking_20_min end
	
	SELECT
		@v161mspositiontaking_81_max = 	case when @v161mspositiontaking_81_max - @v161mpos_81 > @v161mspositiontaking_81_min THEN @v161mspositiontaking_81_max - @v161mpos_81 ELSE @v161mspositiontaking_81_min end ,
		@v161mspositiontaking_83_max = 	case when @v161mspositiontaking_83_max - @v161mpos_83 > @v161mspositiontaking_83_min THEN @v161mspositiontaking_83_max - @v161mpos_83 ELSE @v161mspositiontaking_83_min end ,
		@v161mspositiontaking_86_max = 	case when @v161mspositiontaking_86_max - @v161mpos_86 > @v161mspositiontaking_86_min THEN @v161mspositiontaking_86_max - @v161mpos_86 ELSE @v161mspositiontaking_86_min end ,
		@v161mspositiontaking_88_max = 	case when @v161mspositiontaking_88_max - @v161mpos_88 > @v161mspositiontaking_88_min THEN @v161mspositiontaking_88_max - @v161mpos_88 ELSE @v161mspositiontaking_88_min end ,
		
		@v161mslivepositiontaking_85_max = case when @v161mslivepositiontaking_85_max - @v161mlivepos_85 > @v161mslivepositiontaking_85_min THEN @v161mslivepositiontaking_85_max - @v161mlivepos_85 ELSE @v161mslivepositiontaking_85_min end,
		@v161mslivepositiontaking_86_max = case when @v161mslivepositiontaking_86_max - @v161mlivepos_86 > @v161mslivepositiontaking_86_min THEN @v161mslivepositiontaking_86_max - @v161mlivepos_86 ELSE @v161mslivepositiontaking_86_min end,
		@v161mslivepositiontaking_87_max = case when @v161mslivepositiontaking_87_max - @v161mlivepos_87 > @v161mslivepositiontaking_87_min THEN @v161mslivepositiontaking_87_max - @v161mlivepos_87 ELSE @v161mslivepositiontaking_87_min end,
		@v161mslivepositiontaking_89_max = case when @v161mslivepositiontaking_89_max - @v161mlivepos_89 > @v161mslivepositiontaking_89_min THEN @v161mslivepositiontaking_89_max - @v161mlivepos_89 ELSE @v161mslivepositiontaking_89_min end,
		@v161mslivepositiontaking_90_max = case when @v161mslivepositiontaking_90_max - @v161mlivepos_90 > @v161mslivepositiontaking_90_min THEN @v161mslivepositiontaking_90_max - @v161mlivepos_90 ELSE @v161mslivepositiontaking_90_min end
	
			
	if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
		BEGIN --@UpdatePositiontaking 
			if 
				@spositiontaking_1  <0 OR @spositiontaking_1  >0.9
				OR @spositiontaking_2  <0 OR @spositiontaking_2  >0.9
				OR @spositiontaking_3  <0 OR @spositiontaking_3  >0.9
				OR @spositiontaking_4  <0 OR @spositiontaking_4  >0.9
				OR @spositiontaking_5  <0 OR @spositiontaking_5  >0.9
				OR @spositiontaking_6  <0 OR @spositiontaking_6  >0.9
				OR @spositiontaking_7  <0 OR @spositiontaking_7  >0.9
				OR @spositiontaking_8  <0 OR @spositiontaking_8  >0.9
				OR @spositiontaking_9  <0 OR @spositiontaking_9  >0.9
				OR @spositiontaking_10 <0 OR @spositiontaking_10 >0.9
				OR @spositiontaking_9999  <0 OR @spositiontaking_9999  >0.9
				OR @slivepositiontaking_1  <0 OR @slivepositiontaking_1  >0.9
				OR @slivepositiontaking_3  <0 OR @slivepositiontaking_3  >0.9
				OR @slivepositiontaking_7  <0 OR @slivepositiontaking_7  >0.9
				OR @slivepositiontaking_8  <0 OR @slivepositiontaking_8  >0.9
				
				
				BEGIN
					select @ErrCode = 5
					Select @ErrMsg = 	case @Language 
										when 'E' then 'Wrong position taking (for Soccer).'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
								end
					return
				END
			
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 1 AS sporttype, 1 AS bettype, @auto_spositiontaking_1 AS autopositiontaking, @isauto_spositiontaking_1 AS isautopositiontaking, @auto_slivepositiontaking_1 AS autolivepositiontaking, @isauto_slivepositiontaking_1 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 3 AS bettype, @auto_spositiontaking_3 AS autopositiontaking, @isauto_spositiontaking_3 AS isautopositiontaking, @auto_slivepositiontaking_3 AS autolivepositiontaking, @isauto_slivepositiontaking_3 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 7 AS bettype, @auto_spositiontaking_7 AS autopositiontaking, @isauto_spositiontaking_7 AS isautopositiontaking, @auto_slivepositiontaking_7 AS autolivepositiontaking, @isauto_slivepositiontaking_7 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 8 AS bettype, @auto_spositiontaking_8 AS autopositiontaking, @isauto_spositiontaking_8 AS isautopositiontaking, @auto_slivepositiontaking_8 AS autolivepositiontaking, @isauto_slivepositiontaking_8 AS isautolivepositiontaking

						UNION ALL	SELECT 1 AS sporttype, 2 AS bettype, @auto_spositiontaking_2 AS autopositiontaking, @isauto_spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 4 AS bettype, @auto_spositiontaking_4 AS autopositiontaking, @isauto_spositiontaking_4 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 5 AS bettype, @auto_spositiontaking_5 AS autopositiontaking, @isauto_spositiontaking_5 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 6 AS bettype, @auto_spositiontaking_6 AS autopositiontaking, @isauto_spositiontaking_6 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 9 AS bettype, @auto_spositiontaking_9 AS autopositiontaking, @isauto_spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 10 AS bettype, @auto_spositiontaking_10 AS autopositiontaking, @isauto_spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 1 AS sporttype, 9999 AS bettype, @auto_spositiontaking_9999 AS autopositiontaking, @isauto_spositiontaking_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					)
			 AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				INNER JOIN @tmp_Sports sports 
						on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype 
						on b.bettype = bettype.typeid
			where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))
			
		if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 1 AS sporttype, @auto_spositiontaking_1 AS autopositiontaking, @auto_slivepositiontaking_1 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @auto_spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @auto_spositiontaking_3 AS autopositiontaking, @auto_slivepositiontaking_3 AS autolivepositiontaking
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @auto_spositiontaking_4 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @auto_spositiontaking_5 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @auto_spositiontaking_6 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @auto_spositiontaking_7 AS autopositiontaking, @auto_slivepositiontaking_7 AS autolivepositiontaking
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @auto_spositiontaking_8 AS autopositiontaking, @auto_slivepositiontaking_8 AS autolivepositiontaking
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @auto_spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @auto_spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 9999 AS bettype, 1 AS sporttype, @auto_spositiontaking_9999 AS autopositiontaking, 0 AS autolivepositiontaking
					
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			inner join @tmp_Sports sports on b.sporttype = sports.sporttype
			inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MinLive: '+ cast((b.autolivepositiontaking_min) AS varchar(10)) ELSE '' END + '<br>'
			from 
				(
							SELECT 1 AS bettype, 1 AS sporttype, @auto_spositiontaking_1 AS autopositiontaking, @isauto_spositiontaking_1 AS isautopositiontaking, @mspositiontaking_1_min as autopositiontaking_min, @auto_slivepositiontaking_1 AS autolivepositiontaking, @isauto_slivepositiontaking_1 AS isautolivepositiontaking, @mslivepositiontaking_1_min as autolivepositiontaking_min
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @auto_spositiontaking_2 AS autopositiontaking, @isauto_spositiontaking_2 AS isautopositiontaking, @mspositiontaking_2_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @auto_spositiontaking_3 AS autopositiontaking, @isauto_spositiontaking_3 AS isautopositiontaking, @mspositiontaking_3_min as autopositiontaking_min, @auto_slivepositiontaking_3 AS autolivepositiontaking, @isauto_slivepositiontaking_3 AS isautolivepositiontaking, @mslivepositiontaking_3_min as autolivepositiontaking_min
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @auto_spositiontaking_4 AS autopositiontaking, @isauto_spositiontaking_4 AS isautopositiontaking, @mspositiontaking_4_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @auto_spositiontaking_5 AS autopositiontaking, @isauto_spositiontaking_5 AS isautopositiontaking, @mspositiontaking_5_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @auto_spositiontaking_6 AS autopositiontaking, @isauto_spositiontaking_6 AS isautopositiontaking, @mspositiontaking_6_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @auto_spositiontaking_7 AS autopositiontaking, @isauto_spositiontaking_7 AS isautopositiontaking, @mspositiontaking_7_min as autopositiontaking_min, @auto_slivepositiontaking_7 AS autolivepositiontaking, @isauto_slivepositiontaking_7 AS isautolivepositiontaking, @mslivepositiontaking_7_min as autolivepositiontaking_min
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @auto_spositiontaking_8 AS autopositiontaking, @isauto_spositiontaking_8 AS isautopositiontaking, @mspositiontaking_8_min as autopositiontaking_min, @auto_slivepositiontaking_8 AS autolivepositiontaking, @isauto_slivepositiontaking_8 AS isautolivepositiontaking, @mslivepositiontaking_8_min as autolivepositiontaking_min
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @auto_spositiontaking_9 AS autopositiontaking, @isauto_spositiontaking_9 AS isautopositiontaking, @mspositiontaking_9_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @auto_spositiontaking_10 AS autopositiontaking, @isauto_spositiontaking_10 AS isautopositiontaking, @mspositiontaking_10_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
					UNION ALL 	SELECT 9999 AS bettype, 1 AS sporttype, @auto_spositiontaking_9999 AS autopositiontaking, @isauto_spositiontaking_9999 AS isautopositiontaking, @mspositiontaking_9999_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 AS autolivepositiontaking_min
										
					) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where ((b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) or (b.bettype in (1,3,7,8) and b.sporttype=1 and b.isautolivepositiontaking = 1 and b.autolivepositiontaking < b.autolivepositiontaking_min ))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END						

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 1 AS sporttype, @spositiontaking_1 AS positiontaking, @slivepositiontaking_1 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @spositiontaking_3 AS positiontaking, @slivepositiontaking_3 AS livepositiontaking
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @spositiontaking_4 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @spositiontaking_5 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @spositiontaking_6 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @spositiontaking_7 AS positiontaking, @slivepositiontaking_7 AS livepositiontaking
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @spositiontaking_8 AS positiontaking, @slivepositiontaking_8 AS livepositiontaking
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 9999 AS bettype, 1 AS sporttype, @spositiontaking_9999 AS positiontaking, 0 AS livepositiontaking
				
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				inner join @tmp_Sports sports on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((b.livepositiontaking_max) AS varchar(10)) ELSE '' END + '<br>'
			from
				(
					SELECT 1 AS bettype, 1 AS sporttype, @spositiontaking_1 AS positiontaking, @isauto_spositiontaking_1 as isauto_spositiontaking, @isauto_smpositiontaking_1 as isauto_smpositiontaking, @mspositiontaking_1_max as positiontaking_max, @slivepositiontaking_1 AS livepositiontaking, @isauto_slivepositiontaking_1 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_1 as isauto_smlivepositiontaking, @mslivepositiontaking_1_max as livepositiontaking_max
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @spositiontaking_2 AS positiontaking, @isauto_spositiontaking_2 as isauto_spositiontaking, @isauto_smpositiontaking_2 as isauto_smpositiontaking, @mspositiontaking_2_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @spositiontaking_3 AS positiontaking, @isauto_spositiontaking_3 as isauto_spositiontaking, @isauto_smpositiontaking_3 as isauto_smpositiontaking, @mspositiontaking_3_max as positiontaking_max, @slivepositiontaking_3 AS livepositiontaking, @isauto_slivepositiontaking_3 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_3 as isauto_smlivepositiontaking, @mslivepositiontaking_3_max AS livepositiontaking_max
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @spositiontaking_4 AS positiontaking, @isauto_spositiontaking_4 as isauto_spositiontaking, @isauto_smpositiontaking_4 as isauto_smpositiontaking, @mspositiontaking_4_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @spositiontaking_5 AS positiontaking, @isauto_spositiontaking_5 as isauto_spositiontaking, @isauto_smpositiontaking_5 as isauto_smpositiontaking, @mspositiontaking_5_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @spositiontaking_6 AS positiontaking, @isauto_spositiontaking_6 as isauto_spositiontaking, @isauto_smpositiontaking_6 as isauto_smpositiontaking, @mspositiontaking_6_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @spositiontaking_7 AS positiontaking, @isauto_spositiontaking_7 as isauto_spositiontaking, @isauto_smpositiontaking_7 as isauto_smpositiontaking, @mspositiontaking_7_max as positiontaking_max, @slivepositiontaking_7 AS livepositiontaking, @isauto_slivepositiontaking_7 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_7 as isauto_smlivepositiontaking, @mslivepositiontaking_7_max AS livepositiontaking_max
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @spositiontaking_8 AS positiontaking, @isauto_spositiontaking_8 as isauto_spositiontaking, @isauto_smpositiontaking_8 as isauto_smpositiontaking, @mspositiontaking_8_max as positiontaking_max, @slivepositiontaking_8 AS livepositiontaking, @isauto_slivepositiontaking_8 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_8 as isauto_smlivepositiontaking, @mslivepositiontaking_8_max AS livepositiontaking_max
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @spositiontaking_9 AS positiontaking, @isauto_spositiontaking_9 as isauto_spositiontaking, @isauto_smpositiontaking_9 as isauto_smpositiontaking, @mspositiontaking_9_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @spositiontaking_10 AS positiontaking, @isauto_spositiontaking_10 as isauto_spositiontaking, @isauto_smpositiontaking_10 as isauto_smpositiontaking, @mspositiontaking_10_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max				
					UNION ALL 	SELECT 9999 AS bettype, 1 AS sporttype, @spositiontaking_9999 AS positiontaking, @isauto_spositiontaking_9999 as isauto_spositiontaking, @isauto_smpositiontaking_9999 as isauto_smpositiontaking, @mspositiontaking_9999_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
				) b
			inner join @tmp_Sports sports on b.sporttype = sports.sporttype
			inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0) or (b.bettype in (1,3,7,8) and b.livepositiontaking > b.livepositiontaking_max and b.isauto_slivepositiontaking= 0 and b.isauto_smlivepositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MinLive: '+ cast((b.livepositiontaking_min) AS varchar(10)) ELSE '' END + '<br>'
			from
				(
					SELECT 1 AS bettype, 1 AS sporttype, @spositiontaking_1 AS positiontaking, @isauto_spositiontaking_1 as isauto_spositiontaking, @isauto_smpositiontaking_1 as isauto_smpositiontaking, @mspositiontaking_1_min as positiontaking_min, @slivepositiontaking_1 AS livepositiontaking, @isauto_slivepositiontaking_1 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_1 as isauto_smlivepositiontaking, @mslivepositiontaking_1_min as livepositiontaking_min
					UNION ALL 	SELECT 2 AS bettype, 1 AS sporttype, @spositiontaking_2 AS positiontaking, @isauto_spositiontaking_2 as isauto_spositiontaking, @isauto_smpositiontaking_2 as isauto_smpositiontaking, @mspositiontaking_2_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 1 AS sporttype, @spositiontaking_3 AS positiontaking, @isauto_spositiontaking_3 as isauto_spositiontaking, @isauto_smpositiontaking_3 as isauto_smpositiontaking, @mspositiontaking_3_min as positiontaking_min, @slivepositiontaking_3 AS livepositiontaking, @isauto_slivepositiontaking_3 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_3 as isauto_smlivepositiontaking, @mslivepositiontaking_3_min AS livepositiontaking_min
					UNION ALL 	SELECT 4 AS bettype, 1 AS sporttype, @spositiontaking_4 AS positiontaking, @isauto_spositiontaking_4 as isauto_spositiontaking, @isauto_smpositiontaking_4 as isauto_smpositiontaking, @mspositiontaking_4_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min
					UNION ALL 	SELECT 5 AS bettype, 1 AS sporttype, @spositiontaking_5 AS positiontaking, @isauto_spositiontaking_5 as isauto_spositiontaking, @isauto_smpositiontaking_5 as isauto_smpositiontaking, @mspositiontaking_5_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min
					UNION ALL 	SELECT 6 AS bettype, 1 AS sporttype, @spositiontaking_6 AS positiontaking, @isauto_spositiontaking_6 as isauto_spositiontaking, @isauto_smpositiontaking_6 as isauto_smpositiontaking, @mspositiontaking_6_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min
					UNION ALL 	SELECT 7 AS bettype, 1 AS sporttype, @spositiontaking_7 AS positiontaking, @isauto_spositiontaking_7 as isauto_spositiontaking, @isauto_smpositiontaking_7 as isauto_smpositiontaking, @mspositiontaking_7_min as positiontaking_min, @slivepositiontaking_7 AS livepositiontaking, @isauto_slivepositiontaking_7 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_7 as isauto_smlivepositiontaking, @mslivepositiontaking_7_min AS livepositiontaking_min
					UNION ALL 	SELECT 8 AS bettype, 1 AS sporttype, @spositiontaking_8 AS positiontaking, @isauto_spositiontaking_8 as isauto_spositiontaking, @isauto_smpositiontaking_8 as isauto_smpositiontaking, @mspositiontaking_8_min as positiontaking_min, @slivepositiontaking_8 AS livepositiontaking, @isauto_slivepositiontaking_8 as isauto_slivepositiontaking, @isauto_smlivepositiontaking_8 as isauto_smlivepositiontaking, @mslivepositiontaking_8_min AS livepositiontaking_min
					UNION ALL 	SELECT 9 AS bettype, 1 AS sporttype, @spositiontaking_9 AS positiontaking, @isauto_spositiontaking_9 as isauto_spositiontaking, @isauto_smpositiontaking_9 as isauto_smpositiontaking, @mspositiontaking_9_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 1 AS sporttype, @spositiontaking_10 AS positiontaking, @isauto_spositiontaking_10 as isauto_spositiontaking, @isauto_smpositiontaking_10 as isauto_smpositiontaking, @mspositiontaking_10_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min		
					UNION ALL 	SELECT 9999 AS bettype, 1 AS sporttype, @spositiontaking_9999 AS positiontaking, @isauto_spositiontaking_9999 as isauto_spositiontaking, @isauto_smpositiontaking_9999 as isauto_smpositiontaking, @mspositiontaking_9999_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 AS livepositiontaking_min
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0) or (b.bettype in (1,3,7,8) and b.livepositiontaking < b.livepositiontaking_min and b.isauto_slivepositiontaking= 0 and b.isauto_smlivepositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END --@UpdatePositiontaking 
			
			--Basketball
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
			BEGIN --@UpdatePositiontakingv2
				if 
					@v2spositiontaking_1 <0 OR @v2spositiontaking_1 >0.9
					OR @v2spositiontaking_2 <0 OR @v2spositiontaking_2 >0.9
					OR @v2spositiontaking_3 <0 OR @v2spositiontaking_3 >0.9
					OR @v2spositiontaking_7 <0 OR @v2spositiontaking_7 >0.9
					OR @v2spositiontaking_8 <0 OR @v2spositiontaking_8 >0.9
				--	OR @v2spositiontaking_9 <0 OR @v2spositiontaking_9 >0.9
					OR @v2spositiontaking_20 <0 OR @v2spositiontaking_20 >0.9
					OR @v2spositiontaking_10 <0 OR @v2spositiontaking_10 >0.9
					
					BEGIN
						select @ErrCode = 8
						Select @ErrMsg = 	case @Language 
											when 'E' then 'Wrong position taking (for Basketball).'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
									end
						return
					END
				
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
					from custoverride AS co with (NOLOCK) 
					inner join
						(
						SELECT 2 AS sporttype, 1 AS bettype, @auto_v2spositiontaking_1 AS autopositiontaking, @isauto_v2spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 2 AS bettype, @auto_v2spositiontaking_2 AS autopositiontaking, @isauto_v2spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 3 AS bettype, @auto_v2spositiontaking_3 AS autopositiontaking, @isauto_v2spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 7 AS bettype, @auto_v2spositiontaking_7 AS autopositiontaking, @isauto_v2spositiontaking_7 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 8 AS bettype, @auto_v2spositiontaking_8 AS autopositiontaking, @isauto_v2spositiontaking_8 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						--	UNION ALL	SELECT 2 AS sporttype, 9 AS bettype, @auto_v2spositiontaking_9 AS autopositiontaking, @isauto_v2spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 10 AS bettype, @auto_v2spositiontaking_10 AS autopositiontaking, @isauto_v2spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
							UNION ALL	SELECT 2 AS sporttype, 20 AS bettype, @auto_v2spositiontaking_20 AS autopositiontaking, @isauto_v2spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking

						) AS b 
							on co.sporttype=b.sporttype and co.bettype=b.bettype
					inner join @tmp_Sports sports 
							on b.sporttype = sports.sporttype
					inner join @tmp_Bettype bettype 
							on b.bettype = bettype.typeid

					where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

					if @ErrType <>''
					BEGIN
						SELECT @isvalid = 0, @ErrCode_cur = 2
						SELECT @ErrMsg_cur = 	case @Language 
														WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
														ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
												END
						select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
								@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
						return
					END
				
					--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
					+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
					from custsetting AS cs with (NOLOCK) inner join
						(
						SELECT 1 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
		--			UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_7 AS autopositiontaking, 0 AS autolivepositiontaking
		--			UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_8 AS autopositiontaking, 0 AS autolivepositiontaking
		--			UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				
				inner join @tmp_Sports sports on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check u1>=us1_min (= min_s1)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
				from 
					(
								SELECT 1 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_1 AS autopositiontaking, @isauto_v2spositiontaking_1 AS isautopositiontaking, @v2mspositiontaking_1_min as autopositiontaking_min
						UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_2 AS autopositiontaking, @isauto_v2spositiontaking_2 AS isautopositiontaking, @v2mspositiontaking_2_min as autopositiontaking_min
						UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_3 AS autopositiontaking, @isauto_v2spositiontaking_3 AS isautopositiontaking, @v2mspositiontaking_3_min as autopositiontaking_min
						UNION ALL 	SELECT 10 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_10 AS autopositiontaking, @isauto_v2spositiontaking_10 AS isautopositiontaking, @v2mspositiontaking_10_min as autopositiontaking_min
						UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @auto_v2spositiontaking_20 AS autopositiontaking, @isauto_v2spositiontaking_20 AS isautopositiontaking, @v2mspositiontaking_20_min as autopositiontaking_min
											
						) AS b 
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 11							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END			
					
				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
								SELECT 1 AS bettype, 2 AS sporttype, @v2spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @v2spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @v2spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @v2spositiontaking_7 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @v2spositiontaking_8 AS positiontaking, 0 AS livepositiontaking
			--			UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @v2spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 10 AS bettype, 2 AS sporttype, @v2spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @v2spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
						
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					inner join @tmp_Sports sports on b.sporttype = sports.sporttype
					inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
					where cs.custid = @srecommend
						and 
						((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
						
				if @ErrType <>''
				BEGIN

					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1<=s1_max
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
				from
					(
						SELECT 1 AS bettype, 2 AS sporttype, @v2spositiontaking_1 AS positiontaking, @isauto_v2spositiontaking_1 as isauto_spositiontaking, @isauto_v2smpositiontaking_1 as isauto_smpositiontaking, @v2mspositiontaking_1_max as positiontaking_max
						UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @v2spositiontaking_2 AS positiontaking, @isauto_v2spositiontaking_2 as isauto_spositiontaking, @isauto_v2smpositiontaking_2 as isauto_smpositiontaking, @v2mspositiontaking_2_max as positiontaking_max
						UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @v2spositiontaking_3 AS positiontaking, @isauto_v2spositiontaking_3 as isauto_spositiontaking, @isauto_v2smpositiontaking_3 as isauto_smpositiontaking, @v2mspositiontaking_3_max as positiontaking_max
						UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @v2spositiontaking_7 AS positiontaking, @isauto_v2spositiontaking_7 as isauto_spositiontaking, @isauto_v2smpositiontaking_7 as isauto_smpositiontaking, @v2mspositiontaking_7_max as positiontaking_max
						UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @v2spositiontaking_8 AS positiontaking, @isauto_v2spositiontaking_8 as isauto_spositiontaking, @isauto_v2smpositiontaking_8 as isauto_smpositiontaking, @v2mspositiontaking_8_max as positiontaking_max
						--UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @v2spositiontaking_9 AS positiontaking, @isauto_v2spositiontaking_9 as isauto_spositiontaking, @isauto_v2smpositiontaking_9 as isauto_smpositiontaking, @v2mspositiontaking_9_max as positiontaking_max
						UNION ALL 	SELECT 10 AS bettype, 2 AS sporttype, @v2spositiontaking_10 AS positiontaking, @isauto_v2spositiontaking_10 as isauto_spositiontaking, @isauto_v2smpositiontaking_10 as isauto_smpositiontaking, @v2mspositiontaking_10_max as positiontaking_max
						UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @v2spositiontaking_20 AS positiontaking, @isauto_v2spositiontaking_20 as isauto_spositiontaking, @isauto_v2smpositiontaking_20 as isauto_smpositiontaking, @v2mspositiontaking_20_max as positiontaking_max
					) b
				inner join @tmp_Sports sports on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1>=s1_min
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
				from
					(
						SELECT 1 AS bettype, 2 AS sporttype, @v2spositiontaking_1 AS positiontaking, @isauto_v2spositiontaking_1 as isauto_spositiontaking, @isauto_v2smpositiontaking_1 as isauto_smpositiontaking, @v2mspositiontaking_1_min as positiontaking_min
						UNION ALL 	SELECT 2 AS bettype, 2 AS sporttype, @v2spositiontaking_2 AS positiontaking, @isauto_v2spositiontaking_2 as isauto_spositiontaking, @isauto_v2smpositiontaking_2 as isauto_smpositiontaking, @v2mspositiontaking_2_min as positiontaking_min
						UNION ALL 	SELECT 3 AS bettype, 2 AS sporttype, @v2spositiontaking_3 AS positiontaking, @isauto_v2spositiontaking_3 as isauto_spositiontaking, @isauto_v2smpositiontaking_3 as isauto_smpositiontaking, @v2mspositiontaking_3_min as positiontaking_min
						UNION ALL 	SELECT 7 AS bettype, 2 AS sporttype, @v2spositiontaking_7 AS positiontaking, @isauto_v2spositiontaking_7 as isauto_spositiontaking, @isauto_v2smpositiontaking_7 as isauto_smpositiontaking, @v2mspositiontaking_7_min as positiontaking_min
						UNION ALL 	SELECT 8 AS bettype, 2 AS sporttype, @v2spositiontaking_8 AS positiontaking, @isauto_v2spositiontaking_8 as isauto_spositiontaking, @isauto_v2smpositiontaking_8 as isauto_smpositiontaking, @v2mspositiontaking_8_min as positiontaking_min
						--UNION ALL 	SELECT 9 AS bettype, 2 AS sporttype, @v2spositiontaking_9 AS positiontaking, @isauto_v2spositiontaking_9 as isauto_spositiontaking, @isauto_v2smpositiontaking_9 as isauto_smpositiontaking, @v2mspositiontaking_9_min as positiontaking_min
						UNION ALL 	SELECT 10 AS bettype, 2 AS sporttype, @v2spositiontaking_10 AS positiontaking, @isauto_v2spositiontaking_10 as isauto_spositiontaking, @isauto_v2smpositiontaking_10 as isauto_smpositiontaking, @v2mspositiontaking_10_min as positiontaking_min
						UNION ALL 	SELECT 20 AS bettype, 2 AS sporttype, @v2spositiontaking_20 AS positiontaking, @isauto_v2spositiontaking_20 as isauto_spositiontaking, @isauto_v2smpositiontaking_20 as isauto_smpositiontaking, @v2mspositiontaking_20_min as positiontaking_min
					) b
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 12							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			END --@UpdatePositiontakingv2
			
			
			--Football
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
			BEGIN --@UpdatePositiontakingv3 
				if 
					@v3spositiontaking_1 <0 OR @v3spositiontaking_1 >0.9
					OR @v3spositiontaking_2 <0 OR @v3spositiontaking_2 >0.9
					OR @v3spositiontaking_3 <0 OR @v3spositiontaking_3 >0.9
					OR @v3spositiontaking_20 <0 OR @v3spositiontaking_20 >0.9
					OR @v3spositiontaking_10 <0 OR @v3spositiontaking_10 >0.9
					
				BEGIN
					select @ErrCode = 8
					Select @ErrMsg = 	case @Language 
										when 'E' then 'Wrong position taking (for Football).'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
								end
					return
				END
			
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 3 AS sporttype, 1 AS bettype, @auto_v3spositiontaking_1 AS autopositiontaking, @isauto_v3spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 2 AS bettype, @auto_v3spositiontaking_2 AS autopositiontaking, @isauto_v3spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 3 AS bettype, @auto_v3spositiontaking_3 AS autopositiontaking, @isauto_v3spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 10 AS bettype, @auto_v3spositiontaking_10 AS autopositiontaking, @isauto_v3spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 3 AS sporttype, 20 AS bettype, @auto_v3spositiontaking_20 AS autopositiontaking, @isauto_v3spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking

					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				inner join @tmp_Sports sports 
						on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype 
						on b.bettype = bettype.typeid
				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

				if @ErrType <>''
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 2
					SELECT @ErrMsg_cur = 	case @Language 
													WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
											END
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

				--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
						SELECT 1 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 10 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking

					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				inner join @tmp_Sports sports on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check u1>=us1_min (= min_s1)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
				from 
					(
								SELECT 1 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_1 AS autopositiontaking, @isauto_v3spositiontaking_1 AS isautopositiontaking, @v3mspositiontaking_1_min as autopositiontaking_min
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_2 AS autopositiontaking, @isauto_v3spositiontaking_2 AS isautopositiontaking, @v3mspositiontaking_2_min as autopositiontaking_min
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_3 AS autopositiontaking, @isauto_v3spositiontaking_3 AS isautopositiontaking, @v3mspositiontaking_3_min as autopositiontaking_min
						UNION ALL 	SELECT 10 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_10 AS autopositiontaking, @isauto_v3spositiontaking_10 AS isautopositiontaking, @v3mspositiontaking_10_min as autopositiontaking_min
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @auto_v3spositiontaking_20 AS autopositiontaking, @isauto_v3spositiontaking_20 AS isautopositiontaking, @v3mspositiontaking_20_min as autopositiontaking_min
											
						) AS b 
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 11							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END		
				
				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
						SELECT 1 AS bettype, 3 AS sporttype, @v3spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @v3spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @v3spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 10 AS bettype, 3 AS sporttype, @v3spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @v3spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					inner join @tmp_Sports sports on b.sporttype = sports.sporttype
					inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1<=s1_max
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
				from
					(
						SELECT 1 AS bettype, 3 AS sporttype, @v3spositiontaking_1 AS positiontaking, @isauto_v3spositiontaking_1 as isauto_spositiontaking, @isauto_v3smpositiontaking_1 as isauto_smpositiontaking, @v3mspositiontaking_1_max as positiontaking_max
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @v3spositiontaking_2 AS positiontaking, @isauto_v3spositiontaking_2 as isauto_spositiontaking, @isauto_v3smpositiontaking_2 as isauto_smpositiontaking, @v3mspositiontaking_2_max as positiontaking_max
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @v3spositiontaking_3 AS positiontaking, @isauto_v3spositiontaking_3 as isauto_spositiontaking, @isauto_v3smpositiontaking_3 as isauto_smpositiontaking, @v3mspositiontaking_3_max as positiontaking_max
						UNION ALL 	SELECT 10 AS bettype, 3 AS sporttype, @v3spositiontaking_10 AS positiontaking, @isauto_v3spositiontaking_10 as isauto_spositiontaking, @isauto_v3smpositiontaking_10 as isauto_smpositiontaking, @v3mspositiontaking_10_max as positiontaking_max
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @v3spositiontaking_20 AS positiontaking, @isauto_v3spositiontaking_20 as isauto_spositiontaking, @isauto_v3smpositiontaking_20 as isauto_smpositiontaking, @v3mspositiontaking_20_max as positiontaking_max
					) b
				inner join @tmp_Sports sports on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1>=s1_min
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
				from
					(
						SELECT 1 AS bettype, 3 AS sporttype, @v3spositiontaking_1 AS positiontaking, @isauto_v3spositiontaking_1 as isauto_spositiontaking, @isauto_v3smpositiontaking_1 as isauto_smpositiontaking, @v3mspositiontaking_1_min as positiontaking_min
						UNION ALL 	SELECT 2 AS bettype, 3 AS sporttype, @v3spositiontaking_2 AS positiontaking, @isauto_v3spositiontaking_2 as isauto_spositiontaking, @isauto_v3smpositiontaking_2 as isauto_smpositiontaking, @v3mspositiontaking_2_min as positiontaking_min
						UNION ALL 	SELECT 3 AS bettype, 3 AS sporttype, @v3spositiontaking_3 AS positiontaking, @isauto_v3spositiontaking_3 as isauto_spositiontaking, @isauto_v3smpositiontaking_3 as isauto_smpositiontaking, @v3mspositiontaking_3_min as positiontaking_min
						UNION ALL 	SELECT 10 AS bettype, 3 AS sporttype, @v3spositiontaking_10 AS positiontaking, @isauto_v3spositiontaking_10 as isauto_spositiontaking, @isauto_v3smpositiontaking_10 as isauto_smpositiontaking, @v3mspositiontaking_10_min as positiontaking_min
						UNION ALL 	SELECT 20 AS bettype, 3 AS sporttype, @v3spositiontaking_20 AS positiontaking, @isauto_v3spositiontaking_20 as isauto_spositiontaking, @isauto_v3smpositiontaking_20 as isauto_smpositiontaking, @v3mspositiontaking_20_min as positiontaking_min
					) b
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 12							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

			END --@UpdatePositiontakingv3 
			
		--Tennis
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv5 = 1 )
		BEGIN --@UpdatePositiontakingv5
			if 
				@v5spositiontaking_1 <0 OR @v5spositiontaking_1 >0.9
				OR @v5spositiontaking_2 <0 OR @v5spositiontaking_2 >0.9
				OR @v5spositiontaking_3 <0 OR @v5spositiontaking_3 >0.9
				OR @v5spositiontaking_20 <0 OR @v5spositiontaking_20 >0.9
				OR @v5spositiontaking_9999 <0 OR @v5spositiontaking_9999 >0.9
				OR @v5spositiontaking_10 <0 OR @v5spositiontaking_10 >0.9
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Tennis).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end
				return
			END	
		
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 5 AS sporttype, 1 AS bettype, @auto_v5spositiontaking_1 AS autopositiontaking, @isauto_v5spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 2 AS bettype, @auto_v5spositiontaking_2 AS autopositiontaking, @isauto_v5spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 3 AS bettype, @auto_v5spositiontaking_3 AS autopositiontaking, @isauto_v5spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 20 AS bettype, @auto_v5spositiontaking_20 AS autopositiontaking, @isauto_v5spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 10 AS bettype, @auto_v5spositiontaking_10 AS autopositiontaking, @isauto_v5spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 5 AS sporttype, 9999 AS bettype, @auto_v5spositiontaking_9999 AS autopositiontaking, @isauto_v5spositiontaking_9999 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				inner join @tmp_Sports sports 
						on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype 
						on b.bettype = bettype.typeid

				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

	
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 9999 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_9999 AS autopositiontaking, 0 AS autolivepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			inner join @tmp_Sports sports on b.sporttype = sports.sporttype
			inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
			from 
				(
							SELECT 1 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_1 AS autopositiontaking, @isauto_v5spositiontaking_1 AS isautopositiontaking, @v5mspositiontaking_1_min as autopositiontaking_min
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_2 AS autopositiontaking, @isauto_v5spositiontaking_2 AS isautopositiontaking, @v5mspositiontaking_2_min as autopositiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_3 AS autopositiontaking, @isauto_v5spositiontaking_3 AS isautopositiontaking, @v5mspositiontaking_3_min as autopositiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_20 AS autopositiontaking, @isauto_v5spositiontaking_20 AS isautopositiontaking, @v5mspositiontaking_20_min as autopositiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_10 AS autopositiontaking, @isauto_v5spositiontaking_10 AS isautopositiontaking, @v5mspositiontaking_10_min as autopositiontaking_min
					UNION ALL 	SELECT 9999 AS bettype, 5 AS sporttype, @auto_v5spositiontaking_9999 AS autopositiontaking, @isauto_v5spositiontaking_9999 AS isautopositiontaking, @v5mspositiontaking_9999_min as autopositiontaking_min
										
					) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END		

			--Check s1<=s4
			SELECT @ErrType = ''

			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 5 AS sporttype, @v5spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @v5spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @v5spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 5 AS sporttype, @v5spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @v5spositiontaking_20 AS positiontaking, 0 AS livepositiontaking				
					UNION ALL 	SELECT 9999 AS bettype, 5 AS sporttype, @v5spositiontaking_9999 AS positiontaking, 0 AS livepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 5 AS sporttype, @v5spositiontaking_1 AS positiontaking, @isauto_v5spositiontaking_1 as isauto_spositiontaking, @isauto_v5smpositiontaking_1 as isauto_smpositiontaking, @v5mspositiontaking_1_max as positiontaking_max
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @v5spositiontaking_2 AS positiontaking, @isauto_v5spositiontaking_2 as isauto_spositiontaking, @isauto_v5smpositiontaking_2 as isauto_smpositiontaking, @v5mspositiontaking_2_max as positiontaking_max
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @v5spositiontaking_3 AS positiontaking, @isauto_v5spositiontaking_3 as isauto_spositiontaking, @isauto_v5smpositiontaking_3 as isauto_smpositiontaking, @v5mspositiontaking_3_max as positiontaking_max
					UNION ALL 	SELECT 10 AS bettype, 5 AS sporttype, @v5spositiontaking_10 AS positiontaking, @isauto_v5spositiontaking_10 as isauto_spositiontaking, @isauto_v5smpositiontaking_10 as isauto_smpositiontaking, @v5mspositiontaking_10_max as positiontaking_max
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @v5spositiontaking_20 AS positiontaking, @isauto_v5spositiontaking_20 as isauto_spositiontaking, @isauto_v5smpositiontaking_20 as isauto_smpositiontaking, @v5mspositiontaking_20_max as positiontaking_max
					UNION ALL 	SELECT 9999 AS bettype, 5 AS sporttype, @v5spositiontaking_9999 AS positiontaking, @isauto_v5spositiontaking_9999 as isauto_spositiontaking, @isauto_v5smpositiontaking_9999 as isauto_smpositiontaking, @v5mspositiontaking_9999_max as positiontaking_max
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 5 AS sporttype, @v5spositiontaking_1 AS positiontaking, @isauto_v5spositiontaking_1 as isauto_spositiontaking, @isauto_v5smpositiontaking_1 as isauto_smpositiontaking, @v5mspositiontaking_1_min as positiontaking_min
					UNION ALL 	SELECT 2 AS bettype, 5 AS sporttype, @v5spositiontaking_2 AS positiontaking, @isauto_v5spositiontaking_2 as isauto_spositiontaking, @isauto_v5smpositiontaking_2 as isauto_smpositiontaking, @v5mspositiontaking_2_min as positiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 5 AS sporttype, @v5spositiontaking_3 AS positiontaking, @isauto_v5spositiontaking_3 as isauto_spositiontaking, @isauto_v5smpositiontaking_3 as isauto_smpositiontaking, @v5mspositiontaking_3_min as positiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 5 AS sporttype, @v5spositiontaking_10 AS positiontaking, @isauto_v5spositiontaking_10 as isauto_spositiontaking, @isauto_v5smpositiontaking_10 as isauto_smpositiontaking, @v5mspositiontaking_10_min as positiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 5 AS sporttype, @v5spositiontaking_20 AS positiontaking, @isauto_v5spositiontaking_20 as isauto_spositiontaking, @isauto_v5smpositiontaking_20 as isauto_smpositiontaking, @v5mspositiontaking_20_min as positiontaking_min
					UNION ALL 	SELECT 9999 AS bettype, 5 AS sporttype, @v5spositiontaking_9999 AS positiontaking, @isauto_v5spositiontaking_9999 as isauto_spositiontaking, @isauto_v5smpositiontaking_9999 as isauto_smpositiontaking, @v5mspositiontaking_9999_min as positiontaking_min
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid

			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END --@UpdatePositiontakingv5
		
		
		--Baseball
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1 )
			BEGIN --@UpdatePositiontakingv8 
				if 
					 @v8spositiontaking_1 <0 OR @v8spositiontaking_1 >0.9
					OR @v8spositiontaking_3 <0 OR @v8spositiontaking_3 >0.9
					OR @v8spositiontaking_20 <0	OR @v8spositiontaking_20 >0.9
					OR @v8spositiontaking_10 <0 OR @v8spositiontaking_10 >0.9
											
					BEGIN
						select @ErrCode = 8
						Select @ErrMsg = 	case @Language 
											when 'E' then 'Wrong position taking (for Baseball).'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
									end
						return
					END				
			
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 8 AS sporttype, 1 AS bettype, @auto_v8spositiontaking_1 AS autopositiontaking, @isauto_v8spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 8 AS sporttype, 3 AS bettype, @auto_v8spositiontaking_3 AS autopositiontaking, @isauto_v8spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 8 AS sporttype, 10 AS bettype, @auto_v8spositiontaking_10 AS autopositiontaking, @isauto_v8spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
						UNION ALL	SELECT 8 AS sporttype, 20 AS bettype, @auto_v8spositiontaking_20 AS autopositiontaking, @isauto_v8spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				inner join @tmp_Sports sports 
						on b.sporttype = sports.sporttype
				inner join @tmp_Bettype bettype 
						on b.bettype = bettype.typeid

				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

				if @ErrType <>''
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 2
					SELECT @ErrMsg_cur = 	case @Language 
													WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
											END
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END

				--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
								SELECT 1 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 10 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check u1>=us1_min (= min_s1)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
				from 
					(
								SELECT 1 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_1 AS autopositiontaking, @isauto_v8spositiontaking_1 AS isautopositiontaking, @v8mspositiontaking_1_min as autopositiontaking_min						
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_3 AS autopositiontaking, @isauto_v8spositiontaking_3 AS isautopositiontaking, @v8mspositiontaking_3_min as autopositiontaking_min
						UNION ALL 	SELECT 10 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_10 AS autopositiontaking, @isauto_v8spositiontaking_10 AS isautopositiontaking, @v8mspositiontaking_10_min as autopositiontaking_min
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @auto_v8spositiontaking_20 AS autopositiontaking, @isauto_v8spositiontaking_20 AS isautopositiontaking, @v8mspositiontaking_20_min as autopositiontaking_min
											
						) AS b 
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 11							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END	
				
				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
				+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
								SELECT 1 AS bettype, 8 AS sporttype, @v8spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @v8spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 10 AS bettype, 8 AS sporttype, @v8spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @v8spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
						
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
					INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and 
					((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1<=s1_max
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
				from
					(
						SELECT 1 AS bettype, 8 AS sporttype, @v8spositiontaking_1 AS positiontaking, @isauto_v8spositiontaking_1 as isauto_spositiontaking, @isauto_v8smpositiontaking_1 as isauto_smpositiontaking, @v8mspositiontaking_1_max as positiontaking_max					
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @v8spositiontaking_3 AS positiontaking, @isauto_v8spositiontaking_3 as isauto_spositiontaking, @isauto_v8smpositiontaking_3 as isauto_smpositiontaking, @v8mspositiontaking_3_max as positiontaking_max
						UNION ALL 	SELECT 10 AS bettype, 8 AS sporttype, @v8spositiontaking_10 AS positiontaking, @isauto_v8spositiontaking_10 as isauto_spositiontaking, @isauto_v8smpositiontaking_10 as isauto_smpositiontaking, @v8mspositiontaking_10_max as positiontaking_max
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @v8spositiontaking_20 AS positiontaking, @isauto_v8spositiontaking_20 as isauto_spositiontaking, @isauto_v8smpositiontaking_20 as isauto_smpositiontaking, @v8mspositiontaking_20_max as positiontaking_max
					) b
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1>=s1_min
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
				from
					(
						SELECT 1 AS bettype, 8 AS sporttype, @v8spositiontaking_1 AS positiontaking, @isauto_v8spositiontaking_1 as isauto_spositiontaking, @isauto_v8smpositiontaking_1 as isauto_smpositiontaking, @v8mspositiontaking_1_min as positiontaking_min						
						UNION ALL 	SELECT 3 AS bettype, 8 AS sporttype, @v8spositiontaking_3 AS positiontaking, @isauto_v8spositiontaking_3 as isauto_spositiontaking, @isauto_v8smpositiontaking_3 as isauto_smpositiontaking, @v8mspositiontaking_3_min as positiontaking_min
						UNION ALL 	SELECT 10 AS bettype, 8 AS sporttype, @v8spositiontaking_10 AS positiontaking, @isauto_v8spositiontaking_10 as isauto_spositiontaking, @isauto_v8smpositiontaking_10 as isauto_smpositiontaking, @v8mspositiontaking_10_min as positiontaking_min
						UNION ALL 	SELECT 20 AS bettype, 8 AS sporttype, @v8spositiontaking_20 AS positiontaking, @isauto_v8spositiontaking_20 as isauto_spositiontaking, @isauto_v8smpositiontaking_20 as isauto_smpositiontaking, @v8mspositiontaking_20_min as positiontaking_min
					) b
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 12							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			END --@UpdatePositiontakingv8

		--Golf
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv10 = 1 )
		BEGIN -- @UpdatePositiontakingv10
			if 
			 @v10spositiontaking_1 <0 OR @v10spositiontaking_1 >0.9
				OR @v10spositiontaking_2 <0 OR @v10spositiontaking_2 >0.9
				OR @v10spositiontaking_3 <0 OR @v10spositiontaking_3 >0.9
				OR @v10spositiontaking_20 <0 OR @v10spositiontaking_20 >0.9
				OR @v10spositiontaking_10 <0 OR @v10spositiontaking_10 >0.9
				
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Golf).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end
				return
			END

			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(
				SELECT 10 AS sporttype, 1 AS bettype, @auto_v10spositiontaking_1 AS autopositiontaking, @isauto_v10spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 2 AS bettype, @auto_v10spositiontaking_2 AS autopositiontaking, @isauto_v10spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 3 AS bettype, @auto_v10spositiontaking_3 AS autopositiontaking, @isauto_v10spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 10 AS bettype, @auto_v10spositiontaking_10 AS autopositiontaking, @isauto_v10spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 10 AS sporttype, 20 AS bettype, @auto_v10spositiontaking_20 AS autopositiontaking, @isauto_v10spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN @tmp_Sports sports 
					on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype 
					on b.bettype = bettype.typeid
				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
				--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
			from 
				(
							SELECT 1 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_1 AS autopositiontaking, @isauto_v10spositiontaking_1 AS isautopositiontaking, @v10mspositiontaking_1_min as autopositiontaking_min						
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_2 AS autopositiontaking, @isauto_v10spositiontaking_2 AS isautopositiontaking, @v10mspositiontaking_2_min as autopositiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_3 AS autopositiontaking, @isauto_v10spositiontaking_3 AS isautopositiontaking, @v10mspositiontaking_3_min as autopositiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_10 AS autopositiontaking, @isauto_v10spositiontaking_10 AS isautopositiontaking, @v10mspositiontaking_10_min as autopositiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @auto_v10spositiontaking_20 AS autopositiontaking, @isauto_v10spositiontaking_20 AS isautopositiontaking, @v10mspositiontaking_20_min as autopositiontaking_min
										
					) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END	

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 10 AS sporttype, @v10spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @v10spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @v10spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 10 AS sporttype, @v10spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @v10spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
			
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 10 AS sporttype, @v10spositiontaking_1 AS positiontaking, @isauto_v10spositiontaking_1 as isauto_spositiontaking, @isauto_v10smpositiontaking_1 as isauto_smpositiontaking, @v10mspositiontaking_1_max as positiontaking_max
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @v10spositiontaking_2 AS positiontaking, @isauto_v10spositiontaking_2 as isauto_spositiontaking, @isauto_v10smpositiontaking_2 as isauto_smpositiontaking, @v10mspositiontaking_2_max as positiontaking_max
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @v10spositiontaking_3 AS positiontaking, @isauto_v10spositiontaking_3 as isauto_spositiontaking, @isauto_v10smpositiontaking_3 as isauto_smpositiontaking, @v10mspositiontaking_3_max as positiontaking_max
					UNION ALL 	SELECT 10 AS bettype, 10 AS sporttype, @v10spositiontaking_10 AS positiontaking, @isauto_v10spositiontaking_10 as isauto_spositiontaking, @isauto_v10smpositiontaking_10 as isauto_smpositiontaking, @v10mspositiontaking_10_max as positiontaking_max
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @v10spositiontaking_20 AS positiontaking, @isauto_v10spositiontaking_20 as isauto_spositiontaking, @isauto_v10smpositiontaking_20 as isauto_smpositiontaking, @v10mspositiontaking_20_max as positiontaking_max
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 10 AS sporttype, @v10spositiontaking_1 AS positiontaking, @isauto_v10spositiontaking_1 as isauto_spositiontaking, @isauto_v10smpositiontaking_1 as isauto_smpositiontaking, @v10mspositiontaking_1_min as positiontaking_min						
					UNION ALL 	SELECT 2 AS bettype, 10 AS sporttype, @v10spositiontaking_2 AS positiontaking, @isauto_v10spositiontaking_2 as isauto_spositiontaking, @isauto_v10smpositiontaking_2 as isauto_smpositiontaking, @v10mspositiontaking_2_min as positiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 10 AS sporttype, @v10spositiontaking_3 AS positiontaking, @isauto_v10spositiontaking_3 as isauto_spositiontaking, @isauto_v10smpositiontaking_3 as isauto_smpositiontaking, @v10mspositiontaking_3_min as positiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 10 AS sporttype, @v10spositiontaking_10 AS positiontaking, @isauto_v10spositiontaking_10 as isauto_spositiontaking, @isauto_v10smpositiontaking_10 as isauto_smpositiontaking, @v10mspositiontaking_10_min as positiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 10 AS sporttype, @v10spositiontaking_20 AS positiontaking, @isauto_v10spositiontaking_20 as isauto_spositiontaking, @isauto_v10smpositiontaking_20 as isauto_smpositiontaking, @v10mspositiontaking_20_min as positiontaking_min
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END -- @UpdatePositiontakingv10


		--Motorsports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
		BEGIN--@UpdatePositiontakingv11
			if 
			 @v11spositiontaking_1 <0 OR @v11spositiontaking_1 >0.9
			OR @v11spositiontaking_20 <0 OR @v11spositiontaking_20 >0.9
			OR @v11spositiontaking_10 <0 OR @v11spositiontaking_10 >0.9

			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Motorsports).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end
				return
			END

			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(SELECT 11 AS sporttype, 1 AS bettype, @auto_v11spositiontaking_1 AS autopositiontaking, @isauto_v11spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 11 AS sporttype, 10 AS bettype, @auto_v11spositiontaking_10 AS autopositiontaking, @isauto_v11spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 11 AS sporttype, 20 AS bettype, @auto_v11spositiontaking_20 AS autopositiontaking, @isauto_v11spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN @tmp_Sports sports 
					on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype 
					on b.bettype = bettype.typeid

				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
	
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
						SELECT 1 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
				UNION ALL 	SELECT 10 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking		
				UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
			from 
				(
							SELECT 1 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_1 AS autopositiontaking, @isauto_v11spositiontaking_1 AS isautopositiontaking, @v11mspositiontaking_1_min as autopositiontaking_min						
					UNION ALL 	SELECT 10 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_10 AS autopositiontaking, @isauto_v11spositiontaking_10 AS isautopositiontaking, @v11mspositiontaking_10_min as autopositiontaking_min		
					UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @auto_v11spositiontaking_20 AS autopositiontaking, @isauto_v11spositiontaking_20 AS isautopositiontaking, @v11mspositiontaking_20_min as autopositiontaking_min
										
					) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END	
			
			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 11 AS sporttype, @v11spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 11 AS sporttype, @v11spositiontaking_10 AS positiontaking, 0 AS livepositiontaking		
					UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @v11spositiontaking_20 AS positiontaking, 0 AS livepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 11 AS sporttype, @v11spositiontaking_1 AS positiontaking, @isauto_v11spositiontaking_1 as isauto_spositiontaking, @isauto_v11smpositiontaking_1 as isauto_smpositiontaking, @v11mspositiontaking_1_max as positiontaking_max
					UNION ALL 	SELECT 10 AS bettype, 11 AS sporttype, @v11spositiontaking_10 AS positiontaking, @isauto_v11spositiontaking_10 as isauto_spositiontaking, @isauto_v11smpositiontaking_10 as isauto_smpositiontaking, @v11mspositiontaking_10_max as positiontaking_max
					UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @v11spositiontaking_20 AS positiontaking, @isauto_v11spositiontaking_20 as isauto_spositiontaking, @isauto_v11smpositiontaking_20 as isauto_smpositiontaking, @v11mspositiontaking_20_max as positiontaking_max
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 11 AS sporttype, @v11spositiontaking_1 AS positiontaking, @isauto_v11spositiontaking_1 as isauto_spositiontaking, @isauto_v11smpositiontaking_1 as isauto_smpositiontaking, @v11mspositiontaking_1_min as positiontaking_min						
					UNION ALL 	SELECT 10 AS bettype, 11 AS sporttype, @v11spositiontaking_10 AS positiontaking, @isauto_v11spositiontaking_10 as isauto_spositiontaking, @isauto_v11smpositiontaking_10 as isauto_smpositiontaking, @v11mspositiontaking_10_min as positiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 11 AS sporttype, @v11spositiontaking_20 AS positiontaking, @isauto_v11spositiontaking_20 as isauto_spositiontaking, @isauto_v11smpositiontaking_20 as isauto_smpositiontaking, @v11mspositiontaking_20_min as positiontaking_min
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END	--@UpdatePositiontakingv11
	
		--Other sports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1 )
		BEGIN--@UpdatePositiontakingv99
			if 
			 @v99spositiontaking_1 <0 OR @v99spositiontaking_1 >0.9 
			OR @v99spositiontaking_2 <0 OR @v99spositiontaking_2 >0.9
			OR @v99spositiontaking_3 <0 OR @v99spositiontaking_3 >0.9
			OR @v99spositiontaking_20 <0 OR @v99spositiontaking_20 >0.9
			OR @v99spositiontaking_10 <0 OR @v99spositiontaking_10 >0.9
				
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Other sports).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end
				return
			END
	
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(
				SELECT 99 AS sporttype, 1 AS bettype, @auto_v99spositiontaking_1 AS autopositiontaking, @isauto_v99spositiontaking_1 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 2 AS bettype, @auto_v99spositiontaking_2 AS autopositiontaking, @isauto_v99spositiontaking_2 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 3 AS bettype, @auto_v99spositiontaking_3 AS autopositiontaking, @isauto_v99spositiontaking_3 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 10 AS bettype, @auto_v99spositiontaking_10 AS autopositiontaking, @isauto_v99spositiontaking_10 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					UNION ALL	SELECT 99 AS sporttype, 20 AS bettype, @auto_v99spositiontaking_20 AS autopositiontaking, @isauto_v99spositiontaking_20 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN @tmp_Sports sports 
					on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype 
					on b.bettype = bettype.typeid

			where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_1 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_2 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_3 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_10 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking
					
					-- mixed sports
					UNION ALL 	SELECT 9 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking

				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
			from 
				(
							SELECT 1 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_1 AS autopositiontaking, @isauto_v99spositiontaking_1 AS isautopositiontaking, @v99mspositiontaking_1_min as autopositiontaking_min						
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_2 AS autopositiontaking, @isauto_v99spositiontaking_2 AS isautopositiontaking, @v99mspositiontaking_2_min as autopositiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_3 AS autopositiontaking, @isauto_v99spositiontaking_3 AS isautopositiontaking, @v99mspositiontaking_3_min as autopositiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_10 AS autopositiontaking, @isauto_v99spositiontaking_10 AS isautopositiontaking, @v99mspositiontaking_10_min as autopositiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_20 AS autopositiontaking, @isauto_v99spositiontaking_20 AS isautopositiontaking, @v99mspositiontaking_20_min as autopositiontaking_min
										
					) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END	

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
							SELECT 1 AS bettype, 99 AS sporttype, @v99spositiontaking_1 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @v99spositiontaking_2 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @v99spositiontaking_3 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 10 AS bettype, 99 AS sporttype, @v99spositiontaking_10 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @v99spositiontaking_20 AS positiontaking, 0 AS livepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END	
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 99 AS sporttype, @v99spositiontaking_1 AS positiontaking, @isauto_v99spositiontaking_1 as isauto_spositiontaking, @isauto_v99smpositiontaking_1 as isauto_smpositiontaking, @v99mspositiontaking_1_max as positiontaking_max
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @v99spositiontaking_2 AS positiontaking, @isauto_v99spositiontaking_2 as isauto_spositiontaking, @isauto_v99smpositiontaking_2 as isauto_smpositiontaking, @v99mspositiontaking_2_max as positiontaking_max
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @v99spositiontaking_3 AS positiontaking, @isauto_v99spositiontaking_3 as isauto_spositiontaking, @isauto_v99smpositiontaking_3 as isauto_smpositiontaking, @v99mspositiontaking_3_max as positiontaking_max
					UNION ALL 	SELECT 10 AS bettype, 99 AS sporttype, @v99spositiontaking_10 AS positiontaking, @isauto_v99spositiontaking_10 as isauto_spositiontaking, @isauto_v99smpositiontaking_10 as isauto_smpositiontaking, @v99mspositiontaking_10_max as positiontaking_max
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @v99spositiontaking_20 AS positiontaking, @isauto_v99spositiontaking_20 as isauto_spositiontaking, @isauto_v99smpositiontaking_20 as isauto_smpositiontaking, @v99mspositiontaking_20_max as positiontaking_max
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
			from
				(
					SELECT 1 AS bettype, 99 AS sporttype, @v99spositiontaking_1 AS positiontaking, @isauto_v99spositiontaking_1 as isauto_spositiontaking, @isauto_v99smpositiontaking_1 as isauto_smpositiontaking, @v99mspositiontaking_1_min as positiontaking_min						
					UNION ALL 	SELECT 2 AS bettype, 99 AS sporttype, @v99spositiontaking_2 AS positiontaking, @isauto_v99spositiontaking_2 as isauto_spositiontaking, @isauto_v99smpositiontaking_2 as isauto_smpositiontaking, @v99mspositiontaking_2_min as positiontaking_min
					UNION ALL 	SELECT 3 AS bettype, 99 AS sporttype, @v99spositiontaking_3 AS positiontaking, @isauto_v99spositiontaking_3 as isauto_spositiontaking, @isauto_v99smpositiontaking_3 as isauto_smpositiontaking, @v99mspositiontaking_3_min as positiontaking_min
					UNION ALL 	SELECT 10 AS bettype, 99 AS sporttype, @v99spositiontaking_10 AS positiontaking, @isauto_v99spositiontaking_10 as isauto_spositiontaking, @isauto_v99smpositiontaking_10 as isauto_smpositiontaking, @v99mspositiontaking_10_min as positiontaking_min
					UNION ALL 	SELECT 20 AS bettype, 99 AS sporttype, @v99spositiontaking_20 AS positiontaking, @isauto_v99spositiontaking_20 as isauto_spositiontaking, @isauto_v99smpositiontaking_20 as isauto_smpositiontaking, @v99mspositiontaking_20_min as positiontaking_min
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END--@UpdatePositiontakingv99	

		--Mix Parlay Mixed Sports
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv99MP = 1	)
		BEGIN--@UpdatePositiontakingv99MP
			if 
				@v99spositiontaking_9 <0 OR @v99spositiontaking_9 > 0.9

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
	
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride AS co with (NOLOCK) 
			inner join
				(SELECT 99 AS sporttype, 9 AS bettype, @auto_v99spositiontaking_9 AS autopositiontaking, @isauto_v99spositiontaking_9 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
					
				) AS b 
					on co.sporttype=b.sporttype and co.bettype=b.bettype
			INNER JOIN @tmp_Sports sports 
					on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype 
					on b.bettype = bettype.typeid
				where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=1 and b.bettype in (1,3,7,8) and b.autolivepositiontaking>co.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END

			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
						SELECT 9 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_9 AS autopositiontaking, 0 AS autolivepositiontaking
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.autopositiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.autolivepositiontaking))
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
			from 
				(
						SELECT 9 AS bettype, 99 AS sporttype, @auto_v99spositiontaking_9 AS autopositiontaking, @isauto_v99spositiontaking_9 AS isautopositiontaking, @v99mspositiontaking_9_min as autopositiontaking_min						
				) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END	

			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=1 and b.bettype in (1,3,7,8) THEN '-MaxLive: '+ cast((cs.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting AS cs with (NOLOCK) inner join
				(
						SELECT 9 AS bettype, 99 AS sporttype, @v99spositiontaking_9 AS positiontaking, 0 AS livepositiontaking
				
				) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs.custid = @srecommend
				and 
				((cs.spositiontaking<b.positiontaking) or (b.bettype in (1,3,7,8) and b.sporttype=1 and cs.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
			from
				(
					SELECT 9 AS bettype, 99 AS sporttype, @v99spositiontaking_9 AS positiontaking, @isauto_v99spositiontaking_9 as isauto_spositiontaking, @isauto_v99smpositiontaking_9 as isauto_smpositiontaking, @v99mspositiontaking_9_max as positiontaking_max
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
			from
				(
					SELECT 9 AS bettype, 99 AS sporttype, @v99spositiontaking_9 AS positiontaking, @isauto_v99spositiontaking_9 as isauto_spositiontaking, @isauto_v99smpositiontaking_9 as isauto_smpositiontaking, @v99mspositiontaking_9_min as positiontaking_min						
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END--@UpdatePositiontakingv99MP
	
		-- HR Fixed Odds
		IF @UpdateMultiple = 0 OR @UpdatePositiontakingv154 = 1
		BEGIN -- UpdatePositiontakingv154
			IF @v154spositiontaking_20 < 0 OR @v154spositiontaking_20 > 0.9
			BEGIN
				SELECT @ErrCode = 8
				SELECT @ErrMsg = CASE @language WHEN 'E' THEN 'Wrong position taking (for HR Fixed Odds)'
					ELSE dbo.f_Get_MsgNamebyMsgID(20001, @language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
				                 END
				                 RETURN
			END
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
				from custoverride AS co with (NOLOCK) 
				inner join
					(
					SELECT 154 AS sporttype, 20 AS bettype, @auto_v154spositiontaking_20 AS autopositiontaking,
							@isauto_v154spositiontaking_20 AS isautopositiontaking
					) AS b 
						on co.sporttype=b.sporttype and co.bettype=b.bettype
				INNER JOIN @tmp_Sports sports 
						on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype 
						on b.bettype = bettype.typeid

				where co.custid = @srecommend 
				and b.isautopositiontaking>0 
				and b.autopositiontaking>co.maxpositiontaking
				
				if @ErrType <>''
				BEGIN
					SELECT @isvalid = 0, @ErrCode_cur = 2
					SELECT @ErrMsg_cur = 	case @Language 
													WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
													ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
											END
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END 
				
				--Check u1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))+ '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
						SELECT 20 AS bettype, 154 AS sporttype, @auto_v154spositiontaking_20 AS autopositiontaking
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and cs.spositiontaking<b.autopositiontaking
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 7							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					RETURN
					
				END
				
				--Check u1>=us1_min (= min_s1)
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10)) + '<br>'
				from 
					(
							SELECT 20 AS bettype, 154 AS sporttype, @auto_v154spositiontaking_20 AS autopositiontaking, @isauto_v154spositiontaking_20 AS isautopositiontaking, @v154mspositiontaking_20_min as autopositiontaking_min						
					) AS b 
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) 
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 11							
					SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END	
				
				--Check s1<=s4
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs.spositiontaking) AS varchar(10))+ '<br>'
				from custsetting AS cs with (NOLOCK) inner join
					(
						SELECT 20 AS bettype, 154 AS sporttype,@v154spositiontaking_20 AS positiontaking	
					) AS b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
					INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
					INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where cs.custid = @srecommend
					and cs.spositiontaking<b.positiontaking
					
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1<=s1_max
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10)) + '<br>'
				from
					(
						SELECT 20 AS bettype, 154 AS sporttype,@v154spositiontaking_20 AS positiontaking,
						@isauto_v154spositiontaking_20 as isauto_spositiontaking,
						@isauto_v154smpositiontaking_20 as isauto_smpositiontaking, 
						@v154mspositiontaking_20_max as positiontaking_max
					) b
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 8							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
				
				--Check s1>=s1_min
				SELECT @ErrType = ''
				SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10)) + '<br>'
				from
					(
						SELECT 20 AS bettype, 154 AS sporttype, @v154spositiontaking_20 AS positiontaking, @isauto_v154spositiontaking_20 as isauto_spositiontaking, @isauto_v154smpositiontaking_20 as isauto_smpositiontaking, @v154mspositiontaking_20_min as positiontaking_min						
					) b
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
				where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0)
				
				if @ErrType <>''
				BEGIN
					SELECT @ErrMsg_cur =	@UserName + ': '+
										case @Language 
											WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
										END, @ErrCode_cur = 12							
					select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
							@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
					return
				END
			END
		--v161 number game
		if (@UpdateMultiple = 0 or  @UpdatePositiontakingv161 = 1)
		BEGIN --@UpdatePositiontakingv161
			if 
				@v161spositiontaking_81 <0 OR @v161spositiontaking_81 >0.9	
				OR @v161spositiontaking_83 <0 OR @v161spositiontaking_83 >0.9	
				OR @v161spositiontaking_86 <0 OR @v161spositiontaking_86 >0.9	
				OR @v161spositiontaking_88 <0 OR @v161spositiontaking_88 >0.9	
				OR @v161slivepositiontaking_85 <0 OR @v161slivepositiontaking_85 >0.9	
				OR @v161slivepositiontaking_86 <0 OR @v161slivepositiontaking_86 >0.9	
				OR @v161slivepositiontaking_87 <0 OR @v161slivepositiontaking_87 >0.9	
				OR @v161slivepositiontaking_89 <0 OR @v161slivepositiontaking_89 >0.9	
				OR @v161slivepositiontaking_90 <0 OR @v161slivepositiontaking_90 >0.9	
			BEGIN
				select @ErrCode = 8
				Select @ErrMsg = 	case @Language 
									when 'E' then 'Wrong position taking (for Number Game).'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end
				return
			END
		--Check u1<=l4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + ', '
			from custoverride3rd AS co3 with (NOLOCK) inner join
			(
				SELECT 161 AS sporttype, 81 AS bettype, @auto_v161spositiontaking_81 AS autopositiontaking, @isauto_v161spositiontaking_81 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 83 AS bettype, @auto_v161spositiontaking_83 AS autopositiontaking, @isauto_v161spositiontaking_83 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 88 AS bettype, @auto_v161spositiontaking_88 AS autopositiontaking, @isauto_v161spositiontaking_88 AS isautopositiontaking, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 85 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_85 AS autolivepositiontaking, @isauto_v161slivepositiontaking_85 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 86 AS bettype, @auto_v161spositiontaking_86 AS autopositiontaking, @isauto_v161spositiontaking_86 AS isautopositiontaking, @auto_v161slivepositiontaking_86 AS autolivepositiontaking, @isauto_v161slivepositiontaking_86 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 87 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_87 AS autolivepositiontaking, @isauto_v161slivepositiontaking_87 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 89 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_89 AS autolivepositiontaking, @isauto_v161slivepositiontaking_89 AS isautolivepositiontaking
				UNION ALL	SELECT 161 AS sporttype, 90 AS bettype, 0 AS autopositiontaking, 0 AS isautopositiontaking, @auto_v161slivepositiontaking_90 AS autolivepositiontaking, @isauto_v161slivepositiontaking_90 AS isautolivepositiontaking
				
			) AS b on co3.sporttype=b.sporttype and co3.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid

			where co3.custid = @srecommEND and ((b.isautopositiontaking>0 and b.autopositiontaking>co3.maxpositiontaking) or (b.isautolivepositiontaking>0 and b.sporttype=161 and b.bettype in (85,86,87) and b.autolivepositiontaking>co3.maxlivepositiontaking))

			if @ErrType <>''
			BEGIN
				SELECT @isvalid = 0, @ErrCode_cur = 2
				SELECT @ErrMsg_cur = 	case @Language 
												WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
										END
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			-- END check parameter
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


			-- number game
			--Check u1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((cs3.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting3rd AS cs3 with (NOLOCK) inner join
				(
								SELECT 81 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_81 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_83 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_88 AS autopositiontaking, 0 AS autolivepositiontaking
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_85 AS autolivepositiontaking
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_86 AS autopositiontaking, @auto_v161slivepositiontaking_86 AS autolivepositiontaking
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_87 AS autolivepositiontaking
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_89 AS autolivepositiontaking
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, @auto_v161slivepositiontaking_90 AS autolivepositiontaking
					
				) AS b on cs3.sporttype=b.sporttype and cs3.bettype=b.bettype
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs3.custid = @srecommEND
				and 
				((cs3.spositiontaking<b.autopositiontaking) or (b.bettype in (85,86,87,89,90) and b.sporttype=161 and cs3.slivepositiontaking<b.autolivepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 7							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check u1>=us1_min (= min_s1)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.autopositiontaking_min) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MinLive: '+ cast((b.autolivepositiontaking_min) AS varchar(10)) ELSE '' END + '<br>'
			from 
				(
							SELECT 81 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_81 AS autopositiontaking, @isauto_v161spositiontaking_81 AS isautopositiontaking, @v161mspositiontaking_81_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 as autolivepositiontaking_min
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_83 AS autopositiontaking, @isauto_v161spositiontaking_83 AS isautopositiontaking, @v161mspositiontaking_83_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 as autolivepositiontaking_min
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_88 AS autopositiontaking, @isauto_v161spositiontaking_88 AS isautopositiontaking, @v161mspositiontaking_88_min as autopositiontaking_min, 0 AS autolivepositiontaking, 0 AS isautolivepositiontaking, 0 as autolivepositiontaking_min
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, 0 AS isautopositiontaking, 0 as autopositiontaking_min, @auto_v161slivepositiontaking_85 AS autolivepositiontaking, @isauto_v161slivepositiontaking_85 AS isautolivepositiontaking, @v161mslivepositiontaking_85_min AS autolivepositiontaking_min
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @auto_v161spositiontaking_86 AS autopositiontaking, @isauto_v161spositiontaking_86 AS isautopositiontaking, @v161mspositiontaking_86_min as autopositiontaking_min, @auto_v161slivepositiontaking_86 AS autolivepositiontaking, @isauto_v161slivepositiontaking_86 AS isautolivepositiontaking, @v161mslivepositiontaking_86_min AS autolivepositiontaking_min
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, 0 AS isautopositiontaking, 0 as autopositiontaking_min, @auto_v161slivepositiontaking_87 AS autolivepositiontaking, @isauto_v161slivepositiontaking_87 AS isautolivepositiontaking, @v161mslivepositiontaking_87_min AS autolivepositiontaking_min
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, 0 AS isautopositiontaking, 0 as autopositiontaking_min, @auto_v161slivepositiontaking_89 AS autolivepositiontaking, @isauto_v161slivepositiontaking_89 AS isautolivepositiontaking, @v161mslivepositiontaking_89_min AS autolivepositiontaking_min
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS autopositiontaking, 0 AS isautopositiontaking, 0 as autopositiontaking_min, @auto_v161slivepositiontaking_90 AS autolivepositiontaking, @isauto_v161slivepositiontaking_90 AS isautolivepositiontaking, @v161mslivepositiontaking_90_min AS autolivepositiontaking_min
										
					) AS b 
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where ((b.isautopositiontaking = 1 and b.autopositiontaking < b.autopositiontaking_min) or (b.bettype in (1,3,7,8) and b.sporttype=1 and b.isautolivepositiontaking = 1 and b.autolivepositiontaking < b.autolivepositiontaking_min ))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 11							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END						

			-- number game
			--Check s1<=s4
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.spositiontaking) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((cs3.slivepositiontaking) AS varchar(10)) ELSE '' END + '<br>'
			from custsetting3rd AS cs3 with (NOLOCK) inner join
				(
								SELECT 81 AS bettype, 161 AS sporttype, @v161spositiontaking_81 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @v161spositiontaking_83 AS positiontaking, 0 AS livepositiontaking
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @v161spositiontaking_88 AS positiontaking, 0 AS livepositiontaking	
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_85 AS livepositiontaking
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @v161spositiontaking_86 AS positiontaking, @v161slivepositiontaking_86 AS livepositiontaking
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_87 AS livepositiontaking
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_89 AS livepositiontaking
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS positiontaking, @v161slivepositiontaking_90 AS livepositiontaking
					
				) AS b on cs3.sporttype=b.sporttype and cs3.bettype=b.bettype
				INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
				INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where cs3.custid = @srecommEND
				and 
				((cs3.spositiontaking<b.positiontaking) or (b.bettype in (85,86,87,89,90) and b.sporttype=161 and cs3.slivepositiontaking<b.livepositiontaking))
				
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1<=s1_max
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.positiontaking_max) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MaxLive: '+ cast((b.livepositiontaking_max) AS varchar(10)) ELSE '' END + '<br>'
			from
				(
					SELECT 81 AS bettype, 161 AS sporttype, @v161spositiontaking_81 AS positiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking, @isauto_v161smpositiontaking_81 as isauto_smpositiontaking, @v161mspositiontaking_81_max as positiontaking_max, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 as livepositiontaking_max
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @v161spositiontaking_83 AS positiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking, @isauto_v161smpositiontaking_83 as isauto_smpositiontaking, @v161mspositiontaking_83_max as positiontaking_max, 0							 AS livepositiontaking, 0								   as isauto_slivepositiontaking, 0									  as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @v161spositiontaking_88 AS positiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking, @isauto_v161smpositiontaking_88 as isauto_smpositiontaking, @v161mspositiontaking_88_max as positiontaking_max, 0							 AS livepositiontaking, 0								   as isauto_slivepositiontaking, 0									  as isauto_smlivepositiontaking, 0 AS livepositiontaking_max
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0						AS positiontaking, 0							  as isauto_spositiontaking, 0								 as isauto_smpositiontaking, 0							  as positiontaking_max, @v161slivepositiontaking_85 AS livepositiontaking, @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_85 as isauto_smlivepositiontaking, @v161mslivepositiontaking_85_max AS livepositiontaking_max
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @v161spositiontaking_86 AS positiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking, @isauto_v161smpositiontaking_86 as isauto_smpositiontaking, @v161mspositiontaking_86_max as positiontaking_max, @v161slivepositiontaking_86 AS livepositiontaking, @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_86 as isauto_smlivepositiontaking, @v161mslivepositiontaking_86_max AS livepositiontaking_max
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0						AS positiontaking, 0							  as isauto_spositiontaking, 0								 as isauto_smpositiontaking, 0							  as positiontaking_max, @v161slivepositiontaking_87 AS livepositiontaking, @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_87 as isauto_smlivepositiontaking, @v161mslivepositiontaking_87_max AS livepositiontaking_max
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0						AS positiontaking, 0							  as isauto_spositiontaking, 0								 as isauto_smpositiontaking, 0							  as positiontaking_max, @v161slivepositiontaking_89 AS livepositiontaking, @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_89 as isauto_smlivepositiontaking, @v161mslivepositiontaking_89_max AS livepositiontaking_max
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0						AS positiontaking, 0							  as isauto_spositiontaking, 0								 as isauto_smpositiontaking, 0							  as positiontaking_max, @v161slivepositiontaking_90 AS livepositiontaking, @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_90 as isauto_smlivepositiontaking, @v161mslivepositiontaking_90_max AS livepositiontaking_max
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking > b.positiontaking_max and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0) or (b.bettype in (85,86,87,89,90) and b.livepositiontaking > b.livepositiontaking_max and b.isauto_slivepositiontaking= 0 and b.isauto_smlivepositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 8							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
			
			--Check s1>=s1_min
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((b.positiontaking_min) AS varchar(10))
			+ CASE WHEN b.sporttype=161 and b.bettype in (85,86,87,89,90) THEN '-MinLive: '+ cast((b.livepositiontaking_min) AS varchar(10)) ELSE '' END + '<br>'
			from
				(
								SELECT 81 AS bettype, 161 AS sporttype, @v161spositiontaking_81 AS positiontaking, @isauto_v161spositiontaking_81 as isauto_spositiontaking, @isauto_v161smpositiontaking_81 as isauto_smpositiontaking, @v161mspositiontaking_81_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 as livepositiontaking_min
					UNION ALL 	SELECT 83 AS bettype, 161 AS sporttype, @v161spositiontaking_83 AS positiontaking, @isauto_v161spositiontaking_83 as isauto_spositiontaking, @isauto_v161smpositiontaking_83 as isauto_smpositiontaking, @v161mspositiontaking_83_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 as livepositiontaking_min
					UNION ALL 	SELECT 88 AS bettype, 161 AS sporttype, @v161spositiontaking_88 AS positiontaking, @isauto_v161spositiontaking_88 as isauto_spositiontaking, @isauto_v161smpositiontaking_88 as isauto_smpositiontaking, @v161mspositiontaking_88_min as positiontaking_min, 0 AS livepositiontaking, 0 as isauto_slivepositiontaking, 0 as isauto_smlivepositiontaking, 0 as livepositiontaking_min
					UNION ALL 	SELECT 85 AS bettype, 161 AS sporttype, 0 AS positiontaking, 0 as isauto_spositiontaking, 0 as isauto_smpositiontaking, 0 as positiontaking_min, @v161slivepositiontaking_85 AS livepositiontaking, @isauto_v161slivepositiontaking_85 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_85 as isauto_smlivepositiontaking, @v161mslivepositiontaking_85_min as livepositiontaking_min
					UNION ALL 	SELECT 86 AS bettype, 161 AS sporttype, @v161spositiontaking_86 AS positiontaking, @isauto_v161spositiontaking_86 as isauto_spositiontaking, @isauto_v161smpositiontaking_86 as isauto_smpositiontaking, @v161mspositiontaking_86_min as positiontaking_min, @v161slivepositiontaking_86 AS livepositiontaking, @isauto_v161slivepositiontaking_86 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_86 as isauto_smlivepositiontaking, @v161mslivepositiontaking_86_min as livepositiontaking_min
					UNION ALL 	SELECT 87 AS bettype, 161 AS sporttype, 0 AS positiontaking, 0 as isauto_spositiontaking, 0 as isauto_smpositiontaking, 0 as positiontaking_min, @v161slivepositiontaking_87 AS livepositiontaking, @isauto_v161slivepositiontaking_87 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_87 as isauto_smlivepositiontaking, @v161mslivepositiontaking_87_min as livepositiontaking_min
					UNION ALL 	SELECT 89 AS bettype, 161 AS sporttype, 0 AS positiontaking, 0 as isauto_spositiontaking, 0 as isauto_smpositiontaking, 0 as positiontaking_min, @v161slivepositiontaking_89 AS livepositiontaking, @isauto_v161slivepositiontaking_89 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_89 as isauto_smlivepositiontaking, @v161mslivepositiontaking_89_min as livepositiontaking_min
					UNION ALL 	SELECT 90 AS bettype, 161 AS sporttype, 0 AS positiontaking, 0 as isauto_spositiontaking, 0 as isauto_smpositiontaking, 0 as positiontaking_min, @v161slivepositiontaking_90 AS livepositiontaking, @isauto_v161slivepositiontaking_90 as isauto_slivepositiontaking, @isauto_v161smlivepositiontaking_90 as isauto_smlivepositiontaking, @v161mslivepositiontaking_90_min as livepositiontaking_min
					
				) b
			INNER JOIN @tmp_Sports sports on b.sporttype = sports.sporttype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			where (b.positiontaking < b.positiontaking_min and b.isauto_spositiontaking= 0 and b.isauto_smpositiontaking = 0) or (b.bettype in (85,86,87,89,90) and b.livepositiontaking < b.livepositiontaking_min and b.isauto_slivepositiontaking= 0 and b.isauto_smlivepositiontaking = 0)
			
			if @ErrType <>''
			BEGIN
				SELECT @ErrMsg_cur =	@UserName + ': '+
									case @Language 
										WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
									END, @ErrCode_cur = 12							
				select	@ErrCode = @ErrCode + cast(@ErrCode_cur AS varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				return
			END
		END --@UpdatePositiontakingv161


	SELECT @spositiontaking_1_max = spositiontaking, @slivepositiontaking_1_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=1
	SELECT @spositiontaking_3_max = spositiontaking, @slivepositiontaking_3_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=1
	SELECT @spositiontaking_7_max = spositiontaking, @slivepositiontaking_7_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=7 and sporttype=1
	SELECT @spositiontaking_8_max = spositiontaking, @slivepositiontaking_8_max = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=8 and sporttype=1

	SELECT @spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=1
	SELECT @spositiontaking_4_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=4 and sporttype=1
	SELECT @spositiontaking_5_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=5 and sporttype=1
	SELECT @spositiontaking_6_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=6 and sporttype=1
	SELECT @spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=1
	SELECT @spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=1
	
	-- Outright PT for sports
	SELECT @v2spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=2
	SELECT @v3spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=3
	SELECT @v5spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=5
	SELECT @v8spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=8
	SELECT @v10spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=10
	SELECT @v11spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=11
	SELECT @v99spositiontaking_10_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=10 and sporttype=99
	
	SELECT @spositiontaking_9999_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9999 and sporttype=1

	SELECT @v2spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=2
	SELECT @v2spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=2
	SELECT @v2spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=2
	SELECT @v2spositiontaking_7_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=7 and sporttype=2
	SELECT @v2spositiontaking_8_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=8 and sporttype=2
	--select @v2spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=2
	SELECT @v2spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=2

	SELECT @v3spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=3
	SELECT @v3spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=3
	SELECT @v3spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=3
	SELECT @v3spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=3

	SELECT @v5spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=5
	SELECT @v5spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=5
	SELECT @v5spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=5
	SELECT @v5spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=5
	SELECT @v5spositiontaking_9999_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9999 and sporttype=5

	SELECT @v8spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=8
	SELECT @v8spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=8
	SELECT @v8spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=8

	SELECT @v10spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=10
	SELECT @v10spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=10
	SELECT @v10spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=10
	SELECT @v10spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=10

	SELECT @v11spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=11
	SELECT @v11spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=11

	SELECT @v99spositiontaking_1_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=1 and sporttype=99
	SELECT @v99spositiontaking_2_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=2 and sporttype=99
	SELECT @v99spositiontaking_3_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=3 and sporttype=99
	SELECT @v99spositiontaking_20_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=20 and sporttype=99

	--mixed sports
	SELECT @v99spositiontaking_9_max = spositiontaking from custsetting with (NOLOCK) where custid = @srecommEND and bettype=9 and sporttype=99
	
	-- HR Fixed Odds
	SELECT @v154spositiontaking_20_max = spositiontaking
	FROM custsetting WITH (NOLOCK)
	WHERE custid = @srecommend 
	AND bettype = 20 
	AND sporttype = 154
	
	--number game
	SELECT @v161spositiontaking_81_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=81 and sporttype=161
	SELECT @v161spositiontaking_83_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=83 and sporttype=161
	SELECT @v161spositiontaking_88_max = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=88 and sporttype=161
	SELECT @v161slivepositiontaking_85_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=85 and sporttype=161
	SELECT @v161spositiontaking_86_max = spositiontaking, @v161slivepositiontaking_86_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=86 and sporttype=161
	SELECT @v161slivepositiontaking_87_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=87 and sporttype=161
	SELECT @v161slivepositiontaking_89_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=89 and sporttype=161
	SELECT @v161slivepositiontaking_90_max = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommEND and bettype=90 and sporttype=161

	SELECT 
		@spositiontaking_1 = CASE WHEN @spositiontaking_1+@mpositiontaking_1+@apositiontaking_1>@spositiontaking_1_max THEN @spositiontaking_1_max-@mpositiontaking_1-@apositiontaking_1 ELSE @spositiontaking_1 END,
		@spositiontaking_2 = CASE WHEN @spositiontaking_2+@mpositiontaking_2+@apositiontaking_2>@spositiontaking_2_max THEN @spositiontaking_2_max-@mpositiontaking_2-@apositiontaking_2 ELSE @spositiontaking_2 END,
		@spositiontaking_3 = CASE WHEN @spositiontaking_3+@mpositiontaking_3+@apositiontaking_3>@spositiontaking_3_max THEN @spositiontaking_3_max-@mpositiontaking_3-@apositiontaking_3 ELSE @spositiontaking_3 END,
		@spositiontaking_4 = CASE WHEN @spositiontaking_4+@mpositiontaking_4+@apositiontaking_4>@spositiontaking_4_max THEN @spositiontaking_4_max-@mpositiontaking_4-@apositiontaking_4 ELSE @spositiontaking_4 END,
		@spositiontaking_5 = CASE WHEN @spositiontaking_5+@mpositiontaking_5+@apositiontaking_5>@spositiontaking_5_max THEN @spositiontaking_5_max-@mpositiontaking_5-@apositiontaking_5 ELSE @spositiontaking_5 END,
		@spositiontaking_6 = CASE WHEN @spositiontaking_6+@mpositiontaking_6+@apositiontaking_6>@spositiontaking_6_max THEN @spositiontaking_6_max-@mpositiontaking_6-@apositiontaking_6 ELSE @spositiontaking_6 END,
		@spositiontaking_7 = CASE WHEN @spositiontaking_7+@mpositiontaking_7+@apositiontaking_7>@spositiontaking_7_max THEN @spositiontaking_7_max-@mpositiontaking_7-@apositiontaking_7 ELSE @spositiontaking_7 END,
		@spositiontaking_8 = CASE WHEN @spositiontaking_8+@mpositiontaking_8+@apositiontaking_8>@spositiontaking_8_max THEN @spositiontaking_8_max-@mpositiontaking_8-@apositiontaking_8 ELSE @spositiontaking_8 END,
		@spositiontaking_9 = CASE WHEN @spositiontaking_9+@mpositiontaking_9+@apositiontaking_9>@spositiontaking_9_max THEN @spositiontaking_9_max-@mpositiontaking_9-@apositiontaking_9 ELSE @spositiontaking_9 END,
		@spositiontaking_10 = CASE WHEN @spositiontaking_10+@mpositiontaking_10+@apositiontaking_10>@spositiontaking_10_max THEN @spositiontaking_10_max-@mpositiontaking_10-@apositiontaking_10 ELSE @spositiontaking_10 END,
		
		-- Outright PT for sports
		@v2spositiontaking_10 = CASE WHEN @v2spositiontaking_10+@v2mpositiontaking_10+@v2apositiontaking_10>@v2spositiontaking_10_max THEN @v2spositiontaking_10_max-@v2mpositiontaking_10-@v2apositiontaking_10 ELSE @v2spositiontaking_10 END,
		@v3spositiontaking_10 = CASE WHEN @v3spositiontaking_10+@v3mpositiontaking_10+@v3apositiontaking_10>@v3spositiontaking_10_max THEN @v3spositiontaking_10_max-@v3mpositiontaking_10-@v3apositiontaking_10 ELSE @v3spositiontaking_10 END,
		@v5spositiontaking_10 = CASE WHEN @v5spositiontaking_10+@v5mpositiontaking_10+@v5apositiontaking_10>@v5spositiontaking_10_max THEN @v5spositiontaking_10_max-@v5mpositiontaking_10-@v5apositiontaking_10 ELSE @v5spositiontaking_10 END,
		@v8spositiontaking_10 = CASE WHEN @v8spositiontaking_10+@v8mpositiontaking_10+@v8apositiontaking_10>@v8spositiontaking_10_max THEN @v8spositiontaking_10_max-@v8mpositiontaking_10-@v8apositiontaking_10 ELSE @v8spositiontaking_10 END,
		@v10spositiontaking_10 = CASE WHEN @v10spositiontaking_10+@v10mpositiontaking_10+@v10apositiontaking_10>@v10spositiontaking_10_max THEN @v10spositiontaking_10_max-@v10mpositiontaking_10-@v10apositiontaking_10 ELSE @v10spositiontaking_10 END,
		@v11spositiontaking_10 = CASE WHEN @v11spositiontaking_10+@v11mpositiontaking_10+@v11apositiontaking_10>@v11spositiontaking_10_max THEN @v11spositiontaking_10_max-@v11mpositiontaking_10-@v11apositiontaking_10 ELSE @v11spositiontaking_10 END,
		@v99spositiontaking_10 = CASE WHEN @v99spositiontaking_10+@v99mpositiontaking_10+@v99apositiontaking_10>@v99spositiontaking_10_max THEN @v99spositiontaking_10_max-@v99mpositiontaking_10-@v99apositiontaking_10 ELSE @v99spositiontaking_10 END,
		
		@spositiontaking_9999 = CASE WHEN @spositiontaking_9999+@mpositiontaking_9999+@apositiontaking_9999>@spositiontaking_9999_max THEN @spositiontaking_9999_max-@mpositiontaking_9999-@apositiontaking_9999 ELSE @spositiontaking_9999 END,

		@slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1+@mlivepositiontaking_1+@alivepositiontaking_1>@slivepositiontaking_1_max THEN @slivepositiontaking_1_max-@mlivepositiontaking_1-@alivepositiontaking_1 ELSE @slivepositiontaking_1 END,
		@slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3+@mlivepositiontaking_3+@alivepositiontaking_3>@slivepositiontaking_3_max THEN @slivepositiontaking_3_max-@mlivepositiontaking_3-@alivepositiontaking_3 ELSE @slivepositiontaking_3 END,
		@slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7+@mlivepositiontaking_7+@alivepositiontaking_7>@slivepositiontaking_7_max THEN @slivepositiontaking_7_max-@mlivepositiontaking_7-@alivepositiontaking_7 ELSE @slivepositiontaking_7 END,
		@slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8+@mlivepositiontaking_8+@alivepositiontaking_8>@slivepositiontaking_8_max THEN @slivepositiontaking_8_max-@mlivepositiontaking_8-@alivepositiontaking_8 ELSE @slivepositiontaking_8 END,

		@v2spositiontaking_1 = CASE WHEN @v2mpositiontaking_1+@v2spositiontaking_1+@v2apositiontaking_1>@v2spositiontaking_1_max THEN @v2spositiontaking_1_max-@v2mpositiontaking_1-@v2apositiontaking_1 ELSE @v2spositiontaking_1 END,
		@v2spositiontaking_2 = CASE WHEN @v2mpositiontaking_2+@v2spositiontaking_2+@v2apositiontaking_2>@v2spositiontaking_2_max THEN @v2spositiontaking_2_max-@v2mpositiontaking_2-@v2apositiontaking_2 ELSE @v2spositiontaking_2 END,
		@v2spositiontaking_3 = CASE WHEN @v2mpositiontaking_3+@v2spositiontaking_3+@v2apositiontaking_3>@v2spositiontaking_3_max THEN @v2spositiontaking_3_max-@v2mpositiontaking_3-@v2apositiontaking_3 ELSE @v2spositiontaking_3 END,
		@v2spositiontaking_7 = CASE WHEN @v2mpositiontaking_7+@v2spositiontaking_7+@v2apositiontaking_7>@v2spositiontaking_7_max THEN @v2spositiontaking_7_max-@v2mpositiontaking_7-@v2apositiontaking_7 ELSE @v2spositiontaking_7 END,
		@v2spositiontaking_8 = CASE WHEN @v2mpositiontaking_8+@v2spositiontaking_8+@v2apositiontaking_8>@v2spositiontaking_8_max THEN @v2spositiontaking_8_max-@v2mpositiontaking_8-@v2apositiontaking_8 ELSE @v2spositiontaking_8 END,
	--	@v2spositiontaking_9 = CASE WHEN @v2mpositiontaking_9+@v2spositiontaking_9+@v2apositiontaking_9>@v2spositiontaking_9_max THEN @v2spositiontaking_9_max-@v2mpositiontaking_9-@v2apositiontaking_9 ELSE @v2spositiontaking_9 END,
		@v2spositiontaking_20 = CASE WHEN @v2mpositiontaking_20+@v2spositiontaking_20+@v2apositiontaking_20>@v2spositiontaking_20_max THEN @v2spositiontaking_20_max-@v2mpositiontaking_20-@v2apositiontaking_20 ELSE @v2spositiontaking_20 END,

		@v3spositiontaking_1 = CASE WHEN @v3mpositiontaking_1+@v3spositiontaking_1+@v3apositiontaking_1>@v3spositiontaking_1_max THEN @v3spositiontaking_1_max-@v3mpositiontaking_1-@v3apositiontaking_1 ELSE @v3spositiontaking_1 END,
		@v3spositiontaking_2 = CASE WHEN @v3mpositiontaking_2+@v3spositiontaking_2+@v3apositiontaking_2>@v3spositiontaking_2_max THEN @v3spositiontaking_2_max-@v3mpositiontaking_2-@v3apositiontaking_2 ELSE @v3spositiontaking_2 END,
		@v3spositiontaking_3 = CASE WHEN @v3mpositiontaking_3+@v3spositiontaking_3+@v3apositiontaking_3>@v3spositiontaking_3_max THEN @v3spositiontaking_3_max-@v3mpositiontaking_3-@v3apositiontaking_3 ELSE @v3spositiontaking_3 END,
		@v3spositiontaking_20 = CASE WHEN @v3mpositiontaking_20+@v3spositiontaking_20+@v3apositiontaking_20>@v3spositiontaking_20_max THEN @v3spositiontaking_20_max-@v3mpositiontaking_20-@v3apositiontaking_20 ELSE @v3spositiontaking_20 END,

		@v5spositiontaking_1 = CASE WHEN @v5mpositiontaking_1+@v5spositiontaking_1+@v5apositiontaking_1>@v5spositiontaking_1_max THEN @v5spositiontaking_1_max-@v5mpositiontaking_1-@v5apositiontaking_1 ELSE @v5spositiontaking_1 END,
		@v5spositiontaking_2 = CASE WHEN @v5mpositiontaking_2+@v5spositiontaking_2+@v5apositiontaking_2>@v5spositiontaking_2_max THEN @v5spositiontaking_2_max-@v5mpositiontaking_2-@v5apositiontaking_2 ELSE @v5spositiontaking_2 END,
		@v5spositiontaking_3 = CASE WHEN @v5mpositiontaking_3+@v5spositiontaking_3+@v5apositiontaking_3>@v5spositiontaking_3_max THEN @v5spositiontaking_3_max-@v5mpositiontaking_3-@v5apositiontaking_3 ELSE @v5spositiontaking_3 END,
		@v5spositiontaking_20 = CASE WHEN @v5mpositiontaking_20+@v5spositiontaking_20+@v5apositiontaking_20>@v5spositiontaking_20_max THEN @v5spositiontaking_20_max-@v5mpositiontaking_20-@v5apositiontaking_20 ELSE @v5spositiontaking_20 END,
		@v5spositiontaking_9999 = CASE WHEN @v5mpositiontaking_9999+@v5spositiontaking_9999+@v5apositiontaking_9999>@v5spositiontaking_9999_max THEN @v5spositiontaking_9999_max-@v5mpositiontaking_9999-@v5apositiontaking_9999 ELSE @v5spositiontaking_9999 END,

		@v8spositiontaking_1 = CASE WHEN @v8mpositiontaking_1+@v8spositiontaking_1+@v8apositiontaking_1>@v8spositiontaking_1_max THEN @v8spositiontaking_1_max-@v8mpositiontaking_1-@v8apositiontaking_1 ELSE @v8spositiontaking_1 END,
		@v8spositiontaking_3 = CASE WHEN @v8mpositiontaking_3+@v8spositiontaking_3+@v8apositiontaking_3>@v8spositiontaking_3_max THEN @v8spositiontaking_3_max-@v8mpositiontaking_3-@v8apositiontaking_3 ELSE @v8spositiontaking_3 END,
		@v8spositiontaking_20 = CASE WHEN @v8mpositiontaking_20+@v8spositiontaking_20+@v8apositiontaking_20>@v8spositiontaking_20_max THEN @v8spositiontaking_20_max-@v8mpositiontaking_20-@v8apositiontaking_20 ELSE @v8spositiontaking_20 END,

		@v10spositiontaking_1 = CASE WHEN @v10mpositiontaking_1+@v10spositiontaking_1+@v10apositiontaking_1>@v10spositiontaking_1_max THEN @v10spositiontaking_1_max-@v10mpositiontaking_1-@v10apositiontaking_1 ELSE @v10spositiontaking_1 END,
		@v10spositiontaking_2 = CASE WHEN @v10mpositiontaking_2+@v10spositiontaking_2+@v10apositiontaking_2>@v10spositiontaking_2_max THEN @v10spositiontaking_2_max-@v10mpositiontaking_2-@v10apositiontaking_2 ELSE @v10spositiontaking_2 END,
		@v10spositiontaking_3 = CASE WHEN @v10mpositiontaking_3+@v10spositiontaking_3+@v10apositiontaking_3>@v10spositiontaking_3_max THEN @v10spositiontaking_3_max-@v10mpositiontaking_3-@v10apositiontaking_3 ELSE @v10spositiontaking_3 END,
		@v10spositiontaking_20 = CASE WHEN @v10mpositiontaking_20+@v10spositiontaking_20+@v10apositiontaking_20>@v10spositiontaking_20_max THEN @v10spositiontaking_20_max-@v10mpositiontaking_20-@v10apositiontaking_20 ELSE @v10spositiontaking_20 END,

		@v11spositiontaking_1 = CASE WHEN @v11mpositiontaking_1+@v11spositiontaking_1+@v11apositiontaking_1>@v11spositiontaking_1_max THEN @v11spositiontaking_1_max-@v11mpositiontaking_1-@v11apositiontaking_1 ELSE @v11spositiontaking_1 END,
		@v11spositiontaking_20 = CASE WHEN @v11mpositiontaking_20+@v11spositiontaking_20+@v11apositiontaking_20>@v11spositiontaking_20_max THEN @v11spositiontaking_20_max-@v11mpositiontaking_20-@v11apositiontaking_20 ELSE @v11spositiontaking_20 END,

		@v99spositiontaking_1 = CASE WHEN @v99mpositiontaking_1+@v99spositiontaking_1+@v99apositiontaking_1>@v99spositiontaking_1_max THEN @v99spositiontaking_1_max-@v99mpositiontaking_1-@v99apositiontaking_1 ELSE @v99spositiontaking_1 END,
		@v99spositiontaking_2 = CASE WHEN @v99mpositiontaking_2+@v99spositiontaking_2+@v99apositiontaking_2>@v99spositiontaking_2_max THEN @v99spositiontaking_2_max-@v99mpositiontaking_2-@v99apositiontaking_2 ELSE @v99spositiontaking_2 END,
		@v99spositiontaking_3 = CASE WHEN @v99mpositiontaking_3+@v99spositiontaking_3+@v99apositiontaking_3>@v99spositiontaking_3_max THEN @v99spositiontaking_3_max-@v99mpositiontaking_3-@v99apositiontaking_3 ELSE @v99spositiontaking_3 END,
		@v99spositiontaking_20 = CASE WHEN @v99mpositiontaking_20+@v99spositiontaking_20+@v99apositiontaking_20>@v99spositiontaking_20_max THEN @v99spositiontaking_20_max-@v99mpositiontaking_20-@v99apositiontaking_20 ELSE @v99spositiontaking_20 END,

		-- mixed sports
		@v99spositiontaking_9 = CASE WHEN @v99mpositiontaking_9+@v99spositiontaking_9+@v99apositiontaking_9>@v99spositiontaking_9_max 
									THEN @v99spositiontaking_9_max-@v99mpositiontaking_9-@v99apositiontaking_9 ELSE @v99spositiontaking_9 
		                        END,
		-- HR Fixed Odds
		@v154spositiontaking_20 = CASE WHEN @v154mpositiontaking_20 + @v154spositiontaking_20 + @v154apositiontaking_20 > @v154spositiontaking_20_max
									THEN @v154spositiontaking_20_max - @v154mpositiontaking_20 - @v154apositiontaking_20 ELSE @v154spositiontaking_20
									END,
		-- number game
		@v161spositiontaking_81 = CASE WHEN @v161mpositiontaking_81+@v161spositiontaking_81+@v161apositiontaking_81>@v161spositiontaking_81_max THEN @v161spositiontaking_81_max-@v161mpositiontaking_81-@v161apositiontaking_81 ELSE @v161spositiontaking_81 END,
		@v161spositiontaking_83 = CASE WHEN @v161mpositiontaking_83+@v161spositiontaking_83+@v161apositiontaking_83>@v161spositiontaking_83_max THEN @v161spositiontaking_83_max-@v161mpositiontaking_83-@v161apositiontaking_83 ELSE @v161spositiontaking_83 END,		
		@v161spositiontaking_86 = CASE WHEN @v161mpositiontaking_86+@v161spositiontaking_86+@v161apositiontaking_86>@v161spositiontaking_86_max THEN @v161spositiontaking_86_max-@v161mpositiontaking_86-@v161apositiontaking_86 ELSE @v161spositiontaking_86 END,
		@v161spositiontaking_88 = CASE WHEN @v161mpositiontaking_88+@v161spositiontaking_88+@v161apositiontaking_88>@v161spositiontaking_88_max THEN @v161spositiontaking_88_max-@v161mpositiontaking_88-@v161apositiontaking_88 ELSE @v161spositiontaking_88 END,
		@v161slivepositiontaking_85 = CASE WHEN @v161mlivepositiontaking_85+@v161slivepositiontaking_85+@v161alivepositiontaking_85>@v161slivepositiontaking_85_max THEN @v161slivepositiontaking_85_max-@v161mlivepositiontaking_85-@v161alivepositiontaking_85 ELSE @v161slivepositiontaking_85 END,
		@v161slivepositiontaking_86 = CASE WHEN @v161mlivepositiontaking_86+@v161slivepositiontaking_86+@v161alivepositiontaking_86>@v161slivepositiontaking_86_max THEN @v161slivepositiontaking_86_max-@v161mlivepositiontaking_86-@v161alivepositiontaking_86 ELSE @v161slivepositiontaking_86 END,
		@v161slivepositiontaking_87 = CASE WHEN @v161mlivepositiontaking_87+@v161slivepositiontaking_87+@v161alivepositiontaking_87>@v161slivepositiontaking_87_max THEN @v161slivepositiontaking_87_max-@v161mlivepositiontaking_87-@v161alivepositiontaking_87 ELSE @v161slivepositiontaking_87 END,
		@v161slivepositiontaking_89 = CASE WHEN @v161mlivepositiontaking_89+@v161slivepositiontaking_89+@v161alivepositiontaking_89>@v161slivepositiontaking_89_max THEN @v161slivepositiontaking_89_max-@v161mlivepositiontaking_89-@v161alivepositiontaking_89 ELSE @v161slivepositiontaking_89 END,
		@v161slivepositiontaking_90 = CASE WHEN @v161mlivepositiontaking_90+@v161slivepositiontaking_90+@v161alivepositiontaking_90>@v161slivepositiontaking_90_max THEN @v161slivepositiontaking_90_max-@v161mlivepositiontaking_90-@v161alivepositiontaking_90 ELSE @v161slivepositiontaking_90 END

	SELECT 
		@spositiontaking_1 = CASE WHEN @spositiontaking_1<0 THEN 0 ELSE @spositiontaking_1 END,
		@spositiontaking_2 = CASE WHEN @spositiontaking_2<0 THEN 0 ELSE @spositiontaking_2 END,
		@spositiontaking_3 = CASE WHEN @spositiontaking_3<0 THEN 0 ELSE @spositiontaking_3 END,
		@spositiontaking_4 = CASE WHEN @spositiontaking_4<0 THEN 0 ELSE @spositiontaking_4 END,
		@spositiontaking_5 = CASE WHEN @spositiontaking_5<0 THEN 0 ELSE @spositiontaking_5 END,
		@spositiontaking_6 = CASE WHEN @spositiontaking_6<0 THEN 0 ELSE @spositiontaking_6 END,
		@spositiontaking_7 = CASE WHEN @spositiontaking_7<0 THEN 0 ELSE @spositiontaking_7 END,
		@spositiontaking_8 = CASE WHEN @spositiontaking_8<0 THEN 0 ELSE @spositiontaking_8 END,
		@spositiontaking_9 = CASE WHEN @spositiontaking_9<0 THEN 0 ELSE @spositiontaking_9 END,
		@spositiontaking_10 = CASE WHEN @spositiontaking_10<0 THEN 0 ELSE @spositiontaking_10 END,
		
		-- Outright PT for sports
		@v2spositiontaking_10 = CASE WHEN @v2spositiontaking_10<0 THEN 0 ELSE @v2spositiontaking_10 END,
		@v3spositiontaking_10 = CASE WHEN @v3spositiontaking_10<0 THEN 0 ELSE @v3spositiontaking_10 END,
		@v5spositiontaking_10 = CASE WHEN @v5spositiontaking_10<0 THEN 0 ELSE @v5spositiontaking_10 END,
		@v8spositiontaking_10 = CASE WHEN @v8spositiontaking_10<0 THEN 0 ELSE @v8spositiontaking_10 END,
		@v10spositiontaking_10 = CASE WHEN @v10spositiontaking_10<0 THEN 0 ELSE @v10spositiontaking_10 END,
		@v11spositiontaking_10 = CASE WHEN @v11spositiontaking_10<0 THEN 0 ELSE @v11spositiontaking_10 END,
		@v99spositiontaking_10 = CASE WHEN @v99spositiontaking_10<0 THEN 0 ELSE @v99spositiontaking_10 END,
		
		@spositiontaking_9999 = CASE WHEN @spositiontaking_9999<0 THEN 0 ELSE @spositiontaking_9999 END,

		@slivepositiontaking_1 = CASE WHEN @slivepositiontaking_1<0 THEN 0 ELSE @slivepositiontaking_1 END,
		@slivepositiontaking_3 = CASE WHEN @slivepositiontaking_3<0 THEN 0 ELSE @slivepositiontaking_3 END,
		@slivepositiontaking_7 = CASE WHEN @slivepositiontaking_7<0 THEN 0 ELSE @slivepositiontaking_7 END,
		@slivepositiontaking_8 = CASE WHEN @slivepositiontaking_8<0 THEN 0 ELSE @slivepositiontaking_8 END,

		@v2spositiontaking_1 = CASE WHEN @v2spositiontaking_1<0 THEN 0 ELSE @v2spositiontaking_1 END,
		@v2spositiontaking_2 = CASE WHEN @v2spositiontaking_2<0 THEN 0 ELSE @v2spositiontaking_2 END,
		@v2spositiontaking_3 = CASE WHEN @v2spositiontaking_3<0 THEN 0 ELSE @v2spositiontaking_3 END,
		@v2spositiontaking_7 = CASE WHEN @v2spositiontaking_7<0 THEN 0 ELSE @v2spositiontaking_7 END,
		@v2spositiontaking_8 = CASE WHEN @v2spositiontaking_8<0 THEN 0 ELSE @v2spositiontaking_8 END,
	--	@v2spositiontaking_9 = CASE WHEN @v2spositiontaking_9<0 THEN 0 ELSE @v2spositiontaking_9 END,
		@v2spositiontaking_20 = CASE WHEN @v2spositiontaking_20<0 THEN 0 ELSE @v2spositiontaking_20 END,

		@v3spositiontaking_1 = CASE WHEN @v3spositiontaking_1<0 THEN 0 ELSE @v3spositiontaking_1 END,
		@v3spositiontaking_2 = CASE WHEN @v3spositiontaking_2<0 THEN 0 ELSE @v3spositiontaking_2 END,
		@v3spositiontaking_3 = CASE WHEN @v3spositiontaking_3<0 THEN 0 ELSE @v3spositiontaking_3 END,
		@v3spositiontaking_20 = CASE WHEN @v3spositiontaking_20<0 THEN 0 ELSE @v3spositiontaking_20 END,

		@v5spositiontaking_1 = CASE WHEN @v5spositiontaking_1<0 THEN 0 ELSE @v5spositiontaking_1 END,
		@v5spositiontaking_2 = CASE WHEN @v5spositiontaking_2<0 THEN 0 ELSE @v5spositiontaking_2 END,
		@v5spositiontaking_3 = CASE WHEN @v5spositiontaking_3<0 THEN 0 ELSE @v5spositiontaking_3 END,
		@v5spositiontaking_20 = CASE WHEN @v5spositiontaking_20<0 THEN 0 ELSE @v5spositiontaking_20 END,
		@v5spositiontaking_9999 = CASE WHEN @v5spositiontaking_9999<0 THEN 0 ELSE @v5spositiontaking_9999 END,

		@v8spositiontaking_1 = CASE WHEN @v8spositiontaking_1<0 THEN 0 ELSE @v8spositiontaking_1 END,
		@v8spositiontaking_3 = CASE WHEN @v8spositiontaking_3<0 THEN 0 ELSE @v8spositiontaking_3 END,
		@v8spositiontaking_20 = CASE WHEN @v8spositiontaking_20<0 THEN 0 ELSE @v8spositiontaking_20 END,

		@v10spositiontaking_1 = CASE WHEN @v10spositiontaking_1<0 THEN 0 ELSE @v10spositiontaking_1 END,
		@v10spositiontaking_2 = CASE WHEN @v10spositiontaking_2<0 THEN 0 ELSE @v10spositiontaking_2 END,
		@v10spositiontaking_3 = CASE WHEN @v10spositiontaking_3<0 THEN 0 ELSE @v10spositiontaking_3 END,
		@v10spositiontaking_20 = CASE WHEN @v10spositiontaking_20<0 THEN 0 ELSE @v10spositiontaking_20 END,

		@v11spositiontaking_1 = CASE WHEN @v11spositiontaking_1<0 THEN 0 ELSE @v11spositiontaking_1 END,
		@v11spositiontaking_20 = CASE WHEN @v11spositiontaking_20<0 THEN 0 ELSE @v11spositiontaking_20 END,

		@v99spositiontaking_1 = CASE WHEN @v99spositiontaking_1<0 THEN 0 ELSE @v99spositiontaking_1 END,
		@v99spositiontaking_2 = CASE WHEN @v99spositiontaking_2<0 THEN 0 ELSE @v99spositiontaking_2 END,
		@v99spositiontaking_3 = CASE WHEN @v99spositiontaking_3<0 THEN 0 ELSE @v99spositiontaking_3 END,
		@v99spositiontaking_20 = CASE WHEN @v99spositiontaking_20<0 THEN 0 ELSE @v99spositiontaking_20 END,

		-- mixed sports
		@v99spositiontaking_9 = CASE WHEN @v99spositiontaking_9<0 THEN 0 ELSE @v99spositiontaking_9 END,

		-- HR Fixed Odds
		@v154spositiontaking_20 = CASE WHEN @v154spositiontaking_20 < 0 THEN 0 ELSE @v154spositiontaking_20 END,
		
		-- number game
		@v161spositiontaking_81 = CASE WHEN @v161spositiontaking_81<0 THEN 0 ELSE @v161spositiontaking_81 END,
		@v161spositiontaking_83 = CASE WHEN @v161spositiontaking_83<0 THEN 0 ELSE @v161spositiontaking_83 END,
		@v161spositiontaking_86 = CASE WHEN @v161spositiontaking_86<0 THEN 0 ELSE @v161spositiontaking_86 END,
		@v161spositiontaking_88 = CASE WHEN @v161spositiontaking_88<0 THEN 0 ELSE @v161spositiontaking_88 END,
		@v161slivepositiontaking_85 = CASE WHEN @v161slivepositiontaking_85<0 THEN 0 ELSE @v161slivepositiontaking_85 END,
		@v161slivepositiontaking_86 = CASE WHEN @v161slivepositiontaking_86<0 THEN 0 ELSE @v161slivepositiontaking_86 END,
		@v161slivepositiontaking_87 = CASE WHEN @v161slivepositiontaking_87<0 THEN 0 ELSE @v161slivepositiontaking_87 END,
		@v161slivepositiontaking_89 = CASE WHEN @v161slivepositiontaking_89<0 THEN 0 ELSE @v161slivepositiontaking_89 END,
		@v161slivepositiontaking_90 = CASE WHEN @v161slivepositiontaking_90<0 THEN 0 ELSE @v161slivepositiontaking_90 END

	--- 20131031@Johnson: Aplly execrep when update pt on member
		EXEC dbo.Acc_CustSetting_08
		@custid = @custid,
		@roleid = 4,
		
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
		@v99spositiontaking_10 = @v99spositiontaking_10
		
	
	-- number game
	IF (@UpdateMultiple=0 OR @UpdatePositiontakingv161=1)
	BEGIN
								EXEC dbo.Acc_CustSetting3rd_08
			@custid = @custid,
			@mode = 'number',
			@roleid = 4,
			
			@v161spositiontaking_81 = @v161spositiontaking_81,
			@v161spositiontaking_83 = @v161spositiontaking_83,
			@v161spositiontaking_86 = @v161spositiontaking_86,
			@v161spositiontaking_88 = @v161spositiontaking_88,
			@v161slivepositiontaking_85 = @v161slivepositiontaking_85,
			@v161slivepositiontaking_86 = @v161slivepositiontaking_86,
			@v161slivepositiontaking_87 = @v161slivepositiontaking_87,
			@v161slivepositiontaking_89 = @v161slivepositiontaking_89,
			@v161slivepositiontaking_90 = @v161slivepositiontaking_90
	END
	/*
	--don't update s1 for member under master was set i3=1(normal)
	UPDATE cs WITH (ROWLOCK, UPDLOCK)
	SET
		cs.spositiontaking = 
						CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND cs.bettype<>9 AND @UpdatePositiontakingv99 = 0) 
									OR (cs.sporttype=99 AND cs.bettype=9 AND @UpdatePositiontakingv99MP = 0)
									OR (cs.sporttype = 154 AND cs.bettype = 20 AND @UpdatePositiontakingv154 = 0) )) 
								THEN cs.spositiontaking 
						ELSE CASE cs.sporttype 	
								WHEN 1 THEN case cs.bettype WHEN 1 THEN @spositiontaking_1 WHEN 2 THEN @spositiontaking_2 WHEN 3 THEN @spositiontaking_3 WHEN 4 THEN @spositiontaking_4 WHEN 5 THEN @spositiontaking_5 WHEN 6 THEN @spositiontaking_6 WHEN 7 THEN @spositiontaking_7 WHEN 8 THEN @spositiontaking_8 WHEN 9 THEN @spositiontaking_9 WHEN 10 THEN @spositiontaking_10 ELSE 0 END
								WHEN 2 THEN case cs.bettype WHEN 1 THEN @v2spositiontaking_1 WHEN 2 THEN @v2spositiontaking_2 WHEN 3 THEN @v2spositiontaking_3 WHEN 7 THEN @v2spositiontaking_7 WHEN 8 THEN @v2spositiontaking_8  WHEN 20 THEN @v2spositiontaking_20  ELSE 0 END
								WHEN 3 THEN case cs.bettype WHEN 1 THEN @v3spositiontaking_1 WHEN 2 THEN @v3spositiontaking_2 WHEN 3 THEN @v3spositiontaking_3 WHEN 20 THEN @v3spositiontaking_20 ELSE 0 END
								WHEN 5 THEN case cs.bettype WHEN 1 THEN @v5spositiontaking_1 WHEN 2 THEN @v5spositiontaking_2 WHEN 3 THEN @v5spositiontaking_3 WHEN 20 THEN @v5spositiontaking_20 ELSE 0 END
								WHEN 8 THEN case cs.bettype WHEN 1 THEN @v8spositiontaking_1 WHEN 3 THEN @v8spositiontaking_3 WHEN 20 THEN @v8spositiontaking_20 ELSE 0 END
								WHEN 10 THEN case cs.bettype WHEN 1 THEN @v10spositiontaking_1 WHEN 2 THEN @v10spositiontaking_2 WHEN 3 THEN @v10spositiontaking_3 WHEN 20 THEN @v10spositiontaking_20 ELSE 0 END
								WHEN 11 THEN case cs.bettype WHEN 1 THEN @v11spositiontaking_1 WHEN 20 THEN @v11spositiontaking_20 ELSE 0 END
								WHEN 99 THEN case cs.bettype WHEN 1 THEN @v99spositiontaking_1 WHEN 2 THEN @v99spositiontaking_2 WHEN 3 THEN @v99spositiontaking_3 WHEN 9 THEN @v99spositiontaking_9 WHEN 20 THEN @v99spositiontaking_20 ELSE 0 END
								WHEN 154 THEN CASE cs.bettype WHEN 20 THEN @v154spositiontaking_20 ELSE 0 END
								ELSE cs.spositiontaking END
						END
	FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
		INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
	WHERE cs.custid=@custid and c.roleid = 1 and scs.isautopositiontaking = 0

	--don't update s1 for member under master was set i3=1(live)
	UPDATE cs with (ROWLOCK, UPDLOCK)
	SET
		cs.slivepositiontaking = 
							CASE WHEN (@UpdateMultiple = 1 
								AND ((cs.sporttype=1 AND @UpdatePositiontaking = 0) 
									OR (cs.sporttype=2 AND @UpdatePositiontakingv2 = 0)  
									OR (cs.sporttype=3 AND @UpdatePositiontakingv3 = 0) 
									OR (cs.sporttype=5 AND @UpdatePositiontakingv5 = 0) 
									OR (cs.sporttype=8 AND @UpdatePositiontakingv8 = 0) 
									OR (cs.sporttype=10 AND @UpdatePositiontakingv10 = 0) 
									OR (cs.sporttype=11 AND @UpdatePositiontakingv11 = 0) 
									OR (cs.sporttype=99 AND @UpdatePositiontakingv99 = 0))) 
								THEN cs.slivepositiontaking 		
							ELSE case cs.sporttype WHEN 1 THEN case cs.bettype 
																		WHEN 1 THEN @slivepositiontaking_1 
																		WHEN 3 THEN @slivepositiontaking_3 
																		WHEN 7 THEN @slivepositiontaking_7 
																		WHEN 8 THEN @slivepositiontaking_8 
																		ELSE cs.slivepositiontaking END 
														ELSE cs.slivepositiontaking END
							END
	FROM Custsetting cs INNER JOIN custinfo c (nolock) on cs.custid = c.custid
		INNER JOIN custsetting scs (nolock) on scs.custid = c.mrecommEND and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
	where cs.custid=@custid and c.roleid = 1 and scs.isautolivepositiontaking = 0

	-- number game
	IF (@UpdateMultiple=0 OR @UpdatePositiontakingv161=1)
	BEGIN
		UPDATE cs3 with(rowlock,updlock)
		SET cs3.spositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 81 THEN @v161spositiontaking_81 
																					WHEN 83 THEN @v161spositiontaking_83
																					WHEN 86 THEN @v161spositiontaking_86
																					WHEN 88 THEN @v161spositiontaking_88
																					ELSE 0 END
													ELSE cs3.spositiontaking END
		from custsetting3rd cs3 INNER JOIN custinfo c with(nolock) on cs3.custid = c.custid
			 INNER JOIN custsetting3rd mcs3 with(nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
		where cs3.custid =@custid and c.roleid = 1 and mcs3.isautopositiontaking = 0	
	
		UPDATE cs3 with (ROWLOCK, UPDLOCK)
		set
			cs3.slivepositiontaking = case cs3.sporttype WHEN 161 THEN case cs3.bettype WHEN 85 THEN @v161slivepositiontaking_85 
																						WHEN 86 THEN @v161slivepositiontaking_86 
																						WHEN 87 THEN @v161slivepositiontaking_87 
																						WHEN 89 THEN @v161slivepositiontaking_89
																						WHEN 90 THEN @v161slivepositiontaking_90
																						ELSE cs3.slivepositiontaking END 
														 ELSE cs3.slivepositiontaking END
		from custsetting3rd cs3 INNER JOIN custinfo c (nolock) on cs3.custid = c.custid
			INNER JOIN custsetting3rd mcs3 (nolock) on mcs3.custid = c.mrecommend and cs3.sporttype = mcs3.sporttype and cs3.bettype = mcs3.bettype
		where cs3.custid=@custid and c.roleid = 1 and mcs3.isautolivepositiontaking = 0
	END
	*/
	
	---apply execrep when update auto pt on member
		EXEC dbo.Acc_CustSetting_09
		@custid = @custid,
		@roleid = 4,
		
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
--			@auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
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
		
		@isauto_spositiontaking_1 = @isauto_spositiontaking_1,
		@isauto_spositiontaking_2 = @isauto_spositiontaking_2,
		@isauto_spositiontaking_3 = @isauto_spositiontaking_3,
		@isauto_spositiontaking_4 = @isauto_spositiontaking_4,
		@isauto_spositiontaking_5 = @isauto_spositiontaking_5,
		@isauto_spositiontaking_6 = @isauto_spositiontaking_6,
		@isauto_spositiontaking_7 = @isauto_spositiontaking_7,
		@isauto_spositiontaking_8 = @isauto_spositiontaking_8,
		@isauto_spositiontaking_9 = @isauto_spositiontaking_9,
		@isauto_spositiontaking_10 = @isauto_spositiontaking_10,
		@isauto_spositiontaking_9999 = @isauto_spositiontaking_9999,
		@isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1,
		@isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3,
		@isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7,
		@isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8,
		@isauto_v2spositiontaking_1 = @isauto_v2spositiontaking_1,
		@isauto_v2spositiontaking_2 = @isauto_v2spositiontaking_2,
		@isauto_v2spositiontaking_3 = @isauto_v2spositiontaking_3,
		@isauto_v2spositiontaking_7 = @isauto_v2spositiontaking_7,
		@isauto_v2spositiontaking_8 = @isauto_v2spositiontaking_8,
--			@isauto_v2spositiontaking_9 = @isauto_v2spositiontaking_9,
		@isauto_v2spositiontaking_20 = @isauto_v2spositiontaking_20,
		@isauto_v3spositiontaking_1 = @isauto_v3spositiontaking_1,
		@isauto_v3spositiontaking_2 = @isauto_v3spositiontaking_2,
		@isauto_v3spositiontaking_3 = @isauto_v3spositiontaking_3,
		@isauto_v3spositiontaking_20 = @isauto_v3spositiontaking_20,
		@isauto_v5spositiontaking_1 = @isauto_v5spositiontaking_1,
		@isauto_v5spositiontaking_2 = @isauto_v5spositiontaking_2,
		@isauto_v5spositiontaking_3 = @isauto_v5spositiontaking_3,
		@isauto_v5spositiontaking_20 = @isauto_v5spositiontaking_20,
		@isauto_v5spositiontaking_9999 = @isauto_v5spositiontaking_9999,
		@isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,
		@isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,
		@isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,		
		@isauto_v10spositiontaking_1 = @isauto_v10spositiontaking_1,
		@isauto_v10spositiontaking_2 = @isauto_v10spositiontaking_2,
		@isauto_v10spositiontaking_3 = @isauto_v10spositiontaking_3,
		@isauto_v10spositiontaking_20 = @isauto_v10spositiontaking_20,
		@isauto_v11spositiontaking_1 = @isauto_v11spositiontaking_1,
		@isauto_v11spositiontaking_20 = @isauto_v11spositiontaking_20,
		
		@isauto_v99spositiontaking_1 = @isauto_v99spositiontaking_1,
		@isauto_v99spositiontaking_2 = @isauto_v99spositiontaking_2,
		@isauto_v99spositiontaking_3 = @isauto_v99spositiontaking_3,
		@isauto_v99spositiontaking_20 = @isauto_v99spositiontaking_20,
		-- mixed sports
		@isauto_v99spositiontaking_9 = @isauto_v99spositiontaking_9,
		@isauto_v154spositiontaking_20 = @isauto_v154spositiontaking_20,
		
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
		@UpdatePositiontakingv154 = @UpdatePositiontakingv154
		
		
		
		EXEC dbo.Acc_CustSetting3rd_09
		@custid = @custid,
		@roleid = 4,
		@mode = 'number',
		
		@auto_v161spositiontaking_81 = @auto_v161spositiontaking_81,
		@auto_v161spositiontaking_83 = @auto_v161spositiontaking_83,
		@auto_v161spositiontaking_86 = @auto_v161spositiontaking_86,
		@auto_v161spositiontaking_88 = @auto_v161spositiontaking_88,
		@auto_v161slivepositiontaking_85 = @auto_v161slivepositiontaking_85,
		@auto_v161slivepositiontaking_86 = @auto_v161slivepositiontaking_86,
		@auto_v161slivepositiontaking_87 = @auto_v161slivepositiontaking_87,
		@auto_v161slivepositiontaking_89 = @auto_v161slivepositiontaking_89,
		@auto_v161slivepositiontaking_90 = @auto_v161slivepositiontaking_90,

		@isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,
		@isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,
		@isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
		@isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
		@isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
		@isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
		@isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
		@isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
		@isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,
		
		@UpdateMultiple = @UpdateMultiple,
		@UpdatePositiontakingv161 = @UpdatePositiontakingv161
	/*
	EXEC dbo.Acc_CustomerUpdMember_AutoPositiontaking 
				@custid = @custid,
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
				@auto_slivepositiontaking_1 = @auto_slivepositiontaking_1,
				@auto_slivepositiontaking_3 = @auto_slivepositiontaking_3,
				@auto_slivepositiontaking_7 = @auto_slivepositiontaking_7,
				@auto_slivepositiontaking_8 = @auto_slivepositiontaking_8,
				@auto_v2spositiontaking_1 = @auto_v2spositiontaking_1,
				@auto_v2spositiontaking_2 = @auto_v2spositiontaking_2,
				@auto_v2spositiontaking_3 = @auto_v2spositiontaking_3,
				@auto_v2spositiontaking_7 = @auto_v2spositiontaking_7,
				@auto_v2spositiontaking_8 = @auto_v2spositiontaking_8,
	--			@auto_v2spositiontaking_9 = @auto_v2spositiontaking_9,
				@auto_v2spositiontaking_20 = @auto_v2spositiontaking_20,
				@auto_v3spositiontaking_1 = @auto_v3spositiontaking_1,
				@auto_v3spositiontaking_2 = @auto_v3spositiontaking_2,
				@auto_v3spositiontaking_3 = @auto_v3spositiontaking_3,
				@auto_v3spositiontaking_20 = @auto_v3spositiontaking_20,
				@auto_v5spositiontaking_1 = @auto_v5spositiontaking_1,
				@auto_v5spositiontaking_2 = @auto_v5spositiontaking_2,
				@auto_v5spositiontaking_3 = @auto_v5spositiontaking_3,
				@auto_v5spositiontaking_20 = @auto_v5spositiontaking_20,
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
				-- HR Fixed Odds
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

				@isauto_spositiontaking_1 = @isauto_spositiontaking_1,
				@isauto_spositiontaking_2 = @isauto_spositiontaking_2,
				@isauto_spositiontaking_3 = @isauto_spositiontaking_3,
				@isauto_spositiontaking_4 = @isauto_spositiontaking_4,
				@isauto_spositiontaking_5 = @isauto_spositiontaking_5,
				@isauto_spositiontaking_6 = @isauto_spositiontaking_6,
				@isauto_spositiontaking_7 = @isauto_spositiontaking_7,
				@isauto_spositiontaking_8 = @isauto_spositiontaking_8,
				@isauto_spositiontaking_9 = @isauto_spositiontaking_9,
				@isauto_spositiontaking_10 = @isauto_spositiontaking_10,
				@isauto_slivepositiontaking_1 = @isauto_slivepositiontaking_1,
				@isauto_slivepositiontaking_3 = @isauto_slivepositiontaking_3,
				@isauto_slivepositiontaking_7 = @isauto_slivepositiontaking_7,
				@isauto_slivepositiontaking_8 = @isauto_slivepositiontaking_8,
				@isauto_v2spositiontaking_1 = @isauto_v2spositiontaking_1,
				@isauto_v2spositiontaking_2 = @isauto_v2spositiontaking_2,
				@isauto_v2spositiontaking_3 = @isauto_v2spositiontaking_3,
				@isauto_v2spositiontaking_7 = @isauto_v2spositiontaking_7,
				@isauto_v2spositiontaking_8 = @isauto_v2spositiontaking_8,
	--			@isauto_v2spositiontaking_9 = @isauto_v2spositiontaking_9,
				@isauto_v2spositiontaking_20 = @isauto_v2spositiontaking_20,
				@isauto_v3spositiontaking_1 = @isauto_v3spositiontaking_1,
				@isauto_v3spositiontaking_2 = @isauto_v3spositiontaking_2,
				@isauto_v3spositiontaking_3 = @isauto_v3spositiontaking_3,
				@isauto_v3spositiontaking_20 = @isauto_v3spositiontaking_20,
				@isauto_v5spositiontaking_1 = @isauto_v5spositiontaking_1,
				@isauto_v5spositiontaking_2 = @isauto_v5spositiontaking_2,
				@isauto_v5spositiontaking_3 = @isauto_v5spositiontaking_3,
				@isauto_v5spositiontaking_20 = @isauto_v5spositiontaking_20,
				@isauto_v8spositiontaking_1 = @isauto_v8spositiontaking_1,
				@isauto_v8spositiontaking_3 = @isauto_v8spositiontaking_3,
				@isauto_v8spositiontaking_20 = @isauto_v8spositiontaking_20,
				@isauto_v10spositiontaking_1 = @isauto_v10spositiontaking_1,
				@isauto_v10spositiontaking_2 = @isauto_v10spositiontaking_2,
				@isauto_v10spositiontaking_3 = @isauto_v10spositiontaking_3,
				@isauto_v10spositiontaking_20 = @isauto_v10spositiontaking_20,
				@isauto_v11spositiontaking_1 = @isauto_v11spositiontaking_1,
				@isauto_v11spositiontaking_20 = @isauto_v11spositiontaking_20,
				
				@isauto_v99spositiontaking_1 = @isauto_v99spositiontaking_1,
				@isauto_v99spositiontaking_2 = @isauto_v99spositiontaking_2,
				@isauto_v99spositiontaking_3 = @isauto_v99spositiontaking_3,
				@isauto_v99spositiontaking_20 = @isauto_v99spositiontaking_20,
				-- mixed sports
				@isauto_v99spositiontaking_9 = @isauto_v99spositiontaking_9,
				-- HR Fixed Odds
				@isauto_v154spositiontaking_20 = @isauto_v154spositiontaking_20,
				-- number game
				@isauto_v161spositiontaking_81 = @isauto_v161spositiontaking_81,
				@isauto_v161spositiontaking_83 = @isauto_v161spositiontaking_83,
				@isauto_v161spositiontaking_86 = @isauto_v161spositiontaking_86,
				@isauto_v161spositiontaking_88 = @isauto_v161spositiontaking_88,
				@isauto_v161slivepositiontaking_85 = @isauto_v161slivepositiontaking_85,
				@isauto_v161slivepositiontaking_86 = @isauto_v161slivepositiontaking_86,
				@isauto_v161slivepositiontaking_87 = @isauto_v161slivepositiontaking_87,
				@isauto_v161slivepositiontaking_89 = @isauto_v161slivepositiontaking_89,
				@isauto_v161slivepositiontaking_90 = @isauto_v161slivepositiontaking_90,

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
				@UpdatePositiontakingv161 = @UpdatePositiontakingv161,

				@language = @language,
				@userid = @userid
		*/
		
		--merge code sps correct pt into sps update pt
		--no need call these sps
		/* 
		EXEC dbo.Acc_CustSetting_00
			@custid = @custid, 
			@recommend = @recommend, 
			@mrecommend = @mrecommend, 
			@srecommend = @srecommend,
			@updautosuper = 0
			
		EXEC dbo.Acc_CustSetting3rd_00
			@custid = @custid, 
			@recommend = @recommend, 
			@mrecommend = @mrecommend, 
			@srecommend = @srecommend,
			@mode = 'number',
			@updautosuper = 0
		*/				
		
	/*
	EXEC dbo.Acc_CustomerUpdMember_MinMaxPositiontaking 
		@custid = @custid, 
		@recommEND = @recommEND, 
		@mrecommEND = @mrecommEND, 
		@srecommEND = @srecommEND,
		@updautosuper = 0
	*/
SELECT	
	@spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_1 ELSE @spositiontaking_1 END,
	@spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_2 ELSE @spositiontaking_2 END,
	@spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_3 ELSE @spositiontaking_3 END,
	@spositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_4 ELSE @spositiontaking_4 END,
	@spositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_5 ELSE @spositiontaking_5 END,
	@spositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_6 ELSE @spositiontaking_6 END,
	@spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_7 ELSE @spositiontaking_7 END,
	@spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_8 ELSE @spositiontaking_8 END,
	@spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_9 ELSE @spositiontaking_9 END,
	@spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_10 ELSE @spositiontaking_10 END,
	@spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @Old_spositiontaking_9999 ELSE @spositiontaking_9999 END,
	
	-- Outright PT for sports
	@v2spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2spositiontaking_10 ELSE @v2spositiontaking_10 END,
	@v3spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3spositiontaking_10 ELSE @v3spositiontaking_10 END,
	@v5spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5spositiontaking_10 ELSE @v5spositiontaking_10 END,
	@v8spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8spositiontaking_10 ELSE @v8spositiontaking_10 END,
	@v10spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10spositiontaking_10 ELSE @v10spositiontaking_10 END,
	@v11spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11spositiontaking_10 ELSE @v11spositiontaking_10 END,
	@v99spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99spositiontaking_10 ELSE @v99spositiontaking_10 END,
		
	@auto_spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_1 ELSE @auto_spositiontaking_1 END,
	@auto_spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_2 ELSE @auto_spositiontaking_2 END,
	@auto_spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_3 ELSE @auto_spositiontaking_3 END,
	@auto_spositiontaking_4 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_4 ELSE @auto_spositiontaking_4 END,
	@auto_spositiontaking_5 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_5 ELSE @auto_spositiontaking_5 END,
	@auto_spositiontaking_6 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_6 ELSE @auto_spositiontaking_6 END,
	@auto_spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_7 ELSE @auto_spositiontaking_7 END,
	@auto_spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_8 ELSE @auto_spositiontaking_8 END,
	@auto_spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_9 ELSE @auto_spositiontaking_9 END,
	@auto_spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_10 ELSE @auto_spositiontaking_10 END,
	@auto_spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_spositiontaking_9999 ELSE @auto_spositiontaking_9999 END,
	
	-- Outright PT for sports
	@auto_v2spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_10 ELSE @auto_v2spositiontaking_10 END,
	@auto_v3spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_auto_v3spositiontaking_10 ELSE @auto_v3spositiontaking_10 END,
	@auto_v5spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_auto_v5spositiontaking_10 ELSE @auto_v5spositiontaking_10 END,
	@auto_v8spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_10 ELSE @auto_v8spositiontaking_10 END,
	@auto_v10spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_auto_v10spositiontaking_10 ELSE @auto_v10spositiontaking_10 END,
	@auto_v11spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11spositiontaking_10 ELSE @auto_v11spositiontaking_10 END,
	@auto_v99spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_auto_v99spositiontaking_10 ELSE @auto_v99spositiontaking_10 END,
	
	--i1
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
	@isauto_spositiontaking_9999 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_spositiontaking_9999 ELSE @isauto_spositiontaking_9999 END,
		
	-- Outright PT for sports
	@isauto_v2spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_10 ELSE @isauto_v2spositiontaking_10 END,
	@isauto_v3spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3spositiontaking_10 ELSE @isauto_v3spositiontaking_10 END,
	@isauto_v5spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5spositiontaking_10 ELSE @isauto_v5spositiontaking_10 END,
	@isauto_v8spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8spositiontaking_10 ELSE @isauto_v8spositiontaking_10 END,
	@isauto_v10spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10spositiontaking_10 ELSE @isauto_v10spositiontaking_10 END,
	@isauto_v11spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11spositiontaking_10 ELSE @isauto_v11spositiontaking_10 END,
	@isauto_v99spositiontaking_10 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99spositiontaking_10 ELSE @isauto_v99spositiontaking_10 END,
	
		
	@slivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_slivepositiontaking_1 ELSE @slivepositiontaking_1 END,
	@slivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_slivepositiontaking_3 ELSE @slivepositiontaking_3 END,
	@slivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_slivepositiontaking_7 ELSE @slivepositiontaking_7 END,
	@slivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_slivepositiontaking_8 ELSE @slivepositiontaking_8 END,
	
	@auto_slivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_slivepositiontaking_1 ELSE @auto_slivepositiontaking_1 END,
	@auto_slivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_slivepositiontaking_3 ELSE @auto_slivepositiontaking_3 END,
	@auto_slivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_slivepositiontaking_7 ELSE @auto_slivepositiontaking_7 END,
	@auto_slivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_auto_slivepositiontaking_8 ELSE @auto_slivepositiontaking_8 END,
	
	@isauto_slivepositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_slivepositiontaking_1 ELSE @isauto_slivepositiontaking_1 END,
	@isauto_slivepositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_slivepositiontaking_3 ELSE @isauto_slivepositiontaking_3 END,
	@isauto_slivepositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_slivepositiontaking_7 ELSE @isauto_slivepositiontaking_7 END,
	@isauto_slivepositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_slivepositiontaking_8 ELSE @isauto_slivepositiontaking_8 END,
		
	@v2spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_1 ELSE @v2spositiontaking_1 END,
	@v2spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_2 ELSE @v2spositiontaking_2 END,
	@v2spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_3 ELSE @v2spositiontaking_3 END,
	@v2spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_7 ELSE @v2spositiontaking_7 END,
	@v2spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_8 ELSE @v2spositiontaking_8 END,	
	@v2spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_v2spositiontaking_20 ELSE @v2spositiontaking_20 END,
	
	@auto_v2spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_1 ELSE @auto_v2spositiontaking_1 END,
	@auto_v2spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_2 ELSE @auto_v2spositiontaking_2 END,
	@auto_v2spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_3 ELSE @auto_v2spositiontaking_3 END,
	@auto_v2spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_7 ELSE @auto_v2spositiontaking_7 END,
	@auto_v2spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_8 ELSE @auto_v2spositiontaking_8 END,
	@auto_v2spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_auto_v2spositiontaking_20 ELSE @auto_v2spositiontaking_20 END,
	
	@isauto_v2spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_1 ELSE @isauto_v2spositiontaking_1 END,
	@isauto_v2spositiontaking_2 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_2 ELSE @isauto_v2spositiontaking_2 END,
	@isauto_v2spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_3 ELSE @isauto_v2spositiontaking_3 END,
	@isauto_v2spositiontaking_7 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_7 ELSE @isauto_v2spositiontaking_7 END,
	@isauto_v2spositiontaking_8 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_8 ELSE @isauto_v2spositiontaking_8 END,
	@isauto_v2spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2spositiontaking_20 ELSE @isauto_v2spositiontaking_20 END,
		
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
	
	@v8spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8spositiontaking_1 ELSE @v8spositiontaking_1 END,
	@v8spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8spositiontaking_3 ELSE @v8spositiontaking_3 END,
	@v8spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_v8spositiontaking_20 ELSE @v8spositiontaking_20 END,
	
	@auto_v8spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_1 ELSE @auto_v8spositiontaking_1 END,
	@auto_v8spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_3 ELSE @auto_v8spositiontaking_3 END,
	@auto_v8spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_auto_v8spositiontaking_20 ELSE @auto_v8spositiontaking_20 END,
	
	@isauto_v8spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8spositiontaking_1 ELSE @isauto_v8spositiontaking_1 END,
	@isauto_v8spositiontaking_3 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8spositiontaking_3 ELSE @isauto_v8spositiontaking_3 END,
	@isauto_v8spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8spositiontaking_20 ELSE @isauto_v8spositiontaking_20 END,
	
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
	
	@v11spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11spositiontaking_1 ELSE @v11spositiontaking_1 END,
	@v11spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_v11spositiontaking_20 ELSE @v11spositiontaking_20 END,
	
	@auto_v11spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11spositiontaking_1 ELSE @auto_v11spositiontaking_1 END,
	@auto_v11spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_auto_v11spositiontaking_20 ELSE @auto_v11spositiontaking_20 END,
	
	@isauto_v11spositiontaking_1 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11spositiontaking_1 ELSE @isauto_v11spositiontaking_1 END,
	@isauto_v11spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11spositiontaking_20 ELSE @isauto_v11spositiontaking_20 END,
	
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
	
	-- mixed sports
	@v99spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_v99spositiontaking_9 ELSE @v99spositiontaking_9 END,
	@auto_v99spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_auto_v99spositiontaking_9 ELSE @auto_v99spositiontaking_9 END,
	@isauto_v99spositiontaking_9 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_isauto_v99spositiontaking_9 ELSE @isauto_v99spositiontaking_9 END,
	
	-- HR fixodds
	@v154spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_v154spositiontaking_20 ELSE @v154spositiontaking_20 END,
	@auto_v154spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_auto_v154spositiontaking_20 ELSE @auto_v154spositiontaking_20 END,
	@isauto_v154spositiontaking_20 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv154 = 0 THEN @old_isauto_v154spositiontaking_20 ELSE @isauto_v154spositiontaking_20 END,
	
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
	@isauto_v161slivepositiontaking_90 = CASE WHEN @UpdateMultiple= 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161slivepositiontaking_90 ELSE @isauto_v161slivepositiontaking_90 END
	
	SELECT @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)


	DECLARE @TrackingValue2 varchar(MAX)


	SELECT @LogSPData = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
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
	'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

	'<s spt_1="'+ coalesce(cast(@spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'spt_2="'+ coalesce(cast(@spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'spt_3="'+ coalesce(cast(@spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'spt_4="'+ coalesce(cast(@spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'spt_5="'+ coalesce(cast(@spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
	'spt_6="'+ coalesce(cast(@spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'spt_7="'+ coalesce(cast(@spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'spt_8="'+ coalesce(cast(@spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'spt_9="'+ coalesce(cast(@spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'spt_10="'+ coalesce(cast(@spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'v2spt_10="'+ coalesce(cast(@v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v3spt_10="'+ coalesce(cast(@v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v5spt_10="'+ coalesce(cast(@v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v8spt_10="'+ coalesce(cast(@v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v10spt_10="'+ coalesce(cast(@v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v11spt_10="'+ coalesce(cast(@v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v99spt_10="'+ coalesce(cast(@v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	'spt_9999="'+ coalesce(cast(@spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
	'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	'v5spt_9999="'+ coalesce(cast(@v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

	'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- HR Fixed Odds
	'v154spt_20="'+ coalesce(cast(@v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	--number game
	'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'a_v2spt_10="'+ coalesce(cast(@auto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_10="'+ coalesce(cast(@auto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_10="'+ coalesce(cast(@auto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_10="'+ coalesce(cast(@auto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_10="'+ coalesce(cast(@auto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v11spt_10="'+ coalesce(cast(@auto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_10="'+ coalesce(cast(@auto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	'a_spt_9999="'+ coalesce(cast(@auto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_9999="'+ coalesce(cast(@auto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

	'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
	-- mixed sports
	'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- HR Fixed Odds
	'a_v154spt_20="'+ coalesce(cast(@auto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	--i1
	'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'isa_v2spt_10="'+ coalesce(cast(@isauto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_10="'+ coalesce(cast(@isauto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_10="'+ coalesce(cast(@isauto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_10="'+ coalesce(cast(@isauto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_10="'+ coalesce(cast(@isauto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v11spt_10="'+ coalesce(cast(@isauto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_10="'+ coalesce(cast(@isauto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	'isa_spt_9999="'+ coalesce(cast(@isauto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'isa_v2spt_1="'+ coalesce(cast(@isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_2="'+ coalesce(cast(@isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_3="'+ coalesce(cast(@isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_7="'+ coalesce(cast(@isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_8="'+ coalesce(cast(@isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'isa_v2spt_9="'+ coalesce(cast(@isauto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_20="'+ coalesce(cast(@isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v3spt_1="'+ coalesce(cast(@isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_2="'+ coalesce(cast(@isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_3="'+ coalesce(cast(@isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_20="'+ coalesce(cast(@isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v5spt_1="'+ coalesce(cast(@isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_2="'+ coalesce(cast(@isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_3="'+ coalesce(cast(@isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_20="'+ coalesce(cast(@isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_9999="'+ coalesce(cast(@isauto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

	'isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v10spt_1="'+ coalesce(cast(@isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_2="'+ coalesce(cast(@isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'isa_v10spt_3="'+ coalesce(cast(@isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_20="'+ coalesce(cast(@isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v11spt_1="'+ coalesce(cast(@isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v11spt_20="'+ coalesce(cast(@isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v99spt_1="'+ coalesce(cast(@isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_2="'+ coalesce(cast(@isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_3="'+ coalesce(cast(@isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_20="'+ coalesce(cast(@isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'isa_v99spt_9="'+ coalesce(cast(@isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- HR Fixed Odds
	'isa_v154spt_20="'+ coalesce(cast(@isauto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'
	--i3
	/*'<isau isa_smpt_1="'+ coalesce(cast(@isauto_smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_2="'+ coalesce(cast(@isauto_smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_3="'+ coalesce(cast(@isauto_smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_4="'+ coalesce(cast(@isauto_smpositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_5="'+ coalesce(cast(@isauto_smpositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_6="'+ coalesce(cast(@isauto_smpositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_7="'+ coalesce(cast(@isauto_smpositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_8="'+ coalesce(cast(@isauto_smpositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_9="'+ coalesce(cast(@isauto_smpositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_smpt_10="'+ coalesce(cast(@isauto_smpositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_smlivept_1="'+ coalesce(cast(@isauto_smlivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_smlivept_3="'+ coalesce(cast(@isauto_smlivepositiontaking_3 AS varchar(50)),space(1))  + '" ' +
	'isa_smlivept_7="'+ coalesce(cast(@isauto_smlivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_smlivept_8="'+ coalesce(cast(@isauto_smlivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'isa_v2smpt_1="'+ coalesce(cast(@isauto_v2smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_2="'+ coalesce(cast(@isauto_v2smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_3="'+ coalesce(cast(@isauto_v2smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_7="'+ coalesce(cast(@isauto_v2smpositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_8="'+ coalesce(cast(@isauto_v2smpositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	--'isa_v2smpt_9="'+ coalesce(cast(@isauto_v2smpositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_v2smpt_20="'+ coalesce(cast(@isauto_v2smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v3smpt_1="'+ coalesce(cast(@isauto_v3smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v3smpt_2="'+ coalesce(cast(@isauto_v3smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v3smpt_3="'+ coalesce(cast(@isauto_v3smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v3smpt_20="'+ coalesce(cast(@isauto_v3smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v5smpt_1="'+ coalesce(cast(@isauto_v5smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v5smpt_2="'+ coalesce(cast(@isauto_v5smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v5smpt_3="'+ coalesce(cast(@isauto_v5smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v5smpt_20="'+ coalesce(cast(@isauto_v5smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v8smpt_1="'+ coalesce(cast(@isauto_v8smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v8smpt_3="'+ coalesce(cast(@isauto_v8smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v8smpt_20="'+ coalesce(cast(@isauto_v8smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v10smpt_1="'+ coalesce(cast(@isauto_v10smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v10smpt_2="'+ coalesce(cast(@isauto_v10smpositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'isa_v10smpt_3="'+ coalesce(cast(@isauto_v10smpositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v10smpt_20="'+ coalesce(cast(@isauto_v10smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v11smpt_1="'+ coalesce(cast(@isauto_v11smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v11smpt_20="'+ coalesce(cast(@isauto_v11smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v99smpt_1="'+ coalesce(cast(@isauto_v99smpositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v99smpt_2="'+ coalesce(cast(@isauto_v99smpositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v99smpt_3="'+ coalesce(cast(@isauto_v99smpositiontaking_3 AS varchar(50)),space(1))  + '" ' +
	'isa_v99smpt_20="'+ coalesce(cast(@isauto_v99smpositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	--mixed sports
	'isa_v99smpt_9="'+ coalesce(cast(@isauto_v99smpositiontaking_9 AS varchar(50)),space(1))  + '" ' +
	-- number game
	'isa_v161smpt_81="'+ coalesce(cast(@isauto_v161smpositiontaking_81 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smpt_83="'+ coalesce(cast(@isauto_v161smpositiontaking_83 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smpt_85="'+ coalesce(cast(@isauto_v161smpositiontaking_85 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smpt_86="'+ coalesce(cast(@isauto_v161smpositiontaking_86 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smlivept_85="'+ coalesce(cast(@isauto_v161smlivepositiontaking_85 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smlivept_86="'+ coalesce(cast(@isauto_v161smlivepositiontaking_86 AS varchar(50)),space(1))  + '" ' +
	'isa_v161smlivept_87="'+ coalesce(cast(@isauto_v161smlivepositiontaking_87 AS varchar(50)),space(1))  + '" /></Acc_CustomerUpdMember_Super>'*/
		
		
	SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
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
	'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

	'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
	'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'v2spt_10="'+ coalesce(cast(@Old_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v3spt_10="'+ coalesce(cast(@Old_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v5spt_10="'+ coalesce(cast(@Old_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v8spt_10="'+ coalesce(cast(@Old_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v10spt_10="'+ coalesce(cast(@Old_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v11spt_10="'+ coalesce(cast(@Old_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'v99spt_10="'+ coalesce(cast(@Old_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	'spt_9999="'+ coalesce(cast(@Old_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
	'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'v2spt_1="'+ coalesce(cast(@Old_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v2spt_2="'+ coalesce(cast(@Old_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v2spt_3="'+ coalesce(cast(@Old_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v2spt_7="'+ coalesce(cast(@Old_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'v2spt_8="'+ coalesce(cast(@Old_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'v2spt_20="'+ coalesce(cast(@Old_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v3spt_1="'+ coalesce(cast(@Old_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v3spt_2="'+ coalesce(cast(@Old_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v3spt_3="'+ coalesce(cast(@Old_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v3spt_20="'+ coalesce(cast(@Old_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v5spt_1="'+ coalesce(cast(@Old_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v5spt_2="'+ coalesce(cast(@Old_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v5spt_3="'+ coalesce(cast(@Old_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v5spt_20="'+ coalesce(cast(@Old_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	'v5spt_9999="'+ coalesce(cast(@Old_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

	'v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v10spt_1="'+ coalesce(cast(@Old_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v10spt_2="'+ coalesce(cast(@Old_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v10spt_3="'+ coalesce(cast(@Old_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v10spt_20="'+ coalesce(cast(@Old_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v11spt_1="'+ coalesce(cast(@Old_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v11spt_20="'+ coalesce(cast(@Old_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'v99spt_1="'+ coalesce(cast(@Old_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'v99spt_2="'+ coalesce(cast(@Old_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'v99spt_3="'+ coalesce(cast(@Old_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'v99spt_20="'+ coalesce(cast(@Old_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'v99spt_9="'+ coalesce(cast(@Old_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- HR Fixed Odds
	'v154spt_20="'+ coalesce(cast(@old_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	--number game
	'v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'a_v2spt_10="'+ coalesce(cast(@Old_auto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_10="'+ coalesce(cast(@Old_auto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_10="'+ coalesce(cast(@Old_auto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_10="'+ coalesce(cast(@Old_auto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_10="'+ coalesce(cast(@Old_auto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v11spt_10="'+ coalesce(cast(@Old_auto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_10="'+ coalesce(cast(@Old_auto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	'a_spt_9999="'+ coalesce(cast(@Old_auto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'a_v2spt_1="'+ coalesce(cast(@Old_auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_2="'+ coalesce(cast(@Old_auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_3="'+ coalesce(cast(@Old_auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_7="'+ coalesce(cast(@Old_auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_8="'+ coalesce(cast(@Old_auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'a_v2spt_20="'+ coalesce(cast(@Old_auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v3spt_1="'+ coalesce(cast(@Old_auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_2="'+ coalesce(cast(@Old_auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'a_v3spt_3="'+ coalesce(cast(@Old_auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v3spt_20="'+ coalesce(cast(@Old_auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v5spt_1="'+ coalesce(cast(@Old_auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_2="'+ coalesce(cast(@Old_auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_3="'+ coalesce(cast(@Old_auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_20="'+ coalesce(cast(@Old_auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	'a_v5spt_9999="'+ coalesce(cast(@Old_auto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

	'a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v10spt_1="'+ coalesce(cast(@Old_auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_2="'+ coalesce(cast(@Old_auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_3="'+ coalesce(cast(@Old_auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v10spt_20="'+ coalesce(cast(@Old_auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v11spt_1="'+ coalesce(cast(@Old_auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v11spt_20="'+ coalesce(cast(@Old_auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'a_v99spt_1="'+ coalesce(cast(@Old_auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_2="'+ coalesce(cast(@Old_auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_3="'+ coalesce(cast(@Old_auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'a_v99spt_20="'+ coalesce(cast(@Old_auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
	-- mixed sports
	'a_v99spt_9="'+ coalesce(cast(@Old_auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- HR Fixed Odds
	'a_v154spt_20="'+ coalesce(cast(@old_auto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

	--i1
	'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'isa_v2spt_10="'+ coalesce(cast(@Old_isauto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_10="'+ coalesce(cast(@Old_isauto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_10="'+ coalesce(cast(@Old_isauto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_10="'+ coalesce(cast(@Old_isauto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_10="'+ coalesce(cast(@Old_isauto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v11spt_10="'+ coalesce(cast(@Old_isauto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_10="'+ coalesce(cast(@Old_isauto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
	
	'isa_spt_9999="'+ coalesce(cast(@Old_isauto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

	'isa_v2spt_1="'+ coalesce(cast(@Old_isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_2="'+ coalesce(cast(@Old_isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_3="'+ coalesce(cast(@Old_isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_7="'+ coalesce(cast(@Old_isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_8="'+ coalesce(cast(@Old_isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
	'isa_v2spt_20="'+ coalesce(cast(@Old_isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v3spt_1="'+ coalesce(cast(@Old_isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_2="'+ coalesce(cast(@Old_isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_3="'+ coalesce(cast(@Old_isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v3spt_20="'+ coalesce(cast(@Old_isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v5spt_1="'+ coalesce(cast(@Old_isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_2="'+ coalesce(cast(@Old_isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_3="'+ coalesce(cast(@Old_isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_20="'+ coalesce(cast(@Old_isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	'isa_v5spt_9999="'+ coalesce(cast(@Old_isauto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

	'isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v10spt_1="'+ coalesce(cast(@Old_isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_2="'+ coalesce(cast(@Old_isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
	'isa_v10spt_3="'+ coalesce(cast(@Old_isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v10spt_20="'+ coalesce(cast(@Old_isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v11spt_1="'+ coalesce(cast(@Old_isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v11spt_20="'+ coalesce(cast(@Old_isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

	'isa_v99spt_1="'+ coalesce(cast(@Old_isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_2="'+ coalesce(cast(@Old_isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_3="'+ coalesce(cast(@Old_isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
	'isa_v99spt_20="'+ coalesce(cast(@Old_isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'isa_v99spt_9="'+ coalesce(cast(@Old_isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
	-- HR Fixed Odds
	'isa_v154spt_20="'+ coalesce(cast(@old_isauto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
	-- number game
	'isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
	'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'

	SET @ENDRun = getdate()
	SET @duration  = datediff (millisecond,@startRun,@ENDRun)

	BEGIN TRY
		--Log positiontaking
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 404,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH			
		SELECT @LogSPData = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
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
		'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

		'<s spt_1="'+ coalesce(cast(@spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'spt_2="'+ coalesce(cast(@spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'spt_3="'+ coalesce(cast(@spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'spt_4="'+ coalesce(cast(@spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'spt_5="'+ coalesce(cast(@spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
		'spt_6="'+ coalesce(cast(@spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'spt_7="'+ coalesce(cast(@spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'spt_8="'+ coalesce(cast(@spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'spt_9="'+ coalesce(cast(@spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'spt_10="'+ coalesce(cast(@spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for sports
		'v2spt_10="'+ coalesce(cast(@v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v3spt_10="'+ coalesce(cast(@v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v5spt_10="'+ coalesce(cast(@v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v8spt_10="'+ coalesce(cast(@v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v10spt_10="'+ coalesce(cast(@v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v11spt_10="'+ coalesce(cast(@v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v99spt_10="'+ coalesce(cast(@v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		'spt_9999="'+ coalesce(cast(@spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
		'slivept_1="'+ coalesce(cast(@slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'slivept_3="'+ coalesce(cast(@slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'slivept_7="'+ coalesce(cast(@slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'slivept_8="'+ coalesce(cast(@slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'v2spt_1="'+ coalesce(cast(@v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v2spt_2="'+ coalesce(cast(@v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v2spt_3="'+ coalesce(cast(@v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v2spt_7="'+ coalesce(cast(@v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'v2spt_8="'+ coalesce(cast(@v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		--'v2spt_9="'+ coalesce(cast(@v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'v2spt_20="'+ coalesce(cast(@v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v3spt_1="'+ coalesce(cast(@v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v3spt_2="'+ coalesce(cast(@v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v3spt_3="'+ coalesce(cast(@v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v3spt_20="'+ coalesce(cast(@v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v5spt_1="'+ coalesce(cast(@v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v5spt_2="'+ coalesce(cast(@v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v5spt_3="'+ coalesce(cast(@v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v5spt_20="'+ coalesce(cast(@v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		'v5spt_9999="'+ coalesce(cast(@v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

		'v8spt_1="'+ coalesce(cast(@v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v8spt_3="'+ coalesce(cast(@v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v8spt_20="'+ coalesce(cast(@v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v10spt_1="'+ coalesce(cast(@v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v10spt_2="'+ coalesce(cast(@v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v10spt_3="'+ coalesce(cast(@v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v10spt_20="'+ coalesce(cast(@v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v11spt_1="'+ coalesce(cast(@v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v11spt_20="'+ coalesce(cast(@v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v99spt_1="'+ coalesce(cast(@v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v99spt_2="'+ coalesce(cast(@v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v99spt_3="'+ coalesce(cast(@v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v99spt_20="'+ coalesce(cast(@v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'v99spt_9="'+ coalesce(cast(@v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		--HR Fixed Odds
		'v154spt_20="'+ coalesce(cast(@v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +		
		--number game
		'v161spt_81="'+ coalesce(cast(@v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'v161spt_83="'+ coalesce(cast(@v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'v161spt_86="'+ coalesce(cast(@v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161spt_88="'+ coalesce(cast(@v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_85="'+ coalesce(cast(@v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_86="'+ coalesce(cast(@v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_87="'+ coalesce(cast(@v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_89="'+ coalesce(cast(@v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_90="'+ coalesce(cast(@v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		'<au a_spt_1="'+ coalesce(cast(@auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_spt_2="'+ coalesce(cast(@auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_spt_3="'+ coalesce(cast(@auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_spt_4="'+ coalesce(cast(@auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'a_spt_5="'+ coalesce(cast(@auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'a_spt_6="'+ coalesce(cast(@auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'a_spt_7="'+ coalesce(cast(@auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_spt_8="'+ coalesce(cast(@auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'a_spt_9="'+ coalesce(cast(@auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'a_spt_10="'+ coalesce(cast(@auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for sports
		'a_v2spt_10="'+ coalesce(cast(@auto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_10="'+ coalesce(cast(@auto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_10="'+ coalesce(cast(@auto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_10="'+ coalesce(cast(@auto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_10="'+ coalesce(cast(@auto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v11spt_10="'+ coalesce(cast(@auto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_10="'+ coalesce(cast(@auto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		'a_spt_9999="'+ coalesce(cast(@auto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_1="'+ coalesce(cast(@auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_3="'+ coalesce(cast(@auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_7="'+ coalesce(cast(@auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_8="'+ coalesce(cast(@auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'a_v2spt_1="'+ coalesce(cast(@auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_2="'+ coalesce(cast(@auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_3="'+ coalesce(cast(@auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_7="'+ coalesce(cast(@auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_8="'+ coalesce(cast(@auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		--'a_v2spt_9="'+ coalesce(cast(@auto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_20="'+ coalesce(cast(@auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v3spt_1="'+ coalesce(cast(@auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_2="'+ coalesce(cast(@auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'a_v3spt_3="'+ coalesce(cast(@auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_20="'+ coalesce(cast(@auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v5spt_1="'+ coalesce(cast(@auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_2="'+ coalesce(cast(@auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_3="'+ coalesce(cast(@auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_20="'+ coalesce(cast(@auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_9999="'+ coalesce(cast(@auto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

		'a_v8spt_1="'+ coalesce(cast(@auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_3="'+ coalesce(cast(@auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_20="'+ coalesce(cast(@auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v10spt_1="'+ coalesce(cast(@auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_2="'+ coalesce(cast(@auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_3="'+ coalesce(cast(@auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_20="'+ coalesce(cast(@auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v11spt_1="'+ coalesce(cast(@auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v11spt_20="'+ coalesce(cast(@auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v99spt_1="'+ coalesce(cast(@auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_2="'+ coalesce(cast(@auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_3="'+ coalesce(cast(@auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_20="'+ coalesce(cast(@auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
		-- mixed sports
		'a_v99spt_9="'+ coalesce(cast(@auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- HR Fixed Odds
		'a_v154spt_20="'+ coalesce(cast(@auto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'a_v161spt_81="'+ coalesce(cast(@auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_83="'+ coalesce(cast(@auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_86="'+ coalesce(cast(@auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_88="'+ coalesce(cast(@auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_85="'+ coalesce(cast(@auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_86="'+ coalesce(cast(@auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_87="'+ coalesce(cast(@auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_89="'+ coalesce(cast(@auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_90="'+ coalesce(cast(@auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		--i1
		'<ia isa_spt_1="'+ coalesce(cast(@isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_2="'+ coalesce(cast(@isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_3="'+ coalesce(cast(@isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_4="'+ coalesce(cast(@isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_5="'+ coalesce(cast(@isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_6="'+ coalesce(cast(@isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_7="'+ coalesce(cast(@isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_8="'+ coalesce(cast(@isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_9="'+ coalesce(cast(@isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_10="'+ coalesce(cast(@isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		-- Outright PT for sports
		'isa_v2spt_10="'+ coalesce(cast(@isauto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_10="'+ coalesce(cast(@isauto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_10="'+ coalesce(cast(@isauto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_10="'+ coalesce(cast(@isauto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_10="'+ coalesce(cast(@isauto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v11spt_10="'+ coalesce(cast(@isauto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_10="'+ coalesce(cast(@isauto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		'isa_spt_9999="'+ coalesce(cast(@isauto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_1="'+ coalesce(cast(@isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_3="'+ coalesce(cast(@isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_7="'+ coalesce(cast(@isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_8="'+ coalesce(cast(@isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'isa_v2spt_1="'+ coalesce(cast(@isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_2="'+ coalesce(cast(@isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_3="'+ coalesce(cast(@isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_7="'+ coalesce(cast(@isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_8="'+ coalesce(cast(@isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		--'isa_v2spt_9="'+ coalesce(cast(@isauto_v2spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_20="'+ coalesce(cast(@isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v3spt_1="'+ coalesce(cast(@isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_2="'+ coalesce(cast(@isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_3="'+ coalesce(cast(@isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_20="'+ coalesce(cast(@isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v5spt_1="'+ coalesce(cast(@isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_2="'+ coalesce(cast(@isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_3="'+ coalesce(cast(@isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_20="'+ coalesce(cast(@isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_9999="'+ coalesce(cast(@isauto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

		'isa_v8spt_1="'+ coalesce(cast(@isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_3="'+ coalesce(cast(@isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_20="'+ coalesce(cast(@isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v10spt_1="'+ coalesce(cast(@isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_2="'+ coalesce(cast(@isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'isa_v10spt_3="'+ coalesce(cast(@isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_20="'+ coalesce(cast(@isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v11spt_1="'+ coalesce(cast(@isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v11spt_20="'+ coalesce(cast(@isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v99spt_1="'+ coalesce(cast(@isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_2="'+ coalesce(cast(@isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_3="'+ coalesce(cast(@isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_20="'+ coalesce(cast(@isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'isa_v99spt_9="'+ coalesce(cast(@isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- HR Fixed Odds
		'isa_v154spt_20="'+ coalesce(cast(@isauto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'isa_v161spt_81="'+ coalesce(cast(@isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_83="'+ coalesce(cast(@isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_86="'+ coalesce(cast(@isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_88="'+ coalesce(cast(@isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_85="'+ coalesce(cast(@isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_86="'+ coalesce(cast(@isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_87="'+ coalesce(cast(@isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_89="'+ coalesce(cast(@isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_90="'+ coalesce(cast(@isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'
					
		SELECT @TrackingValue2 = '<Acc_CustomerUpdMember_Super><info Language="'+ coalesce(cast(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS varchar(30)),SPACE(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1)) + '" ' +
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
		'UpdatePositiontakingv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(1)),space(1)) + '" ' +
		'UpdatePositiontakingv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(1)),space(1)) + '" />' +

		'<s spt_1="'+ coalesce(cast(@Old_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'spt_2="'+ coalesce(cast(@Old_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'spt_3="'+ coalesce(cast(@Old_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'spt_4="'+ coalesce(cast(@Old_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'spt_5="'+ coalesce(cast(@Old_spositiontaking_5 AS varchar(50)),space(1))  + '" ' +
		'spt_6="'+ coalesce(cast(@Old_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'spt_7="'+ coalesce(cast(@Old_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'spt_8="'+ coalesce(cast(@Old_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'spt_9="'+ coalesce(cast(@Old_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'spt_10="'+ coalesce(cast(@Old_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for sports
		'v2spt_10="'+ coalesce(cast(@Old_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v3spt_10="'+ coalesce(cast(@Old_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v5spt_10="'+ coalesce(cast(@Old_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v8spt_10="'+ coalesce(cast(@Old_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v10spt_10="'+ coalesce(cast(@Old_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v11spt_10="'+ coalesce(cast(@Old_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'v99spt_10="'+ coalesce(cast(@Old_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		'spt_9999="'+ coalesce(cast(@Old_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
		'slivept_1="'+ coalesce(cast(@Old_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'slivept_3="'+ coalesce(cast(@Old_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'slivept_7="'+ coalesce(cast(@Old_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'slivept_8="'+ coalesce(cast(@Old_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'v2spt_1="'+ coalesce(cast(@Old_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v2spt_2="'+ coalesce(cast(@Old_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v2spt_3="'+ coalesce(cast(@Old_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v2spt_7="'+ coalesce(cast(@Old_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'v2spt_8="'+ coalesce(cast(@Old_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'v2spt_20="'+ coalesce(cast(@Old_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v3spt_1="'+ coalesce(cast(@Old_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v3spt_2="'+ coalesce(cast(@Old_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v3spt_3="'+ coalesce(cast(@Old_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v3spt_20="'+ coalesce(cast(@Old_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v5spt_1="'+ coalesce(cast(@Old_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v5spt_2="'+ coalesce(cast(@Old_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v5spt_3="'+ coalesce(cast(@Old_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v5spt_20="'+ coalesce(cast(@Old_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		'v5spt_9999="'+ coalesce(cast(@Old_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

		'v8spt_1="'+ coalesce(cast(@Old_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v8spt_3="'+ coalesce(cast(@Old_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v8spt_20="'+ coalesce(cast(@Old_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v10spt_1="'+ coalesce(cast(@Old_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v10spt_2="'+ coalesce(cast(@Old_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v10spt_3="'+ coalesce(cast(@Old_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v10spt_20="'+ coalesce(cast(@Old_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v11spt_1="'+ coalesce(cast(@Old_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v11spt_20="'+ coalesce(cast(@Old_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'v99spt_1="'+ coalesce(cast(@Old_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'v99spt_2="'+ coalesce(cast(@Old_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'v99spt_3="'+ coalesce(cast(@Old_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'v99spt_20="'+ coalesce(cast(@Old_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'v99spt_9="'+ coalesce(cast(@Old_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- HR Fixed Odds
		'v154spt_20="'+ coalesce(cast(@old_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		--number game
		'v161spt_81="'+ coalesce(cast(@Old_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'v161spt_83="'+ coalesce(cast(@Old_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'v161spt_86="'+ coalesce(cast(@Old_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161spt_88="'+ coalesce(cast(@Old_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_85="'+ coalesce(cast(@Old_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_86="'+ coalesce(cast(@Old_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_87="'+ coalesce(cast(@Old_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_89="'+ coalesce(cast(@Old_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'v161slivept_90="'+ coalesce(cast(@Old_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		'<au a_spt_1="'+ coalesce(cast(@Old_auto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_spt_2="'+ coalesce(cast(@Old_auto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_spt_3="'+ coalesce(cast(@Old_auto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_spt_4="'+ coalesce(cast(@Old_auto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'a_spt_5="'+ coalesce(cast(@Old_auto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'a_spt_6="'+ coalesce(cast(@Old_auto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'a_spt_7="'+ coalesce(cast(@Old_auto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_spt_8="'+ coalesce(cast(@Old_auto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'a_spt_9="'+ coalesce(cast(@Old_auto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'a_spt_10="'+ coalesce(cast(@Old_auto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for sports
		'a_v2spt_10="'+ coalesce(cast(@Old_auto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_10="'+ coalesce(cast(@Old_auto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_10="'+ coalesce(cast(@Old_auto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_10="'+ coalesce(cast(@Old_auto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_10="'+ coalesce(cast(@Old_auto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v11spt_10="'+ coalesce(cast(@Old_auto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_10="'+ coalesce(cast(@Old_auto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		'a_spt_9999="'+ coalesce(cast(@Old_auto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_1="'+ coalesce(cast(@Old_auto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_3="'+ coalesce(cast(@Old_auto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_7="'+ coalesce(cast(@Old_auto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_slivept_8="'+ coalesce(cast(@Old_auto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'a_v2spt_1="'+ coalesce(cast(@Old_auto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_2="'+ coalesce(cast(@Old_auto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_3="'+ coalesce(cast(@Old_auto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_7="'+ coalesce(cast(@Old_auto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_8="'+ coalesce(cast(@Old_auto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'a_v2spt_20="'+ coalesce(cast(@Old_auto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v3spt_1="'+ coalesce(cast(@Old_auto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_2="'+ coalesce(cast(@Old_auto_v3spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'a_v3spt_3="'+ coalesce(cast(@Old_auto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v3spt_20="'+ coalesce(cast(@Old_auto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v5spt_1="'+ coalesce(cast(@Old_auto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_2="'+ coalesce(cast(@Old_auto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_3="'+ coalesce(cast(@Old_auto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_20="'+ coalesce(cast(@Old_auto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		'a_v5spt_9999="'+ coalesce(cast(@Old_auto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

		'a_v8spt_1="'+ coalesce(cast(@Old_auto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_3="'+ coalesce(cast(@Old_auto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v8spt_20="'+ coalesce(cast(@Old_auto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v10spt_1="'+ coalesce(cast(@Old_auto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_2="'+ coalesce(cast(@Old_auto_v10spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_3="'+ coalesce(cast(@Old_auto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v10spt_20="'+ coalesce(cast(@Old_auto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v11spt_1="'+ coalesce(cast(@Old_auto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v11spt_20="'+ coalesce(cast(@Old_auto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'a_v99spt_1="'+ coalesce(cast(@Old_auto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_2="'+ coalesce(cast(@Old_auto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_3="'+ coalesce(cast(@Old_auto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'a_v99spt_20="'+ coalesce(cast(@Old_auto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' + 
		-- mixed sports
		'a_v99spt_9="'+ coalesce(cast(@Old_auto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- HR Fixed Odds
		'a_v154spt_20="'+ coalesce(cast(@old_auto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'a_v161spt_81="'+ coalesce(cast(@Old_auto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_83="'+ coalesce(cast(@Old_auto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_86="'+ coalesce(cast(@Old_auto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161spt_88="'+ coalesce(cast(@Old_auto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_85="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_86="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_87="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_89="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'a_v161slivept_90="'+ coalesce(cast(@Old_auto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" />' +

		--i1
		'<ia isa_spt_1="'+ coalesce(cast(@Old_isauto_spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_2="'+ coalesce(cast(@Old_isauto_spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_3="'+ coalesce(cast(@Old_isauto_spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_4="'+ coalesce(cast(@Old_isauto_spositiontaking_4 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_5="'+ coalesce(cast(@Old_isauto_spositiontaking_5 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_6="'+ coalesce(cast(@Old_isauto_spositiontaking_6 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_7="'+ coalesce(cast(@Old_isauto_spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_8="'+ coalesce(cast(@Old_isauto_spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_9="'+ coalesce(cast(@Old_isauto_spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		'isa_spt_10="'+ coalesce(cast(@Old_isauto_spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		-- Outright PT for sports
		'isa_v2spt_10="'+ coalesce(cast(@Old_isauto_v2spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_10="'+ coalesce(cast(@Old_isauto_v3spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_10="'+ coalesce(cast(@Old_isauto_v5spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_10="'+ coalesce(cast(@Old_isauto_v8spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_10="'+ coalesce(cast(@Old_isauto_v10spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v11spt_10="'+ coalesce(cast(@Old_isauto_v11spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_10="'+ coalesce(cast(@Old_isauto_v99spositiontaking_10 AS varchar(50)),space(1)) + '" ' +
		
		'isa_spt_9999="'+ coalesce(cast(@Old_isauto_spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_1="'+ coalesce(cast(@Old_isauto_slivepositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_3="'+ coalesce(cast(@Old_isauto_slivepositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_7="'+ coalesce(cast(@Old_isauto_slivepositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_slivept_8="'+ coalesce(cast(@Old_isauto_slivepositiontaking_8 AS varchar(50)),space(1)) + '" ' +

		'isa_v2spt_1="'+ coalesce(cast(@Old_isauto_v2spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_2="'+ coalesce(cast(@Old_isauto_v2spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_3="'+ coalesce(cast(@Old_isauto_v2spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_7="'+ coalesce(cast(@Old_isauto_v2spositiontaking_7 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_8="'+ coalesce(cast(@Old_isauto_v2spositiontaking_8 AS varchar(50)),space(1)) + '" ' +
		'isa_v2spt_20="'+ coalesce(cast(@Old_isauto_v2spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v3spt_1="'+ coalesce(cast(@Old_isauto_v3spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_2="'+ coalesce(cast(@Old_isauto_v3spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_3="'+ coalesce(cast(@Old_isauto_v3spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v3spt_20="'+ coalesce(cast(@Old_isauto_v3spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v5spt_1="'+ coalesce(cast(@Old_isauto_v5spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_2="'+ coalesce(cast(@Old_isauto_v5spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_3="'+ coalesce(cast(@Old_isauto_v5spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_20="'+ coalesce(cast(@Old_isauto_v5spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		'isa_v5spt_9999="'+ coalesce(cast(@Old_isauto_v5spositiontaking_9999 AS varchar(50)),space(1)) + '" ' +

		'isa_v8spt_1="'+ coalesce(cast(@Old_isauto_v8spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_3="'+ coalesce(cast(@Old_isauto_v8spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v8spt_20="'+ coalesce(cast(@Old_isauto_v8spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v10spt_1="'+ coalesce(cast(@Old_isauto_v10spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_2="'+ coalesce(cast(@Old_isauto_v10spositiontaking_2 AS varchar(50)),space(1))  + '" ' +
		'isa_v10spt_3="'+ coalesce(cast(@Old_isauto_v10spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v10spt_20="'+ coalesce(cast(@Old_isauto_v10spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v11spt_1="'+ coalesce(cast(@Old_isauto_v11spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v11spt_20="'+ coalesce(cast(@Old_isauto_v11spositiontaking_20 AS varchar(50)),space(1)) + '" ' +

		'isa_v99spt_1="'+ coalesce(cast(@Old_isauto_v99spositiontaking_1 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_2="'+ coalesce(cast(@Old_isauto_v99spositiontaking_2 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_3="'+ coalesce(cast(@Old_isauto_v99spositiontaking_3 AS varchar(50)),space(1)) + '" ' +
		'isa_v99spt_20="'+ coalesce(cast(@Old_isauto_v99spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- mixed sports
		'isa_v99spt_9="'+ coalesce(cast(@Old_isauto_v99spositiontaking_9 AS varchar(50)),space(1)) + '" ' +
		-- HR fixed odds
		'isa_v154spt_20="'+ coalesce(cast(@old_isauto_v154spositiontaking_20 AS varchar(50)),space(1)) + '" ' +
		-- number game
		'isa_v161spt_81="'+ coalesce(cast(@Old_isauto_v161spositiontaking_81 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_83="'+ coalesce(cast(@Old_isauto_v161spositiontaking_83 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_86="'+ coalesce(cast(@Old_isauto_v161spositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161spt_88="'+ coalesce(cast(@Old_isauto_v161spositiontaking_88 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_85="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_85 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_86="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_86 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_87="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_87 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_89="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_89 AS varchar(50)),space(1)) + '" ' +
		'isa_v161slivept_90="'+ coalesce(cast(@Old_isauto_v161slivepositiontaking_90 AS varchar(50)),space(1)) + '" /></Acc_CustomerUpdMember_Super>'

		--Log positiontaking
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 404,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration	
	END CATCH		
END--Update Position Taking



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_Super] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_Super] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_Super] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_Super] TO [vnteam] AS [dbo]