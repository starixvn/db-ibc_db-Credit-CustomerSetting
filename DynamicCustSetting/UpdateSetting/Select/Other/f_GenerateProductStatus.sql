SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER FUNCTION	dbo.f_GenerateProductStatus (
					@bitmap				BINARY(32)
				,	@bitmapOrder		TINYINT
				,	@newStatusValue		BIT
				)  
 RETURNS BINARY(32)
 AS  
/*  
	Created:	Viet @ 7.OCT.2015  
	DB:			DBCUST/CustDB  
  
	Revision:
		- 20160408@Billy:	Fix arithmetic overflow error when update value from 1 to 0

	Param's Explanation:
*/  
BEGIN  
	DECLARE	@byte_pos		TINYINT = 1 + ((@bitmapOrder - 1) / 8)
	DECLARE @col_val		TINYINT = POWER(2, (@bitmapOrder - 1) % 8)
	 
	DECLARE	@sub_bitmap		BINARY(1) = SUBSTRING(@bitmap, @byte_pos, 1)
	DECLARE @oldStatusValue	TINYINT = CASE @sub_bitmap & @col_val WHEN 0 THEN 0 ELSE 1 END  
	 
	IF	@oldStatusValue = @newStatusValue
		RETURN	@bitmap  
	 
	SET	@sub_bitmap += @col_val * (CAST(@newStatusValue AS SMALLINT) - @oldStatusValue)  
	 
	RETURN CONVERT(BINARY(32), STUFF(@bitmap, @byte_pos, 1, @sub_bitmap))
END
GO