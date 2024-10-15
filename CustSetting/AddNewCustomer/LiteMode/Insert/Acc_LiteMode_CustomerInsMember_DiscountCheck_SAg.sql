/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_DiscountCheck_SAg]
	@srecommend INT,
	@siteid SMALLINT =0,
	@currency SMALLINT =0,
	
	@SettingType25 VARCHAR(MAX)= '' OUTPUT, --SB
	@SettingType19 VARCHAR(MAX)= '' OUTPUT, --LCS
	@SettingType3 VARCHAR(MAX)= '' OUTPUT, --Others Games	
	@SettingStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT,
	@IsValidateParam BIT = 1,
	@IsUpdateParam BIT = 0 -- Update Parameter
AS
/*
	Created: 20230515@Johnson  
	Task : check Discount for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230515@Johnson: initial sp [redmine: #179159]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240822@Eden: Scale out DBCUST - Credit Customer in GlobCustDB [redmine: #206823]

	Param's Explanation: 
		- @SettingType25 = '<Root>
						<R SportType="1" BetType="1" Discount="0.0025" />
						<R SportType="1" BetType="3" Discount="0.005" />
						<R SportType="1" BetType="7" Discount="0.0075" />
						<R SportType="1" BetType="8" Discount="0.01" />
						<R SportType="1" BetType="4" Discount="0.0025" />
						<R SportType="1" BetType="5" Discount="0.001" />
						<R SportType="2" BetType="1" Discount="0.0025" />
					</Root>'
*/	
BEGIN
	SET NOCOUNT ON

	DECLARE @xml XML
	
	DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, bettype SMALLINT, discount DECIMAL(9,8),Child_DisplayOrder INT)
	
	CREATE TABLE #ProductSettingDetail_Check(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		MaxDiscount	decimal(9,8),
		Child_DisplayOrder	INT
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxDiscount,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,
		CASE WHEN SettingLevel = 4 THEN SettingLevel --SportTypeBettype
			ELSE 2 END SettingLevel--SportType
		,MaxDiscount
		,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	
	--check SB Discount
	IF ISNULL(@SettingType25,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType25)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/R') T(c) 
		
		IF @IsValidateParam = 1
		BEGIN
			--Check if new discount <0 or > default Max Discount
			IF EXISTS (SELECT TOP 1 1 
							FROM @NewDiscountTbl tmp
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
									AND pdt.SettingType IN (25)
									AND pdt.IsLive		= 0
							WHERE 
								tmp.Discount		< 0								
								)
			BEGIN
				SET @xml = (
						SELECT 1 AS '@MsgID'
							, 'Invalid commission rate.' AS '@Msg'
							, (
								SELECT pdt.SportType AS '@SportType'
									, pdt.BetType AS '@BetType'
									, pdt.SettingLevel as '@SettingLevel'
								FROM @NewDiscountTbl tmp
								INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
									ON pdt.SportType	= tmp.SportType
										AND pdt.BetType = tmp.BetType
										AND pdt.SettingType IN (25)
										AND pdt.IsLive		= 0
								WHERE 
									(	tmp.Discount		< 0									
									)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 52
				SET @ErrCode = 101
			
				RETURN
			END
		END
		
		IF @IsUpdateParam = 1 -- UpdateParameter for update and writelog
		BEGIN
			--correct discount
			UPDATE t
			SET t.Discount = cs.Discount
			FROM @NewDiscountTbl t
				INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
														AND t.bettype = cs.bettype
			WHERE custid = @srecommend			
				AND t.Discount > cs.Discount

			UPDATE t
			SET t.Child_DisplayOrder = d.Child_DisplayOrder
			FROM @NewDiscountTbl t
				INNER JOIN #ProductSettingDetail_Check d 
					ON t.SportType = d.SportType
					AND t.BetType = d.BetType
			
			SELECT @SettingType25 = (
			SELECT SportType '@SportType', 
				BetType '@BetType', 
				discount '@Discount'			
			FROM @NewDiscountTbl
			ORDER BY Child_DisplayOrder,SportType,BetType
			FOR XML PATH ('R'), ROOT('Root')
			)
		END
	END	
	
	--check LCS Discount
	IF ISNULL(@SettingType19,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType19)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/R') T(c) 
		
		IF @IsValidateParam = 1
		BEGIN
			--Check if new discount <0 or > default Max Discount
			IF EXISTS (SELECT TOP 1 1 
							FROM @NewDiscountTbl tmp
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
									AND pdt.SettingType IN (19)
									AND pdt.IsLive		= 0
							WHERE 
								tmp.Discount		< 0								
								)
			BEGIN
				SET @xml = (
						SELECT 1 AS '@MsgID'
							, 'Invalid commission rate.' AS '@Msg'
							, (
								SELECT pdt.SportType AS '@SportType'
									, pdt.BetType AS '@BetType'
									, pdt.SettingLevel as '@SettingLevel'
								FROM @NewDiscountTbl tmp
								INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
									ON pdt.SportType	= tmp.SportType
										AND pdt.BetType = tmp.BetType
										AND pdt.SettingType IN (19)
										AND pdt.IsLive		= 0
								WHERE 
									(	tmp.Discount		< 0									
									)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 51
				SET @ErrCode = 102
			
				RETURN
			END
		END
		
		
		IF @IsUpdateParam = 1 -- UpdateParameter for update and writelog
		BEGIN
			--correct discount
			UPDATE t
			SET t.Discount = cs.Discount
			FROM @NewDiscountTbl t
				INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
														AND t.bettype = cs.bettype
			WHERE custid = @srecommend			
				AND t.Discount > cs.Discount

			UPDATE t
			SET t.Child_DisplayOrder = d.Child_DisplayOrder
			FROM @NewDiscountTbl t
				INNER JOIN #ProductSettingDetail_Check d 
					ON t.SportType = d.SportType
					AND t.BetType = d.BetType
			
			SELECT @SettingType19 = (
			SELECT SportType '@SportType', 
				BetType '@BetType', 
				discount '@Discount'			
			FROM @NewDiscountTbl
			ORDER BY Child_DisplayOrder,SportType,BetType
			FOR XML PATH ('R'), ROOT('Root')
			)
		END
	END	
		
	--check Others Games Discount
	IF ISNULL(@SettingType3,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType3)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/R') T(c) 
		
		
		IF @IsValidateParam = 1
		BEGIN
			--Check if new discount <0 or > default Max Discount
			IF EXISTS (SELECT TOP 1 1 
							FROM @NewDiscountTbl tmp
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
									AND pdt.SettingType IN (3)
									AND pdt.IsLive		= 0
							WHERE 
								tmp.Discount		< 0								
								)
			BEGIN
				SET @xml = (
						SELECT 1 AS '@MsgID'
							, 'Invalid commission rate.' AS '@Msg'
							, (
								SELECT pdt.SportType AS '@SportType'
									, pdt.BetType AS '@BetType'
									, pdt.SettingLevel as '@SettingLevel'
								FROM @NewDiscountTbl tmp
								INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
									ON pdt.SportType	= tmp.SportType
										AND pdt.BetType = tmp.BetType
										AND pdt.SettingType IN (3)
										AND pdt.IsLive		= 0
								WHERE 
									(	tmp.Discount		< 0									
									)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 51
				SET @ErrCode = 102
			
				RETURN
			END
		END
		
		IF @IsUpdateParam = 1 -- UpdateParameter for update and writelog
		BEGIN
			--correct discount
			UPDATE t
			SET t.Discount = cs.Discount
			FROM @NewDiscountTbl t
				INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
														AND t.bettype = cs.bettype
			WHERE custid = @srecommend			
				AND t.Discount > cs.Discount
			
			UPDATE t
			SET t.Child_DisplayOrder = d.Child_DisplayOrder
			FROM @NewDiscountTbl t
				INNER JOIN #ProductSettingDetail_Check d 
					ON t.SportType = d.SportType
					AND t.BetType = d.BetType
			
			SELECT @SettingType3 = (
			SELECT SportType '@SportType', 
				BetType '@BetType', 
				discount '@Discount'			
			FROM @NewDiscountTbl
			ORDER BY Child_DisplayOrder,SportType,BetType
			FOR XML PATH ('R'), ROOT('Root')
			)
		END
	END	
	
	DROP TABLE #ProductSettingDetail_Check
END	