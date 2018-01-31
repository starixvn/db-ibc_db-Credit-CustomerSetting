/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_09]
	@mrecommend INT = 0,
	@custid int = 0,
	@roleid INT,
	@mode VARCHAR(50)='',
	--super update auto pt on member
	--number game
	@auto_v161spositiontaking_81 smallmoney = 0,
	@auto_v161spositiontaking_83 smallmoney = 0,
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,
	
	@isauto_v161spositiontaking_81 bit = 0,
	@isauto_v161spositiontaking_83 bit = 0,
	@isauto_v161spositiontaking_86 bit = 0,
	@isauto_v161spositiontaking_88 bit = 0,
	@isauto_v161slivepositiontaking_85 bit = 0,
	@isauto_v161slivepositiontaking_86 bit = 0,
	@isauto_v161slivepositiontaking_87 bit = 0,
	@isauto_v161slivepositiontaking_89 bit = 0,
	@isauto_v161slivepositiontaking_90 bit = 0,

	--master update auto pt on member
	--number game
	@auto_v161mpositiontaking_mem_81 smallmoney = 0,
	@auto_v161mpositiontaking_mem_83 smallmoney = 0,
	@auto_v161mpositiontaking_mem_86 smallmoney = 0,
	@auto_v161mpositiontaking_mem_88 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_85 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_86 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_87 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_89 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_90 smallmoney = 0,
	
	@isauto_v161mpositiontaking_mem_81 bit = 0,
	@isauto_v161mpositiontaking_mem_83 bit = 0,
	@isauto_v161mpositiontaking_mem_86 bit = 0,
	@isauto_v161mpositiontaking_mem_88 bit = 0,
	@isauto_v161mlivepositiontaking_mem_85 bit = 0,
	@isauto_v161mlivepositiontaking_mem_86 bit = 0,
	@isauto_v161mlivepositiontaking_mem_87 bit = 0,
	@isauto_v161mlivepositiontaking_mem_89 bit = 0,
	@isauto_v161mlivepositiontaking_mem_90 bit = 0,	
	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv161 BIT = 1
	
 AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update auto pt on member
		DB: DBCUST/bodb02
		Original versions:	Acc_CustomerUpdMember_Super
				Acc_CustomerUpdMember_Master
				Acc_CustomerUpdMemberHR_SAg
				Acc_CustomerUpdMemberHR_MAg
				
		Revision:
			- 20131104@Johnson: Add racing
			- 20140220@Johnson: Merge code correct pt on members after update auto pt for number game[RedmineID: #11562]
			- 20140313@Johnson: Merge code correct pt on members after update auto pt for racing [RedmineID: #11562]
			- 20140424@Johnson: fix bug number game correct super pt on member after master update auto pt on member
			- 20150610@Daniel: 
		       + Improve medthod check table existing in subscribers	
		       + Separate custDB to new server DBCUST  	
			- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON 

	if NOT(dbo.f_CheckRepTable('custinfo') = 1 
	     AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
	     AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
     )
	   	RETURN  
	
	Declare @bettype int,
			@maxpos smallmoney,	
			@autov161positiontaking smallmoney,
			@isautov161positiontaking bit, 
			
			@autov161livepositiontaking smallmoney,
			@isautov161livepositiontaking bit, 

			@srecommend int,			
			@recommend int
	
	DECLARE @tmp_sag TABLE(custid int, sporttype smallint, bettype smallint,
			spositiontaking smallmoney, slivepositiontaking smallmoney, mpositiontaking smallmoney, mlivepositiontaking smallmoney, minpositiontaking smallmoney, minlivepositiontaking smallmoney, maxpositiontaking smallmoney, maxlivepositiontaking smallmoney
		) 
		
	DECLARE @tmp_mag TABLE(custid int, sporttype smallint, bettype smallint,
		mpositiontaking smallmoney, mlivepositiontaking smallmoney, autopositiontaking smallmoney, isautopositiontaking bit, isautolivepositiontaking bit, autolivepositiontaking smallmoney, 
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
	
	select @srecommend = srecommend, @mrecommend = mrecommend, @recommend =recommend from custinfo with (NOLOCK) where custid = @custid
		
	IF @mode = 'number'
	BEGIN
		INSERT INTO @tmp_cs (custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, slivepositiontaking, mlivepositiontaking, alivepositiontaking,
			autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking,
			autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking
		)
		SELECT custid, sporttype, bettype, spositiontaking, mpositiontaking, apositiontaking, slivepositiontaking, mlivepositiontaking, alivepositiontaking,
			autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking,
			autompositiontaking, autolivempositiontaking, isautompositiontaking, isautolivempositiontaking
		FROM custsetting3rd WITH(NOLOCK)
		WHERE custid = @custid and sporttype = 161		
		
		INSERT INTO @tmp_sag(custid, sporttype, bettype, spositiontaking, slivepositiontaking,mpositiontaking, mlivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
		SELECT scs.custid, scs.sporttype, scs.bettype, spositiontaking, slivepositiontaking, mpositiontaking, mlivepositiontaking, sco.minpositiontaking, sco.minlivepositiontaking, sco.maxpositiontaking, sco.maxlivepositiontaking
		FROM custsetting3rd scs with(NOLOCK)
			INNER JOIN custoverride3rd sco WITH(NOLOCK) on scs.custid = sco.custid and scs.sporttype = sco.sporttype and scs.bettype = sco.bettype
		WHERE scs.custid = @srecommend and scs.sporttype = 161
		
		INSERT INTO @tmp_mag(custid, sporttype, bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
		SELECT mcs.custid, mcs.sporttype, mcs.bettype, mpositiontaking, mlivepositiontaking, autopositiontaking, autolivepositiontaking, isautopositiontaking, isautolivepositiontaking, mco.minpositiontaking, mco.minlivepositiontaking, mco.maxpositiontaking, mco.maxlivepositiontaking
		FROM custsetting3rd mcs WITH(NOLOCK)
			inner JOIN custoverride3rd mco WITH(NOLOCK) on mcs.custid = mco.custid and mcs.sporttype = mco.sporttype and mcs.bettype = mco.bettype
		WHERE mcs.custid = @mrecommend and mcs.sporttype = 161	
		
		INSERT INTO @tmp_ag(custid, sporttype, bettype, apositiontaking, alivepositiontaking, isautompositiontaking , autompositiontaking , isautolivempositiontaking , autolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking)
		SELECT cs.custid, cs.sporttype, cs.bettype, apositiontaking, alivepositiontaking, isautompositiontaking , autompositiontaking , cs.isautolivempositiontaking , autolivempositiontaking, minpositiontaking, minlivepositiontaking, maxpositiontaking, maxlivepositiontaking
		FROM custoverride3rd co WITH(NOLOCK)
			inner join custSetting3rd cs WITH(NOLOCK) on cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
		WHERE cs.custid = @recommend and cs.sporttype = 161			
	
		IF @roleid = 4
		BEGIN						
			Declare
					@old_autov161positiontaking smallmoney,
					@old_isautov161positiontaking smallmoney,
					
					@old_autov161livepositiontaking smallmoney,
					@old_isautov161livepositiontaking smallmoney		
			declare 
			@old_auto_v161spositiontaking_81 smallmoney,
			@old_auto_v161spositiontaking_83 smallmoney,
			@old_auto_v161spositiontaking_86 smallmoney,
			@old_auto_v161spositiontaking_88 smallmoney,
			@old_auto_v161slivepositiontaking_85 smallmoney,
			@old_auto_v161slivepositiontaking_86 smallmoney,
			@old_auto_v161slivepositiontaking_87 smallmoney,
			@old_auto_v161slivepositiontaking_89 smallmoney,
			@old_auto_v161slivepositiontaking_90 smallmoney,
			
			@old_isauto_v161spositiontaking_81 bit,
			@old_isauto_v161spositiontaking_83 bit,
			@old_isauto_v161spositiontaking_86 bit,
			@old_isauto_v161spositiontaking_88 bit,
			@old_isauto_v161slivepositiontaking_85 bit,
			@old_isauto_v161slivepositiontaking_86 bit,
			@old_isauto_v161slivepositiontaking_87 bit,
			@old_isauto_v161slivepositiontaking_89 bit,
			@old_isauto_v161slivepositiontaking_90 bit,
			
			@master_auto_v161spositiontaking_81 smallmoney,
			@master_auto_v161spositiontaking_83 smallmoney,
			@master_auto_v161spositiontaking_86 smallmoney,
			@master_auto_v161spositiontaking_88 smallmoney,
			@master_auto_v161slivepositiontaking_85 smallmoney,
			@master_auto_v161slivepositiontaking_86 smallmoney,
			@master_auto_v161slivepositiontaking_87 smallmoney,
			@master_auto_v161slivepositiontaking_89 smallmoney,
			@master_auto_v161slivepositiontaking_90 smallmoney,
			
			@master_isauto_v161spositiontaking_81 bit,
			@master_isauto_v161spositiontaking_83 bit,
			@master_isauto_v161spositiontaking_86 bit,
			@master_isauto_v161spositiontaking_88 bit,
			@master_isauto_v161slivepositiontaking_85 bit,
			@master_isauto_v161slivepositiontaking_86 bit,
			@master_isauto_v161slivepositiontaking_87 bit,
			@master_isauto_v161slivepositiontaking_89 bit,
			@master_isauto_v161slivepositiontaking_90 bit
			
			-- number game
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
				BEGIN --UpdatePositiontakingv161
					select 	@old_auto_v161spositiontaking_81	=	autopositiontaking		,	@old_isauto_v161spositiontaking_81	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=81
					select 	@old_auto_v161spositiontaking_83	=	autopositiontaking		,	@old_isauto_v161spositiontaking_83	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=83
					select 	@old_auto_v161spositiontaking_86	=	autopositiontaking		,	@old_isauto_v161spositiontaking_86	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=86
					select 	@old_auto_v161spositiontaking_88	=	autopositiontaking		,	@old_isauto_v161spositiontaking_88	=	isautopositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=88
					select 	@old_auto_v161slivepositiontaking_85	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_85	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=85
					select 	@old_auto_v161slivepositiontaking_86	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_86	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=86
					select 	@old_auto_v161slivepositiontaking_87	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_87	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=87
					select 	@old_auto_v161slivepositiontaking_89	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_89	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=89
					select 	@old_auto_v161slivepositiontaking_90	=	autolivepositiontaking		,	@old_isauto_v161slivepositiontaking_90	=	isautolivepositiontaking		from custsetting3rd with (nolock) where custid = @custid and sporttype=161	and bettype=90
				END  --UpdatePositiontakingv161

			--Get Auto PT of member from Master
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
				BEGIN --UpdatePositiontakingv161
					select @master_auto_v161spositiontaking_81 = autopositiontaking, @master_isauto_v161spositiontaking_81 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=81 and sporttype=161
					select @master_auto_v161spositiontaking_83 = autopositiontaking, @master_isauto_v161spositiontaking_83 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=83 and sporttype=161
					select @master_auto_v161spositiontaking_88 = autopositiontaking, @master_isauto_v161spositiontaking_88 = isautopositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=88 and sporttype=161
					select															 @master_auto_v161slivepositiontaking_85 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_85 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
					select @master_auto_v161spositiontaking_86 = autopositiontaking, @master_auto_v161slivepositiontaking_86 = autolivepositiontaking, @master_isauto_v161spositiontaking_86 = isautopositiontaking, @master_isauto_v161slivepositiontaking_86 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
					select															 @master_auto_v161slivepositiontaking_87 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_87 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=87 and sporttype=161
					select															 @master_auto_v161slivepositiontaking_89 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_89 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=89 and sporttype=161
					select															 @master_auto_v161slivepositiontaking_90 = autolivepositiontaking,																 @master_isauto_v161slivepositiontaking_90 = isautolivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=90 and sporttype=161
				END  --UpdatePositiontakingv161
			
				--Update Member account (autopositiontaking field) - Number game
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
				Begin --@UpdatePositiontakingv161
					update cs
					set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
					from @tmp_cs cs
						inner JOIN 
						(
											select 81 as bettype, 161 as sporttype, @auto_v161spositiontaking_81 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_81 as isautopositiontaking,									0	as isautolivepositiontaking
								union all 	select 83 as bettype, 161 as sporttype, @auto_v161spositiontaking_83 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_83 as isautopositiontaking,									0	as isautolivepositiontaking
								union all 	select 88 as bettype, 161 as sporttype, @auto_v161spositiontaking_88 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_88 as isautopositiontaking,									0	as isautolivepositiontaking
								union all 	select 85 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_85	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_85	as isautolivepositiontaking
								union all 	select 86 as bettype, 161 as sporttype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86	as autolivepositiontaking, @isauto_v161spositiontaking_86 as isautopositiontaking, @isauto_v161slivepositiontaking_86	as isautolivepositiontaking
								union all 	select 87 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_87	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_87	as isautolivepositiontaking
								union all 	select 89 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_89	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_89	as isautolivepositiontaking
								union all 	select 90 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_90	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_90	as isautolivepositiontaking					
							) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
					
					
					/*update cs3 with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
					from custsetting3rd cs3 inner join 
							(
											select 81 as bettype, 161 as sporttype, @auto_v161spositiontaking_81 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_81 as isautopositiontaking,									0	as isautolivepositiontaking
								union all 	select 83 as bettype, 161 as sporttype, @auto_v161spositiontaking_83 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_83 as isautopositiontaking,									0	as isautolivepositiontaking
								union all 	select 88 as bettype, 161 as sporttype, @auto_v161spositiontaking_88 as autopositiontaking,									0	as autolivepositiontaking, @isauto_v161spositiontaking_88 as isautopositiontaking,									0	as isautolivepositiontaking
								union all 	select 85 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_85	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_85	as isautolivepositiontaking
								union all 	select 86 as bettype, 161 as sporttype, @auto_v161spositiontaking_86 as autopositiontaking, @auto_v161slivepositiontaking_86	as autolivepositiontaking, @isauto_v161spositiontaking_86 as isautopositiontaking, @isauto_v161slivepositiontaking_86	as isautolivepositiontaking
								union all 	select 87 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_87	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_87	as isautolivepositiontaking
								union all 	select 89 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_89	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_89	as isautolivepositiontaking
								union all 	select 90 as bettype, 161 as sporttype, 0							 as autopositiontaking, @auto_v161slivepositiontaking_90	as autolivepositiontaking,								0 as isautopositiontaking, @isauto_v161slivepositiontaking_90	as isautolivepositiontaking					
							) as b on b.bettype = cs3.bettype and b.sporttype = cs3.sporttype
					where cs3.custid = @custid
					*/
				END --@UpdatePositiontakingv161
			
			--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
			select 
				-- number game
				@auto_v161spositiontaking_81 = case when @isauto_v161spositiontaking_81>0 then @auto_v161spositiontaking_81 else @master_auto_v161spositiontaking_81 end,			
				@auto_v161spositiontaking_83 = case when @isauto_v161spositiontaking_83>0 then @auto_v161spositiontaking_83 else @master_auto_v161spositiontaking_83 end,			
				@auto_v161spositiontaking_86 = case when @isauto_v161spositiontaking_86>0 then @auto_v161spositiontaking_86 else @master_auto_v161spositiontaking_86 end,			
				@auto_v161spositiontaking_88 = case when @isauto_v161spositiontaking_88>0 then @auto_v161spositiontaking_88 else @master_auto_v161spositiontaking_88 end,			
				@auto_v161slivepositiontaking_85 = case when @isauto_v161slivepositiontaking_85>0 then @auto_v161slivepositiontaking_85 else @master_auto_v161slivepositiontaking_85 end,			
				@auto_v161slivepositiontaking_86 = case when @isauto_v161slivepositiontaking_86>0 then @auto_v161slivepositiontaking_86 else @master_auto_v161slivepositiontaking_86 end,			
				@auto_v161slivepositiontaking_87 = case when @isauto_v161slivepositiontaking_87>0 then @auto_v161slivepositiontaking_87 else @master_auto_v161slivepositiontaking_87 end,
				@auto_v161slivepositiontaking_89 = case when @isauto_v161slivepositiontaking_89>0 then @auto_v161slivepositiontaking_89 else @master_auto_v161slivepositiontaking_89 end,
				@auto_v161slivepositiontaking_90 = case when @isauto_v161slivepositiontaking_90>0 then @auto_v161slivepositiontaking_90 else @master_auto_v161slivepositiontaking_90 end,
				
				-- number game
				@isauto_v161spositiontaking_81 = case when @isauto_v161spositiontaking_81>0 then @isauto_v161spositiontaking_81 else @master_isauto_v161spositiontaking_81 end,
				@isauto_v161spositiontaking_83 = case when @isauto_v161spositiontaking_83>0 then @isauto_v161spositiontaking_83 else @master_isauto_v161spositiontaking_83 end,
				@isauto_v161spositiontaking_86 = case when @isauto_v161spositiontaking_86>0 then @isauto_v161spositiontaking_86 else @master_isauto_v161spositiontaking_86 end,
				@isauto_v161spositiontaking_88 = case when @isauto_v161spositiontaking_88>0 then @isauto_v161spositiontaking_88 else @master_isauto_v161spositiontaking_88 end,
				@isauto_v161slivepositiontaking_85 = case when @isauto_v161slivepositiontaking_85>0 then @isauto_v161slivepositiontaking_85 else @master_isauto_v161slivepositiontaking_85 end,
				@isauto_v161slivepositiontaking_86 = case when @isauto_v161slivepositiontaking_86>0 then @isauto_v161slivepositiontaking_86 else @master_isauto_v161slivepositiontaking_86 end,
				@isauto_v161slivepositiontaking_87 = case when @isauto_v161slivepositiontaking_87>0 then @isauto_v161slivepositiontaking_87 else @master_isauto_v161slivepositiontaking_87 end,
				@isauto_v161slivepositiontaking_89 = case when @isauto_v161slivepositiontaking_89>0 then @isauto_v161slivepositiontaking_89 else @master_isauto_v161slivepositiontaking_89 end,
				@isauto_v161slivepositiontaking_90 = case when @isauto_v161slivepositiontaking_90>0 then @isauto_v161slivepositiontaking_90 else @master_isauto_v161slivepositiontaking_90 end


				--Update member account
				--Using Cursor (spositiontaking field)
				DECLARE CUR CURSOR FOR 
						select 81 as bettype, @isauto_v161spositiontaking_81 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_81 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking								, @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
			union all  	select 83 as bettype, @isauto_v161spositiontaking_83 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_83 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
			union all  	select 88 as bettype, @isauto_v161spositiontaking_88 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_88 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking

			union all  	select 85 as bettype, 0								 as isautov161positiontaking	, @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking,							  @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
			union all  	select 86 as bettype, @isauto_v161spositiontaking_86 as isautov161positiontaking	, @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking	, @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking	, @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking	, @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
			union all  	select 87 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
			union all  	select 89 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
			union all  	select 90 as bettype, 0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking
				
				OPEN CUR

				FETCH NEXT FROM CUR INTO
					@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
				
				WHILE @@FETCH_STATUS = 0
					BEGIN
						-- Update number game (non-live)
						if @bettype in (81,83,86,88) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
							BEGIN
								if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
									Begin --@UpdatePositiontakingv161
										if @isautov161positiontaking > 0
											BEGIN
												select @maxpos = spositiontaking from @tmp_sag where sporttype=161 and bettype = @bettype
												
												update cs
												SET  spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
												from @tmp_cs cs
												where cs.bettype = @bettype 
												
												/*
												select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
												
												update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
												from custsetting3rd cs3
												where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
												*/
											END
									END--@UpdatePositiontakingv161
							END


						-- Update number game (live)
						if @bettype in (85,86,87,89,90) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
							BEGIN
								if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
									Begin --@UpdatePositiontakingv161
										if @isautov161livepositiontaking > 0
											BEGIN
												select @maxpos = slivepositiontaking from @tmp_sag where sporttype=161 and bettype = @bettype
												
												update cs
												set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
												from @tmp_cs cs 
												where cs.bettype = @bettype
												
												/*
												select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
												
												update cs3 with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
												from custsetting3rd cs3
												where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
												*/
											END
									END--@UpdatePositiontakingv161
							END

						FETCH NEXT FROM CUR INTO			
							@bettype, @isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
					END

				CLOSE CUR
				DEALLOCATE CUR				
			END--end roleid = 4
			ELSE IF @roleid = 3
			BEGIN						
				declare @auto_v161mpositiontaking_81 smallmoney,
						@auto_v161mpositiontaking_83 smallmoney,
						@auto_v161mpositiontaking_86 smallmoney,
						@auto_v161mpositiontaking_88 smallmoney,
						@auto_v161mlivepositiontaking_85 smallmoney,
						@auto_v161mlivepositiontaking_86 smallmoney,
						@auto_v161mlivepositiontaking_87 smallmoney,
						@auto_v161mlivepositiontaking_89 smallmoney,
						@auto_v161mlivepositiontaking_90 smallmoney,
						
						@isauto_v161mpositiontaking_81 bit,
						@isauto_v161mpositiontaking_83 bit,
						@isauto_v161mpositiontaking_86 bit,
						@isauto_v161mpositiontaking_88 bit,
						@isauto_v161mlivepositiontaking_85 bit,
						@isauto_v161mlivepositiontaking_86 bit,
						@isauto_v161mlivepositiontaking_87 bit,
						@isauto_v161mlivepositiontaking_89 bit,
						@isauto_v161mlivepositiontaking_90 bit
							
				--Get Auto PT of member from agent
				--um2,im2
				select @auto_v161mpositiontaking_81 = autompositiontaking, @isauto_v161mpositiontaking_81 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=81 and sporttype=161
				select @auto_v161mpositiontaking_83 = autompositiontaking, @isauto_v161mpositiontaking_83 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=83 and sporttype=161
				select @auto_v161mpositiontaking_88 = autompositiontaking, @isauto_v161mpositiontaking_88 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=88 and sporttype=161
				select @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=85 and sporttype=161
				select @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=86 and sporttype=161
				select @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=87 and sporttype=161
				select @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=89 and sporttype=161
				select @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=90 and sporttype=161
				
				UPDATE cs3
				SET autompositiontaking = b.autompositiontaking, autolivempositiontaking = b.autolivempositiontaking, isautompositiontaking = b.isautompositiontaking, isautolivempositiontaking = b.isautolivempositiontaking
				FROM @tmp_cs cs3 inner join 
						(
										select 81 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_81 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_81 as isautompositiontaking, 0				as isautolivempositiontaking
							union all 	select 83 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_83 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_83 as isautompositiontaking, 0				as isautolivempositiontaking
							union all 	select 88 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_88 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_88 as isautompositiontaking, 0				as isautolivempositiontaking
							union all 	select 85 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_85 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_85	as isautolivempositiontaking
							union all 	select 86 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_86 as autompositiontaking, @auto_v161mlivepositiontaking_mem_86 	as autolivempositiontaking, @isauto_v161mpositiontaking_mem_86 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_86	as isautolivempositiontaking
							union all 	select 87 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_87 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_87	as isautolivempositiontaking
							union all 	select 89 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_89 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_89	as isautolivempositiontaking
							union all 	select 90 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_90 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_90	as isautolivempositiontaking
							
						) as b on b.bettype = cs3.bettype and b.sporttype = cs3.sporttype
				
				/*
				--Update Member account (autompositiontaking field)
				update cs3 with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autompositiontaking, autolivempositiontaking = b.autolivempositiontaking, isautompositiontaking = b.isautompositiontaking, isautolivempositiontaking = b.isautolivempositiontaking
				from custsetting3rd cs3 inner join 
						(
										select 81 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_81 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_81 as isautompositiontaking, 0				as isautolivempositiontaking
							union all 	select 83 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_83 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_83 as isautompositiontaking, 0				as isautolivempositiontaking
							union all 	select 88 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_88 as autompositiontaking, 0				as autolivempositiontaking, @isauto_v161mpositiontaking_mem_88 as isautompositiontaking, 0				as isautolivempositiontaking
							union all 	select 85 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_85 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_85	as isautolivempositiontaking
							union all 	select 86 as bettype, 161 as sporttype, @auto_v161mpositiontaking_mem_86 as autompositiontaking, @auto_v161mlivepositiontaking_mem_86 	as autolivempositiontaking, @isauto_v161mpositiontaking_mem_86 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_86	as isautolivempositiontaking
							union all 	select 87 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_87 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_87	as isautolivempositiontaking
							union all 	select 89 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_89 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_89	as isautolivempositiontaking
							union all 	select 90 as bettype, 161 as sporttype, 0 as autompositiontaking, @auto_v161mlivepositiontaking_mem_90 	as autolivempositiontaking, 0 as isautompositiontaking, @isauto_v161mlivepositiontaking_mem_90	as isautolivempositiontaking
							
						) as b on b.bettype = cs3.bettype and b.sporttype = cs3.sporttype
				where cs3.custid = @custid	
				*/	
				--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in agent account)
				-- number game
				select
					@auto_v161mpositiontaking_81 = case when @isauto_v161mpositiontaking_mem_81>0 then @auto_v161mpositiontaking_mem_81 else @auto_v161mpositiontaking_81 end,
					@auto_v161mpositiontaking_83 = case when @isauto_v161mpositiontaking_mem_83>0 then @auto_v161mpositiontaking_mem_83 else @auto_v161mpositiontaking_83 end,	
					@auto_v161mpositiontaking_86 = case when @isauto_v161mpositiontaking_mem_86>0 then @auto_v161mpositiontaking_mem_86 else @auto_v161mpositiontaking_86 end,
					@auto_v161mpositiontaking_88 = case when @isauto_v161mpositiontaking_mem_88>0 then @auto_v161mpositiontaking_mem_88 else @auto_v161mpositiontaking_88 end,
					@auto_v161mlivepositiontaking_85 = case when @isauto_v161mlivepositiontaking_mem_85>0 then @auto_v161mlivepositiontaking_mem_85 else @auto_v161mlivepositiontaking_85 end,
					@auto_v161mlivepositiontaking_86 = case when @isauto_v161mlivepositiontaking_mem_86>0 then @auto_v161mlivepositiontaking_mem_86 else @auto_v161mlivepositiontaking_86 end,
					@auto_v161mlivepositiontaking_87 = case when @isauto_v161mlivepositiontaking_mem_87>0 then @auto_v161mlivepositiontaking_mem_87 else @auto_v161mlivepositiontaking_87 end,
					@auto_v161mlivepositiontaking_89 = case when @isauto_v161mlivepositiontaking_mem_89>0 then @auto_v161mlivepositiontaking_mem_89 else @auto_v161mlivepositiontaking_89 end,
					@auto_v161mlivepositiontaking_90 = case when @isauto_v161mlivepositiontaking_mem_90>0 then @auto_v161mlivepositiontaking_mem_90 else @auto_v161mlivepositiontaking_90 end,

					@isauto_v161mpositiontaking_81 = case when @isauto_v161mpositiontaking_mem_81>0 then @isauto_v161mpositiontaking_mem_81 else @isauto_v161mpositiontaking_81 end,
					@isauto_v161mpositiontaking_83 = case when @isauto_v161mpositiontaking_mem_83>0 then @isauto_v161mpositiontaking_mem_83 else @isauto_v161mpositiontaking_83 end,
					@isauto_v161mpositiontaking_86 = case when @isauto_v161mpositiontaking_mem_86>0 then @isauto_v161mpositiontaking_mem_86 else @isauto_v161mpositiontaking_86 end,
					@isauto_v161mpositiontaking_88 = case when @isauto_v161mpositiontaking_mem_88>0 then @isauto_v161mpositiontaking_mem_88 else @isauto_v161mpositiontaking_88 end,
					@isauto_v161mlivepositiontaking_85 = case when @isauto_v161mlivepositiontaking_mem_85>0 then @isauto_v161mlivepositiontaking_mem_85 else @isauto_v161mlivepositiontaking_85 end,
					@isauto_v161mlivepositiontaking_86 = case when @isauto_v161mlivepositiontaking_mem_86>0 then @isauto_v161mlivepositiontaking_mem_86 else @isauto_v161mlivepositiontaking_86 end,
					@isauto_v161mlivepositiontaking_87 = case when @isauto_v161mlivepositiontaking_mem_87>0 then @isauto_v161mlivepositiontaking_mem_87 else @isauto_v161mlivepositiontaking_87 end,
					@isauto_v161mlivepositiontaking_89 = case when @isauto_v161mlivepositiontaking_mem_89>0 then @isauto_v161mlivepositiontaking_mem_89 else @isauto_v161mlivepositiontaking_89 end,
					@isauto_v161mlivepositiontaking_90 = case when @isauto_v161mlivepositiontaking_mem_90>0 then @isauto_v161mlivepositiontaking_mem_90 else @isauto_v161mlivepositiontaking_90 end

					--Update member account
					--Using Cursor (mpositiontaking field)
					DECLARE CUR CURSOR FOR 
							SELECT 81 AS bettype	, @isauto_v161mpositiontaking_81 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_81 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking
				UNION ALL  	SELECT 83 AS bettype	, @isauto_v161mpositiontaking_83 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_83 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking
				UNION ALL  	SELECT 88 AS bettype	, @isauto_v161mpositiontaking_88 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_88 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking
				UNION ALL  	SELECT 85 AS bettype	,							   0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_85 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_85 AS autov161livepositiontaking
				UNION ALL  	SELECT 86 AS bettype	, @isauto_v161mpositiontaking_86 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_86 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_86 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_86 AS autov161livepositiontaking
				UNION ALL  	SELECT 87 AS bettype	,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_87 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_87 AS autov161livepositiontaking
				UNION ALL  	SELECT 89 AS bettype	,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_89 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_89 AS autov161livepositiontaking
				UNION ALL  	SELECT 90 AS bettype	,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_90 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_90 AS autov161livepositiontaking
				OPEN CUR

				FETCH NEXT FROM CUR INTO
					@bettype, @isautov161positiontaking, @isautov161livepositiontaking,@autov161positiontaking,@autov161livepositiontaking


				--m1=min(u,m3-a1)
				WHILE @@FETCH_STATUS = 0
				BEGIN		
					--Update Number game  -- non-live
					if @bettype in (81,83,86,88) 
					BEGIN

						if @isautov161positiontaking >0
						BEGIN
							select @maxpos = mpositiontaking from @tmp_mag where sporttype=161 and bettype = @bettype
							
							UPDATE cs3
							SET mpositiontaking = case when @maxpos - apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - apositiontaking end
							FROM @tmp_cs cs3
							WHERE cs3.bettype = @bettype and cs3.sporttype=161
							/*
							select @maxpos = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
							
							update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - apositiontaking end
							from custsetting3rd cs3
							where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
							*/
						END
					END
					--Update Number game -- live
					if @bettype in (85,86,87,89,90) 
					BEGIN
						if @isautov161livepositiontaking > 0
						BEGIN
							select @maxpos = mlivepositiontaking from @tmp_mag where sporttype=161 and bettype = @bettype
							
							UPDATE cs3
							SET mlivepositiontaking = case when @maxpos - alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - alivepositiontaking end
							FROM @tmp_cs cs3
							WHERE cs3.bettype = @bettype and cs3.sporttype=161							
							/*
							select @maxpos = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
							
							update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - alivepositiontaking end
							from custsetting3rd cs3
							where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
							*/
						END	
					END		
					FETCH NEXT FROM CUR INTO
						@bettype, @isautov161positiontaking, @isautov161livepositiontaking,@autov161positiontaking,@autov161livepositiontaking
				END
				CLOSE CUR
				DEALLOCATE CUR				
			END--end @roleid =3
			
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
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking < aco.minlivepositiontaking
			
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
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking > aco.maxlivepositiontaking
			
			--Recal AUTO MPT 
			--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
			-------------------
			Update cs 
				set mpositiontaking =
					case when scs.mpositiontaking > mcs.mpositiontaking then 
						case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
						then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
						else  mcs.mpositiontaking-cs.apositiontaking end
					else
						case when scs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
						then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
						else  scs.mpositiontaking-cs.apositiontaking end
					end
			from
				@tmp_cs cs
				inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
				inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
				inner join @tmp_ag as acs  on acs.sporttype= cs.sporttype and acs.bettype= cs.bettype
			where
				(acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
				
			Update cs
			set mlivepositiontaking =
				case when scs.mlivepositiontaking > mcs.mlivepositiontaking then
					case when mcs.mlivepositiontaking-cs.alivepositiontaking > (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
						then (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
					else  mcs.mlivepositiontaking-cs.alivepositiontaking end
				else
					case when scs.mlivepositiontaking-cs.alivepositiontaking > (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
						then (case when cs.isautolivempositiontaking = 1 then cs.autolivempositiontaking else acs.autolivempositiontaking end)
					else  scs.mlivepositiontaking-cs.alivepositiontaking end
				end
		from
			@tmp_cs cs
			inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
			inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
			inner join @tmp_ag as acs on acs.sporttype= cs.sporttype and acs.bettype= cs.bettype
		where
			cs.bettype in (85, 86, 87,89,90)
			and (acs.isautolivempositiontaking = 1 or cs.isautolivempositiontaking = 1)	
					
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
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking + cs.mlivepositiontaking < mco.minlivepositiontaking
			
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
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking +cs.mlivepositiontaking > mcs.maxlivepositiontaking
			
			--recal autopos
			Update cs
				set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
										(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
			from
				@tmp_cs cs 
				inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
				inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
			where
				(cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
			
			Update cs
				set slivepositiontaking = case when scs.slivepositiontaking-cs.mlivepositiontaking-cs.alivepositiontaking >
										(case when cs.isautolivepositiontaking=1 then cs.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when cs.isautolivepositiontaking=1 then cs.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-cs.mlivepositiontaking-cs.alivepositiontaking end 
			from
				@tmp_cs cs
				inner join @tmp_mag as mcs on mcs.sporttype= cs.sporttype and mcs.bettype= cs.bettype
				inner join @tmp_sag as scs on scs.sporttype= cs.sporttype and scs.bettype= cs.bettype
			where
				cs.bettype in (85,86,87,89,90)
				and (cs.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)	

						
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
			where cs.bettype in (85,86,87,89,90) and cs.alivepositiontaking + cs.mlivepositiontaking + cs.slivepositiontaking < sco.minlivepositiontaking 			
			
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
			where cs.bettype in (85,86,87,89,90) and cs.slivepositiontaking + cs.mlivepositiontaking + cs.alivepositiontaking > scs.slivepositiontaking
				
			update cs
			SET cs.apositiontaking = t.apositiontaking,
				cs.mpositiontaking = t.mpositiontaking,
				cs.spositiontaking = t.spositiontaking,
				cs.alivepositiontaking = t.alivepositiontaking,
				cs.mlivepositiontaking = t.mlivepositiontaking,
				cs.slivepositiontaking = t.slivepositiontaking,
				cs.isautopositiontaking = t.isautopositiontaking,
				cs.isautolivepositiontaking = t.isautolivepositiontaking,
				cs.isautompositiontaking = t.isautompositiontaking,
				cs.isautolivempositiontaking = t.isautolivempositiontaking,
				cs.autopositiontaking = t.autopositiontaking,
				cs.autolivepositiontaking = t.autolivepositiontaking,
				cs.autompositiontaking = t.autompositiontaking,
				cs.autolivempositiontaking = t.autolivempositiontaking
			FROM @tmp_cs t
				INNER JOIN custsetting3rd cs WITH(UPDLOCK,ROWLOCK) ON t.custid = cs.custid and t.sporttype = cs.sporttype and t.bettype = cs.bettype
			WHERE cs.apositiontaking <> t.apositiontaking
					OR cs.mpositiontaking <> t.mpositiontaking
					OR cs.spositiontaking <> t.spositiontaking
					OR cs.alivepositiontaking <> t.alivepositiontaking
					OR cs.mlivepositiontaking <> t.mlivepositiontaking
					OR cs.slivepositiontaking <> t.slivepositiontaking
					OR cs.isautopositiontaking <> t.isautopositiontaking
					OR cs.isautolivepositiontaking <> t.isautolivepositiontaking
					OR cs.isautompositiontaking <> t.isautompositiontaking
					OR cs.isautolivempositiontaking <> t.isautolivempositiontaking
					OR cs.autopositiontaking <> t.autopositiontaking
					OR cs.autolivepositiontaking <> t.autolivepositiontaking
					OR cs.autompositiontaking <> t.autompositiontaking
					OR cs.autolivempositiontaking <> t.autolivempositiontaking
		END--end @mode = 'number'
	
END