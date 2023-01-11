/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Age_LimitPTDailyIns]
	-- Add the parameters for the stored procedure here
	  @Actorid				INT,
	  @custid				INT,
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
*/
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @srecommend INT,
				@mrecommend INT,
				@recommend	INT , 
				@Currency	TINYINT,
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
		CREATE TABLE #TempLimit (ProductID TINYINT,	SportType SMALLINT,	BetType	SMALLINT,CustID INT,Currency TINYINT,SiteID INT,MaxCount TINYINT, SettingStatus TINYINT) 
	
		INSERT INTO @tblPT( SportType , BetType ,MaxCount  )  
		SELECT b.SportType,b.BetType,MIN(l.MaxCount) AS MaxCoun
		FROM LimitPTDailySetting l WITH(NOLOCK) 
		INNER JOIN ProductSettingDetail b WITH(NOLOCK) ON l.ProductID = b.ProductID AND b.SettingStatus = b.SettingStatus
		WHERE b.SettingType IN (1,18) AND b.SettingStatus <= @SettingStatus
		AND (l.Currency = @Currency OR l.Currency = 0) AND (l.SiteID = @SiteID OR l.SiteID = 0)
		 AND (l.CustID = 0 OR  l.CustID IN (@srecommend,@mrecommend,@recommend))
		GROUP BY b.SportType,b.BetType
		
		INSERT INTO CustLimitPTSetting (CustID,SportType,BetType,ActorID,PTCount,LastUpdated)
		SELECT @custid , P.SportType,p.BetType,@Actorid , 1 AS PTCount ,CAST(GETDATE() AS  DATE) AS LastUpdated
		FROM @tblPT p 
		
	END TRY
	BEGIN CATCH
		SELECT  @ErrCode = ERROR_NUMBER(),@ErrMsg = ERROR_MESSAGE()
		RETURN
	END CATCH
END
GO
