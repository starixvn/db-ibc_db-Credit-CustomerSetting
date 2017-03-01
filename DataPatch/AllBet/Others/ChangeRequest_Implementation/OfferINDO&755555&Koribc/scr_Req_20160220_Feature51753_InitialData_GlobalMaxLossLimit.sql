/*
	Created: Helen
	Task: set global setting of Max Loss Limit with value
	DB: DBCUST/CustDB
	Date: 20160820
	
	https://docs.google.com/spreadsheets/d/183ftwazU-wB0YHVlMOmL7_gyjWQPhaj6bMgYOtMKMrk/edit#gid=672993935
	
	Sheet: SMA Loss Limit Initial Setting, get from column "Min of Loss Limit (round number)" & "Max of Loss limit (round number)"
*/ 

GO
/*
SELECT TOP 10 * FROM dbo.LossLimit_GlobalSetting (NOLOCK)
WHERE ProductId = 21
*/

DELETE FROM LossLimit_GlobalSetting WHERE ProductId = 21
GO

INSERT INTO LossLimit_GlobalSetting (ProductId, ExchangeId, MinLossLimit,DefaultLossLimit)
VALUES
(21,2,500,500000),
(21,35,100,122400),
(21,3,100,122400),
(21,64,100,122400),
(21,40,100,122400),
(21,17,100,122400),
(21,16,100,122400),
(21,6,100,111500),
(21,5,900,949700),
(21,67,900,949700),
(21,13,800,818400),
(21,43,4200,4278600),
(21,47,1600,1612900),
(21,33,1600,1612900),
(21,34,1600,1612900),
(21,15,1600,1612900),
(21,22,1600,1612900),
(21,45,138500,138504100),
(21,70,100,142800),
(21,69,100,142800),
(21,1,100,166600),
(21,12,0,93200),
(21,4,4200,4278600),
(21,51,2700,2777700),
(21,61,8200,8233100),
(21,20,100,122400)

