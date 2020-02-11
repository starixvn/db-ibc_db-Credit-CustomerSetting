/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[CS_GroupExtraPT_Ins]
	@SuperId			INT
	,@HeadlineId		INT
	,@GroupId			INT = 0
	,@EffectiveDate		DATETIME
	,@IsRollBack		BIT = 0
	,@GroupName 		VARCHAR(50) = '' OUTPUT
	,@ErrCode			INT = 0 OUTPUT
	,@ErrMsg			NVARCHAR(1000) = '' OUTPUT
AS

/*
	Creator: 20190620@Sophia
	Task: CN88 - Add Super's ExtraPT Setting
	DB: DBCUST.CustDB
	
	Revisions:
		- 20190620@Sophia: Initialize SP [RedmineID: #114912]
		- 20190926@Percy: Change Headline's Super [RedmineID: #118962]
	 
	Param's Explanation:
		- @GroupId = 0: get default group
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @currentDate DATETIME, @EndDate DATETIME, @FromDate DATETIME
	SELECT  @currentDate = CONVERT(DATE, GETDATE()), @EndDate = '9999-12-31'
	
	IF @IsRollBack = 0 OR @GroupId IS NOT NULL
	BEGIN
		IF @EffectiveDate < @currentDate
		BEGIN
			SELECT @ErrCode = 101, @ErrMsg = N'Invalid effective date.'
			RETURN
		END

		IF @GroupId = 0 -- get default group
		BEGIN
			SELECT @GroupId = GroupId FROM dbo.CS_HeadlineExtraPTGroup WITH (NOLOCK) WHERE HeadlineId = @HeadlineId
		END

		SELECT TOP 1 @GroupName = GroupName FROM dbo.Acc_GroupExtraPT_Product WITH (NOLOCK) WHERE GroupId = @GroupId
			
		IF @GroupName IS NULL
		BEGIN			 
			SELECT @ErrCode = 102, @ErrMsg = N'Invalid rates.'
			RETURN
		END

		BEGIN TRY
			DELETE dbo.Acc_GroupExtraPTSetting WITH (ROWLOCK, UPDLOCK)
			WHERE SuperId = @SuperId
				AND FromDate >= @EffectiveDate
				AND ToDate >= @currentDate

			UPDATE dbo.Acc_GroupExtraPTSetting WITH (ROWLOCK)
			SET ToDate = DATEADD(DAY, -1, @EffectiveDate)
			WHERE SuperId = @SuperId
				AND FromDate < @EffectiveDate
				AND ToDate >= @currentDate

			INSERT INTO dbo.Acc_GroupExtraPTSetting (SuperId, GroupId, GroupName, ProductId, Sporttype, SubProduct, ExtraPT, FromDate, ToDate, UplineId)
			SELECT @SuperId, GroupId, GroupName, ProductId, Sporttype, SubProduct, ExtraPT
					,CASE WHEN @EffectiveDate < FromDate THEN FromDate ELSE @EffectiveDate END AS FromDate
					,CASE WHEN @EndDate < ToDate THEN @EndDate ELSE ToDate END AS ToDate
					,@HeadlineId AS UplineId
			FROM dbo.Acc_GroupExtraPT_Product WITH (NOLOCK)
			WHERE GroupId = @GroupId
				AND @EffectiveDate <= ToDate
		END TRY
		BEGIN CATCH			
			SELECT @ErrCode = 104,
				@ErrMsg = 'Error when insert/update/detete data.'
				
			DELETE dbo.Acc_GroupExtraPTSetting WITH (ROWLOCK, UPDLOCK)
			WHERE SuperId = @SuperId
				AND ToDate >= @currentDate

			RETURN
		END CATCH	
	END
	ELSE -- Rollback incase failed
	BEGIN
		-- delete redundant data
		DELETE dbo.Acc_GroupExtraPTSetting WITH (ROWLOCK, UPDLOCK)
		WHERE SuperId = @SuperId
				AND ToDate >= @currentDate
	END
END
GO