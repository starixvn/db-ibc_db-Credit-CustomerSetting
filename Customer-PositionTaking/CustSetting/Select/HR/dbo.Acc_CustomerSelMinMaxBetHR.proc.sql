ALTER PROCEDURE [dbo].[Acc_CustomerSelMinMaxBetHR]
	@CustID int
AS

--=====================================================
--Select minbet, maxbet, max per match for Horseracing
--Developer: Vinh Truong
--Modify from:
--Date: 2008-10-21
--=====================================================

SET NOCOUNT ON

Declare 
	@uplineID int,
	@roleid int,
	
	@minbet money,
	@maxbet money,
	@MaxPerMatch money,

	@MinBet_Min money,
	@MaxBet_Max money,
	@MaxPerMatch_Max money,
	@MaxPerMatch_Min money
	
select @roleid = roleid
from customer with (nolock)
where custid = @custid
select @roleid = isnull(@roleid, 0)

select @uplineID = case @roleid when 1 then recommend when 2 then mrecommend when 3 then srecommend else 0 end
from customer with (nolock) where custid = @custid


if @roleid in (1,2,3)
BEGIN

	Select  
	 @MinBet_Min = Max(case when MinBet = 0 then NULL else MinBet end),   
	 @MaxBet_Max = Min(case when MaxBet = 0 then NULL else MaxBet end)  
	from   
	 custsetting as cs WITH (NOLOCK)  
	 INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)  
	 and cs.bettype = 31 and cs.sporttype=151  
	where ci.custid = @UplineID  
	  
	  
	Select @MaxPerMatch_Min = 0,  @MaxperMatch_Max = Min(case when cs.MaxPerMatch151 = 0 then NULL else cs.MaxPerMatch151 end)  
	from   
	 custinfo as cs WITH (NOLOCK)   
	 INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)  
	where ci.custid = @UplineID  

END

if @roleid = 4
BEGIN
	Select 
		@MinBet_Min = NULL,
		@MaxBet_Max = NULL,
		@MaxPerMatch_Min = NULL,
		@MaxperMatch_Max = NULL
END


SELECT
	@minbet = cs.minbet, 
	@maxbet = cs.maxbet, 
	@maxpermatch = ci.maxpermatch151
FROM 
	custinfo as ci with (NOLOCK)
	INNER JOIN custsetting as cs with (NOLOCK) on ci.custid  = cs.custid
WHERE 
	ci.custid = @custId AND cs.bettype = 31 AND cs.sporttype = 151
	
	
SELECT
	@minbet AS minbet, 
	@maxbet AS maxbet, 
	@maxpermatch AS maxpermatch,
	@MinBet_Min AS MinBet_Max,
	@MaxBet_Max AS MaxBet_Min,
	@MaxPerMatch_Min AS MaxPerMatch_Min,
	@MaxperMatch_Max AS MaxperMatch_Max
	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMinMaxBetHR] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMinMaxBetHR] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMinMaxBetHR] TO [bodbDownlineNetView]
GO