/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelStatusNumberGame]
	@CustId		INT
AS
/*
	Created: Johnson
	Date: 2018-02-05
	Task: Get status Number Game of customer
	DB: DBCUST/CustDB

	Revisions:
		- 20180205@Johnson: create new sp for new direction status [Redmine:#87328]					
	Parameter's Explanation:
 */
 BEGIN       
	SET NOCOUNT ON           
	
	DECLARE
		@roleid INT,
		@DisableNumber BIT,
		@TotalDisabledMasters INT=0,
		@TotalEnabledMasters INT =0,
		@TotalDisabledAgents INT=0,
		@TotalEnabledAgents INT=0,
		@TotalDisabledMembers INT=0,
		@TotalEnabledMembers INT=0
	
	SELECT @roleid = roleid,
		@DisableNumber = DisableNumber
	FROM dbo.CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @roleid NOT IN (1,2,3,4)
		RETURN
	
	IF @roleid = 4 
	BEGIN
		SELECT @TotalDisabledMasters = SUM(CASE WHEN roleid = 3 AND DisableNumber =1 THEN 1 ELSE 0 END),
			@TotalEnabledMasters = SUM(CASE WHEN roleid = 3 AND DisableNumber =0 THEN 1 ELSE 0 END),
			@TotalDisabledAgents = SUM(CASE WHEN roleid = 2 AND DisableNumber =1 THEN 1 ELSE 0 END),
			@TotalEnabledAgents = SUM(CASE WHEN roleid = 2 AND DisableNumber =0 THEN 1 ELSE 0 END),
			@TotalDisabledMembers = SUM(CASE WHEN roleid = 1 AND DisableNumber =1 THEN 1 ELSE 0 END),
			@TotalEnabledMembers = SUM(CASE WHEN roleid = 1 AND DisableNumber =0 THEN 1 ELSE 0 END)
		FROM dbo.CustInfo WITH(NOLOCK)
		WHERE srecommend = @custid
			AND custid <> @custid
	END	
	ELSE IF @roleid = 3 
	BEGIN
		SELECT @TotalDisabledAgents = SUM(CASE WHEN roleid = 2 AND DisableNumber =1 THEN 1 ELSE 0 END),
			@TotalEnabledAgents = SUM(CASE WHEN roleid = 2 AND DisableNumber =0 THEN 1 ELSE 0 END),
			@TotalDisabledMembers = SUM(CASE WHEN roleid = 1 AND DisableNumber =1 THEN 1 ELSE 0 END),
			@TotalEnabledMembers = SUM(CASE WHEN roleid = 1 AND DisableNumber =0 THEN 1 ELSE 0 END)
		FROM dbo.CustInfo WITH(NOLOCK)
		WHERE mrecommend = @custid
			AND custid <> @custid
	END	
	ELSE IF @roleid = 2 
	BEGIN
		SELECT @TotalDisabledMembers = SUM(CASE WHEN roleid = 1 AND DisableNumber =1 THEN 1 ELSE 0 END),
			@TotalEnabledMembers = SUM(CASE WHEN roleid = 1 AND DisableNumber =0 THEN 1 ELSE 0 END)
		FROM dbo.CustInfo WITH(NOLOCK)
		WHERE recommend = @custid
			AND custid <> @custid
	END
	
	SELECT @DisableNumber DisableNumber,
		@TotalDisabledMasters TotalDisabledMasters,
		@TotalEnabledMasters TotalEnabledMasters,
		@TotalDisabledAgents TotalDisabledAgents,
		@TotalEnabledAgents TotalEnabledAgents,
		@TotalDisabledMembers TotalDisabledMembers,
		@TotalEnabledMembers TotalEnabledMembers
	
	
END
GO