ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_AutoMPositiontaking]
	@custid int,
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
	
	-- number game
	@auto_v161mpositiontaking_mem_81 smallmoney = 0,
	@auto_v161mpositiontaking_mem_83 smallmoney = 0,
	@auto_v161mpositiontaking_mem_86 smallmoney = 0,
	@auto_v161mpositiontaking_mem_88 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_85 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_86 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_87 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_89 smallmoney = 0,
	@auto_v161mlivepositiontaking_mem_90 smallmoney = 0,

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
	@isauto_v154mpositiontaking_mem_20 smallmoney = 0,
	
	-- number game
	@isauto_v161mpositiontaking_mem_81 bit = 0,
	@isauto_v161mpositiontaking_mem_83 bit = 0,
	@isauto_v161mpositiontaking_mem_86 bit = 0,
	@isauto_v161mpositiontaking_mem_88 bit = 0,
	@isauto_v161mlivepositiontaking_mem_85 bit = 0,
	@isauto_v161mlivepositiontaking_mem_86 bit = 0,
	@isauto_v161mlivepositiontaking_mem_87 bit = 0,
	@isauto_v161mlivepositiontaking_mem_89 bit = 0,
	@isauto_v161mlivepositiontaking_mem_90 bit = 0,

	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT,
	@language varchar(2) = 'E',
	@userid int
AS
--@Source Control
/*
Created: 20090619@Phuc
Task : Update master auto PT at member level
DB: DBTXN/bodb02

Revisions:
	20100916@Lukas:	- Add number game setting
					- Add Mixed sports setting
					- Remove mix parlay of basketball
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]			
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/



SET NOCOUNT ON
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
	
	@autov161positiontaking smallmoney,
	@isautov161positiontaking bit, 
	
	@autov161livepositiontaking smallmoney,
	@isautov161livepositiontaking bit, 

	@srecommend int,
	@mrecommend int,
	@recommend int
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

	-- number game
	@auto_v161mpositiontaking_81 smallmoney,
	@auto_v161mpositiontaking_83 smallmoney,
	@auto_v161mpositiontaking_86 smallmoney,
	@auto_v161mpositiontaking_88 smallmoney,
	@auto_v161mlivepositiontaking_85 smallmoney,
	@auto_v161mlivepositiontaking_86 smallmoney,
	@auto_v161mlivepositiontaking_87 smallmoney,
	@auto_v161mlivepositiontaking_89 smallmoney,
	@auto_v161mlivepositiontaking_90 smallmoney,
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
	
	-- number game
	@isauto_v161mpositiontaking_81 bit,
	@isauto_v161mpositiontaking_83 bit,
	@isauto_v161mpositiontaking_86 bit,
	@isauto_v161mpositiontaking_88 bit,
	@isauto_v161mlivepositiontaking_85 bit,
	@isauto_v161mlivepositiontaking_86 bit,
	@isauto_v161mlivepositiontaking_87 bit,
	@isauto_v161mlivepositiontaking_89 bit,
	@isauto_v161mlivepositiontaking_90 bit

select @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend from custinfo with (NOLOCK) where custid = @custid

--------------------------------------------------------
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

-- number game
select @auto_v161mpositiontaking_81 = autompositiontaking, @isauto_v161mpositiontaking_81 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=81 and sporttype=161
select @auto_v161mpositiontaking_83 = autompositiontaking, @isauto_v161mpositiontaking_83 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=83 and sporttype=161
select @auto_v161mpositiontaking_88 = autompositiontaking, @isauto_v161mpositiontaking_88 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=88 and sporttype=161
select @auto_v161mlivepositiontaking_85 = autolivempositiontaking, @isauto_v161mlivepositiontaking_85 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=85 and sporttype=161
select @auto_v161mpositiontaking_86 = autompositiontaking, @auto_v161mlivepositiontaking_86 = autolivempositiontaking, @isauto_v161mpositiontaking_86 = isautompositiontaking, @isauto_v161mlivepositiontaking_86 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=86 and sporttype=161
select @auto_v161mlivepositiontaking_87 = autolivempositiontaking, @isauto_v161mlivepositiontaking_87 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=87 and sporttype=161
select @auto_v161mlivepositiontaking_89 = autolivempositiontaking, @isauto_v161mlivepositiontaking_89 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=89 and sporttype=161
select @auto_v161mlivepositiontaking_90 = autolivempositiontaking, @isauto_v161mlivepositiontaking_90 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @recommend and bettype=90 and sporttype=161

--------------------------------------------------------

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
if @@Error <> 0
BEGIN
	
	SELECT @ErrCode = 101,
			@ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
					end	
	return
END

--- number game

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
if @@Error <> 0
BEGIN	
	SELECT @ErrCode = 201,
			@ErrMsg =  
					case @Language 
						when 'E' then 'Error updating auto position taking'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
					end	
	return
END
	
	
---------------------------------------------------------------------------------------------------------------------------------------------
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
	
	-- number game
	@auto_v161mpositiontaking_81 = case when @isauto_v161mpositiontaking_mem_81>0 then @auto_v161mpositiontaking_mem_81 else @auto_v161mpositiontaking_81 end,
	@auto_v161mpositiontaking_83 = case when @isauto_v161mpositiontaking_mem_83>0 then @auto_v161mpositiontaking_mem_83 else @auto_v161mpositiontaking_83 end,	
	@auto_v161mpositiontaking_86 = case when @isauto_v161mpositiontaking_mem_86>0 then @auto_v161mpositiontaking_mem_86 else @auto_v161mpositiontaking_86 end,
	@auto_v161mpositiontaking_88 = case when @isauto_v161mpositiontaking_mem_88>0 then @auto_v161mpositiontaking_mem_88 else @auto_v161mpositiontaking_88 end,
	@auto_v161mlivepositiontaking_85 = case when @isauto_v161mlivepositiontaking_mem_85>0 then @auto_v161mlivepositiontaking_mem_85 else @auto_v161mlivepositiontaking_85 end,
	@auto_v161mlivepositiontaking_86 = case when @isauto_v161mlivepositiontaking_mem_86>0 then @auto_v161mlivepositiontaking_mem_86 else @auto_v161mlivepositiontaking_86 end,
	@auto_v161mlivepositiontaking_87 = case when @isauto_v161mlivepositiontaking_mem_87>0 then @auto_v161mlivepositiontaking_mem_87 else @auto_v161mlivepositiontaking_87 end,
	@auto_v161mlivepositiontaking_89 = case when @isauto_v161mlivepositiontaking_mem_89>0 then @auto_v161mlivepositiontaking_mem_89 else @auto_v161mlivepositiontaking_89 end,
	@auto_v161mlivepositiontaking_90 = case when @isauto_v161mlivepositiontaking_mem_90>0 then @auto_v161mlivepositiontaking_mem_90 else @auto_v161mlivepositiontaking_90 end,

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
	@isauto_v154mpositiontaking_20 = case when @isauto_v154mpositiontaking_mem_20>0 then @isauto_v154mpositiontaking_mem_20 else @isauto_v154mpositiontaking_20 end,
	
	-- number game
	@isauto_v161mpositiontaking_81 = case when @isauto_v161mpositiontaking_mem_81>0 then @isauto_v161mpositiontaking_mem_81 else @isauto_v161mpositiontaking_81 end,
	@isauto_v161mpositiontaking_83 = case when @isauto_v161mpositiontaking_mem_83>0 then @isauto_v161mpositiontaking_mem_83 else @isauto_v161mpositiontaking_83 end,
	@isauto_v161mpositiontaking_86 = case when @isauto_v161mpositiontaking_mem_86>0 then @isauto_v161mpositiontaking_mem_86 else @isauto_v161mpositiontaking_86 end,
	@isauto_v161mpositiontaking_88 = case when @isauto_v161mpositiontaking_mem_88>0 then @isauto_v161mpositiontaking_mem_88 else @isauto_v161mpositiontaking_88 end,
	@isauto_v161mlivepositiontaking_85 = case when @isauto_v161mlivepositiontaking_mem_85>0 then @isauto_v161mlivepositiontaking_mem_85 else @isauto_v161mlivepositiontaking_85 end,
	@isauto_v161mlivepositiontaking_86 = case when @isauto_v161mlivepositiontaking_mem_86>0 then @isauto_v161mlivepositiontaking_mem_86 else @isauto_v161mlivepositiontaking_86 end,
	@isauto_v161mlivepositiontaking_87 = case when @isauto_v161mlivepositiontaking_mem_87>0 then @isauto_v161mlivepositiontaking_mem_87 else @isauto_v161mlivepositiontaking_87 end,
	@isauto_v161mlivepositiontaking_89 = case when @isauto_v161mlivepositiontaking_mem_89>0 then @isauto_v161mlivepositiontaking_mem_89 else @isauto_v161mlivepositiontaking_89 end,
	@isauto_v161mlivepositiontaking_90 = case when @isauto_v161mlivepositiontaking_mem_90>0 then @isauto_v161mlivepositiontaking_mem_90 else @isauto_v161mlivepositiontaking_90 end
---------------------------------------------------------------------------------------------------------------------------------------------

	--Update member account
	--Using Cursor (mpositiontaking field)
	DECLARE CUR CURSOR FOR 
			SELECT 1 AS bettype		,		   @isauto_mpositiontaking_1 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_1 AS isautolivepositiontaking		,		  @auto_mpositiontaking_1 AS autopositiontaking	    	,		   @auto_mlivepositiontaking_1 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_1 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_1 AS autov2positiontaking		,		@isauto_v3mpositiontaking_1 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_1 AS autov3positiontaking,			@isauto_v5mpositiontaking_1 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_1 AS autov5positiontaking		,		@isauto_v8mpositiontaking_1 AS isautov8positiontaking		,		   @auto_v8mpositiontaking_1 AS autov8positiontaking		,		@isauto_v10mpositiontaking_1 AS isautov10positiontaking		,		   @auto_v10mpositiontaking_1 AS autov10positiontaking		,		@isauto_v11mpositiontaking_1 AS isautov11positiontaking		,		   @auto_v11mpositiontaking_1 AS autov11positiontaking		,		@isauto_v99mpositiontaking_1 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_1 AS autov99positiontaking	,	0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 2 AS bettype		,		   @isauto_mpositiontaking_2 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		  @auto_mpositiontaking_2 AS autopositiontaking	    	,									 0 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_2 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_2 AS autov2positiontaking		,		@isauto_v3mpositiontaking_2 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_2 AS autov3positiontaking,			@isauto_v5mpositiontaking_2 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_2 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,		@isauto_v10mpositiontaking_2 AS isautov10positiontaking		,		   @auto_v10mpositiontaking_2 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,		@isauto_v99mpositiontaking_2 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_2 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL 	SELECT 3 AS bettype		,		   @isauto_mpositiontaking_3 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_3 AS isautolivepositiontaking		,		   @auto_mpositiontaking_3 AS autopositiontaking		,		   @auto_mlivepositiontaking_3 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_3 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_3 AS autov2positiontaking		,		@isauto_v3mpositiontaking_3 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_3 AS autov3positiontaking,			@isauto_v5mpositiontaking_3 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_3 AS autov5positiontaking		,		@isauto_v8mpositiontaking_3 AS isautov8positiontaking		,		   @auto_v8mpositiontaking_3 AS autov8positiontaking		,		@isauto_v10mpositiontaking_3 AS isautov10positiontaking		,		   @auto_v10mpositiontaking_3 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,		@isauto_v99mpositiontaking_3 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_3 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 4 AS bettype		,		   @isauto_mpositiontaking_4 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_4 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL 	SELECT 5 AS bettype		,		   @isauto_mpositiontaking_5 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_5 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 6 AS bettype		,		   @isauto_mpositiontaking_6 AS isautopositiontaking		,									0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_6 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 7 AS bettype		,		   @isauto_mpositiontaking_7 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_7 AS isautolivepositiontaking		,		  @auto_mpositiontaking_7 AS autopositiontaking	    	,		   @auto_mlivepositiontaking_7 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_7 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_7 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									 0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 8 AS bettype		,		   @isauto_mpositiontaking_8 AS isautopositiontaking		,		  @isauto_mlivepositiontaking_8 AS isautolivepositiontaking		,		  @auto_mpositiontaking_8 AS autopositiontaking	    	,		   @auto_mlivepositiontaking_8 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_8 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_8 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									 0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 9 AS bettype		,		   @isauto_mpositiontaking_9 AS isautopositiontaking		,									 0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_9 AS autopositiontaking		,									 0 AS autolivepositiontaking		,		/*@isauto_v2mpositiontaking_9*/ 0 AS isautov2positiontaking		,	/*@auto_v2mpositiontaking_9*/  0  AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   @isauto_v99mpositiontaking_9 AS isautov99mppositiontaking ,@auto_v99mpositiontaking_9 AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 10 AS bettype	,		   @isauto_mpositiontaking_10 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,		   @auto_mpositiontaking_10 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL 	SELECT 20 AS bettype	,									 0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,		   @isauto_v2mpositiontaking_20 AS isautov2positiontaking		,		   @auto_v2mpositiontaking_20 AS autov2positiontaking		,		@isauto_v3mpositiontaking_20 AS isautov3positiontaking		,		   @auto_v3mpositiontaking_20 AS autov3positiontaking,			@isauto_v5mpositiontaking_20 AS isautov5positiontaking		,		   @auto_v5mpositiontaking_20 AS autov5positiontaking		,		@isauto_v8mpositiontaking_20 AS isautov8positiontaking		,		   @auto_v8mpositiontaking_20 AS autov8positiontaking		,		@isauto_v10mpositiontaking_20 AS isautov10positiontaking	,		   @auto_v10mpositiontaking_20 AS autov10positiontaking		,		@isauto_v11mpositiontaking_20 AS isautov11positiontaking	,		   @auto_v11mpositiontaking_20 AS autov11positiontaking		,	@isauto_v99mpositiontaking_20 AS isautov99positiontaking		,		   @auto_v99mpositiontaking_20 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,									0 AS autov161livepositiontaking								,@isauto_v154mpositiontaking_20 AS isautov154positiontaking	,@auto_v154mpositiontaking_20 AS autov154positiontaking	
																																																																																																																																																																																																																																																																																																																																																																																																																																																									
UNION ALL  	SELECT 81 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking, @isauto_v161mpositiontaking_81 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_81 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking							,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 83 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking, @isauto_v161mpositiontaking_83 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_83 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking							,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 88 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking, @isauto_v161mpositiontaking_88 AS isautov161positiontaking		,											0 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_88 AS autov161positiontaking	    	,										0 AS autov161livepositiontaking							,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 85 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,							   0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_85 AS isautov161livepositiontaking		,									0	 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_85 AS autov161livepositiontaking						,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 86 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking, @isauto_v161mpositiontaking_86 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_86 AS isautov161livepositiontaking		,		  @auto_v161mpositiontaking_86 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_86 AS autov161livepositiontaking						,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 87 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_87 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_87 AS autov161livepositiontaking						,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 89 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_89 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_89 AS autov161livepositiontaking						,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
UNION ALL  	SELECT 90 AS bettype	,									0 AS isautopositiontaking		,									  0 AS isautolivepositiontaking		,									0 AS autopositiontaking		,									 0 AS autolivepositiontaking		,										0 AS isautov2positiontaking		,									0 AS autov2positiontaking		,									0 AS isautov3positiontaking		,									0 AS autov3positiontaking,										0 AS isautov5positiontaking		,									0 AS autov5positiontaking		,									0 AS isautov8positiontaking		,									0 AS autov8positiontaking		,								0 AS isautov10positiontaking		,									 0 AS autov10positiontaking		,								0 AS isautov11positiontaking		,									0 AS autov11positiontaking		,								0 AS isautov99positiontaking		,									0 AS autov99positiontaking	,   0							AS isautov99mppositiontaking , 0						  AS autov99mppositiontaking,								0 AS isautov161positiontaking		,		  @isauto_v161mlivepositiontaking_90 AS isautov161livepositiontaking		,										0 AS autov161positiontaking	    	,		   @auto_v161mlivepositiontaking_90 AS autov161livepositiontaking						,0 AS isautov154positiontaking								,0 AS autov154positiontaking	
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
	@isautov161positiontaking, @isautov161livepositiontaking,@autov161positiontaking,@autov161livepositiontaking,
	@isautov154positiontaking, @autov154positiontaking



--m1=min(u,m3-a1)
WHILE @@FETCH_STATUS = 0
BEGIN
		if @isautopositiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=1 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - apositiontaking end
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 102,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Soccer)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	---------------------------------
	--Update LIVE
	if @bettype in (1,3,7,8) 
	BEGIN
		if @isautolivepositiontaking >0
		BEGIN
			select @maxpos = mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=1 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - alivepositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 103,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Soccer - LIVE)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
																							when 'CS' then N'(于足球-现场)'
																							when 'CT' then N'(於足球-現場)'
																							when 'TH' then N'(สำหรับการเล่นสดขณะแข่งขัน ของฟุตบอล)'
																							when 'J' then N'(for Soccer - LIVE)'
																							when 'KO' then N'(축구- 생중계)'
																							when 'VI' then N'(Bóng đá - Trực tuyến)'
																							else N'(for Soccer - LIVE)' END
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END		
	---------------------------------
	--Update Basketball
	if @bettype in (1,2,3,7,8,9,20) 
	BEGIN
		if @isautov2positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=2 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=2
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrCode = 104,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Basketball)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
	
	---------------------------------
	--Update Football
	if @bettype in (1,2,3,20) 
	BEGIN
		if @isautov3positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=3 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=3
			if @@Error <> 0
			BEGIN
				
				SELECT @ErrCode = 105,
					@ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END

	---------------------------------
	--Update Tennis
	if @bettype in (1,2,3,20) 
	BEGIN
		if @isautov5positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=5 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=5
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 106,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Tennis)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END

	---------------------------------
	--Update Baseball
	if @bettype in (1,3,20) 
	BEGIN
		if @isautov8positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=8 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=8
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 107,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Baseball)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END

	---------------------------------
	--Update Golf
	if @bettype in (1,2,3,20)
	BEGIN
		if @isautov10positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=10 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=10
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 108,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Golf)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END

	---------------------------------
	--Update Motorsports
	if @bettype in (1,20)
	BEGIN
		if @isautov11positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=11 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=11
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 109,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Motorsports)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END

	---------------------------------
	--Update Other sports
	if @bettype in (1,2,3,20) 
	BEGIN
		if @isautov99positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=99 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 110,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Other sports)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
	
	---------------------------------
	--Update mixed sports
	if @bettype in (9) 
	BEGIN
		if @isautov99mppositiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=99 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 110,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Mix Sports Parlay)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
	
	---------------------------------
	--Update HR Fixed Odds
	if @bettype in (20)
	BEGIN
		if @isautov154positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=154 and bettype = @bettype
			update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov154positiontaking then @autov154positiontaking else @maxpos - apositiontaking end
			from custsetting
			where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=154
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 109,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Motorsports)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
	
	---------------------------------
	--Update Number game  -- non-live
	if @bettype in (81,83,86,88) 
	BEGIN
		if @isautov161positiontaking >0
		BEGIN
			select @maxpos = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
			update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - apositiontaking end
			from custsetting3rd cs3
			where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 202,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Number Game)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
								end	
				DEALLOCATE CUR
				CLOSE CUR
				return
			END
		END
	END
	--Update Number game -- live
	if @bettype in (85,86,87,89,90) 
	BEGIN
		if @isautov161livepositiontaking > 0
		BEGIN

			select @maxpos = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
			update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - alivepositiontaking end
			from custsetting3rd cs3
			where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
			if @@Error <> 0
			BEGIN
				SELECT @ErrCode = 203,
						@ErrMsg =  
								case @Language 
									when 'E' then 'Error updating auto position taking (for Number Game - LIVE)'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
																							when 'CS' then N'(供数字游戏-现场)'
																							when 'CT' then N'(供數字游戲-現場)'
																							when 'TH' then N'(สำหรับเกมหมายเลข -สด)'
																							when 'J' then N'(for Number Game - LIVE)'
																							when 'KO' then N'(for Number Game - LIVE)'
																							when 'VI' then N'(for Number Game - Trực tuyến)'
																							else N'(for Number Game - LIVE)' END
								end		
				DEALLOCATE CUR	
				CLOSE CUR	
				return	
			END	
		END	
	END		
	---------------------------------	
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
		@isautov161positiontaking, @isautov161livepositiontaking,@autov161positiontaking,@autov161livepositiontaking,
		@isautov154positiontaking, @autov154positiontaking
END

CLOSE CUR
DEALLOCATE CUR





GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_AutoMPositiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_AutoMPositiontaking] TO [vnteam] AS [dbo]