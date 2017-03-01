ALTER PROCEDURE dbo.Acc_CustomerSelP2PMember_All
	@custid INT,
	@errcode INT = 0 OUTPUT,
	@errmsg NVARCHAR(200) = '' OUTPUT
AS

/* 
	Created: 20110720@tom
	Task: get basic setting of a member for p2pgamesetting
	Db: db053.bodb02
	Original:


	Revisions:
		- 20120427@Johnson: Calculate today p2p winlost
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
	,@transferp2p MONEY
	,@maxtransferp2p	MONEY
	,@todayWinlostP2P	MONEY
	,@Maxdiscount	DECIMAL(9,8)	
	,@uplineisautoresetp2p	BIT
	,@isautoresetp2p	BIT
	,@disablep2p	BIT
	,@disablefunp2p   BIT
	,@recommend INT
	,@fromdate DATETIME
	,@todate DATETIME;

SELECT @fromdate = CONVERT(VARCHAR(10),GETDATE(),120)
SELECT @todate = @fromdate + '23:59:59'

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
		,todayWinlostP2P	MONEY
		,uplineisautoresetp2p	BIT
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
      ,@transferp2p = cuif.maxtransferp2p
      ,@uplineisautoresetp2p = upline.isautoresetp2p
      ,@isautoresetp2p = cuif.isautoresetp2p
      ,@disablep2p = cuif.disablep2p
      ,@disablefunp2p = cuif.disablefunp2p
      ,@recommend=cuif.recommend
  FROM bodb02.dbo.customer cust WITH (NOLOCK)
	INNER JOIN	bodb02.dbo.custinfo cuif WITH(NOLOCK)
		ON	cust.custid = cuif.custid
	INNER JOIN	bodb02.dbo.custinfo upline WITH(NOLOCK)
		ON	upline.custid = cuif.recommend	
WHERE	cust.custid=@custid --and cuif.roleid=1


IF @roleid=1
BEGIN
	INSERT INTO	 @table_p (firstname,lastname,phone,mobilephone,fax
		  ,email,username,currency,roleid,uplineisautoresetp2p,isautoresetp2p,disablep2p,disablefunp2p )
	VALUES (@firstname,@lastname,@phone,@mobilephone,@fax
		  ,@email,@username,@currency,@roleid,@uplineisautoresetp2p,@isautoresetp2p,@disablep2p,@disablefunp2p)

	SELECT @mintransferp2p=MinCredit , @Maxdiscount = MaxPlayerdiscount FROM P2PDefaultSetting WITH(NOLOCK) WHERE currency=@currency
	SELECT @maxtransferp2p=cuif.maxtransferp2p FROM bodb02.dbo.custinfo cuif WITH(NOLOCK) WHERE cuif.custid=@recommend	
	SELECT @todayWinlostP2P = SUM(winlost - actual_stake) FROM bettrans WITH(NOLOCK) WHERE custid = @custid AND winlostdate BETWEEN @fromdate AND @todate AND bettype = 1000
	
	UPDATE @table_p
	SET		mintransferp2p	=ISNULL(@mintransferp2p,0)
		,maxtransferp2p	=ISNULL(@maxtransferp2p,0)
		,transferp2p = ISNULL(@transferp2p,0)
		,todayWinlostP2P = ISNULL(@todayWinlostP2P,0)

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
		,uplineisautoresetp2p
		,isautoresetp2p
		,todayWinlostP2P
	FROM @table_p

	SELECT bettype
		,StakeLevel1
		,StakeLevel2
		,StakeLevel3
		,StakeLevel4
		,StakeLevel5
		,CASE WHEN	custid =@custid THEN @roleid ELSE 2 END   roleid
	FROM P2PGameSetting	WITH(NOLOCK)
	WHERE	custid=@custid	OR custid=   @recommend
	ORDER BY roleid desc

	SELECT p2pg.groupID
		,tbl.discount		Uplinediscount
		,case when tbl.discount < @Maxdiscount then tbl.discount
			Else @Maxdiscount End Maxdiscount		
		,p2pg.playerdiscount		discount
	FROM P2PGroupComm p2pg WITH(NOLOCK)
		INNER JOIN 
		(
		SELECT groupID	,discount	
		FROM P2PGroupComm p2pg WITH(NOLOCK)
			WHERE custid =@recommend
		 )	 tbl On	 p2pg.groupID = tbl.groupID 
		WHERE custid =@custid			
END
ELSE
	BEGIN
		SELECT @errmsg =  N'Customer is not member level.'
			,@errcode = 500
		RETURN		
	END

GO
GRANT EXECUTE ON dbo.Acc_CustomerSelP2PMember_All TO bodbAdminNet
GO
GRANT EXECUTE ON dbo.Acc_CustomerSelP2PMember_All TO bodbDownlineNet
GO
GRANT VIEW definition ON dbo.Acc_CustomerSelP2PMember_All TO vnteam
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelP2PMember_All TO [bodbExtAccNet]

