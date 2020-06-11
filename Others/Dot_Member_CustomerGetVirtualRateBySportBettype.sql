/*<info serverAlias="DBCUST-CustDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_CustomerGetVirtualRateBySportBettype]
                    @CustID				INT,
                    @SportType			SMALLINT,
                    @BetType			SMALLINT,
					@OriginalSportType	SMALLINT = 0,
                    @OriginalBetType	SMALLINT = 0,
                    @isLive				BIT,
					@IsLicensee			BIT,
					@LeagueGroupID		SMALLINT = 0,
					@IsApplyVR2			BIT = 0,
					@srecommend         INT,
					@usertype			INT = 0, --0:default(MBC) 1:IMBC 2:CN88
                    @virtualMultiplier	SMALLMONEY	OUT,
					@RefLevelID			INT = NULL                    
AS
/*
    Created: 20151019@joy
    DB: DBCUST.CustDB
    Task: Select Virtual Rate from new table structure

    Revisions:
		- 20190701@VN-Dominic: Add a new input param @LeagueGroupID
					, and add a new different logic to get VR setting for E-sports
		- 20200116@VN-Elodie: Add a new different logic to get VR setting for Soccer
		- 20200203@VN-Elodie: Apply Currency Modifier
		-- 20200308@VN-Elodie: VR Setting for Soccer By Hours (6AM - 8PM GMT+8)
		-- 20200311@VN-Elodie: VR Setting for Soccer By Hours ( Weekends 6am - 8pm HK time and WEEKDAYS 6am - 1am HK time)
		-- 20200311@VN-Elodie: VR Setting for Soccer By Hours (WEEKENDS 6am - 8pm HK time, X=-3%, WEEKDAYS 6am - 8pm HK time, X = -3%, WEEKDAYS 8pm - 1am HK time, X = -2%)
		-- 20200512@VN-Eden: Disable VR setting of CN88 Customers [#133976]
		-- 20200511@VN-Eden: E-sport VR for Map X Overtime [#132517]

    Parameter's Explanation:
*/
BEGIN
    SET NOCOUNT ON
	DECLARE @VRLeagueGroupID SMALLINT, @CurrencyModifier SMALLMONEY = 1.00, @CurrentHKDate DATETIME, @CurrentHKTime TIME
	
	IF @SportType = 1
	BEGIN --For Soccer
		SELECT @virtualMultiplier = NULL
		IF @IsApplyVR2 = 0 --Get VR1
		BEGIN
			SELECT      @virtualMultiplier=dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID)
			FROM        CustVirtualSetting    	AS cvs WITH (NOLOCK)
			INNER JOIN  ProfileVirtualSetting   AS pvs WITH (NOLOCK)
					ON  cvs.seqNo = pvs.seqNo
			WHERE       cvs.custid = @CustID
					AND pvs.sporttype = @SportType
					AND pvs.bettype = @BetType
					AND pvs.islive = @isLive   
					AND pvs.isActive=1 

			SELECT @CurrentHKDate = DATEADD(HOUR, 12, GETDATE())
			SELECT @CurrentHKTime = CONVERT(VARCHAR(12),@CurrentHKDate,114)	
			
			IF @isLive = 1 AND @virtualMultiplier < 1 AND @usertype <> 2
			BEGIN
				IF @CurrentHKTime BETWEEN '06:00:00' AND '20:00:00'
				BEGIN
					SELECT @virtualMultiplier = @virtualMultiplier - 0.03
				END	

				IF DATENAME(DW,@CurrentHKDate) NOT IN ('Saturday','Sunday') AND (@CurrentHKTime BETWEEN '00:00:00' AND '01:00:00' OR @CurrentHKTime BETWEEN '20:00:00.001' AND '23:59:59.999')
				BEGIN
					SELECT @virtualMultiplier = @virtualMultiplier - 0.02
				END
			END
		END
		ELSE --Get VR2
		BEGIN
			--Base on @LeagueGroupID, get configured VRLeagueGroupID 
			SELECT @VRLeagueGroupID = VRLeagueGroupID
			FROM VRLeagueGroupMapping WITH (NOLOCK)
			WHERE LeagueGroupID = @LeagueGroupID

			--If LeagueGroupID and bettype are not configured for VR setting
			--then get setting on sport level
			IF NOT EXISTS(SELECT 1 FROM VRSettingHierarchy WITH (NOLOCK)
					WHERE VRLeagueGroupID=@VRLeagueGroupID 
					AND SportType=@OriginalSportType
					AND BetType = @OriginalBetType)
				SELECT @VRLeagueGroupID = -1, @OriginalBetType = -1 --Sport Level

			--Get VR multiplier
			;WITH VR_Hierachy AS (
				SELECT LevelID, ParentLevelID, 1 OrderNo
				FROM VRSettingHierarchy h WITH (NOLOCK)
				WHERE SportType = @OriginalSportType 
					AND BetType = @OriginalBetType
					AND VRLeagueGroupID = @VRLeagueGroupID
				UNION ALL
				SELECT c.LevelID, c.ParentLevelID, p.OrderNo + 1  OrderNo
				FROM VRSettingHierarchy c WITH (NOLOCK)
					INNER JOIN VR_Hierachy p on p.ParentLevelID = c.LevelID  -- this is the recursion, recursion depth is always 3
			) ,
			CustIDs AS (
				SELECT upv.Val CustID, ROW_NUMBER() OVER (ORDER BY (SELECT 0)) RoleID
				FROM (
					SELECT custid,recommend,mrecommend,srecommend,0 [Global]
					FROM Customer WITH (NOLOCK)
					WHERE CustID=@CustID
				) t
				UNPIVOT
				(
					Val
					FOR col IN (custid,recommend,mrecommend,srecommend,[Global])
				) upv
			)
			SELECT TOP 1 @virtualMultiplier = CASE WHEN @IsLive = 1 THEN vlive.Value ELSE vnonlive.Value END
			FROM VR_Hierachy h WITH (NOLOCK)
			CROSS JOIN CustIDs c WITH (NOLOCK)
			INNER JOIN VRCustSetting vr WITH (NOLOCK)
				ON vr.CustID = c.CustID
					AND vr.LevelID = h.LevelID
			INNER JOIN VRValueMapping vlive WITH (NOLOCK) ON vr.ValueIDLIVE = vlive.ValueID
			INNER JOIN VRValueMapping vnonlive WITH (NOLOCK) ON vr.ValueIDNonLIVE = vnonlive.ValueID
			WHERE CASE WHEN @IsLive = 1 THEN vlive.ValueID ELSE vnonlive.ValueID END > 0 --Exclude 'Follow parent'
			ORDER BY c.RoleID,h.OrderNo

			--IF @virtualMultiplier IS NULL --Get VR1
			--BEGIN
			--	SELECT      @virtualMultiplier=dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID)
			--	FROM        CustVirtualSetting    	AS cvs WITH (NOLOCK)
			--	INNER JOIN  ProfileVirtualSetting   AS pvs WITH (NOLOCK)
			--			ON  cvs.seqNo = pvs.seqNo
			--	WHERE       cvs.custid = @CustID
			--			AND pvs.sporttype = @SportType
			--			AND pvs.bettype = @BetType
			--			AND pvs.islive = @isLive   
			--			AND pvs.isActive=1 
			--END
		END		
	END


	ELSE IF @SportType NOT IN (43,1) --Not E-sports, Soccers
	BEGIN
		SELECT      @virtualMultiplier=dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID)
		FROM        CustVirtualSetting    	AS cvs WITH (NOLOCK)
		INNER JOIN  ProfileVirtualSetting   AS pvs WITH (NOLOCK)
				ON  cvs.seqNo = pvs.seqNo
		WHERE       cvs.custid = @CustID
				AND pvs.sporttype = @SportType
				AND pvs.bettype = @BetType
				AND pvs.islive = @isLive   
				AND pvs.isActive=1  
	END

	ELSE IF @SportType = 43
	BEGIN --For E-sports
		--Base on @LeagueGroupID, get configured VRLeagueGroupID 
		SELECT @VRLeagueGroupID = VRLeagueGroupID
		FROM VRLeagueGroupMapping WITH (NOLOCK)
		WHERE LeagueGroupID = @LeagueGroupID

		IF ISNULL(@RefLevelID,0) = 0
		BEGIN
			SELECT @RefLevelID = LevelID 
			FROM VRSettingHierarchy WITH (NOLOCK)
			WHERE VRLeagueGroupID=@VRLeagueGroupID 
				AND BetType = @Bettype
				AND SportType=@SportType

			IF ISNULL(@RefLevelID,0) = 0 
				SELECT @RefLevelID = 1	--Esport level	
		END
  
		--Get VR multiplier
		;WITH VR_Hierachy AS (
			SELECT LevelID, ParentLevelID, 1 OrderNo
			FROM VRSettingHierarchy h WITH (NOLOCK)
			WHERE LevelID = @RefLevelID
			UNION ALL
			SELECT c.LevelID, c.ParentLevelID, p.OrderNo + 1  OrderNo
			FROM VRSettingHierarchy c WITH (NOLOCK)
				INNER JOIN VR_Hierachy p on p.ParentLevelID = c.LevelID  -- this is the recursion, recursion depth is always 3
		) ,
		CustIDs AS (
			SELECT upv.Val CustID, ROW_NUMBER() OVER (ORDER BY (SELECT 0)) RoleID
			FROM (
				SELECT custid,recommend,mrecommend,srecommend,0 [Global]
				FROM Customer WITH (NOLOCK)
				WHERE CustID=@CustID
			) t
			UNPIVOT
			(
				Val
				FOR col IN (custid,recommend,mrecommend,srecommend,[Global])
			) upv
		)
		SELECT TOP 1 @virtualMultiplier = CASE WHEN @IsLive = 1 THEN vlive.Value ELSE vnonlive.Value END
		FROM VR_Hierachy h WITH (NOLOCK)
		CROSS JOIN CustIDs c WITH (NOLOCK)
		INNER JOIN VRCustSetting vr WITH (NOLOCK)
			ON vr.CustID = c.CustID
				AND vr.LevelID = h.LevelID
		INNER JOIN VRValueMapping vlive WITH (NOLOCK) ON vr.ValueIDLIVE = vlive.ValueID
		INNER JOIN VRValueMapping vnonlive WITH (NOLOCK) ON vr.ValueIDNonLIVE = vnonlive.ValueID
		WHERE CASE WHEN @IsLive = 1 THEN vlive.ValueID ELSE vnonlive.ValueID END > 0 --Exclude 'Follow parent'
		ORDER BY c.RoleID,h.OrderNo

	END
	
	IF @virtualMultiplier IS NULL OR @usertype = 2 --CN88
		SELECT @virtualMultiplier = 1

	--Apply Currency Modifier
	IF @IsLicensee = 0
	BEGIN
		SELECT @CurrencyModifier = CurrencyModifier FROM dbo.CustSuper WITH (NOLOCK) WHERE custid = @srecommend
	END
	ELSE
	BEGIN
		SELECT @CurrencyModifier = CurrencyModifier FROM dbo.Dep_CustSuper WITH (NOLOCK) WHERE custid = @srecommend
	END

	SELECT @virtualMultiplier = @virtualMultiplier * @CurrencyModifier
END
