/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_Discount150Check] 
	  @CustID		INT
	, @Discount		VARCHAR(MAX)
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)		= ''		OUTPUT
AS
/*
	Created: 20231023@Helios
	Task : Check Customer's commission for SB
	DB: DBCUST/CustDB
	Original: 

	Revisions: 
		- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 

	Param's Explanation:
	@Discount: Json Type
		'[ 
					{ "SportType": "1", "BetType": "1", "Discount": "0.00150000" },
					{ "SportType": "1", "BetType": "3", "Discount": "0.00050000" },
					{ "SportType": "1", "BetType": "4", "Discount": "0.00350000" },
					{ "SportType": "1", "BetType": "5", "Discount": "0.00450000" },
					{ "SportType": "1", "BetType": "7", "Discount": "0.00550000" },
					{ "SportType": "1", "BetType": "8", "Discount": "0.00650000" },
					{ "SportType": "2", "BetType": "1", "Discount": "0.00100000" }
				 ]'
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @xml		XML

	DECLARE @NewCommTbl TABLE (
			  SportType			SMALLINT
			, BetType			SMALLINT
			, Discount			DECIMAL (9,8)
		)
	
	--------------------Collect Data--------------------
	-- Check if XML is null or empty
	IF @Discount IS NULL OR @Discount = ''
		RETURN
	

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg	= ''

	
	-- Parse Data Json
	INSERT INTO @NewCommTbl (SportType , BetType , Discount)
	SELECT Comm.SportType , Comm.BetType , Comm.Discount
	FROM OPENJSON(@Discount)
	WITH 
		(
			SportType		SMALLINT,
			BetType		SMALLINT,
			Discount		DECIMAL (9,8)
		) AS Comm


	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @NewCommTbl t
		INNER JOIN ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 25
		AND u.FunctionType = 1 --Edit Customer

	IF EXISTS (
		SELECT 1
		FROM @NewCommTbl nc
		INNER JOIN ProductSettingDetail psd ON nc.SportType = psd.SportType AND nc.BetType = psd.BetType
		WHERE nc.Discount < 0						-- Discount Values must be > 0 
		OR (nc.SportType = 1 AND nc.Discount > 0.2)		-- Exclude MysanmarOdds Discount Values mustbe < 0.2
		OR (nc.SportType = 2 AND nc.Discount > 0.01)		-- With MyanmarOdds Discount Values mustbe < 0.01
		OR (nc.Discount > psd.MaxDiscount)				-- New Rule From DCS
	)
	BEGIN
		SET @xml		= (SELECT	1 AS '@MsgID'
						,	'Invalid commission rate.' AS '@Msg'
						,	(SELECT psd.SportType AS '@SportType'
									, psd.BetType AS '@BetType'
							FROM @NewCommTbl nc
								INNER JOIN ProductSettingDetail psd ON nc.SportType = psd.SportType AND nc.BetType = psd.BetType
								WHERE nc.Discount < 0						-- Discount Values must be > 0 
								OR (nc.SportType = 1 AND nc.Discount > 0.2)		-- Exclude MysanmarOdds Discount Values mustbe < 0.2
								OR (nc.SportType = 2 AND nc.Discount > 0.01)		-- With MyanmarOdds Discount Values mustbe < 0.01
								OR (nc.Discount > psd.MaxDiscount)				-- New Rule From DCS
					FOR XML PATH('Row')
						, TYPE
					)
			FOR XML PATH('Root')
				, TYPE
						)
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @ErrCode = 101
		SET @MsgType = 51

		RETURN
	END


END