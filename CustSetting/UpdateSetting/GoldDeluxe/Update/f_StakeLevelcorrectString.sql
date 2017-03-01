ALTER FUNCTION dbo.f_StakeLevelcorrectString (@String VARCHAR(100), @ExcludeString VARCHAR(100))
RETURNS @outputTemp TABLE  
 (  
  String VARCHAR(100)
 )  
AS 
/*      
	Created By: Helen
	Created Date: 20151120
	Task: Improve the performance of the setting [Redmine: 45056]      
	DB: DBCUST/custDB      
	
*/	       
BEGIN
		
	DECLARE @StringTemp VARCHAR(100) = ''
			
	IF @String <> '' AND @ExcludeString <> ''
	BEGIN
		
		SET @StringTemp = @String + ','
		
		SELECT @StringTemp = REPLACE(@StringTemp,Val + ',','')
		FROM dbo.strSplit(@ExcludeString,',') 

		IF RIGHT (@StringTemp,1) = ','
			SET @StringTemp =  REVERSE(STUFF(REVERSE(@StringTemp), 1, 1, ''))
		
		INSERT INTO @outputTemp(String)  
		SELECT @StringTemp 	

		RETURN
	END
	ELSE IF @ExcludeString = ''
	BEGIN
		INSERT INTO @outputTemp(String)  
		SELECT @String 
		RETURN
	END

	RETURN	
END

GO

