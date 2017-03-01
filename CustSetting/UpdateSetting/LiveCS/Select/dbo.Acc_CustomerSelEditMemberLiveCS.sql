ALTER PROCEDURE[dbo].[Acc_CustomerSelEditMemberLiveCS]
	@custid		INT,
	@recommend	INT
AS
/*
	Created: 20111226@Lukas
	Task: Agent edits member's live casino setting
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150617@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	
	Parameters Explanation
*/
BEGIN

	SET NOCOUNT ON
		
	DECLARE @roleID INT, @Username VARCHAR(30)

		-- Check Downline Belonging
	EXEC dbo.Age_CustomerSelCheckBelongingByCustID  
			@SessionCustID	= @recommend, 
			@Custid			= @CustID,
			@Username		= @Username OUTPUT,
			@roleID			= @roleID OUTPUT

	IF @roleID = 0
		RETURN

	DECLARE @srecommend INT,
			@mrecommend INT,
			@max_V162apositiontaking_1101	SMALLMONEY,
			@min_v162apositiontaking_1101	SMALLMONEY,
			@v162discount_1101				DECIMAL(9,8),
			
			@v162spt_1101		SMALLMONEY,
			@cs_v162apt_1101	SMALLMONEY
			
	SELECT @srecommend = srecommend , @mrecommend = mrecommend 
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	--
	SELECT	@max_V162apositiontaking_1101 = apositiontaking,
			@v162discount_1101 = discount
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101

	SELECT @min_v162apositiontaking_1101 = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101
	
	--s4
	SELECT @v162spt_1101 = spositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101

	--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
	SELECT @cs_v162apt_1101 = CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
									ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
												ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= @v162spt_1101-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v162spt_1101-cs.spositiontaking-cs.mpositiontaking END
											END
										 END 
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101
	
	SELECT @max_v162apositiontaking_1101 = CASE WHEN @max_v162apositiontaking_1101 <= @cs_v162apt_1101 THEN @max_v162apositiontaking_1101 ELSE @cs_v162apt_1101 END
		
	SELECT		
		apositiontaking AS v162apositiontaking_1101,
		@max_V162apositiontaking_1101 AS v162apositiontaking_1101_max,
		@min_v162apositiontaking_1101 AS v162apositiontaking_1101_min,
		playerdiscount	AS v162playerdiscount_1101,
		@v162discount_1101 AS v162playerdiscount_1101_max
	FROM CustsettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
END


/*
exec [dbo].[Acc_CustomerSelEditMemberLiveCS] @custid = 642719,@recommend = 642706
*/
GO
GRANT VIEW DEFINITION ON [Acc_CustomerSelEditMemberLiveCS] TO vnteam
GO
GRANT EXECUTE ON [Acc_CustomerSelEditMemberLiveCS] TO bodbAdminNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditMemberLiveCS] TO bodbDownlineNet
GO
GRANT EXECUTE ON [Acc_CustomerSelEditMemberLiveCS] TO bodbDownlineNetView
