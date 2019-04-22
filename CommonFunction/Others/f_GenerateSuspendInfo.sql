/*<info serverAlias="DBCUST-custDB,DB042-bodb02,Db043-bodb02,DB044-bodb02,DB04Admin1-bodb02,DB04Admin2-bodb02,DB05-bodb02,DB05BK1-bodb02,DBEXT-bodb02,DBLICAPI-bodb02,DBLICAPI02-bodb02,DBACC-bodb02" executers="" viewers="" isFunction="1" isNested="0"></info>*/

ALTER FUNCTION dbo.f_GenerateSuspendInfo(@bitOrder TINYINT,@suspend BIT,@SuspendInfo TINYINT)
RETURNS TABLE
AS 
/*
	Created by:Johnson
	Date:2019-04-08
	Task: get downlines suspend info status
	DB: DBCUST/CustDB
	
	Revisions:
		- 20190408@Johnson: initial sp [redmine: #105587]
	Parameter's Explanation:
*/
RETURN(SELECT CASE WHEN @suspend = 1 THEN @SuspendInfo|power(2,@bitOrder-1)
			ELSE @SuspendInfo&(CASE @bitOrder WHEN 4 THEN 7 WHEN 3 THEN 11 WHEN 2 THEN 13 WHEN 1 THEN 14 END) END
		as suspendInfo		
	)
GO
