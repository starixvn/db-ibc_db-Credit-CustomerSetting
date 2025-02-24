/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_12]
	@CustId						INT,
	@RoleId						TINYINT,
	@ReasonId					TINYINT = NULL,
	@PreventActionId 			TINYINT = NULL,
	@Comment					NVARCHAR(300) = NULL,
	@VoidTime					VARCHAR(50) = '',
	@LimitAmount 				MONEY = 0,
	@UpdateTime					BIT = 0,	
	
	@UserID						INT = 0,
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
		- 20200720@Johnson: Add void time & Limit amount [redmine:#135253]
		- 20201016@Elodie: Output all downline list is removed PA [Redmine:#141756]
		- 20210422@Johnson: change source ProblemAccount to ProblemAccountClassification for UpdateReviewStatus [redmine:#153059]
		- 20220422@Johnson: Add Creator into ProblemAccount [redmine: #171686]
		- 20240807@Helios: Scale Out DBCUST - Apply Inhouse replication for tables of problem account [Redmine:#209747]
		- 20250219@Helios: HF - Apply Inhouse replication for tables of problem account [Redmine:#218106] 
	Param's Explanation:
		@Action: MarkProblem, RemoveReduceBetLimit
		
*/
BEGIN
	SET NOCOUNT ON

	IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
		AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
	)
	RETURN;

	DECLARE @SetBit1 INT, @Pos TINYINT, @SubIssueTypeId TINYINT
	CREATE TABLE #DownlineCust (CustID INT PRIMARY KEY, RoleID TINYINT)
	CREATE TABLE #DownlineSuccess (CustID INT)
	CREATE TABLE #DirectMarkCust (CustID INT, RoleID TINYINT)
	
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

	SELECT @SubIssueTypeId = SubIssueTypeId 
	FROM dbo.ProblemAccountAction WITH (NOLOCK)
	WHERE ActionId = @PreventActionId

	IF @Action = 'MarkProblem'
	BEGIN
		IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
		BEGIN
			SELECT	@Pos = CASE @RoleId WHEN 4 THEN 3
										WHEN 3 THEN 2
										WHEN 2 THEN 1
										WHEN 1 THEN 0 END					
			
			SELECT @SetBit1 = POWER(2, @Pos)								

			BEGIN TRY			
				INSERT INTO dbo.ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, MaxBet, MaxPerEvent, CreatedDate, IsReviewed, IsAbnormalMember, ActionId, SubIssueTypeId, VoidTime, LimitAmount, Creator, RepUpdateTime)
				SELECT @CustId, @SetBit1, @ReasonId, @Comment, NULL, NULL, GETDATE(), 0, 0, @PreventActionId, 
					CASE WHEN @RoleId = 1 THEN @SubIssueTypeId ELSE NULL END,
					@VoidTime, @LimitAmount, @UserId , [dbo].[f_GetDateTime2]()
				WHERE NOT EXISTS (SELECT 1 FROM ProblemAccount WHERE CustId = @CustId)

				IF @@ROWCOUNT = 0
				BEGIN
					UPDATE pa 
					SET pa.ProblemStatus = ProblemStatus | @SetBit1,
						pa.CreatedDate = GETDATE(),
						pa.ReasonId = @ReasonId,
						pa.Comment = @Comment,
						pa.ActionId = @PreventActionId,
						pa.SubIssueTypeId = CASE WHEN @RoleId = 1 THEN @SubIssueTypeId ELSE NULL END,
						pa.VoidTime = @VoidTime,
						pa.LimitAmount = @LimitAmount,
						pa.Creator = @UserId,
						pa.RepUpdateTime = [dbo].[f_GetDateTime2]()
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
			SET pa.ProblemStatus = ProblemStatus | @SetBit1,
				pa.ActionId = @PreventActionId,
				pa.SubIssueTypeId = CASE WHEN t.RoleID = 1 THEN @SubIssueTypeId ELSE NULL END,
				pa.VoidTime = @VoidTime,
				pa.Creator = @UserId,
				pa.RepUpdateTime = [dbo].[f_GetDateTime2]()
			OUTPUT Inserted.CustId INTO #DownlineSuccess
			FROM dbo.ProblemAccount pa WITH (ROWLOCK)
				INNER JOIN #DownlineCust t ON t.CustID = pa.CustId

			INSERT INTO dbo.ProblemAccount (CustId, ProblemStatus, ReasonId, Comment, MaxBet, MaxPerEvent, CreatedDate, IsReviewed, IsAbnormalMember, ActionId, SubIssueTypeId, VoidTime, LimitAmount, Creator, RepUpdateTime)
			OUTPUT Inserted.CustId INTO #DownlineSuccess
			SELECT CustId, @SetBit1, NULL, NULL, NULL, NULL, GETDATE(), 0, 0, @PreventActionId,			
				CASE WHEN t.RoleID = 1 THEN @SubIssueTypeId ELSE NULL END,
				@VoidTime, 0, @UserId, [dbo].[f_GetDateTime2]()
			FROM #DownlineCust t
			WHERE NOT EXISTS (SELECT 1 FROM ProblemAccount WHERE CustId = t.CustId)

			SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
												FROM #DownlineSuccess l
												FOR XML PATH('')),1,1,'')	
		END
	END	
	IF @Action = 'UpdateProblemAcc'
	BEGIN
		IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
		BEGIN
			UPDATE pa 		
			SET pa.ActionId = @PreventActionId,
				pa.SubIssueTypeId = CASE WHEN t.RoleID = 1 THEN @SubIssueTypeId ELSE NULL END,
				pa.VoidTime = CASE WHEN @UpdateTime = 1 THEN @VoidTime 
								WHEN @UpdateTime = 0 AND (@PreventActionId <> 2 
														OR (@PreventActionId =2 AND pa.ActionId <> 2)
														)
								THEN 'At Settlement'
								ELSE pa.VoidTime END,
				pa.LimitAmount = CASE WHEN @PreventActionId <> 2 THEN 0 ELSE pa.LimitAmount END,
				pa.RepUpdateTime =  [dbo].[f_GetDateTime2]()
			OUTPUT Inserted.CustId INTO #DownlineSuccess
			FROM dbo.ProblemAccount pa WITH (ROWLOCK)
				INNER JOIN #DownlineCust t ON t.CustID = pa.CustId

			SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
												FROM #DownlineSuccess l
												FOR XML PATH('')),1,1,'')		
		END
	END
	ELSE IF @Action = 'RemoveReduceBetLimit'
	BEGIN
		IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
		BEGIN
			UPDATE pa 
			SET pa.MaxBet = NULL,
				pa.MaxPerEvent = NULL,
				pa.RepUpdateTime =  [dbo].[f_GetDateTime2]()
			FROM dbo.ProblemAccount pa WITH (ROWLOCK)
				INNER JOIN #DownlineCust t ON t.CustId = pa.CustId
		END
	END
	ELSE IF @Action = 'UpdateReviewStatus'
	BEGIN
		IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
		BEGIN
			UPDATE pa 		
			SET pa.IsReviewed = 1 , pa.RepUpdateTime = [dbo].[f_GetDateTime2]()
			OUTPUT Inserted.CustId INTO #DownlineSuccess
			FROM dbo.ProblemAccountClassification pa WITH (ROWLOCK)
				INNER JOIN #DownlineCust t ON t.CustID = pa.CustId
			WHERE pa.IsReviewed = 0 
				--AND (pa.ReasonId IS NOT NULL OR pa.IsAbnormalMember = 1)

			SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
												FROM #DownlineSuccess l
												FOR XML PATH('')),1,1,'')
		END
	END
	ELSE IF @Action = 'UnmarkProblem'
	BEGIN
		IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
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
					INNER JOIN #DirectMarkCust dm WITH (NOLOCK) ON dm.CustId = CASE WHEN dm.RoleID = 3 THEN ci.mrecommend
																					WHEN dm.RoleID = 2 THEN ci.recommend END
				
				DELETE c 
				FROM #DownlineCust c
					INNER JOIN #DirectMarkCust dm WITH (NOLOCK) ON dm.CustID = c.CustID
			END	

			DELETE pa 
			OUTPUT Deleted.CustId INTO #DownlineSuccess
			FROM dbo.ProblemAccount pa WITH (ROWLOCK)
				INNER JOIN #DownlineCust c ON c.CustID = pa.CustId

			INSERT INTO ProblemAccount_Del_InHouse (CustID , RepUpdateTime)
			SELECT CustID , [dbo].[f_GetDateTime2]() FROM #DownlineSuccess 

			SELECT @SuccessDownlineList = STUFF((SELECT ','+ CAST(l.CustID AS VARCHAR(20))
												FROM #DownlineSuccess l
												FOR XML PATH('')),1,1,'')

			SELECT @SuccessDownlineList = ISNULL(@SuccessDownlineList,'')
		END
	END
	DROP TABLE #DownlineCust
END
GO