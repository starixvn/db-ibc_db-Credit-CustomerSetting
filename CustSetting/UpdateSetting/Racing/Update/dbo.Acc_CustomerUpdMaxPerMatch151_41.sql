  
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatch151_41]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
	Created: 
	Task : Update master's minbet, maxbet, max per match for Horseracing
	DB: DBTRANS.bodb02
	Revision:
		- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language

*/
	SET NOCOUNT ON 
		
	update custinfo with (ROWLOCK, UPDLOCK)
	set 	
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatch151_41] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatch151_41] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatch151_41] TO [vnteam]