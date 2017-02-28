  ALTER PROCEDURE [dbo].[Acc_CustomerSelMinMax]
	@custid int,	
	@MinBet money output, @MaxBet money output, @MaxPerMatch money output,
	@MinBetv2 money output, @MaxBetv2 money output, @MaxPerMatchv2 money output,
	@MinBetv3 money output, @MaxBetv3 money output, @MaxPerMatchv3 money output,
	@MinBetv5 money output, @MaxBetv5 money output, @MaxPerMatchv5 money output,
	@MinBetv8 money output, @MaxBetv8 money output, @MaxPerMatchv8 money output,
	@MinBetv10 money output, @MaxBetv10 money output, @MaxPerMatchv10 money output,
	@MinBetv11 money output, @MaxBetv11 money output, @MaxPerMatchv11 money output,
	@MinBetv99 money output, @MaxBetv99 money output, @MaxPerMatchv99 money output,
	@MinBetv99MP money output, @MaxBetv99MP money output, @MaxPerMatchv99MP money output,
	@MinBetv161 money output, @MaxBetv161 money output, @MaxPerMatchv161 money output, @MaxPerBallv161 money output
AS
/*
Created: 20110427@Simon
Task : Select customer minbet, maxbet, maxpermatch. 
DB: DB05.bodb02
Original:

Revisions:
    
Param's Explanation:
• @custid: custid that need to be viewed.   
*/

SET NOCOUNT ON

Select
	@MinBet = case when bettype = 1 and sporttype=1 then MinBet end, 
	@MaxBet = case when bettype = 1 and sporttype=1 then MaxBet end,
	@MinBetv2 = case when bettype = 1 and sporttype=2 then MinBet end, 
	@MaxBetv2 = case when bettype = 1 and sporttype=2 then MaxBet end,
	@MinBetv3 = case when bettype = 1 and sporttype=3 then MinBet end, 
	@MaxBetv3 = case when bettype = 1 and sporttype=3 then MaxBet end,
	@MinBetv5 = case when bettype = 1 and sporttype=5 then MinBet end, 
	@MaxBetv5 = case when bettype = 1 and sporttype=5 then MaxBet end,
	@MinBetv8 = case when bettype = 1 and sporttype=8 then MinBet end, 
	@MaxBetv8 = case when bettype = 1 and sporttype=8 then MaxBet end,
	@MinBetv10 = case when bettype = 1 and sporttype=10 then MinBet end, 
	@MaxBetv10 = case when bettype = 1 and sporttype=10 then MaxBet end,
	@MinBetv11 = case when bettype = 1 and sporttype=11 then MinBet end, 
	@MaxBetv11 = case when bettype = 1 and sporttype=11 then MaxBet end,
	@MinBetv99 = case when bettype = 1 and sporttype=99 then MinBet end, 
	@MaxBetv99 = case when bettype = 1 and sporttype=99 then MaxBet end,
	@MinBetv99MP = case when bettype = 9 and sporttype=99 then MinBet end, 
	@MaxBetv99MP = case when bettype = 9 and sporttype=99 then MaxBet end,
	@MinBetv161 = case when bettype = 81 and sporttype=161 then MinBet end, 
	@MaxBetv161 = case when bettype = 81 and sporttype=161 then MaxBet end
from custsetting WITH (NOLOCK)
where custid = @CustID

--MAX PER MATCH
Select 
	@MaxperMatch = MaxPerMatch, 
	@MaxPerMatchv2 = MaxPerMatch2, 
	@MaxPerMatchv3 = MaxPerMatch3, 
	@MaxPerMatchv5 = MaxPerMatch5, 
	@MaxPerMatchv8 = MaxPerMatch8, 
	@MaxPerMatchv10 = MaxPerMatch10, 
	@MaxPerMatchv11 = MaxPerMatch11, 
	@MaxPerMatchv99 = MaxPerMatch99,
	@MaxPerMatchv99MP = MaxPerMatch99MP,
	@MaxPerMatchv161 = MaxPerMatch161,
	@MaxPerBallv161 = MaxPerBall161
from custinfo WITH (NOLOCK) 
where custid = @CustID


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMinMax] TO vnteam 