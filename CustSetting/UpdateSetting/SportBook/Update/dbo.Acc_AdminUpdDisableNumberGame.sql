/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_AdminUpdDisableNumberGame]
	@CustID INT,
	@Disable BIT,
	
	@UpdateAllMasters BIT = 0,
	@UpdateAllAgents  BIT = 0,
	@UpdateAllMembers BIT = 0,
	
	@DisableAllMasters BIT = NULL,
	@DisableAllAgents  BIT = NULL,
	@DisableAllMembers BIT = NULL,
	
	@UserID INT,
	@Language VARCHAR(2) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg nvarchar(200) = '' OUTPUT,
	@IP VARCHAR(15)=''
AS
/*
Created: 20100831@Jamie
Task : Update Bingo Number Game status for customer
DB: DBCUST/CustDB
Original:Acc_CustomerUpdDisableNumber

Revisions:
	- 20101021@Henry: Record execution time
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message FROM f_Get_MsgNameByMsgID function by language
	- 20121206@Scott : Check Allowed downlines during peak hour at weekend
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in CASE of DBLOG server failure
	- 20130926@Kathy: Apply exec rep
	- 20131108@Elodie: Splitting bodb02 into CustDB (Turn to use Acc_ExecRep_Cust_04)	
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	- 20180202@Johnson: remove @DisableDownline for new direction for status [redmine: #87328]
Param's Explanation:
• @custid: customer id.   
• @Disable: status
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = GETDATE()

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode <>0 RETURN
	--END
	DECLARE @RoleID TINYINT , 
		@UplineDisableNumber BIT, 
		@Old_DisableNumber BIT,
		@Allow2Udpate BIT = 1

	SELECT	@RoleID = RoleID,
			@Old_DisableNumber = ISNULL(DisableNumber, 0)
	FROM dbo.Custinfo WITH (NOLOCK)
	WHERE CustID = @CustID

	IF @RoleID NOT IN (1,2,3,4)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' then 'Invalid user!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						END, @ErrCode = 100	
		RETURN
	END

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
	--END

	IF @Old_DisableNumber = @Disable 
		AND @UpdateAllMasters = 0 
		AND @UpdateAllAgents = 0 
		AND @UpdateAllMembers = 0
	RETURN

	IF @Disable = 0 -- check status upline
	begin			
		IF @RoleID = 3
			SELECT @UplineDisableNumber = ISNULL(DisableNumber,0) FROM CustInfo WITH (NOLOCK)
			WHERE custid = (SELECT SRecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 2
			SELECT @UplineDisableNumber = ISNULL(DisableNumber,0) FROM CustInfo WITH (NOLOCK)
			WHERE custid = (SELECT MRecommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 1
			SELECT @UplineDisableNumber = ISNULL(DisableNumber,0) FROM CustInfo WITH (NOLOCK)
			WHERE custid = (SELECT Recommend FROM Custinfo WITH (NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 4 SELECT @UplineDisableNumber = 0   --not checking the upline WHEN the customer is the super
			
		IF @UplineDisableNumber = 1
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Your account was disabled Number Game betting. Cannot edit customer.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60017,@Language)
							END, @ErrCode = 105
			RETURN
		END 
	END
	
	--check constraint parameters
	SELECT @Allow2Udpate=1
	IF(@roleid = 4)
	BEGIN
		IF (@UpdateAllMembers=1 AND @UpdateAllAgents=1 AND @DisableAllAgents=1 AND @DisableAllMembers=0)
			OR (@UpdateAllMasters=1 AND @UpdateAllAgents=1 AND @DisableAllMasters=1 AND @DisableAllAgents=0)			
			OR (@Disable = 1 				
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
						AND DisableNumber = 1						
					)
			SELECT @Allow2Udpate=0			
		END
		
		IF @UpdateAllAgents=1 AND @UpdateAllMasters=0 AND @DisableAllAgents=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE srecommend = @custid
						AND roleid = 3
						AND DisableNumber = 1						
					)
			SELECT @Allow2Udpate=0			
		END
	END	
	ELSE IF (@Roleid =3)
	BEGIN	
		IF (@UpdateAllMembers=1 AND @UpdateAllAgents=1 AND @DisableAllAgents=1 AND @DisableAllMembers=0)			
			OR (@Disable = 1 				
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
						AND DisableNumber = 1
					)
			SELECT @Allow2Udpate=0			
		END
	END
	ELSE IF (@roleid =2)
	BEGIN
		IF @Disable = 1 			
			AND (@UpdateAllMembers = 0					
				OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
				)
		SELECT @Allow2Udpate=0		
	END
	
	--upline status and downlines not suitable
	IF @Allow2Udpate=0	
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 

	---------------------

	UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET DisableNumber = @Disable
	WHERE CustID = @CustID
	IF (@@error <> 0)
	begin

		SELECT @ErrMsg =
						CASE @Language 
							WHEN 'E' then 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 101
		RETURN
	END
	--Check condition for update all downline
	IF (@Disable = 1 OR (@Disable = 0 AND (@UpdateAllMasters = 1 OR @UpdateAllAgents =1 OR @UpdateAllMembers=1))) --Disable all downline OR enable all downline
	BEGIN TRY
		--20130926@Kathy: Apply ExecRep 
		EXEC [Acc_CustomerInfo_Execrep_04]
			@CustID		= @CustID,
			@RoleID		= @RoleID,
			@Action		= 'DisableNumberGame',
			@DisableNumberGame = @Disable,
			
			@UpdateAllMasters = @UpdateAllMasters,
			@UpdateAllAgents = @UpdateAllAgents,
			@UpdateAllMembers = @UpdateAllMembers,
			
			@DisableAllMasters = @DisableAllMasters,
			@DisableAllAgents = @DisableAllAgents,
			@DisableAllMembers = @DisableAllMembers		
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' then 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	
		IF @RoleID = 4 
			SELECT @ErrCode = 102
		ELSE IF @RoleID = 3
			SELECT @ErrCode = 103
		ELSE IF @RoleID = 2
			SELECT @ErrCode = 104
		RETURN
	END CATCH

	DECLARE @LogSPData VARCHAR(8000),
			@LogSPData_Old VARCHAR(8000), 
			@ActionID INT

	SELECT @LogSPData = '<Acc_AdminUpdDisableNumberGame CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" '+
						'DisableNumber="'+ COALESCE(CAST(@Disable as VARCHAR(50)),SPACE(1)) + '" '+
						'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
						'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
						'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
						'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
						'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
						'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
						'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" '+
						'Language="'+ COALESCE(CAST(@Language as VARCHAR(2)),SPACE(1))+'" '+
						'ErrCode="'+ COALESCE(CAST(@ErrCode as VARCHAR(50)),SPACE(1)) + '" '+
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(400)),SPACE(1))+'" '+
						'IP="'+ COALESCE(CAST(@IP as VARCHAR(15)),SPACE(1))+'" />'
	
	SELECT @LogSPData_Old = '<Acc_AdminUpdDisableNumberGame CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" '+
						'DisableNumber="'+ COALESCE(CAST(@Old_DisableNumber as VARCHAR(50)),SPACE(1)) + '" '+
						'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
						'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
						'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
						'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
						'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
						'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
						'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" '+
						'Language="'+ COALESCE(CAST(@Language as VARCHAR(2)),SPACE(1))+'" '+
						'ErrCode="'+ COALESCE(CAST(@ErrCode as VARCHAR(50)),SPACE(1)) + '" '+
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg as VARCHAR(400)),SPACE(1))+'" '+
						'IP="'+ COALESCE(CAST(@IP as VARCHAR(15)),SPACE(1))+'" />'						

	SET @endRun = GETDATE()
	SET @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		/*1120	Acc_CustomerUpdDisableNumber	Update Enabled/Disabled Number Game status*/
		--write log for themself
		SELECT @ActionID =  CASE @roleid WHEN 4 THEN 60008 
										WHEN 3 THEN 65016
										WHEN 2 THEN 70024 
										WHEN 1 THEN 75032 END
		
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = @ActionID,
			@TrackingValue = @LogSPData	 ,
			@TrackingValue2 = @LogSPData_old  ,
			@duration = @duration
		
		IF @roleid >3 
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMasters = 1 )
					)			
		BEGIN
			SELECT @ActionID = 65017
			
			--actionID on master
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData	 ,
				@TrackingValue2 = @LogSPData_old  ,
				@duration = @duration 
		END
		
		IF @Roleid >2
			AND ( @Disable = 1 
				OR (@Disable = 0 AND @UpdateAllAgents = 1 )
				)	
		BEGIN	
			SELECT @ActionID = CASE @roleid WHEN 3 THEN 70025
											WHEN 4 THEN 70026 END
											
			--actionID on agent
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData	 ,
				@TrackingValue2 = @LogSPData_old  ,
				@duration = @duration
		END
		
		IF @Roleid >1
			AND ( @Disable = 1 
				OR (@Disable = 0 AND @UpdateAllMembers = 1 )
				)
		BEGIN
			SELECT @ActionID = CASE @roleid WHEN 2 THEN 75033 
											WHEN 3 THEN 75034
											WHEN 4 THEN 75035 END
			--actionID on member
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData	 ,
				@TrackingValue2 = @LogSPData_old  ,
				@duration = @duration
		END		
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_AdminUpdDisableNumberGame CustID="'+ COALESCE(CAST(@CustID as VARCHAR(50)),SPACE(1)) + '" '+
							'DisableNumber="'+ COALESCE(CAST(@Disable as VARCHAR(50)),SPACE(1)) + '" '+
							'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
							'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
							'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
							'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
							'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
							'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
							
							'UserID="'+ COALESCE(CAST(@UserID as VARCHAR(50)),SPACE(1)) + '" '+
							'Language="'+ COALESCE(CAST(@Language as VARCHAR(2)),SPACE(1))+'" '+
							'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() as VARCHAR(50)),SPACE(1)) + '" '+
							'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() as VARCHAR(4000)),SPACE(1))+'" '+
							'IP="'+ COALESCE(CAST(@IP as VARCHAR(15)),SPACE(1))+'" />'
							
		/*1120	Acc_CustomerUpdDisableNumber	Update Enabled/Disabled Number Game status*/
		--write log for themself
		SELECT @ActionID =  CASE @roleid WHEN 4 THEN 60008 
										WHEN 3 THEN 65016
										WHEN 2 THEN 70024 
										WHEN 1 THEN 75032 END
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = @ActionID,
			@TrackingValue = @LogSPData	 ,
			@TrackingValue2 = @LogSPData_old  ,
			@duration = @duration
		
		IF @roleid >3 
				AND ( @Disable = 1 
					OR (@Disable = 0 AND @UpdateAllMasters = 1 )
					)			
		BEGIN
			SELECT @ActionID = 65017
			
			--actionID on master
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData	 ,
				@TrackingValue2 = @LogSPData_old  ,
				@duration = @duration 
		END
		
		IF @Roleid >2
			AND ( @Disable = 1 
				OR (@Disable = 0 AND @UpdateAllAgents = 1 )
				)	
		BEGIN	
			SELECT @ActionID = CASE @roleid WHEN 3 THEN 70025
											WHEN 4 THEN 70026 END
											
			--actionID on agent
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData	 ,
				@TrackingValue2 = @LogSPData_old  ,
				@duration = @duration
		END
		
		IF @Roleid >1
			AND ( @Disable = 1 
				OR (@Disable = 0 AND @UpdateAllMembers = 1 )
				)
		BEGIN
			SELECT @ActionID = CASE @roleid WHEN 2 THEN 75033 
											WHEN 3 THEN 75034
											WHEN 4 THEN 75035 END
			--actionID on member
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData	 ,
				@TrackingValue2 = @LogSPData_old  ,
				@duration = @duration
		END		
	END CATCH
END

GO