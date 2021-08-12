/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" ></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_12]
	@CustId			INT,
    @RoleId			INT,
	@XML	VARCHAR(MAX) = NULL,
	@Mode varchar(50)=''
AS
/*
    Created: 20210518@Winfred
    Task : Update Parlay Max Payout 
    DB: DBCust/CustDB
    
    Revisions:
		- 20210518@Winfred: Update Parlay Max Payout for SMA  [RedmineID:#154104]
    Param's Explanation:
            
*/
BEGIN
	SET NOCOUNT ON;
    -- check existing tables
	IF (@Mode='MaxPayout')
	BEGIN
		IF dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 0 RETURN
		IF dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 0 RETURN
		IF dbo.f_CheckRepTable('MaxPayoutGlobalSetting') = 0 RETURN
		
		DECLARE @NewMaxPayoutTbl TABLE (
				SportType			SMALLINT
				, BetType			SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
				)
		IF @XML IS NULL OR @XML='' RETURN
		
		--Parse XML	
		DECLARE @iDoc1 INT

		EXEC sp_xml_preparedocument @iDoc1 OUTPUT
			, @XML

		INSERT @NewMaxPayoutTbl (SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
		FROM OPENXML(@iDoc1, '/ROOT/MaxPayoutLimit', 1) WITH (
				SportType			SMALLINT
				, BetType			SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
				)

		EXEC sp_xml_removedocument @iDoc1
		
		IF @RoleId = 4
		BEGIN
			UPDATE mps
			SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
													THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
				, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
													THEN tmp.Combo2 ELSE mps.Combo2 END
				, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
													THEN tmp.Combo35 ELSE mps.Combo35 END
				, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
													THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
			FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
			INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON mps.CustId = c.CustId
			WHERE c.srecommend = @CustID AND mps.CustId <> @CustId
			
			UPDATE mps
			SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
													THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
				, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
													THEN tmp.Combo2 ELSE mps.Combo2 END
				, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
													THEN tmp.Combo35 ELSE mps.Combo35 END
				, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
													THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
			FROM dbo.CustMaxPayoutSetting_Member mps WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
			INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON mps.CustId = c.CustId
			WHERE c.srecommend = @CustID
		END
		ELSE IF @RoleId = 3
		BEGIN
			UPDATE mps
			SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
													THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
				, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
													THEN tmp.Combo2 ELSE mps.Combo2 END
				, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
													THEN tmp.Combo35 ELSE mps.Combo35 END
				, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
													THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
			FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
			INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON mps.CustId = c.CustId
			WHERE c.mrecommend = @CustID AND mps.CustId <> @CustId
			
			UPDATE mps
			SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
													THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
				, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
													THEN tmp.Combo2 ELSE mps.Combo2 END
				, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
													THEN tmp.Combo35 ELSE mps.Combo35 END
				, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
													THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
			FROM dbo.CustMaxPayoutSetting_Member mps WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
			INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON mps.CustId = c.CustId
			WHERE c.mrecommend = @CustID
		END	
		ELSE IF @RoleId = 2
		BEGIN
			UPDATE mps
			SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
													THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
				, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
													THEN tmp.Combo2 ELSE mps.Combo2 END
				, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
													THEN tmp.Combo35 ELSE mps.Combo35 END
				, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
													THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
			FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
			INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON mps.CustId = c.CustId
			WHERE c.recommend = @CustID AND mps.CustId <> @CustId
			
			UPDATE mps
			SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
													THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
				, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
													THEN tmp.Combo2 ELSE mps.Combo2 END
				, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
													THEN tmp.Combo35 ELSE mps.Combo35 END
				, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
													THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
			FROM dbo.CustMaxPayoutSetting_Member mps WITH(ROWLOCK,UPDLOCK)
			INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
			INNER JOIN dbo.CustInfo c WITH(NOLOCK) ON mps.CustId = c.CustId
			WHERE c.recommend = @CustID
		END		
	END
	
END