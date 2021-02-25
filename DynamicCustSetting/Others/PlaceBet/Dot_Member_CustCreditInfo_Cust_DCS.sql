/*<info serverAlias="DBCUST-CustDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_CustCreditInfo_Cust_DCS]
	@custid INT,
	@sporttype SMALLINT,
	@PartnerID SMALLINT=null,
	@bettype SMALLINT= 0,
	@liveindicator BIT =0,
	@isLicensee BIT = 0,
	@sporttype_vrate SMALLINT= 0,
	@bettype_vrate SMALLINT = 0,
	@LeagueGroupID SMALLINT = 0,
	@IsApplyVR2 BIT = 0,
	@RefLevelID INT = NULL,
	@IsLowVR BIT = 0 ,
	@BetFrom NVARCHAR(1) = '',
	@CustomerClass SMALLINT = NULL,     
	@StakeRM MONEY = NULL
AS
BEGIN
/*
	--------------------------------------------------------------------------------
	-- !!!!!!!!!!!!!!! include UM function !!!!!!!!!!!!!!!!!!!!!!!!
	-- durning UM time alert function [f_CheckUMStatus]
	--------------------------------------------------------------------------------
	Revision:
	-- 2013-09-26@TWJoe(CUSTDB):  new sp for CUSTDB
	-- 2014-02-07@Tony(CUSTDB):  add sport 183 and 185
	-- 2014-03-26@TWJoe(CUSTDB):  add check closed isnull
	-- 2015-02-04@TWJoe(CUSTDB):  get new virtualrate
	-- 2015-02-26@TWJoe(CUSTDB):  when get new virtualrate ,if @sporttype<>1 set @sporttype = 99
	-- 2015-03-04TWJoe(CUSTDB):  new virtualrate for all site
	-- 2015-03-06TWJoe(CUSTDB):  new virtualrate change bettype 153,155,1308,1316 to 1 ,1305,1318 to 2,156,1306,1312 to 3
	-- 2015-07-02TWJoe(CUSTDB):  add check DisableBet for sporttype 161,162,43,180~186
	-- 2015-07-16TWJoe(CUSTDB):  get MaxWinLimit for Virtual Sports(180~186)
	-- 2015-10-16TWJoe(CUSTDB):  Muay Thai(44) canbet check Dot_Member_ProductStatus_DCS
	-- 2015-10-19TWJoe(CUSTDB):  add check DisableBet for SuperLive BetType 801~806
	-- 2015-10-21@VN-Dominic(CUSTDB): + add a new logic to get maxpermatch when placing bets on MuayThai
	--                                + Using @isLicensee as an input parameter when calling Dot_Member_ProductStatus_DCS
	-- 2015-11-03@Joy(CUSTDB):  Add two Parameters @sporttype_vrate, @sporttype_vrate for  virtual rate enhancement
	-- 2015-11-03@TWJoe(CUSTDB):  using new VirtualRate from Dot_Member_CustomerGetVirtualRateBySportBettype by @sporttype_vrate, @sporttype_vrate
	-- 2015-12-09@TWJoe(CUSTDB):  add CookFighting check can bet
	-- 2016-08-04@TWJoe(CUSTDB):  chang autosuspend rule
	-- 2016-10-28@TWJoe(CUSTDB):  add @dbo.f_DisableSport() for virtual sports update change lic key
	-- 2017-08-01@Vivi(CustDB): change use temp table (#tmp) to table parameter (@tmp)
	-- 2017-07-25@TWJoe(CUSTDB):  return BonusWalletFlag for Bonus Wallet
	-- 2018-08-16@TWJoe(CUSTDB):  return @DisableBet
	-- 2018-12-26@TWJoe(CUSTDB):  change DisableBet to DisabledBet
	-- 2019-05-30@Vivi(CUSTDB): add UM control
	-- 2019-07-01@VN-Dominic(CUSTDB): Add a new input param @LeagueGroupID,and add a new different logic to get VR setting for E-sports
	-- 2019-09-10@TWJoe(CUSTDB): LicUser SportType=44 use MaxPerMatch99
	-- 2019-09-11@TWJoe(CUSTDB): remove DisableOpenTote,Disable151_AU,DisableHorseRacing,Disable152_UK,Disable152_AU,Disable153_AU,DisableLiveCasino,DisableVirtualSports,MaxWinLiveCasino,MaxPerMatch44
	-- 2019-12-13@TWJoe(CUSTDB): remove maxpermatch154,maxpermatch151_OT,MaxPerMatch151_AU,maxpermatch151,maxpermatch152_UK,MaxPerMatch152_AU,MaxPerMatch153_AU
	-- 20200116@VN-Elodie: Add a new different logic to get VR setting for Soccer
	-- 20200203@VN-Elodie: Apply Currency Modifier
	-- 20200511@VN-Eden: E-sport VR for Map X Overtime [#132517]
	-- 20200703@VN-Eden: Control Virtual Rate for Soccer SET = -99% for member stake less than or equal to RM125 [#136990]
	-- 20200811@VN-Eden: Adjust VR setting for Other Sports of Haifa, IBO, Mansion88 & Happy8 [redmine: #139229]
	-- 20200826@VN-Eden: Adjust VR setting for Soccer of Haifa, IBO [redmine: #140368]
	-- 20201014@VN-Eden: VR Setting for Soccer By Stake <= RM 80 [Redmine: #143314]
	-- 20210219@VN-Eden: Apply VR by stake range and Auto Adjustment VR by Member profile [Redmine: #150298]
*/
	SET NOCOUNT ON;

	DECLARE @UMRejectFlag bit = 0
	DECLARE @username nvarchar(50), @recommend int, @mrecommend int, @srecommend int,
			@credit money, @MaxPerBall161 money,
			@actualrate float, @currencyname nvarchar(50), @virtualrate smallmoney,
			@maxpermatch money, @autosuspend bit, @currency int,
			@closed bit, @reject bit, @DisableBet bit,@MaxWinVendorGame smallmoney=0,@WinMaxBetType smallint,@DisBetSetting bit,@BonusWalletFlag bit,@False bit=0,@True bit=1,@Zero tinyint=0, @Site VARCHAR(10), @IsForcedVRValue BIT, @ForcedVRValue SMALLMONEY,@creatdate DATETIME
	/* don't move
	set @WinMaxBetType=@bettype
	select @WinMaxBetType=case --when @sporttype = 255 then 1701 --GD
							   --when @sporttype = 203 then 2001 --MG
							   --when @sporttype = 202 then 1501 --KENO
							   when @sporttype in (180,181,182,183,184,185,186) then 1301 --Virtual Sports
							   else 0 end
	if @WinMaxBetType<>0
	begin
		select @MaxWinVendorGame=ISNULL(MaxWinLimit,0) from CustWinLimit with (nolock) where sporttype=@sporttype and bettype=@WinMaxBetType
	end
	*/
	set @DisBetSetting=0
	DECLARE @tmp TABLE (IsHidden bit, IsDisabled bit)
	if (@sporttype=44)
	begin
		INSERT INTO  @tmp (IsHidden, IsDisabled)
			exec Dot_Member_ProductStatus_DCS
				@custid=@custid,
				@sporttype=@sporttype,
				@isLicensee = @isLicensee				
		select @DisBetSetting=IsDisabled from @tmp
	end
	declare @DisableSport bit
	select @DisableSport=dbo.f_DisableSport(@sporttype)
	select @username=ci.username,@recommend=ci.recommend,@mrecommend=ci.mrecommend,@srecommend=ci.srecommend, @credit=ci.credit, @MaxPerBall161=ci.MaxPerBall161,@actualrate=ex.actualrate,@currencyname=ex.currency,@virtualrate=ci.virtualmultiplier,@BonusWalletFlag=isNull(ci.BonusWalletFlag,@False),

					@maxpermatch=IsNull(CASE @sporttype 
					WHEN 1 THEN maxpermatch 
					WHEN 2 THEN maxpermatch2
					WHEN 3 THEN maxpermatch3
					WHEN 5 THEN maxpermatch5
					WHEN 8 THEN maxpermatch8
					WHEN 10 THEN maxpermatch10
					WHEN 11 THEN maxpermatch11
					WHEN 161 THEN maxpermatch161
					WHEN 32 THEN maxpermatch2
					WHEN 44 THEN maxpermatch99
					ELSE ci.maxpermatch99 END, @Zero),
					@autosuspend=case when @sporttype=1 then ISNULL(ci.autosuspend,@False)
									  --when @sporttype in (180,181,182,183,184,185,186) then 0
									  else ISNULL(ci.autosuspend2,@False) end,
					@currency=ci.currency,
					@DisableBet= isnull(case 
										when @sporttype=161 then ci.DisableNumber
										when @sporttype=43 then ci.DisableEsports
										when @sporttype=44 then @DisBetSetting
										when @sporttype=1 and @bettype in (801,802,803,804,805,806) then ci.DisableSuperLive
										else 0 end,1) | @DisableSport,
					@closed=isnull(ci.closed,0),
					@reject= case when @DisableBet=0 then isnull(ci.reject,@False) else @DisableBet end
					from custinfo as ci with (nolock) join exchange as ex with (nolock)
		on  ci.currency = ex.exchangeid where ci.custid=@custid 

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

	DECLARE @new_virtualrate FLOAT = 1

	IF @sporttype_vrate <= 99
		AND @BetFrom = 'a' --Desktop/ChinaView
		AND @isLicensee = 1 AND @currencyname IN( 'RMB','UUS')
	BEGIN
		DECLARE @AdjustmentSporttype smallint

		SELECT @AdjustmentSporttype = v.SportType
		FROM VRCustAutoAdjustment v WITH(NOLOCK) 
		WHERE v.SportType IN (99, 100) 
			AND v.CustID = @custid
			AND v.[Status] = 1
			AND FirstBetDate IS NULL

		IF @AdjustmentSporttype IN (99, 100) --Update VR = 0 for Other Sports
		BEGIN
			DECLARE @ValueID_0 INT
			DECLARE @BasketBallLevelID INT
			DECLARE	@tblVirtualrate		TABLE (
										SportType			INT
									,	BetType				INT
									,	IsLive				BIT
									,	VirtualMultiplier	SMALLMONEY	
									);
			DECLARE	@virtualXML	TABLE (
											seqNo		TINYINT PRIMARY KEY
										,	Pos			VARBINARY(64)
										,	Val			VARBINARY(64)
										);
			
			--Update Status = 2
			UPDATE v
			SET v.[Status] = 2 
			FROM VRCustAutoAdjustment v WITH(ROWLOCK) 
				WHERE v.SportType = @AdjustmentSporttype
					AND v.CustID = @custid
					AND v.[Status] = 1
					AND FirstBetDate IS NULL
			
			SELECT @ValueID_0 = ValueID
			FROM VRValueMapping WITH(NOLOCK)
			WHERE Value = 1.00
				
			--Update VR = 0 for Basket Ball (using VR2)
			SELECT @BasketBallLevelID = levelID
			FROM VRSettingHierarchy  WITH(NOLOCK)
			WHERE SportType = 2
				AND VRLeagueGroupID = -1
				AND BetType = -1 

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
			INSERT INTO	@tblVirtualrate (
									SportType
								,	BetType
								,	IsLive
								,	VirtualMultiplier
							)
			SELECT	sporttype,bettype,islive,1.00
			FROM ProfileVirtualSetting 	WITH (NOLOCK)	
			WHERE sporttype NOT IN (1,2,43)

			IF @AdjustmentSporttype = 100 --Update VR = 0 for Soccer (using VR1)
			BEGIN
				INSERT INTO	@tblVirtualrate (
										SportType
									,	BetType
									,	IsLive
									,	VirtualMultiplier
								)
				SELECT	sporttype,bettype,islive,1.00
				FROM ProfileVirtualSetting 	WITH (NOLOCK)	
				WHERE sporttype = 1
			END
										
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

	--#150298 Check Member meet with given credit and StakeRM condition to Set VR = 0
	IF EXISTS( SELECT 1 FROM VRMemberBigStake WITH(NOLOCK) WHERE custid = @custid AND Type = 1 AND status = 1)
	BEGIN
		SET @IsForcedVRValue = 0
	END
	ELSE
	BEGIN
		SELECT @Site = ISNULL(site,''), @creatdate = creatdate FROM Customer WITH(NOLOCK) WHERE custid = @custid

		IF EXISTS(
			SELECT 1
			FROM dbo.f_GetVRBigStakeConfig(@Site) cf
			WHERE cf.Credit < @credit * (CASE WHEN @currency <> 20 THEN @actualrate ELSE 1 END) 
				AND stakeRM < @StakeRM
				AND cf.Type = 1
				AND cf.ReleasedDate <= @creatdate
			)
		BEGIN
			SET @IsForcedVRValue = 1

			SELECT @ForcedVRValue = VRValue
			FROM dbo.f_GetVRBigStakeConfig(@Site) cf
			WHERE cf.Type = 1
		END

		ELSE
			SET @IsForcedVRValue = 0
	END

	IF @bettype<>0
	BEGIN
		IF @sporttype = 1
		BEGIN
			IF @bettype NOT BETWEEN 801 AND 806 --For Soccer, exclude SuperLive
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
										, @virtualMultiplier = @new_virtualrate OUT
										, @IsLowVR = @IsLowVR
										, @CustomerClass = @CustomerClass
										, @StakeRM = @StakeRM
										, @virtualrate = @virtualrate
										, @BetFrom = @BetFrom
			END			
		END
		ELSE IF @sporttype = 43 --For Esports, get VR2
		BEGIN
			EXEC Dot_Member_CustomerGetVirtualRateBySportBettype @custid=@custid
									, @sporttype = @sporttype_vrate
									, @bettype = @bettype_vrate
									, @isLive = @liveindicator
									, @isLicensee = @isLicensee	
									, @LeagueGroupID = @LeagueGroupID	
									, @srecommend = @srecommend					
									, @virtualMultiplier = @new_virtualrate OUT
									, @RefLevelID = @RefLevelID
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
									, @IsLowVR = @IsLowVR
		END

		IF @IsForcedVRValue = 1 AND @sporttype NOT IN (2,43)
		BEGIN
			SET @new_virtualrate = CASE WHEN @ForcedVRValue > ISNULL(@new_virtualrate,1) THEN @ForcedVRValue ELSE ISNULL(@new_virtualrate,1) END
		END

		SET @virtualrate = isnull(@new_virtualrate,1)
	END
	
	--Get data from DCS structure
	IF @sporttype IN (44) AND @isLicensee = 0 --MuayThai for Credit
	BEGIN
		SELECT  @MaxperMatch = ISNULL(MaxPerMatch, @Zero)
		FROM dbo.CustBetSetting3rd_Member bs WITH (NOLOCK)
		WHERE bs.custid = @custid
		   AND bs.BetType = 3
		   AND bs.SportType = @Sporttype
	END
	
	SELECT @username username, @recommend recommend, @mrecommend mrecommend, @srecommend srecommend,
			@credit credit, @MaxPerBall161 MaxPerBall161,
			@actualrate actualrate, @currencyname currencyname, @virtualrate virtualrate,
			@maxpermatch maxpermatch, @autosuspend autosuspend, @currency currency,
			@closed closed, @reject reject,@DisableBet DisabledBet,@BonusWalletFlag BonusWalletFlag
END




