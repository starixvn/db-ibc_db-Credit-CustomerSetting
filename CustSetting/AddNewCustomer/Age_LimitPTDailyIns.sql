/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_LimitPTDailyIns]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT,
	  @custid				INT,
	  @ServiceType			TINYINT = 0,
	  @SettingStatus		TINYINT = 0,
	  @ErrCode				INT				= 0		OUTPUT
	, @ErrMsg				NVARCHAR(200)	= ''	OUTPUT
AS
/*
	Task : NAP CM -  Limit Monthly PT Update
	DB: DBCUST/CustDB
	Original: 
	Revisions:
		- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230620@Luke: Limitation to update PT for new member [Redmine: #188950]
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
		- 20241230@July: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]
		- 20250410@Johnson: change datatype for ExchangeID[redmine: #223630]
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
		- 20251027@Eden: Adjust Live Casino PT & Commission [Redmine: #242260]
		
*/
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @srecommend INT,
				@mrecommend INT,
				@recommend	INT , 
				@Currency	INT,
				@site		NVARCHAR(50),
				@SiteID		INT	,
				@roleActorid TINYINT = 5
			
		SELECT	@roleActorid = roleid FROM Customer WITH(NOLOCK)	WHERE custid = @Actorid
		IF @roleActorid > 4 
		BEGIN
			RETURN
		END 
	
		SELECT	@srecommend = srecommend,
				@mrecommend = mrecommend,
				@recommend  = recommend,
				@Currency	= currency,
				@site		= Site
		FROM Customer WITH(NOLOCK)
		WHERE custid = @custid
	
		SELECT @SiteID = siteid FROM Site WITH(NOLOCK) WHERE site = @site
	
		DECLARE @tblPT TABLE (
					SportType		SMALLINT,
					BetType			SMALLINT , 
					MaxCount		TINYINT
					)			
	
		-- For read xml 				
		IF @ServiceType = 0
		BEGIN
			INSERT INTO @tblPT( SportType , BetType ,MaxCount  )  
			SELECT b.SportType,b.BetType,MIN(l.MaxCount) AS MaxCount
			FROM LimitPTDailySetting l WITH(NOLOCK) 
				INNER JOIN dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID, @currency) b ON l.ProductID = b.ProductID
			WHERE b.SettingType IN (1,18)
				AND (l.Currency = @Currency OR l.Currency = 0) AND (l.SiteID = @SiteID OR l.SiteID = 0)
				AND (l.CustID = 0 OR  l.CustID IN (@srecommend,@mrecommend,@recommend))
				AND l.LimitNewAccUpdPT = 1
			GROUP BY b.SportType,b.BetType
		END
		ELSE IF @ServiceType = 1
		BEGIN
			INSERT INTO @tblPT( SportType , BetType ,MaxCount  )  
			SELECT b.SportType,b.BetType,MIN(l.MaxCount) AS MaxCount
			FROM LimitPTDailySetting l WITH(NOLOCK) 
				INNER JOIN dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@SiteID, @currency) b ON l.ProductID = b.ProductID
			WHERE b.SettingType IN (1,18)
				AND (l.Currency = @Currency OR l.Currency = 0) AND (l.SiteID = @SiteID OR l.SiteID = 0)
				AND (l.CustID = 0 OR  l.CustID IN (@srecommend,@mrecommend,@recommend))
				AND l.LimitNewAccUpdPT = 1
			GROUP BY b.SportType,b.BetType
		END
		-- Exclude Sport/Product Non Offer PT Limit
		DELETE t FROM @tblPT AS t 
		CROSS APPLY (
					SELECT dbo.f_CustSetting_GetOfferPTLimit (t.SportType, t.BetType)
				) fn (IsNonOffer)
		WHERE fn.IsNonOffer = 0
		
		INSERT INTO CustLimitPTSetting (CustID,SportType,BetType,ActorID,PTCount,LastUpdated,RepUpdateTime)
		SELECT @custid , P.SportType, p.BetType, @Actorid , 1 AS PTCount, CAST(GETDATE() AS  DATE) AS LastUpdated, dbo.f_GetDateTime2()
		FROM @tblPT p 
		
	END TRY
	BEGIN CATCH
		SELECT  @ErrCode = ERROR_NUMBER(),@ErrMsg = ERROR_MESSAGE()
		RETURN
	END CATCH
END
GO
