/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateSel] 
	@CustID INT,
	@CreationStatus TINYINT = 0
AS
/*
	Created: 20230508@Johnson  
	Task : Get PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230508@Johnson: initial sp [redmine: #179159]
		- 20231204@Johnson: Sort SubGroup [redmine: #197629]
	Param's Explanation: 
		- @TemplateID = 0: get All	
*/	
BEGIN
	SET NOCOUNT ON 
	DECLARE @tmpProductSettingProfile TABLE(GroupID TINYINT, SubGroupID TINYINT, SubGroupOrder TINYINT)	
	
	IF @CreationStatus IN (1,0)
	BEGIN
		INSERT INTO @tmpProductSettingProfile(GroupID, SubGroupID, SubGroupOrder)
		SELECT DISTINCT GroupID, SubGroupID, SubGroupOrder
		FROM ProductSettingProfile WITH(NOLOCK)
		WHERE GroupType = 153 --PT
			AND CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END			
	END
	ELSE IF @CreationStatus = 3
	BEGIN
		INSERT INTO @tmpProductSettingProfile(GroupID, SubGroupID, SubGroupOrder)
		SELECT DISTINCT GroupID, SubGroupID, SubGroupOrder
		FROM ProductSettingProfile_UAT WITH(NOLOCK)
		WHERE GroupType = 153 --PT
			AND CreationStatus <> 2
	END
	
	SELECT t.TemplateID, TemplateName, cs.GroupID, cs.SubGroupID, PT, IsDefault	
	FROM CustPTTemplate t WITH(NOLOCK)
		INNER JOIN CustPTTemplateDetail cs WITH(NOLOCK) ON t.TemplateID = cs.TemplateID
		LEFT JOIN @tmpProductSettingProfile p ON cs.GroupID = p.GroupID AND cs.SubGroupID = p.SubGroupID
	WHERE custid = @custid
	ORDER BY t.TemplateID DESC, cs.GroupID ASC, SubGroupOrder ASC
END	