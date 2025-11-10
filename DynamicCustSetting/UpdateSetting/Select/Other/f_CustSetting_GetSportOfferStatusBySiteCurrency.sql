/*<info serverAlias="DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION f_CustSetting_GetSportOfferStatusBySiteCurrency(
	@SiteID INT, 
	@Currency INT,
	@Sporttype SMALLINT,
	@Bettype SMALLINT,
	@SettingStatus TINYINT
) 
RETURNS BIT
/*
    Created: 20230731@Eden  
	Task : Get Sport Offer Status By CustID
	DB: DBCUST/CustDB,DBAGE/bodb02, DBACC/bodb02,DBTXN/CustDB
  
	Revisions:
		- 20230731@Eden: Simplify Live Casino Customer Setting - [Redmine: #189389] 
		- 20251110@Dave: Live Casino - Adjust-pt-comm-for-live-casino [RedmineID: #242260]

	Examples:
	SELECT dbo.f_CustSetting_GetSportOfferStatusBySiteCurrency(1,20,242,3201,3)
	SELECT dbo.f_CustSetting_GetSportOfferStatusBySiteCurrency(1,20,211,2401,3)
*/
BEGIN 
	DECLARE @IsHidden BIT, @SettingType TINYINT = NULL

	IF EXISTS(
		SELECT 1
		FROM SportNonOfferedSiteCurrency WITH(NOLOCK) 
		WHERE SiteID IN(0, @SiteID)
			AND Currency IN (0,@Currency)
			AND SportType = @Sporttype AND BetType = @Bettype
	)
	BEGIN
		SELECT @IsHidden = 1
		RETURN @IsHidden
	END
	
	SELECT @IsHidden = IsHidden
	FROM ProductStatusSiteCurrency WITH(NOLOCK) 
	WHERE SiteID IN(0, @SiteID)
		AND Currency IN (0,@Currency)
		AND SportType = @Sporttype AND BetType = @Bettype
	
	IF @IsHidden IS NOT NULL
	BEGIN
		RETURN @IsHidden
	END

	IF EXISTS(
		SELECT 1 
		FROM dbo.f_CustSetting_ProductProfileSel(@SettingType,@SettingStatus,@SiteID,@Currency) t
		WHERE t.SettingType IN(4,11,13,21)
			AND t.SportType = @Sporttype 
			AND t.BetType = @Bettype
			AND t.IsHidden = 1
	)
	BEGIN
		SELECT @IsHidden = 1
		RETURN @IsHidden
	END
	
	SET @IsHidden = 0
	RETURN @IsHidden
END
