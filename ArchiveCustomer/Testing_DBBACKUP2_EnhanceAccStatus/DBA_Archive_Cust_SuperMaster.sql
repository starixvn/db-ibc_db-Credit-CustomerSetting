/*<info serverAlias="DBBACKUP2-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_Archive_Cust_SuperMaster]
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
			- 20201130@Eden: NAP/Alpha & EXT - Apply color for archived accounts [Redmine:145018]
			- 20210316@Helen: backup CustSub and delete for stage 4 [RedmineID: #130032]
			- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
			- 20210810@Eden: Enhance Performance for stage 1 [RedmineID: #155969]
*/
BEGIN
	DECLARE @RoleID INT

	IF @Stage = 1
	BEGIN 
		SELECT @RoleID = ci.roleid FROM custInfo ci WITH (NOLOCK) WHERE ci.custid = @CustID
		--CLosed Super, Master, Agent
		IF dbo.f_CheckRepTable('Custinfo') = 0
		   OR dbo.f_CheckRepTable('CustProductStatus') = 0
			RETURN
		ELSE 
		BEGIN
			IF @RoleID = 4
			BEGIN
				WHILE (1=1)
				BEGIN 
					UPDATE TOP(5000) cps
						SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					FROM dbo.custInfo ci WITH (NOLOCK)
						INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
					WHERE ci.srecommend = @CustID AND ci.roleid IN (4,3) AND CloseInfo&POWER(2,@RoleID - 1) = 0

					IF @@ROWCOUNT < 5000
						BREAK
				END
			END
			ELSE IF @RoleID = 3
			BEGIN
				WHILE (1=1)
				BEGIN
					UPDATE TOP(5000) cps
						SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					FROM dbo.custInfo ci WITH (NOLOCK)
						INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
					WHERE ci.mrecommend = @CustID AND ci.roleid IN (3,2) AND CloseInfo&POWER(2,@RoleID - 1) = 0 

					IF @@ROWCOUNT < 5000
						BREAK
				END
			END
		END

		IF dbo.f_CheckRepTable('CustLoginInfo') = 0 
			RETURN
		BEGIN
			--> Insert Update ClosedReason
			IF NOT EXISTS (SELECT 1 FROM dbo.CustLoginInfo WITH(NOLOCK) WHERE custid = @custid)
				INSERT INTO CustLoginInfo(CustID, ClosedReason) SELECT @CustID, 4
			ELSE
				UPDATE m
				SET ClosedReason = 4
				FROM CustLoginInfo m WITH (ROWLOCK, UPDLOCK)
				WHERE m.CustID = @CustID
		END 
	END	
	ELSE IF @Stage = 2 
	BEGIN 
		IF dbo.f_CheckRepTable('Custinfo') = 0
			RETURN
		ELSE 
		BEGIN
			UPDATE dbo.Custinfo WITH (UPDLOCK,ROWLOCK)
			SET		[enabled] = 0, credit = 0
			WHERE	custid = @CustID
			 
		END
		
		SELECT @RoleID = ci.roleid FROM custInfo ci WITH (NOLOCK) WHERE ci.custid = @CustID
		--CLosed Super, Master, Agent
		IF dbo.f_CheckRepTable('Custinfo') = 0
		   OR dbo.f_CheckRepTable('CustProductStatus') = 0
			RETURN
		ELSE 
		BEGIN
			IF @RoleID = 4
			BEGIN
				WHILE (1=1)
				BEGIN 
					UPDATE TOP(5000) cps
						SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					FROM dbo.custInfo ci WITH (NOLOCK)
						INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
					WHERE ci.srecommend = @CustID AND ci.roleid IN (4,3) AND CloseInfo&POWER(2,@RoleID - 1) = 0

					IF @@ROWCOUNT < 5000
						BREAK
				END
			END
			ELSE IF @RoleID = 3
			BEGIN
				WHILE (1=1)
				BEGIN
					UPDATE TOP(5000) cps
						SET CloseInfo = CloseInfo|POWER(2,@RoleID - 1)
					FROM dbo.custInfo ci WITH (NOLOCK)
						INNER JOIN CustProductStatus cps WITH (UPDLOCK,ROWLOCK) ON cps.CustID = ci.custid
					WHERE ci.mrecommend = @CustID AND ci.roleid IN (3,2) AND CloseInfo&POWER(2,@RoleID - 1) = 0 

					IF @@ROWCOUNT < 5000
						BREAK
				END
			END
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
		
		IF dbo.f_CheckRepTable('custsub') = 1 
		BEGIN
			DELETE dbo.custSub WITH (UPDLOCK,ROWLOCK)
			WHERE	custid = @CustID 
			
		END

		IF dbo.f_CheckRepTable('CustProductStatus') = 1 		
		BEGIN
			DELETE  dbo.CustProductStatus WITH (ROWLOCK)
			WHERE	custid = @CustID
		END	
				
	END 
END
    
