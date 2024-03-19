/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_00]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,
	@roleid INT,
	@isSearchAndCopy BIT = 0,
	@copyFromCustID INT = 0,

	@groupa DECIMAL(9,8) = 0, 
	@groupb DECIMAL(9,8) = 0, 
	@groupc DECIMAL(9,8) = 0, 
	@groupd DECIMAL(9,8) = 0,
	
	---
	--insert new super	
	@spositiontaking_1 SMALLMONEY = 0,
	@spositiontaking_2 SMALLMONEY = 0,
	@spositiontaking_3 SMALLMONEY = 0,
	@spositiontaking_4 SMALLMONEY = 0,
	@spositiontaking_5 SMALLMONEY = 0,
	@spositiontaking_6 SMALLMONEY = 0,
	@spositiontaking_7 SMALLMONEY = 0,
	@spositiontaking_8 SMALLMONEY = 0,
	@spositiontaking_9 SMALLMONEY = 0,
	@spositiontaking_10 SMALLMONEY = 0,
	@v2spositiontaking_10 SMALLMONEY = 0,
	@v3spositiontaking_10 SMALLMONEY = 0,
	@v5spositiontaking_10 SMALLMONEY = 0,
	@v8spositiontaking_10 SMALLMONEY = 0,
	@v10spositiontaking_10 SMALLMONEY = 0,
	@v11spositiontaking_10 SMALLMONEY = 0,
	@v99spositiontaking_10 SMALLMONEY = 0,
	@spositiontaking_9999 SMALLMONEY = 0,
	
	@slivepositiontaking_1 SMALLMONEY = 0,
	@slivepositiontaking_3 SMALLMONEY = 0,
	@slivepositiontaking_7 SMALLMONEY = 0,
	@slivepositiontaking_8 SMALLMONEY = 0,
	
	@v2spositiontaking_1 SMALLMONEY = 0,
	@v2spositiontaking_2 SMALLMONEY = 0,
	@v2spositiontaking_3 SMALLMONEY = 0,
	@v2spositiontaking_7 SMALLMONEY = 0,
	@v2spositiontaking_8 SMALLMONEY = 0,
	--@v2spositiontaking_9 SMALLMONEY = 0,
	@v2spositiontaking_20 SMALLMONEY = 0,
	@v2spositiontaking_9999 SMALLMONEY = 0,
	
	@v3spositiontaking_1 SMALLMONEY = 0,
	@v3spositiontaking_2 SMALLMONEY = 0,
	@v3spositiontaking_3 SMALLMONEY = 0,
	@v3spositiontaking_20 SMALLMONEY = 0,

	@v5spositiontaking_1 SMALLMONEY = 0,
	@v5spositiontaking_2 SMALLMONEY = 0,
	@v5spositiontaking_3 SMALLMONEY = 0,
	@v5spositiontaking_20 SMALLMONEY = 0,
	@v5spositiontaking_9999 SMALLMONEY = 0,

	@v8spositiontaking_1 SMALLMONEY = 0,
	@v8spositiontaking_3 SMALLMONEY = 0,
	@v8spositiontaking_20 SMALLMONEY = 0,

	@v10spositiontaking_1 SMALLMONEY = 0,
	@v10spositiontaking_2 SMALLMONEY = 0,
	@v10spositiontaking_3 SMALLMONEY = 0,
	@v10spositiontaking_20 SMALLMONEY = 0,

	@v11spositiontaking_1 SMALLMONEY = 0,
	@v11spositiontaking_20 SMALLMONEY = 0,

	@v99spositiontaking_1 SMALLMONEY = 0,
	@v99spositiontaking_2 SMALLMONEY = 0,
	@v99spositiontaking_3 SMALLMONEY = 0,
	@v99spositiontaking_9 SMALLMONEY = 0,
	@v99spositiontaking_20 SMALLMONEY = 0,
	@v99spositiontaking_9999 SMALLMONEY = 0,	
	
	---create new master
	@auto_spositiontaking_1 smallmoney = 0,
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney = 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
	@auto_spositiontaking_9999 smallmoney = 0,
	@auto_slivepositiontaking_1 smallmoney = 0,
	@auto_slivepositiontaking_3 smallmoney = 0,
	@auto_slivepositiontaking_7 smallmoney = 0,
	@auto_slivepositiontaking_8 smallmoney = 0,
	
	@auto_v2spositiontaking_1 smallmoney = 0,
	@auto_v2spositiontaking_2 smallmoney = 0,
	@auto_v2spositiontaking_3 smallmoney = 0,
	@auto_v2spositiontaking_7 smallmoney = 0,
	@auto_v2spositiontaking_8 smallmoney = 0,
--	@auto_v2spositiontaking_9 smallmoney = 0,
	@auto_v2spositiontaking_20 smallmoney = 0,
	@auto_v2spositiontaking_9999 smallmoney = 0,
	
	@auto_v3spositiontaking_1 smallmoney = 0,
	@auto_v3spositiontaking_2 smallmoney = 0,
	@auto_v3spositiontaking_3 smallmoney = 0,	
	@auto_v3spositiontaking_20 smallmoney = 0,
	
	@auto_v5spositiontaking_1 smallmoney = 0,
	@auto_v5spositiontaking_2 smallmoney = 0,
	@auto_v5spositiontaking_3 smallmoney = 0,	
	@auto_v5spositiontaking_20 smallmoney = 0,
	@auto_v5spositiontaking_9999 smallmoney = 0,
	
	@auto_v8spositiontaking_1 smallmoney = 0,	
	@auto_v8spositiontaking_3 smallmoney = 0,	
	@auto_v8spositiontaking_20 smallmoney = 0,
	
	@auto_v10spositiontaking_1 smallmoney = 0,
	@auto_v10spositiontaking_2 smallmoney = 0,
	@auto_v10spositiontaking_3 smallmoney = 0,	
	@auto_v10spositiontaking_20 smallmoney = 0,
	
	@auto_v11spositiontaking_1 smallmoney = 0,	
	@auto_v11spositiontaking_20 smallmoney = 0,
	
	@auto_v99spositiontaking_1 smallmoney = 0,
	@auto_v99spositiontaking_2 smallmoney = 0,
	@auto_v99spositiontaking_3 smallmoney = 0,		
	@auto_v99spositiontaking_20 smallmoney = 0,	
	@auto_v99spositiontaking_9999 smallmoney = 0,	
	@auto_v99spositiontaking_9 smallmoney = 0,
	
	----n4 vs	
	@isauto_spositiontaking_1 BIT = 0,
	@isauto_spositiontaking_2 BIT = 0,
	@isauto_spositiontaking_3 BIT = 0,
	@isauto_spositiontaking_4 BIT = 0,
	@isauto_spositiontaking_5 BIT = 0,
	@isauto_spositiontaking_6 BIT = 0,
	@isauto_spositiontaking_7 BIT = 0,
	@isauto_spositiontaking_8 BIT = 0,
	@isauto_spositiontaking_9 BIT = 0,
	@isauto_spositiontaking_10 BIT = 0,
	@isauto_v2spositiontaking_10 BIT = 0,
	@isauto_v3spositiontaking_10 BIT = 0,
	@isauto_v5spositiontaking_10 BIT = 0,
	@isauto_v8spositiontaking_10 BIT = 0,
	@isauto_v10spositiontaking_10 BIT = 0,
	@isauto_v11spositiontaking_10 BIT = 0,
	@isauto_v99spositiontaking_10 BIT = 0,
	@isauto_spositiontaking_9999 BIT = 0,
	
	@isauto_slivepositiontaking_1 BIT = 0,
	@isauto_slivepositiontaking_3 BIT = 0,
	@isauto_slivepositiontaking_7 BIT = 0,
	@isauto_slivepositiontaking_8 BIT = 0,
	
	@isauto_v2spositiontaking_1 BIT = 0,
	@isauto_v2spositiontaking_2 BIT = 0,
	@isauto_v2spositiontaking_3 BIT = 0,
	@isauto_v2spositiontaking_7 BIT = 0,
	@isauto_v2spositiontaking_8 BIT = 0,
--	@isauto_v2spositiontaking_9 BIT = 0,
	@isauto_v2spositiontaking_20 BIT = 0,
	@isauto_v2spositiontaking_9999 BIT = 0,
	
	@isauto_v3spositiontaking_1 BIT = 0,
	@isauto_v3spositiontaking_2 BIT = 0,
	@isauto_v3spositiontaking_3 BIT = 0,	
	@isauto_v3spositiontaking_20 BIT = 0,
	
	@isauto_v5spositiontaking_1 BIT = 0,
	@isauto_v5spositiontaking_2 BIT = 0,
	@isauto_v5spositiontaking_3 BIT = 0,	
	@isauto_v5spositiontaking_20 BIT = 0,
	@isauto_v5spositiontaking_9999 BIT = 0,
	
	@isauto_v8spositiontaking_1 BIT = 0,	
	@isauto_v8spositiontaking_3 BIT = 0,	
	@isauto_v8spositiontaking_20 BIT = 0,
	
	@isauto_v10spositiontaking_1 BIT = 0,
	@isauto_v10spositiontaking_2 BIT = 0,
	@isauto_v10spositiontaking_3 BIT = 0,	
	@isauto_v10spositiontaking_20 BIT = 0,
	
	@isauto_v11spositiontaking_1 BIT = 0,	
	@isauto_v11spositiontaking_20 BIT = 0,

	@isauto_v99spositiontaking_1 BIT = 0,
	@isauto_v99spositiontaking_2 BIT = 0,
	@isauto_v99spositiontaking_3 BIT = 0,		
	@isauto_v99spositiontaking_20 BIT = 0,
	@isauto_v99spositiontaking_9999 BIT = 0,
	@isauto_v99spositiontaking_9 BIT = 0,	
	
	@mpositiontaking_1 SMALLMONEY = 0,
	@mpositiontaking_2 SMALLMONEY = 0,
	@mpositiontaking_3 SMALLMONEY = 0,
	@mpositiontaking_4 SMALLMONEY = 0,
	@mpositiontaking_5 SMALLMONEY = 0,
	@mpositiontaking_6 SMALLMONEY = 0,
	@mpositiontaking_7 SMALLMONEY = 0,
	@mpositiontaking_8 SMALLMONEY = 0,
	@mpositiontaking_9 SMALLMONEY = 0,
	@mpositiontaking_10 SMALLMONEY = 0,
	@v2mpositiontaking_10 SMALLMONEY = 0,
	@v3mpositiontaking_10 SMALLMONEY = 0,
	@v5mpositiontaking_10 SMALLMONEY = 0,
	@v8mpositiontaking_10 SMALLMONEY = 0,
	@v10mpositiontaking_10 SMALLMONEY = 0,
	@v11mpositiontaking_10 SMALLMONEY = 0,
	@v99mpositiontaking_10 SMALLMONEY = 0,
	@mpositiontaking_9999 SMALLMONEY = 0,
	
	@mlivepositiontaking_1 SMALLMONEY = 0,
	@mlivepositiontaking_3 SMALLMONEY = 0,
	@mlivepositiontaking_7 SMALLMONEY = 0,
	@mlivepositiontaking_8 SMALLMONEY = 0,
	
	@v2mpositiontaking_1 SMALLMONEY = 0,
	@v2mpositiontaking_2 SMALLMONEY = 0,
	@v2mpositiontaking_3 SMALLMONEY = 0,
	@v2mpositiontaking_7 SMALLMONEY = 0,
	@v2mpositiontaking_8 SMALLMONEY = 0,
	--@v2mpositiontaking_9 SMALLMONEY = 0,
	@v2mpositiontaking_20 SMALLMONEY = 0,
	@v2mpositiontaking_9999 SMALLMONEY = 0,

	@v3mpositiontaking_1 SMALLMONEY = 0,
	@v3mpositiontaking_2 SMALLMONEY = 0,
	@v3mpositiontaking_3 SMALLMONEY = 0,
	@v3mpositiontaking_20 SMALLMONEY = 0,

	@v5mpositiontaking_1 SMALLMONEY = 0,
	@v5mpositiontaking_2 SMALLMONEY = 0,
	@v5mpositiontaking_3 SMALLMONEY = 0,
	@v5mpositiontaking_20 SMALLMONEY = 0,
	@v5mpositiontaking_9999 SMALLMONEY = 0,

	@v8mpositiontaking_1 SMALLMONEY = 0,
	@v8mpositiontaking_3 SMALLMONEY = 0,
	@v8mpositiontaking_20 SMALLMONEY = 0,

	@v10mpositiontaking_1 SMALLMONEY = 0,
	@v10mpositiontaking_2 SMALLMONEY = 0,
	@v10mpositiontaking_3 SMALLMONEY = 0,
	@v10mpositiontaking_20 SMALLMONEY = 0,

	@v11mpositiontaking_1 SMALLMONEY = 0,
	@v11mpositiontaking_20 SMALLMONEY = 0,

	@v99mpositiontaking_1 SMALLMONEY = 0,
	@v99mpositiontaking_2 SMALLMONEY = 0,
	@v99mpositiontaking_3 SMALLMONEY = 0,
	@v99mpositiontaking_9 SMALLMONEY = 0,
	@v99mpositiontaking_20 SMALLMONEY = 0,
	@v99mpositiontaking_9999 SMALLMONEY = 0,	
		
	---create agent
	--Auto Master PT
	@auto_mpositiontaking_1 smallmoney = 0,
	@auto_mpositiontaking_2 smallmoney = 0,
	@auto_mpositiontaking_3 smallmoney = 0,
	@auto_mpositiontaking_4 smallmoney = 0,
	@auto_mpositiontaking_5 smallmoney = 0,
	@auto_mpositiontaking_6 smallmoney = 0,
	@auto_mpositiontaking_7 smallmoney = 0,
	@auto_mpositiontaking_8 smallmoney = 0,
	@auto_mpositiontaking_9 smallmoney = 0,
	@auto_mpositiontaking_10 smallmoney = 0,
	@auto_v2mpositiontaking_10 smallmoney = 0,
	@auto_v3mpositiontaking_10 smallmoney = 0,
	@auto_v5mpositiontaking_10 smallmoney = 0,
	@auto_v8mpositiontaking_10 smallmoney = 0,
	@auto_v10mpositiontaking_10 smallmoney = 0,
	@auto_v11mpositiontaking_10 smallmoney = 0,
	@auto_v99mpositiontaking_10 smallmoney = 0,
	@auto_mpositiontaking_9999 smallmoney = 0,
	@auto_mlivepositiontaking_1 smallmoney = 0,
	@auto_mlivepositiontaking_3 smallmoney = 0,
	@auto_mlivepositiontaking_7 smallmoney = 0,
	@auto_mlivepositiontaking_8 smallmoney = 0,
	
	@auto_v2mpositiontaking_1 smallmoney = 0,
	@auto_v2mpositiontaking_2 smallmoney = 0,
	@auto_v2mpositiontaking_3 smallmoney = 0,
	@auto_v2mpositiontaking_7 smallmoney = 0,
	@auto_v2mpositiontaking_8 smallmoney = 0,
--	@auto_v2mpositiontaking_9 smallmoney = 0,
	@auto_v2mpositiontaking_20 smallmoney = 0,
	@auto_v2mpositiontaking_9999 smallmoney = 0,
	
	@auto_v3mpositiontaking_1 smallmoney = 0,
	@auto_v3mpositiontaking_2 smallmoney = 0,
	@auto_v3mpositiontaking_3 smallmoney = 0,	
	@auto_v3mpositiontaking_20 smallmoney = 0,
	
	@auto_v5mpositiontaking_1 smallmoney = 0,
	@auto_v5mpositiontaking_2 smallmoney = 0,
	@auto_v5mpositiontaking_3 smallmoney = 0,	
	@auto_v5mpositiontaking_20 smallmoney = 0,
	@auto_v5mpositiontaking_9999 smallmoney = 0,
	
	@auto_v8mpositiontaking_1 smallmoney = 0,	
	@auto_v8mpositiontaking_3 smallmoney = 0,	
	@auto_v8mpositiontaking_20 smallmoney = 0,
	
	@auto_v10mpositiontaking_1 smallmoney = 0,
	@auto_v10mpositiontaking_2 smallmoney = 0,
	@auto_v10mpositiontaking_3 smallmoney = 0,	
	@auto_v10mpositiontaking_20 smallmoney = 0,
	
	@auto_v11mpositiontaking_1 smallmoney = 0,	
	@auto_v11mpositiontaking_20 smallmoney = 0,
	
	@auto_v99mpositiontaking_1 smallmoney = 0,
	@auto_v99mpositiontaking_2 smallmoney = 0,
	@auto_v99mpositiontaking_3 smallmoney = 0,	
	@auto_v99mpositiontaking_20 smallmoney = 0,	
	@auto_v99mpositiontaking_9999 smallmoney = 0,	
	-- mix parlay of mixed sports
	@auto_v99mpositiontaking_9 smallmoney = 0,	

	@isauto_mpositiontaking_1 BIT = 0,
	@isauto_mpositiontaking_2 BIT = 0,
	@isauto_mpositiontaking_3 BIT = 0,
	@isauto_mpositiontaking_4 BIT = 0,
	@isauto_mpositiontaking_5 BIT = 0,
	@isauto_mpositiontaking_6 BIT = 0,
	@isauto_mpositiontaking_7 BIT = 0,
	@isauto_mpositiontaking_8 BIT = 0,
	@isauto_mpositiontaking_9 BIT = 0,
	@isauto_mpositiontaking_10 BIT = 0,
	@isauto_v2mpositiontaking_10 BIT = 0,
	@isauto_v3mpositiontaking_10 BIT = 0,
	@isauto_v5mpositiontaking_10 BIT = 0,
	@isauto_v8mpositiontaking_10 BIT = 0,
	@isauto_v10mpositiontaking_10 BIT = 0,
	@isauto_v11mpositiontaking_10 BIT = 0,
	@isauto_v99mpositiontaking_10 BIT = 0,
	@isauto_mpositiontaking_9999 BIT = 0,
	
	@isauto_mlivepositiontaking_1 BIT = 0,
	@isauto_mlivepositiontaking_3 BIT = 0,
	@isauto_mlivepositiontaking_7 BIT = 0,
	@isauto_mlivepositiontaking_8 BIT = 0,
	
	@isauto_v2mpositiontaking_1 BIT = 0,
	@isauto_v2mpositiontaking_2 BIT = 0,
	@isauto_v2mpositiontaking_3 BIT = 0,
	@isauto_v2mpositiontaking_7 BIT = 0,
	@isauto_v2mpositiontaking_8 BIT = 0,
--	@isauto_v2mpositiontaking_9 BIT = 0,
	@isauto_v2mpositiontaking_20 BIT = 0,
	@isauto_v2mpositiontaking_9999 BIT = 0,
	
	@isauto_v3mpositiontaking_1 BIT = 0,
	@isauto_v3mpositiontaking_2 BIT = 0,
	@isauto_v3mpositiontaking_3 BIT = 0,	
	@isauto_v3mpositiontaking_20 BIT = 0,
	
	@isauto_v5mpositiontaking_1 BIT = 0,
	@isauto_v5mpositiontaking_2 BIT = 0,
	@isauto_v5mpositiontaking_3 BIT = 0,	
	@isauto_v5mpositiontaking_20 BIT = 0,
	@isauto_v5mpositiontaking_9999 BIT = 0,
	
	@isauto_v8mpositiontaking_1 BIT = 0,	
	@isauto_v8mpositiontaking_3 BIT = 0,	
	@isauto_v8mpositiontaking_20 BIT = 0,
	
	@isauto_v10mpositiontaking_1 BIT = 0,
	@isauto_v10mpositiontaking_2 BIT = 0,
	@isauto_v10mpositiontaking_3 BIT = 0,	
	@isauto_v10mpositiontaking_20 BIT = 0,
	
	@isauto_v11mpositiontaking_1 BIT = 0,	
	@isauto_v11mpositiontaking_20 BIT = 0,

	@isauto_v99mpositiontaking_1 BIT = 0,
	@isauto_v99mpositiontaking_2 BIT = 0,
	@isauto_v99mpositiontaking_3 BIT = 0,	
	@isauto_v99mpositiontaking_20 BIT = 0,
	@isauto_v99mpositiontaking_9999 BIT = 0,
	--- mix parlay of mixed sports
	@isauto_v99mpositiontaking_9 BIT = 0,	
		
	@apositiontaking_1 SMALLMONEY = 0,
	@apositiontaking_2 SMALLMONEY = 0,
	@apositiontaking_3 SMALLMONEY = 0,
	@apositiontaking_4 SMALLMONEY = 0,
	@apositiontaking_5 SMALLMONEY = 0,
	@apositiontaking_6 SMALLMONEY = 0,
	@apositiontaking_7 SMALLMONEY = 0,
	@apositiontaking_8 SMALLMONEY = 0,
	@apositiontaking_9 SMALLMONEY = 0,
	@apositiontaking_10 SMALLMONEY = 0,
	@v2apositiontaking_10 SMALLMONEY = 0,
	@v3apositiontaking_10 SMALLMONEY = 0,
	@v5apositiontaking_10 SMALLMONEY = 0,
	@v8apositiontaking_10 SMALLMONEY = 0,
	@v10apositiontaking_10 SMALLMONEY = 0,
	@v11apositiontaking_10 SMALLMONEY = 0,
	@v99apositiontaking_10 SMALLMONEY = 0,
	@apositiontaking_9999 SMALLMONEY = 0,
	
	@alivepositiontaking_1 SMALLMONEY = 0,
	@alivepositiontaking_3 SMALLMONEY = 0,
	@alivepositiontaking_7 SMALLMONEY = 0,
	@alivepositiontaking_8 SMALLMONEY = 0,
	
	@v2apositiontaking_1 SMALLMONEY = 0,
	@v2apositiontaking_2 SMALLMONEY = 0,
	@v2apositiontaking_3 SMALLMONEY = 0,
	@v2apositiontaking_7 SMALLMONEY = 0,
	@v2apositiontaking_8 SMALLMONEY = 0,
	--@v2apositiontaking_9 SMALLMONEY = 0,
	@v2apositiontaking_20 SMALLMONEY = 0,
	
	@v2apositiontaking_9999 SMALLMONEY = 0,

	@v3apositiontaking_1 SMALLMONEY = 0,
	@v3apositiontaking_2 SMALLMONEY = 0,
	@v3apositiontaking_3 SMALLMONEY = 0,
	@v3apositiontaking_20 SMALLMONEY = 0,

	@v5apositiontaking_1 SMALLMONEY = 0,
	@v5apositiontaking_2 SMALLMONEY = 0,
	@v5apositiontaking_3 SMALLMONEY = 0,
	@v5apositiontaking_20 SMALLMONEY = 0,
	@v5apositiontaking_9999 SMALLMONEY = 0,

	@v8apositiontaking_1 SMALLMONEY = 0,
	@v8apositiontaking_3 SMALLMONEY = 0,
	@v8apositiontaking_20 SMALLMONEY = 0,

	@v10apositiontaking_1 SMALLMONEY = 0,
	@v10apositiontaking_2 SMALLMONEY = 0,
	@v10apositiontaking_3 SMALLMONEY = 0,
	@v10apositiontaking_20 SMALLMONEY = 0,

	@v11apositiontaking_1 SMALLMONEY = 0,
	@v11apositiontaking_20 SMALLMONEY = 0,

	@v99apositiontaking_1 SMALLMONEY = 0,
	@v99apositiontaking_2 SMALLMONEY = 0,
	@v99apositiontaking_3 SMALLMONEY = 0,
	@v99apositiontaking_9 SMALLMONEY = 0,
	@v99apositiontaking_20 SMALLMONEY = 0,
	@v99apositiontaking_9999 SMALLMONEY = 0,	
				  	
	@discount decimal(9,8)= 0,	
	@discountcs DECIMAL(9,8)=0, 
	--comm 1x2
	@discount1x2 DECIMAL(9,8)=0,
	
	
	@playerdiscount decimal(9,8) = 0, 
	@playerdiscountcs decimal(9,8) = 0,
	--1x2 
	@playerdiscount1x2 decimal(9,8)=0,	

	
	@adiscount decimal(9,8) = 0,
	@adiscountcs decimal(9,8) = 0,
	@adiscount1x2 decimal(9,8) = 0,

	
	@sdiscount decimal(9,8) = 0,		
	@sdiscountcs decimal(9,8) = 0,	
	@sdiscount1x2 decimal(9,8) = 0,			
	
	-->Bet Setting XML
	@BetSettingXML VARCHAR(8000) = '',

	-- Myanma Odds
	@discountMyanmarOdds DECIMAL(9,8) = 0,	
	@IsMyanmarOdds BIT = 0,
	
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
	Parameter's explanation:
		-@isSearchAndCopy & @copyFromCustID : support to copy suspendinfo for roleid = 1
		-@SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN
    SET NOCOUNT ON
			
     if (dbo.f_CheckRepTable('CustSetting') = 1 
		  AND dbo.f_CheckRepTable('CustOverride') = 1 
		  AND dbo.f_CheckRepTable('ProductGlobalSetting') = 1 
		  AND dbo.f_CheckRepTable('ProductBetSetting') = 1
		  AND dbo.f_CheckRepTable('AgentCommRate') = 1
		  AND dbo.f_CheckRepTable('CustCommRate') = 1 
		  AND dbo.f_CheckRepTable('CustBetSetting_Agent') = 1
		  AND dbo.f_CheckRepTable('CustBetSetting_Member') = 1 
		  AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1 
		  AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 1 
	   )
	BEGIN

	DECLARE @discountnumber DECIMAL(9,8)=0,
	@playerdiscountnumber decimal(9,8)=0,
	@adiscountnumber decimal(9,8) = 0,
	@sdiscountnumber decimal(9,8) = 0
	

    DECLARE @ProductGlobalSetting TABLE (Sporttype INT, Bettype INT, MaxPositiontaking SMALLMONEY, IsDep BIT)
    DECLARE @ProductBetSetting TABLE (Currency TINYINT, Bettype INT, MinBet MONEY)     
	   
	DECLARE @currency INT
          , @super    INT
          , @master   INT

    SELECT @currency = currency
         , @super = srecommend
         , @master = mrecommend
      FROM dbo.custInfo WITH(NOLOCK)
    WHERE custid = @custid	
	
	
	DECLARE @DocHandler INT	
	DECLARE @BetSetting TABLE(
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY, 
			MaxPayoutPerMatch MONEY
		);

	--Parse SB Bet Setting from XML
	IF ISNULL(@BetSettingXML,'') <> ''
	BEGIN
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @BetSettingXML

		INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT SportType        
			,BetType          
			,MinBet           
			,MaxBet           
			,MaxPerMatch      
			,MaxPerNumber     
			,MaxPayoutPerMatch
		FROM OPENXML (@DocHandler, '/Root/Row',1) 
		WITH (
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY, 
			MaxPayoutPerMatch MONEY
		) AS Data

		EXEC sp_xml_removedocument @DocHandler
	END
	ELSE
	BEGIN
		--Error Occurs
		SELECT @ErrCode=116
					
		RETURN
	END


	IF @roleid = 4
	BEGIN					
		INSERT INTO [dbo].[custsetting]([custId], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking ,[autompositiontaking],[autolivempositiontaking],[isautompositiontaking],[isautolivempositiontaking])
				SELECT @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1, @spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--1x2
		UNION ALL	SELECT @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, 0, 0, 0, @discount1x2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL	SELECT @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				
		UNION ALL	SELECT @custid, 9999, 1, @apositiontaking_9999, @mpositiontaking_9999, @spositiontaking_9999, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL	select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 2, @v2apositiontaking_10, @v2mpositiontaking_10, @v2spositiontaking_10,  0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 9999, 2, @v2apositiontaking_9999, @v2mpositiontaking_9999, @v2spositiontaking_9999, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL	SELECT @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 3, @v3apositiontaking_10, @v3mpositiontaking_10, @v3spositiontaking_10,  0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 9999, 5, @v5apositiontaking_9999, @v5mpositiontaking_9999, @v5spositiontaking_9999, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 5, @v5apositiontaking_10, @v5mpositiontaking_10, @v5spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 8, @v8apositiontaking_10, @v8mpositiontaking_10, @v8spositiontaking_10,0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 10, @v10apositiontaking_10, @v10mpositiontaking_10, @v10spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 11, @v11apositiontaking_10, @v11mpositiontaking_10, @v11spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 99, @v99apositiontaking_10, @v99mpositiontaking_10, @v99spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 9999, 99, @v99apositiontaking_9999, @v99mpositiontaking_9999, @v99spositiontaking_9999, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--Mix Sports Parlay
		UNION ALL	SELECT @custid, 9, 99, @v99apositiontaking_9, @v99mpositiontaking_9, @v99spositiontaking_9, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
					
			RETURN
		END		

		INSERT INTO [dbo].[custoverride]([custId], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		SELECT @custid, 1, 1, 0, @spositiontaking_1, 0, @slivepositiontaking_1
		UNION ALL SELECT @custid, 3, 1, 0, @spositiontaking_3, 0, @slivepositiontaking_3
		UNION ALL SELECT @custid, 7, 1, 0, @spositiontaking_7, 0, @slivepositiontaking_7
		UNION ALL SELECT @custid, 8, 1, 0, @spositiontaking_8, 0, @slivepositiontaking_8
		UNION ALL SELECT @custid, 2, 1, 0, @spositiontaking_2, 0, 0.93
		UNION ALL SELECT @custid, 4, 1, 0, @spositiontaking_4, 0, 0.93
		UNION ALL SELECT @custid, 5, 1, 0, @spositiontaking_5, 0, 0.93
		UNION ALL SELECT @custid, 6, 1, 0, @spositiontaking_6, 0, 0.93
		UNION ALL SELECT @custid, 9, 1, 0, @spositiontaking_9, 0, 0.93
		UNION ALL SELECT @custid, 10, 1, 0, @spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 2, 0, @v2spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 3, 0, @v3spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 5, 0, @v5spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 8, 0, @v8spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 10, 0, @v10spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 11, 0, @v11spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 10, 99, 0, @v99spositiontaking_10, 0, 0.93
		UNION ALL SELECT @custid, 9999, 1, 0, @spositiontaking_9999, 0, 0.93

		UNION ALL SELECT @custid, 1, 2, 0, @v2spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 2, 2, 0, @v2spositiontaking_2, 0, 0.93
		UNION ALL SELECT @custid, 3, 2, 0, @v2spositiontaking_3, 0, 0.93
		UNION ALL SELECT @custid, 7, 2, 0, @v2spositiontaking_7, 0, 0.93
		UNION ALL SELECT @custid, 8, 2, 0, @v2spositiontaking_8, 0, 0.93
		--UNION ALL select @custid, 9, 2, 0, @v2spositiontaking_9, 0, 0.93
		UNION ALL SELECT @custid, 20, 2, 0, @v2spositiontaking_20, 0, 0.93
		UNION ALL SELECT @custid, 9999, 2, 0, @v2spositiontaking_9999, 0, 0.93

		UNION ALL SELECT @custid, 1, 3, 0, @v3spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 2, 3, 0, @v3spositiontaking_2, 0, 0.93
		UNION ALL SELECT @custid, 3, 3, 0, @v3spositiontaking_3, 0, 0.93
		UNION ALL SELECT @custid, 20, 3, 0, @v3spositiontaking_20, 0, 0.93

		UNION ALL SELECT @custid, 1, 5, 0, @v5spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 2, 5, 0, @v5spositiontaking_2, 0, 0.93
		UNION ALL SELECT @custid, 3, 5, 0, @v5spositiontaking_3, 0, 0.93
		UNION ALL SELECT @custid, 20, 5, 0, @v5spositiontaking_20, 0, 0.93
		UNION ALL SELECT @custid, 9999, 5, 0, @v5spositiontaking_9999, 0, 0.93

		UNION ALL SELECT @custid, 1, 8, 0, @v8spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 3, 8, 0, @v8spositiontaking_3, 0, 0.93
		UNION ALL SELECT @custid, 20, 8, 0, @v8spositiontaking_20, 0, 0.93

		UNION ALL SELECT @custid, 1, 10, 0, @v10spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 2, 10, 0, @v10spositiontaking_2, 0, 0.93
		UNION ALL SELECT @custid, 3, 10, 0, @v10spositiontaking_3, 0, 0.93
		UNION ALL SELECT @custid, 20, 10, 0, @v10spositiontaking_20, 0, 0.93

		UNION ALL SELECT @custid, 1, 11, 0, @v11spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 20, 11, 0, @v11spositiontaking_20, 0, 0.93

		UNION ALL SELECT @custid, 1, 99, 0, @v99spositiontaking_1, 0, 0.93
		UNION ALL SELECT @custid, 2, 99, 0, @v99spositiontaking_2, 0, 0.93
		UNION ALL SELECT @custid, 3, 99, 0, @v99spositiontaking_3, 0, 0.93
		UNION ALL SELECT @custid, 9, 99, 0, @v99spositiontaking_9, 0, 0.93
		UNION ALL SELECT @custid, 20, 99, 0, @v99spositiontaking_20, 0, 0.93
		UNION ALL SELECT @custid, 9999, 99, 0, @v99spositiontaking_9999, 0, 0.93
	
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END							
				
	END--end roleid = 4
	ELSE IF @roleid = 3
	BEGIN			
		INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking] )
		select @custid, 1, 1, @spositiontaking_1, @mpositiontaking_1, 0, @slivepositiontaking_1, @mlivepositiontaking_1, 0, @auto_slivepositiontaking_1, @auto_spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_spositiontaking_1, @isauto_slivepositiontaking_1, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 1, @spositiontaking_3, @mpositiontaking_3, 0, @slivepositiontaking_3, @mlivepositiontaking_3, 0, @auto_slivepositiontaking_3, @auto_spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_spositiontaking_3, @isauto_slivepositiontaking_3, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 1, @spositiontaking_7, @mpositiontaking_7, 0, @slivepositiontaking_7, @mlivepositiontaking_7, 0, @auto_slivepositiontaking_7, @auto_spositiontaking_7, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_spositiontaking_7, @isauto_slivepositiontaking_7, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 1, @spositiontaking_8, @mpositiontaking_8, 0, @slivepositiontaking_8, @mlivepositiontaking_8, 0, @auto_slivepositiontaking_8, @auto_spositiontaking_8, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_spositiontaking_8, @isauto_slivepositiontaking_8, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 1, @spositiontaking_2, @mpositiontaking_2, 0, 0, 0, 0, 0, @auto_spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 4, 1, @spositiontaking_4, @mpositiontaking_4, 0, 0, 0, 0, 0, @auto_spositiontaking_4, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_spositiontaking_4, 0, 0, 0, 0, 0
		--1x2
		UNION ALL
		select @custid, 5, 1, @spositiontaking_5, @mpositiontaking_5, 0, 0, 0, 0, 0, @auto_spositiontaking_5, @discount1x2, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_spositiontaking_5, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 6, 1, @spositiontaking_6, @mpositiontaking_6, 0, 0, 0, 0, 0, @auto_spositiontaking_6, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_spositiontaking_6, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9, 1, @spositiontaking_9, @mpositiontaking_9, 0, 0, 0, 0, 0, @auto_spositiontaking_9, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_spositiontaking_9, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 1, @spositiontaking_10, @mpositiontaking_10, 0, 0, 0, 0, 0, @auto_spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_spositiontaking_10, 0, 0, 0, 0, 0
				
		UNION ALL
		select @custid, 9999, 1, @spositiontaking_9999, @mpositiontaking_9999, 0, 0, 0, 0, 0, @auto_spositiontaking_9999, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_spositiontaking_9999, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 1, 2, @v2spositiontaking_1, @v2mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v2spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v2spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 2, @v2spositiontaking_2, @v2mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v2spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v2spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 2, @v2spositiontaking_3, @v2mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v2spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v2spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 2, @v2spositiontaking_7, @v2mpositiontaking_7, 0, 0, 0, 0, 0, @auto_v2spositiontaking_7, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v2spositiontaking_7, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 2, @v2spositiontaking_8, @v2mpositiontaking_8, 0, 0, 0, 0, 0, @auto_v2spositiontaking_8, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v2spositiontaking_8, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 2, @v2spositiontaking_10, @v2mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v2spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v2spositiontaking_10, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 9, 2,   @v2spositiontaking_9,   @v2mpositiontaking_9,   0, 0, 0, 0, 0, @auto_v2spositiontaking_9,  @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v2spositiontaking_9, 0  , 0, 0, 0, 0
		--Get commission of Correct Score for MoneyLine
		UNION ALL
		select @custid, 20, 2, @v2spositiontaking_20, @v2mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v2spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v2spositiontaking_20, 0, 0, 0, 0, 0
		
		UNION ALL
		SELECT @custid, 9999, 2, @v2spositiontaking_9999, @v2mpositiontaking_9999, 0, 0, 0, 0, 0, @auto_v2spositiontaking_9999, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v2spositiontaking_9999, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 3, @v3spositiontaking_1, @v3mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v3spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v3spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 3, @v3spositiontaking_2, @v3mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v3spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v3spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 3, @v3spositiontaking_3, @v3mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v3spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v3spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 3, @v3spositiontaking_20, @v3mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v3spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v3spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 3, @v3spositiontaking_10, @v3mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v3spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v3spositiontaking_10, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 5, @v5spositiontaking_1, @v5mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v5spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v5spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 5, @v5spositiontaking_2, @v5mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v5spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v5spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 5, @v5spositiontaking_3, @v5mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v5spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v5spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 5, @v5spositiontaking_20, @v5mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v5spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v5spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9999, 5, @v5spositiontaking_9999, @v5mpositiontaking_9999, 0, 0, 0, 0, 0, @auto_v5spositiontaking_9999, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v5spositiontaking_9999, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 5, @v5spositiontaking_10, @v5mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v5spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v5spositiontaking_10, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 1, 8, @v8spositiontaking_1, @v8mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v8spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v8spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 8, @v8spositiontaking_3, @v8mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v8spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v8spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 8, @v8spositiontaking_20, @v8mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v8spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v8spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 8, @v8spositiontaking_10, @v8mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v8spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v8spositiontaking_10, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 10, @v10spositiontaking_1, @v10mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v10spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v10spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 10, @v10spositiontaking_2, @v10mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v10spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v10spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 10, @v10spositiontaking_3, @v10mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v10spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v10spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 10, @v10spositiontaking_20, @v10mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v10spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v10spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 10, @v10spositiontaking_10, @v10mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v10spositiontaking_10,  @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v10spositiontaking_10, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 11, @v11spositiontaking_1, @v11mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v11spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v11spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 11, @v11spositiontaking_20, @v11mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v11spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v11spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 11, @v11spositiontaking_10, @v11mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v11spositiontaking_10,  @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v11spositiontaking_10, 0, 0, 0, 0, 0

		--v99
		UNION ALL
		select @custid, 1, 99, @v99spositiontaking_1, @v99mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v99spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v99spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 99, @v99spositiontaking_2, @v99mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v99spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v99spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 99, @v99spositiontaking_3, @v99mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v99spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, 0, 0, @isauto_v99spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 99, @v99spositiontaking_20, @v99mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v99spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v99spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 99, @v99spositiontaking_10, @v99mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v99spositiontaking_10,  @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v99spositiontaking_10, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9999, 99, @v99spositiontaking_9999, @v99mpositiontaking_9999, 0, 0, 0, 0, 0, @auto_v99spositiontaking_9999,  @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v99spositiontaking_9999, 0, 0, 0, 0, 0
		-- mix parlay of mixed sports
		UNION ALL
		select @custid, 9, 99, @v99spositiontaking_9, @v99mpositiontaking_9, 0, 0, 0, 0, 0, @auto_v99spositiontaking_9, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, @isauto_v99spositiontaking_9, 0, 0, 0, 0, 0
	
		if @@Error <> 0
		BEGIN
			--Error Occurs	
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE [custsetting] with (ROWLOCK) where custid =  @custid
						
			return
		END		

		INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		select @custid, 1, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 7, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 8, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 4, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 5, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 6, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 8, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 11, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 1, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 7, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 8, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 2, 0, 0.93, 0, 0.93
		--UNION ALL select @custid, 9, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 2, 0, 0.93, 0, 0.93
		
		UNION ALL select @custid, 1, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 3, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 5, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 8, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 8, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 8, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 10, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 11, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 11, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 99, 0, 0.93, 0, 0.93
	
		if @@Error <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=118
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
						
			return
		END				
		     
	END--end roleid =3
	ELSE IF @roleid = 2
	BEGIN				
		INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking,[autopositiontaking],[autolivepositiontaking],[isautopositiontaking],[isautolivepositiontaking])
		select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1, 0, @alivepositiontaking_1, @mlivepositiontaking_1, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_mpositiontaking_1, @auto_mlivepositiontaking_1, @isauto_mpositiontaking_1, @isauto_mlivepositiontaking_1, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, 0, @alivepositiontaking_3, @mlivepositiontaking_3, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_mpositiontaking_3, @auto_mlivepositiontaking_3, @isauto_mpositiontaking_3, @isauto_mlivepositiontaking_3, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, 0, @alivepositiontaking_7, @mlivepositiontaking_7, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_mpositiontaking_7, @auto_mlivepositiontaking_7, @isauto_mpositiontaking_7, @isauto_mlivepositiontaking_7, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, 0, @alivepositiontaking_8, @mlivepositiontaking_8, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_mpositiontaking_8, @auto_mlivepositiontaking_8, @isauto_mpositiontaking_8, @isauto_mlivepositiontaking_8, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_mpositiontaking_2, 0, @isauto_mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_mpositiontaking_4, 0, @isauto_mpositiontaking_4, 0, 0 ,0 ,0 ,0
		--1x2
		UNION ALL
		select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, 0, 0, 0, 0, 0, @discount1x2, 0, 0, 0, 0, 0, 0, 0, 0, @auto_mpositiontaking_5, 0, @isauto_mpositiontaking_5, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_mpositiontaking_6, 0, @isauto_mpositiontaking_6, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_mpositiontaking_9, 0, @isauto_mpositiontaking_9, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_mpositiontaking_10, 0, @isauto_mpositiontaking_10, 0, 0 ,0 ,0 ,0
				
		UNION ALL
		select @custid, 9999, 1, @apositiontaking_9999, @mpositiontaking_9999, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_mpositiontaking_9999, 0, @isauto_mpositiontaking_9999, 0, 0 ,0 ,0 ,0
		
		UNION ALL
		select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v2mpositiontaking_1, 0, @isauto_v2mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v2mpositiontaking_2, 0, @isauto_v2mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v2mpositiontaking_3, 0, @isauto_v2mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v2mpositiontaking_7, 0, @isauto_v2mpositiontaking_7, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v2mpositiontaking_8, 0, @isauto_v2mpositiontaking_8, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 2, @v2apositiontaking_10, @v2mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v2mpositiontaking_10, 0, @isauto_v2mpositiontaking_10, 0, 0 ,0 ,0 ,0
		--UNION ALL
		--select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v2mpositiontaking_9, 0, @isauto_v2mpositiontaking_9, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v2mpositiontaking_20, 0, @isauto_v2mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 9999, 2, @v2apositiontaking_9999, @v2mpositiontaking_9999, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v2mpositiontaking_9999, 0, @isauto_v2mpositiontaking_9999, 0, 0 ,0 ,0 ,0
		
		UNION ALL
		select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v3mpositiontaking_1, 0, @isauto_v3mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v3mpositiontaking_2, 0, @isauto_v3mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v3mpositiontaking_3, 0, @isauto_v3mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v3mpositiontaking_20, 0, @isauto_v3mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 3, @v3apositiontaking_10, @v3mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v3mpositiontaking_10, 0, @isauto_v3mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v5mpositiontaking_1, 0, @isauto_v5mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v5mpositiontaking_2, 0, @isauto_v5mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v5mpositiontaking_3, 0, @isauto_v5mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v5mpositiontaking_20, 0, @isauto_v5mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 9999, 5, @v5apositiontaking_9999, @v5mpositiontaking_9999, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v5mpositiontaking_9999, 0, @isauto_v5mpositiontaking_9999, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 5, @v5apositiontaking_10, @v5mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v5mpositiontaking_10, 0, @isauto_v5mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v8mpositiontaking_1, 0, @isauto_v8mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v8mpositiontaking_3, 0, @isauto_v8mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v8mpositiontaking_20, 0, @isauto_v8mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 8, @v8apositiontaking_10, @v8mpositiontaking_10,   0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v8mpositiontaking_10, 0, @isauto_v8mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v10mpositiontaking_1, 0, @isauto_v10mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v10mpositiontaking_2, 0, @isauto_v10mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v10mpositiontaking_3, 0, @isauto_v10mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v10mpositiontaking_20, 0, @isauto_v10mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 10, @v10apositiontaking_10, @v10mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v10mpositiontaking_10, 0, @isauto_v10mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v11mpositiontaking_1, 0, @isauto_v11mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v11mpositiontaking_20, 0, @isauto_v11mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 11, @v11apositiontaking_10, @v11mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v11mpositiontaking_10, 0, @isauto_v11mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v99mpositiontaking_1, 0, @isauto_v99mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v99mpositiontaking_2, 0, @isauto_v99mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @auto_v99mpositiontaking_3, 0, @isauto_v99mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v99mpositiontaking_20, 0, @isauto_v99mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 99, @v99apositiontaking_10, @v99mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v99mpositiontaking_10, 0, @isauto_v99mpositiontaking_10, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 9999, 99, @v99apositiontaking_9999, @v99mpositiontaking_9999, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v99mpositiontaking_9999, 0, @isauto_v99mpositiontaking_9999, 0, 0 ,0 ,0 ,0
		--- mix parlay of mixed sports
		UNION ALL
		select @custid, 9, 99, @v99apositiontaking_9, @v99mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @auto_v99mpositiontaking_9, 0, @isauto_v99mpositiontaking_9, 0, 0 ,0 ,0 ,0

		if @@error <> 0
		BEGIN
			--Error occur	
			SELECT @ErrCode = 114
			
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			
			return
		END		

		INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		select @custid, 1, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 7, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 8, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 4, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 5, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 6, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 1, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 8, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 11, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 10, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 1, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 7, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 8, 2, 0, 0.93, 0, 0.93
		--UNION ALL select @custid, 9, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 2, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 2, 0, 0.93, 0, 0.93
		
		UNION ALL select @custid, 1, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 3, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 3, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 5, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 5, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 8, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 8, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 8, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 10, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 10, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 11, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 11, 0, 0.93, 0, 0.93

		UNION ALL select @custid, 1, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 2, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 3, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 20, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9999, 99, 0, 0.93, 0, 0.93
		UNION ALL select @custid, 9, 99, 0, 0.93, 0, 0.93

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 115
				
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			
			return
		END				

	END--end roleid =2
	ELSE IF @roleid = 1
	BEGIN			
		--print @v2mpositiontaking_20
		INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking  ,[autompositiontaking],[autolivempositiontaking],[isautompositiontaking],[isautolivempositiontaking])
		select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1,@spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--1x2
		UNION ALL
		select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, @playerdiscount1x2, @discount1x2, @adiscount1x2, @sdiscount1x2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 9999, 1, @apositiontaking_9999, @mpositiontaking_9999, @spositiontaking_9999, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 2, @v2apositiontaking_10, @v2mpositiontaking_10, @v2spositiontaking_10,0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 9999, 2, @v2apositiontaking_9999, @v2mpositiontaking_9999, @v2spositiontaking_9999, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
		UNION ALL
		select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 3, @v3apositiontaking_10, @v3mpositiontaking_10, @v3spositiontaking_10,0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9999, 5, @v5apositiontaking_9999, @v5mpositiontaking_9999, @v5spositiontaking_9999, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 5, @v5apositiontaking_10, @v5mpositiontaking_10, @v5spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 8, @v8apositiontaking_10, @v8mpositiontaking_10, @v8spositiontaking_10,0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 10, @v10apositiontaking_10, @v10mpositiontaking_10, @v10spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 11, @v11apositiontaking_10, @v11mpositiontaking_10, @v11spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9, 99, @v99apositiontaking_9, isnull(@v99mpositiontaking_9,0), isnull(@v99spositiontaking_9,0), 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9999, 99, @v99apositiontaking_9999, @v99mpositiontaking_9999, @v99spositiontaking_9999, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 99, @v99apositiontaking_10, @v99mpositiontaking_10, @v99spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		if @@Error <> 0
		BEGIN
			--Error occurs
			SELECT @ErrCode=215
			
			-- ROLLBACK MANUALLY
			Delete custsetting with (ROWLOCK) where custid  =@custid

			return
		END				
	END
	
	-- For Myanma Odds
	--DECLARE @DirectParentAgent INT 
	
	IF @roleid IN (2,3,4)
	BEGIN
		
		--IF @roleid = 2 
		--	SET @DirectParentAgent = @mrecommend 
		--IF @roleid = 3 
		--	SET @DirectParentAgent = @srecommend 
		---- For Myanma Odds
		--IF (@IsMyanmarOdds = 1 AND (@roleid = 4 OR EXISTS (SELECT 1 FROM AgentCommRate WITH (NOLOCK) WHERE CustID = @DirectParentAgent AND SportType = 1 AND Bettype = 1)))
		IF (@IsMyanmarOdds = 1)
		BEGIN
			INSERT INTO dbo.AgentCommRate (CustID,SportType,BetType,CommRate) 
			SELECT @custid,1,1,@discountMyanmarOdds
		END	
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid			
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END

		--Insert SportBook, Number Game bet setting 
		INSERT INTO CustBetSetting_Agent(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT @custid
			,SportType        
			,BetType          
			,MinBet           
			,MaxBet           
			,MaxPerMatch      
			,MaxPerNumber     
			,MaxPayoutPerMatch
		FROM @BetSetting

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid					
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustBetSetting_Agent WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END
	
	END
	IF @roleid = 1
	BEGIN
		IF (@IsMyanmarOdds = 1)
		BEGIN
			CREATE TABLE #CustCommRate_MOtemp (CustID INT, SportType SMALLINT, BetType SMALLINT,CommRate decimal(9,8),roleid TINYINT)
			
			INSERT INTO #CustCommRate_MOtemp(CustID,SportType,BetType,CommRate,roleid )
			SELECT @CustID AS CustID,AC.SportType,AC.BetType,AC.CommRate,CI.roleid 
			FROM AgentCommRate ac WITH (NOLOCK)
				JOIN custInfo ci WITH (NOLOCK) ON ac.CustID = ci.custid
			WHERE ac.CustID IN (@srecommend,@mrecommend,@recommend) AND ac.Sporttype = 1 AND ac.Bettype = 1
			
			INSERT INTO CustCommRate (CustID,SportType,BetType,sdiscount,adiscount,discount,playerdiscount)
			SELECT CustID,SportType,BetType,T.[4],T.[3],T.[2],@discountMyanmarOdds
			FROM #CustCommRate_MOtemp
			PIVOT(
				SUM(CommRate)
				FOR roleID IN ([2],[3],[4])
			) AS T
			
				
			IF @@ERROR <> 0
			BEGIN
				--Error Occurs
				SELECT @ErrCode=116
				
				-- ROLLBACK MANUALLY
				DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
				DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid							
				DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  = @custid
				DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
				
				RETURN
			END
		END

		--Insert SportBook, Number Game bet setting 
		INSERT INTO CustBetSetting_Member(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT @custid
			,SportType        
			,BetType          
			,MinBet           
			,MaxBet           
			,MaxPerMatch      
			,MaxPerNumber     
			,MaxPayoutPerMatch
		FROM @BetSetting

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
				
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid						
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  = @custid
			DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
			DELETE CustBetSetting_Member WITH (ROWLOCK) WHERE custId  = @custid
				
			RETURN
		END
		
	END
	
	--FOR Parlay Max Payout 
	IF @roleid IN (2,3,4)
	BEGIN
		IF @roleid = 4 
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM MaxPayoutGlobalSetting WITH(NOLOCK) WHERE Currency = @currency )
			BEGIN
				INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
				SELECT @custid , cs.SportType, cs.BetType, 
						cs.SingleMatchParlay,
						cs.Combo2,
						cs.Combo35,
						cs.ComboOver6
				FROM dbo.MaxPayoutGlobalSetting cs WITH(NOLOCK)
				WHERE cs.Currency = @currency AND cs.SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
				UNION 
				SELECT @custid , 1 AS SportType,9 AS BetType, 
						0.1 AS SingleMatchParlay,
						0.1 AS Combo2,
						0.1 AS Combo35,
						0.1 AS ComboOver6
				WHERE  NOT EXISTS(SELECT TOP 1 1 FROM MaxPayoutGlobalSetting WITH(NOLOCK) WHERE Currency = @currency AND SportType = 1 AND BetType = 9)	
				UNION 
				SELECT @custid , 99 AS SportType,9 AS BetType, 
						0.1 AS SingleMatchParlay,
						0.1 AS Combo2,
						0.1 AS Combo35,
						0.1 AS ComboOver6
				WHERE  NOT EXISTS(SELECT TOP 1 1 FROM MaxPayoutGlobalSetting WITH(NOLOCK) WHERE Currency = @currency AND SportType = 99 AND BetType = 9)							
			END
			ELSE
			BEGIN
				INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
				SELECT @custid , 1 AS SportType,9 AS BetType, 
						0.1 AS SingleMatchParlay,
						0.1 AS Combo2,
						0.1 AS Combo35,
						0.1 AS ComboOver6
				UNION 
				SELECT @custid , 99 AS SportType,9 AS BetType, 
						0.1 AS SingleMatchParlay,
						0.1 AS Combo2,
						0.1 AS Combo35,
						0.1 AS ComboOver6
			END
		END
		ELSE IF @roleid = 3
		BEGIN 
			INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					cs.SingleMatchParlay,
					cs.Combo2,
					cs.Combo35,
					cs.ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs  WITH(NOLOCK)
			WHERE cs.CustID = @srecommend
		END
		ELSE IF @roleid = 2
		BEGIN 
			INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					cs.SingleMatchParlay,
					cs.Combo2,
					cs.Combo35,
					cs.ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs  WITH(NOLOCK)
			WHERE cs.CustID = @mrecommend
		END
			
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid					
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustMaxPayoutSetting_Agent WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustBetSetting_Agent WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END
	
	END
	IF @roleid = 1
	BEGIN
		IF @isSearchAndCopy = 0
		BEGIN 
			INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					CASE WHEN cs.SingleMatchParlay = 0 THEN mps.SingleMatchParlay  ELSE cs.SingleMatchParlay END AS SingleMatchParlay, 
					CASE WHEN cs.Combo2 = 0 THEN mps.Combo2  ELSE cs.Combo2 END AS Combo2,
					CASE WHEN cs.Combo35 = 0 THEN mps.Combo35  ELSE cs.Combo35 END AS Combo35,
					CASE WHEN cs.ComboOver6 = 0 THEN mps.ComboOver6  ELSE cs.ComboOver6 END AS ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs  WITH(NOLOCK)
				LEFT JOIN MaxPayoutGlobalSetting mps WITH(NOLOCK) ON cs.BetType = mps.BetType  AND cs.SportType = mps.SportType AND mps.Currency = @currency
			WHERE cs.CustID = @recommend 		
		END
		ELSE
		BEGIN
			INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					CASE WHEN cs.SingleMatchParlay > upl.SingleMatchParlay  AND upl.SingleMatchParlay > 0 THEN upl.SingleMatchParlay ELSE cs.SingleMatchParlay END AS SingleMatchParlay,
					CASE WHEN cs.Combo2 > upl.Combo2  AND upl.Combo2 > 0 THEN upl.Combo2 ELSE cs.Combo2 END AS Combo2,
					CASE WHEN cs.Combo35 > upl.Combo35  AND upl.Combo35 > 0 THEN upl.Combo35 ELSE cs.Combo35 END AS Combo35,
					CASE WHEN cs.ComboOver6 > upl.ComboOver6  AND upl.ComboOver6 > 0 THEN upl.ComboOver6 ELSE cs.ComboOver6 END AS ComboOver6
			FROM dbo.CustMaxPayoutSetting_Member cs WITH (NOLOCK)
			INNER JOIN dbo.CustMaxPayoutSetting_Agent upl WITH (NOLOCK) ON cs.SportType = upl.SportType AND cs.BetType = upl.BetType
			WHERE cs.CustID  = @copyFromCustID  AND Upl.CustID = @recommend
		END	
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid				
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  = @custid
			DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
			DELETE CustMaxPayoutSetting_Member WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustBetSetting_Member WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END
		
	END
	
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
		IF(dbo.f_CheckRepTable('custSetting') = 1) DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('custOverride') = 1) DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid				
		IF(dbo.f_CheckRepTable('AgentCommRate') = 1) DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid		
		IF(dbo.f_CheckRepTable('CustCommRate') = 1) DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustBetSetting_Agent') = 1) DELETE CustBetSetting_Agent WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustBetSetting_Member') = 1) DELETE CustBetSetting_Member WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 1) DELETE CustMaxPayoutSetting_Member WITH (ROWLOCK) WHERE custId  = @custid
		IF(dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1) DELETE CustMaxPayoutSetting_Agent WITH (ROWLOCK) WHERE custId  = @custid
	END
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/	
END
GO