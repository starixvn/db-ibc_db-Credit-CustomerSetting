ALTER PROCEDURE [dbo].[Acc_OperatorSel] 
	@Keyword nvarchar(50)='%',
	@FirstChar nvarchar(6)='%',
	@PageSize int=50,
	@PageIndex int=1,
	@TotalPages int=0 output
AS
/*
Created:
Task : Get User Information
DB: DBCUST.CustDB
Original: Add Operator

Revisions:
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
*/
--Original: AddOperator
--@update2008/01/14 search username

--Pattern Explanation:
--Search keyword: '%keyword%'
--First char
--A: 'A%'
--B: 'B%'
--0-9: '[0-9]%'

SET NOCOUNT ON
DECLARE @RowCount int, @RowStart int, @RowEnd int
SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 

IF @TotalPages = 0
BEGIN
	SELECT 
		@TotalPages = count(1),@TotalPages=@TotalPages/@PageSize + case when @TotalPages%@PageSize > 0 then 1 else 0 end  
	FROM 
		customer as C with (NOLOCK)
		inner join customer as Cr with (NOLOCK) on Cr.custid=C.creator
	WHERE 
		C.roleid in (5,6,7,8,9,10)
		and C.username not in ('steven')
		and c.username like @Keyword and c.username like @FirstChar
END
select * from 
(
select
	C.CustID, C.UserName, C.FirstName, C.LastName, C.Phone, C.MobilePhone, C.Email, C.RoleID, C.Creatdate, Cr.username as Creator,
	ROW_NUMBER() OVER (ORDER by c.username ) as RowNumber 
from
	customer as C with (NOLOCK)
	inner join customer as Cr with (NOLOCK) on Cr.custid=C.creator
where 
	C.roleid in (5,6,7,8,9,10)
	and C.username not in ('steven')
	and c.username like @Keyword and c.username like @FirstChar
) a
where a.rownumber between @rowstart and @rowend


GO
GRANT EXECUTE ON [dbo].[Acc_OperatorSel] TO [bodbAdminNet]