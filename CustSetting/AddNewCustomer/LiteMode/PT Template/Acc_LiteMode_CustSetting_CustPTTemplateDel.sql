/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateDel] 
	@CustID INT,
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

	Param's Explanation: 
		
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME
			,@endRun DATETIME
			,@duration INT
			,@TemplateName VARCHAR(50)	
	
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
	
	DELETE CustPTTemplateDetail WHERE TemplateID = @TemplateID
	
	DELETE CustPTTemplate WHERE custid = @custid AND TemplateID = @TemplateID
	
	SET @endRun=GETDATE()
	SET @duration=datediff(millisecond,@startRun,@endRun)
	
	DECLARE @LogSPData VARCHAR(MAX)
	 
    --Log info
    SELECT @LogSPData = '<Root custid="'+ coalesce(cast(@custid as VARCHAR(50)),space(1)) + '" ' +
						'TemplateName="'+ coalesce(cast(@TemplateName as VARCHAR(50)),space(1)) + '" ' +						
						'IP="'+ coalesce(cast(@IP as VARCHAR(20)),space(1)) + '" ' +
						'/>'
						
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @CustID,
				@CustID = @CustID,
				@ActionID = 477,
				@TrackingValue = @LogSPData,				
				@duration = @duration
END	