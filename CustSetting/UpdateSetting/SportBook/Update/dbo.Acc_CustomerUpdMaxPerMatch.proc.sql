ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatch]
	@custid int,
	@maxpermatch money,
	@maxpermatchv2 money,
	@maxpermatchv3 money,
	@maxpermatchv5 money,
	@maxpermatchv8 money,
	@maxpermatchv10 money,
	@maxpermatchv11 money,
	@maxpermatchv99 money,
	@maxpermatchv99MP money,
	@maxpermatchv1MP money,
	@maxpermatchv154 money,
	@maxpermatchv161 money,
	@UpdateMultiple bit = 0,	
	@UpdateMinMaxBet bit = 1,
	@UpdateMinMaxBetv2 bit = 1,
	@UpdateMinMaxBetv3 bit = 1,
	@UpdateMinMaxBetv5 bit = 1,
	@UpdateMinMaxBetv8 bit = 1,
	@UpdateMinMaxBetv10 bit = 1,
	@UpdateMinMaxBetv11 bit = 1,
	@UpdateMinMaxBetv99 bit = 1,
	@UpdateMinMaxBetv99MP bit = 1,
	@UpdateMinMaxBetv1MP bit = 1,
	@UpdateMinMaxBetv154 bit = 1,	
	@UpdateMinMaxBetv161 bit = 1,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--Update Maxpermatch in db
/*
Created: 20081118@Phuc
Task : Update Maxpermatch
DB: DBTXN/bodb02
Original:

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20100830@Henry: Amend to update for Number Game + Mix Parlay Mixed Sports
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
    - 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

update custinfo with (ROWLOCK, UPDLOCK)
set 	
	MaxPerMatch=case when @UpdateMultiple = 0 or @UpdateMinMaxBet=1 then @MaxPerMatch else MaxPerMatch end,
	MaxPerMatch2=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv2=1 then @MaxPerMatchv2 else MaxPerMatch2 end,
	MaxPerMatch3=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv3=1 then @MaxPerMatchv3 else MaxPerMatch3 end,
	MaxPerMatch5=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv5=1 then @MaxPerMatchv5 else MaxPerMatch5 end,
	MaxPerMatch8=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv8=1 then @MaxPerMatchv8 else MaxPerMatch8 end,
	MaxPerMatch10=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv10=1 then @MaxPerMatchv10 else MaxPerMatch10 end,
	MaxPerMatch11=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv11=1 then @MaxPerMatchv11 else MaxPerMatch11 end,
	MaxPerMatch99=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv99=1 then @MaxPerMatchv99 else MaxPerMatch99 end,
	MaxPerMatch99MP=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv99MP=1 then @MaxPerMatchv99MP else MaxPerMatch99MP end,
	MaxPerMatch1MP=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv1MP=1 then @MaxPerMatchv1MP else MaxPerMatch1MP end,
	MaxPerMatch154=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv154=1 then @MaxPerMatchv154 else MaxPerMatch154 end,
	MaxPerMatch161=case when @UpdateMultiple = 0 or @UpdateMinMaxBetv161=1 then @MaxPerMatchv161 else MaxPerMatch161 end
where custid = @custid 
if (@@error <> 0)
begin
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115
	return
end


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatch] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatch] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatch] TO [vnteam] AS [dbo]