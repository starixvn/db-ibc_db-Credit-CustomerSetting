ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_00]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,
	@roleid INT,
 

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
	
	--HR Fixed Odds
	@v154spositiontaking_20 SMALLMONEY = 0,
	
	@v151spositiontaking_31 smallmoney = 0,
	@v151spositiontaking_32 smallmoney = 0,
	@v151spositiontaking_41 smallmoney = 0,
	@v151spositiontaking_42 smallmoney = 0,
	@v151spositiontaking_51 smallmoney = 0,
	@v151spositiontaking_52 smallmoney = 0,
	
	@v152spositiontaking_41 smallmoney = 0,
	@v152spositiontaking_42 smallmoney = 0,
	@v152spositiontaking_51 smallmoney = 0,
	@v152spositiontaking_52 smallmoney = 0,
	
	@v153spositiontaking_51 smallmoney = 0,
	@v153spositiontaking_52 smallmoney = 0,

	--v161
	@v161spositiontaking_81 SMALLMONEY = 0,
	@v161spositiontaking_83 SMALLMONEY = 0,
	--@v161spositiontaking_85 SMALLMONEY = 0,
	@v161spositiontaking_86 SMALLMONEY = 0,
	@v161spositiontaking_88 SMALLMONEY = 0,
	@v161slivepositiontaking_85 SMALLMONEY = 0,
	@v161slivepositiontaking_86 SMALLMONEY = 0,
	@v161slivepositiontaking_87 SMALLMONEY = 0,	
	@v161slivepositiontaking_89 SMALLMONEY = 0,
	@v161slivepositiontaking_90 SMALLMONEY = 0,
	
	@v162spositiontaking_1101 SMALLMONEY =0,
	@v255spositiontaking_1701 SMALLMONEY =0,

	@v180spositiontaking_1201 smallmoney = 0,
	@v181spositiontaking_1231 smallmoney = 0,
	@v182spositiontaking_1231 smallmoney = 0,
	@v183spositiontaking_1231 smallmoney = 0,
	@v184spositiontaking_1231 smallmoney = 0,
	@v185spositiontaking_1231 smallmoney = 0,
	@v186spositiontaking_1220 smallmoney = 0,
	

	--@v201spositiontaking_2 smallmoney = 0,
	--@v201spositiontaking_3 smallmoney = 0,

	@v202spositiontaking_1501 smallmoney = 0,
	@v202spositiontaking_1511 smallmoney = 0,
	@v202spositiontaking_1503 smallmoney = 0,
	@v202spositiontaking_1504 smallmoney = 0,
	@v202spositiontaking_1505 smallmoney = 0,
	@v202spositiontaking_1513 smallmoney = 0,
	@v202spositiontaking_1507 smallmoney = 0,
	@v202spositiontaking_1508 smallmoney = 0,
	@v202spositiontaking_1509 smallmoney = 0,
	@v202spositiontaking_1514 smallmoney = 0,
	---
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

	@auto_v99spositiontaking_9 smallmoney = 0,
	
	--HR Fixed Odds
	@auto_v154spositiontaking_20 SMALLMONEY = 0,
	
	@auto_v161spositiontaking_81 smallmoney = 0,            
	@auto_v161spositiontaking_83 smallmoney = 0,
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,
	
	--n4 vs
	@min_v180spositiontaking_1201 smallmoney = 0,	 --VS
	@min_v181spositiontaking_1231 smallmoney = 0,
	@min_v182spositiontaking_1231 smallmoney = 0,
	@min_v183spositiontaking_1231 smallmoney = 0,
	@min_v184spositiontaking_1231 smallmoney = 0,
	@min_v185spositiontaking_1231 smallmoney = 0,
	@min_v186spositiontaking_1220 smallmoney = 0,
	


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

	@isauto_v99spositiontaking_9 BIT = 0,
	
	@isauto_v154spositiontaking_20 BIT = 0,
	
	@isauto_v161spositiontaking_81 BIT = 0,					
	@isauto_v161spositiontaking_83 BIT = 0,
	@isauto_v161spositiontaking_86 BIT = 0,
	@isauto_v161spositiontaking_88 BIT = 0,
	
	@isauto_v161slivepositiontaking_85 BIT = 0,
	@isauto_v161slivepositiontaking_86 BIT = 0,
	@isauto_v161slivepositiontaking_87 BIT = 0,
	@isauto_v161slivepositiontaking_89 BIT = 0,
	@isauto_v161slivepositiontaking_90 BIT = 0,
	
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
	
	--HR Fixed Odds
	@v154mpositiontaking_20 SMALLMONEY = 0,
	
	@v151mpositiontaking_31 smallmoney = 0,
	@v151mpositiontaking_32 smallmoney = 0,
	@v151mpositiontaking_41 smallmoney = 0,
	@v151mpositiontaking_42 smallmoney = 0,
	@v151mpositiontaking_51 smallmoney = 0,
	@v151mpositiontaking_52 smallmoney = 0,
	
	@v152mpositiontaking_41 smallmoney = 0,
	@v152mpositiontaking_42 smallmoney = 0,
	@v152mpositiontaking_51 smallmoney = 0,
	@v152mpositiontaking_52 smallmoney = 0,
	
	@v153mpositiontaking_51 smallmoney = 0,
	@v153mpositiontaking_52 smallmoney = 0,

	--v161
	@v161mpositiontaking_81 SMALLMONEY = 0,
	@v161mpositiontaking_83 SMALLMONEY = 0,
	--@v161mpositiontaking_85 SMALLMONEY = 0,
	@v161mpositiontaking_86 SMALLMONEY = 0,
	@v161mpositiontaking_88 SMALLMONEY = 0,
	@v161mlivepositiontaking_85 SMALLMONEY = 0,
	@v161mlivepositiontaking_86 SMALLMONEY = 0,
	@v161mlivepositiontaking_87 SMALLMONEY = 0,
	@v161mlivepositiontaking_89 SMALLMONEY = 0,
	@v161mlivepositiontaking_90 SMALLMONEY =0,
	
	@v162mpositiontaking_1101 SMALLMONEY =0,
	@v255mpositiontaking_1701 SMALLMONEY =0,

	@v180mpositiontaking_1201 smallmoney = 0,
	@v181mpositiontaking_1231 smallmoney = 0,
	@v182mpositiontaking_1231 smallmoney = 0,
	@v183mpositiontaking_1231 smallmoney = 0,
	@v184mpositiontaking_1231 smallmoney = 0,
	@v185mpositiontaking_1231 smallmoney = 0,
	@v186mpositiontaking_1220 smallmoney = 0,
	

	--@v201mpositiontaking_2 smallmoney = 0,
	--@v201mpositiontaking_3 smallmoney = 0,

	@v202mpositiontaking_1501 smallmoney = 0,
	@v202mpositiontaking_1511 smallmoney = 0,
	@v202mpositiontaking_1503 smallmoney = 0,
	@v202mpositiontaking_1504 smallmoney = 0,
	@v202mpositiontaking_1505 smallmoney = 0,
	@v202mpositiontaking_1513 smallmoney = 0,
	@v202mpositiontaking_1507 smallmoney = 0,
	@v202mpositiontaking_1508 smallmoney = 0,
	@v202mpositiontaking_1509 smallmoney = 0,
	@v202mpositiontaking_1514 smallmoney = 0,
	---
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

	-- mix parlay of mixed sports
	@auto_v99mpositiontaking_9 smallmoney = 0,
	
	--HR Fixed Odds
	@auto_v154mpositiontaking_20 SMALLMONEY = 0,
	
	-- number game
	@auto_v161mpositiontaking_81 smallmoney = 0,
	@auto_v161mpositiontaking_83 smallmoney = 0,
	--@auto_v161mpositiontaking_85 smallmoney = 0,
	@auto_v161mpositiontaking_86 smallmoney = 0,
	@auto_v161mpositiontaking_88 smallmoney = 0,
	
	@auto_v161mlivepositiontaking_85 smallmoney = 0,
	@auto_v161mlivepositiontaking_86 smallmoney = 0,
	@auto_v161mlivepositiontaking_87 smallmoney = 0,
	@auto_v161mlivepositiontaking_89 smallmoney = 0,
	@auto_v161mlivepositiontaking_90 smallmoney = 0,
		
	@min_v180mpositiontaking_1201 smallmoney = 0,--VS
	@min_v181mpositiontaking_1231 smallmoney = 0,
	@min_v182mpositiontaking_1231 smallmoney = 0,
	@min_v183mpositiontaking_1231 smallmoney = 0,
	@min_v184mpositiontaking_1231 smallmoney = 0,
	@min_v185mpositiontaking_1231 smallmoney = 0,
	@min_v186mpositiontaking_1220 smallmoney = 0,
	

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

	--- mix parlay of mixed sports
	@isauto_v99mpositiontaking_9 BIT = 0,
	@isauto_v154mpositiontaking_20 BIT = 0,
	
	-- number game
	@isauto_v161mpositiontaking_81 BIT = 0,
	@isauto_v161mpositiontaking_83 BIT = 0,
	--@isauto_v161mpositiontaking_85 BIT = 0,
	@isauto_v161mpositiontaking_86 BIT = 0,
	@isauto_v161mpositiontaking_88 BIT = 0,
	
	@isauto_v161mlivepositiontaking_85 BIT = 0,
	@isauto_v161mlivepositiontaking_86 BIT = 0,	
	@isauto_v161mlivepositiontaking_87  BIT = 0,
	@isauto_v161mlivepositiontaking_89  BIT = 0,
	@isauto_v161mlivepositiontaking_90  BIT = 0,
		
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
	
	--HR Fixed Odds
	@v154apositiontaking_20 SMALLMONEY = 0,
	
	--v161
	@v161apositiontaking_81 SMALLMONEY = 0,
	@v161apositiontaking_83 SMALLMONEY = 0,
	--@v161apositiontaking_85 SMALLMONEY = 0,
	@v161apositiontaking_86 SMALLMONEY = 0,
	@v161apositiontaking_88 SMALLMONEY = 0,
	@v161alivepositiontaking_85 SMALLMONEY = 0,
	@v161alivepositiontaking_86 SMALLMONEY = 0,
	@v161alivepositiontaking_87 SMALLMONEY = 0,
	@v161alivepositiontaking_89 SMALLMONEY = 0,
	@v161alivepositiontaking_90 SMALLMONEY = 0,
	
	@v162apositiontaking_1101 SMALLMONEY = 0,
	@v255apositiontaking_1701 SMALLMONEY = 0,

	@v180apositiontaking_1201 SMALLMONEY = 0,
	@v181apositiontaking_1231 SMALLMONEY = 0,
	@v182apositiontaking_1231 SMALLMONEY = 0,
	@v183apositiontaking_1231 SMALLMONEY = 0,
	@v184apositiontaking_1231 SMALLMONEY = 0,
	@v185apositiontaking_1231 SMALLMONEY = 0,
	@v186apositiontaking_1220 SMALLMONEY = 0,
							  
	@v202apositiontaking_1501 SMALLMONEY = 0,
	@v202apositiontaking_1511 SMALLMONEY = 0,
	@v202apositiontaking_1503 SMALLMONEY = 0,
	@v202apositiontaking_1504 SMALLMONEY = 0,
	@v202apositiontaking_1505 SMALLMONEY = 0,
	@v202apositiontaking_1513 SMALLMONEY = 0,
	@v202apositiontaking_1507 SMALLMONEY = 0,
	@v202apositiontaking_1508 SMALLMONEY = 0,
	@v202apositiontaking_1509 SMALLMONEY = 0,
	@v202apositiontaking_1514 SMALLMONEY = 0,
	
	@MinBet MONEY = 0,
	@MaxBet MONEY = 0,	
	@MinBetv2 MONEY = 0,
	@MaxBetv2 MONEY = 0,		
	@MinBetv3 MONEY = 0,
	@MaxBetv3 MONEY = 0,	
	@MinBetv5 MONEY = 0,
	@MaxBetv5 MONEY = 0,	
	@MinBetv8 MONEY = 0,
	@MaxBetv8 MONEY = 0,	
	@MinBetv10 MONEY = 0,
	@MaxBetv10 MONEY = 0,	
	@MinBetv11 MONEY = 0,
	@MaxBetv11 MONEY = 0,	
	@MinBetv99 MONEY = 0,
	@MaxBetv99 MONEY = 0,		
	--Mix Parlay mix sports
	@MinBetv99MP MONEY = 0,
	@MaxBetv99MP MONEY = 0,		
	
	--Mix Parlay soccer sports
	@MinBetv1MP MONEY = 0,
	@MaxBetv1MP MONEY = 0,		
	
	--HR Fixed Odds
	@MinBetv154 MONEY = 0,
	@MaxBetv154 MONEY = 0,		
	--Number game
	@MinBetv161 MONEY = 0,
	@MaxBetv161 MONEY = 0,	
	
	@minbetv180 money = 0,
	@maxbetv180 money = 0,
	@minbetv181 money = 0,
	@maxbetv181 money = 0,
	@minbetv182 money = 0,
	@maxbetv182 money = 0,
	@minbetv183 money = 0,
	@maxbetv183 money = 0,
	@minbetv184 money = 0,
	@maxbetv184 money = 0,
	@minbetv185 money = 0,
	@maxbetv185 money = 0,
	@minbetv186 money = 0,
	@maxbetv186 money = 0,
	

	@discount decimal(9,8)= 0,	
	@discountcs DECIMAL(9,8)=0, 
	--comm 1x2
	@discount1x2 DECIMAL(9,8)=0,
	@discountnumber DECIMAL(9,8)=0,
	
	@playerdiscount decimal(9,8) = 0, 
	@playerdiscountcs decimal(9,8) = 0,
	--1x2 
	@playerdiscount1x2 decimal(9,8)=0,	
	
	@playerdiscountnumber decimal(9,8)=0,
	@playerdiscountHRFixedOdds decimal(9,8)=0,
	
	@v151playerdiscount_31 decimal(9,8) = 0,
	@v151playerdiscount_41 decimal(9,8) = 0,
	@v151playerdiscount_51 decimal(9,8) = 0,
	@v152playerdiscount_41 decimal(9,8) = 0,
	@v152playerdiscount_51 decimal(9,8) = 0,
	@v153playerdiscount_51 decimal(9,8) = 0,
		
	@adiscount decimal(9,8) = 0,
	@adiscountcs decimal(9,8) = 0,
	@adiscount1x2 decimal(9,8) = 0,
	@adiscountnumber decimal(9,8) = 0,
	
	@sdiscount decimal(9,8) = 0,		
	@sdiscountcs decimal(9,8) = 0,	
	@sdiscount1x2 decimal(9,8) = 0,	
	@sdiscountnumber decimal(9,8) = 0,
	
	--v151
	@v151discount_31 decimal(9,8) = 0,
	@v151adiscount_31 decimal(9,8) = 0,
	@v151sdiscount_31 decimal(9,8) = 0,
	
	@v151discount_41 decimal(9,8) = 0,
	@v151adiscount_41 decimal(9,8) = 0,
	@v151sdiscount_41 decimal(9,8) = 0,
	
	@v151discount_51 decimal(9,8) = 0,
	@v151adiscount_51 decimal(9,8) = 0,
	@v151sdiscount_51 decimal(9,8) = 0,
	
	--v152
	@v152discount_41 decimal(9,8) = 0,
	@v152adiscount_41 decimal(9,8) = 0,
	@v152sdiscount_41 decimal(9,8) = 0,
	
	@v152discount_51 decimal(9,8) = 0,
	@v152adiscount_51 decimal(9,8) = 0,
	@v152sdiscount_51 decimal(9,8) = 0,
	
	--v153
	@v153discount_51 decimal(9,8) = 0,
	@v153adiscount_51 decimal(9,8) = 0,
	@v153sdiscount_51 decimal(9,8) = 0,
	
	--v201
	--@v201discount decimal(9,8) = 0,
	--@v201adiscount decimal(9,8) = 0,
	--@v201sdiscount decimal(9,8) = 0,
	
	--v202
	@v202discount_1501 decimal(9,8) = 0,
	@v202discount_1511 decimal(9,8) = 0,
	@v202discount_1503 decimal(9,8) = 0,
	@v202discount_1504 decimal(9,8) = 0,
	@v202discount_1505 decimal(9,8) = 0,
	@v202discount_1513 decimal(9,8) = 0,
	@v202discount_1507 decimal(9,8) = 0,
	@v202discount_1508 decimal(9,8) = 0,
	@v202discount_1509 decimal(9,8) = 0,
	@v202discount_1514 decimal(9,8) = 0,
	
	@v202adiscount_1501 decimal(9,8) = 0,
	@v202adiscount_1511 decimal(9,8) = 0,
	@v202adiscount_1503 decimal(9,8) = 0,
	@v202adiscount_1504 decimal(9,8) = 0,
	@v202adiscount_1505 decimal(9,8) = 0,
	@v202adiscount_1513 decimal(9,8) = 0,
	@v202adiscount_1507 decimal(9,8) = 0,
	@v202adiscount_1508 decimal(9,8) = 0,
	@v202adiscount_1509 decimal(9,8) = 0,
	@v202adiscount_1514 decimal(9,8) = 0,
	
	@v202sdiscount_1501 decimal(9,8) = 0,
	@v202sdiscount_1511 decimal(9,8) = 0,
	@v202sdiscount_1503 decimal(9,8) = 0,
	@v202sdiscount_1504 decimal(9,8) = 0,
	@v202sdiscount_1505 decimal(9,8) = 0,
	@v202sdiscount_1513 decimal(9,8) = 0,
	@v202sdiscount_1507 decimal(9,8) = 0,
	@v202sdiscount_1508 decimal(9,8) = 0,
	@v202sdiscount_1509 decimal(9,8) = 0,
	@v202sdiscount_1514 decimal(9,8) = 0,

	--v162
	@v162discount_1101 decimal(9,8) = 0,
	@v162adiscount_1101 decimal(9,8) = 0,
	@v162sdiscount_1101 decimal(9,8) = 0,
	
	--v255
	@v255discount_1701 decimal(9,8) = 0,
	@v255adiscount_1701 decimal(9,8) = 0,
	@v255sdiscount_1701 decimal(9,8) = 0,

	--v154
	@discountHRFixedOdds decimal(9,8) = 0,
	@adiscountHRFixedOdds decimal(9,8) = 0,
	@sdiscountHRFixedOdds decimal(9,8) = 0,
	
	-- Myanma Odds
	@discountMyanmarOdds DECIMAL(9,8) = 0,
	@IsMyanmarOdds BIT = 0,
	
	@UplineSyncLiveCasino BIT = 0,
	
	@ErrCode INT = 0 OUTPUT
	
 AS
	/*
		Created: Johnson
		Date: 20131106
		Task: Apply execrep when insert into custsetting/custsetting3rd
		DB: DBCUST/CustDB
		
		Revisions:
			- 20131120@Kathy: Add Virtual Greyhounds, Virtual Motor Racing (182, 184) [Redmine:#7234]. Refer to Sps:
				+ Acc_CustomerInsMemb
				+ Acc_CustomerInsMember_SAg_xtest
				+ Acc_CustomerInsMember_MAg_xtest
				+ Acc_CustomerInsMember_Ag_xtest
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
		Parameter's Explanation:
		
	*/
BEGIN
    SET NOCOUNT ON
			
     if (dbo.f_CheckRepTable('CustSetting') = 1 
		  AND dbo.f_CheckRepTable('CustOverride') = 1 
		  AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
		  AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
		  AND dbo.f_CheckRepTable('CustSettingGame') = 1 
		  AND dbo.f_CheckRepTable('CustOverrideGame') = 1 
		  AND dbo.f_CheckRepTable('CustGameType') = 1
		  AND dbo.f_CheckRepTable('ProductGlobalSetting') = 1 
		  AND dbo.f_CheckRepTable('ProductBetSetting') = 1 
		  AND dbo.f_CheckRepTable('AgentCommRate') = 1
		 AND dbo.f_CheckRepTable('CustCommRate') = 1
		  --AND dbo.f_CheckRepTable('P2PGAMESETTING') = 1 
		  --AND dbo.f_CheckRepTable('P2PGroupComm') = 1		  
	   )
	BEGIN

    DECLARE @tmp_GameType TABLE (GameTypeID INT, IBCBettypeID INT)
    DECLARE @ProductGlobalSetting TABLE (Sporttype INT, Bettype INT, MaxPositiontaking SMALLMONEY, IsDep BIT)
    DECLARE @ProductBetSetting TABLE (Currency TINYINT, Bettype INT, MinBet MONEY)
    
    IF(dbo.f_CheckRepTable('GameType') = 1)
	   INSERT INTO @tmp_GameType (GameTypeID, IBCBettypeID)
	   SELECT GameTypeID, IBCBettypeID FROM GameType WITH (NOLOCK)
    ELSE
	   BEGIN TRY		
		  INSERT INTO @tmp_GameType (GameTypeID, IBCBettypeID)
		  SELECT GameTypeID, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	   END TRY
	   BEGIN CATCH		
		  INSERT INTO @tmp_GameType (GameTypeID, IBCBettypeID)
		  SELECT GameTypeID, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	   END CATCH
   
	   
	DECLARE @currency INT
          , @super    INT
          , @master   INT

    SELECT @currency = currency
         , @super = srecommend
         , @master = mrecommend
      FROM dbo.custInfo WITH(NOLOCK)
    WHERE custid = @custid		

	IF @roleid = 4
	BEGIN					
		INSERT INTO [dbo].[custsetting]([custId], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], [Minbet], [Maxbet], autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking ,[autompositiontaking],[autolivempositiontaking],[isautompositiontaking],[isautolivempositiontaking])
				SELECT @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1, @spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0

		--1x2
		UNION ALL	SELECT @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, 0, 0, 0, @discount1x2, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv1MP, @MaxBetv1MP, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL	SELECT @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
				
		UNION ALL	SELECT @custid, 9999, 1, @apositiontaking_9999, @mpositiontaking_9999, @spositiontaking_9999, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL	select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 2, @v2apositiontaking_10, @v2mpositiontaking_10, @v2spositiontaking_10,  0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 3, @v3apositiontaking_10, @v3mpositiontaking_10, @v3spositiontaking_10,  0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 9999, 5, @v5apositiontaking_9999, @v5mpositiontaking_9999, @v5spositiontaking_9999, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 5, @v5apositiontaking_10, @v5mpositiontaking_10, @v5spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 8, @v8apositiontaking_10, @v8mpositiontaking_10, @v8spositiontaking_10,0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 10, @v10apositiontaking_10, @v10mpositiontaking_10, @v10spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 11, @v11apositiontaking_10, @v11mpositiontaking_10, @v11spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL	SELECT @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0,0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 10, 99, @v99apositiontaking_10, @v99mpositiontaking_10, @v99spositiontaking_10, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		--Mix Sports Parlay
		UNION ALL	SELECT @custid, 9, 99, @v99apositiontaking_9, @v99mpositiontaking_9, @v99spositiontaking_9, 0,0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, @MinBetv99MP, @MaxBetv99MP, 0, 0, 0, 0, 0, 0, 0, 0
		
		--HR Fixed Odds
		UNION ALL	SELECT @custid, 20, 154, ISNULL(@v154apositiontaking_20,0), ISNULL(@v154mpositiontaking_20,0), ISNULL(@v154spositiontaking_20,0), 0, 0, 0, 0, 0, 0, ISNULL(@discountHRFixedOdds,0), 0, 0, 0, 0, 0, 0, ISNULL(@MinBetv154,0), ISNULL(@MaxBetv154,0), 0, 0, 0, 0, 0, 0, 0, 0

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
					
			RETURN
		END

		--insert into CustSetting3rd
		INSERT INTO [dbo].[CustSetting3rd]([custId], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking],  [playerdiscount], [discount], [adiscount], [sdiscount], [Minbet], [Maxbet], autopositiontaking, isautopositiontaking, alivepositiontaking, mlivepositiontaking, slivepositiontaking, autolivepositiontaking, isautolivepositiontaking,[autompositiontaking],[isautompositiontaking],[autolivempositiontaking],[isautolivempositiontaking])
		--			SELECT @custid, 2, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL	SELECT @custid, 3, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--v151
					SELECT @custid, 31, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 32, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 41, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 42, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 51, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 52, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--v152
		UNION ALL	SELECT @custid, 41, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 42, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 51, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 52, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--v153
		UNION ALL	SELECT @custid, 51, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 52, 153, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--v161
		UNION ALL	SELECT @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, @v161spositiontaking_81, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, @v161spositiontaking_83, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 85, 161, 0, 0, 0, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_85, @v161mlivepositiontaking_85, @v161slivepositiontaking_85, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, @v161spositiontaking_86, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_86, @v161mlivepositiontaking_86, @v161slivepositiontaking_86, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 87, 161, 0, 0, 0, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_87, @v161mlivepositiontaking_87, @v161slivepositiontaking_87, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 88, 161, @v161apositiontaking_88, @v161mpositiontaking_88, @v161spositiontaking_88, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 89, 161, 0, 0, 0, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_89, @v161mlivepositiontaking_89, @v161slivepositiontaking_89, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 90, 161, 0, 0, 0, 0, 0, 0, @discountnumber, @MinBetv161, @MaxBetv161, 0, 0, @v161alivepositiontaking_90, @v161mlivepositiontaking_90, @v161slivepositiontaking_90, 0, 0, 0, 0, 0, 0
		-- v18x
		UNION ALL	SELECT @custid, 1201, 180, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 1231, 181, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 1231, 182, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 1231, 183, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 1231, 184, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 1231, 185, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL	SELECT @custid, 1220, 186, 0.9, 0.9, 0.9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END

		INSERT INTO [dbo].[custoverride]([custId], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		SELECT @custid, 1, 1, 0, @spositiontaking_1, 0, @slivepositiontaking_1
		UNION ALL SELECT @custid, 3, 1, 0, @spositiontaking_3, 0, @slivepositiontaking_3
		UNION ALL SELECT @custid, 7, 1, 0, @spositiontaking_7, 0, @slivepositiontaking_7
		UNION ALL SELECT @custid, 8, 1, 0, @spositiontaking_8, 0, @slivepositiontaking_8
		UNION ALL SELECT @custid, 2, 1, 0, @spositiontaking_2, 0, 0.9
		UNION ALL SELECT @custid, 4, 1, 0, @spositiontaking_4, 0, 0.9
		UNION ALL SELECT @custid, 5, 1, 0, @spositiontaking_5, 0, 0.9
		UNION ALL SELECT @custid, 6, 1, 0, @spositiontaking_6, 0, 0.9
		UNION ALL SELECT @custid, 9, 1, 0, @spositiontaking_9, 0, 0.9
		UNION ALL SELECT @custid, 10, 1, 0, @spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 2, 0, @v2spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 3, 0, @v3spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 5, 0, @v5spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 8, 0, @v8spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 10, 0, @v10spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 11, 0, @v11spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 10, 99, 0, @v99spositiontaking_10, 0, 0.9
		UNION ALL SELECT @custid, 9999, 1, 0, @spositiontaking_9999, 0, 0.9

		UNION ALL SELECT @custid, 1, 2, 0, @v2spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 2, 2, 0, @v2spositiontaking_2, 0, 0.9
		UNION ALL SELECT @custid, 3, 2, 0, @v2spositiontaking_3, 0, 0.9
		UNION ALL SELECT @custid, 7, 2, 0, @v2spositiontaking_7, 0, 0.9
		UNION ALL SELECT @custid, 8, 2, 0, @v2spositiontaking_8, 0, 0.9
		--UNION ALL select @custid, 9, 2, 0, @v2spositiontaking_9, 0, 0.9
		UNION ALL SELECT @custid, 20, 2, 0, @v2spositiontaking_20, 0, 0.9

		UNION ALL SELECT @custid, 1, 3, 0, @v3spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 2, 3, 0, @v3spositiontaking_2, 0, 0.9
		UNION ALL SELECT @custid, 3, 3, 0, @v3spositiontaking_3, 0, 0.9
		UNION ALL SELECT @custid, 20, 3, 0, @v3spositiontaking_20, 0, 0.9

		UNION ALL SELECT @custid, 1, 5, 0, @v5spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 2, 5, 0, @v5spositiontaking_2, 0, 0.9
		UNION ALL SELECT @custid, 3, 5, 0, @v5spositiontaking_3, 0, 0.9
		UNION ALL SELECT @custid, 20, 5, 0, @v5spositiontaking_20, 0, 0.9
		UNION ALL SELECT @custid, 9999, 5, 0, @v5spositiontaking_9999, 0, 0.9

		UNION ALL SELECT @custid, 1, 8, 0, @v8spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 3, 8, 0, @v8spositiontaking_3, 0, 0.9
		UNION ALL SELECT @custid, 20, 8, 0, @v8spositiontaking_20, 0, 0.9

		UNION ALL SELECT @custid, 1, 10, 0, @v10spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 2, 10, 0, @v10spositiontaking_2, 0, 0.9
		UNION ALL SELECT @custid, 3, 10, 0, @v10spositiontaking_3, 0, 0.9
		UNION ALL SELECT @custid, 20, 10, 0, @v10spositiontaking_20, 0, 0.9

		UNION ALL SELECT @custid, 1, 11, 0, @v11spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 20, 11, 0, @v11spositiontaking_20, 0, 0.9

		UNION ALL SELECT @custid, 1, 99, 0, @v99spositiontaking_1, 0, 0.9
		UNION ALL SELECT @custid, 2, 99, 0, @v99spositiontaking_2, 0, 0.9
		UNION ALL SELECT @custid, 3, 99, 0, @v99spositiontaking_3, 0, 0.9
		UNION ALL SELECT @custid, 9, 99, 0, @v99spositiontaking_9, 0, 0.9
		UNION ALL SELECT @custid, 20, 99, 0, @v99spositiontaking_20, 0, 0.9
		UNION ALL SELECT @custid, 20, 154, 0, ISNULL(@v154spositiontaking_20,0), 0, 0.9


		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END

		-- Insert Into CustOverride3rd
		INSERT INTO [dbo].[CustOverride3rd]([custId], [bettype], [sporttype], minpositiontaking, maxpositiontaking,minlivepositiontaking,maxlivepositiontaking)
		--SELECT @custid, 2, 201, 0, 0.5, 0, 0.9
		--UNION ALL SELECT @custid, 3, 201, 0, 0.5, 0, 0.9
		--v151 
				  SELECT @custid, 31, 151, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 32, 151, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 41, 151, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 42, 151, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 51, 151, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 52, 151, 0, 0.5, 0, 0.9
		--v152
		UNION ALL SELECT @custid, 41, 152, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 42, 152, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 51, 152, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 52, 152, 0, 0.5, 0, 0.9
		--v153
		UNION ALL SELECT @custid, 51, 153, 0, 0.5, 0, 0.9
		UNION ALL SELECT @custid, 52, 153, 0, 0.5, 0, 0.9
		--v161
		UNION ALL SELECT @custid, 81, 161, 0, @v161spositiontaking_81, 0, 0.9
		UNION ALL SELECT @custid, 83, 161, 0, @v161spositiontaking_83, 0, 0.9
		UNION ALL SELECT @custid, 85, 161, 0, 0.9, 0, @v161slivepositiontaking_85
		UNION ALL SELECT @custid, 86, 161, 0, @v161spositiontaking_86, 0, @v161slivepositiontaking_86
		UNION ALL SELECT @custid, 87, 161, 0, 0.9, 0, @v161slivepositiontaking_87
		UNION ALL SELECT @custid, 88, 161, 0, @v161spositiontaking_88, 0, 0.9
		UNION ALL SELECT @custid, 89, 161, 0, 0.9, 0, @v161slivepositiontaking_89
		UNION ALL SELECT @custid, 90, 161, 0, 0.9, 0, @v161slivepositiontaking_90
		--v18x
		UNION ALL SELECT @custid, 1201, 180, 0, 0.9, 0, 0.9
		UNION ALL SELECT @custid, 1231, 181, 0, 0.9, 0, 0.9
		UNION ALL SELECT @custid, 1231, 182, 0, 0.9, 0, 0.9
		UNION ALL SELECT @custid, 1231, 183, 0, 0.9, 0, 0.9
		UNION ALL SELECT @custid, 1231, 184, 0, 0.9, 0, 0.9
		UNION ALL SELECT @custid, 1231, 185, 0, 0.9, 0, 0.9
		UNION ALL SELECT @custid, 1220, 186, 0, 0.9, 0, 0.9
		

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END

		--Insert Into P2P Setting
		INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
			(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
		SELECT @custid  , 1001 , 1 , 0 , 0 , 0 , 0
		UNION ALL SELECT @custid  , 1002 , 1 , 0 , 0 , 0 , 0

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END  

		INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
				   (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
		SELECT @custid  , 1 , 0 , 0 , 0 , 0 
		UNION ALL SELECT @custid  , 2 , 0 , 0 , 0 , 0 

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END           
		
		--Insert live casino, Keno, GoldDeluxe setting
		INSERT INTO CustSettingGame([CustID]
				   ,[Bettype]
				   ,[Sporttype]
				   ,[apositiontaking]
				   ,[mpositiontaking]
				   ,[spositiontaking]
				   ,[playerdiscount]
				   ,[discount]
				   ,[adiscount]
				   ,[sdiscount]
				   ,[autopositiontaking]
				   ,[isautopositiontaking]
				   ,[autompositiontaking]
				   ,[isautompositiontaking])
		SELECT @custid , 1101, 162, 0, 0, 0.9, 0, 0, 0, 0, 0, 0 ,0 ,0		
		UNION ALL SELECT @custid , 1501, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1501
		UNION ALL SELECT @custid , 1511, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1511
		UNION ALL SELECT @custid , 1503, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1503
		UNION ALL SELECT @custid , 1504, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1504
		UNION ALL SELECT @custid , 1505, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1505
		UNION ALL SELECT @custid , 1513, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1513
		UNION ALL SELECT @custid , 1507, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1507
		UNION ALL SELECT @custid , 1508, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1508
		UNION ALL SELECT @custid , 1509, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1509
		UNION ALL SELECT @custid , 1514, 202, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 202 and Bettype = 1514
		UNION ALL SELECT @custid , 1701, 255, MaxPositiontaking, MaxPositiontaking, MaxPositiontaking, 0, 0, 0, 0, 0, 0 ,0 ,0 FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 255 and Bettype = 1701 AND IsDep = 0
		
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			
			RETURN
		END     

		INSERT INTO [CustOverrideGame]
				   ([CustID]
				   ,[Bettype]
				   ,[Sporttype]
				   ,[minpositiontaking])
		SELECT @custid, 1101, 162, 0	
		UNION ALL SELECT @custid, 1501, 202, 0
		UNION ALL SELECT @custid, 1511, 202, 0
		UNION ALL SELECT @custid, 1503, 202, 0
		UNION ALL SELECT @custid, 1504, 202, 0
		UNION ALL SELECT @custid, 1505, 202, 0
		UNION ALL SELECT @custid, 1513, 202, 0
		UNION ALL SELECT @custid, 1507, 202, 0
		UNION ALL SELECT @custid, 1508, 202, 0
		UNION ALL SELECT @custid, 1509, 202, 0
		UNION ALL SELECT @custid, 1514, 202, 0
		UNION ALL SELECT @custid, 1701, 255, 0

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE custSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSetting3rd WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
			
			RETURN
		END		

		DECLARE @StakeLevelList_1701 VARCHAR(50), @StakeLevelList_1702 VARCHAR(50)
		SELECT @StakeLevelList_1701 = '', @StakeLevelList_1702 = ''
		SELECT @StakeLevelList_1701 = @StakeLevelList_1701 + CASE WHEN @StakeLevelList_1701 = '' THEN '' ELSE ',' END + CAST(StakeLevelID AS VARCHAR(5)) FROM StakeLevel WHERE GameTypeID = 1701 AND ExchangeId = @currency
		SELECT @StakeLevelList_1702 = @StakeLevelList_1702 + CASE WHEN @StakeLevelList_1702 = '' THEN '' ELSE ',' END + CAST(StakeLevelID AS VARCHAR(5)) FROM StakeLevel WHERE GameTypeID = 1702 AND ExchangeId = @currency

		--Keno
		INSERT INTO dbo.CustGameType(GameTypeID, Custid, MinBet, MaxBet, MaxPerGameType, IsDisabled, StakeLevelList)
		SELECT	GameTypeID, @Custid, 0, 0, 0, 1, CAST(0 AS VARCHAR(100))
		FROM	@tmp_GameType
		WHERE	IBCBetTypeID BETWEEN 1501 AND 1599
		UNION ALL SELECT 1701, @custid, 0, 0, 0, 0, @StakeLevelList_1701
		UNION ALL SELECT 1702, @custid, 0, 0, 0, 0, @StakeLevelList_1702

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 156
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSetting3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			
			RETURN
		END

		--end keno
	END--end roleid = 4
	ELSE IF @roleid = 3
	BEGIN			
		INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], [minbet], [maxbet], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking] )
		select @custid, 1, 1, @spositiontaking_1, @mpositiontaking_1, 0, @slivepositiontaking_1, @mlivepositiontaking_1, 0, @auto_slivepositiontaking_1, @auto_spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_1, @isauto_slivepositiontaking_1, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 1, @spositiontaking_3, @mpositiontaking_3, 0, @slivepositiontaking_3, @mlivepositiontaking_3, 0, @auto_slivepositiontaking_3, @auto_spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_3, @isauto_slivepositiontaking_3, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 1, @spositiontaking_7, @mpositiontaking_7, 0, @slivepositiontaking_7, @mlivepositiontaking_7, 0, @auto_slivepositiontaking_7, @auto_spositiontaking_7, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_7, @isauto_slivepositiontaking_7, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 1, @spositiontaking_8, @mpositiontaking_8, 0, @slivepositiontaking_8, @mlivepositiontaking_8, 0, @auto_slivepositiontaking_8, @auto_spositiontaking_8, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_8, @isauto_slivepositiontaking_8, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 1, @spositiontaking_2, @mpositiontaking_2, 0, 0, 0, 0, 0, @auto_spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 4, 1, @spositiontaking_4, @mpositiontaking_4, 0, 0, 0, 0, 0, @auto_spositiontaking_4, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_4, 0, 0, 0, 0, 0
		--1x2
		UNION ALL
		select @custid, 5, 1, @spositiontaking_5, @mpositiontaking_5, 0, 0, 0, 0, 0, @auto_spositiontaking_5, @discount1x2, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_5, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 6, 1, @spositiontaking_6, @mpositiontaking_6, 0, 0, 0, 0, 0, @auto_spositiontaking_6, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_6, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9, 1, @spositiontaking_9, @mpositiontaking_9, 0, 0, 0, 0, 0, @auto_spositiontaking_9, @discountcs, 0, 0, 0, 0, 0, 0, 0, @MinBetv1MP, @MaxBetv1MP, 0, 0, @isauto_spositiontaking_9, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 1, @spositiontaking_10, @mpositiontaking_10, 0, 0, 0, 0, 0, @auto_spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_10, 0, 0, 0, 0, 0
				
		UNION ALL
		select @custid, 9999, 1, @spositiontaking_9999, @mpositiontaking_9999, 0, 0, 0, 0, 0, @auto_spositiontaking_9999, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbet, @maxbet, 0, 0, @isauto_spositiontaking_9999, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 1, 2, @v2spositiontaking_1, @v2mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v2spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 2, @v2spositiontaking_2, @v2mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v2spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 2, @v2spositiontaking_3, @v2mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v2spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 2, @v2spositiontaking_7, @v2mpositiontaking_7, 0, 0, 0, 0, 0, @auto_v2spositiontaking_7, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_7, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 2, @v2spositiontaking_8, @v2mpositiontaking_8, 0, 0, 0, 0, 0, @auto_v2spositiontaking_8, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_8, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 2, @v2spositiontaking_10, @v2mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v2spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_10, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 9, 2,   @v2spositiontaking_9,   @v2mpositiontaking_9,   0, 0, 0, 0, 0, @auto_v2spositiontaking_9,  @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_9, 0  , 0, 0, 0, 0
		--Get commission of Correct Score for MoneyLine
		UNION ALL
		select @custid, 20, 2, @v2spositiontaking_20, @v2mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v2spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv2, @maxbetv2, 0, 0, @isauto_v2spositiontaking_20, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 3, @v3spositiontaking_1, @v3mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v3spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 3, @v3spositiontaking_2, @v3mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v3spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 3, @v3spositiontaking_3, @v3mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v3spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 3, @v3spositiontaking_20, @v3mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v3spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 3, @v3spositiontaking_10, @v3mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v3spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv3, @maxbetv3, 0, 0, @isauto_v3spositiontaking_10, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 5, @v5spositiontaking_1, @v5mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v5spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 5, @v5spositiontaking_2, @v5mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v5spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 5, @v5spositiontaking_3, @v5mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v5spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 5, @v5spositiontaking_20, @v5mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v5spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9999, 5, @v5spositiontaking_9999, @v5mpositiontaking_9999, 0, 0, 0, 0, 0, @auto_v5spositiontaking_9999, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_9999, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 5, @v5spositiontaking_10, @v5mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v5spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv5, @maxbetv5, 0, 0, @isauto_v5spositiontaking_10, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 1, 8, @v8spositiontaking_1, @v8mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v8spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 8, @v8spositiontaking_3, @v8mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v8spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 8, @v8spositiontaking_20, @v8mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v8spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 8, @v8spositiontaking_10, @v8mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v8spositiontaking_10, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv8, @maxbetv8, 0, 0, @isauto_v8spositiontaking_10, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 10, @v10spositiontaking_1, @v10mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v10spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 10, @v10spositiontaking_2, @v10mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v10spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 10, @v10spositiontaking_3, @v10mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v10spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 10, @v10spositiontaking_20, @v10mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v10spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 10, @v10spositiontaking_10, @v10mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v10spositiontaking_10,  @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv10, @maxbetv10, 0, 0, @isauto_v10spositiontaking_10, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 11, @v11spositiontaking_1, @v11mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v11spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv11, @maxbetv11, 0, 0, @isauto_v11spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 11, @v11spositiontaking_20, @v11mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v11spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv11, @maxbetv11, 0, 0, @isauto_v11spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 11, @v11spositiontaking_10, @v11mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v11spositiontaking_10,  @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv11, @maxbetv11, 0, 0, @isauto_v11spositiontaking_10, 0, 0, 0, 0, 0

		--v99
		UNION ALL
		select @custid, 1, 99, @v99spositiontaking_1, @v99mpositiontaking_1, 0, 0, 0, 0, 0, @auto_v99spositiontaking_1, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_1, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 99, @v99spositiontaking_2, @v99mpositiontaking_2, 0, 0, 0, 0, 0, @auto_v99spositiontaking_2, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_2, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 99, @v99spositiontaking_3, @v99mpositiontaking_3, 0, 0, 0, 0, 0, @auto_v99spositiontaking_3, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_3, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 99, @v99spositiontaking_20, @v99mpositiontaking_20, 0, 0, 0, 0, 0, @auto_v99spositiontaking_20, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_20, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 99, @v99spositiontaking_10, @v99mpositiontaking_10, 0, 0, 0, 0, 0, @auto_v99spositiontaking_10,  @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv99, @maxbetv99, 0, 0, @isauto_v99spositiontaking_10, 0, 0, 0, 0, 0
		-- mix parlay of mixed sports
		UNION ALL
		select @custid, 9, 99, @v99spositiontaking_9, @v99mpositiontaking_9, 0, 0, 0, 0, 0, @auto_v99spositiontaking_9, @discountcs, 0, 0, 0, 0, 0, 0, 0, @minbetv99mp, @maxbetv99mp, 0, 0, @isauto_v99spositiontaking_9, 0, 0, 0, 0, 0
		
		UNION ALL
		SELECT @custid, 20, 154, ISNULL(@v154spositiontaking_20,0), ISNULL(@v154mpositiontaking_20,0), 0, 0, 0, 0, 0, ISNULL(@auto_v154spositiontaking_20,0), ISNULL(@discountHRFixedOdds,0), 0, 0, 0, 0, 0, 0, 0, ISNULL(@minbetv154,0), ISNULL(@maxbetv154,0), 0, 0, ISNULL(@isauto_v154spositiontaking_20,0), 0, 0, 0, 0, 0

		if @@Error <> 0
		BEGIN
			--Error Occurs	
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE [custsetting] with (ROWLOCK) where custid =  @custid
						
			return
		END
		--insert into CustSetting3rd
		INSERT INTO [dbo].[CustSetting3rd](custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, alivepositiontaking, mlivepositiontaking, slivepositiontaking, autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking)
		--v151
		select @custid, 31, 151, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 31 AND custid = @srecommend
		UNION ALL
		select @custid, 32, 151, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 32 AND custid = @srecommend
		UNION ALL					   
		select @custid, 41, 151, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 41 AND custid = @srecommend
		UNION ALL					   
		select @custid, 42, 151, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 42 AND custid = @srecommend
		UNION ALL					   
		select @custid, 51, 151, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 51 AND custid = @srecommend
		UNION ALL					   
		select @custid, 52, 151, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 52 AND custid = @srecommend

		--v152
		UNION ALL
		select @custid, 41, 152, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 41 AND custid = @srecommend
		UNION ALL					   																																
		select @custid, 42, 152, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 42 AND custid = @srecommend
		UNION ALL					   																																
		select @custid, 51, 152, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 51 AND custid = @srecommend
		UNION ALL					   																																
		select @custid, 52, 152, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 52 AND custid = @srecommend

		--v153
		UNION ALL
		select @custid, 51, 153, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 153 AND bettype = 51 AND custid = @srecommend
		UNION ALL
		select @custid, 52, 153, 0, 0, spositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 153 AND bettype = 52 AND custid = @srecommend

		----v201
		--UNION ALL
		--select @custid, 2, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 3, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--- v161   
		--custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, alivepositiontaking, mlivepositiontaking,
		-- slivepositiontaking, autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking
		UNION ALL
		select @custid, 81, 161, 0, @v161mpositiontaking_81, @v161spositiontaking_81, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_81, @isauto_v161spositiontaking_81, 0, 0, 0, 0, 0, 0, 0, 0,0

		UNION ALL				 
		select @custid, 83, 161, 0, @v161mpositiontaking_83, @v161spositiontaking_83, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_83, @isauto_v161spositiontaking_83, 0, 0, 0, 0, 0, 0, 0, 0,0
		UNION ALL
		select @custid, 85, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_85, @v161slivepositiontaking_85, @auto_v161slivepositiontaking_85, @isauto_v161slivepositiontaking_85, 0,0
		UNION ALL
		select @custid, 86, 161, 0, @v161mpositiontaking_86, @v161spositiontaking_86, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_86, @isauto_v161spositiontaking_86, 0, 0, 0, @v161mlivepositiontaking_86, @v161slivepositiontaking_86, @auto_v161slivepositiontaking_86, @isauto_v161slivepositiontaking_86, 0,0
		UNION ALL
		select @custid, 87, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_87, @v161slivepositiontaking_87, @auto_v161slivepositiontaking_87, @isauto_v161slivepositiontaking_87, 0,0
		UNION ALL
		select @custid, 88, 161, 0, @v161mpositiontaking_88, @v161spositiontaking_88, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, @auto_v161spositiontaking_88, @isauto_v161spositiontaking_88, 0, 0, 0, 0, 0, 0, 0, 0,0
		UNION ALL
		select @custid, 89, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_89, @v161slivepositiontaking_89, @auto_v161slivepositiontaking_89, @isauto_v161slivepositiontaking_89, 0,0
		UNION ALL
		select @custid, 90, 161, 0, 0, 0, 0, 0, @discountnumber, 0, @minbetv161, @maxbetv161, 0, 0, 0, 0, 0, @v161mlivepositiontaking_90, @v161slivepositiontaking_90, @auto_v161slivepositiontaking_90, @isauto_v161slivepositiontaking_90, 0,0
		--v180
		
		UNION ALL
		select @custid, 1201, 180, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 180 AND bettype = 1201 AND custid = @srecommend
		UNION ALL
		select @custid, 1231, 181, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv181,0), ISNULL(@maxbetv181,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 181 AND bettype = 1231 AND custid = @srecommend
		UNION ALL
		select @custid, 1231, 182, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv182,0), ISNULL(@maxbetv182,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 182 AND bettype = 1231 AND custid = @srecommend		
		UNION ALL
		select @custid, 1231, 183, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv183,0), ISNULL(@maxbetv183,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 183 AND bettype = 1231 AND custid = @srecommend		
		UNION ALL
		select @custid, 1231, 184, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv184,0), ISNULL(@maxbetv184,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 184 AND bettype = 1231 AND custid = @srecommend
		UNION ALL
		select @custid, 1231, 185, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv185,0), ISNULL(@maxbetv185,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 185 AND bettype = 1231 AND custid = @srecommend
		UNION ALL
		select @custid, 1220, 186, 0, 0, spositiontaking, 0, 0, 0, 0, ISNULL(@minbetv186,0), ISNULL(@maxbetv186,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 186 AND bettype = 1220 AND custid = @srecommend

		
		if @@Error <> 0
		BEGIN
			--Error Occurs	
			SELECT @ErrCode=117
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid
						
			return
		END

		INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		select @custid, 1, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 7, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 8, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 4, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 5, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 6, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 8, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 11, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9999, 1, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 7, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 8, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 2, 0, 0.9, 0, 0.9
		--UNION ALL select @custid, 9, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 2, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 3, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9999, 5, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 8, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 8, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 8, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 10, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 11, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 11, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9, 99, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 20, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 154, 0, 0.9, 0, 0.9


		if @@Error <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=118
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid			
			DELETE custoverride with (ROWLOCK) where custid =  @custid
						
			return
		END

		--Insert into CustOverride3rd
		INSERT INTO [dbo].[CustOverride3rd]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		--		  select @custid, 2, 201, 0, 0.5, 0, 0.9
		--UNION ALL select @custid, 3, 201, 0, 0.5, 0, 0.9
		--v151
				  select @custid, 31, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 32, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 41, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 42, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 51, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 52, 151, 0, 0.5, 0, 0.9
		--v152
		UNION ALL select @custid, 41, 152, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 42, 152, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 51, 152, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 52, 152, 0, 0.5, 0, 0.9
		--v153
		UNION ALL select @custid, 51, 153, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 52, 153, 0, 0.5, 0, 0.9

		UNION ALL select @custid, 81, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 83, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 85, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 86, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 87, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 88, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 89, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 90, 161, 0, 0.9, 0, 0.9
		--v180
		UNION ALL select @custid, 1201, 180, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 1231, 181, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 1231, 182, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 1231, 183, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 1231, 184, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 1231, 185, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 1220, 186, 0, 0.9, 0, 0.9

		

		if @@Error <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=119
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid			
			DELETE CustOverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
						
			return
		END

		--Insert Into P2P Setting
		INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
			(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
		SELECT @custid  , 1001 , StakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @srecommend AND bettype = 1001
		UNION ALL 
		SELECT @custid  , 1002 , StakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @srecommend AND bettype = 1002
		 
		 
		if @@error <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=119
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid
			DELETE CustOverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			
			return
		END


		INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
				   (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
		SELECT @custid  , 1 , 0 , 0 , 0 , 0 
		UNION ALL SELECT @custid  , 2 , 0 , 0 , 0 , 0
		--SELECT @custid custId,groupID,sdiscount,0 adiscount,0 discount,0 playerdiscount
		--FROM dbo.P2PGroupComm
		--Where custid  = @srecommend ; 

		 
		if @@error <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=119
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid
			DELETE CustOverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid

			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
						
			return
		END

		--Insert live casino setting
		INSERT INTO CustSettingGame([CustID]
				   ,[Bettype]
				   ,[Sporttype]
				   ,[apositiontaking]
				   ,[mpositiontaking]
				   ,[spositiontaking]
				   ,[playerdiscount]
				   ,[discount]
				   ,[adiscount]
				   ,[sdiscount]
				   ,[autopositiontaking]
				   ,[isautopositiontaking]
				   ,[autompositiontaking]
				   ,[isautompositiontaking])
			SELECT @custid , bettype, 162, 0, 0, CASE WHEN @UplineSyncLiveCasino = 1 THEN spositiontaking ELSE 0 END, 0, 0, 0,  0, 0, 0 ,0 ,0       
			FROM CustSettingGame cs WITH(NOLOCK) 		
			WHERE cs.custid = @srecommend and cs.sporttype = 162 AND cs.bettype = 1101
			UNION ALL 
			SELECT @custid , bettype, 202, 0, 0, spositiontaking, 0, 0, 0,  0, 0, 0 ,0 ,0       
			FROM CustSettingGame cs WITH(NOLOCK)
			WHERE cs.custid = @srecommend and cs.sporttype = 202 AND cs.bettype BETWEEN 1501 AND 1599
			UNION ALL 
			SELECT @custid , bettype, sporttype, 0, 0, spositiontaking, 0, 0, 0,  0, 0, 0 ,0 ,0       
			FROM CustSettingGame cs WITH(NOLOCK)
			WHERE cs.custid = @srecommend and cs.sporttype = 255 AND cs.bettype = 1701

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
						
			RETURN
		END

		INSERT INTO [CustOverrideGame]
				   ([CustID]
				   ,[Bettype]
				   ,[Sporttype]
				   ,[minpositiontaking])
		SELECT @custid, 1101, 162, 0		
		UNION ALL 
		SELECT @custid, bettype, 202, 0 
		FROM CustOverrideGame co WITH(NOLOCK)
		WHERE co.custid = @srecommend and co.sporttype = 202 AND co.bettype BETWEEN 1501 AND 1599	
		UNION ALL 
		SELECT @custid, bettype, sporttype, 0 
		FROM CustOverrideGame co WITH(NOLOCK)
		WHERE co.custid = @srecommend and co.sporttype = 255 AND co.bettype = 1701
	

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE [CustSetting] with (ROWLOCK) where custid =  @custid
			DELETE [CustSetting3rd] with (ROWLOCK) where custid = @custid
			DELETE [custOverride] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE [custOverride3rd] WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
						
			RETURN
		END
		
		--Keno: Master.MinBet = MAX(Super.MinBet, Global.MinBet)
        --      Other values will be copy from super
		INSERT INTO dbo.CustGameType
        (
            GameTypeID
          , CustID
          , StakeLevelList
          , MinBet
          , MaxBet
          , MaxPerGameType
          , IsDisabled
        )
		SELECT cg.GameTypeID
             , @CustID
             , cg.StakeLevelList
             , CASE
                 WHEN cg.MinBet = 0 AND cg.MaxBet = 0 AND cg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MAX(MinBet)
                         FROM (VALUES (cg.MinBet)
                                    , (pbs.MinBet)
                              ) AS UplineMinBet(MinBet)
                      )
               END
             , cg.MaxBet
             , cg.MaxPerGameType
             , cg.IsDisabled
		FROM dbo.CustGameType cg WITH(NOLOCK)
			INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID
			INNER JOIN dbo.ProductBetSetting pbs WITH(NOLOCK) ON gt.IBCBetTypeID = pbs.Bettype
		WHERE cg.CustID = @srecommend
           AND pbs.Currency = @currency
           AND gt.IBCBetTypeID BETWEEN 1501 AND 1599
		UNION ALL 
		SELECT GameTypeID, @custid, StakeLevelList, 0, 0, 0, 0 FROM CustGameType WITH (NOLOCK) WHERE CustID = @srecommend AND GameTypeID IN (1701,1702)

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SET @ErrCode = 156
			
			-- ROLLBACK MANUALLY
			DELETE dbo.CustSetting with (ROWLOCK) where custid = @custid
			DELETE dbo.CustSetting3rd with (ROWLOCK) where custid = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid
									
			RETURN
		END
		--End Keno
		     
	END--end roleid =3
	ELSE IF @roleid = 2
	BEGIN				
		INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], [MinBet], [MaxBet], autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking,[autopositiontaking],[autolivepositiontaking],[isautopositiontaking],[isautolivepositiontaking])
		select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1, 0, @alivepositiontaking_1, @mlivepositiontaking_1, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_1, @auto_mlivepositiontaking_1, @isauto_mpositiontaking_1, @isauto_mlivepositiontaking_1, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, 0, @alivepositiontaking_3, @mlivepositiontaking_3, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_3, @auto_mlivepositiontaking_3, @isauto_mpositiontaking_3, @isauto_mlivepositiontaking_3, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, 0, @alivepositiontaking_7, @mlivepositiontaking_7, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_7, @auto_mlivepositiontaking_7, @isauto_mpositiontaking_7, @isauto_mlivepositiontaking_7, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, 0, @alivepositiontaking_8, @mlivepositiontaking_8, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_8, @auto_mlivepositiontaking_8, @isauto_mpositiontaking_8, @isauto_mlivepositiontaking_8, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_2, 0, @isauto_mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_4, 0, @isauto_mpositiontaking_4, 0, 0 ,0 ,0 ,0
		--1x2
		UNION ALL
		select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, 0, 0, 0, 0, 0, @discount1x2, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_5, 0, @isauto_mpositiontaking_5, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_6, 0, @isauto_mpositiontaking_6, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv1MP, @MaxBetv1MP, @auto_mpositiontaking_9, 0, @isauto_mpositiontaking_9, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_10, 0, @isauto_mpositiontaking_10, 0, 0 ,0 ,0 ,0
				
		UNION ALL
		select @custid, 9999, 1, @apositiontaking_9999, @mpositiontaking_9999, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBet, @MaxBet, @auto_mpositiontaking_9999, 0, @isauto_mpositiontaking_9999, 0, 0 ,0 ,0 ,0
		
		UNION ALL
		select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_1, 0, @isauto_v2mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_2, 0, @isauto_v2mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_3, 0, @isauto_v2mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_7, 0, @isauto_v2mpositiontaking_7, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_8, 0, @isauto_v2mpositiontaking_8, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 2, @v2apositiontaking_10, @v2mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_10, 0, @isauto_v2mpositiontaking_10, 0, 0 ,0 ,0 ,0
		--UNION ALL
		--select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_9, 0, @isauto_v2mpositiontaking_9, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0,  @MinBetv2, @MaxBetv2, @auto_v2mpositiontaking_20, 0, @isauto_v2mpositiontaking_20, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_1, 0, @isauto_v3mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_2, 0, @isauto_v3mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_3, 0, @isauto_v3mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_20, 0, @isauto_v3mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 3, @v3apositiontaking_10, @v3mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0,  @MinBetv3, @MaxBetv3, @auto_v3mpositiontaking_10, 0, @isauto_v3mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_1, 0, @isauto_v5mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_2, 0, @isauto_v5mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_3, 0, @isauto_v5mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_20, 0, @isauto_v5mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 9999, 5, @v5apositiontaking_9999, @v5mpositiontaking_9999, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_9999, 0, @isauto_v5mpositiontaking_9999, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 5, @v5apositiontaking_10, @v5mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0,  @MinBetv5, @MaxBetv5, @auto_v5mpositiontaking_10, 0, @isauto_v5mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_1, 0, @isauto_v8mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_3, 0, @isauto_v8mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_20, 0, @isauto_v8mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 8, @v8apositiontaking_10, @v8mpositiontaking_10,   0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, @auto_v8mpositiontaking_10, 0, @isauto_v8mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_1, 0, @isauto_v10mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_2, 0, @isauto_v10mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_3, 0, @isauto_v10mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_20, 0, @isauto_v10mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 10, @v10apositiontaking_10, @v10mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0,  @MinBetv10, @MaxBetv10, @auto_v10mpositiontaking_10, 0, @isauto_v10mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv11, @MaxBetv11, @auto_v11mpositiontaking_1, 0, @isauto_v11mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, @auto_v11mpositiontaking_20, 0, @isauto_v11mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 11, @v11apositiontaking_10, @v11mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0,  @MinBetv11, @MaxBetv11, @auto_v11mpositiontaking_10, 0, @isauto_v11mpositiontaking_10, 0, 0 ,0 ,0 ,0

		UNION ALL
		select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_1, 0, @isauto_v99mpositiontaking_1, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_2, 0, @isauto_v99mpositiontaking_2, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, 0, 0, 0, 0, 0, 0, 0, 0, @groupa, @groupb, @groupc, @groupd, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_3, 0, @isauto_v99mpositiontaking_3, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_20, 0, @isauto_v99mpositiontaking_20, 0, 0 ,0 ,0 ,0
		UNION ALL
		select @custid, 10, 99, @v99apositiontaking_10, @v99mpositiontaking_10, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0,  @MinBetv99, @MaxBetv99, @auto_v99mpositiontaking_10, 0, @isauto_v99mpositiontaking_10, 0, 0 ,0 ,0 ,0
		--- mix parlay of mixed sports
		UNION ALL
		select @custid, 9, 99, @v99apositiontaking_9, @v99mpositiontaking_9, 0, 0, 0, 0, 0, @discountcs, 0, 0, 0, 0, 0, 0, 0, 0, @MinBetv99mp, @MaxBetv99mp, @auto_v99mpositiontaking_9, 0, @isauto_v99mpositiontaking_9, 0, 0 ,0 ,0 ,0
		
		UNION ALL
		select @custid, 20, 154, ISNULL(@v154apositiontaking_20,0), ISNULL(@v154mpositiontaking_20,0), 0, 0, 0, 0, 0, ISNULL(@discountHRFixedOdds,0), 0, 0, 0, 0, 0, 0, 0, 0, ISNULL(@MinBetv154,0), ISNULL(@MaxBetv154,0), ISNULL(@auto_v154mpositiontaking_20,0), 0, ISNULL(@isauto_v154mpositiontaking_20,0), 0, 0 ,0 ,0 ,0

		if @@error <> 0
		BEGIN
			--Error occur	
			SELECT @ErrCode = 114
			
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			
			return
		END

		--Insert into CustSetting3rd  
		INSERT INTO [dbo].[CustSetting3rd]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [MinBet], [MaxBet], [autopositiontaking], [isautopositiontaking], [autompositiontaking], [isautompositiontaking], [alivepositiontaking],[mlivepositiontaking], [slivepositiontaking],[autolivepositiontaking], [isautolivepositiontaking], [autolivempositiontaking], [isautolivempositiontaking])
		----v201
		--select @custid, 2, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 3, 201, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--v151
		select @custid, 31, 151, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 31 AND custid = @mrecommend
		UNION ALL
		select @custid, 32, 151, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 32 AND custid = @mrecommend
		UNION ALL					   
		select @custid, 41, 151, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 41 AND custid = @mrecommend
		UNION ALL					   
		select @custid, 42, 151, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 42 AND custid = @mrecommend
		UNION ALL					   
		select @custid, 51, 151, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 51 AND custid = @mrecommend
		UNION ALL					   
		select @custid, 52, 151, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 52 AND custid = @mrecommend

		--v152
		UNION ALL
		select @custid, 41, 152, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 41 AND custid = @mrecommend
		UNION ALL					   																																
		select @custid, 42, 152, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 42 AND custid = @mrecommend
		UNION ALL					   																																
		select @custid, 51, 152, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 51 AND custid = @mrecommend
		UNION ALL					   																																
		select @custid, 52, 152, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 52 AND custid = @mrecommend

		--v153
		UNION ALL
		select @custid, 51, 153, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 153 AND bettype = 51 AND custid = @mrecommend
		UNION ALL
		select @custid, 52, 153, 0, mpositiontaking, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 153 AND bettype = 52 AND custid = @mrecommend

		---- v161 number game
		--custid, bettype, sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, minbet, maxbet, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking, alivepositiontaking, mlivepositiontaking, 
																																					-- slivepositiontaking, autolivepositiontaking, isautolivepositiontaking, autolivempositiontaking, isautolivempositiontaking
		UNION ALL 
		select @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_81, @isauto_v161mpositiontaking_81, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_83, @isauto_v161mpositiontaking_83, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 85, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_85, @v161mlivepositiontaking_85, 0, 0, 0, @auto_v161mlivepositiontaking_85, @isauto_v161mlivepositiontaking_85
		UNION ALL
		select @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_86, @isauto_v161mpositiontaking_86, @v161alivepositiontaking_86, @v161mlivepositiontaking_86, 0, 0, 0, @auto_v161mlivepositiontaking_86, @isauto_v161mlivepositiontaking_86
		UNION ALL
		select @custid, 87, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_87, @v161mlivepositiontaking_87, 0, 0, 0, @auto_v161mlivepositiontaking_87, @isauto_v161mlivepositiontaking_87
		UNION ALL
		select @custid, 88, 161, @v161apositiontaking_88, @v161mpositiontaking_88, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, @auto_v161mpositiontaking_88, @isauto_v161mpositiontaking_88, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 89, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_89, @v161mlivepositiontaking_89, 0, 0, 0, @auto_v161mlivepositiontaking_89, @isauto_v161mlivepositiontaking_89
		UNION ALL
		select @custid, 90, 161, 0, 0, 0, 0, @discountnumber, 0, 0, @MinBetv161, @MaxBetv161, 0, 0, 0, 0, @v161alivepositiontaking_90, @v161mlivepositiontaking_90, 0, 0, 0, @auto_v161mlivepositiontaking_90, @isauto_v161mlivepositiontaking_90

		UNION ALL -- v180 virtual soccer
		select @custid, 1201, 180, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 180 AND bettype = 1201 AND custid = @mrecommend
		UNION ALL -- v181 virtual horse racing
		select @custid, 1231, 181, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv181,0), ISNULL(@maxbetv181,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 181 AND bettype = 1231 AND custid = @mrecommend
		UNION ALL -- v182 Virtual Greyhounds
		select @custid, 1231, 182, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv182,0), ISNULL(@maxbetv182,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 182 AND bettype = 1231 AND custid = @mrecommend
		UNION ALL -- v183 Virtual Speedway
		select @custid, 1231, 183, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv183,0), ISNULL(@maxbetv183,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 183 AND bettype = 1231 AND custid = @mrecommend
		UNION ALL -- v184 Virtual Motor Racing
		select @custid, 1231, 184, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv184,0), ISNULL(@maxbetv184,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 184 AND bettype = 1231 AND custid = @mrecommend
		UNION ALL -- v185 Virtual Cycling
		select @custid, 1231, 185, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv185,0), ISNULL(@maxbetv185,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 185 AND bettype = 1231 AND custid = @mrecommend
		UNION ALL -- v186 virtual tennis
		select @custid, 1220, 186, 0, mpositiontaking, 0, 0, 0, 0, 0, ISNULL(@minbetv186,0), ISNULL(@maxbetv186,0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 186 AND bettype = 1220 AND custid = @mrecommend		

		if @@error <> 0
		BEGIN
			--Error occur	
			SELECT @ErrCode = 114
			
			-- ROLLBACK MANUALLY
			DELETE CustSetting with (ROWLOCK) where custid =  @custid
			DELETE CustSetting3rd with (ROWLOCK) where custid =  @custid
			
			return
		END

		INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
		select @custid, 1, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 7, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 8, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 4, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 5, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 6, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 1, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 8, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 11, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 10, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9999, 1, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 7, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 8, 2, 0, 0.9, 0, 0.9
		--UNION ALL select @custid, 9, 2, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 2, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 3, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 3, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 5, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 9999, 5, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 8, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 8, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 8, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 10, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 10, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 11, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 11, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 1, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 2, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 3, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 99, 0, 0.9, 0, 0.9

		UNION ALL select @custid, 9, 99, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 20, 154, 0, 0.9, 0, 0.9

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 115
				
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			
			return
		END

		--Insert Into CustOverride3rd
		INSERT INTO [dbo].[CustOverride3rd]([custid], [bettype], [sporttype], [minpositiontaking], [maxpositiontaking],[minlivepositiontaking],[maxlivepositiontaking])
		--		  select @custid, 2, 201, 0, 0.5, 0, 0.9
		--UNION ALL select @custid, 3, 201, 0, 0.5, 0, 0.9

		--v151
				  select @custid, 31, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 32, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 41, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 42, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 51, 151, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 52, 151, 0, 0.5, 0, 0.9
		--v152
		UNION ALL select @custid, 41, 152, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 42, 152, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 51, 152, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 52, 152, 0, 0.5, 0, 0.9
		--v153
		UNION ALL select @custid, 51, 153, 0, 0.5, 0, 0.9
		UNION ALL select @custid, 52, 153, 0, 0.5, 0, 0.9

		-- number game
		UNION ALL select @custid, 81, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 83, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 85, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 86, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 87, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 88, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 89, 161, 0, 0.9, 0, 0.9
		UNION ALL select @custid, 90, 161, 0, 0.9, 0, 0.9
		-- v180 virtual soccer
		UNION ALL select @custid, 1201, 180, 0, 0.9, 0, 0.9
		-- v181 virtual horse racing
		UNION ALL select @custid, 1231, 181, 0, 0.9, 0, 0.9
		-- v182  Virtual Greyhounds
		UNION ALL select @custid, 1231, 182, 0, 0.9, 0, 0.9
		-- v183  Virtual Speedway
		UNION ALL select @custid, 1231, 183, 0, 0.9, 0, 0.9
		-- v184 Virtual Motor Racing
		UNION ALL select @custid, 1231, 184, 0, 0.9, 0, 0.9
		-- v185  Virtual Cycling
		UNION ALL select @custid, 1231, 185, 0, 0.9, 0, 0.9
		---- v186 virtual tennis
		UNION ALL select @custid, 1220, 186, 0, 0.9, 0, 0.9
		
		
		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 115
				
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
			
			return
		END

		--Insert Into P2P Setting
		INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
			(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
		SELECT @custid  , 1001 , stakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @mrecommend AND bettype = 1001
		UNION ALL 
		SELECT @custid  , 1002 , stakeLevel1 , 0 , 0 , 0 , 0 FROM dbo.P2PGAMESETTING WITH(ROWLOCK) WHERE custid = @mrecommend AND bettype = 1002

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 115
				
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
				
			return
		END

		INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
				   (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
		SELECT @custid  , 1 , 0 , 0 , 0 , 0 
		UNION ALL SELECT @custid  , 2 , 0 , 0 , 0 , 0           
		--SELECT @custid custId,groupID,sdiscount,adiscount,0 discount,0 playerdiscount
		--FROM dbo.P2PGroupComm
		--Where custid  = @mrecommend ; 


		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 115
				
			-- ROLLBACK MANUALLY	
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
				
			return
		END

		--- insert into CustSettingGame
		INSERT INTO custsettingGame(CustID, Bettype, Sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking)
		SELECT @custid, 1101, 162, 0, CASE WHEN @UplineSyncLiveCasino = 1 THEN mpositiontaking ELSE 0 END, 0, 0, 0, 0, 0, 0, 0, 0, 0
		FROM custsettingGame WITH(NOLOCK)
		WHERE custid = @mrecommend AND sporttype = 162 AND bettype = 1101
		UNION ALL 
		SELECT @custid , bettype, 202, 0, mpositiontaking, 0, 0, 0, 0,  0, 0, 0 ,0 ,0       
		FROM CustSettingGame cs WITH(NOLOCK)
		WHERE cs.custid = @mrecommend and cs.sporttype = 202 AND cs.bettype BETWEEN 1501 AND 1599
		UNION ALL 
		SELECT @custid , bettype, sporttype, 0, mpositiontaking, 0, 0, 0, 0,  0, 0, 0 ,0 ,0       
		FROM CustSettingGame cs WITH(NOLOCK)
		WHERE cs.custid = @mrecommend and cs.sporttype = 255 AND cs.bettype = 1701

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 210
				
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid	
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
				
			RETURN
		END

		--- insert into Custoverridegame
		INSERT INTO Custoverridegame(CustID, Bettype, Sporttype, minpositiontaking)						
		SELECT @CustID, 1101, 162, 0		
		UNION ALL 
		SELECT @custid, bettype, 202, 0
		FROM Custoverridegame WITH (NOLOCK) 
		WHERE custid = @mrecommend AND Sporttype = 202 AND Bettype BETWEEN 1501 and 1599
		UNION ALL 
		SELECT @custid, bettype, Sporttype, 0
		FROM Custoverridegame WITH (NOLOCK) 
		WHERE custid = @mrecommend AND Sporttype = 255 AND Bettype =1701
		
		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 211
				
			-- ROLLBACK MANUALLY
			DELETE custsetting with (ROWLOCK) where custid =  @custid
			DELETE custsetting3rd with (ROWLOCK) where custid =  @custid
			DELETE custoverride with (ROWLOCK) where custid =  @custid
			DELETE CustOverride3rd with (ROWLOCK) where custid =  @custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid	
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
			DELETE Custoverridegame WITH (ROWLOCK) WHERE custId  =@custid
				
			RETURN
		END

		--Keno: Agent.MinBet = MAX(Master.MinBet, Super.MinBet, Global.MinBet)
        --      Agent.MaxBet = MIN(Master.MaxBet, Super.MaxBet)
        --      Member.MaxPerMatch = MIN(Master.MaxPerMatch, Super.MaxPerMatch)
        --      Upline with unlimit value(MinBet = MaxBet = MaxPerMatch = 0) will be ignore when comparing
        --      Other values will be copy from master
		INSERT INTO dbo.CustGameType
        (
            GameTypeID
          , CustID
          , StakeLevelList
          , MinBet
          , MaxBet
          , MaxPerGameType
          , IsDisabled
        )
		SELECT mcg.GameTypeID
             , @CustID
             , mcg.StakeLevelList
             , CASE
                 WHEN mcg.MinBet = 0 AND mcg.MaxBet = 0 AND mcg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MAX(MinBet)
                         FROM (VALUES (mcg.MinBet)
                                    , (ISNULL(scg.MinBet, 0))
                                    , (pbs.MinBet)
                              ) AS UplineMinBet(MinBet)
                      )
               END
             , CASE
                 WHEN mcg.MinBet = 0 AND mcg.MaxBet = 0 AND mcg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MIN(MaxBet)
                         FROM (VALUES (mcg.MaxBet)
                                    , (ISNULL(scg.MaxBet, mcg.MaxBet))
                              ) AS UplineMaxBet(MaxBet)
                      )
               END
             , CASE
                 WHEN mcg.MinBet = 0 AND mcg.MaxBet = 0 AND mcg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MIN(MaxPerMatch)
                         FROM (VALUES (mcg.MaxPerGameType)
                                    , (ISNULL(scg.MaxPerGameType, mcg.MaxPerGameType))
                              ) AS UplineMaxPerMatch(MaxPerMatch)
                      )
               END
             , mcg.IsDisabled
		  FROM dbo.CustGameType mcg WITH(NOLOCK)
    INNER JOIN @tmp_GameType gt ON mcg.GameTypeID = gt.GameTypeID
    INNER JOIN dbo.ProductBetSetting pbs WITH(NOLOCK) ON gt.IBCBetTypeID = pbs.Bettype
     LEFT JOIN dbo.CustGameType scg WITH(NOLOCK) ON scg.GameTypeID = mcg.GameTypeID
                                                AND scg.CustID = @super
                                                AND NOT (scg.MinBet = 0 AND scg.MaxBet = 0 AND scg.MaxPerGameType = 0)
		 WHERE mcg.CustID = @mrecommend
           AND pbs.Currency = @currency
           AND gt.IBCBetTypeID BETWEEN 1501 AND 1599
		
		UNION ALL 
		SELECT GameTypeID, @custid, StakeLevelList, 0, 0, 0, 0 FROM CustGameType WITH (NOLOCK) WHERE CustID = @mrecommend AND GameTypeID IN (1701,1702)

		IF @@error <> 0
		BEGIN
			--Error occur
			SET @ErrCode = 156
				
			-- ROLLBACK MANUALLY
			DELETE dbo.custsetting with (ROWLOCK) where custid = @custid
			DELETE dbo.custsetting3rd with (ROWLOCK) where custid = @custid
			DELETE dbo.custoverride with (ROWLOCK) where custid = @custid
			DELETE dbo.CustOverride3rd with (ROWLOCK) where custid = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid	
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custsettingGame WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.Custoverridegame WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustGameType WITH (ROWLOCK) WHERE custId = @custid

			RETURN
		END
		--End Keno

	END--end roleid =2
	ELSE IF @roleid = 1
	BEGIN			
		--print @v2mpositiontaking_20
		INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [alivepositiontaking], [mlivepositiontaking], [slivepositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], MinBet, MaxBet, autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking  ,[autompositiontaking],[autolivempositiontaking],[isautompositiontaking],[isautolivempositiontaking])
		select @custid, 1, 1, @apositiontaking_1, @mpositiontaking_1,@spositiontaking_1, @alivepositiontaking_1, @mlivepositiontaking_1, @slivepositiontaking_1, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 1, @apositiontaking_3, @mpositiontaking_3, @spositiontaking_3, @alivepositiontaking_3, @mlivepositiontaking_3, @slivepositiontaking_3, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 1, @apositiontaking_7, @mpositiontaking_7, @spositiontaking_7, @alivepositiontaking_7, @mlivepositiontaking_7, @slivepositiontaking_7, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 1, @apositiontaking_8, @mpositiontaking_8, @spositiontaking_8, @alivepositiontaking_8, @mlivepositiontaking_8, @slivepositiontaking_8, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 1, @apositiontaking_2, @mpositiontaking_2, @spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 4, 1, @apositiontaking_4, @mpositiontaking_4, @spositiontaking_4, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		--1x2
		UNION ALL
		select @custid, 5, 1, @apositiontaking_5, @mpositiontaking_5, @spositiontaking_5, 0, 0, 0, @playerdiscount1x2, @discount1x2, @adiscount1x2, @sdiscount1x2, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 6, 1, @apositiontaking_6, @mpositiontaking_6, @spositiontaking_6, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9, 1, @apositiontaking_9, @mpositiontaking_9, @spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBetv1MP, @MaxBetv1MP, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 1, @apositiontaking_10, @mpositiontaking_10, @spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 9999, 1, @apositiontaking_9999, @mpositiontaking_9999, @spositiontaking_9999, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0,@MinBet, @MaxBet, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 1, 2, @v2apositiontaking_1, @v2mpositiontaking_1, @v2spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 2, @v2apositiontaking_2, @v2mpositiontaking_2, @v2spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 2, @v2apositiontaking_3, @v2mpositiontaking_3, @v2spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 7, 2, @v2apositiontaking_7, @v2mpositiontaking_7, @v2spositiontaking_7, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 8, 2, @v2apositiontaking_8, @v2mpositiontaking_8, @v2spositiontaking_8, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 2, @v2apositiontaking_10, @v2mpositiontaking_10, @v2spositiontaking_10,0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 9, 2, @v2apositiontaking_9, @v2mpositiontaking_9, @v2spositiontaking_9, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 2, @v2apositiontaking_20, @v2mpositiontaking_20, @v2spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv2, @MaxBetv2, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 3, @v3apositiontaking_1, @v3mpositiontaking_1, @v3spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 3, @v3apositiontaking_2, @v3mpositiontaking_2, @v3spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 3, @v3apositiontaking_3, @v3mpositiontaking_3, @v3spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 3, @v3apositiontaking_20, @v3mpositiontaking_20, @v3spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 3, @v3apositiontaking_10, @v3mpositiontaking_10, @v3spositiontaking_10,0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv3, @MaxBetv3, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 5, @v5apositiontaking_1, @v5mpositiontaking_1, @v5spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 5, @v5apositiontaking_2, @v5mpositiontaking_2, @v5spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 5, @v5apositiontaking_3, @v5mpositiontaking_3, @v5spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 5, @v5apositiontaking_20, @v5mpositiontaking_20, @v5spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9999, 5, @v5apositiontaking_9999, @v5mpositiontaking_9999, @v5spositiontaking_9999, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 5, @v5apositiontaking_10, @v5mpositiontaking_10, @v5spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv5, @MaxBetv5, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 8, @v8apositiontaking_1, @v8mpositiontaking_1, @v8spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 8, @v8apositiontaking_3, @v8mpositiontaking_3, @v8spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 8, @v8apositiontaking_20, @v8mpositiontaking_20, @v8spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 8, @v8apositiontaking_10, @v8mpositiontaking_10, @v8spositiontaking_10,0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv8, @MaxBetv8, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 10, @v10apositiontaking_1, @v10mpositiontaking_1, @v10spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 10, @v10apositiontaking_2, @v10mpositiontaking_2, @v10spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 10, @v10apositiontaking_3, @v10mpositiontaking_3, @v10spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 10, @v10apositiontaking_20, @v10mpositiontaking_20, @v10spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 10, @v10apositiontaking_10, @v10mpositiontaking_10, @v10spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv10, @MaxBetv10, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 11, @v11apositiontaking_1, @v11mpositiontaking_1, @v11spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 11, @v11apositiontaking_20, @v11mpositiontaking_20, @v11spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 11, @v11apositiontaking_10, @v11mpositiontaking_10, @v11spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv11, @MaxBetv11, 0, 0, 0, 0, 0, 0, 0, 0

		UNION ALL
		select @custid, 1, 99, @v99apositiontaking_1, @v99mpositiontaking_1, @v99spositiontaking_1, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 2, 99, @v99apositiontaking_2, @v99mpositiontaking_2, @v99spositiontaking_2, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 3, 99, @v99apositiontaking_3, @v99mpositiontaking_3, @v99spositiontaking_3, 0, 0, 0, @playerdiscount, @discount, @adiscount, @sdiscount, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 9, 99, @v99apositiontaking_9, isnull(@v99mpositiontaking_9,0), isnull(@v99spositiontaking_9,0), 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99MP, @MaxBetv99MP, 0, 0, 0, 0, 0, 0, 0, 0
		
		UNION ALL
		select @custid, 20, 99, @v99apositiontaking_20, @v99mpositiontaking_20, @v99spositiontaking_20, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 10, 99, @v99apositiontaking_10, @v99mpositiontaking_10, @v99spositiontaking_10, 0, 0, 0, @playerdiscountcs, @discountcs, @adiscountcs, @sdiscountcs, 0, 0, 0, 0, 0, 0, @MinBetv99, @MaxBetv99, 0, 0, 0, 0, 0, 0, 0, 0
		UNION ALL
		select @custid, 20, 154, ISNULL(@v154apositiontaking_20,0), ISNULL(@v154mpositiontaking_20,0), ISNULL(@v154spositiontaking_20,0), 0, 0, 0, ISNULL(@playerdiscountHRFixedOdds,0), ISNULL(@discountHRFixedOdds,0), ISNULL(@adiscountHRFixedOdds,0), ISNULL(@sdiscountHRFixedOdds,0), 0, 0, 0, 0, 0, 0, ISNULL(@MinBetv154,0), ISNULL(@MaxBetv154,0), 0, 0, 0, 0, 0, 0, 0, 0


		if @@Error <> 0
		BEGIN
			--Error occurs
			SELECT @ErrCode=215
			
			-- ROLLBACK MANUALLY
			Delete custsetting with (ROWLOCK) where custid  =@custid

			return
		END
		
		--inser into CustSetting3rd
		INSERT INTO [dbo].[CustSetting3rd]([custid], [bettype], [sporttype], [apositiontaking], [mpositiontaking], [spositiontaking], [playerdiscount], [discount], [adiscount], [sdiscount], MinBet, MaxBet, autopositiontaking, isautopositiontaking, alivepositiontaking,mlivepositiontaking,slivepositiontaking,autolivepositiontaking,isautolivepositiontaking,[autompositiontaking],[autolivempositiontaking],[isautompositiontaking],[isautolivempositiontaking])
		--select @custid, 2, 201, 0, @v201mpositiontaking_2, @v201spositiontaking_2, 0, @v201discount, @v201adiscount, @v201sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		--UNION ALL
		--select @custid, 3, 201, 0, @v201mpositiontaking_3, @v201spositiontaking_3, 0, @v201discount, @v201adiscount, @v201sdiscount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

		--v151
		select @custid, 31, 151, apositiontaking, @v151mpositiontaking_31, @v151spositiontaking_31, @v151playerdiscount_31, @v151discount_31, @v151adiscount_31, @v151sdiscount_31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 31 AND custid = @recommend
		UNION ALL
		select @custid, 32, 151, apositiontaking, @v151mpositiontaking_32, @v151spositiontaking_32, @v151playerdiscount_31, @v151discount_31, @v151adiscount_31, @v151sdiscount_31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 32 AND custid = @recommend 
		UNION ALL
		select @custid, 41, 151, apositiontaking, @v151mpositiontaking_41, @v151spositiontaking_41, @v151playerdiscount_41, @v151discount_41, @v151adiscount_41, @v151sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 41 AND custid = @recommend
		UNION ALL
		select @custid, 42, 151, apositiontaking, @v151mpositiontaking_42, @v151spositiontaking_42, @v151playerdiscount_41, @v151discount_41, @v151adiscount_41, @v151sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 42 AND custid = @recommend
		UNION ALL
		select @custid, 51, 151, apositiontaking, @v151mpositiontaking_51, @v151spositiontaking_51, @v151playerdiscount_51, @v151discount_51, @v151adiscount_51, @v151sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 51 AND custid = @recommend
		UNION ALL
		select @custid, 52, 151, apositiontaking, @v151mpositiontaking_52, @v151spositiontaking_52, @v151playerdiscount_51, @v151discount_51, @v151adiscount_51, @v151sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 151 AND bettype = 52 AND custid = @recommend

		--v152
		UNION ALL
		select @custid, 41, 152, apositiontaking, @v152mpositiontaking_41, @v152spositiontaking_41, @v152playerdiscount_41, @v152discount_41, @v152adiscount_41, @v152sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 41 AND custid = @recommend
		UNION ALL
		select @custid, 42, 152, apositiontaking, @v152mpositiontaking_42, @v152spositiontaking_42, @v152playerdiscount_41, @v152discount_41, @v152adiscount_41, @v152sdiscount_41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 42 AND custid = @recommend
		UNION ALL
		select @custid, 51, 152, apositiontaking, @v152mpositiontaking_51, @v152spositiontaking_51, @v152playerdiscount_51, @v152discount_51, @v152adiscount_51, @v152sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 51 AND custid = @recommend
		UNION ALL
		select @custid, 52, 152, apositiontaking, @v152mpositiontaking_52, @v152spositiontaking_52, @v152playerdiscount_51, @v152discount_51, @v152adiscount_51, @v152sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 152 AND bettype = 52 AND custid = @recommend

		--v153
		UNION ALL
		select @custid, 51, 153, apositiontaking, @v153mpositiontaking_51, @v153spositiontaking_51, @v153playerdiscount_51, @v153discount_51, @v153adiscount_51, @v153sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 153 AND bettype = 51 AND custid = @recommend
		UNION ALL
		select @custid, 52, 153, apositiontaking, @v153mpositiontaking_52, @v153spositiontaking_52, @v153playerdiscount_51, @v153discount_51, @v153adiscount_51, @v153sdiscount_51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	FROM dbo.CustSetting3rd WITH (NOLOCK) WHERE sporttype = 153 AND bettype = 52 AND custid = @recommend

		--v161
		UNION ALL
		select @custid, 81, 161, @v161apositiontaking_81, @v161mpositiontaking_81, @v161spositiontaking_81, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 83, 161, @v161apositiontaking_83, @v161mpositiontaking_83, @v161spositiontaking_83, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 88, 161, @v161apositiontaking_88, @v161mpositiontaking_88, @v161spositiontaking_88, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 85, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_85,@v161mlivepositiontaking_85,@v161slivepositiontaking_85,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 86, 161, @v161apositiontaking_86, @v161mpositiontaking_86, @v161spositiontaking_86, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_86,@v161mlivepositiontaking_86,@v161slivepositiontaking_86,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 87, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_87,@v161mlivepositiontaking_87,@v161slivepositiontaking_87,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 89, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_89,@v161mlivepositiontaking_89,@v161slivepositiontaking_89,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 90, 161, 0, 0, 0, @playerdiscountnumber, @discountnumber, @adiscountnumber, @sdiscountnumber, @MinBetv161, @MaxBetv161, 0, 0,@v161alivepositiontaking_90,@v161mlivepositiontaking_90,@v161slivepositiontaking_90,0,0, 0, 0, 0, 0
		--v180
		UNION ALL
		select @custid, 1201, 180, ISNULL(@v180apositiontaking_1201,0), ISNULL(@v180mpositiontaking_1201,0), ISNULL(@v180spositiontaking_1201,0), 0, 0, 0, 0, ISNULL(@minbetv180,0), ISNULL(@maxbetv180,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 1231, 181, ISNULL(@v181apositiontaking_1231,0), ISNULL(@v181mpositiontaking_1231,0), ISNULL(@v181spositiontaking_1231,0), 0, 0, 0, 0, ISNULL(@minbetv181,0), ISNULL(@maxbetv181,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 1231, 182, ISNULL(@v182apositiontaking_1231,0), ISNULL(@v182mpositiontaking_1231,0), ISNULL(@v182spositiontaking_1231,0), 0, 0, 0, 0, ISNULL(@minbetv182,0), ISNULL(@maxbetv182,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 1231, 183, ISNULL(@v183apositiontaking_1231,0), ISNULL(@v183mpositiontaking_1231,0), ISNULL(@v183spositiontaking_1231,0), 0, 0, 0, 0, ISNULL(@minbetv183,0), ISNULL(@maxbetv183,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 1231, 184, ISNULL(@v184apositiontaking_1231,0), ISNULL(@v184mpositiontaking_1231,0), ISNULL(@v184spositiontaking_1231,0), 0, 0, 0, 0, ISNULL(@minbetv184,0), ISNULL(@maxbetv184,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 1231, 185, ISNULL(@v185apositiontaking_1231,0), ISNULL(@v185mpositiontaking_1231,0), ISNULL(@v185spositiontaking_1231,0), 0, 0, 0, 0, ISNULL(@minbetv185,0), ISNULL(@maxbetv185,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		UNION ALL
		select @custid, 1220, 186, ISNULL(@v186apositiontaking_1220,0), ISNULL(@v186mpositiontaking_1220,0), ISNULL(@v186spositiontaking_1220,0), 0, 0, 0, 0, ISNULL(@minbetv186,0), ISNULL(@maxbetv186,0), 0, 0,0,0,0,0,0, 0, 0, 0, 0
		
		if @@Error <> 0
		BEGIN
			--Error occurs
			SELECT @ErrCode=215
			
			-- ROLLBACK MANUALLY
			Delete custsetting with (ROWLOCK) where custid  =@custid
			Delete CustSetting3rd with (ROWLOCK) where custid  =@custid

			return
		END
		
		--Insert Into P2P Setting
		INSERT INTO  dbo.P2PGAMESETTING WITH(ROWLOCK)
			(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
		SELECT @custid  , bettype , StakeLevel1 , 0 , 0 , 0 , 0 FROM P2PGameSetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1001
		UNION ALL 
		SELECT @custid  , bettype , StakeLevel1 , 0 , 0 , 0 , 0 FROM P2PGameSetting WITH(NOLOCK) WHERE custid = @recommend AND bettype = 1002


		if @@error <> 0
		BEGIN
			--Error occurs
			SELECT @ErrCode=216
			
			-- ROLLBACK MANUALLY
			Delete custsetting with (ROWLOCK) where custid  =@custid
			Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			
			return
		END


		INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)

				   (custId,groupID,sdiscount,adiscount,discount,playerdiscount)
		SELECT @custid custId
			,P2PGroupComm.groupID
			,GC_S.sdiscount
			,GC_M.adiscount
			,P2PGroupComm.discount
			,0 playerdiscount
		FROM dbo.P2PGroupComm WITH(NOLOCK) 
		INNER JOIN (
			SELECT groupID
				,sdiscount
			FROM dbo.P2PGroupComm WITH(NOLOCK) 
			WHERE custid = @srecommend
			) GC_S ON GC_S.GROUPID = P2PGroupComm.GROUPID
		INNER JOIN (
			SELECT groupID
				,adiscount
			FROM dbo.P2PGroupComm WITH(NOLOCK) 
			WHERE custid = @mrecommend
			) GC_M ON GC_M.GROUPID = P2PGroupComm.GROUPID
		WHERE custid = @recommend;

		--SELECT @custid custId,groupID,sdiscount,adiscount,discount,0 playerdiscount
		--FROM dbo.P2PGroupComm
		--Where custid  = @recommend ; 

		if @@error <> 0
		BEGIN
			--Error occurs
			SELECT @ErrCode=216
			
			-- ROLLBACK MANUALLY
			Delete custsetting with (ROWLOCK) where custid  =@custid
			Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			
			return
		END

		--- insert into custsettingGame
		INSERT INTO custsettingGame(CustID, Bettype, Sporttype, apositiontaking, mpositiontaking, spositiontaking, playerdiscount, discount, adiscount, sdiscount, autopositiontaking, isautopositiontaking, autompositiontaking, isautompositiontaking)
		SELECT @custid, 1101, 162, @v162apositiontaking_1101, @v162mpositiontaking_1101, @v162spositiontaking_1101, 0, @v162discount_1101, @v162adiscount_1101, @v162sdiscount_1101, 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1501, 202, ISNULL(@v202apositiontaking_1501,0), ISNULL(@v202mpositiontaking_1501,0), ISNULL(@v202spositiontaking_1501,0), 0, ISNULL(@v202discount_1501,0), ISNULL(@v202adiscount_1501,0), ISNULL(@v202sdiscount_1501,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1511, 202, ISNULL(@v202apositiontaking_1511,0), ISNULL(@v202mpositiontaking_1511,0), ISNULL(@v202spositiontaking_1511,0), 0, ISNULL(@v202discount_1511,0), ISNULL(@v202adiscount_1511,0), ISNULL(@v202sdiscount_1511,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1503, 202, ISNULL(@v202apositiontaking_1503,0), ISNULL(@v202mpositiontaking_1503,0), ISNULL(@v202spositiontaking_1503,0), 0, ISNULL(@v202discount_1503,0), ISNULL(@v202adiscount_1503,0), ISNULL(@v202sdiscount_1503,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1504, 202, ISNULL(@v202apositiontaking_1504,0), ISNULL(@v202mpositiontaking_1504,0), ISNULL(@v202spositiontaking_1504,0), 0, ISNULL(@v202discount_1504,0), ISNULL(@v202adiscount_1504,0), ISNULL(@v202sdiscount_1504,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1505, 202, ISNULL(@v202apositiontaking_1505,0), ISNULL(@v202mpositiontaking_1505,0), ISNULL(@v202spositiontaking_1505,0), 0, ISNULL(@v202discount_1505,0), ISNULL(@v202adiscount_1505,0), ISNULL(@v202sdiscount_1505,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1513, 202, ISNULL(@v202apositiontaking_1513,0), ISNULL(@v202mpositiontaking_1513,0), ISNULL(@v202spositiontaking_1513,0), 0, ISNULL(@v202discount_1513,0), ISNULL(@v202adiscount_1513,0), ISNULL(@v202sdiscount_1513,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1507, 202, ISNULL(@v202apositiontaking_1507,0), ISNULL(@v202mpositiontaking_1507,0), ISNULL(@v202spositiontaking_1507,0), 0, ISNULL(@v202discount_1507,0), ISNULL(@v202adiscount_1507,0), ISNULL(@v202sdiscount_1507,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1508, 202, ISNULL(@v202apositiontaking_1508,0), ISNULL(@v202mpositiontaking_1508,0), ISNULL(@v202spositiontaking_1508,0), 0, ISNULL(@v202discount_1508,0), ISNULL(@v202adiscount_1508,0), ISNULL(@v202sdiscount_1508,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1509, 202, ISNULL(@v202apositiontaking_1509,0), ISNULL(@v202mpositiontaking_1509,0), ISNULL(@v202spositiontaking_1509,0), 0, ISNULL(@v202discount_1509,0), ISNULL(@v202adiscount_1509,0), ISNULL(@v202sdiscount_1509,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1514, 202, ISNULL(@v202apositiontaking_1514,0), ISNULL(@v202mpositiontaking_1514,0), ISNULL(@v202spositiontaking_1514,0), 0, ISNULL(@v202discount_1514,0), ISNULL(@v202adiscount_1514,0), ISNULL(@v202sdiscount_1514,0), 0, 0, 0, 0
		UNION ALL
		SELECT @custid, 1701, 255, ISNULL(@v255apositiontaking_1701,0), ISNULL(@v255mpositiontaking_1701,0), ISNULL(@v255spositiontaking_1701,0), 0, ISNULL(@v255discount_1701,0), ISNULL(@v255adiscount_1701,0), ISNULL(@v255sdiscount_1701,0), 0, 0, 0, 0
		FROM CustSettingGame 
		WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701
								
		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 210
				
			-- ROLLBACK MANUALLY
			Delete custsetting with (ROWLOCK) where custid  =@custid
			Delete CustSetting3rd with (ROWLOCK) where custid  =@custid
			DELETE P2PGameSetting WITH (ROWLOCK) WHERE custId  =@custid
			DELETE P2PGroupComm WITH (ROWLOCK) WHERE custId  =@custid
			DELETE custsettingGame WITH (ROWLOCK) WHERE custId  =@custid
				
			RETURN
		END	

		--Keno: Member.MinBet = MAX(Agent.MinBet, Master.MinBet, Super.MinBet, Global.MinBet)
        --      Member.MaxBet = MIN(Agent.MaxBet, Master.MaxBet, Super.MaxBet)
        --      Member.MaxPerMatch = MIN(Agent.MaxPerMatch, Master.MaxPerMatch, Super.MaxPerMatch)
        --      Upline with unlimit value(MinBet = MaxBet = MaxPerMatch = 0) will be ignore when comparing
        --      Other values will be copied from Agent
		INSERT INTO dbo.CustGameType
        (
            GameTypeID
          , CustID
          , StakeLevelList
          , MinBet
          , MaxBet
          , MaxPerGameType
          , IsDisabled
        )
		SELECT acg.GameTypeID
             , @CustID
             , acg.StakeLevelList
             , CASE
                 WHEN acg.MinBet = 0 AND acg.MaxBet = 0 AND acg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MAX(MinBet)
                         FROM (VALUES (acg.MinBet)
                                    , (ISNULL(mcg.MinBet, 0))
                                    , (ISNULL(scg.MinBet, 0))
                                    , (pbs.MinBet)
                              ) AS UplineMinBet(MinBet)
                      )
               END
             , CASE
                 WHEN acg.MinBet = 0 AND acg.MaxBet = 0 AND acg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MIN(MaxBet)
                         FROM (VALUES (acg.MaxBet)
                                    , (ISNULL(mcg.MaxBet, 0))
                                    , (ISNULL(scg.MaxBet, 0))
                              ) AS UplineMaxBet(MaxBet)
                        WHERE MaxBet <> 0
                      )
               END
             , CASE
                 WHEN acg.MinBet = 0 AND acg.MaxBet = 0 AND acg.MaxPerGameType = 0 THEN 0
                 ELSE (SELECT MIN(MaxPerMatch)
                         FROM (VALUES (acg.MaxPerGameType)
                                    , (ISNULL(mcg.MaxPerGameType, 0))
                                    , (ISNULL(scg.MaxPerGameType, 0))
                              ) AS UplineMaxPerMatch(MaxPerMatch)
                        WHERE MaxPerMatch <> 0
                      )
               END
             , acg.IsDisabled
		  FROM dbo.CustGameType acg WITH(NOLOCK)
			INNER JOIN @tmp_GameType gt ON acg.GameTypeID = gt.GameTypeID
			INNER JOIN dbo.ProductBetSetting pbs WITH(NOLOCK) ON gt.IBCBetTypeID = pbs.Bettype
			LEFT JOIN dbo.CustGameType scg WITH(NOLOCK) ON acg.GameTypeID = scg.GameTypeID
														AND scg.CustID = @super
														AND NOT (scg.MinBet = 0 AND scg.MaxBet = 0 AND scg.MaxPerGameType = 0)
			LEFT JOIN dbo.CustGameType mcg WITH(NOLOCK) ON acg.GameTypeID = mcg.GameTypeID
														AND mcg.CustID = @master
														AND NOT (mcg.MinBet = 0 AND mcg.MaxBet = 0 AND mcg.MaxPerGameType = 0)
		 WHERE pbs.Currency = @currency
           AND acg.CustID = @recommend
           AND gt.IBCBetTypeID BETWEEN 1501 AND 1599		
		
		IF @@error <> 0
		BEGIN
			--Error occur
			SET @ErrCode = 156
				
			-- ROLLBACK MANUALLY
			Delete dbo.custsetting with (ROWLOCK) where custid = @custid
			Delete dbo.CustSetting3rd with (ROWLOCK) where custid = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custsettingGame WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustGameType WITH (ROWLOCK) WHERE custId = @custid			
				
			RETURN
		END
		--End Keno

		--Gold Deluxe
		DECLARE @StakeLevelListAg_1701 VARCHAR(50), @StakeLevelListAg_1702 VARCHAR(50), @StakeLevelID_1701 VARCHAR(50),  @StakeLevelID_1702 VARCHAR(50)
		SELECT @StakeLevelListAg_1701 = StakeLevelList FROM CustGameType WITH (NOLOCK) WHERE custid = @recommend AND GameTypeID = 1701
		SELECT @StakeLevelListAg_1702 = StakeLevelList FROM CustGameType WITH (NOLOCK) WHERE custid = @recommend AND GameTypeID = 1702

		IF @StakeLevelListAg_1701 IS NOT NULL AND @StakeLevelListAg_1702 IS NOT NULL
		BEGIN
			SELECT TOP 1 @StakeLevelID_1701 = StakeLevelID FROM dbo.strSplit(@StakeLevelListAg_1701,',') a INNER JOIN StakeLevel s WITH (NOLOCK) ON s.StakeLevelID = a.val ORDER BY MinStake, MaxStake ASC
			SELECT TOP 1 @StakeLevelID_1702 = StakeLevelID FROM dbo.strSplit(@StakeLevelListAg_1702,',') a INNER JOIN StakeLevel s WITH (NOLOCK) ON s.StakeLevelID = a.val ORDER BY MinStake, MaxStake ASC
		END

		INSERT INTO dbo.CustGameType
        (
            GameTypeID
          , CustID
          , StakeLevelList
          , MinBet
          , MaxBet
          , MaxPerGameType
          , IsDisabled
        )		
		SELECT 1701, @custid, ISNULL(@StakeLevelID_1701,''), 0, 0, 0, 0
		UNION ALL 
		SELECT 1702, @custid, ISNULL(@StakeLevelID_1702,''), 0, 0, 0, 0
		
		IF @@error <> 0
		BEGIN
			--Error occur
			SET @ErrCode = 156
				
			-- ROLLBACK MANUALLY
			Delete dbo.custsetting with (ROWLOCK) where custid = @custid
			Delete dbo.CustSetting3rd with (ROWLOCK) where custid = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custsettingGame WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustGameType WITH (ROWLOCK) WHERE custId = @custid			
				
			RETURN
		END
		--End Gold Deluxe
	END
	
	-- For colossus Bet and Myanma Odds
	DECLARE @DirectParentAgent INT 
	select @roleid as roleid
	
	IF @roleid IN (2,3,4)
	BEGIN
		
		IF @roleid = 2 
			SET @DirectParentAgent = @mrecommend 
		IF @roleid = 3 
			SET @DirectParentAgent = @srecommend 
		-- For Colossus Bet
		IF @roleid = 4 OR EXISTS (SELECT 1 FROM AgentCommRate WITH (NOLOCK) WHERE CustID = @DirectParentAgent AND SportType = 204)
		BEGIN
			INSERT INTO dbo.AgentCommRate WITH (ROWLOCK) (CustID,SportType,BetType,CommRate) 
			SELECT @custid,204,18001,0
			UNION ALL 
			SELECT @custid,204,18002,0
		END	
		
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSetting3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END
		-- For Myanma Odds
		IF (@IsMyanmarOdds = 1 AND (@roleid = 4 OR EXISTS (SELECT 1 FROM AgentCommRate WITH (NOLOCK) WHERE CustID = @DirectParentAgent AND SportType = 1 AND Bettype = 301)))
		BEGIN
			INSERT INTO dbo.AgentCommRate WITH (ROWLOCK) (CustID,SportType,BetType,CommRate) 
			SELECT @custid,1,301,@discountMyanmarOdds
		END	
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode=116
			
			-- ROLLBACK MANUALLY
			DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSetting3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid
			
			RETURN
		END
	
	END
	IF @roleid = 1
	BEGIN
		-- For Colossus Bet
		SELECT @CustID AS CustID,AC.SportType,AC.BetType,AC.CommRate,CI.roleid 
		INTO #CustCommRate_temp
		FROM AgentCommRate ac WITH (ROWLOCK)
			JOIN custInfo ci WITH (ROWLOCK) ON ac.CustID = ci.custid
		WHERE ac.CustID IN (@srecommend,@mrecommend,@recommend) AND ac.Sporttype = 204 
		
		INSERT INTO CustCommRate (CustID,SportType,BetType,sdiscount,adiscount,discount,playerdiscount)
		SELECT CustID,SportType,BetType,T.[4],T.[3],T.[2],0
		FROM #CustCommRate_temp
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
			DELETE dbo.CustSetting3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
			DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  = @custid
			DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
			
			RETURN
		END
		IF (@IsMyanmarOdds = 1)
		BEGIN
		
			SELECT @CustID AS CustID,AC.SportType,AC.BetType,AC.CommRate,CI.roleid 
			INTO #CustCommRate_MOtemp
			FROM AgentCommRate ac WITH (ROWLOCK)
				JOIN custInfo ci WITH (ROWLOCK) ON ac.CustID = ci.custid
			WHERE ac.CustID IN (@srecommend,@mrecommend,@recommend) AND ac.Sporttype = 1 AND ac.Bettype = 301
			
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
				DELETE dbo.CustSetting3rd WITH (ROWLOCK) WHERE custId = @custid
				DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
				DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
				DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
				DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
				DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
				DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
				DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
				DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  = @custid
				DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
				
				RETURN
			END
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
			, @ErrCode			= @DCSErrCode OUTPUT
				
	IF @DCSErrCode <> 0 
	BEGIN
		--Error occur
		SET @ErrCode = 911
				
		-- ROLLBACK MANUALLY
		IF(dbo.f_CheckRepTable('custSetting') = 1) DELETE dbo.custSetting WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('CustSetting3rd') = 1) DELETE dbo.CustSetting3rd WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('custOverride') = 1) DELETE dbo.custOverride WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('custOverride3rd') = 1) DELETE dbo.custOverride3rd WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('P2PGameSetting') = 1) DELETE dbo.P2PGameSetting WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) DELETE dbo.P2PGroupComm WITH (ROWLOCK) WHERE custId = @custid
		IF(dbo.f_CheckRepTable('CustSettingGame') = 1) DELETE dbo.CustSettingGame WITH(ROWLOCK) WHERE custid = @custid
		IF(dbo.f_CheckRepTable('CustOverrideGame') = 1) DELETE dbo.CustOverrideGame WITH(ROWLOCK) WHERE custid = @custid
		IF(dbo.f_CheckRepTable('CustGameType') = 1) DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
		IF(dbo.f_CheckRepTable('AgentCommRate') = 1) DELETE AgentCommRate WITH (ROWLOCK) WHERE custId  =@custid		
		IF(dbo.f_CheckRepTable('CustCommRate') = 1) DELETE CustCommRate WITH (ROWLOCK) WHERE custId  = @custid
	END
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/
	
END
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInfo_Execrep_00] TO [vnteam] AS [dbo]