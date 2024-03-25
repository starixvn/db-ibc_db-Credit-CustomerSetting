/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_00]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,
	@roleid INT,
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	@isSearchAndCopy BIT = 0,
	@copyFromCustID INT = 0,

	@SettingType25 VARCHAR(MAX)= '', --Discount
	@SettingType26 VARCHAR(MAX)= '', --Bet Setting
	@SettingType27 VARCHAR(MAX)= '', --Parlay Max Payout
	@SettingType28 VARCHAR(MAX)= '', --PT
	
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
	
 AS
	/*
		Created: Johnson
		Date: 20131106
		Task: Apply execrep when insert into custsetting/custsetting3rd
		DB: DBCUST/CustDB
		
		Revisions:
			- 20131120@Kathy: Add Virtual Greyhounds, Virtual Motor Racing (182, 184) [Redmine:#7234]. Refer to Sps:
				+ Acc_CustomerInsMember_Com
				+ Acc_CustomerInsMember_SAg
				+ Acc_CustomerInsMember_MAg
				+ Acc_CustomerInsMember_Ag
			- 20140303@Patrick	: Add more sport:202 for Keno
			- 20140331@Sophia: remove Fi sporttype = 201
			- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
			- 20140318@Elodie: Add CustSettingGame for Keno [Redmine:#13156]
			- 20140618@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
            - 20141029@Logan:   Check constraint for customer Keno bet setting:  [Redmine: #25165]
                                + MinBet = MAX(AllUpline.MinBet, Global.MinBet)
                                + MaxBet & MaxPerMatch = MIN(AllUpline)
                                + MinBet = MaxBet = MaxPerMatch = 0 (unlimit) if Direct Upline is also unlimit
			- 20141204@Johnson: Add country Korea[bettype = 1514] for Keno [Redmine: #26647]                                
			- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]			
			- 20150603@Daniel: 
				+ Separate custDB to new server DBCUST: 
				+ Improve medthod check table existing in subscribers	
			- 20150715@Viet: remove P2P tables from replication check	
			- 20150910@Elodie: Fix bug no record of gametypeid 1701,1702 for member in case agent has no bet limit or all bet limit unchecked [Redmine:#41823]
			- 20150825@Helen: Colossus Bet - [Redmine: #41264]
			- 20150904@Helen: commission setting for MO [Redmine #41470]
			- 20151015@Dominic: Add logic for new customer setting structure [Redmine #26274]
			- 20151119@Dominic: Fix bug when inserting setting into DCS structure Redmine Feature #26274
			- 20160627@Winnie: Out right PT [Redmine #59438]  	
			- 20161109@Helen: Separate Bet Setting for Soccer - Parlay - [Redmine:66265]
			- 20170223@Elodie: Change preset PT to max PT - [Redmine: #71883]
			- 20170302@Helen: BAIO - Cust setting - [Redmine: 71609]
			- 20170505@Winnie Agent have no PT Setting but new creation member got setting [Redmine: #71639]
			- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
			- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
			- 20180327@Vicky: add header infomation [Redmine: #90422]
			- 20181106@Johnson: add Happy 5 [Redmine: #104006]
			- 20190520@Johnson: add @isSearchAndCopy & @copyFromCustID to support SC suspendInfo for member level [redmine: #105587]
			- 20190910@Winnie: Other Sports - Add New "Others" PT Setting for Badminton [redmine: #119713]
			- 20190805@Eden: Remove initial setting for inactive products (Colosus Bet)  [redmine: #118699]
			- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
			- 20201112@Eden: Keno - Delete unused bettype (country) of Keno [Redmine: #145247]
			- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
			- 20210324@Johnson: Hide GoldDeluxe settings [redmine:#151188]
			- 20210518@Winfred: Add new Parlay Max Payout [RedmineID:#154104]
			- 20210802@Eden: Max Payout Per Match [redmine: #158073]
			- 20220616@Johnson: define temp table to avoid dump db [redmine:#174035]
			- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
			- 20230921@Johnson: extend MaxPT = 0.93 [redmine:194132]
			- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	Parameter's explanation:
		-@isSearchAndCopy & @copyFromCustID : support to copy suspendinfo for roleid = 1
		-@SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN
    SET NOCOUNT ON
			
     IF ( dbo.f_CheckRepTable('CustBetSetting_Agent') = 1
		  AND dbo.f_CheckRepTable('CustBetSetting_Member') = 1 
		  AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1 
		  AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 1 
		  AND dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1 
		  AND dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 1 
		  AND dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1 
		  AND dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1 
	   )
	BEGIN
		CREATE TABLE #ProductSettingDetail_ExecRep00(
			[SettingType] [smallint] ,
			[SportType] [smallint] ,
			[BetType] [smallint] ,
			[IsLive] [bit] ,
			[ProductID] [tinyint] ,
			[MaxPT] [smallmoney] ,
			[MaxDiscount] [decimal](9, 8) ,
			[IsSync] [bit] ,
			[IsHidden] [bit] ,
			[IsDisabled] [bit] ,
			[SettingLevel] [tinyint] ,
			[DisplayOrder] [tinyint] ,
			[SettingStatus] [tinyint] ,
			[IntervalValue] [decimal](19, 8) ,
			[RealProductId] [tinyint] ,
			[MaxChoice] [tinyint] ,
			[ProductSettingID] [int] ,
			[Parent_ProductSettingID] [int] ,
			[Child_DisplayOrder] [int] ,
			SubType [TINYINT],
			PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
		)
		
		IF dbo.f_CheckRepTable('ProductSettingProfile') = 1 
			AND dbo.f_CheckRepTable('ProductProfileSiteCurrency') = 1		
		BEGIN
			INSERT INTO #ProductSettingDetail_ExecRep00(SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType)
			SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
					,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType
			FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)

		END

		--PT setting
		BEGIN
			CREATE TABLE #SportBettypeFilter28 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)

			DECLARE @tblPT28 TABLE (
					SportType		SMALLINT,
					BetType			SMALLINT,
					IsLive			BIT,
					SuperPT			SMALLMONEY,
					IsAutoSuperPT	BIT,
					AutoSuperPT		SMALLMONEY,
					MasterPT		SMALLMONEY,				
					MasterMinPT		SMALLMONEY,
					MasterMaxPT		SMALLMONEY,
					IsAutoMasterPT	BIT,
					AutoMasterPT	SMALLMONEY,
					AgentPT			SMALLMONEY,				
					AgentMinPT		SMALLMONEY,
					SuperMinPT		SMALLMONEY
					)
				
			DECLARE @xml XML
		
			INSERT INTO #SportBettypeFilter28(ProductID, SportType,Bettype,IsLive, SettingType, RealProductId)
			SELECT ProductID, SportType,Bettype,IsLive, SettingType, RealProductId
			FROM #ProductSettingDetail_ExecRep00
			WHERE SettingType IN (28)
		
			IF ISNULL(@SettingType28,'') <> ''
			BEGIN
				SELECT @xml = CONVERT(XML, @SettingType28)
				IF @roleid = 4
				BEGIN
					INSERT INTO @tblPT28(
							SportType, 
							BetType, 
							IsLive,
							SuperPT,
							MasterPT,
							AgentPT,
							SuperMinPT
						)
					SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
						T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
						T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
						T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
						T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
						T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS SuperMinPT
					FROM  @xml.nodes('/Root/R') T(c)		
				END
				ELSE IF @Roleid = 3
				BEGIN
					INSERT INTO @tblPT28(SportType, 
						BetType, 
						IsLive,
						SuperPT,
						IsAutoSuperPT,
						AutoSuperPT,
						MasterPT,				
						MasterMinPT)
					SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
						T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
						T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
						T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
						T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
						T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
						T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
					FROM  @xml.nodes('/Root/R') T(c)
				END
				ELSE IF @roleid = 2
				BEGIN
					INSERT INTO @tblPT28(SportType, 
						BetType, 
						IsLive,
						MasterPT,
						IsAutoMasterPT,
						AutoMasterPT,
						AgentPT,				
						AgentMinPT)
					SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
						T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
						T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
						T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
						T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoMasterPT,
						T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
						T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS AgentMinPT
					FROM  @xml.nodes('/Root/R') T(c) 
				END
				ELSE IF @roleid = 1
				BEGIN
					INSERT INTO @tblPT28(SportType, 
						BetType, 
						IsLive,
						SuperPT,
						MasterPT,					
						AgentPT)
					SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
						T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
						T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
						T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
						T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
					FROM  @xml.nodes('/Root/R') T(c) 
				END
			END
				
			BEGIN TRY
				IF @RoleID = 4
				BEGIN				
					INSERT INTO [dbo].[CustPTSetting3rd_Agent]
						([CustID]
						,[SportType]
						,[BetType]
						,[IsLive]
						,[SuperPT]
						,[MasterPT]
						,[AgentPT]
						,[IsAutoMasterPT]
						,[AutoMasterPT]
						,[IsAutoSuperPT]
						,[AutoSuperPT]
						,[MinPT]
						,[MaxPT])
					SELECT 
						@CustID
						,t.SportType
						,t.BetType
						,t.IsLive
						,t.SuperPT
						,t.MasterPT
						,t.AgentPT
						,0 AS IsAutoMasterPT
						,0 AS AutoMasterPT
						,0 AS IsAutoSuperPT
						,0 AS AutoSuperPT
						,t.SuperMinPT
						,100 MaxPT
					FROM @tblPT28 t
						INNER JOIN #SportBettypeFilter28 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
				END
				ELSE IF @RoleID = 3
				BEGIN				
					INSERT INTO [dbo].[CustPTSetting3rd_Agent]
						([CustID]
						,[SportType]
						,[BetType]
						,[IsLive]
						,[SuperPT]
						,[MasterPT]
						,[AgentPT]
						,[IsAutoMasterPT]
						,[AutoMasterPT]
						,[IsAutoSuperPT]
						,[AutoSuperPT]
						,[MinPT]
						,[MaxPT])
					SELECT 
						@CustID
						,t.SportType
						,t.BetType
						,t.IsLive
						,t.SuperPT
						,t.MasterPT
						,0 as AgentPT
						,0 IsAutoMasterPT
						,0 AutoMasterPT
						,t.IsAutoSuperPT
						,t.AutoSuperPT
						,t.MasterMinPT
						,100 MaxPT
					FROM @tblPT28 t
						INNER JOIN #SportBettypeFilter28 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
				END
				ELSE IF @roleid = 2
				BEGIN
					INSERT INTO [dbo].[CustPTSetting3rd_Agent]
						([CustID]
						,[SportType]
						,[BetType]
						,[IsLive]
						,[SuperPT]
						,[MasterPT]
						,[AgentPT]
						,[IsAutoMasterPT]
						,[AutoMasterPT]
						,[IsAutoSuperPT]
						,[AutoSuperPT]
						,[MinPT]
						,[MaxPT])
					SELECT 
						@CustID
						,t.SportType
						,t.BetType
						,t.IsLive
						,0 as SuperPT
						,t.MasterPT
						,t.AgentPT
						,t.IsAutoMasterPT
						,t.AutoMasterPT
						,0 as IsAutoSuperPT
						,0 as AutoSuperPT
						,t.AgentMinPT
						,100 MaxPT
					FROM @tblPT28 t
						INNER JOIN #SportBettypeFilter28 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
				END
				ELSE IF @roleid = 1
				BEGIN
					--If this is the first member,insert into Group Setting
					INSERT INTO [dbo].[CustPTGroupSetting3rd_Member]
						([AgentID]
						,[SportType]
						,[BetType]
						,[IsLive]
						,[SuperPT]
						,[MasterPT]
						,[AgentPT]
						,[IsAutoMasterPT]
						,[AutoMasterPT]
						,[IsAutoSuperPT]
						,[AutoSuperPT])		
					SELECT 
						@recommend,SportType,BetType,Islive,
						SuperPT,MasterPT,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT
					FROM @tblPT28
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM dbo.CustPTGroupSetting3rd_Member WHERE AgentID = @recommend)
					AND @srecommend IN (
							13869621,
							5340162,
							12262401,
							12141653,
							4138910,
							6379932,
							16112208,
							12141529,
							1539339,
							720475
							--UUS
							,17287861
							,18879367
							,14373244
							,18362423
							,18479460
							,18289591
						)
			
					IF @@ROWCOUNT<>0
					BEGIN
						INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
							SELECT @CustID,1
					END
					ELSE 
					BEGIN
						IF EXISTS(SELECT TOP 1 1
									FROM dbo.CustPTGroupSetting3rd_Member grp WITH(NOLOCK)
									JOIN @tblPT28 tmp ON tmp.SportType = grp.SportType
															AND tmp.BetType = grp.BetType
															AND tmp.Islive = grp.Islive
									WHERE grp.AgentID = @recommend
									AND (
										tmp.SuperPT <> grp.SuperPT
										OR
										tmp.MasterPT <> grp.MasterPT
										OR
										tmp.AgentPT <> grp.AgentPT
										OR
										0 <> grp.IsAutoMasterPT
										OR
										0 <> grp.AutoMasterPT
										OR
										0 <> grp.IsAutoSuperPT
										OR
										0 <> grp.AutoSuperPT
									))
							OR @srecommend NOT IN (
												13869621,
												5340162,
												12262401,
												12141653,
												4138910,
												6379932,
												16112208,
												12141529,
												1539339,
												720475
												--UUS
												,17287861
												,18879367
												,14373244
												,18362423
												,18479460
												,18289591
											)
						BEGIN
							--If this member's PT setting are diffrent from Group PT Setting
							INSERT INTO [dbo].[CustPTSetting3rd_Member]
									([CustID]
									,[SportType]
									,[BetType]
									,[IsLive]
									,[SuperPT]
									,[MasterPT]
									,[AgentPT]
									,[IsAutoMasterPT]
									,[AutoMasterPT]
									,[IsAutoSuperPT]
									,[AutoSuperPT])
							SELECT 
							@CustID,SportType,BetType,Islive,
								SuperPT,MasterPT,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT
							FROM @tblPT28
					
							INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
								SELECT @CustID,0
						END
						ELSE
						BEGIN
							INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
								SELECT @CustID,1
						END
					END				
				END
			END TRY
			BEGIN CATCH 
				SELECT @ErrCode = 1			
			
				IF @roleid > 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID				
				END	
				ELSE IF @roleid = 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
					DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				END
				RETURN
			END CATCH

		END
		--Commission
		BEGIN
			CREATE TABLE #SportBettypeFilter25 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
			DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, bettype SMALLINT, discount DECIMAL(9,8), playerdiscount DECIMAL(9,8), sdiscount DECIMAL(9,8), adiscount DECIMAL(9,8))
	
			INSERT INTO #SportBettypeFilter25(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
			SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId		
			FROM #ProductSettingDetail_ExecRep00
			WHERE SettingType IN (25)
		
			IF  ISNULL(@SettingType25,'') <> ''
			BEGIN			
				IF @roleid IN (4,3,2)
				BEGIN
					SELECT @xml = CONVERT(XML,@SettingType25)
				
					INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
					SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
						T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
					FROM   @xml.nodes('/Root/R') T(c) 
				END
				ELSE IF @roleid = 1
				BEGIN
					SELECT @xml = CONVERT(XML,@SettingType25)
				
					INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount,adiscount,sdiscount)
					SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
						T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
						T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
						T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount,
						T.c.query('.').value('(R/@adiscount)[1]', 'decimal(9,8)') AS adiscount,
						T.c.query('.').value('(R/@sdiscount)[1]', 'decimal(9,8)') AS sdiscount
					FROM   @xml.nodes('/Root/R') T(c) 
				END
			END
		
			BEGIN TRY
				IF @RoleID IN (4,3,2)
				BEGIN
					INSERT INTO [dbo].[CustDiscount3rd_Agent]
						   ([CustID]
						   ,[SportType]
						   ,[BetType]
						   ,[Discount])
					SELECT 
						@CustID
						,dc.SportType
						,dc.BetType
						,dc.discount
					FROM @NewDiscountTbl dc
						INNER JOIN #SportBettypeFilter25 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType
				END	
				ELSE IF @roleid = 1
				BEGIN
					INSERT INTO [dbo].[CustDiscount3rd_Member]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[PlayerDiscount]
					   ,[AgentDiscount]
					   ,[MasterDiscount]
					   ,[SuperDiscount])
					SELECT 
						@CustID
						,dc.SportType
						,dc.BetType
						,dc.playerdiscount
						,dc.discount
						,dc.adiscount
						,dc.sdiscount
					FROM @NewDiscountTbl dc
						INNER JOIN #SportBettypeFilter25 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType   
				END
			END TRY
			BEGIN CATCH 
				SELECT @ErrCode = 3			
				DELETE FROM CustProductStatus WHERE CustID = @CustID			
				IF @roleid > 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID				
					DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				END	
				ELSE IF @roleid = 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
					DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
					DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				END
				RETURN
			END CATCH
		END

		--Bet Setting
		BEGIN
			DECLARE @BetSetting TABLE(
				SportType         SMALLINT, 
				BetType           SMALLINT, 
				MinBet            MONEY, 
				MaxBet            MONEY, 
				MaxPerMatch       MONEY, 
				MaxPerNumber      MONEY, 
				MaxPayoutPerMatch MONEY		
				PRIMARY KEY(sporttype, Bettype)
			);
			CREATE TABLE #SportBettypeFilter26 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		
			INSERT INTO #SportBettypeFilter26(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
			SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
			FROM #ProductSettingDetail_ExecRep00
			WHERE SettingType IN (26)
		
			DELETE @BetSetting
		
			IF ISNULL(@SettingType26,'') <> ''
			BEGIN			
				SELECT @xml = CONVERT(XML,@SettingType26)
		
				INSERT INTO @BetSetting(SportType, 
					BetType, 
					MinBet, 
					MaxBet, 
					MaxPerMatch, 
					MaxPayoutPerMatch)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
					T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
					T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
					T.c.query('.').value('(R/@MaxPayout)[1]', 'money') AS MaxPayoutPerMatch
				FROM  @xml.nodes('/Root/R') T(c)   
			END
				
			BEGIN TRY
				IF @roleid IN (4,3,2)
				BEGIN 
					INSERT INTO CustBetSetting_Agent(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
					SELECT @custid
						,cs.SportType        
						,cs.BetType          
						,MinBet           
						,MaxBet           
						,MaxPerMatch      
						,MaxPerNumber     
						,MaxPayoutPerMatch
					FROM @BetSetting cs
						INNER JOIN #SportBettypeFilter26 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				END
				ELSE IF @roleid = 1
				BEGIN
					INSERT INTO CustBetSetting_Member(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
					SELECT @custid
						,cs.SportType        
						,cs.BetType          
						,MinBet           
						,MaxBet           
						,MaxPerMatch      
						,MaxPerNumber     
						,MaxPayoutPerMatch
					FROM @BetSetting cs
						INNER JOIN #SportBettypeFilter26 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				END
			END TRY
			BEGIN CATCH 
				SELECT @ErrCode = 26			
				DELETE FROM CustProductStatus WHERE CustID = @CustID			
				IF @roleid > 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID					
					DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
					DELETE FROM CustBetSetting_Agent WHERE CustID = @CustID
				END		
				ELSE IF @roleid = 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
					DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
					DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
					DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
				END
				RETURN	
			END CATCH
		END

		--Parlay MaxPayout
		BEGIN
			CREATE TABLE #SportBettypeFilter27 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
			DECLARE @NewMaxPayoutTbl TABLE (
						SportType			SMALLINT
						, BetType			SMALLINT
						, SingleMatchParlay	MONEY
						, Combo2			MONEY
						, Combo35			MONEY
						, ComboOver6		MONEY
						)
		
			INSERT INTO #SportBettypeFilter27(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
			SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
			FROM #ProductSettingDetail_ExecRep00
			WHERE SettingType IN (27)
		
			IF ISNULL(@SettingType27,'') <> ''
			BEGIN
				SELECT @xml = CONVERT(XML,@SettingType27)
				
				INSERT INTO @NewMaxPayoutTbl(SportType, 
					BetType, 
					SingleMatchParlay, 
					Combo2, 
					Combo35, 
					ComboOver6)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@SingleMP)[1]', 'money') AS SingleMatchParlay,
					T.c.query('.').value('(R/@Combo2)[1]', 'money') AS Combo2,
					T.c.query('.').value('(R/@Combo35)[1]', 'money') AS Combo35,
					T.c.query('.').value('(R/@Combo6)[1]', 'money') AS ComboOver6
				FROM  @xml.nodes('/Root/R') T(c)
			END		
		
			BEGIN TRY
				IF @roleid IN (4,3,2)
				BEGIN 
					INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
					SELECT @custid , cs.SportType, cs.BetType, 
							cs.SingleMatchParlay,
							cs.Combo2,
							cs.Combo35,
							cs.ComboOver6
					FROM @NewMaxPayoutTbl cs
						INNER JOIN #SportBettypeFilter27 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				END
				ELSE IF @roleid = 1
				BEGIN
					INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
					SELECT @custid , cs.SportType, cs.BetType, 
							cs.SingleMatchParlay,
							cs.Combo2,
							cs.Combo35,
							cs.ComboOver6
					FROM @NewMaxPayoutTbl cs
						INNER JOIN #SportBettypeFilter27 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				END
			END TRY
			BEGIN CATCH 
				SELECT @ErrCode = 27			
				DELETE FROM CustProductStatus WHERE CustID = @CustID			
				IF @roleid > 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID					
					DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
					DELETE FROM CustBetSetting_Agent WHERE CustID = @CustID
					DELETE FROM CustMaxPayoutSetting_Agent WHERE CustID = @CustID
				END	
				ELSE IF @roleid = 1
				BEGIN
					DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
					DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
					DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
					DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
					DELETE FROM CustMaxPayoutSetting_Member WHERE CustID = @CustID
				END			
				RETURN	
			END CATCH
		END
		
		DROP TABLE #ProductSettingDetail_ExecRep00
		DROP TABLE #SportBettypeFilter25
		DROP TABLE #SportBettypeFilter26
		DROP TABLE #SportBettypeFilter27
		DROP TABLE #SportBettypeFilter28
	END

	/*DOMINIC-CUSTOMER SETTING RENOVATION-START*/
	DECLARE @DCSErrCode INT = 0
	EXEC dbo.Acc_DynamicCustomerInfo_00
			@CustID				= @CustID
			, @SuperID			= @srecommend
			, @MasterID			= @mrecommend
			, @AgentID			= @recommend
			, @RoleID			= @roleid
			, @ProductID		= NULL
			, @isSearchAndCopy 	= @isSearchAndCopy
			, @copyFromCustID 	= @copyFromCustID
			, @ErrCode			= @DCSErrCode OUTPUT
			, @SettingStatus    = @SettingStatus
				
	IF @DCSErrCode <> 0 
	BEGIN
		--Error occur
		SET @ErrCode = 911
				
		-- ROLLBACK MANUALLY
		IF(dbo.f_CheckRepTable('CustBetSetting_Agent') = 1) DELETE CustBetSetting_Agent WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustBetSetting_Member') = 1) DELETE CustBetSetting_Member WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 1) DELETE CustMaxPayoutSetting_Member WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1) DELETE CustMaxPayoutSetting_Agent WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1) DELETE CustPTSetting3rd_Agent WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 1) DELETE CustPTSetting3rd_Member WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1) DELETE CustDiscount3rd_Agent WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1) DELETE CustDiscount3rd_Member WITH (ROWLOCK) WHERE custId  = @custid
	END
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/	
END
GO