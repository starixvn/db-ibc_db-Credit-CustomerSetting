/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_DiscountCheck_MAg]
	@mrecommend INT,
	@SettingType25 VARCHAR(MAX)= '' OUTPUT, --SB
	@SettingType19 VARCHAR(MAX)= '' OUTPUT, --LCS	
	@IsMyanmarOdds BIT= 0,
	@CreationStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20230627@Johnson  
	Task : check Discount for agent 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230627@Johnson: initial sp [redmine: #179159]

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
	
	DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, bettype SMALLINT, discount DECIMAL(9,8))
	
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
	SELECT SportType,BetType,SettingType,IsLive,ProductID,
		CASE WHEN SettingLevel = 4 THEN 4 --SportTypeBettype
			ELSE 2 END as SettingLevel --SportType
		,MaxDiscount
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus)
	
	--check SB Discount
	IF ISNULL(@SettingType25,'') <> ''		
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType25)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/R') T(c) 
		
		IF @IsMyanmarOdds = 1
		BEGIN
			UPDATE t
			SET t.Discount = s.commRate
			FROM @NewDiscountTbl t
				CROSS APPLY (SELECT commRate  
							FROM AgentCommRate WITH(NOLOCK)  
							WHERE custid = @mrecommend
								AND sporttype = 1   
								AND bettype = 1) s
			WHERE sporttype = 2
				AND bettype = 1
				AND t.Discount > s.commRate
			
			--update groupb,c,d = 0
			UPDATE @NewDiscountTbl
			SET discount = 0
			WHERE sporttype = 1
				AND bettype IN (3,7,8)			
		END
			
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
		
		--correct discount
		UPDATE t
		SET t.Discount = CASE WHEN t.bettype = 1 AND t.Discount > cs.groupa THEN cs.groupa
							WHEN t.bettype = 3 AND t.Discount > cs.groupb THEN cs.groupb
							WHEN t.bettype = 7 AND t.Discount > cs.groupc THEN cs.groupc
							WHEN t.bettype = 8 AND t.Discount > cs.groupd THEN cs.groupd
							WHEN t.bettype IN (4,5) AND t.Discount > cs.sdiscount THEN cs.groupd
							ELSE t.Discount END
		FROM @NewDiscountTbl t
			INNER JOIN custsetting cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
													AND t.bettype = cs.bettype
		WHERE custid = @mrecommend
			AND t.sporttype = 1
			
		SELECT @SettingType25 = (
		SELECT SportType '@SportType', 
			BetType '@BetType', 
			discount '@Discount'			
		FROM @NewDiscountTbl
		FOR XML PATH ('R'), ROOT('Root')
		)		
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
		
		--correct discount
		UPDATE t
		SET t.Discount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
													AND t.bettype = cs.bettype
		WHERE custid = @mrecommend			
			AND t.Discount > cs.Discount
			
		SELECT @SettingType19 = (
		SELECT SportType '@SportType', 
			BetType '@BetType', 
			discount '@Discount'			
		FROM @NewDiscountTbl
		FOR XML PATH ('R'), ROOT('Root')
		)
	END	
			
	DROP TABLE #ProductSettingDetail_Check
END	