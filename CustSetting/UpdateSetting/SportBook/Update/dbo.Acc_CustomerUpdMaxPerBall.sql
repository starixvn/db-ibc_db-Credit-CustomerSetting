ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerBall]
	@custid int,
	@maxperballv161 money = 0,
	@UpdateMultiple bit = 0,	
	@UpdateMinMaxBetv161 bit = 1,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS

/*
Created: 20101026@Lukas
Task : Update Maxperball
DB: DB02.bodb02
Original:

Revisions:
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
Param's Explanation:

*/

update custinfo with (ROWLOCK, UPDLOCK)
set 	
	MaxPerBall161 = case when @UpdateMultiple = 0 or @UpdateMinMaxBetv161 = 1 then @maxperballv161 else MaxPerBall161 end
where custid = @custid 
if (@@error <> 0)
begin
	Select @ErrMsg = case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 100
	return
end

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerBall] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerBall] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerBall] TO [vnteam]