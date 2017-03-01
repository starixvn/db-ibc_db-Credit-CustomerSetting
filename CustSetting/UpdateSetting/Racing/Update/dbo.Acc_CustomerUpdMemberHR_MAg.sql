ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberHR_MAg] 
	@CustID int,--memberid
	--m1
	@v151mpositiontaking_31 smallmoney  = 0 OUTPUT,
	@v151mpositiontaking_32 smallmoney  = 0 OUTPUT,
	@v151mpositiontaking_41 smallmoney  = 0 OUTPUT,
	@v151mpositiontaking_42 smallmoney  = 0 OUTPUT,
	@v151mpositiontaking_51 smallmoney = 0 OUTPUT,
	@v151mpositiontaking_52 smallmoney = 0 OUTPUT,
	@v152mpositiontaking_41 smallmoney = 0 OUTPUT,
	@v152mpositiontaking_42 smallmoney = 0 OUTPUT,
	@v152mpositiontaking_51 smallmoney = 0 OUTPUT,
	@v152mpositiontaking_52 smallmoney = 0 OUTPUT,
	@v153mpositiontaking_51 smallmoney = 0 OUTPUT,
	@v153mpositiontaking_52 smallmoney = 0 OUTPUT,
	--im2
	@isauto_v151mpositiontaking_31 bit = 0,
	@isauto_v151mpositiontaking_32 bit = 0,
	@isauto_v151mpositiontaking_41 bit = 0,
	@isauto_v151mpositiontaking_42 bit = 0,
	@isauto_v151mpositiontaking_51 bit = 0,
	@isauto_v151mpositiontaking_52 bit = 0,
	@isauto_v152mpositiontaking_41 bit = 0,
	@isauto_v152mpositiontaking_42 bit = 0,
	@isauto_v152mpositiontaking_51 bit = 0,
	@isauto_v152mpositiontaking_52 bit = 0,
	@isauto_v153mpositiontaking_51 bit = 0,
	@isauto_v153mpositiontaking_52 bit = 0,
	--im1
	@isauto_v151mpositiontaking_mem_31 bit = 0,
	@isauto_v151mpositiontaking_mem_32 bit = 0,
	@isauto_v151mpositiontaking_mem_41 bit = 0,
	@isauto_v151mpositiontaking_mem_42 bit = 0,
	@isauto_v151mpositiontaking_mem_51 bit = 0,
	@isauto_v151mpositiontaking_mem_52 bit = 0,
	@isauto_v152mpositiontaking_mem_41 bit = 0,
	@isauto_v152mpositiontaking_mem_42 bit = 0,
	@isauto_v152mpositiontaking_mem_51 bit = 0,
	@isauto_v152mpositiontaking_mem_52 bit = 0,
	@isauto_v153mpositiontaking_mem_51 bit = 0,
	@isauto_v153mpositiontaking_mem_52 bit = 0,
	--um1
	@auto_v151mpositiontaking_mem_31 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_32 SMALLMONEY = 0,  
	@auto_v151mpositiontaking_mem_41 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_42 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_51 SMALLMONEY = 0,
	@auto_v151mpositiontaking_mem_52 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_41 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_42 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_51 SMALLMONEY = 0,
	@auto_v152mpositiontaking_mem_52 SMALLMONEY = 0,
	@auto_v153mpositiontaking_mem_51 SMALLMONEY = 0,
	@auto_v153mpositiontaking_mem_52 SMALLMONEY = 0, 

	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1,

	@UserID int,--masterid	
	@Language varchar(2) = 'E',
	@SubAccID int = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090520@Phuc
Task : Master edit member(HR)
DB: DBTXN/bodb02
Original: [Acc_CustomerUpdMaster_Member]

Revisions:
	-20090626@Phuc: Auto master PT on member level
					Enrich error message.(-101: general info, -102: closed, -103: suspended, 
						-104: credit, -105: commission, -106: min/max bet, -107: positiontaking
						-108: disable FI, -109: disableHR)
	-20090723@Phuc: Write log subaccname instead of subaccid.
    - 20090801@Shifu: check disabled user
    - 20090806@Phuc: remove check m1=min(m3-a2,m1)
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100515@Shifu: Add default value for @v151mpositiontaking_31, @v151mpositiontaking_32
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20101019@Henry: Record execution time
	- 20110124@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
	- 20110323@Johnson: check @custid must be member's ID
	- 20110504@Lukas: backup isAutoPT_Master_On_Agent to write log
	- 20110519@Johnson: write log for old setting
	- 20110709@Johnson: Change to use new server BD053 instead DB052.
	- 20111017@TOM: Apply Multiple Edit Racing PT.	
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20130610@Johnson: check m1 with valid range of m1
	- 20131106@Johnson: Apply execrep when update pt on member
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)	
	- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
	- 20140307@Johnson: apply new m1_max is m3-a1 not apply range !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1) [Redmine:#12953] 
	- 20140313@Johnson: check constraint min um1, m1 with max(n3-a1,0)
						merge code correct pt into sp execrep Acc_CustSetting3rd_08/Acc_CustSetting3rd_09[redmine:#11562]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Use temp table for sports, bettype table,
															Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID)
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

----- Elodie @ 01 JUN 2015 -------------------
	DECLARE @tmp_Sports TABLE (SportType TINYINT, SportName NVARCHAR(50))
	DECLARE @tmp_Bettype TABLE (TypeID INT, TypeNamee NVARCHAR(50))
	
	BEGIN TRY
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBAGE.bodb02.dbo.Sports WITH (NOLOCK)		
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_Sports (SportType, SportName)
		SELECT SportType, SportName FROM DBTXN.bodb02.dbo.Sports WITH (NOLOCK)	
	END CATCH

	BEGIN TRY			
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBAGE.bodb02.dbo.Bettype WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_Bettype (TypeID, TypeNamee)
		SELECT TypeID, TypeNamee FROM DBTXN.bodb02.dbo.Bettype WITH (NOLOCK)
	END CATCH
----- /Elodie @ 01 JUN 2015 -------------------

Declare @ErrType varchar(1000), @roleid tinyint, @recommend INT,	@mrecommend INT, @srecommend INT,
	@ErrCode_cur int, @ErrMsg_cur nvarchar(4000)
Select @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

EXEC Age_CustomerSelCheckBelongingByCustID
	@SessionCustID = @Userid, 
	@username = @username output,
	@Custid = @custid,
	@roleid = @roleid OUTPUT
	if (@roleid <> 1) return -- return if not member

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end

select @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend 
from customer with (NOLOCK) where custid = @custid

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check parameter

declare @maxpos smallmoney
set @maxpos = 0.5

if ((@v151mpositiontaking_31 <0
	or @v151mpositiontaking_32 <0
	or @v151mpositiontaking_31 > @maxpos
	or @v151mpositiontaking_32 > @maxpos
	or @auto_v151mpositiontaking_mem_31 <0
	or @auto_v151mpositiontaking_mem_32 <0
	or @auto_v151mpositiontaking_mem_31 > @maxpos
	or @auto_v151mpositiontaking_mem_32 > @maxpos	)
	and @UpdatePositiontakingv151_31 = 1			)
	
	or ((@v151mpositiontaking_41 <0
	or @v151mpositiontaking_42 <0
	or @v151mpositiontaking_41 > @maxpos
	or @v151mpositiontaking_42 > @maxpos
	or @auto_v151mpositiontaking_mem_41 <0
	or @auto_v151mpositiontaking_mem_42 <0
	or @auto_v151mpositiontaking_mem_41 > @maxpos
	or @auto_v151mpositiontaking_mem_42 > @maxpos	)	
	and @UpdatePositiontakingv151_41 = 1			)
	
	or ((@v151mpositiontaking_51 <0
	or @v151mpositiontaking_52 <0
	or @v151mpositiontaking_51 > @maxpos
	or @v151mpositiontaking_52 > @maxpos
	or @auto_v151mpositiontaking_mem_51 <0
	or @auto_v151mpositiontaking_mem_52 <0
	or @auto_v151mpositiontaking_mem_51 > @maxpos
	or @auto_v151mpositiontaking_mem_52 > @maxpos	)
	and @UpdatePositiontakingv151_51 = 1			)
	
	or ((@v152mpositiontaking_41 <0
	or @v152mpositiontaking_42 <0
	or @v152mpositiontaking_41 > @maxpos
	or @v152mpositiontaking_42 > @maxpos
	or @auto_v152mpositiontaking_mem_41 <0
	or @auto_v152mpositiontaking_mem_42 <0
	or @auto_v152mpositiontaking_mem_41 > @maxpos
	or @auto_v152mpositiontaking_mem_42 > @maxpos	)	
	and @UpdatePositiontakingv152_41 = 1			)
	
	or ((@v152mpositiontaking_51 <0
	or @v152mpositiontaking_52 <0
	or @v152mpositiontaking_51 > @maxpos
	or @v152mpositiontaking_52 > @maxpos
	or @auto_v152mpositiontaking_mem_51 <0
	or @auto_v152mpositiontaking_mem_52 <0
	or @auto_v152mpositiontaking_mem_51 > @maxpos
	or @auto_v152mpositiontaking_mem_52 > @maxpos	)
	and @UpdatePositiontakingv152_51 = 1			)
	
	or ((@v153mpositiontaking_51 <0
	or @v153mpositiontaking_52 <0
	or @v153mpositiontaking_51 > @maxpos
	or @v153mpositiontaking_52 > @maxpos
	or @auto_v153mpositiontaking_mem_51 <0
	or @auto_v153mpositiontaking_mem_52 <0
	or @auto_v153mpositiontaking_mem_51 > @maxpos
	or @auto_v153mpositiontaking_mem_52 > @maxpos	)
	and @UpdatePositiontakingv153_51 = 1			)

BEGIN
	select @ErrCode_cur = 5
	Select @ErrMsg_cur = 	@UserName + ': ' +
		case @Language 
						when 'E' then 'Wrong position taking.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
				end
	Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
-- End check param
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


DECLARE 
	--a1
	@v151apositiontaking_31 SMALLMONEY,
	@v151apositiontaking_32 SMALLMONEY,
	@v151apositiontaking_41 SMALLMONEY,
	@v151apositiontaking_42 SMALLMONEY,
	@v151apositiontaking_51 SMALLMONEY,
	@v151apositiontaking_52 SMALLMONEY,
	@v152apositiontaking_41 SMALLMONEY,
	@v152apositiontaking_42 SMALLMONEY,
	@v152apositiontaking_51 SMALLMONEY,
	@v152apositiontaking_52 SMALLMONEY,
	@v153apositiontaking_51 SMALLMONEY,
	@v153apositiontaking_52 SMALLMONEY,
	
	--a2
	@max_v151apositiontaking_31 SMALLMONEY,
	@max_v151apositiontaking_32 SMALLMONEY,
	@max_v151apositiontaking_41 SMALLMONEY,
	@max_v151apositiontaking_42 SMALLMONEY,
	@max_v151apositiontaking_51 SMALLMONEY,
	@max_v151apositiontaking_52 SMALLMONEY,
	@max_v152apositiontaking_41 SMALLMONEY,
	@max_v152apositiontaking_42 SMALLMONEY,
	@max_v152apositiontaking_51 SMALLMONEY,
	@max_v152apositiontaking_52 SMALLMONEY,
	@max_v153apositiontaking_51 SMALLMONEY,
	@max_v153apositiontaking_52 SMALLMONEY,
	
	--old_m1	
	@old_v151mpositiontaking_31 SMALLMONEY,
	@old_v151mpositiontaking_32 SMALLMONEY,
	@old_v151mpositiontaking_41 SMALLMONEY,
	@old_v151mpositiontaking_42 SMALLMONEY,
	@old_v151mpositiontaking_51 SMALLMONEY,
	@old_v151mpositiontaking_52 SMALLMONEY,
	@old_v152mpositiontaking_41 SMALLMONEY,
	@old_v152mpositiontaking_42 SMALLMONEY,
	@old_v152mpositiontaking_51 SMALLMONEY,
	@old_v152mpositiontaking_52 SMALLMONEY,
	@old_v153mpositiontaking_51 SMALLMONEY,
	@old_v153mpositiontaking_52 SMALLMONEY,
	
	--old_um1
	@old_auto_v151mpositiontaking_mem_31 SMALLMONEY,
	@old_auto_v151mpositiontaking_mem_32 SMALLMONEY,
	@old_auto_v151mpositiontaking_mem_41 SMALLMONEY,
	@old_auto_v151mpositiontaking_mem_42 SMALLMONEY,
	@old_auto_v151mpositiontaking_mem_51 SMALLMONEY,
	@old_auto_v151mpositiontaking_mem_52 SMALLMONEY,
	@old_auto_v152mpositiontaking_mem_41 SMALLMONEY,
	@old_auto_v152mpositiontaking_mem_42 SMALLMONEY,
	@old_auto_v152mpositiontaking_mem_51 SMALLMONEY,
	@old_auto_v152mpositiontaking_mem_52 SMALLMONEY,
	@old_auto_v153mpositiontaking_mem_51 SMALLMONEY,
	@old_auto_v153mpositiontaking_mem_52 SMALLMONEY,
	
	--old_im1
	@old_isauto_v151mpositiontaking_mem_31 BIT,
	@old_isauto_v151mpositiontaking_mem_32 BIT,
	@old_isauto_v151mpositiontaking_mem_41 BIT,
	@old_isauto_v151mpositiontaking_mem_42 BIT,
	@old_isauto_v151mpositiontaking_mem_51 BIT,
	@old_isauto_v151mpositiontaking_mem_52 BIT,
	@old_isauto_v152mpositiontaking_mem_41 BIT,
	@old_isauto_v152mpositiontaking_mem_42 BIT,
	@old_isauto_v152mpositiontaking_mem_51 BIT,
	@old_isauto_v152mpositiontaking_mem_52 BIT,
	@old_isauto_v153mpositiontaking_mem_51 BIT,
	@old_isauto_v153mpositiontaking_mem_52 BIT,

	--s4
	@max_v151spositiontaking_31 SMALLMONEY,
	@max_v151spositiontaking_32 SMALLMONEY,
	@max_v151spositiontaking_41 SMALLMONEY,
	@max_v151spositiontaking_42 SMALLMONEY,
	@max_v151spositiontaking_51 SMALLMONEY,
	@max_v151spositiontaking_52 SMALLMONEY,
	@max_v152spositiontaking_41 SMALLMONEY,
	@max_v152spositiontaking_42 SMALLMONEY,
	@max_v152spositiontaking_51 SMALLMONEY,
	@max_v152spositiontaking_52 SMALLMONEY,
	@max_v153spositiontaking_51 SMALLMONEY,
	@max_v153spositiontaking_52 SMALLMONEY,
	
	--s1
	@v151spositiontaking_31 SMALLMONEY,
	@v151spositiontaking_32 SMALLMONEY,
	@v151spositiontaking_41 SMALLMONEY,
	@v151spositiontaking_42 SMALLMONEY,
	@v151spositiontaking_51 SMALLMONEY,
	@v151spositiontaking_52 SMALLMONEY,
	@v152spositiontaking_41 SMALLMONEY,
	@v152spositiontaking_42 SMALLMONEY,
	@v152spositiontaking_51 SMALLMONEY,
	@v152spositiontaking_52 SMALLMONEY,
	@v153spositiontaking_51 SMALLMONEY,
	@v153spositiontaking_52 SMALLMONEY,
	
	--u1
	@auto_v151spositiontaking_mem_31 SMALLMONEY,
	@auto_v151spositiontaking_mem_32 SMALLMONEY,
	@auto_v151spositiontaking_mem_41 SMALLMONEY,
	@auto_v151spositiontaking_mem_42 SMALLMONEY,
	@auto_v151spositiontaking_mem_51 SMALLMONEY,
	@auto_v151spositiontaking_mem_52 SMALLMONEY,
	@auto_v152spositiontaking_mem_41 SMALLMONEY,
	@auto_v152spositiontaking_mem_42 SMALLMONEY,
	@auto_v152spositiontaking_mem_51 SMALLMONEY,
	@auto_v152spositiontaking_mem_52 SMALLMONEY,
	@auto_v153spositiontaking_mem_51 SMALLMONEY,
	@auto_v153spositiontaking_mem_52 SMALLMONEY,
	--i1
	@isauto_v151spositiontaking_mem_31 BIT,
	@isauto_v151spositiontaking_mem_32 BIT,
	@isauto_v151spositiontaking_mem_41 BIT,
	@isauto_v151spositiontaking_mem_42 BIT,
	@isauto_v151spositiontaking_mem_51 BIT,
	@isauto_v151spositiontaking_mem_52 BIT,
	@isauto_v152spositiontaking_mem_41 BIT,
	@isauto_v152spositiontaking_mem_42 BIT,
	@isauto_v152spositiontaking_mem_51 BIT,
	@isauto_v152spositiontaking_mem_52 BIT,
	@isauto_v153spositiontaking_mem_51 BIT,
	@isauto_v153spositiontaking_mem_52 BIT,
	--u3
	@auto_v151spositiontaking_31 SMALLMONEY,
	@auto_v151spositiontaking_32 SMALLMONEY,
	@auto_v151spositiontaking_41 SMALLMONEY,
	@auto_v151spositiontaking_42 SMALLMONEY,
	@auto_v151spositiontaking_51 SMALLMONEY,
	@auto_v151spositiontaking_52 SMALLMONEY,
	@auto_v152spositiontaking_41 SMALLMONEY,
	@auto_v152spositiontaking_42 SMALLMONEY,
	@auto_v152spositiontaking_51 SMALLMONEY,
	@auto_v152spositiontaking_52 SMALLMONEY,
	@auto_v153spositiontaking_51 SMALLMONEY,
	@auto_v153spositiontaking_52 SMALLMONEY,
	
	--i3
	@isauto_v151spositiontaking_31 BIT,
	@isauto_v151spositiontaking_32 BIT,
	@isauto_v151spositiontaking_41 BIT,
	@isauto_v151spositiontaking_42 BIT,
	@isauto_v151spositiontaking_51 BIT,
	@isauto_v151spositiontaking_52 BIT,
	@isauto_v152spositiontaking_41 BIT,
	@isauto_v152spositiontaking_42 BIT,
	@isauto_v152spositiontaking_51 BIT,
	@isauto_v152spositiontaking_52 BIT,
	@isauto_v153spositiontaking_51 BIT,
	@isauto_v153spositiontaking_52 BIT,
	
	--um2
	@auto_v151mpositiontaking_31 SMALLMONEY,
	@auto_v151mpositiontaking_32 SMALLMONEY,
	@auto_v151mpositiontaking_41 SMALLMONEY,
	@auto_v151mpositiontaking_42 SMALLMONEY,
	@auto_v151mpositiontaking_51 SMALLMONEY,
	@auto_v151mpositiontaking_52 SMALLMONEY,
	@auto_v152mpositiontaking_41 SMALLMONEY,
	@auto_v152mpositiontaking_42 SMALLMONEY,
	@auto_v152mpositiontaking_51 SMALLMONEY,
	@auto_v152mpositiontaking_52 SMALLMONEY,
	@auto_v153mpositiontaking_51 SMALLMONEY,
	@auto_v153mpositiontaking_52 SMALLMONEY,
	
	---- backup to write log
	@isauto_v151mpositiontaking_agent_31 bit,
	@isauto_v151mpositiontaking_agent_32 bit,
	@isauto_v151mpositiontaking_agent_41 bit,
	@isauto_v151mpositiontaking_agent_42 bit,
	@isauto_v151mpositiontaking_agent_51 bit,
	@isauto_v151mpositiontaking_agent_52 bit,
	@isauto_v152mpositiontaking_agent_41 bit,
	@isauto_v152mpositiontaking_agent_42 bit,
	@isauto_v152mpositiontaking_agent_51 bit,
	@isauto_v152mpositiontaking_agent_52 bit,
	@isauto_v153mpositiontaking_agent_51 bit,
	@isauto_v153mpositiontaking_agent_52 bit

DECLARE
	--m3
	@max_v151mapositiontaking_31 SMALLMONEY,
	@max_v151mapositiontaking_32 SMALLMONEY,
	@max_v151mapositiontaking_41 SMALLMONEY,
	@max_v151mapositiontaking_42 SMALLMONEY,
	@max_v151mapositiontaking_51 SMALLMONEY,
	@max_v151mapositiontaking_52 SMALLMONEY,
	@max_v152mapositiontaking_41 SMALLMONEY,
	@max_v152mapositiontaking_42 SMALLMONEY,
	@max_v152mapositiontaking_51 SMALLMONEY,
	@max_v152mapositiontaking_52 SMALLMONEY,
	@max_v153mapositiontaking_51 SMALLMONEY,
	@max_v153mapositiontaking_52 SMALLMONEY
	
DECLARE
	--n3
	@min_v151mapositiontaking_31 SMALLMONEY,
	@min_v151mapositiontaking_32 SMALLMONEY,
	@min_v151mapositiontaking_41 SMALLMONEY,
	@min_v151mapositiontaking_42 SMALLMONEY,
	@min_v151mapositiontaking_51 SMALLMONEY,
	@min_v151mapositiontaking_52 SMALLMONEY,
	@min_v152mapositiontaking_41 SMALLMONEY,
	@min_v152mapositiontaking_42 SMALLMONEY,
	@min_v152mapositiontaking_51 SMALLMONEY,
	@min_v152mapositiontaking_52 SMALLMONEY,
	@min_v153mapositiontaking_51 SMALLMONEY,
	@min_v153mapositiontaking_52 SMALLMONEY,
	
	--max_m1
	--max_m1 = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	@max_v151mp_31 smallmoney,
	@max_v151mp_32 smallmoney,
	@max_v151mp_41 smallmoney,
	@max_v151mp_42 smallmoney,
	@max_v151mp_51 smallmoney,
	@max_v151mp_52 smallmoney,
	@max_v152mp_41 smallmoney,
	@max_v152mp_42 smallmoney,
	@max_v152mp_51 smallmoney,
	@max_v152mp_52 smallmoney,
	@max_v153mp_51 smallmoney,
	@max_v153mp_52 smallmoney,
	
	--min_m1 = n3 -a1
	@min_v151mp_31 smallmoney,
	@min_v151mp_32 smallmoney,
	@min_v151mp_41 smallmoney,
	@min_v151mp_42 smallmoney,
	@min_v151mp_51 smallmoney,
	@min_v151mp_52 smallmoney,
	@min_v152mp_41 smallmoney,
	@min_v152mp_42 smallmoney,
	@min_v152mp_51 smallmoney,
	@min_v152mp_52 smallmoney,
	@min_v153mp_51 smallmoney,
	@min_v153mp_52 smallmoney



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
if @srecommend>100 and @custid<>79711
BEGIN
	declare @ErrMsg varchar(200)
	Select @ErrMsg = 'Sorry, please try again later.'
	RaisError (@ErrMsg, 16, 1)
	return
END
*/

--s1,a1,old_m1,u1,i1
IF (@UpdatePositiontakingv151_31 = 1)
	BEGIN
		SELECT @v151spositiontaking_31 = spositiontaking, @v151apositiontaking_31 = apositiontaking, @auto_v151spositiontaking_mem_31 = autopositiontaking, @isauto_v151spositiontaking_mem_31 = isautopositiontaking, @old_v151mpositiontaking_31 = mpositiontaking , @old_auto_v151mpositiontaking_mem_31 = autompositiontaking , @old_isauto_v151mpositiontaking_mem_31 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=31 AND sporttype=151
		SELECT @v151spositiontaking_32 = spositiontaking, @v151apositiontaking_32 = apositiontaking, @auto_v151spositiontaking_mem_32 = autopositiontaking, @isauto_v151spositiontaking_mem_32 = isautopositiontaking, @old_v151mpositiontaking_32 = mpositiontaking , @old_auto_v151mpositiontaking_mem_32 = autompositiontaking , @old_isauto_v151mpositiontaking_mem_32 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=32 AND sporttype=151
	END
IF (@UpdatePositiontakingv151_41 = 1)
	BEGIN
		SELECT @v151spositiontaking_41 = spositiontaking, @v151apositiontaking_41 = apositiontaking, @auto_v151spositiontaking_mem_41 = autopositiontaking, @isauto_v151spositiontaking_mem_41 = isautopositiontaking, @old_v151mpositiontaking_41 = mpositiontaking , @old_auto_v151mpositiontaking_mem_41 = autompositiontaking , @old_isauto_v151mpositiontaking_mem_41 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=41 AND sporttype=151
		SELECT @v151spositiontaking_42 = spositiontaking, @v151apositiontaking_42 = apositiontaking, @auto_v151spositiontaking_mem_42 = autopositiontaking, @isauto_v151spositiontaking_mem_42 = isautopositiontaking, @old_v151mpositiontaking_42 = mpositiontaking , @old_auto_v151mpositiontaking_mem_42 = autompositiontaking , @old_isauto_v151mpositiontaking_mem_42 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=42 AND sporttype=151
	END
IF @UpdatePositiontakingv151_51 = 1
	BEGIN
		SELECT @v151spositiontaking_51 = spositiontaking, @v151apositiontaking_51 = apositiontaking, @auto_v151spositiontaking_mem_51 = autopositiontaking, @isauto_v151spositiontaking_mem_51 = isautopositiontaking, @old_v151mpositiontaking_51 = mpositiontaking , @old_auto_v151mpositiontaking_mem_51 = autompositiontaking , @old_isauto_v151mpositiontaking_mem_51 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=51 AND sporttype=151
		SELECT @v151spositiontaking_52 = spositiontaking, @v151apositiontaking_52 = apositiontaking, @auto_v151spositiontaking_mem_52 = autopositiontaking, @isauto_v151spositiontaking_mem_52 = isautopositiontaking, @old_v151mpositiontaking_52 = mpositiontaking , @old_auto_v151mpositiontaking_mem_52 = autompositiontaking , @old_isauto_v151mpositiontaking_mem_52 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=52 AND sporttype=151
	END
IF (@UpdatePositiontakingv152_41 = 1)
	BEGIN	
		SELECT @v152spositiontaking_41 = spositiontaking, @v152apositiontaking_41 = apositiontaking, @auto_v152spositiontaking_mem_41 = autopositiontaking, @isauto_v152spositiontaking_mem_41 = isautopositiontaking, @old_v152mpositiontaking_41 = mpositiontaking , @old_auto_v152mpositiontaking_mem_41 = autompositiontaking , @old_isauto_v152mpositiontaking_mem_41 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=41 AND sporttype=152
		SELECT @v152spositiontaking_42 = spositiontaking, @v152apositiontaking_42 = apositiontaking, @auto_v152spositiontaking_mem_42 = autopositiontaking, @isauto_v152spositiontaking_mem_42 = isautopositiontaking, @old_v152mpositiontaking_42 = mpositiontaking , @old_auto_v152mpositiontaking_mem_42 = autompositiontaking , @old_isauto_v152mpositiontaking_mem_42 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=42 AND sporttype=152
	END
IF (@UpdatePositiontakingv152_51 = 1)
	BEGIN	
		SELECT @v152spositiontaking_51 = spositiontaking, @v152apositiontaking_51 = apositiontaking, @auto_v152spositiontaking_mem_51 = autopositiontaking, @isauto_v152spositiontaking_mem_51 = isautopositiontaking, @old_v152mpositiontaking_51 = mpositiontaking , @old_auto_v152mpositiontaking_mem_51 = autompositiontaking , @old_isauto_v152mpositiontaking_mem_51 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=51 AND sporttype=152
		SELECT @v152spositiontaking_52 = spositiontaking, @v152apositiontaking_52 = apositiontaking, @auto_v152spositiontaking_mem_52 = autopositiontaking, @isauto_v152spositiontaking_mem_52 = isautopositiontaking, @old_v152mpositiontaking_52 = mpositiontaking , @old_auto_v152mpositiontaking_mem_52 = autompositiontaking , @old_isauto_v152mpositiontaking_mem_52 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=52 AND sporttype=152
	END
IF (@UpdatePositiontakingv153_51 = 1)
	BEGIN	
		SELECT @v153spositiontaking_51 = spositiontaking, @v153apositiontaking_51 = apositiontaking, @auto_v153spositiontaking_mem_51 = autopositiontaking, @isauto_v153spositiontaking_mem_51 = isautopositiontaking, @old_v153mpositiontaking_51 = mpositiontaking , @old_auto_v153mpositiontaking_mem_51 = autompositiontaking , @old_isauto_v153mpositiontaking_mem_51 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=51 AND sporttype=153
		SELECT @v153spositiontaking_52 = spositiontaking, @v153apositiontaking_52 = apositiontaking, @auto_v153spositiontaking_mem_52 = autopositiontaking, @isauto_v153spositiontaking_mem_52 = isautopositiontaking, @old_v153mpositiontaking_52 = mpositiontaking , @old_auto_v153mpositiontaking_mem_52 = autompositiontaking , @old_isauto_v153mpositiontaking_mem_52 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=52 AND sporttype=153
	END

--Check if old_PT = new_PT return
IF @v151mpositiontaking_31 = @old_v151mpositiontaking_31 AND
	@v151mpositiontaking_32 = @old_v151mpositiontaking_32 AND
	@v151mpositiontaking_41 = @old_v151mpositiontaking_41 AND
	@v151mpositiontaking_42 = @old_v151mpositiontaking_42 AND
	@v151mpositiontaking_51 = @old_v151mpositiontaking_51 AND
	@v151mpositiontaking_52 = @old_v151mpositiontaking_52 AND
	@v152mpositiontaking_41 = @old_v152mpositiontaking_41 AND
	@v152mpositiontaking_42 = @old_v152mpositiontaking_42 AND
	@v152mpositiontaking_51 = @old_v152mpositiontaking_51 AND
	@v152mpositiontaking_52 = @old_v152mpositiontaking_52 AND
	@v153mpositiontaking_51 = @old_v153mpositiontaking_51 AND
	@v153mpositiontaking_52 = @old_v153mpositiontaking_52 AND
	--um1
	@auto_v151mpositiontaking_mem_31 = @old_auto_v151mpositiontaking_mem_31 AND
	@auto_v151mpositiontaking_mem_32 = @old_auto_v151mpositiontaking_mem_32 AND
	@auto_v151mpositiontaking_mem_41 = @old_auto_v151mpositiontaking_mem_41 AND
	@auto_v151mpositiontaking_mem_42 = @old_auto_v151mpositiontaking_mem_42 AND
	@auto_v151mpositiontaking_mem_51 = @old_auto_v151mpositiontaking_mem_51 AND
	@auto_v151mpositiontaking_mem_52 = @old_auto_v151mpositiontaking_mem_52 AND
	@auto_v152mpositiontaking_mem_41 = @old_auto_v152mpositiontaking_mem_41 AND
	@auto_v152mpositiontaking_mem_42 = @old_auto_v152mpositiontaking_mem_42 AND
	@auto_v152mpositiontaking_mem_51 = @old_auto_v152mpositiontaking_mem_51 AND
	@auto_v152mpositiontaking_mem_52 = @old_auto_v152mpositiontaking_mem_52 AND
	@auto_v153mpositiontaking_mem_51 = @old_auto_v153mpositiontaking_mem_51 AND
	@auto_v153mpositiontaking_mem_52 = @old_auto_v153mpositiontaking_mem_52 AND
	--im1
	@isauto_v151mpositiontaking_mem_31 = @old_isauto_v151mpositiontaking_mem_31 AND
	@isauto_v151mpositiontaking_mem_32 = @old_isauto_v151mpositiontaking_mem_32 AND
	@isauto_v151mpositiontaking_mem_41 = @old_isauto_v151mpositiontaking_mem_41 AND
	@isauto_v151mpositiontaking_mem_42 = @old_isauto_v151mpositiontaking_mem_42 AND 
	@isauto_v151mpositiontaking_mem_51 = @old_isauto_v151mpositiontaking_mem_51 AND
	@isauto_v151mpositiontaking_mem_52 = @old_isauto_v151mpositiontaking_mem_52 AND
	@isauto_v152mpositiontaking_mem_41 = @old_isauto_v152mpositiontaking_mem_41 AND
	@isauto_v152mpositiontaking_mem_42 = @old_isauto_v152mpositiontaking_mem_42 AND
	@isauto_v152mpositiontaking_mem_51 = @old_isauto_v152mpositiontaking_mem_51 AND
	@isauto_v152mpositiontaking_mem_52 = @old_isauto_v152mpositiontaking_mem_52 AND
	@isauto_v153mpositiontaking_mem_51 = @old_isauto_v153mpositiontaking_mem_51 AND
	@isauto_v153mpositiontaking_mem_52 = @old_isauto_v153mpositiontaking_mem_52 
BEGIN	
	Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
	RETURN 
END
			
--m3,u3,i3
IF ( @UpdatePositiontakingv151_31 = 1 )
	BEGIN
		SELECT @max_v151mapositiontaking_31 =mpositiontaking, @auto_v151spositiontaking_31 = autopositiontaking, @isauto_v151spositiontaking_31 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=31 AND sporttype=151
		SELECT @max_v151mapositiontaking_32 =mpositiontaking, @auto_v151spositiontaking_32 = autopositiontaking, @isauto_v151spositiontaking_32 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=32 AND sporttype=151
	END
IF ( @UpdatePositiontakingv151_41 = 1 )
	BEGIN
		SELECT @max_v151mapositiontaking_41 =mpositiontaking, @auto_v151spositiontaking_41 = autopositiontaking, @isauto_v151spositiontaking_41 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=41 AND sporttype=151
		SELECT @max_v151mapositiontaking_42 =mpositiontaking, @auto_v151spositiontaking_42 = autopositiontaking, @isauto_v151spositiontaking_42 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=42 AND sporttype=151
	END
IF ( @UpdatePositiontakingv151_51 = 1 )
	BEGIN
		SELECT @max_v151mapositiontaking_51 =mpositiontaking, @auto_v151spositiontaking_51 = autopositiontaking, @isauto_v151spositiontaking_51 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=51 AND sporttype=151
		SELECT @max_v151mapositiontaking_52 =mpositiontaking, @auto_v151spositiontaking_52 = autopositiontaking, @isauto_v151spositiontaking_52 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=52 AND sporttype=151
	END
IF ( @UpdatePositiontakingv152_41 = 1 )
	BEGIN	
		SELECT @max_v152mapositiontaking_41 =mpositiontaking, @auto_v152spositiontaking_41 = autopositiontaking, @isauto_v152spositiontaking_41 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=41 AND sporttype=152
		SELECT @max_v152mapositiontaking_42 =mpositiontaking, @auto_v152spositiontaking_42 = autopositiontaking, @isauto_v152spositiontaking_42 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=42 AND sporttype=152
	END
IF ( @UpdatePositiontakingv152_51 = 1 )
	BEGIN
		SELECT @max_v152mapositiontaking_51 =mpositiontaking, @auto_v152spositiontaking_51 = autopositiontaking, @isauto_v152spositiontaking_51 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=51 AND sporttype=152
		SELECT @max_v152mapositiontaking_52 =mpositiontaking, @auto_v152spositiontaking_52 = autopositiontaking, @isauto_v152spositiontaking_52 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=52 AND sporttype=152
	END
IF ( @UpdatePositiontakingv153_51 = 1 )
	BEGIN
		SELECT @max_v153mapositiontaking_51 =mpositiontaking, @auto_v153spositiontaking_51 = autopositiontaking, @isauto_v153spositiontaking_51 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=51 AND sporttype=153
		SELECT @max_v153mapositiontaking_52 =mpositiontaking, @auto_v153spositiontaking_52 = autopositiontaking, @isauto_v153spositiontaking_52 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=52 AND sporttype=153
	END
--n3
IF ( @UpdatePositiontakingv151_31 = 1 )
	BEGIN
		SELECT @min_v151mapositiontaking_31 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=31 AND sporttype=151
		SELECT @min_v151mapositiontaking_32 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=32 AND sporttype=151
	END
IF ( @UpdatePositiontakingv151_41 = 1 )
	BEGIN		
		SELECT @min_v151mapositiontaking_41 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=41 AND sporttype=151
		SELECT @min_v151mapositiontaking_42 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=42 AND sporttype=151
	END	
IF ( @UpdatePositiontakingv151_51 = 1 )
	BEGIN		
		SELECT @min_v151mapositiontaking_51 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=51 AND sporttype=151
		SELECT @min_v151mapositiontaking_52 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=52 AND sporttype=151
	END	
IF ( @UpdatePositiontakingv152_41 = 1 )
	BEGIN		
		SELECT @min_v152mapositiontaking_41 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=41 AND sporttype=152
		SELECT @min_v152mapositiontaking_42 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=42 AND sporttype=152
	END	
IF ( @UpdatePositiontakingv152_51 = 1 )
	BEGIN		
		SELECT @min_v152mapositiontaking_51 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=51 AND sporttype=152
		SELECT @min_v152mapositiontaking_52 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=52 AND sporttype=152
	END	
IF ( @UpdatePositiontakingv153_51 = 1 )
	BEGIN		
		SELECT @min_v153mapositiontaking_51 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=51 AND sporttype=153
		SELECT @min_v153mapositiontaking_52 = minpositiontaking FROM CustOverride3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype=52 AND sporttype=153
	END
--s4
IF ( @UpdatePositiontakingv151_31 = 1 )
	BEGIN
		SELECT @max_v151spositiontaking_31 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=31 AND sporttype=151
		SELECT @max_v151spositiontaking_32 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=32 AND sporttype=151
	END	
IF ( @UpdatePositiontakingv151_41 = 1 )
	BEGIN		
		SELECT @max_v151spositiontaking_41 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=41 AND sporttype=151
		SELECT @max_v151spositiontaking_42 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=42 AND sporttype=151
	END	
IF ( @UpdatePositiontakingv151_51 = 1 )
	BEGIN		
		SELECT @max_v151spositiontaking_51 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=51 AND sporttype=151
		SELECT @max_v151spositiontaking_52 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=52 AND sporttype=151
	END	
IF ( @UpdatePositiontakingv152_41 = 1 )
	BEGIN		
		SELECT @max_v152spositiontaking_41 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=41 AND sporttype=152
		SELECT @max_v152spositiontaking_42 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=42 AND sporttype=152
	END	
IF ( @UpdatePositiontakingv152_51 = 1 )
	BEGIN		
		SELECT @max_v152spositiontaking_51 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=51 AND sporttype=152
		SELECT @max_v152spositiontaking_52 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=52 AND sporttype=152
	END
IF ( @UpdatePositiontakingv153_51 = 1 )
	BEGIN
		SELECT @max_v153spositiontaking_51 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=51 AND sporttype=153
		SELECT @max_v153spositiontaking_52 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype=52 AND sporttype=153
	END
	
	/*
	--calculate m1_max = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	Select
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
		@max_v151mp_31 = max(case when cs.bettype = 31 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_31 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v151spositiontaking_31 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v151mp_32 = max(case when cs.bettype = 32 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_32 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v151spositiontaking_32 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v151mp_41 = max(case when cs.bettype = 41 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_41 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v151spositiontaking_41 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v151mp_42 = max(case when cs.bettype = 42 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_42 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v151spositiontaking_42 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v151mp_51 = max(case when cs.bettype = 51 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_51 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v151spositiontaking_51 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v151mp_52 = max(case when cs.bettype = 52 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_52 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v151spositiontaking_52 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v152mp_41 = max(case when cs.bettype = 41 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v152spositiontaking_41 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v152spositiontaking_41 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v152mp_42 = max(case when cs.bettype = 42 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v152spositiontaking_42 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v152spositiontaking_42 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v152mp_51 = max(case when cs.bettype = 51 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_51 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v152spositiontaking_51 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v152mp_52 = max(case when cs.bettype = 52 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v151spositiontaking_52 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v152spositiontaking_52 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v153mp_51 = max(case when cs.bettype = 51 and cs.sporttype = 153 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v153spositiontaking_51 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v153spositiontaking_51 - cs.spositiontaking-cs.apositiontaking end end else 0 end),
		@max_v153mp_52 = max(case when cs.bettype = 52 and cs.sporttype = 153 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@max_v153spositiontaking_52 - cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @max_v153spositiontaking_52 - cs.spositiontaking-cs.apositiontaking end end else 0 end)
	From CustSetting3rd as cs with (NOLOCK) 
		inner join custinfo as c with (nolock) on cs.custid = c.custid
		inner join CustSetting3rd as mcs with (nolock) on mcs.custid = c.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype =cs.bettype
	where cs.custid = @custid and cs.sporttype BETWEEN 151 AND 153
	
	--@max_mp = min[@max_mp,min(m3,l3)-a1]	
	select @max_v151mp_31 = CASE WHEN @max_v151mp_31 < @max_v151mapositiontaking_31 - @v151apositiontaking_31 THEN @max_v151mp_31 ELSE @max_v151mapositiontaking_31 - @v151apositiontaking_31 END
	select @max_v151mp_32 = CASE WHEN @max_v151mp_32 < @max_v151mapositiontaking_32 - @v151apositiontaking_32 THEN @max_v151mp_32 ELSE @max_v151mapositiontaking_32 - @v151apositiontaking_32 END
	select @max_v151mp_41 = CASE WHEN @max_v151mp_41 < @max_v151mapositiontaking_41 - @v151apositiontaking_41 THEN @max_v151mp_41 ELSE @max_v151mapositiontaking_41 - @v151apositiontaking_41 END
	select @max_v151mp_42 = CASE WHEN @max_v151mp_42 < @max_v151mapositiontaking_42 - @v151apositiontaking_42 THEN @max_v151mp_42 ELSE @max_v151mapositiontaking_42 - @v151apositiontaking_42 END
	select @max_v151mp_51 = CASE WHEN @max_v151mp_51 < @max_v151mapositiontaking_51 - @v151apositiontaking_51 THEN @max_v151mp_51 ELSE @max_v151mapositiontaking_51 - @v151apositiontaking_51 END
	select @max_v151mp_52 = CASE WHEN @max_v151mp_52 < @max_v151mapositiontaking_52 - @v151apositiontaking_52 THEN @max_v151mp_52 ELSE @max_v151mapositiontaking_52 - @v151apositiontaking_52 END
	
	select @max_v152mp_41 = CASE WHEN @max_v152mp_41 < @max_v152mapositiontaking_41 - @v152apositiontaking_41 THEN @max_v152mp_41 ELSE @max_v152mapositiontaking_41 - @v152apositiontaking_41 END
	select @max_v152mp_42 = CASE WHEN @max_v152mp_42 < @max_v152mapositiontaking_42 - @v152apositiontaking_42 THEN @max_v152mp_42 ELSE @max_v152mapositiontaking_42 - @v152apositiontaking_42 END
	select @max_v152mp_51 = CASE WHEN @max_v152mp_51 < @max_v152mapositiontaking_51 - @v152apositiontaking_51 THEN @max_v152mp_51 ELSE @max_v152mapositiontaking_51 - @v152apositiontaking_51 END
	select @max_v152mp_52 = CASE WHEN @max_v152mp_52 < @max_v152mapositiontaking_52 - @v152apositiontaking_52 THEN @max_v152mp_52 ELSE @max_v152mapositiontaking_52 - @v152apositiontaking_52 END
	
	select @max_v153mp_51 = CASE WHEN @max_v153mp_51 < @max_v153mapositiontaking_51 - @v153apositiontaking_51 THEN @max_v153mp_51 ELSE @max_v153mapositiontaking_51 - @v153apositiontaking_51 END
	select @max_v153mp_52 = CASE WHEN @max_v153mp_52 < @max_v153mapositiontaking_52 - @v153apositiontaking_52 THEN @max_v153mp_52 ELSE @max_v153mapositiontaking_52 - @v153apositiontaking_52 END
*/
	--m1_max = m3- a1
	select @max_v151mp_31 = @max_v151mapositiontaking_31 - @v151apositiontaking_31
	select @max_v151mp_32 = @max_v151mapositiontaking_32 - @v151apositiontaking_32
	select @max_v151mp_41 = @max_v151mapositiontaking_41 - @v151apositiontaking_41
	select @max_v151mp_42 = @max_v151mapositiontaking_42 - @v151apositiontaking_42
	select @max_v151mp_51 = @max_v151mapositiontaking_51 - @v151apositiontaking_51
	select @max_v151mp_52 = @max_v151mapositiontaking_52 - @v151apositiontaking_52
	
	select @max_v152mp_41 = @max_v152mapositiontaking_41 - @v152apositiontaking_41
	select @max_v152mp_42 = @max_v152mapositiontaking_42 - @v152apositiontaking_42
	select @max_v152mp_51 = @max_v152mapositiontaking_51 - @v152apositiontaking_51
	select @max_v152mp_52 = @max_v152mapositiontaking_52 - @v152apositiontaking_52
	
	select @max_v153mp_51 = @max_v153mapositiontaking_51 - @v153apositiontaking_51
	select @max_v153mp_52 = @max_v153mapositiontaking_52 - @v153apositiontaking_52
	
	--m1_min = max(n3- a1,0)
	select @min_v151mp_31 = case when @min_v151mapositiontaking_31 - @v151apositiontaking_31 > 0 THEN @min_v151mapositiontaking_31 - @v151apositiontaking_31 ELSE 0 END
	select @min_v151mp_32 = case when @min_v151mapositiontaking_32 - @v151apositiontaking_32 > 0 THEN @min_v151mapositiontaking_32 - @v151apositiontaking_32 ELSE 0 END
	select @min_v151mp_41 = case when @min_v151mapositiontaking_41 - @v151apositiontaking_41 > 0 THEN @min_v151mapositiontaking_41 - @v151apositiontaking_41 ELSE 0 END
	select @min_v151mp_42 = case when @min_v151mapositiontaking_42 - @v151apositiontaking_42 > 0 THEN @min_v151mapositiontaking_42 - @v151apositiontaking_42 ELSE 0 END
	select @min_v151mp_51 = case when @min_v151mapositiontaking_51 - @v151apositiontaking_51 > 0 THEN @min_v151mapositiontaking_51 - @v151apositiontaking_51 ELSE 0 END
	select @min_v151mp_52 = case when @min_v151mapositiontaking_52 - @v151apositiontaking_52 > 0 THEN @min_v151mapositiontaking_52 - @v151apositiontaking_52 ELSE 0 END
	
	select @min_v152mp_41 = case when @min_v152mapositiontaking_41 - @v152apositiontaking_41 > 0 THEN @min_v152mapositiontaking_41 - @v152apositiontaking_41 ELSE 0 END
	select @min_v152mp_42 = case when @min_v152mapositiontaking_42 - @v152apositiontaking_42 > 0 THEN @min_v152mapositiontaking_42 - @v152apositiontaking_42 ELSE 0 END
	select @min_v152mp_51 = case when @min_v152mapositiontaking_51 - @v152apositiontaking_51 > 0 THEN @min_v152mapositiontaking_51 - @v152apositiontaking_51 ELSE 0 END
	select @min_v152mp_52 = case when @min_v152mapositiontaking_52 - @v152apositiontaking_52 > 0 THEN @min_v152mapositiontaking_52 - @v152apositiontaking_52 ELSE 0 END
	
	select @min_v153mp_51 = case when @min_v153mapositiontaking_51 - @v153apositiontaking_51 > 0 THEN @min_v153mapositiontaking_51 - @v153apositiontaking_51 ELSE 0 END
	select @min_v153mp_52 = case when @min_v153mapositiontaking_52 - @v153apositiontaking_52 > 0 THEN @min_v153mapositiontaking_52 - @v153apositiontaking_52 ELSE 0 END
	
--um2,im2
SELECT 
	@isauto_v151mpositiontaking_31 = MAX(CASE WHEN acs.bettype = 31 AND acs.sporttype=151 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v151mpositiontaking_32 = MAX(CASE WHEN acs.bettype = 32 AND acs.sporttype=151 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v151mpositiontaking_41 = MAX(CASE WHEN acs.bettype = 41 AND acs.sporttype=151 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v151mpositiontaking_42 = MAX(CASE WHEN acs.bettype = 42 AND acs.sporttype=151 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v151mpositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=151 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v151mpositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=151 THEN acs.isautompositiontaking ELSE 0 END),
	
	@isauto_v152mpositiontaking_41 = MAX(CASE WHEN acs.bettype = 41 AND acs.sporttype=152 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v152mpositiontaking_42 = MAX(CASE WHEN acs.bettype = 42 AND acs.sporttype=152 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v152mpositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=152 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v152mpositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=152 THEN acs.isautompositiontaking ELSE 0 END),
	
	@isauto_v153mpositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=153 THEN acs.isautompositiontaking ELSE 0 END),
	@isauto_v153mpositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=153 THEN acs.isautompositiontaking ELSE 0 END),
	
	@auto_v151mpositiontaking_31 = MAX(CASE WHEN acs.bettype = 31 AND acs.sporttype=151 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v151mpositiontaking_32 = MAX(CASE WHEN acs.bettype = 32 AND acs.sporttype=151 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v151mpositiontaking_41 = MAX(CASE WHEN acs.bettype = 41 AND acs.sporttype=151 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v151mpositiontaking_42 = MAX(CASE WHEN acs.bettype = 42 AND acs.sporttype=151 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v151mpositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=151 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v151mpositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=151 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v152mpositiontaking_41 = MAX(CASE WHEN acs.bettype = 41 AND acs.sporttype=152 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v152mpositiontaking_42 = MAX(CASE WHEN acs.bettype = 42 AND acs.sporttype=152 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v152mpositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=152 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v152mpositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=152 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v153mpositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=153 THEN acs.autompositiontaking ELSE 0 END),
	@auto_v153mpositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=153 THEN acs.autompositiontaking ELSE 0 END),
	--a2	
	@max_v151apositiontaking_31 = MAX(CASE WHEN acs.bettype = 31 AND acs.sporttype=151 THEN acs.apositiontaking ELSE 0 END),
	@max_v151apositiontaking_32 = MAX(CASE WHEN acs.bettype = 32 AND acs.sporttype=151 THEN acs.apositiontaking ELSE 0 END),
	@max_v151apositiontaking_41 = MAX(CASE WHEN acs.bettype = 41 AND acs.sporttype=151 THEN acs.apositiontaking ELSE 0 END),
	@max_v151apositiontaking_42 = MAX(CASE WHEN acs.bettype = 42 AND acs.sporttype=151 THEN acs.apositiontaking ELSE 0 END),
	@max_v151apositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=151 THEN acs.apositiontaking ELSE 0 END),
	@max_v151apositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=151 THEN acs.apositiontaking ELSE 0 END),
	@max_v152apositiontaking_41 = MAX(CASE WHEN acs.bettype = 41 AND acs.sporttype=152 THEN acs.apositiontaking ELSE 0 END),
	@max_v152apositiontaking_42 = MAX(CASE WHEN acs.bettype = 42 AND acs.sporttype=152 THEN acs.apositiontaking ELSE 0 END),
	@max_v152apositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=152 THEN acs.apositiontaking ELSE 0 END),
	@max_v152apositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=152 THEN acs.apositiontaking ELSE 0 END),
	@max_v153apositiontaking_51 = MAX(CASE WHEN acs.bettype = 51 AND acs.sporttype=153 THEN acs.apositiontaking ELSE 0 END),
	@max_v153apositiontaking_52 = MAX(CASE WHEN acs.bettype = 52 AND acs.sporttype=153 THEN acs.apositiontaking ELSE 0 END)
FROM CustSetting3rd acs WITH(NOLOCK)
WHERE acs.custid = @recommend
		and acs.sporttype in (151,152,153)

-- backup
	SELECT 
	@isauto_v151mpositiontaking_agent_31 = @isauto_v151mpositiontaking_31,
	@isauto_v151mpositiontaking_agent_32 = @isauto_v151mpositiontaking_32,
	@isauto_v151mpositiontaking_agent_41 = @isauto_v151mpositiontaking_41,
	@isauto_v151mpositiontaking_agent_42 = @isauto_v151mpositiontaking_42,
	@isauto_v151mpositiontaking_agent_51 = @isauto_v151mpositiontaking_51,
	@isauto_v151mpositiontaking_agent_52 = @isauto_v151mpositiontaking_52,
	@isauto_v152mpositiontaking_agent_41 = @isauto_v152mpositiontaking_41,
	@isauto_v152mpositiontaking_agent_42 = @isauto_v152mpositiontaking_42,
	@isauto_v152mpositiontaking_agent_51 = @isauto_v152mpositiontaking_51,
	@isauto_v152mpositiontaking_agent_52 = @isauto_v152mpositiontaking_52,
	@isauto_v153mpositiontaking_agent_51 = @isauto_v153mpositiontaking_51,
	@isauto_v153mpositiontaking_agent_52 = @isauto_v153mpositiontaking_52

if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
	BEGIN --@UpdatePositiontakingv151
		--Check um1<=l3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+
			case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
			 + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10)) + '<br>'
			FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN
				(
									SELECT 151 AS sporttype, 31 AS bettype, @auto_v151mpositiontaking_mem_31 AS autopositiontaking, @isauto_v151mpositiontaking_mem_31 AS isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype, 32 AS bettype, @auto_v151mpositiontaking_mem_32 AS autopositiontaking, @isauto_v151mpositiontaking_mem_32 AS isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype, 41 AS bettype, @auto_v151mpositiontaking_mem_41 AS autopositiontaking, @isauto_v151mpositiontaking_mem_41 AS isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype, 42 AS bettype, @auto_v151mpositiontaking_mem_42 AS autopositiontaking, @isauto_v151mpositiontaking_mem_42 AS isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype, 51 AS bettype, @auto_v151mpositiontaking_mem_51 AS autopositiontaking, @isauto_v151mpositiontaking_mem_51 AS isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
					UNION ALL		SELECT 151 AS sporttype, 52 AS bettype, @auto_v151mpositiontaking_mem_52 AS autopositiontaking, @isauto_v151mpositiontaking_mem_52 AS isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid

			WHERE co.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking)

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 6,
					   @ErrMsg_cur = CASE @Language 
											WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
									END
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
									
				RETURN
			END	

			--Check um1<=m3
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+
			case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
			+ '-Max: '+ CAST((mcs.mpositiontaking) AS VARCHAR(10)) + '<br>'
			FROM CustSetting3rd AS mcs WITH (NOLOCK) INNER JOIN
				(
									SELECT 151 AS sporttype, 31 AS bettype, @auto_v151mpositiontaking_mem_31 AS autopositiontaking, @isauto_v151mpositiontaking_mem_31 AS isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype, 32 AS bettype, @auto_v151mpositiontaking_mem_32 AS autopositiontaking, @isauto_v151mpositiontaking_mem_32 AS isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype, 41 AS bettype, @auto_v151mpositiontaking_mem_41 AS autopositiontaking, @isauto_v151mpositiontaking_mem_41 AS isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype, 42 AS bettype, @auto_v151mpositiontaking_mem_42 AS autopositiontaking, @isauto_v151mpositiontaking_mem_42 AS isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype, 51 AS bettype, @auto_v151mpositiontaking_mem_51 AS autopositiontaking, @isauto_v151mpositiontaking_mem_51 AS isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
					UNION ALL		SELECT 151 AS sporttype, 52 AS bettype, @auto_v151mpositiontaking_mem_52 AS autopositiontaking, @isauto_v151mpositiontaking_mem_52 AS isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
				) AS b ON mcs.sporttype=b.sporttype AND mcs.bettype=b.bettype
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
			WHERE mcs.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>mcs.mpositiontaking) 

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 7,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
				RETURN
			END
			
			--Check um1>=um1_min (=m1_min)
			SELECT @ErrType = ''
			SELECT @ErrType = @ErrType + sportname + '-'+
			case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
			+ '-Min: '+ CAST((b.minpositiontaking) AS VARCHAR(10)) + '<br>'
			FROM 
				(
									SELECT 151 AS sporttype, 31 AS bettype, @auto_v151mpositiontaking_mem_31 AS autopositiontaking, @isauto_v151mpositiontaking_mem_31 AS isautopositiontaking, @min_v151mp_31 as minpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype, 32 AS bettype, @auto_v151mpositiontaking_mem_32 AS autopositiontaking, @isauto_v151mpositiontaking_mem_32 AS isautopositiontaking, @min_v151mp_32 as minpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype, 41 AS bettype, @auto_v151mpositiontaking_mem_41 AS autopositiontaking, @isauto_v151mpositiontaking_mem_41 AS isautopositiontaking, @min_v151mp_41 as minpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype, 42 AS bettype, @auto_v151mpositiontaking_mem_42 AS autopositiontaking, @isauto_v151mpositiontaking_mem_42 AS isautopositiontaking, @min_v151mp_42 as minpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype, 51 AS bettype, @auto_v151mpositiontaking_mem_51 AS autopositiontaking, @isauto_v151mpositiontaking_mem_51 AS isautopositiontaking, @min_v151mp_51 as minpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
					UNION ALL		SELECT 151 AS sporttype, 52 AS bettype, @auto_v151mpositiontaking_mem_52 AS autopositiontaking, @isauto_v151mpositiontaking_mem_52 AS isautopositiontaking, @min_v151mp_52 as minpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
				) AS b 
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
			WHERE (b.isautopositiontaking>0 AND b.autopositiontaking<b.minpositiontaking) 

			IF @ErrType <>''
			BEGIN
				SELECT @ErrCode_cur = 11,
					   @ErrMsg_cur = @UserName + ': '+
									CASE @Language 
										WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
									END							
				SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
				RETURN
			END
	END--@UpdatePositiontakingv151
	
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
	BEGIN --@UpdatePositiontakingv152
		--Check um1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN
			(
								SELECT 152 AS sporttype, 41 AS bettype, @auto_v152mpositiontaking_mem_41 AS autopositiontaking, @isauto_v152mpositiontaking_mem_41 AS isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype, 42 AS bettype, @auto_v152mpositiontaking_mem_42 AS autopositiontaking, @isauto_v152mpositiontaking_mem_42 AS isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype, 51 AS bettype, @auto_v152mpositiontaking_mem_51 AS autopositiontaking, @isauto_v152mpositiontaking_mem_51 AS isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				UNION ALL		SELECT 152 AS sporttype, 52 AS bettype, @auto_v152mpositiontaking_mem_52 AS autopositiontaking, @isauto_v152mpositiontaking_mem_52 AS isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1

			) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid

		WHERE co.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking)

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 6,
				   @ErrMsg_cur = CASE @Language 
										WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
								END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
								
			RETURN
		END	

		--Check um1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((mcs.mpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM CustSetting3rd AS mcs WITH (NOLOCK) INNER JOIN
			(
								SELECT 152 AS sporttype, 41 AS bettype, @auto_v152mpositiontaking_mem_41 AS autopositiontaking, @isauto_v152mpositiontaking_mem_41 AS isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype, 42 AS bettype, @auto_v152mpositiontaking_mem_42 AS autopositiontaking, @isauto_v152mpositiontaking_mem_42 AS isautopositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype, 51 AS bettype, @auto_v152mpositiontaking_mem_51 AS autopositiontaking, @isauto_v152mpositiontaking_mem_51 AS isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				UNION ALL		SELECT 152 AS sporttype, 52 AS bettype, @auto_v152mpositiontaking_mem_52 AS autopositiontaking, @isauto_v152mpositiontaking_mem_52 AS isautopositiontaking WHERE @UpdatePositiontakingv152_51 = 1

			) AS b ON mcs.sporttype=b.sporttype AND mcs.bettype=b.bettype
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE mcs.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>mcs.mpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 7,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		
		--Check um1>=um1_min (=m1_min)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Min: '+ CAST((b.minpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM 
			(
								SELECT 152 AS sporttype, 41 AS bettype, @auto_v152mpositiontaking_mem_41 AS autopositiontaking, @isauto_v152mpositiontaking_mem_41 AS isautopositiontaking, @min_v152mp_41 as minpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype, 42 AS bettype, @auto_v152mpositiontaking_mem_42 AS autopositiontaking, @isauto_v152mpositiontaking_mem_42 AS isautopositiontaking, @min_v152mp_42 as minpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype, 51 AS bettype, @auto_v152mpositiontaking_mem_51 AS autopositiontaking, @isauto_v152mpositiontaking_mem_51 AS isautopositiontaking, @min_v152mp_51 as minpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				UNION ALL		SELECT 152 AS sporttype, 52 AS bettype, @auto_v152mpositiontaking_mem_52 AS autopositiontaking, @isauto_v152mpositiontaking_mem_52 AS isautopositiontaking, @min_v152mp_52 as minpositiontaking WHERE @UpdatePositiontakingv152_51 = 1

			) AS b 
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.isautopositiontaking>0 AND b.autopositiontaking < b.minpositiontaking

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 11,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
	END--@UpdatePositiontakingv152
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
	BEGIN --@UpdatePositiontakingv153
		--Check um1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN
			(
								SELECT 153 AS sporttype, 51 AS bettype, @auto_v153mpositiontaking_mem_51 AS autopositiontaking, @isauto_v153mpositiontaking_mem_51 AS isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
				UNION ALL		SELECT 153 AS sporttype, 52 AS bettype, @auto_v153mpositiontaking_mem_52 AS autopositiontaking, @isauto_v153mpositiontaking_mem_52 AS isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid

		WHERE co.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>co.maxpositiontaking)

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 6,
				   @ErrMsg_cur = CASE @Language 
										WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
										ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
								END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
								
			RETURN
		END	

		--Check um1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((mcs.mpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM CustSetting3rd AS mcs WITH (NOLOCK) INNER JOIN
			(
								SELECT 153 AS sporttype, 51 AS bettype, @auto_v153mpositiontaking_mem_51 AS autopositiontaking, @isauto_v153mpositiontaking_mem_51 AS isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
				UNION ALL		SELECT 153 AS sporttype, 52 AS bettype, @auto_v153mpositiontaking_mem_52 AS autopositiontaking, @isauto_v153mpositiontaking_mem_52 AS isautopositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			) AS b ON mcs.sporttype=b.sporttype AND mcs.bettype=b.bettype
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE mcs.custid = @mrecommend AND (b.isautopositiontaking>0 AND b.autopositiontaking>mcs.mpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 7,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		
		--Check um1>=um1_min (=m1_min)
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Min: '+ CAST((b.minpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM 
			(
								SELECT 153 AS sporttype, 51 AS bettype, @auto_v153mpositiontaking_mem_51 AS autopositiontaking, @isauto_v153mpositiontaking_mem_51 AS isautopositiontaking, @min_v153mp_51 as minpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
				UNION ALL		SELECT 153 AS sporttype, 52 AS bettype, @auto_v153mpositiontaking_mem_52 AS autopositiontaking, @isauto_v153mpositiontaking_mem_52 AS isautopositiontaking, @min_v153mp_51 as minpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			) AS b
		INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.isautopositiontaking>0 AND b.autopositiontaking<b.minpositiontaking

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 11,
				   @ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong auto position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
	END--@UpdatePositiontakingv153

if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
	BEGIN --@UpdatePositiontakingv151
		--Check m1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10)) + '<br>'
		FROM (
								SELECT 151 AS sporttype	,	 31 AS bettype	,	 @v151mpositiontaking_31 AS mpositiontaking	,	 @max_v151mapositiontaking_31 AS maxmpositiontaking	WHERE @UpdatePositiontakingv151_31 = 1
				UNION ALL		SELECT 151 AS sporttype	,	 32 AS bettype	,	 @v151mpositiontaking_32 AS mpositiontaking	,	 @max_v151mapositiontaking_32 AS maxmpositiontaking	WHERE @UpdatePositiontakingv151_31 = 1
				UNION ALL		SELECT 151 AS sporttype	,	 41 AS bettype	,	 @v151mpositiontaking_41 AS mpositiontaking	,	 @max_v151mapositiontaking_41 AS maxmpositiontaking	WHERE @UpdatePositiontakingv151_41 = 1
				UNION ALL		SELECT 151 AS sporttype	,	 42 AS bettype	,	 @v151mpositiontaking_42 AS mpositiontaking	,	 @max_v151mapositiontaking_42 AS maxmpositiontaking	WHERE @UpdatePositiontakingv151_41 = 1
				UNION ALL		SELECT 151 AS sporttype	,	 51 AS bettype	,	 @v151mpositiontaking_51 AS mpositiontaking	,	 @max_v151mapositiontaking_51 AS maxmpositiontaking	WHERE @UpdatePositiontakingv151_51 = 1
				UNION ALL		SELECT 151 AS sporttype	,	 52 AS bettype	,	 @v151mpositiontaking_52 AS mpositiontaking	,	 @max_v151mapositiontaking_52 AS maxmpositiontaking	WHERE @UpdatePositiontakingv151_51 = 1
		)b 	
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE (b.mpositiontaking>b.maxmpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		--Check m1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10)) + '<br>'
			FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN
				(
									SELECT 151 AS sporttype	,	 31 AS bettype	,	 @v151mpositiontaking_31 AS mpositiontaking	WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype	,	 32 AS bettype	,	 @v151mpositiontaking_32 AS mpositiontaking	WHERE @UpdatePositiontakingv151_31 = 1
					UNION ALL		SELECT 151 AS sporttype	,	 41 AS bettype	,	 @v151mpositiontaking_41 AS mpositiontaking	WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype	,	 42 AS bettype	,	 @v151mpositiontaking_42 AS mpositiontaking	WHERE @UpdatePositiontakingv151_41 = 1
					UNION ALL		SELECT 151 AS sporttype	,	 51 AS bettype	,	 @v151mpositiontaking_51 AS mpositiontaking	WHERE @UpdatePositiontakingv151_51 = 1
					UNION ALL		SELECT 151 AS sporttype	,	 52 AS bettype	,	 @v151mpositiontaking_52 AS mpositiontaking	WHERE @UpdatePositiontakingv151_51 = 1
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE co.custid = @mrecommend AND (b.mpositiontaking>co.maxpositiontaking) 
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 9,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1 <= m1_max
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((b.mpositiontaking_max) AS VARCHAR(10)) + '<br>'
		FROM 
			(
				SELECT 151 as sporttype, 31 as bettype, @isauto_v151mpositiontaking_31 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_31 as isautompositiontaking_mem, @v151mpositiontaking_31 as mpositiontaking, @max_v151mp_31 as mpositiontaking_max WHERE @UpdatePositiontakingv151_31 = 1
				UNION ALL SELECT 151 as sporttype, 32 as bettype, @isauto_v151mpositiontaking_32 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_32 as isautompositiontaking_mem, @v151mpositiontaking_32 as mpositiontaking, @max_v151mp_32 as mpositiontaking_max WHERE @UpdatePositiontakingv151_31 = 1
				UNION ALL SELECT 151 as sporttype, 41 as bettype, @isauto_v151mpositiontaking_41 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_41 as isautompositiontaking_mem, @v151mpositiontaking_41 as mpositiontaking, @max_v151mp_41 as mpositiontaking_max WHERE @UpdatePositiontakingv151_41 = 1
				UNION ALL SELECT 151 as sporttype, 42 as bettype, @isauto_v151mpositiontaking_42 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_42 as isautompositiontaking_mem, @v151mpositiontaking_42 as mpositiontaking, @max_v151mp_42 as mpositiontaking_max WHERE @UpdatePositiontakingv151_41 = 1
				UNION ALL SELECT 151 as sporttype, 51 as bettype, @isauto_v151mpositiontaking_51 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_51 as isautompositiontaking_mem, @v151mpositiontaking_51 as mpositiontaking, @max_v151mp_51 as mpositiontaking_max WHERE @UpdatePositiontakingv151_51 = 1
				UNION ALL SELECT 151 as sporttype, 52 as bettype, @isauto_v151mpositiontaking_52 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_52 as isautompositiontaking_mem, @v151mpositiontaking_52 as mpositiontaking, @max_v151mp_52 as mpositiontaking_max WHERE @UpdatePositiontakingv151_51 = 1
			) b
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.mpositiontaking > b.mpositiontaking_max and b.isautomapositiontaking = 0 and b.isautompositiontaking_mem = 0 	
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 10,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking. <br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'+@ErrType
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1 >= m1_min
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Min: '+ CAST((b.mpositiontaking_min) AS VARCHAR(10)) + '<br>'
		FROM 
			(
				SELECT 151 as sporttype, 31 as bettype, @isauto_v151mpositiontaking_31 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_31 as isautompositiontaking_mem, @v151mpositiontaking_31 as mpositiontaking, @min_v151mp_31 as mpositiontaking_min WHERE @UpdatePositiontakingv151_31 = 1
				UNION ALL SELECT 151 as sporttype, 32 as bettype, @isauto_v151mpositiontaking_32 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_32 as isautompositiontaking_mem, @v151mpositiontaking_32 as mpositiontaking, @min_v151mp_32 as mpositiontaking_min WHERE @UpdatePositiontakingv151_31 = 1
				UNION ALL SELECT 151 as sporttype, 41 as bettype, @isauto_v151mpositiontaking_41 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_41 as isautompositiontaking_mem, @v151mpositiontaking_41 as mpositiontaking, @min_v151mp_41 as mpositiontaking_min WHERE @UpdatePositiontakingv151_41 = 1
				UNION ALL SELECT 151 as sporttype, 42 as bettype, @isauto_v151mpositiontaking_42 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_42 as isautompositiontaking_mem, @v151mpositiontaking_42 as mpositiontaking, @min_v151mp_42 as mpositiontaking_min WHERE @UpdatePositiontakingv151_41 = 1
				UNION ALL SELECT 151 as sporttype, 51 as bettype, @isauto_v151mpositiontaking_51 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_51 as isautompositiontaking_mem, @v151mpositiontaking_51 as mpositiontaking, @min_v151mp_51 as mpositiontaking_min WHERE @UpdatePositiontakingv151_51 = 1
				UNION ALL SELECT 151 as sporttype, 52 as bettype, @isauto_v151mpositiontaking_52 as isautomapositiontaking, @old_isauto_v151mpositiontaking_mem_52 as isautompositiontaking_mem, @v151mpositiontaking_52 as mpositiontaking, @min_v151mp_52 as mpositiontaking_min WHERE @UpdatePositiontakingv151_51 = 1
			) b
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.mpositiontaking < b.mpositiontaking_min and b.isautomapositiontaking = 0 and b.isautompositiontaking_mem = 0 	
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 12,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking. <br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'+@ErrType
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--m1=m1+a1>m3?m3-a1:m1
		SELECT 
			@v151mpositiontaking_31 = CASE WHEN @v151apositiontaking_31+@v151mpositiontaking_31>@max_v151mapositiontaking_31 THEN @max_v151mapositiontaking_31-@v151apositiontaking_31 ELSE @v151mpositiontaking_31 END,
			@v151mpositiontaking_32 = CASE WHEN @v151apositiontaking_32+@v151mpositiontaking_32>@max_v151mapositiontaking_32 THEN @max_v151mapositiontaking_32-@v151apositiontaking_32 ELSE @v151mpositiontaking_32 END,
			@v151mpositiontaking_41 = CASE WHEN @v151apositiontaking_41+@v151mpositiontaking_41>@max_v151mapositiontaking_41 THEN @max_v151mapositiontaking_41-@v151apositiontaking_41 ELSE @v151mpositiontaking_41 END,
			@v151mpositiontaking_42 = CASE WHEN @v151apositiontaking_42+@v151mpositiontaking_42>@max_v151mapositiontaking_42 THEN @max_v151mapositiontaking_42-@v151apositiontaking_42 ELSE @v151mpositiontaking_42 END,
			@v151mpositiontaking_51 = CASE WHEN @v151apositiontaking_51+@v151mpositiontaking_51>@max_v151mapositiontaking_51 THEN @max_v151mapositiontaking_51-@v151apositiontaking_51 ELSE @v151mpositiontaking_51 END,
			@v151mpositiontaking_52 = CASE WHEN @v151apositiontaking_52+@v151mpositiontaking_52>@max_v151mapositiontaking_52 THEN @max_v151mapositiontaking_52-@v151apositiontaking_52 ELSE @v151mpositiontaking_52 END

		--m1=m1+a1<n3?n3-a1:m1
		SELECT 
			@v151mpositiontaking_31 = CASE WHEN @v151apositiontaking_31+@v151mpositiontaking_31<@min_v151mapositiontaking_31 THEN @min_v151mapositiontaking_31-@v151apositiontaking_31 ELSE @v151mpositiontaking_31 END,
			@v151mpositiontaking_32 = CASE WHEN @v151apositiontaking_32+@v151mpositiontaking_32<@min_v151mapositiontaking_32 THEN @min_v151mapositiontaking_32-@v151apositiontaking_32 ELSE @v151mpositiontaking_32 END,
			@v151mpositiontaking_41 = CASE WHEN @v151apositiontaking_41+@v151mpositiontaking_41<@min_v151mapositiontaking_41 THEN @min_v151mapositiontaking_41-@v151apositiontaking_41 ELSE @v151mpositiontaking_41 END,
			@v151mpositiontaking_42 = CASE WHEN @v151apositiontaking_42+@v151mpositiontaking_42<@min_v151mapositiontaking_42 THEN @min_v151mapositiontaking_42-@v151apositiontaking_42 ELSE @v151mpositiontaking_42 END,
			@v151mpositiontaking_51 = CASE WHEN @v151apositiontaking_51+@v151mpositiontaking_51<@min_v151mapositiontaking_51 THEN @min_v151mapositiontaking_51-@v151apositiontaking_51 ELSE @v151mpositiontaking_51 END,
			@v151mpositiontaking_52 = CASE WHEN @v151apositiontaking_52+@v151mpositiontaking_52<@min_v151mapositiontaking_52 THEN @min_v151mapositiontaking_52-@v151apositiontaking_52 ELSE @v151mpositiontaking_52 END

		SELECT 
			@v151mpositiontaking_31 = CASE WHEN @v151mpositiontaking_31<0 THEN 0 ELSE @v151mpositiontaking_31 END,
			@v151mpositiontaking_32 = CASE WHEN @v151mpositiontaking_32<0 THEN 0 ELSE @v151mpositiontaking_32 END,
			@v151mpositiontaking_41 = CASE WHEN @v151mpositiontaking_41<0 THEN 0 ELSE @v151mpositiontaking_41 END,
			@v151mpositiontaking_42 = CASE WHEN @v151mpositiontaking_42<0 THEN 0 ELSE @v151mpositiontaking_42 END,
			@v151mpositiontaking_51 = CASE WHEN @v151mpositiontaking_51<0 THEN 0 ELSE @v151mpositiontaking_51 END,
			@v151mpositiontaking_52 = CASE WHEN @v151mpositiontaking_52<0 THEN 0 ELSE @v151mpositiontaking_52 END

		--Must include code for auto master
		--um=im1>0?um1:um2
		--im=im1>0?im1:im2
		--m1=im>0?min(um,m3-a1):m1
		----------------------------------------------------------------------------------------------------------------------------
		--auto master

		--um=im1>0?um1:um2
		SELECT 
			@auto_v151mpositiontaking_31 = CASE WHEN @isauto_v151mpositiontaking_mem_31>0 THEN @auto_v151mpositiontaking_mem_31 ELSE @auto_v151mpositiontaking_31 END,
			@auto_v151mpositiontaking_32 = CASE WHEN @isauto_v151mpositiontaking_mem_32>0 THEN @auto_v151mpositiontaking_mem_32 ELSE @auto_v151mpositiontaking_32 END,
			@auto_v151mpositiontaking_41 = CASE WHEN @isauto_v151mpositiontaking_mem_41>0 THEN @auto_v151mpositiontaking_mem_41 ELSE @auto_v151mpositiontaking_41 END,
			@auto_v151mpositiontaking_42 = CASE WHEN @isauto_v151mpositiontaking_mem_42>0 THEN @auto_v151mpositiontaking_mem_42 ELSE @auto_v151mpositiontaking_42 END,
			@auto_v151mpositiontaking_51 = CASE WHEN @isauto_v151mpositiontaking_mem_51>0 THEN @auto_v151mpositiontaking_mem_51 ELSE @auto_v151mpositiontaking_51 END,
			@auto_v151mpositiontaking_52 = CASE WHEN @isauto_v151mpositiontaking_mem_52>0 THEN @auto_v151mpositiontaking_mem_52 ELSE @auto_v151mpositiontaking_52 END,
			
			--im=im1>0?im1:im31
			@isauto_v151mpositiontaking_31 = CASE WHEN @isauto_v151mpositiontaking_mem_31>0 THEN @isauto_v151mpositiontaking_mem_31 ELSE @isauto_v151mpositiontaking_31 END,
			@isauto_v151mpositiontaking_32 = CASE WHEN @isauto_v151mpositiontaking_mem_32>0 THEN @isauto_v151mpositiontaking_mem_32 ELSE @isauto_v151mpositiontaking_32 END,
			@isauto_v151mpositiontaking_41 = CASE WHEN @isauto_v151mpositiontaking_mem_41>0 THEN @isauto_v151mpositiontaking_mem_41 ELSE @isauto_v151mpositiontaking_41 END,
			@isauto_v151mpositiontaking_42 = CASE WHEN @isauto_v151mpositiontaking_mem_42>0 THEN @isauto_v151mpositiontaking_mem_42 ELSE @isauto_v151mpositiontaking_42 END,
			@isauto_v151mpositiontaking_51 = CASE WHEN @isauto_v151mpositiontaking_mem_51>0 THEN @isauto_v151mpositiontaking_mem_51 ELSE @isauto_v151mpositiontaking_51 END,
			@isauto_v151mpositiontaking_52 = CASE WHEN @isauto_v151mpositiontaking_mem_52>0 THEN @isauto_v151mpositiontaking_mem_52 ELSE @isauto_v151mpositiontaking_52 END
		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		--m1=im>0?min(um,m3-a1):m1
		SELECT @v151mpositiontaking_31 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_31, 0)<=0 THEN @v151mpositiontaking_31 ELSE CASE WHEN @auto_v151mpositiontaking_31 < @max_v151mapositiontaking_31 - @v151apositiontaking_31 THEN @auto_v151mpositiontaking_31 ELSE @max_v151mapositiontaking_31 - @v151apositiontaking_31 END END
		SELECT @v151mpositiontaking_32 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_32, 0)<=0 THEN @v151mpositiontaking_32 ELSE CASE WHEN @auto_v151mpositiontaking_32 < @max_v151mapositiontaking_32 - @v151apositiontaking_32 THEN @auto_v151mpositiontaking_32 ELSE @max_v151mapositiontaking_32 - @v151apositiontaking_32 END END
		SELECT @v151mpositiontaking_41 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_41, 0)<=0 THEN @v151mpositiontaking_41 ELSE CASE WHEN @auto_v151mpositiontaking_41 < @max_v151mapositiontaking_41 - @v151apositiontaking_41 THEN @auto_v151mpositiontaking_41 ELSE @max_v151mapositiontaking_41 - @v151apositiontaking_41 END END
		SELECT @v151mpositiontaking_42 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_42, 0)<=0 THEN @v151mpositiontaking_42 ELSE CASE WHEN @auto_v151mpositiontaking_42 < @max_v151mapositiontaking_42 - @v151apositiontaking_42 THEN @auto_v151mpositiontaking_42 ELSE @max_v151mapositiontaking_42 - @v151apositiontaking_42 END END
		SELECT @v151mpositiontaking_51 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_51, 0)<=0 THEN @v151mpositiontaking_51 ELSE CASE WHEN @auto_v151mpositiontaking_51 < @max_v151mapositiontaking_51 - @v151apositiontaking_51 THEN @auto_v151mpositiontaking_51 ELSE @max_v151mapositiontaking_51 - @v151apositiontaking_51 END END
		SELECT @v151mpositiontaking_52 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_52, 0)<=0 THEN @v151mpositiontaking_52 ELSE CASE WHEN @auto_v151mpositiontaking_52 < @max_v151mapositiontaking_52 - @v151apositiontaking_52 THEN @auto_v151mpositiontaking_52 ELSE @max_v151mapositiontaking_52 - @v151apositiontaking_52 END END
		-------------------------------------------------------------------------------
		/*
		--maxm1=isauto?m3:m3-a2
		SELECT @max_v151mapositiontaking_31 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_31, 0)>0 THEN @max_v151mapositiontaking_31 ELSE @max_v151mapositiontaking_31-@max_v151apositiontaking_31 END
		SELECT @max_v151mapositiontaking_32 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_32, 0)>0 THEN @max_v151mapositiontaking_32 ELSE @max_v151mapositiontaking_32-@max_v151apositiontaking_32 END
		SELECT @max_v151mapositiontaking_41 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_41, 0)>0 THEN @max_v151mapositiontaking_41 ELSE @max_v151mapositiontaking_41-@max_v151apositiontaking_41 END
		SELECT @max_v151mapositiontaking_42 = CASE WHEN ISNULL(@isauto_v151mpositiontaking_42, 0)>0 THEN @max_v151mapositiontaking_42 ELSE @max_v151mapositiontaking_42-@max_v151apositiontaking_42 END
		--m1=m1>maxm1?maxm1:m1
		SELECT @v151mpositiontaking_31 = CASE WHEN @v151mpositiontaking_31 > @max_v151mapositiontaking_31 THEN @max_v151mapositiontaking_31 ELSE @v151mpositiontaking_31 END
		SELECT @v151mpositiontaking_32 = CASE WHEN @v151mpositiontaking_32 > @max_v151mapositiontaking_32 THEN @max_v151mapositiontaking_32 ELSE @v151mpositiontaking_32 END
		SELECT @v151mpositiontaking_41 = CASE WHEN @v151mpositiontaking_41 > @max_v151mapositiontaking_41 THEN @max_v151mapositiontaking_41 ELSE @v151mpositiontaking_41 END
		SELECT @v151mpositiontaking_42 = CASE WHEN @v151mpositiontaking_42 > @max_v151mapositiontaking_42 THEN @max_v151mapositiontaking_42 ELSE @v151mpositiontaking_42 END
		*/
		----------------------------------------------------------------------------------------------------------------------------
		-- end auto master



		---------------------------------------------------------------------------------------------------------------------------------------------
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
		SELECT 
			@auto_v151spositiontaking_31 = CASE WHEN @isauto_v151spositiontaking_mem_31>0 THEN @auto_v151spositiontaking_mem_31 ELSE @auto_v151spositiontaking_31 END,
			@auto_v151spositiontaking_32 = CASE WHEN @isauto_v151spositiontaking_mem_32>0 THEN @auto_v151spositiontaking_mem_32 ELSE @auto_v151spositiontaking_32 END,
			@auto_v151spositiontaking_41 = CASE WHEN @isauto_v151spositiontaking_mem_41>0 THEN @auto_v151spositiontaking_mem_41 ELSE @auto_v151spositiontaking_41 END,
			@auto_v151spositiontaking_42 = CASE WHEN @isauto_v151spositiontaking_mem_42>0 THEN @auto_v151spositiontaking_mem_42 ELSE @auto_v151spositiontaking_42 END,
			@auto_v151spositiontaking_51 = CASE WHEN @isauto_v151spositiontaking_mem_51>0 THEN @auto_v151spositiontaking_mem_51 ELSE @auto_v151spositiontaking_51 END,
			@auto_v151spositiontaking_52 = CASE WHEN @isauto_v151spositiontaking_mem_52>0 THEN @auto_v151spositiontaking_mem_52 ELSE @auto_v151spositiontaking_52 END,

			@isauto_v151spositiontaking_31 = CASE WHEN @isauto_v151spositiontaking_mem_31>0 THEN @isauto_v151spositiontaking_mem_31 ELSE @isauto_v151spositiontaking_31 END,
			@isauto_v151spositiontaking_32 = CASE WHEN @isauto_v151spositiontaking_mem_32>0 THEN @isauto_v151spositiontaking_mem_32 ELSE @isauto_v151spositiontaking_32 END,
			@isauto_v151spositiontaking_41 = CASE WHEN @isauto_v151spositiontaking_mem_41>0 THEN @isauto_v151spositiontaking_mem_41 ELSE @isauto_v151spositiontaking_41 END,
			@isauto_v151spositiontaking_42 = CASE WHEN @isauto_v151spositiontaking_mem_42>0 THEN @isauto_v151spositiontaking_mem_42 ELSE @isauto_v151spositiontaking_42 END,
			@isauto_v151spositiontaking_51 = CASE WHEN @isauto_v151spositiontaking_mem_51>0 THEN @isauto_v151spositiontaking_mem_51 ELSE @isauto_v151spositiontaking_51 END,
			@isauto_v151spositiontaking_52 = CASE WHEN @isauto_v151spositiontaking_mem_52>0 THEN @isauto_v151spositiontaking_mem_52 ELSE @isauto_v151spositiontaking_52 END
			
		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		SELECT @v151spositiontaking_31 = CASE WHEN ISNULL(@isauto_v151spositiontaking_31, 0)<=0 THEN @v151spositiontaking_31 ELSE CASE WHEN @auto_v151spositiontaking_31 < @max_v151spositiontaking_31 - @v151mpositiontaking_31 - @v151apositiontaking_31 THEN @auto_v151spositiontaking_31 ELSE @max_v151spositiontaking_31 - @v151mpositiontaking_31 - @v151apositiontaking_31 END END
		SELECT @v151spositiontaking_32 = CASE WHEN ISNULL(@isauto_v151spositiontaking_32, 0)<=0 THEN @v151spositiontaking_32 ELSE CASE WHEN @auto_v151spositiontaking_32 < @max_v151spositiontaking_32 - @v151mpositiontaking_32 - @v151apositiontaking_32 THEN @auto_v151spositiontaking_32 ELSE @max_v151spositiontaking_32 - @v151mpositiontaking_32 - @v151apositiontaking_32 END END
		SELECT @v151spositiontaking_41 = CASE WHEN ISNULL(@isauto_v151spositiontaking_41, 0)<=0 THEN @v151spositiontaking_41 ELSE CASE WHEN @auto_v151spositiontaking_41 < @max_v151spositiontaking_41 - @v151mpositiontaking_41 - @v151apositiontaking_41 THEN @auto_v151spositiontaking_41 ELSE @max_v151spositiontaking_41 - @v151mpositiontaking_41 - @v151apositiontaking_41 END END
		SELECT @v151spositiontaking_42 = CASE WHEN ISNULL(@isauto_v151spositiontaking_42, 0)<=0 THEN @v151spositiontaking_42 ELSE CASE WHEN @auto_v151spositiontaking_42 < @max_v151spositiontaking_42 - @v151mpositiontaking_42 - @v151apositiontaking_42 THEN @auto_v151spositiontaking_42 ELSE @max_v151spositiontaking_42 - @v151mpositiontaking_42 - @v151apositiontaking_42 END END
		SELECT @v151spositiontaking_51 = CASE WHEN ISNULL(@isauto_v151spositiontaking_51, 0)<=0 THEN @v151spositiontaking_51 ELSE CASE WHEN @auto_v151spositiontaking_51 < @max_v151spositiontaking_51 - @v151mpositiontaking_51 - @v151apositiontaking_51 THEN @auto_v151spositiontaking_51 ELSE @max_v151spositiontaking_51 - @v151mpositiontaking_51 - @v151apositiontaking_51 END END
		SELECT @v151spositiontaking_52 = CASE WHEN ISNULL(@isauto_v151spositiontaking_52, 0)<=0 THEN @v151spositiontaking_52 ELSE CASE WHEN @auto_v151spositiontaking_52 < @max_v151spositiontaking_52 - @v151mpositiontaking_52 - @v151apositiontaking_52 THEN @auto_v151spositiontaking_52 ELSE @max_v151spositiontaking_52 - @v151mpositiontaking_52 - @v151apositiontaking_52 END END

		-------------------------------------------------------------------------------
		--maxs1=isauto?s4:s4-m2
		SELECT @max_v151spositiontaking_31 = CASE WHEN ISNULL(@isauto_v151spositiontaking_31, 0)>0 THEN @max_v151spositiontaking_31 ELSE @max_v151spositiontaking_31-@max_v151mapositiontaking_31 END
		SELECT @max_v151spositiontaking_32 = CASE WHEN ISNULL(@isauto_v151spositiontaking_32, 0)>0 THEN @max_v151spositiontaking_32 ELSE @max_v151spositiontaking_32-@max_v151mapositiontaking_32 END
		SELECT @max_v151spositiontaking_41 = CASE WHEN ISNULL(@isauto_v151spositiontaking_41, 0)>0 THEN @max_v151spositiontaking_41 ELSE @max_v151spositiontaking_41-@max_v151mapositiontaking_41 END
		SELECT @max_v151spositiontaking_42 = CASE WHEN ISNULL(@isauto_v151spositiontaking_42, 0)>0 THEN @max_v151spositiontaking_42 ELSE @max_v151spositiontaking_42-@max_v151mapositiontaking_42 END
		SELECT @max_v151spositiontaking_51 = CASE WHEN ISNULL(@isauto_v151spositiontaking_51, 0)>0 THEN @max_v151spositiontaking_51 ELSE @max_v151spositiontaking_51-@max_v151mapositiontaking_51 END
		SELECT @max_v151spositiontaking_52 = CASE WHEN ISNULL(@isauto_v151spositiontaking_52, 0)>0 THEN @max_v151spositiontaking_52 ELSE @max_v151spositiontaking_52-@max_v151mapositiontaking_52 END
		--s1=s1>maxs1?maxs1:s1
		SELECT @v151spositiontaking_31 = CASE WHEN @v151spositiontaking_31 > @max_v151spositiontaking_31 THEN @max_v151spositiontaking_31 ELSE @v151spositiontaking_31 END
		SELECT @v151spositiontaking_32 = CASE WHEN @v151spositiontaking_32 > @max_v151spositiontaking_32 THEN @max_v151spositiontaking_32 ELSE @v151spositiontaking_32 END
		SELECT @v151spositiontaking_41 = CASE WHEN @v151spositiontaking_41 > @max_v151spositiontaking_41 THEN @max_v151spositiontaking_41 ELSE @v151spositiontaking_41 END
		SELECT @v151spositiontaking_42 = CASE WHEN @v151spositiontaking_42 > @max_v151spositiontaking_42 THEN @max_v151spositiontaking_42 ELSE @v151spositiontaking_42 END
		SELECT @v151spositiontaking_51 = CASE WHEN @v151spositiontaking_51 > @max_v151spositiontaking_51 THEN @max_v151spositiontaking_51 ELSE @v151spositiontaking_51 END
		SELECT @v151spositiontaking_52 = CASE WHEN @v151spositiontaking_52 > @max_v151spositiontaking_52 THEN @max_v151spositiontaking_52 ELSE @v151spositiontaking_52 END
	
	END --@UpdatePositiontakingv151
	

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1 )
	BEGIN --@UpdatePositiontakingv152
		--Check m1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10))
		FROM (
								SELECT 152 AS sporttype	,	 41 AS bettype	,	 @v152mpositiontaking_41 AS mpositiontaking	,	 @max_v152mapositiontaking_41 AS maxmpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype	,	 42 AS bettype	,	 @v152mpositiontaking_42 AS mpositiontaking	,	 @max_v152mapositiontaking_42 AS maxmpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL		SELECT 152 AS sporttype	,	 51 AS bettype	,	 @v152mpositiontaking_51 AS mpositiontaking	,	 @max_v152mapositiontaking_51 AS maxmpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				UNION ALL		SELECT 152 AS sporttype	,	 52 AS bettype	,	 @v152mpositiontaking_52 AS mpositiontaking	,	 @max_v152mapositiontaking_52 AS maxmpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
		)b 	
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE (b.mpositiontaking>b.maxmpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		--Check m1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))
			FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN
				(
									SELECT 152 AS sporttype	,	 41 AS bettype	,	 @v152mpositiontaking_41 AS mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
					UNION ALL		SELECT 152 AS sporttype	,	 42 AS bettype	,	 @v152mpositiontaking_42 AS mpositiontaking WHERE @UpdatePositiontakingv152_41 = 1
					UNION ALL		SELECT 152 AS sporttype	,	 51 AS bettype	,	 @v152mpositiontaking_51 AS mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
					UNION ALL		SELECT 152 AS sporttype	,	 52 AS bettype	,	 @v152mpositiontaking_52 AS mpositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE co.custid = @mrecommend AND (b.mpositiontaking>co.maxpositiontaking) 
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 9,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1 <= m1_max
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((b.mpositiontaking_max) AS VARCHAR(10)) + '<br>'
		FROM 
			(
				SELECT 152 as sporttype, 41 as bettype, @isauto_v152mpositiontaking_41 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_41 as isautompositiontaking_mem, @v152mpositiontaking_41 as mpositiontaking, @max_v152mp_41 as mpositiontaking_max WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL SELECT 152 as sporttype, 42 as bettype, @isauto_v152mpositiontaking_42 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_42 as isautompositiontaking_mem, @v152mpositiontaking_42 as mpositiontaking, @max_v152mp_42 as mpositiontaking_max WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL SELECT 152 as sporttype, 51 as bettype, @isauto_v152mpositiontaking_51 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_51 as isautompositiontaking_mem, @v152mpositiontaking_51 as mpositiontaking, @max_v152mp_51 as mpositiontaking_max WHERE @UpdatePositiontakingv152_51 = 1
				UNION ALL SELECT 152 as sporttype, 52 as bettype, @isauto_v152mpositiontaking_52 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_52 as isautompositiontaking_mem, @v152mpositiontaking_52 as mpositiontaking, @max_v152mp_52 as mpositiontaking_max WHERE @UpdatePositiontakingv152_51 = 1
			) b
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.mpositiontaking > b.mpositiontaking_max and b.isautomapositiontaking = 0 and b.isautompositiontaking_mem = 0 	
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 10,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'+@ErrType
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1 >= m1_min
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Min: '+ CAST((b.mpositiontaking_min) AS VARCHAR(10)) + '<br>'
		FROM 
			(
				SELECT 152 as sporttype, 41 as bettype, @isauto_v152mpositiontaking_41 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_41 as isautompositiontaking_mem, @v152mpositiontaking_41 as mpositiontaking, @min_v152mp_41 as mpositiontaking_min WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL SELECT 152 as sporttype, 42 as bettype, @isauto_v152mpositiontaking_42 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_42 as isautompositiontaking_mem, @v152mpositiontaking_42 as mpositiontaking, @min_v152mp_42 as mpositiontaking_min WHERE @UpdatePositiontakingv152_41 = 1
				UNION ALL SELECT 152 as sporttype, 51 as bettype, @isauto_v152mpositiontaking_51 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_51 as isautompositiontaking_mem, @v152mpositiontaking_51 as mpositiontaking, @min_v152mp_51 as mpositiontaking_min WHERE @UpdatePositiontakingv152_51 = 1
				UNION ALL SELECT 152 as sporttype, 52 as bettype, @isauto_v152mpositiontaking_52 as isautomapositiontaking, @old_isauto_v152mpositiontaking_mem_52 as isautompositiontaking_mem, @v152mpositiontaking_52 as mpositiontaking, @min_v152mp_52 as mpositiontaking_min WHERE @UpdatePositiontakingv152_51 = 1
			) b
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.mpositiontaking < b.mpositiontaking_min and b.isautomapositiontaking = 0 and b.isautompositiontaking_mem = 0 	
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 12,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'+@ErrType
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--m1=m1+a1>m3?m3-a1:m1
		SELECT 
			@v152mpositiontaking_41 = CASE WHEN @v152apositiontaking_41+@v152mpositiontaking_41>@max_v152mapositiontaking_41 THEN @max_v152mapositiontaking_41-@v152apositiontaking_41 ELSE @v152mpositiontaking_41 END,
			@v152mpositiontaking_42 = CASE WHEN @v152apositiontaking_42+@v152mpositiontaking_42>@max_v152mapositiontaking_42 THEN @max_v152mapositiontaking_42-@v152apositiontaking_42 ELSE @v152mpositiontaking_42 END,
			@v152mpositiontaking_51 = CASE WHEN @v152apositiontaking_51+@v152mpositiontaking_51>@max_v152mapositiontaking_51 THEN @max_v152mapositiontaking_51-@v152apositiontaking_51 ELSE @v152mpositiontaking_51 END,
			@v152mpositiontaking_52 = CASE WHEN @v152apositiontaking_52+@v152mpositiontaking_52>@max_v152mapositiontaking_52 THEN @max_v152mapositiontaking_52-@v152apositiontaking_52 ELSE @v152mpositiontaking_52 END

		--m1=m1+a1<n3?n3-a1:m1
		SELECT 
			@v152mpositiontaking_41 = CASE WHEN @v152apositiontaking_41+@v152mpositiontaking_41<@min_v152mapositiontaking_41 THEN @min_v152mapositiontaking_41-@v152apositiontaking_41 ELSE @v152mpositiontaking_41 END,
			@v152mpositiontaking_42 = CASE WHEN @v152apositiontaking_42+@v152mpositiontaking_42<@min_v152mapositiontaking_42 THEN @min_v152mapositiontaking_42-@v152apositiontaking_42 ELSE @v152mpositiontaking_42 END,
			@v152mpositiontaking_51 = CASE WHEN @v152apositiontaking_51+@v152mpositiontaking_51<@min_v152mapositiontaking_51 THEN @min_v152mapositiontaking_51-@v152apositiontaking_51 ELSE @v152mpositiontaking_51 END,
			@v152mpositiontaking_52 = CASE WHEN @v152apositiontaking_52+@v152mpositiontaking_52<@min_v152mapositiontaking_52 THEN @min_v152mapositiontaking_52-@v152apositiontaking_52 ELSE @v152mpositiontaking_52 END

		SELECT 
			@v152mpositiontaking_41 = CASE WHEN @v152mpositiontaking_41<0 THEN 0 ELSE @v152mpositiontaking_41 END,
			@v152mpositiontaking_42 = CASE WHEN @v152mpositiontaking_42<0 THEN 0 ELSE @v152mpositiontaking_42 END,
			@v152mpositiontaking_51 = CASE WHEN @v152mpositiontaking_51<0 THEN 0 ELSE @v152mpositiontaking_51 END,
			@v152mpositiontaking_52 = CASE WHEN @v152mpositiontaking_52<0 THEN 0 ELSE @v152mpositiontaking_52 END

		--Must include code for auto master
		--um=im1>0?um1:um2
		--im=im1>0?im1:im2
		--m1=im>0?min(um,m3-a1):m1
		----------------------------------------------------------------------------------------------------------------------------
		--auto master

		--um=im1>0?um1:um2
		SELECT 
			@auto_v152mpositiontaking_41 = CASE WHEN @isauto_v152mpositiontaking_mem_41>0 THEN @auto_v152mpositiontaking_mem_41 ELSE @auto_v152mpositiontaking_41 END,
			@auto_v152mpositiontaking_42 = CASE WHEN @isauto_v152mpositiontaking_mem_42>0 THEN @auto_v152mpositiontaking_mem_42 ELSE @auto_v152mpositiontaking_42 END,
			@auto_v152mpositiontaking_51 = CASE WHEN @isauto_v152mpositiontaking_mem_51>0 THEN @auto_v152mpositiontaking_mem_51 ELSE @auto_v152mpositiontaking_51 END,
			@auto_v152mpositiontaking_52 = CASE WHEN @isauto_v152mpositiontaking_mem_52>0 THEN @auto_v152mpositiontaking_mem_52 ELSE @auto_v152mpositiontaking_52 END,
			--im=im1>0?im1:im31
			@isauto_v152mpositiontaking_41 = CASE WHEN @isauto_v152mpositiontaking_mem_41>0 THEN @isauto_v152mpositiontaking_mem_41 ELSE @isauto_v152mpositiontaking_41 END,
			@isauto_v152mpositiontaking_42 = CASE WHEN @isauto_v152mpositiontaking_mem_42>0 THEN @isauto_v152mpositiontaking_mem_42 ELSE @isauto_v152mpositiontaking_42 END,
			@isauto_v152mpositiontaking_51 = CASE WHEN @isauto_v152mpositiontaking_mem_51>0 THEN @isauto_v152mpositiontaking_mem_51 ELSE @isauto_v152mpositiontaking_51 END,
			@isauto_v152mpositiontaking_52 = CASE WHEN @isauto_v152mpositiontaking_mem_52>0 THEN @isauto_v152mpositiontaking_mem_52 ELSE @isauto_v152mpositiontaking_52 END
		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		--m1=im>0?min(um,m3-a1):m1
		SELECT @v152mpositiontaking_41 = CASE WHEN ISNULL(@isauto_v152mpositiontaking_41, 0)<=0 THEN @v152mpositiontaking_41 ELSE CASE WHEN @auto_v152mpositiontaking_41 < @max_v152mapositiontaking_41 - @v152apositiontaking_41 THEN @auto_v152mpositiontaking_41 ELSE @max_v152mapositiontaking_41 - @v152apositiontaking_41 END END
		SELECT @v152mpositiontaking_42 = CASE WHEN ISNULL(@isauto_v152mpositiontaking_42, 0)<=0 THEN @v152mpositiontaking_42 ELSE CASE WHEN @auto_v152mpositiontaking_42 < @max_v152mapositiontaking_42 - @v152apositiontaking_42 THEN @auto_v152mpositiontaking_42 ELSE @max_v152mapositiontaking_42 - @v152apositiontaking_42 END END
		SELECT @v152mpositiontaking_51 = CASE WHEN ISNULL(@isauto_v152mpositiontaking_51, 0)<=0 THEN @v152mpositiontaking_51 ELSE CASE WHEN @auto_v152mpositiontaking_51 < @max_v152mapositiontaking_51 - @v152apositiontaking_51 THEN @auto_v152mpositiontaking_51 ELSE @max_v152mapositiontaking_51 - @v152apositiontaking_51 END END
		SELECT @v152mpositiontaking_52 = CASE WHEN ISNULL(@isauto_v152mpositiontaking_52, 0)<=0 THEN @v152mpositiontaking_52 ELSE CASE WHEN @auto_v152mpositiontaking_52 < @max_v152mapositiontaking_52 - @v152apositiontaking_52 THEN @auto_v152mpositiontaking_52 ELSE @max_v152mapositiontaking_52 - @v152apositiontaking_52 END END
		-- end auto master

		---------------------------------------------------------------------------------------------------------------------------------------------
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
		SELECT 
			@auto_v152spositiontaking_41 = CASE WHEN @isauto_v152spositiontaking_mem_41>0 THEN @auto_v152spositiontaking_mem_41 ELSE @auto_v152spositiontaking_41 END,
			@auto_v152spositiontaking_42 = CASE WHEN @isauto_v152spositiontaking_mem_42>0 THEN @auto_v152spositiontaking_mem_42 ELSE @auto_v152spositiontaking_42 END,
			@auto_v152spositiontaking_51 = CASE WHEN @isauto_v152spositiontaking_mem_51>0 THEN @auto_v152spositiontaking_mem_51 ELSE @auto_v152spositiontaking_51 END,
			@auto_v152spositiontaking_52 = CASE WHEN @isauto_v152spositiontaking_mem_52>0 THEN @auto_v152spositiontaking_mem_52 ELSE @auto_v152spositiontaking_52 END,

			@isauto_v152spositiontaking_41 = CASE WHEN @isauto_v152spositiontaking_mem_41>0 THEN @isauto_v152spositiontaking_mem_41 ELSE @isauto_v152spositiontaking_41 END,
			@isauto_v152spositiontaking_42 = CASE WHEN @isauto_v152spositiontaking_mem_42>0 THEN @isauto_v152spositiontaking_mem_42 ELSE @isauto_v152spositiontaking_42 END,
			@isauto_v152spositiontaking_51 = CASE WHEN @isauto_v152spositiontaking_mem_51>0 THEN @isauto_v152spositiontaking_mem_51 ELSE @isauto_v152spositiontaking_51 END,
			@isauto_v152spositiontaking_52 = CASE WHEN @isauto_v152spositiontaking_mem_52>0 THEN @isauto_v152spositiontaking_mem_52 ELSE @isauto_v152spositiontaking_52 END
		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		SELECT @v152spositiontaking_41 = CASE WHEN ISNULL(@isauto_v152spositiontaking_41, 0)<=0 THEN @v152spositiontaking_41 ELSE CASE WHEN @auto_v152spositiontaking_41 < @max_v152spositiontaking_41 - @v152mpositiontaking_41 - @v152apositiontaking_41 THEN @auto_v152spositiontaking_41 ELSE @max_v152spositiontaking_41 - @v152mpositiontaking_41 - @v152apositiontaking_41 END END
		SELECT @v152spositiontaking_42 = CASE WHEN ISNULL(@isauto_v152spositiontaking_42, 0)<=0 THEN @v152spositiontaking_42 ELSE CASE WHEN @auto_v152spositiontaking_42 < @max_v152spositiontaking_42 - @v152mpositiontaking_42 - @v152apositiontaking_42 THEN @auto_v152spositiontaking_42 ELSE @max_v152spositiontaking_42 - @v152mpositiontaking_42 - @v152apositiontaking_42 END END
		SELECT @v152spositiontaking_51 = CASE WHEN ISNULL(@isauto_v152spositiontaking_51, 0)<=0 THEN @v152spositiontaking_51 ELSE CASE WHEN @auto_v152spositiontaking_51 < @max_v152spositiontaking_51 - @v152mpositiontaking_51 - @v152apositiontaking_51 THEN @auto_v152spositiontaking_51 ELSE @max_v152spositiontaking_51 - @v152mpositiontaking_51 - @v152apositiontaking_51 END END
		SELECT @v152spositiontaking_52 = CASE WHEN ISNULL(@isauto_v152spositiontaking_52, 0)<=0 THEN @v152spositiontaking_52 ELSE CASE WHEN @auto_v152spositiontaking_52 < @max_v152spositiontaking_52 - @v152mpositiontaking_52 - @v152apositiontaking_52 THEN @auto_v152spositiontaking_52 ELSE @max_v152spositiontaking_52 - @v152mpositiontaking_52 - @v152apositiontaking_52 END END
		-------------------------------------------------------------------------------
		--maxs1=isauto?s4:s4-m2
		SELECT @max_v152spositiontaking_41 = CASE WHEN ISNULL(@isauto_v152spositiontaking_41, 0)>0 THEN @max_v152spositiontaking_41 ELSE @max_v152spositiontaking_41-@max_v152mapositiontaking_41 END
		SELECT @max_v152spositiontaking_42 = CASE WHEN ISNULL(@isauto_v152spositiontaking_42, 0)>0 THEN @max_v152spositiontaking_42 ELSE @max_v152spositiontaking_42-@max_v152mapositiontaking_42 END
		SELECT @max_v152spositiontaking_51 = CASE WHEN ISNULL(@isauto_v152spositiontaking_51, 0)>0 THEN @max_v152spositiontaking_51 ELSE @max_v152spositiontaking_51-@max_v152mapositiontaking_51 END
		SELECT @max_v152spositiontaking_52 = CASE WHEN ISNULL(@isauto_v152spositiontaking_52, 0)>0 THEN @max_v152spositiontaking_52 ELSE @max_v152spositiontaking_52-@max_v152mapositiontaking_52 END
		--s1=s1>maxs1?maxs1:s1
		SELECT @v152spositiontaking_41 = CASE WHEN @v152spositiontaking_41 > @max_v152spositiontaking_41 THEN @max_v152spositiontaking_41 ELSE @v152spositiontaking_41 END
		SELECT @v152spositiontaking_42 = CASE WHEN @v152spositiontaking_42 > @max_v152spositiontaking_42 THEN @max_v152spositiontaking_42 ELSE @v152spositiontaking_42 END
		SELECT @v152spositiontaking_51 = CASE WHEN @v152spositiontaking_51 > @max_v152spositiontaking_51 THEN @max_v152spositiontaking_51 ELSE @v152spositiontaking_51 END
		SELECT @v152spositiontaking_52 = CASE WHEN @v152spositiontaking_52 > @max_v152spositiontaking_52 THEN @max_v152spositiontaking_52 ELSE @v152spositiontaking_52 END
	
	END --@UpdatePositiontakingv152
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
	BEGIN --@UpdatePositiontakingv153
		--Check m1<=m3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ CAST((b.maxmpositiontaking) AS VARCHAR(10))
		FROM (
								SELECT 153 AS sporttype	,	 51 AS bettype	,	 @v153mpositiontaking_51 AS mpositiontaking	,	 @max_v153mapositiontaking_51 AS maxmpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
				UNION ALL		SELECT 153 AS sporttype	,	 52 AS bettype	,	 @v153mpositiontaking_52 AS mpositiontaking	,	 @max_v153mapositiontaking_52 AS maxmpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		)b 	
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE (b.mpositiontaking>b.maxmpositiontaking) 

		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 8,
					@ErrMsg_cur = @UserName + ': '+
								CASE @Language 
									WHEN 'E' THEN 'Wrong  position taking.<br>'+@ErrType
									ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
								END							
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			
			RETURN
		END
		--Check m1<=l3
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((co.maxpositiontaking) AS VARCHAR(10))
			FROM CustOverride3rd AS co WITH (NOLOCK) INNER JOIN
				(
									SELECT 153 AS sporttype	,	 51 AS bettype	,	 @v153mpositiontaking_51 AS mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
					UNION ALL		SELECT 153 AS sporttype	,	 52 AS bettype	,	 @v153mpositiontaking_52 AS mpositiontaking WHERE @UpdatePositiontakingv153_51 = 1
				) AS b ON co.sporttype=b.sporttype AND co.bettype=b.bettype
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE co.custid = @mrecommend AND (b.mpositiontaking>co.maxpositiontaking) 
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 9,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking (min/max set by company) ('+@ErrType+').'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1 <= m1_max
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Max: '+ CAST((b.mpositiontaking_max) AS VARCHAR(10)) + '<br>'
		FROM 
			(
				SELECT 153 as sporttype, 51 as bettype, @isauto_v153mpositiontaking_51 as isautomapositiontaking, @old_isauto_v153mpositiontaking_mem_51 as isautompositiontaking_mem, @v153mpositiontaking_51 as mpositiontaking, @max_v153mp_51 as mpositiontaking_max WHERE @UpdatePositiontakingv153_51 = 1
				UNION ALL SELECT 153 as sporttype, 52 as bettype, @isauto_v153mpositiontaking_52 as isautomapositiontaking, @old_isauto_v153mpositiontaking_mem_52 as isautompositiontaking_mem, @v153mpositiontaking_52 as mpositiontaking, @max_v153mp_52 as mpositiontaking_max WHERE @UpdatePositiontakingv153_51 = 1
			) b
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.mpositiontaking > b.mpositiontaking_max and b.isautomapositiontaking = 0 and b.isautompositiontaking_mem = 0 	
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 10,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'+@ErrType
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--check m1 >= m1_min
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + sportname + '-'+
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		+ '-Min: '+ CAST((b.mpositiontaking_min) AS VARCHAR(10)) + '<br>'
		FROM 
			(
				SELECT 153 as sporttype, 51 as bettype, @isauto_v153mpositiontaking_51 as isautomapositiontaking, @old_isauto_v153mpositiontaking_mem_51 as isautompositiontaking_mem, @v153mpositiontaking_51 as mpositiontaking, @min_v153mp_51 as mpositiontaking_min WHERE @UpdatePositiontakingv153_51 = 1
				UNION ALL SELECT 153 as sporttype, 52 as bettype, @isauto_v153mpositiontaking_52 as isautomapositiontaking, @old_isauto_v153mpositiontaking_mem_52 as isautompositiontaking_mem, @v153mpositiontaking_52 as mpositiontaking, @min_v153mp_52 as mpositiontaking_min WHERE @UpdatePositiontakingv153_51 = 1
			) b
			INNER JOIN @tmp_Sports s ON b.sporttype = s.sporttype
			INNER JOIN @tmp_Bettype bt ON b.bettype = bt.typeid
		WHERE b.mpositiontaking < b.mpositiontaking_min and b.isautomapositiontaking = 0 and b.isautompositiontaking_mem = 0 	
		
		IF @ErrType <>''
		BEGIN
			SELECT @ErrCode_cur = 12,
  					@ErrMsg_cur = @UserName + ': '+
						 CASE @Language 
								WHEN 'E' THEN 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'+@ErrType
						END
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
		
		--m1=m1+a1>m3?m3-a1:m1
		SELECT 
			@v153mpositiontaking_51 = CASE WHEN @v153apositiontaking_51+@v153mpositiontaking_51>@max_v153mapositiontaking_51 THEN @max_v153mapositiontaking_51-@v153apositiontaking_51 ELSE @v153mpositiontaking_51 END,
			@v153mpositiontaking_52 = CASE WHEN @v153apositiontaking_52+@v153mpositiontaking_52>@max_v153mapositiontaking_52 THEN @max_v153mapositiontaking_52-@v153apositiontaking_52 ELSE @v153mpositiontaking_52 END

		--m1=m1+a1<n3?n3-a1:m1
		SELECT 
			@v153mpositiontaking_51 = CASE WHEN @v153apositiontaking_51+@v153mpositiontaking_51<@min_v153mapositiontaking_51 THEN @min_v153mapositiontaking_51-@v153apositiontaking_51 ELSE @v153mpositiontaking_51 END,
			@v153mpositiontaking_52 = CASE WHEN @v153apositiontaking_52+@v153mpositiontaking_52<@min_v153mapositiontaking_52 THEN @min_v153mapositiontaking_52-@v153apositiontaking_52 ELSE @v153mpositiontaking_52 END

		SELECT 
			@v153mpositiontaking_51 = CASE WHEN @v153mpositiontaking_51<0 THEN 0 ELSE @v153mpositiontaking_51 END,
			@v153mpositiontaking_52 = CASE WHEN @v153mpositiontaking_52<0 THEN 0 ELSE @v153mpositiontaking_52 END


		--Must include code for auto master
		--um=im1>0?um1:um2
		--im=im1>0?im1:im2
		--m1=im>0?min(um,m3-a1):m1
		----------------------------------------------------------------------------------------------------------------------------
		--auto master

		--um=im1>0?um1:um2
		SELECT 
			@auto_v153mpositiontaking_51 = CASE WHEN @isauto_v153mpositiontaking_mem_51>0 THEN @auto_v153mpositiontaking_mem_51 ELSE @auto_v153mpositiontaking_51 END,
			@auto_v153mpositiontaking_52 = CASE WHEN @isauto_v153mpositiontaking_mem_52>0 THEN @auto_v153mpositiontaking_mem_52 ELSE @auto_v153mpositiontaking_52 END,
			--im=im1>0?im1:im31
			@isauto_v153mpositiontaking_51 = CASE WHEN @isauto_v153mpositiontaking_mem_51>0 THEN @isauto_v153mpositiontaking_mem_51 ELSE @isauto_v153mpositiontaking_51 END,
			@isauto_v153mpositiontaking_52 = CASE WHEN @isauto_v153mpositiontaking_mem_52>0 THEN @isauto_v153mpositiontaking_mem_52 ELSE @isauto_v153mpositiontaking_52 END
		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		--m1=im>0?min(um,m3-a1):m1
		SELECT @v153mpositiontaking_51 = CASE WHEN ISNULL(@isauto_v153mpositiontaking_51, 0)<=0 THEN @v153mpositiontaking_51 ELSE CASE WHEN @auto_v153mpositiontaking_51 < @max_v153mapositiontaking_51 - @v153apositiontaking_51 THEN @auto_v153mpositiontaking_51 ELSE @max_v153mapositiontaking_51 - @v153apositiontaking_51 END END
		SELECT @v153mpositiontaking_52 = CASE WHEN ISNULL(@isauto_v153mpositiontaking_52, 0)<=0 THEN @v153mpositiontaking_52 ELSE CASE WHEN @auto_v153mpositiontaking_52 < @max_v153mapositiontaking_52 - @v153apositiontaking_52 THEN @auto_v153mpositiontaking_52 ELSE @max_v153mapositiontaking_52 - @v153apositiontaking_52 END END
		-- end auto master

		---------------------------------------------------------------------------------------------------------------------------------------------
		--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
		SELECT 
			@auto_v153spositiontaking_51 = CASE WHEN @isauto_v153spositiontaking_mem_51>0 THEN @auto_v153spositiontaking_mem_51 ELSE @auto_v153spositiontaking_51 END,
			@auto_v153spositiontaking_52 = CASE WHEN @isauto_v153spositiontaking_mem_52>0 THEN @auto_v153spositiontaking_mem_52 ELSE @auto_v153spositiontaking_52 END,

			@isauto_v153spositiontaking_51 = CASE WHEN @isauto_v153spositiontaking_mem_51>0 THEN @isauto_v153spositiontaking_mem_51 ELSE @isauto_v153spositiontaking_51 END,
			@isauto_v153spositiontaking_52 = CASE WHEN @isauto_v153spositiontaking_mem_52>0 THEN @isauto_v153spositiontaking_mem_52 ELSE @isauto_v153spositiontaking_52 END
		---------------------------------------------------------------------------------------------------------------------------------------------

		----------------***Use Auto Position Taking***----------------------------------
		SELECT @v153spositiontaking_51 = CASE WHEN ISNULL(@isauto_v153spositiontaking_51, 0)<=0 THEN @v153spositiontaking_51 ELSE CASE WHEN @auto_v153spositiontaking_51 < @max_v153spositiontaking_51 - @v153mpositiontaking_51 - @v153apositiontaking_51 THEN @auto_v153spositiontaking_51 ELSE @max_v153spositiontaking_51 - @v153mpositiontaking_51 - @v153apositiontaking_51 END END
		SELECT @v153spositiontaking_52 = CASE WHEN ISNULL(@isauto_v153spositiontaking_52, 0)<=0 THEN @v153spositiontaking_52 ELSE CASE WHEN @auto_v153spositiontaking_52 < @max_v153spositiontaking_52 - @v153mpositiontaking_52 - @v153apositiontaking_52 THEN @auto_v153spositiontaking_52 ELSE @max_v153spositiontaking_52 - @v153mpositiontaking_52 - @v153apositiontaking_52 END END

		-------------------------------------------------------------------------------
		--maxs1=isauto?s4:s4-m2
		SELECT @max_v153spositiontaking_51 = CASE WHEN ISNULL(@isauto_v153spositiontaking_51, 0)>0 THEN @max_v153spositiontaking_51 ELSE @max_v153spositiontaking_51-@max_v153mapositiontaking_51 END
		SELECT @max_v153spositiontaking_52 = CASE WHEN ISNULL(@isauto_v153spositiontaking_52, 0)>0 THEN @max_v153spositiontaking_52 ELSE @max_v153spositiontaking_52-@max_v153mapositiontaking_52 END
		--s1=s1>maxs1?maxs1:s1
		SELECT @v153spositiontaking_51 = CASE WHEN @v153spositiontaking_51 > @max_v153spositiontaking_51 THEN @max_v153spositiontaking_51 ELSE @v153spositiontaking_51 END
		SELECT @v153spositiontaking_52 = CASE WHEN @v153spositiontaking_52 > @max_v153spositiontaking_52 THEN @max_v153spositiontaking_52 ELSE @v153spositiontaking_52 END

	END --@UpdatePositiontakingv153

--don't update m1,s1 for member under agent was set im2=1
EXEC dbo.Acc_CustSetting3rd_08
	@custid = @custid,
	@roleid = 3,
	@mode = 'horse',
	
	@v151spositiontaking_31 = @v151spositiontaking_31,
	@v151spositiontaking_32 = @v151spositiontaking_32,
	@v151spositiontaking_41 = @v151spositiontaking_41,
	@v151spositiontaking_42 = @v151spositiontaking_42,
	@v151spositiontaking_51 = @v151spositiontaking_51,
	@v151spositiontaking_52 = @v151spositiontaking_52,
	@v152spositiontaking_41 = @v152spositiontaking_41,
	@v152spositiontaking_42 = @v152spositiontaking_42,
	@v152spositiontaking_51 = @v152spositiontaking_51,
	@v152spositiontaking_52 = @v152spositiontaking_52,
	@v153spositiontaking_51 = @v153spositiontaking_51,
	@v153spositiontaking_52 = @v153spositiontaking_52,
	
	@v151mpositiontaking_31 = @v151mpositiontaking_31,
	@v151mpositiontaking_32 = @v151mpositiontaking_32,
	@v151mpositiontaking_41 = @v151mpositiontaking_41,
	@v151mpositiontaking_42 = @v151mpositiontaking_42,
	@v151mpositiontaking_51 = @v151mpositiontaking_51,
	@v151mpositiontaking_52 = @v151mpositiontaking_52,
	@v152mpositiontaking_41 = @v152mpositiontaking_41,
	@v152mpositiontaking_42 = @v152mpositiontaking_42,
	@v152mpositiontaking_51 = @v152mpositiontaking_51,
	@v152mpositiontaking_52 = @v152mpositiontaking_52,
	@v153mpositiontaking_51 = @v153mpositiontaking_51,
	@v153mpositiontaking_52 = @v153mpositiontaking_52 ,
	
	@UpdateMultiple = @UpdateMultiple,
	@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
	@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
	@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
	@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
	@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
	@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51
	
/*
UPDATE cs WITH (ROWLOCK, UPDLOCK)
SET
	mpositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))	
								THEN cs.mpositiontaking	
							ELSE CASE	WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
									WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
									WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
									WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
									WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
									WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
									WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
									WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
									WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
									WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
									WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
									WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
									ELSE cs.mpositiontaking END
							END,
	spositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN cs.spositiontaking 
							ELSE CASE WHEN cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
									WHEN cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
									WHEN cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
									WHEN cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
									WHEN cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51 
									WHEN cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
									WHEN cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
									WHEN cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
									WHEN cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
									WHEN cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
									WHEN cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
									WHEN cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
									ELSE cs.spositiontaking END
							END
FROM CustSetting3rd cs INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
	INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = c.recommend AND cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype 
WHERE c.custid=@custid AND c.roleid = 1 AND acs.isautompositiontaking = 0 AND cs.sporttype in (151,152,153)
*/

--Update auto PT
--------------------------------------------------------
--Update Member account (autompositiontaking field)
EXEC dbo.Acc_CustSetting3rd_09
	@custid = @custid,
	@mrecommend = @mrecommend,
	@roleid = 3,
	@mode = 'horse',
	
	@auto_v151mpositiontaking_31 = @auto_v151mpositiontaking_31,
	@auto_v151mpositiontaking_32 = @auto_v151mpositiontaking_32,
	@auto_v151mpositiontaking_41 = @auto_v151mpositiontaking_41,
	@auto_v151mpositiontaking_42 = @auto_v151mpositiontaking_42,
	@auto_v151mpositiontaking_51 = @auto_v151mpositiontaking_51,
	@auto_v151mpositiontaking_52 = @auto_v151mpositiontaking_52,
	@auto_v152mpositiontaking_41 = @auto_v152mpositiontaking_41,
	@auto_v152mpositiontaking_42 = @auto_v152mpositiontaking_42,
	@auto_v152mpositiontaking_51 = @auto_v152mpositiontaking_51,
	@auto_v152mpositiontaking_52 = @auto_v152mpositiontaking_52,
	@auto_v153mpositiontaking_51 = @auto_v153mpositiontaking_51,
	@auto_v153mpositiontaking_52 = @auto_v153mpositiontaking_52,
	
	@auto_v151mpositiontaking_mem_31 = @auto_v151mpositiontaking_mem_31,
	@auto_v151mpositiontaking_mem_32 = @auto_v151mpositiontaking_mem_32,  
	@auto_v151mpositiontaking_mem_41 = @auto_v151mpositiontaking_mem_41,
	@auto_v151mpositiontaking_mem_42 = @auto_v151mpositiontaking_mem_42,
	@auto_v151mpositiontaking_mem_51 = @auto_v151mpositiontaking_mem_51,
	@auto_v151mpositiontaking_mem_52 = @auto_v151mpositiontaking_mem_52,
	@auto_v152mpositiontaking_mem_41 = @auto_v152mpositiontaking_mem_41,
	@auto_v152mpositiontaking_mem_42 = @auto_v152mpositiontaking_mem_42,
	@auto_v152mpositiontaking_mem_51 = @auto_v152mpositiontaking_mem_51,
	@auto_v152mpositiontaking_mem_52 = @auto_v152mpositiontaking_mem_52,
	@auto_v153mpositiontaking_mem_51 = @auto_v153mpositiontaking_mem_51,
	@auto_v153mpositiontaking_mem_52 = @auto_v153mpositiontaking_mem_52, 
	
	@isauto_v151mpositiontaking_31 = @isauto_v151mpositiontaking_31,
	@isauto_v151mpositiontaking_32 = @isauto_v151mpositiontaking_32,
	@isauto_v151mpositiontaking_41 = @isauto_v151mpositiontaking_41,
	@isauto_v151mpositiontaking_42 = @isauto_v151mpositiontaking_42,
	@isauto_v151mpositiontaking_51 = @isauto_v151mpositiontaking_51,
	@isauto_v151mpositiontaking_52 = @isauto_v151mpositiontaking_52,
	@isauto_v152mpositiontaking_41 = @isauto_v152mpositiontaking_41,
	@isauto_v152mpositiontaking_42 = @isauto_v152mpositiontaking_42,
	@isauto_v152mpositiontaking_51 = @isauto_v152mpositiontaking_51,
	@isauto_v152mpositiontaking_52 = @isauto_v152mpositiontaking_52,
	@isauto_v153mpositiontaking_51 = @isauto_v153mpositiontaking_51,
	@isauto_v153mpositiontaking_52 = @isauto_v153mpositiontaking_52,
	
	@isauto_v151mpositiontaking_mem_31 = @isauto_v151mpositiontaking_mem_31,
	@isauto_v151mpositiontaking_mem_32 = @isauto_v151mpositiontaking_mem_32,
	@isauto_v151mpositiontaking_mem_41 = @isauto_v151mpositiontaking_mem_41,
	@isauto_v151mpositiontaking_mem_42 = @isauto_v151mpositiontaking_mem_42,
	@isauto_v151mpositiontaking_mem_51 = @isauto_v151mpositiontaking_mem_51,
	@isauto_v151mpositiontaking_mem_52 = @isauto_v151mpositiontaking_mem_52,
	@isauto_v152mpositiontaking_mem_41 = @isauto_v152mpositiontaking_mem_41,
	@isauto_v152mpositiontaking_mem_42 = @isauto_v152mpositiontaking_mem_42,
	@isauto_v152mpositiontaking_mem_51 = @isauto_v152mpositiontaking_mem_51,
	@isauto_v152mpositiontaking_mem_52 = @isauto_v152mpositiontaking_mem_52,
	@isauto_v153mpositiontaking_mem_51 = @isauto_v153mpositiontaking_mem_51,
	@isauto_v153mpositiontaking_mem_52 = @isauto_v153mpositiontaking_mem_52,
	
	@UpdateMultiple = @UpdateMultiple,
	@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
	@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
	@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
	@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
	@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
	@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51 

/*
update CustSetting3rd with (ROWLOCK, UPDLOCK) 
set autompositiontaking =  CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN  cs.autompositiontaking
							ELSE b.autompositiontaking END, 
	isautompositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN  cs.isautompositiontaking
							ELSE b.isautompositiontaking END 
from CustSetting3rd as cs inner join 
		(
						select 31 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_31 as autompositiontaking, @isauto_v151mpositiontaking_mem_31 as isautompositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all 	select 32 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_32 as autompositiontaking, @isauto_v151mpositiontaking_mem_32 as isautompositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all 	select 41 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_41 as autompositiontaking, @isauto_v151mpositiontaking_mem_41 as isautompositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all 	select 42 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_42 as autompositiontaking, @isauto_v151mpositiontaking_mem_42 as isautompositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all 	select 51 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_51 as autompositiontaking, @isauto_v151mpositiontaking_mem_51 as isautompositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all 	select 52 as bettype, 151 as sporttype, @auto_v151mpositiontaking_mem_52 as autompositiontaking, @isauto_v151mpositiontaking_mem_52 as isautompositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all 	select 41 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_41 as autompositiontaking, @isauto_v152mpositiontaking_mem_41 as isautompositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all 	select 42 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_42 as autompositiontaking, @isauto_v152mpositiontaking_mem_42 as isautompositiontaking WHERE @UpdatePositiontakingv152_41 = 1
			union all 	select 51 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_51 as autompositiontaking, @isauto_v152mpositiontaking_mem_51 as isautompositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			union all 	select 52 as bettype, 152 as sporttype, @auto_v152mpositiontaking_mem_52 as autompositiontaking, @isauto_v152mpositiontaking_mem_52 as isautompositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			union all 	select 51 as bettype, 153 as sporttype, @auto_v153mpositiontaking_mem_51 as autompositiontaking, @isauto_v153mpositiontaking_mem_51 as isautompositiontaking WHERE @UpdatePositiontakingv153_51 = 1
			union all 	select 52 as bettype, 153 as sporttype, @auto_v153mpositiontaking_mem_52 as autompositiontaking, @isauto_v153mpositiontaking_mem_52 as isautompositiontaking WHERE @UpdatePositiontakingv153_51 = 1
		
		) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
where cs.custid = @custid
if @@Error <> 0
BEGIN
	
	SELECT @ErrCode_cur = 101,
			@ErrMsg_cur =  
					case @Language 
						when 'E' then 'Error updating auto position taking'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
					end	
	SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@UpdatePositiontakingv151 	
	if @isauto_v151mpositiontaking_31 >0 and @UpdatePositiontakingv151_31 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 31
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_31 then @auto_v151mpositiontaking_31 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 31 and cs.sporttype = 151
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END

	if @isauto_v151mpositiontaking_32 >0 and @UpdatePositiontakingv151_31 = 1 
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 32
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_32 then @auto_v151mpositiontaking_32 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 32 and cs.sporttype = 151
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)			
			return
		END
	END
	if @isauto_v151mpositiontaking_41 >0 and @UpdatePositiontakingv151_41 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 41
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_41 then @auto_v151mpositiontaking_41 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 41 and cs.sporttype = 151
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v151mpositiontaking_42 >0 and @UpdatePositiontakingv151_41 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 42
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_42 then @auto_v151mpositiontaking_42 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 42 and cs.sporttype = 151
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v151mpositiontaking_51 >0 and @UpdatePositiontakingv151_51 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 51
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_51 then @auto_v151mpositiontaking_51 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 51 and cs.sporttype = 151
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v151mpositiontaking_52 >0 and @UpdatePositiontakingv151_51 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=151 and bettype = 52
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v151mpositiontaking_52 then @auto_v151mpositiontaking_52 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 52 and cs.sporttype = 151
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
END --@UpdatePositiontakingv151 	

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@UpdatePositiontakingv152
	if @isauto_v152mpositiontaking_41 >0 and @UpdatePositiontakingv152_41 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 41
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_41 then @auto_v152mpositiontaking_41 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 41 and cs.sporttype = 152
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v152mpositiontaking_42 >0 and @UpdatePositiontakingv152_41 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 42
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_42 then @auto_v152mpositiontaking_42 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 42 and cs.sporttype = 152
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v152mpositiontaking_51 >0 and @UpdatePositiontakingv152_51 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 51
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_51 then @auto_v152mpositiontaking_51 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 51 and cs.sporttype = 152
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v152mpositiontaking_52 >0 and @UpdatePositiontakingv152_51 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=152 and bettype = 52
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v152mpositiontaking_52 then @auto_v152mpositiontaking_52 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 52 and cs.sporttype = 152
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
END --@UpdatePositiontakingv152

if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
	BEGIN --@UpdatePositiontakingv153
	if @isauto_v153mpositiontaking_51 >0 and @UpdatePositiontakingv153_51 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=153 and bettype = 51
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v153mpositiontaking_51 then @auto_v153mpositiontaking_51 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 51 and cs.sporttype = 153
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
	if @isauto_v153mpositiontaking_52 >0 and @UpdatePositiontakingv153_51 = 1
	BEGIN
		select @maxpos = mpositiontaking from CustSetting3rd with (NOLOCK) where custid = @mrecommend and sporttype=153 and bettype = 52
		update CustSetting3rd with (ROWLOCK, UPDLOCK) set mpositiontaking = case when @maxpos - apositiontaking>@auto_v153mpositiontaking_52 then @auto_v153mpositiontaking_52 else @maxpos - apositiontaking end
		from CustSetting3rd as cs
		where custid = @custid and cs.bettype = 52 and cs.sporttype = 153
		if @@Error <> 0
		BEGIN
			SELECT @ErrCode_cur = 110,
					@ErrMsg_cur =  
							case @Language 
								when 'E' then 'Error updating auto position taking (for Other sports)'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
							end	
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	END
END--@UpdatePositiontakingv153
*/

--merge code correct pt into sp execrep Acc_CustSetting3rd_08/Acc_CustSetting3rd_09
/*
EXEC dbo.Acc_CustSetting3rd_00
			@custid = @custid, 
			@recommend = @recommend, 
			@mrecommend = @mrecommend, 
			@srecommend = @srecommend,
			@mode = 'horse'
*/
---EXEC dbo.Acc_CustomerUpdMemberHR_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @LogSPData VARCHAR(MAX),
		@TrackingValueDB VARCHAR(5000)

Select @LogSPData = '<Acc_CustomerUpdMemberHR_MAg><info custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' +

'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

'<m v151mpt_31="'+ coalesce(cast(@v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151mpt_32="'+ coalesce(cast(@v151mpositiontaking_32 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_41="'+ coalesce(cast(@v151mpositiontaking_41 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_42="'+ coalesce(cast(@v151mpositiontaking_42 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_51="'+ coalesce(cast(@v151mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_52="'+ coalesce(cast(@v151mpositiontaking_52 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_41="'+ coalesce(cast(@v152mpositiontaking_41 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_42="'+ coalesce(cast(@v152mpositiontaking_42 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_51="'+ coalesce(cast(@v152mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_52="'+ coalesce(cast(@v152mpositiontaking_52 as varchar(50)),SPACE(1)) + '" ' +
'v153mpt_51="'+ coalesce(cast(@v153mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<iam isa_v151mpt_31="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_31 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_32="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_32 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_41="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_42="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_51="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_52="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_41="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_42="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_51="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_52="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_51="'+ coalesce(cast(@isauto_v153mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_52="'+ coalesce(cast(@isauto_v153mpositiontaking_agent_52 as varchar(50)),space(1)) + '" />' +

'<iame isa_v151mpt_mem_31="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_31 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_32="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_32 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_41="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_42="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_51="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_52="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_41="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_42="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_51="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_52="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_mem_51="'+ coalesce(cast(@isauto_v153mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_mem_52="'+ coalesce(cast(@isauto_v153mpositiontaking_mem_52 as varchar(50)),space(1)) + '" />' +

'<aume a_v151mpt_mem_31="'+ coalesce(cast(@auto_v151mpositiontaking_mem_31 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_32="'+ coalesce(cast(@auto_v151mpositiontaking_mem_32 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_mem_41="'+ coalesce(cast(@auto_v151mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_42="'+ coalesce(cast(@auto_v151mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_51="'+ coalesce(cast(@auto_v151mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_52="'+ coalesce(cast(@auto_v151mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_41="'+ coalesce(cast(@auto_v152mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_42="'+ coalesce(cast(@auto_v152mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_51="'+ coalesce(cast(@auto_v152mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_52="'+ coalesce(cast(@auto_v152mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'a_v153mpt_mem_51="'+ coalesce(cast(@auto_v153mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'a_v153mpt_mem_52="'+ coalesce(cast(@auto_v153mpositiontaking_mem_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_MAg>'


Select @TrackingValueDB = '<Acc_CustomerUpdMemberHR_MAg><info custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />' +

'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

'<m v151mpt_31="'+ coalesce(cast(@old_v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151mpt_32="'+ coalesce(cast(@old_v151mpositiontaking_32 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_41="'+ coalesce(cast(@old_v151mpositiontaking_41 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_42="'+ coalesce(cast(@old_v151mpositiontaking_42 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_51="'+ coalesce(cast(@old_v151mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
'v151mpt_52="'+ coalesce(cast(@old_v151mpositiontaking_52 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_41="'+ coalesce(cast(@old_v152mpositiontaking_41 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_42="'+ coalesce(cast(@old_v152mpositiontaking_42 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_51="'+ coalesce(cast(@old_v152mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
'v152mpt_52="'+ coalesce(cast(@old_v152mpositiontaking_52 as varchar(50)),SPACE(1)) + '" ' +
'v153mpt_51="'+ coalesce(cast(@old_v153mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
'v153mpt_52="'+ coalesce(cast(@old_v153mpositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<iam isa_v151mpt_31="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_31 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_32="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_32 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_41="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_42="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_51="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_52="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_41="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_42="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_51="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_52="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_51="'+ coalesce(cast(@isauto_v153mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_52="'+ coalesce(cast(@isauto_v153mpositiontaking_agent_52 as varchar(50)),space(1)) + '" />' +

'<iame isa_v151mpt_mem_31="'+ coalesce(cast(@old_isauto_v151mpositiontaking_mem_31 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_32="'+ coalesce(cast(@old_isauto_v151mpositiontaking_mem_32 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_41="'+ coalesce(cast(@old_isauto_v151mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_42="'+ coalesce(cast(@old_isauto_v151mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_51="'+ coalesce(cast(@old_isauto_v151mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v151mpt_mem_52="'+ coalesce(cast(@old_isauto_v151mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_41="'+ coalesce(cast(@old_isauto_v152mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_42="'+ coalesce(cast(@old_isauto_v152mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_51="'+ coalesce(cast(@old_isauto_v152mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v152mpt_mem_52="'+ coalesce(cast(@old_isauto_v152mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_mem_51="'+ coalesce(cast(@old_isauto_v153mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'isa_v153mpt_mem_52="'+ coalesce(cast(@old_isauto_v153mpositiontaking_mem_52 as varchar(50)),space(1)) + '" />' +

'<aume a_v151mpt_mem_31="'+ coalesce(cast(@old_auto_v151mpositiontaking_mem_31 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_32="'+ coalesce(cast(@old_auto_v151mpositiontaking_mem_32 as varchar(50)),space(1)) + '" ' +
'a_v151mpt_mem_41="'+ coalesce(cast(@old_auto_v151mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_42="'+ coalesce(cast(@old_auto_v151mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_51="'+ coalesce(cast(@old_auto_v151mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'a_v151mpt_mem_52="'+ coalesce(cast(@old_auto_v151mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_41="'+ coalesce(cast(@old_auto_v152mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_42="'+ coalesce(cast(@old_auto_v152mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_51="'+ coalesce(cast(@old_auto_v152mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'a_v152mpt_mem_52="'+ coalesce(cast(@old_auto_v152mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
'a_v153mpt_mem_51="'+ coalesce(cast(@old_auto_v153mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
'a_v153mpt_mem_52="'+ coalesce(cast(@old_auto_v153mpositiontaking_mem_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_MAg>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 409,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdMemberHR_MAg><info custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />' +

	'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

	'<m v151mpt_31="'+ coalesce(cast(@v151mpositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'v151mpt_32="'+ coalesce(cast(@v151mpositiontaking_32 as varchar(50)),SPACE(1)) + '" ' +
	'v151mpt_41="'+ coalesce(cast(@v151mpositiontaking_41 as varchar(50)),SPACE(1)) + '" ' +
	'v151mpt_42="'+ coalesce(cast(@v151mpositiontaking_42 as varchar(50)),SPACE(1)) + '" ' +
	'v151mpt_51="'+ coalesce(cast(@v151mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
	'v151mpt_52="'+ coalesce(cast(@v151mpositiontaking_52 as varchar(50)),SPACE(1)) + '" ' +
	'v152mpt_41="'+ coalesce(cast(@v152mpositiontaking_41 as varchar(50)),SPACE(1)) + '" ' +
	'v152mpt_42="'+ coalesce(cast(@v152mpositiontaking_42 as varchar(50)),SPACE(1)) + '" ' +
	'v152mpt_51="'+ coalesce(cast(@v152mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
	'v152mpt_52="'+ coalesce(cast(@v152mpositiontaking_52 as varchar(50)),SPACE(1)) + '" ' +
	'v153mpt_51="'+ coalesce(cast(@v153mpositiontaking_51 as varchar(50)),SPACE(1)) + '" ' +
	'v153mpt_52="'+ coalesce(cast(@v153mpositiontaking_52 as varchar(50)),space(1)) + '" />' +

	'<iam isa_v151mpt_31="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_31 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_32="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_32 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_41="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_41 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_42="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_42 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_51="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_52="'+ coalesce(cast(@isauto_v151mpositiontaking_agent_52 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_41="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_41 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_42="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_42 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_51="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_52="'+ coalesce(cast(@isauto_v152mpositiontaking_agent_52 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v153mpt_51="'+ coalesce(cast(@isauto_v153mpositiontaking_agent_51 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v153mpt_52="'+ coalesce(cast(@isauto_v153mpositiontaking_agent_52 as varchar(50)),space(1)) + '" />' +

	'<iame isa_v151mpt_mem_31="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_31 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_mem_32="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_32 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_mem_41="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_mem_42="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_mem_51="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v151mpt_mem_52="'+ coalesce(cast(@isauto_v151mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_mem_41="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_mem_42="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_mem_51="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v152mpt_mem_52="'+ coalesce(cast(@isauto_v152mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v153mpt_mem_51="'+ coalesce(cast(@isauto_v153mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
	'isa_v153mpt_mem_52="'+ coalesce(cast(@isauto_v153mpositiontaking_mem_52 as varchar(50)),space(1)) + '" />' +

	'<aume a_v151mpt_mem_31="'+ coalesce(cast(@auto_v151mpositiontaking_mem_31 as varchar(50)),SPACE(1)) + '" ' +
	'a_v151mpt_mem_32="'+ coalesce(cast(@auto_v151mpositiontaking_mem_32 as varchar(50)),space(1)) + '" ' +
	'a_v151mpt_mem_41="'+ coalesce(cast(@auto_v151mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
	'a_v151mpt_mem_42="'+ coalesce(cast(@auto_v151mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
	'a_v151mpt_mem_51="'+ coalesce(cast(@auto_v151mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
	'a_v151mpt_mem_52="'+ coalesce(cast(@auto_v151mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
	'a_v152mpt_mem_41="'+ coalesce(cast(@auto_v152mpositiontaking_mem_41 as varchar(50)),SPACE(1)) + '" ' +
	'a_v152mpt_mem_42="'+ coalesce(cast(@auto_v152mpositiontaking_mem_42 as varchar(50)),SPACE(1)) + '" ' +
	'a_v152mpt_mem_51="'+ coalesce(cast(@auto_v152mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
	'a_v152mpt_mem_52="'+ coalesce(cast(@auto_v152mpositiontaking_mem_52 as varchar(50)),SPACE(1)) + '" ' +
	'a_v153mpt_mem_51="'+ coalesce(cast(@auto_v153mpositiontaking_mem_51 as varchar(50)),SPACE(1)) + '" ' +
	'a_v153mpt_mem_52="'+ coalesce(cast(@auto_v153mpositiontaking_mem_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_MAg>'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 409,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH


Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_MAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_MAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_MAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberHR_MAg] TO [vnteam] AS [dbo]