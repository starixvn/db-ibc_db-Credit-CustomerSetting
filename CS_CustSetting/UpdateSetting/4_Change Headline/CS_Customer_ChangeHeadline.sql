/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_alpv" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[CS_Customer_ChangeHeadline]
	@UserId				INT
	,@SuperId			INT
	,@HeadlineUsername	VARCHAR(50)
	,@ExtraPTSetting	VARCHAR(MAX)
	,@EffectiveDate		DATETIME
	,@IP				VARCHAR(15) = ''
	,@ErrCode			INT = 0 OUTPUT
	,@ErrMsg			NVARCHAR(4000) = '' OUTPUT
AS

/*
	Created: 20190926@Percy
	DB: DBCUST.CustDB
	Task: CN88 - Change Headline of Super

	Revisions:
		- 20190926@Percy: Initialize SP [Redmine: #118962]
		- 20200309@Sophia: Allow to set Headline PT up to 5% [Redmine: #129665]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME, @Duration INT
	SELECT  @startRun = CURRENT_TIMESTAMP

	DECLARE @LogSPData VARCHAR(MAX), @LogSPData_Old VARCHAR(MAX), @XmlData XML, @XmlData_Old XML

	SELECT @ErrCode = 0, @ErrMsg = ''

	DECLARE @currentDate DATETIME = CONVERT(DATE, CURRENT_TIMESTAMP)

	DECLARE @Old_HeadlineId INT, @Old_HeadlineUsername VARCHAR(50)
	DECLARE @HeadlineId INT, @HeadlineCurrency TINYINT, @SuperCurrency TINYINT
	DECLARE @NoOfMember INT

	/* ===== Check Invalid Input Params ===== */
	BEGIN
		SELECT @HeadlineUsername = LTRIM(RTRIM(ISNULL(@HeadlineUsername, '')))
		SELECT @HeadlineId = custid, @HeadlineCurrency = currency FROM dbo.Customer WITH (NOLOCK) WHERE username = @HeadlineUsername AND roleid = 0

		IF @HeadlineId IS NULL
		BEGIN
			SELECT @ErrCode = 101, @ErrMsg = 'Invalid Headline.'
			RETURN
		END

		SELECT @SuperCurrency = currency FROM dbo.Customer WITH (NOLOCK) WHERE custid = @SuperId AND roleid = 4
		
		SELECT @Old_HeadlineId = u.custid, @Old_HeadlineUsername = u.username
		FROM dbo.Customer u WITH (NOLOCK)
			INNER JOIN dbo.CustSuper cs WITH (NOLOCK) ON u.custid = cs.UplineId
		WHERE cs.custid = @SuperId AND u.roleid = 0

		IF @SuperCurrency IS NULL OR ISNULL(@Old_HeadlineUsername , '') = ''
		BEGIN
			SELECT @ErrCode = 102, @ErrMsg = 'Invalid Super.'
			RETURN
		END

		IF @SuperCurrency <> @HeadlineCurrency
		BEGIN
			SELECT @ErrCode = 103, @ErrMsg = 'Currency of Super and new Headline does not match.'
			RETURN
		END

		IF @Old_HeadlineUsername = @HeadlineUsername
		BEGIN
			SELECT @ErrCode = 104, @ErrMsg = 'The new Headline must be different from old'
			RETURN
		END

		SELECT @NoOfMember = COUNT(1) FROM dbo.Customer WITH (NOLOCK) WHERE srecommend = @SuperId AND roleid = 1

		IF @NoOfMember = 0 AND @EffectiveDate <> @currentDate
		BEGIN
			SELECT @ErrCode = 105, @ErrMsg = 'Effective Date must be today'
			RETURN
		END

		IF @NoOfMember <> 0 AND @EffectiveDate <> DATEADD(DAY, 1, @currentDate)
		BEGIN
			SELECT @ErrCode = 106, @ErrMsg = 'Effective Date must be tomorrow'
			RETURN
		END
	END
	/* ===== End Check Invalid Input Params ===== */

	/* ===== Update Extra PT Setting ===== */
	BEGIN
		DECLARE @GroupId INT, @GroupName VARCHAR(50), @Old_GroupId INT

		DECLARE @ExtraPTSetting_XML XML
		DECLARE @tblExtraPTSetting TABLE (ProductId INT, ExtraPT DECIMAL(9,8))

		BEGIN TRY
			SELECT @ExtraPTSetting_XML = CONVERT(XML, @ExtraPTSetting)

			INSERT INTO @tblExtraPTSetting (ProductId, ExtraPT)
			SELECT t.c.value('@ProductId', 'INT') AS ProductId, t.c.value('@ExtraPT', 'DECIMAL(9,8)') AS ExtraPT
			FROM @ExtraPTSetting_XML.nodes('ROOT/ExtraPT') AS t(c)
			OPTION (OPTIMIZE FOR (@ExtraPTSetting_XML = NULL))
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 110, @ErrMsg = 'ExtraPT''s Paramter Invalid'
			RETURN
		END CATCH

		SELECT @GroupId = s.GroupId, @GroupName = s.GroupName
		FROM dbo.Acc_GroupExtraPT_Product s WITH (NOLOCK)
			INNER JOIN @tblExtraPTSetting e ON s.ProductID = e.ProductID AND s.ExtraPT = e.ExtraPT
		WHERE s.ProductID IN (1, 3)
			AND s.Sporttype = 0 AND s.SubProduct = ''
			AND s.GroupName LIKE 'CN88_%'
			AND @currentDate BETWEEN s.FromDate AND s.ToDate
		GROUP BY s.GroupId, s.GroupName
		HAVING COUNT(1) = 2

		IF @GroupId IS NULL
		BEGIN
			SELECT @ErrCode = 111, @ErrMsg = N'Invalid rates.'
			RETURN
		END

		SELECT TOP 1 @Old_GroupId = GroupId
		FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
		WHERE SuperId = @SuperId
			AND Sporttype = 0 AND SubProduct = ''
			AND @currentDate BETWEEN FromDate AND ToDate

		SELECT @XmlData_Old = (
			SELECT	@Old_HeadlineId			AS '@HeadlineID'
					,@Old_HeadlineUsername	AS '@Headline'
					,SportsbookPossess		AS '@SportsbookPossess'
					,NonSportsPossess		AS '@NonSportsPossess'
					,EffectiveDate			AS '@EffectiveDate'
					,@IP					AS '@IP'
			FROM (
				SELECT
					CONVERT(VARCHAR(10), p.FromDate, 120) AS EffectiveDate
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.SportsbookPossess)) AS SportsbookPossess
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.NonSportsPossess)) AS NonSportsPossess
				FROM (
					SELECT CASE ProductId WHEN 1 THEN 'Sportsbook' ELSE 'NonSports' END + 'Possess' AS Product, ExtraPT, FromDate
					FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
					WHERE SuperId = @SuperId
						AND ProductId IN (1, 3)
						AND Sporttype = 0 AND SubProduct = ''
						AND @currentDate BETWEEN FromDate AND ToDate
				) AS s
				PIVOT (
					MAX(ExtraPT)
					FOR Product IN (SportsbookPossess, NonSportsPossess)
				) AS p
			) AS t
			FOR XML PATH ('R'), TYPE
		)

		EXEC dbo.CS_GroupExtraPT_Ins
			@SuperId		= @SuperId
			,@HeadlineId	= @HeadlineId
			,@GroupId		= @GroupId
			,@EffectiveDate = @EffectiveDate
			,@ErrCode		= @ErrCode OUTPUT
			,@ErrMsg		= @ErrMsg OUTPUT

		IF @ErrCode <> 0
		BEGIN
			SELECT @ErrCode = 112, @ErrMsg = 'Update failed. Please try again'
			RETURN
		END
	END
	/* ===== End Update Extra PT Setting ===== */

	/* ===== Update Customer Setting ===== */
	BEGIN
		DECLARE @GroupHeadlineId INT, @Old_GroupHeadlineId INT
		SELECT  @GroupHeadlineId = GroupId FROM dbo.CustGroupHeadline WITH (NOLOCK) WHERE custid = @HeadlineId
		SELECT  @Old_GroupHeadlineId = GroupId FROM dbo.CustGroupHeadline WITH (NOLOCK) WHERE custid = @Old_HeadlineId
		
		BEGIN TRY
			-- CustSuper
			UPDATE dbo.CustSuper WITH (ROWLOCK) SET UplineId = @HeadlineId WHERE custid = @SuperId
			-- custAccount
			UPDATE dbo.custAccount WITH (ROWLOCK) SET GroupId = @GroupHeadlineId WHERE custid = @SuperId
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 113, @ErrMsg = 'Update failed. Please try again'

			-- Rollback Extra PT Setting
			EXEC dbo.CS_GroupExtraPT_Ins
				@SuperId		= @SuperId
				,@HeadlineId	= @Old_HeadlineId
				,@GroupId		= @Old_GroupId
				,@EffectiveDate = @currentDate
				,@IsRollBack	= 1

			-- Rollback CustSuper
			UPDATE dbo.CustSuper WITH (ROWLOCK) SET UplineId = @Old_HeadlineId WHERE custid = @SuperId
			-- Rollback custAccount
			UPDATE dbo.custAccount WITH (ROWLOCK) SET GroupId = @Old_GroupHeadlineId WHERE custid = @SuperId

			RETURN
		END CATCH

		SELECT @XmlData = (
			SELECT	@HeadlineId				AS '@HeadlineID'
					,@HeadlineUsername		AS '@Headline'
					,SportsbookPossess		AS '@SportsbookPossess'
					,NonSportsPossess		AS '@NonSportsPossess'
					,EffectiveDate			AS '@EffectiveDate'
					,@IP					AS '@IP'
			FROM (
				SELECT
					CONVERT(VARCHAR(10), p.FromDate, 120) AS EffectiveDate
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.SportsbookPossess)) AS SportsbookPossess
					,dbo.f_CS_FomatNumber(CONVERT(VARCHAR(50), p.NonSportsPossess)) AS NonSportsPossess
				FROM (
					SELECT CASE ProductId WHEN 1 THEN 'Sportsbook' ELSE 'NonSports' END + 'Possess' AS Product, ExtraPT, FromDate
					FROM dbo.Acc_GroupExtraPTSetting WITH (NOLOCK)
					WHERE SuperId = @SuperId
						AND ProductId IN (1, 3)
						AND Sporttype = 0 AND SubProduct = ''
						AND @EffectiveDate BETWEEN FromDate AND ToDate
				) AS s
				PIVOT (
					MAX(ExtraPT)
					FOR Product IN (SportsbookPossess, NonSportsPossess)
				) AS p
			) AS t
			FOR XML PATH ('R'), TYPE
		)
	END
	/* ===== End Update Customer Setting ===== */

	/* ===== Write log ===== */
	BEGIN
		SELECT @Duration = DATEDIFF(MILLISECOND, @startRun, CURRENT_TIMESTAMP)
		SELECT @LogSPData = CONVERT(VARCHAR(MAX), @XmlData), @LogSPData_Old = CONVERT(VARCHAR(MAX), @XmlData_Old)
	
		EXEC CS_WriteLog_UserLog_RunSP_Wrapper
			@UserId				= @UserId
			,@CustID			= @SuperId
			,@ActionID			= 160014
			,@TrackingValue		= @LogSPData
			,@TrackingValue2	= @logSPData_Old
			,@Duration			= @Duration
	END
	/* ===== End Write log ===== */
END
GO