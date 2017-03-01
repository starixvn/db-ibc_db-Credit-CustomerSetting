  
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatch153_51]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
Created: 20110113@Henry
Task : Update maxpermatch of a customer
DB: DBTRANS.bodb02

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
		MaxPerMatch153_AU = @MaxPerMatch
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatch153_51] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatch153_51] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatch153_51] TO [vnteam]