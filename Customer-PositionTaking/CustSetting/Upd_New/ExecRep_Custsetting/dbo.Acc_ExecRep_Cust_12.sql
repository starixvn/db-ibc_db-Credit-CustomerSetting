ALTER PROCEDURE [Acc_ExecRep_Cust_12]  
	@custid    INT,  
	@roleid    TINYINT,
	@sporttype smallint,
	@maxpermatch MONEY,  
	@ErrCode   INT = 0 OUTPUT,  
	@ErrMsg    NVARCHAR(200) = '' OUTPUT  
AS  
/*  

Created: Daniel  
Date: 2012-09-19  
Task: exec replicate to update status and bet setting virtual sports for downlines  
DB: DBCUST/CustDB  

Revisions:  
	- 20121203@Scott : update status and bet setting for virtual tennis by setting's virtual soccer  
	- 20121211@Scott : don't update status virtual sport
	- 20120221@Johnson: add virtual horse racing setting (sporttype :181)
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)	
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]					
 	- 20150613@Daniel: 
 	    + Created, split update custinfo part in SP Acc_CustSetting3rd_03 into this SP for separate custDB to new server DBCUST
	    + Improve medthod check table existing in subscribers	
	
Parameter's Explanation:  

*/

SET NOCOUNT ON  

 if (dbo.f_CheckRepTable('custinfo') = 0) RETURN


IF @roleid = 4  
BEGIN  
	
	IF @sporttype = 180 
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch180 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 181
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch181 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 182
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch182 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 

	IF @sporttype = 183
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch183 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 184
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch184 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
	IF @sporttype = 185
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch185 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 

	IF @sporttype = 186 
	BEGIN 
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK) 
			SET MaxPerMatch186 = @maxpermatch	
		WHERE srecommend = @custid  
		
	END 
	
 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 301  
		RETURN  
	END  
END  

ELSE IF @roleid = 3  
BEGIN

	IF @sporttype = 180 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch180 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 181 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch181 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 182
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch182 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 183
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch183 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 184
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch184 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 185
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch185 = @maxpermatch
		WHERE mrecommend = @custid  
		
	END 
	IF @sporttype = 186 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch186 = @maxpermatch 
		WHERE mrecommend = @custid  
		
	END 
 
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 303  
		RETURN  
	END  
 
END 
 
ELSE IF @roleid = 2  
BEGIN  

	IF @sporttype = 180 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch180 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 181 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch181 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 182
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch182 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 183
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch183 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 184
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch184 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 185
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch185 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	IF @sporttype = 186 
	BEGIN
	
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
			SET MaxPerMatch186 = @maxpermatch  
		WHERE recommend = @custid  
		
	END
	
	
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 305  
		RETURN  
	END  
 
END  

GO
GRANT EXECUTE ON [dbo].[Acc_ExecRep_Cust_12] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_ExecRep_Cust_12] TO [vnteam] AS [dbo]
