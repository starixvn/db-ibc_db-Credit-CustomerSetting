/*
	Created: 20200505@Helen
	Task: https://nexdev.net/issues/130032
	DB: DBMSG.bodb_message
*/
USE bodb_message
GO

CREATE TABLE [dbo].[CustArchiveMessage]
(
	StageID INT 
	, GroupLevelName VARCHAR(100)
	, [Content_en] [nvarchar](MAX) NULL
	, [Content_vn] [nvarchar](MAX) NULL
	, [Content_ch] [nvarchar](MAX) NULL
	, [Content_cs] [nvarchar](MAX) NULL
	, [Content_th] [nvarchar](MAX) NULL
	
) ON [PRIMARY]

GO
