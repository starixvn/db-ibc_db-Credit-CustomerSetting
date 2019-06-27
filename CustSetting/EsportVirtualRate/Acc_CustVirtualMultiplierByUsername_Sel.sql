
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustVirtualMultiplierByUsername_Sel]
	@Username NVARCHAR(50)
	, @SportType INT
	, @ErrCode TINYINT OUT
	, @ErrMsg NVARCHAR(200) OUT
AS
/*    
	Created: 20190626@Dominic    
	Task :  Retrieve VR setting of an account for a specific sport  [Redmind: #114830]
	DB: DBCUST/CustDB    
	    
	Revisions:    
		- 20190626@Dominic : First commit
  
*/ 
BEGIN
	DECLARE @CustID INT

	SELECT @CustID = CustID
	FROM Customer c(NOLOCK)
	WHERE username=@Username

	EXEC Acc_CustVirtualMultiplier_Sel @CustID=@CustID, @SportType=@SportType, @ErrCode=@ErrCode OUT, @ErrMsg=@ErrMsg OUT

END