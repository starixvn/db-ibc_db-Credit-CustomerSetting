ALTER PROCEDURE [dbo].[Acc_CustSetting_MultiCustPermissionValidate]  
	@CustID INT 
	,@TargetCustIDLst VARCHAR(MAX)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) ='' OUTPUT    
AS  
/*  
	Created: 20150528@Dominic  
	Task: Validate user permission 
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @tblCust TABLE(CustID INT)
	DECLARE @FakeCustCnt INT = 0
	DECLARE @isEnable BIT = 1, @RoleID INT
	DECLARE @username NVARCHAR(50)
	SELECT @ErrCode=0,@ErrMsg=''
	
	INSERT INTO @tblCust (CustID)
	SELECT CONVERT(INT, val)
	FROM dbo.strSplit(@TargetCustIDLst, ',') 
	
	SELECT @FakeCustCnt = COUNT(1)
	FROM @tblCust c
	LEFT JOIN dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.CustID
	WHERE ci.username IS NULL
	
	--Check if Actor was disabled
	IF @FakeCustCnt <> 0  
	BEGIN  
		SELECT @ErrMsg = 'Some Accounts were disabled!'  
		SELECT @ErrCode = 1
		RETURN  
	END 
	
	SELECT @FakeCustCnt = COUNT(1)
	FROM dbo.custinfo ci WITH (NOLOCK)  
	JOIN @tblCust c ON c.CustID = ci.CustID
	WHERE ISNULL([enabled],0) = 0

	
	--Check if Actor was disabled
	IF @isEnable = 0 or @FakeCustCnt <> 0  
	BEGIN  
		SELECT @ErrMsg = 'Some Accounts were disabled!'  
		SELECT @ErrCode = 2
		RETURN  
	END  
	
	--Check if roleid of taget cusomer is not consistent
	SELECT TOP 1 @RoleID = ISNULL(RoleID,0)
	FROM @tblCust c
		INNER JOIN dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.CustID
	
	SELECT @FakeCustCnt = COUNT(1)
	FROM @tblCust c
	INNER JOIN dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.CustID
	WHERE ci.roleID <> @RoleID
	
	IF @FakeCustCnt <> 0
	BEGIN  
		SELECT @ErrMsg = 'Invalid Permission!' 
		SELECT @ErrCode = 3
		RETURN  
	END  
	
	
	--Check if Actor has roleid smaller than target customer
	SELECT @RoleID = ISNULL(RoleID,0) 
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @CustID
	
	SELECT @FakeCustCnt = COUNT(1)
	FROM @tblCust c
	JOIN dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.CustID
	WHERE ci.roleID >= @RoleID
	
	IF @FakeCustCnt <> 0
	BEGIN  
		SELECT @ErrMsg = 'Invalid Permission!' 
		SELECT @ErrCode = 4
		RETURN  
	END  
	
	--Check if Actor is not in the same line with target customer
	SELECT @FakeCustCnt = COUNT(1)
	FROM @tblCust c
	JOIN dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.CustID
	WHERE
		NOT (ci.srecommend = @CustID or ci.mrecommend = @CustID
			or ci.recommend = @CustID or ci.custid = @CustID
			OR @RoleID >= 5)
			
	IF @FakeCustCnt <> 0
	BEGIN  
		SELECT @ErrMsg = 'Customers are not in the same line!' 
		SELECT @ErrCode = 5
		RETURN 
	END  
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MultiCustPermissionValidate] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MultiCustPermissionValidate] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MultiCustPermissionValidate] TO [bodbExtAccNet]