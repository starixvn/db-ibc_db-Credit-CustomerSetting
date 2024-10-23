/*<info serverAlias="DBcust-CustDB" executers="" viewers="" isFunction="0"></info>*/

/*
	 Created by: Patrick
	 Task: Sign up SP with certificate [Redmine:#206823]
	 DB: DBcust.CustDB

*/

--create certificate on DBcust.CustDB
CREATE CERTIFICATE cert_scaleout_dbcust_UAT
ENCRYPTION BY PASSWORD = 'Admin!@#password' 
WITH SUBJECT = 'scaleout-dbcust-UAT', 
START_DATE = '20240716', EXPIRY_DATE = '20500101'


-- copy certificate 
CREATE TABLE ##keys (pubkey varbinary (MAX) NOT NULL, privkey varbinary(MAX) NOT NULL)
INSERT ##keys (pubkey, privkey)
SELECT 
	certencoded(cert_id('cert_scaleout_dbcust_UAT')),
	certprivatekey(cert_id('cert_scaleout_dbcust_UAT'),'Topsecret???','Admin!@#password')

-- create a user for that certificate 
CREATE USER user_cert_scaleout_dbcust_UAT FROM CERTIFICATE cert_scaleout_dbcust_UAT

--grant permission
grant insert, select, update, delete	on  CustinfoMini to user_cert_scaleout_dbcust_UAT
grant insert, select, update, delete	on CustSubMini  to user_cert_scaleout_dbcust_UAT 

--grant alter				on customer		to user_cert_scaleout_dbcust_UAT


-- Import the certificate we created in the first test database into the second. (GlobCustDB)
DECLARE @sql nvarchar(MAX)
SELECT @sql =
 'CREATE CERTIFICATE cert_scaleout_dbcust_UAT
 FROM BINARY = ' + convert(nvarchar(MAX), pubkey, 1) + '
 WITH PRIVATE KEY (BINARY = ' + convert(nvarchar(MAX), privkey, 1) + ',
 DECRYPTION BY PASSWORD = ''Topsecret???'',
 ENCRYPTION BY PASSWORD = ''Admin!@#passwordagain'')'
FROM ##keys 
PRINT @sql 
EXEC (@sql) 
DROP TABLE ##keys


-- sign required SP on each database (custDB, GlobCustDB) 
ADD SIGNATURE TO SP_name BY CERTIFICATE certificate_name
WITH PASSWORD = 'Admin!@#passwordagain'


