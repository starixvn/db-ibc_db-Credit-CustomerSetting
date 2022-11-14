/*<info serverAlias="DBCUST-CustDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_GetCustCreditInfo] @custid INT
	,@sporttype SMALLINT
	,@PartnerID SMALLINT = NULL
	,@bettype SMALLINT = 0
	,@liveindicator BIT = 0
	,@isLicensee BIT = 0
	,@sporttype_vrate SMALLINT = 0
	,@bettype_vrate SMALLINT = 0
	,@SportTypeRefBetSetting INT = 0
	,@BetTypeRefBetSetting INT = 0
	,@StructureVerBetSetting VARCHAR(10) = ''
	,@isparlay BIT = 0
	,@CheckDisableBet3rd BIT = 0
	,@WinMaxSportType SMALLINT = 0
	,@WinMaxBetType SMALLINT = 0
	,@Date DATE = NULL
	,@usertype INT = 0
	,--0:default(MBC) 1:IMBC 2:CN88
	@LeagueGroupID SMALLINT = 0
	,@IsApplyVR2 BIT = 0
	,@RefLevelID INT = NULL
	,@IsLowVR BIT = 0
	,@BetFrom NVARCHAR(1) = ''
	,@CustomerClass SMALLINT = NULL
	,@StakeRM MONEY = NULL
	,@LeagueID INT = - 1
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
    -- 20200826@VN-Eden: Adjust VR setting for Soccer of Haifa, IBO [redmine: #140368]
    -- 20201014@VN-Eden: VR Setting for Soccer By Stake <= RM 80 [Redmine: #143314]
    -- 20210204@TW-Andy: BasketBall BetBuilder Use MaxPerMatch99MP                               
    -- 20210219@VN-Eden: Apply VR by stake range and Auto Adjustment VR by Member profile [Redmine: #150298]
    -- 20210309@VN-Eden: Revise @betfrom = 'a' to 'z' to VR setting for Basketball on some licensees from Desktop/China View [Redmine: #151392]
    -- 20210226@VN-Eden: Implement Lock for VR update [Redmine:#149370]
    -- 20210427@VN-Eden: Implement dedicated feature to control Global Virtual Rate adjustment on tickets [Redmine:#136423]
    -- 20210703@TW-Andy: Credit user lock account  suspend 
    -- 20210427@VN-Eden: change funtion get autosuspend [Redmine: #160766]
    -- 20220477@Tw-Xinxian: Cloumn add alias
    -- 20220912@Tw-YC: remove maxpermatch164
  */
BEGIN
	SET NOCOUNT ON

	DECLARE @UMRejectFlag BIT = 0
	DECLARE @username NVARCHAR(50)
		,@recommend INT
		,@mrecommend INT
		,@srecommend INT
		,@credit MONEY
		,@MaxPerBall161 MONEY
		,@actualrate FLOAT
		,@currencyname NVARCHAR(50)
		,@virtualrate SMALLMONEY
		,@maxpermatch MONEY
		,@autosuspend BIT
		,@currency INT
		,@closed BIT
		,@reject BIT
		,@DisableBet BIT
		,@MaxWinVendorGame SMALLMONEY = 0
		,@DisBetSetting BIT
		,@DisBetSetting3rd BIT = 0
		,@BonusWalletFlag BIT
		,@False BIT = 0
		,@True BIT = 1
		,@Zero TINYINT = 0
		,@MaxWinLimit SMALLMONEY = 0
		,@MaxLossLimit MONEY = 0
		,@CN88_reject BIT = 1
		,@CN88_closed BIT = 1
		,@Site VARCHAR(10)
		,@IsForcedVRValue BIT
		,@ForcedVRValue SMALLMONEY
		,@creatdate DATETIME
		,@SiteID INT
		,@Istest BIT
		,@Locked BIT = 0

	SELECT @Istest = CASE 
			WHEN (
					Object_name(@@PROCID) LIKE '%[_]xtest%'
					OR Object_name(@@PROCID) LIKE '%[_]xpre%'
					OR Object_name(@@PROCID) LIKE '%[_]uat[1-9]%'
					)
				THEN 1
			ELSE 0
			END

	--set @WinMaxBetType=@bettype
	IF @WinMaxSportType <> 0
		AND @WinMaxBetType <> 0
	BEGIN
		SELECT @MaxWinLimit = Isnull(maxwinlimit, @Zero)
			,@MaxLossLimit = Isnull(maxlosslimit, @Zero)
		FROM custwinlosslimit_member WITH (NOLOCK)
		WHERE custid = @custid
			AND sporttype = @WinMaxSportType
			AND bettype = @WinMaxBetType
	END

	IF @usertype = 2
	BEGIN
		SELECT @CN88_closed = CASE 
				WHEN inactiveinfo > 0
					OR suspendedinfo > 0
					THEN 1
				ELSE 0
				END
			,@CN88_reject = CASE 
				WHEN viewonlyinfo > 0
					THEN 1
				ELSE 0
				END
		FROM cs_customerstatus WITH (NOLOCK)
		WHERE custid = @custid

		IF @Date IS NULL
		BEGIN
			SET @Date = CURRENT_TIMESTAMP
		END
	END

	SET @DisBetSetting = 0

	DECLARE @tmp TABLE (
		ishidden BIT
		,isdisabled BIT
		)

	IF @StructureVerBetSetting = 'DCS'
		AND @usertype <> 2
	BEGIN
		INSERT INTO @tmp (
			ishidden
			,isdisabled
			)
		EXEC Dot_member_productstatus_dcs @custid = @custid
			,@sporttype = @sporttype
			,@isLicensee = @isLicensee

		SELECT @DisBetSetting = isdisabled
		FROM @tmp
	END

	IF @CheckDisableBet3rd <> 0
	BEGIN
		SELECT @DisBetSetting3rd = isdisabled
		FROM disablebetbyproduct3rd WITH (NOLOCK)
		WHERE sporttype = @sporttype
	END

	DECLARE @DisableSport BIT

	SELECT @DisableSport = dbo.F_disablesport(@sporttype)

	SELECT @username = ci.username
		,@recommend = ci.recommend
		,@mrecommend = ci.mrecommend
		,@srecommend = ci.srecommend
		,@credit = CASE 
			WHEN @usertype = 2
				THEN CASE 
						WHEN (
								ci.creditupdateddate IS NULL
								OR @Date >= CONVERT(DATE, ci.creditupdateddate)
								)
							THEN ci.credit
						ELSE @Zero
						END
			ELSE ci.credit
			END
		,@MaxPerBall161 = ci.maxperball161
		,@actualrate = ex.actualrate
		,@currencyname = ex.currency
		,@virtualrate = ci.virtualmultiplier
		,@BonusWalletFlag = Isnull(ci.bonuswalletflag, @False)
		,@maxpermatch = Isnull(CASE 
				WHEN @usertype = 2
					THEN @Zero
				WHEN @isparlay = 0
					AND @sporttype = 1
					THEN ci.maxpermatch
				WHEN @isparlay = 0
					AND @sporttype = 2
					THEN ci.maxpermatch2
				WHEN @isparlay = 0
					AND @sporttype = 3
					THEN ci.maxpermatch3
				WHEN @isparlay = 0
					AND @sporttype = 5
					THEN ci.maxpermatch5
				WHEN @isparlay = 0
					AND @sporttype = 8
					THEN ci.maxpermatch8
				WHEN @isparlay = 0
					AND @sporttype = 10
					THEN ci.maxpermatch10
				WHEN @isparlay = 0
					AND @sporttype = 11
					THEN ci.maxpermatch11
				WHEN @isparlay = 0
					AND @sporttype = 161
					THEN ci.maxpermatch161
				WHEN @isparlay = 0
					AND @sporttype = 164
					AND @isLicensee = 0
					THEN 0
				WHEN @isparlay = 0
					AND @sporttype = 164
					AND @isLicensee = 1
					THEN ci.maxpermatch161
				WHEN @isparlay = 0
					AND @sporttype = 32
					THEN ci.maxpermatch2
				WHEN @isparlay = 0
					AND @sporttype = 44
					THEN ci.maxpermatch99
				WHEN @isparlay = 1
					AND @sporttype = 1
					THEN ci.maxpermatch1mp
				WHEN @isparlay = 1
					AND @sporttype = 2
					AND @bettype = 38
					THEN ci.maxpermatch99mp
				WHEN @isparlay = 1
					AND @sporttype = 99
					THEN ci.maxpermatch99mp
				ELSE ci.maxpermatch99
				END, 0)
		,@autosuspend = CASE 
			WHEN @sporttype = 1
				THEN Isnull(ci.autosuspend, @False)
			WHEN @isparlay = 1
				OR @sporttype IN (
					180
					,181
					,182
					,183
					,184
					,185
					,186
					,190
					,191
					,192
					,193
					,194
					,195
					,196
					,197
					)
				THEN @False
			ELSE Isnull(ci.autosuspend2, @False)
			END
		,@currency = ci.currency
		,@DisableBet = Isnull(CASE 
				WHEN @usertype = 2
					THEN @False
				WHEN @bettype = 10
					THEN ci.disableoutright
				WHEN @StructureVerBetSetting = 'DCS'
					THEN @DisBetSetting
				WHEN @sporttype IN (
						161
						,164
						)
					THEN ci.disablenumber
				WHEN @sporttype = 43
					THEN ci.disableesports
				WHEN @sporttype = 1
					AND @bettype IN (
						801
						,802
						,803
						,804
						,805
						,806
						)
					THEN ci.disablesuperlive
				ELSE @False
				END, @True) | @DisableSport
		,@closed = CASE 
			WHEN @usertype = 2
				THEN Isnull(ci.closed, @False) | @CN88_closed
			WHEN @isLicensee = 0
				THEN CASE 
						WHEN Isnull(cps.closeinfo, 0) > 0
							THEN 1
						ELSE 0
						END
			ELSE Isnull(ci.closed, @False)
			END
		,@reject = CASE 
			WHEN @DisableBet = @False
				THEN CASE 
						WHEN @isLicensee = 0
							THEN CASE 
									WHEN Isnull(cps.suspendinfo, 0) > 0
										THEN 1
									ELSE 0
									END
						WHEN @usertype = 2
							THEN @CN88_reject
						ELSE Isnull(ci.reject, @False)
						END
			ELSE @DisableBet
			END
		,@Locked = CASE 
			WHEN @isLicensee = 0
				THEN CASE 
						WHEN Isnull(cps.locked, 0) > 0
							THEN 1
						ELSE 0
						END
			ELSE 0
			END
	FROM custinfo AS ci WITH (NOLOCK)
	JOIN exchange AS ex WITH (NOLOCK) ON ci.currency = ex.exchangeid
	LEFT JOIN custproductstatus AS cps WITH (NOLOCK) ON ci.custid = cps.custid
	WHERE ci.custid = @custid

	------------------------------------------------
	-- 20181219@Vivi: add get UM flag
	IF @reject = @False
	BEGIN
		SELECT @UMRejectFlag = dbo.F_checkumstatus(@custid, @isLicensee)

		IF @UMRejectFlag = 1
			AND @currency <> 20
			AND @srecommend <> 72 --(@srecommend=72: Allbet Test)
		BEGIN
			SELECT @reject = @True
		END
	END

	------------------------------------------------
	IF @sporttype IN (44)
		AND @isLicensee = 0 --MuayThai for Credit
	BEGIN
		SELECT @MaxperMatch = Isnull(maxpermatch, @Zero)
		FROM dbo.custbetsetting3rd_member bs WITH (NOLOCK)
		WHERE bs.custid = @custid
			AND bs.bettype = 3
			AND bs.sporttype = @Sporttype
	END

	DECLARE @new_virtualrate FLOAT = 1

	IF @sporttype_vrate <= 99
		AND @BetFrom = 'z' --Desktop/ChinaView
		AND @isLicensee = 1
		AND @currencyname IN (
			'RMB'
			,'UUS'
			)
	BEGIN
		DECLARE @AdjustmentSporttype SMALLINT

		SELECT @AdjustmentSporttype = v.sporttype
		FROM vrcustautoadjustment v WITH (NOLOCK)
		WHERE v.sporttype IN (
				99
				,100
				)
			AND v.custid = @custid
			AND v.[status] = 1
			AND firstbetdate IS NULL

		IF @AdjustmentSporttype IN (
				99
				,100
				) --Update VR = 0 for Other Sports
		BEGIN
			DECLARE @ValueID_0 INT
			DECLARE @BasketBallLevelID INT
			DECLARE @tblVirtualrate TABLE (
				sporttype INT
				,bettype INT
				,islive BIT
				,virtualmultiplier SMALLMONEY
				);
			DECLARE @virtualXML TABLE (
				seqno TINYINT PRIMARY KEY
				,pos VARBINARY(64)
				,val VARBINARY(64)
				);

			--Update Status = 2
			UPDATE v
			SET v.[status] = 2
			FROM vrcustautoadjustment v WITH (ROWLOCK)
			WHERE v.sporttype = @AdjustmentSporttype
				AND v.custid = @custid
				AND v.[status] = 1
				AND FirstBetDate IS NULL

			----lock VR status Other sport
			IF NOT EXISTS (
					SELECT 1
					FROM vrcustlockstatus(NOLOCK)
					WHERE custid = @custid
						AND type = 2
					)
			BEGIN
				INSERT INTO vrcustlockstatus (
					custid
					,type
					)
				SELECT @custid
					,2
			END

			SELECT @ValueID_0 = valueid
			FROM vrvaluemapping WITH (NOLOCK)
			WHERE value = 1.00

			--Update VR = 0 for Basket Ball (using VR2)
			SELECT @BasketBallLevelID = levelid
			FROM vrsettinghierarchy WITH (NOLOCK)
			WHERE sporttype = 2
				AND vrleaguegroupid = - 1
				AND bettype = - 1

			IF EXISTS (
					SELECT 1
					FROM vrcustsetting WITH (NOLOCK)
					WHERE custid = @custid
						AND levelid = @BasketBallLevelID
					)
			BEGIN
				UPDATE v
				SET v.valueidlive = @ValueID_0
					,v.valueidnonlive = @ValueID_0
				FROM vrcustsetting v WITH (ROWLOCK)
				WHERE custid = @custid
					AND LevelID = @BasketBallLevelID
					AND (
						v.valueidlive != @ValueID_0
						OR v.valueidnonlive != @ValueID_0
						)
			END
			ELSE
			BEGIN
				INSERT INTO vrcustsetting (
					custid
					,levelid
					,valueidlive
					,valueidnonlive
					)
				VALUES (
					@custid
					,@BasketBallLevelID
					,@ValueID_0
					,@ValueID_0
					)
			END

			--Update VR = 0 for Other sports (using VR1)                
			INSERT INTO @tblVirtualrate (
				sporttype
				,bettype
				,islive
				,virtualmultiplier
				)
			SELECT sporttype
				,bettype
				,islive
				,1.00
			FROM profilevirtualsetting WITH (NOLOCK)
			WHERE sporttype NOT IN (
					1
					,2
					,43
					)

			IF @AdjustmentSporttype = 100 --Update VR = 0 for Soccer (using VR1)
			BEGIN
				INSERT INTO @tblVirtualrate (
					sporttype
					,bettype
					,islive
					,virtualmultiplier
					)
				SELECT sporttype
					,bettype
					,islive
					,1.00
				FROM profilevirtualsetting WITH (NOLOCK)
				WHERE sporttype = 1

				--lock VR status for Soccer
				IF NOT EXISTS (
						SELECT 1
						FROM vrcustlockstatus(NOLOCK)
						WHERE custid = @custid
							AND type = 1
						)
				BEGIN
					INSERT INTO vrcustlockstatus (
						custid
						,type
						)
					SELECT @custid
						,1
				END
			END

			INSERT INTO @virtualXML (
				seqno
				,pos
				,val
				)
			SELECT seqno
				,p1.pos
				,p2.val
			FROM (
				SELECT DISTINCT seqno
				FROM profilevirtualsetting WITH (NOLOCK)
				) pvs
			CROSS APPLY (
				SELECT CONVERT(VARBINARY(64), (
							SELECT CONVERT(VARCHAR, Cast(ipvs.profileid - 64 * (ipvs.seqno - 1) AS BINARY (1)), 2)
							FROM @tblVirtualrate AS tmp
							INNER JOIN profilevirtualsetting AS ipvs WITH (NOLOCK) ON tmp.sporttype = ipvs.sporttype
								AND tmp.bettype = ipvs.bettype
								AND tmp.islive = ipvs.islive
							WHERE ipvs.seqno = pvs.seqno
							FOR XML path('')
							), 2) AS Pos
				) p1
			CROSS APPLY (
				SELECT CONVERT(VARBINARY(64), (
							SELECT CONVERT(VARCHAR, Cast(CASE 
											WHEN Cast(virtualmultiplier * 100 AS INT) > 200
												THEN ((Cast(virtualmultiplier * 100 AS INT) - 200) / 5 + 200)
											ELSE Cast(virtualmultiplier * 100 AS INT)
											END AS BINARY (1)), 2)
							FROM @tblVirtualrate AS tmp
							INNER JOIN profilevirtualsetting AS ipvs WITH (NOLOCK) ON tmp.sporttype = ipvs.sporttype
								AND tmp.bettype = ipvs.bettype
								AND tmp.islive = ipvs.islive
							WHERE ipvs.seqno = pvs.seqno
							FOR XML path('')
							), 2) AS Val
				) p2;

			UPDATE cvs
			SET cvs.bitmapvirtual = bm.bitmap
			FROM custvirtualsetting AS cvs WITH (
					UPDLOCK
					,ROWLOCK
					)
			INNER JOIN @virtualXML AS tmp ON cvs.seqno = tmp.seqno
			CROSS APPLY (
				SELECT TOP 1 bitmap
				FROM dbo.F_generatevirtualsetting_inline(cvs.bitmapvirtual, tmp.val, tmp.pos)
				) AS bm
			WHERE cvs.custid = @custid
		END
	END

	SELECT @Site = Isnull(site, '')
		,@creatdate = creatdate
	FROM customer WITH (NOLOCK)
	WHERE custid = @custid

	SELECT @SiteID = siteid
	FROM site WITH (NOLOCK)
	WHERE site = @Site

	--#150298 Check Member meet with given credit and StakeRM condition to Set VR = 0
	IF EXISTS (
			SELECT 1
			FROM vrmemberbigstake WITH (NOLOCK)
			WHERE custid = @custid
				AND type = 1
				AND STATUS = 1
			)
	BEGIN
		SET @IsForcedVRValue = 0
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM dbo.F_getvrbigstakeconfig(@Site) cf
				WHERE cf.credit < @credit * (
						CASE 
							WHEN @currency <> 20
								THEN @actualrate
							ELSE 1
							END
						)
					AND stakerm < @StakeRM
					AND cf.type = 1
					AND cf.releaseddate <= @creatdate
				)
		BEGIN
			SET @IsForcedVRValue = 1

			SELECT @ForcedVRValue = vrvalue
			FROM dbo.F_getvrbigstakeconfig(@Site) cf
			WHERE cf.type = 1
		END
		ELSE
			SET @IsForcedVRValue = 0
	END

	IF @bettype <> 0
	BEGIN
		IF @sporttype = 1
		BEGIN
			IF @bettype NOT BETWEEN 801
					AND 806 --For Soccer, exclude SuperLive
			BEGIN
				EXEC Dot_member_customergetvirtualratebysportbettype @custid = @custid
					,@sporttype = @sporttype_vrate
					,@bettype = @bettype_vrate
					,@OriginalSportType = @sporttype
					,@OriginalBetType = @bettype
					,@isLive = @liveindicator
					,@isLicensee = @isLicensee
					,@LeagueGroupID = @LeagueGroupID
					,@IsApplyVR2 = @IsApplyVR2
					,@srecommend = @srecommend
					,@usertype = @usertype
					,@virtualMultiplier = @new_virtualrate OUT
					,@IsLowVR = @IsLowVR
					,@CustomerClass = @CustomerClass
					,@StakeRM = @StakeRM
					,@virtualrate = @virtualrate
					,@BetFrom = @BetFrom
					,@SiteID = @SiteID
					,@LeagueID = @LeagueID
					,@Istest = @Istest
			END
		END
		ELSE IF @sporttype IN (
				2
				,43
				) --For Esports/BasketBall, get VR2
		BEGIN
			EXEC Dot_member_customergetvirtualratebysportbettype @custid = @custid
				,@sporttype = @sporttype_vrate
				,@bettype = @bettype_vrate
				,@OriginalSportType = @sporttype
				,@OriginalBetType = @bettype
				,@isLive = @liveindicator
				,@isLicensee = @isLicensee
				,@LeagueGroupID = @LeagueGroupID
				,@srecommend = @srecommend
				,@virtualMultiplier = @new_virtualrate OUT
				,@usertype = @usertype
				,@RefLevelID = @RefLevelID
				,@IsLowVR = @IsLowVR
				,@CustomerClass = @CustomerClass
				,@StakeRM = @StakeRM
				,@BetFrom = @BetFrom
				,@SiteID = @SiteID
				,@LeagueID = @LeagueID
				,@Istest = @Istest
		END
		ELSE IF @virtualrate = 1 --For a remaining sport, get VR1
		BEGIN
			EXEC Dot_member_customergetvirtualratebysportbettype @custid = @custid
				,@sporttype = @sporttype_vrate
				,@bettype = @bettype_vrate
				,@OriginalSportType = @sporttype
				,@OriginalBetType = @bettype
				,@isLive = @liveindicator
				,@isLicensee = @isLicensee
				,@LeagueGroupID = @LeagueGroupID
				,@srecommend = @srecommend
				,@virtualMultiplier = @new_virtualrate OUT
				,@usertype = @usertype
				,@IsLowVR = @IsLowVR
				,@CustomerClass = @CustomerClass
				,@StakeRM = @StakeRM
				,@virtualrate = @virtualrate
				,@BetFrom = @BetFrom
				,@SiteID = @SiteID
				,@LeagueID = @LeagueID
				,@Istest = @Istest
		END

		IF @IsForcedVRValue = 1
			AND @sporttype NOT IN (
				2
				,43
				)
		BEGIN
			SET @new_virtualrate = CASE 
					WHEN @ForcedVRValue > Isnull(@new_virtualrate, 1)
						THEN @ForcedVRValue
					ELSE Isnull(@new_virtualrate, 1)
					END
		END

		SET @virtualrate = Isnull(@new_virtualrate, 1)
	END

	--Get Autosuspend (VR2)
	IF @sporttype IN (
			2
			,43
			)
		AND @isparlay = 0
	BEGIN
		SET @autosuspend = @False

		IF Isnull(@usertype, 0) <> 2 -- not CN88
		BEGIN
			SELECT @autosuspend = t.isvrautosuspend
			FROM [dbo].F_getvrautosuspendstatus_placebet(@custid, @sporttype_vrate, @bettype_vrate, @LeagueGroupID, @liveindicator, @virtualrate) t

			SET @autosuspend = Isnull(@autosuspend, @False)
		END
	END

	--Get data from DCS structure
	--IF (@StructureVerBetSetting='DCS')
	--BEGIN
	--  if (@SportTypeRefBetSetting<>0 and @BetTypeRefBetSetting <>0)
	--  begin
	--    if @isLicensee=0
	--    begin
	--      SELECT  @MaxperMatch = ISNULL(MaxPerMatch, @Zero)
	--      FROM dbo.CustBetSetting3rd_Member bs WITH (NOLOCK)
	--      WHERE bs.custid = @custid
	--         AND bs.BetType = @BetTypeRefBetSetting
	--         AND bs.SportType = @SportTypeRefBetSetting
	--    end else
	--    begin
	--      SELECT  @MaxperMatch = ISNULL(MaxPerMatch, @Zero)
	--      FROM dbo.Dep_CustBetSetting_Member bs WITH (NOLOCK)
	--      WHERE bs.custid = @custid
	--         AND bs.BetType = @BetTypeRefBetSetting
	--         AND bs.SportType = @SportTypeRefBetSetting
	--    end
	--  end else
	--  begin
	--    set @MaxperMatch=@Zero
	--  end
	--END
	SELECT @username username
		,@recommend recommend
		,@mrecommend mrecommend
		,@srecommend srecommend
		,@credit credit
		,@MaxPerBall161 MaxPerBall161
		,@actualrate actualrate
		,@currencyname currencyname
		,@virtualrate virtualrate
		,@maxpermatch maxpermatch
		,@autosuspend autosuspend
		,@currency currency
		,@closed closed
		,@reject reject
		,@DisableBet disabledBet
		,@DisBetSetting3rd DisBetSetting3rd
		,@BonusWalletFlag BonusWalletFlag
		,@MaxWinLimit MaxWinLimit
		,@MaxLossLimit MaxLossLimit
		,@Locked Locked
END