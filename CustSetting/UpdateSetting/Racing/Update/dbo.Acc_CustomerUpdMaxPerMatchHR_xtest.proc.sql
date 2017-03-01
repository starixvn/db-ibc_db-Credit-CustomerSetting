ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatchHR]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 
Task : Update MaxPerMatch HR
DB: DB02.bodb02
Original: 

Revisions:
	- 20100516@Phuc: copy maxpermatch for OpenTote(from SA).
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

	SET NOCOUNT ON
	update custinfo with (ROWLOCK, UPDLOCK)
	set 	
		MaxPerMatch151= @MaxPerMatch,
		MaxPerMatch151_OT = @MaxPerMatch 
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchHR] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchHR] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatchHR] TO [vnteam]