/*
	Created: Elodie
	Task: Update ProductStatusSiteCurrency for Lottery
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
 
DECLARE @Sporttype INT, @Bettype INT
SELECT @Sporttype = 220, @Bettype = 1021
	
DELETE FROM ProductStatusSiteCurrency WHERE SportType=@Sporttype

INSERT INTO ProductStatusSiteCurrency (SportType, BetType, SiteID, Currency, IsHidden, IsDisabled)
SELECT @Sporttype, @Bettype, siteid, 0, 1, 1
FROM Site WITH (NOLOCK)
WHERE site NOT IN ('755555', 'Indo', 'KORIBC', '733333', '222223', '222225', '222227')
	