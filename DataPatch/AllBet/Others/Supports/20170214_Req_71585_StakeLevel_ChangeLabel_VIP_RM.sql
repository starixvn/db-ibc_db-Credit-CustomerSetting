/*
	Created: Helen@20170214
	Task: https://nexdev.net/issues/71585
	
	DB: DBCUST/CUSTDB

	-- For references:
		StakeLevelID	GameTypeID	MinLabel	MaxLabel	MinStake		MaxStake		exchangeid	resourceid	GameGroupID
		721				2402		2,000		200,000		2000.00000000	200000.00000000	2			135			0

*/

UPDATE SL
	SET MinLabel='5,000'
	, MaxLabel='100,000'
	, MinStake =  5000 
	, MaxStake = 100000
FROM StakeLevel SL
WHERE ExchangeId = 2 and GameTypeID = 2402 AND StakeLevelID = 721