/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_alpv,wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustSetting_GetUplineByCustID] 
	  @CustID		INT,
	  @UplineID		INT OUTPUT
AS
/*
	Created: 20250813@Helios
	Task : Get User infor by CustID - ALPHA
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20250813@Helios: Agency Cash Service -Customer Setting Sprint 8 [redmine: #235266]

	Param's Explanation:
		DECLARE @p1 INT 
			EXEC Age_CustSetting_GetUplineByCustID_UAT2 @CustID = 249558220 , @UplineID = @p1 OUTPUT
		SELECT @p1
*/
BEGIN
	SET NOCOUNT ON;

	SELECT @UplineID = ( SELECT

						CASE
							WHEN (roleid = 1 AND i.recommend = - 4) OR i.roleid = 3	THEN i.srecommend
							WHEN (roleid = 1 AND i.recommend = - 3) OR i.roleid = 2	THEN i.mrecommend
							WHEN (roleid = 1 AND i.recommend NOT IN (-3,-4))		THEN i.recommend
						ELSE 0 
							END	
					FROM custInfo i WITH (NOLOCK)
					WHERE i.custid = @CustID
				)
END
GO