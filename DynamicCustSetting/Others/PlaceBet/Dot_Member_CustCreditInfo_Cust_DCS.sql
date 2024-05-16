/*<info serverAlias="DBCUST-CustDB" executers="svc_tig" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_CustCreditInfo_Cust_DCS] @custid INT
			 
	,@sporttype SMALLINT
	,@PartnerID SMALLINT = NULL
	,@bettype SMALLINT = 0
	,@liveindicator BIT = 0
	,@isLicensee BIT = 0
	,@sporttype_vrate SMALLINT = 0
	,@bettype_vrate SMALLINT = 0
	,@LeagueGroupID SMALLINT = 0
	,@IsApplyVR2 BIT = 0
	,@RefLevelID INT = NULL
	,@IsLowVR BIT = 0
	,@BetFrom NVARCHAR(4) = ''
	,@CustomerClass SMALLINT = NULL
	,@StakeRM MONEY = NULL
	,@LeagueID INT = - 1
	,@CCsporttype SMALLINT
	,@CustomerClassDetail SMALLINT = NULL
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
        -- 20210309@VN-Eden: Revise @betfrom = 'a' to 'z' to VR setting for Basketball on some licensees from Desktop/China View [Redmine: #151392]
        -- 20210226@VN-Eden: Implement Lock for VR update [Redmine:#149370]
        -- 20210427@VN-Eden: Implement dedicated feature to control Global Virtual Rate adjustment on tickets [Redmine:#136423]
        -- 20210703@TW-Andy: Credit user lock account  suspend 	
        -- 20220419@TW-Xinxain: column add alias
		-- 20221226@TW-Andy: remove usage of column maxpermatch on [custInfo]
		-- 20230307@Johnson: add auto suspend for Basketball and return Basketball VR to its original state [redmine:#184339]
		-- 20230421@VN-Elodie: Change data type of betfrom [Redmine:#177296]
		-- 20230427@VN-Luke: Separate lock function for Basketball [Redmine: #185991]
		-- 20230616@TwYC(DBCust): Remove logic of [custinfo.disablenumber]
		-- 20240328@VN-Luke: [NAP CM] VR Engine - Add in new criteria: Apply follow the VR accumulated balance, Currency [Redmine: #201333]
		-- 20240422@VN-Winfred: [NAP CM] VR Engine - Allow to add CC by Sport, and re-arrange league group on dropdownlist [Redmine: #195539]

      */
	SET NOCOUNT ON;

	DECLARE @UMRejectFlag BIT = 0
	DECLARE @username NVARCHAR(50)
		,@recommend INT
		,@mrecommend INT
		,@srecommend INT
		,@credit MONEY
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
		,@WinMaxBetType SMALLINT
		,@DisBetSetting BIT
		,@BonusWalletFlag BIT
		,@False BIT = 0
		,@True BIT = 1
		,@Zero TINYINT = 0
		,@Site VARCHAR(10)
		,@IsForcedVRValue BIT
		,@ForcedVRValue SMALLMONEY
		,@creatdate DATETIME
		,@SiteID INT
		,@Istest BIT
		,@Locked BIT = 0
		,@AccumulatedBalance BIT = 0

	SELECT @Istest = CASE 
			WHEN (
					Object_name(@@PROCID) LIKE '%[_]xtest%'
					OR Object_name(@@PROCID) LIKE '%[_]xpre%'
					OR Object_name(@@PROCID) LIKE '%[_]uat[1-9]%'
					)
				THEN 1
			ELSE 0
			END

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
	SET @DisBetSetting = 0

	DECLARE @tmp TABLE (
		ishidden BIT
		,isdisabled BIT
		)

	IF (@sporttype = 44)
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

	DECLARE @DisableSport BIT

	SELECT @DisableSport = dbo.F_disablesport(@sporttype)

	SELECT @username = ci.username
		,@recommend = ci.recommend
		,@mrecommend = ci.mrecommend
		,@srecommend = ci.srecommend
		,@credit = ci.credit
		,@actualrate = ex.actualrate
		,@currencyname = ex.currency
		,@virtualrate = ci.virtualmultiplier
		,@BonusWalletFlag = Isnull(ci.bonuswalletflag, @False)
		,@maxpermatch = @Zero
		,@autosuspend = CASE 
			WHEN @sporttype = 1
				THEN Isnull(ci.autosuspend, @False)
			WHEN @sporttype = 2
				THEN Isnull(ci.autosuspend3, @False)	
					--when @sporttype in (180,181,182,183,184,185,186) then 0
			ELSE Isnull(ci.autosuspend2, @False)
			END
		,@currency = ci.currency
		,@DisableBet = Isnull(CASE 
				WHEN @sporttype = 43
					THEN ci.disableesports
				WHEN @sporttype = 44
					THEN @DisBetSetting
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
				ELSE 0
				END, 1) | @DisableSport
		,@closed = CASE 
			WHEN @isLicensee = 0
				THEN CASE 
						WHEN Isnull(cps.closeinfo, 0) > 0
							THEN 1
						ELSE 0
						END
			ELSE Isnull(ci.closed, 0)
			END
		,@reject = CASE 
			WHEN @DisableBet = 0
				THEN CASE 
						WHEN @isLicensee = 0
							THEN CASE 
									WHEN Isnull(cps.suspendinfo, 0) > 0
										THEN 1
									ELSE 0
									END
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

			--lock VR status Basketball
			IF NOT EXISTS (
					SELECT 1
					FROM vrcustlockstatus(NOLOCK)
					WHERE custid = @custid
						AND type = 3
					)
			BEGIN
				INSERT INTO vrcustlockstatus (
					custid
					,type
					)
				SELECT @custid
					,3
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
			WHERE sporttype NOT IN (1,43)

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

			SELECT @ForcedVRValue = VRValue
			FROM dbo.f_GetVRBigStakeConfig(@Site) cf
			WHERE cf.Type = 1
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
					,@virtualMultiplier = @new_virtualrate OUT
					,@IsLowVR = @IsLowVR
					,@CustomerClass = @CustomerClass
					,@StakeRM = @StakeRM
					,@virtualrate = @virtualrate
					,@BetFrom = @BetFrom
					,@SiteID = @SiteID
					,@LeagueID = @LeagueID
					,@Istest = @Istest
					,@CurrencyID = @currency
					,@AccumulatedBalance = @AccumulatedBalance OUTPUT
					,@CCSportType = @CCSportType
					,@CustomerClassDetail = @CustomerClassDetail
			END
		END
		ELSE IF @sporttype = 43 --For Esports, get VR2
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
				,@RefLevelID = @RefLevelID
				,@IsLowVR = @IsLowVR
				,@CustomerClass = @CustomerClass
				,@StakeRM = @StakeRM
				,@BetFrom = @BetFrom
				,@SiteID = @SiteID
				,@LeagueID = @LeagueID
				,@Istest = @Istest
				,@CurrencyID = @currency
				,@AccumulatedBalance = @AccumulatedBalance OUTPUT
				,@CCSportType = @CCSportType
				,@CustomerClassDetail = @CustomerClassDetail
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
				,@IsLowVR = @IsLowVR
				,@CustomerClass = @CustomerClass
				,@StakeRM = @StakeRM
				,@virtualrate = @virtualrate
				,@BetFrom = @BetFrom
				,@SiteID = @SiteID
				,@LeagueID = @LeagueID
				,@Istest = @Istest
				,@CurrencyID = @currency
				,@AccumulatedBalance = @AccumulatedBalance OUTPUT
				,@CCSportType = @CCSportType
				,@CustomerClassDetail = @CustomerClassDetail
		END

		IF @IsForcedVRValue = 1 AND @sporttype NOT IN (43)
		BEGIN
			SET @new_virtualrate = CASE 
					WHEN @ForcedVRValue > Isnull(@new_virtualrate, 1)
						THEN @ForcedVRValue
					ELSE Isnull(@new_virtualrate, 1)
					END
		END

		SET @virtualrate = Isnull(@new_virtualrate, 1)
	END

	--Get data from DCS structure
	IF @sporttype IN (44)
		AND @isLicensee = 0 --MuayThai for Credit
	BEGIN
		SELECT @MaxperMatch = Isnull(maxpermatch, @Zero)
		FROM dbo.custbetsetting3rd_member bs WITH (NOLOCK)
		WHERE bs.custid = @custid
			AND bs.bettype = 3
			AND bs.sporttype = @Sporttype
	END
 
	SELECT @username username
		,@recommend recommend
		,@mrecommend mrecommend
		,@srecommend srecommend
		,@credit credit
		,@actualrate actualrate
		,@currencyname currencyname
		,@virtualrate virtualrate
		,@maxpermatch maxpermatch
		,@autosuspend autosuspend
		,@currency currency
		,@closed closed
		,@reject reject
		,@DisableBet DisabledBet
		,@BonusWalletFlag BonusWalletFlag
		,@Locked Locked
		,@AccumulatedBalance AccumulatedBalance
END
