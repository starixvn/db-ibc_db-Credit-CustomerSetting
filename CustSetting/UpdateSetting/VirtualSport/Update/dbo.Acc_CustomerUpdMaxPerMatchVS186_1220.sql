CREATE PROCEDURE [dbo].[Acc_CustomerUpdMaxPerMatchVS186_1220]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT	
AS
/*
Created: Scott
Date: 20121130
Task : Update MaxPerMatch Virtual Tennis
DB: DBTRANS.bodb02
Original: [Acc_CustomerUpdMaxPerMatchVS180_1201]

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
		maxpermatch186 = @MaxPerMatch
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
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS186_1220] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS186_1220] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaxPerMatchVS186_1220] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaxPerMatchVS186_1220] TO [bodbExtAccNet]