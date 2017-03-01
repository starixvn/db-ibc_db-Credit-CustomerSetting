ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterLiveCS]
	@custid		INT,
	@srecommend	INT
AS
/*
	Created: Johnson
	Date: 23Dec2011
	Task: Super edits master's live casino setting
	DB: DBCUST.CustDB
		
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)

	Parameters Explanation
*/
SET NOCOUNT ON

DECLARE	@min_mpositiontaking	SMALLMONEY,
		@max_spositiontaking	SMALLMONEY,
		@max_adiscount			SMALLMONEY,
		@DisableAutoMPT			BIT

--Disable auto master PT
SELECT @DisableAutoMPT = DisableAutoMPT 
FROM CustMaster WITH (NOLOCK) 
WHERE CustID = @custid

SELECT @min_mpositiontaking = minpositiontaking
FROM CustOverrideGame WITH (NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

SELECT @max_spositiontaking = spositiontaking, @max_adiscount = sdiscount
FROM CustSettingGame cs WITH (NOLOCK)
WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101

SELECT ISNULL(@DisableAutoMPT, 0) AS DisableAutoMPT, 
	isautopositiontaking AS isauto_v162spositiontaking_1101, --i3
	autopositiontaking AS auto_v162spostiontaking_1101,--u3
	spositiontaking AS v162spositiontaking_1101,--s3
	mpositiontaking AS v162mpositiontaking_1101,--m3	
	adiscount AS v162discount_1101,--g3
	ISNULL(@max_adiscount, 0) AS v162discount_1101_max,--g3_max
	ISNULL(@max_spositiontaking, 0) AS v162spositiontaking_1101_max,--s4
	ISNULL(@min_mpositiontaking, 0) AS  v162mpositiontaking_1101_min,--n3	
	ISNULL(@max_spositiontaking, 0) AS auto_v162spositiontaking_1101_max--u3_max	
FROM CustsettingGame WITH (NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101



GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterLiveCS] TO [bodbDownlineNetView]
