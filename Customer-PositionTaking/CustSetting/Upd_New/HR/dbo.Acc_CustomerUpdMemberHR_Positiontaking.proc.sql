ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberHR_PositionTaking]
	@custid INT,--memberid		
	@v151apositiontaking_31 SMALLMONEY,
	@v151apositiontaking_32 SMALLMONEY,
	@v151apositiontaking_41 SMALLMONEY,
	@v151apositiontaking_42 SMALLMONEY,
	@v151apositiontaking_51 SMALLMONEY = 0,
	@v151apositiontaking_52 SMALLMONEY = 0,
	@v152apositiontaking_41 SMALLMONEY = 0,
	@v152apositiontaking_42 SMALLMONEY = 0,
	@v152apositiontaking_51 SMALLMONEY = 0,
	@v152apositiontaking_52 SMALLMONEY = 0,
	@v153apositiontaking_51 SMALLMONEY = 0,
	@v153apositiontaking_52 SMALLMONEY = 0,
	
	@UpdateMultiple BIT = 0,
	@UpdatePositiontakingv151_31 BIT = 1,
	@UpdatePositiontakingv151_41 BIT = 1,
	@UpdatePositiontakingv151_51 BIT = 1,
	@UpdatePositiontakingv152_41 BIT = 1,
	@UpdatePositiontakingv152_51 BIT = 1,
	@UpdatePositiontakingv153_51 BIT = 1,
		
	@UserID INT,	
	@IP varchar(15)='',	
	@Language VARCHAR(2)= 'E',	
	@SubAccID INT = 0, --Sub-AccountID	
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20090518@Phuc
Task : Update HR's Member Position Taking
DB: DBTXN/bodb02
Original:

Revisions:
	- 20090630@Phuc: auto master PT on member level.
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100112@Kiwi: Amend to write log in xml format.
	- 20101019@Henry: Record execution time
	- 20110111@Lukas: Add setting
						+ AU Horse racing
						+ UK, AU Greyhound racing
						+ AU Harness racing
	- 20110331@Lukas: include sport name to error messages
	- 20110518@Johnson: write log for old setting
	- 20111017@TOM: Apply Multiple Edit Racing PT.
	- 20111114@TOM: Add parameter input @UpdatePositiontakingv151_31 => _51
								@UpdatePositiontakingv152_41 => _51
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: write log on DBTXN if DBLOG failure
	- 20130606@Johnson: Check a1 in valid range
	- 20131107@Johnson: Apply execrep when update pt on member
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sports, bettype by link database)
	- 20131113@Johnson: Use execrept Acc_CustSetting3rd_00 to correct after update pt on member 
	- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON
----- David @ 09 JUN 2015 -------------------
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
----- /David @ 09 JUN 2015 -------------------

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

DECLARE 	
	@Recommend INT,	
	@MRecommend INT,
	@SRecommend INT,
	@UserName nvarchar(20),
	@ErrAcc varchar(4000), @ErrType varchar(4000),
	--m1
	@v151mpositiontaking_31 SMALLMONEY,
	@v151mpositiontaking_32 SMALLMONEY,
	@v151mpositiontaking_41 SMALLMONEY,
	@v151mpositiontaking_42 SMALLMONEY,
	@v151mpositiontaking_51 SMALLMONEY,
	@v151mpositiontaking_52 SMALLMONEY,
	@v152mpositiontaking_41 SMALLMONEY,
	@v152mpositiontaking_42 SMALLMONEY,
	@v152mpositiontaking_51 SMALLMONEY,
	@v152mpositiontaking_52 SMALLMONEY,
	@v153mpositiontaking_51 SMALLMONEY,
	@v153mpositiontaking_52 SMALLMONEY,
	--m3
	@v151mapositiontaking_31_max SMALLMONEY,
	@v151mapositiontaking_32_max SMALLMONEY,
	@v151mapositiontaking_41_max SMALLMONEY,
	@v151mapositiontaking_42_max SMALLMONEY,
	@v151mapositiontaking_51_max SMALLMONEY,
	@v151mapositiontaking_52_max SMALLMONEY,
	@v152mapositiontaking_41_max SMALLMONEY,
	@v152mapositiontaking_42_max SMALLMONEY,
	@v152mapositiontaking_51_max SMALLMONEY,
	@v152mapositiontaking_52_max SMALLMONEY,
	@v153mapositiontaking_51_max SMALLMONEY,
	@v153mapositiontaking_52_max SMALLMONEY,
	--old_a1
	@old_v151apositiontaking_31 SMALLMONEY,
	@old_v151apositiontaking_32 SMALLMONEY,
	@old_v151apositiontaking_41 SMALLMONEY,
	@old_v151apositiontaking_42 SMALLMONEY,
	@old_v151apositiontaking_51 SMALLMONEY,
	@old_v151apositiontaking_52 SMALLMONEY,
	@old_v152apositiontaking_41 SMALLMONEY,
	@old_v152apositiontaking_42 SMALLMONEY,
	@old_v152apositiontaking_51 SMALLMONEY,
	@old_v152apositiontaking_52 SMALLMONEY,
	@old_v153apositiontaking_51 SMALLMONEY,
	@old_v153apositiontaking_52 SMALLMONEY,
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
	--im2
	@isauto_v151mpositiontaking_31 BIT,
	@isauto_v151mpositiontaking_32 BIT,
	@isauto_v151mpositiontaking_41 BIT,
	@isauto_v151mpositiontaking_42 BIT,
	@isauto_v151mpositiontaking_51 BIT,
	@isauto_v151mpositiontaking_52 BIT,
	@isauto_v152mpositiontaking_41 BIT,
	@isauto_v152mpositiontaking_42 BIT,
	@isauto_v152mpositiontaking_51 BIT,
	@isauto_v152mpositiontaking_52 BIT,
	@isauto_v153mpositiontaking_51 BIT,
	@isauto_v153mpositiontaking_52 BIT,
	--um1
	@auto_v151mpositiontaking_mem_31 SMALLMONEY,
	@auto_v151mpositiontaking_mem_32 SMALLMONEY,
	@auto_v151mpositiontaking_mem_41 SMALLMONEY,
	@auto_v151mpositiontaking_mem_42 SMALLMONEY,
	@auto_v151mpositiontaking_mem_51 SMALLMONEY,
	@auto_v151mpositiontaking_mem_52 SMALLMONEY,
	@auto_v152mpositiontaking_mem_41 SMALLMONEY,
	@auto_v152mpositiontaking_mem_42 SMALLMONEY,
	@auto_v152mpositiontaking_mem_51 SMALLMONEY,
	@auto_v152mpositiontaking_mem_52 SMALLMONEY,
	@auto_v153mpositiontaking_mem_51 SMALLMONEY,
	@auto_v153mpositiontaking_mem_52 SMALLMONEY,
	--im1
	@isauto_v151mpositiontaking_mem_31 BIT,
	@isauto_v151mpositiontaking_mem_32 BIT,
	@isauto_v151mpositiontaking_mem_41 BIT,
	@isauto_v151mpositiontaking_mem_42 BIT,
	@isauto_v151mpositiontaking_mem_51 BIT,
	@isauto_v151mpositiontaking_mem_52 BIT,
	@isauto_v152mpositiontaking_mem_41 BIT,
	@isauto_v152mpositiontaking_mem_42 BIT,
	@isauto_v152mpositiontaking_mem_51 BIT,
	@isauto_v152mpositiontaking_mem_52 BIT,
	@isauto_v153mpositiontaking_mem_51 BIT,
	@isauto_v153mpositiontaking_mem_52 BIT,
	
	--a1_max
	@v151apositiontaking_31_max smallmoney,
	@v151apositiontaking_32_max smallmoney,
	@v151apositiontaking_41_max smallmoney,
	@v151apositiontaking_42_max smallmoney,
	@v151apositiontaking_51_max smallmoney,
	@v151apositiontaking_52_max smallmoney,
	
	@v152apositiontaking_41_max smallmoney,
	@v152apositiontaking_42_max smallmoney,
	@v152apositiontaking_51_max smallmoney,
	@v152apositiontaking_52_max smallmoney,
	
	@v153apositiontaking_51_max smallmoney,
	@v153apositiontaking_52_max smallmoney,
	
	@cs_v151ap_31 smallmoney,
	@cs_v151ap_32 smallmoney,
	@cs_v151ap_41 smallmoney,
	@cs_v151ap_42 smallmoney,
	@cs_v151ap_51 smallmoney,
	@cs_v151ap_52 smallmoney,
	@cs_v152ap_41 smallmoney,
	@cs_v152ap_42 smallmoney,
	@cs_v152ap_51 smallmoney,
	@cs_v152ap_52 smallmoney,
	@cs_v153ap_51 smallmoney,
	@cs_v153ap_52 smallmoney


SELECT 	
	@Recommend = recommend,
	@MRecommend = mrecommend,
	@SRecommend = srecommend,	
	@UserName = username
FROM 
	custinfo WITH (NOLOCK)
WHERE CustID = @CustID

--get max_a1
--@apos_max = min(a2,l2)
Select 	
	@v151apositiontaking_31_max = max(case when cs.bettype = 31 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_32_max = max(case when cs.bettype = 32 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	@v152apositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v152apositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v152apositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v152apositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	@v153apositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=153 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v153apositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=153 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end)
From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @recommend and cs.sporttype between 151 and 153
	
--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
Select 
	@cs_v151ap_31 = max(case when cs.bettype = 31 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_32 = max(case when cs.bettype = 32 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_41 = max(case when cs.bettype = 41 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_42 = max(case when cs.bettype = 42 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_51 = max(case when cs.bettype = 51 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_52 = max(case when cs.bettype = 52 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_v152ap_41 = max(case when cs.bettype = 41 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v152ap_42 = max(case when cs.bettype = 42 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v152ap_51 = max(case when cs.bettype = 51 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v152ap_52 = max(case when cs.bettype = 52 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_v153ap_51 = max(case when cs.bettype = 51 and cs.sporttype=153 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v153ap_52 = max(case when cs.bettype = 52 and cs.sporttype=153 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking-cs.spositiontaking-cs.mpositiontaking end end end else 0 end)			
From CustSetting3rd as cs with (NOLOCK) 
	inner join customer as c with (nolock) on cs.custid = c.custid
	inner join CustSetting3rd as scs with (nolock) on scs.custid = c.srecommend and scs.bettype = cs.bettype and scs.sporttype = cs.sporttype
	inner join CustSetting3rd as mcs with (nolock) on mcs.custid = c.mrecommend and mcs.bettype = cs.bettype and mcs.sporttype = cs.sporttype
	inner join CustSetting3rd as acs with (nolock) on acs.custid = c.recommend and acs.bettype = cs.bettype and acs.sporttype = cs.sporttype
where cs.custid = @custid and cs.sporttype between 151 and 153

--max_a1 = min(min(a2,l2),max_a1)
select 
	@v151apositiontaking_31_max = case when @v151apositiontaking_31_max <= @cs_v151ap_31 then @v151apositiontaking_31_max else @cs_v151ap_31 end,
	@v151apositiontaking_32_max = case when @v151apositiontaking_32_max <= @cs_v151ap_32 then @v151apositiontaking_32_max else @cs_v151ap_32 end,
	@v151apositiontaking_41_max = case when @v151apositiontaking_41_max <= @cs_v151ap_41 then @v151apositiontaking_41_max else @cs_v151ap_41 end,
	@v151apositiontaking_42_max = case when @v151apositiontaking_42_max <= @cs_v151ap_42 then @v151apositiontaking_42_max else @cs_v151ap_42 end,
	@v151apositiontaking_51_max = case when @v151apositiontaking_51_max <= @cs_v151ap_51 then @v151apositiontaking_51_max else @cs_v151ap_51 end,
	@v151apositiontaking_52_max = case when @v151apositiontaking_52_max <= @cs_v151ap_52 then @v151apositiontaking_52_max else @cs_v151ap_52 end,
	
	@v152apositiontaking_41_max = case when @v152apositiontaking_41_max <= @cs_v152ap_41 then @v152apositiontaking_41_max else @cs_v152ap_41 end,
	@v152apositiontaking_42_max = case when @v152apositiontaking_42_max <= @cs_v152ap_42 then @v152apositiontaking_42_max else @cs_v152ap_42 end,
	@v152apositiontaking_51_max = case when @v152apositiontaking_51_max <= @cs_v152ap_51 then @v152apositiontaking_51_max else @cs_v152ap_51 end,
	@v152apositiontaking_52_max = case when @v152apositiontaking_52_max <= @cs_v152ap_52 then @v152apositiontaking_52_max else @cs_v152ap_52 end,
	
	@v153apositiontaking_51_max = case when @v153apositiontaking_51_max <= @cs_v153ap_51 then @v153apositiontaking_51_max else @cs_v153ap_51 end,
	@v153apositiontaking_52_max = case when @v153apositiontaking_52_max <= @cs_v153ap_52 then @v153apositiontaking_52_max else @cs_v153ap_52 end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
	BEGIN --@UpdatePositiontakingv151
		IF ((@v151apositiontaking_31 < 0
			or @v151apositiontaking_31 > 0.5
			or	@v151apositiontaking_32 < 0
			or @v151apositiontaking_32 > 0.5		)
			and @UpdatePositiontakingv151_31 = 1	)
			
			or	((@v151apositiontaking_41 < 0
			or @v151apositiontaking_41 > 0.5			
			or	@v151apositiontaking_42 < 0
			or @v151apositiontaking_42 > 0.5		)
			and @UpdatePositiontakingv151_41 = 1	)
			
			or	((@v151apositiontaking_51 < 0
			or @v151apositiontaking_51 > 0.5
			or	@v151apositiontaking_52 < 0
			or @v151apositiontaking_52 > 0.5		)
			and @UpdatePositiontakingv151_51 = 1	)
			
		BEGIN
			select @ErrCode = 8
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						end
			return
		END			

		--check n2<=a1<=l2 - Vinh
		select @ErrType = ''
		select @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
		from CustOverride3rd as co with (NOLOCK) inner join
			(
							select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking WHERE @UpdatePositiontakingv151_31 = 1
				union all	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking WHERE @UpdatePositiontakingv151_31 = 1
				union all	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking WHERE @UpdatePositiontakingv151_41 = 1
				union all	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking WHERE @UpdatePositiontakingv151_41 = 1
				union all	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv151_51 = 1
				union all	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
		)
		if @ErrType <>''
		BEGIN
			select @ErrCode = 9
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
						end
			return
		END

		--check a1<=a4 - Vinh
		select @ErrType = ''
		select @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
		from custinfo as c with (NOLOCK) inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
			(
				 			select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking WHERE @UpdatePositiontakingv151_31 = 1
				union all 	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking WHERE @UpdatePositiontakingv151_31 = 1
				union all 	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking WHERE @UpdatePositiontakingv151_41 = 1
				union all 	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking WHERE @UpdatePositiontakingv151_41 = 1
				union all 	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv151_51 = 1
				union all 	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv151_51 = 1
			) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking )
		if @ErrType <>''
		BEGIN
			select @ErrCode = 10
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
						end
			return
		END
		
		--check a1 <= max_a1
		select @ErrType = ''
		SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
		FROM (
				select 31 as bettype, 151 as sporttype, @v151apositiontaking_31 as apositiontaking WHERE @UpdatePositiontakingv151_31 = 1
				union all 	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32 as apositiontaking WHERE @UpdatePositiontakingv151_31 = 1
				union all 	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41 as apositiontaking WHERE @UpdatePositiontakingv151_41 = 1
				union all 	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42 as apositiontaking WHERE @UpdatePositiontakingv151_41 = 1
				union all 	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv151_51 = 1
				union all 	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv151_51 = 1			
			) b
			INNER JOIN 
			 (
				select 31 as bettype, 151 as sporttype, @v151apositiontaking_31_max as apositiontaking_max
				union all 	select 32 as bettype, 151 as sporttype, @v151apositiontaking_32_max as apositiontaking_max
				union all 	select 41 as bettype, 151 as sporttype, @v151apositiontaking_41_max as apositiontaking_max
				union all 	select 42 as bettype, 151 as sporttype, @v151apositiontaking_42_max as apositiontaking_max
				union all 	select 51 as bettype, 151 as sporttype, @v151apositiontaking_51_max as apositiontaking_max
				union all 	select 52 as bettype, 151 as sporttype, @v151apositiontaking_52_max as apositiontaking_max
			) t on b.sporttype = t.sporttype and b.bettype = t.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		WHERE b.apositiontaking > t.apositiontaking_max	
		
		if @ErrType <>''
		BEGIN
			select @ErrCode = 11
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking .<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			return
		END
	END --@UpdatePositiontakingv151

if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
	BEGIN --@UpdatePositiontakingv152
		IF ((@v152apositiontaking_41 < 0
			or @v152apositiontaking_41 > 0.5
			or @v152apositiontaking_42 < 0
			or @v152apositiontaking_42 > 0.5		)
			and @UpdatePositiontakingv152_41 = 1	)

			or	((@v152apositiontaking_51 < 0
			or @v152apositiontaking_51 > 0.5
			or @v152apositiontaking_52 < 0
			or @v152apositiontaking_52 > 0.5		)
			and @UpdatePositiontakingv152_51 = 1	)
		BEGIN
			select @ErrCode = 8
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						end
			return
		END	
		--check n2<=a1<=l2 - Vinh
		select @ErrType = ''
		select @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
		from CustOverride3rd as co with (NOLOCK) inner join
			(
							select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				union all	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				union all	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				union all	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
		)
		if @ErrType <>''
		BEGIN
			select @ErrCode = 9
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
						end
			return
		END		
				
		--check a1<=a4 - Vinh
		select @ErrType = ''
		select @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
		from custinfo as c with (NOLOCK) inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
			(
							select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				union all 	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				union all 	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				union all 	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv152_51 = 1
			) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking )
		if @ErrType <>''
		BEGIN
			select @ErrCode = 10
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
						end
			return
		END		
		
			--check a1 <= max_a1
		select @ErrType = ''
		SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
		FROM (
				select 41 as bettype, 152 as sporttype, @v152apositiontaking_41 as apositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				union all 	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42 as apositiontaking WHERE @UpdatePositiontakingv152_41 = 1
				union all 	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv152_51 = 1
				union all 	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv152_51 = 1			
			) b
			INNER JOIN 
			 (
				select 41 as bettype, 152 as sporttype, @v152apositiontaking_41_max as apositiontaking_max
				union all 	select 42 as bettype, 152 as sporttype, @v152apositiontaking_42_max as apositiontaking_max
				union all 	select 51 as bettype, 152 as sporttype, @v152apositiontaking_51_max as apositiontaking_max
				union all 	select 52 as bettype, 152 as sporttype, @v152apositiontaking_52_max as apositiontaking_max
			) t on b.sporttype = t.sporttype and b.bettype = t.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		WHERE b.apositiontaking > t.apositiontaking_max	
		
		if @ErrType <>''
		BEGIN
			select @ErrCode = 11
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking .<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			return
		END
	END --@UpdatePositiontakingv152
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
	BEGIN --@UpdatePositiontakingv153
		IF @v153apositiontaking_51 < 0
			or @v153apositiontaking_51 > 0.5

			or	@v153apositiontaking_52 < 0
			or @v153apositiontaking_52 > 0.5
		BEGIN
			select @ErrCode = 8
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language)
						end
			return
		END

		--check n2<=a1<=l2 - Vinh
		select @ErrType = ''
		select @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10)) + '<br>'
		from CustOverride3rd as co with (NOLOCK) inner join
			(
							select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking
				union all	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking
			) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		where co.custid = @recommend and (( (b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking))
		)
		if @ErrType <>''
		BEGIN
			select @ErrCode = 9
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
						end
			return
		END
		
		--check a1<=a4 - Vinh
		select @ErrType = ''
		select @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
		from custinfo as c with (NOLOCK) inner join CustSetting3rd as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
			(
							select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking
				union all 	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking
			) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		where c.custid = @recommend and (b.apositiontaking>scs.apositiontaking )
		if @ErrType <>''
		BEGIN
			select @ErrCode = 10
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
						end
			return
		END		
		
			--check a1 <= max_a1
		select @ErrType = ''
		SELECT @ErrType = @ErrType + s.SportName + ' - ' +
		case when b.bettype = 51 then 'Win.Aust Tote' when b.bettype = 52 then 'Place.Aust Tote' else typenamee end
		 + '-Max: '+ cast((t.apositiontaking_max) as varchar(10)) + '<br>'
		FROM (
				select 51 as bettype, 153 as sporttype, @v153apositiontaking_51 as apositiontaking WHERE @UpdatePositiontakingv153_51 = 1
				union all 	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52 as apositiontaking WHERE @UpdatePositiontakingv153_51 = 1			
			) b
			INNER JOIN 
			 (
				select 51 as bettype, 153 as sporttype, @v153apositiontaking_51_max as apositiontaking_max
				union all 	select 52 as bettype, 153 as sporttype, @v153apositiontaking_52_max as apositiontaking_max
			) t on b.sporttype = t.sporttype and b.bettype = t.bettype
			INNER JOIN @tmp_Bettype bettype on b.bettype = bettype.typeid
			INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		WHERE b.apositiontaking > t.apositiontaking_max	
		
		if @ErrType <>''
		BEGIN
			select @ErrCode = 11
			Select @ErrMsg = 	@UserName + ': '+
				case @Language 
								when 'E' then 'Wrong position taking .<br>'+@ErrType
								ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
						end
			return
		END
	END --@UpdatePositiontakingv153
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--s1,u1,i1,m1,old_a1
if (@UpdateMultiple = 0 or @UpdatePositiontakingv151_31 = 1 or @UpdatePositiontakingv151_41 = 1 or @UpdatePositiontakingv151_51 = 1)
	BEGIN --@UpdatePositiontakingv151 
		if (@UpdatePositiontakingv151_31 = 1)
			begin
				SELECT @v151spositiontaking_31 = spositiontaking, @v151mpositiontaking_31 = mpositiontaking, @auto_v151spositiontaking_mem_31 = autopositiontaking, @isauto_v151spositiontaking_mem_31 = isautopositiontaking, @old_v151apositiontaking_31 = apositiontaking, @auto_v151mpositiontaking_mem_31 = autompositiontaking, @isauto_v151mpositiontaking_mem_31 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=31 AND sporttype=151 
				SELECT @v151spositiontaking_32 = spositiontaking, @v151mpositiontaking_32 = mpositiontaking, @auto_v151spositiontaking_mem_32 = autopositiontaking, @isauto_v151spositiontaking_mem_32 = isautopositiontaking, @old_v151apositiontaking_32 = apositiontaking, @auto_v151mpositiontaking_mem_32 = autompositiontaking, @isauto_v151mpositiontaking_mem_32 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=32 AND sporttype=151
				------------------------------------------------------------------------------------------------------------------------------
				--Auto Master PT
				------------------------------------------------------------------------------------------------------------------------------
				--u2,i2				
				select @auto_v151mpositiontaking_31 = autompositiontaking, @isauto_v151mpositiontaking_31 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=31 and sporttype=151
				select @auto_v151mpositiontaking_32 = autompositiontaking, @isauto_v151mpositiontaking_32 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=32 and sporttype=151
				--m3,u3,i3
				SELECT @v151mapositiontaking_31_max = mpositiontaking, @auto_v151spositiontaking_31 = autopositiontaking, @isauto_v151spositiontaking_31 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 31 AND sporttype = 151
				SELECT @v151mapositiontaking_32_max = mpositiontaking, @auto_v151spositiontaking_32 = autopositiontaking, @isauto_v151spositiontaking_32 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 32 AND sporttype = 151
				--s4
				SELECT @max_v151spositiontaking_31 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 31 AND sporttype = 151
				SELECT @max_v151spositiontaking_32 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 32 AND sporttype = 151
			end
		if (@UpdatePositiontakingv151_41 = 1)
			begin			
				SELECT @v151spositiontaking_41 = spositiontaking, @v151mpositiontaking_41 = mpositiontaking, @auto_v151spositiontaking_mem_41 = autopositiontaking, @isauto_v151spositiontaking_mem_41 = isautopositiontaking, @old_v151apositiontaking_41 = apositiontaking, @auto_v151mpositiontaking_mem_41 = autompositiontaking, @isauto_v151mpositiontaking_mem_41 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=41 AND sporttype=151 
				SELECT @v151spositiontaking_42 = spositiontaking, @v151mpositiontaking_42 = mpositiontaking, @auto_v151spositiontaking_mem_42 = autopositiontaking, @isauto_v151spositiontaking_mem_42 = isautopositiontaking, @old_v151apositiontaking_42 = apositiontaking, @auto_v151mpositiontaking_mem_42 = autompositiontaking, @isauto_v151mpositiontaking_mem_42 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=42 AND sporttype=151
				select @auto_v151mpositiontaking_41 = autompositiontaking, @isauto_v151mpositiontaking_41 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=41 and sporttype=151
				select @auto_v151mpositiontaking_42 = autompositiontaking, @isauto_v151mpositiontaking_42 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=42 and sporttype=151
				SELECT @v151mapositiontaking_41_max = mpositiontaking, @auto_v151spositiontaking_41 = autopositiontaking, @isauto_v151spositiontaking_41 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 41 AND sporttype = 151
				SELECT @v151mapositiontaking_42_max = mpositiontaking, @auto_v151spositiontaking_42 = autopositiontaking, @isauto_v151spositiontaking_42 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 42 AND sporttype = 151
				SELECT @max_v151spositiontaking_41 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 41 AND sporttype = 151
				SELECT @max_v151spositiontaking_42 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 42 AND sporttype = 151
			end
			
		if (@UpdatePositiontakingv151_51 = 1)
			begin			
				SELECT @v151spositiontaking_51 = spositiontaking, @v151mpositiontaking_51 = mpositiontaking, @auto_v151spositiontaking_mem_51 = autopositiontaking, @isauto_v151spositiontaking_mem_51 = isautopositiontaking, @old_v151apositiontaking_51 = apositiontaking, @auto_v151mpositiontaking_mem_51 = autompositiontaking, @isauto_v151mpositiontaking_mem_51 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=51 AND sporttype=151 
				SELECT @v151spositiontaking_52 = spositiontaking, @v151mpositiontaking_52 = mpositiontaking, @auto_v151spositiontaking_mem_52 = autopositiontaking, @isauto_v151spositiontaking_mem_52 = isautopositiontaking, @old_v151apositiontaking_52 = apositiontaking, @auto_v151mpositiontaking_mem_52 = autompositiontaking, @isauto_v151mpositiontaking_mem_52 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=52 AND sporttype=151
				select @auto_v151mpositiontaking_51 = autompositiontaking, @isauto_v151mpositiontaking_51 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=51 and sporttype=151
				select @auto_v151mpositiontaking_52 = autompositiontaking, @isauto_v151mpositiontaking_52 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=52 and sporttype=151
				SELECT @v151mapositiontaking_51_max = mpositiontaking, @auto_v151spositiontaking_51 = autopositiontaking, @isauto_v151spositiontaking_51 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 51 AND sporttype = 151
				SELECT @v151mapositiontaking_52_max = mpositiontaking, @auto_v151spositiontaking_52 = autopositiontaking, @isauto_v151spositiontaking_52 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 52 AND sporttype = 151		
				SELECT @max_v151spositiontaking_51 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 51 AND sporttype = 151
				SELECT @max_v151spositiontaking_52 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 52 AND sporttype = 151		
			end
	END --@UpdatePositiontakingv151
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv152_41 = 1 or @UpdatePositiontakingv152_51 = 1)
	BEGIN --@UpdatePositiontakingv152
		if (@UpdatePositiontakingv152_41 = 1)
			begin	
				SELECT @v152spositiontaking_41 = spositiontaking, @v152mpositiontaking_41 = mpositiontaking, @auto_v152spositiontaking_mem_41 = autopositiontaking, @isauto_v152spositiontaking_mem_41 = isautopositiontaking, @old_v152apositiontaking_41 = apositiontaking, @auto_v152mpositiontaking_mem_41 = autompositiontaking, @isauto_v152mpositiontaking_mem_41 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=41 AND sporttype=152 
				SELECT @v152spositiontaking_42 = spositiontaking, @v152mpositiontaking_42 = mpositiontaking, @auto_v152spositiontaking_mem_42 = autopositiontaking, @isauto_v152spositiontaking_mem_42 = isautopositiontaking, @old_v152apositiontaking_42 = apositiontaking, @auto_v152mpositiontaking_mem_42 = autompositiontaking, @isauto_v152mpositiontaking_mem_42 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=42 AND sporttype=152
				--u2,i2
				select @auto_v152mpositiontaking_41 = autompositiontaking, @isauto_v152mpositiontaking_41 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=41 and sporttype=152
				select @auto_v152mpositiontaking_42 = autompositiontaking, @isauto_v152mpositiontaking_42 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=42 and sporttype=152
				--m3,u3,i3
				SELECT @v152mapositiontaking_41_max = mpositiontaking, @auto_v152spositiontaking_41 = autopositiontaking, @isauto_v152spositiontaking_41 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 41 AND sporttype = 152
				SELECT @v152mapositiontaking_42_max = mpositiontaking, @auto_v152spositiontaking_42 = autopositiontaking, @isauto_v152spositiontaking_42 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 42 AND sporttype = 152
				--s4
				SELECT @max_v152spositiontaking_41 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 41 AND sporttype = 152
				SELECT @max_v152spositiontaking_42 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 42 AND sporttype = 152
			end
		if (@UpdatePositiontakingv152_51 = 1)
			begin
				SELECT @v152spositiontaking_51 = spositiontaking, @v152mpositiontaking_51 = mpositiontaking, @auto_v152spositiontaking_mem_51 = autopositiontaking, @isauto_v152spositiontaking_mem_51 = isautopositiontaking, @old_v152apositiontaking_51 = apositiontaking, @auto_v152mpositiontaking_mem_51 = autompositiontaking, @isauto_v152mpositiontaking_mem_51 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=51 AND sporttype=152 
				SELECT @v152spositiontaking_52 = spositiontaking, @v152mpositiontaking_52 = mpositiontaking, @auto_v152spositiontaking_mem_52 = autopositiontaking, @isauto_v152spositiontaking_mem_52 = isautopositiontaking, @old_v152apositiontaking_52 = apositiontaking, @auto_v152mpositiontaking_mem_52 = autompositiontaking, @isauto_v152mpositiontaking_mem_52 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=52 AND sporttype=152
				select @auto_v152mpositiontaking_51 = autompositiontaking, @isauto_v152mpositiontaking_51 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=51 and sporttype=152
				select @auto_v152mpositiontaking_52 = autompositiontaking, @isauto_v152mpositiontaking_52 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=52 and sporttype=152
				SELECT @v152mapositiontaking_51_max = mpositiontaking, @auto_v152spositiontaking_51 = autopositiontaking, @isauto_v152spositiontaking_51 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 51 AND sporttype = 152
				SELECT @v152mapositiontaking_52_max = mpositiontaking, @auto_v152spositiontaking_52 = autopositiontaking, @isauto_v152spositiontaking_52 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 52 AND sporttype = 152
				SELECT @max_v152spositiontaking_51 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 51 AND sporttype = 152
				SELECT @max_v152spositiontaking_52 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 52 AND sporttype = 152		
			end
	END --@UpdatePositiontakingv152
	
if (@UpdateMultiple = 0 or @UpdatePositiontakingv153_51 = 1)
	BEGIN --@UpdatePositiontakingv153
		SELECT @v153spositiontaking_51 = spositiontaking, @v153mpositiontaking_51 = mpositiontaking, @auto_v153spositiontaking_mem_51 = autopositiontaking, @isauto_v153spositiontaking_mem_51 = isautopositiontaking, @old_v153apositiontaking_51 = apositiontaking, @auto_v153mpositiontaking_mem_51 = autompositiontaking, @isauto_v153mpositiontaking_mem_51 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=51 AND sporttype=153 
		SELECT @v153spositiontaking_52 = spositiontaking, @v153mpositiontaking_52 = mpositiontaking, @auto_v153spositiontaking_mem_52 = autopositiontaking, @isauto_v153spositiontaking_mem_52 = isautopositiontaking, @old_v153apositiontaking_52 = apositiontaking, @auto_v153mpositiontaking_mem_52 = autompositiontaking, @isauto_v153mpositiontaking_mem_52 = isautompositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype=52 AND sporttype=153
		
		--u2,i2
		select @auto_v153mpositiontaking_51 = autompositiontaking, @isauto_v153mpositiontaking_51 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=51 and sporttype=153
		select @auto_v153mpositiontaking_52 = autompositiontaking, @isauto_v153mpositiontaking_52 = isautompositiontaking from CustSetting3rd with (NOLOCK) where custid = @recommend and bettype=52 and sporttype=153
		
		--m3,u3,i3
		SELECT @v153mapositiontaking_51_max = mpositiontaking, @auto_v153spositiontaking_51 = autopositiontaking, @isauto_v153spositiontaking_51 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 51 AND sporttype = 153
		SELECT @v153mapositiontaking_52_max = mpositiontaking, @auto_v153spositiontaking_52 = autopositiontaking, @isauto_v153spositiontaking_52 = isautopositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @mrecommend AND bettype = 52 AND sporttype = 153
		
		--s4
		SELECT @max_v153spositiontaking_51 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 51 AND sporttype = 153
		SELECT @max_v153spositiontaking_52 = spositiontaking FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @srecommend AND bettype = 52 AND sporttype = 153
	END --@UpdatePositiontakingv153


---------------------------------------------------------------------------------------------------------------------------------------------
--CHOOSE MEMBER AUTOPOSITIONTAKING IF MEMBER IS SET AUTO (regardless of the setting in master account)
SELECT 
	@auto_v151spositiontaking_31 = CASE WHEN @isauto_v151spositiontaking_mem_31 > 0 THEN @auto_v151spositiontaking_mem_31 ELSE @auto_v151spositiontaking_31 END,
	@auto_v151spositiontaking_32 = CASE WHEN @isauto_v151spositiontaking_mem_32 > 0 THEN @auto_v151spositiontaking_mem_32 ELSE @auto_v151spositiontaking_32 END,
	@auto_v151spositiontaking_41 = CASE WHEN @isauto_v151spositiontaking_mem_41 > 0 THEN @auto_v151spositiontaking_mem_41 ELSE @auto_v151spositiontaking_41 END,
	@auto_v151spositiontaking_42 = CASE WHEN @isauto_v151spositiontaking_mem_42 > 0 THEN @auto_v151spositiontaking_mem_42 ELSE @auto_v151spositiontaking_42 END,
	@auto_v151spositiontaking_51 = CASE WHEN @isauto_v151spositiontaking_mem_51 > 0 THEN @auto_v151spositiontaking_mem_51 ELSE @auto_v151spositiontaking_51 END,
	@auto_v151spositiontaking_52 = CASE WHEN @isauto_v151spositiontaking_mem_52 > 0 THEN @auto_v151spositiontaking_mem_52 ELSE @auto_v151spositiontaking_52 END,
	@auto_v152spositiontaking_41 = CASE WHEN @isauto_v152spositiontaking_mem_41 > 0 THEN @auto_v152spositiontaking_mem_41 ELSE @auto_v152spositiontaking_41 END,
	@auto_v152spositiontaking_42 = CASE WHEN @isauto_v152spositiontaking_mem_42 > 0 THEN @auto_v152spositiontaking_mem_42 ELSE @auto_v152spositiontaking_42 END,
	@auto_v152spositiontaking_51 = CASE WHEN @isauto_v152spositiontaking_mem_51 > 0 THEN @auto_v152spositiontaking_mem_51 ELSE @auto_v152spositiontaking_51 END,
	@auto_v152spositiontaking_52 = CASE WHEN @isauto_v152spositiontaking_mem_52 > 0 THEN @auto_v152spositiontaking_mem_52 ELSE @auto_v152spositiontaking_52 END,
	@auto_v153spositiontaking_51 = CASE WHEN @isauto_v153spositiontaking_mem_51 > 0 THEN @auto_v153spositiontaking_mem_51 ELSE @auto_v153spositiontaking_51 END,
	@auto_v153spositiontaking_52 = CASE WHEN @isauto_v153spositiontaking_mem_52 > 0 THEN @auto_v153spositiontaking_mem_52 ELSE @auto_v153spositiontaking_52 END,

	@isauto_v151spositiontaking_31 = CASE WHEN @isauto_v151spositiontaking_mem_31 > 0 THEN @isauto_v151spositiontaking_mem_31 ELSE @isauto_v151spositiontaking_31 END,
	@isauto_v151spositiontaking_32 = CASE WHEN @isauto_v151spositiontaking_mem_32 > 0 THEN @isauto_v151spositiontaking_mem_32 ELSE @isauto_v151spositiontaking_32 END,
	@isauto_v151spositiontaking_41 = CASE WHEN @isauto_v151spositiontaking_mem_41 > 0 THEN @isauto_v151spositiontaking_mem_41 ELSE @isauto_v151spositiontaking_41 END,
	@isauto_v151spositiontaking_42 = CASE WHEN @isauto_v151spositiontaking_mem_42 > 0 THEN @isauto_v151spositiontaking_mem_42 ELSE @isauto_v151spositiontaking_42 END,
	@isauto_v151spositiontaking_51 = CASE WHEN @isauto_v151spositiontaking_mem_51 > 0 THEN @isauto_v151spositiontaking_mem_51 ELSE @isauto_v151spositiontaking_41 END,
	@isauto_v151spositiontaking_52 = CASE WHEN @isauto_v151spositiontaking_mem_52 > 0 THEN @isauto_v151spositiontaking_mem_52 ELSE @isauto_v151spositiontaking_42 END,
	@isauto_v152spositiontaking_41 = CASE WHEN @isauto_v152spositiontaking_mem_41 > 0 THEN @isauto_v152spositiontaking_mem_41 ELSE @isauto_v151spositiontaking_41 END,
	@isauto_v152spositiontaking_42 = CASE WHEN @isauto_v152spositiontaking_mem_42 > 0 THEN @isauto_v152spositiontaking_mem_42 ELSE @isauto_v151spositiontaking_42 END,
	@isauto_v152spositiontaking_51 = CASE WHEN @isauto_v152spositiontaking_mem_51 > 0 THEN @isauto_v152spositiontaking_mem_51 ELSE @isauto_v151spositiontaking_41 END,
	@isauto_v152spositiontaking_52 = CASE WHEN @isauto_v152spositiontaking_mem_52 > 0 THEN @isauto_v152spositiontaking_mem_52 ELSE @isauto_v151spositiontaking_42 END,
	@isauto_v153spositiontaking_51 = CASE WHEN @isauto_v153spositiontaking_mem_51 > 0 THEN @isauto_v153spositiontaking_mem_51 ELSE @isauto_v151spositiontaking_41 END,
	@isauto_v153spositiontaking_52 = CASE WHEN @isauto_v153spositiontaking_mem_52 > 0 THEN @isauto_v153spositiontaking_mem_52 ELSE @isauto_v151spositiontaking_42 END
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--um=im1>0?um1:um2
SELECT 
	@auto_v151mpositiontaking_31 = CASE WHEN @isauto_v151mpositiontaking_mem_31>0 THEN @auto_v151mpositiontaking_mem_31 ELSE @auto_v151mpositiontaking_31 END,
	@auto_v151mpositiontaking_32 = CASE WHEN @isauto_v151mpositiontaking_mem_32>0 THEN @auto_v151mpositiontaking_mem_32 ELSE @auto_v151mpositiontaking_32 END,
	@auto_v151mpositiontaking_41 = CASE WHEN @isauto_v151mpositiontaking_mem_41>0 THEN @auto_v151mpositiontaking_mem_41 ELSE @auto_v151mpositiontaking_41 END,
	@auto_v151mpositiontaking_42 = CASE WHEN @isauto_v151mpositiontaking_mem_42>0 THEN @auto_v151mpositiontaking_mem_42 ELSE @auto_v151mpositiontaking_42 END,
	@auto_v151mpositiontaking_51 = CASE WHEN @isauto_v151mpositiontaking_mem_51>0 THEN @auto_v151mpositiontaking_mem_51 ELSE @auto_v151mpositiontaking_51 END,
	@auto_v151mpositiontaking_52 = CASE WHEN @isauto_v151mpositiontaking_mem_52>0 THEN @auto_v151mpositiontaking_mem_52 ELSE @auto_v151mpositiontaking_52 END,
	@auto_v152mpositiontaking_41 = CASE WHEN @isauto_v152mpositiontaking_mem_41>0 THEN @auto_v152mpositiontaking_mem_41 ELSE @auto_v152mpositiontaking_41 END,
	@auto_v152mpositiontaking_42 = CASE WHEN @isauto_v152mpositiontaking_mem_42>0 THEN @auto_v152mpositiontaking_mem_42 ELSE @auto_v152mpositiontaking_42 END,
	@auto_v152mpositiontaking_51 = CASE WHEN @isauto_v152mpositiontaking_mem_51>0 THEN @auto_v152mpositiontaking_mem_51 ELSE @auto_v152mpositiontaking_51 END,
	@auto_v152mpositiontaking_52 = CASE WHEN @isauto_v152mpositiontaking_mem_52>0 THEN @auto_v152mpositiontaking_mem_52 ELSE @auto_v152mpositiontaking_52 END,
	@auto_v153mpositiontaking_51 = CASE WHEN @isauto_v153mpositiontaking_mem_51>0 THEN @auto_v153mpositiontaking_mem_51 ELSE @auto_v153mpositiontaking_51 END,
	@auto_v153mpositiontaking_52 = CASE WHEN @isauto_v153mpositiontaking_mem_52>0 THEN @auto_v153mpositiontaking_mem_52 ELSE @auto_v153mpositiontaking_52 END,
--im=im1>0?im1:im2
	@isauto_v151mpositiontaking_31 = CASE WHEN @isauto_v151mpositiontaking_mem_31>0 THEN @isauto_v151mpositiontaking_mem_31 ELSE @isauto_v151mpositiontaking_31 END,
	@isauto_v151mpositiontaking_32 = CASE WHEN @isauto_v151mpositiontaking_mem_32>0 THEN @isauto_v151mpositiontaking_mem_32 ELSE @isauto_v151mpositiontaking_32 END,
	@isauto_v151mpositiontaking_41 = CASE WHEN @isauto_v151mpositiontaking_mem_41>0 THEN @isauto_v151mpositiontaking_mem_41 ELSE @isauto_v151mpositiontaking_41 END,
	@isauto_v151mpositiontaking_42 = CASE WHEN @isauto_v151mpositiontaking_mem_42>0 THEN @isauto_v151mpositiontaking_mem_42 ELSE @isauto_v151mpositiontaking_42 END,
	@isauto_v151mpositiontaking_51 = CASE WHEN @isauto_v151mpositiontaking_mem_51>0 THEN @isauto_v151mpositiontaking_mem_51 ELSE @isauto_v151mpositiontaking_51 END,
	@isauto_v151mpositiontaking_52 = CASE WHEN @isauto_v151mpositiontaking_mem_52>0 THEN @isauto_v151mpositiontaking_mem_52 ELSE @isauto_v151mpositiontaking_52 END,
	@isauto_v152mpositiontaking_41 = CASE WHEN @isauto_v152mpositiontaking_mem_41>0 THEN @isauto_v152mpositiontaking_mem_41 ELSE @isauto_v152mpositiontaking_41 END,
	@isauto_v152mpositiontaking_42 = CASE WHEN @isauto_v152mpositiontaking_mem_42>0 THEN @isauto_v152mpositiontaking_mem_42 ELSE @isauto_v152mpositiontaking_42 END,
	@isauto_v152mpositiontaking_51 = CASE WHEN @isauto_v152mpositiontaking_mem_51>0 THEN @isauto_v152mpositiontaking_mem_51 ELSE @isauto_v152mpositiontaking_51 END,
	@isauto_v152mpositiontaking_52 = CASE WHEN @isauto_v152mpositiontaking_mem_52>0 THEN @isauto_v152mpositiontaking_mem_52 ELSE @isauto_v152mpositiontaking_52 END,
	@isauto_v153mpositiontaking_51 = CASE WHEN @isauto_v153mpositiontaking_mem_51>0 THEN @isauto_v153mpositiontaking_mem_51 ELSE @isauto_v153mpositiontaking_51 END,
	@isauto_v153mpositiontaking_52 = CASE WHEN @isauto_v153mpositiontaking_mem_52>0 THEN @isauto_v153mpositiontaking_mem_52 ELSE @isauto_v153mpositiontaking_52 END


--a1=min(a1,m3)
SELECT 
	@v151apositiontaking_31 = CASE WHEN @v151apositiontaking_31 > @v151mapositiontaking_31_max THEN @v151mapositiontaking_31_max ELSE @v151apositiontaking_31 END,
	@v151apositiontaking_32 = CASE WHEN @v151apositiontaking_32 > @v151mapositiontaking_32_max THEN @v151mapositiontaking_32_max ELSE @v151apositiontaking_32 END,
	@v151apositiontaking_41 = CASE WHEN @v151apositiontaking_41 > @v151mapositiontaking_41_max THEN @v151mapositiontaking_41_max ELSE @v151apositiontaking_41 END,
	@v151apositiontaking_42 = CASE WHEN @v151apositiontaking_42 > @v151mapositiontaking_42_max THEN @v151mapositiontaking_42_max ELSE @v151apositiontaking_42 END,
	@v151apositiontaking_51 = CASE WHEN @v151apositiontaking_51 > @v151mapositiontaking_51_max THEN @v151mapositiontaking_51_max ELSE @v151apositiontaking_51 END,
	@v151apositiontaking_52 = CASE WHEN @v151apositiontaking_52 > @v151mapositiontaking_52_max THEN @v151mapositiontaking_52_max ELSE @v151apositiontaking_52 END,
	@v152apositiontaking_41 = CASE WHEN @v152apositiontaking_41 > @v152mapositiontaking_41_max THEN @v152mapositiontaking_41_max ELSE @v152apositiontaking_41 END,
	@v152apositiontaking_42 = CASE WHEN @v152apositiontaking_42 > @v152mapositiontaking_42_max THEN @v152mapositiontaking_42_max ELSE @v152apositiontaking_42 END,
	@v152apositiontaking_51 = CASE WHEN @v152apositiontaking_51 > @v152mapositiontaking_51_max THEN @v152mapositiontaking_51_max ELSE @v152apositiontaking_51 END,
	@v152apositiontaking_52 = CASE WHEN @v152apositiontaking_52 > @v152mapositiontaking_52_max THEN @v152mapositiontaking_52_max ELSE @v152apositiontaking_52 END,
	@v153apositiontaking_51 = CASE WHEN @v153apositiontaking_51 > @v153mapositiontaking_51_max THEN @v153mapositiontaking_51_max ELSE @v153apositiontaking_51 END,
	@v153apositiontaking_52 = CASE WHEN @v153apositiontaking_52 > @v153mapositiontaking_52_max THEN @v153mapositiontaking_52_max ELSE @v153apositiontaking_52 END


--a1=if(!im)if(m1+a1>m3,m3-m1)
SELECT 
	@v151apositiontaking_31 = CASE WHEN @isauto_v151mpositiontaking_31 > 0 THEN @v151apositiontaking_31 ELSE CASE WHEN @v151apositiontaking_31 + @v151mpositiontaking_31 > @v151mapositiontaking_31_max THEN @v151mapositiontaking_31_max - @v151mpositiontaking_31 ELSE @v151apositiontaking_31 END END,
	@v151apositiontaking_32 = CASE WHEN @isauto_v151mpositiontaking_32 > 0 THEN @v151apositiontaking_32 ELSE CASE WHEN @v151apositiontaking_32 + @v151mpositiontaking_32 > @v151mapositiontaking_32_max THEN @v151mapositiontaking_32_max - @v151mpositiontaking_32 ELSE @v151apositiontaking_32 END END,
	@v151apositiontaking_41 = CASE WHEN @isauto_v151mpositiontaking_41 > 0 THEN @v151apositiontaking_41 ELSE CASE WHEN @v151apositiontaking_41 + @v151mpositiontaking_41 > @v151mapositiontaking_41_max THEN @v151mapositiontaking_41_max - @v151mpositiontaking_41 ELSE @v151apositiontaking_41 END END,
	@v151apositiontaking_42 = CASE WHEN @isauto_v151mpositiontaking_42 > 0 THEN @v151apositiontaking_42 ELSE CASE WHEN @v151apositiontaking_42 + @v151mpositiontaking_42 > @v151mapositiontaking_42_max THEN @v151mapositiontaking_42_max - @v151mpositiontaking_42 ELSE @v151apositiontaking_42 END END,
	@v151apositiontaking_51 = CASE WHEN @isauto_v151mpositiontaking_51 > 0 THEN @v151apositiontaking_51 ELSE CASE WHEN @v151apositiontaking_51 + @v151mpositiontaking_51 > @v151mapositiontaking_51_max THEN @v151mapositiontaking_51_max - @v151mpositiontaking_51 ELSE @v151apositiontaking_51 END END,
	@v151apositiontaking_52 = CASE WHEN @isauto_v151mpositiontaking_52 > 0 THEN @v151apositiontaking_52 ELSE CASE WHEN @v151apositiontaking_52 + @v151mpositiontaking_52 > @v151mapositiontaking_52_max THEN @v151mapositiontaking_52_max - @v151mpositiontaking_52 ELSE @v151apositiontaking_52 END END,
	@v152apositiontaking_41 = CASE WHEN @isauto_v152mpositiontaking_41 > 0 THEN @v152apositiontaking_41 ELSE CASE WHEN @v152apositiontaking_41 + @v152mpositiontaking_41 > @v152mapositiontaking_41_max THEN @v152mapositiontaking_41_max - @v152mpositiontaking_41 ELSE @v152apositiontaking_41 END END,
	@v152apositiontaking_42 = CASE WHEN @isauto_v152mpositiontaking_42 > 0 THEN @v152apositiontaking_42 ELSE CASE WHEN @v152apositiontaking_42 + @v152mpositiontaking_42 > @v152mapositiontaking_42_max THEN @v152mapositiontaking_42_max - @v152mpositiontaking_42 ELSE @v152apositiontaking_42 END END,
	@v152apositiontaking_51 = CASE WHEN @isauto_v152mpositiontaking_51 > 0 THEN @v152apositiontaking_51 ELSE CASE WHEN @v152apositiontaking_51 + @v152mpositiontaking_51 > @v152mapositiontaking_51_max THEN @v152mapositiontaking_51_max - @v152mpositiontaking_51 ELSE @v152apositiontaking_51 END END,
	@v152apositiontaking_52 = CASE WHEN @isauto_v152mpositiontaking_52 > 0 THEN @v152apositiontaking_52 ELSE CASE WHEN @v152apositiontaking_52 + @v152mpositiontaking_52 > @v152mapositiontaking_52_max THEN @v152mapositiontaking_52_max - @v152mpositiontaking_52 ELSE @v152apositiontaking_52 END END,
	@v153apositiontaking_51 = CASE WHEN @isauto_v153mpositiontaking_51 > 0 THEN @v153apositiontaking_51 ELSE CASE WHEN @v153apositiontaking_51 + @v153mpositiontaking_51 > @v153mapositiontaking_51_max THEN @v153mapositiontaking_51_max - @v153mpositiontaking_51 ELSE @v153apositiontaking_51 END END,
	@v153apositiontaking_52 = CASE WHEN @isauto_v153mpositiontaking_52 > 0 THEN @v153apositiontaking_52 ELSE CASE WHEN @v153apositiontaking_52 + @v153mpositiontaking_52 > @v153mapositiontaking_52_max THEN @v153mapositiontaking_52_max - @v153mpositiontaking_52 ELSE @v153apositiontaking_52 END END


SELECT 
	@v151apositiontaking_31 = CASE WHEN @v151apositiontaking_31 < 0 THEN 0 ELSE @v151apositiontaking_31 END,
	@v151apositiontaking_32 = CASE WHEN @v151apositiontaking_32 < 0 THEN 0 ELSE @v151apositiontaking_32 END,
	@v151apositiontaking_41 = CASE WHEN @v151apositiontaking_41 < 0 THEN 0 ELSE @v151apositiontaking_41 END,
	@v151apositiontaking_42 = CASE WHEN @v151apositiontaking_42 < 0 THEN 0 ELSE @v151apositiontaking_42 END,
	@v151apositiontaking_51 = CASE WHEN @v151apositiontaking_51 < 0 THEN 0 ELSE @v151apositiontaking_51 END,
	@v151apositiontaking_52 = CASE WHEN @v151apositiontaking_52 < 0 THEN 0 ELSE @v151apositiontaking_52 END,
	@v152apositiontaking_41 = CASE WHEN @v152apositiontaking_41 < 0 THEN 0 ELSE @v152apositiontaking_41 END,
	@v152apositiontaking_42 = CASE WHEN @v152apositiontaking_42 < 0 THEN 0 ELSE @v152apositiontaking_42 END,
	@v152apositiontaking_51 = CASE WHEN @v152apositiontaking_51 < 0 THEN 0 ELSE @v152apositiontaking_51 END,
	@v152apositiontaking_52 = CASE WHEN @v152apositiontaking_52 < 0 THEN 0 ELSE @v152apositiontaking_52 END,
	@v153apositiontaking_51 = CASE WHEN @v153apositiontaking_51 < 0 THEN 0 ELSE @v153apositiontaking_51 END,
	@v153apositiontaking_52 = CASE WHEN @v153apositiontaking_52 < 0 THEN 0 ELSE @v153apositiontaking_52 END

---------------------------------------------------------------------------------------------------------------------------------------------
----------------***Use Master Auto Position Taking***----------------------------------
--use @auto_mpt at agent
--@max_mpt = @maxdownlinepos + mpt ; pt: positiontaking
--if um = 0 then m1 = m2
--else	if um < m3 - a1 then m1 = um
--		else m1 = m3 - a1

--m1=iif(im,min(m3-a1,um),m1)
select @v151mpositiontaking_31 = case when isnull(@isauto_v151mpositiontaking_31, 0)=0 then @v151mpositiontaking_31 else case when @auto_v151mpositiontaking_31 < @v151mapositiontaking_31_max - @v151apositiontaking_31 then @auto_v151mpositiontaking_31 else @v151mapositiontaking_31_max - @v151apositiontaking_31 end end
select @v151mpositiontaking_32 = case when isnull(@isauto_v151mpositiontaking_32, 0)=0 then @v151mpositiontaking_32 else case when @auto_v151mpositiontaking_32 < @v151mapositiontaking_32_max - @v151apositiontaking_32 then @auto_v151mpositiontaking_32 else @v151mapositiontaking_32_max - @v151apositiontaking_32 end end
select @v151mpositiontaking_41 = case when isnull(@isauto_v151mpositiontaking_41, 0)=0 then @v151mpositiontaking_41 else case when @auto_v151mpositiontaking_41 < @v151mapositiontaking_41_max - @v151apositiontaking_41 then @auto_v151mpositiontaking_41 else @v151mapositiontaking_41_max - @v151apositiontaking_41 end end
select @v151mpositiontaking_42 = case when isnull(@isauto_v151mpositiontaking_42, 0)=0 then @v151mpositiontaking_42 else case when @auto_v151mpositiontaking_42 < @v151mapositiontaking_42_max - @v151apositiontaking_42 then @auto_v151mpositiontaking_42 else @v151mapositiontaking_42_max - @v151apositiontaking_42 end end
select @v151mpositiontaking_51 = case when isnull(@isauto_v151mpositiontaking_51, 0)=0 then @v151mpositiontaking_51 else case when @auto_v151mpositiontaking_51 < @v151mapositiontaking_51_max - @v151apositiontaking_51 then @auto_v151mpositiontaking_51 else @v151mapositiontaking_51_max - @v151apositiontaking_51 end end
select @v151mpositiontaking_52 = case when isnull(@isauto_v151mpositiontaking_52, 0)=0 then @v151mpositiontaking_52 else case when @auto_v151mpositiontaking_52 < @v151mapositiontaking_52_max - @v151apositiontaking_52 then @auto_v151mpositiontaking_52 else @v151mapositiontaking_52_max - @v151apositiontaking_52 end end
select @v152mpositiontaking_41 = case when isnull(@isauto_v152mpositiontaking_41, 0)=0 then @v152mpositiontaking_41 else case when @auto_v152mpositiontaking_41 < @v152mapositiontaking_41_max - @v152apositiontaking_41 then @auto_v152mpositiontaking_41 else @v152mapositiontaking_41_max - @v152apositiontaking_41 end end
select @v152mpositiontaking_42 = case when isnull(@isauto_v152mpositiontaking_42, 0)=0 then @v152mpositiontaking_42 else case when @auto_v152mpositiontaking_42 < @v152mapositiontaking_42_max - @v152apositiontaking_42 then @auto_v152mpositiontaking_42 else @v152mapositiontaking_42_max - @v152apositiontaking_42 end end
select @v152mpositiontaking_51 = case when isnull(@isauto_v152mpositiontaking_51, 0)=0 then @v152mpositiontaking_51 else case when @auto_v152mpositiontaking_51 < @v152mapositiontaking_51_max - @v152apositiontaking_51 then @auto_v152mpositiontaking_51 else @v152mapositiontaking_51_max - @v152apositiontaking_51 end end
select @v152mpositiontaking_52 = case when isnull(@isauto_v152mpositiontaking_52, 0)=0 then @v152mpositiontaking_52 else case when @auto_v152mpositiontaking_52 < @v152mapositiontaking_52_max - @v152apositiontaking_52 then @auto_v152mpositiontaking_52 else @v152mapositiontaking_52_max - @v152apositiontaking_52 end end
select @v153mpositiontaking_51 = case when isnull(@isauto_v153mpositiontaking_51, 0)=0 then @v153mpositiontaking_51 else case when @auto_v153mpositiontaking_51 < @v153mapositiontaking_51_max - @v153apositiontaking_51 then @auto_v153mpositiontaking_51 else @v153mapositiontaking_51_max - @v153apositiontaking_51 end end
select @v153mpositiontaking_52 = case when isnull(@isauto_v153mpositiontaking_52, 0)=0 then @v153mpositiontaking_52 else case when @auto_v153mpositiontaking_52 < @v153mapositiontaking_52_max - @v153apositiontaking_52 then @auto_v153mpositiontaking_52 else @v153mapositiontaking_52_max - @v153apositiontaking_52 end end

--------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------

----------------***Use Auto Position Taking***----------------------------------
--@max_spt = @maxdownlinepos + spt ; pt: positiontaking
--if @auto_spt = 0 then @spt = @spt  -- Auto pt is not used
--else	if @auto_spt < @max_spt - @mpt - @apt then @spt = @auto_spt
--		else @spt = @max_spt - @mpt - @apt
SELECT @v151spositiontaking_31 = CASE WHEN ISNULL(@isauto_v151spositiontaking_31, 0)<=0 THEN @v151spositiontaking_31 ELSE CASE WHEN @auto_v151spositiontaking_31 < @max_v151spositiontaking_31 - @v151mpositiontaking_31 - @v151apositiontaking_31 THEN @auto_v151spositiontaking_31 ELSE @max_v151spositiontaking_31 - @v151mpositiontaking_31 - @v151apositiontaking_31 END END
SELECT @v151spositiontaking_32 = CASE WHEN ISNULL(@isauto_v151spositiontaking_32, 0)<=0 THEN @v151spositiontaking_32 ELSE CASE WHEN @auto_v151spositiontaking_32 < @max_v151spositiontaking_32 - @v151mpositiontaking_32 - @v151apositiontaking_32 THEN @auto_v151spositiontaking_32 ELSE @max_v151spositiontaking_32 - @v151mpositiontaking_32 - @v151apositiontaking_32 END END
SELECT @v151spositiontaking_41 = CASE WHEN ISNULL(@isauto_v151spositiontaking_41, 0)<=0 THEN @v151spositiontaking_41 ELSE CASE WHEN @auto_v151spositiontaking_41 < @max_v151spositiontaking_41 - @v151mpositiontaking_41 - @v151apositiontaking_41 THEN @auto_v151spositiontaking_41 ELSE @max_v151spositiontaking_41 - @v151mpositiontaking_41 - @v151apositiontaking_41 END END
SELECT @v151spositiontaking_42 = CASE WHEN ISNULL(@isauto_v151spositiontaking_42, 0)<=0 THEN @v151spositiontaking_42 ELSE CASE WHEN @auto_v151spositiontaking_42 < @max_v151spositiontaking_42 - @v151mpositiontaking_42 - @v151apositiontaking_42 THEN @auto_v151spositiontaking_42 ELSE @max_v151spositiontaking_42 - @v151mpositiontaking_42 - @v151apositiontaking_42 END END
SELECT @v151spositiontaking_51 = CASE WHEN ISNULL(@isauto_v151spositiontaking_51, 0)<=0 THEN @v151spositiontaking_51 ELSE CASE WHEN @auto_v151spositiontaking_51 < @max_v151spositiontaking_51 - @v151mpositiontaking_51 - @v151apositiontaking_51 THEN @auto_v151spositiontaking_51 ELSE @max_v151spositiontaking_51 - @v151mpositiontaking_51 - @v151apositiontaking_51 END END
SELECT @v151spositiontaking_52 = CASE WHEN ISNULL(@isauto_v151spositiontaking_52, 0)<=0 THEN @v151spositiontaking_52 ELSE CASE WHEN @auto_v151spositiontaking_52 < @max_v151spositiontaking_52 - @v151mpositiontaking_52 - @v151apositiontaking_52 THEN @auto_v151spositiontaking_52 ELSE @max_v151spositiontaking_52 - @v151mpositiontaking_52 - @v151apositiontaking_52 END END
SELECT @v152spositiontaking_41 = CASE WHEN ISNULL(@isauto_v152spositiontaking_41, 0)<=0 THEN @v152spositiontaking_41 ELSE CASE WHEN @auto_v152spositiontaking_41 < @max_v152spositiontaking_41 - @v152mpositiontaking_41 - @v152apositiontaking_41 THEN @auto_v152spositiontaking_41 ELSE @max_v152spositiontaking_41 - @v152mpositiontaking_41 - @v152apositiontaking_41 END END
SELECT @v152spositiontaking_42 = CASE WHEN ISNULL(@isauto_v152spositiontaking_42, 0)<=0 THEN @v152spositiontaking_42 ELSE CASE WHEN @auto_v152spositiontaking_42 < @max_v152spositiontaking_42 - @v152mpositiontaking_42 - @v152apositiontaking_42 THEN @auto_v152spositiontaking_42 ELSE @max_v152spositiontaking_42 - @v152mpositiontaking_42 - @v152apositiontaking_42 END END
SELECT @v152spositiontaking_51 = CASE WHEN ISNULL(@isauto_v152spositiontaking_51, 0)<=0 THEN @v152spositiontaking_51 ELSE CASE WHEN @auto_v152spositiontaking_51 < @max_v152spositiontaking_51 - @v152mpositiontaking_51 - @v152apositiontaking_51 THEN @auto_v152spositiontaking_51 ELSE @max_v152spositiontaking_51 - @v152mpositiontaking_51 - @v152apositiontaking_51 END END
SELECT @v152spositiontaking_52 = CASE WHEN ISNULL(@isauto_v152spositiontaking_52, 0)<=0 THEN @v152spositiontaking_52 ELSE CASE WHEN @auto_v152spositiontaking_52 < @max_v152spositiontaking_52 - @v152mpositiontaking_52 - @v152apositiontaking_52 THEN @auto_v152spositiontaking_52 ELSE @max_v152spositiontaking_52 - @v152mpositiontaking_52 - @v152apositiontaking_52 END END
SELECT @v153spositiontaking_51 = CASE WHEN ISNULL(@isauto_v153spositiontaking_51, 0)<=0 THEN @v153spositiontaking_51 ELSE CASE WHEN @auto_v153spositiontaking_51 < @max_v153spositiontaking_51 - @v153mpositiontaking_51 - @v153apositiontaking_51 THEN @auto_v153spositiontaking_51 ELSE @max_v153spositiontaking_51 - @v153mpositiontaking_51 - @v153apositiontaking_51 END END
SELECT @v153spositiontaking_52 = CASE WHEN ISNULL(@isauto_v153spositiontaking_52, 0)<=0 THEN @v153spositiontaking_52 ELSE CASE WHEN @auto_v153spositiontaking_52 < @max_v153spositiontaking_52 - @v153mpositiontaking_52 - @v153apositiontaking_52 THEN @auto_v153spositiontaking_52 ELSE @max_v153spositiontaking_52 - @v153mpositiontaking_52 - @v153apositiontaking_52 END END
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--max_spositiontaking = if(i1||i3)s4:s4-m1-a1
SELECT @max_v151spositiontaking_31 = CASE WHEN ISNULL(@isauto_v151spositiontaking_31, 0)>0 THEN @max_v151spositiontaking_31 ELSE @max_v151spositiontaking_31 - @v151mpositiontaking_31 - @v151apositiontaking_31 END
SELECT @max_v151spositiontaking_32 = CASE WHEN ISNULL(@isauto_v151spositiontaking_32, 0)>0 THEN @max_v151spositiontaking_32 ELSE @max_v151spositiontaking_32 - @v151mpositiontaking_32 - @v151apositiontaking_32 END
SELECT @max_v151spositiontaking_41 = CASE WHEN ISNULL(@isauto_v151spositiontaking_41, 0)>0 THEN @max_v151spositiontaking_41 ELSE @max_v151spositiontaking_41 - @v151mpositiontaking_41 - @v151apositiontaking_41 END
SELECT @max_v151spositiontaking_42 = CASE WHEN ISNULL(@isauto_v151spositiontaking_42, 0)>0 THEN @max_v151spositiontaking_42 ELSE @max_v151spositiontaking_42 - @v151mpositiontaking_42 - @v151apositiontaking_42 END
SELECT @max_v151spositiontaking_51 = CASE WHEN ISNULL(@isauto_v151spositiontaking_51, 0)>0 THEN @max_v151spositiontaking_51 ELSE @max_v151spositiontaking_51 - @v151mpositiontaking_51 - @v151apositiontaking_51 END
SELECT @max_v151spositiontaking_52 = CASE WHEN ISNULL(@isauto_v151spositiontaking_52, 0)>0 THEN @max_v151spositiontaking_52 ELSE @max_v151spositiontaking_52 - @v151mpositiontaking_52 - @v151apositiontaking_52 END
SELECT @max_v152spositiontaking_41 = CASE WHEN ISNULL(@isauto_v152spositiontaking_41, 0)>0 THEN @max_v152spositiontaking_41 ELSE @max_v152spositiontaking_41 - @v152mpositiontaking_41 - @v152apositiontaking_41 END
SELECT @max_v152spositiontaking_42 = CASE WHEN ISNULL(@isauto_v152spositiontaking_42, 0)>0 THEN @max_v152spositiontaking_42 ELSE @max_v152spositiontaking_42 - @v152mpositiontaking_42 - @v152apositiontaking_42 END
SELECT @max_v152spositiontaking_51 = CASE WHEN ISNULL(@isauto_v152spositiontaking_51, 0)>0 THEN @max_v152spositiontaking_51 ELSE @max_v152spositiontaking_51 - @v152mpositiontaking_51 - @v152apositiontaking_51 END
SELECT @max_v152spositiontaking_52 = CASE WHEN ISNULL(@isauto_v152spositiontaking_52, 0)>0 THEN @max_v152spositiontaking_52 ELSE @max_v152spositiontaking_52 - @v152mpositiontaking_52 - @v152apositiontaking_52 END
SELECT @max_v153spositiontaking_51 = CASE WHEN ISNULL(@isauto_v153spositiontaking_51, 0)>0 THEN @max_v153spositiontaking_51 ELSE @max_v153spositiontaking_51 - @v153mpositiontaking_51 - @v153apositiontaking_51 END
SELECT @max_v153spositiontaking_52 = CASE WHEN ISNULL(@isauto_v153spositiontaking_52, 0)>0 THEN @max_v153spositiontaking_52 ELSE @max_v153spositiontaking_52 - @v153mpositiontaking_52 - @v153apositiontaking_52 END

--//REPLACING CHECK MAX SUPER PT ON MEMBER

--s1=min(s1,max_spositiontaking)
SELECT @v151spositiontaking_31 = CASE WHEN @v151spositiontaking_31 > @max_v151spositiontaking_31 THEN @max_v151spositiontaking_31 ELSE @v151spositiontaking_31 END
SELECT @v151spositiontaking_32 = CASE WHEN @v151spositiontaking_32 > @max_v151spositiontaking_32 THEN @max_v151spositiontaking_32 ELSE @v151spositiontaking_32 END
SELECT @v151spositiontaking_41 = CASE WHEN @v151spositiontaking_41 > @max_v151spositiontaking_41 THEN @max_v151spositiontaking_41 ELSE @v151spositiontaking_41 END
SELECT @v151spositiontaking_42 = CASE WHEN @v151spositiontaking_42 > @max_v151spositiontaking_42 THEN @max_v151spositiontaking_42 ELSE @v151spositiontaking_42 END
SELECT @v151spositiontaking_51 = CASE WHEN @v151spositiontaking_51 > @max_v151spositiontaking_51 THEN @max_v151spositiontaking_51 ELSE @v151spositiontaking_51 END
SELECT @v151spositiontaking_52 = CASE WHEN @v151spositiontaking_52 > @max_v151spositiontaking_52 THEN @max_v151spositiontaking_52 ELSE @v151spositiontaking_52 END
SELECT @v152spositiontaking_41 = CASE WHEN @v152spositiontaking_41 > @max_v152spositiontaking_41 THEN @max_v152spositiontaking_41 ELSE @v152spositiontaking_41 END
SELECT @v152spositiontaking_42 = CASE WHEN @v152spositiontaking_42 > @max_v152spositiontaking_42 THEN @max_v152spositiontaking_42 ELSE @v152spositiontaking_42 END
SELECT @v152spositiontaking_51 = CASE WHEN @v152spositiontaking_51 > @max_v152spositiontaking_51 THEN @max_v152spositiontaking_51 ELSE @v152spositiontaking_51 END
SELECT @v152spositiontaking_52 = CASE WHEN @v152spositiontaking_52 > @max_v152spositiontaking_52 THEN @max_v152spositiontaking_52 ELSE @v152spositiontaking_52 END
SELECT @v153spositiontaking_51 = CASE WHEN @v153spositiontaking_51 > @max_v153spositiontaking_51 THEN @max_v153spositiontaking_51 ELSE @v153spositiontaking_51 END
SELECT @v153spositiontaking_52 = CASE WHEN @v153spositiontaking_52 > @max_v153spositiontaking_52 THEN @max_v153spositiontaking_52 ELSE @v153spositiontaking_52 END


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------
EXEC dbo.Acc_CustSetting3rd_08
	@custid = @custid,
	@roleid = 2,
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
	@v153mpositiontaking_52 = @v153mpositiontaking_52,
	
	@v151apositiontaking_31 = @v151apositiontaking_31,
	@v151apositiontaking_32 = @v151apositiontaking_32,
	@v151apositiontaking_41 = @v151apositiontaking_41,
	@v151apositiontaking_42 = @v151apositiontaking_42,
	@v151apositiontaking_51 = @v151apositiontaking_51,
	@v151apositiontaking_52 = @v151apositiontaking_52,
	@v152apositiontaking_41 = @v152apositiontaking_41,
	@v152apositiontaking_42 = @v152apositiontaking_42,
	@v152apositiontaking_51 = @v152apositiontaking_51,
	@v152apositiontaking_52 = @v152apositiontaking_52,
	@v153apositiontaking_51 = @v153apositiontaking_51,
	@v153apositiontaking_52 = @v153apositiontaking_52,
			
	@UpdateMultiple = @UpdateMultiple,
	@UpdatePositiontakingv151_31 = @UpdatePositiontakingv151_31,
	@UpdatePositiontakingv151_41 = @UpdatePositiontakingv151_41,
	@UpdatePositiontakingv151_51 = @UpdatePositiontakingv151_51,
	@UpdatePositiontakingv152_41 = @UpdatePositiontakingv152_41,
	@UpdatePositiontakingv152_51 = @UpdatePositiontakingv152_51,
	@UpdatePositiontakingv153_51 = @UpdatePositiontakingv153_51
	


EXEC dbo.Acc_CustSetting3rd_00
		@custid = @custid, 
		@recommend = @recommend, 
		@mrecommend = @mrecommend, 
		@srecommend = @srecommend,
		@mode = 'horse'	
---EXEC dbo.Acc_CustomerUpdMemberHR_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

/*
BEGIN TRANSACTION
---------------------------------------

UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
SET
	apositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN apositiontaking	
							ELSE CASE WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151apositiontaking_31 
									WHEN bettype = 32 and sporttype = 151  and @UpdatePositiontakingv151_31 = 1 THEN @v151apositiontaking_32 
									WHEN bettype = 41 and sporttype = 151  and @UpdatePositiontakingv151_41 = 1 THEN @v151apositiontaking_41 
									WHEN bettype = 42 and sporttype = 151  and @UpdatePositiontakingv151_41 = 1 THEN @v151apositiontaking_42 
									WHEN bettype = 51 and sporttype = 151  and @UpdatePositiontakingv151_51 = 1 THEN @v151apositiontaking_51 
									WHEN bettype = 52 and sporttype = 151  and @UpdatePositiontakingv151_51 = 1 THEN @v151apositiontaking_52 
									WHEN bettype = 41 and sporttype = 152  and @UpdatePositiontakingv152_41 = 1 THEN @v152apositiontaking_41 
									WHEN bettype = 42 and sporttype = 152  and @UpdatePositiontakingv152_41 = 1 THEN @v152apositiontaking_42 
									WHEN bettype = 51 and sporttype = 152  and @UpdatePositiontakingv152_51 = 1 THEN @v152apositiontaking_51 
									WHEN bettype = 52 and sporttype = 152  and @UpdatePositiontakingv152_51 = 1 THEN @v152apositiontaking_52 
									WHEN bettype = 51 and sporttype = 153  and @UpdatePositiontakingv153_51 = 1 THEN @v153apositiontaking_51 
									WHEN bettype = 52 and sporttype = 153  and @UpdatePositiontakingv153_51 = 1 THEN @v153apositiontaking_52 
									ELSE apositiontaking END END,
	--Auto Master PT
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	mpositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN mpositiontaking
							ELSE CASE	WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_31 
										WHEN bettype = 32 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151mpositiontaking_32 
										WHEN bettype = 41 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_41 
										WHEN bettype = 42 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151mpositiontaking_42 
										WHEN bettype = 51 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_51 
										WHEN bettype = 52 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151mpositiontaking_52 
										WHEN bettype = 41 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_41 
										WHEN bettype = 42 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152mpositiontaking_42 
										WHEN bettype = 51 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_51 
										WHEN bettype = 52 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152mpositiontaking_52 
										WHEN bettype = 51 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_51 
										WHEN bettype = 52 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153mpositiontaking_52 
										ELSE mpositiontaking END END,	
					  
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	spositiontaking = CASE WHEN @UpdateMultiple = 1 
								AND (	(sporttype=151 AND @UpdatePositiontakingv151_31 = 0 AND @UpdatePositiontakingv151_41 = 0 AND @UpdatePositiontakingv151_51 = 0 )
									OR  (sporttype=152 AND @UpdatePositiontakingv152_41 = 0 AND @UpdatePositiontakingv152_51 = 0 ) 
									OR  (sporttype=153 AND @UpdatePositiontakingv153_51 = 0))
								THEN spositiontaking
							ELSE CASE	WHEN bettype = 31 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_31 
										WHEN bettype = 32 and sporttype = 151 and @UpdatePositiontakingv151_31 = 1 THEN @v151spositiontaking_32 
										WHEN bettype = 41 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_41 
										WHEN bettype = 42 and sporttype = 151 and @UpdatePositiontakingv151_41 = 1 THEN @v151spositiontaking_42 
										WHEN bettype = 51 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_51
										WHEN bettype = 52 and sporttype = 151 and @UpdatePositiontakingv151_51 = 1 THEN @v151spositiontaking_52 
										WHEN bettype = 41 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_41 
										WHEN bettype = 42 and sporttype = 152 and @UpdatePositiontakingv152_41 = 1 THEN @v152spositiontaking_42 
										WHEN bettype = 51 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_51 
										WHEN bettype = 52 and sporttype = 152 and @UpdatePositiontakingv152_51 = 1 THEN @v152spositiontaking_52 
										WHEN bettype = 51 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_51 
										WHEN bettype = 52 and sporttype = 153 and @UpdatePositiontakingv153_51 = 1 THEN @v153spositiontaking_52 
										ELSE spositiontaking END
							END
WHERE custid=@custid and sporttype BETWEEN 151 AND 153

EXEC dbo.Acc_CustomerUpdMemberHR_MinMaxPositiontaking @custid = @custid, @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend

COMMIT TRANSACTION
*/

Declare @LogSPData varchar(MAX),
		@TrackingValueDB varchar(5000)
	
Select @LogSPData = '<Acc_CustomerUpdMemberHR_PositionTaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(8000)),space(1)) + '" />' +

'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

'<ag v151apt_31="'+ coalesce(cast(@v151apositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151apt_32="'+ coalesce(cast(@v151apositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151apt_41="'+ coalesce(cast(@v151apositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151apt_42="'+ coalesce(cast(@v151apositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151apt_51="'+ coalesce(cast(@v151apositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v151apt_52="'+ coalesce(cast(@v151apositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v152apt_41="'+ coalesce(cast(@v152apositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v152apt_42="'+ coalesce(cast(@v152apositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v152apt_51="'+ coalesce(cast(@v152apositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v152apt_52="'+ coalesce(cast(@v152apositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v153apt_51="'+ coalesce(cast(@v153apositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v153apt_52="'+ coalesce(cast(@v153apositiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_PositionTaking>'

Select @TrackingValueDB = '<Acc_CustomerUpdMemberHR_PositionTaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(8000)),space(1)) + '" />' +

'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

'<ag v151apt_31="'+ coalesce(cast(@old_v151apositiontaking_31 as varchar(50)),space(1)) + '" ' +
'v151apt_32="'+ coalesce(cast(@old_v151apositiontaking_32 as varchar(50)),space(1)) + '" ' +
'v151apt_41="'+ coalesce(cast(@old_v151apositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v151apt_42="'+ coalesce(cast(@old_v151apositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v151apt_51="'+ coalesce(cast(@old_v151apositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v151apt_52="'+ coalesce(cast(@old_v151apositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v152apt_41="'+ coalesce(cast(@old_v152apositiontaking_41 as varchar(50)),space(1)) + '" ' +
'v152apt_42="'+ coalesce(cast(@old_v152apositiontaking_42 as varchar(50)),space(1)) + '" ' +
'v152apt_51="'+ coalesce(cast(@old_v152apositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v152apt_52="'+ coalesce(cast(@old_v152apositiontaking_52 as varchar(50)),space(1)) + '" ' +
'v153apt_51="'+ coalesce(cast(@old_v153apositiontaking_51 as varchar(50)),space(1)) + '" ' +
'v153apt_52="'+ coalesce(cast(@old_v153apositiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_PositionTaking>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 421,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END TRY
BEGIN CATCH	
	Select @LogSPData = '<Acc_CustomerUpdMemberHR_PositionTaking><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />' +

	'<Multiple UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv151_31="'+ coalesce(cast(@UpdatePositiontakingv151_31 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv151_41="'+ coalesce(cast(@UpdatePositiontakingv151_41 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv151_51="'+ coalesce(cast(@UpdatePositiontakingv151_51 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv152_41="'+ coalesce(cast(@UpdatePositiontakingv152_41 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv152_51="'+ coalesce(cast(@UpdatePositiontakingv152_51 as varchar(1)),space(1)) + '" ' +
	'UpdatePositiontakingv153_51="'+ coalesce(cast(@UpdatePositiontakingv153_51 as varchar(1)),space(1)) + '" />' +

	'<ag v151apt_31="'+ coalesce(cast(@v151apositiontaking_31 as varchar(50)),space(1)) + '" ' +
	'v151apt_32="'+ coalesce(cast(@v151apositiontaking_32 as varchar(50)),space(1)) + '" ' +
	'v151apt_41="'+ coalesce(cast(@v151apositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'v151apt_42="'+ coalesce(cast(@v151apositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'v151apt_51="'+ coalesce(cast(@v151apositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'v151apt_52="'+ coalesce(cast(@v151apositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'v152apt_41="'+ coalesce(cast(@v152apositiontaking_41 as varchar(50)),space(1)) + '" ' +
	'v152apt_42="'+ coalesce(cast(@v152apositiontaking_42 as varchar(50)),space(1)) + '" ' +
	'v152apt_51="'+ coalesce(cast(@v152apositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'v152apt_52="'+ coalesce(cast(@v152apositiontaking_52 as varchar(50)),space(1)) + '" ' +
	'v153apt_51="'+ coalesce(cast(@v153apositiontaking_51 as varchar(50)),space(1)) + '" ' +
	'v153apt_52="'+ coalesce(cast(@v153apositiontaking_52 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdMemberHR_PositionTaking>'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 421,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValueDB,
		@duration = @duration
END CATCH
