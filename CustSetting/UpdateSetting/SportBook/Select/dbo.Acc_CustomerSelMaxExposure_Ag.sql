/*<info serverAlias="DBACC-bodb02,DBTXN-bodb02" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelMaxExposure_Ag]
	@custid int,
	@sporttype SMALLINT,
	@MaxExposure money OUTPUT
AS
/*
Created: 
Task : Max Exposure by Sporttype [Used for checking Update Credit]
DB: DBTXN/bodb02
Original:

Revisions:
	- 20110520@Amy: Re-arrange bettype
	- 20170803@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.		
*/
SET NOCOUNT ON
Select top 1 @MaxExposure = sum(actual_stake) 
from 
	bettrans as b with (NOLOCK) 
	inner join match as m with (NOLOCK) on b.matchid = m.matchid
where b.custid = @custid and b.bettype<=19000 and b.ruben = 0 and m.sporttype = @sporttype
group by m.homeid, m.awayid, m.leagueid, m.eventdate
order by sum(actual_stake) desc

select @MaxExposure = isnull(@MaxExposure, 0)


GO
