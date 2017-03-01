ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_00]
	@CustId			INT,
    @RoleId			INT,
	@Limit_XML	VARCHAR(MAX) = NULL,
	@SettingType	SMALLINT		= 6
AS
/*
    Created: 20160108@Elodie
    Task : Update SMA WinLossLimit 
    DB: DBCust/CustDB
    
    Revisions:
		- 20161011@Winnie:  Implement for Loss limit setting type RedmineID: #65472
    Param's Explanation:
            
*/
BEGIN
	SET NOCOUNT ON;
    -- check existing tables

    IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN
	
	IF(@SettingType=12)
	BEGIN
		DECLARE @NewLimitTbl12 TABLE(
			SportType SMALLINT,
			BetType SMALLINT,	
			MaxLossLimit MONEY,
			IsAutoReset BIT
		)
		IF @Limit_XML IS NULL OR @Limit_XML='' RETURN

		--Parse XML	
		DECLARE @iDoc12 INT
		EXEC sp_xml_preparedocument @iDoc12 OUTPUT, @Limit_XML

		INSERT @NewLimitTbl12
		SELECT SportType,BetType,MaxLossLimit,IsAutoReset
		FROM OPENXML (@iDoc12, '/ROOT/Limit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MaxLossLimit MONEY, IsAutoReset BIT)		
		EXEC sp_xml_removedocument @iDoc12

		IF @RoleId = 4
		BEGIN
			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.srecommend = @CustId AND cwl.CustId <> @CustId

			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.srecommend = @CustId AND cwl.CustId <> @CustId
			
		END
		ELSE IF @RoleID = 3
		BEGIN
			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.mrecommend = @CustId AND cwl.CustId <> @CustId

			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.mrecommend = @CustId AND cwl.CustId <> @CustId
			
		END
		ELSE IF @RoleID = 2
		BEGIN
			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.recommend = @CustId AND cwl.CustId <> @CustId

			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.recommend = @CustId AND cwl.CustId <> @CustId
		END

	END
	ELSE IF(@SettingType=6)
	BEGIN
		DECLARE @NewLimitTbl TABLE(
			SportType SMALLINT,
			BetType SMALLINT,
			MaxWinLimit SMALLMONEY,
			MaxLossLimit MONEY,
			IsAutoReset BIT
		)
		
		IF @Limit_XML IS NULL OR @Limit_XML='' RETURN

		--Parse XML	
		DECLARE @iDoc INT
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @Limit_XML

		INSERT @NewLimitTbl
		SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset
		FROM OPENXML (@iDoc, '/ROOT/Limit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MaxWinLimit SMALLMONEY, MaxLossLimit MONEY, IsAutoReset BIT)	
		
		EXEC sp_xml_removedocument @iDoc

		IF @RoleId = 4
		BEGIN
			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.srecommend = @CustId AND cwl.CustId <> @CustId

			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.srecommend = @CustId AND cwl.CustId <> @CustId
			
		END
		ELSE IF @RoleID = 3
		BEGIN
			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.mrecommend = @CustId AND cwl.CustId <> @CustId

			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.mrecommend = @CustId AND cwl.CustId <> @CustId
			
		END
		ELSE IF @RoleID = 2
		BEGIN
			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.recommend = @CustId AND cwl.CustId <> @CustId

			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON cwl.CustId = c.CustId
			WHERE c.recommend = @CustId AND cwl.CustId <> @CustId
		END
	END
END