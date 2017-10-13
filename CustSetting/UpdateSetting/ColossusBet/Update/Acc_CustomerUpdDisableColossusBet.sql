/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisableColossusBet]  
(
	@custid  INT,  
	@Disable BIT = NULL,   
	@EnableDownlines BIT = NULL,  
	@SystemID	TINYINT = 1,
	@UserID  INT = 0,  
	@SubAccID INT = 0, --Sub-AccountID  
	@IP   VARCHAR(20)= '',  
	@Language VARCHAR(2) = 'E',  
	@ErrCode INT = 0 OUTPUT,  
	@ErrMsg  VARCHAR(4000) = '' OUTPUT  
) 
 AS  
 
 /*  
    Created: Helen  
    Date: 20150821
    Task: Updating Colossus Bet Status - Redmine: #41264
    DB: DBCUST / CustDB  
    
	Revisions:
	- 20170307@Winnie: Change enable behavior & Allowed disable on EXT-NAP [Redmine: #72336]
	- 20171013@Johnson: Set @EnableDownlines = NULL as default when dont have downline [Redmine: #72973]
	Parameters Explanation:
	
*/ 
 
BEGIN  
	SET NOCOUNT ON   
	DECLARE @startRun DATETIME  
	DECLARE @endRun DATETIME  
	DECLARE @duration INT  

	SET @startRun = GETDATE()  

	--Check disable user  
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid  
		,@ErrCode = @ErrCode OUTPUT  
		,@ErrMsg = @ErrMsg OUTPUT  

	IF @ErrCode > 0  
		RETURN  

	DECLARE @roleid INT,  
			@Disable_Old BIT,  
			@UplineDisable BIT,     
			@HasDownline BIT = 0 
			,@DisableDownlines_Old BIT = 0


	SELECT @roleid = roleid,  
			@Disable_Old = DisableColossusBet
	FROM custInfo WITH(NOLOCK)  
	WHERE custid = @custid  

	IF (@RoleID NOT IN (1, 2, 3, 4))  
	BEGIN  
		SELECT @ErrMsg = CASE @Language  
								WHEN 'E' THEN 'Invalid user!'  
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002, @Language)  
						END  
			, @ErrCode = 100  

		RETURN  
	END  

	SELECT top 1 @HasDownline = 1   
	FROM dbo.CustInfo WITH (NOLOCK)  
	WHERE (@RoleID = 4 AND srecommend = @CustID and roleid = 3)  
		OR (@RoleID = 3 AND mrecommend = @CustID and roleid = 2)  
		OR (@RoleID = 2 AND recommend = @CustID and roleid = 1)  
	
	
	IF @HasDownline = 1
	BEGIN
		IF @roleid = 4 
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND DisableColossusBet = 1)
				SET @DisableDownlines_Old = 1
		END
		ELSE IF @roleid = 3
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND DisableColossusBet = 1)
				SET @DisableDownlines_Old = 1
		END
		ELSE IF @roleid = 2
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE recommend = @custid AND DisableColossusBet = 1)
				SET @DisableDownlines_Old = 1
		END
	END

	IF @Disable_old = @Disable AND (@DisableDownlines_Old <> @EnableDownlines OR @EnableDownlines IS NULL)
	RETURN
	IF @Disable = 0 -- check status upline  
	BEGIN  
		IF @RoleID = 4  --not checking the upline when the customer is the super  
			SELECT @UplineDisable = 0  
		IF @RoleID = 3  
			SELECT @UplineDisable = ISNULL(c1.DisableColossusBet, 0)  
			FROM custInfo c1 WITH (NOLOCK)  
			WHERE c1.custid = (SELECT c2.srecommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)  

		IF @RoleID = 2  
			SELECT @UplineDisable = ISNULL(c1.DisableColossusBet, 0)  
			FROM custInfo c1 WITH (NOLOCK)  
			WHERE c1.custid = (SELECT c2.mrecommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)  

		IF @RoleID = 1  
			SELECT @UplineDisable = ISNULL(c1.DisableColossusBet, 0)  
			FROM custInfo c1 WITH (NOLOCK)  
			WHERE c1.custid = (SELECT c2.recommend FROM custInfo c2 WITH (NOLOCK) WHERE c2.custid = @CustID)  

	END  

	IF @UplineDisable = 1  
	BEGIN  
		SELECT @ErrMsg =  CASE @Language   
								WHEN 'E' THEN 'Account was disabled Colossus Bets. Unable to edit downlines.'  
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60032,@Language)  
						END, @ErrCode = 101  
		RETURN  
	END   
	IF ((@Disable = 1 AND @Disable_Old = 0) OR
	 (@DisableDownlines_Old = 0 AND @EnableDownlines = 0 AND @HasDownline = 1)) AND @SystemID=2 AND @roleid IN (4,3,2)
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to disable for downlines.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60035,@Language)
						END, @ErrCode = 102
		RETURN
	END 

	IF @Disable = 1 AND @EnableDownlines = 1 AND @HasDownline=1
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 
	

	-- Update chính nó  
	UPDATE dbo.CustInfo WITH(ROWLOCK, UPDLOCK)  
		SET DisableColossusBet = @Disable,  
			HideColossusBet = CASE WHEN HideColossusBet = 1 THEN 0 ELSE HideColossusBet END    
	WHERE custid = @CustID  

	--Check condition for update all downlines  
	IF ( @RoleID > 1 AND 
		(@Disable = 1  
			OR (@Disable = 0 AND (@EnableDownlines = 1 AND @HasDownline = 1))  
		)  
		)  
	BEGIN  
		EXEC Acc_CustomerSelCheckAllowedDownlines @custid = @custid  
		,@roleid = @roleid  
		,@isExecRep = 1  
		,@Language = @Language  
		,@ErrMsg = @ErrMsg OUTPUT  
		,@ErrCode = @ErrCode OUTPUT  

		IF @ErrCode <> 0 RETURN  

		--Disable all downlines or enable all downlines  
		BEGIN TRY  
			EXEC [Acc_CustomerInfo_Execrep_04] @CustID = @CustID  
			 ,@RoleID = @RoleID  
			 ,@DisableColossusBet = @Disable  
			 ,@Action = 'ColossusBet'  
		END TRY  
		BEGIN CATCH  
			SELECT @ErrMsg = CASE @Language  
			 WHEN 'E' THEN 'Update process is unsuccessful.'  
			 ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)  
			 END  
			SET @ErrCode = 102  
			RETURN  
		END CATCH  
	END  

	DECLARE @LogSPData VARCHAR(MAX),    
			@LogSPData_Old VARCHAR(2000)    
	 
	SELECT @LogSPData = '<Acc_CustomerUpdDisableColossusBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
		'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+    
		'ApplyDownlines="'+ coalesce(cast(@EnableDownlines as varchar(50)),space(1)) + '" '+    
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    
		'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +  
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+    
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'    
	 
	SELECT @LogSPData_Old = '<Acc_CustomerUpdDisableColossusBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
		'Disable="'+ coalesce(cast(@Disable_old as varchar(50)),space(1)) + '" '+    
		'ApplyDownlines="'+ CASE WHEN @DisableDownlines_Old = 1 THEN  coalesce(cast(0 as varchar(50)),space(1)) ELSE  coalesce(cast(1 as varchar(50)),space(1)) END +'" '+    
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    
		'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +  
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+    
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'    
	  
	SET @endRun = GETDATE()    
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)    

	BEGIN TRY  
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP    
		@UserID = @UserID,    
		@CustID = @CustID,    
		@ActionID = 1157,    
		@TrackingValue = @LogSPData  ,   
		@TrackingValue2 = @LogSPData_old  ,    
		@duration = @duration    
	END TRY   
	BEGIN CATCH  

	SELECT @LogSPData = '<Acc_CustomerUpdDisableColossusBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
		'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+    
		'ApplyDownlines="'+ coalesce(cast(@EnableDownlines as varchar(50)),space(1)) + '" '+    
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    
		'SubAccName="' + coalesce(cast(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), space(1)) + '" ' +  
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
		'ErrMsg="'+ ERROR_MESSAGE() +'" '+    
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'   
	   
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP    
		@UserID = @UserID,    
		@CustID = @CustID,    
		@ActionID = 1157,    
		@TrackingValue = @LogSPData,    
		@TrackingValue2 = @LogSPData_old,    
		@duration = @duration  

	END CATCH  

END
GO