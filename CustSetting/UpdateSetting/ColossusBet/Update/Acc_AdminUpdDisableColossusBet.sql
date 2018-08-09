/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_AdminUpdDisableColossusBet]  
(
	@custid  INT,  
	@Disable BIT = NULL,   
	
	@UpdateAllMasters BIT = 0,
	@UpdateAllAgents  BIT = 0,
	@UpdateAllMembers BIT = 0,
	
	@DisableAllMasters BIT = NULL,
	@DisableAllAgents  BIT = NULL,
	@DisableAllMembers BIT = NULL,
	
	@UserID  INT = 0,  	
	@IP   VARCHAR(20)= '',  
	@Language VARCHAR(2) = 'E',  
	@ErrCode INT = 0 OUTPUT,  
	@ErrMsg  VARCHAR(4000) = '' OUTPUT  
) 
 AS  
 
 /*  
    Created: Johnson  
    Date: 20180119
    Task: Updating Colossus Bet Status by Admin
    DB: DBCUST/CustDB  
    Original: Acc_CustomerUpdDisableColossusBet
	
	Revisions:
		- 20180119@Johnson: launch new sp from Acc_CustomerUpdDisableColossusBet for new direction[Redmine: #83828]
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
			@HasDownline BIT = 0,
			@Allow2Udpate BIT = 1 			

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
	
	IF @Disable_old = @Disable AND @UpdateAllMasters = 0 AND @UpdateAllAgents = 0 AND @UpdateAllMembers = 0
	RETURN
	
	--Check Allowed downlines during peak hour at weekend	
	EXEC Acc_AdminCheckAllowedDownlinesByLevel @custid=@custid,
										@roleid=@roleid,
										@isExecRep=1,
										@UpdateAllMasters = @UpdateAllMasters,
										@UpdateAllAgents = @UpdateAllAgents,
										@UpdateAllMembers = @UpdateAllMembers,
										@Language=@Language,
										@ErrMsg=@ErrMsg output,
										@ErrCode=@ErrCode output
	IF @ErrCode <>0 RETURN

	--end check downlines 
	
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
	
	--check constraint parameters
	SELECT @Allow2Udpate=1
	IF(@roleid = 4)
	BEGIN
		IF (@UpdateAllMembers=1 AND @UpdateAllAgents=1 AND @DisableAllAgents=1 AND @DisableAllMembers=0)
			OR (@UpdateAllMasters=1 AND @UpdateAllAgents=1 AND @DisableAllMasters=1 AND @DisableAllAgents=0)			
			OR (@Disable = 1 
				AND @HasDownline=1
				AND (@UpdateAllMasters = 0 OR @UpdateAllAgents = 0 OR @UpdateAllMembers = 0
					OR (@UpdateAllMasters =1 AND @DisableAllMasters = 0)
					OR (@UpdateAllAgents = 1 AND @DisableAllAgents = 0)
					OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
					)
				)
		SELECT @Allow2Udpate=0		
		
		IF @UpdateAllMembers=1 AND @UpdateAllAgents=0 AND @DisableAllMembers=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE srecommend = @custid
						AND roleid = 2
						AND DisableColossusBet = 1						
					)
			SELECT @Allow2Udpate=0			
		END
		
		IF @UpdateAllAgents=1 AND @UpdateAllMasters=0 AND @DisableAllAgents=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE srecommend = @custid
						AND roleid = 3
						AND DisableColossusBet = 1						
					)
			SELECT @Allow2Udpate=0			
		END
	END	
	ELSE IF (@Roleid =3)
	BEGIN	
		IF (@UpdateAllMembers=1 AND @UpdateAllAgents=1 AND @DisableAllAgents=1 AND @DisableAllMembers=0)			
			OR (@Disable = 1 
				AND @HasDownline=1
				AND (@UpdateAllAgents = 0 OR @UpdateAllMembers = 0					
					OR (@UpdateAllAgents = 1 AND @DisableAllAgents = 0)
					OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
					)
				)
			SELECT @Allow2Udpate=0	
			
		IF @UpdateAllMembers=1 AND @UpdateAllAgents=0 AND @DisableAllMembers=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE mrecommend = @custid
						AND roleid = 2
						AND DisableColossusBet = 1
					)
			SELECT @Allow2Udpate=0			
		END
	END
	ELSE IF (@roleid =2)
	BEGIN
		IF @Disable = 1 
			AND @HasDownline=1
			AND (@UpdateAllMembers = 0					
				OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
				)
		SELECT @Allow2Udpate=0		
	END
	
	IF @Allow2Udpate=0		
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 
	

	-- Update status
	UPDATE dbo.CustInfo WITH(ROWLOCK, UPDLOCK)  
		SET DisableColossusBet = @Disable,  
			HideColossusBet = CASE WHEN HideColossusBet = 1 THEN 0 ELSE HideColossusBet END    
	WHERE custid = @CustID  

	--Check condition for update all downlines  
	IF ( @RoleID > 1 
		AND (@Disable = 1  
			OR (@Disable = 0 
				AND @HasDownline = 1
				AND (@UpdateAllMasters = 1 
					OR @UpdateAllAgents = 1 
					OR @UpdateAllMembers = 1 
					)  
				)  
			)
		)	
	BEGIN  		
		--Disable all downlines or enable all downlines  
		BEGIN TRY  
			EXEC [Acc_CustomerInfo_Execrep_04] @CustID = @CustID  
				,@RoleID = @RoleID  
				,@DisableColossusBet = @Disable 
				,@UpdateAllMasters = @UpdateAllMasters
				,@UpdateAllAgents = @UpdateAllAgents
				,@UpdateAllMembers = @UpdateAllMembers
				,@DisableAllMasters = @DisableAllMasters
				,@DisableAllAgents = @DisableAllAgents
				,@DisableAllMembers = @DisableAllMembers			 
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
			@LogSPData_Old VARCHAR(2000),
			@ActionID INT		
	 
	SELECT @LogSPData = '<Acc_AdminUpdDisableColossusBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
		'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+    		
		'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
		'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
		'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
		'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
		'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
		'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    		
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+    
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'    
	 
	SELECT @LogSPData_Old = '<Acc_AdminUpdDisableColossusBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
		'Disable="'+ coalesce(cast(@Disable_old as varchar(50)),space(1)) + '" '+    		
		'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
		'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
		'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
		'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
		'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
		'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    		
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+    
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'    
	  
	SET @endRun = GETDATE()    
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)    

	BEGIN TRY  
		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60007 
										WHEN 3 THEN 65014
										WHEN 2 THEN 70021 
										WHEN 1 THEN 75028 END
										
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP    
			@UserID = @UserID,    
			@CustID = @CustID,    
			@ActionID = @ActionID,    
			@TrackingValue = @LogSPData  ,   
			@TrackingValue2 = @LogSPData_old  ,    
			@duration = @duration 
		
		--write log for downlines in-case disable downline
		IF @HasDownline = 1
		BEGIN
			IF @roleid >3 
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMasters = 1 )
					)			
			BEGIN
				SELECT @ActionID = 65015
				
				--actionID on master
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @LogSPData_old  ,  
					@duration = @duration  
			END
			
			IF @Roleid >2
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllAgents = 1 )
					)	
			BEGIN	
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70022
												WHEN 4 THEN 70023 END
												
				--actionID on agent
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @LogSPData_old  ,  
					@duration = @duration 
			END
			
			IF @Roleid >1
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMembers = 1 )
					)
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75029 
												WHEN 3 THEN 75030
												WHEN 4 THEN 75031 END
				--actionID on member
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @LogSPData_old  ,  
					@duration = @duration
			END	
		END		
	END TRY   
	BEGIN CATCH  

		SELECT @LogSPData = '<Acc_AdminUpdDisableColossusBet CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+    
			'Disable="'+ coalesce(cast(@Disable as varchar(50)),space(1)) + '" '+    		
			'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
			'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
			'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
			'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
			'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
			'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
			'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+    		
			'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+    
			'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+    
			'ErrMsg="'+ ERROR_MESSAGE() +'" '+    
			'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'   
	   
		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60007 
										WHEN 3 THEN 65014
										WHEN 2 THEN 70021 
										WHEN 1 THEN 75028 END
										
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP    
			@UserID = @UserID,    
			@CustID = @CustID,    
			@ActionID = @ActionID,    
			@TrackingValue = @LogSPData  ,   
			@TrackingValue2 = @LogSPData_old  ,    
			@duration = @duration 
		
		--write log for downlines in-case disable downline
		IF @HasDownline = 1
		BEGIN
			IF @roleid >3 
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMasters = 1 )
					)			
			BEGIN
				SELECT @ActionID = 65015
				
				--actionID on master
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @LogSPData_old  ,  
					@duration = @duration  
			END
			
			IF @Roleid >2
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllAgents = 1 )
					)	
			BEGIN	
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70022
												WHEN 4 THEN 70023 END
												
				--actionID on agent
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @LogSPData_old  ,  
					@duration = @duration 
			END
			
			IF @Roleid >1
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMembers = 1 )
					)
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75029 
												WHEN 3 THEN 75030
												WHEN 4 THEN 75031 END
				--actionID on member
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogSPData  , 
					@TrackingValue2 = @LogSPData_old  ,  
					@duration = @duration
			END	
		END	

	END CATCH  

END
GO