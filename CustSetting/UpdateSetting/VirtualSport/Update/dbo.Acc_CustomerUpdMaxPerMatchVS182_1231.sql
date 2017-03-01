ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatchVS182_1231]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT	
AS
/*
	Created: Elodie
	Date: 20131121
	Task : Update MaxPerMatch for Virtual greyhounds
	DB: DBTXN/bodb02

	Revisions:

	Param's Explanation:
	• @ErrCode:
		= 0: Update successfully.
		> 0: Specific Error.  
	• @ErrMsg: Error description.
*/
	SET NOCOUNT ON
	
	update custinfo with (ROWLOCK, UPDLOCK)
	set 	
		maxpermatch182 = @MaxPerMatch
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS182_1231] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS182_1231] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatchVS182_1231] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS182_1231] TO [bodbExtAccNet]