/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_DelCustSettingSportsbook]
	@AgentID	INT,
	@Type		SMALLINT
AS 
/*
	Created by: 20240613@Johnson	
	Task: For archive Acc (New) - update/delete part in stage 1,2,3 
	DB: DBCUST/CustDB
	
	Revisions:
		- 20240613@Johnson: Scale out DBCUST [redmine: #199915]
		
	Param's Explanation:
		@Type: 
			+ -1-Stage 1: update closed = 1 for whole agent line
			+ 0 -Stage 2: update enable = 0 & credit = 0 for whole agent line
			+ 1 -Stage 3: Delete cust setting for members under agent
			+ 2 -Stage 4: Delete cust info for members under agent	
*/
BEGIN
	SET NOCOUNT ON;
	
	IF @Type = 1
	BEGIN
		WHILE(1=1)
		BEGIN
			DELETE TOP(5000) dbo.BetSetting_Member WITH (ROWLOCK)
			WHERE	custid IN (SELECT custid FROM Custinfo WITH (NOLOCK) 
								WHERE roleid = 1 
									AND recommend = @AgentID
									)
			IF @@ROWCOUNT < 5000 
				BREAK
		END
		
		DELETE dbo.BetSetting_Agent WITH (UPDLOCK,ROWLOCK)
		WHERE	custid = @AgentID 			
	END
END	