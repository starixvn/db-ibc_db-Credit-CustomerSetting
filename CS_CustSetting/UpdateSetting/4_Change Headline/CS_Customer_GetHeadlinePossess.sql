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
	SELECT  @SuperId = custid FROM dbo.Customer WITH (NOLOCK) WHERE username = @SuperUsername AND roleid = 4

	IF ISNULL(@SuperId, 0) <> 0
	BEGIN
		SELECT
			@SuperId AS SuperId
			,u.HeadlineId
			,u.HeadlineUsername
			,e.ExtraPTSetting
			,i.NoOfMember
		FROM (
			SELECT
				u.custid	AS HeadlineId
				,u.username AS HeadlineUsername
			FROM dbo.CustSuper cs WITH (NOLOCK)
				INNER JOIN dbo.Customer u WITH (NOLOCK) ON cs.UplineId = u.custid
			WHERE cs.custid = @SuperId AND u.roleid = 0
		) AS u
			CROSS APPLY (
				SELECT (
					SELECT ProductId AS '@ProductId', ExtraPT AS '@ExtraPT'
					FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
					WHERE SuperId = @SuperId
						AND ProductId IN (1, 3)
						AND Sporttype = 0 AND SubProduct = ''
						AND @currentDate BETWEEN FromDate AND ToDate
					FOR XML PATH ('ExtraPT'), TYPE, ROOT ('ROOT')
				) AS ExtraPTSetting
			) AS e
			CROSS APPLY (
				SELECT COUNT(1) AS NoOfMember FROM dbo.Customer WITH (NOLOCK) WHERE srecommend = @SuperId AND roleid = 1
			) AS i
	END
END
GO