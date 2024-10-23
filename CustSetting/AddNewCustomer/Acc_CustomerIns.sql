/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE Acc_CustomerIns
(
	@FirstName	NVARCHAR (50)
	,@LastName	NVARCHAR (50)
	,@UserName	NVARCHAR (50)
	,@UserPwd	NVARCHAR (50)='' 
	,@pwdexpiry DATETIME	= NULL
	,@roleid	INT			= NULL
	,@closed	BIT			= NULL
	,@CustID	INT
	,@creator	INT 

	,@phone			NVARCHAR(50) = NULL
	,@mobilephone	NVARCHAR(50) = NULL
	,@email			NVARCHAR(50) = NULL
	,@fax			NVARCHAR(50) = NULL
	,@address		NVARCHAR(80) = NULL
	,@city			NVARCHAR(50) = NULL
	,@state			NVARCHAR(50) = NULL
	,@country		NVARCHAR(50) = NULL
	,@postal		NVARCHAR(50) = NULL
	,@srecommend	INT			 = NULL
	,@mrecommend	INT			 = 0
	,@recommend		INT			 = 0
	,@currency		INT			 = NULL
	,@site			NVARCHAR(50) = NULL
	,@ugroup		VARCHAR(5)	 = NULL
	,@birthday		SMALLDATETIME = NULL
	,@refcode1		NVARCHAR(100) = NULL
	,@refcode2		NVARCHAR(100) = NULL
	,@remark		NVARCHAR(100) = NULL
	,@important		BIT			  = NULL
	,@UserName2		VARCHAR(50)	  = NULL
	,@createDate	SMALLDATETIME = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT

) WITH EXECUTE AS OWNER
AS
/*
	Created: 20240704@Louisa
	Task: Scaleout DBCUST Redmine:#199915
	DB: DBCUST/CUSTDB
		
	Revisions:
		- 20240704@Louisa: initial [Redmine:#206823]

	Parameter's Explanation:
*/
BEGIN
	SET IDENTITY_INSERT Customer ON
	BEGIN TRY		
		IF @createDate IS NULL
			SET @createDate = GETDATE()

		INSERT  INTO customer 
		(	custid
			,username
			,userpwd
			,roleid
			,firstname
			,lastname
			,creator
			,pwdexpiry
			,phone
			,mobilephone
			,fax
			,email
			,address
			,city
			,state
			,country
			,postal
			,srecommend
			,mrecommend
			,recommend 
			,currency
			,Site
			,creatdate
			,ugroup
			,birthday
			,refcode1
			,refcode2
			,remark
			,important
			,username2
		)
		VALUES  (
			@custid
			,@username
			,@userpwd
			,@roleid
			,@firstname
			,@lastname
			,@creator
			,@pwdexpiry
			,@phone
			,@mobilephone
			,@fax
			,@email
			,@address
			,@city
			,@state
			,@country
			,@postal
			,@srecommend
			,@mrecommend
			,@recommend
			,@currency
			,@site
			,@createDate
			,@ugroup
			,@birthday
			,@refcode1
			,@refcode2
			,@remark
			,@important
			,@UserName2
				);
		
		SET IDENTITY_INSERT Customer OFF
		--SELECT @CustID = @@IDENTITY;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = @@ERROR
				,@ErrMsg = ERROR_MESSAGE()
		RETURN
	END CATCH
END
GO