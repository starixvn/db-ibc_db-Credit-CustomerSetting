ALTER PROCEDURE [dbo].[Acc_ExecRep_Cust_10]
	@custid int,
	@roleid tinyint,
	@action varchar(30) = '',
	@EnableVirtualrate BIT = 0,
	@Suspended	BIT =0,
	@Closed		BIT =0,
	@disabledCS BIT =0,
	@DisableLiveCasino BIT = 0,
	@DisableHRFixedOdds BIT = 0,
	@DisableVS BIT = 0,
	@EnableVS BIT = 0,
	@DisableNumberGame BIT = 0,
	@DisableGoldDeluxe BIT = 0,
	@BingoStatus BIT = 0,
	@AutoSuspendSoccer BIT = 0,
	@AutoSuspendOtherSports BIT = 0
AS 
/*
Created: Daniel
Date: 20150605
Task : Update custinfo
DB: DBCUST/CustDB
Replication Info: Inlcude in exec rep from DBCUST.custDB -> DBTRANS.custDB & DB05x/DB06/DB04x/DBTP.bodb02
Original: Acc_CustomerInfo_Execrep_04


Revisions:
	- 20150605@Daniel: 
	  + Created, split update custinfo part in SP Acc_CustomerInfo_Execrep_04 into this SP for separate custDB to new server DBCUST
	  + Improve medthod check table existing in subscribers
	  

Param's Explanation:
	@Action: 
		+ 'Suspended': Suspended/Reject		[@Suspended]
		+ 'Closed': Closed					[@Closed]
		+ 'disabledCS': RNG Casino Status	[@disabledCS]
		+ 'DisableLiveCasino': Live Casino status [@DisableLiveCasino]
		+ 'DisableVS': Disable Virtual Sport [@DisableVS]
		+ 'EnableVS': Enable Virtual Sport [@EnableVS]
		+ 'DisableNumberGame': Number game status [@DisableNumberGame]
		+ 'DisableHRFixedOdds': HR Fixed Odds status [@DisableHRFixedOdds]
		+ 'BingoStatus': Bingo status [@BingoStatus]
		+ 'AutoSuspend': Auto suspend all: Soccer and Other Sports [@AutoSuspendSoccer, @AutoSuspendOtherSports]
		+ 'AutoSuspendSoccer': Auto suspend for Soccer[@AutoSuspendSoccer]
		+ 'AutoSuspendOther': Auto suspend for Other Sports [@AutoSuspendOtherSports]
		+ 'UpdKeno-Hide' : Hide Keno gaming
   
*/
SET NOCOUNT ON 

	
if @action = 'VirtualMultiplier'
BEGIN
	DECLARE @EnableVirtualrateOld BIT
		
	SELECT @EnableVirtualrateOld = virtualmultiplier
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF (@EnableVirtualrateOld <> @EnableVirtualrate AND dbo.f_CheckRepTable('custinfo') = 1)
	BEGIN
		if @roleid = 4
		BEGIN			
			update custinfo with (ROWLOCK, UPDLOCK) set virtualmultiplier = @EnableVirtualrate
			where srecommend = @custid
			
		END
		else if @roleid = 3
		BEGIN			
			update custinfo with (ROWLOCK, UPDLOCK) set virtualmultiplier = @EnableVirtualrate
			where mrecommend = @custid			
		END
		else if @roleid = 2
		BEGIN			
			update custinfo with (ROWLOCK, UPDLOCK) set virtualmultiplier = @EnableVirtualrate
			where recommend = @custid			
		END
		else if @roleid = 1
		BEGIN			
			update custinfo with (ROWLOCK, UPDLOCK) set virtualmultiplier = @EnableVirtualrate
			where custid = @custid			
		END
	END
		
END
ELSE IF (@Action ='Suspended' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	if @RoleID = 4 
	BEGIN
		UPDATE	CustInfo with (ROWLOCK, UPDLOCK) 
		SET		Reject = @Suspended 
		WHERE	SRecommend = @CustID
	END
	ELSE IF @RoleID = 3 
	BEGIN
		UPDATE	CustInfo with (ROWLOCK, UPDLOCK) 
		SET		Reject = @Suspended 
		WHERE	MRecommend = @CustID
	END
	ELSE IF @RoleID = 2 
	BEGIN
		UPDATE	CustInfo with (ROWLOCK, UPDLOCK) 
		SET		Reject = @Suspended 
		WHERE	Recommend = @CustID
	END
END
ELSE IF (@Action='Closed' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	IF @RoleID = 4 
	BEGIN
		UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		SET		closed = @closed 
		WHERE	srecommend = @custid
	END
	ELSE IF @RoleID = 3 
	BEGIN
		UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		SET		closed = @closed 
		WHERE	mrecommend = @custid
	END
	ELSE IF @RoleID = 2 
	BEGIN
		UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		SET		closed = @closed 
		WHERE	recommend = @custid
	END	
END
ELSE IF (@Action ='disabledCS' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	IF @RoleID = 4
	BEGIN
		UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
		SET		DisableCasino = @disabledCS
		WHERE	SyncCasino=1 AND srecommend=@custid AND roleid BETWEEN 1 AND 3 
	END
	ELSE IF @RoleID = 3
	BEGIN
		UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
		SET		DisableCasino = @disabledCS
		WHERE	SyncCasino=1 AND mrecommend=@custid AND roleid BETWEEN 1 AND 2 
	END
	ELSE IF @RoleID = 2
	BEGIN
		UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
		SET		DisableCasino = @disabledCS
		WHERE	SyncCasino=1 AND recommend=@custid AND roleid = 1
	END
END
ELSE IF (@Action = 'DisableLiveCasino' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN 
	IF @roleid = 4
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK)
			SET DisableLiveCasino = @DisableLiveCasino
			WHERE srecommend = @custid 
		
	IF @roleid = 3 
		UPDATE CustInfo WITH(ROWLOCK, UPDLOCK)
		SET DisableLiveCasino = @DisableLiveCasino
		WHERE mrecommend = @custid 
		
	IF @roleid =2
		UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
		SET DisableLiveCasino = @DisableLiveCasino
		WHERE recommend = @custid 	
END
ELSE IF (@Action = 'DisableVS' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	if @RoleID = 4 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableVirtualSports = @DisableVS 
		where SRecommend = @CustID

	if @RoleID = 3 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableVirtualSports = @DisableVS 
		where MRecommend = @CustID

	if @RoleID = 2 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableVirtualSports = @DisableVS 
		where Recommend = @CustID
END
ELSE IF (@Action = 'EnableVS' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	IF @roleid = 4
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET DisableVirtualSports = @EnableVS,  
				HideVirtualSports = CASE WHEN HideVirtualSports = 1 THEN 0 ELSE HideVirtualSports END 
		WHERE srecommend = @custid  
	
	IF @roleid = 3
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET DisableVirtualSports = @EnableVS,  
				HideVirtualSports = CASE WHEN HideVirtualSports = 1 THEN 0 ELSE HideVirtualSports END
		WHERE mrecommend = @custid 
	IF @roleid = 2
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET DisableVirtualSports = @EnableVS,  
				HideVirtualSports = CASE WHEN HideVirtualSports = 1 THEN 0 ELSE HideVirtualSports END 
		WHERE recommend = @custid 
END
ELSE IF (@Action = 'DisableNumberGame' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	if @RoleID = 4 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableNumber = @DisableNumberGame 
		where SRecommend = @CustID

	if @RoleID = 3 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableNumber = @DisableNumberGame 
		where MRecommend = @CustID

	if @RoleID = 2 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableNumber = @DisableNumberGame 
		where Recommend = @CustID
END
ELSE IF (@Action = 'DisableHRFixedOdds' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	if @RoleID = 4 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableHRFixedOdds = @DisableHRFixedOdds
		where SRecommend = @CustID

	if @RoleID = 3 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableHRFixedOdds = @DisableHRFixedOdds 
		where MRecommend = @CustID

	if @RoleID = 2 
		update CustInfo with (ROWLOCK, UPDLOCK) 
		set DisableHRFixedOdds = @DisableHRFixedOdds 
		where Recommend = @CustID
END
ELSE IF (@Action = 'BingoStatus' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	IF @RoleID = 4
		UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET
			DisableBingo = @BingoStatus
		WHERE SyncBingo=1 AND srecommend=@custid AND roleid in (1,2,3)
	IF @RoleID = 3
		UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET
			DisableBingo = @BingoStatus
		WHERE SyncBingo=1 AND mrecommend=@custid AND roleid in (1,2)
	IF @RoleID = 2
		UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET
			DisableBingo = @BingoStatus
		WHERE SyncBingo=1 AND recommend=@custid AND roleid = 1
END
else if (@Action = 'AutoSuspend' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	IF @roleID = 4 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend2 = @AutoSuspendOtherSports, 
			autosuspend = @AutoSuspendSoccer
		WHERE srecommend = @custID 
	END

	IF @roleID = 3 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend2 = @AutoSuspendOtherSports,	
			autosuspend = @AutoSuspendSoccer
		WHERE mrecommend = @custID 
	END

	IF @roleID = 2 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend2 = @AutoSuspendOtherSports,	
			autosuspend = @AutoSuspendSoccer
		WHERE recommend = @custID 
	END
END
else IF (@Action = 'AutoSuspendSoccer' AND dbo.f_CheckRepTable('custinfo') = 1)
begin 
	IF @roleID = 4 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend = @AutoSuspendSoccer	
		WHERE srecommend = @custID 
	END

	IF @roleID = 3 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend = @AutoSuspendSoccer	
		WHERE mrecommend = @custID 
	END

	IF @roleID = 2 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend = @AutoSuspendSoccer	
		WHERE recommend = @custID 
	END
end
else if (@Action = 'AutoSuspendOther' AND dbo.f_CheckRepTable('custinfo') = 1)
begin
	IF @roleID = 4 
		BEGIN
			UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
			SET	autosuspend2 = @AutoSuspendOtherSports
			WHERE srecommend = @custID 	
		END

	IF @roleID = 3 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend2 = @AutoSuspendOtherSports	
		WHERE mrecommend = @custID 
	END

	IF @roleID = 2 
	BEGIN
		UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		SET	autosuspend2 = @AutoSuspendOtherSports	
		WHERE recommend = @custID 
	END
end
/**20140228@Bobby: Update Keno status [Redmine:#12474]**/
else if (@Action = 'UpdKeno-Hide' AND dbo.f_CheckRepTable('custinfo') = 1)
begin
	IF (@roleID = 4)
	BEGIN
		UPDATE cust
		SET HideKeno = 0
		FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK) 
		WHERE CustID <> @CustID
			AND SRecommend = @CustID
	END

	IF (@roleID = 3)
	BEGIN
		UPDATE cust
		SET HideKeno = 0
		FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK) 
		WHERE CustID <> @CustID
			AND MRecommend = @CustID
	END

	IF (@roleID = 2)
	BEGIN
		UPDATE cust
		SET HideKeno = 0
		FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK) 
		WHERE CustID <> @CustID
			AND Recommend = @CustID
	END
end
--@20150424@Johnson: add Gold Deluxe
ELSE IF (@Action = 'GoldDeluxe' AND dbo.f_CheckRepTable('custinfo') = 1)
BEGIN
	IF (@roleID = 4)
	BEGIN
		UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		SET DisableGoldDeluxe = @DisableGoldDeluxe,
			HideGoldDeluxe = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE HideGoldDeluxe END		
		WHERE CustID <> @CustID
			AND SRecommend = @CustID
	END

	IF (@roleID = 3)
	BEGIN
		UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		SET DisableGoldDeluxe = @DisableGoldDeluxe,
			HideGoldDeluxe = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE HideGoldDeluxe END				
		WHERE CustID <> @CustID
			AND MRecommend = @CustID
	END

	IF (@roleID = 2)
	BEGIN
		UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		SET DisableGoldDeluxe = @DisableGoldDeluxe,
			HideGoldDeluxe = CASE WHEN HideGoldDeluxe = 1 THEN 0 ELSE HideGoldDeluxe END				
		WHERE CustID <> @CustID
			AND Recommend = @CustID
	END
END