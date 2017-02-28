ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgent_AutoPositiontaking]
	@recommend int,
	@mrecommend int,
	@auto_mpositiontaking_1 smallmoney = 0, 
	@auto_mpositiontaking_2 smallmoney = 0,
	@auto_mpositiontaking_3 smallmoney = 0,
	@auto_mpositiontaking_4 smallmoney = 0,
	@auto_mpositiontaking_5 smallmoney= 0,
	@auto_mpositiontaking_6 smallmoney = 0,
	@auto_mpositiontaking_7 smallmoney = 0,
	@auto_mpositiontaking_8 smallmoney = 0,
	@auto_mpositiontaking_9 smallmoney = 0,
	@auto_mpositiontaking_10 smallmoney = 0,
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
	
	--- mixed sports
	@auto_v99mpositiontaking_9 smallmoney = 0,
	@auto_v154mpositiontaking_20 smallmoney = 0,
	
	--number game
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

	@updatemultiple bit = 0,
	@updatepositiontaking bit = 1,
	
	@updatepositiontakingv2 bit = 1,
	@updatepositiontakingv3 bit = 1,
	@updatepositiontakingv5 bit = 1,
	@updatepositiontakingv8 bit = 1,
	@updatepositiontakingv10 bit = 1,
	@updatepositiontakingv11 bit = 1,
	@updatepositiontakingv99 bit = 1,

	-- mixed sports
	@updatepositiontakingv99MP bit = 1,
	@updatepositiontakingv154 bit = 1,
	
	-- number game
	@updatepositiontakingv161 bit = 1,
	
	@language varchar(2),
	@updateallmembers bit = 0,
	@newmpositiontaking smallmoney,
	@userid int,
	
	@isauto_mpositiontaking_1 bit = 0,
	@isauto_mpositiontaking_2 bit = 0,
	@isauto_mpositiontaking_3 bit = 0,
	@isauto_mpositiontaking_4 bit = 0,
	@isauto_mpositiontaking_5 bit= 0,
	@isauto_mpositiontaking_6 bit = 0,
	@isauto_mpositiontaking_7 bit = 0,
	@isauto_mpositiontaking_8 bit = 0,
	@isauto_mpositiontaking_9 bit = 0,
	@isauto_mpositiontaking_10 bit = 0,
	@isauto_mpositiontaking_9999 bit = 0,
	
	@isauto_mlivepositiontaking_1 bit = 0,
	@isauto_mlivepositiontaking_3 bit = 0,
	@isauto_mlivepositiontaking_7 bit = 0,
	@isauto_mlivepositiontaking_8 bit = 0,
	
	@isauto_v2mpositiontaking_1 bit = 0,
	@isauto_v2mpositiontaking_2 bit = 0,
	@isauto_v2mpositiontaking_3 bit = 0,
	@isauto_v2mpositiontaking_7 bit = 0,
	@isauto_v2mpositiontaking_8 bit = 0,
--	@isauto_v2mpositiontaking_9 bit = 0,
	@isauto_v2mpositiontaking_20 bit = 0,
	
	@isauto_v3mpositiontaking_1 bit = 0,
	@isauto_v3mpositiontaking_2 bit = 0,
	@isauto_v3mpositiontaking_3 bit = 0,
	@isauto_v3mpositiontaking_20 bit = 0,

	@isauto_v5mpositiontaking_1 bit = 0,
	@isauto_v5mpositiontaking_2 bit = 0,
	@isauto_v5mpositiontaking_3 bit = 0,
	@isauto_v5mpositiontaking_20 bit = 0,
	@isauto_v5mpositiontaking_9999 bit = 0,

	@isauto_v8mpositiontaking_1 bit = 0,
	@isauto_v8mpositiontaking_3 bit = 0,
	@isauto_v8mpositiontaking_20 bit = 0,

	@isauto_v10mpositiontaking_1 bit = 0,
	@isauto_v10mpositiontaking_2 bit = 0,
	@isauto_v10mpositiontaking_3 bit = 0,
	@isauto_v10mpositiontaking_20 bit = 0,

	@isauto_v11mpositiontaking_1 bit = 0,
	@isauto_v11mpositiontaking_20 bit = 0,

	@isauto_v99mpositiontaking_1 bit = 0,
	@isauto_v99mpositiontaking_2 bit = 0,
	@isauto_v99mpositiontaking_3 bit = 0,
	@isauto_v99mpositiontaking_20 bit = 0,

	-- mixed sports
	@isauto_v99mpositiontaking_9 bit = 0,
	@isauto_v154mpositiontaking_20 bit = 0,

	-- number game
	@isauto_v161mpositiontaking_81 bit = 0,
	@isauto_v161mpositiontaking_83 bit = 0,
	--@isauto_v161mpositiontaking_85 bit = 0,
	@isauto_v161mpositiontaking_86 bit = 0,
	@isauto_v161mpositiontaking_88 bit = 0,
	
	@isauto_v161mlivepositiontaking_85 bit = 0,
	@isauto_v161mlivepositiontaking_86 bit = 0,
	@isauto_v161mlivepositiontaking_87 bit = 0,
	@isauto_v161mlivepositiontaking_89 bit = 0,
	@isauto_v161mlivepositiontaking_90 bit = 0,
	
	-- Outright PT for sports
	@auto_v2mpositiontaking_10 smallmoney = 0,
	@auto_v3mpositiontaking_10 smallmoney = 0,
	@auto_v5mpositiontaking_10 smallmoney = 0,
	@auto_v8mpositiontaking_10 smallmoney = 0,
	@auto_v10mpositiontaking_10 smallmoney = 0,
	@auto_v11mpositiontaking_10 smallmoney = 0,
	@auto_v99mpositiontaking_10 smallmoney = 0,
	
	@isauto_v2mpositiontaking_10 bit = 0,
	@isauto_v3mpositiontaking_10 bit = 0,
	@isauto_v5mpositiontaking_10 bit = 0,
	@isauto_v8mpositiontaking_10 bit = 0,
	@isauto_v10mpositiontaking_10 bit = 0,
	@isauto_v11mpositiontaking_10 bit = 0,
	@isauto_v99mpositiontaking_10 bit = 0,
	
	
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090121@Thien
Task : Update auto PT at agent level
DB: DBTXN/bodb02
Original:[Acc_CustomerUpdAutoPositiontaking_Master]

Revisions:
    - 20081009@Phuc: Auto Master PT  
		Update use Auto_MPT at agent for all members only when:
		(autoMPT at agent changes AND isauto at agent = 1
		OR isauto at agent changes from 0 to 1)
		 m1=min(m3-a1,u2)

		Update a specific MPT for all members only when:
		@updateallmembers = 1
		AND isauto at agent = 0
		AND isauto at agent change from 1 to 0
		m1=min(m2,@newmpositiontaking)
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090630@Phuc: auto master PT on member level.
    - 20100911@Lukas:	- Add number game setting
						- Add mixed sports setting
						- Removed mix parlay of basetball
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131030@Johnson: Apply execrep when update downlines					
	- 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
Param's Explanation:
• @ErrCode:
    = 0: update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON
if @updatepositiontaking = 0 and @updatepositiontakingv2 = 0 and @updatepositiontakingv3 = 0 and @updatepositiontakingv5 = 0 and @updatepositiontakingv8 = 0 and @updatepositiontakingv10 = 0 and @updatepositiontakingv11 = 0  and @updatepositiontakingv99 = 0 and @updatepositiontakingv99mp = 0 and @updatepositiontakingv154 = 0 and @updatepositiontakingv161 = 0 and @updatemultiple=1
BEGIN
	return
END

Declare
	@bettype int,
	@autopositiontaking smallmoney,
	@autolivepositiontaking smallmoney,
	@old_autopositiontaking smallmoney,
	@old_autolivepositiontaking smallmoney,

	@autov2positiontaking smallmoney,
	@autov3positiontaking smallmoney,
	@autov5positiontaking smallmoney,
	@autov8positiontaking smallmoney,
	@autov10positiontaking smallmoney,
	@autov11positiontaking smallmoney,
	@autov99positiontaking smallmoney,

	-- mixed sports
	@autov99mppositiontaking smallmoney,
	@autov154positiontaking smallmoney,
	
	-- number game
	@autov161positiontaking smallmoney,
	@autov161livepositiontaking smallmoney,

	@old_autov2positiontaking smallmoney,
	@old_autov3positiontaking smallmoney,
	@old_autov5positiontaking smallmoney,
	@old_autov8positiontaking smallmoney,
	@old_autov10positiontaking smallmoney,
	@old_autov11positiontaking smallmoney,
	@old_autov99positiontaking smallmoney,
	
	-- mixed sports
	@old_autov99mppositiontaking smallmoney,
	@old_autov154positiontaking smallmoney,
	
	-- number game
	@old_autov161positiontaking smallmoney,
	@old_autov161livepositiontaking smallmoney,

	@maxpos smallmoney,
	@isautopositiontaking bit, 
	@isautolivepositiontaking bit, 
	
	@isautov2positiontaking bit,
	@isautov3positiontaking bit,
	@isautov5positiontaking bit,
	@isautov8positiontaking bit,
	@isautov10positiontaking bit,
	@isautov11positiontaking bit,
	@isautov99positiontaking bit,

	-- mixed sports
	@isautov99mppositiontaking bit,
	@isautov154positiontaking bit,

	-- number game
	@isautov161positiontaking bit,
	@isautov161livepositiontaking bit,

	@old_isautopositiontaking smallmoney, 
	@old_isautolivepositiontaking smallmoney, 
	
	@old_isautov2positiontaking smallmoney,
	@old_isautov3positiontaking smallmoney,
	@old_isautov5positiontaking smallmoney,
	@old_isautov8positiontaking smallmoney,
	@old_isautov10positiontaking smallmoney,
	@old_isautov11positiontaking smallmoney,
	@old_isautov99positiontaking smallmoney,
	
	-- mixed sports
	@old_isautov99mppositiontaking bit,
	@old_isautov154positiontaking smallmoney,
	
	-- number game
	@old_isautov161positiontaking bit,
	@old_isautov161livepositiontaking bit

Declare 
	@old_auto_mpositiontaking_1 smallmoney,
	@old_auto_mpositiontaking_2 smallmoney,
	@old_auto_mpositiontaking_3 smallmoney,
	@old_auto_mpositiontaking_4 smallmoney,
	@old_auto_mpositiontaking_5 smallmoney,
	@old_auto_mpositiontaking_6 smallmoney,
	@old_auto_mpositiontaking_7 smallmoney,
	@old_auto_mpositiontaking_8 smallmoney,
	@old_auto_mpositiontaking_9 smallmoney,
	@old_auto_mpositiontaking_10 smallmoney,
	@old_auto_mpositiontaking_9999 smallmoney,
	@old_auto_mlivepositiontaking_1 smallmoney,
	@old_auto_mlivepositiontaking_3 smallmoney,
	@old_auto_mlivepositiontaking_7 smallmoney,
	@old_auto_mlivepositiontaking_8 smallmoney,
	
	@old_auto_v2mpositiontaking_1 smallmoney,
	@old_auto_v2mpositiontaking_2 smallmoney,
	@old_auto_v2mpositiontaking_3 smallmoney,
	@old_auto_v2mpositiontaking_7 smallmoney,
	@old_auto_v2mpositiontaking_8 smallmoney,
--	@old_auto_v2mpositiontaking_9 smallmoney,
	@old_auto_v2mpositiontaking_20 smallmoney,
	
	@old_auto_v3mpositiontaking_1 smallmoney,
	@old_auto_v3mpositiontaking_2 smallmoney,
	@old_auto_v3mpositiontaking_3 smallmoney,
	@old_auto_v3mpositiontaking_20 smallmoney,

	@old_auto_v5mpositiontaking_1 smallmoney,
	@old_auto_v5mpositiontaking_2 smallmoney,
	@old_auto_v5mpositiontaking_3 smallmoney,
	@old_auto_v5mpositiontaking_20 smallmoney,
	@old_auto_v5mpositiontaking_9999 smallmoney,

	@old_auto_v8mpositiontaking_1 smallmoney,
	@old_auto_v8mpositiontaking_3 smallmoney,
	@old_auto_v8mpositiontaking_20 smallmoney,

	@old_auto_v10mpositiontaking_1 smallmoney,
	@old_auto_v10mpositiontaking_2 smallmoney,
	@old_auto_v10mpositiontaking_3 smallmoney,
	@old_auto_v10mpositiontaking_20 smallmoney,

	@old_auto_v11mpositiontaking_1 smallmoney,
	@old_auto_v11mpositiontaking_20 smallmoney,

	@old_auto_v99mpositiontaking_1 smallmoney,
	@old_auto_v99mpositiontaking_2 smallmoney,
	@old_auto_v99mpositiontaking_3 smallmoney,
	@old_auto_v99mpositiontaking_20 smallmoney,

	-- mixed sports
	@old_auto_v99mpositiontaking_9 smallmoney,
	@old_auto_v154mpositiontaking_20 smallmoney,
	
	-- number game
	@old_auto_v161mpositiontaking_81 smallmoney,
	@old_auto_v161mpositiontaking_83 smallmoney,
	--@old_auto_v161mpositiontaking_85 smallmoney,
	@old_auto_v161mpositiontaking_86 smallmoney,
	@old_auto_v161mpositiontaking_88 smallmoney,
	
	@old_auto_v161mlivepositiontaking_85 smallmoney,
	@old_auto_v161mlivepositiontaking_86 smallmoney,
	@old_auto_v161mlivepositiontaking_87 smallmoney,
	@old_auto_v161mlivepositiontaking_89 smallmoney,
	@old_auto_v161mlivepositiontaking_90 smallmoney,
	
	@old_isauto_mpositiontaking_1 bit,
	@old_isauto_mpositiontaking_2 bit,
	@old_isauto_mpositiontaking_3 bit,
	@old_isauto_mpositiontaking_4 bit,
	@old_isauto_mpositiontaking_5 bit,
	@old_isauto_mpositiontaking_6 bit,
	@old_isauto_mpositiontaking_7 bit,
	@old_isauto_mpositiontaking_8 bit,
	@old_isauto_mpositiontaking_9 bit,
	@old_isauto_mpositiontaking_10 bit,
	@old_isauto_mpositiontaking_9999 bit,
	
	@old_isauto_mlivepositiontaking_1 bit,
	@old_isauto_mlivepositiontaking_3 bit,
	@old_isauto_mlivepositiontaking_7 bit,
	@old_isauto_mlivepositiontaking_8 bit,
	
	@old_isauto_v2mpositiontaking_1 bit,
	@old_isauto_v2mpositiontaking_2 bit,
	@old_isauto_v2mpositiontaking_3 bit,
	@old_isauto_v2mpositiontaking_7 bit,
	@old_isauto_v2mpositiontaking_8 bit,
--	@old_isauto_v2mpositiontaking_9 bit,
	@old_isauto_v2mpositiontaking_20 bit,
	
	@old_isauto_v3mpositiontaking_1 bit,
	@old_isauto_v3mpositiontaking_2 bit,
	@old_isauto_v3mpositiontaking_3 bit,
	@old_isauto_v3mpositiontaking_20 bit,

	@old_isauto_v5mpositiontaking_1 bit,
	@old_isauto_v5mpositiontaking_2 bit,
	@old_isauto_v5mpositiontaking_3 bit,
	@old_isauto_v5mpositiontaking_20 bit,
	@old_isauto_v5mpositiontaking_9999 bit,

	@old_isauto_v8mpositiontaking_1 bit,
	@old_isauto_v8mpositiontaking_3 bit,
	@old_isauto_v8mpositiontaking_20 bit,

	@old_isauto_v10mpositiontaking_1 bit,
	@old_isauto_v10mpositiontaking_2 bit,
	@old_isauto_v10mpositiontaking_3 bit,
	@old_isauto_v10mpositiontaking_20 bit,

	@old_isauto_v11mpositiontaking_1 bit,
	@old_isauto_v11mpositiontaking_20 bit,

	@old_isauto_v99mpositiontaking_1 bit,
	@old_isauto_v99mpositiontaking_2 bit,
	@old_isauto_v99mpositiontaking_3 bit,
	@old_isauto_v99mpositiontaking_20 bit,

	-- mixed sports
	@old_isauto_v99mpositiontaking_9 bit,
	@old_isauto_v154mpositiontaking_20 bit,
	
	-- number game
	@old_isauto_v161mpositiontaking_81 bit,
	@old_isauto_v161mpositiontaking_83 bit,
	--@old_isauto_v161mpositiontaking_85 bit,
	@old_isauto_v161mpositiontaking_86 bit,
	@old_isauto_v161mpositiontaking_88 bit,
	
	@old_isauto_v161mlivepositiontaking_85 bit,
	@old_isauto_v161mlivepositiontaking_86 bit,
	@old_isauto_v161mlivepositiontaking_87 bit,
	@old_isauto_v161mlivepositiontaking_89 bit,
	@old_isauto_v161mlivepositiontaking_90 bit,
	
	-- Outright PT for sports
	
	@old_auto_v2mpositiontaking_10 smallmoney,
	@old_auto_v3mpositiontaking_10 smallmoney,
	@old_auto_v5mpositiontaking_10 smallmoney,
	@old_auto_v8mpositiontaking_10 smallmoney,
	@old_auto_v10mpositiontaking_10 smallmoney,
	@old_auto_v11mpositiontaking_10 smallmoney,
	@old_auto_v99mpositiontaking_10 smallmoney,
	
	@old_isauto_v2mpositiontaking_10 bit,
	@old_isauto_v3mpositiontaking_10 bit,
	@old_isauto_v5mpositiontaking_10 bit,
	@old_isauto_v8mpositiontaking_10 bit,
	@old_isauto_v10mpositiontaking_10 bit,
	@old_isauto_v11mpositiontaking_10 bit,
	@old_isauto_v99mpositiontaking_10 bit

--------------------------------------------------------
--Get old Auto PT from Agent
select 	@old_auto_mpositiontaking_1	=	autompositiontaking		,	@old_isauto_mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	1
select 	@old_auto_mpositiontaking_2	=	autompositiontaking		,	@old_isauto_mpositiontaking_2	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	2
select 	@old_auto_mpositiontaking_3	=	autompositiontaking		,	@old_isauto_mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	3
select 	@old_auto_mpositiontaking_4	=	autompositiontaking		,	@old_isauto_mpositiontaking_4	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	4
select 	@old_auto_mpositiontaking_5	=	autompositiontaking		,	@old_isauto_mpositiontaking_5	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	5
select 	@old_auto_mpositiontaking_6	=	autompositiontaking		,	@old_isauto_mpositiontaking_6	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	6
select 	@old_auto_mpositiontaking_7	=	autompositiontaking		,	@old_isauto_mpositiontaking_7	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	7
select 	@old_auto_mpositiontaking_8	=	autompositiontaking		,	@old_isauto_mpositiontaking_8	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	8
select 	@old_auto_mpositiontaking_9	=	autompositiontaking		,	@old_isauto_mpositiontaking_9	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	9
select 	@old_auto_mpositiontaking_10	=	autompositiontaking		,	@old_isauto_mpositiontaking_10	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	10

-- Outright PT for sports
select 	@old_auto_v2mpositiontaking_10 = autompositiontaking, @old_isauto_v2mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =2 	and bettype=	10
select 	@old_auto_v3mpositiontaking_10 = autompositiontaking, @old_isauto_v3mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =3 	and bettype=	10
select 	@old_auto_v5mpositiontaking_10 = autompositiontaking, @old_isauto_v5mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =5 	and bettype=	10
select 	@old_auto_v8mpositiontaking_10 = autompositiontaking, @old_isauto_v8mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =8 	and bettype=	10
select 	@old_auto_v10mpositiontaking_10 = autompositiontaking, @old_isauto_v10mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =10 	and bettype=	10
select 	@old_auto_v11mpositiontaking_10 = autompositiontaking, @old_isauto_v11mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =11 	and bettype=	10
select 	@old_auto_v99mpositiontaking_10 = autompositiontaking, @old_isauto_v99mpositiontaking_10 = isautompositiontaking	from custsetting with (nolock) where custid = @recommend and sporttype =99 	and bettype=	10

select 	@old_auto_mpositiontaking_9999	=	autompositiontaking		,	@old_isauto_mpositiontaking_9999	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	9999
select 	@old_auto_mlivepositiontaking_1	=	autolivempositiontaking		,	@old_isauto_mlivepositiontaking_1	=	isautolivempositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	1
select 	@old_auto_mlivepositiontaking_3	=	autolivempositiontaking		,	@old_isauto_mlivepositiontaking_3	=	isautolivempositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	3
select 	@old_auto_mlivepositiontaking_7	=	autolivempositiontaking		,	@old_isauto_mlivepositiontaking_7	=	isautolivempositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	7
select 	@old_auto_mlivepositiontaking_8	=	autolivempositiontaking		,	@old_isauto_mlivepositiontaking_8	=	isautolivempositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype =	1	and bettype=	8

select 	@old_auto_v2mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	1
select 	@old_auto_v2mpositiontaking_2	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_2	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	2
select 	@old_auto_v2mpositiontaking_3	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	3
select 	@old_auto_v2mpositiontaking_7	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_7	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	7
select 	@old_auto_v2mpositiontaking_8	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_8	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	8
--select 	@old_auto_v2mpositiontaking_9	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_9	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	9
select 	@old_auto_v2mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v2mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=2	and bettype=	20

select 	@old_auto_v3mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v3mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=3	and bettype=	1
select 	@old_auto_v3mpositiontaking_2	=	autompositiontaking		,	@old_isauto_v3mpositiontaking_2	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=3	and bettype=	2
select 	@old_auto_v3mpositiontaking_3	=	autompositiontaking		,	@old_isauto_v3mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=3	and bettype=	3
select 	@old_auto_v3mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v3mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=3	and bettype=	20

select 	@old_auto_v5mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v5mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=5	and bettype=	1
select 	@old_auto_v5mpositiontaking_2	=	autompositiontaking		,	@old_isauto_v5mpositiontaking_2	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=5	and bettype=	2
select 	@old_auto_v5mpositiontaking_3	=	autompositiontaking		,	@old_isauto_v5mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=5	and bettype=	3
select 	@old_auto_v5mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v5mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=5	and bettype=	20
select 	@old_auto_v5mpositiontaking_9999	=	autompositiontaking		,	@old_isauto_v5mpositiontaking_9999	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=5	and bettype=	9999

select 	@old_auto_v8mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v8mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=8	and bettype=	1
select 	@old_auto_v8mpositiontaking_3	=	autompositiontaking		,	@old_isauto_v8mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=8	and bettype=	3
select 	@old_auto_v8mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v8mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=8	and bettype=	20

select 	@old_auto_v10mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v10mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=10	and bettype=	1
select 	@old_auto_v10mpositiontaking_2	=	autompositiontaking		,	@old_isauto_v10mpositiontaking_2	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=10	and bettype=	2
select 	@old_auto_v10mpositiontaking_3	=	autompositiontaking		,	@old_isauto_v10mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=10	and bettype=	3
select 	@old_auto_v10mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v10mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=10	and bettype=	20

select 	@old_auto_v11mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v11mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=11	and bettype=	1
select 	@old_auto_v11mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v11mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=11	and bettype=	20

select 	@old_auto_v99mpositiontaking_1	=	autompositiontaking		,	@old_isauto_v99mpositiontaking_1	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=99	and bettype=	1
select 	@old_auto_v99mpositiontaking_2	=	autompositiontaking		,	@old_isauto_v99mpositiontaking_2	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=99	and bettype=	2
select 	@old_auto_v99mpositiontaking_3	=	autompositiontaking		,	@old_isauto_v99mpositiontaking_3	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=99	and bettype=	3
select 	@old_auto_v99mpositiontaking_20	=	autompositiontaking		,	@old_isauto_v99mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=99	and bettype=	20

-- mixed sports
select 	@old_auto_v99mpositiontaking_9	=	autompositiontaking		,	@old_isauto_v99mpositiontaking_9	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=99	and bettype=	9
select 	@old_auto_v154mpositiontaking_20=	autompositiontaking		,	@old_isauto_v154mpositiontaking_20	=	isautompositiontaking		from custsetting with (nolock) where custid = @recommend and sporttype=154	and bettype=	20

-- number game
select 	@old_auto_v161mpositiontaking_81	=	autompositiontaking		,	@old_isauto_v161mpositiontaking_81	=	isautompositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	81
select 	@old_auto_v161mpositiontaking_83	=	autompositiontaking		,	@old_isauto_v161mpositiontaking_83	=	isautompositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	83
--select 	@old_auto_v161mpositiontaking_85	=	autompositiontaking		,	@old_isauto_v161mpositiontaking_85	=	isautompositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	85
select 	@old_auto_v161mpositiontaking_86	=	autompositiontaking		,	@old_isauto_v161mpositiontaking_86	=	isautompositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	86
select 	@old_auto_v161mpositiontaking_88	=	autompositiontaking		,	@old_isauto_v161mpositiontaking_88	=	isautompositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	88

select 	@old_auto_v161mlivepositiontaking_85	=	autolivempositiontaking		,	@old_isauto_v161mlivepositiontaking_85	=	isautolivempositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	85
select 	@old_auto_v161mlivepositiontaking_86	=	autolivempositiontaking		,	@old_isauto_v161mlivepositiontaking_86	=	isautolivempositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	86
select 	@old_auto_v161mlivepositiontaking_87	=	autolivempositiontaking		,	@old_isauto_v161mlivepositiontaking_87	=	isautolivempositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	87
select 	@old_auto_v161mlivepositiontaking_89	=	autolivempositiontaking		,	@old_isauto_v161mlivepositiontaking_89	=	isautolivempositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	89
select 	@old_auto_v161mlivepositiontaking_90	=	autolivempositiontaking		,	@old_isauto_v161mlivepositiontaking_90	=	isautolivempositiontaking		from custsetting3rd with (nolock) where custid = @recommend and sporttype=161	and bettype=	90


if @updatepositiontaking = 1 or @updatemultiple=0
BEGIN
	--Update Master Agent account (autopositiontaking field)
	--For Football
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_mpositiontaking_1 as autopositiontaking, @auto_mlivepositiontaking_1	as autolivepositiontaking, @isauto_mpositiontaking_1 as isautopositiontaking, @isauto_mlivepositiontaking_1	as isautolivepositiontaking
				union all 	select 2 as bettype, @auto_mpositiontaking_2 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_2 as isautopositiontaking, 0				as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_mpositiontaking_3 as autopositiontaking, @auto_mlivepositiontaking_3 	as autolivepositiontaking, @isauto_mpositiontaking_3 as isautopositiontaking, @isauto_mlivepositiontaking_3	as isautolivepositiontaking
				union all 	select 4 as bettype, @auto_mpositiontaking_4 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_4 as isautopositiontaking, 0				as isautolivepositiontaking
				union all 	select 5 as bettype, @auto_mpositiontaking_5 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_5 as isautopositiontaking, 0				as isautolivepositiontaking
				union all 	select 6 as bettype, @auto_mpositiontaking_6 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_6 as isautopositiontaking, 0				as isautolivepositiontaking
				union all 	select 7 as bettype, @auto_mpositiontaking_7 as autopositiontaking, @auto_mlivepositiontaking_7 	as autolivepositiontaking, @isauto_mpositiontaking_7 as isautopositiontaking, @isauto_mlivepositiontaking_7	as isautolivepositiontaking
				union all 	select 8 as bettype, @auto_mpositiontaking_8 as autopositiontaking, @auto_mlivepositiontaking_8 	as autolivepositiontaking, @isauto_mpositiontaking_8 as isautopositiontaking, @isauto_mlivepositiontaking_8	as isautolivepositiontaking			
				union all 	select 9 as bettype, @auto_mpositiontaking_9 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_9 as isautopositiontaking, 0				as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_mpositiontaking_10 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_10 as isautopositiontaking, 0				as isautolivepositiontaking
				
				union all 	select 9999 as bettype, @auto_mpositiontaking_9999 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_9999 as isautopositiontaking, 0				as isautolivepositiontaking
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=1
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Soccer)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
			end	
			,  @ErrCode=201
		return
	END
END
if (@updatepositiontakingv2 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Basketball
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v2mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 2 as bettype, @auto_v2mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_v2mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 7 as bettype, @auto_v2mpositiontaking_7 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_7 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 8 as bettype, @auto_v2mpositiontaking_8 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_8 as isautopositiontaking, 0	as isautolivepositiontaking
--				union all 	select 9 as bettype, @auto_v2mpositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v2mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
			
				union all 	select 10 as bettype, @auto_v2mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
				
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=2
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Basketball)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
			end	
			,  @ErrCode=202
		return
	END
END

if (@updatepositiontakingv3 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Football
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v3mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 2 as bettype, @auto_v3mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_v3mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v3mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_v3mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
				
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=3
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Football)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
			end	
			,  @ErrCode=203
		return
	END
END

if (@updatepositiontakingv5 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Tennis
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v5mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 2 as bettype, @auto_v5mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_v5mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v5mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 9999 as bettype, @auto_v5mpositiontaking_9999 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_9999 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_v5mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=5
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Tennis)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
			end	
			,  @ErrCode=204
		return
	END
END

if (@updatepositiontakingv8 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Baseball
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v8mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_v8mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v8mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_v8mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=8
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Baseball)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
			end	
			,  @ErrCode=205
		return
	END
END

if (@updatepositiontakingv10 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Golf
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v10mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 2 as bettype, @auto_v10mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_v10mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v10mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_v10mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
				
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=10
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Golf)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
			end	
			,  @ErrCode=206
		return
	END
END

if (@updatepositiontakingv11 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Motorsports
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v11mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v11mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_v11mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=11
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Motorsports)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
			end	
			,  @ErrCode=207
		return
	END
END

if (@updatepositiontakingv99 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Other sports
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
							select 1 as bettype, @auto_v99mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 2 as bettype, @auto_v99mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 3 as bettype, @auto_v99mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 20 as bettype, @auto_v99mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
				union all 	select 10 as bettype, @auto_v99mpositiontaking_10 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_10 as isautopositiontaking, 0	as isautolivepositiontaking
				
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=99
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Other sports)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
			end	
			,  @ErrCode=208
		return
	END
END

--- mixed sports
if (@updatepositiontakingv99mp = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Mixed sports
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
				select 9 as bettype, @auto_v99mpositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking
				
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=99
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
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
			,  @ErrCode=301
		return
	END
END

if (@updatepositiontakingv154 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For Motorsports
	update custsetting with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting inner join 
			(
						select 20 as bettype, @auto_v154mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v154mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking
			) as b on b.bettype = custsetting.bettype
	where custsetting.custid = @recommend and custsetting.sporttype=154
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Motorsports)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
			end	
			,  @ErrCode=207
		return
	END
END

--- number game
if (@updatepositiontakingv161 = 1 or @updatemultiple=0)
BEGIN
	--Update Master Agent account
	--For number game
	update cs3 with (ROWLOCK, UPDLOCK) set autompositiontaking = b.autopositiontaking, autolivempositiontaking = b.autolivepositiontaking, isautompositiontaking = b.isautopositiontaking, isautolivempositiontaking = b.isautolivepositiontaking
	from custsetting3rd cs3 inner join 
			(
							select 81 as bettype, @auto_v161mpositiontaking_81 as autopositiontaking, 0				as autolivepositiontaking, @isauto_v161mpositiontaking_81 as isautopositiontaking, 0				as isautolivepositiontaking
				union all	select 83 as bettype, @auto_v161mpositiontaking_83 as autopositiontaking, 0				as autolivepositiontaking, @isauto_v161mpositiontaking_83 as isautopositiontaking, 0				as isautolivepositiontaking
				union all	select 85 as bettype,                            0 as autopositiontaking, @auto_v161mlivepositiontaking_85	as autolivepositiontaking,          0 as isautopositiontaking, @isauto_v161mlivepositiontaking_85	as isautolivepositiontaking
				union all	select 86 as bettype, @auto_v161mpositiontaking_86 as autopositiontaking, @auto_v161mlivepositiontaking_86	as autolivepositiontaking, @isauto_v161mpositiontaking_86 as isautopositiontaking, @isauto_v161mlivepositiontaking_86	as isautolivepositiontaking
				union all	select 87 as bettype,							 0 as autopositiontaking, @auto_v161mlivepositiontaking_87	as autolivepositiontaking,			0 as isautopositiontaking, @isauto_v161mlivepositiontaking_87	as isautolivepositiontaking
				union all	select 88 as bettype, @auto_v161mpositiontaking_88 as autopositiontaking, 0				as autolivepositiontaking, @isauto_v161mpositiontaking_88 as isautopositiontaking, 0				as isautolivepositiontaking
				union all	select 89 as bettype,							 0 as autopositiontaking, @auto_v161mlivepositiontaking_89	as autolivepositiontaking,			0 as isautopositiontaking, @isauto_v161mlivepositiontaking_89	as isautolivepositiontaking
				union all	select 90 as bettype,							 0 as autopositiontaking, @auto_v161mlivepositiontaking_90	as autolivepositiontaking,			0 as isautopositiontaking, @isauto_v161mlivepositiontaking_90	as isautolivepositiontaking
			) as b on b.bettype = cs3.bettype
	where cs3.custid = @recommend and cs3.sporttype=161
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
			case @Language 
				when 'E' then 'Error updating auto position taking (for Number Game)'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
			end	
			,  @ErrCode=302
		return
	END
END

EXEC dbo.Acc_CustSetting_05	
	@mrecommend = @mrecommend,
	@recommend = @recommend,
	@roleid = 2,
	@isauto_mpositiontaking_1 = @isauto_mpositiontaking_1, 
	@isauto_mpositiontaking_2 = @isauto_mpositiontaking_2, 
	@isauto_mpositiontaking_3 = @isauto_mpositiontaking_3, 
	@isauto_mpositiontaking_4 = @isauto_mpositiontaking_4, 
	@isauto_mpositiontaking_5 = @isauto_mpositiontaking_5, 
	@isauto_mpositiontaking_6 = @isauto_mpositiontaking_6, 
	@isauto_mpositiontaking_7 = @isauto_mpositiontaking_7, 
	@isauto_mpositiontaking_8 = @isauto_mpositiontaking_8, 
	@isauto_mpositiontaking_9 = @isauto_mpositiontaking_9, 
	@isauto_mpositiontaking_10 = @isauto_mpositiontaking_10, 
	@isauto_mpositiontaking_9999 = @isauto_mpositiontaking_9999, 
	@isauto_mlivepositiontaking_1 = @isauto_mlivepositiontaking_1, 
	@isauto_mlivepositiontaking_3 = @isauto_mlivepositiontaking_3, 
	@isauto_mlivepositiontaking_7 = @isauto_mlivepositiontaking_7, 
	@isauto_mlivepositiontaking_8 = @isauto_mlivepositiontaking_8, 
	
	@isauto_v2mpositiontaking_1 = @isauto_v2mpositiontaking_1,
	@isauto_v2mpositiontaking_2 = @isauto_v2mpositiontaking_2,
	@isauto_v2mpositiontaking_3 = @isauto_v2mpositiontaking_3,
	@isauto_v2mpositiontaking_7 = @isauto_v2mpositiontaking_7,
	@isauto_v2mpositiontaking_8 = @isauto_v2mpositiontaking_8,
	@isauto_v2mpositiontaking_20 = @isauto_v2mpositiontaking_20,
	
	@isauto_v3mpositiontaking_1 = @isauto_v3mpositiontaking_1,
	@isauto_v3mpositiontaking_2 = @isauto_v3mpositiontaking_2,
	@isauto_v3mpositiontaking_3 = @isauto_v3mpositiontaking_3,
	@isauto_v3mpositiontaking_20 = @isauto_v3mpositiontaking_20,
	
	@isauto_v5mpositiontaking_1 = @isauto_v5mpositiontaking_1,
	@isauto_v5mpositiontaking_2 = @isauto_v5mpositiontaking_2,
	@isauto_v5mpositiontaking_3 = @isauto_v5mpositiontaking_3,
	@isauto_v5mpositiontaking_20 = @isauto_v5mpositiontaking_20,
	@isauto_v5mpositiontaking_9999 = @isauto_v5mpositiontaking_9999,
	
	@isauto_v8mpositiontaking_1 = @isauto_v8mpositiontaking_1,
	@isauto_v8mpositiontaking_3 = @isauto_v8mpositiontaking_3,
	@isauto_v8mpositiontaking_20 = @isauto_v8mpositiontaking_20,

	@isauto_v10mpositiontaking_1 = @isauto_v10mpositiontaking_1,
	@isauto_v10mpositiontaking_2 = @isauto_v10mpositiontaking_2,
	@isauto_v10mpositiontaking_3 = @isauto_v10mpositiontaking_3,
	@isauto_v10mpositiontaking_20 = @isauto_v10mpositiontaking_20,

	@isauto_v11mpositiontaking_1 = @isauto_v11mpositiontaking_1,
	@isauto_v11mpositiontaking_20 = @isauto_v11mpositiontaking_20,

	@isauto_v99mpositiontaking_1 = @isauto_v99mpositiontaking_1,
	@isauto_v99mpositiontaking_2 = @isauto_v99mpositiontaking_2,
	@isauto_v99mpositiontaking_3 = @isauto_v99mpositiontaking_3,
	@isauto_v99mpositiontaking_20 = @isauto_v99mpositiontaking_20,

	-- mixed sports
	@isauto_v99mpositiontaking_9 = @isauto_v99mpositiontaking_9,
	@isauto_v154mpositiontaking_20 = @isauto_v154mpositiontaking_20,

	
	@old_isauto_mpositiontaking_1 = @old_isauto_mpositiontaking_1, 
	@old_isauto_mpositiontaking_2 = @old_isauto_mpositiontaking_2, 
	@old_isauto_mpositiontaking_3 = @old_isauto_mpositiontaking_3, 
	@old_isauto_mpositiontaking_4 = @old_isauto_mpositiontaking_4, 
	@old_isauto_mpositiontaking_5 = @old_isauto_mpositiontaking_5, 
	@old_isauto_mpositiontaking_6 = @old_isauto_mpositiontaking_6, 
	@old_isauto_mpositiontaking_7 = @old_isauto_mpositiontaking_7, 
	@old_isauto_mpositiontaking_8 = @old_isauto_mpositiontaking_8, 
	@old_isauto_mpositiontaking_9 = @old_isauto_mpositiontaking_9, 
	@old_isauto_mpositiontaking_10 = @old_isauto_mpositiontaking_10, 
	@old_isauto_mpositiontaking_9999 = @old_isauto_mpositiontaking_9999, 
	@old_isauto_mlivepositiontaking_1 = @old_isauto_mlivepositiontaking_1, 
	@old_isauto_mlivepositiontaking_3 = @old_isauto_mlivepositiontaking_3, 
	@old_isauto_mlivepositiontaking_7 = @old_isauto_mlivepositiontaking_7, 
	@old_isauto_mlivepositiontaking_8 = @old_isauto_mlivepositiontaking_8, 
	
	@old_isauto_v2mpositiontaking_1 = @old_isauto_v2mpositiontaking_1,
	@old_isauto_v2mpositiontaking_2 = @old_isauto_v2mpositiontaking_2,
	@old_isauto_v2mpositiontaking_3 = @old_isauto_v2mpositiontaking_3,
	@old_isauto_v2mpositiontaking_7 = @old_isauto_v2mpositiontaking_7,
	@old_isauto_v2mpositiontaking_8 = @old_isauto_v2mpositiontaking_8,
	@old_isauto_v2mpositiontaking_20 = @old_isauto_v2mpositiontaking_20,
	
	@old_isauto_v3mpositiontaking_1 = @old_isauto_v3mpositiontaking_1,
	@old_isauto_v3mpositiontaking_2 = @old_isauto_v3mpositiontaking_2,
	@old_isauto_v3mpositiontaking_3 = @old_isauto_v3mpositiontaking_3,
	@old_isauto_v3mpositiontaking_20 = @old_isauto_v3mpositiontaking_20,
	
	@old_isauto_v5mpositiontaking_1 = @old_isauto_v5mpositiontaking_1,
	@old_isauto_v5mpositiontaking_2 = @old_isauto_v5mpositiontaking_2,
	@old_isauto_v5mpositiontaking_3 = @old_isauto_v5mpositiontaking_3,
	@old_isauto_v5mpositiontaking_20 = @old_isauto_v5mpositiontaking_20,
	@old_isauto_v5mpositiontaking_9999 = @old_isauto_v5mpositiontaking_9999,
	
	@old_isauto_v8mpositiontaking_1 = @old_isauto_v8mpositiontaking_1,
	@old_isauto_v8mpositiontaking_3 = @old_isauto_v8mpositiontaking_3,
	@old_isauto_v8mpositiontaking_20 = @old_isauto_v8mpositiontaking_20,

	@old_isauto_v10mpositiontaking_1 = @old_isauto_v10mpositiontaking_1,
	@old_isauto_v10mpositiontaking_2 = @old_isauto_v10mpositiontaking_2,
	@old_isauto_v10mpositiontaking_3 = @old_isauto_v10mpositiontaking_3,
	@old_isauto_v10mpositiontaking_20 = @old_isauto_v10mpositiontaking_20,

	@old_isauto_v11mpositiontaking_1 = @old_isauto_v11mpositiontaking_1,
	@old_isauto_v11mpositiontaking_20 = @old_isauto_v11mpositiontaking_20,

	@old_isauto_v99mpositiontaking_1 = @old_isauto_v99mpositiontaking_1,
	@old_isauto_v99mpositiontaking_2 = @old_isauto_v99mpositiontaking_2,
	@old_isauto_v99mpositiontaking_3 = @old_isauto_v99mpositiontaking_3,
	@old_isauto_v99mpositiontaking_20 = @old_isauto_v99mpositiontaking_20,

	-- mixed sports
	@old_isauto_v99mpositiontaking_9 = @old_isauto_v99mpositiontaking_9,
	@old_isauto_v154mpositiontaking_20 = @old_isauto_v154mpositiontaking_20,
	
	@auto_mpositiontaking_1 = @auto_mpositiontaking_1, 
	@auto_mpositiontaking_2 = @auto_mpositiontaking_2,
	@auto_mpositiontaking_3 = @auto_mpositiontaking_3,
	@auto_mpositiontaking_4 = @auto_mpositiontaking_4,
	@auto_mpositiontaking_5 = @auto_mpositiontaking_5,
	@auto_mpositiontaking_6 = @auto_mpositiontaking_6,
	@auto_mpositiontaking_7 = @auto_mpositiontaking_7,
	@auto_mpositiontaking_8 = @auto_mpositiontaking_8,
	@auto_mpositiontaking_9 = @auto_mpositiontaking_9,
	@auto_mpositiontaking_10 = @auto_mpositiontaking_10,
	@auto_mpositiontaking_9999 = @auto_mpositiontaking_9999,
	@auto_mlivepositiontaking_1 = @auto_mlivepositiontaking_1,
	@auto_mlivepositiontaking_3 = @auto_mlivepositiontaking_3,
	@auto_mlivepositiontaking_7 = @auto_mlivepositiontaking_7,
	@auto_mlivepositiontaking_8 = @auto_mlivepositiontaking_8,
	
	@auto_v2mpositiontaking_1 = @auto_v2mpositiontaking_1,
	@auto_v2mpositiontaking_2 = @auto_v2mpositiontaking_2,
	@auto_v2mpositiontaking_3 = @auto_v2mpositiontaking_3,
	@auto_v2mpositiontaking_7 = @auto_v2mpositiontaking_7,
	@auto_v2mpositiontaking_8 = @auto_v2mpositiontaking_8,
--	@auto_v2mpositiontaking_9 = @auto_v2mpositiontaking_9,
	@auto_v2mpositiontaking_20 = @auto_v2mpositiontaking_20,
	
	@auto_v3mpositiontaking_1 = @auto_v3mpositiontaking_1,
	@auto_v3mpositiontaking_2 = @auto_v3mpositiontaking_2,
	@auto_v3mpositiontaking_3 = @auto_v3mpositiontaking_3,
	@auto_v3mpositiontaking_20 = @auto_v3mpositiontaking_20,

	@auto_v5mpositiontaking_1 = @auto_v5mpositiontaking_1,
	@auto_v5mpositiontaking_2 = @auto_v5mpositiontaking_2,
	@auto_v5mpositiontaking_3 = @auto_v5mpositiontaking_3,
	@auto_v5mpositiontaking_20 = @auto_v5mpositiontaking_20,
	@auto_v5mpositiontaking_9999 = @auto_v5mpositiontaking_9999,

	@auto_v8mpositiontaking_1 = @auto_v8mpositiontaking_1,
	@auto_v8mpositiontaking_3 = @auto_v8mpositiontaking_3,
	@auto_v8mpositiontaking_20 = @auto_v8mpositiontaking_20,

	@auto_v10mpositiontaking_1 = @auto_v10mpositiontaking_1,
	@auto_v10mpositiontaking_2 = @auto_v10mpositiontaking_2,
	@auto_v10mpositiontaking_3 = @auto_v10mpositiontaking_3,
	@auto_v10mpositiontaking_20 = @auto_v10mpositiontaking_20,

	@auto_v11mpositiontaking_1 = @auto_v11mpositiontaking_1,
	@auto_v11mpositiontaking_20 = @auto_v11mpositiontaking_20,
	@auto_v99mpositiontaking_1 = @auto_v99mpositiontaking_1,
	@auto_v99mpositiontaking_2 = @auto_v99mpositiontaking_2,
	@auto_v99mpositiontaking_3 = @auto_v99mpositiontaking_3,
	@auto_v99mpositiontaking_20 = @auto_v99mpositiontaking_20,
	
	--- mixed sports
	@auto_v99mpositiontaking_9 = @auto_v99mpositiontaking_9,
	@auto_v154mpositiontaking_20 = @auto_v154mpositiontaking_20,
	
	@old_auto_mpositiontaking_1 = @old_auto_mpositiontaking_1, 
	@old_auto_mpositiontaking_2 = @old_auto_mpositiontaking_2,
	@old_auto_mpositiontaking_3 = @old_auto_mpositiontaking_3,
	@old_auto_mpositiontaking_4 = @old_auto_mpositiontaking_4,
	@old_auto_mpositiontaking_5 = @old_auto_mpositiontaking_5,
	@old_auto_mpositiontaking_6 = @old_auto_mpositiontaking_6,
	@old_auto_mpositiontaking_7 = @old_auto_mpositiontaking_7,
	@old_auto_mpositiontaking_8 = @old_auto_mpositiontaking_8,
	@old_auto_mpositiontaking_9 = @old_auto_mpositiontaking_9,
	@old_auto_mpositiontaking_10 = @old_auto_mpositiontaking_10,
	@old_auto_mpositiontaking_9999 = @old_auto_mpositiontaking_9999,
	@old_auto_mlivepositiontaking_1 = @old_auto_mlivepositiontaking_1,
	@old_auto_mlivepositiontaking_3 = @old_auto_mlivepositiontaking_3,
	@old_auto_mlivepositiontaking_7 = @old_auto_mlivepositiontaking_7,
	@old_auto_mlivepositiontaking_8 = @old_auto_mlivepositiontaking_8,
	
	@old_auto_v2mpositiontaking_1 = @old_auto_v2mpositiontaking_1,
	@old_auto_v2mpositiontaking_2 = @old_auto_v2mpositiontaking_2,
	@old_auto_v2mpositiontaking_3 = @old_auto_v2mpositiontaking_3,
	@old_auto_v2mpositiontaking_7 = @old_auto_v2mpositiontaking_7,
	@old_auto_v2mpositiontaking_8 = @old_auto_v2mpositiontaking_8,
--	@old_auto_v2mpositiontaking_9 = @old_auto_v2mpositiontaking_9,
	@old_auto_v2mpositiontaking_20 = @old_auto_v2mpositiontaking_20,
	
	@old_auto_v3mpositiontaking_1 = @old_auto_v3mpositiontaking_1,
	@old_auto_v3mpositiontaking_2 = @old_auto_v3mpositiontaking_2,
	@old_auto_v3mpositiontaking_3 = @old_auto_v3mpositiontaking_3,
	@old_auto_v3mpositiontaking_20 = @old_auto_v3mpositiontaking_20,

	@old_auto_v5mpositiontaking_1 = @old_auto_v5mpositiontaking_1,
	@old_auto_v5mpositiontaking_2 = @old_auto_v5mpositiontaking_2,
	@old_auto_v5mpositiontaking_3 = @old_auto_v5mpositiontaking_3,
	@old_auto_v5mpositiontaking_20 = @old_auto_v5mpositiontaking_20,
	@old_auto_v5mpositiontaking_9999 = @old_auto_v5mpositiontaking_9999,

	@old_auto_v8mpositiontaking_1 = @old_auto_v8mpositiontaking_1,
	@old_auto_v8mpositiontaking_3 = @old_auto_v8mpositiontaking_3,
	@old_auto_v8mpositiontaking_20 = @old_auto_v8mpositiontaking_20,

	@old_auto_v10mpositiontaking_1 = @old_auto_v10mpositiontaking_1,
	@old_auto_v10mpositiontaking_2 = @old_auto_v10mpositiontaking_2,
	@old_auto_v10mpositiontaking_3 = @old_auto_v10mpositiontaking_3,
	@old_auto_v10mpositiontaking_20 = @old_auto_v10mpositiontaking_20,

	@old_auto_v11mpositiontaking_1 = @old_auto_v11mpositiontaking_1,
	@old_auto_v11mpositiontaking_20 = @old_auto_v11mpositiontaking_20,
	@old_auto_v99mpositiontaking_1 = @old_auto_v99mpositiontaking_1,
	@old_auto_v99mpositiontaking_2 = @old_auto_v99mpositiontaking_2,
	@old_auto_v99mpositiontaking_3 = @old_auto_v99mpositiontaking_3,
	@old_auto_v99mpositiontaking_20 = @old_auto_v99mpositiontaking_20,
	
	--- mixed sports
	@old_auto_v99mpositiontaking_9 = @old_auto_v99mpositiontaking_9,
	@old_auto_v154mpositiontaking_20 = @old_auto_v154mpositiontaking_20,
	
	@updatemultiple = @updatemultiple,
	@updatepositiontaking = @updatepositiontaking,
	
	@updatepositiontakingv2 = @updatepositiontakingv2,
	@updatepositiontakingv3 = @updatepositiontakingv3,
	@updatepositiontakingv5 = @updatepositiontakingv5,
	@updatepositiontakingv8 = @updatepositiontakingv8,
	@updatepositiontakingv10 = @updatepositiontakingv10,
	@updatepositiontakingv11 = @updatepositiontakingv11,
	@updatepositiontakingv99 = @updatepositiontakingv99,

	-- mixed sports
	@updatepositiontakingv99mp = @updatepositiontakingv99mp,
	@updatepositiontakingv154 = @updatepositiontakingv154,

	@updateallmembers = @updateallmembers,	
	@newmpositiontaking = @newmpositiontaking,
	
	-- Outright PT for sports
	@isauto_v2mpositiontaking_10 = @isauto_v2mpositiontaking_10, 
	@isauto_v3mpositiontaking_10 = @isauto_v3mpositiontaking_10, 
	@isauto_v5mpositiontaking_10 = @isauto_v5mpositiontaking_10, 
	@isauto_v8mpositiontaking_10 = @isauto_v8mpositiontaking_10, 
	@isauto_v10mpositiontaking_10 = @isauto_v10mpositiontaking_10, 
	@isauto_v11mpositiontaking_10 = @isauto_v11mpositiontaking_10, 
	@isauto_v99mpositiontaking_10 = @isauto_v99mpositiontaking_10, 
	
	@old_isauto_v2mpositiontaking_10 = @old_isauto_v2mpositiontaking_10, 
	@old_isauto_v3mpositiontaking_10 = @old_isauto_v3mpositiontaking_10, 
	@old_isauto_v5mpositiontaking_10 = @old_isauto_v5mpositiontaking_10, 
	@old_isauto_v8mpositiontaking_10 = @old_isauto_v8mpositiontaking_10, 
	@old_isauto_v10mpositiontaking_10 = @old_isauto_v10mpositiontaking_10, 
	@old_isauto_v11mpositiontaking_10 = @old_isauto_v11mpositiontaking_10, 
	@old_isauto_v99mpositiontaking_10 = @old_isauto_v99mpositiontaking_10, 
	
	@auto_v2mpositiontaking_10 = @auto_v2mpositiontaking_10,
	@auto_v3mpositiontaking_10 = @auto_v3mpositiontaking_10,
	@auto_v5mpositiontaking_10 = @auto_v5mpositiontaking_10,
	@auto_v8mpositiontaking_10 = @auto_v8mpositiontaking_10,
	@auto_v10mpositiontaking_10 = @auto_v10mpositiontaking_10,
	@auto_v11mpositiontaking_10 = @auto_v11mpositiontaking_10,
	@auto_v99mpositiontaking_10 = @auto_v99mpositiontaking_10,
	
	@old_auto_v2mpositiontaking_10 = @old_auto_v2mpositiontaking_10,
	@old_auto_v3mpositiontaking_10 = @old_auto_v3mpositiontaking_10,
	@old_auto_v5mpositiontaking_10 = @old_auto_v5mpositiontaking_10,
	@old_auto_v8mpositiontaking_10 = @old_auto_v8mpositiontaking_10,
	@old_auto_v10mpositiontaking_10 = @old_auto_v10mpositiontaking_10,
	@old_auto_v11mpositiontaking_10 = @old_auto_v11mpositiontaking_10,
	@old_auto_v99mpositiontaking_10 = @old_auto_v99mpositiontaking_10


EXEC dbo.Acc_CustSetting3rd_05	
	@mrecommend = @mrecommend,
	@recommend = @recommend,
	@roleid = 2,
	@mode = 'number',
	
	@isauto_v161mpositiontaking_81 = @isauto_v161mpositiontaking_81,
	@isauto_v161mpositiontaking_83 = @isauto_v161mpositiontaking_83,
	@isauto_v161mpositiontaking_86 = @isauto_v161mpositiontaking_86,
	@isauto_v161mpositiontaking_88 = @isauto_v161mpositiontaking_88,
	@isauto_v161mlivepositiontaking_85 = @isauto_v161mlivepositiontaking_85,
	@isauto_v161mlivepositiontaking_86 = @isauto_v161mlivepositiontaking_86,
	@isauto_v161mlivepositiontaking_87 = @isauto_v161mlivepositiontaking_87,
	@isauto_v161mlivepositiontaking_89 = @isauto_v161mlivepositiontaking_89,
	@isauto_v161mlivepositiontaking_90 = @isauto_v161mlivepositiontaking_90,
	
	@old_isauto_v161mpositiontaking_81 = @old_isauto_v161mpositiontaking_81,
	@old_isauto_v161mpositiontaking_83 = @old_isauto_v161mpositiontaking_83,
	@old_isauto_v161mpositiontaking_86 = @old_isauto_v161mpositiontaking_86,
	@old_isauto_v161mpositiontaking_88 = @old_isauto_v161mpositiontaking_88,
	@old_isauto_v161mlivepositiontaking_85 = @old_isauto_v161mlivepositiontaking_85,
	@old_isauto_v161mlivepositiontaking_86 = @old_isauto_v161mlivepositiontaking_86,
	@old_isauto_v161mlivepositiontaking_87 = @old_isauto_v161mlivepositiontaking_87,
	@old_isauto_v161mlivepositiontaking_89 = @old_isauto_v161mlivepositiontaking_89,
	@old_isauto_v161mlivepositiontaking_90 = @old_isauto_v161mlivepositiontaking_90,
	
	@auto_v161mpositiontaking_81 = @auto_v161mpositiontaking_81,
	@auto_v161mpositiontaking_83 = @auto_v161mpositiontaking_83,
	--@auto_v161mpositiontaking_85 = @auto_v161mpositiontaking_85,
	@auto_v161mpositiontaking_86 = @auto_v161mpositiontaking_86,
	@auto_v161mpositiontaking_88 = @auto_v161mpositiontaking_88,
	
	@auto_v161mlivepositiontaking_85 = @auto_v161mlivepositiontaking_85,
	@auto_v161mlivepositiontaking_86 = @auto_v161mlivepositiontaking_86,
	@auto_v161mlivepositiontaking_87 = @auto_v161mlivepositiontaking_87,
	@auto_v161mlivepositiontaking_89 = @auto_v161mlivepositiontaking_89,
	@auto_v161mlivepositiontaking_90 = @auto_v161mlivepositiontaking_90,
	
	@old_auto_v161mpositiontaking_81 = @old_auto_v161mpositiontaking_81,
	@old_auto_v161mpositiontaking_83 = @old_auto_v161mpositiontaking_83,
	--@old_auto_v161mpositiontaking_85 = @old_auto_v161mpositiontaking_85,
	@old_auto_v161mpositiontaking_86 = @old_auto_v161mpositiontaking_86,
	@old_auto_v161mpositiontaking_88 = @old_auto_v161mpositiontaking_88,
	
	@old_auto_v161mlivepositiontaking_85 = @old_auto_v161mlivepositiontaking_85,
	@old_auto_v161mlivepositiontaking_86 = @old_auto_v161mlivepositiontaking_86,
	@old_auto_v161mlivepositiontaking_87 = @old_auto_v161mlivepositiontaking_87,
	@old_auto_v161mlivepositiontaking_89 = @old_auto_v161mlivepositiontaking_89,
	@old_auto_v161mlivepositiontaking_90 = @old_auto_v161mlivepositiontaking_90,

	
	@updatepositiontakingv161 = @updatepositiontakingv161,
	@updateallmembers = @updateallmembers,
	@updatemultiple = @updatemultiple,	
	@newmpositiontaking = @newmpositiontaking
/*
	Declare CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_mpositiontaking_1  as isautopositiontaking	,	  @isauto_mlivepositiontaking_1 as isautolivepositiontaking	,	  @auto_mpositiontaking_1 as autopositiontaking	,	   @auto_mlivepositiontaking_1 as autolivepositiontaking	,	    @old_auto_mpositiontaking_1  as old_autopositiontaking	,	   @old_auto_mlivepositiontaking_1 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_1  as old_isautopositiontaking	 ,	   @old_isauto_mlivepositiontaking_1 as old_isautolivepositiontaking	,	   @isauto_v2mpositiontaking_1 as isautov2positiontaking	,	   @auto_v2mpositiontaking_1 as autov2positiontaking	,	   @old_auto_v2mpositiontaking_1 as old_autov2positiontaking	,	   @old_isauto_v2mpositiontaking_1 as old_isautov2positiontaking	,	@isauto_v3mpositiontaking_1 as isautov3positiontaking	,	   @auto_v3mpositiontaking_1 as autov3positiontaking	,	   @old_auto_v3mpositiontaking_1 as old_autov3positiontaking	,	   @old_isauto_v3mpositiontaking_1 as old_isautov3positiontaking	,	@isauto_v5mpositiontaking_1 as isautov5positiontaking	,	   @auto_v5mpositiontaking_1 as autov5positiontaking	,	   @old_auto_v5mpositiontaking_1 as old_autov5positiontaking	,	   @old_isauto_v5mpositiontaking_1 as old_isautov5positiontaking	,	@isauto_v8mpositiontaking_1 as isautov8positiontaking	,	   @auto_v8mpositiontaking_1 as autov8positiontaking	,	   @old_auto_v8mpositiontaking_1 as old_autov8positiontaking	,	   @old_isauto_v8mpositiontaking_1 as old_isautov8positiontaking	,	@isauto_v10mpositiontaking_1 as isautov10positiontaking	,	   @auto_v10mpositiontaking_1 as autov10positiontaking	,	   @old_auto_v10mpositiontaking_1 as old_autov10positiontaking	,	   @old_isauto_v10mpositiontaking_1 as old_isautov10positiontaking	,	@isauto_v11mpositiontaking_1 as isautov11positiontaking	,	   @auto_v11mpositiontaking_1 as autov11positiontaking	,	   @old_auto_v11mpositiontaking_1 as old_autov11positiontaking	,	   @old_isauto_v11mpositiontaking_1 as old_isautov11positiontaking	,	@isauto_v99mpositiontaking_1 as isautov99positiontaking	,	   @auto_v99mpositiontaking_1 as autov99positiontaking	,	   @old_auto_v99mpositiontaking_1 as old_autov99positiontaking	,	   @old_isauto_v99mpositiontaking_1 as old_isautov99positiontaking	,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 2 as bettype	,	   @isauto_mpositiontaking_2  as isautopositiontaking	,								  0 as isautolivepositiontaking	,	  @auto_mpositiontaking_2 as autopositiontaking	,							     0 as autolivepositiontaking	,		@old_auto_mpositiontaking_2  as old_autopositiontaking	,	   								 0 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_2  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,	   @isauto_v2mpositiontaking_2 as isautov2positiontaking	,	   @auto_v2mpositiontaking_2 as autov2positiontaking	,	   @old_auto_v2mpositiontaking_2 as old_autov2positiontaking	,	   @old_isauto_v2mpositiontaking_2 as old_isautov2positiontaking	,	@isauto_v3mpositiontaking_2 as isautov3positiontaking	,	   @auto_v3mpositiontaking_2 as autov3positiontaking	,	   @old_auto_v3mpositiontaking_2 as old_autov3positiontaking	,	   @old_isauto_v3mpositiontaking_2 as old_isautov3positiontaking	,	@isauto_v5mpositiontaking_2 as isautov5positiontaking	,	   @auto_v5mpositiontaking_2 as autov5positiontaking	,	   @old_auto_v5mpositiontaking_2 as old_autov5positiontaking	,	   @old_isauto_v5mpositiontaking_2 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,	@isauto_v10mpositiontaking_2 as isautov10positiontaking	,	   @auto_v10mpositiontaking_2 as autov10positiontaking	,	   @old_auto_v10mpositiontaking_2 as old_autov10positiontaking	,	   @old_isauto_v10mpositiontaking_2 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	@isauto_v99mpositiontaking_2 as isautov99positiontaking	,	   @auto_v99mpositiontaking_2 as autov99positiontaking	,	   @old_auto_v99mpositiontaking_2 as old_autov99positiontaking	,	   @old_isauto_v99mpositiontaking_2 as old_isautov99positiontaking	,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 3 as bettype	,	   @isauto_mpositiontaking_3  as isautopositiontaking	,	  @isauto_mlivepositiontaking_3 as isautolivepositiontaking	,	  @auto_mpositiontaking_3 as autopositiontaking	,	   @auto_mlivepositiontaking_3 as autolivepositiontaking	,		@old_auto_mpositiontaking_3  as old_autopositiontaking	,	   @old_auto_mlivepositiontaking_3 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_3  as old_isautopositiontaking	 ,	   @old_isauto_mlivepositiontaking_3 as old_isautolivepositiontaking	,	   @isauto_v2mpositiontaking_3 as isautov2positiontaking	,	   @auto_v2mpositiontaking_3 as autov2positiontaking	,	   @old_auto_v2mpositiontaking_3 as old_autov2positiontaking	,	   @old_isauto_v2mpositiontaking_3 as old_isautov2positiontaking	,	@isauto_v3mpositiontaking_3 as isautov3positiontaking	,	   @auto_v3mpositiontaking_3 as autov3positiontaking	,	   @old_auto_v3mpositiontaking_3 as old_autov3positiontaking	,	   @old_isauto_v3mpositiontaking_3 as old_isautov3positiontaking	,	@isauto_v5mpositiontaking_3 as isautov5positiontaking	,	   @auto_v5mpositiontaking_3 as autov5positiontaking	,	   @old_auto_v5mpositiontaking_3 as old_autov5positiontaking	,	   @old_isauto_v5mpositiontaking_3 as old_isautov5positiontaking	,	@isauto_v8mpositiontaking_3 as isautov8positiontaking	,	   @auto_v8mpositiontaking_3 as autov8positiontaking	,	   @old_auto_v8mpositiontaking_3 as old_autov8positiontaking	,	   @old_isauto_v8mpositiontaking_3 as old_isautov8positiontaking	,	@isauto_v10mpositiontaking_3 as isautov10positiontaking	,	   @auto_v10mpositiontaking_3 as autov10positiontaking	,	   @old_auto_v10mpositiontaking_3 as old_autov10positiontaking	,	   @old_isauto_v10mpositiontaking_3 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	@isauto_v99mpositiontaking_3 as isautov99positiontaking	,	   @auto_v99mpositiontaking_3 as autov99positiontaking	,	   @old_auto_v99mpositiontaking_3 as old_autov99positiontaking	,	   @old_isauto_v99mpositiontaking_3 as old_isautov99positiontaking	,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 4 as bettype	,	   @isauto_mpositiontaking_4  as isautopositiontaking	,								  0 as isautolivepositiontaking	,	  @auto_mpositiontaking_4 as autopositiontaking	,								 0 as autolivepositiontaking	,		@old_auto_mpositiontaking_4  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_4  as old_isautopositiontaking     ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,								    0 as old_autov2positiontaking	,									    0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									  0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 5 as bettype	,	   @isauto_mpositiontaking_5  as isautopositiontaking	,								  0 as isautolivepositiontaking	,	  @auto_mpositiontaking_5 as autopositiontaking	,								 0 as autolivepositiontaking	,		@old_auto_mpositiontaking_5  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_5  as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 6 as bettype	,	   @isauto_mpositiontaking_6  as isautopositiontaking	,								  0 as isautolivepositiontaking	,	  @auto_mpositiontaking_6 as autopositiontaking	,								 0 as autolivepositiontaking	,		@old_auto_mpositiontaking_6  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_6  as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 7 as bettype	,	   @isauto_mpositiontaking_7  as isautopositiontaking	,	  @isauto_mlivepositiontaking_7 as isautolivepositiontaking	,	  @auto_mpositiontaking_7 as autopositiontaking	,	   @auto_mlivepositiontaking_7 as autolivepositiontaking	,		@old_auto_mpositiontaking_7  as old_autopositiontaking	,	   @old_auto_mlivepositiontaking_7 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_7  as old_isautopositiontaking	 ,		@old_isauto_mlivepositiontaking_7 as old_isautolivepositiontaking	,	   @isauto_v2mpositiontaking_7 as isautov2positiontaking	,	   @auto_v2mpositiontaking_7 as autov2positiontaking	,	   @old_auto_v2mpositiontaking_7 as old_autov2positiontaking	,	   @old_isauto_v2mpositiontaking_7 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 8 as bettype	,	   @isauto_mpositiontaking_8  as isautopositiontaking	,	  @isauto_mlivepositiontaking_8 as isautolivepositiontaking	,	  @auto_mpositiontaking_8 as autopositiontaking	,	   @auto_mlivepositiontaking_8 as autolivepositiontaking	,		@old_auto_mpositiontaking_8  as old_autopositiontaking	,	   @old_auto_mlivepositiontaking_8 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_8  as old_isautopositiontaking	 ,	   @old_isauto_mlivepositiontaking_8 as old_isautolivepositiontaking	,	   @isauto_v2mpositiontaking_8 as isautov2positiontaking	,	   @auto_v2mpositiontaking_8 as autov2positiontaking	,	   @old_auto_v2mpositiontaking_8 as old_autov2positiontaking	,	   @old_isauto_v2mpositiontaking_8 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,							    0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 9 as bettype	,	   @isauto_mpositiontaking_9  as isautopositiontaking	,								  0 as isautolivepositiontaking	,	  @auto_mpositiontaking_9 as autopositiontaking	,								 0 as autolivepositiontaking	,		@old_auto_mpositiontaking_9  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_9  as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,  0 as isautov2positiontaking	,  0 as autov2positiontaking	,   0 as old_autov2positiontaking	,	 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,	@isauto_v99mpositiontaking_9  as isautov99mppositiontaking	,	 @auto_v99mpositiontaking_9 as autov99mppositiontaking	,	   @old_auto_v99mpositiontaking_9 as old_autov99mppositiontaking	,	     @old_isauto_v99mpositiontaking_9 as old_isautov99mppositiontaking	,								0 as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	
union all  	select 10 as bettype,	   @isauto_mpositiontaking_10 as isautopositiontaking	,								  0 as isautolivepositiontaking	,	  @auto_mpositiontaking_10 as autopositiontaking,								 0 as autolivepositiontaking	,		@old_auto_mpositiontaking_10 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	  @old_isauto_mpositiontaking_10 as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 20 as bettype,	   0 as isautopositiontaking							,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								   0 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,								   0 as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,	   @isauto_v2mpositiontaking_20 as isautov2positiontaking	,	   @auto_v2mpositiontaking_20 as autov2positiontaking	,	   @old_auto_v2mpositiontaking_20 as old_autov2positiontaking	,	   @old_isauto_v2mpositiontaking_20 as old_isautov2positiontaking	,	@isauto_v3mpositiontaking_20 as isautov3positiontaking	,	   @auto_v3mpositiontaking_20 as autov3positiontaking	,	   @old_auto_v3mpositiontaking_20 as old_autov3positiontaking	,	   @old_isauto_v3mpositiontaking_20 as old_isautov3positiontaking	,	@isauto_v5mpositiontaking_20 as isautov5positiontaking	,	   @auto_v5mpositiontaking_20 as autov5positiontaking	,	   @old_auto_v5mpositiontaking_20 as old_autov5positiontaking	,	  @old_isauto_v5mpositiontaking_20 as old_isautov5positiontaking	,    @isauto_v8mpositiontaking_20 as isautov8positiontaking	,		@auto_v8mpositiontaking_20 as autov8positiontaking	,		@old_auto_v8mpositiontaking_20 as old_autov8positiontaking	,	   @old_isauto_v8mpositiontaking_20 as old_isautov8positiontaking	,	@isauto_v10mpositiontaking_20 as isautov10positiontaking,	   @auto_v10mpositiontaking_20 as autov10positiontaking	,	   @old_auto_v10mpositiontaking_20 as old_autov10positiontaking	,	   @old_isauto_v10mpositiontaking_20 as old_isautov10positiontaking	,	@isauto_v11mpositiontaking_20 as isautov11positiontaking,	   @auto_v11mpositiontaking_20 as autov11positiontaking	,	   @old_auto_v11mpositiontaking_20 as old_autov11positiontaking	,	   @old_isauto_v11mpositiontaking_20 as old_isautov11positiontaking	,	@isauto_v99mpositiontaking_20 as isautov99positiontaking,	   @auto_v99mpositiontaking_20 as autov99positiontaking	,	   @old_auto_v99mpositiontaking_20 as old_autov99positiontaking	,	   @old_isauto_v99mpositiontaking_20 as old_isautov99positiontaking	,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,@isauto_v154mpositiontaking_20 as isautov154positiontaking	,@auto_v154mpositiontaking_20 as autov154positiontaking	,@old_auto_v154mpositiontaking_20 as old_autov154positiontaking	,@old_isauto_v154mpositiontaking_20 as old_isautov154positiontaking
union all  	select 21 as bettype,	   0 as isautopositiontaking							,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								   0 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,								   0 as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									 0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									  0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 22 as bettype,	   0 as isautopositiontaking							,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								   0 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,								   0 as old_isautopositiontaking     ,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,										0 as isautov161livepositiontaking	,							0 as autov161positiontaking	,										0 as autov161livepositiontaking	,									0  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,										0  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
--- number game ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
union all  	select 81 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,							     0 as autolivepositiontaking	,								0  as old_autopositiontaking	,	   								 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	@isauto_v161mpositiontaking_81 as isautov161positiontaking	,									0 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_81 as autov161positiontaking	,										0 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_81  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_81  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 83 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								0  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	@isauto_v161mpositiontaking_83 as isautov161positiontaking	,									0 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_83 as autov161positiontaking	,										0 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_83  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_83  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 85 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,							     0 as autolivepositiontaking	,								0  as old_autopositiontaking	,	   								 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	                             0 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_85 as isautov161livepositiontaking	,	                            0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_85 as autov161livepositiontaking	,	                                   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_85 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_85 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 86 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								0  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	@isauto_v161mpositiontaking_86 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_86 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_86 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_86 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_86  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_86 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_86  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_86 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 87 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								0  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,								0  as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_87 as isautov161livepositiontaking	,								0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_87 as autov161livepositiontaking	,									   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_87 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_87 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all 	select 88 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,								 0 as autolivepositiontaking	,								0  as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	@isauto_v161mpositiontaking_88 as isautov161positiontaking	,									0 as isautov161livepositiontaking	,	 @auto_v161mpositiontaking_88 as autov161positiontaking	,										0 as autov161livepositiontaking	,	    @old_auto_v161mpositiontaking_88  as old_autov161positiontaking	,											0 as old_autov161livepositiontaking	,	  @old_isauto_v161mpositiontaking_88  as old_isautov161positiontaking	 ,											0 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 89 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,							     0 as autolivepositiontaking	,								0  as old_autopositiontaking	,	   								 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	                             0 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_89 as isautov161livepositiontaking	,	                            0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_89 as autov161livepositiontaking	,	                                   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_89 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_89 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking
union all  	select 90 as bettype	,	   0					  as isautopositiontaking	,								  0 as isautolivepositiontaking	,							0 as autopositiontaking	,							     0 as autolivepositiontaking	,								0  as old_autopositiontaking	,	   								 0 as old_autolivepositiontaking	,									0  as old_isautopositiontaking	 ,									   0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									0 as old_autov2positiontaking	,										0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,										0 as old_isautov3positiontaking	,	0 as isautov5positiontaking								,	   0 as autov5positiontaking							,									0 as old_autov5positiontaking	,									 0 as old_isautov5positiontaking	,								0 as isautov8positiontaking	,								0 as autov8positiontaking	,									 0 as old_autov8positiontaking	,									0 as old_isautov8positiontaking		,							   0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									   0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									  0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,	   0 as autov99positiontaking							,									0 as old_autov99positiontaking	,	       0 as old_isautov99positiontaking								,								0 as isautov99mppositiontaking	,								0 as autov99mppositiontaking	,									0 as old_autov99mppositiontaking	,										0 as old_isautov99mppositiontaking	,	                             0 as isautov161positiontaking	,	 @isauto_v161mlivepositiontaking_90 as isautov161livepositiontaking	,	                            0 as autov161positiontaking	,	   @auto_v161mlivepositiontaking_90 as autov161livepositiontaking	,	                                   0  as old_autov161positiontaking	,	   @old_auto_v161mlivepositiontaking_90 as old_autov161livepositiontaking	,									   0  as old_isautov161positiontaking	 ,	   @old_isauto_v161mlivepositiontaking_90 as old_isautov161livepositiontaking	,0 as isautov154positiontaking								,0 as autov154positiontaking							,0 as old_autov154positiontaking								,0 as old_isautov154positiontaking

	OPEN CUR

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
		@isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking,
		@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking


	--Update use Auto_MPT at agent for all members only when:
	--(autoMPT at agent changes AND isauto at agent = 1
	--OR isauto at agent changes from 0 to 1)
	-- m1=min(m3-a1,u2)
	
	--Update a specific MPT for all members only when:
	--@updateallmembers = 1
	--AND isauto at agent = 0
	--AND isauto at agent change from 1 to 0
	--m1=min(m2,@newmpositiontaking)
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if (@autopositiontaking <> @old_autopositiontaking or @isautopositiontaking <> @old_isautopositiontaking) and (@updatepositiontaking = 1 or @updatemultiple=0)
		BEGIN
			if @isautopositiontaking >0 --auto PT is used
			BEGIN				
				-- m1=min(m3-a1,u2)				
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=1 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where
					c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1

				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Soccer)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end	
						,  @ErrCode=209
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautopositiontaking <> @old_isautopositiontaking  --auto PT is NOT used
			BEGIN
				if @updateallmembers = 1 -- Update All Member option is used
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 				
					if @@Error <> 0
					BEGIN
						 
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Soccer)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
							end	
						,  @ErrCode=210
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END
		---------------------------------
		--Update LIVE
		if @bettype in (1,3,7,8) and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking ) and (@updatepositiontaking = 1 or @updatemultiple=0)
		BEGIN
			if @isautolivepositiontaking >0 --Use AUTO_MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=1 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - alivepositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
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
						,  @ErrCode=211
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautolivepositiontaking <> @old_isautolivepositiontaking --Not use AUTO_PT
			BEGIN
				if @updateallmembers = 1--Update all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when acs.mlivepositiontaking<@newmpositiontaking then acs.mlivepositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=1 			
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
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
						,  @ErrCode=212
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END
		---------------------------------
		--Update Basketball
		if @bettype in (1,2,3,7,8,9,20) and (@autov2positiontaking <> @old_autov2positiontaking or @isautov2positiontaking <> @old_isautov2positiontaking ) and (@updatepositiontakingv2 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov2positiontaking >0
			BEGIN
				--update m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=2 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end	
						,  @ErrCode=213
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov2positiontaking <> @old_isautov2positiontaking -- Not use AUTO_PT
			BEGIN
				if @updateallmembers = 1 --Update all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=2 
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end	
							,  @ErrCode=214
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	
		
				---------------------------------
		--Update Football
		if @bettype in (1,2,3,20) and (@autov3positiontaking <> @old_autov3positiontaking or @isautov3positiontaking <> @old_isautov3positiontaking ) and (@updatepositiontakingv3 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov3positiontaking >0 --Use AUTO_MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=3 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end	
							,  @ErrCode=215
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov3positiontaking <> @old_isautov3positiontaking --Not use AUTO_MPT
			BEGIN
				if @updateallmembers = 1 --Update all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=3 
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end	
							,  @ErrCode=216
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	

		---------------------------------
		--Update Tennis
		if @bettype in (1,2,3,20) and (@autov5positiontaking <> @old_autov5positiontaking or @isautov5positiontaking <> @old_isautov5positiontaking ) and (@updatepositiontakingv5 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov5positiontaking >0
			BEGIN
				-- m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=5 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=5 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end	
							,  @ErrCode=217
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov5positiontaking <> @old_isautov5positiontaking
			BEGIN
				if @updateallmembers = 1--update all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=5
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end	
							,  @ErrCode=218
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	

		---------------------------------
		--Update Baseball
		if @bettype in (1,3,20) and (@autov8positiontaking <> @old_autov8positiontaking or @isautov8positiontaking <> @old_isautov8positiontaking ) and (@updatepositiontakingv8 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov8positiontaking >0--Use AUTO MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=8 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=8 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end	
							,  @ErrCode=219
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov8positiontaking <> @old_isautov8positiontaking -- Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1--All member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=8 and custsetting.isautopositiontaking=0
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end	
							,  @ErrCode=220
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	

		---------------------------------
		--Update Golf
		if @bettype in (1,2,3,20) and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking ) and (@updatepositiontakingv10 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov10positiontaking >0 --Use AUTO MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=10 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end	
							,  @ErrCode=221
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov10positiontaking <> @old_isautov10positiontaking --Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 -- all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=10 
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end	
							,  @ErrCode=222
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	

		---------------------------------
		--Update Motorsports
		if @bettype in (1,20) and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking ) and (@updatepositiontakingv11 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov11positiontaking >0 --Use AUTO MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=11 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end	
							,  @ErrCode=223
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov11positiontaking <> @old_isautov11positiontaking -- Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 -- all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=11 
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end	
							,  @ErrCode=224
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	
		---------------------------------
		--Update Other sports
		if @bettype in (1,2,3,20) and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking ) and (@updatepositiontakingv99 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov99positiontaking >0 --Use AUTO MPT
			BEGIN 
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=99 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
							,  @ErrCode=225
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov99positiontaking <> @old_isautov99positiontaking --Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 --All member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
							,  @ErrCode=226
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END			
		
		---------------------------------
		--Update Mixed sports		
		if @bettype =9 and (@autov99mppositiontaking <> @old_autov99mppositiontaking or @isautov99mppositiontaking <> @old_isautov99mppositiontaking ) and (@updatepositiontakingv99mp = 1 or @updatemultiple=0)
		BEGIN
			if @isautov99mppositiontaking >0 --Use AUTO MPT
			BEGIN 
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=99 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
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
							,  @ErrCode=303
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov99mppositiontaking <> @old_isautov99mppositiontaking --Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 --All member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=99
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
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
							,  @ErrCode=304
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END			
		---------------------------------
		--Update HR Fixed Odds
		if @bettype in (20) and (@autov154positiontaking <> @old_autov154positiontaking or @isautov154positiontaking <> @old_isautov154positiontaking ) and (@updatepositiontakingv154 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov154positiontaking >0 --Use AUTO MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and sporttype=154 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov154positiontaking then @autov154positiontaking else @maxpos - apositiontaking end
				from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=154
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end	
							,  @ErrCode=223
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov154positiontaking <> @old_isautov154positiontaking -- Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 -- all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update custsetting with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs.mpositiontaking<@newmpositiontaking then acs.mpositiontaking else @newmpositiontaking end
					from custsetting inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
					inner join custsetting as acs with (NOLOCK) on acs.custid = @recommend and custsetting.sporttype=acs.sporttype and custsetting.bettype=acs.bettype
					where c.recommend = @recommend and c.roleid = 1 and custsetting.bettype = @bettype and custsetting.sporttype=154
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
							end	
							,  @ErrCode=224
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END	
		---------------------------------
		--Update Number game
		if @bettype in (81,83,86,88) and (@autov161positiontaking <> @old_autov161positiontaking or @isautov161positiontaking <> @old_isautov161positiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov161positiontaking >0 --Use AUTO MPT
			BEGIN 				
				--m1=min(m3-a1,u2)
				select @maxpos = mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
				update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - apositiontaking end
				from custsetting3rd cs3  inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161

				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end	
							,  @ErrCode=305
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov161positiontaking <> @old_isautov161positiontaking --Not use AUTO MPT
			BEGIN
				if @updateallmembers = 1 --All member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update cs3 with (ROWLOCK, UPDLOCK) set mpositiontaking = case when acs3.mpositiontaking<@newmpositiontaking then acs3.mpositiontaking else @newmpositiontaking end
					from custsetting3rd  cs3 inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
					inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = @recommend and cs3.sporttype=acs3.sporttype and cs3.bettype=acs3.bettype
					where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end	
							,  @ErrCode=306
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END		
	
		--Update number game LIVE
		if @bettype in (85,86,87,89,90) and (@autov161livepositiontaking <> @old_autov161livepositiontaking or @isautov161livepositiontaking <> @old_isautov161livepositiontaking ) and (@updatepositiontakingv161 = 1 or @updatemultiple=0)
		BEGIN
			if @isautov161livepositiontaking >0 --Use AUTO_MPT
			BEGIN
				--m1=min(m3-a1,u2)
				select @maxpos = mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=161 and bettype = @bettype
				update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when @maxpos - alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - alivepositiontaking end
				from custsetting3rd cs3 inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
				where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
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
						,  @ErrCode=307
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
			else if @isautov161livepositiontaking <> @old_isautov161livepositiontaking --Not use AUTO_PT
			BEGIN
				if @updateallmembers = 1--Update all member
				BEGIN
					--m1=min(m2,@newmpositiontaking)
					update cs3 with (ROWLOCK, UPDLOCK) set mlivepositiontaking = case when acs3.mlivepositiontaking<@newmpositiontaking then acs3.mlivepositiontaking else @newmpositiontaking end
					from custsetting3rd cs3 inner join custinfo as c with (NOLOCK) on cs3.custid = c.custid
					inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = @recommend and cs3.sporttype=acs3.sporttype and cs3.bettype=acs3.bettype
					where c.recommend = @recommend and c.roleid = 1 and cs3.bettype = @bettype and cs3.sporttype=161 			
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
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
						,  @ErrCode=308
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END
		-------------
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
			@isautov154positiontaking, @autov154positiontaking, @old_autov154positiontaking, @old_isautov154positiontaking,
			@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking


	END

	CLOSE CUR
	DEALLOCATE CUR
--END
*/


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_AutoPositiontaking] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_AutoPositiontaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_AutoPositiontaking] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgent_AutoPositiontaking] TO [vnteam] AS [dbo]