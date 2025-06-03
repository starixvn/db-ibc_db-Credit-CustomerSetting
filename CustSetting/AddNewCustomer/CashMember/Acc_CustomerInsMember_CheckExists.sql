/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].Acc_CustomerInsMember_CheckExists
	@UplineCustID	INT,
	@Username		VARCHAR(30) = '',
	@Mode			TINYINT = 0
AS
/*
	Created: 20250422@Elodie			
	Task: Check exist cash member under this upline
	DB:  DBCUST-CustDB
		
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 

	Parameter's Explanation:		
		@UplineCustID: Super/MasterID
		@Username: custinfo.username
	
	Examples:
	EXEC CustDB..Acc_CustomerInsMember_CheckExists 
		@UplineCustID = 179806625,
		@Username = 'EdenTestS10000001',
		@Mode = 1
	*/ 
BEGIN	
	SET NOCOUNT ON
	DECLARE @CustID INT
	--Check exist username/username2
	SELECT @CustID = c.custid
	FROM customer c WITH (NOLOCK)
	WHERE c.username = @Username

	IF @CustID IS NULL
		SELECT @CustID = c.custid
		FROM customer c WITH (NOLOCK)
		WHERE c.username2 = @Username

	SELECT c.username,c.custid,c.Enabled  
	FROM custinfo c WITH(NOLOCK) 
		INNER JOIN vw_CustInfoExtra cs WITH (NOLOCK) ON c.custid = cs.custid
	WHERE c.custid = @CustID 
		AND c.recommend = @UplineCustID 
		AND c.roleid = 1
		AND ((@Mode = 1 AND cs.ServiceType = 1) OR (@Mode = 0 AND cs.ServiceType = 0))
END
GO