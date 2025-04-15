/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_CustomerInsMember_DiscountCheck_DirectMember
	@srecommend INT,
	@mrecommend INT,
	@UplineRoleID TINYINT, 
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	
	@GroupTypeT150 VARCHAR(MAX)= '',
	@GroupTypeT156 VARCHAR(MAX)= '',
	@ugroup VARCHAR(5)='',
	@SettingStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20241107@Eden	
	Task: Validate when Super/Master create direct member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

	Param's Explanation: 
		- @GroupTypeT150 : 
			[
				{"SportType": "1","BetType": "1","Discount": "0.0010000"},
				{"SportType": "1","BetType": "5","Discount": "0.0030000"},
				{"SportType": "1","BetType": "4","Discount": "0.0035000"}
			]
		- @GroupTypeT156 : 
			 [
				{"SportType": "9911","BetType": "2400","Discount": "0.0035000"},
				{"SportType": "175","BetType": "7901","Discount": "0.0025000"}
			]
*/	
BEGIN
	SET NOCOUNT ON

	DECLARE @xml XML
	
	DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, 
									bettype SMALLINT, 
									playerdiscount DECIMAL(9,8), 
									sdiscount DECIMAL(9,8), 
									adiscount DECIMAL(9,8), 
									discount DECIMAL(9,8),
									Child_DisplayOrder	INT
									)
	
	CREATE TABLE #ProductSettingDetail_Check(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		MaxDiscount	decimal(9,8),
		Child_DisplayOrder	INT
	)

	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,IsLive,ProductID,SettingLevel,MaxDiscount,Child_DisplayOrder)
	SELECT SportType,BetType,IsLive,ProductID,
		CASE WHEN SettingLevel = 4 THEN 4 --SportTypeBettype
			ELSE 2 END as SettingLevel --SportType
		,MaxDiscount
		,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE GroupType IN(150,156)
	
	--check SB Discount
	IF ISNULL(@GroupTypeT150,'') <> ''		
	BEGIN
		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount)
		SELECT SportType,BetType,Discount
		FROM OPENJSON(@GroupTypeT150) WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,Discount DECIMAL(9,8)  '$.Discount'
			)
			
		BEGIN
			--Check if new discount <0 or > default Max Discount
			IF EXISTS (		SELECT TOP 1 1 
							FROM @NewDiscountTbl tmp
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
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
		END
	END	
	
	--check LCS Discount
	IF ISNULL(@GroupTypeT156,'') <> ''		
	BEGIN
		DELETE @NewDiscountTbl
		
		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount)
		SELECT SportType,BetType,Discount
		FROM OPENJSON(@GroupTypeT156) WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,Discount DECIMAL(9,8)  '$.Discount'
			)
		
		BEGIN
			--Check if new discount <0 or > default Max Discount
			IF EXISTS (SELECT TOP 1 1 
							FROM @NewDiscountTbl tmp
							INNER JOIN #ProductSettingDetail_Check pdt WITH (NOLOCK)
								ON pdt.SportType	= tmp.SportType
									AND pdt.BetType = tmp.BetType
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
		END
	END	
	DROP TABLE #ProductSettingDetail_Check
END	
GO