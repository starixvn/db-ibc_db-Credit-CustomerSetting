/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_Discount150Check]
	  @CustID		INT
	, @Discount		VARCHAR(MAX)
	, @ugroup		VARCHAR(3) = NULL
	, @SettingStatus	TINYINT			= 0
	, @CurrencyID	INT				= 0
	, @siteid		INT				= 0
	, @GroupID		TINYINT			= 1
	, @GroupType	TINYINT			= 150
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
		- 20250110@Johnson: Allow Agents to change member Comm group [RedmineID: #216405]
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

	CREATE TABLE #ProductSettingDetail_Check(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		MaxDiscount	decimal(9,8),
		Child_DisplayOrder	INT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
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

	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxDiscount,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxDiscount,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @NewCommTbl t
		INNER JOIN #ProductSettingDetail_Check ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 25
		AND u.FunctionType = 1 --Edit Customer

	
	DECLARE @RoleID INT 
	
	SELECT @RoleID = RoleID 
	FROM Customer WITH (NOLOCK)
	WHERE custid = @CustID


	IF @RoleID IN (2,3,4)
	BEGIN
		--Check if new discount < 0 or > default Max Discount
		IF EXISTS (
				SELECT 1
				FROM @NewCommTbl nc
				INNER JOIN #ProductSettingDetail_Check psd ON nc.SportType = psd.SportType AND nc.BetType = psd.BetType
				WHERE nc.Discount < 0						-- Discount Values must be > 0 
				OR (nc.Discount > psd.MaxDiscount)				-- New Rule From DCS
			)
			BEGIN
				SET @xml		= (SELECT	1 AS '@MsgID'
								,	'Invalid commission rate.' AS '@Msg'
								,	(SELECT psdc.SportType AS '@SportType'
											, psdc.BetType AS '@BetType'
											, psdc.SettingLevel AS '@SettingLevel'
									FROM @NewCommTbl nc
									INNER JOIN #ProductSettingDetail_Check psdc ON nc.SportType = psdc.SportType AND nc.BetType = psdc.BetType
										WHERE nc.Discount < 0					
										OR (nc.Discount > psdc.MaxDiscount)
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
								)
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @ErrCode = 101
				SET @MsgType = 52

				RETURN
			END
	END


	--Check if new discount (member) > default Max Discount
	IF @RoleID = 1
	BEGIN
		DECLARE @GroupDiscount		DECIMAL(9,8)
			, @Discount1X2		DECIMAL(9,8)
			, @DiscountOthers		DECIMAL(9,8)

		-- Get MaxDiscount Group A,B,C,D
		SELECT @GroupDiscount = psdc.MaxDiscount 
		FROM #ProductSettingDetail_Check psdc 
		WHERE psdc.SportType = 1 
		AND (psdc.BetType = CASE 
					WHEN @uGroup IN ('a', 'hka', 'dea') THEN 1  
					WHEN @uGroup IN ('b', 'hkb', 'deb') THEN 3 
					WHEN @uGroup IN ('c', 'hkc', 'dec') THEN 7 
					WHEN @uGroup IN ('d', 'hkd', 'ded') THEN 8  
					END)

		-- Get MaxDiscount 1X2
		SELECT @Discount1X2 = psdc.MaxDiscount 
		FROM #ProductSettingDetail_Check psdc 
		WHERE psdc.SportType = 1 
		AND psdc.BetType = 5

		-- Get MaxDiscount Others
		SELECT @DiscountOthers = psdc.MaxDiscount 
		FROM #ProductSettingDetail_Check psdc 
		WHERE psdc.SportType = 1 
		AND psdc.BetType = 4


		IF EXISTS (
			SELECT 1
			FROM @NewCommTbl
			WHERE SportType = 1 AND 
			(	
				Discount < 0
				OR
				BetType = 1 AND Discount > @GroupDiscount  
				OR 
				BetType = 4 AND Discount > @DiscountOthers  
				OR
				BetType = 5 AND Discount > @Discount1X2  
			)
		)
		BEGIN
			SET @xml		= (SELECT	1 AS '@MsgID'
							,	'Invalid commission rate.' AS '@Msg'
							,	(SELECT psdc.SportType AS '@SportType'
										, psdc.BetType AS '@BetType'
										, psdc.SettingLevel AS '@SettingLevel'
								FROM @NewCommTbl nc
								INNER JOIN #ProductSettingDetail_Check psdc ON nc.SportType = psdc.SportType AND nc.BetType = psdc.BetType
								WHERE nc.SportType = 1 AND 
								(
									nc.Discount < 0
									OR
									nc.BetType = 1 AND Discount > @GroupDiscount  
									OR 
									nc.BetType = 4 AND Discount > @DiscountOthers  
									OR
									nc.BetType = 5 AND Discount > @Discount1X2  
								)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
							)
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @ErrCode = 101
			SET @MsgType = 53

			RETURN
		END
	END


	


END