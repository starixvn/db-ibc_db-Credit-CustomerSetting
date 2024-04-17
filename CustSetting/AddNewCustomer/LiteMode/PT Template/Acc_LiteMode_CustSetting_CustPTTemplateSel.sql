/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateSel] 
	@CustID INT,
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20230508@Johnson  
	Task : Get PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230508@Johnson: initial sp [redmine: #179159]
		- 20231204@Johnson: Sort SubGroup [redmine: #197629]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	Param's Explanation: 
		- @TemplateID = 0: get All	
*/	
BEGIN
	SET NOCOUNT ON 
	DECLARE @tmpProductSettingProfile TABLE(GroupID TINYINT, SubGroupID TINYINT, SubGroupOrder TINYINT)	
	
	IF @SettingStatus IN (1,0)
	BEGIN
		INSERT INTO @tmpProductSettingProfile(GroupID, SubGroupID, SubGroupOrder)
		SELECT DISTINCT GroupID, SubGroupID, SubGroupOrder
		FROM ProductSettingProfile WITH(NOLOCK)
		WHERE GroupType = 153 --PT
			AND SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END			
	END
	ELSE IF @SettingStatus = 3
	BEGIN
		INSERT INTO @tmpProductSettingProfile(GroupID, SubGroupID, SubGroupOrder)
		SELECT DISTINCT GroupID, SubGroupID, SubGroupOrder
		FROM ProductSettingProfile_UAT WITH(NOLOCK)
		WHERE GroupType = 153 --PT
			AND SettingStatus <> 2
	END
	
	SELECT t.TemplateID, TemplateName, cs.GroupID, cs.SubGroupID, PT, IsDefault	
	FROM CustPTTemplate t WITH(NOLOCK)
		INNER JOIN CustPTTemplateDetail cs WITH(NOLOCK) ON t.TemplateID = cs.TemplateID
		LEFT JOIN @tmpProductSettingProfile p ON cs.GroupID = p.GroupID AND cs.SubGroupID = p.SubGroupID
	WHERE custid = @custid
	ORDER BY t.TemplateID DESC, cs.GroupID ASC, SubGroupOrder ASC
END	