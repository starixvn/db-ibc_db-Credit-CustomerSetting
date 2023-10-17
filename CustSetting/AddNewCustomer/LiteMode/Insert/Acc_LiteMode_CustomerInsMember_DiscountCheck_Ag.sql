/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_DiscountCheck_Ag]
	@srecommend INT,
	@mrecommend INT,
	@recommend INT,
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	
	@SettingType25 VARCHAR(MAX)= '' OUTPUT, --SB
	@SettingType19 VARCHAR(MAX)= '' OUTPUT, --LCS	
	@SettingType3 VARCHAR(MAX)= '' OUTPUT, --LCS	
	@IsMyanmarOdds BIT= 0,
	@ugroup VARCHAR(5)='',
	@CreationStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20230727@Johnson  
	Task : check Discount for agent 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230727@Johnson: initial sp [redmine: #179159]

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
	
	DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, 
									bettype SMALLINT, 
									playerdiscount DECIMAL(9,8), 
									sdiscount DECIMAL(9,8), 
									adiscount DECIMAL(9,8), 
									discount DECIMAL(9,8)
									)
	
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
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus,@siteid,@currency)
	
	--check SB Discount
	IF ISNULL(@SettingType25,'') <> ''		
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType25)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS playerdiscount
		FROM   @xml.nodes('/Root/R') T(c) 
		
		IF @IsMyanmarOdds = 1
		BEGIN
			UPDATE t
			SET t.playerDiscount = CASE WHEN t.playerDiscount > s.commRate THEN s.commRate ELSE t.playerDiscount END,
				t.Discount = s.commRate
			FROM @NewDiscountTbl t
				CROSS APPLY (SELECT commRate  
							FROM AgentCommRate WITH(NOLOCK)  
							WHERE custid = @recommend
								AND sporttype = 1   
								AND bettype = 1) s
			WHERE sporttype = 2
				AND bettype = 1				
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
							tmp.playerDiscount		< 0								
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
								(	tmp.playerDiscount		< 0									
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
		
		--update SMA discount
		UPDATE t
		SET t.sdiscount = CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 
									THEN 
										CASE WHEN @ugroup in ('a','hka','dea') THEN groupa 
											WHEN @ugroup in ('b','hkb','deb') THEN groupb 
											WHEN @ugroup in ('c','hkc','dec') THEN groupc 
											ELSE groupd END
									ELSE cs.sdiscount END
		FROM @NewDiscountTbl t
			INNER JOIN custsetting cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
													AND t.bettype = cs.bettype
		WHERE custid = @srecommend
			AND t.sporttype = 1
		
		UPDATE t
		SET t.adiscount = CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 
									THEN 
										CASE WHEN @ugroup in ('a','hka','dea') THEN groupa 
											WHEN @ugroup in ('b','hkb','deb') THEN groupb 
											WHEN @ugroup in ('c','hkc','dec') THEN groupc 
											ELSE groupd END
									ELSE cs.adiscount END
		FROM @NewDiscountTbl t
			INNER JOIN custsetting cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
													AND t.bettype = cs.bettype
		WHERE custid = @mrecommend
			AND t.sporttype = 1
			
		UPDATE t
		SET t.discount = CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 
									THEN 
										CASE WHEN @ugroup in ('a','hka','dea') THEN groupa 
											WHEN @ugroup in ('b','hkb','deb') THEN groupb 
											WHEN @ugroup in ('c','hkc','dec') THEN groupc 
											ELSE groupd END
									ELSE cs.discount END
		FROM @NewDiscountTbl t
			INNER JOIN custsetting cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
													AND t.bettype = cs.bettype
		WHERE custid = @recommend
			AND t.sporttype = 1	
		
		--set comm of sportbook = 0 if agent of member exist in table CustNoComm
		IF EXISTS(SELECT 1 FROM CustNoComm WHERE custID = @recommend)
		BEGIN
			UPDATE t
			SET sdiscount = 0,
				adiscount = 0,
				discount = 0,
				playerdiscount = 0
			FROM @NewDiscountTbl t
			WHERE sporttype = 1
		END
		ELSE --correct comm
		BEGIN
			UPDATE t
			SET adiscount = sdiscount
			FROM @NewDiscountTbl t
			WHERE adiscount > sdiscount
			AND sporttype = 1
			
			UPDATE t
			SET discount = adiscount
			FROM @NewDiscountTbl t
			WHERE discount > adiscount
			AND sporttype = 1
			
			UPDATE t
			SET playerdiscount = discount
			FROM @NewDiscountTbl t
			WHERE playerdiscount > discount
			AND sporttype = 1
		END
		
		SELECT @SettingType25 = (
		SELECT SportType '@SportType', 
			BetType '@BetType', 
			playerdiscount '@playerdiscount',
			ISNULL(discount,0) '@discount',
			ISNULL(adiscount,0) '@adiscount',
			ISNULL(sdiscount,0) '@sdiscount'
		FROM @NewDiscountTbl
		FOR XML PATH ('R'), ROOT('Root')
		)		
	END	
	
	--check LCS Discount
	IF ISNULL(@SettingType19,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType19)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS playerdiscount
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
							tmp.playerdiscount		< 0								
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
								(	tmp.playerdiscount		< 0									
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
		
		--update SMA discount
		UPDATE t
		SET t.sdiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @srecommend
		
		UPDATE t
		SET t.adiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @mrecommend	
		
		UPDATE t
		SET t.discount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @recommend
		
		--correct discount
		UPDATE t
		SET adiscount = sdiscount
		FROM @NewDiscountTbl t
		WHERE adiscount > sdiscount		
		
		UPDATE t
		SET discount = adiscount
		FROM @NewDiscountTbl t
		WHERE discount > adiscount
		
		UPDATE t
		SET playerdiscount = discount
		FROM @NewDiscountTbl t
		WHERE playerdiscount > discount
					
		SELECT @SettingType19 = (
		SELECT SportType '@SportType', 
			BetType '@BetType', 
			playerdiscount '@playerdiscount',
			discount '@discount',
			adiscount '@adiscount',
			sdiscount '@sdiscount'
		FROM @NewDiscountTbl
		FOR XML PATH ('R'), ROOT('Root')
		)
	END	
	
	--check Others Games Discount
	IF ISNULL(@SettingType3,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		SELECT @xml = CONVERT(XML,@SettingType3)
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount)
		SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS playerdiscount
		FROM   @xml.nodes('/Root/R') T(c) 
		
		--Check if new discount <0 or > default Max Discount
		IF EXISTS (SELECT TOP 1 1 
						FROM @NewDiscountTbl tmp
						INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
							ON pdt.SportType	= tmp.SportType
								AND pdt.BetType = tmp.BetType
								AND pdt.SettingType IN (3)
								AND pdt.IsLive		= 0
						WHERE 
							tmp.playerdiscount		< 0								
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
								(	tmp.playerdiscount		< 0									
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
		
		--update SMA discount
		UPDATE t
		SET t.sdiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @srecommend
		
		UPDATE t
		SET t.adiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @mrecommend	
		
		UPDATE t
		SET t.discount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @recommend
		
		--correct discount
		UPDATE t
		SET adiscount = sdiscount
		FROM @NewDiscountTbl t
		WHERE adiscount > sdiscount		
		
		UPDATE t
		SET discount = adiscount
		FROM @NewDiscountTbl t
		WHERE discount > adiscount
		
		UPDATE t
		SET playerdiscount = discount
		FROM @NewDiscountTbl t
		WHERE playerdiscount > discount
					
		SELECT @SettingType3 = (
		SELECT SportType '@SportType', 
			BetType '@BetType', 
			playerdiscount '@playerdiscount',
			discount '@discount',
			adiscount '@adiscount',
			sdiscount '@sdiscount'
		FROM @NewDiscountTbl
		FOR XML PATH ('R'), ROOT('Root')
		)
	END	
	
	DROP TABLE #ProductSettingDetail_Check
END	