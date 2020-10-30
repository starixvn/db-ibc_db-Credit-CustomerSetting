/*<info serverAlias="DBSPARE-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_Archive_Cust_SuperMaster]
	@CustID	INT,
	@Stage SMALLINT
AS 
/*
		Description: Disable an Master, Super
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
*/
BEGIN
	IF @Stage = 1
	BEGIN 
		IF dbo.f_CheckRepTable('Custinfo') = 0
			RETURN
		ELSE 
		BEGIN
			UPDATE dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
			SET		closed = 1
			WHERE	custid = @CustID
		END 
	END	
	ELSE 
	IF @Stage = 2 
	BEGIN 
		IF dbo.f_CheckRepTable('Custinfo') = 0
			RETURN
		ELSE 
		BEGIN
			UPDATE dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
			SET		[enabled] = 0, closed = 1, credit = 0
			WHERE	custid = @CustID
			 
		END 
	END	
	ELSE IF @Stage = 3
	BEGIN
		IF dbo.f_CheckRepTable('CustVirtualSetting') = 1
		BEGIN
			DELETE 
			FROM dbo.CustVirtualSetting WITH(ROWLOCK,UPDLOCK)
			WHERE	custid = @CustID
				
		END

	     IF (dbo.f_CheckRepTable('CustSetting') = 1 
		  AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	     )
		BEGIN
			
			DELETE  dbo.CustSetting WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID
		
			DELETE  dbo.CustSetting3rd WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID
				
		END
	
	     IF (dbo.f_CheckRepTable('CustSettingGame') = 1 
		  AND dbo.f_CheckRepTable('CustGameType') = 1 
	     )
		BEGIN			
			
			DELETE  dbo.[CustSettingGame] WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID
		
			DELETE  dbo.[CustGameType] WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID
					
		END

		IF dbo.f_CheckRepTable('CustProductStatus') = 1 		
		BEGIN
			DELETE  dbo.CustProductStatus WITH (ROWLOCK)
			WHERE	custid = @CustID
		END	
			
	END 
	ELSE IF @Stage = 4
	BEGIN
				
	    IF (dbo.f_CheckRepTable('Custinfo') = 1 
		  AND dbo.f_CheckRepTable('Customer') = 1 
	    )
	    BEGIN
		
			DELETE  dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID
			
			DELETE dbo.Customer WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID
		END	
				
	END 
END
