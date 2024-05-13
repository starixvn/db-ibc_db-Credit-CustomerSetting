/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Age_LimitPTDailyUpd]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT,
	  @custid				INT,
	  @UpdatePT				VARCHAR(MAX)
	, @ErrCode				INT				= 0		OUTPUT
	, @ErrMsg				NVARCHAR(200)	= ''	OUTPUT
AS
/*
		Task : NAP CM -  Limit Daily PT Update
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 20211027@Winfred: NAP CM -  Limit Daily PT Update [Redmine: #162476]
			- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
			- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
	*/
BEGIN
	SET NOCOUNT ON;

	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @UpdatePT OUTPUT

	BEGIN TRY
		DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT	
				)			
	
	-- For read xml 				
	INSERT INTO @tblPT(
				SportType,
				BetType
			)
	SELECT
		SportType,
		BetType
	FROM dbo.f_DCS_PT_XMLParse(@UpdatePT)	

	-- Exclude Sport/Product Non Offer PT Limit
	DELETE t FROM @tblPT AS t 
	CROSS APPLY (
				SELECT dbo.f_CustSetting_GetOfferPTLimit (t.SportType, t.BetType)
			) fn (IsOffer)
	WHERE fn.IsOffer = 0
	
		IF EXISTS( SELECT TOP 1 1 FROM CustLimitPTSetting t WITH(NOLOCK)  
									INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType
							  WHERE   CustID = @custid AND ActorID = @Actorid )
		BEGIN
			UPDATE t
			SET t.PTCount = CASE WHEN DATEADD(DAY,30,CAST(LastUpdated AS DATE)) >= CAST(GETDATE() AS  DATE) THEN  t.PTCount + 1  ELSE 1 END,
				t.LastUpdated = CAST(GETDATE() AS  DATE)
			FROM CustLimitPTSetting t WITH(UPDLOCK,ROWLOCK)
				INNER JOIN @tblPT p ON t.SportType = p.SportType AND t.BetType = P.BetType 
			WHERE CustID = @custid AND ActorID = @Actorid 
		END
		
		INSERT INTO CustLimitPTSetting (CustID,SportType,BetType,ActorID,PTCount,LastUpdated)
		SELECT @custid , P.SportType,p.BetType,@Actorid , 1 AS PTCount ,CAST(GETDATE() AS  DATE) AS LastUpdated
		FROM @tblPT p 
		WHERE  NOT EXISTS( SELECT TOP 1 1 FROM CustLimitPTSetting t WITH(NOLOCK)  
							  WHERE CustID = @custid AND ActorID = @Actorid AND t.SportType = p.SportType AND t.BetType = P.BetType )
			
		 
	END TRY
	BEGIN CATCH
		SELECT  @ErrCode = ERROR_NUMBER(),@ErrMsg = ERROR_MESSAGE()
		RETURN
	END CATCH

END
GO
