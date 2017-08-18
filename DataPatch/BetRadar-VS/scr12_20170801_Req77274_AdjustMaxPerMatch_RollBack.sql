/*
	Created: Elodie
	Task: Adjust Setting for BetRadarVS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
ALTER PROCEDURE [dbo].[Acc_ExecRep_Cust_09]
AS
BEGIN
	
	SET NOCOUNT ON

	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 RETURN

	DECLARE @msgDone NVARCHAR(200)

	DECLARE @ProductID TINYINT
	DECLARE @fSportType SMALLINT, @fBetType SMALLINT, @tSportType SMALLINT, @tBetType SMALLINT, @IsLive BIT

	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT, IsFinished BIT)

	SELECT @msgDone = 'Done for sporttype %d, bettype %d.'
	SELECT @ProductID = 5

	INSERT INTO #DestinationSportBetType(fSportType, fBetType,tSportType, tBetType, IsLive,  SettingType, IsFinished)
	SELECT	CASE WHEN SportType IN (190, 191, 199) THEN 180 ELSE SportType END, 
			CASE WHEN SportType IN (190, 191, 199) THEN 1201 ELSE BetType END, 
			SportType, BetType, 0, SettingType, 0
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (1, 2)


	--------------------------------------Bet Setting-------------------------------------------------		
	WHILE (1 = 1)
	BEGIN		
		CREATE TABLE #SMAList_BetSetting (custid INT, MaxPerMatch MONEY)
		CREATE TABLE #MemberList_BetSetting (custid INT, MaxPerMatch MONEY)

		UPDATE TOP (1) #DestinationSportBetType
		SET IsFinished = 1
			,@fBetType = fBetType	
			,@fSportType = fSportType
			,@tBetType = tBetType
			,@tSportType = tSportType
			,@IsLive = IsLive
		WHERE IsFinished = 0
			AND SettingType = 2

		IF @@ROWCOUNT = 0 BREAK

		--Agent Level
		INSERT INTO #SMAList_BetSetting (custid, MaxPerMatch)
		SELECT c.custid, csa.MaxPerMatch
		FROM custInfo c WITH(NOLOCK) 
			INNER JOIN dbo.CustBetSetting3rd_Agent csa WITH(NOLOCK) ON csa.custid = c.custid
		WHERE csa.SportType = @tSportType AND csa.BetType = @tBetType
				AND c.roleid IN (2,3,4) AND Enabled = 1
				AND CASE	WHEN @fSportType = 181 THEN c.maxpermatch181
							WHEN @fSportType = 182 THEN c.maxpermatch182					 
							WHEN @fSportType = 183 THEN c.maxpermatch183
							WHEN @fSportType = 184 THEN c.maxpermatch184
							WHEN @fSportType = 185 THEN c.maxpermatch185
							WHEN @fSportType = 186 THEN c.maxpermatch186
							ELSE c.maxpermatch180 END <> csa.maxperMatch			

		RAISERROR('Done: Get the affected SMA list for bet setting', 0, 1)  WITH NOWAIT

		--Member Level
		INSERT INTO #MemberList_BetSetting (custid, MaxPerMatch)
		SELECT c.custid, csm.MaxPerMatch
		FROM custInfo c WITH(NOLOCK)		
			INNER JOIN dbo.CustBetSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = c.custid
		WHERE csm.SportType = @tSportType AND csm.BetType = @tBetType
				AND c.roleid = 1 AND Enabled = 1
				AND CASE	WHEN @fSportType = 181 THEN c.maxpermatch181
							WHEN @fSportType = 182 THEN c.maxpermatch182					 
							WHEN @fSportType = 183 THEN c.maxpermatch183
							WHEN @fSportType = 184 THEN c.maxpermatch184
							WHEN @fSportType = 185 THEN c.maxpermatch185
							WHEN @fSportType = 186 THEN c.maxpermatch186
							ELSE c.maxpermatch180 END <> csm.maxperMatch			
	
		RAISERROR('Done: Get the affected member list for bet setting', 0, 1)  WITH NOWAIT

		--------------------------------------Bet Setting-------------------------------------------------		
		--Agent Level
		UPDATE csa
		SET csa.maxperMatch180 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 180

		UPDATE csa
		SET csa.maxperMatch181 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 181

		UPDATE csa
		SET csa.maxperMatch182 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 182

		UPDATE csa
		SET csa.maxperMatch183 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 183

		UPDATE csa
		SET csa.maxperMatch184 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 184

		UPDATE csa
		SET csa.maxperMatch185 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 185

		UPDATE csa
		SET csa.maxperMatch186 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 186

		RAISERROR('Done: Update the affected SMA list for bet setting', 0, 1)  WITH NOWAIT

		--Member Level		
		UPDATE csa
		SET csa.maxperMatch180 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 180

		UPDATE csa
		SET csa.maxperMatch181 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 181

		UPDATE csa
		SET csa.maxperMatch182 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 182

		UPDATE csa
		SET csa.maxperMatch183 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 183

		UPDATE csa
		SET csa.maxperMatch184 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 184

		UPDATE csa
		SET csa.maxperMatch185 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 185

		UPDATE csa
		SET csa.maxperMatch186 = cs.MaxPerMatch
		FROM dbo.custInfo csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE @tSportType = 186

		RAISERROR('Done: Update the affected member list for bet setting', 0, 1)  WITH NOWAIT

		RAISERROR(@msgDone, 0, 1, @tSportType, @tBetType)  WITH NOWAIT

		DROP TABLE #SMAList_BetSetting
		DROP TABLE #MemberList_BetSetting
	END
END		
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT DBCUST SERVERS -----
--------------------------------------------------------------------------------------
EXEC dbo.Acc_ExecRep_Cust_09 

