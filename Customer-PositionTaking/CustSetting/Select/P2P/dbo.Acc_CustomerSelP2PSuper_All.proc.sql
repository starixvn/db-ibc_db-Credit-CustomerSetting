ALTER PROCEDURE dbo.Acc_CustomerSelP2PSuper_All
	@custid INT,
	@errcode INT = 0 OUTPUT,
	@errmsg NVARCHAR(200) = '' OUTPUT
AS
/*
created: 20110720@tom
task: get basic setting of a super for p2pgamesetting
db: db053.bodb02
original:


revisions:
*/

SET NOCOUNT ON
DECLARE	 @firstname NVARCHAR(50)
	,@lastname	NVARCHAR(50)
	,@phone	NVARCHAR(50)
	,@mobilephone   NVARCHAR(50)
	,@fax	NVARCHAR(50)
	,@email	NVARCHAR(50)
	,@username VARCHAR(50)
	,@currency	TINYINT
	,@roleid	   TINYINT
	,@mintransferp2p MONEY
	,@maxtransferp2p	MONEY
	,@isautoresetp2p	BIT
	,@disablep2p	BIT
	,@disablefunp2p   BIT
	,@maxsdiscount DECIMAL(9,8)

DECLARE @table_p TABLE(
		firstname NVARCHAR(50)
		,lastname	NVARCHAR(50)
		,phone	NVARCHAR(50)
		,mobilephone   NVARCHAR(50)
		,fax	NVARCHAR(50)
		,email	NVARCHAR(50)
		,username VARCHAR(50)
		,currency	TINYINT
		,roleid	   TINYINT
		,mintransferp2p	MONEY   DEFAULT 0
		,transferp2p	MONEY  DEFAULT 0
		,maxtransferp2p	MONEY		  DEFAULT 0
		,isautoresetp2p	BIT
		,disablep2p	BIT
		,disablefunp2p   BIT
	)

SELECT @firstname =cust.firstname
      ,@lastname = cust.lastname
      ,@phone = cust.phone
      ,@mobilephone = cust.mobilephone
      ,@fax = cust.fax
      ,@email = cust.email
      ,@username = cuif.username
      ,@currency = cuif.currency
      ,@roleid= cuif.roleid
      ,@maxtransferp2p = cuif.maxtransferp2p
      ,@isautoresetp2p = cuif.isautoresetp2p
      ,@disablep2p = cuif.disablep2p
      ,@disablefunp2p = cuif.disablefunp2p
  FROM bodb02.dbo.customer cust WITH (NOLOCK)
	INNER JOIN	bodb02.dbo.custinfo cuif WITH(NOLOCK)
		ON	cust.custid = cuif.custid
WHERE	cust.custid=@custid --and cuif.roleid=4

IF @roleid=4
BEGIN
	INSERT INTO	 @table_p (firstname,lastname,phone,mobilephone,fax
		  ,email,username,currency,roleid,transferp2p,isautoresetp2p,disablep2p,disablefunp2p )
	VALUES (@firstname,@lastname,@phone,@mobilephone,@fax
		  ,@email,@username,@currency,@roleid,@maxtransferp2p,@isautoresetp2p,@disablep2p,@disablefunp2p)

	SELECT @Maxsdiscount=Maxsdiscount,@mintransferp2p=MinCredit,@maxtransferp2p=MaxCredit FROM P2PDefaultSetting WITH(NOLOCK) WHERE currency=@currency

	UPDATE @table_p
	SET		mintransferp2p	=ISNULL(@mintransferp2p,0)
		,maxtransferp2p	=ISNULL(@maxtransferp2p,0)

	SELECT firstname
		,lastname
		,phone
		,mobilephone
		,fax
		,email
		,username
		,currency
		,roleid
		,mintransferp2p
		,transferp2p
		,maxtransferp2p
		,1 uplineisautoresetp2p
		,isautoresetp2p
	FROM @table_p 

	SELECT bettype
		,StakeLevel1
		,StakeLevel2
		,StakeLevel3
		,StakeLevel4
		,StakeLevel5
		,4 roleid
	FROM P2PGameSetting	WITH(NOLOCK)
	WHERE	custid=@custid
	ORDER BY roleid desc

	SELECT groupID
		,@Maxsdiscount	Uplinediscount
		,@Maxsdiscount	Maxdiscount
		,sdiscount	discount
	FROM P2PGroupComm WITH(NOLOCK)
		WHERE custid =@custid
END
ELSE
	BEGIN
		SELECT @errmsg =  N'Customer is not supper level.'
			,@errcode = 500
		RETURN		
	END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PSuper_All] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PSuper_All] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PSuper_All] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelP2PSuper_All] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelP2PSuper_All] TO [vnteam]