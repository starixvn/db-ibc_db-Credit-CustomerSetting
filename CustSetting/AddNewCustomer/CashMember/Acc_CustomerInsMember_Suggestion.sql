/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_Suggestion]
	@UplineCustID	INT,
	@Username		VARCHAR(30) = '',
	@Mode			TINYINT = 0
AS
/*
	Created: 20250422@Elodie	
	Task: Search cash member 
	DB:  DBCUST-CustDB
		
	Revisions:
		- 20250422@Elodie: Offer Cash member [redmine:#223896] 

	Parameter's Explanation:		
		@UplineCustID: AgentId
		@Username: Prefix username
		@Mode: 0: search copy credit member
			   1: create new cash member
	Examples:
	EXEC CustDB.dbo.Acc_CustomerInsMember_Suggestion 
		@UplineCustID = 179806626,
		@Username = 'EdenTestS1',
		@Mode = 1
	*/ 
BEGIN	
	SET NOCOUNT ON
	
	SELECT TOP 10 c.username, c.username2, c.firstname, c.lastname, c1.custid
	FROM customer c1 WITH (NOLOCK)
		INNER JOIN vw_CustInfoExtra cs WITH (NOLOCK) ON c1.custid = cs.custid
		CROSS APPLY (	SELECT TOP 1 username, username2,firstname,lastname
						FROM Customer WITH (NOLOCK)
						WHERE custid = c1.custid 
							AND (username LIKE @username  + '%' 
									OR username2 LIKE @username  + '%' 
									OR firstname LIKE @username  + '%' 
									OR lastname LIKE @username  + '%' 
								)
					) c
	WHERE roleid = 1
		AND recommend = @UplineCustID
		AND ((@Mode = 1 AND cs.ServiceType = 1) OR (@Mode = 0 AND cs.ServiceType = 0))
	ORDER BY c.username	
END
