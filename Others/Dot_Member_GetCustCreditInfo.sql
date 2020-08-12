/*<info serverAlias="DBCUST-CustDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Dot_Member_GetCustCreditInfo]
	@custid int,
	@sporttype smallint,
	@PartnerID smallint=null,
	@bettype smallint= 0,
	@liveindicator bit =0,
	@isLicensee bit = 0,
	@sporttype_vrate smallint= 0,
	@bettype_vrate smallint= 0,
	@SportTypeRefBetSetting int=0,
	@BetTypeRefBetSetting int=0,
	@StructureVerBetSetting varchar(10)='',
	@isparlay bit = 0,
	@CheckDisableBet3rd bit = 0,
    @WinMaxSportType smallint = 0,
    @WinMaxBetType smallint = 0,
    @Date Date = null,
    @usertype int = 0, --0:default(MBC) 1:IMBC 2:CN88
	@LeagueGroupID SMALLINT =0,
	@IsApplyVR2 BIT = 0,
	@RefLevelID INT = NULL,
	@IsLowVR BIT = 0,
	@BetFrom NVARCHAR(1) = ''
AS
/*
--------------------------------------------------------------------------------
	-- !!!!!!!!!!!!!!! include UM function !!!!!!!!!!!!!!!!!!!!!!!!
	-- durning UM time alert function [f_CheckUMStatus]
	--------------------------------------------------------------------------------
	Revision:
	-- 2016-02-18@TWJoe(CUSTDB):  Create SP using mapping table
	-- 2016-02-25@TWJoe(CUSTDB):  add retuen @DisableBet
	-- 2016-04-16@TWJoe(CUSTDB):  support combo parlay
	-- 2016-08-04@TWJoe(CUSTDB):  chang autosuspend rule
	-- 2016-10-28@TWJoe(CUSTDB):  add @dbo.f_DisableSport() for virtual sports update change lic key
	-- 2016-11-18@TWJoe(CUSTDB):  add MaxPerMatch1MP
	-- 2016-12-08@TWJoe(CUSTDB):  Lic no use MaxPerMatch1MP , rollback to maxpermatch
	-- 2017-08-01@Vivi(CustDB): change use temp table (#tmp) to table parameter (@tmp)
	-- 2017-06-27@TWJoe(CUSTDB):  Dot_Member_ProductStatus_DCS Support All Virtual Sports
	-- 2017-07-25@TWJoe(CUSTDB):  return BonusWalletFlag for Bonus Wallet
	-- 2017-08-02@TWJoe(CUSTDB):  return @DisBetSetting3rd
	-- 2018-04-10@TWJoe(CUSTDB):  @autosuspend add check sporttype 192, 193
	-- 2018-04-12@TWJoe(CUSTDB):  add return MaxWinLimit, MaxLossLimit for Virtual Sports(@WinMaxSportType=180,@WinMaxBetType=1201)
	-- 2018-04-18@TWJoe(CUSTDB):  remove old script
	-- 2018-09-21@TWJoe(CUSTDB):  add check outright disable
	-- 2018-10-23@TWJoe(CUSTDB):  Get Happy 5 MaxPerMatch(maxpermatch164)
	-- 2018-11-28@TWJoe(CUSTDB):  Support sporttype 194
	-- 2018-12-18@TWJoe(CUSTDB):  Change Lic Happy 5 MaxperMatch164 To MaxperMatch161
	-- 2019-03-05@TWJoe(CUSTDB):  DCS MaxPerMatch Change To Dot_Member_GetCustSetting
	-- 2019-03-07@TWJoe(CUSTDB):  add @Date, @isCN88 Support CN88 Credit 
	-- 2019-05-30@Vivi(CUSTDB): add UM control
	-- 2019-06-12@TWJoe(CUSTDB): CN88 User Check reject,closed setting from CS_CustomerStatus
	-- 2019-07-01@VN-Dominic(CUSTDB): Add a new input param @LeagueGroupID,and add a new different logic to get VR setting for E-sports
	-- 2019-09-10@TWJoe(CUSTDB): LicUser SportType=44 use MaxPerMatch99
	-- 2019-09-11@TWJoe(CUSTDB): remove DisableOpenTote,Disable151_AU,DisableHorseRacing,Disable152_UK,Disable152_AU,Disable153_AU,DisableLiveCasino,MaxWinLiveCasino,MaxPerMatch44
	-- 2019-12-13@TWJoe(CUSTDB): remove maxpermatch154,maxpermatch151_OT,MaxPerMatch151_AU,maxpermatch151,maxpermatch152_UK,MaxPerMatch152_AU,MaxPerMatch153_AU
	-- 10191227@Eden: Integrate VR autosuspend [Redmine: #121876]
	-- 20200116@VN-Elodie: Add a new different logic to get VR setting for Soccer
	-- 20200203@VN-Elodie: Apply Currency Modifier
	-- 20200308@VN-Elodie: VR Setting for Soccer By Hours (6AM - 8PM GMT+8)
	-- 20200512@VN-Eden: Disable VR setting of CN88 Customers [#133976]
	-- 20200511@VN-Eden: E-sport VR for Map X Overtime [#132517]
	-- 20200612@TWAdam(CUSTDB): LicUser Soccer Parlay use MaxPerMatch1MP & Add BetRadar new virtual sports (195,196,197)
	-- 20200703@VN-Eden: Control Virtual Rate for Soccer SET = -99% for member stake less than or equal to RM125 [#136990]
	-- 20200610@VN-Eden: Virtual Rate for Basketball [Redmine: #134978]
	-- 20200722@VN-Eden: VR setting for Basketball by member stake [Redmine: #138089]
	-- 20200805@VN-Eden: VR setting for Basketball on some licensees from Desktop/China View [redmine: #138168]
	-- 20200811@VN-Eden: Adjust VR setting for Other Sports of Haifa, IBO, Mansion88 & Happy8 [redmine: #139229]
*/	
BEGIN

	SET NOCOUNT ON

	DECLARE @UMRejectFlag BIT = 0

	DECLARE @username NVARCHAR(50), @recommend INT, @mrecommend INT, @srecommend INT,
			@credit MONEY, @MaxPerBall161 MONEY,
			@actualrate FLOAT, @currencyname NVARCHAR(50), @virtualrate SMALLMONEY,
			@maxpermatch MONEY, @autosuspend BIT, @currency INT,
			@closed BIT, @reject BIT, @DisableBet BIT,@MaxWinVendorGame SMALLMONEY=0,
			@DisBetSetting BIT,@DisBetSetting3rd BIT = 0,@BonusWalletFlag BIT,@False BIT=0,@True BIT=1,@Zero TINYINT=0,@MaxWinLimit SMALLMONEY=0,
			@MaxLossLimit MONEY=0,@CN88_reject BIT= 1,@CN88_closed BIT=1

	--set @WinMaxBetType=@bettype
	IF @WinMaxSportType<>0 and @WinMaxBetType<>0
	BEGIN
		SELECT @MaxWinLimit=ISNULL(MaxWinLimit,@Zero),@MaxLossLimit=ISNULL(MaxLossLimit,@Zero)  
		FROM CustWinLossLimit_Member  WITH (NOLOCK) 
		WHERE custid=@custid and sporttype=@WinMaxSportType and bettype=@WinMaxBetType
	END
	
	IF @usertype=2
	BEGIN
		SELECT @CN88_closed=CASE WHEN InactiveInfo>0 or SuspendedInfo>0 THEN 1 ELSE 0 END, 
				@CN88_reject=CASE WHEN ViewOnlyInfo>0 THEN 1 ELSE 0 END 
		FROM CS_CustomerStatus WITH (NOLOCK) 
		WHERE CustId=@custid
        
		IF @Date is null
		BEGIN
			SET @Date=CURRENT_TIMESTAMP
		END
	END
	
	SET @DisBetSetting=0
	DECLARE @tmp TABLE(IsHidden BIT, IsDisabled BIT)
	
	IF @StructureVerBetSetting='DCS' and @usertype<>2
	BEGIN
		INSERT INTO  @tmp (IsHidden, IsDisabled)
		EXEC Dot_Member_ProductStatus_DCS
				@custid=@custid,
				@sporttype=@sporttype,
				@isLicensee = @isLicensee				
			
		SELECT @DisBetSetting=IsDisabled FROM @tmp
	END

	IF @CheckDisableBet3rd<>0
	BEGIN
		SELECT @DisBetSetting3rd=IsDisabled FROM DisableBetByProduct3rd WITH (NOLOCK) WHERE SportType = @sporttype
	END
    
	DECLARE @DisableSport BIT
	SELECT @DisableSport=dbo.f_DisableSport(@sporttype)
	SELECT @username=ci.username,@recommend=ci.recommend,@mrecommend=ci.mrecommend,@srecommend=ci.srecommend,
			@credit=CASE WHEN @usertype=2 THEN case when (ci.CreditUpdatedDate is null or @Date>=convert(date,ci.CreditUpdatedDate)) then ci.credit else @Zero end ELSE ci.credit END,
			@MaxPerBall161=ci.MaxPerBall161,@actualrate=ex.actualrate,@currencyname=ex.currency,@virtualrate=ci.virtualmultiplier,@BonusWalletFlag=isNull(ci.BonusWalletFlag,@False),
					@maxpermatch=IsNull(CASE
					WHEN @usertype=2 THEN @Zero 
					WHEN @isparlay=0 and @sporttype=1 THEN maxpermatch 
					WHEN @isparlay=0 and @sporttype=2 THEN maxpermatch2
					WHEN @isparlay=0 and @sporttype=3 THEN maxpermatch3
					WHEN @isparlay=0 and @sporttype=5 THEN maxpermatch5
					WHEN @isparlay=0 and @sporttype=8 THEN maxpermatch8
					WHEN @isparlay=0 and @sporttype=10 THEN maxpermatch10
					WHEN @isparlay=0 and @sporttype=11 THEN maxpermatch11
					WHEN @isparlay=0 and @sporttype=161 THEN maxpermatch161
					WHEN @isparlay=0 and @sporttype=164 and @isLicensee=0 THEN maxpermatch164
					WHEN @isparlay=0 and @sporttype=164 and @isLicensee=1 THEN maxpermatch161
					WHEN @isparlay=0 and @sporttype=32 THEN maxpermatch2
					WHEN @isparlay=0 and @sporttype=44 THEN MaxPerMatch99
					WHEN @isparlay=1 and @sporttype=1 THEN MaxPerMatch1MP
					WHEN @isparlay=1 and @sporttype=99 THEN MaxPerMatch99MP
					ELSE ci.maxpermatch99 END, 0),
					@autosuspend=case when @sporttype=1 then ISNULL(ci.autosuspend,@False)
										when @isparlay=1 or @sporttype in (180,181,182,183,184,185,186,190,191,192,193,194,195,196,197) then @False
										else ISNULL(ci.autosuspend2,@False) end,
					@currency=ci.currency,
					@DisableBet= isnull(case 
										when @usertype=2 then @False
										when @bettype=10 then ci.DisableOutright
										when @StructureVerBetSetting='DCS' then @DisBetSetting
										when @sporttype in (161,164) then ci.DisableNumber
										when @sporttype=43 then ci.DisableEsports
										when @sporttype=1 and @bettype in (801,802,803,804,805,806) then ci.DisableSuperLive
										else @False end,@True) | @DisableSport,
					@closed=CASE WHEN @usertype=2 THEN isnull(ci.closed,@False) | @CN88_closed ELSE isnull(ci.closed,@False) END,
					@reject= case when @DisableBet=@False then CASE WHEN @usertype=2 THEN @CN88_reject ELSE isnull(ci.reject,@False) END else @DisableBet end
		from custinfo as ci with (nolock) 
			join exchange as ex with (nolock) on  ci.currency = ex.exchangeid 
		where ci.custid=@custid 
	
	
	------------------------------------------------
	-- 20181219@Vivi: add get UM flag
	IF @reject=@False
	BEGIN
		SELECT @UMRejectFlag = dbo.f_CheckUMStatus(@custid, @isLicensee)
	
		IF @UMRejectFlag=1 AND @currency<>20 AND @srecommend<>72 --(@srecommend=72: Allbet Test)
		BEGIN
			SELECT @reject=@True
		END
	END
	------------------------------------------------
	IF @sporttype IN (44) AND @isLicensee = 0 --MuayThai for Credit
	BEGIN
		SELECT  @MaxperMatch = ISNULL(MaxPerMatch, @Zero)
		FROM dbo.CustBetSetting3rd_Member bs WITH (NOLOCK)
		WHERE bs.custid = @custid
			AND bs.BetType = 3
			AND bs.SportType = @Sporttype
	END		

	DECLARE @new_virtualrate FLOAT = 1

	IF @sporttype_vrate <= 99 AND @sporttype_vrate NOT IN (1, 43) --Other sports
		AND @BetFrom = 'a' --Desktop/ChinaView
		AND @isLicensee = 1 AND @currencyname IN( 'RMB','UUS')
	BEGIN
		IF EXISTS (	SELECT TOP 1 1 
					FROM VRCustAutoAdjustment v WITH(NOLOCK) 
					WHERE v.SportType = 99 
						AND v.CustID = @custid
						AND v.[Status] = 1
						AND FirstBetDate IS NULL
				)
			BEGIN
				UPDATE v
				SET v.[Status] = 2 
				FROM VRCustAutoAdjustment v WITH(ROWLOCK) 
					WHERE v.SportType = 99 
						AND v.CustID = @custid
						AND v.[Status] = 1
						AND FirstBetDate IS NULL
				
				--Update VR = 0 for Basket Ball (using VR2)
				DECLARE @BasketBallLevelID INT
					, @ValueID_0 INT

				SELECT @BasketBallLevelID = levelID
				FROM VRSettingHierarchy  WITH(NOLOCK)
				WHERE SportType = 2
					AND VRLeagueGroupID = -1
					AND BetType = -1

				SELECT @ValueID_0 = ValueID
				FROM VRValueMapping WITH(NOLOCK)
				WHERE Value = 1.00 

				IF EXISTS (	SELECT 1 
							FROM VRCustSetting WITH(NOLOCK) 
							WHERE custid = @custid AND LevelID = @BasketBallLevelID) 
				BEGIN
					UPDATE v
					SET v.ValueIDLIVE = @ValueID_0
						,v.ValueIDNonLIVE = @ValueID_0
					FROM VRCustSetting v WITH(ROWLOCK) 
					WHERE custid = @custid AND LevelID = @BasketBallLevelID
						AND (v.ValueIDLIVE != @ValueID_0 OR v.ValueIDNonLIVE != @ValueID_0)
				END
				ELSE
				BEGIN
					INSERT INTO VRCustSetting( CustID,LevelID,ValueIDLIVE,ValueIDNonLIVE) VALUES ( @custid,@BasketBallLevelID,@ValueID_0,@ValueID_0)
				END

				--Update VR = 0 for Other sports (using VR1)
				DECLARE	@tblVirtualrate		TABLE (
											SportType			INT
										,	BetType				INT
										,	IsLive				BIT
										,	VirtualMultiplier	SMALLMONEY	
										);
										
				INSERT INTO	@tblVirtualrate (
										SportType
									,	BetType
									,	IsLive
									,	VirtualMultiplier
								)
				SELECT	sporttype,bettype,islive,1.00
				FROM ProfileVirtualSetting 	WITH (NOLOCK)	
				WHERE sporttype NOT IN (1,2,43)

				DECLARE	@virtualXML	TABLE (
												seqNo		TINYINT PRIMARY KEY
											,	Pos			VARBINARY(64)
											,	Val			VARBINARY(64)
											);
										
				INSERT INTO @virtualXML(seqNo, Pos, Val )
				SELECT	seqNo, p1.Pos, p2.Val
				FROM (
						SELECT	DISTINCT seqNo
						FROM	ProfileVirtualSetting WITH (NOLOCK)
					) pvs
					CROSS APPLY (
						SELECT CONVERT(VARBINARY(64), (
							SELECT	CONVERT(VARCHAR, CAST(ipvs.profileID - 64 * (ipvs.seqNo - 1) AS BINARY(1)), 2)
							FROM		@tblVirtualrate			AS tmp
								INNER JOIN	ProfileVirtualSetting	AS ipvs WITH (NOLOCK)
									ON	tmp.sporttype	= ipvs.sporttype
										AND	tmp.bettype		= ipvs.bettype
										AND	tmp.isLive		= ipvs.islive
							WHERE	ipvs.seqNo = pvs.seqNo
							FOR XML PATH ('')						
						), 2) AS Pos
					) p1
					CROSS APPLY (
						SELECT CONVERT(VARBINARY(64), (
							SELECT	CONVERT(VARCHAR, CAST(CASE WHEN CAST(VirtualMultiplier * 100 AS INT) > 200 THEN ((CAST(VirtualMultiplier * 100 AS INT) - 200) / 5 + 200) ELSE CAST(VirtualMultiplier * 100 AS INT) END AS BINARY(1)), 2)
							FROM		@tblVirtualrate			AS tmp
								INNER JOIN	ProfileVirtualSetting	AS ipvs WITH (NOLOCK)
									ON	tmp.sporttype	= ipvs.sporttype
										AND	tmp.bettype		= ipvs.bettype
										AND	tmp.isLive		= ipvs.islive
							WHERE	ipvs.seqNo = pvs.seqNo
							FOR XML PATH ('')						
						), 2) AS Val
					) p2;

				UPDATE cvs
					SET cvs.bitmapVirtual = bm.bitmap
				FROM		CustVirtualSetting	AS cvs WITH(UPDLOCK, ROWLOCK)			
					INNER JOIN	@virtualXML			AS tmp
							ON	cvs.seqNo = tmp.seqNo
					CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
				WHERE	cvs.custid = @custid
			END
	END

	IF @bettype<>0
	BEGIN
		IF @sporttype = 1 
		BEGIN
			IF @bettype NOT BETWEEN 801 AND 806 --For Soccer, exclude SuperLive
			BEGIN
				IF @IsApplyVR2 = 1 --Get VR2
					OR (@IsApplyVR2 = 0 AND @virtualrate = 1) -- Get VR1 
				BEGIN
					EXEC Dot_Member_CustomerGetVirtualRateBySportBettype @custid=@custid									
											, @sporttype = @sporttype_vrate
											, @bettype = @bettype_vrate
											, @OriginalSportType = @sporttype
											, @OriginalBetType = @bettype
											, @isLive = @liveindicator
											, @isLicensee = @isLicensee
											, @LeagueGroupID = @LeagueGroupID
											, @IsApplyVR2 = @IsApplyVR2
											, @srecommend = @srecommend
											, @usertype = @usertype
											, @virtualMultiplier = @new_virtualrate OUT
											, @IsLowVR = @IsLowVR
				END
			END			
		END
		ELSE IF @sporttype IN(2, 43) --For Esports/BasketBall, get VR2
		BEGIN
			EXEC Dot_Member_CustomerGetVirtualRateBySportBettype @custid=@custid
									, @sporttype = @sporttype_vrate
									, @bettype = @bettype_vrate
									, @isLive = @liveindicator
									, @isLicensee = @isLicensee
									, @LeagueGroupID = @LeagueGroupID
									, @srecommend = @srecommend								
									, @virtualMultiplier = @new_virtualrate OUT
									, @usertype = @usertype
									, @RefLevelID = @RefLevelID
									, @IsLowVR = @IsLowVR
		END

		ELSE IF @virtualrate = 1 --For a remaining sport, get VR1
		BEGIN
			EXEC Dot_Member_CustomerGetVirtualRateBySportBettype @custid=@custid
									, @sporttype = @sporttype_vrate
									, @bettype = @bettype_vrate
									, @isLive = @liveindicator	
									, @isLicensee = @isLicensee	
									, @srecommend = @srecommend															
									, @virtualMultiplier = @new_virtualrate OUT
									, @usertype = @usertype
									, @IsLowVR = @IsLowVR
		END

		SET @virtualrate = isnull(@new_virtualrate,1)
	end

	--Get E-Sport Autosuspend 
	IF @sporttype IN(2, 43) AND @isparlay = 0 
	BEGIN
		SET @autosuspend = @False

		IF @sporttype = 2 AND @IsLowVR = 1 AND @virtualrate < 1.00 
			SET @autosuspend = @False
		ELSE
		IF ISNULL(@usertype,0) <> 2 -- not CN88
		BEGIN
			SELECT @autosuspend = t.IsVRAutoSuspend 
			FROM [dbo].[f_GetVRAutosuspendStatus](@custid, @sporttype_vrate, @bettype_vrate, @LeagueGroupID, @liveindicator) t

			SET @autosuspend = ISNULL(@autosuspend,@False)
		END
	END
	
	--Get data from DCS structure
	--IF (@StructureVerBetSetting='DCS')
	--BEGIN
	--	if (@SportTypeRefBetSetting<>0 and @BetTypeRefBetSetting <>0)
	--	begin
	--		if @isLicensee=0
	--		begin
	--			SELECT  @MaxperMatch = ISNULL(MaxPerMatch, @Zero)
	--			FROM dbo.CustBetSetting3rd_Member bs WITH (NOLOCK)
	--			WHERE bs.custid = @custid
	--			   AND bs.BetType = @BetTypeRefBetSetting
	--			   AND bs.SportType = @SportTypeRefBetSetting
	--		end else
	--		begin
	--			SELECT  @MaxperMatch = ISNULL(MaxPerMatch, @Zero)
	--			FROM dbo.Dep_CustBetSetting_Member bs WITH (NOLOCK)
	--			WHERE bs.custid = @custid
	--			   AND bs.BetType = @BetTypeRefBetSetting
	--			   AND bs.SportType = @SportTypeRefBetSetting
	--		end
	--	end else
	--	begin
	--		set @MaxperMatch=@Zero
	--	end
	--END
	SELECT @username username, @recommend recommend, @mrecommend mrecommend, @srecommend srecommend,
			@credit credit, @MaxPerBall161 MaxPerBall161,
			@actualrate actualrate, @currencyname currencyname, @virtualrate virtualrate,
			@maxpermatch maxpermatch, @autosuspend autosuspend, @currency currency,
			@closed closed, @reject reject, @DisableBet disabledBet,@DisBetSetting3rd DisBetSetting3rd,@BonusWalletFlag BonusWalletFlag,
			@MaxWinLimit MaxWinLimit, @MaxLossLimit MaxLossLimit
END
