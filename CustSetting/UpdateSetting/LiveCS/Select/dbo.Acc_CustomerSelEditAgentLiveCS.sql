
ALTER PROCEDURE[dbo].[Acc_CustomerSelEditAgentLiveCS]
	@custid		INT,
	@mrecommend INT
AS
/*
	Created: 20111226@Lukas
	Task: Master edits agent's live casino setting
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150609@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	
	Parameters Explanation
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleID INT 

		-- Check Downline Belonging
--	EXEC dbo.Age_CustomerSelCheckBelonging  
--			@SessionCustID	= @mrecommend, 
--			@Custid			= @CustID,
--			@roleID			= @roleID OUTPUT
--
--	IF @roleID = 0
--		RETURN

	DECLARE @v162adiscount_1101	DECIMAL(9,8),
			@DisableAutoMPT		BIT,
			@max_v162mpositiontaking_1101 SMALLMONEY

	SELECT @DisableAutoMPT = DisableAutoMPT
	FROM custmaster WITH(NOLOCK)
	WHERE custid = @mrecommend
			
	
	--Master Comm	
	SELECT	@v162adiscount_1101 = adiscount,
			@max_v162mpositiontaking_1101 = mpositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101

	SELECT 	
		ISNULL(discount,0) AS v162discount_1101,
		ISNULL(@v162adiscount_1101,0) AS v162discount_1101_max,
		ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,		

		--a2
		apositiontaking AS v162apositiontaking_1101,		
		--m2		
		mpositiontaking AS v162mpositiontaking_1101,
		@max_v162mpositiontaking_1101 AS v162mpositiontaking_1101_max,
		--u2
		autompositiontaking AS auto_v162mpositiontaking_1101,		
		--i2
		isautompositiontaking AS isauto_v162mpositiontaking_1101,		
		--u2_max
		@max_v162mpositiontaking_1101 AS auto_v162mpositiontaking_1101_max,
		
		--n2
		co.minpositiontaking as v162apositiontaking_1101_min	
	FROM custsettingGame cs WITH(NOLOCK)
			INNER JOIN custoverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
	WHERE cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101

END


GO
GRANT VIEW DEFINITION ON [Acc_CustomerSelEditAgentLiveCS] TO vnteam
GO
GRANT EXECUTE ON [Acc_CustomerSelEditAgentLiveCS] TO bodbAdminNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditAgentLiveCS] TO bodbDownlineNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditAgentLiveCS] TO bodbDownlineNetView
