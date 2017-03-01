ALTER PROCEDURE [dbo].[Acc_Custsetting_09] 
	@custid int,
	@roleid INT,
	
	--super update auto pt on member
	@auto_spositiontaking_1 smallmoney = 0,
	@auto_spositiontaking_2 smallmoney = 0,
	@auto_spositiontaking_3 smallmoney = 0,
	@auto_spositiontaking_4 smallmoney = 0,
	@auto_spositiontaking_5 smallmoney= 0,
	@auto_spositiontaking_6 smallmoney = 0,
	@auto_spositiontaking_7 smallmoney = 0,
	@auto_spositiontaking_8 smallmoney = 0,
	@auto_spositiontaking_9 smallmoney = 0,
	@auto_spositiontaking_10 smallmoney = 0,
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
	
	-- mixed sports
	@auto_v99spositiontaking_9 smallmoney = 0,
	@auto_v154spositiontaking_20 smallmoney = 0,
	
	@isauto_spositiontaking_1 bit = 0,
	@isauto_spositiontaking_2 bit = 0,
	@isauto_spositiontaking_3 bit = 0,
	@isauto_spositiontaking_4 bit = 0,
	@isauto_spositiontaking_5 bit= 0,
	@isauto_spositiontaking_6 bit = 0,
	@isauto_spositiontaking_7 bit = 0,
	@isauto_spositiontaking_8 bit = 0,
	@isauto_spositiontaking_9 bit = 0,
	@isauto_spositiontaking_10 bit = 0,
	@isauto_spositiontaking_9999 bit = 0,
	
	@isauto_slivepositiontaking_1 bit = 0,
	@isauto_slivepositiontaking_3 bit = 0,
	@isauto_slivepositiontaking_7 bit = 0,
	@isauto_slivepositiontaking_8 bit = 0,
	
	@isauto_v2spositiontaking_1 bit = 0,
	@isauto_v2spositiontaking_2 bit = 0,
	@isauto_v2spositiontaking_3 bit = 0,
	@isauto_v2spositiontaking_7 bit = 0,
	@isauto_v2spositiontaking_8 bit = 0,
	@isauto_v2spositiontaking_9 bit = 0,
	@isauto_v2spositiontaking_20 bit = 0,
	
	@isauto_v3spositiontaking_1 bit = 0,
	@isauto_v3spositiontaking_2 bit = 0,
	@isauto_v3spositiontaking_3 bit = 0,
	@isauto_v3spositiontaking_20 bit = 0,

	@isauto_v5spositiontaking_1 bit = 0,
	@isauto_v5spositiontaking_2 bit = 0,
	@isauto_v5spositiontaking_3 bit = 0,
	@isauto_v5spositiontaking_20 bit = 0,
	@isauto_v5spositiontaking_9999 bit = 0,

	@isauto_v8spositiontaking_1 bit = 0,
	@isauto_v8spositiontaking_3 bit = 0,
	@isauto_v8spositiontaking_20 bit = 0,

	@isauto_v10spositiontaking_1 bit = 0,
	@isauto_v10spositiontaking_2 bit = 0,
	@isauto_v10spositiontaking_3 bit = 0,
	@isauto_v10spositiontaking_20 bit = 0,

	@isauto_v11spositiontaking_1 bit = 0,
	@isauto_v11spositiontaking_20 bit = 0,

	@isauto_v99spositiontaking_1 bit = 0,
	@isauto_v99spositiontaking_2 bit = 0,
	@isauto_v99spositiontaking_3 bit = 0,
	@isauto_v99spositiontaking_20 bit = 0,
	
	-- mixed sports
	@isauto_v99spositiontaking_9 bit = 0,
	@isauto_v154spositiontaking_20 bit = 0,
	
	@UpdateMultiple BIT = 0,
	@UpdatePositiontaking BIT = 1,
	@UpdatePositiontakingv2 BIT = 1,
	@UpdatePositiontakingv3 BIT = 1,
	@UpdatePositiontakingv5 BIT = 1,
	@UpdatePositiontakingv8 BIT = 1,
	@UpdatePositiontakingv10 BIT = 1,
	@UpdatePositiontakingv11 BIT = 1,
	@UpdatePositiontakingv99 BIT = 1,
	@UpdatePositiontakingv99MP BIT = 1,
	@UpdatePositiontakingv154 BIT = 1,
	
	--master update auto pt on member
	--um1
	@auto_mpositiontaking_mem_1 smallmoney = 0,
	@auto_mpositiontaking_mem_2 smallmoney = 0,
	@auto_mpositiontaking_mem_3 smallmoney = 0,
	@auto_mpositiontaking_mem_4 smallmoney = 0,
	@auto_mpositiontaking_mem_5 smallmoney= 0,
	@auto_mpositiontaking_mem_6 smallmoney = 0,
	@auto_mpositiontaking_mem_7 smallmoney = 0,
	@auto_mpositiontaking_mem_8 smallmoney = 0,
	@auto_mpositiontaking_mem_9 smallmoney = 0,
	@auto_mpositiontaking_mem_10 smallmoney = 0,
	@auto_mpositiontaking_mem_9999 smallmoney = 0,
	@auto_mlivepositiontaking_mem_1 smallmoney = 0,
	@auto_mlivepositiontaking_mem_3 smallmoney = 0,
	@auto_mlivepositiontaking_mem_7 smallmoney = 0,
	@auto_mlivepositiontaking_mem_8 smallmoney = 0,
	
	@auto_v2mpositiontaking_mem_1 smallmoney = 0,
	@auto_v2mpositiontaking_mem_2 smallmoney = 0,
	@auto_v2mpositiontaking_mem_3 smallmoney = 0,
	@auto_v2mpositiontaking_mem_7 smallmoney = 0, 
	@auto_v2mpositiontaking_mem_8 smallmoney = 0,
--	@auto_v2mpositiontaking_mem_9 smallmoney = 0,
	@auto_v2mpositiontaking_mem_20 smallmoney = 0,
	
	@auto_v3mpositiontaking_mem_1 smallmoney = 0,
	@auto_v3mpositiontaking_mem_2 smallmoney = 0,
	@auto_v3mpositiontaking_mem_3 smallmoney = 0,
	@auto_v3mpositiontaking_mem_20 smallmoney = 0,

	@auto_v5mpositiontaking_mem_1 smallmoney = 0,
	@auto_v5mpositiontaking_mem_2 smallmoney = 0,
	@auto_v5mpositiontaking_mem_3 smallmoney = 0,
	@auto_v5mpositiontaking_mem_20 smallmoney = 0,
	@auto_v5mpositiontaking_mem_9999 smallmoney = 0,

	@auto_v8mpositiontaking_mem_1 smallmoney = 0,
	@auto_v8mpositiontaking_mem_3 smallmoney = 0,
	@auto_v8mpositiontaking_mem_20 smallmoney = 0,

	@auto_v10mpositiontaking_mem_1 smallmoney = 0,
	@auto_v10mpositiontaking_mem_2 smallmoney = 0,
	@auto_v10mpositiontaking_mem_3 smallmoney = 0,
	@auto_v10mpositiontaking_mem_20 smallmoney = 0,

	@auto_v11mpositiontaking_mem_1 smallmoney = 0,
	@auto_v11mpositiontaking_mem_20 smallmoney = 0,

	@auto_v99mpositiontaking_mem_1 smallmoney = 0,
	@auto_v99mpositiontaking_mem_2 smallmoney = 0,
	@auto_v99mpositiontaking_mem_3 smallmoney = 0,
	@auto_v99mpositiontaking_mem_20 smallmoney = 0,

	-- mixed sports
	@auto_v99mpositiontaking_mem_9 smallmoney = 0,
	@auto_v154mpositiontaking_mem_20 smallmoney = 0,

	--im1
	@isauto_mpositiontaking_mem_1 bit = 0,
	@isauto_mpositiontaking_mem_2 bit = 0,
	@isauto_mpositiontaking_mem_3 bit = 0,
	@isauto_mpositiontaking_mem_4 bit = 0,
	@isauto_mpositiontaking_mem_5 bit= 0,
	@isauto_mpositiontaking_mem_6 bit = 0,
	@isauto_mpositiontaking_mem_7 bit = 0,
	@isauto_mpositiontaking_mem_8 bit = 0,
	@isauto_mpositiontaking_mem_9 bit = 0,
	@isauto_mpositiontaking_mem_10 bit = 0,
	@isauto_mpositiontaking_mem_9999 bit = 0,
	
	@isauto_mlivepositiontaking_mem_1 bit = 0,
	@isauto_mlivepositiontaking_mem_3 bit = 0,
	@isauto_mlivepositiontaking_mem_7 bit = 0,
	@isauto_mlivepositiontaking_mem_8 bit = 0,
	
	@isauto_v2mpositiontaking_mem_1 bit = 0,
	@isauto_v2mpositiontaking_mem_2 bit = 0,
	@isauto_v2mpositiontaking_mem_3 bit = 0,
	@isauto_v2mpositiontaking_mem_7 bit = 0,
	@isauto_v2mpositiontaking_mem_8 bit = 0,
--	@isauto_v2mpositiontaking_mem_9 bit = 0,
	@isauto_v2mpositiontaking_mem_20 bit = 0,
	
	@isauto_v3mpositiontaking_mem_1 bit = 0,
	@isauto_v3mpositiontaking_mem_2 bit = 0,
	@isauto_v3mpositiontaking_mem_3 bit = 0,
	@isauto_v3mpositiontaking_mem_20 bit = 0,

	@isauto_v5mpositiontaking_mem_1 bit = 0,
	@isauto_v5mpositiontaking_mem_2 bit = 0,
	@isauto_v5mpositiontaking_mem_3 bit = 0,
	@isauto_v5mpositiontaking_mem_20 bit = 0,
	@isauto_v5mpositiontaking_mem_9999 bit = 0,

	@isauto_v8mpositiontaking_mem_1 bit = 0,
	@isauto_v8mpositiontaking_mem_3 bit = 0,
	@isauto_v8mpositiontaking_mem_20 bit = 0,

	@isauto_v10mpositiontaking_mem_1 bit = 0,
	@isauto_v10mpositiontaking_mem_2 bit = 0,
	@isauto_v10mpositiontaking_mem_3 bit = 0,
	@isauto_v10mpositiontaking_mem_20 bit = 0,

	@isauto_v11mpositiontaking_mem_1 bit = 0,
	@isauto_v11mpositiontaking_mem_20 bit = 0,

	@isauto_v99mpositiontaking_mem_1 bit = 0,
	@isauto_v99mpositiontaking_mem_2 bit = 0,
	@isauto_v99mpositiontaking_mem_3 bit = 0,
	@isauto_v99mpositiontaking_mem_20 bit = 0,

	-- mixed sports
	@isauto_v99mpositiontaking_mem_9 bit = 0,
	@isauto_v154mpositiontaking_mem_20 bit = 0,
	
	-- Outright PT for sports
	@auto_v2spositiontaking_10 smallmoney = 0,
	@auto_v3spositiontaking_10 smallmoney = 0,
	@auto_v5spositiontaking_10 smallmoney = 0,
	@auto_v8spositiontaking_10 smallmoney = 0,
	@auto_v10spositiontaking_10 smallmoney = 0,
	@auto_v11spositiontaking_10 smallmoney = 0,
	@auto_v99spositiontaking_10 smallmoney = 0,
	
	@isauto_v2spositiontaking_10 bit = 0,
	@isauto_v3spositiontaking_10 bit = 0,
	@isauto_v5spositiontaking_10 bit = 0,
	@isauto_v8spositiontaking_10 bit = 0,
	@isauto_v10spositiontaking_10 bit = 0,
	@isauto_v11spositiontaking_10 bit = 0,
	@isauto_v99spositiontaking_10 bit = 0,
	
	@auto_v2mpositiontaking_mem_10 smallmoney = 0,
	@auto_v3mpositiontaking_mem_10 smallmoney = 0,
	@auto_v5mpositiontaking_mem_10 smallmoney = 0,
	@auto_v8mpositiontaking_mem_10 smallmoney = 0,
	@auto_v10mpositiontaking_mem_10 smallmoney = 0,
	@auto_v11mpositiontaking_mem_10 smallmoney = 0,
	@auto_v99mpositiontaking_mem_10 smallmoney = 0,
	
	@isauto_v2mpositiontaking_mem_10 bit = 0,
	@isauto_v3mpositiontaking_mem_10 bit = 0,
	@isauto_v5mpositiontaking_mem_10 bit = 0,
	@isauto_v8mpositiontaking_mem_10 bit = 0,
	@isauto_v10mpositiontaking_mem_10 bit = 0,
	@isauto_v11mpositiontaking_mem_10 bit = 0,
	@isauto_v99mpositiontaking_mem_10 bit = 0

	
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update auto pt on member
		DB: DBCUST/custDB
		Original versions:	Acc_CustomerUpdMember_AutoPositiontaking, Acc_CustomerUpdMember_AutoMPositiontaking				
		
		Revision:
			- 20131105@Elodie: Add HR Fixed Odds [Redmine:#6505]
			- 20140220@Johnson: Merge code correct pt on members after update auto pt
			- 20140424@Johnson: fix bug correct super pt on member after master update auto pt on member
			- 20140701@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]

		  - 20150610@Daniel: 
		   + Improve medthod check table existing in subscribers	
		   + Separate custDB to new server DBCUST   
		 - 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]  			
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON 
	
     if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	   AND dbo.f_CheckRepTable('CustSetting') = 1 
	   AND dbo.f_CheckRepTable('CustOverride') = 1 
	   )
     RETURN	
		
	Declare @bettype int,	
			
			@autopositiontaking smallmoney, 	
			@isautopositiontaking bit,	
			
			@autolivepositiontaking smallmoney,
			@isautolivepositiontaking bit,	

			@maxpos smallmoney,	
			
			@autov2positiontaking smallmoney,
			@isautov2positiontaking bit, 

			@autov3positiontaking smallmoney,
			@isautov3positiontaking bit, 

			@autov5positiontaking smallmoney,
			@isautov5positiontaking bit, 

			@autov8positiontaking smallmoney,
			@isautov8positiontaking bit, 

			@autov10positiontaking smallmoney,
			@isautov10positiontaking bit, 

			@autov11positiontaking smallmoney,
			@isautov11positiontaking bit, 

			@autov99positiontaking smallmoney,
			@isautov99positiontaking bit, 
			
			@autov99mppositiontaking smallmoney,
			@isautov99mppositiontaking bit,
			
			@autov154positiontaking smallmoney,
			@isautov154positiontaking bit, 
			
			@srecommend int,
			@mrecommend int,
			@recommend int
	
	
	DECLARE @tmp_sag TABLE(custid int, sporttype smallint, bettype smallint,
		spositiontaking smallmoney, slivepositiontaking smallmoney, mpositiontaking smallmoney, mlivepositiontaking smallmoney, minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
	) 
	
	DECLARE @tmp_mag TABLE(custid int, sporttype smallint, bettype smallint,
		mpositiontaking smallmoney, mlivepositiontaking smallmoney, isautopositiontaking bit, isautolivepositiontaking bit, autopositiontaking smallmoney, autolivepositiontaking smallmoney,
		minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
	)
	
	DECLARE @tmp_ag TABLE(custid int, sporttype smallint, bettype smallint,
		apositiontaking smallmoney, alivepositiontaking smallmoney, isautompositiontaking bit, autompositiontaking smallmoney, isautolivempositiontaking bit, autolivempositiontaking smallmoney, 
		minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney)
	
	DECLARE @tmp_cs TABLE(custid int, sporttype smallint, bettype smallint,
		spositiontaking smallmoney, mpositiontaking smallmoney, apositiontaking smallmoney, slivepositiontaking smallmoney, mlivepositiontaking smallmoney, alivepositiontaking smallmoney,
		autopositiontaking smallmoney, autolivepositiontaking smallmoney, isautopositiontaking bit, isautolivepositiontaking bit,
		autompositiontaking smallmoney, autolivempositiontaking smallmoney, isautompositiontaking bit, isautolivempositiontaking bit
	)
	
	DECLARE @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney
	
	select @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend from custinfo with (NOLOCK) where custid = @custid
	
	INSERT INTO @tmp_cs (custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, slivepositiontaking, mlivepositiontaking, alivepositiontaking,
		autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking,
		autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking
	)
	SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, slivepositiontaking, mlivepositiontaking, alivepositiontaking,
		autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking, 
		autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking
	FROM custsetting WITH(NOLOCK)
	WHERE custid = @custid		
	
	INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, slivepositiontaking, mpositiontaking, mlivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
	SELECT scs.custid, scs.sporttype, scs.bettype, spositiontaking, slivepositiontaking, mpositiontaking, mlivepositiontaking, sco.minpositiontaking, sco.minlivepositiontaking, sco.maxpositiontaking, sco.maxlivepositiontaking
	FROM custsetting scs with(NOLOCK)
		INNER JOIN custoverride sco WITH(NOLOCK) on scs.custid = sco.custid and scs.sporttype = sco.sporttype and scs.bettype = sco.bettype
	WHERE scs.custid = @srecommend
	
	INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, mlivepositiontaking, isautopositiontaking, isautolivepositiontaking, autopositiontaking , autolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
	SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, mlivepositiontaking, isautopositiontaking, isautolivepositiontaking, autopositiontaking , autolivepositiontaking, mco.minpositiontaking, mco.minlivepositiontaking, mco.maxpositiontaking, mco.maxlivepositiontaking
	FROM custsetting mcs WITH(NOLOCK)
		inner JOIN custoverride mco WITH(NOLOCK) on mcs.custid = mco.custid and mcs.sporttype = mco.sporttype and mcs.bettype = mco.bettype
	WHERE mcs.custid = @mrecommend	
	
	INSERT INTO @tmp_ag(custid, sporttype, bettype, apositiontaking, alivepositiontaking, isautompositiontaking , autompositiontaking , isautolivempositiontaking , autolivempositiontaking , minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
	SELECT cs.custid, cs.sporttype, cs.bettype, apositiontaking, alivepositiontaking, isautompositiontaking , autompositiontaking , cs.isautolivempositiontaking , autolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking
	FROM custoverride co WITH(NOLOCK)
		inner join custSetting cs WITH(NOLOCK) on cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
	WHERE cs.custid = @recommend 	
	
	IF @roleid = 4
	BEGIN
		Declare			
			@old_autopositiontaking smallmoney,
			@old_isautopositiontaking smallmoney,
						
			@old_autolivepositiontaking smallmoney,
			@old_isautolivepositiontaking smallmoney,
			
			@old_autov2positiontaking smallmoney,
			@old_isautov2positiontaking smallmoney,

			@old_autov3positiontaking smallmoney,
			@old_isautov3positiontaking smallmoney,
		
			@old_autov5positiontaking smallmoney,
			@old_isautov5positiontaking smallmoney,
						
			@old_autov8positiontaking smallmoney,
			@old_isautov8positiontaking smallmoney,
			
			@old_autov10positiontaking smallmoney,
			@old_isautov10positiontaking smallmoney,

			@old_autov11positiontaking smallmoney,
			@old_isautov11positiontaking smallmoney,

			@old_autov99positiontaking smallmoney,
			@old_isautov99positiontaking smallmoney,

			-- mixed sports
			@old_autov99mppositiontaking smallmoney,
			@old_isautov99mppositiontaking smallmoney,
			
			@old_autov154positiontaking smallmoney,
			@old_isautov154positiontaking smallmoney
			
		declare 
			@old_auto_spositiontaking_1 smallmoney,
			@old_auto_spositiontaking_2 smallmoney,
			@old_auto_spositiontaking_3 smallmoney,
			@old_auto_spositiontaking_4 smallmoney,
			@old_auto_spositiontaking_5 smallmoney,
			@old_auto_spositiontaking_6 smallmoney,
			@old_auto_spositiontaking_7 smallmoney,
			@old_auto_spositiontaking_8 smallmoney,
			@old_auto_spositiontaking_9 smallmoney,
			@old_auto_spositiontaking_10 smallmoney,
			@old_auto_spositiontaking_9999 smallmoney,	
			@old_auto_slivepositiontaking_1 smallmoney,
			@old_auto_slivepositiontaking_3 smallmoney,
			@old_auto_slivepositiontaking_7 smallmoney,
			@old_auto_slivepositiontaking_8 smallmoney,
			
			@old_auto_v2spositiontaking_1 smallmoney,
			@old_auto_v2spositiontaking_2 smallmoney,
			@old_auto_v2spositiontaking_3 smallmoney,
			@old_auto_v2spositiontaking_7 smallmoney,
			@old_auto_v2spositiontaking_8 smallmoney,
		--	@old_auto_v2spositiontaking_9 smallmoney,
			@old_auto_v2spositiontaking_20 smallmoney,

			@old_auto_v3spositiontaking_1 smallmoney,
			@old_auto_v3spositiontaking_2 smallmoney,
			@old_auto_v3spositiontaking_3 smallmoney,
			@old_auto_v3spositiontaking_20 smallmoney,

			@old_auto_v5spositiontaking_1 smallmoney,
			@old_auto_v5spositiontaking_2 smallmoney,
			@old_auto_v5spositiontaking_3 smallmoney,
			@old_auto_v5spositiontaking_20 smallmoney,
			@old_auto_v5spositiontaking_9999 smallmoney,

			@old_auto_v8spositiontaking_1 smallmoney,
			@old_auto_v8spositiontaking_3 smallmoney,
			@old_auto_v8spositiontaking_20 smallmoney,

			@old_auto_v10spositiontaking_1 smallmoney,
			@old_auto_v10spositiontaking_2 smallmoney,
			@old_auto_v10spositiontaking_3 smallmoney,
			@old_auto_v10spositiontaking_20 smallmoney,

			@old_auto_v11spositiontaking_1 smallmoney,
			@old_auto_v11spositiontaking_20 smallmoney,

			@old_auto_v99spositiontaking_1 smallmoney,
			@old_auto_v99spositiontaking_2 smallmoney,
			@old_auto_v99spositiontaking_3 smallmoney,
			@old_auto_v99spositiontaking_20 smallmoney,

			-- mixed sports
			@old_auto_v99spositiontaking_9 smallmoney,
			@old_auto_v154spositiontaking_20 smallmoney,

			@old_isauto_spositiontaking_1 bit,
			@old_isauto_spositiontaking_2 bit,
			@old_isauto_spositiontaking_3 bit,
			@old_isauto_spositiontaking_4 bit,
			@old_isauto_spositiontaking_5 bit,
			@old_isauto_spositiontaking_6 bit,
			@old_isauto_spositiontaking_7 bit,
			@old_isauto_spositiontaking_8 bit,
			@old_isauto_spositiontaking_9 bit,
			@old_isauto_spositiontaking_10 bit,
			@old_isauto_spositiontaking_9999 bit,
			
			@old_isauto_slivepositiontaking_1 bit,
			@old_isauto_slivepositiontaking_3 bit,
			@old_isauto_slivepositiontaking_7 bit,
			@old_isauto_slivepositiontaking_8 bit,
			
			@old_isauto_v2spositiontaking_1 bit,
			@old_isauto_v2spositiontaking_2 bit,
			@old_isauto_v2spositiontaking_3 bit,
			@old_isauto_v2spositiontaking_7 bit,
			@old_isauto_v2spositiontaking_8 bit,
		--	@old_isauto_v2spositiontaking_9 bit,
			@old_isauto_v2spositiontaking_20 bit,

			@old_isauto_v3spositiontaking_1 bit,
			@old_isauto_v3spositiontaking_2 bit,
			@old_isauto_v3spositiontaking_3 bit,
			@old_isauto_v3spositiontaking_20 bit,

			@old_isauto_v5spositiontaking_1 bit,
			@old_isauto_v5spositiontaking_2 bit,
			@old_isauto_v5spositiontaking_3 bit,
			@old_isauto_v5spositiontaking_20 bit,
			@old_isauto_v5spositiontaking_9999 bit,

			@old_isauto_v8spositiontaking_1 bit,
			@old_isauto_v8spositiontaking_3 bit,
			@old_isauto_v8spositiontaking_20 bit,

			@old_isauto_v10spositiontaking_1 bit,
			@old_isauto_v10spositiontaking_2 bit,
			@old_isauto_v10spositiontaking_3 bit,
			@old_isauto_v10spositiontaking_20 bit,

			@old_isauto_v11spositiontaking_1 bit,
			@old_isauto_v11spositiontaking_20 bit,

			@old_isauto_v99spositiontaking_1 bit,
			@old_isauto_v99spositiontaking_2 bit,
			@old_isauto_v99spositiontaking_3 bit,
			@old_isauto_v99spositiontaking_20 bit,

			-- mixed sports
			@old_isauto_v99spositiontaking_9 bit,
			@old_isauto_v154spositiontaking_20 bit,
			
			@master_auto_spositiontaking_1 smallmoney,
			@master_auto_spositiontaking_2 smallmoney,
			@master_auto_spositiontaking_3 smallmoney,
			@master_auto_spositiontaking_4 smallmoney,
			@master_auto_spositiontaking_5 smallmoney,
			@master_auto_spositiontaking_6 smallmoney,
			@master_auto_spositiontaking_7 smallmoney,
			@master_auto_spositiontaking_8 smallmoney,
			@master_auto_spositiontaking_9 smallmoney,
			@master_auto_spositiontaking_10 smallmoney,
			@master_auto_spositiontaking_9999 smallmoney,
			
			@master_auto_slivepositiontaking_1 smallmoney,
			@master_auto_slivepositiontaking_3 smallmoney,
			@master_auto_slivepositiontaking_7 smallmoney,
			@master_auto_slivepositiontaking_8 smallmoney,
			
			@master_auto_v2spositiontaking_1 smallmoney,
			@master_auto_v2spositiontaking_2 smallmoney,
			@master_auto_v2spositiontaking_3 smallmoney,
			@master_auto_v2spositiontaking_7 smallmoney,
			@master_auto_v2spositiontaking_8 smallmoney,
		--	@master_auto_v2spositiontaking_9 smallmoney,
			@master_auto_v2spositiontaking_20 smallmoney,
			
			@master_auto_v3spositiontaking_1 smallmoney,
			@master_auto_v3spositiontaking_2 smallmoney,
			@master_auto_v3spositiontaking_3 smallmoney,
			@master_auto_v3spositiontaking_20 smallmoney,

			@master_auto_v5spositiontaking_1 smallmoney,
			@master_auto_v5spositiontaking_2 smallmoney,
			@master_auto_v5spositiontaking_3 smallmoney,
			@master_auto_v5spositiontaking_20 smallmoney,
			@master_auto_v5spositiontaking_9999 smallmoney,

			@master_auto_v8spositiontaking_1 smallmoney,
			@master_auto_v8spositiontaking_3 smallmoney,
			@master_auto_v8spositiontaking_20 smallmoney,

			@master_auto_v10spositiontaking_1 smallmoney,
			@master_auto_v10spositiontaking_2 smallmoney,
			@master_auto_v10spositiontaking_3 smallmoney,
			@master_auto_v10spositiontaking_20 smallmoney,

			@master_auto_v11spositiontaking_1 smallmoney,
			@master_auto_v11spositiontaking_20 smallmoney,

			@master_auto_v99spositiontaking_1 smallmoney,
			@master_auto_v99spositiontaking_2 smallmoney,
			@master_auto_v99spositiontaking_3 smallmoney,
			@master_auto_v99spositiontaking_20 smallmoney,

			-- mixed sports
			@master_auto_v99spositiontaking_9 smallmoney,
			@master_auto_v154spositiontaking_20 smallmoney,

			@master_isauto_spositiontaking_1 bit,
			@master_isauto_spositiontaking_2 bit,
			@master_isauto_spositiontaking_3 bit,
			@master_isauto_spositiontaking_4 bit,
			@master_isauto_spositiontaking_5 bit,
			@master_isauto_spositiontaking_6 bit,
			@master_isauto_spositiontaking_7 bit,
			@master_isauto_spositiontaking_8 bit,
			@master_isauto_spositiontaking_9 bit,
			@master_isauto_spositiontaking_10 bit,
			@master_isauto_spositiontaking_9999 bit,
			
			@master_isauto_slivepositiontaking_1 bit,
			@master_isauto_slivepositiontaking_3 bit,
			@master_isauto_slivepositiontaking_7 bit,
			@master_isauto_slivepositiontaking_8 bit,
			
			@master_isauto_v2spositiontaking_1 bit,
			@master_isauto_v2spositiontaking_2 bit,
			@master_isauto_v2spositiontaking_3 bit,
			@master_isauto_v2spositiontaking_7 bit,
			@master_isauto_v2spositiontaking_8 bit,
		--	@master_isauto_v2spositiontaking_9 bit,
			@master_isauto_v2spositiontaking_20 bit,

			@master_isauto_v3spositiontaking_1 bit,
			@master_isauto_v3spositiontaking_2 bit,
			@master_isauto_v3spositiontaking_3 bit,
			@master_isauto_v3spositiontaking_20 bit,

			@master_isauto_v5spositiontaking_1 bit,
			@master_isauto_v5spositiontaking_2 bit,
			@master_isauto_v5spositiontaking_3 bit,
			@master_isauto_v5spositiontaking_20 bit,
			@master_isauto_v5spositiontaking_9999 bit,

			@master_isauto_v8spositiontaking_1 bit,
			@master_isauto_v8spositiontaking_3 bit,
			@master_isauto_v8spositiontaking_20 bit,

			@master_isauto_v10spositiontaking_1 bit,
			@master_isauto_v10spositiontaking_2 bit,
			@master_isauto_v10spositiontaking_3 bit,
			@master_isauto_v10spositiontaking_20 bit,

			@master_isauto_v11spositiontaking_1 bit,
			@master_isauto_v11spositiontaking_20 bit,

			@master_isauto_v99spositiontaking_1 bit,
			@master_isauto_v99spositiontaking_2 bit,
			@master_isauto_v99spositiontaking_3 bit,
			@master_isauto_v99spositiontaking_20 bit,

			-- mixed sports
			@master_isauto_v99spositiontaking_9 bit,
			@master_isauto_v154spositiontaking_20 bit,
			
			-- Outright PT for sports
			@old_auto_v2spositiontaking_10 smallmoney,
			@old_auto_v3spositiontaking_10 smallmoney,
			@old_auto_v5spositiontaking_10 smallmoney,
			@old_auto_v8spositiontaking_10 smallmoney,
			@old_auto_v10spositiontaking_10 smallmoney,
			@old_auto_v11spositiontaking_10 smallmoney,
			@old_auto_v99spositiontaking_10 smallmoney,
			
			@old_isauto_v2spositiontaking_10 bit,
			@old_isauto_v3spositiontaking_10 bit,
			@old_isauto_v5spositiontaking_10 bit,
			@old_isauto_v8spositiontaking_10 bit,
			@old_isauto_v10spositiontaking_10 bit,
			@old_isauto_v11spositiontaking_10 bit,
			@old_isauto_v99spositiontaking_10 bit,
			
			@master_auto_v2spositiontaking_10 smallmoney,
			@master_auto_v3spositiontaking_10 smallmoney,
			@master_auto_v5spositiontaking_10 smallmoney,
			@master_auto_v8spositiontaking_10 smallmoney,
			@master_auto_v10spositiontaking_10 smallmoney,
			@master_auto_v11spositiontaking_10 smallmoney,
			@master_auto_v99spositiontaking_10 smallmoney,
			
			@master_isauto_v2spositiontaking_10 bit,
			@master_isauto_v3spositiontaking_10 bit,
			@master_isauto_v5spositiontaking_10 bit,
			@master_isauto_v8spositiontaking_10 bit,
			@master_isauto_v10spositiontaking_10 bit,
			@master_isauto_v11spositiontaking_10 bit,
			@master_isauto_v99spositiontaking_10 bit

		
		--Get old Auto PT of Member
		if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
				BEGIN --@UpdatePositiontaking 
					
					select 	@old_auto_spositiontaking_1	=	autopositiontaking		,	@old_isauto_spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=1
					select 	@old_auto_spositiontaking_2	=	autopositiontaking		,	@old_isauto_spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=2
					select 	@old_auto_spositiontaking_3	=	autopositiontaking		,	@old_isauto_spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=3
					select 	@old_auto_spositiontaking_4	=	autopositiontaking		,	@old_isauto_spositiontaking_4	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=4
					select 	@old_auto_spositiontaking_5	=	autopositiontaking		,	@old_isauto_spositiontaking_5	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=5
					select 	@old_auto_spositiontaking_6	=	autopositiontaking		,	@old_isauto_spositiontaking_6	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=6
					select 	@old_auto_spositiontaking_7	=	autopositiontaking		,	@old_isauto_spositiontaking_7	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=7
					select 	@old_auto_spositiontaking_8	=	autopositiontaking		,	@old_isauto_spositiontaking_8	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=8
					select 	@old_auto_spositiontaking_9	=	autopositiontaking		,	@old_isauto_spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=9
					select 	@old_auto_spositiontaking_10	=	autopositiontaking		,	@old_isauto_spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=10
					select 	@old_auto_spositiontaking_9999	=	autopositiontaking		,	@old_isauto_spositiontaking_9999	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=9999
					select 	@old_auto_slivepositiontaking_1	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_1	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=1
					select 	@old_auto_slivepositiontaking_3	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_3	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=3
					select 	@old_auto_slivepositiontaking_7	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_7	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=7
					select 	@old_auto_slivepositiontaking_8	=	autolivepositiontaking		,	@old_isauto_slivepositiontaking_8	=	isautolivepositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=1	and bettype=8
				END  --@UpdatePositiontaking 

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
				BEGIN --UpdatePositiontakingv2 
					select 	@old_auto_v2spositiontaking_1	=	autopositiontaking		,	@old_isauto_v2spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=1
					select 	@old_auto_v2spositiontaking_2	=	autopositiontaking		,	@old_isauto_v2spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=2
					select 	@old_auto_v2spositiontaking_3	=	autopositiontaking		,	@old_isauto_v2spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=3
					select 	@old_auto_v2spositiontaking_7	=	autopositiontaking		,	@old_isauto_v2spositiontaking_7	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=7
					select 	@old_auto_v2spositiontaking_8	=	autopositiontaking		,	@old_isauto_v2spositiontaking_8	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=8
					--select 	@old_auto_v2spositiontaking_9	=	autopositiontaking		,	@old_isauto_v2spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=9
					select 	@old_auto_v2spositiontaking_10	=	autopositiontaking		,	@old_isauto_v2spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=10
					select 	@old_auto_v2spositiontaking_20	=	autopositiontaking		,	@old_isauto_v2spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=20
				END  --UpdatePositiontakingv2 

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
				BEGIN --UpdatePositiontakingv3 
					select 	@old_auto_v3spositiontaking_1	=	autopositiontaking		,	@old_isauto_v3spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=1
					select 	@old_auto_v3spositiontaking_2	=	autopositiontaking		,	@old_isauto_v3spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=2
					select 	@old_auto_v3spositiontaking_3	=	autopositiontaking		,	@old_isauto_v3spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=3
					select 	@old_auto_v3spositiontaking_10	=	autopositiontaking		,	@old_isauto_v3spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=10
					select 	@old_auto_v3spositiontaking_20	=	autopositiontaking		,	@old_isauto_v3spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=20
				END  --UpdatePositiontakingv3

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1)
				BEGIN --UpdatePositiontakingv5 
					select 	@old_auto_v5spositiontaking_1	=	autopositiontaking		,	@old_isauto_v5spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=1
					select 	@old_auto_v5spositiontaking_2	=	autopositiontaking		,	@old_isauto_v5spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=2
					select 	@old_auto_v5spositiontaking_3	=	autopositiontaking		,	@old_isauto_v5spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=3
					select 	@old_auto_v5spositiontaking_10	=	autopositiontaking		,	@old_isauto_v5spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=10
					select 	@old_auto_v5spositiontaking_20	=	autopositiontaking		,	@old_isauto_v5spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=20
					select 	@old_auto_v5spositiontaking_9999	=	autopositiontaking		,	@old_isauto_v5spositiontaking_9999	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=9999
				END  --UpdatePositiontakingv5

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1)
				BEGIN --UpdatePositiontakingv8 
					select 	@old_auto_v8spositiontaking_1	=	autopositiontaking		,	@old_isauto_v8spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=1
					select 	@old_auto_v8spositiontaking_3	=	autopositiontaking		,	@old_isauto_v8spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=3
					select 	@old_auto_v8spositiontaking_10	=	autopositiontaking		,	@old_isauto_v8spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=10
					select 	@old_auto_v8spositiontaking_20	=	autopositiontaking		,	@old_isauto_v8spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=20
				END  --UpdatePositiontakingv8

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1)
				BEGIN --UpdatePositiontakingv10 
					select 	@old_auto_v10spositiontaking_1	=	autopositiontaking		,	@old_isauto_v10spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=1
					select 	@old_auto_v10spositiontaking_2	=	autopositiontaking		,	@old_isauto_v10spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=2
					select 	@old_auto_v10spositiontaking_3	=	autopositiontaking		,	@old_isauto_v10spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=3
					select 	@old_auto_v10spositiontaking_10	=	autopositiontaking		,	@old_isauto_v10spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=10
					select 	@old_auto_v10spositiontaking_20	=	autopositiontaking		,	@old_isauto_v10spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=20
				END  --UpdatePositiontakingv10

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
				BEGIN --UpdatePositiontakingv11 
					select 	@old_auto_v11spositiontaking_1	=	autopositiontaking		,	@old_isauto_v11spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=1
					select 	@old_auto_v11spositiontaking_10	=	autopositiontaking		,	@old_isauto_v11spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=10
					select 	@old_auto_v11spositiontaking_20	=	autopositiontaking		,	@old_isauto_v11spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=20
				END  --UpdatePositiontakingv11

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1)
				BEGIN --UpdatePositiontakingv99 
					select 	@old_auto_v99spositiontaking_1	=	autopositiontaking		,	@old_isauto_v99spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=1
					select 	@old_auto_v99spositiontaking_2	=	autopositiontaking		,	@old_isauto_v99spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=2
					select 	@old_auto_v99spositiontaking_3	=	autopositiontaking		,	@old_isauto_v99spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=3
					select 	@old_auto_v99spositiontaking_10	=	autopositiontaking		,	@old_isauto_v99spositiontaking_10	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=10
					select 	@old_auto_v99spositiontaking_20	=	autopositiontaking		,	@old_isauto_v99spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=20
				END  --UpdatePositiontakingv99

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1)
				BEGIN --UpdatePositiontakingv99MP 
		-- mixed 
					select 	@old_auto_v99spositiontaking_9	=	autopositiontaking		,	@old_isauto_v99spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=9
				END  --UpdatePositiontakingv99MP
		
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1)
				BEGIN --UpdatePositiontakingv11 
					select 	@old_auto_v154spositiontaking_20	=	autopositiontaking		,	@old_isauto_v154spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=154	and bettype=20
				END  --UpdatePositiontakingv11
				
		--Get Auto PT of member from Master
		if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
				BEGIN --UpdatePositiontaking
					select @master_auto_spositiontaking_1 = autopositiontaking, @master_auto_slivepositiontaking_1 = autolivepositiontaking, @master_isauto_spositiontaking_1 = isautopositiontaking, @master_isauto_slivepositiontaking_1 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
					select @master_auto_spositiontaking_3 = autopositiontaking, @master_auto_slivepositiontaking_3 = autolivepositiontaking, @master_isauto_spositiontaking_3 = isautopositiontaking, @master_isauto_slivepositiontaking_3 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
					select @master_auto_spositiontaking_7 = autopositiontaking, @master_auto_slivepositiontaking_7 = autolivepositiontaking, @master_isauto_spositiontaking_7 = isautopositiontaking, @master_isauto_slivepositiontaking_7 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
					select @master_auto_spositiontaking_8 = autopositiontaking, @master_auto_slivepositiontaking_8 = autolivepositiontaking, @master_isauto_spositiontaking_8 = isautopositiontaking, @master_isauto_slivepositiontaking_8 = isautolivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1
					select @master_auto_spositiontaking_2 = autopositiontaking, @master_isauto_spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
					select @master_auto_spositiontaking_4 = autopositiontaking, @master_isauto_spositiontaking_4 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
					select @master_auto_spositiontaking_5 = autopositiontaking, @master_isauto_spositiontaking_5 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
					select @master_auto_spositiontaking_6 = autopositiontaking, @master_isauto_spositiontaking_6 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
					select @master_auto_spositiontaking_9 = autopositiontaking, @master_isauto_spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
					select @master_auto_spositiontaking_10 = autopositiontaking, @master_isauto_spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1
					select @master_auto_spositiontaking_9999 = autopositiontaking, @master_isauto_spositiontaking_9999 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=1
				END  --UpdatePositiontaking

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
				BEGIN --UpdatePositiontakingv2
					select @master_auto_v2spositiontaking_1 = autopositiontaking, @master_isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
					select @master_auto_v2spositiontaking_2 = autopositiontaking, @master_isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
					select @master_auto_v2spositiontaking_3 = autopositiontaking, @master_isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
					select @master_auto_v2spositiontaking_7 = autopositiontaking, @master_isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
					select @master_auto_v2spositiontaking_8 = autopositiontaking, @master_isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
					--select @master_auto_v2spositiontaking_9 = autopositiontaking, @master_isauto_v2spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
					select @master_auto_v2spositiontaking_10 = autopositiontaking, @master_isauto_v2spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=2
					select @master_auto_v2spositiontaking_20 = autopositiontaking, @master_isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2
				END  --UpdatePositiontakingv2

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
				BEGIN --UpdatePositiontakingv3
					select @master_auto_v3spositiontaking_1 = autopositiontaking, @master_isauto_v3spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=3
					select @master_auto_v3spositiontaking_2 = autopositiontaking, @master_isauto_v3spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=3
					select @master_auto_v3spositiontaking_3 = autopositiontaking, @master_isauto_v3spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=3
					select @master_auto_v3spositiontaking_10 = autopositiontaking, @master_isauto_v3spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=3
					select @master_auto_v3spositiontaking_20 = autopositiontaking, @master_isauto_v3spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=3
				END  --UpdatePositiontakingv3

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1)
				BEGIN --UpdatePositiontakingv5
					select @master_auto_v5spositiontaking_1 = autopositiontaking, @master_isauto_v5spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=5
					select @master_auto_v5spositiontaking_2 = autopositiontaking, @master_isauto_v5spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=5
					select @master_auto_v5spositiontaking_3 = autopositiontaking, @master_isauto_v5spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=5
					select @master_auto_v5spositiontaking_10 = autopositiontaking, @master_isauto_v5spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=5
					select @master_auto_v5spositiontaking_20 = autopositiontaking, @master_isauto_v5spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=5
					select @master_auto_v5spositiontaking_9999 = autopositiontaking, @master_isauto_v5spositiontaking_9999 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=5
				END  --UpdatePositiontakingv5

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1)
				BEGIN --UpdatePositiontakingv8
					select @master_auto_v8spositiontaking_1 = autopositiontaking, @master_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=8
					select @master_auto_v8spositiontaking_3 = autopositiontaking, @master_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=8
					select @master_auto_v8spositiontaking_10 = autopositiontaking, @master_isauto_v8spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=8
					select @master_auto_v8spositiontaking_20 = autopositiontaking, @master_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=8
				END  --UpdatePositiontakingv8

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1)
				BEGIN --UpdatePositiontakingv10
					select @master_auto_v10spositiontaking_1 = autopositiontaking, @master_isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
					select @master_auto_v10spositiontaking_2 = autopositiontaking, @master_isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
					select @master_auto_v10spositiontaking_3 = autopositiontaking, @master_isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
					select @master_auto_v10spositiontaking_10 = autopositiontaking, @master_isauto_v10spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=10
					select @master_auto_v10spositiontaking_20 = autopositiontaking, @master_isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10
				END  --UpdatePositiontakingv10

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
				BEGIN --UpdatePositiontakingv11
					select @master_auto_v11spositiontaking_1 = autopositiontaking, @master_isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
					select @master_auto_v11spositiontaking_10 = autopositiontaking, @master_isauto_v11spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=11
					select @master_auto_v11spositiontaking_20 = autopositiontaking, @master_isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11
				END  --UpdatePositiontakingv11

		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1)
				BEGIN --UpdatePositiontakingv99
					select @master_auto_v99spositiontaking_1 = autopositiontaking, @master_isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
					select @master_auto_v99spositiontaking_2 = autopositiontaking, @master_isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
					select @master_auto_v99spositiontaking_3 = autopositiontaking, @master_isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
					select @master_auto_v99spositiontaking_10 = autopositiontaking, @master_isauto_v99spositiontaking_10 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=99
					select @master_auto_v99spositiontaking_20 = autopositiontaking, @master_isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99
				END  --UpdatePositiontakingv99

		-- mixed sports
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1)
				BEGIN --UpdatePositiontakingv99MP
					select @master_auto_v99spositiontaking_9 = autopositiontaking, @master_isauto_v99spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=99
				END  --UpdatePositiontakingv99MP
	
		if (@UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1)
				BEGIN --UpdatePositiontakingv154
					select @master_auto_v154spositiontaking_20 = autopositiontaking, @master_isauto_v154spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=154
				END  --UpdatePositiontakingv154
		
		--Update Member account (autopositiontaking field)
		update cs
		SET  autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
		from @tmp_cs cs			
			inner join (
						select 1 as bettype, 1 as sporttype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1	as autolivepositiontaking, @isauto_spositiontaking_1 as isautopositiontaking, @isauto_slivepositiontaking_1	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 2 as bettype, 1 as sporttype, @auto_spositiontaking_2 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_2 as isautopositiontaking, 0				as isautolivepositiontaking  WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 3 as bettype, 1 as sporttype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3 	as autolivepositiontaking, @isauto_spositiontaking_3 as isautopositiontaking, @isauto_slivepositiontaking_3	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 4 as bettype, 1 as sporttype, @auto_spositiontaking_4 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_4 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 5 as bettype, 1 as sporttype, @auto_spositiontaking_5 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_5 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 6 as bettype, 1 as sporttype, @auto_spositiontaking_6 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_6 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 7 as bettype, 1 as sporttype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7 	as autolivepositiontaking, @isauto_spositiontaking_7 as isautopositiontaking, @isauto_slivepositiontaking_7	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 8 as bettype, 1 as sporttype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8 	as autolivepositiontaking, @isauto_spositiontaking_8 as isautopositiontaking, @isauto_slivepositiontaking_8	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 9 as bettype, 1 as sporttype, @auto_spositiontaking_9 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_9 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 10 as bettype, 1 as sporttype, @auto_spositiontaking_10 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_10 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				union all 	select 9999 as bettype, 1 as sporttype, @auto_spositiontaking_9999 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_9999 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
				
				-- Outright PT for sports
				union all 	select 10 as bettype, 2 as sporttype, @auto_v2spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v2spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				union all 	select 10 as bettype, 3 as sporttype, @auto_v3spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v3spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
				union all 	select 10 as bettype, 5 as sporttype, @auto_v5spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v5spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
				union all 	select 10 as bettype, 8 as sporttype, @auto_v8spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v8spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
				union all 	select 10 as bettype, 10 as sporttype, @auto_v10spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v10spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
				union all 	select 10 as bettype, 11 as sporttype, @auto_v11spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v11spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1
				union all 	select 10 as bettype, 99 as sporttype, @auto_v99spositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v99spositiontaking_10 as isautopositiontaking, 0 as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
				
				union all 	select 1 as bettype, 2 as sporttype, @auto_v2spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				union all 	select 2 as bettype, 2 as sporttype, @auto_v2spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				union all 	select 3 as bettype, 2 as sporttype, @auto_v2spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				union all 	select 7 as bettype, 2 as sporttype, @auto_v2spositiontaking_7 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_7 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				union all 	select 8 as bettype, 2 as sporttype, @auto_v2spositiontaking_8 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_8 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
--				union all 	select 9 as bettype, 2 as sporttype, @auto_v2spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				union all 	select 20 as bettype, 2 as sporttype, @auto_v2spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
				
				union all 	select 1 as bettype, 3 as sporttype, @auto_v3spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
				union all 	select 2 as bettype, 3 as sporttype, @auto_v3spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
				union all 	select 3 as bettype, 3 as sporttype, @auto_v3spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
				union all 	select 20 as bettype, 3 as sporttype, @auto_v3spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1

				union all 	select 1 as bettype, 5 as sporttype, @auto_v5spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
				union all 	select 2 as bettype, 5 as sporttype, @auto_v5spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
				union all 	select 3 as bettype, 5 as sporttype, @auto_v5spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
				union all 	select 20 as bettype, 5 as sporttype, @auto_v5spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
				union all 	select 9999 as bettype, 5 as sporttype, @auto_v5spositiontaking_9999 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_9999 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1

				union all 	select 1 as bettype, 8 as sporttype, @auto_v8spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
				union all 	select 3 as bettype, 8 as sporttype, @auto_v8spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
				union all 	select 20 as bettype, 8 as sporttype, @auto_v8spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1

				union all 	select 1 as bettype, 10 as sporttype, @auto_v10spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
				union all 	select 2 as bettype, 10 as sporttype, @auto_v10spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
				union all 	select 3 as bettype, 10 as sporttype, @auto_v10spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
				union all 	select 20 as bettype, 10 as sporttype, @auto_v10spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1

				union all 	select 1 as bettype, 11 as sporttype, @auto_v11spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1
				union all 	select 20 as bettype, 11 as sporttype, @auto_v11spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1

				union all 	select 1 as bettype, 99 as sporttype, @auto_v99spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
				union all 	select 2 as bettype, 99 as sporttype, @auto_v99spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
				union all 	select 3 as bettype, 99 as sporttype, @auto_v99spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
				union all 	select 20 as bettype, 99 as sporttype, @auto_v99spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1

				-- mixed sports
				union all 	select 9 as bettype, 99 as sporttype, @auto_v99spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1
				union all 	select 20 as bettype, 154 as sporttype, @auto_v154spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v154spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1
			
			) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
	
	
		/*	--Update Member account (autopositiontaking field)
			update custsetting with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
			from custsetting inner join 
					(
								select 1 as bettype, 1 as sporttype, @auto_spositiontaking_1 as autopositiontaking, @auto_slivepositiontaking_1	as autolivepositiontaking, @isauto_spositiontaking_1 as isautopositiontaking, @isauto_slivepositiontaking_1	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 2 as bettype, 1 as sporttype, @auto_spositiontaking_2 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_2 as isautopositiontaking, 0				as isautolivepositiontaking  WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 3 as bettype, 1 as sporttype, @auto_spositiontaking_3 as autopositiontaking, @auto_slivepositiontaking_3 	as autolivepositiontaking, @isauto_spositiontaking_3 as isautopositiontaking, @isauto_slivepositiontaking_3	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 4 as bettype, 1 as sporttype, @auto_spositiontaking_4 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_4 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 5 as bettype, 1 as sporttype, @auto_spositiontaking_5 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_5 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 6 as bettype, 1 as sporttype, @auto_spositiontaking_6 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_6 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 7 as bettype, 1 as sporttype, @auto_spositiontaking_7 as autopositiontaking, @auto_slivepositiontaking_7 	as autolivepositiontaking, @isauto_spositiontaking_7 as isautopositiontaking, @isauto_slivepositiontaking_7	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 8 as bettype, 1 as sporttype, @auto_spositiontaking_8 as autopositiontaking, @auto_slivepositiontaking_8 	as autolivepositiontaking, @isauto_spositiontaking_8 as isautopositiontaking, @isauto_slivepositiontaking_8	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 9 as bettype, 1 as sporttype, @auto_spositiontaking_9 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_9 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						union all 	select 10 as bettype, 1 as sporttype, @auto_spositiontaking_10 as autopositiontaking, 0				as autolivepositiontaking, @isauto_spositiontaking_10 as isautopositiontaking, 0				as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontaking = 1
						
						union all 	select 1 as bettype, 2 as sporttype, @auto_v2spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
						union all 	select 2 as bettype, 2 as sporttype, @auto_v2spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
						union all 	select 3 as bettype, 2 as sporttype, @auto_v2spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
						union all 	select 7 as bettype, 2 as sporttype, @auto_v2spositiontaking_7 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_7 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
						union all 	select 8 as bettype, 2 as sporttype, @auto_v2spositiontaking_8 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_8 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
		--				union all 	select 9 as bettype, 2 as sporttype, @auto_v2spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
						union all 	select 20 as bettype, 2 as sporttype, @auto_v2spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
						
						union all 	select 1 as bettype, 3 as sporttype, @auto_v3spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
						union all 	select 2 as bettype, 3 as sporttype, @auto_v3spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
						union all 	select 3 as bettype, 3 as sporttype, @auto_v3spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
						union all 	select 20 as bettype, 3 as sporttype, @auto_v3spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1

						union all 	select 1 as bettype, 5 as sporttype, @auto_v5spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
						union all 	select 2 as bettype, 5 as sporttype, @auto_v5spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
						union all 	select 3 as bettype, 5 as sporttype, @auto_v5spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
						union all 	select 20 as bettype, 5 as sporttype, @auto_v5spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1

						union all 	select 1 as bettype, 8 as sporttype, @auto_v8spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
						union all 	select 3 as bettype, 8 as sporttype, @auto_v8spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
						union all 	select 20 as bettype, 8 as sporttype, @auto_v8spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1

						union all 	select 1 as bettype, 10 as sporttype, @auto_v10spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
						union all 	select 2 as bettype, 10 as sporttype, @auto_v10spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
						union all 	select 3 as bettype, 10 as sporttype, @auto_v10spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
						union all 	select 20 as bettype, 10 as sporttype, @auto_v10spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1

						union all 	select 1 as bettype, 11 as sporttype, @auto_v11spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1
						union all 	select 20 as bettype, 11 as sporttype, @auto_v11spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1

						union all 	select 1 as bettype, 99 as sporttype, @auto_v99spositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
						union all 	select 2 as bettype, 99 as sporttype, @auto_v99spositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
						union all 	select 3 as bettype, 99 as sporttype, @auto_v99spositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
						union all 	select 20 as bettype, 99 as sporttype, @auto_v99spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1

						-- mixed sports
						union all 	select 9 as bettype, 99 as sporttype, @auto_v99spositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99spositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1
						union all 	select 20 as bettype, 154 as sporttype, @auto_v154spositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v154spositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking WHERE @UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1
					
					) as b on b.bettype = custsetting.bettype and b.sporttype = custsetting.sporttype
			where custsetting.custid = @custid
			*/
			--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
			select 
				@auto_spositiontaking_1 = case when @isauto_spositiontaking_1>0 then @auto_spositiontaking_1 else @master_auto_spositiontaking_1 end,
				@auto_spositiontaking_2 = case when @isauto_spositiontaking_2>0 then @auto_spositiontaking_2 else @master_auto_spositiontaking_2 end,
				@auto_spositiontaking_3 = case when @isauto_spositiontaking_3>0 then @auto_spositiontaking_3 else @master_auto_spositiontaking_3 end,
				@auto_spositiontaking_4 = case when @isauto_spositiontaking_4>0 then @auto_spositiontaking_4 else @master_auto_spositiontaking_4 end,
				@auto_spositiontaking_5 = case when @isauto_spositiontaking_5>0 then @auto_spositiontaking_5 else @master_auto_spositiontaking_5 end,
				@auto_spositiontaking_6 = case when @isauto_spositiontaking_6>0 then @auto_spositiontaking_6 else @master_auto_spositiontaking_6 end,
				@auto_spositiontaking_7 = case when @isauto_spositiontaking_7>0 then @auto_spositiontaking_7 else @master_auto_spositiontaking_7 end,
				@auto_spositiontaking_8 = case when @isauto_spositiontaking_8>0 then @auto_spositiontaking_8 else @master_auto_spositiontaking_8 end,
				@auto_spositiontaking_9 = case when @isauto_spositiontaking_9>0 then @auto_spositiontaking_9 else @master_auto_spositiontaking_9 end,
				@auto_spositiontaking_10 = case when @isauto_spositiontaking_10>0 then @auto_spositiontaking_10 else @master_auto_spositiontaking_10 end,
				-- Outright PT for sports
				@auto_v2spositiontaking_10 = case when @isauto_v2spositiontaking_10>0 then @auto_v2spositiontaking_10 else @master_auto_v2spositiontaking_10 end,
				@auto_v3spositiontaking_10 = case when @isauto_v3spositiontaking_10>0 then @auto_v3spositiontaking_10 else @master_auto_v3spositiontaking_10 end,
				@auto_v5spositiontaking_10 = case when @isauto_v5spositiontaking_10>0 then @auto_v5spositiontaking_10 else @master_auto_v5spositiontaking_10 end,
				@auto_v8spositiontaking_10 = case when @isauto_v8spositiontaking_10>0 then @auto_v8spositiontaking_10 else @master_auto_v8spositiontaking_10 end,
				@auto_v10spositiontaking_10 = case when @isauto_v10spositiontaking_10>0 then @auto_v10spositiontaking_10 else @master_auto_v10spositiontaking_10 end,
				@auto_v11spositiontaking_10 = case when @isauto_v11spositiontaking_10>0 then @auto_v11spositiontaking_10 else @master_auto_v11spositiontaking_10 end,
				@auto_v99spositiontaking_10 = case when @isauto_v99spositiontaking_10>0 then @auto_v99spositiontaking_10 else @master_auto_v99spositiontaking_10 end,
				
				@auto_spositiontaking_9999 = case when @isauto_spositiontaking_9999>0 then @auto_spositiontaking_9999 else @master_auto_spositiontaking_9999 end,
			
				@auto_slivepositiontaking_1 = case when @isauto_slivepositiontaking_1>0 then @auto_slivepositiontaking_1 else @master_auto_slivepositiontaking_1 end,
				@auto_slivepositiontaking_3 = case when @isauto_slivepositiontaking_3>0 then @auto_slivepositiontaking_3 else @master_auto_slivepositiontaking_3 end,
				@auto_slivepositiontaking_7 = case when @isauto_slivepositiontaking_7>0 then @auto_slivepositiontaking_7 else @master_auto_slivepositiontaking_7 end,
				@auto_slivepositiontaking_8 = case when @isauto_slivepositiontaking_8>0 then @auto_slivepositiontaking_8 else @master_auto_slivepositiontaking_8 end,
			
				@auto_v2spositiontaking_1 = case when @isauto_v2spositiontaking_1>0 then @auto_v2spositiontaking_1 else @master_auto_v2spositiontaking_1 end,
				@auto_v2spositiontaking_2 = case when @isauto_v2spositiontaking_2>0 then @auto_v2spositiontaking_2 else @master_auto_v2spositiontaking_2 end,
				@auto_v2spositiontaking_3 = case when @isauto_v2spositiontaking_3>0 then @auto_v2spositiontaking_3 else @master_auto_v2spositiontaking_3 end,
				@auto_v2spositiontaking_7 = case when @isauto_v2spositiontaking_7>0 then @auto_v2spositiontaking_7 else @master_auto_v2spositiontaking_7 end,
				@auto_v2spositiontaking_8 = case when @isauto_v2spositiontaking_8>0 then @auto_v2spositiontaking_8 else @master_auto_v2spositiontaking_8 end,
		--		@auto_v2spositiontaking_9 = case when @isauto_v2spositiontaking_9>0 then @auto_v2spositiontaking_9 else @master_auto_v2spositiontaking_9 end,
				@auto_v2spositiontaking_20 = case when @isauto_v2spositiontaking_20>0 then @auto_v2spositiontaking_20 else @master_auto_v2spositiontaking_20 end,

				@auto_v3spositiontaking_1 = case when @isauto_v3spositiontaking_1>0 then @auto_v3spositiontaking_1 else @master_auto_v3spositiontaking_1 end,
				@auto_v3spositiontaking_2 = case when @isauto_v3spositiontaking_2>0 then @auto_v3spositiontaking_2 else @master_auto_v3spositiontaking_2 end,
				@auto_v3spositiontaking_3 = case when @isauto_v3spositiontaking_3>0 then @auto_v3spositiontaking_3 else @master_auto_v3spositiontaking_3 end,
				@auto_v3spositiontaking_20 = case when @isauto_v3spositiontaking_20>0 then @auto_v3spositiontaking_20 else @master_auto_v3spositiontaking_20 end,

				@auto_v5spositiontaking_1 = case when @isauto_v5spositiontaking_1>0 then @auto_v5spositiontaking_1 else @master_auto_v5spositiontaking_1 end,
				@auto_v5spositiontaking_2 = case when @isauto_v5spositiontaking_2>0 then @auto_v5spositiontaking_2 else @master_auto_v5spositiontaking_2 end,
				@auto_v5spositiontaking_3 = case when @isauto_v5spositiontaking_3>0 then @auto_v5spositiontaking_3 else @master_auto_v5spositiontaking_3 end,
				@auto_v5spositiontaking_20 = case when @isauto_v5spositiontaking_20>0 then @auto_v5spositiontaking_20 else @master_auto_v5spositiontaking_20 end,
				@auto_v5spositiontaking_9999 = case when @isauto_v5spositiontaking_9999>0 then @auto_v5spositiontaking_9999 else @master_auto_v5spositiontaking_9999 end,

				@auto_v8spositiontaking_1 = case when @isauto_v8spositiontaking_1>0 then @auto_v8spositiontaking_1 else @master_auto_v8spositiontaking_1 end,
				@auto_v8spositiontaking_3 = case when @isauto_v8spositiontaking_3>0 then @auto_v8spositiontaking_3 else @master_auto_v8spositiontaking_3 end,
				@auto_v8spositiontaking_20 = case when @isauto_v8spositiontaking_20>0 then @auto_v8spositiontaking_20 else @master_auto_v8spositiontaking_20 end,

				@auto_v10spositiontaking_1 = case when @isauto_v10spositiontaking_1>0 then @auto_v10spositiontaking_1 else @master_auto_v10spositiontaking_1 end,
				@auto_v10spositiontaking_2 = case when @isauto_v10spositiontaking_2>0 then @auto_v10spositiontaking_2 else @master_auto_v10spositiontaking_2 end,
				@auto_v10spositiontaking_3 = case when @isauto_v10spositiontaking_3>0 then @auto_v10spositiontaking_3 else @master_auto_v10spositiontaking_3 end,
				@auto_v10spositiontaking_20 = case when @isauto_v10spositiontaking_20>0 then @auto_v10spositiontaking_20 else @master_auto_v10spositiontaking_20 end,

				@auto_v11spositiontaking_1 = case when @isauto_v11spositiontaking_1>0 then @auto_v11spositiontaking_1 else @master_auto_v11spositiontaking_1 end,
				@auto_v11spositiontaking_20 = case when @isauto_v11spositiontaking_20>0 then @auto_v11spositiontaking_20 else @master_auto_v11spositiontaking_20 end,

				@auto_v99spositiontaking_1 = case when @isauto_v99spositiontaking_1>0 then @auto_v99spositiontaking_1 else @master_auto_v99spositiontaking_1 end,
				@auto_v99spositiontaking_2 = case when @isauto_v99spositiontaking_2>0 then @auto_v99spositiontaking_2 else @master_auto_v99spositiontaking_2 end,
				@auto_v99spositiontaking_3 = case when @isauto_v99spositiontaking_3>0 then @auto_v99spositiontaking_3 else @master_auto_v99spositiontaking_3 end,
				@auto_v99spositiontaking_20 = case when @isauto_v99spositiontaking_20>0 then @auto_v99spositiontaking_20 else @master_auto_v99spositiontaking_20 end,

				-- mixed sports
				@auto_v99spositiontaking_9 = case when @isauto_v99spositiontaking_9>0 then @auto_v99spositiontaking_9 else @master_auto_v99spositiontaking_9 end,
				@auto_v154spositiontaking_20 = case when @isauto_v154spositiontaking_20>0 then @auto_v154spositiontaking_20 else @master_auto_v154spositiontaking_20 end,
				
				@isauto_spositiontaking_1 = case when @isauto_spositiontaking_1>0 then @isauto_spositiontaking_1 else @master_isauto_spositiontaking_1 end,
				@isauto_spositiontaking_2 = case when @isauto_spositiontaking_2>0 then @isauto_spositiontaking_2 else @master_isauto_spositiontaking_2 end,
				@isauto_spositiontaking_3 = case when @isauto_spositiontaking_3>0 then @isauto_spositiontaking_3 else @master_isauto_spositiontaking_3 end,
				@isauto_spositiontaking_4 = case when @isauto_spositiontaking_4>0 then @isauto_spositiontaking_4 else @master_isauto_spositiontaking_4 end,
				@isauto_spositiontaking_5 = case when @isauto_spositiontaking_5>0 then @isauto_spositiontaking_5 else @master_isauto_spositiontaking_5 end,
				@isauto_spositiontaking_6 = case when @isauto_spositiontaking_6>0 then @isauto_spositiontaking_6 else @master_isauto_spositiontaking_6 end,
				@isauto_spositiontaking_7 = case when @isauto_spositiontaking_7>0 then @isauto_spositiontaking_7 else @master_isauto_spositiontaking_7 end,
				@isauto_spositiontaking_8 = case when @isauto_spositiontaking_8>0 then @isauto_spositiontaking_8 else @master_isauto_spositiontaking_8 end,
				@isauto_spositiontaking_9 = case when @isauto_spositiontaking_9>0 then @isauto_spositiontaking_9 else @master_isauto_spositiontaking_9 end,
				@isauto_spositiontaking_10 = case when @isauto_spositiontaking_10>0 then @isauto_spositiontaking_10 else @master_isauto_spositiontaking_10 end,
				
				-- outright PT for sports
				@isauto_v2spositiontaking_10 = case when @isauto_v2spositiontaking_10>0 then @isauto_v2spositiontaking_10 else @master_isauto_v2spositiontaking_10 end,
				@isauto_v3spositiontaking_10 = case when @isauto_v3spositiontaking_10>0 then @isauto_v3spositiontaking_10 else @master_isauto_v3spositiontaking_10 end,
				@isauto_v5spositiontaking_10 = case when @isauto_v5spositiontaking_10>0 then @isauto_v5spositiontaking_10 else @master_isauto_v5spositiontaking_10 end,
				@isauto_v8spositiontaking_10 = case when @isauto_v8spositiontaking_10>0 then @isauto_v8spositiontaking_10 else @master_isauto_v8spositiontaking_10 end,
				@isauto_v10spositiontaking_10 = case when @isauto_v10spositiontaking_10>0 then @isauto_v10spositiontaking_10 else @master_isauto_v10spositiontaking_10 end,
				@isauto_v11spositiontaking_10 = case when @isauto_v11spositiontaking_10>0 then @isauto_v11spositiontaking_10 else @master_isauto_v11spositiontaking_10 end,
				@isauto_v99spositiontaking_10 = case when @isauto_v99spositiontaking_10>0 then @isauto_v99spositiontaking_10 else @master_isauto_v99spositiontaking_10 end,
				
				@isauto_spositiontaking_9999 = case when @isauto_spositiontaking_9999>0 then @isauto_spositiontaking_9999 else @master_isauto_spositiontaking_9999 end,
			
				@isauto_slivepositiontaking_1 = case when @isauto_slivepositiontaking_1>0 then @isauto_slivepositiontaking_1 else @master_isauto_slivepositiontaking_1 end,
				@isauto_slivepositiontaking_3 = case when @isauto_slivepositiontaking_3>0 then @isauto_slivepositiontaking_3 else @master_isauto_slivepositiontaking_3 end,
				@isauto_slivepositiontaking_7 = case when @isauto_slivepositiontaking_7>0 then @isauto_slivepositiontaking_7 else @master_isauto_slivepositiontaking_7 end,
				@isauto_slivepositiontaking_8 = case when @isauto_slivepositiontaking_8>0 then @isauto_slivepositiontaking_8 else @master_isauto_slivepositiontaking_8 end,
			
				@isauto_v2spositiontaking_1 = case when @isauto_v2spositiontaking_1>0 then @isauto_v2spositiontaking_1 else @master_isauto_v2spositiontaking_1 end,
				@isauto_v2spositiontaking_2 = case when @isauto_v2spositiontaking_2>0 then @isauto_v2spositiontaking_2 else @master_isauto_v2spositiontaking_2 end,
				@isauto_v2spositiontaking_3 = case when @isauto_v2spositiontaking_3>0 then @isauto_v2spositiontaking_3 else @master_isauto_v2spositiontaking_3 end,
				@isauto_v2spositiontaking_7 = case when @isauto_v2spositiontaking_7>0 then @isauto_v2spositiontaking_7 else @master_isauto_v2spositiontaking_7 end,
				@isauto_v2spositiontaking_8 = case when @isauto_v2spositiontaking_8>0 then @isauto_v2spositiontaking_8 else @master_isauto_v2spositiontaking_8 end,
		--		@isauto_v2spositiontaking_9 = case when @isauto_v2spositiontaking_9>0 then @isauto_v2spositiontaking_9 else @master_isauto_v2spositiontaking_9 end,
				@isauto_v2spositiontaking_20 = case when @isauto_v2spositiontaking_20>0 then @isauto_v2spositiontaking_20 else @master_isauto_v2spositiontaking_20 end,

				@isauto_v3spositiontaking_1 = case when @isauto_v3spositiontaking_1>0 then @isauto_v3spositiontaking_1 else @master_isauto_v3spositiontaking_1 end,
				@isauto_v3spositiontaking_2 = case when @isauto_v3spositiontaking_2>0 then @isauto_v3spositiontaking_2 else @master_isauto_v3spositiontaking_2 end,
				@isauto_v3spositiontaking_3 = case when @isauto_v3spositiontaking_3>0 then @isauto_v3spositiontaking_3 else @master_isauto_v3spositiontaking_3 end,
				@isauto_v3spositiontaking_20 = case when @isauto_v3spositiontaking_20>0 then @isauto_v3spositiontaking_20 else @master_isauto_v3spositiontaking_20 end,

				@isauto_v5spositiontaking_1 = case when @isauto_v5spositiontaking_1>0 then @isauto_v5spositiontaking_1 else @master_isauto_v5spositiontaking_1 end,
				@isauto_v5spositiontaking_2 = case when @isauto_v5spositiontaking_2>0 then @isauto_v5spositiontaking_2 else @master_isauto_v5spositiontaking_2 end,
				@isauto_v5spositiontaking_3 = case when @isauto_v5spositiontaking_3>0 then @isauto_v5spositiontaking_3 else @master_isauto_v5spositiontaking_3 end,
				@isauto_v5spositiontaking_20 = case when @isauto_v5spositiontaking_20>0 then @isauto_v5spositiontaking_20 else @master_isauto_v5spositiontaking_20 end,
				@isauto_v5spositiontaking_9999 = case when @isauto_v5spositiontaking_9999>0 then @isauto_v5spositiontaking_9999 else @master_isauto_v5spositiontaking_9999 end,

				@isauto_v8spositiontaking_1 = case when @isauto_v8spositiontaking_1>0 then @isauto_v8spositiontaking_1 else @master_isauto_v8spositiontaking_1 end,
				@isauto_v8spositiontaking_3 = case when @isauto_v8spositiontaking_3>0 then @isauto_v8spositiontaking_3 else @master_isauto_v8spositiontaking_3 end,
				@isauto_v8spositiontaking_20 = case when @isauto_v8spositiontaking_20>0 then @isauto_v8spositiontaking_20 else @master_isauto_v8spositiontaking_20 end,

				@isauto_v10spositiontaking_1 = case when @isauto_v10spositiontaking_1>0 then @isauto_v10spositiontaking_1 else @master_isauto_v10spositiontaking_1 end,
				@isauto_v10spositiontaking_2 = case when @isauto_v10spositiontaking_2>0 then @isauto_v10spositiontaking_2 else @master_isauto_v10spositiontaking_2 end,
				@isauto_v10spositiontaking_3 = case when @isauto_v10spositiontaking_3>0 then @isauto_v10spositiontaking_3 else @master_isauto_v10spositiontaking_3 end,
				@isauto_v10spositiontaking_20 = case when @isauto_v10spositiontaking_20>0 then @isauto_v10spositiontaking_20 else @master_isauto_v10spositiontaking_20 end,

				@isauto_v11spositiontaking_1 = case when @isauto_v11spositiontaking_1>0 then @isauto_v11spositiontaking_1 else @master_isauto_v11spositiontaking_1 end,
				@isauto_v11spositiontaking_20 = case when @isauto_v11spositiontaking_20>0 then @isauto_v11spositiontaking_20 else @master_isauto_v11spositiontaking_20 end,

				@isauto_v99spositiontaking_1 = case when @isauto_v99spositiontaking_1>0 then @isauto_v99spositiontaking_1 else @master_isauto_v99spositiontaking_1 end,
				@isauto_v99spositiontaking_2 = case when @isauto_v99spositiontaking_2>0 then @isauto_v99spositiontaking_2 else @master_isauto_v99spositiontaking_2 end,
				@isauto_v99spositiontaking_3 = case when @isauto_v99spositiontaking_3>0 then @isauto_v99spositiontaking_3 else @master_isauto_v99spositiontaking_3 end,
				@isauto_v99spositiontaking_20 = case when @isauto_v99spositiontaking_20>0 then @isauto_v99spositiontaking_20 else @master_isauto_v99spositiontaking_20 end,

				-- mixed sports
				@isauto_v99spositiontaking_9 = case when @isauto_v99spositiontaking_9>0 then @isauto_v99spositiontaking_9 else @master_isauto_v99spositiontaking_9 end,
				@isauto_v154spositiontaking_20 = case when @isauto_v154spositiontaking_20>0 then @isauto_v154spositiontaking_20 else @master_isauto_v154spositiontaking_20 end


			--Update member account
			--Using Cursor (spositiontaking field)
			DECLARE CUR CURSOR FOR 
					select 1 as bettype	,	   @isauto_spositiontaking_1 as isautopositiontaking	,	  @isauto_slivepositiontaking_1 as isautolivepositiontaking	,	  @auto_spositiontaking_1 as autopositiontaking	,	   @auto_slivepositiontaking_1 as autolivepositiontaking	,	  @old_auto_spositiontaking_1 as old_autopositiontaking	    ,	   @old_auto_slivepositiontaking_1 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_1 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_1 as isautov2positiontaking	,	   @auto_v2spositiontaking_1 as autov2positiontaking	,	   @old_auto_v2spositiontaking_1 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_1 as isautov3positiontaking	,	   @auto_v3spositiontaking_1 as autov3positiontaking	,	   @old_auto_v3spositiontaking_1 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_1 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_1 as isautov5positiontaking	,	   @auto_v5spositiontaking_1 as autov5positiontaking	,	   @old_auto_v5spositiontaking_1 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_1 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_1 as isautov8positiontaking	,	   @auto_v8spositiontaking_1 as autov8positiontaking	,	   @old_auto_v8spositiontaking_1 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_1 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_1 as isautov10positiontaking	,	   @auto_v10spositiontaking_1 as autov10positiontaking	,	   @old_auto_v10spositiontaking_1 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_1 as isautov11positiontaking	,	   @auto_v11spositiontaking_1 as autov11positiontaking	,	   @old_auto_v11spositiontaking_1 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_1 as isautov99positiontaking	,		@auto_v99spositiontaking_1 as autov99positiontaking	,	   @old_auto_v99spositiontaking_1 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 2 as bettype	,	   @isauto_spositiontaking_2 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_2 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_2 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_2 as old_isautopositiontaking    	,										0 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_2 as isautov2positiontaking	,	   @auto_v2spositiontaking_2 as autov2positiontaking	,	     @old_auto_v2spositiontaking_2 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_2 as isautov3positiontaking	,	   @auto_v3spositiontaking_2 as autov3positiontaking	,	   @old_auto_v3spositiontaking_2 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_2 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_2 as isautov5positiontaking	,	   @auto_v5spositiontaking_2 as autov5positiontaking	,	   @old_auto_v5spositiontaking_2 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_2 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_2 as isautov10positiontaking	,	   @auto_v10spositiontaking_2 as autov10positiontaking	,	   @old_auto_v10spositiontaking_2 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_2 as isautov99positiontaking	,		@auto_v99spositiontaking_2 as autov99positiontaking	,	   @old_auto_v99spositiontaking_2 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all 	select 3 as bettype	,	   @isauto_spositiontaking_3 as isautopositiontaking	,	  @isauto_slivepositiontaking_3 as isautolivepositiontaking	,	  @auto_spositiontaking_3 as autopositiontaking	,	   @auto_slivepositiontaking_3 as autolivepositiontaking	,		@old_auto_spositiontaking_3 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_3 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_3 as old_isautopositiontaking	    ,		@old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_3 as isautov2positiontaking	,	   @auto_v2spositiontaking_3 as autov2positiontaking	,	   @old_auto_v2spositiontaking_3 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_3 as isautov3positiontaking	,	   @auto_v3spositiontaking_3 as autov3positiontaking	,	   @old_auto_v3spositiontaking_3 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_3 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_3 as isautov5positiontaking	,	   @auto_v5spositiontaking_3 as autov5positiontaking	,	   @old_auto_v5spositiontaking_3 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_3 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_3 as isautov8positiontaking	,	   @auto_v8spositiontaking_3 as autov8positiontaking	,	   @old_auto_v8spositiontaking_3 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_3 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_3 as isautov10positiontaking	,	   @auto_v10spositiontaking_3 as autov10positiontaking	,	   @old_auto_v10spositiontaking_3 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_3 as isautov99positiontaking	,		@auto_v99spositiontaking_3 as autov99positiontaking	,	   @old_auto_v99spositiontaking_3 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 4 as bettype	,	   @isauto_spositiontaking_4 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_4 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_4 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_4 as old_isautopositiontaking	,										 0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									    0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all 	select 5 as bettype	,	   @isauto_spositiontaking_5 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_5 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_5 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_5 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									  0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 6 as bettype	,	   @isauto_spositiontaking_6 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_6 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_6 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_6 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,								 0 as isautov2positiontaking	,								 0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,						     0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,						      0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,						             0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 7 as bettype	,	   @isauto_spositiontaking_7 as isautopositiontaking	,	  @isauto_slivepositiontaking_7 as isautolivepositiontaking	,	  @auto_spositiontaking_7 as autopositiontaking	,	   @auto_slivepositiontaking_7 as autolivepositiontaking	,		@old_auto_spositiontaking_7 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_7 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_7 as old_isautopositiontaking	    ,		 @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking	,		@isauto_v2spositiontaking_7 as isautov2positiontaking	,	   @auto_v2spositiontaking_7 as autov2positiontaking	,	   @old_auto_v2spositiontaking_7 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 8 as bettype	,	   @isauto_spositiontaking_8 as isautopositiontaking	,	  @isauto_slivepositiontaking_8 as isautolivepositiontaking	,	  @auto_spositiontaking_8 as autopositiontaking	,	   @auto_slivepositiontaking_8 as autolivepositiontaking	,		@old_auto_spositiontaking_8 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_8 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_8 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_8 as isautov2positiontaking	,	   @auto_v2spositiontaking_8 as autov2positiontaking	,	   @old_auto_v2spositiontaking_8 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 9 as bettype	,	   @isauto_spositiontaking_9 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_9 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_9 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_9 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,	/*@isauto_v2spositiontaking_9*/ 0 as isautov2positiontaking	,	/*@auto_v2spositiontaking_9*/ 0 as autov2positiontaking	,	/*@old_auto_v2spositiontaking_9*/ 0 as old_autov2positiontaking	,	/*@old_isauto_v2spositiontaking_9*/ 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	, 	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, @isauto_v99spositiontaking_9 as isautov99mppositiontaking	, @auto_v99spositiontaking_9 as autov99mppositiontaking	, @old_isauto_v99spositiontaking_9 as old_isautov99mppositiontaking	, @old_auto_v99spositiontaking_9 as old_autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		
		union all  	select 10 as bettype,	   @isauto_spositiontaking_10 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_10 as autopositiontaking,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_10 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_10 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,	@isauto_v2spositiontaking_10 as isautov2positiontaking	,	@auto_v2spositiontaking_10 as autov2positiontaking	,  @old_auto_v2spositiontaking_10 as old_autov2positiontaking				,	 @old_isauto_v2spositiontaking_10 as old_isautov2positiontaking	    ,	@isauto_v3spositiontaking_10	 as isautov3positiontaking,		@auto_v3spositiontaking_10 as autov3positiontaking	,	 @old_auto_v3spositiontaking_10 as old_autov3positiontaking		,		@old_isauto_v3spositiontaking_10 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_10 as isautov5positiontaking	,	@auto_v5spositiontaking_10 as autov5positiontaking	,	@old_auto_v5spositiontaking_10 as old_autov5positiontaking	,				@old_isauto_v5spositiontaking_10 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_10 as isautov8positiontaking	,	@auto_v8spositiontaking_10 as autov8positiontaking	,	@old_auto_v8spositiontaking_10 as old_autov8positiontaking	,				@old_isauto_v8spositiontaking_10 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_10 as isautov10positiontaking	,@auto_v10spositiontaking_10 as autov10positiontaking	,	@old_auto_v10spositiontaking_10 as old_autov10positiontaking	,	@old_isauto_v10spositiontaking_10 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_10 as isautov11positiontaking	,	@auto_v11spositiontaking_10 as autov11positiontaking	,	@old_auto_v11spositiontaking_10 as old_autov11positiontaking	,@old_isauto_v11spositiontaking_10 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_10 as isautov99positiontaking,		@auto_v99spositiontaking_10 as autov99positiontaking,	@old_auto_v99spositiontaking_10 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_10 as old_isautov99positiontaking		, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		
		union all  	select 9999 as bettype	,	   @isauto_spositiontaking_9999 as isautopositiontaking	,							0 as isautolivepositiontaking	,	  @auto_spositiontaking_9999 as autopositiontaking	,								0 as autolivepositiontaking	,		@old_auto_spositiontaking_9999 as old_autopositiontaking	,								  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_9999 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									  0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_9999 as isautov5positiontaking	,  @auto_v5spositiontaking_9999 as autov5positiontaking	,	   @old_auto_v5spositiontaking_9999 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_9999 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	, 	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking	,						  0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all 	select 20 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking  	,		@isauto_v2spositiontaking_20 as isautov2positiontaking	,	   @auto_v2spositiontaking_20 as autov2positiontaking	,	   @old_auto_v2spositiontaking_20 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_20 as isautov3positiontaking	,	   @auto_v3spositiontaking_20 as autov3positiontaking	,	   @old_auto_v3spositiontaking_20 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_20 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_20 as isautov5positiontaking	,	   @auto_v5spositiontaking_20 as autov5positiontaking	,	   @old_auto_v5spositiontaking_20 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_20 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_20 as isautov8positiontaking	,	   @auto_v8spositiontaking_20 as autov8positiontaking	,	   @old_auto_v8spositiontaking_20 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_20 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_20 as isautov10positiontaking,		@auto_v10spositiontaking_20 as autov10positiontaking,	   @old_auto_v10spositiontaking_20 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_20 as isautov11positiontaking,	   @auto_v11spositiontaking_20 as autov11positiontaking	,	   @old_auto_v11spositiontaking_20 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_20 as isautov99positiontaking,		@auto_v99spositiontaking_20 as autov99positiontaking,	   @old_auto_v99spositiontaking_20 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,@isauto_v154spositiontaking_20 AS isautov154positiontaking	,@auto_v154spositiontaking_20 AS autov154positiontaking	,@old_auto_v154spositiontaking_20 AS old_autov154positiontaking	,@old_isauto_v154spositiontaking_20 AS old_isautov154positiontaking
		union all  	select 21 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									  0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,							       0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								    0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
		union all  	select 22 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking							,0 AS old_autov154positiontaking								,0 AS old_isautov154positiontaking
			
			OPEN CUR

			FETCH NEXT FROM CUR INTO
				@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, 
				@old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking,
				
				@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking,	
				
				@isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking,	
				
				@isautov5positiontaking, @autov5positiontaking, @old_autov5positiontaking, @old_isautov5positiontaking,	
				@isautov8positiontaking, @autov8positiontaking, @old_autov8positiontaking, @old_isautov8positiontaking,	
				@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking,
				@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking,
				@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
				@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking,
				@isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking

			WHILE @@FETCH_STATUS = 0
			BEGIN
		--		if @autopositiontaking <> @old_autopositiontaking or @isautopositiontaking <> @old_isautopositiontaking 
		--		BEGIN			
				if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
				Begin --@UpdatePositiontaking
					if @isautopositiontaking >0
					BEGIN
						select @maxpos = spositiontaking from @tmp_sag where sporttype=1 and bettype = @bettype
						
						update cs
						SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
						from @tmp_cs cs
						where bettype = @bettype and sporttype = 1
						
						/*select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
						
						update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
						where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
						*/
					END
		--		END
				--Update LIVE
					if @bettype in (1,3,7,8) --and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking)
					BEGIN
						if @isautolivepositiontaking >0
						BEGIN
							select @maxpos = slivepositiontaking from @tmp_sag where sporttype=1 and bettype = @bettype
							
							update cs
							SET slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 1
							/*
							select @maxpos = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
							*/
						END
					END		
				End --@UpdatePositiontaking
				
				--Update Basketball
				if @bettype in (1,2,3,7,8,9,20,10) --and (@autov2positiontaking <> @old_autov2positiontaking or @isautov2positiontaking <> @old_isautov2positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
					Begin --@UpdatePositiontakingv2
						if @isautov2positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_sag where sporttype=2 and bettype = @bettype
							
							update cs
							set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 2
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=2 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=2
							*/
						END
					End --@UpdatePositiontakingv2
				END
				
				--Update Football
				if @bettype in (1,2,3,20,10) --and (@autov3positiontaking <> @old_autov3positiontaking or @isautov3positiontaking <> @old_isautov3positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
					Begin --@UpdatePositiontakingv3
						if @isautov3positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_sag where sporttype=3 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 3
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=3 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=3
							*/
						END
					End --@UpdatePositiontakingv3
				END

				--Update Tennis
				if @bettype in (1,2,3,20,10) --and (@autov5positiontaking <> @old_autov5positiontaking or @isautov5positiontaking <> @old_isautov5positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1)
					Begin --@UpdatePositiontakingv5
						if @isautov5positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_sag where sporttype=5 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 5
							
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=5 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=5
							*/
						END
					End--@UpdatePositiontakingv5
				END

				--Update Baseball
				if @bettype in (1,3,20,10) --and (@autov8positiontaking <> @old_autov8positiontaking or @isautov8positiontaking <> @old_isautov8positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1)
					Begin --@UpdatePositiontakingv8
						if @isautov8positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_sag where sporttype=8 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 8
							
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=8 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=8
							*/
						END
					End--@UpdatePositiontakingv8
				END

				--Update Golf
				if @bettype in (1,2,3,20,10) --and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1)
					Begin --@UpdatePositiontakingv10
						if @isautov10positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_sag where sporttype=10 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 10
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=10 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=10
							*/
						END
					End--@UpdatePositiontakingv10
				END

				--Update Motorsports
				if @bettype in (1,20,10) --and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
					Begin --@UpdatePositiontakingv11
						if @isautov11positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_sag where sporttype=11 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 11
							
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=11 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=11
							*/
						END
					End--@UpdatePositiontakingv11
				END

				--Update Other sports
				if @bettype in (1,2,3,20,10) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1)
					Begin --@UpdatePositiontakingv99
						if @isautov99positiontaking >0
						BEGIN
							select @maxpos = spositiontaking from @tmp_Sag where sporttype=99 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 99
							
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
							*/
						END
					End--@UpdatePositiontakingv99
				END

				-- Update mixed sports
				if @bettype = 9 --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
				BEGIN
					if (@UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1)
					Begin --@UpdatePositiontakingv99MP
						if @isautov99mppositiontaking > 0
						BEGIN
							select @maxpos = spositiontaking from @tmp_Sag where sporttype=99 and bettype = @bettype
							
							update cs
							SET spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 99
							
							/*
							select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
							
							update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
							from custsetting
							where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
							*/
						END
					END --@UpdatePositiontakingv99MP
				END
				
				-- Update HR Fixed Odds
				IF @bettype = 20 
				BEGIN
					IF @UpdateMultiple = 0 OR @UpdatePositiontakingv154 = 1
					BEGIN
						IF @isautov154positiontaking > 0
						BEGIN
							SELECT @maxpos = cs.spositiontaking FROM @tmp_Sag cs WHERE cs.bettype = @bettype AND cs.sporttype = 154
							
							update cs
							SET spositiontaking = CASE WHEN @maxpos - mpositiontaking - apositiontaking > @autov154positiontaking THEN @autov154positiontaking ELSE @maxpos - mpositiontaking - apositiontaking END
							from @tmp_cs cs
							where bettype = @bettype and sporttype = 154
							
							/*
							SELECT @maxpos = cs.spositiontaking FROM custSetting cs WITH (NOLOCK) WHERE cs.custid = @srecommend AND cs.bettype = @bettype AND cs.sporttype = 154
							
							UPDATE custSetting WITH(UPDLOCK, ROWLOCK)
							SET spositiontaking = CASE WHEN @maxpos - mpositiontaking - apositiontaking > @autov154positiontaking THEN @autov154positiontaking ELSE @maxpos - mpositiontaking - apositiontaking END
							from custsetting
							WHERE custid = @custid AND bettype = @bettype AND sporttype = 154
							*/
						END
					END
				END
				FETCH NEXT FROM CUR INTO			
					@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, @old_autopositiontaking, @old_autolivepositiontaking, @old_isautopositiontaking, @old_isautolivepositiontaking,
					@isautov2positiontaking, @autov2positiontaking, @old_autov2positiontaking, @old_isautov2positiontaking,	
					@isautov3positiontaking, @autov3positiontaking, @old_autov3positiontaking, @old_isautov3positiontaking,	
					@isautov5positiontaking, @autov5positiontaking, @old_autov5positiontaking, @old_isautov5positiontaking,	
					@isautov8positiontaking, @autov8positiontaking, @old_autov8positiontaking, @old_isautov8positiontaking,	
					@isautov10positiontaking, @autov10positiontaking, @old_autov10positiontaking, @old_isautov10positiontaking,
					@isautov11positiontaking, @autov11positiontaking, @old_autov11positiontaking, @old_isautov11positiontaking,
					@isautov99positiontaking, @autov99positiontaking, @old_autov99positiontaking, @old_isautov99positiontaking,
					@isautov99mppositiontaking, @autov99mppositiontaking, @old_autov99mppositiontaking, @old_isautov99mppositiontaking,
					@isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking

			END
			CLOSE CUR
			DEALLOCATE CUR
			
	END
	ELSE IF @roleid = 3
	BEGIN 
		declare 
			--um2
			@auto_mpositiontaking_1 smallmoney,
			@auto_mpositiontaking_2 smallmoney,
			@auto_mpositiontaking_3 smallmoney,
			@auto_mpositiontaking_4 smallmoney,
			@auto_mpositiontaking_5 smallmoney,
			@auto_mpositiontaking_6 smallmoney,
			@auto_mpositiontaking_7 smallmoney,
			@auto_mpositiontaking_8 smallmoney,
			@auto_mpositiontaking_9 smallmoney,
			@auto_mpositiontaking_10 smallmoney,
			@auto_mpositiontaking_9999 smallmoney,
			
			@auto_mlivepositiontaking_1 smallmoney,
			@auto_mlivepositiontaking_3 smallmoney,
			@auto_mlivepositiontaking_7 smallmoney,
			@auto_mlivepositiontaking_8 smallmoney,
			
			@auto_v2mpositiontaking_1 smallmoney,
			@auto_v2mpositiontaking_2 smallmoney,
			@auto_v2mpositiontaking_3 smallmoney,
			@auto_v2mpositiontaking_7 smallmoney,
			@auto_v2mpositiontaking_8 smallmoney,
		--	@auto_v2mpositiontaking_9 smallmoney,
			@auto_v2mpositiontaking_20 smallmoney,
			
			@auto_v3mpositiontaking_1 smallmoney,
			@auto_v3mpositiontaking_2 smallmoney,
			@auto_v3mpositiontaking_3 smallmoney,
			@auto_v3mpositiontaking_20 smallmoney,

			@auto_v5mpositiontaking_1 smallmoney,
			@auto_v5mpositiontaking_2 smallmoney,
			@auto_v5mpositiontaking_3 smallmoney,
			@auto_v5mpositiontaking_20 smallmoney,
			@auto_v5mpositiontaking_9999 smallmoney,

			@auto_v8mpositiontaking_1 smallmoney,
			@auto_v8mpositiontaking_3 smallmoney,
			@auto_v8mpositiontaking_20 smallmoney,

			@auto_v10mpositiontaking_1 smallmoney,
			@auto_v10mpositiontaking_2 smallmoney,
			@auto_v10mpositiontaking_3 smallmoney,
			@auto_v10mpositiontaking_20 smallmoney,

			@auto_v11mpositiontaking_1 smallmoney,
			@auto_v11mpositiontaking_20 smallmoney,

			@auto_v99mpositiontaking_1 smallmoney,
			@auto_v99mpositiontaking_2 smallmoney,
			@auto_v99mpositiontaking_3 smallmoney,
			@auto_v99mpositiontaking_20 smallmoney,
			
			-- mixed sports
			@auto_v99mpositiontaking_9 smallmoney,
			@auto_v154mpositiontaking_20 smallmoney,

			--im2
			@isauto_mpositiontaking_1 bit,
			@isauto_mpositiontaking_2 bit,
			@isauto_mpositiontaking_3 bit,
			@isauto_mpositiontaking_4 bit,
			@isauto_mpositiontaking_5 bit,
			@isauto_mpositiontaking_6 bit,
			@isauto_mpositiontaking_7 bit,
			@isauto_mpositiontaking_8 bit,
			@isauto_mpositiontaking_9 bit,
			@isauto_mpositiontaking_10 bit,
			@isauto_mpositiontaking_9999 bit,
			
			@isauto_mlivepositiontaking_1 bit,
			@isauto_mlivepositiontaking_3 bit,
			@isauto_mlivepositiontaking_7 bit,
			@isauto_mlivepositiontaking_8 bit,
			
			@isauto_v2mpositiontaking_1 bit,
			@isauto_v2mpositiontaking_2 bit,
			@isauto_v2mpositiontaking_3 bit,
			@isauto_v2mpositiontaking_7 bit,
			@isauto_v2mpositiontaking_8 bit,
		--	@isauto_v2mpositiontaking_9 bit,
			@isauto_v2mpositiontaking_20 bit,

			@isauto_v3mpositiontaking_1 bit,
			@isauto_v3mpositiontaking_2 bit,
			@isauto_v3mpositiontaking_3 bit,
			@isauto_v3mpositiontaking_20 bit,

			@isauto_v5mpositiontaking_1 bit,
			@isauto_v5mpositiontaking_2 bit,
			@isauto_v5mpositiontaking_3 bit,
			@isauto_v5mpositiontaking_20 bit,
			@isauto_v5mpositiontaking_9999 bit,

			@isauto_v8mpositiontaking_1 bit,
			@isauto_v8mpositiontaking_3 bit,
			@isauto_v8mpositiontaking_20 bit,

			@isauto_v10mpositiontaking_1 bit,
			@isauto_v10mpositiontaking_2 bit,
			@isauto_v10mpositiontaking_3 bit,
			@isauto_v10mpositiontaking_20 bit,

			@isauto_v11mpositiontaking_1 bit,
			@isauto_v11mpositiontaking_20 bit,

			@isauto_v99mpositiontaking_1 bit,
			@isauto_v99mpositiontaking_2 bit,
			@isauto_v99mpositiontaking_3 bit,
			@isauto_v99mpositiontaking_20 bit,

			-- mixed sports
			@isauto_v99mpositiontaking_9 bit,
			@isauto_v154mpositiontaking_20 bit,
			
			-- Outright PT for sports
			@auto_v2mpositiontaking_10 smallmoney,
			@auto_v3mpositiontaking_10 smallmoney,
			@auto_v5mpositiontaking_10 smallmoney,
			@auto_v8mpositiontaking_10 smallmoney,
			@auto_v10mpositiontaking_10 smallmoney,
			@auto_v11mpositiontaking_10 smallmoney,
			@auto_v99mpositiontaking_10 smallmoney,
			
			@isauto_v2mpositiontaking_10 bit,
			@isauto_v3mpositiontaking_10 bit,
			@isauto_v5mpositiontaking_10 bit,
			@isauto_v8mpositiontaking_10 bit,
			@isauto_v10mpositiontaking_10 bit,
			@isauto_v11mpositiontaking_10 bit,
			@isauto_v99mpositiontaking_10 bit

		--Get Auto PT of member from agent
		--um2,im2
		select @auto_mpositiontaking_1 = autompositiontaking, @auto_mlivepositiontaking_1 = autolivempositiontaking, @isauto_mpositiontaking_1 = isautompositiontaking, @isauto_mlivepositiontaking_1 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=1
		select @auto_mpositiontaking_3 = autompositiontaking, @auto_mlivepositiontaking_3 = autolivempositiontaking, @isauto_mpositiontaking_3 = isautompositiontaking, @isauto_mlivepositiontaking_3 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=1
		select @auto_mpositiontaking_7 = autompositiontaking, @auto_mlivepositiontaking_7 = autolivempositiontaking, @isauto_mpositiontaking_7 = isautompositiontaking, @isauto_mlivepositiontaking_7 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=7 and sporttype=1
		select @auto_mpositiontaking_8 = autompositiontaking, @auto_mlivepositiontaking_8 = autolivempositiontaking, @isauto_mpositiontaking_8 = isautompositiontaking, @isauto_mlivepositiontaking_8 = isautolivempositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=8 and sporttype=1
		select @auto_mpositiontaking_2 = autompositiontaking, @isauto_mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=1
		select @auto_mpositiontaking_4 = autompositiontaking, @isauto_mpositiontaking_4 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=4 and sporttype=1
		select @auto_mpositiontaking_5 = autompositiontaking, @isauto_mpositiontaking_5 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=5 and sporttype=1
		select @auto_mpositiontaking_6 = autompositiontaking, @isauto_mpositiontaking_6 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=6 and sporttype=1
		select @auto_mpositiontaking_9 = autompositiontaking, @isauto_mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=1
		select @auto_mpositiontaking_10 = autompositiontaking, @isauto_mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=1
		
		-- Outright PT for sports
		select @auto_v2mpositiontaking_10 = autompositiontaking, @isauto_v2mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=2
		select @auto_v3mpositiontaking_10 = autompositiontaking, @isauto_v3mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=3
		select @auto_v5mpositiontaking_10 = autompositiontaking, @isauto_v5mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=5
		select @auto_v8mpositiontaking_10 = autompositiontaking, @isauto_v8mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=8
		select @auto_v10mpositiontaking_10 = autompositiontaking, @isauto_v10mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=10
		select @auto_v11mpositiontaking_10 = autompositiontaking, @isauto_v11mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=11
		select @auto_v99mpositiontaking_10 = autompositiontaking, @isauto_v99mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=10 and sporttype=99
		
		select @auto_mpositiontaking_9999 = autompositiontaking, @isauto_mpositiontaking_9999 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9999 and sporttype=1

		select @auto_v2mpositiontaking_1 = autompositiontaking, @isauto_v2mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=2
		select @auto_v2mpositiontaking_2 = autompositiontaking, @isauto_v2mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=2
		select @auto_v2mpositiontaking_3 = autompositiontaking, @isauto_v2mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=2
		select @auto_v2mpositiontaking_7 = autompositiontaking, @isauto_v2mpositiontaking_7 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=7 and sporttype=2
		select @auto_v2mpositiontaking_8 = autompositiontaking, @isauto_v2mpositiontaking_8 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=8 and sporttype=2
		--select @auto_v2mpositiontaking_9 = autompositiontaking, @isauto_v2mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=2
		select @auto_v2mpositiontaking_20 = autompositiontaking, @isauto_v2mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=2

		select @auto_v3mpositiontaking_1 = autompositiontaking, @isauto_v3mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=3
		select @auto_v3mpositiontaking_2 = autompositiontaking, @isauto_v3mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=3
		select @auto_v3mpositiontaking_3 = autompositiontaking, @isauto_v3mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=3
		select @auto_v3mpositiontaking_20 = autompositiontaking, @isauto_v3mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=3

		select @auto_v5mpositiontaking_1 = autompositiontaking, @isauto_v5mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=5
		select @auto_v5mpositiontaking_2 = autompositiontaking, @isauto_v5mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=5
		select @auto_v5mpositiontaking_3 = autompositiontaking, @isauto_v5mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=5
		select @auto_v5mpositiontaking_20 = autompositiontaking, @isauto_v5mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=5
		select @auto_v5mpositiontaking_9999 = autompositiontaking, @isauto_v5mpositiontaking_9999 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9999 and sporttype=5

		select @auto_v8mpositiontaking_1 = autompositiontaking, @isauto_v8mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=8
		select @auto_v8mpositiontaking_3 = autompositiontaking, @isauto_v8mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=8
		select @auto_v8mpositiontaking_20 = autompositiontaking, @isauto_v8mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=8

		select @auto_v10mpositiontaking_1 = autompositiontaking, @isauto_v10mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=10
		select @auto_v10mpositiontaking_2 = autompositiontaking, @isauto_v10mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=10
		select @auto_v10mpositiontaking_3 = autompositiontaking, @isauto_v10mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=10
		select @auto_v10mpositiontaking_20 = autompositiontaking, @isauto_v10mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=10

		select @auto_v11mpositiontaking_1 = autompositiontaking, @isauto_v11mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=11
		select @auto_v11mpositiontaking_20 = autompositiontaking, @isauto_v11mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=11

		select @auto_v99mpositiontaking_1 = autompositiontaking, @isauto_v99mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=1 and sporttype=99
		select @auto_v99mpositiontaking_2 = autompositiontaking, @isauto_v99mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=2 and sporttype=99
		select @auto_v99mpositiontaking_3 = autompositiontaking, @isauto_v99mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=3 and sporttype=99
		select @auto_v99mpositiontaking_20 = autompositiontaking, @isauto_v99mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=99

		-- mixed sports
		select @auto_v99mpositiontaking_9 = autompositiontaking, @isauto_v99mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=9 and sporttype=99
		select @auto_v154mpositiontaking_20 = autompositiontaking, @isauto_v154mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @recommend and bettype=20 and sporttype=154

		
		update cs
		SET autompositiontaking = b.autompositiontaking, autolivempositiontaking = b.autolivempositiontaking, isautompositiontaking = b.isautompositiontaking, isautolivempositiontaking = b.isautolivempositiontaking
		FROM @tmp_cs cs
			INNER JOIN (
								select 1 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_1 as autompositiontaking, @auto_mlivepositiontaking_mem_1	as autolivempositiontaking, @isauto_mpositiontaking_mem_1 as isautompositiontaking, @isauto_mlivepositiontaking_mem_1	as isautolivempositiontaking
					union all 	select 2 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_2 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_2 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 3 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_3 as autompositiontaking, @auto_mlivepositiontaking_mem_3 	as autolivempositiontaking, @isauto_mpositiontaking_mem_3 as isautompositiontaking, @isauto_mlivepositiontaking_mem_3	as isautolivempositiontaking
					union all 	select 4 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_4 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_4 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 5 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_5 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_5 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 6 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_6 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_6 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 7 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_7 as autompositiontaking, @auto_mlivepositiontaking_mem_7 	as autolivempositiontaking, @isauto_mpositiontaking_mem_7 as isautompositiontaking, @isauto_mlivepositiontaking_mem_7	as isautolivempositiontaking
					union all 	select 8 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_8 as autompositiontaking, @auto_mlivepositiontaking_mem_8 	as autolivempositiontaking, @isauto_mpositiontaking_mem_8 as isautompositiontaking, @isauto_mlivepositiontaking_mem_8	as isautolivempositiontaking			
					union all 	select 9 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_9 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_9 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 10 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_10 as isautompositiontaking, 0				as isautolivempositiontaking
					
					-- Outright PT for sports
					union all 	select 10 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v2mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					union all 	select 10 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v3mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					union all 	select 10 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v5mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					union all 	select 10 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v8mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					union all 	select 10 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v10mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					union all 	select 10 as bettype, 11 as sporttype, @auto_v11mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v11mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					union all 	select 10 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v99mpositiontaking_mem_10 as isautompositiontaking, 0 as isautolivempositiontaking
					
					
					union all 	select 9999 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_9999 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_9999 as isautompositiontaking, 0				as isautolivempositiontaking
					
					union all 	select 1 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 7 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_7 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_7 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 8 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_8 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_8 as isautompositiontaking, 0	as isautolivempositiontaking
		--			union all 	select 9 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_9 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_9 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking
					
					union all 	select 1 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 9999 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_9999 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_9999 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v8mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v8mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v8mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 11 as sporttype, @auto_v11mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v11mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 11 as sporttype, @auto_v11mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v11mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					-- mixed sports
					union all 	select 9 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_9 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_9 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 154 as sporttype, @auto_v154mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v154mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking
				
				) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
		
		/*
		--Update Member account (autompositiontaking field)
		update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autompositiontaking, autolivempositiontaking = b.autolivempositiontaking, isautompositiontaking = b.isautompositiontaking, isautolivempositiontaking = b.isautolivempositiontaking
		from custsetting inner join 
				(
								select 1 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_1 as autompositiontaking, @auto_mlivepositiontaking_mem_1	as autolivempositiontaking, @isauto_mpositiontaking_mem_1 as isautompositiontaking, @isauto_mlivepositiontaking_mem_1	as isautolivempositiontaking
					union all 	select 2 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_2 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_2 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 3 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_3 as autompositiontaking, @auto_mlivepositiontaking_mem_3 	as autolivempositiontaking, @isauto_mpositiontaking_mem_3 as isautompositiontaking, @isauto_mlivepositiontaking_mem_3	as isautolivempositiontaking
					union all 	select 4 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_4 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_4 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 5 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_5 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_5 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 6 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_6 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_6 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 7 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_7 as autompositiontaking, @auto_mlivepositiontaking_mem_7 	as autolivempositiontaking, @isauto_mpositiontaking_mem_7 as isautompositiontaking, @isauto_mlivepositiontaking_mem_7	as isautolivempositiontaking
					union all 	select 8 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_8 as autompositiontaking, @auto_mlivepositiontaking_mem_8 	as autolivempositiontaking, @isauto_mpositiontaking_mem_8 as isautompositiontaking, @isauto_mlivepositiontaking_mem_8	as isautolivempositiontaking			
					union all 	select 9 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_9 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_9 as isautompositiontaking, 0				as isautolivempositiontaking
					union all 	select 10 as bettype, 1 as sporttype, @auto_mpositiontaking_mem_10 as autompositiontaking, 0				as autolivempositiontaking, @isauto_mpositiontaking_mem_10 as isautompositiontaking, 0				as isautolivempositiontaking
					
					union all 	select 1 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 7 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_7 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_7 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 8 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_8 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_8 as isautompositiontaking, 0	as isautolivempositiontaking
		--			union all 	select 9 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_9 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_9 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 2 as sporttype, @auto_v2mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v2mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking
					
					union all 	select 1 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 3 as sporttype, @auto_v3mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v3mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 5 as sporttype, @auto_v5mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v5mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v8mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v8mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 8 as sporttype, @auto_v8mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v8mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 10 as sporttype, @auto_v10mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v10mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 11 as sporttype, @auto_v11mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v11mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 11 as sporttype, @auto_v11mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v11mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					union all 	select 1 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_1 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_1 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 2 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_2 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_2 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 3 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_3 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_3 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking

					-- mixed sports
					union all 	select 9 as bettype, 99 as sporttype, @auto_v99mpositiontaking_mem_9 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v99mpositiontaking_mem_9 as isautompositiontaking, 0	as isautolivempositiontaking
					union all 	select 20 as bettype, 154 as sporttype, @auto_v154mpositiontaking_mem_20 as autompositiontaking, 0	as autolivempositiontaking, @isauto_v154mpositiontaking_mem_20 as isautompositiontaking, 0	as isautolivempositiontaking
				
				) as b on b.bettype = custsetting.bettype and b.sporttype = custsetting.sporttype
		where custsetting.custid = @custid
		*/	
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in agent account)
		select 
			@auto_mpositiontaking_1 = case when @isauto_mpositiontaking_mem_1>0 then @auto_mpositiontaking_mem_1 else @auto_mpositiontaking_1 end,
			@auto_mpositiontaking_2 = case when @isauto_mpositiontaking_mem_2>0 then @auto_mpositiontaking_mem_2 else @auto_mpositiontaking_2 end,
			@auto_mpositiontaking_3 = case when @isauto_mpositiontaking_mem_3>0 then @auto_mpositiontaking_mem_3 else @auto_mpositiontaking_3 end,
			@auto_mpositiontaking_4 = case when @isauto_mpositiontaking_mem_4>0 then @auto_mpositiontaking_mem_4 else @auto_mpositiontaking_4 end,
			@auto_mpositiontaking_5 = case when @isauto_mpositiontaking_mem_5>0 then @auto_mpositiontaking_mem_5 else @auto_mpositiontaking_5 end,
			@auto_mpositiontaking_6 = case when @isauto_mpositiontaking_mem_6>0 then @auto_mpositiontaking_mem_6 else @auto_mpositiontaking_6 end,
			@auto_mpositiontaking_7 = case when @isauto_mpositiontaking_mem_7>0 then @auto_mpositiontaking_mem_7 else @auto_mpositiontaking_7 end,
			@auto_mpositiontaking_8 = case when @isauto_mpositiontaking_mem_8>0 then @auto_mpositiontaking_mem_8 else @auto_mpositiontaking_8 end,
			@auto_mpositiontaking_9 = case when @isauto_mpositiontaking_mem_9>0 then @auto_mpositiontaking_mem_9 else @auto_mpositiontaking_9 end,
			@auto_mpositiontaking_10 = case when @isauto_mpositiontaking_mem_10>0 then @auto_mpositiontaking_mem_10 else @auto_mpositiontaking_10 end,
			
			-- Outright PT for sports
			@auto_v2mpositiontaking_10 = case when @isauto_v2mpositiontaking_mem_10>0 then @auto_v2mpositiontaking_mem_10 else @auto_v2mpositiontaking_10 end,
			@auto_v3mpositiontaking_10 = case when @isauto_v3mpositiontaking_mem_10>0 then @auto_v3mpositiontaking_mem_10 else @auto_v3mpositiontaking_10 end,
			@auto_v5mpositiontaking_10 = case when @isauto_v5mpositiontaking_mem_10>0 then @auto_v5mpositiontaking_mem_10 else @auto_v5mpositiontaking_10 end,
			@auto_v8mpositiontaking_10 = case when @isauto_v8mpositiontaking_mem_10>0 then @auto_v8mpositiontaking_mem_10 else @auto_v8mpositiontaking_10 end,
			@auto_v10mpositiontaking_10 = case when @isauto_v10mpositiontaking_mem_10>0 then @auto_v10mpositiontaking_mem_10 else @auto_v10mpositiontaking_10 end,
			@auto_v11mpositiontaking_10 = case when @isauto_v11mpositiontaking_mem_10>0 then @auto_v11mpositiontaking_mem_10 else @auto_v11mpositiontaking_10 end,
			@auto_v99mpositiontaking_10 = case when @isauto_v99mpositiontaking_mem_10>0 then @auto_v99mpositiontaking_mem_10 else @auto_v99mpositiontaking_10 end,
			
			@auto_mpositiontaking_9999 = case when @isauto_mpositiontaking_mem_9999>0 then @auto_mpositiontaking_mem_9999 else @auto_mpositiontaking_9999 end,

			@auto_mlivepositiontaking_1 = case when @isauto_mlivepositiontaking_mem_1>0 then @auto_mlivepositiontaking_mem_1 else @auto_mlivepositiontaking_1 end,
			@auto_mlivepositiontaking_3 = case when @isauto_mlivepositiontaking_mem_3>0 then @auto_mlivepositiontaking_mem_3 else @auto_mlivepositiontaking_3 end,
			@auto_mlivepositiontaking_7 = case when @isauto_mlivepositiontaking_mem_7>0 then @auto_mlivepositiontaking_mem_7 else @auto_mlivepositiontaking_7 end,
			@auto_mlivepositiontaking_8 = case when @isauto_mlivepositiontaking_mem_8>0 then @auto_mlivepositiontaking_mem_8 else @auto_mlivepositiontaking_8 end,

			@auto_v2mpositiontaking_1 = case when @isauto_v2mpositiontaking_mem_1>0 then @auto_v2mpositiontaking_mem_1 else @auto_v2mpositiontaking_1 end,
			@auto_v2mpositiontaking_2 = case when @isauto_v2mpositiontaking_mem_2>0 then @auto_v2mpositiontaking_mem_2 else @auto_v2mpositiontaking_2 end,
			@auto_v2mpositiontaking_3 = case when @isauto_v2mpositiontaking_mem_3>0 then @auto_v2mpositiontaking_mem_3 else @auto_v2mpositiontaking_3 end,
			@auto_v2mpositiontaking_7 = case when @isauto_v2mpositiontaking_mem_7>0 then @auto_v2mpositiontaking_mem_7 else @auto_v2mpositiontaking_7 end,
			@auto_v2mpositiontaking_8 = case when @isauto_v2mpositiontaking_mem_8>0 then @auto_v2mpositiontaking_mem_8 else @auto_v2mpositiontaking_8 end,
		--	@auto_v2mpositiontaking_9 = case when @isauto_v2mpositiontaking_mem_9>0 then @auto_v2mpositiontaking_mem_9 else @auto_v2mpositiontaking_9 end,
			@auto_v2mpositiontaking_20 = case when @isauto_v2mpositiontaking_mem_20>0 then @auto_v2mpositiontaking_mem_20 else @auto_v2mpositiontaking_20 end,
			
			@auto_v3mpositiontaking_1 = case when @isauto_v3mpositiontaking_mem_1>0 then @auto_v3mpositiontaking_mem_1 else @auto_v3mpositiontaking_1 end,
			@auto_v3mpositiontaking_2 = case when @isauto_v3mpositiontaking_mem_2>0 then @auto_v3mpositiontaking_mem_2 else @auto_v3mpositiontaking_2 end,
			@auto_v3mpositiontaking_3 = case when @isauto_v3mpositiontaking_mem_3>0 then @auto_v3mpositiontaking_mem_3 else @auto_v3mpositiontaking_3 end,
			@auto_v3mpositiontaking_20 = case when @isauto_v3mpositiontaking_mem_20>0 then @auto_v3mpositiontaking_mem_20 else @auto_v3mpositiontaking_20 end,
			
			@auto_v5mpositiontaking_1 = case when @isauto_v5mpositiontaking_mem_1>0 then @auto_v5mpositiontaking_mem_1 else @auto_v5mpositiontaking_1 end,
			@auto_v5mpositiontaking_2 = case when @isauto_v5mpositiontaking_mem_2>0 then @auto_v5mpositiontaking_mem_2 else @auto_v5mpositiontaking_2 end,
			@auto_v5mpositiontaking_3 = case when @isauto_v5mpositiontaking_mem_3>0 then @auto_v5mpositiontaking_mem_3 else @auto_v5mpositiontaking_3 end,			
			@auto_v5mpositiontaking_20 = case when @isauto_v5mpositiontaking_mem_20>0 then @auto_v5mpositiontaking_mem_20 else @auto_v5mpositiontaking_20 end,
			@auto_v5mpositiontaking_9999 = case when @isauto_v5mpositiontaking_mem_9999>0 then @auto_v5mpositiontaking_mem_9999 else @auto_v5mpositiontaking_9999 end,
			
			@auto_v8mpositiontaking_1 = case when @isauto_v8mpositiontaking_mem_1>0 then @auto_v8mpositiontaking_mem_1 else @auto_v8mpositiontaking_1 end,
			@auto_v8mpositiontaking_3 = case when @isauto_v8mpositiontaking_mem_3>0 then @auto_v8mpositiontaking_mem_3 else @auto_v8mpositiontaking_3 end,
			@auto_v8mpositiontaking_20 = case when @isauto_v8mpositiontaking_mem_20>0 then @auto_v8mpositiontaking_mem_20 else @auto_v8mpositiontaking_20 end,
			
			@auto_v10mpositiontaking_1 = case when @isauto_v10mpositiontaking_mem_1>0 then @auto_v10mpositiontaking_mem_1 else @auto_v10mpositiontaking_1 end,
			@auto_v10mpositiontaking_2 = case when @isauto_v10mpositiontaking_mem_2>0 then @auto_v10mpositiontaking_mem_2 else @auto_v10mpositiontaking_2 end,
			@auto_v10mpositiontaking_3 = case when @isauto_v10mpositiontaking_mem_3>0 then @auto_v10mpositiontaking_mem_3 else @auto_v10mpositiontaking_3 end,
			@auto_v10mpositiontaking_20 = case when @isauto_v10mpositiontaking_mem_20>0 then @auto_v10mpositiontaking_mem_20 else @auto_v10mpositiontaking_20 end,

			@auto_v11mpositiontaking_1 = case when @isauto_v11mpositiontaking_mem_1>0 then @auto_v11mpositiontaking_mem_1 else @auto_v11mpositiontaking_1 end,
			@auto_v11mpositiontaking_20 = case when @isauto_v11mpositiontaking_mem_20>0 then @auto_v11mpositiontaking_mem_20 else @auto_v11mpositiontaking_20 end,

			@auto_v99mpositiontaking_1 = case when @isauto_v99mpositiontaking_mem_1>0 then @auto_v99mpositiontaking_mem_1 else @auto_v99mpositiontaking_1 end,
			@auto_v99mpositiontaking_2 = case when @isauto_v99mpositiontaking_mem_2>0 then @auto_v99mpositiontaking_mem_2 else @auto_v99mpositiontaking_2 end,
			@auto_v99mpositiontaking_3 = case when @isauto_v99mpositiontaking_mem_3>0 then @auto_v99mpositiontaking_mem_3 else @auto_v99mpositiontaking_3 end,
			@auto_v99mpositiontaking_20 = case when @isauto_v99mpositiontaking_mem_20>0 then @auto_v99mpositiontaking_mem_20 else @auto_v99mpositiontaking_20 end,

			-- mixed sports
			@auto_v99mpositiontaking_9 = case when @isauto_v99mpositiontaking_mem_9>0 then @auto_v99mpositiontaking_mem_9 else @auto_v99mpositiontaking_9 end,
			@auto_v154mpositiontaking_20 = case when @isauto_v154mpositiontaking_mem_20>0 then @auto_v154mpositiontaking_mem_20 else @auto_v154mpositiontaking_20 end,
			
			@isauto_mpositiontaking_1 = case when @isauto_mpositiontaking_mem_1>0 then @isauto_mpositiontaking_mem_1 else @isauto_mpositiontaking_1 end,
			@isauto_mpositiontaking_2 = case when @isauto_mpositiontaking_mem_2>0 then @isauto_mpositiontaking_mem_2 else @isauto_mpositiontaking_2 end,
			@isauto_mpositiontaking_3 = case when @isauto_mpositiontaking_mem_3>0 then @isauto_mpositiontaking_mem_3 else @isauto_mpositiontaking_3 end,
			@isauto_mpositiontaking_4 = case when @isauto_mpositiontaking_mem_4>0 then @isauto_mpositiontaking_mem_4 else @isauto_mpositiontaking_4 end,
			@isauto_mpositiontaking_5 = case when @isauto_mpositiontaking_mem_5>0 then @isauto_mpositiontaking_mem_5 else @isauto_mpositiontaking_5 end,
			@isauto_mpositiontaking_6 = case when @isauto_mpositiontaking_mem_6>0 then @isauto_mpositiontaking_mem_6 else @isauto_mpositiontaking_6 end,
			@isauto_mpositiontaking_7 = case when @isauto_mpositiontaking_mem_7>0 then @isauto_mpositiontaking_mem_7 else @isauto_mpositiontaking_7 end,
			@isauto_mpositiontaking_8 = case when @isauto_mpositiontaking_mem_8>0 then @isauto_mpositiontaking_mem_8 else @isauto_mpositiontaking_8 end,
			@isauto_mpositiontaking_9 = case when @isauto_mpositiontaking_mem_9>0 then @isauto_mpositiontaking_mem_9 else @isauto_mpositiontaking_9 end,
			@isauto_mpositiontaking_10 = case when @isauto_mpositiontaking_mem_10>0 then @isauto_mpositiontaking_mem_10 else @isauto_mpositiontaking_10 end,
			
			-- Outright PT for sports
			@isauto_v2mpositiontaking_10 = case when @isauto_v2mpositiontaking_mem_10>0 then @isauto_v2mpositiontaking_mem_10 else @isauto_v2mpositiontaking_10 end,
			@isauto_v3mpositiontaking_10 = case when @isauto_v3mpositiontaking_mem_10>0 then @isauto_v3mpositiontaking_mem_10 else @isauto_v3mpositiontaking_10 end,
			@isauto_v5mpositiontaking_10 = case when @isauto_v5mpositiontaking_mem_10>0 then @isauto_v5mpositiontaking_mem_10 else @isauto_v5mpositiontaking_10 end,
			@isauto_v8mpositiontaking_10 = case when @isauto_v8mpositiontaking_mem_10>0 then @isauto_v8mpositiontaking_mem_10 else @isauto_v8mpositiontaking_10 end,
			@isauto_v10mpositiontaking_10 = case when @isauto_v10mpositiontaking_mem_10>0 then @isauto_v10mpositiontaking_mem_10 else @isauto_v10mpositiontaking_10 end,
			@isauto_v11mpositiontaking_10 = case when @isauto_v11mpositiontaking_mem_10>0 then @isauto_v11mpositiontaking_mem_10 else @isauto_v11mpositiontaking_10 end,
			@isauto_v99mpositiontaking_10 = case when @isauto_v99mpositiontaking_mem_10>0 then @isauto_v99mpositiontaking_mem_10 else @isauto_v99mpositiontaking_10 end,
			
			@isauto_mpositiontaking_9999 = case when @isauto_mpositiontaking_mem_9999>0 then @isauto_mpositiontaking_mem_9999 else @isauto_mpositiontaking_9999 end,

			@isauto_mlivepositiontaking_1 = case when @isauto_mlivepositiontaking_mem_1>0 then @isauto_mlivepositiontaking_mem_1 else @isauto_mlivepositiontaking_1 end,
			@isauto_mlivepositiontaking_3 = case when @isauto_mlivepositiontaking_mem_3>0 then @isauto_mlivepositiontaking_mem_3 else @isauto_mlivepositiontaking_3 end,
			@isauto_mlivepositiontaking_7 = case when @isauto_mlivepositiontaking_mem_7>0 then @isauto_mlivepositiontaking_mem_7 else @isauto_mlivepositiontaking_7 end,
			@isauto_mlivepositiontaking_8 = case when @isauto_mlivepositiontaking_mem_8>0 then @isauto_mlivepositiontaking_mem_8 else @isauto_mlivepositiontaking_8 end,

			@isauto_v2mpositiontaking_1 = case when @isauto_v2mpositiontaking_mem_1>0 then @isauto_v2mpositiontaking_mem_1 else @isauto_v2mpositiontaking_1 end,
			@isauto_v2mpositiontaking_2 = case when @isauto_v2mpositiontaking_mem_2>0 then @isauto_v2mpositiontaking_mem_2 else @isauto_v2mpositiontaking_2 end,
			@isauto_v2mpositiontaking_3 = case when @isauto_v2mpositiontaking_mem_3>0 then @isauto_v2mpositiontaking_mem_3 else @isauto_v2mpositiontaking_3 end,
			@isauto_v2mpositiontaking_7 = case when @isauto_v2mpositiontaking_mem_7>0 then @isauto_v2mpositiontaking_mem_7 else @isauto_v2mpositiontaking_7 end,
			@isauto_v2mpositiontaking_8 = case when @isauto_v2mpositiontaking_mem_8>0 then @isauto_v2mpositiontaking_mem_8 else @isauto_v2mpositiontaking_8 end,
		--	@isauto_v2mpositiontaking_9 = case when @isauto_v2mpositiontaking_mem_9>0 then @isauto_v2mpositiontaking_mem_9 else @isauto_v2mpositiontaking_9 end,
			@isauto_v2mpositiontaking_20 = case when @isauto_v2mpositiontaking_mem_20>0 then @isauto_v2mpositiontaking_mem_20 else @isauto_v2mpositiontaking_20 end,

			@isauto_v3mpositiontaking_1 = case when @isauto_v3mpositiontaking_mem_1>0 then @isauto_v3mpositiontaking_mem_1 else @isauto_v3mpositiontaking_1 end,
			@isauto_v3mpositiontaking_2 = case when @isauto_v3mpositiontaking_mem_2>0 then @isauto_v3mpositiontaking_mem_2 else @isauto_v3mpositiontaking_2 end,
			@isauto_v3mpositiontaking_3 = case when @isauto_v3mpositiontaking_mem_3>0 then @isauto_v3mpositiontaking_mem_3 else @isauto_v3mpositiontaking_3 end,
			@isauto_v3mpositiontaking_20 = case when @isauto_v3mpositiontaking_mem_20>0 then @isauto_v3mpositiontaking_mem_20 else @isauto_v3mpositiontaking_20 end,

			@isauto_v5mpositiontaking_1 = case when @isauto_v5mpositiontaking_mem_1>0 then @isauto_v5mpositiontaking_mem_1 else @isauto_v5mpositiontaking_1 end,
			@isauto_v5mpositiontaking_2 = case when @isauto_v5mpositiontaking_mem_2>0 then @isauto_v5mpositiontaking_mem_2 else @isauto_v5mpositiontaking_2 end,
			@isauto_v5mpositiontaking_3 = case when @isauto_v5mpositiontaking_mem_3>0 then @isauto_v5mpositiontaking_mem_3 else @isauto_v5mpositiontaking_3 end,
			@isauto_v5mpositiontaking_20 = case when @isauto_v5mpositiontaking_mem_20>0 then @isauto_v5mpositiontaking_mem_20 else @isauto_v5mpositiontaking_20 end,
			@isauto_v5mpositiontaking_9999 = case when @isauto_v5mpositiontaking_mem_9999>0 then @isauto_v5mpositiontaking_mem_9999 else @isauto_v5mpositiontaking_9999 end,

			@isauto_v8mpositiontaking_1 = case when @isauto_v8mpositiontaking_mem_1>0 then @isauto_v8mpositiontaking_mem_1 else @isauto_v8mpositiontaking_1 end,
			@isauto_v8mpositiontaking_3 = case when @isauto_v8mpositiontaking_mem_3>0 then @isauto_v8mpositiontaking_mem_3 else @isauto_v8mpositiontaking_3 end,
			@isauto_v8mpositiontaking_20 = case when @isauto_v8mpositiontaking_mem_20>0 then @isauto_v8mpositiontaking_mem_20 else @isauto_v8mpositiontaking_20 end,

			@isauto_v10mpositiontaking_1 = case when @isauto_v10mpositiontaking_mem_1>0 then @isauto_v10mpositiontaking_mem_1 else @isauto_v10mpositiontaking_1 end,
			@isauto_v10mpositiontaking_2 = case when @isauto_v10mpositiontaking_mem_2>0 then @isauto_v10mpositiontaking_mem_2 else @isauto_v10mpositiontaking_2 end,
			@isauto_v10mpositiontaking_3 = case when @isauto_v10mpositiontaking_mem_3>0 then @isauto_v10mpositiontaking_mem_3 else @isauto_v10mpositiontaking_3 end,
			@isauto_v10mpositiontaking_20 = case when @isauto_v10mpositiontaking_mem_20>0 then @isauto_v10mpositiontaking_mem_20 else @isauto_v10mpositiontaking_20 end,

			@isauto_v11mpositiontaking_1 = case when @isauto_v11mpositiontaking_mem_1>0 then @isauto_v11mpositiontaking_mem_1 else @isauto_v11mpositiontaking_1 end,
			@isauto_v11mpositiontaking_20 = case when @isauto_v11mpositiontaking_mem_20>0 then @isauto_v11mpositiontaking_mem_20 else @isauto_v11mpositiontaking_20 end,

			@isauto_v99mpositiontaking_1 = case when @isauto_v99mpositiontaking_mem_1>0 then @isauto_v99mpositiontaking_mem_1 else @isauto_v99mpositiontaking_1 end,
			@isauto_v99mpositiontaking_2 = case when @isauto_v99mpositiontaking_mem_2>0 then @isauto_v99mpositiontaking_mem_2 else @isauto_v99mpositiontaking_2 end,
			@isauto_v99mpositiontaking_3 = case when @isauto_v99mpositiontaking_mem_3>0 then @isauto_v99mpositiontaking_mem_3 else @isauto_v99mpositiontaking_3 end,
			@isauto_v99mpositiontaking_20 = case when @isauto_v99mpositiontaking_mem_20>0 then @isauto_v99mpositiontaking_mem_20 else @isauto_v99mpositiontaking_20 end,

			-- mixed sports
			@isauto_v99mpositiontaking_9 = case when @isauto_v99mpositiontaking_mem_9>0 then @isauto_v99mpositiontaking_mem_9 else @isauto_v99mpositiontaking_9 end,
			@isauto_v154mpositiontaking_20 = case when @isauto_v154mpositiontaking_mem_20>0 then @isauto_v154mpositiontaking_mem_20 else @isauto_v154mpositiontaking_20 end


			--Update member account
			--Using Cursor (mpositiontaking field)
			DECLARE CUR CURSOR FOR 
					SELECT 1 AS bettype		,		   @isauto_mpositiontaking_1 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_1 AS isautolivepositiontaking		,		  @auto_mpositiontaking_1 AS autopositiontaking	    	,		   @auto_mlivepositiontaking_1 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_1 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_1 AS autov2positiontaking		,		@isauto_v3mpositiontaking_1 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_1 AS autov3positiontaking,			@isauto_v5mpositiontaking_1 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_1 AS autov5positiontaking		,		@isauto_v8mpositiontaking_1 AS isautov8positiontaking		,		   @auto_v8mpositiontaking_1 AS autov8positiontaking		,		@isauto_v10mpositiontaking_1 AS isautov10positiontaking		,		   @auto_v10mpositiontaking_1 AS autov10positiontaking		,		@isauto_v11mpositiontaking_1 AS isautov11positiontaking		,		   @auto_v11mpositiontaking_1 AS autov11positiontaking		,		@isauto_v99mpositiontaking_1 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_1 AS autov99positiontaking	,	0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL  	SELECT 2 AS bettype		,		   @isauto_mpositiontaking_2 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		  @auto_mpositiontaking_2 AS autopositiontaking	    	,									 0 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_2 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_2 AS autov2positiontaking		,		@isauto_v3mpositiontaking_2 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_2 AS autov3positiontaking,			@isauto_v5mpositiontaking_2 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_2 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,		@isauto_v10mpositiontaking_2 AS isautov10positiontaking		,		   @auto_v10mpositiontaking_2 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,		@isauto_v99mpositiontaking_2 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_2 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL 	SELECT 3 AS bettype		,		   @isauto_mpositiontaking_3 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_3 AS isautolivepositiontaking		,		   @auto_mpositiontaking_3 AS autopositiontaking		,		   @auto_mlivepositiontaking_3 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_3 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_3 AS autov2positiontaking		,		@isauto_v3mpositiontaking_3 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_3 AS autov3positiontaking,			@isauto_v5mpositiontaking_3 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_3 AS autov5positiontaking		,		@isauto_v8mpositiontaking_3 AS isautov8positiontaking		,		   @auto_v8mpositiontaking_3 AS autov8positiontaking		,		@isauto_v10mpositiontaking_3 AS isautov10positiontaking		,		   @auto_v10mpositiontaking_3 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,		@isauto_v99mpositiontaking_3 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_3 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL  	SELECT 4 AS bettype		,		   @isauto_mpositiontaking_4 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_4 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL 	SELECT 5 AS bettype		,		   @isauto_mpositiontaking_5 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_5 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL  	SELECT 6 AS bettype		,		   @isauto_mpositiontaking_6 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_6 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL  	SELECT 7 AS bettype		,		   @isauto_mpositiontaking_7 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_7 AS isautolivepositiontaking		,		  @auto_mpositiontaking_7 AS autopositiontaking	    	,		   @auto_mlivepositiontaking_7 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_7 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_7 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									 0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL  	SELECT 8 AS bettype		,		   @isauto_mpositiontaking_8 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_8 AS isautolivepositiontaking		,		  @auto_mpositiontaking_8 AS autopositiontaking	    	,		   @auto_mlivepositiontaking_8 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_8 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_8 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									 0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL  	SELECT 9 AS bettype		,		   @isauto_mpositiontaking_9 AS isautopositiontaking		,									 0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_9 AS autopositiontaking		,									 0 AS autolivepositiontaking		,		/*@isauto_v2mpositiontaking_9*/ 0 AS isautov2positiontaking		,	/*@auto_v2mpositiontaking_9*/  0  AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   @isauto_v99mpositiontaking_9 AS isautov99mppositiontaking ,@auto_v99mpositiontaking_9 AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		
		UNION ALL  	SELECT 10 AS bettype	,		   @isauto_mpositiontaking_10 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_10 AS autopositiontaking		,									 0 AS autolivepositiontaking		,		@isauto_v2mpositiontaking_10  AS isautov2positiontaking		,				@auto_v2mpositiontaking_10 AS autov2positiontaking		,		@isauto_v3mpositiontaking_10 AS isautov3positiontaking		,			@auto_v3mpositiontaking_10 AS autov3positiontaking,			@isauto_v5mpositiontaking_10 AS isautov5positiontaking		,			@auto_v5mpositiontaking_10 AS autov5positiontaking		,		@isauto_v8mpositiontaking_10 AS isautov8positiontaking		,		@auto_v8mpositiontaking_10 AS autov8positiontaking		,			@isauto_v10mpositiontaking_10 AS isautov10positiontaking		,		@auto_v10mpositiontaking_10 AS autov10positiontaking		,	@isauto_v11mpositiontaking_10 AS isautov11positiontaking		,	@auto_v11mpositiontaking_10 AS autov11positiontaking		,	@isauto_v99mpositiontaking_10 AS isautov99positiontaking		,		@auto_v99mpositiontaking_10 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		
		UNION ALL  	SELECT 9999 AS bettype	,		   @isauto_mpositiontaking_9999 AS isautopositiontaking		,									 0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_9999 AS autopositiontaking		,									 0 AS autolivepositiontaking		,		/*@isauto_v2mpositiontaking_9*/ 0 AS isautov2positiontaking		,	/*@auto_v2mpositiontaking_9*/  0  AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,			@isauto_v5mpositiontaking_9999 AS isautov5positiontaking	,		   @auto_v5mpositiontaking_9999 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
		UNION ALL 	SELECT 20 AS bettype	,									 0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_20 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_20 AS autov2positiontaking		,		@isauto_v3mpositiontaking_20 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_20 AS autov3positiontaking,			@isauto_v5mpositiontaking_20 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_20 AS autov5positiontaking		,		@isauto_v8mpositiontaking_20 AS isautov8positiontaking		,		   @auto_v8mpositiontaking_20 AS autov8positiontaking		,		@isauto_v10mpositiontaking_20 AS isautov10positiontaking	,		   @auto_v10mpositiontaking_20 AS autov10positiontaking		,		@isauto_v11mpositiontaking_20 AS isautov11positiontaking	,		   @auto_v11mpositiontaking_20 AS autov11positiontaking		,	@isauto_v99mpositiontaking_20 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_20 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking	,@isauto_v154mpositiontaking_20 AS isautov154positiontaking	,@auto_v154mpositiontaking_20 AS autov154positiontaking
																																																																																																																																																																																																																																																																																																																																																										
		OPEN CUR																																																																																																																																																																																																																																																																																																																																																						

		FETCH NEXT FROM CUR INTO
			@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, 
			@isautov2positiontaking, @autov2positiontaking,	
			@isautov3positiontaking, @autov3positiontaking, 
			@isautov5positiontaking, @autov5positiontaking, 	
			@isautov8positiontaking, @autov8positiontaking, 
			@isautov10positiontaking, @autov10positiontaking,
			@isautov11positiontaking, @autov11positiontaking, 
			@isautov99positiontaking, @autov99positiontaking,
			@isautov99mppositiontaking, @autov99mppositiontaking,
			@isautov154positiontaking, @autov154positiontaking
			
		--m1=min(u,m3-a1)
		WHILE @@FETCH_STATUS = 0
		BEGIN
				if @isautopositiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=1 and bettype = @bettype
					
					update cs
					SET mpositiontaking = case when @maxpos - apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=1
					
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=1 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - apositiontaking end
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
					*/					
				END
			--Update LIVE
			if @bettype in (1,3,7,8) 
			BEGIN
				if @isautolivepositiontaking >0
				BEGIN
					select @maxpos = mlivepositiontaking from @tmp_mag where sporttype=1 and bettype = @bettype
					
					UPDATE cs
					SET mlivepositiontaking = case when @maxpos - alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - alivepositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=1
					
					/*
					select @maxpos = mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=1 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - alivepositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
					*/
				END
			END		
			--Update Basketball
			if @bettype in (1,2,3,7,8,9,20,10) 
			BEGIN
				if @isautov2positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=2 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=2
					
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=2 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=2
					*/					
				END
			END
			
			--Update Football
			if @bettype in (1,2,3,20,10) 
			BEGIN
				if @isautov3positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=3 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=3
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=3 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=3
					*/
				END
			END

			--Update Tennis
			if @bettype in (1,2,3,20,10) 
			BEGIN
				if @isautov5positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=5 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=5
					
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=5 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=5
					*/
				END
			END

			--Update Baseball
			if @bettype in (1,3,20,10) 
			BEGIN
				if @isautov8positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=8 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=8
					
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=8 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=8
					*/
				END
			END

			--Update Golf
			if @bettype in (1,2,3,20,10)
			BEGIN
				if @isautov10positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=10 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=10
					
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=10 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=10
					*/
				END
			END

			--Update Motorsports
			if @bettype in (1,20,10)
			BEGIN
				if @isautov11positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=11 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=11
					
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=11 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=11
					*/
				END
			END

			--Update Other sports
			if @bettype in (1,2,3,20,10) 
			BEGIN
				if @isautov99positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=99 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=99
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=99 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
					*/
				END
			END
			
			--Update mixed sports
			if @bettype in (9) 
			BEGIN
				if @isautov99mppositiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=99 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=99
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=99 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
					*/
				END
			END				
			--Update HR Fixed Odds
			if @bettype in (20)
			BEGIN
				if @isautov154positiontaking >0
				BEGIN
					select @maxpos = mpositiontaking from @tmp_mag where sporttype=154 and bettype = @bettype
					
					UPDATE cs
					SET mpositiontaking = case when @maxpos - apositiontaking>@autov154positiontaking then @autov154positiontaking else @maxpos - apositiontaking end
					FROM @tmp_cs cs
					WHERE cs.bettype = @bettype and cs.sporttype=154
					/*
					select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=154 and bettype = @bettype
					
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov154positiontaking then @autov154positiontaking else @maxpos - apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=154					
					*/
				END
			END
			FETCH NEXT FROM CUR INTO
				@bettype, @isautopositiontaking, @isautolivepositiontaking, @autopositiontaking, @autolivepositiontaking, 
				@isautov2positiontaking, @autov2positiontaking,	
				@isautov3positiontaking, @autov3positiontaking, 
				@isautov5positiontaking, @autov5positiontaking, 	
				@isautov8positiontaking, @autov8positiontaking, 
				@isautov10positiontaking, @autov10positiontaking,
				@isautov11positiontaking, @autov11positiontaking, 
				@isautov99positiontaking, @autov99positiontaking,
				@isautov99mppositiontaking, @autov99mppositiontaking,
				@isautov154positiontaking, @autov154positiontaking
		END
	
		CLOSE CUR
		DEALLOCATE CUR		
	END
	
	--correct pt after update s1
	--check agent min/max
	--update a1=n2 when a1<n2
	update cs
	SET cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END			
	from @tmp_cs cs
		inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
		inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.apositiontaking < aco.minpositiontaking
				
	update cs
	SET cs.alivepositiontaking = aco.minlivepositiontaking,
		cs.mlivepositiontaking = case when cs.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking - aco.minlivepositiontaking ELSE cs.mlivepositiontaking END			
	from @tmp_cs cs
		inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
		inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking < aco.minlivepositiontaking
	
	--update a1=l2 when a1>l2
	update cs
	SET apositiontaking = aco.maxpositiontaking
	from @tmp_cs cs
		inner join @tmp_ag aco ON cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.apositiontaking > aco.maxpositiontaking
		
	update cs
	SET alivepositiontaking = aco.maxlivepositiontaking
	from @tmp_cs cs
		inner join @tmp_ag aco ON cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking > aco.maxlivepositiontaking
	
	--Recal AUTO MPT 
	--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
	Update cs
		set mpositiontaking = 
			case when scs.mpositiontaking > mcs.mpositiontaking then
					case when mcs.mpositiontaking- cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					else  mcs.mpositiontaking-cs.apositiontaking end
				else 
					case when scs.mpositiontaking- cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
					else  scs.mpositiontaking-cs.apositiontaking end
				end
	from
		@tmp_cs cs
		inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
		inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
		inner join @tmp_ag as acs on acs.sporttype= cs.sporttype and acs.bettype= cs.bettype
	where
		(acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
	
	Update cs
		set mlivepositiontaking =
			case when scs.mlivepositiontaking > mcs.mlivepositiontaking then
				case when mcs.mlivepositiontaking-cs.alivepositiontaking > (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
					then (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
				else  mcs.mlivepositiontaking-cs.alivepositiontaking end
			else
				case when scs.mlivepositiontaking- cs.alivepositiontaking > (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
					then (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
				else  scs.mlivepositiontaking- cs.alivepositiontaking end
			end
	from
		@tmp_cs cs
		inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
		inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
		inner join @tmp_ag as acs on acs.sporttype= cs.sporttype and acs.bettype= cs.bettype
	where
		 (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1)
			
				
	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	update cs
	set cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
	from @tmp_cs cs
		inner join @tmp_mag mco on cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
	where cs.apositiontaking + cs.mpositiontaking < mco.minpositiontaking
	
	update cs
	set cs.mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
	from @tmp_cs cs
		inner join @tmp_mag mco on cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
	where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking
	
	
	--update m1,a1 when a1+m1>l3
	--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	Update cs
	set @maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
		@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end	
	from @tmp_cs cs
		inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
		inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.apositiontaking +cs.mpositiontaking > mcs.maxpositiontaking
	
	Update cs
	set @maxmapos = case when mcs.mlivepositiontaking>mcs.maxlivepositiontaking then mcs.maxlivepositiontaking else mcs.mlivepositiontaking end,
		@mpos = case when @maxmapos-cs.alivepositiontaking<0 then 0 else @maxmapos-cs.alivepositiontaking end,
		mlivepositiontaking = @mpos,
		@apos = case when cs.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.alivepositiontaking end,
		alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end	
	from @tmp_cs cs
		inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
		inner join @tmp_ag aco on cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking +cs.mlivepositiontaking > mcs.maxlivepositiontaking
	
	--recal autopos
	Update cs
		set spositiontaking = case when scs.spositiontaking- cs.mpositiontaking- cs.apositiontaking >
								(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
	from
		@tmp_cs cs
		inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
		inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
	where
		(cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)

	Update cs
		set slivepositiontaking = case when scs.slivepositiontaking- cs.mlivepositiontaking-cs.alivepositiontaking >
								(case when cs.isautolivepositiontaking=1 then cs.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when cs.isautolivepositiontaking=1 then cs.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-cs.mlivepositiontaking-cs.alivepositiontaking end 
	from
		@tmp_cs cs
		inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
		inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
	where
		(cs.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)
				
	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	update cs
	set spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
	from @tmp_cs cs
		inner JOIN @tmp_sag sco on cs.sporttype = sco.sporttype and cs.bettype = sco.bettype
	where cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking < sco.minpositiontaking 			
	
	update cs
	set slivepositiontaking = sco.minlivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking
	from @tmp_cs cs
		inner JOIN @tmp_sag sco on cs.sporttype = sco.sporttype and cs.bettype = sco.bettype
	where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking 			
	
	
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	update cs
	set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking end,
		spositiontaking = @spos,
		@mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
		@maxmapos = case when mcs.mpositiontaking>mcs.maxpositiontaking then mcs.maxpositiontaking else mcs.mpositiontaking end,
		@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		@mapos = case when @mapos2<mcs.minpositiontaking then mcs.minpositiontaking else @mapos2 end,
		@mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end	
	from @tmp_cs cs
		inner join @tmp_sag scs on cs.sporttype = scs.sporttype and cs.bettype = scs.bettype 
		inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
		inner join @tmp_ag aco on  cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
		
	update cs
	set @spos = case when scs.slivepositiontaking-cs.mlivepositiontaking-cs.alivepositiontaking<0 then 0 else scs.slivepositiontaking - cs.mlivepositiontaking - cs.alivepositiontaking end,
		slivepositiontaking = @spos,
		@mapos1 = case when @spos+cs.mlivepositiontaking+cs.alivepositiontaking>scs.slivepositiontaking then scs.slivepositiontaking-@spos else cs.mlivepositiontaking+cs.alivepositiontaking end,
		@maxmapos = case when mcs.mlivepositiontaking>mcs.maxlivepositiontaking then mcs.maxlivepositiontaking else mcs.mlivepositiontaking end,
		@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		@mapos = case when @mapos2<mcs.minlivepositiontaking then mcs.minlivepositiontaking else @mapos2 end,
		@mpos = case when @mapos-cs.alivepositiontaking<0 then 0 else @mapos-cs.alivepositiontaking end,
		mlivepositiontaking = @mpos,
		@apos = case when cs.alivepositiontaking + @mpos>@mapos then @mapos-@mpos else cs.alivepositiontaking end,
		alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end	
	from @tmp_cs cs
		inner join @tmp_sag scs on cs.sporttype = scs.sporttype and cs.bettype = scs.bettype 
		inner join @tmp_mag mcs on cs.sporttype = mcs.sporttype and cs.bettype = mcs.bettype
		inner join @tmp_ag aco on  cs.sporttype = aco.sporttype and cs.bettype = aco.bettype
	where cs.sporttype = 1 and cs.bettype in (1,3,7,8) and cs.slivepositiontaking + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking
		
	
	update cs
	SET cs.apositiontaking = t.apositiontaking,
		cs.mpositiontaking = t.mpositiontaking,
		cs.spositiontaking = t.spositiontaking,
		cs.alivepositiontaking = t.alivepositiontaking,
		cs.mlivepositiontaking = t.mlivepositiontaking,
		cs.slivepositiontaking = t.slivepositiontaking,
		cs.autopositiontaking = t.autopositiontaking,
		cs.autolivepositiontaking = t.autolivepositiontaking,	
		cs.autompositiontaking = t.autompositiontaking,
		cs.autolivempositiontaking = t.autolivempositiontaking,		
		cs.isautopositiontaking = t.isautopositiontaking,
		cs.isautolivepositiontaking = t.isautolivepositiontaking,
		cs.isautompositiontaking = t.isautompositiontaking,
		cs.isautolivempositiontaking = t.isautolivempositiontaking			
	FROM @tmp_cs t
		INNER JOIN custsetting cs WITH(UPDLOCK,ROWLOCK) ON t.custid = cs.custid and t.sporttype = cs.sporttype and t.bettype = cs.bettype
	WHERE cs.apositiontaking <> t.apositiontaking
			OR cs.mpositiontaking <> t.mpositiontaking
			OR cs.spositiontaking <> t.spositiontaking
			OR cs.alivepositiontaking <> t.alivepositiontaking
			OR cs.mlivepositiontaking <> t.mlivepositiontaking
			OR cs.slivepositiontaking <> t.slivepositiontaking
			OR cs.autopositiontaking <> t.autopositiontaking
			OR cs.autolivepositiontaking <> t.autolivepositiontaking	
			OR cs.autompositiontaking <> t.autompositiontaking
			OR cs.autolivempositiontaking <> t.autolivempositiontaking		
			OR cs.isautopositiontaking <> t.isautopositiontaking
			OR cs.isautolivepositiontaking <> t.isautolivepositiontaking
			OR cs.isautompositiontaking <> t.isautompositiontaking
			OR cs.isautolivempositiontaking <> t.isautolivempositiontaking	
	
END