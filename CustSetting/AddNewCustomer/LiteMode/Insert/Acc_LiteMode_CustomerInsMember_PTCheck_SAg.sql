/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_PTCheck_SAg]
	@srecommend INT,	
	
	@SettingType28 VARCHAR(MAX)= '',-- SB
	@SettingType1 VARCHAR(MAX)= '',-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot), NG2
	@SettingType18 VARCHAR(MAX)= '',-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: 20230523@Johnson  
	Task : check PT for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230523@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType28 = '<Root>
						<r sporttype="1" bettype="1" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
						<r sporttype="1" bettype="1" islive="1" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
						....
						<r sporttype="99" bettype="9" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
					</Root>'			
		- @SettingType1 = '<Root>
						<r sporttype="43" bettype="1" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
						<r sporttype="44" bettype="1" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
						....
						<r sporttype="9908" bettype="1201" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
					</Root>'
		- @SettingType18 = '<Root>
						<r sporttype="169" bettype="3611" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
						<r sporttype="220" bettype="1024" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
						....
						<r sporttype="245" bettype="4601" islive="0" superpt="90" isauto="0" autopt="0" masterpt="0" minpt="0" />
					</Root>'				
*/	
BEGIN
	SET NOCOUNT ON 
		
	DECLARE @tblPT28 TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLMONEY,
				MasterPT		SMALLMONEY,				
				MasterMinPT		SMALLMONEY,
				MasterMaxPT		SMALLMONEY
				)	
	
	DECLARE @tblPT18 TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLMONEY,
				MasterPT		SMALLMONEY,				
				MasterMinPT		SMALLMONEY,
				MasterMaxPT		SMALLMONEY
				)
				
	DECLARE @xml XML
	
	IF ISNULL(@SettingType28,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType28)
		
		INSERT INTO @tblPT28(SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(r/@islive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(r/@superpt)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(r/@isauto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(r/@autopt)[1]', 'smallmoney') AS AutoSuperPT,
			T.c.query('.').value('(r/@masterpt)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(r/@minpt)[1]', 'smallmoney') AS MasterMinPT
		FROM  @xml.nodes('/Root/r') T(c) 			
	END	

	IF ISNULL(@SettingType1,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType1)
		
		INSERT INTO @tblPT18(SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(r/@islive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(r/@superpt)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(r/@isauto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(r/@autopt)[1]', 'smallmoney') AS AutoSuperPT,
			T.c.query('.').value('(r/@masterpt)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(r/@minpt)[1]', 'smallmoney') AS MasterMinPT
		FROM  @xml.nodes('/Root/r') T(c) 			
	END
	
	IF ISNULL(@SettingType18,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML, @SettingType18)
		
		INSERT INTO @tblPT18(SportType, 
			BetType, 
			IsLive,
			SuperPT,
			IsAutoSuperPT,
			AutoSuperPT,
			MasterPT,				
			MasterMinPT)
		SELECT T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS SportType,
			T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS BetType,
			T.c.query('.').value('(r/@islive)[1]', 'bit') AS IsLive,
			T.c.query('.').value('(r/@superpt)[1]', 'smallmoney') AS SuperPT,
			T.c.query('.').value('(r/@isauto)[1]', 'bit') AS IsAutoSuperPT,
			T.c.query('.').value('(r/@autopt)[1]', 'smallmoney') AS AutoSuperPT,
			T.c.query('.').value('(r/@masterpt)[1]', 'smallmoney') AS MasterPT,
			T.c.query('.').value('(r/@minpt)[1]', 'smallmoney') AS MasterMinPT
		FROM  @xml.nodes('/Root/r') T(c) 			
	END
	
	
END	