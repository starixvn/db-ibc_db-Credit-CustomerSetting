
/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustVirtualMultiplier_Sel]
	@CustID INT
	, @SportType INT
	, @ErrCode TINYINT OUT
	, @ErrMsg NVARCHAR(200) OUT
AS
/*    
	Created: 20190626@Dominic    
	Task :  Retrieve VR setting of an account for a specific sport  [Redmind: #114830]
	DB: CustDB@DBCUST
	    
	Revisions:    
		- 20190626@Dominic : First commit
  
*/ 
BEGIN
	SELECT @ErrCode = 0, @ErrMsg = ''

	DECLARE @RoleID INT, @recommend INT, @mrecommend INT, @srecommend INT, @Username NVARCHAR(50)
	DECLARE @ActualRate FLOAT, @Currency NVARCHAR(50), @UplineUsername NVARCHAR(50)
	DECLARE @UplineCustID INT
	
	SELECT @RoleID =roleid
			, @recommend = recommend, @mrecommend = mrecommend
			, @srecommend = srecommend
			, @ActualRate = e.actualrate
			, @Currency = e.currency
			, @Username = Username
	FROM Customer c (NOLOCK)
		INNER JOIN exchange e (NOLOCK) ON  e.exchangeid = c.currency  
	WHERE CustID = @CustID
		

	IF @CustID IS NULL OR (@CustID <> 0 AND @Currency IS NULL) 
	BEGIN
		SELECT @ErrCode = 1
		SELECT @ErrMsg = 'This account is not existing'
		RETURN
	END

	IF NOT EXISTS(
		SELECT 1 
		FROM [dbo].[VRSettingHierarchy] h (NOLOCK) 
			INNER JOIN [dbo].[VRCustSetting] vr ON vr.CustID = 0 AND vr.[LevelID] = h.[LevelID]
		WHERE h.[SportType] = @SportType
	)
	BEGIN
		SELECT @ErrCode = 2
		SELECT @ErrMsg = 'This SportType is not supported'
		RETURN
	END

	IF @RoleID = 1
		SELECT @UplineCustID = @recommend
	ELSE IF @RoleID = 2
		SELECT @UplineCustID = @mrecommend
	ELSE IF @RoleID = 3
		SELECT @UplineCustID = @srecommend
	ELSE IF @RoleID = 4
		SELECT @UplineCustID = 0

	SELECT @UplineUsername = username
	FROM customer (NOLOCK)
	WHERE CustID = @UplineCustID

	--1st Dataset: Cust/currency info
	SELECT @CustID CustID,@Username Username, @Currency Currency,@ActualRate ActualRate, @UplineCustID UplineCustID, @UplineUsername UplineUsername

	--2nd Dataset: Virtual Rate
	SELECT h.SportType
	, lg.GroupID LeagueGroupID, lg.GroupName LeagueGroup
	, bg.GroupID BettypeGroupID, bg.GroupName BettypeGroup
	, h.BetType BetTypeID
	, h.LevelID
	,ISNULL(ValueIDLIVE,0) ValueIDLIVE, vlive.Value ValueLIVE
	,ISNULL(ValueIDNonLIVE,0) ValueIDNonLIVE, vnonlive.Value ValueNonLIVE
	FROM VRSettingHierarchy h 
		LEFT JOIN VRLeagueGroup lg ON h.VRLeagueGroupID = lg.GroupID
		LEFT JOIN VRBettypeGroup bg ON h.VRBetTypeGroupID = bg.GroupID
		LEFT JOIN VRCustSetting vr (NOLOCK) 
			ON vr.CustID = @CustID
				AND vr.LevelID = h.LevelID
	LEFT JOIN VRValueMapping vlive ON vr.ValueIDLIVE = vlive.ValueID
	LEFT JOIN VRValueMapping vnonlive ON vr.ValueIDNonLIVE = vnonlive.ValueID
	WHERE h.SportType = @SportType
	ORDER BY lg.GroupName,bg.GroupName
END