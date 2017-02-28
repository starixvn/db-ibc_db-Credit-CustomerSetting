 ALTER PROCEDURE dbo.Acc_CheckAllowedShow
	@CustID int,
	@AllowedFi bit=1 output,
	--@AllowedHR bit=0 output,
	@AllowedCS bit=0 output,
	@AllowedBI bit=0 output
AS
/*
Created by: 20090525@Simon
Task: Check the showed types. (Finance / Horse Racing / Casino)
DB: DB052.BODB02 
Revisions:
	- 20090908@Shifu: Check Allow HR
	- 20100930@Ethan: Check Allow BI
	- 20110614@Johnson: not check currency for HR
*/

SET NOCOUNT ON

Declare @mCurrencyID int, @RoleID int, @SyncCasino bit, @SyncBingo bit, @DisableBingo bit  
Declare @srecommend int, @mrecommend int, @recommend int

Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend
from custinfo with (nolock) where CustID=@CustID

-- For Finance
set @AllowedFi=1
	
If @RoleID=4
Begin	
	set @AllowedCS=1
	set @AllowedBI=1
End
Else 
Begin 
	-- Check if Replicate run slowly.
	If (@RoleID is null) 
	Begin 
		--set @AllowedHR=0
		set @AllowedCS=0
		set @AllowedBI=0
		return
	End
	-- For Casino (Check Upline allowed Casino)
	if @RoleID=3
		Select @SyncCasino=SyncCasino, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo from custinfo with (nolock) where CustID=@srecommend	
	Else if @RoleID=2
		Select @SyncCasino=SyncCasino, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo  from custinfo with (nolock) where CustID=@mrecommend	
	Else if @RoleID=1
		Select @SyncCasino=SyncCasino, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo from custinfo with (nolock) where CustID=@recommend		
	
	-- For Casino
	if @SyncCasino!=1
		set @AllowedCS=0
	else
		set @AllowedCS=1
		
	-- For Bingo
	if @SyncBingo!=1 
		set @AllowedBI=0
	else
		set @AllowedBI=1
			
End

-- For Horse Racing	
--Exec Acc_CheckHRAllowedCurrency @CurrencyID=@mCurrencyID, @Allowed= @AllowedHR OUTPUT


GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].Acc_CheckAllowedShow TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CheckAllowedShow] TO vnteam