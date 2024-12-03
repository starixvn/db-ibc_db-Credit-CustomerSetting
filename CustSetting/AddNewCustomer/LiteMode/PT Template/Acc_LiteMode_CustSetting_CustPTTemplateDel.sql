/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateDel] 
	@CustID INT,
	@SubAccID INT = 0,
	@TemplateID INT,
	
	@Language VARCHAR(3) = 'E',
	@IP VARCHAR(15)='',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20230510@Johnson  
	Task : delete PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230510@Johnson: initial sp [redmine: #179159]
		- 20241212@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]		
	Param's Explanation: 
		
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
			,@TemplateName NVARCHAR(50)	
			,@roleid TINYINT
	
	SELECT @startRun = GETDATE()	
	
	SELECT @TemplateName = TemplateName FROM CustPTTemplate WITH(NOLOCK) WHERE custid = @custid AND TemplateID = @TemplateID
	
	IF @@ROWCOUNT = 0
	BEGIN
		SELECT	@ErrMsg = CASE @Language 
						WHEN 'E' THEN 'This Template is not exists.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20047,@Language)
					end,
				@ErrCode = 100
		RETURN
	END
	
	SELECT @roleid = roleid 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	DELETE CustPTTemplateDetail 
	OUTPUT DELETED.TemplateID, DELETED.GroupID, DELETED.SubGroupID, dbo.f_GetDateTime2()
	INTO CustPTTemplateDetail_Del_Inhouse(TemplateID,GroupID,SubGroupID,RepUpdateTime)
	WHERE TemplateID = @TemplateID
	
	DELETE CustPTTemplate 
	OUTPUT DELETED.TemplateID, dbo.f_GetDateTime2()
	INTO CustPTTemplate_Del_Inhouse(TemplateID,RepUpdateTime)
	WHERE custid = @custid AND TemplateID = @TemplateID
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	DECLARE @LogSPData NVARCHAR(MAX),
			@ActionID INT
		
	SELECT @ActionID = CASE WHEN @roleid = 4 THEN 477
							WHEN @roleid = 3 THEN 482
							WHEN @roleid = 2 THEN 485 END	
	 
    --Log info
    SELECT @LogSPData = '<Root custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +	
						'TemplateName="'+ dbo.f_EncodeXMLValue(coalesce(cast(@TemplateName as NVARCHAR(50)),space(1))) + '" ' +						
						'IP="'+ coalesce(cast(@IP as VARCHAR(20)),space(1)) + '" ' +
						'/>'
						
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @CustID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,				
				@duration = @duration
END	