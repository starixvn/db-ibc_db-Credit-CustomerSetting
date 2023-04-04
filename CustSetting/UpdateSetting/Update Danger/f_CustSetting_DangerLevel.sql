/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="1" isNested="1"></info>*/
ALTER FUNCTION [dbo].[f_CustSetting_DangerLevel]
	(@site		NVARCHAR(50),
	 @currency	INT)
RETURNS @DangerLevel TABLE (DangerLevel BIGINT)
AS
/*
	Created: 20220913@Tacy
	Task : Customer Setting - Set Danger level (Saba Sports) for newly created members [RedmineID: #177464]
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20220913@Tacy: Create Function
		- 20221226@Tacy: NAP CM - Split 789y Site [RedmineID: #184879]

	Parameter's Explanation:		
*/	
BEGIN
	DECLARE @SoccerLevel TINYINT,
            @BasketballLevel TINYINT,
			@SiteLabel VARCHAR(50)

	SELECT @SiteLabel=SiteLabel
	FROM Site WITH (NOLOCK)
	WHERE site=@Site

	SELECT	@SoccerLevel=10,
            @BasketballLevel=CASE WHEN @SiteLabel='789y' OR @currency=96 THEN 10 ELSE 9 END

	INSERT INTO @DangerLevel(DangerLevel)
    SELECT dbo.f_GenerateDangerLevelInfo(0,@SoccerLevel,@BasketballLevel,1,1)

	RETURN
END
