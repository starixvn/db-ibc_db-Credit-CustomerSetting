USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelWinningShareColossusBet]    Script Date: 11/11/2015 00:16:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[Acc_CustomerSelWinningShareColossusBet] (@custID INT)
AS
/*
	Created By: Helen
	Created Date: 20151110
	Task: Get WinningShare Setting for ColossusBet - [Redmine:]
	Database: DBCust/CustDB
*/
BEGIN
	DECLARE @srecommend INT, @mrecommend INT, @recommend INT
	
	DECLARE @VN_Commpany VARCHAR (100),@VN_Super VARCHAR (100), @VN_Master VARCHAR (100),@VN_Agent VARCHAR (100)		
			
	SELECT @srecommend=srecommend, @mrecommend = mrecommend, @recommend = recommend
	FROM custInfo WITH (NOLOCK)
	WHERE custid = @custID
	
	IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH (NOLOCK) WHERE custid = @recommend)
	BEGIN
		SET @VN_Commpany = 'WinningShareCompany_DirectMember'
		SET @VN_Super = 'WinningShareSuper_DirectMember'
		SET @VN_Master = 'WinningShareMaster_DirectMember'
		SET @VN_Agent = 'WinningShareAgent_DirectMember'
		
	END
	ELSE IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH (NOLOCK) WHERE custid = @mrecommend)
	BEGIN
		SET @VN_Commpany = 'WinningShareCompany_DirectAgent'
		SET @VN_Super = 'WinningShareSuper_DirectAgent'
		SET @VN_Master = 'WinningShareMaster_DirectAgent'
		SET @VN_Agent = 'WinningShareAgent_DirectAgent'
		
	END
	ELSE IF EXISTS (SELECT 1 FROM Acc_CustDirect WITH (NOLOCK) WHERE custid = @srecommend)
	BEGIN
		SET @VN_Commpany = 'WinningShareCompany_DirectMaster'
		SET @VN_Super = 'WinningShareSuper_DirectMaster'
		SET @VN_Master = 'WinningShareMaster_DirectMaster'
		SET @VN_Agent = 'WinningShareAgent_DirectMaster'
		
	END
	ELSE 
	BEGIN
		SET @VN_Commpany = 'WinningShareCompany'
		SET @VN_Super = 'WinningShareSuper'
		SET @VN_Master = 'WinningShareMaster'
		SET @VN_Agent = 'WinningShareAgent'
		
	END
	
	SELECT 	@VN_Commpany as CommpanyName, @VN_Super as SuperName,@VN_Master as MasterName,@VN_Agent as AgentName

	--SELECT VName, NumberValue 
	--FROM VendorGlobalSetting WITH (NOLOCK)
	--WHERE VName IN (@VN_Commpany,@VN_Super,@VN_Master,@VN_Agent)
	--and VendorId = 4
	
END
