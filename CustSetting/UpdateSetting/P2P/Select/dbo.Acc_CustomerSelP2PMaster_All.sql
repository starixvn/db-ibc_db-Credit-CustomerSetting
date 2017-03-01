ALTER PROCEDURE dbo.Acc_CustomerSelP2PMaster_All
	@custid INT,
	@errcode INT = 0 OUTPUT,
	@errmsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20110720@tom
Task: get basic setting of a master for p2pgamesetting
Db: db053.bodb02
Original:


Revisions:
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
	,@Maxdiscount	DECIMAL(9,8)
	,@uplineisautoresetp2p	BIT	
	,@isautoresetp2p	BIT
	,@disablep2p	BIT
	,@disablefunp2p   BIT
	,@srecommend INT

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
		,maxtransferp2p	money		  default 0
        ,uplineisautoresetp2p	BIT		
		,isautoresetp2p	bit
		,disablep2p	bit
		,disablefunp2p   bit
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
      ,@uplineisautoresetp2p = upline.isautoresetp2p
      ,@isautoresetp2p = cuif.isautoresetp2p
      ,@disablep2p = cuif.disablep2p
      ,@disablefunp2p = cuif.disablefunp2p
      ,@srecommend=cuif.srecommend
  FROM bodb02.dbo.customer cust WITH (NOLOCK)
	INNER JOIN	bodb02.dbo.custinfo cuif WITH(NOLOCK)
		ON	cust.custid = cuif.custid
	INNER JOIN	bodb02.dbo.custinfo upline WITH(NOLOCK)
		ON	upline.custid = cuif.srecommend			
WHERE	cust.custid=@custid --and cuif.roleid=3

IF @roleid=3
BEGIN
	INSERT INTO	 @table_p (firstname,lastname,phone,mobilephone,fax
		  ,email,username,currency,roleid,transferp2p,uplineisautoresetp2p,isautoresetp2p,disablep2p,disablefunp2p )
	VALUES (@firstname,@lastname,@phone,@mobilephone,@fax
		  ,@email,@username,@currency,@roleid,@maxtransferp2p,@uplineisautoresetp2p,@isautoresetp2p,@disablep2p,@disablefunp2p)

	SELECT @mintransferp2p=MinCredit , @Maxdiscount = MaxAdiscount FROM P2PDefaultSetting WITH(NOLOCK) WHERE currency=@currency
	SELECT @maxtransferp2p=cuif.maxtransferp2p FROM bodb02.dbo.custinfo cuif WITH(NOLOCK) WHERE cuif.custid=@srecommend	


	UPDATE @table_p
	SET	mintransferp2p	=ISNULL(@mintransferp2p,0)
		,MaxTransferP2P	=ISNULL(@maxtransferp2p,0)

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
		,MaxTransferP2P
		,uplineisautoresetp2p		
		,IsAutoResetP2P
	FROM @table_p

	SELECT bettype
		,StakeLevel1
		,StakeLevel2
		,StakeLevel3
		,StakeLevel4
		,StakeLevel5
		,CASE WHEN	custid =@custid THEN @roleid ELSE 4 END   roleid
	FROM P2PGameSetting	WITH(NOLOCK)
	WHERE	custid=@custid	OR custid=   @srecommend
	ORDER BY roleid desc

	SELECT p2pg.groupID
		,tbl.sdiscount		Uplinediscount
		,case when tbl.sdiscount < @Maxdiscount then tbl.sdiscount
			Else @Maxdiscount End Maxdiscount
		,p2pg.adiscount		discount
	FROM P2PGroupComm p2pg WITH(NOLOCK)
		INNER JOIN 
		(
		SELECT groupID	,sdiscount	
		FROM P2PGroupComm p2pg WITH(NOLOCK)
			WHERE custid =@srecommend
		 )	 tbl On	 p2pg.groupID = tbl.groupID 
		WHERE custid =@custid
END
ELSE
	BEGIN
			SELECT @errmsg =  N'Customer is not master level.'
				,@errcode = 500
			RETURN		
	END

 
GO
GRANT EXECUTE ON dbo.Acc_CustomerSelP2PMaster_All TO bodbAdminNet
GO
GRANT EXECUTE ON dbo.Acc_CustomerSelP2PMaster_All TO bodbDownlineNet
GO
GRANT VIEW definition ON dbo.Acc_CustomerSelP2PMaster_All TO vnteam
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelP2PMaster_All TO [bodbExtAccNet]
