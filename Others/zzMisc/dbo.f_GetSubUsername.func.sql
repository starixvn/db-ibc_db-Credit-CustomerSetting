ALTER FUNCTION [dbo].[f_GetSubUsername]
(	
	@SubAccID int
)
RETURNS varchar(300)
AS

BEGIN
	Declare @SubAccName varchar(30)
	If @SubAccID > 0
		Select @SubAccName = username From dbo.custSub (nolock) where SubAccID = @SubAccID
	Else
		Set @SubAccName = ''

	Return isnull(@SubAccName,'')
END


GO
GRANT EXECUTE ON [dbo].[f_GetSubUsername] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[f_GetSubUsername] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[f_GetSubUsername] TO [vnteam]