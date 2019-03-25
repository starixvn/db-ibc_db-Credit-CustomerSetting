/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" isFunction="0" isNested="1"></info>*/
USE [CustDB]
GO

ALTER PROCEDURE [dbo].[CS_DynamicCustomerInfo_01]
	@CustId			INT,
	@RoleId			TINYINT,
	@Action			VARCHAR(50) = '',
	@StatusId		TINYINT = 0,
	@UpdStatusId	TINYINT = 0,
	@SystemId		TINYINT = 1
AS

/*
	Created: 20181218@Percy
	DB: DBCUST.CustDB
	Task: Execrep SP

	Revisions:
		- 20181218@Percy: Initialize SP: Update status customer whole line [RedmineID: #105338]

	Param's Explanation:
		@UpdStatusId:
			1: Open
			2: Suspended
			3: Closed
*/

BEGIN
	SET NOCOUNT ON

	IF dbo.f_CheckRepTable('custInfo') = 1
	BEGIN
		IF @Action = 'UpdateStatus'
		BEGIN
			-- This account
			CREATE TABLE #tmpCust (CustId INT PRIMARY KEY)
			INSERT INTO #tmpCust (CustId)
			VALUES (@CustId)

			-- Downlines
			IF @RoleId = 4
			BEGIN
				INSERT INTO #tmpCust (CustId)
				SELECT CustId
				FROM dbo.custInfo WITH (NOLOCK)
				WHERE srecommend = @CustId
					AND roleId < 4
					AND 1 = CASE
						WHEN @StatusId = 1 AND @UpdStatusId = 2 AND ISNULL(reject, 0) = 0 AND ISNULL(closed, 0) = 0 THEN 1
						WHEN @StatusId = 1 AND @UpdStatusId = 3 AND ISNULL(closed, 0) = 0 THEN 1
						WHEN @StatusId = 2 AND ISNULL(reject, 0) = 1 AND ISNULL(closed, 0) = 0 THEN 1
						ELSE 0 END
			END
			ELSE IF @RoleId = 3
			BEGIN
				INSERT INTO #tmpCust (CustId)
				SELECT CustId
				FROM dbo.custInfo WITH (NOLOCK)
				WHERE mrecommend = @CustId
					AND roleId < 3
					AND 1 = CASE
						WHEN @StatusId = 1 AND @UpdStatusId = 2 AND ISNULL(reject, 0) = 0 AND ISNULL(closed, 0) = 0 THEN 1
						WHEN @StatusId = 1 AND @UpdStatusId = 3 AND ISNULL(closed, 0) = 0 THEN 1
						WHEN @StatusId = 2 AND ISNULL(reject, 0) = 1 AND ISNULL(closed, 0) = 0 THEN 1
						ELSE 0 END
			END
			ELSE IF @RoleId = 2
			BEGIN
				INSERT INTO #tmpCust (CustId)
				SELECT CustId
				FROM dbo.custInfo WITH (NOLOCK)
				WHERE recommend = @CustId
					AND roleId < 2
					AND 1 = CASE
						WHEN @StatusId = 1 AND @UpdStatusId = 2 AND ISNULL(reject, 0) = 0 AND ISNULL(closed, 0) = 0 THEN 1
						WHEN @StatusId = 1 AND @UpdStatusId = 3 AND ISNULL(closed, 0) = 0 THEN 1
						WHEN @StatusId = 2 AND ISNULL(reject, 0) = 1 AND ISNULL(closed, 0) = 0 THEN 1
						ELSE 0 END
			END
				
			UPDATE ci WITH (ROWLOCK, UPDLOCK)
			SET reject	= CASE @UpdStatusId WHEN 1 THEN 0 WHEN 2 THEN 1 ELSE reject END,
				closed	= CASE @UpdStatusId WHEN 1 THEN 0 WHEN 2 THEN 0 ELSE 1 END
			FROM dbo.custInfo ci
				INNER JOIN #tmpCust tc ON ci.custid = tc.custid

			IF @UpdStatusId = 3
			BEGIN
				IF dbo.f_CheckRepTable('CustLoginInfo') = 1 AND dbo.f_CheckRepTable('CustLoginInfo_Member') = 1
				BEGIN
					DECLARE @ClosedReason TINYINT
					SELECT  @ClosedReason = CASE WHEN @SystemId = 1 THEN 1 ELSE 2 END
				
					UPDATE cl
					SET cl.ClosedReason = @ClosedReason
					FROM dbo.CustLoginInfo cl with (ROWLOCK, UPDLOCK)
						INNER JOIN #tmpCust tc ON cl.CustId = tc.CustId
					
					UPDATE cl
					SET cl.ClosedReason = @ClosedReason
					FROM dbo.CustLoginInfo_Member cl WITH (ROWLOCK, UPDLOCK)
						INNER JOIN #tmpCust tc ON cl.CustId = tc.CustId

					INSERT INTO dbo.CustLoginInfo_Member (CustId, SecurityCode, IP, LastChangedId, LastChangedDate, ClosedReason)
					SELECT tc.CustId, NULL, NULL, NULL, GETDATE(), @ClosedReason
					FROM #tmpCust tc
						INNER JOIN custInfo ci ON tc.CustId = ci.CustId
						LEFT JOIN dbo.CustLoginInfo_Member cl WITH (NOLOCK) ON tc.CustId = cl.CustId
					WHERE ci.roleId = 1 AND cl.CustId IS NULL
				END
			END

			DROP TABLE #tmpCust
		END
	END
END
GO