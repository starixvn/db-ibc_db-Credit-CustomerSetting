ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgent_PositionTaking]
	@custid int, --agentID
	
	@apositiontaking_1 smallmoney,
	@apositiontaking_2 smallmoney,
	@apositiontaking_3 smallmoney,
	@apositiontaking_4 smallmoney,
	@apositiontaking_5 smallmoney,
	@apositiontaking_6 smallmoney,
	@apositiontaking_7 smallmoney,
	@apositiontaking_8 smallmoney,
	@apositiontaking_9 smallmoney,
	@apositiontaking_10 smallmoney,
	@apositiontaking_9999 smallmoney =0,
	
	@mpositiontaking_1 smallmoney,
	@mpositiontaking_2 smallmoney,
	@mpositiontaking_3 smallmoney,
	@mpositiontaking_4 smallmoney,
	@mpositiontaking_5 smallmoney,
	@mpositiontaking_6 smallmoney,
	@mpositiontaking_7 smallmoney,
	@mpositiontaking_8 smallmoney,
	@mpositiontaking_9 smallmoney,
	@mpositiontaking_10 smallmoney,
	@mpositiontaking_9999 smallmoney =0,
	
	@alivepositiontaking_1 smallmoney,
	@alivepositiontaking_3 smallmoney,
	@alivepositiontaking_7 smallmoney,
	@alivepositiontaking_8 smallmoney,
	@mlivepositiontaking_1 smallmoney,
	@mlivepositiontaking_3 smallmoney,
	@mlivepositiontaking_7 smallmoney,
	@mlivepositiontaking_8 smallmoney,
	
	@v2apositiontaking_1 smallmoney,
	@v2apositiontaking_2 smallmoney,
	@v2apositiontaking_3 smallmoney,
	@v2apositiontaking_7 smallmoney,
	@v2apositiontaking_8 smallmoney,
--	@v2apositiontaking_9 smallmoney,
	@v2apositiontaking_20 smallmoney,

	@v3apositiontaking_1 smallmoney,
	@v3apositiontaking_2 smallmoney,
	@v3apositiontaking_3 smallmoney,
	@v3apositiontaking_20 smallmoney,

	@v5apositiontaking_1 smallmoney,
	@v5apositiontaking_2 smallmoney,
	@v5apositiontaking_3 smallmoney,
	@v5apositiontaking_20 smallmoney,
	@v5apositiontaking_9999 smallmoney = 0,

	@v8apositiontaking_1 smallmoney,
	@v8apositiontaking_3 smallmoney,
	@v8apositiontaking_20 smallmoney,

	@v10apositiontaking_1 smallmoney,
	@v10apositiontaking_2 smallmoney,
	@v10apositiontaking_3 smallmoney,
	@v10apositiontaking_20 smallmoney,

	@v11apositiontaking_1 smallmoney,
	@v11apositiontaking_20 smallmoney,

	@v99apositiontaking_1 smallmoney,
	@v99apositiontaking_2 smallmoney,
	@v99apositiontaking_3 smallmoney,
	@v99apositiontaking_20 smallmoney,

	-- mixed sports
	@v99apositiontaking_9 smallmoney,
	@v154apositiontaking_20 smallmoney = 0,
	
	-- number game
	@v161apositiontaking_81 smallmoney,
	@v161apositiontaking_83 smallmoney,
	--@v161apositiontaking_85 smallmoney,
	@v161apositiontaking_86 smallmoney,
	@v161apositiontaking_88 smallmoney = 0,
	
	@v161alivepositiontaking_85 smallmoney,
	@v161alivepositiontaking_86 smallmoney,
	@v161alivepositiontaking_87 smallmoney,
	@v161alivepositiontaking_89 smallmoney = 0,
	@v161alivepositiontaking_90 smallmoney = 0,
	
	@v2mpositiontaking_1 smallmoney,
	@v2mpositiontaking_2 smallmoney,
	@v2mpositiontaking_3 smallmoney,
	@v2mpositiontaking_7 smallmoney,
	@v2mpositiontaking_8 smallmoney,
--	@v2mpositiontaking_9 smallmoney,
	@v2mpositiontaking_20 smallmoney,

	@v3mpositiontaking_1 smallmoney,
	@v3mpositiontaking_2 smallmoney,
	@v3mpositiontaking_3 smallmoney,
	@v3mpositiontaking_20 smallmoney,

	@v5mpositiontaking_1 smallmoney,
	@v5mpositiontaking_2 smallmoney,
	@v5mpositiontaking_3 smallmoney,
	@v5mpositiontaking_20 smallmoney,
	@v5mpositiontaking_9999 smallmoney = 0,

	@v8mpositiontaking_1 smallmoney,
	@v8mpositiontaking_3 smallmoney,
	@v8mpositiontaking_20 smallmoney,

	@v10mpositiontaking_1 smallmoney,
	@v10mpositiontaking_2 smallmoney,
	@v10mpositiontaking_3 smallmoney,
	@v10mpositiontaking_20 smallmoney,

	@v11mpositiontaking_1 smallmoney,
	@v11mpositiontaking_20 smallmoney,

	@v99mpositiontaking_1 smallmoney,
	@v99mpositiontaking_2 smallmoney,
	@v99mpositiontaking_3 smallmoney,
	@v99mpositiontaking_20 smallmoney,

	-- mixed sports
	@v99mpositiontaking_9 smallmoney,
	@v154mpositiontaking_20 smallmoney = 0,
	
	-- number game
	@v161mpositiontaking_81 smallmoney,
	@v161mpositiontaking_83 smallmoney,
	--@v161mpositiontaking_85 smallmoney,
	@v161mpositiontaking_86 smallmoney,
	@v161mpositiontaking_88 smallmoney,
	
	@v161mlivepositiontaking_85 smallmoney,
	@v161mlivepositiontaking_86 smallmoney,
	@v161mlivepositiontaking_87 smallmoney,
	@v161mlivepositiontaking_89 smallmoney,
	@v161mlivepositiontaking_90 smallmoney,
	
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

	-- mixed sports
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
	
	--number game
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
	
	@updateallmembers bit = 0,
	@newmpositiontaking smallmoney = 0,--equals max(m+a) - chosen(a)

	@UpdateMultiple bit = 0,
	
	@UpdatePositiontaking bit = 1,
	@UpdatePositiontakingv2 bit = 1,
	@UpdatePositiontakingv3 bit = 1,
	@UpdatePositiontakingv5 bit = 1,
	@UpdatePositiontakingv8 bit = 1,
	@UpdatePositiontakingv10 bit = 1,
	@UpdatePositiontakingv11 bit = 1,
	@UpdatePositiontakingv99 bit = 1,
	@UpdatePositiontakingv99MP bit = 1,
	@UpdatePositiontakingv154 bit = 1,
	@UpdatePositiontakingv161 bit = 1,
	
	-- Outright PT for sports
	@v2apositiontaking_10 smallmoney = 0,
	@v3apositiontaking_10 smallmoney = 0,
	@v5apositiontaking_10 smallmoney = 0,
	@v8apositiontaking_10 smallmoney = 0,
	@v10apositiontaking_10 smallmoney = 0,
	@v11apositiontaking_10 smallmoney = 0,
	@v99apositiontaking_10 smallmoney = 0,
	
	@v2mpositiontaking_10 smallmoney = 0,
	@v3mpositiontaking_10 smallmoney = 0,
	@v5mpositiontaking_10 smallmoney = 0,
	@v8mpositiontaking_10 smallmoney = 0,
	@v10mpositiontaking_10 smallmoney = 0,
	@v11mpositiontaking_10 smallmoney = 0,
	@v99mpositiontaking_10 smallmoney = 0,
	
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

					
	@SubAccID int = 0, --Sub-AccountID	
	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
--@Source Control
/*
Created: 20080515@Thien
Task : Update Agent's Position Taking
DB: DBTXN/bodb02
Original: Acc_CustomerUpdEditCustomer_MAg

Revisions:
    - 20081003@Phuc: Auto Master PT 
		check n3<=m2+a2<=l3 if i2 = 0
			else a2<=l3 and u2+a2>=n3 if i2 = 1			
    - 20090314@HanhVu: add Korean language
    - 20090424@Phuc:Separate finance sporttype(201).
					Write log subaccname instead of subaccid.
	- 20090917@Phuc: write log into DBLOG.
	- 20100112@Kiwi: amend to write log in xml format.
	- 20100910@Lukas:	- Add Number game setting
						- Add Mixed sports setting
						- Remove Mix parlay of basketball 
	- 20101019@Henry: Record execution time
	- 20110513@Amy: Remove OUTPUT from @UpdatePositiontaking, @UpdatePositiontakingv2...
	- 20110606@Amy: Write log Old values
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20120829@Johnson: Check m2+a2 with m4
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131030@Johnson: Checking total downlines before UPDATEs
					and apply execrep for recalculating pt on members 
	- 20131108@Elodie: Splitting bodb02 into CustDB (call sport, bettype by link database)					
	- 20140627@Johnson: Add bettype Others for soccer & tennis [Redmine: #16903]
	- 20150508@Johnson: fix bug update multiple affect to HR Fixed Odds [Redmine: #35151]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, Use temp table for sports, bettype table)
	- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
	- 20160627@Helen: Provide dedicated Outright PT for each sport - [Redmine: 59438]
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

Declare @UserName varchar(20), @mrecommend int, @srecommend int
declare @ErrAcc varchar(4000), @ErrType varchar(4000)
Select @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend from custinfo with (NOLOCK) where CustID = @CustID

---- Johnson@20131030: Checking total downlines before UPDATEs 
EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
	@roleid=2,
	@isExecRep=1,
	@isUpdatePT = 1,
	@Sporttype = 1,
	@Language='E',
	@ErrMsg=@ErrMsg output,
	@ErrCode=@ErrCode output
IF	@ErrCode <> 0 
	RETURN 
----------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Check Param
if @UpdateMultiple = 0 or @UpdatePositiontaking = 1
BEGIN
	if 
		@apositiontaking_1  <0
		or @apositiontaking_2  <0
		or @apositiontaking_3  <0
		or @apositiontaking_4  <0
		or @apositiontaking_5  <0
		or @apositiontaking_6  <0
		or @apositiontaking_7  <0
		or @apositiontaking_8  <0
		or @apositiontaking_9  <0
		or @apositiontaking_9999  <0
		or @alivepositiontaking_1  <0
		or @alivepositiontaking_3  <0
		or @alivepositiontaking_7  <0
		or @alivepositiontaking_8  <0
		or @apositiontaking_10 <0
		or @apositiontaking_1+@mpositiontaking_1 >0.9
		or @apositiontaking_2+@mpositiontaking_2 >0.9
		or @apositiontaking_3+@mpositiontaking_3 >0.9
		or @apositiontaking_4+@mpositiontaking_4 >0.9
		or @apositiontaking_5+@mpositiontaking_5 >0.9
		or @apositiontaking_6+@mpositiontaking_6 >0.9
		or @apositiontaking_7+@mpositiontaking_7 >0.9
		or @apositiontaking_8+@mpositiontaking_8 >0.9
		or @apositiontaking_9+@mpositiontaking_9 >0.9
		or @apositiontaking_10+@mpositiontaking_10 >0.9
		or @apositiontaking_9999+@mpositiontaking_9999 >0.9
		or @alivepositiontaking_1+@mlivepositiontaking_1 >0.9
		or @alivepositiontaking_3+@mlivepositiontaking_3 >0.9
		or @alivepositiontaking_7+@mlivepositiontaking_7 >0.9
		or @alivepositiontaking_8+@mlivepositiontaking_8 >0.9
		or @mpositiontaking_1  <0
		or @mpositiontaking_2  <0
		or @mpositiontaking_3  <0
		or @mpositiontaking_4  <0
		or @mpositiontaking_5  <0
		or @mpositiontaking_6  <0
		or @mpositiontaking_7  <0
		or @mpositiontaking_8  <0
		or @mpositiontaking_9  <0
		or @mpositiontaking_9999  <0
		or @mlivepositiontaking_1  <0
		or @mlivepositiontaking_3  <0
		or @mlivepositiontaking_7  <0
		or @mlivepositiontaking_8  <0
		or @mpositiontaking_10 <0
		or @mpositiontaking_1  >0.9
		or @mpositiontaking_2  >0.9
		or @mpositiontaking_3  >0.9
		or @mpositiontaking_4  >0.9
		or @mpositiontaking_5  >0.9
		or @mpositiontaking_6  >0.9
		or @mpositiontaking_7  >0.9
		or @mpositiontaking_8  >0.9
		or @mpositiontaking_9  >0.9
		or @mpositiontaking_9999  >0.9
		or @mlivepositiontaking_1  >0.9
		or @mlivepositiontaking_3  >0.9
		or @mlivepositiontaking_7  >0.9
		or @mlivepositiontaking_8  >0.9
		or @mpositiontaking_10 >0.9
		-- Outright PT

		
	BEGIN
		select @ErrCode = 5
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Soccer).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](1,@Language) + ')'
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from 
		custoverride as co with (NOLOCK) 
		inner join
		(
						select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @isauto_mpositiontaking_1 as isauto_mpositiontaking,  @isauto_mlivepositiontaking_1 as isauto_mlivepositiontaking, @auto_mpositiontaking_1 as auto_mpositiontaking,  @auto_mlivepositiontaking_1 as auto_mlivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @isauto_mpositiontaking_3 as isauto_mpositiontaking,  @isauto_mlivepositiontaking_3 as isauto_mlivepositiontaking, @auto_mpositiontaking_3 as auto_mpositiontaking,  @auto_mlivepositiontaking_3 as auto_mlivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @isauto_mpositiontaking_7 as isauto_mpositiontaking,  @isauto_mlivepositiontaking_7 as isauto_mlivepositiontaking, @auto_mpositiontaking_7 as auto_mpositiontaking,  @auto_mlivepositiontaking_7 as auto_mlivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @isauto_mpositiontaking_8 as isauto_mpositiontaking,  @isauto_mlivepositiontaking_8 as isauto_mlivepositiontaking, @auto_mpositiontaking_8 as auto_mpositiontaking,  @auto_mlivepositiontaking_8 as auto_mlivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_2 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_2 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_4 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_4 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_5 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_5 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_6 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_6 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_9 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_9 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_10 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			
			
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @isauto_mpositiontaking_9999 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_mpositiontaking_9999 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking)) or 
						((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.isauto_mlivepositiontaking=0) and (b.mlivepositiontaking+b.alivepositiontaking>co.maxlivepositiontaking or b.mlivepositiontaking+b.alivepositiontaking<co.minlivepositiontaking)) or
						((b.sporttype = 1 and b.bettype in (1,3,7,8) and b.isauto_mlivepositiontaking>0) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking + b.auto_mlivepositiontaking<co.minlivepositiontaking))
					)

	if @ErrType <>''
	BEGIN
		select @ErrCode = 6
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	--check n2<=a2<=l2 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '--MinLive: '+ cast((co.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from 
		custoverride as co with (NOLOCK) 
		inner join
		(
						select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking) or 
						(b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 7
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((scs.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from customer as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
						select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mpositiontaking_1 as mpositiontaking, @mlivepositiontaking_1 as mlivepositiontaking
			union all 	select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mpositiontaking_3 as mpositiontaking, @mlivepositiontaking_3 as mlivepositiontaking
			union all 	select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mpositiontaking_7 as mpositiontaking, @mlivepositiontaking_7 as mlivepositiontaking
			union all 	select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mpositiontaking_8 as mpositiontaking, @mlivepositiontaking_8 as mlivepositiontaking
			union all 	select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_4 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_5 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_6 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
			) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and 
		(b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))

	if @ErrType <>''
	BEGIN
		select @ErrCode = 11
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--Basketball
if @UpdateMultiple = 0 or @UpdatePositiontakingv2 = 1
BEGIN
	if 
		@v2apositiontaking_1  <0
		or @v2apositiontaking_2  <0
		or @v2apositiontaking_3  <0
--		or @v2apositiontaking_7  <0
--		or @v2apositiontaking_8  <0
--		or @v2apositiontaking_9  <0
		or @v2apositiontaking_20  <0
		
		or @v2apositiontaking_10  <0
		or @v2apositiontaking_10+@v2mpositiontaking_10 >0.9
		
		or @v2apositiontaking_1+@v2mpositiontaking_1 >0.9
		or @v2apositiontaking_2+@v2mpositiontaking_2 >0.9
		or @v2apositiontaking_3+@v2mpositiontaking_3 >0.9
--		or @v2apositiontaking_7+@v2mpositiontaking_7 >0.9
--		or @v2apositiontaking_8+@v2mpositiontaking_8 >0.9
--		or @v2apositiontaking_9+@v2mpositiontaking_9 >0.9
		or @v2apositiontaking_20+@v2mpositiontaking_20 >0.9
		
		or @v2mpositiontaking_10 <0
		or @v2mpositiontaking_1 <0
		or @v2mpositiontaking_2 <0
		or @v2mpositiontaking_3 <0
--		or @v2mpositiontaking_7 <0
--		or @v2mpositiontaking_8 <0
--		or @v2mpositiontaking_9 <0
		or @v2mpositiontaking_20 <0
		
		or @v2mpositiontaking_10 >0.9
		or @v2mpositiontaking_1 >0.9
		or @v2mpositiontaking_2 >0.9
		or @v2mpositiontaking_3 >0.9
--		or @v2mpositiontaking_7 >0.9
--		or @v2mpositiontaking_8 >0.9
--		or @v2mpositiontaking_9 >0.9
		or @v2mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Basketball).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](2,@Language) + ')'
					end
		return
	END
	
	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v2mpositiontaking_1 as auto_mpositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2mpositiontaking_2 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v2mpositiontaking_2 as auto_mpositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2mpositiontaking_3 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v2mpositiontaking_3 as auto_mpositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v2mpositiontaking_10 as auto_mpositiontaking
--			union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2mpositiontaking_9 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v2mpositiontaking_9 as auto_mpositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v2mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v2mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))	
					)
	
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 	select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
--			union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking

		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END


	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from customer as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 		select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
--			union all 	select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v2mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
	
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--Football
if @UpdateMultiple = 0 or @UpdatePositiontakingv3 = 1
BEGIN
	if 
		@v3apositiontaking_1  <0
		or @v3apositiontaking_2  <0
		or @v3apositiontaking_3  <0
		or @v3apositiontaking_20  <0
		or @v3apositiontaking_10  <0
		
		or @v3apositiontaking_10+@v3mpositiontaking_10 >0.9
		
		or @v3apositiontaking_1+@v3mpositiontaking_1 >0.9
		or @v3apositiontaking_2+@v3mpositiontaking_2 >0.9
		or @v3apositiontaking_3+@v3mpositiontaking_3 >0.9
		or @v3apositiontaking_20+@v3mpositiontaking_20 >0.9
		
		or @v3mpositiontaking_10 <0
		or @v3mpositiontaking_1 <0
		or @v3mpositiontaking_2 <0
		or @v3mpositiontaking_3 <0
		or @v3mpositiontaking_20 <0
		
		or @v3mpositiontaking_10 >0.9
		or @v3mpositiontaking_1 >0.9
		or @v3mpositiontaking_2 >0.9
		or @v3mpositiontaking_3 >0.9
		or @v3mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Football).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](3,@Language) + ')'
					end
		return
	END
	
	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v3mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v3mpositiontaking_1 as auto_mpositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v3mpositiontaking_2 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v3mpositiontaking_2 as auto_mpositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v3mpositiontaking_3 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v3mpositiontaking_3 as auto_mpositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v3mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v3mpositiontaking_10 as auto_mpositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v3mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v3mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))	
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
--						or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from customer as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v3mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--Tennis
if @UpdateMultiple = 0 or @UpdatePositiontakingv5 = 1
BEGIN
	if 
		@v5apositiontaking_1  <0
		or @v5apositiontaking_2  <0
		or @v5apositiontaking_3  <0
		or @v5apositiontaking_20  <0
		or @v5apositiontaking_9999  <0
		
		or @v5apositiontaking_10  <0
		or @v5apositiontaking_10+@v5mpositiontaking_10 >0.9
		
		or @v5apositiontaking_1+@v5mpositiontaking_1 >0.9
		or @v5apositiontaking_2+@v5mpositiontaking_2 >0.9
		or @v5apositiontaking_3+@v5mpositiontaking_3 >0.9
		or @v5apositiontaking_20+@v5mpositiontaking_20 >0.9
		or @v5apositiontaking_9999+@v5mpositiontaking_9999 >0.9
		
		or @v5mpositiontaking_10 <0
		
		or @v5mpositiontaking_1 <0
		or @v5mpositiontaking_2 <0
		or @v5mpositiontaking_3 <0
		or @v5mpositiontaking_20 <0
		or @v5mpositiontaking_9999 <0
		
		or @v5mpositiontaking_10 >0.9
		
		or @v5mpositiontaking_1 >0.9
		or @v5mpositiontaking_2 >0.9
		or @v5mpositiontaking_3 >0.9
		or @v5mpositiontaking_20 >0.9
		or @v5mpositiontaking_9999 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Tennis).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](5,@Language) + ')'
					end
		return
	END
	
	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v5mpositiontaking_1 as auto_mpositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5mpositiontaking_2 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v5mpositiontaking_2 as auto_mpositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5mpositiontaking_3 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v5mpositiontaking_3 as auto_mpositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v5mpositiontaking_10 as auto_mpositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v5mpositiontaking_20 as auto_mpositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v5mpositiontaking_9999 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v5mpositiontaking_9999 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END


	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, 0 as alivepositiontaking, @v5mpositiontaking_9999 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--BaseBall
if @UpdateMultiple = 0 or @UpdatePositiontakingv8 = 1
BEGIN
	if 
		@v8apositiontaking_1  <0
		or @v8apositiontaking_3  <0
		or @v8apositiontaking_20  <0
		or @v8apositiontaking_10  <0
		
		or @v8apositiontaking_10+@v8mpositiontaking_10 >0.9
		or @v8apositiontaking_1+@v8mpositiontaking_1 >0.9
		or @v8apositiontaking_3+@v8mpositiontaking_3 >0.9
		or @v8apositiontaking_20+@v8mpositiontaking_20 >0.9
		
		or @v8mpositiontaking_10 <0
		or @v8mpositiontaking_1 <0
		or @v8mpositiontaking_3 <0
		or @v8mpositiontaking_20 <0
		
		or @v8mpositiontaking_10 >0.9
		
		or @v8mpositiontaking_1 >0.9
		or @v8mpositiontaking_3 >0.9
		or @v8mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Baseball).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](8,@Language) + ')'
					end
		return
	END


	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v8mpositiontaking_1 as auto_mpositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8mpositiontaking_3 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v8mpositiontaking_3 as auto_mpositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v8mpositiontaking_10 as auto_mpositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v8mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v8mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
--						or (b.sporttype = 1 and b.bettype in (1,3,7,8) and (b.alivepositiontaking>co.maxlivepositiontaking or b.alivepositiontaking<co.minlivepositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END


	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from customer as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v8mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--Golf
if @UpdateMultiple = 0 or @UpdatePositiontakingv10 = 1
BEGIN
	if 
		@v10apositiontaking_1  <0
		or @v10apositiontaking_2  <0
		or @v10apositiontaking_3  <0
		or @v10apositiontaking_20  <0
		or @v10apositiontaking_10  <0
		
		or @v10apositiontaking_10+@v10mpositiontaking_10 >0.9
		
		or @v10apositiontaking_1+@v10mpositiontaking_1 >0.9
		or @v10apositiontaking_2+@v10mpositiontaking_2 >0.9
		or @v10apositiontaking_3+@v10mpositiontaking_3 >0.9
		or @v10apositiontaking_20+@v10mpositiontaking_20 >0.9
		
		or @v10mpositiontaking_10 <0
		
		or @v10mpositiontaking_1 <0
		or @v10mpositiontaking_2 <0
		or @v10mpositiontaking_3 <0
		or @v10mpositiontaking_20 <0
		
		or @v10mpositiontaking_10 >0.9
		or @v10mpositiontaking_1 >0.9
		or @v10mpositiontaking_2 >0.9
		or @v10mpositiontaking_3 >0.9
		or @v10mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Golf).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](10,@Language) + ')'
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v10mpositiontaking_1 as auto_mpositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10mpositiontaking_2 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v10mpositiontaking_2 as auto_mpositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10mpositiontaking_3 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v10mpositiontaking_3 as auto_mpositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v10mpositiontaking_10 as auto_mpositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v10mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v10mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v10mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--Motorsports
if @UpdateMultiple = 0 or @UpdatePositiontakingv11 = 1
BEGIN
	if 
		@v11apositiontaking_1  <0
		or @v11apositiontaking_20  <0
		or @v11apositiontaking_10  <0
		
		or @v11apositiontaking_10+@v11mpositiontaking_10 >0.9
		
		or @v11apositiontaking_1+@v11mpositiontaking_1 >0.9
		or @v11apositiontaking_20+@v11mpositiontaking_20 >0.9
		
		or @v11mpositiontaking_10 <0
		
		or @v11mpositiontaking_1 <0
		or @v11mpositiontaking_20 <0
		
		or @v11mpositiontaking_10 >0.9
		
		or @v11mpositiontaking_1 >0.9
		or @v11mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Motorsports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](11,@Language) + ')'
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v11mpositiontaking_1 as auto_mpositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v11mpositiontaking_10 as auto_mpositiontaking	 		
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v11mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v11mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
						select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking						
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking	 	
			union all 	select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v11mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--Other Sports
if @UpdateMultiple = 0 or @UpdatePositiontakingv99 = 1
BEGIN
	if 
		@v99apositiontaking_1  <0
		or @v99apositiontaking_2  <0
		or @v99apositiontaking_3  <0
		or @v99apositiontaking_20  <0
		
		or @v99apositiontaking_10  <0
		
		or @v99apositiontaking_10+@v99mpositiontaking_10 >0.9
		
		or @v99apositiontaking_1+@v99mpositiontaking_1 >0.9
		or @v99apositiontaking_2+@v99mpositiontaking_2 >0.9
		or @v99apositiontaking_3+@v99mpositiontaking_3 >0.9
		or @v99apositiontaking_20+@v99mpositiontaking_20 >0.9
		
		or @v99mpositiontaking_10 <0
		
		or @v99mpositiontaking_1 <0
		or @v99mpositiontaking_2 <0
		or @v99mpositiontaking_3 <0
		or @v99mpositiontaking_20 <0
		
		or @v99mpositiontaking_10 >0.9
		
		or @v99mpositiontaking_1 >0.9
		or @v99mpositiontaking_2 >0.9
		or @v99mpositiontaking_3 >0.9
		or @v99mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Other sports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](99,@Language) + ')'
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_1 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_1 as auto_mpositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_2 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_2 as auto_mpositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_3 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_3 as auto_mpositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_10 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_10 as auto_mpositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_1 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_2 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_3 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_10 as mpositiontaking, 0 as mlivepositiontaking
			union all 	select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking or (b.sporttype = 1 and b.bettype in (1,3,7,8) and b.alivepositiontaking>scs.alivepositiontaking))
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END


-- Mixed sports
if @UpdateMultiple = 0 or @UpdatePositiontakingv99MP = 1
BEGIN
	if 
		   @v99apositiontaking_9 < 0
		or @v99apositiontaking_9 + @v99mpositiontaking_9 > 0.9		
		or @v99mpositiontaking_9 < 0		
		or @v99mpositiontaking_9 > 0.9		
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Mix Sports Parlay).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + case @Language 
																							when 'CS' then N'(供混合体育过关)'
																							when 'CT' then N'(供混合體育過關)'
																							when 'TH' then N'(สำหรับกีฬาบอลชุด)'
																							when 'J' then N'(Mix Sports Parlay)'
																							when 'KO' then N'(Mix Sports Parlay)'
																							when 'VI' then N'(Mix Sports Parlay)'
																							else N'(Mix Sports Parlay)' END
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
	 		select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_9 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_9 as auto_mpositiontaking
			
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	
	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
			select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_9 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_9 as auto_mpositiontaking
			
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
			select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, 0 as alivepositiontaking, @v99mpositiontaking_9 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v99mpositiontaking_9 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v99mpositiontaking_9 as auto_mpositiontaking
			
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and (b.apositiontaking>scs.apositiontaking)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--HR Fixed Odds
if @UpdateMultiple = 0 or @UpdatePositiontakingv154 = 1
BEGIN
	if 
		@v154apositiontaking_20  <0
		or @v154apositiontaking_20+@v154mpositiontaking_20 >0.9
		or @v154mpositiontaking_20 <0		
		or @v154mpositiontaking_20 >0.9
	BEGIN
		select @ErrCode = 8
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Motorsports).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](154,@Language) + ')'
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0, 
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
				 		select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v154mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v154mpositiontaking_20 as isauto_mpositiontaking,  0 as isauto_mlivepositiontaking, @auto_v154mpositiontaking_20 as auto_mpositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co.minpositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 9
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--n2<=a2<=l2
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co.maxpositiontaking) as varchar(10))+ '<br>'
	from custoverride as co with (NOLOCK) inner join
		(
						select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v154mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on co.sporttype=b.sporttype and co.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @custid and (	
						(b.apositiontaking>co.maxpositiontaking or b.apositiontaking<co.minpositiontaking)
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 10
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 - Vinh
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((scs.apositiontaking) as varchar(10)) + '<br>'
	from custinfo as c with (NOLOCK) inner join custsetting as scs with (NOLOCK) on c.srecommend = scs.custid inner join 
		(
				 	select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking, 0 as alivepositiontaking, @v154mpositiontaking_20 as mpositiontaking, 0 as mlivepositiontaking
		) as b on scs.sporttype=b.sporttype and scs.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and b.apositiontaking>scs.apositiontaking
	if @ErrType <>''
	BEGIN
		select @ErrCode = 12
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END

--- Number game
if @UpdateMultiple = 0 or @UpdatePositiontakingv161 = 1
BEGIN
	if 
		   @v161apositiontaking_81  <0
		or @v161apositiontaking_83  <0
		--or @v161apositiontaking_85  <0
		or @v161apositiontaking_86  <0
		or @v161apositiontaking_88  <0
		
		or @v161alivepositiontaking_85  <0
		or @v161alivepositiontaking_86  <0
		or @v161alivepositiontaking_87  <0
		or @v161alivepositiontaking_89  <0
		or @v161alivepositiontaking_90  <0
		
		or @v161apositiontaking_81+@v161mpositiontaking_81 >0.9
		or @v161apositiontaking_83+@v161mpositiontaking_83 >0.9
		--or @v161apositiontaking_85+@v161mpositiontaking_85 >0.9
		or @v161apositiontaking_86+@v161mpositiontaking_86 >0.9
		or @v161apositiontaking_88+@v161mpositiontaking_88 >0.9
		
		or @v161alivepositiontaking_85 + @v161mlivepositiontaking_85 > 0.9
		or @v161alivepositiontaking_86 + @v161mlivepositiontaking_86 > 0.9
		or @v161alivepositiontaking_87 + @v161mlivepositiontaking_87 > 0.9
		or @v161alivepositiontaking_89 + @v161mlivepositiontaking_89 > 0.9
		or @v161alivepositiontaking_90 + @v161mlivepositiontaking_90 > 0.9
		
		or @v161mpositiontaking_81 < 0
		or @v161mpositiontaking_83 < 0
		--or @v161mpositiontaking_85 < 0
		or @v161mpositiontaking_86 < 0
		or @v161mpositiontaking_88 < 0
		
		or @v161mlivepositiontaking_85 < 0
		or @v161mlivepositiontaking_86 < 0
		or @v161mlivepositiontaking_87 < 0
		or @v161mlivepositiontaking_89 < 0
		or @v161mlivepositiontaking_90 < 0
		
		or @v161mpositiontaking_81  > 0.9
		or @v161mpositiontaking_83  > 0.9
		--or @v161mpositiontaking_85  > 0.9
		or @v161mpositiontaking_86  > 0.9
		or @v161mpositiontaking_88  > 0.9
		
		or @v161mlivepositiontaking_85  > 0.9
		or @v161mlivepositiontaking_86  > 0.9
		or @v161mlivepositiontaking_87  > 0.9
		or @v161mlivepositiontaking_89  > 0.9
		or @v161mlivepositiontaking_90  > 0.9

	BEGIN
		select @ErrCode = 5
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (for Number Game).'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](161,@Language) + ')'
					end
		return
	END

	--check n3<=m2+a2<=l3 if i2 = 0,
	--a2<=l3 and u2+a2>=n3 if i2 = 1
	
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co3.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co3.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co3.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co3.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from 
		custoverride3rd as co3 with (NOLOCK) 
		inner join
		(
						select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161mpositiontaking_81 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v161mpositiontaking_81 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161mpositiontaking_83 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v161mpositiontaking_83 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, 0 as isauto_mpositiontaking,  @isauto_v161mlivepositiontaking_85 as isauto_mlivepositiontaking, 0 as auto_mpositiontaking,  @auto_v161mlivepositiontaking_85 as auto_mlivepositiontaking
			union all	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @isauto_v161mpositiontaking_86 as isauto_mpositiontaking,  @isauto_v161mlivepositiontaking_86 as isauto_mlivepositiontaking, @auto_v161mpositiontaking_86 as auto_mpositiontaking,  @auto_v161mlivepositiontaking_86 as auto_mlivepositiontaking
			union all	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, 0 as isauto_mpositiontaking,  @isauto_v161mlivepositiontaking_87 as isauto_mlivepositiontaking, 0 as auto_mpositiontaking,  @auto_v161mlivepositiontaking_87 as auto_mlivepositiontaking	
			union all	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking, @isauto_v161mpositiontaking_88 as isauto_mpositiontaking, 0 as isauto_mlivepositiontaking, @auto_v161mpositiontaking_88 as auto_mpositiontaking,  0 as auto_mlivepositiontaking
			union all	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, 0 as isauto_mpositiontaking,  @isauto_v161mlivepositiontaking_89 as isauto_mlivepositiontaking, 0 as auto_mpositiontaking,  @auto_v161mlivepositiontaking_89 as auto_mlivepositiontaking
			union all	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, 0 as isauto_mpositiontaking,  @isauto_v161mlivepositiontaking_90 as isauto_mlivepositiontaking, 0 as auto_mpositiontaking,  @auto_v161mlivepositiontaking_90 as auto_mlivepositiontaking
		) as b on co3.sporttype=b.sporttype and co3.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co3.custid = @mrecommend and (	
						((b.isauto_mpositiontaking=0) and (b.mpositiontaking+b.apositiontaking>co3.maxpositiontaking or b.mpositiontaking+b.apositiontaking<co3.minpositiontaking)) or 
						(b.isauto_mpositiontaking>0 and (b.apositiontaking>co3.maxpositiontaking or b.apositiontaking + b.auto_mpositiontaking<co3.minpositiontaking)) or 
						((b.sporttype = 161 and b.bettype in (85,86,87,89,89) and b.isauto_mlivepositiontaking = 0) and (b.mlivepositiontaking+b.alivepositiontaking>co3.maxlivepositiontaking or b.mlivepositiontaking+b.alivepositiontaking < co3.minlivepositiontaking)) or
						((b.sporttype = 161 and b.bettype in (85,86,87,89,90) and b.isauto_mlivepositiontaking > 0) and (b.alivepositiontaking>co3.maxlivepositiontaking or b.alivepositiontaking + b.auto_mlivepositiontaking < co3.minlivepositiontaking))
					)

	if @ErrType <>''
	BEGIN
		select @ErrCode = 6
		Select @ErrMsg = 	case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END
	--check n2<=a2<=l2 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Min: '+ cast((co3.minpositiontaking) as varchar(10))+ '-Max: '+ cast((co3.maxpositiontaking) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '--MinLive: '+ cast((co3.minlivepositiontaking) as varchar(10))+ '-MaxLive: '+ cast((co3.maxlivepositiontaking) as varchar(10)) else '' end + '<br>'
	from 
		custoverride3rd as co3 with (NOLOCK) 
		inner join
		(
						select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking
			union all	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking
			union all	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking
			union all	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking
			union all	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking
			union all	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking
			union all	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking
			union all	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking
			
		) as b on co3.sporttype=b.sporttype and co3.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co3.custid = @custid and (	
						(b.apositiontaking>co3.maxpositiontaking or b.apositiontaking<co3.minpositiontaking) or 
						(b.sporttype = 161 and b.bettype in (85,86,87,89,90) and (b.alivepositiontaking>co3.maxlivepositiontaking or b.alivepositiontaking<co3.minlivepositiontaking))
					)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 7
		Select @ErrMsg = @UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (min/max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20002,@Language) + '<br>' + @ErrType
					end
		return
	END

	--check a2<=a4 
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((cs3.apositiontaking) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((cs3.alivepositiontaking) as varchar(10)) else '' end + '<br>'
	from customer as c with (NOLOCK) inner join custsetting3rd as cs3 with (NOLOCK) on c.srecommend = cs3.custid inner join 
		(
					 	select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_81 as mpositiontaking, 0 as mlivepositiontaking
			union all	select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_83 as mpositiontaking, 0 as mlivepositiontaking
			union all	select 85 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_85 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking
			union all	select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161alivepositiontaking_86 as alivepositiontaking, @v161mpositiontaking_86 as mpositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking
			union all	select 87 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_87 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking
			union all	select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, 0 as alivepositiontaking, @v161mpositiontaking_88 as mpositiontaking, 0 as mlivepositiontaking
			union all	select 89 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_89 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking
			union all	select 90 as bettype, 161 as sporttype, 0 as apositiontaking, @v161alivepositiontaking_90 as alivepositiontaking, 0 as mpositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking
			
			) as b on cs3.sporttype=b.sporttype and cs3.bettype = b.bettype
		INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
		INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where c.custid = @mrecommend and 
		(b.apositiontaking>cs3.apositiontaking or (b.sporttype = 161 and b.bettype in (85,86,87,89,90) and b.alivepositiontaking>cs3.alivepositiontaking))

	if @ErrType <>''
	BEGIN
		select @ErrCode = 11
		Select @ErrMsg = 	@UserName + ': '+
					case @Language 
							when 'E' then 'Wrong position taking (max set by company).<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20005,@Language) + '<br>' + @ErrType
					end
		return
	END
END
--End check param
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare 
	@old_apositiontaking_1 smallmoney,
	@old_apositiontaking_2 smallmoney,
	@old_apositiontaking_3 smallmoney,
	@old_apositiontaking_4 smallmoney,
	@old_apositiontaking_5 smallmoney,
	@old_apositiontaking_6 smallmoney,
	@old_apositiontaking_7 smallmoney,
	@old_apositiontaking_8 smallmoney,
	@old_apositiontaking_9 smallmoney,
	@old_apositiontaking_10 smallmoney,
	@old_apositiontaking_9999 smallmoney,
	@old_mpositiontaking_1 smallmoney,
	@old_mpositiontaking_2 smallmoney,
	@old_mpositiontaking_3 smallmoney,
	@old_mpositiontaking_4 smallmoney,
	@old_mpositiontaking_5 smallmoney,
	@old_mpositiontaking_6 smallmoney,
	@old_mpositiontaking_7 smallmoney,
	@old_mpositiontaking_8 smallmoney,
	@old_mpositiontaking_9 smallmoney,
	@old_mpositiontaking_10 smallmoney,
	@old_mpositiontaking_9999 smallmoney,
	@old_alivepositiontaking_1 smallmoney,
	@old_alivepositiontaking_3 smallmoney,
	@old_alivepositiontaking_7 smallmoney,
	@old_alivepositiontaking_8 smallmoney,
	@old_mlivepositiontaking_1 smallmoney,
	@old_mlivepositiontaking_3 smallmoney,
	@old_mlivepositiontaking_7 smallmoney,
	@old_mlivepositiontaking_8 smallmoney,
	
	@old_v2apositiontaking_1 smallmoney,
	@old_v2apositiontaking_2 smallmoney,
	@old_v2apositiontaking_3 smallmoney,
	@old_v2apositiontaking_7 smallmoney,
	@old_v2apositiontaking_8 smallmoney,
--	@old_v2apositiontaking_9 smallmoney,
	@old_v2apositiontaking_20 smallmoney,

	@old_v3apositiontaking_1 smallmoney,
	@old_v3apositiontaking_2 smallmoney,
	@old_v3apositiontaking_3 smallmoney,
	@old_v3apositiontaking_20 smallmoney,

	@old_v5apositiontaking_1 smallmoney,
	@old_v5apositiontaking_2 smallmoney,
	@old_v5apositiontaking_3 smallmoney,
	@old_v5apositiontaking_20 smallmoney,
	@old_v5apositiontaking_9999 smallmoney,

	@old_v8apositiontaking_1 smallmoney,
	@old_v8apositiontaking_3 smallmoney,
	@old_v8apositiontaking_20 smallmoney,

	@old_v10apositiontaking_1 smallmoney,
	@old_v10apositiontaking_2 smallmoney,
	@old_v10apositiontaking_3 smallmoney,
	@old_v10apositiontaking_20 smallmoney,

	@old_v11apositiontaking_1 smallmoney,
	@old_v11apositiontaking_20 smallmoney,

	@old_v99apositiontaking_1 smallmoney,
	@old_v99apositiontaking_2 smallmoney,
	@old_v99apositiontaking_3 smallmoney,
	@old_v99apositiontaking_20 smallmoney,
		
	-- mixed sports
	@old_v99apositiontaking_9 smallmoney,
	@old_v154apositiontaking_20 smallmoney,
	
	-- number game
	@old_v161apositiontaking_81 smallmoney,
	@old_v161apositiontaking_83 smallmoney,
	--@old_v161apositiontaking_85 smallmoney,
	@old_v161apositiontaking_86 smallmoney,
	@old_v161apositiontaking_88 smallmoney,
	
	@old_v161alivepositiontaking_85 smallmoney,
	@old_v161alivepositiontaking_86 smallmoney,
	@old_v161alivepositiontaking_87 smallmoney,
	@old_v161alivepositiontaking_89 smallmoney,
	@old_v161alivepositiontaking_90 smallmoney,
	
	@old_v2mpositiontaking_1 smallmoney,
	@old_v2mpositiontaking_2 smallmoney,
	@old_v2mpositiontaking_3 smallmoney,
	@old_v2mpositiontaking_7 smallmoney,
	@old_v2mpositiontaking_8 smallmoney,
--	@old_v2mpositiontaking_9 smallmoney,
	@old_v2mpositiontaking_20 smallmoney,

	@old_v3mpositiontaking_1 smallmoney,
	@old_v3mpositiontaking_2 smallmoney,
	@old_v3mpositiontaking_3 smallmoney,
	@old_v3mpositiontaking_20 smallmoney,

	@old_v5mpositiontaking_1 smallmoney,
	@old_v5mpositiontaking_2 smallmoney,
	@old_v5mpositiontaking_3 smallmoney,
	@old_v5mpositiontaking_20 smallmoney,
	@old_v5mpositiontaking_9999 smallmoney,

	@old_v8mpositiontaking_1 smallmoney,
	@old_v8mpositiontaking_3 smallmoney,
	@old_v8mpositiontaking_20 smallmoney,

	@old_v10mpositiontaking_1 smallmoney,
	@old_v10mpositiontaking_2 smallmoney,
	@old_v10mpositiontaking_3 smallmoney,
	@old_v10mpositiontaking_20 smallmoney,

	@old_v11mpositiontaking_1 smallmoney,
	@old_v11mpositiontaking_20 smallmoney,

	@old_v99mpositiontaking_1 smallmoney,
	@old_v99mpositiontaking_2 smallmoney,
	@old_v99mpositiontaking_3 smallmoney,
	@old_v99mpositiontaking_20 smallmoney,

	-- mixed sports
	@old_v99mpositiontaking_9 smallmoney,
	@old_v154mpositiontaking_20 smallmoney,
	
	-- number game
	@old_v161mpositiontaking_81 smallmoney,
	@old_v161mpositiontaking_83 smallmoney,
	--@old_v161mpositiontaking_85 smallmoney,
	@old_v161mpositiontaking_86 smallmoney,
	@old_v161mpositiontaking_88 smallmoney,
	
	@old_v161mlivepositiontaking_85 smallmoney,
	@old_v161mlivepositiontaking_86 smallmoney,
	@old_v161mlivepositiontaking_87 smallmoney,
	@old_v161mlivepositiontaking_89 smallmoney,
	@old_v161mlivepositiontaking_90 smallmoney,
	
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
	
	@old_v2apositiontaking_10 smallmoney,
	@old_v3apositiontaking_10 smallmoney,
	@old_v5apositiontaking_10 smallmoney,
	@old_v8apositiontaking_10 smallmoney,
	@old_v10apositiontaking_10 smallmoney,
	@old_v11apositiontaking_10 smallmoney,
	@old_v99apositiontaking_10 smallmoney,
	
	@old_v2mpositiontaking_10 smallmoney,
	@old_v3mpositiontaking_10 smallmoney,
	@old_v5mpositiontaking_10 smallmoney,
	@old_v8mpositiontaking_10 smallmoney,
	@old_v10mpositiontaking_10 smallmoney,
	@old_v11mpositiontaking_10 smallmoney,
	@old_v99mpositiontaking_10 smallmoney,
	
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
	
select @old_mpositiontaking_1 = mpositiontaking, @old_mlivepositiontaking_1 = mlivepositiontaking, @old_apositiontaking_1 = apositiontaking, @old_alivepositiontaking_1 = alivepositiontaking,
	@Old_auto_mpositiontaking_1 = autompositiontaking, @Old_isauto_mpositiontaking_1=isautompositiontaking,
	@Old_auto_mlivepositiontaking_1 = autolivempositiontaking, @Old_isauto_mlivepositiontaking_1=isautolivempositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=1
select @old_mpositiontaking_3 = mpositiontaking, @old_mlivepositiontaking_3 = mlivepositiontaking, @old_apositiontaking_3 = apositiontaking, @old_alivepositiontaking_3 = alivepositiontaking,
	@Old_auto_mpositiontaking_3 = autompositiontaking, @Old_isauto_mpositiontaking_3=isautompositiontaking,
	@Old_auto_mlivepositiontaking_3 = autolivempositiontaking, @Old_isauto_mlivepositiontaking_3=isautolivempositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=1
select @old_mpositiontaking_7 = mpositiontaking, @old_mlivepositiontaking_7 = mlivepositiontaking, @old_apositiontaking_7 = apositiontaking, @old_alivepositiontaking_7 = alivepositiontaking, 
	@Old_auto_mpositiontaking_7 = autompositiontaking, @Old_isauto_mpositiontaking_7=isautompositiontaking,
@Old_auto_mlivepositiontaking_7 = autolivempositiontaking, @Old_isauto_mlivepositiontaking_7=isautolivempositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=1
select @old_mpositiontaking_8 = mpositiontaking, @old_mlivepositiontaking_8 = mlivepositiontaking, @old_apositiontaking_8 = apositiontaking, @old_alivepositiontaking_8 = alivepositiontaking,
	@Old_auto_mpositiontaking_8 = autompositiontaking, @Old_isauto_mpositiontaking_8=isautompositiontaking,
@Old_auto_mlivepositiontaking_8 = autolivempositiontaking, @Old_isauto_mlivepositiontaking_8=isautolivempositiontaking
from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=1

select @old_mpositiontaking_2 = mpositiontaking, @old_apositiontaking_2 = apositiontaking, @old_auto_mpositiontaking_2 = autompositiontaking, @old_isauto_mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=1
select @old_mpositiontaking_4 = mpositiontaking, @old_apositiontaking_4 = apositiontaking, @old_auto_mpositiontaking_4 = autompositiontaking, @old_isauto_mpositiontaking_4 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=4 and sporttype=1
select @old_mpositiontaking_5 = mpositiontaking, @old_apositiontaking_5 = apositiontaking, @old_auto_mpositiontaking_5 = autompositiontaking, @old_isauto_mpositiontaking_5 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=5 and sporttype=1
select @old_mpositiontaking_6 = mpositiontaking, @old_apositiontaking_6 = apositiontaking, @old_auto_mpositiontaking_6 = autompositiontaking, @old_isauto_mpositiontaking_6 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=6 and sporttype=1
select @old_mpositiontaking_9 = mpositiontaking, @old_apositiontaking_9 = apositiontaking, @old_auto_mpositiontaking_9 = autompositiontaking, @old_isauto_mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=1
select @old_mpositiontaking_10 = mpositiontaking, @old_apositiontaking_10 = apositiontaking, @old_auto_mpositiontaking_10 = autompositiontaking, @old_isauto_mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=1

-- Outright PT for sports
select @old_v2mpositiontaking_10 = mpositiontaking, @old_v2apositiontaking_10 = apositiontaking, @old_auto_v2mpositiontaking_10 = autompositiontaking, @old_isauto_v2mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=2
select @old_v3mpositiontaking_10 = mpositiontaking, @old_v3apositiontaking_10 = apositiontaking, @old_auto_v3mpositiontaking_10 = autompositiontaking, @old_isauto_v3mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=3
select @old_v5mpositiontaking_10 = mpositiontaking, @old_v5apositiontaking_10 = apositiontaking, @old_auto_v5mpositiontaking_10 = autompositiontaking, @old_isauto_v5mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=5
select @old_v8mpositiontaking_10 = mpositiontaking, @old_v8apositiontaking_10 = apositiontaking, @old_auto_v8mpositiontaking_10 = autompositiontaking, @old_isauto_v8mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=8
select @old_v10mpositiontaking_10 = mpositiontaking, @old_v10apositiontaking_10 = apositiontaking, @old_auto_v10mpositiontaking_10 = autompositiontaking, @old_isauto_v10mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=10
select @old_v11mpositiontaking_10 = mpositiontaking, @old_v11apositiontaking_10 = apositiontaking, @old_auto_v11mpositiontaking_10 = autompositiontaking, @old_isauto_v11mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=11
select @old_v99mpositiontaking_10 = mpositiontaking, @old_v99apositiontaking_10 = apositiontaking, @old_auto_v99mpositiontaking_10 = autompositiontaking, @old_isauto_v99mpositiontaking_10 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=10 and sporttype=99

select @old_mpositiontaking_9999 = mpositiontaking, @old_apositiontaking_9999 = apositiontaking, @old_auto_mpositiontaking_9999 = autompositiontaking, @old_isauto_mpositiontaking_9999 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=1

select @old_v2mpositiontaking_1 = mpositiontaking, @old_v2apositiontaking_1 = apositiontaking, @old_auto_v2mpositiontaking_1 = autompositiontaking, @old_isauto_v2mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=2
select @old_v2mpositiontaking_2 = mpositiontaking, @old_v2apositiontaking_2 = apositiontaking, @old_auto_v2mpositiontaking_2 = autompositiontaking, @old_isauto_v2mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=2
select @old_v2mpositiontaking_3 = mpositiontaking, @old_v2apositiontaking_3 = apositiontaking, @old_auto_v2mpositiontaking_3 = autompositiontaking, @old_isauto_v2mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=2
select @old_v2mpositiontaking_7 = mpositiontaking, @old_v2apositiontaking_7 = apositiontaking, @old_auto_v2mpositiontaking_7 = autompositiontaking, @old_isauto_v2mpositiontaking_7 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=7 and sporttype=2
select @old_v2mpositiontaking_8 = mpositiontaking, @old_v2apositiontaking_8 = apositiontaking, @old_auto_v2mpositiontaking_8 = autompositiontaking, @old_isauto_v2mpositiontaking_8 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=8 and sporttype=2
select @old_v2mpositiontaking_20 = mpositiontaking, @old_v2apositiontaking_20 = apositiontaking, @old_auto_v2mpositiontaking_20 = autompositiontaking, @old_isauto_v2mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=2

select @old_v3mpositiontaking_1 = mpositiontaking, @old_v3apositiontaking_1 = apositiontaking, @old_auto_v3mpositiontaking_1 = autompositiontaking, @old_isauto_v3mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=3
select @old_v3mpositiontaking_2 = mpositiontaking, @old_v3apositiontaking_2 = apositiontaking, @old_auto_v3mpositiontaking_2 = autompositiontaking, @old_isauto_v3mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=3
select @old_v3mpositiontaking_3 = mpositiontaking, @old_v3apositiontaking_3 = apositiontaking, @old_auto_v3mpositiontaking_3 = autompositiontaking, @old_isauto_v3mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=3
select @old_v3mpositiontaking_20 = mpositiontaking, @old_v3apositiontaking_20 = apositiontaking, @old_auto_v3mpositiontaking_20 = autompositiontaking, @old_isauto_v3mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=3

select @old_v5mpositiontaking_1 = mpositiontaking, @old_v5apositiontaking_1 = apositiontaking, @old_auto_v5mpositiontaking_1 = autompositiontaking, @old_isauto_v5mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=5
select @old_v5mpositiontaking_2 = mpositiontaking, @old_v5apositiontaking_2 = apositiontaking, @old_auto_v5mpositiontaking_2 = autompositiontaking, @old_isauto_v5mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=5
select @old_v5mpositiontaking_3 = mpositiontaking, @old_v5apositiontaking_3 = apositiontaking, @old_auto_v5mpositiontaking_3 = autompositiontaking, @old_isauto_v5mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=5
select @old_v5mpositiontaking_20 = mpositiontaking, @old_v5apositiontaking_20 = apositiontaking, @old_auto_v5mpositiontaking_20 = autompositiontaking, @old_isauto_v5mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=5
select @old_v5mpositiontaking_9999 = mpositiontaking, @old_v5apositiontaking_9999 = apositiontaking, @old_auto_v5mpositiontaking_9999 = autompositiontaking, @old_isauto_v5mpositiontaking_9999 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9999 and sporttype=5

select @old_v8mpositiontaking_1 = mpositiontaking, @old_v8apositiontaking_1 = apositiontaking, @old_auto_v8mpositiontaking_1 = autompositiontaking, @old_isauto_v8mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=8
select @old_v8mpositiontaking_3 = mpositiontaking, @old_v8apositiontaking_3 = apositiontaking, @old_auto_v8mpositiontaking_3 = autompositiontaking, @old_isauto_v8mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=8
select @old_v8mpositiontaking_20 = mpositiontaking, @old_v8apositiontaking_20 = apositiontaking, @old_auto_v8mpositiontaking_20 = autompositiontaking, @old_isauto_v8mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=8

select @old_v10mpositiontaking_1 = mpositiontaking, @old_v10apositiontaking_1 = apositiontaking, @old_auto_v10mpositiontaking_1 = autompositiontaking, @old_isauto_v10mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=10
select @old_v10mpositiontaking_2 = mpositiontaking, @old_v10apositiontaking_2 = apositiontaking, @old_auto_v10mpositiontaking_2 = autompositiontaking, @old_isauto_v10mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=10
select @old_v10mpositiontaking_3 = mpositiontaking, @old_v10apositiontaking_3 = apositiontaking, @old_auto_v10mpositiontaking_3 = autompositiontaking, @old_isauto_v10mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=10
select @old_v10mpositiontaking_20 = mpositiontaking, @old_v10apositiontaking_20 = apositiontaking, @old_auto_v10mpositiontaking_20 = autompositiontaking, @old_isauto_v10mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=10

select @old_v11mpositiontaking_1 = mpositiontaking, @old_v11apositiontaking_1 = apositiontaking, @old_auto_v11mpositiontaking_1 = autompositiontaking, @old_isauto_v11mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=11
select @old_v11mpositiontaking_20 = mpositiontaking, @old_v11apositiontaking_20 = apositiontaking, @old_auto_v11mpositiontaking_20 = autompositiontaking, @old_isauto_v11mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=11

select @old_v99mpositiontaking_1 = mpositiontaking, @old_v99apositiontaking_1 = apositiontaking, @old_auto_v99mpositiontaking_1 = autompositiontaking, @old_isauto_v99mpositiontaking_1 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=1 and sporttype=99
select @old_v99mpositiontaking_2 = mpositiontaking, @old_v99apositiontaking_2 = apositiontaking, @old_auto_v99mpositiontaking_2 = autompositiontaking, @old_isauto_v99mpositiontaking_2 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=2 and sporttype=99
select @old_v99mpositiontaking_3 = mpositiontaking, @old_v99apositiontaking_3 = apositiontaking, @old_auto_v99mpositiontaking_3 = autompositiontaking, @old_isauto_v99mpositiontaking_3 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=3 and sporttype=99
select @old_v99mpositiontaking_20 = mpositiontaking, @old_v99apositiontaking_20 = apositiontaking, @old_auto_v99mpositiontaking_20 = autompositiontaking, @old_isauto_v99mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=99

-- mixed sports
select @old_v99mpositiontaking_9 = mpositiontaking, @old_v99apositiontaking_9 = apositiontaking, @old_auto_v99mpositiontaking_9 = autompositiontaking, @old_isauto_v99mpositiontaking_9 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=9 and sporttype=99
select @old_v154mpositiontaking_20 = mpositiontaking, @old_v154apositiontaking_20 = apositiontaking, @old_auto_v154mpositiontaking_20 = autompositiontaking, @old_isauto_v154mpositiontaking_20 = isautompositiontaking from custsetting with (NOLOCK) where custid = @custid and bettype=20 and sporttype=154

-- number game
select @old_v161mpositiontaking_81 = mpositiontaking, @old_v161apositiontaking_81 = apositiontaking, @old_auto_v161mpositiontaking_81 = autompositiontaking, @old_isauto_v161mpositiontaking_81 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=81 and sporttype=161
select @old_v161mpositiontaking_83 = mpositiontaking, @old_v161apositiontaking_83 = apositiontaking, @old_auto_v161mpositiontaking_83 = autompositiontaking, @old_isauto_v161mpositiontaking_83 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=83 and sporttype=161
select @old_v161mlivepositiontaking_85 = mlivepositiontaking, @old_v161alivepositiontaking_85 = alivepositiontaking, @old_auto_v161mlivepositiontaking_85 = autolivempositiontaking, @old_isauto_v161mlivepositiontaking_85 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=85 and sporttype=161
select @old_v161mpositiontaking_86 = mpositiontaking, @old_v161mlivepositiontaking_86 = mlivepositiontaking, @old_v161apositiontaking_86 = apositiontaking, @old_v161alivepositiontaking_86 = alivepositiontaking, @old_auto_v161mpositiontaking_86 = autompositiontaking, @old_isauto_v161mpositiontaking_86 = isautompositiontaking, @old_auto_v161mlivepositiontaking_86 = autolivempositiontaking, @old_isauto_v161mlivepositiontaking_86 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=86 and sporttype=161
select @old_v161mlivepositiontaking_87 = mlivepositiontaking, @old_v161alivepositiontaking_87 = alivepositiontaking, @old_auto_v161mlivepositiontaking_87 = autolivempositiontaking, @old_isauto_v161mlivepositiontaking_87 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=87 and sporttype=161
select @old_v161mpositiontaking_88 = mpositiontaking, @old_v161apositiontaking_88 = apositiontaking, @old_auto_v161mpositiontaking_88 = autompositiontaking, @old_isauto_v161mpositiontaking_88 = isautompositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=88 and sporttype=161
select @old_v161mlivepositiontaking_89 = mlivepositiontaking, @old_v161alivepositiontaking_89 = alivepositiontaking, @old_auto_v161mlivepositiontaking_89 = autolivempositiontaking, @old_isauto_v161mlivepositiontaking_89 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=89 and sporttype=161
select @old_v161mlivepositiontaking_90 = mlivepositiontaking, @old_v161alivepositiontaking_90 = alivepositiontaking, @old_auto_v161mlivepositiontaking_90 = autolivempositiontaking, @old_isauto_v161mlivepositiontaking_90 = isautolivempositiontaking from custsetting3rd with (NOLOCK) where custid = @custid and bettype=90 and sporttype=161


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

declare
	@max_mapositiontaking_1 smallmoney,
	@max_mapositiontaking_2 smallmoney,
	@max_mapositiontaking_3 smallmoney,
	@max_mapositiontaking_4 smallmoney,
	@max_mapositiontaking_5 smallmoney,
	@max_mapositiontaking_6 smallmoney,
	@max_mapositiontaking_7 smallmoney,
	@max_mapositiontaking_8 smallmoney,
	@max_mapositiontaking_9 smallmoney,
	@max_mapositiontaking_10 smallmoney,
	@max_mapositiontaking_9999 smallmoney,
	@max_malivepositiontaking_1 smallmoney,
	
	@max_malivepositiontaking_3 smallmoney,
	@max_malivepositiontaking_7 smallmoney,
	@max_malivepositiontaking_8 smallmoney,
	
	@max_v2mapositiontaking_1 smallmoney,
	@max_v2mapositiontaking_2 smallmoney,
	@max_v2mapositiontaking_3 smallmoney,
	@max_v2mapositiontaking_7 smallmoney,
	@max_v2mapositiontaking_8 smallmoney,
--	@max_v2mapositiontaking_9 smallmoney,
	@max_v2mapositiontaking_20 smallmoney,

	@max_v3mapositiontaking_1 smallmoney,
	@max_v3mapositiontaking_2 smallmoney,
	@max_v3mapositiontaking_3 smallmoney,
	@max_v3mapositiontaking_20 smallmoney,

	@max_v5mapositiontaking_1 smallmoney,
	@max_v5mapositiontaking_2 smallmoney,
	@max_v5mapositiontaking_3 smallmoney,
	@max_v5mapositiontaking_20 smallmoney,
	@max_v5mapositiontaking_9999 smallmoney,

	@max_v8mapositiontaking_1 smallmoney,
	@max_v8mapositiontaking_3 smallmoney,
	@max_v8mapositiontaking_20 smallmoney,

	@max_v10mapositiontaking_1 smallmoney,
	@max_v10mapositiontaking_2 smallmoney,
	@max_v10mapositiontaking_3 smallmoney,
	@max_v10mapositiontaking_20 smallmoney,

	@max_v11mapositiontaking_1 smallmoney,
	@max_v11mapositiontaking_20 smallmoney,

	@max_v99mapositiontaking_1 smallmoney,
	@max_v99mapositiontaking_2 smallmoney,
	@max_v99mapositiontaking_3 smallmoney,
	@max_v99mapositiontaking_20 smallmoney,

	-- mixed sports
	@max_v99mapositiontaking_9 smallmoney,
	@max_v154mapositiontaking_20 smallmoney,
	
	-- number game
	@max_v161mapositiontaking_81 smallmoney,
	@max_v161mapositiontaking_83 smallmoney,
	--@max_v161mapositiontaking_85 smallmoney,
	@max_v161mapositiontaking_86 smallmoney,
	@max_v161mapositiontaking_88 smallmoney,
	
	@max_v161malivepositiontaking_85 smallmoney,
	@max_v161malivepositiontaking_86 smallmoney,
	@max_v161malivepositiontaking_87 smallmoney,
	@max_v161malivepositiontaking_89 smallmoney,
	@max_v161malivepositiontaking_90 smallmoney,
	
	@max_v2mapositiontaking_10 smallmoney,
	@max_v3mapositiontaking_10 smallmoney,
	@max_v5mapositiontaking_10 smallmoney,
	@max_v8mapositiontaking_10 smallmoney,
	@max_v10mapositiontaking_10 smallmoney,
	@max_v11mapositiontaking_10 smallmoney,
	@max_v99mapositiontaking_10 smallmoney

select @max_mapositiontaking_1 =mpositiontaking, @max_malivepositiontaking_1 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=1
select @max_mapositiontaking_3 =mpositiontaking, @max_malivepositiontaking_3 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=1
select @max_mapositiontaking_7 =mpositiontaking, @max_malivepositiontaking_7 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=1
select @max_mapositiontaking_8 =mpositiontaking, @max_malivepositiontaking_8 =mlivepositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=1
select @max_mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=1
select @max_mapositiontaking_4 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=4 and sporttype=1
select @max_mapositiontaking_5 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=5 and sporttype=1
select @max_mapositiontaking_6 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=6 and sporttype=1
select @max_mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=1
select @max_mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=1

-- Outright PT for sports
select @max_v2mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=2
select @max_v3mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=3
select @max_v5mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=5
select @max_v8mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=8
select @max_v10mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=10
select @max_v11mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=11
select @max_v99mapositiontaking_10 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=10 and sporttype=99

select @max_mapositiontaking_9999 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=1

select @max_v2mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=2
select @max_v2mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=2
select @max_v2mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=2
select @max_v2mapositiontaking_7 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=7 and sporttype=2
select @max_v2mapositiontaking_8 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=8 and sporttype=2
--select @max_v2mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
select @max_v2mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=2

select @max_v3mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=3
select @max_v3mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=3
select @max_v3mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=3
select @max_v3mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=3

select @max_v5mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=5
select @max_v5mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=5
select @max_v5mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=5
select @max_v5mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=5
select @max_v5mapositiontaking_9999 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9999 and sporttype=5

select @max_v8mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=8
select @max_v8mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=8
select @max_v8mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=8

select @max_v10mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=10
select @max_v10mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=10
select @max_v10mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=10
select @max_v10mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=10

select @max_v11mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=11
select @max_v11mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=11

select @max_v99mapositiontaking_1 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=1 and sporttype=99
select @max_v99mapositiontaking_2 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=2 and sporttype=99
select @max_v99mapositiontaking_3 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=3 and sporttype=99
select @max_v99mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=99

-- mixed sports
select @max_v99mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=99
select @max_v154mapositiontaking_20 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=20 and sporttype=154

--number game
select @max_v161mapositiontaking_81 =mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=81 and sporttype=161
select @max_v161mapositiontaking_83 =mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=83 and sporttype=161
select @max_v161malivepositiontaking_85 =mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=85 and sporttype=161
select @max_v161mapositiontaking_86 =mpositiontaking, @max_v161malivepositiontaking_86 =mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=86 and sporttype=161
select @max_v161malivepositiontaking_87 =mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=87 and sporttype=161
select @max_v161mapositiontaking_88 =mpositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=88 and sporttype=161
select @max_v161malivepositiontaking_89 =mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=89 and sporttype=161
select @max_v161malivepositiontaking_90 =mlivepositiontaking from custsetting3rd with (NOLOCK) where custid = @mrecommend and bettype=90 and sporttype=161

--max(m2+a2)=min(m3,m4)
select @max_mapositiontaking_1 = case when @max_mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_mapositiontaking_1 end, @max_malivepositiontaking_1 = case when @max_malivepositiontaking_1 > mlivepositiontaking then mlivepositiontaking else @max_malivepositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=1
select @max_mapositiontaking_3 = case when @max_mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_mapositiontaking_3 end, @max_malivepositiontaking_3 = case when @max_malivepositiontaking_3 > mlivepositiontaking then mlivepositiontaking else @max_malivepositiontaking_3 end  from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=1
select @max_mapositiontaking_7 = case when @max_mapositiontaking_7 > mpositiontaking then mpositiontaking else @max_mapositiontaking_7 end, @max_malivepositiontaking_7 = case when @max_malivepositiontaking_7 > mlivepositiontaking then mlivepositiontaking else @max_malivepositiontaking_7 end  from custsetting with (NOLOCK) where custid = @srecommend and bettype=7 and sporttype=1
select @max_mapositiontaking_8 = case when @max_mapositiontaking_8 > mpositiontaking then mpositiontaking else @max_mapositiontaking_8 end, @max_malivepositiontaking_8 = case when @max_malivepositiontaking_8 > mlivepositiontaking then mlivepositiontaking else @max_malivepositiontaking_8 end  from custsetting with (NOLOCK) where custid = @srecommend and bettype=8 and sporttype=1
select @max_mapositiontaking_2 = case when @max_mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_mapositiontaking_2 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=1
select @max_mapositiontaking_4 = case when @max_mapositiontaking_4 > mpositiontaking then mpositiontaking else @max_mapositiontaking_4 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=4 and sporttype=1
select @max_mapositiontaking_5 = case when @max_mapositiontaking_5 > mpositiontaking then mpositiontaking else @max_mapositiontaking_5 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=5 and sporttype=1
select @max_mapositiontaking_6 = case when @max_mapositiontaking_6 > mpositiontaking then mpositiontaking else @max_mapositiontaking_6 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=6 and sporttype=1
select @max_mapositiontaking_9 = case when @max_mapositiontaking_9 > mpositiontaking then mpositiontaking else @max_mapositiontaking_9 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=1
select @max_mapositiontaking_10 = case when @max_mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=1
-- Outright PT for sports

select @max_v2mapositiontaking_10 = case when @max_v2mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=2
select @max_v3mapositiontaking_10 = case when @max_v3mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=3
select @max_v5mapositiontaking_10 = case when @max_v5mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=5
select @max_v8mapositiontaking_10 = case when @max_v8mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=8
select @max_v10mapositiontaking_10 = case when @max_v10mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=10
select @max_v11mapositiontaking_10 = case when @max_v11mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v11mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=11
select @max_v99mapositiontaking_10 = case when @max_v99mapositiontaking_10 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_10 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=10 and sporttype=99


select @max_mapositiontaking_9999 = case when @max_mapositiontaking_9999 > mpositiontaking then mpositiontaking else @max_mapositiontaking_9999 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=9999 and sporttype=1

select @max_v2mapositiontaking_1 = case when @max_v2mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=2
select @max_v2mapositiontaking_2 = case when @max_v2mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_2 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=2
select @max_v2mapositiontaking_3 = case when @max_v2mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_3 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=2
select @max_v2mapositiontaking_7 = case when @max_v2mapositiontaking_7 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_7 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=7 and sporttype=2
select @max_v2mapositiontaking_8 = case when @max_v2mapositiontaking_8 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_8 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=8 and sporttype=2
--select @max_v2mapositiontaking_9 =mpositiontaking from custsetting with (NOLOCK) where custid = @mrecommend and bettype=9 and sporttype=2
select @max_v2mapositiontaking_20 = case when @max_v2mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v2mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=2

select @max_v3mapositiontaking_1 = case when @max_v3mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=3
select @max_v3mapositiontaking_2 = case when @max_v3mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_2 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=3
select @max_v3mapositiontaking_3 = case when @max_v3mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_3 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=3
select @max_v3mapositiontaking_20 = case when @max_v3mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v3mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=3

select @max_v5mapositiontaking_1 = case when @max_v5mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=5
select @max_v5mapositiontaking_2 = case when @max_v5mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_2 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=5
select @max_v5mapositiontaking_3 = case when @max_v5mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_3 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=5
select @max_v5mapositiontaking_20 = case when @max_v5mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=5
select @max_v5mapositiontaking_9999 = case when @max_v5mapositiontaking_9999 > mpositiontaking then mpositiontaking else @max_v5mapositiontaking_9999 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=9999 and sporttype=5

select @max_v8mapositiontaking_1 = case when @max_v8mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=8
select @max_v8mapositiontaking_3 = case when @max_v8mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_3 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=8
select @max_v8mapositiontaking_20 = case when @max_v8mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v8mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=8

select @max_v10mapositiontaking_1 = case when @max_v10mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=10
select @max_v10mapositiontaking_2 = case when @max_v10mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_2 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=10
select @max_v10mapositiontaking_3 = case when @max_v10mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_3 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=10
select @max_v10mapositiontaking_20 = case when @max_v10mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v10mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=10

select @max_v11mapositiontaking_1 = case when @max_v11mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v11mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=11
select @max_v11mapositiontaking_20 = case when @max_v11mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v11mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=11

select @max_v99mapositiontaking_1 = case when @max_v99mapositiontaking_1 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_1 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=1 and sporttype=99
select @max_v99mapositiontaking_2 = case when @max_v99mapositiontaking_2 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_2 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=2 and sporttype=99
select @max_v99mapositiontaking_3 = case when @max_v99mapositiontaking_3 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_3 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=3 and sporttype=99
select @max_v99mapositiontaking_20 = case when @max_v99mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=99

-- mixed sports
select @max_v99mapositiontaking_9 = case when @max_v99mapositiontaking_9 > mpositiontaking then mpositiontaking else @max_v99mapositiontaking_9 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=9 and sporttype=99
select @max_v154mapositiontaking_20 = case when @max_v154mapositiontaking_20 > mpositiontaking then mpositiontaking else @max_v154mapositiontaking_20 end from custsetting with (NOLOCK) where custid = @srecommend and bettype=20 and sporttype=154

--number game
select @max_v161mapositiontaking_81 = case when @max_v161mapositiontaking_81 > mpositiontaking then mpositiontaking else @max_v161mapositiontaking_81 end from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=81 and sporttype=161
select @max_v161mapositiontaking_83 = case when @max_v161mapositiontaking_83 > mpositiontaking then mpositiontaking else @max_v161mapositiontaking_83 end from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=83 and sporttype=161
select @max_v161malivepositiontaking_85 = case when @max_v161malivepositiontaking_85 > mlivepositiontaking then mlivepositiontaking else @max_v161malivepositiontaking_85 end from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=85 and sporttype=161
select @max_v161mapositiontaking_86 = case when @max_v161mapositiontaking_86 > mpositiontaking then mpositiontaking else @max_v161mapositiontaking_86 end , @max_v161malivepositiontaking_86 = case when @max_v161malivepositiontaking_86 > mlivepositiontaking then mlivepositiontaking else @max_v161malivepositiontaking_86 end  from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=86 and sporttype=161
select @max_v161malivepositiontaking_87 = case when @max_v161malivepositiontaking_87 > mlivepositiontaking then mlivepositiontaking else @max_v161malivepositiontaking_87 end  from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=87 and sporttype=161
select @max_v161mapositiontaking_88 = case when @max_v161mapositiontaking_88 > mpositiontaking then mpositiontaking else @max_v161mapositiontaking_88 end from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=88 and sporttype=161
select @max_v161malivepositiontaking_89 = case when @max_v161malivepositiontaking_89 > mlivepositiontaking then mlivepositiontaking else @max_v161malivepositiontaking_89 end  from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=89 and sporttype=161
select @max_v161malivepositiontaking_90 = case when @max_v161malivepositiontaking_90 > mlivepositiontaking then mlivepositiontaking else @max_v161malivepositiontaking_90 end  from custsetting3rd with (NOLOCK) where custid = @srecommend and bettype=90 and sporttype=161

--check m2+a2<=min(m3,m4) - Vinh
if @UpdateMultiple = 0 
	or @UpdatePositiontaking = 1
	or @UpdatePositiontakingv2 = 1
	or @UpdatePositiontakingv3 = 1
	or @UpdatePositiontakingv5 = 1
	or @UpdatePositiontakingv8 = 1
	or @UpdatePositiontakingv10 = 1
	or @UpdatePositiontakingv11 = 1
	or @UpdatePositiontakingv99 = 1
	or @UpdatePositiontakingv99MP = 1
	or @UpdatePositiontakingv154 = 1
	or @UpdatePositiontakingv161 = 1
BEGIN
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((b.max_mapositiontaking) as varchar(10))
	+ case when b.sporttype in (1,161) and b.bettype in (1,3,7,8,85,86,87,89,90) then '-MaxLive: '+ cast((b.max_malivepositiontaking) as varchar(10)) else '' end + '<br>'
	from
	(
				  select 1 as bettype, 1 as sporttype, @apositiontaking_1 as apositiontaking, @mpositiontaking_1 as mpositiontaking, @max_mapositiontaking_1 as max_mapositiontaking, @alivepositiontaking_1 as alivepositiontaking, @mlivepositiontaking_1 as mlivepositiontaking, @max_malivepositiontaking_1 as max_malivepositiontaking
		union all select 3 as bettype, 1 as sporttype, @apositiontaking_3 as apositiontaking, @mpositiontaking_3 as mpositiontaking, @max_mapositiontaking_3 as max_mapositiontaking, @alivepositiontaking_3 as alivepositiontaking, @mlivepositiontaking_3 as mlivepositiontaking, @max_malivepositiontaking_3 as max_malivepositiontaking
		union all select 7 as bettype, 1 as sporttype, @apositiontaking_7 as apositiontaking, @mpositiontaking_7 as mpositiontaking, @max_mapositiontaking_7 as max_mapositiontaking, @alivepositiontaking_7 as alivepositiontaking, @mlivepositiontaking_7 as mlivepositiontaking, @max_malivepositiontaking_7 as max_malivepositiontaking
		union all select 8 as bettype, 1 as sporttype, @apositiontaking_8 as apositiontaking, @mpositiontaking_8 as mpositiontaking, @max_mapositiontaking_8 as max_mapositiontaking, @alivepositiontaking_8 as alivepositiontaking, @mlivepositiontaking_8 as mlivepositiontaking, @max_malivepositiontaking_8 as max_malivepositiontaking
		union all select 2 as bettype, 1 as sporttype, @apositiontaking_2 as apositiontaking, @mpositiontaking_2 as mpositiontaking, @max_mapositiontaking_2 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking		
		union all select 4 as bettype, 1 as sporttype, @apositiontaking_4 as apositiontaking, @mpositiontaking_4 as mpositiontaking, @max_mapositiontaking_4 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 5 as bettype, 1 as sporttype, @apositiontaking_5 as apositiontaking, @mpositiontaking_5 as mpositiontaking, @max_mapositiontaking_5 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 6 as bettype, 1 as sporttype, @apositiontaking_6 as apositiontaking, @mpositiontaking_6 as mpositiontaking, @max_mapositiontaking_6 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 9 as bettype, 1 as sporttype, @apositiontaking_9 as apositiontaking, @mpositiontaking_9 as mpositiontaking, @max_mapositiontaking_9 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 1 as sporttype, @apositiontaking_10 as apositiontaking, @mpositiontaking_10 as mpositiontaking, @max_mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		
		-- Outright PT for sports
		union all select 10 as bettype, 2 as sporttype, @v2apositiontaking_10 as apositiontaking, @v2mpositiontaking_10 as mpositiontaking, @max_v2mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 3 as sporttype, @v3apositiontaking_10 as apositiontaking, @v3mpositiontaking_10 as mpositiontaking, @max_v3mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 5 as sporttype, @v5apositiontaking_10 as apositiontaking, @v5mpositiontaking_10 as mpositiontaking, @max_v5mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 8 as sporttype, @v8apositiontaking_10 as apositiontaking, @v8mpositiontaking_10 as mpositiontaking, @max_v8mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 10 as sporttype, @v10apositiontaking_10 as apositiontaking, @v10mpositiontaking_10 as mpositiontaking, @max_v10mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 11 as sporttype, @v11apositiontaking_10 as apositiontaking, @v11mpositiontaking_10 as mpositiontaking, @max_v11mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 10 as bettype, 99 as sporttype, @v99apositiontaking_10 as apositiontaking, @v99mpositiontaking_10 as mpositiontaking, @max_v99mapositiontaking_10 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		
		union all select 9999 as bettype, 1 as sporttype, @apositiontaking_9999 as apositiontaking, @mpositiontaking_9999 as mpositiontaking, @max_mapositiontaking_9999 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		
		--v2
		union all select 1 as bettype, 2 as sporttype, @v2apositiontaking_1 as apositiontaking, @v2mpositiontaking_1 as mpositiontaking, @max_v2mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 2 as bettype, 2 as sporttype, @v2apositiontaking_2 as apositiontaking, @v2mpositiontaking_2 as mpositiontaking, @max_v2mapositiontaking_2 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 3 as bettype, 2 as sporttype, @v2apositiontaking_3 as apositiontaking, @v2mpositiontaking_3 as mpositiontaking, @max_v2mapositiontaking_3 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
--		union all select 7 as bettype, 2 as sporttype, @v2apositiontaking_7 as apositiontaking, @v2mpositiontaking_7 as mpositiontaking, @max_v2mapositiontaking_7 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
--		union all select 8 as bettype, 2 as sporttype, @v2apositiontaking_8 as apositiontaking, @v2mpositiontaking_8 as mpositiontaking, @max_v2mapositiontaking_8 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
--		union all select 9 as bettype, 2 as sporttype, @v2apositiontaking_9 as apositiontaking, @v2mpositiontaking_9 as mpositiontaking, @max_v2mapositiontaking_9 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 2 as sporttype, @v2apositiontaking_20 as apositiontaking, @v2mpositiontaking_20 as mpositiontaking, @max_v2mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		--v3
		union all select 1 as bettype, 3 as sporttype, @v3apositiontaking_1 as apositiontaking, @v3mpositiontaking_1 as mpositiontaking, @max_v3mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 2 as bettype, 3 as sporttype, @v3apositiontaking_2 as apositiontaking, @v3mpositiontaking_2 as mpositiontaking, @max_v3mapositiontaking_2 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 3 as bettype, 3 as sporttype, @v3apositiontaking_3 as apositiontaking, @v3mpositiontaking_3 as mpositiontaking, @max_v3mapositiontaking_3 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 3 as sporttype, @v3apositiontaking_20 as apositiontaking, @v3mpositiontaking_20 as mpositiontaking, @max_v3mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		--v5
		union all select 1 as bettype, 5 as sporttype, @v5apositiontaking_1 as apositiontaking, @v5mpositiontaking_1 as mpositiontaking, @max_v5mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 2 as bettype, 5 as sporttype, @v5apositiontaking_2 as apositiontaking, @v5mpositiontaking_2 as mpositiontaking, @max_v5mapositiontaking_2 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 3 as bettype, 5 as sporttype, @v5apositiontaking_3 as apositiontaking, @v5mpositiontaking_3 as mpositiontaking, @max_v5mapositiontaking_3 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 5 as sporttype, @v5apositiontaking_20 as apositiontaking, @v5mpositiontaking_20 as mpositiontaking, @max_v5mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 9999 as bettype, 5 as sporttype, @v5apositiontaking_9999 as apositiontaking, @v5mpositiontaking_9999 as mpositiontaking, @max_v5mapositiontaking_9999 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		--v8
		union all select 1 as bettype, 8 as sporttype, @v8apositiontaking_1 as apositiontaking, @v8mpositiontaking_1 as mpositiontaking, @max_v8mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 3 as bettype, 8 as sporttype, @v8apositiontaking_3 as apositiontaking, @v8mpositiontaking_3 as mpositiontaking, @max_v8mapositiontaking_3 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 8 as sporttype, @v8apositiontaking_20 as apositiontaking, @v8mpositiontaking_20 as mpositiontaking, @max_v8mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		--v10
		union all select 1 as bettype, 10 as sporttype, @v10apositiontaking_1 as apositiontaking, @v10mpositiontaking_1 as mpositiontaking, @max_v10mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 2 as bettype, 10 as sporttype, @v10apositiontaking_2 as apositiontaking, @v10mpositiontaking_2 as mpositiontaking, @max_v10mapositiontaking_2 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 3 as bettype, 10 as sporttype, @v10apositiontaking_3 as apositiontaking, @v10mpositiontaking_3 as mpositiontaking, @max_v10mapositiontaking_3 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 10 as sporttype, @v10apositiontaking_20 as apositiontaking, @v10mpositiontaking_20 as mpositiontaking, @max_v10mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		--v11
		union all select 1 as bettype, 11 as sporttype, @v11apositiontaking_1 as apositiontaking, @v11mpositiontaking_1 as mpositiontaking, @max_v11mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 11 as sporttype, @v11apositiontaking_20 as apositiontaking, @v11mpositiontaking_20 as mpositiontaking, @max_v11mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		--v99
		union all select 1 as bettype, 99 as sporttype, @v99apositiontaking_1 as apositiontaking, @v99mpositiontaking_1 as mpositiontaking, @max_v99mapositiontaking_1 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 2 as bettype, 99 as sporttype, @v99apositiontaking_2 as apositiontaking, @v99mpositiontaking_2 as mpositiontaking, @max_v99mapositiontaking_2 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 3 as bettype, 99 as sporttype, @v99apositiontaking_3 as apositiontaking, @v99mpositiontaking_3 as mpositiontaking, @max_v99mapositiontaking_3 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		union all select 20 as bettype, 99 as sporttype, @v99apositiontaking_20 as apositiontaking, @v99mpositiontaking_20 as mpositiontaking, @max_v99mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking

		-- mixed sports
		union all select 9 as bettype, 99 as sporttype, @v99apositiontaking_9 as apositiontaking, @v99mpositiontaking_9 as mpositiontaking, @max_v99mapositiontaking_9 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		--v154
		union all select 20 as bettype, 154 as sporttype, @v154apositiontaking_20 as apositiontaking, @v154mpositiontaking_20 as mpositiontaking, @max_v154mapositiontaking_20 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking
		
		--number game
		union all select 81 as bettype, 161 as sporttype, @v161apositiontaking_81 as apositiontaking, @v161mpositiontaking_81 as mpositiontaking, @max_v161mapositiontaking_81 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking		
		union all select 83 as bettype, 161 as sporttype, @v161apositiontaking_83 as apositiontaking, @v161mpositiontaking_83 as mpositiontaking, @max_v161mapositiontaking_83 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking		
		union all select 85 as bettype, 161 as sporttype, 0 as apositiontaking, 0 as mpositiontaking, 0 as max_mapositiontaking, @v161alivepositiontaking_85 as alivepositiontaking, @v161mlivepositiontaking_85 as mlivepositiontaking, @max_v161malivepositiontaking_85 as max_malivepositiontaking
		union all select 86 as bettype, 161 as sporttype, @v161apositiontaking_86 as apositiontaking, @v161mpositiontaking_86 as mpositiontaking, @max_v161mapositiontaking_86 as max_mapositiontaking, @v161alivepositiontaking_86 as alivepositiontaking, @v161mlivepositiontaking_86 as mlivepositiontaking, @max_v161malivepositiontaking_86 as max_malivepositiontaking
		union all select 87 as bettype, 161 as sporttype, 0 as apositiontaking, 0 as mpositiontaking, 0 as max_mapositiontaking, @v161alivepositiontaking_87 as alivepositiontaking, @v161mlivepositiontaking_87 as mlivepositiontaking, @max_v161malivepositiontaking_87 as max_malivepositiontaking
		union all select 88 as bettype, 161 as sporttype, @v161apositiontaking_88 as apositiontaking, @v161mpositiontaking_88 as mpositiontaking, @max_v161mapositiontaking_88 as max_mapositiontaking, 0 as alivepositiontaking, 0 as mlivepositiontaking, 0 as max_malivepositiontaking		
		union all select 89 as bettype, 161 as sporttype, 0 as apositiontaking, 0 as mpositiontaking, 0 as max_mapositiontaking, @v161alivepositiontaking_89 as alivepositiontaking, @v161mlivepositiontaking_89 as mlivepositiontaking, @max_v161malivepositiontaking_89 as max_malivepositiontaking
		union all select 90 as bettype, 161 as sporttype, 0 as apositiontaking, 0 as mpositiontaking, 0 as max_mapositiontaking, @v161alivepositiontaking_90 as alivepositiontaking, @v161mlivepositiontaking_90 as mlivepositiontaking, @max_v161malivepositiontaking_90 as max_malivepositiontaking
		
	) as b
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where (b.apositiontaking+b.mpositiontaking>b.max_mapositiontaking) or 
		  (b.sporttype in (1,161) and b.bettype in (1,3,7,8,85,86,87) and (b.alivepositiontaking+b.mlivepositiontaking>b.max_malivepositiontaking))

	if @ErrType <>''
	BEGIN
		select @ErrCode = 101
		Select @ErrMsg = 	@UserName + ': '+
							case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
END



--check u2<=min(m3,m4,l3) - Phuc@20081209
if @UpdateMultiple = 0 
	or @UpdatePositiontaking = 1
	or @UpdatePositiontakingv2 = 1
	or @UpdatePositiontakingv3 = 1
	or @UpdatePositiontakingv5 = 1
	or @UpdatePositiontakingv8 = 1
	or @UpdatePositiontakingv10 = 1
	or @UpdatePositiontakingv11 = 1
	or @UpdatePositiontakingv99 = 1
	or @UpdatePositiontakingv99MP = 1
	or @UpdatePositiontakingv154 = 1
BEGIN
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end) as varchar(10))
	+ case when b.sporttype=1 and b.bettype in (1,3,7,8) then '-MaxLive: '+ cast((case when max_malivepositiontaking > co.maxlivepositiontaking then co.maxlivepositiontaking else max_malivepositiontaking end) as varchar(10)) else '' end + '<br>'
	from custoverride co (nolock) inner join 
	(
					select 1 as bettype, 1 as sporttype, @auto_mpositiontaking_1 as autopositiontaking, @auto_mlivepositiontaking_1	as autolivepositiontaking, @isauto_mpositiontaking_1 as isautopositiontaking, @isauto_mlivepositiontaking_1	as isautolivepositiontaking, @max_mapositiontaking_1 as max_mapositiontaking,@max_malivepositiontaking_1 as max_malivepositiontaking
		union all 	select 2 as bettype, 1 as sporttype, @auto_mpositiontaking_2 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_2 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_2 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 1 as sporttype, @auto_mpositiontaking_3 as autopositiontaking, @auto_mlivepositiontaking_3 	as autolivepositiontaking, @isauto_mpositiontaking_3 as isautopositiontaking, @isauto_mlivepositiontaking_3	as isautolivepositiontaking, @max_mapositiontaking_3 as max_mapositiontaking, @max_malivepositiontaking_3 as max_malivepositiontaking
		union all 	select 4 as bettype, 1 as sporttype, @auto_mpositiontaking_4 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_4 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_4 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 5 as bettype, 1 as sporttype, @auto_mpositiontaking_5 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_5 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_5 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 6 as bettype, 1 as sporttype, @auto_mpositiontaking_6 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_6 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_6 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 7 as bettype, 1 as sporttype, @auto_mpositiontaking_7 as autopositiontaking, @auto_mlivepositiontaking_7 	as autolivepositiontaking, @isauto_mpositiontaking_7 as isautopositiontaking, @isauto_mlivepositiontaking_7	as isautolivepositiontaking, @max_mapositiontaking_7 as max_mapositiontaking, @max_malivepositiontaking_7 as max_malivepositiontaking
		union all 	select 8 as bettype, 1 as sporttype, @auto_mpositiontaking_8 as autopositiontaking, @auto_mlivepositiontaking_8 	as autolivepositiontaking, @isauto_mpositiontaking_8 as isautopositiontaking, @isauto_mlivepositiontaking_8	as isautolivepositiontaking, @max_mapositiontaking_8 as max_mapositiontaking, @max_malivepositiontaking_8 as max_malivepositiontaking
		union all 	select 9 as bettype, 1 as sporttype, @auto_mpositiontaking_9 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_9 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_9 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 1 as sporttype, @auto_mpositiontaking_10 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_10 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		
		-- Outright PT for sports
		union all 	select 10 as bettype, 2 as sporttype, @auto_v2mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v2mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v2mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 3 as sporttype, @auto_v3mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v3mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v3mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 5 as sporttype, @auto_v5mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v5mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v5mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 8 as sporttype, @auto_v8mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v8mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v8mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 10 as sporttype, @auto_v10mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v10mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v10mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 11 as sporttype, @auto_v11mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v11mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v11mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 10 as bettype, 99 as sporttype, @auto_v99mpositiontaking_10 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v99mpositiontaking_10 as isautopositiontaking, 0as isautolivepositiontaking, @max_v99mapositiontaking_10 as max_mapositiontaking,0 as max_malivepositiontaking	
		
		union all 	select 9999 as bettype, 1 as sporttype, @auto_mpositiontaking_9999 as autopositiontaking, 0				as autolivepositiontaking, @isauto_mpositiontaking_9999 as isautopositiontaking, 0				as isautolivepositiontaking, @max_mapositiontaking_9999 as max_mapositiontaking,0 as max_malivepositiontaking	
		
		--v2
		union all	select 1 as bettype, 2 as sporttype, @auto_v2mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v2mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 2 as bettype, 2 as sporttype, @auto_v2mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v2mapositiontaking_2 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 2 as sporttype, @auto_v2mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v2mapositiontaking_3 as max_mapositiontaking,0 as max_malivepositiontaking	
--		union all 	select 9 as bettype, 2 as sporttype, @auto_v2mpositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v2mapositiontaking_9 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 2 as sporttype, @auto_v2mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v2mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v2mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	
	
		--v3
		union all	select 1 as bettype, 3 as sporttype, @auto_v3mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v3mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 2 as bettype, 3 as sporttype, @auto_v3mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v3mapositiontaking_2 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 3 as sporttype, @auto_v3mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v3mapositiontaking_3 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 3 as sporttype, @auto_v3mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v3mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v3mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	

		--v5
		union all	select 1 as bettype, 5 as sporttype, @auto_v5mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v5mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 2 as bettype, 5 as sporttype, @auto_v5mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v5mapositiontaking_2 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 5 as sporttype, @auto_v5mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v5mapositiontaking_3 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 5 as sporttype, @auto_v5mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v5mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 9999 as bettype, 5 as sporttype, @auto_v5mpositiontaking_9999 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v5mpositiontaking_9999 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v5mapositiontaking_9999 as max_mapositiontaking,0 as max_malivepositiontaking	

		--v8
		union all   select 1 as bettype, 8 as sporttype, @auto_v8mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v8mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 8 as sporttype, @auto_v8mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v8mapositiontaking_3 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 8 as sporttype, @auto_v8mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v8mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v8mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	

		--v10
		union all	select 1 as bettype, 10 as sporttype, @auto_v10mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v10mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 2 as bettype, 10 as sporttype, @auto_v10mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v10mapositiontaking_2 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 10 as sporttype, @auto_v10mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v10mapositiontaking_3 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 10 as sporttype, @auto_v10mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v10mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v10mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	

		--v11
		union all	select 1 as bettype, 11 as sporttype, @auto_v11mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v11mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 11 as sporttype, @auto_v11mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v11mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v11mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	

		--v99
		union all	select 1 as bettype, 99 as sporttype, @auto_v99mpositiontaking_1 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_1 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v99mapositiontaking_1 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 2 as bettype, 99 as sporttype, @auto_v99mpositiontaking_2 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_2 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v99mapositiontaking_2 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 3 as bettype, 99 as sporttype, @auto_v99mpositiontaking_3 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_3 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v99mapositiontaking_3 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 20 as bettype, 99 as sporttype, @auto_v99mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v99mapositiontaking_20 as max_mapositiontaking, 0 as max_malivepositiontaking	
		--v154
		union all 	select 20 as bettype, 154 as sporttype, @auto_v154mpositiontaking_20 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v154mpositiontaking_20 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v154mapositiontaking_20 as max_mapositiontaking,0 as max_malivepositiontaking	

		-- mixed sports
		union all 	select 9 as bettype, 99 as sporttype, @auto_v99mpositiontaking_9 as autopositiontaking, 0	as autolivepositiontaking, @isauto_v99mpositiontaking_9 as isautopositiontaking, 0	as isautolivepositiontaking, @max_v99mapositiontaking_9 as max_mapositiontaking,0 as max_malivepositiontaking
	) as b on b.sporttype = co.sporttype and b.bettype = co.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co.custid = @mrecommend and
	(
		  (	b.isautopositiontaking = 1 
			and b.autopositiontaking > case when max_mapositiontaking > co.maxpositiontaking then co.maxpositiontaking else max_mapositiontaking end
		  ) 
			or 
		  (	b.isautolivepositiontaking = 1 and b.sporttype = 1 and b.bettype in (1,3,7,8) 
			and (b.autolivepositiontaking > case when max_malivepositiontaking > co.maxlivepositiontaking then co.maxlivepositiontaking else max_malivepositiontaking end)
		  )
	)
	if @ErrType <>''
	BEGIN
		select @ErrCode = 101
		Select @ErrMsg = 	@UserName + ': '+
							case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
END

---- number game
--check u2<=min(m3,m4,l3)
if @UpdateMultiple = 0 
	or @UpdatePositiontakingv161 = 1	
BEGIN
	select @ErrType = ''
	select @ErrType = @ErrType + sportname + '-'+ typenamee + '-Max: '+ cast((case when max_mapositiontaking > co3.maxpositiontaking then co3.maxpositiontaking else max_mapositiontaking end) as varchar(10))
	+ case when b.sporttype=161 and b.bettype in (85,86,87,89,90) then '-MaxLive: '+ cast((case when max_malivepositiontaking > co3.maxlivepositiontaking then co3.maxlivepositiontaking else max_malivepositiontaking end) as varchar(10)) else '' end + '<br>'
	from custoverride3rd co3 (nolock) inner join 
	(					
				 	select 81 as bettype, 161 as sporttype, @auto_v161mpositiontaking_81 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v161mpositiontaking_81 as isautopositiontaking, 0 as isautolivepositiontaking, @max_v161mapositiontaking_81 as max_mapositiontaking,0 as max_malivepositiontaking	
		union all 	select 83 as bettype, 161 as sporttype, @auto_v161mpositiontaking_83 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v161mpositiontaking_83 as isautopositiontaking, 0 as isautolivepositiontaking, @max_v161mapositiontaking_83 as max_mapositiontaking,0 as max_malivepositiontaking
		union all 	select 85 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161mlivepositiontaking_85	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161mlivepositiontaking_85 as isautolivepositiontaking, 0 as max_mapositiontaking, @max_v161malivepositiontaking_85 as max_malivepositiontaking
		union all 	select 86 as bettype, 161 as sporttype, @auto_v161mpositiontaking_86 as autopositiontaking, @auto_v161mlivepositiontaking_86	as autolivepositiontaking, @isauto_v161mpositiontaking_86 as isautopositiontaking, @isauto_v161mlivepositiontaking_86	as isautolivepositiontaking, @max_v161mapositiontaking_86 as max_mapositiontaking,@max_v161malivepositiontaking_86 as max_malivepositiontaking
		union all 	select 87 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161mlivepositiontaking_87	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161mlivepositiontaking_87 as isautolivepositiontaking, 0 as max_mapositiontaking, @max_v161malivepositiontaking_87 as max_malivepositiontaking
		union all 	select 88 as bettype, 161 as sporttype, @auto_v161mpositiontaking_88 as autopositiontaking, 0 as autolivepositiontaking, @isauto_v161mpositiontaking_88 as isautopositiontaking, 0 as isautolivepositiontaking, @max_v161mapositiontaking_88 as max_mapositiontaking,0 as max_malivepositiontaking
		union all 	select 89 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161mlivepositiontaking_89	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161mlivepositiontaking_89 as isautolivepositiontaking, 0 as max_mapositiontaking, @max_v161malivepositiontaking_89 as max_malivepositiontaking
		union all 	select 90 as bettype, 161 as sporttype, 0 as autopositiontaking, @auto_v161mlivepositiontaking_90	as autolivepositiontaking, 0 as isautopositiontaking, @isauto_v161mlivepositiontaking_90 as isautolivepositiontaking, 0 as max_mapositiontaking, @max_v161malivepositiontaking_90 as max_malivepositiontaking
		
	) as b on b.sporttype = co3.sporttype and b.bettype = co3.bettype
	INNER JOIN @tmp_Sports s on b.sporttype = s.sporttype
	INNER JOIN @tmp_Bettype bt on b.bettype = bt.typeid
	where co3.custid = @mrecommend and
	(
		  (	b.isautopositiontaking = 1 
			and b.autopositiontaking > case when max_mapositiontaking > co3.maxpositiontaking then co3.maxpositiontaking else max_mapositiontaking end
		  ) 
			or 
		  (	b.isautolivepositiontaking = 1 and b.sporttype = 161 and b.bettype in (85,86,87,89,90) 
			and (b.autolivepositiontaking > case when max_malivepositiontaking > co3.maxlivepositiontaking then co3.maxlivepositiontaking else max_malivepositiontaking end)
		  )
	)

	if @ErrType <>''
	BEGIN
		select @ErrCode = 101
		Select @ErrMsg = 	@UserName + ': '+
							case @Language 
							when 'E' then 'Wrong position taking.<br>'+@ErrType
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>' + @ErrType
					end		
		return
	END
END
----------------------------------------------------------------------------------------------------------

update custsetting with (ROWLOCK, UPDLOCK)
set
	apositiontaking = case when (@UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) or (sporttype=2 and @UpdatePositiontakingv2 = 0) or (sporttype=3 and @UpdatePositiontakingv3 = 0) or (sporttype=5 and @UpdatePositiontakingv5 = 0) or (sporttype=8 and @UpdatePositiontakingv8 = 0) or (sporttype=10 and @UpdatePositiontakingv10 = 0) or (sporttype=11 and @UpdatePositiontakingv11 = 0) or (sporttype=99 and @UpdatePositiontakingv99 = 0 and bettype <> 9) or (sporttype=99 and @UpdatePositiontakingv99MP = 0 and bettype = 9) OR (sporttype=154 and @UpdatePositiontakingv154 = 0))) then apositiontaking else case sporttype 	when 1 then case bettype when 1 then @apositiontaking_1 when 2 then @apositiontaking_2 when 3 then @apositiontaking_3 when 4 then @apositiontaking_4 when 5 then @apositiontaking_5 when 6 then @apositiontaking_6 when 7 then @apositiontaking_7 when 8 then @apositiontaking_8 when 9 then @apositiontaking_9 when 10 then @apositiontaking_10 when 9999 then @apositiontaking_9999 else 0 end
					
					when 2 then case bettype when 1 then @v2apositiontaking_1 when 2 then @v2apositiontaking_2 when 3 then @v2apositiontaking_3 when 7 then @v2apositiontaking_7 when 8 then @v2apositiontaking_8  /*when 9 then @v2apositiontaking_9*/ when 20 then @v2apositiontaking_20 when 10 then @v2apositiontaking_10 else 0 end
					
					when 3 then case bettype when 1 then @v3apositiontaking_1 when 2 then @v3apositiontaking_2 when 3 then @v3apositiontaking_3 when 20 then @v3apositiontaking_20 when 10 then @v3apositiontaking_10 else 0 end
					
					when 5 then case bettype when 1 then @v5apositiontaking_1 when 2 then @v5apositiontaking_2 when 3 then @v5apositiontaking_3 when 20 then @v5apositiontaking_20 when 9999 then @v5apositiontaking_9999 when 10 then @v5apositiontaking_10 else 0 end
					
					when 8 then case bettype when 1 then @v8apositiontaking_1 when 3 then @v8apositiontaking_3 when 20 then @v8apositiontaking_20 when 10 then @v8apositiontaking_10 else 0 end
					
					when 10 then case bettype when 1 then @v10apositiontaking_1 when 2 then @v10apositiontaking_2 when 3 then @v10apositiontaking_3 when 20 then @v10apositiontaking_20 when 10 then @v10apositiontaking_10 else 0 end
					
					when 11 then case bettype when 1 then @v11apositiontaking_1 when 20 then @v11apositiontaking_20 when 10 then @v11apositiontaking_10 else 0 end
					
					when 99 then case bettype when 1 then @v99apositiontaking_1 when 2 then @v99apositiontaking_2 when 3 then @v99apositiontaking_3 when 20 then @v99apositiontaking_20 when 9 then @v99apositiontaking_9 when 10 then @v99apositiontaking_10 else 0 end
					
					when 154 then case bettype when 20 then @v154apositiontaking_20 else 0 end
				else apositiontaking end end,
				
	mpositiontaking = case 
					when (@UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) or (sporttype=2 and @UpdatePositiontakingv2 = 0) or (sporttype=3 and @UpdatePositiontakingv3 = 0) or (sporttype=5 and @UpdatePositiontakingv5 = 0) or (sporttype=8 and @UpdatePositiontakingv8 = 0) or (sporttype=10 and @UpdatePositiontakingv10 = 0) or (sporttype=11 and @UpdatePositiontakingv11 = 0) or (sporttype=99 and @UpdatePositiontakingv99 = 0 and bettype <> 9) or (sporttype=99 and @UpdatePositiontakingv99MP = 0 and bettype = 9) OR (sporttype=154 and @UpdatePositiontakingv154 = 0))) then mpositiontaking 
					else case sporttype 	
						when 1 then case bettype when 1 then @mpositiontaking_1 when 2 then @mpositiontaking_2 when 3 then @mpositiontaking_3 when 4 then @mpositiontaking_4 when 5 then @mpositiontaking_5 when 6 then @mpositiontaking_6 when 7 then @mpositiontaking_7 when 8 then @mpositiontaking_8 when 9 then @mpositiontaking_9  when 10 then @mpositiontaking_10 when 9999 then @mpositiontaking_9999 else 0 end
						
						when 2 then case bettype when 1 then @v2mpositiontaking_1 when 2 then @v2mpositiontaking_2 when 3 then @v2mpositiontaking_3 when 7 then @v2mpositiontaking_7 when 8 then @v2mpositiontaking_8 /*when 9 then @v2mpositiontaking_9*/ when 20 then @v2mpositiontaking_20 when 10 then @v2mpositiontaking_10 else 0 end
						
						when 3 then case bettype when 1 then @v3mpositiontaking_1 when 2 then @v3mpositiontaking_2 when 3 then @v3mpositiontaking_3 when 20 then @v3mpositiontaking_20 when 10 then @v3mpositiontaking_10 else 0 end
						
						when 5 then case bettype when 1 then @v5mpositiontaking_1 when 2 then @v5mpositiontaking_2 when 3 then @v5mpositiontaking_3 when 20 then @v5mpositiontaking_20 when 9999 then @v5mpositiontaking_9999 when 10 then @v5mpositiontaking_10 else 0 end
						
						when 8 then case bettype when 1 then @v8mpositiontaking_1 when 3 then @v8mpositiontaking_3 when 20 then @v8mpositiontaking_20 when 10 then @v8mpositiontaking_10 else 0 end
						
						when 10 then case bettype when 1 then @v10mpositiontaking_1 when 2 then @v10mpositiontaking_2 when 3 then @v10mpositiontaking_3 when 20 then @v10mpositiontaking_20 when 10 then @v10mpositiontaking_10 else 0 end
						
						when 11 then case bettype when 1 then @v11mpositiontaking_1 when 20 then @v11mpositiontaking_20 when 10 then @v11mpositiontaking_10 else 0 end
						
						when 99 then case bettype when 1 then @v99mpositiontaking_1 when 2 then @v99mpositiontaking_2 when 3 then @v99mpositiontaking_3 when 20 then @v99mpositiontaking_20 when 9 then @v99mpositiontaking_9 when 10 then @v99mpositiontaking_10 else 0 end
						
						when 154 then case bettype when 20 then @v154mpositiontaking_20 else 0 end					
				else mpositiontaking end end,
	alivepositiontaking = case when (@UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) or (sporttype=2 and @UpdatePositiontakingv2 = 0) or (sporttype=3 and @UpdatePositiontakingv3 = 0) or (sporttype=5 and @UpdatePositiontakingv5 = 0) or (sporttype=8 and @UpdatePositiontakingv8 = 0) or (sporttype=10 and @UpdatePositiontakingv10 = 0) or (sporttype=11 and @UpdatePositiontakingv11 = 0) or (sporttype=99 and @UpdatePositiontakingv99 = 0 and bettype <> 9) or (sporttype=99 and @UpdatePositiontakingv99MP = 0 and bettype = 9) OR (sporttype=154 and @UpdatePositiontakingv154 = 0))) then alivepositiontaking else case sporttype 	when 1 then case bettype when 1 then @alivepositiontaking_1 when 3 then @alivepositiontaking_3 when 7 then @alivepositiontaking_7 when 8 then @alivepositiontaking_8 else alivepositiontaking end else alivepositiontaking end end,
	mlivepositiontaking = case when (@UpdateMultiple = 1 and ((sporttype=1 and @UpdatePositiontaking = 0) or (sporttype=2 and @UpdatePositiontakingv2 = 0) or (sporttype=3 and @UpdatePositiontakingv3 = 0) or (sporttype=5 and @UpdatePositiontakingv5 = 0) or (sporttype=8 and @UpdatePositiontakingv8 = 0) or (sporttype=10 and @UpdatePositiontakingv10 = 0) or (sporttype=11 and @UpdatePositiontakingv11 = 0) or (sporttype=99 and @UpdatePositiontakingv99 = 0 and bettype <> 9) or (sporttype=99 and @UpdatePositiontakingv99MP = 0 and bettype = 9) OR (sporttype=154 and @UpdatePositiontakingv154 = 0))) then mlivepositiontaking else case sporttype 	when 1 then case bettype when 1 then @mlivepositiontaking_1 when 3 then @mlivepositiontaking_3 when 7 then @mlivepositiontaking_7 when 8 then @mlivepositiontaking_8 else mlivepositiontaking end else mlivepositiontaking end end
where custid=@custid
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115
	return
end

--- number game
update custsetting3rd with(rowlock,updlock)
set apositiontaking = case when (@UpdateMultiple = 1 and sporttype = 161 and @UpdatePositiontakingv161 = 0)  then apositiontaking 
						   else case sporttype when 161 then case bettype when 81 then @v161apositiontaking_81 
																		  when 83 then @v161apositiontaking_83 
																		  --when 85 then @v161apositiontaking_85 
																		  when 86 then @v161apositiontaking_86 	
																		  when 88 then @v161apositiontaking_88 																      
																		  else 0 end
											   else apositiontaking end 
						   end,

	mpositiontaking = case when (@UpdateMultiple = 1 and sporttype = 161 and @UpdatePositiontakingv161 = 0)  then mpositiontaking 
						   else case sporttype when 161 then case bettype when 81 then @v161mpositiontaking_81 
																		  when 83 then @v161mpositiontaking_83 
																		  --when 85 then @v161mpositiontaking_85 
																		  when 86 then @v161mpositiontaking_86 	
																		  when 88 then @v161mpositiontaking_88																      
																		  else 0 end
											   else mpositiontaking end 
						   end,
	alivepositiontaking = case when (@UpdateMultiple = 1 and sporttype=161 and @UpdatePositiontakingv161 = 0) then alivepositiontaking else case sporttype 	when 161 then case bettype when 85 then @v161alivepositiontaking_85 when 86 then @v161alivepositiontaking_86 when 87 then @v161alivepositiontaking_87 when 89 then @v161alivepositiontaking_89 when 90 then @v161alivepositiontaking_90 else alivepositiontaking end else alivepositiontaking end end,
	mlivepositiontaking = case when (@UpdateMultiple = 1 and sporttype=161 and @UpdatePositiontakingv161 = 0) then mlivepositiontaking else case sporttype 	when 161 then case bettype when 85 then @v161mlivepositiontaking_85 when 86 then @v161mlivepositiontaking_86 when 87 then @v161mlivepositiontaking_87 when 89 then @v161mlivepositiontaking_89 when 90 then @v161mlivepositiontaking_90 else mlivepositiontaking end else mlivepositiontaking end end
where custid = @custid
if(@@error <> 0)
begin
	select @ErrMsg = @UserName + ': '+
					 case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 115
	return
end

----------------------------------------------------------
--Cal Auto Positiontaking for Master
EXEC dbo.Acc_CustomerUpdAgent_AutoPositiontaking 
	@recommend = @custid,
	@mrecommend = @mrecommend,
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
	-- mixed sports
	@auto_v99mpositiontaking_9 = @auto_v99mpositiontaking_9,
	@auto_v154mpositiontaking_20 = @auto_v154mpositiontaking_20,
	
	-- number game
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
	
	-- number game
	@updatepositiontakingv161 = @updatepositiontakingv161,

	@language = @language,
	@updateallmembers = @updateallmembers,
	@newmpositiontaking = @newmpositiontaking,
	@userid = @userid,
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
--	@isauto_v2mpositiontaking_9 = @isauto_v2mpositiontaking_9,
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
	
	-- number game
	@isauto_v161mpositiontaking_81 = @isauto_v161mpositiontaking_81,
	@isauto_v161mpositiontaking_83 = @isauto_v161mpositiontaking_83,
	--@isauto_v161mpositiontaking_85 = @isauto_v161mpositiontaking_85,
	@isauto_v161mpositiontaking_86 = @isauto_v161mpositiontaking_86,
	@isauto_v161mpositiontaking_88 = @isauto_v161mpositiontaking_88,
	
	@isauto_v161mlivepositiontaking_85 = @isauto_v161mlivepositiontaking_85,
	@isauto_v161mlivepositiontaking_86 = @isauto_v161mlivepositiontaking_86,
	@isauto_v161mlivepositiontaking_87 = @isauto_v161mlivepositiontaking_87,
	@isauto_v161mlivepositiontaking_89 = @isauto_v161mlivepositiontaking_89,
	@isauto_v161mlivepositiontaking_90 = @isauto_v161mlivepositiontaking_90,

	-- Outright PT for sports
	
	@auto_v2mpositiontaking_10 = @auto_v2mpositiontaking_10,
	@auto_v3mpositiontaking_10 = @auto_v3mpositiontaking_10,
	@auto_v5mpositiontaking_10 = @auto_v5mpositiontaking_10,
	@auto_v8mpositiontaking_10 = @auto_v8mpositiontaking_10,
	@auto_v10mpositiontaking_10 = @auto_v10mpositiontaking_10,
	@auto_v11mpositiontaking_10 = @auto_v11mpositiontaking_10,
	@auto_v99mpositiontaking_10 = @auto_v99mpositiontaking_10,
	
	@isauto_v2mpositiontaking_10 = @isauto_v2mpositiontaking_10,
	@isauto_v3mpositiontaking_10 = @isauto_v3mpositiontaking_10,
	@isauto_v5mpositiontaking_10 = @isauto_v5mpositiontaking_10,
	@isauto_v8mpositiontaking_10 = @isauto_v8mpositiontaking_10,
	@isauto_v10mpositiontaking_10 = @isauto_v10mpositiontaking_10,
	@isauto_v11mpositiontaking_10 = @isauto_v11mpositiontaking_10,
	@isauto_v99mpositiontaking_10 = @isauto_v99mpositiontaking_10,
	

	@ErrCode = @ErrCode OUTPUT,
	@ErrMsg = @ErrMsg OUTPUT
	
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 123					 
	
	return
end

---- 20131030@Johnson: apply execrep for recalculating pt on members
EXEC dbo.Acc_CustSetting_07 @recommend = @custid, @roleid = 2

EXEC dbo.Acc_CustSetting3rd_07 @recommend = @custid, @roleid = 2, @mode = 'number'

/*					
EXEC dbo.Acc_CustomerUpdAgent_MaxPositiontaking @recommend = @custid
if (@@error <> 0)
begin
	
	Select @ErrMsg = @UserName + ': '+
					case @Language 
						when 'E' then 'Update process is unsuccessful !'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
					end, @ErrCode = 124					 
	
	return
end
*/


Declare @LogSPData varchar(8000)
Declare @TrackingValue2 varchar(8000)

----------
-- 20150714@Johnson: Write log value from db if not change when update multiple [Redmine: #39555]
---------------------------------
SELECT 
	@apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_1 ELSE @apositiontaking_1 END,
	@apositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_2 ELSE @apositiontaking_2 END,
	@apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_3 ELSE @apositiontaking_3 END,
	@apositiontaking_4 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_4 ELSE @apositiontaking_4 END,
	@apositiontaking_5 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_5 ELSE @apositiontaking_5 END,
	@apositiontaking_6 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_6 ELSE @apositiontaking_6 END,
	@apositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_7 ELSE @apositiontaking_7 END,
	@apositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_8 ELSE @apositiontaking_8 END,
	@apositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_9 ELSE @apositiontaking_9 END,
	@apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_10 ELSE @apositiontaking_10 END,
	-- Outright PT for sports
	@v2apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_10 ELSE @v2apositiontaking_10 END,
	@v3apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_10 ELSE @v3apositiontaking_10 END,
	@v5apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_10 ELSE @v5apositiontaking_10 END,
	@v8apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_10 ELSE @v8apositiontaking_10 END,
	@v10apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_10 ELSE @v10apositiontaking_10 END,
	@v11apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11apositiontaking_10 ELSE @v11apositiontaking_10 END,
	@v99apositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_10 ELSE @v99apositiontaking_10 END,
	
	@apositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_apositiontaking_9999 ELSE @apositiontaking_9999 END,
	
	@mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_1 ELSE @mpositiontaking_1 END,
	@mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_2 ELSE @mpositiontaking_2 END,
	@mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_3 ELSE @mpositiontaking_3 END,
	@mpositiontaking_4 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_4 ELSE @mpositiontaking_4 END,
	@mpositiontaking_5 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_5 ELSE @mpositiontaking_5 END,
	@mpositiontaking_6 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_6 ELSE @mpositiontaking_6 END,
	@mpositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_7 ELSE @mpositiontaking_7 END,
	@mpositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_8 ELSE @mpositiontaking_8 END,
	@mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_9 ELSE @mpositiontaking_9 END,
	@mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_10 ELSE @mpositiontaking_10 END,
	-- outright PT for sports
	@v2mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_10 ELSE @v2mpositiontaking_10 END,
	@v3mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3mpositiontaking_10 ELSE @v3mpositiontaking_10 END,
	@v5mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5mpositiontaking_10 ELSE @v5mpositiontaking_10 END,
	@v8mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8mpositiontaking_10 ELSE @v8mpositiontaking_10 END,
	@v10mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10mpositiontaking_10 ELSE @v10mpositiontaking_10 END,
	@v11mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11mpositiontaking_10 ELSE @v11mpositiontaking_10 END,
	@v99mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99mpositiontaking_10 ELSE @v99mpositiontaking_10 END,
	
	@mpositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mpositiontaking_9999 ELSE @mpositiontaking_9999 END,
	
	@alivepositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_1 ELSE @alivepositiontaking_1 END,
	@alivepositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_3 ELSE @alivepositiontaking_3 END,
	@alivepositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_7 ELSE @alivepositiontaking_7 END,
	@alivepositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_alivepositiontaking_8 ELSE @alivepositiontaking_8 END,
	@mlivepositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mlivepositiontaking_1 ELSE @mlivepositiontaking_1 END,
	@mlivepositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mlivepositiontaking_3 ELSE @mlivepositiontaking_3 END,
	@mlivepositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mlivepositiontaking_7 ELSE @mlivepositiontaking_7 END,
	@mlivepositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_mlivepositiontaking_8 ELSE @mlivepositiontaking_8 END,
	
	@v2apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_1 ELSE @v2apositiontaking_1 END,
	@v2apositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_2 ELSE @v2apositiontaking_2 END,
	@v2apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_3 ELSE @v2apositiontaking_3 END,
	@v2apositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_7 ELSE @v2apositiontaking_7 END,
	@v2apositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_8 ELSE @v2apositiontaking_8 END,
--	@v2apositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @@UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_9 ELSE @v2apositiontaking_9 END,
	@v2apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2apositiontaking_20 ELSE @v2apositiontaking_20 END,

	@v3apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_1 ELSE @v3apositiontaking_1 END,
	@v3apositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_1 ELSE @v3apositiontaking_1 END,
	@v3apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_1 ELSE @v3apositiontaking_1 END,
	@v3apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3apositiontaking_1 ELSE @v3apositiontaking_1 END,

	@v5apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_1 ELSE @v5apositiontaking_1 END,
	@v5apositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_2 ELSE @v5apositiontaking_2 END,
	@v5apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_3 ELSE @v5apositiontaking_3 END,
	@v5apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_20 ELSE @v5apositiontaking_20 END,
	@v5apositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5apositiontaking_9999 ELSE @v5apositiontaking_9999 END,

	@v8apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_1 ELSE @v8apositiontaking_1 END,
	@v8apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_3 ELSE @v8apositiontaking_3 END,
	@v8apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8apositiontaking_20 ELSE @v8apositiontaking_20 END,
	
	@v10apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_1 ELSE @v10apositiontaking_1 END,
	@v10apositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_2 ELSE @v10apositiontaking_2 END,
	@v10apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_3 ELSE @v10apositiontaking_3 END,
	@v10apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10apositiontaking_20 ELSE @v10apositiontaking_20 END,

	@v11apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11apositiontaking_1 ELSE @v11apositiontaking_1 END,
	@v11apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11apositiontaking_20 ELSE @v11apositiontaking_20 END,
	
	@v99apositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_1 ELSE @v99apositiontaking_1 END,
	@v99apositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_2 ELSE @v99apositiontaking_2 END,
	@v99apositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_3 ELSE @v99apositiontaking_3 END,
	@v99apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99apositiontaking_20 ELSE @v99apositiontaking_20 END,
	
	-- mixed sports
	@v99apositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99mp = 0 THEN @Old_v99apositiontaking_9 ELSE @v99apositiontaking_9 END,
	@v154apositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv154 = 0 THEN @Old_v154apositiontaking_20 ELSE @v154apositiontaking_20 END,
	
	-- number game
	@v161apositiontaking_81 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_81 ELSE @v161apositiontaking_81 END,
	@v161apositiontaking_83 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_83 ELSE @v161apositiontaking_83 END,
	--@v161apositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @@UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_85 ELSE @@v161apositiontaking_85 END,
	@v161apositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_86 ELSE @v161apositiontaking_86 END,
	@v161apositiontaking_88 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161apositiontaking_88 ELSE @v161apositiontaking_88 END,
	
	@v161alivepositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_85 ELSE @v161alivepositiontaking_85 END,
	@v161alivepositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_86 ELSE @v161alivepositiontaking_86 END,
	@v161alivepositiontaking_87 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_87 ELSE @v161alivepositiontaking_87 END,
	@v161alivepositiontaking_89 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_89 ELSE @v161alivepositiontaking_89 END,
	@v161alivepositiontaking_90 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161alivepositiontaking_90 ELSE @v161alivepositiontaking_90 END,
	
	@v2mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_1 ELSE @v2mpositiontaking_1 END,
	@v2mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_2 ELSE @v2mpositiontaking_2 END,
	@v2mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_3 ELSE @v2mpositiontaking_3 END,
	@v2mpositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_7 ELSE @v2mpositiontaking_7 END,
	@v2mpositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_8 ELSE @v2mpositiontaking_8 END,
--	@v2mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_9 ELSE @v2mpositiontaking_9 END,
	@v2mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_v2mpositiontaking_20 ELSE @v2mpositiontaking_20 END,

	@v3mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3mpositiontaking_1 ELSE @v3mpositiontaking_1 END,
	@v3mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3mpositiontaking_2 ELSE @v3mpositiontaking_2 END,
	@v3mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3mpositiontaking_3 ELSE @v3mpositiontaking_3 END,
	@v3mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_v3mpositiontaking_20 ELSE @v3mpositiontaking_20 END,

	@v5mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5mpositiontaking_1 ELSE @v5mpositiontaking_1 END,
	@v5mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5mpositiontaking_2 ELSE @v5mpositiontaking_2 END,
	@v5mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5mpositiontaking_3 ELSE @v5mpositiontaking_3 END,
	@v5mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5mpositiontaking_20 ELSE @v5mpositiontaking_20 END,
	@v5mpositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_v5mpositiontaking_9999 ELSE @v5mpositiontaking_9999 END,

	@v8mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8mpositiontaking_1 ELSE @v8mpositiontaking_1 END,
	@v8mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8mpositiontaking_3 ELSE @v8mpositiontaking_3 END,
	@v8mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_v8mpositiontaking_20 ELSE @v8mpositiontaking_20 END,

	@v10mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10mpositiontaking_1 ELSE @v10mpositiontaking_1 END,
	@v10mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10mpositiontaking_2 ELSE @v10mpositiontaking_2 END,
	@v10mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10mpositiontaking_3 ELSE @v10mpositiontaking_3 END,
	@v10mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_v10mpositiontaking_20 ELSE @v10mpositiontaking_20 END,

	@v11mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11mpositiontaking_1 ELSE @v11mpositiontaking_1 END,
	@v11mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_v11mpositiontaking_20 ELSE @v11mpositiontaking_20 END,

	@v99mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99mpositiontaking_1 ELSE @v99mpositiontaking_1 END,
	@v99mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99mpositiontaking_2 ELSE @v99mpositiontaking_2 END,
	@v99mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99mpositiontaking_3 ELSE @v99mpositiontaking_3 END,
	@v99mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_v99mpositiontaking_20 ELSE @v99mpositiontaking_20 END,

	-- mixed sports
	@v99mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99mp = 0 THEN @Old_v99mpositiontaking_9 ELSE @v99mpositiontaking_9 END,
	@v154mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv154 = 0 THEN @Old_v154mpositiontaking_20 ELSE @v154mpositiontaking_20 END,
	
	-- number game
	@v161mpositiontaking_81 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mpositiontaking_81 ELSE @v161mpositiontaking_81 END,
	@v161mpositiontaking_83 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mpositiontaking_83 ELSE @v161mpositiontaking_83 END,
	--@v161mpositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mpositiontaking_85 ELSE @v161mpositiontaking_85 END,
	@v161mpositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mpositiontaking_86 ELSE @v161mpositiontaking_86 END,
	@v161mpositiontaking_88 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mpositiontaking_88 ELSE @v161mpositiontaking_88 END,
	
	@v161mlivepositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mlivepositiontaking_85 ELSE @v161mlivepositiontaking_85 END,
	@v161mlivepositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mlivepositiontaking_86 ELSE @v161mlivepositiontaking_86 END,
	@v161mlivepositiontaking_87 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mlivepositiontaking_87 ELSE @v161mlivepositiontaking_87 END,
	@v161mlivepositiontaking_89 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mlivepositiontaking_89 ELSE @v161mlivepositiontaking_89 END,
	@v161mlivepositiontaking_90 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_v161mlivepositiontaking_90 ELSE @v161mlivepositiontaking_90 END,
	
	@auto_mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_1 ELSE @auto_mpositiontaking_1 END,
	@auto_mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_2 ELSE @auto_mpositiontaking_2 END,
	@auto_mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_3 ELSE @auto_mpositiontaking_3 END,
	@auto_mpositiontaking_4 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_4 ELSE @auto_mpositiontaking_4 END,
	@auto_mpositiontaking_5 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_5 ELSE @auto_mpositiontaking_5 END,
	@auto_mpositiontaking_6 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_6 ELSE @auto_mpositiontaking_6 END,
	@auto_mpositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_7 ELSE @auto_mpositiontaking_7 END,
	@auto_mpositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_8 ELSE @auto_mpositiontaking_8 END,
	@auto_mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_9 ELSE @auto_mpositiontaking_9 END,
	@auto_mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_10 ELSE @auto_mpositiontaking_10 END,
	-- Outright PT for sports
	@auto_v2mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_10 ELSE @auto_v2mpositiontaking_10 END,
	@auto_v3mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_auto_v3mpositiontaking_10 ELSE @auto_v3mpositiontaking_10 END,
	@auto_v5mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5mpositiontaking_10 ELSE @auto_v5mpositiontaking_10 END,
	@auto_v8mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_auto_v8mpositiontaking_10 ELSE @auto_v8mpositiontaking_10 END,
	@auto_v10mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_auto_v10mpositiontaking_10 ELSE @auto_v10mpositiontaking_10 END,
	@auto_v11mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @Old_auto_v11mpositiontaking_10 ELSE @auto_v11mpositiontaking_10 END,
	@auto_v99mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_auto_v99mpositiontaking_10 ELSE @auto_v99mpositiontaking_10 END,
	
	@auto_mpositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mpositiontaking_9999 ELSE @auto_mpositiontaking_9999 END,
	@auto_mlivepositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mlivepositiontaking_1 ELSE @auto_mlivepositiontaking_1 END,
	@auto_mlivepositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mlivepositiontaking_3 ELSE @auto_mlivepositiontaking_3 END,
	@auto_mlivepositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mlivepositiontaking_7 ELSE @auto_mlivepositiontaking_7 END,
	@auto_mlivepositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @Old_auto_mlivepositiontaking_8 ELSE @auto_mlivepositiontaking_8 END,
	
	@auto_v2mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_1 ELSE @auto_v2mpositiontaking_1 END,
	@auto_v2mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_2 ELSE @auto_v2mpositiontaking_2 END,
	@auto_v2mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_3 ELSE @auto_v2mpositiontaking_3 END,
	@auto_v2mpositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_7 ELSE @auto_v2mpositiontaking_7 END,
	@auto_v2mpositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_8 ELSE @auto_v2mpositiontaking_8 END,
--	@auto_v2mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_9 ELSE @auto_v2mpositiontaking_9 END,
	@auto_v2mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @Old_auto_v2mpositiontaking_20 ELSE @auto_v2mpositiontaking_20 END,
	
	@auto_v3mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_auto_v3mpositiontaking_1 ELSE @auto_v3mpositiontaking_1 END,
	@auto_v3mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_auto_v3mpositiontaking_2 ELSE @auto_v3mpositiontaking_2 END,
	@auto_v3mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_auto_v3mpositiontaking_3 ELSE @auto_v3mpositiontaking_3 END,
	@auto_v3mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @Old_auto_v3mpositiontaking_20 ELSE @auto_v3mpositiontaking_20 END,
	
	@auto_v5mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5mpositiontaking_1 ELSE @auto_v5mpositiontaking_1 END,
	@auto_v5mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5mpositiontaking_2 ELSE @auto_v5mpositiontaking_2 END,
	@auto_v5mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5mpositiontaking_3 ELSE @auto_v5mpositiontaking_3 END,
	@auto_v5mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5mpositiontaking_20 ELSE @auto_v5mpositiontaking_20 END,
	@auto_v5mpositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @Old_auto_v5mpositiontaking_9999 ELSE @auto_v5mpositiontaking_9999 END,
	
	@auto_v8mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_auto_v8mpositiontaking_1 ELSE @auto_v8mpositiontaking_1 END,
	@auto_v8mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_auto_v8mpositiontaking_3 ELSE @auto_v8mpositiontaking_3 END,
	@auto_v8mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @Old_auto_v8mpositiontaking_20 ELSE @auto_v8mpositiontaking_20 END,
	
	@auto_v10mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_auto_v10mpositiontaking_1 ELSE @auto_v10mpositiontaking_1 END,
	@auto_v10mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_auto_v10mpositiontaking_2 ELSE @auto_v10mpositiontaking_2 END,
	@auto_v10mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_auto_v10mpositiontaking_3 ELSE @auto_v10mpositiontaking_3 END,
	@auto_v10mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @Old_auto_v10mpositiontaking_20 ELSE @auto_v10mpositiontaking_20 END,
	
	@auto_v11mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @auto_v11mpositiontaking_1 ELSE @auto_v11mpositiontaking_1 END,
	@auto_v11mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @auto_v11mpositiontaking_20 ELSE @auto_v11mpositiontaking_20 END,

	@auto_v99mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_auto_v99mpositiontaking_1 ELSE @auto_v99mpositiontaking_1 END,
	@auto_v99mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_auto_v99mpositiontaking_2 ELSE @auto_v99mpositiontaking_2 END,
	@auto_v99mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_auto_v99mpositiontaking_3 ELSE @auto_v99mpositiontaking_3 END,
	@auto_v99mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @Old_auto_v99mpositiontaking_20 ELSE @auto_v99mpositiontaking_20 END,	

	-- mixed sports
	@auto_v99mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99mp = 0 THEN @Old_auto_v99mpositiontaking_9 ELSE @auto_v99mpositiontaking_9 END,
	@auto_v154mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv154 = 0 THEN @Old_auto_v154mpositiontaking_20 ELSE @auto_v154mpositiontaking_20 END,	
	
	--number game
	@auto_v161mpositiontaking_81 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mpositiontaking_81 ELSE @auto_v161mpositiontaking_81 END,
	@auto_v161mpositiontaking_83 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mpositiontaking_83 ELSE @auto_v161mpositiontaking_83 END,
	--@auto_v161mpositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mpositiontaking_85 ELSE @auto_v161mpositiontaking_85 END,
	@auto_v161mpositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mpositiontaking_86 ELSE @auto_v161mpositiontaking_86 END,
	@auto_v161mpositiontaking_88 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mpositiontaking_88 ELSE @auto_v161mpositiontaking_88 END,
	
	@auto_v161mlivepositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mlivepositiontaking_85 ELSE @auto_v161mlivepositiontaking_85 END,
	@auto_v161mlivepositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mlivepositiontaking_86 ELSE @auto_v161mlivepositiontaking_86 END,
	@auto_v161mlivepositiontaking_87 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mlivepositiontaking_87 ELSE @auto_v161mlivepositiontaking_87 END,
	@auto_v161mlivepositiontaking_89 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mlivepositiontaking_89 ELSE @auto_v161mlivepositiontaking_89 END,
	@auto_v161mlivepositiontaking_90 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @Old_auto_v161mlivepositiontaking_90 ELSE @auto_v161mlivepositiontaking_90 END,
	
	@isauto_mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_1 ELSE @isauto_mpositiontaking_1 END,
	@isauto_mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_2 ELSE @isauto_mpositiontaking_2 END,
	@isauto_mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_3 ELSE @isauto_mpositiontaking_3 END,
	@isauto_mpositiontaking_4 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_4 ELSE @isauto_mpositiontaking_4 END,
	@isauto_mpositiontaking_5 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_5 ELSE @isauto_mpositiontaking_5 END,
	@isauto_mpositiontaking_6 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_6 ELSE @isauto_mpositiontaking_6 END,
	@isauto_mpositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_7 ELSE @isauto_mpositiontaking_7 END,
	@isauto_mpositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_8 ELSE @isauto_mpositiontaking_8 END,
	@isauto_mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_9 ELSE @isauto_mpositiontaking_9 END,
	@isauto_mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_10 ELSE @isauto_mpositiontaking_10 END,
	-- Outright PT for sports
	@isauto_v2mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_10 ELSE @isauto_v2mpositiontaking_10 END,
	@isauto_v3mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_10 ELSE @isauto_v3mpositiontaking_10 END,
	@isauto_v5mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_10 ELSE @isauto_v5mpositiontaking_10 END,
	@isauto_v8mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_10 ELSE @isauto_v8mpositiontaking_10 END,
	@isauto_v10mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_10 ELSE @isauto_v10mpositiontaking_10 END,
	@isauto_v11mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11mpositiontaking_10 ELSE @isauto_v11mpositiontaking_10 END,
	@isauto_v99mpositiontaking_10 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_10 ELSE @isauto_v99mpositiontaking_10 END,
	
	@isauto_mpositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mpositiontaking_9999 ELSE @isauto_mpositiontaking_9999 END,
	@isauto_mlivepositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_1 ELSE @isauto_mlivepositiontaking_1 END,
	@isauto_mlivepositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_3 ELSE @isauto_mlivepositiontaking_3 END,
	@isauto_mlivepositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_7 ELSE @isauto_mlivepositiontaking_7 END,
	@isauto_mlivepositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontaking = 0 THEN @old_isauto_mlivepositiontaking_8 ELSE @isauto_mlivepositiontaking_8 END,
	
	@isauto_v2mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_1 ELSE @isauto_v2mpositiontaking_1 END,
	@isauto_v2mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_2 ELSE @isauto_v2mpositiontaking_2 END,
	@isauto_v2mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_3 ELSE @isauto_v2mpositiontaking_3 END,
	@isauto_v2mpositiontaking_7 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_7 ELSE @isauto_v2mpositiontaking_7 END,
	@isauto_v2mpositiontaking_8 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_8 ELSE @isauto_v2mpositiontaking_8 END,
--	@isauto_v2mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_9 ELSE @isauto_v2mpositiontaking_9 END,
	@isauto_v2mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv2 = 0 THEN @old_isauto_v2mpositiontaking_20 ELSE @isauto_v2mpositiontaking_20 END,
	
	@isauto_v3mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_1 ELSE @isauto_v3mpositiontaking_1 END,
	@isauto_v3mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_2 ELSE @isauto_v3mpositiontaking_2 END,
	@isauto_v3mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_3 ELSE @isauto_v3mpositiontaking_3 END,
	@isauto_v3mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv3 = 0 THEN @old_isauto_v3mpositiontaking_20 ELSE @isauto_v3mpositiontaking_20 END,
	
	@isauto_v5mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_1 ELSE @isauto_v5mpositiontaking_1 END,
	@isauto_v5mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_2 ELSE @isauto_v5mpositiontaking_2 END,
	@isauto_v5mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_3 ELSE @isauto_v5mpositiontaking_3 END,
	@isauto_v5mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_20 ELSE @isauto_v5mpositiontaking_20 END,
	@isauto_v5mpositiontaking_9999 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv5 = 0 THEN @old_isauto_v5mpositiontaking_9999 ELSE @isauto_v5mpositiontaking_9999 END,
	
	@isauto_v8mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_1 ELSE @isauto_v8mpositiontaking_1 END,
	@isauto_v8mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_3 ELSE @isauto_v8mpositiontaking_3 END,
	@isauto_v8mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv8 = 0 THEN @old_isauto_v8mpositiontaking_20 ELSE @isauto_v8mpositiontaking_20 END,
	
	@isauto_v10mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_1 ELSE @isauto_v10mpositiontaking_1 END,
	@isauto_v10mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_2 ELSE @isauto_v10mpositiontaking_2 END,
	@isauto_v10mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_3 ELSE @isauto_v10mpositiontaking_3 END,
	@isauto_v10mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv10 = 0 THEN @old_isauto_v10mpositiontaking_20 ELSE @isauto_v10mpositiontaking_20 END,
	
	@isauto_v11mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11mpositiontaking_1 ELSE @isauto_v11mpositiontaking_1 END,
	@isauto_v11mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv11 = 0 THEN @old_isauto_v11mpositiontaking_20 ELSE @isauto_v11mpositiontaking_20 END,

	@isauto_v99mpositiontaking_1 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_1 ELSE @isauto_v99mpositiontaking_1 END,
	@isauto_v99mpositiontaking_2 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_2 ELSE @isauto_v99mpositiontaking_2 END,
	@isauto_v99mpositiontaking_3 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_3 ELSE @isauto_v99mpositiontaking_3 END,
	@isauto_v99mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99 = 0 THEN @old_isauto_v99mpositiontaking_20 ELSE @isauto_v99mpositiontaking_20 END,	

	-- mixed sports
	@isauto_v99mpositiontaking_9 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv99mp = 0 THEN @old_isauto_v99mpositiontaking_9 ELSE @isauto_v99mpositiontaking_9 END,
	@isauto_v154mpositiontaking_20 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv154 = 0 THEN @old_isauto_v154mpositiontaking_20 ELSE @isauto_v154mpositiontaking_20 END,	
	
	--number game
	@isauto_v161mpositiontaking_81 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mpositiontaking_81 ELSE @isauto_v161mpositiontaking_81 END,
	@isauto_v161mpositiontaking_83 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mpositiontaking_83 ELSE @isauto_v161mpositiontaking_83 END,
	--@isauto_v161mpositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mpositiontaking_85 ELSE @isauto_v161mpositiontaking_85 END,
	@isauto_v161mpositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mpositiontaking_86 ELSE @isauto_v161mpositiontaking_86 END,
	@isauto_v161mpositiontaking_88 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mpositiontaking_88 ELSE @isauto_v161mpositiontaking_88 END,
	
	@isauto_v161mlivepositiontaking_85 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mlivepositiontaking_85 ELSE @isauto_v161mlivepositiontaking_85 END,
	@isauto_v161mlivepositiontaking_86 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mlivepositiontaking_86 ELSE @isauto_v161mlivepositiontaking_86 END,
	@isauto_v161mlivepositiontaking_87 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mlivepositiontaking_87 ELSE @isauto_v161mlivepositiontaking_87 END,
	@isauto_v161mlivepositiontaking_89 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mlivepositiontaking_89 ELSE @isauto_v161mlivepositiontaking_89 END,
	@isauto_v161mlivepositiontaking_90 = CASE WHEN @UpdateMultiple = 1 AND @UpdatePositiontakingv161 = 0 THEN @old_isauto_v161mlivepositiontaking_90 ELSE @isauto_v161mlivepositiontaking_90 END
-----------------------------------------------

Select @LogSPData ='<Acc_CustomerUpdAgent_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'v2apt_10="'+ coalesce(cast(@v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3apt_10="'+ coalesce(cast(@v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5apt_10="'+ coalesce(cast(@v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8apt_10="'+ coalesce(cast(@v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10apt_10="'+ coalesce(cast(@v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11apt_10="'+ coalesce(cast(@v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99apt_10="'+ coalesce(cast(@v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +

'apt_9999="'+ coalesce(cast(@apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2apt_1="'+ coalesce(cast(@v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2apt_2="'+ coalesce(cast(@v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2apt_3="'+ coalesce(cast(@v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2apt_7="'+ coalesce(cast(@v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2apt_8="'+ coalesce(cast(@v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2apt_20="'+ coalesce(cast(@v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3apt_1="'+ coalesce(cast(@v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3apt_2="'+ coalesce(cast(@v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3apt_3="'+ coalesce(cast(@v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3apt_20="'+ coalesce(cast(@v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5apt_1="'+ coalesce(cast(@v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5apt_2="'+ coalesce(cast(@v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5apt_3="'+ coalesce(cast(@v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5apt_20="'+ coalesce(cast(@v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5apt_9999="'+ coalesce(cast(@v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10apt_1="'+ coalesce(cast(@v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10apt_2="'+ coalesce(cast(@v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10apt_3="'+ coalesce(cast(@v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10apt_20="'+ coalesce(cast(@v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11apt_1="'+ coalesce(cast(@v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11apt_20="'+ coalesce(cast(@v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99apt_1="'+ coalesce(cast(@v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99apt_2="'+ coalesce(cast(@v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99apt_3="'+ coalesce(cast(@v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
--- mixed sports
'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v154apt_20="'+ coalesce(cast(@v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +

--mixed sports
'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports
'v2mpt_10="'+ coalesce(cast(@v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3mpt_10="'+ coalesce(cast(@v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5mpt_10="'+ coalesce(cast(@v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8mpt_10="'+ coalesce(cast(@v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10mpt_10="'+ coalesce(cast(@v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11mpt_10="'+ coalesce(cast(@v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99mpt_10="'+ coalesce(cast(@v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'mpt_9999="'+ coalesce(cast(@mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2mpt_1="'+ coalesce(cast(@v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2mpt_2="'+ coalesce(cast(@v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2mpt_3="'+ coalesce(cast(@v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2mpt_7="'+ coalesce(cast(@v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2mpt_8="'+ coalesce(cast(@v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v2mpt_20="'+ coalesce(cast(@v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3mpt_1="'+ coalesce(cast(@v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3mpt_2="'+ coalesce(cast(@v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3mpt_3="'+ coalesce(cast(@v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3mpt_20="'+ coalesce(cast(@v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5mpt_1="'+ coalesce(cast(@v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5mpt_2="'+ coalesce(cast(@v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5mpt_3="'+ coalesce(cast(@v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5mpt_20="'+ coalesce(cast(@v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5mpt_9999="'+ coalesce(cast(@v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10mpt_1="'+ coalesce(cast(@v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10mpt_2="'+ coalesce(cast(@v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10mpt_3="'+ coalesce(cast(@v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10mpt_20="'+ coalesce(cast(@v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11mpt_1="'+ coalesce(cast(@v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11mpt_20="'+ coalesce(cast(@v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99mpt_1="'+ coalesce(cast(@v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99mpt_2="'+ coalesce(cast(@v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99mpt_3="'+ coalesce(cast(@v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- mixed sports
'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v154mpt_20="'+ coalesce(cast(@v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--number game
'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

--auto v1
'<aum a_mpt_1="'+ coalesce(cast(@auto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_mpt_2="'+ coalesce(cast(@auto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_mpt_3="'+ coalesce(cast(@auto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_mpt_4="'+ coalesce(cast(@auto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_mpt_5="'+ coalesce(cast(@auto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_mpt_6="'+ coalesce(cast(@auto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_mpt_7="'+ coalesce(cast(@auto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_mpt_8="'+ coalesce(cast(@auto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_mpt_9="'+ coalesce(cast(@auto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_mpt_10="'+ coalesce(cast(@auto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
--  Outright PT for sports
'a_v2mpt_10="'+ coalesce(cast(@auto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_10="'+ coalesce(cast(@auto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_10="'+ coalesce(cast(@auto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_10="'+ coalesce(cast(@auto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_10="'+ coalesce(cast(@auto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v11mpt_10="'+ coalesce(cast(@auto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_10="'+ coalesce(cast(@auto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'a_mpt_9999="'+ coalesce(cast(@auto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'a_mlivept_1="'+ coalesce(cast(@auto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_mlivept_3="'+ coalesce(cast(@auto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_mlivept_7="'+ coalesce(cast(@auto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_mlivept_8="'+ coalesce(cast(@auto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--auto v2
'a_v2mpt_1="'+ coalesce(cast(@auto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_2="'+ coalesce(cast(@auto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_3="'+ coalesce(cast(@auto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_7="'+ coalesce(cast(@auto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_8="'+ coalesce(cast(@auto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'a_v2mpt_9="'+ coalesce(cast(@auto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_20="'+ coalesce(cast(@auto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v3
'a_v3mpt_1="'+ coalesce(cast(@auto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_2="'+ coalesce(cast(@auto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_3="'+ coalesce(cast(@auto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_20="'+ coalesce(cast(@auto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v5
'a_v5mpt_1="'+ coalesce(cast(@auto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_2="'+ coalesce(cast(@auto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_3="'+ coalesce(cast(@auto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_20="'+ coalesce(cast(@auto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_9999="'+ coalesce(cast(@auto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

--auto v8
'a_v8mpt_1="'+ coalesce(cast(@auto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_3="'+ coalesce(cast(@auto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_20="'+ coalesce(cast(@auto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v10
'a_v10mpt_1="'+ coalesce(cast(@auto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_2="'+ coalesce(cast(@auto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_3="'+ coalesce(cast(@auto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_20="'+ coalesce(cast(@auto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v11
'a_v11mpt_1="'+ coalesce(cast(@auto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v11mpt_20="'+ coalesce(cast(@auto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v99
'a_v99mpt_1="'+ coalesce(cast(@auto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_2="'+ coalesce(cast(@auto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_3="'+ coalesce(cast(@auto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_20="'+ coalesce(cast(@auto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
---mixed sports
'a_v99mpt_9="'+ coalesce(cast(@auto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v154mpt_20="'+ coalesce(cast(@auto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

-- number game
'a_v161mpt_81="'+ coalesce(cast(@auto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_83="'+ coalesce(cast(@auto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'a_v161mpt_85="'+ coalesce(cast(@auto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_86="'+ coalesce(cast(@auto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_88="'+ coalesce(cast(@auto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'a_v161mlivept_85="'+ coalesce(cast(@auto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_86="'+ coalesce(cast(@auto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_87="'+ coalesce(cast(@auto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_89="'+ coalesce(cast(@auto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_90="'+ coalesce(cast(@auto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

--isauto v1
'<iam isa_mpt_1="'+ coalesce(cast(@isauto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_mpt_2="'+ coalesce(cast(@isauto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_mpt_3="'+ coalesce(cast(@isauto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_mpt_4="'+ coalesce(cast(@isauto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_mpt_5="'+ coalesce(cast(@isauto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_mpt_6="'+ coalesce(cast(@isauto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_mpt_7="'+ coalesce(cast(@isauto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_mpt_8="'+ coalesce(cast(@isauto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_mpt_9="'+ coalesce(cast(@isauto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_mpt_10="'+ coalesce(cast(@isauto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'isa_v2mpt_10="'+ coalesce(cast(@isauto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_10="'+ coalesce(cast(@isauto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_10="'+ coalesce(cast(@isauto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_10="'+ coalesce(cast(@isauto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_10="'+ coalesce(cast(@isauto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v11mpt_10="'+ coalesce(cast(@isauto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_10="'+ coalesce(cast(@isauto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'isa_mpt_9999="'+ coalesce(cast(@isauto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_1="'+ coalesce(cast(@isauto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_3="'+ coalesce(cast(@isauto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_7="'+ coalesce(cast(@isauto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_8="'+ coalesce(cast(@isauto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--isauto v2
'isa_v2mpt_1="'+ coalesce(cast(@isauto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_2="'+ coalesce(cast(@isauto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_3="'+ coalesce(cast(@isauto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_7="'+ coalesce(cast(@isauto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_8="'+ coalesce(cast(@isauto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
--'isa_v2mpt_9="'+ coalesce(cast(@isauto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_20="'+ coalesce(cast(@isauto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v3
'isa_v3mpt_1="'+ coalesce(cast(@isauto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_2="'+ coalesce(cast(@isauto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_3="'+ coalesce(cast(@isauto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_20="'+ coalesce(cast(@isauto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v5
'isa_v5mpt_1="'+ coalesce(cast(@isauto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_2="'+ coalesce(cast(@isauto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_3="'+ coalesce(cast(@isauto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_20="'+ coalesce(cast(@isauto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_9999="'+ coalesce(cast(@isauto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

--isauto v8
'isa_v8mpt_1="'+ coalesce(cast(@isauto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_3="'+ coalesce(cast(@isauto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_20="'+ coalesce(cast(@isauto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v10
'isa_v10mpt_1="'+ coalesce(cast(@isauto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_2="'+ coalesce(cast(@isauto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_3="'+ coalesce(cast(@isauto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_20="'+ coalesce(cast(@isauto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v11
'isa_v11mpt_1="'+ coalesce(cast(@isauto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v11mpt_20="'+ coalesce(cast(@isauto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
--isauto v99
'isa_v99mpt_1="'+ coalesce(cast(@isauto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_2="'+ coalesce(cast(@isauto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_3="'+ coalesce(cast(@isauto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_20="'+ coalesce(cast(@isauto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--mixed sports
'isa_v99mpt_9="'+ coalesce(cast(@isauto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_v154mpt_20="'+ coalesce(cast(@isauto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

-- number game
'isa_v161mpt_81="'+ coalesce(cast(@isauto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_83="'+ coalesce(cast(@isauto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'isa_v161mpt_85="'+ coalesce(cast(@isauto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_86="'+ coalesce(cast(@isauto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_88="'+ coalesce(cast(@isauto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'isa_v161mlivept_85="'+ coalesce(cast(@isauto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_86="'+ coalesce(cast(@isauto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_87="'+ coalesce(cast(@isauto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_89="'+ coalesce(cast(@isauto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_90="'+ coalesce(cast(@isauto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdAgent_PositionTaking>'


Select @TrackingValue2 ='<Acc_CustomerUpdAgent_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +

'<ag apt_1="'+ coalesce(cast(@Old_apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'apt_2="'+ coalesce(cast(@Old_apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'apt_3="'+ coalesce(cast(@Old_apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'apt_4="'+ coalesce(cast(@Old_apositiontaking_4 as varchar(50)),space(1)) + '" ' +
'apt_5="'+ coalesce(cast(@Old_apositiontaking_5 as varchar(50)),space(1)) + '" ' +
'apt_6="'+ coalesce(cast(@Old_apositiontaking_6 as varchar(50)),space(1)) + '" ' +
'apt_7="'+ coalesce(cast(@Old_apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'apt_8="'+ coalesce(cast(@Old_apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'apt_9="'+ coalesce(cast(@Old_apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'apt_10="'+ coalesce(cast(@Old_apositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'v2apt_10="'+ coalesce(cast(@Old_v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3apt_10="'+ coalesce(cast(@Old_v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5apt_10="'+ coalesce(cast(@Old_v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8apt_10="'+ coalesce(cast(@Old_v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10apt_10="'+ coalesce(cast(@Old_v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11apt_10="'+ coalesce(cast(@Old_v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99apt_10="'+ coalesce(cast(@Old_v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +

'apt_9999="'+ coalesce(cast(@Old_apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'alivept_1="'+ coalesce(cast(@Old_alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'alivept_3="'+ coalesce(cast(@Old_alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'alivept_7="'+ coalesce(cast(@Old_alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'alivept_8="'+ coalesce(cast(@Old_alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2apt_1="'+ coalesce(cast(@Old_v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2apt_2="'+ coalesce(cast(@Old_v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2apt_3="'+ coalesce(cast(@Old_v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2apt_7="'+ coalesce(cast(@Old_v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2apt_8="'+ coalesce(cast(@Old_v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
'v2apt_20="'+ coalesce(cast(@Old_v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3apt_1="'+ coalesce(cast(@Old_v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3apt_2="'+ coalesce(cast(@Old_v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3apt_3="'+ coalesce(cast(@Old_v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3apt_20="'+ coalesce(cast(@Old_v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5apt_1="'+ coalesce(cast(@Old_v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5apt_2="'+ coalesce(cast(@Old_v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5apt_3="'+ coalesce(cast(@Old_v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5apt_20="'+ coalesce(cast(@Old_v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5apt_9999="'+ coalesce(cast(@Old_v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8apt_1="'+ coalesce(cast(@Old_v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8apt_3="'+ coalesce(cast(@Old_v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8apt_20="'+ coalesce(cast(@Old_v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10apt_1="'+ coalesce(cast(@Old_v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10apt_2="'+ coalesce(cast(@Old_v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10apt_3="'+ coalesce(cast(@Old_v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10apt_20="'+ coalesce(cast(@Old_v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11apt_1="'+ coalesce(cast(@Old_v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11apt_20="'+ coalesce(cast(@Old_v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99apt_1="'+ coalesce(cast(@Old_v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99apt_2="'+ coalesce(cast(@Old_v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99apt_3="'+ coalesce(cast(@Old_v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99apt_20="'+ coalesce(cast(@Old_v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
--- mixed sports
'v99apt_9="'+ coalesce(cast(@Old_v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v154apt_20="'+ coalesce(cast(@Old_v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v161apt_81="'+ coalesce(cast(@Old_v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161apt_83="'+ coalesce(cast(@Old_v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161apt_85="'+ coalesce(cast(@Old_v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161apt_86="'+ coalesce(cast(@Old_v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161apt_88="'+ coalesce(cast(@Old_v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161alivept_85="'+ coalesce(cast(@Old_v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161alivept_86="'+ coalesce(cast(@Old_v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161alivept_87="'+ coalesce(cast(@Old_v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
'v161alivept_89="'+ coalesce(cast(@Old_v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161alivept_90="'+ coalesce(cast(@Old_v161alivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

'<m mpt_1="'+ coalesce(cast(@Old_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mpt_2="'+ coalesce(cast(@Old_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'mpt_3="'+ coalesce(cast(@Old_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mpt_4="'+ coalesce(cast(@Old_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'mpt_5="'+ coalesce(cast(@Old_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'mpt_6="'+ coalesce(cast(@Old_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'mpt_7="'+ coalesce(cast(@Old_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mpt_8="'+ coalesce(cast(@Old_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'mpt_9="'+ coalesce(cast(@Old_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'mpt_10="'+ coalesce(cast(@Old_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'v2mpt_10="'+ coalesce(cast(@Old_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v3mpt_10="'+ coalesce(cast(@Old_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v5mpt_10="'+ coalesce(cast(@Old_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v8mpt_10="'+ coalesce(cast(@Old_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v10mpt_10="'+ coalesce(cast(@Old_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v11mpt_10="'+ coalesce(cast(@Old_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'v99mpt_10="'+ coalesce(cast(@Old_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'mpt_9999="'+ coalesce(cast(@Old_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'mlivept_1="'+ coalesce(cast(@Old_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'mlivept_3="'+ coalesce(cast(@Old_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'mlivept_7="'+ coalesce(cast(@Old_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'mlivept_8="'+ coalesce(cast(@Old_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

'v2mpt_1="'+ coalesce(cast(@Old_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v2mpt_2="'+ coalesce(cast(@Old_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v2mpt_3="'+ coalesce(cast(@Old_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v2mpt_7="'+ coalesce(cast(@Old_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'v2mpt_8="'+ coalesce(cast(@Old_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'v2mpt_20="'+ coalesce(cast(@Old_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v3mpt_1="'+ coalesce(cast(@Old_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v3mpt_2="'+ coalesce(cast(@Old_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v3mpt_3="'+ coalesce(cast(@Old_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v3mpt_20="'+ coalesce(cast(@Old_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v5mpt_1="'+ coalesce(cast(@Old_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v5mpt_2="'+ coalesce(cast(@Old_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v5mpt_3="'+ coalesce(cast(@Old_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v5mpt_20="'+ coalesce(cast(@Old_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'v5mpt_9999="'+ coalesce(cast(@Old_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

'v8mpt_1="'+ coalesce(cast(@Old_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v8mpt_3="'+ coalesce(cast(@Old_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v8mpt_20="'+ coalesce(cast(@Old_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v10mpt_1="'+ coalesce(cast(@Old_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v10mpt_2="'+ coalesce(cast(@Old_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v10mpt_3="'+ coalesce(cast(@Old_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v10mpt_20="'+ coalesce(cast(@Old_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v11mpt_1="'+ coalesce(cast(@Old_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v11mpt_20="'+ coalesce(cast(@Old_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

'v99mpt_1="'+ coalesce(cast(@Old_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'v99mpt_2="'+ coalesce(cast(@Old_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'v99mpt_3="'+ coalesce(cast(@Old_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'v99mpt_20="'+ coalesce(cast(@Old_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
-- mixed sports
'v99mpt_9="'+ coalesce(cast(@Old_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'v154mpt_20="'+ coalesce(cast(@Old_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--number game
'v161mpt_81="'+ coalesce(cast(@Old_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'v161mpt_83="'+ coalesce(cast(@Old_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'v161mpt_85="'+ coalesce(cast(@Old_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mpt_86="'+ coalesce(cast(@Old_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mpt_88="'+ coalesce(cast(@Old_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'v161mlivept_85="'+ coalesce(cast(@Old_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'v161mlivept_86="'+ coalesce(cast(@Old_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'v161mlivept_87="'+ coalesce(cast(@Old_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'v161mlivept_89="'+ coalesce(cast(@Old_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'v161mlivept_90="'+ coalesce(cast(@Old_v161mlivepositiontaking_90 as varchar(50)),space(1)) +'" />' +

--auto v1
'<aum a_mpt_1="'+ coalesce(cast(@Old_auto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_mpt_2="'+ coalesce(cast(@Old_auto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_mpt_3="'+ coalesce(cast(@Old_auto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_mpt_4="'+ coalesce(cast(@Old_auto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'a_mpt_5="'+ coalesce(cast(@Old_auto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'a_mpt_6="'+ coalesce(cast(@Old_auto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'a_mpt_7="'+ coalesce(cast(@Old_auto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_mpt_8="'+ coalesce(cast(@Old_auto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_mpt_9="'+ coalesce(cast(@Old_auto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_mpt_10="'+ coalesce(cast(@Old_auto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

-- Outright PT for sports

'a_v2mpt_10="'+ coalesce(cast(@Old_auto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_10="'+ coalesce(cast(@Old_auto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_10="'+ coalesce(cast(@Old_auto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_10="'+ coalesce(cast(@Old_auto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_10="'+ coalesce(cast(@Old_auto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v11mpt_10="'+ coalesce(cast(@Old_auto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_10="'+ coalesce(cast(@Old_auto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'a_mpt_9999="'+ coalesce(cast(@Old_auto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'a_mlivept_1="'+ coalesce(cast(@Old_auto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_mlivept_3="'+ coalesce(cast(@Old_auto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_mlivept_7="'+ coalesce(cast(@Old_auto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_mlivept_8="'+ coalesce(cast(@Old_auto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--auto v2
'a_v2mpt_1="'+ coalesce(cast(@Old_auto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_2="'+ coalesce(cast(@Old_auto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_3="'+ coalesce(cast(@Old_auto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_7="'+ coalesce(cast(@Old_auto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_8="'+ coalesce(cast(@Old_auto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'a_v2mpt_20="'+ coalesce(cast(@Old_auto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v3
'a_v3mpt_1="'+ coalesce(cast(@Old_auto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_2="'+ coalesce(cast(@Old_auto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_3="'+ coalesce(cast(@Old_auto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v3mpt_20="'+ coalesce(cast(@Old_auto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v5
'a_v5mpt_1="'+ coalesce(cast(@Old_auto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_2="'+ coalesce(cast(@Old_auto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_3="'+ coalesce(cast(@Old_auto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_20="'+ coalesce(cast(@Old_auto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'a_v5mpt_9999="'+ coalesce(cast(@Old_auto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

--auto v8
'a_v8mpt_1="'+ coalesce(cast(@Old_auto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_3="'+ coalesce(cast(@Old_auto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v8mpt_20="'+ coalesce(cast(@Old_auto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v10
'a_v10mpt_1="'+ coalesce(cast(@Old_auto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_2="'+ coalesce(cast(@Old_auto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_3="'+ coalesce(cast(@Old_auto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v10mpt_20="'+ coalesce(cast(@Old_auto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v11
'a_v11mpt_1="'+ coalesce(cast(@Old_auto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v11mpt_20="'+ coalesce(cast(@Old_auto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--auto v99
'a_v99mpt_1="'+ coalesce(cast(@Old_auto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_2="'+ coalesce(cast(@Old_auto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_3="'+ coalesce(cast(@Old_auto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'a_v99mpt_20="'+ coalesce(cast(@Old_auto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
---mixed sports
'a_v99mpt_9="'+ coalesce(cast(@Old_auto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'a_v154mpt_20="'+ coalesce(cast(@Old_auto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

-- number game
'a_v161mpt_81="'+ coalesce(cast(@Old_auto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_83="'+ coalesce(cast(@Old_auto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'a_v161mpt_85="'+ coalesce(cast(@Old_auto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_86="'+ coalesce(cast(@Old_auto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161mpt_88="'+ coalesce(cast(@Old_auto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'a_v161mlivept_85="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_86="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_87="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_89="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'a_v161mlivept_90="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

--isauto v1
'<iam isa_mpt_1="'+ coalesce(cast(@Old_isauto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_mpt_2="'+ coalesce(cast(@Old_isauto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_mpt_3="'+ coalesce(cast(@Old_isauto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_mpt_4="'+ coalesce(cast(@Old_isauto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
'isa_mpt_5="'+ coalesce(cast(@Old_isauto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
'isa_mpt_6="'+ coalesce(cast(@Old_isauto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
'isa_mpt_7="'+ coalesce(cast(@Old_isauto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_mpt_8="'+ coalesce(cast(@Old_isauto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_mpt_9="'+ coalesce(cast(@Old_isauto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_mpt_10="'+ coalesce(cast(@Old_isauto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
-- Outright PT for sports
'isa_v2mpt_10="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_10="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_10="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_10="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_10="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v11mpt_10="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_10="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +

'isa_mpt_9999="'+ coalesce(cast(@Old_isauto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_1="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_3="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_7="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_mlivept_8="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

--isauto v2
'isa_v2mpt_1="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_2="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_3="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_7="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_8="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
'isa_v2mpt_20="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v3
'isa_v3mpt_1="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_2="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_3="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v3mpt_20="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v5
'isa_v5mpt_1="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_2="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_3="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_20="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
'isa_v5mpt_9999="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

--isauto v8
'isa_v8mpt_1="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_3="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v8mpt_20="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v10
'isa_v10mpt_1="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_2="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_3="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v10mpt_20="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--isauto v11
'isa_v11mpt_1="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v11mpt_20="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
--isauto v99
'isa_v99mpt_1="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_2="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_3="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
'isa_v99mpt_20="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

--mixed sports
'isa_v99mpt_9="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
'isa_v154mpt_20="'+ coalesce(cast(@Old_isauto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

-- number game
'isa_v161mpt_81="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_83="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
--'isa_v161mpt_85="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_86="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161mpt_88="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

'isa_v161mlivept_85="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_86="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_87="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_89="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
'isa_v161mlivept_90="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdAgent_PositionTaking>'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
	--Log positiontaking
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 412,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH

	Select @LogSPData ='<Acc_CustomerUpdAgent_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
	'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
	'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
	'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
	'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
	'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
	'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
	'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
	'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
	'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +
	'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1)) + '" />' +

	'<ag apt_1="'+ coalesce(cast(@apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'apt_2="'+ coalesce(cast(@apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'apt_3="'+ coalesce(cast(@apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'apt_4="'+ coalesce(cast(@apositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'apt_5="'+ coalesce(cast(@apositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'apt_6="'+ coalesce(cast(@apositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'apt_7="'+ coalesce(cast(@apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'apt_8="'+ coalesce(cast(@apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'apt_9="'+ coalesce(cast(@apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'apt_10="'+ coalesce(cast(@apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'v2apt_10="'+ coalesce(cast(@v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v3apt_10="'+ coalesce(cast(@v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v5apt_10="'+ coalesce(cast(@v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v8apt_10="'+ coalesce(cast(@v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v10apt_10="'+ coalesce(cast(@v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v11apt_10="'+ coalesce(cast(@v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v99apt_10="'+ coalesce(cast(@v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'apt_9999="'+ coalesce(cast(@apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'alivept_1="'+ coalesce(cast(@alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'alivept_3="'+ coalesce(cast(@alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'alivept_7="'+ coalesce(cast(@alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'alivept_8="'+ coalesce(cast(@alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2apt_1="'+ coalesce(cast(@v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2apt_2="'+ coalesce(cast(@v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2apt_3="'+ coalesce(cast(@v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2apt_7="'+ coalesce(cast(@v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2apt_8="'+ coalesce(cast(@v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'v2apt_9="'+ coalesce(cast(@v2apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2apt_20="'+ coalesce(cast(@v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3apt_1="'+ coalesce(cast(@v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3apt_2="'+ coalesce(cast(@v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3apt_3="'+ coalesce(cast(@v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3apt_20="'+ coalesce(cast(@v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5apt_1="'+ coalesce(cast(@v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5apt_2="'+ coalesce(cast(@v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5apt_3="'+ coalesce(cast(@v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5apt_20="'+ coalesce(cast(@v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v5apt_9999="'+ coalesce(cast(@v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	'v8apt_1="'+ coalesce(cast(@v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8apt_3="'+ coalesce(cast(@v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8apt_20="'+ coalesce(cast(@v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10apt_1="'+ coalesce(cast(@v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10apt_2="'+ coalesce(cast(@v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10apt_3="'+ coalesce(cast(@v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10apt_20="'+ coalesce(cast(@v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11apt_1="'+ coalesce(cast(@v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11apt_20="'+ coalesce(cast(@v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99apt_1="'+ coalesce(cast(@v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99apt_2="'+ coalesce(cast(@v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99apt_3="'+ coalesce(cast(@v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99apt_20="'+ coalesce(cast(@v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	--- mixed sports
	'v99apt_9="'+ coalesce(cast(@v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v154apt_20="'+ coalesce(cast(@v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	--mixed sports
	'v161apt_81="'+ coalesce(cast(@v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161apt_83="'+ coalesce(cast(@v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'v161apt_85="'+ coalesce(cast(@v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161apt_86="'+ coalesce(cast(@v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161apt_88="'+ coalesce(cast(@v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'v161alivept_85="'+ coalesce(cast(@v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161alivept_86="'+ coalesce(cast(@v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161alivept_87="'+ coalesce(cast(@v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161alivept_89="'+ coalesce(cast(@v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161alivept_90="'+ coalesce(cast(@v161alivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	'<m mpt_1="'+ coalesce(cast(@mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'mpt_2="'+ coalesce(cast(@mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'mpt_3="'+ coalesce(cast(@mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'mpt_4="'+ coalesce(cast(@mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'mpt_5="'+ coalesce(cast(@mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'mpt_6="'+ coalesce(cast(@mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'mpt_7="'+ coalesce(cast(@mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'mpt_8="'+ coalesce(cast(@mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'mpt_9="'+ coalesce(cast(@mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'mpt_10="'+ coalesce(cast(@mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	-- Outright PT for sports
	'v2mpt_10="'+ coalesce(cast(@v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v3mpt_10="'+ coalesce(cast(@v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v5mpt_10="'+ coalesce(cast(@v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v8mpt_10="'+ coalesce(cast(@v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v10mpt_10="'+ coalesce(cast(@v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v11mpt_10="'+ coalesce(cast(@v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v99mpt_10="'+ coalesce(cast(@v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'mpt_9999="'+ coalesce(cast(@mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'mlivept_1="'+ coalesce(cast(@mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'mlivept_3="'+ coalesce(cast(@mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'mlivept_7="'+ coalesce(cast(@mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'mlivept_8="'+ coalesce(cast(@mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2mpt_1="'+ coalesce(cast(@v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2mpt_2="'+ coalesce(cast(@v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2mpt_3="'+ coalesce(cast(@v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2mpt_7="'+ coalesce(cast(@v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2mpt_8="'+ coalesce(cast(@v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'v2mpt_9="'+ coalesce(cast(@v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v2mpt_20="'+ coalesce(cast(@v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3mpt_1="'+ coalesce(cast(@v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3mpt_2="'+ coalesce(cast(@v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3mpt_3="'+ coalesce(cast(@v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3mpt_20="'+ coalesce(cast(@v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5mpt_1="'+ coalesce(cast(@v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5mpt_2="'+ coalesce(cast(@v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5mpt_3="'+ coalesce(cast(@v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5mpt_20="'+ coalesce(cast(@v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v5mpt_9999="'+ coalesce(cast(@v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	'v8mpt_1="'+ coalesce(cast(@v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8mpt_3="'+ coalesce(cast(@v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8mpt_20="'+ coalesce(cast(@v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10mpt_1="'+ coalesce(cast(@v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10mpt_2="'+ coalesce(cast(@v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10mpt_3="'+ coalesce(cast(@v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10mpt_20="'+ coalesce(cast(@v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11mpt_1="'+ coalesce(cast(@v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11mpt_20="'+ coalesce(cast(@v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99mpt_1="'+ coalesce(cast(@v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99mpt_2="'+ coalesce(cast(@v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99mpt_3="'+ coalesce(cast(@v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99mpt_20="'+ coalesce(cast(@v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'v99mpt_9="'+ coalesce(cast(@v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v154mpt_20="'+ coalesce(cast(@v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--number game
	'v161mpt_81="'+ coalesce(cast(@v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161mpt_83="'+ coalesce(cast(@v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'v161mpt_85="'+ coalesce(cast(@v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mpt_86="'+ coalesce(cast(@v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161mpt_88="'+ coalesce(cast(@v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'v161mlivept_85="'+ coalesce(cast(@v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_86="'+ coalesce(cast(@v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_87="'+ coalesce(cast(@v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_89="'+ coalesce(cast(@v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_90="'+ coalesce(cast(@v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	--auto v1
	'<aum a_mpt_1="'+ coalesce(cast(@auto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_mpt_2="'+ coalesce(cast(@auto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_mpt_3="'+ coalesce(cast(@auto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_mpt_4="'+ coalesce(cast(@auto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'a_mpt_5="'+ coalesce(cast(@auto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'a_mpt_6="'+ coalesce(cast(@auto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'a_mpt_7="'+ coalesce(cast(@auto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_mpt_8="'+ coalesce(cast(@auto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'a_mpt_9="'+ coalesce(cast(@auto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_mpt_10="'+ coalesce(cast(@auto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'a_v2mpt_10="'+ coalesce(cast(@auto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_10="'+ coalesce(cast(@auto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_10="'+ coalesce(cast(@auto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_10="'+ coalesce(cast(@auto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_10="'+ coalesce(cast(@auto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v11mpt_10="'+ coalesce(cast(@auto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_10="'+ coalesce(cast(@auto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'a_mpt_9999="'+ coalesce(cast(@auto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_1="'+ coalesce(cast(@auto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_3="'+ coalesce(cast(@auto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_7="'+ coalesce(cast(@auto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_8="'+ coalesce(cast(@auto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	--auto v2
	'a_v2mpt_1="'+ coalesce(cast(@auto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_2="'+ coalesce(cast(@auto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_3="'+ coalesce(cast(@auto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_7="'+ coalesce(cast(@auto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_8="'+ coalesce(cast(@auto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'a_v2mpt_9="'+ coalesce(cast(@auto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_20="'+ coalesce(cast(@auto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v3
	'a_v3mpt_1="'+ coalesce(cast(@auto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_2="'+ coalesce(cast(@auto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_3="'+ coalesce(cast(@auto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_20="'+ coalesce(cast(@auto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v5
	'a_v5mpt_1="'+ coalesce(cast(@auto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_2="'+ coalesce(cast(@auto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_3="'+ coalesce(cast(@auto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_20="'+ coalesce(cast(@auto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_9999="'+ coalesce(cast(@auto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	--auto v8
	'a_v8mpt_1="'+ coalesce(cast(@auto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_3="'+ coalesce(cast(@auto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_20="'+ coalesce(cast(@auto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v10
	'a_v10mpt_1="'+ coalesce(cast(@auto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_2="'+ coalesce(cast(@auto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_3="'+ coalesce(cast(@auto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_20="'+ coalesce(cast(@auto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v11
	'a_v11mpt_1="'+ coalesce(cast(@auto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v11mpt_20="'+ coalesce(cast(@auto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v99
	'a_v99mpt_1="'+ coalesce(cast(@auto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_2="'+ coalesce(cast(@auto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_3="'+ coalesce(cast(@auto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_20="'+ coalesce(cast(@auto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	---mixed sports
	'a_v99mpt_9="'+ coalesce(cast(@auto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_v154mpt_20="'+ coalesce(cast(@auto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	-- number game
	'a_v161mpt_81="'+ coalesce(cast(@auto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_83="'+ coalesce(cast(@auto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'a_v161mpt_85="'+ coalesce(cast(@auto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_86="'+ coalesce(cast(@auto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_88="'+ coalesce(cast(@auto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'a_v161mlivept_85="'+ coalesce(cast(@auto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_86="'+ coalesce(cast(@auto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_87="'+ coalesce(cast(@auto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_89="'+ coalesce(cast(@auto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_90="'+ coalesce(cast(@auto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	--isauto v1
	'<iam isa_mpt_1="'+ coalesce(cast(@isauto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_2="'+ coalesce(cast(@isauto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_3="'+ coalesce(cast(@isauto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_4="'+ coalesce(cast(@isauto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_5="'+ coalesce(cast(@isauto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_6="'+ coalesce(cast(@isauto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_7="'+ coalesce(cast(@isauto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_8="'+ coalesce(cast(@isauto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_9="'+ coalesce(cast(@isauto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_10="'+ coalesce(cast(@isauto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'isa_v2mpt_10="'+ coalesce(cast(@isauto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_10="'+ coalesce(cast(@isauto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_10="'+ coalesce(cast(@isauto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_10="'+ coalesce(cast(@isauto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_10="'+ coalesce(cast(@isauto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v11mpt_10="'+ coalesce(cast(@isauto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_10="'+ coalesce(cast(@isauto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'isa_mpt_9999="'+ coalesce(cast(@isauto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_1="'+ coalesce(cast(@isauto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_3="'+ coalesce(cast(@isauto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_7="'+ coalesce(cast(@isauto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_8="'+ coalesce(cast(@isauto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	--isauto v2
	'isa_v2mpt_1="'+ coalesce(cast(@isauto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_2="'+ coalesce(cast(@isauto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_3="'+ coalesce(cast(@isauto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_7="'+ coalesce(cast(@isauto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_8="'+ coalesce(cast(@isauto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	--'isa_v2mpt_9="'+ coalesce(cast(@isauto_v2mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_20="'+ coalesce(cast(@isauto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v3
	'isa_v3mpt_1="'+ coalesce(cast(@isauto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_2="'+ coalesce(cast(@isauto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_3="'+ coalesce(cast(@isauto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_20="'+ coalesce(cast(@isauto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v5
	'isa_v5mpt_1="'+ coalesce(cast(@isauto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_2="'+ coalesce(cast(@isauto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_3="'+ coalesce(cast(@isauto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_20="'+ coalesce(cast(@isauto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_9999="'+ coalesce(cast(@isauto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	--isauto v8
	'isa_v8mpt_1="'+ coalesce(cast(@isauto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_3="'+ coalesce(cast(@isauto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_20="'+ coalesce(cast(@isauto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v10
	'isa_v10mpt_1="'+ coalesce(cast(@isauto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_2="'+ coalesce(cast(@isauto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_3="'+ coalesce(cast(@isauto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_20="'+ coalesce(cast(@isauto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v11
	'isa_v11mpt_1="'+ coalesce(cast(@isauto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v11mpt_20="'+ coalesce(cast(@isauto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	--isauto v99
	'isa_v99mpt_1="'+ coalesce(cast(@isauto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_2="'+ coalesce(cast(@isauto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_3="'+ coalesce(cast(@isauto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_20="'+ coalesce(cast(@isauto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--mixed sports
	'isa_v99mpt_9="'+ coalesce(cast(@isauto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_v154mpt_20="'+ coalesce(cast(@isauto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	-- number game
	'isa_v161mpt_81="'+ coalesce(cast(@isauto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_83="'+ coalesce(cast(@isauto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'isa_v161mpt_85="'+ coalesce(cast(@isauto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_86="'+ coalesce(cast(@isauto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_88="'+ coalesce(cast(@isauto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'isa_v161mlivept_85="'+ coalesce(cast(@isauto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_86="'+ coalesce(cast(@isauto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_87="'+ coalesce(cast(@isauto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_89="'+ coalesce(cast(@isauto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_90="'+ coalesce(cast(@isauto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdAgent_PositionTaking>'


	Select @TrackingValue2 ='<Acc_CustomerUpdAgent_PositionTaking><info UpdMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(50)),space(1)) + '" ' +
	'Updpt="'+ coalesce(cast(@UpdatePositiontaking as varchar(50)),space(1)) + '" ' +
	'Updptv2="'+ coalesce(cast(@UpdatePositiontakingv2 as varchar(50)),space(1)) + '" ' +
	'Updptv3="'+ coalesce(cast(@UpdatePositiontakingv3 as varchar(50)),space(1)) + '" ' +
	'Updptv5="'+ coalesce(cast(@UpdatePositiontakingv5 as varchar(50)),space(1)) + '" ' +
	'Updptv8="'+ coalesce(cast(@UpdatePositiontakingv8 as varchar(50)),space(1)) + '" ' +
	'Updptv10="'+ coalesce(cast(@UpdatePositiontakingv10 as varchar(50)),space(1)) + '" ' +
	'Updptv11="'+ coalesce(cast(@UpdatePositiontakingv11 as varchar(50)),space(1)) + '" ' +
	'Updptv99="'+ coalesce(cast(@UpdatePositiontakingv99 as varchar(50)),space(1)) + '" ' +
	'Updptv99MP="'+ coalesce(cast(@UpdatePositiontakingv99MP as varchar(50)),space(1)) + '" ' +
	'Updptv154="'+ coalesce(cast(@UpdatePositiontakingv154 as varchar(50)),space(1)) + '" ' +	
	'Updptv161="'+ coalesce(cast(@UpdatePositiontakingv161 as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(5000)),space(1)) + '" />' +

	'<ag apt_1="'+ coalesce(cast(@Old_apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'apt_2="'+ coalesce(cast(@Old_apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'apt_3="'+ coalesce(cast(@Old_apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'apt_4="'+ coalesce(cast(@Old_apositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'apt_5="'+ coalesce(cast(@Old_apositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'apt_6="'+ coalesce(cast(@Old_apositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'apt_7="'+ coalesce(cast(@Old_apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'apt_8="'+ coalesce(cast(@Old_apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'apt_9="'+ coalesce(cast(@Old_apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'apt_10="'+ coalesce(cast(@Old_apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	-- Outright PT for sports
	'v2apt_10="'+ coalesce(cast(@Old_v2apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v3apt_10="'+ coalesce(cast(@Old_v3apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v5apt_10="'+ coalesce(cast(@Old_v5apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v8apt_10="'+ coalesce(cast(@Old_v8apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v10apt_10="'+ coalesce(cast(@Old_v10apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v11apt_10="'+ coalesce(cast(@Old_v11apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v99apt_10="'+ coalesce(cast(@Old_v99apositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	'apt_9999="'+ coalesce(cast(@Old_apositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'alivept_1="'+ coalesce(cast(@Old_alivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'alivept_3="'+ coalesce(cast(@Old_alivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'alivept_7="'+ coalesce(cast(@Old_alivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'alivept_8="'+ coalesce(cast(@Old_alivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2apt_1="'+ coalesce(cast(@Old_v2apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2apt_2="'+ coalesce(cast(@Old_v2apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2apt_3="'+ coalesce(cast(@Old_v2apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2apt_7="'+ coalesce(cast(@Old_v2apositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2apt_8="'+ coalesce(cast(@Old_v2apositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'v2apt_20="'+ coalesce(cast(@Old_v2apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3apt_1="'+ coalesce(cast(@Old_v3apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3apt_2="'+ coalesce(cast(@Old_v3apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3apt_3="'+ coalesce(cast(@Old_v3apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3apt_20="'+ coalesce(cast(@Old_v3apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5apt_1="'+ coalesce(cast(@Old_v5apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5apt_2="'+ coalesce(cast(@Old_v5apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5apt_3="'+ coalesce(cast(@Old_v5apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5apt_20="'+ coalesce(cast(@Old_v5apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v5apt_9999="'+ coalesce(cast(@Old_v5apositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	'v8apt_1="'+ coalesce(cast(@Old_v8apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8apt_3="'+ coalesce(cast(@Old_v8apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8apt_20="'+ coalesce(cast(@Old_v8apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10apt_1="'+ coalesce(cast(@Old_v10apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10apt_2="'+ coalesce(cast(@Old_v10apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10apt_3="'+ coalesce(cast(@Old_v10apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10apt_20="'+ coalesce(cast(@Old_v10apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11apt_1="'+ coalesce(cast(@Old_v11apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11apt_20="'+ coalesce(cast(@Old_v11apositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99apt_1="'+ coalesce(cast(@Old_v99apositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99apt_2="'+ coalesce(cast(@Old_v99apositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99apt_3="'+ coalesce(cast(@Old_v99apositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99apt_20="'+ coalesce(cast(@Old_v99apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	--- mixed sports
	'v99apt_9="'+ coalesce(cast(@Old_v99apositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v154apt_20="'+ coalesce(cast(@Old_v154apositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	--mixed sports
	'v161apt_81="'+ coalesce(cast(@Old_v161apositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161apt_83="'+ coalesce(cast(@Old_v161apositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'v161apt_85="'+ coalesce(cast(@Old_v161apositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161apt_86="'+ coalesce(cast(@Old_v161apositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161apt_88="'+ coalesce(cast(@Old_v161apositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'v161alivept_85="'+ coalesce(cast(@Old_v161alivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161alivept_86="'+ coalesce(cast(@Old_v161alivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161alivept_87="'+ coalesce(cast(@Old_v161alivepositiontaking_87 as varchar(50)),space(1)) + '" ' + 
	'v161alivept_89="'+ coalesce(cast(@Old_v161alivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161alivept_90="'+ coalesce(cast(@Old_v161alivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	'<m mpt_1="'+ coalesce(cast(@Old_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'mpt_2="'+ coalesce(cast(@Old_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'mpt_3="'+ coalesce(cast(@Old_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'mpt_4="'+ coalesce(cast(@Old_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'mpt_5="'+ coalesce(cast(@Old_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'mpt_6="'+ coalesce(cast(@Old_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'mpt_7="'+ coalesce(cast(@Old_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'mpt_8="'+ coalesce(cast(@Old_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'mpt_9="'+ coalesce(cast(@Old_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'mpt_10="'+ coalesce(cast(@Old_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'v2mpt_10="'+ coalesce(cast(@Old_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v3mpt_10="'+ coalesce(cast(@Old_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v5mpt_10="'+ coalesce(cast(@Old_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v8mpt_10="'+ coalesce(cast(@Old_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v10mpt_10="'+ coalesce(cast(@Old_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v11mpt_10="'+ coalesce(cast(@Old_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'v99mpt_10="'+ coalesce(cast(@Old_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	
	'mpt_9999="'+ coalesce(cast(@Old_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'mlivept_1="'+ coalesce(cast(@Old_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'mlivept_3="'+ coalesce(cast(@Old_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'mlivept_7="'+ coalesce(cast(@Old_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'mlivept_8="'+ coalesce(cast(@Old_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	'v2mpt_1="'+ coalesce(cast(@Old_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v2mpt_2="'+ coalesce(cast(@Old_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v2mpt_3="'+ coalesce(cast(@Old_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v2mpt_7="'+ coalesce(cast(@Old_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'v2mpt_8="'+ coalesce(cast(@Old_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'v2mpt_20="'+ coalesce(cast(@Old_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v3mpt_1="'+ coalesce(cast(@Old_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v3mpt_2="'+ coalesce(cast(@Old_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v3mpt_3="'+ coalesce(cast(@Old_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v3mpt_20="'+ coalesce(cast(@Old_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v5mpt_1="'+ coalesce(cast(@Old_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v5mpt_2="'+ coalesce(cast(@Old_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v5mpt_3="'+ coalesce(cast(@Old_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v5mpt_20="'+ coalesce(cast(@Old_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'v5mpt_9999="'+ coalesce(cast(@Old_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	'v8mpt_1="'+ coalesce(cast(@Old_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v8mpt_3="'+ coalesce(cast(@Old_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v8mpt_20="'+ coalesce(cast(@Old_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v10mpt_1="'+ coalesce(cast(@Old_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v10mpt_2="'+ coalesce(cast(@Old_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v10mpt_3="'+ coalesce(cast(@Old_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v10mpt_20="'+ coalesce(cast(@Old_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v11mpt_1="'+ coalesce(cast(@Old_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v11mpt_20="'+ coalesce(cast(@Old_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	'v99mpt_1="'+ coalesce(cast(@Old_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'v99mpt_2="'+ coalesce(cast(@Old_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'v99mpt_3="'+ coalesce(cast(@Old_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'v99mpt_20="'+ coalesce(cast(@Old_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	-- mixed sports
	'v99mpt_9="'+ coalesce(cast(@Old_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'v154mpt_20="'+ coalesce(cast(@Old_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	--number game
	'v161mpt_81="'+ coalesce(cast(@Old_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'v161mpt_83="'+ coalesce(cast(@Old_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'v161mpt_85="'+ coalesce(cast(@Old_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mpt_86="'+ coalesce(cast(@Old_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161mpt_88="'+ coalesce(cast(@Old_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'v161mlivept_85="'+ coalesce(cast(@Old_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_86="'+ coalesce(cast(@Old_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_87="'+ coalesce(cast(@Old_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_89="'+ coalesce(cast(@Old_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'v161mlivept_90="'+ coalesce(cast(@Old_v161mlivepositiontaking_90 as varchar(50)),space(1)) +'" />' +

	--auto v1
	'<aum a_mpt_1="'+ coalesce(cast(@Old_auto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_mpt_2="'+ coalesce(cast(@Old_auto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_mpt_3="'+ coalesce(cast(@Old_auto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_mpt_4="'+ coalesce(cast(@Old_auto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'a_mpt_5="'+ coalesce(cast(@Old_auto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'a_mpt_6="'+ coalesce(cast(@Old_auto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'a_mpt_7="'+ coalesce(cast(@Old_auto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_mpt_8="'+ coalesce(cast(@Old_auto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'a_mpt_9="'+ coalesce(cast(@Old_auto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_mpt_10="'+ coalesce(cast(@Old_auto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'a_v2mpt_10="'+ coalesce(cast(@Old_auto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_10="'+ coalesce(cast(@Old_auto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_10="'+ coalesce(cast(@Old_auto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_10="'+ coalesce(cast(@Old_auto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_10="'+ coalesce(cast(@Old_auto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v11mpt_10="'+ coalesce(cast(@Old_auto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_10="'+ coalesce(cast(@Old_auto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	
	'a_mpt_9999="'+ coalesce(cast(@Old_auto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_1="'+ coalesce(cast(@Old_auto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_3="'+ coalesce(cast(@Old_auto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_7="'+ coalesce(cast(@Old_auto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_mlivept_8="'+ coalesce(cast(@Old_auto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	--auto v2
	'a_v2mpt_1="'+ coalesce(cast(@Old_auto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_2="'+ coalesce(cast(@Old_auto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_3="'+ coalesce(cast(@Old_auto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_7="'+ coalesce(cast(@Old_auto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_8="'+ coalesce(cast(@Old_auto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'a_v2mpt_20="'+ coalesce(cast(@Old_auto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v3
	'a_v3mpt_1="'+ coalesce(cast(@Old_auto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_2="'+ coalesce(cast(@Old_auto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_3="'+ coalesce(cast(@Old_auto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v3mpt_20="'+ coalesce(cast(@Old_auto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v5
	'a_v5mpt_1="'+ coalesce(cast(@Old_auto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_2="'+ coalesce(cast(@Old_auto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_3="'+ coalesce(cast(@Old_auto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_20="'+ coalesce(cast(@Old_auto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'a_v5mpt_9999="'+ coalesce(cast(@Old_auto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	--auto v8
	'a_v8mpt_1="'+ coalesce(cast(@Old_auto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_3="'+ coalesce(cast(@Old_auto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v8mpt_20="'+ coalesce(cast(@Old_auto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v10
	'a_v10mpt_1="'+ coalesce(cast(@Old_auto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_2="'+ coalesce(cast(@Old_auto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_3="'+ coalesce(cast(@Old_auto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v10mpt_20="'+ coalesce(cast(@Old_auto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v11
	'a_v11mpt_1="'+ coalesce(cast(@Old_auto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v11mpt_20="'+ coalesce(cast(@Old_auto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--auto v99
	'a_v99mpt_1="'+ coalesce(cast(@Old_auto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_2="'+ coalesce(cast(@Old_auto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_3="'+ coalesce(cast(@Old_auto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'a_v99mpt_20="'+ coalesce(cast(@Old_auto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	---mixed sports
	'a_v99mpt_9="'+ coalesce(cast(@Old_auto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'a_v154mpt_20="'+ coalesce(cast(@Old_auto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	-- number game
	'a_v161mpt_81="'+ coalesce(cast(@Old_auto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_83="'+ coalesce(cast(@Old_auto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'a_v161mpt_85="'+ coalesce(cast(@Old_auto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_86="'+ coalesce(cast(@Old_auto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161mpt_88="'+ coalesce(cast(@Old_auto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'a_v161mlivept_85="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_86="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_87="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_89="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'a_v161mlivept_90="'+ coalesce(cast(@Old_auto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" />' +

	--isauto v1
	'<iam isa_mpt_1="'+ coalesce(cast(@Old_isauto_mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_2="'+ coalesce(cast(@Old_isauto_mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_3="'+ coalesce(cast(@Old_isauto_mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_4="'+ coalesce(cast(@Old_isauto_mpositiontaking_4 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_5="'+ coalesce(cast(@Old_isauto_mpositiontaking_5 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_6="'+ coalesce(cast(@Old_isauto_mpositiontaking_6 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_7="'+ coalesce(cast(@Old_isauto_mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_8="'+ coalesce(cast(@Old_isauto_mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_9="'+ coalesce(cast(@Old_isauto_mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_mpt_10="'+ coalesce(cast(@Old_isauto_mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	-- Outright PT for sports
	'isa_v2mpt_10="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_10="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_10="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_10="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_10="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v11mpt_10="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_10="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_10 as varchar(50)),space(1)) + '" ' +
	
	
	'isa_mpt_9999="'+ coalesce(cast(@Old_isauto_mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_1="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_3="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_7="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_mlivept_8="'+ coalesce(cast(@Old_isauto_mlivepositiontaking_8 as varchar(50)),space(1)) + '" ' +

	--isauto v2
	'isa_v2mpt_1="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_2="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_3="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_7="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_7 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_8="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_8 as varchar(50)),space(1)) + '" ' +
	'isa_v2mpt_20="'+ coalesce(cast(@Old_isauto_v2mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v3
	'isa_v3mpt_1="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_2="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_3="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v3mpt_20="'+ coalesce(cast(@Old_isauto_v3mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v5
	'isa_v5mpt_1="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_2="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_3="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_20="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	'isa_v5mpt_9999="'+ coalesce(cast(@Old_isauto_v5mpositiontaking_9999 as varchar(50)),space(1)) + '" ' +

	--isauto v8
	'isa_v8mpt_1="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_3="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v8mpt_20="'+ coalesce(cast(@Old_isauto_v8mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v10
	'isa_v10mpt_1="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_2="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_3="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v10mpt_20="'+ coalesce(cast(@Old_isauto_v10mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--isauto v11
	'isa_v11mpt_1="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v11mpt_20="'+ coalesce(cast(@Old_isauto_v11mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	--isauto v99
	'isa_v99mpt_1="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_1 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_2="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_2 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_3="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_3 as varchar(50)),space(1)) + '" ' +
	'isa_v99mpt_20="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_20 as varchar(50)),space(1)) + '" ' +

	--mixed sports
	'isa_v99mpt_9="'+ coalesce(cast(@Old_isauto_v99mpositiontaking_9 as varchar(50)),space(1)) + '" ' +
	'isa_v154mpt_20="'+ coalesce(cast(@Old_isauto_v154mpositiontaking_20 as varchar(50)),space(1)) + '" ' +
	
	-- number game
	'isa_v161mpt_81="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_81 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_83="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_83 as varchar(50)),space(1)) + '" ' +
	--'isa_v161mpt_85="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_86="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'isa_v161mpt_88="'+ coalesce(cast(@Old_isauto_v161mpositiontaking_88 as varchar(50)),space(1)) + '" ' +

	'isa_v161mlivept_85="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_85 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_86="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_86 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_87="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_87 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_89="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_89 as varchar(50)),space(1)) + '" ' +
	'isa_v161mlivept_90="'+ coalesce(cast(@Old_isauto_v161mlivepositiontaking_90 as varchar(50)),space(1)) + '" /></Acc_CustomerUpdAgent_PositionTaking>'

	--Log positiontaking
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 412,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END CATCH
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_PositionTaking] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_PositionTaking] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgent_PositionTaking] TO [vnteam] AS [dbo]