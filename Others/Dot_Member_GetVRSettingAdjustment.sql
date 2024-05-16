/*<info serverAlias="DBCUST-CUSTDB" executers="svc_tig" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE dbo.Dot_Member_GetVRSettingAdjustment (
			 @Sporttype				SMALLINT   
			,@Bettype				SMALLINT   
			,@SiteType				TINYINT    
			,@SiteID				INT        
			,@CustomerClass			SMALLINT   
			,@DateOfWeek			TINYINT    
			,@LeagueGroupID			INT        
			,@LeagueID				INT        
			,@Betfrom				NVARCHAR(4)    
			,@StakeRM				MONEY      
			,@VRValue				SMALLMONEY OUTPUT
			,@VRStatus				TINYINT  
			,@Time					TIME(7)    
			,@LiveIndicator			BIT   
			,@Istest				BIT = 0
			,@CurrencyID			INT = 0
			,@AccumulatedBalance	BIT = 0 OUTPUT
)
AS  
/*  
	Created:	20210425@Eden
	Task:		Get VR setting adjustment for ticket
	DB:			DBCUST/CustDB
	Original:	
  
	Revisions:  
	    - 20210425@Eden: First commit [Redmine:#136423]
		- 20230301@Eden: Wrong VR of Basketball and Esport [Redmine:#184585]
		- 20230307@Johnson: Return Basketball VR to its original state [redmine:#184339]
		- 20230421@VN-Elodie: Change data type of betfrom [Redmine:#177296]
		- 20240328@Luke: [NAP CM] VR Engine - Add in new criteria: Apply follow the VR accumulated balance, Currency [Redmine: #201333]

	Param's Explanation:  
	DECLARE @VRValue SMALLMONEY = 0.5
			,@AccumulatedBalance BIT
	EXEC Dot_Member_GetVRSettingAdjustment
		@Sporttype     = 1 ,
		@Bettype       = 1, 
		@SiteType      = 1, 
		@SiteID        = 1, 
		@CustomerClass = 8, 
		@DateOfWeek    = 5, 
		@LeagueGroupID = 1, 
		@LeagueID      = 1, 
		@Betfrom       = 'a', 
		@StakeRM       = 70, 
		@VRValue       = @VRValue OUTPUT, 
		@VRStatus      = 1, 
		@Time          = '23:59:59.9999', 
		@LiveIndicator = 1,
		@CurrencyID	   = 20,
		@AccumulatedBalance = @AccumulatedBalance OUTPUT
	SELECT @VRValue, @AccumulatedBalance
*/  
BEGIN    
	DECLARE @Adjustmenttype tinyint ,@AdjustmentValue SMALLMONEY
	DECLARE @NotinConfig TABLE 
	(
		 Sporttype     SMALLINT   
		,Bettype       SMALLINT   
		,SiteID        INT        
		,CustomerClass SMALLINT   
		,DateOfWeek    TINYINT    
		,LeagueGroupID INT        
		,LeagueID      INT 
		,CurrencyID		INT
	)

	INSERT INTO @NotinConfig( 
		 Sporttype    
		,Bettype      
		,SiteID       
		,CustomerClass
		,DateOfWeek   
		,LeagueGroupID
		,LeagueID   
		,CurrencyID
	)

	SELECT @Sporttype as Sporttype, 0 as Bettype, 0 as SiteID, 0 as CustomerClass, 0 as DateOfWeek,-1 as LeagueGroupID, -1 as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, @Bettype as Bettype, 0 as SiteID, 0 as CustomerClass, 0 as DateOfWeek,-1 as LeagueGroupID, -1 as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, 0 as Bettype, @SiteID as SiteID, 0 as CustomerClass, 0 as DateOfWeek,-1 as LeagueGroupID, -1 as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, 0 as Bettype, 0 as SiteID, @CustomerClass as CustomerClass, 0 as DateOfWeek,-1 as LeagueGroupID, -1 as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, 0 as Bettype, 0 as SiteID, 0 as CustomerClass, @DateOfWeek as DateOfWeek,-1 as LeagueGroupID, -1 as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, 0 as Bettype, 0 as SiteID, 0 as CustomerClass, 0 as DateOfWeek, @LeagueGroupID as LeagueGroupID, -1 as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, 0 as Bettype, 0 as SiteID, 0 as CustomerClass, 0 as DateOfWeek,-1 as LeagueGroupID, @LeagueID as LeagueID, 0 AS CurrencyID UNION ALL
	SELECT 0 as Sporttype, 0 as Bettype, 0 as SiteID, 0 as CustomerClass, 0 as DateOfWeek,-1 as LeagueGroupID, -1 as LeagueID, @CurrencyID AS CurrencyID

	SELECT TOP(1)
		@Adjustmenttype	= r.Adjustmenttype, 
		@AdjustmentValue = r.AdjustmentValue,
		@AccumulatedBalance = r.AccumulatedBalance
		--, r.Priority
	FROM [VRSettingRule] r WITH(NOLOCK,FORCESEEK)
	INNER JOIN [VRSettingRuleDetail] rd WITH(NOLOCK,FORCESEEK)
		ON r.ruleid = rd.ruleid
	OUTER APPLY(	SELECT TOP 1 rd0.ruleid 
					FROM VRSettingRuleDetail_NotApply rd0 WITH(NOLOCK,FORCESEEK)
						INNER JOIN @NotInConfig s
							 ON rd0.Sporttype = s.sporttype
							AND rd0.Bettype = s.bettype
							AND rd0.SiteID = s.SiteID
							AND rd0.LeagueGroupID = s.LeagueGroupID
							AND rd0.LeagueID = s.LeagueID
							AND rd0.CustomerClass = s.CustomerClass
							AND rd0.DateOfWeek = s.DateOfWeek
							AND rd0.CurrencyID = s.CurrencyID
					WHERE r.ruleid = rd0.ruleid
				)rd0
	WHERE rd.Sporttype IN(0,@Sporttype)
		AND rd.Bettype IN(0,@Bettype)
		AND rd.SiteID IN(0,@SiteID)
		AND rd.LeagueGroupID IN( -1,@LeagueGroupID)
		AND rd.LeagueID IN( -1,@LeagueID)
		AND rd.CustomerClass IN(0,@CustomerClass)
		AND rd.DateOfWeek IN(0,@DateOfWeek)
		AND rd.CurrencyID IN (0,@CurrencyID)
		--
		AND r.LiveIndicator IN(2,@LiveIndicator)
		AND r.SiteType IN(0,@SiteType)
		AND r.BeginTime <= @Time
		AND r.EndTime >= CASE WHEN r.EndTime = '' THEN r.EndTime ELSE @Time END
		AND r.Betfrom IN('',@Betfrom)
		AND r.StakeRM_From <=  @StakeRM
		AND r.StakeRM_To >= CASE WHEN r.StakeRM_To = 0 THEN r.StakeRM_To ELSE @StakeRM END
		AND r.VR_From <= @VRValue
		AND r.VR_To > = CASE WHEN r.VR_To = 0 THEN r.VR_To ELSE @VRValue END
		AND r.VRStatus IN( 2,ISNULL(@VRStatus,r.VRStatus))
		AND rd0.ruleid IS NULL
		AND r.Status <= @Istest
	ORDER BY r.Priority

	SELECT @VRValue = CASE WHEN @Adjustmenttype = 1 THEN @AdjustmentValue
							WHEN @Adjustmenttype = 2 THEN @AdjustmentValue + @VRValue
							WHEN @VRStatus = 0 AND @Sporttype NOT IN(43) THEN 1.00
							ELSE @VRValue END
END

GO
	