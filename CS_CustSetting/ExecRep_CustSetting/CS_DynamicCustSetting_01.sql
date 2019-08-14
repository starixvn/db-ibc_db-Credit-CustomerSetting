/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[CS_DynamicCustSetting_01]
	@CustId						INT,
	@RoleId						TINYINT,
	@ReasonId					TINYINT = NULL,
	@Comment					NVARCHAR(300) = NULL,

	@Action						VARCHAR(50),
	@AbnomalBetMember			VARCHAR(MAX) = NULL,
	@DirectMarkedCust			VARCHAR(MAX) = NULL,
	@IsSuccess					BIT = 1 OUTPUT,
	@SuccessDownlineList		VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20190808@Elodie
	DB: DBCUST/CustDB
	Task: Execrep SP

	Revisions:
		- 20190808@Elodie: Initial SP [Redmine:#116814]

	Param's Explanation:
		@Action: MarkProblem, ReduceBetLimit, RemoveReduceBetLimit
		
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @SetBit1 INT, @Pos TINYINT
	CREATE TABLE #TempCust (CustID INT PRIMARY KEY, RoleID TINYINT)
	CREATE TABLE #IgnoreCust (CustID INT PRIMARY KEY)
	CREATE TABLE #DownlineSuccess (CustID INT)

	IF dbo.f_CheckRepTable('custInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CS_ProblemAccount') = 0 RETURN
	
	IF @RoleID = 4 --Super			
	BEGIN
		INSERT INTO #TempCust (CustID, RoleID)
		SELECT custid, roleid
		FROM custInfo c WITH(NOLOCK)
		WHERE srecommend = @CustID AND c.custid <> @CustId
	END
	ELSE IF @RoleID = 3 --Master
	BEGIN
		INSERT INTO #TempCust (CustID, RoleID)
		SELECT custid, roleid
		FROM custInfo c WITH(NOLOCK)
		WHERE mrecommend = @CustID AND c.custid <> @CustId
	END
	ELSE IF @RoleID = 2 --Agent
	BEGIN
		INSERT INTO #TempCust (CustID, RoleID)
		SELECT custid, roleid
		FROM custInfo c WITH(NOLOCK)
		WHERE recommend = @CustID AND c.custid <> @CustId
	END	

	IF @Action = 'MarkProblem'
	BEGIN
		SELECT	@Pos = CASE @RoleId WHEN 4 THEN 3
									WHEN 3 THEN 2
									WHEN 2 THEN 1
									WHEN 1 THEN 0 END					
			
		SELECT @SetBit1 = POWER(2, @Pos)								

		BEGIN TRY
			INSERT INTO dbo.CS_ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, IsReducedBetLimit, MaxBet, MaxPerEvent, CreatedDate, IsReviewed)
			SELECT @CustId, @SetBit1, @ReasonId, @Comment, 0, NULL, NULL, GETDATE(), 0
			WHERE NOT EXISTS (SELECT 1 FROM CS_ProblemAccount WHERE CustId = @CustId)

			UPDATE pa 
			SET pa.ProblemStatus = ProblemStatus | @SetBit1,
				pa.ReasonId = @ReasonId,
				pa.Comment = @Comment
			FROM dbo.CS_ProblemAccount pa WITH (ROWLOCK)
			WHERE CustId = @CustId			
		END TRY
		BEGIN CATCH
			SELECT @IsSuccess = 0
			RETURN			
		END CATCH

		INSERT INTO dbo.CS_ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, IsReducedBetLimit, MaxBet, MaxPerEvent, CreatedDate, IsReviewed)
		OUTPUT Inserted.CustId INTO #DownlineSuccess
		SELECT CustId, @SetBit1, NULL, NULL, 0, NULL, NULL, GETDATE(), 0 
		FROM #TempCust t
		WHERE NOT EXISTS (SELECT 1 FROM CS_ProblemAccount WHERE CustId = t.CustId)

		UPDATE pa 		
		SET pa.ProblemStatus = ProblemStatus | @SetBit1
		OUTPUT Inserted.CustId INTO #DownlineSuccess
		FROM dbo.CS_ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #TempCust t ON t.CustID = pa.CustId

		SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
											FROM #DownlineSuccess l
											FOR XML PATH('')),1,1,'')		
	END
	ELSE IF @Action = 'ReduceBetLimit'
	BEGIN		
		UPDATE pa 		
		SET pa.IsReducedBetLimit = 1
		FROM dbo.CS_ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #TempCust t ON t.CustID = pa.CustId
	END
	ELSE IF @Action = 'RemoveReduceBetLimit'
	BEGIN
		IF ISNULL(@DirectMarkedCust,'') <> ''
		BEGIN
			INSERT INTO #IgnoreCust (CustID)			
			SELECT CAST(val AS INT)
			FROM dbo.f_StringSplit(@DirectMarkedCust, ',') f

			IF @RoleId = 4
			BEGIN
				DELETE t 
				FROM #TempCust t
					INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = t.CustID
					INNER JOIN #IgnoreCust i ON ci.srecommend = i.CustID
			END
			ELSE IF @RoleId = 3
			BEGIN
				DELETE t 
				FROM #TempCust t
					INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = t.CustID
					INNER JOIN #IgnoreCust i ON ci.mrecommend = i.CustID
			END
			ELSE IF @RoleId = 2
			BEGIN
				DELETE t 
				FROM #TempCust t
					INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = t.CustID
					INNER JOIN #IgnoreCust i ON ci.recommend = i.CustID
			END

			DELETE FROM #IgnoreCust
		END

		IF ISNULL(@AbnomalBetMember,'') <> ''
		BEGIN
			INSERT INTO #IgnoreCust (CustID)			
			SELECT CAST(val AS INT)
			FROM dbo.f_StringSplit(@AbnomalBetMember, ',') f

			DELETE t 
			FROM #TempCust t
				INNER JOIN #IgnoreCust i ON t.CustID = i.CustID

			DELETE FROM #IgnoreCust
		END

		UPDATE pa 
		SET pa.MaxBet = NULL,
			pa.MaxPerEvent = NULL,
			pa.IsReducedBetLimit = 0
		FROM dbo.CS_ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #TempCust t ON t.CustId = pa.CustId
		
	END

	DROP TABLE #TempCust
END
GO