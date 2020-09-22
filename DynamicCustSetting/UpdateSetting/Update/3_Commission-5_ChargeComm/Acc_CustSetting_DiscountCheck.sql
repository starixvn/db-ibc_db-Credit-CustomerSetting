/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustSetting_DiscountCheck] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @Discount			VARCHAR(MAX)
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20141111@Dominic
	Task : Check Customer's Discount
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20200615@Elodie: Implement new setting type 19 [Redmine: #135363]
		- 20200914@Eden: Minimize UM Time - Lock updating customer settings [#136464]

	Param's Explanation:
		• @Discount:
			<ROOT>
					<Discount 
							SportType="1" 
							BetType="1" 
							Discount="0.0025"
					/>
			</ROOT>
	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NewDiscountTbl TABLE (
		  SportType	SMALLINT
		, BetType	SMALLINT
		, Discount	DECIMAL(9, 8)
		)
	DECLARE @xml		XML

	IF @Discount IS NULL
		OR @Discount = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
					, @Discount

	INSERT @NewDiscountTbl
	SELECT SportType
		, BetType
		, CAST(Discount AS DECIMAL(9, 8)) AS Discount
	FROM OPENXML(@iDoc, '/ROOT/Discount', 1) WITH (
				SportType	SMALLINT
				, BetType	SMALLINT
				, Discount	VARCHAR(15)
			)

	EXEC sp_xml_removedocument @iDoc

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewDiscountTbl t
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType IN(3, 19)
		AND u.FunctionType = 1 --Edit Customer

	--Check if new discount <0 or > default Max Discount
	IF EXISTS (select TOP 1 1 
					FROM @NewDiscountTbl tmp
					INNER JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
						ON pdt.SportType	= tmp.SportType
							AND pdt.BetType = tmp.BetType
							AND pdt.SettingType IN (3,19)
							AND pdt.IsLive		= 0
					WHERE 
						(	tmp.Discount		< 0
							OR	tmp.Discount	> pdt.maxDiscount
						))
	BEGIN
		SET @xml = (
				SELECT 1 AS '@MsgID'
					, 'Invalid commission rate.' AS '@Msg'
					, (
						SELECT pdt.SportType AS '@SportType'
							, pdt.BetType AS '@BetType'
						FROM @NewDiscountTbl tmp
						INNER JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
							ON pdt.SportType	= tmp.SportType
								AND pdt.BetType = tmp.BetType
								AND pdt.SettingType IN (3,19)
								AND pdt.IsLive		= 0
						WHERE 
							(	tmp.Discount		< 0
								OR	tmp.Discount	> pdt.maxDiscount
							)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 51
		SET @ErrCode = 101
		
		RETURN
	END
END
GO
