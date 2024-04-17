/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
use CustDB
go
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditAgentGoldDeluxe]
	@custid		INT,
	@mrecommend INT
AS
/*
	Created: 20150422@Elodie
	Task: Master edits agent's Gold Deluxe setting
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150612@Kathy: Move sp from DBAGE.bodb02 to DBCUST.CustDB [Redmine:#36216]
		- 20150721@Patrick: Add more winlimit section
		- 20170921@Johnson: Fix the unsynchronized setting,fix @Downline status to show checkbox enable downline [Redmine: #72973]
							+@Downline = 1: has at least one customer has sync status
										=0 : all downlines not sync	
		- 20180109@Johnson: remove downlines status for new direction[Redmine:#87328]	
		- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]																						
	Parameters Explanation
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleID INT 

		-- Check Downline Belonging
	EXEC dbo.Age_CustomerSelCheckBelonging  
			@SessionCustID	= @mrecommend, 
			@Custid			= @CustID,
			@roleID			= @roleID OUTPUT

	IF @roleID = 0
		RETURN

	DECLARE @v255adiscount_1701				DECIMAL(9,8)
			,@DisableAutoMPT				BIT
			,@max_v255mpositiontaking_1701 SMALLMONEY			
			,@DisableGoldDeluxe				BIT
			,@DisableUpline					BIT = 0

	SELECT	@DisableAutoMPT = DisableAutoMPT
	FROM	dbo.custmaster WITH(NOLOCK)
	WHERE	custid = @mrecommend
	
	SELECT	@DisableGoldDeluxe = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @mrecommend
	
	--Master Comm	
	SELECT	@v255adiscount_1701 = adiscount,
			@max_v255mpositiontaking_1701 = mpositiontaking
	FROM	dbo.CustSettingGame WITH(NOLOCK)
	WHERE	custid = @mrecommend 
			AND sporttype = 255 
			AND bettype = 1701
	
	--Customer Info
	SELECT	 c.username
			,c.username2 AS nickname
			,c.firstname
			,c.lastname
			,c.phone
			,c.mobilephone
			,c.fax
			,ISNULL(@DisableUpline,1) 		AS DisableUpline
			,ISNULL(@DisableGoldDeluxe,1)	AS DisableGoldDeluxe	
			,ISNULL(NULLIF(c.site,''), ag.site) AS Site		
	FROM	dbo.Customer c WITH (NOLOCK)
		LEFT JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
	WHERE	c.custID = @CustID   	  
	
	--PT & commission
	SELECT 	
			ISNULL(discount,0) AS v255discount_1701,
			ISNULL(@v255adiscount_1701,0) AS v255discount_1701_max,
			ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,		

			--a2
			apositiontaking AS v255apositiontaking_1701,		
			--m2		
			mpositiontaking AS v255mpositiontaking_1701,
			@max_v255mpositiontaking_1701 AS v255mpositiontaking_1701_max,
			--u2
			autompositiontaking AS auto_v255mpositiontaking_1701,		
			--i2
			isautompositiontaking AS isauto_v255mpositiontaking_1701,		
			--u2_max
			@max_v255mpositiontaking_1701 AS auto_v255mpositiontaking_1701_max,
			
			--n2
			co.minpositiontaking as v255apositiontaking_1701_min	
	FROM	dbo.custsettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.custoverrideGame co WITH(NOLOCK) 
			ON cs.custid = co.custid 
				AND cs.sporttype = co.sporttype 
				AND cs.bettype = co.bettype
	WHERE	cs.custid = @custid 
			AND cs.sporttype = 255 
			AND cs.bettype = 1701
	
	-- bet setting
	EXEC dbo.Acc_CustomerSelStakeLevelGoldDeluxe
		@custid		= @custid
		,@UplineId	= @mrecommend
	
	--Winlimit
	EXEC dbo.Acc_CustomerWinLimitSelEdit @CustId = @CustId
		, @SportType = 255
		, @BetType = 1701

END
GO