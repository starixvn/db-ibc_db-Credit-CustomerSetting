/*<info serverAlias="DBAGE-bodb02" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_GetToolTipProduct]
    @Site          VARCHAR(10),
    @SettingStatus TINYINT    = 0,
    @currency      SMALLINT   = 0
AS
/*
	Created: 20251028@Dave
	Task : Get list product for tooltip display
	DB: DBAGE/bodb02

	Revision:
		- 20251028@Dave: Live Casino - Adjust-pt-comm-for-live-casino [RedmineID: #242260]

    Param's Explanation:
        - @SettingStatus: 0: Pro, 1: UAT
*/
BEGIN
    SET NOCOUNT ON;

    DECLARE @siteid INT, @SiteLabel NVARCHAR(50);

    SELECT @siteid = siteid, @SiteLabel = SiteLabel
    FROM Site WITH (NOLOCK)
    WHERE Site = @Site;

    -- Get offered product list for site/currency/setting
    CREATE TABLE #OfferedProducts (
        ProductID INT,
        ProductName VARCHAR(50),
        IsHidden BIT,
        EndOfSupportDate DATE,
        OrderNo INT,
        [Type] TINYINT
    );

    INSERT INTO #OfferedProducts (ProductID, ProductName, IsHidden, EndOfSupportDate, OrderNo, [Type])
    EXEC dbo.Age_GetOfferedProductBySiteCurrency @Site = @Site, @Currency = @currency, @SettingStatus = @SettingStatus;

    DELETE #OfferedProducts
    WHERE EndOfSupportDate < CAST(GETDATE() AS DATE) OR IsHidden = 1;

    -- Return tooltip product list only when RealProduct is offered for site/currency
    SELECT PR.GroupType,
           MT.RealProductId,
           PR.SportType,
           PR.BetType
    FROM dbo.f_CustSetting_ProductProfileSel(NULL, @SettingStatus, @siteid, @currency) AS PR
    INNER JOIN dbo.f_CustSetting_SportBetTypeSettingMatrix(@SettingStatus) AS MT
        ON PR.SportType = MT.SportTypeRefComm
       AND PR.BetType = MT.BetTypeRefComm
       AND MT.Site = @Site
    INNER JOIN #OfferedProducts OP
        ON MT.RealProductId = OP.ProductID
    WHERE PR.GroupType IN (156)
        AND @SiteLabel IN ('MBC')

    UNION

    SELECT PR.GroupType,
           MT.RealProductId,
           PR.SportType,
           PR.BetType
    FROM dbo.f_CustSetting_ProductProfileSel(NULL, @SettingStatus, @siteid, @currency) AS PR
    INNER JOIN dbo.f_CustSetting_SportBetTypeSettingMatrix(@SettingStatus) AS MT
        ON PR.SportType = MT.SportTypeRefPT
       AND PR.BetType = MT.BetTypeRefPT
       AND MT.Site = @Site
    INNER JOIN #OfferedProducts OP2
        ON MT.RealProductId = OP2.ProductID
    WHERE PR.GroupType IN (153)
    AND MT.SportTypeRefPT <> 9911

    ORDER BY GroupType ASC, SportType ASC, BetType ASC, RealProductId ASC;

    DROP TABLE #OfferedProducts;
END;
GO