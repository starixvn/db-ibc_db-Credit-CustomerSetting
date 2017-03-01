ALTER PROCEDURE dbo.Acc_CustomerSelp2PAgent_All
	@custid INT,
	@errcode INT = 0 OUTPUT,
	@errmsg NVARCHAR(200) = '' OUTPUT
AS
/* 
Created: 20110720@tom
Task: get basic setting of a agent for p2pgamesetting
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
	,@mrecommend INT

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
      ,@uplineisautoresetp2p = upline.isautoresetp2p
      ,@isautoresetp2p = cuif.isautoresetp2p
      ,@disablep2p = cuif.disablep2p
      ,@disablefunp2p = cuif.disablefunp2p
      ,@mrecommend=cuif.mrecommend
  FROM bodb02.dbo.customer cust WITH (NOLOCK)
	INNER JOIN	bodb02.dbo.custinfo cuif WITH(NOLOCK)
		ON	cust.custid = cuif.custid
	INNER JOIN	bodb02.dbo.custinfo upline WITH(NOLOCK)
		ON	upline.custid = cuif.mrecommend		
WHERE	cust.custid=@custid --and cuif.roleid=2

IF @roleid=2
BEGIN
	INSERT INTO	 @table_p (firstname,lastname,phone,mobilephone,fax
		  ,email,username,currency,roleid,transferp2p,uplineisautoresetp2p,isautoresetp2p,disablep2p,disablefunp2p )
	VALUES (@firstname,@lastname,@phone,@mobilephone,@fax
		  ,@email,@username,@currency,@roleid,@maxtransferp2p,@uplineisautoresetp2p,@isautoresetp2p,@disablep2p,@disablefunp2p)

	SELECT @mintransferp2p=MinCredit , @Maxdiscount = Maxdiscount FROM P2PDefaultSetting WITH(NOLOCK) WHERE currency=@currency
	SELECT @maxtransferp2p=cuif.maxtransferp2p FROM bodb02.dbo.custinfo cuif WITH(NOLOCK) WHERE cuif.custid=@mrecommend	

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
		  ,uplineisautoresetp2p
		  ,isautoresetp2p
	 FROM @table_p

	SELECT bettype
		,StakeLevel1
		,StakeLevel2
		,StakeLevel3
		,StakeLevel4
		,StakeLevel5
		,CASE WHEN	custid =@custid THEN @roleid ELSE 3 END   roleid
	FROM P2PGameSetting	WITH(NOLOCK)
	WHERE	custid=@custid	OR custid=   @mrecommend
	ORDER BY roleid desc

	SELECT p2pg.groupID
		,tbl.adiscount		Uplinediscount
		,case when tbl.adiscount < @Maxdiscount then tbl.adiscount
			Else @Maxdiscount End Maxdiscount
		,p2pg.discount		discount
	FROM P2PGroupComm p2pg WITH(NOLOCK)
		INNER JOIN 
		(
		SELECT groupID	,adiscount	
		FROM P2PGroupComm p2pg WITH(NOLOCK)
			WHERE custid =@mrecommend
		 )	 tbl On	 p2pg.groupID = tbl.groupID 
		WHERE custid =@custid		
END
ELSE
	BEGIN
		SELECT @errmsg =  N'Customer is not agent level.'
				,@errcode = 500
		RETURN		
	END

GO
GRANT EXECUTE ON dbo.Acc_CustomerSelp2PAgent_All TO bodbAdminNet
GO
GRANT EXECUTE ON dbo.Acc_CustomerSelp2PAgent_All TO bodbDownlineNet
GO
GRANT VIEW definition ON dbo.Acc_CustomerSelp2PAgent_All TO vnteam
GO
GRANT EXECUTE ON [dbo].Acc_CustomerSelp2PAgent_All TO [bodbExtAccNet]

