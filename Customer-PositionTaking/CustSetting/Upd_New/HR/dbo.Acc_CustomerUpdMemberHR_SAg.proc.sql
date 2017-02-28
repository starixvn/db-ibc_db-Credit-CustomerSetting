ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberHR_SAg] 
	@CustID int,--memberid 
	@UserID int,

	@v151spositiontaking_31 smallmoney = 0 OUTPUT,
	@v151spositiontaking_32 smallmoney = 0 OUTPUT,
	@v151spositiontaking_41 smallmoney = 0 OUTPUT,
	@v151spositiontaking_42 smallmoney = 0 OUTPUT,
	@v151spositiontaking_51 smallmoney = 0 OUTPUT,
	@v151spositiontaking_52 smallmoney = 0 OUTPUT,
	@v152spositiontaking_41 smallmoney = 0 OUTPUT,
	@v152spositiontaking_42 smallmoney = 0 OUTPUT,
	@v152spositiontaking_51 smallmoney = 0 OUTPUT,
	@v152spositiontaking_52 smallmoney = 0 OUTPUT,
	@v153spositiontaking_51 smallmoney = 0 OUTPUT,
	@v153spositiontaking_52 smallmoney = 0 OUTPUT,

	@auto_v151spositiontaking_31 smallmoney = 0,
	@auto_v151spositiontaking_32 smallmoney = 0,
	@auto_v151spositiontaking_41 smallmoney = 0,
	@auto_v151spositiontaking_42 smallmoney = 0,
	@auto_v151spositiontaking_51 smallmoney = 0,
	@auto_v151spositiontaking_52 smallmoney = 0,
	@auto_v152spositiontaking_41 smallmoney = 0,
	@auto_v152spositiontaking_42 smallmoney = 0,
	@auto_v152spositiontaking_51 smallmoney = 0,
	@auto_v152spositiontaking_52 smallmoney = 0,
	@auto_v153spositiontaking_51 smallmoney = 0,
	@auto_v153spositiontaking_52 smallmoney = 0,

	@isauto_v151spositiontaking_31 bit = 0,
	@isauto_v151spositiontaking_32 bit = 0,
	@isauto_v151spositiontaking_41 bit = 0,
	@isauto_v151spositiontaking_42 bit = 0,
	@isauto_v151spositiontaking_51 bit = 0,
	@isauto_v151spositiontaking_52 bit = 0,
	@isauto_v152spositiontaking_41 bit = 0,
	@isauto_v152spositiontaking_42 bit = 0,
	@isauto_v152spositiontaking_51 bit = 0,
	@isauto_v152spositiontaking_52 bit = 0,
	@isauto_v153spositiontaking_51 bit = 0,
	@isauto_v153spositiontaking_52 bit = 0,

	@isauto_v151smpositiontaking_31 bit = 0,--i3
	@isauto_v151smpositiontaking_32 bit = 0,
	@isauto_v151smpositiontaking_41 bit = 0,
	@isauto_v151smpositiontaking_42 bit = 0,
	@isauto_v151smpositiontaking_51 bit = 0,
	@isauto_v151smpositiontaking_52 bit = 0,
	@isauto_v152smpositiontaking_41 bit = 0,
	@isauto_v152smpositiontaking_42 bit = 0,
	@isauto_v152smpositiontaking_51 bit = 0,
	@isauto_v152smpositiontaking_52 bit = 0,
	@isauto_v153smpositiontaking_51 bit = 0,
	@isauto_v153smpositiontaking_52 bit = 0,

	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1,
	
	@language varchar(2) = 'E',
	@SubAccID int = 0, --Sub-AccountID
	@IP varchar(15)='',
	@Username varchar(30) = '' OUTPUT,
	@ErrCode varchar(300) = '' OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090520@Phuc
Task : Super edits Member(HR)
DB: DBTXN/bodb02
Original: Acc_CustomerUpdSuper_Member

Revisions:
	- 20090717@Phuc: enrich error message.(-101: general info, -102: closed, -103: suspended, 
						-104: credit, -105: commission, -106: min/max bet, -107: positiontaking
						-108: disable FI, -109: disableHR)
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090801@Shifu: check disabled user
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: Amend to write log in xml format.
	- 20100515@Shifu: Add default value for @v151mpositiontaking_31, @v151mpositiontaking_32
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20110124@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
	- 20110323@Johnson: Check @custid must be member's ID
	- 20110428@Lukas: change tag name when write log <a> -> <au>
	- 20110518@Johnson: write log for old setting
	- 20110706@Johnson: write log for execution time
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20111017@TOM: Apply Multiple Edit Racing PT.
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20130418@Johnson: check auto positiontaking negative
	- 20130607@Johnson: check s1 with max_s1
	- 20131108@Johnson: Apply execrep when update pt on members
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)	
	- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
	- 20140314@Johnson: check constraint min us1, s1 with max(n4-m1-a1,0)
						merge code correct pt into sp execrep Acc_CustSetting3rd_08/Acc_CustSetting3rd_09[redmine:#11562]
	- 20140416@Johson: check s1_max = max(min(s4,l4)-m3,max(n4-m1-a1,0))
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

Declare @ErrCode_cur int, @ErrMsg_cur nvarchar(4000), @roleid tinyint
Select @ErrCode_cur = 0, @ErrMsg_cur = '', @ErrCode = '', @ErrMsg = ''

EXEC Age_CustomerSelCheckBelongingByCustID
	@SessionCustID = @Userid, 
	@Custid = @custid,
	@Username = @Username OUTPUT,
	@roleid = @roleid OUTPUT
	if (@roleid <> 1) return-- return if not member

--Check disable user
EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
IF @ErrCode_Cur > 0
BEGIN
	select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
--end 
declare 
	--m1
	@v151mpositiontaking_31 smallmoney,
	@v151mpositiontaking_32 smallmoney,
	@v151mpositiontaking_41 smallmoney,
	@v151mpositiontaking_42 smallmoney,
	@v151mpositiontaking_51 smallmoney,
	@v151mpositiontaking_52 smallmoney,
	@v152mpositiontaking_41 smallmoney,
	@v152mpositiontaking_42 smallmoney,
	@v152mpositiontaking_51 smallmoney,
	@v152mpositiontaking_52 smallmoney,
	@v153mpositiontaking_51 smallmoney,
	@v153mpositiontaking_52 smallmoney,

	@old_v151spositiontaking_31 smallmoney,
	@old_v151spositiontaking_32 smallmoney,
	@old_v151spositiontaking_41 smallmoney,
	@old_v151spositiontaking_42 smallmoney,
	@old_v151spositiontaking_51 smallmoney,
	@old_v151spositiontaking_52 smallmoney,
	@old_v152spositiontaking_41 smallmoney,
	@old_v152spositiontaking_42 smallmoney,
	@old_v152spositiontaking_51 smallmoney,
	@old_v152spositiontaking_52 smallmoney,
	@old_v153spositiontaking_51 smallmoney,
	@old_v153spositiontaking_52 smallmoney,

	@mrecommend int,
	@recommend int,
	@srecommend int,
	--a1
	@v151apositiontaking_31 smallmoney,
	@v151apositiontaking_32 smallmoney,
	@v151apositiontaking_41 smallmoney,
	@v151apositiontaking_42 smallmoney,
	@v151apositiontaking_51 smallmoney,
	@v151apositiontaking_52 smallmoney,
	@v152apositiontaking_41 smallmoney,
	@v152apositiontaking_42 smallmoney,
	@v152apositiontaking_51 smallmoney,
	@v152apositiontaking_52 smallmoney,
	@v153apositiontaking_51 smallmoney,
	@v153apositiontaking_52 smallmoney,
	--s4
	@v151spositiontaking_31_max smallmoney,
	@v151spositiontaking_32_max smallmoney,
	@v151spositiontaking_41_max smallmoney,
	@v151spositiontaking_42_max smallmoney,
	@v151spositiontaking_51_max smallmoney,
	@v151spositiontaking_52_max smallmoney,
	@v152spositiontaking_41_max smallmoney,
	@v152spositiontaking_42_max smallmoney,
	@v152spositiontaking_51_max smallmoney,
	@v152spositiontaking_52_max smallmoney,
	@v153spositiontaking_51_max smallmoney,
	@v153spositiontaking_52_max smallmoney,
	--s1_max=min(s4,l4)-m3
	 --min(s4,l4) 
	@v151mspos_31_max smallmoney,  
	@v151mspos_32_max smallmoney,  
	@v151mspos_41_max smallmoney,  
	@v151mspos_42_max smallmoney,  
	@v151mspos_51_max smallmoney,  
	@v151mspos_52_max smallmoney,
	@v152mspos_41_max smallmoney,  
	@v152mspos_42_max smallmoney,
	@v152mspos_51_max smallmoney,  
	@v152mspos_52_max smallmoney,
	@v153mspos_51_max smallmoney,  
	@v153mspos_52_max smallmoney,
		
	--m3
	@v151mpos_31 smallmoney,
	@v151mpos_32 smallmoney,
	@v151mpos_41 smallmoney,
	@v151mpos_42 smallmoney,
	@v151mpos_51 smallmoney,
	@v151mpos_52 smallmoney,
	@v152mpos_41 smallmoney,
	@v152mpos_42 smallmoney,
	@v152mpos_51 smallmoney,
	@v152mpos_52 smallmoney,
	@v153mpos_51 smallmoney,
	@v153mpos_52 smallmoney,
	
	--s1_max
	@v151spos_31_max smallmoney,
	@v151spos_32_max smallmoney,
	@v151spos_41_max smallmoney,
	@v151spos_42_max smallmoney,
	@v151spos_51_max smallmoney,
	@v151spos_52_max smallmoney,
	@v152spos_41_max smallmoney,
	@v152spos_42_max smallmoney,
	@v152spos_51_max smallmoney,
	@v152spos_52_max smallmoney,
	@v153spos_51_max smallmoney,
	@v153spos_52_max smallmoney,
	
	--s1_min
	@v151spos_31_min smallmoney,
	@v151spos_32_min smallmoney,
	@v151spos_41_min smallmoney,
	@v151spos_42_min smallmoney,
	@v151spos_51_min smallmoney,
	@v151spos_52_min smallmoney,
	@v152spos_41_min smallmoney,
	@v152spos_42_min smallmoney,
	@v152spos_51_min smallmoney,
	@v152spos_52_min smallmoney,
	@v153spos_51_min smallmoney,
	@v153spos_52_min smallmoney,
	
	
	@old_auto_v151spositiontaking_31 smallmoney ,
	@old_auto_v151spositiontaking_32 smallmoney ,
	@old_auto_v151spositiontaking_41 smallmoney ,
	@old_auto_v151spositiontaking_42 smallmoney ,
	@old_auto_v151spositiontaking_51 smallmoney ,
	@old_auto_v151spositiontaking_52 smallmoney ,
	@old_auto_v152spositiontaking_41 smallmoney ,
	@old_auto_v152spositiontaking_42 smallmoney ,
	@old_auto_v152spositiontaking_51 smallmoney ,
	@old_auto_v152spositiontaking_52 smallmoney ,
	@old_auto_v153spositiontaking_51 smallmoney ,
	@old_auto_v153spositiontaking_52 smallmoney ,

	@old_isauto_v151spositiontaking_31 bit ,
	@old_isauto_v151spositiontaking_32 bit ,	
	@old_isauto_v151spositiontaking_41 bit ,
	@old_isauto_v151spositiontaking_42 bit ,	
	@old_isauto_v151spositiontaking_51 bit ,
	@old_isauto_v151spositiontaking_52 bit ,
	@old_isauto_v152spositiontaking_41 bit ,
	@old_isauto_v152spositiontaking_42 bit ,
	@old_isauto_v152spositiontaking_51 bit ,
	@old_isauto_v152spositiontaking_52 bit ,
	@old_isauto_v153spositiontaking_51 bit ,
	@old_isauto_v153spositiontaking_52 bit

declare @ErrType varchar(1000), @maxpos smallmoney


select @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @username = username from customer with (NOLOCK) where custid = @custid

set @maxpos = 0.5 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check param
declare @IsValid bit
Select @isvalid = 1
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
	BEGIN --@UpdatePositiontakingv151
		if 
			((@v151spositiontaking_31 <0
			or @v151spositiontaking_32 <0
			or @auto_v151spositiontaking_31 <0
			or @auto_v151spositiontaking_32 <0
			or @v151spositiontaking_31 > @maxpos
			or @v151spositiontaking_32 > @maxpos		)
			and @UpdatePositiontakingv151_31 = 1		)
			
			or ((@v151spositiontaking_41 <0
			or @v151spositiontaking_42 <0
			or @auto_v151spositiontaking_41 <0
			or @auto_v151spositiontaking_42 <0
			or @v151spositiontaking_41 > @maxpos
			or @v151spositiontaking_42 > @maxpos		)
			and @UpdatePositiontakingv151_41 = 1		)
			
			or ((@v151spositiontaking_51 <0
			or @v151spositiontaking_52 <0		
			or @auto_v151spositiontaking_51 <0
			or @auto_v151spositiontaking_52 <0	
			or @v151spositiontaking_51 > @maxpos
			or @v151spositiontaking_52 > @maxpos		)
			and @UpdatePositiontakingv151_51 = 1		)
			
		BEGIN
			select @isvalid = 0, @ErrCode_cur = 1
			Select @ErrMsg_cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						end
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)		
			return
		END	
		
		--Check Old_PT <> New_PT
		IF (@UpdatePositiontakingv151_31 = 1)
			BEGIN
				select @v151apositiontaking_31 = apositiontaking, @v151mpositiontaking_31 = mpositiontaking, @old_v151spositiontaking_31 = spositiontaking, @old_auto_v151spositiontaking_31 = autopositiontaking, @old_isauto_v151spositiontaking_31 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=31 and sporttype=151
				select @v151apositiontaking_32 = apositiontaking, @v151mpositiontaking_32 = mpositiontaking, @old_v151spositiontaking_32 = spositiontaking, @old_auto_v151spositiontaking_32 = autopositiontaking, @old_isauto_v151spositiontaking_32 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=32 and sporttype=151
			END
		IF (@UpdatePositiontakingv151_41 = 1)
			BEGIN			
				select @v151apositiontaking_41 = apositiontaking, @v151mpositiontaking_41 = mpositiontaking, @old_v151spositiontaking_41 = spositiontaking, @old_auto_v151spositiontaking_41 = autopositiontaking, @old_isauto_v151spositiontaking_41 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=41 and sporttype=151
				select @v151apositiontaking_42 = apositiontaking, @v151mpositiontaking_42 = mpositiontaking, @old_v151spositiontaking_42 = spositiontaking, @old_auto_v151spositiontaking_42 = autopositiontaking, @old_isauto_v151spositiontaking_42 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=42 and sporttype=151
			END	
		IF (@UpdatePositiontakingv151_51 = 1)
			BEGIN				
				select @v151apositiontaking_51 = apositiontaking, @v151mpositiontaking_51 = mpositiontaking, @old_v151spositiontaking_51 = spositiontaking, @old_auto_v151spositiontaking_51 = autopositiontaking, @old_isauto_v151spositiontaking_51 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=51 and sporttype=151
				select @v151apositiontaking_52 = apositiontaking, @v151mpositiontaking_52 = mpositiontaking, @old_v151spositiontaking_52 = spositiontaking, @old_auto_v151spositiontaking_52 = autopositiontaking, @old_isauto_v151spositiontaking_52 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=52 and sporttype=151		
			END
	END --@UpdatePositiontakingv151

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
	BEGIN --@UpdatePositiontakingv152
		if 			
			((@v152spositiontaking_41 <0
			or @v152spositiontaking_42 <0
			or @auto_v152spositiontaking_41 <0
			or @auto_v152spositiontaking_42 <0
			or @v152spositiontaking_41 > @maxpos
			or @v152spositiontaking_42 > @maxpos	)
			and @UpdatePositiontakingv152_41 = 1	)
			
			or ((@v152spositiontaking_51 <0
			or @v152spositiontaking_52 <0
			or @auto_v152spositiontaking_51 <0
			or @auto_v152spositiontaking_52 <0
			or @v152spositiontaking_51 > @maxpos
			or @v152spositiontaking_52 > @maxpos	)
			and @UpdatePositiontakingv152_51 = 1	)
			
		BEGIN
			select @isvalid = 0, @ErrCode_cur = 1
			Select @ErrMsg_cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						end
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)		
			return
		END	
		
		IF (@UpdatePositiontakingv152_41 = 1)
			BEGIN
				select @v152apositiontaking_41 = apositiontaking, @v152mpositiontaking_41 = mpositiontaking, @old_v152spositiontaking_41 = spositiontaking, @old_auto_v152spositiontaking_41 = autopositiontaking, @old_isauto_v152spositiontaking_41 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=41 and sporttype=152
				select @v152apositiontaking_42 = apositiontaking, @v152mpositiontaking_42 = mpositiontaking, @old_v152spositiontaking_42 = spositiontaking, @old_auto_v152spositiontaking_42 = autopositiontaking, @old_isauto_v152spositiontaking_42 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=42 and sporttype=152
			END
		IF (@UpdatePositiontakingv152_51 = 1)
			BEGIN
				select @v152apositiontaking_51 = apositiontaking, @v152mpositiontaking_51 = mpositiontaking, @old_v152spositiontaking_51 = spositiontaking, @old_auto_v152spositiontaking_51 = autopositiontaking, @old_isauto_v152spositiontaking_51 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=51 and sporttype=152
				select @v152apositiontaking_52 = apositiontaking, @v152mpositiontaking_52 = mpositiontaking, @old_v152spositiontaking_52 = spositiontaking, @old_auto_v152spositiontaking_52 = autopositiontaking, @old_isauto_v152spositiontaking_52 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=52 and sporttype=152
			END
	END --@UpdatePositiontakingv152
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
	BEGIN --@@UpdatePositiontakingv153
		if 
			(   @v153spositiontaking_51 <0	
			or  @v153spositiontaking_52 <0	
			or @auto_v153spositiontaking_51 <0
			or @auto_v153spositiontaking_52 <0
			or @v153spositiontaking_51 > @maxpos 			
			or @v153spositiontaking_52 > @maxpos	)
			and @UpdatePositiontakingv153_51 = 1
		BEGIN
			select @isvalid = 0, @ErrCode_cur = 1
			Select @ErrMsg_cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						end
			SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)		
			return
		END	
		IF (@UpdatePositiontakingv153_51 = 1 )
			BEGIN
				select @v153apositiontaking_51 = apositiontaking, @v153mpositiontaking_51 = mpositiontaking, @old_v153spositiontaking_51 = spositiontaking, @old_auto_v153spositiontaking_51 = autopositiontaking, @old_isauto_v153spositiontaking_51 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=51 and sporttype=153
				select @v153apositiontaking_52 = apositiontaking, @v153mpositiontaking_52 = mpositiontaking, @old_v153spositiontaking_52 = spositiontaking, @old_auto_v153spositiontaking_52 = autopositiontaking, @old_isauto_v153spositiontaking_52 = isautopositiontaking from CustSetting3rd with (NOLOCK) where custid = @custid and bettype=52 and sporttype=153
			END 	
	END --@UpdatePositiontakingv153

IF @v151spositiontaking_31 = @old_v151spositiontaking_31 AND
	@v151spositiontaking_32 = @old_v151spositiontaking_32 AND
	@v151spositiontaking_41 = @old_v151spositiontaking_41 AND
	@v151spositiontaking_42 = @old_v151spositiontaking_42 AND
	@v151spositiontaking_51 = @old_v151spositiontaking_51 AND
	@v151spositiontaking_52 = @old_v151spositiontaking_52 AND
	@v152spositiontaking_41 = @old_v152spositiontaking_41 AND
	@v152spositiontaking_42 = @old_v152spositiontaking_42 AND
	@v152spositiontaking_51 = @old_v152spositiontaking_51 AND
	@v152spositiontaking_52 = @old_v152spositiontaking_52 AND
	@v153spositiontaking_51 = @old_v153spositiontaking_51 AND
	@v153spositiontaking_52 = @old_v153spositiontaking_52 AND
	
	@auto_v151spositiontaking_31 = @old_auto_v151spositiontaking_31 AND
	@auto_v151spositiontaking_32 = @old_auto_v151spositiontaking_32 AND
	@auto_v151spositiontaking_41 = @old_auto_v151spositiontaking_41 AND
	@auto_v151spositiontaking_42 = @old_auto_v151spositiontaking_42 AND
	@auto_v151spositiontaking_51 = @old_auto_v151spositiontaking_51 AND
	@auto_v151spositiontaking_52 = @old_auto_v151spositiontaking_52 AND
	@auto_v152spositiontaking_41 = @old_auto_v152spositiontaking_41 AND
	@auto_v152spositiontaking_42 = @old_auto_v152spositiontaking_42 AND
	@auto_v152spositiontaking_51 = @old_auto_v152spositiontaking_51 AND
	@auto_v152spositiontaking_52 = @old_auto_v152spositiontaking_52 AND
	@auto_v153spositiontaking_51 = @old_auto_v153spositiontaking_51 AND
	@auto_v153spositiontaking_52 = @old_auto_v153spositiontaking_52 AND
	
	@isauto_v151spositiontaking_31 = @old_isauto_v151spositiontaking_31 AND
	@isauto_v151spositiontaking_32 = @old_isauto_v151spositiontaking_32 AND
	@isauto_v151spositiontaking_41 = @old_isauto_v151spositiontaking_41 AND
	@isauto_v151spositiontaking_42 = @old_isauto_v151spositiontaking_42 AND
	@isauto_v151spositiontaking_51 = @old_isauto_v151spositiontaking_51 AND
	@isauto_v151spositiontaking_52 = @old_isauto_v151spositiontaking_52 AND
	@isauto_v152spositiontaking_41 = @old_isauto_v152spositiontaking_41 AND
	@isauto_v152spositiontaking_42 = @old_isauto_v152spositiontaking_42 AND
	@isauto_v152spositiontaking_51 = @old_isauto_v152spositiontaking_51 AND
	@isauto_v152spositiontaking_52 = @old_isauto_v152spositiontaking_52 AND
	@isauto_v153spositiontaking_51 = @old_isauto_v153spositiontaking_51 AND
	@isauto_v153spositiontaking_52 = @old_isauto_v153spositiontaking_52
BEGIN
	Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)
	return
END 


	select @ErrType = ''
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
BEGIN --@@UpdatePositiontakingv151	
	
	if (@UpdatePositiontakingv151_31 = 1 )
		begin
			select @v151spositiontaking_31_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=31 and sporttype=151
			select @v151spositiontaking_32_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=32 and sporttype=151
			
			--min(s4,l4), 
			--s1_min = max(n4-m1-a1,0) 
			SELECT @v151mspos_31_max = CASE WHEN @v151spositiontaking_31_max < co.maxpositiontaking THEN @v151spositiontaking_31_max ELSE co.maxpositiontaking END,
					@v151spos_31_min = CASE WHEN co.minpositiontaking - @v151mpositiontaking_31 - @v151apositiontaking_31 > 0 THEN co.minpositiontaking - @v151mpositiontaking_31 - @v151apositiontaking_31 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 31 and sporttype = 151
			
			SELECT @v151mspos_32_max = CASE WHEN @v151spositiontaking_32_max < co.maxpositiontaking THEN @v151spositiontaking_32_max ELSE co.maxpositiontaking END, 
					@v151spos_32_min = CASE WHEN co.minpositiontaking - @v151mpositiontaking_32 - @v151apositiontaking_32 > 0 THEN co.minpositiontaking - @v151mpositiontaking_32 - @v151apositiontaking_32 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 32 and sporttype = 151
			
			--m3
			SELECT @v151mpos_31 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 151 and bettype = 31
			SELECT @v151mpos_32 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 151 and bettype = 32
			--s1_max = max(min(s4,l4)-m3,s1_min)
			SELECT @v151spos_31_max = case when @v151mspos_31_max - @v151mpos_31 > @v151spos_31_min then @v151mspos_31_max - @v151mpos_31 else @v151spos_31_min end
			SELECT @v151spos_32_max = case when @v151mspos_32_max - @v151mpos_32 > @v151spos_32_min then @v151mspos_32_max - @v151mpos_32 else @v151spos_32_min end
			
		
			
		end
	if (@UpdatePositiontakingv151_41 = 1 )
		begin
			select @v151spositiontaking_41_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=41 and sporttype=151
			select @v151spositiontaking_42_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=42 and sporttype=151
			
			--min(s4,l4),
			--s1_min = max(n4-m1-a1,0)  
			SELECT @v151mspos_41_max = CASE WHEN @v151spositiontaking_41_max < co.maxpositiontaking THEN @v151spositiontaking_31_max ELSE co.maxpositiontaking END, 
					@v151spos_41_min = CASE WHEN co.minpositiontaking - @v151mpositiontaking_41 - @v151apositiontaking_41 > 0 THEN co.minpositiontaking - @v151mpositiontaking_41 - @v151apositiontaking_41 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 41 and sporttype = 151
			
			SELECT @v151mspos_42_max = CASE WHEN @v151spositiontaking_42_max < co.maxpositiontaking THEN @v151spositiontaking_32_max ELSE co.maxpositiontaking END ,
				@v151spos_42_min = CASE WHEN co.minpositiontaking - @v151mpositiontaking_42 - @v151apositiontaking_42 > 0 THEN co.minpositiontaking - @v151mpositiontaking_42 - @v151apositiontaking_42 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 42 and sporttype = 151
			
			--m3
			SELECT @v151mpos_41 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 151 and bettype = 41
			SELECT @v151mpos_42 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 151 and bettype = 42
			--s1_max = max(min(s4,l4)-m3,s1_min)
			SELECT @v151spos_41_max = case when @v151mspos_41_max - @v151mpos_41 > @v151spos_41_min then @v151mspos_41_max - @v151mpos_41 else @v151spos_41_min end
			SELECT @v151spos_42_max = case when @v151mspos_42_max - @v151mpos_42 > @v151spos_42_min then @v151mspos_42_max - @v151mpos_42 else @v151spos_42_min end
		end
	if (@UpdatePositiontakingv151_51 = 1 )
		begin
			select @v151spositiontaking_51_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=151
			select @v151spositiontaking_52_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=52 and sporttype=151
			
			--min(s4,l4) 
			--s1_min = max(n4-m1-a1,0)
			SELECT @v151mspos_51_max = CASE WHEN @v151spositiontaking_51_max < co.maxpositiontaking THEN @v151spositiontaking_51_max ELSE co.maxpositiontaking END, 
					@v151spos_51_min = CASE WHEN co.minpositiontaking - @v151mpositiontaking_51 - @v151apositiontaking_51 > 0 THEN co.minpositiontaking - @v151mpositiontaking_51 - @v151apositiontaking_51 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 51 and sporttype = 151
			
			SELECT @v151mspos_52_max = CASE WHEN @v151spositiontaking_52_max < co.maxpositiontaking THEN @v151spositiontaking_52_max ELSE co.maxpositiontaking END, 
					@v151spos_52_min = CASE WHEN co.minpositiontaking - @v151mpositiontaking_52 - @v151apositiontaking_52 > 0 THEN co.minpositiontaking - @v151mpositiontaking_52 - @v151apositiontaking_52 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 52 and sporttype = 151
			
			--m3
			SELECT @v151mpos_51 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 151 and bettype = 51
			SELECT @v151mpos_52 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 151 and bettype = 52
			--s1_max = max(min(s4,l4)-m3,s1_min)
			SELECT @v151spos_51_max = case when @v151mspos_51_max - @v151mpos_51 > @v151spos_51_min THEN @v151mspos_51_max - @v151mpos_51 else @v151spos_51_min end
			SELECT @v151spos_52_max = case when @v151mspos_52_max - @v151mpos_52 > @v151spos_52_min then @v151mspos_52_max - @v151mpos_52 else @v151spos_52_min end
		end
		
	--us1<=l4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ case when b.bettype = 51 then 'Win. Aust Tote' when b.bettype = 52 then 'Place. Aust Tote' else typenamee end + ', '
	from CustOverride3rd as co with (NOLOCK) inner join
	(
						select 151 as sporttype, 31 as bettype, @auto_v151spositiontaking_31 as autopositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
		union all		select 151 as sporttype, 32 as bettype, @auto_v151spositiontaking_32 as autopositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
		union all		select 151 as sporttype, 41 as bettype, @auto_v151spositiontaking_41 as autopositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
		union all		select 151 as sporttype, 42 as bettype, @auto_v151spositiontaking_42 as autopositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
		union all		select 151 as sporttype, 51 as bettype, @auto_v151spositiontaking_51 as autopositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		union all		select 151 as sporttype, 52 as bettype, @auto_v151spositiontaking_52 as autopositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
	) as b on co.sporttype=b.sporttype and co.bettype=b.bettype
		inner join @tmp_Sports sports on b.sporttype = sports.sporttype
		inner join @tmp_Bettype bettype on b.bettype = bettype.typeid

	where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking))


	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode_cur = 2
		Select @ErrMsg_cur = 	@UserName + ': '+
			case @Language 
							when 'E' then 'Wrong position taking (min/max set by company) ('+@ErrType+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
					end
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--us1<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
	from CustSetting3rd as cs with (NOLOCK) inner join
		(
						select 31 as bettype, 151 as sporttype, @auto_v151spositiontaking_31 as autopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all 	select 32 as bettype, 151 as sporttype, @auto_v151spositiontaking_32 as autopositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 41 as bettype, 151 as sporttype, @auto_v151spositiontaking_41 as autopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all 	select 42 as bettype, 151 as sporttype, @auto_v151spositiontaking_42 as autopositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 51 as bettype, 151 as sporttype, @auto_v151spositiontaking_51 as autopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all 	select 52 as bettype, 151 as sporttype, @auto_v151spositiontaking_52 as autopositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where cs.custid = @srecommend
		and 
		((cs.spositiontaking<b.autopositiontaking))
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							end	, @ErrCode_cur = 223						
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--us1>= us1_min (=s1_min)
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Min: '+ cast((b.minpositiontaking) as varchar(10)) + '<br>'
	from 
		(
						select 31 as bettype, 151 as sporttype, @auto_v151spositiontaking_31 as autopositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking, @v151spos_31_min as minpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all 	select 32 as bettype, 151 as sporttype, @auto_v151spositiontaking_32 as autopositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking, @v151spos_32_min as minpositiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 41 as bettype, 151 as sporttype, @auto_v151spositiontaking_41 as autopositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking, @v151spos_41_min as minpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all 	select 42 as bettype, 151 as sporttype, @auto_v151spositiontaking_42 as autopositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking, @v151spos_42_min as minpositiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 51 as bettype, 151 as sporttype, @auto_v151spositiontaking_51 as autopositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking, @v151spos_51_min as minpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all 	select 52 as bettype, 151 as sporttype, @auto_v151spositiontaking_52 as autopositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking, @v151spos_52_min as minpositiontaking WHERE @UpdatePositiontakingv151_51 = 1
		) as b 
	inner join @tmp_Sports sports on b.sporttype = sports.sporttype
	inner join @tmp_Bettype bettype on b.bettype = bettype.typeid
	where b.isautopositiontaking = 1 and b.autopositiontaking < b.minpositiontaking 
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							end	, @ErrCode_cur = 300						
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--s1<=s4	
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
	from CustSetting3rd as cs with (NOLOCK) inner join
		(
						select 31 as bettype, 151 as sporttype, @v151spositiontaking_31 as positiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all 	select 32 as bettype, 151 as sporttype, @v151spositiontaking_32 as positiontaking WHERE @UpdatePositiontakingv151_31 = 1
			union all	select 41 as bettype, 151 as sporttype, @v151spositiontaking_41 as positiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all 	select 42 as bettype, 151 as sporttype, @v151spositiontaking_42 as positiontaking WHERE @UpdatePositiontakingv151_41 = 1
			union all	select 51 as bettype, 151 as sporttype, @v151spositiontaking_51 as positiontaking WHERE @UpdatePositiontakingv151_51 = 1
			union all 	select 52 as bettype, 151 as sporttype, @v151spositiontaking_52 as positiontaking WHERE @UpdatePositiontakingv151_51 = 1
		) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where cs.custid = @srecommend
		and 
		((cs.spositiontaking<b.positiontaking))
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong  position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							end, @ErrCode_cur = 5
		Select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--s1<=s1_max
	select @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((t.spositiontaking_max) as varchar(10)) + '<br>'			
	FROM 	
		(
			SELECT 151 as sporttype, 31 as bettype, @v151spositiontaking_31 as spositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking, @isauto_v151smpositiontaking_31 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_31 = 1 
			UNION ALL SELECT 151 as sporttype, 32 as bettype, @v151spositiontaking_32 as spositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking, @isauto_v151smpositiontaking_32 as isautosmpositiontaking WHERE @UpdatePositiontakingv151_31 = 1 
			UNION ALL SELECT 151 as sporttype, 41 as bettype, @v151spositiontaking_41 as spositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking, @isauto_v151smpositiontaking_41 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_41 = 1 
			UNION ALL SELECT 151 as sporttype, 42 as bettype, @v151spositiontaking_42 as spositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking, @isauto_v151smpositiontaking_42 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_41 = 1 
			UNION ALL SELECT 151 as sporttype, 51 as bettype, @v151spositiontaking_51 as spositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking, @isauto_v151smpositiontaking_51 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_51 = 1 
			UNION ALL SELECT 151 as sporttype, 52 as bettype, @v151spositiontaking_52 as spositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking, @isauto_v151smpositiontaking_52 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_51 = 1 
		)b
		INNER JOIN
		(
			SELECT 151 as sporttype, 31 as bettype, @v151spos_31_max as spositiontaking_max
			UNION ALL SELECT 151 as sporttype, 32 as bettype, @v151spos_32_max as spositiontaking_max
			UNION ALL SELECT 151 as sporttype, 41 as bettype, @v151spos_41_max as spositiontaking_max
			UNION ALL SELECT 151 as sporttype, 42 as bettype, @v151spos_42_max as spositiontaking_max
			UNION ALL SELECT 151 as sporttype, 51 as bettype, @v151spos_51_max as spositiontaking_max
			UNION ALL SELECT 151 as sporttype, 52 as bettype, @v151spos_52_max as spositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype 
		INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
	WHERE b.spositiontaking > t.spositiontaking_max and isautopositiontaking = 0 and isauto_smpositiontaking = 0
	
	if @ErrType <>''
		BEGIN
			select @ErrCode_Cur = 11
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		
	--s1>=s1_min
	select @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Min: '+ cast((t.spositiontaking_min) as varchar(10)) + '<br>'			
	FROM 	
		(
			SELECT 151 as sporttype, 31 as bettype, @v151spositiontaking_31 as spositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking, @isauto_v151smpositiontaking_31 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_31 = 1 
			UNION ALL SELECT 151 as sporttype, 32 as bettype, @v151spositiontaking_32 as spositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking, @isauto_v151smpositiontaking_32 as isautosmpositiontaking WHERE @UpdatePositiontakingv151_31 = 1 
			UNION ALL SELECT 151 as sporttype, 41 as bettype, @v151spositiontaking_41 as spositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking, @isauto_v151smpositiontaking_41 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_41 = 1 
			UNION ALL SELECT 151 as sporttype, 42 as bettype, @v151spositiontaking_42 as spositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking, @isauto_v151smpositiontaking_42 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_41 = 1 
			UNION ALL SELECT 151 as sporttype, 51 as bettype, @v151spositiontaking_51 as spositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking, @isauto_v151smpositiontaking_51 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_51 = 1 
			UNION ALL SELECT 151 as sporttype, 52 as bettype, @v151spositiontaking_52 as spositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking, @isauto_v151smpositiontaking_52 as isauto_smpositiontaking  WHERE @UpdatePositiontakingv151_51 = 1 
		)b
		INNER JOIN
		(
			SELECT 151 as sporttype, 31 as bettype, @v151spos_31_min as spositiontaking_min
			UNION ALL SELECT 151 as sporttype, 32 as bettype, @v151spos_32_min as spositiontaking_min
			UNION ALL SELECT 151 as sporttype, 41 as bettype, @v151spos_41_min as spositiontaking_min
			UNION ALL SELECT 151 as sporttype, 42 as bettype, @v151spos_42_min as spositiontaking_min
			UNION ALL SELECT 151 as sporttype, 51 as bettype, @v151spos_51_min as spositiontaking_min
			UNION ALL SELECT 151 as sporttype, 52 as bettype, @v151spos_52_min as spositiontaking_min
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype 
		INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
	WHERE b.spositiontaking < t.spositiontaking_min and isautopositiontaking = 0 and isauto_smpositiontaking = 0
	
	if @ErrType <>''
		BEGIN
			select @ErrCode_Cur = 100
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
			
	select 
		@v151spositiontaking_31 = case when @v151mpositiontaking_31+@v151spositiontaking_31+@v151apositiontaking_31>@v151spositiontaking_31_max then @v151spositiontaking_31_max-@v151mpositiontaking_31-@v151apositiontaking_31 else @v151spositiontaking_31 end,
		@v151spositiontaking_32 = case when @v151mpositiontaking_32+@v151spositiontaking_32+@v151apositiontaking_32>@v151spositiontaking_32_max then @v151spositiontaking_32_max-@v151mpositiontaking_32-@v151apositiontaking_32 else @v151spositiontaking_32 end,
		@v151spositiontaking_41 = case when @v151mpositiontaking_41+@v151spositiontaking_41+@v151apositiontaking_41>@v151spositiontaking_41_max then @v151spositiontaking_41_max-@v151mpositiontaking_41-@v151apositiontaking_41 else @v151spositiontaking_41 end,
		@v151spositiontaking_42 = case when @v151mpositiontaking_42+@v151spositiontaking_42+@v151apositiontaking_42>@v151spositiontaking_42_max then @v151spositiontaking_42_max-@v151mpositiontaking_42-@v151apositiontaking_42 else @v151spositiontaking_42 end,
		@v151spositiontaking_51 = case when @v151mpositiontaking_51+@v151spositiontaking_51+@v151apositiontaking_51>@v151spositiontaking_51_max then @v151spositiontaking_51_max-@v151mpositiontaking_51-@v151apositiontaking_41 else @v151spositiontaking_51 end,
		@v151spositiontaking_52 = case when @v151mpositiontaking_52+@v151spositiontaking_52+@v151apositiontaking_52>@v151spositiontaking_52_max then @v151spositiontaking_52_max-@v151mpositiontaking_52-@v151apositiontaking_42 else @v151spositiontaking_52 end
		

	select 
		@v151spositiontaking_31 = case when @v151spositiontaking_31<0 then 0 else @v151spositiontaking_31 end,
		@v151spositiontaking_32 = case when @v151spositiontaking_32<0 then 0 else @v151spositiontaking_32 end,
		@v151spositiontaking_41 = case when @v151spositiontaking_41<0 then 0 else @v151spositiontaking_41 end,
		@v151spositiontaking_42 = case when @v151spositiontaking_42<0 then 0 else @v151spositiontaking_42 end,
		@v151spositiontaking_51 = case when @v151spositiontaking_51<0 then 0 else @v151spositiontaking_51 end,
		@v151spositiontaking_52 = case when @v151spositiontaking_52<0 then 0 else @v151spositiontaking_52 end

END --@@UpdatePositiontakingv151	


if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
BEGIN --@@UpdatePositiontakingv152	
	
	if  @UpdatePositiontakingv152_41 = 1
		begin
			select @v152spositiontaking_41_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=41 and sporttype=152
			select @v152spositiontaking_42_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=42 and sporttype=152
			
			--min(s4,l4) 
			SELECT @v152mspos_41_max = CASE WHEN @v152spositiontaking_41_max < co.maxpositiontaking THEN @v152spositiontaking_41_max ELSE co.maxpositiontaking END, 
					@v152spos_41_min = CASE WHEN co.minpositiontaking - @v152mpositiontaking_41 - @v152apositiontaking_41 > 0 THEN co.minpositiontaking - @v152mpositiontaking_41 - @v152apositiontaking_41 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 41 and sporttype = 152
			
			SELECT @v152mspos_42_max = CASE WHEN @v152spositiontaking_42_max < co.maxpositiontaking THEN @v152spositiontaking_42_max ELSE co.maxpositiontaking END, 
					@v152spos_42_min = CASE WHEN co.minpositiontaking - @v152mpositiontaking_42 - @v152apositiontaking_42 > 0 THEN co.minpositiontaking - @v152mpositiontaking_42 - @v152apositiontaking_42 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 42 and sporttype = 152
			
			--m3
			SELECT @v152mpos_41 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 152 and bettype = 41
			SELECT @v152mpos_42 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 152 and bettype = 42
			--s1_max = max(min(s4,l4)-m3,s1_min)
			SELECT @v152spos_41_max = case when @v152mspos_41_max - @v152mpos_41 > @v152spos_41_min then @v152mspos_41_max - @v152mpos_41 else @v152spos_41_min end
			SELECT @v152spos_42_max = case when @v152mspos_42_max - @v152mpos_42 > @v152spos_42_min then @v152mspos_42_max - @v152mpos_42 else @v152spos_42_min end
		end
	if  @UpdatePositiontakingv152_51 = 1
		begin
			select @v152spositiontaking_51_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=152
			select @v152spositiontaking_52_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=52 and sporttype=152
			
			--min(s4,l4) 
			SELECT @v152mspos_51_max = CASE WHEN @v152spositiontaking_51_max < co.maxpositiontaking THEN @v152spositiontaking_51_max ELSE co.maxpositiontaking END, 
					@v152spos_51_min = CASE WHEN co.minpositiontaking - @v152mpositiontaking_51 - @v152apositiontaking_51 > 0 THEN co.minpositiontaking - @v152mpositiontaking_51 - @v152apositiontaking_51 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 51 and sporttype = 152
			
			SELECT @v152mspos_52_max = CASE WHEN @v152spositiontaking_52_max < co.maxpositiontaking THEN @v152spositiontaking_52_max ELSE co.maxpositiontaking END, 
					@v152spos_52_min = CASE WHEN co.minpositiontaking - @v152mpositiontaking_52 - @v152apositiontaking_52 > 0 THEN co.minpositiontaking - @v152mpositiontaking_52 - @v152apositiontaking_52 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 52 and sporttype = 152
			
			--m3
			SELECT @v152mpos_51 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 152 and bettype = 51
			SELECT @v152mpos_52 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 152 and bettype = 52
			--s1_max = max(min(s4,l4)-m3,s1_min)
			SELECT @v152spos_51_max = case when @v152mspos_51_max - @v152mpos_51 > @v152spos_51_min then @v152mspos_51_max - @v152mpos_51 else @v152spos_51_min end
			SELECT @v152spos_52_max = case when @v152mspos_52_max - @v152mpos_52 > @v152spos_52_min then @v152mspos_52_max - @v152mpos_52 else @v152spos_52_min end
		end
	
	--us1<=l4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ case when b.bettype = 51 then 'Win. Aust Tote' when b.bettype = 52 then 'Place. Aust Tote' else typenamee end + ', '
	from CustOverride3rd as co with (NOLOCK) inner join
	(
					select 152 as sporttype, 41 as bettype, @auto_v152spositiontaking_41 as autopositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking where @UpdatePositiontakingv152_41 = 1
	union all		select 152 as sporttype, 42 as bettype, @auto_v152spositiontaking_42 as autopositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking where @UpdatePositiontakingv152_41 = 1	
	union all		select 152 as sporttype, 51 as bettype, @auto_v152spositiontaking_51 as autopositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv152_51 = 1
	union all		select 152 as sporttype, 52 as bettype, @auto_v152spositiontaking_52 as autopositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv152_51 = 1
	) as b on co.sporttype=b.sporttype and co.bettype=b.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid

	where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking))


	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode_cur = 2
		Select @ErrMsg_cur = 	@UserName + ': '+
			case @Language 
							when 'E' then 'Wrong position taking (min/max set by company) ('+@ErrType+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
					end
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	-- End check parameter
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--us1<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
	from CustSetting3rd as cs with (NOLOCK) inner join
		(
						select 41 as bettype, 152 as sporttype, @auto_v152spositiontaking_41 as autopositiontaking where @UpdatePositiontakingv152_41 = 1
			union all 	select 42 as bettype, 152 as sporttype, @auto_v152spositiontaking_42 as autopositiontaking where @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype, 152 as sporttype, @auto_v152spositiontaking_51 as autopositiontaking where @UpdatePositiontakingv152_51 = 1
			union all 	select 52 as bettype, 152 as sporttype, @auto_v152spositiontaking_52 as autopositiontaking where @UpdatePositiontakingv152_51 = 1
		) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where cs.custid = @srecommend
		and 
		((cs.spositiontaking<b.autopositiontaking))
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							end	, @ErrCode_cur = 223						
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--us1 >= us1_min (=s1_min)
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Min: '+ cast((b.minpositiontaking) as varchar(10)) + '<br>'
	from 
		(
						select 41 as bettype, 152 as sporttype, @auto_v152spositiontaking_41 as autopositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking, @v151spos_41_min as minpositiontaking where @UpdatePositiontakingv152_41 = 1
			union all 	select 42 as bettype, 152 as sporttype, @auto_v152spositiontaking_42 as autopositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking, @v151spos_42_min as minpositiontaking where @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype, 152 as sporttype, @auto_v152spositiontaking_51 as autopositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking, @v151spos_51_min as minpositiontaking where @UpdatePositiontakingv152_51 = 1
			union all 	select 52 as bettype, 152 as sporttype, @auto_v152spositiontaking_52 as autopositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking, @v151spos_52_min as minpositiontaking where @UpdatePositiontakingv152_51 = 1
		) as b 
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where b.isautopositiontaking = 1 and b.autopositiontaking < b.minpositiontaking
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							end	, @ErrCode_cur = 300						
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--s1<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
	from CustSetting3rd as cs with (NOLOCK) inner join
		(
						select 41 as bettype, 152 as sporttype, @v152spositiontaking_41 as positiontaking where @UpdatePositiontakingv152_41 = 1
			union all 	select 42 as bettype, 152 as sporttype, @v152spositiontaking_42 as positiontaking where @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype, 152 as sporttype, @v152spositiontaking_51 as positiontaking where @UpdatePositiontakingv152_51 = 1
			union all 	select 52 as bettype, 152 as sporttype, @v152spositiontaking_52 as positiontaking where @UpdatePositiontakingv152_51 = 1
		) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where cs.custid = @srecommend
		and 
		((cs.spositiontaking<b.positiontaking))
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong  position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							end, @ErrCode_cur = 5
		Select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--s1<=s1_max	
	select @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((t.spositiontaking_max) as varchar(10)) + '<br>'			
	FROM 	
		(			
			SELECT 152 as sporttype, 41 as bettype, @v152spositiontaking_41 as spositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking, @isauto_v152smpositiontaking_41 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_41 = 1 
			UNION ALL SELECT 152 as sporttype, 42 as bettype, @v152spositiontaking_42 as spositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking, @isauto_v152smpositiontaking_42 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_41 = 1 
			UNION ALL SELECT 152 as sporttype, 51 as bettype, @v152spositiontaking_51 as spositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking, @isauto_v152smpositiontaking_51 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_51 = 1 
			UNION ALL SELECT 152 as sporttype, 52 as bettype, @v152spositiontaking_52 as spositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking, @isauto_v152smpositiontaking_52 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_51 = 1 
		)b
		INNER JOIN
		(
			SELECT 152 as sporttype, 41 as bettype, @v152spos_41_max as spositiontaking_max
			UNION ALL SELECT 152 as sporttype, 42 as bettype, @v152spos_42_max as spositiontaking_max
			UNION ALL SELECT 152 as sporttype, 51 as bettype, @v152spos_51_max as spositiontaking_max
			UNION ALL SELECT 152 as sporttype, 52 as bettype, @v152spos_52_max as spositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype 
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
	WHERE b.spositiontaking > t.spositiontaking_max and isautopositiontaking = 0 and isauto_smpositiontaking = 0
	
	if @ErrType <>''
		BEGIN
			select @ErrCode_cur = 11
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	
	--s1>=s1_min
	select @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Min: '+ cast((t.spositiontaking_min) as varchar(10)) + '<br>'			
	FROM 	
		(			
			SELECT 152 as sporttype, 41 as bettype, @v152spositiontaking_41 as spositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking, @isauto_v152smpositiontaking_41 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_41 = 1 
			UNION ALL SELECT 152 as sporttype, 42 as bettype, @v152spositiontaking_42 as spositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking, @isauto_v152smpositiontaking_42 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_41 = 1 
			UNION ALL SELECT 152 as sporttype, 51 as bettype, @v152spositiontaking_51 as spositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking, @isauto_v152smpositiontaking_51 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_51 = 1 
			UNION ALL SELECT 152 as sporttype, 52 as bettype, @v152spositiontaking_52 as spositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking, @isauto_v152smpositiontaking_52 as isauto_smpositiontaking WHERE @UpdatePositiontakingv152_51 = 1 
		)b
		INNER JOIN
		(
			SELECT 152 as sporttype, 41 as bettype, @v152spos_41_min as spositiontaking_min
			UNION ALL SELECT 152 as sporttype, 42 as bettype, @v152spos_42_min as spositiontaking_min
			UNION ALL SELECT 152 as sporttype, 51 as bettype, @v152spos_51_min as spositiontaking_min
			UNION ALL SELECT 152 as sporttype, 52 as bettype, @v152spos_52_min as spositiontaking_min
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype 
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
	WHERE b.spositiontaking < t.spositiontaking_min and isautopositiontaking = 0 and isauto_smpositiontaking = 0
	
	if @ErrType <>''
		BEGIN
			select @ErrCode_cur = 12
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
			
	select 
		@v152spositiontaking_41 = case when @v152mpositiontaking_41+@v152spositiontaking_41+@v152apositiontaking_41>@v152spositiontaking_41_max then @v152spositiontaking_41_max-@v152mpositiontaking_41-@v151apositiontaking_41 else @v152spositiontaking_41 end,
		@v152spositiontaking_42 = case when @v152mpositiontaking_42+@v152spositiontaking_42+@v152apositiontaking_42>@v152spositiontaking_42_max then @v152spositiontaking_42_max-@v152mpositiontaking_42-@v151apositiontaking_42 else @v152spositiontaking_42 end,
		@v152spositiontaking_51 = case when @v152mpositiontaking_51+@v152spositiontaking_51+@v152apositiontaking_51>@v152spositiontaking_51_max then @v152spositiontaking_51_max-@v152mpositiontaking_51-@v151apositiontaking_41 else @v152spositiontaking_51 end,
		@v152spositiontaking_52 = case when @v152mpositiontaking_52+@v152spositiontaking_52+@v152apositiontaking_52>@v152spositiontaking_52_max then @v152spositiontaking_52_max-@v152mpositiontaking_52-@v151apositiontaking_42 else @v152spositiontaking_52 end

	select 
		@v152spositiontaking_41 = case when @v152spositiontaking_41<0 then 0 else @v152spositiontaking_41 end,
		@v152spositiontaking_42 = case when @v152spositiontaking_42<0 then 0 else @v152spositiontaking_42 end,
		@v152spositiontaking_51 = case when @v152spositiontaking_51<0 then 0 else @v152spositiontaking_51 end,
		@v152spositiontaking_52 = case when @v152spositiontaking_52<0 then 0 else @v152spositiontaking_52 end

END --@@UpdatePositiontakingv152



if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
BEGIN --@@UpdatePositiontakingv153		
	if 	(@UpdatePositiontakingv153_51 = 1 )
		begin
			select @v153spositiontaking_51_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=51 and sporttype=153
			select @v153spositiontaking_52_max = spositiontaking from CustSetting3rd with (NOLOCK) where custid = @srecommend and bettype=52 and sporttype=153
			
			--min(s4,l4) 
			SELECT @v153mspos_51_max = CASE WHEN @v153spositiontaking_51_max < co.maxpositiontaking THEN @v153spositiontaking_51_max ELSE co.maxpositiontaking END,
					@v153spos_51_min = CASE WHEN co.minpositiontaking - @v153mpositiontaking_51 - @v153apositiontaking_51 > 0 THEN co.minpositiontaking - @v153mpositiontaking_51 - @v153apositiontaking_51 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 51 and sporttype = 153
			
			SELECT @v153mspos_52_max = CASE WHEN @v153spositiontaking_52_max < co.maxpositiontaking THEN @v153spositiontaking_52_max ELSE co.maxpositiontaking END,
					@v153spos_52_min = CASE WHEN co.minpositiontaking - @v153mpositiontaking_52 - @v153apositiontaking_52 > 0 THEN co.minpositiontaking - @v153mpositiontaking_52 - @v153apositiontaking_52 ELSE 0 END
			FROM CustOverride3rd co WITH(NOLOCK) WHERE custid = @srecommend and bettype = 52 and sporttype = 153
			
			--m3
			SELECT @v153mpos_51 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 153 and bettype = 51
			SELECT @v153mpos_52 = mpositiontaking FROM custsetting3rd WITH(NOLOCK) WHERE custid = @mrecommend and sporttype = 153 and bettype = 52
			--s1_max = min(s4,l4)-m3
			SELECT @v153spos_51_max = case when @v153mspos_51_max - @v153mpos_51 > @v153spos_51_min then @v153mspos_51_max - @v153mpos_51 else @v153spos_51_min end
			SELECT @v153spos_52_max = case when @v153mspos_52_max - @v153mpos_52 > @v153spos_52_min then @v153mspos_52_max - @v153mpos_52 else @v153spos_52_min end
		end
	
	--us1<=l4
	select @ErrType = @ErrType + sportname + '-'+ case when b.bettype = 51 then 'Win. Aust Tote' when b.bettype = 52 then 'Place. Aust Tote' else typenamee end + ', '
	from CustOverride3rd as co with (NOLOCK) inner join
	(				select 153 as sporttype, 51 as bettype, @auto_v153spositiontaking_51 as autopositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking	where @UpdatePositiontakingv153_51 = 1
	union all		select 153 as sporttype, 52 as bettype, @auto_v153spositiontaking_52 as autopositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking	where @UpdatePositiontakingv153_51 = 1	
	) as b on co.sporttype=b.sporttype and co.bettype=b.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid

	where co.custid = @srecommend and ((b.isautopositiontaking>0 and b.autopositiontaking>co.maxpositiontaking))

	if @ErrType <>''
	BEGIN
		select @isvalid = 0, @ErrCode_cur = 2
		Select @ErrMsg_cur = 	@UserName + ': '+
			case @Language 
							when 'E' then 'Wrong position taking (min/max set by company) ('+@ErrType+').'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + ' ('+@ErrType+').'
					end
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	-- End check parameter
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--us1<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
	from CustSetting3rd as cs with (NOLOCK) inner join
		(				select 51 as bettype, 153 as sporttype, @auto_v153spositiontaking_51 as autopositiontaking	where @UpdatePositiontakingv153_51 = 1
			union all 	select 52 as bettype, 153 as sporttype, @auto_v153spositiontaking_52 as autopositiontaking	where @UpdatePositiontakingv153_51 = 1
		) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where cs.custid = @srecommend
		and 
		((cs.spositiontaking<b.autopositiontaking))
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							end	, @ErrCode_cur = 223						
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--us1>= us1_min(=s1_min)
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Min: '+ cast((b.minpositiontaking) as varchar(10)) + '<br>'
	from 
		(				select 51 as bettype, 153 as sporttype, @auto_v153spositiontaking_51 as autopositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking, @v153spos_51_min as minpositiontaking where @UpdatePositiontakingv153_51 = 1
			union all 	select 52 as bettype, 153 as sporttype, @auto_v153spositiontaking_52 as autopositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking, @v153spos_52_min as minpositiontaking where @UpdatePositiontakingv153_51 = 1
		) as b
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where b.isautopositiontaking = 1 and b.autopositiontaking < b.minpositiontaking
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong auto position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20009,@Language) + '<br>' + @ErrType
							end	, @ErrCode_cur = 300						
		Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--s1<=s4
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+
	case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
	 + '-Max: '+ cast((cs.spositiontaking) as varchar(10)) + '<br>'
	from CustSetting3rd as cs with (NOLOCK) inner join
		(				select 51 as bettype, 153 as sporttype, @v153spositiontaking_51 as positiontaking	where @UpdatePositiontakingv153_51 = 1
			union all 	select 52 as bettype, 153 as sporttype, @v153spositiontaking_52 as positiontaking	where @UpdatePositiontakingv153_51 = 1
		) as b on cs.sporttype=b.sporttype and cs.bettype=b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where cs.custid = @srecommend
		and 
		((cs.spositiontaking<b.positiontaking))
		
	if @ErrType <>''
	BEGIN
		Select @ErrMsg_cur =	@UserName + ': '+
							case @Language 
								when 'E' then 'Wrong position taking.<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
							end, @ErrCode_cur = 5
		Select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	
	--s1<=s1_max
	select @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((t.spositiontaking_max) as varchar(10)) + '<br>'			
	FROM 	
		(			
			SELECT 153 as sporttype, 51 as bettype, @v153spositiontaking_51 as spositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking, @isauto_v153smpositiontaking_51 as isauto_smpositiontaking WHERE @UpdatePositiontakingv153_51 = 1 
			UNION ALL SELECT 153 as sporttype, 52 as bettype, @v153spositiontaking_52 as spositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking, @isauto_v153smpositiontaking_52 as isauto_smpositiontaking WHERE @UpdatePositiontakingv153_51 = 1 
		)b
		INNER JOIN
		(
			SELECT 153 as sporttype, 51 as bettype, @v153spos_51_max as spositiontaking_max
			UNION ALL SELECT 153 as sporttype, 52 as bettype, @v153spos_52_max as spositiontaking_max
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype 
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
	WHERE b.spositiontaking > t.spositiontaking_max and isautopositiontaking = 0 and isauto_smpositiontaking = 0
	
	if @ErrType <>''
		BEGIN
			select @ErrCode_Cur = 11
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking .<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
	
	--s1>=s1_min
	select @ErrType = ''
	SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Min: '+ cast((t.spositiontaking_min) as varchar(10)) + '<br>'			
	FROM 	
		(			
			SELECT 153 as sporttype, 51 as bettype, @v153spositiontaking_51 as spositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking, @isauto_v153smpositiontaking_51 as isauto_smpositiontaking WHERE @UpdatePositiontakingv153_51 = 1 
			UNION ALL SELECT 153 as sporttype, 52 as bettype, @v153spositiontaking_52 as spositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking, @isauto_v153smpositiontaking_52 as isauto_smpositiontaking WHERE @UpdatePositiontakingv153_51 = 1 
		)b
		INNER JOIN
		(
			SELECT 153 as sporttype, 51 as bettype, @v153spos_51_min as spositiontaking_min
			UNION ALL SELECT 153 as sporttype, 52 as bettype, @v153spos_52_min as spositiontaking_min
		) t ON b.sporttype = t.sporttype AND b.bettype = t.bettype 
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype 
	WHERE b.spositiontaking < t.spositiontaking_min and isautopositiontaking = 0 and isauto_smpositiontaking = 0
	
	if @ErrType <>''
		BEGIN
			select @ErrCode_Cur = 12
			Select @ErrMsg_Cur = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking .<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			Select  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
			
	select 
		@v153spositiontaking_51 = case when @v153mpositiontaking_51+@v153spositiontaking_51+@v153apositiontaking_51>@v153spositiontaking_51_max then @v153spositiontaking_51_max-@v153mpositiontaking_51-@v151apositiontaking_41 else @v153spositiontaking_51 end,
		@v153spositiontaking_52 = case when @v153mpositiontaking_52+@v153spositiontaking_52+@v153apositiontaking_52>@v153spositiontaking_52_max then @v153spositiontaking_52_max-@v153mpositiontaking_52-@v151apositiontaking_42 else @v153spositiontaking_52 end

	select 
		@v153spositiontaking_51 = case when @v153spositiontaking_51<0 then 0 else @v153spositiontaking_51 end,
		@v153spositiontaking_52 = case when @v153spositiontaking_52<0 then 0 else @v153spositiontaking_52 end

END --@@UpdatePositiontakingv153	

--don't update s1 for member under master was set i3=1(normal)
EXEC dbo.Acc_CustSetting3rd_08
	@custid = @custid,	
	@roleid = 4,
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
	
	@UpdateMultiple = @UpdateMultiple,
	@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
	@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
	@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
	@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
	@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
	@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51
/*
update cs with (ROWLOCK, UPDLOCK)
set
	cs.spositiontaking = case when @UpdateMultiple = 1 
								AND (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								then cs.spositiontaking 
							else case	
									when cs.bettype = 31 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_31 
									when cs.bettype = 32 and cs.sporttype = 151 and @UpdatePositiontakingv151_31 = 1 then @v151spositiontaking_32 
									when cs.bettype = 41 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_41 
									when cs.bettype = 42 and cs.sporttype = 151 and @UpdatePositiontakingv151_41 = 1 then @v151spositiontaking_42 
									when cs.bettype = 51 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_51 
									when cs.bettype = 52 and cs.sporttype = 151 and @UpdatePositiontakingv151_51 = 1 then @v151spositiontaking_52 
									when cs.bettype = 41 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_41 
									when cs.bettype = 42 and cs.sporttype = 152 and @UpdatePositiontakingv152_41 = 1 then @v152spositiontaking_42 
									when cs.bettype = 51 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_51 
									when cs.bettype = 52 and cs.sporttype = 152 and @UpdatePositiontakingv152_51 = 1 then @v152spositiontaking_52 
									when cs.bettype = 51 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_51 
									when cs.bettype = 52 and cs.sporttype = 153 and @UpdatePositiontakingv153_51 = 1 then @v153spositiontaking_52 
								else cs.spositiontaking end
							end
from CustSetting3rd cs  inner join customer c (nolock) on cs.custid = c.custid
	inner join CustSetting3rd scs (nolock) on scs.custid = c.mrecommend and cs.sporttype = scs.sporttype and cs.bettype = scs.bettype
where cs.custid=@custid and cs.sporttype in (151,152,153) and c.roleid = 1 and scs.isautopositiontaking = 0
*/

--Update auto PT
EXEC dbo.Acc_CustSetting3rd_09
	@custid = @custid,
	@roleid = 4,
	@mode = 'horse',
	
	@auto_v151spositiontaking_31 = @auto_v151spositiontaking_31,
	@auto_v151spositiontaking_32 = @auto_v151spositiontaking_32,
	@auto_v151spositiontaking_41 = @auto_v151spositiontaking_41,
	@auto_v151spositiontaking_42 = @auto_v151spositiontaking_42,
	@auto_v151spositiontaking_51 = @auto_v151spositiontaking_51,
	@auto_v151spositiontaking_52 = @auto_v151spositiontaking_52,
	@auto_v152spositiontaking_41 = @auto_v152spositiontaking_41,
	@auto_v152spositiontaking_42 = @auto_v152spositiontaking_42,
	@auto_v152spositiontaking_51 = @auto_v152spositiontaking_51,
	@auto_v152spositiontaking_52 = @auto_v152spositiontaking_52,
	@auto_v153spositiontaking_51 = @auto_v153spositiontaking_51,
	@auto_v153spositiontaking_52 = @auto_v153spositiontaking_52,

	@isauto_v151spositiontaking_31 = @isauto_v151spositiontaking_31,
	@isauto_v151spositiontaking_32 = @isauto_v151spositiontaking_32,
	@isauto_v151spositiontaking_41 = @isauto_v151spositiontaking_41,
	@isauto_v151spositiontaking_42 = @isauto_v151spositiontaking_42,
	@isauto_v151spositiontaking_51 = @isauto_v151spositiontaking_51,
	@isauto_v151spositiontaking_52 = @isauto_v151spositiontaking_52,
	@isauto_v152spositiontaking_41 = @isauto_v152spositiontaking_41,
	@isauto_v152spositiontaking_42 = @isauto_v152spositiontaking_42,
	@isauto_v152spositiontaking_51 = @isauto_v152spositiontaking_51,
	@isauto_v152spositiontaking_52 = @isauto_v152spositiontaking_52,
	@isauto_v153spositiontaking_51 = @isauto_v153spositiontaking_51,
	@isauto_v153spositiontaking_52 = @isauto_v153spositiontaking_52,
	
	@UpdateMultiple = @UpdateMultiple,
	@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
	@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
	@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
	@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
	@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
	@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51
/*
update CustSetting3rd with (ROWLOCK, UPDLOCK) 
	set autopositiontaking = case when @UpdateMultiple = 1 
								and (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								then cs.autopositiontaking
							else b.autopositiontaking end,
		isautopositiontaking = case when @UpdateMultiple = 1 
								and (	(cs.sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (cs.sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (cs.sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								then cs.isautopositiontaking
							else b.isautopositiontaking end
from CustSetting3rd as cs inner join 
		(
						select 31 as bettype, 151 as sporttype, @auto_v151spositiontaking_31 as autopositiontaking, @isauto_v151spositiontaking_31 as isautopositiontaking where @UpdatePositiontakingv151_31 = 1
			union all 	select 32 as bettype, 151 as sporttype, @auto_v151spositiontaking_32 as autopositiontaking, @isauto_v151spositiontaking_32 as isautopositiontaking where @UpdatePositiontakingv151_31 = 1	
			union all	select 41 as bettype, 151 as sporttype, @auto_v151spositiontaking_41 as autopositiontaking, @isauto_v151spositiontaking_41 as isautopositiontaking where @UpdatePositiontakingv151_41 = 1
			union all 	select 42 as bettype, 151 as sporttype, @auto_v151spositiontaking_42 as autopositiontaking, @isauto_v151spositiontaking_42 as isautopositiontaking where @UpdatePositiontakingv151_41 = 1	
			union all	select 51 as bettype, 151 as sporttype, @auto_v151spositiontaking_51 as autopositiontaking, @isauto_v151spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv151_51 = 1
			union all 	select 52 as bettype, 151 as sporttype, @auto_v151spositiontaking_52 as autopositiontaking, @isauto_v151spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv151_51 = 1
			union all	select 41 as bettype, 152 as sporttype, @auto_v152spositiontaking_41 as autopositiontaking, @isauto_v152spositiontaking_41 as isautopositiontaking where @UpdatePositiontakingv152_41 = 1
			union all 	select 42 as bettype, 152 as sporttype, @auto_v152spositiontaking_42 as autopositiontaking, @isauto_v152spositiontaking_42 as isautopositiontaking where @UpdatePositiontakingv152_41 = 1
			union all	select 51 as bettype, 152 as sporttype, @auto_v152spositiontaking_51 as autopositiontaking, @isauto_v152spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv152_51 = 1
			union all 	select 52 as bettype, 152 as sporttype, @auto_v152spositiontaking_52 as autopositiontaking, @isauto_v152spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv152_51 = 1
			union all	select 51 as bettype, 153 as sporttype, @auto_v153spositiontaking_51 as autopositiontaking, @isauto_v153spositiontaking_51 as isautopositiontaking where @UpdatePositiontakingv153_51 = 1
			union all 	select 52 as bettype, 153 as sporttype, @auto_v153spositiontaking_52 as autopositiontaking, @isauto_v153spositiontaking_52 as isautopositiontaking where @UpdatePositiontakingv153_51 = 1
		) as b on b.bettype = cs.bettype and b.sporttype = cs.sporttype
where cs.custid = @custid

if @@Error <> 0
BEGIN
	SELECT @ErrMsg_cur =  @UserName + ': '+
	case @Language 
		when 'E' then 'Error updating auto position taking'
		ELSE [dbo].[f_Get_MsgNamebyMsgID](20010,@Language)
	end, @ErrCode_cur = 11
	SELECT  @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
	return
END
*/
--merge code sp correct pt after update pt on member into sp execrep Acc_CustSetting3rd_08/Acc_CustSetting3rd_09
/*
EXEC dbo.Acc_CustSetting3rd_00
			@custid = @custid, 
			@recommend = @recommend, 
			@mrecommend = @mrecommend, 
			@srecommend = @srecommend,
			@mode = 'horse'
*/			
--EXEC dbo.Acc_CustomerUpdMemberHR_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(5000)

Select @LogSPData = '<Acc_CustomerUpdMemberHR_SAg><info custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
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

'<s v151spt_31="'+ coalesce(cast(@v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151spt_32="'+ coalesce(cast(@v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151spt_41="'+ coalesce(cast(@v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151spt_42="'+ coalesce(cast(@v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151spt_51="'+ coalesce(cast(@v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v151spt_52="'+ coalesce(cast(@v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v152spt_41="'+ coalesce(cast(@v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v152spt_42="'+ coalesce(cast(@v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v152spt_51="'+ coalesce(cast(@v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v152spt_52="'+ coalesce(cast(@v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v153spt_51="'+ coalesce(cast(@v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v153spt_52="'+ coalesce(cast(@v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<au a_v151spt_31="'+ coalesce(cast(@auto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'a_v151spt_32="'+ coalesce(cast(@auto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'a_v151spt_41="'+ coalesce(cast(@auto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v151spt_42="'+ coalesce(cast(@auto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v151spt_51="'+ coalesce(cast(@auto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v151spt_52="'+ coalesce(cast(@auto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v152spt_41="'+ coalesce(cast(@auto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v152spt_42="'+ coalesce(cast(@auto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v152spt_51="'+ coalesce(cast(@auto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v152spt_52="'+ coalesce(cast(@auto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v153spt_51="'+ coalesce(cast(@auto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v153spt_52="'+ coalesce(cast(@auto_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<ia isa_v151spt_31="'+ coalesce(cast(@isauto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_32="'+ coalesce(cast(@isauto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_41="'+ coalesce(cast(@isauto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_42="'+ coalesce(cast(@isauto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_51="'+ coalesce(cast(@isauto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_52="'+ coalesce(cast(@isauto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_41="'+ coalesce(cast(@isauto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_42="'+ coalesce(cast(@isauto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_51="'+ coalesce(cast(@isauto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_52="'+ coalesce(cast(@isauto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_51="'+ coalesce(cast(@isauto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_52="'+ coalesce(cast(@isauto_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<isau isa_v151smpt_31="'+ coalesce(cast(@isauto_v151smpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_32="'+ coalesce(cast(@isauto_v151smpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_41="'+ coalesce(cast(@isauto_v151smpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_42="'+ coalesce(cast(@isauto_v151smpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_51="'+ coalesce(cast(@isauto_v151smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_52="'+ coalesce(cast(@isauto_v151smpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_41="'+ coalesce(cast(@isauto_v152smpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_42="'+ coalesce(cast(@isauto_v152smpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_51="'+ coalesce(cast(@isauto_v152smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_52="'+ coalesce(cast(@isauto_v152smpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v153smpt_51="'+ coalesce(cast(@isauto_v153smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v153smpt_52="'+ coalesce(cast(@isauto_v153smpositiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_SAg>'

Select @TrackingValueDB = '<Acc_CustomerUpdMemberHR_SAg><info custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
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

'<s v151spt_31="'+ coalesce(cast(@old_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151spt_32="'+ coalesce(cast(@old_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151spt_41="'+ coalesce(cast(@old_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151spt_42="'+ coalesce(cast(@old_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151spt_51="'+ coalesce(cast(@old_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v151spt_52="'+ coalesce(cast(@old_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v152spt_41="'+ coalesce(cast(@old_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v152spt_42="'+ coalesce(cast(@old_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v152spt_51="'+ coalesce(cast(@old_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v152spt_52="'+ coalesce(cast(@old_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v153spt_51="'+ coalesce(cast(@old_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v153spt_52="'+ coalesce(cast(@old_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<au a_v151spt_31="'+ coalesce(cast(@old_auto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'a_v151spt_32="'+ coalesce(cast(@old_auto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'a_v151spt_41="'+ coalesce(cast(@old_auto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v151spt_42="'+ coalesce(cast(@old_auto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v151spt_51="'+ coalesce(cast(@old_auto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v151spt_52="'+ coalesce(cast(@old_auto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v152spt_41="'+ coalesce(cast(@old_auto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'a_v152spt_42="'+ coalesce(cast(@old_auto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'a_v152spt_51="'+ coalesce(cast(@old_auto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v152spt_52="'+ coalesce(cast(@old_auto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'a_v153spt_51="'+ coalesce(cast(@old_auto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'a_v153spt_52="'+ coalesce(cast(@old_auto_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<ia isa_v151spt_31="'+ coalesce(cast(@old_isauto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_32="'+ coalesce(cast(@old_isauto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_41="'+ coalesce(cast(@old_isauto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_42="'+ coalesce(cast(@old_isauto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_51="'+ coalesce(cast(@old_isauto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v151spt_52="'+ coalesce(cast(@old_isauto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_41="'+ coalesce(cast(@old_isauto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_42="'+ coalesce(cast(@old_isauto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_51="'+ coalesce(cast(@old_isauto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v152spt_52="'+ coalesce(cast(@old_isauto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_51="'+ coalesce(cast(@old_isauto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v153spt_52="'+ coalesce(cast(@old_isauto_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

'<isau isa_v151smpt_31="'+ coalesce(cast(@isauto_v151smpositiontaking_31 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_32="'+ coalesce(cast(@isauto_v151smpositiontaking_32 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_41="'+ coalesce(cast(@isauto_v151smpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_42="'+ coalesce(cast(@isauto_v151smpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_51="'+ coalesce(cast(@isauto_v151smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v151smpt_52="'+ coalesce(cast(@isauto_v151smpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_41="'+ coalesce(cast(@isauto_v152smpositiontaking_41 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_42="'+ coalesce(cast(@isauto_v152smpositiontaking_42 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_51="'+ coalesce(cast(@isauto_v152smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v152smpt_52="'+ coalesce(cast(@isauto_v152smpositiontaking_52 as varchar(50)),space(1)) + '" ' +
'isa_v153smpt_51="'+ coalesce(cast(@isauto_v153smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
'isa_v153smpt_52="'+ coalesce(cast(@isauto_v153smpositiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_SAg>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log positiontaking
BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 406,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdMemberHR_SAg><info custid="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
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

	'<s v151spt_31="'+ coalesce(cast(@v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'v151spt_32="'+ coalesce(cast(@v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'v151spt_41="'+ coalesce(cast(@v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'v151spt_42="'+ coalesce(cast(@v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'v151spt_51="'+ coalesce(cast(@v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'v151spt_52="'+ coalesce(cast(@v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'v152spt_41="'+ coalesce(cast(@v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'v152spt_42="'+ coalesce(cast(@v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'v152spt_51="'+ coalesce(cast(@v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'v152spt_52="'+ coalesce(cast(@v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'v153spt_51="'+ coalesce(cast(@v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'v153spt_52="'+ coalesce(cast(@v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

	'<au a_v151spt_31="'+ coalesce(cast(@auto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'a_v151spt_32="'+ coalesce(cast(@auto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'a_v151spt_41="'+ coalesce(cast(@auto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'a_v151spt_42="'+ coalesce(cast(@auto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'a_v151spt_51="'+ coalesce(cast(@auto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'a_v151spt_52="'+ coalesce(cast(@auto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'a_v152spt_41="'+ coalesce(cast(@auto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'a_v152spt_42="'+ coalesce(cast(@auto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'a_v152spt_51="'+ coalesce(cast(@auto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'a_v152spt_52="'+ coalesce(cast(@auto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'a_v153spt_51="'+ coalesce(cast(@auto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'a_v153spt_52="'+ coalesce(cast(@auto_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

	'<ia isa_v151spt_31="'+ coalesce(cast(@isauto_v151spositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'isa_v151spt_32="'+ coalesce(cast(@isauto_v151spositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'isa_v151spt_41="'+ coalesce(cast(@isauto_v151spositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'isa_v151spt_42="'+ coalesce(cast(@isauto_v151spositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'isa_v151spt_51="'+ coalesce(cast(@isauto_v151spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'isa_v151spt_52="'+ coalesce(cast(@isauto_v151spositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'isa_v152spt_41="'+ coalesce(cast(@isauto_v152spositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'isa_v152spt_42="'+ coalesce(cast(@isauto_v152spositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'isa_v152spt_51="'+ coalesce(cast(@isauto_v152spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'isa_v152spt_52="'+ coalesce(cast(@isauto_v152spositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'isa_v153spt_51="'+ coalesce(cast(@isauto_v153spositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'isa_v153spt_52="'+ coalesce(cast(@isauto_v153spositiontaking_52 as varchar(50)),space(1)) + '" />' +

	'<isau isa_v151smpt_31="'+ coalesce(cast(@isauto_v151smpositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'isa_v151smpt_32="'+ coalesce(cast(@isauto_v151smpositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'isa_v151smpt_41="'+ coalesce(cast(@isauto_v151smpositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'isa_v151smpt_42="'+ coalesce(cast(@isauto_v151smpositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'isa_v151smpt_51="'+ coalesce(cast(@isauto_v151smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'isa_v151smpt_52="'+ coalesce(cast(@isauto_v151smpositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'isa_v152smpt_41="'+ coalesce(cast(@isauto_v152smpositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'isa_v152smpt_42="'+ coalesce(cast(@isauto_v152smpositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'isa_v152smpt_51="'+ coalesce(cast(@isauto_v152smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'isa_v152smpt_52="'+ coalesce(cast(@isauto_v152smpositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'isa_v153smpt_51="'+ coalesce(cast(@isauto_v153smpositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'isa_v153smpt_52="'+ coalesce(cast(@isauto_v153smpositiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_SAg>'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 406,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH		

Select @ErrCode = @ErrCode + '-107'+char(7), @ErrMsg = @ErrMsg + char(7)


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_SAg] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_SAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberHR_SAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberHR_SAg] TO [vnteam] AS [dbo]