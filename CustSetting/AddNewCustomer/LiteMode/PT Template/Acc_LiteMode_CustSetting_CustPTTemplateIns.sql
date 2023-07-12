/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateIns] 
	@CustID INT,
	@SubAccID INT = 0,
	@TemplateID INT = 0 OUTPUT,
	@TemplateName NVARCHAR(50),
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
			,@roleid TINYINT
	
	SELECT @startRun = GETDATE()	
	
	DECLARE @xml XML = CONVERT(XML,@Settings)
	
	DECLARE @tmpSetting TABLE (groupID TINYINT, SubGroupID TINYINT, PT SMALLMONEY)
	
	INSERT INTO @tmpSetting(groupID,SubGroupID,PT)
	SELECT T.c.query('.').value('(r/@group)[1]', 'tinyint') AS GroupID,
		T.c.query('.').value('(r/@sub)[1]', 'tinyint') AS subGroupID,
		T.c.query('.').value('(r/@pt)[1]', 'smallmoney') AS PT
	FROM   @xml.nodes('/Root/r') T(c) 
	
	IF EXISTS(SELECT TOP (1) 1 FROM CustPTTemplate WITH(NOLOCK) WHERE custid = @custid AND TemplateName = @TemplateName)
	BEGIN
		SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'This Template Name already exists.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20045,@Language)
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
	
	SELECT @roleid = roleid 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	--reset IsDefault = 0 for existing template is default
	IF @IsDefault = 1
	BEGIN
		UPDATE CustPTTemplate WITH(ROWLOCK)
		SET IsDefault = 0
		WHERE custid = @custid
			AND IsDefault = 1
	END
		
	INSERT INTO [dbo].[CustPTTemplate]
           ([custid]
           ,[TemplateName]
           ,[IsDefault])
    VALUES (@custid,@TemplateName,@IsDefault)
	 
	SELECT @TemplateID = SCOPE_IDENTITY()

	INSERT INTO [dbo].[CustPTTemplateDetail]
           ([TemplateID]
           ,[GroupID]
           ,[SubGroupID]
           ,[PT])
	SELECT @TemplateID, GroupID, SubGroupID, PT
	FROM @tmpSetting
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	 DECLARE @LogSPData VARCHAR(MAX),
		@ActionID INT
		
	SELECT @ActionID = CASE WHEN @roleid = 4 THEN 475
							WHEN @roleid = 3 THEN 480
							WHEN @roleid = 2 THEN 483 END	 
    --Log info
    SELECT @LogSPData = '<Root custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +	
						'TemplateName="'+ coalesce(cast(@TemplateName as NVARCHAR(50)),space(1)) + '" ' +
						'IsDefault="'+ coalesce(cast(@IsDefault as VARCHAR(1)),space(1)) + '" ' +
						'IP="'+ coalesce(cast(@IP as VARCHAR(20)),space(1)) + '" >' +
						CAST((
							SELECT GroupID AS '@GroupID', SubGroupID as '@SubGroupID', PT as '@PT'
							FROM @tmpSetting
							FOR XML PATH('r'), 
							TYPE
						) AS VARCHAR(MAX))+
						'</Root>'
						
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @CustID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,				
				@duration = @duration	
				
END