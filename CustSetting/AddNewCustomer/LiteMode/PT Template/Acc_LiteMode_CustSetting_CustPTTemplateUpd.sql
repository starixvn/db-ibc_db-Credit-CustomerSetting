/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateUpd] 
	@CustID INT,
	@TemplateID INT,
	@Settings VARCHAR(MAX),
	@IsDefault BIT = 0,
	@CreationStatus TINYINT = 0, 
	
	@Language VARCHAR(3) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20230508@Johnson  
	Task : Add PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230508@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @Settings = '<Root>
						<r group="1" sub="1" pt="85" />
						<r group="2" sub="2" pt="85" />
						<r group="3" sub="5" pt="85" />
						<r group="3" sub="6" pt="85" />
						<r group="4" sub="0" pt="85" />
					</Root>'
		- group: Product Group/sub: Sub Group	
		- @CreationStatus: 0: Pro, 1: UAT, 3: UAT/PRO		
		- @ErrType: 0: normal message, 1: show sport/bettype
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
	
	SELECT @startRun = GETDATE()	
	
	DECLARE @xml XML = CONVERT(XML,@Settings)
	
	DECLARE @tmpSetting TABLE (groupID TINYINT, SubGroupID TINYINT, PT SMALLMONEY, Old_PT SMALLMONEY)
	
	INSERT INTO @tmpSetting(groupID,SubGroupID,PT)
	SELECT T.c.query('.').value('(r/@group)[1]', 'tinyint') AS GroupID,
		T.c.query('.').value('(r/@sub)[1]', 'tinyint') AS subGroupID,
		T.c.query('.').value('(r/@pt)[1]', 'smallmoney') AS PT
	FROM   @xml.nodes('/Root/r') T(c) 
	
	IF NOT EXISTS(SELECT 1 FROM CustPTTemplate WITH(NOLOCK) WHERE custid = @custid AND TemplateID = @TemplateID)
	BEGIN
		SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'This Template is not exists.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20047,@Language)
					end,
				@ErrCode = 100
		RETURN
	END
	
	EXEC Acc_LiteMode_CustSetting_CustPTTemplateCheck 
		@CustID = @CustID,	
		@Settings = @Settings,
		@CreationStatus = @CreationStatus, 
		
		@Language = @Language,
		@ErrCode = @ErrCode OUTPUT,
		@ErrType = @ErrType OUTPUT,
		@ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN;
	
	DECLARE @Old_IsDefault BIT,
		@TemplateName VARCHAR(50)
	
	SELECT @Old_IsDefault = IsDefault,
		@TemplateName = TemplateName
	FROM CustPTTemplate WITH(ROWLOCK)		
	WHERE custid = @custid
		AND TemplateID = @TemplateID
	
	UPDATE t
	SET t.Old_PT = cs.PT
	FROM @tmpSetting t
		INNER JOIN CustPTTemplateDetail cs WITH(NOLOCK) ON cs.TemplateID = @TemplateID
														AND cs.GroupID = t.GroupID
														AND cs.SubGroupID = t.SubGroupID
	
	IF @IsDefault = @Old_IsDefault 
	AND NOT EXISTS (SELECT 1 FROM @tmpSetting WHERE PT <> Old_PT)
		RETURN;
		
	--reset IsDefault = 0 for existing template is default
	IF @IsDefault = 1
	BEGIN
		IF @IsDefault <> @Old_IsDefault
		BEGIN
			UPDATE CustPTTemplate WITH(ROWLOCK)
			SET IsDefault = 0
			WHERE custid = @custid
				AND IsDefault = 1
				
			UPDATE CustPTTemplate WITH(ROWLOCK)
			SET IsDefault = 1
			WHERE custid = @custid
				AND TemplateID = @TemplateID				 
		END		
	END	
		
	UPDATE cs
	SET cs.PT = t.PT
	FROM @tmpSetting t
		INNER JOIN CustPTTemplateDetail cs WITH(NOLOCK) ON cs.TemplateID = @TemplateID
														AND cs.GroupID = t.GroupID
														AND cs.SubGroupID = t.SubGroupID
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	 DECLARE @LogSPData VARCHAR(MAX),
			@Old_LogSPData VARCHAR(MAX)
	 
    --Log info
    SELECT @LogSPData = '<Root custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
						'TemplateName="'+ coalesce(cast(@TemplateName as VARCHAR(50)),space(1)) + '" ' +
						'IsDefault="'+ coalesce(cast(@IsDefault as VARCHAR(1)),space(1)) + '" ' +
						'IP="'+ coalesce(cast(@IP as VARCHAR(20)),space(1)) + '" ' +
						CAST((
							SELECT GroupID, SubGroupID, PT
							FROM @tmpSetting
							FOR XML PATH('r'), 
							TYPE
						) AS VARCHAR(MAX))+
						'/>'
	
	SELECT @Old_LogSPData = '<Root custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
						'TemplateName="'+ coalesce(cast(@TemplateName as VARCHAR(50)),space(1)) + '" ' +
						'IsDefault="'+ coalesce(cast(@IsDefault as VARCHAR(1)),space(1)) + '" ' +
						'IP="'+ coalesce(cast(@IP as VARCHAR(20)),space(1)) + '" ' +
						CAST((
							SELECT GroupID, SubGroupID, Old_PT as PT
							FROM @tmpSetting
							FOR XML PATH('r'), 
							TYPE
						) AS VARCHAR(MAX))+
						'/>'
						
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @CustID,
				@CustID = @CustID,
				@ActionID = 476,
				@TrackingValue = @LogSPData,				
				@TrackingValue2 = @Old_LogSPData,
				@duration = @duration	
				
END	