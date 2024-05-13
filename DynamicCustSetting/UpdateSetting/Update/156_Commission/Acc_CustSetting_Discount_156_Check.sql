/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_Discount_156_Check] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @Discount			VARCHAR(MAX)
	, @GroupID			TINYINT			= 3
	, @GroupType		TINYINT			= 156  
	, @SettingStatus		TINYINT			= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)		= ''		OUTPUT
AS
/*
	Created: 20240216@Helios
	Task : Check Customer's Discount
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_DiscountSelect

	Revision:
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 

	Param's Explanation:
		- @Discount:
				'[
					{ "SportType":"9911"  , "BetType":"2400"  , "Discount":"0.0025" }, 
					{ "SportType":"242"  , "BetType":"3201"  , "Discount":"0.0025" }
				]'
	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NewDiscountTbl TABLE (
			  SportType	SMALLINT
			, BetType	SMALLINT
			, Discount	DECIMAL(9, 8)
						)
	DECLARE
		@xml		XML,
		@SiteID	INT,
		@Currency	SMALLINT

	IF @Discount IS NULL
		OR @Discount = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	-- Parse Data Json
	INSERT INTO @NewDiscountTbl ( SportType , BetType , Discount )
	SELECT Comm.SportType , Comm.BetType , Comm.Discount
	FROM OPENJSON(@Discount)
	WITH 
		(
			SportType		SMALLINT,
			BetType		SMALLINT,
			Discount		DECIMAL (9,8)
		) AS Comm

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
		, @currency = currency
		, @siteid   = s.siteid
	FROM dbo.Customer  c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE custid = @CustID

	CREATE TABLE #ProductSettingDetail_Check(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		MaxDiscount	decimal(9,8),
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxDiscount)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxDiscount
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewDiscountTbl t
		INNER JOIN #ProductSettingDetail_Check ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer 

	--Check if new discount <0 or > default Max Discount
	IF EXISTS (select TOP 1 1 
					FROM @NewDiscountTbl tmp
					INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
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
							, pdt.SettingLevel AS '@SettingLevel'
						FROM @NewDiscountTbl tmp
						INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
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

	DROP TABLE #ProductSettingDetail_Check
END
GO
