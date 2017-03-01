ALTER PROCEDURE [dbo].[Acc_CustomerSelMemberSearch_AutoSuspend]
	@Keyword	NVARCHAR(50)	= '%',
	@FirstChar	NVARCHAR(6)		= '%',
	@PageSize	INT				= 50,
	@PageIndex	INT				= 1,
	@TotalPages	INT				= 0 OUTPUT
AS
/*
	Created by: []
	Date: []
	Task: []
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
*/
--@Pattern Explanation:
	--Search keyword: '%keyword%'
	--Frist char:
	--A: 'A%'
	--B: 'B%'
	--0-9: '[0-9]%'
SET NOCOUNT ON
DECLARE @RowCount INT, @RowStart INT, @RowEnd INT
SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 

IF @TotalPages = 0
BEGIN
	SELECT @TotalPages = count(1)/@PageSize + (count(1)%@PageSize)%2 
	FROM custinfo ci WITH (NOLOCK) 
		inner join customer c WITH (NOLOCK) on c.custid = ci.custid
	WHERE c.roleid = 1
		and c.username like @Keyword and c.username like @FirstChar
END

SELECT * FROM 
(
	SELECT 
		c.username, 
		c.CustID, 
		autosuspend,
		c.firstname, 
		c.lastname,
		ROW_NUMBER() OVER (ORDER by c.username ) as RowNumber
	FROM custinfo ci WITH (NOLOCK) 
		inner join customer c WITH (NOLOCK) on c.custid = ci.custid
	WHERE c.roleid = 1
		and c.username like @Keyword and c.username like @FirstChar
) a
WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMemberSearch_AutoSuspend] TO [bodbAdminNet]