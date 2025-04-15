/*<info serverAlias="DBCUST-CUSTDB,DBAGE-bodb02" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_GetMemberType]
   @CustID		INT  
 , @CustType	TINYINT = 0		OUTPUT
 , @ErrCode		INT = 0		OUTPUT
 , @ErrMsg		VARCHAR(500) = '' OUTPUT
AS  
/*  
 Created: 202421127@Helios  
 Task : Return CustMember Type Is normal or Direct
 DB: DBCUST/CustDB, DBAGE/bodb02  
 Original:  
  
 Revisions:  
	- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]

 Example: 
	- @CustType : 1 is Normal Member
			  3 is Master direct member
			  4 is Super direct member

	declare @p1 TINYINT
	set @p1=0
	declare @p2 int
	set @p2=0
	declare @p3 varchar(500)
	set @p3=''

	EXEC [Acc_GetMemberType] @CustID = 119277402 , @CustType = @p1 OUTPUT, @ErrCode = @p2 OUTPUT, @ErrMsg = @p3 OUTPUT

	SELECT @p1 AS CustType,  @p2 AS ErrCode, @p3 AS ErrMsg
 */ 
BEGIN
	SET NOCOUNT ON 
	
	SELECT @CustType = 0 , @ErrCode = 0 , @ErrMsg = ''

	SELECT @CustType = CASE 
					WHEN i.recommend = -4 THEN 4
					WHEN i.recommend = -3 THEN 3
					ELSE 1
				 END
	FROM custInfo i WITH (NOLOCK)
	WHERE i.custid = @CustID
	AND i.roleid = 1

	IF ISNULL(@CustType,0) = 0
	BEGIN
		SELECT @ErrCode = 100 , @ErrMsg = N'Member is invalid'
		RETURN;
	END
END