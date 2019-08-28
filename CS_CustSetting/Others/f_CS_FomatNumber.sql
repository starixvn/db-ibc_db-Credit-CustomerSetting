/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,Dot_Member" viewers="" isFunction="1"></info>*/

ALTER FUNCTION f_CS_FomatNumber(@str VARCHAR(50)) 
RETURNS VARCHAR(50) 
AS
/*
    Created: Elodie
    Date: 20181212
    Task: Format number to write log (CS Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]
    Example:
		SELECT dbo.f_CS_FomatNumber ('0.00')
*/
BEGIN
	DECLARE @iDot TINYINT, @iCut TINYINT, @LenStr TINYINT

	SELECT @iDot = CHARINDEX('.',@str)
	SELECT @LenStr = LEN(@str)

	IF @iDot > 0
	BEGIN		
		SELECT @iCut = @LenStr - PATINDEX('%[123456789]%', REVERSE(@str)) + 1
		IF @iCut < @iDot OR @iCut > @LenStr
		BEGIN
			SELECT @str = SUBSTRING(@str,1,@iDot - 1)
		END
		ELSE
		BEGIN
			SELECT @str = SUBSTRING(@str,1,@iCut)
		END
	END	

	RETURN @str
END

