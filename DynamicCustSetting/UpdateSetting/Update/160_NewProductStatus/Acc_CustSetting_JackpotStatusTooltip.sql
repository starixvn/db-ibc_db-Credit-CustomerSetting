/*<info serverAlias="DBAGE-bodb02" executers="wsv_nap, wsv_alp, wsv_xnap, wsv_alpv" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE Acc_CustSetting_JackpotStatusTooltip
(
	@Custid			INT,
	@SettingStatus	TINYINT = 0
)
AS
/*
	Created: 20250609@Dave
	Task: Live & RNG Casino - Product Status - Jackpot- Add Tooltip
	DB: DBAGE/bodb02
	
	Revisions:
		- 20250609@Dave: Initial SP [Redmine: #229765]
		
	Parameter's Explanation:
		@SettingStatus: 0 - PRO ; 1 - UAT
		
*/	
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@SiteID			INT,
		@Site			NVARCHAR(50),
		@Currency		INT;

	SELECT @SiteID= s.siteid, @Site = s.site, @Currency =cus.currency
	FROM Customer AS cus WITH (NOLOCK) 
		INNER JOIN Site AS s WITH (NOLOCK) ON cus.site = s.site
	WHERE cus.custid = @Custid;

	SELECT r.RealProductId, r.SportType, r.BetType
	FROM bettype AS sm WITH (NOLOCK)
		INNER JOIN SportBettypeSettingMatrix AS r WITH (NOLOCK) 
			ON sm.typeid = r.BetType
		INNER JOIN Products AS p WITH (NOLOCK) 
			ON r.RealProductId = p.ProductID
		LEFT JOIN SportNonOfferedSiteCurrency AS sno WITH (NOLOCK) 
			ON r.RealProductId = sno.RealProductID 
			AND sno.Currency IN (0, @Currency)
			AND sno.SiteID IN (0, @SiteID)
	WHERE sm.typenamee = 'Jackpot Contribution'
		AND r.isLicensee = 0
		AND r.isActive = 1
		AND r.isDeleted = 0
		AND sno.SportType IS NULL
		AND p.Enabled = 1
		AND p.Environment <= @SettingStatus;

END
GO