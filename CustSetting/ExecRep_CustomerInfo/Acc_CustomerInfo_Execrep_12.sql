/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_12]
	@CustId						INT,
	@RoleId						TINYINT,
	@ReasonId					TINYINT = NULL,
	@PreventActionId 			TINYINT = NULL,
	@Comment					NVARCHAR(300) = NULL,

	@Action						VARCHAR(50),
	@AbnomalBetMember			VARCHAR(MAX) = NULL,
	@DirectMarkedCust			VARCHAR(MAX) = NULL,
	@ExcludeAbnormalMember		BIT = 0,
	@ExcludeDirectMark			BIT = 0,
	@IsSuccess					BIT = 1 OUTPUT,
	@SuccessDownlineList		VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20200210@Elodie
	DB: DBCUST/CustDB
	Task: Update Problem Account

	Revisions:
		- 20200210@Elodie: Initial SP [Redmine:#116814]

	Param's Explanation:
		@Action: MarkProblem, RemoveReduceBetLimit
		
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @SetBit1 INT, @Pos TINYINT
	CREATE TABLE #DownlineCust (CustID INT PRIMARY KEY, RoleID TINYINT)
	CREATE TABLE #DownlineSuccess (CustID INT)
	CREATE TABLE #DirectMarkCust (CustID INT, RoleID TINYINT)

	IF dbo.f_CheckRepTable('custInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('ProblemAccount') = 0 RETURN
	
	IF @RoleID = 4 --Super			
	BEGIN
		INSERT INTO #DownlineCust (CustID, RoleID)
		SELECT custid, roleid
		FROM custInfo c WITH(NOLOCK)
		WHERE srecommend = @CustID AND c.custid <> @CustId
	END
	ELSE IF @RoleID = 3 --Master
	BEGIN
		INSERT INTO #DownlineCust (CustID, RoleID)
		SELECT custid, roleid
		FROM custInfo c WITH(NOLOCK)
		WHERE mrecommend = @CustID AND c.custid <> @CustId
	END
	ELSE IF @RoleID = 2 --Agent
	BEGIN
		INSERT INTO #DownlineCust (CustID, RoleID)
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
			INSERT INTO dbo.ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, MaxBet, MaxPerEvent, CreatedDate, IsReviewed, IsAbnormalMember, ActionId)
			SELECT @CustId, @SetBit1, @ReasonId, @Comment, NULL, NULL, GETDATE(), 0, 0, @PreventActionId 
			WHERE NOT EXISTS (SELECT 1 FROM ProblemAccount WHERE CustId = @CustId)

			IF @@ROWCOUNT = 0
			BEGIN
				UPDATE pa 
				SET pa.ProblemStatus = ProblemStatus | @SetBit1,
					pa.CreatedDate = GETDATE(),
					pa.ReasonId = @ReasonId,
					pa.Comment = @Comment
				FROM dbo.ProblemAccount pa WITH (ROWLOCK)
				WHERE CustId = @CustId
			END

			SELECT @IsSuccess = 1	
		END TRY
		BEGIN CATCH
			SELECT @IsSuccess = 0
			RETURN			
		END CATCH

		UPDATE pa 		
		SET pa.ProblemStatus = ProblemStatus | @SetBit1
		OUTPUT Inserted.CustId INTO #DownlineSuccess
		FROM dbo.ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #DownlineCust t ON t.CustID = pa.CustId

		INSERT INTO dbo.ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, MaxBet, MaxPerEvent, CreatedDate, IsReviewed, IsAbnormalMember, ActionId)
		OUTPUT Inserted.CustId INTO #DownlineSuccess
		SELECT CustId, @SetBit1, NULL, NULL, NULL, NULL, GETDATE(), 0, 0, @PreventActionId 
		FROM #DownlineCust t
		WHERE NOT EXISTS (SELECT 1 FROM ProblemAccount WHERE CustId = t.CustId)

		SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
											FROM #DownlineSuccess l
											FOR XML PATH('')),1,1,'')		
	END	
	IF @Action = 'UpdateProblemAcc'
	BEGIN
		UPDATE pa 		
		SET pa.ActionId = @PreventActionId--,
			--pa.SubIssueTypeId = CASE WHEN t.RoleID = 1 AND @ReasonId = 109 THEN 38 ELSE pa.SubIssueTypeId END
		OUTPUT Inserted.CustId INTO #DownlineSuccess
		FROM dbo.ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #DownlineCust t ON t.CustID = pa.CustId

		SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
											FROM #DownlineSuccess l
											FOR XML PATH('')),1,1,'')		
	END
	ELSE IF @Action = 'RemoveReduceBetLimit'
	BEGIN
		UPDATE pa 
		SET pa.MaxBet = NULL,
			pa.MaxPerEvent = NULL
		FROM dbo.ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #DownlineCust t ON t.CustId = pa.CustId		
	END
	ELSE IF @Action = 'UpdateReviewStatus'
	BEGIN
		UPDATE pa 		
		SET pa.IsReviewed = 1
		OUTPUT Inserted.CustId INTO #DownlineSuccess
		FROM dbo.ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #DownlineCust t ON t.CustID = pa.CustId
		WHERE pa.IsReviewed = 0 
			AND (pa.ReasonId IS NOT NULL OR pa.IsAbnormalMember = 1)

		SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
											FROM #DownlineSuccess l
											FOR XML PATH('')),1,1,'')
	END
	ELSE IF @Action = 'UnmarkProblem'
	BEGIN
		IF @ExcludeAbnormalMember = 1
		BEGIN
			DELETE c 
			FROM #DownlineCust c
				INNER JOIN dbo.ProblemAccount pa WITH (NOLOCK) ON pa.CustId = c.CustID
			WHERE pa.IsAbnormalMember = 1
		END	
		IF @ExcludeDirectMark = 1
		BEGIN
			INSERT INTO #DirectMarkCust (CustID, RoleID)
			SELECT c.CustID, c.RoleID
			FROM #DownlineCust c
				INNER JOIN dbo.ProblemAccount pa WITH (NOLOCK) ON pa.CustId = c.CustID
			WHERE pa.ReasonId IS NOT NULL

			DELETE c 
			FROM #DownlineCust c
				INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.CustId = c.CustID
				INNER JOIN #DirectMarkCust dm WITH (NOLOCK) ON dm.CustId = CASE WHEN c.RoleID = 3 THEN ci.mrecommend
																				WHEN c.RoleID = 2 THEN ci.recommend END
				
			DELETE c 
			FROM #DownlineCust c
				INNER JOIN #DirectMarkCust dm WITH (NOLOCK) ON dm.CustID = c.CustID
		END	

		DELETE pa 
		OUTPUT Deleted.CustId INTO #DownlineSuccess
		FROM dbo.ProblemAccount pa WITH (ROWLOCK)
			INNER JOIN #DownlineCust c ON c.CustID = pa.CustId

		SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
											FROM #DownlineSuccess l
											FOR XML PATH('')),1,1,'')
	END
	DROP TABLE #DownlineCust
END
GO