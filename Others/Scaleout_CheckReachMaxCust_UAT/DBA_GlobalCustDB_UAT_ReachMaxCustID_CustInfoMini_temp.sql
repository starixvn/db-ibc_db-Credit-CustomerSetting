/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[DBA_GlobalCustDB_UAT_ReachMaxCustID_CustInfoMini_temp]
AS
/*
	Created: Helen
	Date: 2024-07-04
	Task: register username/nickname/custid for CREDIT
	DB: DBGLOB-GLOBCUSTDB
	
	Revisions:
		- 20240704@Helen: DBCUST-GlobalCustDB-Reach maxcustid of customer Checking - [Redmine:#206823]
		
	Parameter's Explanation:

	Local:
		max_customer_Reseed		max_custsub_Reseed
		148625630				1981560
	SIT
		max_customer_Reseed		max_custsub_Reseed
		25012623				772321

*/
BEGIN

	DECLARE @ErrorMessage	VARCHAR(MAX)	= ''
				,@Subject		NVARCHAR(500)	= ''
				,@Body			NVARCHAR(MAX)	= ''
				,@Recipients	VARCHAR(MAX)	= ''	
	
	DECLARE @Mini_MaxCustID_UAT INT, @customer_IdentityReseed INT, @AvailableCustID_UAT INT

	IF @@SERVERNAME IN ('SITDBCUST') 
		SET @customer_IdentityReseed = 25012623 -- SIT
	IF @@SERVERNAME IN ('TESTDBCUST')
		SET @customer_IdentityReseed = 148625630 -- Local
	/*
	IF @@SERVERNAME IN ('DBCUST')
		SET @customer_IdentityReseed = XXX
	*/
	--SET @Mini_MaxCustID_UAT = (SELECT MAX(custid) FROM dbo.CustInfoMini WITH (NOLOCK) WHERE custid < @customer_IdentityReseed)
	
	SET @Mini_MaxCustID_UAT = (SELECT CONVERT(INT,current_value) FROM sys.sequences WHERE name = 'seq_CustinfoMini')

	--SELECT @customer_IdentityReseed, @Mini_MaxCustID_UAT as Mini_MaxCustID_UAT

	SET @AvailableCustID_UAT =  @customer_IdentityReseed - @Mini_MaxCustID_UAT 
	
	IF @AvailableCustID_UAT <= 3000 -- reached over 90%
	BEGIN
			SET @ErrorMessage = 'Total of available custid for UAT till now:' + CONVERT(VARCHAR(20),@AvailableCustID_UAT)

			IF @@SERVERNAME IN ('DBCUST') 
			BEGIN
				SET @Recipients = 'dbaadmin@starixsoft.com'
			END
			ELSE
			BEGIN
				SET @Recipients = 'dba_local@starixsoft.com;qa@starixsoft.com;gary.vu@starixsoft.com'
			END

			-- Send notification via email
			SET @Subject = @@SERVERNAME + '.GlobCustDB - UAT CustID nearly reach custid of customer - Waring !'	
			
			SET @Body = 'DBCUST:GlobCustDB.CustInfoMini - UAT CustID nearly reach custid of customer - Waring !' + CHAR(13) + CHAR(10)
				+ @ErrorMessage
		
			EXEC msdb.dbo.sp_send_dbmail
					@recipients= @Recipients
					,@body=@Body
					,@sensitivity ='Personal'
					,@importance ='High'
					,@subject =@Subject
					,@body_format = 'TEXT'
					,@profile_name =DEFAULT;

	END
END
