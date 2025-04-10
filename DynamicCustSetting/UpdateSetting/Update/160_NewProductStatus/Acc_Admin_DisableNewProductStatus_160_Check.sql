/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatus_160_Check] 
	  @IsDisabled		VARCHAR(MAX)
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @GroupID			TINYINT		= 3
	, @GroupType		TINYINT		= 160
	, @siteid			SMALLINT
	, @Currency			INT
	, @ErrCode			INT			= 0		OUTPUT
	, @MsgType			INT			= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''		OUTPUT
	, @CustID			INT			= NULL
	, @SettingStatus		TINYINT		= 0
AS
/*
	Created: 20240216@Helios
	Task : Validate enabled status
	DB: DBCUST/CustDB
	Original:
		Acc_Admin_DisableNewProductStatusCheck
	Revision: 
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]  
		- 20250410@Johnson: change datatype for ExchangeID[redmine: #223630]
	Param's Explanation:
	@IsDisabled
		[
			{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" , "UpdateAllSuperDirectMembers":"0" , "DisableAllSuperDirectMembers":"0" , "UpdateAllMasterDirectMembers":"0" , "DisableAllMasterDirectMembers":"0" }, 
			{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" , "UpdateAllSuperDirectMembers":"0" , "DisableAllSuperDirectMembers":"0" , "UpdateAllMasterDirectMembers":"0" , "DisableAllMasterDirectMembers":"0" }, 
			{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" , "UpdateAllSuperDirectMembers":"0" , "DisableAllSuperDirectMembers":"0" , "UpdateAllMasterDirectMembers":"0" , "DisableAllMasterDirectMembers":"0" }, 
			{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" , "UpdateAllMasters":"1" , "UpdateAllAgents":"1" , "UpdateAllMembers":"1" , "DisableAllMasters":"0" , "DisableAllAgents":"0" , "DisableAllMembers":"0" , "UpdateAllSuperDirectMembers":"0" , "DisableAllSuperDirectMembers":"0" , "UpdateAllMasterDirectMembers":"0" , "DisableAllMasterDirectMembers":"0" }	
		]
	• @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
	*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #NewDisableStatTblCheck
	(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents			BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
			, ParentSporttype			SMALLINT
			, ParentBetType			SMALLINT
			, UpdateAllSuperDirectMembers	BIT
			, DisableAllSuperDirectMembers	BIT
			, UpdateAllMasterDirectMembers	BIT
			, DisableAllMasterDirectMembers BIT
	)
	CREATE TABLE #OldDisableStatTbl 
	(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents			BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
			, UpdateAllSuperDirectMembers		BIT
			, DisableAllSuperDirectMembers	BIT
			, UpdateAllMasterDirectMembers	BIT
			, DisableAllMasterDirectMembers	BIT
	)
	CREATE TABLE #ErrorSportTypeTbl
	(
			 SportType				SMALLINT
			, BetType				SMALLINT
			, MsgID				INT
			, ParentSporttype			SMALLINT
			, ParentBetType			SMALLINT
			, SettingLevel			TINYINT
	)
	DECLARE @xml XML, @iDoc INT

	SELECT @ErrCode = 0
		, @ErrMsg	= ''

	INSERT INTO #NewDisableStatTblCheck(
		  SportType			
		, BetType			
		, IsDisabled		
		, UpdateAllMasters	
		, UpdateAllAgents	
		, UpdateAllMembers	
		, DisableAllMasters	
		, DisableAllAgents	
		, DisableAllMembers
		, UpdateAllSuperDirectMembers
		, DisableAllSuperDirectMembers
		, UpdateAllMasterDirectMembers
		, DisableAllMasterDirectMembers
	)
	SELECT SportType, BetType, IsDisabled, UpdateAllMasters, UpdateAllAgents, UpdateAllMembers,DisableAllMasters,DisableAllAgents,DisableAllMembers,UpdateAllSuperDirectMembers,DisableAllSuperDirectMembers,UpdateAllMasterDirectMembers,DisableAllMasterDirectMembers
	FROM OPENJSON(@IsDisabled)
	WITH 
		(	SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents			BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
			, UpdateAllSuperDirectMembers  BIT
			, DisableAllSuperDirectMembers BIT
			, UpdateAllMasterDirectMembers BIT
			, DisableAllMasterDirectMembers BIT
		) AS DisabledProductStatus

	IF @RoleID = 4
		SET @custID = @SuperID
	IF @RoleID = 3
		SET @custID = @MasterID
	IF @RoleID = 2
		SET @custID = @AgentID

	CREATE TABLE #ProductSettingDetail_Check(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[Parent_ProductSettingID] [int],
		[ProductSettingID] [int],
		[SettingLevel]	  [TINYINT],
		[ProductID]		[TINYINT]
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,SettingLevel,ProductID)
	SELECT SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,SettingLevel,ProductID
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM #NewDisableStatTblCheck t
		INNER JOIN #ProductSettingDetail_Check ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer 

	--Get error data
	--60033: Account disabled for this product. Unable to edit downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 0)
	BEGIN
	
		IF @RoleID = 3 OR (@RoleID = 1 AND @AgentID = -4)
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
		END
		ELSE IF @RoleID = 2 OR (@RoleID = 1 AND @AgentID = -3)
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @MasterID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
		END
		ELSE IF @RoleID = 1 AND @AgentID NOT IN (-4,-3)
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @AgentID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
		END
	END

	--90012: You are not allowed to perform this action.
	--Update disable of upline and not update for downline
	IF EXISTS 
	(SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 1 AND 
		(
			((UpdateAllMasters = 0 OR UpdateAllSuperDirectMembers = 0) AND @RoleID = 4) OR 
			((UpdateAllAgents = 0 OR UpdateAllMasterDirectMembers = 0) AND @RoleID IN (4,3)) OR 
			(UpdateAllMembers = 0 AND @RoleID IN (4,3,2))
		)
	)	
	BEGIN
		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
		SELECT tmp.SportType
			, tmp.BetType
			, 90012 AS MsgID
		FROM #NewDisableStatTblCheck tmp
		WHERE IsDisabled = 1 AND (
							((UpdateAllMasters = 0 OR UpdateAllSuperDirectMembers = 0) AND @RoleID = 4) OR 
							((UpdateAllAgents = 0 OR UpdateAllMasterDirectMembers = 0) AND @RoleID IN (4,3)) OR 
							(UpdateAllMembers = 0 AND @RoleID IN (4,3,2))
						)
	END

	--90012: You are not allowed to perform this action.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 1 AND ((UpdateAllMasters = 1 AND DisableAllMasters = 0) OR (UpdateAllSuperDirectMembers = 1 AND DisableAllSuperDirectMembers = 0))) 
	BEGIN
		IF @RoleID = 4--disable super and enable master
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE UpdateAllMasters = 1 AND DisableAllMasters = 0 AND IsDisabled = 1

			-- Add new for SuperDirectMember
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE UpdateAllSuperDirectMembers = 1 AND DisableAllSuperDirectMembers = 0 AND IsDisabled = 1
		END
	END
	
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE (UpdateAllAgents = 1 AND DisableAllAgents = 0) OR (UpdateAllMasterDirectMembers = 1 AND DisableAllMasterDirectMembers = 0)) 
	BEGIN
	
		IF @RoleID = 4--(disable super/disable master) and enable agent
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
			WHERE UpdateAllAgents = 1 AND DisableAllAgents = 0
				AND (IsDisabled = 1
					OR EXISTS (	SELECT TOP 1 1 
								FROM dbo.CustProductStatus stMaster WITH (NOLOCK)
									INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = stMaster.CustID
								WHERE ci.srecommend = @SuperID AND ci.roleid = 3
									AND ((dbo.f_GetProductStatus(stMaster.bitmapIsDisabled, PSP.bitmapOrder) = 1 AND tmp.UpdateAllMasters = 0)
										OR (tmp.UpdateAllMasters = 1 AND tmp.DisableAllMasters = 1))))

			--(disable super/disable master) and enable MasterDirectMember
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
			WHERE tmp.UpdateAllMasterDirectMembers = 1 AND tmp.DisableAllMasterDirectMembers = 0
				AND (IsDisabled = 1
					OR EXISTS (	SELECT TOP 1 1 
								FROM dbo.CustProductStatus stMaster WITH (NOLOCK)
									INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = stMaster.CustID
								WHERE ci.srecommend = @SuperID AND ci.roleid = 3
									AND ((dbo.f_GetProductStatus(stMaster.bitmapIsDisabled, PSP.bitmapOrder) = 1 AND tmp.UpdateAllMasters = 0)
										OR (tmp.UpdateAllMasters = 1 AND tmp.DisableAllMasters = 1))))
		END
		ELSE IF @RoleID = 3--disable master and enable agent
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
			WHERE UpdateAllAgents = 1 AND DisableAllAgents = 0 AND IsDisabled = 1
			
			--disable master and enable MasterDirectMember
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
			WHERE tmp.UpdateAllMasterDirectMembers = 1 AND tmp.DisableAllMasterDirectMembers = 0 AND IsDisabled = 1
		END	
	END

	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE UpdateAllMembers = 1 AND DisableAllMembers = 0)
	BEGIN
	
		IF @RoleID = 4 --(disable super/disable master/disable agent) and enable member
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
			WHERE UpdateAllMembers = 1 AND DisableAllMembers = 0
				AND (IsDisabled = 1
					OR EXISTS (	SELECT TOP 1 1 
								FROM dbo.CustProductStatus stMaster WITH (NOLOCK)
									INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = stMaster.CustID
								WHERE ci.srecommend = @SuperID AND ci.roleid = 3
									AND ((dbo.f_GetProductStatus(stMaster.bitmapIsDisabled, PSP.bitmapOrder) = 1 AND tmp.UpdateAllMasters = 0)
										OR (tmp.UpdateAllMasters = 1 AND tmp.DisableAllMasters = 1))
								)
					OR EXISTS (	SELECT TOP 1 1 
								FROM dbo.CustProductStatus stAgent WITH (NOLOCK)
									INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = stAgent.CustID
								WHERE ci.srecommend = @SuperID AND ci.roleid = 2
									AND ((dbo.f_GetProductStatus(stAgent.bitmapIsDisabled, PSP.bitmapOrder) = 1 AND tmp.UpdateAllAgents = 0)
										OR (tmp.UpdateAllAgents = 1 AND tmp.DisableAllAgents = 1))
								)
					)
		END
		ELSE IF @RoleID = 3--(disable master/disable agent) and enable member
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stMaster WITH (NOLOCK) ON  stMaster.CustID	= @MasterID
			WHERE UpdateAllMembers = 1 AND DisableAllMembers = 0
				AND (IsDisabled = 1
					OR EXISTS (	SELECT TOP 1 1 
								FROM dbo.CustProductStatus stAgent WITH (NOLOCK)
									INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = stAgent.CustID
								WHERE ci.mrecommend = @MasterID AND ci.srecommend = @SuperID AND ci.roleid = 2
									AND ((dbo.f_GetProductStatus(stAgent.bitmapIsDisabled, PSP.bitmapOrder) = 1 AND tmp.UpdateAllAgents = 0)
										OR (tmp.UpdateAllAgents = 1 AND tmp.DisableAllAgents = 1))
								)
					)
				
		END
		ELSE IF @RoleID = 2--disable agent and enable member
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 90012 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
			WHERE UpdateAllMembers = 1 AND DisableAllMembers = 0 AND IsDisabled = 1
		END	
	END

	--IF there's no error data then return
	IF EXISTS (
			SELECT TOP 1 1
			FROM #ErrorSportTypeTbl
			)
	BEGIN
		GOTO RETURNTBL;
	END

	--IF @Settingtype = 21 -- Check status dependency
	--BEGIN
		UPDATE t 
		SET t.ParentSporttype = par.SportType, t.ParentBetType = par.BetType
		FROM #NewDisableStatTblCheck t
			INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
				ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
			INNER JOIN #ProductSettingDetail_Check par WITH(NOLOCK) 
				ON d.Parent_ProductSettingID = par.ProductSettingID

		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
		SELECT TOP(1) t.SportType
				, t.BetType
				, 60037 AS MsgID
				, t.ParentSporttype
				, t.ParentBetType
		FROM #NewDisableStatTblCheck t
			LEFT JOIN #NewDisableStatTblCheck par 
				ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType
			INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
				ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = @custID
			CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
		WHERE t.IsDisabled < ISNULL(par.IsDisabled,s.value)

		IF @@ROWCOUNT > 0
		BEGIN
			GOTO RETURNTBL;
		END
		
		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
		SELECT TOP(1) t.SportType
				, t.BetType
				, 60037 AS MsgID
				, t.ParentSporttype
				, t.ParentBetType
		FROM #NewDisableStatTblCheck t
			INNER JOIN #NewDisableStatTblCheck par 
				ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType
		WHERE (t.UpdateAllMasters = 1 AND t.DisableAllMasters = 0 AND par.DisableAllMasters = 1)
			OR (t.UpdateAllAgents = 1 AND t.DisableAllAgents = 0 AND par.DisableAllAgents = 1)
			OR (t.UpdateAllMembers = 1 AND t.DisableAllMembers = 0 AND par.DisableAllMembers = 1)
			OR (t.UpdateAllSuperDirectMembers = 1 AND t.DisableAllSuperDirectMembers = 0 AND par.DisableAllSuperDirectMembers = 1)
			OR (t.UpdateAllMasterDirectMembers = 1 AND t.DisableAllMasterDirectMembers = 0 AND par.DisableAllMasterDirectMembers = 1)

		IF @@ROWCOUNT > 0
		BEGIN
			GOTO RETURNTBL;
		END

		IF @RoleID = 4
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) t.SportType
					, t.BetType
					, 60037 AS MsgID
					, t.ParentSporttype
					, t.ParentBetType
			FROM #NewDisableStatTblCheck t
				LEFT JOIN #NewDisableStatTblCheck par 
					ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType AND par.UpdateAllMasters = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
				CROSS APPLY (   SELECT TOP 1 1 AS IsDisabled
								FROM custInfo ci WITH(NOLOCK) 
									INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
									CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
								WHERE ci.srecommend = @custID
									AND roleid = 3
									AND s.value = 1
									AND par.SportType IS NULL
									AND t.UpdateAllMasters = 1 
									AND t.DisableAllMasters = 0 
							) st -- check if any disabled Master

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) t.SportType
					, t.BetType
					, 60037 AS MsgID
					, t.ParentSporttype
					, t.ParentBetType
			FROM #NewDisableStatTblCheck t
				LEFT JOIN #NewDisableStatTblCheck par 
					ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType AND par.UpdateAllAgents = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
				CROSS APPLY (   SELECT TOP 1 1 AS IsDisabled
								FROM custInfo ci WITH(NOLOCK) 
									INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
									CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
								WHERE ci.srecommend = @custID
									AND roleid = 2
									AND s.value = 1
									AND par.SportType IS NULL
									AND t.UpdateAllAgents = 1 
									AND t.DisableAllAgents = 0 
							) st -- check if any disabled Agent

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) t.SportType
					, t.BetType
					, 60037 AS MsgID
					, t.ParentSporttype
					, t.ParentBetType
			FROM #NewDisableStatTblCheck t
				LEFT JOIN #NewDisableStatTblCheck par 
					ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType AND (par.UpdateAllMembers = 1 OR par.UpdateAllSuperDirectMembers = 1 OR par.UpdateAllMasterDirectMembers = 1)
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
				CROSS APPLY (   SELECT TOP 1 1 AS IsDisabled
								FROM custInfo ci WITH(NOLOCK) 
									INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
									CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
								WHERE ci.srecommend = @custID
									AND roleid = 1
									AND s.value = 1
									AND par.SportType IS NULL
									AND (
											(t.UpdateAllMembers = 1 AND t.DisableAllMembers = 0)
										OR	(t.UpdateAllSuperDirectMembers = 1 AND t.DisableAllSuperDirectMembers = 0)
										OR	(t.UpdateAllMasterDirectMembers = 1 AND t.DisableAllMasterDirectMembers = 0)
									     )

							) st -- check if any disabled Member
				
			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) t.SportType
					, t.BetType
					, 60037 AS MsgID
					, t.ParentSporttype
					, t.ParentBetType
			FROM #NewDisableStatTblCheck t
				LEFT JOIN #NewDisableStatTblCheck par 
					ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType AND par.UpdateAllAgents = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
				CROSS APPLY (   SELECT TOP 1 1 AS IsDisabled
								FROM custInfo ci WITH(NOLOCK) 
									INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
									CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
								WHERE ci.mrecommend = @custID
									AND roleid = 2
									AND s.value = 1
									AND par.SportType IS NULL
									AND t.UpdateAllAgents = 1 
									AND t.DisableAllAgents = 0 
							) st -- check if any disabled Agent

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) t.SportType
					, t.BetType
					, 60037 AS MsgID
					, t.ParentSporttype
					, t.ParentBetType
			FROM #NewDisableStatTblCheck t
				LEFT JOIN #NewDisableStatTblCheck par 
					ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType AND (par.UpdateAllMembers = 1 OR par.UpdateAllMasterDirectMembers = 1 )
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
				CROSS APPLY (   SELECT TOP 1 1 AS IsDisabled
								FROM custInfo ci WITH(NOLOCK) 
									INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
									CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
								WHERE ci.mrecommend = @custID
									AND roleid = 1
									AND s.value = 1
									AND par.SportType IS NULL
									AND (
										(t.UpdateAllMembers = 1 AND t.DisableAllMembers = 0)
										OR
										(t.UpdateAllMasterDirectMembers = 1 AND t.DisableAllMasterDirectMembers = 0)
									    )
							) st -- check if any disabled Member
				
			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END
		END
		ELSE IF @RoleID = 2
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) t.SportType
					, t.BetType
					, 60037 AS MsgID
					, t.ParentSporttype
					, t.ParentBetType
			FROM #NewDisableStatTblCheck t
				LEFT JOIN #NewDisableStatTblCheck par 
					ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType AND par.UpdateAllMembers = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
				CROSS APPLY (   SELECT TOP 1 1 AS IsDisabled
								FROM custInfo ci WITH(NOLOCK) 
									INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
									CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
								WHERE ci.recommend = @custID
									AND roleid = 1
									AND s.value = 1
									AND par.SportType IS NULL
									AND t.UpdateAllMembers = 1 
									AND t.DisableAllMembers = 0 
							) st -- check if any disabled Member
				
			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END
		END

		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
		SELECT TOP(1) de.SportType
				, de.BetType
				, 60037 AS MsgID
				, t.Sporttype AS ParentSporttype
				, t.BetType AS ParentBetType
		FROM #NewDisableStatTblCheck t
			INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
				ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
			INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
				ON d.ProductSettingID = de.Parent_ProductSettingID 
			LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
				ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType
			INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
				ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = @custID
			CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
		WHERE tempde.SportType IS NULL 
			AND t.IsDisabled > s.value

		IF @@ROWCOUNT > 0
		BEGIN
			GOTO RETURNTBL;
		END
		
		IF @RoleID = 4
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) de.SportType
					, de.BetType
					, 60037 AS MsgID
					, t.Sporttype AS ParentSporttype
					, t.BetType AS ParentBetType
			FROM #NewDisableStatTblCheck t
				INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
					ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
				INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
					ON d.ProductSettingID = de.Parent_ProductSettingID 
				LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
					ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType AND tempde.UpdateAllMasters = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
				CROSS APPLY (       SELECT TOP 1 1 AS IsDisabled
									FROM custInfo ci WITH(NOLOCK) 
										INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
										CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
									WHERE ci.srecommend = @custID
										AND roleid = 3
										AND s.value = 0
										AND tempde.SportType IS NULL
										AND t.UpdateAllMasters = 1 
										AND t.DisableAllMasters = 1 
								) st -- check if any Enabled Master

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) de.SportType
					, de.BetType
					, 60037 AS MsgID
					, t.Sporttype AS ParentSporttype
					, t.BetType AS ParentBetType
			FROM #NewDisableStatTblCheck t
				INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
					ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
				INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
					ON d.ProductSettingID = de.Parent_ProductSettingID 
				LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
					ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType AND tempde.UpdateAllAgents = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
				CROSS APPLY (       SELECT TOP 1 1 AS IsDisabled
									FROM custInfo ci WITH(NOLOCK) 
										INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
										CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
									WHERE ci.srecommend = @custID
										AND roleid = 2
										AND s.value = 0
										AND tempde.SportType IS NULL
										AND t.UpdateAllAgents = 1 
										AND t.DisableAllAgents = 1 
								) st -- check if any Enabled Agent

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) de.SportType
					, de.BetType
					, 60037 AS MsgID
					, t.Sporttype AS ParentSporttype
					, t.BetType AS ParentBetType
			FROM #NewDisableStatTblCheck t
				INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
					ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
				INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
					ON d.ProductSettingID = de.Parent_ProductSettingID 
				LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
					ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType AND (tempde.UpdateAllMembers = 1 OR tempde.UpdateAllSuperDirectMembers = 1)
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
				CROSS APPLY (       SELECT TOP 1 1 AS IsDisabled
									FROM custInfo ci WITH(NOLOCK) 
										INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
										CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
									WHERE ci.srecommend = @custID
										AND roleid = 1
										AND s.value = 0
										AND tempde.SportType IS NULL
										AND (
											(t.UpdateAllMembers = 1 AND t.DisableAllMembers = 1)
										OR	(t.UpdateAllSuperDirectMembers = 1 AND t.DisableAllSuperDirectMembers = 1)
										)
								) st -- check if any Enabled Member (Normal & Direct)

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) de.SportType
					, de.BetType
					, 60037 AS MsgID
					, t.Sporttype AS ParentSporttype
					, t.BetType AS ParentBetType
			FROM #NewDisableStatTblCheck t
				INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
					ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
				INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
					ON d.ProductSettingID = de.Parent_ProductSettingID 
				LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
					ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType AND tempde.UpdateAllAgents = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
				CROSS APPLY (       SELECT TOP 1 1 AS IsDisabled
									FROM custInfo ci WITH(NOLOCK) 
										INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
										CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
									WHERE ci.mrecommend = @custID
										AND roleid = 2
										AND s.value = 0
										AND tempde.SportType IS NULL
										AND t.UpdateAllAgents = 1 
										AND t.DisableAllAgents = 1 
								) st -- check if any Enabled Agent

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) de.SportType
					, de.BetType
					, 60037 AS MsgID
					, t.Sporttype AS ParentSporttype
					, t.BetType AS ParentBetType
			FROM #NewDisableStatTblCheck t
				INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
					ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
				INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
					ON d.ProductSettingID = de.Parent_ProductSettingID 
				LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
					ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType AND (tempde.UpdateAllMembers = 1 OR tempde.UpdateAllMasterDirectMembers = 1)
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
				CROSS APPLY (       SELECT TOP 1 1 AS IsDisabled
									FROM custInfo ci WITH(NOLOCK) 
										INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
										CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
									WHERE ci.mrecommend = @custID
										AND roleid = 1
										AND s.value = 0
										AND tempde.SportType IS NULL
										AND (
											(t.UpdateAllMembers = 1 AND t.DisableAllMembers = 1)
										OR	(t.UpdateAllMasterDirectMembers = 1 AND t.DisableAllMasterDirectMembers = 1)
										)
								) st -- check if any Enabled Member (Normal & Direct)

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END
		END
		ELSE IF @RoleID = 2
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
			SELECT TOP(1) de.SportType
					, de.BetType
					, 60037 AS MsgID
					, t.Sporttype AS ParentSporttype
					, t.BetType AS ParentBetType
			FROM #NewDisableStatTblCheck t
				INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
					ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
				INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
					ON d.ProductSettingID = de.Parent_ProductSettingID 
				LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
					ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType AND tempde.UpdateAllMembers = 1
				INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
					ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
				CROSS APPLY (       SELECT TOP 1 1 AS IsDisabled
									FROM custInfo ci WITH(NOLOCK) 
										INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = ci.custid
										CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
									WHERE ci.recommend = @custID
										AND roleid = 1
										AND s.value = 0
										AND tempde.SportType IS NULL
										AND t.UpdateAllMembers = 1 
										AND t.DisableAllMembers = 1 
								) st -- check if any Enabled Member Normal

			IF @@ROWCOUNT > 0
			BEGIN
				GOTO RETURNTBL;
			END
		END
	--END
	
	RETURNTBL:

	UPDATE estt 
		SET estt.SettingLevel = psdc.SettingLevel
	FROM #ErrorSportTypeTbl estt
	INNER JOIN #ProductSettingDetail_Check psdc ON estt.SportType = psdc.SportType AND estt.BetType = psdc.BetType

	IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 60033)
	BEGIN
		SET @xml = (
				SELECT 60033 AS '@MsgID'
					, 'Account disabled for this product. Unable to edit downlines.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
							, SettingLevel AS '@SettingLevel'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 60033
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 91
		SET @ErrCode = 101
		
		RETURN
	END
	ELSE IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 90012)
	BEGIN
		SET @xml = (
				SELECT 90012 AS '@MsgID'
					, 'You are not allowed to perform this action.' AS '@Msg'
					, (
						SELECT DISTINCT SportType AS '@SportType'
							, BetType AS '@BetType'
							, SettingLevel AS '@SettingLevel'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 90012
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 91
		SET @ErrCode = 103
		
		RETURN
	END
	ELSE IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 60037)
	BEGIN
		SET @xml = (
				SELECT 60037 AS '@MsgID'
					, 'You cannot Enable {ChildSport} when {ParentSport} is Disabled.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
							, ParentSportType AS '@ParentSportType'
							, ParentBetType AS '@ParentBetType'
							, SettingLevel AS '@SettingLevel'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 60037
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 92
		SET @ErrCode = 103
		
		RETURN
	END

	DROP TABLE #ErrorSportTypeTbl
	DROP TABLE #NewDisableStatTblCheck
	DROP TABLE #OldDisableStatTbl
	DROP TABLE #ProductSettingDetail_Check
END
GO