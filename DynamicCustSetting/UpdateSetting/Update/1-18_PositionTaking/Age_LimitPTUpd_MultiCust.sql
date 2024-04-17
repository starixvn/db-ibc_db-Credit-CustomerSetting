/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_LimitPTUpd_MultiCust]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT, --userid
	  @custIdList			VARCHAR(MAX),
	  @UpdatePT				VARCHAR(MAX),
	  @SettingStatus		BIT = 0
	, @ErrCode				INT				= 0		OUTPUT
	, @ErrMsg				NVARCHAR(200)	= ''	OUTPUT
AS
/*
		Task : NAP CM -  Limitation to update PT for new member
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 202130620@Luke: Limitation to update PT for new member [Redmine: #188950]
	*/
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @TblCust AS TABLE(
			custId INT
		)

		INSERT INTO @TblCust(custId)
		SELECT value
		FROM string_split(@CustIdList, ',')
		WHERE value <> ''

		DECLARE @tmpPT AS TABLE(
			SportType	SMALLINT,
			BetType		SMALLINT	
		)	
		INSERT INTO @tmpPT(
					SportType,
					BetType
				)
		SELECT p.SportType, p.BetType
		FROM dbo.f_DCS_PT_XMLParse(@UpdatePT) p

		DECLARE @tblPT AS TABLE(
			SportType	SMALLINT,
			BetType		SMALLINT	
		)	
		INSERT INTO @tblPT(
					SportType,
					BetType
				)
		SELECT DISTINCT t.Sporttype, t.Bettype 
		FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus) p
			INNER JOIN LimitPTDailySetting l WITH (NOLOCK) ON p.productID = l.ProductID
			INNER JOIN @tmpPT t ON p.SportType = t.SportType AND p.BetType = t.BetType
		WHERE SettingType IN (1, 18)

		IF EXISTS(SELECT TOP 1 1 FROM CustLimitPTSetting t WITH(NOLOCK)  
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
									INNER JOIN @TblCust c ON t.CustID = c.custId
							  WHERE  ActorID = @Actorid)

		BEGIN
			UPDATE t
			SET t.PTCount = CASE WHEN DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= CAST(GETDATE() AS  DATE) THEN  t.PTCount + 1  ELSE 1 END,
				t.LastUpdated = CAST(GETDATE() AS  DATE)
			FROM CustLimitPTSetting t WITH(UPDLOCK,ROWLOCK)
				INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType 
			WHERE CustID IN (SELECT custid FROM @tblCust) AND ActorID = @Actorid 
		END
		
		INSERT INTO CustLimitPTSetting (CustID,SportType,BetType,ActorID,PTCount,LastUpdated)
		SELECT c.custid , P.SportType,p.BetType,@Actorid , 1 AS PTCount ,CAST(GETDATE() AS  DATE) AS LastUpdated
		FROM @tblPT p 
			CROSS APPLY @TblCust c
		WHERE NOT EXISTS(
			SELECT TOP 1 1
			FROM CustLimitPTSetting l
			WHERE l.CustID = c.custId
		)
	END TRY
	BEGIN CATCH
		SELECT  @ErrCode = ERROR_NUMBER(),@ErrMsg = ERROR_MESSAGE()
		RETURN
	END CATCH
END
GO
