/*<info serverAlias="DBCUST-CustDB" executers="svc_tig" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_CustomerGetVirtualRateBySportBettype]
                    @CustID					INT,
                    @SportType				SMALLINT,
                    @BetType				SMALLINT,
					@OriginalSportType		SMALLINT = 0,
                    @OriginalBetType		SMALLINT = 0,
                    @isLive					BIT,
					@IsLicensee				BIT,
					@LeagueGroupID			SMALLINT = 0,
					@IsApplyVR2				BIT = 0,
					@srecommend				INT,
					@usertype				INT = 0, --0:default(MBC) 1:IMBC 2:CN88
                    @virtualMultiplier		SMALLMONEY	OUT,
					@RefLevelID				INT = NULL,
					@IsLowVR				BIT = 0,
					@CustomerClass			SMALLINT = NULL,         
					@StakeRM				MONEY = NULL,
					@virtualrate			SMALLMONEY = NULL,
					@BetFrom				NVARCHAR(4) = '',
					@SiteID					INT = NULL,
					@LeagueID				INT = -1,
					@Istest				BIT = 0,
					@CurrencyID			INT = 0,
					@AccumulatedBalance	BIT = 0 OUTPUT,
					@CustomerClassDetail	SMALLINT = NULL,
					@CCSportType			SMALLINT = 0
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
		-- 20200625@VN-Eden: VR Setting for Soccer By Hours from 3AM to 6AM (GMT+8)[#136378]
		-- 20200702@VN-Eden: VR Setting for Soccer By Hours from 3AM to 6AM (GMT+8) - Credit Only (exclude CN88) [#136378]
		-- 20200703@VN-Eden: Control Virtual Rate for Soccer SET = -99% for member stake less than or equal to RM125 [#136990]
		-- 20200713@VN-Eden: VR Setting for Soccer By Hours from 3AM to 6AM (GMT+8) - Credit Only (exclude CN88) - REVOKE [#136378]
		-- 20200610@VN-Eden: Virtual Rate for Basketball [Redmine: #134978]
		-- 20200722@VN-Eden: VR setting for Basketball by member stake [Redmine: #138089]
		-- 20201014@VN-Eden: VR Setting for Soccer By Stake <= RM 80 [Redmine: #143314]
		-- 20201209@VN-Eden: VR Setting for Soccer By Hours (1AM - 6AM GMT+8) [Redmine: #146787]
		-- 20210427@VN-Eden: Implement dedicated feature to control Global Virtual Rate adjustment on tickets [Redmine:#136423]
		-- 20230307@VN-Johnson: Return Basketball VR to its original state [redmine:#184339]
		-- 20230421@VN-Elodie: Change data type of betfrom [Redmine:#177296]
		-- 20240328@VN-Luke: [NAP CM] VR Engine - Add in new criteria: Apply follow the VR accumulated balance, Currency [Redmine: #201333]
		-- 20240422@Winfred: [NAP CM] VR Engine - Allow to add CC by Sport, and re-arrange league group on dropdownlist [Redmine: #195539]

    Parameter's Explanation:
*/
BEGIN
    SET NOCOUNT ON
	DECLARE @VRLeagueGroupID SMALLINT, @CurrencyModifier SMALLMONEY = 1.00, @CurrentHKDate DATETIME, @CurrentHKTime TIME, @DateOfWeek TINYINT
	DECLARE @SiteType TINYINT
	
	IF @usertype = 2 --CN88 : Not apply VR
		GOTO ReturnVR;

	SELECT @StakeRM = ISNULL(@StakeRM,0),
		   @CustomerClass = ISNULL(@CustomerClass,0)

	SELECT @CurrentHKDate = DATEADD(HOUR, 12, GETDATE())
	SELECT @CurrentHKTime = CONVERT(VARCHAR(12),@CurrentHKDate,114)
	SELECT @DateOfWeek = DATEPART(DW,@CurrentHKDate)
	SELECT @SiteType = CASE WHEN @IsLicensee = 1 THEN 2 ELSE 1 END --1 : Credit, 2: Deposit
			
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

			IF @virtualMultiplier IS NULL
			BEGIN
				SELECT @virtualMultiplier = 1
				RETURN 
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
		END		
	END

	ELSE IF @SportType IN(43)
	BEGIN --For E-sports, BasketBall
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
				SELECT @RefLevelID = LevelID
				FROM VRSettingHierarchy c WITH(NOLOCK)
				WHERE c.SportType = @SportType 
					AND VRLeagueGroupID = -1 
					AND VRBetTypeGroupID = -1 
					AND BetType = -1 --Sporttype Level
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
	
	ELSE --Not E-sports, Soccers
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

	--Get VR on tickets by config table
	EXEC Dot_Member_GetVRSettingAdjustment
		 @Sporttype				= @OriginalSportType    
		,@Bettype				= @OriginalBetType      
		,@SiteType				= @SiteType     
		,@SiteID				= @SiteID       
		,@CustomerClass			= @CustomerClass
		,@DateOfWeek			= @DateOfWeek   
		,@LeagueGroupID			= @LeagueGroupID
		,@LeagueID				= @LeagueID     
		,@Betfrom				= @Betfrom      
		,@StakeRM				= @StakeRM      
		,@VRValue				= @virtualMultiplier OUTPUT   
		,@VRStatus				= @virtualrate     
		,@Time					= @CurrentHKTime         
		,@LiveIndicator			= @isLive
		,@Istest				= @Istest
		,@CurrencyID			= @CurrencyID
		,@AccumulatedBalance	= @AccumulatedBalance OUTPUT
		,@CCSporttype			= @CCSportType 
		,@CustomerClassDetail	= @CustomerClassDetail 

	ReturnVR:

	IF @virtualMultiplier IS NULL OR @usertype = 2 --CN88
		SELECT @virtualMultiplier = 1

	/*
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
	*/
END
GO
