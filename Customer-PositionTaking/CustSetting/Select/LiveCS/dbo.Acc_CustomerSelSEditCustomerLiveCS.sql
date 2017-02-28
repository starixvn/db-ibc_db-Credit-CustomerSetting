ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerLiveCS]
	@custid		INT
AS
	/*
		Created:Johnson
		Date: 23Dec2011
		Task: Super edits live casino settings on member
		DB: DBCUST.CustDB
		
		Revisions:
			- 20150515@Johnson: fix s1_max = Max(n4-(m1+a1), s4 - m3) [Redmined: #35758]
			- 20150617@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
		Parameters Explanation:
	*/
SET NOCOUNT ON

DECLARE 	
	@v162spositiontaking_1101		SMALLMONEY,--s4
	@v162spositiontaking_1101_min	SMALLMONEY,--n4
	@v162mpositiontaking_1101		SMALLMONEY,--m3
	@isauto_v162spositiontaking_1101 BIT,--i3
	@srecommend INT, 
	@mrecommend	INT

SELECT @srecommend = srecommend, @mrecommend = mrecommend 
FROM CustInfo WITH(NOLOCK)
WHERE custid = @custid

--s4
SELECT @v162spositiontaking_1101 = spositiontaking
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101

--n4
SELECT @v162spositiontaking_1101_min = minpositiontaking
FROM CustOverrideGame WITH(NOLOCK)	
WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101

--i3,m3
SELECT @v162mpositiontaking_1101 = mpositiontaking, @isauto_v162spositiontaking_1101 = isautopositiontaking
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101 

SELECT spositiontaking as v162spositiontaking_1101,
	mpositiontaking as v162mpositiontaking_1101,
	apositiontaking as v162apositiontaking_1101,
	autopositiontaking as auto_v162spositiontaking_1101_mem,	
	isautopositiontaking as isauto_v162spositiontaking_1101_mem,
	ISNULL(@isauto_v162spositiontaking_1101,0) as isauto_v162spositiontaking_1101, -- i3
	ISNULL(@v162spositiontaking_1101,0) as auto_v162spositiontaking_1101_max,
	--s1_max= Max(n4-(m1+a1), s4 - m3)
	CASE WHEN @v162spositiontaking_1101_min - (mpositiontaking+apositiontaking) > ISNULL(@v162spositiontaking_1101,0) - ISNULL(@v162mpositiontaking_1101,0)
			THEN @v162spositiontaking_1101_min - (mpositiontaking+apositiontaking) 
			ELSE ISNULL(@v162spositiontaking_1101,0) - ISNULL(@v162mpositiontaking_1101,0) END as v162spositiontaking_1101_max,
	-- s1_min 
	CASE WHEN ISNULL(@v162spositiontaking_1101_min,0) - (mpositiontaking + apositiontaking) > 0 THEN ISNULL(@v162spositiontaking_1101_min,0) - (mpositiontaking + apositiontaking) ELSE 0 END v162spositiontaking_1101_min	
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSEditCustomerLiveCS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerLiveCS] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerLiveCS] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerLiveCS] TO [bodbDownlineNetView]