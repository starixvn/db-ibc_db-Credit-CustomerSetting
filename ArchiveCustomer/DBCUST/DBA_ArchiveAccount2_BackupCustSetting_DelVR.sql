/*<info serverAlias="DBARCCUST-bodb_customer" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[DBA_ArchiveAccount2_BackupCustSetting_DelVR]
	@AgentID INT
AS
/*
	Created: 20160415@Daniel
	Task: Archive unused Account - Delete old virtual setting before backup new 
	DB: DBARCCUST/bodb_customer
	Revisions:   
	- 20241030@Helios: ScaleOut Apply DeleteInHouse - Extend more table - Remove Code Old Structure [RedmineID: #201061] 
			  
*/
SET NOCOUNT ON
DELETE FROM dbo.CustVirtualSetting_Old WHERE custid IN (SELECT custid FROM bodb02.dbo.custinfo WITH(NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
GO
