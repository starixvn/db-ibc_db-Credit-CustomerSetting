/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[CS_Customer_GetHeadlinePossess]
	@SuperUsername VARCHAR(50)
AS

/*
	Created: 20190926@Percy
	DB: DBCUST.CustDB
	Task: CN88 - Select Headline Possess of Super Username

	Revisions:
		- 20190926@Percy: Initialize SP [Redmine: #118962]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @currentDate DATETIME = CONVERT(DATE, CURRENT_TIMESTAMP)

	DECLARE @SuperId INT
	SELECT  @SuperId = custid FROM dbo.Customer WITH (NOLOCK) WHERE username = @SuperUsername AND roleid = 4 AND site = 'CN88'

	IF ISNULL(@SuperId, 0) <> 0
	BEGIN
		DECLARE @ExtraPT TABLE (UplineId INT, ProductId INT, ExtraPT DECIMAL(9,8), IsCurrent TINYINT)

		INSERT INTO @ExtraPT (UplineId, ProductId, ExtraPT, IsCurrent)
		SELECT UplineId, ProductId, ExtraPT, CASE WHEN @currentDate >= FromDate THEN 1 ELSE 0 END AS IsCurrent
		FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
		WHERE SuperId = @SuperId
			AND ProductId IN (1, 3)
			AND Sporttype = 0 AND SubProduct = ''
			AND FromDate <= DATEADD(DAY, 1, @currentDate) -- current and tomorrow
			AND ToDate >= @currentDate

		IF EXISTS (SELECT 1 FROM @ExtraPT WHERE IsCurrent = 0)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM @ExtraPT HAVING COUNT(DISTINCT UplineId) = 2) -- not change Headline in tomorrow
			BEGIN
				DELETE @ExtraPT WHERE IsCurrent = 0
			END
		END

		;WITH CTE_ExtraPT AS (
			SELECT
				e1.UplineId	AS HeadlineId
				,u.Username	AS HeadlineUsername
				,(
					SELECT ProductId AS '@ProductId', ExtraPT AS '@ExtraPT'
					FROM @ExtraPT e2
					WHERE e1.UplineId = e2.UplineId AND e1.IsCurrent = e2.IsCurrent
					FOR XML PATH ('ExtraPT'), TYPE, ROOT ('ROOT')
				) AS ExtraPTSetting
				,e1.IsCurrent
			FROM @ExtraPT e1
				INNER JOIN dbo.Customer u WITH (NOLOCK) ON e1.UplineId = u.custid AND u.roleid = 0
			GROUP BY
				e1.UplineId
				,u.Username
				,e1.IsCurrent
		)
		SELECT
			@SuperId			AS SuperId
			,HeadlineId			AS Current_HeadlineId
			,HeadlineUsername	AS Current_HeadlineUsername
			,ExtraPTSetting		AS Current_ExtraPTSetting
			,Next_HeadlineId
			,Next_HeadlineUsername
			,Next_ExtraPTSetting
			,NoOfMember
		FROM CTE_ExtraPT curr
			OUTER APPLY (
				SELECT
					HeadlineId			AS Next_HeadlineId
					,HeadlineUsername	AS Next_HeadlineUsername
					,ExtraPTSetting		AS Next_ExtraPTSetting
				FROM CTE_ExtraPT
				WHERE IsCurrent = 0
			) [next]
			CROSS APPLY (
				SELECT COUNT(1) AS NoOfMember FROM dbo.Customer WITH (NOLOCK) WHERE srecommend = @SuperId AND roleid = 1
			) AS i
		WHERE IsCurrent = 1
	END
END
GO