/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_DestConfig_Select
--	@SiteDBGroupID SMALLINT
AS
/*
	 Created by: 20240628@Louisa
	 Task: init [Redmine:#204370]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#204370]
		- 20240628@Louisa: Add GroupID [Redmine:#207025]
*/
BEGIN
	SELECT Tablename
			,rID
			,Interval
			,BatchSize
			,SPSelect
			,SPInsert
			,SiteDBGroupID
			,GroupID
	FROM Dest_ServiceTransform WITH(NOLOCK)
	WHERE StatusID = 1
		--AND SiteDBGroupID = @SiteDBGroupID
END
GO
