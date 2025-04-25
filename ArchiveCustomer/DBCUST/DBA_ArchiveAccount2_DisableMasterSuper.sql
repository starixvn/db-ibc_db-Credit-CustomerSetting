/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_DisableMasterSuper]
	@AccName VARCHAR(50),
	@UserID INT = 360418,
	@ErrMsg NVARCHAR(200) = '' OUTPUT,
	@ErrCode INT = 0 OUTPUT,
	@srecommend INT = 0 OUTPUT,
	@ReduceCredit MONEY = 0 OUTPUT,
	@ArchivedDate DATE = NULL
AS
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
			- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
			- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
			- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
			- 20210614@Eden: All sites - Dormant SMA Account List [RedmineID: #155969]
			- 20210923@Eden: Include newly created tables into Archive Credit Dormant Account process [redmine: #162050]
			- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
			- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
			- 20230529@Eden: Archiving credit accounts for additional tables [Redmine: #188850]
			- 20230620@Tacy: Remove columns and code used by Colossus Bets, GD product [RedmineID: #179132]
			- 20231019@Helios: Customer Setting - Remove old Structure un Use [RedmineID: #193083]
			- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061] 
			- 20250102@Eden: Archiving direct member [redmine: #215533] 
*/
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int, @Now datetime, @Level VARCHAR(10)
	set @startRun = getdate()
	DECLARE @ProcessedDate DATETIME  = GETDATE()

	Declare @roleid int, @CustID int, @Enabled bit

	SELECT @roleid = roleid, @CustID = custid, @Enabled = Enabled, @srecommend = srecommend, @ReduceCredit = credit
	FROM custinfo (nolock)
	WHERE username = @AccName

	IF @roleid = 3
		SET @Level = 'master'
	ELSE IF @roleid = 4
		SET @Level = 'super'

	IF @Enabled = 0
	BEGIN
		-- Disabled before but some tables not backup yet
		EXEC dbo.DBA_ArchiveAccount2_BackupAgent @AccName = @AccName
		Select @ErrMsg = @AccName +':'+ 'This '+ @Level +' has been archived!!', @ErrCode = 101
		print @ErrMsg

		EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
			@CustId = @CustID,
			@RoleID = @roleid,
			@StageID = 2,
			@ProcessedDate = @ProcessedDate,
			@ArchivedDate = @ArchivedDate
		return
	END

	--==Check new created members
	IF @roleid = 3
	IF EXISTS(SELECT 1 FROM customer c WITH (NOLOCK) WHERE mrecommend = @CustID AND creatdate >= DATEADD(mm, -4, GETDATE()))
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'This '+ @Level +' just created new members while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@CustID,@ErrMsg,@roleid) 
		print @ErrMsg
		return
	END
	ELSE IF @roleid = 4
	IF EXISTS(SELECT 1 FROM customer c WITH (NOLOCK) WHERE srecommend = @CustID AND creatdate >= DATEADD(mm, -4, GETDATE()))
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'This '+ @Level +' just created new members while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@CustID,@ErrMsg,@roleid) 
		print @ErrMsg
		return
	END

	--==Check the status has changed
	IF EXISTS(SELECT 1 FROM CustProductStatus cps WITH (NOLOCK) WHERE cps.CustID = @CustID AND cps.CloseInfo = 0)
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'This '+ @Level +' has been reopened while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@CustID,@ErrMsg,@roleid) 
		print @ErrMsg
		return
	END
	--== Check new active trans ==========================
	DECLARE @IsActive BIT = 0
	EXEC DBTXN.bodb02.dbo.[DBA_ArchiveAccount_CheckActiveSMA] @AccName = @AccName ,@IsActive = @IsActive OUTPUT

	IF @IsActive = 1
	BEGIN
		Select @ErrMsg = @AccName +':'+ 'This '+ @Level +' just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@CustID,@ErrMsg,@roleid) 
		print @ErrMsg
		RETURN
	END

	--Pre-check: Make sure cust info data not exist in DBRACCUST before backup
	IF	EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) WHERE custid = @CustID)
		--OR EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) WHERE mrecommend = @CustID AND recommend = -3)
		--OR EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.customer_old WITH(NOLOCK) WHERE srecommend = @CustID AND recommend = -4)
		OR EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) WHERE custid = @CustID)
		--OR EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) WHERE mrecommend = @CustID AND recommend = -3)
		--OR EXISTS(SELECT 1 FROM DBARCCUST.bodb_Customer.dbo.custinfo_old WITH(NOLOCK) WHERE srecommend = @CustID AND recommend = -4)
	BEGIN
		-- Disabled before but some tables not backup yet
		EXEC dbo.DBA_ArchiveAccount2_BackupAgent @AccName = @AccName
		Select @ErrMsg = @AccName +':'+ 'Backup data of this '+ @Level +' already exist. Please check!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (CustID, ErrMsg,Roleid) VALUES(@CustID,@ErrMsg,@roleid) 
		print @ErrMsg
		return
	END

	PRINT  @AccName +':'+ 'START:' + convert(varchar(50), getdate(), 113)

	--BACKUP DATA Super/Master
	EXEC [DBA_ArchiveAccount2_BackupAgent] @AccName = @AccName
	--Backup Data Member
	EXEC [DBA_ArchiveAccount2_BackupMember]  @AccName = @AccName

	-----------------------------------------------------------------------------------------------------------
	--> Insert data for Cust_ArchiveAccount - Master/Super
	BEGIN
		EXEC dbo.[Acc_DormantAccountList_InsertUpdate] 
			@CustId = @CustID,
			@RoleID = @roleid,
			@StageID = 2,
			@ProcessedDate = @ProcessedDate,
			@ArchivedDate = @ArchivedDate
	END

	--Archive
	EXEC dbo.[DBA_ArchiveAccount_SMALine] @CustID = @CustID, @StageID = 2
	
	----------------------------------------------------------------
	print  @AccName +':'+ 'END:' + convert(varchar(50), getdate(), 113)

	------------------
	declare @LogSPData varchar(2000)

	Select @LogSPData = '<DBA_ArchiveAccount2_DisableMasterSuper AccName="'+ coalesce(cast(@AccName as varchar(50)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))  + '"/>'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	IF @Enabled = 1
	BEGIN
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1177,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END
	--Writelog clear given credit for Master
	DECLARE @LogData VARCHAR(500) = ''
	SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@AccName, SPACE(1))  
	IF @ReduceCredit <> 0
	BEGIN
		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @CustID,
				@Doing = @LogData,
				@OldValue = @ReduceCredit,
				@NewValue = 0,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END TRY
		BEGIN CATCH
			SELECT @LogData = @LogData + ' ErrMsg:' + ERROR_MESSAGE()

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @CustID,
				@Doing = @LogData,
				@OldValue = @ReduceCredit,
				@NewValue = 0,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END CATCH
	END	
END