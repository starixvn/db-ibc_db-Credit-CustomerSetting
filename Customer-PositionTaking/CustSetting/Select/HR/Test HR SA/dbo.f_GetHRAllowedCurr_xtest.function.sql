 CREATE FUNCTION [dbo].[f_GetHRAllowedCurr_xtest]
()RETURNS @res table (exchangeID  int PRIMARY KEY, currency  varchar(50))
AS

/*
Created: 
Task : Get Horse Racing information
DB: DBTRANS, DB05/2, DB06

Revisions:
	- 20100528@Phuc: Removed GBP currency.
	- 20110609@Johnson: get all currency for HR SA Tote
Param's Explanation:
*/

BEGIN
	Insert Into @res(exchangeID, currency)
	Select distinct ExchangeID, Currency 
	From Exchange (nolock) --where currency in (Select val From dbo.strsplit('US$,EURO,RM,SD$,RMB,HK$,Yen,NTD,$US,Y$US,IRR,UUS,TB,THB,IDD,IDR,IN,IND,DDD', ','))
	Return 
END

