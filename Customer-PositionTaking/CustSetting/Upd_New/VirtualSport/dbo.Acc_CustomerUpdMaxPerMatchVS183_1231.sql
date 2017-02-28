CREATE PROCEDURE [Acc_CustomerUpdMaxPerMatchVS183_1231]
	@custid int,
	@MaxPerMatch money,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT	
AS
/*
	Created: Kathy
	Date: 20140402
	Task : Update MaxPerMatch for Virtual Speedway 
	DB: DBTXN/custDB

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
		maxpermatch183 = @MaxPerMatch
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

GRANT EXECUTE ON [Acc_CustomerUpdMaxPerMatchVS183_1231] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [Acc_CustomerUpdMaxPerMatchVS183_1231] TO [bodbDownlineNet] AS [dbo]
GO

GRANT EXECUTE ON [Acc_CustomerUpdMaxPerMatchVS183_1231] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [Acc_CustomerUpdMaxPerMatchVS183_1231] TO [vnteam] AS [dbo]
GO


