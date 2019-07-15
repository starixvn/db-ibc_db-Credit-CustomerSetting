USE [CustDB]
GO

ALTER PROCEDURE [dbo].[Dot_Member_CustomerGetVirtualRateBySportBettype]
                    @CustID     INT,
                    @SportType  SMALLINT,
                    @BetType    SMALLINT,
                    @isLive     BIT,
					@LeagueGroupID SMALLINT = 0,
                    @virtualMultiplier Smallmoney out
                    
AS
    /*
        Created: 20151019@joy
        DB: DBCUST.CustDB
        Task: Select Virtual Rate from new table structure

        Revisions:
			- 20190701@VN-Dominic: Add a new input param @LeagueGroupID
						, and add a new different logic to get VR setting for E-sports
        Parameter's Explanation:
    */
BEGIN
    SET NOCOUNT ON

	IF @SportType <> 43 --Not E-sports
	BEGIN
		SELECT      @virtualMultiplier=dbo.f_GetVirtualSetting(cvs.bitmapVirtual, pvs.profileID)
		FROM        CustVirtualSetting    	AS cvs WITH(NOLOCK)
		INNER JOIN  ProfileVirtualSetting   AS pvs WITH(NOLOCK)
				ON  cvs.seqNo = pvs.seqNo
		WHERE       cvs.custid = @CustID
				AND pvs.sporttype = @SportType
				AND pvs.bettype = @BetType
				AND pvs.islive = @isLive   
				AND pvs.isActive=1  
	END
	ELSE
	BEGIN --For E-sports
		DECLARE @VRLeagueGroupID SMALLINT

		--Base on @LeagueGroupID, get configured VRLeagueGroupID 
		SELECT @VRLeagueGroupID = VRLeagueGroupID
		FROM VRLeagueGroupMapping (NOLOCK)
		WHERE LeagueGroupID = @LeagueGroupID

		--If a LeagueGroup is not configured for VR yet, then follow 'Other Games' VR group
		--We temporarily hard-code because we expect all LeagueGroups must be configured for VR before allowing members to place bet
		IF @VRLeagueGroupID IS NULL
			SELECT @VRLeagueGroupID = 5 --Other Games

		--If Original Bettype is not configured for VR, then follow 'Not Available' value (-1)
		IF NOT EXISTS(SELECT 1 FROM VRSettingHierarchy(NOLOCK) 
				WHERE VRLeagueGroupID=@VRLeagueGroupID 
				AND SportType=@SportType
				AND BetType = @Bettype)
			SELECT @Bettype = -1 --League Group Level

		--If VRLeagueGroupID and Bettype are both not configured for VR, then follow E-sports setting level
		IF NOT EXISTS(SELECT 1 FROM VRSettingHierarchy(NOLOCK) 
				WHERE VRLeagueGroupID=@VRLeagueGroupID 
				AND SportType=@SportType
				AND BetType = @Bettype)
			SELECT @VRLeagueGroupID = -1, @Bettype = -1 --Sport Level

		--Get VR multiplier
		;WITH VR_Hierachy AS (
			SELECT LevelID, ParentLevelID, 1 OrderNo
			FROM VRSettingHierarchy h
			WHERE SportType = @SportType 
				AND BetType = @Bettype
				AND VRLeagueGroupID = @VRLeagueGroupID
			UNION ALL
			SELECT c.LevelID, c.ParentLevelID, p.OrderNo + 1  OrderNo
			FROM VRSettingHierarchy c
				INNER JOIN VR_Hierachy p on p.ParentLevelID = c.LevelID  -- this is the recursion, recursion depth is always 3
		) ,
		CustIDs AS (
			SELECT upv.Val CustID, ROW_NUMBER() OVER (ORDER BY (SELECT 0)) RoleID
			FROM (
				SELECT custid,recommend,mrecommend,srecommend,0 [Global]
				FROM Customer (NOLOCK)
				WHERE CustID=@CustID
			) t
			UNPIVOT
			(
				Val
				FOR col IN (custid,recommend,mrecommend,srecommend,[Global])
			) upv
		)
		SELECT TOP 1 @virtualMultiplier = CASE WHEN @IsLive = 1 THEN vlive.Value ELSE vnonlive.Value END
		FROM VR_Hierachy h
		CROSS JOIN CustIDs c (NOLOCK)
		INNER JOIN VRCustSetting vr (NOLOCK) 
			ON vr.CustID = c.CustID
				AND vr.LevelID = h.LevelID
		INNER JOIN VRValueMapping vlive ON vr.ValueIDLIVE = vlive.ValueID
		INNER JOIN VRValueMapping vnonlive ON vr.ValueIDNonLIVE = vnonlive.ValueID
		WHERE CASE WHEN @IsLive = 1 THEN vlive.ValueID ELSE vnonlive.ValueID END > 0 --Exclude 'Follow parent'
		ORDER BY c.RoleID,h.OrderNo

		IF @virtualMultiplier IS NULL
			SELECT @virtualMultiplier = 1
	END
END