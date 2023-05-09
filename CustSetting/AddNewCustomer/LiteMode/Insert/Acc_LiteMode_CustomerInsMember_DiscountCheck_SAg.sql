/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_DiscountCheck_SAg]
	@srecommend INT,
	@SettingType25 VARCHAR(MAX)= '', --SB
	@SettingType19 VARCHAR(MAX)= '', --LCS
	@SettingType3 VARCHAR(MAX)= '', --NG2
	@IsMyanmarOdds BIT= 0,
	@CreationStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: 20230515@Johnson  
	Task : check Discount for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230515@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType25 = '<Root>
						<r sporttype="1" bettype="1" discount="0.0025" />
						<r sporttype="1" bettype="3" discount="0.005" />
						<r sporttype="1" bettype="7" discount="0.0075" />
						<r sporttype="1" bettype="8" discount="0.01" />
						<r sporttype="1" bettype="4" discount="0.0025" />
						<r sporttype="1" bettype="5" discount="0.001" />
						<r sporttype="2" bettype="1" discount="0.0025" />
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
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxDiscount
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@CreationStatus)
	
	--check SB Discount
	IF ISNULL(@SettingType25,'') <> ''		
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType25)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(r/@sporttype)[1]', 'tinyint') AS sporttype,
			T.c.query('.').value('(r/@bettype)[1]', 'tinyint') AS bettype,
			T.c.query('.').value('(r/@discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/r') T(c) 
		
		IF @IsMyanmarOdds = 1
		BEGIN
			UPDATE t
			SET t.Discount = s.commRate
			FROM @NewDiscountTbl t
				CROSS APPLY (SELECT commRate  
							FROM AgentCommRate WITH(NOLOCK)  
							WHERE custid = @srecommend
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
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
									AND pdt.SettingType IN (25)
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
	
	--check LCS Discount
	IF ISNULL(@SettingType19,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType19)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(r/@sporttype)[1]', 'tinyint') AS sporttype,
			T.c.query('.').value('(r/@bettype)[1]', 'tinyint') AS bettype,
			T.c.query('.').value('(r/@discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/r') T(c)
		
		--Check if new discount <0 or > default Max Discount
		IF EXISTS (SELECT TOP 1 1 
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
							FROM @NewDiscountTbl tmp
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
									AND pdt.SettingType IN (19)
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
			SET @ErrCode = 102
			
			RETURN
		END
	END	
	
	--check NG2 Discount
	IF ISNULL(@SettingType3,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType3)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
		SELECT T.c.query('.').value('(r/@sporttype)[1]', 'tinyint') AS sporttype,
			T.c.query('.').value('(r/@bettype)[1]', 'tinyint') AS bettype,
			T.c.query('.').value('(r/@discount)[1]', 'decimal(9,8)') AS discount
		FROM   @xml.nodes('/Root/r') T(c)
		
		--Check if new discount <0 or > default Max Discount
		IF EXISTS (SELECT TOP 1 1 
						FROM @NewDiscountTbl tmp
						INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
							ON pdt.SportType	= tmp.SportType
								AND pdt.BetType = tmp.BetType
								AND pdt.SettingType IN (3)
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
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
									AND pdt.SettingType IN (3)
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
			SET @ErrCode = 103
			
			RETURN
		END
	END	
	
	DROP TABLE #ProductSettingDetail_Check
END	