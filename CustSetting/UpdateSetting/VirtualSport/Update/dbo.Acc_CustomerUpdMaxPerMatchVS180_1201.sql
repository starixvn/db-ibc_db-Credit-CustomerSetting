ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatchVS180_1201]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT	
AS
/*
Created: 
Task : Update MaxPerMatch Virtual Soccer
DB: DBTRANS.bodb02
Original: 

Revisions:
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
	SET NOCOUNT ON
	
	update custinfo with (ROWLOCK, UPDLOCK)
	set 	
		maxpermatch180 = @MaxPerMatch
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS180_1201] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS180_1201] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatchVS180_1201] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS180_1201] TO [bodbExtAccNet]