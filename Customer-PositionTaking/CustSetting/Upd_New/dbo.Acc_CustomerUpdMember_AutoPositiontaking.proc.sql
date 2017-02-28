ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_AutoPositiontaking]
	@custid int,
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
	
	-- HR Fixed Odds
	@auto_v154spositiontaking_20 SMALLMONEY = 0,
	
	-- number game
	@auto_v161spositiontaking_81 smallmoney = 0,
	@auto_v161spositiontaking_83 smallmoney = 0,
	@auto_v161spositiontaking_86 smallmoney = 0,
	@auto_v161spositiontaking_88 smallmoney = 0,
	@auto_v161slivepositiontaking_85 smallmoney = 0,
	@auto_v161slivepositiontaking_86 smallmoney = 0,
	@auto_v161slivepositiontaking_87 smallmoney = 0,
	@auto_v161slivepositiontaking_89 smallmoney = 0,
	@auto_v161slivepositiontaking_90 smallmoney = 0,

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
	
	-- HR Fixed Odds
	@isauto_v154spositiontaking_20 BIT = 0,
	-- number game
	@isauto_v161spositiontaking_81 bit = 0,
	@isauto_v161spositiontaking_83 bit = 0,
	@isauto_v161spositiontaking_86 bit = 0,
	@isauto_v161spositiontaking_88 bit = 0,
	@isauto_v161slivepositiontaking_85 bit = 0,
	@isauto_v161slivepositiontaking_86 bit = 0,
	@isauto_v161slivepositiontaking_87 bit = 0,
	@isauto_v161slivepositiontaking_89 bit = 0,
	@isauto_v161slivepositiontaking_90 bit = 0,

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
	@UpdatePositiontakingv161 BIT = 1,

	@language varchar(2) = 'E',
	@userid int
AS
--@Source Control
/*
Created: 20080515@Thien
Task : Update auto PT at member level
DB: DBTRANS.bodb02
Original:Acc_CustomerUpdAutoPositiontaking_Member

Revisions:
    - 20081023@Phuc: Add new sporttype 201, bettype 3 
    - 20090122@PhuongBich: add new sporttype 201, bettype 2.
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
    - 20090526@Phuc: remove write log.
	- 20100909@Lukas:	- Add mixed sports setting
						- Add number game setting
						- Remove mix parlay of basketball
	- 20110802@Lukas: (Number Game)
			- Add more bettypes: Warrior, Next Combo, Number Group
			- Remove Dead ball Over/Under
	- 20111223@Tom: Add parameter @UpdatePositiontaking_xxx to check multiple edit PT.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20131014@Kathy: - Add HR Fixed Odds (154) [Redmine:#6505]
		
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/



SET NOCOUNT ON
Declare @ErrMsg nvarchar(2000)
Declare @bettype int,
	@autopositiontaking smallmoney, 	
	@isautopositiontaking bit,	
	@old_autopositiontaking smallmoney,
	@old_isautopositiontaking smallmoney,
	
	@autolivepositiontaking smallmoney,
	@isautolivepositiontaking bit,	
	@old_autolivepositiontaking smallmoney,
	@old_isautolivepositiontaking smallmoney,
	
	@maxpos smallmoney,	
	
	@autov2positiontaking smallmoney,
	@isautov2positiontaking bit, 
	@old_autov2positiontaking smallmoney,
	@old_isautov2positiontaking smallmoney,

	@autov3positiontaking smallmoney,
	@isautov3positiontaking bit, 
	@old_autov3positiontaking smallmoney,
	@old_isautov3positiontaking smallmoney,

	@autov5positiontaking smallmoney,
	@isautov5positiontaking bit, 
	@old_autov5positiontaking smallmoney,
	@old_isautov5positiontaking smallmoney,

	@autov8positiontaking smallmoney,
	@isautov8positiontaking bit, 
	@old_autov8positiontaking smallmoney,
	@old_isautov8positiontaking smallmoney,

	@autov10positiontaking smallmoney,
	@isautov10positiontaking bit, 
	@old_autov10positiontaking smallmoney,
	@old_isautov10positiontaking smallmoney,

	@autov11positiontaking smallmoney,
	@isautov11positiontaking bit, 
	@old_autov11positiontaking smallmoney,
	@old_isautov11positiontaking smallmoney,

	@autov99positiontaking smallmoney,
	@isautov99positiontaking bit, 
	@old_autov99positiontaking smallmoney,
	@old_isautov99positiontaking smallmoney,

	-- mixed sports
	@autov99mppositiontaking smallmoney,
	@isautov99mppositiontaking bit,
	@old_autov99mppositiontaking smallmoney,
	@old_isautov99mppositiontaking smallmoney,
	
	-- HR Fixed Odds
	@autov154mpositiontaking SMALLMONEY,
	@isautov154mpositiontaking BIT,
	@old_autov154positiontaking SMALLMONEY,
	@old_isautov154positiontaking BIT,

	-- number game
	@autov161positiontaking smallmoney,
	@isautov161positiontaking bit,
	@old_autov161positiontaking smallmoney,
	@old_isautov161positiontaking smallmoney,
	
	@autov161livepositiontaking smallmoney,
	@isautov161livepositiontaking bit,	
	@old_autov161livepositiontaking smallmoney,
	@old_isautov161livepositiontaking smallmoney,

	@srecommend int,
	@mrecommend int
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

	-- HR Fixed Odds
	@old_auto_v154spositiontaking_20 SMALLMONEY,
	
	-- number game
	@old_auto_v161spositiontaking_81 smallmoney,
	@old_auto_v161spositiontaking_83 smallmoney,
	@old_auto_v161spositiontaking_86 smallmoney,
	@old_auto_v161spositiontaking_88 smallmoney,
	@old_auto_v161slivepositiontaking_85 smallmoney,
	@old_auto_v161slivepositiontaking_86 smallmoney,
	@old_auto_v161slivepositiontaking_87 smallmoney,
	@old_auto_v161slivepositiontaking_89 smallmoney,
	@old_auto_v161slivepositiontaking_90 smallmoney,

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
	
	-- HR Fixed Odds
	@old_isauto_v154spositiontaking_20 BIT,
	
	-- number game
	@old_isauto_v161spositiontaking_81 bit,
	@old_isauto_v161spositiontaking_83 bit,
	@old_isauto_v161spositiontaking_86 bit,
	@old_isauto_v161spositiontaking_88 bit,
	@old_isauto_v161slivepositiontaking_85 bit,
	@old_isauto_v161slivepositiontaking_86 bit,
	@old_isauto_v161slivepositiontaking_87 bit,
	@old_isauto_v161slivepositiontaking_89 bit,
	@old_isauto_v161slivepositiontaking_90 bit,
	

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
	
	-- HR Fixed Odds
	@master_auto_v154spositiontaking_20 SMALLMONEY,

	-- number game
	@master_auto_v161spositiontaking_81 smallmoney,
	@master_auto_v161spositiontaking_83 smallmoney,
	@master_auto_v161spositiontaking_86 smallmoney,
	@master_auto_v161spositiontaking_88 smallmoney,
	@master_auto_v161slivepositiontaking_85 smallmoney,
	@master_auto_v161slivepositiontaking_86 smallmoney,
	@master_auto_v161slivepositiontaking_87 smallmoney,
	@master_auto_v161slivepositiontaking_89 smallmoney,
	@master_auto_v161slivepositiontaking_90 smallmoney,

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
	
	-- HR Fixed Odds
	@master_isauto_v154spositiontaking_20 BIT,
	
	-- number game
	@master_isauto_v161spositiontaking_81 bit,
	@master_isauto_v161spositiontaking_83 bit,
	@master_isauto_v161spositiontaking_86 bit,
	@master_isauto_v161spositiontaking_88 bit,
	@master_isauto_v161slivepositiontaking_85 bit,
	@master_isauto_v161slivepositiontaking_86 bit,
	@master_isauto_v161slivepositiontaking_87 bit,
	@master_isauto_v161slivepositiontaking_89 bit,
	@master_isauto_v161slivepositiontaking_90 bit

--------------------------------------------------------
select @srecommend = srecommend, @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
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
			select 	@old_auto_v2spositiontaking_20	=	autopositiontaking		,	@old_isauto_v2spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=2	and bettype=20
		END  --UpdatePositiontakingv2 

if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
		BEGIN --UpdatePositiontakingv3 
			select 	@old_auto_v3spositiontaking_1	=	autopositiontaking		,	@old_isauto_v3spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=1
			select 	@old_auto_v3spositiontaking_2	=	autopositiontaking		,	@old_isauto_v3spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=2
			select 	@old_auto_v3spositiontaking_3	=	autopositiontaking		,	@old_isauto_v3spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=3
			select 	@old_auto_v3spositiontaking_20	=	autopositiontaking		,	@old_isauto_v3spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=3	and bettype=20
		END  --UpdatePositiontakingv3

if (@UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1)
		BEGIN --UpdatePositiontakingv5 
			select 	@old_auto_v5spositiontaking_1	=	autopositiontaking		,	@old_isauto_v5spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=1
			select 	@old_auto_v5spositiontaking_2	=	autopositiontaking		,	@old_isauto_v5spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=2
			select 	@old_auto_v5spositiontaking_3	=	autopositiontaking		,	@old_isauto_v5spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=3
			select 	@old_auto_v5spositiontaking_20	=	autopositiontaking		,	@old_isauto_v5spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=5	and bettype=20
		END  --UpdatePositiontakingv5

if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1)
		BEGIN --UpdatePositiontakingv8 
			select 	@old_auto_v8spositiontaking_1	=	autopositiontaking		,	@old_isauto_v8spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=1
			select 	@old_auto_v8spositiontaking_3	=	autopositiontaking		,	@old_isauto_v8spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=3
			select 	@old_auto_v8spositiontaking_20	=	autopositiontaking		,	@old_isauto_v8spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=8	and bettype=20
		END  --UpdatePositiontakingv8

if (@UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1)
		BEGIN --UpdatePositiontakingv10 
			select 	@old_auto_v10spositiontaking_1	=	autopositiontaking		,	@old_isauto_v10spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=1
			select 	@old_auto_v10spositiontaking_2	=	autopositiontaking		,	@old_isauto_v10spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=2
			select 	@old_auto_v10spositiontaking_3	=	autopositiontaking		,	@old_isauto_v10spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=3
			select 	@old_auto_v10spositiontaking_20	=	autopositiontaking		,	@old_isauto_v10spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=10	and bettype=20
		END  --UpdatePositiontakingv10

if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
		BEGIN --UpdatePositiontakingv11 
			select 	@old_auto_v11spositiontaking_1	=	autopositiontaking		,	@old_isauto_v11spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=1
			select 	@old_auto_v11spositiontaking_20	=	autopositiontaking		,	@old_isauto_v11spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=11	and bettype=20
		END  --UpdatePositiontakingv11

if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1)
		BEGIN --UpdatePositiontakingv99 
			select 	@old_auto_v99spositiontaking_1	=	autopositiontaking		,	@old_isauto_v99spositiontaking_1	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=1
			select 	@old_auto_v99spositiontaking_2	=	autopositiontaking		,	@old_isauto_v99spositiontaking_2	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=2
			select 	@old_auto_v99spositiontaking_3	=	autopositiontaking		,	@old_isauto_v99spositiontaking_3	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=3
			select 	@old_auto_v99spositiontaking_20	=	autopositiontaking		,	@old_isauto_v99spositiontaking_20	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=20
		END  --UpdatePositiontakingv99

if (@UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1)
		BEGIN --UpdatePositiontakingv99MP 
-- mixed 
			select 	@old_auto_v99spositiontaking_9	=	autopositiontaking		,	@old_isauto_v99spositiontaking_9	=	isautopositiontaking		from custsetting with (nolock) where custid = @custid and sporttype=99	and bettype=9
		END  --UpdatePositiontakingv99MP
		
IF(@UpdateMultiple = 0 OR @UpdatePositiontakingv154 = 1 )
BEGIN -- UpdatePositiontakingv154
	SELECT @old_auto_v154spositiontaking_20 = cs.autopositiontaking,
			@old_isauto_v154spositiontaking_20 = cs.isautopositiontaking 
	FROM custSetting cs WITH (NOLOCK)
	WHERE cs.custid = @custid
	AND cs.sporttype = 154
	AND cs.bettype = 20
END -- UpdatePositiontakingv154

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
--------------------------------------------------------

--------------------------------------------------------
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
		END  --UpdatePositiontaking

if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
		BEGIN --UpdatePositiontakingv2
			select @master_auto_v2spositiontaking_1 = autopositiontaking, @master_isauto_v2spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
			select @master_auto_v2spositiontaking_2 = autopositiontaking, @master_isauto_v2spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
			select @master_auto_v2spositiontaking_3 = autopositiontaking, @master_isauto_v2spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
			select @master_auto_v2spositiontaking_7 = autopositiontaking, @master_isauto_v2spositiontaking_7 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
			select @master_auto_v2spositiontaking_8 = autopositiontaking, @master_isauto_v2spositiontaking_8 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
			--select @master_auto_v2spositiontaking_9 = autopositiontaking, @master_isauto_v2spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
			select @master_auto_v2spositiontaking_20 = autopositiontaking, @master_isauto_v2spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2
		END  --UpdatePositiontakingv2

if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
		BEGIN --UpdatePositiontakingv3
			select @master_auto_v3spositiontaking_1 = autopositiontaking, @master_isauto_v3spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=3
			select @master_auto_v3spositiontaking_2 = autopositiontaking, @master_isauto_v3spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=3
			select @master_auto_v3spositiontaking_3 = autopositiontaking, @master_isauto_v3spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=3
			select @master_auto_v3spositiontaking_20 = autopositiontaking, @master_isauto_v3spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=3
		END  --UpdatePositiontakingv3

if (@UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1)
		BEGIN --UpdatePositiontakingv5
			select @master_auto_v5spositiontaking_1 = autopositiontaking, @master_isauto_v5spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=5
			select @master_auto_v5spositiontaking_2 = autopositiontaking, @master_isauto_v5spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=5
			select @master_auto_v5spositiontaking_3 = autopositiontaking, @master_isauto_v5spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=5
			select @master_auto_v5spositiontaking_20 = autopositiontaking, @master_isauto_v5spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=5
		END  --UpdatePositiontakingv5

if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1)
		BEGIN --UpdatePositiontakingv8
			select @master_auto_v8spositiontaking_1 = autopositiontaking, @master_isauto_v8spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=8
			select @master_auto_v8spositiontaking_3 = autopositiontaking, @master_isauto_v8spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=8
			select @master_auto_v8spositiontaking_20 = autopositiontaking, @master_isauto_v8spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=8
		END  --UpdatePositiontakingv8

if (@UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1)
		BEGIN --UpdatePositiontakingv10
			select @master_auto_v10spositiontaking_1 = autopositiontaking, @master_isauto_v10spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
			select @master_auto_v10spositiontaking_2 = autopositiontaking, @master_isauto_v10spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
			select @master_auto_v10spositiontaking_3 = autopositiontaking, @master_isauto_v10spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
			select @master_auto_v10spositiontaking_20 = autopositiontaking, @master_isauto_v10spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10
		END  --UpdatePositiontakingv10

if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
		BEGIN --UpdatePositiontakingv11
			select @master_auto_v11spositiontaking_1 = autopositiontaking, @master_isauto_v11spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
			select @master_auto_v11spositiontaking_20 = autopositiontaking, @master_isauto_v11spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11
		END  --UpdatePositiontakingv11

if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1)
		BEGIN --UpdatePositiontakingv99
			select @master_auto_v99spositiontaking_1 = autopositiontaking, @master_isauto_v99spositiontaking_1 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
			select @master_auto_v99spositiontaking_2 = autopositiontaking, @master_isauto_v99spositiontaking_2 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
			select @master_auto_v99spositiontaking_3 = autopositiontaking, @master_isauto_v99spositiontaking_3 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
			select @master_auto_v99spositiontaking_20 = autopositiontaking, @master_isauto_v99spositiontaking_20 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99
		END  --UpdatePositiontakingv99

-- mixed sports
if (@UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1)
		BEGIN --UpdatePositiontakingv99MP
			select @master_auto_v99spositiontaking_9 = autopositiontaking, @master_isauto_v99spositiontaking_9 = isautopositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=99
		END  --UpdatePositiontakingv99MP

-- HR Fixed Odds
IF (@UpdateMultiple = 0 OR @UpdatePositiontakingv154 = 1)
BEGIN
	SELECT @master_auto_v154spositiontaking_20 = cs.autopositiontaking,
		@master_isauto_v154spositiontaking_20 = cs.isautopositiontaking
	FROM custSetting cs WITH (NOLOCK) 
	WHERE cs.custid = @mrecommend
	AND cs.bettype = 20
	AND cs.sporttype = 154
END

--number game
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
--------------------------------------------------------

	--Update Member account (autopositiontaking field)
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
			
				-- HR Fixed Odds
				UNION ALL 
				SELECT 20 AS bettype, 154 AS sporttype, @auto_v154spositiontaking_20 AS autopositiontaking, 0 AS autolivepositiontaking, 
				@isauto_v154spositiontaking_20 AS isautopositiontaking, 0 AS isautolivepositiontaking 
				WHERE @UpdateMultiple = 0 OR @UpdatePositiontakingv154 = 1
				
			) as b on b.bettype = custsetting.bettype and b.sporttype = custsetting.sporttype
	where custsetting.custid = @custid
	
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking'
			ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
		end	
		RaisError (@ErrMsg, 16, 1)
		return
	END
	

	--Update Member account (autopositiontaking field) - Number game
if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
Begin --@UpdatePositiontakingv161
	update cs3 with (ROWLOCK, UPDLOCK) set autopositiontaking = b.autopositiontaking, autolivepositiontaking = b.autolivepositiontaking, isautopositiontaking = b.isautopositiontaking, isautolivepositiontaking = b.isautolivepositiontaking
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
	if @@Error <> 0
	BEGIN
		
		SELECT @ErrMsg =  
		case @Language 
			when 'E' then 'Error updating auto position taking'
			ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
		end	
		RaisError (@ErrMsg, 16, 1)
		return
	END
END --@UpdatePositiontakingv161
	---------------------------------------------------------------------------------------------------------------------------------------------
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
		
		-- HR Fixed Odds
		@auto_v154spositiontaking_20 = CASE WHEN @isauto_v154spositiontaking_20 > 0 THEN @auto_v154spositiontaking_20 ELSE @master_auto_v154spositiontaking_20 END,
		
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
		
		-- HR Fixed Odds
		@isauto_v154spositiontaking_20 = CASE WHEN @isauto_v154spositiontaking_20 > 0 THEN @isauto_v154spositiontaking_20 
		ELSE @master_isauto_v154spositiontaking_20 END,
		
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

	---------------------------------------------------------------------------------------------------------------------------------------------

	--Update member account
	--Using Cursor (spositiontaking field)
	DECLARE CUR CURSOR FOR 
			select 1 as bettype	,	   @isauto_spositiontaking_1 as isautopositiontaking	,	  @isauto_slivepositiontaking_1 as isautolivepositiontaking	,	  @auto_spositiontaking_1 as autopositiontaking	,	   @auto_slivepositiontaking_1 as autolivepositiontaking	,	  @old_auto_spositiontaking_1 as old_autopositiontaking	    ,	   @old_auto_slivepositiontaking_1 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_1 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_1 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_1 as isautov2positiontaking	,	   @auto_v2spositiontaking_1 as autov2positiontaking	,	   @old_auto_v2spositiontaking_1 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_1 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_1 as isautov3positiontaking	,	   @auto_v3spositiontaking_1 as autov3positiontaking	,	   @old_auto_v3spositiontaking_1 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_1 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_1 as isautov5positiontaking	,	   @auto_v5spositiontaking_1 as autov5positiontaking	,	   @old_auto_v5spositiontaking_1 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_1 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_1 as isautov8positiontaking	,	   @auto_v8spositiontaking_1 as autov8positiontaking	,	   @old_auto_v8spositiontaking_1 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_1 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_1 as isautov10positiontaking	,	   @auto_v10spositiontaking_1 as autov10positiontaking	,	   @old_auto_v10spositiontaking_1 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_1 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_1 as isautov11positiontaking	,	   @auto_v11spositiontaking_1 as autov11positiontaking	,	   @old_auto_v11spositiontaking_1 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_1 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_1 as isautov99positiontaking	,		@auto_v99spositiontaking_1 as autov99positiontaking	,	   @old_auto_v99spositiontaking_1 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_1 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking		, 0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,			
			0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking

UNION ALL  	select 2 as bettype	,	   @isauto_spositiontaking_2 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_2 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_2 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_2 as old_isautopositiontaking    	,										0 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_2 as isautov2positiontaking	,	   @auto_v2spositiontaking_2 as autov2positiontaking	,	     @old_auto_v2spositiontaking_2 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_2 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_2 as isautov3positiontaking	,	   @auto_v3spositiontaking_2 as autov3positiontaking	,	   @old_auto_v3spositiontaking_2 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_2 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_2 as isautov5positiontaking	,	   @auto_v5spositiontaking_2 as autov5positiontaking	,	   @old_auto_v5spositiontaking_2 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_2 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_2 as isautov10positiontaking	,	   @auto_v10spositiontaking_2 as autov10positiontaking	,	   @old_auto_v10spositiontaking_2 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_2 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_2 as isautov99positiontaking	,		@auto_v99spositiontaking_2 as autov99positiontaking	,	   @old_auto_v99spositiontaking_2 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_2 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking	,							0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
 0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL 	select 3 as bettype	,	   @isauto_spositiontaking_3 as isautopositiontaking	,	  @isauto_slivepositiontaking_3 as isautolivepositiontaking	,	  @auto_spositiontaking_3 as autopositiontaking	,	   @auto_slivepositiontaking_3 as autolivepositiontaking	,		@old_auto_spositiontaking_3 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_3 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_3 as old_isautopositiontaking	    ,		@old_isauto_slivepositiontaking_3 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_3 as isautov2positiontaking	,	   @auto_v2spositiontaking_3 as autov2positiontaking	,	   @old_auto_v2spositiontaking_3 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_3 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_3 as isautov3positiontaking	,	   @auto_v3spositiontaking_3 as autov3positiontaking	,	   @old_auto_v3spositiontaking_3 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_3 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_3 as isautov5positiontaking	,	   @auto_v5spositiontaking_3 as autov5positiontaking	,	   @old_auto_v5spositiontaking_3 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_3 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_3 as isautov8positiontaking	,	   @auto_v8spositiontaking_3 as autov8positiontaking	,	   @old_auto_v8spositiontaking_3 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_3 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_3 as isautov10positiontaking	,	   @auto_v10spositiontaking_3 as autov10positiontaking	,	   @old_auto_v10spositiontaking_3 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_3 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_3 as isautov99positiontaking	,		@auto_v99spositiontaking_3 as autov99positiontaking	,	   @old_auto_v99spositiontaking_3 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_3 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking					,			0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
 0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
  	select 4 as bettype	,	   @isauto_spositiontaking_4 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_4 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_4 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_4 as old_isautopositiontaking	,										 0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									    0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
 0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
 	select 5 as bettype	,	   @isauto_spositiontaking_5 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_5 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_5 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_5 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,									0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									  0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
  	select 6 as bettype	,	   @isauto_spositiontaking_6 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_6 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_6 as old_autopositiontaking	,									 0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_6 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,								 0 as isautov2positiontaking	,								 0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,						     0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,						      0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,						             0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								, 
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
  	select 7 as bettype	,	   @isauto_spositiontaking_7 as isautopositiontaking	,	  @isauto_slivepositiontaking_7 as isautolivepositiontaking	,	  @auto_spositiontaking_7 as autopositiontaking	,	   @auto_slivepositiontaking_7 as autolivepositiontaking	,		@old_auto_spositiontaking_7 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_7 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_7 as old_isautopositiontaking	    ,		 @old_isauto_slivepositiontaking_7 as old_isautolivepositiontaking	,		@isauto_v2spositiontaking_7 as isautov2positiontaking	,	   @auto_v2spositiontaking_7 as autov2positiontaking	,	   @old_auto_v2spositiontaking_7 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_7 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
  	select 8 as bettype	,	   @isauto_spositiontaking_8 as isautopositiontaking	,	  @isauto_slivepositiontaking_8 as isautolivepositiontaking	,	  @auto_spositiontaking_8 as autopositiontaking	,	   @auto_slivepositiontaking_8 as autolivepositiontaking	,		@old_auto_spositiontaking_8 as old_autopositiontaking	,	   @old_auto_slivepositiontaking_8 as old_autolivepositiontaking	,	  @old_isauto_spositiontaking_8 as old_isautopositiontaking	    ,	   @old_isauto_slivepositiontaking_8 as old_isautolivepositiontaking	,	   @isauto_v2spositiontaking_8 as isautov2positiontaking	,	   @auto_v2spositiontaking_8 as autov2positiontaking	,	   @old_auto_v2spositiontaking_8 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_8 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								, 0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking
	           ,0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
  	select 9 as bettype	,	   @isauto_spositiontaking_9 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_9 as autopositiontaking	,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_9 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_9 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,	/*@isauto_v2spositiontaking_9*/ 0 as isautov2positiontaking	,	/*@auto_v2spositiontaking_9*/ 0 as autov2positiontaking	,	/*@old_auto_v2spositiontaking_9*/ 0 as old_autov2positiontaking	,	/*@old_isauto_v2spositiontaking_9*/ 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	, 	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, @isauto_v99spositiontaking_9 as isautov99mppositiontaking	, @auto_v99spositiontaking_9 as autov99mppositiontaking	, @old_isauto_v99spositiontaking_9 as old_isautov99mppositiontaking	, @old_auto_v99spositiontaking_9 as old_autov99mppositiontaking	,0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking, 0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
  	select 10 as bettype,	   @isauto_spositiontaking_10 as isautopositiontaking	,								0 as isautolivepositiontaking	,	  @auto_spositiontaking_10 as autopositiontaking,									0 as autolivepositiontaking	,		@old_auto_spositiontaking_10 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,	   @old_isauto_spositiontaking_10 as old_isautopositiontaking	,										0 as old_isautolivepositiontaking	,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									  0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								   0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								, 
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
 	select 20 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,									  0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking  	,		@isauto_v2spositiontaking_20 as isautov2positiontaking	,	   @auto_v2spositiontaking_20 as autov2positiontaking	,	   @old_auto_v2spositiontaking_20 as old_autov2positiontaking	,	   @old_isauto_v2spositiontaking_20 as old_isautov2positiontaking	,	@isauto_v3spositiontaking_20 as isautov3positiontaking	,	   @auto_v3spositiontaking_20 as autov3positiontaking	,	   @old_auto_v3spositiontaking_20 as old_autov3positiontaking	,	   @old_isauto_v3spositiontaking_20 as old_isautov3positiontaking	,	@isauto_v5spositiontaking_20 as isautov5positiontaking	,	   @auto_v5spositiontaking_20 as autov5positiontaking	,	   @old_auto_v5spositiontaking_20 as old_autov5positiontaking	,	   @old_isauto_v5spositiontaking_20 as old_isautov5positiontaking	,	@isauto_v8spositiontaking_20 as isautov8positiontaking	,	   @auto_v8spositiontaking_20 as autov8positiontaking	,	   @old_auto_v8spositiontaking_20 as old_autov8positiontaking	,	   @old_isauto_v8spositiontaking_20 as old_isautov8positiontaking	,	@isauto_v10spositiontaking_20 as isautov10positiontaking,		@auto_v10spositiontaking_20 as autov10positiontaking,	   @old_auto_v10spositiontaking_20 as old_autov10positiontaking	,	   @old_isauto_v10spositiontaking_20 as old_isautov10positiontaking	,	@isauto_v11spositiontaking_20 as isautov11positiontaking,	   @auto_v11spositiontaking_20 as autov11positiontaking	,	   @old_auto_v11spositiontaking_20 as old_autov11positiontaking	,	   @old_isauto_v11spositiontaking_20 as old_isautov11positiontaking	,	@isauto_v99spositiontaking_20 as isautov99positiontaking,		@auto_v99spositiontaking_20 as autov99positiontaking,	   @old_auto_v99spositiontaking_20 as old_autov99positiontaking	,	   @old_isauto_v99spositiontaking_20 as old_isautov99positiontaking	, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,
@isauto_v154spositiontaking_20 AS isautov154positiontaking,
	           @auto_v154spositiontaking_20 AS autov154positiontaking,
	           @old_auto_v154spositiontaking_20 AS old_autov154positiontaking,
	           @old_isauto_v154spositiontaking_20 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
 	select 21 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									  0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,							       0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,								    0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,	0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
	           0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
UNION ALL
 	select 22 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking		,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, 0 as isautov161livepositiontaking									, 0 as autov161positiontaking							, 0 as autov161livepositiontaking								, 0 as old_autov161positiontaking								, 0 as old_autov161livepositiontaking									, 0 as old_isautov161positiontaking									, 0 as old_isautov161livepositiontaking
--- number game
UNION ALL
  	select 81 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking		,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
@isauto_v161spositiontaking_81 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_81 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_81 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking								, @old_isauto_v161spositiontaking_81 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
UNION ALL
  	select 83 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking	,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking, @isauto_v161spositiontaking_83 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_83 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_83 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_83 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking
UNION ALL
  	select 88 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking							,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
	            @isauto_v161spositiontaking_88 as isautov161positiontaking	, 0 as isautov161livepositiontaking									, @auto_v161spositiontaking_88 as autov161positiontaking, 0 as autov161livepositiontaking								, @old_auto_v161spositiontaking_88 as old_autov161positiontaking	, 0 as old_autov161livepositiontaking									, @old_isauto_v161spositiontaking_88 as old_isautov161positiontaking	, 0 as old_isauto_v161livepositiontaking

UNION ALL
  	select 85 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking							,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
 0								 as isautov161positiontaking	, @isauto_v161slivepositiontaking_85 as isautov161livepositiontaking, 0 as autov161positiontaking,							  @auto_v161slivepositiontaking_85 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_85 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_85 as old_isautov161livepositiontaking
union all  	
	select 86 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
	            @isauto_v161spositiontaking_86 as isautov161positiontaking	, @isauto_v161slivepositiontaking_86 as isautov161livepositiontaking, @auto_v161spositiontaking_86 as autov161positiontaking, @auto_v161slivepositiontaking_86 as autov161livepositiontaking, @old_auto_v161spositiontaking_86 as old_autov161positiontaking	, @old_auto_v161slivepositiontaking_86 as old_autov161livepositiontaking	, @old_isauto_v161spositiontaking_86 as old_isautov161positiontaking	, @old_isauto_v161slivepositiontaking_86 as old_isautov161livepositiontaking
union all  
	select 87 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_87 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_87 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_87 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_87 as old_isautov161livepositiontaking
union all  	
	select 89 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_89 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_89 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_89 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_89 as old_isautov161livepositiontaking
union all  	
	select 90 as bettype,	   0 as isautopositiontaking							,								0 as isautolivepositiontaking	,							0 as autopositiontaking	,									0 as autolivepositiontaking	,									0 as old_autopositiontaking	,										0 as old_autolivepositiontaking	,									 0 as old_isautopositiontaking	,									  0 as old_isautolivepositiontaking	    ,								 0 as isautov2positiontaking	,								0 as autov2positiontaking	,									 0 as old_autov2positiontaking	,									 0 as old_isautov2positiontaking	,								0 as isautov3positiontaking	,								0 as autov3positiontaking	,									0 as old_autov3positiontaking	,									  0 as old_isautov3positiontaking	,							 0 as isautov5positiontaking	,								 0 as autov5positiontaking	,								   0 as old_autov5positiontaking	,									  0 as old_isautov5positiontaking	,							  0 as isautov8positiontaking	,								 0 as autov8positiontaking	,									0 as old_autov8positiontaking	,									 0 as old_isautov8positiontaking	,							0 as isautov10positiontaking	,								0 as autov10positiontaking	,									0 as old_autov10positiontaking	,									0 as old_isautov10positiontaking	,							0 as isautov11positiontaking	,								0 as autov11positiontaking	,									0 as old_autov11positiontaking	,									0 as old_isautov11positiontaking	,   0 as isautov99positiontaking							,		0 as autov99positiontaking							,			0 as old_autov99positiontaking							,	       0 as old_isautov99positiontaking								, 0 as isautov99mppositiontaking							, 0 as autov99mppositiontaking							, 0 as old_isautov99mppositiontaking								, 0 as old_autov99mppositiontaking								,
0 AS isautov154positiontaking,
	           0 AS autov154positiontaking,
	           0 AS old_autov154positiontaking,
	           0 AS old_isautov154positiontaking,
0 as isautov161positiontaking									, @isauto_v161slivepositiontaking_90 as isautov161livepositiontaking, 0 as autov161positiontaking							, @auto_v161slivepositiontaking_90 as autov161livepositiontaking, 0 as old_autov161positiontaking									, @old_auto_v161slivepositiontaking_90 as old_autov161livepositiontaking	, 0 as old_isautov161positiontaking										, @old_isauto_v161slivepositiontaking_90 as old_isautov161livepositiontaking
-------------------------------------------
	
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
		@isautov154mpositiontaking, @autov154mpositiontaking, @old_autov154positiontaking, @old_isautov154positiontaking,
		@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
--		if @autopositiontaking <> @old_autopositiontaking or @isautopositiontaking <> @old_isautopositiontaking 
--		BEGIN			
		if (@UpdateMultiple = 0 or @UpdatePositiontaking = 1)
		Begin --@UpdatePositiontaking
			if @isautopositiontaking >0
			BEGIN
				select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
				update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking> @autopositiontaking then @autopositiontaking else @maxpos - mpositiontaking-apositiontaking end
				where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
				if @@Error <> 0
				BEGIN
					
					SELECT @ErrMsg =  
						case @Language 
							when 'E' then 'Error updating auto position taking (for Soccer)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
						end	
					RaisError (@ErrMsg, 16, 1)
					DEALLOCATE CUR
					CLOSE CUR
					return
				END
			END
--		END
		---------------------------------
		--Update LIVE
			if @bettype in (1,3,7,8) --and (@autolivepositiontaking <> @old_autolivepositiontaking or @isautolivepositiontaking <> @old_isautolivepositiontaking)
			BEGIN
				if @isautolivepositiontaking >0
				BEGIN
					select @maxpos = slivepositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=1 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autolivepositiontaking then @autolivepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=1
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
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END		
		End --@UpdatePositiontaking
		---------------------------------
		--Update Basketball
		if @bettype in (1,2,3,7,8,9,20) --and (@autov2positiontaking <> @old_autov2positiontaking or @isautov2positiontaking <> @old_isautov2positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1)
			Begin --@UpdatePositiontakingv2
				if @isautov2positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=2 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov2positiontaking then @autov2positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=2
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Basketball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End --@UpdatePositiontakingv2
		END
		
		---------------------------------
		--Update Football
		if @bettype in (1,2,3,20) --and (@autov3positiontaking <> @old_autov3positiontaking or @isautov3positiontaking <> @old_isautov3positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1)
			Begin --@UpdatePositiontakingv3
				if @isautov3positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=3 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov3positiontaking then @autov3positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=3
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Football)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End --@UpdatePositiontakingv3
		END

		---------------------------------
		--Update Tennis
		if @bettype in (1,2,3,20) --and (@autov5positiontaking <> @old_autov5positiontaking or @isautov5positiontaking <> @old_isautov5positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1)
			Begin --@UpdatePositiontakingv5
				if @isautov5positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=5 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov5positiontaking then @autov5positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=5
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Tennis)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End--@UpdatePositiontakingv5
		END

		---------------------------------
		--Update Baseball
		if @bettype in (1,3,20) --and (@autov8positiontaking <> @old_autov8positiontaking or @isautov8positiontaking <> @old_isautov8positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1)
			Begin --@UpdatePositiontakingv8
				if @isautov8positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=8 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov8positiontaking then @autov8positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=8
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Baseball)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End--@UpdatePositiontakingv8
		END

		---------------------------------
		--Update Golf
		if @bettype in (1,2,3,20) --and (@autov10positiontaking <> @old_autov10positiontaking or @isautov10positiontaking <> @old_isautov10positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1)
			Begin --@UpdatePositiontakingv10
				if @isautov10positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=10 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov10positiontaking then @autov10positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=10
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Golf)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End--@UpdatePositiontakingv10
		END

		---------------------------------
		--Update Motorsports
		if @bettype in (1,20) --and (@autov11positiontaking <> @old_autov11positiontaking or @isautov11positiontaking <> @old_isautov11positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1)
			Begin --@UpdatePositiontakingv11
				if @isautov11positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=11 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov11positiontaking then @autov11positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=11
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Motorsports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End--@UpdatePositiontakingv11
		END

		---------------------------------
		--Update Other sports
		if @bettype in (1,2,3,20) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1)
			Begin --@UpdatePositiontakingv99
				if @isautov99positiontaking >0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99positiontaking then @autov99positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			End--@UpdatePositiontakingv99
		END

		---------------------------------
		-- Update mixed sports
		if @bettype = 9 --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1)
			Begin --@UpdatePositiontakingv99MP
				if @isautov99mppositiontaking > 0
				BEGIN
					select @maxpos = spositiontaking from custsetting with (NOLOCK) where custid = @srecommend and sporttype=99 and bettype = @bettype
					update custsetting with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov99mppositiontaking then @autov99mppositiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting
					where custid = @custid and custsetting.bettype = @bettype and custsetting.sporttype=99
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
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END --@UpdatePositiontakingv99MP
		END
		---------------------------------
		
		-- Update HR Fixed Odds
		IF @bettype = 20 
		BEGIN
			IF @UpdateMultiple = 0 OR @UpdatePositiontakingv154 = 1
			BEGIN
				IF @isautov154mpositiontaking > 0
				BEGIN
					SELECT @maxpos = cs.spositiontaking
					FROM custSetting cs WITH (NOLOCK) 
					WHERE cs.custid = @srecommend
					AND cs.bettype = @bettype
					AND cs.sporttype = 154
					UPDATE custSetting WITH(UPDLOCK, ROWLOCK)
					SET spositiontaking = CASE WHEN @maxpos - mpositiontaking - apositiontaking > @autov154mpositiontaking THEN @autov154mpositiontaking ELSE @maxpos - mpositiontaking - apositiontaking END
					WHERE custid = @custid
					AND bettype = @bettype
					AND sporttype = 154
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
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END
		END
		-- Update number game (non-live)
		if @bettype in (81,83,86,88) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
			Begin --@UpdatePositiontakingv161
				if @isautov161positiontaking > 0
				BEGIN
					select @maxpos = spositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
					update cs3 with (ROWLOCK, UPDLOCK) set spositiontaking = case when @maxpos - mpositiontaking-apositiontaking>@autov161positiontaking then @autov161positiontaking else @maxpos - mpositiontaking-apositiontaking end
					from custsetting3rd cs3
					where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Number Game)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END--@UpdatePositiontakingv161
		END

		---------------------------------

		-- Update number game (live)
		if @bettype in (85,86,87,89,90) --and (@autov99positiontaking <> @old_autov99positiontaking or @isautov99positiontaking <> @old_isautov99positiontaking )
		BEGIN
			if (@UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1)
			Begin --@UpdatePositiontakingv161
				if @isautov161livepositiontaking > 0
				BEGIN
					select @maxpos = slivepositiontaking from custsetting3rd with (NOLOCK) where custid = @srecommend and sporttype=161 and bettype = @bettype
					update cs3 with (ROWLOCK, UPDLOCK) set slivepositiontaking = case when @maxpos - mlivepositiontaking-alivepositiontaking>@autov161livepositiontaking then @autov161livepositiontaking else @maxpos - mlivepositiontaking-alivepositiontaking end
					from custsetting3rd cs3
					where custid = @custid and cs3.bettype = @bettype and cs3.sporttype=161
					if @@Error <> 0
					BEGIN
						
						SELECT @ErrMsg =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Number Game - Live)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + case @Language 
																							when 'CS' then N'(供数字游戏-现场)'
																							when 'CT' then N'(供數字游戲-現場)'
																							when 'TH' then N'(สำหรับเกมหมายเลข -สด)'
																							when 'J' then N'(for Number Game - LIVE)'
																							when 'KO' then N'(for Number Game - LIVE)'
																							when 'VI' then N'(for Number Game - Trực tuyến)'
																							else N'(for Number Game - LIVE)' END
							end	
						RaisError (@ErrMsg, 16, 1)
						DEALLOCATE CUR
						CLOSE CUR
						return
					END
				END
			END--@UpdatePositiontakingv161
		END

		---------------------------------	
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
			@isautov154mpositiontaking, @autov154mpositiontaking, @old_autov154positiontaking, @old_isautov154positiontaking,
			@isautov161positiontaking, @isautov161livepositiontaking, @autov161positiontaking, @autov161livepositiontaking, @old_autov161positiontaking, @old_autov161livepositiontaking, @old_isautov161positiontaking, @old_isautov161livepositiontaking
		
	END

	CLOSE CUR
	DEALLOCATE CUR

/*
declare @LogData nvarchar(1000)

Select @LogData = 
	'Super ' + convert(varchar(20), @UserID) + ' update member autopositiontaing ' + convert(varchar(20), @CustID) +
		+ '[old,new] '
		+ 'spos1['+convert(varchar(20), @old_auto_spositiontaking_1)+','+convert(varchar(20), @auto_spositiontaking_1)+']'
		+ 'spos2['+convert(varchar(20), @old_auto_spositiontaking_2)+','+convert(varchar(20), @auto_spositiontaking_2)+']'
		+ 'spos3['+convert(varchar(20), @old_auto_spositiontaking_3)+','+convert(varchar(20), @auto_spositiontaking_3)+']'
		+ 'spos4['+convert(varchar(20), @old_auto_spositiontaking_4)+','+convert(varchar(20), @auto_spositiontaking_4)+']'
		+ 'spos5['+convert(varchar(20), @old_auto_spositiontaking_5)+','+convert(varchar(20), @auto_spositiontaking_5)+']'
		+ 'spos6['+convert(varchar(20), @old_auto_spositiontaking_6)+','+convert(varchar(20), @auto_spositiontaking_6)+']'
		+ 'spos7['+convert(varchar(20), @old_auto_spositiontaking_7)+','+convert(varchar(20), @auto_spositiontaking_7)+']'
		+ 'spos8['+convert(varchar(20), @old_auto_spositiontaking_8)+','+convert(varchar(20), @auto_spositiontaking_8)+']'
		+ 'spos9['+convert(varchar(20), @old_auto_spositiontaking_9)+','+convert(varchar(20), @auto_spositiontaking_9)+']'
		+ 'spos10['+convert(varchar(20), @old_auto_spositiontaking_10)+','+convert(varchar(20), @auto_spositiontaking_10)+']'

		+ 'slpos1['+convert(varchar(20), @old_auto_slivepositiontaking_1)+','+convert(varchar(20), @auto_slivepositiontaking_1)+']'
		+ 'slpos3['+convert(varchar(20), @old_auto_slivepositiontaking_3)+','+convert(varchar(20), @auto_slivepositiontaking_3)+']'
		+ 'slpos7['+convert(varchar(20), @old_auto_slivepositiontaking_7)+','+convert(varchar(20), @auto_slivepositiontaking_7)+']'
		+ 'slpos8['+convert(varchar(20), @old_auto_slivepositiontaking_8)+','+convert(varchar(20), @auto_slivepositiontaking_8)+']'

		+ 'bspos1['+convert(varchar(20), @old_auto_v2spositiontaking_1)+','+convert(varchar(20), @auto_v2spositiontaking_1)+']'
		+ 'bspos2['+convert(varchar(20), @old_auto_v2spositiontaking_2)+','+convert(varchar(20), @auto_v2spositiontaking_2)+']'
		+ 'bspos3['+convert(varchar(20), @old_auto_v2spositiontaking_3)+','+convert(varchar(20), @auto_v2spositiontaking_3)+']'
		+ 'bspos7['+convert(varchar(20), @old_auto_v2spositiontaking_7)+','+convert(varchar(20), @auto_v2spositiontaking_7)+']'
		+ 'bspos8['+convert(varchar(20), @old_auto_v2spositiontaking_8)+','+convert(varchar(20), @auto_v2spositiontaking_8)+']'
		+ 'bspos9['+convert(varchar(20), @old_auto_v2spositiontaking_9)+','+convert(varchar(20), @auto_v2spositiontaking_9)+']'
		+ 'bspos20['+convert(varchar(20), @old_auto_v2spositiontaking_20)+','+convert(varchar(20), @auto_v2spositiontaking_20)+']'

if len(@logdata) >300
BEGIN
	select @logdata = left(@logdata,300)
END
EXEC WriteLog_UserLog @UserID = @UserID, @Doing = @LogData


Select @LogData = 
	'Super ' + convert(varchar(20), @UserID) + ' update member isautopositiontaing ' + convert(varchar(20), @custid) +
		+ '[old,new] '
		+ 'isauto1['+convert(varchar(20), @old_isauto_spositiontaking_1)+','+convert(varchar(20), @isauto_spositiontaking_1)+']'
		+ 'isauto2['+convert(varchar(20), @old_isauto_spositiontaking_2)+','+convert(varchar(20), @isauto_spositiontaking_2)+']'
		+ 'isauto3['+convert(varchar(20), @old_isauto_spositiontaking_3)+','+convert(varchar(20), @isauto_spositiontaking_3)+']'
		+ 'isauto4['+convert(varchar(20), @old_isauto_spositiontaking_4)+','+convert(varchar(20), @isauto_spositiontaking_4)+']'
		+ 'isauto5['+convert(varchar(20), @old_isauto_spositiontaking_5)+','+convert(varchar(20), @isauto_spositiontaking_5)+']'
		+ 'isauto6['+convert(varchar(20), @old_isauto_spositiontaking_6)+','+convert(varchar(20), @isauto_spositiontaking_6)+']'
		+ 'isauto7['+convert(varchar(20), @old_isauto_spositiontaking_7)+','+convert(varchar(20), @isauto_spositiontaking_7)+']'
		+ 'isauto8['+convert(varchar(20), @old_isauto_spositiontaking_8)+','+convert(varchar(20), @isauto_spositiontaking_8)+']'
		+ 'isauto9['+convert(varchar(20), @old_isauto_spositiontaking_9)+','+convert(varchar(20), @isauto_spositiontaking_9)+']'
		+ 'isauto10['+convert(varchar(20), @old_isauto_spositiontaking_10)+','+convert(varchar(20), @isauto_spositiontaking_10)+']'

		+ 'islauto1['+convert(varchar(20), @old_isauto_slivepositiontaking_1)+','+convert(varchar(20), @isauto_slivepositiontaking_1)+']'
		+ 'islauto3['+convert(varchar(20), @old_isauto_slivepositiontaking_3)+','+convert(varchar(20), @isauto_slivepositiontaking_3)+']'
		+ 'islauto7['+convert(varchar(20), @old_isauto_slivepositiontaking_7)+','+convert(varchar(20), @isauto_slivepositiontaking_7)+']'
		+ 'islauto8['+convert(varchar(20), @old_isauto_slivepositiontaking_8)+','+convert(varchar(20), @isauto_slivepositiontaking_8)+']'

		+ 'isbauto1['+convert(varchar(20), @old_isauto_v2spositiontaking_1)+','+convert(varchar(20), @isauto_v2spositiontaking_1)+']'
		+ 'isbauto2['+convert(varchar(20), @old_isauto_v2spositiontaking_2)+','+convert(varchar(20), @isauto_v2spositiontaking_2)+']'
		+ 'isbauto3['+convert(varchar(20), @old_isauto_v2spositiontaking_3)+','+convert(varchar(20), @isauto_v2spositiontaking_3)+']'
		+ 'isbauto7['+convert(varchar(20), @old_isauto_v2spositiontaking_7)+','+convert(varchar(20), @isauto_v2spositiontaking_7)+']'
		+ 'isbauto8['+convert(varchar(20), @old_isauto_v2spositiontaking_8)+','+convert(varchar(20), @isauto_v2spositiontaking_8)+']'
		+ 'isbauto9['+convert(varchar(20), @old_isauto_v2spositiontaking_9)+','+convert(varchar(20), @isauto_v2spositiontaking_9)+']'
		+ 'isbauto20['+convert(varchar(20), @old_isauto_v2spositiontaking_20)+','+convert(varchar(20), @isauto_v2spositiontaking_20)+']'

if len(@logdata) >300
BEGIN
	select @logdata = left(@logdata,300)
END
EXEC WriteLog_UserLog @UserID = @UserID, @Doing = @LogData
*/

GO
GRANT VIEW DEFINITION ON [Acc_CustomerUpdMember_AutoPositiontaking] TO vnteam
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_AutoPositiontaking] TO [bodbAdminNet]
