USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_ExecRep_Cust_11]    Script Date: 06/30/2015 13:31:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_ExecRep_Cust_11    Script Date: 6/24/2015 11:17:26 AM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_05]   
	@custid int,  
	@roleid int,  
	@isEnable bit = 0,
	@maxperball money = 0,
	@maxpermatch money = 0,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg varchar(500) = '' OUTPUT
AS  

/*  
	Created: 20150613@Daniel
	Task: enable/disable number game for whole line - custinfo only
	DB: DBCUST/CustDB

	Revisions:	
 	- 20150613@Daniel: 
 	    + Created, split update custinfo part in SP Acc_CustSetting3rd_02 into this SP for separate custDB to new server DBCUST
	    + Improve medthod check table existing in subscribers		  
 
	Param's Explanation:
 
*/  
SET NOCOUNT ON

IF (dbo.f_CheckRepTable('custinfo') = 0) RETURN


DECLARE @isDisable BIT
SELECT @isDisable = CASE WHEN @isEnable = 1 THEN 0 ELSE 1 END
 
IF @roleid = 1 -- update for himself only
BEGIN  
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)  
	SET		disablenumber = @isDisable,		
		 	maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
		 	maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	custid = @custid

	IF @@ERROR > 0 
	BEGIN
		SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
				@ErrCode = 110
		RETURN
	END
END
ELSE IF @roleid = 2
BEGIN
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)
	SET		disablenumber = @isDisable,		
			maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
			maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	recommend = @custid

	IF @@ERROR > 0 
		BEGIN
			SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
					@ErrCode = 112
			RETURN
		END	
END
ELSE IF @roleid = 3
BEGIN
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)
	SET		disablenumber = @isDisable,		
			maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
			maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	mrecommend = @custid

	IF @@ERROR > 0 
		BEGIN
			SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
					@ErrCode = 114
			RETURN
		END	
END
ELSE IF @roleid = 4
BEGIN
	UPDATE	dbo.custinfo WITH (ROWLOCK, UPDLOCK)
	SET		disablenumber = @isDisable,		
			maxperball161 = case @isDisable when 0 then @maxperball else maxperball161 end,
			maxpermatch161 = case @isDisable when 0 then @maxpermatch else maxpermatch161 end
	WHERE	srecommend = @custid

		IF @@ERROR > 0 
			BEGIN
				SELECT  @ErrMsg = 'Update enable/disable number game unsuccessful.',
						@ErrCode = 116
				RETURN
			END	
END
GO
GRANT EXECUTE ON [dbo].[Acc_ExecRep_Cust_11] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_ExecRep_Cust_11] TO [vnteam] AS [dbo]