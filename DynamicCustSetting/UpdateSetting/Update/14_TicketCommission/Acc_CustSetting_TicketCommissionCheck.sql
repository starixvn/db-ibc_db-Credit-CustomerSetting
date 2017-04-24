/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_TicketCommissionCheck] 
	  @CustID			INT
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @Commission		VARCHAR(MAX)
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20170424@Elodie
	Task : Check Customer's Ticket Commission
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
		• @Commission:
			<ROOT>
					<Commission 
							SportType="160" 
							BetType="1601" 
							Commission="0.070"
					/>
			</ROOT>

*/
BEGIN
	SET NOCOUNT ON

	DECLARE @NewCommTbl TABLE (
		  SportType		SMALLINT
		, BetType		SMALLINT
		, Commission	DECIMAL(9, 8)
		)

	DECLARE @UplineCommTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, Commission	DECIMAL(9, 8)
		)
	DECLARE @xml		XML

	IF @Commission IS NULL OR @Commission = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
					, @Commission

	INSERT @NewCommTbl
	SELECT SportType
		, BetType
		, CAST(Commission AS DECIMAL(9, 8)) AS Commission
	FROM OPENXML(@iDoc, '/ROOT/Commission', 1) WITH (
				SportType		SMALLINT
				, BetType		SMALLINT
				, Commission	VARCHAR(15)
			)

	EXEC sp_xml_removedocument @iDoc

	IF @RoleID = 3
	BEGIN
		--Get super 's Commission
		INSERT INTO @UplineCommTbl
		SELECT cs.SportType
			, cs.BetType
			, MIN(cs.Discount) AS Commission
		FROM dbo.CustDiscount3rd_Agent_csr cs WITH (NOLOCK)
		INNER JOIN @NewCommTbl tmp
			ON tmp.SportType	= cs.SportType
				AND tmp.BetType = cs.BetType
		WHERE cs.CustID			= @SuperID
		GROUP BY cs.SportType
			, cs.BetType
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Get super/master 's Commission
		INSERT INTO @UplineCommTbl
		SELECT cs.SportType
			, cs.BetType
			, MIN(cs.Discount) AS Commission
		FROM dbo.CustDiscount3rd_Agent_csr cs WITH (NOLOCK)
		INNER JOIN @NewCommTbl tmp
			ON tmp.SportType	= cs.SportType
				AND tmp.BetType = cs.BetType
		WHERE cs.CustID			= @SuperID 
			OR cs.CustID		= @MasterID
		GROUP BY cs.SportType
			, cs.BetType
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Get super/master/agent 's Commission
		INSERT INTO @UplineCommTbl
		SELECT cs.SportType
			, cs.BetType
			, MIN(cs.Discount) AS Commission
		FROM dbo.CustDiscount3rd_Agent_csr cs WITH (NOLOCK)
		INNER JOIN @NewCommTbl tmp
			ON tmp.SportType	= cs.SportType
				AND tmp.BetType = cs.BetType
		WHERE cs.CustID			= @SuperID 
			OR cs.CustID		= @MasterID
			OR cs.CustID		= @AgentID
		GROUP BY cs.SportType
			, cs.BetType
	END

	--Check if new Commission <0 or > default Max Commission
	IF EXISTS (select TOP 1 1 
					FROM @NewCommTbl tmp
					INNER JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
						ON pdt.SportType	= tmp.SportType
							AND pdt.BetType = tmp.BetType
							AND pdt.SettingType = 14
							AND pdt.IsLive		= 0
					WHERE 
						(	tmp.Commission		< 0
							OR	tmp.Commission	> pdt.MaxDiscount
						))
	BEGIN
		SET @xml = (
				SELECT 1 AS '@MsgID'
					, 'Invalid commission rate.' AS '@Msg'
					, (
						SELECT pdt.SportType AS '@SportType'
							, pdt.BetType AS '@BetType'
						FROM @NewCommTbl tmp
						INNER JOIN dbo.ProductSettingDetail pdt WITH (NOLOCK)
							ON pdt.SportType	= tmp.SportType
								AND pdt.BetType = tmp.BetType
								AND pdt.SettingType = 14
								AND pdt.IsLive		= 0
						WHERE 
							(	tmp.Commission		< 0
								OR	tmp.Commission	> pdt.MaxDiscount
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

	IF @RoleID IN (1, 2, 3)
	BEGIN
		--Check if Commission<=MIN(upper.Commission)
		IF EXISTS(SELECT TOP 1 1
				FROM @NewCommTbl tmp
					INNER JOIN @UplineCommTbl uc ON uc.BetType = tmp.BetType AND uc.SportType = tmp.SportType
				WHERE uc.Commission > tmp.Commission)
		BEGIN
			SET @xml = (
					SELECT 11 AS '@MsgID'
						, 'The Commission must be less than or equal to the Given Commission.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewCommTbl tmp
								INNER JOIN @UplineCommTbl uc ON uc.BetType = tmp.BetType AND uc.SportType = tmp.SportType
							WHERE uc.Commission > tmp.Commission
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

